# Closed-caller theorem and exact callable identity

Proof-preservation and specialization repair. No new general optimizer, no
`.bot` change, no change to a function's contract or to what any program means.
The compiler already knew which callable it was passing; this milestone stops
throwing that away before code generation, and makes one proof of "no unknown
callers" serve every analysis that needs it.

Measurements: [`audit/exact-callable/`](audit/exact-callable/README.md). Every
dynamic count is callgrind instructions per steady-state run (Ir/run) on **one**
runtime binary (the audit build of the frozen runtime; `native/src` is
unchanged by this milestone), so before and after differ only in the NIR the
compiler emits. Before = the parent fence `64af2fe`, after = this tree.

## Outcome

| | before | after |
|---|---:|---:|
| `refined-checks` Ir/run | 8,190,753 | **6,776,096** (−17.3%) |
| `refined-checks` TLD scan, Ir/char | 1,307 | **371** (R2: 376) |
| `refined-checks` local-part scan, Ir/char | 831 | 790 |
| `refined-checks` `rt_call_value` per run | 8,000 | **0** |
| `refined-checks` one-character Strings per run | 8,000 | 6,800 (all local part) |
| `callvalue` sites, 8 canonical programs | 8 | **2** (both genuinely dynamic) |
| `test-selection` Ir/run | 35,913 | 33,274 (−7.3%) |
| `lex-strategy` / `source-checks` / `uri-steady` Ir/run | 314,302 / 73,594 / 42,789,709 | 312,757 / 73,385 / 42,738,290 |
| JIT machine code, 17-program corpus | 102,412 B | 102,074 B (−338 B, −0.33%) |

1. **One closedness proof.** `hir::specialize::InstanceClosed` is the single
   authoritative answer. `analyze` computes it once at the stable point and
   stores it (`closed`); `hir::range`, `hir::construction`, the closed-caller
   pass and the audit output all read it. `hir::range::OpenInstances` no longer
   has a coarser test of its own (it was "is a Block value of this block
   materialized", which calls every capturing closure open).
2. **Exact callable identity survives codegen projection.** `KeyType` keeps
   `{block E ARITY any ?CONTRACT?}` and `{native NAME}` for a callable
   argument. A call through the parameter is a direct call (`call`/`callenv`
   for a Botlish block, the native operation itself for a native). The instance
   view carries the resolved call target, so StringRegion, blockescape,
   tiny-leaf inlining, range and error analysis see an ordinary exact call.
3. **Botlish blocks and natives are one concept for specialization**: one key
   shape, one budget, one join, one overlay mechanism. They differ only in the
   final lowering.
4. **blockescape generalized from one instance per closure to several.** It was
   a precondition: a closure with two exact targets has two codegen instances,
   and the old analysis declined any literal with more than one.
5. **A target budget** (`exactLimit`, default 4, `-exact-callable-limit`) bounds
   the instances; beyond it a target shares the old kind-only key and the
   callable-value ABI.
6. **`-exact-callable-opt 0`** (env `BOTLISH_NATIVE_EXACT_CALLABLE_OPT=0`)
   restores the kind-only keys, the differential baseline. It reproduces the
   previous compiler's NIR byte for byte on seven of the eight canonical
   programs; the eighth, `uri-steady`, differs only by the range-openness
   unification (which has no flag: it removes a stale proxy rather than adding
   a behavior), 25 NIR lines in `repeat_uri`.

**Verification** (details in [Full regression](#full-regression)): `tests/all.tcl`
passes 3,626 / 3,626 on the interpreter backend and 3,622 passed + 4 skipped
(`coreScoping`, as before) on the Tcl compile backend, and the same under
`BOTLISH_NATIVE_GC_STRESS=1`; the Rust crate's 56 + 22 tests pass (`native/src` is
unchanged); native coverage matches the previous tree apart from the tests added
(the one pre-existing failure, `refined-5`, and the 49 unsupported tests are
identical); the 19-row corpus agrees on every backend with unchanged code
statistics.

## Motivation

[MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md](MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md)
traced the +136.8% `refined-checks` regression (R2 3.46M → 8.20M Ir/run) to one
shared loss point. The semantic layer proves
`scan_while<int, block(e239)/1 -> bool>` and `scan_while<int, native
is_tcl_alpha>`; codegen projection collapsed both to `scan_while<generic>`:

* `hir::specialize` forced a value-capturing closure onto its generic key;
* `KeyType` reduced `block E` to `block` and `native N` to `native`, and the
  closed-caller theorem joined `block ⊔ native = any`.

The consequence: a `callvalue` per character, a generic-entry trampoline and a
`guard str` in `local_char?`, and a one-character String per character because
the TLD consumer (`is_tcl_alpha`, a StringRegion consumer) was invisible behind
the dispatch. The scratch counterfactual measured the ceiling at 6,794,452
Ir/run. The same erasure turned every exact callable argument in the corpus
into `callvalue`: 6 of the 8 canonical sites had an exact callable in their
semantic instance.

## Bottom-up investigation findings (what this milestone acted on)

| finding | action |
|---|---|
| `KeyType` erased identity on the premise "a call through either is the same indirect callvalue", true only because the key erased it | identity kept in the key; the call is direct |
| `Handle` forced a value-capturing closure onto `GenericKey` | relaxed for exactly the callable positions (below) |
| `ClosedCallerFacts` joined `KeyType`s: `block ⊔ native = any` | `JoinKey`: identity survives when every caller agrees; instances are split per target before any join |
| `hir::range::OpenInstances` ignored `InstanceClosed`: every capturing closure read "open", every entry Range `[-∞, +∞]` | range reads the authoritative proof |
| the instance view had no way to say "this call through a parameter has a known target" | overlay entries carry the resolved target (new; see [Overlay target](#overlay-target)) |

## Previous closed-caller theorem

M7.c ([M7C-CLOSED-CLOSURE-ENTRY-FACTS.md](M7C-CLOSED-CLOSURE-ENTRY-FACTS.md))
added `InstanceClosed` and `ClosedCallerFacts`: for a *closed generic*
instance, the join of every exact caller's `KeyType` per parameter seeds the
instance's entry kinds, through the same seeding mechanism M1/M7.b use. It ran
in `CloseCallers`, after the ordinary fixpoint, and forbade creating instances
there (M7.c.1, [M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md](M7C1-CLOSECALLERS-CONVERGENCE-FENCE.md)).
It restored *kinds* (`int`) for the `Int` parameters of `scan_while`, `char_at`,
`tld?`, `domain?`. It never restored callable identity (the join erased it) or
Ranges (range had its own, coarser test).

## Authoritative InstanceClosed definition

`InstanceClosed(I)` means: **every invocation of codegen instance I that can
happen at run time is accounted for in the analysis's own call graph**, so a
fact derived from the callers the compiler knows (an entry-kind theorem, an
entry Range, an exact-callable key) holds for every call that can occur.

| instance | closed iff | why sound |
|---|---|---|
| the program | always | no callers |
| a **specialized** instance (some key position is not `any`: a kind, an exact callable, an aggregate shape) | always | only `Handle → Instance` selects a specific key, i.e. only a direct call. A Block value's dynamic dispatch always enters the block's *generic* instance |
| a **generic** instance of a static (environment-free) block | its Block value is never materialized (`hir::aot::materializedBlocks`, over every used instance) | the Block value is the only route to an unknown caller |
| a **generic** instance of a value-capturing closure | `hir::blockescape` proves every reference to the binding is an exact, arity-matching call (`RefsAsCalls`, a greatest fixpoint) and `wants` this instance | the closure is never a first-class value. (aot's `materializedBlocks` counts *every* bind of a capturing closure as materializing, so it cannot decide this branch) |

What it relies on: the used set, `calls`, `edges` and `values`, all frozen
after the ordinary fixpoint; and blockescape's own analysis of that graph.

Which analysis computes it: `InstanceClosed` itself, over a finished analysis,
through `ClosedInstances`; the result is stored in the analysis dict under
`closed` (`InstanceId → 1`, specialized instances and the program included).
`hir::specialize::closed` reads it.

When it is stable: after `Fixpoint`. `CloseCallers` writes only overlays and
results, never `calls`/`edges`/`values`/`used`, and blockescape reads only
structure and those maps, so the answer is the same whether or not the
closed-caller pass ran (`exact-callable-closed-stable-across-closecallers`
checks this on six corpus programs). `CloseCallers` computes its blockescape
analysis at that frozen graph, and `analyze` reuses it for the stored result
(with the closed-caller pass off, it is computed afresh: the same function over
the same graph).

Which cases it can prove: everything in the table. Which remain open: a
generic instance whose Block value is materialized (a callable that escapes:
stored, returned, put in a List, passed to code that is not an exact call); a
closure blockescape declines (a reference that is not a call, or none at all);
and the generic *Block-value entry* of a closure blockescape does de-closure
through its specialized instances: it is never entered at run time but is not
itself proven (it stays open, and, being in the call graph, still contributes
its own calls to range facts: see [Known limitations](#known-limitations)).

Exact identity and closedness are different questions. An exact callable
argument says which code a parameter holds *at one call*; that is a fact about
the argument expression's type, and it keys a **specialized** instance, closed
by construction. A callable that is exact at one call and also escapes does not
make anything else closed (`exact-callable-escaping-not-closed`).

### Consumer audit (spec #36)

| subsystem | what it uses |
|---|---|
| `hir::specialize` (`CloseCallers`, `ClosedSet`) | the authoritative proof (computed at its own snapshot of the frozen graph) |
| `hir::range` (`OpenInstances`) | **now the authoritative proof** (was a coarser materialization proxy) |
| `hir::construction` (plan results) | **now the stored `closed` result** (it called `InstanceClosed` with its own blockescape; same value) |
| `hir::blockescape` | the *source* of the closure branch, not a consumer |
| `hir::escape`, `hir::stringregion`, `hir::traversal` | a deliberately **different property**: they restrict to *non-generic* instances because a generic instance has the fixed generic-entry ABI (no hidden parameters or companion fields), not because of caller closure |
| `hir::aot` (readiness, guards) | a different property: representation blockers, not callers |
| `hir::callables` | a static legality gate (no erasure of a typed callable), not a per-instance oracle |
| `native/lower.tcl` | `envless` (a static property) and the analyses above; no closedness of its own |

No stale proxy remains for the question "may this instance have unknown
callers". `hir::specialize::closedAudit` (audit only) prints, per used
instance, the closed answer, the proof branch, the caller count, the exact
targets and range's openness, and the tools count disagreements: none.

## Analysis ordering

The actual pipeline (`native::lowered`, `native/lower.tcl`):

```
native::prepareHir          attach native bodies; re-check -> semantic instances
hir::specialize::analyze
    Instance/Handle         instance creation; exact callable keys enter HERE
    Fixpoint                calls, edges, values, results converge
    CloseCallers            blockescape; closed set; closed-caller theorems (Reanalyze:
                            never calls Instance)
    ClosedInstances         the authoritative `closed` result, stored in the analysis
hir::range::analyze         reads `closed` (OpenInstances)
hir::escape, hir::stringregion, hir::blockescape, hir::traversal
hir::construction           reads `closed`
lowering                    direct calls, region consumers, internal variants
```

Nothing asks for closedness before it is stable: `OpenInstances` is only
reachable through an analysis that has `closed`; for a hand-built analysis
without it, it derives it with the same function.

## Exact callable identity model

The semantic type of a callable argument is `{block E ARITY RESULT ?CONTRACT?}`
or `{native NAME}` (`hir/types.tcl`). Two exact callables of different code are
different types; `lub` joins them to a structural `Fn` contract (identity
forgotten) only where they genuinely merge (an `if` branch, a List literal).
The specializer's **key** is a projection of that type for code generation. The
projection is representation-relevant exactly for callables, because the
identity decides whether the call through the parameter is indirect or direct.
It is not true of exact scalar values, exact List elements or contracts, and
none of those enter a key.

### Codegen key representation

| semantic argument type | codegen key |
|---|---|
| `{block E ARITY R}` / `{block E ARITY R CONTRACT}` | `{block E ARITY any}` / `{block E ARITY any CONTRACT}` |
| `{native NAME}` | `{native NAME}` |
| structural `Fn{...}` | `any` (unchanged: a Fn value has no one runtime kind) |
| a callable inside a List/struct/set | `block` / `native` (kind only: nothing proves which element a read returns) |

* **Stable, hashable, comparable**: a Tcl list; the instance cache keys on it.
* **Binding identity**: `E` is a block ExprId (a declaration), never a printed
  name; natives are keyed by registry name, never by signature. Two functions
  of the same name in two modules are two targets
  (`exact-callable-same-name-different-modules`); two natives with the same
  `str -> bool` type are two targets (`exact-callable-natives-same-signature`).
* **Result slot normalized to `any`**: it is a property of the creating walk
  and grows during the fixpoint; keying on it would make keys unstable. The
  target's own instance carries the result.
* **The contract** (5th element) is a function of `E` alone
  (`hir::types::blockType`), so it adds no dimension: two different contracts
  never share a block.
* **Display**: `block(e239)`, `native(is_tcl_alpha)` in instance labels, NIR
  `instance=` strings and `closedAudit` (`hir::specialize::ShowKey`). The
  internal id is an audit handle, not a language feature.
* **Captured values are not in the key.** The closure *value* is still an
  ordinary argument; the key names the code target. `callenv` receives the
  environment from the parameter register. This is why exact identity does not
  mean envless (spec #42, #43).

## KeyType changes

`KeyType` is split in two: `KeyType` (exact for a top-level callable) and
`ElementKeyType` (the old kind-only projection, used inside aggregates).
`CoarseCallable` maps an exact key to its kind. `Handle` coarsens when
`-exact-callable-opt 0`; `Instance` coarsens when the budget is spent.

### Native / Botlish unification and where they differ

| property | exact Botlish block | exact native function |
|---|---|---|
| identity survives `KeyType` | yes: `{block E ARITY any ?CONTRACT?}` | yes: `{native NAME}` |
| creates a target-specific instance | yes (one per `E`, within the budget) | yes (one per `NAME`, within the budget) |
| direct invocation | `call ID` (envless target) / `callenv ID CLOSURE` (target with an environment) | the native operation itself (`op strtclalnum`, `op strregiontclalpha` over a region, ...) |
| generic fallback available | yes: kind-only `block` key and `callvalue` | yes: kind-only `native` key and `callvalue` |
| callable signature known | exact `{block E arity result contract}` | native registry metadata (`arity`, `-result-type`) |
| error/result facts usable | callee instance result and `calleeErrors` of the target | native `-result-type`, `-result-shape`, `known` type tests, declared param types |

The first five rows are symmetric except for the concrete direct lowering. The
only intentional differences: the native is identified by registry name (its
symbol id belongs to one HIR copy, so the overlay carries the name and `view`
resolves the symbol), a native needs no environment, and an exact Botlish
closure keeps its environment as an argument. Neither is more exact than the
other merely for being builtin (spec #44, #45); `exact-callable-mixed-*` pins
that the same helper called with a block and a native gets two exact instances.

## ClosedCallerFacts changes

* A caller's per-position contribution is its `KeyType`, now exact for a
  callable.
* **`JoinKey`** joins two keys: equal keys stay equal (the exact identity
  survives when every caller agrees); two different callables (exact or kind)
  join to their common kind (`block`/`native`) or `any`, exactly as the kind
  keys joined before. They never join to a structural contract, which would add
  a fact the old keys never carried.
* The first fix is not in the join: **callers that pass different targets no
  longer share an instance to be joined**. `Handle` selects instances per
  target at the normal instance-creation stage, so the join only ever sees one
  target (or, after a budget fallback, the kinds).
* `ClosedSet` now also includes a *specialized* instance of a value-capturing
  closure whose key still has an `any` position, so `scan_while<any,
  native(is_tcl_alpha)>`'s `start` is still refined to `int` by the theorem
  (it is a closed instance by the table above). A specialized instance of a
  static block with an `any` position is left alone: its callers genuinely pass
  nothing more precise, and re-inferring it through `FrozenHandle` (which lacks
  `Handle`'s semantic-result refinement) would only lose precision.

## Value-capturing closure handling

**What the generic-key rule protected.** Not correctness. A closure's captured
values reach an instance through the closure value and the capture seeds,
never through the key; a specialized instance is entered only by the exact
calls that selected it; a materialized Block keeps its own generic entry. The
rule bounded code growth, and, as a side effect, made *one* instance per
closure literal, which is what `hir::blockescape`'s de-closure proof
(`SingleInstance`) required. Closures whose captures are all proven `Int`
(`sum-refined`'s `step`) were already exempt.

**What changed.** For a closure with aggregate or managed captures, `Handle`
still sends every parameter to `any` **except an exact callable argument**,
which keeps its identity (bounded by `exactLimit`). The other positions are
refined by the closed-caller theorem as before. The identity is
representation-relevant for any closure; nothing else about the arguments
changed. `-call-facts-opt 0` still forces the whole key generic (that flag is
the differential baseline for closure specialization).

**Which closures specialize now**: any closure called with an exact callable,
in that position. **Which captures genuinely need generic representation**:
none for correctness; aggregate captures stay in the capture *seeds* (joined
across creations), unchanged.

**Proof that it is safe**: (1) a specialized instance is closed by the table
above; (2) blockescape's de-closure is extended to several instances (next
section), so no closure gets heap-allocated that was not before, except in the
one boundary case of limitation 8;
(3) GC: the exact closure value and its captures are ordinary registers/slots
of the caller and callee; `exact-callable-gc-*` and the executable parity tests
run String, List, MutableArray and struct captures under GC stress through an
exact call (spec #94).

## Blockescape interaction

`hir::blockescape` is the existing proof that a locally bound closure is only
ever called, so its captures can be passed as ordinary values to a
capture-explicit internal variant instead of building a heap closure. It
required **exactly one used instance** per literal (`SingleInstance`) and
declined a literal polymorphic across several. With exact keys a literal has
one instance per target, so `scan_while` would have lost its de-closure
(a `rt_closure_new` per `emailish?` call, the exact opposite of the repair).

The generalization (`hir/blockescape.tcl`, `native/lower.tcl`):

* `RelevantInstances`: the literal's non-generic used instances if it has any,
  else its single generic instance.
* `RefsAsCalls` returns the **set** of call targets; every reference (self,
  external, sibling) must be an exact call whose target is one of the
  literal's relevant instances, examined in **every** used instance of the
  literal and of each sibling capturer (each has its own `calls`).
* `wants` holds every relevant instance; the one flattened capture list a
  literal has is shared.
* Lowering: `virtual` answers only "is this binding de-closured"; each call
  site names **its own** callee instance (`fn targets $e`), which blockescape
  guarantees is wanted (a violation is a `NATIVE BUG`, never a silent wrong
  call).

Why sound: a call site that resolves to a non-relevant instance makes the
binding ineligible; the canonical (closure-taking) function stays purely
additive. The only new case is that a literal's instances differ by key, and
their capture lists agree because the flattened list depends on the literal and
the candidate graph only. After the change `refined-checks`' `scan_while`
(two exact instances), `tld?` and `domain?` are all internal variants and the
program builds no closure (`blockescape-region-companion-refined-checks-3`).

## Specialization budget

`exactLimit` (default **4**): at most that many live specialized instances of
one function keyed by an exact callable. A further distinct target takes the
kind-only key. Counting is by live instances (as the existing per-block `limit`
of 8 does: instances an earlier fixpoint pass used and no pass uses any more do
not count), so which target meets the budget first depends on discovery order,
which is deterministic. Settings: `hir::specialize::exactLimit`,
`-exact-callable-limit N` on `analyze` and on native lowering, and
`BOTLISH_NATIVE_EXACT_CALLABLE_LIMIT`. The per-block `limit` (8, shared with
kind keys) is the hard ceiling, and `instanceLimit` (1000) the global one.

Measured (`audit/exact-callable/` budget probe: 16 distinct targets into one
two-call HOF, machine code via `native::codeSize`):

| exactLimit | apply_loop instances | emitted functions | machine code | lowering | `callvalue` sites |
|---:|---:|---:|---:|---:|---:|
| 0 (all kind-only) | 1 | 18 | 5,960 B | 52 ms | 2 |
| 1 | 2 | 19 | 6,500 B | 61 ms | 2 |
| 2 | 3 | 20 | 7,040 B | 66 ms | 2 |
| 4 (default) | 5 | 22 | 8,120 B | 79 ms | 2 |
| 8 | 9 | 26 | 10,280 B | 104 ms | 2 |

Every extra exact instance costs about 540 bytes here (a small HOF body plus
one target function) and about 6 ms of lowering (median of five; the
bytes are deterministic). The `callvalue` count is the
shared fallback instance's two call sites. Without a fallback the count is 0
(the N ≤ limit rows of `out/budget.txt`). The corpus's most-targeted function has 2
targets. 4 is conservative: half of the per-block ceiling, so exact keys cannot
crowd out the kind specializations a function also needs.

**Fallback correctness (spec #51).** The shared instance is the pre-milestone
instance: the caller passes the callable as an ordinary argument either way, and
the shared body calls it through `callvalue`. `exact-callable-budget-*` check
the values on every backend and against the unbudgeted compile.

## Fixed-point / convergence argument

* Exact keys are created in `Handle` → `Instance`, during `Fixpoint`, never
  later. `CloseCallers` re-infers through `FrozenHandle`, which resolves a call
  only to its pre-recorded target and never calls `Instance`; `ClosedCallerFacts`
  only *reads* callers and `Reanalyze` only narrows `any` positions. So no
  instance is created after the fixpoint (spec #14, #39):
  `exact-callable-no-instance-after-fixpoint` compares `keys` and `used` with
  the pass off and on.
* The key space is finite: a key is a tuple over kinds, block ExprIds (finitely
  many), native names (finitely many) and the bounded aggregate shapes of
  `hir/types.tcl`; the lattice an instance moves in is `exact(E) ⊏ kind ⊏ any`
  (self-tail widening and `JoinKey` only go up it).
* Budgets bound the width: the effective exact ceiling is `min(exactLimit,
  limit)` (live specialized instances per block), `instanceLimit` bounds the
  whole analysis, and the pre-existing per-instance `passLimit` guards
  non-monotone corners.
* **Recursion** (spec #40): a helper that forwards its predicate unchanged
  passes an argument whose type *is* its own key type, so the call targets the
  same instance (a self tail call stays a loop; non-tail recursion hits the
  instance cache). `exact-callable-recursive-hof`, `…non-tail-recursive-hof`.
  A recursion that wraps its predicate in a new closure each level creates a
  closure of the same *code target* every level (the key is the block, not the
  closure), so it terminates (`exact-callable-recursion-new-closure-each-level`).
* **Cycles** (spec #41): a call cycle whose edges agree keeps the exact key; if
  targets differ across a cycle they get one instance per target until the
  budget, then the kind key, which is the old behavior. No oscillation: a key
  once chosen for a (callee, call-site types) pair is the same on the next pass.
  `sr-recursion-higher-order-cycle` is a mutual-recursion-through-function-values
  program that now specializes (its static struct constructions fall from 4 to 2).

## Overlay target

The one mechanism the spec did not name but that the repair needs. A call
through a parameter has `target ""` in the semantic HIR: the parameter's type is
`any`. `hir::types::Call` on the instance's *scratch* HIR (the parameter now
seeded with an exact key type) does compute `{block E}` / `{native SYM}`, but
`Analyze` copied only `type`, `known` and `reachable` into the instance's
overlay, and native lowering reads `target` from the view. The overlay entry is
now `{TYPE KNOWN REACHABLE ?TARGET?}`; `TARGET` is recorded only when the
semantic node's target is empty and the instance's is not (a call's semantic
target is never changed, only added), as `{block E}` or `{native NAME}`. `view`
applies it (a native's name is resolved to a symbol in that view's HIR).
Consequently every analysis that consumes a view sees the call as exact: this is
what makes StringRegion, blockescape, tiny-leaf, range and the AOT guard counts
react with no hook of their own (spec #25).

## Direct Botlish callable lowering

`Call`'s existing block-target branch: an envless target needs no code for the
callee (`skipCallee`), and a target with an environment is `callenv ID CLOSURE`
with the closure value taken from the parameter register. Both go to the exact
instance the specializer chose (`fn targets $e`), through the ordinary exact-call
machinery (tiny-leaf inlining, region consumers, plan/field transport, result
Range constants). `refined-checks`, `scan_while<any, block(e239)>`:

```
%7 = call 11 %4 %3          ; char_at<generic>, materializing (the local part)
%8 = call 12 %7             ; local_char?<str>   (was: %8 = callvalue %1 %7)
```

(`local_char?<str>` has no `guard str`; its generic entry trampoline is never
entered.) The completion semantics are the ordinary direct call's: a normal
return and every declared error propagate exactly as for any exact call; what
disappears is the `callvalue` completion machinery that existed only for
unknown dispatch, and the `guardbool` after it (the callee's result is a known
`bool`): `lex-strategy`, `source-checks` and `test-selection` lose both.

## Direct native callable lowering

The native branch: `NativeCall` over the registry symbol the overlay resolved,
including raw-eligible arithmetic and the StringRegion ops
(`TryStringRegionOp`). `refined-checks`, `scan_while<any, native(is_tcl_alpha)>`:

```
%7 %8 %9 = callmulti 10 %4 %3       ; char_at, region companion: no String built
%10 = op strregiontclalpha %7 %8 %9 ; was: %7 = call 11 (rt_substr); %8 = callvalue
```

`lex-strategy`'s `list::all?<List[str], native(is_tcl_alnum)>`:
`%9 = callvalue %1 %8; guardbool %9` → `%9 = op strtclalnum %8`.

## Generic fallback

Unchanged and still required: `callvalue`, the generic entry, the generic
callable ABI. `exact-callable-dynamic-*` check a predicate chosen by `if`
(`count_while<any, str>`, one `callvalue`), a callable read from a List at a
non-constant index, and an exact callable that also escapes. The two remaining
canonical `callvalue` sites (below) are genuine.

## Range openness unification

**Before.** `hir::range::OpenInstances` marked a generic instance open iff
`hir::aot::materializedBlocks` listed its block: "some used instance's reachable
code materializes a Block value of it". That is the right test for a static
block and the identical test as `InstanceClosed`'s static branch. For a
value-capturing closure it is wrong: aot counts every bind of a capturing
closure as materializing, so every such instance read open even where blockescape
had proved the caller set closed, and no caller-derived entry Range was ever
propagated into it.

**Now.** `OpenInstances` = every used non-program instance not in the
authoritative `closed` set (a specialized instance is closed by construction,
so only generic instances can be open). No special case for `scan_while` or any
closure (spec #33).

The benchmark instances affected by the unification alone are the generic
closure instances blockescape de-closures: `char_at`, `tld?` and `domain?` in
`refined-checks`, and `repeat_uri` in `uri-steady` (a top-level function that
captures the program's `corpus`).

## Scanner range effects

Entry/read Ranges, `refined-checks` (`audit/exact-callable/out/ranges-*`; the
tool prints every instance of a function, dead generic entry included):

| binding | before | after |
|---|---|---|
| `scan_while.start`, local part | `[-∞, +∞]` (generic, open) | `[0, 0]` |
| `scan_while.start`, TLD | `[-∞, +∞]` | `[2, 4611686018427387903]` |
| `scan_while.i` (read) | `[-∞, 4611686018427387902]` | `[0, 4611686018427387902]` / `[2, …]` |
| `tld?.i` | `[-∞, +∞]` | `[2, 4611686018427387903]` |
| `domain?.start` | `[-∞, +∞]` | `[1, 4611686018427387903]` |
| `domain?.j` (read) | `[-∞, 4611686018427387902]` | `[1, 4611686018427387902]` |
| `char_at.i` | `[-∞, +∞]` | `[-∞, 4611686018427387902]` |

`char_at.i` gets only its upper bound: it is also called from the retained,
never-entered generic `scan_while` entry (whose `i` has no lower bound), and
the join includes that call (limitation 2 below). The intervals are the existing
caller propagation's, unchanged; no new range analysis.

**Which machine checks disappear.** Measured on the NIR (op counts per
function, before → after):

| function | tagged `i*` ops | raw `ri*` ops |
|---|---:|---:|
| `domain?<generic>` | 5 → 2 | 0 → 3 |
| `web::emailish?<str>` | 3 → 0 | 0 → 3 |
| `repeat_uri<generic>` (`uri-steady`) | 4 → 2 | 0 → 2 |
| `scan_while`, `tld?`, `char_at` | unchanged | unchanged |

Each tagged op that becomes raw drops the small-Int tag test, the Bool word or
the overflow check and its cold `rt_int_add`/`rt_int_cmp` path. `scan_while`'s
own compare stays tagged because its bound `n = length(v)` has no Range here
(the interval is insufficient), and `char_at`'s `i + 1` stays checked for the
reason above. Dynamic effect: `uri-steady` −51,419 Ir/run (−0.12%), the rest
inside the `refined-checks` figure. This is small, as the investigation
predicted (≤ ~2%).

## StringRegion downstream effects

StringRegion runs after specialization on the exact-call graph (its views carry
the overlay target), so nothing is stale: the TLD scan's `char_at` is a region
companion call feeding `strregiontclalpha`, with no `rt_substr`.
`exact-callable-stringregion-*` pin the effect with and without exact keys; the
`native-string-view` corpus test's String count for `café@例え.テスト` falls 8 → 5,
exactly the three characters of the TLD `テスト`.

## refined-checks before / after

Same runtime binary (callgrind, steady state, per run):

| | Ir/run | `rt_call_value` | `rt_substr` | generic-entry runs |
|---|---:|---:|---:|---:|
| R2 (`e7d53b6`, hand-specialized scanners) | 3,461,692 | 0 | 3 | 0 |
| before (`64af2fe`) | 8,190,753 | 8,000 | 8,003 | 6,800 |
| scratch counterfactual (exact targets) | 6,794,452 | 0 | 6,803 | 0 |
| **after** | **6,776,096** | **0** | **6,803** | **0** |

−1,414,657 Ir/run (−17.3%), at the counterfactual ceiling and 18,356 under it:
the range facts add a little the counterfactual did not have. The remaining gap
to R2 is the one-character String per local-part character.

Per scanned character: before / after / R2.

| path | before | after | R2 |
|---|---:|---:|---:|
| TLD (`is_tcl_alpha`), 1,200 chars/run | 1,307 | **371** | 376 |
| local part (`local_char?`), 6,800 chars/run | 831 | 790 | 319 |

`scan_while` inclusive Ir/run: 7,216,459 → 5,372,202 (local part) + 445,600 (TLD).

| | R2 scanner | before | after |
|---|---|---|---|
| dispatch | direct region consumers (inlined) | `callvalue` + `rt_call_value` + generic-entry trampoline | direct `call` (local part), direct native op (TLD) |
| StringRegion | region everywhere | opaque: `char_at` materializes | TLD: region (`callmulti`, `strregiontclalpha`); local part: still a String |
| guards | none | `guard str` in `local_char?` per call | none |
| materialization | 0 per char | 1 String per char | 1 String per local-part char |

## TLD path

`scan_while<any, native(is_tcl_alpha)>`: `callmulti` of `char_at`'s region
companion, then `strregiontclalpha`. 445,600 Ir over 1,200 characters = **371
Ir/char**: R2's level (376). No `rt_substr` on the path.

## local-part remaining materialization

`local_char?` = `is_tcl_alnum(c) or immutable_set_contains(set, c)`. The first
is a region consumer; the set membership is not, so `char_at` still builds a
String for every local-part character: **6,800 one-character Strings per run**
(52.9% of the remaining Ir). This is the separate missing consumer the
investigation named; this milestone does not touch it (spec #79). What did
change on this path: no dispatch (`rt_call_value`, 225 Ir/char), no trampoline
(7 Ir/char), no `guard str`, and `local_char?` itself 200.8 → 187.8 Ir/call.

## Canonical callvalue census

`callvalue` sites in the emitted NIR of the eight canonical programs
(`census-before.txt` / `census-after.txt`):

| program | function | before | after | classification |
|---|---|:---:|:---:|---|
| `refined-checks` | `scan_while` | 1 | 0 | exact (block + native), now direct |
| `test-selection` | `list::any?` | 1 | 0 | exact, `callenv` |
| `test-selection` | `list::none?` | 1 | 0 | exact, `callenv` |
| `test-selection` | `list::find` | 1 | 0 | exact, `callenv` |
| `lex-strategy` | `list::all?` | 1 | 0 | exact native, `strtclalnum` |
| `lex-strategy` | `classify` | 1 | 1 | **genuinely dynamic** (the callable is chosen at run time) |
| `source-checks` | `list::find` | 1 | 0 | exact, `callenv` |
| `source-checks` | `classify_leading` | 1 | 1 | **genuinely dynamic** (List-held checks) |
| total | | **8** | **2** | 6 exact sites repaired; 0 budget-fallback, 0 unsupported-exactness, 0 bugs |

The 17-program corpus has no other `callvalue` site.

### test-selection / lex-strategy / source-checks

| program | Ir/run before | after | function-level change |
|---|---:|---:|---|
| `test-selection` | 35,913 | 33,274 (−7.3%) | `list::any?`, `list::none?`, `list::find`, `affected?`, `select_affected`, `first_affected` now keyed by `block(e55)`/`block(e94)`; 3 `callvalue` + 3 `guardbool` become 3 `callenv`; machine code −168 B |
| `lex-strategy` | 314,302 | 312,757 (−0.5%) | `list::all?<List[str], native(is_tcl_alnum)>` has `strtclalnum`; −88 B |
| `source-checks` | 73,594 | 73,385 (−0.3%) | `list::find<List[str], block(e114)>` is `callenv`; the dynamic `classify_leading` site is preserved; −56 B |

These improve with **no source change**: `list::any?` and friends are generic
source; each call site has an exact target, so each gets exact code.

## Instance census

Per canonical program (`sem` = valid semantic instances after `native::prepareHir`,
unchanged by this milestone; `used` = codegen instances; `exact` = used instances
with an exact-callable key; `kind-callable` = used instances with a kind-only
`block`/`native` key, the old "generic callable" keying):

| program | sem | used before → after | emitted before → after | exact | kind-callable before → after | `callvalue` |
|---|---:|---:|---:|---:|---:|---:|
| fib | 1 | 2 → 2 | 2 → 2 | 0 | 0 → 0 | 0 → 0 |
| lex-strategy | 13 | 11 → 11 | 11 → 11 | 1 | 1 → 0 | 2 → 1 |
| loop-count | 2 | 3 → 3 | 3 → 3 | 0 | 0 → 0 | 0 → 0 |
| refined-checks | 19 | 26 → 29 | 24 → 26 | 2 | 0 → 0 | 1 → 0 |
| source-checks | 4 | 7 → 7 | 7 → 7 | 1 | 1 → 0 | 2 → 1 |
| sum-refined | 2 | 4 → 4 | 3 → 3 | 0 | 0 → 0 | 0 → 0 |
| test-selection | 12 | 12 → 12 | 12 → 12 | 6 | 6 → 0 | 3 → 0 |
| uri-steady | 19 | 19 → 19 | 17 → 17 | 0 | 0 → 0 | 0 → 0 |

The nine `examples/stdlib` programs are unchanged in every column. Corpus-wide
(17 programs): `used` 242 → 245, `emitted` 231 → 233, exact-keyed instances
0 → 10, kind-only callable instances 8 → 0, `callvalue` 8 → 2, closure
allocation sites 5 → 5, semantic instances 295 → 295.

### Specialization growth

Only one source function gains codegen instances. Everything else is the same
count under a different (exact) key.

| source function | instances before → after (emitted) | distinct targets | machine code |
|---|---|---|---|
| `scan_while` (`refined-checks`) | 1 → 2 | `block(e239)` (`local_char?`), `native(is_tcl_alpha)` | 496 B → 440 + 456 = 896 B |
| `list::any?`, `list::none?`, `list::find`, `list::all?` | 1 → 1 each | 1 each | key change only |

The `used` count grows by two more for `refined-checks`: the generic `scan_while`
entry and `local_char?`'s generic Block-value entry stay in the used set (a Block
value is passed as an argument) but are not emitted for `scan_while` (de-closured)
and never entered for `local_char?`.

### Sharing economics (spec #49)

`scan_while<generic>` shared by both predicates: one 496-byte function. Exact
instances: 896 bytes, **+400 bytes**. Removed per scanned character: the
`rt_call_value` dispatch (225.5 Ir inclusive, 30.7 of it dispatch), the
generic-entry trampoline (7), the `guard str`, the post-call completion test,
and on the TLD path a String allocation (595 Ir). The extra 400 bytes pay back
within the first ~2 scanned characters of any run.

## Code-size impact

JIT machine-code bytes (`native::codeSize`; the 17-program corpus), and, for the
scalar-assembly corpus, objdump function sizes (`out/codesize.md`):

| program | functions emitted | bytes before | bytes after | delta |
|---|---:|---:|---:|---:|
| `refined-checks` | 24 → 26 | 8,903 | 9,089 | **+186** |
| `test-selection` | 12 → 12 | 6,589 | 6,421 | −168 |
| `uri-steady` | 17 → 17 | 5,674 | 5,462 | −212 |
| `lex-strategy` | 11 → 11 | 5,207 | 5,119 | −88 |
| `source-checks` | 7 → 7 | 4,305 | 4,249 | −56 |
| the other 12 programs | unchanged | 71,734 | 71,734 | 0 |
| **corpus (17 programs)** | 231 → 233 | **102,412** | **102,074** | **−338 (−0.33%)** |

`refined-checks`, per function (objdump corpus, `out/codesize.md`; `fib`,
`loop-count`, `sum-refined` and the nine `examples/stdlib` programs are
byte-identical):

| function | before | after |
|---|---:|---:|
| `scan_while<generic>` | 496 | — |
| `scan_while<any, block(e239)>` | — | 440 |
| `scan_while<any, native(is_tcl_alpha)>` | — | 456 |
| `local_char?<str>` | — | 176 |
| `domain?<generic>` | 1,244 | 1,076 |
| `web::emailish?<str>` | 601 | 379 |

Net +186 B in `refined-checks`: the extra `scan_while` and `local_char?<str>`
instances, partly paid for by `emailish?` (−222) and `domain?` (−168), which
lose tag tests and checked arithmetic to the range facts. The three exact HOF
programs (`test-selection`, `lex-strategy`, `source-checks`) *shrink*:
`callvalue` plus `guardbool` is larger than `callenv`. `uri-steady` (−212 B)
shrinks from the range-openness unification alone: it has no callable argument.

Which program grows the most: `refined-checks` (+186 B, +2.1%: the second
`scan_while` instance, offset by `emailish?` 601 → 379 and `domain?` 1,244 → 1,076).
Which gains the most dynamically: `refined-checks` (−17.3%), then
`test-selection` (−7.3%).

## Compile-time impact

Phases, median of 7 runs on an otherwise idle host (`tools/compiletime.tcl`;
milliseconds; `prepare` = `native::prepareHir`, which creates the semantic
instances, `lower` = every other analysis plus NIR emission, `cranelift` = the
Rust driver):

| program | prepare | specialize | range | lower | total (before → after) |
|---|---:|---:|---:|---:|---:|
| `refined-checks` | 178 → 177 | 39 → 42 | 41 → **63** | 50 → 61 | 332 → 354 (**+22 ms, +6.6%**) |
| `test-selection` | 0 → 0 | 10 → 11 | 8 → 8 | 20 → 21 | 48 → 55 |
| `lex-strategy` | 0 → 0 | 12 → 13 | 18 → 17 | 20 → 21 | 60 → 62 |
| `csv_records` (largest program) | 2 → 2 | 134 → 131 | 171 → 165 | 313 → 305 | 648 → 631 |
| `hashtable` | 1 → 1 | 67 → 64 | 81 → 80 | 99 → 100 | 278 → 261 |

The semantic layer (`prepare`) is untouched by the milestone. Codegen
specialization costs 0 to 3 ms: the extra closedness result reuses the
blockescape analysis `CloseCallers` already runs (a third, standalone run costs
4 to 11 ms on the largest corpus programs, which is why it is reused), and the
extra codegen instances are few. The one real increase is **range analysis on
`refined-checks`** (+22 ms): the closure instances that used to be range-open
(skipped) now take part in caller propagation, so the round loop does real work
on them. Programs with no closure-shaped generic instance, and the programs
that change only their key (`test-selection`, `lex-strategy`), are within
noise. The remaining differences (including `csv_records` and `hashtable`
reading faster, and the "cranelift" remainder, which is a difference of two
noisy totals) are noise, not effects. The budget probe bounds the cost of
instance growth itself: about 6 ms of lowering per extra exact instance.

## Machine code (spec #77)

`refined-checks`'s repaired loop (`scan_while<any, block(e239)>`), assembly:
`call botlish_fn_11 ; char_at<generic>` then `call botlish_fn_12 ;
local_char?<str>`. `rt_call_value` has no reference left in the object file
(1 before); `rt_str_region_is_tcl_alpha` has one (0 before). `local_char?<str>`
is 176 bytes with no `guard str`/`rt_type_error` path. The tag test on `i`/`n`
and the overflow-checked `i + 1` remain (Case 5 of the investigation: `n` has no
Range). The R2 / before / after comparison above covers dispatch, StringRegion
path, guards and materialization.

## GC stress

`exact-callable-gc-*` run, under `BOTLISH_NATIVE_GC_STRESS=1`, an exact closure
capturing a String and a List, one capturing a MutableArray and an anonymous
struct, and an exact native over a StringRegion. The generic `callvalue`
previously supplied an argument vector and rooting path; the direct call roots
the arguments and the closure like any other exact call. The whole suite also
ran under GC stress (below).

## Standalone parity

`tests/exact-callable-executable.test`: an exact Botlish block, an exact native
over a StringRegion, a mixed helper, a capturing exact closure (String, List,
Int captures) and the refined-checks scan, plus the real `bench/refined-checks.bot`.
Each is compiled to an ELF, relocated with the input deleted and an empty
`PATH`, and run normally and under GC stress, against every in-process backend.
Callables passed as arguments declare their parameter types, because AOT
readiness requires every used instance to be guard-free and a passed Block's
generic instance is used: untyped passed callables are NOT-READY on the previous
tree too.

## Full regression

All runs are on the final tree, from a snapshot copy so edits during the run
cannot leak in; "before" is the parent fence `64af2fe`, run the same way.

| check | before (`64af2fe`) | after |
|---|---|---|
| `tests/all.tcl`, `CORE_BACKEND=interp` | 3,551 / 3,551 | **3,626 / 3,626** |
| `tests/all.tcl`, `CORE_BACKEND=compile` | 3,551: 3,547 passed, 4 skipped | **3,626: 3,622 passed, 4 skipped** |
| GC stress (`BOTLISH_NATIVE_GC_STRESS=1`), interp | not run on the previous tree (CI's `gc-stress` job covers `main`) | **3,626 / 3,626** |
| GC stress, compile | not run on the previous tree | **3,626: 3,622 passed, 4 skipped** |
| `tests/native-coverage.tcl` | 3,584 tests: 1,369 native, 2,124 independent, 41 passed-partial, 49 unsupported, 1 failed | 3,660 tests: **1,411** native, **2,158** independent, 41 passed-partial, 49 unsupported, 1 failed |
| `cargo test --release --manifest-path native/Cargo.toml` | 56 + 22 passed | 56 + 22 passed (`native/src` unchanged) |
| `bench/corpus.tcl -runs 1` | 19 rows, all `agree` | 19 rows, all `agree`; code-size, function, guard, box and allocation columns identical to before in every row |

The 4 skipped tests are the `coreScoping` constraint on the compile backend, as
before. The 75 additional tests are the two new files, `exact-callable-key.test`
(60) and `exact-callable-executable.test` (6), and the exact or dynamic twins
added beside re-pinned tests.

**The native-coverage failure is not new.** `refined-5` (`Emailish? requires a
string`, in `tests/refined.test`) is the only failed test, and the 49 unsupported
tests (and the construct each needs) are the same list on both trees: the
unsupported-construct table and the failure list of the two runs are identical.

**Wall-clock** (`bench/bench.tcl -runs 5`, Cranelift column, quiet host, three
repetitions on each tree; informational). Only `refined-checks` moves by more than
the repetition-to-repetition noise:

| program | before (µs) | after (µs) |
|---|---|---|
| `refined-checks` | 858, 790, 751 | **671, 669, 669** |
| `test-selection` | 5.4, 3.6, 5.0 | 3.3, 3.9, 3.4 |
| `lex-strategy` | 56.3, 52.3, 37.5 | 35.5, 35.5, 35.7 |
| `source-checks` | 8.7, 8.4, 8.1 | 8.6, 8.3, 8.1 |

The microsecond-scale rows vary between repetitions by more than the Ir change
(−7.3%, −0.5%, −0.3%), so they are not read as signal; the Ir/run figures above,
from callgrind on one runtime binary, are the measurement. `refined-checks` is
−11% to −22% in wall-clock against −17.3% in Ir.

### Tests that pinned the old premise

Twenty-five existing tests asserted behavior that was a consequence of the erasure
(an exact callable argument stays indirect, one shared instance per kind, a
`callvalue` count). Each was reviewed and re-pinned with its reason; none was
loosened to pass. Where a test existed to exercise the **dynamic** path, its
callable was made genuinely dynamic so it keeps covering it, and an exact variant
was added:

| test | change |
|---|---|
| `callable-target-forwarded-param-*` (`hir-callable-target`) | M2 Outcome C no longer holds: one caller is direct; two callers get two instances; the budget fallback pins the old shared/indirect behavior |
| `fn-keytype-projection`, `fn-specialization-shared-instance` | exact identity in the key; sharing only past the budget |
| `ic-callable-no-target`, `ic-keys-unchanged` | an inferred contract is still never a code target, the exact argument is; a contract-only callable stays `callvalue` (new test) |
| `module-static-check-still-callvalue` | now 0; `-exact-callable-opt 0` still shows the callvalue |
| `open-instance-callvalue-stays-dynamic`, `closed-call-open-caller-fallback` | `apply`'s call is direct; closedness unchanged; the genuinely dynamic variant keeps the original contrast |
| `condition-outcome-6/7` | the "genuinely dynamic" call is made dynamic (a declared-`Fn` pick); the exact variant decides the condition (`6b`) |
| `tiny-leaf-dynamic-call-not-inlined`, `-top-level-site-still-inlines`, `-canonical-still-callable-value`, and the pressure fixture `bench/tiny-leaf-pressure.tcl` (`tiny-leaf-pressure-dynamic-keeps-canonical`) | the "dynamic use" is made genuinely dynamic (`pick`); exact variant added: a tiny leaf **is** inlined into the exact instance |
| `native-call-7`, `vc-str-open-1` (+ `-2`), `blockescape-open-call-1` (+ `-2`), `call-facts-generic-1` | exact is direct / crosses as a plan; the dynamic barrier variant added where the test is about dispatch |
| `native-executable-generic-entry` | **made dynamic**: it covers the generic trampoline in an AOT executable under GC, which an exact call no longer enters |
| `stack-map-callvalue-boundary-1/2` (+ `-3`) | **the callable is made dynamic**: with an exact target these tests stopped dispatching through `rt_call_value` and so silently stopped covering the stack-map boundary they exist for |
| `sr-recursion-higher-order-cycle`, `view-emailish-corpus-1`, `blockescape-region-companion-refined-checks-1/3`, `emailish-predicate-check-scanner-instance-count` | counts that fell or grew as intended (structs 4 → 2; Strings 8 → 5 and 8,004 → 6,804; `scan_while` two instances) |

### Which tests stopped exercising `callvalue`

An exact call is no longer a `callvalue`, so every test that used to reach the
generic path *by accident* stopped doing so, and every test that exists to cover
that path had to be kept honest. `audit/exact-callable/tools/callvalue-coverage.sh`
runs the whole suite on a copy of a tree with each `callvalue` emission logged with
the test that caused it; `callvalue-coverage-diff.py` compares two logs
(`out/callvalue-coverage-diff.txt`).

| | before | after |
|---|---:|---:|
| tests that emit `callvalue` | 153 | 144 |
| `callvalue` emissions in the suite | 647 | 465 |

Of the 153 tests that emitted `callvalue`: 54 emit none now, 81 emit fewer, 17
emit the same number, 1 emits more (`tiny-leaf-canonical-still-callable-value`,
1 → 2: the exact twin added next to the dynamic one). 45 tests that emitted none
now emit some: the new `exact-callable-*` tests (fallbacks and dynamic variants),
`callable-target-forwarded-param-shared-instance-stays-indirect`,
`ic-callable-contract-only-stays-callvalue`,
`module-static-check-callvalue-with-exact-callable-off`, and the dynamic twins
`blockescape-open-call-2` and `vc-str-open-2`.

The 54 that lost it fall in three groups, each reviewed:

1. **The test pinned the old premise** and was re-pinned (the table above): the
   `hir-callable-target` forwarded-parameter pair, `ic-callable-no-target`,
   `module-static-check-still-callvalue`, `call-facts-generic-1`,
   `blockescape-open-call-1`, `view-emailish-corpus-1/2`.
2. **The test is about something else and the callable was incidental**: they
   run `refined-checks`, `emailish?`, `test-selection`, a list-loop or a hashtable
   program and assert on values, NIR shape of a different construct, or allocation
   counts (`module-static-*`, `native-refinement-propagation-*`,
   `native-listloop-*-no-output-list`, `ht-property-*`, `bitshift-real-byte-*`,
   `tiny-leaf-real-*`, `native-validator-predicate-*`,
   `native-tcl-unicode-emailish-gc-stress`, `sr-control-test-selection`,
   `fn-dogfood-test-selection`, `vt-corpus-*`, `direct-hir-native-*`). Their
   assertions all still hold on the direct form (they are in the 3,626).
3. **The test's purpose was the dispatch path** and would have silently stopped
   covering it. These were made genuinely dynamic (a callable chosen at run time:
   `pick`, a declared-`Fn` selection) and each still emits `callvalue` in the
   "after" log: `stack-map-callvalue-boundary-1/2` (1 each),
   `tiny-leaf-dynamic-call-not-inlined` and `-top-level-site-still-inlines` (2
   each), `tiny-leaf-pressure-dynamic-keeps-canonical` (1),
   `tiny-leaf-canonical-still-callable-value` (2),
   `native-executable-generic-entry` (3), `blockescape-open-call-2` (4) and
   `vc-str-open-1/2` (1 and 4). Where the exact behavior needed its own pin, an
   exact twin exists: `tiny-leaf-exact-callable-param-call-inlines`,
   `stack-map-callvalue-boundary-3`, `blockescape-open-call-1` and `vc-str-open-1`
   (the exact test, with the dynamic one beside it), and the
   `exact-callable-executable-*` tests. The
   analysis-level tests of the dynamic case (`condition-outcome-6/7`,
   `closed-call-open-caller-fallback`, `open-instance-callvalue-*`) never lower to
   native, so this log cannot see them; their dynamic variants assert the analysis
   result directly.

After the review the suite still has **144 tests and 465 emissions** reaching the
generic ABI, and the GC-stress runs cross it through the stack-map boundary tests,
`exact-callable-gc-*` and the AOT generic-entry test.

## Required architecture questions

1. **What exactly does `InstanceClosed` prove?** That every run-time invocation
   of the instance is accounted for in the analysis's call graph (table above).
2. **Which analysis computes it?** `hir::specialize::InstanceClosed`, over a
   finished analysis, through `ClosedInstances`; the closure branch is
   blockescape's proof.
3. **At what point is it stable?** After `Fixpoint`: `calls`, `edges`,
   `values` and `used` are frozen from there.
4. **Which subsystems consume it after this milestone?** `hir::specialize`
   (`CloseCallers`), `hir::range` (`OpenInstances`), `hir::construction`, the
   audit output and the public `closed` query.
5. **Is there now one authoritative closedness proof?** Yes. The other
   subsystems that look at `generic` use a different, stated property (the
   generic-entry ABI), and the audit shows no instance closed and range-open.

6. **Codegen key of an exact Botlish block?** `{block E ARITY any ?CONTRACT?}`.
7. **Of an exact native function?** `{native NAME}`.
8. **Why uniform?** Both name a statically known target; the same `Handle` path,
   budget, join, overlay and closed-caller mechanism serve both.
9. **Where do they intentionally differ?** The final lowering (`call`/`callenv`
   with the closure as environment vs the native operation), identification (a
   block by ExprId, a native by registry name), and what is known of the signature.
10. **Two exact targets with identical `Fn` types stay distinct?** Yes.

11. **Does one exact target create a target-specific codegen instance?** Yes.
12. **Two targets?** Two instances, each direct.
13. **Beyond the budget?** The extra targets share the kind-only `block`/`native`
    instance and the callable-value ABI.
14. **Can `ClosedCallerFacts` itself create an instance after the fixpoint?** No.
15. **How is convergence guaranteed?** A finite key space and budgets; instances
    are only created in `Handle` during the fixpoint; `CloseCallers` only reads
    and narrows.

16. **Why were value-capturing closures forced generic?** Code growth, and one
    instance per closure literal for blockescape's de-closure; not correctness.
17. **Which of those can now specialize?** Any closure called with an exact
    callable, in that position (the rest of the key stays generic, refined by the
    theorem).
18. **What proof makes that safe?** A specialized instance is only entered by the
    exact calls that selected it; the closure value is an ordinary argument; the
    generic Block-value entry is untouched; blockescape handles several instances.
19. **Are captures included in callable identity?** The target, yes; captured
    values, no. (Corollary: a callable *captured* by a nested closure is not keyed;
    limitation 3.)

20. **How is an exact Botlish callable invocation lowered?** `call`/`callenv`
    to the exact instance (the closure value from the parameter as the
    environment).
21. **An exact native?** The native operation through `NativeCall`, including the
    StringRegion ops.
22. **When is `callvalue` still used?** A callable chosen at run time, a
    callable read from a List at a non-constant index, a captured callable that
    differs per creation, and the budget fallback.
23. **Does the generic callable ABI remain supported?** Yes.

24. **What did `OpenInstances` use before?** "A Block value of the block is
    materialized in some used instance's reachable code".
25. **Why was it coarser?** aot counts every bind of a capturing closure as
    materializing, so every capturing closure read open.
26. **What does it use now?** The authoritative `InstanceClosed`: an instance is
    open iff it is a non-program instance not in the stored `closed` set.
27. **Which scanner entry ranges improve?** The table above.
28. **Which machine checks disappear?** Only those in the measured table
    (`domain?`, `emailish?`, `repeat_uri`); not `scan_while`'s or `char_at`'s.

29. **Does `scan_while` still contain `callvalue`?** No.
30. **Does `local_char?` still execute through a generic trampoline?** No.
31. **Does its `guard str` remain?** No (`local_char?<str>`).
32. **Does the TLD `char_at` path still call `rt_substr` per character?** No.
33. **Ir/run after?** 6,776,096.
34. **Ir/character on the TLD path?** 371.
35. **Local-part one-character Strings remaining?** 6,800 per run.

36. **`callvalue` sites before/after?** 8 → 2.
37. **How many remaining are genuinely dynamic?** 2 of 2.
38. **Exact-callable codegen instances added?** 10 exact-keyed instances: 8
    are the same instances as before under an exact key instead of a kind-only
    one (`test-selection` 6, `lex-strategy` 1, `source-checks` 1); 2 are new
    (`scan_while`'s pair). The used set grows by 3 in total.
39. **Emitted function count?** 231 → 233 (corpus; both in `refined-checks`).
40. **Whole-corpus code bytes?** 102,412 → 102,074 B (−338 B).
41. **Which program grows the most?** `refined-checks`, +186 B.
42. **Which program gains the most dynamically?** `refined-checks`, −17.3% Ir.

### Native / Botlish symmetry

See the table in [Native / Botlish unification](#native--botlish-unification-and-where-they-differ).

## Known limitations

1. **A Block value passed as an argument still exists.** The exact-keyed
   instance never reads the parameter for an envless target, but the caller
   still produces the value (`fnvalue`), so the callee's generic instance and
   entry stay in the used set (`local_char?<generic>`, `inc<generic>`) and are
   emitted. A passed *capturing* closure is still heap-allocated, because
   blockescape counts passing as an escape (it does not see through an exact
   parameter). Dropping an exact callable parameter from the callee's ABI is a
   follow-up.
2. **A never-entered generic entry still pollutes range facts.** `scan_while<generic>`
   (the Block-value entry of a de-closured closure) is open and in the call graph,
   so its calls join into `char_at`'s entry Range, keeping `char_at.i`'s lower bound
   at `-∞`. Pruning generic entries of de-closured literals from the used set is
   the follow-up; it changes the used set, so it was left out of a
   proof-preservation milestone.
3. **A callable captured by a nested closure is not keyed.** The closure's
   capture seed is the join over creations, so two different callables reaching
   one closure literal stay a `callvalue` inside it (`exact-callable-captured-callable-boundary`).
   Adding captured callable identity to the key is the extension.
4. **Callables inside aggregates are kind-only.** A callable read from a List at
   a constant index is exact only because the *existing* exact-value analysis
   says so (`exact-value-facts`); this milestone adds no aggregate propagation.
5. **The budget is per function, by live instance**, not a global code-size
   budget.
6. **The local part still materializes** (set membership is not a region consumer).
7. **AOT readiness** is unchanged: every used instance must be guard-free, so a
   program that passes a callable as an argument still needs typed parameters on it.
8. **De-closure is decided per instance.** blockescape requires every reference
   to the closure, in *every* used instance of the literal, to resolve to a
   recorded call. An exact instance that proves a self-call dead has no recorded
   call there and makes the binding ineligible, so the closure is allocated.
   Measured case: a recursive closure called with the type-test natives
   `integer?` and `string?` on a `str` argument (the tests' outcome is known, so
   the recursive branch is dead in the `integer?` instance): 0 closures with
   `-exact-callable-opt 0`, 1 closure with exact keys
   (`exact-callable-dead-self-call-keeps-closure`). Correct, only slower, and
   only where a predicate's outcome is statically decided; the old single
   generic instance never pruned that branch. Treating an unreachable reference
   as vacuous needs lowering to guarantee it never evaluates one; lowering does
   skip decided `if` branches, but this milestone did not audit every path, and
   a violated assumption would be a compiler crash, not a slower program.

## Readiness for self-recursive result ranges

The next numerical milestone (depth-bounded result summaries for a
self-recursive instance such as `fib`) needs entry Ranges on closed instances and
an exact call to read a callee's summary. Both exist and are unchanged for
`fib`, `loop-count`, `sum-refined` and `matmul`, whose NIR is byte-identical
(`out/nir-identity.txt`). What this milestone adds to that path: exact calls
through a callable parameter now carry the callee's result Range summary to the
caller (e.g. `scan_while`'s `[0, …]`), and a closure instance blockescape
proves closed receives caller-derived entry Ranges, the precondition for any
bounded induction over a closure-shaped recursion. No result-range analysis,
raw-Int ABI, root-store or backend-frame change was made.

## Reproduction

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/exact-callable-key.test
tclsh9.0 tests/exact-callable-executable.test
git worktree add -f /tmp/base 64af2fe && ln -s "$PWD/native/target" /tmp/base/native/target
bash audit/exact-callable/tools/run-all.sh /tmp/base /tmp/exact-callable-scratch
```
