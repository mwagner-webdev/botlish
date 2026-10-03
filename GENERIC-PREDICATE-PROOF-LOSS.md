# Generic predicate proof loss (`lib/web.bot`'s `tld?` / `domain?`)

This file tracks one question and the fixes it led to: why `tld?` and
`domain?` (`lib/web.bot`, the scanner closures inside `web::emailish?`) are
compiled under `<generic>` keys, and where the facts the compiler already
proves about them are lost before they reach machine code. The
investigation found five independent loss points. Each fix gets its own
section below; the status table is the index.

| # | loss point | where (at the commit that fixed / last checked it) | status |
|---|---|---|---|
| 1 | value-capturing closures with a non-Int capture get the generic key | `hir/specialize.tcl:937-957` (`Handle`) | **fixed** ([Loss point 1](#loss-point-1-int-key-positions-for-capturing-closures)): keys and Ranges, no machine-code change until 4 and 5 |
| 2 | never-entered generic Block-value entries of de-closured closures stay in the analysis | `hir/aot.tcl:269`, `hir/specialize.tcl:829`; fixed in `hir/specialize.tcl:1210` (`DormantInstances`), `hir/range.tcl:2250` (`OpenInstances`), `:2378`, `:2642`, `hir/rangerec.tcl:269`, `native/native.tcl:225` | **fixed** ([Loss point 2](#loss-point-2-dormant-instances)) |
| 3 | call sites read the ascending phase's callee result summaries, never narrowed | `hir/range.tcl` `Fixpoint` / `Call` | **fixed** (this report, [Fix 3](#fix-3-result-summary-narrowing)) |
| – | prerequisite found while verifying fix 3: `hir::range` never visited a call's callee expression (unsound; native miscompiles on `main`) | `hir/range.tcl` `Call` | **fixed** ([Callee-position calls](#callee-position-calls-soundness-fix)) |
| – | prerequisite found while verifying fix 3: the `bit_and` identity fold trusted interval Ranges (unsound; native miscompiles on `main`) | `native/lower.tcl` `FoldPureBitwise` | **fixed** ([`bit_and` identity fold](#bit_and-identity-fold-soundness-fix)) |
| – | prerequisite found while verifying point 2: `hir::blockescape` never examined a closure nested in a candidate's own literal or in a sibling capturer (unsound; native crashes on `main`, wrong results with `-block-escape-opt 0` once point 2 trusts it) | `hir/blockescape.tcl` `Bindings` | **fixed** ([Blockescape: nested capturers](#blockescape-nested-capturers-soundness-fix)) |
| – | prerequisite found while preparing point 1: `hir::blockescape` never counted a literal's generic instance as a de-closure target when an exact call selected it next to specialized ones (pre-existing NATIVE BUG; with point 1, closures called with an Int and another kind would lose de-closure) | `hir/blockescape.tcl:194` (`RelevantInstances`) | **fixed** ([Blockescape: a called generic instance](#blockescape-a-called-generic-instance)) |
| 4 | counted loops always use tagged compare/advance; their bounds are tagged RawInt consumers | `native/lower.tcl` `CountLoop`, `native/rawabi.tcl:696-709` | open |
| 5 | the RawInt ABI never reaches de-closured (internal-capture) functions | `native/lower.tcl:2246` (`InternalFunction`), `:4676` (`abiCall`), `native/rawabi.tcl:64-66` | open |

## The investigation

Measured on `bench/refined-checks.bot` (which runs `web::emailish?`) at
`9376f99`, before the merge of the collecting-loops work; the loss points
were re-checked on the merged tree (`main` at `07b373c` plus this work) and
the line numbers above are from there.

### What makes them generic (point 1)

`hir::specialize::Handle` gives a value-capturing closure a real key only if
every *structural* capture's seed has kind `int` (lines 900-908). Otherwise
every key position becomes `any`, except an exact callable (line 926,
EXACT-CALLABLE-CLOSED-CALLER.md).

* `tld?` captures `(scan_while, n)`: `scan_while` is a closure, so its seed
  is a block type and the check fails.
* `domain?` captures `(n, char_at, tld?, label_char?)`: it fails on the
  three closures.
* Checking the *flattened* captures (what the de-closured function actually
  receives, `n v`) would still fail, on `v : str`.

The discarded fact is real: both call sites pass `int` (`tld?(j + 1)`,
`domain?(local_end + 1)`), and the closed-caller theorem
(`hir::specialize::closedCallerTheorem`) gives `int` for both instances. Both
instances are closed (blockescape proves every reference is a call; one
caller each).

What the generic key itself costs is a single check: `native/rawabi.tcl:120`
reads RawInt eligibility from the key (`$key eq "int"`), not from the
closed-caller theorem, so `tld?.i` (closed, entry `[2, 2^62-1]`, fits small)
and `domain?.start` (`[1, 2^62-1]`) are rejected as `not-int`. The
generic-instance exclusions in `hir::stringregion`, `hir::traversal` and
`hir::escape` do not apply to these two bodies.

### Why the bodies are tagged anyway (points 2-5)

`hir::range`'s raw-op decision (`native::lower::RawEligibleCall`) is per
expression and Range-driven, not key-driven. `tld?`'s `e == n`, `e - i` and
`>= 2` were tagged because `e = scan_while(i, is_tcl_alpha)` read
`[-∞, 2^62-1]` at the call site while the callee's own result Range is
`[0, 2^62-1]` (point 3; at `9376f99` the values were `[-∞, 2^62-2]` vs
`[2, 2^62-2]`). The other points only matter once the key is relaxed:

* **Point 2.** `hir::aot::materializedBlocks` counts every bind of a capturing
  closure as materializing its Block value (`hir/aot.tcl:286`), so
  `hir::specialize::Analyze` keeps an edge to the closure's generic instance
  (`hir/specialize.tcl:820`). Today that is harmless for `tld?`/`domain?`:
  the generic instance *is* the direct-call target and is proven closed.
  With `<int>` keys it splits off as an open, never-entered instance whose
  own calls still feed `hir::range` (which skips contributions *to* open
  instances, not *from* them). Measured with the key relaxed: `tld?<int>.i`
  drops from `[2, …]` to `[-∞, …]` because `domain?<generic>` (start unknown)
  calls it; `-emit-native-executable` refuses a user program of the same
  shape (`tests/exact-callable-executable.test:116`: `char_at<generic>` and
  `domain?<generic>` are open and keep `UnknownParameterKind` guards); 21
  existing tests fail, 15 of them label/theorem pins in
  `closed-closure-entry-facts.test`. `web.bot` itself escapes the readiness
  check only because `native::executable` checks it before native
  implementations are expanded. This is limitation 2 of
  EXACT-CALLABLE-CLOSED-CALLER.md, now reaching `tld?`/`domain?`.
* **Point 4.** `CountLoop` emits its compare and advance as tagged ops
  (`CountOps`: `ilt`/`ile`/`igt`/`ige`, `iadd`/`isub`) whatever the Ranges
  prove, and the RawInt demand rule mirrors this by classifying every count
  loop bound as a tagged consumer ("count loop bound"). With points 1-3
  repaired, `tld?<int>.i` and `domain?<int>.start` are RawInt-eligible but
  `suppressed-mixed-tagged-use`: `domain?`'s start bounds its own loop, and
  `tld?`'s `i` reaches `scan_while`'s loop. The per-character loop header of
  `domain?` and `scan_while` stays tagged in every configuration.
* **Point 5.** `tld?` and `domain?` are only ever emitted as de-closured
  internal-capture functions. `InternalFunction` applies only the self-tail
  raw-parameter rule and never reads the ABI plan, and the call-site
  `abiCall` test excludes those calls; by design ("only the canonical
  function of an instance has a physical raw signature"). Forcing the plan
  raw on top of points 1-3 gave `ABI RawInt` in the plan but untouched
  functions: no raw parameters, callers still `rbox`.

Smaller items: the captured `n` is a hidden trailing parameter, always
tagged (`native/rawabi.tcl:162`); each `tld?` call materializes an
`is_tcl_alpha` native value to pass to `scan_while` (limitation 1 of
EXACT-CALLABLE-CLOSED-CALLER.md).

### Counterfactual matrix (`9376f99`, scratch patches, not committed)

| configuration | `tld?` key | `tld?` ops | `tld?.i` entry | `tld?` self Ir/run | total Ir/run |
|---|---|---|---|---|---|
| baseline | generic | `ieq` `isub` `ige` | `[2, 2^62-1]` | 24,800 | 5,647,959 |
| point 1 only (`int` keys) | int | unchanged | `[-∞, 2^62-1]` (lost) | – | – |
| point 3 only (result narrowing) | generic | `rieq` `risub` `rige` | `[2, 2^62-1]` | 14,000 | 5,637,412 |
| points 1+2+3 | int | raw | `[2, 2^62-1]`, RawInt blocked by 4/5 | 14,000 | 5,637,464 |

Every configuration returned `[400, 0]`. `tld?` + `domain?` together are
about 2% of `refined-checks`' instructions: the ceiling of this whole line
of work on that benchmark is small, but point 3 turned out to be general
(next section).

## Callee-position calls (soundness fix)

Found by the adversarial review of fix 3, fixed first (its own commit),
because fix 3 would otherwise have turned it into new miscompiles.

`hir::range::Call` evaluated a call's arguments but never its *callee*
expression. A call in callee position -- `sel(k)(0)`, `list_get(fs,
pick(k))(y)` -- or a closure created there is a real exact call or creation
site (`hir::specialize` records it and native lowering calls it directly),
but its arguments never reached the called instance's entry Range. The
entry then covered only the other callers: unsound, and on `main` a native
miscompile once range-decided branch lowering (M6) trusts it:

```
fn one(y):
    1
fn two(y):
    2
fn sel(k):
    if k > 5:
        two
    else:
        one
fn apply(g):
    g(0)
[apply(sel(1)), sel(10)(0)]          # interp [1, 2]; cranelift on main [1, 1]
```

`sel<int>`'s entry was `[1, 1]` (only `sel(1)` was seen), so `k > 5` was
"always false" and the `two` branch was dropped. `[pick(1), list_get(fs,
pick(10))(0)]` gave `[0, 1]` instead of `[0, 2]` the same way.

Fix 3 made this worse in a new way: a program where the ascending summary
happened to be wide enough to cover the missing caller (`sel` branching on
`clamp(k) < 0`, with `sel(0 - 50)(0)` in callee position) was correct on
`main` and miscompiled once the summary was narrowed under the unsound
entry. With the callee visited, all three programs agree on every backend.

`Call` now evaluates a non-reference callee before the arguments (a dead
callee makes the call dead, like a dead argument). A plain reference has no
subexpressions and is still skipped. Every other HIR node kind was checked
against `hir::children`: `Expr` visits all their children, so the callee was
the only gap. The same `Call` serves `hir::range`'s declared-contract
verification walk, which now sees such calls too.

Tests (`tests/hir-range.test`): the callee-position caller reaches the entry
(`sel`: `[1, 10] {1,10}`; the `list_get` index shape: the same), and
interp/compile/cranelift parity on the three programs above.

Corpus effect (NIR of all 44 corpus programs, `main` at `07b373c` against
both soundness fixes; the same on `e1ce1a3`): one program changes, and only by getting more precise.
`examples/hir/01-scopes.ir` invokes a block literal immediately
(`{call {block {} ...}}`); that creation site sits in callee position, so
before the fix its capture `x` was never seen, and now the read is the
constant 20.

## `bit_and` identity fold (soundness fix)

Found by the same review (downstream-consumer lens), fixed in its own commit
before fix 3, whose narrower call-site Ranges made it fire in more programs.

`native::lower::FoldPureBitwise` lowered `bit_and(a, K)` as plain `a` when
`a` was nonnegative, `K` a single proven value, and the call's result
Range equal to `a`'s. Its justification, a self-map argument, holds only
for exact value sets. For a plain interval the result Range is the hull
`[0, K]` whether or not the mask clears bits, so a non-identity was folded:

```
fn lim(x):              # clamps to [0, 95]
    if x > 95:
        95
    else:
        if x < 0:
            0
        else:
            x
fn f(k):
    bit_and(lim(k), 95)
loop i from 30 to 34:
    f(i)                # interp [30, 31, 0, 1]; cranelift on main [30, 31, 32, 33]
```

(32 and 33 have bit 5 set; 95 does not.) With fix 3 the simpler `[f(32),
f(0)]`, whose call site used to read `lim`'s summary `[-∞, 95]` (which
blocked the fold), became `[32, 0]` instead of `[0, 0]`.

The fold now asks the question it needs (`native::lower::AndIdentity`):
`a`'s Range is nonnegative and finite, and either every exact value `v`
satisfies `v & K == v`, or (too many values to list) `K` has every bit
below the bit length of `a`'s maximum. The case the fold was written for
(`bit_and(x, 15)` with `x` proven in `[0, 15]`) still folds; a wide
interval under a full mask (`[0, 1000]` and `1023`) now folds too.

Tests (`tests/native-bitwise-fold.test`, 6): parity and NIR for the
bit-clearing interval, the narrowed call site, the nibble identity, the
wide full mask, an exact-set non-identity and the mask as first operand.

Corpus effect: no NIR change in any of the 44 corpus programs.

## Fix 3: result-summary narrowing

### Outcome

Call sites now read callee result summaries narrowed together with the
entry and capture facts, instead of the ascending phase's joined ones.

* `refined-checks`' `tld?`: `e = scan_while(i, is_tcl_alpha)` reads
  `[0, 2^62-1]` instead of `[-∞, 2^62-1]`, so `e == n`, `e - i` and `>= 2`
  lower to `rieq`/`risub`/`rige` instead of tagged `ieq`/`isub`/`ige`.
  `tld?`: 62 → **35 Ir/call** (24,800 → 14,000 Ir/run); `refined-checks`:
  5,648,265 → **5,637,510 Ir/run (−0.19%)**. `tld?` stays `<generic>`; its
  key is point 1.
* The loss was general, not `scan_while`-specific: any callee whose first
  analysis round (entries still unknown) gives a one-sided result kept the
  open side at every call site (`clamp` example below).
* Nothing gets wider: over the corpus (29 programs, 5,130 Range facts),
  8 facts narrower, **0 wider**; 1 program's NIR changes (`refined-checks`,
  one function); every other `bench/*.bot` and `examples/stdlib/*.bot`
  program's NIR is byte-identical.
* With the pass switched off (`hir::range::resultNarrowOpt 0`) the
  compiler is byte-identical to its parent commit (the two soundness fixes
  above): NIR and analysis of all 29 corpus programs plus 15 Core-IR-text
  programs, 0 mismatches.
* No extra analysis work where nothing narrows: a pass that converges in
  one round replaces the final recompute. `refined-checks` (the one corpus
  program that narrows) pays one extra round, +29 `AnalyzeInstance` calls
  (268 → 297), about 6 ms.
* Soundness evidence beyond the argument below: 5,600 fuzzed programs
  (`tools/fuzz.tcl`), 0 Range violations in about 470,000 checks, 0
  backend disagreements caused by the pass; full suite, GC-stress suite
  and native coverage pass (see [Verification](#verification)).

### The loss

`hir::range::Fixpoint` computes three kinds of facts per used instance: entry
Ranges, capture Ranges, and a *successful-result summary* in `calleeResults`
-- the Range an exact call expression reads (`hir::range::Call`). Its
ascending phase widens entries and joins summaries; M9's descending phase
(M9-INSTANCE-ENTRY-INT-FACTS.md) then narrows entries and captures. Nothing
ever narrowed the summaries, so call sites kept whatever infinite side the
ascending rounds left, even where the callee's own result under its
narrowed entries is bounded.

The ascending fold makes this systematic, not a corner case. Every entry
starts `unknown`, and a summary, once concrete, is only ever joined:

```
round 1:  clamp(x) analyzed with x unknown   -> result [-∞, 100]   summary := [-∞, 100]
round 2:  x = [5, 5] from the caller         -> result [5, 100]    summary := join = [-∞, 100]
...       converged; M9 narrows x, never the summary
```

So any callee whose first-round result has one finite side keeps the wide
side at every call site:

```
fn clamp(x):          # called only as clamp(5)
    if x > 100:
        100
    else:
        x
fn double(y):
    y * 2
fn use(k):
    double(clamp(k)) + 1
use(5)
```

| fact | before | after |
|---|---|---|
| `use`'s `clamp(k)` call | `[-∞, 100]` | `[5, 100]` |
| `double`'s entry | `[-∞, 100]` | `[5, 100]` |
| `use`'s `double(…)` call | `[-∞, +∞]` | `[10, 200]` |
| `use`'s result | `[-∞, +∞]` | `[11, 201]` |

`hir/rangerec.tcl`'s `RefinedResults` already documented the same loss
("calleeResults holds the ASCENDING phase's widened summaries ...
weight<int> -> [2,+inf] while its post-narrowing result is [2,11]") and
worked around it inside the recursive-result solver only.

### The change

`hir/range.tcl`:

* M9's narrowing loop body moved, unchanged, into
  `hir::range::NarrowRounds {ctx narrowed captures results narrowResults
  roundBudget}`; `Fixpoint` calls it for M9 exactly as before
  (`narrowResults 0`).
* A second pass, `NarrowRounds … 1`, starts from the facts M9 committed and
  narrows entries, captures **and** summaries together: each round, an
  instance's fresh result narrows its own summary with the same
  `RangeNarrow`, callers read it the next round, and whatever their
  arguments gain narrows their callees' entries in turn. Pinned summaries
  (`rangerec.tcl`) are never touched.
* The pass commits only if it reaches its own fixed point within budget
  (the same discipline as M9: an unfinished pass leaks nothing); otherwise
  M9's facts stand unchanged. When it converges, its last round, which
  changed nothing and therefore analyzed every instance under exactly the
  committed facts, is reused as the final recompute.
* Test/audit knobs (namespace variables, not user flags):
  `hir::range::resultNarrowOpt` (0 skips the pass) and
  `hir::range::resultNarrowRoundLimit` (budget override). `Fixpoint`'s
  state also records `ascendingResults` and `resultNarrow {attempted
  converged rounds}` for audits.

`hir/rangerec.tcl`: only the `RefinedResults` comment changed. Its
intersection of each summary with the callee's final result is still
needed after a converged pass: it restores exact value sets `RangeNarrow`
does not carry, and tightens finite-but-loose bounds `RangeNarrow` never
touches.

### Soundness

The argument does not depend on convergence or on monotonicity of the
transfer functions:

1. Every fact the pass starts from is sound: they are M9's committed facts
   (or the ascending phase's, if M9 fell back). This premise is the
   analysis' general soundness, and it did not hold before the
   [callee-position fix](#callee-position-calls-soundness-fix).
2. A round computes each fact from facts that are sound: an instance's
   fresh result under sound entries, captures and callee summaries
   (including its own summary, for self calls) covers every successful
   result of every invocation; the join of every reached exact call's
   arguments covers every invocation of a closed instance, because each
   one goes through such a call; open instances never receive
   contributions; induction-locked entries are never touched. This is the
   ordinary per-instance soundness of `AnalyzeInstance` that M9 and
   `RefinedResults` already rely on.
3. `RangeNarrow(old, new)` only replaces an *infinite* side of `old` with
   `new`'s bound, keeps finite sides, returns `old` unchanged when it would
   be empty, and drops nothing it did not refine. So it is never tighter
   than `old ∩ new`, which is sound when both are.

Hence every iterate is sound. Convergence is required for commitment by
policy (no partially narrowed state is published), not for soundness.
Termination: `RangeNarrow` changes each side of each fact at most once
(infinite to finite), so a pass changes finitely many times; the budget is
`Fixpoint`'s own `4 × instances + 16` rounds.

No regression by construction: the pass starts from M9's facts and
`RangeNarrow` never widens, so every committed entry, capture and summary
is a sub-interval of what M9 committed, and with `resultNarrowOpt 0` (or a
non-converging pass) `Fixpoint` returns exactly what it returned before.

Expression Ranges and instance `result`s are *recomputed* under those
facts. They are sound but not guaranteed to be sub-intervals: the Range
lattice has no empty interval, so code that the narrower facts prove dead
can produce an incomparable one (an inverted `[14, 8]` that `*` turns into
a non-empty interval). See [Known limitations](#known-limitations).

### `refined-checks`: `tld?` before / after

`tld?`'s NIR (ExprId suffixes dropped); the only function whose NIR
changes in the corpus:

```
before                                         after
%4 = call 15 %0 %3 %1 %2                       %4 = call 15 %0 %3 %1 %2
%5 = op ieq %4 %1                              %5 = op runbox %4
br %5 L0 L1                                    %6 = op runbox %1
                                               %7 = op rieq %5 %6
                                               br %7 L0 L1
label L0                                       label L0
%7 = op isub %4 %0                             %9 = op runbox %0
                                               %10 = op risub %5 %9
%8 = int 2                                     %11 = int 2
%9 = rawint 2                                  %12 = rawint 2
%10 = op ige %7 %8                             %13 = op rige %10 %12
```

| fact (`tld?<generic>`) | before | after |
|---|---|---|
| summary of `scan_while<any, native(is_tcl_alpha)>` | `[-∞, 2^62-1]` | `[0, 2^62-1]` |
| `e` (call site and both reads) | `[-∞, 2^62-1]` | `[0, 2^62-1]` |
| `e - i` | `[-∞, 2^62-3]` | `[-(2^62-1), 2^62-3]` (fits small) |

The RawInt plan now marks that `scan_while` instance's result `RawInt`
(raw demand from `tld?`'s `rieq`). The NIR does not change for it: the
instance is only emitted as a de-closured internal-capture function, which
keeps the tagged ABI (point 5). The plan text was already able to say this
for internal-only instances; it is inert.

### Corpus census

`tools/census.tcl` (`out/census.txt`): every program in `bench/*.bot`,
`examples/stdlib/*.bot` and `examples/surface/*.bot` that compiles natively
(29; two `examples/surface` programs are deliberate compile errors), with
the pass off and on, comparing every entry, capture, summary, result and
expression Range native lowering consumed:

| | count |
|---|---|
| Range facts compared | 5,130 |
| narrower | 8 (6 expressions, 2 summaries) |
| wider or incomparable | **0** |
| programs with any Range change | 2 (`refined-checks`, `examples/surface/08-return`) |
| programs with NIR changes | 1 (`refined-checks`: `tld?`) |
| result-narrowing passes attempted / converged | 29 / 29, at most 2 rounds |

`08-return`'s `abs<int>` summary narrows from `[0, +∞]` to `[0, 7]` (two
call sites); its NIR does not change. A further 15 Core-IR-text programs
(`bench/*.ir`, `examples/*.ir`, `examples/hir/*.ir`) give the same picture:
3 changed functions, all the same `tld?` change.

**Pass off = the old compiler.** `tools/equivalence.tcl`: a worktree of
the parent commit (`584de41`, the two soundness fixes) against this change
with `resultNarrowOpt 0`, on all 44 programs:
NIR and `hir::range::analyze` instances byte-identical (58 required
comparisons), and so are the analysis' induction/recursive records, the
RawInt plan text, instance labels, emitted function variants, HIR text,
call counts and every `Fixpoint` state apart from the two new keys (203
more comparisons), 0 mismatches.

### Instructions

`tools/emit-nir.tcl` + `audit/post-r2a-dynamic-census/tools/profile-nir.sh`
(audit binary, 21 runs, first run excluded; `out/ir.txt`). Only programs
whose NIR changes need profiling; the other 16 `bench`/`stdlib` programs
are unchanged by construction.

| program | Ir/run before | after | |
|---|---:|---:|---|
| `bench/refined-checks` | 5,648,265 | 5,637,510 | −10,755 (−0.19%) |
| — `tld?` self | 24,800 | 14,000 | 62 → 35 Ir/call, 400 calls |

Measured on the final tree with a runtime built from it; `out/ir.txt` holds
the original full-corpus run on `e1ce1a3` + fix 3 (−10,837, the same
function-level change). In `tld?` the tag tests (3,200 Ir), the overflow
check, the Bool test and 4,000 Ir of register moves disappear; 1,200 Ir of
untagging is added. The rest of the difference is glibc heap-layout noise;
every other Botlish function has identical self Ir and call counts.

### Compile time

`tools/compiletime.tcl` (`out/compiletime.txt`), medians of 5, with the
machine loaded by two test-suite runs (treat per-program deltas within
about ±14% as noise):

* Exact work: every corpus program except `refined-checks` converges in one
  round, which is reused as the final recompute, so its `AnalyzeInstance`
  count is identical. `refined-checks`: 2 rounds, 268 → 297 calls.
* `hir::range::analyze`: `refined-checks` 68 → 74-77 ms; the sum over the 17
  programs 565 → 573 ms. Whole `native::nir`: 2,251 → 2,253 ms summed, no
  measurable change.

### Fuzzing

`tools/fuzz.tcl` (`out/fuzz.txt`) generates chains of 2-6 non-recursive
helpers (one- and two-sided clamps, also at the small-Int boundary
±2^62; counted loops in every direction with early `return`, `break`,
`continue` and the post-loop value; closures capturing Ints; the
`emailish?` shape: a String and its length captured by nested scanners
with a predicate passed as a value; helpers stored in a List and called
through `list_get`, so open instances exist). Three oracles per program:
interp = compile = cranelift; every top-level call's actual value lies in
its claimed call-site Range; and a runtime trace that checks every Int
argument, result and captured Int against the entry Ranges, results,
summaries and capture facts.

| run | programs | knobs | Range checks | violations | disagreements caused by the pass |
|---|---:|---|---:|---:|---:|
| A | 5,000 | default | 26,796 top-level + 394,560 trace | 0 | 0 |
| B | 300 | round limit 1 | 1,563 + 25,167 | 0 | 0 |
| C | 300 | round limit 2 | 1,548 + 21,700 | 0 | 0 |

In A the pass changed a Range in 1,096 of 5,000 programs and always
converged (1-9 rounds); in B, 72 passes ran out of budget and committed
nothing (every Range equals the pass-off analysis). An oracle self-test
(`-mutate 1`, a deliberately unsound pass) is caught by all three oracles.
The committed output is a rerun on the final code (this commit, on `main`
at `07b373c`); earlier runs on `e1ce1a3` + fix 3 alone and with the two
soundness fixes gave identical totals. That is also
the fuzzer's blind spot: its generator never puts a call in callee position
(its `list_get(...)(...)` indexes are constants) and never masks with a
constant that clears bits of a clamped value, so it could not find either
soundness bug above; the reviews did.

All 40 backend disagreements are one **pre-existing** native lowering bug,
identical with the pass off and on a clean export of `e1ce1a3`:

```
fn f(a):
    k = 5
    fn g(x):
        x + k
    g(a)

fs = [f]
list_get(fs, 0)(3)
```

interp and compile give 8; cranelift throws `native lowering: call e11 of a
de-closure-converted binding has no wanted callee instance (NATIVE BUG)`.
It needs a call through `list_get` of a known List and a nested closure
capturing a *local*. Not fixed here. **Since fixed** by
[Blockescape: a called generic instance](#blockescape-a-called-generic-instance)
(`g<generic>`, selected by `f<generic>`'s call, is now a de-closure target
of its own); regression tests in `tests/blockescape-called-generic.test`.

### Adversarial review

Three independent reviews of the change, each from a different angle, with
every finding then reproduced or refuted by a separate verifier:

* **Soundness of the pass itself.** The argument above holds; it fails only
  at its premise, because `hir::range` was not sound to begin with: calls in
  callee position were never seen (verified: real, pre-existing). That is
  the [callee-position fix](#callee-position-calls-soundness-fix), now its
  own commit underneath this one. It also corrected two comments (fixed).
* **Integration and refactor.** No correctness problem. The `NarrowRounds`
  extraction is faithful; reusing the converged round as the final
  recompute is exact (recomputed and compared on 984 `Fixpoint` calls);
  `rangerec.tcl` keeps soundness, determinism and termination; with the
  pass off, analysis and NIR equal the parent across 110 programs × 7
  option combinations; a separate self-recursive fuzz (3,000 programs, 217
  changed by the pass, 42,563 observed values) found nothing. Its two
  findings were report statements (fixed: the `RefinedResults` sentence and
  the base revision of the audit outputs).
* **Native lowering consumers.** No consumer relies on a call-site Range
  agreeing with the callee's own `result` or ABI decision (they disagree
  soundly, e.g. after `RangeNarrow` keeps a finite side). It found the
  unsound [`bit_and` identity fold](#bit_and-identity-fold-soundness-fix)
  (verified: real, pre-existing; fix 3 exposed it in more programs), fixed
  in its own commit. It also found an unrelated **pre-existing runtime
  bug, not fixed here**: `rt_int_shl` (`native/src/runtime/ops.rs`) uses
  `i64::checked_shl`, which only rejects shift amounts >= 64 and silently
  drops shifted-out bits, so `shift_left(2, 62)` is `-9223372036854775808`
  natively and `9223372036854775808` on interp/compile. **Since fixed** in
  a later commit: `rt_int_shl` keeps the small result only when shifting it
  back recovers the operand (`shl_i64_exact`) and otherwise promotes to
  BigInt; the raw `rishl` path was audited and was already sound (it needs
  a proven small result range). Regression tests: `bitshift-shl-*` and
  `bitshift-shr-negative-tagged` in `tests/native-bitshift.test`, plus Rust
  unit tests in `native/src/runtime/ops.rs`.


### Verification

On the final code (this commit, on `main` at `07b373c`), each suite in its
own worktree:

| suite | result |
|---|---|
| `tests/all.tcl`, interp | 4,161 / 4,161 |
| `tests/all.tcl`, compile | 4,157 passed, 4 skipped (`coreScoping`), 0 failed |
| the same under `BOTLISH_NATIVE_GC_STRESS=1` | identical |
| `tests/native-coverage.tcl` (cranelift) | 4,195 tests: native 1,726, independent 2,367, passed-partial 41, unsupported 60, failed 1 (`refined-5`) |
| the same on `main` (`07b373c`) | 4,171 tests: native 1,712, independent 2,357, passed-partial 41, unsupported 60, failed 1 (`refined-5`) |

The coverage difference is exactly the 24 added tests (14 native, 10
independent); the one failure is the same pre-existing `refined-5` on both.

Tests: `tests/result-range-narrowing.test` (new, 12 tests): the `clamp`
call-site Range, the clamp → double → use chain (entries and results),
`refined-checks`' `tld?` call site and NIR ops with the pass off and on,
knob-off = ascending summaries and knob-on ⊑ ascending, an unconverged pass
committing nothing (round limit 1), a pinned recursive summary untouched,
an open instance's summary keeping its dynamic caller's values, and
interp/compile/cranelift parity on five narrowing-sensitive programs
(small-Int edges on both sides, open and closed instances of one function,
a scanner closure).

`tests/checked-domain-proof-provenance.test`: one existing test pinned the
loss itself. `checked-domain-q2-still-emits-both-checks` expected
`checkedSmall`'s `TooLarge` check to survive because "nonneg's result is
only bounded below", but the program's only caller is `g(5)`: `nonneg(5)`
is exactly 10, and the lower-bound-only Range was the frozen ascending
summary `[10, +∞)`. With the pass both checks are dead. The test keeps its
purpose (partial elimination) with a caller that is genuinely unbounded
above (`g(length(s))`), and a new test,
`checked-domain-q2-narrowed-summary-removes-both-checks`, pins `g(5)`
removing both checks (and keeping `TooLarge` with the pass off).

### Known limitations

1. **Only infinite sides narrow.** `RangeNarrow` never tightens a finite
   bound, so a summary the ascending phase left finite but loose stays
   loose. `intersect` would keep tightening, but loses the at-most-once-
   per-side termination argument.
2. **Exact value sets on summaries are dropped** where `RangeNarrow` fills a
   side (`clamp`'s result is `{5, 100}`, its summary `[5, 100]`).
   `rangerec.tcl`'s `RefinedResults` intersection restores them for the
   recursive solver.
3. **Dead code can produce incomparable Ranges.** There is no empty
   interval in the lattice: when narrower facts make a branch or loop
   domain infeasible, its Ranges can come out inverted and become a
   non-empty interval again through arithmetic. Sound (the code never
   runs), and never seen in the corpus, but 3 of 5,000 fuzz programs show
   it, once on an instance `result`: seed 5/435's `f2<int, int>` result
   lower bound −18 → −45 (its call-site summary keeps −18). A bottom for
   empty intervals is a separate lattice change.
4. **The pass runs on the same round budget as `Fixpoint`**
   (`4 × instances + 16`); a program that needs more commits nothing and
   keeps M9's facts.

## Blockescape: nested capturers (soundness fix)

Found by the adversarial review of loss point 2, fixed first (its own
commit), because point 2 relies on the property it breaks.

`hir::blockescape` de-closures a closure binding B only if every reference
to B is the callee of an exact call. It checks the references in the
region's own expressions, in the literal's own body (self calls) and in the
body of each sibling closure of the same region that captures B. Those are
*direct* expressions only: a closure nested one level deeper is a region of
its own and was never looked at. `HasSelfCapture` covered a nested self
reference only when the literal had no direct self call, and a sibling
capturer only needed one direct call. So a nested closure that used B as a
*value* went unseen whenever a direct call existed somewhere:

```
fn outer(k):
    fn rec(n, p):
        fn bounce(m):
            fs = [other, rec]          # rec as a value, inside rec
            g = list_get(fs, k)
            g(m * 10000000000000000000000, p)
        ...                           # and a direct self call rec(n - 1, p)
    rec(10, is_tcl_alpha)
```

On `main` this program (and the sibling variant, `c` calling `f` directly
while `c`'s nested `d` stores `f`) fails to compile natively ("self in a
function without environment", "eN does not capture bN"). With
`-block-escape-opt 0` it ran on `main`, but with point 2 it returned
garbage: the "never-entered" generic entry of `rec` was entered through
the List, and a callee whose RawInt ABI had been planned from live callers
only unboxed a bignum. With `-exact-callable-opt 0 -block-escape-opt 0`
`main` was already wrong (stack exhaustion, garbage), through the same
hole and `closed`.

**The change** (`hir/blockescape.tcl`, `Bindings`): a candidate captured by
any Block literal that is neither one of its region's own literals (its own
literal, a sibling) nor checked otherwise -- that is, by a closure nested
inside its literal or inside a sibling -- is declined outright. Conservative:
a nested closure that only *calls* B declines it too (references there are
not examined at all); B is then an ordinary heap closure, as any binding
with an unexamined use.

**Evidence.** Corpus (44 programs, `bench`, `examples/stdlib`,
`examples/surface`, Core-IR text): NIR byte-identical to `main` in every
program; no corpus closure has a nested capturer. Tests
(`tests/blockescape-nested-capturers.test`, 13): which bindings are still
de-closured (the nested closures and the sibling capturer, not `rec`/`f`),
and interp/compile/cranelift parity for the two review programs and a
nested call-only shape under default flags, `-block-escape-opt 0`,
`-exact-callable-opt 0` and both.

## Loss point 2: dormant instances

### Outcome

The generic Block-value entry of a closure that `hir::blockescape`
de-closures, and every instance only such an entry reaches, is now
**dormant**: still used (still in the call graph, still emitted when
`-block-escape-opt 0` materializes the closure), but never entered at run
time, so nothing it does is evidence about anything else.

* `refined-checks`: `scan_while<generic>` is dormant; its unbounded loop
  counter no longer reaches `char_at`, whose entry goes from
  `[-∞, 2^62-2]` to **`[0, 2^62-2]`**. `char_at`'s `i + 1` lowers to
  `runbox`/`riadd`/`rbox` instead of the tagged, overflow-checked `iadd`, in
  both of its emitted variants. This is limitation 2 of
  EXACT-CALLABLE-CLOSED-CALLER.md.
* `char_at`: 46 → **35** and 34 → **22 Ir/call** (10,800 calls per run);
  `refined-checks`: 5,637,105 → **5,509,900 Ir/run (−2.26%)**. More than the
  "≈2%" ceiling the investigation estimated for `tld?`/`domain?`: `char_at`
  is the hot one.
* Nothing gets wider: over the corpus (29 programs, 5,130 Range facts) 4
  facts narrower, **0 wider**; 1 program's NIR changes (`refined-checks`,
  the two `char_at` functions). Core-IR text (15 programs): 22 narrower,
  0 wider; 4 programs change, 3 of them the same `char_at` change
  (`refined-checks.ir`, `05-refined-strings.ir`, `hir/06-refined-strings.ir`),
  one a closure capture (`hir/02-closures.ir`, below).
* With the knob off (`hir::specialize::dormantOpt 0`) the compiler is
  byte-identical to its parent commit on all 44 programs (440 dump files).
* Point 1 is now possible without the regressions the scratch experiment
  showed (next section).
* Side effect: a program whose only AOT blockers sit in a dormant entry is
  now accepted by `-emit-native-executable` (the scanner shapes in
  `tests/dormant-instances.test` were `NATIVE AOT NOT-READY` on
  `scan<generic>`'s `loop i from start` guard).

### The loss

`hir::aot::materializedBlocks` (`hir/aot.tcl:269`) counts every bind of a
value-capturing closure as materializing its Block value, so
`hir::specialize::Analyze` keeps an edge from the binding instance to the
literal's generic instance (`hir/specialize.tcl:829`). When blockescape
de-closures the binding through specialized instances, that generic
instance is the entry of a Block value no code ever calls. It is open (its
callers are not all known: it has none), so it receives no facts, but its
own calls and closure creations still fed `hir::range` (which skipped
contributions *to* open instances, not *from* them), the closed-caller
theorem and `hir::range::ExternalSeeds`; and AOT readiness required it to be
guard-free although it is never emitted (block escape on) or never run
(off).

Instances reachable only through such an entry inherit the problem: with
`<int>` keys (point 1) the dormant `tld?<generic>` creates its own
`scan_while<any, native(is_tcl_alpha)>`, whose calls would pollute
`char_at<int>`.

### The change

`hir/specialize.tcl`:

* `DormantInstances` (`:1210`), computed once after the ordinary fixpoint
  from the frozen graph and the blockescape result over it, stored as
  `dormant` in the analysis (`:252`) and computed identically by
  `CloseCallers` (`:1564`). **Entries** are the generic instances of every
  value-capturing literal of which blockescape wants some instance (the
  binding is de-closured). **Live** is reachability from the program over
  `edges`, where an edge into an entry is followed only when the target is
  a `calls` target of the source. Dormant = used − live.
* `ClosedCallerFacts` (`:1325`) skips dormant callers.
* Queries: `hir::specialize::dormant` (`:1669`); `closedAudit` (`:1682`)
  gains a `dormant=` column.
* Knob `hir::specialize::dormantOpt` (test/audit only; 0 = empty set).

`hir/range.tcl`: `OpenInstances` (`:2250`) adds the dormant set to `open`
(a dormant instance gets the facts that hold for any caller); `Fixpoint`'s
ascending loop (`:2642`) and `NarrowRounds` (`:2378`) skip the calls and
closure creations of dormant instances; `ExternalSeeds` (`:790`) skips
dormant callers. `hir/rangerec.tcl`: `ExternalEntry` (`:269`) skips dormant
callers. `native/native.tcl:225`: AOT readiness skips dormant instances.

#### Design questions

* **Prune from `used`, or keep and exclude?** Kept. The used graph is the
  input of blockescape, so pruning it would make the dormant set depend on
  an analysis computed from the set (circular); and with
  `-block-escape-opt 0` lowering materializes the closure and needs the
  entry's code (its function pointer). Keeping them changes no instance,
  key, edge or emitted function: the knob-off equivalence is exact, and
  with the knob on only facts change.
* **Where facts are joined.** Every consumer that joins evidence across
  instances: `hir::range` (calls, creations, external seeds, rangerec's
  external entry), the closed-caller theorem, AOT readiness. Consumers that
  read `closed` and plan representations (`native/rawabi.tcl`,
  `native/shortstring.tcl`, `hir/construction.tcl`) are unchanged: they keep
  callers and callees consistent by construction, and a dormant instance's
  Ranges are the open ones, so no raw position is planned from them.
* **Circularity with blockescape.** None: blockescape runs on the full
  used graph exactly as before, and the dormant set is derived from its
  result afterwards.
* **`-block-escape-opt 0`.** The entry is emitted (it is the closure's code
  pointer) and still never called: an exact call of a materialized closure
  goes to the instance hir::specialize chose for that call site
  (`callenv` of the specialized canonical function). `native/rawabi.tcl`
  already treats such generic instances as open there.

### Soundness

The claim is that no dormant instance runs, on any backend.

1. A Block value only runs code when called. An exact call runs the
   instance recorded for that call site in the caller's `calls`; a dynamic
   call of a Block value runs the literal's generic instance.
2. An entry's literal is de-closured, so blockescape proved that every
   reference to its binding is the callee of an exact call: its Block value
   never reaches a dynamic call site. So an entry runs only when a recorded
   exact call selects it, and every other dormant instance runs only when
   some instance calls it or creates it.
3. Liveness follows every call edge of a live instance (even unreachable
   calls) and every value edge except into entries. An instance that some
   live instance calls is therefore live; a dormant instance is only ever
   called or created by dormant ones. By induction over a run, no dormant
   instance is ever entered: the program is live, and a live instance only
   enters live instances.

It does not rely on blockescape's claim that the exact calls reach
*specialized* instances: a call that selects the generic instance keeps it
live. It does rely on the dynamic-call part of the proof, and that part was
wrong for closures nested in the literal or in a sibling: the
[nested-capturer fix](#blockescape-nested-capturers-soundness-fix), found
by this change's review, comes first for that reason.

Given that, excluding a dormant instance's calls and creations removes only
evidence of runs that never happen; treating dormant instances as open gives
them facts that hold whoever calls them, so their code (emitted under
`-block-escape-opt 0`) is correct even if the claim were wrong for them.
The one place where code compiled for a dormant caller relies on a live
callee's facts is a call into a RawInt parameter planned from live callers
only: the dormant call site unboxes without a check (wrong only if run).

### `refined-checks`: `char_at` before / after

```
before                              after
%2 = int 1                          %2 = op runbox %0
%3 = rawint 1                       %3 = int 1
%4 = op iadd %0 %2                  %4 = rawint 1
%5 = op regioncheck %1 %0 %4        %5 = op riadd %2 %4
retmulti %1 %0 %4                   %6 = op rbox %5
                                    %7 = op regioncheck %1 %0 %6
                                    retmulti %1 %0 %6
```

The other variant (`substr` instead of `regioncheck`) changes the same way.

### `examples/hir/02-closures.ir`

```
{bind adder {block {n} {block {x} (x + n + base)}}}
{bind add5 {call {ref adder} {const 5}}}
{call {ref add5} {const 1}}
```

`adder<int>` is the call target; `adder<generic>` is dormant. It created
the inner closure with an unknown `n`, which joined into the capture fact;
now `n` is `[5, 5]`, the inner closure's `+`s lower raw and its result is
`[106, 106]`. Correct (the program returns 106 on every backend).

### Evidence

`tools/run-knob.sh` (`out/census-dormant.txt`, base = the nested-capturer
fix): the census above, `census.tcl` knob 0 vs 1, and `equivalence-off.tcl`
(parent commit vs knob 0: NIR, Range analysis, every `Fixpoint` state, RawInt
plan text, labels, variants, HIR, dormant set and call counts byte-identical,
440 comparisons, 0 mismatches). `census.tcl` gained a `dormant-wider` class
for facts of instances dormant at knob 1 (deliberately the open facts); the
corpus has none.

Instructions (`out/ir-dormant.txt`; `audit/post-r2a-dynamic-census/tools/profile-nir.sh`, 21
runs, run 0 excluded):

| function (`refined-checks`) | calls/run | self Ir/run before | after |
|---|---:|---:|---:|
| `char_at` (region variant) | 4,000 | 184,000 | 140,000 |
| `char_at` (ordinary variant) | 6,800 | 231,200 | 149,600 |
| total | | 5,637,105 | 5,509,900 (−2.26%) |

(`web::emailish?`, `scan_while` and `domain?` lose 1-2 Ir/call each from
the shorter calls; every other function's self Ir is unchanged.)

### Fuzzing

`tools/fuzz.tcl -knob hir::specialize::dormantOpt` (`out/fuzz-dormant.txt`).
Its trace oracle now joins only a block's *live* instances (a dormant one
claims nothing, so joining it would make the oracle vacuous exactly where
this change acts), and reports any invocation of a block whose every
instance is dormant; `-mutate 2` (every instance that makes a call declared
dormant too) is the matching oracle self-test.

| run | programs | native | Range checks | violations | disagreements |
|---|---:|---|---:|---:|---:|
| A | 5,000 | default | 26,796 top-level + 394,560 trace | 0 | 38, all pre-existing |
| B | 2,000 | `-block-escape-opt 0` | 10,830 + 160,338 | 0 | 0 |
| C (self-test) | 200 | `-mutate 2` | | 15 top-level, 1,209 trace | 24 (21 introduced) |

In A, 2,341 programs have a dormant instance and 497 change a Range. The 38
disagreements are all the pre-existing `list_get(fs, 0)(3)` NATIVE BUG
(identical with the knob off), fixed by the [next
commit](#blockescape-a-called-generic-instance). The generator never builds
nested capturers (limitation 5), so it could not find the review's bug.

### Adversarial review

An independent review (soundness, integration, downstream consumers),
every finding reproduced before acting:

* **Soundness: found a real hole, pre-existing, that this change turned into
  wrong results.** blockescape never examined closures nested in a literal
  or a sibling capturer (two reproducers: a recursive closure stored in a
  List by a closure nested in its own body; a sibling stored by a closure
  nested in its capturer). On `main` both fail to compile natively; with
  `-block-escape-opt 0` they returned garbage under this change (a
  "dormant" entry was entered through the List). Fixed first:
  [nested capturers](#blockescape-nested-capturers-soundness-fix); both
  programs are regression tests here and there.
* Everything else held: liveness (strongly connected components are wholly
  live or wholly dormant, so recursive solving never mixes them), capture
  facts (a block created only by dormant code has only dormant instances),
  `CloseCallers` and `analyze` computing the same set, the representation
  planners reading `closed`, AOT readiness, per-region-instance eligibility,
  and a probe matrix over every backend and option combination
  (`-block-escape-opt 0`, `-specialize 0`, `-call-facts-opt 0`,
  `-exact-callable-opt 0`, `-closed-caller-facts-opt 0`) with the knob on and
  off.
* Unrelated, recorded, not fixed: `interp` accepts a forward reference
  between sibling local closures and returns a value where `compile` and
  cranelift raise `CORE SEMANTIC UNBOUND`.

The review also covered the generalized entry rule (wanted generic
instances count as entries too) and the planned blockescape change of the
next section, and found no separate problem in either beyond the nested
capturers.

### Verification

On this commit (the nested-capturer fix underneath, `main` at `ccedf43`),
each suite in its own worktree:

| suite | result |
|---|---|
| `tests/all.tcl`, interp | 4,345 / 4,345 |
| `tests/all.tcl`, compile | 4,341 passed, 4 skipped (`coreScoping`), 0 failed |
| the same under `BOTLISH_NATIVE_GC_STRESS=1` | identical |
| `tests/native-coverage.tcl` (cranelift) | 4,379 tests: native 1,830, independent 2,442, passed-partial 46, unsupported 60, failed 1 (`refined-5`) |
| the same on `main` (`ccedf43`) | 4,346 tests: native 1,811, independent 2,428, passed-partial 46, unsupported 60, failed 1 (`refined-5`) |

The coverage difference is exactly the 33 added tests (13 for the
nested-capturer fix, 20 here; 19 native and 14 independent in all); the one failure
is the pre-existing `refined-5` on both.

Tests: `tests/dormant-instances.test` (new, 20): the dormant sets of
`refined-checks` and of a transitive shape; an escaping closure's entry
stays live; `used`/keys unchanged by the knob; `closedAudit`; a transitively
dormant instance is closed but range-open; `char_at`'s entry and NIR, the
scanner shape's `get`, the transitive callee's entry, the `adder` capture and
the closed-caller theorem, each knob off and on; the review's nested-value
program (nothing dormant, parity); interp/compile/cranelift parity with
block escape on and off on five shapes; and AOT readiness (the scanner
shape builds and runs, also under GC stress and with block escape off, and
is `NATIVE AOT NOT-READY` with the knob off).

### Known limitations

1. **The set rests on blockescape's no-dynamic-call proof.** Any future
   gap there is a gap here (the nested-capturer bug was one).
2. **Representation planners still see dormant callers.** RawInt and
   ShortString1 demand, and virtual construction, still count call sites
   in dormant code (never emitted with block escape on). Only usefulness,
   never safety.
3. **A static block materialized only in dormant code** still counts as
   materialized (`hir::specialize::MaterializedBlocks`), so its generic
   instance stays open.
4. **Dormant code is still compiled under `-block-escape-opt 0`**, with the
   any-caller facts, and its calls into RawInt parameters unbox unchecked.
5. **The fuzzer never generates nested capturers**, which is why it could not
   find the blockescape bug the review found.

## Blockescape: a called generic instance

Needed by loss point 1, and a fix for the pre-existing NATIVE BUG fix 3's
fuzzing found (its own commit).

`hir::blockescape::RelevantInstances` lists the instances a de-closured
binding may be called at. It returned a literal's non-generic instances if
it had any, and its generic instance only when that was the literal's only
instance: a generic instance next to specialized ones was assumed to be
kept only as the materialized Block value's entry, never a call target.
That is false when an exact call's arguments give no key while another
call's do:

```
fn f(a):
    k = 5
    fn g(x):
        x + k
    g(a)          # in f<generic> (f is a Block value in a List): g<generic>
fs = [f]          # in f<int> (the exact call below):        g<int>
list_get(fs, 0)(3)
```

blockescape found `g` eligible in `f<int>`'s region instance and marked
the binding de-closured (per binding), but `f<generic>`'s call selected
`g<generic>`, which had no internal variant: `native lowering: call e11 of
a de-closure-converted binding has no wanted callee instance (NATIVE BUG)`
(fix 3's fuzz: 40 of 5,600 programs; the point-2 fuzz: 38 of 5,000). With
loss point 1 the same situation becomes common: a closure called with an Int
and with a String gets `inner<int>` and `inner<generic>`, and blockescape
declined the binding, so the closure was heap-allocated again where the
single generic instance used to be de-closured.

**The change** (`hir/blockescape.tcl`, `RelevantInstances`): the generic
instance is a de-closure target too when some used instance's `calls` map
targets it. Every reference must still be an exact call to one of the
listed instances; the generic one now gets its own internal variant like
the others. It becomes `wanted`, hence closed (InstanceClosed's closure
branch): every call to it is a recorded exact call, because the binding is
de-closured and its value never reaches a dynamic call site. A generic
instance called only by dormant code (or only by itself) is still dormant:
the dormant entry rule counts every generic instance of a de-closured
literal, wanted or not.

**Evidence.** Corpus: NIR byte-identical in all 44 programs (no corpus
closure has a generic instance called next to a specialized one). Tests
(`tests/blockescape-called-generic.test`, 5): both instances wanted and
closed, no closure allocated, interp/compile/cranelift parity with block
escape on and off for the program above and a variant calling `g` both
ways. The fuzzer's whole class of pre-existing disagreements is gone: the
point-1 fuzz (which includes this commit) reports 0 disagreements in 7,000
programs, where the point-2 run had 38 in 5,000.

Reviewed together with loss point 1 (its section): no problem found; the
review noted that the called generic instance now also goes through
blockescape's self and sibling checks, so a call pruned there declines the
binding (not observed).

## Loss point 1: Int key positions for capturing closures

### Outcome

`tld?`, `domain?`, `char_at` and `scan_while`'s `start` are keyed `<int>`
(`tld?<int>`, `domain?<int>`, `char_at<int>`,
`scan_while<int, native(is_tcl_alpha)>`, `scan_while<int, block(e239)>`);
their generic instances remain as dormant Block-value entries.

* **Nothing is lost.** The keyed instances keep every entry Range the
  closed generic instances had (`tld?.i` `[2, 2^62-1]`, `domain?.start`
  `[1, 2^62-1]`, `char_at.i` `[0, 2^62-2]`, `scan_while.start` `[0, 0]` /
  `[2, 2^62-1]`): the scratch experiment's Range regression, test failures
  and `NATIVE AOT NOT-READY` are gone, because point 2 made the split-off
  generic entries (and `scan_while<any, native(is_tcl_alpha)>`, which only
  `tld?<generic>` reaches) dormant.
* **Machine code: no change, as predicted.** `refined-checks`' NIR is
  identical apart from instance labels, with the RawInt demand filter on
  and off; so is every other corpus program's (44 programs: 39
  byte-identical, 5 identical modulo labels). No Ir to measure.
* **What changed:** the keys, hence the instance labels and
  `instance="int"` in the NIR headers; the RawInt plan, which now says
  *eligible* for `tld?.i`, `domain?.start`, `char_at.i` and
  `scan_while.start`; the kind guards of a closure whose Int parameter has
  no closed-caller theorem (a closure not de-closured, or called through an
  open caller) are gone by the key alone; 4 more (dormant) instances in
  `refined-checks` (29 → 33), 1 in `uri-steady` (19 → 20).
* **What still blocks raw parameters** (the RawInt plan, `tests/closure-int-keys.test`):
  `tld?<int>.i`, `domain?<int>.start` and `char_at<int>.i` are
  `suppressed-mixed-tagged-use` (a counted loop's bound is a tagged
  consumer: `domain?`'s own loop, `scan_while`'s loop that `tld?`'s `i`
  reaches; `char_at`'s `i` feeds `substring`), `scan_while.start` is
  `suppressed-no-raw-demand` (only a count loop bound consumes it): loss
  point 4. With the demand filter off (`-raw-demand-opt 0`) the plan is
  `rawint`, and still nothing changes: every one of these instances is only
  emitted as a de-closured internal-capture function, which keeps the
  tagged ABI (loss point 5).

### The choice: the key, not the theorem in `rawabi.tcl`

Two ways were open: keep `int` positions in `Handle`, or let
`native/rawabi.tcl:120` accept the closed-caller theorem for a closed
generic instance. The key:

* is the representation every consumer already reads (instance labels,
  `hir::stringregion`/`traversal`/`escape`'s generic-instance exclusions,
  AOT readiness, the RawInt ABI); the theorem would be a second channel for
  one consumer only;
* holds whether or not the instance is closed (a specialized instance is
  selected only by the exact calls whose argument was Int), so it also
  removes kind guards where no theorem exists (a capturing closure that
  escapes, or whose caller is open);
* was what the scratch experiment showed to be blocked only by point 2,
  now fixed; the theorem route would have kept `tld?<generic>` as the
  direct-call target, i.e. would not have needed point 2, but neither
  route changes machine code until points 4 and 5 are done.

Only `int` positions: Int is the one kind with a representation consequence
(Range facts, raw Int operations, the RawInt ABI). Other kinds stay `any`,
refined by the closed-caller theorem as before; code growth is bounded by
the existing per-block `limit`.

### The change

`hir/specialize.tcl` `Handle` (`:937-957`): the closure key rule keeps
`IsExactCallableKey $k || $k eq "int"` positions (knob
`hir::specialize::closureIntKeyOpt`, test/audit only; 0 = the previous
rule). It relies on the two preceding commits: point 2 (the generic entry
that splits off is dormant), and the [called generic
instance](#blockescape-a-called-generic-instance) (a closure called with an
Int and with another kind stays de-closured).

### Soundness

A key position is a fact about the call that selected the instance: the
argument's static kind there. A specialized instance is entered only by the
exact calls that selected it (InstanceClosed), so `int` in its key holds
for every invocation; this is the same argument that already keys static
blocks and scalar-capture closures by kind. The captured values reach the
instance through the closure (or the flattened captures), never through the
key, so keying a capturing closure by its parameters' kinds changes nothing
about captures. Every Block value still enters the generic instance.

### The 21 tests the scratch experiment broke, re-examined

With point 2 and the called-generic fix in place, 44 tests failed: 20 in
four of the five files the experiment broke (`exact-callable-executable.test`,
the AOT fixture, now passes), 11 in `close-callers-convergence.test`, 3 in
`native-block-escape.test` and 2 in `virtual-construction.test` (labels),
6 in point 2's new dormant tests (point-2-era labels) and 2 in tests added
since (the nested-capturer fix, fix 3's open-instance test).
Each was re-examined; none is weakened:

| tests | why it failed | change |
|---|---|---|
| `closed-closure-entry-facts.test`: 14 (theorem, guard, identity, instance-count, mixed-kind, open-instance, alias, escape, captured-through-parent, recursive) | the file's vehicle for the closed-caller theorem on a generic closure was an Int parameter, which is now a key position: the theorem had nothing left to derive (`inner<int>`), and `specId` found the keyed instance | vehicle switched to Str (and Bool for the disagreeing caller): every non-Int position is still forced generic, so the same mechanism is exercised on the default path with the same expectations (`int` → `str` in the theorem pins, `x + length(tag)` → `length(x) + length(tag)`); the recursive fixture's `n` is a key position now (`inner<any, int>`, theorem `{str int}`); the header explains; the Int case is pinned in `closure-int-keys.test` |
| `exact-callable-key.test` `-aggregate-capture-keys` | pinned the old rule (only the exact callable position kept) | pins the new rule, with a third, String parameter that must stay generic: `scan<int, native(is_tcl_alpha), any>`, theorem `{int {native …} str}` |
| `exact-callable-key.test` `-range-open-is-not-closed` | invariant "range-open ⇔ not closed" | point 2 defined range-open as "not closed or dormant"; with point 1 `refined-checks` has a closed dormant instance. The test checks the new invariant over the same corpus |
| `exact-callable-key.test` `-range-generic-closure-not-open` | needs a closed *generic* closure instance with an Int parameter | runs with `closureIntKeyOpt 0` as well as exact keys off (its stated premise) |
| `hir-specialize.test` `-m1-closure-capture`, `-m1-exact-call-propagation` | labels: `cls<int> cls<generic>` | labels updated; both still check the M1 property on `cls<generic>` (declared type in its view; its own call reaching `is_alphanumeric<int>`, now asserted directly so it cannot pass through `cls<int>`) and also on `cls<int>` |
| `emailish-predicate.test` instance count | +1 instance for `char_at`, `tld?`, `domain?` (dormant generic entries), +1 for `scan_while` (the dormant `<any, native(is_tcl_alpha)>`) | counts updated, description explains each |
| `close-callers-convergence.test` 11 (M7.c.1's round-budget fence: forced insufficient rounds, cascades, rollback, identity) | the fixtures build cascades that need a known number of CloseCallers rounds, with Int arguments as the vehicle; with Int keys there is nothing for the theorem to derive, so every pass converges at once | the file's two analysis helpers run with `closureIntKeyOpt 0`, fixtures and expectations unchanged: CloseCallers, the code under test, is the same code by default for every non-Int position (exercised on the default path by `closed-closure-entry-facts.test`) |
| `virtual-construction.test` `vc-str-helper-1`, `vc-str-chain-1` | `piece`, `build`, `a`, `b` capture `digits` and are called with Ints: labels `piece<int>`, `build<int, int, any>`; the dormant generic entries of `a`/`b` are listed by the plan too (it reads closedness) | labels updated; values and allocation counts (what the tests are about) unchanged |
| `native-block-escape.test` 3 (`-minimal-2`, `-escaping-coexist-2`, `-refined-checks-2`) | NIR headers say `instance="int"` | regexes updated (same function, same env/results/captures checks) |
| `dormant-instances.test` 3 | the dormant set and labels of point 2 change with keys (`get<int>`, the generic entries of every Int-keyed closure) | expectations updated; the closed-caller-theorem test needed a non-Int vehicle (a String parameter `any` in the dormant `scan<generic>`) to keep exercising a dormant caller |
| `result-range-narrowing.test` `-open-instance-summary-stays-sound` | `apply` captures a List, so it is `apply<int, int>` now, and its `list_get(fns, i)(v)` became an exact call of `f<int>` (correct: the summary then includes −50) instead of the dynamic call into `f<generic>` the test is about | two functions in the List keep the call dynamic |
| `blockescape-nested-capturers.test` `-declined` | `d` has two wanted instances | the helper lists bindings (`lsort -unique`) |

`exact-callable-executable.test`'s `refined-checks-scan` fixture (the AOT
executable) passes.

### Evidence

`tools/run-knob.sh … closureIntKeyOpt census-intkeys.txt blocks`
(`out/census-intkeys.txt`): a function-level census (`census-blocks.tcl`:
per function, the join over its live instances of entry, result and
expression Ranges, since keys change): 5,222 facts, all identical; NIR
byte-identical in 39 programs and identical modulo instance labels in 5;
knob off = parent commit, byte for byte (440 comparisons, 0 mismatches).

Compile time: `native::nir` on `refined-checks` 393 → 415 ms (medians of
3, machine loaded), `uri-steady` 122 → 124 ms.

### Fuzzing

`tools/fuzz.tcl -knob hir::specialize::closureIntKeyOpt` (`out/fuzz-intkeys.txt`).
Since this knob changes instance keys, the knob-0/knob-1 comparison is made
per function (the join over its live instances, as `census-blocks.tcl`
does) instead of per instance id; the runtime oracles are unchanged.

| run | programs | native | Range checks | violations | disagreements |
|---|---:|---|---:|---:|---:|
| A | 5,000 | default | 26,796 top-level + 394,560 trace | 0 | 0 |
| B | 2,000 | `-block-escape-opt 0` | 10,830 + 160,338 | 0 | 0 |

In A, 3,140 programs have a dormant instance and 252 change a Range: 195
programs gain a strictly narrower interval somewhere, **146 lose precision
somewhere** (108 of them on a checked top-level call). That is limitation 2
below: a call that used to reach a callee's generic instance (its argument
was `any` in a generic-keyed closure) now reaches the callee's `<int>`
instance and shares its per-instance summary with the other call sites; in
seed 1/315 this closes an abstract cycle (`t1 = f1(3)` feeds `f3`'s argument,
which feeds `f1<int>`'s entry, whose summary is `t1`) that widening resolves
to `[-∞, +∞]`. It is how every keyed static function already behaves; no
corpus program is affected (census above). The pre-existing `list_get`
NATIVE BUG of the point-2 run is gone (fixed by the called-generic commit).

### Adversarial review

An independent review of this commit and the called-generic one
(soundness of both, test changes, downstream consumers), with a probe matrix
of 19 programs over every backend, `-block-escape-opt 0`, `-specialize 0`,
`-call-facts-opt 0`, `-exact-callable-opt 0`, `-closed-caller-facts-opt 0`,
`-raw-int-abi-opt 0`, `-raw-demand-opt 0`, both knobs, `limit` 1-3 and
`exactLimit` 1/4, and AOT builds under GC stress: no soundness problem in
either commit. Its findings, all acted on:

* the fuzzer compared knob-0 and knob-1 instances by id, which breaks when
  keys change (the committed version of the tool at the time); now per
  function, as above;
* three test changes protected less than before: `dormant-closed-audit`
  no longer covered `closedAudit`'s closed-generic-closure branch (now
  pinned again, on the theorem shape's `ok<generic>`); the recursive M7.c
  fixture's `n` had become a key position, so the theorem no longer joined a
  derived self-call argument on a non-key position (the fixture now recurses
  on a String, `substring(s, 1, …)`, theorem `{str str}`); the dormant
  theorem test dropped a Range column (covered by the other dormant tests);
* stale comments (`ClosedSet`'s header, a probe program's header);
* possible precision costs it did not observe: the called generic instance
  is now included in blockescape's self and sibling checks (a pruned call
  there declines the binding), and Int keys count against `limit`.

### Verification

On the final tree (all four commits, rebased onto `main` at `66dbf7d`),
each suite in its own worktree:

| suite | result |
|---|---|
| `tests/all.tcl`, interp | 4,590 / 4,590 |
| `tests/all.tcl`, compile | 4,586 passed, 4 skipped (`coreScoping`), 0 failed |
| the same under `BOTLISH_NATIVE_GC_STRESS=1` | identical |
| `tests/native-coverage.tcl` (cranelift) | 4,624 tests: native 1,932, independent 2,573, passed-partial 58, unsupported 60, failed 1 (`refined-5`) |
| the same on `main` (`66dbf7d`) | 4,575 tests: native 1,908, independent 2,548, passed-partial 58, unsupported 60, failed 1 (`refined-5`) |

The coverage difference is exactly the 49 added tests (13 nested
capturers, 20 dormant instances, 5 called generic instance, 11 Int keys;
24 native, 25 independent); the one failure is the pre-existing `refined-5`
on both. The point-2 figures in its own section were measured on that
commit before the rebase (`main` at `ccedf43`; the commits since touch only
`surface/` and a report).

Tests: `tests/closure-int-keys.test` (new, 11): `refined-checks`' keys and
entry Ranges with the knob on and off, its NIR identical modulo labels
(demand filter on and off), the RawInt plan's eligibility and suppression
reasons, the Int key and its guard removal without the theorem, other kinds
staying generic, a mixed Int/String closure staying de-closured, and parity
with block escape on and off on three programs.

### Known limitations

1. **No machine-code payoff until points 4 and 5.** The keys and Ranges
   are there; counted loops and de-closured functions do not use them.
2. **Instance merging can widen a per-instance summary.** A call whose
   argument was `any` in a generic caller (and so went to the callee's
   generic instance) can now come from a keyed caller with an Int and share
   the callee's `<int>` instance with other call sites: the fuzzer's seed
   1/5 has `f1<int>` serving both `f2_h(f2_v)` and `f2_h(f2_v - 5)`, so one
   call expression's Range goes from `{8, 18, 21}` to `{8, 13, …, 36}`
   (sound: the program returns the same everywhere). None in the corpus.
3. **More instances**: every Int-called capturing closure keeps a dormant
   generic entry beside its keyed instance (not emitted with block escape
   on), and Int keys count against the per-block `limit`, so a closure
   called with many kinds reaches the all-`any` fallback sooner.

## Next steps (points 4, 5)

Points 1, 2 and 3 are done. On `refined-checks` they give `char_at`'s
`i + 1` a raw add (point 2, −2.26% Ir/run) and `tld?`'s comparisons raw
operations (point 3, −0.19%); point 1 gives `tld?`, `domain?`, `char_at`
and `scan_while` Int keys with the Ranges intact, and changes no machine
code. What still keeps their parameters tagged:

1. **Point 4:** raw induction variables for `CountLoop` (and lockstep
   loops) when the domain's Ranges fit small, and the matching demand-rule
   change (`native/rawabi.tcl:696-709`, "count loop bound"). It makes
   `tld?<int>.i`, `domain?<int>.start` and `scan_while.start`
   `suppressed-mixed-tagged-use` / `suppressed-no-raw-demand` today, and it
   is the only remaining point with a per-character cost in these
   functions (`domain?`'s and `scan_while`'s loop headers). `char_at<int>.i`
   additionally feeds `substring`, a tagged native consumer.
2. **Point 5:** let `InternalFunction` (`native/lower.tcl:2246`) and its
   blockescape-virtual call sites (`abiCall`, `:4676`) take the plan's raw
   positions (`native/rawabi.tcl:64-66` documents the restriction). With the
   demand filter off the plan is already `rawint` for these instances and
   the NIR still does not change.

Smaller open items, outside the numbered points:

* the captured `n` reaches a de-closured function as a hidden trailing
  parameter that is always tagged (`native/rawabi.tcl:162`);
* each `tld?` call materializes an `is_tcl_alpha` native value to pass to
  `scan_while` (limitation 1 of EXACT-CALLABLE-CLOSED-CALLER.md);
* point 1's precision cost: call sites that now share a callee's `<int>`
  instance can widen its per-instance summary (146 of 5,000 fuzz programs,
  none in the corpus; [Loss point 1](#loss-point-1-int-key-positions-for-capturing-closures),
  limitation 2);
* point 2's limitations: the RawInt/ShortString demand rules and virtual
  construction still count call sites in dormant code, and a static block
  materialized only in dormant code keeps its generic instance open
  ([Loss point 2](#loss-point-2-dormant-instances), limitations 2-3);
* unrelated, found by the point-2 review: `interp` accepts a forward
  reference between sibling local closures and returns a value, where
  `compile` and cranelift raise `CORE SEMANTIC UNBOUND`.

The ceiling on `refined-checks` is modest: after point 2 most of its time
is `char_at`'s `rt_substr`/`regioncheck` and `rt_set_contains`.
