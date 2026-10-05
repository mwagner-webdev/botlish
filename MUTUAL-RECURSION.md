# Mutual recursion: `mutual:` groups

**Status: design, not implemented.**

STRICT-REFERENCE-DETERMINISM.md made every binding visible only from its
definition onward. It left mutual recursion to "a future explicit
mechanism". This is that mechanism: a `mutual:` group declares, at a module's
top level, a set of functions whose bodies can all see each other.

```botlish
mutual:
    fn is_even(n) -> bool:
        if n == 0:
            return true
        is_odd(n - 1)

    fn is_odd(n) -> bool:
        if n == 0:
            return false
        is_even(n - 1)
```

Everywhere else, the strict reference rule is unchanged.

## Motivation

Compiler-shaped code is mutually recursive by nature. A pass over a recursive
structure is a set of functions that call each other (`gen_expr ↔ gen_block`,
`check ↔ infer`, `eval ↔ apply`). The Tcl implementation of Botlish shows the
cycle sizes a self-hosted port would meet:

| file | procedures in mutual-recursion cycles |
|---|---|
| `native/lower.tcl` | 36 of 190, one SCC: `Expr`, `Call`/`CallInner`/`CallArgs`, `If`, `Bind`, `Sequence*`, the loop forms, `Struct`/`Project`, `VirtualValue`, `PlanPieces`/`ConstructPieces`, ... |
| `hir/types.tcl` | about 30 (the inference walker and the type lattice) |
| `compiler/compiler.tcl` | 15 (`CompileExpr`, `CompileIf`, `CompileCall`, `CompileBlock`, ...) |
| `hir/completions.tcl` | 12 |

`native/lower.tcl` also has three cycles that bypass its `Expr` hub (virtual
values through `If`/`Call`, call arguments in field form, virtual
construction pieces). Passing one function as an argument would therefore not
be enough. You would need four entry points, threaded through about 36
functions. The two workarounds that work today are passing functions as
arguments and late binding through a top-level `MutableArray` cell. Neither
scales to that size, and both hide the call targets the specializer needs.

## Syntax

```
topStatement = typeDecl | structDecl | errorDecl | mutualGroup | statement
mutualGroup  = "mutual" ":" NEWLINE INDENT { NEWLINE | function } DEDENT
```

* `mutual` is a **contextual word**, like `opaque`, `nomethod`, `flags` and
  `import`. It starts a group only as the first token of a top-level
  statement, followed directly by `:` and a newline. That form is a syntax
  error today (`expected end of line, found ":"`), so no existing program
  changes meaning. `mutual` stays an ordinary name everywhere else
  (`mutual = 1`, `fn mutual(x):`, `x.mutual`).
* **Members** are two or more `fn` declarations. Each may carry `nomethod`.
  Blank and comment lines are allowed between them. Nothing else is: no
  value bindings, no `type`/`struct`/`error` declarations, no imports, no
  nested group, no expression statements.
* **Every member declares its result type** (`-> T`). This is a syntax
  requirement, for the reasons in "Why every member declares its result
  type" below. Parameters may stay untyped. `errors` clauses work as for any
  function: they are already explicit.
* **Placement:**
  * A group may appear only at the top level of a file. This is the
    parser's `topLevel` flag, the same check `type`, `struct` and `error`
    declarations use.
  * The file must be a module (loaded by `import`), not the entry program.
    This is checked where module-ness is known (`surface/modules.tcl` /
    `hir::isModuleScope`); see "Why module top level only" below.

Rejected forms:

| Source | Diagnostic |
|---|---|
| `mutual:` inside a function, `if`, `loop` or handler | syntax error: a mutual group is only allowed at the top level of a module |
| `mutual:` at the entry program's top level | semantic error `MUTUAL-PLACEMENT`: a mutual group is only allowed in a module |
| a member without `-> T` | syntax error: a function in a mutual group must declare its result type |
| `x = e`, `type`, `struct`, `error` or another `mutual:` inside a group | syntax error: a mutual group contains only function declarations |
| a group with one member | syntax error: a mutual group needs at least two functions (one function already sees itself) |
| `mutual:` with no indented block | the ordinary `expected an indented block` |

## Semantics

The amended visibility rule (STRICT-REFERENCE-DETERMINISM.md, "Semantic
rule"):

> Bindings are visible from their definition onward, except that the members
> of a `mutual:` group are visible from the start of the group. Every
> member's body, including functions nested in it, may refer to every member
> of its group. Code before the group sees none of them. Code after the group
> sees all of them as ordinary bindings.

* **Members are ordinary module bindings in every other respect.** The
  following all apply unchanged:
  * the section scope's `DUPLICATE` rule, among members and against the
    module's other bindings;
  * qualified access from other files (`ns::is_even`), with the group
    invisible outside the module;
  * method sugar, aliases (`g = is_even` after the group), flags and
    `nomethod`.
* **Only functions can be members, because only functions are safe.** A
  function's body runs only when it is called, and the group calls nothing
  while its members are being established. So no member can be observed
  before it exists. A value member would run its initializer during the
  group, and that initializer could call a member whose own references are
  not yet established. That is exactly the use-before-initialization the
  strict rule rules out.
* **The group runs no code.** It establishes its members in source order. A
  module value initializer after the group may call any member. One before
  the group cannot name them, as today.
* **Recursion depth.** A tail call to another member is an ordinary call,
  exactly as "Other calls, including tail calls to other functions, are real
  calls" says for today's code (README §20). Only self tail calls become
  loops. Deep mutual recursion is bounded by the stack (`NATIVE LIMIT STACK`
  natively), like deep self recursion.

## Why module top level only

* **Module top-level functions capture nothing.** A module binding is a
  module static and never enters a function's capture set
  (MODULE-STATIC-RETAINED-VALUES.md; `hir/resolve.tcl`'s capture walk;
  `native/lower.tcl` `Access`). The consequences:
  * Group members reach each other as module statics, not captures.
  * Native code treats them as environment-free functions, so a call within
    the group is a direct `call` by target.
  * No closure holds another member's closure, and no cell or shared
    environment is needed.
* **Entry-program and local functions do capture.** An entry-program
  top-level function can capture earlier program bindings (a top-level
  `MutableArray` cell, for example), and a function in a function body
  captures its enclosing locals. Members of such a group would capture each
  other: a cyclic closure environment.
  * That needs either cells, which STRICT-REFERENCE-DETERMINISM.md removed
    from lowering (the runtime's cell object is unused), or a shared group
    environment record. Either is a new runtime and NIR representation.
  * Deferred (see "Later").
* **The cost for programs is small.** The mutually recursive core of a
  program lives in a module (`lib/NAME.bot`), which is where reusable code
  lives anyway.

## Why every member declares its result type

**Forward references were removed because of determinism.** Before
STRICT-REFERENCE-DETERMINISM.md, a reference to a not-yet-analyzed function
was typed `{block E ARITY any}` (`ForwardType`). The erased result made the
caller-before-callee source order of `csv_records.bot` produce more of
everything than the callee-first order:

| measure | callee-first | caller-before-callee |
|---|---|---|
| codegen instances | 66 | 90 |
| guards | 28 | 56 |
| emitted functions | 63 | 85 |

"Later definitions were repairing information earlier stages did not have."

**A group necessarily walks some caller's body before a callee's.** A
declared result type is what keeps that from reintroducing the problem.
* Before any member's body is walked, every member's binding already has its
  exact type `{block E ARITY T}`, with T the declared result.
* That is the shape a named function's self-binding gets today
  (`hir::types::Block`'s `selfType`), except that the result is the
  declaration rather than an assumption.
* Nothing is erased to `any`, so what a member's body is analyzed against
  does not depend on member order.

**Required property, as a regression test:** permuting the members of a group
changes none of the following:
* semantic instances;
* specialization instances;
* guards;
* AOT classification;
* NIR, except function numbering, which follows block position.

This is the definition-order experiment of STRICT-REFERENCE-DETERMINISM.md,
run as a test.

The rest of the signature needs nothing new:
* **Error sets are already declared syntactically.** A call's effective
  errors are never larger than the callee's declared signature
  (`hir/errorsets.tcl`), and proofs only remove errors. So nothing about
  errors is inferred across the cycle.
* **Parameters can stay untyped.** Instance cycles through argument types
  already exist: self recursion across keys, and functions passed to each
  other (`ping(pong, ...)`, test `si-rec-2b`). `hir::semantic` and
  `hir::specialize` resolve them with their existing worklists. README §21
  reports `even<int>` ↔ `odd<int>` and `a → b → c → a` reaching a fixpoint
  with one instance per function.

**Alternative not chosen:** inferring results across the group. That would
generalize the self-binding's three-attempt loop to an SCC fixpoint in the
frontend. It is possible later. It would add a fixpoint for convenience only,
and it reopens order dependence that the declaration closes.

## Implementation sketch

Like `elif` and struct destructuring, the group should disappear early.
After resolution its members are ordinary `bind`s of block literals in the
module section. The group's only lasting trace is one side table, which the
invariant checker and type seeding read.

**`surface/lexer.tcl`.** Nothing: `mutual` is contextual.

**`surface/parser.tcl`**
* An `AtMutualGroup` test in the top-level dispatch, like `AtStructDecl`.
* The member, placement and result-type checks above.
* A `mutual` AST node holding the member `function` nodes.
* Node ids: the group's id is `mutual` (`mutual#2`, ... when repeated).
  Members keep their ordinary top-level `NAME()` ids. Names are unique in
  the scope, so wrapping existing functions in a group does not renumber
  anything.

**`surface/lower.tcl`.** Each member lowers to the usual
`bind f (block ...)`, wrapped in one HIR-syntax `mutual` form that only the
resolver reads.

**`hir/resolve.tcl`**
* At a `mutual` form, first take, for every member in source order, the
  pre-body steps the `bind` case already takes for a function:
  * `Establish`;
  * `hir::flags::DeclareFunction`;
  * the `nomethod` mark.
* Then resolve each member's block in source order.
* Replace the form with its member binds in the section sequence.
* Record `mutualGroups`, GroupId → member BindingIds, plus `group G` on each
  member binding.
* Capture lists do not change, because module statics are not captures.
* The "declared later" hint (`LaterNames`) can name the group when code
  before it references a member.

**`hir/refcheck.tcl`.** The invariant gains one exception: a reference from
inside a member's body to a member of the same group. `hir::format` prints
the group. `hir::read` support can follow HIR text's support for module
sections, which it does not carry today.

**`hir/types.tcl` / `hir/semantic.tcl`.** On reaching a group in the section
walk, before walking any member body:
* Seed every member binding with its exact block type: arity, declared
  result, declared parameter contract.
* Record every member's creation environment. It is empty, since module
  functions capture nothing.

Without the seeding, a call to a later member would fall back to
`BindingType`'s final `return any`, which is `ForwardType` again. Without
the recorded environments, an instance request for a member not yet created
would take the `no-env` decline and the whole-program re-walk. Each member's
own self-binding keeps today's attempt loop.

**Analyses with recursion-specific handling, to re-audit against real groups**

| file | what to check |
|---|---|
| `hir/specialize.tcl` | discovery on the spot (`nestLimit` 32), newest-first worklist, `CloseCallers` rounds |
| `hir/rangerec.tcl` | self-recursive result summaries (SELF-RECURSIVE-RESULT-RANGES.md); a group member gets none and falls back to its declared result's range, which is sound |
| `hir/completions.tcl` | per-call callee re-analysis, `guard` cycle set, `maxAnalyses` 256 |
| `hir/exactvalue.tcl` | the step budget |
| `hir/escape.tcl` | recursion without a base case declines |
| demand propagation over call edges (`hir/stringregion.tcl`, `hir/traversal.tcl`, `hir/construction.tcl`) | these are fixpoints and should handle cycles |
| `native/lower.tcl` tiny-leaf inlining | needs a check |

These analyses already meet cycles through arguments, so the expected
outcome is "no change". That should be verified, not assumed.

**Backends.** No change is expected; verify each.
* **Interpreter:** it runs the core IR that HIR lowers to. There the group
  is sequential binds in one scope, and the interpreter's scopes declare
  names on entry, so closures see later bindings (README §2).
* **Tcl compiler:** it compiles from HIR. Members are module statics read
  after the group has established them.
* **Native:** members are environment-free module functions called by
  target. No NIR, codegen or runtime change.

**Diagnostics.** The syntax errors in the table above, and the one semantic
code `MUTUAL-PLACEMENT`. There is no new warning.

## Tests to add

* **Resolution:**
  * members see each other, including from functions nested in a member;
  * code before the group gets `UNBOUND`, with the hint;
  * code after the group sees every member;
  * `DUPLICATE` between members, and against other module bindings;
  * qualified access from another file;
  * method sugar and aliases after the group;
  * flags and `nomethod` on a member called from an earlier member.
* **Syntax:** every row of the rejection table. `mutual` still works as an
  ordinary name.
* **Determinism:** member permutations give the identical facts listed in
  "Required property".
* **Backend parity:** interp, compile, cranelift and cranelift-generic on
  even/odd and on a three-member cycle with untyped parameters. AOT `closed`.
  A standalone executable.
* **Corpus:** byte-identical NIR for the canonical programs, none of which
  uses the construct.
* **Example:** `examples/surface/09-mutual-recursion.bot` stays the
  entry-program rejection example; it is the program shape a group does not
  cover. Its comment should point here. Add a module example; tests create
  modules in a scratch `$::core::libraryDir`, as `tests/surface-modules.test`
  does.

## Later (not part of this design)

* Groups in function bodies and at the entry program's top level. These need
  a cyclic closure environment.
* Mutually recursive `struct` declarations under the same `mutual:` keyword.
* Result-type inference across a group.
* Tail calls between members as jumps.
* Values in groups, hoisting, forward declarations or prototypes. All of
  these are rejected as designs, not deferred.

## Open questions

* Should a group whose members do not actually reach each other be rejected,
  or warned about? The resolved reference graph would make that a compiler
  proof. The proposal is to accept it: the group declares visibility, not a
  call graph, and legality should not change when a call is edited away.
* Should the one-member rejection be a warning instead? The proposal is an
  error, since the group would mean nothing.
