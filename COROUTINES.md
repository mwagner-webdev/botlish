# COROUTINES.md

Botlish's first coroutine milestone.

> A coroutine is an eagerly started, affine resumable computation. `yield`
> may occur arbitrarily deep in its synchronous call stack. Construction runs
> immediately to the first outward `yield`, normal return, or unhandled
> `fail`; each later call resumes to the next such boundary. The resume
> channel is statically fixed to zero values or one structured message value.
> Coroutine handles are movable but never implicitly copyable or aliased.

The architectural theorem the milestone establishes:

> `yield` is a statically tracked deep control effect; `coroutine` turns one
> exact yielding execution into an eagerly started affine value whose unique
> continuation may be resumed with one fixed structured message protocol until
> it reaches a stable terminal result or error.

COROUTINE-PREREQUISITES.md is the research this builds on (what each backend
already provided, the roadblocks); this document is what was built.

## Contents

* [The principal program](#the-principal-program)
* [Report](#report) -- the 61 points of the milestone report, in order
* [Files](#files)

## The principal program

```botlish
struct Message:
    value: int

struct Event:
    value: int

fn deep(base: int, resume Message) -> int:
    message = yield Event {value: base}
    message.value

fn worker(base: int, resume Message) -> Event:
    x = deep(base)
    message = yield Event {value: x}
    return Event {value: message.value}

coroutine {step, first} = worker(10)

second = step(Message {value: 20})
final = step(Message {value: 30})
again = step(Message {value: 999})
[first, second, final, again]
```

evaluates to `[Event {value: 10}, Event {value: 20}, Event {value: 30},
Event {value: 30}]` on every backend (Tcl interpreter, Tcl compiler,
Cranelift generic and specialized, and an AOT executable):

* construction enters `worker`, then `deep`; `deep` yields `Event(10)`, the
  whole stack (`deep` over `worker` over the coroutine's entry) is suspended,
  and `first` is `Event(10)`;
* the first resume makes `deep`'s yield evaluate to `Message(20)`; `deep`
  returns 20; `worker` yields `Event(20)`: `second`;
* the second resume makes `worker`'s yield evaluate to `Message(30)`;
  `worker` returns `Event(30)`: `final`, and the coroutine is completed;
* the third call runs no body code and returns the cached `Event(30)`.

```botlish
other = step
step(Message {value: 1})
```

is rejected at compile time:

```
<file>:18:1: `step` was used after its coroutine value was moved

moved here:
    other = step  (<file>:17:1)

used here:
    <file>:18:1 (CORE SEMANTIC USE-AFTER-MOVE)
```

while `other(Message {value: 1})` is valid and continues the same
coroutine. An empty-loop coroutine completes during construction without any
error; an unhandled `fail` in a segment crosses the construction or resume
call through the ordinary error channel and leaves the coroutine terminally
failed; there is no exhaustion condition; no handle is ever copied; and a
coroutine is not an iterator. `tests/coroutines.test`'s `co-principal`,
`co-principal-move`, `co-empty-loop`, `co-errors-*` and `co-source-*` pin
each statement.

## Report

### 1. Coroutine-construction grammar

```
simple        = binding | destructure | coroutineBind | return | break | ...
coroutineBind = "coroutine" "{" coField { "," coField } [ "," ] "}"
                "=" valueOrHandled
coField       = ( "step" | "first" ) [ ":" IDENT ]
```

`surface/parser.tcl` (grammar comment at its top; `CoroutineAhead`,
`CoroutineBind`). The right side is an ordinary value or a handled value:
`coroutine {step, first} = worker(x):` followed by `on E:` handlers, which
handle the construction (the first segment). The fields are exactly `step`
(the handle) and `first` (the first outward result), each at most once
(`DUPLICATE-FIELD`), each optionally renamed (`{step: next, first:
initial}`), either omitted. Every other form is its own coded syntax error,
`COROUTINE-BINDING-FIELD`: an unknown field (`{foo}`), a nested pattern
(`{step: {a}}`), the positional form (`coroutine (a, b) = ...`) and the
sugar `coroutine step = worker(x)` (with a message naming the braced
spelling). The right side is not checked by the parser to be a call: a
non-call (or a call of something that cannot yield) is HIR's
`COROUTINE-RHS-NOT-YIELDING`. An `if`/`loop` right side is a syntax error
(the right side is one value, not a block).

### 2. Resume-clause grammar

```
params       = [ ordinarySection ] [ "," flagSection ] [ "," contextSection ]
               [ "," resumeClause ] [ "," ]
resumeClause = "resume" typeExpr
```

The resume clause is the last entry of a parameter list (after ordinary
parameters, flags and context parameters): `fn worker(initial: str, flags
:verbose, context out: Out, resume StepInput) -> Event`. A function has at
most one ("a function declares at most one resume clause"), an entry after
it is an error ("the resume clause must be the last entry of the parameter
list, found name "b" after it"), and a trait requirement cannot have one (a
coroutine protocol is not a trait operation). The type must be a declared
struct type: anything else (an Int, a String, a List, an anonymous struct)
is `COROUTINE-RESUME-TYPE` at the type (`hir/resolve.tcl`'s
`ResolveResume`).

### 3. Contextual-keyword behavior

* `yield` is a keyword (`surface/lexer.tcl`): `yield = 3` is a syntax error.
  It never named anything before, and an expression form that suspends must
  not be shadowable.
* `coroutine` is contextual: it starts a coroutine binding only when
  directly followed by a braced field group and `=` (`CoroutineAhead`), and
  stays an ordinary name everywhere else: `coroutine = 3`, `coroutine + 1`,
  and the namespace in `coroutine::done?(h)`.
* `resume` is contextual: it is the resume clause only when directly
  followed by a type (a name or `unit`; `ResumeMarker`). `fn f(resume)`,
  `fn f(resume: int)` and `resume(4)` keep their meaning.

`co-syntax-contextual`, `co-syntax-resume-clause`.

### 4. AST representation

`surface/ast.tcl`:

| node | fields | printed |
|---|---|---|
| `yield` | `value` | `(yield (binary + (name a) (int 1)))` |
| `coroutinebind` | `pattern` (destructure-shaped `{span fields}`; each field `name` is `step` or `first`, `local` its binding name), `value` (the call) | `(coroutine {step: s, first: f} (call (name w) (int 4)))` |
| `function` | `resume`: `""` or `{type TYPE typeSpan SPAN span SPAN}` | `fn f (a:int flags :x resume T)` |

A handled construction prints as a statement with its handlers, like a
handled binding.

### 5. HIR representation

No new HIR node kind. Every coroutine operation is a call of an internal root
native (`core/coroutines.tcl`), so every analysis that does not care about
coroutines sees an ordinary opaque native call (`surface/lower.tcl`):

```
yield V                      call ^coroutine#yield V
coroutine {step, first} = worker(a)
                             bind coroutine#N#arg1 a
                             bind step (call ^coroutine#create THUNK)
                             bind first (call ^coroutine#start (ref step))
                             unit
                             THUNK = (block {} (call worker (ref coroutine#N#arg1)))
step(m)                      call ^coroutine#resume (ref step) m
coroutine::done?(step)       call ^coroutine::done? (ref step)
fn f(..., resume T)          block ... resume {T ORIGIN}  (declaredResume once resolved)
```

`#` cannot be spelled by source, so the temporaries and the internal natives
are hygienic. A literal argument stays in the thunk (no temporary); a
method-call construction binds its receiver first. `step(m)` is written as an
ordinary call; resolution rewrites it (`hir/resolve.tcl`'s
`CoroutineResume`) when the callee is a reference to a binding that holds a
handle by construction (`IsCoroutineBinding`: bound to a `coroutine#create`
call, or to a reference of such a binding -- a move).

Analysis results live in the side table `coroutines` (`hir/coroutines.tcl`):

| key | meaning |
|---|---|
| `blocks` | yield-capable function -> `{protocol P yieldType T reason R}` |
| `thunks` | thunk block -> `{create CALL root FUNCTION call ROOTCALL}` |
| `boundaries` | a thunk's root call -> the thunk |
| `yields` | yield call -> its function (`""` at the top level) |
| `edges`, `direct` | the exact call graph, each function's own yields |
| `mayYield`, `next` | after verify: the reachable yield effect, and each function's next step towards a yield |
| `moves` | move binding statement -> the binding moved from |

The debug text (`main.tcl -hir`, `hir/format.tcl`, read back by
`hir/read.tcl` to the same text) states each yielding function's effect, the
handle's type and every move:

```
e2 block s3 (b2 base:int) captures () declares int resume Message coroutine-effect (yields Event, resume Message) ...
    e4 call native(coroutine#yield) : Message
e25 bind b10 step : Coroutine{resume: Message, yield: Event, errors: []}
    e26 call native(coroutine#create) : Coroutine{resume: Message, yield: Event, errors: []}
        e28 block s5 () captures (b5 worker) : block(e28)/0 -> Event
e32 bind b12 first : Event
    e33 call native(coroutine#start) : Event
e38 call native(coroutine#resume) : Event
e37 bind b14 other : Coroutine{resume: Message, yield: Event, errors: []} move
```

(`co-hir-text`.)

### 6. Coroutine effect representation

A function's coroutine effect is the pair (outward type, resume protocol):
`coroutine-effect (yields Event, resume Message)` in HIR text,
`hir::coroutines::EffectText`. It is derived, never declared: the protocol
from the fixed point (point 8), the outward type from the yields the function
can reach (point 9). A function whose effect is empty does not print one.
Being *in* the effect (may yield) is reachability-based and recorded in
`mayYield` (point 8); the protocol is computed over every syntactic call edge
(it is needed by type inference, which runs before reachability is known).

### 7. Direct-yield analysis

`hir::coroutines::analyze` (run first in `hir::CheckOnce`, before type
inference) walks the program once (`hir::contexts::Walk`) and records every
`coroutine#yield` call with its function -- the innermost enclosing function
body, never a nested function's. A yield in top-level code has no function:
`YIELD-OUTSIDE-FUNCTION` (`co-yield-outside-function`). After type
inference, `verify` keeps the direct yields that are reachable
(`dict get $hir exprs $y reachable`): an unreachable yield does not make its
function yielding (`co-effect-unreachable`).

### 8. Transitive-yield fixed point

The exact call graph is syntactic: a call whose callee denotes one function
(a function literal, a binding denoting one, a module function:
`hir::contexts::Callee`), excluding each thunk's boundary call. A call
through a function value is no edge, which is sound because a function that
may yield never becomes a value (point 37).

`verify` computes the reachable yield effect breadth-first from the
functions with a reachable direct yield: a function may yield if it has a
reachable direct yield or a reachable call of a function that may yield. The
breadth-first order gives every function its first step towards a yield
along a shortest chain, in call order (`next`), which the diagnostics print
(point 21). A self-recursive function is an ordinary edge to itself and
converges like any other (`co-effect-recursive`); mutual recursion needs
bindings visible before their definition, which the language does not have
(MUTUAL-RECURSION.md).

The construction boundary stops the effect: a function that constructs a
coroutine of a yielding function does not yield itself and may be called
anywhere (`co-effect-nested-isolation`, `co-effect-nested-coroutines`).

### 9. Yield output-type inference

A yield expression's *value* is the resume message (point 10). What it
*sends* is the outward value, and a coroutine's outward type is its root's
(point 19). Per function, `hir::coroutines::YieldTypes` collects the sent
values' types of every yield the function can reach (its own and its
callees', transitively); `EffectText` shows their join. Helpers are not
given an outward type of their own: one helper reached by coroutines of
different roots sends to whichever is running, and each root checks every
yield it can reach (point 19).

### 10. Resume-type inference

The protocol of each yield-capable function is a least fixed point over the
lattice `none < {unit, T1, T2, ...} < conflict` (`hir::coroutines::Solve`),
bottom-up over the call graph. A function's local constraints are:

* a declared `resume T`;
* a use of one of its yields' values as the argument of an exact call whose
  parameter is declared with a struct type `T` (use-site inference:
  `consume(m)` with `fn consume(m: In)` makes the function's protocol `In`);

and every yielding callee's protocol is a constraint too. The first fixed
point runs; then every function still `none` whose yield's value is *used*
(not discarded: `Discarded`, which treats statement position, the last
statement of a discarded `if`/handler/collecting loop, and a plain `loop:`
body as discarded) defaults to the zero-message protocol `unit`, unless that
use is a field projection (`m.v`), which needs a declared type
(`COROUTINE-RESUME-UNDERCONSTRAINED`, naming the projection); a second fixed
point lets the defaults reach their callers. A root still `none` (every
yield it reaches discards its value) resolves to `unit`.

Two different constraints meeting in one function are
`COROUTINE-RESUME-CONFLICT`, explained through both chains:

```
both needs two different resume protocols, and one coroutine has exactly one
(no union is inferred: declare a struct with the fields both need, or split the coroutine):
    resume A: it calls ha (<input>:14:19), which declares it
    resume B: it calls hb (<input>:14:26), which declares it
```

There is never a union, never a widening to `any`, never an inferred
anonymous struct (`co-protocol-*`). A function whose own yields all discard
their values adapts to its callers' protocol; if both a zero-message and a
struct-protocol coroutine can reach it, its yields' values are typed `any`
-- they are discarded, so nothing observes it (`co-protocol-unconstrained-
helper`, `co-protocol-discarded-collections`).

### 11. Explicit resume validation

A declared `resume T` is resolved where it is written: it must name a declared
struct type (`COROUTINE-RESUME-TYPE` otherwise, located at the type; point
13), and it is one more local constraint of the fixed point, so it must agree
with every use and every yielding callee (`COROUTINE-RESUME-CONFLICT`).
Within the function, each yield evaluates to `T` and every use of it is
type-checked as an ordinary `T` value. At each resume, the message argument
must be a subtype of the protocol type (`TYPE`: "the resume message of this
coroutine must be a Message, got Event"; `co-protocol-wrong-type`).

### 12. Zero-message protocol

A coroutine whose root's protocol resolves to `unit` takes no message:
`step()`; every yield evaluates to `unit`. `step(x)` is
`COROUTINE-RESUME-ARITY` ("this coroutine has the zero-message protocol:
resume it with no argument, "step()", got 1 argument(s)"), and a struct
protocol's `step()` or `step(a, b)` is the same code ("this coroutine is
resumed with exactly one Message message: "step(Message {...})"").
`co-protocol-zero-message`, `co-protocol-arity`. Natively the zero-message
resume is its own operation (`coresume0`).

### 13. Structured-message restriction

A protocol is one named struct type or nothing: never a scalar, a String, a
List, an anonymous struct, a union or a multi-value message. Several values
travel as the fields of one struct ("put several values in the fields of a
struct"). `co-protocol-struct-only`.

### 14. Deep-yield call-stack semantics

A yield suspends the *whole* coroutine: every frame between the coroutine's
entry and the yield stays as it is, at any depth, and resuming continues the
innermost one, whose callers then return in turn (`co-deep-three-levels`:
`deepest` under `middle` under `worker`). A yield is legal in any function
that runs inside a coroutine -- in a loop, a branch, an on-handler, a
recursive call (`co-effect-loop-branch`, `co-effect-handler`,
`co-effect-recursive`). A coroutine started inside another coroutine's
segment is independent: its yields suspend only itself
(`co-effect-nested-coroutines`).

### 15. Eager construction order

`coroutine {step, first} = worker(a, b)`:

1. evaluates `a`, then `b` (a method call's receiver first), exactly as an
   ordinary call evaluates its arguments, before the coroutine exists;
2. creates the handle (nothing runs);
3. starts it: runs `worker(a, b)` to its first outward boundary;
4. binds `step`, then `first`.

`co-binding-eager-order` observes the order through a MutableArray: the
arguments' side effects precede the body's, and the body's effects up to the
first yield have happened when the statement completes.

### 16. First-yield construction behavior

The start runs the body to its first yield: `first` is that yield's outward
value, the coroutine is suspended at it, and `coroutine::done?(step)` is
`false`.

### 17. Return-before-yield behavior

A body that returns before any yield (an empty loop, an early return)
completes during construction: `first` is its final result, the coroutine is
completed, `done?` is `true`, and every later call returns that result again.
It is not an error and not an "empty" or "exhausted" state
(`co-empty-loop`, `co-terminal-success`).

### 18. First-result binding / destructuring

The binding names the two results of a construction without building any
two-field value: `step` is the handle the create call returns, `first` the
start call's value (two separate HIR bindings). Natively the construction of
`coroutine {step, first} = t(1)` allocates exactly the coroutine object and
the yielded struct -- no List, no struct for the pair, and no Block (a
thunk over literal arguments is a static closure)
(`co-binding-no-aggregate`). Either field may be omitted: an omitted `step`
binds the handle to a hygienic temporary (the coroutine still runs eagerly
and is then abandoned); an omitted `first` leaves the start's value unbound.

### 19. Root outward-type rule

A coroutine's outward type is its root's: the root's declared result type,
else the one type among its own returns and every yield it can reach that
all the others are subtypes of. Every yield reachable from the root (deep
ones included) and every return must fit it, otherwise
`COROUTINE-RESULT-MISMATCH` at the construction: against a declared result
it names the offending yield ("the yield at <file>:9:5 sends a int"),
otherwise it lists the types a segment can end with
(`co-result-mismatch`). `first` and every resume are typed with it.

### 20. Helper return-vs-yield distinction

Only the root's return is an outward value (the final result). A helper's
`return` (or result) goes to its caller as from any call: `deep` returns
`int` while the coroutine's outward type is `Event`. A helper's yields send
outward values of the root's outward type. The two never mix: a helper does
not become a "generator of its return type".

### 21. Unwrapped-yield diagnostics

A yielding call graph entered without a coroutine boundary is
`UNWRAPPED-YIELD`, with the shortest call chain to a yield:

```
<file>:17:1: outer may suspend, but this call does not start a coroutine
(start it with "coroutine {step, first} = outer(...)", or call it from a function that runs inside a coroutine):
    outer, which calls worker at <file>:16:12
     -> worker, which yields directly at <file>:13:15 (CORE SEMANTIC UNWRAPPED-YIELD)
```

It is reported for a reachable call from top-level code of a function that
may yield, and for a function that may yield used as a value (an unknown
call could run it outside every coroutine; `co-effect-function-value`). A
call from a function that is itself yielding is legal: that function runs
inside a coroutine or is itself reported where it is called.

### 22. Ordinary error propagation

There is no coroutine-specific error channel. A segment (the start or a
resume) completes like a call: normally with an outward value, or with the
error the body left unhandled -- the same declared error, raised at the
`coroutine#start`/`coroutine#resume` call, handled by `on E:` handlers on
the construction or the resume, or admitted by the enclosing function's
`errors` declaration. Statically, a segment may produce what its
coroutine's root call may (`hir/completions.tcl`'s `NativeCallFacts`: the
effective errors of the thunk, exactly as for an exact call, so a failure
the root handles internally is no obligation), and the legality rule is the
ordinary one; unhandled, it is `UNHANDLED-ERROR`, named as the operation:
"this coroutine construction may produce the declared error "Broken"",
"this coroutine resume may produce ..." (`co-errors-declared-propagation`).
A root that always fails after yielding is not a statically known failure:
its segments may complete normally by yielding (`co-errors-last-segment-
always-fails`). Type inference charges the handle's error set
(`Coroutine{..., errors: [E]}`, the root's declared errors) to every
segment call, so handlers type as on any call.

### 23. Startup-error behavior

An unhandled `fail` before the first yield crosses the construction: its
handlers run (their value is `first`), and the coroutine is failed
(`co-errors-startup`). A later call raises the same error again without
running anything.

### 24. Resume-error behavior

An unhandled `fail` in a later segment -- at any depth -- crosses the resume
call that ran that segment, with the same handler and legality rules
(`co-errors-segment`). A failure handled inside the coroutine never reaches
the resume (`co-errors-internal`). A native stack overflow on a coroutine's
own stack is the ordinary `NATIVE LIMIT STACK` (`co-errors-uncaught-native-
limit`).

### 25. Terminal successful state

When the root returns, the segment's result is the final value, the
coroutine is `completed`, its continuation is gone (the Tcl coroutine has
returned; natively the stack is released to the pool) and its thunk is
dropped.

### 26. Terminal failed state

When the root fails, the coroutine is `failed` and keeps the error: in the
Tcl runtime the failure completion (or the Tcl error with its options), in
the native runtime the `RtError` and its declared-error id.

### 27. Repeated call after success

Every later call returns the cached final result -- the very value the body
returned (`co-terminal-identity`: a nested aggregate kept whole) -- and runs
no body code (`co-terminal-success` counts body side effects). There is no
exhaustion error.

### 28. Repeated call after failure

Every later call raises the cached error again (same name, same handler
behavior) and never runs the body (`co-errors-startup`, `co-errors-segment`).

### 29. `coroutine::done?`

`coroutine::done?(h)` (a qualified root native; `import coroutine`, like
every standard intrinsic) is `true` exactly when the coroutine is completed or
failed. It observes the handle without consuming it (`co-affine-done-does-
not-move`).

### 30. Coroutine handle compiler type

`{coroutine RESUME OUTWARD ERRORS}` in HIR (`hir/types.tcl`), shown
`Coroutine{resume: Message, yield: Event, errors: [Broken]}`: the resolved
protocol (`unit` or a named struct type), the outward type, and the root's
declared errors. It is a specific type (`IsSpecific`) with no source
spelling (the `Coroutine{...}` notation exists only so that HIR text can state
and read back a handle's type), and its values have no equality and no hash
(`core/value.tcl`'s kind `coroutine` is excluded from both; natively too).

### 31. Affine binding representation

There is no affine type or annotation: a binding is a *handle binding* when
its type is a coroutine type. Its ownership state lives only in the static
analysis (`hir::coroutines::Affine`): per binding `live`, `{moved BIND}` or
`{maybe BIND...}`. Nothing is recorded at run time (no moved sentinel; point
66).

### 32. Move operation

`other = step` -- a binding whose value is a reference to a handle binding --
moves the handle: `other` is the new owner, `step` is dead from then on. At
run time a move is an ordinary binding of the same reference (natively a
register copy); there is no move operation, no copy and no fork. A moved
handle continues the one coroutine where it stopped
(`co-affine-move-never-forks`).

### 33. Use-after-move analysis

Every reference to a handle binding has a role (`RefRole`): a *use* (the
handle of a resume, of `done?`, or a reference in statement position), a
*move* (the value of a binding statement), *storage* (point 36) or a
*function* position (point 37). The forward dataflow walks each region (the
top level, every function body) in order; a use or move of a binding in
state `moved` is `USE-AFTER-MOVE`, naming the move and the use (the
principal program above). Each owner in a move chain is dead after its own
move (`co-affine-move-chain-use-after`).

### 34. Control-flow liveness joins

At an `if` or handler join, a binding moved on some paths only is `{maybe
...}`: a later use is `AFFINE-NOT-DEFINITELY-LIVE`, naming every move that
can reach it (`co-affine-branch-join`). A path that cannot complete
(`return`, `fail`, `break`, `continue`, a `never`-typed expression) does not
reach the join: a move in a branch that returns leaves the handle live on
the remaining path (`co-affine-terminating-branch`). A loop body is iterated
to a fixed point with its `continue` states, and its `break` states join
the exit, so a move inside a loop reaches the next iteration
(`co-affine-loop`). Bindings declared inside a loop body are per iteration.

### 35. Consume-and-replace resume semantics

Resuming consumes the coroutine's current continuation and replaces it with
the next one (or with the terminal state), behind the same handle: the call
is a use, not a move, so `step` stays the owner across any number of
resumes, in sequence or in a loop (`co-affine-loop`,
`co-affine-done-does-not-move`). Only the handle names the continuation;
there is never a second name for it.

### 36. Unsupported affine storage frontier

A handle can be bound, moved to another local binding, resumed and observed.
Everything else is `COROUTINE-STORAGE-UNSUPPORTED`, with what it would have
been (`co-storage-frontier`, `co-storage-equality`):

* a List element; a struct field; the value of a `return`, of a function, of
  an `if`, a handler or a loop; the program's result;
* an argument (it would be erased to a value another function could keep),
  equality included;
* a capture by a nested function (point 38);
* a module binding (module values are immutable and shared; a module's top
  level cannot even construct a coroutine: `INVALID-TOPLEVEL`,
  `co-storage-module`).

### 37. Function-value interaction

A handle is not a function value: passing it where a structural `Fn` is
expected is `COROUTINE-NOT-FUNCTION` ("it carries the evolving state of one
coroutine and cannot be passed where a function value of type
Fn{args: [], return: T, errors: []} is expected"; no second, type-level
diagnostic). A *function that may yield* cannot become a value either
(`UNWRAPPED-YIELD` at the reference, point 21): a call through a value is
not a call-graph edge, so the effect could not follow it.

### 38. Closure interaction

A handle cannot be captured by a nested function (`COROUTINE-STORAGE-
UNSUPPORTED`): a closure is a value that may be stored, copied and called
repeatedly, which would alias the handle. A *thunk* captures the
construction's argument temporaries, never a handle. A nested function may
itself construct, drive and drop its own coroutines.

### 39. Context interaction

Contexts are fixed at creation: a coroutine's code runs with the providers
its construction selected. With contexts that are installed once and never
replaced (CONTEXTS.md), a context *value* is the same for every segment; for
context *traits* (CONTEXT-TRAITS.md) selection is static at the construction
(the top-level call), and a resume is no call that selects anything: a
context implementing the same trait installed between two resumes changes
nothing, while a new construction there is
`AMBIGUOUS-CONTEXT-IMPLEMENTATION` (`co-context-fixed-at-construction`).
`hir::contexts::Callee` treats a construction as a call of its thunk, so the
thunk's root's requirement is checked at the construction like any call's.
With the real portable output trait (`io::IO`, lib/io.bot) and a substitute
context whose writes fail beyond a length limit, `io::print_line` called
deep inside a coroutine writes through the provider in every segment, and a
write failure after a resume crosses that resume and stays the coroutine's
terminal error (`co-context-portable-io`, every backend); with
`linux::io::LinuxIO`, a standalone executable prints from inside a
coroutine before and after a yield, in segment order, also under GC stress
(`co-executable-linux-io`).

### 40. Trait/context-specialization interaction

Both are resolved before any backend runs, and coroutines take part as
ordinary code. A trait-polymorphic yielding function is monomorphized into
an ordinary yielding clone (`co-trait-polymorphic`); a yielding function that
requires a context trait is cloned for the selection, and every operation
becomes a direct call of the selected implementation (`co-context-trait`).
The thunk is a boundary, not an owner: build 2's plan treats the thunk's call
as its enclosing code's call (`hir/traits.tcl`'s `OwnerBlock` skips thunks),
so the thunk calls the clone. Native evidence (`co-context-trait-native`):
the yielding clone of `deep` takes no context argument, calls the
implementation directly, and no `callvalue` appears -- suspension adds no
dictionary, slot or indirect call.

### 41. Suspended-frame representation

* Tcl backends: one Tcl coroutine per Botlish coroutine (Tcl 9's NRE runs
  both the evaluator and generated procs without C-stack recursion,
  COROUTINE-PREREQUISITES.md §2). The suspended frames are the Tcl
  coroutine's own frames; the store entry
  (`core::coroutines::store`, `ID -> {state thunk ?continuation? ?value?
  ?failure?}`) holds the continuation command.
* Native: a stack of its own per started coroutine -- an 8 MiB anonymous
  mapping (`MAP_NORESERVE`: address space, pages committed as touched;
  `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` overrides it) with a 64 KiB
  `PROT_NONE` guard below. A suspended coroutine's frames simply stay on that
  stack; the coroutine object (`CoroutineObj`, 96 bytes) holds the saved
  stack pointer. Switching (`bl_co_switch`, x86-64 assembly) saves the SysV
  callee-saved registers and the MXCSR/x87 control words on the current
  stack, behind a standard frame record, so a suspended stack's frame chain
  starts at `saved_sp + 48` and is read by the ordinary frame walker.

### 42. GC tracing of suspended state

Native (`runtime/heap.rs`, `runtime/vm.rs`, `runtime/framewalk.rs`):

* running coroutines form a chain (`Vm::co_current`, each one's `resumer`);
  every running coroutine object is a root, and the collector walks the
  current stack, then each resumer's stack from where it switched away
  (`framewalk::walk_from`, bounded by that stack);
* a suspended coroutine is reached through its handle like any object:
  marking it walks its suspended stack with the same precise stack maps as
  the main stack (every coroutine operation is a GC safepoint:
  `ops::op_may_allocate` classifies them as possibly allocating, so every
  caller of a function that may yield has its live values in stack maps);
* an unreachable suspended coroutine is swept: its stack goes back to the
  pool, nothing on it runs (no frame owns a Rust value with a destructor).

`co-gc-suspended-stacks`, `co-gc-stress` and the Rust runtime tests run
collections from inside other coroutines' segments and from the main
program while values live only in suspended frames at several depths.

### 43. Terminal-result/error tracing

The cached final result is the transport slot (`value`) and is traced as a
field; a cached failure's values (`RtError::values`) are traced too; the
thunk is dropped (`UNIT`) at termination, so its captures become garbage.
In the Tcl backends the store entry keeps them, and the per-run store
(`core::coroutines::fresh`) is dropped with the program run, deleting any
Tcl coroutine left suspended.

### 44. Interpreter implementation

`core/coroutines.tcl`, registered as natives, used unchanged by the
interpreter and the Tcl compiler:

* `coroutine#create(thunk)` allocates `{coroutine ID}` with state `fresh`;
* `coroutine#start(h)` runs `coroutine ::core::coroutines::coID Body ID`;
  `Body` invokes the thunk through `core::callable::invoke` (so the body's
  completion arrives at the boundary as a completion);
* `coroutine#yield(v)` checks `info coroutine` against the running stack
  (`YIELD-OUTSIDE-COROUTINE` otherwise -- unreachable from checked source)
  and calls Tcl `yield {yielded V}`;
* `coroutine#resume(h, ?m?)` resumes the continuation with the message;
* `Segment` records `running` while a segment runs, then `suspended`,
  `completed` or `failed` from the outcome (`{yielded V}`, `{done
  COMPLETION}`, or a Tcl error), and returns the segment's completion;
* start and resume are `-completion 1` natives (`core/native.tcl`): their
  implementation returns a completion, so a body's declared error crosses
  the call as the ordinary propagate-error completion;
* `core::coroutines::fresh` gives each program run its own store, deleting
  leftover Tcl coroutines at the end.

### 45. Tcl compiler implementation

The Tcl compiler compiles the same native calls; the completion natives go
through the generic call path (`compiler/compiler.tcl`'s
`CompileNativeCall`), never the direct native call (which assumes a plain
value), and `core::compiler::evalHir` wraps a run in `fresh` like the
interpreter. Generated procs run inside the Tcl coroutine exactly like the
evaluator.

### 46. Native implementation

* NIR (`native/src/nir.rs`): `op cocreate THUNK`, `op costart H`,
  `op coresume H M`, `op coresume0 H`, `op coyield V`, `op codone H`
  (`native/lower.tcl` maps the five natives). An environment-free thunk is a
  static closure (`fnvalue`); one capturing temporaries is an ordinary
  closure.
* Code generation (`native/src/codegen/clif.rs`): each is a call of a runtime
  helper (`rt_co_*`); start/resume/yield are fallible (a 0 result means the
  pending error), and all but `codone` are allocation sites, hence
  safepoints.
* Runtime (`native/src/runtime/coroutine.rs`): `rt_co_start` maps (or takes
  from the pool) a stack, lays out an initial frame that "returns" into
  `bl_co_trampoline`, and runs the first segment; `co_body` calls the thunk's
  generic entry, records the terminal state and switches back for good;
  `rt_co_yield` stores the outward value in the transport slot and switches
  to the resumer; `rt_co_resume` stores the message and switches in.
  `segment` links the chain for the GC and publishes the running stack's
  bounds to the stack-overflow guard on every switch, so an overflow on a
  coroutine stack is the ordinary `NATIVE LIMIT STACK`.
* AOT executables link the same runtime; the principal program and a program
  printing through `io::print_line` from inside a coroutine run as
  executables, also under `BOTLISH_NATIVE_GC_STRESS=1`.
* Hosts: x86-64 Linux. Elsewhere `rt_co_start` reports `NATIVE UNSUPPORTED`
  (no stack switch exists there yet; COROUTINE-PREREQUISITES.md R3).

### 47. Deep-yield backend evidence

`co-nir-operations` reads the NIR of the principal program plus a move and a
`done?`: the program's code is exactly `cocreate` (1 operand), `costart`,
`coresume` (handle, message), `codone`, each on the one handle register (the
move copies no state and creates no operation); `deep` contains the
`coyield`, and `worker` reaches it through an ordinary direct `call` --
nothing in the generated code of a deep frame knows it may be suspended:

```
func 0 "<program>"
    %0 = fnvalue 3
    %1 = op cocreate %0
    %2 = op costart %1
    %7 = op coresume %1 %6
    %20 = op codone %1
func 1 "deep" params=1
    %1 = structnew 1 %0
    %2 = op coyield %1
func 2 "worker" params=1
    %1 = call 1 %0
    %3 = op coyield %2
func 3 ""            (the thunk)
    %2 = call 2 %0
```

### 48. Empty-loop evidence

`co-empty-loop`: a coroutine whose loop runs zero times returns during
construction; `first` is its final result, `done?` is `true`, and calling it
again returns the same result -- on every backend, with no exhaustion and no
failure.

### 49. Error-boundary evidence

`co-errors-startup` (a fail before the first yield crosses the construction
and its handler runs), `co-errors-segment` (a deep fail after resumes
crosses the resume; later calls raise it again), `co-errors-declared-
propagation` (through a function that declares it; unhandled at the top it is
`UNHANDLED-ERROR` for the construction and for the resume),
`co-errors-internal`, `co-errors-last-segment-always-fails`, and
`co-effect-handler` (a yield inside an on-handler: resuming continues the
handler) -- every one on every backend.

### 50. Affine/no-alias evidence

The `co-affine-*` tests (moves, chains, branch joins, terminating branches,
loops, `done?` and resumes as uses) and the storage frontier tests are
static; `co-affine-move-never-forks` is dynamic: after `other = step` and a
second move, resuming the newest owner continues where the first stopped
(the results run 1, 2, 3, 4, 4: one continuation, never restarted or
duplicated), and `co-terminal-success` counts the body's side effects. The fuzzer moves handles in
a third of its programs and checks every resume's result. Mutation testing
(point 53) kills the aliasing, forking, non-invalidating-move and
lenient-join mutants.

### 51. Allocation/frame evidence

Per construction, natively (`bench/coroutines.tcl`, allocation report):
one `Coroutine` object (96 bytes: header, state, thunk, transport slot,
failure, stack, saved and resumer stack pointers, resumer), one `Block`
for a thunk that captures (48 bytes; none for literal arguments), and
whatever the body allocates (here one 40-byte struct per yield). No
aggregate for the binding's two results. A started coroutine's stack is 8
MiB of address space with the pages its frames touch committed -- one page
for a shallow suspension. See point 58 for the measurements.

### 52. Fuzzer design/results

`audit/coroutines/tools/fuzz.tcl` generates programs with a root and 0..3
helper levels, each body 1..5 statements over an accumulator chain: yields
(value discarded, passed to a struct-typed parameter, or projected under a
declared protocol), calls of the next level (handled or not), counted loops
of yields, branches, guarded fails and returns, nested generator coroutines,
and side effects folded into a checksum in a MutableArray. A driver -- at the
top level or in a function -- constructs (field forms and renames vary),
resumes 0..6 times with the protocol's messages, checks `done?` and moves
the handle; after every segment it reads the side-effect checksum.

The oracle shares no code with the compiler. Statically it computes the
transitive yield effect and the root's protocol (compared with the
compiler's `mayYield` and protocol). Dynamically it runs the generated
statements as one sequential computation fed the driver's messages in
order, with the explicit machine not-created -> suspended(at the Nth yield)
-> completed(value) | failed(error), the suspended frames being its own Tcl
stack; it derives every observed value: the first result, every resume's
result, the cached result or error after termination, every `done?` answer
and the checksum after every segment. Ownership (live/moved per binding) is
the driver's record. A third of the programs carry exactly one fault, with
the diagnostic class the oracle predicts: `USE-AFTER-MOVE`,
`AFFINE-NOT-DEFINITELY-LIVE`, `COROUTINE-RESUME-ARITY`, `TYPE`,
`COROUTINE-STORAGE-UNSUPPORTED`, `UNWRAPPED-YIELD`,
`YIELD-OUTSIDE-FUNCTION`, `COROUTINE-RESULT-MISMATCH`,
`COROUTINE-RESUME-CONFLICT`; a root that cannot yield is
`COROUTINE-RHS-NOT-YIELDING`.

Results (every run on all four backends unless noted; "accepted" programs
are compared value by value, "rejected" ones by diagnostic class):

| seeds | programs | accepted | rejected | disagreements |
|---|---:|---:|---:|---:|
| 1-100 | 100 | 54 | 46 | 0 |
| 3000-3099 | 100 | 55 | 45 | 0 |
| 7000-7099 | 100 | 49 | 51 | 0 |
| 1000-1199 (an earlier generator, before side effects) | 200 | 123 | 77 | 0 |
| 5000-5199 (an earlier generator, before deep programs) | 200 | 125 | 75 | 0 |
| 101-112 (`co-fuzz-bounded`, in the test suite) | 12 | | | 0 |

Every predicted diagnostic class occurred (in the final 300: `COROUTINE-RHS-
NOT-YIELDING` 51, `COROUTINE-RESUME-ARITY` 16, `COROUTINE-STORAGE-
UNSUPPORTED` 13, `AFFINE-NOT-DEFINITELY-LIVE` 14, `UNWRAPPED-YIELD` 14,
`YIELD-OUTSIDE-FUNCTION` 9, `COROUTINE-RESULT-MISMATCH` 9, `TYPE` 7,
`USE-AFTER-MOVE` 5, `COROUTINE-RESUME-CONFLICT` 4).

The fuzzer found two compiler bugs while it was written, both fixed with
tests: a yield that is the last statement of a discarded collecting loop
counted as a use of its value (a spurious protocol conflict), and a resume of
a coroutine whose protocol is a conflict crashed type checking (`conflict`
leaked as a type) instead of reporting the conflict alone.

### 53. Mutation results

`audit/coroutines/tools/mutate.tcl` applies each mutant of
`audit/coroutines/tools/mutants.txt` to a private copy of the compiler,
library and native backend (native mutants rebuild that copy) and runs
`tests/coroutines.test`, the fuzzer (25 programs, every backend) and, for
native mutants, the Rust runtime tests.

**31 mutants, 31 killed, 0 survived** -- every mutant item 62 of the
brief names, in each runtime where it can live, plus the native ones it
implies. What killed each (a test name, the number of failing tests, or the
number of disagreeing fuzz programs of 25, seed 11):

| mutant | `tests/coroutines.test` | fuzzer | Rust runtime tests |
|---|---|---|---|
| **construction-lazy**: construction does not run the body: the first resume starts it | 38 tests | 13/25 programs | -- |
| **first-yield-discarded**: construction runs past the first yield: its value is lost | 35 tests | 12/25 programs | -- |
| **return-before-yield-exhaustion**: a body that returns before yielding fails the construction as exhausted | `co-empty-loop`, `co-terminal-success` | survived | -- |
| **completed-raises-exhaustion**: a call of a completed handle raises an exhaustion error | 11 tests | 3/25 programs | -- |
| **completed-reruns-body**: a call of a completed handle runs the body again from its beginning | 10 tests | 3/25 programs | -- |
| **failed-resumes-body**: a call of a failed handle runs the body again | `co-context-portable-io`, `co-errors-last-segment-always-fails`, `co-errors-segment` | 1/25 programs | -- |
| **failed-loses-error**: a call of a failed handle completes normally with unit instead of raising the original error | 5 tests | 2/25 programs | -- |
| **message-wrong-yield**: each resume delivers the previous resume's message (the first, unit) | 14 tests | 6/25 programs | -- |
| **effect-one-caller**: the yield effect reaches the direct callers of a yielding function and no further | 7 tests | 2/25 programs | -- |
| **call-crosses-yield**: an ordinary top-level call of a yielding function is allowed | `co-unwrapped-chain` | 2/25 programs | -- |
| **protocol-widened-any**: every coroutine accepts any resume message: the handle's protocol is any | `co-hir-text`, `co-protocol-arity`, `co-protocol-wrong-type` | 2/25 programs | -- |
| **two-protocols-accepted**: a second, different protocol reaching a function is ignored (the first wins) | `co-protocol-conflict`, `co-protocol-default-meets-struct` | survived | -- |
| **scalar-resume-accepted**: a declared resume type need not be a struct | `co-protocol-struct-only` | survived | -- |
| **assignment-aliases**: binding a handle to another name is no move: both names stay usable | 5 tests | survived | -- |
| **assignment-forks**: binding a handle to another name starts a new coroutine of the same call: the new name runs a copy from the beginning | `co-affine-move-never-forks`, `co-fuzz-bounded`, `co-source-no-iterator-or-exhaustion` | 5/25 programs | -- |
| **move-keeps-source**: a move does not invalidate the binding moved from | 4 tests | survived | -- |
| **join-keeps-live**: a handle moved on one branch only is live after the join | `co-affine-branch-join`, `co-affine-loop` | survived | -- |
| **step-call-moves**: a resume consumes the handle: its owner is moved by the call | 27 tests | 12/25 programs | -- |
| **done-consumes**: coroutine::done? consumes the handle: its owner is moved by the query | 5 tests | 9/25 programs | -- |
| **handle-as-fn**: a handle is accepted where a structural Fn value is expected | `co-storage-frontier` | survived | -- |
| **handle-erased-to-any**: a handle is accepted as an argument of an untyped (any) parameter | `co-storage-equality`, `co-storage-frontier` | survived | -- |
| **context-reselected-per-resume**: every top-level resume selects the coroutine's context-trait providers again | `co-context-fixed-at-construction` | survived | -- |
| **native-construction-lazy**: construction does not run the body natively: the first resume starts it | 41 tests | 13/25 programs | 6 tests |
| **native-first-yield-discarded**: native construction runs past the first yield | 38 tests | 12/25 programs | 4 tests |
| **native-completed-raises-exhaustion**: a call of a completed handle raises an exhaustion error natively | 12 tests | 3/25 programs | `yields_resumes_and_keeps_its_final_result`, `return_before_any_yield_completes_at_the_start` |
| **native-completed-reruns-body**: a call of a completed handle runs the body again natively | 11 tests | 3/25 programs | `yields_resumes_and_keeps_its_final_result` |
| **native-failed-loses-error**: a call of a failed handle completes normally with unit natively | 5 tests | 2/25 programs | `a_failure_is_terminal_and_raised_again` |
| **native-message-wrong-yield**: a native resume does not deliver its message: the yield evaluates to its own outward value | 15 tests | 6/25 programs | 3 tests |
| **native-deep-stack-not-preserved**: a suspended coroutine's stack is released (pooled for reuse) while its frames are suspended on it | 5 tests | 4/25 programs | survived |
| **gc-suspended-frames-untraced**: the collector does not trace the frames of a suspended coroutine's stack | `co-gc-stress` | survived | survived |
| **gc-resumer-frames-untraced**: the collector does not trace the frames suspended below a running coroutine (its resumers' stacks) | `co-executable-linux-io`, `co-gc-many-coroutines`, `co-gc-stress` | survived | survived |

Notes:

* *assignment forks coroutine*: no backend has a copy of a continuation to
  give a fork (a Tcl coroutine and a native stack cannot be duplicated), so
  a fork of the *current* state cannot even be written -- and under the
  affine discipline it would be unobservable, since the source is dead. The
  mutant forks the *initial* state: a move starts a new coroutine of the
  same call. (The source audit also catches its new `coroutine#fork`
  spelling.)
* *deep stack not preserved*: frames between the root and a yield are never
  copied anywhere, so "not preserved" means "their stack is reused while
  they are suspended on it"; the native mutant returns a suspended stack to
  the pool. In the Tcl runtime the suspended frames are a Tcl coroutine's
  own; there is no stack to lose, so no Tcl mutant exists.
* The fuzzer alone misses a mutant only for constructs it does not generate
  (scalar or declared protocols, `Fn` parameters, contexts, collections
  under stress) or rarely produces with seed 11 (a return before the first
  yield, a second protocol in a passing program); each is killed by a
  focused test. The GC mutants need collections at the right moment:
  `co-gc-stress` (and `co-gc-many-coroutines`) kill them.
* No equivalent mutant survives.

### 54. Full regression

`tests/all.tcl` (tcltest, one child process per file, private `-tmpdir`
each), against the baseline (this branch's base commit `a382c10`, run the
same way in a separate worktree):

| run | baseline | with coroutines |
|---|---|---|
| interp (`CORE_BACKEND=interp`) | 6489 passed | 6553 passed, 2 failed (below), then 111/111 on rerunning the two files |
| compile (`CORE_BACKEND=compile`) | 6485 passed, 4 skipped (`coreScoping`) | 6554 passed, 4 skipped (`coreScoping`), 0 failed |
| GC stress (`BOTLISH_NATIVE_GC_STRESS=1`) | (CI) | 6558 passed, 0 failed |
| Rust (`cargo test --release`) | 187 lib + 31 bin | 194 lib + 31 bin passed |

The two interp failures were inventories that list every root native and
correctly noticed the new ones: `ns-root-inventory` (the internal `#`
natives, now also the four coroutine operations) and
`linux-syscall-native-registered` (qualified natives outside the value-family
namespaces; `coroutine` is a value family now). Both were updated (and
STDLIB-NAMESPACES.md lists the `coroutine` namespace); the compile and GC
runs, which reached those files after the update, passed them. Every suite
item 63 lists ran: traits, context traits, contexts, refinements, validators,
errors/completions, loops, method sugar, semantic instances, function values,
opaque structs, Bytes/MutableBytes, ABI numerics; the 69 new tests are
`tests/coroutines.test`.

The Rust coroutine tests also pass under `BOTLISH_NATIVE_GC_STRESS=1`. The
whole Rust suite does not run under stress, on the baseline either: two
pre-existing `ops.rs` tests (`a_mutable_storage_*`) hold heap values only in
Rust locals (the CI GC-stress job runs the Tcl suite, not the Rust tests).

### 55. Native coverage

`tests/native-coverage.tcl` (the whole suite on Cranelift, every test
classified):

| class | baseline (`a382c10`) | with coroutines |
|---|---:|---:|
| tests | 6489 | 6558 |
| native | 2535 | 2599 |
| independent | 3800 | 3832 |
| passed-partial | 67 | 67 |
| unsupported | 60 | 60 |
| failed | 27 (below) | 0 |

The baseline's 27 "failed" are the standalone-executable tests
(`*-executable-*`, `io-*`, `raw-*-gc-stress`, ...), whose linking failed in
the baseline's separate worktree with its copied `native/target`
("executable link failed"; an artifact of that copy, checked on
`raw-count-loops-gc-stress`) -- they pass natively in this checkout, where
they count as native. Every other class is unchanged: the 69 new tests are
`tests/coroutines.test`'s -- 37 native and 32 independent (2599 = 2535 + 27
+ 37; 3832 = 3800 + 32), none unsupported or partial -- and no existing test
changed class. The unsupported
constructs are the same 60 tests as before (host-returned Block values,
`test-log`/`test-tick` instrumentation natives, sequence mode, Tcl-only
refinement natives).

### 56. GC-stress results

* The whole suite under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt
  at every allocation site): 6558 passed, 0 failed (point 54).
* `co-gc-stress` runs the GC program -- Strings and Lists held only by
  suspended frames at every level of a recursion three and five frames
  deep, in two interleaved coroutines plus an abandoned one, with
  allocation churn (hence collections) inside each segment and in the main
  program between resumes -- under stress on both native backends;
  `co-gc-suspended-stacks` runs it on every backend without; `co-gc-many-coroutines`
  constructs 4000 coroutines (2000 abandoned suspended, 2000 completed) and
  checks the program stays correct as their stacks are reclaimed.
* `co-executable-linux-io` runs an AOT executable under stress.
* The Rust runtime tests of `runtime/coroutine.rs` (seven: yields and
  resumes, terminal failure, return before yield, collections inside and
  between segments with stress forced, nested coroutines on their own
  stacks, an abandoned suspended coroutine collected and its stack pooled
  and reused, a yield outside any coroutine) pass with and without stress.
* Mutation: both GC mutants (point 53) are killed by these tests.

### 57. Scalar audit

`tclsh9.0 native/generate-scalar-audit.tcl` regenerated
`audit/native-scalar-asm/`: all 13 `.asm` files (and their summaries) are
byte-identical to the committed ones; the only difference was the README's
recorded commit hash and rustc version (this sandbox's rustc 1.97 vs the
recorded 1.99), which was not committed. Coroutine support adds no code to,
and changes no decision for, a program without coroutines: every coroutine
analysis is skipped unless the program refers to a coroutine operation
(`hir::coroutines::Used`/the `coroutines` table), the new native helpers are
only called by the new operations, and the GC's extra walks are no-ops
without a running or suspended coroutine.

### 58. Performance measurements

`tclsh9.0 bench/coroutines.tcl -runs 5 -n 4000` (n = 4000 operations per
program on the Tcl backends, 200000 natively; best of 5 in-process runs,
compilation excluded; this sandbox, 4 cores, nothing else running). Each
program repeats one operation; its baseline does the same work without a
coroutine (an ordinary call building the same struct, the same recursion
depth); the table shows (program - baseline) / n, and the whole program per
operation in parentheses:

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| construction to the first yield, then abandoned | 332 us (569 us) | 176 us (185 us) | 6.9 us (7.1 us) |
| construction + resume to completion + one cached call | 290 us (935 us) | 202 us (227 us) | 0.68 us (0.87 us) |
| resume, yield in the root | 34 us (273 us) | 14 us (24 us) | 200 ns (372 ns) |
| resume, yield 1 frame deep | 53 us (767 us) | 18 us (35 us) | 205 ns (393 ns) |
| resume, yield 8 frames deep | noise (2.7 ms) | 18 us (62 us) | 185 ns (393 ns) |
| resume, yield 32 frames deep | noise (9.8 ms) | 24 us (160 us) | 214 ns (678 ns) |

("noise": the interpreter's deep rows are dominated by the recursion itself,
which the baseline repeats, and the difference is within run-to-run
variation: -21 us and +480 us.)

Allocations per construction, natively: one `Coroutine` (96 B), one `Block`
(48 B, the thunk capturing the loop variable; none for literal arguments),
and the yielded struct (40 B). Nothing else, and nothing per resume beyond
what the body allocates.

Resident memory per coroutine held at once (peak RSS with K coroutines alive
minus with none, over K; K = 2000 on the Tcl backends, 10000 natively; each
coroutine is held by one frame of a recursion, which the figure includes):

| state | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| suspended, yield in the first frame below the root | 49.6 KiB | 20.1 KiB | 4.2 KiB |
| suspended, yield 32 frames deep | 338.5 KiB | 58.1 KiB | 4.2 KiB |
| completed (stack released, result cached) | 15.6 KiB | 13.0 KiB | 0.1 KiB |

What this says about the architecture (no optimization was attempted):

* **Deep yield costs nothing natively.** A resume is ~200 ns whatever the
  depth (1, 8, 32 frames): nothing is copied or unwound, the frames stay on
  their stack. The Tcl compiler's resume is likewise flat (14-24 us); the
  interpreter's is lost in its own call cost.
* **A suspended native coroutine is one touched page** (4 KiB of its 8 MiB
  reservation, plus 96 bytes) -- also at 32 frames deep, since Botlish frames
  are small. A completed one is its object and its cached result (~0.1 KiB);
  its stack went back to the pool.
* **The one native problem is stack reclamation for abandoned coroutines.**
  Constructing coroutines that are abandoned while suspended costs ~10x more
  (6.9 us vs 0.68 us) than running them to completion: an abandoned stack is
  freed only when a collection proves its handle dead, the pool keeps 32
  stacks, so most constructions pay `mmap` + `mprotect` and most sweeps a
  `munmap`. A framework running thousands of short tests as coroutines should
  run them to completion (they then reuse pooled stacks), or the runtime
  needs an explicit release of statically dead handles and a larger pool
  (point 61).
* **The Tcl backends are memory-heavy per coroutine** -- 50 KiB (interp) and
  20 KiB (compile) per suspended coroutine, ~9 KiB per interpreted frame
  below the yield (the completed row is mostly the holding recursion's own
  frame). Thousands of suspended coroutines on the reference interpreter
  cost hundreds of MiB: acceptable for a reference, worth knowing for the
  test framework (run it natively).
* A pre-existing native cost unrelated to coroutines distorted the first
  measurements: a single collecting loop of N iterations allocates N Lists
  and copies O(N^2) elements (2000 iterations allocate 16 MB, on the base
  commit too), so the benchmark repeats its operations in nested loops of
  100.

### 59. Current limitations

* **Hosts.** Native coroutines need the stack switch, written for x86-64
  Linux (SysV). Windows (fibers or a Win64 switch, plus frame pointers for
  the GC walk) and wasm (no program-visible stack) are later work
  (COROUTINE-PREREQUISITES.md R3); the Tcl backends run coroutines
  everywhere.
* **Stack reclamation waits for a collection.** A suspended coroutine that is
  abandoned keeps its stack until the collector proves the handle dead; only
  32 freed stacks are pooled, the rest are unmapped. A program creating many
  short-lived coroutines that it abandons suspended pays `mmap`/`mprotect`
  per construction (point 58); one that runs them to completion reuses
  pooled stacks.
* **Stack size is fixed per coroutine** (8 MiB of address space by default,
  `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`); recursion deeper than that inside
  a coroutine is `NATIVE LIMIT STACK`, the same resource limit as the main
  stack's. The Tcl backends' limit is Tcl's recursion limit, as everywhere.
* **Tcl backends keep an abandoned coroutine's frames** until the program
  run ends (deleting a suspended Tcl coroutine runs no `finally`;
  COROUTINE-PREREQUISITES.md A.3). Correct, not frugal.
* **Protocols are inferred over every syntactic call edge**, reachable or
  not (type inference runs before reachability is known): an unreachable
  call of a function with a different protocol is still a conflict.
* **Trait-implementation yields are invisible before monomorphization.** A
  trait operation whose implementation yields is resolved in build 2; in
  build 1 the call is an operation, not an edge. Monomorphized programs are
  checked again, so nothing unsound is accepted, but the diagnostics speak
  about the clone.
* **Use-site inference reads exact callees' declared parameter types only**:
  a yield value passed to an untyped or inferred parameter does not
  constrain the protocol (a projection then needs `resume T`).
* **`coroutine::done?` needs `import coroutine`**, like every standard
  intrinsic (IMPORTS.md).
* **Handles live in local bindings only** (point 36). Lists of coroutines, a
  scheduler, coroutine fields and handle-taking functions all wait for a
  general affine discipline.
* A pre-existing native limitation, not coroutine-specific, showed up while
  testing: a literal empty List argument whose element type is projected
  (`worker([])` with `xs: List[S]` and `x.f`) is `NATIVE UNSUPPORTED
  struct-shape` with or without coroutines; the tests pass such Lists
  through parameters.

### 60. What remains before `MutableVector`

`MutableVector` is the first affine *container* the test framework will
want (a growable buffer of results, owned by one place). This milestone
built the affine discipline for one kind of value in one kind of place; a
MutableVector needs it generalized:

* an affine *type* property instead of "the type is a coroutine type", with
  the same use/move/storage roles (`RefRole`) driven by it;
* affine values as function arguments and results (moves into and out of
  calls), which this milestone rejects as storage: the dataflow must follow
  moves across call boundaries (consumed parameters, returned ownership);
* affine values in struct fields and Lists with the move-out rules that
  makes possible (or an explicit "affine containers hold only non-affine
  elements" restriction);
* a runtime representation that never needs a moved sentinel: like
  coroutine handles, ownership must stay static.

### 61. What remains before the Botlish-native test framework

A test framework written in Botlish that runs thousands of tests as
coroutines (each test a coroutine that yields its assertions or progress)
needs:

* **a scheduler-shaped storage frontier**: a List (or queue) of handles,
  i.e. affine containers (point 60);
* **cheap abandonment natively**: returning stacks of abandoned suspended
  coroutines without waiting for a collection (an explicit drop when the
  last owner dies statically, or `madvise(MADV_DONTNEED)` of pooled stacks
  above a high-water mark), and a larger pool;
* **typed protocols per test kind** are already enough (one struct message);
  what is missing is a way to pass a handle to a runner function (handles as
  arguments, point 60);
* **resource limits per coroutine** (a smaller default stack for tests,
  configurable per construction) so that thousands of suspended tests fit in
  address space comfortably;
* no change to the effect system: a test body's helpers already yield
  arbitrarily deep, and errors already cross the resume as ordinary errors,
  which is exactly how a failed assertion should reach the runner.

## Files

| File | What |
|---|---|
| `surface/lexer.tcl`, `surface/parser.tcl`, `surface/ast.tcl`, `surface/lower.tcl` | `yield`, the coroutine binding, the resume clause; lowering to the internal natives |
| `hir/syntax.tcl`, `hir/resolve.tcl` | the block's resume clause; `ResolveResume`; a call of a handle as `coroutine#resume` |
| `hir/coroutines.tcl` | the static semantics (header comment: what it decides) |
| `hir/types.tcl` | the coroutine type, the natives' result shapes, segment error charging |
| `hir/completions.tcl`, `hir/errorsets.tcl` | segments' effective errors; a thunk admits its root's errors; boundary calls are no known failure |
| `hir/contexts.tcl`, `hir/traits.tcl` | a construction is a call of its thunk; a thunk is no owner in build 2 |
| `hir/range.tcl` | a handle argument is the coroutine pass's rejection only |
| `hir/format.tcl`, `hir/read.tcl` | `resume T`, `coroutine-effect (...)`, `move`, the coroutine type in HIR text |
| `core/coroutines.tcl`, `core/native.tcl`, `core/value.tcl`, `core/evaluator.tcl`, `compiler/compiler.tcl` | the Tcl runtime, `-completion` natives, the `coroutine` kind |
| `native/lower.tcl`, `native/src/nir.rs`, `native/src/codegen/clif.rs`, `native/src/runtime/{coroutine,heap,vm,framewalk,ops,value,...}.rs` | the native implementation |
| `tests/coroutines.test` | the milestone's tests |
| `audit/coroutines/tools/fuzz.tcl`, `mutate.tcl`, `mutants.txt` | fuzzer and mutation testing |
| `bench/coroutines.tcl` | the performance report |
