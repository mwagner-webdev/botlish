# FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md

Loop-carried struct virtualization and field-level construction: a census
of how a fold carrying an immutable struct is represented today, what
carrying its fields independently would save, what a design must prove, and
the recommended next milestones. No production code changed; the evidence
is a probe suite, a NIR-level experiment that applies the proposed
representation to the NIR the current compiler emits, and measurements
(`audit/fold-virtual-struct-state/`).

Evidence labels: **Implementation fact** -- read from the compiler or
runtime at commit `0030f8a7`; **Observation** -- a reproducible run
(section 16); **Judgment** -- an interpretation or recommendation.

## Contents

1. [Executive answer](#1-executive-answer)
2. [Current state](#2-current-state)
3. [Representation trace](#3-representation-trace)
4. [Scanner analysis](#4-scanner-analysis)
5. [Chunk analysis](#5-chunk-analysis)
6. [Existing virtual struct machinery](#6-existing-virtual-struct-machinery)
7. [Loop back edges: the missing representation and proof](#7-loop-back-edges-the-missing-representation-and-proof)
8. [Construction-plan interactions](#8-construction-plan-interactions)
9. [Consumption interactions](#9-consumption-interactions)
10. [Control-flow correctness](#10-control-flow-correctness)
11. [GC and resource lifetimes](#11-gc-and-resource-lifetimes)
12. [Architectural alternatives](#12-architectural-alternatives)
13. [Compiler economics](#13-compiler-economics)
14. [Recommended stages and acceptance tests](#14-recommended-stages-and-acceptance-tests)
15. [Risks and unresolved questions](#15-risks-and-unresolved-questions)
16. [Reproduction and evidence](#16-reproduction-and-evidence)

## 1. Executive answer

**Yes: a fold's immutable struct intermediate can be carried as
independent field values, materialized only where the whole value is
observed, and the existing machinery already holds almost every piece.**
The hypothesis survives the census, with two corrections and one hazard.

* **The gap is one missing slot kind, not a missing optimizer.**
  (*Implementation fact.*) hir/escape.tcl's struct scalar replacement
  already keeps a struct in field registers as a local, through an `if`
  join, across an exact return or argument, and around a self tail
  recursion (`fields` variants through `tail`). A fold's intermediate is a
  `param` binding of the iteration scope that none of its slot kinds
  (bound locals, instance parameters, instance results) covers, the fold
  node is no recognized construction, and every literal completing the
  body is consumed by the loop -- census reason `control`. Probe E shows
  the one difference: the same two-field struct is virtual in all five
  existing positions and materialized only at the fold's back edge.
* **The measured benefit is the whole gap.** (*Observation*, the NIR
  experiment: the compiler's own NIR with the struct registers of the fold
  rewritten as field registers, validated and run by the driver.)

  | workload | today | field registers | equivalent recursion |
  |---|---:|---:|---:|
  | scanner (6 fields), instructions/run | 137,933 | 28,944 | 25,524 |
  | scanner, struct allocations | 161 | 1 | 0 |
  | chunk fold at 16,384, instructions/run | 336,048,202 | 33,816,936 (with `done` a plan) | 33,088,667 |
  | chunk fold at 16,384, List elements copied | 18,124,480 | 65,761 | 65,760 |
  | consumed MutableVector fold at 16,384, instructions/run | 19,869,429 | 2,341,861 | -- |

  Field registers close 97% of the scanner's gap to its recursion, and
  field registers with `done` carried as a plan close 99.8% of the chunk
  fold's; the remaining few percent are the final struct, the loop latch
  and register moves, not field representation (section 4).
* **Correction 1: struct scalar replacement and field-level construction
  are two optimizations, and the second needs the first.** Field registers
  alone leave the chunk fold's List copying untouched (336M to 317M
  instructions; 18,124,480 elements copied either way). A List field
  becomes a plan only once it lives in a register of its own: a plan
  cannot live inside a heap struct (nir.rs's `validate_plans` admits a
  plan register only as a `construct` piece, a move into another plan
  register, a plan argument or a plan result), so Approach B is ruled out
  and Approach A is the only form that composes.
* **Correction 2: register carrying is not free of regressions.** A body
  that hands the whole intermediate to an open call every iteration and
  completes with the intermediate itself allocates nothing today (one
  object, passed around) and would rebuild the object every iteration as
  fields (Probe D's `d-identity-materialize`: 2 struct allocations become
  1,025). And a fold the consumption leaves copying shares its struct
  intermediate whole at every iteration's start, which as fields costs a
  materialization *and* the share's own struct (Probe C's `c-vec-continue`:
  21,847 become 32,769). The eligibility rule must exclude a materializing
  use on a path that completes with the intermediate unchanged (section
  7.4), and the whole-struct share must be lowered field-wise (section 9).
* **The hazard: the back edge is a parallel move.** Today's projection of
  a virtual binding returns the field register itself, so a completion
  `P {a: s.b, b: s.a}` lowered as sequential moves into the carried
  registers would overwrite `a` before `b` reads it. Neither existing
  position has the problem (an `if` join writes fresh registers; a tail
  call passes its arguments at once). `d-exits.bot`'s `swap_pure` pins it.
* **Value semantics need no new proof.** (*Implementation fact.*) A struct
  is immutable and has no observable identity (`==` and hashing are
  structural, STRUCTS.md "Equality"; no registered native observes an
  object's identity), and the carried registers are written only by the
  move that ends a normal completion (`continue` jumps past it, `break`
  and exhaustion read it), so `continue`'s and `break`'s rollback,
  independent observation of earlier versions and error exits hold by
  construction -- the experiment preserved the value of every one of the
  40 probe functions on the driver, also under GC stress. The proofs that
  *are* needed are the shape fact, the use verdict, the no-loss rule, the
  parallel back edge and, for a plan field, per-iteration linearity of
  the field path.

**Recommendation** (*Judgment*): two milestones, in this order, both
extensions of existing analyses -- no new runtime object, NIR instruction
or HIR node:

1. **FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1: loop-carried struct scalar
   replacement.** A *fold slot* in hir/escape.tcl (the fourth slot kind,
   as hir/construction.tcl's plan fold was its fourth carrier), the fold
   node as a recognized construction (so a fold-valued function returns
   `retmulti` fields), `ClassifyIf` accepting a branch that is the
   intermediate itself, the eligibility rule of section 7.4, and native
   lowering's loop result handling widened from one register to N with a
   parallel back-edge move. Primary workload: the scanner.
2. **FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-2: field-level construction.**
   hir/construction.tcl's fifth carrier, the *plan field* of a virtual
   fold slot: per-iteration linearity of the field path, a projection of a
   plan field a plan source, a completion literal's field a plan position.
   Primary workload: `Chunks {done, current}`.

M1 must also lower the whole-struct share of a vector-bearing
intermediate field-wise (or decline such a slot): section 9 measured the
loss otherwise. General aggregate scalar replacement is not recommended
(section 12).

## 2. Current state

(*Implementation facts*, unless marked.)

| mechanism | document | what it does for a fold today |
|---|---|---|
| fold lowering | FOLD-LOOPS-MILESTONE-1.md | the intermediate is one loop-carried register (`LoopResultStart`, `LoopResultBind`, `LoopResultAdd`, `LoopResultFinish`, a `fold` mode of the `loops` entry `break` reads); scalars need nothing more |
| plan fold | FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md | a String/List intermediate, linear per iteration, is a construction plan in that register (hir/construction.tcl's fourth carrier) |
| consumed fold | CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md | a collection-bearing intermediate (a struct of vectors included) skips its entry copy where no `continue`/`break` can follow a give-away (hir/mutvec.tcl's `FoldExitsClean`) |
| struct scalar replacement | STRUCT-SCALAR-REPLACEMENT.md, VALUE-TRANSPORT-MATERIALIZATION.md | a struct local, `if` join, exact return or argument and self-tail parameter in field registers, materialized lazily and once per dominating scope; nothing for a fold |
| `std::list::flat` | LIST-FLAT-MILESTONE-1.md | consumes a materialized List; not involved |

So after the three fold milestones, a fold's *scalar* intermediate, a
*List/String* intermediate and the *headers* of a vector-bearing struct
intermediate are all handled. What is left is the enclosing struct object
of a struct intermediate and the immutable List fields inside it -- the two
workloads below.

## 3. Representation trace

The scanner's fold (`audit/fold-loops/workloads/scanner-fold.bot`,
function `scan`): `fold with intermediate s Scan {...}:`, six Int fields,
an `if`/`elif` chain whose six leaves are `Scan {...}` literals, a `break`
at the end of the text.

### Required artifact: the representation map

| stage | representation of the intermediate and its successors | fields individually accessible | whole struct must exist | fields could be plans / consumed values | what prevents carrying fields into the next iteration |
|---|---|---|---|---|---|
| surface (surface/parser.tcl `Fold`) | a `loop` AST node with `fold {name nameSpan initial}`; completions are struct-literal ASTs | yes (syntax) | no | n/a | nothing |
| HIR (hir/resolve.tcl `BindFold`) | `foldBinding`: a fresh `param` binding of the iteration scope; `foldInitial`: a `struct` node; the body's trailing `if` chain ends in `struct` nodes; reads are `project(ref s, f)` | yes: `project` nodes | no: HIR has value semantics and no identity | n/a | nothing |
| types (hir/types.tcl `FoldBody`) | `{nstruct Scan}`, the join of the initial value and every completion | -- | no | -- | nothing |
| hir/mutvec.tcl elaboration | unchanged for Int fields; a vector-bearing struct gets an entry share by *struct* descriptor (`mutable_vector#share(s, "s1.1.h")`) unless consumed | -- | the share takes the object | consumed headers: decided here (`FoldIncoming`, `ExclusivePositions`) | a whole-struct share in copying folds (section 9) |
| hir/escape.tcl | slots are `bind` locals of kind `local` (`RawLocalArities`), instance parameters (`RawParamArities`), instance results (`Arities`/`Exits`); the intermediate is none of these; `Classify` of a loop node is `""`; the literals' consumer is the loop: census `materialized (control)` | -- | **yes, decided here** | -- | **no fold slot kind; a fold is no construction; `ClassifyIf` has no branch that is a reference to a virtual binding** |
| hir/construction.tcl | a plan fold needs a String/List intermediate (`RefFamily`); a struct is "flat: not String/List-typed"; a struct literal's field is a barrier ("other (struct)"); a projection is no plan source (`Source`) | -- | -- | **no field-level carrier** | the List fields of the chunk workload |
| native/lower.tcl | `LoopResultStart`: the initial value by `Expr` (`structnew`) into one register; `LoopResultBind`: `{reg R}`; each leaf `Struct` a `structnew`; each `if` one join register; `LoopResultAdd`: one `move`; `break`/exhaustion: `move` of the register (`FoldValue`) | through `structget` | yes | no | `accReg` is one register by construction |
| NIR (`scan`) | `%15`: 7 `structnew` sites (6 leaves, the initial value), 40 `structget`, a chain of 6 join `move`s up to the back edge `%15 = move %26` | `structget` | yes | no | -- |
| runtime | `rt_struct_new` copies the fields into a boxed slice and `Vm::alloc` boxes a `StructObj {hdr, shape, len, ptr}`: two heap allocations per struct, freed by the collector | memory loads | yes | -- | -- |
| GC | one root (the pointer) per live struct register; every `structnew` is a safepoint (13 in `scan`) | -- | -- | -- | -- |

**Architectural limitation or missing recognition?** (*Judgment.*) Every
row below hir/escape.tcl only executes its decision: lowering already joins
N field registers at an `if` (`If` with `virtualN`), already carries fields
through a self tail call, and nothing in NIR, Cranelift, the runtime or the
collector needs a new concept for N loop-carried registers (the plan fold
and the collecting loop already carry registers across back edges). The
limitation is missing recognition in hir/escape.tcl plus the one-register
assumption of `LoopResult*`.

The NIR of one leaf and the back edge today (`scan`, constants left out):

```
  label L10                              ; elif ident_char?(c)
    %49 = call 2 %0 %16                  ; text.ident_end(p)
    %50 = structget 1 %15                ; s.idents
    %53 = op iadd %50 %51
    %54 = structget 2 %15                ; s.ints ... s.deepest: read back
    ...                                  ;   from the object only to be
    %58 = structnew 0 %49 %53 %54 %55 %56 %57   ; copied into a new one
    %48 = move %58
    ...
  label L8
    %15 = move %26                       ; the back edge: one pointer
```

and of the experiment's field registers (`tools/nir-sra.tcl`, the same
leaf; `%126` .. `%130` are carried field registers):

```
  label L10
    %49 = call 2 %0 %16
    %50 = move %126                      ; s.idents: a register
    %53 = op iadd %50 %51
    %54 = move %127                      ; s.ints .. s.deepest
    ...
    %151 = move %49  ...  %156 = move %57    ; the literal's six fields
    %157 = move %151 ... %162 = move %156    ; the if join's six registers
    jump L12                                 ; no object built
```

## 4. Scanner analysis

(*Observation.* Instructions per run are callgrind's, the difference of a
4- and a 24-run profile of `botlish-native bench` on the program's NIR
(`tools/measure.tcl`); three repetitions of one row varied by under 1%, so
differences below about 300 instructions are noise. Rows dominated by the
collector vary more: a copying row of Probe C measured 1,440,879,064 and
1,510,326,282 in two runs. The earlier milestone used the standalone
executable; its numbers are quoted where compared.)

`results/probe-a.txt`:

| program | Struct allocations | instructions/run | allocator | generated code |
|---|---:|---:|---:|---:|
| 6 fields: fold (FOLD-LOOPS-MILESTONE-1.md measured 137,280) | 161 | 137,933 | 59.5% | 19.9% |
| fold, `Scan` in field registers | 40 | 56,442 | 39.2% | 44.8% |
| fold, `Scan` and `Number` in field registers | 16 | 38,659 | 22.1% | 64.4% |
| fold, both, and `number_at`'s fold value returned as fields | **1** | **28,944** | 3.3% | 85.0% |
| tail recursion (measured 25,192) | 0 | 25,524 | 2.1% | 87.4% |
| MutableArray cells (measured 56,437) | 0 | 58,774 | 35.7% | 44.0% |
| 4 fields: fold / fields / recursion / cells | 161 / 1 / 0 / 0 | 137,530 / 27,936 / 24,264 / 52,796 | | |
| 2 fields: fold / fields / recursion / cells | 161 / 1 / 0 / 0 | 134,555 / 25,528 / 22,657 / 49,755 | | |

* **The struct allocations are the gap, and the cost does not depend on
  the width.** 161 structs per run at every width (122 `Scan`: the initial value
  and 121 completions; 39 `Number`: 15 calls' initial values and 24
  digits; `native::allocationReport`'s sites); 2, 4 and 6 fields cost
  within 2.5% of each other. Per struct: (137,933 - 28,944) / 160 = 681 instructions,
  of which about 510 are the allocator (two `malloc`s and two `free`s:
  `rt_struct_new`'s boxed slice and the object), about 40 the collector,
  the rest `rt_struct_new` and the `structget` loads.
* **`number_at` matters as much as `scan`.** Its fold carries `Number`
  per digit, and its *value* leaves the function: with `scan` alone
  scalar-replaced 40 structs remain (56,442 instructions); `number_at`'s
  fold in registers leaves 16, materialized at its `ret` (38,659); only a
  fold value that crosses the return as `retmulti` fields -- the existing
  return transport, applied to a function whose result is a fold -- removes
  them (28,944). So M1 must make a fold a recognized construction, not
  only its intermediate a slot.
* **What remains is not representation.** The field-register `scan` has
  exactly the recursion's arithmetic: 4 `runbox`, 3 `rbox`, 5 raw and 5
  tagged arithmetic operations in both, and no `structget`. It differs in
  `move`s (159 against 8: the `if` chain's join registers, which Cranelift
  coalesces), the fold's loop latch (FOLD-LOOPS-MILESTONE-1.md measured 3
  instructions per iteration for a counted loop against a tail call) and
  the final `Scan` the program reads (1 allocation; the recursion's result
  crosses as `callmulti`). The residual 3,420 instructions (13%) are those.
  Tag conversions and checks are the same in both: an intermediate has no
  proven range, and neither has a recursion's parameter here.
* **Code size shrinks**: 4,682 to 3,747 bytes for the whole program
  (recursion 3,375).

Width and spills (`results/probe-a-width.txt`: `economics/spill-W.bot`, a
W-field fold whose body calls a recursive function first, so every field
is live across a call; 1,000 iterations):

| fields | today: instructions/run | as fields | ratio | saved per iteration | code bytes today / as fields |
|---:|---:|---:|---:|---:|---:|
| 2 | 806,961 | 129,774 | 6.2x | 677 | 1,065 / 961 |
| 4 | 898,556 | 222,756 | 4.0x | 676 | 1,833 / 1,745 |
| 8 | 1,082,703 | 410,911 | 2.6x | 672 | 3,345 / 3,329 |
| 16 | 1,544,606 | 778,320 | 2.0x | 766 | 6,329 / 7,025 |
| 32 | 2,294,894 | 1,507,650 | 1.5x | 787 | 12,681 / 14,049 |
| 64 | 3,832,474 | 2,956,750 | 1.3x | 876 | 25,265 / 27,929 |

* **Field registers win at every width measured**, spills included: the
  saving per iteration is the object (about 680 instructions, growing
  slowly with the fields copied into it); what shrinks is only its share,
  as the per-field work grows.
* **Code grows from 16 fields on** (+11% at 16, 32 and 64): spill and
  reload code for fields live across the call, against one pointer. No
  width cap is needed for speed; the existing local ceiling (16,
  VALUE-TRANSPORT-MATERIALIZATION.md) is a reasonable code-size cap, and a
  fold slot crosses no call boundary, so the argument-edge budget does not
  apply (section 6).

## 5. Chunk analysis

(*Observation*, `results/probe-b.txt`.) `chunks-fold.bot` carries
`Chunks {done: List[List[int]], current: List[int]}`; the earlier
milestones measured it at 16,384 tokens as 338,290,044 instructions and
18,124,480 elements copied, against the recursion's 33,006,534 and 65,760.

| N = 16,384 | Struct | Lists | elements copied | plan extensions | instructions/run |
|---|---:|---:|---:|---:|---:|
| chunk fold today | 16,384 | 26,687 | 18,124,480 | 16,383 (the token loop's) | 336,048,202 |
| fold, `Chunks` in field registers | 0 | 26,687 | 18,124,480 | 16,383 | 316,637,327 |
| fold, field registers, `done` a plan | 0 | 21,539 | **65,761** | 21,531 | **33,816,936** |
| tail recursion | 0 | 21,539 | 65,760 | 21,530 | 33,088,667 |
| MutableVectors | 0 | 13,584 | 62,958 | 31,361 | 36,157,897 |

and across sizes (instructions per run):

| N | fold | fields | fields + plan | recursion |
|---:|---:|---:|---:|---:|
| 128 | 406,763 | 271,398 | 248,221 | 243,689 |
| 1,024 | 3,481,648 | 2,386,631 | 1,999,090 | 1,964,064 |
| 4,096 | 22,812,339 | 17,941,782 | 8,021,143 | 7,901,936 |
| 16,384 | 336,048,202 | 316,637,327 | 33,816,936 | 33,088,667 |

* **Two costs, separable.** The struct allocations are linear (one per
  token: 135,000 instructions at 128 tokens, 19.4 million at 16,384 --
  1,185 per struct there, the collector working over a growing live set);
  the `done` copies are quadratic (16.0x per 4x tokens before, 4.0x
  after). Scalar replacement alone removes the first and leaves the
  second (84% of today's cost at 16,384); the plan removes the second.
* **Field registers plus a plan field reproduce the recursion exactly** in
  everything the runtime counts: 21,539 Lists, 2 plans, 65,761 against
  65,760 elements copied (the one-element difference is the experiment's
  exit, which extends the plan and then materializes it in two
  instructions where the recursion's `construct list flat %2 elem %3` does
  both). Instructions are within 2.2%.
* **`current` stays flat, as in the recursion.** It is read
  (`st.current == []`) and then appended on the same path, so it is not
  linear; the recursion copies it too (`op listappend %3 %16` in every
  `chunks_from` instance) -- it holds a handful of elements.
* **The recursion pays in specialization instead.** It compiles six
  instances of `chunks_from` (the `List[never]` combinations of its two
  List parameters; 11,651 bytes of code against the fold's 4,420, 180-224
  ms of lowering against 30-40 ms).

The reduced shapes (`b-wrap-fold`: one List field; `b-counted-fold`: a
List and a count, half the completions keeping the List):

| N = 4,096 | today | fields | fields + plan | direct List fold / recursion |
|---|---:|---:|---:|---:|
| wrap: instructions | 83,428,961 | 79,332,088 | 3,495,298 | 3,486,986 (direct fold) |
| wrap: elements copied | 8,394,750 | 8,394,750 | 16,378 | 16,378 |
| counted: instructions | 23,747,468 | 19,303,645 | 2,671,119 | 2,611,797 (recursion) |
| counted: elements copied | 2,104,319 | 2,104,319 | 12,283 | 12,283 |

At 16,384 the same holds at full scale: `b-wrap-fold` 1,651,660,144
instructions today, 1,637,121,930 with field registers, 13,824,958 with the
List a plan, against the direct List fold's 13,832,716 (134,242,302
elements copied, then 65,530, the direct fold's exactly);
`b-counted-fold` 408,840,131, 393,142,291, then 10,608,171 against its
recursion's 10,274,652 (33,583,103 elements copied, then 49,147, the
recursion's exactly).

A one-field struct around a List costs, with both milestones, what the
direct List fold costs (within 0.8% at every size): the struct adds
nothing once it is registers.

## 6. Existing virtual struct machinery

(*Implementation facts*; Probe E, `workloads/e-positions.bot`, one
two-field `P` per position, census and NIR read with
`native::structCensus`.)

| position | analysis (hir/escape.tcl) | lowering (native/lower.tcl) | Probe E |
|---|---|---|---|
| local bound to a literal, an `if` or a recognized call | `RawLocalArities` (shape), `Eligible`/`UseVerdict` (uses free, or lazily materializing in the binding's own innermost loop) | `{virtual FIELDS SHAPE ROOT MAT}` local; `Project` returns the field register; `MaterializeVirtual` builds once per dominating scope | local |
| `if` join | `ClassifyIf`: every value-producing branch ends in a construction of one descriptor | `If` with `virtualN`: N fresh join registers, `SequenceVirtual` per branch | local |
| exact return | `Arities` over `Exits` (a self-tail exit is a back edge, skipped) | `CompanionFunction`: `retmulti`; the caller's `callmulti` | return |
| exact argument | `RawParamArities` (every exact call site proves the shape), budgeted by hir/transport.tcl | `fields` variant (`pnames="p.0 p.1"`), `CallArgs`/`CanSupplyFields` per site | call |
| self tail recursion | a parameter slot on a call-graph cycle: `cyclic`, scored `3 x W` against a budget of 20 | the `fields` variant's `tail %0 %14 %3 %15`: a parallel transfer of the fields | call |
| **fold back edge** | **none** | **one register** | **materialized (control)** |

Limits of the existing machinery that matter for a fold:

* `Classify` recognizes a struct literal, an `if`, a syscall/layout/
  write-back result, a `list` call and an exact call of a recognized
  instance. It never recognizes a `ref`, so `if c: s else: S {...}` -- a
  branch completing with an existing virtual value -- is no join today
  (the chunk fold's first branch is exactly that).
* A struct *parameter* never materializes inside its callee (each call
  would allocate); a local materializes lazily, but only where it runs as
  often as the binding (`UseVerdict`'s `loop` rule). The fold
  intermediate is bound once per iteration, so a materialization in the
  body runs once per binding: the local rule applies, with the fold as the
  binding's loop (`ParentsAndLoops` already gives every body expression the
  fold as its innermost loop).
* The transport budget's cycle term was calibrated for argument edges
  (stack operands at calls). A fold slot crosses no call boundary of its
  own: its cost is register pressure inside one function, which the
  `local` ceiling (16) and the width measurements above address.
* `mutable_vector#share` of a virtual struct has no field-wise lowering:
  it is a native use that materializes (section 9).

## 7. Loop back edges: the missing representation and proof

### 7.1 The representation

A fold slot is the fold's intermediate binding with a descriptor `{N SHAPE
?CUT?}`. In lowering (*Judgment*, every piece an existing one widened):

* `LoopResultStart`: the initial value's fields (`VirtualValue`) moved
  into N fresh carried registers; an initial value that is a physical
  object (a parameter, a call result nothing recognizes) is opened with N
  `structget`s once, before the loop.
* `LoopResultBind`: the intermediate bound as `{virtual CARRIED SHAPE ROOT
  ""}` -- the virtual local entry, so projections, aliases, forwards and
  lazy materialization work unchanged.
* `LoopBody`: the body's value lowered by `SequenceVirtual` (the `if`
  join's lowering).
* `LoopResultAdd`: a **parallel** move of the N completion registers into
  the N carried registers (section 7.3).
* `LoopResultFinish` and `break`: the fold's value is the carried fields
  -- handed on as fields where the fold is itself a recognized
  construction (bound to a virtual local, an exit of a `retmulti`
  instance), materialized once otherwise (`FoldValue`'s role).
* `continue`: unchanged (a jump to the head skips the move).

### 7.2 The proof: what hir/escape.tcl must establish

| obligation | why | how (existing pieces) |
|---|---|---|
| **shape**: the initial value and every normal completion classify to one descriptor, or are the intermediate itself | every value entering the carried registers must be N fields of one shape | `Classify` for the initial value, `ClassifyIf` over the completions (`TrailingPositions`/`FoldIncoming`'s notion of a completion), plus the new identity branch; a growth fact, computed with `RawLocalArities` |
| **uses**: every reference to the intermediate is free (a projection, a completion, a forward to a slot of the same descriptor -- an exact callee's `fields` parameter, an inner fold's initial value) or lazily materializable | the fields are registers; a use that needs the object builds it | `UseVerdict` with the fold as the binding's loop; a shrink fact in `Eligible` |
| **no capture** | a nested function would read the binding after the iteration | the existing `captured` exclusion of `RawLocalArities` |
| **no loss** (section 7.4) | a materialization per iteration where today there is none | a path condition: no materializing use on a path that completes with the intermediate unchanged |
| **the fold as a construction** | the fold's value is the carried fields at exhaustion and at each bare `break` | `Classify` of a fold node: its slot's descriptor (a shape fact only: section 15's monotonicity note) |

### 7.3 The parallel back edge

(*Implementation fact.*) `Project` on a virtual binding returns the field
register itself, without a copy; `StructFields` puts it into the literal's
field list as is. In an `if` join every branch writes fresh `NewRegs`; in a
tail call `tail` transfers all arguments at once. A fold back edge would be
the first place where a completion's fields may *be* the carried registers:
`P {a: s.b, b: s.a}` gives the field list `{C1 C0}`, and the moves `C0 =
move C1; C1 = move C0` leave `{1, 1}` where `{1, 0}` is right
(`d-exits.bot`'s `swap_pure`). `LoopResultAdd` must copy through
temporaries whenever a source is a carried register written earlier in the
same move set (or simply always, and let Cranelift's SSA construction
remove the copies). The experiment does not exercise this: the compiler's
NIR reads fields with `structget` into fresh registers.

### 7.4 When not to carry fields

(*Observation*, Probe D.) Field registers change *where* objects are built:
today one per constructing completion plus the initial value; as fields, one
per materializing use, plus one at the exit if the fold's value is needed
as an object.

| path of an iteration | allocations today | as fields |
|---|---:|---:|
| constructs its successor, no whole use of the intermediate | 1 | 0 |
| constructs, and uses the intermediate whole (stored, `==`, an open call) | 1 | 1 |
| completes with the intermediate itself, no whole use | 0 | 0 |
| completes with the intermediate itself **and** uses it whole | **0** | **1** |

The last row is `d-identity-materialize.bot` (an open call `f(s)` every
iteration, `s` completing all but the last): 2 struct allocations today,
1,025 as fields. A whole-struct share at every iteration's start (a fold
the consumption leaves copying) is the same loss in another form (section
9). Three rules keep every program at or below today's count
(*Judgment*):

* decline a fold slot with a materializing use on a path that completes
  with the intermediate unchanged (a path condition over the body, the
  same walk shape as `FoldWalk`'s one bit), and
* require at least one constructing completion (else nothing is saved, and
  the exit materialization of a value that came in as an object is a loss),
  and
* lower a share of the intermediate by struct descriptor field-wise (or
  decline the slot).

The initial value's allocation, saved when it is a literal, pays for the
exit materialization. A later refinement can carry the materialized object
itself as a second, maybe-object register (unit until built, kept by an
unchanged completion, dropped by a constructing one) -- VALUE-TRANSPORT-
MATERIALIZATION.md's pending objects carried around the loop -- which would
admit the excluded case; M1 does not need it.

## 8. Construction-plan interactions

(*Observation*, `-plan-field` of the experiment; *Judgment* for the
design.)

**Approach A -- scalar-replace the struct, then let a List field be a plan
in its own register -- works, and composes with nothing new.** The
experiment marks `done`'s carried registers `planregs`, turns `op
listappend` of them into `construct list plan`, hands the plan on through
the field moves and reads it flat (`construct list flat`) where it leaves:

```
  label L9                               ; Chunks {done: st.done.append(st.current), current: []}
    %20 = move %55                       ; st.done: the carried plan register
    %21 = move %56                       ; st.current: flat
    %22 = construct list plan %20 elem %21
    ...
    %55 = move %61                       ; the back edge (a plan register)
  label L15                              ; after the fold: c.done.append(c.current)
    %52 = construct list plan %50 elem %51
    %72 = construct list flat %52        ; the one materialization
```

The driver's `validate_plans` accepted every experiment program (its
"may have been consumed" dataflow over the back edges) and the values are
identical. What M2 needs in hir/construction.tcl:

* **A fifth carrier, the plan field** `(fold, F)`: a String/List field F of
  a fold slot hir/escape.tcl made virtual (construction already runs after
  the escape analysis and reads it: `virtualArity`), linear per iteration.
* **Linearity of a field path.** A reference to the intermediate counts for
  F when it is projected to F or used whole (a whole use reads every field:
  an identity completion passes F on, a materialization reads it flat); a
  projection to another field does not; `continue` and a bare `break`
  count for every field, as `FoldLinear` counts them for the whole
  intermediate. One walk of the body can return a count per List field
  (`Uses`/`SeqUses` with a vector instead of a number), not one walk per
  field (section 13).
* **Source and Context cases.** `project(ref s, F)` of a plan field is
  plan-producing; a struct literal's field F is a plan position when the
  literal is a completion (or the initial value) of that fold; anything
  else stays a barrier.
* **Lowering**: the virtual local entry carries a family per field;
  `Project` of a plan field in a plan position is `{span REG}`, elsewhere
  `construct ... flat`; the carried registers of a plan field are declared
  plan registers.

**Approach B -- a plan held inside the struct object -- is excluded.**
(*Implementation fact.*) `validate_plans` rejects a plan register as an
operand of anything but `construct`, a move into a plan register, a plan
parameter's argument or a plan result's `ret`; a `structnew` operand would
put a private, mutable plan object into a heap value any later use could
observe or share. Making it legal needs a field tag, a materialization hook
on every struct read and the collector's cooperation: a fourth
construction mechanism, which the milestone's constraints forbid.

**Approach C -- a fold-specific state representation --** would have to
reproduce the descriptor, shape identity, lazy materialization, field
joins and return transport hir/escape.tcl and `native/lower.tcl` already
have; its one real fold-specific part, the parallel back edge, is a
few lines in `LoopResultAdd` either way. (*Judgment:* no.)

Whether a plan field changes field *independence*: no. A plan is extended
in place only as the first piece of a `construct ... plan`, and linearity
per field path is what makes it invisible; the other fields are ordinary
registers whatever F is.

## 9. Consumption interactions

(*Observation*, `results/probe-c.txt`; *implementation facts* as marked.)

| n = 16,384 | Struct | shares / detaches / elements copied | instructions/run |
|---|---:|---|---:|
| `{count, items}`, literal completion, consumed (today) | 16,385 | 0 / 0 / 0 | 19,869,429 |
| same, copying elaboration (`consumedFolds 0`) | 32,769 | 16,384 / 16,384 / 134,209,536 | 1,510,326,282 |
| same, consumed, fields in registers | 1 | 0 / 0 / 0 | 2,341,861 |
| `{count, items}`, completed by `a` itself, consumed | 1 | 0 / 0 / 0 | 2,135,582 |

| `{count, evens, odds}`, one vector pushed per iteration, consumed (today) | 16,385 | 0 / 0 / 0 | 19,876,300 |
| same, fields in registers | 1 | 0 / 0 / 0 | 2,068,048 |
| `{log: List, items: MutableVector}`, consumed (today) | 16,385 | 0 / 0 / 134,209,540 List elements | 1,470,794,138 |
| same, fields in registers | 1 | same List copies | 1,456,346,488 |
| same, fields in registers, `log` a plan | 1 | 0 / 0 / 32,768 List elements | 9,137,337 |
| `{count, items}`, `continue` after the push: not consumed (today) | 21,847 | 16,384 / 16,384 / 44,741,973 | 519,072,585 |
| same, fields in registers, the share left whole | **32,769** | 16,384 / 16,384 / 44,741,973 | **537,495,580** |

* **Consumption solved the copies; the struct is what is left.** With the
  vector consumed, the literal-completed fold costs 9.3x the fold that
  completes with `a` (19.9M against 2.1M instructions): one struct per
  iteration, about 1,070 instructions each at this size. In registers it
  costs what the `a` fold costs (2.34M against 2.14M).
* **Ownership is decided before representation, and representation does
  not disturb it.** (*Implementation fact.*) hir/mutvec.tcl's elaboration
  runs in the front end and writes its shares into the HIR
  (`ExclusivePositions` wraps each non-fresh completion field in a share);
  hir/escape.tcl and lowering run after it, on that HIR. A carried field
  register holds exactly the header the struct's slot held, moved by the
  same back edge. So `Fresh`, `Moved`, `ExclusivePositions`, `NoLaterUse`
  and `FoldExitsClean` stay the authority: no second ownership analysis,
  and decomposition can neither turn a consumed field into a shared one
  nor invent exclusivity (it adds no share and removes none).
* **The copying elaboration shares the whole struct, and carrying fields
  makes that worse.** (*Implementation fact.*) In a fold the consumption
  does not reach (`c-vec-continue`: a `continue` after the push), every
  iteration starts with `mutable_vector#share(s, "s1.1.h")`, and the
  runtime's `share_by` builds a new `StructObj` around the shared header.
  (*Observation.*) On a slot carried as fields that share is a native use
  of the whole value: the intermediate is materialized every iteration,
  and the share builds a second struct from it -- 32,769 structs and 3.5%
  more instructions at 16,384 (21,847 today: the share's struct every
  iteration and the literal on the third that completes; +14% at 1,024).
  Lowering the share field-wise (an `h` share of each header field
  register, the other fields as they are; it reads only the descriptor,
  which already names the slots) removes both structs. (*Judgment:* M1
  must do that, or decline a fold slot whose intermediate is shared whole
  -- it is not optional.)
* **Mixed fields compose.** `c-mixed` (an immutable List that grows and a
  MutableVector that is pushed): 1,470,794,138 instructions today at
  16,384, 1,456,346,488 with field registers, 9,137,337 with the List a
  plan as well -- the vector consumed, the List a plan, the struct gone,
  each by its own existing rule.

## 10. Control-flow correctness

(*Observation*: `results/probes.txt`. Every probe function's value is
equal on the interpreter, the Tcl compiler, cranelift-generic and
cranelift, equals the probe file's `# expect:` line (values checked by
hand), and the experiment's field-register NIR returns the original NIR's
value on the driver, also under `BOTLISH_NATIVE_GC_STRESS=1`. In today's struct census almost every construction
of these files is `materialized (control)`; `results/probes.txt` lists
each file's census.)

| case | probe | proof obligation |
|---|---|---|
| every completion a literal | `d-exits` `plain` | shape fact |
| `continue` before a successor | `continue_first` | nothing: the jump skips the back-edge move |
| successor computed, then `continue` | `continue_after_candidate` | the candidate's fields are in fresh registers; the carried registers are written only by the completion's move |
| successor computed, then bare `break` | `break_after_candidate` | `break` reads the carried registers, never a candidate |
| partial update, a field carried unchanged | `partial` | a field's value may be the carried register itself |
| the intermediate as one branch's completion | `identity_branch` | the identity completion is free (a move of each register onto itself) |
| no domain, ended on a field | `no_domain` | the condition reads a carried register |
| fields permuted | `swap`, `swap_pure` | **the parallel back edge** (section 7.3) |
| the successor built by a helper function from the intermediate | `helper` | the completion is a call: a recognized result (`retmulti`) whose argument forwards the slot to a `fields` parameter -- both existing transports |
| earlier versions retained in a List | `d-observe` `history` | a whole use materializes; immutable, so the retained object never changes |
| old and new version in one record | `both_versions` | independent observation: nothing mutates either |
| exact callee and function value | `calls` | an exact `fields` callee is a free forward; the open call materializes |
| captured by a nested function | `captured` | the slot is declined (`captured`) |
| `return s` mid-fold | `early` | the register dies; the return materializes (or returns fields from a `retmulti` instance) |
| `==` of the intermediate | `compared` | equality materializes (a hard boundary) |
| error after the candidate, handled outside | `d-errors` `raised` | the fold has no value; registers die |
| error handled in the body | `handled` | the handler's value is an ordinary completion |
| a handler that `continue`s after a candidate | `skipped` | as `continue` |
| inner fold seeded with the outer intermediate, its value the outer's next | `d-nested` `seeded` | a forward into another fold slot of the same descriptor; the inner fold's value a construction |
| inner fold seeded with a field | `field_seeded` | a projection |
| the intermediate in an inner loop's body | `inner_loop` | a projection runs per inner iteration (free); a whole use there is the `loop` rule's |
| a struct-valued fold as a result | `digits` | the fold as a recognized construction |
| a `yield` in the body: the intermediate live across each suspension | `d-coroutine` | registers across a suspension (the coroutine's stack, or a fused coroutine's registers): nothing new |
| anonymous, nested, generic, callable-field, one-field, domain-typed field | `d-shapes` | descriptor `{N {ID LAYOUT}}`; a nested struct is one field unless a cut opens it; a refined field keeps its type (no representation change) |
| whole use on an identity path | `d-identity-materialize` | **section 7.4's rule** |

Allocation totals per probe file (today -> experiment): d-coroutine 4 ->
0, d-errors 14 -> 0, d-exits 69 -> 18, d-nested 19 -> 4, d-observe 57 ->
51 (most of its uses need the object), d-shapes 28 -> 4, e-positions 9 ->
0, d-identity-materialize 2 -> 1,025. `d-exits`' 18 are one
materialization per fold function where its value is stored into the
program's List, and `helper`'s 9 (its initial value and 8 `advance`
results): a carried register defined by a call is outside the NIR
experiment's reach; M1's `Classify` of the call and `advance`'s `retmulti`
companion are the existing transports for it.

**Why `continue`, `break` and errors need no new rule** (*Implementation
fact* about today's lowering, carried over): the fold's carried register is
written in exactly one place, the move `LoopResultAdd` emits at the end of
a normal completion; `continue` (`jump $head`) bypasses it, `break` moves
the carried register (`FoldValue`), an error or `return` leaves the
function's frame. Carrying N registers instead of one keeps all three
properties as long as the N moves stay in that one place. Eligibility is
therefore not inferred from the absence of `break` or `continue`, and none
of the rows above is declined for having one. The struct being immutable
is what makes this free; the plan field (M2) is mutable in place and needs
linearity exactly as a plan fold does.

## 11. GC and resource lifetimes

* **Roots.** (*Implementation fact.*) A virtual field is an ordinary tagged
  NIR register, rooted by safepoint liveness like every register (stack
  maps on native-frame hosts, shadow slots on the fallback plan);
  STRUCT-SCALAR-REPLACEMENT.md's GC section applies unchanged, and a plan
  field is a plan register, rooted as the plan fold's. Nothing is hidden
  from the collector: a field that holds a heap reference is a root while
  live, and a materialization is an allocation with its operands live.
  (*Observation*, the driver's `roots` report:) `scan`'s maximum live
  roots go from 8 to 9 and its shadow slots from 8 to 10; its safepoints
  fall from 13 to 7 (every `structnew` was one). The chunk fold: 8 and 8
  before and after, safepoints 17 to 15.
* **Lifetimes.** Each field register is live until its own last use; a
  field read only by the next iteration's projection stays live across the
  back edge, as the whole object did. Abandoned candidate fields die where
  their registers do.
* **Coroutines.** A register live across a `yield` is saved with the
  coroutine's stack, or kept in a fused coroutine's registers (COROUTINE-
  FUSION-MILESTONE-1.md); N registers instead of one pointer are more of
  the same, no new mechanism. (*Observation*: `d-coroutine.bot`'s
  experiment NIR gives the same value fused and unfused
  (`BOTLISH_NATIVE_COROUTINE_FUSION=0`), with and without GC stress, its
  4 struct allocations becoming 0.) A fold intermediate across `yield` is
  an acceptance test for M1.
* **Affine values.** AFFINE-FOLD-UNSUPPORTED keeps every affine struct out
  of a fold intermediate (affinity is compositional), so a fold slot has no
  drop descriptor and no release of its own; nothing here touches it.
  Affine values that die inside the body are released after their
  statements by `SequenceStatements`, which every sequence form now uses:
  **the gap FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md section 12 left
  open for `SequenceRaw`, `SequenceShort` and `SequenceVirtual` was closed
  on main by commit `5c810a7d` ("release what dies after the statements of
  every sequence form", tests/resources/forms.bot)** -- verified, not
  re-reported; `SequenceVirtual` is the body lowering M1 would use.
* **Errors and returns.** The registers die with the frame; `return s`
  materializes as any return of a virtual local does.

A finding of the probe tooling, not of the compiler (*Observation*): the
NIR validator (nir.rs's `validate_selected`) checks structure but not that
a register is defined on every path to a use. An early version of the
experiment read an undefined register; `botlish-native check` accepted the
NIR and the run crashed (SIGSEGV). The compiler never emits such NIR, but a
NIR-to-NIR pass (coroutine fusion validates its output with
`validate_function`) is only as safe as that check; severity low, noted
for whoever next writes a NIR pass.

## 12. Architectural alternatives

| | (1) fold slot in the struct scalar replacement + plan field | (2) plan inside the struct object | (3) fold-specific state | (4) general aggregate SRA (NIR pass) |
|---|---|---|---|---|
| semantic correctness | value-preserving by construction (immutable, identity-free) + parallel move; plan field by linearity | needs a plan observable through a heap object: no | as (1) | value-preserving for a register web of `structnew`/`move`; plans undecidable at NIR level without HIR linearity |
| reuse | descriptors, shapes, cuts, lazy materialization, `If` joins, `retmulti`, transport, plan carriers, `validate_plans` | little | duplicates (1)'s | NIR only; a second optimizer beside hir/escape.tcl |
| proof complexity | a shape fact, a use verdict, a path condition (7.4); per-field linearity for M2 | a new plan protocol | same as (1) | trivial for structs; cost policy needs source facts |
| plans | composes (Approach A) | the whole point, and the problem | composes | no |
| ownership | untouched (decided before) | untouched | untouched | untouched |
| control flow | the existing one-move discipline | same | same | automatic |
| GC/affine | registers; affine excluded | a new traced field kind | registers | registers |
| compile time | linear in the body per fold (section 13) | -- | similar | linear in NIR |
| code quality | Cranelift sees N registers | an object | as (1) | as (1), but no cross-function transport |
| beyond folds | the identity branch of `ClassifyIf` joins ordinary `if`s field-wise too; the slot kind serves any construct that carries a binding around a back edge | none | none | everything, which is the risk |
| expected benefit | scanner 137,933 -> ~28,944; chunks 336M -> ~33.8M | the chunk fold's copies only: a struct per iteration stays | as (1) | scanner ~38,659 (no return transport); chunks unchanged; regresses `d-identity-materialize` and `c-vec-continue` without a policy |
| risk | moderate: a fourth slot kind in a 3,148-line analysis | high | duplication | a second representation authority |

(*Judgment.*) Design 1 is the smallest sound architecture: every
correctness argument is one that hir/escape.tcl and hir/construction.tcl
already make for another slot or carrier, and the evidence is that the
NIR it would produce runs within 2-13% of the recursions everywhere
measured.

On design 4: the experiment *is* a general NIR-level SRA for struct webs,
and it is instructive why it should stay an experiment. It cannot create
`retmulti` companions (40 -> 16 structs instead of 1 for the scanner
without hand help), cannot decide a plan field (it needs the source's
linearity; `validate_plans` can only reject), has no notion of the cost
policy of section 7.4 (it regresses `d-identity-materialize` 500x), and it
would make NIR a second place where representation is decided, against the
architecture in which hir/escape.tcl is the single authority and NIR the
checker. Its value is as an oracle: the allocation counts it produces are
the targets M1 and M2's tests can assert.

A cheaper `structnew` (one allocation with inline fields instead of two)
is orthogonal: it would roughly halve the 510 allocator instructions per
struct, but every iteration would still allocate, and the chunk fold's
quadratic copying is untouched.

## 13. Compiler economics

(*Observation*, `results/economics.txt` and `results/backend-time.txt`:
best of 5 runs; "escape" is `hir::escape::analyze`, "construction"
`hir::construction::analyze`, both inside the lowering's time; "verdicts"
the `UseVerdict` calls of one lowering; "after" the experiment's rewrite of
the same NIR. Times are wall-clock on a shared 4-core container, one
callgrind job beside them: read differences under 10-15% as noise.)

| program | front end ms | escape ms | construction ms | verdicts | lowering ms | NIR | code bytes before / after | max live roots / safepoints before / after | Cranelift ms before / after |
|---|---:|---:|---:|---:|---:|---:|---:|---|---:|
| width-2 (one fold, 2 fields) | 19.7 | 0.6 | 0.3 | 1 | 7.7 | 47 | 1,317 / 1,197 | 7/8 / 7/6 | 1.9 / 1.9 |
| width-16 | 55.9 | 2.4 | 1.1 | 1 | 32.4 | 173 | 6,669 / 6,581 | 21/50 / 21/48 | 5.9 / 5.8 |
| width-64 | 213.7 | 9.3 | 3.9 | 1 | 145.3 | 605 | 25,173 / 27,045 | 69/194 / 69/192 | 23.3 / 35.3 |
| nested-1 (struct folds nested) | 25.4 | 0.8 | 0.3 | 1 | 11.8 | 55 | 1,517 / 1,333 | 8/9 / 9/7 | |
| nested-3 | 50.8 | 1.4 | 0.7 | 1 | 19.1 | 133 | 3,709 / 3,677 | 16/23 / 23/17 | |
| nested-5 | 158.2 | 2.3 | 1.1 | 1 | 33.9 | 211 | 6,261 / 5,901 | 24/37 / 37/27 | 5.6 / 5.7 |
| many-10 (struct folds in one function) | 106.8 | 5.4 | 2.5 | 1 | 71.7 | 540 | 13,533 / 11,133 | 8/83 / 9/53 | 11.6 / 9.3 |
| many-40 | 409.4 | 27.1 | 12.0 | 1 | 331.1 | 2,100 | 51,005 / 43,109 | 8/323 / 9/203 | |
| many-80 | 835.6 | 64.7 | 25.4 | 1 | 704.9 | 4,180 | 100,669 / 86,717 | 8/643 / 9/403 | 115.7 / 129.5 |
| locals-10 (struct locals: the control) | 68.6 | 4.2 | 0.8 | 10 | 35.7 | 56 | 453 / 453 | | |
| locals-80 | 401.0 | 37.6 | 7.4 | 80 | 314.7 | 336 | 455 / 455 | | |
| scanner-fold | 88.9 | 4.4 | 2.2 | 0 | 77.4 | 286 | 4,682 / 3,778 | (scan: 8/13 / 9/7) | 6.7 / 5.1 |
| chunks-fold | 53.7 | 2.1 | 1.1 | 0 | 33.6 | 200 | 4,420 / 4,164 | | 5.1 / 4.9 |
| tests/golden/fold-loops.bot (70 folds) | 18,085 | 128.8 | 61.0 | 59 | 4,861 | 6,028 | 129,022 / 129,232 | | 127.0 / 129.3 |

What the measurements say (*observations*):

* **The analyses a design would extend are linear in what a fold
  contributes.** The escape analysis takes 0.6 to 9.3 ms from 2 to 64
  fields (one literal per fold, width in its descriptor only), 5.4 to
  64.7 ms from 10 to 80 folds (12x for 8x), and 0.8 to 2.3 ms from depth 1
  to 5. It is 3-12% of the lowering everywhere (the golden suite 2.6%); the
  construction analysis about half of that. Today a fold contributes no slot (`verdicts` 1, the
  program's own; the struct locals of `locals-K` give K verdicts, one
  `Eligible` round).
* **The front end, not representation, is what nesting costs.** Depth 1 to
  5 takes the front end from 25 to 158 ms (about 1.5x per level, 2x at the
  last), the fold typing's bounded fixpoint (`FoldBody`); representation
  analyses and lowering stay linear. Nothing proposed here touches the
  front end.
* **Field registers shrink the code of narrow state and grow wide state.**
  Code bytes fall 1-12% for up to 16 fields, 6-18% for nested and many
  folds (many-80: 100,669 to 86,717), are flat at 32 fields and grow 7% at
  64 -- and from 16 fields on where a call in the body forces spills
  (section 4's width table, +11%). Cranelift's time is neutral within
  noise, lower for the scanner (6.7 to 5.1 ms), higher at 64 fields
  (+52%) and for 80 folds in one function (+12%).
  The rewrite's NIR has up to 52% more instructions (the tool emits two
  move sets per completion; a lowering needs one), which Cranelift's SSA
  construction removes.
* **Roots trade pointer roots for field roots and remove safepoints.**
  Maximum live roots rise where several struct intermediates are live at
  once (nested-5: 24 to 37), barely elsewhere (many-80: 8 to 9); the
  safepoints fall by every `structnew` removed (many-80: 643 to 403).

Projected cost of the milestones (*Judgment*, from what each adds to
these walks):

* **M1** adds one slot per fold to `Eligible` (the `locals-K` row is the
  measured price of K slots: about 0.4-0.5 ms per slot at this size), no
  new classification walk (`Classify` already visits every literal for
  the census: 812 calls for many-80, today), one `UseVerdict` per fold over
  references `RegionInfo` already indexes, and one walk of each fold's
  body for the no-loss condition (the shape of hir/mutvec.tcl's
  `FoldWalk`). For many-80 that is on the order of 30-40 ms over today's
  65 ms of escape analysis, inside 705 ms of lowering. No new semantic
  instance or specialization key: representation only. No per-field walk:
  a field enters as the descriptor's width.
* **M2** adds plan-field candidates only for String/List fields of
  virtual fold slots (none in `width`, `nested`, `many`), each judged by
  one walk of its fold's body counting every List field at once.
  FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md's economics showed why that
  matters: a carrier whose linearity walks the whole function per
  candidate (`Linear`, plan locals) went superlinear at 40 candidates
  (33,078 walks, 96 ms); `FoldLinear`'s body walk did not. The plan field
  must take `FoldLinear`'s shape, never `Linear`'s.
* **Width** stays under the local ceiling (16) by default (section 15);
  at 64 fields compile time and code size are the costs to weigh, not
  run time.

## 14. Recommended stages and acceptance tests

### M1 -- FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1: loop-carried struct scalar replacement

Scope (*Judgment*):

1. hir/escape.tcl: a fold slot `{InstanceId FoldBindingId} -> DESC`, raw
   (shape) beside `RawLocalArities` and judged in `Eligible` with
   `UseVerdict` (the fold as the binding's loop); `Classify` of a fold node
   (its slot's shape fact); `ClassifyIf` accepting a branch that is a
   reference to the intermediate (and, generally, to a virtual binding of
   the same descriptor); the no-loss rule (7.4); census records for fold
   slots; `explain`.
2. native/lower.tcl: `LoopResultStart`/`Bind`/`Add`/`Finish`, `FoldValue`
   and `break` over N registers; the parallel back-edge move; the fold as a
   `VirtualValue` source; `-struct-opt 0` keeps one register.
3. The field-wise share of section 9 (`mutable_vector#share` of a virtual
   binding by a struct descriptor: an `h` share per header field
   register), or, failing that, a declined slot for an intermediate shared
   whole: `c-vec-continue` regresses otherwise.

Acceptance:

* Probe E: `fold_backedge`'s constructions classified virtual
  (`native::structCensus`), no `structnew` in its NIR.
* The scanner: Struct allocations 161 -> 1 (the program's final value), at
  most 115% of the recursion's instructions (measured target: 28,944
  against 25,524, the experiment's); the 2- and 4-field variants the same.
* Every Probe D file: the same value on the four backends and with
  `-struct-opt 0`; allocation counts at or below today's in every file
  (`d-identity-materialize` must stay at 2), and at or below the
  experiment's elsewhere; Probe C's rows at or below today's, with
  `c-vec-continue` at most its 21,847 structs (field-wise: 0 for the
  intermediate).
* `swap_pure` and a three-field rotation: the parallel move.
* A fold intermediate live across `yield` (fused and unfused), and the
  whole of `tests/fold-loops.test`, `tests/consumed-fold-intermediates.test`,
  `tests/struct-scalar-replacement.test` and `tests/value-transport.test`,
  also under `BOTLISH_NATIVE_GC_STRESS=1`.
* Mutants: a sequential back edge, a candidate written before a
  `continue`, `break` reading the candidate, the no-loss rule dropped, the
  identity branch accepted for a different descriptor, a captured
  intermediate admitted.
* A fuzzer that generates fold bodies over a struct intermediate (the
  probe shapes) and compares values and allocation counts with
  `-struct-opt 0` and with this census's `nir-sra.tcl` as an allocation
  oracle.

### M2 -- FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-2: field-level construction

Scope: hir/construction.tcl's plan field carrier (section 8): per-field
linearity in one walk, `Source`/`Context` cases, `foldFieldFamily` for
lowering; native/lower.tcl's per-field families in the virtual entry.

Acceptance:

* The chunk fold at 16,384: elements copied 18,124,480 -> at most the
  recursion's 65,760 (+1), instructions within 5% of the recursion
  (experiment: 2.2%); growth 4.0x per 4x tokens.
* `b-wrap-fold` within 1% of the direct List fold at every size;
  `b-counted-fold` within 5% of its recursion; `c-mixed`'s List a plan with
  its vector consumed.
* Negative cases, each flat with its reason: the field read then extended
  (`current`), extended twice on one path, a whole use after an extension,
  `continue`/`break` after a materialized extension (the plan fold's
  `fvc-reject-*` shapes, per field).
* `validate_plans` on every test program; GC stress; the plan fold's
  mutants per field.

### Why two milestones, not one

(*Judgment.*) M2 cannot exist without M1 (a plan field is a field
register), and M1 delivers the scanner, the vector-bearing structs and
every fold of small state alone; M1 is validated by values and allocation
counts, M2 by copy counts and `validate_plans`, and their mutants are
disjoint. A unified milestone would make a regression in either
indistinguishable. Neither needs a separate prerequisite: no backedge join
mechanism is missing (the If join's N-register pattern is it), and no
field-level lifetime fact beyond registers' liveness is needed.

## 15. Risks and unresolved questions

* **The fold value as a construction and the analysis' monotonicity.**
  `Arities` (instance results) grows before `Eligible` shrinks. If a fold
  is a construction only when its slot is eligible, a result would depend
  on a shrink fact. Making the fold's construction a shape fact (initial
  value and completions) and letting lowering open a physical intermediate
  with `structget`s at the exit when the slot is declined keeps the order;
  the cost of that fallback is N loads, never an allocation.
* **Register pressure at width.** Measured to 64 fields with a call in
  every iteration (section 4): field registers still win (1.3x), but code
  grows about 11%
  from 16 fields on, as every field live across a call is spilled and
  reloaded. Whether a fold slot takes the local ceiling (16) or none is a
  code-size decision, not a speed one; the census recommends the ceiling
  for M1, as for any other local, and measuring again if a workload wants
  more. Bodies with many calls per iteration and wide state were not
  measured beyond this one shape.
* **Nested struct fields.** A field that is itself a struct literal is one
  field unless a cut opens it (VALUE-TRANSPORT-MATERIALIZATION.md's
  value-tree frontier). Whether a fold slot should take the class's cut
  decision or always keep inner structs closed is open; the probes'
  `nested` shape keeps it closed and still saves the outer object.
* **ClassifyIf's identity branch outside folds.** Accepting a branch that
  is a reference to a virtual binding is general: `p = if c: q else: P
  {...}` with `q` virtual would also join field-wise. That changes existing
  NIR (struct census classes of current programs); its effect on the
  corpus must be measured in M1.
* **The C backend** carries a struct as a C value already; nothing here
  changes it (`ccompile/` reads no escape analysis).
* **HIR interchange and the front-end cache** are untouched: the escape
  and construction analyses are native lowering's, outside the HIR and the
  cache key.

## 16. Reproduction and evidence

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
A=audit/fold-virtual-struct-state
bash $A/tools/run-all.sh probes   # results/probes.txt (four backends + experiment)
bash $A/tools/run-all.sh a        # results/probe-a.txt
bash $A/tools/run-all.sh w        # results/probe-a-width.txt
bash $A/tools/run-all.sh b        # results/probe-b.txt (the slow part)
bash $A/tools/run-all.sh c        # results/probe-c.txt
tclsh9.0 $A/tools/gen-economics.tcl
tclsh9.0 $A/tools/economics.tcl -runs 5 $A/economics/{width,nested,many,locals}-*.bot \
    audit/fold-loops/workloads/scanner-fold.bot audit/fold-loops/workloads/chunks-fold.bot \
    tests/golden/fold-loops.bot   # results/economics.txt
# one program by hand: its NIR, the experiment's rewrite, the driver
tclsh9.0 $A/tools/nir.tcl audit/fold-loops/workloads/scanner-fold.bot /tmp/scan.nir
tclsh9.0 $A/tools/nir-sra.tcl -functions "scan number_at" -return-fields number_at:1 \
    /tmp/scan.nir /tmp/scan-fields.nir
native/target/release/botlish-native run /tmp/scan-fields.nir --alloc summary
```

Measured on this container (Linux x86-64, 4 cores, Xeon, the release
native backend) at `0030f8a7`. Callgrind counts through the bench driver
repeat within about 1% (section 4); timings in the economics table are
best of 5 on a shared machine (one callgrind measurement ran beside them)
and are noisy.
