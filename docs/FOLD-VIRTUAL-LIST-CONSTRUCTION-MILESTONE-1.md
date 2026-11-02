# FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md

Virtual construction across fold intermediates: a fold whose String or List
intermediate the body only extends now carries it as a construction plan
(M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md), extended in place and materialized
once, exactly as the same List carried by a self tail call already was.

> An immutable List is a value, not necessarily an allocated object at
> every point in its computation. When successive versions of that value
> cannot be observed independently, construction may remain virtual until
> materialization is actually required.

## Outcome

* **Repeated-prefix copying is gone for eligible folds.** The direct List
  fold `fold x in xs with intermediate acc []: acc.append(x * 3 + 1)` at
  N = 16,384 copied 134,242,302 List elements and allocated 16,388 Lists;
  it now copies 65,530 and allocates 5 (and 2 private plans). Its
  instructions per run fall from 1,663,965,015 to 13,664,710 (122x), and
  they now grow 4.0x per 4x N, where they grew 20.8-32.7x.
* **The fold costs what the recursion costs.** The fold and the self tail
  call carrying the same List (list-recursive.bot) now allocate the same
  Lists and plans, make the same number of in-place extensions and
  materializations, and copy exactly the same number of elements at every
  size (a Tcl test pins the equality). Instructions per run are within
  2.1% (13,664,710 vs 13,386,116 at N = 16,384), as are the chunk
  workloads' (31,278,095 vs 31,059,104: 0.7%).
* **One mechanism, one more carrier.** No NIR instruction, runtime helper,
  heap kind, compiler pass or Rust change was added: hir/construction.tcl's
  existing fixpoint gained a fourth carrier, the *plan fold*, beside plan
  locals, plan parameters and plan results, and native/lower.tcl's loop
  result handling binds and materializes it with the existing plan
  machinery. HIR, types, specialization keys, the Tcl backends and
  `-virtual-construction-opt 0` are unchanged.
* **Observable earlier versions stay eager.** An append computed before a
  `break` or `continue`, two versions on one path, an observation followed
  by an append, a captured intermediate, a reference inside an inner loop:
  each is declined with a recorded reason and runs the ordinary
  materialized fold, with identical values. Declining is never an error.
* **Scope held.** Scalar folds and struct-valued folds lower to
  byte-identical NIR (the struct chunk workload's instruction counts are
  unchanged at every size), `std::list::flat` receives an ordinary
  completed List and is not fused, and no public builder or syntax exists.
* **A latent defect fixed on the way.** `SequenceTo`, the lowering of a
  sequence whose value is wanted in a plan position, dropped the affine
  releases `Sequence` emits after each statement: a coroutine that died
  inside a plan-family `if` branch of a recurrence was never released (3
  started, 0 released, on the tree before this milestone). It now releases
  them, as plan fold bodies need.
* **Verified.** 58 Tcl tests (every value on interp, compile,
  cranelift-generic and cranelift, compared with the eager fold too), a
  45-test golden suite on all four backends (every test fails when inverted
  or altered), a fuzzer whose values and eligibility decisions agree with
  two independent models over 900 programs (60 more under GC stress), 18
  mutants all killed, and the regression runs listed under Verification.

## 1. The preexisting mechanism

M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md keeps an immutable String or List
virtual while it is being built: compile-time *pieces* (`{span REG}`,
`{elem REG}`, `{region ...}`) inside a function, and a private runtime
*plan object* (runtime/construct.rs's `ListPlanObj`, a growable vector;
`StrPlanObj`, a gap buffer) where a construction must cross a point pieces
cannot -- a self-tail back edge, a call, a join -- held in a *maybe-plan*
register declared in the function's `planregs=`. One NIR instruction,
`construct list|str plan|flat PIECE...`, extends the first plan piece in
place (its *anchor*) or builds a fresh plan, and materializes (`flat`).

hir/construction.tcl decides where, per used instance, with a monotone
fixpoint over three carriers:

* a *plan local* -- a `bind` whose value is plan-producing and which is
  *linear*: at most one reference along every path of its scope
  (`Linear`, via `Uses`, which counts references per path, a loop body
  bound outside counting as many);
* a *plan parameter* -- a String/List parameter, linear, uncaptured, to
  which some direct call passes a construction and whose own uses continue
  it: this is the carrier of a self tail recurrence `build(i + 1,
  acc.append(x))`;
* a *plan result* -- a closed instance whose result some caller extends.

nir.rs's `validate_plans` re-checks every function: a plan register may only
be a `construct` span piece, moved into another plan register, passed at a
plan parameter or returned from a plan result, and a forward "may have been
consumed" dataflow over the CFG (back edges and handler spans included)
rejects any path that consumes a plan register twice. Each plan object also
carries a `consumed` tripwire.

## 2. Implementation census: why a fold copied

| component | what it did for a fold intermediate |
|---|---|
| hir/construction.tcl candidates | considered only `bind` locals and instance parameters: a fold's intermediate (`foldBinding`, a `param` binding of the iteration scope) was neither |
| `Linear` | walked loops from the binding's `declaredBy`; a fold binding's is `""`, so no loop was known to be per iteration |
| `Uses` | treated `continue` as a reference to nothing and a bare `break` as no reference |
| `Context` | named a fold's initial value "fold intermediate (initial value)" and its body's value "loop body value": both materialization barriers |
| native/lower.tcl `LoopResultStart` / `LoopResultBind` / `LoopResultAdd` / `LoopResultFinish`, `break` | the intermediate one ordinary register: initial value by `Expr`, bound as `{reg R}`, body value by `Sequence` (flat), moved into the result |

So every `acc.append(x)` lowered to `op listappend` on the flat
intermediate: one allocation and a copy of the whole prefix per iteration,
N^2/2 element copies for N iterations (the 4.00x-per-doubling pattern
M8A measured for recursions before it).

What was already there to reuse:

* **Loop-carried plan registers work.** The collecting loop's own
  accumulator is one (`CollectStart`: a plan register consumed by the
  extension and redefined by the back-edge `move`). So `validate_plans`'s
  dataflow across back edges, the collector's rooting of a plan in a
  register (stack maps, the shadow stack, a suspended coroutine's stack)
  and coroutine fusion all already handled the shape.
* **A plan parameter's local** (`{plan REG FAMILY}` in `fn locals`) is
  exactly what a reference to the intermediate needs: in a plan position it
  is `{span REG}`; anywhere else `Ref` materializes it with `construct ...
  flat REG` (which passes a flat value through).
* **`PlanPieces`, `PiecesToPlan`, `SequenceTo`** lower an expression or a
  sequence in a plan position; `If` already joins plan branches in a plan
  register.

The decision: **a fold intermediate is a fourth carrier of the same
analysis**, and the loop result handling gives it a maybe-plan register.
Nothing is a fold-specific representation.

## 3. The extension

**Analysis** (hir/construction.tcl, +184 / -26 lines, code and comments):

* Candidates: every fold of every used instance whose intermediate is
  String/List-typed at every reference (`RefFamily`) with a fold value of
  the same family, uncaptured, unclaimed by another representation
  analysis (escape, StringRegion, Block virtualization), and linear per
  iteration (`FoldLinear`). Each declined one records its reason in
  `foldWhy`.
* `FoldLinear` runs `Linear`'s path count (`SeqUses`) over the fold's own
  body, with the fold marked `fold` in the set of per-iteration loops;
  `Uses` counts a `continue`, and a bare `break`, *targeting a fold marked
  so* as one reference. The intermediate is bound anew in each iteration,
  and every reference to it and every `continue` or `break` that passes it
  on is inside that body, so the body is the whole question (a loop inside
  it still counts as many). The first version walked the whole enclosing
  function, as `Linear` does for a local; the economics below showed that
  doubling the walks of a function holding many folds, and the body walk
  gives the same decisions (the test file, the golden suite and the fuzzer
  were rerun on it).
* Fixpoint: a candidate becomes a plan fold when, judged as if it already
  were one, some reference to the intermediate is in a plan position (the
  construction continues through it) and the body's trailing value -- the
  next intermediate -- is plan-producing (`Source`). Both are monotone in
  the analysis state, so the fixpoint still terminates.
* `Context` (`FoldContext`): a plan fold's initial value and its body's
  trailing value are plan positions; the fold's own value is not a plan
  source (it is materialized).
* `foldFamily` is the lowering's query; `explain` lists plan folds.

**Lowering** (native/lower.tcl, +93 / -19 lines):

* `LoopResultStart`: for a plan fold, the initial value is lowered in a
  plan position (`PlanPieces`, `PiecesToPlan`) into a fresh register
  declared plan.
* `LoopResultBind` binds the intermediate as `{plan REG FAMILY}`.
* `LoopBody` lowers the body with `SequenceTo` in the fold's family, so the
  next intermediate arrives as a plan (or a flat value) and `LoopResultAdd`'s
  `move` puts it in the carried register, as before.
* `FoldValue` materializes the register where the fold yields it --
  exhaustion (`LoopResultFinish`) and a bare `break` -- with `construct ...
  flat`.
* `SequenceTo` now releases the affine values dead after each statement,
  as `Sequence` does (section 12).

The NIR of `build` in list-fold.bot (constants and `@e` locations left
out):

```
    %13 = op listlen %4
    %18 = op listnew                       ; the initial value []
    %19 = move %18                         ; the intermediate: planregs="... 19 ..."
  label L5
    %20 = op ilt %16 %13
    br %20 L6 L8
  label L6
    %21 = op listget %4 %16
    %22 = construct list plan %19 elem %21 ; acc.append(x): extends the plan in place
    %19 = move %22                         ; the next intermediate
    ...
  label L8
    %26 = construct list flat %19          ; exhaustion: the one materialization
    %17 = move %26
```

Before, line `%22` was `op listappend %19 %21` and `L8` moved `%19`
directly.

## 4. Eligibility: when earlier versions cannot be observed

A plan is extended in place, so it must have exactly one continuation. The
fold's intermediate is bound anew in each iteration; its old value can be
passed on, or observed, by:

| use | why it counts |
|---|---|
| a reference (`acc`, `acc.append(x)`, `f(acc)`) | it reads the value |
| a `continue` targeting the fold | it carries the current value into the next iteration |
| a bare `break` targeting the fold | it hands the current value out as the fold's |
| a capture by a function made in the body | the function may read it any time later: never a plan |
| a reference inside an inner loop's body | runs once per inner iteration: counts as many |
| a handler of a call | its body's references follow the call's, on that path |

At most one such use along every path of an iteration (normal or abrupt) is
linearity. Then:

* the construction must continue through the intermediate: some reference
  in a plan position (an append's List operand, a plan local's value, a
  plan parameter's argument, the trailing value), and
* the next intermediate must be plan-producing: an append, a reference to
  the intermediate or a plan local, a call of a plan-result instance, or an
  `if` one of whose branch values is one.

Decisions the tests pin (`fvcDecisions`; the reasons are the analysis'):

| body | decision |
|---|---|
| `acc.append(x)` | plan |
| `if keep(x): acc.append(x * 10) else: acc` | plan |
| `if x == 0: continue` ... `acc.append(y)` | plan |
| `if x > 5: break` / `acc.append(x)` | plan |
| `y = acc.append(x)` / `if x > 5: break` / `y` | flat: two uses on the break path |
| `y = acc.append(x)` / `if x == 2: continue` / `y` | flat: two uses on the continue path |
| `y = acc.append(x)` / `if x == 2: acc else: y` | flat: two versions on one path |
| `n = acc.length()` / `acc.append(n + x)` | flat: observed, then extended |
| `p = {before: acc, after: acc.append(x)}` | flat: two versions in one record |
| `n = keep(log, acc)` / `acc.append(n)` | flat: retained by a place parameter, then extended |
| `n = keep(log, acc)` / `[x].append(n)` | flat: every use needs a flat value |
| `fn size(): acc.length()` / `acc.append(size)` | flat: captured |
| `ys = loop y in [1, 2]: acc.length() + y` / `acc.append(ys)` | flat: referenced in an inner loop |
| `y = acc.append(x)` / `z = check(x): on E: continue` / `y` | flat: the handler continues after the extension |
| no domain, `if acc.length() >= 3: break` / `acc.append(1)` | flat: the test reads it, the break passes it on |
| inner fold seeded with the outer intermediate, its value the outer's next | outer flat (its next value is a fold's, not a construction), inner plan |
| `y = acc.append(x)` / `z = fold w in ws with intermediate inner y: ...` / `z.append(0)` | both plan: the inner fold extends the outer's one continuation |
| an Int or a struct intermediate | flat: not String/List-typed |

**Why `continue` and `break` must count.** A plan local defers its copy to
its consumer, so `y = acc.append(x); if c: break; y` would happen to be
safe without the rule: the in-place extension runs at the trailing `y`,
after the break test. But once the append is *materialized* before the
break -- `y = acc.append(x); if y.length() > 3: break; y.append(0)` --
materializing consumes the plan, and the break would consume it again. With
the rule removed (the mutants `break-not-a-use`, `continue-not-a-use`)
`validate_plans` rejects exactly that program: "plan register %7 may be
consumed twice". The rule is what keeps the old intermediate unobservably
unextended on every path; the tests `fvc-reject-break-after-materialized`
and `fvc-reject-continue-after-materialized` pin it by value, and the
decision tests by reason.

**Aliasing.** Only a plan object is ever extended in place, and only as the
first piece of a `construct ... plan` (runtime/construct.rs: an anchor is a
leading plan span). A flat initial value -- a parameter, a binding another
fold also starts from -- is copied into a fresh plan by the first
extension, so it is never modified (`fvc-shared-initial`: two folds from one
`base` and `base` itself all keep their values). Appended elements are
ordinary values stored by reference, as `list_append` stores them
(`fvc-retained-element`).

## 5. Materialization and escape

A plan fold's register holds either a flat value (the initial value until
the first extension, or a flat next value a branch produced) or a private
plan. It is materialized, with one `construct ... flat` (a flat value
passes through), wherever a flat value is needed:

* the fold's value, at exhaustion and at each bare `break` (`FoldValue`):
  the fold itself is never a plan source, so returning, storing, inspecting
  or passing the result (`fvc-positions`, `fvc-flat-composition`) sees an
  ordinary List;
* a reference to the intermediate in any non-plan position (a native
  operation, a List element, a call argument at a non-plan parameter, a
  `return` from a function that is no plan result): `Ref`'s existing `plan`
  case, the single reference linearity allows;
* nothing else: errors and `return` leave the fold and the register dies
  (the collector frees the plan).

Escaping values never meet a plan: `validate_plans` rejects a plan register
in any instruction other than `construct`, `move` into a plan register,
plan-parameter argument or plan-result `ret` (the mutants
`escaped-not-materialized` and `binding-read-flat` produce such NIR and
are rejected).

## 6. Control flow

| completion | what happens to the carried register |
|---|---|
| normal completion | the trailing value, lowered in a plan position, is moved in (an in-place extension of the same plan, a fresh plan, or a flat value) |
| `continue` | untouched: the jump skips the move (linearity: nothing extended it on that path) |
| bare `break` | materialized into the fold's result |
| exhaustion | materialized into the fold's result |
| empty domain, List[never] | the initial value, never extended, passed through by `construct ... flat` |
| `return` | the register dies; a returned `acc.append(99)` is materialized (or handed on, from a plan-result function) by the existing `return` lowering |
| error raised in the body | the register dies; a handler outside the fold sees nothing of it (`fvc-element-error`, `fvc-error-before-commit`) |
| error handled in the body | an ordinary completion (`fvc-handled-in-body`); a handler that continues after an extension is a second use (declined) |
| `yield` | the plan is an ordinary register live across the suspension, fused or on the general runtime (`fvc-coroutine`, cranelift and cranelift-unfused) |

Evaluation order is untouched: every piece is evaluated exactly where the
eager lowering evaluates it (M8A's `ConstructPieces`), the initial value
after the loop's operands, and an append's operands even on a path whose
result is then discarded; only the copying moves.

## 7. Runtime representation and GC safety

Nothing changed in the runtime. A plan fold's register is an ordinary heap
register: precise stack maps (or the shadow stack) root it at every
safepoint while it is live, across the back edge as the collecting loop's
plan already was; a `ListPlanObj`'s elements are traced; a suspended
coroutine's stack is walked. `construct`'s pieces are live into it (the
mutant `construct-pieces-not-live` removes them from the collector's
liveness, section 11). Coroutine fusion copies the fold, with its plan
register, into the consumer (`fvc-coroutine` runs fused and unfused).

GC stress (`BOTLISH_NATIVE_GC_STRESS=1`, a collection at every
allocation): `fvc-gc-stress` (nested plan folds of fresh Strings, broken
off) on every backend, `fvc-executable` as a standalone executable, the
whole test file, the fuzzer (60 programs) and the golden suite's programs
through the executable test.

## 8. Positive and negative examples

All values below are identical on interp, compile, cranelift-generic,
cranelift and cranelift with `-virtual-construction-opt 0` (the tests and
the golden suite):

```botlish
fn chunks(xs: List[int]) -> List[List[int]]:     # plan: every path
    fold t in xs with intermediate done []:      # extends, keeps, continues
        if t == 0:                               # or breaks with `done`
            continue                             # used once
        if t > 1000:
            break
        if t < 0:
            done.append([t]).append([-t])
        elif t == 2:
            done
        else:
            done.append([t, t + 1])

fn f(xs: List[int]) -> List[int]:                # flat: the break path
    fold x in xs with intermediate acc []:       # passes `acc` on after
        y = acc.append(x)                        # `y` consumed it
        if y.length() > 3:
            break
        y.append(0)
```

The test file has 31 positive and 14 negative value tests, all ported to the
golden suite, and 13 structural ones (section 11).

## 9. Measurements

All on this container (Linux x86-64, 4 cores, the release native backend),
by `audit/fold-virtual-construction/tools/measure.tcl`, before (a worktree
of commit ebc9a56, the backend unchanged) and after, in
`audit/fold-virtual-construction/results/{before,after}.txt`. Element
copies, allocations and plan counters are the runtime's own
(`native::allocationReport`, deterministic). Instructions per run are
callgrind's, the difference of a 4- and a 24-run profile of the standalone
executable (1 and 3 runs at N = 16,384, where an eager fold's runs take
minutes under callgrind); they repeat to within 16 instructions. Times are
best of 20 runs, JIT excluded, on a shared container: noisy, and not the
evidence.

Each program builds its input with a collecting loop (one plan of its own:
the second plan, materialization and half the copies in every "after"
row), then the List under test, then reads it.

### Direct List fold, against the recursion and a MutableVector

| N | list-fold before | list-fold after | list-recursive | list-vector |
|---:|---:|---:|---:|---:|
| | **instructions per run** | | | |
| 128 | 159,011 | 116,267 | 114,204 | 135,239 |
| 1,024 | 2,440,370 | 851,345 | 833,971 | 971,224 |
| 4,096 | 79,818,602 | 3,426,717 | 3,357,119 | 3,865,477 |
| 16,384 | 1,663,965,015 | **13,664,710** | 13,386,121 | 15,391,522 |
| | **List elements copied** | | | |
| 128 | 8,382 | 506 | 506 | 507 |
| 1,024 | 525,822 | 4,090 | 4,090 | 4,091 |
| 4,096 | 8,394,750 | 16,378 | 16,378 | 16,379 |
| 16,384 | 134,242,302 | **65,530** | 65,530 | 65,531 |
| | **List allocations / plans** | | | |
| any N | N + 4 / 1 | 5 / 2 | 5 / 2 | 7 / 2 |
| | **time (us)** | | | |
| 1,024 | 508.6 | 71.4 | 73.9 | 82.1 |
| 16,384 | 130,974.8 | 1,262.0 | 1,251.1 | 1,923.1 |

* Growth per 4x N: copies 16.0x before, 4.0x after; instructions 20.8-32.7x
  before, 4.0x after (3.99x from 4,096 to 16,384).
* The fold and the recursion make the same constructions: 2 plans, 32,766
  extensions and 2 materializations at 16,384, identical copies. The fold
  executes 833 instructions per element against the recursion's 816
  (marginal, from 4,096 to 16,384): its index loop and `listget` against
  the recursion's `at`, not construction.
* The fold now beats the MutableVector idiom (938 per element), which pays
  for the vector's header and its copy into a List at the end.
* Code size of the builder function: 729 bytes before, 873 after (a
  `construct` call passes its pieces in a stack array; M8A measured the same
  growth for recursions); the recursion's builder is 508. Whole programs:
  1,725 / 1,869 / 2,148 bytes.

### Chunk construction: a direct List[List[int]] intermediate

chunks-direct-fold.bot: a separator `continue`s, a negative token appends
two inner Lists, the token 1 an empty one, the token 2 keeps the
intermediate, the end marker `break`s, any other token appends `[t, t +
1]`; chunks-direct-recursive.bot has the same transitions as self tail
calls (values checked against a Python model at every size).

| N | fold before | fold after | recursion | copies before | copies after = recursion | Lists before → after (recursion) |
|---:|---:|---:|---:|---:|---:|---|
| 128 | 311,476 | 254,208 | 252,112 | 5,627 | 786 | 207 → 114 (114) |
| 1,024 | 3,298,660 | 1,962,135 | 1,948,587 | 344,851 | 6,385 | 1,659 → 891 (891) |
| 4,096 | 68,193,566 | 7,848,178 | 7,794,006 | 5,473,975 | 25,568 | 6,628 → 3,551 (3,551) |
| 16,384 | 1,641,130,130 | **31,278,095** | 31,059,104 | 87,506,628 | **102,319** | 26,518 → 14,198 (14,198) |

The remaining Lists are the inner Lists the program constructs (one per
appended chunk) and the input. Every control shape of a fold body is in
this one loop, and the fold stays a plan fold.

The struct-valued chunk workload (FOLD-LOOPS-MILESTONE-1.md's
chunks-fold.bot, a fold carrying `Chunks {done, current}`) is outside the
scope and **unchanged**: 331,077 / 3,550,985 / 22,940,069 / 338,290,044
instructions per run before and after, 18,124,480 elements copied at
16,384, against its recursion's 33,006,534 instructions and 65,760 copies.
It remains the baseline for the struct milestone (section 13).

### Composition with std::list::flat

fold-flat.bot builds a List[List[int]] with a fold (`acc.append(expand(x))`,
expand making a 3-element List) and flattens it:

| N | before | after | copies before | copies after | flat's share (both) |
|---:|---:|---:|---:|---:|---:|
| 1,024 | 4,145,134 | 2,118,721 | 531,966 | 10,234 | 3,072 |
| 16,384 | 2,478,642,088 | **36,565,513** | 134,340,606 | **163,834** | 49,152 |

The fold's own construction, measured without `flat` (the same program
reading the fold's length instead): 134,291,454 copies before, 114,682
after at 16,384. `flat` copies exactly 3N elements into one List in both
trees -- it is untouched and unfused, and the fold hands it an ordinary
List (`fvc-nir-flat-separate`: one `construct list flat`, then one `op
listflat`).

## 10. Compiler economics

**Change size.** hir/construction.tcl +184 / -26 lines, native/lower.tcl
+93 / -19 (code and comments together); no other compiler file. No new NIR
operation, runtime helper, heap kind, Rust code, pass, option or metadata.

**Analysis cost** (`audit/fold-virtual-construction/tools/economics.tcl`:
`hir::construction::analyze`'s time, best of 5 lowerings; `Uses` walks, the
linearity walk's entries into an expression; the whole native lowering):

| program | plan folds | analyze before | analyze after | `Uses` walks before / after | lowering before / after |
|---|---:|---:|---:|---:|---:|
| list-fold.bot | 1 | 463 us | 563 us | 87 / 97 | 10.4 / 10.4 ms |
| chunks-direct-fold.bot | 2 | 1,496 us | 2,117 us | 242 / 356 | 51.9 / 55.0 ms |
| fold-flat.bot | 1 | 542 us | 717 us | 91 / 97 | 13.0 / 14.3 ms |
| nested-1 .. nested-5 (d nested plan folds) | d | 181 .. 951 us | 246 .. 1,486 us | 8, 34, 78, 140, 220 / 12, 51, 117, 210, 330 | 6.0 .. 24.4 / 6.0 .. 24.6 ms |
| many-40 (40 folds in one function, 20 plan) | 20 | 88.7 ms | 96.0 ms | 32,718 / 33,078 | 219 / 231 ms |
| golden/fold-loops.bot (70 folds) | 2 | 44.4 ms | 56.0 ms | 3,564 / 3,626 | 4.61 / 4.79 s |
| golden/list-flat.bot | 2 | 36.3 ms | 38.3 ms | 5,382 / 5,429 | 1.71 / 1.95 s |
| scanner-fold.bot, chunks-fold.bot (struct folds) | 0 | 2,168, 1,038 us | 2,558, 1,143 us | 344, 184 / same | 71.6, 30.9 / 82.5, 31.0 ms |
| lex-strategy-fold.bot (scalar folds) | 0 | 2,164 us | 2,345 us | 406 / same | 50.1 / 54.0 ms |
| uri-steady.bot (M8A's recursions, no fold) | 0 | 3,109 us | 3,316 us | 329 / same | 141 / 143 ms |
| refined-checks.bot | 0 | 5,642 us | 6,092 us | 367 / same | 262 / 290 ms |

(The full tables, 30 programs: `audit/fold-virtual-construction/results/
economics-{before,after}.txt`. Times are best of 5 lowerings in one
process on a shared container: differences under about 15% are within
run to run variation, as programs whose analysis did not change at all
show (source-checks 1,482 -> 1,457 us, test-selection's lowering 51.2 ->
45.1 ms); the walk counts are exact. The golden suites' "after" rows ran
beside a mutation harness.)

* A fold that is not String/List-typed is declined before any walk
  (`RefFamily`), so scalar and struct folds add no `Uses` walk.
* **No plan fold, no new walk.** The `Uses` walk counts of every program
  without a plan fold are identical before and after, scalar and struct
  folds included: a fold that is not String/List-typed is declined by
  `RefFamily` before any walk. What remains is one extra pass over each
  function's expressions to find its folds, and the analysis' time on
  those programs moves within noise.
* **A plan fold costs one walk of its own body** (`FoldLinear`) plus one
  `Context` check per reference per fixpoint round. Nested folds grow the
  walks quadratically in the nesting depth (each fold walks the folds
  inside it), as the locals already did before (8, 34, 78, 140, 220 ->
  12, 51, 117, 210, 330): no multiplicative interaction with the type
  fixpoint FOLD-LOOPS-MILESTONE-1.md measured, which is in the front end;
  this analysis runs once, on the final HIR, after specialization.
* **Many folds in one function.** The first version walked the whole
  function per fold, as `Linear` does per local: many-40's walks went from
  32,718 to 64,638 and its analysis from 88.7 to 200.2 ms (lowering 219 ->
  342 ms). The body walk brings that to 33,078 walks and 96.0 ms. (The
  function's 40 `r_i` and 20 `n` locals are what cost the 32,718 walks
  already before: `Linear` walks the whole function per local candidate.
  That quadratic cost is M8A's, untouched here.)
* The analysis is 4-6% of native lowering on the workloads, about 1-3% on
  the golden suites; many-40's 42% was 40% before.

**Programs without a plan fold lower to byte-identical NIR.**
`audit/fold-virtual-construction/tools/nir-digest.tcl` over 77
programs (bench/, its experimental variants, the bench-bimodality variants,
FOLD-LOOPS-MILESTONE-1.md's workloads, examples/surface and examples/stdlib,
the golden suites fold-loops.bot, list-flat.bot and virtual-construction.bot,
and this milestone's workloads): the 58 that have no plan fold
lower to byte-identical NIR in both trees (scalar folds, struct folds,
collecting loops, M8A's recursions and plan results, the fold-loops
workloads and the lex-strategy fold variants among them); the 12 that
differ each have plan folds (this milestone's workloads and economics
inputs, and fold-loops.bot, list-flat.bot and fold-virtual-construction.bot,
with 2, 2 and 50); 7 are rejected identically by both (programs that need
staged modules, and examples written to be rejected).

**Generated code**: +120 to +248 bytes per function holding a plan fold
(section 9); nothing elsewhere.

## 11. Verification

On this container, on the final tree unless said otherwise.

* **tests/fold-virtual-construction.test**: 58 tests, all passing, plain
  and under `BOTLISH_NATIVE_GC_STRESS=1` (as are tests/virtual-construction.test,
  51, and tests/fold-loops.test, 104: `results/gc-stress.txt`). Every value test runs interp,
  compile, cranelift-generic, cranelift and cranelift with
  `-virtual-construction-opt 0`; decision tests pin plan or flat and the
  reason; structural tests pin the NIR (one extension per iteration into a
  declared plan register, one materialization per exit, no `listappend`;
  the eager form with the option off; flat unfused), the copy counts
  (linear at N and 4N; equal to the recursion's), types and specialization
  identical on and off, releases, GC stress and a standalone executable
  (plain and under GC stress).
* **tests/golden/fold-virtual-construction.bot**: 45 golden tests, all
  four backends, generated by `audit/fold-virtual-construction/tools/
  golden-port.tcl` from the Tcl tests' own programs and results (never a
  copy), with its fragment and census; the manifest regenerated
  (`merge.tcl`: 58 rows added, nothing else changed). Every port is
  `weaker` than its Tcl test (the eager comparison and the decisions stay
  in Tcl), so the Tcl tests stay active. `audit/golden/tools/perturb.tcl
  -mode both`: 45 of 45 inverted and 45 of 45 altered tests fail as
  required.
* **The fuzzer** (`audit/fold-virtual-construction/tools/fuzz.tcl`): random
  folds over a List or its indices, with `continue`, `break`, `return`,
  observations, captures, plan locals, appends of one or two elements and
  nested `if` values, run on all four backends and the eager fold and
  compared with an independent Tcl model of their values; the compiler's
  decision compared with an independent model of the eligibility rule
  (written from section 4, not from the code). Seeds 1-7, 17 and 41, 100
  programs each (900 in all: 326 plan folds, 572 declined, 2 whose fold
  body no call reaches), and seed 8 (60 programs, 19 plan folds) under GC
  stress: 0 disagreements, 0 mispredictions
  (`audit/fold-virtual-construction/results/fuzz.txt`). (The first
  runs showed mispredictions; all were folds of an instance over an empty
  `List[never]`, whose body never runs and whose decision means nothing:
  the fuzzer now judges only folds whose body runs.)
* **Mutation testing** (`audit/fold-virtual-construction/tools/
  mutate.tcl`, `mutants.txt`): 18 mutants -- the optimizer disabled, a
  break or a continue not counted as a use, linearity ignored, a captured
  intermediate accepted, the continuation check or the next-value check
  dropped, a declined fold failing the compilation, the next intermediate
  materialized every iteration, the fold's value not materialized,
  exhaustion materializing the wrong family, the intermediate bound flat,
  an append not committed, the initial value dropped, nested folds sharing
  one register, pieces in the wrong order, `SequenceTo`'s releases dropped,
  and (rebuilding a private copy of the backend) a `construct`'s pieces
  missing from the collector's liveness. **18 of 18 killed**
  (`audit/fold-virtual-construction/results/mutate.txt`), every one by
  the test file: the value-changing ones also by the fuzzer (40 programs
  of seed 1 per mutant), the GC-root one by the GC-stress test and the
  GC-stress executable. Four change only cost or representation, never a
  value -- `optimizer-disabled`, `continues-dropped`,
  `next-value-check-dropped`, `next-value-materialized` -- and are killed
  by the structural and decision tests (NIR, copy counts, reasons), as
  they must be: values cannot tell them apart. `break-not-a-use` and
  `continue-not-a-use` are killed by value too (`validate_plans` rejects
  the double consumption, section 4).
* **Other harnesses whose mutants edit the changed code.** Every mutant of
  every `audit/*/tools/*mutants*.txt` applies (two fold-loops mutants of the
  break and exhaustion lowering were updated to the new text, the same
  rule). The harnesses AGENTS.md names for the code this milestone
  touched, run whole on the final tree: `audit/fold-loops/tools/mutate.tcl`
  (fold lowering) 22 of 22 killed, `audit/affine/tools/mutate.tcl` and
  `audit/coroutines/tools/mutate.tcl` (where releases lower: the
  `SequenceTo` fix) 29 of 29 and 52 of 52 killed, the coroutine harness's
  native mutants rebuilt in its private copy
  (`results/mutate-{fold-loops,affine,coroutines}.txt`).
* **Regression.** REGRESSION-RESULT

## 12. A defect found on the way: releases in plan-position sequences

`native::lower::Sequence` releases, after each statement, the affine values
that die there (AFFINE-VALUES.md; `hir::affine::releasesAfter`).
`SequenceTo`, the same sequence with its value wanted in a plan position,
did not: it was M8A's helper for plan-result function bodies and
plan-family `if` branches. A coroutine created and resumed inside a
plan-family branch of a recurrence was therefore never released (the tree
before this milestone: 3 started, 0 released, by
`native::allocationReport`'s coroutine counters with fusion off); with the
eager lowering it was. A plan fold's body is lowered by `SequenceTo`, so
the same omission would have leaked a coroutine per iteration. The fix is
the two `ReleaseHandles` calls `Sequence` makes (a plan or a flat
String/List is never affine itself, so the release never touches the
construction). `fvc-release-in-body` and `fvc-release-plan-join` pin it;
the mutant `release-dropped` restores the omission and is killed by both.
(`SequenceRaw`, `SequenceShort` and `SequenceVirtual` have the same shape;
they are not on the fold path and were not examined here.)

## 13. Remaining limitations and follow-up

1. **List fields of struct intermediates.** The chunk fold carrying
   `Chunks {done, current}` still copies `done` at every append: 18.1
   million elements at 16,384 against its recursion's 65,760, 10x its
   instructions. Either the fields stay virtual inside the carried struct,
   or the struct is scalar-replaced into loop-carried registers (one per
   field, as the `if` join's virtual struct already is) and each List field
   becomes a plan fold of its own. They overlap but are not the same: the
   second also removes the per-iteration struct allocation the scanner fold
   pays (FOLD-LOOPS-MILESTONE-1.md, "Stateful scanner").
2. **A fold is no plan source.** Its value is always materialized, so a
   fold whose next intermediate is another fold's value (an inner fold
   seeded with the outer intermediate, the inner's result the outer's next
   value) keeps the outer flat and copies once per outer iteration. Letting
   a plan fold hand its register to a plan position (the fold's value
   wanted as a plan) would close that, with `Source`/`Context` cases for
   loops.
3. **Observation materializes.** `n = acc.length()` before `acc.append(n)`
   is declined: a plan-aware length would make it linear. M8A recommended
   against plan-aware observers on its evidence; no workload here needs it.
4. **A bare fold that breaks on its own intermediate** (`if acc.length() >=
   3: break`) is declined for the same reason.
5. **Producer-consumer fusion** of collecting loops, folds and
   `std::list::flat` (the next milestone of the progression): fold-flat.bot
   still allocates every inner List and copies each element twice (into
   the fold's result, then into flat's). This milestone does not anticipate
   it: nothing depends on `flat` being the consumer.

## Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/fold-virtual-construction.test
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/fold-virtual-construction.test
tclsh9.0 tests/local.tcl tests/golden/fold-virtual-construction.bot
tclsh9.0 audit/fold-virtual-construction/tools/golden-port.tcl      # regenerates the suite
tclsh9.0 audit/golden/tools/perturb.tcl -mode both tests/golden/fold-virtual-construction.bot
for s in 1 2 3; do tclsh9.0 audit/fold-virtual-construction/tools/fuzz.tcl -n 100 -seed $s; done
tclsh9.0 audit/fold-virtual-construction/tools/fuzz.tcl -n 60 -seed 8 -gc-stress 1
tclsh9.0 audit/fold-virtual-construction/tools/mutate.tcl
W=audit/fold-virtual-construction/workloads
tclsh9.0 audit/fold-virtual-construction/tools/measure.tcl -instructions 1 $W/*.bot \
    audit/fold-loops/workloads/chunks-fold.bot audit/fold-loops/workloads/chunks-recursive.bot
git worktree add /tmp/before ebc9a56 && ln -s "$PWD/native/target" /tmp/before/native/target
tclsh9.0 audit/fold-virtual-construction/tools/measure.tcl -root /tmp/before -instructions 1 $W/*.bot
tclsh9.0 audit/fold-virtual-construction/tools/economics.tcl $W/*.bot audit/fold-virtual-construction/economics/*.bot
tclsh9.0 audit/fold-virtual-construction/tools/nir-digest.tcl bench/*.bot   # and -root /tmp/before
```
