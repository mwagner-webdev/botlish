# Core evaluator — executable semantic specification

A small reference evaluator, written in Tcl, for the semantic core of a new
language. It is a specification you can run, not a production runtime: it
aims for clarity over speed.

Tcl is only the implementation language. The semantics described here are
the language's own. Where Tcl behaves differently (truthiness, strings as
values, exceptions, variable scope, command lookup), the evaluator does
**not** inherit Tcl's behavior.

There are two backends that implement the same semantics:

* **`interp`**: the tree-walking reference interpreter (`core/evaluator.tcl`).
* **`compile`**: a compiler from IR to Tcl procedures (`compiler/compiler.tcl`,
  see §12).

The whole test suite runs against both.

```
core/            runtime and interpreter (see "Implementation map")
compiler/        IR -> Tcl compiler
examples/*.ir    acceptance programs as IR data
tests/*.test     tcltest suite
main.tcl         example runner
```

```sh
tclsh tests/all.tcl                         # test suite, both backends
CORE_BACKEND=compile tclsh tests/all.tcl    # test suite, one backend
tclsh main.tcl                              # run all examples (interp)
tclsh main.tcl -backend compile -code FILE.ir   # compile, show generated Tcl, run
tclsh bench/bench.tcl                       # compare backends on bench/*.ir
```

```tcl
source compiler/compiler.tcl       ;# loads core too; core/core.tcl alone is interp-only
core::useBackend compile
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
  this. A binding can never be observed changing, because bindings don't
  change.
* **A name means one binding throughout its scope.** A scope is a program, a
  block body, an `if` branch, or a loop iteration. The scope binds every name
  bound by a `bind` evaluated directly in it, including binds nested inside
  call arguments or an `if` condition, but not binds inside nested scopes. On
  entry, the scope declares all of these names. Using a name after it is
  declared but before its `bind` completes is an `UNBOUND` error ("used
  before its binding"). It never silently reads an outer binding of the same
  name:

  ```
  (bind x (const 1))
  (call (block {}
      (bind y (call (block {} (ref x))))   ; this x is the inner x -> error
      (bind x (const 2))))
  ```

  This rule is what lets names be resolved statically. The compiler depends
  on it.
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
returns `true` or `false`. A fact is a **type** (§14). For example, the
metadata for `integer?` is `-refines-true {0 int}` ("when the result is
true, argument 0 is an `int`"). The metadata for `Emailish?` is
`{0 {refined str {Emailish}}}`.

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
`RETURN-OUTSIDE-CALLABLE`, `UNCAUGHT-ERROR`, `RANGE`.

Malformed IR raises `CORE MALFORMED`. Application-level failures are `Result`
values. The two are never mixed.

A native that breaks its declared type contract (§8) raises
`CORE CONTRACT TYPE`. That's a bug in trusted Tcl code, not in the program.

## 8. Native callables in the root environment

| Name | Signature | Refinement |
|------|-----------|------------|
| `+` `-` `*` | int, int → int | |
| `<` `<=` `>` `>=` | int, int → bool | |
| `==` | any, any → bool (value equality) | |
| `eq` | str, str → bool | |
| `list` | any... → list | |
| `integer?` | any → bool | true: arg 0 : `int` |
| `string?` | any → bool | true: arg 0 : `str` |
| `list?` | any → bool | true: arg 0 : `list` |
| `ok?` | any → bool | true: arg 0 : `Result.ok` |
| `error?` | any → bool | true: arg 0 : `Result.error` |
| `result-value` | ok Result → its value | |
| `result-error` | error Result → its payload | |
| `length` | str → int | |
| `substring` | str, int, int → str (characters `start <= i < end`) | |
| `lowercase` | str → str | |
| `concat` | str, str → str | |
| `Emailish?` | str → bool (`lib/web.tcl`) | true: arg 0 : `Emailish` |
| `UriQueryValue?` | str → bool (`lib/web.tcl`) | true: arg 0 : `UriQueryValue` |
| `uriEscape` | str → `UriQueryValue` (`lib/web.tcl`) | |

New natives are registered through the registry, not by changing the
evaluator:

```tcl
core::registerNative even? -arity 1 -impl myEvenImpl -refines-true {0 Even}
```

`-refines-true` and `-refines-false` take `ARG-INDEX TYPE` pairs.

Natives may also declare a signature. `-param-types {int int}` lists the
type each argument must have (`any` means no requirement), and
`-result-type int` gives the type of every result. Types can be refined, for
example `-result-type {refined str {UriQueryValue}}`.

**Declared types are a contract.** After every call, the reference runtime
checks that each argument satisfied its parameter type and that the result
satisfies the result type. A violation raises `CORE CONTRACT TYPE`. So a
native can't claim to return a `UriQueryValue` while returning a plain
string. The compiler relies on these declarations (§13). Only its inlined
intrinsics for trusted builtins skip the check.

**Strings discard refinements.** A string transformation's result carries no
refinement unless its contract explicitly establishes one. So
`substring(UriQueryValue)` is a plain `str`, while `uriEscape(str)` is a
`UriQueryValue`.

## 9. Public API

| Procedure | Purpose |
|-----------|---------|
| `core::eval NODE` | evaluate one expression in a fresh program scope; returns a value |
| `core::evalProgram EXPRS` | evaluate a list of expressions; returns the last value |
| `core::evalIn NODE ENV` | evaluate in a given environment; returns a completion |
| `core::useBackend ?NAME?` | select or query the backend (`interp`, `compile`) |
| `core::compiler::generatedCode EXPRS ?MODE?` | the Tcl code generated for a unit (`program` or `sequence`) |
| `core::compiler::programTypes EXPRS` | inferred types of program-level bindings |
| `core::compiler::bindingTypes EXPRS` | inferred type of every `bind`, at any depth |
| `core::type::*` | semantic types (§14) |
| `core::regex::*` | regex IR (§15) |
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
| `core/block.tcl` | block creation and invocation (interpreted and compiled bodies) |
| `core/native.tcl` | native registry and invocation |
| `core/callable.tcl` | the single call dispatch point |
| `core/refine.tcl` | deriving and installing branch refinements |
| `core/runtime.tcl` | semantic rules shared by both backends |
| `core/evaluator.tcl` | interpreter (one handler per form), backend selection, public API |
| `core/type.tcl` | semantic types: named/refined types, subtyping, value membership |
| `core/regex.tcl` | engine-independent regex IR, lowered to Tcl ARE |
| `core/primitives.tcl`, `core/predicates.tcl`, `core/strings.tcl` | builtin natives |
| `lib/web.tcl` | demonstration library: `Emailish`, `UriQueryValue`, `uriEscape` |
| `compiler/compiler.tcl` | IR → Tcl compiler backend |
| `compiler/types.tcl` | compiler-only static types, delegating to `core/type.tcl` |
| `bench/` | benchmark programs and runner |

Implementation notes (not part of the semantics):

* Runtime values are tagged Tcl lists (`{int 42}`, `{str hello}`, ...).
* Environments are ids in a frame store that only grows. Nothing is reclaimed,
  which is acceptable for a reference model.
* Interpreter handlers use `core::interp::valueOf`, which relies on Tcl's
  `return -level 2` to propagate an abrupt completion out of the calling
  handler. What propagates is still an explicit completion value.

## 11. Not implemented (deliberately)

No parser or surface syntax, macros, modules, objects, assignment, mutable
variables, exceptions, `?` propagation, pattern matching, a type checker
beyond refinement tracking, async, coroutines, threads, FFI, or native code
generation.

## 12. The compiler backend

`compiler/compiler.tcl` translates IR into Tcl procedures that Tcl then
bytecode-compiles. It reuses the runtime (values, natives, environments, the
call boundary and refinement metadata) but none of the interpreter's
evaluation machinery. There are no completion objects, no per-node dispatch,
and no name search in scopes it can resolve statically.

**Units.** The expressions passed to `evalProgram` or `evalIn` form a
compilation unit and become `proc unitN {base}`, where `base` is the
environment the unit runs in. Units are cached by their IR, so compiling the
same IR twice yields the same proc.

**Expressions** are flattened into Tcl commands in evaluation order. Each
intermediate value goes into a temporary `tN`. Constants become literal
words.

**Blocks** become `proc blockN {captured argv}`. The Block value stores the
proc name in its `CODE` field. `core::block::invoke` checks arity and applies
the same call boundary to compiled and interpreted Blocks, so the two kinds
can call each other.

**`if` and `loop`** compile inline into Tcl `if` and `while 1`. Control flow
maps onto Tcl completion codes:

| IR | Inside a compiled loop in the same proc | Otherwise |
|----|----|----|
| `(break v)` | `set tLoop v; break` | `return -code break v` |
| `(continue)` | `continue` | `return -code continue` |
| `(return v)` | `return v` in a block proc | `return -code return v` at unit level |

The "otherwise" cases only arise in code the static placement check would
reject. They reach the call or program boundary and raise the same errors as
the interpreter.

**Names** are resolved at compile time using the scope rule in §2:

* A scope that contains a block node is *materialized* as a runtime frame,
  because a closure may capture it and its bindings and refinements can be
  observed. It declares its names on entry and reads and writes through
  `core::env`, which checks use-before-binding at run time.
* Any other scope never escapes its proc. Its bindings are Tcl locals `vN`.
  Evaluation order inside it matches the compiler's walk, so use-before-binding
  and duplicate bindings are decided at compile time and compiled into the
  matching error.
* Names that no nested scope binds are resolved in the unit's environment.
  In *sequence* mode (`evalIn`), that environment is arbitrary, so these
  names are looked up dynamically. In *program* mode (`evalProgram`), the
  environment is a fresh program scope over a fresh root. Program-level
  names are then known and typed, and root names compile to constants.

**Refinements** are installed only in materialized branches, since those are
the only ones where facts can be observed. They use the callee value the
condition actually called, plus the same metadata rules as the interpreter.

**Testing.** `tests/all.tcl` runs every test file once per backend, with the
backend chosen by `CORE_BACKEND`. `tests/backends.test` also runs a corpus
under both backends in one process and compares the outcomes, and checks
calls between compiled and interpreted Blocks. `tests/inference.test` does
the same for programs built to expose unsound type facts (§13).

**Known gap:** compiled code cannot yet propagate a `propagate-error`
completion out of a call. No form produces one yet.

## 13. Type inference

The compiler's static types are the semantic types of `core/type.tcl` (§14),
plus a few forms only the compiler needs, defined in `compiler/types.tcl`.
Types only *describe* runtime values. They never change what a program
means: the compiler uses them to pick faster code whose behavior is
identical, and falls back to generic code whenever a type is unknown. The
invariant is that an operand of semantic type `T` always holds a value `v`
for which `core::type::acceptsValue T v` is true.

| Type | Defined in | Describes |
|------|------------|-----------|
| `int` `str` `bool` `unit` `list` `result` `native` `block` | core | values of that kind |
| `{refined BASE {NAMES…}}` | core | values of `BASE` satisfying every named type |
| `any` | core | nothing known |
| `{native NAME}` | compiler | exactly the native `NAME` |
| `{block PROC ARITY RESULT}` | compiler | a Block compiled to `PROC`, whose calls return `RESULT` |
| `never` | compiler | no value: evaluation does not complete normally |

`core::types::lub`, `narrow` and `kindOf` handle the compiler-only forms
themselves and delegate everything else to `core::type`. For example,
`kindOf {refined str {Emailish}}` is `str`, and narrowing `str` by
`Emailish` gives `{refined str {Emailish}}`.

**Where types come from.**

* **Literals and constructors:** `const`, `ok`, `error-value`, `list`.
* **Root constants** in program mode: `+` has type `{native +}`, and `true`
  has type `bool`.
* **Native signatures** (§8): a call of `-` has type `int`, and a call of
  `uriEscape` has type `{refined str {UriQueryValue}}`.
* **Immutability:** a binding has the type of the expression it was bound
  to, and keeps it.
* **Refinements:** inside the `then` branch of `(if (call (ref integer?) (ref x)) …)`,
  `x` is `int`. Inside the `then` branch of `Emailish?`, it's
  `{refined str {Emailish}}`. Nested predicates accumulate evidence.
* **Flow facts:** when a native that requires a type returns, its argument
  had that type. The runtime contract check guarantees this. Because
  bindings are immutable, the argument keeps the type for the rest of the
  path.
* **Block results:** the result type is the lub of the body's value and
  every `return`. A block that calls itself through its binding is compiled
  under an assumed result type, starting from `never`, until the inferred
  type equals the assumption. If that doesn't happen within 3 passes, the
  result type is `any`. Accepting only a stable assumption is sound by
  induction over calls.

**Scope of facts.** A fact holds only on the path that proves it:

* Facts learned in a branch or loop body are dropped at its end.
* Facts learned in a sequence hold for the rest of that sequence.
* A closure inherits the facts known where it is created. Its captured
  bindings can't change afterwards.

**What types buy.**

* **Representations:** an operand is `box` (a runtime value), `int` (a bare
  integer) or `bool` (1/0). Unboxed values are boxed only when they escape
  into a frame, a call, a `return` or a `break`.
* **Intrinsics:** calls of `+ - * < <= > >= == eq list integer? string? list? ok? error?`
  compile to inline Tcl. An argument whose kind isn't known is first checked
  with `core::value::expect`. That check raises exactly the error the native
  would, in the same order, and then becomes a flow fact.
* **Folding:** a predicate applied to a value of known kind becomes a
  constant. An `if` with a constant condition compiles only the branch that
  runs.
* **Direct calls:** in program mode, a call of a `{block PROC ARITY _}` with
  matching arity calls `PROC` directly. The generic invoke is unnecessary
  there: in a checked program, a compiled block can't produce an escaping
  `break` or `continue`, and arity is already known to match.

`core::compiler::programTypes EXPRS` reports the inferred types of
program-level bindings. `core::compiler::bindingTypes EXPRS` reports the type
of every `bind` at any depth, including refinements in force at that point.
`tclsh main.tcl -backend compile -code FILE.ir` shows the generated code.

**Performance** (`tclsh bench/bench.tcl`, best of 5, excluding compilation):

| program | interp | compile, untyped | compile, typed |
|---------|-------:|-----------------:|---------------:|
| `fib.ir` | 1121 ms | 326 ms | 12 ms |
| `loop-count.ir` | 194 ms | 53 ms | 2 ms |
| `sum-refined.ir` | 110 ms | 37 ms | 16 ms |

`sum-refined` gains least. Its scopes contain closures, so its bindings stay
in runtime frames, and the parameter tested with `==` has no static kind.
Since then, native type contracts are checked after every generic native
call. That costs roughly 10% in the interpreter and on compiled
`sum-refined`; inlined intrinsics are unaffected.

## 14. Types, named types and evidence

`core/type.tcl` owns the meaning of types. The interpreter is the
specification; the compiler consumes the same definitions.

**Type forms.**

| Form | Values |
|------|--------|
| `int` `str` `bool` `unit` `list` `result` `block` `native` | every value of that kind |
| `any` | every value |
| `{refined BASE {NAME…}}` | values of kind `BASE` that satisfy every named type (an evidence set) |

A registered name on its own is shorthand: `Emailish` means
`{refined str {Emailish}}`. `core::type::normalize` gives the canonical form,
with names sorted and unique, and every registry stores canonical types.

**Named types** are registered from Tcl. There's no type declaration IR yet:

```tcl
core::type::register Emailish      -base str -validator [list core::regex::matches $re]
core::type::register UriQueryValue -base str -opaque 1
core::type::definePredicate Emailish          ;# registers the native Emailish?
```

* A **validator** type is structural. The validator (a command prefix called
  with the value, returning 1/0) decides membership.
* An **opaque** type has no validator. A value belongs to it only if it
  carries runtime *evidence*, which only trusted natives attach. For opaque
  types, evidence is the semantics. For validator types, evidence is only an
  optimization.

**Operations.**

| Operation | Meaning |
|-----------|---------|
| `valid T` | `T` is a well-formed type |
| `base T` | its primitive kind (`""` for `any`) |
| `subtype A B` | every value of `A` is a value of `B` |
| `acceptsValue T V` | `V` is a value of `T` |
| `validate NAME V` | `V` satisfies the named type (evidence, else validator; opaque: evidence only) |
| `lub A B` | same base: the evidence both share; otherwise `any` |
| `narrow A B` | same base: the union of the evidence; otherwise `B` (a contradiction only happens on unreachable paths) |
| `assertValue T V CONTEXT` | contract check; raises `CORE CONTRACT TYPE` |

For example, `lub(Emailish, str)` is `str`, and
`narrow(Emailish, NonEmpty)` is `{refined str {Emailish NonEmpty}}`. Proving a
second property never erases the first.

**Runtime evidence.** Strings may carry evidence:

```
{str TEXT}                          plain
{str TEXT {UriQueryValue}}          proven UriQueryValue
{str TEXT {Emailish UriQueryValue}}
```

`core::value::evidence`, `withEvidence` and `hasEvidence` work with it.
`strOf` still returns the text. **Evidence is knowledge about a value, not
part of it:** `==`, `eq` and ordinary display ignore it, so `"foo"` proven to
be a `UriQueryValue` still equals `"foo"`. `core::value::show V 1` shows
evidence as `"foo"#{UriQueryValue}`; the differential tests use this form, so
both backends must agree on evidence too. Only string values carry evidence
for now.

**The predicate pattern.** A named type gets an ordinary predicate. `if`
knows nothing about named types:

```
(if (call (ref Emailish?) (ref x))
    (block {} … x : {refined str {Emailish}} …)
    (block {} …))
```

A future surface form such as `if string is Emailish x:` can lower to this
call without new core semantics.

**Trusted transforms produce evidence.** `uriEscape` percent-encodes its
input and returns `withEvidence [str $escaped] UriQueryValue`. Its declared
result type is `{refined str {UriQueryValue}}`. The compiler knows the
static type, and the runtime value carries the proof through dynamically
typed code. The contract check stops a native from claiming that type
without delivering the evidence.

`lib/web.tcl` defines `Emailish`, `UriQueryValue`, their predicates and
`uriEscape` as a demonstration library, loaded with core.
`examples/05-refined-strings.ir` shows all of it.

## 15. Regular expressions

`core/regex.tcl` represents regexes as Tcl data. The IR is the
specification; Tcl's `regexp` is only the engine it's lowered to. Constructs
outside the safe contract are rejected when the IR is built, so arbitrary
engine syntax is never accepted and never needs sanitizing.

```tcl
set re [core::regex::create {seq
    {repeat {class alnum} 1 inf}
    {lit @}
    {repeat {class alnum} 1 inf}
    {lit .}
    {repeat {class alpha} 2 inf}}]
core::regex::matchesText $re foo@example.com   ;# 1 (the whole text must match)
```

| Node | Matches |
|------|---------|
| `{lit TEXT}` | the characters of `TEXT`, never as regex syntax |
| `{char C}` / `{range LO HI}` / `{class NAME}` | one character; classes: `alpha digit alnum upper lower space punct xdigit` |
| `{set ITEM…}` | one character matching any char, range or class item |
| `{any}` | any one character |
| `{seq NODE…}` / `{alt NODE…}` | sequence / alternatives |
| `{repeat NODE MIN MAX}` | `MIN`..`MAX` repetitions, `MAX` may be `inf`; bounds 0..255 |
| `{capture NAME NODE}` | a named capture (`core::regex::captures`) |
| `{start}` / `{end}` | start / end of the text |

`compileTcl` returns the ARE. Every non-alphanumeric literal is emitted as a
`\uXXXX` escape. `matches RE V` is the validator protocol, taking a string
value. `unicode-property` is reserved and currently rejected. There are no
backreferences or lookaround.
