# Opportunistic semantic function instances

## Outcome

**Delivered:** a compiler-internal *semantic instance* layer (`hir/semantic.tcl`,
about 700 lines, plus small hooks in `hir/types.tcl`, `hir/range.tcl`,
`hir/callables.tcl`, `hir/specialize.tcl`, `hir/hir.tcl`). When a call's target
block is statically known and the call's argument types say more than the
block's own entry types, the *ordinary body* of the function is analyzed once
more under those concrete argument types -- the same `hir::types` walk,
refinements, flow facts, reachability and nested-closure typing every function
body gets -- and the call is typed with what that analysis proves. No source
syntax, no type variable, no generic function type, no `codeTargets`, no
struct, no source refactor: the milestone tests whether they are needed.

```
fn identity(x): x                   identity(m : MutableArray[str])  ->  MutableArray[str]
fn capacity(x): capacity(x)         capacity(m : MutableArray[str])  ->  int
fn first(xs): list_get(xs, 0)       first(List[str]) -> str          first(List[int]) -> int
list::find(xs, predicate)           find(List[str], is_b) -> str     find(List[int], big) -> int
```

The parameter/result relationship is never written down anywhere: it falls out
because the body returns `x` and `x` had a concrete type.

**Semantic instances are analysis, not codegen.** Nothing here emits code,
clones HIR or creates a `hir::specialize` instance. On the frozen canonical
corpus (17 programs) the layer creates **252 semantic instances** (all valid)
that run through the **same 245 codegen instances** as before; the emitted NIR
of all 17 programs, and the scalar machine code of all 17, are **byte-identical**
to the parent tree. `hir::specialize::KeyType` is untouched
(`KeyType(MutableArray[T]) = mutarray` still).

**Measured effects, honestly:**

* 62 of 403 exact-block call sites in the corpus got a more precise semantic
  result (`any` -> `int`/`str`/`List[str]`/`List[List[int]]`/...); `chars_of`,
  `list::find`, `ht_fold`, the recursive accumulators of `lex-strategy`,
  `matmul`, `uri-steady`, `string_*`, `ai_text_clean` are among them.
* The strict-contract counterfactual (`variant-all-trusted`, the exact same
  scratch experiment) goes **35 -> 32 sites** (10 -> 9 of 31 programs): three
  call-boundary sites disappear (`list::find` erasure in `source-checks`,
  `classifier(c)` fed from `chars_of`, the `ht_fold` callback) and one is
  re-attributed to the call (`test-selection`, `list::find`). The rest are
  **definition-level obligations**, which an instance cannot discharge by
  design (a semantic instance never rescues a definition; see "Definition
  validity vs call-instance validity").
* Two annotations that were proposed are answered: `chars_of`'s result
  annotation is **no longer required** (the concrete instance proves
  `List[str]`); `total_valid` / `select_affected` / `esc_bytes` remain
  definition-level obligations.
* The nine builder-flow sites are **unchanged**: the value type now reaches
  the inside of `geo_append<...>` (instances with `value : mutarray` exist),
  and dies at the positional `[storage, length]` pair and at the raw
  `mutable_array_freeze`. A scratch control (nothing merged) shows the
  *machinery* is sufficient for one shared untyped `append` to serve three
  element types once the storage is typed and not paired: see "Readiness for
  typed-builder source refactor".
* Intentional behavior changes: 32 pre-existing tests pinned the *old* boundary
  (an untyped `identity` erases a typed array; a typed callable cannot pass an
  untyped higher-order parameter). Their expectations changed, and each now
  carries an equivalent or stricter soundness probe (table in "Full
  regression").
* Front-end compile time on the 17-program corpus grows (table in "Compile-time
  impact"); the dominant functions are named there. No source or generated-code
  change.

## Motivation

`MutableArray[T]` and structural `Fn{...}` made static contracts real, but an
ordinary untyped function could not preserve them: `identity(MutableArray[str])`
was rejected (the untyped parameter is `any`, erasing the element contract), and
a read-only wrapper such as `fn capacity(x): mutable_array_capacity(x)` was
rejected because intrinsic inference gives it the raw `mutarray` requirement.
Both are not cases where the programmer needs a generic type: for a concrete call
the compiler already knows enough to analyze the function under the actual types.

## Source functions vs semantic instances vs codegen instances

| term | what | where |
|---|---|---|
| **source function** | the one function the programmer wrote (a block expression) | HIR |
| **semantic instance** | a compiler-internal analysis of that function under one concrete semantic entry environment | `hir::semantic` tables |
| **codegen instance** | an emitted lowered/native function body | `hir::specialize` instances, NIR `func` |
| **specialization key** | the representation-oriented grouping codegen instances share (`KeyType`) | `hir::specialize::KeyType` |

They are deliberately separate. A semantic instance may (a) share a codegen
instance with other semantic instances (`identity<MutableArray[str]>` and
`identity<MutableArray[int]>` run the same generic code), (b) disappear through
inlining (no codegen identity at all), (c) have no codegen instance because
codegen never reaches it. None ever *causes* one: nothing in `hir/semantic.tcl`
calls `hir::specialize`.

## Why this is not user-facing generics

Nothing in the source language, the type namespace, `hir::moduleSignatures` or
any diagnostic changes shape: no `fn f[T]`, `where`, `forall`, `T`, generic `Fn`.
`mat-syn-5` and `si-nogen-1` pin that those spellings are still syntax/unknown-
type errors. Instances are an *implementation fact about analysis*: which
instances are analyzed depends on which calls exist, adding a caller can only add
an instance, and an instance is never part of any function's contract. The
public signature of `identity` stays `x : any -> any` (`si-nogen-2/3`).

## Semantic instance key

`{BLOCK ENTRY-TYPES}`: the block's ExprId and one **full semantic type** per
parameter. `MutableArray[str]`, `MutableArray[int]`, `List[str]`, `List[int]`,
`Fn{args:[str],...}`, `Fn{args:[int],...}` and exact callables `{block E ...}`
are all distinct key components and are never projected to `mutarray`, `list`,
`block`, `native` or `any`. `ENTRY-TYPES[i]` is

* the argument's static type, for a parameter with no declared or trusted-
  inferred contract (`hir::signatures::entryTypes`);
* for a parameter *with* one, the argument type if it is a subtype of the
  contract (a `Dog` for an `Animal` parameter), else the contract itself.

Exact scalar values are **not** in the key (`identity(0)`, `identity(1)`,
`identity(2)` are one instance `identity<int>`: `si-sep-4`). Ranges and exact
sets are not in the key either; existing range machinery still supplies its own
local facts. A request whose entry types equal the block's generic entry types
(`any` arguments, or arguments equal to the declared types) would re-run the
generic analysis: it is *trivial*, not an instance, and keeps the generic
result (an argument that is genuinely `any` stays broad: `si-id-7/8`).

Instance ids (`s0`, `s1`, ...) are allocated in discovery order of a
deterministic walk; they appear only in audit output, never in diagnostics.

## Entry environment

* **Parameters**: the entry types above, seeded into the walk's `types`.
* **Captures**: the recorded creation environment (next section).
* **Module-static bindings**: typed once per program by
  `hir::types::BindingType`, never per instance.
* **Self / forward references**: as in the generic walk (`{block E ARITY any}`);
  the recursion result comes from the instance table, not from the exact type.

## Capture handling

*Audit question:* can the semantic analysis of a block depend on varying capture
types? Yes: an exact block type names a *code target*, not a closure
environment, and the same block expression is created once per activation of its
enclosing function.

*Chosen model and proof.* The entry environment of a block's instance is the
environment its **generic** analysis recorded where the block is created
(`RecordEnv`: the type of each captured binding in the creating walk, in `Block`
before its body is typed). The generic analysis of the enclosing function is
valid for every activation of it, so every closure of that block that ever exists
captures values whose types are subtypes of the recorded ones; an instance
analyzed under the recorded types is therefore sound for every closure of the
block. The key needs no capture component because the recorded environment is a
function of the block alone. (We considered keying on capture types: it would
create one instance per environment revision, and the model above needs none.)

Consequences, all pinned:

* A closure created *inside an instance's walk* (`mk<MutableArray[str]>` creating
  `get`) is typed in place with the instance's precise environment as part of
  that instance's *region*; its body is verified with the enclosing instance, so
  an invalid write inside it is found (`si-cap-2`). The same source closure is
  typed differently per enclosing instance (`si-cap-1`: `str` and `int`). Its
  own calls also request an instance under the recorded (generic) environment,
  and the call keeps whichever result is more precise (`si-cap-3/4`).
* A recursive enclosing function types its body up to three times under an
  optimistic result assumption. If a later attempt records a *different*
  environment for a nested block, every instance analyzed under the old one is
  re-analyzed with its readers and the worklist is drained before the next
  request reads an answer (`si-cap-6`); no stale answer survives.
* A block with captures whose creating walk has not run yet (a *forward call*)
  has no environment in this pass. The request is declined (`no-env`) and
  `hir::types::infer` walks the program once more with the environments the
  first walk recorded (at most 3 walks; every walk is sound, later ones more
  precise). Definition order therefore does not change the result
  (`si-det-1`, `si-rec-2`). In the frozen corpus no request was declined
  (functions are defined before use or capture nothing): every program needed one
  walk.

## Demand-driven discovery

Instances are requested only by exact, statically reachable block calls
(`hir::types::Call`'s `{block E ARITY R}` callee) in the program or in an existing
instance's body. There is no enumeration of type combinations. Calls in
statically unreachable branches request nothing (`si-rec-7`). Calls of natives,
of blocks carrying an intrinsic container rule (`mutarray::from_list`/`create`,
`hir/containers.tcl`), and the native backend's `-native-body` overrides never
create instances. A call through a structural `Fn` or an open value has no exact
target and creates none (`si-dyn-1`).

Note that a function *body* is walked by the generic analysis whether or not
anything calls the function, so a call written inside an uncalled function still
requests instances from its own concrete arguments (`si-rec-7`).

## Caching and canonicalization

Identical canonical `{BLOCK ENTRY-TYPES}` keys are one instance (`hits` in the
census: 821 of 1665 requests were cache hits, 592 trivial, 252 created).
Types are the canonical forms `hir::types` already produces; there is no
dependence on dict iteration order, definition order, ExprId identity of
arguments or traversal order (`si-det-1` compiles the same program in three
definition orders and compares the canonical instance sets and results; `si-det-2`
compares two compilations). Two keys are merged only when canonically equal --
never merely because their runtime representation is equal.

## Recursion / SCC handling

An instance being analyzed that is requested again answers with its current
result, initially `never`, the same optimistic assumption `hir::types::Block`
uses. `Analyze` re-walks until the result stops growing (`lub`); a change that
other *analyzing* instances already read marks them dirty, one that *finished*
instances read queues them; `Drain` re-analyzes queued instances oldest first.
A top-level request returns only settled answers. Self recursion, mutual
recursion in either definition order (`si-rec-1/2/4`) and type-changing recursion
(`f<A>` -> `f<B>`, `si-rec-3`) terminate. In the frozen corpus 91 instances are
recursive/SCC participants; the maximum passes any instance needed is 2. An
instance that read no in-progress answer needs one walk.

## Termination / budgets

* The type lattice is finite: aggregate nesting is bounded (depth 3,
  `hir::types::MakeList`/`MakeMutArray`), so `f(T) -> f(List[T]) -> ...` stops at
  the bound (`si-rec-3`: the chain `wrap("a", 5)` produces at most the per-block
  budget of instances and is `any`).
* Results only grow; more than `passLimit` (6) growing passes give `any`.
* Budgets: `maxPerBlock` 16, `maxInstances` 2000, `maxDepth` 24 nested
  analyses (and a stack-depth guard). A request beyond a budget is **declined**
  and keeps its ordinary generic typing.
* *A budget never turns into a false error and never accepts an erasure*: the
  fallback is the pre-existing behavior. A declined call gives its parameters no
  instance context, so `hir::callables` still rejects a bearing argument that
  would cross an untyped parameter (`si-rec-5/6`); a non-bearing call simply gets
  the generic result. No budget was hit in the corpus.

## Definition validity vs call-instance validity

Three levels stay distinct:

* **explicitly typed function**: the definition must satisfy its declared
  contract for every admitted value; unchanged, checked by the existing
  `verifyDeclaredResults`/`verifyDeclaredParams`. `si-bad-7`: an instance cannot
  rescue an invalid definition.
* **untyped function**: ordinary generic/source semantics continue to exist; the
  generic body is analyzed and verified exactly as before.
* **semantic instance**: one call environment, accepted or rejected more
  precisely. `verify` runs, on a *view* of the HIR that carries an instance's
  snapshot, the same per-body checks a definition gets -- typed-call
  admissibility and the MutableArray store/copy rules (`hir::range::
  verifyBlocks`, the refactored body of `verifyDeclaredParams`) and the bearing/
  non-erasure audit (`hir::callables::verifyBlocks`). A diagnostic there means
  "this function is invalid for *this call*" and is reported at that call. The
  source function is not rejected: `f<int>` valid, `f<str>` invalid
  (`si-bad-3`), a valid `writer` instance does not make `writer(m, 5)` valid
  (`si-bad-4`). A problem the definition already has for every call (the generic
  verification reported the same diagnostic at the same expression) stays the
  definition's and is not re-reported per call. A call to an invalid instance from
  inside another instance makes the caller invalid too, with a nested message
  (`si-bad-5`).

## Intrinsic contracts interaction

`hir/signatures.tcl` is untouched. Intrinsic contracts are still derived from
declaration + body alone, independent of the caller population (`si-nogen-2/3`;
`hir::moduleSignatures` still reports `list::find` params `{list any}`). Two
consequences worth stating:

* The *generic* walk types a call to an exact block with its instance result, so
  a body that calls another function with concrete arguments gets a more precise
  intermediate type. Intrinsic inference reads those types; that is the body
  analysis improving, not caller information entering (no caller-population fact
  reaches any signature).
* A *checked-only* requirement (a native's `-param-types`, an `if` condition) is
  the run-time-validated description of an unconstrained caller. For a call whose
  argument is contract-*bearing* (a `MutableArray[T]`, a typed callable) and that
  has an instance, `VerifyCall` does not apply the checked mismatch
  (`MutableArray[str]` vs the raw `mutarray` requirement of `capacity`): the body
  was analyzed with the argument's own type and any misuse is that instance's
  diagnostic. Non-bearing arguments keep the existing static check (`f("a")` for
  `f(x): x + 1` is still rejected). *Trusted* (declared/inferred-trusted)
  requirements are unchanged and still enforced at every call, because the
  generic code that runs assumes them.

## Explicit declarations interaction

`fn f(x: T)`: the declared type is the definition's contract. The instance seeds
`x` with the argument type only if it is a subtype of `T` (`Small` for
`x: Small` gives result `int[Small]`; a `List[int]` argument for `xs: list`
gives `MutableArray[int]` from `from_list(xs)`: `mat-fl-2`, `si-decl-1`). A
non-provable argument keeps `T` as seed and is rejected by the ordinary
`VerifyCall` proof (`si-decl-2`). A narrower argument fact is used for result
precision and optimization only.

## Bearing/non-erasure integration

The generalized `Bearing`/`Preserves` machinery (`hir/callables.tcl`) is used
unchanged, in two places:

1. **Argument contexts.** For a call with an instance, `ArgContexts` uses the
   instance's entry type as the destination context for a parameter with no
   declared/trusted contract (instead of "no declaration -> `""` -> erasure").
   `identity(MutableArray[str])` therefore sees its destination as
   `MutableArray[str]` and `Preserves` holds trivially. Declared/trusted
   parameters keep their declared context. A declined call keeps `""`.
2. **The instance's own body** is audited by the same walk on the view:
   returning, joining, storing and passing the value are checked against the
   types the *instance* has, so the contract must actually be preserved by the
   body.

`si-brg-*` probe every route: a declared raw/any result (`erase(x) -> mutarray`),
storing into raw storage, a join with an erasing value, a kind test followed by a
write, an unknown structural callee (no exact target, no instance: rejected as
before), an exact callee that keeps the contract (accepted), a list of arrays
kept element-wise and its erasure into `-> list` rejected. The instance never
bypasses a rule: an erasing body is *invalid for that call*.

## Instance result typing

The result of an instance is the ordinary `lub(body, returns)` of its walk (a
declared result stays authoritative). The call is typed with the instance result
when it `Refines` the generic result: a subtype of it, the same exact callable
whose own result is more precise (a closure created inside the instance), or a
type that differs only by carrying MutableArray element contracts the generic
result has erased (a `MutableArray[T]` is not a subtype of the raw kind -- that
would be the erasure -- but describes the same values with more contract).
Otherwise the generic result stays: the generic result is sound for every
argument, so a less precise instance answer never replaces it. The relation is
stored as a side table keyed by (context, call ExprId) -> instance; the call's
type is the ordinary `type` field of the HIR, so every later analysis (refinement,
flow facts, range, bearing audit, specialization) reads it with no new path.

## Error/completion typing

The instance walk computes `calleeErrors`, reachability and `known` outcomes with
the ordinary machinery, so a concrete instance may have more precise reachability
(`describe(41)` proves the `string?` arm unreachable: `int`, and `describe("hi")`
is `str`). Declared error contracts stay authoritative and are not changed
(`list::find` still `errors NotFound`, `si-hof-5`). Completion/error-set legality
(`hir::errorsets`) is a definition-level check on the generic body and is not
re-run per instance: instance types add no new completion diagnostic. One
consequence of precision reaches it: `handle list::find(strs, p) NotFound: 0` now
has the call's own type `str`, and the ordinary "handled result is the call's
type, no implicit union widening" rule rejects the `0` (`si-hof-8`); with an `any`
result that was silently accepted before.

## Exact callable arguments

An argument of exact callable type keeps it: `find<List[str], is_b/1 -> bool>`
seeds `predicate : {block is_b 1 bool}`, so `predicate(x)` inside the body is an
exact call of `is_b` with `x : str` -- itself a request for `is_b<str>`. No finite
union of callable identities is invented. A structural `Fn` argument is seeded as
that `Fn`. `Fn{args:[any],...}` is never forced merely because the source
parameter is untyped (`si-brg-6`, `si-decl-3`, `si-hof-*`). This is what makes a
typed/exact callable pass through an untyped higher-order parameter *only because
that instance seeds the parameter with its full contract*: the escape rules are
not weakened globally (the unknown-callee probes are still rejected).

## Dynamic-call boundary

A callee that is only `Fn{...}`, `any` or an open value has no exact block
implementation, so nothing is instantiated and the callable contract is used
(`si-dyn-1`, `si-brg-5`, `mat-atk-11`'s dynamic probes). Finite target propagation
is future work; no `codeTargets` exists.

## KeyType remains codegen-oriented

`hir::specialize::KeyType` is unchanged (`si-sep-1` pins `KeyType(MutableArray[T])
= mutarray`, `List` keeps its element, structural `Fn` is `any`). The only edit in
`hir/specialize.tcl` is in the result of a call inside an instance's region
inference: it takes the semantic instance result when that is a subtype of the
key-type instance's (never less precise than the semantic HIR). The instance
count did not move (245 before and after), and the corpus NIR is byte-identical.

## Semantic-to-codegen mapping

A semantic instance has no codegen identity of its own; it runs through the
codegen instance `hir::specialize` chose for the *calls that requested it*
(specialize records call ExprId -> callee instance). `audit/opportunistic-
semantic-instances/tools/census.tcl` derives the relation from those recorded
targets and the `func` entries of the lowered NIR. See "Codegen instance census".

## Inlining interaction

An inlined call has no codegen identity: the request is recorded when the call
is analyzed, independently of whether the native lowering later inlines the
callee. No clone is kept to make accounting easier. In the corpus, of the 252
semantic instances 7 reach a codegen instance that is not emitted as a function
(inlined), and 11 have no used codegen call site (their caller is unused by
codegen, or the call folded away).

## Codegen sharing

Recorded in the census: 158 semantic instances run through 66 codegen instances
that host more than one of them (e.g. `chars_of<str, int, list>`,
`chars_of<str, int, List[str]>` and `chars_of<any, int, List[never]>` all run
`chars_of<str, int, List[str]|List[never]>`). Static type differences do not
justify machine-code duplication, and there is none.

## identity controls

`audit/opportunistic-semantic-instances/out/probes-controls.txt` (and `-off`, the
same programs with the layer disabled):

| program | with instances | without (parent behavior) |
|---|---|---|
| `identity(5)` | `int` | `any` |
| `identity("a")` | `str` | `any` |
| `identity([1, 2])` | `List[int]` | `any` |
| `identity(mutarray::create(2, "x"))` | `MutableArray[str]` | rejected: cannot erase element contract |
| `identity(m : MutableArray[int])` | `MutableArray[int]` | rejected |
| `n = identity(m); mutable_array_set(n, 0, "y")` | valid, `str` | rejected |
| `mutable_array_set(n, 0, 123)` | rejected (int not admissible to str) | rejected |
| `f = identity; f(m)` (exact alias) | `MutableArray[str]` | rejected |
| `fn g(y): identity(y); g(1)` (arg genuinely `any` inside `g`) | `int` (g's instance) | `any` |

## MutableArray forwarder controls

`fn forward(x): y = x; y` keeps `MutableArray[str]` through the immutable alias
(no alias mechanism specific to generics: `si-id-5`); `twice(x): identity(
identity(x))` composes instances (`si-id-6`); a typed array in a list survives
element-wise (`stash(m) : List[MutableArray[str]]`) and is rejected when the same
function declares `-> list` (`si-brg-7`).

## read-only wrapper controls

`fn capacity(x): mutable_array_capacity(x)` accepts `MutableArray[str]` and gives
`int` (`si-ro-1`); `fn first(x): mutable_array_get(x, 0)` gives `str` for
`MutableArray[str]` and `int` for `MutableArray[int]`, two simultaneous instances
(`si-ro-2/3`); `freeze` keeps `List[T]` (`si-ro-4`).

## invalid instance controls

```
fn smash(x): mutable_array_set(x, 0, 123)
m = mutarray::create(2, "x")
smash(m)
```
```
4:1: call to smash with x : MutableArray[str] is invalid: value of type int is not
admissible to element type str of MutableArray[str] (facts: [123, 123] {123}): a
MutableArray's element type is fixed for its lifetime, a store never widens it and
inserts no check (in the body of smash, at 2:29)
```
The diagnostic names the *call*, the concrete environment and the body position,
and no synthetic name (`si-bad-6`). `smash(mutable_array_allocate(1))` (raw) and
`writer(m, "ok")` are accepted; `writer(m, 5)` is rejected; `f(1)` valid and
`f("a")` invalid for `f(x): x + 1`. Erasing bodies are rejected per call
(declared raw result, raw storage, join, kind-test write, nested two-hop
`b(x): a(x)` where `a` writes an int).

## List element/result controls

`first(List[str]) : str`, `first(List[int]) : int`,
`first(List[MutableArray[str]]) : MutableArray[str]` (`si-list-1`), both instances
in one program (`si-list-2`); `copy(xs): loop x in xs: x` gives `List[str]` /
`List[int]` without hard-coding `copy` (`si-list-3`); a recursive accumulator
`collect(xs, i, acc)` with `acc : List[never]` at entry gives `List[str]` /
`List[int]` (`si-list-4`, and `mutarray-list-7`, which previously pinned `any`,
now gives `List[mutarray]`).

## list::find

`list::find(xs, predicate)` is unchanged source (`errors NotFound`, no `T`):

| call | result |
|---|---|
| `find(List[str], is_b)` (untyped or `s: str`-typed predicate) | `str` |
| `find(List[int], big)` (untyped or `n: int`-typed predicate) | `int` |
| `find(List[str], big)` with `big(n: int)` or untyped `big(n): n > 5` | rejected: `call to list::find with xs : List[str], predicate : big/1 -> bool is invalid: ...` |
| `find([mutarray::create(1, "x")], nonempty)` | `MutableArray[str]` |

Successful result `str`, error `NotFound`, `x : str`, `predicate(x) : bool` all
come from ordinary body analysis. The typed predicate that was previously
rejected as a callable escape now passes because the instance seeds `predicate`
with its full contract (`si-hof-3/4`); the incompatible case is rejected through
`VerifyCall` inside the body.

## any?/all?/none?

Typed by the same mechanism, result stays `bool`, callbacks are checked against the
element type (`si-hof-6/7`); e.g. `any?(["a"], pos)` with `pos(n: int)` is rejected.

## chars_of

Real source (`bench/lex-strategy.bot`): `chars_of(s, i, acc)` returns its caller's
accumulator. Semantic instances give `chars_of<any, int, List[never]> -> List[str]`,
`chars_of<str, int, List[never]> -> List[str]` and `chars_of<str, int, List[str]>
-> List[str]` (recursion memoized, at most 2 passes); the corpus call sites in
`classify` and `fully_alnum?` are `List[str]` (were `any`). `classify`'s
`classifier(c)` in the strict counterfactual (`lex-strategy.bot:57:20`, the
previous milestone's single "exposed checked requirements" site) **disappears**.
**`chars_of` no longer needs its proposed result annotation**: the concrete
instance proves the relationship without any source change.

## CSV accumulators

`csv.bot`/`csv_chunked`/`csv_geometric`/`csv_records` `scan_records`: the
recursive accumulator relation is recovered as far as the *values* allow
(`scan_records<str, int, List[never]> -> list`), and the result remains `list`,
not `List[List[str]]`: the appended value is `list_get(scanned, 0)` where
`scanned` is the positional `[fields, index]` pair returned by `scan_record`,
whose element type the positional record erases. So the CSV accumulator results
stay broad for a **struct** reason (positional pair), not for the accumulator
relation; the two `csv_records` accumulator-return strict sites are unchanged.

## ht_fold

`ht_fold(table, 0, ht_capacity(table), [], ht_collect_pair)` (`hashtable.bot:362`)
was `any`; the instance `ht_fold<any, int, int, List[never], ht_collect_pair/3 ->
list> -> List[list]` (and, for the recursive call, `<..., List[list], ...>`)
types it `List[list]`. The strict-counterfactual site (`ht_collect_pair` erased
into the untyped callback parameter) **disappears**. The fold's accumulator
element is `list` (the collected `[key, value]` pair): a struct again, so it stops
at `List[list]`. No Hashtable-specific rule was added.

## geo_append

Instances of `geo_append(builder, value)` recorded on the corpus (the same source
function is used for several element kinds):

| program | instances (builder, value) -> result |
|---|---|
| `csv_geometric` | `geo_append<list, any> -> list` |
| `csv_records` | `geo_append<list, any> -> list`, `geo_append<any, mutarray> -> list`, `geo_append<list, mutarray> -> list` |

So *multiple semantic value-type instances of one source function exist* without
generics: `value : any` (records extracted from the positional scan pair),
`value : mutarray` (row hash tables). What the machinery cannot do with
`geo_append` as written is preserve `T` through the builder: the builder is
`list` (the positional `[storage, length]` pair, a struct boundary) over raw
`mutable_array_allocate` storage, and `mutable_array_freeze` of raw storage is
`list`. That is the frozen source's representation, not a failure of the instance
mechanism. Source unchanged.

## Frozen corpus census

Program set: `bench/*.bot` + `examples/stdlib/*.bot` (17 programs), tool
`audit/opportunistic-semantic-instances/tools/census.tcl`, output
`out/census-after.txt`.

| | count |
|---|---|
| exact-block call requests considered | 1665 |
| trivial (entry types = generic entry types: not an instance) | 592 |
| cache hits (canonically identical key) | 821 |
| **semantic instances created / unique / used** | **252** |
| valid | 252 |
| invalid | 0 |
| declined / fallback (`no-env`, budgets) | 0 |
| recursive / SCC participants (incl. self loops) | 91 |
| functions with more than one semantic instance | 64 |
| maximum instances of one function | 7 (`matmul`'s `product_row`) |
| Walks (body analyses) in all | 343 (maximum passes per instance: 2) |
| walk rounds per program | 1 (no forward-call environment was missing) |
| retained analysis state, text size of tables+snapshots+environments | ~435 KB over 17 programs (about 26 KB per program) |

Which previous `any`/bare boundaries became precise (`out/calltypes-{before,after}.txt`,
every exact-block call site's semantic type, 403 sites, 62 changed):

| function | before | after |
|---|---|---|
| `chars_of(...)` | `any` | `List[str]` / `list` |
| `count_true`, `total_valid`, `valid_chars`, `check`, `drive`, `repeat_uri` | `any` | `int` |
| `list::find(candidates, invalid_name?)` | `any` | `str` |
| `select_affected(...)` | `list` | `List[list]` |
| `esc_bytes`, `esc_from`, `esc_char`, `web::uri_escape_text` | `any` | `str` |
| `clean_ai_text`, `clean_from`, `clean_char`, `replace`, `reverse_*` | `any` | `str` |
| `matmul`, `product_rows`, `product_row`, `dot` | `any` | `List[List[int]]`, `List[List[int]]`, `List[int]`, `int` |
| `ht_fold` | `any` | `List[list]` |
| `row_fill`, `row_table` | `any` | `mutarray` |
| `chunked_copy_chunks` | `any` | `int` |
| `csv_parse`, `scan_records` | `any` | `list` |

## Strict-counterfactual before/after

`audit/intrinsic-function-contracts/tools/validity.tcl` under
`variant-all-trusted.patch`, the *same* scratch experiment on the parent tree
(`out/strict-counterfactual-before.txt`) and this tree
(`out/strict-counterfactual-after.txt`):

| | programs with diagnostics | sites |
|---|---|---|
| before (parent `b1e3e45`) | 10 of 31 | 35 |
| after | 9 of 31 | 32 |

Disappeared (call-boundary sites): `lex-strategy.bot:57:20` (`classifier(c)`, the
`chars_of` accumulator relation), `source-checks.bot:89:40` (`list::find`
erasing a bearing predicate), `hashtable.bot:362:47` (`ht_fold` callback).
Re-attributed: `test-selection.bot:68:31` (erasure of the bearing `is_affected?`
into `list::find`) is now `test-selection.bot:68:13`, reported at the call because
its instance is invalid under that regime (its inner definition-level site
`affected?` requires `list` of an `any` element). Nothing new appears: the
definition-level "inherited" duplicates the instance walk re-derives are recognized
and not re-reported per call.

Why the other 32 stay: under `variant-all-trusted` every inferred requirement is
treated like a declaration *for the definition*: the body of `total_valid` must be
valid for every `tokens`, not just for a `List[str]`. A semantic instance is a
fact about one call and by design never rescues a definition. The remaining sites
are exactly those: `any` arguments coming out of an untyped aggregate element,
a positional pair, a raw MutableArray slot. They are not generic-relation
failures any more.

## Annotation candidates revisited

| candidate | still necessary? | fell out from instances? | needs struct? | other missing relation |
|---|---|---|---|---|
| `chars_of` result | **no** | **yes**: `chars_of<... > -> List[str]`, the strict site is gone | no | none |
| `total_valid` `tokens` | yes: definition-level (`valid_chars(list_get(tokens, i), ...)` needs `str`, the definition sees `tokens : any`) | no | no | a declared parameter contract (`tokens: List[str]`) |
| `select_affected` `tests` | yes: definition-level | no | partly: the elements are positional `[name, deps]` pairs | declared `List[list]`; the pair fields stay `any` |
| `esc_bytes` `bytes` | yes: definition-level (`hex_pair(list_get(bytes, i))`) | no | no | declared `List[Byte]` |

Not added; source is frozen.

## Nine builder-flow sites revisited

`csv_records.bot:452:{20,45,81,99}` and `453:{32,55,77,100,124}` are **unchanged**
(`out/trace-{before,after}-variant.txt` differ only by the `ht_fold` line).
How far the type travels now: a row table (`row_table -> mutarray`, raw) reaches
`geo_append<list, mutarray>`, whose instance sees `value : mutarray` (was `any`);
it is stored into the builder `[storage, length]` (a `list`: struct boundary) over
raw storage, and `geo_finish` freezes raw storage to `list`, so
`list_get(rows, 0)` is `any` again. Blockers, in order: raw builder storage,
positional pair, then (only after those) the shared value relation, which the
instances now provide. Failure to fix the nine is not a failure of the layer.

## Semantic instance census

See "Frozen corpus census". Per-function table (real regime, program calls =
the program's own calls that use the instance):

| function | semantic inputs -> result | status | program calls | codegen instance |
|---|---|---|---|---|
| `chars_of` (lex-strategy) | `<any, int, List[never]>` -> `List[str]` | valid | 2 | `chars_of<str,int,List[never]>` |
| | `<str, int, list>` -> `list` | valid | 1 | `chars_of<str,int,List[str]>` |
| | `<str, int, List[str]>` -> `List[str]` | valid | 0 | `chars_of<str,int,List[str]>` |
| | `<str, int, List[never]>` -> `List[str]` | valid | 0 | same |
| `list::all?` (lex-strategy) | `<List[str], native is_tcl_alnum>` -> `bool` | valid | 1 | `list::all?<List[str], native>` |
| `list::find` (source-checks) | `<List[str], invalid_name?/1 -> bool>` -> `str` | valid | 1 | `list::find<List[str], block>` |
| `list::find` (test-selection) | `<any, is_affected?/1 -> bool>` -> `any`; `<List[list], is_affected?/1 -> bool>` -> `list` | valid | 1 / 0 | `list::find<List[list], block>` |
| `list::any?`/`none?` (test-selection) | `<any, changed?/1>` / `<List[str], changed?/1>` -> `bool` | valid | 0 / 1 | `<any, block>` / `<List[str], block>` |
| `geo_append` (csv_records) | `<list, any>`, `<any, mutarray>`, `<list, mutarray>` -> `list` | valid | 0 / 1 / 0 | `geo_append<list[mutarray,int], mutarray>` |
| `scan_records` (csv_records) | `<str, any, list>`, `<any, int, list>`, `<str, int, list>` -> `list` | valid | 1 / 1 / 0 | one codegen instance |
| `ht_fold` (hashtable) | `<any,int,int,List[never],ht_collect_pair/3 -> list>` -> `List[list]` | valid | 1 | not used by codegen (caller unused) |
| `identity`, `capacity` (focused controls) | see probes | valid | | shared/generic |

The complete tables, including the codegen mapping of every instance, are in
`out/census-after.txt`.

## Codegen instance census

| | count |
|---|---|
| semantic instances | 252 |
| used codegen instances (`hir::specialize`) before / after | **245 / 245** (AOT classification identical: 200 closed, 41 guarded, 4 open) |
| emitted functions (lowered NIR) | 234 (unchanged) |
| semantic instances running through a codegen instance that is emitted | 234 (in 180 codegen instances) |
| semantic instances sharing a codegen instance with another | 158 (in 66 codegen instances) |
| semantic instances whose codegen instance is inlined (not emitted) | 7 |
| semantic instances with no used codegen call site | 11 |
| semantic instances that cause a *new* codegen instance | **0** |
| semantic instances analysis-only in total (do not emit anything of their own) | 252 |

## Generated-code effects

`native/generate-scalar-audit.tcl` over the 17 programs: **byte-identical** to the
parent tree (only the README's `git commit:` line differs); `nir-all.tcl` (NIR text
and instance labels of the same 17 programs, `out/`): **byte-identical**;
`callvalue` 9, direct `call` 285, emitted functions 234, before and after. No
backend rule was added, so the precision does not reach machine code on this
corpus. It does reach the guard *analysis*: `native::report`'s generic blockers
of `ai_text_clean` and `csv_chunked` dropped by one each (6 -> 5, 29 -> 28), i.e.
a representation guard that an `any` call result needed in a *generic* instance
that is not emitted; `native-spec-14` pins the new numbers. So on Q45: yes, one
analysis guard in each of two programs disappeared solely because a semantic call
result became more precise, and no emitted guard changed.

## Compile-time impact

Median of 7 front-end compiles (`surface::readProgramFile -strict 0`: parse, resolve,
intrinsic contracts, type inference including semantic instances, every static
check) of the same 17 programs, parent tree vs this tree, two interleaved runs
(`audit/intrinsic-function-contracts/tools/compiletime.tcl 7`,
`out/compiletime-{before,after}-run{1,2}.txt`, machine otherwise idle):

| | before | after |
|---|---|---|
| run 1 total (ms) | 1484.5 | 2203.2 |
| run 2 total (ms) | 1469.3 | 2213.1 |

That is **+48%** (+50% in run 2), stable across runs, i.e. a material growth.
Where it goes (per program, run 1, ms before -> after): `csv_records` 366 -> 566,
`hashtable` 268 -> 393, `uri-steady` 188 -> 286, `csv_geometric` 89 -> 166,
`csv_chunked` 111 -> 170, `csv` 67 -> 114; the small benchmarks grow by a few ms.
The cost is proportional to the number of body analyses (343 walks for the 17
programs, about 1.5 ms each on `csv_records`, whose 68 instances walk 91 times)
plus one verification of each instance on its view (about 1.4 ms each), on top of
the unchanged generic analysis. Profile of `csv_records` (502 ms instrumented):
`hir::semantic::Walk` 136 ms, `verify` 93 ms (`View` 30 ms, `verifyBlocks` 62 ms).
Copying the HIR for a walk is not the cost (a 1287-expression HIR copies and
modifies in 88 us). Work already done to keep it down: an instance that read no
in-progress answer needs one walk instead of two (`assumes`), only the final
walk is snapshotted, trivial requests never create instances, and identical keys
are cached. The semantic key was **not** coarsened: no evidence yet says the growth
is worth trading precision for; the levers, if it must shrink, are declining
instances with no bearing/higher-order content or reusing instances across the
signature rounds. Memory: the retained analysis state is about 435 KB of
text over the 17 programs (about 26 KB per program), never a cloned HIR.

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl` (Tcl 9.0.1 from the pinned
Ubuntu packages, native backend built with rustc 1.98.1, `cranelift` and
`cranelift-generic` run inside the tests that use them):

| backend | total | passed | skipped | failed |
|---|---|---|---|---|
| interp | 3122 | 3122 | 0 | 0 |
| compile | 3122 | 3122 | 0 | 0 |

The parent tree is 3045/3045 per backend (measured before any change). This
milestone adds `tests/semantic-instances.test` (76 tests; the parity tests run
their program on interp, compile, cranelift-generic and cranelift and require
identical outcomes) and one test in `tests/typed-callable-escape.test` (arity
mismatch through a helper is a run-time error), and updates the expectations of
tests that pinned the old boundary.

Additional runs, all passing: `semantic-instances`, `mutable-array-type` (118),
`mutarray-construction` (76), `native-mutarray` (49) and `native-csv-records`
(21) under `BOTLISH_NATIVE_GC_STRESS=1` on interp and compile. The layer touches
no runtime, GC or rooting code and the generated code is byte-identical, so the
full GC-stress run stays with the `gc-stress` CI job.

**Tests whose expectations changed (32 tests, 2 sample files), and why.** Each is
a place where the old rule was "an untyped function boundary loses the type"; each
kept an equivalent or stricter probe.

| test(s) | old expectation | now |
|---|---|---|
| `mat-sp-5`, `mat-atk-12`, `mat-bd-5` | untyped `identity`/read-only wrapper rejects a typed array | accepted, contract kept; an erasing or wrongly-writing body is rejected |
| `mat-atk-8`, `mat-atk-9` | `identity(List[MutableArray])` / nested arrays rejected | accepted (kept element-wise); `list`/`any`/`mutarray`/`MutableArray[any]` sinks still rejected |
| `mat-atk-2` | rejected with the erasure message | still rejected, message now `call to f with x : MutableArray[str] is invalid: value of type int ...` |
| `mat-atk-11` | callable value cannot launder the array | exact targets (native reader, exact identity) accepted; unknown targets (dynamic `pick`) still rejected |
| `mat-id-3` | `apply(create)` with a declared raw result is `mutarray` | rejected as an erasure when the target is exact and the result is declared raw; raw through an unknown target |
| `mat-syn-3`, `mat-fl-2`, `mat-cr-1` | result shown as declared `Fn`/`MutableArray[any]` | the narrower argument fact is used for the call result |
| `mat-id-4` | only `containers.tcl` names the container functions | unchanged (the new file avoids the names) |
| `mutarray-list-7` | empty accumulator gives `any` | `List[mutarray]` (accumulator relation recovered) |
| `callable-escape-{bug,apply-*,mixed,source-defined,cross-module}` (7) | "cannot be preserved" erasure diagnostic | the call is rejected by the instance (`argument for parameter "x" cannot be proven to satisfy int[Byte]`); `apply(take_byte, 7)` still rejected (no value facts); new arity test |
| `fn-escape-declared-param-erased`, `fn-escape-typed-list` | erasure diagnostic | rejected by the instance through the `Fn` contract |
| `char-typed-callable-escape-rejected`, `char-container-erasure-ordinary` | rejected | accepted for a fitting argument; the wrong argument and a declared broad result still rejected |
| `applied-type-erasure-vs-consume`, `applied-type-callable-escape-still-rejected` | rejected | accepted for a fitting argument; a declared broad result / wrong argument rejected |
| `set-*` (3) | same as `applied-*` for `ImmutableSet` | same |
| `ic-trusted-bearing` | trusted-contract callable rejected through an untyped helper | fitting callable accepted, unfitting one rejected at the call |
| `hir-specialize-corpus-1`, `native-spec-14` | generic blockers 6/29 | 5/28 for `ai_text_clean`/`csv_chunked` |
| `native-refinement-propagation-native-body-without-override-loses-it` | `any` | `str` (never `str[UriQueryValue]`) |
| `examples/hir/01-scopes.hir`, `04-refinement.hir` | stated facts `list` / `any` | regenerated: `List[int]`; `describe(41) : int`, `describe("hi") : str` |

## Benchmark parity

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 bench/bench.tcl -runs 1` (native backend built):
exit status 0 -- `bench.tcl` exits 1 if the Botlish backends disagree on any
program's result, and none did, on all 8 canonical benchmarks (fib, lex-strategy,
loop-count, refined-checks, source-checks, sum-refined, test-selection,
uri-steady) across Tcl interp, Tcl compile and Cranelift (`out/bench-runs1.txt`).
Timings are not compared: the generated code is byte-identical to the parent's, so
there is nothing to compare.

## Known limitations

* **Definition-level obligations are not discharged** by instances (by design):
  `total_valid`, `select_affected`, `esc_bytes` under the strict counterfactual.
* **No value monomorphization.** An instance is keyed by types; `apply(take_byte,
  7)` is rejected because `7` is an `int` inside the instance, not proven `Byte`
  (`callable-escape-apply-good-arg-still-rejected`). A future refinement could
  carry argument ranges; that is the value-monomorphization the milestone forbids.
* **More precision surfaces existing rules.** A call whose instance result is a
  bearing type now meets the audit in its consumers: `apply(create)` where
  `apply(f: Fn{...}) -> mutarray` declares a raw result is rejected as an erasure
  (`mat-id-3`), a `handle ... NotFound: 0` for a `str`-typed `find` is rejected
  (`si-hof-8`). Both are the existing rules applied to a more precise type.
* **Nested closures** get their captured types from the enclosing instance only
  through in-place typing; a separate instance of the closure uses the generic
  recorded environment (sound, less precise).
* **Compile time** grows with the number of instances (see above).
* **Forward-called functions with captures** need a second walk; three walks at most.
* **Budgets** (`maxPerBlock` 16, total 2000, depth 24) never triggered on the
  corpus; a declined call keeps generic typing and rejects bearing arguments
  exactly as before.
* Exact callables are keyed by code target and result; a `predicate` whose result
  revises changes the key (a distinct instance).
* `-strict 0`: an invalid instance is an ordinary TYPE diagnostic at the call and
  therefore an AOT blocker of the region containing the call, like every static
  TYPE diagnostic.

## Readiness for typed-builder source refactor

**Would the new machinery be sufficient to let one shared `geo_append` source serve
its three element types without explicit generic syntax, if the builder were
refactored from raw allocation to `mutarray::create` / `MutableArray[T]`?**

*Yes for the value/storage relation, not for the pair.* A scratch control
(`tools/probes-builder.txt`, nothing merged, the frozen source untouched):

```
fn tb_append(storage, length, value):
    if length == mutable_array_capacity(storage):
        grown = mutarray::create(length * 2 + 1, value)
        mutable_array_copy(grown, 0, storage, 0, length)
        mutable_array_set(grown, length, value)
        grown
    else:
        mutable_array_set(storage, length, value)
        storage
```
one untyped source function used with `str`, `List[str]` and `mutarray` element
types gives three instances `tb_append<MutableArray[str], int, str>`,
`<MutableArray[List[str]], int, List[str]>`, `<MutableArray[mutarray], int,
mutarray>`, each returning its own `MutableArray[T]` (the join of `grown` and
`storage` stays typed because both branches have the same type); a wrong value
(`tb_append(MutableArray[str], 1, 5)`) is rejected at the call; a typed loop
`tb_fill` with the same shape also works; and `freeze` gives `List[T]`. What still
blocks the real `geo_append`: it returns `[grown, length + 1]`, a positional pair,
and a typed array inside a positional pair is rejected as an erasure (the control
`tb_pair` shows it). So the refactor needs (a) typed storage created with `create`,
(b) storage and length threaded as two values instead of a pair (or the later
struct work), and then one shared untyped `geo_append` source is sufficient: no
per-element-type copy, no generic syntax. This is the answer to the next
milestone, not something performed here.

## Incremental compilation implications

The conceptual rule holds and would carry over:

```
body available + exact call     -> opportunistic instance
body unavailable / open call    -> declared/source contract
```
Instances are ephemeral (a side table, not cloned HIR) and a function of the body
plus the call's argument types plus its recorded creation environment, so a
separately compiled callee whose *body is not available* simply keeps its source
contract; a callee whose body is available gets instances from exact calls only.
Adding a caller can add an instance and never invalidates another (no closed-world
assumption); changing a body invalidates only that block's instances and their
readers (the `deps` graph). Instances are never a signature: which instances are
analyzed can change with the call sites without changing any API. Nothing is
implemented here.

## Answers to the required questions

### Architecture

1. **What is a semantic instance?** A compiler-internal analysis of one source
   function's ordinary body under one concrete semantic entry environment.
2. **How is its key represented?** `{BLOCK ENTRY-TYPES}` (the block ExprId and one
   full semantic type per parameter), in `hir semantic keys`.
3. **Which type distinctions survive?** All of them: `MutableArray[T]`, `List[T]`,
   `ImmutableSet[T]`, `Byte`/named refinements, structural `Fn`, exact callables.
4. **Exact scalar values?** No.
5. **Exact callable identity when known?** Yes, kept as `{block E ...}`.
6. **Varying capture types?** The recorded creation environment of the block from
   its generic analysis (sound for every closure of the block); closures created in
   an instance's walk are typed in place with the instance's environment. Not in
   the key.
7. **Is the original HIR cloned?** No. A walk uses a scratch value copy of the HIR
   (dict copy-on-write) that is dropped; what is kept per instance is a snapshot of
   the volatile per-expression facts of its region (side table).
8. **Where are entry/result facts stored?** `hir semantic`: `instances` (args,
   result, snapshot, passes, ...), `keys`, `calls` ((context, call) -> instance),
   `envs`, census counters. No HIR field changes.
9. **How does recursion reuse an in-progress instance?** The request finds the key,
   returns the current result (initially `never`), records the reader as dependent
   and marks it as assuming; growth re-walks / requeues dependents.
10. **Why does the analysis terminate?** The type lattice is finite (bounded
    aggregate nesting); results only grow with a pass limit; instances are memoized
    by canonical key with per-block, total and depth budgets.

### Separation

11. **Is the key the same as `KeyType`?** No.
12. **Did `KeyType` change?** No.
13. **Can two semantic instances share one codegen instance?** Yes (158 do).
14. **Can a semantic instance disappear through inlining?** Yes (7 do; 11 have no
    used call site).
15. **Does every semantic instance emit code?** No: none emits code of its own.
16. **Semantic vs codegen instances in the canonical corpus?** 252 vs 245 (234
    emitted functions); no codegen instance is caused by a semantic one.

### Soundness

17. **Can `identity(MutableArray[str])` preserve the element contract?** Yes.
18. **Can an untyped writer accepting the same array write an int into it?** No:
    `smash`/`writer(m, 5)` are rejected at the call.
19. **How does the audit distinguish the two bodies?** It walks each instance body
    on that instance's own types: `identity` returns `x : MutableArray[str]` (a
    `Preserves` match), `smash` stores an `int` into `MutableArray[str]`
    (`VerifyStore`), an erasing body fails `Preserves` at its erasing position.
20. **Can semantic instancing bypass an existing non-erasure rule?** No: the same
    rules run on every instance body, and a declined call keeps the old context.
21. **Can a failed precise instance silently fall back to erased generic
    execution?** No: an invalid instance is a diagnostic at the call. Only budgets
    fall back, and a fallback never accepts a bearing argument.

### Genericity

22. `identity(int)` infers `int`. 23. `identity(str)` infers `str`.
24. `first(List[str])` infers `str`. 25. `first(List[int])` infers `int`.
26. **Can one source `first` have both instances simultaneously?** Yes (`si-list-2`).
27. **Does that require two emitted machine functions?** No, not necessarily (and in
    the corpus none is caused).
28. **Can `list::find(List[str], predicate)` return `str` without a source type
    variable?** Yes. 29. The int case returns `int`.
30. **What blocks any case that still fails?** Definition-level obligations
    (`total_valid`, `select_affected`, `esc_bytes`), positional pairs and raw
    storage (the builder), and callables of unknown target.

### Real corpus

31. **Which of the seven generic-relationship strict failures disappear?** Three
    disappear (`list::find` erasure in `source-checks`, the `chars_of`/`classifier`
    relation, the `ht_fold` callback), one is re-attributed to the call
    (`test-selection` `list::find`), and the rest are definition-level or struct
    (see above).
32. **Does `chars_of` still need its result annotation?** No.
33. **Do the CSV accumulator results remain `any`?** They are `list` (were `any`) and
    stay broad because the values come from a positional pair.
34. **Does `ht_fold` improve?** Yes: `any` -> `List[list]`; its strict site is gone.
35. **Do `list::find` predicate/result sites improve?** Yes: `str`, `int`,
    `MutableArray[str]` results; the `source-checks` site disappears; the
    `test-selection` one is re-attributed.
36. **Do `total_valid`, `select_affected`, `esc_bytes` still need annotations?**
    Yes (definition-level).
37. **What happens to the nine builder-flow sites?** Unchanged; the value type now
    reaches inside `geo_append` and is lost at the pair and the raw freeze.
38. **Does `geo_append` acquire multiple semantic value-type instances?** Yes
    (`any`, `mutarray`).
39. **Is the remaining blocker raw storage, the positional pair, or something else?**
    Both raw storage and the positional pair (in that order along the chain); the
    generic value relation is no longer the blocker.

### Codegen

40. **How many semantic instances are analysis-only?** All 252.
41. **How many share codegen?** 158 (in 66 codegen instances).
42. **How many are inlined away?** 7 reach a not-emitted codegen instance; 11 have no
    used call site.
43. **How many genuinely cause additional emitted code?** 0.
44. **Did canonical native code size change?** No (scalar assembly byte-identical).
45. **Did any guard disappear solely because a semantic call result became more
    precise?** In the guard analysis of two programs (one generic blocker each),
    not in emitted code.

## Files

New: `hir/semantic.tcl`, `tests/semantic-instances.test`,
`OPPORTUNISTIC-SEMANTIC-INSTANCES.md`, `audit/opportunistic-semantic-instances/`.
Modified: `hir/types.tcl` (walk rounds, creation environment, the call hook),
`hir/range.tcl` (`verifyBlocks`, checked-contract rule for a bearing argument with
an instance), `hir/callables.tcl` (`verifyBlocks`, instance argument contexts),
`hir/specialize.tcl` (never less precise than the semantic result), `hir/hir.tcl`
(load, verify step, data-model note), tests whose expectations pinned the old
boundary (listed under "Full regression"), `examples/hir/01-scopes.hir` and
`04-refinement.hir` (stated facts regenerated), `README.md` (one row).
