# Raw 64-bit Int ABI

## Outcome

An exact, **closed** Botlish instance transports an Int parameter, and its
successful Int result, as a **raw signed machine integer** (`RawInt`, a
two's-complement `i64` on the current native target) instead of a tagged
`Value` when three conditions hold:

1. **Safety (eligibility, the theorem).** The position's semantic type is Int,
   its instance is closed (`InstanceClosed`), and its final Range
   `fitsSmall` (`hir::range::fitsSmall`): the integer is provably a small
   tagged Int at every call, so the raw/tagged conversions at the boundary are
   non-allocating and lossless.
2. **Usefulness (raw demand).** Raw representation is *demanded* somewhere in
   the position's use / transport closure: some reachable consumer genuinely
   wants a raw Int (a raw arithmetic or comparison operand, a raw self-tail loop
   slot), possibly behind aliases, branches, returns and exact call edges.
3. **No competing tagged use (mixed uses are boxed).** No consumer in that
   closure needs a tagged Value. A position with both raw and tagged consumers
   stays tagged.

```
eligible  +  raw demanded  +  every consumer in the closure raw   =>  RawInt
eligible  +  the entire closure tagged-only                       =>  tagged Value
eligible  +  mixed raw/tagged consumers                           =>  tagged Value (boxed by default)
```

Conditions 2 and 3 are a usefulness filter layered *after* the safety theorem;
they never make an ineligible position raw and never change a value, an error
or a completion. They exist because eligible-but-undemanded or only partly
demanded raw transport is a `tagged -> raw -> tagged` round trip with nothing to
gain (the preliminary milestone's hashtable/CSV regression, below). The semantic
type stays `Int`, arbitrary precision, and the canonical tagged ABI is
untouched everywhere the proof or these rules do not apply. A tagged consumer in
the *program function* (it runs once, so it is the single frontier conversion
every raw region has) does not count as a competing use.

* `fib<int>` (`bench/fib.bot`) is physically `i64 fib(i64 n)`: `n` raw, the
  result raw, `n - 1` / `n - 2` passed raw, results added with the existing
  raw `riadd`, returned raw. **No `rbox`/`runbox` remains in the function**
  (before: 3 + 3). The program passes the literal `22` as a `rawint` and boxes
  the final result once. Every consumer in its recursive parameter/result
  cycle is raw (`rilt`, `risub`, `riadd`, the program's boundary box), so both
  suppression rules leave it exactly as the preliminary milestone had it:
  **byte-identical NIR, 1,404,178 Ir/run**.
* Dynamic instructions (callgrind, 21 runs, run 0 excluded): **1,547,454 →
  1,404,178 Ir/run (−9.3 %)**. All 286,561 Ir of retag/untag disappear; about
  half of that is given back by one extra callee-saved register the backend now
  keeps (see *Fib dynamic instructions*), which is backend territory and is
  recorded, not optimised.
* The plan is one authoritative `native::rawabi` result, computed once after the
  closedness and Range analyses and read by the callee's lowering and by every
  call site. NIR carries the physical signature in the function header
  (`rawparams="0 2" rawresult=1`); `native/src/nir.rs` re-validates caller/callee
  agreement and rejects a mismatch as a compiler bug. The demand rules feed that
  same plan, so a suppressed position is tagged for the callee and for every
  caller by construction.
* Errors are never encoded in the integer. A raw-result function that cannot
  fail returns the bare integer; one that can fail returns the integer plus a
  status word (second return register).
* Whole canonical corpus (A tagged ABI → B RawInt eligibility only → C demand,
  mixed uses kept raw → **D demand, mixed uses boxed (production)**): machine
  code **101,963 → 101,662 → 101,552 → 101,879 bytes**, 233 functions in every
  configuration, GC root candidates 1,283 → 1,238 → 1,244 → 1,276. Of 79 eligible
  positions (56 parameters, 23 results) **20 are selected** (19 parameters, 1
  result; B: 79), 3 + 17 suppressed for want of any raw demand and 34 + 5 as
  mixed uses. Static `rbox`/`runbox`: **47/47 → 66/48 → 60/41 → 44/42**.
* **The regressions are recovered in full:** `hashtable` 12,732 (tagged) →
  12,799 (+67) → **12,732 (+0)**, `csv_geometric` 7,578 → 7,597 (+19) →
  **7,578**, `csv_records` 23,245 → 23,204 → 23,234; and no program is larger
  than the tagged baseline except `uri-steady` (+9 bytes, a mixed-parameter
  frontier in `web::is_unreserved`, see *Known limitations*). The price of the
  boxed-mixed default is that the preliminary milestone's size gains in
  programs whose parameters mix raw and tagged uses shrink (`matmul` −223 → −51
  bytes, `lex-strategy` −40 → 0): see *Updated corpus code-size result*.
* Regression, differential fuzzing, GC stress and standalone-executable
  parity: see *Full regression*, *Differential testing*, *GC stress* and
  *Standalone parity* (results pending final validation).

Files: `native/rawabi.tcl` (planner, demand pass, audit), `native/lower.tcl`
(plan storage, callee/caller lowering, raw `if` join, raw alias, options),
`native/src/nir.rs` (header attributes, validation, call-site effect rule, unit
tests), `native/src/codegen/clif.rs` (physical signature, prologue, call/ret,
generic-entry conversion), `native/explain-native.tcl` (`raw-int-abi.txt`),
`tests/raw-int-abi.test` (69 tests), `audit/raw-int-abi/`.

## Motivation

The previous milestone proved `fib<int>`'s argument and result are small Ints,
and made the arithmetic inside the function raw. Every recursive boundary still
did `raw n → rbox → tagged argument → call → tagged result → runbox → raw
arithmetic`, and the result was reboxed on the way out. That is representation
conversion that serves no semantic purpose: the theorem "this Int cannot become
a BigInt" was forgotten at the function boundary. The measured cost was 286,561
retag + untag Ir out of 1,547,454.

## Starting fib representation

```
func 1 "fib" params=1 ... rawregs="1 3 7 8 11 13 14 17 18"
    %1 = op runbox %0              ; n is tagged on entry, unboxed once
    ...
    %8 = op risub %1 %7
    %9 = op rbox %8                ; boxed again to cross the call
    %10 = call 1 %9
    %11 = op runbox %10            ; and unboxed again
    ... (same for n - 2)
    %18 = op riadd %11 %17
    %19 = op rbox %18              ; result boxed to return
    ret %19
```

## Semantic proof inputs

The planner reads exactly three things and invents no numeric fact:

1. `hir::specialize` — `closed` (`InstanceClosed`: every invocation of the
   instance is a direct exact call the analysis saw), the instance's key types
   and its result type.
2. `hir::range` — the instance's final **entry Range** per parameter, and its
   **successful-result Range**, through the same ordinary result query every
   consumer uses. The self-recursive result summary of the previous milestone
   arrives through that query; there is no `if function is recursive` logic in
   the planner (`raw-result-follows-the-ordinary-result-query` pins this:
   withdrawing the summary with `-recursive-result-range-opt 0` or a too-small
   `-recursive-range-limit` makes the *same* instance's result tagged again).
3. `hir::range::fitsSmall` — the one membership test.

## Why RawInt is signed i64

Small tagged Botlish Ints are `[-2^62, 2^62 - 1]`, so every value that passes
`fitsSmall` is exactly representable as a signed 64-bit machine integer. There
is no need to derive a narrower width: the decision is *tagged vs raw
machine-word*, not *which width*. The encoding is plain two's complement — no
tag bit, no bias, no pointer-like encoding. The physical register is `i64`, but
the admissible domain is still the small-Int domain, not all of `i64`
(`raw-outside-small-result`, `raw-outside-small-parameter`: a Range reaching
`2^62` fits a register but gets the tagged ABI, and `succ(2^62 - 1)` correctly
returns the BigInt `4611686018427387904`).

## Why there is no RawInt32 ABI

On the current 64-bit scalar call ABI, `i32` and `i64` both occupy one general
machine argument/result slot; a narrower width therefore does not reduce
transport width, while it would multiply ABI variants. Range may still record
that a value fits `i32` as metadata (it is not an ABI class), and local/backend
lowering may exploit narrower arithmetic later.

## Eligibility theorem

A parameter position (resp. the successful result) of instance `I` is RawInt iff

1. its semantic type is Int (key type `int`; the result type's kind is `int`),
2. `I` is closed (`InstanceClosed`), and
3. its final entry (resp. successful-result) Range satisfies `fitsSmall`.

*Why closed*: the Range is a statement about every invocation only if every
invocation is known; an open instance (its Block value escapes, or it has
unknown callers) has callers that would pass tagged Values, and a Block value
always enters the tagged generic entry. A bound derived from one known caller
is never used (`raw-open-instance-stays-tagged`). *Why `fitsSmall` and not
"finite"*: the raw/tagged conversions at the frontier are non-allocating only
inside the small domain; a finite Range reaching `2^62` may need a BigInt.
Negative ranges are eligible (`raw-negative-range`, `raw-small-domain-edges`).
Lowering also checks one non-analysis fact: with `-block-escape-opt 0` every
closure is materialized as a Block value whatever the proof says, so the planner
treats generic closure instances as open then (found by the existing
`blockescape-*` tests; `GenericRef` also asserts it).

## Authoritative ABI plan

`native::rawabi::plan` returns `InstanceId → {params {value|rawint…} result
value|rawint paramReasons resultReason closed paramEligible resultEligible
paramTrace resultTrace}`. It is stored once in `native::lower::abiPlan`. Callers
and callees go through `AbiParams` / `AbiResult`; nothing decides rawness at an
individual call instruction, and the demand filter (below) is applied *inside*
the plan, never in lowering, so a position the demand rule keeps tagged is
tagged in the callee's prologue/return and at every call site. The
physical-kind vocabulary (`value`, `rawint`) is a seed for future scalar
representations; only `rawint` is implemented.

## Why safety and usefulness are separate

The eligibility theorem answers *"can this value safely be transported raw?"*
It reads three facts (type, closedness, `fitsSmall`) and is the only thing that
makes raw transport **sound**. It says nothing about whether raw transport is
**worth it**: an eligible parameter that only reaches `list_append`,
`mutable_array_set`, a `hash` call or a struct field is a tagged value in a raw
costume. The caller unboxes (or computes raw), the callee immediately re-boxes
for its tagged consumer, and the pair `rbox`/`runbox` buys nothing:

```
RawInt-eligible value  ->  raw at the function boundary  ->  rbox  ->  tagged consumers only
```

That is the preliminary milestone's measured symptom (static `rbox` 47 → 66,
`hashtable` +67 bytes), and it is just as real when only *some* consumers are
tagged: the conversion is paid for the tagged ones and the raw one could have
paid its own. The two questions are kept as two distinct planner
stages with distinct vocabulary:

* **eligible** = proven safe (Position, unchanged, still the whole safety rule);
* **selected** = eligible, raw-demanded **and** free of competing tagged uses
  (the demand pass, below).

Only selected positions are physical RawInt. The plan records both
(`paramEligible`/`resultEligible` beside `params`/`result`), so the audit can
always say *which* of the two a position failed. A position can be eligible but
not selected; it can never be selected without being eligible.

## Raw-demand suppression

The rule is deliberately small and purely boolean:

```
RawInt selected   iff   RawInt eligible
                  AND   raw representation is demanded somewhere in its use / transport closure
                  AND   no consumer in that closure needs a tagged Value
```

* If the entire closure ends in tagged consumers, the position stays tagged
  (`suppressed-no-raw-demand`).
* If it has a raw consumer **and** a tagged one anywhere in the closure (a
  *mixed use*), it stays tagged too (`suppressed-mixed-tagged-use`): **boxed is
  the default in mixed cases**. Not even one raw consumer in twenty tagged ones,
  or twenty raw consumers and one tagged one, retains RawInt; there is nothing
  to weigh.
* Only a position every consumer of which is raw is raw.

There are no scores, distances, weights, consumer counts, frequency or spill
estimates and no profitability model; the rule never asks *how many* uses are
raw or tagged, only whether any is tagged. `-raw-mixed-policy raw`
(env `BOTLISH_NATIVE_RAW_MIXED_POLICY=raw`, audit-only) restores the earlier
"any raw demand retains RawInt" policy for comparison (configuration C below).

Planner pipeline (the final plan stays the one authoritative result):

```
Range / closedness
  -> RawInt eligibility                 (Position: unchanged)
  -> raw-demand analysis                (Demand: boolean reachability + tagged-use closure)
  -> final ABI plan                     (native::lower::abiPlan)
  -> lowering
```

`native::rawabi::plan` runs eligibility, then `Demand` over the eligible
positions, and returns the plan; lowering never re-decides a position, so the
callee and every caller see one physical signature.

## Demand graph

`Demand` builds a small directed graph per program and computes one boolean per
eligible position.

Nodes: `P:ID:K` (parameter K of instance ID), `R:ID` (its successful result),
`B:ID:BINDING` (a local or parameter binding of that instance's region) and one
distinguished seed `RAW`. An edge `A -> B` reads "if B is raw-demanded then so is
A": A's value flows into B. **Absence of an edge is a tagged consumer.**

Raw-demand seeds (edges into `RAW`), using the repository's actual operation
categories:

| seed | what lowering does with it |
|---|---|
| operand of a raw-representable native op: `+ - * < <= > >=`, `==` on two Ints, the proven-safe `shift_left`/`shift_right` | `riadd risub rimul rilt rile rigt rige rieq rishl rishr` consume the operand raw. Same range conditions as `RawEligibleCall`/`RawEligibleShift` (both operands, and for arithmetic the result, `fitsSmall`), without the guard facts (which only ever reject), so the planner is never stricter than lowering |
| a slot of a self-tail loop whose entry Range `fitsSmall` | `native::lower::RawParams` already keeps that parameter a raw register for the whole function, whatever the ABI; a self tail call passes it raw |

Everything else a value can reach is **tagged**, positively recognized as such:
a tagged native op (`list`, `list_get`, `mutable_array_*`, `hash`, `mod`,
`bit_and`, an equality that is not Int-vs-Int, ...), a generic or dynamic call,
a call argument whose callee position is not eligible (an eligible one gets an
edge, which reaches `RAW` only if that position is itself demanded), struct
fields, `ok`/`error` payloads, loop bounds, list-loop elements, branch
conditions, discarded statement values, the program's own last value, a
captured or module-static slot (written tagged), and a call's callee.

Any construct the pass does not recognise adds an edge into `RAW`: the fallback
is always *keep the existing decision*.

## Transport propagation

Demand propagates backward along **transport-preserving** edges; each is an edge
in the graph:

* **alias / binding**: `y = x`: `B(x)` flows to `B(y)`, and `B(y)`'s own uses are
  whatever they are (`z = y; z + 1` demands `x`);
* **branches**: each reachable branch's last value flows to the `if`'s own sink;
  every branch raw retains RawInt; one tagged branch (a mixed use) or all-tagged branches do not. Branches decided
  by `hir::range::ConditionOutcome` or marked unreachable in the instance view
  are skipped (the same facts lowering uses; no new reachability analysis);
* **return** and a body's tail value: flow into `R(this instance)`;
* **exact call argument**: argument `i` flows into `P(callee, i)` iff that
  position is eligible, so demand continues through `P(callee, i)`'s own uses
  and onward transports (`f` result → `g` parameter → `h` parameter → raw op
  stays raw end to end);
* **exact call result**: `R(callee)` flows into the consumer of the call's
  value at each direct call site. Because RawInt requires a closed instance,
  every call site is known (every invocation is a direct exact call recorded in
  some instance's `calls` map), so a result's demand is determined from the
  *complete* caller set. An open instance is never eligible, so open demand is
  never inferred;
* **break value** flows to the loop's sink; **handle** forwards its sink to its
  call and handler bodies.

A position is demanded iff it **reaches `RAW`** (a reverse breadth-first search
from the seed; monotone, deterministic, `O(values + use edges + exact transport
edges)`, no path enumeration). It is *clean* iff nothing in its closure is
tagged: a second reverse breadth-first search marks as unclean every node with a
tagged consumer of its own, every node that flows into an unclean node, and
every node that flows into an eligible position that is not demanded (such a
position is tagged, so the flow into it is a tagged use). A position is selected
iff it is demanded and clean. Consequently *raw transport alone never creates
demand*: a cycle of pure transport edges (`f(x) -> g(x)`, `g(x) -> f(x)`, or a
self-forwarding non-tail recursion) is never reached from `RAW` and collapses to
tagged. Transport propagates existing demand; it cannot bootstrap its own.

Parameters and results are planned in their own directions. A parameter's
demand is its uses in the callee's body and onward transports; a result's
demand is the demand of every closed caller's use of the call value. A body
that computes its result raw does not by itself demand a raw result (it would
be boxed somewhere regardless); a raw-consuming callee does demand a raw
parameter (it removes the callee's own unboxing).

## Tagged-only suppression

A parameter or result whose whole closure is tagged-only stays tagged:

```
fn wrap(n): [n]                 # n: Int, small, closed -> eligible
list_length(wrap(3))            # n only reaches `list` (tagged): suppressed
```

`wrap<int>=val>val`, `paramReasons {suppressed-no-raw-demand}`, no `rawparams`
in the header, zero `rbox`/`runbox` at the call or in the callee.
`tests/raw-int-abi.test` (`demand-*`) pins the parameter, result, mixed,
alias, branch, dead-branch, return, transport-chain, tagged-chain,
self-forwarding-cycle and program-frontier shapes. A bounded result whose every
caller stores it is eligible and suppressed (`pick<int>=supp>supp`); a result
consumed by a raw comparison at a caller is selected (`six<str>=val>raw`).

The audit text (`native/explain-native.tcl`'s `raw-int-abi.txt`,
`native::rawabi::explain`) states, for each eligible position, the verdict and
its trace:

```
instance fib<int>
  params:
    n:
      entry [0, 22]    fitsSmall yes    RawInt eligible yes
      raw demand: parameter n -> raw rilt @e4
      ABI RawInt
  result:
    range [0, 17711]   fitsSmall yes    RawInt eligible yes
    raw demand: result of fib<int> (raw riadd @e9)
    ABI RawInt

instance ht_alloc<int>
  params:
    capacity:
      entry [8, 8]     fitsSmall yes    RawInt eligible yes
      raw demand: none (tagged consumers: tagged native mutable_array_allocate,
                        tagged argument 2 of ht_fill_empty<mutarray, int, int>)
      ABI tagged (suppressed-no-raw-demand)
```

`-raw-demand-opt 0` (env `BOTLISH_NATIVE_RAW_DEMAND_OPT=0`) is an audit-only
switch (not a language feature): it keeps eligibility and skips the demand
filter, reproducing the preliminary "eligible ⇒ raw" plan for three-way
comparison. `-raw-int-abi-opt 0` is still the tagged baseline.

## Mixed uses (boxed by default)

A position with a raw consumer *and* a tagged one is boxed
(`suppressed-mixed-tagged-use`), and the rule travels along transport edges,
because a tagged consumer anywhere in the closure is a tagged consumer of the
position:

```
fn both(n):                     # raw: x = n + 1      tagged: [n, x]
    x = n + 1
    [n, x]                      # both<int>=supp>val

fn h(z): x = z + 1; [z, x]      # z boxed (mixed)
fn g(y): h(y)                   # y flows into a boxed position: g's parameter is boxed too
```

Specifics (`demand-*` tests pin each):

* a returned parameter whose result position is tagged (ineligible, or boxed) is
  a tagged use, so `pick(n) = if n < 3: n else: 3` boxes `n`;
* a counted loop's bounds, a branch condition, collection and struct storage, a
  tagged native op and a call into a boxed or ineligible position are tagged
  uses;
* a **discarded raw call result** is still boxed at the call, so it is a tagged
  use of the callee's result; other discarded values (no code) are not;
* a tagged use **in the program function** is not a competing use: that function
  runs once and the conversion there is the frontier every raw region has (this
  is why `fib(22)` as the program's last value does not box `fib`'s result);
* a self-tail loop slot is still a raw register inside the function whatever the
  ABI (`RawParams`), so a boxed loop parameter costs one unboxing at entry, not
  one per iteration;
* a position boxed because of a mixed use does not make its raw consumers raw
  elsewhere: only the position's own representation changes.

The cost is in the transport: a raw operation on a boxed parameter unboxes it
once in the callee (which the preliminary plan paid at every tagged caller or
tagged use instead). Which side is cheaper depends on counts the rule
deliberately does not take.

## Parameter raw masks, raw result planning

Each position is independent: `raw/tagged`, `tagged/raw` and `raw/raw` all occur,
and so do mixed parameter lists (`f(a, b, s)` → `raw, tagged, tagged`: `a` only compared, `b` unbounded, `s` a String). One
plan exists per codegen instance — a mask over the declared parameters plus a
result flag — so there are no per-call-site variants. The plan is a function of
instance facts only; exact Range values never enter an instance key (two
instances `[0,22]` and `[0,1000]` would share one physical shape), and no new
semantic instance is ever created for an ABI difference. The physical identity
is the NIR function's header (`rawparams`, `rawresult`), one canonical function
per semantic instance, as for the other physical variants (companion, fields…).

Result eligibility is *not* derived from parameter eligibility
(`seven(v)` below has a tagged parameter and a raw result; `big(n)` a raw
parameter and a tagged result).

## Canonical tagged ABI

Unchanged for: open instances, generic entries, dynamic (`callvalue`) calls,
unproven or non-small Ranges, BigInt-capable paths, the program function,
companion / region / internal-capture / fields variants (they are separate NIR
functions with their own conventions), FFI/native boundaries, and every case the
budget or an analysis declines. `-raw-int-abi-opt 0` (or
`BOTLISH_NATIVE_RAW_INT_ABI_OPT=0`) restores it everywhere and reproduces the
parent's NIR for fib exactly (`raw-fib-disabled-is-the-tagged-abi`).

## Codegen-instance representation

A generic source function can have an open tagged instance and a closed raw
instance simultaneously (`raw-open-instance-stays-tagged`:
`open_one<generic>=val>val`, `open_one<int>=raw>raw`). An escaping function's
generic entry stays tagged; its closed exact direct callers use the separate
raw instance. Dynamic calls (`callvalue`) never see a raw function:
`nir.rs` rejects `fnvalue`/`closure` of a raw-ABI function, and the generic
`botlish_entry_N` wrapper of such a function converts defensively (untag
arguments, tag the result / status) even though it can never run.

## Planning order

`hir::specialize::analyze` (instances, the one closedness result) →
`hir::range::analyze` (entry Ranges, call results, bounded recursive result
summaries) → **`native::rawabi::plan`** (eligibility, then the raw-demand
analysis) → escape / string region / block escape / traversal / construction
analyses → NIR lowering → Cranelift. The planner runs after the Range results
are stable and strictly before any lowering. It is downstream of the proof: raw
selection removes boxing, never a check the proof relied on, so it cannot feed
back into Range. The demand pass is monotone: it only reads eligibility (never
speculative raw selection), seeds from actual raw operations and propagates
backward, so there is no circular planning (no position is raw merely because
another is raw).

## Exact-call interaction

A caller uses a raw position only when `fn targets` names the exact callee
instance and the call goes to that instance's **canonical** function (not a
companion/fields variant, not an inlined tiny leaf, not a virtualized
de-closure call). The callee's plan is authoritative. A call through an exact
callable parameter that resolves to a raw instance is an ordinary exact call
(`raw-exact-callable-target-is-raw`: `apply_dyn<block(e2), int>=val,raw>raw`,
zero `callvalue`). Constant arguments to raw parameters are emitted as a bare
`rawint` (no tagged constant built and unboxed).

## Recursive-call interaction

Self non-tail calls resolve to the same canonical function and signature, so the
plan is stable under recursion (fib; `raw-non-tail-recursion-with-allocation`).
Self tail calls stay `tail` back edges; a raw parameter is a `rawreg` local, so
`tail` already passes raw (`raw-tail-recursion-keeps-self-tail`). Mixed
signatures are preserved (`sum<int, int>=raw,val>val`). The plan is per
instance, so a parameter whose recursive calls pass an unbounded value falls
back to tagged for every call (`raw-recursive-mixed-bound`).

## Errors / completions

Only the *successful* payload becomes raw. A function that cannot fail
(`Function::may_error == false`, the settled closed-call summary) returns the
bare integer: that is the `i64 f(i64…)` shape. A function that can fail returns
`(value, status)`: status `1` on success, `0` with an error pending (the error
exit returns `(0, 0)`); the call site checks the status word, not the value. A
raw callee's call site follows the callee's own settled `may_error` even with
`-call-effects-opt 0` (which otherwise forces every site to check), because the
integer has no sentinel. `raw-error-capable-result` (`check<int>=raw>raw` with
`fail Negative`, handled and propagated), `raw-error-path-and-caller-handle`
and `raw-error-escapes-uncaught-as-an-error` pin success, failure and handler.
On x86-64/Linux a stack overflow is the guard page and never an error return;
the fallback depth-check path is unchanged and behaves as it did for any
`may_error=false` tagged function.

## GC / root semantics

A raw Int is a non-root scalar. Raw registers are declared in `rawregs`, and a
raw parameter is defined with `def_raw`, so `codegen::roots` (which filters
`raw_regs`) never treats it as a root and no stack-map entry is emitted for it;
nothing is special-cased per parameter. A raw value live across a safepoint is
just a scalar in a register or spill. Pinned by `raw-gc-raw-live-across-
allocation` (raw `n`, a String and a List live across allocations, GC stress),
`raw-gc-recursive-allocating-frames` (200 allocating recursive frames, GC
stress), the executable tests (GC stress, relocated), the focused GC-stress
suite below, and a 300-program GC-stress fuzz run. Corpus effect (`out/roots.txt`):
safepoints 595 → 595, root candidates 1,283 → 1,238, root slots 812 → 781.
The `rbox` root-store cleanup is deliberately not folded in.

## NIR representation

The smallest coherent extension of the existing raw-value discipline: two
optional header attributes, `rawparams="i j …"` (parameter positions whose
*physical* incoming argument is raw; each must also be in `rawregs`, and the
prologue does no unboxing for it) and `rawresult=1`. Raw versus tagged values
stay explicit through `rawregs`. Validation (`nir.rs`): call/callenv argument
`i` is raw iff the callee's parameter `i` is, the destination is raw iff the
callee's result is, `ret` is raw iff the function's result is, `fnvalue`/
`closure` of a raw-ABI function is rejected, the program function and
companions cannot be raw. No HIR change, no semantic RawInt type, no new raw
arithmetic opcodes: existing `riadd`/`risub`/`rimul`/raw compares consume the
values directly.

Lowering support: raw `if` joins in the tail position or `return` of a raw-
result function (`rawjoin` demand; sound because the value flows into the
proven-small result Range) and a statement-position local alias `y = x` of a raw
register stays raw (`raw-alias-stays-raw`, `raw-branch-merge-stays-raw`,
`raw-return-statement-is-raw`).

## Cranelift signature / lowering

Parameters are `i64` either way, so the parameter signature is unchanged; the
only signature change is a raw-result function that may fail, which returns two
`i64` (value, status). `Symbols::status_result` tells call sites which callee
convention to read. JIT, object emission and standalone executables share this
code path (`raw-executable-fib`, `raw-executable-mixed`).

## Boundary conversions, continuous raw regions, mixed frontiers

Conversions happen exactly at the frontier and are cached (`TaggedOf`/`RawOf`).
`f → g → h` all raw: one continuous raw region, zero `rbox`/`runbox` in any of
them (`raw-chain-one-continuous-region`). Mixed `raw bump → tagged-only seven →
raw bump`: exactly one `rbox` (before the tagged position) and none around the
raw ones (`raw-mixed-frontier-converts-exactly-at-the-boundary`). A branch join
of a tagged-only Int stays tagged (`raw-branch-join-of-a-tagged-only-int-stays-
tagged`). A proven-constant result is replaced by the constant, the call itself
still emitted for effects.

## fib before/after NIR

Before (`audit/raw-int-abi/out/fib/abi0.nir`) as above. After
(`abi1.nir`):

```
func 0 "<program>" ...
    %0 = rawint 22
    %1 = call 1 %0
    %2 = op rbox %1                 ; the single frontier conversion
    ret %2
func 1 "fib" params=1 ... rawregs="0 2 4 6 7 8 10 11 12 13" rawparams="0" rawresult=1
    %3 = op rilt %0 %2
    br %3 L0 L1
  label L0
    %4 = move %0                    ; raw join register
    jump L2
  label L1
    %7 = op risub %0 %6
    %8 = call 1 %7                  ; raw call, raw result
    %11 = op risub %0 %10
    %12 = call 1 %11
    %13 = op riadd %8 %12
    %4 = move %13
    jump L2
  label L2
    ret %4
```

Recursive-hot-path `rbox`: **0**; `runbox`: **0**. Outer program boundary: one
`rawint` argument, one `rbox` of the final result.

## fib before/after machine code

(`audit/raw-int-abi/out/fib/abi{0,1}.asm`, `asmcensus.txt`.) Raw compare,
subtraction, call and addition now read as plain machine instructions:

```
before (tagged ABI)                           after (RawInt ABI)
sar  rax,1            ; untag n                 cmp  rsi,2          ; n is raw
cmp  rax,2                                       jl   leaf
lea/shl/or            ; retag n-1               mov  rsi,r12 ; sub rsi,1   ; n-1 raw
call fib
sar  rax,1            ; untag result            call fib            ; result in rax
lea/shl/or            ; retag n-2               mov  r15,rax ; sub rsi,2
call fib
sar  rax,1                                      call fib
add  ...                                        add  rax,rcx        ; raw add
shl rax,1 ; or rax,1  ; retag result            ret                 ; raw result
```

Function bytes: `fib<int>` 131 → 114 (object text), 148 → 141 (`codeSize`, with
padding); instructions 38 → 32; tag/untag shifts 9 → 0; stack stores 2 → 3 (one
more callee-saved spill); calls unchanged (2); safepoints/root candidates/slots
0 before and after (already zero after the previous milestone). The dead generic
entry wrapper grows 17 → 27 bytes (it now converts), see *Known limitations*.

## fib dynamic instructions

callgrind steady state, the same methodology (`profile-nir.sh`, 21 runs, run 0
excluded; `audit/raw-int-abi/out/fib/profile-abi{0,1}/`):

| | before | after |
|---|---:|---:|
| Ir/run | **1,547,454** | **1,404,178** (−9.3 %) |
| instructions per internal call (28,656 calls) | 37 | 30 |
| instructions per leaf call (28,657 calls) | 17 | 19 |

(`28,656·30 + 28,657·19 = 1,404,163` plus 15 outside `fib`; `28,656·37 +
28,657·17 = 1,547,441` before.)

Classes, per run: retag 171,936 → 2, untag 114,625 → 0 (**all 286,561 boundary
conversion Ir removed**); prologue 286,567 → 343,880 (+57,313), epilogue
343,881 → 401,194 (+57,313), `mov reg-reg` 343,875 → 372,532 (+28,657);
arithmetic 85,968, compare 57,313, `jcc` 57,313, calls 57,313, `jmp` 28,656
unchanged. The conversions are gone but the register allocator now keeps three
callee-saved registers (`vm`, `n`, the first result across the second call)
instead of two, which costs one push/pop pair on every call, including the leaf
path (17 → 19). Net −143,276 Ir. The raw ABI recovers the whole conversion
class; half of it is paid back by frame traffic.

## Residual machine-code opportunities (not optimised here)

Largest remaining instruction classes in `fib` (per run, of 1,404,178):

1. **epilogue** 401,194 (28.6 %) and **prologue** 343,880 (24.5 %) — together
   53 %: `push rbp; mov rbp,rsp; sub rsp,0x20`, three callee-saved spills and
   reloads, `add rsp; mov rsp,rbp; pop rbp; ret`. The leaf path pays the full
   frame for `n < 2` (shrink-wrapping / a leaf fast path would remove it).
2. **`mov reg-reg`** 372,532 (26.5 %) — argument shuffling around the two
   calls and the `vm` pointer carried through every call in `rdi`.
3. arithmetic 85,968, compare/branch 114,626, calls 57,313.

These are the input to the later bottom-up machine-code audit: frame setup
(shrink-wrapping, frame-pointer elision), callee-saved pressure, and the `vm`
argument. No frame optimisation was attempted.

## General non-recursive cases

`tests/raw-int-abi.test`: `inc_bounded(n) = n + 1` under a closed caller →
`raw>raw` (leaf inlining disabled to keep the boundary; with inlining on the
helper has no function at all); raw param / tagged result (`big(n) = n *
3·10^18`); tagged param / raw result (`seven(v) = 7`, `v` unbounded); mixed
`f(a, b, s)` = `raw, tagged, tagged`; negative range; smallMin/smallMax
round-trip; alias, branch merge, early `return`, constant arguments,
comparisons consuming raw directly.

## Negative / out-of-small / open / dynamic controls

* `succ(2^62-1)`: `raw>val` (result `2^62`), value `4611686018427387904` agrees
  everywhere; `ident(2^62)`: `val>val`.
* `fib(100)`: parameter raw, result tagged (`unbounded-or-not-small`, the
  finite-but-large control).
* open generic instance: `not-int` / `open-instance`, tagged.
* a Block value called dynamically runs the tagged generic entry and agrees.
* exact callable specialization calls the raw instance directly; the generic
  instance of the same function stays tagged.

## ABI census (preliminary: eligibility only)

`audit/raw-int-abi/out/census.txt` (17 canonical programs: `bench/*.bot`,
`examples/stdlib/*.bot`): **228 instances examined; 56 raw parameter positions;
23 raw results; 4 instances with both; 68 instances with any raw ABI (22
recursive, 46 non-recursive); 160 tagged-only.** Only a minority benefits;
`source-checks`, `test-selection`, `string_replace` gain nothing (every
position is `not-int` or unproven). Rejection tags observed: `not-int`,
`open-instance`, `unbounded-or-not-small`, `unknown-range` (`dynamic-entry`
is the program; `disabled` is `-raw-int-abi-opt 0`; `unsupported-completion`
and `variant-budget` do not occur: errors are supported and there is no
per-call variant). The functions that gain raw positions are listed per program
in `census.txt` (`-detail`); notable ones: `fib<int>` (both), `loop-count`'s
`work` (both) and `drive` (param), `byte::nibble` (both), the `ascii::is_*`
predicates (param), `ht_*_state` constants and `ht_capacity` (result), the
`matmul` `dot`/`product_row`/`product_rows` (params).

Call edges (corpus, emitted NIR): off — tagged→tagged 309; on — raw→raw 24,
tagged→raw 48 (frontier conversions in the caller), raw→tagged 18,
tagged→tagged 219.

## Conversion census (preliminary: eligibility only)

Total NIR `rbox`/`runbox`: **47/47 → 66/48**. Classified call-boundary
conversions (an `rbox` feeding a call argument or `ret`; a `runbox` of a call
result or of a parameter): rbox 20 → 19, runbox 18 → 5. fib: 3/3 → 1/0.
`loop-count` 4/1 → 2/0, `matmul` 5/5 → 6/5 with call-boundary runbox 3 → 0.
The static total went up in programs where an Int is raw only to be consumed by
tagged operations (hashtable `ht_probe_*`/`ht_grow_or_clean`/`ht_alloc`,
csv_records) — see limitations.

## Code-size impact (preliminary: eligibility only)

`out/codesize.txt`: whole-corpus machine code **101,963 → 101,662 bytes
(−301, −0.3 %)**; the functions that gain a raw signature −62 bytes (callers
shrink more than callees). fib 181 → 181 whole (`fib` 148 → 141, the program
function +7 for the `rawint`/`rbox`); loop-count −6; sum-refined −9; matmul
−223 (−4.7 %); refined-checks −21; csv_records −41; **hashtable +67 (+0.5 %)**,
csv_geometric +19. No pathological growth, but the "proven ⇒ raw, no
profitability test" policy is not uniformly a win in size.

## Three-way conversion census

`audit/raw-int-abi/tools/demand.tcl` (`out/demand.txt`, `-detail` adds every
position's trace) lowers each canonical program in four configurations: **A**
tagged ABI (`-raw-int-abi-opt 0`, the pre-RawInt baseline), **B** RawInt
eligibility only (`-raw-demand-opt 0`, the preliminary result), **C** demand
suppression with mixed uses kept raw (`-raw-mixed-policy raw`, the earlier
cleanup policy, audit-only) and **D** demand suppression with mixed uses boxed
(production). The comparison that matters is A / B / D; C shows what the
boxed-mixed default costs and recovers. Static NIR counts over the 17 programs,
233 functions:

| | rbox | runbox | machine bytes |
|---|---:|---:|---:|
| A tagged baseline | 47 | 47 | 101,963 |
| B eligibility only | 66 | 48 | 101,662 |
| C demand, mixed uses raw | 60 | 41 | 101,552 |
| **D demand, mixed uses boxed** | **44** | **42** | **101,879** |

Per program:

| program | rbox A / B / C / D | runbox A / B / C / D | machine bytes A / B / C / D | eligible → selected (D): parameters; results |
|---|---|---|---|---|
| fib | 3 / 1 / 1 / 1 | 3 / 0 / 0 / 0 | 181 / 181 / 181 / 181 | 1→1; 1→1 |
| lex-strategy | 4 / 5 / 5 / 4 | 4 / 3 / 3 / 4 | 5,119 / 5,079 / 5,079 / 5,119 | 3→0; 0→0 |
| loop-count | 4 / 2 / 3 / 3 | 1 / 0 / 0 / 0 | 287 / 281 / 274 / 274 | 2→2; 1→0 |
| refined-checks | 7 / 10 / 8 / 7 | 11 / 10 / 9 / 9 | 9,089 / 9,068 / 9,046 / 9,080 | 10→6; 6→0 |
| source-checks | 1 / 1 / 1 / 1 | 3 / 3 / 3 / 3 | 4,249 / 4,249 / 4,249 / 4,249 | 0→0; 0→0 |
| sum-refined | 1 / 1 / 1 / 1 | 0 / 0 / 0 / 0 | 286 / 277 / 277 / 277 | 1→1; 0→0 |
| test-selection | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 6,421 / 6,421 / 6,421 / 6,421 | 0→0; 0→0 |
| uri-steady | 5 / 8 / 6 / 5 | 7 / 6 / 5 / 5 | 5,462 / 5,459 / 5,437 / 5,471 | 9→5; 4→0 |
| ai_text_clean | 1 / 1 / 1 / 1 | 1 / 1 / 1 / 1 | 3,081 / 3,078 / 3,078 / 3,081 | 2→0; 0→0 |
| csv | 0 / 1 / 1 / 0 | 2 / 1 / 1 / 2 | 5,723 / 5,719 / 5,719 / 5,723 | 1→0; 0→0 |
| csv_chunked | 2 / 2 / 2 / 2 | 4 / 4 / 4 / 4 | 10,168 / 10,142 / 10,142 / 10,168 | 3→0; 1→0 |
| csv_geometric | 0 / 1 / 0 / 0 | 1 / 3 / 1 / 1 | 7,578 / 7,597 / 7,578 / 7,578 | 1→0; 0→0 |
| csv_records | 8 / 14 / 13 / 8 | 3 / 9 / 6 / 4 | 23,245 / 23,204 / 23,177 / 23,234 | 11→2; 5→0 |
| hashtable | 4 / 11 / 10 / 4 | 0 / 1 / 1 / 0 | 12,732 / 12,799 / 12,786 / 12,732 | 3→1; 5→0 |
| matmul | 5 / 6 / 6 / 5 | 5 / 5 / 5 / 7 | 4,734 / 4,511 / 4,511 / 4,683 | 8→1; 0→0 |
| string_replace | 0 / 0 / 0 / 0 | 1 / 1 / 1 / 1 | 2,618 / 2,618 / 2,618 / 2,618 | 0→0; 0→0 |
| string_reverse | 2 / 2 / 2 / 2 | 1 / 1 / 1 / 1 | 990 / 979 / 979 / 990 | 1→0; 0→0 |

D is larger than the tagged baseline A in one program only, `uri-steady` (+9
bytes). Against the eligibility-only plan B, D is larger in the programs whose
raw parameters or results had a competing tagged use, which the boxed-mixed
default gives back: `matmul` +172 (still −51 vs A), `lex-strategy` +40 (= A),
`csv_records` +30, `csv_chunked` +26, `uri-steady` +12, `refined-checks` +12
(−9 vs A), `string_reverse` +11, `csv` +4, `ai_text_clean` +3. The `rbox` total
is now *below* the tagged baseline (44 < 47).

**Classification of every remaining `rbox`** (the tool follows each box back to
where its raw value came from, and whether anything else wanted that value
raw):

| class | meaning | A | B | C | D |
|---|---|---:|---:|---:|---:|
| frontier | raw *computation* (arithmetic, constant, join) boxed for a tagged consumer: the inherent tagged frontier of raw arithmetic | 25 | 21 | 22 | 22 |
| mixed | raw parameter / raw call result with a genuine raw consumer in the same function as the tagged one | 0 | 22 | 22 | **1** |
| mixed-callers | raw call result with no raw consumer at *this* call site, raw because another caller wants it raw | 0 | 16 | 12 | **0** |
| program boundary | the program's own final boxed result | 0 | 1 | 1 | 1 |
| other (raw registers that are not ABI positions, e.g. self-tail loop registers; unclassified) | | 22 | 3 | 3 | 20 |
| **raw selected, no raw consumer** | a raw parameter whose every use is tagged: a bug of the demand rule | 0 | **3** | 0 | **0** |

The boxed-mixed default removes the `mixed-callers` class entirely and all but
one `mixed` box (a self-tail loop parameter that is raw inside the function
whatever the ABI); what is left is the inherent frontier, the program boundary
and the loop-register boxes the tagged baseline already had.

## Hashtable regression recovery

Every eligible hashtable position and its verdict (`out/demand.txt`):

| position | closure | verdict |
|---|---|---|
| `ht_min_capacity`, `ht_empty_state`, `ht_occupied_state`, `ht_tombstone_state` results | `mutable_array_set` / `==` against an untyped `mutable_array_get` / `ht_alloc` / `ht_capacity_for`'s unbounded argument: tagged only | **suppressed**, no raw demand (4) |
| `ht_alloc.capacity` | `mutable_array_allocate`, `ht_fill_empty`'s unbounded argument: tagged only | **suppressed**, no raw demand |
| `ht_capacity` result | raw-demanded once (`oldCapacity = ht_capacity(table)` → `ht_rehash_scan`'s raw loop slot) but used tagged by `ht_probe_start`, `ht_probe_next`, `ht_should_grow` (`* 2` overflows the small range) and others | **boxed**, mixed use |
| `ht_rehash_scan.i` | raw `i >= oldCapacity`, `i + 1` and the self-tail slot, but also `mutable_array_get(oldControls, i)` | **boxed**, mixed use (still a raw register inside the function: `RawParams`) |
| `ht_rehash_scan.oldCapacity` | `i >= oldCapacity` and the self-tail slot only | raw |

Machine code, whole program: **A 12,732 → B 12,799 (+67) → C 12,786 (+54) → D
12,732 (+0)**; `rbox` 4 → 11 → 10 → 4, `runbox` 0 → 1 → 1 → 0. Per function the
D code is the tagged baseline's: no function differs in size from A. The
earlier cleanup (C) removed only the five tagged-only positions (13 of the 67
bytes); the residue was `ht_capacity`'s result, raw-demanded by one caller and
tagged by six, which is a mixed use. Boxing mixed uses removes it, so the
regression is **recovered in full**, with no hashtable-specific rule.

## CSV conversion recovery

The CSV programs (`csv`, `csv_chunked`, `csv_geometric`, `csv_records`) were
re-audited position by position. The tagged-only and mixed Ints are the same
`ht_*`/`geo_*`/`scan_*` helpers they share with the hashtable, plus their own
loop indices:

* `csv_geometric` **+19 → 0 bytes** (B 7,597, D 7,578 = A): `geo_new_capacity
  .capacity` only reaches the overflowing `capacity * 2`, a tagged multiply;
  `rbox` 1 → 0, `runbox` 3 → 1.
* `csv_records` A 23,245 → B 23,204 → C 23,177 → **D 23,234** (−11 vs A, +30 vs
  B): the four `ht_*_state`/`ht_min_capacity` results and `geo_new_capacity
  .capacity` are suppressed (no raw demand), eight parameters and `ht_capacity`'s
  result are mixed and boxed (`ht_capacity_for.expected` and its callers
  `ht_new_sized`/`row_new`/`row_table.header_count` feed a tagged `*`; the `i`
  loop indices feed `list_get`/`mutable_array_get`), leaving `ht_rehash_scan
  .oldCapacity` and `row_fill.field_count` raw. `rbox` 14 → 8 (= A), `runbox`
  9 → 4.
* `csv_chunked` 10,168 and `csv` 5,723 return to their tagged sizes: their
  `scan_records.index` is compared with `>=` but also passed to the tagged
  `scan_record`, `chunked_copy_chunks.index` feeds `list_get` (mixed), and
  `chunk_size`'s result is tagged-only.

## Updated ABI census

`out/census-demand.txt` (`census.tcl`, default = production D): **228 instances
examined; 19 raw parameter positions; 1 raw result; 1 instance with both; 19
instances with any raw ABI (8 recursive, 11 non-recursive); 209 tagged-only.**
Against the preliminary (B) 228 / 56 / 23 / 4 / 68 (22 / 46) and the
mixed-kept-raw policy (C) 53 / 6 / 1 / 51 (22 / 29):

| | B eligibility only | C mixed uses raw | D mixed uses boxed |
|---|---:|---:|---:|
| instances examined | 228 | 228 | 228 |
| raw parameter positions | 56 | 53 | **19** |
| raw result positions | 23 | 6 | **1** |
| instances with any raw position | 68 | 51 | **19** |
| instances with both | 4 | 1 | **1** |
| recursive / non-recursive with a raw position | 22 / 46 | 22 / 29 | 8 / 11 |

Call edges (emitted NIR): off — tagged→tagged 309; **on (D) — raw→raw 11,
tagged→raw 10, raw→tagged 3, tagged→tagged 285** (B: 24 / 48 / 18 / 219).
The surviving raw positions are the ones every consumer of which is raw:
`fib<int>` (parameter and result), the `ascii::is_*` predicates' `b`,
`check`/`dot`/`drive`/`work`/`refined_sum` loop parameters, `ht_rehash_scan
.oldCapacity`, `row_fill.field_count`.

**Suppression census** (eligible → selected → suppressed, parameters and
results separately; every suppressed position names its reason):

| | eligible | selected | suppressed: no raw demand | suppressed: mixed tagged use |
|---|---:|---:|---:|---:|
| parameters | 56 | 19 | 3 | 34 |
| results | 23 | 1 | 17 | 5 |
| **total positions** | **79** | **20** | **20** | **39** |

Reasons: `eligible-fits-small` (every row above is eligible), then either
`suppressed-no-raw-demand` (the 3 parameters `ht_alloc.capacity` and
`geo_new_capacity.capacity` ×2, and the 17 results `ht_min_capacity`,
`ht_empty_state`, `ht_occupied_state`, `ht_tombstone_state` ×2 programs each,
`byte::from_int`, `byte::nibble`, `high_nibble` ×2 each, `chunk_size`,
`scan_while`, `work`) or `suppressed-mixed-tagged-use` (34 parameters, 5
results: `high_nibble` ×2, `ht_capacity` ×2, `scan_while`). `out/demand.txt`
lists every position with its trace. Parameters are mostly *mixed* (a bounded
parameter is typically compared or stepped and also stored, indexed or passed
on), results mostly *tagged-only* (a bounded result is usually handed to a
store, a tagged comparison or an unbounded accumulator).

## Dynamic instructions per run (four-way)

Callgrind steady state (`profile-nir.sh`, the same audit binary, 4 runs of which
run 0 is excluded; `out/ir-demand.txt`), Ir per run of the emitted NIR:

| program | A tagged | B eligibility only | C mixed uses raw | D mixed uses boxed | D vs A | D vs B |
|---|---:|---:|---:|---:|---:|---:|
| fib | 1,547,454 | 1,404,178 | 1,404,178 | 1,404,178 | -9.26 % | +0.00 % |
| loop-count | 13,039 | 12,037 | 12,037 | 12,037 | -7.68 % | +0.00 % |
| sum-refined | 12,437 | 12,435 | 12,435 | 12,435 | -0.02 % | +0.00 % |
| lex-strategy | 312,704 | 312,946 | 311,644 | 314,264 | +0.50 % | +0.42 % |
| refined-checks | 6,777,321 | 6,776,760 | 6,776,694 | 6,776,661 | -0.01 % | -0.00 % |
| uri-steady | 42,746,691 | 42,681,034 | 42,695,633 | 42,727,997 | -0.04 % | +0.11 % |
| matmul | 9,246 | 9,226 | 9,226 | 9,240 | -0.06 % | +0.15 % |
| hashtable | 11,727 | 11,790 | 11,785 | 11,727 | +0.00 % | -0.53 % |
| csv_records | 99,461 | 99,541 | 99,203 | 99,694 | +0.23 % | +0.15 % |
| csv_geometric | 19,637 | 19,652 | 19,637 | 19,637 | +0.00 % | -0.08 % |
| csv_chunked | 19,516 | 19,504 | 19,504 | 19,516 | +0.00 % | +0.06 % |

`fib` is exactly the preliminary figure (identical NIR). `hashtable` and
`csv_geometric` are at the tagged baseline (their D NIR is the tagged code), `fib`
−9.3 %, `loop-count` −7.7 %. `lex-strategy` allocates, so its Ir moves by about
±0.5 % between identical runs (its A figure was 311,115 in an earlier sweep,
312,704 now): its +0.5 % is noise-level. The one measurable cost of the
boxed-mixed default is `csv_records`, +0.23 % over the tagged baseline (+0.15 %
over B): a mixed `ht_capacity_for.expected` chain is unboxed once per call
instead of being raw throughout. No workload slows down materially.

## Updated corpus code-size result

Whole canonical corpus (17 programs, 233 functions in every configuration):

| | machine code bytes | GC root candidates | root slots | safepoints |
|---|---:|---:|---:|---:|
| A tagged baseline | 101,963 | 1,283 | 812 | 595 |
| B eligibility only | 101,662 (−301) | 1,238 | 781 | 595 |
| C demand, mixed uses raw | 101,552 (−411) | 1,244 | 782 | 595 |
| **D demand, mixed uses boxed** | **101,879 (−84)** | 1,276 | 807 | 595 |

D is **84 bytes smaller than the tagged baseline** but 223 bytes larger than the
eligibility-only plan and 327 larger than C: boxing mixed uses removes every
regression (hashtable, `csv_geometric`, `csv_chunked`, `csv`, ... back to the
tagged size; no program larger than A except `uri-steady`, +9) and with them
most of the preliminary gains in programs whose raw parameters also had tagged
uses (`matmul` −223 → −51, `lex-strategy` −40 → 0, `uri-steady` −3 → +9,
`refined-checks` −21 → −9, `csv_records` −41 → −11). That is the trade of the
boxed-mixed default; the audit-only `-raw-mixed-policy raw` recovers the
earlier numbers (C). GC root candidates rise by 38 over B (positions that went
back to tagged are legitimately rootable again), still 7 below A; safepoints
are unchanged. Functions with no root slot: 46 → 48 → 47 → 46 of 233
(`out/roots-demand.txt`).

## Updated fib result

`fib<int>` stays `i64 fib(i64 n)`: raw parameter, raw result, **0 `rbox`/0
`runbox` in the function**, the recursive call arguments `risub` results passed
raw, results `riadd`ed raw and returned raw. Its demand trace
(`raw demand: parameter n -> raw rilt @e4`, `result of fib<int> (raw riadd
@e9)`) names the genuine seeds, which is why the recursive parameter/result cycle
survives the suppression. The emitted NIR is **byte-identical** to the
preliminary RawInt NIR (`out/fib/demand.nir` vs `out/fib/abi1.nir`), so the
machine code is the same: `fib<int>` 141 bytes (`codeSize`), whole program 181.

Callgrind, the same methodology and the same audit binary (`profile-nir.sh`, 21
runs, run 0 excluded; `out/fib/profile-demand/`): **1,404,178 Ir/run**, exactly
the preliminary figure (28,656 internal calls at 30 instructions, 28,657 leaf
calls at 19). No change was expected and none occurred.

## Compile-time impact

`audit/raw-int-abi/tools/compiletime.tcl` (median of 7, milliseconds, whole
compile = `native::codeSize`; `out/compiletime.txt`). The planner itself is
negligible: 0.03 ms for `fib`, `loop-count`, `sum-refined`; 0.27 ms for
`refined-checks`; 0.60 ms for `csv_records` (0.1 % of its 760 ms compile).

| program | abi plan | lower (ABI off → on) | cranelift (off → on) | whole compile (off → on) |
|---|---:|---:|---:|---:|
| fib | 0.03 | 3 → 2 | 5 → 4 | 26 → 24 |
| loop-count | 0.03 | 5 → 3 | 5 → 4 | 16 → 14 |
| sum-refined | 0.04 | 4 → 3 | 4 → 4 | 13 → 12 |
| refined-checks | 0.27 | 74 → 64 | 20 → 16 | 396 → 371 |
| csv_records | 0.60 | 394 → 370 | 20 → 4 | 768 → 760 |

(The differences are within run-to-run noise; no compile-time cost is
measurable. `prepare`/`specialize`/`range` are the same analyses either way.)

**Raw-demand pass** (`compiletime.tcl` now has a `demand` column: the plan with
demand minus the eligibility-only plan; `out/compiletime-demand.txt`; median of
7, ms, whole compile = `native::codeSize`):

| program | abi plan (eligibility) | demand pass | lower | whole compile | demand / whole |
|---|---:|---:|---:|---:|---:|
| fib | 0.02 | 0.40 | 3 | 24 | 1.7 % |
| loop-count | 0.03 | 0.38 | 4 | 13 | 2.9 % |
| sum-refined | 0.03 | 0.26 | 3 | 12 | 2.2 % |
| refined-checks | 0.31 | 4.52 | 61 | 368 | 1.2 % |
| uri-steady | 0.19 | 3.13 | 41 | 117 | 2.7 % |
| matmul | 0.09 | 1.70 | 18 | 60 | 2.8 % |
| hashtable | 0.29 | 7.21 | 119 | 290 | 2.5 % |
| csv_records | 0.57 | **12.86** | 347 | 699 | **1.8 %** |

(The csv_records and hashtable rows are a quiet re-measure, median of 9; the
others median of 7. The pass now also computes the tagged-use closure, a second
reverse search: no measurable change from the earlier 13.7 ms.)

The worst canonical case is `csv_records`: 12.9 ms, 3.7 % of its lowering time
and 1.8 % of the whole compile. The pass itself is a boolean walk over the
relevant instances' expressions plus a reverse breadth-first search,
`O(values + use edges + exact transport edges)` (no path enumeration, no
exponential branch exploration); about a third of its time (4.0 of 10.8 ms in
`csv_records`) is building each relevant instance's `hir::specialize::view`
(30 of the 59 instances, the same view lowering builds), the rest is the walk
and the range queries. It is much larger than the eligibility planner alone (that is
a flat loop over instances) but small beside lowering and Cranelift.

## Controls

`out/controls.txt`: with the ABI on and off the struct/transport census text,
the allocation count and bytes of a run, the allocations by kind and the guard
count are **identical** for `test-selection` (struct storage), `refined-checks`
(String representation), `hashtable` and `csv_records`. The raw ABI changes
Int parameter/result transport only.

## GC stress

* The `native*.test` files (26 files, 779 tests) pass under
  `BOTLISH_NATIVE_GC_STRESS=1` (forced GC attempt at every allocation site).
* `raw-int-abi.test` contains its own stress cases (`raw-gc-raw-live-across-
  allocation`, `raw-gc-recursive-allocating-frames`, both executable tests run
  under stress), and `tools/fuzz.tcl` ran 300 random programs under stress, 0
  disagreements (`out/fuzz-gcstress.txt`).
* The remaining suite-wide stress run is left to the `gc-stress` job of
  `.github/workflows/tests.yml` on push (`AGENTS.md`); it was not run locally
  for the whole suite. `fib<int>` and the other raw functions that make no
  allocation have no safepoint at all, so stress has nothing to exercise in
  them; the stress value is in raw values live across *other* functions'
  safepoints, which the tests above cover.

## Standalone parity

`raw-executable-fib` and `raw-executable-mixed` (raw, tagged and error-capable
instances in one program) compile to an ELF, move it, delete the source, run it
with an empty `PATH`, and again under `BOTLISH_NATIVE_GC_STRESS=1`; the value
agrees with interp, compile, `cranelift-generic` and `cranelift`.

## Differential testing

* `tests/raw-int-abi.test`: every behavioural test runs interp, compile,
  cranelift-generic, cranelift, and native with the ABI on/off × leaf inlining
  on/off.
* `raw-fuzz-random-closed-helpers` (40 programs) and
  `raw-fuzz-random-self-recursion` (25) in the suite.
* `tools/fuzz.tcl`: **1,500 + 1,500 random programs and 300 under GC stress, 0
  disagreements** (`out/fuzz*.txt`); every program uses a raw ABI, about half
  have a raw result, ~2 % end in an error outcome (a runtime `mod` by zero).

## Full regression

Tcl 9.0.1, Linux x86-64, release native backend, all from a clean tree.

| run | before (parent) | after |
|---|---|---|
| `tests/all.tcl` interp backend | 3663 total, 3663 passed | **3709 total, 3709 passed, 0 failed** |
| `tests/all.tcl` compile backend | 3663 total, 3659 passed, 4 skipped | **3709 total, 3705 passed, 4 skipped, 0 failed** |
| `tests/native-coverage.tcl` (cranelift) | 3697: native 1418, independent 2188, passed-partial 41, unsupported 49, failed 1 | **3743: native 1453, independent 2199, passed-partial 41, unsupported 49, failed 1** |
| Rust release tests (`cargo test --release`) | 56 + 22 | **64 + 22 passed** (8 new raw-ABI validation/effects tests) |

* +46 tests are the new `raw-int-abi.test` (45) and
  `tiny-leaf-pressure-growth-under-raw-abi` (1).
* The one coverage "failed" test is `refined-5` (the error message names
  `length` instead of `emailish?` under the cranelift test backend). It fails
  identically on the parent tree (checked on a clean worktree of the parent
  commit): pre-existing, unrelated.
* `bench/bench.tcl -runs 1`: all backends agree on every program, exit 0
  (`fib.bot` Tcl interp 9951 ms, compile 72.6 ms, Cranelift 175 us).
* `bench/corpus.tcl -runs 1`: all backends agree on every algorithm/size
  (6 m 30 s run), exit 0.
* Native execution time, `botlish-native bench` on the emitted NIR, best of 3
  x 200 runs, ABI off → on (machine shared with a background job, so only
  `fib` is a clear signal): **fib 145.9 -> 136.3 us (-6.6 %)**; loop-count 896
  -> 902 ns, sum-refined 723 -> 723 ns, refined-checks 663 -> 659 us,
  uri-steady 4.63 -> 4.65 ms, matmul 833 -> 833 ns, csv_records 9.41 -> 9.38 us,
  hashtable 1076 -> 1094 ns (all within noise). Callgrind is the reliable
  instruction-level figure for `fib` (above).

## Existing tests that changed (and why)

* `native.test`: `native-call-1` regex; `native-repr-1,4,6,9,18,20,21,22` pin
  the *tagged-ABI* boundary conversions and now pass `-raw-int-abi-opt 0`
  (their subject — a conversion at a call boundary — no longer exists under the
  raw ABI; `raw-int-abi.test` pins the new behaviour at the same boundaries).
* `native-root-liveness.test`: `fib` 20 → 14 NIR registers, `loop-count` 16/15 →
  14/14 (fewer conversions); with demand suppression `loop-count`'s `work`
  (whose result only feeds an unbounded accumulator) is back to a tagged result:
  **15**/14 registers (`root-structural-2`).
* `native-tiny-leaf-pressure.test`: the "inlining never grows code" audit is
  the tagged-ABI property (`-raw-int-abi-opt 0`); a new test pins the
  production behaviour: no growth for the 1-op and chain leaves, under 10 % for
  the fold-resistant 8-op horner leaf (a raw call is cheaper than a tagged one,
  so the inline/call break-even moved; retuning is future work). Demand
  suppression made the non-inlined baseline cheaper again at some call-site
  counts (128 sites, direct only: inlined 4,483 → 4,476 bytes, not inlined
  4,183 → 4,049, i.e. +10.5 % instead of +7.2 %), so that bound is now 15 %.
* `raw-int-abi.test`: seven tests pinned "eligible ⇒ raw" on programs whose only
  consumers of the position are tagged (`raw-param-tagged-result`,
  `raw-mixed-parameters`, `raw-mixed-physical-signature-in-nir`,
  `raw-outside-small-result`, `raw-open-instance-stays-tagged`,
  `raw-exact-callable-target-is-raw`, `raw-error-capable-result`); each program
  gained a genuine raw consumer (a compare or an addition), keeping the property
  the test is about. `parityAbi` now also runs the eligibility-only plan.

## Known limitations

* **No general opportunity-cost model, and the boxed-mixed default is blunt.**
  The rules are categorical: raw only when *every* consumer in the closure is
  raw. They never count uses, so a parameter with nineteen raw operations and one
  tagged store is boxed, and the callee then unboxes it once for the raw
  operations; the preliminary plan would have kept it raw and boxed it once for
  the store. The boxed default exists because mixed use was the whole residue of
  the hashtable regression (and the cost is visible: the corpus saving shrinks
  from −411 bytes with mixed uses raw to −84, `matmul` −223 → −51, `uri-steady`
  +9 over the tagged baseline). A weighted policy (use counts, distance,
  frequency, spill or code size) is deliberately not added; revisit it only when
  self-hosting or stdlib growth gives real workloads that need it.
  `-raw-mixed-policy raw` (audit-only) reproduces the earlier policy.
* **A boxed position cascades through transport.** A parameter that flows into a
  boxed parameter, or a result whose consumer is boxed, is itself boxed, so one
  tagged use can un-raw a chain (`web::is_unreserved.b` → `ascii::is_alphanumeric.b`
  is the `uri-steady` case: the raw predicates keep their raw parameter, the
  mixed caller boxes its own and unboxes once at the call, +3 bytes).
* **The demand pass approximates lowering's raw consumers from HIR and Ranges.**
  It drops the guard facts (so it can only over-approximate raw demand), does
  not see tiny-leaf inlining (a call to a leaf whose parameter is *not*
  eligible is treated as a tagged argument, so a raw operation inside the
  inlined body does not retain the caller's parameter), and does not see
  later lowering-only facts (virtualization, scalar replacement). Where it is
  unsure it keeps the preliminary decision.
* **Self-tail loop slots always count as raw demand**, because
  `RawParams` already keeps them raw whatever the ABI; a pure-forwarding self-tail
  parameter therefore stays raw (there is no raw consumer, but the loop state
  is a raw register regardless). Pure forwarding *cycles* without that
  mechanism (non-tail recursion, mutual recursion if the language had forward
  references) collapse to tagged.
* Raw ABI is for the **canonical** function only. Companion, region,
  internal-capture and fields variants, `callmulti` field transport, closures'
  captured storage, struct/List/MutableArray storage, FFI/native calls and the
  program function stay tagged.
* Parameter type is read from the instance key (`int`); a closed *generic*
  instance whose parameters the closed-caller theorem merely narrows is not
  raw.
* Entry Range is the ordinary final entry Range, e.g. `fn f(n): if n == 0 …
  f(n - 1)` has entry `[-∞, 30]` (no decreasing guard) and its `n` stays tagged
  although the *external* entry is `{30}`. No Range analysis was added.
* The tagged generic-entry wrapper of a raw function is retained (dead,
  17 → 27 bytes for fib) — wrapper elimination was not attempted.
* RawInt currently means signed `i64`; target-specific machine-word lowering is
  open but not claimed.
* Leaf-path cost can rise (17 → 19 instructions for fib's leaf) when the
  allocator needs one more callee-saved register; no shrink-wrapping here
  (backend territory, recorded for the later machine-code audit).
* No RawInt32 ABI, no Range change, no root-store (`rbox` immediate) optimisation
  and no hashtable/CSV storage specialisation were added by the demand cleanup;
  the RawInt ABI is **frozen** pending substantially larger stdlib or
  self-hosting evidence.

## Readiness for short-string frontier heuristics

The shared concept is *semantic value → proven representable scalar form →
physical call/frontier representation*. Reusable as is: the plan keyed by
codegen instance and consulted by callee and callers alike; the physical-kind
vocabulary; the `rawparams`/`rawresult` header idea and `nir.rs`'s call-site
agreement validation; the raw alias / join / frontier-conversion machinery
(`RawOf`/`TaggedOf`, which would become per-representation converters); the
2-word `(value, status)` completion convention. Specific to Int: `fitsSmall`,
the `rbox`/`runbox` pair and raw arithmetic. A one-character-String → `u32`
Char frontier would add a second `PhysicalParamKind`, its proof (length-1
String fact) and its own conversion pair, not a new framework.

## Architecture questions

1. **Where is the plan computed?** `native::rawabi::plan`, called once from
   `native::lower::program` after `hir::specialize::analyze` and
   `hir::range::analyze`, stored in `native::lower::abiPlan`.
2. **Facts consumed?** `closed`, instance key/result types, final entry Ranges,
   successful-result Ranges, `fitsSmall` (+ whether block-escape is enabled);
   for the demand filter additionally each relevant instance's view
   (`reachable`, types, exact targets), `hir::range::ConditionOutcome`, operand
   Ranges and the self-tail call set. It invents no numeric fact.
3. **Does HIR change?** No.
4. **Does semantic Int typing change?** No.
5. **Is RawInt a source type?** No.
6. **What does RawInt physically mean?** Signed `i64` on the current native
   target.

## Eligibility questions

7. A parameter is RawInt-*eligible* when it is Int, the instance is closed and
   its final entry Range is `fitsSmall`; it is *selected* raw when, in addition,
   raw representation is demanded in its use / transport closure.
8. The result is eligible under the same three conditions on the
   successful-result Range, and selected under the same demand condition over
   its closed callers.
9. `InstanceClosed` is required so the Range covers every invocation and no
   dynamic/Block-value caller can pass a tagged Value to a raw entry.
10. `fitsSmall` rather than "finite": only inside the tagged small domain are
    the conversions non-allocating and lossless.
11. Can a negative Range use RawInt? **Yes.**
12. Can a finite Range reaching `2^62` use RawInt? **No.**

## ABI questions

13. Can parameter and result decisions differ? **Yes.**
14. Can only some Int parameters be raw? **Yes.**
15. Physical raw layouts per codegen instance: **one planned layout.**
16. Caller/callee agreement: one stored plan read by both, plus `nir.rs`
    validation of every call, `ret` and `tail` against the callee's physical
    signature (a mismatch is a compile error, not a fallback).
17. Open caller: the instance is open, so the canonical tagged ABI
    (`open-instance`).
18. `callvalue`: always the generic tagged entry; a raw function has no Block
    value (`fnvalue`/`closure` rejected).

## fib questions

19. Is `n` passed raw recursively? **Yes.** 20. Results raw? **Yes.**
21. `rbox` remaining in the recursive hot path: **0.** 22. `runbox`: **0.**
23. Outermost boundary: one `rawint` argument and one `rbox` of the result.
24. Ir/run: 1,547,454 → 1,404,178. 25. Internal-call instructions: 37 → 30.
26. Leaf-call instructions: 17 → 19. 27. Function bytes: 148 → 141
    (`codeSize`), 131 → 114 (object text).

## Representation questions

28. No RawInt32: on the current 64-bit scalar call ABI, `i32` and `i64` both
    occupy one general machine argument/result slot; narrower width therefore
    does not reduce transport width, while it would multiply ABI variants.
29. Range may still record that a value fits `i32`: yes, but it is not an ABI
    class here.
30. Local/backend lowering may exploit narrower arithmetic later: yes.

## GC questions

31. Is RawInt a GC root? **No.** 32. Can it live across a safepoint? **Yes, as a
    non-root scalar.** 33. Stack maps: raw registers are declared in `rawregs`
    and `def_raw` never stores them; `codegen::roots` excludes `raw_regs` from
    liveness-derived root sets. 34. Pinned by the GC-stress tests listed in *GC
    / root semantics* and *GC stress*.

## Corpus questions

35. Instances gaining raw parameters: 19 positions (56 eligible; 37 not
    selected), 19 instances have any raw position (68 eligible). 36. Raw
    results: 1 (23 eligible). 37. Both: 1 (4 eligible). 38. `rbox`/`runbox`: 47/47
    (tagged) → 66/48 (eligibility only) → **44/42** (demand-filtered, mixed uses
    boxed); call-boundary rbox/runbox 20/18 → 19/5 → 18/10. 39. Whole-corpus
    machine bytes: 101,963 → 101,662 → **101,879**. 40. Non-numeric workloads:
    struct storage, String representation, allocation counts and guards are
    identical (`controls.txt`, `controls-demand.txt`); only Int helper signatures
    inside `hashtable`/`csv_*`/`refined-checks`/`uri-steady` changed.

## Raw-demand questions

1. **What is the difference between RawInt eligibility and RawInt selection?**
   Eligibility is the safety theorem (Int, closed instance, final Range
   `fitsSmall`): the position *may* be raw. Selection additionally requires raw
   demand somewhere in the position's use / transport closure: the position
   *should* be raw. Selected implies eligible, never the reverse.
2. **What constitutes a raw-demand seed?** An operand of a raw-representable
   native operation (`+ - * < <= > >=`, `==` on two Ints, the proven-safe
   shifts) under lowering's own range conditions, and a slot of a self-tail loop
   whose entry Range `fitsSmall` (`RawParams`). Nothing else is a seed.
3. **Through which edges does raw demand propagate?** Backward through aliases
   (`y = x`), if branches (each reachable branch's last value), `return` and a
   body's tail value (into the instance's result), exact call arguments (into
   an eligible callee parameter), exact call results (into the call value's
   consumer, over the complete closed caller set), `break` values and `handle`
   bodies; dead branches (unreachable bit, range-decided condition) are skipped.
4. **Does raw ABI transport itself create demand?** **Not by itself.** It
   propagates existing demand but cannot bootstrap a demand-free cycle: demand
   is reachability to the seed `RAW`, and a cycle of pure transport edges never
   reaches it (`demand-forwarding-cycle-cannot-bootstrap-raw`,
   `demand-tagged-chain-is-all-tagged`).
5. **What happens if all consumers are tagged?** **RawInt is suppressed**: the
   position stays tagged (`suppressed-no-raw-demand`) for the callee and every
   caller.
6. **What happens with mixed consumers?** **RawInt is boxed**: a position with
   both raw and tagged consumers anywhere in its closure stays tagged
   (`suppressed-mixed-tagged-use`, `demand-mixed-use-is-boxed`,
   `demand-mixed-use-propagates-through-transport`). Only a closure whose every
   consumer is raw is raw. (`-raw-mixed-policy raw`, audit-only, keeps the
   earlier "any genuine raw demand retains RawInt".)
7. **Does `fib` remain fully raw?** **Yes**: raw parameter, raw result, 0
   `rbox`/0 `runbox`, byte-identical NIR, 1,404,178 Ir/run.
8. **Does the rule apply to results as well as parameters?** **Yes**: 22 of 23
   eligible results (17 tagged-only, 5 mixed) and 37 of 56 eligible parameters
   (3 tagged-only, 34 mixed) are not raw.

## Census questions

9. **`rbox` / `runbox`** pre-RawInt / pre-suppression / post-suppression:
   **47/47 → 66/48 → 44/42** (corpus, static NIR; 60/41 with mixed uses kept
   raw).
10. **Hashtable bytes** pre-RawInt / pre-suppression / post-suppression:
    **12,732 → 12,799 → 12,732** (`rbox` 4 → 11 → 4, `runbox` 0 → 1 → 0).
11. **CSV bytes/conversions:** `csv_geometric` 7,578 → 7,597 → **7,578**
    (`rbox`/`runbox` 0/1 → 1/3 → 0/1); `csv_records` 23,245 → 23,204 →
    **23,234** (8/3 → 14/9 → 8/4); `csv_chunked` 10,168 → 10,142 → 10,168;
    `csv` 5,723 → 5,719 → 5,723.
12. **Raw positions before/after suppression:** parameters 56 → **19**, results
    23 → **1**, instances with any raw position 68 → **19**, with both 4 → 1.
13. **How many eligible positions were suppressed?** 59 of 79 (75 %): 20 for
    want of any raw demand, 39 as mixed uses.
14. **Suppressed parameters vs results:** 37 parameters (3 + 34 mixed), 22
    results (17 + 5 mixed).
15. **Did whole-corpus bytes improve or regress?** Against the tagged baseline:
    **improved**, 101,963 → 101,879 (−84). Against the preliminary eligibility-only
    plan (101,662): 217 bytes larger, the gains of the mixed-use positions the
    default boxes. The regressions are gone (no program larger than the tagged
    baseline except `uri-steady`, +9).

## Performance questions

16. **`fib` Ir/run after suppression?** **1,404,178**, identical to the
    preliminary RawInt (byte-identical NIR; tagged baseline 1,547,454).
17. **Has its recursive NIR changed?** No: `diff out/fib/abi1.nir
    out/fib/demand.nir` is empty; raw `n`, raw result, 0 `rbox`/0 `runbox` in
    the recursion, one `rawint`/`rbox` frontier in the program function. No loss
    of RawInt transport.
18. **Does hashtable recover the preliminary code-size regression?** **Fully**:
    +67 → **+0** bytes (12,732, no function differs from the tagged build), and
    Ir 11,727 = tagged. The earlier policy recovered 13 of the 67 bytes; the
    residue was `ht_capacity`'s result, raw-demanded by one caller and tagged by
    six, which the boxed-mixed default boxes. CSV: `csv_geometric` +19 → 0,
    `csv_records` −11 bytes vs tagged.
19. **Does any workload materially slow down?** No. Against the tagged ABI the
    worst is `csv_records` (+0.23 % Ir) and `lex-strategy` (+0.5 %, noise-level);
    `fib` −9.3 %, `loop-count` −7.7 %. Against the preliminary plan no program
    gets slower by more than 0.42 % (`lex-strategy`, noise-level; `csv_records`
    +0.15 %).

## Future-facing question

41. See *Readiness for short-string frontier heuristics*.
