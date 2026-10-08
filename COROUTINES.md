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

AFFINE-VALUES.md generalizes the ownership half of this milestone: affinity
is now a property of any value whose type owns a coroutine (a struct, a
List), a coroutine handle type is spelled `Coroutine{args: [M], return: R,
errors: [E]}` in source and shares `Fn`'s callable contract, handles move
through arguments, results, struct fields and List elements, and the
ownership analysis and release elaboration live in `hir/affine.tcl`. The
points below that it changes (30, 31, 33, 36, 37, 38 and the two release
sections) say so where they stand; coroutine control semantics are
unchanged.

## Contents

* [The principal program](#the-principal-program)
* [Report](#report) -- the 61 points of the milestone report, in order
* [Release at the last use](#release-at-the-last-use) -- the follow-up that
  frees a coroutine where its handle dies
* [Release on every early exit](#release-on-every-early-exit) -- and where a
  return, fail, break, continue or propagated error leaves its scope first
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
| `releases` | statement -> the handle bindings whose coroutines are released after it ([Release at the last use](#release-at-the-last-use)) |

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

*Superseded by AFFINE-VALUES.md points 1-5:* the type is now `{coroutine
{args {M} return R errors {E}}}`, spelled `Coroutine{args: [Message],
return: Event, errors: [Broken]}` in source and in HIR text, with `Fn`'s
callable contract. As built here:

`{coroutine RESUME OUTWARD ERRORS}` in HIR (`hir/types.tcl`), shown
`Coroutine{resume: Message, yield: Event, errors: [Broken]}`: the resolved
protocol (`unit` or a named struct type), the outward type, and the root's
declared errors. It is a specific type (`IsSpecific`) with no source
spelling (the `Coroutine{...}` notation exists only so that HIR text can state
and read back a handle's type), and its values have no equality and no hash
(`core/value.tcl`'s kind `coroutine` is excluded from both; natively too).

### 31. Affine binding representation

*Generalized by AFFINE-VALUES.md points 9-13:* a binding is affine when its
type is (a coroutine, or a struct or List owning one); its state lives in
`hir::affine`'s analysis. As built here:

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

*Generalized by AFFINE-VALUES.md point 14 (`hir::affine::Consumer`).* As
built here:

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

*Superseded by AFFINE-VALUES.md:* a handle may now be a struct field, a List
element, an argument, a result and the value of an `if`, handler or loop
(points 16-31); what remains rejected is erasure, equality, capture, module
bindings and element-copying List operations, under the `AFFINE-*` codes
(points 27, 31, 37-39). `COROUTINE-STORAGE-UNSUPPORTED` no longer exists. As
built here:

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

*Unchanged in substance by AFFINE-VALUES.md (points 5, 40): `Fn` and
`Coroutine` share a callable contract but stay distinct kinds; an untyped
higher-order function given a coroutine is specialized for it (point 7).*

A handle is not a function value: passing it where a structural `Fn` is
expected is `COROUTINE-NOT-FUNCTION` ("it carries the evolving state of one
coroutine and cannot be passed where a function value of type
Fn{args: [], return: T, errors: []} is expected"; no second, type-level
diagnostic). A *function that may yield* cannot become a value either
(`UNWRAPPED-YIELD` at the reference, point 21): a call through a value is
not a call-graph edge, so the effect could not follow it.

### 38. Closure interaction

*Since AFFINE-VALUES.md the diagnostic is `AFFINE-CAPTURE-UNSUPPORTED`, for
every affine binding (point 37).*

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
  Since [Release at the last use](#release-at-the-last-use) and [Release on
  every early exit](#release-on-every-early-exit), that is the fallback: a
  coroutine is released where its handle's last use is, or where an exit
  leaves the handle's scope first, and only what those do not cover (a
  coroutine held by a released suspended coroutine's own frames, a shadowed
  name at an exit) waits for a sweep.

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
* `coroutine#release(h)` (since [Release at the last
  use](#release-at-the-last-use)) unwinds a suspended coroutine whose handle
  is dead (after its last use, or on an exit leaving its scope) and drops
  what any released coroutine holds;
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
  `op coresume H M`, `op coresume0 H`, `op coyield V`, `op codone H`, and
  `op corelease H` after a handle's last use or on an exit leaving its
  scope (`native/lower.tcl` maps the natives). An environment-free thunk is a
  static closure (`fnvalue`); one capturing temporaries is an ordinary
  closure.
* Code generation (`native/src/codegen/clif.rs`): each is a call of a runtime
  helper (`rt_co_*`); start/resume/yield are fallible (a 0 result means the
  pending error), and all but `codone` and `corelease` are allocation sites,
  hence safepoints.
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
side effects folded into a checksum in a MutableArray and (since [Release
on every early exit](#release-on-every-early-exit)) coroutines held across
the function's later exits and loops whose iterations break and continue
past their own coroutine. A driver -- at the
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
`COROUTINE-RHS-NOT-YIELDING`. It also predicts where the final owner of the
driver's coroutine is released, and what every exit of every generated
function releases (compared with the compiler's tables).

Results (every run on all four backends unless noted; "accepted" programs
are compared value by value, "rejected" ones by diagnostic class):

| seeds | programs | accepted | rejected | disagreements |
|---|---:|---:|---:|---:|
| 1-100 | 100 | 64 | 36 | 0 |
| 3000-3099 | 100 | 56 | 44 | 0 |
| 7000-7099 | 100 | 58 | 42 | 0 |
| 1-100, 3000-3099, 7000-7099 (an earlier generator, before early exits) | 300 | 158 | 142 | 0 |
| 1000-1199 (an earlier generator, before side effects) | 200 | 123 | 77 | 0 |
| 5000-5199 (an earlier generator, before deep programs) | 200 | 125 | 75 | 0 |
| 101-112 (`co-fuzz-bounded`, in the test suite) | 12 | | | 0 |

Every predicted diagnostic class occurred (in the final 300: `COROUTINE-RHS-
NOT-YIELDING` 48, `AFFINE-NOT-DEFINITELY-LIVE` 12, `YIELD-OUTSIDE-FUNCTION`
12, `COROUTINE-RESUME-ARITY` 11, `COROUTINE-RESULT-MISMATCH` 11,
`COROUTINE-STORAGE-UNSUPPORTED` 8, `UNWRAPPED-YIELD` 8, `USE-AFTER-MOVE` 6,
`TYPE` 3, `COROUTINE-RESUME-CONFLICT` 3), and the accepted 178 checked 394
releasing exits: 58 returns, 135 fails, 39 calls failing with `Boom`, 80
breaks and 82 continues.

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

**52 mutants, 52 killed, 0 survived** -- every mutant item 62 of the
brief names, in each runtime where it can live, plus the native ones it
implies, plus 10 for [Release at the last use](#release-at-the-last-use)
(`release-*`, `compiler-release-missing`, `native-release-*`) and 11 for
[Release on every early exit](#release-on-every-early-exit) (`exit-release-*`,
`core-ir-error-release-missing`, `compiler-exit-release-missing`,
`compiler-error-release-missing`, `native-exit-release-missing`,
`native-error-release-missing`). What killed each (a test name, the number
of failing tests, or the number of disagreeing fuzz programs of 25, seed 11;
Tcl-only mutants run first, native ones after; the run with the early-exit
tests and fuzzer, so the counts are higher than before them):

| mutant | `tests/coroutines.test` | fuzzer | Rust runtime tests |
|---|---|---|---|
| **construction-lazy**: construction does not run the body: the first resume starts it | 43 tests | 18/25 programs | -- |
| **first-yield-discarded**: construction runs past the first yield: its value is lost | 39 tests | 18/25 programs | -- |
| **return-before-yield-exhaustion**: a body that returns before yielding fails the construction as exhausted | `co-empty-loop`, `co-terminal-success` | survived | -- |
| **completed-raises-exhaustion**: a call of a completed handle raises an exhaustion error | 11 tests | 5/25 programs | -- |
| **completed-reruns-body**: a call of a completed handle runs the body again from its beginning | 10 tests | 5/25 programs | -- |
| **failed-resumes-body**: a call of a failed handle runs the body again | 4 tests | 2/25 programs | -- |
| **failed-loses-error**: a call of a failed handle completes normally with unit instead of raising the original error | 5 tests | 2/25 programs | -- |
| **message-wrong-yield**: each resume delivers the previous resume's message (the first, unit) | 13 tests | 8/25 programs | -- |
| **effect-one-caller**: the yield effect reaches the direct callers of a yielding function and no further | 7 tests | 2/25 programs | -- |
| **call-crosses-yield**: an ordinary top-level call of a yielding function is allowed | `co-unwrapped-chain` | survived | -- |
| **protocol-widened-any**: every coroutine accepts any resume message: the handle's protocol is any | `co-hir-text`, `co-protocol-arity`, `co-protocol-wrong-type` | survived | -- |
| **two-protocols-accepted**: a second, different protocol reaching a function is ignored (the first wins) | `co-protocol-conflict`, `co-protocol-default-meets-struct` | 1/25 programs | -- |
| **scalar-resume-accepted**: a declared resume type need not be a struct | `co-protocol-struct-only` | survived | -- |
| **assignment-aliases**: binding a handle to another name is no move: both names stay usable | 10 tests | 9/25 programs | -- |
| **assignment-forks**: binding a handle to another name starts a new coroutine of the same call: the new name runs a copy from the beginning | 4 tests | 7/25 programs | -- |
| **move-keeps-source**: a move does not invalidate the binding moved from | 9 tests | 9/25 programs | -- |
| **join-keeps-live**: a handle moved on one branch only is live after the join | `co-affine-branch-join`, `co-affine-loop` | 1/25 programs | -- |
| **step-call-moves**: a resume consumes the handle: its owner is moved by the call | 31 tests | 17/25 programs | -- |
| **done-consumes**: coroutine::done? consumes the handle: its owner is moved by the query | 8 tests | 12/25 programs | -- |
| **handle-as-fn**: a handle is accepted where a structural Fn value is expected | `co-storage-frontier` | survived | -- |
| **handle-erased-to-any**: a handle is accepted as an argument of an untyped (any) parameter | `co-storage-equality`, `co-storage-frontier` | survived | -- |
| **context-reselected-per-resume**: every top-level resume selects the coroutine's context-trait providers again | `co-context-fixed-at-construction` | survived | -- |
| **release-never**: no coroutine is released at its handle's last use: every one waits for a collection (Tcl: the program's end) | 7 tests | 19/25 programs | -- |
| **release-moved-handle**: a handle moved away is released too: its new owner's coroutine is released while still in use | 6 tests | 8/25 programs | -- |
| **release-at-declaration**: a coroutine is released right after its handle's binding, before its uses | 52 tests | 19/25 programs | -- |
| **release-before-statement**: the Tcl lowering releases before the statement of the last use instead of after it | 37 tests | 19/25 programs | -- |
| **release-last-value-lost**: a release after a sequence's last statement makes the release's unit the sequence's value | 11 tests | survived | -- |
| **compiler-release-missing**: the Tcl compiler compiling HIR (main.tcl's compile backend) emits no release | `co-exit-release-tcl-runtime`, `co-release-tcl-runtime` | survived | -- |
| **release-leaves-frames**: the Tcl runtime deletes a released suspended coroutine without unwinding it: its frames stay until the run ends | `co-release-tcl-runtime` | survived | -- |
| **release-resumes-body**: a released suspended Tcl coroutine is resumed (with unit) instead of unwound: its body runs on after the yield | `co-release-values` | 2/25 programs | -- |
| **exit-release-never**: no exit releases anything: a coroutine left by a return, fail, break, continue or failing call waits for a collection (Tcl: the program's end) | 5 tests | 13/25 programs | -- |
| **exit-release-crosses-loop**: a break or continue releases every handle of its function, not only those of the loop body it leaves: a handle the function still uses after the loop is released | 4 tests | 5/25 programs | -- |
| **exit-release-handled-error**: a handled call releases on the errors its handlers handle too: the handler resumes a released coroutine | 10 tests | 9/25 programs | -- |
| **exit-release-before-value**: an exit releases every handle before evaluating its value, also one the value resumes | 4 tests | survived | -- |
| **exit-release-after-last-use**: an exit after a handle's last use releases it again (it was released at that last use) | `co-exit-release-placement`, `co-fuzz-bounded` | 14/25 programs | -- |
| **exit-release-shadowed**: an exit releases a handle whose name a nested binding rebinds: the release names the other binding | `co-exit-release-placement` | survived | -- |
| **core-ir-error-release-missing**: the Core IR lowering releases nothing on a call's propagated error | `co-exit-release-tcl-runtime` | survived | -- |
| **compiler-exit-release-missing**: the Tcl compiler compiling HIR releases nothing before an exit statement | `co-exit-release-tcl-runtime` | survived | -- |
| **compiler-error-release-missing**: the Tcl compiler compiling HIR releases nothing on a call's propagated error | `co-exit-release-tcl-runtime` | survived | -- |
| **native-construction-lazy**: construction does not run the body natively: the first resume starts it | 46 tests | 18/25 programs | 6 tests |
| **native-first-yield-discarded**: native construction runs past the first yield | 43 tests | 18/25 programs | 4 tests |
| **native-completed-raises-exhaustion**: a call of a completed handle raises an exhaustion error natively | 12 tests | 5/25 programs | `yields_resumes_and_keeps_its_final_result`, `return_before_any_yield_completes_at_the_start` |
| **native-completed-reruns-body**: a call of a completed handle runs the body again natively | 11 tests | 5/25 programs | `yields_resumes_and_keeps_its_final_result` |
| **native-failed-loses-error**: a call of a failed handle completes normally with unit natively | 5 tests | 2/25 programs | `a_failure_is_terminal_and_raised_again` |
| **native-message-wrong-yield**: a native resume does not deliver its message: the yield evaluates to its own outward value | 14 tests | 4/25 programs | 3 tests |
| **native-deep-stack-not-preserved**: a suspended coroutine's stack is released (pooled for reuse) while its frames are suspended on it | 10 tests | 10/25 programs | survived |
| **gc-suspended-frames-untraced**: the collector does not trace the frames of a suspended coroutine's stack | `co-gc-stress` | survived | survived |
| **gc-resumer-frames-untraced**: the collector does not trace the frames suspended below a running coroutine (its resumers' stacks) | 6 tests | survived | survived |
| **native-release-not-emitted**: native lowering emits no corelease | `co-exit-release-native-stacks`, `co-nir-operations`, `co-release-native-stacks` | survived | survived |
| **native-release-keeps-stack**: a native release leaves a suspended coroutine's stack in place (a collection frees it later) | `co-exit-release-native-stacks`, `co-release-native-stacks` | survived | survived |
| **native-exit-release-missing**: native lowering releases nothing before a return | `co-exit-release-native-stacks` | survived | survived |
| **native-error-release-missing**: native lowering's failure pad of a call releases nothing | `co-exit-release-native-stacks` | survived | survived |

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
* A release is unobservable by design, so a release mutant that only wastes
  resources (frames or a stack kept, no release emitted natively, none on an
  exit) changes no value: the fuzzer's values cannot see it, and the focused
  tests that count Tcl coroutines, frames and native stacks kill it (the
  fuzzer's release oracle kills those that move a release in the tables). A
  release mutant that frees too early, or frees a coroutine still owned, is
  caught everywhere, as a resume of a released coroutine.
* No equivalent mutant survives. One did while the early-exit mutants were
  written: removing the check that an exit leaves after the handle's binding
  statement changed nothing, because a binding not yet bound there is not in
  the liveness state at all. The check was redundant and is gone, and so is
  the mutant.

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

The Rust coroutine tests also pass under `BOTLISH_NATIVE_GC_STRESS=1`. At
the time, the whole Rust suite did not, on the baseline either: other
runtime tests held heap values only in Rust locals. A later change rooted
them (`e98c62e`); the whole Rust suite now passes under stress, and the CI
GC-stress job runs it.

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
operation in parentheses. These numbers predate [Release at the last
use](#release-at-the-last-use), which changed the first row (see there);
they were re-measured once the benchmark could repeat each operation in a
single collecting loop (last point below):

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| construction to the first yield, then abandoned | 239 us (325 us) | 117 us (125 us) | 5.2 us (5.2 us) |
| construction + resume to completion + one cached call | 204 us (570 us) | 136 us (158 us) | 0.57 us (0.57 us) |
| resume, yield in the root | 34 us (117 us) | 13 us (22 us) | 144 ns (146 ns) |
| resume, yield 1 frame deep | noise (452 us) | 14 us (30 us) | 161 ns (167 ns) |
| resume, yield 8 frames deep | noise (1.9 ms) | 14 us (51 us) | 158 ns (185 ns) |
| resume, yield 32 frames deep | noise (7.3 ms) | 22 us (136 us) | 221 ns (470 ns) |

("noise": the interpreter's deep rows are dominated by the recursion itself,
which the baseline repeats, and the difference is within run-to-run
variation: -32 us, +42 us and -199 us.)

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

* **Deep yield costs nothing natively.** A resume is ~150-220 ns whatever
  the depth (1, 8, 32 frames): nothing is copied or unwound, the frames stay
  on their stack. The Tcl compiler's resume is likewise flat (13-22 us); the
  interpreter's is lost in its own call cost.
* **A suspended native coroutine is one touched page** (4 KiB of its 8 MiB
  reservation, plus 96 bytes) -- also at 32 frames deep, since Botlish frames
  are small. A completed one is its object and its cached result (~0.1 KiB);
  its stack went back to the pool.
* **The one native problem was stack reclamation for abandoned coroutines.**
  Constructing coroutines that are abandoned while suspended cost ~9x more
  (5.2 us vs 0.57 us above; 6.9 us vs 0.68 us in the first measurement)
  than running them to completion: an abandoned stack was freed only when a
  collection proved its handle dead, the pool keeps 32 stacks, so about half
  of the constructions paid `mmap` + `mprotect` + a page fault and the
  sweeps a `munmap`. [Release at the last use](#release-at-the-last-use)
  fixed it: the same program now costs 0.45 us per construction.
* **The Tcl backends are memory-heavy per coroutine** -- 50 KiB (interp) and
  20 KiB (compile) per suspended coroutine, ~9 KiB per interpreted frame
  below the yield (the completed row is mostly the holding recursion's own
  frame). Thousands of suspended coroutines on the reference interpreter
  cost hundreds of MiB: acceptable for a reference, worth knowing for the
  test framework (run it natively).
* A pre-existing native cost unrelated to coroutines distorted the first
  measurements: a collecting loop of N iterations allocated N Lists and
  copied O(N^2) elements (2000 iterations allocated 16 MB), so the benchmark
  repeated its operations in nested loops of 100. Collecting loops now build
  their List in one private List plan (native/lower.tcl's CollectStart; O(1)
  Lists, O(N) copies), and the benchmark repeats each operation in a single
  collecting loop whose List is discarded: a retained List of 200000
  elements would still be marked by every collection the operation
  triggers (it doubled the native construction row), a harness cost, not a
  coroutine one. The numbers above are from that version.

### 59. Current limitations

* **Hosts.** Native coroutines need the stack switch, written for x86-64
  Linux (SysV). Windows (fibers or a Win64 switch, plus frame pointers for
  the GC walk) and wasm (no program-visible stack) are later work
  (COROUTINE-PREREQUISITES.md R3); the Tcl backends run coroutines
  everywhere.
* **Stack reclamation is static, not total.** A coroutine is released right
  after its handle's last use ([Release at the last
  use](#release-at-the-last-use)), or on an exit that leaves the handle's
  scope first ([Release on every early exit](#release-on-every-early-exit)).
  What is left to the collector, which keeps a suspended coroutine's stack
  until it proves the handle dead (only 32 freed stacks are pooled, the rest
  are unmapped): a coroutine held by the frames of a suspended coroutine that
  is itself released (its frames are discarded, their exits never run), a
  handle whose name is rebound between an exit and its scope, and programs
  the discipline rejects (`-strict 0`). Before releases existed, every
  abandoned suspended coroutine went this way, at ~10x the construction cost
  (point 58).
* **Stack size is fixed per coroutine** (8 MiB of address space by default,
  `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`); recursion deeper than that inside
  a coroutine is `NATIVE LIMIT STACK`, the same resource limit as the main
  stack's. The Tcl backends' limit is Tcl's recursion limit, as everywhere.
* **Tcl backends keep an unreleased abandoned coroutine's frames** until
  the program run ends (deleting a suspended Tcl coroutine runs no
  `finally`; COROUTINE-PREREQUISITES.md A.3). A released one is unwound
  instead, frames and all; what is left are the cases above.
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
  (`worker([])` with `xs: List[S]` and `x.f`) was `NATIVE UNSUPPORTED
  struct-shape` with or without coroutines, so the tests pass such Lists
  through parameters. It has since been fixed (`c40a163`: a read of a
  `List[never]` is never-typed, and a projection of it unreachable); such a
  coroutine now runs natively too.

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
* **cheap abandonment natively**: done by [Release at the last
  use](#release-at-the-last-use) and [Release on every early
  exit](#release-on-every-early-exit) (a dead handle's stack goes back to
  the pool at once, also when a test returns or fails early). Still open:
  `madvise(MADV_DONTNEED)` of pooled stacks above a high-water mark, so that
  a burst of deep tests does not keep its pages;
* **typed protocols per test kind** are already enough (one struct message);
  what is missing is a way to pass a handle to a runner function (handles as
  arguments, point 60);
* **resource limits per coroutine** (a smaller default stack for tests,
  configurable per construction) so that thousands of suspended tests fit in
  address space comfortably;
* no change to the effect system: a test body's helpers already yield
  arbitrarily deep, and errors already cross the resume as ordinary errors,
  which is exactly how a failed assertion should reach the runner.

## Release at the last use

*Generalized by AFFINE-VALUES.md (points 32-35): the same rule now applies
to every affine binding and discarded affine value, a struct or List being
dropped by its type's descriptor; the tables live in `hir::affine`.*

A follow-up to the milestone: a coroutine is released as soon as the affine
analysis proves its handle dead, instead of when a collection finds the
handle unreachable. This is resource cleanup that comes from the type
discipline itself. A program that forgets a coroutine (stops resuming it,
lets the handle go out of use) has it closed at that point, without a
`close` call, a finalizer, or reference counting. The same rule applies to
any future affine value (a MutableVector, a file or socket handle) and to
nothing else.

### Why

The performance measurements (point 58) showed native construction about
10x slower when coroutines are abandoned while suspended. The mechanism,
measured over 20,000 constructions of a coroutine that yields once and is
then abandoned:

1. A native start takes a stack from a per-thread pool, or else `mmap`s 8 MiB
   (plus a 64 KiB guard it `mprotect`s); the first touch of a fresh stack is a
   page fault.
2. A coroutine that completes returns its stack to the pool at once; the next
   construction reuses it with no system call and the page already resident.
3. An abandoned suspended coroutine returned its stack only when a
   collection swept it. Collections run after ~1 MiB of allocation since the
   last one, and each start counts 16 KiB, so ~64 dead stacks piled up between
   collections. The pool keeps 32: the sweep pooled 32 and `munmap`ped the
   rest, and the next cycle's constructions past the first 32 mapped fresh
   stacks.

So about half of all constructions paid `mmap` + `mprotect` + a page fault,
and the sweeps the matching `munmap`: 9,749 `mmap`, 9,768 `mprotect`, 9,734
`munmap` and 10,050 minor faults, against 22/38/7 and 330 when the same
coroutines ran to completion (process start-up alone), at 4,651 ns against
777 ns per construction. Collecting more often (`BOTLISH_NATIVE_GC_MIN=262144`,
so the pool never overflows) brought the abandoned case to 554 ns with no
code change, which confirmed the cause.

### The rule

`hir::coroutines::Releases` runs at the end of the affine analysis (only for
a program the discipline accepts) and records, per statement, the handle
bindings to release right after it. A handle binding is released after the
**last statement of its own sequence** (the function or block body, branch,
loop body, handler or top level that declares it) **that refers to it**,
anywhere inside, when after that statement it still owns its coroutine on
some path:

| after that statement the binding is | released there? | why |
|---|---|---|
| `live` (never moved) | yes | no reference to it follows; nothing else owns the coroutine |
| `maybe` (moved on some paths, inside that statement) | yes | the new owner is bound inside a branch, loop body or handler of that statement, out of scope after it (and released there itself); a `maybe` binding referred to later is `AFFINE-NOT-DEFINITELY-LIVE` |
| `moved` | no | its new owner is a live binding of the same sequence; it is released after *its* last use |
| unreachable (the statement cannot complete) | no | `return step().n`: nothing runs after it (the `return` releases it: [Release on every early exit](#release-on-every-early-exit)) |

Consequences:

* a construction in a loop body is released at the end of every iteration;
  a handle declared outside a loop and used in it, after the loop;
* the last use may be the sequence's last statement, whose value is the
  sequence's value (a function's result, a loop element, an `if`'s value, the
  program's result): the backends keep that value and release after it;
* a release is idempotent (the `maybe` case can release a coroutine twice:
  once by the new owner in its branch, once after the branch);
* nothing observable changes. A suspended body never runs again either way,
  Botlish has no finalizers, and no code can reach the handle after its last
  use. So a release is a resource decision, never a semantic one, and
  `tests/coroutines.test` and the fuzzer show identical values on every
  backend.

What it does not cover (a collection still reclaims these, as before): a
path that leaves the sequence before the last use (`return`, `break`,
`continue`, a `fail` or an error propagating through) -- since covered by
[Release on every early exit](#release-on-every-early-exit) -- and a handle
in a program the discipline rejected but that runs anyway (`-strict 0`).

### Representation and lowering

* HIR: the side table `coroutines releases` (statement -> bindings); the
  debug text prints it on the statement as a flag, read back by
  `hir/read.tcl`:

  ```
  e49 bind b17 again : Event release=b10
  e37 bind b14 other : Coroutine{resume: Message, yield: Event, errors: []} move
  e39 bind b16 x : Event release=b14
  ```

* A sixth internal operation, `coroutine#release(H)` (a root native like the
  others), NIR `op corelease %h`.
* Core IR (`hir::lower::Seq`, the interpreter and the Tcl compiler's Core IR
  route): the statement, then `(call (ref coroutine#release) (ref H))`; after a
  sequence's last statement, `(bind coroutine#kept#E STATEMENT)`, the
  releases, `(ref coroutine#kept#E)` (a binding statement `(bind N V)` keeps
  its value as `(ref N)` instead). HIR rebuilt from that Core IR (the Tcl
  compiler's route) sees the release calls: the affine analysis does not
  count one as a use, and releases no binding that already has one.
* The Tcl compiler from HIR (`core::compiler::CompileSequence`, main.tcl's
  `compile` backend): `core::coroutines::releaseImpl` of the binding's value,
  after the statement's own code.
* Native (`native::lower::Sequence`): `op corelease` of the handle's register
  after the statement; the statement's value register stays the sequence's
  value.

### Runtimes

* A sixth runtime state, `released`. The handle is dead and the coroutine
  holds nothing. Resuming it or asking `done?` of it is a compiler bug
  (`COROUTINE-STATE`), which is also what makes a misplaced release fail
  loudly in every test.
* Tcl (`core::coroutines::releaseImpl`): a suspended coroutine is resumed
  with a private marker (never a Botlish value). Its pending `yield` raises a
  Tcl error, which passes every Botlish handler (they handle declared
  errors only) and unwinds the whole suspended stack through the evaluator's
  own `finally` clauses, so its environments are released and its Tcl
  coroutine ends. This is COROUTINE-PREREQUISITES.md's "cancel token"
  (§4.2 item 4). A terminal coroutine drops its cached result or error.
* Native (`rt_co_release`): a suspended coroutine's stack goes back to the
  pool at once (no frame on it owns a Rust value with a destructor, exactly
  as when one is swept), and the thunk, transport slot and cached failure
  are dropped. The allocation report's new `coroutines` section counts
  stacks mapped and reused, releases, and suspended coroutines swept
  without a release.

### Evidence

* `co-release-placement`: where releases go (after the last resume, per loop
  iteration, after a loop that uses the handle, after a function's last
  statement, after the branch that moved the handle on one path, and inside
  that branch for its new owner), and where they don't (a moved-from handle;
  a last use in a `return`).
* `co-release-values`: values kept through releases after last statements
  (a function result, loop elements, an `if` value, the program result), and
  a released suspended body runs no further code (its side-effect log stays
  as it was at the yield). `co-release-branch-move`: both paths of a one-path
  move, every backend.
* `co-release-tcl-runtime`: in the interpreter, the 9 frames of a coroutine
  suspended 5 calls deep are gone right after its handle's last use, and no
  Tcl coroutine survives a loop of 50 abandoned ones on the interpreter, the
  Tcl compiler's Core IR route, or its HIR route. (The one frame per
  iteration that remains is the thunk closure's, the same as a loop creating
  any closure leaves in the Tcl reference.)
* `co-release-native-stacks`: 2000 constructions abandoned in a loop map
  **one** stack and reuse it 1999 times; 2000 releases, 0 suspended
  coroutines swept; the same value under GC stress.
* The fuzzer's oracle predicts the final owner's release (after the
  statement of its last reference, and none for any handle it was moved
  from), compared on every accepted program. A release that is misplaced in
  any other way shows up as a resume of a released coroutine.
* Regression with releases: `tests/all.tcl` 6563 passed on the interpreter,
  6559 passed and the same 4 skipped (`coreScoping`) on the Tcl compiler,
  6563 passed under `BOTLISH_NATIVE_GC_STRESS=1`; native coverage 2602
  native, 3834 independent, 67 passed-partial, the same 60 unsupported, 0
  failed; `cargo test --release` 194 + 31 passed (the coroutine tests also
  under stress); the scalar assembly audit byte-identical (programs without
  coroutines have no release); the fuzzer, 300 programs over three seeds on
  every backend with the placement oracle, no disagreement.
* Mutation: 10 more mutants, all killed (point 53): no release; releasing a
  moved-from handle; releasing at the declaration; releasing before the
  statement (Tcl lowering); losing the last statement's value; the Tcl
  compiler's HIR route not releasing; a Tcl release that deletes without
  unwinding (frames kept); a Tcl release that resumes the body; native
  lowering not emitting `corelease`; a native release that keeps the stack.

### Measurements

`bench/coroutines.tcl -runs 5 -n 4000` again, with releases (one other job,
the GC-stress suite, ran on another core):

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| construction to the first yield, then abandoned (before) | 332 us (569 us) | 176 us (185 us) | 6.9 us (7.1 us) |
| construction to the first yield, then abandoned (released) | 266 us (458 us) | 101 us (109 us) | **0.45 us (0.58 us)** |
| construction + resume to completion + one cached call | 235 us (698 us) | 114 us (135 us) | 0.69 us (0.83 us) |
| resume, yield in the root / 1 / 8 / 32 frames deep | 29-143 us | 13-21 us | 178-246 ns |

An abandoned native construction now costs less than one run to completion
(which also runs a second segment and a cached call): the dead handle's
stack goes straight back to the pool and the next construction reuses it,
page already resident. Over the 20,000 constructions of the experiment above:

| abandoned while suspended | `mmap` | `mprotect` | `munmap` | minor faults |
|---|---:|---:|---:|---:|
| before (swept by collections) | 9,749 | 9,768 | 9,734 | 10,050 |
| released at the last use | 22 | 41 | 7 | 309 |

These are process start-up only, the same as when the coroutines run to
completion (22 / 38 / 6, 313 faults). On the Tcl backends, unwinding a
released coroutine is cheaper than leaving its Tcl coroutine and frames
alive until the run ends (the compiler: 176 to 101 us). Resume costs and the
memory of coroutines whose handles are still in use are unchanged (they are
not released).

## Release on every early exit

*Generalized by AFFINE-VALUES.md (points 18, 22, 33): every affine binding,
and the pending temporaries of a call or construction an exit abandons.*

The second follow-up closes the gap [Release at the last
use](#release-at-the-last-use) left: a path that leaves a handle's scope
before its last use (`return`, `fail`, `break`, `continue`, or a call whose
declared error propagates out) releases the coroutines it takes out of scope
too, instead of leaving them to a collection (Tcl: to the end of the run).
This is drop elaboration for the one affine value the language has: every
exit of a scope releases what the scope still owns.

### Why

The last-use release runs after a statement completes normally, so an
abrupt completion before it skipped it. Such exits are ordinary code: a
function that constructs a coroutine and returns early on some input, a
loop that `continue`s past an element, a helper whose callee fails. Over
2,100 rows of `co-exit-release-native-stacks` (each row calls eight
functions, one per kind of exit; 27,900 constructions, 18,000 of them
abandoned while suspended), natively:

| | stacks mapped | stacks reused | released | released suspended | swept suspended (a collection found them) |
|---|---:|---:|---:|---:|---:|
| last-use releases only | 3,353 | 24,547 | 8,700 | 900 | 17,053 |
| and releases on every exit | **2** | 27,898 | 27,900 | 18,000 | **0** |

On the Tcl backends, 7 rows left 57 suspended Tcl coroutines (and their
frames) alive until the run ended; now none.

### The rule

An *exit* is an abrupt completion. What it leaves, and when its releases
run:

| exit | leaves every sequence up to | released |
|---|---|---|
| `return V` | the function's body (or the top level) | before evaluating `V`, except the handles `V` refers to: those after it (`return step().n`) |
| `fail E` | the function's body | before failing |
| `break`, `continue` | the target loop's body | before leaving |
| a call propagating declared error `E` | the function's body, unless a `handle` whose call contains the call handles `E` (then no sequence: the grammar puts no sequence inside a call) | on the way out: per such `E`, release and propagate `E` unchanged |

A handle binding is released on exit X when X leaves the binding's sequence
from a statement after its binding statement and at or before its last use
(after it, the last-use release already ran), and the binding owns its
coroutine (live, or maybe moved) in the liveness state where X leaves.

It is sound for the same reason as the last-use rule: after X, no binding
still in scope owns the coroutine. A move target is declared where the move
is, so every binding the coroutine may have moved to is in a sequence X
leaves too; and handles never leave their function (no return, argument,
field, List element or capture), so a function's exit ends every coroutine
it still owns. A release is idempotent, so a maybe-moved binding and its
new owner may both be released. Nothing observable changes, as before.

Details:

* The errors of a call's error edge are its type-level declared errors
  (`calleeErrors`: the callee's `errors` clause, a structural callee's
  contract, a coroutine segment's errors), never a narrower proof, so the
  completion facts stay inspection data. A failure that is not a declared
  error (a run-time fault) ends the program and needs no release.
* A call inside an exit's value does not release again what the exit
  released before evaluating it.
* A self tail call has no error edge: the Tcl compiler and native lowering
  compile it as a restart of the function, which a catch around the call
  would break. Its `return` already released the handles its arguments do
  not use, before the call.
* Core IR names a released handle (it resolves names), so a handle whose
  name a nested binding rebinds between the exit and the handle's own scope
  is not released at that exit (on any backend, so they all agree); it is
  left to a collection.

### Representation and lowering

* HIR: two more side tables of `coroutines`, `exits` (an exit statement ->
  bindings) and `errorExits` (a call, or a handled call's `handle` -> error
  name -> bindings), printed as flags and read back by `hir/read.tcl`:

  ```
  e83 bind b36 step : Coroutine{resume: unit, yield: V, errors: []}
  e99 return -> e80 : never exit-release=b36
  e105 call block(e71) : int error-release=Boom=b36
  e113 fail Boom : never exit-release=b36
  e114 call native(+) : int release=b36
  ```

* Core IR (`hir::lower::Seq`, `hir::lower::ReleasingOnError`): the releases
  before the exit statement, or `(bind coroutine#kept#E V)`, the releases,
  `(return (ref coroutine#kept#E))`; a call with an error edge becomes
  `(handle CALL E (block {} RELEASES... (fail E)) ...)`, and a `handle` gets
  those handlers added. An error is its name, so failing with the same name
  again is the same propagation.
* The Tcl compiler from HIR (`CompileForm`, `ReleasingOnError`): the
  releases around the exit's value; a call with an error edge runs in a
  `catch` whose propagate-error completion (code 5) of such an error
  releases, and every abrupt completion goes on with `return -options`
  (`CompileHandle`'s technique); a handled call gets a switch arm per
  unhandled name.
* Native (`native::lower::Expr`, `Call`, `Handle`): `op corelease` before
  `ret`/`retmulti`, the loop's jump or `faildeclared` (after the value for
  the handles it uses); a call with an error edge is bracketed by
  `pusherrorexit PAD`/`poperrorexit`, and the pad tests the pending error
  per name (`declarederroreq`), releases, and `reraise`s it unchanged
  (`Handle`'s technique, with no handler); `Handle` releases for the names
  its handlers do not handle before its own `reraise`.

### Evidence

* `co-exit-release-placement`: what each exit releases, before or after its
  value: a `return` before the last use (before its value) and one whose
  value resumes the handle (after it); a `fail`; an unhandled call's `Boom`;
  a handled call whose handler handles `Boom` (nothing) but not `Late`
  (released); a `break` and a `continue` (only the loop body's handle, not
  the function's); a shadowed name (nothing); a self tail call (its `return`
  releases before the call, the call has no error edge); a `return` whose
  value both fails and resumes (released after the value and on the
  value's error); a moved-from handle (nothing; its new owner instead); a
  handle bound after the exit, or last used before it (nothing).
* `co-exit-release-values`: one function per exit kind, called for k = 0..6
  (7 x 8 results, two rows checked by hand): identical on every backend,
  including a handler that resumes the handle after a handled error and a
  function using its handle after a loop that broke and continued.
* `co-exit-release-tcl-runtime`: after those 7 rows no Tcl coroutine is
  alive, on the interpreter and on both Tcl compiler routes (57 were before).
* `co-exit-release-native-stacks`: 2,100 rows, the table under "Why"; the
  same value under GC stress.
* `co-exit-release-hir-text`: the flags print, read back to the same text,
  and lower to the same Core IR.
* The fuzzer (point 52) generates `held` coroutines (constructed mid-function,
  resumed only at its end, so later returns, fails and failing calls leave
  them suspended) and `scan` loops (a coroutine per iteration, `break` and
  `continue` before its resume). Its oracle predicts, function by function
  in source order, what every exit releases, and that no other exit
  releases anything; a release of the wrong handle (one still resumed after
  the loop, after a handled error) shows as a resume of a released
  coroutine on every backend. Over 300 programs (seeds 1-100, 3000-3099,
  7000-7099, every backend), 394 releasing exits were predicted and checked,
  with no disagreement.
* Mutation: 11 more mutants, all killed (point 53): no exit releases
  anything; a `break`/`continue` releases the whole function's handles; a
  handled error releases too; every handle released before the exit's
  value; an exit after the last use releases again; a shadowed handle
  released; and each lowering in turn not releasing (Core IR on a call's
  error, the Tcl compiler before an exit and on a call's error, native
  before a `return` and in a call's failure pad).
* Regression: `tests/all.tcl` 6568 passed on the interpreter, 6564 passed
  and the same 4 skipped (`coreScoping`) on the Tcl compiler, and the same
  under `BOTLISH_NATIVE_GC_STRESS=1`; native coverage 2604 native, 3837
  independent, 67 passed-partial, the same 60 unsupported, 0 failed;
  `cargo test --release` 194 + 31 passed, also under stress; the scalar
  assembly audit byte-identical (no program in it uses coroutines).

### Measurements

`bench/coroutines.tcl -runs 5 -n 4000` (200,000 operations natively), its
`exit-*` rows: a construction abandoned while suspended on each kind of
exit, against the same function building the struct instead. Before is the
parent commit running the same benchmark file; nothing else ran meanwhile.

| construction abandoned on | Cranelift before | Cranelift after | Tcl compile before | Tcl compile after |
|---|---:|---:|---:|---:|
| an early return | 4,705 ns | **449 ns** | 115 us | 104 us |
| a fail | 5,316 ns | **489 ns** | 127 us | 203 us (*) |
| a callee's propagated error | 4,655 ns | **521 ns** | 129 us | 118 us |
| a break | 4,640 ns | **458 ns** | 151 us | 139 us |
| (its last use, for comparison) | 464 ns | 451 ns | 90 us | 99 us |

(*) An outlier that did not reproduce: measured alone twice more, the same
row was 91 us after against 103 and 111 us before.

Natively an exit now costs what the last use costs: the same mechanism as
under [Release at the last use](#release-at-the-last-use) ("Why"), a dead
coroutine's stack going straight back to the pool instead of through a
collection. An error edge costs a little more than a plain return (521
against 449 ns: the call's failure pad tests the error and reraises it). On
the Tcl backends the differences are within the noise of these runs (the
rows of unchanged operations moved by up to 15% between the two); what
changes there is memory: an abandoned coroutine's Tcl coroutine and frames
no longer live until the run ends (`co-exit-release-tcl-runtime`). Resume
costs and the memory of coroutines still held are unchanged.

### What it does not cover

* **A suspended coroutine's own frames.** Releasing a suspended coroutine
  discards its frames (natively) or unwinds them by a Tcl error no Botlish
  handler catches (Tcl): their exits do not run, so a coroutine one of those
  frames held is left to a collection (natively) or to the end of the run
  (Tcl).
* **A shadowed name at the exit** (above), and the post-value release of a
  `return` whose value is a self tail call using the handle (the backends
  that restart the function never reach it).
* **Programs the discipline rejects** that run anyway (`-strict 0`), as
  before.

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
| `hir/affine.tcl` (AFFINE-VALUES.md) | since the affine-values milestone: the ownership analysis and release elaboration (moved out of `hir/coroutines.tcl`, generalized) |
