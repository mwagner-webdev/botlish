# Flag parameters

A small language milestone: a distinct parameter category for simple boolean
options.

```
fn open(path, flags :append, :cloexec):
    ...

fd = open("file.txt", :append, :cloexec)
fd = "file.txt".open(:append, :cloexec)
```

> A flag parameter is an immutable `Bool` parameter with a fixed default of
> `false`, set to `true` solely by the presence of its flag name at the call
> site.

Flags are a *callable-interface* category, not surface sugar for `Bool`
arguments, and they have no semantic physical representation. This milestone
is the language feature; it deliberately does not design an ABI, a Linux flag
mapping, or a flag-based overload system.

## Declaration

```
function    = "fn" IDENT "(" [ paramList ] ")" [ "->" IDENT ] [ "errors" ... ] ":" suite
paramList   = [ param { "," param } ] [ "," flagSection ] [ "," ]
param       = IDENT [ ":" typeExpr ]
flagSection = "flags" flagDecl { "," flagDecl }
flagDecl    = ":" IDENT                     -- the name glued to the colon
```

`fn f(x, y, flags :a, :b, :c)`, `fn f(flags :a)` (zero ordinary parameters)
and `fn f(x, flags :a, :b,)` (trailing comma) are valid. Each flag introduces
an immutable local named without the colon (`quiet` for `:quiet`), of
semantic type `Bool`: `true` if `:quiet` was supplied at this call, `false`
otherwise. There is no `:foo = true`, `required :foo`, `!:foo` or `nofoo`;
`flags :no_cache` is just a flag whose name happens to start with `no_`. An
option that is not naturally "optional Bool, absent means false" is an
ordinary parameter, an enum, a struct value, ...

**Section order.** A parameter list is a sequence of *sections* in one
canonical order, `ordinary* -> flags? -> context? -> variadic?`; `ordinary`,
`flags` and (since CONTEXTS.md) `context` exist. The parser (`surface/parser.tcl`,
`ParamSections`) reads one entry at a time and each entry knows its section
(`paramSectionOrder`, `EnterSection`); `flags` does not swallow the rest of the
signature, so `context` after it (CONTEXTS.md: `fn f(x, flags :q, context io:
LinuxIO)`, its own `MALFORMED-CONTEXT-SECTION` diagnostics), and a terminal
`variadic`, are one more marker and one more rank. An ordinary parameter after the flag section, a
second `flags` section, or a flag outside the section is
`MALFORMED-FLAG-SECTION`.

**`flags` is contextual, not reserved.** It opens the flag section only where
an entry is spelled `flags :NAME`: the word, a colon *separated from it by
space*, and a name glued to the colon. Everywhere else it is an ordinary
identifier: `fn f(flags)`, `fn f(flags, x)`, `fn f(x, flags)`,
`fn f(flags: int)` and `fn f(flags : int)` are an ordinary (possibly typed)
parameter named `flags`, and `flags = 1`, `f(flags)`, `flags.x` are
expressions as before. (The one spelling that changes meaning is the
previously meaningless `flags :name` in a parameter list.) A flag may itself
be named `flags`.

**Order is canonical.** Declaration order is kept as written
(`fn f(flags :zeta, :alpha)` is `zeta, alpha`, never sorted) in the AST, in
HIR, in diagnostics.

**One local namespace.** Flags are ordinary locals of the function's scope:
`fn f(mode, flags :mode)` is `FLAG-BINDING-COLLISION`, a body binding named
like a flag is the ordinary `DUPLICATE`, a nested scope may shadow one as it
may shadow a parameter. A flag declared twice is
`DUPLICATE-FLAG-DECLARATION`. Both point at the flag's spelling. Flags are not
a namespace of their own: `:append` of `open` and `:append` of `log` are
unrelated (no flag-name registry, no global flag).

## Call syntax

```
callArgs = [ expression { "," expression } ] [ "," flag { "," flag } ] [ "," ]
flag     = ":" IDENT                        -- the name glued to the colon
```

`f(x)`, `f(x, :quiet)`, `f(x, :quiet, :flush)`; method calls use the same
argument list: `x.f(a, :quiet)`. Flag order is irrelevant
(`f(x, :a, :b)` is `f(x, :b, :a)`: they resolve to the same HIR). A flag is
not an expression: it has no value and no runtime event, so `f(make_x(), :q)`
evaluates `make_x()` and nothing for `:q`. A flag is only valid in this
position: `x = :foo`, `return :foo`, `[:foo]`, `{k: :foo}`, `(:foo)`,
`1 + :foo` are `FLAG-NOT-A-VALUE`; there is no `FlagSet` type, no
`has_flag`, no `...flags` / `**flags` / `flags...`, no dynamic forwarding. A
wrapper that wants a callee's flag declares it in its own signature
(`inner(:v)` only inside `if v:`): a callee gaining a flag never silently
enlarges a wrapper's API.

An ordinary argument after the flags is `ARGUMENT-AFTER-FLAG` (`f(a, :q, b)`);
this keeps the flag section distinguishable from a future variadic argument
list. `f(:a, :a)` is `DUPLICATE-FLAG` (a set spelled twice is an error, never
idempotent).

## Diagnostics

| Code | When | Located at |
|---|---|---|
| `UNKNOWN-FLAG` | `f(:flush)` where `f` does not declare `:flush`: `function f does not accept flag :flush (accepted flags: :quiet)` (or `it declares no flags`) | the flag |
| `DUPLICATE-FLAG` | `f(:quiet, :quiet)`: `flag :quiet was supplied more than once` | the second spelling |
| `FLAG-CALLEE-UNKNOWN` | a flag supplied to a callee that is not a statically known function (a parameter, a field, ...) | the flag |
| `ARITY` | a call of a function with flags passes the wrong number of ordinary arguments, counted *without* the flags (a function without flags keeps its run-time `ARITY`) | the call |
| `FLAG-FUNCTION-VALUE` | a function with flags used as a value (see "Aliases and values") | the reference |
| `DUPLICATE-FLAG-DECLARATION` | `fn f(flags :a, :a)` | the second declaration |
| `FLAG-BINDING-COLLISION` | `fn f(x, flags :x)` | the flag |
| `MALFORMED-FLAG-SECTION` | ordinary parameter after the flag section, a second section, a flag outside the section | the offender |
| `MALFORMED-FLAG` | `:` without a name, a keyword as the name, a space after `:` | the colon |
| `ARGUMENT-AFTER-FLAG` | an ordinary call argument after a flag | the argument |
| `FLAG-NOT-A-VALUE` | `:name` where a value is | the flag |

The syntax ones are surface syntax diagnostics with a code (`FailCode`); the
rest are HIR diagnostics raised as `CORE SEMANTIC <CODE>` like every other
static error. Method spelling reports exactly the free call's diagnostic, at
the flag.

## Aliases and values

The flag interface belongs to the called *declaration*, resolved statically
at each call: the function binding, or a name bound to it (`g = f`, a chain
of such, a module function bound to a name, `m::f`). `g(:a)` and
`value.g(:a)` use `f`'s interface and name the called spelling (`g`) in
diagnostics.

A function with flags is **not a first-class value**. It can be called
(directly, through an alias, through method sugar) and bound to another name
as the whole right side of a binding; passing it as an argument, returning it,
storing it in a list or struct, or putting it in an `if` value is
`FLAG-FUNCTION-VALUE`. Reason: nothing in this milestone gives a function
*type* a flag interface (the structural `Fn{args, return, errors}` type has
none, and no variance/subtyping rule is invented), so a flagged function that
escaped could be called through a path that cannot see its flags. The future
rule is expected to make accepted flag names part of the callable signature;
nothing here blocks it. Function values without flags are unchanged.

## Boolean arguments

Flags are the language's form for *options*. A call that passes boolean
literals is unreadable: `true` carries no name, so

```
open_file("file.txt", true, false, true)
```

says nothing about what it asks for, and once a call passes two or more of
them the signature cannot be used at the call site without reading the
declaration. Declared with flags, the same function names each option where it
is used, and an option that is not wanted is simply not written:

```
fn open_file(path, flags :append, :create, :sync):
    ...
open_file("file.txt", :append, :sync)
```

The idiom:

* an **option** -- an optional choice the caller makes, absent means `false`
  -- is a flag;
* a boolean **parameter** remains right for *data* bools -- a function whose
  ordinary parameters are all bools (`xor(a: bool, b: bool)`) has no subject
  for options to qualify -- and for values callers compute:
  `open_file(path, wants_append, ...)` and `open_file(path, n > 0, ...)`
  already say what they mean;
* where flags do not apply (a bool every caller computes, a function used as a
  value -- a function with flags is not a first-class value, see "Aliases and
  values" -- a native's interface), a **named binding** at the call
  (`append = true` ... `open_file(path, append, create, sync)`) is the
  readable alternative.

The compiler warning `MANY-BOOLEAN-ARGUMENTS` (README.md §23,
WARNINGS-MANY-BOOLEAN-ARGUMENTS.md) points at this statement: a written call
that passes two or more boolean literals to a declared function whose
signature has a subject and at least two parameters the checker proves bool.
It states the count, names the callee and names the form; flags are never
counted, and a named or computed bool is never evidence.

**It is deliberately not autofixable.** Rewriting positional bools as flags
needs a mapping from each literal to a flag name, and nothing catches a wrong
one: a flag defaults to `false`, so a rewrite that drops or swaps an option
still passes the right number of ordinary arguments and compiles. The arity
check that catches a mis-mapped rewrite of positional arguments has no
counterpart for flags; a wrong mapping compiles, runs and is silently wrong
(the warning's fuzzer swaps two flags at every call of every convertible
callee: every such rewrite compiles, and many change the program's value).
And which `true` means which option is the author's intent, not a proof: the
only names in sight are the parameter names, and the call is unreadable
precisely because `true` carries no name -- recovering one from the
declaration would be guessing, circularly.

**Graduation criteria (future work, not implemented).** Revisit -- make it
autofixable, or redesign it -- when either holds:

1. the language makes the literal-to-flag mapping *declared and total* (for
   example, call-site option syntax for positional bools, so that every
   positional bool has a declared name a rewrite reads rather than guesses);
2. **flag-variables land** -- a flag's value carried in a variable (today a
   flag is not a value: `FLAG-NOT-A-VALUE`). That is the recorded revisit
   trigger: the evidence rule and the per-site choice are then re-examined
   together (a flag-variable passed to a `bool` parameter is named, hence
   silent today, and may deserve to be evidence of its own; and grouping per
   callee, or anchoring at the declaration, may become the better design).

## What each layer holds

1. **AST** (`surface/ast.tcl`). `function` has `flags` ({name span} dicts in
   written order, beside `params`); `call` and `methodcall` have `flags` (the
   supplied flags, in written order). A flag's span covers `:name`; ids are
   `FN()/flag(NAME)` and `CALL/flag(NAME)`. `-ast` prints
   `fn f (x flags :a :b)` and `(call (name f) (name x) :a)`.
2. **Syntax** (`hir/syntax.tcl`). `block` takes optional `flags`
   ({NAME ORIGIN} pairs); `call` takes optional `flags` (`withFlags`). Flags
   are names with origins, never expression nodes.
3. **HIR** (`hir/flags.tcl`, `hir/resolve.tcl`'s block and call cases). The
   semantic facts, independent of any physical transport:
   * `block` expr `flags`: the declared flag names in declaration order.
   * binding `flagIface` `{flags NAMES ordinary N}`: the interface of a
     binding that denotes a declared function, copied to aliases of it.
   * `call` expr `flagVector` `{{NAME 0|1}...}`: one entry per flag the callee
     declares, in declaration order; `1` if the call supplied it. The
     supplied *set* is what is recorded: call-site order is gone.
4. **How flags become Bool bindings.** Each declared flag is one more
   parameter of the block, `bool`-typed (`declaredParamTypes`), after the
   ordinary ones, bound in the function's own body scope exactly like an
   ordinary parameter: the body's `quiet` is a normal reference to a normal
   immutable `bool` binding. There is no flag value type.
5. **How calls encode supplied flags.** While resolving a call whose callee has
   a known interface, `hir::flags::ResolveCall` validates the supplied set
   against it and appends one `bool` constant per declared flag to the call's
   `args` (`true` supplied, `false` omitted, declaration order); evaluation
   events are those of the ordinary arguments only. This trailing-Bool
   transport is an **internal, replaceable** representation: it is the
   simplest correct one for this architecture (every analysis, the
   interpreter, the Tcl compiler and native see an ordinary call of ordinary
   `bool` parameters), and `flags` / `flagVector` keep the semantic identity so
   a later lowering can transport flags differently (a bitfield, nothing for a
   flag no callee reads).
6. **Interpreter and Tcl compiler.** They run the core IR HIR lowers to: the
   function is `(block (x a b) ...)` and the call `(call f x true false)`.
   For each invocation the declared flag is `true` if supplied and `false`
   otherwise, then the body runs with ordinary Bool values. Nothing about
   flags exists in core IR or the evaluators.
7. **Native.** HIR lowers to NIR as it always did: one `bool` parameter per
   flag, constants at the call. **This physical representation is not the
   language ABI** and no ABI independently requires it.
8. **Method syntax.** Normalization is unchanged (METHOD-SUGAR.md): the
   resolver turns `x.f(a, :q)` into the ordinary call `f(x, a)` plus the
   supplied flags, then validates the flags like any call's. The receiver is
   the first ordinary argument; `x.f(:q)` and `f(x, :q)` are the same HIR
   (printed text, core IR, diagnostics).

## Representation independence and ABI

The semantic model is "Bool parameters". Today's trailing `bool` parameters
are one possible physical choice; the compiler remains free to transport flags
as separate booleans, one bitfield, compile-time constants, or not at all,
provided behaviour is identical, and the HIR keeps the flag names (in
declaration order) and each call's static flag vector to decide that later.
Future work may distinguish *semantic callable signature*, *stable generic
physical contract* (e.g. a declaration-order bitmask for exported or
first-class functions) and *specialized closed-call contract* (a closed
instance that erases the transport). **No final generic flag ABI was
introduced in this milestone**: no bit numbers, no export machinery, no
separate-compilation design, and nothing Linux-specific. A Botlish wrapper
around a syscall maps `append` to a native bit itself, in ordinary Botlish.

## Specialization and constant propagation today

A closed call such as `f(10, :a)` passes constant `bool` arguments; the
existing call-site specialization keys instances by argument *types* (`f<int,
bool, bool>`), so `f(10, :a)`, `f(20, :b)`, `f(30)` share **one** specialized
instance: no per-flag-combination instances (no `2^N`), no flag-specific
specialization engine, and no constant propagation of the flag values into the
callee body (a constant `bool` argument is not specialized on). Dead-flag
elimination (a flag no body reads) is not done; an unused flag is neither an
error nor a warning (no warning reads a flag's use; `MANY-BOOLEAN-ARGUMENTS`,
"Boolean arguments" above, never counts flags).

## Non-goals (not implemented)

`context`, new variadic semantics, overloading, function-type variance,
first-class flag values, runtime flag dictionaries, spreads or rest
forwarding, default-true / required / negated flags, arbitrary flag
expressions, reflection over supplied flags, a Linux syscall library or
constant mapping, an external ABI, bitmask optimisation, per-combination
specialization, lint policy about flags, and anything about the planned
method-syntax linter.

## Tests

* `tests/flags.test` (155 tests; programs run on the interpreter, Tcl
  compiler, native generic and native specialized, and one on the standalone
  executable): AST shapes, spans, contextual `flags`, 22 syntax errors with
  codes and columns, observation of every flag subset, omitted flags false,
  fresh per-call values, flags in `if`/`and`/`or`/`not`/`==`, calls, struct
  fields, returns, closures, nested and recursive calls (different flag sets
  per recursive call), explicit-only forwarding, handled calls, the same
  spelling in unrelated functions, 13 static diagnostics with locations,
  diagnostics through methods and aliases, `FLAG-FUNCTION-VALUE`, aliases
  (chains, methods, plain-function aliases, non-static aliases), method vs free
  parity (7 shapes, equal HIR) and evaluation order with logs (flags add and
  reorder no events), the retained HIR facts (declaration order,
  `flagVector`, `flagIface`, aliases, no flag expression kind, HIR text round
  trip, core IR shape), module functions (qualified, bound, as method, unknown
  flag, as value), the all-8-subsets and all-6-call-orders differential for six
  function bodies (observe, branches, arithmetic weights, forwarded to an
  ordinary function, struct, recursive) in free and method spelling, native
  specialization, one namespace, no warnings under `-warnings error`, the
  standalone executable, and a fuzz smoke run.
* `audit/flags/tools/fuzz.tcl` (`-n N -seed S -dump 1 -backends LIST`): the
  generator described in its header (0..4 flags in random declaration order,
  six body shapes, unused flags, free / method / alias / nested / probed
  calls, random supplied subsets in random order, recursive functions that
  rebuild their flag set) against an independent Tcl model of values and
  evaluation log, plus one negative program per generated program (eleven
  defect kinds, each with its expected diagnostic).

Results of the fuzz run are recorded in the milestone report that came with
this change; the fuzzer demonstrably can fail (with call flag arguments
appended in reverse order it reports 13 oracle disagreements in 20 programs;
with the unknown-flag check disabled, 4 negative escapes).

## Known limitations

* A function with flags is not a first-class value (above).
* `hir::format` / `hir::parse` (HIR text) carry the trailing `bool`
  parameters and the Bool arguments but not the flag identity (`flags`,
  `flagVector`, `flagIface` are in-memory facts, rebuilt only by resolution).
* Unflagged functions keep their run-time `ARITY`; only calls of functions
  with flags are arity-checked statically, so that the message can count
  ordinary arguments.
* No constant propagation of flag values and no dead-flag elimination yet.
* The one existing spelling whose meaning changes: a parameter written
  `flags :T` (space before the colon, none after) used to be a parameter
  named `flags` annotated `T`; it now opens a flag section. `flags: T`,
  `flags : T`, `flags:T` and plain `flags` are unchanged. No program in the
  repository (tests, examples, `lib/`, corpus) uses the changed spelling.
