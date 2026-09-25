# Comprehensive generated-code audit (final semantic source fence)

## Outcome

This milestone is a diagnostic audit. It does not optimize anything. It
asks one question across every workload family the brief names: **where
does a fact Botlish has already proven stop influencing representation,
specialization, NIR and machine code?**

Short answer: the facts are mostly proven correctly and mostly still
available when native lowering runs. They are either consumed by the wrong
kind of decision or discarded one step earlier than they would be useful.
Five root compiler problems explain almost every inefficiency observed. They
are listed below, most leverage first; §27 has the evidence and §29 the
proposed order.

| # | Root cause (short) | Representative symptoms |
|---|---|---|
| RC1 | **Instance selection ignores proven parameter facts.** Specialization keys are kind-only and chosen before any range fact exists. Generic instances are seeded with `any`, even for *declared* parameter types. Every function that references a module-retained value is a value-capturing closure, and those are forced generic. | `guard int` + tagged compares in every ASCII predicate on the URI path; 26 of 33 functions in `refined-checks` generic; 27 parameter guards there. |
| RC2 | **Proven value facts have no control-flow consumer.** `hir::range` proves intervals and exact sets per instance. Lowering uses them only to choose raw vs tagged representation, fold bitwise ops, and substitute closed call results. Nothing uses a range to decide a comparison or delete a branch. `effectiveErrors` has no consumer at all, and `may_error` is recomputed structurally, per function, in Rust. | `byte::from_int(45)` keeps both checks and both `fail` paths although the instance's own entry range is `[45,45]`; `BelowRange` survives in `byte::set` although the entry range is `[0,+∞]`. |
| RC3 | **Call boundaries are opaque.** Tagged ABI, out-of-line tiny functions, Bool re-materialized and re-tested at every return, effects summarized per callee. Tiny-leaf inlining only accepts straight-line bodies of a fixed op list. | ASCII composition = up to 5 real calls per byte; `char::codepoint` = wrapper call + runtime helper call for a one-shift payload extraction. |
| RC4 | **Compiler-internal representations drop facts their own construction already guarantees** (loop index bounds, unique ownership of an accumulator, byte positions). | Collecting `listloop`: tagged index with overflow/BigInt slow paths, re-checked `listget` bounds, **O(n²) persistent-append accumulator** (92% of bytes allocated in the ASCII probe), temporary `List[Byte]` → dedup scan; StringRegions carry character indices only, so non-ASCII region ops re-seek (112,000 UTF-8 seek bytes per `refined-checks` run). |
| RC5 | **Front-of-pipeline rewrites, module lowering and siloed lattices erase identity before analysis sees it.** `ExpandNativeBodies` pastes validator bodies into raw IR before HIR type-test refinement. Module-retained values are closure captures, and the retention proof is thrown away. The completion proof keeps private native facts. | Second `Emailish?` scan per steady-state iteration of `refined-checks` (decided statically on interp/compile, executed natively); 5.1 KB duplicate scanner copy; the constant set is never known and is scanned with generic `equal`; `char::codepoint`'s upper bound never reaches codegen. |

Two **correctness bugs** turned up along the way. They are reported
separately from the optimization findings, in §1:

- **C1 (S0, silent miscompile, fixed):** `hir/range.tcl` had no `handle`
  case. A handled call and every handler body were invisible to the
  interprocedural range fixpoint. The result was wrong entry and result
  ranges, which native lowering then trusted: raw small-Int overflow, a
  BigInt compared as a raw word, and a wrong constant substituted for a
  call result. The fix is minimal (one `handle` case) and comes with
  regression tests. The brief allows a fix when one is needed for
  trustworthy evidence, and this one was: range facts are this audit's main
  instrument, and several required probe workloads contain handlers.
- **C2 (native crash, not fixed):** a user function that calls a module
  function which is itself a closure over a retained module value (e.g.
  `fn f(b: Byte) -> bool: web::is_unreserved(b)`) fails native lowering
  with `NATIVE BUG: binding … is not reachable`. The failure is loud (no
  wrong values) and doesn't corrupt any evidence, so it is documented, not
  fixed.

No `.bot` source, no optimizer, no representation, lowering or backend
behavior was changed (§31). The only production diff is the C1 fix. It
changes generated code only for programs that contain a `handle`, and no
benchmark or corpus program does (verified byte-for-byte, §30).

## Contents

1. Correctness findings (reported separately)
2. Audit methodology
3. Frozen semantic/source baseline
4. Current compiler pipeline
5. Fact inventory
6. Specialization inventory
7. Representation inventory
8. Benchmark baseline
9. Positive control: nibble/bit work
10. `byte::from_int` audit
11. `byte::set` audit
12. `char::codepoint` / UnicodeChar audit
13. Byte representation audit
14. ASCII audit
15. `web::is_unreserved` audit
16. ImmutableSet audit
17. `listloop` audit
18. Error-completion audit
19. URI / `refined-checks` audit
20. StringRegion / traversal audit
21. Scalar control workloads
22. GC / rooting / call-ABI observations
23. First-loss matrix
24. Finding table
25. Box/unbox/guard census, generic-call census, allocation census
26. Code-size and hot-path decomposition
27. Root-cause clusters
28. Candidate fix families; leverage / complexity / semantic-risk matrix
29. Recommended machine-level milestone order
30. Tests / regression
31. Source-fence confirmation

---

## 1. Correctness findings (reported separately)

### C1 — `hir::range` ignored `handle` nodes (S0 miscompile, fixed)

**Found while tracing** the `byte::from_int` dynamic probe: `callfacts.txt`
showed the handled call's argument with no range fact at all, which led to
`hir::range::Expr`.

**Mechanism.** `hir::range::Expr` (`hir/range.tcl`) dispatches on node kind
and ends in `default { return [unknown] }`. When explicit errors were added
(commit `90cfe54`), `fail` got a case but `handle` did not. So for
`r = f(x): on E: ...`:

- the wrapped call is never visited. Its argument ranges are never recorded
  in `ctx calls`, and `hir::range::analyze`'s caller-propagation fold joins
  **only recorded calls**. If any *other*, unhandled exact call reaches the
  same instance, the callee's entry range is computed from that caller
  alone, which is unsound narrowing;
- handler bodies are never visited. A `return`/`break` inside one never
  reaches `returnRange`/`breakRanges`, so the function's result range
  misses it. That wrong result then feeds `calleeResults`, and
  `native::lower::ClosedResult` substitutes a "proven" constant for the
  call.

Native lowering trusts these ranges for raw arithmetic/comparison
eligibility and for closed-result constants. Both `cranelift` and
`cranelift-generic` are affected (range analysis runs regardless of
`-specialize`). `-repr-opt 0` hides the first two shapes.

**Reproductions** (`audit/comprehensive-generated-code/bugs/`, run with
`tclsh9.0 main.tcl -backend {interp|cranelift} FILE`):

| file | interp (correct) | cranelift before fix |
|---|---|---|
| `handle-range-entry.bot` (`f(5)` + handled `f(2^62-1)`, body `x + 1`) | `[6, [4611686018427387904]]` | `[6, [-4611686018427387904]]` (raw add wrapped the tag) |
| `handle-range-bigint.bot` (`byte::from_int(45)` + handled `from_int(±10^23)`) | `[45, [1, 2]]` | `[45, [2, 2]]` (BigInt pointer compared raw) |
| `handle-return-result.bot` (`return 2^62-1` inside a handler) | `[4611686018427387904, 6]` | `[6, 6]` (`ClosedResult` substituted 5) |

**Fix** (the only production change of this milestone): `hir/range.tcl`
now has a `handle` case. It visits the wrapped call and every handler body
(restoring the binding facts around each handler, exactly as `if` does for
its branches). It returns `unknown` for the handle's own value, which is
what the `default` case already returned, so the fix only *adds* recorded
calls and return/break ranges and never narrows anything. After the fix all
three reproductions agree on all four backends.
`tests/errors.test` has three new parity tests (§30). Programs without a
`handle` produce byte-identical NIR before and after (§30).

### C2 — module closure referenced from a user function (native crash, not fixed)

`audit/comprehensive-generated-code/bugs/module-closure-from-user-fn.bot`:

```botlish
fn f(b: Byte) -> bool:
    web::is_unreserved(b)
f(45)
```

interp: `true`. cranelift: `NATIVE BUG: native lowering: binding b46 is not
reachable from e322`. **First cause:** the HIR `captures` list of the user
function `f` is empty, even though `f` references the module-scope binding
`web::is_unreserved`, and that binding is a *closure* (it captures the
retained `additional_unreserved_chars`). `hir::aot::context` therefore
classifies `f` as envless/static. `native::lower::Access` then has no
capture slot through which to reach the module binding. Module functions
calling each other work, because their captures *do* include module
bindings: `web::uri_escape_text` captures `web::is_unreserved`. So do calls
from the program root.

Not fixed: the failure is loud (compile-time `NATIVE BUG`, never a wrong
value), it has no bearing on any evidence in this report, and a fix means
deciding how module closures are reached from user code, which is exactly
the module-value representation question RC5 raises. **Audit consequence:**
the only way to call the web path natively today is from program top level
or from another module function. A steady-state URI-escaping measurement
probe (`rep(k) = ... web::uri_escape_text(...)`) could not be compiled, so
Byte/ASCII steady-state timing is measured through
`probes/steady-ascii.bot` instead (§8).

---

## 2. Audit methodology

Every workload was taken through the brief's template (A source, B
semantic facts, C HIR types, D ranges/exact facts, E completion facts, F
instances, G representations, H NIR, I asm/CLIF as needed, J first loss, K
cost, L root cause). The evidence comes from existing entry points only,
through non-production helpers under `audit/comprehensive-generated-code/tools/`
(all listed in §30). The two central ones:

- `audit/comprehensive-generated-code/tools/probe.tcl PROGRAM OUTDIR
  ?LOWER-OPTIONS?`. It writes `completion.txt`: every call/handle node
  `hir/completions.tcl` stamped, with `effectiveErrors`,
  `mayReturnNormally` and `resultRangeFact`, i.e. the facts proven *before*
  specialization. `spec.txt` lists instances, key types, results and call
  targets. `params.txt` gives each used instance's parameter declaration,
  the *view type* its own region inference actually used, and the
  `hir::range` entry range lowering consults. `callfacts.txt` has, for
  every reachable exact call, argument view types and ranges, result range,
  and the semantic `effectiveErrors` side by side. It also writes
  `nir.txt`, `asm.txt` (`objdump -dr` of `native::object`, unlinked, so
  runtime helpers appear as relocations), `roots.txt`, `effects.txt`
  (`botlish-native calls`: per-call `may_error`/`may_gc`) and
  `summary.txt` (per-function bytes, registers, mechanically counted NIR
  ops, one-run allocation sites).
- `audit/comprehensive-generated-code/tools/census.tcl OUTDIR...`: the
  guard/box/helper/call census of §25, read from probe outputs.

**Which HIR is inspected.** `main.tcl -backend cranelift` and
`bench/corpus.tcl` both call `native::evalHir` on the surface HIR, and
`probe.tcl` lowers that same HIR, so the inspected NIR is what those
entry points execute. `.ir` programs go through `native::buildProgramHir`
(the `ExpandNativeBodies` + module-native bridge path `native::runProgram`
and `bench.tcl` use).

**Workload corpus.** Existing programs wherever possible: `bench/*.ir` and
all nine `examples/stdlib/*.bot`, unchanged. Where the brief names a *call
shape* that no existing program isolates, a probe under
`audit/comprehensive-generated-code/probes/` reproduces the corresponding
test-suite program (each file names its origin). These probes are
call-site harnesses around the frozen library. None of them is an
alternate version of any library function.

| probe | shape | origin |
|---|---|---|
| `from-int-literal.bot` | D: exact literal 45 | `tests/errors.test` known-safe-literal |
| `from-int-dynamic.bot` | A: unconstrained Int (listloop element), both errors handled | `tests/ascii.test` loop shape |
| `from-int-nonneg.bot` | B: statically nonnegative | `tests/errors.test` partial-range-elimination (verbatim `nonneg`/`g`) |
| `from-int-byte.bot` | C: statically Byte-range (`byte::complement` result) | brief item 10 |
| `from-int-invalid.bot` | E: `from_int(999)` | `tests/errors.test` known-failure-literal (verbatim) |
| `byte-set-canonical.bot` | `byte::set(['-','.','_','~'])` standalone | `tests/byte-set.test` byte-set-canonical (verbatim) |
| `byte-set-dynamic.bot` | `byte::set` on a non-literal list, AboveRange handled | brief item 14 |
| `ascii-256.bot` | all five predicates over 0..255 | `tests/ascii.test` ascii-backend-parity-256 |
| `web-unreserved-256.bot` | `web::is_unreserved` over 0..255 | `tests/web-unreserved.test` parity-256 |
| `web-unreserved-literals.bot` | `is_unreserved` on six exact literals | `tests/web-unreserved.test` set-built-once (verbatim) |
| `steady-ascii.bot` | 1024 × 256 `ascii::is_alphanumeric` calls from a proven-`Byte` caller (timing only) | brief item 126 |
| `steady-ascii-param.bot` / `steady-ascii-capture.bot` | the same work through a static classifier / through a closure capturing a List (the web module's instance shape) | brief items 20, 126 |

**Severity and category** use the brief's S0–S4 and A–J scales.
"**lost**" means the fact is no longer present in the data structure the
next layer reads. "**retained-but-unused**" means it is present there and
the layer does not act on it.

**Reproduce everything:**

```sh
export LANG=C.utf8 LC_ALL=C.utf8
for p in audit/comprehensive-generated-code/probes/*.bot bench/*.ir examples/stdlib/*.bot; do
    tclsh9.0 audit/comprehensive-generated-code/tools/probe.tcl "$p" OUT/$(basename "${p%.*}")
done
tclsh9.0 audit/comprehensive-generated-code/tools/census.tcl OUT/*
bash audit/comprehensive-generated-code/tools/bench-baseline.sh OUT/bench 5
```

(`probes/from-int-invalid.bot` is rejected at compile time by design:
KNOWN-ERROR, no codegen.)

The curated artifacts cited below are committed under
`audit/comprehensive-generated-code/artifacts/` (§30 lists them).
Uncurated full dumps are not committed.

---

## 3. Frozen semantic/source baseline

- Audited revision: `39bac41` ("Regenerate the scalar assembly audit
  corpus"), on top of the static-completion-proof milestone (`2a1cf1e`)
  and the explicit-error milestone (`90cfe54`).
- Frozen vertical, unchanged here: `lib/byte.bot` (`from_int`, `set`,
  nibble helpers, `Byte`/`Nibble`/`LowNibble`/`HighNibble`), `lib/ascii.bot`,
  `lib/char.bot`, `lib/web.bot` (`is_unreserved`,
  `additional_unreserved_chars`, `uri_escape_text`), plus
  error/errors/fail/handle and completion-proof semantics.
  `git diff 39bac41 -- lib/ bench/ examples/` is empty.
- Toolchain: Tcl 9.0.1 (the repository pin, AGENTS.md), rustc 1.98.1,
  cranelift-codegen 0.135.2, x86-64 Linux (4-vCPU Xeon @ 2.80 GHz KVM guest).
- The committed `audit/native-scalar-asm/` corpus was *not* regenerated.
  The probe tool reproduces its code sizes exactly for all 13 programs
  (e.g. refined-checks 17,855 B, csv_records 21,624 B, hashtable 12,868 B),
  so the machine code audited here is the machine code that corpus records.

## 4. Current compiler pipeline (actual, not aspirational)

```
.bot ─surface::parse─▶ AST ─surface::lowerToHir─▶ HIR syntax
.ir  ─core::loadProgramFile─▶ core IR ─native::ExpandNativeBodies (native only, syntactic, pre-HIR)─▶ core IR'
                                                   │
hir::buildSyntax                                   ▼
  1  hir::sourcetypes::apply     type Byte = Int in 0..255 → core::type registry (integer domains)
  2  hir::errordecls::apply      error names
  3  hir::resolve::program       bindings, scopes, captures, call targets, declaredParamTypes,
                                 declaredResult, declaredErrors
  4  hir::types::infer           semantic types; declared params seed their binding; refinement
                                 narrowing; `known` (decided condition, type/evidence level); reachability
  5  hir::range::verifyDeclared{Results,Params}   static admissibility (Range lattice, exact sets)
  6  hir::callables::verify      typed / error-bearing callables are never erased to opaque values
  7  hir::errorsets::verify → hir::completions   per exact call: effectiveErrors, mayReturnNormally,
                                 resultRangeFact stamped on the node; KNOWN-ERROR / UNHANDLED-ERROR
  8  hir::modulebinding::validate   retained module values context-free + immutable (diagnostics only)
                                                   │
native::lower::program                             ▼
  9  hir::specialize::analyze    instances {block, KeyType...}; region re-inference per instance
                                 (view overlays: type, known, reachable)
 10  hir::range::analyze         per used instance: induction, exact-caller propagation, self-call
                                 widening, callee result summaries → Range per expression
 11  hir::escape / stringregion / blockescape / traversal   representation plans
 12  per instance: hir::aot::analyzeRegion(view) → guards / known errors; then lowering:
     raw eligibility (ranges), FoldPureBitwise, ClosedResult constants, RawParams,
     tiny-leaf inlining, If (HIR reachability), ListLoop, Handle          ──▶ NIR text
                                                   │
botlish-native (Rust)                              ▼
 13  nir.rs parse + summarize_call_effects   may_error / may_gc per function (structural fixpoint)
 14  codegen::roots                          safepoints, shadow slots
 15  codegen::clif                           NIR op → CLIF (inline fast paths or rt_* helper calls)
 16  Cranelift (egraph opt, regalloc2)       machine code
```

| # | Pass | Facts introduced | Facts consumed | Facts discarded | Representation decisions |
|---|---|---|---|---|---|
| — | `ExpandNativeBodies` (.ir, native only) | — | native registry `-native-body` | **type-test identity** of substituted predicates (`Emailish?`) | — |
| 3 | resolve | captures, targets, declared types/errors | source | module-scope captures of *user* functions (C2) | — |
| 4 | types::infer | semantic types (nominal evidence), `known` for type-test conditions | declared param types | — | — |
| 5 | range verify | admissibility (transient) | integer domains, exact sets | the per-expression Ranges themselves (not stored) | — |
| 7 | completions | **effectiveErrors, mayReturnNormally, resultRangeFact** on nodes | Range lattice, branch feasibility, literal lists, `char_codepoint` [0,0x10FFFF] (own table) | nothing, but **nothing downstream reads its output** | — |
| 8 | modulebinding | "retained, initialized once, immutable" | initializers | **the proof itself** (a local variable) | — |
| 9 | specialize | instances, view types, instance result types | argument kinds, `RefinementFacts` (named evidence all exact callers prove), declared *results* | **named evidence in keys**; **everything for generic instances** (seed `any`, declared param types ignored); non-Int captures force generic | **which instance a call uses**: the first and coarsest representation decision |
| 10 | range::analyze | per-instance Ranges (interval + exact ≤32) | view types (ConstrainType), exact-caller argument ranges, native `-result-range` | handled calls/bodies (**C1**, fixed); precision via widen-only summaries | — |
| 11 | escape etc. | virtual fields, regions, internal variants, traversal plans | spec + view | — | List/String/Block/byte-offset representations |
| 12 | lowering | NIR | view types, guards, ranges | **completion facts (never read)**; ranges for control flow (never asked) | tagged vs raw (local only); constants |
| 13 | nir.rs | may_error/may_gc per function | NIR instruction kinds | call-site specificity | per-call check / safepoint |
| 15–16 | codegen/Cranelift | — | NIR | — | inline vs helper; machine registers |

### Required pipeline table (item 116)

| Layer/pass | Knows nominal type? | Knows range? | Knows exact value? | Knows effective errors? | Chooses representation? |
|---|---:|---:|---:|---:|---:|
| type inference | **yes** (evidence sets, declared params) | only implicitly through the named domain | literal types only | no (declared/callee sets only) | no |
| range analysis (verify, semantic) | via `TypeFact` | yes (transient) | yes | no | no |
| completion proof | via `TypeFact` | **yes** (local, call-specific, branch-feasible) | **yes** (literals, literal lists, char literals) | **yes (produces it)** | no |
| specialization | **key: no**; seed: non-generic instances only, when every exact call proves it | no | no (list *shapes* yes) | no | **yes** (instance = kind-level representation) |
| range analysis (codegen-facing) | via view type | **yes** (per instance, caller-joined) | yes (≤32 values) | no | no |
| native lowering | view types | reads ranges for raw/bitwise/closed-result only | point ranges → constants | **no** | **yes** (tagged/raw, virtual, region) |
| NIR | no (`instance=` label) | no | constants only | no (`may_error` recomputed per function) | tagged vs `rawregs` |
| Cranelift | no | no | constants | no | machine registers |

### Pass-ordering question (item 130)

> Are any useful facts computed only after the stage that would need them
> has already decided?

Yes, five of them:

1. **Ranges vs instance keys.** `hir::range::analyze` runs *after*
   `hir::specialize::analyze`, over the instances specialization already
   chose. It cannot split an instance, so a fact that differs per caller
   (`from_int(45)` vs `from_int(n)`) can only ever be the join. Ranges are
   instance-level, never call-level.
2. **Completion facts vs `may_error`.** `effectiveErrors` is computed first
   (step 7) but never read. `may_error` is recomputed last (step 13),
   structurally, from whether the callee's *NIR body* contains a
   `faildeclared`/guard/fallible op. By then the call-site facts have no
   carrier.
3. **Block virtualization vs closure specialization.** Specialization
   decides "value-capturing closure → generic" (step 9) *before*
   `hir::blockescape` proves the closure never exists at runtime (step 11).
   The virtualized scanners in `refined-checks` keep generic guards for a
   closure that was removed.
4. **Native-body substitution vs type-test refinement.** `ExpandNativeBodies`
   rewrites raw core IR *before* `hir::types::infer` could decide
   `Emailish?(s)` from `s : Emailish`. The interp/compile HIR decides the
   inner call statically (`known=1` on e15); the native HIR has a plain
   block call with no `known`.
5. **Within `hir::range`:** callee *result* summaries are widen-only from
   the first round, before caller parameter facts have settled.
   `from_int<int>` with entry `[45,45]` settles to result `[45,45]`, but
   its caller's call-result range stays `[0,255]`. Minor (F20).

## 5. Fact inventory

| Lattice / carrier | Where | Facts | Lifetime / reach |
|---|---|---|---|
| Semantic types | `hir/types.tcl`, node `type` | kinds, named evidence (`int[Byte]`), `List[T]`, `ImmutableSet[T]`, fixed List shapes, `{block B arity result}` | whole pipeline via HIR; per-instance *view* overlays in step 9 |
| Integer domains | `core::type::integerFacts` | Byte `[0,255]`, Nibble/LowNibble `[0,15]`, HighNibble exact 16 values | read through `TypeFact` wherever a type is visible |
| Range (semantic uses) | `hir::range::verify*`, `hir/completions.tcl` | interval + exact set, branch narrowing; completions adds branch *feasibility* | transient, except `resultRangeFact` on call nodes |
| Range (codegen use) | `hir::range::analyze` | per instance: parameter entry, per-expression, result | consumed by lowering (§4 row 12) |
| Completion facts | node fields `effectiveErrors`, `mayReturnNormally`, `resultRangeFact` | per exact call | **no consumer** (not in `hir/format.tcl` text; nothing reads them) |
| Native metadata | `core/native.tcl` registry | `-result-range nonneg / collection-length`, `-param-types`, `-tests-type` | range::analyze, aot guards, types::infer |
| Module retention | `hir::modulebinding::validate` local `values` | retained immutable object graph, init order | **discarded** after diagnostics |
| Specialization | `hir::specialize` instances | key types, seeds, overlays, `calls` | lowering |
| Guards | `hir::aot::analyzeRegion(view)` blockers | per (operation, operand) kind checks | lowering (`guard`) |
| Effects | `nir.rs` | `may_error`, `may_gc` per NIR function | Rust codegen only |

**Duplicated fact representations that break flow (item 72):**

- **Byte's domain** exists four times: as evidence `{Byte}`, as
  `integerFacts` `[0,255]`, as `hir::range` `TypeFact`, and inside
  completions. Only the evidence form crosses into specialization, and there
  it is dropped from keys and (for generic instances) from seeds. The range
  forms are recomputed later from whatever the view type still says.
- **`char::codepoint`'s result:** `hir::range` knows `[0,+∞]` (registry
  `-result-range nonneg`). `hir/completions.tcl` has its own
  `NativeResultRange` table with `[0,0x10FFFF]`, exact for a literal. The
  codegen-facing lattice never gets the upper bound, so `from_int`'s
  comparisons inside `byte::set` stay tagged (`[0,+∞]` is not
  `fitsSmall`).
- **A call's result:** completions says `from_int(45)` = `[45,45]{45}`;
  `hir::range` says the same call is `[0,255]` (F20).
- **Errors:** `declaredErrors` (block), `effectiveErrors` (call node),
  `may_error` (NIR function, Rust) are three independent facts. Only the
  last reaches machine code, and it is the least precise.

## 6. Specialization inventory

**Key** (`hir/specialize.tcl`, `KeyType`): `{BLOCK ARG-KEY...}`; an
argument key is the argument's *kind* (`int str bool unit result any
UnicodeChar immutableSet mutarray block native`) or a `List` key with a
key-typed element and optional fixed shape. Named evidence is dropped by
design; so are ranges, exact values and error sets. The instance's *seed*
(not key) additionally gets:

- `RefineParams`: the named evidence *every* exact call of the block proves
  (`RefinementFacts`, a syntactic pass over *all* calls, including calls in
  unused module functions, F21). **Skipped when the key is `any`.**
- captured-binding types joined over creations (`seeds`).
- not the block's `declaredParamTypes`. Semantic inference seeds
  those; `inferRegion` seeds from the key alone.

Instance policy: generic if every key is `any`; ≤8 specialized instances per
block; **exact calls of a value-capturing closure get the generic key
unless every capture is a proven Int**; a materialized Block value always
runs the generic instance; self tail calls widen.

### Specialization matrix (item 58)

| Fact | Known in HIR? | In specialization key? | Used for instance seed / representation? | Used by lowering? |
|---|---:|---:|---:|---:|
| `Byte` nominal type | yes (evidence) | **no** | non-generic instances: only if *every* exact call proves it; generic: **no** | only through the view type → `ConstrainType` → raw eligibility |
| `[0,255]` range | yes (domain) | no | no (range analysis runs later) | **raw eligibility only** |
| exact `45` | yes (const; completions exact; range point) | no | no | entry range `[45,45]` reaches `from_int<int>` when 45 is its only caller: used for raw compare, **not** to decide the compare |
| `effectiveErrors={}` | **yes** (node field) | no | no | **no** |
| `effectiveErrors={AboveRange}` | **yes** (node field) | no | no | **no** |
| `ImmutableSet` exact members | **no**: only the initializer call and `ImmutableSet[int[Byte]]` | no | no | no |
| `List[Byte]` element type | yes | element *kind* (`int`) | element kind | `listget` result kind known (no guard) |
| UnicodeChar kind | yes | yes | yes | yes (no guard), payload via `rt_char_codepoint` |
| constant value | yes | no | no | `ClosedResult`, `FoldPureBitwise` |
| exact callee | yes (`target`) | the block *is* the instance; Block-typed args: kind only | — | direct `call` |
| container exact contents | literal-list *shape* in type | shape yes, values no | escape analysis | virtual fields |

### Instance counts (item 75)

| workload | used instances | generic (incl. program) | distinct blocks | NIR functions |
|---|---:|---:|---:|---:|
| `bench/refined-checks.ir` | 39 | 28 | 29 | 33 |
| `probes/web-unreserved-256` | 18 | 14 | 18 | 16 |
| `probes/ascii-256` | 8 | 1 | 8 | 7 |
| `probes/byte-set-canonical` | 4 | 1 | 4 | 4 |
| `examples/stdlib/csv_records` | 58 | 13 | 49 | 55 |
| `examples/stdlib/hashtable` | 30 | 7 | 30 | 26 |

The web vertical **under-specializes**: it has almost no specialized
instances, and that is policy (RC1), not the instance limit. The only
visible over-specialization is `Emailish?`'s pasted body: two identical
copies, each with a `<str>` *and* a `<generic>` instance, because the
block-literal callee is materialized as a dead `fnvalue` (F14).

## 7. Representation inventory

Native value word (`native/src/runtime/value.rs`): small Int `(n<<1)|1`
(n ∈ [-2^62, 2^62)); `false`=2, `true`=6, `unit`=10; UnicodeChar
`(cp<<3)|4` (immediate, never a GC root); heap pointer (8-aligned) to
`StrObj {hdr, chars, ascii, text}`, `ListObj {hdr, len, ptr}`,
`SetObj {hdr, len, ptr}` (List layout, deduplicated, unsorted),
`ClosureObj {hdr, func, arity, code, ncaps, caps}`, BigInt, Result,
MutArray, Cell, Native; `0` = error pending.

| Class | Where it exists | Semantic types mapped to it |
|---|---|---|
| tagged word | every NIR register by default; every parameter, result, capture, container element, branch join | everything |
| raw i64 | local temporaries only (`rawregs`); self-tail loop parameters with a `fitsSmall` entry range (`RawParams`) | Int/Byte/Nibble… when the range proves small and no guard is needed |
| Bool | tagged 2/6 everywhere in NIR; Cranelift folds `br(bool)` only for raw compares | Bool |
| UnicodeChar | tagged immediate | UnicodeChar |
| virtual List fields | scalar-replaced fixed-shape Lists (local/remote/param) | record-like Lists |
| StringRegion | `(base, start, end)` registers; `retmulti` companions | temporary substrings consumed by `==`/`length` |
| capture-explicit internal variant | de-closure-converted Blocks | nonescaping local Blocks |
| hidden byte offset | traversal-plan instances | forward `peek`-shaped scans |

**Bounded Int types (item 60).** Byte, Nibble, LowNibble and HighNibble all
use the same class: kind `int` → tagged small Int, raw only as a local
temporary. They never diverge in representation, only in range facts. A
generic instance comes from one of five causes: (a) non-Int closure
captures (observed: the whole web module and the `Emailish?` scanners),
(b) materialized Block values, whose generic entry is "open" (observed:
`web::is_unreserved`, `uri_escape_text`), (c) self-tail key widening,
(d) the 8-instance limit, (e) `-specialize 0`. (c) and (d) are not
decisive in any audited workload.

**Position matters (item 61):**

| position | Byte today |
|---|---|
| parameter | tagged (ABI); `runbox` (1 `sar`) at first raw use; raw from prologue only in self-tail loops (`RawParams`) |
| local expression | raw iff the range is `fitsSmall` and the operand needs no guard |
| call result | tagged; replaced by a constant iff the range is a point (`ClosedResult`) |
| container element | tagged word in `ListObj`/`SetObj` (8 bytes per Byte) |
| captured value | tagged word loaded through `ClosureObj.caps` per use |
| module-retained value | a program-scope binding reached as a closure capture |

**Memory layouts relevant to access cost (item 92).** `listget` has an
inline fast path (tag test, unsigned bounds compare against `ListObj.len`,
load `ptr[i]`) with an `rt_list_get` fallback. `list_length`, `length` and
`immutable_set_contains` are always runtime calls (`rt_list_len`,
`rt_str_len`, `rt_set_contains`), although `len`/`chars` sit at fixed
offsets. A capture load is two dependent loads (closure → `caps` → slot).

---

## 8. Benchmark baseline

**Baseline A = final semantic source fence + current backend**, captured
*before* any production change of this milestone. The C1 fix changes no
benchmark program's NIR (§30), so A is also the baseline for the post-fix
tree.

- Environment (`artifacts/bench-A/environment.txt`): commit `39bac41`, Tcl
  9.0.1, rustc 1.98.1, Go 1.24.7, Python 3.11.15, Intel Xeon @ 2.80 GHz,
  4 vCPU KVM guest, Linux 6.18. Shared cloud container: absolute times are
  only comparable within this report.
- Method: the repository's own commands. `tclsh9.0 bench/bench.tcl -runs 5
  -markdown` (bench.yml's methodology: one untimed warm-up, then best of 5
  runs per program and backend, Cranelift JIT compile excluded), repeated
  in **5 independent sessions**; median of the five best-of-5 values
  reported with min/max. `tclsh9.0 bench/corpus.tcl -backends "cranelift
  cranelift-generic"` once (best of 3, with code size, guards and
  allocations). Script: `tools/bench-baseline.sh`; summary:
  `tools/bench-summary.py`.

| program | Cranelift median | min–max (spread) | Rust | Go | Python | Tcl compile | Tcl interp |
|---|---:|---:|---:|---:|---:|---:|---:|
| `fib.ir` | **182.20 µs** | 182.16–182.38 (0%) | 50.66 µs | 94.30 µs | 2.9 ms | 83.2 ms | 12.57 s |
| `loop-count.ir` | **1.80 µs** | 1.76–2.47 (40%) | 0.76 µs | 3.39 µs | 142.9 µs | 2.1 ms | 313.5 ms |
| `refined-checks.ir` | **546.55 µs** | 541.22–553.00 (2%) | 196.71 µs | 188.53 µs | 3.1 ms | 10.9 ms | 434.4 ms |
| `sum-refined.ir` | **1.32 µs** | 1.32–2.97 (125%) | 2.92 µs | 2.60 µs | 185.0 µs | 36.7 ms | 192.7 ms |

Variance: `fib` and `refined-checks` are stable to 0–2%. The two
microsecond-scale programs are stable except for session 5, which
overlapped a short analysis script running on another core; its reference-language
columns show the same outliers (Go `fib` 145 µs vs 94 µs, Rust 70 µs vs
51 µs), so the medians are used. Changes of a few percent on
`refined-checks`, or sub-microsecond changes on `loop-count`/`sum-refined`,
are within noise and should not be interpreted.

Static baseline per benchmark (probe outputs, identical to the committed
scalar-asm corpus):

| program | NIR functions | machine bytes | allocations / run | generic functions | guards | exact calls with `may_error` check |
|---|---:|---:|---:|---:|---:|---:|
| `fib.ir` | 2 | 394 | 0 | 0 | 0 | 0 / 3 |
| `loop-count.ir` | 3 | 418 | 0 | 0 | 0 | 0 / 2 |
| `sum-refined.ir` | 3 | 292 | 0 | 0 | 0 | 0 / 2 |
| `refined-checks.ir` | 33 | 17,855 | 23 | 26 | 27 | 45 / 46 |

Algorithm corpus (`artifacts/bench-A/corpus-native.txt`, native backends,
best of 3), selected sizes:

| algorithm | input | cranelift | cranelift-generic | code (generic → specialized) | guards | allocations |
|---|---|---:|---:|---|---|---|
| string_reverse | 10,000 chars | 6.6 ms | 6.7 ms | 1,189 → 827 B | 4 → 0 | 20,023 objs, 50.0 MB string copies (source O(n²) concat) |
| string_replace | 10 KB | 0.581 ms | 0.727 ms | 3,413 → 2,377 B | 12 → 0 | 694 objs |
| csv | 10,000 rows | 180.9 ms | 200.7 ms | 5,346 → 4,778 B | 19 → 0 | 497,818 objs, **50,065,012 List elements copied** (source-level `list_append` accumulation, O(n²)) |
| csv_geometric | 10,000 rows | 139.5 ms | 130.9 ms | 7,225 → 5,380 B | 24 → 0 | 487,837 objs |
| csv_chunked | 10,000 rows | 160.1 ms | 138.7 ms | 8,502 → 10,150 B | 29 → 1 | 478,134 objs |
| matmul | 32×32 | 0.289 ms | 0.555 ms | 58,282 → 58,042 B | 17 → 0 | 1,171 objs |

Corpus timings are single best-of-3 measurements with GC in the timed
region. Differences under ~20% between the two native columns at the
large sizes are not reliable (e.g. `string_replace` 100 KB: 33.8 vs
26.2 ms). The structural columns are exact.

**Steady-state Byte/ASCII probe** (`tools/measure.tcl`, `native::measure`,
7 sessions × best of 50, 262,144 classifications each,
`artifacts/steady-timing.txt`):

| probe | ASCII chain reached | median | per classification |
|---|---|---:|---:|
| `steady-ascii.bot` | `<int>` (direct call from `count`) | 3,601 µs | 13.7 ns |
| `steady-ascii-param.bot` | `<int>`, through one extra static `cls` call | 4,293 µs | 16.4 ns |
| `steady-ascii-capture.bot` | **generic** (same `cls`, but a closure capturing a List, the web shape) | 6,536 µs | **24.9 ns** |

Session spreads are below 1.5%. The capture/param pair does identical work
and differs only in RC1's instance selection. The generic chain costs
**+8.6 ns (+52%) per classification**. (`-specialize 0` is *not* a proxy for
the generic chain: `SemanticInstances` seeds generic instances with the
semantic types, which *include* declared parameter types, so it compiles
`ascii::is_digit` without a guard. See F05.)

**Pre/post semantic-milestone snapshots (item 108)**, from the committed
`audit/native-scalar-asm/README.md` history (structure only; timings from
other sessions are not comparable):

| snapshot | `refined-checks` functions / bytes | what changed |
|---|---|---|
| before the ASCII milestone (`c77a0e2`) | 25 / 16,284 | — |
| ASCII + `is_unreserved` + `byte::set` initializer (`6b10713`) | 32 / 18,093 | source shape: new web/ascii/byte functions |
| explicit errors (`378451c`) | 34 / 19,043 | source shape: `from_int` + handler in `esc_char` |
| static completion proofs (`2a1cf1e`) | 33 / 17,855 | source shape: `esc_char`'s conversion removed |
| **final fence (this audit, `39bac41`)** | **33 / 17,855** | — |

Every step was a source-shape change. None was a backend change, which is
consistent with RC2: the semantic milestones added facts but no
consumer.

---

## 9. Positive control: nibble/bit work

Workload: `web::uri_escape_text`'s nested `high_nibble(b) =
byte::nibble(byte::high_nibble(b))`, as compiled inside
`bench/refined-checks.ir` (function 11). The same function lowered with
`-tiny-leaf-inline-opt 0` is the "before inlining" view.

| stage | what happens |
|---|---|
| source facts | `byte::high_nibble(b) -> HighNibble` (declared result, source-defined exact domain {0,16,…,240}); `byte::nibble(x) -> Nibble` |
| HIR / static proof | result contracts verified once per body; the call's semantic type is `int[HighNibble]` |
| specialization | `hir::specialize::Analyze` **replaces the inferred result with the declared result**: the callee's result type crosses the call boundary. `byte::nibble` is called with key `int`, and `RefinementFacts` proves `{HighNibble}` for its parameter, so the instance seed is `int[HighNibble]` |
| range analysis | `TypeFact(int[HighNibble])` = `[0,240]` exact 16 values; exact-caller propagation gives `byte::nibble<int>` the entry `{0,16,…,240}`; `BitOp` exact transfer: `x & 15` = `{0}`, `x >> 4` ∈ `[0,15]`, `0 \| y` = `y`, `(…) & 15` = identity |
| lowering (the consumer) | `FoldPureBitwise` reads `hir::range::of` **per expression**: point result → constant (`x & 15` → 0), identity OR/AND → operand; `RawEligibleShift` makes `>> 4` raw; tiny-leaf inlining removes both calls (straight-line body, only safe ops, no guard, no known error) |
| NIR | `guard int %0; iand %0 240; runbox; rishr 4; rbox; ret`. The four-op `nibble` body became one shift |
| machine code | `and rsi,0x1e1; sar rax,5; shl rax,1; or rax,1` on the fast path (+ the generic guard, see below) |

What made it work, mechanically:

1. **The fact is a value fact on an Int expression.** It lives in
   `hir::range`, which lowering already reads per expression.
2. **The consumer exists at the right granularity.** `FoldPureBitwise` and
   `RawEligible*` ask "what is this expression's Range?" at each native op.
   No instance split and no branch decision is needed.
3. **The facts cross calls through contracts that were already the
   boundary's currency.** Declared result types replace inferred results in
   specialization, and exact-caller parameter propagation seeds the callee.
4. **Tiny-leaf inlining's shape restriction fits the bodies exactly**:
   straight-line, safe ops only.

**The residue proves the rule.** `high_nibble` itself is still
`<generic>` with a `guard int` on `b`: it is a closure nested in
`uri_escape_text`, which captures module values, so RC1 applies to it
like every other web function. The improvement stopped exactly where the
fact would have had to cross an instance-selection boundary.

### Required positive-control question (item 121)

> Why did the nibble/bit work improve generated code while several later
> semantic milestones barely changed it?

Because the nibble/bit work added **both a fact and a consumer in the same
place**: range/exact-set transfer in `hir::range` *and* the lowering code
that reads it (`FoldPureBitwise`, `RawEligibleShift`, tiny-leaf inlining for
straight-line leaves). The later milestones added facts in places no
consumer reads:

- explicit errors and static completion proofs added `effectiveErrors`,
  `mayReturnNormally` and `resultRangeFact` as *HIR node fields*, deliberately
  kept out of `hir::range` to avoid codegen changes (STATIC-COMPLETION-PROOFS.md,
  "HIR representation"). Nothing reads them (RC2);
- ASCII and `web::is_unreserved` rely on *branch* facts (`b >= 48 and
  b <= 57`) and on *instance selection* (`Byte` reaching a closure's
  callee). No lowering consumer turns a range into a decided branch, and
  instance keys drop the evidence (RC1, RC2);
- `byte::set` and `char::codepoint` added facts to the completion proof's
  private table (`NativeResultRange`), not to the codegen-facing lattice
  (RC5).

The nibble path also never needed a *control-flow* decision. Every
simplification it got is an algebraic identity on one expression. Byte
range checks, ASCII classification and error edges are all control flow,
and control flow is exactly what no pass decides from ranges.

**Bit/shift helpers (item 51)** are the current best fact-transport path:
source contract → result-type substitution → exact-caller propagation →
per-expression consumer → raw NIR. Arithmetic comparisons share every step
except the last. They get raw *representation* from the same ranges
(`rige`/`rile`) but never *decision*. Error helpers share none of it:
their facts live on nodes, outside this path entirely.

---

## 10. `byte::from_int` audit

```botlish
fn from_int(value: int) -> Byte errors BelowRange, AboveRange:
    if value < 0: fail BelowRange
    else: if value > 255: fail AboveRange else: value
```

| probe | completion proof (node) | instance | entry range (`hir::range`) | NIR compares | fail paths | call-site `may_error` | callee bytes |
|---|---|---|---|---|---|---|---:|
| D `from_int(45)` | `effectiveErrors={}` `resultRangeFact=[45,45]{45}` | `from_int<int>` | **`[45,45]{45}`** | raw `rilt`/`rigt` | both | **true** | 118 |
| C `from_int(complement(n))` | `effectiveErrors={}` | `from_int<int>` | **`[0,255]`** | raw | both | true | 118 |
| B `from_int(nonneg(m))` | `effectiveErrors={AboveRange}` | `from_int<int>` | **`[0,+∞]`** | tagged `ilt`/`igt` | both | true | 329 |
| A `from_int(n)` (unconstrained) | `{AboveRange,BelowRange}` | `from_int<int>` | `[-∞,+∞]` | tagged | both | true | 329 |
| E `from_int(999)` | KNOWN-ERROR at compile time | — | — | — | — | — | no codegen |

(`artifacts/from-int-*/`; `callfacts.txt` shows the node facts and the
instance facts side by side.)

### The known-safe discrepancy (item 12): why `from_int(45)` keeps both checks

Every hypothesis in the brief, tested against the trace:

| hypothesis | verdict | evidence |
|---|---|---|
| no call-site specialization | **true** | one instance per `{block, kinds}`: `from_int<int>` serves every Int caller |
| specialization key lacks range facts | **true** | `KeyType` → `int` |
| callee compiled once independently of caller | **true** (per instance) | same NIR body for A–D; only the *raw vs tagged* choice differs, because the instance's joined entry range differs |
| completion facts stored but not consumed by lowering | **true** | `effectiveErrors={}` on e85; `native/lower.tcl` never reads the field |
| inliner absent | **false, but it declines**: the tiny-leaf inliner exists; the body has `if` and `fail` | `LeafExprStructural` accepts only const/ref/bind/native-call |
| range facts never reach the lowerer | **false** | `from_int<int>`'s entry range `[45,45]` *is* in `hir::range` when lowering runs, and lowering uses it, but only to pick `rilt`/`rigt` over `ilt`/`igt` |

**First non-consumption:** `native::lower::If`. It prunes a branch only
when HIR reachability (`hir::types::KnownOutcome`, type-level) says so. It
never asks `hir::range` whether `value < 0` is decided, and there is no
comparison analogue of `FoldPureBitwise`. With entry range `[45,45]`, both
comparisons are decided, both `faildeclared` blocks are dead, the function
would have no `Fail` instruction, and `nir.rs` would then compute
`may_error=false` on its own, removing the caller's check too. **The
entire residue is one missing consumer away from disappearing** in this
probe, because here the instance happens to have a single caller.

When the instance is shared with a dynamic caller (e.g. `web-unreserved-256`
calls `from_int` both from `byte::set` and from the handled top-level loop),
the joined entry range can no longer decide anything. That limit is RC1, not
RC2.

```
FACT: effectiveErrors(byte::from_int(45)) = {}
completion proof      yes (node e85)
call node field       yes
specializer           ignores (key {int})                 <-- FIRST NON-CONSUMPTION (call-site fact)
range analysis        entry [45,45]{45} retained (instance-level; here it has one caller)
native lowerer        uses the range for raw compares only;
                      If never decides from ranges           <-- NON-CONSUMPTION of the instance-level fact
NIR                   2 compares, 2 faildeclared
nir.rs effects        may_error=true (structural)          consequence
assembly              12-instruction callee success path + caller `test rax,rax / jne`
```

### Partial-error discrepancy (item 13)

For probe B, `effectiveErrors={AboveRange}` **is** stored (e99). The
native instance **knows more than enough**: entry range `[0,+∞]`. The
`BelowRange` path survives because (1) no consumer decides `value < 0`
from a range (RC2), and (2) the entry range is one-sided, so it is not
`fitsSmall`: both comparisons use the *tagged* `ilt`/`igt` with their
BigInt `rt_int_cmp` slow paths (329 bytes instead of 118). The canonical
**FACT PRESERVED BUT UNUSED** (category B).

### Success-path cost of a genuinely dynamic call (item 37)

For probe A, `from_int<int>` tagged, success path 29 instructions
(`artifacts/from-int-dynamic/asm.txt`):

| part | instructions | necessary? |
|---|---:|---|
| frame, 2 callee-saved spills/restores, `ret` | 11 | ABI (the raw instance needs 5: no callee-saves) |
| 2 × small-Int tag test + branch | 4 | yes, semantically (the value may be a BigInt) |
| 2 × compare → Bool via `cmov` → `cmp r,6` → branch | 10 | compare yes; Bool materialize/re-test is representation residue (F18) |
| register moves (Vm pointer, value) | 4 | register-allocation residue |
| error dispatch bookkeeping on the success path | **0** | the fail blocks are out of line |
| caller: `test rax,rax` + `jne` | 2 | yes for a dynamic call |

**Declaring two errors costs nothing on the success path** beyond the
caller's one `test`/branch. What is expensive is the tagged representation
of an unconstrained Int and the Bool round trip. That matches item 107's
observation that explicit errors barely moved the benchmarks: the error
machinery really is cheap, and other costs dominate.

---

## 11. `byte::set` audit

```botlish
fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte] errors AboveRange:
    bytes = loop c in chars:
        from_int(char::codepoint(c))
    immutable_set_from_list(bytes)
```

**Facts.** The completion proof stamps the inner call e77 with
`effectiveErrors={AboveRange}`, generically, from `char::codepoint`'s
`[0,0x10FFFF]`. The module initializer call `byte::set(['-','.','_','~'])`
gets `effectiveErrors={}` (literal-list elements enumerated by
`LiteralListOf`).

**Where `BelowRange` stops being impossible (item 14).**

```
FACT: char::codepoint(c) >= 0   (so BelowRange is impossible)
completion proof        yes ([0,0x10FFFF], own NativeResultRange table)
call node e77           effectiveErrors={AboveRange}
hir::range              char::codepoint<UnicodeChar> result [0,+∞] (registry `nonneg`);
                        from_int<int> entry [0,+∞]   retained (lower bound only)
native lowerer          `op ilt %0 0` emitted, tagged     <-- FIRST NON-CONSUMPTION (RC2)
                        upper bound 0x10FFFF never reached hir::range   <-- LOST (RC5, F03)
assembly                BelowRange compare + branch + cold fail block per element
```

### Module-initializer case (item 15) and construction pipeline (item 29)

`bench/refined-checks.ir` (and `probes/byte-set-canonical.bot`, identical
code): `<program>` builds the 4-element `List[UnicodeChar]`, calls
`byte::set<List[UnicodeChar]>` once, and the result becomes a closure capture
of `web::is_unreserved`.

| step | allocations | loops | calls (per element) | checks (per element) | element stores | temporaries |
|---|---:|---:|---|---|---:|---|
| `['-','.','_','~']` literal | 1 List | — | — | — | 4 | the literal list |
| `listloop` setup | 1 List (empty accumulator) | 1 | `rt_list_len` once | — | — | index, accumulator |
| per element: loop test | — | — | — | tagged `ilt` (tag test + compare + Bool) | — | — |
| per element: `list_get` | — | — | — | tag test + bounds compare (inline) | — | — |
| per element: `char::codepoint` | — | — | **2** (wrapper fn + `rt_char_codepoint`) | — | — | — |
| per element: `from_int` | — | — | 1 | tagged `<0` and `>255` + caller `may_error` test | — | — |
| per element: `listappend` | **1 List** (copy of all previous) | — | `rt_list_append` | NO_VALUE test | k+1 (copy) | a new accumulator |
| per element: index `+1` | — | — | — | tag + overflow check, `rt_int_add` slow path | — | — |
| `immutable_set_from_list` | 1 Set | O(n²) dedup | `rt_set_from_list` (`equal` per pair) | — | 4 | — |

Totals for n=4 (measured, `artifacts/byte-set-canonical/summary.txt`): **7
allocations, 312 bytes, 14 List element copies** (4 literal + 0+1+2+3
accumulator + 4 set). Per element: 4 out-of-line calls (codepoint wrapper,
`rt_char_codepoint`, `from_int`, `rt_list_append`), 5 small-Int tag tests,
4 tagged ops with BigInt/overflow slow paths (loop test, `from_int`'s two
compares, index `+1`), and root-slot stores for the element, the
accumulator and the index.

| item | classification |
|---|---|
| `char::codepoint` extraction, one range check (`>255`), membership dedup, the final set | semantically required |
| `<0` check + `BelowRange` block; `>255` check for the four literal chars; the loop-index tag/overflow checks; `listget` bounds re-check | proof-removable (facts exist: RC2, RC4) |
| wrapper call around `rt_char_codepoint`; Bool materialization; root-slot stores for an Int index | representation / call-boundary artifacts (RC3, RC4) |
| per-append full copy; temporary `List[Byte]`; O(n²) set dedup of known-distinct literals | fusion / container-representation opportunities (RC4) |

**Temporary `List[Byte]` (item 30).** `bytes` is a named local binding with
exactly one consumer, the next statement's `immutable_set_from_list`. It is
not externally observable. Removing it needs **producer-consumer fusion**
(`listloop` → `setfromlist`) or a builder representation of the
accumulator. General escape analysis is not required (the value has one
use and never escapes), and neither is inlining. The existing
`hir/escape.tcl` handles only fixed-shape Lists, so it does not apply.

**Dynamic list (`probes/byte-set-dynamic.bot`).** Same NIR body (the
instance is keyed on `List[UnicodeChar]`, not on contents). The runtime
AboveRange is produced by the shared `from_int<int>` and propagated by
`byte::set`'s `test rax,rax`, then caught by the handler at the call site.

---

## 12. `char::codepoint` / UnicodeChar audit

| question (item 16–17) | answer | evidence |
|---|---|---|
| Does the lowerer know UnicodeChar is immediate? | **The runtime does; the op table does not use it.** | `value.rs`: `(cp<<3)\|4`; `clif.rs:1515`: `CharCodepoint => rt_char_codepoint` |
| Does it call a helper? | **Yes**, two: the Botlish function `char::codepoint<UnicodeChar>` (39 bytes, `push/mov/call rt_char_codepoint/pop/ret`) and the runtime helper. | `artifacts/byte-set-canonical/asm.txt` |
| Direct payload extraction? | No. `v >> 2` already *is* the tagged Int `(cp<<1)\|1`: one shift | — |
| Exact literal still through the helper? | Yes, whenever the call happens at runtime. In `byte::set` the literal is a *list element* reached through `listget`, so no pass could see it anyway. | — |
| Where is exactness lost? | `hir::range` has **no UnicodeChar domain** (Range is Int-only), so a literal char's codepoint is exact only inside `hir/completions.tcl`. Inside `byte::set` exactness is gone even earlier, at the listloop element binding (unseeded). | completions `resultRangeFact=[0,1114111]`; `hir::range` `[0,+∞]` |
| Unnecessary kind guards / boxing for UnicodeChar parameters? | **No.** `char::codepoint<UnicodeChar>` has no guard (typed param + UnicodeChar key). | NIR func 1 |
| Why not tiny-leaf inlined? | `charcodepoint` is not in `leafInlineSafeOps` (the list is Int arithmetic/compare/bitwise only), although it is total and allocation-free | `native/lower.tcl:217` |

Classification: **B** (the representation fact "immediate scalar" is
retained but the lowering maps the op to a generic helper), plus **E** (a
call boundary for a one-shift body). Cost per `byte::set` element: 2
calls, 8 instructions of call/frame, plus the helper's own body, instead of
one shift.

---

## 13. Byte representation audit

Trace of one `Byte` through `web::is_unreserved` (URI path, `refined-checks`)
and through `ascii::is_digit` called directly (`ascii-256`):

| stage | direct call (`ascii-256`) | URI path (`esc_char` → `is_unreserved`) |
|---|---|---|
| source type | `b: Byte` | `b: Byte` |
| HIR nominal type | `int[Byte]` | `int[Byte]` (`list_get(bytes, 0)` of `List[Byte]`) |
| range fact | `[0,255]` | `[0,255]` at the call site |
| instance | `is_digit<int>`; seed `int[Byte]` via `RefineParams` | `is_unreserved<generic>` (closure capture policy); callee chain `ascii::*<generic>`; seed **`any`** |
| representation class | tagged param → one `runbox`, raw compares | tagged param, `guard int`, tagged compares |
| call ABI | tagged word in `rsi` | tagged word in `rsi` (+ closure in `rdx` for `is_unreserved`) |
| NIR ops | `runbox`, `rige`, `rile`, `br` | `guard int`, `ige`, `ile`, `br` |
| machine register | `sar rsi,1`; `cmp rsi,0x30` | `test rsi,1`… `cmp rsi,0x61` (tagged immediate) with `rt_int_cmp` fallback |
| memory (List/Set element) | 8-byte tagged word | 8-byte tagged word |

### Required Byte question (item 122)

> Why can the compiler prove Byte semantics but still emit generic guards or
> general Int machinery?

Pass boundaries, in order:

1. **`hir::specialize::KeyType`** drops the evidence `{Byte}`: kind `int`
   only. That is fine *if* the seed restores it.
2. **`hir::specialize::RefineParams`** restores it only for non-generic
   instances, and only if **every** exact call in the whole semantic HIR
   proves it (including calls in unused functions, F21).
3. **`hir::specialize::Analyze` seeds generic instances with `any`**,
   ignoring the block's own `declaredParamTypes`. Yet a typed parameter is a
   caller-side obligation that `hir::range::verifyDeclaredParams` has
   already discharged at *every* exact call, and `hir::callables` forbids
   erasing a typed callable. So the declaration holds in every instance,
   generic included. **This is the first loss for every generic-instance
   `guard int` on a `Byte` parameter** (category A).
4. **`hir::specialize::Handle`** gives any exact call of a closure that
   captures a non-Int value the generic key. Every module function that
   touches a retained module value (`additional_unreserved_chars`,
   `hex_digits`) is such a closure, and so is everything it calls with a
   `Byte` (category D).
5. **Representation is tagged at every boundary by design** (parameter,
   result, capture, element), and raw only as a local temporary. Even the
   best case (`is_digit<int>`) pays one `sar` to re-derive what the caller
   already had in a register. That is cheap, but it is a call-boundary
   repack (category E).

Byte stops being "known Int in 0..255" at step 3 (generic instances) or step
2 (a mixed-evidence caller set). In the best case it stays known through
range analysis but is repacked as a tagged word at the next call boundary
(step 5).

### Registers vs memory (item 19)

Nothing in the evidence argues for a physical `i8`. Every Byte cost
observed is **generic vs proven**: `guard int`, tagged compare with BigInt
fallback, `may_error` cascade, Bool round trip. None of it is width. On
x86-64, raw `i64` compares (`cmp rsi,0x30`) are exactly as cheap as 8-bit
ones. The only memory-side cost is the 8-byte tagged element in List/Set,
and that matters only if a Byte-specialized container representation is
chosen later (§16).

### Required representation question (item 128)

> Is the biggest representation problem wrong physical width, or
> generic-vs-proven scalar representation?

**Generic-vs-proven.** No observed inefficiency is caused by width. In
`refined-checks`: 19 `guard int`, all on parameters of generic instances;
57 tagged Int ops with BigInt slow paths, 43 of them in generic instances.
The other 14 sit in specialized instances where no bounded range reaches
the operand: the listloop index (F10), `check`'s loop test (F20) and its
genuinely unbounded accumulator, `from_int`'s one-sided `[0,+∞]`, and the
`Emailish?` driver's scan results. 45 of 46 exact calls carry a
`may_error` check (§25). `ascii-256`
compiles the same five predicates with 0 guards and 0 tagged compares,
and only one of its ten calls carries an error check.

---

## 14. ASCII audit

### Leaf predicates (item 21)

`ascii::is_digit(b) = b >= 48 and b <= 57` (is_upper/is_lower identical in
shape). Two compiled forms exist, and which one a call gets is decided
entirely by the *caller's* instance (§13):

| | `is_digit<int>` (`ascii-256`) | `is_digit<generic>` (`web-unreserved-256`, `refined-checks`) |
|---|---|---|
| bytes | 74 | 377 |
| NIR | `runbox`, `rige`, `br`, `rile`, `br`, Bool consts | `guard int`, `ige`, `br`, `ile`, `br`, Bool consts |
| in-range path (instructions) | **11**: frame 4 + `ret`, `sar`, 2×(`cmp`,`jcc`), `mov eax,6` | **36**: frame + 2 callee-saves 12, guard 5, 2 × (tag test 3–4 + `cmp` + `cmov` Bool + `cmp r,6` + `jcc`), moves |
| out-of-line calls | 0 | 0 (`rt_type_error`/`rt_int_cmp` only on cold/BigInt paths) |
| roots / safepoints | 0 / 0 | 0 / 0 |
| `may_error` | false | **true** (the guard can fail) |
| allocation | none | none (item 85 ✓: every ASCII predicate is allocation-free in both forms) |

Source semantics: 2 comparisons + conjunction. The `<int>` leaf is within
a few instructions of ideal as an out-of-line function. The leaf itself is
not the problem.

### Composition (item 22)

`is_alphabetic = is_upper(b) or is_lower(b)`, `is_alphanumeric =
is_alphabetic(b) or is_digit(b)`: both compile to two real `call`s each, in
both instance forms. Why the tiny-leaf inliner does not apply
(`native/lower.tcl`, `LeafExprStructural`):

- it accepts only `const`, `ref`, `bind` and **native** calls of
  `leafInlineSafeOps`. `and`/`or` are HIR `if`s, so even the leaves
  `is_digit`/`is_upper`/`is_lower` are rejected: **control flow, not
  size**;
- `is_alphabetic`/`is_alphanumeric` contain *block* calls, rejected
  outright. Calls inside a function prevent leaf classification;
- the op budget (8) is not the binding constraint for any of them. Fully
  expanded, `is_alphanumeric` is 6 comparisons, which *would* fit.

Call-graph expansion would expose a simple CFG: a chain of ≤6 compare-and-
branch pairs on one unboxed register.

### Inlining vs specialization (item 23)

Classifying a non-alphanumeric byte such as `'-'` (45) through
`ascii::is_alphanumeric` (dynamic path: 5 calls, 3 comparisons evaluated):

| configuration | calls | guards | tagged compares | `may_error` checks | ≈ instructions |
|---|---:|---:|---:|---:|---:|
| today, generic chain (URI path) | 5 | 3 | 3 | 5 | ≈140 |
| today, `<int>` chain (direct caller) | 5 | 0 | 0 (raw) | 0 | ≈80 |
| perfect representation, no inlining | 5 | 0 | 0 | 0 | ≈80 |
| perfect representation + inlining | 0 | 0 | 0 | 0 | ≈10 (1 `sar`, ≤6 `cmp`/`jcc`, Bool) |

- **Better specialization alone** (RC1) removes the guards, the tagged
  compares with BigInt fallbacks, and the error-check cascade: roughly
  140 → 80 instructions on this path. The `<int>` chain already exists and
  proves it.
- **Inlining is required even with perfect representation** (RC3): the
  remaining ≈80 instructions are about 85% call overhead (frames, argument
  moves, Vm-pointer shuffling, callee-saved spills in the two composite
  functions, Bool materialized in each callee and re-tested with `cmp
  rax,6` in each caller).

The two mechanisms are independent and neither subsumes the other.

### Required ASCII question (item 126)

> Is ASCII slow because comparisons are poor, because tiny functions are not
> inlined, because Byte representation is generic, or some combination?

**A combination of the second and third, not the first.** The comparisons
themselves are good: raw `cmp`/`jcc` with the unbox hoisted, once
representation is proven. Measured (§8, 262,144 classifications): the
`<int>` chain costs 13.7 ns per classification when called directly, and
16.4 ns through one more static call level. The same work through the
generic chain (the web shape) costs **24.9 ns**: +8.6 ns (+52%) for generic
representation alone. The call-boundary share cannot be measured without
changing source (a hand-inlined predicate would be an alternate source
version), so it is estimated statically from the table above. Per
classified byte: generic representation ≈ +60 instructions; call
boundaries ≈ 70 of the remaining ≈80; the comparisons and their branches,
the only part the source actually asks for, ≈ 6–12.

### Bool, comparisons and short-circuits (items 88–91)

- **Bool** is a tagged word (2/6) across every NIR register and every call
  return. A raw compare feeding `br` folds into `cmp`/`jcc` (Cranelift does
  this locally). A *tagged* compare is lowered by `clif.rs` as fast path ∪
  BigInt slow path merged into a Bool value (`cmov` from a constant-pool
  `TRUE`) and then re-tested (`cmp rcx,6; je`). Every predicate call returns
  a Bool word the caller re-tests. That shape is emitted by Botlish
  (`clif.rs`), not introduced by Cranelift (F18).
- **Comparison operands** (item 89) are raw exactly when the instance's
  range is `fitsSmall` and no guard is needed. ASCII `<int>`: raw.
  ASCII generic: tagged. `from_int` with `[45,45]`/`[0,255]`: raw; with
  `[0,+∞]`: tagged. Loop indices: tagged (§17). No per-comparison guard
  appears anywhere; a guard is per operand per operation (and emitted twice
  on the same register in `char_at`, F19).
- **Short-circuit** `and`/`or` lower to direct CFG (`if` with constant Bool
  arms). No helper calls, and the Bool is materialized only at the
  function's return.
- **Branch layout** (item 91): unremarkable once the above is accounted
  for. Cold `rt_type_error`/`rt_fail_declared` blocks are placed out of
  line.

---

## 15. `web::is_unreserved` audit

```botlish
fn is_unreserved(b: Byte) -> bool:
    ascii::is_alphanumeric(b) or immutable_set_contains(additional_unreserved_chars, b)
```

`refined-checks` function 9 / `web-unreserved-256` function 9, 199 bytes,
`env=1 captures=1 instance="generic"`:

```
%1 = call 8 %0            ; ascii::is_alphanumeric<generic> -- real call, may_error=true
br %1 L0 L1               ; true → return true (short-circuit)
L1: %4 = capture 0        ; the retained set: closure → caps → slot (2 dependent loads)
    %5 = op setcontains %4 %0   ; rt_set_contains: linear scan, `equal` per member
    br %5 ...             ; Bool re-materialized
```

| aspect | observation | first cause |
|---|---|---|
| instance | always `<generic>`, even for exact literal arguments (`web-unreserved-literals`: arg ranges `[45,45]`… at the call sites) | captures a non-Int value → generic key (RC1, F06). The generic instance is also a materialized Block, hence **open** to range propagation, so the exact 45 never reaches it (`params.txt`: entry `[-∞,+∞]`) |
| Byte argument | tagged word; parameter view type `any` | F05 |
| call to `ascii::is_alphanumeric` | real call into the generic ASCII chain; `test rax,rax` + `cmp rax,6` after it | RC1 → guards → `may_error` (F08); RC3 |
| short-circuit | direct: `je` to a `mov eax,6` return block | — |
| retained set | `capture 0`: two dependent loads per call | module value lowered as a closure capture (RC5, F13) |
| `setcontains` | `rt_set_contains` call; 1–4 `equal` calls inside (per member: `kind_of` ×2, dispatch, compare) | generic ImmutableSet (F13) |
| Bool result | tagged, re-tested by every caller | F18 |

The generic path costs ≈36 instructions in `is_unreserved` itself, plus
≈140 in the ASCII chain for a non-alphanumeric byte, plus the set scan. None
of it runs in `refined-checks`' steady state (§19). It runs once per byte
of every string `uri_escape_text` escapes.

---

## 16. ImmutableSet audit

### Constant set `additional_unreserved_chars` (item 25)

| layer | what it knows about `{45,46,95,126}` |
|---|---|
| source | `byte::set(['-', '.', '_', '~'])`, a module binding |
| HIR | the initializer call node; type `ImmutableSet[int[Byte]]`; the literal list's element *types* (`List[UnicodeChar]`) |
| completion proof | the literal list's exact codepoints, **only as inputs** to `effectiveErrors({})`; the set value itself is never computed |
| module-retention proof | "initialized once, transitively immutable". **Discarded** after `hir::modulebinding::validate` |
| specialization | `is_unreserved`'s closure seed: `ImmutableSet[int[Byte]]` |
| range analysis | nothing (Range is Int-only; containers are not modeled) |
| lowering / NIR | `capture 0` then `op setcontains`: a generic op on a runtime pointer |
| runtime | `SetObj {len=4, ptr}` of tagged words; linear `equal` scan |

### Required ImmutableSet question (item 125)

> At which layer does the compiler cease to know that
> `additional_unreserved_chars` is the exact constant set `{45,46,95,126}`?

**It never knows it.** The exact *codepoints* of the four literal chars
exist only transiently inside the completion proof, as argument facts for
one `effectiveErrors` computation. No pass evaluates `byte::set` on
them. No lattice represents a set value. The retention proof that would
license treating the binding as a compile-time constant is discarded
after validation. From specialization onward the compiler knows only
`ImmutableSet[int[Byte]]`, reached through a closure capture.

### Dynamic `ImmutableSet[Byte]` and `ImmutableSet[T]` (items 27–28)

`SetObj` is `ListObj`'s layout: header, `len`, `ptr` to tagged words;
`rt_set_from_list` dedups in O(n²) with `equal`; `rt_set_contains` is a
linear scan with an out-of-line `equal` per member. `equal` dispatches on
kind even when both sides are statically Byte. GC: one managed object plus
its value array, rooted like any heap value. Per-member `equal` rules out
nothing statically (`may_error=true` because `equal` raises EQUALITY for
Blocks); for a `Byte` element type that error is impossible.

These are three different optimization problems (not decided here, item 26):

| | knowledge available | plausible future direction (not chosen) |
|---|---|---|
| static exact set (`{45,46,95,126}`) | could be exact at compile time if the initializer were evaluated or the retained value transported | constant-folded membership (comparison chain / 128-bit mask). Needs RC5 first |
| dynamic `ImmutableSet[Byte]` | element domain is 256 values (type) | a 256-bit bitmap representation class *could* be justified by the domain. No evidence yet that dynamic Byte sets are hot |
| dynamic `ImmutableSet[T]` | only `T` | hashing / sorted storage: a general container question, unrelated to Byte |

Nothing in this audit says every Byte set should become a bitmap. The only
Byte-set membership on a measured path is the four-element constant.

---

## 17. `listloop` audit

Generic construct, as lowered by `native::lower::ListLoop` (`byte::set`'s
loop, `artifacts/byte-set-canonical/`):

```
%1 = op listlen %0           ; rt_list_len (call)
%4 = op listnew              ; empty accumulator (allocation)
L0: %8 = op ilt %5 %1        ; tagged compare, rt_int_cmp slow path, Bool, re-test
    br %8 L1 L3
L1: %9 = op listget %0 %5    ; inline: tag test + unsigned bounds compare; rt_list_get fallback
    …body…
    %12 = op listappend %6 %11   ; rt_list_append: allocate len+1, copy all
L2: %15 = op iadd %5 %13     ; tagged add, overflow test, rt_int_add slow path
    jump L0
```

Per iteration: 5 conditional branches of scaffolding (loop test, Bool
re-test, `listget` tag, `listget` bounds, add overflow) + the append's NO_VALUE
test; one runtime call (`rt_list_append`), with `rt_int_cmp`/`rt_int_add`/
`rt_list_get` present only as untaken slow paths; root-slot stores for index,
element and accumulator (the tagged `iadd` is a potential allocation, so
the loop is a safepoint).

| cost | intrinsic to collecting a List? | fact the construction already guarantees |
|---|---|---|
| one load of `len` | yes (once) | — |
| index compare per iteration | yes | — |
| index is tagged; `ilt`/`iadd` carry BigInt slow paths and a safepoint | **no** | `0 ≤ idx < len ≤ MAX_COLLECTION_LENGTH = SMALL_MAX` (`value.rs`), so the index always fits a raw i64 |
| `listget` tag test + bounds compare | **no** | `idx < len` was just tested; the list is immutable |
| a new List per append, copying all previous elements | **no**: the accumulator is compiler-owned and never observable before loop exit (no source name, discarded on `break`) | unique ownership |
| final result List | yes | — |
| `break`/`continue`/`return`/error machinery | **nothing on paths that don't use it**: `ListLoop` registers labels, and only a body that actually contains `break`/`continue` emits jumps to them; errors are the ordinary per-call `test rax,rax` | — |

`listget` bounds check (item 32): still performed. **First loss:**
`ListLoop` knows the index is in bounds ("proven-in-bounds index … by
construction", its own comment), but NIR has no unchecked-element op and
no raw-index form for this loop, so the fact is **not represented** in NIR
(category A). `codegen::clif::list_get` must re-check.

Index representation (item 33): **tagged**, unlike hand-lowered self-tail
Int loops (`loop-count`'s `work<int>`, `drive`), where `RawParams` makes a
proven-small parameter raw from the prologue on. The synthetic listloop
index is not a HIR binding, so `hir::range` (whose `listloop` case visits
the body but models no index) has no fact for it.

Append (item 34), `probes/ascii-256.bot`, 256 iterations:

| | value |
|---|---:|
| List element copies | 34,176 = 256 (literal) + 1,280 (5-element rows) + **32,640 = 0+1+…+255 (accumulator)** |
| allocations | 514 (1 + 1 + 256 rows + **256 accumulator copies**) |
| bytes | 287,792, ≈92% of them accumulator copies |

That is **algorithmic runtime-container cost** (O(n²) persistent append),
caused by the **compiler's** choice to accumulate with the persistent
`listappend` op. Nothing in the source requires it.

### Required listloop question (item 124)

> Which listloop overhead is intrinsic to collecting a List, and which is
> merely recovering facts the loop construction already guarantees?

Intrinsic: one length load, one index compare per element, the element
load, the element store, one final List. Everything else recovers facts the
construction guarantees: index tagging with BigInt/overflow paths and the
resulting safepoint and root stores, the `listget` tag and bounds checks,
the Bool round trip on the loop test. On top of that, the O(n²) copy and n
allocations come from representing a uniquely owned accumulator as a
persistent List (RC4).

---

## 18. Error-completion audit

Native mechanisms (`native/src/codegen/clif.rs`, `runtime/ops.rs`):

| mechanism | lowering | cost |
|---|---|---|
| `fail NAME` (`Inst::Fail`) | `rt_fail_declared(vm, id, name)` sets `Vm.declared_error`, then jump to the current `error_exit` (return `NO_VALUE`=0) | cold block: 2 loads (name from the constant table) + call |
| call of a `may_error` callee | `check(v)`: `brif v ok, error_exit` | **1 `test` + 1 `jcc` on the success path** |
| `PushErrorExit`/`PopErrorExit` | compile-time only: push/pop the `error_exit_stack` target | **0 instructions** |
| `DeclaredErrorEq` | `rt_declared_error(vm)` call + `icmp` | cold; one helper call **per handler arm** (not shared across arms) |
| `ClearDeclaredError` | `rt_clear_declared_error(vm)` call | cold |
| `Reraise` | jump to the outer `error_exit` | cold |
| effect summary | `nir.rs::summarize_call_effects`: a function `may_error` if its body has any `Guard`/`GuardBool`/`CellCheck`/`Raise`/`Fail`/`Reraise`/fallible op or `callvalue`, transitively over direct calls | decides `check()` per call site, **from the callee function only** |

| shape (item 36) | workload | residue on the success path |
|---|---|---|
| direct `fail` | `from_int` | out-of-line blocks only |
| propagating call | `byte::set` → `from_int` | `test rax,rax; je` → shared exit |
| handled call | `from-int-dynamic` `<program>` | the same `test`/`jne`; dispatch (2 × `rt_declared_error`, `rt_clear_declared_error`) is cold |
| statically error-free call | `from_int(45)`, `from_int(complement(n))` | **callee: both compares + both fail blocks; caller: `test`/`jne`** |
| partially error-free call | `from_int(nonneg(m))`, `byte::set`'s inner call | the impossible `BelowRange` compare + block |

### `may_error` is function-global (items 39–40)

`declaredErrors` (block), `effectiveErrors` (call site) and actual body
capability (NIR) are three distinct facts. Only the third reaches codegen,
computed per NIR function. **Yes, it is inherently function-global while the
proofs are call-site-specific.** That is a structural mismatch, recorded
here and not redesigned. `from_int<int>` is compiled once, as `may_error`,
and serves `from_int(45)` (`effectiveErrors={}`) and `from_int(n)` alike.
The mismatch is also *indirect*: the guards that generic instances carry
(RC1) make whole ASCII chains `may_error=true` (F08). `web-unreserved-256`:
16 of 17 exact calls carry a check. The same predicates called with a
proven Byte (`ascii-256`): 1 of 10 (the one to `from_int`).

### Required error question (item 123)

> Why can `effectiveErrors(call) = {}` coexist with machine code containing
> error branches?

A combination, in this order of cause:

1. **Lowering ignorance / fact timing:** `effectiveErrors` is a HIR node
   field produced at `hir::buildSyntax` time and **never read** by
   specialization, range analysis, lowering or `nir.rs`.
2. **Function-global compilation:** the callee body is compiled per
   *instance*, and the instance key has no error or range component, so the
   body must stay correct for every caller of `from_int<int>`.
3. **No control-flow consumer for the facts that do reach lowering:** even
   when the instance's own range decides both comparisons (`[45,45]`),
   `native::lower::If` does not prune. If it did, the `Fail` instructions
   would vanish and `nir.rs` would derive `may_error=false` on its own. No
   new effect machinery would be needed.

Specialization is not the *first* cause. The facts to specialize on are
never offered to it.

---

## 19. URI / `refined-checks` audit

`bench/refined-checks.ir`: 33 NIR functions, **17,855 bytes**, 26 generic
functions, 27 parameter guards (19 `int`, 6 `str`, 1 `list`, 1 local `str`),
57 tagged Int ops, 46 exact calls (45 with a `may_error` check), 12
`callmulti` (region companions), 11 `tail`. NIR register counts per
function are in `artifacts/refined-checks/summary.txt` (max 40, `<program>`).
Allocation: 23 objects, 1,085 bytes per run; 40 static constants.

### Startup vs steady state (item 42)

| phase | work | allocations |
|---|---|---:|
| module init | `hex_digits` list (1); char-literal list (1); `byte::set`: accumulator (1) + 4 appends (4) + set (1); closures `is_unreserved`, `uri_escape_text` (2) | 10 |
| one-time `uriEscape("a b")` | `encode_utf8` ×3, `substring` ×3, `concat` ×6 | 12 |
| result list | `[check(...), check(...)]` | 1 |
| **steady state**: `check` × 400 × 2 inputs, `Emailish?` scans | StringRegion comparisons only | **0** |

So in this benchmark the **entire Byte/ASCII/`is_unreserved`/URI path runs
once, at startup, on a 3-character string**. The steady state is the
`Emailish?` scanner. Per-byte URI costs (§§10–16) are real but
**unmeasured by the current benchmark suite** (§29, "measurement
clarity").

### Steady-state cost attribution (`check` loop)

| cost | evidence | finding |
|---|---|---|
| **second `Emailish?` scan per iteration** on the email input, statically redundant | plain HIR decides the inner call (`e15 known=1`); the native HIR, after `ExpandNativeBodies`, has an ordinary block call (`e551`, no `known`). NIR `check`: `call 17` then `call 25` | F14 (RC5): ~1.5× the scans (1200 vs 800 per run) |
| scanners are generic: `guard int` on the index per character, tagged `ige`/`iadd`, `char_at` guards the same register twice | the scanners capture `v: str`, so they get the generic key; `hir::blockescape` later removes the closure but not the instance choice | F15 (RC1) |
| region ops are runtime calls: `rt_str_region_check` per character, `rt_str_region_eq` up to 5× per character in `scan_local`, `rt_str_region_is_tcl_alnum` | 18 `rt_str_region_eq` relocations; `char_at` companion is a `callmulti` with an out-pointer return | F16 / F17 (RC3/RC4) |
| **non-ASCII re-seek from byte 0 on every region op** | `utf8SeekBytes = 112,000` per run; `rt_str_region_eq` non-ASCII path: `char_indices().nth(from)` | F16 (RC4) |
| `UriQueryValue?(q)` decided (`bool true; br; unreachable`) | residue of 3 instructions | minor, not numbered |

### Closures and module values (items 43–44, 93)

- Startup: 2 closure allocations (`is_unreserved`: 1 capture; `uri_escape_text`:
  2 captures, `hex_digits` and the `is_unreserved` closure). Nested
  `uri_escape_text` helpers are envless or internal variants: no per-call
  closure allocation.
- Per call: `capture I` = 2 dependent loads (closure → `caps` → slot). The
  module-retained immutable values are neither embedded constants nor
  globals. They are **closure captures**, a representation that does not
  match the "initialized once, immutable thereafter" guarantee
  `hir::modulebinding` proves and then discards. GC does not force this:
  the retained objects are rooted through the closure, while program-lifetime
  objects already exist (`Header` "static" flag for constants, natives and
  env-free closures).
- The bigger consequence is not the loads but **instance selection**:
  capturing any non-Int value makes every exact call to the function
  generic (RC1).

---

## 20. StringRegion / traversal audit

Workloads: `examples/stdlib/ai_text_clean.bot` (traversal plan),
`examples/stdlib/csv.bot` (regions), `refined-checks` (regions inside
virtualized closures).

| question | answer |
|---|---|
| region representation (item 46) | compiler-only: three registers `(base, start, end)`, `start`/`end` tagged *character* indices; `retmulti`/`callmulti` across companion boundaries (an out-pointer for results 2..3 in machine code); **never a heap object**. Escape behavior does not force materialization: every region consumer is `==`/`length`, by construction |
| construction | `regioncheck` = `rt_str_region_check` call (bounds only, no allocation) |
| base access | the base String register stays live (rooted) as long as the region |
| UTF-8 seek | **ASCII base:** direct byte slice. **Non-ASCII base:** `rt_str_region_eq`/`region_one_scalar` walk `char_indices()` from byte 0 on *every* op (`refined-checks`: 112,000 seek bytes) |
| hidden byte offset (item 47) | **survives in machine code where it applies**: `ai_text_clean`'s `clean_from<str,int,str>` carries it as a 4th parameter (`params=4`), `decodecharat %0 %3`, `strbytelen`, `iadd`, tail; `utf8SeekBytes`=0 there. **Does not apply** to the `Emailish?` scanners (not a `peek`-shaped ZeroStart forward scan), which is where the seeks are |
| bounds checks | `ai_text_clean`: the loop's own `index >= length(text)` *and* the inlined traversal access's EOF re-check. Both are `rt_str_len` calls + tagged `ige` per character (F17; SCALAR-ASM-AUDIT finding 6, unchanged) |
| rooting | ordinary shadow slots for the three registers; no extra mechanism |
| helper calls per character | `ai_text_clean`: `rt_str_len` ×2, `rt_str_decode_char_at` (allocates the 1-char String `clean_char` needs), `rt_str_byte_len`, `rt_str_cat` (source-level O(n²) concat), plus `clean_char`'s `rt_str_region_eq` calls |

### Required String question (item 127)

> After StringRegion/traversal removed the major allocation/O(n²)
> pathologies, what are the largest remaining generated-code costs?

1. **Region operations on non-ASCII text re-seek from byte 0** (O(n) per
   op, several ops per character). Regions carry character indices only.
   The traversal plan's byte offset is limited to one loop shape (F16).
2. **Every region/String query is an out-of-line runtime call**:
   `rt_str_len`, `rt_str_region_check`, `rt_str_region_eq` (even for a
   one-character literal), `rt_str_region_is_tcl_alnum`. `StrObj.chars` and
   `.ascii` sit at fixed offsets, but only `listget` got an inline fast
   path (F17).
3. **Generic scanner instances**: `guard int` + tagged index arithmetic per
   character, because the scanners capture `v` (F15, RC1).
4. **Redundant work the semantics already decided**: the second `Emailish?`
   scan (F14) and the double length/EOF check in traversal accesses.

Allocation is no longer the issue. `refined-checks`' steady state allocates
nothing.

---

## 21. Scalar control workloads

| program | functions | bytes | allocations | notes |
|---|---:|---:|---:|---|
| `fib.ir` | 2 | 394 | 0 | `fib<int>` entry range `[-∞,22]`: `widen` dropped the lower bound on the first growth step (F20), so `n < 2` is a **tagged** compare with an `rt_int_cmp` slow path; `n-1`, `n-2` raw on the narrowed `[2,22]` branch; `+` of two call results tagged (unknown result ranges). 2 shadow slots, no `may_error` checks |
| `loop-count.ir` | 3 | 418 | 0 | `work<int>`: fully raw (`[1,500]`); Cranelift folds `(i*3+7)-(i*3)` to 7; `drive<int,int>`: raw decrement, tagged `total` (unbounded) |
| `sum-refined.ir` | 3 | 292 | 0 | `sum<int,int>`: `n ∈ [0,400]` raw; one real call to `step<int>` per iteration; `step`'s `iadd` tagged (accumulator unbounded) |

The controls are healthy and match the committed scalar-asm corpus byte for
byte. They set the baseline for call overhead (`push`/`mov`/`pop`/`ret` +
callee-saves only when values live across calls), integer representation
(raw where ranges are finite and small), and prologue cost (no stack
check instructions; no Vm loads except the constant table).

---

## 22. GC / rooting / call-ABI observations (items 54–56)

- **Allocation-free scalar functions carry no root machinery** (item 55):
  `ascii::*` (both forms), `from_int` (both forms), `char::codepoint`,
  `web::is_unreserved` have 0 safepoints, 0 root candidates, 0 shadow slots.
  F3's safepoint-aware liveness works as intended (positive).
- Root bookkeeping appears exactly where an op may allocate. Tagged
  `iadd`/`isub`/`imul` count as allocating (BigInt overflow path,
  `op_may_allocate`), so **a tagged loop index makes a loop a safepoint** and
  forces a shadow-slot store of the index each iteration (`byte::set`,
  `<program>` listloops). This is **introduced by downstream uncertainty**
  (RC4, F10), not by the calling convention.
- Shadow slots are sized to max-live roots. The one outlier is startup-only:
  a 256-element literal list keeps 256 small-Int *constant* registers as
  root candidates (`web-unreserved-256`: 257 slots, 241 zeroed at entry),
  because NIR registers carry no "known immediate" class (F22, S4).
- **Prologue/epilogue**: frame pointer push/pop always (4 instructions + `ret`);
  callee-saved spills only when values live across calls (2–5 registers in
  composite predicates and loops); the Vm pointer rides in `rdi` into every
  function and helper and is re-shuffled around calls (`mov rdi,r13`).
  No per-function Vm/context loads except the constant table for string
  and `TRUE` constants. This is ABI cost (category I) and is **not** caused
  by any source abstraction.
- **Handlers** add no root liveness on the success path: push/pop of the
  error exit is compile-time.

---

## 23. First-loss matrix (item 117)

"Last present" = the last layer where the fact is definitely available in the
data the next layer reads. **lost** = gone from that data;
**unused** = present but not acted on.

| Fact | Introduced | Last definitely present | First lost / ignored | Visible machine-code consequence |
|---|---|---|---|---|
| Byte nominal identity | source `type Byte = …`; `b: Byte` annotations (types::infer) | semantic HIR; seeds of non-generic instances when *every* exact call proves it | **lost** at `hir::specialize` (`KeyType` drops evidence; `Analyze` seeds generic instances with `any`, ignoring `declaredParamTypes`) | `guard int` + tagged compares in every generic ASCII predicate; `may_error` cascade |
| Byte `[0,255]` | integer domain (`core::type::integerFacts`) | `hir::range` per instance (via view type) | generic instances: **lost** with the evidence. Specialized: **unused** for control flow (raw eligibility only), then repacked tagged at every call boundary | generic: tagged compares with `rt_int_cmp`; specialized: one `sar` per callee |
| Nibble `[0,15]` / HighNibble exact | integer domain + declared results | **machine code** (fully consumed: `FoldPureBitwise`, `RawEligibleShift`, inlining) | only where the enclosing instance is generic (`high_nibble<generic>`: `guard int` on its input) | positive control: one `and` + `sar` |
| UnicodeChar scalar identity | literal / type | NIR (`UnicodeChar` key, tagged immediate) | **unused** by `clif.rs` (`CharCodepoint` → `rt_char_codepoint`) and by the tiny-leaf safe-op list | 2 calls per codepoint |
| `char::codepoint` nonnegative | registry `-result-range nonneg` (hir::range); completions' own table | `hir::range`: `from_int<int>` entry `[0,+∞]` | **unused** by `native::lower::If` | `BelowRange` compare + block per `byte::set` element |
| `char::codepoint ≤ 0x10FFFF` | `hir/completions.tcl` `NativeResultRange` only | completions (node `resultRangeFact`) | **lost**: never enters `hir::range` (siloed lattice) | `from_int` compares tagged instead of raw inside `byte::set` |
| exact char codepoint (literal) | completions | completions only (`hir::range` has no UnicodeChar domain); inside `byte::set` already gone at the listloop element binding | **lost** before specialization | helper call for a literal |
| `effectiveErrors={}` | completions (node field) | HIR node | **unused**: nothing downstream reads the field | callee compares + `faildeclared` blocks; caller `test rax,rax` |
| `effectiveErrors={AboveRange}` | completions | HIR node (+ instance range `[0,+∞]`) | **unused** (node); range **unused** by `If` | `BelowRange` path |
| exact four-member ImmutableSet | **never introduced** (literal codepoints exist transiently inside one completions computation) | — | — | closure capture load + `rt_set_contains` linear `equal` scan |
| `List[Byte]` element type | types (`encode_utf8`, listloop result) | instance keys (element *kind* `int`); `listget` result typing | Byte evidence **lost** in keys; storage is 8-byte tagged words | no guard on elements in specialized code; `guard list`/`guard int` in generic helpers (`esc_bytes<generic>`) |
| listloop index in bounds | `native::lower::ListLoop` (construction) | the lowering procedure's own knowledge | **lost**: NIR has no raw index form and no unchecked `listget` | tagged `ilt`/`iadd` with BigInt paths + safepoint + root store; `listget` tag + bounds re-check |
| module-retained immutable identity | `hir::modulebinding::validate` | that proc's local `values` dict | **lost** immediately (proof not stored) | retained value is a closure capture (2 loads/use), and capturing it forces generic instances (RC1) |

---

## 24. Finding table (item 118)

| ID | Workload | Fact | First loss / non-consumption | Symptom | Category | Severity |
|---|---|---|---|---|---|---|
| C1 | any program with `handle` | calls/returns inside a handle | `hir::range::Expr` had no `handle` case | wrong ranges → miscompile (fixed) | correctness | **S0** |
| C2 | user fn → module closure | module binding captured | HIR `captures` of user functions omit module closures | `NATIVE BUG` at compile time (not fixed) | correctness (crash) | **S0** (loud) |
| F01 | `from_int(45)`, `from_int(Byte)` | `effectiveErrors={}`; instance range decides both compares | `native::lower::If` never decides from ranges; node field never read | 2 compares + 2 fail blocks + caller check | B, F | S3 |
| F02 | `from_int(nonneg)`, `byte::set` | `effectiveErrors={AboveRange}`; entry `[0,+∞]` | `native::lower::If`; one-sided range not `fitsSmall` | `BelowRange` path; tagged compares (329 vs 118 B) | B | S3 |
| F03 | `byte::set` | codepoint ≤ 0x10FFFF | siloed in completions' `NativeResultRange` | tagged instead of raw compares | A | S4 (startup here) |
| F04 | `byte::set`, `char::codepoint` | UnicodeChar is an immediate; body is one shift | `clif.rs` op table → helper; `leafInlineSafeOps` | 2 calls per element | B, E | S3 |
| F05 | ASCII on URI path | declared `b: Byte` (discharged at every call) | `hir::specialize::Analyze` seeds `any`; `RefineParams` skips `any` (the non-specializing `-specialize 0` path honors the declaration and emits no guard) | `guard int`, tagged compares, 377 vs 74 B per leaf; +8.6 ns (+52%) per classification (§8) | A | S2 |
| F06 | whole `web` module | exact callee, Byte/str args | `hir::specialize::Handle`: non-Int captures → generic key | 12/16 generic fns (`web-unreserved-256`), 26/33 (`refined-checks`); 10 guards in URI helpers | D, G | **S1** |
| F07 | ASCII composition | ≤6-compare CFG | `LeafExprStructural` rejects `if` and block calls | 5 calls per classified byte, Bool round trips | E | S3 |
| F08 | generic ASCII chain | callees cannot fail except their (redundant) guard | guards ⇒ `nir.rs` `may_error` ⇒ per-call checks | 16/17 vs 1/10 calls checked | F, E | S3 |
| F09 | every fallible call | per-call `effectiveErrors` | `nir.rs` `summarize_call_effects` (per function, structural) | checks after statically error-free calls | F | S3 |
| F10 | collecting `listloop` | `0 ≤ idx < len ≤ SMALL_MAX` | `ListLoop` → NIR (no raw index / unchecked get) | tagged index ops + safepoint + root stores; `listget` re-check | A | S2 |
| F11 | collecting `listloop` | accumulator uniquely owned until exit | `ListLoop` uses persistent `listappend` | n allocations, O(n²) copies (≈92% of bytes in `ascii-256`) | G | S2 |
| F12 | `byte::set` | temporary list has one consumer; literal elements distinct | no fusion; `setfromlist` O(n²) dedup | extra List + dedup | G, H | S4 |
| F13 | `web::is_unreserved` | constant set `{45,46,95,126}`, retained, immutable | never computed; retention proof discarded | capture loads + `rt_set_contains` + ≤4 `equal` calls | A, G | S3 |
| F14 | `refined-checks` | `Emailish?(s)` decided in the then-branch | `native::ExpandNativeBodies` (pre-HIR) erases type-test identity | 2nd full scan per iteration; 5,144 B duplicate; dead `fnvalue` → extra generic instances | A | S2 |
| F15 | `refined-checks` scanners | index kind from callers; closure removed by blockescape | capture policy decided in specialize *before* blockescape | `guard int`/tagged index per char; 14 guards | D | S2 |
| F16 | `refined-checks` (non-ASCII) | byte position already reached by the scan | regions are char-indexed; traversal plan shape-limited | 112,000 seek bytes/run | C | S2 |
| F17 | strings, lists | `chars`/`len`/`ascii` at fixed offsets | `clif.rs` maps `strlen`/`listlen`/`regioneq`/`regioncheck` to helpers | `rt_str_len` ×2 per char (`ai_text_clean`), region-eq calls | G | S3 |
| F18 | predicates, tagged compares | compare feeds `br`; call returns Bool | `clif.rs` tagged-compare shape; tagged Bool ABI | `cmov` + `cmp r,6` per tagged compare and per predicate return | C | S4 |
| F19 | `char_at<generic>` | the same register was just guarded | guards per (op, operand) blocker, not deduplicated | duplicate `guard int` | B | S4 |
| F20 | `from_int(45)`, `fib`, `refined-checks`' `check` | settled instance result / nonnegative param | `hir::range`: widen-only result summaries; `widen` drops a bound on first growth | call result `[0,255]` vs `[45,45]`; `fib`'s `n < 2` and `check`'s `n <= 0` tagged with `rt_int_cmp` slow paths | A | S3 (hot loop tests) |
| F21 | any program loading `byte.bot` | Byte evidence at every *used* call | `RefinementFacts` intersects calls in unused functions too | lost seed evidence | A | S4 |
| F22 | large literal lists | constant registers are immediates | NIR has no immediate register class | 256 shadow slots at init | I | S4 |

Positive findings (mechanisms that work and should be preserved): P1
nibble/bit fact transport (§9); P2 tiny-leaf inlining for straight-line
leaves; P3 allocation-free functions carry no root machinery (§22); P4
error machinery costs one `test`/`jcc` on the success path (§18); P5
`listget` has an inline fast path (SCALAR-ASM-AUDIT finding 4 is
resolved); P6 the traversal byte offset survives into machine code where it
applies (§20); P7 scalar controls are raw and stable (§21); P8
`refined-checks`' steady state allocates nothing.

---

## 25. Censuses

Mechanical counts come from `tools/census.tcl` over the probe outputs
(`artifacts/census.txt`), and the grouping by cause from reading each
function's NIR.

### Box/unbox/guard census (item 62)

| workload | guards | grouped by cause | `runbox` / `rbox` | tagged Int ops (BigInt slow path) |
|---|---:|---|---:|---:|
| `refined-checks` | 27 (all in generic instances, 26 on parameters) | **3** ASCII leaves on a declared `Byte` param (F05) · **10** URI helpers `high_nibble`/`hex_pair`/`esc_bytes`/`esc_char`/`esc_from` (F06) · **14** pasted `Emailish?` scanners: `char_at` 2×2 (one register guarded twice, F19), `scan_*` 3×2, `tld_ok` 1×2, the dead-`fnvalue` generic copies 1×2 (F15, doubled by F14) | 3 / 2 | 57 (43 in generic instances) |
| `web-unreserved-256` | 13 | 3 ASCII (F05) + 10 URI helpers (F06) | 2 / 1 | 17 |
| `ascii-256` | 0 | — (the same predicates through a proven-`Byte` caller) | 3 / 0 | 4 (loop scaffolding, `from_int` on unbounded input) |
| `byte-set-canonical` | 0 | — | 0 / 0 | 4 (loop index `ilt`/`iadd`: F10; `from_int` on `[0,+∞]`: F02) |
| `hashtable` | 25 (specialized instances, mostly locals) | `mutarray`/`int` on `list_get` of record-like Lists: SCALAR-ASM-AUDIT findings 1/7 (element kinds of heterogeneous Lists), outside this vertical | 1 / 5 | 21 |
| `csv_records` | 29 | same cause as `hashtable` (5 of them in its 8 generic instances) | 4 / 10 | 44 |
| `fib`, `loop-count`, `sum-refined` | 0 | — | 1–2 / 1–4 | 2 / 2 / 1 |

Grouped by root cause: **all 27 guards in `refined-checks` (the web path
and the `Emailish?` scanners) come from generic instances**. Of those, 3
are removable by honoring declared parameter types alone (fix family 1a)
and 24 need the closure/capture specialization policy fixed (1b). No guard on the Byte path is a real runtime
possibility: every argument is statically `int`-kinded at its call site.
Boxing (`runbox`/`rbox`) is rare and cheap (one `sar`, or `shl`+`or`). The
tagged ops with BigInt slow paths are where representation cost actually
sits.

### Generic-call census (item 63)

Static runtime-helper call sites in `refined-checks` (relocations in
`asm.txt`), classified:

| helper | sites | executed in steady state? | classification |
|---|---:|---|---|
| `rt_int_cmp` / `rt_int_add` / `rt_int_sub` / `rt_int_and` / `rt_int_mod` | 36 / 19 / 2 / 1 / 1 | no (BigInt slow paths) | accidentally generic: every operand here is small, but ranges are unknown in generic instances |
| `rt_type_error` | 27 | no (guard failure) | accidentally generic (the guards themselves are the waste) |
| `rt_str_region_eq` | 18 | **yes**, up to 5 per character | exactly known at the call site: a 1-character literal on the other side; non-ASCII path seeks |
| `rt_str_region_is_tcl_alnum` / `_alpha` | 4 / 2 | yes | semantically polymorphic (Tcl Unicode classes), reasonable as a helper |
| `rt_str_region_check` | 2 | yes, per character | exactly known: bounds of a tagged small index |
| `rt_str_len` / `rt_list_len` | 5 / 3 | yes / once | accidentally generic: a field load |
| `rt_list_get` | 5 | no (fallback of the inline fast path) | — |
| `rt_value_eq` | 2 | yes (`domain_loop`) | semantically polymorphic (`veq` on an unknown kind) |
| `rt_set_contains` | 1 | once per URI byte | exactly known set (F13) |
| `rt_char_codepoint` | 1 | once per `byte::set` element | exactly known representation (F04) |
| `rt_list_append` / `rt_list_new` / `rt_set_from_list` / `rt_str_cat` / `rt_substr` / `rt_str_utf8_bytes` / `rt_closure_new` | 1 / 4 / 1 / 4 / 1 / 1 / 2 | startup / one-time | semantically required allocation (the accumulator copying is not, F11) |
| `rt_fail_declared` | 2 | no | cold |

### Allocation census (items 84–87)

| workload | startup | steady state | classification |
|---|---|---|---|
| `refined-checks` | 10 at module init: retained state 2 (`hex_digits`, the set) · temporary construction 6 (char list, accumulator + 4 appends) · closures 2 · plus 12 for the one `uriEscape("a b")` (semantic result strings) and 1 result list | **0** | intentional: 2 + 12 + 1; temporary/composition: 6; closures: 2 |
| `ascii-256` | 1 literal + 1 accumulator | 256 rows (semantic) + **256 accumulator copies** (container growth, O(n²)) | 92% of bytes are accumulator copies (F11) |
| `byte-set-canonical` | 7 (1 literal, 1 + 4 accumulator, 1 set) | — | 5 of 7 are temporary construction |
| `ai_text_clean` | 1 | 55 `decodecharat` 1-char Strings (materialized for `clean_char`'s `str` parameter) + 55 `strcat` (source-level O(n²) concat) | composition + semantic |
| ASCII predicates, `from_int`, `char::codepoint`, `is_unreserved` | — | **0** | item 85 ✓: every scalar predicate/conversion is allocation-free |

Temporary-object lifetimes (item 86): the `List[Byte]` temporary in
`byte::set`, the listloop accumulators, the StringRegions and the
`web` closures never escape. The compiler proves non-escape for the regions
(and for scalar-replaced fixed-shape Lists and virtualized Blocks), not for
the accumulator or the `byte::set` temporary. The retained set and the two
module closures are genuinely retained.

## 26. Code-size and hot-path decomposition

### Size and timing baseline per workload (item 120)

| workload | NIR functions | machine bytes | NIR regs (max fn) | allocations / run | Cranelift time (median, §8) |
|---|---:|---:|---:|---:|---:|
| `bench/fib.ir` | 2 | 394 | 17 | 0 | see §8 |
| `bench/loop-count.ir` | 3 | 418 | 17 | 0 | see §8 |
| `bench/sum-refined.ir` | 3 | 292 | 13 | 0 | see §8 |
| `bench/refined-checks.ir` | 33 | 17,855 | 40 | 23 | see §8 |
| `probes/ascii-256` | 7 | 7,951 | 546 | 514 | — |
| `probes/web-unreserved-256` | 16 | 16,497 | 560 | 268 | — |
| `probes/byte-set-canonical` | 4 | 1,183 | 17 | 7 | — |
| `probes/from-int-literal` | 2 | 168 | 10 | 0 | — |
| `examples/stdlib/*` (9) | 5–55 | 798–21,624 | — | 5–111 | `bench/corpus.tcl`, §8 |

### Code-size decomposition (item 76)

`refined-checks` by *function group* (exact, from `summary.txt`):

| group | bytes | share | note |
|---|---:|---:|---|
| `Emailish?` body, copy 2 | 5,144 | 28.8% | pure duplication (F14), incl. a 769 B dead-`fnvalue` generic instance |
| `Emailish?` body, copy 1 | 5,144 | 28.8% | generic scanners (F15): 14 guards |
| URI escaping helpers | 3,216 | 18.0% | all generic (F06) |
| ASCII chain + `is_unreserved` | 1,674 | 9.4% | the same code as `<int>` instances would be ≈570 B (F05/F06): ≈1,100 B of generic overhead |
| `<program>` | 1,172 | 6.6% | startup |
| `byte::set` + `from_int` + `char::codepoint` | 1,001 | 5.6% | startup |
| `check` | 504 | 2.8% | steady-state driver |

By *instruction class* (heuristic, `tools/asm-classes.py`: classifies by
instruction shape, not provenance; order of magnitude only):

| class | `refined-checks` | `csv_records` | `byte-set-canonical` |
|---|---:|---:|---:|
| computation and moves ("other") | 46% | 40% | 37% |
| guard / error check (tag tests, `test rax,rax` after calls) | 13% | 14% | 11% |
| callee-saved spills/reloads | 12% | 14% | 11% |
| root-slot stores | 8% | 10% | 14% |
| frame (`push`/`pop`/`sub rsp`/`ret`) | 7% | 10% | 11% |
| Bool materialization / re-test | 5% | 3% | 5% |
| runtime helper call instructions | 4% | 4% | 6% |
| Botlish call instructions | 2% | 4% | 3% |

(The 256-element probes are dominated by 256 root-slot stores for the
literal list at program init (F22) and are not representative.)

### Hot-path instruction decomposition (items 77–78)

Static instruction counts along the common (fast) path, from `asm.txt`:

| function | source semantics | generated (fast path) |
|---|---|---|
| `ascii::is_digit<int>` | 2 comparisons + conjunction | 11: frame 4 + `ret`, 1 unbox (`sar`), 2 `cmp` + 2 `jcc`, 1 Bool constant |
| `ascii::is_digit<generic>` | same | 36: frame + callee-saves 12, guard 5, 2 × (tag test + `cmp` + `cmov` Bool + `cmp r,6` + `jcc`) ≈ 17, moves 2 |
| `ascii::is_alphanumeric<int>` | 1 disjunction of two calls | 19 own (+ callees): frame + 2 callee-saves 11, 4 arg/Vm moves, `call`, `cmp rax,6`, `je`, Bool; a second call when the first is false |
| `web::is_unreserved<generic>` | 1 call, 1 membership, 1 disjunction | ≈36 own: frame + 3 callee-saves 13, `call` + `may_error` test + Bool test, 2 capture loads, `rt_set_contains` + NO_VALUE test + Bool test, Bool re-materialization |
| `byte::from_int<int>`, raw (`[45,45]`/`[0,255]`) | 0 comparisons needed at a proven-safe site, 2 in general | 12: frame 4 + `ret`, `mov`+`sar`, 2 × (`cmp`,`jcc`), return move; caller: `mov`, `call`, `test`, `jne` |
| `byte::from_int<int>`, tagged | 2 comparisons (value may be a BigInt) | 29 (§10) |
| `byte::set` loop body | codepoint, 1 range check, append | ≈53 per element + callees: tagged loop test 11, `listget` tag/bounds + load 11, 2 calls into `char::codepoint` (+ helper), `from_int` call + check, `rt_list_append` + check, 3 root-slot stores, tagged `iadd` with overflow test 10, backedge |
| `scan_local<generic>` (StringRegion) | one character classification per iteration | per character: `guard int`, tagged `ige` + Bool, `callmulti char_at` (its own 2 guards, overflow-checked `iadd`, `rt_str_region_check`, out-pointer return), `rt_str_region_is_tcl_alnum`, up to 5 `rt_str_region_eq`, tagged `iadd`, `tail` |

### Botlish vs Cranelift (items 79–81)

Every redundancy in this report is already present in the NIR. Botlish
emitted it: guards, tagged ops, `faildeclared` blocks, helper ops, the
duplicated scanner, the listloop scaffolding. The Bool
`cmov`-then-`cmp r,6` shape comes from `codegen/clif.rs`'s tagged-compare
lowering (fast/slow paths merged into a Bool value), not from Cranelift. Cranelift
optimizes the reasonable shapes it is given well: it folds `br(bool(icmp))`
for raw compares, folds `(i*3+7)-(i*3)` to 7, and removes the dead
`rawint` materializations. It does *not* remove the dead `fnvalue` in
`check` (two dependent constant-table loads before each `Emailish?` call
survive, F14). Register-allocation
residue exists (Vm pointer shuffled through callee-saved registers around
calls, occasional redundant `mov rsi,r14` reloads) but it is small next to
the higher-level redundancy and is not pursued here (item 81).

---

## 27. Root-cause clusters

### RC1: instance selection ignores proven parameter facts

**Findings:** F05, F06, F08, F15, F19, F21. It also caps RC2's leverage
(F01/F02 once an instance is shared).

**Mechanism.** One instance per `{block, argument kinds}`. Named evidence
is dropped from the key and restored only in non-generic seeds, and only if
every syntactic call proves it. Generic instances are seeded with `any`,
not with the block's declared parameter types. Exact calls of closures
with non-Int captures always get the generic key. That rule is applied
before `hir::blockescape` proves the closure never exists, and it applies
to every module function touching a retained module value. A generic
instance that is also a materialized Block value is "open", so no caller
range reaches it either.

**Evidence.** The same five ASCII predicates: 0 guards, 74 B leaves, 1/10
checked calls through a proven-Byte caller (`ascii-256`); 3 guards, 377 B
leaves, 16/17 checked calls through `web::is_unreserved` (`web-unreserved-256`).
All 27 guards in `refined-checks` sit in generic instances (§25).

### RC2: proven value and completion facts have no control-flow consumer

**Findings:** F01, F02, F09, F20, and the bounds half of F10.

**Mechanism.** `hir::range`'s per-instance facts are consumed for
*representation* (raw vs tagged), *bitwise folding* and *closed-result
constants*, never to decide a comparison or prune a branch. `If` prunes
only on type-level HIR reachability. `effectiveErrors`/`mayReturnNormally`
are written and never read. `may_error` is re-derived per function from NIR
structure.

**Evidence.** `from_int<int>` with entry range `[45,45]` (or `[0,255]`)
compiles both comparisons and both `faildeclared` blocks. With `[0,+∞]`
(`byte::set`) the `BelowRange` path survives. One consumer would remove
both, and `may_error` would then fall out of `nir.rs` unchanged (§10, §18).

### RC3: call boundaries are opaque

**Findings:** F04, F07, F17, F18, plus the ABI costs of §22.

**Mechanism.** Tagged-word ABI everywhere (a proven-small Int is repacked
at every boundary). Bool is a tagged word re-tested by every caller. Tiny-leaf
inlining accepts only straight-line bodies of Int ops. Several trivial ops
(`charcodepoint`, `strlen`, `listlen`, 1-character `regioneq`) are runtime
helper calls.

**Evidence.** ASCII classification: ≈80 instructions with perfect
representation, ≈85% of them call overhead (§14). `char::codepoint`: 2 calls
for one shift (§12).

### RC4: compiler-internal representations drop facts they could carry

**Findings:** F10, F11, F12, F16, F22.

**Mechanism.** The listloop index lives outside HIR bindings and NIR has no
raw index or unchecked element op. The uniquely owned accumulator uses the
persistent `listappend`. StringRegions carry character indices only. NIR has
no immediate register class.

**Evidence.** 32,640 accumulator element copies and 256 extra allocations
for a 256-element loop (§17). 112,000 seek bytes per `refined-checks` run
(§20).

### RC5: front-of-pipeline rewrites, module lowering and siloed lattices erase identity

**Findings:** F03, F13, F14, the module-capture half of F06, and the
correctness bug C2.

**Mechanism.** `ExpandNativeBodies` rewrites raw IR before HIR can decide
type tests. Retained module values are lowered as closure captures, and
`hir::modulebinding`'s proof is discarded. Completions keeps its own native
result table (`char_codepoint`'s upper bound, exact literals) instead of
sharing the codegen-facing lattice.

**Evidence.** The redundant second `Emailish?` scan and its duplicate
5,144 B body (§19). The constant set is never known (§16). `from_int`'s
comparisons stay tagged inside `byte::set` (§11).

The brief's example hypotheses map onto these as follows. "Call-site facts
not part of specialization" and "representation selection sees only coarse
runtime kind" are both RC1. "Post-analysis facts computed too late" splits
into RC2 (never consumed) and RC5 (erased/siloed). "Container exactness not
represented" is RC5/RC4. "Tiny-call overhead / inlining gap" and "generic
runtime helper boundary" are RC3.

## 28. Candidate fix families

None of these is implemented. The complexity and risk estimates name the
affected layers.

| family | root cause | layers | complexity | semantic risk | notes |
|---|---|---|---|---|---|
| **1a** seed every instance (generic included) with the block's `declaredParamTypes` | RC1 | `hir/specialize.tcl` (`Analyze`) | **low** | **low**: consumes an obligation `verifyDeclaredParams` already discharged at every exact call, and `hir::callables` forbids erasing a typed callable. This is exactly what `-specialize 0`'s `SemanticInstances` already does. M1 must re-verify that the erasure check is complete for every value position (e.g. List elements), because 1a's soundness rests on it | removes typed-param guards; makes `is_unreserved` → `is_alphanumeric` an `<int>` call even while `is_unreserved` stays generic |
| **1b** let exact calls of closures specialize when `hir::blockescape` proves they are never materialized, or when every capture is a retained immutable module value | RC1 | `hir/specialize.tcl` policy + pass ordering with `hir/blockescape.tcl` | medium | low–medium (capture seeds are already joined across creations; code growth stays bounded by `limit`) | removes F06/F15 guards (24 of 27 in `refined-checks`) |
| 1c range/exact facts in instance keys | RC1/RC2 | specialize, range | high | medium (code growth, fixpoint interaction) | not supported by the evidence yet: 1a/1b plus 2a cover the observed cases |
| 1d compute `RefinementFacts` over *used* exact calls only | RC1 | specialize | low | low | F21 |
| **2a** range-decided comparisons and branches in lowering (the control-flow twin of `FoldPureBitwise`) | RC2 | `native/lower.tcl` (`NativeCall`, `If`) | medium | medium: only as sound as `hir::range`, see C1. Pair with a guard that `hir::range::Expr` covers every node kind | removes `from_int` residue wherever the instance's joined facts decide it; `may_error` follows automatically |
| 2b branch feasibility inside `hir::range` (import completions' `RangeEmpty` rule) | RC2 | `hir/range.tcl` | medium | medium | tighter joins after dead `fail` branches; changes codegen-facing facts, as intended |
| 2c split `may_error` into declared vs semantic parts, and give each call site its declared part from `effectiveErrors` | RC2 | lower (per-call flag), `nir.rs` | medium | medium: must still honour non-declared failures (guards, RANGE, stack limit) | removes the caller check after `from_int(45)` without touching the callee |
| **2d** threshold widening (widen to the nearest known constant bound, not straight to ±∞) and non-locking result summaries | RC2 (F20) | `hir/range.tcl` | low | low | `fib`'s `n < 2` and `check`'s `n <= 0` become raw |
| **3a** extend tiny-leaf inlining to small branchy predicates (`if`/`and`/`or` over safe ops) and to leaves whose only calls are themselves inlinable | RC3 | `native/lower.tcl` (`Leaf*`) | medium | low–medium (existing leaf discipline; bounded budget) | ASCII ≈80 → ≈10 instructions per byte; note that an inlined body still sees the *callee instance's* ranges, not the call site's |
| **3b** inline trivial helpers in codegen: `charcodepoint` (one shift), `strlen`/`listlen` (field load + tag), ASCII-base `regioneq` against a 1-char literal; add `charcodepoint` to `leafInlineSafeOps` | RC3 | `codegen/clif.rs`, lower op list | low | low | F04, F17 |
| 3c raw-scalar internal entry for specialized instances with proven-small parameters (like the existing internal/fields variants) | RC3 | lower, codegen | medium–high | medium | removes per-boundary repack; small per-call gain; later |
| 3d Bool in flags / 0-1 across internal boundaries | RC3 | codegen ABI | high | medium | F18; low leverage |
| **4a** listloop: raw index + in-bounds element load op | RC4 | `native/lower.tcl` `ListLoop`, `nir.rs`, `clif.rs` | low–medium | low (construction guarantees `idx < len ≤ SMALL_MAX`, list immutable) | F10; also removes the index safepoint and root stores |
| **4b** listloop accumulator as a builder (growable buffer frozen at exit; the MutableArray substrate already exists) | RC4 | lower, runtime | medium | medium (break/continue/error discard paths, rooting) | F11: O(n²) → O(n) copies, n allocations → O(log n) |
| 4c listloop → `setfromlist` fusion; distinct-literal set construction | RC4 | lower | medium | low | F12; low leverage (startup) |
| 4d byte offsets carried in StringRegions (or a per-String last-position cache) | RC4 | stringregion, lower, runtime | high | medium | F16: non-ASCII scans |
| **5a** keep predicate identity through native-body substitution: substitute after HIR resolution/refinement, or only where HIR did not decide the call (`native/native.tcl`'s own header already notes the "run after resolution" alternative) | RC5 | `native/native.tcl`, `hir` | medium | low–medium | F14: one of three steady-state scans in `refined-checks`, 5 KB of code |
| **5b** retained module values as program-lifetime constants (persist the `hir::modulebinding` proof, reference retained values directly, keep module functions envless) | RC5 (+RC1, C2) | modulebinding, aot/resolve captures, lower, runtime static objects | high | medium | fixes C2 at its root, removes capture loads (F13), dissolves the module half of F06 without a policy change |
| **5c** one native-result fact source: move `char_codepoint`'s `[0,0x10FFFF]` into the registry metadata `hir::range` reads | RC5 | `core/native.tcl`, `hir/range.tcl` | low | low | F03 |
| 5d compile-time evaluation of retained initializers (exact constant sets) | RC5 | new | high | medium | only after 5b; enables constant-folded membership (§16) |

### Leverage / complexity / semantic-risk matrix (item 119)

| Root cause | Findings explained | Candidate fix family | Leverage (evidence) | Complexity | Semantic risk |
|---|---|---|---|---|---|
| RC1 instance selection ignores proven parameter facts | F05 F06 F08 F15 F19 F21 (+caps RC2) | 1a + 1b (+1d) | **highest on the fenced vertical**: all 27 guards in `refined-checks`; 26/33 generic functions in `refined-checks`; ASCII leaves 377 → 74 B; the 5 checked calls inside the ASCII chain become unchecked (as in `ascii-256`) | low (1a) / medium (1b) | low / low–medium |
| RC2 no control-flow consumer for proven facts | F01 F02 F09 F20 (F10 bounds) | 2a + 2d (+2c) | every safe/partially safe `from_int` site; `BelowRange` in `byte::set`; hot loop tests in `fib`/`check`; any range-decided branch in general | medium (2a) / low (2d) | medium (depends on `hir::range` soundness) / low |
| RC3 opaque call boundaries | F04 F07 F17 F18 | 3a + 3b | ASCII per-byte path ≈8× fewer instructions after RC1; `char::codepoint` 2 calls → 1 shift; string length/equality helpers on every character | medium (3a) / low (3b) | low–medium / low |
| RC4 internal representations drop construction facts | F10 F11 F12 F16 F22 | 4a + 4b (+4d later) | every collecting `listloop` iteration; O(n²) → O(n) copies (≈92% of bytes in the ASCII probe); non-ASCII region scans | low–medium / medium / high | low / medium / medium |
| RC5 identity erased or siloed before analysis | F03 F13 F14 (F06) C2 | 5a + 5b + 5c | `refined-checks` steady state (redundant scan, 29% of its code); the constant set; the C2 crash | medium / high / low | low–medium / medium / low |

## 29. Recommended machine-level milestone order

Criteria, in the brief's order: semantic safety, breadth/leverage,
measurement clarity, dependency order, implementation complexity,
preservation of the source fence. Every milestone below consumes facts
Botlish already proves. None needs a new proof or a `.bot` change.

0. **M0: correctness and measurement first.** (a) Fix C2 minimally: a
   user function that references a module closure must capture it, the
   way module functions already do. This is a correctness fix, and the
   principled representation change is M2. (b) Add a *new* steady-state
   URI-escaping / Byte-classification benchmark. No current benchmark
   exercises the Byte/ASCII/URI path in steady state (in `refined-checks`
   it runs once, at startup, on "a b"), and until C2 is fixed such a
   benchmark cannot be written as a function-driven loop. A new benchmark
   file changes no existing fenced source. Record its baseline on the
   pre-M1 compiler so that A→B stays clean.

1. **M1: instance fact transport** (1a, 1b, 1d). Broadest leverage on the
   fenced vertical, lowest semantic risk (it consumes obligations the
   compiler already enforces), and a prerequisite for M3: range-decided
   branches are only as precise as the instances they run in. Measurable
   on the existing suite through `refined-checks`' scanners (F15: per-character
   guards in the steady state) and on guard/instance counts.
2. **M2: module values as program constants** (5b, which also fixes C2).
   It removes the root of the web module's generic-instance problem that
   1b only works around, makes the URI path callable from ordinary
   functions (unblocking steady-state measurement), and is the precondition
   for any constant-set work. It is higher complexity than M1, so it comes
   second; if M1's 1b already specializes module closures, M2's code
   benefit shrinks but its correctness value (C2) does not.
3. **M3: control-flow consumers for proven facts** (2a, 2d, then 2c).
   The error-edge and range-check residue (`from_int`, `byte::set`) plus
   hot loop tests. It follows M1 because instance precision determines how
   often a joined range decides anything. It follows C1 (done here) because
   it raises the stakes of `hir::range` soundness. The entry criterion
   should be a check that `hir::range::Expr` handles every HIR node kind.
4. **M4: loop and collection scaffolding** (4a, 4b). Independent of M1–M3,
   very clear measurement (allocation and copy counters), large algorithmic
   leverage for any collecting loop, but low weight in the *current*
   benchmark suite (no hot listloop). Could be pulled ahead of M3 if a
   listloop-heavy benchmark is added.
5. **M5: call boundaries** (3b first, then 3a). After M1 the ASCII chain
   is `<int>`, and inlining it then yields the ≈10-instruction form. 3b is
   cheap and could ride along with any earlier milestone.
6. **M6: string identity and positions** (5a, then 4d; 5c can ride along
   with M3). 5a is the largest single steady-state item in the existing
   benchmark (F14). It is ordered late only because it is workload-specific
   (validator predicates with `-native-body`), not broad. If benchmark
   movement is the priority, 5a is the cheapest large measured win and can
   be done at any point.

### Path to the machine-code fence (item 131)

```
FINAL SEMANTIC SOURCE FENCE            (this audit; C1 fixed)
        ↓
M0  C2 correctness fix + steady-state URI/Byte benchmark
        ↓
M1  instance fact transport            (declared params, closure/capture policy)
        ↓
M2  module values as program constants (fixes C2)
        ↓
M3  range/completion facts decide control flow
        ↓
M4  loop and collection scaffolding
        ↓
M5  call boundaries (trivial helpers inline, branchy-leaf inlining)
        ↓
M6  string identity and positions (native-body substitution, region byte offsets)
        ↓
MACHINE-CODE FENCE                     (re-run this audit's probes + census; compare A→B)
        ↓
later historical .bot modernization    (C = modern source + improved backend)
```

### Required specialization question (item 129)

> Which semantic facts would have to enter the specialization key or callee
> assumptions to remove the broadest set of observed redundancies?

Mostly *callee assumptions*, not keys:

1. the block's own **declared parameter types**, as the seed of every
   instance (1a);
2. **exact-call-only reachability of closures**: "this closure is never
   materialized" (from `hir::blockescape`) and "this capture is a retained
   immutable module value" (from `hir::modulebinding`) (1b/5b).

Those two cover all 27 guards in `refined-checks` and the `may_error` cascade. Range
facts do **not** need to enter keys for any observed case. They already
reach instances through exact-caller propagation, and what they lack is a
control-flow consumer (2a). Error sets need not enter keys either: once
2a prunes range-decided `fail` blocks, `may_error` follows. Call-site
declared-error facts (2c) are only needed for instances shared between
safe and unsafe callers.

---

## 30. Tests / regression

### Commands and exact counts

| run | before (`39bac41`, unmodified) | after (C1 fix + tests) |
|---|---|---|
| `tclsh9.0 tests/all.tcl` (interp + compile) | interp **2102/2102**, compile **2102/2102** (0 skipped, 0 failed; 14m48s) | interp **2105/2105**, compile **2105/2105** (the 2102 + 3 new C1 tests; 0 skipped, 0 failed; 14m41s) |
| `cargo test --release --manifest-path native/Cargo.toml` | **60 passed, 0 failed** | **60 passed, 0 failed** |
| `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl` | interp **2102/2102**, compile **2102/2102** (14m24s) | interp **2105/2105**, compile **2105/2105** (0 skipped, 0 failed; 14m38s) |

All runs used `LANG=C.utf8 LC_ALL=C.utf8`, Tcl 9.0.1 and a release build of
`native/`. The "after" runs were executed sequentially: two concurrent
`tests/all.tcl` runs share `tests/`' temporary files (`makeFile`) and
interfere, so a first, concurrent attempt was discarded.

### C1 regression tests (`tests/errors.test`)

- `errors-handled-call-joins-callee-entry-range`: four-backend parity plus
  interp value for `handle-range-entry`'s shape;
- `errors-handler-return-joins-result-range`: the same for a `return` inside a
  handler body;
- `errors-handled-byte-from-int-bigint`: `byte::from_int(45)` + a handled
  BigInt `from_int`, through a real module file.

All three **fail on the unfixed tree** (verified by stashing `hir/range.tcl`)
and pass after the fix.

### No benchmark program changes

Before/after NIR, byte-for-byte (`native::nir`), for `bench/fib.ir`,
`bench/loop-count.ir`, `bench/sum-refined.ir`, `bench/refined-checks.ir` and
all nine `examples/stdlib/*.bot`: **13/13 identical**. None of them contains
a `handle`. Probe programs: NIR identical for all of them. One *fact*
changed: in `probes/web-unreserved-256.bot`, `from_int<int>`'s entry range
was `[0,+∞]` before the fix (unsound: only `byte::set`'s call was visible)
and is `[-∞,+∞]` after. Its NIR is unchanged because `[0,+∞]` was not
`fitsSmall` either way. The artifacts committed for probes with handlers are
the post-fix outputs.

### Benchmark regression (item 114)

The same `tools/bench-baseline.sh` (5 sessions × `bench.tcl -runs 5`, plus
the native corpus) and the steady-state probes, re-run on the final tree
(`artifacts/bench-after/`):

| program | Cranelift A (median) | after (median) | Δ | A spread |
|---|---:|---:|---:|---:|
| `fib.ir` | 182.20 µs | 182.16 µs | −0.02% | 0% |
| `loop-count.ir` | 1.80 µs | 1.80 µs | 0% | 40% |
| `refined-checks.ir` | 546.55 µs | 544.36 µs | −0.4% | 2% |
| `sum-refined.ir` | 1.32 µs | 1.32 µs | 0% | 125% (one outlier session) |
| `steady-ascii-capture` | 6,535.77 µs | 6,529.35 µs | −0.1% | <1.5% |
| `steady-ascii-param` | 4,293.27 µs | 4,279.97 µs | −0.3% | <1.5% |
| `steady-ascii` | 3,601.48 µs | 3,584.31 µs | −0.5% | <1.5% |

All values agree across backends in every session (`✅`). The corpus's
structural columns are identical: code bytes, function counts, guards,
box/unbox/raw-op counts, allocated objects and bytes, element copies. All
timing deltas are within run-to-run noise. As expected: no benchmark
program's NIR changed (above).

### Artifacts committed (`audit/comprehensive-generated-code/`)

| path | content |
|---|---|
| `tools/probe.tcl`, `tools/census.tcl`, `tools/asm-classes.py`, `tools/measure.tcl`, `tools/bench-baseline.sh`, `tools/bench-summary.py` | the non-production inspection helpers used for every number in this report |
| `probes/*.bot` | call-shape harnesses (origins in §2) |
| `bugs/*.bot` | C1 and C2 reproductions |
| `artifacts/<workload>/` | `completion`, `spec`, `params`, `callfacts`, `summary`, `effects`, `roots` (+ `nir`/`asm`, or `nir-excerpt`/`asm-excerpt` for the 256-element probes, whose `<program>` is dominated by the literal list) |
| `artifacts/census.txt`, `artifacts/asm-classes.txt` | §25/§26 raw counts |
| `artifacts/bench-A/`, `artifacts/bench-after/`, `artifacts/steady-timing.txt` | §8 and §30 measurements |

Full `refined-checks`/stdlib disassembly is not duplicated here. It is
byte-identical to the committed `audit/native-scalar-asm/` corpus (§3).

## 31. Source-fence confirmation

| stop condition (item 133) | status |
|---|---|
| 1. no frozen `.bot` source changed | ✅ `git diff 39bac41 -- lib/ bench/ examples/` is empty |
| 2. no optimizer/representation/lowering/backend behavior changed | ✅ The only production change is the C1 correctness fix in `hir/range.tcl` (analysis soundness). It adds recorded calls and return/break ranges, never narrows, and changes no benchmark program's NIR |
| 3. baseline captured | ✅ §8 (timing, code size, functions, allocations, guards) |
| 4. pipeline and fact ownership documented | ✅ §4–§7 |
| 5. Byte, Nibble, UnicodeChar, error completion, List, ImmutableSet, StringRegion, module values traced | ✅ §9–§20, §23 |
| 6. every major inefficiency has a first-loss / first-non-consumption point | ✅ §23–§24 |
| 7. Nibble/bit analyzed as positive control | ✅ §9 |
| 8. `from_int(45)` safe-call residue explained | ✅ §10 |
| 9. `byte::set` impossible `BelowRange` explained | ✅ §11 |
| 10. ASCII call/guard overhead explained | ✅ §13–§14 (measured: +52% generic) |
| 11. constant ImmutableSet generality explained | ✅ §16 |
| 12. listloop bounds/helper/accumulator overhead explained | ✅ §17 |
| 13. remaining StringRegion/traversal costs identified | ✅ §20 |
| 14. findings clustered into a small number of root problems | ✅ 5 root causes (§27) |
| 15. fix families ranked | ✅ §28 |
| 16. milestone order produced | ✅ §29 |
| 17. ordinary, Rust and GC-stress regressions pass | ✅ §30 |
| 18. benchmarks unchanged within noise | ✅ §30 |
| 19. FINAL SEMANTIC SOURCE FENCE intact | ✅ |
| 20. no machine-level fix implemented | ✅ (C1 is a soundness fix to an analysis, reported separately; it removes no code and changes no benchmark's machine code) |

**The next milestone should be chosen from §27–§29. This audit does not
pre-select one beyond the evidence-based order given there.**
