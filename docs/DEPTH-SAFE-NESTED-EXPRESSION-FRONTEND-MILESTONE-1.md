# DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md

A syntactically valid Botlish program is no longer rejected, and no
compilation fails, because of how deep the program nests.

> The nesting depth of a syntactically valid Botlish expression must not be
> limited by the Tcl interpreter's call stack. Removing host recursion from
> the parser is incomplete if the same nested program merely overflows the
> next frontend phase.

## Contents

1. Result
2. Starting failures
3. Why the host's depth decided programs
4. The frontend census
5. The mechanism: recursion in segments (core/deep.tcl)
6. Parser architecture
7. Parentheses, unary and binary nesting, flat chains
8. Lists, struct constructions, calls and postfix chains
9. Statement nesting: blocks, functions, handlers, elif chains
10. Mixed nesting
11. HIR build, resolution, typing, the analyses
12. Lowering and code generation
13. Diagnostics and recovery
14. Evaluation and error order
15. Affine values
16. Quadratic costs found on the way
17. hir::semantic's host-depth decision
18. Oracle, fuzzer, probe
19. Mutation testing
20. Performance
21. HIR, cache, isolation, the service
22. The run (the reference interpreter)
23. Regression and CI
24. Remaining recursion: the final census
25. Explicit limitations
26. Next milestone
27. What to run when changing this

## 1. Result

Every specimen family -- parentheses, unary minus and `not`, binary
arithmetic nested right and left, a flat operator chain, List literals,
named struct constructions, projection chains, calls, method chains, `or`
and `and` chains, `elif` chains, nested `if` blocks, nested function
declarations, nested handlers, and all of them mixed -- compiles 1000 deep
at Tcl's *default* recursion limit of 1000 nested evaluations, through every
compile-time path (the front end with every warning pass, HIR text printed
and read back, interchange text, core IR and its check, the Tcl compiler,
native lowering, a trait program, a coroutine program, a `static compile:`
block, an imported module, the compiler service), and runs on all four
backends with the value its structure gives it. Parentheses and List
literals compile 5000 deep; the fuzzer compiles mixed programs 1500 deep.

The walks are unchanged. Each procedure whose recursion follows the
program's nesting (132 of them, `audit/depth-safe-nesting/census.tsv`)
starts with one guard:

    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}

Past a segment's 60 frames, the guarded call does not call deeper: it goes
on in a new *segment* -- a Tcl coroutine holding its caller's variables --
and the segment it leaves is suspended on a driver's explicit stack. The
driver resumes every segment from its own shallow frame, and Tcl counts a
coroutine's evaluations from where it is resumed, so the interpreter's
nesting stays at most one segment deeper than the driver whatever the
program's depth. No recursion limit is raised (the front end's former floor
of 100000, `hir::Deep`, is gone), nothing catches TCL LIMIT STACK, and no
nesting limit or diagnostic was added.

On the way, the front end's memory went from superlinear to linear in the
nesting: Tcl 9.0.1 gives nested syntax nodes string representations in
`concat`, `regexp` and `string first`, which made a List literal 400 deep
take 590 MB and one 1000 deep exhaust the machine. And one host-depth
decision went: hir::semantic declined semantic instances where Tcl's frames
were 700 deep.

## 2. Starting failures

Measured on the revision before this milestone (`c483709`) with
`audit/depth-safe-nesting/tools/specimens.tcl`'s programs, the front end and
every lowering at Tcl's default limit of 1000, bisected
(`baseline.tcl`, the largest depth that compiled and the first that did not,
with the procedure repeated most in the error's stack):

FIXME baseline table

Under main.tcl, which raises the limit to 100000 for the programs it runs
(`core::useProgramRecursionLimit`), the parser reaches further, but memory
does not (section 16): a List literal 400 deep took 590 MB and 2.3 s, and
1000 deep was killed for lack of memory; `handler` 400 deep took 6.9 GB.

The motivating failure (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md,
section 22) was `S0 {next: S1 {next: ... S96 {c: make(1)}}}`: "too many
nested evaluations (infinite loop?)", errorcode TCL LIMIT STACK, before any
analysis ran. It compiles now 1000 deep (`dsn-affine-chain`, section 15).

## 3. Why the host's depth decided programs

Tcl 9 runs a procedure call without growing the C stack (its non-recursive
engine, NRE), but it counts nested evaluations and stops at `interp
recursionlimit` (1000 by default): "too many nested evaluations (infinite
loop?)". The front end's walks are recursive procedures, one or more Tcl
evaluations per level of the program's nesting: the parser's productions
(ten per parenthesis: Expression, Conjunction, Logical, Inversion,
Comparison, Additive, Multiplicative, Unary, Postfix, Primary), then every
walk over the AST, the HIR syntax and the HIR. So the deepest compilable
program was about 1000 divided by the frames one level costs: 81
parentheses.

The compiler had worked around it in two ways. main.tcl raises the limit to
100000 before compiling (for the programs the Tcl backends run), and
`hir::Deep` raised it to at least 100000 around the HIR build, the checks,
the warning passes, native lowering and the Tcl compiler
(COMPILER-BOTTLENECKS.md, 4.4, for the completion analysis' static call
chains). Neither covered the parser called from a test or a tool, and
either only moved the bound: deeper programs failed the same way, and a
C-recursive command on the path (a variable trace, `lsort -command`) would
have exhausted the C stack instead.

## 4. The frontend census

`audit/depth-safe-nesting/tools/census.tcl` traces every procedure of the
compiler (surface, hir, core's IR check and Tcl compiler, native lowering,
the service) while each specimen kind 24 deep goes through each scenario
(`scenarios.tcl`: the nine paths of section 1), and counts each procedure's
simultaneous activations. One active at least 12 times at once recurses with
the nesting. `probe.tcl` runs every specimen 1000 deep through every
scenario at the default limit and names the procedures a TCL LIMIT STACK's
stack repeats. The census found 132 procedures:

FIXME census table by phase

Every one carries the guard; `tests/depth-safe-nesting.test`'s
`dsn-census-guarded` checks that each listed procedure starts with it,
that no other procedure carries one, and that no compile-time file reads
`info level` for anything else.

What the census leaves out on purpose:

* **Recursion over finite structures** -- types (`hir::types::show`, the
  type lattice), declarations, slots, layouts, type arguments -- whose
  depth the program's declarations bound, not its expressions. Their
  nesting is bounded by the applied-type bound (`hir::types::MakeApplied`)
  or the declaration graph (OWNED-RECURSION-DECLARATION-SUMMARY-
  MILESTONE-1.md); the static census of self-recursive procedures
  (section 24) lists them.
* **The reference interpreter's run** (section 22).

## 5. The mechanism: recursion in segments (core/deep.tcl)

The prompt preferred explicit work stacks. Rewriting 132 procedures --
the type checker's `Expr`, the range analysis, the completion analysis,
native lowering's 13,000 lines -- each into continuation-passing style over
its own explicit stack would have been the largest change to the compiler
since HIR, with every walk's evaluation order, error order and state
threading re-derived by hand. The smallest coherent change is one explicit
stack that every walk shares: the stack of suspended segments.

* **The guard.** The first statement of every census procedure. Below the
  bound it costs a bytecoded `info level` and a variable read. Past it,
  `tailcall` replaces the guarded call by `core::deep::descend` with the
  call's own words, in the guarded call's caller's frame.
* **descend** makes a new segment: a coroutine (an `apply` of one cached
  lambda per namespace) that will run the same command. Inside the driver's
  running segment it yields `{descend SEG}` to the driver and waits;
  outside any driver (a walk called from a test, or inside someone else's
  coroutine) it becomes a driver itself.
* **The driver** (`Drive`) keeps the segments in a list -- the explicit
  stack -- and resumes the top one from its own frame: a request pushes the
  new segment, a finished segment is popped and its outcome resumes the
  segment below. The bound is 60 frames in a segment (Tcl counts a
  coroutine's frames from its own base), 200 outside a driver.
* **Variables.** A coroutine sees no frame but its own, so a segment cannot
  `upvar` into the suspended caller. It takes the caller's variables
  instead (`Take`): the caller's frame is suspended below the segment, and
  no other code can reach its locals meanwhile, so moving a local into the
  segment and back is exact -- the local is emptied meanwhile, so the
  segment's copy is not shared and `dict set` copies nothing. A link to
  another frame's variable is copied and written back. A link to a
  namespace variable, which code in the segment may reach directly, is
  linked again to the same variable (`upvar #0`): it is found by its name in
  the caller's namespace and confirmed the same variable by unsetting one
  and seeing the other go (`Aliases`, then put back). A variable the call
  creates in its caller's frame is given back too (`Give`).
* **Outcomes.** A segment ends with `{done {CODE RESULT OPTIONS STATE}}`;
  `descend` returns it with the caller's state restored and `-level`
  incremented, as `uplevel` would: results, errors with their codes and
  stack, `break`, `continue` and `return -level` cross a segment unchanged.
  A command's words are expanded (`{*}`), never evaluated as a script: a
  HIR among them is never given a string.
* **Entry points.** `core::deep::run SCRIPT` is SCRIPT in the caller's
  frame under a driver; `hir::Deep` (the HIR build, the checks, the warning
  passes, native lowering, the Tcl compiler, core IR lowering) and
  `surface::parse` use it. A run inside a running segment is the script
  itself.

The guard's contract (AGENTS.md, "Depth-safe recursion"): a guarded
procedure reaches its caller only through `upvar 1`/`uplevel 1`, never
yields, and passes no namespace variable under another name. Every guarded
procedure was checked for `upvar`/`uplevel` past level 1, `info level` and
`info frame`: one (`core::compiler::ReleasingOnError`) uses `uplevel 1`,
which a segment's frame, holding the caller's variables in its caller's
namespace, serves the same way.

Why not the alternatives:

* **Raising the limit** (the old floor): moves the failure, keeps a
  C-recursive command on the path a crash, and the prompt rules it out.
* **An explicit stack per walk**: section 5's first paragraph.
* **Linearizing the program** (temporaries before the parser or in the
  lowering): changes the HIR, its text and its diagnostics, and depends on
  a threshold.
* **A child interpreter or `after`**: C-recursive, or no shared state.

## 6. Parser architecture

The parser is recursive descent with one procedure per precedence level
(Expression, Conjunction, Logical for `or`/`and`, Inversion for `not`,
Comparison, Additive, Multiplicative, Unary, Postfix, Primary) and a loop
in each binary level (left-associative: `a - b - c` builds `(a - b) - c`
without recursing) and in Postfix (calls, projections, method calls,
static indices). What recurses with the program's nesting:

| production | recursive shape | classification |
|---|---|---|
| Primary `(` -> Expression | parentheses | host depth proportional to nesting |
| Primary `[` -> Arguments -> Expression | List elements | host depth proportional to nesting |
| Primary `{`, NAME `{` -> FieldInits -> Expression | construction fields | host depth proportional to nesting |
| Postfix `(` -> CallArguments -> Expression | call and method arguments | host depth proportional to nesting |
| Unary -> Unary, Inversion -> Inversion | `-`, `not` | tail-like, proportional to nesting |
| Expression `yield` -> Expression | `yield` | proportional to nesting |
| Logical, Additive, Multiplicative, Postfix | operator and postfix chains | loops: bounded |
| Statement -> If/Loop/Function/HandledCall -> Suite -> Statements | blocks | proportional to block nesting |

Every procedure on those cycles is guarded (all of them, not one per cycle:
a segment's frames stay bounded by the bound plus one cycle). The grammar,
the AST, the spans and the recovery are the parser's own, unchanged:
nothing was rewritten.

## 7. Parentheses, unary and binary nesting, flat chains

* `((((1))))` 1000 and 5000 deep is the value 1 (grouping is erased, as
  before: no wrapper node).
* `----1` (N minuses) and `not not ... true` 1000 deep.
* `1 + (1 + (... 1))` (`rbin`) and `((2N+1) - 1) - 1 ...` (`lbin`) 1000
  deep: N + 1, which only left-to-right subtraction gives -- the specimen
  pins associativity.
* `2N+1 - 1 - 1 - ... - 1` with 1000 operators on one line (`flat`): one
  loop in the parser, but a left-deep tree 1000 deep for everything after
  it (it failed at 497 before, in core IR lowering, past the floor's
  reach). N + 1.

## 8. Lists, struct constructions, calls and postfix chains

* `[[[[...1...]]]]` 1000 and 5000 deep.
* The motivating workload: 1001 struct declarations S0 ... S1000 and one
  construction `S0 {next: S1 {next: ... S1000 {value: 42}}}`, read back
  through a field path 1000 long: 42 on every backend.
* `project`: a chain built one statement per level and read through
  `x0.next.next....value` (a left-deep projection tree).
* `f(f(f(...1...)))` 1000 deep through an identity function; `x.inc()`
  1000 times (a left-deep method-call tree); `std::list::length` and
  `Box {value: ...}.value` in the mixed and fuzzed programs.

## 9. Statement nesting: blocks, functions, handlers, elif chains

* `ifnest`: 1000 nested `if c:` blocks each with an `else`.
* `fnnest`: 1000 nested function declarations, each calling the next.
* `handler`: `g(N)` failing, its handler calling `g(N-1)`, ..., 1000 deep.
* `elif`: 1000 `elif` clauses (ELIF.md had measured 400 failing): an
  `elif` is an `else` holding an `if`, so the HIR nests 1000 deep.
* `or` and `and` chains of 1000 terms (HASH-TABLE-COMPILER-PRESSURE.md's
  CO-8: 1024 terms failed): each lowers to nested `if`s.

## 10. Mixed nesting

`mixed` cycles a List literal, a call of an untyped identity, a
construction projected again and parentheses, 1000 deep: guards on one
production's cycle do not cover another's, and the census found the
cross-production cycles (Primary -> Arguments -> Expression ->
... -> Primary -> FieldInits -> ...). The fuzzer (section 18) draws a new
mix per program.

## 11. HIR build, resolution, typing, the analyses

All recursive, all guarded (the census's phases): surface lowering
(`surface::lower::Node`, `Sequence`, `FieldInits`, `Handlers`), static
sites, resolution (`hir::resolve::Expr`, `Sequence`, `ResolveStruct`),
inference (`hir::types::Expr`, `Call`, `Struct`, `Project`, `If`,
`Handle`, `Sequence`, `Bind`, `Block`, `inferRegion`), contracts
(`hir::signatures::Value`, `Call`, `Seq`), the range analysis (`Expr`,
`Call`, `If`, `Sequence`, `VerifyCallArguments`, `PathsWithin`),
refinement implication, the callable audit, the completion analysis
(`Eval`, `EvalCall`, `EvalIf`, `EvalHandle`, `Seq`, `StaticWalk`,
`ExactCopy`, `WalkBlock`, `analyzeBlock`, `EffectiveFacts`),
specialization, the affine flow, repeatability, and the warning passes'
completion walks. Expected-type propagation through 1000 nested
constructions (`hir::types::Struct` passing a field's declared type down)
needed nothing of its own.

The completion analysis also nests one analysis per static call
(COMPILER-BOTTLENECKS.md, 4.4): the 250- and 1030-function chains of
`tests/range-fixpoint-scaling.test` (3.1, 3.3) compile at the default limit
without the floor, through the same guards.

## 12. Lowering and code generation

Guarded: core IR lowering (`hir::lower::expr`, `Exprs`, `Seq`, `body`) and
its check (`core::ir::check`, `CollectBindNames`), the Tcl compiler
(`CompileExpr`, `CompileForm`, `CompileCall`, `CompileStruct`,
`CompileProject`, `CompileIf`, `CompileCondition`, `ConditionIf`,
`CompileHandle`, `CompileSequence`, `CompileBind`, `CompileBlock`,
`CompileBlockBody`, `ReleasingOnError`, `hir::WalkInto`,
`hir::aot::TailInto`), native lowering (`native::lower::Expr`, `Call`,
`CallInner`, `CallArgs`, `If`, `Handle`, `Sequence`, `SequenceTo`,
`StructFields`, `StaticOutcome`, `StaticOutcomeOf`, `MandatoryWriteBack`,
`ConstantIntValue`; the short-string and raw-ABI walks; escape and
construction planning).

Generated code does not mirror the source's nesting where it need not: NIR
is a linear instruction list (1000 nested identity calls are 1000 `call`
instructions in one function), and the native backends run 1000-deep
expressions with no native recursion. The Tcl compiler's code is nested Tcl
command substitutions, which Tcl's bytecode compiler handles 5000 deep.

## 13. Diagnostics and recovery

Malformed programs 1000 deep -- a parenthesis, a List's bracket or a
construction's brace missing, the innermost argument an operator with no
operand -- are the parser's syntax diagnostics, at the place and in the
words the same program 5 deep gets (`dsn-malformed`; the fuzzer removes a
closing bracket of the spine, or puts an operator before one, in every
program). A TYPE error in the innermost construction of a 1000-deep chain
is the compilation's one diagnostic, at that field
(`dsn-type-error-deep`). Recovery is unchanged: the parser's own, its
state carried through segments by `Take`/`Give` -- also when a syntax
error unwinds through them.

## 14. Evaluation and error order

`dsn-evaluation-order`: 1000 nested calls `g(i, ...)`, each failing with its
index when the index is in a set and adding 1 otherwise, the innermost a
`pair` of two calls. On all four backends the error handled is the
innermost failing index's (arguments run before their call: 998 of
{3, 500, 998}), the left sibling's of two failing leaves (-1 of -1 and -2),
and without failures the value is 1002. The segment mechanism cannot
reorder anything: it runs the same code; the test pins that the lowerings
it runs did not either.

## 15. Affine values

`dsn-affine-chain`: `S0 {next: S1 {next: ... S1000 {c: make(1)}}}` in one
expression, its innermost field a coroutine handle -- the deep finite
affine value the ownership milestone had to build one statement per level --
is made twice, passed, returned and dropped: on interp and compile two
coroutines, two releases; natively (unfused) two released, none swept, and
the same under GC stress.

## 16. Quadratic costs found on the way

Making the walks depth-safe exposed what deep nesting costs once nothing
stops it:

* **Stringified syntax.** Tcl 9.0.1's `concat` gives a string to every
  element of a list after the first; `regexp`, `string first`, `in`/`ni`,
  `lsort` and `switch` give one to their operand. A syntax or AST node's
  string holds its whole subtree, and Tcl keeps it with every node of the
  subtree: for a program nested N deep that is O(N^2) characters, kept.
  The node-children helpers (`surface::ast::Children`,
  `hir::static::Children`, surface lowering's destructuring and coroutine
  bindings) now join lists with `list {*}...`; `hir::traits::IntrinsicDecls`
  and `UsesCoroutines` searched the whole syntax as text for an intrinsic
  trait's name and for `coroutine#create`, and now read it node by node
  (`hir::syntax::words`, an explicit work list, matching each node's own
  fields). Peak memory for a List literal: 590 MB at 400 deep before,
  FIXME after; at 800 deep FIXME.
* **A repeated constant fold.** Native lowering asked, at every call of an
  integer constant expression, whether its whole subtree was constant
  (`native::lower::ConstantIntValue`): 41,090 calls for 200 levels. It is
  remembered per expression for the program being lowered now (a view
  changes no answer: the fold reads only literals and root-native
  callees). Native lowering of `1 + (1 + ...)` 800 deep: 3.5 s before, 0.4
  s after.

What stays superlinear is measured in section 20 and named in section 25.

## 17. hir::semantic's host-depth decision

hir::semantic declined a semantic instance where `[info level] > 700` --
how deep Tcl's frames were when the request came, which depends on how
deep the program's expressions nest around it -- and recorded a request as
`deep` (for the static decisions' C:budget) at half that. With segments,
`info level` measures a segment, and the rule would have silently stopped
applying; under the design law it should never have applied. The nesting
budget is the instance stack's now (`maxDepth` nested analyses), only.
Over the 118 golden suites and the benchmarks, the old tree's deepest
`info level` at that check was FIXME (far below 350), so no corpus
decision changes (`levelprobe.tcl`).

## 18. Oracle, fuzzer, probe

* **The specimens' model.** `specimens.tcl` works out each specimen's value
  from its own structure (N + 1 for the sums, the parity of N for `-` and
  `not`, a List N deep, the struct chain's 42, the mixed program's List
  depth) -- never the compiler's answer.
* **The fuzzer** (`fuzz.tcl`): one expression whose spine nests up to 1500
  levels through every production in turn (parentheses, unary minus,
  `not`, `+`/`-` either way round, `and`/`or`, `==`, calls, method calls,
  List literals, constructions projected again, a List's length) with
  small random siblings; the generator computes the value as it builds the
  text. Each program must compile at the default limit and show the
  model's value on every backend asked, build the same HIR with segments of
  a random size (2 to 60 frames), and its one-token-malformed copy must be
  the parser's syntax diagnostic. FIXME seeds.
* **The probe** (`probe.tcl`): section 1's paths for every specimen 1000
  deep at the default limit. FIXME result; on the old tree every path
  fails.

## 19. Mutation testing

FIXME mutants table

## 20. Performance

FIXME bench table

## 21. HIR, cache, isolation, the service

* No HIR format, text, interchange or cache-key change: segments change
  where frames live. `dsn-cache` reads a 1000-deep program through the
  front-end cache twice and gets the HIR its build makes.
* `dsn-isolation`: deep valid, deep malformed, ordinary and deep programs
  compiled in turn (and back) each build exactly the HIR they build alone;
  no driver, segment or changed bound outlives a compilation (the driver
  restores its state in a `finally`, and deletes any segment an error left).
  The explicit stack is the driver's local variable: no global stack, so a
  nested compilation (a static block's builds, the service, a test calling
  the compiler inside its own coroutine) gets its own driver.
* `dsn-service`: the compiler service analyzes an unsaved 1000-deep
  document and a malformed one at the default limit; the probe's `service`
  scenario also runs position queries over the deep text. The language
  server is the service's client (LSP-MILESTONE-1.md): it adds no walk.
* `dsn-static-compile`: a `static compile:` block decided by whole-program
  builds with a 1000-deep List in its body (accepted), and one whose
  1000-deep construction has a TYPE error innermost (rejected, its
  CompilerError handled).
* `dsn-segment-invariance`: every specimen 40 deep, a malformed one and the
  2048 engine compile to the same HIR text, core IR, Tcl code and NIR with
  a segment every 3 frames as with the default 60.

## 22. The run (the reference interpreter)

The reference interpreter evaluates a program's nesting as nested Tcl
evaluations when it *runs* it (`core::interp::evalIn`, `core::forms::op-*`,
a Botlish call's `core::block::invoke`): that is the program's own
recursion, like its calls, and runs under the program recursion limit
(`core::useProgramRecursionLimit`, main.tcl's and the golden runner's,
100000: about 14,000 nested expressions on the interpreter). It is not
guarded on purpose: a Botlish coroutine on the Tcl backends is a Tcl
coroutine whose `yield` must reach its own resumer, never a driver's. The
Tcl compiler's code runs a 1000-deep expression as one command with nested
substitutions; native code has no recursion for it at all.

## 23. Regression and CI

FIXME

## 24. Remaining recursion: the final census

FIXME

## 25. Explicit limitations

* **The applied-type bound** (`hir::types::MakeApplied`): `Box {value: Box
  {value: ...}}` is a TYPE error from 7 levels on, the inner argument cut
  to `any` while the value is still precise. Unchanged: 1000 deep it is the
  same diagnostic at the same place as 7 deep (`dsn-box-bound`), where the
  front end used to fail with TCL LIMIT STACK at 100. That precision limit
  is the next milestone's candidate, not this one's.
* **Superlinear phases left**: FIXME
* **The guard's contract** is a convention the census test checks for the
  guard's presence, not for every caller's variables: a guarded procedure
  passed a namespace variable under another name (`upvar #0 ::x y`) would
  get a copy. None is, today.
* **Uninhabited declarations** and **function-type polarity** are
  untouched.

## 26. Next milestone

FIXME

## 27. What to run when changing this

If you change core/deep.tcl, a guarded procedure's use of its caller's
frame, the census, or a walk over nesting: `tests/depth-safe-nesting.test`
(at Tcl's default limit), `audit/depth-safe-nesting/tools/probe.tcl` (no
path 1000 deep hits Tcl's limit), `audit/depth-safe-nesting/tools/census.tcl`
(no recursive procedure missing), `audit/depth-safe-nesting/tools/fuzz.tcl`
(several seeds) and `audit/depth-safe-nesting/tools/mutate.tcl` (every
mutant applies and is killed by a detector its `!!` line names);
`bench/nested-frontend.tcl` regenerates section 20's table.
