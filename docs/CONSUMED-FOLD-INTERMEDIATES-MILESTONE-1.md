# Consumed fold intermediates, milestone 1

A fold carries one value from each iteration to the next. A fold whose
intermediate holds a mutable collection used to copy that value at every
iteration's entry, so that a `continue` could keep, and a bare `break`
yield, the value the iteration started with; every iteration's first write
then copied the whole collection, and n pushes copied n(n-1)/2 elements.
Now the compiler *consumes* the intermediate -- the iteration mutates the
carried collection in place, nothing is copied -- wherever no `continue` or
bare `break` of the fold can run after the iteration may have given the
intermediate's header away. Everywhere else the copy stays, because that
exit needs it. The language is unchanged: no syntax, rule, diagnostic,
annotation, runtime operation or format.

Throughout, *implementation fact* means something read from the code,
*observation* something a run showed (with its command), and *judgment* a
design decision this report argues for.

## Contents

1. [Result](#1-result)
2. [Starting behavior and measured cost](#2-starting-behavior-and-measured-cost)
3. [Architecture census](#3-architecture-census)
4. [The ownership-transfer rule](#4-the-ownership-transfer-rule)
5. [No-exit folds](#5-no-exit-folds)
6. [The control-flow-sensitive extension](#6-the-control-flow-sensitive-extension)
7. [`continue` and `break` preserved](#7-continue-and-break-preserved)
8. [Nested folds and nested control flow](#8-nested-folds-and-nested-control-flow)
9. [Mutable collections and struct intermediates](#9-mutable-collections-and-struct-intermediates)
10. [Shared values and copy-on-write](#10-shared-values-and-copy-on-write)
11. [Errors, returns, coroutines and resources](#11-errors-returns-coroutines-and-resources)
12. [Proofs and diagnostics preserved](#12-proofs-and-diagnostics-preserved)
13. [Backend consistency](#13-backend-consistency)
14. [Allocation counts](#14-allocation-counts)
15. [Runtime benchmarks](#15-runtime-benchmarks)
16. [Fuzzing and mutation testing](#16-fuzzing-and-mutation-testing)
17. [Compile-time cost](#17-compile-time-cost)
18. [Remaining limitations](#18-remaining-limitations)
19. [Files changed and verification commands](#19-files-changed-and-verification-commands)

## 1. Result

* **The census's fold** (CONSTRUCT-BINDING-MUTATION-CENSUS-1.md, corpus
  a02: push onto a MutableVector intermediate, complete with it) gives its
  original value with 0 shares, 0 detaches and 0 copied elements, where it
  made 1,000, 1,000 and 499,500 at 1,000 pushes; its copies no longer grow
  with its length (section 14). 32,000 pushes take 8.3 ms instead of
  308 ms, process start-up included (section 15).
* **The rule is the copy convention's**, not a fold-specific optimizer
  (section 4): a fold's intermediate joins the convention's *consumed
  parameters* -- the fold's initial value and every normal completion of its
  body are its "arguments", exclusive positions -- when no exit of the fold
  can follow a give-away of its header. One walk of the body decides the
  exits (`FoldExitsClean`).
* **It reaches beyond the no-exit case**: an exit before the first
  mutation (`if x < 0: continue`, `if acc.length() >= n: break`, the
  `continue` the loop protocol writes into a fold over a MutableMap), an
  inner loop's own `break`/`continue`, a handler on a call made before the
  intermediate is touched, an `if` completing with the intermediate on both
  branches, struct, MutableArray, MutableMap and MutableSet intermediates,
  nested folds, a fold inside a generic function (sections 6 to 9).
* **Semantics are unchanged.** A `continue` or bare `break` that can run
  after a mutation keeps the copy and the rollback (census c08, c09);
  every program of the test file and of the fuzzer gives one outcome on
  the four backends with the consumption on and with it off (the copying
  elaboration, kept as `hir::mutvec::consumedFolds 0`), the standalone
  executables and GC stress included; the rejected programs report the same
  diagnostics (sections 7, 12, 13, 16).
* **One latent bug fixed on the way**: a fold whose initial value was a
  read-out of a place (a vector mutated before the fold and read after it)
  stopped the elaboration with an internal error, because
  `hir::mutvec::ReplaceChild` did not know the `foldInitial` field
  (section 3).
* **Evidence**: `tests/consumed-fold-intermediates.test` (31 tests), the
  fuzzer `audit/consumed-folds/tools/fuzz.tcl` (950 programs, 0
  disagreements; its `-fault` modes find the unsound variants), the mutation
  catalog `audit/consumed-folds/tools/mutants.txt` (20 mutants, all killed by
  the test their `!!` line names) and `bench/consumed-folds.tcl`.

## 2. Starting behavior and measured cost

*Implementation fact.* Before this milestone the elaboration
(`hir::mutvec::Elaborate`, after the checks) renamed a mutated fold
intermediate `acc` to a parameter `acc#entry` and bound `acc =
mutable_vector#share(acc#entry, "h")` as the body's first statement
(`EntryRename`). The HIR of the census's a02, from `main.tcl -hir`:

```
e10 countloop s5 (b6 i) fold (b237 acc#entry) binds b7 acc : MutableVector[int]
    ...
    e30 bind b7 acc : MutableVector[int]
        e28 call native(mutable_vector#share) : MutableVector[int]
            e26 ref b237 acc#entry : MutableVector[int]
            e29 const str h : str
    e15 call native(std::mutable_vector::push) : unit vector=mutate place=b7
        e17 ref b7 acc : MutableVector[int]
        e18 ref b6 i : int
    e19 ref b7 acc : MutableVector[int]
```

*Observation.* `tclsh9.0 audit/construct-binding-mutation/tools/fold-cost.tcl`
on this branch's base (main at 2ca98b5), before the change (best of 3 driver
processes, start-up included; 4-core container):

| idiom | n | best (µs) | shares | detaches | elements copied |
|---|---:|---:|---:|---:|---:|
| fold intermediate (a02) | 1,000 | 9,552 | 1,000 | 1,000 | 499,500 |
| | 4,000 | 15,105 | 4,000 | 4,000 | 7,998,000 |
| | 16,000 | 67,467 | 16,000 | 16,000 | 127,992,000 |
| | 32,000 | 308,259 | 32,000 | 32,000 | 511,984,000 |
| outer local (a03) | 1,000 to 32,000 | 8,585 to 9,994 | 0 | 0 | 0 |
| threaded working copy (a04) | 1,000 to 32,000 | 11,337 to 12,627 | 0 | 0 | 0 |

The same quadratic shape as the census's (its 359.3 ms at 32,000 on a busier
machine). The census corpus ran clean on all four backends
(`audit/construct-binding-mutation/tools/run.tcl`: 41 programs, 0 failures).

## 3. Architecture census

*Implementation facts*, file by file:

* **Representation.** A fold is a loop node of any of the four kinds
  carrying `foldBinding` (the intermediate: a `param` of the loop's body
  scope) and `foldInitial` (an operand evaluated after the loop's own;
  `hir::FoldInitials`). Core IR is `(fold INIT LOOP)`, the loop's block
  binding the intermediate last (hir/lower.tcl). `hir/fold.tcl` holds only
  the FOLD-INTERMEDIATE-TYPE check; ownership is nowhere in it.
* **How the backends carry it.** Every backend binds the intermediate to
  the carried value itself: native lowering's `LoopResultBind` binds
  `foldBinding` to the accumulator register, a normal completion `move`s
  into it (`LoopResultAdd`), `continue` jumps past that move, a bare `break`
  and exhaustion move it into the result (`LoopResultFinish`, the `loops`
  entry); the Tcl compiler's `FoldBind` binds the body's variable from the
  accumulator variable per iteration; the evaluator's result state does the
  same. So a header mutated in place through the intermediate is mutated in
  the accumulator: whatever `continue` or `break` carries is what the
  iteration did to it.
* **Where the copy comes from.** `hir::mutvec::Elaborate`'s entry phase
  calls `EntryRename` for every place root that is a parameter -- of a
  function, a loop element, a handler payload, a fold intermediate -- unless
  the copy convention *consumes* it or it is a place parameter.
  `acc#entry` is referenced only by that share: the loop machinery is its
  one other reader.
* **Which exits read the starting value.** A `continue` (rule 5) and a bare
  `break` (rule 6) of the fold; exhaustion reads the last completion; a
  `return`, a `fail` or a propagated error leaves the fold with no value
  (rule 8). `break` and `continue` target the nearest enclosing loop (rule
  10: no labels), so an exit inside an inner loop is that loop's. The loop
  protocol of MutableMap, MutableSet and ImmutableMap (hir/iteration.tcl,
  before the elaboration) rewrites a fold over one into a counted fold whose
  first statement is `if iteration_live?(...): (nothing) else: continue`.
* **The copy convention** (hir/mutvec.tcl, "Last uses and consumed
  parameters"; MUTABLE-VECTOR.md's later sections): *read-outs* share a
  place's value unless it is its path's last use (`NoLaterUse`, which reads
  `continue` and `break` as leaving the binding's iteration), an
  observation by reference (`ByReference`), a place argument, a discarded
  statement or the function's own result; *consumed parameters* of directly
  called functions make no entry copy, and every call hands them an
  exclusive header (`ExclusivePositions`, the third phase's wraps:
  `Fresh`, `Moved` or a share); *demanded* locals; `FreshFunctions`. That
  machinery expresses the fold's transfer exactly: the fold is the one
  "caller" of its intermediate, its initial value and its completions the
  "arguments".
* **Where the decision goes.** In `Convention`, before the read-outs: a
  consumed intermediate is a held binding, so its value uses are moves at
  their last use and shares before (as a consumed parameter's). No new HIR
  representation: a consumed intermediate is simply not renamed.
* **A latent bug.** `hir::mutvec::ReplaceChild` (used by every wrap) listed
  the single-child fields `value callee condition iterable start end
  receiver call` but not `foldInitial`. A read-out of a place root as a
  fold's initial value -- `v.push(100)` before the fold, `fold ... with
  intermediate acc v:`, `v.push(7)` after -- therefore failed with
  `hir::mutvec::ReplaceChild: e20 is not a child of e17` on every backend
  (*observation*, `main.tcl -hir` on that program before the change). It is
  fixed (the field added) and pinned by `cfi-initial-read-out`. The
  consumption needs it: a fold's initial value is now an exclusive position.
* **The analyses that read folds** -- `hir::types::FoldBody`,
  `hir::range`, `hir::cardinality`, `hir::induction`, `hir::completions`,
  `hir::affine` -- all run inside `hir::check`, before `hir::BuildFull`
  elaborates (hir/hir.tcl: `hir::iteration::Elaborate`, then
  `hir::mutvec::Elaborate`, after the checks). The elaboration reads their
  results (types, reachability) and feeds none of them.

## 4. The ownership-transfer rule

*Implementation fact* (hir/mutvec.tcl, "Consumed fold intermediates"). A
fold's intermediate B is **consumed** when the convention's fixed point
makes it so, by the same two routes as a function's parameter:

* it is **eligible** (`Eligible`): a parameter of a collection-bearing,
  unrestricted type, not captured by a nested function, and its fold's
  exits are **clean** (`FoldExitsClean`, decided once per fold); and
* it **needs to own its header**: it is a place root (a mutating
  operation's receiver path, or a place parameter's argument), or its last
  use hands the header to an exclusive position.

A consumed intermediate is a held binding (its earlier value uses copy, its
last use moves), makes **no entry copy** (it stays the loop's parameter, so
the iteration mutates the carried header), and its fold's **incoming
values** -- the initial value, and every normal completion of the body: the
body's last statement, through an `if` with two branches into each
branch's last statement (`FoldIncoming`) -- are **exclusive positions**:
`ExclusivePositions` lists them, so a local or parameter whose last use is
one becomes demanded or consumed in turn, and the elaboration's third
phase wraps each that is not `Fresh` or `Moved` in a share (a struct
literal field by field). A consumed fold's value is fresh (`Fresh`): every
value it carries was exclusive, and it gives the header away only when an
iteration completes.

**Clean exits.** `FoldWalk` walks the body in evaluation order with one
bit, "this iteration may have given B's header away", starting at 0 for
every iteration, and fails as soon as a `continue` or bare `break` whose
target is the fold is reached with the bit set. A reference to B sets it
when `GivesHeader`: the path it begins (its projections) is a mutating
operation's receiver or a place parameter's argument (`PlaceArgument`), or
a value use at its path's last use (`NoLaterUse`), which moves the header
on. It does not when the path holds no header (an Int field), the
reference is a discarded statement, the call reads it by reference
(`ByReference`: an observing operation's receiver, a native's observing
argument), or the use is not its path's last (it is shared). The walk
over-approximates: both branches of an `if` (joined), a handler from the
state after any part of its call, an inner loop's body as if it ran again
from its own end state, a statement after one that never completes as if it
could run; unreachable code never runs, and a nested function cannot refer
to B (it is never captured) or exit the fold.

*Judgment.* The rule decides by the facts the convention already relies on
-- `PlaceArgument`, `ByReference`, `NoLaterUse`, `Fresh`, `Moved` -- never
by an operation's name, so a new mutating operation, place-parameter
function or observing native is classified as everything else is. The bit
is per iteration because the rollback is relative to the iteration's
starting value: what an earlier iteration did is that value.

**Why it is sound.** The carried header H at an iteration's start is held
only by the accumulator: the initial value and every completion were
exclusive. In the iteration, only B's own uses can reach H: a share gives a
new header over the same backing (copy-on-write detaches whichever writes
first), an observation keeps nothing, and the convention forbids captures.
So H changes only after a give-away. An exit before any give-away carries H
unchanged -- the value the copy would have kept; an exit after one is
excluded. A normal completion carries whatever it completes with, which is
exclusive. A `return` or an error leaves the fold with no value.

## 5. No-exit folds

*Observation* (`main.tcl -hir` of corpus a02, after):

```
e10 countloop s5 (b6 i) fold (b7 acc) : MutableVector[int]
    e11 const 0 : int
    e12 ref b5 n : int
    e13 call block(e2) : MutableVector[int]
        e14 ref b1 ints : block(e2)/0 -> MutableVector[int]
    e15 call native(std::mutable_vector::push) : unit vector=mutate place=b7
        e16 ref b8 std::mutable_vector::push : native std::mutable_vector::push
        e17 ref b7 acc : MutableVector[int]
        e18 ref b6 i : int
    e19 ref b7 acc : MutableVector[int]
```

No rename, no share. The initial value `ints()` is fresh (a function whose
every result is a constructor's), the completion `acc` its path's last use:
nothing is wrapped. `cfi-push-consumed`: value 1000 on the four backends with
the consumption on and off, native counters `{0 0 0}` (shares, detaches,
elements) against `{1000 1000 499500}`; `cfi-push-linear`: 0 at 1,000, 2,000
and 4,000 pushes against 499,500, 1,999,000 and 7,998,000;
`cfi-hir-text`: the HIR text of both elaborations.

## 6. The control-flow-sensitive extension

The milestone's classes, as the walk decides them (all *observations* of
`tests/consumed-fold-intermediates.test`, values identical with the
consumption off):

| class | example | decision | test |
|---|---|---|---|
| A. no exit of the fold | push and complete | consumed | `cfi-push-consumed` |
| B. exit before the give-away | `if x < 0: continue` first; `if acc.length() >= 3: break`; a bare fold's `break` before its push; a handler that continues on a call made before | consumed | `cfi-exit-before-mutation`, `cfi-handler-before-mutation` |
| C. exit after the give-away | push then `continue` (c08) or `break` (c09); a place helper, a move into a local, an inner loop's pushes, a nested fold's initial value, a handler that continues after a push | copied | `cfi-exit-after-mutation`, `cfi-exit-after-give-away` |
| D. nested constructs | an inner loop's own `break`/`continue` beside pushes of the fold's intermediate | consumed | `cfi-exit-of-inner-loop` |
| E. conditional mutation | a push in an `else` branch, a handler body or an `if` condition (a place helper), before a later exit | copied | `cfi-exit-after-conditional-mutation` |

Class E is decided conservatively: the walk joins paths, so a push under
`x > 1` and a `continue` under `x < 0` keep the copy although no execution
runs both (section 18).

## 7. `continue` and `break` preserved

*Observation.* Census c08 (`acc.push(x); if x < 0: continue; acc` over
`[1, -2, 3]`) still gives `[1, 3]` and c09 (`acc.push(x); if x == 0: break;
acc` over `[1, 2, 0, 9]`) `[1, 2]`, on the four backends: both keep
`acc#entry` and its share (`main.tcl -hir`; `cfi-exit-after-mutation`). A
bare fold whose `break` follows its push (`[0, 2, 4, 6]`, the last push
discarded) keeps it too. Wherever the copy goes, its exit carries the
iteration's starting value (class B), checked against the copying
elaboration in every test and every fuzzed program.

## 8. Nested folds and nested control flow

* **Nested folds carrying one vector** (census a06): the inner fold's
  intermediate is a place root with no exit, so it is consumed; its initial
  value is the outer intermediate at its last use, an exclusive position, so
  the outer intermediate -- never mutated itself -- is consumed too (the
  convention's fixed point); the outer body's completion is the inner fold,
  fresh. 0 copies at any level against `{6 6 15}` (`cfi-nested-folds`).
* **An inner fold with its own rollback** keeps its own copy; the outer
  fold is decided on its own (`cfi-nested-inner-exit`).
* **Inner loops**: their `break` and `continue` are theirs and do not
  prevent consuming the fold's intermediate even when the inner loop pushes
  onto it (`cfi-exit-of-inner-loop`: 0 copies against `{3 2 1}`); a fold's
  exit after an inner loop that pushed keeps the copy (`cfi-exit-after-give-away`).

## 9. Mutable collections and struct intermediates

*Observations* (each: value identical on the four backends with the
consumption on and off; native counters on, then off):

| intermediate | program | test | counters on | off |
|---|---|---|---|---|
| MutableArray | `acc.set(i, ...)` over 8 iterations; the initial array read after the fold | `cfi-mutable-array` | `{1 1 4}` (the initial value copied once) | `{8 8 32}` |
| struct of two vectors (a05) | one field pushed per iteration | `cfi-struct-intermediate` | `{0 0 0}` | `{400 200 9900}` |
| struct with a count | completed by a new literal of its fields | same | `{0 0 0}` | `{20 10 24}` |
| struct, `continue` first | | same | `{0 0 0}` | `{20 9 18}` |
| struct, an Int field read before a `break` | | `cfi-int-field-read` | `{0 0 0}` | `{3 3 3}` |
| MutableMap | `acc.set(k, 1)` (a generic place parameter) | `cfi-mutable-map` | `{0 0 0}` | `{20 16 38}` |
| MutableVector over a MutableMap | the loop protocol's `continue` first | same | `{0 0 0}` | `{3 2 1}` |
| MutableSet | `acc.add(x)` | `cfi-mutable-set` | `{0 0 0}` | `{20 12 33}` |
| imprinted `MutableVector[T]` | inside a generic function | `cfi-generic` | `{0 0 0}` | `{4 4 13}` |
| scalar, unmutated vector | `acc + x`; a vector carried through `continue` | `cfi-immutable-intermediates` | `{0 0 0}` | `{0 0 0}` |

No collection is special-cased: MutableMap's and MutableSet's operations
are ordinary Botlish functions with place parameters (`PlaceArgument`), the
loop protocol's `continue` is an ordinary exit before any give-away, and a
struct's fields are paths of the same intermediate. A struct literal
completing the body is exclusive field by field: in `cfi-struct-completion-fields`
(`Pair {mine: p.mine, theirs: other}`) the pushed field moves and only the
field another binding holds is copied, once per iteration (`{10 1 1}`
against `{22 11 46}`); the later push onto that field never reaches the
other binding.

## 10. Shared values and copy-on-write

A consumed fold must never mutate a header another live value holds. The
exclusive positions guarantee it (*observations*):

* **An initial value another binding still reads** is copied once, at the
  fold's start, never per iteration; the pushes never reach it
  (`cfi-initial-shared`: `[1, 4, 100, 2]`, `{1 1 1}` against `{3 3 6}`; also
  when the other binding is mutated after the fold, `[2, 6]`).
* **An initial value at its binding's last use moves in**: nothing is
  copied (`cfi-initial-moved`).
* **A completion with a value another binding holds** is copied for the
  fold, so the next iteration's push never reaches it
  (`cfi-completion-shared`: `u` keeps its length 1).
* **A consumed fold's value is fresh**: a local bound to it and mutated
  after makes no copy (`{0 0 0}` against `{4 4 6}`), nor does a caller
  mutating the result of a function that returns one (`{0 0 0}` against
  `{5 5 10}`) (`cfi-fold-value-fresh`).
* **Uniqueness is never assumed from names**: what holds a header is the
  convention's (a share is a new header; copy-on-write still detaches
  whichever header writes first while the backing is shared, e.g. the
  `theirs` field above).

## 11. Errors, returns, coroutines and resources

* **An error after the push leaves the fold** with no value; the caller's
  vector, the fold's initial value through a value parameter, keeps its
  length (`cfi-error-leaves-fold`: `[-1, 1]`).
* **A `return` from inside the fold** returns what the iteration computed
  (`cfi-return-mid`, consumed: `[-3]`).
* **A `yield` inside the fold** suspends with the carried vector live; the
  resumer observes the lengths (`cfi-coroutine`: `[1, 2, 3, 3]`, consumed).
* **Releases.** *Implementation fact:* only unrestricted intermediates are
  concerned: an affine one is still AFFINE-FOLD-UNSUPPORTED, and a
  collection of affine elements is affine. The change adds and removes
  only `mutable_vector#share` calls of unrestricted values, which release
  nothing; `hir::affine`'s release scopes and drop descriptors are computed
  before and unchanged. Affine temporaries in a fold body (the coroutine
  handle above) release as before (`cfi-coroutine`, the fuzzer's handlers).
* **GC stress**: `cfi-gc-stress` and `cfi-executable` run consumed folds
  natively under `BOTLISH_NATIVE_GC_STRESS=1`; the fuzzer's seed 7 runs 100
  programs under it (0 disagreements).

## 12. Proofs and diagnostics preserved

*Implementation fact.* The consumption is decided inside
`hir::mutvec::Elaborate`, which `hir::BuildFull` runs after `hir::check`:
every type, range, cardinality, induction, completion, affine and relational
fact -- and every diagnostic those analyses or `hir::mutvec::verify` report
-- is computed before it, from a HIR it has not touched. The census's p01
(a fold intermediate's array capacity unproven, UNHANDLED-ERROR) is
therefore unchanged; this milestone does not try to change it.
`hir::emission::verify` runs after the elaboration (on the code every
backend compiles); a consumed fold has fewer native calls of
`mutable_vector#share`, which yields nothing.

*Observation.* `cfi-diagnostics-unchanged`: every rejected program of the
census corpus (r01 to r05, p01) reports the same diagnostics, kind, line
and column, with the consumption on and off. The golden suites that
exercise folds, vectors, arrays, maps, sets, iteration, place parameters,
reordering and value parameters pass (section 19).

## 13. Backend consistency

*Implementation fact.* The decision is written into the HIR every backend
compiles (no rename, fewer shares); no backend, core IR form, NIR
instruction, runtime operation or value representation changed, and HIR
text, HIR interchange and the front-end cache carry it as they carry any
elaboration. The consumption switch `hir::mutvec::consumedFolds` is a
front-end input (`surface::cache::Key`'s `consumed-folds`; `hc-key`, and the
mutant `key-ignores-consumed-folds` of audit/hir-interchange, killed by it).

*Observation.* Every test compares interp, compile, cranelift-generic and
cranelift with the consumption on and off (eight outcomes, one value);
`cfi-executable` adds a standalone executable, plain and under GC stress.

## 14. Allocation counts

*Observation*, `tclsh9.0 bench/consumed-folds.tcl -part run` (one
instrumented native run per row; on = consumed, off = the copying
elaboration; shares, detaches and elements copied of MutableVectors and
MutableArrays together; allocations are heap objects; growth B the vector
backing bytes allocated, by growth or detach):

| idiom | n | consumed: shares / detaches / elements | allocations | growths | growth B | collections | copying: shares / detaches / elements | allocations | growths | growth B | collections |
|---|---:|---|---:|---:|---:|---:|---|---:|---:|---:|---:|
| fold-intermediate | 1,000 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 | 1,000 / 1,000 / 499,500 | 1,002 | 1,000 | 3,996,048 | 7 |
| fold-intermediate | 4,000 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 | 4,000 / 4,000 / 7,998,000 | 4,002 | 4,000 | 63,984,048 | 119 |
| fold-intermediate | 16,000 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 | 16,000 / 16,000 / 127,992,000 | 16,002 | 16,000 | 1,023,936,048 | 1,802 |
| fold-intermediate | 32,000 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 | 32,000 / 32,000 / 511,984,000 | 32,002 | 32,000 | 4,095,872,048 | 6,629 |
| outer-local | 1,000 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 |
| outer-local | 4,000 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 |
| outer-local | 16,000 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 |
| outer-local | 32,000 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 |
| threaded-copy | 1,000 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 |
| threaded-copy | 4,000 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 |
| threaded-copy | 16,000 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 |
| threaded-copy | 32,000 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 |
| fold-struct | 1,000 | 0 / 0 / 0 | 5 | 16 | 8,192 | 0 | 2,000 / 1,000 / 249,500 | 3,005 | 1,000 | 1,996,096 | 3 |
| fold-struct | 4,000 | 0 / 0 / 0 | 5 | 20 | 32,768 | 0 | 8,000 / 4,000 / 3,998,000 | 12,005 | 4,000 | 31,984,096 | 60 |
| fold-struct | 16,000 | 0 / 0 / 0 | 5 | 24 | 131,072 | 0 | 32,000 / 16,000 / 63,992,000 | 48,005 | 16,000 | 511,936,096 | 939 |
| fold-struct | 32,000 | 0 / 0 / 0 | 5 | 26 | 262,144 | 0 | 64,000 / 32,000 / 255,984,000 | 96,005 | 32,000 | 2,047,872,096 | 3,606 |
| fold-skip-first | 1,000 | 0 / 0 / 0 | 2 | 9 | 8,192 | 0 | 1,000 / 1,000 / 499,500 | 1,002 | 1,000 | 3,996,048 | 7 |
| fold-skip-first | 4,000 | 0 / 0 / 0 | 2 | 11 | 32,768 | 0 | 4,000 / 4,000 / 7,998,000 | 4,002 | 4,000 | 63,984,048 | 119 |
| fold-skip-first | 16,000 | 0 / 0 / 0 | 2 | 13 | 131,072 | 0 | 16,000 / 16,000 / 127,992,000 | 16,002 | 16,000 | 1,023,936,048 | 1,802 |
| fold-skip-first | 32,000 | 0 / 0 / 0 | 2 | 14 | 262,144 | 0 | 32,000 / 32,000 / 511,984,000 | 32,002 | 32,000 | 4,095,872,048 | 6,629 |
| fold-skip-after | 1,000 | 1,000 / 1,000 / 499,500 | 1,002 | 1,000 | 3,996,048 | 7 | 1,000 / 1,000 / 499,500 | 1,002 | 1,000 | 3,996,048 | 7 |
| fold-skip-after | 4,000 | 4,000 / 4,000 / 7,998,000 | 4,002 | 4,000 | 63,984,048 | 119 | 4,000 / 4,000 / 7,998,000 | 4,002 | 4,000 | 63,984,048 | 119 |
| fold-skip-after | 16,000 | 16,000 / 16,000 / 127,992,000 | 16,002 | 16,000 | 1,023,936,048 | 1,802 | 16,000 / 16,000 / 127,992,000 | 16,002 | 16,000 | 1,023,936,048 | 1,802 |
| fold-skip-after | 32,000 | 32,000 / 32,000 / 511,984,000 | 32,002 | 32,000 | 4,095,872,048 | 6,629 | 32,000 / 32,000 / 511,984,000 | 32,002 | 32,000 | 4,095,872,048 | 6,629 |
| fold-map | 1,000 | 0 / 0 / 0 | 12 | 35 | 40,896 | 0 | 5,000 / 4,992 / 2,565,988 | 7,012 | 3,052 | 12,020,784 | 30 |
| fold-map | 4,000 | 0 / 0 / 0 | 12 | 43 | 163,776 | 0 | 20,000 / 19,990 / 41,094,184 | 28,012 | 12,075 | 192,083,088 | 457 |
| fold-map | 16,000 | 0 / 0 / 0 | 12 | 51 | 655,296 | 0 | 80,000 / 79,988 / 657,694,392 | 112,012 | 48,102 | 3,072,332,304 | 5,610 |
| fold-map | 32,000 | 0 / 0 / 0 | 12 | 55 | 1,310,656 | 0 | 160,000 / 159,987 / 2,630,885,240 | 224,012 | 96,117 | 12,288,664,592 | 13,610 |

What the table shows:

* **The quadratic term is gone.** Consumed, the census's fold copies 0
  elements at every size, makes 2 heap allocations (the vector's header and
  the program's List) and grows its backing 14 times for 32,000 pushes
  (262,144 bytes) -- exactly the outer local's row, the census's efficient
  idiom. Copying, it made 32,002 allocations, allocated 4,095,872,048 bytes
  of backings (n detaches of a growing prefix) and ran 6,629 collections.
* **Every idiom the consumption reaches behaves the same**: the struct of
  two vectors, the fold that continues before its push, and the MutableMap
  intermediate (whose copying run allocated 12.3 GB of backings at 32,000
  insertions) all copy nothing; their growths are their collections' own.
* **The negative control keeps its copies**: `fold-skip-after` (a
  `continue` after the push, census c08) makes n shares, n detaches and
  n(n-1)/2 copied elements with the consumption on and off -- its exit
  needs the iteration's starting value, and the rule leaves it alone.
* **Nothing else moves**: the outer local and the threaded working copy, no
  folds, have identical counters both ways.

## 15. Runtime benchmarks

*Observation*, the same run: the best of 3 in-process executions (no
process start: `native::measure`) and of 3 whole driver processes (start-up
included, as `fold-cost.tcl` measures):

| idiom | n | consumed in-process (µs) | copying in-process (µs) | consumed process (µs) | copying process (µs) |
|---|---:|---:|---:|---:|---:|
| fold-intermediate | 1,000 | 5 | 416 | 8,060 | 9,226 |
| fold-intermediate | 4,000 | 17 | 4,284 | 7,943 | 15,047 |
| fold-intermediate | 16,000 | 68 | 46,820 | 8,001 | 71,993 |
| fold-intermediate | 32,000 | 131 | 228,076 | 8,564 | 322,002 |
| outer-local | 1,000 | 4 | 6 | 8,899 | 8,422 |
| outer-local | 4,000 | 17 | 21 | 8,057 | 7,978 |
| outer-local | 16,000 | 68 | 85 | 8,594 | 8,261 |
| outer-local | 32,000 | 120 | 160 | 8,138 | 8,663 |
| threaded-copy | 1,000 | 4 | 4 | 10,936 | 10,746 |
| threaded-copy | 4,000 | 16 | 24 | 11,318 | 11,056 |
| threaded-copy | 16,000 | 90 | 72 | 11,466 | 14,856 |
| threaded-copy | 32,000 | 124 | 128 | 11,058 | 11,887 |
| fold-struct | 1,000 | 5 | 428 | 11,499 | 12,794 |
| fold-struct | 4,000 | 18 | 2,525 | 11,650 | 15,110 |
| fold-struct | 16,000 | 75 | 35,550 | 11,546 | 59,317 |
| fold-struct | 32,000 | 173 | 205,872 | 11,479 | 284,243 |
| fold-skip-first | 1,000 | 5 | 592 | 8,853 | 10,783 |
| fold-skip-first | 4,000 | 20 | 2,954 | 8,741 | 12,915 |
| fold-skip-first | 16,000 | 117 | 46,962 | 9,568 | 73,393 |
| fold-skip-first | 32,000 | 128 | 239,500 | 9,556 | 304,138 |
| fold-skip-after | 1,000 | 451 | 407 | 13,668 | 11,991 |
| fold-skip-after | 4,000 | 4,442 | 2,957 | 12,749 | 12,640 |
| fold-skip-after | 16,000 | 47,739 | 46,039 | 69,963 | 70,876 |
| fold-skip-after | 32,000 | 227,714 | 229,852 | 297,396 | 307,032 |
| fold-map | 1,000 | 240 | 2,597 | 218,286 | 310,015 |
| fold-map | 4,000 | 614 | 26,437 | 328,013 | 363,472 |
| fold-map | 16,000 | 2,652 | 723,243 | 341,473 | 1,108,290 |
| fold-map | 32,000 | 5,519 | 3,320,624 | 356,956 | 4,469,449 |

In-process (no start-up), the census's fold at 32,000 pushes runs in 131
µs consumed against 228,076 µs copying -- about 1,700 times faster, and
linear (5, 17, 68, 131 µs at 1,000 to 32,000: the vector's growth, like the
outer local's 4, 17, 68, 120 µs). Whole processes are dominated by the
driver's fixed cost (lowering the HIR to NIR, code generation, start-up:
about 8 ms for these programs, about 0.3 s for the MutableMap program,
which compiles the ordered-table engine), so a consumed fold's process time
no longer grows with n. The negative control is quadratic both ways (about
228 ms at 32,000), as it must be. Times vary by a few percent from run to
run on this container; the counters are exact.

And the census's own tool, unchanged, on the new tree
(`audit/construct-binding-mutation/tools/fold-cost.tcl`):

| idiom | n | best (µs) | shares | detaches | elements copied |
|---|---:|---:|---:|---:|---:|
| fold intermediate (a02) | 1,000 | 8,054 | 0 | 0 | 0 |
| | 4,000 | 8,207 | 0 | 0 | 0 |
| | 16,000 | 8,048 | 0 | 0 | 0 |
| | 32,000 | 8,321 | 0 | 0 | 0 |
| outer local (a03) | 1,000 to 32,000 | 7,729 to 8,049 | 0 | 0 | 0 |
| threaded working copy (a04) | 1,000 to 32,000 | 10,723 to 11,008 | 0 | 0 | 0 |

(An idle machine. A rerun on the final tree while `tests/local.tcl` used
the container's four cores gave the same counters and 8.9 to 11.9 ms for the
fold: start-up and load, flat in n.)

## 16. Fuzzing and mutation testing

**The fuzzer** (`audit/consumed-folds/tools/fuzz.tcl`) generates folds over
a List, a counted range or nothing (a bare fold ended by a `break`), with a
MutableVector or a struct of two intermediate, whose bodies mix pushes, a
place parameter's helper, observations recorded into an outer log (a
length, a sum through an observing function), a local copy pushed, inner
loops with their own exits, handled calls whose handler continues or
recovers, nested folds whose initial value is the intermediate, `if`s, and
the fold's own `continue` and `break` before and after any of them; initial
values fresh or a vector the function reads after the fold; completions the
intermediate, a struct literal of its fields (or with a field another binding
holds), a fresh vector, that outer vector or an `if` of two. Each program is
compiled with the consumption on and off and run on the four backends; all
outcomes must be one.

| seed | programs | folds not copied at entry | folds copied at entry | folds with their own exits | disagreements | rejected |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 150 | 294 | 46 | 115 | 0 | 0 |
| 2 | 150 | 298 | 45 | 102 | 0 | 0 |
| 3 | 150 | 296 | 47 | 104 | 0 | 0 |
| 4 | 200 | 378 | 76 | 155 | 0 | 0 |
| 5 | 200 | 379 | 72 | 154 | 0 | 0 |
| 7, `-gc-stress 1` | 100 | 190 | 36 | 77 | 0 | 0 |
| **total** | **950** | **1,835** | **322** | **707** | **0** | **0** |

("Not copied at entry" counts every fold whose intermediate is not renamed
`NAME#entry`: consumed ones, and the ones nothing mutates, which were never
copied.)

`-fault exits` (every fold's exits clean) and `-fault incoming` (no
exclusive incoming values) make the consumption unsound in the fuzzer's
process: the comparison then finds 25 and 17
disagreements among 150 programs (seed 1) -- the fuzzer sees the bugs it
is there to see.

**Mutation testing** (`audit/consumed-folds/tools/mutate.tcl`): 20
mutants, each a deliberate break of one rule, applied to a private copy of
the compiler; a mutant counts as killed only when a test its `!!` line names
fails.

| mutant | killed by |
|---|---|
| `give-away-place-ignored` | cfi-exit-after-conditional-mutation, cfi-exit-after-give-away, cfi-exit-after-mutation |
| `give-away-move-ignored` | cfi-exit-after-give-away |
| `give-away-reads-count` | cfi-exit-before-mutation |
| `give-away-int-field` | cfi-int-field-read |
| `walk-else-ignored` | cfi-exit-after-conditional-mutation |
| `walk-condition-ignored` | cfi-exit-after-conditional-mutation |
| `walk-handlers-ignored` | cfi-exit-after-conditional-mutation |
| `walk-loop-body-ignored` | cfi-exit-after-give-away |
| `walk-loop-operands-ignored` | cfi-exit-after-conditional-mutation |
| `incoming-initial-dropped` | cfi-error-leaves-fold, cfi-initial-shared, cfi-mutable-array |
| `incoming-completions-dropped` | cfi-completion-shared, cfi-struct-completion-fields |
| `folds-never-consumed` | cfi-exit-before-mutation, cfi-hir-text, cfi-push-consumed, cfi-push-linear |
| `fold-positions-not-exclusive` | cfi-nested-folds |
| `incoming-if-not-descended` | cfi-if-completion |
| `struct-literal-whole` | cfi-struct-completion-fields |
| `fold-value-not-fresh` | cfi-fold-value-fresh |
| `replace-child-no-fold-initial` | cfi-initial-read-out |

The unsound mutants (exits, give-aways, the walk, the incoming values) are
killed by values the copying elaboration does not give; the precision
mutants (no consumption, an `if` or a struct literal completion copied
whole, a consumed fold's value not fresh, nested folds not demanded) by the
HIR or the native copy counters. The cache key's mutant is the
hir-interchange catalog's (`key-ignores-consumed-folds`, killed by `hc-key`).

**The neighbouring catalogs.** The consumption joins the copy convention
other harnesses guard, so every existing mutant that edits
`hir/mutvec.tcl` ran again against the final tree, with its harness's own
tests: MutableVector's 38 (`audit/mutable-vector/tools/mutate.tcl -only
...`: among them `path-continue-as-break`, `path-break-copies`,
`path-loop-iteration-ignored` and the other `NoLaterUse` mutants the walk
relies on), MutableArray's 9 and MutableMap's 5 -- 52 mutants, 52 killed, 0
survived (*observation*).

## 17. Compile-time cost

*Implementation fact.* `Convention` walks the body of every reachable fold
whose intermediate may hold a header, once (`FoldExitsClean`): O(body size)
expressions, each reference to the intermediate asking `NoLaterUse`, whose
cost is the remaining statements of the enclosing sequences (the read-out
phase asks the same question of the same references). `FoldIncoming` is
O(number of completions). No fixed point is added: the convention's own
fixed point (at most 256 passes, as before) takes the fold intermediates
with the parameters.

*Observation*, `tclsh9.0 bench/consumed-folds.tcl -part compile` (the front
end, best of 3, consumption on and off):

| program | consumption on (µs) | off (µs) | on/off |
|---|---:|---:|---:|
| a02-fold-push-return.bot | 7,228 | 7,228 | 1.000 |
| a05-fold-struct-state.bot | 11,567 | 11,590 | 0.998 |
| a06-fold-nested.bot | 9,546 | 9,305 | 1.026 |
| c04-mutable-map-entry.bot | 2,432,076 | 2,420,560 | 1.005 |
| c08-fold-continue-fixed.bot | 9,193 | 9,033 | 1.018 |
| c08-fold-continue.bot | 10,616 | 10,172 | 1.044 |
| c12-mutable-set-elements.bot | 1,334,589 | 1,330,172 | 1.003 |
| p01-fold-array-unproven.bot | 11,420 | 10,838 | 1.054 |
| fold-loops.bot | 12,763,653 | 14,682,006 | 0.869 |
| mutable-vector.bot | 14,793,496 | 15,470,861 | 0.956 |
| total | 31,759,581 | 34,330,915 | 0.925 |

The two procedures the milestone adds, timed directly (a scratch wrapper
around them, the front end of one compilation each): in
`tests/golden/fold-loops.bot`'s 13.0 s front end, `FoldExitsClean` took 0.94
ms over its 6 calls and `FoldIncoming` 0.15 ms; in a02's 19 ms, 26 µs and
9 µs. The front-end differences in the table are run-to-run variation (the
small programs move both ways by up to 8%); the two golden suites compiled
faster with the consumption on, which this milestone did not attribute: the
new walk is far below that difference either way.

## 18. Remaining limitations

* **An exit after a give-away keeps the copy.** That is the semantics, not
  a missed optimization: such an exit carries the iteration's starting
  value, which only a copy keeps (c08, c09; the negative control in section
  15 stays quadratic). Rewriting such a program (completing with the
  mutated intermediate on the paths that mean to keep it, census c08-fixed)
  makes it cheap.
* **The walk is path-insensitive.** A push under `x > 1` and a `continue`
  under `x < 0` keep the copy although no execution runs both (*observation*:
  the probe `l02`, `{3 2 1}` either way). Path-sensitive facts would need
  the condition analysis's machinery; the conservative answer only costs
  the old copy.
* **Observing callees are not known yet when the exits are judged.** An
  argument of a Botlish function that only reads it, at the intermediate's
  last use before an exit (`if total(acc) > 3: break` as the last use),
  counts as a give-away: the convention computes which parameters only
  observe after its fixed point (`ObservedOnly` depends on it). Natives'
  observing roles and collection operations' receivers are known and
  inert.
* **Completions an `if` does not reach.** A handled call completing the
  body is copied whole unless fresh; an `if` without `else` completes with
  `unit` (FOLD-INTERMEDIATE-TYPE anyway).
* **A captured intermediate** (a closure in the body reading it) is never
  consumed: a closure reads its binding whenever it runs.
* **Unchanged on purpose**: the fold intermediate's array capacity proof
  (p01), affine intermediates (AFFINE-FOLD-UNSUPPORTED), the
  `DISCARDED-MUTATION` warning the census recommends (a separate milestone),
  fold syntax and rules.

## 19. Files changed and verification commands

| file | change |
|---|---|
| hir/mutvec.tcl | "Consumed fold intermediates": `FoldOf`, `FoldIncoming`, `FoldExitsClean`, `FoldWalk`, `FoldWalkSequence`, `GivesHeader`; the fold cases of `Convention` (`foldClean`), `Eligible`, `ExclusivePositions`, `Fresh` and the third phase's wraps; `consumedFolds`; `ReplaceChild` knows `foldInitial` |
| surface/cache.tcl | the key's `consumed-folds` |
| tests/consumed-fold-intermediates.test | new: 31 tests |
| tests/hir-cache.test | `hc-key` covers `consumed-folds` |
| audit/consumed-folds/tools/ | new: `fuzz.tcl`, `mutate.tcl`, `mutants.txt` |
| audit/hir-interchange/tools/mutants.txt | `key-ignores-consumed-folds` |
| bench/consumed-folds.tcl | new: the performance report |
| audit/construct-binding-mutation/ | a02's and a05's `# alloc:` lines (0 copies), the README's note |
| audit/golden/migration/census/consumed-fold-intermediates.tsv, tcl-names.txt, tests/golden/manifest.tsv | the new tests' rows (KEEP-INTERNAL) |
| docs/README.md, docs/MUTABLE-VECTOR.md, compilerpedia/topics/folds.topic, docs/INDEX.md, AGENTS.md | the documentation |

Verification (each *observed* on this branch; outputs in the sections
above):

```
tclsh9.0 tests/consumed-fold-intermediates.test
tclsh9.0 tests/local.tcl tests/fold-loops.test tests/mutable-vector.test tests/mutable-array.test tests/mutable-map.test tests/mutable-set.test tests/collection-iteration.test tests/place-parameters.test tests/nonplace-parameter-mutation.test tests/ordered-table.test tests/vector-bounds.test tests/collection-reorder.test tests/immutable-map.test tests/hir-cache.test tests/mutable-array-type.test
tclsh9.0 audit/consumed-folds/tools/fuzz.tcl -seed N -count 150
tclsh9.0 audit/consumed-folds/tools/fuzz.tcl -seed 7 -count 100 -gc-stress 1
tclsh9.0 audit/consumed-folds/tools/fuzz.tcl -seed 1 -count 150 -fault exits
tclsh9.0 audit/consumed-folds/tools/mutate.tcl
tclsh9.0 audit/hir-interchange/tools/mutate.tcl -only key-ignores-consumed-folds,key-ignores-dfa-lowering
tclsh9.0 audit/mutable-vector/tools/mutate.tcl -only NAMES   (and mutable-array's, mutable-map's: the mutants editing hir/mutvec.tcl)
tclsh9.0 audit/construct-binding-mutation/tools/run.tcl
tclsh9.0 audit/construct-binding-mutation/tools/fold-cost.tcl
tclsh9.0 bench/consumed-folds.tcl
tclsh9.0 tools/compilerpedia.tcl check
tclsh9.0 tools/mutant-catalogs.tcl
tclsh9.0 tests/local.tcl
```

`tests/local.tcl` on the final tree (every Tcl test file on interp and
compile, minus the golden duplicates; every golden suite on the four
backends, 4 jobs, 5,507 s):

```
Tcl tests on interp    8980 passed, 0 failed, 214 skipped, 2493 golden duplicates skipped
Tcl tests on compile   8975 passed, 0 failed, 219 skipped, 2493 golden duplicates skipped
Golden suites: 118 run, 0 failed; tests passed: interp 5637/5637, compile 5637/5637, cranelift-generic 5545/5545, cranelift 5647/5647
```

Also: `tests/fold-loops.test` (all 104 tests, golden duplicates included)
and `tests/consumed-fold-intermediates.test` under
`BOTLISH_NATIVE_GC_STRESS=1`, every test passing; `tools/compilerpedia.tcl
check` (1,290 topics, 759 examples, 0 problems); `tools/mutant-catalogs.tcl`
(91 catalogs, 3,198 mutants, 0 problems); the census corpus on the four
backends (41 programs, 0 failures, a02's and a05's new `# alloc:` lines
included).
