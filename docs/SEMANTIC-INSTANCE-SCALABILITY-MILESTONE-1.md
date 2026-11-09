# SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1

**Semantic instances as a reusable analysis, not a scarce resource.** An
instance's walk now types the program's own HIR in place and restores it
exactly, so it costs the function it analyzes instead of the whole
program; and no request is declined for a budget any more, so whether a
program type-checks no longer depends on how many unrelated types have
instantiated a helper.

## Summary

* **The reproducer compiles.** One untyped helper called with 17 distinct
  struct types, whose result reaches a typed parameter, was rejected at the
  17th call (`argument for parameter "f" cannot be proven to satisfy Fact
  (argument type: any)`). It now compiles at 17, 64, 256 and 1,024 types,
  each call typed with its own struct type
  (`tests/semantic-instances.test`'s `si-budget-17`, `si-budget-1024`).
  SIMCITY-WORKLOAD-KNOWN-GAPS.md's gap 3.1 (the 17th `std::test::holds`
  with a typed predicate rejected as an erasure) is the same cliff and is
  gone too (`si-budget-holds`).
* **An instance walk no longer copies the program.** It used to start from
  a copy of the HIR whose first type write copied the whole expression
  table (Tcl's copy-on-write): 8.1, 16.0, 33.0 and 81.6 ms per walk at
  20,778, 38,626, 74,322 and 145,714 expressions. It now writes the
  generic walk's own HIR and undoes exactly what it wrote: 1.5, 1.7, 1.5
  and 1.7 ms per walk on the same programs; type inference of the largest
  (25,736 lines) takes 41.9 s instead of 102.4 s. Verification applies each snapshot in place the same way.
  `si-region-no-copy` checks structurally that no walk replaces the
  expression table.
* **No budget changes a program's meaning.** The per-function budget
  (`maxPerBlock`, 16) is gone; a request deeper than the nesting limit is
  deferred to the worklist instead of declined; the total (`maxInstances`,
  2,000) and the worklist's length are the resource guards left, and
  reaching either is a compiler failure (`HIR SEMANTIC LIMIT`, naming the
  function, its entry types and the chain of instances being analyzed),
  never a TYPE error at a later use and never a fallback that could accept
  an erasure.
* **Static decisions lost a channel.** `C:budget:B` existed because which
  call got an instance depended on every other request; nothing depends on
  that now, so the channel, its pressure computation and its waiting edges
  are removed.
* **The corpus builds the same programs.** All 239 programs of
  `tests/golden/`, `examples/` and `bench/` have the same outcome under both
  compilers; 125 build the same HIR and 46 fail with the same error. The
  other 67 got instances the old budget had declined (the golden
  framework's helpers hit it all along), and one,
  `framework-semantics.bot`, decides its static blocks in one build fewer
  (section 6.2).
* **It exposed an older static-decision gap**, now closed: a site that
  decides a contribution to the erased-callable contract only through an
  argument an instance is keyed by was no contributor, so a consumer of the
  contract could be judged before it -- rejected, or decided differently by
  the batched and the sequential schedulers (section 3.4).

## 1. The original failure

`audit/mid-end-port/tools/budget.tcl` (audit/mid-end-port/README.md,
sections 5 and 8) writes

```
struct Fact:
    v: int

fn choose(c, x, y):
    if c:
        x
    else:
        y

fn value(f: Fact) -> int:
    f.v

struct T1:
    f: Fact
    tag1: int
...
pick1 = choose(true, T1 {f: Fact {v: 1}, tag1: 0}, T1 {f: Fact {v: 0}, tag1: 1})
total1 = value(pick1.f)
...
```

with N struct types. On this branch's base (53a0d1b, observed):

```
16 types: accepted in 0.13 s; 16 semantic instances, at most 16 of one function; declined: ; peak 29 MB
17 types: rejected TYPE in 0.13 s: budget-17.bot:114:27: argument for parameter "f" cannot be proven to satisfy Fact (argument type: any)
64 types: rejected TYPE in 0.44 s: budget-64.bot:302:27: argument for parameter "f" cannot be proven to satisfy Fact (argument type: any)
```

After the change (observed, `results/budget.txt`; one process, so the peak
is the process's so far):

```
16 types: accepted in 0.14 s; 16 semantic instances, at most 16 of one function; declined: ; peak 29 MB
17 types: accepted in 0.13 s; 17 semantic instances, at most 17 of one function; declined: ; peak 33 MB
64 types: accepted in 0.44 s; 64 semantic instances, at most 64 of one function; declined: ; peak 51 MB
256 types: accepted in 2.01 s; 256 semantic instances, at most 256 of one function; declined: ; peak 126 MB
1024 types: accepted in 8.83 s; 1024 semantic instances, at most 1024 of one function; declined: ; peak 430 MB
```

The base rejects 256 and 1,024 types the same way, at the 17th call.

## 2. Root causes

### 2.1 The budget

`hir::semantic::Call` declined a request past `maxPerBlock` (16) instances
of one function, past `maxInstances` (2,000) in all, or `maxDepth` (24)
analyses deep, and the call kept the callee's generic typing. That is
sound -- the generic result holds for every argument -- but it is less
precise, and a typed use of the generic result (`value(pick17.f)`, where
`pick17` is `any`) is a TYPE error the program did not commit. Which call
was declined depended on the order requests were discovered in, so adding
a call anywhere could reject a call elsewhere; the message never named the
budget. OPPORTUNISTIC-SEMANTIC-INSTANCES.md set the budgets as guards
("no budget was hit in the corpus"); nothing measured what 16 costs or
needs, and termination never depended on it (section 4).

### 2.2 The copies

Implementation inspection of `hir/semantic.tcl` and its callers on the
base found these program-sized copies or materializations on the ordinary
instance path:

| where | what | cost |
|---|---|---|
| `hir::semantic::Walk` | `set scratch [dict get $state base]`: the walk's HIR shares every table with the program's; its first `dict set scratch exprs ...` (in `hir::types::Expr`, the `reachable` write) duplicates the whole `exprs` hash table | O(expressions) per walk, every pass of every instance |
| the same walk, later writes | `bindings`, `scopes` (an `if`'s branch refinements), `types`/`typeIds` (interning a new form), `poisoned` | each table's size, at its first write per walk |
| `hir::semantic::Call` | took the HIR by value and stored it as `state base`, so the generic walk's HIR was shared during every request | -- (it made the copy above unavoidable) |
| `hir::semantic::verify` | `View $hir $id` per used instance: a copy of the HIR with the snapshot applied, `exprs` copied at its first write | O(expressions) per instance |
| `hir::traits::PlanCalls` | `hir::semantic::View` per trait-polymorphic instance context of the monomorphization plan | O(expressions) per trait-polymorphic instance (not changed: section 7) |

`hir::semantic::Snapshot` (the region's facts, read from the walked HIR)
and `Analyze`'s worklist were never program-sized. Type interning itself is
not a copy (an append), but a walk interning into a shared `types` table
copied it.

## 3. The change

### 3.1 Region-local walks

`hir::semantic::Call`, `Analyze`, `Walk`, `Drain` and `Nested` take the
*name* of the HIR variable the generic walk is typing
(`hir::types::Call` passes `hir`), so an instance's walk runs
`hir::types::Sequence` on that variable itself: no second reference to the
HIR exists, and Tcl writes its tables in place. The existing typing,
refinement, reachability, verification and fixpoint code is unchanged: it
still reads and writes an ordinary HIR dict. What makes this safe is that
the walk leaves the HIR exactly as it found it:

* `Save` records, before the walk: every top-level entry but the large
  tables, by reference; of `exprs`, every expression of the block's region
  (`Region`: the block, its body, the closures it creates); of `scopes`
  and `bindings`, every scope nested in the block's body scope
  (`RegionScopes`, from a parent-to-children index made once per run) and
  every binding declared in one; the interning counter; the order of the
  top-level entries.
* `Restore` puts every recorded value back, removes top-level entries the
  walk added, drops the types interned since the mark and restores the
  entries' order. The outermost walk also restores the id counters and
  `symbols`.
* What the walk computed survives only in the instance's snapshot and
  outward type, read before `Restore` (`Snapshot`, `Outward`) -- exactly as
  when it was computed in a copy.

Every walk must start from the HIR the top-level request found (the old
`state base`). A request made from inside another instance's walk
(`Nested`) therefore captures the innermost walk's current entries
(`Capture`), rewinds them to their saved values (`Rewind`), analyzes the
new instance and puts the captured entries back. Only the innermost walk's
changes are ever in the variable, so one rewind suffices. Interning, the id
counters and `symbols` only grow: they are never put aside (an enclosing
walk's type ids stay valid) and only the outermost walk drops them.

`hir::semantic::verify` does the same per used instance: `Save`, `Apply`
(the in-place body of `View`, which stays for its other callers), the five
verifiers on the HIR itself, collect the diagnostics and violated
contracts, `Restore`. `hir::layouts::verifyInstance`, which compares an
instance's receiver types with the generic program's, gets a stand-in
holding the region's saved nodes and their types.

### 3.2 No per-function budget; deferred nesting; one guard

* `maxPerBlock` is removed. Every distinct entry-type combination is its
  own instance.
* A request made with `maxDepth` analyses in progress, or with Tcl's stack
  past `levelLimit`, is **deferred** (`Defer`): the instance is created,
  queued and answers with its current result (`never`), and the caller is
  marked as assuming -- the mechanism recursive requests already used. The
  worklist (`Drain`, which every top-level request runs) analyzes it once
  the analyses in progress return, and re-analyzes its readers when its
  result grows. Depth costs walks, never precision, and whether a call
  gets its instance no longer depends on which request came first
  (`si-defer-1`, `si-defer-2`, `se-equal-deep-first-request`).
* `maxInstances` (2,000) and the worklist's length (5,000 analyses plus
  4 x (passLimit + 3) per instance) are the resource guards left. Reaching
  either throws `HIR SEMANTIC LIMIT` (`Exhausted`), for example (with the
  limit set to 1, `si-rec-6b`): "the semantic-instance limit was reached:
  1 instances were analyzed, and a call needs another one: inner (y : int),
  requested while analyzing outer (x : int); the compiler does not fall
  back to the untyped analysis, which could reject a valid program ..."
  (`si-rec-6`, `si-rec-6b`). The trait-polymorphic and affine exemption
  (past the budget such a call got an instance keyed by its views alone)
  is gone with the fallback it worked around. A failed walk abandons the
  run (`hir::semantic::Abandon`), so no state is left for the next
  compilation.
* The one request still declined is a closure's whose creation
  environment no walk has recorded yet (`no-env`), which a later walk of
  the program serves -- structural, not a count.

### 3.3 Static decisions

`hir/staticdeps.tcl`'s `C:budget:B` channel tracked "pressure" on the
budget (a function holding half its per-block budget, half of all
instances, a request at half the nesting limits) because a rejection could
grant or deny another call's instance. With no decline for a count or a
depth, which call gets an instance depends on its own key alone, and the
total guard is a compiler failure, not a site outcome. The channel, its
pressure computation (`pressured`, `budgetOf`) and its waiting edges are
removed; the remaining waiting channels are `C:erased` and `C:unwind`.
Declined requests (now only `no-env`) still count as erasure contributors.

### 3.4 A dependency the budget hid

The first full test run after the change failed one suite: golden
`callables.bot`, 6 of 140 tests, on every backend, each with
UNHANDLED-ERROR ("this call through a callable value the completion
analysis cannot identify ... may produce the declared error NotFound").
Observed, then reduced to a 45-line program (`se-equal-erased-key-argument`):

* the suite's `errs_*` blocks, which expect to be rejected, end in a
  callable `errs` declaring `NotFound`. In the build where their bodies are
  present, `std::test::rejects_containing`'s instance for such a body (its
  `body` parameter has a trusted callable contract, which the exact callable
  refines, so the instance is keyed by that callable and its result type)
  passes the result to `std::test::describe`'s untyped parameter: a
  contribution of `NotFound` to the erased-callable contract;
* the waiting rule should hold every consumer of that contract back until
  the `errs_*` blocks are rejected, as it did before; but the contribution's
  chain of requests lies outside every static block, and the dependency
  analysis followed, at each call of the chain, only the arguments at
  parameters with no contract. The argument the key is made of here sits at
  a contracted parameter, so the blocks were no contributors, and the six
  consumers were judged, and rejected, first.

Before the change the budget hid it: the suite calls `rejects_containing`
far more than 16 times, the requests were declined, and the analysis
counted each declined request as a contributor of unknown errors through
its call's arguments. The gap itself is older than the change (observed on
the base): in the reduced program, written consumer first, both schedulers
rejected the consumer; written eraser first, the batched scheduler rejected
it where the sequential order accepted it -- a disagreement no golden suite
happened to contain.

`hir::staticdeps::KeyArguments` now follows every argument whose static
type is not its parameter's contract, as `hir::semantic::Call` keys the
instance by it. Both layouts give the same outcome, under both schedulers
(the consumer accepted, the eraser rejected); `callables.bot` passes 140 of
140; the mutant `key-arguments-uncontracted-only` restores the old rule.

### 3.5 The rollback audit

`hir::semantic::auditRollback` (`BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`) keeps
a reference to the HIR at every `Save` and compares the whole HIR with it
after `Restore`, entry by entry, failing the compilation on any difference
(an entry added, removed or changed anywhere, below the outermost walk the
growing tables excepted). It copies the program at every walk -- the cost
the change removes -- and is for tests and audits only. It found nothing in
`tests/semantic-instances.test`, `tests/traits.test`, `tests/affine.test` and
`tests/coroutines.test` (section 6.1).

### 3.6 Merging main's loop clause records (2026-11-09)

`main` gained LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md
(a71cfe4) while this branch waited for CI: the typing walk records a loop
clause binding's type (`hir::types::RecordClause`), and an instance's walk
records it into a top-level table of its own, `instanceClauses`, which
`hir::semantic::Snapshot` reads. On `main` that table lived in the walk's
scratch copy and died with it. Here the walk types the program's HIR in
place, so the table must not survive the walk, and it does not without any
change to the journal: `Save` keeps every top-level entry that is not one
of the sparse tables, and `Rewind` removes every top-level entry the
journal does not hold (section 3.1). A walk nested in another puts the
enclosing walk's records aside with its other changes (`Capture`) and
back after. The merge itself changed only what read the scratch copy:
`Snapshot` reads `instanceClauses` from the HIR it is given, the comment of
`RecordClause` describes the walk in place, and the mutant
`lcb-snapshot-omits-clauses` (`audit/loop-binding-types/tools/mutants.txt`)
quotes the new text. `si-region-clause-records` (new) compiles a helper with
a loop instantiated for three element types, one instance requested from
inside another's walk, under the rollback audit: every instance's snapshot
has its own element type and the program's HIR has no `instanceClauses`; a
`Rewind` that keeps the table fails it. All 14 of main's
`loop-binding-types` mutants are killed on the merged tree.

## 4. Invariants and what bounds the analysis

* The HIR is authoritative and unmodified by an instance walk: every walk
  restores it exactly (audited, section 3.5).
* Isolation: each walk starts from the request-time HIR, with its own
  parameter and capture environment; facts of one instance never reach
  another or the generic program (`si-region-isolated`,
  `si-region-generic-intact`).
* Recursion and mutual recursion keep their fixpoint: the worklist, the
  `assumes`/`dirty` marks and the `passLimit` widening are unchanged;
  deferral reuses them.
* Termination does not depend on a count of instances per function: entry
  types are types of the finite lattice of `hir::types` (aggregate nesting
  bounded by `aggregateDepth` 3, applications by `appliedDepth` 6, minted
  List lengths forgotten by `ForgetInferred`), so every function has
  finitely many keys -- type-changing recursion such as `wrap([x], n - 1)`
  reaches `any` at the bound (`si-rec-3`: 8 instances); an instance's
  result only grows and is widened to `any` past `passLimit` growing passes
  (a function of the instance alone); deferral bounds the Tcl stack. The
  key space is finite but can be very large, so `maxInstances` stays as a
  resource guard, and the worklist's length as a guard against a
  convergence bug.
* Semantic instances stay analyses: `hir::specialize::KeyType` and native
  specialization are untouched (no file of `native/` or
  `hir/specialize.tcl` changed), and `si-run-3` runs a 20-instance program
  on all four backends.
* A genuinely invalid instance is still diagnosed at the call that needs
  it, whatever other instances exist (`si-budget-real-error`); a deferred
  one too (`si-defer-2`).

## 5. Files

| file | change |
|---|---|
| `hir/semantic.tcl` | in-place walks and verification (`Save`, `Capture`, `Rewind`, `Restore`, `AuditRestore`, `RegionScopes`, `ScopeKids`, `Apply`, `Nested`), deferral (`Defer`), the guard (`Exhausted`, `Drain`), `Abandon`; `maxPerBlock` removed; the header's "Budgets" and "Region-local walks"; `Snapshot` reads main's `instanceClauses` in place (section 3.6) |
| `hir/types.tcl` | `hir::types::Call` passes the variable's name; `hir::types::Walk` abandons the run on error; `RecordClause`'s comment (section 3.6) |
| `hir/staticdeps.tcl`, `hir/static.tcl` | `C:budget` removed; `KeyArguments` (section 3.4) |
| `hir/traits.tcl`, `hir/affine.tcl` | two messages and a comment no longer blame a budget |
| `tests/semantic-instances.test` | `si-rec-3/5/6` rewritten; 16 new tests (96 in all) |
| `tests/static-economics.test` | `se-equal-deep-first-request` expects `late` accepted; `se-equal-erased-key-argument` (new) |
| `audit/semantic-instance-scalability/` | `tools/equivalence.tcl` (the corpus HIR comparison), `tools/scaling.tcl` (the measurement grid), `results/` (their recorded outputs) |
| `audit/mid-end-port/tools/` | `instance-walks.tcl` reports instances, per-walk time and peak memory; `budget.tcl` and `measure.tcl` cope without `maxPerBlock` |
| mutant catalogs | static-decisions: `budget-deep-ignored` removed, `key-arguments-uncontracted-only` added, `channels-not-consumed` and `unwind-not-waiting` updated; native-view `untyped-receiver-accepted`, tree-struct `construction-outward-result-only`, loop-binding-types `lcb-snapshot-omits-clauses` (section 3.6) updated |
| Compilerpedia | `error.hir-semantic-limit` (new); `concept.specialization`, `error.affine-erasure-unsupported`, `error.affine-instance-budget`, `error.trait-instance-budget` corrected |
| docs | OPPORTUNISTIC-SEMANTIC-INSTANCES.md, STATIC-COMPILE.md, STATIC-DECISION-ECONOMICS.md, SIMCITY-WORKLOAD-KNOWN-GAPS.md (gap 3.1 fixed), INDEX.md, AGENTS.md (the waiting channels) |
| golden census and manifest | rows for the 17 new Tcl tests (`audit/golden/migration/census/`, `tcl-names.txt`, `tests/golden/manifest.tsv` regenerated) |

## 6. Evidence

Three kinds of evidence, kept apart: **observed** (a run on this
machine, a shared 4-core Linux x86-64 container, Tcl 9.0.1, on 2026-11-08;
times move by 10-25 % from run to run and several runs shared the cores,
which the result files say), **CI** (GitHub Actions on the branch) and
**projected** (what follows from the measured cost model, marked as such).
"Before" is the branch's base, 53a0d1b; "after" is 5471d1e (this
milestone's first commit, before `main` was merged in) for the comparisons,
and the branch head for the tests.

### 6.1 Correctness: tests and harnesses (observed)

| run | result |
|---|---|
| `tests/semantic-instances.test` | 95 of 95; 93 of them again with `BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1` (the two left out are the 1,024-type program and `si-region-no-copy`, which the audit's own copies would defeat). On the tree merged with main (bf0f585): 96 of 96, and 96 of 96 with the audit (`si-region-no-copy` turns it off for itself) |
| `tests/traits.test`, `tests/affine.test`, `tests/coroutines.test` under the rollback audit | 112, 48 and 81 of 81: no walk left a change behind |
| `tests/static-economics.test`: `se-equal-deep-first-request`, `se-equal-plan-unplanned`, `se-equal-erased-key-argument` | pass |
| golden `callables.bot` (section 3.4) | 134 of 140 before the fix, 140 of 140 after |
| `tests/local.tcl` on the branch head (every Tcl test file on interp and compile, every golden suite on the four backends, 4 jobs, 6,694 s) | 0 failures: Tcl tests 9,071 passed on interp and 9,066 on compile (214 and 219 skipped by constraint, 2,493 golden duplicates each); 119 golden suites, 5,682 / 5,682 / 5,590 / 5,692 tests passed on interp / compile / cranelift-generic / cranelift |
| `audit/static-decisions/tools/fuzz.tcl -seed 17`, `-seed 41` | 0 failures (484 and 564 sites) |
| mutants: static-decisions `channels-not-consumed`, `unwind-not-waiting`, `key-arguments-uncontracted-only`; native-view `untyped-receiver-accepted`; tree-struct `construction-outward-result-only` | 5 of 5 apply and are killed (by `se-equal-consumer-waits`, `se-equal-erased-witness`, `se-equal-unwind-channel`, `se-equal-erased-key-argument`, `nv-untyped-receiver`, `ts-generic-construction-typed`) |
| `tools/mutant-catalogs.tcl` | 92 catalogs, 3,213 mutants, 0 problems |
| `tools/compilerpedia.tcl check` | 1,291 topics, 758 examples, 0 problems |
| `audit/golden/migration/merge.tcl -check 1` | 13,448 rows, consistent |
| `tests/local.tcl` on the tree merged with main (bf0f585, the native driver rebuilt; 4 jobs, 5,705 s) | 0 failures: Tcl tests 9,164 passed on interp and 9,159 on compile (264 and 269 skipped by constraint, 2,493 golden duplicates each); 119 golden suites, 5,682 / 5,682 / 5,590 / 5,692 tests passed on interp / compile / cranelift-generic / cranelift |
| merged tree: `tests/loop-clause-binding-types.test` (also under the rollback audit), `audit/loop-binding-types/tools/mutate.tcl`, `tools/mutant-catalogs.tcl`, `merge.tcl -check 1`, `tools/compilerpedia.tcl check` | 18 of 18 both ways; 14 of 14 mutants killed; 97 catalogs, 3,308 mutants, 0 problems; 13,549 rows, consistent; 1,295 topics, 760 examples, 0 problems |

### 6.2 The corpus builds the same programs (observed)

`audit/semantic-instance-scalability/tools/equivalence.tcl` compiled all
239 programs of `tests/golden/`, `examples/` and `bench/` with both
compilers and compared, per program, the outcome, a digest of the checked
HIR and a digest of the semantic-instance table
(`results/equivalence.tsv`):

| class | programs |
|---|---:|
| identical HIR and instance table | 74 |
| identical once run-to-run variation is set aside (a wall-clock time in `staticStats`, the census counters of `traitSource`'s table, checkout paths) | 45 |
| identical once the checker fingerprint emission certificates record is set aside (it hashes the checker's own source, which this change edits) | 6 |
| failing in both, with the same error (modules compiled as programs, other platforms' programs) | 46 |
| **more instances**: the base declined requests for its per-function budget; the new compiler analyzes them | 67 |
| static decisions in fewer builds (`framework-semantics.bot`: 3 rounds and 6 builds before, 2 and 5 after; the removed `C:budget` channel had forced one) | 1 |
| a different outcome | **0** |

The 67 are mostly golden suites: the golden framework's helpers
(`std::test::value`, `rejects_containing`, ...) are untyped functions
called with a different body callable per test, so the budget was hit in
the corpus all along (`flags.bot`: 108 declined requests, 140 instances
before, 203 after; at most 464 instances in any program after). The
opposite was believed (OPPORTUNISTIC-SEMANTIC-INSTANCES.md: "no budget was
hit in the corpus"), true when it was written, before the golden
framework.

### 6.3 Cost of an instance walk (observed)

On generated mid-end-shaped programs (`audit/mid-end-port/tools/synth.tcl
-generic 0`; `results/instance-walks.txt`), one process each:

| lines | expressions | walks | before: per walk | after: per walk | before: `signatures::infer` | after | front end before | after | peak MB before | after |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 3,344 | 20,778 | 48 | 8.1 ms | 1.5 ms | 4.5 s | 4.1 s | 23.0 s | 22.9 s | 524 | 524 |
| 6,543 | 38,626 | 126 | 16.0 ms | 1.7 ms | 11.0 s | 8.4 s | 46.9 s | 43.5 s | 946 | 945 |
| 12,939 | 74,322 | 258 | 33.0 ms | 1.5 ms | 29.8 s | 16.6 s | 97.3 s | 85.1 s | 1,783 | 1,782 |
| 25,736 | 145,714 | 477 | 81.6 ms | 1.7 ms | 102.4 s | 41.9 s | 239.1 s | 176.8 s | 3,094 | 3,090 |

Before, a walk cost the program (8 to 82 ms, doubling with it: the copy
of the expression table, 4.3, 10.1, 25.8 and 56.0 ms at these sizes);
after, it costs its function's region and stays flat (1.5-1.7 ms). The
instance walks of the 25,736-line program took 38.9 s and take 0.8 s; its
type inference (`hir::signatures::infer`) 102.4 s and 41.9 s, its front end
239 s and 177 s, with the same peak memory. (The first three rows ran
one at a time while other jobs shared the cores, the last two side by side
on an otherwise quiet machine.)

The grid of `tools/scaling.tcl` (`results/scaling.txt`; 3 of the 4 cores
busy with other work, so times are inflated) separates the three sizes:

* **The program grows, the helper and its 16 instances stay**: 782, 3,086,
  6,158 and 12,302 lines. Per walk before 0.65, 1.78, 6.72 and 12.83 ms;
  after 0.13, 0.16, 0.17 and 0.18 ms. Instance verification 0.02-0.38 s
  before, 0.00-0.01 s after.
* **The instances grow, the program stays** (6,158 lines): 1, 16, 64, 256
  and 1,024 distinct types. Before, 64 and more are rejected (TYPE). After,
  all compile; the walks of 1,024 instances take 0.11 s in all
  (0.11 ms each), their verification 0.17 s, and the peak memory grows from
  361 to 370 MB.
* **The helper grows** (1,550 to 1,710 lines, 16 instances): 0, 40 and 160
  extra statements. A walk now costs its region. In the first grid
  (5471d1e, cores shared) the 160-statement helper's walk took 22.7 ms
  against 15.2 ms before: the journal (saving and restoring about 1,500
  entries) cost more than copying a 1,710-line program's table. Profiled,
  saving took 1.9 ms and restoring 3.1 ms per walk; stored as flat lists,
  each table restored through one lookup per entry (9dca40a), 1.5 and
  2.4 ms. Measured again on a quiet machine: per walk 1.0, 4.9 and 20.6 ms
  before, 0.17, 4.6 and 20.1 ms after; and the same 160-statement helper in
  a 12,462-line program 40.9 ms before, 28.0 ms after.

### 6.4 The shared helper at scale (observed)

With the shared untyped helper of the scale experiment (`synth.tcl
-passes 32 -generic 1`, 13,899 lines: every tier-1 handler calls
`lattice::choose` with its pass's own struct, one more instance per pass;
`results/shared-helper.txt`), the base rejects the program after 96.9 s
(`pass_17.bot:103:23: argument for parameter "x" cannot be proven to
satisfy lattice::Fact (argument type: any)`, peak 1,935 MB). The branch
accepts it in 113.2 s with 33 instances, 32 of them of `choose`, none
declined (peak 1,972 MB). The 16 s difference is compiling the rest of the
program, which the rejected compilation did not finish.

The reproducer itself (`results/budget.txt`, one process, quiet machine):
the base accepts 16 types and rejects 17, 64, 256 and 1,024 (TYPE, at the
17th call); the branch accepts all five, 1,024 types in 8.8 s with 1,024
instances.

### 6.5 CI

Dispatched on the branch: `static-decisions.yml` (the batched against
the sequential scheduler on every golden suite: the check of section 3.4
and of `framework-semantics.bot`'s fewer builds), `tests.yml` and
`tests-arm64.yml` (the whole suite and its native coverage; their
GC-stress jobs run on pushes to main only, so they are skipped here); and
the push workflows (macOS arm64, Windows x86-64, the two Icy Tower
builds).

Main was merged into the branch at bf0f585 (section 3.6), so the runs that
count are that commit's; the runs at a6f677e and 9dca40a tested the tree
before the merge. At a6f677e, before they were superseded, `icy-tower
(windows x86-64)` and `icy-tower (macos arm64)` passed, `tests (windows
x86-64)` passed its canary, smoke and root-plans jobs, and `tests.yml`
passed its canary. The state at bf0f585 on 2026-11-09 11:40 UTC, the shared
runners saturated (main's own test workflows at 996b50d are queued too):

| workflow | run | state |
|---|---|---|
| `tests.yml` (dispatched) | 42553518671 | passed: canary (mutant catalogs, warning gate, canary selection), native Rust unit tests, the four golden shards (every suite on every backend beside its Tcl originals), stub-linked executables, the method-call decision job (its tests, oracle and fuzzer, and the golden suites under the reference audit). `tests (interp)` did not run its tests: its "Install Neovim" step failed fetching Neovim's release (`curl: (22) ... error: 504`, GitHub's release server), before any test; to be rerun when the run ends. Running: cranelift and cranelift-generic coverage. Queued: compile, system-linked executables |
| `tests-arm64.yml` (dispatched) | 42553521335 | passed, every job: canary, interp, compile, both GC-stress runs, cranelift and cranelift-generic coverage, the four golden shards, the native Rust unit tests (also under GC stress), system-linked executables |
| `static-decisions.yml` (dispatched) | 42553524098 | passed: batched and sequential agree on every golden suite (mutable-array.bot: batched 5 rounds, 7 builds; sequential 69 rounds, 205 builds) |
| `windows-x86_64.yml` | 42553507858 | passed, every job |
| `macos-arm64.yml` | 42553507896 | passed: the Linux control, smoke (with the canary), Botlish.app, acceptance shards 1, 3 and 4. Running: acceptance shard 2, system linker. Queued: main-thread startup, static SDL3, Botlish.app without developer tools |
| `icy-tower-windows.yml` | 42553507899 | passed |
| `icy-tower-macos.yml` | 42553507952 | passed |
| `raven-cleanroom.yml`, `ci-tools.yml` | 42553507901, 42553507895 | passed |

Whatever is pending above is pending, not passed.
PENDING-CI

## 7. Remaining limits and known problems

* **A walk still costs its whole region.** Save and Restore touch every
  expression of the instance's block and nested closures, about 1.6 us per
  entry: an instance of a large function costs a few milliseconds more than
  its typing. In a small program with a large helper this exceeds what the
  old table copy cost (section 6.3); in a large program it is far less.
  Saving only what a walk writes needs every write to go through one place,
  which `hir/types.tcl` and the procedures it calls do not.
* **The trait plan still copies the program per trait-polymorphic
  instance.** `hir::traits::PlanCalls` makes a `hir::semantic::View` (a copy
  of the HIR with the snapshot applied) per trait-polymorphic instance
  context it plans, and reads it through helpers that also read the
  generic HIR; applying it in place would need those helpers to be told
  which one they read. It scales with trait-polymorphic instances only, not
  with instances in general: golden `traits.bot` (5,799 expressions)
  makes 186 such views, 0.29 s of a 23 s compilation
  (`results/remaining-copies.txt`).
* **Native specialization still copies the program per codegen instance**
  (`hir::specialize::memoizeViews`, audit/mid-end-port/README.md section 5:
  the specialized native build of a 12,939-line program does not fit in 16
  GB). Out of this milestone's scope (codegen instances, not semantic
  ones), and the next wall for a large program on the specialized native
  backend.
* **The rest of type inference is still superlinear, in one place.** With
  the copies gone, the statement walkers the audit suspected cost the same
  per call at every size (`results/infer-profile.txt`; exclusive time per
  call at 6,543, 12,939 and 25,736 lines): `hir::types::Sequence` 0.031,
  0.039, 0.037 ms (before: 0.105, 0.264, 0.47 -- the copies were charged to
  it, the wrapper being the walk's), `Bind` 0.022, 0.028, 0.030, `If`
  0.065, 0.084, 0.074, `Call` 0.060, 0.073, 0.065. `hir::types::Block`
  does not: 0.16, 0.31, 0.57 ms. It starts each function body's context
  from the creating context's `types`, every binding typed so far on the
  path (at a module's top level, every earlier top-level binding), and the
  body's first write copies that dict: 227 entries on average at 3,344
  lines, 399 at 6,543, so 0.62 and 1.92 million entries copied in all
  (`remaining-copies.txt`) -- quadratic, the same copy-on-write pattern at
  a smaller scale. Starting the body from its captures' types alone (an
  outer local a body refers to is a capture; a module binding is typed
  once, outside the context) is the likely fix, if nothing reads the rest
  of the creating context there (not verified: its facts and implications
  would need the same check); not changed here.
* **The total guard stays.** `maxInstances` (2,000) bounds a finite but
  possibly very large key space; nothing in the corpus comes near it (464
  at most). A program past it fails with HIR SEMANTIC LIMIT rather than
  compiling less precisely; the limit was not measured against a
  port-sized program with many polymorphic helpers. Projected, from 6.3:
  2,000 instances of small helpers cost well under a second of walks; of
  160-statement helpers, about a minute.
* **`passLimit`** still widens an instance whose result keeps growing to
  `any` after 6 passes: a widening of one instance's own fixpoint (it
  depends on that instance alone, never on other instances), unchanged.
* **The `no-env` decline** remains for a closure whose creation environment
  no walk has recorded yet; a later walk of the program serves it
  (`maxRounds` 3).
* **The static-decision gap of section 3.4** is closed for the arguments a
  key is made of; whether other routes by which a site decides an
  instance's existence exist is not known. The fuzzer's programs did not
  find one (6.1), and the CI comparison of the batched and sequential
  schedulers over every golden suite is the check (6.5).

## 8. Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
S=$(mktemp -d); R=audit/semantic-instance-scalability/results
T=audit/semantic-instance-scalability/tools
git worktree add --detach $S/before 53a0d1b
git worktree add --detach $S/after 5471d1e

# the reproducer (section 1, 6.4)
(cd $S/before && tclsh9.0 audit/mid-end-port/tools/budget.tcl -types "16 17 64 256 1024")
tclsh9.0 audit/mid-end-port/tools/budget.tcl -types "16 17 64 256 1024"

# the corpus (6.2): one line per program, then compare the first five fields
ls tests/golden/*.bot examples/*/*.bot examples/*/*/*.bot examples/*/*/*/*.bot bench/*.bot 2>/dev/null | sort -u > $S/files
tclsh9.0 $T/equivalence.tcl $S/before $(cat $S/files) > $S/before.txt
tclsh9.0 $T/equivalence.tcl $S/after $(cat $S/files) > $S/after.txt

# instance walks (6.3): one process per program
for p in 8 16 32 64; do tclsh9.0 audit/mid-end-port/tools/synth.tcl -out $S/g$p -passes $p -generic 0; done
for p in 8 16 32 64; do for r in before after; do
    tclsh9.0 audit/mid-end-port/tools/instance-walks.tcl $S/$r $S/g$p/main.bot
done; done

# the grid (6.3)
for r in before after; do
    tclsh9.0 $T/scaling.tcl $S/$r 128:16:0 512:16:0 1024:16:0 2048:16:0 \
        1024:1:0 1024:64:0 1024:256:0 1024:1024:0 256:16:0 256:16:40 256:16:160 2048:16:160
done

# the shared helper (6.4) and the profile (7)
tclsh9.0 audit/mid-end-port/tools/synth.tcl -out $S/h32 -passes 32 -generic 1
for r in before after; do
    tclsh9.0 audit/mid-end-port/tools/instance-walks.tcl $S/$r $S/h32/main.bot   # fails on before: TYPE
    tclsh9.0 audit/mid-end-port/tools/infer-profile.tcl $S/$r $S/g32/main.bot audit/mid-end-port/results/infer-procs.txt
done

# the remaining copies (7)
tclsh9.0 $T/remaining-copies.tcl views tests/golden/traits.bot
tclsh9.0 $T/remaining-copies.tcl contexts $S/g8/main.bot $S/g16/main.bot

# the rollback audit over a test file
BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1 tclsh9.0 tests/semantic-instances.test -tmpdir $S/t
```

The result files record which runs shared the machine; times move by 10-25 %
between runs, counts do not.
