# STATIC-COMPILE.md

`static compile:` -- Botlish's first static intrinsic: a recoverable
semantic-compilation boundary around a parser-valid block.

> `static compile:` creates a recoverable semantic-compilation boundary
> around a parser-valid Botlish block. If the block compiles, it executes
> with its ordinary value and error semantics and the boundary has no
> runtime representation. If semantic compilation rejects the block, the
> diagnostic is reified as `std::compiler::CompilerError` and the block is not
> executed.
>
> Parser errors are not captured by `static compile:`. A future lower-level
> `static parse:` may provide that boundary.
>
> `static compile:` is not an assertion. Testing policy belongs to the test
> framework.

```botlish
import std::compiler

fn probe() -> int errors std::compiler::CompilerError:
    static compile:
        missing

r = probe():
    on std::compiler::CompilerError {code, primary}:
        if code == std::compiler::DiagnosticCode::Unbound:
            primary.line * 1000 + primary.column
        else:
            0
r            # 5009: `missing` is at line 5, column 9
```

The three programs of the brief's success criterion (item 102), on the Tcl
interpreter, the Tcl compiler and Cranelift with and without
specialization (`tests/static-compile.test`):

| block | the compiler | at run time |
|---|---|---|
| `missing` | rejects it: the enclosing program compiles | `std::compiler::CompilerError {code: std::compiler::DiagnosticCode::Unbound, primary: std::compiler::SourceLocation {line: 4, column: 9}, related: [], message: "unbound name \"missing\""}` (`sc-negative-unbound`) |
| `std::list::at(xs, i)` | accepts it | `IndexNotFound` when `i` is out of range, never CompilerError (`sc-success-runtime-error`) |
| `20 + 22` | accepts it | `42`, as without the boundary (`sc-success-value`) |

(`std::list::at([], 0)` itself, the brief's literal example, is a block the
compiler *rejects*: the completion proofs see the empty List and the
constant index, so the call is the ordinary KNOWN-ERROR, reified as code
`KnownError` -- `sc-list-at-empty-is-known-error`. A run-time failure needs an
index the compiler cannot decide.)

## Contents

* [The construct](#the-construct)
* [How it works](#how-it-works)
* [The compiler namespace](#the-compiler-namespace)
* [Diagnostic-code census](#diagnostic-code-census)
* [Decision economics](#decision-economics) -- how many builds the decisions
  take (STATIC-DECISION-ECONOMICS.md has the milestone report)
* [Report](#report) -- the 60 points of the milestone report, in order
* [Performance](#performance)
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The construct

```
staticIntrinsic = "static" IDENT ":" suite        -- surface/parser.tcl
valued          = IDENT "=" (if | loop | staticIntrinsic | handledExpr)
                | "return" (if | loop | staticIntrinsic | handledExpr)
simple          = ... | staticIntrinsic | expression
```

A static intrinsic is a statement, or the value of a binding, a `return` or a
struct destructuring -- the positions an `if` takes. Its body is an ordinary
suite. The operation name after `static` is one of the compiler's static
operations (only `compile`); it is compiler syntax, never looked up in a
scope. `static` and `compile` are contextual: the form is recognized only as
the word `static` directly followed by a name where a statement or a
statement's value starts -- two adjacent names, which no other construct
allows -- so `static = 3`, `static(x)`, `x.static`, `compile = f` and
`compile(x)` are ordinary code, and `static compile:` means the same whatever
the program binds.

A file that uses a static intrinsic imports `compiler` (`import std::compiler`):
a rejected block completes with `std::compiler::CompilerError`, an ordinary
namespaced declaration, and Botlish has no implicit imports. Without it the
loader reports `MISSING-IMPORT` at the `static` keyword.

### Where malformed source stops

At the parser, for the whole file. The body of a static block is parsed by
the program's own parser, so a lexical or grammatical error inside it -- an
unclosed bracket, a malformed declaration, a declaration that is top-level
only (`type`, `struct`, `enum`, `error`, `trait`), an `import` -- is the
enclosing program's syntax error (`{SURFACE SYNTAX ...}`, every one of them
with `-recover 1`), exactly as in any other block, and no CompilerError
exists for it (`sc-grammar-body-parse-error`). The import header, likewise,
is checked before any block is. What `static compile:` recovers is the layer
after the parser: everything the loader says about a qualified reference in
the block, and everything resolution and the static checks say about its
code. A future `static parse:` -- a boundary at the token/parser level --
would sit below it; the two stay distinct.

## How it works

`static compile:` is processed after parsing and before resolution, by
`hir/static.tcl` (its header has the whole design):

1. The parser builds a `static` AST node (operation, captured suite).
   `surface/lower.tcl` lowers the suite to ordinary `hir/syntax.tcl` nodes --
   the same nodes, with the same origins, it would lower anywhere -- under a
   `static` syntax node. The loader (`surface/modules.tcl`) checks every
   qualified reference as always, except that a reference inside a static
   block that the file may not make (`MISSING-IMPORT`, `UNKNOWN-NAMESPACE`,
   `UNKNOWN-SYMBOL`, `NOT-AN-ENUM`, `NOT-A-STRUCT`, `AMBIGUOUS-QUALIFIER`) is
   recorded on that block's node (`deferred`) instead of failing the file.
2. `hir::buildSyntax` sees static nodes and calls `hir::static::decide`.
   Each round *expands* the syntax -- every static node replaced by its
   current form -- and builds the whole program with the ordinary pipeline
   (`hir::BuildFull`: resolution, hygiene, every check, method-call
   decisions, the trait monomorphization, the elaborations). Nothing raises
   during a build: diagnostics are data. Each diagnostic belongs to the
   innermost static block whose body holds its primary location, or to the
   enclosing program.
3. The rounds decide every site in the *sequential order*, which defines
   every outcome: a block with a loader diagnostic is rejected at once; a
   round that stopped after resolution rejects every block with a
   resolution diagnostic of its own (resolution is lexical); otherwise the
   first block in post-order with a diagnostic of its own that does not
   *wait* is rejected, and the blocks before it without one are accepted. A
   block waits while it may read a program-wide channel -- the
   erased-callable contract, a semantic-instance budget under pressure --
   that another block with a diagnostic of its own may change: the
   contributors to a channel are judged before its consumers, so a
   consumer's verdict does not depend on where its contributors are written
   ([The waiting rule](#the-waiting-rule)). A round in which no block has a
   diagnostic of its own is the final program. The scheduler only chooses
   how many builds that order takes: it continues the order on one build for
   as long as the build answers it, committing every rejection whose
   block depends on nothing rejected since, and builds again only where one
   decision changes facts another reads ([Decision
   economics](#decision-economics)).
4. An *accepted* block is its body: spliced in place when it binds nothing
   in its own scope (and is one expression in a value position), else the
   then-branch of an `if` on the root `true` -- exactly the `if true:` block
   that scopes what it binds. A *rejected* block is
   `fail std::compiler::CompilerError {code, primary, related, message}`, built
   from the diagnostic, marked `static {operation compile kind KIND}`.
5. The final program's own diagnostics (none in an accepted body, by
   construction) are its diagnostics, raised by the frontend as for any
   program; warnings run on it as on any program.

Every build is a fresh, pure value: HIR is persistent dicts, and the
per-compilation registries (structs, enums, errors, traits, imports) are
rebuilt from the same top-level declarations by every build. A rejected
body's bindings, moves, refinements, semantic instances, summaries and
method candidates existed only in a build that is discarded: that is the
transaction and its rollback.

## The compiler namespace

`stdlib/compiler.bot`, ordinary Botlish:

```botlish
enum DiagnosticCode:
    AffineCaptureUnsupported,
    ...                       # 87 cases, one per recoverable diagnostic kind
    YieldOutsideFunction

struct SourceLocation:
    line: int
    column: int

error CompilerError:
    code: DiagnosticCode
    primary: SourceLocation
    related: List[SourceLocation]
    message: str
```

The compiler's one privilege is constructing these values from its own
diagnostic (`hir::static::Reified`): `code` is the case of the diagnostic's
kind (`hir::static::codes`, an explicit table: `UNBOUND` is `Unbound`,
`USE-AFTER-MOVE` is `UseAfterMove`, one case per kind and one kind per case,
the Botlish enum spelling of the kind); `primary` is the line and column a
strict compile reports it at, in the file the block is written in; `related`
the further locations the diagnostic names, in the order its message names
them (a used value's move, for `USE-AFTER-MOVE` and
`AFFINE-NOT-DEFINITELY-LIVE`; `[]` for every other kind today); `message` the
ordinary message, without its location prefix -- for reading, never the
identity to compare (compare `code`). Everything after that is ordinary:
the payload is an ordinary anonymous struct, transported field-wise in the
native payload slots, bound and destructured by ordinary handlers, rendered
by the ordinary renderer (`<error std::compiler::CompilerError {code: ...}>` when
uncaught under `-strict 0`).

There is one error, not one per diagnostic: what happened at the level of
control flow is that compilation rejected the block; which diagnostic did is
`code`.

## Diagnostic-code census

Every error diagnostic kind the front end can report, classified
(`tests/static-compile.test`'s `sc-census-exhaustive` holds the
classification and fails on any new, unclassified kind token in `hir/*.tcl`
or `surface/modules.tcl`; `sc-codes-one-to-one` holds the table against the
enum):

| class | kinds | a `CompilerError` code? |
|---|---|---|
| semantic / HIR (resolution, types, structs, flags, method calls, enums, refinements) | UNBOUND, DUPLICATE, TYPE, ARITY (flags, syscalls), BREAK-OUTSIDE-LOOP, CONTINUE-OUTSIDE-LOOP, RETURN-OUTSIDE-CALLABLE (a top-level block), DUPLICATE-FIELD, DUPLICATE-FLAG, DUPLICATE-FLAG-DECLARATION, DUPLICATE-LOOP-VARIABLE, FLAG-BINDING-COLLISION, FLAG-CALLEE-UNKNOWN, FLAG-FUNCTION-VALUE, UNKNOWN-FLAG, LOCKSTEP-UNEQUAL, LOCKSTEP-UNPROVEN, NOMETHOD-CALL, AMBIGUOUS-METHOD-CALL, NO-APPLICABLE-METHOD, NOT-A-STRUCT, UNKNOWN-FIELD, UNKNOWN-STRUCT, MISSING-FIELD, UNPROVEN-FIELD, UNKNOWN-ENUM-CASE, PROOF-CLAUSE, REFINEMENT-MINT-AUTHORITY, OPAQUE-CONSTRUCTION, OPAQUE-REPRESENTATION | yes |
| ownership (affine, coroutines, mutable places) | USE-AFTER-MOVE, AFFINE-NOT-DEFINITELY-LIVE, AFFINE-CAPTURE-UNSUPPORTED, AFFINE-CONTAINER-UNSUPPORTED, AFFINE-DUPLICATION-UNSUPPORTED, AFFINE-ELEMENT-COPY-OUT, AFFINE-EQUALITY-UNSUPPORTED, AFFINE-ERASURE-UNSUPPORTED, AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE, AFFINE-GENERIC-NESTED-UNSUPPORTED, AFFINE-INSTANCE-BUDGET, AFFINE-LIST-OPERATION-UNSUPPORTED, AFFINE-PATH-RELEASE-UNSUPPORTED, AFFINE-TEMPORARY-UNSUPPORTED, MUTABLE-PLACE-CAPTURE, MUTABLE-PLACE-RECEIVER, COROUTINE-CONTRACT, COROUTINE-NOT-FUNCTION, COROUTINE-RESULT-MISMATCH, COROUTINE-RESUME-ARITY, COROUTINE-RESUME-CONFLICT, COROUTINE-RESUME-TYPE, COROUTINE-RESUME-UNDERCONSTRAINED, COROUTINE-RHS-NOT-YIELDING, UNWRAPPED-YIELD, YIELD-OUTSIDE-FUNCTION (a top-level block) | yes |
| completion | UNHANDLED-ERROR, KNOWN-ERROR, UNDECLARED-ERROR, MISSING-ERROR-PAYLOAD, UNEXPECTED-ERROR-PAYLOAD | yes |
| module / context / trait | MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION, CONTEXT-BINDING-COLLISION, CONTEXT-FUNCTION-VALUE, CONTEXT-INSTALLATION-UNSUPPORTED, CONTEXT-TRAIT-MISUSE, CONTEXT-TRAIT-POSITION, DUPLICATE-CONTEXT-PARAMETER, NOT-A-CONTEXT, MODULE-CONTEXT, MODULE-IMMUTABLE, TRAIT-IMPL-ORDER, TRAIT-INSTANCE-BUDGET, TRAIT-NESTED-POLYMORPHIC, TRAIT-NOT-SATISFIED, TRAIT-POLYMORPHIC-FUNCTION-VALUE, TRAIT-POLYMORPHIC-RECURSION, TRAIT-STORAGE-UNSUPPORTED, TRAIT-UNKNOWN-OPERATION, TRAIT-VIEW-MISUSE, TRAIT-WITNESS-JOIN | yes |
| loader, a qualified reference in a block | MISSING-IMPORT, UNKNOWN-NAMESPACE, UNKNOWN-SYMBOL, NOT-AN-ENUM, NOT-A-STRUCT, AMBIGUOUS-QUALIFIER | yes (deferred, step 1) |
| loader, header only | CYCLE, DUPLICATE-IMPORT, DUPLICATE-NATIVE, INVALID-TOPLEVEL, MODULE-COLLISION, NOT-A-TYPE, RESERVED-NAMESPACE, SELF-IMPORT, TYPE-IMPORT-COLLISION | no: a block has no header |
| declaration (top level only: a block cannot declare a type, struct, enum, error or trait) | CYCLIC-REFINEMENT, REFINEMENT-CARRIER, TRAIT-DUPLICATE-REQUIREMENT, TRAIT-NAME-COLLISION, TRAIT-OTHER-TRAIT, TRAIT-REQUIREMENT-RECEIVER, TRAIT-SELF-POSITION, ENUM-EMPTY | no |
| top-level installation only | CONTEXT-TYPE-NOT-EXACT, DUPLICATE-CONTEXT | no: an installation in a block is CONTEXT-INSTALLATION-UNSUPPORTED |
| not from source | LISTLOOP-BREAK-VALUE (core IR / HIR text only) | no |
| parser | SURFACE SYNTAX, with codes (STATIC-INTRINSIC-FORM, STATIC-UNKNOWN-OPERATION, LIST-DESTRUCTURING, ...) | no: the enclosing program's parse error |
| run time only | NOT-BOOLEAN, NOT-CALLABLE, a plain call's ARITY, a native's argument TYPE (`1 + "x"`) | no: the block is accepted and fails at run time |
| internal | CONTEXT-TRAIT-INTERNAL, TRAIT-INTERNAL, a monomorphized-program diagnostic (`internal 1`), CORE MALFORMED, Tcl errors | never: fails the compilation |
| warnings | SAME-RETURN-VALUE, METHOD-ELIGIBLE, FIXED-ARITY-LIST-RETURN, SAME-FAILURE, PROVES-NAMING, ONE-CHAR-STRING-LITERAL, MANY-BOOLEAN-ARGUMENTS | never |

A few kinds are *anchored outside* the block that causes them, by the
ordinary compiler's own convention, and are therefore the enclosing
program's diagnostics, not the block's: `MISSING-CONTEXT` (at the top-level
call of the function needing the context), a semantic instance's derived
"call to F with x : T is invalid" (at the call), a violated inferred
parameter contract (at the call), the call form of `UNWRAPPED-YIELD`, and a
function's declared result not proven (at the enclosing function's
literal). The block compiles; the program using it does not.

## Decision economics

What the decisions *are* is the sequential order of step 3: the definition
of every outcome. How many whole-program builds deciding them takes is a
separate question, answered by the scheduler (`hir::static::decide`'s
`scheduler`; STATIC-DECISION-ECONOMICS.md has the measurements and the
milestone report). Three schedulers exist, and all three decide the same
program:

* **batched** (the default) runs the sequential order on one build for as
  long as that build answers it;
* **sequential** builds after every typed rejection: the reference the
  batched scheduler is checked against;
* **legacy** is the procedure before the economics milestone (below), kept
  for the before/after measurements.

`BOTLISH_STATIC_SCHEDULER=sequential|legacy` selects one for a whole
process (how the audits run the existing suites under the reference);
`BOTLISH_STATIC_TRACE=1` prints each compilation's decision trace.

### The waiting rule

Part of the definition, not of the economics. A *program-wide channel* is a
fact every site reading it shares and every site feeding it may change, from
anywhere in the program: the erased-callable contract (what every callable
passed into an untyped parameter can raise, charged to every call through an
uncontracted value) and a semantic-instance budget under pressure. Without
the rule, the sequential order judged a consumer of such a channel against
whatever the program fed it at that point, so a consumer written before a
contributor that was rejected later kept a rejection the final program no
longer justified -- and written after it, it was accepted:

```botlish
fn consumer() -> int errors std::compiler::CompilerError:
    static compile:
        fn run(fs: List[any]) errors IndexNotFound:
            f = std::list::at(fs, 0)
            f()                     # charged what the program erases
        r = run([harmless]):
            on IndexNotFound:
                -2
        1

fn eraser() -> int errors std::compiler::CompilerError:
    static compile:
        r = store(raise_e2)         # erases E2 (store's parameter is untyped)
        fn want(x: int) -> int:
            x
        want("s")                   # TYPE: the block is rejected
```

Written in this order, `consumer` used to be rejected (UNHANDLED-ERROR: E2)
and `eraser` then rejected too, leaving a program that erases nothing;
written the other way round, `consumer` was accepted.

The rule: a failing block *waits* while another failing block contributes
to a channel it consumes. The order rejects the first failing block in
post-order that does not wait, so the contributors are judged first and
the consumer against the channel their decisions leave -- here `eraser` is
rejected first and `consumer` accepted, in either order. The consumers and
contributors come from the dependency analysis
([below](#the-dependency-graph); `hir::staticdeps::Waiting`): a block
consumes a channel its node reaches over the edges that read something --
not a contributor's link to a channel, which only orders, nor an edge to a
gate (below) -- except that a block whose first diagnostic was reported
before the completion walk does not consume the erased-callable contract
(nothing before the walk reads it but the ownership analysis's exit
releases, which report nothing, so no erasure can cause or precede that
diagnostic). The contributors are every block holding a contribution and
every block whose form the channel's node reaches. Three further points
complete it:

* an *ok* contributor does not make a consumer wait: its body is in the
  final program unless a later decision makes it fail;
* a block that waits stays undecided, and the blocks before the rejected one
  that have no diagnostic are accepted as before;
* when every failing block waits -- each on another: a *cycle* through a
  channel, every one consuming what another contributes -- the first one in
  post-order is rejected, as before the rule. With one failing block
  nothing waits.

Two cases are left to layout, and pinned as such. A *cycle*: two blocks that
both erase and both call through an uncontracted value
(`se-equal-channel-cycle`), every call of an instance budget under pressure
(first-come first-served), or two blocks the conservative analysis cannot
tell apart from such. And an ok contributor that a later rejection makes
fail -- an erasing block whose nested block is rejected with a
`CompilerError` the function around it does not admit
(`se-equal-consumer-waits-residual`): a consumer written before it is judged
while its erasure stands. Closing the contributors under what their
diagnostics read would cover the second, and made ordinary failures that a
contributor's code reads wait for each other, one build each
(STATIC-DECISION-ECONOMICS.md, "The waiting rule").

Not every channel has this shape. A *gate* -- a diagnostic that exists only
while no other block has one: the ownership analysis's whole-program
verdict (`C:verdict`) and the trait plan's gate (`C:plan`) -- cannot fail a
consumer while a contributor still fails, so it cannot cause this layout
dependence, and no block waits on one. (Read as a waiting channel, the plan's
gate would make every failing block holding a trait call wait for the last
failing block of the program: one rejection per build.)

### The theorem

A build is a pure function of the forms of the static sites. A site's own
diagnostics -- the only thing the order reads -- are a function of the
facts its analysis reads, and those are a function of the forms of the sites
its analysis can see: the sites it *depends on*. So, having rejected site
Z on one build, every site that does not depend on Z has the diagnostics it
would have in the next build, and the next sequential step can be read off
the same build -- unless the site it needs depends on something rejected
since.

The batched scheduler (`hir::static::Simulate`) groups the sites into
*components* -- sites linked, directly or through others, by a dependency
in either direction -- and takes each component's sequential step on its
own: reject the component's first *failing* site in post-order that does
not wait (accepting the undecided *ok* sites of the component before it),
or, when every failing site of the component waits, its first failing site;
mark every site depending on it *unknown*; stop the component at its first
*unknown* site, and at a failing site that may or may not wait (a
contributor to its channel is unknown). A failing consumer is linked to
every contributor it may wait on (`Components`: it need not read their
forms -- the erased contract reads its witnesses' only), so the rule is the
component's own. No decision in one component can change a status in another, so the
sequential order of the whole program is an interleaving of the components'
own orders: the run commits exactly the rejections the sequential order
commits, with the same diagnostics, and a component builds again only
where one of its decisions changed a fact another of its sites reads. A
*stable decision* is one of these: the component's next decision by the
rule, in a build in which nothing it depends on differs from the sequential
order's build of that step.

Each build checks the previous run's predictions (every site whose status
it still knew must show the same status and, ids blanked, the same first
diagnostic); a contradiction would mean the dependency analysis missed a
channel, and is recorded (`mispredicted`) for the audits and tests, which
fail on it.

Resolution and loader rejections were decided together before this
milestone and still are (resolution is lexical). Acceptances follow the
rejections: a site is accepted when its component's sequential step passes
it, and the round in which no site fails accepts the rest and is the final
program.

Two details keep the diagnostics exact:

* **Nested sites.** An outer site depends on every site nested in its body
  (its body contains their forms): a nested site is decided before the one
  around it, and the outer one is judged again once an inner one is
  rejected -- by then its first diagnostic may be the inner site's
  unadmitted `CompilerError`. A rejected outer site takes the sites nested
  in it with it (they are accepted, inside a body no build keeps).
* **Internal ids.** A message that names internal ids (`block(e12)`, or
  `function e12` for a function without a name -- the only two forms in
  which a diagnostic prints one; a word that merely looks like an id, a
  binding written `s1`, is no id) carries
  the numbering of the build it came from, which the forms of the sites
  numbered before them decide. Such a rejection is committed from a build
  only when no site before its ids differs between that build and the
  sequential order's; otherwise its component waits for a build (the trace
  says so). Predictions compare messages with the ids blanked. Where a
  message can name a callable by its source it does (`two/2 -> bool`,
  `hir::semantic::NameCallables`), and a binding hygiene renamed
  (`NAME#N`, numbered across the whole program, so by sites after it as
  well) is printed as written in every message: a binding by
  `hir::semantic::SourceName` (a module's own definition `NS::NAME`), a
  reference or a binding statement by `hir::semantic::RefName`, a function
  by `hir::semantic::CallableName` (`se-equal-hygiene-*`;
  STATIC-DECISION-ECONOMICS.md, "Callables and bindings named by their
  source").

### The dependency graph

`hir/staticdeps.tcl` computes, from one build, which sites each site's
diagnostics may depend on: a conservative graph whose nodes are regions
(a function literal, or a program's top-level code), bindings, sites and
program-wide channels, an edge saying "may read a fact of". A missed
dependency would make the batched scheduler decide another program; an
extra one only costs a build. Its header lists every edge; in short:

* a site depends on the region its body stands in (its *position*: a
  rejection can make the code after it unreachable, where completion and
  ownership diagnostics are not reported), on the sites nested in it, and
  on its own contract-boundary checks -- and only on what its diagnostics
  read: a site is two nodes, what its diagnostics read and its *form*
  (whether it is still a body, which only its own rejection changes), and
  whatever reads a site's code depends on its form alone. (One node once
  stood for both: a site nested in a function in another site's body
  reached that site's form through the `if true:` scoping it, and through
  it every sibling nested site -- one rejection per build;
  `se-builds-nested-siblings`);
* a region depends on everything its own code mentions -- bindings, the
  functions it defines and calls (their summaries), every candidate of a
  method-style call and what its trial builds judge of the contract
  boundary, its parameters and captures, the control operands
  around its literal, and the narrowings of each captured binding between
  its definition and the region -- but *not* on the rest of the function
  around it: a function is analyzed from its own entry, and sees of the
  enclosing code exactly its captures (`se-property-nested-entry`,
  `se-property-capture-narrowing`). That is why bodies nested in one
  registration function are as independent as top-level ones;
* a binding depends on its definition and on every narrowing mention of it
  in its own region (a condition, a native's parameter types, a mutation:
  a nested function may not capture a vector its function mutates) -- every
  mention, not only the last, which is all an earlier version kept
  (`se-equal-every-mention`);
* the backward channels: an untyped parameter's contract (inferred from its
  uses in the function and the functions nested in it), a shared affine or
  mutable binding (every region mentioning it; a binding holding a function
  is none, whatever the function's contract mentions: a function value has
  no place to mutate and is never moved, and the vector its call returns is
  a new value owned by the binding receiving it), a yielding function's
  yield type (the struct-protocol coroutine constructions that reach it);
* the program-wide channels, modelled as nodes with contributors and
  consumers rather than as a stop sign (which the waiting rule reads too,
  [above](#the-waiting-rule)):
  * **the erased-callable contract** (`hir::completions::erasedErrorsOf`),
    a set of errors. Its *contributors* are the semantic-instance requests
    whose arguments at parameters with no declared or trusted contract
    carry errors (a callable, or a value holding one), by the chain of
    requests keeping the instance and those arguments -- of one naming a
    function, its place only: what a function carries is its declared
    errors, never its body; the positions where a callable with an
    uncontracted parameter acquires a structural type (contravariant
    erasure); and the requests the budget declined. A request that erases
    nothing never will (a rejection only turns a type into `never`) and is
    none. The contract depends, per error, on one *witness* -- the
    contribution last in post-order -- since another contributor's
    rejection leaves the set as it is (`se-equal-erased-witness`,
    `se-builds-erased-empty`); the sites holding a contribution are the
    waiting rule's contributors ([above](#the-waiting-rule)), no edge of
    the graph (they used to be linked to the contract, which the rule made
    redundant). Its *consumers* are the
    regions that call through an uncontracted value -- a callee typed `any`
    or a bare kind, a native calling such an argument -- whose identity and
    contract are both lost. A call through a verified structural `Fn` or
    `Coroutine` contract is *not* a consumer
    (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md: the contract bounds it whatever
    it holds), so callback registries, struct fields and vector elements of
    `Fn{...}` type serialize nothing (`se-builds-contract`). A coroutine
    erases through the same channel (its construction is a call of a root
    native with the callable as an argument) and its yield type is the
    separate yield edge above;
  * **the semantic-instance budget** of a function: open only under
    pressure (a request declined, or half the per-block budget used), and
    then every call of the function is both contributor and consumer --
    every function's at once when half of all instances exist, or a request
    was made at half the nesting limits or deeper: only a first request is
    declined for nesting, and rejecting the site that made the first request
    for an instance can make a deep one the first, which a cache hit hid
    before (`se-equal-deep-first-request`);
  * **the ownership verdict** (`hir::affine::verify`'s `accepted`): release
    scopes, and with them `AFFINE-PATH-RELEASE-UNSUPPORTED`, are computed
    only while the ownership analysis finds nothing anywhere in the
    program, so a site that moves a binding on a loop's break path or in a
    handler has that diagnostic only once every site with an ownership
    diagnostic is rejected. Its *consumers* are the sites holding such a
    join; while the analysis reports something, the verdict depends on one
    *witness* (the diagnostic whose site is last in post-order, or every
    one outside a site: the verdict cannot change while one stays), and
    every site holding one after the first consumer is linked to it, so a
    consumer whose status becomes unknown holds back what the sequential
    order still sees when it judges it. One consumer ahead of six
    rejections takes 3 builds, not 8 (`se-builds-ownership-verdict`). While
    the analysis accepts the program, the verdict depends on the regions
    passing an affine argument whose contract can widen (an untyped
    parameter, a callable value): a rejection only kills paths and narrows
    types, so no other diagnostic can appear. A later finding of the golden
    migration (`mutable-vector.bot` mispredicted; a variant decided another
    program: `se-equal-ownership-verdict`);
  * **the contract-boundary checks** (`hir::completions::Subsume` with
    `Possible`), which run only in a body's own diagnosing walk while the
    program erases something: a site-local channel, from the site to the
    erased contract and to the inputs of the callables at its positions --
    what an input may hold being, like the contract, a set (of errors, and
    whether every value is quiet), with one witness value per part
    (`se-builds-possible-witness`). None while the site fails with a first
    diagnostic reported before the completion walk, which every report
    follows (`se-builds-subsume-gate`). Besides the site's own diagnostics,
    only a method-style call's trial builds read a report: the checks at the
    call's own arguments, which the candidates' parameter types decide, so
    the call's region depends on them (`se-equal-method-trial`);
  * **the gate of the trait monomorphization's plan** (`hir::traits::Plan`),
    which `hir::BuildFull` runs only on a checked program with no
    diagnostic at all, and whose diagnostics (TRAIT-IMPL-ORDER,
    AFFINE-GENERIC-NESTED-UNSUPPORTED, TRAIT-INSTANCE-BUDGET, ...) are a
    site's. Its *consumers* are the sites holding a call the plan can
    report at and no diagnostic of their own -- a trait operation, an
    argument that is or may become affine at an untyped parameter, and a
    call of a trait-polymorphic function only where a context the plan
    walks has no instance for it (`se-builds-plan-instances`,
    `se-equal-plan-unplanned`); while some diagnostic it
    does not report stays, it depends on one witness (the site of the last
    in post-order: the gate cannot open while it stays); while every
    diagnostic may be its own, on every site holding one, decided one per
    build as the sequential order decides them -- a rejection can close the
    gate again, by a diagnostic it causes in no site, after which the
    sequential order accepts the next plan site (`se-equal-plan-reclosed`).
    It used to be missing: `traits.bot` and `affinity.bot` recorded
    mispredictions (`se-equal-plan-gate`, `se-builds-plan-gate`,
    `se-equal-plan-clone`).

Not channels: a demoted trusted contract (`hir::check` keeps the
diagnostics of the check before the demotion,
`se-property-demotion-keeps-diagnostics`), the trait monomorphization's
build after its plan (it runs only on a program with no diagnostic, and its
own are internal), and resolution (lexical).

### Method-style call decisions across rounds

A round's method-style calls with several candidates are decided by trial
builds of the candidates (METHOD-SUGAR.md), and each round used to decide
every one of them again. Now a round takes the previous round's decisions
as made (`hir::static::MethodSeeds`, `hir::BuildFull`'s seeds) except for
the calls that must be decided again: those not decided there, those whose
region reaches a site rejected since (its receiver, arguments or
candidates may differ), and every call such a call reaches (the trials
pair a call's candidates with those of the calls it depends on). A seed is
keyed by the call's identity (`methodCalls`: its file and syntax node, the
same in every build of the compilation), never by its name, and is used only
when the call still exists with that candidate among its candidates. A build whose choices resolve every call as an
earlier build of the decision did is that build (`hir::MethodConfig`): not
made again, so a round with nothing to decide costs one build, not two
(STATIC-DECISION-ECONOMICS.md, "Within one decision"). The seeds live in
`decide`'s loop, for one round: nothing persists across compilations
(`se-deterministic`). `hir::static::methodAudit` builds every seeded round
a second time unseeded and fails unless the two programs are identical
(`se-method-reuse`); `se-method-invalidated` pins a call decided again
because a rejection changed its receiver.

### The transaction model

Unchanged: every build is a fresh, pure value, and nothing a body did
survives a build that is not kept. A batched run reads diagnostics of one
build for several decisions, but never continues *through* an invalid
state: each committed decision is one the sequential order makes, on
diagnostics the batched build shares with the sequential order's build of
that step. The final program is an ordinary `hir::BuildFull` of the
decided syntax -- the round in which no site fails -- with its own
diagnostics and warnings, exactly as before.

### Complexity

* independent sites: a constant number of builds -- one per semantic
  stage that rejects something (resolution, then the checks) plus the
  final one, however many sites and however they are laid out (100 nested
  TYPE rejections: 2 builds, as for the same bodies at the top level);
* dependent sites: one build per level of genuine dependency (a chain of
  K nested blocks each rejecting the one around it takes K + 1 builds, as
  it must: each level's diagnostic is only known once the one inside it is
  decided);
* program-wide channels: a contributor and its consumers form one
  component, decided contributors first (the waiting rule), so the builds
  grow with the number of *strata* -- consumers judged after a
  contributor's rejection -- not with the number of sites beside them.

The dependency analysis is one walk of the build plus a strongly-connected
-components pass, a few percent of a build.

### What the legacy scheduler did

One rejection per typed round -- the first failing site in post-order --
plus every other failing site in a *different top-level unit* (a top-level
function with everything nested in it, or a section's top-level code) that
neither reaches the other by reference; and no second rejection at all while
`hir::static::GlobalChannels` held (a demoted trusted contract, or any
erased-callable contract in the program). So independent failures nested in
one function -- the golden framework's registration function -- were
decided one build each, and one accepted erasing body anywhere serialized
every rejection of the program. It is kept (`Rejectable`, `Independent`,
`Units`, `GlobalChannels`) only as the legacy scheduler, which takes its
first rejection by the waiting rule like the others (and only that one while
a block waits), so that it decides the same program.

## Report

### 1. Exact grammar

`staticIntrinsic = "static" IDENT ":" suite`, in statement position and as
the value of a binding, `return` or destructuring (`surface/parser.tcl`'s
grammar header; `AtStatic`, `StaticIntrinsic`, `ValueOrHandled`). The suite
is the ordinary one: `static compile:`, a new line, an indented block.
Never an operand or an argument (`x = 1 + static compile:` and `f(static
compile: ...)` are syntax errors, `sc-grammar-not-an-expression`).

### 2. Contextual-keyword behavior

Neither word is a lexer keyword. `static NAME` -- two adjacent names, never a
valid expression -- at a statement start or a statement's value starts the
form; everything else is an ordinary name (`sc-grammar-contextual`: a
function named `compile`, a binding `static`, parameters and fields named
`static` and `compile`, and a `static compile:` among them). The operation
is compiler vocabulary: a program-bound `compile` does not change it, and
`static unknown:` is `STATIC-UNKNOWN-OPERATION` even when the program
defines `unknown` (`sc-grammar-unknown-operation`). Malformed forms are
`STATIC-INTRINSIC-FORM` (arguments, no colon, a body on the colon's line,
`static:`), a missing block is the ordinary suite error
(`sc-grammar-malformed`).

### 3. AST representation

`static` node: `operation`, `operationSpan`, `staticSpan`, `body` (a
suite) -- a static intrinsic, not an assertion node. A future `static parse:`
is one more word in `staticOperations` and one more meaning in
`hir/static.tcl`, never a new node kind. Its syntax node (`hir/syntax.tcl`'s
`staticNode`): `operation`, `operationOrigin`, `bodyOrigin`, `body` (syntax
nodes), `deferred` (loader diagnostics).

### 4. Phase

After parsing and loading, before resolution: `hir::buildSyntax` hands a
program with static nodes to `hir::static::decide`, whose rounds each expand
the syntax and run the whole ordinary build (`hir::BuildFull`). Before any
backend: the decided program is ordinary HIR.

### 5. How the outer traversal skips the body

No pass ever sees a static node: `hir::static::Expand` replaces each one by
its form before resolution, every round. An undecided block's body is
resolved in its trial build, but the diagnostics it gets there are recorded
data, attributed to it, never raised; a rejected block's body is not in the
next build at all. The loader, which runs before HIR exists, defers its
diagnostics for references in static blocks (step 1 above).

### 6. Lexical and module environment

The body is expanded where it is written, so it is resolved in its own
lexical scope chain, its file's namespace and imports, with no copy or
re-parse (`sc-positive-lexical`: a parameter, its declared type, an earlier
function, an imported namespace).

### 7. Facts that cross into the body

All of them: the body is compiled by the one compiler in the program it
stands in -- types, ranges, refinements (`sc-tx-refinement`: a validator's
fact), ownership state, contexts, method candidates, semantic instances,
callable contracts. Nothing is erased at the boundary.

### 8. Transaction / rollback mechanism

A build is a pure value; a decision keeps the build's verdict and discards
the build. Persistent state was audited: the registries a build fills
(`hir::structs`, `hir::enums`, `hir::errordecls`, `hir::traits`,
`hir::imports`, `hir::sourcetypes`) are reset and refilled from the same
top-level declarations by every build; the per-pass caches
(`hir::completions::cache`, `hir::contexts::traitCache`, `hir::semantic`'s
and `hir::affine`'s working state, `hir::mutvec`'s per-pass tables) are reset
by the pass that uses them; `surface::modules::parsed` is keyed by a file's
text (pure); the native lowering's caches live past the HIR. Nothing persists
from one round's body to the next round.

### 9. Bindings and declarations

A rejected body's bindings and functions do not exist after it: the outer
scope may bind the same names (`sc-tx-binding-no-export`), a function it
declared is neither a binding nor a method-call candidate (`sc-tx-callable`:
`twice(1)` is UNBOUND, `3.twice()` finds no candidate). An accepted body's
bindings are scoped to its block, as an `if true:` block's
(`sc-tx-scope`). A static block cannot declare a type, struct, enum, error or
trait (declarations are top-level only: a parse error, as in any block,
`sc-grammar-body-parse-error`), so no declaration registry is involved.

### 10. Affine rollback

A rejected block that moved an outer coroutine leaves it unmoved: the code
after it resumes it, at compile time and at run time (`sc-affine-rollback`:
`[5, -2]` -- 5 from the handle used after the skipped block, -2 from the
block's UseAfterMove); a later block that uses the value is judged after the
earlier block's rejection and accepted (`sc-affine-rollback-next-block`);
an accepted block's move is the ordinary block's (`sc-affine-accepted-moves`:
the outer use after it is USE-AFTER-MOVE).

### 11. Refinement and context rollback

A validator's refinement made inside a rejected block does not reach the
code after it (`need(n)` is TYPE), while an accepted block's does, exactly
as an `if true:` block's (`sc-tx-refinement`). A `with context` inside a block
is the nested-scope installation it is in any block
(CONTEXT-INSTALLATION-UNSUPPORTED, reified), and the rest of the program
does not see an installation (`sc-tx-context`: MISSING-CONTEXT). A semantic
instance created only by a rejected body is not in the program, one created
by an accepted body is (`sc-tx-instance`: `int` against `int str`). A nested
callable: item 9.

### 12. Caches and specialization

Item 8's audit: every cache that may hold an entry created during a trial
build is per build or per pass, or keyed by pure inputs; the specializer and
the native lowering run only on the final HIR. `sc-tx-deterministic`: a
block's decision is the same alone and after four rejected blocks that each
moved and failed.

### 13. Successful lowering

An accepted block is ordinary syntax with no static node or mark: the body
spliced in place (it binds nothing in its own scope), or `if ^true {BODY}
{}` (it does). HIR, Core IR and NIR equal the unwrapped body's, or the `if
true:` block's (`sc-hir-accepted-ordinary`, `sc-core-ir`,
`sc-nir-accepted-identical`). Natively the `if` on the root `true` emits no
branch and no constant (`native::lower::PureDecidedCondition` now counts a
root Boolean reference as a pure decided condition).

### 14. Failed lowering

`fail std::compiler::CompilerError {code: <enum const>, primary:
std::compiler::SourceLocation {...}, related: [...], message: "..."}`: an ordinary
`fail` of an ordinary payload error, the payload an ordinary anonymous struct
construction (`struct payload(std::compiler::CompilerError)` in HIR text), its
location values ordinary named constructions, its code an enum constant
(`sc-hir-rejected`). Core IR `(fail std::compiler::CompilerError (struct ...))`,
NIR `faildeclared ID "std::compiler::CompilerError" SHAPE fields...`
(`sc-nir-rejected-payload-slots`). None of the body survives
(`sc-hir-rejected`: no reference to the function the body called).

### 15. Result-value preservation

An accepted block's value is its body's, in every accepted position
(`sc-success-value`: `x = static compile: 20 + 22` is 42, a multi-statement
body, `return static compile:`, a destructuring).

### 16. Run-time error preservation

An accepted body's run-time errors are its own: IndexNotFound
(`sc-success-runtime-error`), a declared application error with its
payload (`sc-success-declared-error`). (A native's argument statically of
another kind was a run-time TYPE here, `sc-native-type-error-is-runtime`,
until METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md made it the call's
compile-time TYPE: such a block is now rejected,
`sc-native-type-error-is-static`.)

### 17. CompilerError contract

A rejected block's error is ordinary: the enclosing function handles or
declares it, or the program is rejected with UNHANDLED-ERROR at the block
(worded for the case: "this \"static compile:\" block's body was rejected
(UNBOUND), so the block completes with the error ..."), a top-level block
likewise (a program's top level admits no error) (`sc-contract-admitted`);
its callers handle it (`sc-contract-unhandled-call`). An accepted block
contributes no CompilerError (`sc-contract-accepted-none`). The staging makes
the three states of item 61 exact: a decided block is either its body (no
CompilerError) or the failure (CompilerError is its completion); the
undecided state exists only inside the rounds, where the enclosing program's
diagnostics are not consulted.

### 18. KNOWN-ERROR

The narrowest rule (`hir/completions.tcl`): a path ending in a reified
failure sets the walk's `intended` flag, and `analyzeBlock` counts such a
path as one that may complete normally -- so a call of a function whose
block was rejected is never KNOWN-ERROR. The error is charged like any other.
An ordinary `fail`, or a call proven to fail on its own, still makes its
callers KNOWN-ERROR, including when it comes before a rejected block
(`sc-known-error-exempt`); a KNOWN-ERROR inside a body is the body's
rejection with code KnownError (`sc-negative-known-error`).

### 19. Warnings

Warnings run on the final program only, as on any program: a warning in an
accepted body is reported at its own location and the body runs
(`sc-warnings-visible`); a warning never rejects a block, and under
`-warnings error` it fails the whole compilation -- the global policy -- with
its own code, never as CompilerError (`sc-warnings-not-rejection`). A
rejected body's warnings are gone with it. The warning gate is unaffected (no
corpus program uses `static compile:`).

### 20. Misuse diagnostics

`STATIC-UNKNOWN-OPERATION` (an operation outside the vocabulary, never an
UNBOUND), `STATIC-INTRINSIC-FORM` (arguments, no colon, a one-line body, no
operation), the ordinary suite error (no block), `MISSING-IMPORT` (no
`import std::compiler`, `sc-import-required`).

### 21. std::compiler::DiagnosticCode

87 cases, one per recoverable kind (the census below), in `stdlib/compiler.bot`.

### 22. Census

[Diagnostic-code census](#diagnostic-code-census).

### 23. Mapping / exhaustiveness

`hir::static::codes` is the explicit table; `sc-codes-one-to-one` holds it
one-to-one against the enum and to the spelling rule; `sc-census-exhaustive`
fails on any upper-case kind token in `hir/*.tcl` or `surface/modules.tcl`
that is neither a code nor classified as never recoverable (with a reason),
and on any code no compiler source names. A kind with no case reaching the
bridge is an internal compiler failure, never a default case
(`sc-unmapped-kind-internal`).

### 24-25. SourceLocation, CompilerError

As declared above, ordinary namespaced declarations named qualified after
`import std::compiler`; a bare `CompilerError` or `DiagnosticCode` is unknown
(`sc-names-qualified`).

### 26. Host-to-Botlish conversion

`hir::static::Reified`: kind -> enum constant (`CodeOf`), primary origin ->
`SourceLocation` construction (`Location`: the origin's line and column),
related origins -> a List literal of constructions, message -> a String
constant; the whole the payload construction of an ordinary `fail`. The
result enters the ordinary error machinery: no exception object, no
diagnostic object at run time.

### 27. Primary-diagnostic selection

The first of the block's own diagnostics in the build's diagnostic list --
the one a strict compile of the same code raises first (it raises every
independent one, the first first: DIAGNOSTIC-RECOVERY.md): resolution
diagnostics (the decision rounds stop after them) before check diagnostics,
then the passes' order, with the frontend's own promotions (opacity, trait
diagnostics, method-call decisions prepended). A CompilerError stays one
diagnostic: only a block's first is the same whatever build rejects it
(STATIC-DECISION-ECONOMICS.md), so a list would let the scheduler decide an
outcome. `sc-primary-selection`: an
UNBOUND after a TYPE error is reified (resolution first); of two UNBOUNDs
the first in source order.

### 28. Source-span preservation

The body is never re-parsed or re-located: its nodes carry their original
spans, and `primary` is the diagnostic's own line and column in the file
(`sc-location-original-span`: line 11, column 14, after blank lines and a
statement inside the block).

### 29. Related locations

From the diagnostic's structured `related` origins (new: `hir::Diagnose`
takes them; `USE-AFTER-MOVE` and `AFFINE-NOT-DEFINITELY-LIVE` record the
moves their messages name, `hir::affine::MoveOrigin`), in message order;
`[]` otherwise -- never synthesized (`sc-affine-use-after-move`).

### 30. Message preservation

The diagnostic's own message, without the `FILE:LINE:COLUMN: ` prefix the
frontend adds when raising it; equal to the ordinary compilation's
(`sc-diag-exact-*`).

### 31. Internal-failure boundary

Never caught: a Tcl error during a round propagates and fails the
compilation (`sc-internal-failure-propagates`, with a simulated compiler bug
the body's code provokes); a diagnostic marked `internal` (a
monomorphized-program diagnostic) or of an `*-INTERNAL` kind is never a
block's (`sc-internal-diagnostic-not-reified`); an unmapped kind is an
internal error.

### 32. Backend-error boundary

Static decisions finish before any backend runs, on HIR; a backend error
(`NATIVE UNSUPPORTED`, `NATIVE BUG`, ...) happens later, on the decided
program, and is never reified. No backend diagnostic is part of Botlish's
source compilation contract.

### 33. Namespaced errors

`a::Failed` handled as `b::Failed` inside a block is UnhandledError whose
message names the canonical `a::Failed`, exactly as ordinary compilation
says it (`sc-namespaced-errors`).

### 34. Opaque structs

An outside construction of `token::Token` inside a block is code
OpaqueConstruction, an outside projection OpaqueRepresentation; the
module's own operations are accepted (`sc-opaque`).

### 35. Higher-order completion

The erased-callable reproducer (E1 escaping `generic` through an untyped
`call`, a handler for E2 only) inside a block is UnhandledError
(`sc-negative-unhandled-erased`, `sc-diag-exact-erased-unhandled`): the
block runs the real completion analysis, fallback included.

### 36. Affine diagnostic

`sc-affine-use-after-move`: UseAfterMove at the second use, the first use
its related location, on every backend.

### 37. Successful run-time error

Item 16.

### 38. Successful value

Item 15.

### 39. Independent failed blocks

`sc-independent-sites`: accepted, rejected (UNBOUND), accepted, rejected
(TYPE), accepted -- all in the program, each with its own outcome:
`[1, -11, 2, -19, 3]`. `sc-rounds`: a program whose blocks are all accepted
takes one build, twelve blocks of which eight are rejected take three.

### 40. Nested static compile

Each level is its own boundary: an inner rejection is an ordinary
CompilerError completion of the outer body, which the outer compiles
(`sc-nested`); an outer body that cannot admit it is rejected in turn,
UnhandledError at the inner block (`sc-nested-outer-rejects`).

### 41. HIR evidence

Before: the AST `static compile <static>` node and the `static` syntax
node (`sc-before-hir`, `sc-grammar-ast`). After, accepted: the unwrapped
body's HIR text (`sc-hir-accepted-ordinary`). After, rejected (a program
whose block calls `side_effect()` and then names `missing`; nothing of the
body is left):

```
e4 bind b2 f : block(e5)/0 -> never
    e5 block s5 () captures () errors std::compiler::CompilerError : block(e5)/0 -> never
        e6 fail std::compiler::CompilerError static=compile:UNBOUND : never
            e7 struct payload(std::compiler::CompilerError) (code, primary, related, message) : struct{code: std::compiler::DiagnosticCode, message: str, primary: std::compiler::SourceLocation, related: List[std::compiler::SourceLocation]}
                e8 const enum {std::compiler::DiagnosticCode Unbound} : std::compiler::DiagnosticCode
                e9 struct std::compiler::SourceLocation (line, column) : std::compiler::SourceLocation
                    e10 const 9 : int
                    e11 const 9 : int
                e12 call native(list) : List[never]
                    e13 ref b3 list : native list
                e14 const str {unbound name "missing"} : str
```

`hir::format` prints the mark as `static=OPERATION:KIND`; `hir::parse` reads
it back (`sc-hir-text-round-trip`).

### 42. Core IR evidence

Accepted: the unwrapped program's Core IR, element for element (`sc-core-ir`).
Rejected, the same program:

```
{bind f {block {} {fail std::compiler::CompilerError {struct {} code {const enum {std::compiler::DiagnosticCode Unbound}} primary {struct {std::compiler::SourceLocation line column} line {const 9} column {const 9}} related {call {ref list}} message {const str {unbound name "missing"}}}}}}
```

an ordinary `fail` of a payload construction; no static form, no compiler
call.

### 43-44. Tcl interpreter and Tcl compiler

They run that Core IR: the accepted body as written (the Tcl compiler folds
an `if` on the root `true` away: its procedure equals the unwrapped one's
but for temporary numbering), the rejected block as an ordinary payload
failure. Every executable test runs on both (`sourceAgree`).

### 45. Native NIR

Accepted: byte-identical to the unwrapped body's (or the `if true:`
block's), no branch, no `bool true` (`sc-nir-accepted-identical`).
Rejected: one `faildeclared ... "std::compiler::CompilerError"` with the payload's
fields in the payload slots (`sc-nir-rejected-payload-slots`); no new NIR
instruction exists for static compile.

### 46. Successful-path allocation / codegen

Zero allocations, the same report as the unwrapped body
(`sc-alloc-accepted-zero`); NIR byte-identical (item 45), so the machine
code is.

### 47. Failed-path allocation

Natively each failure allocates what its payload's fields hold: the
`primary` SourceLocation struct (48 bytes) and the `related` List (24 bytes
when empty) -- 2 allocations, 72 bytes, exactly what the same
`fail std::compiler::CompilerError {...}` written by hand allocates
(Performance below). The message is a String constant, allocated once with
the program's static data, never per failure; the code is an enum word. A
handler that binds the payload whole materializes the anonymous payload
struct, one allocation more (`sc-alloc-rejected`: 3 whole, 2 reading
fields). The payload travels field-wise in the payload slots, never boxed.
Nothing is allocated on a path where the block does not fail.

### 48. Differential valid-body tests

The fuzzer's plain-program check (item 50 below) on every program, and the
HIR/Core IR/NIR identity tests.

### 49. Differential invalid-body diagnostic tests

`sc-diag-exact-*` (15 kinds: unbound, unbound-later, type, result-type,
unknown-field, duplicate, break-outside, unhandled-fail, undeclared-error,
flag-unknown, use-after-move, erased-unhandled, missing-import,
unknown-namespace, not-an-enum): the ordinary compiler's first diagnostic
inside the block written as `if true:` (kind, line, column, related,
message) equals both the diagnostic the site recorded and the
`std::compiler::CompilerError` the block fails with on every backend -- code,
primary, related and message as a handler reads them, the code's case
spelled by the test itself (`scPayloadOf`), never asked of
`hir::static::codes`. The fuzzer does the same for every fault: its model
predicts kind, line and column, and its program's `code_number` names each
case literally.

### 50. Fuzz results

`audit/static-compile/tools/fuzz.tcl` (its header has the design):
a model-based generator: each program has 3..8 sites, a function per
site whose body is one `static compile:` block (its last statement, or one
time in three the value of a binding it returns), each block a valid
fragment or a deliberate fault, and a driver per site that calls it under
handlers for `std::compiler::CompilerError` and the program's application
errors. The model shares nothing with the compiler: it predicts a valid
fragment's value or application error and a fault's kind, line and column,
and every backend (interp, compile, Cranelift) must produce exactly that.
Beside the model, every program is checked twice more: its valid sites
written as ordinary `if true:` blocks must give the same values
(transparency), and every rejected site's recorded diagnostic must equal
the ordinary compiler's first diagnostic in that block (exact diagnostics).

Final campaign (seeds 1, 41 and 81, 40 programs each, and seed 121, 20
programs, with `-gc-stress 1`):

| | |
|---|---|
| programs | 140 |
| sites | 747 |
| accepted | 459 (23 of them holding a rejected nested block) |
| rejected | 288: TYPE 54, UNHANDLED-ERROR 50, UNBOUND 46, DUPLICATE 27, MISSING-IMPORT 26, OPAQUE-CONSTRUCTION 26, KNOWN-ERROR 22, USE-AFTER-MOVE 20, UNKNOWN-FIELD 17 |
| transparent valid sites | 459 |
| exact diagnostics | 288 |
| decision builds | 345 (2.5 per program) |
| disagreements | **0** |

The first campaign's two disagreements were the model's: it placed a
nested function's result TYPE one column early (the compiler reports a
function's result at the `(` of its literal, as for every function). The
model was corrected; the compiler was right. The mutation campaign then
showed the generator's one blind spot -- a rejected nested block whose
failure escapes looks the same whichever block owns the diagnostic -- so a
fragment now nests a rejected block on a branch that never runs, which only
the innermost owner lets the outer block survive (`outermost-owner` is now
killed by the fuzzer too).

### 51. Mutation results

`audit/static-compile/tools/mutate.tcl`, the 21 mutants of `mutants.txt`:
the 17 of item 82's list, one each, plus `loader-error-escapes` (the
loader's half of "escapes as a fatal outer diagnostic"), `outermost-owner`,
`internal-diagnostic-reified` (the diagnostic half of "internal failure
becomes CompilerError") and `same-failure-counts-reified`. Item 82's "leaks
a type/error declaration" is `leaks-declaration`: the only declaration a
block can hold is a function's, since `struct`, `error`, `enum`, `type` and
`trait` are top-level syntax, a parse error inside any block.

**21 mutants, 21 killed, 0 survived** (final tree; each mutant against
`tests/static-compile.test` and 12 fuzz programs, seed 3). The detectors
that caught each:

| mutant | tests failing | fuzz |
|---|---|---|
| `body-resolved-normally` | 60 | 12 of 12 programs disagree |
| `error-escapes-fatal` | 50 | 12 of 12 |
| `loader-error-escapes` | 3 | -- |
| `wrong-code` | 27 | 11 of 12 |
| `loses-primary` | 27 | 11 of 12 |
| `loses-related` | 3 | -- |
| `string-not-error` | 44 | 11 of 12 |
| `success-returns-unit` | 25 | 12 of 12 |
| `runtime-errors-wrapped` | 4 | 7 of 12 |
| `keeps-runtime-wrapper` | 14 | 8 of 12 |
| `executes-prefix` | 13 | 5 of 12 |
| `leaks-binding` | 3 | 8 of 12 |
| `leaks-declaration` | 4 | -- |
| `leaks-affine-move` | 1 | -- |
| `outermost-owner` | 2 | 3 of 12 |
| `known-error-rejects-reified` | 34 | 11 of 12 |
| `known-error-disabled` | 2 | 1 of 12 |
| `warning-becomes-error` | 9 | 10 of 12 |
| `internal-becomes-compiler-error` | 1 | -- |
| `internal-diagnostic-reified` | 1 | -- |
| `same-failure-counts-reified` | 1 | -- |

The fuzzer misses what its generator never builds: loader faults are 1 in
13 fault fragments (12 programs may hold none), its model encodes no
related locations, no fragment declares a function a later block could
call, no two failing blocks share an affine value, and nothing in it fails
inside the compiler. Each of those has its own test. The first campaign
killed 20 of 21: `same-failure-counts-reified` survived, because the rule
it breaks is also implied end to end by SAME-FAILURE's conservative payload
rule (item 59); `sc-same-failure-sites` now pins the rule where the warning
reads it.

### 52. Full regression

The whole suite (`tests/all.tcl`, 165 files, each run with a private
`-tmpdir`) on the final tree, with every brief-named area in it (errors,
error-payloads, namespaced-errors, higher-order-completions, affine,
coroutines, opaque-struct, contexts, traits, refinements, struct
destructuring, method sugar, imports, semantic instances, HIR round trips,
the warning gate):

| backend | total | passed | skipped | failed |
|---|---|---|---|---|
| `CORE_BACKEND=interp` | 7120 | 7120 | 0 | 0 |
| `CORE_BACKEND=compile` | 7120 | 7116 | 4 | 0 |

(The four skips are the suite's `coreScoping` constraint on the Tcl
compiler, as before this milestone.) The warning gate
(`audit/refactor/tools/gate.tcl`) passes with `stdlib/compiler.bot` listed in
the manifest, warning-clean.

The campaigns of the phases this milestone touched (AGENTS.md), on the final
tree:

| campaign | result |
|---|---|
| `audit/same-failure/tools/fuzz.tcl` | 300 seeds, 0 failures, 0 extra warnings |
| `audit/same-failure/tools/mutate.tcl` | 15 mutants, 15 killed (three mutant texts needed the `FailSites` skip on its own lines; the condition they mutate is unchanged) |
| `audit/error-payloads/tools/fuzz.tcl` | seeds 1, 2; seed 3 with `-gc-stress 1`; `-fault unhandled`; `-fault wrong-namespace`: 40 programs each, 0 disagreements |
| `audit/error-payloads/tools/mutate.tcl` | 44 mutants, 44 killed |
| `audit/affine/tools/fuzz.tcl` | seeds 1, 2: 30 programs each, 0 disagreements |
| `audit/enums/tools/mutate.tcl -only cross-enum-parameter` | killed (its text follows `IsFn` -> `IsCallable`) |
| `audit/affine/tools/mutate.tcl` | 29 mutants, 29 killed |
| `audit/coroutines/tools/mutate.tcl` | 52 mutants, 52 killed |
| `audit/one-char-string-literal/tools/fuzz.tcl` | 300 seeds, 0 failures, 0 extra warnings; spelling law 788 of 788 |
| `audit/refinement-values/tools/fuzz.tcl` | 200 programs, 0 failures |
| `audit/traits/tools/mutate.tcl` | 18 mutants, 18 killed |
| `audit/context-traits/tools/mutate.tcl` | 23 mutants, 23 killed |

### 53. GC stress

With `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site), on the final tree:

* `tests/static-compile.test`: **83 of 83 pass** -- among them
  `sc-gc-stress`, which forces stress itself and runs on Cranelift: a
  rejected block's CompilerError read whole (message String, related List,
  nested SourceLocation structs); an accepted block's run-time
  IndexNotFound; and a program whose handler for a rejected block's
  CompilerError first runs an accepted block that starts and resumes a
  coroutine (an affine value), then reads the payload's related List and
  message String, five times over, the results kept in a List (63
  collections; every coroutine released, none swept);
* the fuzzer with `-gc-stress 1` (seed 121, 20 programs, 102 sites):
  0 disagreements (above);
* `audit/error-payloads/tools/fuzz.tcl -seed 3 -gc-stress 1`: 40 programs,
  0 disagreements.

A rejected block's payload is an ordinary declared error's: it travels
field-wise in the Vm's payload slots, which the collector roots, and the
handler's binding is an ordinary value.

### 54. Native coverage

`tests/native-coverage.tcl` (the whole suite on Cranelift, classified), on
the final tree:

| class | tests |
|---|---|
| native | 2873 |
| independent | 4118 |
| passed-partial | 69 |
| unsupported | 60 |
| failed | 0 |

Every `static-compile.test` test passes on Cranelift; the 60 unsupported
tests are the suite's existing ones (test-only natives such as `test-log`,
sequence mode, a validator contract), none of them a static block.

### 55. Scalar / codegen audit

Item 45's NIR identity is the scalar audit for accepted blocks (no branch,
allocation, check, wrapper or indirect call). The one native lowering change
(`PureDecidedCondition` accepting a root Boolean reference) removes a dead
`bool` constant from every `if true:`/`if false:` (and every accepted block
whose body binds a name). The scalar machine-code corpus
(`native/generate-scalar-audit.tcl`, regenerated into a private directory:
13 programs, 178 functions, 72887 bytes of machine code) is byte-identical to
the committed `audit/native-scalar-asm/` -- every `.asm` and `.vcode` file;
only the README's revision lines differ -- so no shipped program's code
changed.

### 56. Compile-time performance

[Performance](#performance).

### 57. Run-time performance

[Performance](#performance).

### 58. State-leak / stress

`sc-tx-deterministic`, `sc-rounds`, the bench's many-block files and the
fuzzer's programs of up to eight blocks: no growth (every build starts from
the same declarations), no stale summaries, decisions independent of
preceding rejected blocks.

### 59. SAME-FAILURE

A reified failure is not a fail site the programmer wrote: `hir::warnings::
FailSites` skips `fail` nodes with the `static` mark, so blocks rejected for
the same diagnostic never group (`sc-same-failure`). Ordinary `fail` sites
are unchanged. End to end the rule is also implied by the warning's
conservative payload rule -- a reified payload is a struct construction,
which `hir::exact::Identity` never proves identical to another, so it could
not group even unmarked -- which is why the first mutation campaign's
`same-failure-counts-reified` survived: the rule is now pinned where the
warning reads it (`sc-same-failure-sites`: of a function's two `fail` nodes,
one written and one reified, only the written one is a fail site), so it
holds if SAME-FAILURE ever learns struct identity. The reified message is a String constant the frontend
synthesizes; it is enumerated by `oc-synthesized-string-consts-enumerated`
and never one character long, so ONE-CHAR-STRING-LITERAL needs no rule.

### 60. Not implemented

No test framework, `test` declaration, expectation syntax or golden files;
no `static parse:`, `static assert_compiles:` or `static assert_rejects:`; no
`std::compiler::compile(str)`, no `syntactic fn`, macros, AST reflection,
compile-time evaluation or IO, subprocess, temporary file or run-time
compiler invocation; no diagnostic subtyping, one-error-per-diagnostic,
handler guards or pattern matching on diagnostics.

### Findings along the way

* A handled call whose normal result is a function value crashed the
  completion pass when a handler's type was checked against it
  (`core::type: malformed type "block ..."` from
  `hir::range::ProvesValueAcceptedBy`): an exact callable type now takes the
  subtype rule, as a structural `Fn` type always did -- found because a
  trial body may well be a function value.
* `surface::modules::RemapFile` did not remap a module's `fail` payload
  origins, so a diagnostic in one pointed at the entry file; it does now
  (the location attribution reads origins).
* Locations: the ordinary compiler reports a function's unproven result at
  its literal (the `(`), a missing context and an instance's invalid call at
  the call -- outside the block that causes them; a static block follows the
  ordinary convention, so those are the enclosing program's diagnostics.

## Performance

`tclsh9.0 bench/static-compile.tcl` (defaults: best of 5 runs; 2000 calls
on the Tcl backends, 200000 natively), on an otherwise idle 4-CPU Linux
x86-64 container, Tcl 9.0.1, the release native backend:

### Compile time

| program | compile | builds |
|---|---|---|
| 1. ordinary valid block (`if true:`) | 24.9 ms | 1 |
| 2. the same block under `static compile:` | 25.9 ms | 1 |
| 3. an invalid block under `static compile:` | 24.9 ms | 2 |

| K blocks | plain (valid only) | all valid, static | builds | mixed (1/3 UNBOUND, 1/3 TYPE), static | builds | per build |
|---|---|---|---|---|---|---|
| 10 | 55.9 ms | 59.9 ms | 1 | 105.1 ms | 3 | 35.0 ms |
| 25 | 144.2 ms | 123.6 ms | 1 | 204.7 ms | 3 | 68.2 ms |
| 50 | 239.3 ms | 238.6 ms | 1 | 373.4 ms | 3 | 124.5 ms |

### Run time

| operation (ns per call) | interp | compile | native |
|---|---|---|---|
| accepted static block | 137006.0 | 2340.0 | 42.6 |
| the same body written plainly | 137811.0 | 2334.0 | 46.7 |
| rejected static block, CompilerError handled | 264604.0 | 22483.5 | 241.5 |
| the same CompilerError written by hand, handled | 372409.5 | 24566.0 | 248.3 |

### Native heap allocations (one call)

| program | allocations | bytes |
|---|---|---|
| accepted static block | 0 | 0 |
| the same body written plainly | 0 | 0 |
| rejected static block, handler reads code and primary | 2 | 72 |
| the same CompilerError written by hand | 2 | 72 |

Reading it:

* **Compile time.** A program whose blocks are all accepted costs one
  build, the same build its plain spelling costs: the static file and the
  plain one are within run-to-run noise of each other (at K = 25 the plain
  file even measured slower). Every round of rejections costs one more
  whole build of the program; the mixed files -- a third of the blocks
  rejected in resolution, a third by a type check -- take three builds
  however many blocks they hold (resolution rejections are decided
  together; independent check-phase rejections are decided together
  wherever they stand -- [Decision economics](#decision-economics) and
  STATIC-DECISION-ECONOMICS.md have the scaling), so their cost is about 1.6-1.9 times the all-valid
  file's. A build that stops at a resolution diagnostic is cheap (row 3's
  two builds cost one full build's time).
* **Run time.** An accepted block is the plain body: the same NIR (item
  45), the same Core IR, so the same time -- the table's differences
  (42.6 against 46.7 ns natively) are noise between two identical
  programs. A rejected block costs exactly what the same
  `fail std::compiler::CompilerError {...}` written by hand costs: the
  hand-written function needs a parameter and a branch to avoid being a
  KNOWN-ERROR, which is why it is, if anything, slower.
* **Allocations.** None for an accepted block. A rejected one allocates
  what its payload's fields need when it fails (the `primary`
  SourceLocation and the `related` List: 2 allocations, 72 bytes; the
  message is a static String constant), the same as the hand-written
  failure; nothing is allocated on the paths that do not fail.

## Files

| file | what |
|---|---|
| `surface/parser.tcl` | `staticIntrinsic`, `AtStatic`, `StaticIntrinsic`, misuse diagnostics |
| `surface/ast.tcl` | the `static` node: ids, children, printing |
| `surface/lower.tcl` | the `static` syntax node |
| `surface/modules.tcl` | the `import std::compiler` rule, deferred loader diagnostics (`StaticSites`, `CheckRef`, `LowerStatements`), `RemapFile` |
| `hir/syntax.tcl` | `staticNode` |
| `hir/static.tcl` | sites, expansion, reification, decisions (the schedulers, `Simulate`, `MethodSeeds`, the trace), the code table |
| `hir/staticdeps.tcl` | the dependency analysis of a build (`Deps`, `Explain`) |
| `hir/hir.tcl` | `hir::buildSyntax` / `hir::BuildFull` (method-call seeds, `MethodConfig`, `BuildStats`), `hir::Diagnose`'s `related` |
| `hir/resolve.tcl` | the mark on a reified `fail`, its UNHANDLED-ERROR wording |
| `hir/completions.tcl` | KNOWN-ERROR's `intended` |
| `hir/warnings.tcl` | SAME-FAILURE skips reified failures |
| `hir/affine.tcl` | related locations of USE-AFTER-MOVE / AFFINE-NOT-DEFINITELY-LIVE |
| `hir/traits.tcl` | monomorphized-program diagnostics marked `internal` |
| `hir/range.tcl` | an exact callable type in `ProvesValueAcceptedBy` |
| `hir/format.tcl`, `hir/read.tcl` | `static=OP:KIND` |
| `native/lower.tcl` | `PureDecidedCondition`: a root Boolean reference |
| `stdlib/compiler.bot` | `DiagnosticCode`, `SourceLocation`, `CompilerError` |
| `tests/static-compile.test` | the tests named above |
| `tests/static-economics.test` | the schedulers' equality, build-count bounds, method-decision reuse, the properties the dependency analysis relies on |
| `audit/static-compile/tools/` | `fuzz.tcl`, `mutate.tcl`, `mutants.txt` |
| `audit/static-decisions/tools/` | the schedulers' differential (`compare.tcl`, `lib.tcl`), model-based fuzzer (`fuzz.tcl`) and mutants (`mutate.tcl`, `mutants.txt`) |
| `bench/static-compile.tcl` | the performance report |
| `bench/static-decisions.tcl` | the decision economics report |

## What to run when changing this

If you change the static-intrinsic grammar, `hir/static.tcl`, the loader's
deferral, how `fail` resolves or lowers, the completion walk's `fail` case,
`hir::Diagnose`'s fields, or add a diagnostic kind anywhere in the front end:
run `tests/static-compile.test`, `audit/static-compile/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`) and
`audit/static-compile/tools/mutate.tcl` (every mutant in `mutants.txt` must
still apply and be killed). A new diagnostic kind needs its classification
in `sc-census-exhaustive` and, if a block can produce it, a case in
`stdlib/compiler.bot` and `hir::static::codes`.

If you change the decision schedulers (`hir/static.tcl`'s `decide`,
`Simulate`, `MethodSeeds`), the dependency analysis (`hir/staticdeps.tcl`),
the method-call decisions' seeds or build reuse (`hir/hir.tcl`), or any fact
an analysis reads across functions -- a new summary, a new backward or
program-wide channel (an inferred contract, the erased-callable contract,
an instance budget, a yield type, the ownership verdict), a new diagnostic
suppressed by reachability or by a whole-program verdict (as
`hir::affine::verify` withholds release scopes from a program its analysis
rejects) -- run `tests/static-economics.test`,
`tests/static-compile.test`, `audit/static-decisions/tools/fuzz.tcl`
(several seeds; `-legacy 1` also checks the legacy scheduler),
`audit/static-decisions/tools/compare.tcl` (the golden suites, the only
programs with static sites, batched against sequential: in CI, never
locally -- the `static-decisions` workflow,
`.github/workflows/static-decisions.yml`; AGENTS.md, "The sequential
comparison runs in CI, never locally") and
`audit/static-decisions/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), and `tests/golden.test` (`golden-static-economics` bounds
the suites' builds). A new cross-function channel the analysis misses shows
up as a `mispredicted` build or a difference from the sequential scheduler:
add its edge to `hir/staticdeps.tcl` (and to its header), never a special
case in the scheduler. A new program-wide channel is a `C:` node, which the
waiting rule reads as well (`Waits`): an edge to or from one can change which
block the order judges first, so check the fuzzer's layout claim (its item
3) on several seeds, and classify a gate-shaped channel as [The waiting
rule](#the-waiting-rule) does. `bench/static-decisions.tcl` regenerates the
economics report.
