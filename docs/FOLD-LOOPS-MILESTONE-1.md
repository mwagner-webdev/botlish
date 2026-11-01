# FOLD-LOOPS-MILESTONE-1.md

Folding loops: `fold CLAUSES with intermediate acc INITIAL:` iterates exactly
as `loop CLAUSES:` does, but carries one immutable value -- the intermediate
-- from each iteration to the next, and is that value at the end.

> A "loop" collects the values produced by its iterations. A "fold" carries
> a value through its iterations. Neither requires mutation in the source
> language, and neither should require constructing values that are not
> part of its semantics.

## Outcome

* The syntax parses and runs on every backend: the reference interpreter
  (core IR), the Tcl compiler, and both native backends (cranelift-generic,
  cranelift), with standalone executables.
* Every iteration form of `loop` composes with `with intermediate`: a List,
  the four numeric forms, lockstep, a MutableMap or MutableSet through the
  loop protocol, and no clause at all (a fold ended by `break`).
* The semantics below are enforced alike everywhere: 104 Tcl tests on all
  four backends (one also as a standalone executable, plain and under GC
  stress), a 79-test golden suite on all four backends, and a mutation
  harness of 22 mutants (all killed).
* A scalar fold lowers natively to one loop-carried register. It builds no
  List, no construction plan and no MutableArray, and allocates nothing of
  its own. Struct- and List-valued intermediates work; what they cost is the
  values the program constructs (measured below).
* Existing loops are unchanged: the collecting-loop test files pass
  unchanged, and the full local suite passes (Verification).
* Two new diagnostics: FOLD-INTERMEDIATE-TYPE and AFFINE-FOLD-UNSUPPORTED.

| lex-strategy variant (this container) | time | instructions per run |
|---|---:|---:|
| bench/lex-strategy.bot (canonical) | 28.85 us | |
| chars-indexed: collect a `List[bool]`, count it | 9.26 us | 119,735 |
| chars-counted: manual self tail call with an accumulator | 1.99 us | 31,864 |
| **chars-folded: `fold` carrying the count** | **2.19 us** | **30,045** |
| chars-direct: manual tail call, direct classifier calls | 1.09 us | 18,610 |
| **chars-direct-folded: `fold`, direct classifier calls** | **1.09 us** | **17,088** |
| Go reference (bench/equivalents/go) | 1.51 us | |

The fold removes the collecting variant's `List[bool]` (4x fewer
instructions: `rt_construct` goes from 39,857 instructions per run to the
program's other 521) and runs 5-8% fewer instructions than the hand-written
tail recursion it replaces. Wall-clock differences of that size are within
this container's noise; the instruction counts are exact.

## Syntax

```
fold   = "fold" [ clause { "and" clause } ]
         "with" "intermediate" IDENT expression ":" suite
clause = IDENT "in" operand
       | IDENT [ "down" ] "from" operand ( "to" | "through" ) operand
```

The clauses are a loop's, parsed by the same procedure
(`surface::parser::LoopClauses`):

```botlish
fold x in xs with intermediate acc 0:                     # a List (or vector, map, set)
fold i from a to b with intermediate acc 0:               # and through, down from
fold x in xs and i from 0 to n with intermediate acc 0:   # lockstep
fold with intermediate state start:                       # no domain: until break
```

* `fold` is contextual. It begins a fold only when it is directly followed
  by a name (`surface::parser::AtFold`). Two adjacent names occur in no
  other construct, the same argument `static compile:` uses. So `fold = 1`,
  `fold(x)`, `x.fold` and `{fold: 1}` keep working (the pre-existing test
  `loop-collecting-no-reducing-syntax` still passes).
* `with` and `intermediate` are words of this header only. A fold's loop
  variable may even be named `with` (`fold with in xs with intermediate
  intermediate 0:` parses), because the header is decided by one token of
  lookahead after the variable, as a loop's is.
* The intermediate's name and its initial value are both required. The
  initial value is a full expression, ended by the suite's `:`, so a
  handled call cannot be an initial value: bind it first. Missing parts are
  parse errors that name what is expected.
* A fold is a *statement value*, exactly where a loop or an `if` may be: a
  statement, the right side of `=`, after `return`, a body's last
  expression. It is never an operand or a call argument; in such a
  position `fold` is an ordinary name, so `f(fold x in ...)` is a syntax
  error at the `x`.

## Semantics

1. The loop's operands (iterable, bounds, lockstep domains) are evaluated
   first, in written order, and checked (a List, Ints), exactly as the
   loop's are. **Then** the initial value is evaluated, exactly once, in
   the enclosing scope. That is the written order, and it extends the
   existing rule that a loop's operands are evaluated once, in order,
   before the first iteration.
2. An empty fold (an empty domain) is its initial value. A fold over
   `List[never]` never runs its body.
3. Each iteration binds the intermediate, fresh and immutable, to the value
   the previous iteration produced: the initial value for the first.
4. A normal completion of the body is the next intermediate.
5. `continue` keeps the current intermediate for the next iteration (the
   body's computed values are discarded).
6. A bare `break` ends the fold with the *current* intermediate: the one the
   iteration started with, never a value the body computed before breaking
   (`fold-loops-break-discards-next`).
7. Exhaustion yields the last intermediate.
8. `return`, `fail` and propagated errors leave the fold as they leave any
   loop; the fold then has no value.
9. The intermediate is bound in the body's scope only. It is not visible in
   the initial value, in the loop's operands or after the fold (UNBOUND).
   Binding its name again in the body's own scope is a DUPLICATE, so it is
   immutable within its iteration; a nested scope (an `if` branch) may
   shadow it, as with any binding. Its name may not be one of the loop's
   variables (DUPLICATE-LOOP-VARIABLE).
10. `break` and `continue` target the nearest enclosing loop or fold of the
    same function, as before; a `break` in a nested function is
    BREAK-OUTSIDE-LOOP.
11. `break VALUE` remains a syntax error. Raw core IR text that writes one
    into a fold is LISTLOOP-BREAK-VALUE with a fold-specific message.

Inventory of other control forms: `yield` inside a fold suspends the
coroutine with the intermediate live across the suspension
(`fold-loops-coroutine`); a handled call in the body is an ordinary
completion; the loop protocol of MutableMap and MutableSet rewrites a fold
into a counted fold whose skipped positions are `continue`s, which keep the
intermediate (`fold-loops-mutable-map`).

## Typing

A fold's type is its intermediate's: the join (lub) of the initial value's
type and the type of every normal completion of its body, the body typed
with the intermediate at that type. `continue` and `break` produce no value;
they are control-flow paths, never implicit producers of a default.

**Inference.** `hir::types::FoldBody` finds the type the way the checker
already finds a recursive function's result (`Block`): it walks the body
under an assumed type, first the initial value's, and again under the join
of that and the body's type until the join reproduces the assumption. The
last of `foldAttempts` (4) walks is under `any`, so a join that keeps
growing (a List nested one level deeper per iteration) ends at the dynamic
type, which is sound. Each walk starts from the same context; the final one
is kept. Typical folds converge in one walk (the initial value already has
the final type) or two (`[]` growing to `List[int]`).

**Conflicts.** Unlike an `if`, whose join is read once, a fold's join is
read again by the same body on the next iteration. So a join that only the
dynamic type covers -- an Int and a String, two different named structs,
anonymous structs of different fields, a value and the `unit` of an `if`
without `else` -- is **FOLD-INTERMEDIATE-TYPE**:

```
t.bot:3:9: the intermediate "acc" of this fold is int (its initial value),
but this completion of the body is str: a fold carries one value from each
iteration to the next, and int and str have no common type (give every
normal completion of the body the intermediate's type)
```

* The diagnostic sits at the first completion (in source order) whose type
  makes the running join collapse. An `if` or handled call whose own join
  is already `any` is looked into to name the branch responsible. A
  missing `else` is named as such: "this `if` has no `else`: when its
  condition is false it completes the body with unit".
* Its related locations are the fold and its initial value: data on the
  diagnostic, not only text.
* A value already of the dynamic type (an untyped parameter) collapses
  nothing.
* No cascade. The walk that finds the conflict makes the intermediate and
  the fold *poison* (DIAGNOSTIC-RECOVERY.md), so a field read of the
  intermediate does not restate it (`fold-loops-conflict-branch`). A
  semantic instance's walk poisons only a fold the generic walk found in
  conflict (an instance refines, it never rejects). A program compiled
  despite its diagnostics (`-strict 0`) is retyped without poison and runs
  with a dynamic intermediate.

The types the tests cover:

* Int, Bool and String intermediates.
* Lists, from `[]`, appended element by element or chunk by chunk.
* Anonymous and named structs, nested structs, structs holding Lists.
* Lists of Lists.
* A MutableVector mutated in the body, which stays a value: the entry copy,
  `fold-loops-mutable-vector`.
* Refined intermediates keep their refinement: a `Percent` fold passes
  where a `Percent` is required (`fold-loops-refined`), and a List whose
  every value has length 2 is `List[int]{length: 2}`.
* Untyped generic functions folding any values (`fold-loops-generic`).

Errors and contexts need nothing new. The initial value's errors are charged
where it is written (UNHANDLED-ERROR), and the body's errors are charged as
a loop body's. A body calling a function that requires a context the caller
installed works (`fold-loops-context`).

**Affine intermediates** are rejected: **AFFINE-FOLD-UNSUPPORTED**, at the
initial value and at a body value that would enter the intermediate.
Carrying one would move it from each iteration's binding into the next and
release it on every exit. That is an ownership protocol of its own, which
this milestone does not design.

## Implementation census and the decision

Before the change, every stage represented loops as four kinds:

| stage | representation |
|---|---|
| surface AST | one `loop` node with a `clauses` list and per-form mirror fields |
| HIR syntax / HIR | `loop`, `listloop`, `countloop`, `lockloop` (bodyScope, element/induction bindings, domains) |
| core IR | `(loop B)`, `(listloop E B)`, `(countloop S E B ?DIR KIND?)`, `(lockloop (D...) B ?REJECTED?)` |
| evaluator | `op-loop`, `op-listloop` (+ consuming vectors), `op-countloop`, `op-lockloop` |
| Tcl compiler | `CompileLoop`, `CompileListLoop`, `CompileCountLoop`, `CompileLockLoop` |
| native | `Loop`, `ListLoop` (consuming vectors, raw guards), `CountLoop` (raw induction), `LockLoop` |

About 36 compiler files switch on those kinds: the analyses (types, range,
completions, callables, signatures, cardinality, construction, escape,
affine, mutvec, iteration, relations, staticdeps, traits, static,
modulebinding, aot) and the backends.

**Decision: a fold is a loop node of any of the four kinds carrying two
more fields**, never a node kind of its own:

* `foldBinding`: the intermediate, a parameter of the loop's body scope,
  like the element binding.
* `foldInitial`: its first value, a child after the loop's operands.

This reuses every iteration form, the lockstep cardinality proofs, raw
induction registers, consuming vectors, the loop protocol of maps and sets,
the scope and control-flow machinery, and each backend's specialized
lowering of each domain unchanged. Only *result handling* differs: carrying
instead of collecting, which is what "shared iteration infrastructure,
separate collection-construction semantics" asks for. A new node kind would
have needed a fold case at every one of the ~400 sites, or a second
iteration machinery.

The risk of the decision is that an analysis treating a loop's value as a
List, or a bare loop's body value as discarded, would silently mistreat a
fold. Every site was audited (the list follows). The mutation harness
checks the dangerous ones: a fold credited with its domain's length, a fold
body value taken for discarded, an initial value left uncharged.

## Representation and lowering, stage by stage

* **Parser** (surface/parser.tcl): `Fold` (sharing `LoopClauses` and
  `LoopNode` with `Loop`) yields a `loop` AST node with a `fold` field
  `{name nameSpan initial}`. The AST walkers (ids, children, map, printer)
  include the initial value after the operands.
* **Surface lowering** (surface/lower.tcl): `LoopSyntax` builds the loop's
  syntax node as before; `hir::syntax::withFold` adds `fold {name origin
  initial}`. Syntax walkers (static decisions, trait stamps, module
  remapping, bind names) visit the initial value through
  `hir::syntax::foldChildren`/`mapFold`.
* **Resolution** (hir/resolve.tcl): the initial value is resolved in the
  enclosing scope after the operands (`ResolveFoldInitial`); the
  intermediate is a fresh `param` binding of the iteration scope after the
  loop's own variables (`BindFold`).
* **Types**: `FoldInitial`, `FoldBody`, `FoldResult` (above).
  **hir/fold.tcl**: what a conflict is, and its report.
* **Core IR**: `(fold INIT LOOP)`, LOOP any loop form whose block binds the
  intermediate last (`core::ir::foldLoop`, `foldIntermediate`). HIR text
  prints `... fold (bN NAME)` on the loop's header and reads it back; HIR
  interchange carries the fields unchanged.
* **Evaluator**: each loop op takes an optional initial expression and keeps
  a result state (`Results`, `ResultBind`, `ResultAdd`, `ResultValue`): a
  List being collected, or the intermediate.
* **Tcl compiler**: the intermediate is the loop's accumulator variable,
  `set` instead of `lappend` (`FoldStart`, `FoldBind`, `ResultLine`,
  `ResultFinish`); a fold's `break` sets the result to it.
* **Native** (native/lower.tcl): `LoopResultStart`, `LoopResultBind`,
  `LoopResultAdd`, `LoopResultFinish` and a `fold` mode in the shared
  `loops` entry that `break` reads. The intermediate is one ordinary
  register, defined before the loop head, redefined by a `move` at the end
  of every normal completion of the body, untouched by `continue` (whose
  jump skips the move), moved into the result at exhaustion and at a
  `break`. This is the multi-definition register pattern the `if` join and
  the induction register already use, so no new NIR exists.

The NIR of `sum` (`fold x in xs with intermediate acc 0: acc + x`), its constants left out:

```
    %1 = op listlen %0
    %4 = move %2                  ; index 0
    %8 = move %6                  ; the intermediate := 0
  label L0
    %9 = op ilt %4 %1
    br %9 L1 L3
  label L1
    %10 = op listget %0 %4
    %11 = op iadd %8 %10          ; acc + x
    %8 = move %11                 ; the next intermediate
    jump L2
  label L2
    %14 = op iadd %4 %12
    %4 = move %14
    jump L0
  label L3
    %5 = move %8                  ; exhaustion: the intermediate
    ret %5
```

**Analyses audited**, and what each needed:

* `hir/aot.tcl`: a fold's body value is used, in the bare form too. This
  was a real bug, found by a struct fold that built `unit`.
* `hir/coroutines.tcl` (`Discarded`): a fold's body value is never
  discarded.
* `hir/completions.tcl`: the initial value walked after the domain, the
  intermediate unseeded, both values entering it subsumed against its type.
* `hir/range.tcl`: the initial value visited; the intermediate and the
  fold's value `unknown`.
* `hir/cardinality.tcl`: a fold is no collecting loop, so never a
  domain-length fact. The intermediate's length is its type's.
* `hir/callables.tcl`: typed-callable preservation of both values entering
  the intermediate.
* `hir/signatures.tcl`: both values flow (unmodeled).
* `hir/construction.tcl`: the initial value is in the once-evaluated
  prefix.
* `hir/escape.tcl`: the initial value is outside the loop; the body's
  trailing value is a trailing position.
* `hir/affine.tcl`: AFFINE-FOLD-UNSUPPORTED.
* `hir/mutvec.tcl`: the entry copy of a mutated MutableVector intermediate
  renames `foldBinding`.
* `hir/iteration.tcl`: the loop protocol rewrite keeps the fold.
* `hir/relations.tcl`: the initial value is an operand; a fold's value
  carries no relational fact.
* `hir/staticdeps.tcl`: the intermediate is defined by the whole fold.
* `hir/traits.tcl`: sid stamps; the witness-join check covers folds.
* `hir/modulebinding.tcl`: context freedom sees the initial value; a fold
  is never retained as a List.
* `hir/static.tcl` and `surface/modules.tcl`: the syntax walks.
* `native/rawabi.tcl`: values entering the intermediate are tagged
  consumers.
* `native/lower.tcl`'s guard accounting (`SkipAfter`).

## Performance

All measurements on this container: Linux x86-64, 4 cores, Xeon,
Go 1.24.7, the release native backend. Timings are best of 60 runs, two
passes, JIT excluded (`audit/bench-bimodality/tools/measure.tcl`).
Instruction counts are callgrind's per run: the difference of a 4- and a
24-run profile (`profile.sh`). They are deterministic, which this shared
container's timings are not: the same program varied by up to 1.5x
between passes, so the instruction counts carry the comparisons.

### lex-strategy

The new variants, in `audit/bench-bimodality/variants/`:

* `lex-strategy-chars-folded` is `lex-strategy-chars-indexed` with
  `classify` (a collecting loop building a `List[bool]`) and `count_true`
  replaced by one fold carrying the count. The classifier is still the
  callable value chosen at the `if` join, and the characters are still
  read by index.
* `lex-strategy-chars-direct-folded` is `lex-strategy-chars-direct` with its
  tail-recursive `count_from` written as a fold.

Each fold variant differs from a manual variant only in how the count is
carried.

| variant | time (best of passes) | instructions/run | generated | helpers | allocator | `rt_construct` |
|---|---:|---:|---:|---:|---:|---:|
| bench/lex-strategy.bot | 28.85 us | | | | | |
| lex-strategy-indexed | 14.74 us | | | | | |
| lex-strategy-chars | 22.42 us | | | | | |
| chars-indexed (collect, count) | 9.26 us | 119,735 | 14.2% | 49.4% | 25.4% | 39,857 |
| chars-counted (tail recursion) | 1.99 us | 31,864 | 39.8% | 49.3% | 6.7% | 521 |
| **chars-folded** | 2.19 us | **30,045** | 36.2% | 52.3% | 7.1% | 521 |
| chars-direct (tail recursion) | 1.09 us | 18,610 | 65.2% | 16.2% | 11.5% | 521 |
| **chars-direct-folded** | 1.09 us | **17,088** | 62.2% | 17.7% | 12.4% | 521 |

* **No allocation of its own.** The fold variants' allocator instructions
  and `malloc` counts equal the manual variants' (`malloc` 470 vs 472
  instructions per run). The 521 instructions of `rt_construct` belong to
  the program's other collecting loop (`alnum_only_tokens`), identical in
  all four.
* **The fold's own function is the cheapest form of the count.**
  `valid_chars` as a fold executes 5,511 instructions per run; the
  equivalent `count_from` executes 6,889. In the direct pair the counting
  code is 7,361 vs 7,426 instructions.
* **Its NIR** (`chars-direct-folded`'s `valid_chars`): the induction
  register is raw (`rilt`, `riadd`), the character read is
  `strcharatproven` (the bound proof survives), and the count is one
  tagged register moved at the back edge. It has no `listnew`,
  `construct`, `mutarray` or `structnew`.
* **What remains is not the fold's.** `rt_call_value` + `invoke_native`
  (8,184 instructions, 27%) in the callable-value pair is
  BENCHMARK-SLOWDOWN-CAUSES.md's cause 5. The count stays a *tagged* Int
  with overflow checks: no range is proven for an intermediate (next
  section).
* Historical reference points (BENCHMARK-SLOWDOWN-CAUSES.md, another
  machine): counted 1.93 us, direct 1.03 us. Measured here: 1.99 and 1.09.
  Go here: 1.51 us.

### Stateful scanner (`audit/fold-loops/workloads/scanner-*.bot`)

A cursor scanner over 218 characters counts identifiers and integers, sums
the integers, tracks the deepest parenthesis nesting and skips `#`
comments. Its state is a struct of six fields, the cursor among them. The
cursor advances by a variable amount per step: a whole identifier, number
or comment at once. The three idioms are checked against an independent
Python model (value `[26, 15, 1116, 3]`):

* `scanner-fold`: a fold with no domain carrying a `Scan` struct, ended by
  `break`. The token ends are folds too: an Int cursor, and a `Number
  {pos, value}` for digits.
* `scanner-recursive`: the same transitions as self tail calls, the state
  as six parameters.
* `scanner-cells`: the pre-fold mutable idiom, one-slot MutableArrays
  updated by a bare loop (as json-parse keeps its cursor).

| idiom | time | instructions/run | allocator | generated |
|---|---:|---:|---:|---:|
| fold (struct state) | 12.65 us | 137,280 | 59.5% | 20.1% |
| tail recursion (state in parameters) | 1.57 us | 25,192 | 3.5% | 87.2% |
| MutableArray cells | 3.63 us | 56,437 | 35.8% | 46.4% |

* **Semantics hold.** Realistic transitions (variable steps, nested folds
  for the token ends, state updated in every branch) are direct to write
  and agree on every backend.
* **No mutable container.** The NIR of `scan` and `number_at` holds no
  MutableArray and no List. Each iteration allocates exactly the struct
  the program constructs: one `structnew` per branch, and `number_at` one
  `Number` per digit.
* **That struct is the whole gap.** The recursion passes the six fields as
  parameters and builds `Scan` once, at the end. The fold materializes a
  struct per step: 121 `Scan` and 39 `Number` structs per run, about 500
  allocator instructions each, frees included. This is *not* fold bookkeeping (the fold adds
  nothing to what the body builds), but it is what a struct intermediate
  costs today: no scalar replacement keeps a loop-carried struct in
  registers. The cells idiom avoids the per-step struct, but pays for
  every slot access through a MutableArray header.

### Chunk-producing fold (`audit/fold-loops/workloads/chunks-*.bot`)

Tokens are split into chunks: a separator closes the current chunk (zero
or one chunk added), a negative token adds two chunks (`[t]`, `[-t]`), and
any other token extends the current chunk. Checked against Python; value
at n=128: `[56, 117, 5556]`.

* `chunks-fold`: a fold carrying `Chunks {done: List[List[int]], current:
  List[int]}`.
* `chunks-recursive`: the same as a self tail call.
* `chunks-vector`: MutableVectors pushed in place.

| idiom | n = 128 | n = 1024 | instr/run (128) | instr/run (1024) | per token (128 -> 1024) |
|---|---:|---:|---:|---:|---:|
| fold | 30.3 us | 253.6 us | 331,077 | 3,550,985 | 2,587 -> 3,468 |
| tail recursion | 16.2 us | 145.5 us | 222,405 | 1,965,589 | 1,738 -> 1,920 |
| MutableVectors | 19.1 us | 256.8 us | 269,178 | 2,168,928 | 2,103 -> 2,118 |

* **Correct under immutable value semantics**, at every size, on every
  backend.
* **Why the recursion is cheaper.** The existing virtual-construction pass
  (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md) makes a self tail call's List
  parameter a *plan register* (`planregs`): `done.append(...)` extends a
  plan in place and is materialized once. The fold's intermediate is a flat
  register, so every `done.append(current)` copies the List
  (`op listappend`), and the cost per token grows with the List (2,587 ->
  3,468 instructions). Add one `Chunks` struct per iteration.
* This is the construction-fusion work the milestone defers, not a fold
  defect: a fold whose intermediate (or a List field of it) is only
  extended could carry a plan, exactly as `CollectStart` does for a
  collecting loop and as plan parameters do for recursion.

### The acceptance criterion

Scalar folding introduces no intermediate List construction, no
mutable-array bookkeeping and no allocation inherent to folding: the
lex-strategy fold allocates exactly what the manual count allocates, and the
NIR of every scalar fold in the tests has no `listnew`, `listappend`,
`construct`, `mutarray` or `structnew` (`fold-loops-nir-scalar`,
`-nir-count-raw`, `-nir-bool-and-break`).

## Compiler economics

**Reuse.** No IR node kind, NIR instruction, runtime helper or analysis
pass was added; one check was (hir/fold.tcl, 150 lines with comments). The
change is 1,649 added and 242 removed lines over 35 compiler files, about
half of them comments. The largest parts:

* `hir/types.tcl` (193): the fixpoint and its poison.
* `native/lower.tcl` (151): shared result handling, which replaced three
  copies of the collecting code.
* `compiler/compiler.tcl` (138), `core/evaluator.tcl` (117) and
  `surface/parser.tcl` (116).

Every other file is a handful of lines at the sites that know loop kinds.

**Inference** is extended locally: the fold's own bounded fixpoint, the
mechanism `Block` uses for recursion. There is no new whole-program
analysis.

**Cost of the fixpoint** (`audit/fold-loops/tools/economics.tcl`, which
counts the type walk's entries into fold bodies over a whole compilation).
A fold whose initial value already has its final type converges in one walk
of its body, and one whose join grows (`[]` to `List[int]`) in two. Nested
folds multiply: each attempt of an outer fold re-walks the inner ones, and
every named function is itself typed at least twice (`Block`'s result
assumption):

| program | fold body walks | front end | NIR | code bytes |
|---|---:|---:|---:|---:|
| nested-1 (`[]` grown by 1 fold) | 2 | 19 ms | 30 | 671 |
| nested-2 | 6 | 26 ms | 59 | 1,451 |
| nested-3 | 14 | 37 ms | 88 | 2,553 |
| nested-4 | 30 | 91 ms | 117 | 3,470 |
| nested-5 | 62 | 166 ms | 146 | 4,389 |

Walks grow as 2^(d+1) - 2 in the nesting depth d of folds that each need
two attempts. Lowering stays linear (NIR and code grow by a constant per
level). Depth 2-3 is cheap; depth 5 of growing Lists is unusual, but it is
exponential, and caching an inner fold's result across an outer fold's
attempts would make it linear.

**Compile time and code size against the manual forms.** Folds compiled
faster than the equivalent self tail recursion in every pair, in both
orders of a run (best of 5, this process):

| pair | front end (fold / manual) | NIR (fold / manual) | code bytes (fold / manual) |
|---|---:|---:|---:|
| lex-strategy chars-folded / -counted | 70 / 123 ms | 187 / 186 | 2,712 / 2,860 |
| lex-strategy direct-folded / -direct | 76 / 103 ms | 184 / 183 | 2,708 / 2,766 |
| scanner fold / recursive | 95 / 87 ms | 286 / 183 | 4,356 / 3,165 |
| chunks fold / recursive | 58 / 134 ms | 200 / 506 | 4,110 / 10,468 |

The recursion's extra cost is semantic instances. `chunks_from` is
specialized six times for the List element types its accumulators take
(`List[never]`, `List[List[never]]`, ...); the fold is typed once by its
fixpoint. The scanner fold is larger than its recursion because every
branch builds the six-field struct.

## Tests

* **tests/fold-loops.test** (104 tests). The behavioral tests run on
  interp, compile, cranelift-generic and cranelift and fail unless all four
  agree. They cover:
  - every iteration form and empty domains, singleton and multi-element
    folds, the bare form ended by `break` and by `return`, arbitrary
    precision;
  - `continue` first, after work and on every iteration; `break` first,
    later, and after the body computed its next value;
  - evaluation order and exactly-once evaluation through a MutableVector
    log written by a place-parameter function (operands, then the initial
    value; also empty and bare folds);
  - initial-value, iterable and body errors and their order, `return`, and
    handled errors in the body;
  - scope: no leak, not in the initial value or the operands, immutability,
    shadowing in a branch and of an outer name, duplicate names;
  - nesting both ways, with break and continue targeting the inner
    construct;
  - every position: binding, argument after binding, `return`, last
    expression, `if` value, top level, statement;
  - every intermediate kind (above);
  - higher-order bodies, closures capturing the iteration's intermediate,
    contexts, coroutines;
  - the diagnostics, with locations, messages and related locations; no
    cascade; the lenient run; the cardinality guard;
  - a fold whose own value is discarded (a statement, the bare form) still
    uses its body's value: an affine body value is rejected and a yield
    completing the body is a used yield (its helper's protocol defaults to
    the zero-message one), exactly as in a bound fold;
  - the parser: every form, contextual words, every missing part;
  - the HIR fields, the HIR text round trip run on two backends, core IR
    lowering and hand-written core IR text on all four backends, and NIR
    (no allocation op; the carried register; the raw induction);
  - a standalone executable, plain and under `BOTLISH_NATIVE_GC_STRESS=1`
    (a collection at every allocation, while the carried register holds
    the only reference to a List or a struct).
* **tests/golden/fold-loops.bot** (79 golden tests, all four backends): the
  source-expressible tests ported to Botlish's own test framework, written
  with its fragment from one table by
  `audit/fold-loops/tools/golden-port.py`. The census
  (`audit/golden/migration/census/fold-loops.tsv`) and the manifest record
  every Tcl test: 77 ported (two of them split into two golden tests), 17
  KEEP-INTERNAL, 7 KEEP-PARSER, the standalone-executable test
  KEEP-MULTI-PROGRAM, and 2 KEEP-NOT-EXPRESSIBLE (they observe a rejected
  program's second diagnostic, which a static compile block does not
  reify).
* **The mutation harness** (`audit/fold-loops/tools/mutate.tcl`, 22
  mutants, Verification).
* **The workloads** (`audit/fold-loops/workloads/`) agree with independent
  Python models on all four backends and are warning-clean under
  `-warnings error`.

## What remains inefficient, and the next steps

1. **Loop-carried structs are materialized every iteration.** This is the
   scanner's whole gap (137,280 vs 25,192 instructions). Scalar replacement
   of a fold's intermediate would extend the `if` join's virtual struct
   (one register per field) to the loop head. Escape analysis would have
   to prove that the intermediate is only projected and rebuilt. It is the
   state optimization this milestone deliberately did not attempt.
2. **List intermediates copy on every append.** The chunks fold is 1.8x
   its recursion. Carrying a construction plan through a fold whose
   intermediate (or a List field of it) is only extended is the
   construction fusion of the planned progression: `std::list::flat`
   first, then fusing folds, collecting loops and `flat`.
3. **Int intermediates stay tagged.** A count is checked for overflow on
   every step because no range is proven for an intermediate (the range
   analysis leaves it unseeded). A bound such as "at most the number of
   iterations so far" would let a counting fold run raw, as the induction
   register does.
4. **The type fixpoint is exponential in the nesting depth** of folds that
   need two attempts each (2^(d+1) - 2 walks). Caching an inner fold's
   converged type across its outer fold's attempts would make it linear.
5. **Affine intermediates** (AFFINE-FOLD-UNSUPPORTED) need an ownership
   protocol: a move from each iteration's binding into the next, and
   releases on `break`, `return` and errors.

The next milestone, as planned: **`std::list::flat[T](lists: List[List[T]])
-> List[T]`**, removing exactly one level of nesting, in order, in linear
time. Only once fold and flat each have an independent, correct
implementation should the compiler fuse their construction patterns. The
plan-register observation above (2) is the concrete starting point.

## Documentation

* docs/README.md: the surface rules (section 17, "Folding loops"), with the
  collecting-loop / folding-loop distinction, and core IR's `(fold INIT
  LOOP)` (section 4).
* docs/INDEX.md.
* AGENTS.md: "Folding loops", the invariants and what to run.
* Compilerpedia: `concept.folds`, `error.fold-intermediate-type` and
  `error.affine-fold-unsupported` (compilerpedia/topics/folds.topic). The
  primer, `task.accumulate`, `capability.map-filter` and `concept.loops`
  previously said that Botlish has no fold; they now point to it.

The design principle, as the reference states it: *iteration, aggregation
and construction are distinct operations. Botlish expresses them
explicitly, while the compiler may eliminate intermediate representations
when their elimination preserves observable semantics.* `std::list::flat`
and construction fusion are future directions; neither exists yet.

## Verification

PENDING

## Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/fold-loops.test
tclsh9.0 tests/local.tcl tests/golden/fold-loops.bot
tclsh9.0 audit/fold-loops/tools/mutate.tcl
V=audit/bench-bimodality/variants
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 60 bench/lex-strategy.bot \
    $V/lex-strategy-chars-indexed/lex-strategy.bot $V/lex-strategy-chars-counted/lex-strategy.bot \
    $V/lex-strategy-chars-folded/lex-strategy.bot $V/lex-strategy-chars-direct/lex-strategy.bot \
    $V/lex-strategy-chars-direct-folded/lex-strategy.bot
bash audit/bench-bimodality/tools/profile.sh $V/lex-strategy-chars-folded/lex-strategy.bot 4 24
W=audit/fold-loops/workloads
bash audit/fold-loops/tools/measure.sh -runs 60 -sizes "128 1024" $W/scanner-*.bot $W/chunks-*.bot
tclsh9.0 audit/fold-loops/tools/economics.tcl $V/lex-strategy-chars-*/lex-strategy.bot $W/*.bot
```
