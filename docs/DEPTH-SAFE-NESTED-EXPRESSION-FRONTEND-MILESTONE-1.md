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
10. Mixed nesting, and nesting that is no expression's
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
declarations, nested handlers, all of them mixed, and what nests that is
no expression -- a written type, a destructuring pattern, loops and folds,
one Boolean condition, `inject` blocks, a layout's arrays of arrays, a
chain of 1001 affine struct declarations built in one expression --
compiles 1000 deep at Tcl's *default* recursion limit of 1000 nested
evaluations, through every compile-time path (the front end with every
warning pass, HIR text printed and read back, interchange text, core IR
and its check, the Tcl compiler, native lowering, a trait program, a
coroutine program, a `static compile:` block, an imported module, a module
binding, the compiler service), and runs on all four backends with the
value its structure gives it. Parentheses and List
literals compile 5000 deep; the fuzzer compiles mixed programs 1500 deep.

The walks are unchanged. Each procedure whose recursion follows the
program's nesting (192 of them, `audit/depth-safe-nesting/census.tsv`)
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
(`audit/depth-safe-nesting/tools/baseline.tcl -root`: the largest depth
that compiled and the first that did not,
with the procedure repeated most in the error's stack):

| specimen | compiles at | fails at | how it fails |
|---|---:|---:|---|
| `paren` | 81 | 82 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `rbin` | 81 | 82 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `lbin` | 81 | 82 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `flat` | 496 | 497 | TCL LIMIT STACK in the core IR lowering (`hir::lower::expr`) |
| `neg` | 496 | 497 | TCL LIMIT STACK in the core IR lowering (`hir::lower::expr`) |
| `not` | 599 | 600 | killed: more than 3 GB of memory (a ulimit; section 16) |
| `list` | 74 | 75 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `struct` | 73 | 74 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `project` | 781 | 782 | killed: more than 3 GB of memory (a ulimit; section 16) |
| `call` | 88 | 89 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `method` | 496 | 497 | TCL LIMIT STACK in the core IR lowering (`hir::lower::expr`) |
| `or` | 502 | 503 | killed: more than 3 GB of memory (a ulimit; section 16) |
| `and` | 447 | 448 | killed: more than 3 GB of memory (a ulimit; section 16) |
| `elif` | 330 | 331 | TCL LIMIT STACK in the parser (`Statements`) |
| `ifnest` | 242 | 243 | TCL LIMIT STACK in the parser (`Statement`) |
| `fnnest` | 243 | 244 | TCL LIMIT STACK in the parser (`Statement`) |
| `handler` | 160 | 161 | TCL LIMIT STACK in the parser (`ValueOrHandled`) |
| `mixed` | 62 | 63 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `typed` | 74 | 75 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `pattern` | 73 | 74 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `loops` | 180 | 181 | TCL LIMIT STACK in the parser (`Statement`) |
| `cond` | 76 | 77 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |
| `inject` | 161 | 162 | TCL LIMIT STACK in the parser (`Statement`) |
| `layout` | 493 | 494 | TCL LIMIT STACK in the parser (`TypeExpr`) |
| `affine` | 72 | 73 | TCL LIMIT STACK in the parser (`surface::parser::Logical` ...) |

No specimen compiled 1000 deep. The typed, pattern, cond and affine
specimens stop at their List literal or construction, before their own
form; the old tree's first failure is whichever walk of the program is
shallowest per level.

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
(`scenarios.tcl`: the ten paths of section 1), and counts each procedure's
simultaneous activations. One active at least 12 times at once recurses with
the nesting (the specimens that cycle through forms -- `loops`, `cond`,
`mixed` -- run 48 deep with a threshold of a quarter, `-fraction 4`, so
that a procedure of one form of the cycle shows). `probe.tcl` runs every
specimen 1000 deep through every scenario at the default limit and names
the procedures a TCL LIMIT STACK's stack repeats. The census was found in
two passes: the expression and block specimens first (132 procedures), then
the forms section 10 lists, each of which failed at the default limit
before it had a specimen -- 192 procedures in all:

| phase | procedures | recursive shape | terminates | changed | why it stays recursive |
|---|---|---|---|---|---|
| parse (26) | `surface::parser::Additive`, `surface::parser::Arguments`, `surface::parser::CallArguments`, `surface::parser::Comparison`, `surface::parser::Conjunction`, `surface::parser::Expression`, `surface::parser::FieldInits`, `surface::parser::Function`, `surface::parser::HandledCall`, `surface::parser::If`, `surface::parser::Inversion`, `surface::parser::Logical`, `surface::parser::Multiplicative`, `surface::parser::Postfix`, `surface::parser::Primary`, `surface::parser::Simple`, `surface::parser::Statement`, `surface::parser::Statements`, `surface::parser::Suite`, `surface::parser::Unary`, `surface::parser::ValueOrHandled`, `surface::parser::Pattern`, `surface::parser::TypeExpr`, `surface::parser::Loop`, `surface::parser::ArrayTypeExpr`, `surface::parser::Injection` | recursive descent: a production per precedence level and per bracketed form, re-entered for every nested operand, argument, element, field value and block; a destructuring pattern's nested field patterns; a written type's arguments (List[List[...]], Fn{...}); a loop's header and suite; a written `array N of ...` representation; an inject block's header and suite | structural: each call descends to a child of a finite tree | guard added | section 5 |
| AST (4) | `surface::ast::Ids`, `surface::ast::Statements`, `surface::ast::Suite`, `surface::ast::PatternIds` | structural ids assigned by a walk of the nested AST (a left-deep chain is as deep as it is long); structural ids of a nested destructuring pattern | structural: each call descends to a child of a finite tree | guard added | section 5 |
| AST text (3) | `surface::ast::Expr`, `surface::ast::PatternText`, `surface::ast::showType` | the AST printer (surface::formatAst), one call per nested node; the AST printer's nested patterns; the AST printer's written types | structural: each call descends to a child of a finite tree | guard added | section 5 |
| load (4) | `surface::modules::StaticSitesWalk`, `surface::modules::Walk`, `surface::modules::RemapFile`, `surface::modules::TypeRefs` | the loader's walks of a file's AST: qualified references, static sites; an imported module's nodes given their file's id; qualified names in a written type's arguments | structural: each call descends to a child of a finite tree | guard added | section 5 |
| surface lowering (6) | `surface::lower::FieldInits`, `surface::lower::Handlers`, `surface::lower::Node`, `surface::lower::Sequence`, `surface::lower::Projections`, `surface::lower::LoopSyntax` | AST to HIR syntax, one call per nested node; a nested pattern's projections, one level per nested field pattern; AST to HIR syntax, one call per nested loop | structural: each call descends to a child of a finite tree | guard added | section 5 |
| static sites (6) | `hir::static::HasStatic`, `hir::static::CollectSites`, `hir::static::Node`, `hir::static::Value`, `hir::syntax::CollectBindNames`, `hir::static::Sequence` | search of the nested syntax for a static block; the static blocks of nested syntax collected; decided static blocks replaced in nested syntax; decided static blocks replaced in nested syntax (a value position); the names a nested syntax node binds; decided static blocks replaced in nested syntax (a sequence) | structural: each call descends to a child of a finite tree | guard added | section 5 |
| resolution (5) | `hir::resolve::Expr`, `hir::resolve::ResolveStruct`, `hir::resolve::Sequence`, `hir::resolve::ResolveTypeExpr`, `hir::resolve::ShowTypeExpr` | scopes and names over nested syntax; a written type's arguments resolved; a written type shown in a diagnostic | structural: each call descends to a child of a finite tree | guard added | section 5 |
| inference (10) | `hir::types::Bind`, `hir::types::Block`, `hir::types::Call`, `hir::types::Expr`, `hir::types::Handle`, `hir::types::If`, `hir::types::Project`, `hir::types::Sequence`, `hir::types::Struct`, `hir::types::inferRegion` | type inference: Expr dispatches on a node and re-enters for its children | structural: each call descends to a child of a finite tree | guard added | section 5 |
| contracts (3) | `hir::signatures::Call`, `hir::signatures::Seq`, `hir::signatures::Value` | inferred parameter contracts and results | structural: each call descends to a child of a finite tree | guard added | section 5 |
| range (6) | `hir::range::Call`, `hir::range::Expr`, `hir::range::If`, `hir::range::PathsWithin`, `hir::range::Sequence`, `hir::range::VerifyCallArguments` | range analysis, admission and verification of calls | structural: each call descends to a child of a finite tree | guard added | section 5 |
| refinement (2) | `hir::refine::IfImplication`, `hir::refine::Implication` | implication through nested conditions | structural: each call descends to a child of a finite tree | guard added | section 5 |
| callables (1) | `hir::callables::WalkExpr` | callable-bearing audit | structural: each call descends to a child of a finite tree | guard added | section 5 |
| completions (12) | `hir::completions::EffectiveFacts`, `hir::completions::Eval`, `hir::completions::EvalCall`, `hir::completions::EvalHandle`, `hir::completions::EvalIf`, `hir::completions::ExactCopy`, `hir::completions::Seq`, `hir::completions::StaticWalk`, `hir::completions::WalkBlock`, `hir::completions::analyzeBlock`, `hir::completions::EvalListloop`, `hir::completions::ExitsLoop` | completion analysis (also nests per static call: the call chain); whether a nested loop body exits its loop | structural; the static-call nesting by `maxDepth` analyses and the cycle guard | guard added | section 5 |
| specialization (2) | `hir::specialize::Analyze`, `hir::specialize::Handle` | call-site specialization analysis of nested functions | structural: each call descends to a child of a finite tree | guard added | section 5 |
| warnings (3) | `hir::warnings::BodyInto`, `hir::warnings::FallThroughs`, `hir::warnings::Leaves` | the warning passes' completion walks | structural: each call descends to a child of a finite tree | guard added | section 5 |
| ownership (4) | `hir::affine::Flow`, `hir::affine::Descriptor`, `hir::affine::DescriptorOf`, `hir::affine::Seq` | the affine flow analysis, one call per nested expression; an affine type's drop descriptor, one level per owned component (a chain of declarations is as deep as it is long); the affine flow, one call per nested sequence (a loop's body) | structural (a drop descriptor: the declarations a type owns, a finite graph cut where a field cycle returns) | guard added | section 5 |
| traits (1) | `hir::traits::StampNode` | a trait or coroutine program's syntax stamped node by node | structural: each call descends to a child of a finite tree | guard added | section 5 |
| repeatability (1) | `hir::repeatable::Expr` | whether a nested expression repeats its value | structural: each call descends to a child of a finite tree | guard added | section 5 |
| injection (2) | `hir::injection::Seq`, `hir::injection::Tau` | the injection proof's provenance walk over nested blocks | structural: each call descends to a child of a finite tree | guard added | section 5 |
| module bindings (2) | `hir::modulebinding::ContextExpr`, `hir::modulebinding::ImmutableExpr` | a module binding's value, one call per nested expression | structural: each call descends to a child of a finite tree | guard added | section 5 |
| layouts (16) | `hir::layouts::CopyType`, `hir::layouts::ReprDescriptor`, `hir::layouts::ReprOfTerm`, `hir::layouts::ReprPointerPath`, `hir::layouts::ReprTerm`, `hir::layouts::ReprText`, `hir::layouts::ReprUnionAt`, `hir::layouts::ReprUnionPath`, `hir::layouts::ResolveArrayTerm`, `hir::layouts::ResolveRepr`, `hir::layouts::ShowTerm`, `hir::layouts::ShowTypeExpr`, `hir::layouts::WithLeafType`, `hir::layouts::WordsFormats`, `hir::layouts::align`, `hir::layouts::size` | a layout representation, one level per nested array, union or record | structural: each call descends to a child of a finite tree | guard added | section 5 |
| core IR lowering (4) | `hir::lower::Exprs`, `hir::lower::Seq`, `hir::lower::body`, `hir::lower::expr` | HIR to core IR (the interpreter's program) | structural: each call descends to a child of a finite tree | guard added | section 5 |
| core IR check (2) | `core::ir::CollectBindNames`, `core::ir::check` | core IR validation and binding collection | structural: each call descends to a child of a finite tree | guard added | section 5 |
| Tcl compiler (20) | `core::compiler::CompileBind`, `core::compiler::CompileBlock`, `core::compiler::CompileBlockBody`, `core::compiler::CompileCall`, `core::compiler::CompileCondition`, `core::compiler::CompileExpr`, `core::compiler::CompileForm`, `core::compiler::CompileHandle`, `core::compiler::CompileIf`, `core::compiler::CompileProject`, `core::compiler::CompileSequence`, `core::compiler::CompileStruct`, `core::compiler::ConditionIf`, `core::compiler::ReleasingOnError`, `hir::WalkInto`, `hir::aot::TailInto`, `core::compiler::CompileListLoop`, `core::compiler::ArrayOfRecords`, `core::compiler::LayoutLeaves`, `core::compiler::LayoutValueText` | code generation, one call per nested expression; the compiler's walk of nested expressions; tail positions; a layout representation's leaves and values | structural: each call descends to a child of a finite tree | guard added | section 5 |
| native lowering (44) | `hir::construction::SeqUses`, `hir::construction::Uses`, `hir::escape::ChooseLevel`, `hir::escape::Classify`, `hir::escape::ClassifyIf`, `hir::escape::CutFields`, `hir::escape::LiteralTree`, `hir::escape::WriteBackPaths`, `native::lower::Call`, `native::lower::CallArgs`, `native::lower::CallInner`, `native::lower::ConstantIntValue`, `native::lower::Expr`, `native::lower::Handle`, `native::lower::If`, `native::lower::MandatoryWriteBack`, `native::lower::Sequence`, `native::lower::SequenceTo`, `native::lower::StaticOutcome`, `native::lower::StaticOutcomeOf`, `native::lower::StructFields`, `native::shortstr::DemandBody`, `native::shortstr::DemandWalk`, `native::shortstr::LiveWalk`, `native::rawabi::If`, `native::rawabi::Seq`, `native::rawabi::Walk`, `native::lower::Struct`, `native::rawabi::Call`, `native::lower::ListLoop`, `native::lower::IterationBody`, `native::lower::DeferredNeeds`, `native::lower::Condition`, `native::lower::ConditionIf`, `native::lower::ConditionBody`, `native::lower::EmitRegionConsumerCondition`, `native::lower::EmitRegionConsumerBody`, `native::lower::ArrayCheck`, `native::lower::ArrayRead`, `native::lower::LayoutLeaves`, `native::lower::ReprHasArrays`, `native::lower::ReprRead`, `native::lower::ReprWrite`, `native::lower::ViewBase` | construction uses (escape of nested values); escape and scalar-replacement plans of nested constructions; HIR to NIR, one call per nested expression; short-string demand and liveness walks; raw ABI walk; a branch-form condition's Boolean structure (BRANCH-FORM-BOOLEAN-LOWERING.md); an inlined region consumer's condition and body; a layout representation's reads, writes and checks | structural: each call descends to a child of a finite tree | guard added | section 5 |
| HIR text (2) | `hir::format::Expr`, `hir::read::Expr` | the HIR text printer, one call per nested expression; the HIR text reader, one call per nested expression | structural: each call descends to a child of a finite tree | guard added | section 5 |
| service (1) | `service::SyntaxWalk` | the service's index of a file's nested AST | structural: each call descends to a child of a finite tree | guard added | section 5 |

"Terminates" is why the walk ends whatever the guard does; "changed" is
the whole change to each (its first line); why each stays a recursive
procedure rather than an explicit loop of its own is section 5. One row per
procedure, with its shape, is `audit/depth-safe-nesting/census.tsv`.

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

The prompt preferred explicit work stacks. Rewriting 192 procedures --
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

## 10. Mixed nesting, and nesting that is no expression's

`mixed` cycles a List literal, a call of an untyped identity, a
construction projected again and parentheses, 1000 deep: guards on one
production's cycle do not cover another's, and the census found the
cross-production cycles (Primary -> Arguments -> Expression ->
... -> Primary -> FieldInits -> ...). The fuzzer (section 18) draws a new
mix per program.

A program nests in more than its expressions, and each form below failed
at the default limit before it had a specimen of its own (found while
writing them, after the expression census was complete):

| specimen | what nests 1000 deep | walks it reached that recursed unguarded |
|---|---|---|
| `typed` | a written parameter type `List[List[...int...]]`, given a List as deep | `surface::parser::TypeExpr`, `surface::modules::TypeRefs`, `hir::resolve::ResolveTypeExpr` (and the printers `surface::ast::showType`, `hir::resolve::ShowTypeExpr`) |
| `pattern` | a destructuring pattern `{next: {next: ... {value: y}}}` of the struct chain | `surface::parser::Pattern`, `surface::ast::PatternIds`, `surface::lower::Projections` (and `surface::ast::PatternText`) |
| `loops` | collecting, counted and fold loops in turn | `surface::parser::Loop`, `surface::lower::LoopSyntax`, `hir::static::Sequence`, `hir::affine::Seq`, `hir::completions::EvalListloop`, `ExitsLoop`, `core::compiler::CompileListLoop`, `native::lower::ListLoop`, `IterationBody`, `DeferredNeeds` |
| `cond` | one `if` condition of `and`, `or` and `not not` in turn, at the top level and in a collecting loop's body (an inlined region consumer) | native lowering's branch form: `native::lower::Condition`, `ConditionIf`, `ConditionBody`, `EmitRegionConsumerCondition`, `EmitRegionConsumerBody` |
| `inject` | `inject no context:` blocks | the parser's `Injection`; the injection proof's provenance walk, `hir::injection::Seq`, `Tau` |
| `layout` | a layout field `array 1 of array 1 of ... U8`, parsed from one byte | the parser's `ArrayTypeExpr`; `hir::layouts`' representation walks (`ResolveRepr`, `ResolveArrayTerm`, `ReprDescriptor`, `ReprText`, `CopyType`, `WordsFormats`, ...); native lowering's `ReprRead`, `ArrayRead` -- and, guarded with them, every other walk of a representation (writes, views, checks, the Tcl compiler's layout leaves), which parsing does not reach |
| `affine` | the struct chain built in one expression with a coroutine handle innermost: 1001 affine declarations | the drop descriptor, `hir::affine::Descriptor`, `DescriptorOf` |
| (scenario `modbinding`) | a module binding's value | `hir::modulebinding::ContextExpr`, `ImmutableExpr` |

A written type deeper than the type lattice's bounds is cut the way it
always was (`hir::types`' aggregate and applied depths): the walks over
*types* -- subtyping, joins, printing -- never see more than those bounds
of a written type, and the declaration-graph walks (summaries, ownership)
are fixpoints, not recursion; the one type walk that followed a chain of
declarations, the drop descriptor, is guarded.

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
* **The loader's sections.** The loader collected each module's lowered
  syntax with `dict set state sections [concat ... [list $section]]`: every
  module loaded after the first had its whole syntax stringified, a string
  at each level. The `loops` specimen in an imported module (it imports
  std::list, so its section comes second) took more than 12 GB 1000 deep
  and 159 MB 120 deep; appended with `dict lappend`, 41 MB 120 deep and 65
  MB 240 deep. The declaration lists beside it (whose layouts and types
  nest as written) are joined with `list {*}...` too.
  `dsn-module-not-stringified` pins it (`concat` returns its only
  non-empty list untouched, so the test's module imports another).
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
Over the 118 golden suites, the 2048 engine and eight benchmark programs,
compiled by the old tree with a probe on that check
(`audit/depth-safe-nesting/tools/levelprobe.tcl -root`), the deepest `info level`
there was 120 (branch-form-boolean.bot; 79 the next): far below both 350
and 700, so no decision of the corpus changes.

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
  a segment every 3 frames as with the default 60 (the Tcl compiler's
  temporaries counted from the same place: their counter is process-wide).
* `dsn-module-binding`: a List literal, a sum and a call chain 1000 deep as
  a module binding of an imported module, read by the program, on every
  backend (`hir::modulebinding`'s walks); `dsn-module-not-stringified`: a
  module loaded after another keeps its syntax free of strings (section
  16).

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

The census (`audit/depth-safe-nesting/census.tsv`) lists 192
procedures, every one guarded (`dsn-census-guarded`). `census.tcl` over
every specimen kind through every scenario (24 deep; `loops`, `cond` and
`mixed`, which cycle through forms, 48 deep at `-fraction 4`) finds no
procedure active half as many times as the program nests that the census
does not list, and `probe.tcl` runs every kind 1000 deep through every
scenario at the default limit without one TCL LIMIT STACK.

What still recurses, and why it may (`static-census.tcl` lists the
262 procedures that call themselves without the guard, by
namespace):

* **Types.** `hir::types` (subtyping, joins, meets, printing, totality),
  `hir::decimal`, `hir::structs`, `hir::imprint`, `hir::callables`'
  bearing, `hir::semantic`'s erasures: walks of a type term. Every type the
  analyses hold is cut to the lattice's bounds -- an aggregate 3 deep, an
  application 6 deep (`hir::types` `aggregateDepth`, `appliedDepth`) --
  written types included: a parameter declared `List[List[...int...]]`
  1000 deep is `List[List[List[list]]]` in its diagnostics, and a
  function type 1000 deep is cut the same way. The syntax of a written type
  (`TypeExpr`, `ResolveTypeExpr`, `TypeRefs`) is as deep as it is written,
  and guarded.
* **Declarations.** Summaries (`hir::summaries`) and recursive ownership
  (`hir::ownership`) are least fixpoints over declaration states, not
  recursion over a chain; the one walk that followed a chain of
  declarations, an affine type's drop descriptor (`hir::affine::Descriptor`),
  is guarded (`affine`: 1001 declarations).
* **The call graph and instances.** Contracts, specialization and semantic
  instances nest one analysis per call, bounded by their budgets
  (`hir::semantic`'s `maxDepth`, the completion analysis' `maxDepth`),
  whose analyses run in the guarded walks' segments.
* **Values of other protocols.** The language server's JSON
  (`lsp::json`), the native driver's records and the service's protocol
  values are the tools' data, not the program's nesting.
* **Self-calls that are no recursion** -- a procedure that normalizes its
  arguments and calls itself once, or whose name appears as another
  command's word or in a string -- are in the static list too; it is an
  over-approximation for a reader adding a walk, not a census.
* **The run** (section 22): the reference interpreter evaluates the
  program's nesting as the program's own recursion, under the program
  recursion limit.

## 25. Explicit limitations

* **The applied-type bound** (`hir::types::MakeApplied`): `Box {value: Box
  {value: ...}}` is a TYPE error from 7 levels on, the inner argument cut
  to `any` while the value is still precise. Unchanged: 1000 deep it is the
  same diagnostic at the same place as 7 deep (`dsn-box-bound`), where the
  front end used to fail with TCL LIMIT STACK at 100. That precision limit
  is the next milestone's candidate, not this one's.
* **Superlinear phases left** (section 20 has the numbers). None is a
  depth limit -- each compiles 1000 deep -- and each is an algorithm's
  cost, not the segments':
  - **Nested folds whose intermediate widens: exponential.** A fold's
    intermediate type is a bounded fixpoint (`hir::types::FoldBody`): when
    the body's type widens the intermediate's, the body is walked again,
    nested folds inside it included -- 6, 9 and 12 nested folds over `[]`
    compile in 58, 134 and 712 ms. A fold whose intermediate keeps its type
    is walked once, and nests linearly (the `loops` specimen's). Found while
    writing that specimen; changing fold typing is FOLD-LOOPS-MILESTONE-1's
    territory, with its own audit, and is not done here.
  - **Nested handlers: quadratic.** The completion analysis range-analyzes
    each live handler body standalone (`hir::range::analyzeSequence`, from
    `hir::completions::EvalHandle`) to admit its completion type, and that
    body holds every handler nested in it: N handlers analyze N(N+1)/2
    levels. Reusing the enclosing analysis would change what is proven
    (it knows the outer bindings' facts), so it is left.
  - **Nested functions in the Tcl compiler: quadratic code.** Each function
    value carries its body's core IR (`core::value::block {} {...}`), the
    functions nested in it included, and each function's prologue walks
    one environment parent per enclosing scope: 420 KB of Tcl for 100
    nested functions, 1.66 MB for 200, and `hir::lower::ReleasingOnError`
    asked N(N-1)/2 times.
  - **Nested blocks on the Tcl backend.** The Tcl compiler's code for a
    nested block is a nested, indented Tcl script: 1.57 MB of Tcl for 125
    nested handlers, 6.15 MB for 250. Defining the unit's procedures takes
    milliseconds, but running it makes Tcl's own parser scan each level's
    text once per enclosing braced script: 0.8 s at 125, 5.9 s at 250 and
    46 s at 500 on the `compile` backend (the other backends run 500 nested
    handlers in under half a second). `dsn-1000-handler` runs that one
    backend 250 deep; the program still compiles 1000 deep, the Tcl
    compiler's unit included.
  - **Nested loops in the native code generator.** NIR stays linear (3,507
    lines for the `loops` specimen 125 deep, 7,010 for 250) and native
    lowering nearly so (0.4 s, 1.4 s), but the driver compiling that one
    function -- 250 nested loops -- takes about 8 s, seven times the 125
    levels' (the driver's passes over one function's loop nest; which
    pass was not measured). `dsn-1000-loops`
    runs the two native backends 250 deep; NIR is lowered 1000 deep.
  - **Block nesting's text.** A block nested N deep is indented N times:
    the source of `ifnest`, `fnnest`, `handler`, `loops` and `inject` is
    O(N^2) characters (2.7 MB for `loops` 1000 deep), and the lexer and
    every span with it.
  - **`or`/`and` chains**: about x2.4 per doubling in inference, the
    completion analysis, branch facts and the range analysis; **struct
    construction and projection chains** in native lowering's escape and
    scalar-replacement planning (section 20).
* **The guard's contract** is a convention the census test checks for the
  guard's presence, not for every caller's variables: a guarded procedure
  passed a namespace variable under another name (`upvar #0 ::x y`) would
  get a copy. None is, today.
* **Uninhabited declarations** and **function-type polarity** are
  untouched.

## 26. Next milestone

Depth no longer decides whether a program compiles; two things still
decide what a deep program costs or means, and either is a milestone of
its own:

* **Precision of applied types past `appliedDepth`** (section 25): `Box
  {value: Box {value: ...}}` 7 deep is a TYPE error because the
  argument's inferred type is cut to `any` one application before the
  value's own type is. Now that nothing else stops a deep program, this is
  the first rule a deep valid program meets. The milestone would make the
  cut keep what the declared field type needs (or check the field against
  the uncut value), with the same finite-lattice argument the bound exists
  for.
* **The superlinear phases** (section 25), measured by
  `bench/nested-frontend.tcl`: a handler body range-analyzed standalone
  once per enclosing handler, and the code a nested function's Tcl
  compilation repeats. Each needs a decision about what an analysis may
  reuse, not a mechanism.

The reference interpreter's own recursion (section 22) is the program's,
not the compiler's, and stays under the program recursion limit by
design.

## 27. What to run when changing this

If you change core/deep.tcl, a guarded procedure's use of its caller's
frame, the census, or a walk over nesting: `tests/depth-safe-nesting.test`
(at Tcl's default limit), `audit/depth-safe-nesting/tools/probe.tcl` (no
path 1000 deep hits Tcl's limit), `audit/depth-safe-nesting/tools/census.tcl`
(no recursive procedure missing), `audit/depth-safe-nesting/tools/fuzz.tcl`
(several seeds) and `audit/depth-safe-nesting/tools/mutate.tcl` (every
mutant applies and is killed by a detector its `!!` line names);
`bench/nested-frontend.tcl` regenerates section 20's table.
