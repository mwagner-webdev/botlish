# AFFINE-VALUES.md

General affinity and callable abstraction.

> Affinity is a compositional property of values, not a property of
> coroutines. A coroutine handle is the one primitive affine value today; a
> struct, an anonymous struct or a List that owns an affine value is affine
> too, by derivation from its type. `Fn` and `Coroutine` share one static
> callable-contract model (arguments, result, errors) while remaining
> distinct callable kinds.

The architectural theorem the milestone establishes:

> Botlish values carry compositional ownership semantics independently of
> their representation or callability. Unrestricted values may participate in
> ordinary value semantics; affine values have one usable owner and move
> through bindings, calls, returns, aggregates and containers with
> deterministic cleanup. `Fn` and `Coroutine` share one static
> callable-contract model, while exact function identity, coroutine
> lifecycle, and affinity remain separate semantic facts.

COROUTINES.md is the milestone this one generalizes (coroutine semantics are
unchanged; their ownership discipline and release elaboration now live in
`hir/affine.tcl` and apply to every affine value).

## Contents

* [Terminology](#terminology)
* [The principal program](#the-principal-program)
* [Report](#report) -- the 65 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## Terminology

| term | meaning |
|---|---|
| unrestricted value | a value whose type permits ordinary duplication and aliasing: every scalar, String, function value, struct and List that owns nothing affine |
| affine value | a value whose type says ordinary operations preserve at most one usable owner: a coroutine handle, and every struct, anonymous struct or List that owns one |
| move | the transfer of an affine value's ownership to a new owner (a binding, a parameter, a result, a struct field, a List element); the old owner is dead from then on |
| release (drop) | the deterministic cleanup where an owner dies still owning its value: a coroutine's suspended execution is unwound and its resources returned; an aggregate releases what it owns |
| callable contract | what calling a value may do: its arguments, its result, its declared errors (`args`, `return`, `errors`) |
| callable kind | what a call means: an exact function (a direct call of known code), an ordinary callable value (`Fn`, an indirect call), or a coroutine (a resume of one evolving execution) |

An affine value may be dropped without ever being used; it simply may not
be implicitly duplicated. Nothing in this milestone is a reference, a
borrow or a lifetime: a move transfers the value itself (the same runtime
object, one new owner), and nothing is ever "used exactly once". (Below, a
*reference* is always HIR's `ref` expression -- a use of a binding's name in
source -- never a pointer-like value.)

## The principal program

```botlish
struct Message:
    value: int

struct Event:
    value: int

struct Running:
    name: str
    step: Coroutine{
        args: [Message],
        return: Event,
        errors: []
    }

fn worker(seed: int, resume Message) -> Event:
    message = yield Event {value: seed}
    return Event {value: message.value}

fn invoke(callable, argument):
    callable(argument)

fn make(seed: int) -> Running:
    coroutine {step} = worker(seed)

    Running {
        name: "worker",
        step: step
    }

running = make(10)

{step} = running

result = invoke(
    step,
    Message {value: 20}
)
```

`result` is `Event {value: 20}` on every backend (Tcl interpreter, Tcl
compiler, Cranelift generic and specialized), and:

* `worker`'s construction creates one coroutine execution, which `Running`
  owns: `step` is moved into the field (a later `step(...)` in `make` is
  `USE-AFTER-MOVE`);
* returning `Running` moves that ownership to the caller's `running`;
* destructuring `running` moves the coroutine into `step` (`running` is dead
  afterwards: even `running.name` is `USE-AFTER-MOVE`);
* `invoke` is specialized against `Coroutine{args: [Message], return: Event,
  errors: []}` -- a clone `invoke<Coroutine{args:[Message],return:Event,errors:[]}>`
  whose call is a resume -- never against `Fn`;
* passing `step` moves ownership into `invoke`'s parameter; calling it
  resumes the original continuation (the worker returns the message's
  value); no alias is created and no continuation is copied;
* no runtime ownership bookkeeping exists: natively the clone is
  `coresume`, `corelease`, `ret`;
* the coroutine is released where `invoke`'s parameter dies (right after
  the resume, its last use);
* `invoke(double, 4)` in the same program is the ordinary generic call of an
  exact, unrestricted function, which stays usable at its binding
  (`double(5)` afterwards).

`tests/affine.test`'s `af-principal-theorem` pins this program (with the
ordinary-function call added) and the clone; `af-principal-callable`,
`af-principal-preserve`, `af-principal-struct` and `af-principal-list` pin
the brief's principal programs 59-62, `af-exact-alias`, `af-explicit-fn` and
`af-generic-dual` its 63-65.

```botlish
a = ordinary_function
b = a
```

still aliases the exact function freely (`af-exact-alias`), while

```botlish
b = affine_value
use(affine_value)
```

is `USE-AFTER-MOVE` for every affine value -- a coroutine, a struct owning
one (`af-aggregate-move`), a List of them (`af-principal-list`).

## Report

### 1. Source grammar for `Coroutine{...}`

```
CoroutineType := "Coroutine" "{" Field ("," Field)* ","? "}"
Field         := "args" ":" "[" (Type ("," Type)*)? "]"
               | "return" ":" Type
               | "errors" ":" "[" (ErrorName ("," ErrorName)*)? "]"
```

exactly `Fn{...}`'s grammar (`surface/parser.tcl`'s `FnType`, one procedure
for both heads): named fields in any order, `args` and `return` required,
`errors` optional (omitted means `[]`), duplicates, unknown fields,
positional type arguments (`Coroutine[...]`) and a `target`/`context` field
rejected with the same messages, worded "coroutine type". Newlines inside
the braces are free (the principal program's multi-line `step` field). The
coroutine-specific restriction is semantic, checked at resolution
(`hir/resolve.tcl`'s `ResolveTypeExpr`): `args` has zero entries (a
coroutine resumed without a message) or one named struct type (its message);
more than one entry, or a scalar, String or other non-struct entry, is
`COROUTINE-CONTRACT` (`af-contract-forms`). `Coroutine` is a reserved type
name (`hir/structs.tcl`), like `Fn`.

### 2. Relationship to the existing `Fn{...}`

One notation, one contract, two kinds. Both parse to the surface form
`{fn {args ... return ... errors ...}}`; a `Coroutine` carries one more
named entry, `kind coroutine` (so every walker of a type expression's
argument and return types handles both without change). Both resolve to a
HIR type whose second element is the same canonical contract dict, both
show in the same notation (`Fn{args: [...], return: ..., errors: [...]}`,
`Coroutine{args: [...], return: ..., errors: [...]}`), and both are checked
by the same contract rules (point 5). What differs is the head of the type:
the callable kind.

### 3. Callable-contract internal representation

`{args {T1 ...} return R errors {E1 ...}}` (errors sorted, unique): the
second element of `{fn CONTRACT}` and of `{coroutine CONTRACT}`
(`hir/types.tcl`'s header, `MakeFn`, `MakeCoroutineType`). An exact native
or block has a contract too, through its `structuralOf` supertype.
`hir::types::Contract TYPE` returns it for every callable type. The old
coroutine type `{coroutine RESUME OUTWARD ERRORS}` (COROUTINES.md point 30)
is gone: a coroutine's resume protocol is its `args` (`{}` or one message
type), its outward type its `return`, its root's declared errors its
`errors` (`CoroutineResume`, `CoroutineOutward`, `CoroutineErrors` read
them). HIR text reads the notation back (`hir/read.tcl`'s `ParseType`).

### 4. Callable-kind representation

The type's head (`hir::types::CallableKind`): `block`/`native` (exact),
`fn`, `coroutine`. Call *checking* reads only the contract: arity, argument
admissibility, result type and the declared errors a call charges are
computed by the same code for a `Fn` and a `Coroutine` callee
(`hir/types.tcl`'s `Call`; `hir/range.tcl`'s `VerifyStructuralCall`;
`hir/completions.tcl`'s structural-call branches, which charge a
coroutine's `errors` exactly like a `Fn`'s). Call *lowering* dispatches by
kind, statically: an exact callee is a direct call, a `Fn` an indirect call
(`callvalue`), and a `Coroutine` a resume -- a typed call whose callee is a
coroutine is rewritten, after checking, into the `coroutine#resume` native
(`hir::coroutines::ElaborateResumes`), so no backend ever sees a call whose
meaning depends on a run-time kind.

### 5. Explicit `Fn` vs `Coroutine` compatibility rule

A `Coroutine` type admits only coroutine handles whose contract is
compatible (`CoroutineMismatch`: the `Fn` rules -- contravariant arguments,
covariant result, error-set subset). A `Fn` type admits exact functions and
function values whose contract is compatible, never a coroutine handle.
Neither kind is ever a subtype of the other, whatever their contracts
(`hir::types::subtype`). Passing a coroutine where a `Fn` is expected is
`COROUTINE-NOT-FUNCTION` ("a coroutine handle is not a function value:
Coroutine and Fn are distinct callable kinds, even with the same contract");
a function where a `Coroutine` is expected is `TYPE` ("only a coroutine
handle is a Coroutine ...") (`af-explicit-fn`). Two coroutine types of
different contracts are a `TYPE` error naming the part: "resume protocol
mismatch", "message type mismatch", a result or an error-set incompatibility
(`af-contract-compat`, `af-contract-error-set`). Coroutines of different
constructor functions with one contract have one type (one List holds them).
The least upper bound of two coroutine types is a coroutine type of the
joined contract; of a coroutine and anything else, `any` (rejected as an
erasure, point 38). There is no implicit conversion in either direction.

### 6. Generic/untyped callable constraint handling

An untyped parameter the body calls has an *inferred* callable contract
(INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md), recorded as a `Fn{...}` entry
type. That contract is a constraint on the argument, not a demand for a
`Fn`: a coroutine handle whose contract satisfies it is admitted
(`hir::signatures::CallableAdmits`), at an untyped parameter only -- an
explicitly declared `Fn` parameter still rejects it (point 5). The semantic
instance of such a call is entered with the handle's own coroutine type, of
its own callable kind (`hir/semantic.tcl`), so the body is checked as
resuming a coroutine (`af-generic-inferred-contract`: a zero-message
`flip()` coroutine given to `fn ask(f) -> bool: if f(): ...`, whose inferred
contract is `Fn{args: [], return: bool, errors: []}`).

### 7. Generic callable specialization

A call that gives an affine argument to an untyped parameter always gets its
semantic instance (an affine argument decides the specialization, like a
trait witness; past the instance budget the instance is keyed by its affine
entry types alone). Checked HIR that contains one (`hir::traits::
NeedsAffinePlan`) is built a second time through the trait
monomorphization (`hir::traits::Plan`, TRAITS.md): the instance's affine
entry types become *clone witnesses* (`AffineWitnesses`, joined with any
trait witnesses in `CloneWitnesses`), the clone
`invoke<Coroutine{args:[Message],return:Event,errors:[]}>` is declared with
those types on its untyped parameters (`hir/resolve.tcl`'s `CloneHead`), and
the call is resolved to the clone. The source function stays for every other
call: `invoke(double, 4)` in the same program calls the ordinary generic
`invoke`. Specialization is transitive (a generic function passing its
affine argument to another generic one, or recursing, calls clones:
`af-generic-transitive`) and crosses modules (the clone resolves the
defining module's bindings: `af-generic-module`). A generic function
declared inside another function, or one whose requirement includes a
context trait, cannot be specialized per argument type:
`AFFINE-GENERIC-NESTED-UNSUPPORTED` (`af-generic-nested`). If no instance
exists for such a call, `AFFINE-INSTANCE-BUDGET` -- there is no runtime
dispatch to fall back to.

### 8. Exact-function alias preservation

An exact function type is unrestricted (`hir::types::IsAffine` is 0 for
every `block`, `native` and `fn` type, including a `Fn` whose arguments are
affine: the function value owns nothing). `a = positive; b = a` is two
aliases of one identity: no move, no `move` flag in HIR text, no ownership
table at all (`dict get $hir affine` is empty: the analysis is not entered),
and natively the calls stay direct (`af-exact-alias`: no `closure` and no
`callvalue` in the program).

### 9. Central affinity query

`hir::types::Affinity TYPE` -- `affine` or `unrestricted` -- and its
predicate `hir::types::IsAffine` (with `AnyAffine` for a type list). Every
ownership decision asks only this: `hir/affine.tcl` never asks whether a
value is a coroutine, so a future affine root needs no change there.
`af-hir-affinity` pins the query's answers.

### 10. Primitive affine roots

Exactly one: the coroutine handle (`hir::types::AffineRoot`: a
`{coroutine ...}` type, or the core type `coroutine` of a native's
parameter). Every other affine type is derived.

### 11. Struct affinity derivation

A named struct is affine iff one of its field types is affine
(`hir::structs::IsAffine`, recursive, cycle-safe, cached per declaration
identity and reset whenever the declarations change); an anonymous struct
the same, structurally. A struct's affinity is a fact of its declaration:
`Running` above is affine because of `step`, not because of any value.

### 12. List affinity derivation

`List[T]` is affine iff `T` is (including a List type's parameter evidence).
A List literal of coroutines is `List[Coroutine{...}]`, inferred or
annotated (`af-list-ownership`). `MutableArray[T]` and `ImmutableSet[T]` of
an affine `T` are `AFFINE-CONTAINER-UNSUPPORTED`: a mutable array's slots
would need move-out and replace operations, a set needs equality.

### 13. Affine binding states

Static only, per affine binding (a local or parameter of affine type):
`live`, `{moved MOVE...}` (moved on every path, by those moves) or `{maybe
MOVE...}` (moved on some path), or the whole state `dead` for a path that
cannot complete normally. A parameter starts `live`. Nothing exists at run
time.

### 14. Generalized move analysis

Every reachable affine-typed expression has exactly one consumer
(`hir::affine::Consumer`):

* **move** -- the value of a binding statement, a call argument (into the
  callee's parameter), a resume's message, a struct field, a List literal's
  element, a `return`, a function's result, an `if`'s or handler's value,
  a `break` value, a coroutine construction's argument (captured by the
  thunk that runs once), and a destructuring's read of an affine field out of
  its temporary;
* **use** -- the handle of a resume (consume-and-replace behind the same
  owner), of `coroutine::done?`, of a coroutine's start; a read of an
  unrestricted field; `list::length`; a bare reference statement;
* **discard** -- a statement whose value nobody receives (a fresh value is
  released right after it);
* **rejected** -- everything that would duplicate, alias or hide ownership
  (points 27, 31, 37-39).

A forward dataflow over each function body and the top level, in evaluation
order, checks every use and move against the binding's state:
`USE-AFTER-MOVE` for a moved binding, `AFFINE-NOT-DEFINITELY-LIVE` for a
maybe-moved one, each naming the moves that reach it. The diagnostics are
COROUTINES.md's, now worded for any affine value ("its affine value was
moved").

### 15. Generalized branch joins

At an `if` or handler join, a binding moved on some paths only is `{maybe
...}`; moved on all (at different places), `{moved ...}`. A path that does
not complete normally (`return`, `fail`, `break`, `continue`, a `never`
expression) does not reach the join, so a move in a branch that returns
leaves the binding live on the other path. Loops iterate to a fixed point
with their `continue` states; `break` states join the exit; a loop body's
own bindings are per iteration (`af-aggregate-branch`).

### 16. Affine function arguments

An argument of affine type moves into the callee's parameter: the caller's
binding is dead after the call (`af-call-transfer`), whether the parameter
is declared (`Coroutine{...}`, an affine struct or List) or generic (the
call's specialization, point 7). Several affine arguments move in left to
right; a value can move through any number of call levels.

### 17. Call-argument ownership temporaries

Between an affine argument's evaluation and the callee's entry, the
argument is owned by a *pending temporary* of the call: the value, already
moved out of its source binding, not yet in a parameter. The analysis
records, for every exit point inside a later argument, which earlier
arguments are pending there (`hir::affine::PendingBefore`; a reference's
pending temporary is still its binding at run time, any other value's is
the expression's own value). The Tcl backends name such a value: HIR
lowering evaluates the call's operands into named locals first (an ANF
block, `hir/lower.tcl`'s `Pending`) only when some release names one; the
Tcl compiler records the operand's Tcl variable (`NoteTemp`); native
lowering the operand's register (`fn temps`).

### 18. Argument-evaluation failure cleanup

If a later argument leaves abruptly -- a declared error it propagates, or a
`return`, `break`, `continue` or `fail` inside it -- the call never happens
and its pending temporaries are released on that exit; the source binding
stays moved (no ownership rollback). In Core IR:

```
take(s2, might_fail(k))
=>
{call {ref take} {ref s2}
    {handle {call {ref might_fail} {ref k}}
        Boom {block {} {call {ref coroutine#release} {ref s2}} {fail Boom}}}}
```

(`af-call-pending`: `test_aff_live()` sees no coroutine left after the
failing call is handled; `af-call-pending-hir`: the error edge names the
moved binding, or the value's own expression when it was not a binding).

### 19. Affine parameters

A parameter is an owner exactly like a local: live on entry, released at
its last use when the function still owns it there (`release=` on that
statement), released by every exit that leaves while it is owned, and moved
by a move like any binding (`af-call-release`, `af-call-transfer`'s
repeated resumes of a live parameter).

### 20. Affine function results

A function's result -- its last statement or a `return` value -- moves to
the caller when the declared (or inferred) result type is affine
(`af-call-return`: a parameter returned, a new value returned). An affine
value flowing into a result type that is not affine is an erasure
(point 38).

### 21. Return ownership transfer

A `return` (or a function's last statement) that moves a binding's value
does not release that binding: its exit state records the move. The other
owned bindings the exit leaves are released *before* the value is evaluated,
except those the value refers to (without moving them), released *after* it
(`hir::affine::releasesOnExit`): `return s(m).value` resumes `s` and then
releases it. The caller owns the result: its own release happens where its
binding dies (`af-call-return`, `af-aggregate-return-fail`).

### 22. Propagated-error ownership cleanup

A call that propagates a declared error leaves every sequence up to its
handler (or the function): the analysis lists, per error name, the owned
bindings and pending temporaries that exit releases (`errorExits`); an error
its handler handles releases nothing (the handler continues with them). Each
backend wraps such a call in a catch that releases and re-raises the same
error (Core IR above; the Tcl compiler's `ReleasingOnError`; native
lowering's landing pads in `Call`/`Handle`). A `fail` releases like any
exit. A function that fails releases its own affine parameters
(`af-call-release`: the caller's binding stays moved, the coroutine is
released by the callee's exit).

### 23. Struct construction transfer

Each affine field value moves into the struct (`af-principal-struct`:
`Running {name: "worker", step: step}` makes `step` dead). The struct is the
one owner; moving the struct moves everything it owns, by representation
transfer (natively a struct travels as its fields: `wrap` returns
`retmulti %name %step`, point 53).

### 24. Struct construction failure cleanup

Field values are pending temporaries of the construction exactly as call
arguments are of a call (points 17, 18): a later field that fails releases
the affine fields evaluated before it (`af-call-pending` includes a struct
whose second field fails).

### 25. Affine struct destructuring

`{step, name} = running` consumes `running`: it moves into a destructuring
temporary (`destructure#N`), and each named affine field is moved *out of
the temporary* into its binding (the one partial move, which only a
destructuring makes: the temporary is never named in source, so nothing can
observe its moved-out fields). Unrestricted fields bind normally. Nested
patterns destructure recursively (`af-aggregate-destructure`). HIR text
states what was moved out: `bind b31 destructure#770 : Running move
consumed=step`.

### 26. Partial destructuring cleanup

The temporary's release (right after the destructuring, its last use)
drops only what it still owns: its descriptor excludes the consumed fields
(`hir::affine::Descriptor TYPE EXCLUDE`). `{name} = running` therefore
releases `running.step` immediately; `{step} = running` releases nothing
(`af-aggregate-destructure`, `af-drop-native`'s `{name} = r` rows).

### 27. Affine field projection restriction

`running.step` outside a destructuring is
`AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE` ("reading it would make a second
owner of what `running` owns, and a field cannot be moved out of a struct
that stays usable (consume the struct with a destructuring instead: "{step}
= running")"), reported once, at the receiver. Reading an unrestricted field
(`running.name`) is a use: the struct stays live (`af-aggregate-field-read`).
A projection of an unrestricted field of a *fresh* affine value (`make().name`)
is `AFFINE-TEMPORARY-UNSUPPORTED`: nothing would own the rest.

### 28. List construction ownership

A List literal's affine elements move into the List (`af-principal-list`:
`steps = [a, b]` makes `a` and `b` dead).

### 29. List whole-value movement

A List of affine values moves whole: bound to another name, passed as an
argument, returned (`af-list-ownership`). `list::length` reads it without
moving it.

### 30. List recursive cleanup

A List's release drops every element, first to last, by the element type's
descriptor (`"l"D`): a List of coroutines releases each coroutine, a List of
affine structs drops each struct (`af-drop-order`: `[Pair {first: make(1),
second: make(2)}, Pair {first: make(3), second: make(4)}]` releases the
coroutines in the order 2, 1, 4, 3). The same on an early exit
(`af-list-ownership`).

### 31. Unsupported affine List operations

Every List operation that would copy an affine element out of a List that
still owns it is `AFFINE-LIST-OPERATION-UNSUPPORTED`: `list::at`,
`list::append`, iterating a List of affine values (`loop s in xs`: the loop
variable would be a second owner), and a collecting loop whose body
produces affine values (its List would own them across abrupt exits)
(`af-list-operations`). No List move-out API was added.

### 32. Generalized last-use release

Every affine binding -- a coroutine, an affine struct, an affine List, a
local or a parameter -- that still owns its value after the last statement
of its own sequence referring to it is released right after that statement
(`releases`), and a discarded fresh affine value right after its statement
(`af-join`: a discarded `make(1)`, a discarded `Running {...}` and a
discarded `[make(3)]` leave no coroutine alive). How it is released is the
type's business (point 34), not the analysis's.

**Path releases** (MUTABLE-VECTOR.md). A binding *maybe moved* by its last
statement -- moved on some paths through it only -- is released on each
path that still owns it, at the end of that path inside the statement: an
`if` branch's last statement (an empty `else` is given a `unit` statement
to hold it), a handler body's last statement, an infinite `loop`'s
`break` (`hir::affine::PathReleases`). It is never released after the
join: there a path that moved it may have given it to an owner that lives
on -- a vector (`if not coroutine::done?(step): queue.push(step)`), or the
join's own value (`x = if c: step else: make(2)` -- which the earlier
after-the-join release got wrong: it released the coroutine `x` owned). A
path no statement ends cannot hold a release: a handled call completing
normally while a handler moved the binding, or a counting or iterating loop
running to its end while a `break` path moved it, is
`AFFINE-PATH-RELEASE-UNSUPPORTED` (move the value on every path, or on
none). `tests/mutable-vector.test`'s `mv-path-release`;
`tests/coroutines.test`'s `co-release-placement` now expects the release
inside the branch.

### 33. Generalized early-exit release

`return`, `fail`, `break`, `continue` and a call propagating a declared
error release every binding of every sequence they leave that still owns its
value there (at or before its last use), and the pending temporaries they
abandon (`exits`, `errorExits`); for `break`/`continue` only the loop body's
sequences. Any affine binding, by its type's descriptor
(`af-aggregate-return-fail`, `af-list-ownership`'s early exit). A binding
whose name a nested binding shadows at the exit is left to the collector
(a release names its binding; COROUTINES.md "Release on every early exit").

### 34. Aggregate drop glue

The type decides how a value is released (`hir::affine::DropPlan`): a
coroutine by `coroutine#release`; an aggregate by `affine#drop(V,
DESCRIPTOR)` (Tcl) / `affinedrop %v %d` (native), with a static
*descriptor* of where the type's affine components are:

| descriptor | drops |
|---|---|
| `c` | a coroutine handle |
| `l`D | every element of a List by D, first to last |
| `s`N`.`(SLOT`.`D)* | the N struct fields at those layout slots by their D, last-declared first |

`Running` is `s1.1.c` (its slot-1 field is a coroutine), `List[Running]`
`ls1.1.c`, `Pair` `s2.1.c0.c`. The descriptor is type-directed: no
unrestricted field and no List of unrestricted values is ever visited; a
struct that owns nothing affine any more (a destructuring temporary whose
affine fields were all moved out) has no descriptor and no release. The drop
order rule: struct fields are released last-declared first (the reverse of
construction), List elements first to last (`af-drop-order`).

### 35. Coroutine drop integration

A descriptor's `c` is the coroutine release of COROUTINES.md ("Release at
the last use"): a suspended coroutine's frames are unwound without running
Botlish code (Tcl: a release marker no handler catches; native: its stack
goes back to the pool), a completed or failed one drops its cached result.
Releases are idempotent (a released handle's second release returns at
once), so a maybe-moved binding and its new owner may both release, and they
never change a value.

### 36. `coroutine::done?` integration

`done?` is a use (`{use observe}`) of a handle however ownership reached it:
a parameter, a destructured binding, a function's result, a generic HOF's
result -- it never moves it (`af-done-generalized`). Like a resume, it
requires an owner: `done?(make(1))` is `AFFINE-TEMPORARY-UNSUPPORTED`.

### 37. Closure-capture restriction

A nested function capturing any affine binding is
`AFFINE-CAPTURE-UNSUPPORTED` (a closure may be called any number of times
and copied freely, so capturing would alias the one owner)
(`af-restrictions`). A coroutine construction's thunk captures its argument
temporaries and moves them (it runs once): `af-call-construction-argument`,
a supervisor coroutine that owns its child.

### 38. `any`/erasure restriction

An affine value flowing into a position whose type is not affine --
`any`, an untyped native argument, a parameter declared `any` or a
non-affine type, a field or element type that is not affine, a function
result type that is not affine, the program's result, a module binding --
is `AFFINE-ERASURE-UNSUPPORTED`: that position does not carry ownership, so
the value would be duplicated or lost (`af-restrictions`). Unlike a `Fn`, a
coroutine type is never cut to `any` by the aggregate type bound.

### 39. Equality/hash interaction

`==`, `hash`, `immutable_set::from_list` and `immutable_set::contains` of an
affine value -- a handle, an affine struct, an affine List -- are
`AFFINE-EQUALITY-UNSUPPORTED`: comparing or hashing would observe the
identity of what it owns (`af-restrictions`; the coroutine fuzzer's
storage fault `kept = current == current`).

### 40. Function-value restriction preservation

A coroutine is still not a function value (`COROUTINE-NOT-FUNCTION`, point
5) and a function that may yield still cannot become one (`UNWRAPPED-YIELD`,
COROUTINES.md point 21). A function *value* receiving an affine argument must
own it: a typed function satisfies `Fn{args: [Coroutine{...}], ...}`, an
untyped one does not (it would need a specialization the indirect call
cannot select) (`af-contract-fn-param`). A `Fn` value itself stays
unrestricted whatever its contract.

### 41. Context interaction

None new. A coroutine's context providers are still fixed at its
construction (COROUTINES.md point 39); moving it through calls, structs and
generic functions changes nothing about them. A generic function whose
requirement includes a context trait is specialized once per context, not
per argument type, so giving it an affine argument at an untyped parameter
is `AFFINE-GENERIC-NESTED-UNSUPPORTED` (declare the parameter's type).

### 42. Trait interaction

The affine specialization *is* the trait monomorphization's machinery
(point 7): a function can have trait parameters and affine untyped
parameters at once, and its clone's witnesses are both. A trait view's
affinity is its concrete witness's (`IsAffine` of `{trait ID WITNESS}`), so
a trait-typed value whose witness is affine is moved like its witness.
`tests/traits.test` and its mutants pass unchanged.

### 43. HIR representation

Types: `{coroutine CONTRACT}` (point 3). Analysis results, in the HIR dict
under `affine` (absent work for a program with no affine type:
`hir::affine::Used`):

| key | contents |
|---|---|
| `moves` | binding statement -> the binding whose value it moves |
| `moveRefs` | moving reference -> where it moves (bind, arg, message, field, element, return, result, join, break, capture, out) |
| `consumed` | destructuring temporary -> the affine fields moved out of it |
| `releases` | statement -> items released after it |
| `exits` | `return`/`fail`/`break`/`continue` -> items released as it leaves |
| `errorExits` | call (or handled call's `handle`) -> error name -> items |

An item is a BindingId or an ExprId (a discarded value or a pending
temporary).

### 44. HIR/debug evidence

HIR text states each fact on its node and reads back to the same text
(`hir/format.tcl`, `hir/read.tcl`; `af-hir-text`):

```
e72 bind b30 r2 : Running move
    e73 ref b29 r : Running move
e74 bind b31 destructure#770 : Running move consumed=step
    e75 ref b30 r2 : Running move
e76 bind b32 step : Coroutine{args: [Message], return: Event, errors: []}
    e77 project step : Coroutine{args: [Message], return: Event, errors: []}
        e78 ref b31 destructure#770 : Running move
...
e95 bind b36 ys : List[Coroutine{args: [Message], return: Event, errors: []}] move release=b36
    e96 ref b35 xs : List[Coroutine{args: [Message], return: Event, errors: []}] move
```

(`move` on a moving reference and on a binding statement whose value moves;
`consumed=FIELDS` on a destructuring temporary; `release=ITEMS`,
`exit-release=ITEMS`, `error-release=NAME=ITEMS` on the statement, exit or
call that releases.) The specialized clone is an ordinary binding:

```
e49 bind b23 invoke<Coroutine{args:[Message],return:Event,errors:[]}> : block(e50)/2 -> Event
    e50 block s10 (b24 f:Coroutine{args: [Message], return: Event, errors: []}, b25 x) captures () clone () : block(e50)/2 -> Event
        e51 call native(coroutine#resume) : Event release=b24
            e52 ref b24 f : Coroutine{args: [Message], return: Event, errors: []}
```

### 45. Core IR lowering

`hir/lower.tcl` writes every release out: after a statement
(`hir::lower::Seq`), before an exit (and after its value, for an item the
value refers to), and on a call's error edge as a handler-shaped catch that
releases and re-raises the same error (`ReleasingOnError`, point 18). A
release is `coroutine#release(x)` or `affine#drop(x, "DESCRIPTOR")`:

```
fn g() -> int:              {bind g {block {}
    coroutine {step} = ...      ... {bind r {struct {Running name step} name {const str b} step {ref step}}}
    r = Running {..., step}     {project {ref r} name}
    r.name                      {call {ref affine#drop} {ref r} {const str s1.1.c}}
    7                           {const 7}}}
```

Pending temporaries become named locals when (only when) a release names one
(point 17). HIR rebuilt from this Core IR (the `compile` route) recognizes the
written releases and does not elaborate them again
(`hir::affine::WrittenReleases`).

### 46. Tcl interpreter behavior

It runs the Core IR above; `affine#drop` is `core/affine.tcl`'s native,
which parses the descriptor once (cached), walks the value by it and calls
`core::coroutines::releaseImpl` for each `c`. No interpreter change beyond
the native.

### 47. Tcl compiler behavior

`compiler/compiler.tcl` compiles releases from the same tables
(`CompileRelease`, by `DropPlan`), exits' before/after releases, and error
edges (`ReleasingOnError`, a `catch` that releases on a propagate-error
completion of a listed name and re-raises with `return -options`). A pending
temporary that is not a binding is the operand's own Tcl variable
(`NoteTemp`, `hir::affine::temporaries`).

### 48. Native lowering

`native/lower.tcl` lowers a release item to `op corelease %r` (a coroutine)
or `str "D"` + `op affinedrop %v %d` (an aggregate) (`ReleaseHandles`,
`DropAccess`). A *virtualized* aggregate (a struct the escape analysis keeps
in registers, never allocated) is dropped by applying its descriptor to its
field registers directly; a discarded construction that is never built
drops its components (`hir::affine::Components`); a pending temporary is the
register its operand was evaluated into; error edges are landing pads that
release and re-raise. A move is no instruction: the same register (or field
registers) is used by the new owner.

### 49. Runtime changes

* `core/affine.tcl`: the `affine#drop` native (Tcl backends).
* `native/src/runtime/affine.rs`: `rt_affine_drop` (descriptor walk; never
  allocates, never fails, no safepoint); NIR op `AffineDrop`/`affinedrop`
  (`nir.rs`, `ops.rs` -- not in `op_may_allocate` -- `clif.rs`, `mod.rs`).
* `core/coroutines.tcl`: two test-only probes, `releaseTrace` (release order)
  and `releaseCalls` (every release call, for the fuzzer's exactly-once
  check), both `none` (off) by default.

There is no ownership object, moved flag, reference count, owner count or
dynamic callable dispatch anywhere (`af-native-runtime-source` greps for
them).

### 50. GC interaction

None needed. A move is a register or field transfer of the same object, so
the collector's roots are unchanged; `affinedrop` does not allocate (it is
not a GC safepoint and needs no stack map); a released coroutine's stack
returns to the pool exactly as a raw handle's release does. Anything left
unreleased (a shadowed binding at an exit, a program the discipline rejects
under `-strict 0`) is still collected by the existing sweep of suspended
coroutines. `af-drop-native` runs 1000 rows of structs, Lists and
destructurings, each owning abandoned coroutines, normally and under
`BOTLISH_NATIVE_GC_STRESS=1`: 3 stacks mapped, 4997 reused, 5000 released,
none swept.

### 51. Exact-function generic HOF evidence

`invoke(double, 7)` calls the ordinary generic `invoke`, whose instance is
entered with `double`'s exact identity: natively the call is inlined
(`invoke`'s instance body is `rimul`), then constant-folded in `main`
(`%29 = int 14`). No closure, no `callvalue` (`af-native-evidence`,
`af-generic-dual`; `bench/affine.tcl`'s `generic-exact` row).

### 52. Coroutine generic HOF evidence

```
func 8 "invoke<Coroutine{args:[Message],return:Event,errors:[]}>" params=2 ... instance="coroutine, Message"
    %2 = op coresume %0 %1
    %3 = op corelease %0
    ret %2
end
```

the same three instructions as the explicitly typed `run_once`. With
specialization off (`-specialize 0`) the clone is still `coresume corelease
ret`, while the source `invoke` (which then serves the exact function's call)
is a plain `callvalue ret`: the clone, made before any backend runs, decides
the callable kind, never a runtime branch (`af-generic-dual`).

### 53. Struct-storage evidence

```
func 5 "wrap" params=1 ... results=2
    %1 = str "w"
    retmulti %1 %0
end
```

`wrap` stores its coroutine parameter in a `Running` and returns it: the
struct is returned as its fields (no allocation); `r2 = r` and `{step} = r2`
in `main` are no instructions at all (`af-native-evidence`).

### 54. List-storage evidence

```
%23 = op listnew %19 %22
%24 = str "lc"
%25 = op affinedrop %23 %24
```

`xs = [make(5), make(6)]; ys = xs` is one `listnew`; `ys`'s release (its
last use is its binding) is one `affinedrop` by `"lc"` that releases both
coroutines.

### 55. Move-through-call evidence

```
func 4 "run_once" params=2 ... instance="coroutine, Message"
    %2 = op coresume %0 %1
    %3 = op corelease %0
    ret %2
end
```

The argument is the caller's register (`call 4 %2 %5`); the callee resumes
it and, owning it, releases it after its last use.

### 56. Return-transfer evidence

`make` returns its coroutine (`%2 = op cocreate %1`, `%3 = op costart
%2`, `ret %2`: the handle register, no release);
`wrap` returns a struct owning it (`retmulti`); the caller's binding owns it
from then on (`%10 %11 = callmulti 5 %9`). In HIR text the returning
reference is `ref b9 step : Coroutine{...} move` and no exit releases it.

### 57. Failure-cleanup evidence

Point 18's Core IR; natively the same edge is a landing pad: in
`af-call-pending`, every backend computes the handled value and the Tcl live
probe sees no coroutine left; the fuzzer's `pendingbox`, `try` and `early`
operations check every such edge against the oracle's release counts
(point 58).

### 58. Fuzzer design/results

`audit/affine/tools/fuzz.tcl` generates a driver function `drive(k)` -- a
straight line of 4..14 operations over coroutine handles and the structs and
Lists that own them -- over a fixed prelude: a coroutine that folds every
message into its accumulator, a typed pass-through (`pass`), a typed
consumer (`consume`), an untyped HOF that resumes its argument (`invoke`,
specialized), an untyped HOF that returns its argument with the event in an
anonymous struct (`keep`), a call whose second argument fails after the
handle moved into the call (`try_consume`), a callee that fails after
resuming its parameter (`guarded`), a callee that returns early with its
parameter boxed (`early`), a construction whose field after the handle fails
(`pending_box`), and two structs (`Box {tag, step}`, `Two {a, b}`). The
operations construct, resume, move, pass, consume (typed or generic), thread
through `keep`, box, unbox (all fields, or only the tag: the handle is
dropped), build and move a List of two, build a `Two` and destructure one or
both fields, consume on one branch of an `if`, discard a result, run
`try_consume`/`guarded` under a handler (failing or not, as `k` decides) and
resume in a loop.

The oracle shares no code with the compiler: it is the generator's own
record of every affine runtime identity -- its accumulator and its one owner
location (a binding, a parameter, a call temporary, a struct field, a List
element, or dropped) -- updated by each operation's transition (a move: old
owner dead, new owner live; a drop: released; a resume: owner unchanged,
accumulator advanced). From it come the driver's value (a checksum every
resume feeds) and the release obligations: every identity released exactly
once (twice allowed only for one consumed on one branch of an `if`, where a
maybe-moved binding and its new owner both release idempotently), none left
alive. Every accepted program must produce the oracle's value on the
interpreter, the Tcl compiler, Cranelift generic and Cranelift specialized;
on the interpreter every release call (`core::coroutines::releaseCalls`) is
matched to the oracle's identities, and no Tcl coroutine may be alive after
`drive`; natively the runtime's counters must show every construction
released and none swept. A third of the programs carry one ownership fault
whose diagnostic the oracle predicts: `USE-AFTER-MOVE` (after a move into a
binding, a call, a struct, a List; a generic function duplicating its
argument, reported at the call), `AFFINE-NOT-DEFINITELY-LIVE`,
`AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE`, `AFFINE-LIST-OPERATION-UNSUPPORTED`,
`AFFINE-CAPTURE-UNSUPPORTED`, `AFFINE-ERASURE-UNSUPPORTED`,
`AFFINE-EQUALITY-UNSUPPORTED`, `COROUTINE-NOT-FUNCTION`.

Results on the final compiler (every backend, native counters on):

| seed | programs | accepted | rejected (as predicted) | identities whose releases were checked | disagreements |
|---|---:|---:|---:|---:|---:|
| 1 | 100 | 70 | 30 | 273 | 0 |
| 3000 | 100 | 69 | 31 | 239 | 0 |
| 7000 | 100 | 60 | 40 | 203 | 0 |

`af-fuzz-bounded` runs 8 programs (seed 101) as part of `tests/affine.test`;
the mutation run (point 59) runs 25 more (seed 11) against every mutant. The
coroutine fuzzer (`audit/coroutines/tools/fuzz.tcl`) still passes; its
storage fault is now an equality (`kept = current == current`,
`AFFINE-EQUALITY-UNSUPPORTED`), since a handle may now be stored.

### 59. Mutation results

`audit/affine/tools/mutate.tcl` applies each mutant of
`audit/affine/tools/mutants.txt` to a private copy of the tree and runs
`tests/affine.test` (private `-tmpdir`) and 25 fuzzer programs (seed 11) on
every backend against it; a native-runtime mutant first rebuilds the copy's
native backend and also runs `cargo test --release --lib affine`. All 29
mutants -- the brief's 25 plus a Tcl struct-drop mutant and three native
ones -- are killed:

| mutant (the brief's wording, AFFINE-VALUES terms) | tests/affine.test | fuzzer | Rust |
|---|---|---|---|
| `struct-affine-unrestricted` (struct containing affine field marked unrestricted) | 15 tests (af-aggregate-branch, -destructure, -field-read, ...) | 8/25 programs | n/a |
| `list-affine-unrestricted` (List[affine] marked unrestricted) | 12 tests (af-call-pending, af-contract-compat, af-drop-native, ...) | 3/25 | n/a |
| `alias-becomes-move` (exact function alias becomes a move) | 43 tests | 25/25 | n/a |
| `assignment-copies` (affine assignment copies) | 13 tests | 11/25 | n/a |
| `arg-no-invalidate` (argument does not invalidate the caller) | 7 tests (af-call-transfer, af-done-generalized, ...) | 21/25 | n/a |
| `list-no-consume` (List construction does not consume) | 4 tests (af-call-pending, af-generic-ownership, ...) | 3/25 | n/a |
| `destructure-aliases` (destructure aliases affine field) | 13 tests | 6/25 | n/a |
| `projection-aliases` (field projection silently aliases) | af-aggregate-field-read | -- | n/a |
| `any-erasure-hides` (any erasure hides affinity) | af-list-operations, af-restrictions | -- | n/a |
| `closure-capture-hides` (closure capture hides affinity) | af-restrictions | 1/25 | n/a |
| `return-releases-before-transfer` | af-call-return, af-generic-return, af-generic-transitive | -- | n/a |
| `callee-fail-no-drop` (callee fails without dropping its parameter) | af-call-release, af-fuzz-bounded | 4/25 | n/a |
| `pending-arg-leak` (later argument fails, earlier moved argument leaks) | af-call-pending, af-call-pending-hir | 1/25 | n/a |
| `aggregate-field-leak` (construction failure leaks earlier affine field) | af-call-pending, af-fuzz-bounded | 3/25 | n/a |
| `partial-destructure-leak` | af-aggregate-destructure, af-call-pending, af-drop-native | 2/25 | n/a |
| `last-use-raw-only` (last-use release only recognizes raw Coroutine) | 8 tests | 4/25 | n/a |
| `exit-raw-only` (early-exit release only recognizes raw Coroutine) | af-aggregate-return-fail, af-fuzz-bounded, af-list-ownership | 6/25 | n/a |
| `list-drop-no-elements` (Tcl runtime) | 5 tests (af-call-pending, af-drop-order, af-join, ...) | 2/25 | n/a |
| `list-drop-twice` (Tcl runtime: each element released twice) | -- | 2/25 (the release-call probe) | n/a |
| `struct-drop-no-fields` (Tcl runtime) | 6 tests | 8/25 | n/a |
| `explicit-fn-accepts-coroutine` | af-explicit-fn | -- | n/a |
| `explicit-coroutine-accepts-fn` | af-explicit-fn | -- | n/a |
| `generic-coerces-fn` (generic HOF coerces Coroutine to Fn) | af-generic-inferred-contract | -- | n/a |
| `generic-runtime-dispatch` (generic HOF emits runtime kind dispatch) | 12 tests (af-generic-dual, af-generic-errors, ...) | 8/25 | n/a |
| `hof-restarts` (coroutine through a HOF restarts/forks) | 22 tests | 17/25 | n/a |
| `struct-move-changes-identity` | 7 tests | 11/25 | n/a |
| `native-affinedrop-not-emitted` | af-drop-native, af-native-evidence | 2/25 | n/a |
| `native-list-drop-no-elements` | af-drop-native, af-native-evidence | 2/25 | survived |
| `native-struct-drop-no-fields` | af-drop-native | -- | survived |

The first run left two survivors, both callable-kind mutants:
`explicit-fn-accepts-coroutine` (a `Coroutine` accepted by an explicit `Fn`
type) and `explicit-coroutine-accepts-fn`. Neither changed what is accepted:
a parameter has its own kind check (`COROUTINE-NOT-FUNCTION`,
`hir/range.tcl`), a `Fn`-typed field or result still rejects a coroutine as
an erasure (a `Fn` is unrestricted), and a function at a `Coroutine`
parameter still fails the typed-callable escape check -- but each changed the
*reason*, and `af-explicit-fn` asserted only codes. It now pins the messages
that name the callable kinds for a field, a result and a `Fn`-typed value
(killing both). The same gap let the coroutine harness's `handle-as-fn` and
`handle-erased-to-any` survive; `co-storage-frontier` now covers a `Fn`-typed
field and a parameter declared `any`.

Not a mutant: a *native* drop that releases a List element twice. A
coroutine release is idempotent by design (`rt_co_release` returns at once
for a released handle), so that program is observably the same; the Tcl
runtime's twice-releasing drop is the mutant (`list-drop-twice`), caught by
the fuzzer's release-call probe, which counts calls rather than first
releases.

The coroutine milestone's mutants (`audit/coroutines/tools/mutate.tcl`, 52
mutants, detectors `tests/coroutines.test` and the coroutine fuzzer): 19 of
them edited code this milestone moved into `hir/affine.tcl` (the move,
join, consumer, release and exit-release rules) or rewrote
(`hir::types::subtype`'s kind rule, the compiler's and native lowering's
release sites); each was rewritten against the new code, keeping its rule.
The run killed 50; `handle-as-fn` and `handle-erased-to-any` survived
(above) and are killed since `co-storage-frontier` covers them: 52 of 52.

Because the affine specialization extends `hir::traits::Plan`, the trait and
context-trait mutants were re-run too: two trait mutants
(`runtime-wrapper`, `one-codegen-instance`) were rewritten against the
changed lines (`CloneWitnesses` replaced `WitnessesOf` at the plan's two
witness sites; a clone head now also declares untyped affine parameters);
`audit/traits/tools/mutate.tcl` kills 18 of 18,
`audit/context-traits/tools/mutate.tcl` 23 of 23. `opaque-struct`'s
`instance-kind` mutant (the kind a semantic instance's diagnostic keeps,
which now also keeps the ownership codes) was rewritten the same way and is
killed. Four mutants of other harnesses (`opaque-struct`'s
`method-candidates` and `registry-flag`, `abi-bytes`'
`byte-masked-to-7-bits` and `hash-ignores-length`) do not apply, and did not
before this milestone either (checked at 34314da): their code changed in
earlier work.

### 60. Full regression

`tests/all.tcl` on the milestone's code (each pass with a private
`-tmpdir`, the two passes concurrently):

| pass | tests | passed | skipped | failed |
|---|---:|---:|---:|---:|
| `CORE_BACKEND=interp` | 6625 | 6624 | 0 | 1 |
| `CORE_BACKEND=compile` | 6625 | 6620 | 4 | 1 |

The one failure in each pass was `stdlib-namespaces.test`'s
`ns-root-inventory`, the inventory of root natives source cannot spell,
which did not list the new `affine#drop`; it now does. The three test files
changed after that run (`affine.test`, `coroutines.test`,
`stdlib-namespaces.test`) pass in both passes (198 of 198 each).
`cargo test --release --manifest-path native/Cargo.toml`: 198 library and
31 integration tests pass. Every existing coroutine test passes unchanged in
substance; the ones that pinned the first milestone's storage frontier
(`co-storage-*`), its diagnostic codes and its HIR type notation were
updated to the generalized behavior (a handle may now be a field, an
element, an argument, a result).

### 61. Native coverage

`tests/native-coverage.tcl -verbose` (the whole suite on Cranelift, every
test classified), on the commit before the milestone (34314da, with its own
native build) and on the final tree:

| class | before (34314da) | after |
|---|---:|---:|
| tests | 6580 | 6625 |
| native | 2613 | 2648 |
| independent | 3839 | 3849 |
| passed-partial | 68 | 68 |
| unsupported | 60 | 60 |
| failed | 0 | 0 |

Compared test by test: no existing test changed class (the coroutine tests
included), none disappeared, and the 45 new tests are `tests/affine.test`'s
-- 35 native, 10 independent (frontend, HIR and source-level checks), none
unsupported or partial. The 60 unsupported tests are the same as before
(host-returned Block values, `test-log`/`test-tick` instrumentation natives,
sequence mode, Tcl-only refinement natives).

### 62. GC-stress results

* The whole suite under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt
  at every allocation site), the interp pass on the final tree: 6625 of 6625
  passed.
* `cargo test --release --manifest-path native/Cargo.toml` under
  `BOTLISH_NATIVE_GC_STRESS=1`: 198 library and 31 integration tests pass,
  including the three new drop tests (`runtime::affine::tests::drops`), which
  root everything they build so that they hold under stress.
* `af-drop-native` runs its 1000 rows of aggregates owning abandoned
  coroutines normally (3 stacks mapped, 4997 reused, 5000 released, none
  swept) and again under stress (the same value), as part of
  `tests/affine.test`.

No GC change was needed (point 50): moves add no roots, and `affinedrop`
neither allocates nor is a safepoint.

### 63. Scalar audit

General affinity is a no-op for a program with no affine value: the analysis
is not entered (`hir::affine::Used` asks whether any interned type is affine;
`dict get $hir affine` is empty), no release is elaborated, and the affine
specialization plan is only consulted when the program constructs a
coroutine (`hir::traits::UsesCoroutines`, a textual test of the sources).
Two checks against the commit before the milestone (34314da):

* **Machine code.** `native/generate-scalar-audit.tcl -outdir DIR`
  regenerated the scalar machine-code corpus (`audit/native-scalar-asm/`:
  13 programs, 194 functions, 83843 bytes of machine code): every `.asm`,
  `.vcode` and summary file is byte-identical to the committed one; only
  the README's commit hash and the sandbox's rustc version line differ.
* **NIR and HIR text** of every `examples/**/*.bot` and `bench/*.bot`
  program (38 that compile; the two intentional negative examples fail
  identically) and of four programs written for the areas the brief names
  -- exact function aliases, `Fn` HOFs (an explicit `Fn{...}` parameter, an
  untyped HOF, a closure returned as a `Fn` value), a trait-polymorphic
  function, Lists and structs of unrestricted values with a destructuring --
  plus the contexts (`examples/io`, `examples/linux`) and refinements
  (`examples/refinement`) of the corpus: 42 programs, `native::nir` and
  `hir::format` output identical before and after.

### 64. Performance

`tclsh9.0 bench/affine.tcl` (best of 5 in-process runs, compilation
excluded; n = 4000 operations per program on the Tcl backends, 200000
natively), on a quiet 4-core container. Each cell is the cost per operation
over its baseline program, the whole program per operation in parentheses:

| operation | baseline | Tcl interp | Tcl compile | Cranelift |
|---|---|---:|---:|---:|
| resume, by the handle's own binding | a loop calling a function | 33284 ns (104366 ns) | 11021 ns (17325 ns) | 134 ns (135 ns) |
| resume, through a `Coroutine{...}` parameter | same | 21850 ns (104135 ns) | 9983 ns (17046 ns) | 134 ns (135 ns) |
| resume, through an untyped (specialized) parameter | same | 38623 ns (112358 ns) | 11058 ns (17253 ns) | 163 ns (164 ns) |
| untyped HOF given an exact function | the direct call | 53220 ns (144902 ns) | 7262 ns (8990 ns) | 1 ns (1 ns) |
| move through one function call | the same recursion passing an Int | 2101 ns (188383 ns) | -357 ns (4112 ns) | 1 ns (10 ns) |
| move through a struct (wrap + destructure) | same | 50038 ns (248141 ns) | 6970 ns (10953 ns) | 4 ns (13 ns) |
| drop a struct owning a coroutine | the bare coroutine dropped | 50868 ns (366618 ns) | 23199 ns (116032 ns) | -21 ns (420 ns) |
| drop a List of 8 coroutines (per coroutine) | the 8 dropped one by one | -14038 ns (380314 ns) | 11844 ns (105921 ns) | 64 ns (472 ns) |

Two more native runs (best of 9) give the run-to-run spread: resume direct
162 / 131 ns, typed parameter 136 / 137 ns, specialized untyped parameter
137 / 135 ns; move through a call 4 / 1 ns, through a struct 7 / 1 ns; drop
a struct 84 / 55 ns, drop a List -17 / 52 ns per coroutine.

What this shows:

* **A specialized generic HOF adds nothing natively.** The resume through
  the untyped parameter's clone is the same NIR as through a typed parameter
  (`coresume0`, `structget`, the loop, one `corelease` after it -- checked
  instruction by instruction), and all three resume rows are the same cost
  within the spread (131-163 ns, the coroutine switch itself). There is no
  dispatch: the clone's call is the resume.
* **A generic HOF given an exact function keeps the direct call**: natively
  1 ns over the direct call (inlined, then constant-folded, point 51).
* **Moves are representation transfers**: 1-7 ns per step natively, through
  a call or through a struct wrapped and destructured at every step (the
  struct travels as its fields; nothing is allocated).
* **Drops cost about what the releases they perform cost**: a struct's
  `affinedrop` and a List's are within the spread of releasing the same
  coroutines one by one (each row's whole cost, ~400-470 ns, is dominated by
  constructing a coroutine on its own stack).
* On the Tcl backends the numbers are dominated by Tcl's own call and
  coroutine machinery and are noisy (the interpreter's resume rows differ by
  more than the operation). The Tcl compiler's typed and specialized
  resumes cost the same as the direct one. Its aggregate drops cost more
  than releasing the same coroutines one by one (in this run 23 us per
  struct, 12 us per List element): `affine#drop` is an ordinary registered
  native, called through the generic native-call path, and was not
  optimized for the Tcl backends, which are the reference implementations.

### 65. Remaining restrictions before `MutableVector[T]`

What a growable vector of affine elements will need, and does not have yet:

* **Move-out and replace operations.** Every element access today copies
  (`list::at`) and is rejected for affine elements; a vector needs
  ownership-moving `take(i)`/`swap(i, v)`/`pop()` whose result is the one
  owner, and the analysis has no *partial-move* state for a container (the
  only partial move is a destructuring temporary's, which source cannot
  name).
* **Iteration that moves.** `loop s in xs` over affine elements is rejected
  (the loop variable would be a second owner); a consuming iteration (each
  element moved into the body, the rest dropped on an early exit) needs a
  drop of the remaining suffix on every exit.
* **Mutable containers of affine values.** `MutableArray[T]` of an affine
  `T` is `AFFINE-CONTAINER-UNSUPPORTED`: overwriting a slot must drop its old
  value, and a slot read must move (point 12).
* **Collecting loops.** A loop collecting affine values is rejected: its
  partial List would need releasing on `break`/`fail`, which the pending
  temporaries do not cover yet.
* **Affine results and messages of coroutines.** A coroutine's `return` and
  message types stay unrestricted (a completed coroutine returns its cached
  result to every later resume; an unreceived message would be dropped
  silently): `af-coroutine-affine-protocol` pins the rejection.
* **Nested generic functions.** A generic function declared inside another
  one cannot be specialized for an affine argument
  (`AFFINE-GENERIC-NESTED-UNSUPPORTED`).
* **Closures.** A closure cannot capture an affine value, and closure values
  are unrestricted; stateful closure affinity is a non-goal here.

None of these needs a new kind of runtime state: each is a new static
consumer role plus the drop glue the descriptors already provide.

## Files

| file | what |
|---|---|
| `surface/parser.tcl`, `surface/ast.tcl` | `Coroutine{...}` (FnType with `kind coroutine`) |
| `hir/resolve.tcl` | resolution and `COROUTINE-CONTRACT`; clone heads of affine witnesses |
| `hir/types.tcl` | the coroutine type, callable contracts and kinds, the affinity query, subtype/lub/show/narrow, contract-based call typing |
| `hir/structs.tcl` | struct affinity (cached), `Coroutine` reserved |
| `hir/affine.tcl` | the ownership analysis and release elaboration (new) |
| `hir/coroutines.tcl` | the coroutine protocol checks; `ElaborateResumes` |
| `hir/semantic.tcl`, `hir/signatures.tcl`, `hir/traits.tcl` | instances of affine calls, `CallableAdmits`, the affine specialization plan |
| `hir/range.tcl`, `hir/completions.tcl` | contract-based call verification and error charging for coroutine callees |
| `hir/format.tcl`, `hir/read.tcl` | HIR text of moves, consumed fields and releases |
| `hir/lower.tcl`, `compiler/compiler.tcl`, `native/lower.tcl` | release lowering, pending temporaries, drop glue |
| `core/affine.tcl`, `native/src/runtime/affine.rs` (+ `nir.rs`, `ops.rs`, `clif.rs`) | `affine#drop` / `affinedrop` |
| `tests/affine.test` | the milestone's tests |
| `audit/affine/tools/fuzz.tcl` | the ownership fuzzer with its independent oracle |
| `audit/affine/tools/mutate.tcl`, `mutants.txt` | mutation testing |
| `bench/affine.tcl` | the performance report |

## What to run when changing this

If you change the affinity query, `hir/affine.tcl`, the callable-contract
typing of calls, `ElaborateResumes`, the affine specialization
(`NeedsAffinePlan`, `AffineWitnesses`, `CloneWitnesses`, `CallableAdmits`),
release lowering in any backend or the drop runtimes, run
`tests/affine.test`, `tests/coroutines.test`, `audit/affine/tools/fuzz.tcl`
(several seeds) and `audit/affine/tools/mutate.tcl` (every mutant in
`audit/affine/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of the
same rule), and `audit/coroutines/tools/mutate.tcl` (its ownership and
release mutants edit `hir/affine.tcl` too). A change to native drop or release
lowering also needs a `BOTLISH_NATIVE_GC_STRESS=1` run of `tests/affine.test`
and `cargo test --release --manifest-path native/Cargo.toml --lib affine`.
`bench/affine.tcl` regenerates point 64.
