# SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1

(Draft: the evidence sections are filled in by the commit that completes the milestone.)

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
  table (Tcl's copy-on-write): 8.1, 16.0 and 33.0 ms per walk at 20,778,
  38,626 and 74,322 expressions. It now writes the generic walk's own HIR
  and undoes exactly what it wrote: 1.5, 1.7 and 1.5 ms per walk on the
  same programs. Verification applies each snapshot in place the same way.
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
* **The corpus builds the same HIR.** RESULTS-EQUIVALENCE

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

After the change (observed):

```
16 types: accepted in 0.18 s; 16 semantic instances, at most 16 of one function; declined: ; peak 29 MB
17 types: accepted in 0.16 s; 17 semantic instances, at most 17 of one function; declined: ; peak 33 MB
64 types: accepted in 0.58 s; 64 semantic instances, at most 64 of one function; declined: ; peak 51 MB
```

(The 64-type compile here ran with the rollback audit on, which copies the
program at every walk: section 3.4.)

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
  result grows. Depth costs walks, never precision, and no outcome depends
  on which request came first (`si-defer-1`, `si-defer-2`,
  `se-equal-deep-first-request`).
* `maxInstances` (2,000) and the worklist's length (5,000 analyses plus
  4 x (passLimit + 3) per instance) are the resource guards left. Reaching
  either throws `HIR SEMANTIC LIMIT` (`Exhausted`): "the semantic-instance
  limit was reached: 2000 instances were analyzed, and a call needs another
  one: inner (y : int), requested while analyzing outer (x : int); ..."
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

### 3.4 The rollback audit

`hir::semantic::auditRollback` (`BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`) keeps
a reference to the HIR at every `Save` and compares the whole HIR with it
after `Restore`, entry by entry, failing the compilation on any difference
(an entry added, removed or changed anywhere, below the outermost walk the
growing tables excepted). It copies the program at every walk -- the cost
the change removes -- and is for tests and audits only. AUDIT-RESULTS

## 4. Invariants and what bounds the analysis

* The HIR is authoritative and unmodified by an instance walk: every walk
  restores it exactly (audited, section 3.4).
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
| `hir/semantic.tcl` | in-place walks and verification (`Save`, `Capture`, `Rewind`, `Restore`, `AuditRestore`, `RegionScopes`, `ScopeKids`, `Apply`, `Nested`), deferral (`Defer`), the guard (`Exhausted`, `Drain`), `Abandon`; `maxPerBlock` removed; the header's "Budgets" and "Region-local walks" |
| `hir/types.tcl` | `hir::types::Call` passes the variable's name; `hir::types::Walk` abandons the run on error |
| `hir/staticdeps.tcl`, `hir/static.tcl` | `C:budget` removed |
| `hir/traits.tcl`, `hir/affine.tcl` | two messages and a comment no longer blame a budget |
| `tests/semantic-instances.test` | `si-rec-3/5/6` rewritten; 16 new tests |
| `tests/static-economics.test` | `se-equal-deep-first-request` expects `late` accepted |
| `audit/semantic-instance-scalability/tools/` | `equivalence.tcl` (the corpus HIR comparison), `scaling.tcl` (the measurement grid) |
| `audit/mid-end-port/tools/` | `instance-walks.tcl` reports instances, per-walk time and peak memory; `budget.tcl` and `measure.tcl` cope without `maxPerBlock` |
| mutant catalogs | static-decisions: `budget-deep-ignored` removed, `channels-not-consumed` and `unwind-not-waiting` updated; native-view `untyped-receiver-accepted`, tree-struct `construction-outward-result-only` updated |
| Compilerpedia | `error.hir-semantic-limit` (new); `concept.specialization`, `error.affine-erasure-unsupported`, `error.affine-instance-budget`, `error.trait-instance-budget` corrected |
| docs | OPPORTUNISTIC-SEMANTIC-INSTANCES.md, STATIC-COMPILE.md, STATIC-DECISION-ECONOMICS.md, SIMCITY-WORKLOAD-KNOWN-GAPS.md (gap 3.1 fixed), INDEX.md, AGENTS.md (the waiting channels) |

## 6. Evidence

EVIDENCE

## 7. Remaining limits and known problems

REMAINING
