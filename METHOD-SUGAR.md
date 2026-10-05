# Method-call sugar

A small syntax milestone: `value.f(a, b)` as an alternate spelling of the
ordinary call `f(value, a, b)`.

```
import list                                # the namespace's functions become candidates
xs.at(i)                   ==   list::at(xs, i)
import str
text.substring(0, 5)       ==   str::substring(text, 0, 5)
n.inc().twice().add(3)     ==   add(twice(inc(n)), 3)
```

The sugar is **parasitic on ordinary function semantics**. `x.f(a, b)` does
not ask "what methods does `x` have?". It asks "is there a function `f`
visible here, and would the ordinary call `f(x, a, b)` be valid?". If yes, the
method spelling *is* that call -- the same HIR, the same resolved callable,
the same errors, the same code. If no, it is not allowed. There is no method
declaration, no extension-method syntax, no receiver annotation, no method
table, no search by receiver type, no overload rule of its own, and no
bound-method value.

## What "visible" means: lexical names and imported namespaces

A function is a candidate for `x.f(...)` if it is visible at the call:

* a function or binding of the file established before the call (a function
  may reach itself; nothing is hoisted),
* a parameter or local binding of an enclosing scope,
* a **root native** (`list`, `argv`, `hash`, the operators, ...: the language
  primitives, STDLIB-NAMESPACES.md), which is visible everywhere unless
  shadowed -- all by ordinary lexical resolution (`hir/resolve.tcl`); or
* a **member `f` of a namespace the file directly imports** (IMPORTS.md):
  `import list` makes the module functions (`list::find`) and intrinsics
  (`list::at`, `list::append`, ...) of exactly `list` candidates; `import
  str` those of `str`; `import abi::x86_64` those of `abi::x86_64` -- and
  `import abi` does not make them candidates, nor does an import of a
  module that imports `abi::x86_64`: imports are exact and not transitive.

An import injects no unqualified name: `list::at(xs, 0)` is valid after
`import list`, `at(xs, 0)` is not, and no alias `at = list::at` is needed (or
created) for `xs.at(0)`. Without the import, `xs.at(0)` finds nothing even
though the compiler knows the standard namespace exists: visibility comes
from the file's own header. A bound intrinsic is the very intrinsic: `xs.at(i)`
resolves to the same native target as `list::at(xs, i)`
(`tests/stdlib-namespaces.test` checks the HIR call targets and the NIR are
identical). An old-style binding (`at = list::at`) still works and, being the
same function as the imported one, is one candidate, not two.

### Several candidates

Botlish still has no overloading: every qualified spelling is one exact
function, and a name denotes one binding. But a method name is now looked up in
several places at once -- the lexical scope and each directly imported
namespace -- so two *distinct* functions can both be visible as `f`
(`import alpha`, `import beta`, both with an `f`; or an imported `at` beside a
local `at`). The sugar then applies its one rule to each: **the call is
accepted with the candidate whose ordinary call `f(x, a, b)` is valid**:

* exactly one valid candidate: the call is that one (so with `import list`
  and `import mutable_array`, `xs.at(i)` on a `List` is `list::at` and
  `a.at(i)` on a `MutableArray` is `mutable_array::at`: each rejects the
  other's receiver kind, the same way a declared parameter type or an
  inferred contract rejects it);
* more than one valid: `AMBIGUOUS-METHOD-CALL`, naming the candidates -- no
  precedence of any kind (not import order, not shortest namespace, not
  "local wins", not "standard library wins"); spell the one you mean
  qualified, `alpha::f(x, ...)`;
* none valid: `NO-APPLICABLE-METHOD`, listing why each candidate fails.

"Valid" is checked, not guessed: `hir::buildSyntax` builds the program with
each candidate chosen (`hir::DecideMethodCalls`) and calls a candidate valid
if its call carries no diagnostic of its own -- a declared parameter or
inferred contract the receiver cannot prove, an invalid flag, a native whose
first parameter has a different known kind, ... A declared error nobody
handled is not evidence against a candidate (it is the obligation of a call
that fits). Calls with a single candidate -- almost all -- cost nothing extra.
A candidate that is statically a function of another arity is not a candidate
(unless none is left, which keeps the ordinary arity error).

## Syntax

```
postfix = primary { "(" [ arguments ] ")" | "." IDENT [ "(" [ arguments ] ")" ] }
```

`"." IDENT` immediately followed by `(` is a method call. The argument list is
the one ordinary calls use (newlines inside the parentheses, trailing comma).
`x.f` without `(` is the field projection it has always been; `(x.f)(a)` is
the call of a field value it has always been (the parenthesized projection is
not a method call). A method call is a postfix: it chains left to right with
calls and projections, and binds tighter than unary `-`, `*` and `+`:

```
-x.f()            ==  -(x.f())
a + b.f(c) * d    ==  a + ((b.f(c)) * d)
s.field.f().g(1)  ==  g(f(s.field), 1)
f(x).g()(h)       ==  (g(f(x)))(h)
```

Receivers are any postfix or primary expression: names, literals (`5.inc()`),
calls, list and struct literals, parenthesized expressions, projections and
other method calls. An `if` is a value only as the right side of `=` or
`return` (README.md section 17), so `(if c: a else: b).f()` is not
expressible; bind it first (`v = if c: ...` then `v.f()`).

A method call is also the call of the handled-call form (`r = x.f(1):` +
`on E:` handlers).

## The eligibility theorem

> `x.f(a, b)` is accepted exactly when `f` is a function visible at the call
> and the ordinary call `f(x, a, b)` is valid; it then **is** that call.

Consequences, all by construction rather than by separate rules:

* **Receiver is parameter 1.** It occupies the first argument position and
  nothing else; later parameters are never searched for a match.
* **At least one parameter.** `x.zero()` is `zero(x)`, an ordinary arity
  error. Nothing special rejects it.
* **Types, aliases, refinements, generics, specialization.** Parameter 1
  accepts the receiver under exactly the ordinary call's rules (declared
  parameter types, source-defined refinement types such as
  `type Small = Int in 0..10`, inferred parameter contracts, call-site
  specialization). The sugar neither broadens nor narrows them.
* **The whole call.** Arity, every later argument, declared errors and
  handlers are the ordinary call's. A wrong later argument is reported as the
  ordinary argument error, not as "method unavailable".
* **Result type** is the selected function's result type.
* **Dynamic values.** Botlish's dynamic type is `any` (an untyped parameter's
  type before specialization). A call with an `any` receiver is accepted or
  rejected by exactly the ordinary call's rules -- in particular a declared
  parameter type is *not* proven by the receiver's runtime value, and
  inference of a function's parameter contracts from its body applies to
  `x.f()` as it does to `f(x)`. The sugar never makes a call valid "because
  the runtime value might fit".
* **Function values.** If the visible name denotes a function value (an
  alias, a parameter, a closure), the call is whatever the ordinary call of
  that value is, with the same exact-callable provenance when known.
* **Flags** (FLAGS.md) are part of the ordinary call: `x.f(a, :quiet)` is
  `f(x, a, :quiet)`, the receiver is the first ordinary argument, and the
  supplied flags are validated against `f`'s flag interface after
  normalization (`UNKNOWN-FLAG`, `DUPLICATE-FLAG`, ... point at the flag's
  own spelling). There are no named arguments; variadics (`list`) work
  (`5.list(6, 7)` is `list(5, 6, 7)`).

### Why there is no ranking, and what ambiguity means

Botlish has no overloading. A name denotes exactly one binding; a second
binding of the name in the same scope is the ordinary `DUPLICATE` error, an
inner binding shadows an outer one, and an ordinary call resolves its callee
by that one lookup, never by argument types. There is therefore no set of
candidate callables for `f` in which the sugar could pick a "best method", and
none is built: **zero** candidates is "no function of that name is visible",
**one** is the ordinary call. A call is "ambiguous" only in the one place the
language already gave `x.name(...)` a meaning:

* **Field-vs-function.** `x.cb(a)` has always meant "read field `cb`, then
  call that value" (README.md, STRUCTS.md). If a function `cb` is also
  visible, there are two candidates for the callee. They compete when the
  receiver's static type is a struct with a field `cb` whose value may be
  callable (a callable type, `any`, or unknown). Botlish then picks neither:

  ```
  AMBIGUOUS-METHOD-CALL: method-style call "cb" is ambiguous: the receiver
  (type struct{cb: ...}) has a field "cb" whose value may be callable, and a
  function "cb" is also visible here; write (receiver.cb)(...) to call the
  field, or cb(receiver, ...) to call the function
  ```

  Both disambiguating spellings are ordinary Botlish. A field statically of
  another kind (an `Int`, a `String`) cannot be called, so it is no candidate
  and the function applies. When *no* function `cb` is visible, the call is
  the field-value call it has always been and nothing changed for existing
  programs. The check runs in the generic analysis and in every semantic
  instance (hir/structs.tcl): an untyped receiver is typed by the call that
  supplies it, so `fn g(s): s.cb(1)` called with `{cb: inc}` is diagnosed at
  that call (as a call of `g` with an invalid instance), never silently read
  as a function call. The one remaining case is an untyped receiver for which
  no instance exists; there the field projection was already a static error
  (`UNPROVEN-FIELD`), so no previously valid program changes meaning.

## Normalization: where the rewrite happens

Method eligibility depends on the visible names and on the ordinary call
being valid, but **not** on any type fact to decide the rewrite itself --
Botlish resolves a callee by name, not by argument types. So the rewrite
happens in the earliest stage that has the visible names: HIR resolution
(`hir::resolve::Expr`), the pass that already resolves every reference. The
parser guesses nothing.

1. **Parser** (`surface/parser.tcl`): `"." IDENT "("` builds a `methodcall`
   AST node (receiver, name, name span, arguments). This is the only
   place the spelling exists as such, so the surface AST printer
   (`main.tcl -ast`) shows `(methodcall x f a b)` (the repository has no
   surface-source formatter; this printer is the round-trip pin); the AST has ids
   (`.../receiver`, `.../argN`) and spans like any node. This mirrors the
   `elif` pattern (ELIF.md): the surface remembers the spelling, the semantic
   compiler sees an existing mechanism.
2. **Surface lowering** (`surface/lower.tcl`) writes it as what it has always
   been, a call of the projection `receiver.name`, plus a `method 1` marker
   (`hir::syntax::methodCallNode`). It looks nothing up.
3. **HIR resolution** (`hir/resolve.tcl`, `call` case): the candidates for
   `name` are gathered (`MethodCandidates`): what the same scope walk
   `Lookup` makes finds (without creating anything), and the member `name`
   of every namespace the file directly imports (`hir/imports.tcl`). If
   there is a candidate, the node becomes the ordinary call
   `name(receiver, args...)`: the callee is a real `ref` -- of that name for
   a lexical candidate (so lexical shadowing is exactly the free call's), the
   qualified `ns::name` for an imported one -- a real use (capture, call
   target, call graph) that resolves to the very binding the free spelling
   would, and the receiver is resolved and later evaluated once, as
   argument 1. With several distinct candidates `hir::buildSyntax` decides
   which one (above). If `name` is not visible, the written callee (the
   projection) is kept and the call is the field-value call. Everything
   after this point is the existing call machinery.

The resolved call carries a `method {name nameOrigin}` field. It is read in
exactly one place: the field/function ambiguity check above. No type
inference, lowering, interpreter, Tcl compiler or native pass reads it (the
dictionary key is simply carried).

### Receiver evaluated once; argument order

The receiver is not duplicated by any rewrite -- it is the first element of
the call's argument list, evaluated where the first argument of the free call
is evaluated: `make().f(arg())` evaluates `make()` once, then `arg()`, as
`f(make(), arg())` does. This is tested with an evaluation log
(MutableArray probes) on every backend, including receivers that are method
calls themselves and arguments that are method calls.

### Chaining

A chain is repeated normalization. `x.f(a).g(b, c).h()` is
`h(g(f(x, a), b, c))`: each step independently needs its function visible and
its ordinary call valid; the resolved HIR of a chain and of the nested free
calls are equal (printed text, expression ids included). There is no pipeline
node and no pipeline optimization.

## Source locations and diagnostics

A method call's HIR origin spans the receiver through the closing
parenthesis; the callee reference originates at the method name (node id
`.../method`), the receiver and each argument at their own text. A call
that fails an ordinary check is therefore located as the free call is: a
receiver rejected by parameter 1 (`5.takes_text()`) at the receiver
(`11:1`), a bad later argument at that argument.

| Situation | Diagnostic |
|---|---|
| no function of that name visible (`x.nothere(1)`, a function of a namespace the file does not import, a function defined later) | the existing field diagnostic of the call it falls back to (`NOT-A-STRUCT`, `UNKNOWN-FIELD`, `UNPROVEN-FIELD`) plus: `as a method-style call, no function named "f" is visible here either: method syntax only applies a function that is already visible by that name (define it here, or import the namespace that defines it with `import NAMESPACE`)` |
| receiver rejected by parameter 1, a bad later argument, wrong arity, errors not handled | exactly the free call's diagnostic (same kind and message; locations point at the receiver/argument) |
| a field and a function both candidates | `AMBIGUOUS-METHOD-CALL` (above), at the method name |
| several distinct visible functions, more than one fits the receiver | `AMBIGUOUS-METHOD-CALL` ("more than one visible function accepts the receiver"), at the method name |
| several distinct visible functions, none fits | `NO-APPLICABLE-METHOD`, at the method name, with each candidate's reason |
| shadowing local that is not callable | `NOT-CALLABLE`, as `f(x)` |

The "no function visible" diagnostic does not claim `f` is a declared member of
the receiver's type, and it does not require the receiver's type to have been
imported (it need not be, see below). The existing field diagnostic is what
`x.f(a)` reported before this milestone, so a typo or a missing function
produces the message the programmer already knew, with the missing-visibility
reason appended.

## What the sugar does not need

* **The receiver's type need not be named in the program.** Eligibility is
  decided by the function name and the ordinary call; the receiver's
  already-resolved static type is all that matters. Test: a `Byte`
  (`byte::complement(200)`, a module type never named in source) receives
  `complement` and `high_nibble` after `import byte`, and the chain works.
* **No function declaration opts in.** `fn replace(text, old, new)` is the
  same declaration whether called as `replace(t, a, b)` or `t.replace(a, b)`.
* **No registry, no search.** Resolution starts from the name after the
  period, over the lexical scope and the namespaces the file imported. The
  compiler never searches the program or the libraries for a function "whose
  first parameter has the receiver's type". Test: a `list::any?` accepting
  the receiver exactly (`[1, 2].any?(p)`) is not found without `import list`;
  `byte::complement` is not found for `200.complement()` without `import
  byte`.
* **No import through the type.** Having type `T` does not lead to `T`'s
  module; the file's own `import` is the capability.

## Backend impact

None. After resolution a method call and its free spelling are the same HIR
(printed text equal), lower to the same core IR text, and have the same
analyses (`hir::specialize::analyze`, `hir::range::analyze`,
`hir::escape::analyze`, cardinality, closed-AOT readiness and its explanation,
specialization explanation) and the same NIR, specialized and generic
(byte-identical text; the NIR carries no source locations). The interpreter,
the Tcl compiler and `native/` did not change: there is no method evaluator
and no method operation in NIR. Method spelling does not inhibit closed-call
reasoning, specialization, RawInt, ShortString, construction analysis or
inlining, because those see an ordinary resolved call (their facts are
compared in the tests). Call graphs (exact targets, recursion detection,
closedness) are equal for the same reason; so is use tracking: the callee is a
real reference to the binding, so an imported/bound function used only as
`x.f()` is used (capture sets and call targets are compared). Botlish has no
unused-import lint to change.

## Tests

* `tests/surface-parser.test`: AST shape (receivers, chains, precedence,
  nesting, multiline and trailing comma, handled form, field forms unchanged),
  spans, ids and nine syntax errors.
* `tests/surface-lowering.test`: the lowered syntax; 11 program shapes with
  equal printed HIR, core IR and diagnostics for method and free spelling;
  the call's origins and node ids; the resolved call has no `project` and a
  `ref` callee with the same target and binding; lexical visibility (later
  binding, shadowing local, parameter).
* `tests/method-sugar.test` (114 tests; each program runs on interpreter, Tcl
  compiler, native generic and native specialized, and the standalone
  executable is run as well): basic arities 1..3, receivers of every kind,
  precedence; real library names (`list::at`, `str::substring`,
  `str::lowercase`, `list::append`, `str::concat` bound to names, variadic
  `list`); module functions bound to names
  (`byte::complement`, `byte::from_int` with handlers, `list::find` with a
  predicate); visibility (unbound module function, receiver-type
  non-search, forward reference, struct receiver, nested scopes, recursion);
  aliases (the local name is the method name, the original is not made
  visible); failures identical to the free call's (zero parameters, arity,
  wrong receiver type, wrong later argument, non-callable) with locations;
  types (refinement types both ways, generics, dynamic receivers, a module
  type that is never named); shadowing (local, parameter, function-valued
  parameter, later binding); no overloads; field coexistence (plain access
  unchanged, field call without a function, parenthesized field call,
  ambiguity rejected with both fixes working, a non-callable field not
  competing, ambiguity found in a semantic instance, no bound method values);
  evaluation order and once-only receivers via logs; chains; error parity
  (success, expected error, second error, propagation through `errors`,
  handlers inside chains, unhandled error rejected alike, bad handler names);
  result types; the callee is an ordinary use; call graph; eight program
  shapes with equal HIR, core IR, analyses and NIR (specialized and generic);
  no method trace in NIR; a module that uses the sugar internally; standalone
  executable; a fuzz smoke run.
* `tests/structs-syntax.test`: one expectation changed, deliberately: `x.f(1)`
  prints as `(methodcall (name x) f (int 1))` (it was `(call (project (name x)
  f) (int 1))`; the lowered meaning is unchanged where no function `f` is
  visible).

## Fuzzing

`audit/method-sugar/tools/fuzz.tcl` (`-n N -seed S -dump 1 -backends LIST`)
generates random trees of ordinary calls over a prelude of 24 visible
functions and two aliases (arity 1..4; Int/String/List/Struct results; typed and generic
parameters; a refinement type; an error-capable function whose calls are
handled; probes that log evaluation order; names bound to other functions)
and prints each tree twice: with a random 75% of the calls as method calls
(the others free, so both nest in both directions) and with every call free.
Ordinary call syntax is the oracle: the two spellings must agree on every
backend on value, error code/message (locations removed) and evaluation log,
and the backends must agree with each other. Each program is also paired with
a **negative** program carrying exactly one defect -- hidden module function
(`list::any?` not bound), function defined after the call, a name that exists
only inside another function, wrong receiver type, receiver outside a
refinement type, wrong later argument, too few / too many arguments, zero
parameters, field/function ambiguity -- which must be rejected (for the
visibility defects with the "no function named" reason; for the others
exactly as its free spelling is rejected, or `AMBIGUOUS-METHOD-CALL`).

Results: 300 programs (seeds 1000..1299, 1069 method calls) and 150 programs
(seeds 5000..5149, 477 method calls), every backend, plus one negative program
each: **0 equivalence disagreements, 0 negative escapes, 0 backend
disagreements.** (3 and 5 programs respectively are static `KNOWN-ERROR`/`TYPE`
rejections that both spellings produce identically.) The fuzzer can fail: with
the receiver deliberately moved to the last argument in `hir/resolve.tcl`, 10
programs gave 6 equivalence disagreements and 3 negative escapes.

## Known limitations

* No `import` exists, so a library function is a method only after being bound
  (`find = list::find`). Library functions the corpus would want as methods
  are not made visible by this milestone (the corpus refactor is deferred).
* `(if c: a else: b).f()` cannot be written (an `if` is not an operand);
  bind the value first.
* A call to an unbound name is diagnosed with the existing field-projection
  message (plus the visibility hint), not as an unbound name, because the
  call falls back to the field-value call it had before.
* The field-vs-function ambiguity is decided on the receiver's static struct
  type, in the generic analysis and in each semantic instance (see above). The
  fields of an `opaque struct` (OPAQUE-STRUCTS.md) are not consulted outside its
  owner: they are not method candidates and cannot make a call ambiguous, and `x.f`
  as a field projection is `OPAQUE-REPRESENTATION` there while `x.f()` is still
  the visible function `f`.
* No bound-method values: `g = x.f` is the field projection error it was.
* No method-style *lint* in this milestone: nothing prefers or warns on either
  spelling (METHOD-ELIGIBLE, WARNINGS-METHOD-ELIGIBLE.md, later added the
  one-directional warning).

## Lint policy (implemented later: WARNINGS-METHOD-ELIGIBLE.md)

This milestone planned a default style rule -- "if method syntax is allowed AND
the selected function has more than two declared parameters, prefer method
syntax" -- and an explicit annotation for functions whose receiver spelling
reads badly, both deferred. They arrived as the `METHOD-ELIGIBLE` warning
(a call written functionally whose sugared spelling is *proven* to resolve to
the identical callee, for a function of **at least two** parameters:
`replace(text, old, new)` and `any(xs, p)` warn, `sin(angle)` never suggests
`angle.sin()`) and the `nomethod fn` declaration (the author withdraws
eligibility, and method syntax to that function becomes a resolution error).
Neither changes the semantic rule of this file: legality is exactly the
eligibility theorem above, unary and binary functions remain legal as methods,
and the warning's parameter rule is a property of the warning, not of the
grammar or the resolver. Where this milestone said "more than two", the
implemented rule is "at least two" (the 2-parameter `any(xs, p)` is the
canonical case).

## Required questions

1. **What syntax was added?** `receiver "." IDENT "(" [arguments] ")"` as a
   postfix (parser: `methodcall` AST node).
2. **What is `x.f(a, b)` equivalent to?** `f(x, a, b)`.
3. **Must `f` be imported?** It must be visible: by ordinary resolution (a
   file's function or binding, a root native) or as a member of a namespace
   the file directly imports (`import list`; IMPORTS.md).
4. **Does the compiler search modules/types for an unimported matching `f`?**
   No: only the namespaces the file itself imports, exactly, never their
   parents, children or dependencies.
5. **Must the receiver's type itself be imported?** No.
6. **Must `f` have a special method/receiver declaration?** No.
7. **Must the receiver be accepted as parameter 1 under ordinary type
   rules?** Yes -- it *is* parameter 1 of the ordinary call.
8. **Are ordinary type aliases respected?** Yes (Botlish's only
   alias-like types are source-defined refinement types; they behave as in
   the free call, tested both directions).
9. **Are generic/specialized calls resolved by the ordinary machinery?** Yes.
10. **Does method syntax have its own overload ranking?** No: no ranking and no
    precedence between imported namespaces or against local functions.
11. **What exactly counts as ambiguous?** Two situations: a visible function
    `f` and a struct receiver whose field `f` may be callable (`x.f(a)` has
    always meant the field call); and several distinct visible functions `f`
    (lexical, or members of different imported namespaces) for which the
    ordinary call with the receiver is valid.
12. **What happens when no imported callable is valid?** If no function `f`
    is visible: the call is the field-value call, whose ordinary diagnostic
    (`NOT-A-STRUCT`/`UNKNOWN-FIELD`/`UNPROVEN-FIELD`) is reported with the
    visibility hint. If exactly one function is visible but `f(x, ...)` is
    invalid: exactly the free call's diagnostic. If several are visible and
    none fits: `NO-APPLICABLE-METHOD`.
13. **What happens when more than one ordinary callable remains valid?**
    `AMBIGUOUS-METHOD-CALL`, naming the candidates (or, for a field and a
    function, both disambiguating spellings).
14. **Can unary functions use method syntax?** Yes, if otherwise eligible
    (`n.inc()`).
15. **Can binary functions use method syntax?** Yes, if otherwise eligible.
16. **Is the future "> 2 parameters" rule part of semantic legality?** No.
17. **Is that linter implemented now?** Not by this milestone; see "Lint policy" (METHOD-ELIGIBLE).
18. **Are bound method values such as `x.f` introduced?** No.
19. **Is the receiver evaluated once?** Yes, as the first argument.
20. **Do method and ordinary syntax have identical error behavior?** Yes
    (same call, same HIR).
21. **Do method calls count as uses of the imported function?** Yes: the
    callee is a real reference to the binding.
22. **Is the call graph identical?** Yes.
23. **Does downstream HIR retain a method abstraction?** No; the resolved call
    is an ordinary `call`. (A `method {name nameOrigin}` field on the call is
    read only by the field/function ambiguity check.)
24. **Did interpreter semantics change?** No.
25. **Did native/NIR gain a method-call operation?** No; `native/` is
    untouched.
26. **Do representative method/free pairs produce equivalent HIR and NIR?**
    Yes (byte-identical).
27. **Does chaining work purely by repeated ordinary-call normalization?**
    Yes.
28. **Are existing struct/member accesses unchanged?** Yes: `x.field`,
    `(x.field)(a)` and `x.field(a)` with no visible function `field` are as
    before; the new rejection is only the genuinely ambiguous field-call plus
    visible-function case.
29. **Did equivalence fuzzing find any disagreement?** No: 450 generated programs (and as many negative programs) agreed on every backend.
30. **Did the full regression pass?** Yes: `tclsh9.0 tests/all.tcl` -- interpreter 4276 passed / 0 failed; compile backend 4272 passed, 4 skipped (existing backend constraints), 0 failed. The native backends run inside the tests (and the standalone-executable test).
