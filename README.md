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

Between the two sits a semantic layer, the **HIR** (`hir/`, §16): core IR
with every name resolved to a binding identity, every expression typed, and
scopes, captures, refinements and known call targets made explicit. The
compiler compiles from HIR; the interpreter runs core IR, and HIR lowers back
to it.

A first, minimal source language (`surface/`, §17) parses Botlish source
into a surface AST and builds HIR from it.

```
source ──surface::parse──▶ AST ──surface::lowerToHir──┐
                                                      ▼
core IR ──────────────hir::build────────────────────▶ HIR ──hir::lower──▶ core IR ──▶ interpreter
                                                       │
                                                       └──────────────────────────▶ Tcl compiler
```

```
core/            runtime and interpreter (see "Implementation map")
hir/             semantic HIR: resolution, types, refinements, lowering
compiler/        HIR -> Tcl compiler
surface/         source language: lexer, parser, surface AST, AST -> HIR
examples/*.ir    acceptance programs as IR data
examples/hir/    HIR samples (.hir text) with the core IR they lower to
examples/surface/  source programs (.bot)
tests/*.test     tcltest suite
main.tcl         example runner
```

```sh
tclsh tests/all.tcl                         # test suite, both backends
CORE_BACKEND=compile tclsh tests/all.tcl    # test suite, one backend
tclsh main.tcl                              # run all examples (interp)
tclsh main.tcl -backend compile -code FILE.ir   # compile, show generated Tcl, run
tclsh main.tcl -hir FILE.ir                 # show the program's HIR, run
tclsh main.tcl -backend compile FILE.hir    # read HIR text, compile it, run
tclsh main.tcl examples/surface/03-closure.bot            # run source (interp)
tclsh main.tcl -backend compile -hir -ast FILE.bot   # show AST and HIR, compile, run
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
| `integer?` | any → bool, type test of `int` | true: arg 0 : `int` |
| `string?` | any → bool, type test of `str` | true: arg 0 : `str` |
| `list?` | any → bool, type test of `list` | true: arg 0 : `list` |
| `ok?` | any → bool, type test of `Result.ok` | true: arg 0 : `Result.ok` |
| `error?` | any → bool, type test of `Result.error` | true: arg 0 : `Result.error` |
| `result-value` | ok Result → its value | |
| `result-error` | error Result → its payload | |
| `length` | str → int | |
| `substring` | str, int, int → str (characters `start <= i < end`) | |
| `lowercase` | str → str | |
| `concat` | str, str → str | |
| `Emailish?` | str → bool, type test of `Emailish` (library `web`) | true: arg 0 : `Emailish` |
| `UriQueryValue?` | str → bool, type test of `UriQueryValue` (library `web`) | true: arg 0 : `UriQueryValue` |
| `uriEscape` | str → `UriQueryValue` (library `web`) | |

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
string. The compiler relies on these declarations (§13). Compiled code
never re-checks them: its inlined intrinsics and type tests are exact, and
generic calls go through the runtime, which checks.

**Type tests.** `-tests-type T` declares a native to be a *type test*: a
pure one-argument predicate that returns exactly `core::type::acceptsValue T ARG`.

* Its parameter type must be `any` or a primitive kind `P`, with `T` a
  subtype of `P`. The runtime itself rejects arguments not of kind `P`, with
  `core::value::expect`'s `TYPE` error, before calling the implementation.
* The result type is `bool`. Unless given explicitly, `-refines-true {0 T}`
  is added.
* The reference runtime verifies every answer against `acceptsValue`. A
  wrong answer raises `CORE CONTRACT TYPE`.

Because the answer is fully specified by the type, a compiler may decide the
call from static types, or replace it with an inline membership test (§13).
Compiled code trusts the declaration, so only the interpreter catches a lying
type test. `core::type::definePredicate` registers type tests, and so do the
builtin kind and tag predicates.

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
| `core::compiler::unitHir EXPRS ?MODE?` | the HIR a unit was compiled from |
| `core::compiler::evalHir HIR` | compile and run a program-mode HIR directly; returns the value |
| `hir::parse TEXT` / `hir::readFile PATH` | read HIR text (the `hir::format` notation) back into HIR |
| `hir::build EXPRS ?-mode M? ?-strict 0\|1? ?-origins D? ?-files D?` | build the HIR of a program (§16) |
| `surface::lex` / `surface::parse SOURCE ?FILE?` | Botlish source → tokens / surface AST (§17) |
| `surface::formatAst AST ?-spans 1?` | readable surface AST |
| `surface::lowerToHir AST ?-strict 0\|1?` | surface AST → HIR |
| `surface::compile SOURCE ?FILE? ?-strict 0\|1?` / `surface::readProgramFile PATH` | source → HIR |
| `hir::lower HIR` / `hir::format HIR ?-origins 1?` | HIR → core IR / readable HIR |
| `hir::*` queries | nodes, scopes, bindings, symbols, types, captures, refinements (§16) |
| `hir::types::*` | static types: core types plus `{native N}`, `{block E A R}`, `never` (§13) |
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
| `core::loadProgramFile PATH` | load the libraries a `.ir` file names with `# requires: NAME…`, then read it |
| `core::loadLibrary NAME` | load the optional library `lib/NAME.tcl` (once) |

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
| `lib/web.tcl` | optional demonstration library (`core::loadLibrary web`): `Emailish`, `UriQueryValue`, `uriEscape` |
| `hir/hir.tcl` | HIR data model, ids, `hir::build`, queries |
| `hir/resolve.tcl` | scopes, bindings, symbols, lexical resolution, captures, control targets |
| `hir/types.tcl` | static types (delegating to `core/type.tcl`) and type inference |
| `hir/refine.tcl` | branch refinement facts and statically decided type tests |
| `hir/lower.tcl` | HIR → core IR |
| `hir/format.tcl` | readable HIR |
| `hir/read.tcl` | HIR text → HIR |
| `compiler/compiler.tcl` | HIR → Tcl compiler backend |
| `surface/lexer.tcl` | source → tokens, indentation → `INDENT`/`DEDENT` |
| `surface/parser.tcl` | tokens → surface AST (recursive descent) |
| `surface/ast.tcl` | spans, syntax errors, AST formatting |
| `surface/lower.tcl` | surface AST → HIR |
| `surface/surface.tcl` | loader and `surface::compile` / `readProgramFile` |
| `bench/` | benchmark programs and runner |

Implementation notes (not part of the semantics):

* Runtime values are tagged Tcl lists (`{int 42}`, `{str hello}`, ...).
* Environments are ids in a frame store that only grows. Nothing is reclaimed,
  which is acceptable for a reference model.
* Interpreter handlers use `core::interp::valueOf`, which relies on Tcl's
  `return -level 2` to propagate an abrupt completion out of the calling
  handler. What propagates is still an explicit completion value.

## 11. Not implemented (deliberately)

Surface syntax beyond the minimal language of §17, macros, modules, objects, assignment, mutable
variables, exceptions, `?` propagation, pattern matching, a type checker
beyond refinement tracking, async, coroutines, threads, FFI, or native code
generation.

## 12. The compiler backend

`compiler/compiler.tcl` translates IR into Tcl procedures that Tcl then
bytecode-compiles. It reuses the runtime (values, natives, environments, the
call boundary and refinement metadata) but none of the interpreter's
evaluation machinery. There are no completion objects, no per-node dispatch,
and no name search in scopes it can resolve statically.

The compiler does no semantic analysis of its own. Each unit is first built
into HIR (§16), which says which binding every name denotes, whether it is
bound yet, the type of every expression, captures, refinements and known
call targets. The compiler only decides how to run that in Tcl: frames,
representations, intrinsics, direct calls and control codes.

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

**Storage.** Names are resolved by the HIR using the scope rule in §2; the
compiler stores each binding according to its HIR scope:

* A scope in which a block is created (its HIR `closures`) is *materialized*
  as a runtime frame, because a closure may capture it and its bindings and
  refinements can be observed. It declares its names on entry and reads and
  writes through `core::env`, which checks use-before-binding at run time.
* Any other scope never escapes its proc. Its bindings are Tcl locals `vN`.
  The HIR decides use-before-binding and duplicate bindings statically there,
  and they compile into the matching error.
* Root bindings compile to constants. Ambient bindings (names of the
  arbitrary environment of a *sequence*-mode unit, `evalIn`) are looked up
  dynamically. In *program* mode (`evalProgram`), the environment is a fresh
  program scope over a fresh root, so every name is known.

**Refinements** are installed only in materialized branches, since those are
the only ones where facts can be observed. They use the callee value the
condition actually called, plus the same metadata rules as the interpreter.

**Testing.** `tests/all.tcl` runs every test file once per backend, with the
backend chosen by `CORE_BACKEND`. `tests/backends.test` also runs a corpus
under both backends in one process and compares the outcomes, and checks
calls between compiled and interpreted Blocks. `tests/inference.test` does
the same for programs built to expose unsound type facts (§13). The
`tests/hir-*.test` files cover the HIR (§16).

**Known gap:** compiled code cannot yet propagate a `propagate-error`
completion out of a call. No form produces one yet.

## 13. Type inference

Types are inferred on the HIR (`hir/types.tcl`, §16) and consumed by the
compiler. Static types are the semantic types of `core/type.tcl` (§14), plus
a few forms that describe values more precisely than a value type can.
Types only *describe* runtime values. They never change what a program
means: the compiler uses them to pick faster code whose behavior is
identical, and falls back to generic code whenever a type is unknown. The
invariant is that an expression of semantic type `T` always evaluates to a
value `v` for which `core::type::acceptsValue T v` is true.

| Type | Defined in | Describes |
|------|------------|-----------|
| `int` `str` `bool` `unit` `list` `result` `native` `block` | core | values of that kind |
| `{refined BASE {NAMES…}}` | core | values of `BASE` satisfying every named type |
| `any` | core | nothing known |
| `{native NAME}` | hir | exactly the native `NAME` |
| `{block EXPR ARITY RESULT}` | hir | a Block created by the block expression `EXPR` (an ExprId), whose calls return `RESULT` |
| `never` | hir | no value: evaluation does not complete normally |

`hir::types::lub`, `narrow` and `kindOf` handle the extra forms themselves
and delegate everything else to `core::type`. For example,
`kindOf {refined str {Emailish}}` is `str`, and narrowing `str` by
`Emailish` gives `{refined str {Emailish}}`. None of these forms mention a
representation: the compiler maps a block's `EXPR` to the proc it generates.

**Where types come from.**

* **Literals and constructors:** `const`, `ok`, `error-value`, `list`.
* **Root constants** in program mode: `+` has type `{native +}`, and `true`
  has type `bool` (and, as an `if` condition, decides the branch).
* **Native signatures** (§8): a call of `-` has type `int`, and a call of
  `uriEscape` has type `{refined str {UriQueryValue}}`.
* **Immutability:** a binding has the type of the expression it was bound
  to, and keeps it.
* **Refinements:** inside the `then` branch of `(if (call (ref integer?) (ref x)) …)`,
  `x` is `int`. Inside the `then` branch of `Emailish?`, it's
  `{refined str {Emailish}}`. Nested predicates accumulate evidence. As in
  the interpreter, only arguments that are plain `(ref NAME)` are refined.
* **Flow facts:** when a native that requires a type returns, its argument
  had that type. The runtime contract check guarantees this. Because
  bindings are immutable, the argument keeps the type for the rest of the
  path.
* **Block results:** the result type is the lub of the body's value and
  every reachable `return`. A block that calls itself through its binding is
  analyzed under an assumed result type, starting from `never`, until the inferred
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
* **Intrinsics:** calls of `+ - * < <= > >= == eq list ok? error?` compile
  to inline Tcl. An argument whose kind isn't known is first checked with
  `core::value::expect`. That check raises exactly the error the native
  would, in the same order; the flow fact above then covers the argument.
* **Type tests** (natives declared with `-tests-type T`, §8), with argument
  of static type `S` and parameter kind `P` (decided by the HIR, which marks
  the call `known`):
  * **Folded to true** if `S ⊑ P` and `S ⊑ T`. For example, `Emailish?` on a
    value already refined to `Emailish`, or `UriQueryValue?` on the result
    of `uriEscape`.
  * **Folded to false** if `S ⊑ P` and `S`'s base differs from `T`'s. For
    example, `integer?` on a string.
  * **Otherwise inline:** the parameter kind check, then either
    `string equal [lindex $v 0] KIND` for a primitive `T` or
    `core::type::acceptsCanonical T $v`. The generic native call is gone.
  * If `S` isn't a subtype of `P`, the test isn't folded, so the kind error
    still happens at run time.
* **Folding:** an `if` with a constant condition compiles only the branch
  that runs.
* **Direct calls:** in program mode, a call whose HIR target is a block
  expression with matching arity calls that block's proc directly. The
  generic invoke is unnecessary
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
Native type contracts are checked on generic native calls, which costs
compiled `sum-refined` roughly 10%; inlined intrinsics and type tests are
unaffected.

`refined-checks.ir` repeats `Emailish?` and `UriQueryValue?` checks, some of
them made redundant by an enclosing refinement. Compiled, it went from
20.9 ms to 8.5 ms once type tests were folded and inlined instead of called
generically.

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
`uriEscape` as an optional demonstration library. It isn't loaded by core:
call `core::loadLibrary web`, or put `# requires: web` in a program file,
which `main.tcl` and `bench/bench.tcl` honor. `examples/05-refined-strings.ir`
shows all of it.

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

## 16. Semantic HIR

`hir/` is the semantic layer between core IR and the backends. Core IR stays
the executable specification: small, and all an evaluator needs. The HIR
records what a program *means* before it runs: which binding every name
denotes, the type of every expression, which facts hold where, what each
block captures and what each call calls. The compiler compiles from HIR, and
future source-level features (namespaces, traits, extension methods, foreign
symbols, the output of macros) are meant to live here and lower to existing
core forms. Core IR only grows for run-time semantics it can't already
express.

```
source text ─▶ syntax tree ─▶ (macro expansion) ─▶ HIR ─▶ core IR ─▶ interp / compiler
               (not yet)                            ▲
core IR ────────────────────── hir::build ──────────┘   (today)
```

```tcl
set h [hir::build $exprs]              ;# -mode program|sequence, -strict 1|0
puts [hir::format $h]
hir::lower $h                          ;# structurally equal to $exprs
```

```
program s2 binds b1 x, b2 f
e1 bind b1 x : int
    e2 const 10 : int
e3 bind b2 f : block(e4)/1 -> int
    e4 block s3 (b3 v) captures (b1 x) : block(e4)/1 -> int
        e5 if : int
            e6 call native(integer?) : bool
                e7 ref b4 integer? : native integer?
                e8 ref b3 v : any
            then s4 refines b3 v : int
                e9 return -> e4 : never
                    e10 ref b3 v : int
            else s5
                e11 ref b1 x : int deferred
```

### Data model

A HIR program is a dict of flat tables, so every entity is addressable by id.
`hir/hir.tcl` documents every field.

| Table | Entry |
|-------|-------|
| `exprs` | expression node: `id kind origin scope type reachable`, plus per-kind fields |
| `scopes` | `kind parent invocation owner names bindings closures refinements` |
| `bindings` | `name kind scope declaredBy origin type symbol value` |
| `symbols` | what a name can denote besides a Botlish binding: `kind name provenance` |
| `types` | interned type forms (§13) |
| `diagnostics` | static errors: `kind message expr` |

Expression kinds follow core IR, with semantic fields added:

| Kind | Fields |
|------|--------|
| `const` | `literal`, `value` |
| `ref` | `name` (the spelling, for diagnostics), `binding`, `init` (`yes`, `no` or `deferred`) |
| `bind` | `name`, `binding`, `value`, `duplicate` |
| `block` | `bodyScope`, `params` (BindingIds), `body`, `captures` (BindingIds), `resultType` |
| `call` | `callee`, `args`, `target` (`""`, `{native SymbolId}` or `{block ExprId}`), `known` (`""`, `1` or `0`) |
| `if` | `condition`, `thenScope`/`thenBody`, `elseScope`/`elseBody`, `refinements` (outcome → BindingId/fact pairs) |
| `loop` | `bodyScope`, `body` |
| `return` / `break` / `continue` | `value`, `target` (the block or loop ExprId they leave) |
| `ok` / `error` | `value` |

There is one call form. Operators, predicates, natives and blocks are all
`call`s. What is known about the callee is metadata (`target`, `known`), so
later resolution (trait methods, multiple dispatch, foreign functions) can
add metadata without adding call forms.

### IDs and origins

IDs are strings with a kind prefix: `e` ExprId, `s` ScopeId, `b` BindingId,
`y` SymbolId and `t` TypeId. `f` (FileId) and `n` (NodeId) are reserved for
source files and syntax nodes. IDs are allocated in order during a
deterministic walk of each program, so building the same IR twice gives the
same ids. Root bindings are created on first reference, so ids don't depend on
how many natives are registered.

Spelling is never identity. Shadowing yields distinct BindingIds, and facts,
captures and types attach to BindingIds, not names.

Every node has an `origin`. Today that's `{ir PATH}`, where PATH indexes into
the input IR: `{ir {1 2}}` is argument 1 of the call at top-level position 1.
A syntax tree will supply `{file f3 start 120 end 144}` in the same field, so
later analyses can report back to source through ExprIds.

### Scopes and resolution

`hir/resolve.tcl` walks the IR once, in evaluation order, and applies the
run-time rules of §2 statically:

* Scope kinds are `root` (natives, `true`, `false`, `unit`), `program`,
  `block` (one invocation: parameters and body), `branch`, `loop` (one
  iteration) and `ambient` (the unknown environment of a sequence-mode unit).
  A scope's `invocation` is the block whose call it belongs to. Code in one
  invocation runs in walk order.
* A scope declares every name it binds on entry. A reference denotes the
  binding of the innermost scope that declares its name. Failing that, it
  denotes a root binding (program mode) or an ambient binding (sequence
  mode). Otherwise it's unresolved (`UNBOUND`).
* `init` says whether the binding has its value when the reference runs.
  `yes`: bound earlier in the same invocation, or a parameter or root binding.
  `no`: same invocation but not bound yet, so evaluating it raises "used
  before its binding". `deferred`: the reference is inside a closure, so it's
  decided when the closure is called.
* A `bind` of a binding that's already bound is marked `duplicate`. It still
  denotes the first binding, and raises `DUPLICATE` when evaluated, after its
  value.
* A block's `captures` are the non-root bindings its body refers to (at any
  depth) that are defined outside the block. A scope's `closures` are the
  blocks created in it.
* `return` targets the innermost block. `break` and `continue` target the
  innermost loop within that block.

Queries: `hir::lookup`, `hir::visibleBindings`, `hir::refinementsAt`,
`hir::captures`, `hir::scopeWithin`, `hir::exprsAt ORIGIN`, `hir::walk` and
`hir::children`.

Static errors become diagnostics. With `-strict 1` (the default),
`hir::build` raises the first one, with the interpreter's error code and
message. With `-strict 0` (which the compiler uses), they stay in the HIR, and
the lowered program raises them at run time exactly where the interpreter
would. Malformed IR always raises `CORE MALFORMED`.

### Types and refinements

`hir/types.tcl` types every expression, using the rules of §13, and interns
the types. Unreachable code is still typed but marked `reachable 0`, and it
contributes nothing to result or break types. Semantic types never encode
representation: no Tcl variables, frames or boxing.

Refinements (`hir/refine.tcl`) follow the run-time rule of §6. When a
condition calls a callee whose static type is a known native, that native's
metadata gives facts about the arguments that are plain references. Facts are
BindingId/type pairs. They're recorded on the `if` (per outcome) and on the
branch scope, and they narrow the binding only inside that branch. Nothing in
the HIR refers to a predicate by name. A type test decided by static types
(§8) sets the call's `known` field. If an `if` condition is known (a decided
test, or the root binding `true` or `false`), the other branch is marked
unreachable.

### Lowering

`hir::lower` (`hir/lower.tcl`) erases ids, types, captures, refinements,
targets and origins. Each node becomes its core IR form (`error` becomes
`error-value`). Constants keep their literal text and references keep their
spelling. Because resolution followed the run-time rules, run-time lookup
finds the same binding. For today's HIR, lowering gives back the input
program. The tests check this for the examples, the benchmarks and the
differential corpora, and check that the lowered programs behave identically
under the interpreter and the compiler.

### HIR text and samples

The `hir::format` notation is also an input format. `hir::parse` (and
`hir::readFile`, which honors `# requires:` and skips `#` comment lines)
rebuilds a complete HIR program from it. The text states the binding ids,
scopes, types, captures, refinements, call targets and flags. The reader
derives everything else: binding kinds and types, scope structure, closures,
root symbols, diagnostics and origins. It rejects text that is malformed or
inconsistent (an id declared twice, a reference to a binding that isn't
visible, a block whose type names another block) with `{HIR PARSE}`. It does
not check that the stated facts are *true*. To check that, compare the text
with `hir::format [hir::build [hir::lower $h]]`.

`core::compiler::evalHir HIR` compiles a program-mode HIR as given, without
rebuilding it from IR, and runs it like `core::evalProgram`. The compiler
trusts the HIR's facts.

`examples/hir/NAME.hir` are samples covering scopes and shadowing, closures,
recursion, refinements, control flow, refined strings and use before
binding. Each sits next to the `NAME.ir` it lowers to and states its outcome
in a `# expect:` or `# expect-error:` comment. `tests/hir-samples.test`
checks, for every sample, that:

* it reads back to the same text,
* its stated facts are what analysis of its IR derives,
* it lowers to `NAME.ir`,
* the interpreter runs the lowered IR to the expected outcome,
* the compiler, compiling the parsed HIR itself, gives the same outcome, and
* both backends agree on the lowered IR.

### Who does what

Moved out of the compiler into HIR:

* lexical resolution and binding identity (the compiler used to key bindings
  as `SCOPE:NAME`)
* scope contents, and use-before-binding and duplicate decisions
* static type inference, flow facts and branch refinement facts
* the fixpoint for recursive block result types (the compiler now compiles
  each block once)
* statically decided type tests
* known call targets (a native symbol or a block expression)
* block captures, and the closures created in each scope
* control-flow targets

Deliberately left in the Tcl backend:

* which scopes become runtime frames, and Tcl variables for everything else
* operand representations (boxed, bare integer, 1/0) and coercions between
  them
* intrinsics, kind checks, and constant folding the HIR doesn't decide (such
  as `==` on values of different kinds)
* emitting direct calls, generic calls, and control flow as Tcl completion
  codes
* installing refinements in materialized frames, using the callee value that
  was actually called

On the 204 programs the test suite evaluates, the HIR-driven compiler infers
the same binding types as the previous compiler and emits the same code
shape: the same counts of generic calls, kind checks, frame operations and
inline expressions. The one difference: a block that refers to an unbound
name now has result type `never` (it always raises) instead of `any`.

### Known limitations

* HIR is built from unresolved trees in core IR notation, whether they come
  from IR files or from source (§17). Source-built HIR carries source spans
  as origins (`hir::build -origins`), but there's no lossless syntax tree: no
  NodeIds, preserved comments or formatting.
* IDs are deterministic per build but not stable across edits. Incremental
  and LSP use will need identity that survives edits.
* HIR refinements are only the statically provable subset. When the callee
  isn't statically known (a parameter, say), the interpreter may still
  install facts the HIR doesn't have.
* The compiler still materializes every scope a block is created in, not just
  scopes whose bindings are captured. Captures are available, but frames are
  observable (`core::blockEnv`, refinement probes), so using them needs care.
* The compiler can fold conditions the HIR doesn't decide (`==`, intrinsic
  kind decisions) and prune a branch the HIR considers reachable. Types stay
  sound, but the HIR's type can be less precise than what the compiled code
  knows.
* An ambient binding (sequence mode) means "the host environment's binding
  of NAME". That identity is approximate if the sequence also binds the name.
* The only symbols are builtins. Parameters are typed `any`: there are no
  type annotations and no function types beyond `{block E A R}`.
* In sequence mode, malformed IR is rejected for the whole unit when it's
  built, including nodes the interpreter would never reach. The compiler
  already did this for the nodes it compiled.
* The HIR is made of persistent Tcl dicts, copied on update. That favors
  clarity over speed.

### Next extension

Give HIR a symbol layer: a module or namespace scope kind whose bindings
denote symbols with canonical provenance (`users::save`). Resolution already
goes through scope kinds and symbol entries. A qualified or method-style
reference could then resolve to the existing `ref` and `call` forms, with the
canonical symbol as the `target`, and lower to existing core IR. After that,
take origins from a lossless syntax tree (FileId and NodeId) so tooling can
query the HIR by source position. On the backend side, the next step is to use
`captures` so that only captured scopes are materialized.

## 17. Surface language (first milestone)

`surface/` is a small Python-like source language. It exists to prove the
vertical slice `source → tokens → surface AST → HIR → core IR → backends`,
not to be the full language. It adds no semantics: every construct lowers to
HIR that already existed, and HIR does all resolution, capture analysis,
typing and checking.

```botlish
fn make_adder(x):
    fn add(y):
        x + y

    add

add10 = make_adder(10)
add10(32)          # 42 (add captures x)
```

### Syntax

* `x = e` is an **immutable binding**, not assignment. A second binding of a
  name in the same scope is `DUPLICATE`; nested scopes may shadow.
* `fn f(a, b):` declares a function. The body's last expression is its
  value; `return` exits early.
* `if c:` / `else:` (optional `else`), `loop:`, `break [e]`, `continue`.
* Integers (decimal, arbitrary precision, no leading zeros), strings
  (`"..."`, escapes `\ \" \n \r \t`), `true`, `false`, `unit`, lists
  `[a, b]`, calls `f(x)(y)`.
* Operators, from highest precedence: call, unary `-`, `*`, `+ -`,
  `== < <= > >=`. Arithmetic is left-associative. Comparisons don't chain
  (`a < b < c` is a syntax error).
* Blocks are delimited by indentation (spaces only; tabs are an error).
  Blank and comment lines (`#`) don't count. Newlines inside `( )` and `[ ]`
  are ignored. Trailing commas are allowed in parameters, arguments and lists.
* Names are `[A-Za-z_][A-Za-z0-9_]*`. `?` is reserved, so natives like
  `integer?` or `test-log` can't be named from source yet.

The full grammar is at the top of `surface/parser.tcl`.

### Lowering

| Source | HIR (as the core IR it is built from) |
|---|---|
| `42`, `"s"` | `const 42`, `const str s` |
| `true` `false` `unit`, `x` | `ref true` …, `ref x` |
| `a + b`, `-a` | `call (ref +) a b`, `call (ref -) (const 0) a` |
| `[a, b]` | `call (ref list) a b` |
| `f(a)` | `call f a` |
| `x = e` | `bind x e` |
| `fn f(a): body` | `bind f (block {a} body…)` |
| `if c: t` / `else: e` | `if c (block {} t…) (block {} e…)`, inline branches; no `else` → empty branch (`unit`) |
| `loop: body` | `loop (block {} body…)` |
| `return` / `break` | `return (ref unit)` / `break` |

Every HIR expression, scope and binding built from source has the origin
`{file f1 start S end E line L column C endLine L2 endColumn C2}`. The HIR's
`files` table maps `f1` to the path. Operator callees point at the operator,
a function's block at its parameter list and body, and branch and loop scopes
at their suites.

### Errors

Syntax errors stop at the first error and raise
`{SURFACE SYNTAX DIAGNOSTIC}` with `FILE:LINE:COLUMN: message`. HIR's
semantic diagnostics (`DUPLICATE`, `UNBOUND`, control placement) are raised
statically as `{CORE SEMANTIC KIND}`, with the source location before the
message. With `-strict 0` they stay in the HIR and are raised at run time.

### Samples and tests

`examples/surface/*.bot` state their outcome in a `# expect:` comment.
`tests/surface-samples.test` runs each one through the interpreter (from the
lowered IR) and the compiler (from the HIR). It checks that both backends
agree, and that the HIR equals what `hir::build` derives from its lowered IR.
`surface-lexer.test`, `surface-parser.test` and `surface-lowering.test`
cover the layers separately.

### Known limitations

* A list literal calls whatever `list` is in scope. A program that binds
  `list` changes what `[...]` means. HIR has no unshadowable way to name a
  root binding yet.
* Duplicate parameter names (`fn f(a, a)`) are rejected by the core IR shape
  check, without a source location.
* No error recovery, no partial parsing, and no stable node identity across
  edits yet (needed for an LSP).
