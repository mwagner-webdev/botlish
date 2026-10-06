# Core evaluator — executable semantic specification

A small reference evaluator, written in Tcl, for the semantic core of a new
language. It is a specification you can run, not a production runtime: it
aims for clarity over speed.

Tcl is only the implementation language. The semantics described here are
the language's own. Where Tcl behaves differently (truthiness, strings as
values, exceptions, variable scope, command lookup), the evaluator does
**not** inherit Tcl's behavior.

**Requires Tcl 9.x** (`core/core.tcl` checks this at load time and fails
clearly under Tcl 8.x rather than running with subtly wrong semantics).
Botlish's String semantics count Unicode scalar values, matching the other
backends (Rust/Cranelift); Tcl 9 represents strings the same way. Tcl 8.x
represents a character outside the Basic Multilingual Plane as a surrogate
pair, so `str::length` would disagree with every other backend by counting such
characters twice -- a host limitation, not a Botlish semantics change, so
it is not worked around here.

There are three backends that implement the same semantics:

* **`interp`**: the tree-walking reference interpreter (`core/evaluator.tcl`).
* **`compile`**: a compiler from IR to Tcl procedures (`compiler/compiler.tcl`,
  see §12).
* **`cranelift`**: a native code backend. HIR is lowered to a small native IR
  and compiled to machine code with Cranelift (`native/`, see §20). It
  compiles specialized instances of functions whose argument kinds are known
  at their call sites (§21). **`cranelift-generic`** is the same backend
  without specialization: the guarded baseline.

The whole test suite runs against `interp` and `compile`. The algorithm
corpus and the native tests run on all of them, and
`tests/native-coverage.tcl` classifies every test of the suite on
`cranelift` (through a test-harness backend that hands each test program's
HIR to `native::evalHir`; `native/` itself registers no core IR backend).

Three representations, three roles:

* **HIR** (`hir/`, §16) is the authoritative semantic program representation:
  core IR's meaning with every name resolved to a binding identity, every
  expression typed, and scopes, captures, refinements, call targets and
  module identity made explicit. Every analysis fact lives here.
* **Core IR** (`core/`, §2) is the small executable representation of the
  Tcl reference interpreter (and the Tcl compiler's input): HIR lowers to it.
  It is not on the native path.
* **NIR** (`native/`, §20) is the production executable representation:
  HIR lowers directly to it, and native code (JIT, object files, standalone
  executables) and, later, a bytecode interpreter are built from it.

The compiler compiles from HIR; the interpreter runs the core IR that HIR
lowers to; native lowers HIR straight to NIR, and never through core IR.

A small source language (`surface/`, §17) parses Botlish source
into a surface AST and builds HIR from it.

```
source ──surface::parse──▶ AST ──surface::lowerToHir──┐
                                                      ▼
core IR text ─────────hir::build────────────────────▶ HIR ──hir::lower──▶ core IR ──▶ interpreter
                                                       │
                                                       ├──────────────────────────▶ Tcl compiler
                                                       │
                                                       └──native::lowered──▶ NIR ──▶ Cranelift ──▶ machine code
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
tclsh9.0 tests/all.tcl                         # test suite, interp and compile
cargo build --release --manifest-path native/Cargo.toml   # build the native backend (§20)
tclsh9.0 tests/native-coverage.tcl             # test suite on cranelift, classified (§20)
tclsh9.0 main.tcl -backend cranelift FILE.bot  # run natively
tclsh9.0 main.tcl -emit-native-executable FILE.bot  # compile to ./FILE (Linux x86_64 glibc)
tclsh9.0 main.tcl -emit-nir -emit-clif FILE.bot   # show NIR, then Cranelift IR, of every function
CORE_BACKEND=compile tclsh9.0 tests/all.tcl    # test suite, one backend
tclsh9.0 main.tcl                              # run all examples (interp)
tclsh9.0 main.tcl -backend compile -code FILE.ir   # compile, show generated Tcl, run
tclsh9.0 main.tcl -hir FILE.ir                 # show the program's HIR, run
tclsh9.0 main.tcl -backend compile FILE.hir    # read HIR text, compile it, run
tclsh9.0 main.tcl examples/surface/03-closure.bot            # run source (interp)
tclsh9.0 main.tcl -backend compile -hir -ast FILE.bot   # show AST and HIR, compile, run
tclsh9.0 bench/bench.tcl                       # compare backends on bench/*.bot
tclsh9.0 bench/corpus.tcl                      # baseline timings of the algorithm corpus (§18)
tclsh9.0 main.tcl -warnings off FILE.bot       # compiler warnings: default | off | error (§23)
tclsh9.0 main.tcl -aot examples/stdlib/matmul.bot   # closed-AOT readiness report (§19)
tclsh9.0 main.tcl -aot-spec examples/stdlib/matmul.bot   # the same per specialized instance (§21)
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
| `struct` | `{a: 1, b: 2}` / `Name {a: 1}` | fixed named fields (STRUCTS.md): anonymous (structural) or declared by `struct Name:` (nominal) |
| `result` | `ok(v)` / `error(v)` | an application-level outcome                   |
| `block`  | `<block (x y)>`  | a closure: parameters, body, captured environment  |
| `native` | `<native +>`     | a primitive callable, possibly with refinement metadata |

Kinds never blur: the integer `10`, the string `"10"`, and the string
`"true"` are all different values, and none of the strings is a Boolean.

**Equality (`==`)** compares structure. Values of different kinds are never
equal. Integers compare numerically, strings compare exact characters, lists
compare element by element, structs compare by shape (an anonymous struct's
field set, or one declaration) and then field by field, and Results compare tag and payload. Equality on
callables is not defined, because it would need identity semantics, which are
out of scope. Comparing callables makes the program invalid.

There is no separate string-equality operator: two Strings are compared
with `==`, which never converts a value of another kind to a String (the
historical `eq` native is gone; STDLIB-NAMESPACES.md).

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

### `(struct HEAD NAME EXPR ...)` / `(project EXPR NAME)`

`struct` builds a struct value (STRUCTS.md): every EXPR is evaluated in written
order, then the value is built, so no partially initialized struct is ever
observable. HEAD is `{}` for an anonymous struct (its identity is its field
set, never the order written) or `{ID FIELD ...}` for a named struct
(declaration identity and slot order). `project` reads one field of a struct
value; HIR proves statically that the receiver is a struct with that field, so
there is no dynamic lookup and no missing-field error.

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

Natives are of two kinds (STDLIB-NAMESPACES.md has the full inventory and
the rule):

* **Language primitives** live at the root, under plain names: the
  operators and their named Int siblings, the list constructor, the kind
  and tag tests, the generic structural `hash`, the process's `argv`.
* **Standard intrinsics** -- operations that belong to one value family --
  live in that family's flat namespace, registered under their qualified
  name (`list::at`, `str::concat`, `mutable_array::set`, ...): a *qualified
  root native*. Source spells them like module members; no module file
  defines them, no local binding can spell `::` (so they cannot be
  shadowed), and a module of the same namespace may define any *other*
  member (`lib/list.bot`'s `list::get`) but never one of the intrinsic's own
  name (`SURFACE MODULE DUPLICATE-NATIVE`; the entry program is in no
  namespace, so it is not held to this rule). Botlish has no overloading,
  so there is nothing for such a definition to coexist as. A source file
  names them only after `import list` (IMPORTS.md), and the import also makes
  the intrinsic a method candidate: `xs.at(1)` is `list::at(xs, 1)`
  (METHOD-SUGAR.md); the import injects no unqualified `at`.

Language primitives (root):

| Name | Signature | Refinement |
|------|-----------|------------|
| `+` `-` `*` | int, int → int | |
| `<` `<=` `>` `>=` | int, int → bool | |
| `mod` | int, int → int (Euclidean: `0 <= r < abs(b)`; `ARITHMETIC` for 0) | |
| `bit_and` `bit_or` `bit_xor` `shift_left` `shift_right` | int, int → int (BYTE-NIBBLE-BIT-ARITHMETIC.md) | |
| `==` | any, any → bool (value equality; the one equality operator, Strings included) | |
| `list` | any... → list (what a `[a, b]` literal calls) | |
| `integer?` | any → bool, type test of `int` | true: arg 0 : `int` |
| `string?` | any → bool, type test of `str` | true: arg 0 : `str` |
| `list?` | any → bool, type test of `list` | true: arg 0 : `list` |
| `mutarray?` | any → bool, type test of `mutarray` (MUTABLEARRAY-CONSTRUCTION-REFINEMENT.md); an argument already typed `MutableArray[T]` keeps that type (PARAMETERIZED-MUTABLEARRAY.md) | true: arg 0 : `mutarray` |
| `ok?` | any → bool, type test of `Result.ok` | true: arg 0 : `Result.ok` |
| `error?` | any → bool, type test of `Result.error` | true: arg 0 : `Result.error` |
| `result-value` | ok Result → its value (core IR only: `-` cannot be spelled in source) | |
| `result-error` | error Result → its payload (core IR only) | |
| `hash` | any → int, the structural hash `==` agrees with (core/hashing.tcl) | |
| `argv` | → `List[String]`, errors `InvalidArgumentEncoding`: the process argument vector including argument zero, each argument validated as UTF-8 by the call (ARGV.md) | |

Standard intrinsics (qualified root natives):

| Name | Signature |
|------|-----------|
| `list::length` | list → int |
| `list::at` | list, int → any, errors `IndexNotFound`: the element at `0 <= i < length`; any other Int index fails with `IndexNotFound` |
| `list::append` | list, any → list (a new list; the argument is unchanged) |
| `str::length` | str → int (Unicode scalar values) |
| `str::substring` | str, int, int → str, errors `LowerUnderrun` `UpperOverrun`: the characters `start <= i < end` of a valid slice (below) |
| `str::lowercase` | str → str (Unicode 16 simple one-to-one case mapping; see §"Strings") |
| `str::concat` | str, str → str |
| `str::encode_utf8` | str → `List[Byte]` (the UTF-8 bytes) |
| `str::is_tcl_alpha` `str::is_tcl_alnum` | one-scalar str → bool (temporary Tcl-compatibility classes, core/tclcompat.tcl) |
| `char::scalar_value` | UnicodeChar → int (the Unicode scalar value: `0..0x10FFFF` without the surrogates, never a byte or a code unit of an encoding) |
| `mutable_array::allocate` | int → mutarray (every slot `unit`) |
| `mutable_array::capacity` | mutarray → int |
| `mutable_array::at` | mutarray, int → any, errors `IndexNotFound` (as `list::at`) |
| `mutable_array::set` | mutarray, int, any → unit, errors `IndexNotFound`: stores in place at `0 <= i < capacity`; any other Int index fails with `IndexNotFound` |
| `mutable_array::copy` | mutarray (DST), int (DS), mutarray (SRC), int (SS), int (COUNT) → unit, errors `LowerUnderrun` `UpperOverrun`: memmove semantics; checks the slice `DS..DS+COUNT` of DST, then `SS..SS+COUNT` of SRC |
| `mutable_array::freeze` | mutarray, int → list, errors `LowerUnderrun` `UpperOverrun`: a copy of the first N slots (the slice `0..N`) |
| `immutable_set::from_list` | `List[T]` → `ImmutableSet[T]` |
| `immutable_set::contains` | `ImmutableSet`, any → bool |
| `byte_store::from_list` | `List[Byte]` → byte storage: the eagerly copied, owned storage behind `abi::bytes::Bytes` (no source type spells it; ABI-BYTES.md) |
| `byte_store::byte_count` | byte storage → int: its exact length |
| `abi::x86_64::from_bytes` | `abi::bytes::Bytes` → `abi::x86_64::Register64`: the machine address of the payload, for the raw layer; native backend only (Tcl backends: `NATIVE-ONLY`); callable only directly (ABI-BYTES.md) |
| `mutable_byte_store::zeroed` `from_storage` `count` `replace` `detach` `freeze` `freeze_prefix` | the writable byte storage behind `abi::bytes::MutableBytes`, a value kind of its own: zero-filled allocation, an independent copy of a byte storage, the fixed count, an update that returns a **fresh** storage (the operand is never written), the detach copy, and immutable snapshots; none is context-free (MUTABLE-BYTES.md) |
| `abi::x86_64::from_mutable_bytes` | `abi::bytes::MutableBytes` → `abi::x86_64::Register64`: the machine address of a **writable** payload, for the raw layer; never mixed with `from_bytes`; native backend only; callable only directly (MUTABLE-BYTES.md) |
| `linux::abi::syscall` | `{rax: R, rdi: R, …, r9: R}` → `abi::x86_64::Register64` (R a Register64): the raw Linux x86-64 kernel transition, raw rax back; omitted argument registers are zero; native backend only (Tcl backends: `NATIVE-ONLY`); callable only directly (LINUX-X86-64-SYSCALL.md) |

Ordinary Botlish members of the same namespaces (library modules, not
natives): `list::get`, `list::any?`, `list::all?`, `list::none?`,
`list::find` (`lib/list.bot`); `mutable_array::from_list`,
`mutable_array::create`, `mutable_array::get` (`lib/mutable_array.bot`).
`char` has no library module: `char::scalar_value` is its one member (a
"code point" also names surrogates and, colloquially, Latin-1 or other
encodings' numbers; a scalar value is exactly what a UnicodeChar holds).
Like every native's parameter types, its `UnicodeChar` requirement is
checked at run time (`char::scalar_value(65)` is the `TYPE` error).

**Indexed access: `at` and `get`.** `at(container, index)` is required
indexed lookup: it returns the element or fails with the builtin declared
error `IndexNotFound` -- an ordinary, handleable error completion
(`on IndexNotFound:`), so a call must handle it, admit it in the enclosing
function's `errors` clause, or be proven not to need to: the call-specific
completion proof (hir/completions.tcl) rules it out when the index provably
designates an element (a List of statically known length with an index in
range; `loop i from 0 to list::length(xs): list::at(xs, i)` and its
MutableArray capacity counterpart; a read guarded by `if i < 0 or i >=
list::length(xs):` or its `and` form; STDLIB-NAMESPACES.md lists the
rules), and makes a provably-missing index a compile-time `KNOWN-ERROR`.
The proof removes the obligation only: a proven call still runs its bounds
check, and `get` does not benefit yet (STDLIB-NAMESPACES.md §12 records the
intended static model and the plan). `get(container, index, default)` is lookup with
an explicit fallback, written in ordinary Botlish over `at`:

```
fn get(xs, index, default):
    value = list::at(xs, index):
        on IndexNotFound:
            default
    value
```

It handles `IndexNotFound` and nothing else (a non-List or non-Int argument
is still the `TYPE` error), `default` is an ordinary eagerly evaluated
argument, and neither operation returns an optional or null value. There is
no negative indexing: `-1` is a missing index like any other.
`mutable_array::set` is the write counterpart of `at`: it stores at a
designated slot or fails with the same `IndexNotFound`, proven the same way.

**Slices.** `str::substring(s, start, end)`, `mutable_array::freeze(a, n)`
(the slice `0..n`) and `mutable_array::copy` (its destination slice, then
its source slice) take a half-open slice `START..END` of a sequence of `N`
elements, valid iff `0 <= START <= END <= N`. START is checked first,
against `0..N`, then END against `START..N`: a bound below its interval
fails with the builtin declared error `LowerUnderrun`, one above it with
`UpperOverrun` (so an inverted slice, `END < START`, is `LowerUnderrun`, and
`substring("abc", 4, 1)` is `UpperOverrun` for its start). Like
`IndexNotFound` they must be handled, admitted by an `errors` clause or
proven impossible: the completion proof also reads String lengths (a
literal, `str::concat`'s sum, a guard such as `if str::length(s) > 0:` or
`if i < 0 or i >= str::length(s): return ...`) and array capacities.

Optional library `web` (`# requires: web`, lib/web.tcl):

| Name | Signature | Refinement |
|------|-----------|------------|
| `Emailish?` | str → bool, type test of `Emailish` | true: arg 0 : `Emailish` |
| `UriQueryValue?` | str → bool, type test of `UriQueryValue` | true: arg 0 : `UriQueryValue` |
| `uriEscape` | str → `UriQueryValue` | |

New natives are registered through the registry, not by changing the
evaluator:

```tcl
core::registerNative even? -arity 1 -impl myEvenImpl -refines-true {0 Even}
```

`-refines-true` and `-refines-false` take `ARG-INDEX TYPE` pairs.

`-runtime {TAG…}` states what a native implementation of the operation
needs from a runtime beyond bare machine operations: `bigint`,
`string-alloc`, `list-alloc`, `result-alloc`, `char-index`, `range-check`,
`structural-equality`, `evidence`, `process-argv`, `raw-syscall`
(`core/native.tcl` defines each). It is metadata for static analysis (§19) and never changes what a call
does.

`-errors {NAME…}` declares the builtin errors (`core::native::declareError`)
a call of the native may complete with: the impl signals one with
`core::native::failDeclared`, and `core::native::invoke` turns that into the
same `propagate-error` completion a Botlish `fail NAME` produces, so
`on NAME:` handlers, an `errors` clause, call analysis and every backend treat
it like any declared error. `argv` (`InvalidArgumentEncoding`), the indexed
intrinsics `list::at`, `mutable_array::at` and `mutable_array::set`
(`IndexNotFound`) and the slicing intrinsics `str::substring`,
`mutable_array::freeze` and `mutable_array::copy` (`LowerUnderrun`,
`UpperOverrun`) declare them; core/native.tcl declares the builtin errors in
their fixed index order. `-bounds` states the check behind such
argument-dependent errors (`index FAMILY CONTAINER INDEX`, or `slices
{FAMILY CONTAINER START END}...`), which the completion proof reads from
the registration rather than from the native's name.

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
`str::substring(UriQueryValue)` is a plain `str`, while `uriEscape(str)` is a
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
| `hir::specialize::analyze HIR ?-specialize 0\|1?` / `hir::specialize::explain HIR ?ANALYSIS?` | call-site specialization: function instances, their facts and blockers (§21) |
| `native::nir` / `native::evalHir` / `native::clif HIR ?-specialize 0\|1?` | native IR / run natively / Cranelift IR (§20) |
| `native::report HIR` / `native::codeSize HIR` | guard accounting and instance counts / machine code size (§21) |
| `hir::types::*` | static types: core types plus `{native N}`, `{block E A R}`, `never`, and the list aggregate facts `{list ELEM ?SHAPE?}` (§13, §21) |
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
| `core::process::withArgv ARGV SCRIPT` | run SCRIPT with the raw byte-string list ARGV as the process argument snapshot `argv()` reads (all four in-process backends; ARGV.md) |
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
| `core/process.tcl` | the process boundary: `argv()`, its builtin error, argv injection (ARGV.md) |
| `core/linuxabi.tcl` | `linux::abi::syscall`, the raw Linux x86-64 kernel transition (native only; LINUX-X86-64-SYSCALL.md) |
| `core/contexts.tcl` | the two internal context operations `context#install` / `context#load` and the Tcl backends' per-run context environment (CONTEXTS.md) |
| `core/bytestore.tcl` | the byte-storage value kinds' natives (immutable `bytestore`, writable `mutbytes`) and the raw address bridges `abi::x86_64::from_bytes` / `from_mutable_bytes` (ABI-BYTES.md, MUTABLE-BYTES.md) |
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
| `hir/specialize.tcl` | call-site specialization: instances, result fixpoint, views for `hir::aot` (§21) |
| `hir/exactvalue.tcl` | exact-value facts and value identity (`hir::exact::Of`, `Identity`, `SameValue`) |
| `hir/warnings.tcl` | compiler warnings: record, static registry, global policy, rendering, error promotion, `SAME-RETURN-VALUE` and `METHOD-ELIGIBLE` (§23) |
| `hir/contexts.tcl` | execution-environment contexts: context parameters, direct and transitive requirements, installation order, `MISSING-CONTEXT` chains, function-value frontier (CONTEXTS.md) |
| `hir/syscall.tcl` | the static contract of `linux::abi::syscall`'s register-struct argument (LINUX-X86-64-SYSCALL.md) and of `abi::x86_64::from_bytes`'s `abi::bytes::Bytes` argument (ABI-BYTES.md) |
| `compiler/compiler.tcl` | HIR → Tcl compiler backend |
| `native/lower.tcl` | HIR → NIR native lowering (§20) |
| `native/native.tcl` | the native entry points, all taking HIR: `native::lowered` (the one HIR → NIR entry), `evalHir` (JIT), NIR, CLIF, object, executable, code size and guard report; runs the native driver |
| `native/prepare.tcl` | `native::prepareHir`: attaches the native implementations a program calls (module functions, validator bodies) to its HIR |
| `native/src/nir.rs` | NIR parsing and validation |
| `native/src/runtime/` | native `Value` representation, heap and collector, errors, runtime helper ABI; `syscall.rs` holds the one inline-asm `syscall` boundary (LINUX-X86-64-SYSCALL.md); `bytesobj.rs` the owned byte-storage object, immutable and writable kinds (ABI-BYTES.md, MUTABLE-BYTES.md) |
| `lib/abi.bot` | the ABI numeric domains `abi::I8` ... `abi::Usize` (ordinary Int values with a proven foreign-interface domain `abi::I8Value` ... `abi::UsizeValue`, not fixed-width arithmetic), their checked creators `abi::i8` ... `abi::usize` and errors `AbiIntegerBelowRange`/`AbiIntegerAboveRange` (ABI-NUMERIC-DOMAINS.md) |
| `lib/abi/bytes.bot` | the ABI memory values, both owned by this one module (the single-owner rule of OPAQUE-STRUCTS.md, so they convert into each other without a public accessor): `abi::bytes::Bytes`, immutable, opaque over contiguous byte storage (`from_list`, `length`; ABI-BYTES.md), and `abi::bytes::MutableBytes`, its writable counterpart, a *value* whose copies are independent (`zeroed`, `from_bytes`, `mutable_length`, `replace`, `detach`, `freeze`, `freeze_prefix`; MUTABLE-BYTES.md) |
| `hir/imports.tcl` | the import environments of a compilation: which namespaces and short type names each file's header imported (IMPORTS.md) |
| `lib/linux.bot` | `linux::write(fd, data)`: one `write(2)` syscall over an `abi::bytes::Bytes`, the kernel's raw signed result as an Int (ABI-BYTES.md); `linux::read(fd, data)`: one `read(2)` into the caller's `abi::bytes::MutableBytes` (copied: the caller's value is never changed), returning a `linux::ReadResult` of the raw `ssize_t` and the updated buffer (MUTABLE-BYTES.md) |
| `lib/linux/io.bot` | `linux::io::LinuxIO`, the process's standard I/O as one opaque context over three opaque `FileDescriptor` tokens; `create()`, and the contextual `write`, `write_error`, `read` over `linux::write` / `linux::read` (CONTEXTS.md) |
| `lib/abi/x86_64.bot` | `abi::x86_64::Register64`, the x86-64 register word as a transport value, and its two Int conversions (LINUX-X86-64-SYSCALL.md); `from_i8` ... `from_usize` encode ABI numeric values as register words, sign- or zero-extended (ABI-NUMERIC-DOMAINS.md) |
| `native/src/codegen/` | the `Backend` interface; NIR → Cranelift IR for JIT and object files |
| `surface/lexer.tcl` | source → tokens, indentation → `INDENT`/`DEDENT` |
| `surface/parser.tcl` | tokens → surface AST (recursive descent) |
| `surface/ast.tcl` | spans, syntax errors, AST formatting |
| `surface/lower.tcl` | surface AST → HIR |
| `surface/surface.tcl` | loader and `surface::compile` / `readProgramFile` |
| `bench/` | benchmark programs and runners (`bench.tcl` for the canonical `*.bot` corpus, `corpus.tcl` for §18) |
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

Surface syntax beyond the minimal language of §17, macros, objects (structs,
STRUCTS.md, are immutable values: no mutable struct, update syntax, methods or
inheritance), assignment, mutable
variables, exceptions, `?` propagation, pattern matching, a type checker
beyond refinement tracking (struct destructuring, STRUCT-DESTRUCTURING.md, is
irrefutable named projection, not pattern matching), async, coroutines, threads, or FFI. A small
one-file/one-namespace module system *is* implemented (§17's
`mod::name` syntax, `surface/modules.tcl`, NATIVE-MODULES.md, and
MODULE-BINDINGS.md), and a source file's cross-namespace dependencies are
declared by exact `import`s (IMPORTS.md). Modules may retain ordinary
immutable bindings whose initializers are context-free; there are no mutable
module bindings, import aliases/wildcards/re-exports, search paths, or
package management.

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

**Declared errors** (`fail NAME`, EXPLICIT-ERROR-COMPLETIONS.md) travel
through compiled code as Tcl completion code 5, out of a direct call of a
compiled block and -- since STRUCTURAL-FUNCTION-TYPES.md, where a callable
with a declared error set may be called through a structural function type
-- out of a generic call (`core::runtime::callValue`) alike.

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
| `{block EXPR ARITY RESULT {args {T…} errors {E…}}}` | hir | the same, for a block that declares parameter types or an error set (its contract) |
| `{fn {args {T…} return R errors {E…}}}` | hir | a *structural function type*: some callable (native or Block) whose calls accept arguments admissible for `T…`, return `R`, and let at most `E…` escape |
| `never` | hir | no value: evaluation does not complete normally |

**Exact and structural callables** (STRUCTURAL-FUNCTION-TYPES.md). An exact
callable type names the code a call runs (for a Block: its code target,
whatever environment the value carries -- two closures of one factory share
it). Each has one structural supertype, `hir::types::structuralOf`: a
block's declared parameter types (untyped: `any`), result type and
declared errors; a native's arity and `-result-type` (its arguments are
run-time checked, so its structural arguments are `any`; natives declare no
errors). Compatibility is the call contract's: arguments contravariant
(declared-parameter admissibility), return covariant, errors a subset. The
`lub` of two different compatible callables is their narrowest common
structural type (the meet of the arguments, the lub of the returns, the
union of the errors), not `any`; with no representable argument meet it
falls back to the shared kind or `any`. A call through a structural type
is typed from its contract, its arguments are checked against the
contract, and its declared errors reach static error checking; it still
lowers as an indirect call. Specialization keys erase both identity (to
the kind) and contract (to `any`).

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
* **Semantic function instances** (OPPORTUNISTIC-SEMANTIC-INSTANCES.md,
  `hir/semantic.tcl`): a call of an exact block whose argument types say more
  than the block's own entry types is typed with the result of analyzing the
  block's ordinary body under those types (`identity(m : MutableArray[str])` is
  `MutableArray[str]`, `first(List[int])` is `int`, `list::find(List[str], p)`
  is `str`), with no generic syntax and no change to the function's own
  contract. A body that is invalid for one call's types (an untyped writer of an
  `int` into a `MutableArray[str]`) makes that *call* a compile-time error, not
  the function. Semantic instances are analysis only: they emit nothing and
  never change a specialization key. A *definition* is still analyzed
  generically, so an untyped function that receives a typed `MutableArray` as a
  parameter and appends a value whose type it computes itself is rejected at
  its own definition; it needs a declared `MutableArray[T]` parameter
  (TYPED-MUTARRAY-BUILDER-REFACTOR.md, "Definition-level obstruction").

**Scope of facts.** A fact holds only on the path that proves it:

* Facts learned in a branch or loop body are dropped at its end.
* Facts learned in a sequence hold for the rest of that sequence.
* A closure inherits the facts known where it is created. Its captured
  bindings can't change afterwards.

**What types buy.**

* **Representations:** an operand is `box` (a runtime value), `int` (a bare
  integer) or `bool` (1/0). Unboxed values are boxed only when they escape
  into a frame, a call, a `return` or a `break`.
* **Intrinsics:** calls of `+ - * < <= > >= == list ok? error?` compile
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
`tclsh9.0 main.tcl -backend compile -code FILE.ir` shows the generated code.

**Performance** (`tclsh9.0 bench/bench.tcl`, best of 5, excluding compilation):

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
part of it:** `==` and ordinary display ignore it, so `"foo"` proven to
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
* Resolution is **sequential**: a scope starts with only its parameters, and
  a `bind` adds its binding when the walk reaches it (after resolving its
  value), so a reference denotes the binding of the innermost scope that has
  established its name *so far*. Failing that, it denotes a root binding
  (program mode) or an ambient binding (sequence mode). Otherwise it's
  unresolved (`UNBOUND`) and gets no binding at all. There is no whole-scope
  symbol table and no hoisting; a named function's `bind` (a block value)
  establishes its binding before its block is resolved, so the function can
  call itself and nothing else that is later. Every dependency between
  bindings of a scope therefore points backward in source order, plus a
  named function's self-edge (`hir::refcheck::forwardRefs` audits this).
  When a name is unbound but bound later in an enclosing scope, the message
  says so; that answer comes from a diagnostic-only index and never
  resolves anything. See STRICT-REFERENCE-DETERMINISM.md.
* `init` is `yes` for every reference, except an ambient one (`deferred`:
  the host environment's value when a closure runs). There is no "not bound
  yet" state.
* A `bind` of a name that's already bound in the same scope is marked
  `duplicate`. It still denotes the first binding, and raises `DUPLICATE`
  when evaluated, after its value.
* Core IR's scopes declare every name they bind on entry (§2), so lowered
  code is name-based where HIR is sequential: hygiene renames a later binding
  (`x#1`) that would capture an earlier reference to an outer binding of the
  same name. Raw core IR that relies on the interpreter's declare-on-entry
  scoping (forward closure references, use before binding) is interpreter-only:
  HIR-based backends treat such a reference as unbound.
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
* A reference to a later binding (including mutual recursion,
  `examples/surface/09-mutual-recursion.bot`) is unresolved (`UNBOUND`): there
  is no forward reference to type, check or repair. Mutual recursion needs a
  future explicit construct.
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
* **Bindings are visible from their definition onward.** A function or value
  may not refer to a later binding in the same lexical scope (`UNBOUND`, at
  the reference), in a module, a function body, a branch, a loop body or a
  handler alike; nothing is hoisted, and running order never makes a forward
  reference legal (an unused function, or an unreachable branch, may not
  contain one). A named function may call itself: `fn f` establishes `f`
  before its own body. A value is not visible in its own initializer, and
  there is no anonymous function expression to recurse through. A closure
  captures what exists where it is created, and a later binding of the same
  name in a nested scope never changes what an earlier reference meant.
  Mutually recursive definitions need a future explicit mechanism; ordinary
  bindings are not hoisted, so write callees before callers. See
  STRICT-REFERENCE-DETERMINISM.md.
* `if c:` / `elif c2:` … / `else:` (any number of `elif`s, optional `else`),
  `loop:`, `break [e]`, `continue`. **`elif` is equivalent to `else:` holding
  one nested `if`**, under the ordinary `if` semantics, and nothing more:

  ```
  if a:                       if a:
      one                         one
  elif b:                     else:
      two              ==         if b:
  else:                               two
      three                       else:
                                      three
  ```

  Conditions are evaluated in written order, each at most once, and none after
  the first true one; only the selected branch runs. A chain without a final
  `else` has the value (`unit`) a nested `if` without `else` has. An `if` chain
  is a value wherever an `if` is (the right side of `=`, the value of
  `return`), with the same branch typing, scopes and completions
  (`return`/`fail`/`break`/`continue` in any branch). An `elif` or `else`
  belongs to the open `if` at its own indentation. An `else` ends the chain
  (`elif` after `else` is a syntax error), `elif` without a preceding `if` is
  a syntax error, and `elif` is a reserved word like `else` (it can no longer
  name a binding or function). See ELIF.md.
* **Collecting loops.** A loop with an iteration clause evaluates to the List
  of its body's values (`continue` contributes nothing, a bare `break` ends it
  with the List so far, `return`/errors leave as usual). A clause is one of

  ```
  loop x in xs:                    # every element of a List
  loop i from a to b:              # a <= i <  b, ascending, b exclusive
  loop i from a through b:         # a <= i <= b, ascending, b inclusive
  loop i down from b to a:         # b >= i >  a, descending, a exclusive
  loop i down from b through a:    # b >= i >= a, descending, a inclusive
  ```

  `from`/`down from` give the direction, `to`/`through` the endpoint
  (`to` exclusive, `through` inclusive); a numeric loop whose bounds put
  nothing in the domain runs zero times (it never reverses direction by
  itself), and bounds are arbitrary-precision `Int`s evaluated once. The
  inclusive forms are not `b + 1` / `a - 1` sugar: no value outside the
  endpoints is ever formed. Clauses compose in **lockstep** with `and`:

  ```
  loop value in values and index from 0 to list::length(values):
      [value, index]
  ```

  `and` runs one body execution per common position, advancing every clause
  together (`continue` advances all of them, `break` leaves the loop). It is
  *not* a special enumeration feature and not `zip`: every clause must have a
  **statically provable equal iteration count**, otherwise the program is
  rejected at compile time (`LOCKSTEP-UNPROVEN`, or `LOCKSTEP-UNEQUAL` when
  the counts provably differ); there is no shortest-wins rule and no runtime
  length check. See COLLECTING-LOOPS.md. A bare `loop:` (no clause) is
  unchanged.
* An `if` can also be the value of a binding, `return` or `break`
  (`sign = if n < 0:` followed by its blocks). It can't be an operand or an
  argument.
* A parameter or result annotation may be a **structural function type**,
  `Fn{args: [T1, T2], return: R, errors: [E1, E2]}` (named fields, any
  order, newlines allowed inside the braces; `errors` may be omitted and
  then means `errors: []`, exactly like a `fn` without an `errors` clause).
  See STRUCTURAL-FUNCTION-TYPES.md.
* A **struct** is a fixed set of named fields (STRUCTS.md). `{x: 1, y: 2}` is
  an anonymous struct value (structural type, field order irrelevant, `{}`
  legal, trailing comma optional); `struct Point:` followed by indented
  `name: Type` lines declares a nominal type, and `Point {x: 1, y: 2}`
  constructs it (every declared field exactly once, statically type-checked,
  no defaults; `mod::Point {...}` for a module's). `value.field` is a total
  static projection; a receiver the compiler cannot prove is a struct with
  that field is rejected, never looked up at run time. Struct values are
  immutable.
* **Opaque structs.** `opaque struct Token:` declares an ordinary struct whose
  representation belongs to the module that declares it: only that module may
  construct it (`token::Token {...}`) or inspect it (`x.value`, `{value} = x`);
  everywhere else it is an ordinary value to pass, store, return, compare and
  hash, and the type is named as any struct's (`token::Token`). Authority is the
  declaring module exactly: no import, parent, child or holder grants it, an
  entry program owns its own opaque structs, and the checks are static
  (`OPAQUE-CONSTRUCTION`, `OPAQUE-REPRESENTATION`) with no runtime test. `opaque`
  is a contextual word, the compiler still sees the fields (a one-field wrapper
  scalar-replaces exactly as an ordinary one), and an opaque value prints as
  `<opaque token::Token>`. It is representation ownership, not OO privacy;
  `context` (below) composes with it as an independent modifier
  (`opaque context struct`), and a later `resource` will too.
  See OPAQUE-STRUCTS.md.
* **Method-call sugar.** `value.f(a, b)` is another spelling of the ordinary
  call `f(value, a, b)`, allowed exactly when `f` is a function visible by
  that name at the call (under ordinary lexical resolution: a function or
  binding of the file, a root native; or a member `f` of a namespace the file
  directly imports, `import list` -- IMPORTS.md; `mod::f` alone, without the
  import, never makes `f` visible) and the ordinary call is valid. When several
  distinct visible functions are candidates, each is tried as the ordinary call
  and exactly one must fit (`AMBIGUOUS-METHOD-CALL` otherwise; no precedence). It adds no declaration, receiver
  type, method table, overload rule or lookup by receiver type: the receiver
  is parameter 1 of the ordinary call, evaluated once in the first-argument
  position; every type, arity, error and handler rule is the free call's; and
  `x.f(a)` and `f(x, a)` resolve to the same HIR. `x.f` without a call is
  still the field projection, `(x.f)(a)` still calls a field value, and a
  call whose name is both a visible function and a possibly-callable field of
  the receiver's struct type is rejected as ambiguous
  (`AMBIGUOUS-METHOD-CALL`). See METHOD-SUGAR.md.
* **`nomethod fn`.** `nomethod fn atan2(y, x):` declares a function that is
  *never the callee of method syntax*. It is a modifier on the one
  declaration, accepted wherever `fn` is (top level, modules, nested
  functions), and a declaration-level fact about the function's interface
  decided by its author -- the author knows receiver syntax would read badly
  (`y.atan2(x)`). A `nomethod` function is called functionally exactly like
  any other: its type, completion, specialization and generated code are
  identical, and nothing about it is visible outside call-form legality. A
  method-style call that would resolve to it is the resolution error
  `NOMETHOD-CALL` (`` `atan2` is declared nomethod and cannot be called with
  method syntax; call it as atan2(receiver, ...) ``): method syntax skips a
  `nomethod` function as a candidate, so another visible function of the same
  name is still found, and only when every visible function of that name is
  `nomethod` is the call rejected. It follows the class of an unbound name: raised by resolution
  (before type inference) under `-strict 1`; kept in the HIR under `-strict 0`,
  where the call stays the call of a field value and fails at run time too.
  An alias (`g = atan2`) is the same function. The flag is carried by
  imports (a `nomethod` function of a module behaves identically) and by the
  builtin registry (`core::native::register -nomethod 1`); no shipped function
  is marked. `nomethod` is a contextual word (an ordinary name everywhere but
  before `fn`). It is not a suppression pragma: it changes what call forms are
  *legal*, not what the compiler *reports* about a call. See
  WARNINGS-METHOD-ELIGIBLE.md.
* **Flag parameters.** `fn open(path, flags :append, :cloexec):` declares a
  *flag section* after the ordinary parameters; `open("f", :append)` supplies
  a flag by naming it. A flag is an immutable `Bool` parameter with a fixed
  default of `false`, `true` exactly when its name is written at the call:
  there are no defaults, required, negated or computed flags, and `:name` is
  not a value (it only exists as a trailing call argument and in a flag
  declaration). Flags are a callable-interface category of their own, checked
  against the called function's declaration (`UNKNOWN-FLAG`,
  `DUPLICATE-FLAG`, ...), share the local namespace of the ordinary
  parameters, and work through method sugar (`path.open(:append)`) and
  aliases (`g = open`). A function with flags can only be called or aliased,
  not passed around as a value. `flags` is a contextual marker, not a reserved
  word. See FLAGS.md.
* **Contexts.** `context struct Clock:` (or `opaque context struct LinuxIO:`)
  declares a struct whose values may be installed into the current execution
  environment; `with context EXPR` installs EXPR's value -- its inferred type
  must be exactly one context struct -- from that statement on (entry program
  top level only, for now); and a function states a value of that
  environment it directly uses in a last parameter section, after the
  ordinary parameters and flags: `fn write(data, context io: LinuxIO):`.
  `io` is an ordinary local; the call is `write(data)` -- context parameters
  are not arguments and do not count in the arity. A context is identified by
  its type alone (at most one installed value per type; the local name means
  nothing outside the function). Only the function that uses a context
  declares it: the compiler derives every caller's transitive requirement
  from the call graph and proves, statement by statement, that each call at
  the top level runs after the installation of everything it needs
  (`MISSING-CONTEXT`, with the call chain that explains it), that no type is
  installed twice (`DUPLICATE-CONTEXT`) and that a function needing a context
  never becomes a value (`CONTEXT-FUNCTION-VALUE`). Natively a context lives in
  a statically assigned slot of the program's writable data, read with fixed
  PC-relative addressing where it is used: no hidden argument, no reserved
  register, no lookup. `context` and `with` are contextual words. The first
  context is `linux::io::LinuxIO` (lib/linux/io.bot): `with context
  linux::io::create()` then `linux::io::write(bytes)`. See CONTEXTS.md.
* **Struct destructuring.** `{user, expires: expiry} = result` binds fields
  of a struct value by name: it evaluates `result` once, then binds `user` to
  `result.user` and `expiry` to `result.expires`, exactly as the explicit
  `tmp = result`, `user = tmp.user`, `expiry = tmp.expires` would, and the
  statement itself evaluates to `unit` (not to the last binding it makes: those
  are implementation details). Struct destructuring binds fields by name. It creates ordinary value bindings; it
  does not create references into the source struct. Fields may be omitted or
  renamed (`{source_field: local_name}`: the left name is the field read, the
  right name the binding made; `{field}` is `{field: field}`), named and
  anonymous structs destructure alike, and a nested pattern
  (`{user: {name, id}, expires} = result`) destructures a field in turn.
  Every requested field must exist, statically, under the ordinary
  field-projection rules (the diagnostics are the projection's); selecting a
  field twice, or binding a name twice, is rejected. It is not pattern
  matching and not assignment: no defaults, wildcards, rest/spread, reference
  modes, or assignment to existing names, and it is only legal where an
  ordinary binding is (not at module top level, where no struct value is a
  legal module binding). **Lists are intentionally not destructured
  positionally** (`[a, b] = value` is the dedicated error
  `LIST-DESTRUCTURING`): APIs returning heterogeneous values should prefer
  struct values with named fields, and a List remains the type of a sequence.
  See STRUCT-DESTRUCTURING.md.
* Integers (decimal, arbitrary precision, no leading zeros), strings
  (`"..."`, escapes `\\ \" \n \r \t`), `true`, `false`, `unit`, lists
  `[a, b]`, calls `f(x)(y)`.
* Operators, from highest precedence: the postfix forms (call, `.field`,
  `.method(...)`, which chain left to right), unary `-`, `*`, `+ -`,
  `== != < <= > >=`, `not`, `and`, `or`. Arithmetic, `and` and `or` are
  left-associative. Comparisons don't chain (`a < b < c` is a syntax error).
* Blocks are delimited by indentation (spaces only; tabs are an error).
  Blank and comment lines (`#`) don't count. Newlines inside `( )` and `[ ]`
  are ignored. Trailing commas are allowed in parameters, arguments and lists.
* Names are `[A-Za-z_][A-Za-z0-9_]*`. `?` is reserved, so natives like
  `integer?` or `test-log` can't be named from source yet.

The full grammar is at the top of `surface/parser.tcl`.

### Modules

One source file is one namespace is one compilation/dependency unit. A
file loaded through `import NAME` is a *module*; its namespace is its
path (there is no `namespace` declaration, and the entry program is in no
namespace): a namespace of ordinary function definitions and immutable value
bindings. A value initializer executes once before the entry program, after
its dependency modules and after earlier values in the same source file. It
must be context-free and must retain a transitively immutable result; there
are no mutable module bindings or top-level expression statements. `NAME`
maps to exactly one file, `lib/NAME.bot` (`core::libraryDir`, the same
directory as the existing `lib/NAME.tcl` native-library convention) -- no
search path, so there is never more than one candidate file for a name. A
nested namespace `a::b` (used as `a::b::symbol`) is the file
`lib/a/b.bot`, one directory per leading segment; `a` and `a::b` are unrelated
modules (LINUX-X86-64-SYSCALL.md). A root native may itself carry a qualified
name (`linux::abi::syscall`): it is spelled like a module definition but
resolves to the root native, and no module may define that member.
Another file uses a module definition as `NAME::symbol`: an ordinary,
non-aliasable qualified reference, allowed only after an exact `import NAME`
in the file's header (IMPORTS.md: `import list`, `import abi::x86_64`,
`import type abi::U8Value` for one type's short name; imports are exact and
not transitive, and are the only thing that loads a module, at most once). `::` is
definition/provenance qualification, never confused with `.`'s (future)
value-access syntax. Resolution fixes a stable binding identity before
lowering; a module value does not use a runtime namespace lookup. See
NATIVE-MODULES.md, MODULE-BINDINGS.md, and `surface/modules.tcl` for the
implementation. Deliberately not built: namespace aliasing, import aliases
or wildcards, re-exports, a search path, or anything package-manager-shaped.

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
| `{a, b: c} = e` | `bind tmp e`, `bind a (project tmp a)`, `bind c (project tmp b)`, `^unit`: `tmp` is a hygienic temporary (its name contains `#`) and the final `unit` is the statement's own value; no HIR or later pass knows destructuring |
| `fn f(a): body` | `bind f (block {a} body…)` |
| `if c: t` / `else: e` | `if c {t…} {e…}`, inline branches; no `else` → empty branch (`unit`) |
| `if c: t` / `elif c2: t2` / `else: e` | `if c {t…} {if c2 {t2…} {e…}}`: an `elif` is an `if` alone in the previous clause's else branch; no HIR or later pass knows `elif` |
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
  There's no one-line form (`if c: a else: b`). A chain of conditions is
  written with `elif` (ELIF.md); a chain's length is bounded only by the
  nesting depth the passes can recurse to (a few hundred clauses at Tcl's
  default recursion limit, as for the same chain written as nested `if`s).
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
| `string_reverse.bot` | `reverse_chars(text)` | reverses the units `str::length`/`str::substring` count |
| `string_replace.bot` | `replace(haystack, needle, replacement)` | exact, left-to-right, non-overlapping replacement |
| `csv.bot` | `csv_parse(text)` | valid-input CSV → list of records of field strings |
| `matmul.bot` | `matmul(a, b)` | Int matrix product over nested lists |

Each file is a normal program: its functions followed by a sample
expression with a `# expect:` comment, so `tclsh9.0 main.tcl FILE` runs it.
`examples/stdlib/corpus.tcl` appends a driver expression to a program, and
runs the result on a backend. The interpreter runs the lowered IR, and the
compiler compiles from HIR, the same way as `examples/surface/`.

**Semantics chosen for the corpus**

* `reverse_chars` reverses characters as the runtime indexes them (Tcl 9
  string indices, i.e. Unicode scalar values). Those aren't grapheme
  clusters: a combining mark ends up before its base letter, and a
  supplementary-plane character (outside the Basic Multilingual Plane) is
  reversed as the single unit it is, not split into a surrogate pair.
* `replace` with an empty needle returns the haystack unchanged.
  Replacements aren't rescanned.
* `csv_parse` handles `,` separators, `\n` record endings (a final `\n`
  doesn't start an empty record), and quoted fields with `""` escapes and
  embedded commas and newlines. An empty line is a record with one empty
  field. `\r\n`, whitespace trimming and invalid-input diagnostics aren't
  supported.
* `matmul` needs rectangular matrices with compatible, non-zero dimensions
  (an empty `a` gives `[]`). An incompatible shape surfaces as `list::at`'s
  `IndexNotFound`, which `matmul` declares (`errors IndexNotFound`) and its
  caller handles. Entries are arbitrary-precision Ints.

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

**Benchmarks.** `tclsh9.0 bench/corpus.tcl [-runs N] [-markdown] [-all]` times
every algorithm at several input sizes on every backend. Each measurement
runs in a fresh process, so measurements can't disturb each other, and
compilation is excluded. Cases marked slow skip the interpreter unless
you pass `-all`. A backend is a case in `corpus::run` and a column; the
native backend's numbers and compile times are in §20. The table below is
the historical Tcl baseline.

`tclsh9.0 bench/corpus.tcl -runs 3` (best of 3, wall time, compilation
excluded). "compile, before" is the first compiler, from
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

* **reverse**: each step copies the whole accumulator (`str::concat(character,
  reversed)`), so the algorithm is O(n²) in characters copied. Up to 10,000
  characters the call overhead still dominates: times grow linearly.
  Before frames were reclaimed, the interpreter kept every intermediate
  accumulator alive: O(n²) memory.
* **replace**: testing for a match allocates a needle-sized substring at
  every position, and every match copies the result so far. Times are
  linear here because matches are sparse.
* **CSV**: `list::append` copies the list, so building n records costs O(n²).
  Going from 1,000 to 10,000 rows takes about 42× as long compiled: with
  call overhead reduced, the copying dominates.
  Quoted fields grow one character at a time. Every field scan allocates a
  two-element list just to return two values.
* **matmul**: n³ work as expected, but every entry read goes through
  `list::at` with a range check, and its result has no static kind. Every
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
tclsh9.0 main.tcl -aot FILE          # readable report, then run
tclsh9.0 main.tcl -aot-data FILE     # the analysis dict
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
* **No init checks:** every reference is to a binding established before it
  (§16), so no reference needs a run-time "is it bound yet" check. (There
  used to be a fact for a forward reference, as in mutual recursion.)
* `==` on two known scalars needs no structural comparison.

**The corpus today.** Every function in §18 has closed dispatch: every call
target is a known native or a known Botlish function. None is closed:

| Program | Dispatch | Types | Main blocker | Native-runtime needs |
|---------|----------|-------|--------------|----------------------|
| `reverse_chars` | closed | guarded (4 blockers) | parameter kinds (`text`, `index`, `reversed`) | bigint, char-index, string-alloc, range-check, structural-equality, tagged-values |
| `replace` | closed | guarded (12) | parameter kinds | bigint, char-index, string-alloc, range-check, tagged-values |
| `csv_parse` | closed | guarded (17) | parameter kinds (15); list elements of the `[field, index]` pairs (2) | bigint, char-index, string-alloc, list-alloc, range-check, tagged-values |
| `matmul` | closed | guarded (17) | parameter kinds (13); list elements feeding `*` and `list::at` (4) | bigint, list-alloc, range-check, structural-equality, tagged-values |

(Requirements are unions over each program's functions and exclude the
sample expression's list literal.)

The blockers come from two sources, neither of them dynamic dispatch:

1. **Parameters have no kind.** There are no annotations and no call-site
   inference, and calling a block proves nothing about its arguments. So
   the first use of each parameter needs a check, and results that pass a
   parameter through (`reverse_from`'s accumulator, `dot`'s `total`) are
   `any`. Flow facts from native signatures already remove every later
   check on the same path.
2. **Lists carry no element type.** `list::at` returns `any`. That affects
   `matmul`'s entries and the pairs `csv` returns.

This table is the *semantic* analysis, and it stays so: a function's HIR
types never change because of its callers. Call-site specialization (§21)
analyzes instances of these functions under the argument kinds their
callers pass, on the same `hir::aot` analysis, and closes all four programs.

**Found while building the corpus.**

* Fixed: `.bot` and `.ir` files were read in the platform's system encoding
  (cp1252 on Windows), which corrupted non-ASCII source. Program files are
  now read as UTF-8.
* Calls of a function bound later (mutual recursion) had no call target, so
  `is_even` in `examples/surface/09-mutual-recursion.bot` was `open`; the
  native milestone (§20) gave it one with an init check. Forward references
  are now illegal (STRICT-REFERENCE-DETERMINISM.md), so the example is a
  rejected program. Block calls still add no flow facts.

**For the first native (Cranelift) milestone**, in order of evidence (the
milestone is described in §20, where items 1, 3 and 4 were done; §21 does 2
and the element-type half of 5):

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
4. Give HIR call targets for forward references to functions (done at the
   time; forward references were later removed from the language).
5. Plan list element types and a growable or persistent list
   representation. `list::append` copying is what makes CSV quadratic.

## 20. The native backend (Cranelift)

`native/` compiles Botlish to machine code. It implements the same semantics
as the interpreter and the Tcl compiler, including arbitrary-precision Ints,
run-time kind checks and the reference error codes and messages. It runs the
algorithm corpus (§18) unchanged.

```sh
cargo build --release --manifest-path native/Cargo.toml   # Rust 1.96+, Cranelift 0.135
tclsh9.0 main.tcl -backend cranelift examples/stdlib/csv.bot
tclsh9.0 main.tcl -emit-nir examples/stdlib/matmul.bot       # native IR
tclsh9.0 main.tcl -emit-clif examples/stdlib/matmul.bot      # Cranelift IR
tclsh9.0 tests/native-coverage.tcl                           # whole suite on cranelift, classified
tclsh9.0 bench/corpus.tcl                                    # corpus timings, all backends
```

```tcl
source native/native.tcl        ;# loads compiler, hir and core too
native::evalHir $hir            ;# run a program-mode HIR natively (JIT)
native::executable $hir $path   ;# or link it into a standalone executable
```

Native compilation takes HIR (from `surface::readProgramFile`,
`hir::readFile`, or `hir::build` for a program written as core IR text) and
nothing else: there is no `core::useBackend cranelift`, and no path lowers
HIR to core IR and rebuilds HIR from it (`DIRECT-HIR-NATIVE-PATH.md`).

### Pipeline

```
HIR ──native::lower (Tcl)──▶ NIR text ──botlish-native (Rust)──▶ Cranelift IR ──▶ machine code
 │                            ▲
 └──hir::aot facts────────────┘
```

* **Native lowering** (`native/lower.tcl`) turns HIR into NIR, one NIR
  function per function *instance* (§21). It does no semantic analysis of
  its own. Instances and their call targets come from `hir::specialize`,
  guards from `hir::aot`'s representation blockers and known-error facts on
  each instance's typed view, self tail calls from
  `hir::aot::selfTailCalls` (shared with the Tcl compiler), and
  environment-free functions from `hir::aot`'s static blocks. Lowering cross-checks the guards against the
  view's types and reports a mismatch as a backend bug.
* **NIR** is register-based and representation-level: constants, moves,
  `guard KIND`, `op OP` (a known operation on operands of the kinds it
  requires), `call` / `callenv` / `callvalue`, `tail`, closures,
  branches, `ret` and `raise`. It has no names to resolve, no types and no
  traits. The format is documented at the top of `native/lower.tcl`.
* **The driver** `botlish-native` (`native/src/main.rs`) parses and
  validates NIR (`nir.rs`), translates it with the `Backend` interface
  (`codegen/`, whose only implementation is Cranelift), JIT-compiles and
  runs it against the runtime (`runtime/`). The Tcl backend runs one driver
  process per program: the NIR goes in as a file, and the value comes back
  in the host's runtime value representation (core/value.tcl), or the error
  with its error code.
* The same translation writes position-independent object files
  (`botlish-native object OUT FILE.nir`). Executable emission links that code
  with the runtime and an initializer for constants, module statics, callable
  metadata and relocated GC stack maps.

### Standalone executables (Linux x86_64 glibc)

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 main.tcl -emit-native-executable examples/stdlib/csv.bot
./examples/stdlib/csv
```

The output is a native ELF executable beside the source, named by removing
its extension. It prints the program's final value followed by a newline
(for example, `42`, `"text"`, or `[1, 2]`). Compilation never executes the
program. Runtime errors go to stderr and return a nonzero exit status.

The executable's `argv()` is the real Linux argument vector of each run
(`./program one two` gives `["./program", "one", "two"]`, argument zero as the
launcher supplied it), validated as UTF-8 only if and when the program calls
it; one executable serves any number of different runs. See ARGV.md.

Every used specialized instance must be **closed**, as reported by
`-aot-spec`; guarded and open workloads fail with `NATIVE AOT NOT-READY`
and source locations. This check uses the shared specialization analysis,
including retained generic entries, before expanding registered native
implementations into runtime support. Range checks, arbitrary-precision Ints,
closures and allocation remain supported runtime operations in closed code.

Compilation needs the built native backend, its adjacent
`libbotlish_native.rlib` and `deps/`, the matching `rustc` (or `RUSTC`
executable), and the system C linker. Cranelift compiles the program; rustc
compiles only its generated startup metadata and statically links the shared
Botlish runtime. The executable uses baseline x86-64 instructions and system
glibc/libm/libgcc; it needs no Tcl, Rust installation, source files, checkout,
or JIT at execution time. The build host determines the minimum glibc version.
`BOTLISH_NATIVE_GC_STRESS` and `BOTLISH_NATIVE_STACK_BYTES` also work for
standalone executables. Failed compilation leaves an existing output intact.

The Tcl API is `native::executable $hir $outputPath ?OPTIONS?`. It also
accepts the native lowering options; specialization is enabled by default
regardless of `BOTLISH_NATIVE_SPECIALIZE`. The CLI also accepts `.hir` and
`.ir` inputs and multiple input paths.

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
`str::length` and `str::substring` count Unicode scalar values, including
supplementary-plane characters as one unit each: ASCII strings are indexed
in O(1), others by walking the characters. This matches Tcl 9, the Tcl
reference implementation's required host (see this README's introduction),
so the corpus tests (§18) exercise supplementary-plane characters like any
other. `str::lowercase` is the Unicode 16 *simple* case mapping: each scalar maps
to exactly one scalar through `UnicodeData.txt`'s simple lowercase column, so
the character count never changes and the mapping ignores context and
language. Consequences: `İ` (U+0130) lowercases to `i` (not the full mapping's
`i` + U+0307), a Greek capital sigma always lowercases to `σ` (never the
final `ς`), and `ẞ` lowercases to `ß`. It is the reference interpreter's
`string tolower` (Tcl 9.0.x, Unicode 16 tables) plus a patch for the two
scalars Tcl leaves unchanged against the standard, U+023A and U+023E (they
lowercase to U+2C65 and U+2C66), and native uses Rust's tables adjusted the
same way: U+0130 is mapped to `i`, and the scalars Unicode 17 gave a
lowercase mapping (U+A7CE, U+A7D2, U+A7D4, U+16EA0..U+16EB8) stay unchanged.
Not implemented here, on purpose: the full mapping (`SpecialCasing.txt`, where
a scalar can become several, plus the final-sigma and language rules), which
is planned for a `grapheme::` namespace, and Unicode 17 and later. The
all-scalars comparison in `tests/native-tcl-unicode.test` fails if a Tcl or
Rust upgrade changes any mapping.

**Lists** are immutable vectors of values. `list::append` copies, as the
reference runtime does, so CSV's quadratic behavior is kept deliberately
(§18).

**Structs** are immutable heap objects of an interned shape (STRUCTS.md), but a
struct is a semantic value and a `StructObj` only one representation of it:
native code keeps a struct as its fields (one ordinary register each) while
it is built and only projected, carried across exact calls and returns, or
joined by an `if`, and materializes it -- once, lazily, with its exact named
or anonymous shape -- at the first use that needs the object (storage in a
List/MutableArray, equality, hashing, an unknown call, capture). `structnew`
in NIR therefore counts real materializations (STRUCT-SCALAR-REPLACEMENT.md;
`-struct-opt 0` disables it). *How far* a value stays virtual is a per-path
transport decision, not a width cap: its width, the exact argument and return
edges it would cross (weighted differently, a loop counted as unbounded) and a
use-density factor are scored against budgets, so a narrow value may be
carried through a dozen calls while a wide one, or one with a long forwarding
chain ahead of it, becomes one physical object -- built once, lazily, after its
cheap local uses -- and an inner struct that is only ever projected is opened
into its outer value (VALUE-TRANSPORT-MATERIALIZATION.md; `-struct-policy
legacy` restores the width-only caps for comparison).

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
* **Environment-free functions** are `hir::aot`'s static blocks. They take
  no closure argument. Their Block
  value is one constant closure, loaded from the constant table.
* **Closures.** A Block value is `{code, function id, arity, captures}`.
  Captures are values, which is sound because a reference's binding is
  established before the closure that reads it is created (§16). A closure
  reads its own function binding through `self`. (Earlier versions kept a
  *cell* for a binding read by a forward reference; forward references no
  longer exist, so lowering never emits cell instructions. The runtime's
  cell object and NIR ops are unused and left for the native cleanup.)
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
`error`), closures with captured values, self recursion, run-time
`UNBOUND` and `DUPLICATE`, calls chosen at run time, natives as values, and
the builtin natives of §8 (root primitives and standard intrinsics).

**Not supported** (each reported as `NATIVE UNSUPPORTED`):

* natives implemented only in Tcl: the `web` and regex libraries and the
  test suite's instrumentation natives (`test-log`, `test-tick`, …)
* named types and evidence (`Emailish?`, refined parameter types)
* sequence mode (`core::evalIn` in an existing Tcl environment)
* handing a Block value back to the host, and so refinement probes through
  `core::blockEnv`

### Coverage

`tests/native-coverage.tcl` runs the whole suite with
`CORE_BACKEND=cranelift` and puts every test in exactly one class. With
`BOTLISH_NATIVE_SPECIALIZE=0` (no specialization, §21) the classification
is identical:

| Class | Tests | Of the 757 tests that predate the backend | Meaning |
|---|---:|---:|---|
| native | 218 | 171 | passed, ran native code |
| independent | 566 | 541 | passed without running a program on the backend (frontend, HIR, analysis) |
| passed-partial | 3 | 0 | passed; checks an unsupported-construct diagnostic on purpose |
| unsupported | 45 | 45 | needs a construct listed above |
| failed | 0 | 0 | anything else |

The 45 unsupported tests need: a Block returned to the host (12), sequence
mode (7), `test-log`/`test_log` (8), `test-tick`/`test_tick` (6), `web`
library natives and evidence (9), and the test natives `test-fake-escape`,
`test-lax-param` and `test-both-ints?` (3).
`tests/native.test` (55 tests) checks lowering and CLIF structure, and
parity of interp, compile, cranelift-generic and cranelift on arithmetic at
the small/big boundaries, guards, every error class, strings, lists,
Results, calls, closures, specialization, the stack limit, the collector
and object emission. `tests/stdlib.test` runs every corpus case on all four
backends.

### Corpus

`tclsh9.0 bench/corpus.tcl -runs 3 -markdown` (best of 3, wall time). The
compile columns are native lowering in Tcl
(including the specialization analysis) + Cranelift code generation and JIT
linking. "code" is generic → specialized: machine code bytes, NIR functions
and kind guards in the NIR.

| algorithm | input | interp | compile | cranelift-generic | cranelift | generic compile | specialized compile | code | compile / cranelift | generic / specialized |
|---|---|---:|---:|---:|---:|---:|---:|---|---:|---:|
| string_reverse | 100 chars | 33.8 ms | 2.9 ms | 0.019 ms | 0.018 ms | 6.2 + 2.9 ms | 6.5 + 2.3 ms | 2054→1686 B, 3→3 fn, 4→0 guards | 163x | 1.1x |
| string_reverse | 1,000 chars | 300.5 ms | 13.0 ms | 0.422 ms | 0.390 ms | 5.2 + 2.8 ms | 6.4 + 2.3 ms | 2054→1686 B, 3→3 fn, 4→0 guards | 33x | 1.1x |
| string_reverse | 10,000 chars | 3107.1 ms | 128.9 ms | 21.8 ms | 23.6 ms | 5.7 + 2.7 ms | 7.1 + 2.4 ms | 2054→1686 B, 3→3 fn, 4→0 guards | 5.5x | 0.9x |
| string_replace | 1 KB | 583.5 ms | 15.9 ms | 0.134 ms | 0.116 ms | 11.9 + 5.2 ms | 9.9 + 3.5 ms | 4893→3813 B, 4→4 fn, 12→0 guards | 137x | 1.2x |
| string_replace | 10 KB | 5855.4 ms | 157.7 ms | 2.9 ms | 2.8 ms | 7.7 + 4.6 ms | 10.5 + 3.6 ms | 4893→3813 B, 4→4 fn, 12→0 guards | 56x | 1.0x |
| string_replace | 100 KB | skipped | 1696.6 ms | 142.7 ms | 82.5 ms | 18.2 + 7.9 ms | 14.3 + 3.8 ms | 4893→3813 B, 4→4 fn, 12→0 guards | 21x | 1.7x |
| csv | 100 rows | 2146.1 ms | 55.7 ms | 0.872 ms | 0.848 ms | 11.7 + 6.7 ms | 20.0 + 6.7 ms | 7588→8094 B, 8→10 fn, 17→0 guards | 66x | 1.0x |
| csv | 1,000 rows | 23233.3 ms | 832.8 ms | 12.5 ms | 11.6 ms | 11.2 + 6.6 ms | 25.7 + 7.7 ms | 7588→8094 B, 8→10 fn, 17→0 guards | 72x | 1.1x |
| csv | 10,000 rows | skipped | 36515.4 ms | 220.9 ms | 176.9 ms | 25.5 + 7.5 ms | 34.7 + 6.9 ms | 7588→8094 B, 8→10 fn, 17→0 guards | 207x | 1.2x |
| matmul | 2x3 * 3x2 | 14.9 ms | 0.896 ms | 0.002 ms | 0.002 ms | 8.1 + 5.7 ms | 16.4 + 5.4 ms | 6930→7494 B, 5→7 fn, 17→0 guards | 448x | 1.0x |
| matmul | 8x8 | 225.4 ms | 9.6 ms | 0.019 ms | 0.017 ms | 15.4 + 10.1 ms | 24.0 + 11.1 ms | 18044→18608 B, 5→7 fn, 17→0 guards | 564x | 1.1x |
| matmul | 16x16 | 1661.5 ms | 65.0 ms | 0.103 ms | 0.085 ms | 44.5 + 28.2 ms | 59.4 + 27.2 ms | 52231→52795 B, 5→7 fn, 17→0 guards | 765x | 1.2x |
| matmul | 32x32 | skipped | 491.3 ms | 0.729 ms | 0.577 ms | 133.7 + 131.0 ms | 195.2 + 120.8 ms | 200021→200585 B, 5→7 fn, 17→0 guards | 852x | 1.3x |

All four backends produced the same value in every case. The code sizes
include the program function, whose size is mostly the benchmark's literal
matrices.

The allocation-heavy cases vary between runs by more than guards could
explain: with `-runs 7`, string_reverse at 10,000 characters took 12.7 ms
generic and 13.3 ms specialized in one run and 14.5 / 14.1 ms in another,
and string_replace at 100 KB 35.1 / 36.4 ms and 34.0 / 35.6 ms. Their time
is string copying and collection, not checks.

Where the time goes:

* **reverse** and **replace** at large sizes are dominated by copying the
  accumulator string on every `str::concat`: O(n²) bytes, most of them garbage
  at once. Collection frequency matters more than the copying itself: with
  a 32 MB minimum collection threshold, `string_replace` at 100 KB took
  146 ms, because new copies kept landing in cold memory; with 1 MB it takes
  about 80 ms (see `native/src/runtime/heap.rs`). A nursery or reference counting would do
  better. The helpers derive a result's character count and ASCII flag from
  the operands instead of rescanning.
* **CSV** spends its time in `list::append` copies (quadratic in records)
  and in allocating the two-element `[field, index]` lists.
* **matmul** runs mostly inline: small-Int fast paths for `*` and `+`, and
  a `list::at` helper call with a range check per entry. Without guards it
  is 1.2–1.3× faster.
* Compile time is dominated by native lowering in Tcl for programs with
  large literals (the benchmark's matrices are source literals), and by
  Cranelift for the rest.

## 21. Call-site specialization

`hir/specialize.tcl` lets native code run functions *specialized* to the
kinds of the arguments their callers pass, while every function's semantics
and HIR types stay exactly what they were. It closes all 50 of the corpus's
kind guards (§19) without changing the corpus. It adds no syntax.

```sh
tclsh9.0 main.tcl -aot-spec examples/stdlib/csv.bot          # instances, facts, blockers
tclsh9.0 main.tcl -emit-nir examples/stdlib/csv.bot          # specialized NIR
tclsh9.0 main.tcl -backend cranelift-generic -emit-nir FILE  # the unspecialized NIR
BOTLISH_NATIVE_SPECIALIZE=0 tclsh9.0 tests/native-coverage.tcl
```

```tcl
set spec [hir::specialize::analyze $hir]      ;# instances, keys, results
puts [hir::specialize::explain $hir $spec]    ;# semantic and instance reports
native::nir $hir -specialize 0                ;# the guarded baseline
native::report $hir                           ;# guard accounting
```

### Semantic types and instances

A function's semantic type doesn't change because of its callers:
`fn reverse_from(text, index, reversed)` stays `(any, any, any)` in HIR,
and `hir::aot::analyze` still reports it guarded. An *instance* is an
implementation artifact: the function's code analyzed again under argument
kinds its semantic inference couldn't assume. Instances of one function
coexist:

```
reverse_from (semantic): guarded   [UnknownParameterKind 4]
reverse_from<str, int, str>: closed   [i2, line 16:16]
  params:   text : str, index : int, reversed : str
  result:   str
  calls:    reverse_from<str, int, str>
  guards:   0
```

Nothing observable changes. A Block value is always the generic function;
instances are chosen only by direct calls, and `f<int>` is never a value
programs can see. Specialization is an optimization: `-specialize 0`
(`cranelift-generic`) runs the generic functions everywhere, and the test
suite and the corpus produce the same values and errors both ways.

### Specialization keys

A key is `{BLOCK ARG-TYPES}`: the block's ExprId and one *key type* per
parameter. Key types are the static types of the arguments reduced to what
choosing an operation depends on:

* the kinds `int str bool unit result any`, with named-type evidence
  dropped (the instance still sees the base kind)
* `block` and `native` for callables, without which one
* `list`, `{list ELEM}` and `{list ELEM SHAPE}`, with key-typed elements

The generic instance has key type `any` everywhere. Equal keys are the same
instance: `keys` is the cache from key to instance, and instance ids are
allocated in discovery order, so the analysis is deterministic. No register
numbers or locations are part of a key.

### Which instance a call uses

For a call of a known block `B` in instance `I`:

1. `B` captures values (it isn't a static block, §19): `B<generic>`.
   Closures over values stay generic, because their captures' kinds would
   depend on which closure is running. Functions whose captures are only
   other functions are specialized.
2. A self tail call whose key types are all subtypes of `I`'s: `I` itself,
   so the call stays a CFG back edge. Otherwise the key is the pointwise lub
   of `I`'s key and the call's (`swap<int, str, int>` tail-calling
   `swap(b, a, n - 1)` goes to `swap<any, any, int>`, which loops). The lub
   is strictly more general, so a chain of such calls climbs a finite
   lattice and ends in an instance that loops. This keeps tail recursion in
   constant native stack.
3. Otherwise `B<key types>`. If every key type is `any`, that is
   `B<generic>`; if `B` already has `limit` (8) specialized instances in
   use, or the analysis has `instanceLimit` (1000) instances, the call uses
   `B<generic>` too.

**Explosion control**, then: at most 8 specialized instances per function
plus its generic one; key types bounded by the aggregate bounds below; self
tail calls only widen. Polymorphic recursion (`nest([x], n - 1)`) makes
instances with deeper list keys until the depth bound turns the key into
plain `list`, which then recurses into itself. Instances are reference
counted by the reachable code that calls or materializes them; one that
drops to zero is released and doesn't count towards the limit, so
instances an optimistic early pass needed don't crowd out the ones the
fixpoint needs.

### Analysis: region inference, results, fixpoint

Each instance is typed by `hir::types::inferRegion`: the same inference
walk as semantic inference (§13), with the same refinements, flow facts and
reachability, plus:

* **Entry facts.** Parameters are seeded with the key types; captured
  bindings with the lub of their types at every creation of the block the
  analysis has seen (for a static block, functions).
* **Calls of known blocks** ask the analysis for the callee instance's
  result type (`SpecializationSummary`: the `result` of the instance).
* **Aggregate facts** (below).
* **Error paths are `never`.** An operation that always raises (a native
  argument statically of another kind, a wrong number of arguments, a
  non-callable callee, a non-Boolean condition) has type `never`, so it
  contributes nothing to a result: `f(s)` returning `1 + "x"` on one path
  and `s` on the other is `str` in `f<str>` (semantically it is `any`). The
  error itself is unchanged: the always-failing check is still emitted.

The **result fixpoint** is a monotone worklist analysis. An instance's
result starts at `never` ("no normal completion known yet"). A call records
the caller as a dependent of the callee; after analyzing an instance, its
result becomes `lub(old, inferred)`, and if that changed, its dependents are
analyzed again. Seeds that grow (a block created with new captured types)
re-analyze that block's instances. All types involved are bounded, so every
chain of changes is finite; as a guard against a non-monotone corner case,
an instance analyzed more than 16 times gets result `any`, and a hard bound
on total analyses raises `{HIR SPECIALIZE LIMIT}`. At the fixpoint every
result holds under the assumptions its callers used, by induction over
calls, as in the semantic inference of recursive block results.

Instances are *unseen*, *building* or *analyzed*. A call that discovers an
unseen callee analyzes it on the spot (up to 32 deep), so the caller usually
sees the callee's result in its first pass; a building callee (recursion)
answers with its current result. The worklist then takes the most recently
discovered instance first, so callees settle before callers are analyzed
again. Mutual recursion (`even<int>` ↔ `odd<int>`) and cycles (`a → b → c
→ a`) reach a fixpoint with one instance per function.

The analysis never changes the HIR. Its output is an *overlay* per
instance: the type, known outcome and reachability of each of the region's
expressions that differ from the semantic HIR. `hir::specialize::view`
applies an overlay to a copy of the HIR. Native lowering memoizes them
(`hir::specialize::memoizeViews`): the analyses it composes and lowering
itself share one view per instance.

### Aggregate facts

Lists get element facts in region inference only (semantic HIR types are
unchanged):

| Form | Meaning |
|---|---|
| `{list ELEM}` (`list<ELEM>`) | every element has static type ELEM; `{list never}` is the empty list |
| `{list ELEM {P0 P1 ...}}` (`list[P0, P1]`) | exactly these elements, element i of type Pi; ELEM is their lub |

* List constants and `list` calls build them: `[1, 2, 3]` is `list<int>`,
  `[[1, 2], [3, 4]]` is `list<list<int>>`, `[1, "a"]` is `list[int, str]`
  (a shape is kept only when it says more than the element type), and `[]`
  is `list<never>`.
* `list::at(xs, i)` has the element type, or position i's type when `xs`
  has a shape and `i` is an Int constant in range. An empty list's element
  is not invented: `list::at([], 0)` is `any` (and fails with `IndexNotFound`).
* `list::append(xs, x)` is `list<lub(ELEM, type of x)>`: `list<int>` stays
  `list<int>` with an Int, and becomes plain `list` with a String. Appending
  drops a shape.
* lub joins element types and, for equal lengths, positions; plain `list`
  is `list<any>`.
* **Bounds:** list forms nest at most three deep (deeper lists are plain
  `list`), shapes have at most eight positions, and only the outermost list
  has one. So the lattice has finite height.

The rules are not specific to the corpus's natives: a native declares how
its result is built with `-result-shape` (`elements`, `element L I`,
`append L V`; `core/native.tcl`), like `-runtime`, and nothing in the
analysis knows a native by name. A list fact proves a kind, never an index:
`list::at` still range-checks, and Int arithmetic keeps its overflow path.

### Guards and lowering

`hir::aot` is the one source of truth for checks. `hir::aot::analyzeRegion`
analyzes one region on any typed view of the program (the semantic HIR, or
an instance's view), with the structural facts computed once
(`hir::aot::context`). An instance's guards are exactly its view's
representation blockers:

* a parameter whose key type is a kind needs no guard;
* a flow fact (`str::length(s)` proves `s : str`) or a refinement (`if
  integer?(x)`) already removes later guards on the same path, in both
  modes, because the view is typed by the same inference;
* a call result of a specialized callee has the callee's result type, and
  `list::at` on `list<int>` gives an `int` that `*` doesn't check.

Native lowering (`native/lower.tcl`) emits one NIR function per instance it
refers to, starting from the program: a direct call calls the instance the
analysis chose; `fnvalue` and `closure` use generic instances; a self tail
call that stays in its instance is `tail`. Only instances the lowered code
refers to are emitted, so a function that is only called with known kinds
has no generic code at all, unless its Block value is materialized
(`hir::aot::materializedBlocks`: a closure or a function passed as a value,
whose closure entry must exist).
Specializations use the generic ABI (tagged words in and out) and differ
only in what they don't check. The NIR header says which instance a
function is (`instance="str, int, str"` or `instance="generic"`).

`native::report HIR` checks the accounting: for both modes, the kind
guards lowering emitted equal the representation blockers of the emitted
instances (and of each tiny leaf inlined into one, once per inlined call,
since its guards are emitted there; but not those of code the lowering does
not emit at all: an `if` arm the instance's Ranges decide against, or what
would only run after an expression whose lowering never completes), and the
NIR's `guard`/`guardbool` instructions equal those plus the checks that
always fail (known errors). A mismatch raises `NATIVE BUG`.

### The corpus

| Program | Semantic blockers | Generic NIR guards | Specialized blockers | Specialized NIR guards | Status |
|---|---:|---:|---:|---:|---|
| `reverse_chars` | 4 | 4 | 0 | 0 | closed |
| `replace` | 12 | 12 | 0 | 0 | closed |
| `csv_parse` | 17 | 17 | 0 | 0 | closed |
| `matmul` | 17 | 17 | 0 | 0 | closed |

Every used instance of every corpus program is closed, transitively. The 44
parameter-kind guards go because every corpus function is called with known
kinds; `csv`'s two element guards go because `[field, index]` is
`list[str, int]` and `list::at(scanned, 1)` is an `int`; `matmul`'s four
because the literal matrices are `list<list<int>>`. The generic functions
stay guarded, and a caller passing, say, a matrix of Strings gets a different
instance (or the generic one) with the checks.

Instances emitted (generic mode emits one generic function each):

| Function | Generic | Specializations |
|---|---|---:|
| `reverse_from`, `reverse_chars` | no | 1 each |
| `matches_at`, `replace_from`, `replace` | no | 1 each |
| `peek`, `scan_unquoted`, `scan_quoted`, `scan_field`, `csv_parse` | no | 1 each |
| `scan_record` (`fields : list<never>` → `list<str>`) | no | 2 |
| `scan_records` (`records : list<never>` → `list<list<str>>`) | no | 2 |
| `dot`, `matmul` | no | 1 each |
| `product_row`, `product_rows` (empty → non-empty accumulator) | no | 2 each |

The second instance of the accumulating functions is the self-tail-call
widening at work: the first call passes `[]`, the loop passes a non-empty
list, and `list<never>` ∪ `list<str>` is `list<str>`, which then loops.

Representative NIR (`tclsh9.0 main.tcl -emit-nir examples/stdlib/matmul.bot`).
The generic `dot` checks 8 operands; `dot<list<int>, list<list<int>>, int,
int, int, int>` checks none, reads Ints out of `list<list<int>>`, multiplies
them without a guard, and loops:

```
func 1 "dot" ... instance="list<int>, list<list<int>>, int, int, int, int"
    %6 = op ieq %3 %4
    br %6 L0 L1
  label L0
    ret %5
  ...
  label L2
    %9 = op listget %0 %3
    %10 = op listget %1 %3
    %11 = op listget %10 %2
    %12 = op imul %9 %11
    %13 = int 1
    %14 = op iadd %3 %13
    %15 = op iadd %5 %12
    tail %0 %1 %2 %14 %4 %15
end
```

In `csv`, the specialized `scan_records` passes `list::at(scanned, 1)`, an
`int` from `list[list<str>, int]`, straight to its loop, and calls the
specialized `scan_record` (`call 5`):

```
func 8 "scan_records" ... instance="str, int, list<list<str>>"
    %7 = op listnew
    %8 = call 5 %0 %1 %7
    %9 = int 1
    %10 = op listget %8 %9
    %11 = int 0
    %12 = op listget %8 %11
    %13 = op listappend %2 %12
    tail %0 %10 %13
end
```

In the CLIF of `reverse_from<str, int, str>` the self tail call is
`jump block0(v68, v59, v67)` to the loop header; the function never calls
itself.

**Compile time** (lowering + JIT, from the table in §20; the first column is
the commit before this milestone, measured the same way):

| Case | before | generic | specialized |
|---|---:|---:|---:|
| string_reverse 100 chars | 4.1 + 3.4 ms | 6.2 + 2.9 ms | 6.5 + 2.3 ms |
| string_replace 1 KB | 6.4 + 4.7 ms | 11.9 + 5.2 ms | 9.9 + 3.5 ms |
| csv 100 rows | 8.4 + 6.9 ms | 11.7 + 6.7 ms | 20.0 + 6.7 ms |
| matmul 2x3 * 3x2 | 7.4 + 6.7 ms | 8.1 + 5.7 ms | 16.4 + 5.4 ms |
| matmul 32x32 | 136.4 + 121.8 ms | 133.7 + 131.0 ms | 195.2 + 120.8 ms |

Lowering times of a few milliseconds vary by ±2 ms between runs. The
specialization analysis roughly doubles lowering for small programs (every
instance's region is inferred and analyzed again), and costs about 60 ms on
matmul 32×32, whose program region holds 5,000 literal expressions. The
first version cost 250 ms there: the worklist re-inferred the program four
times, and views re-applied full overlays. Analyzing unseen callees on
demand, callee-first ordering and overlays of differences fixed that.
Cranelift time follows code size.

**Code size.** Specializations are smaller than their generic versions
(no guard blocks); functions that need two instances (an accumulator
starting empty) add code. Machine code of the corpus files as written
(`native::codeSize`): reverse 1,997 → 1,629 bytes (−18%), replace 4,769 →
3,689 (−23%), CSV 7,525 → 8,031 (+7%), matmul 6,100 → 6,664 (+9%).

### Known limitations

* Closures over values are never specialized.
* Positional shapes come only from literals; `list::at` uses a position only
  for a constant index. There are no Result payload facts.
* The limit counts instances in use at the moment a call is analyzed, so
  which calls get the generic instance at the limit depends on discovery
  order (deterministically).
* The Tcl compiler (§12) doesn't use instances yet. The analysis is
  backend-neutral (`hir/specialize.tcl`, views analyzed by `hir::aot`), so it
  could.

### Next milestone

Kinds are known; representations are not specialized yet. In order of
evidence:

1. **Unboxing** of Ints proven small (range analysis for indices and
   counters): matmul's inner loop and every index in the string functions.
2. **Transient builders** for `list::append` and string accumulation where
   the old value is provably dead (escape analysis), and **scalar
   replacement** of `[field, index]` pairs, whose shapes are now known.
3. A nursery or reference counting for the string-copying cases, which
   dominate reverse and replace at large sizes.
4. Specialization in the Tcl compiler, and of closures with per-creation
   capture facts.
5. Native stack maps and standalone closed AOT are now implemented (see
   §20): executable startup registers the linked functions' GC maps and
   initializes their constants before entering native code.

## 22. Allocation instrumentation

Before any of §21's "next milestone" items (unboxing landed; escape
analysis, transient builders, a nursery are still ahead), the runtime
needed to say *exactly* what it allocates, not just describe it in prose
like §20's "where the time goes." `native/src/runtime/metrics.rs` adds one
canonical accounting layer with no GC, codegen or ABI semantics changed:

```
NIR (op strcat, cell, closure, ...)
  --codegen/clif.rs: in Sites mode only, marks the causing instruction's
    site id in vm.alloc_site immediately before the allocating helper call
        │
        ▼
runtime/vm.rs Vm::alloc<T> ── the one physical allocation point
        │                          (String/List/BigInt/Result/Block/
        ▼                           Native all go through it; the constant
runtime/heap.rs Heap::collect       table is the one exception, counted
  (exact mark-sweep already          separately as "static", excluded from
   visits every object: live/         live/peak/GC since it is never swept)
   reclaimed counted here, never
   approximated as allocated-freed)
        │
        ▼
Metrics::to_tcl -- one Tcl dict (native::allocationReport), native::allocationText
  renders it for humans; native::assertAllocations and friends are built on it
```

**Allocation identity** is the existing `Header::kind` byte -- String, List,
BigInt, Result, Block, Native -- no new taxonomy. **`allocatedBytes`**
is exactly what the runtime's own constructors already compute and hand to
the heap: `size_of` the Rust struct (`headerBytes`) plus the caller-known
variable-length payload (`payloadBytes`) -- not the allocator's actual
malloc chunk size, no padding accounted for. **Live/peak/reclaimed** are
recomputed exactly at every collection from the retained set (never
"allocated − freed"), so `peakLiveObjects`/`peakLiveBytes` can exceed the
final `currentLiveObjects`/`currentLiveBytes` whenever a mid-run collection
actually reclaimed something. Each GC cycle records its reason (`threshold`,
`stress`, or `explicit` -- `Vm::reset`'s end-of-run collection between
benchmark runs), before/after object and byte counts, reclaimed
objects/bytes, and wall time.

**Site attribution** turns out to already be half-built: `native/lower.tcl`
was already emitting `@ExprId` on nearly every instruction
(`Emit`/`Assign`/`AssignRaw`), and `native/src/nir.rs`'s parser was just
discarding it (`if c == '@' { break; }`). Capturing it into
`Function::origins` and interning one `Site` per *compiled* allocating
instruction (never per dynamic execution, so a hot loop's one static
`str::concat` is one site regardless of iteration count) makes every allocation
traceable to `{file line column}` (via `hir::aot::Location`, so the Rust
backend itself never has to understand HIR) and to the runtime operation
that caused it (`strcat` vs. `substr` vs. `listappend`, not just "a
String"). A helper that may allocate but sometimes doesn't (BigInt
arithmetic landing back on a small result) has its site cleared again
immediately after the call, so an allocation-free slow path never
misattributes some later, unrelated allocation.

**Modes** (`botlish-native run|bench FILE.nir --alloc off|summary|sites`,
default `off`): `summary` is a runtime-only switch (no NIR/codegen
change) covering everything except per-site attribution; `sites`
additionally recompiles with the extra site-id stores, like `-specialize`
already recompiles to change what's measured. From Tcl:
`native::allocationReport HIR summary|sites ?RUNS? ?OPTIONS?`,
`native::allocationText REPORT`, and `native::assertAllocations`,
`assertAllocationsAtMost`, `assertBytesAtMost`, `assertKindAllocations` for
future collection/optimizer tests ("this steady-state lookup allocates zero
objects").

**Corpus baseline** (`tclsh9.0 bench/corpus.tcl -runs 3 -all -backends
cranelift`, summary mode, last of 3 runs):

| algorithm | input | allocations | allocated | peak live | GC cycles | string copied | list elems copied |
|---|---|---:|---:|---:|---:|---:|---:|
| string_reverse | 100 chars | 223 | 14.1 KB | 14.1 KB | 1 | 5.2 KB | 5 |
| string_reverse | 1,000 chars | 2,023 | 582.5 KB | 582.5 KB | 1 | 501.5 KB | 5 |
| string_reverse | 10,000 chars | 20,023 | 50.8 MB | 1.1 MB | 49 | 50.0 MB | 5 |
| string_replace | 1 KB | 1,058 | 71.8 KB | 71.8 KB | 1 | 29.4 KB | 5 |
| string_replace | 10 KB | 10,258 | 3.0 MB | 1.1 MB | 3 | 2.6 MB | 5 |
| string_replace | 100 KB | 102,258 | 256.4 MB | 1.4 MB | 236 | 252.3 MB | 5 |
| csv | 100 rows | 7,669 | 377.8 KB | 377.8 KB | 1 | 22.5 KB | 6,690 |
| csv | 1,000 rows | 79,571 | 7.5 MB | 1.3 MB | 8 | 247.3 KB | 516,540 |
| csv | 10,000 rows | 834,585 | 436.9 MB | 8.0 MB | 154 | 2.7 MB | 50,165,040 |
| matmul | 2×3 · 3×2 | 32 | 1.4 KB | 1.4 KB | 1 | 0 | 40 |
| matmul | 8×8 | 115 | 7.6 KB | 7.6 KB | 1 | 0 | 416 |
| matmul | 16×16 | 339 | 33.9 KB | 33.9 KB | 1 | 0 | 2,604 |
| matmul | 32×32 | 1,171 | 194.0 KB | 194.0 KB | 1 | 0 | 18,500 |

This confirms §20's prose quantitatively and sharpens it: **reverse** and
**replace** are almost entirely `str::concat`/`substr` String traffic (peak live
stays at 1.1–1.4 MB at their largest sizes tested -- 10,000 chars / 100 KB
-- while *copied* bytes grow into the hundreds of megabytes: the
accumulator is O(n) live at any instant but O(n²) copied over the run's
lifetime, all through one or two sites). **CSV**'s allocation count is
dominated by `list::append` (the 50 million list-element copies at 10,000
rows are almost all memmoving existing rows/fields forward one element at a
time) rather than by the `[field, index]` pair lists §20 also names as a
cost -- both are visible
now as distinct sites instead of one guess. **matmul** allocates almost
nothing per cell: the inner loop's Ints stay small and raw (§"Representation"
of `native/lower.tcl`), so the only sites are the output rows' `listnew`
calls, and no BigInt ever appears with these operands. The one surprise
worth a follow-up look: from 1,000 to 10,000 rows (10×), object *count*
scales near-linearly (79,571 → 834,585, 10.5×, as expected -- one
`list::append` per field/row) but elements *copied* scales quadratically
(516,540 → 50,165,040, 97×): `list::append`'s O(n) memmove on every call is
the entire explanation, and a transient builder (§21's item 2) should turn
it into O(n) total, not just fewer guards.

**Instrumentation overhead** (best of 5, wall time, same compiled program
except `sites` mode's extra site-id stores):

| case | off | summary | sites |
|---|---:|---:|---:|
| string_reverse 10,000 chars | 3.01 ms | 3.00 ms (≈0%) | 3.33 ms (+11%) |
| csv 10,000 rows | 268.2 ms | 305.3 ms (+14%) | 305.0 ms (+14%) |
| matmul 32×32 | 0.371 ms | 0.384 ms (+4%) | 0.402 ms (+8%) |

`summary` mode is close to free except on CSV's extreme allocation rate
(834,585 objects/run): `Heap::collect`'s exact accounting does one full
extra pass over every currently-tracked object per cycle (`bytes_before`)
on top of the sweep it already does, and CSV alone runs 154 collections.
That pass is a legitimate follow-up to cut (fold it into the existing sweep
loop rather than a separate one) if summary mode needs to get cheaper still
for very high allocation rates; it was not touched in this milestone, which
adds measurement only.

**BigInt and external memory.** A BigInt allocation counts as one Botlish
object with an estimated size (`n.bits() / 8`); `num-bigint`'s actual
internal limb buffer is a second, separate Rust allocation the Botlish heap
never sees, and its transient growth during arithmetic (e.g. intermediate
buffers a multiplication reallocates through) is invisible to this report
entirely. The report is explicitly a **Botlish managed heap allocation
report**: excluded, and said so in both the human and structured output,
are `num-bigint` limb buffers, the shadow stack (a fixed `Vec<Value>`,
~32 MB), Cranelift/JIT code memory, and general process bookkeeping.

```sh
tclsh9.0 bench/corpus.tcl -runs 3 -all -backends cranelift   # alloc column, cranelift only
```
```tcl
native::allocationReport $hir summary            ;# or sites, ?runs? ?options?
puts [native::allocationText $report]            ;# human-readable
native::assertAllocations $hir 0                 ;# a future HashTable-lookup test's shape
```

Tests: `tests/native-alloc.test` (17 tests: counts, bytes, copies, live/
reclaimed exactness, peak > final, per-run isolation, two source
expressions of the same kind as distinct sites, a non-allocating slow path
leaving no stale site, `BOTLISH_NATIVE_GC_STRESS=1` consistency,
instrumentation-off semantic parity) plus 7 Rust unit tests
(`native/src/runtime/heap.rs`) against `Heap`/`Metrics` directly. Neither
GC policy nor codegen semantics changed: `tests/all.tcl` (891 tests, both
Tcl backends) and `tests/native-coverage.tcl` are unaffected.

## 23. Compiler warnings

Botlish compiler warnings are **enabled by default**. They report *semantic
facts the compiler can prove*: a warning says what is true of a legal program
and stops. It never says what to do about it, and a program that keeps the
fact on purpose is correct. A warning that cannot cite a compiler proof does
not belong in a default-on, non-suppressible system.

That bar admits two *preference-shaped* warnings, `METHOD-ELIGIBLE` and
`FIXED-ARITY-LIST-RETURN` (below), and only because each passes the bar rather
than because "style warnings are fine now": (1) its **fact** is compiler-proven
-- the sugared spelling parses and resolves to the identical callee; every
reachable value exit is a written list literal of one arity -- with the
compiler's own parser, resolver, provenance and reachability as the prover;
(2) the **preference** it serves is the language's own declared design
(receiver syntax is Botlish's preferred call form; struct values have named
parts and destructure, Lists deliberately do not: MULTI-VALUE-RESULTS.md), not
a per-warning fashion; (3) the **function's author** has first-class control at
the declaration, as part of the interface: `nomethod fn` withdraws method
eligibility, and a result type `-> list` / `-> List[T]` declares a list result.
Neither is call-site suppression, and both have semantic consequences the
checker enforces (there is still no lint-ignore, pragma or per-call opt-out);
(4) **uncertainty means silence**: wherever the compiler cannot prove the fact,
it says nothing.

There is one global policy per compilation, and nothing finer:

| mode | meaning |
|------|---------|
| `default` | warnings are discovered, attached to the HIR (`hir::warnings::of`) and printed on stderr |
| `off` | no warning pass runs at all (generated source, benchmarks, embedding) |
| `error` | the first warning is a compilation error carrying the warning's own code, raised before any backend runs |

```sh
tclsh9.0 main.tcl -warnings error FILE.bot      # default | off | error
BOTLISH_WARNINGS=off tclsh9.0 bench/bench.tcl   # the default for a compilation given no option
```
```tcl
set hir [surface::compile $source file.bot -warnings default -warning-channel ""]
hir::warnings::of $hir      ;# {code message primary secondary data} records
```

**Botlish does not currently provide GCC/Clang-style `-Wfoo` controls** (no
`-Wno-foo`, `-Werror=foo`, `-Wall`, warning groups or levels), and no source
annotation or comment suppresses a warning. This is intentional, not forgotten
CLI work: every warning is on for everyone, so a warning must be trustworthy
enough to be, and uncertainty means no warning. Codes (`SAME-RETURN-VALUE`,
`METHOD-ELIGIBLE`, `FIXED-ARITY-LIST-RETURN`, `SAME-FAILURE`) are stable for
tests, tooling and documentation, but they are not switches. Adding
`METHOD-ELIGIBLE`, `FIXED-ARITY-LIST-RETURN` and `SAME-FAILURE` gave
`BOTLISH_WARNINGS` and the command line nothing: three modes, one option.

`SAME-RETURN-VALUE`: several distinct, reachable exits of one function are
proven to return the same value.

```
fn classify(x):
    if x < 0:
        return invalid
    if x > 100:
        return invalid
    valid
```
```
f.bot:3:9: warning: value `-1` (`invalid`) is returned from 2 distinct exits (SAME-RETURN-VALUE)
f.bot:5:9: note: also returned here
```

The proof is the compiler's own exact-value facts (`hir::exact`): equal exact
values through immutable aliases, or the very same immutable binding. A call, an
unproven expression or a separately constructed mutable value is never assumed
equal, and `unit` is never reported. See WARNINGS-SAME-RETURN.md for the
semantics, architecture, the corpus audit and known limitations; the tests are
`tests/warnings.test` and `audit/same-return-value/tools/fuzz.tcl`.

`METHOD-ELIGIBLE`: a reachable call *written* in functional form to a declared
named function of at least two parameters whose method spelling is proven to
parse and to resolve to the identical callee.

```
fn any_hit(xs):
    return any(xs, hit?)
```
```
f.bot:2:12: warning: call to `any` is eligible for method syntax (METHOD-ELIGIBLE)
```

The rules are exactly two. (1) Method sugar must be syntactically allowed and
unambiguous: the receiver (the call's first argument) is, as written, a
postfix or primary expression -- a name, qualified name, field chain, call or
method-call result, literal, list or struct literal -- and not an operator
expression, which would need added parentheses; the callee is a declared named
function (`fn`, a builtin, a module function), never a function *value* (a
parameter, an alias) and never `nomethod`; and the resolver's own candidate
gathering for the sugared spelling finds exactly that function and nothing
else visible under the name, with no struct field of that name that could
compete with it. (2) The function declares at least two ordinary parameters
(flags do not count): the sugar moves a trailing argument behind the dot, and
`length(s)` has none to move, so it never suggests `s.length()`. That rule
lives in the warning only; the language's sugar is not restricted by it.

The warning is one-directional (a call already written with sugar is never told
it could be functional), prints no rewrite and carries no fixit, and is one
diagnostic per written call site (no grouping, one location, empty
`secondary`). `x.f(y)` where `f` is `nomethod` is an error, not a warning, so
`nomethod` is a language declaration and not a way to silence anything. See
WARNINGS-METHOD-ELIGIBLE.md for the eligibility theorem, the receiver-form
table, provenance, the corpus audit, the round-trip law and known limitations;
the tests are `tests/method-eligible.test` and
`audit/method-eligible/tools/fuzz.tcl`.

`FIXED-ARITY-LIST-RETURN`: every reachable value exit of one function produces
a written list literal of the same arity N >= 2 -- the positional multi-value
result that struct values name the parts of.

```
fn scan_quoted(text, index, field) errors LowerUnderrun:
    character = peek(text, index)
    if character == "\"":
        if peek(text, index + 1) == "\"":
            return scan_quoted(text, index + 2, str::concat(field, "\""))

        return [field, index + 1]

    scan_quoted(text, index + 1, str::concat(field, character))
```
```
f.bot:4:13: warning: a 2-element list is returned from all 3 value exits; a struct value names the parts (FIXED-ARITY-LIST-RETURN)
f.bot:7:9: note: also returned here
f.bot:9:5: note: also returned here
```

An exit counts as the shape when it is a written list literal (the frontend's
provenance, never text), a read of a binding whose initializer is one (bindings
are immutable, so the initializer is the value), or a direct self-call (whose
value is the function's own: it inherits N); at least one literal is required.
Any single other exit silences: a unit exit (a bare `return`, a final `unit`,
or the fall-through of an else-less final `if` -- "a list or nothing" is an
optional, not a fixed-arity result; this deliberately differs from
`SAME-RETURN-VALUE`, which skips unit), a computed or mutable list, a struct, a
call of any other function, mixed arities, and one- or zero-element lists.
`fail` is not a value exit, so a guard that fails before a list result does not
block the warning; unreachable exits (structurally, or by the completion
proof's range facts) are not exits. Element types are never consulted. A
function whose declaration carries a list-typed result annotation (`-> list`,
`-> List[T]`) has declared its result a list and is never reported; that
annotation is a real type the checker must prove, not a suppression. One
diagnostic per function, anchored at its first exit, the others as notes; no
rewrite, no suggested field names. See WARNINGS-FIXED-ARITY-LIST-RETURN.md for
the shape theorem, the soundness arguments, the corpus audit and known
limitations, and MULTI-VALUE-RESULTS.md for the idiom; the tests are
`tests/fixed-arity-list-return.test` and
`audit/fixed-arity-list-return/tools/fuzz.tcl`.

`SAME-FAILURE`: several distinct, reachable exits of one function `fail` the
same declared failure.

```
error Invalid
fn parse_record(text, pos) errors Invalid:
    if text == "":
        fail Invalid
    if pos == 3:
        fail Invalid
    pos + 1
```
```
f.bot:4:9: warning: failure `Invalid` is raised from 2 distinct exits (SAME-FAILURE)
f.bot:6:9: note: also raised here
```

It is `SAME-RETURN-VALUE`'s theorem on the other completion kind, and it makes
milestone 1's rule bidirectional: a `fail` is never grouped with a return, and
a return is never grouped with a `fail`. The exits are exactly the written
`fail` statements of the function's own body, wherever they sit (branches,
every loop form, on-handler bodies; a re-raise `on E: fail E` is a written
`fail` and counts). Nothing else is a failure exit: the final expression and a
fall-through are normal completions, and a call that fails (an unhandled call
of a fallible function, a final bare call included) propagates its callee's
failure and is an ordinary call. Identity is nominal: `fail` carries a declared
error's name and no payload, and a declared error's name is its identity across
the whole program (a second declaration of a name is rejected), so two sites
fail the same failure exactly when they fail the same name the function's
`errors` clause admits -- similarly named failures (`A`, `A2`) are different
failures. It is silent for a single exit, for different declared failures, for
unreachable sites (statically decided branches, code after a completion, and
branches the completion proof's range facts prove infeasible), for propagated
failures, and for a nested function's or closure's fails, which belong to that
function and are checked on their own; whatever the compiler cannot establish
is silence. One diagnostic per failure group, anchored at its first exit, the
others as notes; a function failing two names repeatedly gets two warnings. The
warning states the fact and stops: it does not suggest merging the guards,
splitting the failure into richer ones, or that the repetition is wrong -- each
can be the right response, and so can keeping the uniform failure. See
WARNINGS-SAME-FAILURE.md for the theorem, the mirror-image exits table, the
reachability argument, the corpus audit and known limitations; the tests are
`tests/same-failure.test` and `audit/same-failure/tools/fuzz.tcl`.
