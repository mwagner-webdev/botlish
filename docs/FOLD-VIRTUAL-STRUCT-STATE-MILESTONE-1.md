# FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md

Loop-carried struct scalar replacement: a fold whose intermediate is an
immutable struct carries it as independent field registers around the
loop's back edge, built as an object only where the whole value is
observed. The completion report of the milestone FOLD-VIRTUAL-STRUCT-STATE-
CENSUS-1.md recommended first (its section 14, stage 1).

Evidence labels, as in the census: **Implementation fact** -- read from
the code; **Observation** -- an executed test or measurement (section 17
reproduces each); **Judgment** -- a reasoned design or policy decision.
The census's numbers came from a NIR-to-NIR experiment (its
`tools/nir-sra.tcl`) applied at commit `0030f8a7`; every number below
labeled *compiler* is the completed compiler's own NIR, measured at the
milestone's tip against the tree it started from, `b0ae98fe` (*base*),
319 commits after the census. The two are never mixed in one column.

## Contents

1. [Executive result](#1-executive-result)
2. [Architecture verification against the census](#2-architecture-verification-against-the-census)
3. [Fold-slot representation and eligibility](#3-fold-slot-representation-and-eligibility)
4. [Shape classification and fold-valued constructions](#4-shape-classification-and-fold-valued-constructions)
5. [Native lowering and parallel back-edge assignment](#5-native-lowering-and-parallel-back-edge-assignment)
6. [Conditional joins and identity completions](#6-conditional-joins-and-identity-completions)
7. [Lazy materialization and the no-loss rule](#7-lazy-materialization-and-the-no-loss-rule)
8. [Consumed mutable fields and field-wise shares](#8-consumed-mutable-fields-and-field-wise-shares)
9. [Function argument and result transport](#9-function-argument-and-result-transport)
10. [Control-flow, GC, coroutine and resource correctness](#10-control-flow-gc-coroutine-and-resource-correctness)
11. [Scanner performance](#11-scanner-performance)
12. [Mutable-field performance](#12-mutable-field-performance)
13. [Chunk workload, with M2's remaining cost isolated](#13-chunk-workload-with-m2s-remaining-cost-isolated)
14. [Width limits, representation budgets and measured compiler costs](#14-width-limits-representation-budgets-and-measured-compiler-costs)
15. [Differential, mutation and regression testing](#15-differential-mutation-and-regression-testing)
16. [Known limitations and recommended M2 boundary](#16-known-limitations-and-recommended-m2-boundary)
17. [Reproduction commands and verification evidence](#17-reproduction-commands-and-verification-evidence)

## 1. Executive result

**Eligible struct-valued fold intermediates are now carried as field
registers, in the existing struct scalar replacement, with no new HIR
node, core IR form, NIR instruction, runtime helper or heap object.**

* **The scanner meets its targets.** (*Observation*, compiler.) The
  six-field scanner builds no struct (161 before), runs in
  28,772 instructions per run against 25,588 for its tail
  recursion (112.4%; target at most 115%), down from 139,066,
  and its helper `number_at` returns its fold's two fields with `retmulti`
  (no struct at the call either). The census's experiment had 28,944
  against 25,524.
* **The representation is one more slot kind.** (*Implementation fact.*)
  hir/escape.tcl's fourth slot kind, the *fold slot*, is judged like a
  bound local whose binding runs once per iteration, plus two rules of its
  own (its *sources* stay virtual; *no loss*); a fold whose slot is
  virtual is a recognized construction, which gives fold-valued functions
  `retmulti`, a local bound to a fold its fields, an `if` branch ending in
  a fold its fields. native/lower.tcl carries the fields with a new
  accumulator mode (`vfold`) of the existing loop-result machinery and a
  parallel back-edge move written in one place.
* **What the census warned about is closed.** (*Observation.*) The back edge
  is a parallel move (a permuting completion is a test and a killed mutant);
  a whole-value use on a path that keeps the intermediate unchanged declines
  the slot (the genuine open-call variant of the census's
  `d-identity-materialize` builds 2 structs with and without fold slots,
  never one per iteration); a copying fold's whole-struct share is lowered
  field by field (Probe C's copying rows build no struct, with exactly the
  shares, detaches and detached elements of before).
* **Struct joins take an identity branch.** (*Implementation fact.*) An
  `if` branch that ends in a reference to a struct binding a slot carries
  (the intermediate itself, a candidate local) is a construction for a
  consumer that is a slot. The same option (`-struct-ref-joins`) lowers
  whole-struct shares field by field, which outside folds changes three
  of the 163 corpus programs, each building 2 structs fewer (section 6).
* **The chunk fold keeps its List copies, as planned.** (*Observation*,
  compiler.) At 16,384 tokens it builds no struct (16,384 before) and runs
  in 316.5 million instructions (base 335.9 million), against 32.9 million
  for its recursion: the List copying the census attributes to milestone 2
  is all that is left.
* **Width is decided by measurement.** (*Judgment.*) Fold slots are
  carried up to 64 fields (`foldWidth`), not the local ceiling of 16:
  field registers ran faster at every width measured up to 256, the code
  is smaller up to 8 fields and up to 15% larger beyond (smaller at every
  width when one field changes per iteration), and Cranelift's
  compile time is neutral to 16 fields, 12-23% higher at 32 and 28-47%
  at 64 where most fields change, and 1.6-2.6 times at 128-256 for a gain
  per iteration near 1.2x (section 14).
* **Off is the old lowering, byte for byte.** (*Observation.*)
  `-struct-fold 0 -struct-ref-joins 0` reproduces the base tree's NIR for
  every one of 163 corpus programs; with the default, no program
  builds more structs than before (105,061 -> 95,992 over those that run
  natively).
* **One bug was found after the first push and fixed.** (*Observation.*)
  A fold whose initial value and completion were exact calls returning a
  nested struct failed native lowering (NATIVE BUG) in the pushed commit
  `c5679581`; section 4 has the cause, `fvs-exact-call-nested-result` and
  a fuzzer template cover it.

* **Regression and CI.** (*Observation.*) The full local suite passes
  (292 Tcl test files on two backends, 121 golden suites on four); the
  four test workflows on the branch fail only the two tests main fails at
  `b0ae98fe` on every host (section 15).
* **What is not met, or not measured.** (*Observation.*) Every stated
  target is met. Beside them: the four-field narrow scanner's median is
  120.6% of its recursion (111.8% in generated code; the 115% target is
  the six-field scanner's); two neighbor fuzzers generate obsolete syntax
  and tested nothing (section 15); x86-64's GC-stress CI job runs only on
  main and did not run for the branch (the milestone's tests passed under
  GC stress locally, and arm64's GC-stress jobs ran in CI).

## 2. Architecture verification against the census

The census's premises were read again at `b0ae98fe` before anything was
written (*Implementation facts* unless marked):

| census premise (section) | at `b0ae98fe` |
|---|---|
| three slot kinds: bound locals, instance parameters, instance results (6) | holds: `RawLocalArities`, `RawParamArities`, `arity`; a fold's intermediate is a `param` binding of the iteration scope that none covers |
| a fold is no recognized construction; its completions are census `control` (3, 6) | holds: `Classify` returned "" for loop kinds; Probe D's files census `materialized(control)` (*Observation*, `probes-before`) |
| `If` joins need both branches recognized; a reference branch is not (6) | holds: `ClassifyIf` classified each branch's last expression with `Classify`, which knows no `ref` |
| one loop-carried register per fold, accumulator modes in `LoopResultStart` .. `LoopResultFinish`, `break` reads the `loops` entry (2, 7) | holds: modes `collect`, `discard`, `fold`, plan fold; M1 adds `vfold` beside them |
| the virtual local entry, `VirtualValue`, `MaterializeVirtual`, `retmulti`/`callmulti`, fields variants exist and are reusable (6) | holds; reused unchanged except where section 5 says |
| consumption decided before representation (9) | holds: hir/mutvec.tcl's elaboration runs first; M1 reads its shares, never decides one |
| `d-identity-materialize` is a whole use through an open call (7.4) | **does not hold**: its `f(s)` is an exact call at `b0ae98fe`, so fold slots carry it with no loss (2 structs become 0). A genuine open call (a function value chosen at run time) was added as the negative control the census meant: `fvs-no-loss-open-call` |
| `c-vec-continue` regresses if a whole-struct share is not lowered field-wise (9) | **partly**: without field-wise shares the slot is declined by `UseVerdict`'s rule that a share is no free use, so nothing regresses; field-wise shares then remove its structs (section 8) |
| NIR's validator does not check that a register is defined on every path (11) | holds: nir.rs's `validate_function` checks structure; M1 adds an independent check of its own output (section 10) |

What the 319 commits since the census changed in the files M1 touches
(*Observation*, `git diff 0030f8a7 b0ae98fe -- hir/escape.tcl
native/lower.tcl hir/transport.tcl`): hir/escape.tcl gained only depth-safe
guards (six walks); native/lower.tcl gained payload-bearing enum cases and
the application libraries' entry dispatch; hir/transport.tcl nothing. None
touches the fold lowering or the slot kinds. The rest of the tree moved
(runtime, front end), so the census's measurements are not reused as the
baseline: every *base* number below was measured again at `b0ae98fe`.

## 3. Fold-slot representation and eligibility

**A fold slot** (*Implementation fact*, hir/escape.tcl, "Fold slots") is
fold intermediate B of instance I when every value that can enter B is a
struct of one descriptor `{N {ID LAYOUT}}`:

* the incoming values are the fold's initial value and every normal
  completion of its body (`FoldIncoming`, `FoldCompletions`: the body's
  last expression through `if` joins, never a `continue` or `break`
  path), each read leaf by leaf (`ValueLeaves`);
* a leaf is a recognized construction (`Classify`: a struct literal, an
  `if` join, a recognized exact call, an inner fold that is itself
  carried), B itself (an identity completion), or a reference to a local
  or another fold intermediate whose static type is that struct
  (`RefShape`, `TypeShape`: a named struct by its declaration, an
  anonymous one by its field set);
* a parameter is never such a reference: a parameter is virtual only in
  its instance's `fields` variant, so its value has no proven field
  registers in every lowering of the instance (mutant
  `ref-shape-any-binding`);
* a List descriptor or a recognized result opened into a cut is no slot
  descriptor (`FoldShape`): a fold slot carries its descriptor's own
  fields.

`RawFoldArities` turns each such fold into a candidate when B is never
captured by a nested function and N is at most `foldWidth` (64; section
14). `Eligible` then judges the candidate exactly as a bound local whose
binding runs once per iteration (`UseVerdict` with the fold as the
binding's loop: a use that needs the object materializes it where the
existing local rules would), and adds:

* **sources.** A reference leaf names a binding (a candidate local `q`,
  an outer fold's intermediate). Entering the slot it is free only while
  that binding is itself virtual, so the slot stands only while every
  source does -- the alias rule generalized (Eligible's SOURCES; mutant
  `sources-unchecked`, test `fvs-source-falls`).
* **no loss.** Section 7.

A dropped candidate keeps its reason (`source`, `no-loss`, `width`,
`capture`, `shape`, the local rules' reasons), reported by
`native::foldSlots` and `hir::escape::explain`.

## 4. Shape classification and fold-valued constructions

**A fold is a recognized construction exactly when its slot is virtual.**
(*Implementation fact.*) `Classify` of a loop node returns `FoldShape`'s
kind, descriptor and targets; `Origins` gives `{fold I B}`. So every
existing consumer of a construction takes a fold's value as fields: a
local bound to a fold, a function returning one (its result descriptor,
hence `retmulti`), an `if` branch ending in one, an argument of an exact
call.

**Monotonicity.** (*Implementation fact.*) Whether a slot is virtual is
decided after eligibility, which itself reads the shapes the constructions
give -- a cycle. `analyze` runs in rounds: a fold whose slot fell is added
to STRUCTOPTS' `foldDeny` (keyed by instance and fold), where `FoldShape`
returns nothing, and the analysis runs again. Denying only removes
constructions, so slots only fall further; the rounds stop after at most
one more than the number of folds that fall, and the lowering's report
carries the count (`escapeRounds`). Over the 163 corpus programs
(*Observation*): 161 need one round and 2 need two (`d-observe` and this
milestone's golden suite, each with a shaped fold whose slot falls, so a
second round runs without its construction); their native lowerings have 131 fold-slot
candidates (counted per instance), 123 carried and 8 declined (`no-loss`
5, `capture` 2, `source` 1).

**Nesting plans.** (*Implementation fact.*) A fold slot never opens a
nested struct into a cut: `NestingPlan` unions every construction and
slot a value entering the slot comes from, and every slot its value goes
to, with an opaque marker (`{opq I E}`), so no cut is chosen for any of
them; an inner struct stays one carried field value. The pushed commit
`c5679581` unioned the fold classes before the instance-result members
existed, so `UnionOrigins` skipped an exact call's result, its callee's
result was opened into a cut, and the lowering found no uncut companion
(NATIVE BUG for `fold ... with intermediate s start(3): step(s, i)` with
nested `Outer {inner: Inner, n}`; *Observation*). The fold classes are now
unioned after the result members (`fvs-exact-call-nested-result`; mutant
`result-outside-slot-class` -- the "mismatched descriptor accepted" kind:
a slot accepting a value that arrives in another representation; the
fuzzer's `nested` template finds it unaided).

## 5. Native lowering and parallel back-edge assignment

(*Implementation facts*, native/lower.tcl.) A fold whose slot is virtual
uses the accumulator mode `vfold`, beside `collect`, `discard`, `fold` and
the plan fold, in the same procedures:

| point | what happens |
|---|---|
| initialization (`LoopResultStart`) | the initial value is lowered as N virtual fields (`VirtualValue`), tagged (`TaggedFields`) and moved into N fresh carried registers, after the loop's operands -- the fold's evaluation order |
| binding (`LoopResultBind`) | B is a virtual local whose fields are the carried registers: projections read them, a materializing use builds the object from them (`MaterializeVirtual`) |
| body (`LoopBody`) | the body's last expression is lowered as N fields (`SequenceVirtual`), so every completion -- a literal, a join, a call's `retmulti`, an inner carried fold, B itself -- yields N registers, never an object |
| normal completion (`LoopResultAdd`) | `FoldBackEdge`: the one parallel move of the completion's registers into the carried ones, at the completion's end and nowhere else |
| `continue` | jumps to the next iteration past the back-edge move: the carried registers keep the iteration's starting value |
| bare `break` | the result registers take the carried registers, not a candidate (mutant `break-not-current`) |
| exhaustion (`LoopResultFinish`) | the result registers are the carried ones |
| the fold's value | used as fields where a consumer takes fields; built once, after the loop, where it is used whole (`FoldObject`; mutant `exit-not-materialized`) |
| errors, returns | registers die with the frame; a `return` of B materializes it as any return of a virtual local does |

**The parallel move.** A completion like `P {a: s.b, b: s.a}` gives the
sources `[b_carried, a_carried]`: moving them one by one overwrites `a`
before `b` reads it. `FoldBackEdge` first copies every source that is a
carried register another move writes into a fresh register, then moves
every source into its carried register:

```tcl
foreach r $carried v $values {
    if {$v ne $r && $v in $carried} {
        set copy [NewReg fn]; Emit fn "$copy = move $v" $e; ...; set v $copy
    }
    lappend sources $v
}
foreach r $carried v $sources {
    if {$v ne $r} { Emit fn "$r = move $v" $e; ... }
}
```

A source equal to its own target is no move (an unchanged field costs
nothing). Copies are made only for carried sources other moves overwrite
(`fvs-swap-parallel-nir` pins the NIR of a swap; `fvs-rotate-three`, a
three-field rotation; `fvs-nested-permutations`, a permuting inner fold
inside a permuting outer one). The sequential mutant
(`back-edge-sequential`) is killed by five tests.

**Fields are tagged values.** The carried registers are managed-capable
(a field may hold a BigInt, a String, a List, a struct object): they are in
the stack maps like any tagged register (mutant `carried-untraced` declares
them raw and is killed by the GC-stress tests). C words and pending
objects never enter a slot: a foreign call's write-back value is no
struct descriptor a fold carries.

## 6. Conditional joins and identity completions

**`ClassifyIf` takes a reference branch for a slot.** (*Implementation
fact.*) With REFJOIN, a branch ending in a reference to a struct binding
whose `RefShape` holds -- the intermediate itself (an identity
completion), a candidate local, an outer intermediate -- counts as a
construction of that descriptor; its fields are the binding's registers
(`JoinRefs`; `Origins` gives `{src I B}` and an opaque marker). Only a
consumer that is itself a slot asks for it: such a branch is free only
while the binding it names stays virtual, which the consumer's sources
rule checks. Fold slots ask for it, and so do bound locals
(`q = if c: p else: P {...}`).

**Measured separately outside folds.** (*Observation*, the corpus,
section 15.) `-struct-ref-joins 0` turns off both things the option
governs outside folds: reference branches of joins consumed by locals, and
whole-struct shares lowered field by field (section 8). Over 163 programs,
3 change NIR because of it alone (`refoff` differs from `default`,
`foldoff` does not), 21 because of fold slots alone, 2 because of both
(the milestone's golden suite and `c-vec-continue`). The three are golden
suites -- `destructuring.bot`, `mutable-vector.bot`, `recursive-types.bot`
-- and in each the change is a whole-struct share of a struct local
holding vectors (a copy at a place's entry), now one `mvshare` per vector
field and no struct: each builds 2 structs fewer (1,421 -> 1,419, 5,453 ->
5,451, 51 -> 49). No corpus program changes because of a reference
branch outside a fold; `fvs-ref-join-local` and
`fvs-ref-join-materialized-source` test that case (mutant
`identity-branch-off`).

**Identity completions.** An identity leaf (`s`) moves nothing: its
sources are the carried registers themselves. A candidate local (`q = P
{...}` then `if c: q`) is a source: if `q` falls (built in an inner loop,
captured), the slot falls with it (`fvs-source-falls`; mutants
`identity-leaf-unchecked`, `sources-unchecked`).

## 7. Lazy materialization and the no-loss rule

**Materialization points** are the existing local rules' (*Implementation
fact*): a use that needs the object -- an argument of an open or
unspecialized call, `==`, a field of a List, a capture, a return beyond
the transport ceilings, a whole-struct value an exact consumer cannot take
as fields -- builds it from the current registers, once per dominating
scope (`MaterializeVirtual`). A fold slot adds no rule of its own here.

**The no-loss rule.** (*Implementation fact*, `FoldNoLoss`.) Today a
fold's object is built once by each constructing completion and passed on
for free by an identity completion or a `continue`. Carried as fields, an
iteration that needs the object and then keeps the intermediate unchanged
would build it every time. So a slot is declined when some materializing
use may run in an iteration that then keeps the intermediate -- by a walk
of the body's paths from each materializing reference with a dead state
for `return`, `fail` and the fold's own `break` (the iteration does not
continue) and a *keep* state for an identity completion or a `continue`
targeting the fold. One walk per slot and set of materializing references,
over the body only (no walk per field).

| control (*Observation*) | decision | Struct allocations, object lowering -> fold slots |
|---|---|---|
| `d-identity-materialize` (census Probe D: its call is exact) | carried | 2 -> 0: the call takes fields |
| a genuine open call on an identity path (`fvs-no-loss-open-call`) | declined, `no-loss` | 2 -> 2 (hundreds if carried: mutant `no-loss-off`) |
| an equality before a `continue` (`fvs-no-loss-continue`'s `run2`) | declined, `no-loss` | unchanged |
| a field read before a `continue`, rebuilt after (`fvs-no-loss-continue`'s `run`) | carried | -- |
| `return s` (a whole use) whose path ends, an identity completion on another (`fvs-no-loss-return`'s `early`) | carried: the return path is dead | -- |
| an equality whose iteration may complete with the identity (`fvs-no-loss-return`'s `late`) | declined, `no-loss` | unchanged |
| a stored field on constructing paths only (`fvs-no-loss-constructing-path`) | carried | -- |

Mutants `no-loss-off` (an open call: 2 structs become hundreds) and
`no-loss-keep-ignored` (an equality before an identity completion) are
killed by allocation counts. The fuzzer's independent model predicts each
generated program's decision from the statements it generated (a capture
declines; a materializing use followed in the iteration by a keeping path
declines; anything else is carried) and agrees with the compiler on every
program (section 15).

## 8. Consumed mutable fields and field-wise shares

**Ownership is decided before representation and is unchanged.**
(*Implementation fact.*) hir/mutvec.tcl's elaboration (consumed fold
intermediates, CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md) runs before the
escape analysis; a fold slot reads its result. A consumed intermediate's
vector field is a carried register holding the header, mutated in place;
a copying fold's entry copy is the elaboration's whole-struct share
`mutable_vector#share(B, "s2.1.h")` for `Acc {count: int, items:
MutableVector[int]}` -- descriptor `sN.(SLOT.D)*` listing the slots that
hold collections (`h` a header, `d` whatever the slot holds at run time, a
nested `s...` an inner struct; hir::mutvec::ShareDescriptor).

**Whole-struct shares are lowered field-wise.** (*Implementation fact*,
`ShareFields`.) A share of a carried binding is a construction
(`StructShareSource`; `Origins` gives `{src I B}`): its fields are the
binding's registers, each slot the descriptor lists replaced by an
`mvshare` of that register by the slot's own descriptor -- exactly the
copies runtime/mutvec.rs's `share_by` makes, and no struct. The parser of
the descriptor (`ShareParts`) is iterative. A share is never added or
dropped: mutant `share-fieldwise-skipped` (no header shared: a continuing
iteration keeps what it pushed) is killed by values; `share-declined` (the
copying fold's slot declined, one struct per iteration) by allocation
counts; and `consumed-shared` (hir::mutvec's copying elaboration
everywhere) by the share and detach counters.

Probe C (section 12) shows the property the census asked for: consumed
rows have no shares or detaches, copying rows have exactly base's, and no
row builds a struct.

## 9. Function argument and result transport

(*Implementation facts*; *Observations* name their tests.)

* **Results.** A function whose value is a carried fold has the fold's
  descriptor as its result (`arity`), so its companion returns the fields
  with `retmulti` and an exact caller reads them with `callmulti`: the
  scanner's `number_at` (`fvs-scanner-result-transport` pins `results=2`,
  `callmulti` and no `structnew`); the width inputs' `ret-W` while the
  transport model admits the return (8 fields do, 16 do not), beyond which
  the result is built once per call, after the loop.
* **Arguments.** An exact call taking the intermediate whole takes its
  fields in the callee's `fields` variant when the parameter is virtual
  (`fvs-exact-call`: no struct); a fold as an argument of an exact call is
  passed as fields (`fvs-fold-argument`).
* **Parameters as initial values.** A parameter entering a fold is no
  source (section 3), so a fold whose initial value is a struct parameter
  has no slot (`fvs-param-initial`: the object lowering, values agreeing
  on every configuration; mutant `ref-shape-any-binding` admits it and is
  killed).
* **Boundaries keep their own rules.** Whether the fold's value crosses an
  exact return or argument as fields is the transport model's decision
  (hir/transport.tcl: widths 16 and 8, and the pressure budgets over the
  boundary path), and a local binding of it takes at most `localWidth` (16)
  fields; a fold slot's own ceiling is 64 (section 14). A value wider than
  its boundary admits is built once there (`spill-32`'s `t`: 1 struct per
  call instead of 1,001).

## 10. Control-flow, GC, coroutine and resource correctness

**Control flow.** (*Observations*, tests/fold-virtual-struct-state.test,
every value compared over eight configurations: interp, compile,
cranelift-generic, cranelift, cranelift with fold slots off, with reference
joins off, with struct scalar replacement off, unfused coroutines.)
`continue` and bare `break` before and after candidates (`fvs-exits`,
`fvs-break-candidate`), an empty domain (`fvs-empty-fold`), a bare fold
(`fvs-bare-fold`), an early `return` of the intermediate
(`fvs-early-return`), a handled declared error (`fvs-errors`) and one that
escapes the fold (`fvs-error-escapes`), nested folds (`fvs-nested`,
`fvs-nested-closed`), permutations (section 5), observation of the whole
value inside and after the loop (`fvs-observe`), and the history test
(`fvs-history-independent`: every earlier version retained in a List and
read after the fold is the value it was).

**Definedness of the new registers.** (*Observation.*) The census found
that `botlish-native check` accepts a register read on a path where it is
undefined. M1 does not redesign the validator; instead
`tools/defined.tcl` checks NIR text independently -- a forward
must-analysis over blocks with error edges from every instruction inside a
`pusherrorexit` span -- and `fvs-nir-defined` runs it over every program
the test file runs, under the default, `-struct-fold 0` and
`-struct-ref-joins 0`; the fuzzer runs it over every program. Over the
corpus: 209 programs (the corpus of section 15 and the width inputs), 18,486 functions, no undefined read -- with fold slots and with `-struct-fold 0 -struct-ref-joins 0` (the base lowering) alike. The driver's validator gap remains, now documented and
covered for this lowering (section 16).

**GC.** (*Observation.*) The test file under
`BOTLISH_NATIVE_GC_STRESS=1` (`fvs-gc-stress` also forces it on a
BigInt- and String-carrying fold), the fuzzer's GC-stress seeds and the
probes under GC stress all agree. The fold-slot function's maximum live
roots and shadow slots are those of the object lowering, or one more where
a carried field and the old object were never live together (section 14's
table), and its safepoints one or two fewer (the per-iteration
`structnew`).

**Coroutines.** (*Observation.*) A fold carried inside a coroutine body
across yields (`fvs-coroutine`), fused and unfused (`cranelift-unfused` is
one of the eight configurations): the carried registers are ordinary
registers of the fused or general frame. `d-coroutine` builds no struct
(4 before).

**Affine resources.** (*Implementation fact.*) An affine intermediate is
AFFINE-FOLD-UNSUPPORTED before any representation is chosen, unchanged; a
fold slot never holds an affine value. Affine values inside the body are
released after their statements by `SequenceStatements`, which
`SequenceVirtual` uses (`fvs-affine-body`: a coroutine handle created and
released every iteration of a carried fold).

## 11. Scanner performance

(*Observation*, compiler; callgrind instructions per run of the census's
workloads; Struct allocations from `native::allocationReport`.)

| workload | base Struct | M1 Struct | base instr/run | M1 instr/run | recursion | M1 / recursion | cells (MutableArray) |
|---|---:|---:|---:|---:|---:|---:|---:|
| scan2 (`a-scan2-*`) | 161 | 0 | 137,698 | 25,877 | 23,809 | 108.7% (generated code: 110.0%) | 51,576 |
| scan4 (`a-scan4-*`) | 161 | 0 | 142,421 | 29,314 | 24,300 | 120.6% (generated code: 111.8%) | 53,004 |
| scan6 (`scanner-*`, the target) | 161 | 0 | 139,066 | 28,772 | 25,588 | **112.4%** (generated code: 111.0%) | 55,741 |

M1 and recursion columns are medians of five runs: callgrind's counts of
one driver process are exact, but they varied between processes by up to
23% on the two- and four-field rows and 2.3% on the six-field ones -- all
of it in the profile's allocator and memory categories (the C allocator's
behavior differs run to run), none in the generated code, so the
generated-code ratio is given beside the total. Base columns are one run.
The census's experiment had 28,944 / 25,524 = 113.4% for the six-field
scanner; the compiler lands 112.4%. The four-field variant's total is
above 115% in the median (its generated code is 111.8%); the 115% target
is the six-field scanner's, and every variant's struct allocations are
gone. The remaining gap to the recursion is not allocation -- the
profile's allocator share falls from 60.0% to 3.6% -- but, by the
generated-code ratio, code: the loop's own control and the back edge's
moves against the recursion's argument passing (*Judgment*, from the
profiles' categories).

`number_at` returns its fold's two fields with `retmulti`. Measured
during development with fold slots but without folds as recognized
constructions (the state mutant `fold-not-construction` restores), the
scanner built 16 structs and ran 38,247 instructions -- the census's point
that optimizing only the main fold is not enough, confirmed on the
compiler.

## 12. Mutable-field performance

(*Observation*, compiler, Probe C at n = 1,024 and 16,384, consumed
(default) and copying (`hir::mutvec::consumedFolds 0`).)

| row | n | Struct base -> M1 | shares/detaches/elements base | M1 | instr/run base | instr/run M1 | M1 / base |
|---|---:|---:|---|---|---:|---:|---:|
| c-vec-literal | 1,024 | 1,025 -> 0 | 0/0/0 | 0/0/0 | 853,348 | 150,604 | 17.6% |
| c-vec-literal(copying) | 1,024 | 2,049 -> 0 | 1024/1024/523776 | 1024/1024/523776 | 6,917,567 | 4,318,461 | 62.4% |
| c-vec-self | 1,024 | 1 -> 0 | 0/0/0 | 0/0/0 | 142,234 | 138,119 | 97.1% |
| c-vec-self(copying) | 1,024 | 1,025 -> 0 | 1024/1024/523776 | 1024/1024/523776 | 5,915,662 | 4,076,303 | 68.9% |
| c-two-vecs | 1,024 | 1,025 -> 0 | 0/0/0 | 0/0/0 | 1,174,987 | 132,355 | 11.3% |
| c-two-vecs(copying) | 1,024 | 2,049 -> 0 | 2048/1024/261632 | 2048/1024/261632 | 6,972,929 | 4,393,411 | 63.0% |
| c-mixed | 1,024 | 1,025 -> 0 | 0/0/0 | 0/0/0 | 3,093,971 | 1,995,142 | 64.5% |
| c-mixed(copying) | 1,024 | 2,049 -> 0 | 1024/1024/523776 | 1024/1024/523776 | 8,291,685 | 5,726,643 | 69.1% |
| c-vec-continue | 1,024 | 1,367 -> 0 | 1024/1024/174933 | 1024/1024/174933 | 5,266,204 | 3,298,486 | 62.6% |
| c-vec-continue(copying) | 1,024 | 1,367 -> 0 | 1024/1024/174933 | 1024/1024/174933 | 5,256,466 | 3,319,313 | 63.1% |
| c-vec-literal | 16,384 | 16,385 -> 0 | 0/0/0 | 0/0/0 | 19,817,716 | 2,303,384 | 11.6% |
| c-vec-literal(copying) | 16,384 | 32,769 -> 0 | 16384/16384/134209536 | 16384/16384/134209536 | 1,503,700,238 | 1,107,645,145 | 73.7% |
| c-vec-self | 16,384 | 1 -> 0 | 0/0/0 | 0/0/0 | 2,161,575 | 2,085,702 | 96.5% |
| c-vec-self(copying) | 16,384 | 16,385 -> 0 | 16384/16384/134209536 | 16384/16384/134209536 | 1,516,259,700 | 1,244,730,284 | 82.1% |
| c-two-vecs | 16,384 | 16,385 -> 0 | 0/0/0 | 0/0/0 | 19,847,816 | 2,000,228 | 10.1% |
| c-two-vecs(copying) | 16,384 | 32,769 -> 0 | 32768/16384/67100672 | 32768/16384/67100672 | 773,539,148 | 664,370,766 | 85.9% |
| c-mixed | 16,384 | 16,385 -> 0 | 0/0/0 | 0/0/0 | 1,470,927,002 | 1,456,395,025 | 99.0% |
| c-mixed(copying) | 16,384 | 32,769 -> 0 | 16384/16384/134209536 | 16384/16384/134209536 | 2,720,985,721 | 2,602,858,628 | 95.7% |
| c-vec-continue | 16,384 | 21,847 -> 0 | 16384/16384/44741973 | 16384/16384/44741973 | 525,836,748 | 514,050,068 | 97.8% |
| c-vec-continue(copying) | 16,384 | 21,847 -> 0 | 16384/16384/44741973 | 16384/16384/44741973 | 527,435,623 | 506,155,293 | 96.0% |

* Consumed rows: zero shares and detaches, before and after.
* Copying rows: the same shares, detaches and detached elements as base
  -- the field-wise share copies exactly what the object share copied.
* Every row builds no struct (base: one per constructing iteration, two
  per iteration in a copying fold -- its entry copy and its completion, the
  latter skipped by `c-vec-continue`'s `continue`;
  `c-vec-self` already built one, its completion being the intermediate).
* Instructions fall in every row, most where the struct was the main cost
  (consumed `c-vec-literal` and `c-two-vecs` at 16,384: 10-12% of base);
  rows dominated by List copying (`c-mixed`'s log field) or by the
  copying mode's element copies change least (96-99%).
* `c-vec-continue` copies at every iteration's entry in both modes (its
  `continue` follows a push: hir/mutvec.tcl keeps the copy), and builds no
  struct.

## 13. Chunk workload, with M2's remaining cost isolated

(*Observation*, compiler, Probe B: `chunks-fold.bot` with its recursive
twin, `b-wrap-fold`, `b-counted-fold` and `list-fold`.)

| row | n | Struct base -> M1 | List copied base -> M1 | instr/run base | instr/run M1 | M1 / base | code bytes base -> M1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| chunks-fold | 128 | 128 -> 0 | 1,516 -> 1,516 | 333,171 | 270,921 | 81.3% | 4,420 -> 4,100 |
| chunks-recursive | 128 | 0 -> 0 | 505 -> 505 | 243,602 | 240,890 | 98.9% | 11,651 -> 11,651 |
| wrap-fold | 128 | 129 -> 0 | 8,382 -> 8,382 | 304,668 | 164,912 | 54.1% | 1,853 -> 1,725 |
| list-fold(direct) | 128 | 0 -> 0 | 506 -> 506 | 117,476 | 116,580 | 99.2% | 1,869 -> 1,869 |
| counted-fold | 128 | 129 -> 0 | 2,271 -> 2,271 | 240,614 | 117,331 | 48.8% | 2,220 -> 2,011 |
| counted-recursive | 128 | 0 -> 0 | 379 -> 379 | 89,739 | 90,900 | 101.3% | 2,712 -> 2,712 |
| chunks-fold | 1,024 | 1,024 -> 0 | 73,689 -> 73,689 | 3,472,548 | 2,376,374 | 68.4% | 4,420 -> 4,100 |
| chunks-recursive | 1,024 | 0 -> 0 | 4,102 -> 4,102 | 1,961,117 | 1,955,058 | 99.7% | 11,651 -> 11,651 |
| wrap-fold | 1,024 | 1,025 -> 0 | 525,822 -> 525,822 | 3,511,519 | 2,289,053 | 65.2% | 1,853 -> 1,725 |
| list-fold(direct) | 1,024 | 0 -> 0 | 4,090 -> 4,090 | 848,660 | 848,895 | 100.0% | 1,869 -> 1,869 |
| counted-fold | 1,024 | 1,025 -> 0 | 132,863 -> 132,863 | 2,393,464 | 1,204,049 | 50.3% | 2,220 -> 2,011 |
| counted-recursive | 1,024 | 0 -> 0 | 3,067 -> 3,067 | 640,650 | 639,060 | 99.8% | 2,712 -> 2,712 |
| chunks-fold | 4,096 | 4,096 -> 0 | 1,143,088 -> 1,143,088 | 22,782,281 | 17,903,298 | 78.6% | 4,420 -> 4,100 |
| chunks-recursive | 4,096 | 0 -> 0 | 16,431 -> 16,431 | 7,863,529 | 7,871,368 | 100.1% | 11,651 -> 11,651 |
| wrap-fold | 4,096 | 4,097 -> 0 | 8,394,750 -> 8,394,750 | 83,408,614 | 79,282,693 | 95.1% | 1,853 -> 1,725 |
| list-fold(direct) | 4,096 | 0 -> 0 | 16,378 -> 16,378 | 3,445,624 | 3,407,929 | 98.9% | 1,869 -> 1,869 |
| counted-fold | 4,096 | 4,097 -> 0 | 2,104,319 -> 2,104,319 | 23,698,384 | 19,274,723 | 81.3% | 2,220 -> 2,011 |
| counted-recursive | 4,096 | 0 -> 0 | 12,283 -> 12,283 | 2,582,293 | 2,581,822 | 100.0% | 2,712 -> 2,712 |
| chunks-fold | 16,384 | 16,384 -> 0 | 18,124,480 -> 18,124,480 | 335,919,226 | 316,460,372 | 94.2% | 4,420 -> 4,100 |
| chunks-recursive | 16,384 | 0 -> 0 | 65,760 -> 65,760 | 32,968,336 | 32,926,472 | 99.9% | 11,651 -> 11,651 |
| wrap-fold | 16,384 | 16,385 -> 0 | 134,242,302 -> 134,242,302 | 1,651,419,694 | 1,637,045,467 | 99.1% | 1,853 -> 1,725 |
| list-fold(direct) | 16,384 | 0 -> 0 | 65,530 -> 65,530 | 13,636,784 | 13,659,966 | 100.2% | 1,869 -> 1,869 |
| counted-fold | 16,384 | 16,385 -> 0 | 33,583,103 -> 33,583,103 | 408,701,015 | 393,010,460 | 96.2% | 2,220 -> 2,011 |
| counted-recursive | 16,384 | 0 -> 0 | 49,147 -> 49,147 | 10,251,609 | 10,188,464 | 99.4% | 2,712 -> 2,712 |

The struct allocations are gone at every size; what is left is the List
copying of the eager `append` on a List field of a carried struct
(`copied`: 18.1 million elements at 16,384 for the chunk fold, against
65,760 in its recursion). That is exactly the census's M1-only prediction
(316.6 million instructions at 16,384; the compiler's 316.5 million) and
not its M1+M2 result (33.8 million): field-level construction plans are
milestone 2's. `b-counted-fold` builds no struct (the census predicted 1).

## 14. Width limits, representation budgets and measured compiler costs

**What the existing limits are.** (*Implementation facts*,
hir/transport.tcl and hir/escape.tcl.)

| limit | kind | purpose | applies to a fold slot? |
|---|---|---|---|
| descriptor well-formedness (every written field in one layout slot) | correctness | a representation must name every field once | yes, unchanged |
| a slot's fields are its descriptor's own (no cut) | correctness, of this design | a carried value has one register layout per iteration | yes (section 4) |
| `localWidth` 16 | local virtualization policy | register pressure of one binding's live range | no (a fold slot has its own); yes to a local bound to the fold's value |
| `returnWidth` 16, `argWidth` 8 and the transport scores (`argRegs` 4, `returnRegs` 8, spill factors, `argBudget`/`returnBudget`/`cycleBudget` 20, `cycleFactor` 3) | transport budgets, calibrated on call-boundary probes (stack operands, code bytes) | the pressure of carrying W values across exact boundaries | only where the fold's value or intermediate crosses one (a call in the body included); the back edge is no boundary |
| nesting cuts (`nesting`, the widened-path budgets) | performance policy | open an inner struct only when the widened value still fits | no: a fold slot is opaque (section 4) |
| `aggregateDepth`, `appliedDepth` | type-lattice bounds | finite types | unrelated |
| legacy caps (16, 8, 4) | the previous milestones' comparison oracle | byte-for-byte comparisons | the legacy policy has no fold slots at all |
| no implementation capacity | -- | NIR registers, descriptors and the virtual local entry have no fixed size | -- |

No width restriction is needed for correctness: a fold slot of any width
lowers to valid NIR (the 128- and 256-field inputs run with
`-struct-fold-width 256`).

**Measurements.** (*Observation*, compiler; `width/` holds the inputs,
tools/gen-width.tcl writes them: `few` -- one field updated per iteration;
`most` -- every field; `branch` -- a third of the iterations identity;
`ret` -- the fold is a function's value; `nested` -- W-1 Int fields and a
nested struct; `spill` -- every field live across a recursive call per
iteration.) Callgrind instructions per run, base over M1 (speedup), and
machine code of the whole program, M1 against base (no input allocates
anything but the fold's structs: 1,001 per run in base, 0 with fold slots,
1 for a 32- or 64-field fold's value bound to a local, built once after
the loop):

| shape | 2 | 4 | 6 | 8 | 16 | 32 | 64 |
|---|---:|---:|---:|---:|---:|---:|---:|
| few (speedup) | 15.69x | 15.93x | 16.12x | 16.21x | 19.44x | 21.62x | 26.10x |
| most (speedup) | 6.95x | 4.13x | 3.06x | 2.56x | 1.88x | 1.42x | 1.25x |
| branch (speedup) | 5.66x | 3.62x | 2.84x | 2.39x | 1.84x | 1.39x | 1.21x |
| ret (speedup) | 7.06x | 4.06x | 3.03x | 2.53x | 1.88x | 1.44x | 1.24x |
| nested (speedup) | 1.87x | 1.79x | 1.72x | 1.66x | 1.59x | 1.39x | 1.27x |
| spill (speedup) | 6.44x | 4.16x | 3.19x | 2.68x | 2.05x | 1.54x | 1.31x |
| few (code) | -26% | -31% | -37% | -42% | -54% | -36% | -41% |
| most (code) | -8% | -9% | -7% | -6% | +5% | +15% | +12% |
| branch (code) | -9% | -8% | -7% | -4% | +4% | +11% | +9% |
| ret (code) | -9% | -5% | -4% | -2% | +9% | +9% | +8% |
| nested (code) | -12% | -11% | -7% | -5% | +0% | +8% | +7% |
| spill (code) | -6% | -9% | -10% | -8% | -0% | +7% | +7% |

Beyond the ceiling (`most` and `spill` at 128 and 256 fields, which the
default declines, measured with `-struct-fold-width 256`): base 8.78M,
16.42M, 7.36M and 13.22M instructions; carried 7.05M, 14.14M, 5.74M and
11.21M (1.25x, 1.16x, 1.28x, 1.18x).

Registers, roots, frame and stack traffic of the fold function (driver
`roots`; objdump of the object: the prologue's frame and the instructions
addressing the frame, i.e. Cranelift's spills, reloads and stack-map
slots), object lowering -> fold slot:

| input | NIR regs | safepoints | max live roots | shadow slots | frame bytes | frame-addressing instructions |
|---|---:|---:|---:|---:|---:|---:|
| few-2 | 25 -> 22 | 5 -> 3 | 3 -> 3 | 3 -> 3 | 96 -> 64 | 31 -> 18 |
| few-4 | 31 -> 30 | 5 -> 3 | 4 -> 5 | 4 -> 5 | 128 -> 80 | 38 -> 20 |
| few-6 | 37 -> 38 | 5 -> 3 | 6 -> 7 | 6 -> 7 | 176 -> 96 | 46 -> 22 |
| few-8 | 43 -> 46 | 5 -> 3 | 8 -> 9 | 8 -> 9 | 224 -> 112 | 54 -> 24 |
| few-16 | 67 -> 78 | 5 -> 3 | 16 -> 17 | 16 -> 17 | 496 -> 176 | 112 -> 32 |
| few-32 | 115 -> 145 | 5 -> 4 | 32 -> 33 | 32 -> 33 | 1008 -> 560 | 210 -> 113 |
| few-64 | 211 -> 273 | 5 -> 4 | 64 -> 65 | 64 -> 65 | 2032 -> 1072 | 403 -> 209 |
| most-2 | 42 -> 39 | 9 -> 7 | 3 -> 3 | 3 -> 3 | 96 -> 64 | 39 -> 30 |
| most-4 | 70 -> 69 | 15 -> 13 | 5 -> 5 | 5 -> 5 | 176 -> 112 | 66 -> 60 |
| most-6 | 98 -> 99 | 21 -> 19 | 7 -> 7 | 7 -> 7 | 240 -> 144 | 90 -> 86 |
| most-8 | 126 -> 129 | 27 -> 25 | 9 -> 9 | 9 -> 9 | 304 -> 176 | 114 -> 112 |
| most-16 | 238 -> 249 | 51 -> 49 | 17 -> 17 | 17 -> 17 | 560 -> 304 | 210 -> 280 |
| most-32 | 462 -> 492 | 99 -> 98 | 33 -> 33 | 33 -> 33 | 1072 -> 848 | 402 -> 716 |
| most-64 | 910 -> 972 | 195 -> 194 | 65 -> 65 | 65 -> 65 | 2096 -> 1616 | 786 -> 1356 |
| branch-2 | 42 -> 40 | 9 -> 7 | 4 -> 4 | 4 -> 4 | 128 -> 96 | 49 -> 39 |
| branch-4 | 62 -> 64 | 15 -> 13 | 6 -> 6 | 6 -> 6 | 192 -> 128 | 75 -> 72 |
| branch-6 | 82 -> 88 | 21 -> 19 | 8 -> 8 | 8 -> 8 | 256 -> 160 | 101 -> 100 |
| branch-8 | 102 -> 112 | 27 -> 25 | 10 -> 10 | 10 -> 10 | 320 -> 192 | 127 -> 128 |
| branch-16 | 182 -> 208 | 51 -> 49 | 18 -> 18 | 18 -> 18 | 576 -> 320 | 231 -> 293 |
| branch-32 | 342 -> 403 | 99 -> 98 | 34 -> 34 | 34 -> 34 | 1088 -> 864 | 439 -> 659 |
| branch-64 | 662 -> 787 | 195 -> 194 | 66 -> 66 | 66 -> 66 | 2112 -> 1632 | 855 -> 1234 |
| ret-2 | 32 -> 32 | 8 -> 6 | 4 -> 4 | 4 -> 4 | 128 -> 96 | 43 -> 33 |
| ret-4 | 52 -> 54 | 14 -> 12 | 6 -> 6 | 6 -> 6 | 192 -> 144 | 78 -> 85 |
| ret-6 | 72 -> 76 | 20 -> 18 | 8 -> 8 | 8 -> 8 | 256 -> 176 | 106 -> 113 |
| ret-8 | 92 -> 98 | 26 -> 24 | 10 -> 10 | 10 -> 10 | 320 -> 208 | 134 -> 141 |
| ret-16 | 172 -> 186 | 50 -> 49 | 18 -> 18 | 18 -> 18 | 576 -> 464 | 246 -> 328 |
| ret-32 | 332 -> 362 | 98 -> 97 | 34 -> 34 | 34 -> 34 | 1088 -> 864 | 470 -> 650 |
| ret-64 | 652 -> 714 | 194 -> 193 | 66 -> 66 | 66 -> 66 | 2112 -> 1632 | 918 -> 1225 |
| nested-2 | 43 -> 38 | 11 -> 9 | 4 -> 4 | 4 -> 4 | 160 -> 128 | 60 -> 53 |
| nested-4 | 57 -> 54 | 15 -> 13 | 6 -> 6 | 6 -> 6 | 224 -> 160 | 81 -> 82 |
| nested-6 | 71 -> 70 | 19 -> 17 | 8 -> 8 | 8 -> 8 | 288 -> 192 | 103 -> 108 |
| nested-8 | 85 -> 86 | 23 -> 21 | 10 -> 10 | 10 -> 10 | 352 -> 224 | 125 -> 134 |
| nested-16 | 141 -> 150 | 39 -> 37 | 18 -> 18 | 18 -> 18 | 608 -> 352 | 213 -> 274 |
| nested-32 | 253 -> 282 | 71 -> 70 | 34 -> 34 | 34 -> 34 | 1120 -> 896 | 389 -> 575 |
| nested-64 | 477 -> 538 | 135 -> 134 | 66 -> 66 | 66 -> 66 | 2144 -> 1664 | 741 -> 1087 |
| spill-2 | 41 -> 38 | 7 -> 5 | 3 -> 3 | 3 -> 3 | 112 -> 80 | 40 -> 31 |
| spill-4 | 63 -> 62 | 11 -> 9 | 5 -> 5 | 5 -> 5 | 176 -> 112 | 65 -> 57 |
| spill-6 | 85 -> 86 | 15 -> 13 | 7 -> 7 | 7 -> 7 | 240 -> 144 | 87 -> 79 |
| spill-8 | 107 -> 110 | 19 -> 17 | 9 -> 9 | 9 -> 9 | 304 -> 176 | 109 -> 101 |
| spill-16 | 195 -> 206 | 35 -> 33 | 17 -> 17 | 17 -> 17 | 560 -> 304 | 197 -> 239 |
| spill-32 | 371 -> 401 | 67 -> 66 | 33 -> 33 | 33 -> 33 | 1072 -> 848 | 373 -> 568 |
| spill-64 | 723 -> 785 | 131 -> 130 | 65 -> 65 | 65 -> 65 | 2096 -> 1616 | 725 -> 1080 |

Cranelift's compile time of the whole program (the driver's `timing`
line, best of 5 processes, milliseconds), object lowering -> fold slot:

| shape | 2 | 4 | 6 | 8 | 16 | 32 | 64 |
|---|---:|---:|---:|---:|---:|---:|---:|
| few | 1.3 -> 1.4 (+4%) | 1.3 -> 1.4 (+1%) | 1.3 -> 1.2 (-9%) | 1.4 -> 1.2 (-10%) | 1.6 -> 1.3 (-13%) | 1.9 -> 1.9 (-3%) | 2.9 -> 2.8 (-2%) |
| most | 1.6 -> 1.6 (-3%) | 2.1 -> 2.1 (-1%) | 2.6 -> 2.5 (-4%) | 3.1 -> 3.0 (-2%) | 5.0 -> 5.4 (+8%) | 9.7 -> 11.9 (+23%) | 24.9 -> 36.5 (+47%) |
| branch | 1.7 -> 1.5 (-16%) | 2.2 -> 2.1 (-7%) | 2.6 -> 2.6 (-3%) | 3.0 -> 2.9 (-2%) | 5.0 -> 5.3 (+6%) | 9.8 -> 12.1 (+23%) | 25.4 -> 36.1 (+42%) |
| ret | 1.8 -> 1.7 (-7%) | 2.3 -> 2.4 (+6%) | 3.0 -> 2.8 (-4%) | 3.2 -> 3.3 (+3%) | 5.1 -> 5.6 (+8%) | 9.6 -> 11.4 (+19%) | 26.0 -> 35.1 (+35%) |
| nested | 1.7 -> 1.7 (+0%) | 2.0 -> 1.9 (-2%) | 2.3 -> 2.5 (+8%) | 2.9 -> 2.8 (-4%) | 4.6 -> 4.3 (-5%) | 7.4 -> 8.7 (+17%) | 18.4 -> 24.1 (+31%) |
| spill | 1.8 -> 1.7 (-7%) | 2.3 -> 2.1 (-10%) | 2.6 -> 2.4 (-7%) | 2.8 -> 2.8 (+1%) | 4.7 -> 4.7 (-0%) | 8.5 -> 9.6 (+12%) | 20.6 -> 26.4 (+28%) |

At 128 and 256 fields (`-struct-fold-width 256`): `most` 89.0 -> 169.4 ms
and 456.6 -> 1,198.2 ms, `spill` 64.7 -> 104.3 ms and 303.4 -> 681.4 ms.

**Policy.** (*Judgment.*) Field registers win at run time at every width
(the allocation they remove costs more than the spills they add, even at
256 fields live across a call), and their frames are smaller up to 64
fields; the price is code (up to 15%) and compile time beyond 16 fields
-- +12-23% at 32, +28-47% at 64, 1.6-2.6 times at 128-256 (Cranelift's
register allocation over hundreds of loop-carried values; stack traffic
grows past 8 fields, the table above) -- where most fields change; when
one field changes, compile time and code fall at every width. So the fold
slot's ceiling is 64 -- a resource bound
on compile time for a gain that has flattened to about 1.2x by then -- not
the local ceiling, which would decline 17-64-field folds that run 1.2 to
1.5 times faster (over 20 times when one field changes per iteration). It
uses the existing representation-budget framework (a `foldWidth` option
beside `localWidth`, `-struct-fold-width`,
`BOTLISH_NATIVE_STRUCT_FOLD_WIDTH`) and no cost model: no measured shape
needed one. A fold slot wider than 64 keeps the object lowering (`dropped
width`).

**Compiler economics.** (*Observation*, `tools/economics.tcl`, base ->
M1, best of 5 on this container; times are wall-clock and noisy.)

| program | escape analysis, us (base -> M1) | use verdicts | classifications | native lowering, us | NIR instructions | machine code, bytes | live/shadow/safepoints |
|---|---:|---:|---:|---:|---:|---:|---|
| width-2 | 517 -> 750 (+45%) | 1 -> 5 | 13 -> 24 | 7,016 -> 7,093 (+1%) | 47 -> 44 | 1,317 -> 1,189 | 7/7/8 -> 7/7/6 |
| width-4 | 719 -> 973 (+35%) | 1 -> 5 | 17 -> 28 | 9,924 -> 9,527 (-4%) | 65 -> 64 | 2,133 -> 1,853 | 9/9/14 -> 9/9/12 |
| width-8 | 1,262 -> 1,542 (+22%) | 1 -> 5 | 25 -> 36 | 16,709 -> 15,810 (-5%) | 101 -> 104 | 3,629 -> 3,285 | 13/13/26 -> 13/13/24 |
| width-16 | 1,968 -> 2,385 (+21%) | 1 -> 5 | 41 -> 52 | 28,361 -> 26,037 (-8%) | 173 -> 184 | 6,669 -> 6,413 | 21/21/50 -> 21/21/48 |
| width-32 | 3,931 -> 4,399 (+12%) | 1 -> 3 | 73 -> 81 | 53,774 -> 53,249 (-1%) | 317 -> 377 | 12,853 -> 13,261 | 37/37/98 -> 37/37/97 |
| width-64 | 8,357 -> 10,913 (+31%) | 1 -> 3 | 137 -> 145 | 113,167 -> 130,318 (+15%) | 605 -> 729 | 25,173 -> 26,149 | 69/69/194 -> 69/69/193 |
| nested-1 | 606 -> 893 (+47%) | 1 -> 5 | 18 -> 29 | 11,175 -> 8,835 (-21%) | 55 -> 52 | 1,517 -> 1,301 | 8/8/9 -> 9/9/7 |
| nested-2 | 949 -> 1,336 (+41%) | 1 -> 9 | 26 -> 48 | 13,432 -> 11,962 (-11%) | 94 -> 90 | 2,605 -> 2,413 | 12/12/16 -> 16/16/12 |
| nested-3 | 1,123 -> 1,829 (+63%) | 1 -> 13 | 34 -> 67 | 15,495 -> 16,438 (+6%) | 133 -> 128 | 3,709 -> 3,549 | 16/16/23 -> 23/23/17 |
| nested-4 | 1,475 -> 2,056 (+39%) | 1 -> 17 | 42 -> 86 | 20,123 -> 18,200 (-10%) | 172 -> 166 | 5,029 -> 4,805 | 20/20/30 -> 30/30/22 |
| nested-5 | 1,730 -> 2,723 (+57%) | 1 -> 21 | 50 -> 105 | 23,298 -> 23,373 (+0%) | 211 -> 204 | 6,261 -> 5,765 | 24/24/37 -> 37/37/27 |
| many-10 | 4,485 -> 8,115 (+81%) | 1 -> 41 | 112 -> 272 | 61,757 -> 68,441 (+11%) | 540 -> 567 | 13,533 -> 10,645 | 8/8/83 -> 9/9/53 |
| many-20 | 9,155 -> 16,675 (+82%) | 1 -> 81 | 212 -> 532 | 118,642 -> 129,242 (+9%) | 1060 -> 1117 | 25,941 -> 19,629 | 8/8/163 -> 9/9/103 |
| many-40 | 24,429 -> 39,672 (+62%) | 1 -> 161 | 412 -> 1052 | 274,247 -> 288,243 (+5%) | 2100 -> 2217 | 51,005 -> 38,493 | 8/8/323 -> 9/9/203 |
| many-80 | 56,117 -> 94,622 (+69%) | 1 -> 321 | 812 -> 2092 | 589,668 -> 666,061 (+13%) | 4180 -> 4417 | 100,669 -> 76,157 | 8/8/643 -> 9/9/403 |
| locals-10 | 3,072 -> 3,291 (+7%) | 10 -> 10 | 80 -> 80 | 29,390 -> 29,872 (+2%) | 56 -> 56 | 453 -> 453 | 4/4/4 -> 4/4/4 |
| locals-20 | 6,485 -> 6,587 (+2%) | 20 -> 20 | 150 -> 150 | 58,530 -> 57,424 (-2%) | 96 -> 96 | 453 -> 453 | 4/4/4 -> 4/4/4 |
| locals-40 | 14,508 -> 16,852 (+16%) | 40 -> 40 | 290 -> 290 | 124,482 -> 136,259 (+9%) | 176 -> 176 | 453 -> 453 | 4/4/4 -> 4/4/4 |
| locals-80 | 33,908 -> 33,694 (-1%) | 80 -> 80 | 570 -> 570 | 270,365 -> 267,691 (-1%) | 336 -> 336 | 455 -> 455 | 4/4/4 -> 4/4/4 |
| scanner-fold | 3,342 -> 5,019 (+50%) | 0 -> 4 | 70 -> 122 | 60,245 -> 66,291 (+10%) | 286 -> 306 | 4,682 -> 3,482 | -/-/- -> -/-/- |
| chunks-fold | 1,691 -> 2,199 (+30%) | 0 -> 2 | 34 -> 61 | 27,770 -> 27,505 (-1%) | 200 -> 194 | 4,420 -> 4,100 | -/-/- -> -/-/- |
| fold-loops | 114,760 -> 126,149 (+10%) | 59 -> 83 | 1671 -> 1881 | 5,615,916 -> 6,065,584 (+8%) | 6034 -> 6015 | 129,222 -> 128,490 | 5/5/2 -> 5/5/2 |

(`width-W`: one W-field struct local and fold; `nested-N`: N nested
folds; `many-N`: N folds in one function; `locals-N`: N struct locals and
no fold -- tools/gen-economics.tcl; then the census's workloads and the
fold-loops golden suite. `-/-/-`: no fold function reported.)

* The escape analysis costs more where there are folds: +12-82% on the
  synthetic inputs, +50% on the scanner, +10% on the fold-loops golden
  suite; on `locals-N` (no fold) it is unchanged within noise. It stays a
  small part of native lowering (the scanner: 5.0 of 66.3 ms), whose total
  changes by -21% to +15%.
* The work is linear in folds, not fields: use verdicts grow by 4 per
  fold (`many-N`: 1 -> 4N+1; `nested-N`: 1 -> 4N+1) and stay at 3-5 for
  a single fold of any width; the escape time of `many-N` doubles with N
  in both trees. One shape fact per fold, one use verdict per slot and
  round, one no-loss walk per slot and set of materializing references:
  no walk per field, and no multiplicative work in nesting or count.
* Programs without an eligible fold slot run one round and keep their
  NIR unless a whole-struct share applies (section 6).

## 15. Differential, mutation and regression testing

| check | result (*Observation*) |
|---|---|
| tests/fold-virtual-struct-state.test (49 tests; values over eight configurations) | all pass; also under `BOTLISH_NATIVE_GC_STRESS=1` |
| golden suite fold-virtual-struct-state.bot (41 ported tests, `weaker`; 8 kept in Tcl) | 41/41 on interp, compile, cranelift-generic, cranelift; perturbation: 41/41 inverted and altered fail |
| standalone executables | `fvs-executable`: the scanner, five Probe D files, `c-vec-continue`, `b-counted-fold` and a permuting nested-result program as executables, plain and under GC stress, equal to the interpreter |
| fuzzer (tools/fuzz.tcl: scalar, history, vector, nested templates; independent decision model; no-loss and definedness checks) | 234 programs, 0 failing: seeds 2-6 (125 programs, seeds 4 and 6 under GC stress) before the nested template and the definedness check, seeds 11, 12, 21 and 22 (109 programs, 22 under GC stress) with them; the model and the compiler agreed on every decision (33 declined among them); the nested template found the `c5679581` bug unaided (seed 11, with the fix reverted) |
| milestone mutants (19) | 19 killed, each by a test its `!!` line names |
| neighbor catalogs | consumed-folds all killed; fold-virtual-construction 18/18; fold-loops 22/22 (after a test extension, below); depth-safe-nesting `native-recursion` killed |
| legacy parity (value-transport-materialization) | 28/28 NIR identical to base |
| corpus (163 programs: every golden suite, `bench/`, the fold workloads; tools/corpus.tcl and corpus-compare.py) | `off` = base byte for byte, every program; default: 137 unchanged, 21 changed by fold slots, 3 by reference joins alone, 2 by both, none by neither; Struct allocations 105,061 -> 95,992, no program more |
| full local suite (`tests/local.tcl`) | every Tcl test file on interp and compile (292 files) and every golden suite on interp, compile, cranelift-generic and cranelift (121 suites): all pass. One test, `syntax-highlighting.test`'s `sh-grammar-vim-corpus` on compile, failed once in the 4-job run (its vim child exited 1) and passed on all three reruns; the branch changes none of its files. (The run was split in two after a wrapper's time limit stopped the first at 410 of 705.) |
| CI | the four test workflows dispatched on the branch at `2ffe5a98` (the code of this report; later commits change documentation, the transport comment and result files only): `tests` (run 43641108945), `tests (linux arm64)` (43641111770), `tests (macos arm64)` (43641114725), `tests (windows x86-64)` (43641117759). All four end `failure`, and every failing job fails only `argv.test`'s `argv-focused-valid-fuzz` and `native-tcl-unicode.test`'s `native-tcl-unicode-lowercase-all-scalars` -- the two tests that fail on main at `b0ae98fe` on every host, checked before branching. Every other job passed: the canaries, the native Rust unit tests (arm64 also under GC stress), every golden shard on x86-64 and arm64, the method-call oracle, the arm64 GC-stress runs (failing only the two), macOS acceptance shards 1-4, Botlish.app, main-thread startup and static SDL3, Windows acceptance shards 2-4. x86-64's GC-stress job runs on pushes to main only and was skipped; static-decisions.yml was not dispatched (fold slots are a native representation decision: no front-end check, scheduler or cross-function fact changed) |

The required mutant kinds map to the catalog as: sequential back edge
`back-edge-sequential`; candidates committed before `continue`
`continue-commits`; `break` reading candidates `break-not-current`;
mismatched descriptor `result-outside-slot-class`; captured intermediate
`capture-admitted`; identity branch misclassified `identity-leaf-unchecked`
(and `identity-branch-off`); fold result not recognized for exact return
`fold-not-construction`; omitted materialization `exit-not-materialized`;
no-loss disabled `no-loss-off` (and `no-loss-keep-ignored`); incorrectly
retained whole-struct share `share-fieldwise-skipped`; consumed field
shared `consumed-shared`; heap-backed field excluded from GC liveness
`carried-untraced`; fold slot rejected entirely `fold-slots-off`; plus
`shape-unrecognized-leaf`, `ref-shape-any-binding`, `sources-unchecked`,
`share-declined`.

**A neighbor mutant that survived.** (*Observation.*) The fold-loops
catalog's `aot-bare-fold-body-discarded` (a bare fold's body value taken
for discarded) survived on the milestone tree and was killed on base: its
one test, `fold-loops-executable`, had a bare fold with a struct
intermediate, which fold slots now carry, and a fold slot's body never
reads the discarded flag the mutant corrupts. The test gained a bare fold
whose struct an equality before a `continue` keeps from field registers
(the no-loss rule); the mutant is killed again.

**Two neighbor fuzzers test nothing.** (*Observation*, base and M1 alike.)
`audit/struct-scalar-replacement/tools/fuzz.py` and
`audit/value-transport-materialization/tools/fuzz.py` generate programs in
the syntax before the `std` namespace (`mutarray::create`); every program
fails to compile and their harnesses count it as `compile-skipped` (40 of
40). They gave no evidence here; repairing them is outside this milestone
(section 16).

## 16. Known limitations and recommended M2 boundary

* **List and String fields copy.** (*Observation.*) A carried struct's
  List field is extended by an eager `append` each iteration: the chunk
  fold's 18.1 million copied elements at 16,384 are milestone 2's (a plan
  field: hir/construction.tcl's carrier inside a fold slot, per-field
  linearity, plan-producing projections). M1 leaves every List field an
  ordinary tagged register; nothing in it prepares or forecloses M2.
* **No cuts.** (*Judgment.*) A fold slot carries its descriptor's own
  fields; an inner struct stays one object, rebuilt when the completion
  rebuilds it (`fvs-exact-call-nested-result` builds 11 `Inner` objects
  where the object lowering builds 22 structs). Opening nested structs
  across a back edge would need a cut stable across iterations; no
  measured workload needed it.
* **Parameters are never sources.** A fold whose initial value (or a
  completion) is a struct parameter keeps the object lowering: the
  parameter's fields exist as registers only in its instance's `fields`
  variant. Admitting it would need the slot to read the parameter's
  fields at entry in every variant -- one projection per field -- a small,
  separate extension no measured workload needed.
* **The no-loss rule is a path walk, not a frequency estimate.** A
  materializing use on a rare path that also keeps the intermediate
  declines the slot even when constructing iterations dominate.
* **The driver's NIR validator** still does not check definedness;
  tools/defined.tcl covers fold-slot lowering in the tests and the fuzzer,
  and any future NIR-to-NIR pass should run it (or the validator should
  learn it).
* **Stale fuzzers.** Section 15's two neighbor fuzzers need their
  generators moved to the `std` namespace.

**Recommended M2 boundary.** Start from the fold slot as it is: a List or
String field of a virtual fold slot becomes a plan carrier when every
completion extends it linearly (the field path `s.items` read once,
appended, written back), materialized where the field is read whole and at
the fold's exit. The census's NIR experiment's M1+M2 row (33.8 million at
16,384) is the target; Probe B's rows above are the M1 baseline.

## 17. Reproduction commands and verification evidence

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
A=audit/fold-virtual-struct-state
tclsh9.0 tests/fold-virtual-struct-state.test
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/fold-virtual-struct-state.test
tclsh9.0 tests/local.tcl tests/golden/fold-virtual-struct-state.bot
tclsh9.0 $A/tools/golden-port.tcl            # regenerates the port (deterministic)
tclsh9.0 $A/tools/fuzz.tcl -seed 2 -count 25 # several seeds; -gc-stress 1 once
tclsh9.0 $A/tools/mutate.tcl                 # every mutant killed
tclsh9.0 $A/tools/defined.tcl FILE.bot ...   # NIR definedness
# corpus: off must equal base; no program builds more structs
tclsh9.0 $A/tools/corpus.tcl -root BASE -run 1 FILES > base.txt
tclsh9.0 $A/tools/corpus.tcl -run 1 -configs 'default {} off {-struct-fold 0 -struct-ref-joins 0} refoff {-struct-ref-joins 0} foldoff {-struct-fold 0}' FILES > mine.txt
python3 -I $A/tools/corpus-compare.py base.txt mine.txt
# measurements (callgrind)
tclsh9.0 $A/tools/measure.tcl -instructions 1 "scan6-fold audit/fold-loops/workloads/scanner-fold.bot" ...
tclsh9.0 $A/tools/measure.tcl -root BASE -instructions 1 ...
tclsh9.0 $A/tools/gen-width.tcl
tclsh9.0 $A/tools/width-facts.tcl -compile-runs 5 $A/width/*.bot
tclsh9.0 $A/tools/economics.tcl -root BASE -runs 5 ...
```

Results are under `audit/fold-virtual-struct-state/results/m1-*.txt`
(base and milestone side by side). Measured on this container (Linux
x86-64, 4 cores, the release native backend); callgrind counts are
exact per driver process but varied between processes (up to 23% on the
narrow scanners, in the allocator and memory categories), so the
scanner's rows are medians of five runs; timings are best of 5 and
noisy.
