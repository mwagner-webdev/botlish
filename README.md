# Core evaluator — executable semantic specification

A small reference evaluator, written in Tcl, for the semantic core of a new
language. It is a specification you can run, not a production runtime: it
aims for clarity over speed.

Tcl is only the implementation language. The semantics described here are
the language's own. Where Tcl behaves differently (truthiness, strings as
values, exceptions, variable scope, command lookup), the evaluator does
**not** inherit Tcl's behavior.

There are three backends that implement the same semantics:

* **`interp`**: the tree-walking reference interpreter (`core/evaluator.tcl`).
* **`compile`**: a compiler from IR to Tcl procedures (`compiler/compiler.tcl`,
  see §12).
* **`cranelift`**: a native code backend. HIR is lowered to a small native IR
  and compiled to machine code with Cranelift (`native/`, see §20).

The whole test suite runs against `interp` and `compile`. The algorithm
corpus and the native tests run on all three, and
`tests/native-coverage.tcl` classifies every test of the suite on
`cranelift`.

Between the two sits a semantic layer, the **HIR** (`hir/`, §16): core IR
with every name resolved to a binding identity, every expression typed, and
scopes, captures, refinements and known call targets made explicit. The
compiler compiles from HIR; the interpreter runs core IR, and HIR lowers back
to it.

A small source language (`surface/`, §17) parses Botlish source
into a surface AST and builds HIR from it.

```
source ──surface::parse──▶ AST ──surface::lowerToHir──┐
                                                      ▼
core IR ──────────────hir::build────────────────────▶ HIR ──hir::lower──▶ core IR ──▶ interpreter
                                                       │
                                                       ├──────────────────────────▶ Tcl compiler
                                                       │
                                                       └──native::lower──▶ NIR ──▶ Cranelift ──▶ machine code
```

```
core/            runtime and interpreter (see "Implementation map")
hir/             semantic HIR: resolution, types, refinements, lowering
compiler/        HIR -> Tcl compiler
native/          HIR -> NIR -> Cranelift native backend (Tcl lowering; Rust runtime and codegen)
surface/         source language: lexer, parser, surface AST, AST -> HIR
examples/*.ir    acceptance programs as IR data
examples/hir/    HIR samples (.hir text) with the core IR they lower to
examples/surface/  source programs (.bot)
examples/stdlib/   algorithm corpus in Botlish: reverse, replace, CSV, matmul (§18)
tests/*.test     tcltest suite
main.tcl         example runner
```

```sh
tclsh tests/all.tcl                         # test suite, interp and compile
cargo build --release --manifest-path native/Cargo.toml   # build the native backend (§20)
tclsh tests/native-coverage.tcl             # test suite on cranelift, classified (§20)
tclsh main.tcl -backend cranelift FILE.bot  # run natively
tclsh main.tcl -emit-nir -emit-clif FILE.bot   # show NIR, then Cranelift IR, of every function
CORE_BACKEND=compile tclsh tests/all.tcl    # test suite, one backend
tclsh main.tcl                              # run all examples (interp)
tclsh main.tcl -backend compile -code FILE.ir   # compile, show generated Tcl, run
tclsh main.tcl -hir FILE.ir                 # show the program's HIR, run
tclsh main.tcl -backend compile FILE.hir    # read HIR text, compile it, run
tclsh main.tcl examples/surface/03-closure.bot            # run source (interp)
tclsh main.tcl -backend compile -hir -ast FILE.bot   # show AST and HIR, compile, run
tclsh bench/bench.tcl                       # compare backends on bench/*.ir
tclsh bench/corpus.tcl                      # baseline timings of the algorithm corpus (§18)
tclsh main.tcl -aot examples/stdlib/matmul.bot   # closed-AOT readiness report (§19)
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
| `list_length` | list → int | |
| `list_get` | list, int → any (the element at `0 <= i < length`, else `RANGE`) | |
| `list_append` | list, any → list (a new list; the argument is unchanged) | |
| `Emailish?` | str → bool, type test of `Emailish` (library `web`) | true: arg 0 : `Emailish` |
| `UriQueryValue?` | str → bool, type test of `UriQueryValue` (library `web`) | true: arg 0 : `UriQueryValue` |
| `uriEscape` | str → `UriQueryValue` (library `web`) | |

New natives are registered through the registry, not by changing the
evaluator:

```tcl
core::registerNative even? -arity 1 -impl myEvenImpl -refines-true {0 Even}
```

`-refines-true` and `-refines-false` take `ARG-INDEX TYPE` pairs.

`-runtime {TAG…}` states what a native implementation of the operation
needs from a runtime beyond bare machine operations: `bigint`,
`string-alloc`, `list-alloc`, `result-alloc`, `char-index`, `range-check`,
`structural-equality`, `evidence` (`core/native.tcl` defines each). It is
metadata for static analysis (§19) and never changes what a call does.

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
| `hir::build EXPRS ?-mode M? ?-strict 0\|1?` | build the HIR of a core IR program (§16) |
| `hir::buildSyntax NODES ?-mode M? ?-strict 0\|1? ?-origin O? ?-files D?` | build HIR from syntax nodes (`hir::syntax::*Node`, `rootRef`, `fromIR`) |
| `surface::lex` / `surface::parse SOURCE ?FILE? ?-recover 1?` | Botlish source → tokens / surface AST (§17) |
| `surface::formatAst AST ?-spans 1? ?-ids 1?` | readable surface AST |
| `surface::findNode AST ID` / `surface::hirExprs HIR ID` | an AST node / its HIR expressions, by structural id |
| `surface::lowerToHir AST ?-strict 0\|1?` | surface AST → HIR |
| `surface::compile SOURCE ?FILE? ?-strict 0\|1?` / `surface::readProgramFile PATH` | source → HIR |
| `hir::lower HIR` / `hir::format HIR ?-origins 1?` | HIR → core IR / readable HIR |
| `hir::*` queries | nodes, scopes, bindings, symbols, types, captures, refinements (§16) |
| `hir::aot::analyze HIR` / `hir::aot::explain HIR ?ANALYSIS?` | closed-AOT readiness: structured analysis / readable report (§19) |
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
| `core/primitives.tcl`, `core/predicates.tcl`, `core/strings.tcl`, `core/lists.tcl` | builtin natives |
| `lib/web.tcl` | optional demonstration library (`core::loadLibrary web`): `Emailish`, `UriQueryValue`, `uriEscape` |
| `hir/hir.tcl` | HIR data model, ids, `hir::build`, queries |
| `hir/syntax.tcl` | syntax nodes: HIR's input, and core IR → syntax |
| `hir/hygiene.tcl` | renaming bindings that shadow root references |
| `hir/resolve.tcl` | scopes, bindings, symbols, lexical resolution, captures, control targets |
| `hir/types.tcl` | static types (delegating to `core/type.tcl`) and type inference |
| `hir/refine.tcl` | branch refinement facts and statically decided type tests |
| `hir/lower.tcl` | HIR → core IR |
| `hir/format.tcl` | readable HIR |
| `hir/read.tcl` | HIR text → HIR |
| `hir/aot.tcl` | closed-AOT readiness analysis (§19) |
| `compiler/compiler.tcl` | HIR → Tcl compiler backend |
| `native/lower.tcl` | HIR → NIR native lowering (§20) |
| `native/native.tcl` | the `cranelift` backend: runs the native driver; NIR, CLIF and object entry points |
| `native/src/nir.rs` | NIR parsing and validation |
| `native/src/runtime/` | native `Value` representation, heap and collector, errors, runtime helper ABI |
| `native/src/codegen/` | the `Backend` interface; NIR → Cranelift IR for JIT and object files |
| `surface/lexer.tcl` | source → tokens, indentation → `INDENT`/`DEDENT` |
| `surface/parser.tcl` | tokens → surface AST (recursive descent) |
| `surface/ast.tcl` | spans, syntax errors, AST formatting |
| `surface/lower.tcl` | surface AST → HIR |
| `surface/surface.tcl` | loader and `surface::compile` / `readProgramFile` |
| `bench/` | benchmark programs and runners (`bench.tcl` for `*.ir`, `corpus.tcl` for §18) |
| `examples/stdlib/corpus.tcl` | loading and running the algorithm corpus on each backend |

Implementation notes (not part of the semantics):

* Runtime values are tagged Tcl lists (`{int 42}`, `{str hello}`, ...).
* Environments are ids in a frame store. Only Blocks refer to frames, so
  frames are reclaimed explicitly (`core/env.tcl`, *Lifetime*): creating a
  Block *pins* its environment and every ancestor, and a scope's frame is
  released when the scope ends (block invocation, branch, loop iteration)
  unless it is pinned. When a program ends and its value contains no Block,
  every frame it created is released. Environments created through the
  embedding API are left to the embedder.
* Interpreter handlers use `core::interp::valueOf`, which relies on Tcl's
  `return -level 2` to propagate an abrupt completion out of the calling
  handler. What propagates is still an explicit completion value.

## 11. Not implemented (deliberately)

Surface syntax beyond the minimal language of §17, macros, modules, objects, assignment, mutable
variables, exceptions, `?` propagation, pattern matching, a type checker
beyond refinement tracking, async, coroutines, threads, or FFI.

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
* **Direct native calls:** a call of a HIR-resolved native with fixed arity
  and no intrinsic calls the native's implementation directly, instead of
  dispatching through `core::runtime::callValue`. It then makes the contract
  checks `core::native::invoke` makes, in the same order, except those that
  static types prove. A primitive kind is checked inline. So contract
  violations still raise `CORE CONTRACT TYPE`.
* **Envless functions:** a block that creates no closures, and whose only
  references to outer bindings are callees of direct calls to envless
  blocks, never reads its environment (a greatest fixpoint, so recursion
  qualifies). Direct calls to such a block skip the callee lookup and pass
  no environment, and its proc doesn't rebuild frame variables. The Block
  value itself is still created with its environment. This covers every
  function in the §18 corpus.
* **Self tail calls:** a call of the enclosing block itself, with matching
  arity, in tail position (the body's value or a `return`'s value, through
  `if` branches), and not inside a `loop`, compiles to rebinding `argv`
  (and `captured`, unless the block is envless) and `continue` in a
  `while 1` around the proc body. Such loops need no Tcl recursion depth.

`core::compiler::programTypes EXPRS` reports the inferred types of
program-level bindings. `core::compiler::bindingTypes EXPRS` reports the type
of every `bind` at any depth, including refinements in force at that point.
`tclsh main.tcl -backend compile -code FILE.ir` shows the generated code.

**Performance** (`tclsh bench/bench.tcl`, best of 5, excluding compilation):

| program | interp | compile, untyped | compile, typed |
|---------|-------:|-----------------:|---------------:|
| `fib.ir` | 1121 ms | 326 ms | 12 ms (8.8 ms with direct native calls and envless functions) |
| `loop-count.ir` | 194 ms | 53 ms | 2 ms (1.4 ms) |
| `sum-refined.ir` | 110 ms | 37 ms | 16 ms (17.7 ms) |

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

Every node has an `origin`. HIR built from core IR has `{ir PATH}`, where
PATH indexes into the input IR: `{ir {1 2}}` is argument 1 of the call at
top-level position 1. HIR built from source (§17) has
`{file f1 node ID start .. end .. line .. column ..}`, so later analyses can
report back to source through ExprIds.

### Syntax nodes: how HIR is built

HIR has one input, *syntax nodes* (`hir/syntax.tcl`). Each node states what
was written and where, before anything is resolved: `const`, `ref`, `bind`,
`block` (parameters with their own origins), `call`, `if` and `loop` (with
origins for their branch and body scopes), `return`, `break`, `continue`,
`ok` and `error`. Every node carries its own origin.

```tcl
set n [hir::syntax::bindNode $origin x [hir::syntax::constNode $origin 10]]
set h [hir::buildSyntax [list $n] -origin $programOrigin -files {f1 main.bot}]
```

`hir::build EXPRS` is `hir::syntax::fromIR` followed by `hir::buildSyntax`.
Frontends such as `surface/` build syntax nodes directly. Resolution,
hygiene, types and refinements all happen in `hir::buildSyntax`, so a
frontend never resolves a name.

### Root references and hygiene

`hir::syntax::rootRef ORIGIN NAME` is a reference to the root binding `NAME`
(a native, `true`, `false` or `unit`) that no local binding can shadow. A
frontend uses it for names it introduces itself, such as the `list` a list
literal calls. It resolves directly to the root binding (program mode only).

Core IR has only lexical `ref`, and core IR doesn't need to grow for this:
spelling isn't identity. After resolution, `hir/hygiene.tcl` checks each
root reference. If a lexical lookup of its name would find a local binding,
that binding is renamed `NAME#N`, a name the program doesn't use and source
can't spell. The rename covers the binding, its scope's names, and every
`bind` and `ref` of it. The original name is kept in the binding's
`spelling`. Lowered core IR, the compiler's runtime frames and HIR text then
all agree with the HIR. Diagnostics are computed before renaming and keep the
source spelling.

### Scopes and resolution

`hir/resolve.tcl` walks the syntax nodes once, in evaluation order, and applies the
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

* Source-built HIR carries structural node ids and spans in its origins
  (§17), but there's no lossless syntax tree: no preserved comments or
  formatting. HIR's own ids (`e12`, `b3`) are deterministic per build but
  not stable across edits.
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
* A reference from a closure to a function bound *later* (mutual recursion,
  `examples/surface/09-mutual-recursion.bot`) has the forward type
  `{block E ARITY any}`: its call target is known, its result type is not.
  Whether the binding is bound when the reference runs stays a run-time
  check (`hir::aot::unprovenReferences`).
* `init deferred` covers every reference from inside a closure, including
  references that are certainly bound when the closure runs (parameters of
  the enclosing block, the function itself, bindings made before the closure
  is created). `hir::aot` (§19) separates these cases; HIR does not.
* Calling a block proves nothing about its arguments. Flow facts come only
  from native signatures, so after `peek(text, i)` returns, `text` is still
  `any` in the caller.
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
keep comments and formatting in a lossless syntax tree so tooling can edit
source through the HIR. On the backend side, the next step is to use
`captures` so that only captured scopes are materialized.

## 17. Surface language

`surface/` is a small Python-like source language. It adds no semantics:
every construct lowers to HIR syntax (§16), and HIR does all resolution,
capture analysis, typing and checking.

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
* An `if` can also be the value of a binding, `return` or `break`
  (`sign = if n < 0:` followed by its blocks). It can't be an operand or an
  argument.
* Integers (decimal, arbitrary precision, no leading zeros), strings
  (`"..."`, escapes `\\ \" \n \r \t`), `true`, `false`, `unit`, lists
  `[a, b]`, calls `f(x)(y)`.
* Operators, from highest precedence: call, unary `-`, `*`, `+ -`,
  `== != < <= > >=`, `not`, `and`, `or`. Arithmetic, `and` and `or` are
  left-associative. Comparisons don't chain (`a < b < c` is a syntax error).
* Blocks are delimited by indentation (spaces only; tabs are an error).
  Blank and comment lines (`#`) don't count. Newlines inside `( )` and `[ ]`
  are ignored. Trailing commas are allowed in parameters, arguments and lists.
* Names are `[A-Za-z_][A-Za-z0-9_]*`. `?` is reserved, so natives like
  `integer?` or `test-log` can't be named from source yet.

The full grammar is at the top of `surface/parser.tcl`.

### Lowering

`^name` is a root reference: it denotes the root binding whatever the
program binds (§16, "Root references and hygiene").

| Source | HIR syntax (as core IR) |
|---|---|
| `42`, `"s"` | `const 42`, `const str s` |
| `true` `false` `unit`, `x` | `^true` …, `ref x` |
| `a + b`, `-a` | `call ^+ a b`, `call ^- (const 0) a` |
| `a != b` | `if (call ^== a b) {^false} {^true}` |
| `not a` | `if a {^false} {^true}` |
| `a and b` | `if a {if b {^true} {^false}} {^false}` |
| `a or b` | `if a {^true} {if b {^true} {^false}}` |
| `[a, b]` | `call ^list a b` |
| `f(a)` | `call f a` |
| `x = e` | `bind x e` |
| `fn f(a): body` | `bind f (block {a} body…)` |
| `if c: t` / `else: e` | `if c {t…} {e…}`, inline branches; no `else` → empty branch (`unit`) |
| `loop: body` | `loop {body…}` |
| `return` / `break` | `return ^unit` / `break` |

`not`, `and`, `or` and `!=` are conditions, not calls. `and` and `or`
evaluate their right operand only when needed. Every operand must be a
Boolean (`NOT-BOOLEAN` otherwise), so the result is always a Boolean. A
program may bind `list`, or name a parameter `list`, without changing what
`[...]` means.

Every HIR expression, scope and binding built from source has the origin
`{file f1 node ID start S end E line L column C endLine L2 endColumn C2}`.
The HIR's `files` table maps `f1` to the path.

### Node ids

Every AST node has a structural `id` that survives unrelated edits. A
statement's id is its parent's id plus a key: `NAME()` for a function,
`NAME=` for a binding, or the statement kind. A repeated key gets `#N`.
Inner nodes add their role (`then`, `cond`, `value`, `left`, `arg1`, …).
For example, the `x + y` in `make_adder`'s inner `add` is
`make_adder()/add()/binary`. Editing one function's body doesn't change ids
outside it. Inserting a statement only changes later siblings with the same
key.

HIR origins carry the id, so `surface::hirExprs HIR ID` finds the HIR
expressions an AST node became, and `surface::findNode AST ID` finds the
node. A rule that adds nodes gives them the id plus a role (`ID/op` for an
operator's callee and constants, `ID/block` for a function's block,
`ID/(a)` for its parameter `a`).

### Errors and recovery

`surface::parse` raises the first syntax error as
`{SURFACE SYNTAX DIAGNOSTIC}` with `FILE:LINE:COLUMN: message`.

`surface::parse SOURCE FILE -recover 1` always returns a program:

* The lexer records each error and recovers locally. It skips bad
  characters, ends unterminated strings at the end of line, and closes open
  brackets at the end of input or before a line that starts like a
  statement.
* A statement that fails to parse becomes an `error` node. Parsing resumes
  after its line and any block indented under it.
* The program's `diagnostics` list every error in source order. `main.tcl`
  uses this to report all syntax errors of a `.bot` file.

`surface::lowerToHir` refuses an AST with diagnostics.

HIR's semantic diagnostics (`DUPLICATE`, including duplicate parameters,
`UNBOUND`, control placement) are raised statically as
`{CORE SEMANTIC KIND}`, with the source location before the message. With
`-strict 0` they stay in the HIR and are raised at run time.

### Samples and tests

`examples/surface/*.bot` state their outcome in a `# expect:` comment.
`tests/surface-samples.test` runs each one through the interpreter (from the
lowered IR) and the compiler (from the HIR). It checks that both backends
agree, and that the HIR equals what `hir::build` derives from its lowered IR.
`surface-lexer.test`, `surface-parser.test` and `surface-lowering.test`
cover the layers separately. `hir-syntax.test` covers HIR syntax, root
references and hygiene.

### Known limitations

**Language**

* `and`, `or` and `not` add no refinements. They lower to nested `if`s, and
  HIR only derives facts from a condition that is a direct predicate call
  (§6), so `if integer?(x) and x > 0:` would not refine `x` in the branch.
  This doesn't bite yet, because predicates can't be named from source.
* An `if` is a value only as the whole right side of `=`, or the whole value
  of `return` or `break`. It can't be an operand or an argument
  (`1 + if c: …`, `f(if c: …)`), because its blocks need their own lines.
  There's no one-line form (`if c: a else: b`) and no `elif`; nest an `if`
  inside `else:` instead.
* Natives whose names contain `?` or `-` (`integer?`, `ok?`, `result-value`,
  `test-log`) can't be named from source. `?` is reserved, and `-` is an
  operator.

**Hygiene**

* A binding renamed for hygiene keeps its core IR name (`list#1`) wherever
  core IR names are visible: lowered IR, `-code` output, `programTypes`,
  runtime environments (`core::envBindings`, block probes), and run-time
  errors of `-strict 0` programs. HIR diagnostics and the binding's
  `spelling` keep the source name.
* Root references work only in program mode. Sequence-mode HIR (`evalIn`,
  an unknown host environment) has no root scope to point at, and building
  one raises `CORE MALFORMED`.

**Errors and recovery**

* Only the first semantic error is raised. `surface::lowerToHir` (strict)
  reports the first HIR diagnostic; the rest stay in the HIR
  (`-strict 0`, `hir::diagnostics`). Syntax errors, in contrast, can all be
  collected with `-recover 1`.
* Recovery is line-based:
  * An error anywhere in a statement discards the whole statement,
    including the block under its header. A typo in an `if` condition drops
    the entire `if`, and errors inside that block go unreported.
  * An error inside a line can cascade into one more diagnostic, for example
    a stray token after an unexpected character (`2 ! 3`).
  * An unclosed bracket is closed only at the end of input or before a line
    that starts like a statement (a keyword or `name =`) and isn't indented
    deeper than the line that opened it. Expression lines in between are
    read as part of the bracket.
* An AST with syntax errors can't be lowered, so there's no partial HIR for
  the valid parts of a broken file.

**Node ids**

* Node ids are structural paths, not identities tracked across edits:
  * Renaming a function or binding changes the ids of everything inside it.
  * Inserting a statement renumbers later siblings with the same key: a new
    `x = …` before an existing one turns `x=` into `x=#2`, and a new
    expression statement shifts `call`, `call#2`, ….
  * Moving code changes its ids.
* There's no incremental reparsing. An editor has to reparse the whole file
  and match nodes by id.

## 18. Algorithm corpus

`examples/stdlib/` holds ordinary algorithms written in Botlish over the
string and list primitives (§8). They're the target corpus for a future
native backend, and they should stay unchanged while that backend learns to
compile them. None of them has a native shortcut.

| File | Function | What it does |
|------|----------|--------------|
| `string_reverse.bot` | `reverse_chars(text)` | reverses the units `length`/`substring` count |
| `string_replace.bot` | `replace(haystack, needle, replacement)` | exact, left-to-right, non-overlapping replacement |
| `csv.bot` | `csv_parse(text)` | valid-input CSV → list of records of field strings |
| `matmul.bot` | `matmul(a, b)` | Int matrix product over nested lists |

Each file is a normal program: its functions followed by a sample
expression with a `# expect:` comment, so `tclsh main.tcl FILE` runs it.
`examples/stdlib/corpus.tcl` appends a driver expression to a program, and
runs the result on a backend. The interpreter runs the lowered IR, and the
compiler compiles from HIR, the same way as `examples/surface/`.

**Semantics chosen for the corpus**

* `reverse_chars` reverses characters as the runtime indexes them (Tcl 8.6
  string indices). Those aren't grapheme clusters: a combining mark ends up
  before its base letter. Only BMP characters are tested, because this Tcl
  build turns non-BMP characters into U+FFFD.
* `replace` with an empty needle returns the haystack unchanged.
  Replacements aren't rescanned.
* `csv_parse` handles `,` separators, `\n` record endings (a final `\n`
  doesn't start an empty record), and quoted fields with `""` escapes and
  embedded commas and newlines. An empty line is a record with one empty
  field. `\r\n`, whitespace trimming and invalid-input diagnostics aren't
  supported.
* `matmul` needs rectangular matrices with compatible, non-zero dimensions
  (an empty `a` gives `[]`). An incompatible shape surfaces as `list_get`'s
  `RANGE` error. Entries are arbitrary-precision Ints.

**How the language shapes them.** Bindings are immutable and a loop
iteration can't carry state, so every loop is a self-recursive tail call
that carries its index and accumulator. The compiler turns these self tail
calls into Tcl loops (§13). The interpreter doesn't, so there recursion
depth grows with the input (`corpus.tcl` raises Tcl's recursion limit). A
function that has to return two things (a field and the
position after it) returns a two-element list.

**Tests.** `tests/stdlib.test` runs about 60 cases (the edge cases of each
algorithm, non-ASCII text, 64-bit overflow, errors) on all three backends
(interp, compile, cranelift) and requires each to produce the stated
outcome. `tests/lists.test` covers the list primitives.

**Benchmarks.** `tclsh bench/corpus.tcl [-runs N] [-markdown] [-all]` times
every algorithm at several input sizes on every backend. Each measurement
runs in a fresh process, so measurements can't disturb each other, and
compilation is excluded. Cases marked slow skip the interpreter unless
you pass `-all`. A backend is a case in `corpus::run` and a column; the
native backend's numbers and compile times are in §20. The table below is
the historical Tcl baseline.

`tclsh bench/corpus.tcl -runs 3` (Tcl 8.6.17 on Windows, best of 3, wall
time, compilation excluded). "compile, before" is the first compiler, from
before direct native calls, envless functions and self-tail loops (Â§13);
"skipped" is a slow case, run with `-all`:

| algorithm | input | interp | compile, before | compile |
|---|---|---:|---:|---:|
| string_reverse | 100 chars | 35.4 ms | 4.8 ms | 1.6 ms |
| string_reverse | 1,000 chars | 296.6 ms | 43.1 ms | 12.9 ms |
| string_reverse | 10,000 chars | 3059.6 ms | 431.3 ms | 127.7 ms |
| string_replace | 1 KB | 569.3 ms | 55.7 ms | 16.7 ms |
| string_replace | 10 KB | 6072.7 ms | 565.6 ms | 159.2 ms |
| string_replace | 100 KB | skipped | 5699.0 ms | 1638.2 ms |
| csv | 100 rows | 2105.8 ms | 156.8 ms | 56.0 ms |
| csv | 1,000 rows | 23930.1 ms | 1977.9 ms | 888.9 ms |
| csv | 10,000 rows | skipped | 49741.9 ms | 37148.1 ms |
| matmul | 2x3 * 3x2 | 15.2 ms | 1.9 ms | 2.2 ms |
| matmul | 8x8 | 225.2 ms | 24.3 ms | 9.2 ms |
| matmul | 16x16 | 1697.6 ms | 175.1 ms | 65.6 ms |
| matmul | 32x32 | skipped | 1380.8 ms | 509.0 ms |

Both backends produced the same value in every measured case.

**Observations** (evidence for runtime and backend work, not defects to fix
here):

* **reverse**: each step copies the whole accumulator (`concat(character,
  reversed)`), so the algorithm is O(n²) in characters copied. Up to 10,000
  characters the call overhead still dominates: times grow linearly.
  Before frames were reclaimed, the interpreter kept every intermediate
  accumulator alive: O(n²) memory.
* **replace**: testing for a match allocates a needle-sized substring at
  every position, and every match copies the result so far. Times are
  linear here because matches are sparse.
* **CSV**: `list_append` copies the list, so building n records costs O(n²).
  Going from 1,000 to 10,000 rows takes about 42× as long compiled: with
  call overhead reduced, the copying dominates.
  Quoted fields grow one character at a time. Every field scan allocates a
  two-element list just to return two values.
* **matmul**: n³ work as expected, but every entry read goes through
  `list_get` with a range check, and its result has no static kind. Every
  `*` and `+` is on arbitrary-precision Ints.
* All four: every loop is a self tail call (`hir::aot` reports `tail`), so
  loop conversion or tail calls in a native backend matter more than any
  other single optimization.

## 19. Closed-AOT readiness analysis

`hir/aot.tcl` answers, for every function and for the program's top level,
the question *could this be compiled to native code without dynamic semantic
dispatch, and what would native code still need?* It only reads HIR (§16):
resolved bindings, types, call targets, captures, control targets and
diagnostics, plus the native registry's signatures and `-runtime` tags. It
emits no code, knows no native by name, and says nothing about any
particular backend.

```sh
tclsh main.tcl -aot FILE          # readable report, then run
tclsh main.tcl -aot-data FILE     # the analysis dict
```

```tcl
set analysis [hir::aot::analyze $hir]    ;# canonical, structured
puts [hir::aot::explain $hir $analysis]  ;# derived text
```

**Status.** A region is `open` if some operation can't be chosen statically
(a call of a value of unknown kind, an ambient name, a static error). It is
`guarded` if every operation is chosen but some operand's kind isn't
established, so native code must check it at run time and keep the value
tagged. It is `closed` otherwise. `dispatch` is `open` exactly when a
semantic blocker exists. `transitive` also takes directly called functions
into account.

Needing runtime support is not a blocker. `+` on two known Ints is closed,
and its need for arbitrary-precision arithmetic is a *requirement*:

| Situation | Reported as |
|-----------|-------------|
| the operation can't be chosen | blocker, class `semantic` (`DynamicCall`, `DynamicBinding`, `UnresolvedBinding`, `UnresolvedControl`, `StaticError`) |
| operation known, operand kind not proven | blocker, class `representation` (`UnknownParameterKind`, `UnknownAggregateElementType`, `UnknownCallResultKind`, `UnknownValueKind`, `UnprovenRefinement`) |
| operation known, needs runtime support | fact plus requirement tag (`bigint`, `string-alloc`, `list-alloc`, `char-index`, `range-check`, `structural-equality`, `closure-env`, `init-check`, `tagged-values`, …) |
| operation always raises | `known-error` fact |

Each blocker and fact carries its ExprId, HIR origin and a location (file,
line, column and surface node id, or the IR path). A representation blocker
also names the operation that needs the kind, the type it needs, and the
*cause* of the unknown kind: a parameter, an element read out of an
aggregate, the result of a call, or a merge. The data model is documented at
the top of `hir/aot.tcl`.

Facts it derives beyond HIR (without changing HIR):

* **Direct calls** are marked `tail`/`self`.
* **Static blocks:** a block whose captures are all bindings of static
  blocks needs no environment. Top-level functions that only call other
  top-level functions are plain functions.
* **Init checks:** a deferred reference needs one only when HIR can't prove
  the binding is bound whenever the closure runs. Parameters, a function's
  reference to itself, and bindings made before the closure is created are
  proven. A forward reference, as in mutual recursion, is not.
* `==` on two known scalars needs no structural comparison.

**The corpus today.** Every function in §18 has closed dispatch: every call
target is a known native or a known Botlish function. None is closed:

| Program | Dispatch | Types | Main blocker | Native-runtime needs |
|---------|----------|-------|--------------|----------------------|
| `reverse_chars` | closed | guarded (4 blockers) | parameter kinds (`text`, `index`, `reversed`) | bigint, char-index, string-alloc, range-check, structural-equality, tagged-values |
| `replace` | closed | guarded (12) | parameter kinds | bigint, char-index, string-alloc, range-check, tagged-values |
| `csv_parse` | closed | guarded (17) | parameter kinds (15); list elements of the `[field, index]` pairs (2) | bigint, char-index, string-alloc, list-alloc, range-check, tagged-values |
| `matmul` | closed | guarded (17) | parameter kinds (13); list elements feeding `*` and `list_get` (4) | bigint, list-alloc, range-check, structural-equality, tagged-values |

(Requirements are unions over each program's functions and exclude the
sample expression's list literal.)

The blockers come from two sources, neither of them dynamic dispatch:

1. **Parameters have no kind.** There are no annotations and no call-site
   inference, and calling a block proves nothing about its arguments. So
   the first use of each parameter needs a check, and results that pass a
   parameter through (`reverse_from`'s accumulator, `dot`'s `total`) are
   `any`. Flow facts from native signatures already remove every later
   check on the same path.
2. **Lists carry no element type.** `list_get` returns `any`. That affects
   `matmul`'s entries and the pairs `csv` returns.

What would close them is left for later milestones: parameter types
(inferred from closed-world call sites, or annotated), element types, and
facts from block calls.

**Found while building the corpus.**

* Fixed: `.bot` and `.ir` files were read in the platform's system encoding
  (cp1252 on Windows), which corrupted non-ASCII source. Program files are
  now read as UTF-8.
* Fixed in the native milestone (§20): calls of a function bound later
  (mutual recursion) had no call target, so `is_even` in
  `examples/surface/09-mutual-recursion.bot` was `open`. It is now
  `guarded`, with an init check. Still in §16's known limitations:
  `init deferred` over-approximates, and block calls add no flow facts.

**For the first native (Cranelift) milestone**, in order of evidence (the
milestone is described in §20; items 1, 3 and 4 are done, 2 and 5 are the
next milestone's):

1. Turn self tail calls into loops. Every loop in the corpus is one, and
   recursion depth otherwise grows with the input. The Tcl compiler already
   does this (§13); `hir::aot`'s `tail`/`self` facts give a native backend
   the same information.
2. Infer parameter kinds from call sites in a closed program. Parameter
   kinds cause 44 of the corpus's 50 blockers.
3. Keep a tagged value representation and runtime helpers for Int (with a
   small-integer fast path), strings and lists, instead of lowering Int to
   bare `i64`. The analysis's requirements list the helpers each function
   needs.
4. Give HIR call targets for forward references to functions.
5. Plan list element types and a growable or persistent list
   representation. `list_append` copying is what makes CSV quadratic.

## 20. The native backend (Cranelift)

`native/` compiles Botlish to machine code. It implements the same semantics
as the interpreter and the Tcl compiler, including arbitrary-precision Ints,
run-time kind checks and the reference error codes and messages. It runs the
algorithm corpus (§18) unchanged.

```sh
cargo build --release --manifest-path native/Cargo.toml   # Rust 1.96+, Cranelift 0.135
tclsh main.tcl -backend cranelift examples/stdlib/csv.bot
tclsh main.tcl -emit-nir examples/stdlib/matmul.bot       # native IR
tclsh main.tcl -emit-clif examples/stdlib/matmul.bot      # Cranelift IR
tclsh tests/native-coverage.tcl                           # whole suite on cranelift, classified
tclsh bench/corpus.tcl                                    # corpus timings, all backends
```

```tcl
source native/native.tcl        ;# loads compiler, hir and core too
core::useBackend cranelift      ;# core::evalProgram now runs natively
native::evalHir $hir            ;# or run a program-mode HIR directly
```

### Pipeline

```
HIR ──native::lower (Tcl)──▶ NIR text ──botlish-native (Rust)──▶ Cranelift IR ──▶ machine code
 │                            ▲
 └──hir::aot facts────────────┘
```

* **Native lowering** (`native/lower.tcl`) turns HIR into NIR. It does no
  semantic analysis of its own. Guards come from `hir::aot`'s
  representation blockers and known-error facts, self tail calls from
  `hir::aot::selfTailCalls` (shared with the Tcl compiler), init checks
  from `hir::aot::unprovenReferences`, and environment-free functions from
  `hir::aot`'s static blocks. Lowering cross-checks the guards against HIR
  types and reports a mismatch as a backend bug.
* **NIR** is register-based and representation-level: constants, moves,
  `guard KIND`, `op OP` (a known operation on operands of the kinds it
  requires), `call` / `callenv` / `callvalue`, `tail`, cells and closures,
  branches, `ret` and `raise`. It has no names to resolve, no types and no
  traits. The format is documented at the top of `native/lower.tcl`.
* **The driver** `botlish-native` (`native/src/main.rs`) parses and
  validates NIR (`nir.rs`), translates it with the `Backend` interface
  (`codegen/`, whose only implementation is Cranelift), JIT-compiles and
  runs it against the runtime (`runtime/`). The Tcl backend runs one driver
  process per program: the NIR goes in as a file, and the value comes back
  in the host's runtime value representation (core/value.tcl), or the error
  with its error code.
* The same translation also writes object files
  (`botlish-native object OUT FILE.nir`). That is a smoke test only:
  running one would also need the runtime as a static library and an
  initializer for the constant table.

### Values

A `Value` is one 64-bit word (`runtime/value.rs`):

| Low bits | Meaning |
|---|---|
| `…1` | small Int `n` as `(n << 1) \| 1`, for `-2^62 <= n < 2^62` |
| `0010`, `0110`, `1010` | `false`, `true`, `unit` |
| `1110` | an unbound cell (never a program value) |
| `…000` | pointer to a heap object, whose header byte is its kind: big Int, Str, List, Result, Block (closure), native, cell |
| `0` | no value: an error is pending |

Kind knowledge and machine representation stay separate. A guard proves a
*kind* (`guard int`) and keeps the tagged word. The Int operations then take
an inline path for two small Ints and call a runtime helper otherwise.
Unboxing proven Ints to bare `i64` is left for a later milestone.

**Ints** are canonical: a value in the small range is always small, so two
Ints are equal iff their words are equal or both are big and numerically
equal. `+`, `-` and `*` run inline on tagged words and detect leaving the
small range with Cranelift's overflow-checking instructions; on overflow or
a big operand, they call `rt_int_add` / `rt_int_sub` / `rt_int_mul`, which
use `num-bigint` and normalize the result. Comparisons are inline for small
Ints and use `rt_int_cmp` otherwise. `num-bigint` is an implementation
detail: nothing about it is visible to programs.

**Strings** are UTF-8 with a cached character count and an ASCII flag.
`length` and `substring` count Unicode scalar values: ASCII strings are
indexed in O(1), others by walking the characters. This matches Tcl 9. On
Tcl 8.6, characters outside the BMP are not representable anyway (§18), so
the corpus tests only use BMP characters. `lowercase` uses simple one-to-one
case mapping, like Tcl's `string tolower`, and keeps a character whose
lowercase form is several characters.

**Lists** are immutable vectors of values. `list_append` copies, as the
reference runtime does, so CSV's quadratic behavior is kept deliberately
(§18).

### Functions, calls and closures

```
botlish_fn_F(vm, a0..an) -> Value              environment-free F
botlish_fn_F(vm, closure, a0..an) -> Value     F with an environment
botlish_entry_F(vm, closure, args*) -> Value   generic entry: the code of F's Block values
```

All words are `i64`, with the platform's C calling convention. A result of
0 means an error is pending: every call site branches to its function's
error exit, which pops the shadow frame and returns 0, so no generated code
runs after a failed guard or helper.

* **Direct calls.** A call whose HIR target is a Botlish function is
  `call botlish_fn_F`, with no lookup and no arity check (HIR checked the
  arity; a mismatch raises `ARITY` in place). A call with no known target
  is `rt_call_value`, which dispatches on the callee's kind: a closure
  (arity check, then its generic entry), a native (arity check, parameter
  kind checks, the operation), or `NOT-CALLABLE`.
* **Known natives** become an `op` after their guards. Arithmetic,
  comparisons, kind tests, cells and captures are inline. String, list,
  Result and structural equality operations call one runtime helper each,
  never a dispatcher. Native identity maps to an implementation in
  `native::lower::natives`; everything else (arity, parameter kinds) comes
  from the native registry.
* **Environment-free functions** are `hir::aot`'s static blocks, minus
  those that capture a cell. They take no closure argument. Their Block
  value is one constant closure, loaded from the constant table.
* **Closures.** A Block value is `{code, function id, arity, captures}`.
  Captures are values, except for bindings that some reference can't be
  proven bound when it runs (a forward reference, as in mutual recursion).
  Those are *cells*: allocated when their scope is entered, set by the bind,
  and read with an `UNBOUND` check where the reference is unproven. A
  closure reads its own function binding through `self`.
* **Self tail calls** (`hir::aot::selfTailCalls`, the Tcl compiler's
  criterion) rebind the parameter variables and jump back to the body block
  after the prologue: a CFG back edge. In the CLIF, the body block is a loop
  header with the parameters as block parameters, and the function never
  calls itself. Other calls, including tail calls to other functions, are
  real calls.
* **Branches and loops** are ordinary CFG blocks. `if` values, `break`
  values, `continue` and `return` from inside loops are jumps and moves.

### Runtime helpers, errors and memory

The helper ABI is listed with its failure and allocation behavior at the top
of `native/src/runtime/ops.rs`. Every helper takes the VM pointer and 64-bit
words. Operands already have the kinds the operation requires. A helper that
fails records a structured `RtError` (the offending values stay GC roots)
and returns 0. The error is formatted only at the program boundary, as the
reference runtime's error code (`CORE SEMANTIC TYPE`, `RANGE`, `ARITY`,
`NOT-BOOLEAN`, `NOT-CALLABLE`, `EQUALITY`, `UNBOUND`, `DUPLICATE`) and its
exact message. The native backend's own failures are `NATIVE UNSUPPORTED`,
`NATIVE INVALID-NIR`, `NATIVE CODEGEN`, `NATIVE BUG` and
`NATIVE LIMIT STACK`. Unbounded recursion ends in `NATIVE LIMIT STACK`,
not a crash. The Tcl backends raise Tcl's recursion limit instead, which is
a resource limit, not semantics.

Memory management is temporary: a precise, non-moving mark-and-sweep
collector (`runtime/heap.rs`). Every native frame reserves one shadow-stack
slot per NIR register, clears them in its prologue, and stores every
register definition to its slot. The collector scans those slots, the
pending error's values and a small list of runtime roots. Register values
stay in Cranelift variables, and objects never move, so reads never touch
the shadow stack. A collection runs inside an allocation, when twice the
live bytes after the last collection have been allocated (at least 32 MB).
`BOTLISH_NATIVE_GC_STRESS=1` collects before every allocation, and the
corpus tests pass that way. Between benchmark runs, the whole heap is
reclaimed. Nothing about ownership reaches HIR or NIR. Cranelift's stack
maps would let a later collector drop the shadow stack.

### Diagnostics

A construct native lowering does not support raises
`{NATIVE UNSUPPORTED WHAT}` with the source location, the HIR node and the
operation, e.g.
`t.bot:2:5: e5: native lowering does not support native test_log: ...`.
Invalid NIR is rejected by the driver's validator before code generation.
A Cranelift verifier or code generation failure is `NATIVE CODEGEN`, and a
panic is `NATIVE BUG`.

**Supported:** program-mode HIR with every expression kind (`const`, `ref`,
`bind`, `block`, `call`, `if`, `loop`, `return`, `break`, `continue`, `ok`,
`error`), closures with captured values and cells, mutual recursion, run-time
`UNBOUND` and `DUPLICATE`, calls chosen at run time, natives as values, and
the builtin natives `+ - * < <= > >= == eq list length substring lowercase
concat list_length list_get list_append integer? string? list? ok? error?
result-value result-error`.

**Not supported** (each reported as `NATIVE UNSUPPORTED`):

* natives implemented only in Tcl: the `web` and regex libraries and the
  test suite's instrumentation natives (`test-log`, `test-tick`, …)
* named types and evidence (`Emailish?`, refined parameter types)
* sequence mode (`core::evalIn` in an existing Tcl environment)
* handing a Block value back to the host, and so refinement probes through
  `core::blockEnv`

### Coverage

`tests/native-coverage.tcl` runs the whole suite with
`CORE_BACKEND=cranelift` and puts every test in exactly one class:

| Class | Tests | Of the 757 tests that predate the backend | Meaning |
|---|---:|---:|---|
| native | 205 | 171 | passed, ran native code |
| independent | 544 | 541 | passed without running a program on the backend (frontend, HIR, analysis) |
| passed-partial | 3 | 0 | passed; checks an unsupported-construct diagnostic on purpose |
| unsupported | 45 | 45 | needs a construct listed above |
| failed | 0 | 0 | anything else |

The 45 unsupported tests need: a Block returned to the host (12), sequence
mode (7), `test-log`/`test_log` (8), `test-tick`/`test_tick` (6), `web`
library natives and evidence (9), and the test natives `test-fake-escape`,
`test-lax-param` and `test-both-ints?` (3).
`tests/native.test` (40 tests) checks lowering and CLIF structure, and
three-way parity on arithmetic at the small/big boundaries, guards, every
error class, strings, lists, Results, calls, closures, the stack limit, the
collector and object emission. `tests/stdlib.test` runs every corpus case on
all three backends.

### Corpus

`tclsh bench/corpus.tcl -runs 3 -markdown` (Tcl 8.6.17, Windows, x86-64;
best of 3, wall time). Cranelift's compile time is separate: native
lowering in Tcl + Cranelift code generation and JIT linking.

| algorithm | input | interp | compile | cranelift | cranelift compile (lower + jit) | compile / cranelift |
|---|---|---:|---:|---:|---:|---:|
| string_reverse | 100 chars | 37.4 ms | 1.6 ms | 0.019 ms | 4.1 + 2.7 ms | 83x |
| string_reverse | 1,000 chars | 301.0 ms | 12.6 ms | 0.431 ms | 4.2 + 3.0 ms | 29x |
| string_reverse | 10,000 chars | 3042.2 ms | 129.1 ms | 21.5 ms | 4.2 + 2.7 ms | 6.0x |
| string_replace | 1 KB | 609.4 ms | 16.9 ms | 0.124 ms | 7.3 + 4.4 ms | 136x |
| string_replace | 10 KB | 5935.9 ms | 161.3 ms | 3.6 ms | 6.4 + 6.3 ms | 45x |
| string_replace | 100 KB | skipped | 1610.2 ms | 83.4 ms | 8.0 + 4.7 ms | 19x |
| csv | 100 rows | 2172.1 ms | 55.2 ms | 1.0 ms | 8.4 + 6.7 ms | 55x |
| csv | 1,000 rows | 23087.2 ms | 899.0 ms | 12.4 ms | 10.1 + 7.0 ms | 72x |
| csv | 10,000 rows | skipped | 36384.2 ms | 237.6 ms | 21.0 + 7.0 ms | 153x |
| matmul | 2x3 * 3x2 | 15.1 ms | 0.968 ms | 0.002 ms | 7.0 + 5.7 ms | 484x |
| matmul | 8x8 | 223.3 ms | 9.3 ms | 0.019 ms | 13.5 + 10.6 ms | 488x |
| matmul | 16x16 | 1645.0 ms | 63.4 ms | 0.108 ms | 34.1 + 26.3 ms | 587x |
| matmul | 32x32 | skipped | 493.3 ms | 0.906 ms | 138.8 + 117.7 ms | 544x |

All three backends produced the same value in every case.

The corpus stays guarded, as `hir::aot` reports: every guard in the NIR is
one of its representation blockers (reverse 4, replace 12, CSV 17,
matmul 17), no call goes through `rt_call_value`, and every corpus function
is environment-free. Where the time goes:

* **reverse** and **replace** at large sizes are dominated by copying the
  accumulator string on every `concat`: O(n²) bytes, most of them garbage
  at once. Collection frequency matters more than the copying itself: with
  a 32 MB minimum collection threshold, `string_replace` at 100 KB took
  146 ms, because new copies kept landing in cold memory; with 1 MB it takes
  about 80 ms (see `native/src/runtime/heap.rs`). A nursery or reference counting would do
  better. The helpers derive a result's character count and ASCII flag from
  the operands instead of rescanning.
* **CSV** spends its time in `list_append` copies (quadratic in records)
  and in allocating the two-element `[field, index]` lists.
* **matmul** runs mostly inline: small-Int fast paths for `*` and `+`, and
  a `list_get` helper call with a range check per entry.
* Compile time is dominated by native lowering in Tcl for programs with
  large literals (the benchmark's matrices are source literals), and by
  Cranelift for the rest.

### Next milestone: specialization and closed native AOT

The remaining blockers are the ones §19 lists: `UnknownParameterKind` (44 of
50) and `UnknownAggregateElementType` (6). Recommendations, in order:

1. **Call-site specialization** of parameter kinds in a closed program:
   compile `f<Str, Int, Str>` next to the generic `f(Any, Any, Any)`, keeping
   the semantic function unchanged. Every corpus function is called from
   known sites with kinds `hir::aot` can already see at the caller.
2. **Result propagation**, so a specialized callee's result kind reaches its
   caller (`reverse_from`'s accumulator, `dot`'s `total`).
3. **Unboxing** of Ints proven small (range analysis for indices and
   counters), then **redundant guard elimination** for guards on values
   HIR narrowed later on the same path (e.g. `index` in `substring(text,
   index, index + 1)`).
4. **List element kinds**, then **transient builders** for `list_append`
   and string accumulation where the old value is provably dead (escape
   analysis), and **scalar replacement** of the `[field, index]` pairs.
5. Replace the shadow stack with Cranelift stack maps, and make the object
   path runnable (runtime as a static library, constant-table initializer)
   for real closed AOT.

The corpus programs should stay unchanged throughout. `hir::aot` and
`bench/corpus.tcl` measure the progress.
