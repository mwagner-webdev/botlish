# Compiler bottlenecks and algorithmic performance bugs: what to tackle next

A backlog, ranked, of what makes the Botlish compiler slow and of the
algorithmic defects behind it, with the evidence for each item and what a
fix needs. It collects the measurements scattered over TEST-SUITE-COST.md,
LARGE-SCALE-GOLDEN-MIGRATION.md ("Compiler performance"),
STATIC-DECISION-ECONOMICS.md, RANGE-FIXPOINT-SCALING.md and the studies in
`audit/golden/migration/out/`. It adds what was measured while narrowing the
trait plan's gate (STATIC-DECISION-ECONOMICS.md, "Trait-polymorphic calls
with their instances"), including three defects found on the way (section 4).

State: main at `92ec95ed`, which is `fdbf946c` plus the C:plan port. Golden-suite
figures marked *measured here* are from `fdbf946c` unless noted, and were taken for this
report: single Tcl 9.0.1 processes on a 4-core container, with up to four
other jobs running. They are indicative, not a benchmark. Every other figure
is quoted from the document named beside it.

Since then the correctness defects of section 4 are fixed: 4.1, 4.2 and 4.4
by the change that added this paragraph (each item says how, and which tests
pin it), 4.3 by the C:plan port. Of the performance backlog of section 3,
3.9 is partly done: the demotion re-check reuses the part of the check
before it that the demotion cannot change (3.9 says what, with its
measurements on a39f9dc). The rest of section 3 is unchanged.

That change was validated as follows:

- `tests/all.tcl` on interp and compile: 170 files, every test passing.
- The trait mutants: 20 of 20 killed. The context-trait mutants: 23 of 23.
- The static-decision mutants of the plan's gate and the budget (`plan-*`, `budget-deep-ignored`): 7 of 7.
- The error-identity mutants: 10 of 10. The SAME-FAILURE mutants: 15 of 15.
- `tests/traits.test` under `BOTLISH_NATIVE_GC_STRESS=1`.
- Fuzzers with 0 failures:
  - traits;
  - context traits;
  - static compile;
  - static decisions, seeds 17, 41 and 5 (seed 41's output byte-identical to the tree before the change);
  - structural contracts, seeds 1 and 7, and the `carrier`, `unknown` and `drop` faults;
  - error payloads, plain and with the `unhandled` and `wrong-namespace` faults.

## 1. Summary

The front end is the cost. Running the tests costs almost nothing, and code
generation in Cranelift is negligible. Within the front end, the cost is the
work repeated per build: every static-decision round, method-call trial and
trait monomorphization is a whole-program build. So every per-build
inefficiency is multiplied by the build count.

| # | Item | Kind | Evidence | Effort |
|---|---|---|---|---|
| 1 | Semantic instances copy the whole HIR per walk and per view | O(instances x program) | callables.bot front end 28.6 -> 14.5 s with the prototype; growth exponent 2.04 -> 1.08 | prototype exists (branch `ccr-7eabe55c-semantic-in-place-views`) |
| 2 | Trait-polymorphic calls get unbounded abstract-view instances | O(N^2) instances, about N^4 time | *measured here*: a chain of 160 functions has 12,880 instances and takes 42-54 s | small to medium |
| 3 | Named functions are walked 2-3 times, nested ones 2^depth | exponential in nesting | callables.bot: 160,030 -> 61,481 expression evaluations | small |
| 4 | `hir::lower` rescans the affine tables per call node; the Tcl compiler re-lowers every block body | quadratic | 583 s corpus-wide; 718 calls taking 0.67 of 0.80 s | trivial (first half) |
| 5 | Hygiene rescans every binding and expression per rename | quadratic | 11% of the front end | small |
| 6 | `hir::contexts::Walk` rebuilds the same maps about 10 times per build | repeated work | 9.4% of representation.bot | small |
| 7 | `Conjuncts` re-walks an `and` chain at every level | quadratic | a 900-conjunct chain costs 170-260 s | small |
| 8 | The signature fixpoint's second round re-types the program to confirm unchanged seeds | 2x typing | round 2 is 51-62% of typing | medium (needs incremental re-typing) |
| 9 | A demoted contract re-runs `CheckOnce` | 2x check, less its unseeded prefix since 3.9's reuse | about 21% of callables.bot; a demoting mutable-array.bot check 12.7 -> 10.4 s with the reuse | prefix reuse done; the rest needs incremental analyses (large) |
| 10 | Library modules are re-analysed in every build | per-build | about 0.5 s x 329 builds, about 165 s | large (needs 4.1 first) |
| 11 | Method-call trial builds | whole builds | 81 of 328 corpus builds; mutable-array.bot 14 of 20. No configuration built twice since: 67 trials + 15 finals of 352, mutable-array.bot 12 of 18. The kind filter decides most of them without trials: METHOD-DECISION-FILTER.md | filter done; the calls it hands over still need a locality theorem (3.10) |
| 12 | Native NIR lowering copies the program per instance view | O(instances x program) | 36% of suite time (TEST-SUITE-COST.md) | large |
| 13 | The erased-callable static walk runs two or three times per build | repeated work | about 3% of a front end | small |
| 14 | Static-decision bookkeeping scales super-linearly in sites | O(S^2)-O(S^3) per round | under 1% today; 9.7% at 500 blocks | small to medium |

Correctness defects found alongside (section 4), all fixed now:

- a struct declaration leaked from one compilation into the next in the same process, and so did error and source-type declarations into a program declaring none (4.1; fixed);
- a dead call of a trait-polymorphic function failed compilation with TRAIT-INSTANCE-BUDGET (4.2; fixed);
- a deep semantic-instance request could be declined by rejecting another site (4.3; fixed by the C:plan port);
- deep static call chains exceeded Tcl's recursion limit in the completion analysis (4.4; fixed).

## 2. Where the time goes

- **Suite time (TEST-SUITE-COST.md section 1, 4,811 s).**
  - Tcl native lowering (`native::lowered`): 36.2%.
  - Front end: 28.0%.
  - Reference execution: 16.4%.
  - The `botlish-native` process: 4.0%.
  - `hir::lower`: 0.2%.
- **Golden suites (LARGE-SCALE-GOLDEN-MIGRATION.md, "Where a suite's time goes", 88 suites, 4,790 s).**
  - Front end: 1,518 s.
  - `hir::lower`: 583 s.
  - Tcl compiler code generation: 1,099 s, measured before main's 14a1143.
  - Cranelift NIR lowering: 396 s.
  - Cranelift code generation: 6.6 s.
  - Native execution: 0.09 s.
- **Front end by phase** (same document; self time):

  | Phase | Share of the front end |
  |---|---|
  | signatures | 38.2% |
  | semantic-instances | 12.6% |
  | hygiene | 11.2% |
  | errorsets | 7.7% |
  | static-decisions | 6.4% |
  | affine | 4.2% |
  | static-deps | 3.1% |
  | parse | 3.1% |
  | resolve | 2.8% |

  `bench/golden-suites.tcl` does not profile `hir::types::infer` or the semantic layer's Walk/Call/Analyze. Their time is charged to "signatures". It does not profile `hir::BuildFull` either, so per-build elaboration lands under "static-decisions".
- **Per build.** Building is now the whole cost (STATIC-DECISION-ECONOMICS.md, point 72). `BuildOnce` plus `BuildFull` are about 76-83% of the front end (`study-frontend-coupling.json`).
- **Golden suites on main (*measured here*, batched, 88 files).**
  - 210 rounds and 321 builds, about 1,000 s of front end.
  - Largest suites:

    | Suite | Front end | Rounds / builds |
    |---|---|---|
    | mutable-array.bot | 181.5 s | 5 / 20 |
    | destructuring.bot | 59.3 s | 5 / 7 |
    | structs-and-enums.bot | 45.5 s | 4 / 17 |
    | static-compile.bot | 43.3 s | 7 / 14 |
    | opaque.bot | 41.4 s | 8 / 12 |
    | methods.bot | 40.9 s | 4 / 6 |
    | stdlib-namespaces.bot | 40.7 s | 3 / 9 |
    | traits.bot | 38.0 s | 8 / 13 (5 / 10 with the C:plan port) |

  - mutable-array.bot costs about 9 s per build. Its builds are mostly method-call trials (item 11), and each build pays items 1, 3 and 5.
  - Since a decision builds no configuration twice (3.10), mutable-array.bot takes 5 rounds and 18 builds (12 of them trials).
  - Re-measured on a39f9dc (other jobs on the same cores): mutable-array.bot's front end is 298 s over its 20 builds. 16 of those builds demote a contract and check twice (item 9), at 13-18 s of check each against 6.5-7 s in the others. With 3.9's reuse the front end is 271 s.
  - Both changes together (3.9's reuse and 3.10's one build per configuration), side by side with a39f9dc on the same loaded cores: mutable-array.bot's front end 265.5 s -> 216.1 s, 5 rounds, 20 -> 18 builds (14 -> 12 trials). Its final HIR is byte-identical to a39f9dc's, also with both audits on (`hir::methodBuildAudit`, `hir::recheckAudit`: 17 demoting checks compared).

## 3. The backlog, in detail

### 3.1 Semantic instances copy the whole HIR (O(instances x program))

- **Where.**
  - `hir::semantic::Walk` (`hir/semantic.tcl`): the scratch HIR is the base HIR, so the first write duplicates `exprs`.
  - `hir::semantic::View`: once per used instance, from verification and from the trait plan.
  - The code-generation specializer does the same (`hir/specialize.tcl`: Analyze, Reanalyze, View).
- **Evidence.**
  - LARGE-SCALE-GOLDEN-MIGRATION.md, item 1.
  - `study-semantic-instances.json`; `study-type-inference.json`: callables.bot's Analyze self time is 8.7 s, 3.41 s of it the `exprs` copy, for an average walked region of 21 expressions in a 5,271-expression program.
  - Synthetic K-unit programs (`study-frontend-coupling.json`):

    | K | 25 | 50 | 100 | 200 |
    |---|---|---|---|---|
    | instances on | 0.79 s | 1.91 s | 8.65 s | 38.29 s |
    | instances off | | 0.95 s | 2.13 s | 4.39 s |
- **Fix.** The branch `ccr-7eabe55c-semantic-in-place-views` walks and views in place with region save/restore.
  - Its final HIR is byte-identical on the whole corpus.
  - Its results: callables.bot 28.6 -> 14.5 s, traits.bot 48.7 -> 34.7 s, growth exponent 2.04 -> 1.08.
  - The staged plan is in `study-semantic-instances.json`, item 3: in-place walks, Apply/Unapply views, indexes, then the specializer.
- **Validation.**
  - The semantic-instances, traits, affine and static-economics harnesses.
  - The branch's check mode: byte-identical HIR.
- **Do first.** It has the largest measured effect, and a verified prototype exists.

### 3.2 Unbounded abstract-view instances for trait-polymorphic calls (new)

- **What happens.** Every function's generic walk requests an instance for each call of a trait-polymorphic function. Inside a trait-polymorphic function `f`, the argument is `f`'s own *abstract* view (`{trait T {param e i}}`). So the request is keyed by `f`'s parameter, not the callee's.
  - In a chain `f1 -> f2 -> ... -> fN` of trait-polymorphic functions, each `fk`'s generic walk instantiates the whole rest of the chain for its own view: N(N+1)/2 instances, all but N of them abstract.
  - The plan clones only concrete witnesses. The abstract instances are typing work that nothing downstream uses beyond the generic result.
- **No budget bounds this.** A trait-polymorphic request past `maxPerBlock` (16) or `maxInstances` (2000) is re-keyed by its views and granted (`hir::semantic::Call`). Abstract views of different callers stay different keys, so the re-key merges nothing. The same re-keyed path also skips the nesting check.
- **Measured here** (chain programs, main; generator in section 6):

  | N | instances | front end |
  |---|---|---|
  | 10 | 55 | 0.08 s |
  | 20 | 210 | 0.13 s |
  | 40 | 820 | 0.34-0.52 s |
  | 80 | 3,240 | 2.8-3.3 s |
  | 160 | 12,880 | 42-54 s |

  Doubling N multiplies the time by about 15 at the top. That is the quadratic instance count times item 3.1's per-instance copy.
- **Not reached by the golden suites.** Their deepest trait-polymorphic nesting is 1 (*measured here*). It is reached by any library of layered generic helpers.
- **Fix, either way.**
  - Key an abstract-view request by the *callee's* abstract view, so one instance per callee serves every abstract caller. All abstract views of one trait are interchangeable up to renaming, which needs care for multi-parameter witnesses.
  - Or do not request an instance for an all-abstract entry at all: the generic walk of the callee already is that analysis, as for a `trivial` request.
- **Validation.** Check the trait plan's clones are unchanged with `tests/traits.test`, `audit/traits/tools/{fuzz,mutate}.tcl` and the context-trait harnesses.

### 3.3 Named functions are walked two or three times, nested ones 2^depth

- **Where.** `hir/types.tcl`, `hir::types::Block`: `set attempts [expr {$self eq "" ? 1 : 3}]`. Every bound block with a non-`never` result is walked at least twice, so a body nested d bound functions deep is walked about 2^d times.
- **Evidence** (`study-type-inference.json`).
  - harness.bot: 164 redundant second attempts, all reproducing the first.
  - loops.bot: expression evaluations 30,364 -> 12,632.
  - callables.bot: 160,030 -> 61,481; its signatures phase 10.4 -> 7.5 s alone, and 4.1 -> 2.1 s on top of 3.1.
- **Fix.** One attempt unless `self` is among the region's captures or static references, with the exactness guard of the study's Stage 4. The study verified identical final HIR on 6 suites.

### 3.4 `hir::lower` and the Tcl compiler's per-block lowering

- **`hir::lower` (quadratic).** `hir::lower`'s Pending and list-loop cases call `hir::affine::temporaries` (`hir/affine.tcl`) per call or struct node. That procedure rebuilds the set of construction operands from the affine `releases`/`exits`/`errorExits` tables every time.
  - Evidence: 0.29 of 0.30 s of lowering on traits-path.bot; 583 s corpus-wide (LARGE-SCALE item 3).
  - `compiler/compiler.tcl` and `native/lower.tcl` already compute it once. The fix is to compute it once per lowering.
- **The Tcl compiler (O(size x depth)).** `core::compiler::CompileBlock` lowers every block body with `hir::lower::body`, the nested ones again inside each enclosing block. Each nested block's Core IR is embedded as a literal in every enclosing block's generated source.
  - Evidence: `compileHir` makes 396 `temporaries` calls on traits-path.bot after 14a1143; the study counted 718 calls taking 0.67 of 0.80 s.
  - Fix: the quadratic factor goes with the first fix. Then memoize lowered bodies by expression id, or emit nested blocks by reference.

### 3.5 Hygiene rescans per rename

- **Where** (`hir/hygiene.tcl`).
  - `Rename` rebuilds the used-name set from all bindings and expressions.
  - `RenameTo` scans every expression and copies `exprs`.
  - `qualifyModules` calls `RenameTo` for every module top-level binding, in every build.
- **Evidence.**
  - 11% of the front end corpus-wide.
  - errors.bot: 153 `RenameTo` calls, 524 ms (10.4%).
  - A minimal program does 42 renames.
- **Fix.** Build a binding -> references index and a used-name set once and update them incrementally. Do `qualifyModules` in one pass with a binding -> name map.
- **Caution.** Hygiene's `NAME#N` numbering is read by the static decisions (`se-equal-hygiene-*`). The numbering must stay what it is.

### 3.6 `hir::contexts::Walk` repeated about ten times per build

- **Where.** Called from `hir/mutvec.tcl` (5 sites), `hir/affine.tcl` (2), `hir/coroutines.tcl` (2) and `hir/contexts.tcl`, each rebuilding the same parent maps.
- **Evidence.** representation.bot: 20 calls in 2 builds, 298 ms (9.4%). harness.bot: 118 ms (7.4%).
- **Fix.** Memoize per build. Invalidate it at the structural rewrites (`mutvec::Elaborate`, view application).

### 3.7 `Conjuncts` is quadratic in an `and`/`or` chain

- **Where.** `hir::completions::Conjuncts`, reached four times per `if` level through `BranchOutcome` and `BranchRelations`. The parser builds `a and b and ...` left-deep, so every level re-walks the rest of the chain.
- **Evidence.** A ~900-conjunct chain (150 CSV reference rows) costs 170-260 s of front end (TEST-SUITE-COST.md 3.3). `tests/native-csv-records.test` still builds it.
- **Fix.** Memoize per (condition, outcome) within the pass, or compose the facts bottom-up.

### 3.8 The signature fixpoint's confirming round

- **Where.** `hir/signatures.tcl` runs a full `hir::types::infer`, every semantic instance included, per round.
- **Evidence.** Every observed call took exactly two rounds. Round 2 reproduced round 1's seeds and cost 51-62% of the typing time (`study-type-inference.json`).
- **Fix.** Re-type only the blocks whose seeds changed, and their dependents. That needs incremental re-typing, because a seeded block's exact type embeds its contract.

### 3.9 The demotion re-check

- **Where.** `hir::check` (`hir/hir.tcl`) checks a program a second time whenever its first check finds a call or an erasure that violates a trusted inferred contract. The second check demotes those parameters to checked-only. The HIR keeps the first check's diagnostics and `beforeCompletions` and everything else from the second.
- **Evidence.**
  - About 21% of callables.bot once items 3.1 and 3.3 are fixed.
  - mutable-array.bot (*measured here* on a39f9dc, before the change below): builds 2-17 each demote two parameters, until round 2 rejects the two blocks that cause it. The parameter is the untyped `fwd(xs)` of `mat-bd-1/wrong-element` and `mat-bd-1/raw`, inferred `MutableArray[str]` and called with an `int` array and a raw one.
  - Each of those builds ran `CheckOnce` twice and `hir::types::infer` four times: 13-18 s of check in a 14-20 s build. Builds 18-20 checked once, in 6.5-8 s.
  - Any program with such a negative test pays the second check in every build until the block is rejected.
- **Done: the second check reuses what the demotion cannot change.**
  - The coroutine protocols are a function of the HIR alone. `hir::check` infers them once, before both checks.
  - A round of the signature fixpoint is a function of the HIR and the round's seeds alone, and the demotion only filters the seeds a round hands to the next (`hir::signatures::infer`).
  - So the first check records every round it does not converge on, keyed by the round's seeds, and the second check takes a round from that memo whenever it reaches the same seeds. It always reaches the first round, which is unseeded.
  - It also reaches a later round when the demoted contract first appears in that later round, for example a callable contract that only the body's seeded types make inferable. Then the second check may type nothing new.
  - Everything from the second check's first newly seeded typing on reads the demoted contracts, so it runs again.
  - The memo belongs to one `hir::check`, so it covers one HIR. Nothing else is shared, and nothing in the HIR changes: the result is the same by construction.
  - `hir::recheckReuse 0` makes the second check from the start, sharing nothing.
- **Effect** (*measured here*, a39f9dc, with the other agent's jobs on the same 4 cores; paired runs of the two trees, side by side):
  - mutable-array.bot's build-2 check, captured and replayed 3 times alternately: 12.3-13.4 s -> 9.8-10.9 s (means 12.7 -> 10.4 s, -18%).
    - `hir::types::infer` runs 3 times instead of 4.
    - The second check alone takes 3.8 s instead of 5.4-5.8 s: one typing with its solve (1.6 s), the semantic instances (0.8 s), the completion walk (0.6 s) and the rest (about 0.8 s).
  - mutable-array.bot, whole front end: 298 -> 271 s (-9%). The checks of builds 2-17 add up to 237 -> 201 s.
  - callables.bot (one demoting build of three), 3 paired runs:
    - its demoting build 9.2-9.4 s -> 6.9-8.2 s (means 9.3 -> 7.7 s, -17%);
    - front end means 17.9 -> 16.2 s (-10%).
  - Peak RSS grows by the round the memo keeps through the first check: 324 -> 349 MB on mutable-array.bot, 171 -> 189 MB on callables.bot.
- **Validation.**
  - `audit/demotion-recheck/tools/audit.tcl` sets `hir::recheckAudit 1`, which makes every demoting check from the start as well and fails on any difference (`hir::AuditRecheck`). Over the 129 golden suites, examples and benchmarks, 9 suites demote in 37 checks (mutable-array.bot 16, refinements.bot 7, framework-semantics.bot 5). Every one gave the same HIR.
  - The final HIR of each of the 129 programs is byte-identical to the one the tree before the change gives, once the tree's path is normalized and the decisions' timing (`depMs`) is zeroed.
  - Tests: `se-demotion-recheck-identical`, `-economics` and `-audit` in tests/static-economics.test. Their programs cover three cases: a second check that reuses only the first round, one that reuses the first two rounds, and one that reuses the first round and then types a round of its own.
  - Mutants: `recheck-round-by-number`, `recheck-rounds-across-checks`, `recheck-rounds-not-shared` and `recheck-analysis-repeated` in audit/static-decisions/tools/mutants.txt.
- **What is left, and why it is not done.**
  - The second check still runs its seeded typing and every analysis after it: about 3.8 s of a demoting mutable-array.bot build.
  - On that build the two checks' HIRs differ in only:
    - four expressions (the two `fwd` blocks' contracts and two types);
    - two interned type forms;
    - the semantic-instance table.
  - So re-checking only what the demotion reaches would remove most of the 3.8 s. It is not done because nothing after the first typing is local to a region today:
    - Typing interns types in walk order, so a region typed again must keep every later id.
    - The analyses read other functions' contracts across calls:
      - `verifyDeclaredParams` checks every call of a demoted function;
      - the semantic instances analyse every caller;
      - the completion walk reads callee summaries, and the erased-callable contract, which `hir::completions::InstanceErasures` computes from every instance of an uncontracted parameter: a demotion can widen it and change verdicts anywhere in the program;
      - the ownership analysis gives a whole-program verdict.
    - Each analysis would need a region re-run and a proof that nothing outside the region reads what changed. That is the incremental re-typing of 3.8, and the same for every analysis after it.
  - Skipping each check's discarded half phase by phase is not sound either:
    - The first check's diagnostics come from every phase, and every one is read (the static decisions read every diagnostic).
    - The second check's annotations read its own diagnostics: `hir::semantic::verify` sorts an instance's diagnostics against the generic ones into `semantic status`, and the ownership analysis computes release scopes only for a program it accepts.
  - Detecting the violation earlier does not help, because both checks' complete results are needed whenever it is found.
- **Coupling.** `hir/staticdeps.tcl` reads the HIR this produces, so it needs the static-decision harnesses (tests/static-economics.test, `se-property-demotion-keeps-diagnostics` and `se-demotion-recheck-*`; the `recheck-*` mutants).

### 3.10 Per-build re-analysis: library modules, method trials, the trait rebuild

- **Library modules.**
  - Every build re-resolves and re-analyses every imported module (`hir::BuildOnce`).
  - Cost: about 0.5 s per build for about 1,450 library expressions, about 165 s over the corpus's 329 builds. `stdlib/test.bot` alone is about 75 s.
  - Reusing an unchanged module's analysis within one compilation needed compilation isolation first. That is done (COMPILATION-ISOLATION.md): a HIR carries the declaration state its backends need. Reuse across builds still has to partition that state by owner namespace.
- **Method-call trials.**
  - 81 of the corpus's 328 builds are trials (`hir::DecideMethodCalls`). mutable-array.bot has 14 trial builds of its 20.
  - The remaining trials are ones the dependency analysis does not cheapen.
  - Deciding a candidate by re-typing only the enclosing function region, falling back to a whole build only when the choice changes a cross-function fact, would remove most of them.
  - **Since then** (STATIC-DECISION-ECONOMICS.md, "Within one decision: no configuration built twice"): a decision builds no configuration twice. A pass of a receiver chain whose decided links all chose the t-th candidate leaves the next pass's trial t a configuration already built, and the decision reads it from a record of that build. Measured on `a39f9dc`'s corpus (129 programs: the 88 golden suites, the examples and benchmarks; 371 builds): 81 trials and 20 final builds became 67 and 15, 371 builds 352; mutable-array.bot 14 + 1 -> 12 + 1 (20 -> 18 builds; front end 292 -> 264 s, the two trees compiling it side by side beside two other jobs), imports.bot 11 + 1 -> 7 + 0, refinements.bot 5 + 1 -> 3 + 0, mutable-vector.bot 7 + 1 -> 4 + 1, ownership.bot 5 + 1 -> 3 + 1. Every program's final HIR, diagnostics and decisions are identical.
  - That is the fewest whole builds the trial rule admits without a locality theorem: a build is the only way to learn what a configuration reads, and each one read is now built once. Fewer builds, or region-local trials, need a theorem that a call's trial reads depend only on some calls' candidates or some functions, and the checker makes that false in general: the demotion re-checks the whole program when a trusted contract is violated (every trial of mutable-array.bot's first checked round demotes two), and the ownership verdict, the erased-callable contract, the instance budget and inferred parameter contracts are whole-program facts a candidate swap can change. The dependency analysis models those for rejections, through witnesses that rely on a rejection being monotone; a candidate swap is not. Even with such a theorem, a chain link with n candidates needs n - 1 new configurations: mutable-array.bot's five passes need at least 10 trials, against the 12 made now. The lever left is the cost of a trial: re-checking only what a choice changes, under the same theorem.
  - **Since then, the kind filter** (METHOD-DECISION-FILTER.md): a call whose receiver's kind leaves one candidate is decided without trying the others, one build per link of a chain; the result is certified and equal to the exact decision's, and what it cannot settle (an untyped receiver, a lexical candidate, no applicable method) is made by the exact decision. The "n - 1 configurations per chain link" above is the floor of deciding by trial, not of deciding.
  - **Since then, one decision procedure** (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md): the exact decision misattributed diagnostics (EXACT-METHOD-DECISION-MISATTRIBUTION.md), so the filter and the exact decision were replaced by one procedure whose verdicts are a call's own checks, certified relative to the decided configuration (`hir/methods.tcl`); the filter's exclusions are its kind proofs. Its cost is a single deviation per candidate the kind proofs leave, not a trial per candidate index; its report's "Economics" has the corpus measurements.
  - Not done: reusing an *older* build of the final configuration as the final one (mutable-array.bot's final is pass 3's trial 1, built again). A build leaves state in namespace variables besides the registries `hir::activate` restores (analysis caches and scratch state), a later trial's would be left behind the reused program, and the code that runs after a decision (`BuildFull`'s elaborations, hir/static.tcl's attribution and dependency analysis, the warnings) has not been audited for reading it. At most one build per decision with trials (15 finals in the corpus after).
- **Trait monomorphization.**
  - `hir::traits::monomorphize` is a second full `BuildOnce` per round, and the result keeps `traitSource` (half of a small suite's 1.4 MB HIR).
  - Skipping the rebuild when the plan clones nothing and redirects no call is a cheap first step. It has not been verified.

### 3.11 Native NIR lowering

- **Evidence.** 36% of suite time (TEST-SUITE-COST.md); 0.7 s even for ten trivial cases (GOLDEN-TEST-FRAMEWORK.md).
- **Status.** Per-instance views were memoized (4ca69cb), but each still copies the program (`hir/specialize.tcl`, `View`). The memo keeps every view alive: peak RSS reaches 1,567 MB on destructuring.bot.
- **Fix.** An overlay or apply/restore working HIR, which is Stage 7 of the plan in item 3.1, and sequentializing the analyses that hold all views at once.

### 3.12 The erased-callable static walk, computed repeatedly

- **Where.** `hir::completions::staticsOf` runs through the completion pass, again through `erasureFacts` (`hir/affine.tcl`), and a third time from the legacy scheduler's `GlobalChannels`.
- **Evidence.** 0.13-0.27 s per suite, about 3% of a front end (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md section 37).
- **Fix.** Compute it once in `CheckOnce` and keep it as a HIR side table.

### 3.13 Static decisions

Batched decisions cost a few percent of a front end today. What remains:

- **Bookkeeping that grows super-linearly in sites** (code reading; under 1% at golden sizes).
  - `hir::static::Waits` scans every status for each failing site, and `Simulate` repeats it per committed rejection: O(S^2) per step.
  - `Attribute`/`Owner` scan the sites per diagnostic: O(D x S). An interval index over the sorted spans gives O(D log S).
  - `hir/staticdeps.tcl` unions every successor SCC's site set, about O(E x S). At 500 blocks the analysis is 2.0 s of a 20.9 s front end, 9.7% (STATIC-DECISION-ECONOMICS.md).
  - Bitset site sets, or computing only what `Simulate` queries, fix this.
- **Rounds at the ceiling.** `tests/golden.test`'s `golden-static-economics` allows 8 rounds.
  - opaque.bot sits at 8 (8 / 12).
  - traits.bot sat at 8 / 13 until the C:plan port (5 / 10).
  - The remaining cost is the component rule: a site that turns unknown holds back the later failing sites of its component. "Finer components" (point 72) is the open optimization.
- **The audit's sequential reference.**
  - `compare.tcl` against `sequential` is one build per rejection. On an earlier tree (*measured here*, before main's latest merge, indicative): destructuring.bot took 69 rounds / 205 builds, 3,347 s. mutable-array.bot did not finish in 3 hours.
  - A full-corpus comparison is therefore impractical, and the audits sample it. Items 3.1 and 3.3 shorten every one of those builds.
- **An analysis worth tightening.** The semantic layer's `End` and verification steps scan all calls per used instance: O(used x calls), and O(rounds x calls x used) in verification. Cheap at today's sizes, but bounded only by the 2000-instance budget, which item 3.2 shows trait-polymorphic requests escape.

### 3.14 Smaller suspects (code reading, not measured)

| Where | Suspected cost | Fix |
|---|---|---|
| `hir/specialize.tcl` view memo: `$hir eq $memoHir` | O(1) only for the identical Tcl object; otherwise both whole HIRs are stringified | compare a generation token |
| `hir/specialize.tcl` Fixpoint | rescans the queue for the newest id on every pop, O(Q^2) | a priority structure |
| `hir/semantic.tcl` Requeue/Drain | `in`/`ni` on list queues | dict membership |
| `hir/affine.tcl` verifyInstance | a full `contexts::Walk` of the view per affine-argument instance | share the walk (3.6) |
| `hir/hir.tcl` MethodCallProblems | a subtree walk and a diagnostics scan per undecided call per trial | index diagnostics by expression (done: `hir/methods.tcl` indexes them by subject once per build) |
| `hir/coroutines.tcl` RefsOf | a full expression scan per yield site | one pass |
| `hir/mutvec.tcl` Elaborate | `ni $roots` inside a loop over all bindings | a dict |
| `compiler/compiler.tcl` | the code cache is keyed by full Core IR text and never evicted; unit procs are never deleted | bound the cache, delete procs after a run |

## 4. Defects found on the way

### 4.1 A declaration leaks from one compilation into the next (fixed)

*Measured here.* In one Tcl process, compile `tests/golden/affinity.bot`
(which declares `struct Query`), then `tests/golden/refinements.bot` (which
declares `refined type Query = str` and `refined type Encoded = Query`).
The second fails:

```
refinements.bot:61:24: invalid refinement carrier Query for "Encoded":
Query is a stable value type, but refinements of aggregate, struct or
callable values are not supported yet ...
```

Alone, or after errors.bot or coroutines.bot, refinements.bot compiles
(3 rounds / 10 builds); through `tests/golden/run.tcl` it passes, 66 of 66.
The `Query` that `Encoded` resolves to is affinity.bot's struct.

The minimal pair: compile `struct Query: v: str` first, then

```
refined type Query = str
refined type Encoded = Query
struct R:
    x: int
```

The second program fails the same way; without its `struct R` it compiles.

The cause is the order of two steps. `hir::sourcetypes::apply` resolves the
refinement carriers first. Only after that does `hir::structs::apply`
replace the struct registry with this program's structs. While the carriers
are resolved, the previous compilation's structs are still registered.
`hir::BuildOnce` calls `hir::structs::Reset` only for a program that
declares no structs, so a program declaring none is not affected.

The fix is to drop the previous registration at the top of
`hir::sourcetypes::apply`, where `Reset` already reclaims the
`core::type`/`core::native` entries, rather than in `hir::structs::apply`.
The fix also needs a regression test that compiles the pair in one process.

**Fixed.** `hir::sourcetypes::Reset`, which `apply` calls before resolving
any declaration, now also clears the struct registry (`hir::structs::Reset`).
The HIR-text path (`hir::read`) was never affected: it reads resolved
carriers. Evidence:

- affinity.bot then refinements.bot in one process: both compile (11 s and
  39 s).
- A pairwise harness compiled every ordered pair of small programs declaring
  `X` as a struct, enum, refinement, integer domain, trait or error, each
  with an extra declaration (none, a struct, an enum, a refinement, a
  refinement over `X`, a struct field of type `X`, or both of the last two),
  comparing each second program's outcome with its outcome after the first.
  Before the fix 28 pairs differed, every one a `struct X` followed by a
  program naming `X` as a carrier and declaring a struct. After it, none.
- `tests/source-types.test`: `source-type-struct-registry-reclaimed-before-carriers`
  (the minimal pair) and `source-type-struct-registry-isolation-kinds` (the
  four kinds of `X` a carrier can name, alone and after `struct X`). Both
  fail without the fix.

Two more declarations leaked forward the same way, into a program that
declares none of its own (LARGE-SCALE-GOLDEN-MIGRATION.md, "Found, not fixed:
compilation isolation"). After a program declaring `error Boom` or `type
Small = Int in 0..9`, a program using `Boom` or `Small` without declaring it
compiled against the earlier declaration. Both registries kept their
contents for a compilation that brings no declarations, which is what core
IR text needs (`hir::build` passes none, and its nodes may name the program
it was lowered from). A frontend's program now resets them:
`hir::BuildOnce` calls `hir::errordecls::Reset` when `-error-decls` is given
and `hir::sourcetypes::Reset` when `-type-decls` is, as it already reset
structs and enums. `source-type-declarations-do-not-leak-forward` pins all
six kinds (error, integer domain, refinement, enum, trait, struct): each use
is rejected as unknown right after a program that declares it. The error and
source-type cases fail without the fix.

The rest of compilation isolation was closed afterwards: the registries are
still process-global, but every HIR records the state its build left behind
and every backend entry point re-activates it, so an earlier HIR's backends
no longer read what a later compilation registered (COMPILATION-ISOLATION.md).

Why it matters beyond the failure:

- Any tool that compiles several programs in one process can mis-compile, not only slow down: the warm runs of `bench/golden-suites.tcl -warm N`, the audits' and fuzzers' loops, and `tests/golden.test`'s runner.
- It is a concrete instance of LARGE-SCALE-GOLDEN-MIGRATION.md's recommendation 2, compilation isolation, once thought "plausibly the cause" of the unexplained process-history slowdown (pass 2 of the golden suites takes 2,440 s against 2,055 s for pass 1 and 1,518 s cold). The investigation behind COMPILATION-ISOLATION.md found it is not: the slowdown appears with a fresh child interpreter per compilation too, and this container's timings drift about 12% across fresh processes.
- Item 3.10's module reuse needed isolation first (now in place).

### 4.2 A dead call of a trait-polymorphic function fails compilation (fixed)

```
fn mk() errors std::compiler::CompilerError:
    static compile:
        Square {side: want_int("s")}     # rejected: mk() is `never`

fn use() -> int errors std::compiler::CompilerError:
    measure(mk())                         # measure(s: Shape) -> int
```

- **What happens.**
  - Once the static block is rejected, `mk()` has type `never`, so `measure(mk())` is a dead call. The semantic layer does not request an instance for it.
  - The trait plan then reports TRAIT-INSTANCE-BUDGET: "the compiler's semantic-instance budget declined it". That is false; no budget was involved. The program does not compile, although the call can never run.
  - A `never` argument arises only from a rejected site's reified failure. Any other always-failing call is a KNOWN-ERROR first.
- **Why the obvious fix is wrong.** The plan's `unreachable` action is not a fix. It replaces the call by `context#unreachable()` and drops the arguments, but the arguments must still run, because the `never` one is what raises the error.
- **Correct fixes.**
  - A plan action that keeps the arguments' evaluation and replaces only the call itself, for example a sequence of the arguments followed by `context#unreachable()`.
  - Or request an instance even for a dead call when the callee is trait-polymorphic.
- **Coupling.** `tests/static-economics.test`'s `se-equal-plan-unplanned` pinned the gate on exactly this diagnostic: a fix changes that test's last outcome to `accepted`, and the test then needs another call without an instance. Run the trait harnesses (`audit/traits/tools/{fuzz,mutate}.tcl`) too.

**Fixed**, by the first of the correct fixes:

- The plan gives a dead call with no instance the `dead` action (`hir::traits::DeadCall`: the callee or an argument has type `never`).
- Build 2 resolves it to a call of `context#unreachable` with the call's own arguments, the receiver of a method call first (`hir::resolve::ResolvePlannedCall`). The arguments run in order up to the one that raises.
- The placeholder now takes any number of arguments (`-arity *`) and moves an affine one as the replaced call would have (`-ownership {move}`). Native lowering evaluates its arguments before the trap. The Tcl backends needed no change.
- A function that only dead calls reach gets no clone.

The example above now yields -1 on interp, compile, cranelift, cranelift-generic and as a standalone executable, also under `BOTLISH_NATIVE_GC_STRESS=1`. So do these variants:

- the never argument in a non-trait parameter;
- method syntax on a never receiver;
- a dead call inside a clone;
- an argument with a side effect before the never one (it runs once per call);
- a MutableArray argument;
- a coroutine handle argument.

The affine analogue (AFFINE-INSTANCE-BUDGET) does not arise: a generic function becomes a specialization candidate only through an instance, and a dead call requests none.

Tests and mutants:

- `tests/traits.test`'s `trait-dead-call-keeps-arguments` covers the variants on all four backends. It fails without the fix.
- New trait mutants `dead-call-budget` and `dead-call-drops-arguments`; that test kills both.
- `se-equal-plan-unplanned` now pins `use` accepted, the batched decisions equal to the sequential ones, no misprediction.
- `hir::staticdeps::Unplanned` still counts a dead call as a consumer of the plan's gate. That is an over-approximation, and costs the test nothing (3 rounds / 4 builds either way).
- The static-decision mutant `plan-unplanned-ignored` was removed. It ignored what is now only a nesting decline, which no deterministic test builds (STATIC-DECISION-ECONOMICS.md, "Trait-polymorphic calls with their instances").

### 4.3 A rejection could make a cached deep request the first one, which the nesting limit then declines (fixed)

The semantic layer declines a request for nesting only when it is the first
for its instance; a cache hit is never declined. Rejecting the site that made
the shallow first request therefore made a deep request the first, which was
then declined. The dependency analysis saw no pressure on the budget, so the
batched scheduler predicted the deep site ok and the next build contradicted
it (`se-equal-deep-first-request`, mispredicted on main).

The fix is the C:plan port's `deep` record: every request at half the nesting
limits or deeper puts the instance budget under pressure. No golden suite
comes near that depth: the deepest request is at stack 7 and Tcl level 75,
against 12 and 350.

A related gap stays open. A trait-polymorphic or affine request past the
per-block or total budget is re-keyed and granted without the nesting check,
so nothing bounds those requests' count or depth. That is item 3.2. Chains of
160 functions still compile at Tcl's default recursion limit, but the limit is
not enforced. Since 4.4's fix the front end runs with a recursion limit of at
least 100000, so the depth such a chain would need to fail is far beyond
what item 3.2's growth lets compile at all.

### 4.4 Deep static call chains exceed Tcl's recursion limit (fixed)

A known issue, open until this fix. `hir::completions::EffectiveFacts` has a cycle
guard and an analysis budget but no depth bound, and no compiler entry point
raises `interp recursionlimit`. A 105-function chain compiles and a
120-function one does not (RANGE-FIXPOINT-SCALING.md section 6); item 3.7's
left-deep chains are another source of depth. Fix with a depth bound that
falls back to the declared contract, plus a raised limit or an iterative
walk. The completion verdicts feed NIR, so this needs its own audit.

**Fixed**, with a depth bound and a scoped raised limit
(RANGE-FIXPOINT-SCALING.md section 6, "Fixed since"):

- `hir::completions::maxDepth` (1024 nested analyses). Past it, `EffectiveFacts` returns the declared-contract fallback a cycle gets. It counts analyses, not frames, so verdicts do not depend on the caller's stack or limit. (`maxAnalyses` never bounded depth: every nested walk starts its own count.)
- `hir::Deep` raises the recursion limit to at least 100000 around `hir::buildSyntax`, `hir::check` (`native::prepareHir` calls it directly) and the warning passes, which repeat the completion walk (`hir::completions::reachedExprs`). It restores the caller's limit afterwards. A program the Tcl backends then run keeps the caller's limit: `tests/compiler-opt.test`'s opt-tail-2 runs at 1000 by design.
- The audit: the deepest nesting over the 88 golden suites and the 41 example and benchmark programs is 12, so no verdict and no NIR of theirs changes.
- At Tcl's default limit, the 120-, 200- and 400-function chains now compile, and cranelift runs the 400-function one. The interpreter still exceeds the default limit running it: that is the program's own recursion on the reference interpreter, not the compiler's.
- Tests: `tests/range-fixpoint-scaling.test` 3.1-3.3. Each fails with its part of the fix removed.

## 5. Suggested order

1. **Exact, small fixes with large measured effects:** 3.4 (temporaries once), 3.3 (one walk), 3.5 (hygiene index), 3.6 (memoized contexts walk), 3.7 (memoized conjuncts), 3.12 (statics once). Each changes no output: validate by byte-identical final HIR on the corpus, plus the harnesses AGENTS.md names for the area.
2. **3.1**, from its prototype; then **3.2**, which multiplies with it.
3. ~~**4.1 and 4.2**, before anything that compiles many programs per process or reuses analyses across builds.~~ Done.
4. **3.8 and 3.9**, with the static-decision harnesses: both change what a build's HIR holds. 3.9's reuse of the unseeded prefix is done; what remains of it needs the incremental re-typing 3.8 needs, and the same for every analysis after the typing.
5. **3.10** (method trials, then library reuse once 4.1 is fixed) and **3.13**'s bookkeeping.
6. **3.11**, the largest. (**4.4** is done, with its audit.)

CI has no compile-time gate, only build-count guards: `tests/static-economics.test`, `golden-static-economics`, `tests/range-fixpoint-scaling.test` and `tests/hir-specialize.test`. A wall-time job over a fixed corpus (`bench/golden-suites.tcl -backends interp`) would catch regressions in the items above.

## 6. How to measure

All under `LANG=C.utf8 LC_ALL=C.utf8`:

- `tclsh9.0 bench/golden-suites.tcl ?-backends interp? ?-warm N? ?-profile 1? FILE.bot ...` -- per-suite rounds and builds, front end by phase, lowering, code generation, peak RSS; `-warm N` shows the process-history effect.
- `tclsh9.0 bench/static-decisions.tcl ?-parts golden,chain,erased,...? ?-schedulers ...?` -- rounds, builds and method trials per scheduler.
- `tclsh9.0 audit/static-decisions/tools/compare.tcl FILE.bot` -- batched against sequential.
- `staticStats` on a decided HIR (rounds, builds, `mispredicted`); `BOTLISH_STATIC_TRACE=1` for the per-round trace (its `channels` line counts the gate's consumers and the budget's pressure).
- The `semantic` field of a HIR (for a trait program, of its `traitSource`): `instances`, `calls`, `declined`, `deep`, and the `requests`/`hits`/`walks` census.
- The trait-polymorphic chain of item 3.2:

  ```tcl
  set text "trait Shape:\n    fn area(s: Shape) -> int\n\nstruct Square:\n    side: int\n\nfn area(s: Square) -> int:\n    s.side\n\nfn f$n\(s: Shape) -> int:\n    s.area()\n\n"
  for {set i [expr {$n-1}]} {$i >= 1} {incr i -1} {
      append text "fn f$i\(s: Shape) -> int:\n    f[expr {$i+1}](s)\n\n"
  }
  append text "f1(Square {side: 1})\n"
  # surface::compile $text x -strict 0 -warnings off; then
  # [dict size [dict get $hir traitSource semantic instances]]
  ```

- Raw study data: `audit/golden/migration/out/study-{semantic-instances,type-inference,frontend-coupling}.json`, `bench-golden-suites-{cold,warm}.md`.
