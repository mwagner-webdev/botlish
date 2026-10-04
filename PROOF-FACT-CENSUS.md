# Proof/fact census

A census of what the compiler proves today, where each fact is created, how
far it travels, where it is deliberately widened, where it is lost and where
it exists but is not used. It is an investigation, not a redesign: nothing in
the proof system was restructured, and no optimization was added.

The census found **three soundness bugs**, all of them now fixed. Each fix is
narrow, comes with a regression test, and is described in §I. Those fixes are
the only compiler changes made here.

* **Baseline:** `66b52cd` ("Regenerate the scalar assembly audit corpus").
* **Fixes:** the commit after it, "Fix three proof soundness bugs found by
  the proof-fact census".
* **Probes, tools and raw outputs:** `audit/proof-census/` (its `README.md`
  maps each probe to a section below). Every observation was made with the
  compiler of the commit it is quoted against, unless it says otherwise.

Terms used throughout:

* **"range"** is `hir/range.tcl` plus `hir/rangerec.tcl` and
  `hir/induction.tcl`. It is the interprocedural Range fixpoint that native
  lowering reads.
* **"completions"** is `hir/completions.tcl`. It is the completion proof that
  decides which declared errors a call can still produce.
* **R / C** in the tables mean "as range sees it" and "as completions sees it".

---

## A. Executive conclusion

### Is the fact architecture broadly coherent?

**Yes.** Two analyses carry most facts, under two deliberately different
contracts, and both are documented in the code:

| | Contract | Feeds | Granularity | Durable? |
|---|---|---|---|---|
| **range** | Closed-world: facts come from *all known callers* of a closed instance | Representation and code generation: raw ints, decided branches, constant results | Per specialization instance, joined over callers | No: recomputed for each native lowering |
| **completions** | Open-world: each function body must be legal for *any* caller; exact call sites are additionally re-walked under their own argument facts | Legality: `UNHANDLED-ERROR` / `KNOWN-ERROR` | Once per function body, plus a memoized walk per exact call | The final effective set only, stamped on the HIR node |

The two share one Range lattice: join, intersect, comparison narrowing,
`ConstrainType`, arithmetic. Each walks the HIR with its own per-node
transfer rules. This split is intentional, as `hir/completions.tcl:10-31`
explains: a semantic analysis must not move generated code, and code
generation must not decide legality.

Most current behaviour follows from it:

* Facts that reach code generation are **interval facts**: exact Ints,
  intervals, source domains, induction and recursive-result Ranges.
* **Relational and cardinality facts** (`i < list::length(xs)`, String
  lengths, capacities) and **completion verdicts** live only in completions.
  Nothing downstream reads them.

### Are the recent issues isolated gaps or systemic duplication?

**Mostly isolated transfer-rule and consumer gaps, with one systemic
pattern.** completions' `Eval` mirrors range's `Expr` node by node, and the
two copies drift. Three instances found here:

1. `return` values (range joins them; completions dropped them). This was
   soundness bug S1.
2. Projected field domains (range had the rule; completions gained it only
   in the ABI milestone).
3. Counted-loop intervals (range seeds the loop variable; completions does
   not). This is gap G3, still open.

The duplication is at the level of *which node kinds get which rule*. The
lattice operations themselves are shared. That argues for a cross-check
harness (§K), not for merging two analyses that answer different questions.

### Top actual gaps (after the soundness fixes)

1. **G1: proven bounds checks are still emitted.** Nothing after the
   completion proof reads its result. A proven `at`/`set`/slice still lowers
   to the checked op, and the Tcl compiler routes it through its generic
   call.
   * *Measured:* on `bench/refined-checks.bot`, deleting the single
     provably redundant `regioncheck` on its hot path (lib/web.bot
     `char_at`) cuts the run from 612 to 558 µs median, about 9%.
2. **G3: completions does not give a counted loop's variable an interval.**
   `loop i from 0 to 256: byte::from_int(i)` and `abi::u8(i)` are rejected.
   So is `list::at(lit3, i - 1)` over `1..4`. range has the fact
   (`[0, 255]`).
3. **G5: struct field values are never facts**, in either analysis, even
   locally. Only the *declared field domain* survives projection.
   * `p = Plain {index: 1}; list::at(xs, p.index)` needs a handler.
   * `abi::x86_64::from_u64(abi::u64(2^64 - 1))` keeps its comparison.
   * The `from_u64` case is therefore representative of a general
     limitation, not an isolated one.
4. **G2: `loop x in xs` reads every element with the checked `listget`**,
   although the index is in bounds by construction. This needs no proof at
   all.
5. **G9 / G10: two smaller source-friction gaps.**
   * G9: a handled call's value Range is lost at handler exit.
   * G10: parameter contract inference ignores branch narrowing, so
     `fn clamp(n) -> Two` is rejected when called with 5.

### Soundness

**Three bugs, all reproduced on every backend and all fixed narrowly (§I).**

* **S1, completions:** a callee's early `return` value was missing from the
  result Range proved for its call site. A program indexing by such a result
  compiled with no handler, then raised an undeclared `IndexNotFound`.
* **S2, completions:** in a loop over a small literal List, `break` or
  `continue` was read as "the loop never completes", which hid all code
  after the loop from the proof.
  * Unhandled errors after the loop compiled, then failed at run time.
  * Valid calls became false `KNOWN-ERROR`s.
* **S3, range:** the equality-termination induction fact was locked onto
  *open* instances. Native lowering then deleted a branch that runs: wrong
  values on `cranelift-generic`, and on the default backend once a call
  falls back to the generic instance.

S1 and S2 did not become memory errors for one reason only: native lowering
ignores the completion proof (G1) and keeps the run-time check. **Any
milestone that removes checks on the strength of `effectiveErrors` depends on
these fixes, and on the soundness audit staying green.**

### Which gaps affect source semantics?

* **G3:** loop intervals.
* **G4:** descending loops.
* **G5:** local struct field values.
* **G6:** return-value cardinality.
* **G7:** exact List/String values passed through an immutable local.
* **G9:** handled-call values.
* **G10:** contract inference.
* **G13:** the index prover vs the slice prover.
* **The recursion cases** (`string_reverse`, `matmul`). These are mostly the
  *designed* open-world contract (D), not lost facts. A domain-typed
  parameter already removes them (§F).

### Which gaps affect current performance?

**On the four core workloads, only G1, on `refined-checks`.**

* `fib`, `loop-count` and `sum-refined` have no proof residue on their hot
  paths. Their NIR is fully raw.
* `refined-checks` also allocates one substring per scanned character. That
  is a representation-heuristic limit, not a missing fact.

Benchmark context is in §J. In this container Cranelift beats Go on 2 of the
4 core workloads, not the reported 3. `fib` (1.4× Go) is the difference, and
it has no fact gap.

---

## B. Analysis inventory

| Subsystem | Computes | Consumes | Granularity / scope | Stored | Overlap |
|---|---|---|---|---|---|
| **`hir/range.tcl`** `Fixpoint` (`2552`) | Range `{min max ?exact?}` per ExprId and per parameter/result, per instance (`range.tcl:20-25`, `172-234`); exact sets ≤ 32 values | static types (`ConstrainType` `281`), declared domains, native `-result-range` metadata, `hir::exact::NativeRange`, induction locks, rangerec pins | per **instance**, flow-sensitive inside; interprocedural, context-insensitive (entry = join over every exact caller of a *closed* instance, `2703-2768`); open instances get no caller facts | no: recomputed by `native::lower::program` (`lower.tcl:1319`) and audit tools | completions re-implements the node dispatch (§A) |
| range "verify" mode (`verifyDeclaredParams` `1500`, `verifyDeclaredResults` `1459`) | proves declared parameter/result/field domains | same transfer rules, parameters seeded only by declared types | **local, per block, deliberately non-interprocedural** (`1480-1499`: "an invalid caller must not pollute the callee fixpoint") | diagnostics | the legality-side use of range |
| **`hir/induction.tcl`** (`analyze` `462`) | equality-termination proof: `p ∈ [init, B.max]` for a self-tail `p ± 1` with an `if p == B` guard; `monotone` (turns `p != B` into `p < B`) | specialize contexts (selfTails), `ExternalSeeds` (literal arguments of known callers, `range.tcl:790`) | per instance, **closed instances only** (after fix S3) | no | its `ClassifyArg` is reused by `hir/traversal.tcl` and `native/shortstring.tcl` |
| **`hir/rangerec.tcl`** (`analyze` `116`, `SolveInstance` `286`) | bounded successful-result Range of a closed, directly self-recursive instance with a strictly decreasing measure and a finite external entry (fib: `[0, 17711]`) | range transfer functions per measure state | per instance; ≤ 128 states | no (pinned into `calleeResults`) | none |
| **`hir/completions.tcl`** | per call: `effectiveErrors`, `mayReturnNormally`, `resultRangeFact`; relational facts while walking: `indexBounds`, `upperBounds`, `sizes`, `minSizes` (`NewCtx` `185`) | range lattice and helpers, `hir/cardinality.tcl` forms, `hir::exact`, native `-bounds` registrations (`core/native.tcl`) | once per function body with parameters unconstrained (`checkBlock` `1727`); exact callees re-walked per call site under argument Ranges, exact scalars and literal Lists (`analyzeBlock` `1690`, memoized); recursion falls back to the declared contract | final sets on the **HIR call node** (or the enclosing `handle` node); generic, not per instance; proof details discarded | duplicated dispatch with range (§D2) |
| `hir/errorsets.tcl` | the legality rule `effective − handled ⊆ enclosing` | completions | per block | diagnostics | — |
| **`hir/cardinality.tcl`** | symbolic linear forms over atoms `len`, `slen`, `cap`, `max`, `v`, `e` (`97-209`); `IntForm`, `StrLength` (`306`), `Capacity` (`343`), `ListLength` (`377`), lockstep `compare` | immutable bindings (`Chase`), exact values, container rules | intraprocedural, on demand | no | consumed only by completions and `hir/lockstep.tcl` |
| `hir/lockstep.tcl` | proves equal lockstep cardinalities, otherwise `LOCKSTEP-UNPROVEN` | cardinality | per loop | diagnostic + mark | — |
| **`hir/exactvalue.tcl`** | `{int N}`, `{val V}`, `{list ...}` | constants, immutable locals, `list`/`append`/`at`/`length`, `+ - *`, decided `if`s; **never** parameters, user calls, structs, MutableArrays (`52-60`) | intraprocedural, on demand | no | used by types, range, completions, cardinality, warnings, shortstring; completions has its own List/String recognizers (`LiteralListOf`) that differ |
| **`hir/specialize.tcl`** | instances keyed by `KeyType` of each argument: kinds; exact callables (≤ 4); nominal struct identity; list element keys (`394-433`); M1/M7 entry types; CloseCallers kind theorems | static types, blockescape closedness | per block ≤ 8 live instances, ≤ 1000 total; silently falls back to `<generic>` when over the limit | instance table + per-instance type overlay | the key never holds exact values, ranges, lengths or field values |
| `hir/semantic.tcl` | semantic instances (result-type refinement) | types, range verify | ≤ 16 per block | declines recorded | — |
| `hir/escape.tcl` (+ `transport.tcl`), `hir/construction.tcl`, `hir/stringregion.tcl`, `hir/blockescape.tcl`, `hir/traversal.tcl` | representation: scalar replacement, virtual construction, string regions, de-closure, UTF-8 traversal cursor | structure, spec closedness; **not** range (except traversal → induction `ClassifyArg`) | per instance × binding | recomputed per lowering | precedence order in `native/lower.tcl` `Bind` |
| `native/rawabi.tcl`, `native/shortstring.tcl` | raw-Int ABI positions; packed-ASCII strings | range (`fitsSmall`, `ConditionOutcome`) | per closed instance | recomputed | `RawOpEligible` mirrors lowering |
| **`native/lower.tcl`** | NIR | spec, range, rawabi, representation analyses, static types, `hir::types::IsEqualityTotal`; **never** completions, cardinality, lockstep or errorsets (grep-verified) | per instance view | — | — |
| `compiler/compiler.tcl` (Tcl compiler) | Tcl code | static types (kind-check elision), `known` type tests, literal `if` conditions | — | — | reads no range and no completion fact; every error-declaring native goes through `GenericCall` (`1067`, `1080-1113`) |

### What each subsystem consumes from the others

* **range ← completions:** nothing. range never reads completions.
* **completions ← range:** only the pure lattice helpers and a local
  `analyzeSequence` (used for handler typing). It never reads range's
  interprocedural entry facts.
* **native lowering ← completions:** nothing.

Hence the two silos.

---

## C. Fact taxonomy: what actually exists

| Fact kind | Representation | Machinery |
|---|---|---|
| Static / nominal type | `hir::types` type, per instance overlay | types, specialize |
| Source-defined integer domain | refined Int type (`type T = Int in a..b`), read as an interval by `ConstrainType` on every `ref`/`project` | **same machinery as Int range** (`hir::range::TypeFact`) |
| Integer range / interval | Range dict | range; completions (local copy) |
| Exact value / constant | Range `exact` set (≤ 32); `hir::exact` values; completions `ctx.exact` | three recognizers: range exact sets, `hir/exactvalue.tcl`, completions' `LiteralListOf`/`ExactValueOf` |
| Boolean truth / decided condition | `hir::types::KnownOutcome` (types) + `hir::range::ConditionOutcome` (ranges) | native M6 decided `if`; completions infeasible-branch pruning (empty narrowed Range) |
| Branch narrowing | `ComparisonNarrowing` on `< <= > >=` (and `==` with exact sets or induction `monotone`) | shared helper; completions adds `and`/`or` decomposition (`Conjuncts` `380`), range does not |
| Relational facts | completions `upperBounds` (binding → list of strict upper FORMs), `indexBounds` (counted-loop 0 ≤ i < FORM) | completions only |
| Equality relations | `sizes` (FORM → exact N), induction `monotone` | completions; range induction |
| Cardinality / List length / String length / capacity | linear forms over `len`/`slen`/`cap` atoms | `hir/cardinality.tcl`, read by completions and lockstep only; range knows only "a collection length is in `[0, 2^62-1]`" (native metadata) |
| Struct field type / domain | declared field type; `VerifyStruct` proves it at construction | range and completions both read it at `project` |
| Struct field exact / range value | **does not exist** (struct Range is `unknown`, `range.tcl:932-944`, `completions.tcl` `project`) | — |
| Call-specific argument facts | completions `analyzeBlock(argRanges, argExact, argExactLists)` | completions (legality) |
| Call-instance facts | range per-instance entry Ranges (joined, closed only); specialize key types and overlays | range, specialize |
| Return / result facts | range `calleeResults` (per instance); completions per-call result Range; the declared/inferred result type | both |
| Recursive induction facts | `hir/induction.tcl` overrides + `monotone`; `hir/rangerec.tcl` state summaries | range only |
| Loop induction-variable facts | range `InductionSeed` interval (`846`); completions `indexBounds` relation | **split**: the interval lives in range, the relation in completions |
| Completion / error facts | `effectiveErrors`, `mayReturnNormally` on HIR nodes | completions; read only by diagnostics, warnings (`reachedExprs`), tests and audits |
| Known-success / impossible error | `effectiveErrors` = `{}` | same |
| Known-error | `KNOWN-ERROR` diagnostic + `mayReturnNormally 0` | same |
| Representation | raw-ABI plan, `rawregs`, scalar replacement, regions, plans, packed ASCII | native analyses; reach NIR as opcode choice and register annotations |
| Escape / materialization | escape, blockescape, construction verdicts | same |
| Raw-Int eligibility | `fitsSmall` of a per-instance Range | range → lowering, rawabi |
| String representation | StringRegion `(base, start, end)`, traversal byte cursor, ShortString1/packed ASCII | stringregion, traversal, shortstring |
| *Not on the requested list:* instance closedness | `hir::specialize::InstanceClosed` (blockescape proof), dormant instances | the gate for every closed-world fact (range entries, rangerec, now induction) |
| *Not on the requested list:* equality totality | `hir::types::IsEqualityTotal` | selects `setcontainstotal`/`setfromlisttotal` (§D3) |
| *Not on the requested list:* reachability | `hir::completions::reachedExprs` | SAME-RETURN-VALUE warning |

**Several requested entries share machinery:**

* "source-defined integer domain", "integer range", "struct field domain"
  and "raw-Int range" are all the Range lattice, read through
  `ConstrainType`.
* "known-success" and "impossible-error" are both `effectiveErrors = {}`.
* "List length", "String length", "MutableArray capacity" and "symbolic
  linear cardinality" are all `hir/cardinality.tcl` forms.

---

## D. Propagation matrix

Codes:

* **Y:** the fact survives.
* **P:** only some forms survive.
* **N:** the fact is lost.
* **–:** not meaningful at this boundary.
* **D:** dropped on purpose (sound widening or a designed contract).

Where the two analyses differ, the cell gives `C:` (completions, legality)
and `R:` (range / native lowering). Each cell was checked against code, and
most against a probe; the probe is named in the notes below the table.

Columns:

* **Exact Int**, **Interval**
* **Domain:** the source-defined domain from a declared type.
* **Card.:** List/String length.
* **Cap.:** MutableArray capacity.
* **Rel.:** relational facts such as `i < len(xs)` or `end <= len(s)`.
* **Field value:** a fact about this struct field's particular value.
* **No-error:** the completion proof's impossible-error verdict.
* **Raw:** raw-Int eligibility.

| Boundary | Exact Int | Interval | Domain | Card. | Cap. | Rel. | Field value | No-error | Raw |
|---|---|---|---|---|---|---|---|---|---|
| literal | Y | Y | – | C:Y R:P | – | – | – | Y | Y |
| immutable bind | Y | Y | Y | C:Y R:P | C:Y R:– | C:Y R:N | N | – | Y |
| local reference | Y | Y | Y | C:Y R:P | C:Y | C:P (alias) R:N | N | – | Y |
| branch (narrowing) | Y | C:Y R:P (no and/or) | Y | C:P R:N | C:P | C:Y R:N | N | C:Y | R:Y (M6) |
| branch join | Y | Y | Y | C:P | C:P | C:P (live branch only) | N | Y | Y |
| early return | Y | C:Y R:P (no and/or) | Y | C:P | C:P | C:Y (same level only) R:N | N | Y | Y |
| loop body (`loop x in`) | C:P (literal List) R:N | C:P R:N | Y (element type) | N | – | D (dropped at exit) | N | Y | R:Y |
| loop exit | D | D | Y | D | Y (capacity is fixed) | D | – | Y | – |
| counted-loop variable | C:N R:Y | **C:N R:Y** | – | – | – | C:Y ascending, **N descending** R:N | – | – | R:Y |
| lockstep loop | C:N R:Y | C:N R:Y | – | C:Y (equal length) | – | C:Y | – | – | R:Y |
| struct construction | N | N | Y (proven at construction) | N | N | N | **N** | – | P (field crosses tagged) |
| struct projection | N | N | Y (both, since `0a3ff16`) | N (fresh atom each time) | N | N | **N** | – | Y (from domain) |
| function argument (call-specific walk) | C:Y | C:Y | C:Y | C:P (inline literal only) | C:N | C:N | C:N | C:Y | – |
| call-specific instance entry | R:Y (closed, joined) | R:Y | R:Y | R:N | R:N | R:N | R:N | – | R:Y |
| ordinary return (in the callee) | Y (C fixed: S1) | Y (C fixed: S1) | Y | N | N | N | N | – | Y |
| call result (in the caller) | Y | Y (R per instance) | Y | N | N | N | N | Y | Y |
| recursive call | C:D R:P | C:D R:P | Y | C:D | C:D | C:D | N | C:D | R:P |
| recursive induction step | C:D R:Y (closed, `==` ±1) | C:D R:Y (rangerec results) | Y | – | – | – | – | C:D | R:Y |
| handler body | Y | Y | Y | Y | Y | D (dropped at exit) | N | Y | Y |
| handler exit (handled value) | **N** | **N** | Y (via type) | N | – | D | N | Y | N |
| method-call normalization | Y | Y | Y | Y | Y | Y | – | Y | Y |
| HIR → NIR | Y | Y | Y | **N** | **N** | **N** | – | **N** | Y |
| NIR → native | as opcode choice | as opcode choice | as opcode choice | – | – | – | – | – | Y (raw ops) |

**Evidence and explanations for the P and N cells that matter:**

* **Interval, branch and early return: R:P.** range has no `and`/`or`
  decomposition, because an `or` is lowered to nested `if`s and
  `ComparisonNarrowing` returns `{}` for them.
  * `d-early-return`: after `if i < 0 or i >= list::length(xs): return`, the
    index's range at `list::at` is still `[-1, 5] {-1,1,5}`.
  * completions decomposes the same condition (`Conjuncts`) and proves the
    read.
  * Gap G11 (codegen only).
* **Counted-loop variable, interval: C:N.** `EvalCountloop` (`616`) leaves
  the binding unknown and records only `indexBounds`. range seeds
  `[start, end-1]` (`InductionSeed`, `846`).
  * `q-countloop-interval`: `byte::from_int(i)` over `0..256` is rejected,
    with range showing `[0, 255]` at the same call.
  * Gap G3.
* **Counted-loop variable, relation: N descending.** `NoteIndexBound` (`641`)
  returns early unless `direction eq "up"`.
  * `l-loop-forms`: `loop i down from list::length(xs) - 1 through 0:
    list::at(xs, i)` is rejected.
  * Gap G4.
* **Struct construction and projection, field value: N.** `p = Plain {index:
  1}; list::at(xs, p.index)` is rejected, and so is the nested
  `o.inner.index` (`s-struct-facts`). range and completions both type the
  struct `unknown`.
  * Gap G5.
* **Function argument, Card.: C:P.** `third([1, 2, 3])` is proven, but
  `xs = [1, 2, 3]; third(xs)` is not (`n-call-specific-transport`). Likewise
  for String.
  * Cause: completions' `LiteralListOf` / `ArgExactLists` accept only an
    inline literal or a forwarded parameter, while `hir::exact` follows
    immutable locals.
  * Gap G7.
* **Function argument, Cap. and Rel.: C:N.** These are deliberate today: only
  Ranges, exact scalars and literal Lists cross a call. Relations and forms
  never do.
* **Call result, Card. and field value: N.** From `r-return-facts`:
  * `list::at(three(), 2)`, `str::substring(text(), 0, 3)` and
    `list::at(xs, holder().index)` are all rejected;
  * `exact() - 40`, `ranged(true)` and a domain-typed result are all proven.
  * Gap G6.
* **Handler exit: N.** From `u-handler-exit`: after `v = g(k): on Boom: 0`,
  where the join would be `{0, 1}`, `v` is unknown to both analyses.
  * range's `handle` case returns `unknown` (`range.tcl:1077-1100`);
    completions does the same.
  * Gap G9.
* **HIR → NIR for Card., Cap., Rel. and No-error: N.** Never read; see §E,
  journeys A–D. Gap G1.
* **Recursive call: C:D.** A cycle falls back to the declared contract
  (`EffectiveFacts` `1013`), which is the open-world contract (§F).
* **Method normalization: Y.** From `k-method-spelling` and
  `k2-bound-name-spelling`, for `at`, `get` and `length`, in a counted loop
  and under an early-return guard:
  * same effective errors, same argument Ranges, same `op listget`;
  * method and bound-name spellings are identical to each other;
  * the qualified spelling differs only in that module-level bindings
    (`at = list::at`) are passed to the function as extra parameters
    (`pnames="xs length at"`) and its instance is keyed `generic` (`xs :
    any`).
  * That is lambda-lifting of captured module bindings, not fact loss (G16).

### D2. range vs completions: overlap classified

| Overlapping theorem | Classification |
|---|---|
| Lattice: join, intersect, narrowing, `ConstrainType`, add/sub/mul/BitOp | **shared helper already used** |
| `const`/`ref`/`bind`/`project` dispatch | **duplicated rule that could drift**. `project` drifted: range had the declared-domain rule, completions gained it in `0a3ff16` by calling the same `ConstrainType` |
| `return` value into the call's result Range | **duplicated rule that drifted unsoundly** (S1, fixed by porting range's rule) |
| Counted/lockstep loop variable | **same source fact interpreted differently**, and lossy on the C side: range has the interval, C has only the relation (G3) |
| `and`/`or` conjuncts, infeasible-branch pruning | **intentional independent reasoning** (completions header `24-30`); range lacking it is G11 |
| `mod` → `[0, |d|-1]`, exact `str::length`, `char::scalar_value` → `[0, 0x10FFFF]` | **intentional independent reasoning** (kept out of codegen on purpose: comment at completions `776-785`) |
| `DifferenceOffset` (`b - a` where `b = a + K`) | range only: **duplicated rule that drifted** (precision only) |
| `IndexBounds` constant-size check vs `hir::exact::BoundsOf` | **duplicated rule** (`BoundsOf` has no callers left) |
| Handler typing | **one analysis consuming the other's result** (`range::analyzeSequence`) |
| Recursion | **intentional**: range induction/rangerec are closed-world; completions is open-world |

So the recent "completions was taught what range knew" episodes are not
isolated: they come from one systemic feature, a duplicated dispatch.

### D3. Checked vs unchecked precedents (§16 of the brief)

The compiler already picks a cheaper form on the strength of a proof in
these places. All are per specialization instance.

| Producer | Representation | Lowering consumer | Checked form | Unchecked form |
|---|---|---|---|---|
| `hir::aot::analyzeRegion` (static types) | `guards`/`knownErrors` dicts | `EmitArgGuards` | `guard KIND` | nothing |
| `known` type tests | HIR `known` field | `NativeCall` | `isint`… | `bool` constant |
| **`hir::types::IsEqualityTotal`** | static type | `NativeCallOp` (`lower.tcl:6171`, `6223`, `6252`) | `setcontains`/`setfromlist` (in `op_may_error`) | **`setcontainstotal`/`setfromlisttotal`**: same runtime helper, a sibling opcode outside `op_may_error` (`ops.rs:113-139`), `fallible=false` (`clif.rs:1819`) |
| range `fitsSmall` | per-instance Range | `RawEligibleCall` / `RawIntOp` (`6645`, `6760`) | `iadd` (tag test, `sadd_overflow`, `rt_int_add`) | `riadd` (plain `iadd`) |
| range (point shift amount, nonnegative small value) | Range | `RawEligibleShift` (`6718`) | `ishl`/`ishr` (`op_may_error`: RANGE) | `rishl`/`rishr`: **drops an error exit** |
| range bounds `fitsSmall` | Range | `RawCountDomain` (`7212`) | tagged `ilt`/`iadd` | `rilt`/`riadd` |
| range `ConditionOutcome` | Range | `If` (`6958`) + `PureDecidedCondition` (`6888`) | both arms + condition | the live arm only (this is what removes `abi::u8`'s checks) |
| range point result | Range | `ClosedResult` (`4762`) | the call's result register | a constant (the call still runs) |
| `hir/traversal.tcl` plan | plan dict | `TraversalAccess` (`5487`) | `substr` call | `ige` + infallible `decodecharat` |
| `hir/escape.tcl` `ScalarUse` | constant index within a literal's arity | virtual-field interception (`lower.tcl:4913-4952`) | `listget` | a register |

**The precedent for proven bounds is `setcontainstotal`:** a non-erroring
sibling opcode of the same runtime operation, chosen per call node from a
static proof, and excluded from `op_may_error`. That exclusion is what also
lets the enclosing function stop being "may error" (`summarize_call_effects`,
`nir.rs:1042`). No checked/unchecked pair exists yet for `listget`,
`mutarrayget`, `mutarrayset`, `mutarraycopy`, `mutarrayfreeze`, `substr` or
`regioncheck` (all are in `op_may_error`).

Negative precedents, where the proof exists and the check is kept:

* `ListLoop` and `LockLoop` emit the checked `listget` themselves
  (`lower.tcl:7162`, `7523`).
* `regioncheck` is always emitted (`4909`, `5407`).
* Refined-integer constructors are always checked
  (`CheckedIntDomainConstruct`, `6313`).

---

## E. Proof journeys

Unless noted, outputs are from `audit/proof-census/tools/census.tcl -nir`
and `native/explain-native.tcl`, at the fixed tree (identical to the
baseline for these probes).

### A. Counted-loop indexed read (`a-counted-loop-at.bot`)

```
fn doubled(xs):
    loop i from 0 to list::length(xs):
        list::at(xs, i) * 2
```

* **Where `0 <= i < list::length(xs)` is established.**
  `EvalCountloop` → `NoteIndexBound` (`completions.tcl:616`, `641`).
  * The loop is ascending, and the start's Range `[0, 0]` is ≥ 0.
  * So `indexBounds(i) = IntForm(list::length(xs))`.
* **How the symbolic length is represented.** `hir/cardinality.tcl`
  `IntForm` gives the linear form `{0 {{len {b xs}} 1}}`. The atom is keyed
  on `xs`'s binding (immutable).
* **How `IndexNotFound` is proven impossible.**
  * `NativeEffectiveFacts` (`1142`) reads the native's registered check
    shape (`core::native::register -bounds {index list C I}`).
  * `IndexBounds` (`1482`) finds `indexBounds(i)` equal to the container's
    length form and returns `in`.
  * Result: `effectiveErrors {}`.
* **range's version of the same fact.** `i ∈ [0, 4611686018427387902]`.
  This comes from collection-length metadata only; range holds no relation to
  `xs`.
* **What reaches NIR:**
  ```
  %10 = op rbox %7
  %11 = op listget %0 %10 @e10
  ```
  In CLIF (`list_get`, `clif.rs:2025`) this is:
  1. a tag test on the just-boxed index;
  2. `icmp ult` against the length loaded at `+8`;
  3. the load;
  4. a slow path `rt_list_get` + `brif` to the error exit.
* **Why the check stays.**
  * `effectiveErrors` is never read by lowering, and no unchecked `listget`
    exists.
  * The Tcl compiler sends the call through `core::runtime::callValue`.
  * Classification: **B, consumer gap** (G1).

### B. MutableArray capacity (`b-mutarray-capacity.bot`)

* **What proves both reads and writes.** `Capacity` (`cardinality.tcl:343`)
  gives a `cap` atom for:
  * `a = mutable_array::allocate(n)`, read in `loop i from 0 to n` or `to
    mutable_array::capacity(a)`;
  * a parameter `a` read in `loop i from 0 to mutable_array::capacity(a)`.
* **Result:** `mutable_array::set(a, i, ...)` and `at(a, i)` both get
  `effective {}`.
* **Why it is sound.** Capacity is fixed at allocation, and no fact refers
  to contents, so mutation invalidates nothing (§I).
* **What reaches NIR:** `op mutarrayset` / `op mutarrayget`. These are plain
  helper calls plus `check` (`clif.rs:1831-1832`), with no inline fast path
  at all.
* **Classification:** B (G1).

### C. Slice proof (`c-slice.bot`)

```
if start >= 0 and end >= start and end <= str::length(text):
    str::substring(text, start, end)
```

* **How the two checks are ruled out independently.** `SliceFacts` (`1430`)
  takes the registered shape `slices {str S START END}` and rules out each
  check on its own, from the decomposed conjuncts:
  * `LowerUnderrun` needs `start >= 0` (narrowing) and `end >= start`
    (`ProveLe`);
  * `UpperOverrun` needs `end <= str::length(text)` (`upperBounds` + `slen`
    form).
* **Result:** `effective {}`.
* **Dropping the last conjunct** (`cut_lower`) leaves `effective
  {UpperOverrun}`. The function then needs only `errors UpperOverrun`, and the
  caller's exact `(0, 2)` call-specific walk proves even that away (`call
  e68 ... effective {}`).
* **What reaches NIR:** `op substr` (`rt_substr` + check). The errors are
  decided per check, but none of that reaches lowering. **B** (G1).

### D. Branch / early-return proof (`d-early-return.bot`)

```
if i < 0 or i >= list::length(xs):
    return fallback
list::at(xs, i)
```

* **How the facts survive the early return.**
  * `EvalIf` (`511`) finds that the then-branch cannot complete normally.
  * The condition's false outcome is carried forward: `Conjuncts` splits the
    false `or` into `i >= 0` (narrowing) and `i < list::length(xs)` (an
    `upperBounds` entry keyed on `i`).
  * Result: `effective {}`.
* **range's view at the read:** `[-1, 5] {-1,1,5}`, un-narrowed (no `and`/
  `or` decomposition, G11).
* **What reaches NIR:** `op listget`. **B** (G1).
* **Scope is correct.** The same guard nested one level down
  (`z-soundness-neighbours` #3) does not carry, which is sound.

### E. Struct-domain projection (`e-struct-domain-projection.bot`)

```
fn direct(x: abi::U8):
    byte::from_int(x.value)
```

1. **Declared field domain.** `x.value : int[AbiU8Value]`, which is
   `[0, 255]`.
2. **range.** `project` → `ConstrainType` (`range.tcl:945-956`) gives
   `[0, 255]`.
3. **completions.** The same rule, since `0a3ff16` (`project` →
   `ConstrainType`). The call-specific walk of `byte::from_int` under
   `[0, 255]` decides both of its checks, so the call has `effective {}`,
   through a local (`via_local`) and directly (`direct`) alike.
4. **Native.** The shared `byte::from_int<int>` instance's entry is
   `[0, 255]`, so M6 decides both comparisons. Its NIR is:
   ```
   func 3 "byte::from_int" ... instance="int"
       ret %0
   ```
   `plus_one(x: abi::U8)` gets raw arithmetic (`runbox`, `riadd`, `rbox`).

**Working.** One representation footnote, which is not a proof issue:
`direct`'s parameter is a materialized struct (`structget 0 %0`) while
`via_local`'s is scalar-replaced (`pnames="x.0"`). One of `direct`'s callers
passes the value of a `handle` (`dynamic`), which is not a recognized
construction, and escape scalar-replaces a parameter only when every exact
caller passes one. Without that caller, `direct` gets `pnames="x.0"`.

### F. Closed call with a known struct value (`f-closed-abi-u64.bot`, `f2-closed-int-vs-struct.bot`)

1. **In the caller,** the literal has Range `{18446744073709551615}`.
2. **The creator is decided.** `abi::u64<int>`'s entry is that point (M9
   instance entry, joined over its one caller), so both of its checks are
   decided: `retmulti %0`. **This is the last place the exact value is
   known.**
3. **Construction drops it.** `U64 {value: value}`: the struct Range is
   `unknown`, and the creator's result Range is `[-∞, +∞]`.
4. **The encoder sees only the declared domain.** `from_u64<abi::U64>`'s
   parameter is the struct (entry `unknown`), and `value.value` is
   `[0, 2^64-1]` from the declared domain. So `igt %0 9223372036854775807`
   and the `isub` path stay.

The pair `f2` isolates the mechanism. Under the same `if v > 100` decision:

* `enc_int(7)` → `ret %0`: the entry is `{7}`, and the branch is decided.
* `enc_box(Box {value: 7})` → `igt`, `isub` remain: the entry is
  `[-∞, +∞]`.

**Classification.** This is **field-fact loss (A)**: no fact for a field's
value exists anywhere, not even locally (`s-struct-facts`). It is not
specialization economics, because there is one instance, well under the
limit. It is not key granularity either: a single-caller instance still
receives an unknown struct entry. Tiny-leaf inlining does not apply, since a
`struct`/`project` body is ineligible. ABI-NUMERIC-DOMAINS.md's "Optimization
frontier" item 1 is confirmed.

### G. Existing recursive induction proof

See §F (a dedicated section). Short version:

* `hir/induction.tcl` proves `reverse_from`'s `index ∈ [0, 2^62-1]`
  (string_reverse's shape). Native code then keeps `index` raw (`rawregs`
  includes it, `riadd`).
* `hir/rangerec.tcl` proves `fib`'s result `[0, 17711]`, which makes it raw
  `riadd`.
* No program is *accepted* because of either. Both feed code generation
  only, because legality is open-world.

### H. A nearby recursive case that fails (`g-induction-declared-param.bot`, `h-recursive-slice.bot`)

```
type Small = Int in 0..1000
fn count_eq(i: Small, n: Small) -> int:      # rejected: i + 1 facts [1, 1001]
    if i == n: return 0
    1 + count_eq(i + 1, n)
fn count_ge(i: Small, n: Small) -> int:      # accepted
    if i >= n: return 0
    1 + count_ge(i + 1, n)
```

* **`count_ge` is accepted.** Local verification (`verifyDeclaredParams`)
  narrows `i < n ≤ 1000`, so `i + 1 ≤ 1000`.
* **`count_eq` is rejected.** It needs `i != n` together with "i starts
  below n and moves by 1". That is the induction argument, and induction is
  closed-world (its initial-side check reads callers), so it is never
  available to the local, open-world verification.
* **The missing capability** is a *contract-level* induction fact. It is not
  a transport edge.
* **`string_reverse`** (`reverse_from`, `==` guard) has the same structure.
  * `>=` termination removes `UpperOverrun` (`reverse_ge`: `effective
    {LowerUnderrun}`).
  * `index: Nat` with `type Nat = Int in 0..2^62-1` removes both
    (`reverse_nat`: `effective {}`). The recursive call `reverse_nat(text,
    index + 1, ...)` is verified, because `index < str::length(text) ≤
    2^62-1`.

### I. `list::get` (`i-get-in-counted-loop.bot`)

1. **In the caller,** the loop proves `0 <= i < len(xs)` (completions,
   relation) and `i ∈ [0, 2^62-2]` (range).
2. **The call** `list::get(xs, i, 0)` is an ordinary call: `call 1`.
3. **Inside the shared `list::get<List[int], int, int>` instance:**
   * range has entry `i ∈ [0, 2^62-2]`, joined over callers (M9).
   * completions stamps `effectiveErrors {IndexNotFound}` on the `handle`
     node, because `get`'s body is walked with `index` unconstrained.
   * The caller's relation never crosses the call: only Ranges, exact values
     and literal Lists do.
4. **NIR:** `pusherrorexit L0`, `op listget`, `poperrorexit`, then
   `declarederroreq 1073741825`, `cleardeclarederror`, and `reraise`.

The caller's proof stops being useful at the **call boundary**, and three
separate things would have to change for it to matter:

* Lowering would have to consume completion verdicts (G1).
* The relation would have to reach the `at`. The existing route is the
  caller-side decision STDLIB-NAMESPACES.md §12 proposes, i.e. `get` treated
  as `at` plus its handler at the call site. That is an **inlining-frontier**
  decision, not a fact-system one.
* Tiny-leaf inlining would have to allow a `handle` body. Even then it lowers
  the inlined body with the *callee's* instance facts
  (`lower.tcl:6117-6118`).

No new transport is needed for `get` once those choices are made.

### J. Representation proof (positive control)

See §G. Example: `fib<int>`.

* The entry `[0, 22]` comes from the closed caller.
* rangerec's result Range is `[0, 17711]`.
* rawabi gives `rawparams="0" rawresult=1`.
* NIR is `rilt`, `risub`, `riadd`, with no tag tests and no overflow paths.
* In CLIF the calls carry no error check (`call fn0(v0, v16)` with no
  `brif`), because `summarize_call_effects` finds no fallible op.

---

## F. Existing recursion and induction machinery

There are **three** mechanisms, all in range and all closed-world, plus the
legality side, which has none by design.

### 1. Ordinary self-call feedback

* **Where:** `range.tcl`, `SettleInstance` and the caller fold.
* **How:** a self call's arguments feed the instance's own entry. Growth is
  widened to infinity after a few passes. Ordinary `< <= > >=` narrowing
  bounds the continuing branch, so `if index >= str::length(text): return`
  keeps `index ≤ 2^62-1`.
* **Example:** `reverse_ge` gets `index ∈ [0, 4611686018427387903]` from this
  mechanism alone; induction declines it ("unsupported relational form").

### 2. Equality-termination induction

**Code:** `hir/induction.tcl`. Tests: `range-induction-*` in
`tests/hir-range.test`.

* **Hypothesis it can express:** "p moves from its initial value toward B by
  exactly ±1 per self-tail call and stops when it equals B". Hence
  `p ∈ [init.min, B.max]` (or the mirror for a decreasing step). It also
  records `monotone`, so the continuing `p != B` branch narrows to `p < B`.
* **How it is established:**
  * Every self-tail call passes `p ± c` with the same literal `c`
    (`ClassifyParam`, `183`).
  * An `if p == B` guard dominates every self-tail call, either at the top
    level or under "harmless wrapper" `if`s (`Guard`, `327`).
  * `|c| = 1`.
  * B is stable: a literal, a context-free native call, or a parameter
    passed through unchanged (`BoundRange`, `209`).
  * The initial value starts on the correct side of B. It is read from
    `ExternalSeeds`, the literal arguments of known direct callers.
* **How recursive calls are analyzed:** the proven override is *locked* (it
  is never widened) as the parameter's entry in the Fixpoint.
* **What crosses the recursive edge:** the parameter's Range, and the
  `monotone` narrowing.
* **What does not cross:**
  * relations (`p < length(text)` becomes the constant `B.max`);
  * other parameters' facts;
  * non-tail recursion;
  * steps of 2 or more ("step may skip equality terminator",
    `range-induction-3`);
  * caller-propagated (non-literal) seeds.
* **Generality:** it is specific to one recurrence family (`==`
  termination, unit step, self-tail) but structural. It is not keyed by
  name.
* **Fix S3:** it is no longer attempted for open instances (§I).
* **Consumers:**
  * range → raw-Int decisions, e.g. `reverse_from`'s `index` stays raw;
    `sum-refined`'s `n` (`range-induction-sum-refined`).
  * `ClassifyArg` is reused by `hir/traversal.tcl` (csv's forward byte
    cursor) and `native/shortstring.tcl`.

### 3. Bounded self-recursive result Ranges

**Code:** `hir/rangerec.tcl`. Report: SELF-RECURSIVE-RESULT-RANGES.md.

* **Hypothesis:** one finite successful-result summary `S(k)` per
  measure value.
* **Conditions:** the instance is closed and directly self-recursive, not on
  a cycle through another instance. Some Int parameter must have a finite
  external entry, and each self call's measure argument must be strictly
  below `k`.
* **What crosses the recursive edge:** `S(j)` only. Per-state facts of other
  parameters, relations and errors do not cross.
* **Proves:** `fib(22)` → `[0, 17711]`.
* **Rejects:**
  * ascending recursion (`walk(xs, i + 1)`: `nondecreasing-call`);
  * accumulators that need a relation (`rec-tail-accumulator`);
  * open instances.

### Legality side

* **completions:** a recursive cycle falls back to the declared contract
  (`EffectiveFacts`).
* **range verify mode:** local; it checks a self-call's argument against the
  declared parameter domain using the body's own facts only (`count_ge`
  accepted, `count_eq` rejected).

**Answers to the brief's questions:**

* **Do facts cross recursive calls?** Yes, in range, through all three
  mechanisms, and they reach machine code. They never feed legality.
* **Is that a lost fact or a design?** It is the contract: a function body
  is legal for every caller. Its signature, including domain-typed
  parameters, is the only channel for caller facts.
* **Can induction simply be made available to legality?** No. The induction
  fact depends on the callers' initial values, so it cannot. For legality,
  the existing mechanism is a domain-typed parameter (`reverse_nat`).

---

## G. Positive controls: why facts reach machine code today

1. **Virtual one-field ABI struct** (`e`, agent probe `u8.bot`).
   * `abi::u8(7)` → `callmulti`.
   * The creator's companion variant is `retmulti %0` (no check, no struct).
   * `bump(x: abi::U8)` gets `pnames="x.0"`: the field is scalar-replaced
     into a register.
   * **Why it survives:** escape proves that every exact caller passes a
     recognized construction of the same descriptor and that every use is a
     projection. The declared field domain is re-derived at each projection
     from the static type, so no field fact has to travel.
2. **Raw Int from a source domain.** `plus_one(x: abi::U8)` → `runbox`,
   `riadd`, `rbox`.
   * **Why it survives:** `ConstrainType` reads `int[AbiU8Value]` at the
     projection, and `RawEligibleCall` sees that both operands and the
     result `[1, 256]` fit small.
3. **Closed constant creator (M6).** In probe `e`, `abi::u8<int>` has entry
   `{0, 7, 9, 200, 255}`: the join of its five callers, all in range. Both
   `if value < 0` / `elif value > 255` are decided, so the companion variant
   is `retmulti %0` and the canonical one `structnew` + `ret`, neither with
   a comparison.
   * **Why it survives:** an Int parameter's entry Range is the join over
     every caller of a closed instance (M9).
4. **Recursive result (rangerec)** and **induction**: `fib`, `reverse_from`
   (§F). Raw loops: `loop-count`, `sum-refined` (`RawCountDomain`).
5. **String representation.**
   * `reverse_from` gets `asciiparams="0"` / `op asciilen`, then
     `construct str plan region ...`: the plan accumulates without
     re-materializing.
   * emailish?'s `char_at` returns a region companion (`results=3`,
     `retmulti %2 %0 %20`), consumed by `regioneq` /
     `strregiontclalpha` without `substr`.
6. **Closed specialization that removes work** (agent probes `hof.bot`,
   `blk.bot`).
   * Exact-callable keys turn `callvalue` into a direct `callenv` into a
     raw, unguarded instance.
   * blockescape removes the closure object entirely.
   * With `BOTLISH_NATIVE_EXACT_CALLABLE_OPT=0`, the same program has a
     dynamic `rt_call_value` plus two `guard int`.

**The common thread.** Each of these is an **interval or type fact**, or a
**structural representation fact**, that native lowering queries directly,
per instance and per ExprId, at emission time. The facts never pass through
NIR as data; they are spent as opcode choice and register annotations.

The missing positive controls fall into the same split:

* Nothing turns a *completion verdict* into machine code.
* Nothing turns a *relation* into machine code.

---

## H. Gap inventory

Classification codes:

* **A:** fact loss.
* **B:** consumer gap.
* **C:** re-derivation gap.
* **D:** intentional widening.

Priorities are P0–P4 or WORKING-AS-DESIGNED (WAD), per §29 of the brief.
Compile-time notes are estimates.

### Soundness, fixed here

| ID | Fact | Producer → expected boundary | Actual point | Class | Impact | Reproducer | Priority / mechanism | Repair (done) |
|---|---|---|---|---|---|---|---|---|
| S1 | callee result Range | completions `return` → `analyzeBlock` result | `return` set `ctx.returned` but dropped the value (`completions.tcl` `return`, `analyzeBlock`) | duplicated rule drifted | unhandled declared error accepted; run-time `UNCAUGHT-ERROR` on all backends | `sound-b-return-range.bot` (control `sound-b-control.bot`) | **P0**, duplicated reasoning | join `return` values into `ctx.returnRange` (range's rule) |
| S2 | loop completion | completions literal-List per-element walk | a body ending in `break`/`continue` read as "the loop never completes" (`EvalListloop`) | missing distinction | code after the loop unchecked (accepted unhandled errors); false `KNOWN-ERROR`; also hides exits from SAME-RETURN-VALUE (`reachedExprs`) | `sound-c-listloop-break.bot`, `sound-c-listloop-continue.bot` | **P0**, missing producer | such bodies take `EvalLoop`'s conservative path (`ExitsLoop`) |
| S3 | induction parameter Range | `hir/induction.tcl` → range Fixpoint lock | locked onto **open** instances; the initial-side check reads only known callers (`range.tcl` Fixpoint, `induction.tcl` analyze) | duplicated closedness check missing (rangerec and traversal have it) | **miscompile**: M6 deleted a live branch (`[5, 20]` vs `[5, 999]`) | `sound-a-open-induction.bot`, `sound-a-open-induction-specialized.bot` | **P0**, missing guard | `analyze` takes the open set; reason "open instance" |

### Open gaps

**G1: proven bounds checks still emitted** (`at`, `set`, slices, `copy`,
`freeze`, `regioncheck`).

* **Status: repaired** in PROOF-FACT-REPAIRS.md §2 (per-check verdicts consumed
  by native lowering and the Tcl compiler; `regioncheck` dropped when proven).

* **Producer:** completions `effectiveErrors {}`.
* **Expected boundary:** HIR → NIR.
* **Where it stops:** lowering never reads it. The Tcl compiler always
  routes through `GenericCall`.
* **Class:** B. **Impact:** optimization.
  * `refined-checks`: 9% from the one `regioncheck` alone (§J).
  * Every proven `listget` keeps a compare-and-branch plus a slow path, and
    keeps the function "may error".
* **Reproducers:** `a`, `b`, `c`, `d`, `bench/refined-checks.bot`.
* **Priority:** **P2**, missing consumer.
* **Smallest repair:**
  1. Drop `op regioncheck` when the slice call's `effectiveErrors` is
     `{}` and `mayReturnNormally` is 1. Its result register is unused, so no
     new opcode is needed.
  2. Then add non-erroring sibling opcodes for `listget`/`mutarrayget`/
     `mutarrayset`/`substr`, following `setcontainstotal`.
  * Caveats:
    * the stamp is per HIR node and generic, valid for every instance;
    * a handled call's stamp is on the `handle` node;
    * an unstamped node means "not reached", not "proven".
  * **Must come after S1–S3** (done).
* **Compile-time:** cheap (a dict lookup per call).

**G2: `loop x in xs` / lockstep list domains emit the checked `listget`.**

* **Producer:** in bounds by construction (`idx < len`).
* **Where it stops:** `ListLoop` / `LockLoop` (`lower.tcl:7162`, `7523`).
* **Class:** B. **Impact:** optimization on every list loop. `listappend` is
  also fallible, so function fallibility would not change.
* **Reproducer:** `m-listloop-checked.bot`.
* **Priority:** **P2**, missing consumer.
* **Smallest repair:** an unchecked `listget` sibling used only by these two
  emitters. No proof plumbing is needed.
* **Compile-time:** none.

**G3: completions gives the counted/lockstep loop variable no interval.**

* **Status: repaired** in PROOF-FACT-REPAIRS.md §1 (one shared
  `hir::range::InductionBinding`, used by both analyses).

* **Producer:** range `InductionSeed`.
* **Expected boundary:** the completions loop body.
* **Where it stops:** `EvalCountloop` / `EvalLockloop` leave it unknown.
* **Class:** C (both bounds are evaluated right there). Same fact, read
  differently.
* **Impact:** semantic friction.
  * `byte::from_int(i)` over `0..256`, `abi::u8(i)`, and `list::at(lit,
    i - 1)` are rejected.
  * The index prover also needs `i`'s min ≥ 0 (G13).
* **Reproducers:** `q-countloop-interval.bot`, `t-relational-prover-pairs.bot`.
* **Priority:** **P1**, duplicated reasoning.
* **Smallest repair:** seed the binding with `hir::range::InductionSeed(start,
  end, direction, endKind)` from the Ranges `EvalCountloop` already computes.
* **Compile-time:** cheap.

**G4: descending counted loops are not proven.**

* **Producer:** completions `NoteIndexBound`.
* **Where it stops:** it returns early unless `direction eq "up"`.
* **Class:** A (producer missing).
* **Impact:** semantic friction. `loop i down from len - 1 through 0:
  list::at(xs, i)` is rejected.
* **Reproducer:** `l-loop-forms.bot`.
* **Priority:** **P1**, missing producer.
* **Smallest repair:** record `0 ≤ i < FORM` for a descending loop whose
  start form + 1 ≤ FORM and whose end is ≥ -1 exclusive (≥ 0 inclusive).
  G3 covers the lower half.
* **Compile-time:** cheap.

**G5: struct field values.**

* **Producer:** the construction's field expression.
* **Expected boundary:** projection, call entry, return.
* **Where it stops:** at struct construction. The Range is `unknown`, and
  only the declared domain is re-derived (`range.tcl:932-956`,
  completions `project`).
* **Class:** A.
* **Impact:**
  * semantic friction (local: `p.index`);
  * optimization (`from_u64` constant; field crosses into callees tagged).
* **Reproducers:** `s-struct-facts.bot`, `f-closed-abi-u64.bot`,
  `f2-closed-int-vs-struct.bot`.
* **Priority:** **P1** locally, **P2** across closed calls. Missing
  producer and propagation.
* **Smallest repair:**
  1. *Local first:* a projection of a ref to an immutable binding whose value
     is a construction reads that field expression's Range. That is
     `hir::exact`'s chase, applied to fields, in both analyses.
  2. *Then* per-field entry Ranges for **virtual (scalar-replaced)** struct
     parameters in range's caller fold. That is joined per instance, **not**
     in the instance key.
* **Compile-time:** local is cheap; per-field entries are moderate; keying
  instances on field facts would be combinatorial (not recommended).

**G6: return transport of List/String length and struct fields.**

* **Producer:** the callee's result expression.
* **Expected boundary:** the call result.
* **Where it stops:** `analyzeBlock` returns an Int Range only. range has
  no cardinality.
* **Class:** A.
* **Impact:** semantic friction. `list::at(three(), 2)`,
  `str::substring(text(), 0, 3)` and `holder().index` are rejected.
* **Reproducer:** `r-return-facts.bot`.
* **Priority:** **P1**, low frequency. Missing propagation.
* **Smallest repair:** return an exact List/String (completions'
  `exactList`) from `analyzeBlock` for literal-returning callees.
* **Compile-time:** cheap to moderate.

**G7: exact List/String passed via an immutable local is not transported.**

* **Producer:** `hir::exact` (follows locals).
* **Expected boundary:** the call-specific walk.
* **Where it stops:** `ArgExactLists`/`LiteralListOf` (`1001`, `771`) accept
  only inline literals or forwarded parameters. `{}` also means "no fact",
  so an empty literal is lost.
* **Class:** C.
* **Impact:** semantic friction. `xs = [1, 2, 3]; third(xs)` is rejected
  while `third([1, 2, 3])` is accepted.
* **Reproducer:** `n-call-specific-transport.bot`.
* **Priority:** **P1** (small). Duplicated recognizer.
* **Smallest repair:** use `hir::exact::ListOf`/`Of` for argument exactness.
* **Compile-time:** cheap.

**G8: relations do not cross calls.**

* **Affected:** `get`; `matmul`'s `dot(k, count)`; the CSV record lengths.
* **Producer:** completions relations.
* **Expected boundary:** the call-specific walk / callee body.
* **Where it stops:** by contract. Function bodies are open-world, and only
  Ranges and exact values cross.
* **Class:** D.
* **Impact:** semantic (source friction in the corpus) and optimization
  (`get`).
* **Reproducers:** `i-get-in-counted-loop.bot`, `examples/stdlib/matmul.bot`.
* **Priority:** **WAD** for legality; **P2** for `get`.
* **Smallest repair:**
  * *Legality:* the existing route is source contracts (domain parameters,
    `>=` guards, §F).
  * *`get`:* the caller-side decision of STDLIB-NAMESPACES.md §12, an
    inlining-frontier decision.
* **Compile-time:** general relational transport would be expensive. Not
  recommended now.

**G9: a handled call's value Range is lost at handler exit.**

* **Producer:** the call result plus each handler's value.
* **Expected boundary:** handler exit.
* **Where it stops:** `handle` returns `unknown` in both analyses.
* **Class:** A.
* **Impact:** semantic and optimization. After `v = g(k): on Boom: 0`, `v`
  is unknown.
* **Reproducer:** `u-handler-exit.bot`.
* **Priority:** **P1/P2**. Missing propagation.
* **Smallest repair:** join the call's result Range with the live handlers'
  values (range `Expr handle`, completions `EvalHandle`).
* **Compile-time:** cheap.

**G10: parameter contract inference ignores branch narrowing.**

* **Producer:** range narrowing at the use site.
* **Expected boundary:** `hir/signatures.tcl` requirement inference.
* **Where it stops:** "the use site already proves it" counts only type
  refinements.
* **Class:** B.
* **Impact:** semantic friction. `fn clamp(n) -> Two` with `n` returned only
  where `0 ≤ n ≤ 2` infers `n : Two`, and `clamp(5)` is rejected.
* **Reproducer:** `p-param-inference-narrowing.bot`.
* **Priority:** **P1**. Missing consumer.
* **Smallest repair:** when a use's requirement is an Int domain, consult
  the local verify-mode Range at that use before recording the requirement.
* **Compile-time:** moderate (needs local Ranges during inference).

**G11: range has no `and`/`or` decomposition.**

* **Producer:** branch conditions.
* **Expected boundary:** range narrowing.
* **Where it stops:** `ComparisonNarrowing` returns `{}` on the nested
  `if`s.
* **Class:** C (completions has `Conjuncts`).
* **Impact:** optimization only, where entry facts don't already bound.
* **Reproducer:** `d-early-return.bot` (range `[-1, 5]` after the guard).
* **Priority:** **P3/P4**. Duplicated reasoning.
* **Smallest repair:** share `Conjuncts` with range's `If`. This is
  codegen-facing, so it needs the asm audit.
* **Compile-time:** cheap.

**G12: alias keying differs.**

* **Producer:** narrowing keys on the binding a ref names directly;
  relations chase aliases.
* **Where it stops:** a guard on `i` with a read through `j = i` is
  unproven.
* **Class:** C.
* **Impact:** semantic friction (rare).
* **Reproducer:** `t-relational-prover-pairs.bot`.
* **Priority:** **P4**. Duplicated reasoning.
* **Smallest repair:** use one keying convention (`Chase`).
* **Compile-time:** cheap.

**G13: the two relational provers in completions disagree.**

* **Producer:** `ProveNonNeg` accepts a counted loop's start, while
  `IndexBounds`' `upperBounds` rule wants Range min ≥ 0.
* **Additional difference:** slices handle `i + 1` / `len - 1`; the index
  prover refuses offsets.
* **Class:** C.
* **Impact:** semantic friction. The same loop + guard proves
  `substring(s, i, i + 1)` but not `list::at(xs, i)`.
* **Reproducer:** `t-relational-prover-pairs.bot`.
* **Priority:** **P1** (small). Duplicated reasoning.
* **Smallest repair:** G3 fixes the nonnegativity half; share the offset
  handling.
* **Compile-time:** cheap.

**G14: range does not prune infeasible branches.**

* **Effect:** result summaries include dead arms. `enc_int(7)`'s result is
  `[-899, 7]` although lowering decided the branch; empty intervals flow
  into arithmetic.
* **Class:** D (documented choice).
* **Impact:** precision only.
* **Reproducer:** `f2-closed-int-vs-struct.bot`.
* **Priority:** **P4**.
* **Smallest repair:** none needed now.

**G15: callee result summaries freeze loose.**

* **Effect:** `of(call)` is looser than the instance's own final `result`.
* **Class:** D.
* **Impact:** precision only.
* **Reproducer:** agent case (`rangerec.tcl:159-172` documents it).
* **Priority:** **P4**.
* **Smallest repair:** none now.

**G16: method spelling via a module-level binding.**

* **Effect:** the binding is lambda-lifted (extra parameters), and the
  instance is keyed `generic`.
* **Class:** not fact loss.
* **Impact:** tiny codegen cost.
* **Reproducer:** `k2-bound-name-spelling.bot`.
* **Priority:** **P4** / WAD for proof equivalence.
* **Smallest repair:** none.

**G17: the completion proof's interface for consumers.**

* **Issues:**
  * only the final set is kept;
  * it is generic per node (not per instance);
  * a handled call's stamp sits on the `handle` node;
  * `effective ⊆ declared` is not enforced (it holds only through the
    walk's monotonicity).
* **Class:** —. **Impact:** risk for G1's consumer.
* **Priority:** **P3**.
* **Smallest repair:** a small accessor that returns "proven / unknown /
  unreached" for a call ExprId, handle-aware.
* **Compile-time:** none.

**G18: tooling and docs.**

* **Issues:**
  * README §21 still describes kind-only callable keys;
  * `hir.tcl:123` names a non-existent `hir::cardinality::Numeric`;
  * `hir::exact::BoundsOf` has no callers;
  * the completions analysis budget comment says "per top-level walk" while
    the counter is per context.
* **Not re-verified here:** the sub-inventories also reported that
  `ns-proof-relations-before-call-ranges` does not pin the order it is
  named for, and that the explain tool's `short-string.txt` overstates
  ShortString1 for some locals.
* **Priority:** **P3**.
* **Smallest repair:** documentation and test fixes.

**G19: `allocate(n)` success does not imply `n ≥ 0` to completions.**

* **Effect:** `freeze(a, n)` after `a = allocate(n)` keeps both
  `LowerUnderrun` and `UpperOverrun`. Both slice checks hinge on `n ≥ 0`,
  and the form `{v n}` is not known nonnegative.
* **Class:** A (producer).
* **Impact:** semantic friction (small).
* **Reproducer:** `v-allocate-size.bot`.
* **Priority:** **P4**.
* **Smallest repair:** a successful `allocate`'s operand is ≥ 0 after the
  call.
* **Compile-time:** cheap.

### Working

| ID | Mechanism | Evidence |
|---|---|---|
| W1 | Projected declared domain, in both analyses and into native | journey E |
| W2 | Closed Int-constant calls (M9 entry + M6 decided branch) | `abi::u8<int>` `retmulti`; `enc_int` `ret %0` |
| W3 | Ascending counted loops, capacities, slice conjuncts, same-level early returns | journeys A–D |
| W4 | Induction, rangerec, traversal | §F |
| W5 | Relation scoping (loops, handlers, joins, shadowing) | §I, 8 neighbours |
| W6 | Open-world per-function legality with call-specific refinement | **WAD**: `string_reverse`/`matmul` friction is the contract, and domain parameters resolve it (`reverse_nat`) |
| W7 | Method normalization is proof-equivalent | `k-*` |
| W8 | `str::lowercase` length rule | sound under the simple case mapping (`o-lowercase-length`) |

### Existing optimizer heuristics vs. fact loss (§27)

Where a fact is present but the optimization does not happen:

* **G1, G2:** *the proof is available, but the operation has no unchecked
  lowering.*
* **`get` (I):** *the proof is available, but the inlining frontier hides
  it.* It is also not transported.
* **`from_u64`:** *the proof is unavailable* (field loss). It is **not**
  specialization economics: there is one instance, and the key is the
  nominal type by design.
* **`direct<abi::U8>` materialized:** *the representation heuristic
  declines* (a shared instance with a `handle`-joined caller). This is not a
  proof issue.
* **emailish? substring allocation per character:** *a representation
  heuristic.* `immutable_set::contains` is not a `ConsumingNative` for
  string regions.

---

## I. Soundness audit

### Bugs found and fixed

All three are reproduced on interp, compile, cranelift and cranelift-generic.
Before/after outcomes are in `audit/proof-census/out/soundness-values.txt`.

**S1. A callee's early `return` was not part of its call's result Range.**

```
fn idx(k):
    if k > 0:
        return 5
    0

fn get(k):
    xs = [10, 20]
    list::at(xs, idx(k))       # proven "in range": the walk saw only `0`

args = argv():
    on InvalidArgumentEncoding:
        []
get(list::length(args))        # strict compile: no diagnostics
```

* **Before:** every backend raised `uncaught propagated error: <error
  IndexNotFound>`.
* **After:** `UNHANDLED-ERROR` at the `list::at`, the same as the if/else
  control.
* **Fix:** `return` joins its value into `ctx.returnRange`, and
  `analyzeBlock` reports the join of the fall-through value and the returned
  values. This is range's own rule (`range.tcl:1042-1049`).
* **Tests:** `ns-proof-early-return-result`, which also checks that an early
  return whose values are all in range is still proven.

**S2. `break`/`continue` in a literal-List loop hid the code after it.**

```
loop x in [1, 2]:
    if x > 1:
        break
    x
list::at([1], 5)               # strict compile: no diagnostics
```

* **Before:** an uncaught `IndexNotFound` on every backend. The `continue`
  variant was a false `KNOWN-ERROR` for `f(0)`, which returns 7 on every
  backend under `-strict 0`.
* **After:** `KNOWN-ERROR` for the first (statically out of range); the
  second is accepted.
* **Fix:** a body that can `break` or `continue` this loop (`ExitsLoop`)
  takes `EvalLoop`'s conservative path. A body that only `return`s or
  `fail`s still stops the per-element walk.
* **Tests:** `ns-proof-literal-loop-exits`.

**S3. The induction fact was locked onto open instances (miscompile).**

```
fn count_up(n, acc):
    if n == 0:
        return acc
    if n > 10:
        return 999
    count_up(n - 1, acc + 1)
# ...count_up escapes: g = choose(flag(1), count_up, other)
[count_up(5, 0), g(20, 0)]
```

* **Before:**
  * interp/compile give `[5, 999]`; `cranelift-generic` gives `[5, 20]`.
  * On the default backend, a program with more than 8 specializations of
    `count_up` (so one literal call falls back to the generic instance that
    `g` also reaches) gives `[10, 0]` instead of `[10, 999]`.
* **After:** `[5, 999]` / `[10, 999]` everywhere.
* **Fix:** `hir::induction::analyze` takes the open-instance set and records
  "open instance" instead of a proof. `range.tcl`'s Fixpoint comment, which
  said open instances "keep whatever hir/induction.tcl proved", is
  corrected. rangerec and traversal already excluded open and generic
  instances.
* **Tests:** `range-induction-open-instance` (fact + four-backend value) and
  `range-induction-closed-instance-unchanged`.

**Validation:**

* Every new test fails on the baseline and passes with the fix.
* NIR is byte-identical before and after for all 32 programs in `bench/`,
  `examples/stdlib/`, `examples/surface/` and `examples/abi/`, so the
  scalar-asm audit corpus is unchanged.
* Full suites on the fixed commit (`CORE_BACKEND=interp` and `compile`, as
  CI runs them):
  * interp: 5155 tests, 5155 passed;
  * compile: 5155 tests, 5151 passed, 4 skipped (`coreScoping`, the same as
    the baseline), 0 failed.
  * The baseline (66b52cd) had 5151 tests: the four new ones are the
    regression tests above.
  * Two baseline runs sharing one worktree concurrently reported 3 and 7
    failures, all in `argv`, `ascii` and `direct-hir-native` (colliding
    executable scratch directories). Re-run serially, those files pass
    (131/131 on each backend).
* CI's example steps (`main.tcl -backend interp|compile`) succeed.
* `BOTLISH_NATIVE_GC_STRESS=1` over `hir-range`, `stdlib-namespaces`,
  `self-recursive-result-ranges`, `instance-entry-range-facts`,
  `raw-count-loops` and `abi-numeric` (interp): 249 tests, 0 failures.

### Negative results: hazards checked and found sound

**`z-soundness-neighbours.bot`: all 8 stay `UNHANDLED-ERROR`.**

1. Shadowing the List after the guard.
2. Shadowing the index after the guard.
3. An early return nested one level below the read's level.
4. A handler that falls through, with a read after it.
5. A guard proven only in one arm of a join.
6. A capacity's size binding shadowed (`n = n + 1`) before the loop.
7. A `continue` guard inside a loop, with a read after the loop.
8. Another List's length as the loop bound.

Same-scope rebinding is a `DUPLICATE` error in Botlish, so these use nested
scopes.

**Mutation (MutableArray):**

* Capacity is fixed at allocation; there is no resize native.
* No analysis records content facts. An element's Range comes only from the
  static element contract `MutableArray[T]`.
* `set` and `copy` therefore invalidate nothing that exists.
* A fact surviving a mutation incorrectly is impossible today. Any future
  content fact *would* need invalidation.

**Relations:** loops and handlers restore relations at scope end (verified in
code: `EvalLoop`, `EvalCountloop`, `EvalLockloop`, `EvalListloop`,
`EvalHandle`). Every cardinality atom names an immutable binding.

**Recursion:** rangerec requires `InstanceClosed`; traversal requires a
non-generic instance (reachable only by direct calls); induction now
requires closedness (S3).

**Cardinality transfer:** `str::lowercase` is length-preserving under
Botlish's simple case mapping. `İ` and `ẞ` stay one scalar on every backend
(`o-lowercase-length`).

**Generic per-node verdicts:** `effectiveErrors` is computed with parameters
unconstrained, so a `{}` stamp is valid for every instance. This matters for
G1.

---

## J. Performance context

The core set has a Go equivalent for each workload (`bench/equivalents/go`):
`fib`, `loop-count`, `refined-checks`, `sum-refined`.

`bench/bench.tcl` was run twice on this container (4 vCPU, Tcl 9.0.1,
go1.24.7): `audit/proof-census/out/bench.md`.

| program | Cranelift | Go | Rust | Botlish vs Go |
|---|---:|---:|---:|---|
| fib | 136.3 µs | 95–97 µs | 56 µs | 1.4× slower |
| loop-count | 1.07 µs | 5.07 µs | 0.55 µs | 4.7× faster |
| refined-checks | 591–611 µs | 185–187 µs | 131–133 µs | 3.2× slower |
| sum-refined | 0.86 µs | 4.02 µs | 3.88 µs | 4.7× faster |

The brief reports that Botlish beats Go in 3 of 4. **This container
reproduces 2 of 4.** `fib` is the difference, and it is likely
environment-sensitive (call overhead).

Which gaps touch the hot paths:

* **`fib`.** NIR is fully raw (`rilt`/`risub`/`riadd`, raw ABI), and no error
  check follows the calls in CLIF. **No proof gap.** The residue is call
  overhead and boolean materialization (`select`/`icmp`), which are
  codegen idioms.
* **`loop-count`, `sum-refined`.** Raw counted loops (`RawCountDomain`) and
  induction (`sum-refined`'s nested `==` guard). **No proof gap.** These are
  the facts that reach codegen working as designed.
* **`refined-checks`.** The hot path is `check` → `emailish?` →
  `scan_while`/`domain?` → `char_at`.
  * Every slice there is proven (`effective {}`), yet the region-companion
    `char_at` runs `op regioncheck` (a `rt_str_region_check` helper call
    plus error branch) whose result is never read. The canonical `char_at`
    runs `op substr` (allocating).
  * **Experiment, no compiler change**
    (`tools/regioncheck-experiment.sh`): deleting that one NIR line gives
    median **612 → 558 µs (−9%)**, consistently across runs
    (`out/regioncheck-experiment.txt`). That is G1's measured value on a
    core workload.
  * The rest of the gap to Go is mostly representation: one substring
    allocation per local-part character (G-rep, not a fact gap) and the
    UTF-8 seeks of a non-ASCII input.
  * The `listget`s in `hex_pair`/`esc_*` run once (top-level `uriEscape`)
    and are cold.

**Reconciliation.** The facts that reach machine code (intervals, domains,
induction, rangerec, representation) are exactly what three of the four core
workloads need, and they work. The facts that do not reach machine code
(completion verdicts, relations, cardinalities) sit on the hot path of one
workload only, through string slicing. So the benchmark results neither prove
nor disprove the completeness of the fact system; they show where the
codegen-facing half is strong.

Compile-time cost of the proof passes (`out/compiletime.txt`, medians; two
test suites were running concurrently, so the numbers are relative):

* The completion proof (`errorsets::verify`) is 7–26% of the front end in an
  unloaded run (fib 8%, csv_records 14%, ai_text_clean 26%, the highest).
* range plus specialization, which run at native lowering, cost more than
  that again (e.g. `csv_records`: front end ≈ 460–550 ms; errorsets 58–65,
  specialize 144–179, range 186–220).
* Recursive call-specific walks are memoized per pass, with a budget of 256
  analyses per walk context. The budget comment says per top-level walk
  (G18).

---

## K. Recommended follow-up milestones

Each is the smallest repair the evidence supports. The order is soundness →
semantic friction → high-confidence performance → cost. None is implemented
here.

### 0. Soundness

S1–S3 are fixed (this milestone).

* **Done:** the cross-check harness is `tests/range-completions-crosscheck.test`
  (PROOF-FACT-REPAIRS.md §3).
* **Follow-up worth doing first:** a **range ↔ completions cross-check
  harness**. Run both analyses' intraprocedural transfer on the same
  fragments (const/ref/bind/project/return/branch/loop/handle) and flag
  disagreements that are not documented as intentional.
* **Why:** it targets the systemic cause of S1, G3 and the earlier
  projection gap, without merging the analyses.
* **Compile-time:** none (test-only).

### 1. Semantic friction, cheap

1. **G3:** seed counted/lockstep loop variables in completions with
   `hir::range::InductionSeed`. This also fixes G13's nonnegativity half.
   *Cheap.*
2. **G4:** a descending counted-loop index bound in `NoteIndexBound`. *Cheap.*
3. **G9:** a handled call's value = the join of the call result and the
   handler values, in both analyses. *Cheap*; range's change is codegen-
   facing, so run the asm audit.
4. **G7:** argument exactness through immutable locals via `hir::exact`, and
   fix the `{}` = "none" sentinel. *Cheap.*
5. **G5 (local):** a projection of a binding whose value is a construction
   reads the field expression's Range, in both analyses. *Cheap.*
6. **G10:** contract inference consults the local Range at an Int-domain use.
   *Moderate.*
7. **G6, G19.** *Cheap to moderate*; low frequency.

### 2. Performance, high confidence

1. **G1a:** drop `regioncheck` for a slice whose `effectiveErrors` is `{}`.
   * Measured −9% on `refined-checks`; no new opcode.
   * Needs the G17 accessor (handle-aware, "unreached" ≠ "proven").
   * *Cheap.*
2. **G2:** an unchecked `listget` sibling for `ListLoop`/`LockLoop`. This is
   by construction and needs no proof. *Cheap.*
3. **G1b:** non-erroring siblings of `listget`/`mutarrayget`/`mutarrayset`/
   `substr`, selected from the completion verdict, following
   `setcontainstotal`. The Tcl compiler's direct-call path for proven sites
   comes with it. *Cheap compile-time*; moderate implementation.
4. **`get` at the caller** (STDLIB-NAMESPACES.md §12, plan 2). This is an
   inlining-frontier decision that reuses 1–3. *Cheap per site.*

### 3. Precision and maintenance

* **G11:** share `Conjuncts` with range. Codegen-facing; needs the asm audit.
* **G12:** alias keying.
* **G18:** docs and tests.

### 4. Only if a workload needs it

* **G5 (closed calls):** per-field entry Ranges for virtual struct
  parameters in range's caller fold (`from_u64`). *Moderate.*
* Do not key instances on field values (combinatorial).
* Do not add general relational call transport (G8). It would change the
  open-world legality contract, and it is expensive.

**No recommendation here requires a new global fact abstraction, a theorem
solver, or merging range and completions.** The census does not justify a
redesign.

---

## Concise map

| Finding | Kind | Impact | Current mechanism | Smallest likely fix |
|---|---|---|---|---|
| S1 early `return` missing from call result Range | duplicated rule drifted (fixed) | **soundness** | completions `analyzeBlock` used the fall-through only | join returns (done) |
| S2 `break`/`continue` in literal-List loop | missing distinction (fixed) | **soundness** + false rejections | `EvalListloop` read `never` as loop non-completion | conservative path (done) |
| S3 induction locked on open instance | missing closedness guard (fixed) | **miscompile** | `hir/induction.tcl` seeds from known callers only | skip open instances (done) |
| projected declared domain (`x.value` of `abi::U8`) | working | semantic + optimization | `ConstrainType` at `project`, both analyses | none |
| closed Int constant through a call | working | optimization | M9 entry join + M6 decided branch | none |
| exact struct field across a closed call (`from_u64`) | missing producer (field loss) | optimization | struct Range is `unknown`; domain only | per-field entries for virtual params (later) |
| exact struct field, local (`p.index`) | missing producer | semantic friction | same | local field chase |
| safe `at`/`set`/slice still checked | missing consumer | performance (−9% measured on refined-checks for `regioncheck`) | lowering never reads `effectiveErrors` | drop `regioncheck`; `*total`-style siblings |
| `loop x in xs` checked `listget` | missing consumer | performance | `ListLoop`/`LockLoop` emit `listget` | unchecked sibling |
| counted-loop interval in completions | duplicated reasoning (lossy) | semantic friction | `EvalCountloop` leaves `i` unknown | seed with `InductionSeed` |
| descending loop index bound | missing producer | semantic friction | `NoteIndexBound` up only | descending case |
| handled value at handler exit | missing propagation | semantic + optimization | `handle` → `unknown` | join call + handlers |
| exact List/String via local into callee | re-derivation gap | semantic friction | `LiteralListOf` vs `hir::exact` | use `hir::exact` |
| List/String length via return | missing propagation | semantic friction | Int-only result Range | return exact List/String |
| relations across calls (`get`, `matmul`) | intentional (open-world) | semantic (corpus) / perf (`get`) | function contract = signature | domain parameters; `get` at caller |
| `==`-terminated recursion in legality | intentional + unsupported theorem | semantic friction | induction is closed-world | domain parameter + `>=` (exists) |
| recursive induction (`reverse_from`, `sum-refined`) | working | optimization | `hir/induction.tcl` → raw index | none |
| recursive result (`fib`) | working | optimization | `hir/rangerec.tcl` → raw result | none |
| contract inference vs narrowing | missing consumer | semantic friction | requirement ignores Ranges | consult local Range |
| range lacks `and`/`or` | duplicated reasoning | optimization (minor) | completions has `Conjuncts` | share it |
| alias keying (`j = i`) | duplicated reasoning | semantic friction (rare) | narrowing direct, relations chased | one convention |
| index vs slice relational prover | duplicated reasoning | semantic friction | `IndexBounds` vs `ProveNonNeg` | G3 + shared offsets |
| method spelling | working (proof-equivalent) | none | normalization to the same callee | none |
| relation scoping, mutation, joins, shadowing | working (sound) | — | restore-at-scope-end, immutable atoms | none |
| `fib` gap to Go | outside the fact system | performance | fully raw already | — |
