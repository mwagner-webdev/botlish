# RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md -- a computation receives the authority injected into it

> Installing a context makes an implementation available to the program.
> Injecting a context grants a particular computation permission to use it.
> Availability is not authority: a computation must not acquire
> dependencies merely because its creator possesses them.

```botlish
context struct Network:
    id: int

context struct Storage:
    base: int

fn store(n: int, context st: Storage) -> int:
    n + st.base

fn calculate(n: int) -> int:
    n * 2

with context Network {id: 7}
with context Storage {base: 10}

a = inject no context:          # a contextless computation
    calculate(16)
b = inject context Storage:     # a Storage-only computation
    store(a)
b                               # 42, on every backend
```

An inject block is a computation whose code may use exactly the contexts it
lists, whatever the code around it can use. Installation and selection do
not change: a context is still installed once, at the entry program's top
level, and a context trait's implementation is still selected once per
program. The block only narrows which of the contexts already available its
code may use, and the compiler proves it: transitively over every call, for
nested blocks, for the enclosing function's context parameters, for direct
modules' mediation and for coroutines constructed elsewhere. Nothing of it
exists at run time.

## Contents

1. Executive result
2. Starting model
3. Language semantics
4. Chosen syntax
5. Static checking
6. Coroutine authority
7. Explicit delegation
8. Compiler representation
9. Backend behavior
10. Acceptance programs
11. Negative tests
12. Mutation testing
13. Performance
14. Compatibility
15. Remaining limitations
16. Next milestone: what `std::actor` still needs
17. Files, and what to run when changing this

---

## 1. Executive result

**Implemented.**

* **The form.** `inject context T1, T2:` and `inject no context:`, followed
  by an indented block: a statement, or the value of a binding, `return` or
  destructuring (its last statement's value). Each `T` is a context struct
  or a context trait, by its canonical identity. `inject` is a contextual
  word (`surface::parser::AtInject`): `inject = 1`, `inject(x)` and
  `fn f(inject: int)` keep their meaning (`ri-parse-contextual`).
* **The rule.** Inside the block, every call -- direct, through an imported
  module, method-style, of a generic (imprinted) function, a trait
  operation as the selected implementation graph binds it, a coroutine
  construction -- may require only injected contexts, transitively
  (`CONTEXT-NOT-INJECTED`, with the requirement's chain). The check reuses
  `hir::contexts::Requirements`, the analysis that already decides
  `MISSING-CONTEXT`; there is no second reachability analysis.
* **Nesting never widens.** A nested block injects a subset of the
  enclosing one; a function that contains a block *requires* what the block
  injects (the block is a use of it), so the function's callers -- and
  their blocks -- must have it too.
* **Context parameters are the creator's authority.** The block may not
  read a context parameter of the function it is written in, nor call a
  nested function that does, unless it injects that context.
* **Direct modules.** A direct module's call inside a block is mediated only
  by an *injected* context of the calling module.
* **Retained coroutine authority.** A coroutine keeps the contexts it was
  constructed with, and its handle's type does not say which. A static
  provenance analysis follows every handle from its construction; a block
  may resume a coroutine only when every construction that can reach the
  resume needed only injected contexts (`CONTEXT-RETAINED-AUTHORITY`). A
  privileged coroutine constructed before the block cannot be resumed in it
  -- directly, through a helper (typed, generic or method-style), through a
  struct, through a wrapper coroutine, as a construction argument or as a
  helper's result -- while contextless and Storage-only coroutines
  constructed within the injected contexts are accepted, and moving a
  privileged handle *through* a block without resuming it is accepted.
* **Zero runtime cost.** The block is the ordinary block `if true:`
  carrying one field, `injects`, on its `if` expression. The NIR of a
  program with blocks equals the NIR of the same program written with
  `if true:` (`ri-zero-cost-nir`); a function called from privileged and
  restricted code is one native instance (`ri-zero-cost-instances`). Every
  backend runs the same programs to the same values.
* **Diagnostics.** `CONTEXT-NOT-INJECTED`, `CONTEXT-RETAINED-AUTHORITY`,
  `DUPLICATE-INJECTED-CONTEXT`; `MISSING-CONTEXT` and
  `AMBIGUOUS-CONTEXT-IMPLEMENTATION` for a top-level block injecting what
  is not installed (or ambiguously implemented) where it runs; `TYPE` and
  `NOT-A-CONTEXT` for the injected types. Each has a
  `std::compiler::DiagnosticCode` case and a Compilerpedia topic; the two
  restriction kinds are obligations of the selected call (SFIAE).

**Not implemented** (scope, section 14 of the brief): `std::actor`, actor
spawning or supervision, threads, cross-thread messaging, sendability,
actor-local installation or selection, a runtime permission check, an
effect system, revocation. The block restricts *context authority*; it is
no process isolation, no memory-safety boundary against unsafe native code
and no sandbox against capabilities a creator deliberately passes as values
(section 7).

The evidence: `tests/restricted-injection.test` (45 tests, every backend
where a program runs), the mutation harness (section 12), the regression
files of the contexts, context traits, coroutines, static intrinsics,
syntax recovery, direct modules and context-owned state (section 14).

## 2. Starting model

What the compiler did before this milestone, as the census found it:

* **Installation.** `with context EXPR` is a root statement of the entry
  program (`hir::contexts::verify`'s root walk; CONTEXT-INSTALLATION-
  UNSUPPORTED anywhere else, hir/contexts.tcl's `Unsupported`, and the
  loader for modules). It moves the value into the installed context
  (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md).
* **Requirements.** For every function (block) the analysis computes
  `direct(B)`, the context identities its region loads (its context
  parameters, `context#load("ID")`), and `required(B)`, the least fixed
  point over the call edges (`hir::contexts::Requirements`); the edges are
  `hir::contexts::Targets`: a call's exact callee (`Callee`: a block
  literal, a binding denoting one through aliases, a native whose body is a
  module function), the specialization a call of a trait-polymorphic
  function resolves to, the implementation the selected implementation
  graph binds an ordinary trait operation to. A context-trait operation has
  no edge: its implementation's requirements are the obligation of the
  top-level call that selects it (`Obligations`).
* **Selection.** Only top-level calls are checked against the installed
  set (`Obligations`, reported through `hir::CheckingCall`): a context
  struct must be installed; a context trait must be implemented by exactly
  one installed context, which is then *the* selection, program-wide
  (`contexts selected`).
* **Coroutines.** A construction `coroutine#create(THUNK)` is a call of its
  thunk (`Callee`): its requirement is the construction's, checked where the
  construction is (directly at top level, through the enclosing function's
  requirement elsewhere). A resume selects nothing -- it is the native
  `coroutine#resume(handle, ...)` for a handle binding (hir/resolve.tcl's
  `CoroutineResume`) or a call through a coroutine-typed value -- so the
  coroutine's code runs with the providers its construction selected
  (COROUTINES.md, "Context interaction"). The handle type `Coroutine{args,
  return, errors}` does not encode those requirements.
* **Function values.** A function whose requirement is not empty may only
  be called or aliased (`CONTEXT-FUNCTION-VALUE`, `CheckValues`): every
  call through a value calls a context-free function.
* **Context-owned state.** A context parameter names the installed
  storage; affine members are context places, observed where they are
  stored and moved only by a collection's explicit operations
  (`hir::affine::ContextPlace`).
* **Direct modules.** A call of a designated direct module is mediated
  only when the calling function requires a context its own module
  declares (`hir::direct::Discharge`).

Where a restricted environment can be represented: the requirement graph
already knows, for every call, the transitive set of contexts it needs, so
the smallest new static fact is *the injected set of a lexical region* --
one list on one expression -- judged against those sets. What it could not
see is the authority a coroutine *handle* carries: that needed one new
analysis, the handle provenance of section 6. No runtime representation was
needed for either.

## 3. Language semantics

Three concepts, kept apart:

| concept | meaning | scope | changed |
|---|---|---|---|
| installation | an implementation exists for a context | entry program, top level | no |
| selection | the implementation chosen for a context trait | program | no |
| injection | a computation is permitted to require a context | an inject block | new |

For an inject block R with injected set I(R) in the code of function O ("" at
top level):

* **Grant.** R is a use of I(R) by O: O requires every context of I(R)
  (reason `inject`, printed in chains as "injects X (the inject block at
  LOC)"). At top level each context of I(R) must be available where R
  runs: a struct installed by an earlier `with context`, a trait implemented
  by exactly one installed context (`MISSING-CONTEXT`,
  `AMBIGUOUS-CONTEXT-IMPLEMENTATION`). An inject block installs nothing:
  `with context` inside one is CONTEXT-INSTALLATION-UNSUPPORTED ("inside an
  inject block, which grants installed contexts and never installs one").
* **Use.** R's code requires only contexts of I(R):

      RequiredContexts(R) ⊆ I(R)

  where RequiredContexts(R) is the union of the transitive requirements of
  every call of R's own code, of the contexts of the enclosing functions'
  context parameters it reads, and of those its callees read through nested
  functions' captures.
* **Nesting.** A block nested in R's code (the same function's) injects a
  subset of I(R). A block in a nested function F is a use by F, so every
  call of F is held to the block around it by the ordinary rule: authority
  cannot widen through any number of functions or blocks.
* **Traits.** A context trait in I(R) grants its operations, through the
  implementation the program selected; it does not grant the implementing
  context's other functions (`inject context std::io::IO:` may print; it
  may not call `std::linux::io::write`). Conversely an injected context
  struct does not grant a trait it implements: requirements are identities,
  and so are grants (`ri-context-trait`).
* **Retained authority.** A resume in R -- or a call in R whose callee may
  resume, or a construction in R whose coroutine may resume -- runs only
  coroutines constructed within I(R) (section 6).

The restriction is static: no runtime context lookup, permission mask,
alternate selection or second installed value exists. The same installed
implementation serves every computation, each with its own permission to
invoke it.

## 4. Chosen syntax

    inject context Database, std::io::IO:
        handle(request)

    worker = inject no context:
        coroutine calculate(inbox)

**One mechanism: a lexical restricted block.** The brief's three directions
were evaluated against the use cases:

* *A restriction attached to coroutine construction* covers the
  calculation actor but not the request handler (no coroutine), and still
  needs the provenance check for handles that cross into the coroutine.
* *A restricted call* (`restricted(f, x)`) is a special case of the block:
  `inject context A: f(x)`. A block also covers several statements, a
  construction plus its adoption into a loop, and a value result.
* *A lexical block* covers all of them -- a contextless calculation, a
  Storage-only service, a framework's request handler, nested
  restrictions -- with no new function kind, coroutine type or callee-side
  annotation. Chosen.

**Spelling.** `inject` is the brief's own word for the act, and the
diagnostic says what happened: "Network is required by this call, but the
enclosing inject block injects only Storage". Rejected spellings:

| spelling | why not |
|---|---|
| `with only context S:` | overloads `with`, whose one form installs: `with only context S:` beside `with context s::create()` would blur installation and injection, which the brief forbids |
| `restrict context S:` | reads as "restrict S" (forbid it) as easily as "restrict to S" |
| `only context S:` | terse, but an empty set needs a second introducer (`no context:`) and nothing names the act |
| a function modifier (`fn h() only context S:`) | the wrong party: the creator restricts a computation, not the callee its own signature; a callee already says what it requires |
| `inject context:` for the empty set | an empty list after a keyword reads as a mistake; `inject no context:` says it, and `inject context:` is a located syntax error suggesting it |

**Grammar** (surface/parser.tcl's `Injection`):

    injection = "inject" ( "no" "context" | "context" typeExpr { "," typeExpr } ) ":" suite

Every malformed shape is a located syntax error with its own message
(`ri-parse-errors`, `ri-parse-error-messages`): a missing list, a wrong
second word, a name after `no context`, a missing `:` or block, code on the
`:` line, and an attempt to install (`inject context s = ...:`: "an inject
block grants contexts that are already installed and installs nothing").
Qualified types (`std::io::IO`, `net::Network`) are qualified references
the loader records and rewrites like any annotation (surface/modules.tcl's
`Walk`); syntax recovery treats a damaged block as any damaged statement.

## 5. Static checking

`hir::injection::verify` (hir/injection.tcl), run by `hir::CheckOnce` right
after `hir::contexts::verify` and `hir::direct::verify`, judges every
reachable inject block of the checked program (`Judged`: never the
monomorphized one, which only carries the field). For each block R it
recomputes the requirement graph (`hir::contexts::Walk`, `Requirements`:
the same edges and the same fixpoint as MISSING-CONTEXT) and, for every
expression whose innermost block is R:

* **calls** of R's own code (the same function's region; a nested
  function's calls are judged at the calls of it): every target in every
  context the code runs in (`Contexts`: the program as written and every
  specialization of the trait-polymorphic function around it) must require
  only I(R) (`CheckCall`). The diagnostic carries the chain
  (`hir::contexts::ChainLines`) and is reported inside
  `hir::CheckingCall`, so it is an obligation of the selected call
  (`hir::methods::ObligationKinds`): an injection never makes another
  method candidate applicable (`ri-sfiae`). At top level a context that is
  not installed at all is MISSING-CONTEXT's (reported by the top-level
  walk) and never also CONTEXT-NOT-INJECTED: the brief's distinction
  between "not installed anywhere" and "installed but deliberately not
  injected".
* **references** to a context parameter declared outside R (`CheckBinding`;
  a struct's load or a context trait's binding) need its context in I(R).
* **captures**: a call of a function that (transitively) reads an
  enclosing function's context parameter declared outside R
  (`Captures`, a second fixpoint over the same edges) needs that context
  in I(R). In the analysis a nested function reading its enclosing
  function's context parameter requires nothing -- the load is its
  enclosing function's -- so without this a helper defined before the
  block could use the creator's context from inside it.
* **nested blocks** of the same function's code inject a subset of I(R).
* **direct calls** (`CheckDirect`): a call of a designated direct module
  made by the calling module's code is mediated, inside R, only by a
  context of R's I(R) that the module itself declares.

Transitivity is the existing analysis's: direct calls, calls through
imported modules (`ri-imported-module`), method-style calls
(`ri-method-sugar`), generic and imprinted functions (`ri-generic`), context
traits (`ri-context-trait`, `ri-trait-in-function`), functions with several
requirements (`ri-only-the-missing`: only the missing ones, once each),
wrappers that mention no context, recursion and mutual recursion
(`ri-recursion`), nested functions (`ri-closure-in-block`), coroutine
constructions (`ri-coroutine-construction-checked`). Unreachable code
requires nothing (`ri-unreachable`), as for MISSING-CONTEXT.

Specialization does not leak a caller's assumptions: requirements are
properties of functions, not of instances (CONTEXTS.md), and the
specializations a trait plan makes are judged in their own contexts
(`Contexts`). A function compiled for a privileged call site and called
from a block is checked by its requirement at the block's call, whatever
instance the backend compiles.

## 6. Coroutine authority

**The counterexample.** A privileged supervisor constructs a coroutine that
retains Network (its construction was checked against the installed set),
then resumes it inside `inject no context:`. The resume selects nothing, the
handle's type says nothing about Network, and the block's own calls require
nothing: without more, the coroutine's Network code would run inside the
block. The milestone rejects it:

    coroutine {step: privileged} = task(41)      # retains Network
    inject no context:
        privileged()                             # CONTEXT-RETAINED-AUTHORITY

**The analysis** (`hir::injection::Provenance`): every value that may hold a
coroutine handle carries a set of *origins* --

| origin | meaning |
|---|---|
| `{auth IDS C}` | constructed by construction call C with requirement IDS (its thunk's transitive requirement) -- plus the origins of what its own code resumes |
| `{p BLOCK I}` | what the caller passes as parameter I of BLOCK (substituted at each call) |
| `{foreign context ID}` | moved out of the installed context ID's state |
| `{foreign payload ERROR}` | received in an affine error payload |

-- computed by a monotone fixpoint over the requirement graph's nodes and
edges, with two summaries per function: the origins of what it may resume
(directly, through callees with their parameters substituted, through a
call of a value -- a coroutine handle, a function value, a context-trait
operation -- which may resume its callee and whatever it is passed), and
the origins that may leave it (its result, and what it moves into its place
parameters). Values flow through bindings (immutable: a reference has its
binding's origins), struct and List construction and projection,
destructuring, `if` and handler joins, loops and folds, collection
mutations (a `mutate` operation moves its arguments into its receiver's
place: `hir::mutvec::OpKind`), place parameters, and every other expression
as the union of its parts. A value whose static type is definite and not
affine holds no handle and carries nothing (`HandleFree`); `any`, trait
views and structural `Fn` types keep their origins, because an untyped
parameter of a generic function is typed in the checked build by its uses
-- `Fn{...}` once it is called -- while the monomorphization specializes it
for a coroutine argument (AFFINE-VALUES.md: one callable contract). This was
found by the laundering test `p3.generic_drive()`: pruning Fn-typed values
let a generic helper launder a handle (the mutant `fn-typed-handle-free`
pins it).

A resume, or a call that may resume, inside R (`CheckRetained`) is accepted
only when every origin is `{auth IDS C}` with IDS ⊆ I(R); otherwise
CONTEXT-RETAINED-AUTHORITY says what is retained ("may resume a coroutine
that retains Network") or why it cannot be proven ("one moved out of the
installed context Pool, where any code using that context may have put
it"; "parameter h of host, which its caller constructed"). A resume of a
coroutine whose construction was itself rejected (CONTEXT-NOT-INJECTED at
C) is that rejection's consequence and is not reported again.

**Why it is sound.** No other channel carries a handle into a computation.
A coroutine never yields, returns or is resumed with an affine value
(COROUTINE-CONTRACT: "pass affine values in at construction"), so resume
messages and results carry no handle; a closure never captures one
(AFFINE-CAPTURE-UNSUPPORTED), `any` never holds one
(AFFINE-ERASURE-UNSUPPORTED) and no module binding is one. What is left --
construction, arguments, results, bindings, aggregates, collections, place
parameters, installed context state and error payloads -- the analysis
follows or treats as foreign. Every handle resumed inside R therefore either
was constructed during R's computation -- its requirement, part of the
requirement of the call that constructed it, already checked against I(R)
-- or entered R through a reference, a parameter, a context place or a
payload, each judged at the resume. The analysis is conservative: an origin
it cannot follow rejects a resume, never accepts it.

**What it accepts** (`ri-coroutine-accepted`): a contextless coroutine
constructed in the block; one constructed outside the block that needed
nothing; one built by a helper the block calls (its construction is the
helper's requirement); one moved through a struct and destructured; one
driven by a typed or untyped helper; a coroutine that constructs and
resumes child coroutines; a Storage-only coroutine in a Storage block.
Moving a privileged handle through a block without resuming it uses none
of its authority and is accepted (`ri-coroutine-pass-through`: the block
returns it, privileged code resumes it). Adopting a coroutine into
`std::event_loop` is a move into the Loop's state, not a resume: two
restricted coroutines, one with only the Loop and one with the Loop and
Storage, run on one ordinary event loop (`ri-same-thread-actors`).

**What it rejects** (`ri-coroutine-laundering`, `ri-coroutine-parameter`,
`ri-coroutine-context-place`): a privileged handle resumed directly, passed
to a typed helper, to an untyped generic helper (also method-style),
through a struct, through a wrapper coroutine constructed outside, as an
argument of a construction inside the block, returned by a helper that
constructed it outside the block; a handle moved out of an installed
context's collection (even with that context injected); the enclosing
function's own coroutine parameter.

The checks are made at resume time *statically*, at every resume site, not
"at the first resume" of a handle.

## 7. Explicit delegation

The guarantee is: **a computation cannot directly invoke a context-dependent
operation unless that context was injected into it.** It is not: a
computation can never indirectly cause a privileged operation anywhere.

* **Values cross freely.** Data, a struct, a List, a function value (which
  is context-free by CONTEXT-FUNCTION-VALUE), an event-loop registration, a
  mailbox address: R may receive and use any value. A privileged supervisor
  that acts on a message a contextless actor sends is delegation through a
  typed communication capability, by design.
* **A copy of a context value is a value.** `v = net` outside the block,
  then `use_value(v)` inside it, is accepted (`ri-context-parameters`, case
  `d`): CONTEXTS.md makes a context value an ordinary value, and what it
  permits is what its own module allows on values (an opaque context's
  module decides). What is rejected is reading the context *parameter*
  itself (`net.id`), which is the creator's compiler-granted authority.
  Context-owned affine state cannot be copied out at all
  (AFFINE-CONTEXT-COPY-OUT), so this delegates no resource.
* **A coroutine handle is not a value-like delegation.** It runs code with
  its construction's authority, so it is judged by what it retains
  (section 6) whenever R resumes it; moving it through R is accepted.
* **Direct modules.** A direct module's own raw authority is acknowledged
  ambient authority at its boundary (DIRECT-MODULES.md) and is not context
  authority: a block in a `direct module` can make its raw calls. A block
  in an *ordinary* module whose function mediates a direct call through its
  context cannot, unless it injects that context (`ri-direct-mediation`).

Existing restrictions are unchanged and not weakened: CONTEXT-FUNCTION-
VALUE, the build-2 check of a closure over a context-trait binding, retention
of coroutine providers, installation only at top level, direct-module
airlocks, opacity.

## 8. Compiler representation

* **Surface.** AST node `inject` {injectSpan, contexts {type typeSpan},
  none, body} (surface/ast.tcl; ids, children, print-back, recovery).
* **HIR.** The block lowers to the ordinary block `if true:` -- the form an
  accepted `static compile:` block already takes (hir/static.tcl's
  `Accepted`) -- with one syntax field, `inject` (the written types and
  their origins), which resolution reads into the `if` expression's
  `injects` (canonical identities, written order; `hir::injection::Resolve`).
  Every analysis reads the block as what it is: code that runs once, right
  there, scoping what it binds; `return`, `yield`, errors and handlers keep
  their meaning; its value is its last statement's.
* **Requirements.** `hir::contexts::Requirements` adds each function's
  grants (`hir::injection::Grants`) to its direct requirement with the
  reason `{inject R}`; `ChainLines` prints it. `-contexts` prints
  `contextinject eN (IDS)` per block.
* **HIR text.** `eN if injects (ID, ...) : TYPE`, read back by
  hir/read.tcl; the round trip is exact (`ri-hir-text`). HIR interchange
  holds the HIR dict, so `injects` travels; a decoded program runs as built
  (`ri-interchange`). The front-end cache keys the front end's files, which
  this milestone changes, so every entry is rebuilt once.
* **Specialization and lowering.** Nothing. The monomorphized build carries
  the field and judges nothing (`Judged`); specialization keys, semantic
  instances, NIR, CLIF and the runtimes are untouched. A function called
  from privileged and restricted code is one instance
  (`ri-zero-cost-instances`).
* **Static intrinsics.** A rejected block inside `static compile:` is the
  CompilerError `ContextNotInjected` (`ri-static-compile`); the codes are in
  stdlib/compiler.bot and `hir::static::codes`, and
  `tests/static-compile.test`'s census classifies the kinds;
  `std::test::code_name` spells them (`gf-code-name-complete`). The decision's
  dependencies are the requirement graph's own edges (call targets, the
  bindings a region references, the function literals in it): the new
  analysis reads nothing across functions that hir/staticdeps.tcl does not
  already connect. `ri-static-schedulers` pins it: a block resuming a
  handle a callee returns is rejected or accepted as another site's
  decision in that callee changes the callee's summary, and the batched
  scheduler decides both programs exactly as the sequential order does.
* **Compiler service, language server.** The diagnostics are the
  compilation's (`ri-service`); a malformed block is a syntax error the
  recovered analysis reports first (`ri-syntax-recovery`).

**No runtime change.** Compile-time enforcement is sufficient because the
installed implementations and selections are program-wide and fixed: what a
computation may call is decided by the call graph, which the compiler
knows completely (every indirect call is context-free), and what a resumed
coroutine may run is decided by its construction, which the provenance
analysis follows.

## 9. Backend behavior

The interpreter, the Tcl compiler, the generic and the specialized native
backend (and standalone executables, which compile the same NIR) run the
same programs to the same values: every accepted program of
`tests/restricted-injection.test` that runs is run on all four through
`riAgree`, except the event-loop program, which runs on the interpreter and
the specialized native backend (its compile time dominates the file). A
program is accepted or rejected by the front end before any backend runs, so
no backend can accept what another rejects. No backend reads `injects`.

## 10. Acceptance programs

| brief | test | what it shows |
|---|---|---|
| contextless computation | `ri-contextless-calculation` | `inject no context:` beside three installed contexts computes |
| | `ri-not-injected-transitive` | a Network requirement two calls deep is CONTEXT-NOT-INJECTED, with its chain |
| | `ri-outside-unchanged` | the same function stays callable outside the block |
| one injected context | `ri-storage-only` | Storage reached through several calls |
| | `ri-only-the-missing` | a function needing Storage, Network and Clock: Network and Clock reported, once each |
| | `ri-context-trait`, `ri-trait-in-function` | a selected context trait injected; the implementing context is not granted by the trait, nor the trait by the context |
| nested restrictions | `ri-nested-narrowing` | a Storage block creates a contextless child; injecting Network inside it is rejected |
| | `ri-grant-is-a-use` | a function's inner block makes the function require its contexts, at blocks and at top level |
| existing privileged coroutine | `ri-coroutine-laundering` | seven laundering routes rejected |
| | `ri-coroutine-accepted`, `ri-coroutine-pass-through` | provably restricted coroutines accepted; a moved-through handle accepted |
| web-framework-shaped entry | `ri-web-framework` | a framework runs a handler with Database injected beside Network and Logging: Database services reached, a Network one rejected; no actor, loop or thread |
| same-thread composition | `ri-same-thread-actors` | two restricted coroutines (Loop; Loop and Storage) on one ordinary event loop, the same VM and installed implementations; the calculator calling a Network function is rejected |

## 11. Negative tests

Every escape route the brief lists, and what happens:

| route | test | outcome |
|---|---|---|
| nested calls | `ri-not-injected-transitive`, `ri-recursion` | CONTEXT-NOT-INJECTED, chain |
| imported modules | `ri-imported-module` | CONTEXT-NOT-INJECTED |
| method sugar | `ri-method-sugar`, `ri-sfiae` | CONTEXT-NOT-INJECTED; never selects another candidate |
| generic imprinting | `ri-generic` | CONTEXT-NOT-INJECTED |
| context traits | `ri-context-trait`, `ri-trait-binding` | CONTEXT-NOT-INJECTED |
| function arguments and results | `ri-closure-in-block`, `ri-coroutine-laundering` | a context-free function value is no use; a handle through a helper's result or argument is judged by its construction |
| existing coroutine handles | `ri-coroutine-laundering` | CONTEXT-RETAINED-AUTHORITY |
| nested and returned coroutines | `ri-coroutine-laundering` (wrapper), `ri-coroutine-accepted` (spawner) | a wrapper carries what it resumes; children constructed inside are accepted |
| affine aggregates | `ri-coroutine-laundering` (struct), `ri-coroutine-accepted` | judged through the struct |
| context-owned resources | `ri-coroutine-context-place` | a handle moved out of a context's state is unprovable: rejected |
| closures | `ri-context-parameters`, `ri-trait-binding`, `ri-closure-in-block` | a nested function reading the creator's context parameter is a use of it |
| `any` and erased values | -- | a handle is never erased (AFFINE-ERASURE-UNSUPPORTED); `any`-typed values keep their origins |
| static or module values | -- | no module binding holds a handle; a block at module level injects what is installed there (nothing: MISSING-CONTEXT) |
| direct modules | `ri-direct-mediation` | CONTEXT-NOT-INJECTED |
| widening inner injection | `ri-nested-narrowing`, `ri-grant-is-a-use` | CONTEXT-NOT-INJECTED |
| installing inside a block | `ri-installation-inside` | CONTEXT-INSTALLATION-UNSUPPORTED |
| not installed where a top-level block runs | `ri-top-level-availability` | MISSING-CONTEXT |
| an unprovable parameter handle | `ri-coroutine-parameter` | CONTEXT-RETAINED-AUTHORITY |

Legal delegation stays legal: a copied context value (`ri-context-parameters`
case `d`), a moved-through handle (`ri-coroutine-pass-through`), event-loop
registrations and posts (`ri-same-thread-actors`), function values
(`ri-closure-in-block`).

## 12. Mutation testing

`audit/restricted-injection/tools/mutate.tcl` applies each mutant of its
`mutants.txt` to a private copy of the compiler and runs
`tests/restricted-injection.test` against it; a mutant counts as killed
only when one of the tests its `!!` line names fails.

23 mutants, one per rule the brief names and every rule above: ignoring the
restricted set, inheriting every installed context, checking only direct
calls, widening a nested injection, a grant that is no use, an unchecked
coroutine construction, an admitted privileged coroutine, a resume that
runs nothing, authority erased through a binding, a collection, a wrapper
coroutine, a trusted context place, an untracked parameter or a pruned
`Fn` type, a context trait bypassed, unchecked context parameters, captures,
availability and direct mediation, an injection that selects a method
candidate, the lowering or HIR text dropping the restriction, and `inject
no context:` read as no restriction.

| mutant | the bug | named detectors | final run |
|---|---|---|---|
| `ignore-injected-set` | the restricted set is ignored: a call's requirement is never compared with what the block injects | `ri-not-injected-transitive`, `ri-only-the-missing`, `ri-web-framework`, `ri-storage-only` | killed (15 failed) |
| `inherit-installed` | a block inherits every installed context: a top-level block's code may use whatever is installed where it runs | `ri-not-injected-transitive`, `ri-only-the-missing`, `ri-context-trait`, `ri-method-sugar` | killed (12 failed) |
| `direct-calls-only` | only the callee's own (direct) contexts are checked, not its transitive requirement | `ri-not-injected-transitive`, `ri-generic`, `ri-recursion`, `ri-storage-only` | killed (10 failed) |
| `wider-nesting` | an inner inject block may inject what its enclosing block does not | `ri-nested-narrowing` | killed (1 failed) |
| `grant-not-a-use` | a function's inject block is no use of what it injects: the function requires nothing for it, so its callers' blocks and its top-level call are not checked for it | `ri-grant-is-a-use` | killed (2 failed) |
| `construction-unchecked` | a coroutine construction in a block is no call of its thunk: its requirement is not checked against the block | `ri-coroutine-construction-checked` | killed (2 failed) |
| `admit-retained` | a coroutine's retained authority is never compared with the block: a privileged coroutine constructed outside is resumed inside | `ri-coroutine-laundering`, `ri-coroutine-message` | killed (3 failed) |
| `resume-not-a-resume` | a resume of a handle binding (coroutine#resume) runs no coroutine code | `ri-coroutine-laundering`, `ri-coroutine-message` | killed (2 failed) |
| `binding-erases` | moving a handle to another binding erases what it retains (bind records no origins) | `ri-coroutine-laundering`, `ri-coroutine-context-place` | killed (4 failed) |
| `collection-erases` | moving a handle into a collection erases what it retains (a mutation does not reach its receiver's place) | `ri-coroutine-laundering` | killed (1 failed) |
| `context-place-trusted` | a handle moved out of an installed context's state is trusted (no foreign origin) | `ri-coroutine-context-place` | killed (1 failed) |
| `parameter-trusted` | a function parameter carries no origin: a helper that resumes what it is passed launders it | `ri-coroutine-laundering`, `ri-coroutine-parameter` | killed (2 failed) |
| `fn-typed-handle-free` | a value typed by a structural Fn contract holds no handle: an untyped generic helper, specialized for a coroutine, launders it | `ri-coroutine-laundering` | killed (1 failed) |
| `wrapper-erases` | a coroutine's handle carries only its own requirement, not what its code resumes: a wrapper coroutine launders the handle it was given | `ri-coroutine-laundering` | killed (1 failed) |
| `trait-bypass` | a requirement of a context trait is never checked: an injected implementing context, or nothing, grants it | `ri-context-trait` | killed (1 failed) |
| `binding-unchecked` | a reference to the enclosing function's context parameter is not checked | `ri-context-parameters`, `ri-trait-binding` | killed (2 failed) |
| `captures-unchecked` | a nested function defined outside the block that reads its enclosing function's context parameter is called inside unchecked | `ri-context-parameters`, `ri-trait-binding` | killed (2 failed) |
| `availability-unchecked` | a top-level block may inject a context that is not installed where it runs | `ri-top-level-availability` | killed (1 failed) |
| `direct-unmediated` | a direct module's call in a block is mediated by the enclosing function's context whether or not the block injects it | `ri-direct-mediation` | killed (1 failed) |
| `obligation-selects` | CONTEXT-NOT-INJECTED is a candidate's problem, not an obligation: a block's missing context selects another method candidate (SFIAE) | `ri-sfiae` | killed (1 failed) |
| `lowering-drops-restriction` | lowering forgets the injected contexts: an inject block is an unrestricted `if true:` | `ri-not-injected-transitive`, `ri-resolve-diagnostics`, `ri-hir-text` | killed (31 failed) |
| `hir-text-drops` | HIR text does not print an inject block's contexts: the round trip loses the restriction | `ri-hir-text` | killed (1 failed) |
| `no-context-means-all` | `inject no context:` is read as injecting every context (an empty list means no restriction) | `ri-not-injected-transitive`, `ri-grant-is-a-use` | killed (13 failed) |

**Result: 23 of 23 killed by a named detector** (the final run, on the
finished tree; the harness first runs the unmutated copy and refuses to
judge mutants unless every test passes there, so no mutant counts as killed
by a file that cannot load). The first run killed 22;
`collection-erases` survived because the only collection test resumed a
handle taken from *installed context state*, which is foreign whatever was
pushed into it. A local collection was the real gap: a privileged handle
pushed into a vector before the block and popped inside it. The test now
has that case (`launder_vector` in `ri-coroutine-laundering`) and the
mutant is killed (`mutate.tcl -only collection-erases`).

**Surviving limitations of the detectors.** The harness runs one test file;
it has no generated-program fuzzer of its own. The provenance analysis's
soundness argument (section 6) rests on the channels other analyses close
(COROUTINE-CONTRACT, AFFINE-CAPTURE-UNSUPPORTED, AFFINE-ERASURE-
UNSUPPORTED), which their own harnesses guard; a mutant opening one of them
is theirs, not this harness's.

## 13. Performance

**Runtime: zero.** An inject block lowers to `if true:`, whose condition
native lowering decides statically (the Tcl backends test one constant, as
for any `if true:`); the NIR of a program with blocks is
byte-for-byte the NIR of the same program written with `if true:`
(`ri-zero-cost-nir`), no instruction mentions it, and a function called
from privileged and restricted code is one native instance with exactly
the functions of the same program without blocks
(`ri-zero-cost-instances`). Coroutine construction and resume paths are
untouched (no runtime file changed). The Tcl backends compile the same
`if`.

**Compile time.** Measured on this 4-core container, front end only (no
cache), the time spent in the two new entry points per compilation
(`hir::injection::Grants`, called from the requirement analysis, and
`hir::injection::verify`):

| program | inject blocks | compile | in the new code | share |
|---|---:|---:|---:|---:|
| examples/event-loop/01-run-task.bot | 0 | 9,112 ms | 17.8 ms (3 checks) | 0.2% |
| examples/games/2048/demo.bot | 0 | 1,921 ms | 1.9 ms | 0.1% |
| two restricted actors on one event loop (`ri-same-thread-actors`' program) | 2 | 9,116 ms | 395 ms | 4.3% |
| the coroutine acceptance program | 6 | 145 ms | 4.8 ms | 3.3% |

A program without blocks pays one scan of its expressions per check (the
blocks are found by their field) and nothing else. A program with blocks
pays the provenance fixpoint over the whole program once per check: most of
the 395 ms is std::event_loop's 1,700 lines, analyzed although no block
calls most of them (a later optimization could analyze only the nodes the
blocks reach). Whole-compilation timings of this tree and of HEAD differ by
less than their run-to-run spread (01-run-task.bot: 9,670 ms at HEAD,
9,932 ms here; demo.bot: 1,734 ms and 1,462 ms; hello.bot: 586 and 587 ms;
medians of five).

No function is compiled again per authority subset: specialization keys,
semantic instances and native instances do not see injections.

## 14. Compatibility

* `inject` is contextual: an ordinary name everywhere a name followed by a
  name is not (`ri-parse-contextual`). No existing program writes two names
  side by side, so no existing program changes meaning.
* A program without inject blocks gets exactly the requirements, selections,
  diagnostics and code it had: `Grants` adds nothing, `verify` returns at
  once, and no backend reads the new field.
* Regression (this tree, a 4-core container): `tclsh9.0 tests/local.tcl`
  -- every Tcl test file on interp and compile, every golden suite on all
  four backends through the front-end cache. Tcl tests on interp: 8,250
  passed, 1 failed, 199 skipped (2,442 golden duplicates skipped); on
  compile: 8,245 passed, 1 failed, 204 skipped. Golden suites: 115 run, 0
  failed (interp 5,512/5,512, compile 5,512/5,512, cranelift-generic
  5,420/5,420, cranelift 5,522/5,522). The one failure on each pass was
  `gf-code-name-complete`: `std::test::code_name` must spell every
  `DiagnosticCode` case, and the three new ones were added to
  stdlib/test.bot after it; `tests/golden-framework.test` then passed
  42/42. The two pinned counts of diagnostic codes moved from 133 to 136
  (`sc-codes-one-to-one`, `gf-code-name-complete`); nothing else changed
  outcome. Also: `tests/static-compile.test` 83/83, the warning gate
  (`audit/refactor/tools/gate.tcl`: the observed warnings are exactly the
  manifest), `tools/compilerpedia.tcl check` (0 problems, 722 examples
  run), the golden manifest's `merge.tcl -check`.

## 15. Remaining limitations

* **Installed context state is unprovable.** A handle moved out of an
  installed context's collection is foreign: resuming it in a block is
  rejected even with that context injected (any code using the context may
  have put any coroutine there). An actor scheduler that resumes tasks it
  keeps in a context must therefore run outside inject blocks -- as
  `std::event_loop`'s `run`/`turn` do, which require the Driver.
* **Parameters are unprovable inside a block.** A block resuming a
  coroutine parameter of the function it is written in is rejected; a
  helper called *from* a block resuming its own parameter is fine (the
  parameter is substituted at the call).
* **A construction and its resume both report** when a coroutine built
  outside is passed to a wrapper constructed inside the block (the
  construction's eager first segment may run the wrapper's resume): two
  sites, two diagnostics.
* **Captured context values are values.** A closure *value* made outside a
  block that reads a context struct's value is a context-free function (as
  in CONTEXTS.md) and may be passed into a block. A direct call of a nested
  function that reads a context parameter is a use and is checked; a call
  through a value is not. A closure over a context-*trait* binding cannot be
  a value at all (the monomorphized program's CONTEXT-FUNCTION-VALUE).
* **Direct modules keep their ambient authority** inside blocks: a
  `direct module` is acknowledged raw authority, not context authority.
* **Event-loop API.** A restricted actor that waits on a channel needs
  `std::event_loop::Loop`, which also lets it register, post, set timers and
  revoke any registration: the Loop is all of the scheduler's
  non-Driver authority. A conceptual inbox needs less (section 16).
* **Identity granularity.** Injection names whole contexts; there is no
  partial context (a field, an operation subset of a trait). A trait with
  fewer operations is the way to inject less of an implementation.

## 16. Next milestone: what `std::actor` still needs

The mechanism is ready for a same-thread actor library to use: an actor is
a coroutine constructed inside `inject context ...:` with the authority the
spawner grants it, adopted by the scheduler, resumed by code that runs
outside every inject block. What remains:

* **An inbox capability that is not the Loop.** Waiting on a registration
  requires the Loop context today (`std::event_loop::wait(reg, context ev:
  Loop)`), so a contextless calculator cannot wait for a message. The actor
  library needs an opaque `Inbox[M]` value -- a registration plus the typed
  queue it receives -- whose wait yields to the scheduler without the actor
  holding the Loop: either an `std::event_loop` operation on a value, or a
  narrower context trait the scheduler installs (one operation: wait on my
  inbox).
* **Typed addresses and replies.** `Address[M]` and reply capabilities as
  values: explicit delegation through a typed channel.
* **Spawning under a policy.** `spawn` as an ordinary function whose
  argument is constructed inside the caller's own inject block: the
  spawner's grant is the actor's authority; the library needs no new
  language support for it.
* **Supervision, failure and shutdown** of actors whose handles the
  scheduler owns in its context: the scheduler resumes them outside any
  block, so retained authority is never a question there.
* Cross-thread actors (sendability, per-thread runtime state) are the
  census's M2-M4 and unchanged by this milestone.

## 17. Files, and what to run when changing this

| file | what |
|---|---|
| surface/parser.tcl | `AtInject`, `Injection`, the statement and value positions |
| surface/ast.tcl, surface/recover.tcl | the `inject` node: ids, children, print-back, recovery |
| surface/modules.tcl | `Walk`: the injected types' qualified references |
| surface/lower.tcl | the `inject` case: `if true:` with `inject` |
| hir/resolve.tcl | the `if` case: `injects` |
| hir/injection.tcl | resolution, grants, the checks, the provenance analysis, the summary |
| hir/contexts.tcl | grants in `Requirements`, the `inject` reason in `ChainLines`, installation inside a block, `-contexts` |
| hir/hir.tcl | the file's load and `hir::injection::verify` in `CheckOnce` |
| hir/methods.tcl | the two obligation kinds |
| hir/format.tcl, hir/read.tcl | HIR text |
| hir/static.tcl, stdlib/compiler.bot, stdlib/test.bot | the three codes, and their `std::test::code_name` spellings |
| compilerpedia/topics/ | `concept.context-injection`, `error.context-not-injected`, `error.context-retained-authority`, `error.duplicate-injected-context` |
| tests/restricted-injection.test | the tests |
| audit/restricted-injection/tools/ | the mutation harness and its mutants |
| audit/golden/migration/census/restricted-injection.tsv | the tests' census rows |

Run `tests/restricted-injection.test`, `tests/contexts.test`,
`tests/context-traits.test`, `tests/coroutines.test`,
`tests/static-compile.test`, `tests/method-resolution.test`,
`audit/restricted-injection/tools/mutate.tcl` (every mutant must still apply
and be killed by a test its `!!` line names) and `tools/compilerpedia.tcl
check`; AGENTS.md, "Restricted context injection", has the rules to keep.
