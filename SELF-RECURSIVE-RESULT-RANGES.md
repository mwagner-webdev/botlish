# Self-recursive result Ranges

## Outcome

`hir::range` now derives a finite **successful-result Range** for a closed,
direct, self-recursive Int instance whose recursion measure strictly
decreases, by evaluating the *same* Range transfer functions over a finite,
memoized table of measure states.

* `fib<int>` (`bench/fib.bot`, entry `n ∈ [0, 22]`): result Range
  `[-∞, +∞]` → **`[0, 17711]`**, over **23** measure states, both `n - 1`
  and `n - 2` proven decreasing. The Range proves every successful result
  fits the tagged small-Int domain (`[-2^62, 2^62 - 1]`).
* The result is stored through the ordinary mechanism (the instance's
  `result` and `calleeResults`), so every consumer asks one question. No
  specialization change, no new NIR opcode, no runtime/ABI/representation
  change, no source syntax.
* Existing range-aware lowering consumed the new fact with no new lowering
  code: `fib<int>` NIR now adds the recursive results with a raw `riadd`
  (no tag tests, no overflow branch, no cold `rt_int_add`), and the
  function lost every GC safepoint and root store as an automatic
  consequence. Machine code for `fib<int>`: 243 → 148 bytes, 49 → 37
  instructions per internal call, 20 → 17 per leaf call;
  **1,977,300 → 1,547,454 Ir/run (−21.7 %)**.
* Controls are byte-identical: with the analysis on, the NIR of every
  other canonical program (all `bench/*.bot` and `examples/stdlib/*.bot`)
  is identical to the parent's; with `-recursive-result-range-opt 0` the
  `fib` NIR is byte-identical to the parent's.
* Soundness evidence beyond the proof: a randomized check against the
  reference interpreter (1,090 random decreasing recursions, 7,299 state
  values; `tools/fuzz.tcl`) found 0 violations.

Files: `hir/rangerec.tcl` (new: solver, `analyze`, audit), `hir/range.tcl`
(`analyze` renamed `Fixpoint` with a `pinned` input; two state-mode hooks;
`ComparisonOutcome` factored out of `ConditionOutcome`), `native/lower.tcl`
and `native/explain-native.tcl` (options/audit), `tests/self-recursive-
result-ranges.test` (37 tests), `audit/self-recursive-result-ranges/`.

## Motivation

The machine-code investigation (`MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md`,
Case 1) showed `fib<int>` had not regressed; its remaining per-call residue
came from facts never derived. The entry Range `[0, 22]` was already
exploited (raw `n < 2`, `n - 1`, `n - 2`), but the recursive *result* was
unknown, which cost, per internal call: tag checks on both recursive
results, an overflow check on the addition, a cold `rt_int_add` path, the
tagged result, and GC-root stores around calls that could (formally)
allocate. This milestone recovers the missing semantic fact and nothing
else.

## Starting `fib` machine code

From the investigation (and regenerated here with
`-recursive-result-range-opt 0`, byte-identical to the parent): 243 bytes
for `fib<int>` (292 for the program), 49 instructions on an internal call
path, 20 on a leaf path, `1,977,300` Ir/run:

```
mov rax,rsi; sar rax,1; cmp rax,2; jl leaf       ; raw compare (entry Range)
... lea/shl/or/mov [rsp],rsi; call fib           ; raw n-1, retag, root store
mov r12,rax; mov [rsp],rax; ... call fib        ; result kept as a tagged Value
mov [rsp+8],rax; mov rcx,r12; and rcx,rax; test rcx,1; jne ...   ; TAG TESTS
lea rcx,[rax-1]; mov rax,rdx; add rax,rcx; seto cl; test cl,cl; je ...  ; OVERFLOW
call rt_int_add                                  ; COLD generic path
```

## Existing result-summary machinery

* `hir::range::Call` answers an exact block call from
  `calleeResults[target]`; `analyze`'s round loop fills it from each
  instance's own `result` (join of its trailing value and `return`s), keeps
  it monotone (an initial `unknown` is provisional; a concrete summary only
  widens; destroyed once means unknown for good: `resultPoisoned`).
* For a **self-recursive** instance the self call reads the instance's own
  summary, so round 1 reads `unknown`, the result is `unknown`, and nothing
  can ever improve it. This is why `fib` stayed `[-∞, +∞]`. (Non-recursive
  exact callees get real summaries, e.g. `work<int> -> [7,7]`.)
* Entry Ranges are a separate fixpoint (caller propagation + self-feedback
  with `widen`, then a post-widen narrowing phase). The result summaries
  are read by lowering through exact call expressions' Ranges
  (`hir::range::of`).

## Eligibility theorem

Let `F` be an instance such that

1. `F` is **closed** (`hir::specialize::InstanceClosed`, read through
   `hir::range::OpenInstances` — there is no second openness notion);
2. `F` is **directly** self-recursive and is not on a call-graph cycle
   through another instance;
3. some Int parameter `p` (the **measure**) has a **finite external entry
   Range** `E` — the join of the argument Ranges of every reachable exact
   call from *other* instances — with at most `limit` start states;
4. at every measure state `k` reachable from `E`, every self call the
   range analysis reaches passes a `p`-argument whose Range is finite and
   entirely **below `k`** (strict decrease), and the number of states
   created stays within `limit`;
5. every successful-result summary comes out finite.

Then one abstract summary `S(k)` per state, computed from the same transfer
functions, is a post-fixpoint of the abstract transformer, hence a sound
successful-result bound (see *Soundness argument*). Anything else falls back
to the existing (unknown) summary.

## Authoritative closedness requirement

A solved summary is only valid for the callers the analysis knows, so the
solver requires `InstanceClosed` (via `OpenInstances`). An open generic
instance (callable escapes, unknown callers) is rejected `open-instance`
and keeps `[-∞, +∞]` — a bounded summary is never derived from one known
call site. Test: `rec-neg-open-callable`.

## Finite-entry requirement

Both bounds must be finite, and the number of start states (the external
entry's tracked exact value set when it has one, else every integer of the
interval) must fit the budget. `[0, +∞]` and `[-∞, +∞]` are
`unbounded-entry`; a finite million-state interval is `state-budget`
(computed arithmetically — no iteration). Test: `rec-neg-unbounded-entry`,
`rec-neg-state-budget`.

One deliberate refinement of "entry Range": the solver reads the *external*
entry (what callers pass), not the ordinary analyzed entry. For `fib` both
are `[0, 22]`/`{22}`. They differ when the ordinary entry is weaker than
what the code actually reaches: `if n == 0: 1 else: f(n - 1) + 1` called
as `f(5)` has ordinary entry `[-∞, 5]` (`hir/induction.tcl`'s equality
termination proof covers self-*tail* calls only), but external entry `{5}`
and a state closure of exactly `5..0`, so it is solved (`[1, 6]`). Caller-
derived entry facts remain the source — nothing is newly inferred from
source syntax.

## Recursion measure

Any Int parameter (by type, `core::type::base == int`) with a finite
external entry is a candidate. Candidates are tried in parameter order; the
first whose whole solve succeeds is the measure. No annotation. If every
finite candidate fails with a non-decrease, the tag is `multiple-measures`
(no single parameter decreases in every reachable self call; lexicographic
and multi-dimensional measures are future work).

## Strict-decrease proof

Decrease is checked **semantically per state**, not by syntax: while walking
state `k`, each self call's measure-argument Range `A` (produced by the
ordinary transfer functions, so overflow/representation can't invalidate
it — Ranges are arbitrary precision) must satisfy `A.max < k` with both
bounds finite. This covers `n - C` (`C > 0`) and `n + C` (`C < 0`) and
anything else the Range lattice proves (e.g. a shift). A call that fails
(`f(n)`, `f(n + 1)`, `f(n - 1)` beside `f(n)`) rejects the instance
(`nondecreasing-call`); an unbounded argument is
`unknown-recursive-arg-range`. A non-decreasing call in a branch the walk
proves dead at every state is never reached and so ignored.

## State-domain construction

States are explored from the start states **downward** along the proven
self calls (a worklist closure), each memoized once. The solver does *not*
assume the measure stays inside the entry interval (spec #62–63): a state is
analyzed only if some reachable state's self call selects it, and states
below the entry interval are created when needed (`fib(22)` creates 22…0;
`f(n - 2)` from 30 creates only the reachable states; a function that
stops at 1 never creates 0 — `rec-multiple-returns` result `[100, 105]`).
Two branches reaching the same state share its summary.

## State budget

`maxRecursiveRangeStates` (default **128**, chosen from the scaling table
below) bounds the number of distinct states. It is exposed as the
audit/native option `-recursive-range-limit N` (and
`BOTLISH_NATIVE_RECURSIVE_RANGE_LIMIT`), and as the `recursiveLimit`
argument of `hir::range::analyze`; never source syntax. Three guards:
start-state count (arithmetic), per-call argument width, and the running
state count. A fourth is a *compile-time economy*: the ordinary entry
Range's finite lower bound is a floor under every state, so a chain at
`lowest` with largest observed step `s` needs at least
`⌈(lowest − floor)/s⌉` more states; if even that overruns the budget the
solve is abandoned after a couple of walks (`loop-count`'s 2,000-state
`drive` otherwise cost `limit` walks to reject). It can only mispredict a
chain that stops above the floor, losing a bound, never soundness.

## Recursive result solver

`hir::range::SolveMeasure` (hir/rangerec.tcl): for a stack of states
(start states, then discovered smaller states), pop state `k`, run the
ordinary `AnalyzeInstance` with the measure parameter fixed to the point
`{k}` and every other parameter at its converged entry Range, in *state
mode* (ctx key `rec`), which changes exactly two things:

* a **self call** with measure-argument Range `A` is answered with
  `join { S(j) | j ∈ A }` from the memo table (`RecursiveCall`); missing
  smaller states are recorded as needs and the call answers a placeholder
  that is flagged incomplete and never judged;
* an **`if`** whose condition is a direct native comparison decided by the
  point-valued measure takes only the live branch (`RecursiveDecided` →
  `ComparisonOutcome`, the theorem native lowering already uses for
  dead-branch elimination, now factored so both share one definition).
  Base cases are found by ordinary condition analysis; nothing recognizes a
  shape or a name.

A state is walked at most twice: once to discover its needs, once when they
are all memoized. All other transfer functions, exact-call results of other
instances, constants, aliases, returns, trailing values and `if` joins are
the unchanged ordinary ones. The instance's result is the join over all
memoized states; if any bound is infinite (or there is no successful
result) the solve is rejected `unsupported-result`.

## Successful-result semantics

The summary is the join of the ordinary walk's *normal completion* value and
its `return`s — exactly the existing definition of an instance result. An
error (`fail`, a proven-failing call) never completes normally in the
analysis (`never`), so error paths contribute no value and the Range stays
finite; the solver never concludes an error is impossible, and error
semantics are the existing ones (`rec-error-path-*`: the failing state
`-3` has an empty summary while `f` gets `[1, 3]`; values and errors agree
on all backends, with and without the analysis). `handle` yields `unknown`
for its own value, so a recursion whose result flows through a `handle`
declines `unsupported-result` rather than being analyzed specially.

## Fixpoint / widening interaction

`analyze` (now in `hir/rangerec.tcl`) runs the ordinary fixpoint
(`Fixpoint`) first, **unchanged**: with no eligible recursion that is all
that happens, plus a cheap detection pass. The converged entry Ranges are
frozen as the solver's input. Solved summaries are **pinned**: they seed
`calleeResults`, are skipped by the round loop's join/poison logic and by
widening, and replace the instance's `result` in the output. `Fixpoint` is
re-run once with them so callers consume them through the ordinary result
machinery. Widening cannot poison the solve because the solve never reads
the instance's own `calleeResults` entry (the ordinary analysis's `unknown`
or poisoned value) — self calls are answered from the memo table.

Chain: sound entries → sound summaries → sound re-run. The re-run's
(possibly narrower) entries are never used to justify the summaries they
were produced with. The summaries are re-derived once more only if the
solve's inputs (the instance's entry/capture facts, its external entry and
the summaries of the callees it calls) changed; `maxRecursivePasses` (2)
bounds the chain. There is no unbounded caller → result → caller loop; the
monotone-convergence argument is simply "each link is independently sound,
the chain is finite". Where the chain is cut early the result is merely less
precise.

## Soundness argument

Define `Walk_F(k, S)` as the ordinary state-`k` range walk of `F` in which
a self call with measure Range `A` returns `⊔{S(j) | j∈A}`. The table `S`
satisfies `S(k) = Walk_F(k, S)` and `Walk_F(k, S)` reads only `S(j)` with
`j < k` (checked at every reached call). A successful run of `F` at
measure `k` returns a value in `S(k)` by induction on the finite derivation
of that run: its self calls return values in `S(j)` (smaller derivation, the
actual `j` lies in the call's argument Range because the walk's ranges
over-approximate); its other calls return values in already-sound summaries
(callee results under the final converged entries); its other parameters lie
in their converged entry Ranges (a sound post-fixpoint including self-call
feedback); its branches take only outcomes the Range facts allow. Hence
`S` is sound for **successful results**; partial correctness needs no
termination argument. *Strict decrease is what makes `S` well defined in one
pass* (no `S(j)`, `j ≥ k`, is ever read, so no iteration/widening is
required), and a start/discovered state list that is the closure of the
reachable states covers every actual invocation of `F` that can occur from
the known callers (external entry from closed callers + self calls). The
pinned result is the join over the whole table, so it also covers internal
invocations.

Soundness of the inputs: the external entry comes from callers' *final*
reachable calls under converged entries; closedness guarantees these are all
the callers.

## Complexity

At most two walks per state (O(states × walk cost); a walk is the ordinary
single-instance analysis), plus the pinned `Fixpoint` re-run and the
detection pass. Memoization per (instance, state) removes the recursion
tree: `fib(22)` is 23 states, not 57,313 calls. A walk is ≈ 0.35 ms for
`fib`'s body (see the scaling table).

## Fib analysis trace

`native/explain-native.tcl` writes `recursive-ranges.txt`
(`audit/self-recursive-result-ranges/out/fib/recursive-ranges.txt`):

```
instance fib<int>
  measure parameter: n
  entry: [0, 22]  (after: [0, 22])
  external entry: [22, 22] {22}
  state count: 23
  self calls:
    e11  n - 1  : [1, 21]
    e17  n - 2  : [0, 20]
  decrease: proven (every reached self call's measure argument is entirely below its state)
  result: [-∞, +∞] -> [0, 17711] {0,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711}
  fits small Int: 1
    n=0 -> [0, 0]      n=1 -> [1, 1]      n=2 -> [1, 1]      n=3 -> [2, 2]
    n=4 -> [3, 3]      n=5 -> [5, 5]      ...   n=21 -> [10946, 10946]
    n=22 -> [17711, 17711]
```

The per-state summaries happen to be singletons (the Range lattice tracks
small exact sets: `[0,0]+[1,1]` is `[1,1]` exactly), and the instance
result carries the 22 distinct values as its exact set. The algorithm
neither knows nor needs the Fibonacci recurrence.

## Fib result Range

`[0, 17711]` (exact: the tightest possible interval). Entry Range before
and after: `[0, 22]` (unchanged — the result proof does not feed the entry
proof; the solve ran from the already-converged `[0, 22]`/`{22}`).
`fitsSmall` = **1**: `-2^62 ≤ 0` and `17711 ≤ 2^62 - 1`. The Range after
widening the width experiment crosses the small-Int limit at `fib(128)`
(finite, `fitsSmall` 0) — the check is a real proof, not a finiteness
check.

## Fib NIR before/after

`audit/self-recursive-result-ranges/out/fib/opt{0,1}.nir`. Before (parent):

```
%10 = call 1 %9 ; %14 = op rbox %13 ; %15 = call 1 %14
%16 = op iadd %10 %15      ; generic tagged add (tag tests + overflow + rt_int_add)
%5 = move %16
```

After:

```
%10 = call 1 %9
%11 = op runbox %10        ; unbox the (proven small) result
... %16 = call 1 %15
%17 = op runbox %16
%18 = op riadd %11 %17     ; raw add: the sum [0, 35422] fits small, no overflow
%19 = op rbox %18
%5 = move %19
```

Registers 17 → 20 (`runbox` ×2, `riadd`, `rbox`; `iadd` gone). No new
opcode. `tests/native-root-liveness.test` pinned the register count; it is
updated 17 → 20 with a comment (the shadow-slot ceiling is unchanged).
These effects come from *existing* consumers: `hir::range::of` on the
exact-call expression (it reads the pinned summary) feeding
`RawEligibleCall`'s raw-arithmetic selection.

## Fib machine code before/after

(`audit/self-recursive-result-ranges/out/fib/opt{0,1}.asm`;
`native::codeSize`: program 292 → 181 bytes, `fib<int>` 243 → 148.)

Executed instructions per internal call (before 49, after 37), by what
changed (hand-counted from the two listings; the per-run class totals in the
next section are the measured version):

* **removed** — the tag test on the two results (`mov rcx,r12; and rcx,rax;
  test rcx,1; jne`), the overflow sequence (`lea rcx,[rax-1]` tagged add,
  `seto; test; je`) and the cold `rt_int_add` call it guards, **five stack
  stores per call** (four root stores of tagged values plus the slot
  zeroing `mov [rsp+8],0`), one callee-saved save and restore (`r13`), and
  a few register shuffles;
* **added** — the add itself becomes raw, so each result is unboxed once
  (`sar` ×2) and the sum reboxed (`shl; or`): +2 untag, +1 retag-pair;
* the **frame** shrinks `sub rsp,0x30` → `0x10`.

Leaf path 20 → 17 instructions (frame zeroing, one fewer callee-saved
save/restore). The GC consequence is automatic, not a root-policy change:
`native::roots` reports `fib` `effects: may_gc=true → false`, safepoints
3 → 0, root candidates 4 → 0, shadow slots 2 → 0, entry zero slots 1 → 0
(the generic `iadd` was the only operation that could allocate; with it
gone the existing effects analysis finds no safepoint). The stack frame
shrinks 0x30 → 0x10. Native stack-overflow protection is the guard page
(`NATIVE-STACK-OVERFLOW.md`), independent of roots.

## Fib dynamic instructions

callgrind steady state, `profile-nir.sh` methodology of the investigation
(21 runs, run 0 excluded; `out/fib/profile-opt{0,1}/`):

| | before | after |
|---|---:|---:|
| Ir/run | **1,977,300** (reproduces the investigation's figure exactly) | **1,547,454** (−21.7 %) |
| instructions per internal call (28,656 calls) | 49 | 37 |
| instructions per leaf call (28,657 calls) | 20 | 17 |

(`28,656·37 + 28,657·17 = 1,547,441` + 13 for the program entry, exactly
the measured figure.)

Changed instruction classes, per run (`mix.txt`): tag test 85,968 → 0;
overflow check 85,968 → 0; stack store 171,938 → 0; `lea` 28,656 → 0;
prologue 343,881 → 286,567; epilogue 401,195 → 343,881; `mov reg-reg`
429,843 → 343,875; **retag 114,624 → 171,936 (+57,312)**; **untag 57,313 →
114,625 (+57,312)**; arithmetic, compare, branches, calls unchanged.
Note the honest trade: the raw add costs two extra unbox and one extra
rebox per internal call; that is the transport cost the raw-Int ABI
milestone is meant to remove.

## Positive synthetic cases

`tests/self-recursive-result-ranges.test` (all pass; values were checked
against an independent brute-force evaluation):

| case | source shape | result Range |
|---|---|---|
| fib | `n < 2: n; fib(n-1) + fib(n-2)` from 22 | `[0, 17711]`, 23 states |
| A | `n <= 0: 1; f(n-1) + 1`, `f(10)` | `[1, 11]` |
| A (`==` guard, non-tail) | `n == 0: 1; f(n-1) + 1`, `f(5)` | `[1, 6]` (ordinary entry `[-∞,5]`) |
| B | `g(n-1) + g(n-3)`, base `n < 3`, `g(25)` | `[1, 8641]` |
| C | measure `0 → -10` (`n <= -10: 0; f(n-1)+1`) | `[0, 10]`, 11 states |
| D | `f(n-1)*2 + 1`, `f(20)` | `[1, 2097151]` |
| E | `weight(n) + f(n-1)` with exact helper | `[0, 110]` (sound, not tight: see limits) |
| multiple base cases | `n==0`, `n==1`, `n==2` bases | `[1, 500]` |
| non-zero lower bound | `n <= 5: 1`, `f(5)+f(20)` | `[1, 16]`, 16 states |
| step 2 / mixed steps | `f(n-2)`; `f(n-1)+f(n-3)` | `[1, 16]`; `[1, 1278]` |
| multiple returns | `return 7`, `return 100`, else | `[100, 105]` |
| tail recursion | `f(n-1)` tail, constant base | `[7, 7]` |

Parity (interp, compile, `cranelift-generic`, `cranelift`, native without
the analysis): `fib`, two-calls, helper, negative, constant-result,
multiple-returns, error-path agree. The constant-result case exercises
`ClosedResult` replacing every call result with the constant 7.

The spec's example E in its nested form `helper(f(n - 1))` is *not* solved:
`helper`'s own result depends on its argument Range, which depends on the
unknown `f` result, so its summary is unknown when the solve needs it
(the cycle is through a callee, not through `f`). The shape in the table
(helper applied to the measure) is solved. This limitation is stated below.

## Negative / rejection cases

Each pins "no bounded summary" and the audit tag:

| case | tag |
|---|---|
| `f(n): f(n)` | `nondecreasing-call` |
| `f(n): f(n + 1)` (bounded caller) | `nondecreasing-call` |
| `f(n-1)` beside `f(n)` (both reached) | `nondecreasing-call` |
| entry `[0, +∞]` (`mod(500, 11)` caller) | `unbounded-entry` |
| 1,000,000 states | `state-budget` |
| 23 states with limit 22 (explicit option) | `state-budget` (and with 23: solved) |
| no Int parameter (`f(b)` over Bool) | `no-int-measure` |
| `f(a, b-1)` and `f(a-1, b)` | `multiple-measures` |
| recursive function also passed as a value | generic instance `[-∞, +∞]`, never pinned (`open-instance` when self-recursive) |
| mutual recursion | `MutuallyRecursive` call-graph test; lexical mutual recursion is already a resolution error (`hir-specialize-9b`), so only exact-callable cycles can occur |
| accumulator `f(n-1, acc+1)` | `unsupported-result` (needs `acc ≤ 10 - n`, a relational fact; spec #106) |
| `-recursive-result-range-opt 0` | no record, parent facts |

`unsupported-control` is reserved and not emitted: a construct the walk
can't see through (`handle`) shows up as an unknown value, i.e.
`unsupported-result`.

## Error-path cases

`g(m) = f(m - 3)` with `f` failing `Negative` for `n < 0`, called with
ranges that include failing values: the state closure contains `-3`
(`never`), `0`, `1`, `2`; `f` gets `[1, 3]`. `parity` with dynamic arguments
(`mod(500, 11)` is statically unknown) gives `[3, -1]`, `[6, 1]`, `[-1, -1]`
identically on all backends with and without the analysis, and as a
standalone executable, plain and under GC stress.

## Corpus census

`audit/self-recursive-result-ranges/out/census.txt` (all 17 canonical
`bench/*.bot` + `examples/stdlib/*.bot`; shared helpers recur across
programs, so counts are of instances per program):

* self-recursive instances: **49**; eligible/solved: **1** (`fib`); finite
  summary gained: **1**.
* rejections (48): `nondecreasing-call` 22, `unbounded-entry` 14,
  `state-budget` 6, `multiple-measures` 3, `unknown-recursive-arg-range` 2,
  `no-int-measure` 1.
* Dominant reason: **ascending index recursion** — the corpus's loops
  are `f(i + 1)` toward a bound (`reverse_from`, `dot`, `ht_fill_empty`,
  the CSV scanners…). They are rejected because the measure *increases*;
  most of them have no Range-finite bound anyway (`length(s)` bounds only
  to `[0, 2^62)`, and the bound is relational: `i ≤ length`). The natural
  next extension, if wanted, is the mirrored order for an increasing
  measure with a finite upper bound; the corpus gives the relational
  limitation (spec #106) as the real obstacle.
* No other canonical workload changes: NIR is **identical** with and
  without the analysis for all programs but `fib` (`refined-checks`, `CSV`,
  `Hashtable`, `test-selection`, `lex-strategy`, `source-checks`, `loop-
  count`, `sum-refined`, `matmul`, `uri-steady`, `ai_text_clean`, ...).

## Result-range consumer audit

**Who reads a successful-result Range.** `hir::range::analyze`'s output is
consumed only by `native/lower.tcl` (and `native/explain-native.tcl`, audit
tools). The result reaches lowering through the Range of an **exact call
expression** (`Call` → `ConstrainType(calleeResults[target])` →
`hir::range::of`). The consumers are:

1. raw-arithmetic selection (`RawEligibleCall`/`RawIntOp`, the
   `iadd/isub/imul` raw lowering): operands and the result fit small ⇒ `riadd` etc. instead
   of tag tests + overflow checks + generic helper;
2. `ClosedResult`: a call whose Range is a single small point becomes that
   constant (the call itself is still performed);
3. `ConditionOutcome` (M6 dead-branch elimination) and `FoldPureBitwise` /
   other operand-range folds;
4. the stack-map/effects analysis, *indirectly*: removing the generic
   `iadd` removed the only possibly-allocating operation in `fib`, so
   `may_gc` became false and no safepoint/root remains.

The instance `result` field itself has no lowering consumer (only audit
and tests). Nothing in the type, effect or completion analyses reads a
value Range as proof of totality (`No value fact implies completion or an
effect`).

**Automatic effects at `fib`:** tag-check elimination, overflow-check and
cold-path elimination, raw add, loss of all GC safepoints/root stores and
slot zeroing, smaller frame.

**Expected effects that still require the raw-Int ABI:** the result is
still returned tagged and arguments are still passed tagged, so each
internal call still pays `rbox`/`runbox` at both boundaries (retag 171,936
+ untag 114,625 = 286,561 Ir/run, 18.5 % of the remaining 1,547,454), plus
the entry `sar` of the parameter; leaf frames and callee-saved traffic
(`mov reg-reg` 22 %, prologue/epilogue 40 %) remain backend territory.

## Small-Int proof

`fib<int>` successful results: `[0, 17711]`, `hir::range::fitsSmall` = 1
(`smallMin = -2^62`, `smallMax = 2^62 - 1`, the only definition of the
runtime's tagged range). Intermediate additions `[0, 35422]` also fit.
This is the prerequisite the raw-Int ABI milestone needs: **parameters
`[0, 22]` and results `[0, 17711]` are both proven within the machine-small
domain for every call of the closed instance**. The query checks against
the real boundary (Botlish Int semantics, negatives included); proofs fail
honestly — `fib(128)` is finite and *not* small.

## Compile-time impact

Median of 9 runs, ms, `audit/self-recursive-result-ranges/out/compiletime.txt`
(opt 0 → opt 1 of `-recursive-result-range-opt`):

| program | hir::range | native lowering (nir) | whole compile |
|---|---|---|---|
| fib | 3 → 16 | 2 → 3 | 11 → 24 |
| loop-count | 3 → 4 | 3 → 4 | 13 → 14 |
| sum-refined | 2 → 2 | 3 → 4 | 12 → 13 |
| refined-checks | 69 → 69 | 66 → 58 | 392 → 376 |
| csv_records (largest) | 194 → 198 | 379 → 348 | 732 → 741 |

(Medians include noise of a few ms; "lowering" is `native::nir` minus the
earlier phases, as in the exact-callable measurements.) Programs without an
eligible chain pay only the detection pass; the doomed 2,000-state chain of
`loop-count` is rejected by the predictive abort after two walks (before
that abort it cost `limit` walks: 4 → 24 ms). `fib` pays for 23 states
(≈ 9 ms solve + ≈ 4 ms pinned re-run).

### State-budget scaling

`tools/budget.tcl`, `fib(W)` (W+1 states), median of 7, `hir::range::analyze`
with the analysis off/on, limit lifted:

| W | off ms | on ms | states | fits small | result max |
|---:|---:|---:|---:|:-:|---|
| 8 | 2.4 | 8.0 | 9 | 1 | 21 |
| 16 | 2.9 | 12.2 | 17 | 1 | 987 |
| 32 | 3.4 | 20.6 | 33 | 1 | 2,178,309 |
| 64 | 1.6 | 25.3 | 65 | 1 | 10,610,209,857,723 |
| 128 | 1.6 | 46.3 | 129 | 0 | ≈ 2.5e26 |
| 256 | 1.7 | 90.6 | 257 | 0 | ≈ 1.4e53 |
| 512 | 1.5 | 185.7 | 513 | 0 | ≈ 4.5e106 |

Linear, ≈ 0.35 ms per state; precision is exact throughout (and the
fits-small answer flips between 64 and 128, as it must). **Default 128**:
worst-case ≈ 45 ms per eligible instance, covers the natural "n ≤ 100"
domains; larger entries are rejected `state-budget` arithmetically.

## GC stress

`BOTLISH_NATIVE_GC_STRESS=1` over `tests/self-recursive-result-ranges.test`
(37 tests, in-process native on every focused recursive program, plus the
standalone-executable tests below run stressed): **all pass**. GC-stress is
otherwise a CI job (`gc-stress` on `main`); the representation is unchanged
and the only GC-relevant change is the one in the roots report above
(`fib` has no safepoint left, which is the effects analysis's own
conclusion from the removal of the generic add).

## Standalone parity

`rec-executable-{fib,two-calls,negative,error-path}`: each program is
compiled with `main.tcl -emit-native-executable`, moved, run with an empty
`PATH` normally and under `BOTLISH_NATIVE_GC_STRESS=1`, and compared with
the interpreter value: all agree.

## Full regression

See the end of this document (filled in after the final run).

## Known limitations

* **Decreasing measures only.** `f(i + 1)` toward a finite bound is
  rejected; this is the corpus's dominant shape (see census), but the
  bounds there are mostly relational (`i ≤ length(s)`).
* **No relational facts** (`acc ≤ 400 - n`): an accumulator is
  `unsupported-result` unless its own Range is finite.
* **Cycles through callees.** If a callee's summary depends on the
  recursive result (e.g. `helper(f(n - 1))` where `helper`'s result is a
  function of its argument), the callee summary is unknown when the solve
  needs it. Solving this needs context-sensitive callee analysis or an
  optimistic guess-and-verify step.
* **Direct self recursion only**; mutual recursion (reachable only through
  exact callables) is declined by a call-graph test. No multi-dimensional
  measures.
* **State-less per-expression Ranges stay loose.** Inside the solved
  function the call-expression Range is the whole-instance `[0, 17711]`, so
  `fib(n-1) + fib(n-2)` is `[0, 35422]` — still small, but not as tight as
  the state's own `S(n)`.
* The exact-set tracking budget (32) makes `fib`'s result carry an exact set
  of 22 values; harmless, sound, and not relied upon.
* The predictive abort and the callee-summary refinement are heuristics for
  cost/precision only; they can lose a bound, never produce an unsound one.
* **Future work:** large finite domains could be solved with interval
  recurrences (a symbolic summary over a parameterized interval) instead of
  pointwise states — deliberately not attempted here.

## Readiness for raw-Int ABI

Everything the raw-Int ABI milestone needs from analysis is now available
per closed instance, through ordinary queries: entry Range per parameter
(`[0, 22]`), successful-result Range (`[0, 17711]`), `fitsSmall` against
the real boundary, `InstanceClosed`, and the derivation record
(`analysis recursive`) explaining each summary. Costs that remain, which
the raw ABI targets: boundary `rbox`/`runbox` pairs (retag + untag =
286,561 Ir of the remaining 1,547,454), the entry unbox. Costs it will not
touch: frame prologue/epilogue and callee-saved traffic (40 % of Ir; leaf
fast path / shrink-wrapping is backend work), and the separately
diagnosed "an `rbox` immediate need not be rooted" issue (moot for `fib`
now that it has no safepoint, still relevant elsewhere).

---

## Answers to the required questions

**Architecture.** (1) Recursive result analysis lives in `hir::range`
(`hir/rangerec.tcl`, same namespace). (2) Specialization does not change.
(3) NIR gains no opcode. (4) Runtime representation does not change.
(5) Yes: stored through the ordinary result mechanism (instance `result` /
`calleeResults`); the per-state table is audit data, never a competing
summary.

**Eligibility.** (6) Closed + direct + one Int measure with finite external
entry + strictly decreasing reachable self calls + finite result + within
budget. (7) A bounded summary is only valid for the callers the analysis
knows; `InstanceClosed` is the single authoritative proof of that. (8) The
first Int parameter with a finite external entry whose full solve succeeds.
(9) Per state, the call's measure-argument Range (from the ordinary
arbitrary-precision transfer functions) must be finite and entirely below
the state. (10) The instance is ineligible (`nondecreasing-call`, or
`multiple-measures`) and keeps the conservative summary. (11)
`unbounded-entry`: fallback. (12) `state-budget`: fallback; the million-state
case is rejected arithmetically.

**Soundness.** (13) Every dependency is a strictly smaller state; the
state set is finite (budget) and the descent is over the integers, so the
worklist terminates; the table is a post-fixpoint regardless of whether the
program itself terminates. (14) A state is only finalized after a walk in
which every needed smaller state was memoized (a walk with a missing need is
discarded and redone). (15) Per call, the join of the summaries of the
states in its argument Range; two calls are then added by ordinary Range
addition. (16) Error paths are `never` in the walk (no value contributes);
the successful-result Range is the join of normal completions and returns,
the existing definition; error analysis is untouched. (17) The solve reads
only converged entries and other instances' summaries; the instance's own
result is never an input (self calls read the table), and the entry facts it
consumes were proved before and without it.

**Fib.** (18) `[0, 22]` (external `{22}`). (19) `[0, 17711]`. (20) 23. (21)
Yes (`[1, 21]` and `[0, 20]` below each state). (22) Yes (`fitsSmall`).
(23) `iadd` → `riadd` with two `runbox` and one `rbox`; the
tag/overflow/cold paths vanish. (24) Tag tests, overflow check, `rt_int_add`
call, 6 root stores/call, slot zeroing, one callee-saved register. (25) The
tagged call ABI (retag/untag per boundary), callee-saved/frame traffic.

**Performance.** (26) 1,977,300 → 1,547,454 Ir/run. (27) `fib<int>` 243 →
148 bytes; program 292 → 181. (28) 49 → 37 instructions per internal call.
(29) 20 → 17 per leaf call. (30) `hir::range` for fib 3 → 16 ms (≈ 9 ms
solve + ≈ 4 ms re-run); unchanged elsewhere. (31) Whole compile 11 → 24 ms
for fib; unchanged within noise for the others. (32) Linear, ≈ 0.35
ms/state; default budget 128.

**Corpus.** (33) 49 self-recursive instances. (34) 1 eligible. (35) 1 gains
a finite summary. (36) `nondecreasing-call` (22 of 48), i.e. ascending
index loops. (37) No: every other canonical program's NIR is identical.
