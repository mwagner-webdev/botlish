# Core evaluator — executable semantic specification

A small reference evaluator, written in Tcl, for the semantic core of a new
language. It is a specification you can run, not a production runtime: it
aims for clarity over speed.

Tcl is only the implementation language. The semantics described here are
the language's own. Where Tcl behaves differently (truthiness, strings as
values, exceptions, variable scope, command lookup), the evaluator does
**not** inherit Tcl's behavior.

```
core/            evaluator (see "Implementation map")
examples/*.ir    acceptance programs as IR data
tests/*.test     tcltest suite
main.tcl         example runner
```

```sh
tclsh tests/all.tcl          # run the test suite
tclsh main.tcl               # run all examples
tclsh main.tcl FILE.ir       # run one program file
```

```tcl
source core/core.tcl
core::formatValue [core::eval {call {ref +} {const 1} {const 2}}]   ;# => 3
```

---

## 1. Values

Values are immutable. Every value has exactly one kind:

| Kind     | Display          | Notes                                              |
|----------|------------------|----------------------------------------------------|
| `int`    | `42`             | arbitrary precision; no fixed-width overflow       |
| `str`    | `"hello"`        | a string                                           |
| `bool`   | `true` / `false` | the only valid condition values                    |
| `unit`   | `unit`           | value of an empty sequence                         |
| `list`   | `[1, "a"]`       | an ordered sequence of values                      |
| `result` | `ok(v)` / `error(v)` | an application-level outcome                   |
| `block`  | `<block (x y)>`  | a closure: parameters, body, captured environment  |
| `native` | `<native +>`     | a primitive callable, possibly with refinement metadata |

Kinds never blur: the integer `10`, the string `"10"`, and the string
`"true"` are all different values, and none of the strings is a Boolean.

**Equality (`==`)** compares structure. Values of different kinds are never
equal. Integers compare numerically, strings compare exact characters, lists
compare element by element, and Results compare tag and payload. Equality on
callables is not defined, because it would need identity semantics, which are
out of scope. Comparing callables makes the program invalid.

**String equality (`eq`)** applies only to strings. It never converts other
values to strings.

## 2. Environments

A lexical environment holds:

* a **parent** (the enclosing lexical environment, or none for the root),
* **bindings**: name → value, each made **once** and never changed,
* **refinements**: binding → facts proven true in this scope.

Rules:

* Binding a name that is already bound *in the same environment* is an error.
  Shadowing it in a nested environment is allowed.
* Names resolve through the lexical parent chain only. They never resolve
  through the caller.
* An environment has identity. A block that captures an environment also sees
  bindings added to it later. Recursion and mutual recursion work because of
  this. Using a name before its binding has been made is an unbound-name
  error. A binding can never be observed changing, because bindings don't
  change.
* Refinements attach to a **binding**, not a name. A fact about an outer `x`
  doesn't apply to an inner `x` that shadows it.

Lookup is written as a search over an ordered list of *scopes*. Today these
are just the lexical frames, innermost first. The planned order is
`local → execution overlay → captured lexical env → module/global`. Adding it
only changes `core::env::lookupScopes`.

The root environment binds all native callables, plus `true`, `false` and
`unit`. These are ordinary immutable bindings with no special status.

## 3. Completions

Each evaluation step ends in a **completion**:

| Completion           | Meaning                                         |
|----------------------|-------------------------------------------------|
| `value(v)`           | normal completion                                |
| `return(v)`          | leave the current callable invocation with `v`   |
| `break(v)`           | leave the nearest lexical loop with `v`          |
| `continue`           | start the nearest lexical loop's next iteration  |
| `propagate-error(e)` | reserved for future structured error propagation (no form produces it yet) |

When a sub-expression completes abruptly (anything other than `value`), the
enclosing expression stops and completes the same way. Sequences stop at the
first abrupt completion.

**Callable boundary** (a block invocation): `return(v)` becomes `value(v)`.
`break` and `continue` may not cross it, and trying to is an error.
`propagate-error` passes through.

**Program boundary**: only `value(v)` may reach it. Any other completion is
an error.

## 4. IR forms

A program is a list of IR expressions. Each IR node is a list that starts
with its operation name. A malformed node is rejected, never guessed at.

### `(const LITERAL)` / `(const TYPE LITERAL)`

Evaluates to a literal value.

* Untyped: canonical decimal integer text (`0`, `42`, `-7`, with no leading
  zeros, no `+` and no `-0`) is an `int`. Anything else is a `str`. So
  `(const 010)` is the string `"010"`.
* `(const int 42)` and `(const str 42)` force the type.
* `(const list {1 2 abc})` builds a list. Each element follows the untyped
  rule.

### `(bind NAME EXPR)`

Evaluates `EXPR`, then binds `NAME` immutably in the current environment.
The result is the bound value. Rebinding a name in the same environment is an
error.

### `(ref NAME)`

Evaluates to the value of the lexically visible binding of `NAME`. An unbound
name is an error.

### `(block PARAMS BODY...)`

Creates a Block value that captures the current environment. The body does
**not** run. Duplicate parameter names are an error.

Invoking a Block with arguments works like this:

1. The argument count must equal the parameter count.
2. A fresh child of the **captured** environment is created.
3. Each parameter is bound immutably in it. Rebinding a parameter in the body
   is therefore a duplicate-binding error.
4. The body runs as a sequence. The value of an empty body is `unit`.
5. The callable boundary rules from §3 apply.

### `(call CALLEE ARG...)`

Evaluates `CALLEE`, then each `ARG` **strictly left to right**, then invokes
the callee. There is exactly one call operation. Blocks, natives, operators
and predicates are all called the same way. Calling a non-callable value is
an error.

### `(if CONDITION THEN-BLOCK ELSE-BLOCK)`

Evaluates `CONDITION`. The result must be a Boolean; nothing else counts as
true or false. Exactly one branch runs, and the `if` evaluates to that
branch's value.

Each branch must be written as a `(block {} ...)` node. Its body is
*lexically part of the enclosing code*. It runs inline, with no callable
boundary, in a fresh child environment. So `return`, `break` and `continue`
inside a branch affect the surrounding callable or loop. Bindings made in a
branch don't escape it, but the branch's value does.

The branch environment also carries any refinements the condition proves
(see §6).

### `(loop BODY-BLOCK)`

`BODY-BLOCK` is a `(block {} ...)` node that runs inline, like an `if`
branch. Each iteration runs in a fresh child environment.

| Body completion      | Effect                              |
|----------------------|-------------------------------------|
| `value(_)`           | next iteration                      |
| `continue`           | next iteration                      |
| `break(v)`           | the loop evaluates to `v`           |
| `return(v)`          | propagates to the enclosing callable |
| `propagate-error(e)` | propagates                          |

### `(return EXPR)`

Completes with `return(v)`. The current invocation stops, and nothing after
the `return` runs.

### `(break)` / `(break EXPR)`

Completes with `break(v)`. `v` is `unit` when no expression is given.

### `(continue)`

Completes with `continue`.

### `(ok EXPR)` / `(error-value EXPR)`

Build Result values `ok(v)` and `error(v)`. These are ordinary values: an
`error(...)` Result doesn't interrupt evaluation. Application-level failures
are represented this way, never with exceptions or completions.

## 5. Control placement

`return` must appear inside a block body. `break` and `continue` must appear
inside a loop body **without an intervening `block` node**. `if` branches and
loop bodies don't count as intervening, because they run inline.

```
(loop (block {} (call (block {} (break)))))   ; invalid: break crosses a callable
(loop (block {} (if c (block {} (break)) (block {}))))   ; valid
```

`core::eval` and `core::evalProgram` check placement before running a
program. The call and program boundaries (§3) enforce the same rules again at
runtime, so code run through `core::evalIn` gets the same errors.

## 6. Predicates and refinement

A callable can carry refinement metadata: facts that are proven when it
returns `true` or `false`. For example, the metadata for `integer?` is
"when the result is true, argument 0 satisfies `Int`".

When an `if` condition has the form `(call (ref P) ARG...)`, the evaluator:

1. resolves `P`,
2. looks up the refinement rules for the observed outcome,
3. applies each rule "argument *i* satisfies *F*" when argument *i* is a plain
   `(ref NAME)`,
4. records fact *F* for that **binding** in the environment of the branch that
   runs.

The fact is visible throughout that branch, including closures created in
it, and nowhere else. Conditions of any other shape add no facts, which is
always sound. Nothing in `if` depends on predicate names. A predicate bound
under another name keeps its metadata, and a user block that shadows
`integer?` has none.

Refinement introspection: `core::refinementsOf ENV NAME` and
`core::envRefinements ENV`. To inspect a scope, create a block in it and use
`core::blockEnv` (see `examples/04-refinement-scope.ir`).

## 7. Invalid programs vs application errors

Invalid programs raise Tcl errors with error code `CORE SEMANTIC <KIND>`:

`UNBOUND`, `DUPLICATE`, `NOT-CALLABLE`, `ARITY`, `NOT-BOOLEAN`, `TYPE`,
`EQUALITY`, `BREAK-OUTSIDE-LOOP`, `CONTINUE-OUTSIDE-LOOP`,
`RETURN-OUTSIDE-CALLABLE`, `UNCAUGHT-ERROR`.

Malformed IR raises `CORE MALFORMED`. Application-level failures are `Result`
values. The two are never mixed.

## 8. Native callables in the root environment

| Name | Signature | Refinement |
|------|-----------|------------|
| `+` `-` `*` | int, int → int | |
| `<` `<=` `>` `>=` | int, int → bool | |
| `==` | any, any → bool (value equality) | |
| `eq` | str, str → bool | |
| `list` | any... → list | |
| `integer?` | any → bool | true: arg 0 : `Int` |
| `string?` | any → bool | true: arg 0 : `Str` |
| `list?` | any → bool | true: arg 0 : `List` |
| `ok?` | any → bool | true: arg 0 : `Result.ok` |
| `error?` | any → bool | true: arg 0 : `Result.error` |
| `result-value` | ok Result → its value | |
| `result-error` | error Result → its payload | |

New natives are registered through the registry, not by changing the
evaluator:

```tcl
core::registerNative even? -arity 1 -impl myEvenImpl -refines-true {0 Even}
```

`-refines-true` and `-refines-false` take `ARG-INDEX FACT` pairs.

## 9. Public API

| Procedure | Purpose |
|-----------|---------|
| `core::eval NODE` | evaluate one expression in a fresh program scope; returns a value |
| `core::evalProgram EXPRS` | evaluate a list of expressions; returns the last value |
| `core::evalIn NODE ENV` | evaluate in a given environment; returns a completion |
| `core::check NODE` | static shape and control-placement check |
| `core::rootEnv` / `core::childEnv ENV` | create environments |
| `core::envDefine ENV NAME VALUE` | add a binding, for embedding and tests |
| `core::envBindings ENV` | local bindings: name → value |
| `core::envRefinements ENV` | visible refinements: name → facts |
| `core::refinementsOf ENV NAME` | facts for the binding `NAME` resolves to |
| `core::blockEnv BLOCK` | a block's captured environment |
| `core::formatValue V` / `core::formatCompletion C` | display |
| `core::registerNative NAME ?options?` | register a native callable |
| `core::readProgramFile PATH` | read a `.ir` file (a list of IR; `#` lines are comments) |

## 10. Implementation map

| File | Responsibility |
|------|----------------|
| `core/errors.tcl` | error classes |
| `core/value.tcl` | value representation, equality, display |
| `core/completion.tcl` | completions and call/program boundaries |
| `core/env.tcl` | frames, binding, lookup scopes, refinement storage |
| `core/ir.tcl` | node shapes, literal rules, static placement check |
| `core/block.tcl` | block creation and invocation |
| `core/native.tcl` | native registry and invocation |
| `core/callable.tcl` | the single call dispatch point |
| `core/refine.tcl` | deriving and installing branch refinements |
| `core/evaluator.tcl` | one handler per form, public API |
| `core/primitives.tcl`, `core/predicates.tcl` | builtin natives |

Implementation notes (not part of the semantics):

* Runtime values are tagged Tcl lists (`{int 42}`, `{str hello}`, ...).
* Environments are ids in a frame store that only grows. Nothing is reclaimed,
  which is acceptable for a reference model.
* Handlers use `core::valueOf`, which relies on Tcl's `return -level 2` to
  propagate an abrupt completion out of the calling handler. What propagates
  is still an explicit completion value.

## 11. Not implemented (deliberately)

No parser or surface syntax, macros, modules, objects, assignment, mutable
variables, exceptions, `?` propagation, pattern matching, a type checker
beyond refinement tracking, async, coroutines, threads, FFI, or compilation.
