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
program's nesting (215 of them, `audit/depth-safe-nesting/census.tsv`)
starts with one guard:

    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}

Past a segment's 150 frames, the guarded call does not call deeper: it goes
on in a new *segment* -- a Tcl coroutine holding its caller's variables --
and the segment it leaves is suspended on a driver's explicit stack. The
driver resumes every segment from its own shallow frame, and Tcl counts a
coroutine's evaluations from where it is resumed, so the interpreter's
nesting stays at most one segment deeper than the driver whatever the
program's depth. No recursion limit is raised (`hir::Deep`'s former floor
of 100000 is gone: it starts a driver now), nothing catches TCL LIMIT
STACK, and no nesting limit or diagnostic was added.

On the way, the front end stopped giving nested syntax string
representations (Tcl 9.0.1 gives them in `concat`, `regexp` and `string
first`), which made a List literal 400 deep take 590 MB and one 1000 deep
exhaust the machine: 39 MB now. Memory is not linear in the nesting yet:
every AST node's structural id is its path from the root, O(depth)
characters, and HIR origins carry it (section 16; 96 MB for `1 + (1 +
...)` 1000 deep, 248 MB 2000 deep). And one host-depth decision went:
hir::semantic declined semantic instances where Tcl's frames were 700
deep.

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
the nesting (the specimens that cycle through forms run once more each
with a threshold of one over their number of forms -- `loops` and `cond`
`-fraction 3`, `mixed` `-fraction 4` -- so that a procedure of one form of
the cycle shows; `cond` 12 deep, as its `and`/`or` analyses under the
trace grow about 4.5 times per doubling and take over an hour 24 deep). `probe.tcl` runs every
specimen 1000 deep through every scenario at the default limit and names
the procedures a TCL LIMIT STACK's stack repeats. The census was found in
three passes: the expression and block specimens first (132 procedures);
the forms section 10 lists, each of which failed at the default limit
before it had a specimen (68 more, the Tcl backends' layout codec among
them); and the specimens that cycle through forms, traced at their own
threshold, which found 12 more that never failed -- a fold's and a counted
loop's walks, one implication walk of a condition's body, the Tcl
compiler's branch of a condition, two of native lowering's struct walks,
each recursing only through procedures already guarded, so that their own
frames never added up -- 212 procedures. Merging main at `0030f8a` added
three: consumed fold intermediates (CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md)
walk a fold body's exits (`hir::mutvec::FoldWalk`, `FoldWalkSequence`),
which failed with TCL LIMIT STACK on a 1000-deep expression in such a
body (`dsn-consumed-fold`), and native lowering's loop bodies go through
`native::lower::LoopBody`, which the `loops` census (`-fraction 3`)
reported as missing -- 215 in all:

| phase | procedures | recursive shape | terminates | changed | why it stays recursive |
|---|---|---|---|---|---|
| parse (28) | `surface::parser::Additive`, `surface::parser::Arguments`, `surface::parser::CallArguments`, `surface::parser::Comparison`, `surface::parser::Conjunction`, `surface::parser::Expression`, `surface::parser::FieldInits`, `surface::parser::Function`, `surface::parser::HandledCall`, `surface::parser::If`, `surface::parser::Inversion`, `surface::parser::Logical`, `surface::parser::Multiplicative`, `surface::parser::Postfix`, `surface::parser::Primary`, `surface::parser::Simple`, `surface::parser::Statement`, `surface::parser::Value`, `surface::parser::Statements`, `surface::parser::Suite`, `surface::parser::Unary`, `surface::parser::ValueOrHandled`, `surface::parser::Pattern`, `surface::parser::TypeExpr`, `surface::parser::Loop`, `surface::parser::Fold`, `surface::parser::ArrayTypeExpr`, `surface::parser::Injection` | recursive descent: a production per precedence level and per bracketed form, re-entered for every nested operand, argument, element, field value and block; a destructuring pattern's nested field patterns; a written type's arguments (List[List[...]], Fn{...}); a loop's header and suite; a fold's header and suite; a written `array N of ...` representation; an inject block's header and suite | structural: each call descends to a child of a finite tree | guard added | section 5 |
| AST (4) | `surface::ast::Ids`, `surface::ast::Statements`, `surface::ast::Suite`, `surface::ast::PatternIds` | structural ids assigned by a walk of the nested AST (a left-deep chain is as deep as it is long); structural ids of a nested destructuring pattern | structural: each call descends to a child of a finite tree | guard added | section 5 |
| AST text (3) | `surface::ast::Expr`, `surface::ast::PatternText`, `surface::ast::showType` | the AST printer (surface::formatAst), one call per nested node; the AST printer's nested patterns; the AST printer's written types | structural: each call descends to a child of a finite tree | guard added | section 5 |
| load (4) | `surface::modules::StaticSitesWalk`, `surface::modules::Walk`, `surface::modules::RemapFile`, `surface::modules::TypeRefs` | the loader's walks of a file's AST: qualified references, static sites; an imported module's nodes given their file's id; qualified names in a written type's arguments | structural: each call descends to a child of a finite tree | guard added | section 5 |
| surface lowering (6) | `surface::lower::FieldInits`, `surface::lower::Handlers`, `surface::lower::Node`, `surface::lower::Sequence`, `surface::lower::Projections`, `surface::lower::LoopSyntax` | AST to HIR syntax, one call per nested node; a nested pattern's projections, one level per nested field pattern; AST to HIR syntax, one call per nested loop | structural: each call descends to a child of a finite tree | guard added | section 5 |
| static sites (6) | `hir::static::HasStatic`, `hir::static::CollectSites`, `hir::static::Node`, `hir::static::Value`, `hir::syntax::CollectBindNames`, `hir::static::Sequence` | search of the nested syntax for a static block; the static blocks of nested syntax collected; decided static blocks replaced in nested syntax; decided static blocks replaced in nested syntax (a value position); the names a nested syntax node binds; decided static blocks replaced in nested syntax (a sequence) | structural: each call descends to a child of a finite tree | guard added | section 5 |
| resolution (5) | `hir::resolve::Expr`, `hir::resolve::ResolveStruct`, `hir::resolve::Sequence`, `hir::resolve::ResolveTypeExpr`, `hir::resolve::ShowTypeExpr` | scopes and names over nested syntax; a written type's arguments resolved; a written type shown in a diagnostic | structural: each call descends to a child of a finite tree | guard added | section 5 |
| inference (11) | `hir::types::Bind`, `hir::types::Block`, `hir::types::Call`, `hir::types::Expr`, `hir::types::Handle`, `hir::types::If`, `hir::types::Project`, `hir::types::FoldBody`, `hir::types::Sequence`, `hir::types::Struct`, `hir::types::inferRegion` | type inference: Expr dispatches on a node and re-enters for its children; a fold's body typed to its intermediate's fixpoint, nested folds within | structural: each call descends to a child of a finite tree | guard added | section 5 |
| contracts (3) | `hir::signatures::Call`, `hir::signatures::Seq`, `hir::signatures::Value` | inferred parameter contracts and results | structural: each call descends to a child of a finite tree | guard added | section 5 |
| range (6) | `hir::range::Call`, `hir::range::Expr`, `hir::range::If`, `hir::range::PathsWithin`, `hir::range::Sequence`, `hir::range::VerifyCallArguments` | range analysis, admission and verification of calls | structural: each call descends to a child of a finite tree | guard added | section 5 |
| refinement (3) | `hir::refine::IfImplication`, `hir::refine::Implication`, `hir::refine::BodyImplication` | implication through nested conditions | structural: each call descends to a child of a finite tree | guard added | section 5 |
| callables (2) | `hir::callables::WalkExpr`, `hir::callables::WalkFold` | callable-bearing audit | structural: each call descends to a child of a finite tree | guard added | section 5 |
| completions (13) | `hir::completions::EffectiveFacts`, `hir::completions::Eval`, `hir::completions::EvalCall`, `hir::completions::EvalHandle`, `hir::completions::EvalIf`, `hir::completions::ExactCopy`, `hir::completions::Seq`, `hir::completions::StaticWalk`, `hir::completions::WalkBlock`, `hir::completions::analyzeBlock`, `hir::completions::EvalListloop`, `hir::completions::EvalCountloop`, `hir::completions::ExitsLoop` | completion analysis (also nests per static call: the call chain); whether a nested loop body exits its loop | structural; the static-call nesting by `maxDepth` analyses and the cycle guard | guard added | section 5 |
| specialization (2) | `hir::specialize::Analyze`, `hir::specialize::Handle` | call-site specialization analysis of nested functions | structural: each call descends to a child of a finite tree | guard added | section 5 |
| warnings (3) | `hir::warnings::BodyInto`, `hir::warnings::FallThroughs`, `hir::warnings::Leaves` | the warning passes' completion walks | structural: each call descends to a child of a finite tree | guard added | section 5 |
| logical copies (2) | `hir::mutvec::FoldWalk`, `hir::mutvec::FoldWalkSequence` | a consumed fold intermediate's exits: the fold body's nested expressions | structural: each call descends to a child of a finite tree | guard added | section 5 |
| ownership (4) | `hir::affine::Flow`, `hir::affine::Descriptor`, `hir::affine::DescriptorOf`, `hir::affine::Seq` | the affine flow analysis, one call per nested expression; an affine type's drop descriptor, one level per owned component (a chain of declarations is as deep as it is long); the affine flow, one call per nested sequence (a loop's body) | structural (a drop descriptor: the declarations a type owns, a finite graph cut where a field cycle returns) | guard added | section 5 |
| traits (1) | `hir::traits::StampNode` | a trait or coroutine program's syntax stamped node by node | structural: each call descends to a child of a finite tree | guard added | section 5 |
| repeatability (1) | `hir::repeatable::Expr` | whether a nested expression repeats its value | structural: each call descends to a child of a finite tree | guard added | section 5 |
| injection (2) | `hir::injection::Seq`, `hir::injection::Tau` | the injection proof's provenance walk over nested blocks | structural: each call descends to a child of a finite tree | guard added | section 5 |
| module bindings (2) | `hir::modulebinding::ContextExpr`, `hir::modulebinding::ImmutableExpr` | a module binding's value, one call per nested expression | structural: each call descends to a child of a finite tree | guard added | section 5 |
| layouts (24) | `hir::layouts::CopyType`, `hir::layouts::ReprDescriptor`, `hir::layouts::ReprOfTerm`, `hir::layouts::ReprPointerPath`, `hir::layouts::ReprTerm`, `hir::layouts::ReprText`, `hir::layouts::ReprUnionAt`, `hir::layouts::ReprUnionPath`, `hir::layouts::ResolveArrayTerm`, `hir::layouts::ResolveRepr`, `hir::layouts::ShowTerm`, `hir::layouts::ShowTypeExpr`, `hir::layouts::WithLeafType`, `hir::layouts::WordsFormats`, `hir::layouts::align`, `hir::layouts::size`, `core::binary::EncodeForeign`, `core::binary::Rows`, `core::binary::DecodeRepr`, `core::binary::HasArrays`, `core::binary::EncodeRepr`, `core::binary::ReprHoldsRaw`, `core::binary::ReprUnionPath`, `core::binary::ReprPointerPath` | a layout representation, one level per nested array, union or record; a layout descriptor's representation, one level per nested array, union or record (the Tcl compiler's static descriptors; the Tcl backends' codec) | structural: each call descends to a child of a finite tree | guard added | section 5 |
| core IR lowering (4) | `hir::lower::Exprs`, `hir::lower::Seq`, `hir::lower::body`, `hir::lower::expr` | HIR to core IR (the interpreter's program) | structural: each call descends to a child of a finite tree | guard added | section 5 |
| core IR check (2) | `core::ir::CollectBindNames`, `core::ir::check` | core IR validation and binding collection | structural: each call descends to a child of a finite tree | guard added | section 5 |
| Tcl compiler (22) | `core::compiler::CompileBind`, `core::compiler::CompileBlock`, `core::compiler::CompileBlockBody`, `core::compiler::CompileCall`, `core::compiler::CompileCondition`, `core::compiler::CompileExpr`, `core::compiler::CompileForm`, `core::compiler::CompileHandle`, `core::compiler::CompileIf`, `core::compiler::CompileProject`, `core::compiler::CompileSequence`, `core::compiler::CompileStruct`, `core::compiler::ConditionIf`, `core::compiler::ConditionBranch`, `core::compiler::ReleasingOnError`, `hir::WalkInto`, `hir::aot::TailInto`, `core::compiler::CompileListLoop`, `core::compiler::CompileCountLoop`, `core::compiler::ArrayOfRecords`, `core::compiler::LayoutLeaves`, `core::compiler::LayoutValueText` | code generation, one call per nested expression; the compiler's walk of nested expressions; tail positions; a layout representation's leaves and values | structural: each call descends to a child of a finite tree | guard added | section 5 |
| native lowering (49) | `hir::construction::SeqUses`, `hir::construction::Uses`, `hir::escape::ChooseLevel`, `hir::escape::Classify`, `hir::escape::ClassifyIf`, `hir::escape::CutFields`, `hir::escape::LiteralTree`, `hir::escape::WriteBackPaths`, `native::lower::Call`, `native::lower::Bind`, `native::lower::CallArgs`, `native::lower::CallInner`, `native::lower::ConstantIntValue`, `native::lower::Expr`, `native::lower::Project`, `native::lower::Handle`, `native::lower::If`, `native::lower::MandatoryWriteBack`, `native::lower::Sequence`, `native::lower::SequenceTo`, `native::lower::StaticOutcome`, `native::lower::StaticOutcomeOf`, `native::lower::StructFields`, `native::shortstr::DemandBody`, `native::shortstr::DemandWalk`, `native::shortstr::LiveWalk`, `native::rawabi::If`, `native::rawabi::Seq`, `native::rawabi::Walk`, `native::lower::Struct`, `native::lower::VirtualValue`, `native::rawabi::Call`, `native::lower::ListLoop`, `native::lower::CountLoop`, `native::lower::IterationBody`, `native::lower::LoopBody`, `native::lower::DeferredNeeds`, `native::lower::Condition`, `native::lower::ConditionIf`, `native::lower::ConditionBody`, `native::lower::EmitRegionConsumerCondition`, `native::lower::EmitRegionConsumerBody`, `native::lower::ArrayCheck`, `native::lower::ArrayRead`, `native::lower::LayoutLeaves`, `native::lower::ReprHasArrays`, `native::lower::ReprRead`, `native::lower::ReprWrite`, `native::lower::ViewBase` | construction uses (escape of nested values); escape and scalar-replacement plans of nested constructions; HIR to NIR, one call per nested expression; short-string demand and liveness walks; raw ABI walk; a scalar-replaced struct's fields read back as a value, one level per nested construction; a branch-form condition's Boolean structure (BRANCH-FORM-BOOLEAN-LOWERING.md); an inlined region consumer's condition and body; a layout representation's reads, writes and checks | structural: each call descends to a child of a finite tree | guard added | section 5 |
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

The prompt preferred explicit work stacks. Rewriting 215 procedures --
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
  segment below. The bound is 150 frames in a segment (Tcl counts a
  coroutine's frames from its own base), 200 outside a driver. A walk that
  goes up and down across the bound makes a segment at each crossing, so
  the bound sits above what an ordinary program's analyses reach without
  deep nesting: at 60 frames, branch-form-boolean.bot's call chains, which
  reach about 120 frames, made 5,000 segments and took a third longer to
  compile; at 150 they make none. Every specimen still compiles 1000 deep
  at a recursion limit of 500 (the driver's stack holds at most 98
  segments then), so a driver started 200 frames deep and a full segment
  stay well inside Tcl's 1000.
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
| `layout` | a layout field `array 1 of array 1 of ... U8`, parsed from one byte | the parser's `ArrayTypeExpr`; `hir::layouts`' representation walks (`ResolveRepr`, `ResolveArrayTerm`, `ReprDescriptor`, `ReprText`, `CopyType`, `WordsFormats`, ...); native lowering's `ReprRead`, `ArrayRead`; the layout codec's descriptor walks, which the Tcl compiler reads at compile time (`core::binary::ReprPointerPath`, ...: found by the probe; the census traces `core::binary` since) -- and, guarded with them, every other walk of a representation (writes, views, checks, the Tcl compiler's layout leaves, the codec's encoding and decoding), which parsing does not reach |
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
  fields). Peak memory of a process compiling a List literal 400 deep
  through the front end, core IR, the Tcl compiler and native lowering:
  590 MB before, 39 MB after; 800 deep, 64 MB (`bench/nested-frontend.tcl
  -kinds list -depths 400,800`).
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

* **Structural ids are paths (not changed).** `surface::ast::Ids` gives
  each node the id of its path from the statement that holds it
  (`x=/value/right/right/...`), and every HIR expression's origin carries
  its node's id (`origin {file f1 node x=/value/right/right/right ...}`):
  a node N levels deep has an id of about 6N characters, so the ids of a
  chain N deep hold O(N^2) characters. The parser of `1 + (1 + ...)`
  without segments (plain recursion, a raised limit) uses 25, 63 and 167 MB
  1000, 2000 and 4000 deep, the same as with them; parentheses, which make
  no node, 14, 27 and 55 MB. Ids are origins, static-site and
  method-seed keys and part of the HIR interchange text, so a
  depth-independent id is a format change of its own (section 26), not
  this milestone's.

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
  the parser's syntax diagnostic. Seeds 1 to 6: 72 programs, spines 6 to
  1,499 deep (median 598), each valid on interp and cranelift, the same
  HIR with segments of 2 to 60 frames, its malformed copy the parser's
  diagnostic: 0 failures.
* **The probe** (`probe.tcl`): section 1's paths for every specimen 1000
  deep at the default limit. A path fails when it hits TCL LIMIT STACK, or
  with any other error the same program 3 deep does not get. Every kind
  through every scenario: 250 paths, 247 compile, and three are refused
  at any depth -- the `struct`, `mixed` and `pattern` specimens' first
  statement made a module binding, whose initializer may not construct a
  struct or project a field (MODULE-CONTEXT, 1 deep as 1000 deep); 0
  failures. (A kind whose first statement is no one-line binding has no
  module-binding path.) On the old tree (`baseline.tcl -root`, section 2)
  every kind fails before 1000 deep.

## 19. Mutation testing

`audit/depth-safe-nesting/tools/mutate.tcl` applies each mutant of
`mutants.txt` to a private copy of the compiler and runs the tests its `!!`
line names there (after a control run of all of them on the unmutated
copy). The phase mutants are generated from the census
(`phase-mutants.py`): one per phase, every guard of the phase removed, so
host recursion comes back to that phase alone while the others stay
depth-safe -- the milestone is not parser-local. The rest are written by
hand: the segment mechanism, the artificial limits a fix could hide behind,
and the semantics the walks must keep (associativity, precedence,
evaluation order, error positions, stringification, the constant fold).
48 mutants, all killed:

| mutant | the bug | killed by |
|---|---|---|
| `parser-recursion` | the parser's productions recurse through host calls again (every parser guard removed) | `dsn-1000-ifnest`, `dsn-1000-list`, `dsn-1000-paren`, `dsn-census-guarded` |
| `paren-recursion` | parentheses recurse through host calls again: the expression chain unguarded, the List, field and argument productions still guarded | `dsn-1000-paren` |
| `ast-recursion` | the parser iterative, the AST's walks (ids, its text) recursive | `dsn-1000-flat`, `dsn-text` |
| `loader-recursion` | the loader's walks of a file recursive | `dsn-1000-list` |
| `surface-lowering-recursion` | AST to HIR syntax recursive | `dsn-1000-handler`, `dsn-1000-list` |
| `static-sites-recursion` | the static-site walks recursive | `dsn-1000-list`, `dsn-static-compile` |
| `resolve-recursion` | the parser and lowering depth-safe, resolution recursive | `dsn-1000-list`, `dsn-1000-struct` |
| `types-recursion` | resolution depth-safe, type inference recursive | `dsn-1000-list`, `dsn-1000-struct` |
| `contracts-recursion` | contract inference recursive | `dsn-1000-call` |
| `range-recursion` | the range analysis recursive | `dsn-1000-elif`, `dsn-1000-rbin` |
| `completions-recursion` | the completion analysis recursive | `dsn-1000-call`, `dsn-1000-handler` |
| `callables-recursion` | the callable audit recursive | `dsn-1000-call` |
| `warnings-recursion` | the warning passes' walks recursive | `dsn-warnings` |
| `affine-recursion` | the affine flow recursive | `dsn-affine-chain` |
| `stamp-recursion` | a trait or coroutine program's syntax stamped recursively | `dsn-affine-chain`, `dsn-trait-program` |
| `coreir-recursion` | the analyses depth-safe, core IR lowering recursive | `dsn-1000-flat`, `dsn-1000-list` |
| `coreir-check-recursion` | core IR's check recursive | `dsn-1000-list` |
| `tcl-compiler-recursion` | core IR depth-safe, the Tcl compiler recursive | `dsn-1000-list`, `dsn-1000-rbin` |
| `native-recursion` | the Tcl compiler depth-safe, native lowering recursive | `dsn-1000-list`, `dsn-1000-struct` |
| `hirtext-recursion` | HIR text printed and read recursively | `dsn-cache`, `dsn-text` |
| `service-recursion` | the service's index of a file recursive | `dsn-service` |
| `repeatable-recursion` | the repeatability analysis recursive | `dsn-repeatable` |
| `modulebinding-recursion` | a module binding's value walked recursively | `dsn-module-binding` |
| `injection-recursion` | the injection proof's provenance walk recursive | `dsn-1000-inject` |
| `layouts-recursion` | layout representations resolved and described recursively | `dsn-1000-layout` |
| `consumed-fold-recursion` | a consumed fold intermediate's exits walked recursively | `dsn-consumed-fold` |
| `codec-recursion` | the layout codec's descriptor walks recursive (the Tcl compiler reads them at compile time) | `dsn-1000-layout` |
| `give-skipped` | a segment's state is never given back to the caller's frame: the caller's locals stay emptied | `dsn-1000-list`, `dsn-mechanism-walk` |
| `give-on-error-skipped` | after an error unwinds through a segment (a syntax error deep in the parser), the caller's frame is left emptied: recovery reads an empty parser state | `dsn-mechanism-errors` |
| `namespace-links-copied` | a link to a namespace variable is taken as a copy: what the segment's code writes to the namespace variable directly is lost when the copy is written back | `dsn-mechanism-walk` |
| `created-variables-lost` | a variable the guarded call creates in its caller's frame stays in the segment | `dsn-mechanism-run` |
| `wrong-segment-resumed` | the driver resumes the bottom of its stack, not the top: continuation frames in the wrong order | `dsn-1000-list`, `dsn-mechanism-walk` |
| `segment-dropped` | a finished segment pops two: the segment waiting below it is never resumed | `dsn-1000-list`, `dsn-mechanism-walk` |
| `nested-drivers` | a guarded call inside a running segment starts a driver of its own there instead of yielding: each segment's frames stack on the last, and the host's nesting grows with the program's again | `dsn-1000-list`, `dsn-1000-paren` |
| `outcome-ignored` | a segment's result is returned whatever its return code: an error deep in a walk becomes a value | `dsn-malformed`, `dsn-mechanism-errors` |
| `limit-at-a-segment` | a program deep enough to need a segment is rejected as too deep (a limit of about six parentheses) | `dsn-depths` |
| `limit-past-1000` | the driver's stack bounded at 200 segments: every 1000-deep specimen still compiles (at most 98 at once), 5000 parentheses (370) do not -- 1000 made a limit | `dsn-beyond` |
| `limit-stack-translated` | the parser recursive again, Tcl's stack exhaustion turned into a syntax error | `dsn-1000-paren` |
| `host-depth-decides-instances` | hir::semantic declines an instance again where Tcl's frames are deep | `dsn-census-guarded` |
| `additive-right-associative` | + and - associate to the right | `dsn-depths` |
| `unary-operand-postfix` | unary minus takes a postfix expression, not another unary one: `--1` no longer parses | `dsn-depths` |
| `arguments-right-to-left` | the reference interpreter evaluates a call's arguments right to left (each still in its own position) | `dsn-evaluation-order` |
| `paren-error-at-opener` | an unclosed parenthesis is reported at the parenthesis, not where the closer was expected | `dsn-malformed` |
| `field-error-at-construction` | a construction's field TYPE error is reported at the construction, not at the field | `dsn-type-error-deep` |
| `intrinsic-names-searched-as-text` | the syntax is searched for an intrinsic trait's name as text again: every nested node gets a string | `dsn-no-stringified-syntax` |
| `children-concatenated` | a call's children are joined with concat: every argument node gets a string | `dsn-no-stringified-syntax` |
| `sections-concatenated` | the loader joins the modules' sections with concat again: every node of every module loaded after the first gets a string | `dsn-module-not-stringified` |
| `constant-fold-repeated` | native lowering asks every integer constant expression's whole subtree again at each level | `dsn-linear-constant-fold` |

The first run killed 43 of 48. Five phase mutants survived, and each was a
finding about the detectors, not the guards: four phases had no test that
drives their walk deep -- core IR's check (no test called it: every
1000-deep compilation in the test file now does), the service's index of a
file (the test made no position query), the warning passes' exit walks (no
block-nested specimen in the warnings test) and the repeatability analysis
(it runs only on a proof-producing predicate decided at a second call:
`dsn-repeatable`) -- and are killed by the strengthened tests. The fifth,
call-site specialization, is an equivalent mutant: its walk re-enters type
inference at every level (`Analyze` -> `hir::types::inferRegion` ->
`Sequence` -> `Expr` -> `Call` -> `Handle` -> `Analyze`), whose guards
bound it, so removing specialization's own guards changes nothing (its
compile of 400 nested functions without them still passes). Its guards
stay -- the census lists every procedure active as deep as the program
nests -- and the generator no longer makes that mutant. The twelve
procedures the last census pass found (section 4) are of the same kind:
each recurses only through guarded procedures, so removing one's guard
alone is caught by `dsn-census-guarded` and by no depth; the phase
mutants were regenerated with them (they remove those guards too), and
the seven that changed -- parser, inference, range, completions,
callables, Tcl compiler, native lowering -- were run again with
`limit-past-1000`, whose bound moved with the segment size (section 5):
8 of 8 killed.

The mutants of other audits that quote code this milestone changed were
updated in place, keeping each a mutant of the same rule, and run through
their own harnesses: c-pointer-borrowing's `transport-only-with-struct-opt`
and `transport-not-in-generic-lowering`, error-payloads'
`nested-destructuring-handler-specific`, layout-unions' `union-as-struct`
and `pointer-union-parse-allowed`, native-link-plan's
`module-links-dropped` and binary-layout's `nested-emit-skipped-interp`:
killed. `tools/mutant-catalogs.tcl`: 89 catalogs, 3175 mutants, every one applies.

## 20. Performance

`bench/nested-frontend.tcl`: each specimen kind 250, 500 and 1000 deep
(and the cheap kinds 2000 deep), each compiled in a fresh process at Tcl's
default limit -- the front end (parse, lowering, the whole-program build
and its checks), core IR, the Tcl compiler's unit, native lowering --
with the process's peak memory and the segments made. Milliseconds 1000
deep, then the total's growth per doubling of the depth (2 is linear),
measured on a 4-core container with other test processes beside it (the
ratios, not the times, are the point):

| kind | tokens | HIR exprs | front | core IR | Tcl | native | total | peak MB | segments | x 250→500 | x 500→1000 | x 1000→2000 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `paren` | 2007 | 3 | 135 | 0 | 1 | 17 | 153 | 31 | 79 | 1.43 | 1.53 | 1.38 |
| `rbin` | 4007 | 3003 | 950 | 13 | 85 | 439 | 1487 | 96 | 727 | 2.03 | 2.09 | 2.50 |
| `lbin` | 4007 | 3003 | 921 | 13 | 81 | 477 | 1492 | 90 | 727 | 2.02 | 2.69 | 2.26 |
| `flat` | 2007 | 3003 | 805 | 13 | 83 | 491 | 1392 | 88 | 628 | 2.05 | 2.22 | 2.14 |
| `neg` | 1007 | 3003 | 754 | 12 | 81 | 503 | 1350 | 100 | 610 | 2.28 | 2.02 | 2.66 |
| `not` | 1007 | 3003 | 5275 | 15 | 53 | 5470 | 10813 | 96 | 16105 | 2.26 | 2.48 | 2.66 |
| `list` | 2007 | 2003 | 683 | 11 | 50 | 345 | 1089 | 75 | 509 | 1.99 | 2.13 | 2.42 |
| `struct` | 17024 | 2005 | 3584 | 10 | 50 | 3249 | 6893 | 162 | 10184 | 2.61 | 4.34 | 3.91 |
| `project` | 21024 | 4005 | 3548 | 14 | 74 | 2204 | 5840 | 129 | 6937 | 2.62 | 3.31 | 3.48 |
| `call` | 3023 | 2007 | 577 | 11 | 44 | 319 | 951 | 74 | 530 | 2.88 | 1.72 | 2.33 |
| `method` | 4025 | 2010 | 687 | 9 | 38 | 277 | 1011 | 100 | 440 | 1.89 | 2.06 | 2.27 |
| `or` | 4009 | 8999 | 14948 | 38 | 167 | 12600 | 27753 | 202 | 33304 | 2.49 | 2.66 |  |
| `and` | 4009 | 11999 | 20559 | 60 | 269 | 18315 | 39203 | 252 | 41830 | 2.76 | 2.79 |  |
| `elif` | 10017 | 6008 | 2872 | 30 | 315 | 1078 | 4295 | 232 | 1570 | 2.94 | 2.60 |  |
| `ifnest` | 13021 | 3006 | 2597 | 17 | 474 | 801 | 3889 | 215 | 1842 | 2.92 | 2.77 |  |
| `fnnest` | 14003 | 4001 | 2912 | 25 | 33810 | 14682 | 51429 | 906 | 24348 | 4.93 | 5.46 |  |
| `handler` | 14053 | 4017 | 17323 | 24 | 862 | 1090 | 19299 | 742 | 18069 | 3.83 | 3.86 |  |
| `mixed` | 4029 | 2007 | 789 | 11 | 54 | 355 | 1209 | 98 | 560 | 1.86 | 2.27 |  |
| `typed` | 5034 | 2066 | 764 | 10 | 48 | 341 | 1163 | 79 | 541 | 1.87 | 1.83 |  |
| `pattern` | 19030 | 4010 | 5110 | 16 | 86 | 4792 | 10004 | 182 | 6263 | 3.37 | 3.60 |  |
| `loops` | 15675 | 6393 | 13407 | 34 | 389 | 22575 | 36405 | 564 | 58268 | 3.79 | 3.85 |  |
| `cond` | 10727 | 18032 | 49494 | 83 | 443 | 53117 | 103137 | 576 | 52113 | 2.71 | 2.90 |  |
| `inject` | 7017 | 2005 | 3232 | 9 | 165 | 599 | 4005 | 260 | 1194 | 2.83 | 2.95 |  |
| `layout` | 3145 | 481 | 464 | 2 | 29 | 169 | 664 | 53 | 234 | 1.24 | 1.31 |  |
| `affine` | 15150 | 1047 | 1245 | 7 | 61 | 1030 | 2343 | 142 | 448 | 2.13 | 2.60 |  |



* **Linear or nearly:** parentheses (×1.5 from 500 to 1000 deep, ×1.4 to
  2000) and `layout` (×1.3); the expression chains -- `rbin`, `lbin`,
  `flat`, `neg`, `not`, `list`, `call`, `method`, `mixed`, `typed` --
  ×1.7 to ×2.7 from 500 to 1000 deep and ×2.1 to ×2.7 to 2000, `affine`
  ×2.6: above 2 by their structural ids (section 16), O(depth) characters
  each, which memory and every copy of an origin carry (`rbin` takes 96
  MB 1000 deep, 248 MB 2000 deep).
* **Superlinear, each named in section 25:** `and`/`or` and `cond`
  (×2.7 to ×2.9: inference, completions, branch facts and the range
  analysis of Boolean chains), `struct`/`project` and `pattern` (×3.3
  to ×4.3: native lowering's escape and scalar-replacement plans of nested
  constructions, and the front end's), `elif`/`ifnest`/`inject` (×2.6
  to ×3.0: a block nested N deep is indented N times), `handler` (×3.9:
  each handler body range-analyzed again per enclosing handler), `loops`
  (×3.9) and `fnnest` (×5.5: the Tcl compiler's code for nested
  functions, 906 MB 1000 deep).
* **Segments are linear in the work**: about one per 150 guarded frames
  that a walk goes down (727 for `rbin` 1000 deep, 1,501 2000 deep); a
  walk that goes up and down the nesting many times (inference of a `not`
  chain re-entered per level: 16,105) makes as many as it descends. With
  60-frame segments (section 5) the same table had two to three times as
  many segments and totals up to a fifth higher (`handler` 23.6 s then,
  19.3 s now).
* **Ordinary programs.** `bench/guard-overhead.tcl` compiles seven
  programs that nest a little -- the branch-form-boolean, fold-loops,
  core-semantics, coroutines, loops and callables suites and the 2048
  suite -- three times each, keeping the fastest, with this branch and
  with main (`f2787af`, which the branch merged), twice in turn: the front
  end 63.6 and 64.3 s against main's 63.4 and 66.3 s, the lowerings 39.7 s
  both times against 40.2 and 40.0 s -- within the runs' own variation.
  One suite stands out: branch-form-boolean.bot, whose analyses run
  deepest, 4.64 and 4.68 s against 4.23 s. Its walks make no segment
  (section 5), but call guarded procedures often enough for the guards'
  check -- `info level` and a qualified variable, about 0.14 µs a call --
  to cost 8%: 4.25 s with every guard line removed. With 60-frame segments
  it took 6.6 s.

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
  a segment every 3 frames as with the default 150 (the Tcl compiler's
  temporaries counted from the same place: their counter is process-wide).
* **The corpus compiles as it did.** Every golden suite and the 2048 and
  Icy Tower suites (120 programs), each compiled in a process of its own by
  the old tree and by this one
  (`audit/method-resolution/tools/invariance.tcl -root`, then `-compare`):
  the same method-call decisions and choices, static outcomes, accepted
  programs' HIR text, reported diagnostics and build counts -- 0
  differences.
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

Locally (a 4-core container, Tcl 9.0.1), on the branch with main merged:

* `tests/depth-safe-nesting.test` at Tcl's default limit: 51 tests, all
  pass (1,179 s alone; recorded for the canary, `tests/canary.tsv`).
* `tclsh9.0 tests/local.tcl -jobs 3`: 662 items -- 272 Tcl test files on
  interp and compile (golden duplicates skipped) and 118 golden suites on
  all four backends -- in 118 minutes: 658 passed. The other four were two
  tests that counted something segments change, each failing on both
  passes, fixed and run again. `dsn-mechanism-walk` asked for more than
  300 segments, which only 60-frame segments make (it asks for a segment
  per segment's frames now: the file 51 of 51). branch-form-boolean.test's
  `bf-lowering-work-linear` counted every entry of two guarded procedures,
  and a call that goes on in a segment is entered twice; it counts the
  entry that does not descend now (a trace sees the level the call will),
  the same at segments of 25, 60 and 150 frames: 32 of 32 on both passes,
  and its audit's `nir-static-outcome-unmemoized` is still killed by it.
* The probe (section 18), the census of every kind (section 4), the fuzzer
  (seeds 1 to 6, section 18, and seeds 7 and 8 on the final tree: 24
  programs 25 to 1,382 deep, 0 failures), the mutants (section 19), the corpus's
  invariance against the old tree (section 21), `tools/compilerpedia.tcl
  check` (1222 topics, 753 examples, 0 problems) and
  `tools/mutant-catalogs.tcl` (89 catalogs, 3175 mutants, every one
  applies).

`main` was green or still running at both ends of the work (no workflow
failed on it): when the branch started, and when main (`f2787af`, then
`53a0d1b`) was merged into it -- its latest finished test runs (`43f6869`,
then `f2787af`) and static-decisions (`1d73754`) green, the newer heads'
still running.

**The merge into main.** Main merged again at `0030f8a` (76 commits:
consumed fold intermediates, loop clause binding types, the Android
target, external tools and target support packages, the single
executable's own Tcl library, unused context imports). One conflict:
`native::lower::IterationBody` took main's new `mode` parameter and kept
its guard (its phase mutant's text updated). Three new walks follow the
nesting (section 4): `hir::mutvec::FoldWalk` and `FoldWalkSequence` failed
with TCL LIMIT STACK on a 1000-deep sum in a consumed fold's body, and the
`loops` census reported `native::lower::LoopBody` missing; all three
guarded and listed (215 procedures), with `dsn-consumed-fold` (the file:
52 tests) and the phase mutant `consumed-fold-recursion`, killed by it. On
the merged tree: `tests/local.tcl` over the depth-safe file, main's new
and changed test files (consumed-fold-intermediates,
fold-virtual-construction, loop-clause-binding-types, unused-context,
resources, hir-cache, compiler-service, c-abi-types, target-model,
native-library, external-tools, android-target) and fold-loops,
branch-form-boolean and threads -- 16 files on interp and compile, 574
tests each, 0 failed, and their 2 golden suites on all four backends;
the census of the `loops` (`-fraction 3`) and `mixed` (`-fraction 4`)
specimens, 0 missing; `tools/mutant-catalogs.tcl` (98 catalogs, 3356
mutants, every one applies); `tools/ci/test_runs.py`;
`tools/compilerpedia.tcl check`. Then main once more, at `a04d06e` (the
method-call decision's F2 and F3, and F4's NOT-CALLABLE): no conflict and
no new walk over the nesting; `tests/local.tcl` over the depth-safe file,
not-callable, method-resolution, method-sugar, method-filter,
static-compile, golden-framework and diagnostic-recovery -- 8 files on
interp and compile, 322 tests each, 0 failed, and their 12 golden suites
on all four backends; the mutant catalogs (99, 3371 mutants), the CI
tools' tests and the Compilerpedia check (0 problems) again.

CI on the branch (a run a newer push superseded says nothing either way):

* **The head, `0dae7f8a`** (main's `53a0d1b` merged, its one conflict
  `hir::lower`: main's thread refusal before the branch's driver), every
  workflow green: tests.yml and tests-arm64.yml dispatched (every job but
  tests.yml's GC-stress run, which is main's), static-decisions.yml
  dispatched (mutable-array.bot and the four shards: no suite
  disagrees), macos-arm64.yml (smoke, the
  system linker, the acceptance tier, Botlish.app and its follow-ups),
  windows-x86_64.yml (smoke, root plans, the acceptance tier, the system
  linker), icy-tower's macOS and Windows workflows, ci tools, the raven
  clean room and package reproducibility.
* **The macOS acceptance tier in five shards.** On `549071b` every
  workflow passed but macos-arm64.yml, whose acceptance shard 2 of 4 hit
  the job's 75-minute limit with no test failed: tier.tcl deals the items
  to shards by index, not by cost, and that shard held workload-2048.test
  (about 17 minutes) and several other long files; main's own shard 2 took
  55 minutes, and the shard's golden suites ran about 6% slower than in
  main's run (the guards' check is part of it: section 20).
  `1adea066` runs the tier in five shards (the workflow and AGENTS.md): on
  `0dae7f8a` they took 53, 23, 30, 41 and 20 minutes.
* **static-decisions.yml**, the batched scheduler against the sequential
  one over the golden suites: passed on `c6cdd86` (before main was merged
  and before the last twelve guards and the segment size), and passed on
  `a82e469`, whose front end is the head's (only tests and this report
  changed since): no suite disagrees.
* **Earlier heads, superseded before they finished:** tests.yml on
  `456f0d3` passed its canary (the mutant catalogs, the warning gate, the
  changed test files and recent failures), the native Rust unit tests and
  the method-call decision oracle; the two tests fixed in `456f0d3` and
  `549071b` would have failed its later jobs. On `c6cdd86`, before the
  merge: tests.yml's and tests-arm64.yml's push runs (their canaries)
  passed. icy-tower's macOS and Windows workflows passed on `456f0d3`, ci
  tools and the raven clean room on `a82e469`.

## 24. Remaining recursion: the final census

The census (`audit/depth-safe-nesting/census.tsv`) lists 212
procedures, every one guarded (`dsn-census-guarded`). `census.tcl` over
every specimen kind through every scenario (24 deep; `loops`, `cond` and
`mixed`, which cycle through forms, also at `-fraction 3`, 3 and 4, `cond`
12 deep) finds no
procedure active half as many times as the program nests that the census
does not list, and `probe.tcl` runs every kind 1000 deep through every
scenario at the default limit without one TCL LIMIT STACK (section 18).

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
  - **Structural ids: quadratic memory.** Every AST node's id, and every
    HIR origin with it, is the node's path from its statement (section
    16): O(depth) characters each. It is the one superlinear term every
    chain of nodes has (×2.1 to ×2.7 per doubling past 1000 deep, section
    20), and why a chain of nodes' memory is not linear: `1 + (1 + ...)`
    takes 96 MB 1000 deep and 248 MB 2000 deep through every lowering,
    and its front end alone 855 MB 4000 deep.
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
  - **A method-style call of a MutableVector operation with a deep
    argument: cubic memory.** `v.push(1 + (1 + ...))` with the sum 100,
    200 and 400 deep takes 44, 140 and 843 MB in the front end, where
    `std::mutable_vector::push(v, ...)` takes 28, 32 and 43 MB and a
    method-style call of a user function with the same argument 42 MB at
    400. The front end makes one build and no method trial for it
    (`hir::buildStats`), so it is not the method-call decision's builds;
    main without this milestone takes 186 and 1,129 MB at 200 and 400 (its
    recursion limit raised), so it is not the segments'. Found while
    writing `dsn-consumed-fold` after the merge of main (section 23), which
    uses the function form; where it goes (most likely a nested node given
    a string, section 16) was not traced and is left to its own change.
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
* **Depth-independent structural ids** (sections 16 and 25): a node's id
  as its parent's id and one step, interned, instead of its whole path,
  would make the front end's memory linear in the nesting. Ids are HIR
  origins, static-site and method-seed keys and interchange text, which
  must stay stable across a static block's rebuilds: a change of the HIR
  format with its own interchange version and audit.
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
path 1000 deep fails), `audit/depth-safe-nesting/tools/census.tcl`
(no recursive procedure missing), `audit/depth-safe-nesting/tools/fuzz.tcl`
(several seeds) and `audit/depth-safe-nesting/tools/mutate.tcl` (every
mutant applies and is killed by a detector its `!!` line names);
`bench/nested-frontend.tcl` regenerates section 20's table.
