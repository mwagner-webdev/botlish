# Explicit error completions: `error`, `errors`, `fail`, `handle`

## Outcome

Botlish had a semantic hole: a source-defined refinement type (e.g. `Byte`)
used a callable constructor syntax, `Byte(x)`, that raised an **undeclared**
runtime completion (`{CORE SEMANTIC RANGE}`) whenever `x` could not be
proven statically safe. That violates this project's own invariant:

> known failure -> compile-time rejection; unknown failure -> declared
> runtime error completion; **never** an undeclared one.

This milestone closes that hole by making runtime-checkable failure a
first-class part of the language, not a native's own implicit side channel:

- `error NAME` -- a top-level error declaration, in a single flat,
  program-global namespace (mirroring `hir/sourcetypes.tcl`'s own
  precedent for source-defined types).
- `fn f(...) -> T errors E1, E2:` -- a function signature declares which
  named errors a call to it may produce, in addition to its ordinary
  parameter/result types.
- `fail NAME` -- a production statement: this function completes right now
  by raising the declared error `NAME`. Never a value; always an abrupt
  completion, exactly like `return`/`break`/`continue`.
- `result = f(x): on E1: ... on E2: ...` -- a call-site handled form: each
  `on` clause supplies a completion (an ordinary value, an early `return`,
  or a re-`fail`) for one named error the call may produce. Errors not
  named by an `on` clause propagate, and must be admitted by the enclosing
  function's own `errors` declaration (or, again, re-declared upward).

Static legality (`hir/errorsets.tcl`, run unconditionally before any
backend executes):

```
calleeErrors(call) - handledErrors(call)  subset-of  enclosingDeclaredErrors
```

Implemented identically, with matching results, on **all four backends**:
the `interp` tree-walker, the `compile` Tcl-codegen backend, and both
native (Cranelift) backends, `cranelift-generic` and `cranelift`. The old
callable refinement-type constructor syntax (`Byte(x)`, `Nibble(x)`, ...) is
removed from the language entirely; `core::type::declareIntConstructor`
now only registers the type's membership predicate, nothing callable.
`byte::from_int(value) -> Byte errors BelowRange, AboveRange:` is the new,
explicit, fallible conversion `lib/byte.bot`'s own `byte::set` and
`lib/web.bot`'s module init and `esc_char` are migrated to use.

Full regression, native/Cranelift parity, and GC stress are reported below
under "Full regression / GC stress".

## Why not `Result[T, E]`

Not used, and deliberately so. A `Result[T, E]` value would be an ordinary
*data* value flowing through bindings, arguments and returns like any
other -- every caller would need to pattern-match/unwrap it explicitly, a
whole payload/destructuring feature this milestone's brief explicitly
forbids, and it would blur the same "abrupt completion vs. ordinary value"
line `return`/`break`/`continue` already keep sharp. This project already
has a completion architecture (`core/completion.tcl`: `value`/`return`/
`break`/`continue`) built exactly for "control leaves this point of the
program via a channel other than its own local value" -- `propagate-error`
was already reserved there (unused, until this milestone) as a fifth
completion kind for precisely this. Reusing it means `fail` costs the
language nothing structurally new: it is threaded through
`core::evaluator.tcl`'s tree-walker, `compiler/compiler.tcl`'s Tcl
completion codes (extended with a new code `5`), and the native backend's
own `Vm.error`/`check()`/`error_exit` machinery the same way `return`
already is, rather than inventing a second, parallel value-shaped error
channel next to it.

## Semantic model

An error is a **completion**, never a value:

- `fail NAME` yields `core::completion::propagatingError` carrying a
  `core::value::errorId` (a new, distinct value kind -- `{errorId NAME}` --
  never conflated with `str`, matching the project's own "tags must not
  blur" convention; it exists only transiently, as a handled-call's own
  dispatch key, and is never itself observable as an ordinary value: no
  operator or native accepts one).
- `handle` intercepts a `propagate-error` completion whose payload's name
  matches one of its own `on` clauses, converts it into an ordinary
  completion (the handler body's own outcome: a value, a `return`, or a
  re-`fail`), and otherwise re-propagates the original completion
  unchanged.
- Everywhere else in the language (an unhandled call, a call inside a
  function that itself declares the same errors), a `propagate-error`
  completion simply propagates outward through ordinary control flow --
  `core::completion::atCallBoundary`/`atProgramBoundary` already handled
  this correctly once `propagate-error` existed, because they treat it
  exactly the way `return` is treated when it reaches a boundary that
  isn't its own target.

## Syntax choices

- **Flat, program-global error namespace** (`hir/errordecls.tcl`, mirroring
  `hir/sourcetypes.tcl`): an `error NAME` declaration is visible everywhere
  in the compiled program, not scoped per-module or per-function. This
  matches how source-defined *types* already work in this codebase, and
  keeps a function's own `errors E1, E2` clause a simple name list rather
  than a set of qualified references.
- **Single-line `errors E1, E2` clause** on the function signature line,
  parsed the same way `-> T` already is (both gated by the same
  `allowResult` parser flag), rather than a separate declaration block --
  keeps a fallible function's full contract (parameters, result, possible
  errors) on one line, at the same syntactic weight as its result type.
- **`fail NAME` as its own statement kind**, not an expression -- it is
  never a value (see "Semantic model" above), so giving it expression
  syntax would misleadingly suggest it produces one. This mirrors `break`/
  `continue`/`return`'s own statement-level status.
- **Call-site handling only on a bare `call` node**
  (`hir::syntax::handleNode`'s own shape check; `surface/parser.tcl`'s
  `ValueOrHandled`): `f(x): on E1: ...` requires the handled expression to
  literally be a call, the same restriction this codebase's own `if`
  grammar already places on itself ("`if` is a value only as the whole
  right side of a binding/return/break, never a nested expression" --
  `surface/parser.tcl`'s own grammar comment) -- consistent, not a new
  restriction invented for this feature. A handled call therefore cannot
  be nested inside another call's own argument list or a list/collection
  literal; it must be bound to a name (or directly returned) first, same
  as `if`.

## Propagation rule (the static legality check)

`hir/errorsets.tcl::verify` walks every `block` (function body) and the
top-level program body once, each under its own enclosing declared-errors
set (`{}` for the top level -- it declares none). For every `handle` node
it finds:

```
remaining = calleeErrors(call) - handledErrors(call)
```

and requires `remaining subset-of enclosingDeclaredErrors`, raising a
static `UNHANDLED-ERROR` diagnostic (`hir::Diagnose`, before any backend
ever runs) for each name in `remaining` that fails admission. `fail NAME`
itself is separately checked at resolution time
(`hir/resolve.tcl`): `NAME` must be a declared error (`UNDECLARED-ERROR`
otherwise) and must be in the *directly* enclosing function's own `errors`
set (`UNHANDLED-ERROR` otherwise) -- a function cannot `fail` an error it
does not itself declare, even if some caller further up would have
admitted it.

`calleeErrors` (`hir/types.tcl`'s `Call`) is populated only when a call's
target resolves to an exact `{block ExprId}` -- i.e. only for a call whose
callee is statically known to be a specific function body, never an erased/
unknown target. This is sound because `hir/callables.tcl`'s own `Bearing`
check (widened by this milestone to also flag a non-empty `declaredErrors`)
already rejects erasing an error-bearing function to an opaque callable
value; a function that declares errors can never become a value whose
static target is unknown, so `calleeErrors` is never silently lost through
indirection.

This is a **flow-insensitive, signature-based** check: it never narrows a
callee's declared error set based on a specific call site's own argument
facts (e.g. it does not attempt to prove "`byte::from_int(45)` can never
actually reach `fail BelowRange`, so this particular call site doesn't need
an `on BelowRange` handler"). See "Static known-failure elimination:
explicitly not implemented" below.

## Handler typing

`hir::errorsets::CheckHandle` requires each live `on NAME` handler body's
own completion type to be **admissible** as the call's own normal result
type, via the same proof machinery (`hir::range::ProvesValueAcceptedBy`)
STRICT-TYPED-PARAMETERS.md's declared-parameter/declared-result-type checks
already use -- not a separate, ad hoc rule invented for handlers. A
provably in-range literal handler body (`on BelowRange: 0`, where the call
returns `Byte`) is therefore accepted the identical way a bare literal
argument already is against a declared `Byte` parameter; a handler body
whose type cannot be proven admissible (wrong type, or a container type
that fails this language's pre-existing element-invariance rule -- see
"Module initialization" below) is a static `TYPE` diagnostic. A handler
body reachable via `never` (e.g. it itself unconditionally re-`fail`s) is
exempted from this check (there is no completion type to admit).

## Top-level closure

The top level's own enclosing declared-errors set is `{}` (empty) --
`hir/errorsets.tcl::verify`'s own `block eq {program}` case. A fallible
call reaching top level completely unhandled is therefore always a static
`UNHANDLED-ERROR`, never something that runs and produces a runtime
completion at the program boundary. (`core/completion.tcl`'s
`atProgramBoundary` still has a real, reachable path to an *uncaught*
propagate-error completion -- `CORE SEMANTIC UNCAUGHT-ERROR` -- but only by
deliberately compiling with relaxed diagnostics (`-strict 0`) and running
the result anyway, exactly the way `tests/byte-set.test`'s own
`moduleErrorKinds` helper does to observe cross-backend runtime agreement;
an ordinary `-strict 1` compile never reaches it.)

## HIR representation

Errors are ordinary HIR expression kinds, not a parallel subsystem:

- `hir/errordecls.tcl` -- the flat error-name registry (mirrors
  `hir/sourcetypes.tcl`).
- `fail` -- `hir::syntax::failNode`; fields `name`. Typed `never`
  (`hir/types.tcl`) -- it never produces a value.
- `handle` -- `hir::syntax::handleNode`; fields `call` (must be a `call`
  node), `handlers` (`{name nameSpan origin body}` per `on` clause). Its
  own static type is the call's own normal type when that isn't `never`,
  else the `lub` of every handler body's own type (`hir/types.tcl`'s
  `Handle`).
- `core/ir.tcl` shapes: `(fail NAME)`, `(handle CALL-EXPR NAME1
  HANDLER-BLOCK1 NAME2 HANDLER-BLOCK2 ...)`.
- Text round-trip (`hir/format.tcl`/`hir/read.tcl`): an `error NAME`
  declaration line; an ` errors E1, E2` suffix on a block's own line; `fail
  NAME` and `handle`/`on NAME` expression lines. `calleeErrors`/
  `handlerTypes` are not re-derived by the reader (matching `hir/read.tcl`'s
  existing philosophy of not re-running analysis passes on read-back HIR);
  they default to safe placeholders.

## Cross-module signatures

A library module's own `error` declarations and `errors`-bearing function
signatures are visible from a separate calling file through the ordinary
module system (`surface/modules.tcl`): `LoadNamespace`/`LoadNamespaces`/
`compileProgramFile` all thread `errorDecls` alongside the pre-existing
`typeDecls`, merged into the same flat, program-global namespace
`hir::errordecls::apply` maintains. The static legality check therefore
applies identically to a cross-module call as to an intra-file one --
confirmed directly in `tests/errors.test`'s own
`errors-cross-module-signature`/`errors-cross-module-unhandled-rejected`.

## Callable-type-syntax removal

`core::type::declareIntConstructor` (`core/type.tcl`) now only calls
`definePredicate` (the type's `NAME?` membership predicate); it no longer
calls `core::native::register`, so a source-defined refinement type has no
callable form at all. `Byte(5)` is now simply an unbound-name reference
(`CORE SEMANTIC UNBOUND`), pinned directly by `tests/errors.test`'s
`errors-callable-syntax-removed`. `core::type::CheckedConstruct` (the old
callable constructor's own generic Tcl implementation) and its one
remaining caller in `native/lower.tcl` are left in place, unmodified, per
this milestone's own scope guidance -- both are dead code now (nothing
registers a native whose `-impl`/`-native-body` is
`{core::type::CheckedConstruct NAME}` any more), kept rather than deleted
to minimize blast radius on code outside this milestone's own stated
scope.

## `byte::from_int` / `byte::set` / `web.bot` migration

`lib/byte.bot`:

```botlish
fn from_int(value) -> Byte errors BelowRange, AboveRange:
    if value < 0:
        fail BelowRange
    else:
        if value > 255:
            fail AboveRange
        else:
            value
```

`value` is deliberately **untyped**. A declared `value: int` parameter
would require STRICT-TYPED-PARAMETERS.md's own static-proof admissibility
at every call site (never a runtime check for a *declared* parameter type)
-- which would break exactly the call shapes this function exists to
serve, e.g. `byte::from_int(list_get(bytes, 0))`, where the argument is
dynamically always an `int` but not statically provable as one. Leaving
`value` untyped relies on the same ordinary dynamic kind-checking every
other untyped Botlish function's `<`/`>` operators already do.

`byte::set` (`lib/byte.bot`):

```botlish
fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte] errors BelowRange, AboveRange:
    bytes = loop c in chars:
        from_int(char::codepoint(c))
    immutable_set_from_list(bytes)
```

`set` re-declares both errors and does not handle them itself -- ordinary
propagation, exactly as `hir/errorsets.tcl`'s rule allows: `from_int`'s
call is unhandled inside `set`'s own body, but `set`'s own `errors
BelowRange, AboveRange` admits it.

`lib/web.bot`'s module init and `esc_char` handle explicitly at the call
site (see "Module initialization" below for the module-init case
specifically):

```botlish
b = byte::from_int(list_get(bytes, 0)):
    on BelowRange:
        0
    on AboveRange:
        0
```

unreachable in practice (`list_get(bytes, 0)` is always one ordinary
0..255 UTF-8 byte here), but, per this milestone's own scope (see "Static
known-failure elimination" below), never statically discharged -- the
handler stays, exactly the same shape `ascii::`'s own strict-typed-
parameter contract already required elsewhere in this file.

## Module initialization ("Outcome B") and the invariant-container fallback

`lib/web.bot`'s `additional_unreserved_chars = byte::set([...])` is a
*retained module-scope binding* (`hir/modulebinding.tcl`,
MINIMAL-IMMUTABLE-SET.md/BYTE-SET.md): it must be proven both
context-free and structurally immutable at compile time, once, so it can
be built at program startup and reused by every call rather than
reconstructed. Since `byte::set` now declares two possible errors, this
binding's own initializer has to be a **handled** call (**Outcome B**:
handle explicitly at the module-init site, chosen over silently widening
`byte::set`'s own contract or forbidding fallible calls from module
init entirely) -- with an unreachable-in-practice fallback for each named
error, since `'-'`, `'.'`, `'_'`, `'~'` are of course always in `Byte`'s
domain.

Getting this to type-check surfaced a real, useful fact about this
codebase's own pre-existing container typing: `ImmutableSet[T]`/`List[T]`
are **invariant** in `T` (MINIMAL-IMMUTABLE-SET.md), so
`immutable_set_from_list([])`'s own inferred type,
`ImmutableSet[never]` (an empty list literal's element type infers to the
bottom type `never`), is **never** admissible as this binding's declared
`ImmutableSet[Byte]` -- not a bug, the same invariance rule
`tests/immutable-set.test`'s own `set-construct-empty` already documents
independently ("satisfying no `ImmutableSet[T]` parameter under initial
invariance"). The fallback therefore has to be a genuine, one-element
`ImmutableSet[Byte]`, built from an actual (equally unreachable-in-
practice) `byte::from_int(0): on ... on ...` conversion:

```botlish
additional_unreserved_chars = byte::set(['-', '.', '_', '~']):
    on BelowRange:
        placeholder = byte::from_int(0):
            on BelowRange:
                0
            on AboveRange:
                0
        immutable_set_from_list([placeholder])
    on AboveRange:
        placeholder = byte::from_int(0):
            on BelowRange:
                0
            on AboveRange:
                0
        immutable_set_from_list([placeholder])
```

This in turn required a real fix to `hir/modulebinding.tcl`'s own
context-free/immutability proof (`ImmutableExpr`), not just to `web.bot`:
proving a module-scope binding's initializer immutable requires *inlining*
the callee's own body with the call's concrete argument facts
(`ImmutableBlockCall`, the same mechanism that already lets
`byte::set(['-', '.', '_', '~'])` prove retainable at all), and that walk
reaches `from_int`'s own internal `fail BelowRange`/`fail AboveRange`
nodes. Previously, any `fail` reached this way made the *whole* proof
`bad` (an unconditional "no retainable value" failure) -- unconditionally,
regardless of whether that branch is actually reachable for the concrete
facts in hand, because this pass, like `hir/errorsets.tcl`, deliberately
never does flow-sensitive branch elimination. The fix adds a third proof
status, `diverge` (distinct from `ok`/`bad`), for exactly this case: a
`fail` completion contributes no value of its own to a merge, so an `if`'s
or a `handle`'s own branch-merge (`MergeDivergentProofs`, next to the
pre-existing `MergeBranchProofs`) simply drops a diverging side and keeps
the other, rather than requiring *every* transitively-reached `fail`
inside an inlined callee body to itself carry a retainable value (which it
never can, by construction -- a `fail` is a completion, never a value).
Soundness of this relaxation rests entirely on `hir/errorsets.tcl`'s own,
completely separate, already-complete static proof that every `fail` this
pass encounters is legitimately handled or re-declared somewhere;
`hir/modulebinding.tcl` only needed to stop mistaking "diverges" for
"unprovable".

## Static known-failure elimination: explicitly not implemented

This milestone does **not** attempt to statically prove a specific `fail`
production unreachable for a specific call site's own argument facts (e.g.
narrowing away `byte::from_int(45)`'s two `fail` branches because `45` is
a compile-time-provable in-range literal) and eliminate the corresponding
`on` handler requirement. Every fallible call site handles (or re-declares)
every one of its callee's declared errors, unconditionally, even where the
concrete value in hand makes a particular error provably unreachable (see
`byte::from_int(45)`'s call sites throughout `lib/web.bot`, and the module-
init fallback above, all of which carry handlers for branches that can
never actually run). This is the explicitly permitted scope boundary
(the original brief's own item 82): the propagation/handling *mechanism*
is the deliverable here, not a dead-branch optimizer for it. The one place
this milestone *did* have to reckon with a `fail`-containing branch that
*is* provably dead for concrete facts -- `hir/modulebinding.tcl`'s own
context-free-inlining proof, above -- was solved without doing any such
elimination: `diverge` merges away an unreachable branch's own value
requirement without ever asking whether that branch is *reachable*, which
is a different, narrower question than "does this specific error ever
actually fire here" and does not reintroduce the forbidden optimization.

## Backend lowering: all four backends

- **interp** (`core/evaluator.tcl`): `op-fail` returns
  `core::completion::propagatingError`; `op-handle` evaluates the call,
  and on a `propagate-error` completion whose payload name matches one of
  its own handlers, evaluates that handler's body in a fresh branch scope;
  otherwise re-propagates the original completion unchanged.
- **compile** (`compiler/compiler.tcl`): `fail` compiles to `return -code 5
  [Word ERRORID]` (Tcl completion code `5`, newly reserved alongside the
  pre-existing `0`-`4`); `CompileHandle` isolates the wrapped call's own
  emitted lines inside a Tcl `catch`, switches on the caught error's own
  name, and `return -options`-re-propagates anything it doesn't recognize
  -- the same general shape `CompileIf`'s own scope handling already uses.
- **cranelift-generic and cranelift** (`native/lower.tcl`,
  `native/src/codegen/clif.rs`, `native/src/runtime/ops.rs`): six new NIR
  instructions (`Fail`, `DeclaredErrorEq`, `ClearDeclaredError`,
  `PushErrorExit`, `PopErrorExit`, `Reraise`) and a `Vm.declared_error: u32`
  field. `fail NAME` calls `rt_fail_declared`, which records `NAME`'s
  1-indexed id and raises through the VM's existing `error_exit`/`check()`
  calling-convention machinery -- **no new error-propagation mechanism**;
  it reuses the exact `NO_VALUE`/`error_exit` plumbing `may_error`/
  `check()` already provide for every other fallible native call. `handle`
  lowers to a `PushErrorExit`/`PopErrorExit` pair that temporarily
  redirects `Translator::error_exit_stack`'s top to a handler-dispatch
  block for the duration of the wrapped call, so every one of `Call`'s own
  many internal lowering paths (unchanged, and not touched by this
  milestone) automatically redirects there without needing Call-specific
  new logic. The dispatch block reads back `declared_error` via
  `rt_declared_error`, branches to the matching handler (clearing the
  pending error state via `rt_clear_declared_error` first), or
  `Reraise`s.

  This surfaced a real GC-root-liveness gap, fixed as part of this
  milestone: `native/src/codegen/roots.rs`'s backward liveness analysis
  computes safepoint root sets from NIR-text-visible control flow alone
  (`Cfg::build`'s explicit branch/jump edges), which cannot see a
  `PushErrorExit`/`PopErrorExit` span's own *implicit* redirect -- a
  register referenced only inside a handler body could otherwise be
  dropped from the root set across the handled call, a genuine memory-
  corruption risk under GC. Fixed with a conservative successor-edge
  injection in `Cfg::build` for the whole handled-call span, so a register
  live in any handler body stays rooted across the call it handles. Also
  fixed: `summarize_call_effects`'s whole-program `may_error` fixpoint
  didn't count `Fail`/`Reraise` as error-producing, which could have
  caused a `fail`-containing function to be (incorrectly) classified
  `may_error = false`, silently skipping the runtime check that makes
  `handle` dispatch run at all.

  A second, independent bug, found and fixed only while re-verifying this
  work directly (not during the original implementation): `native/
  native.tcl`'s `ExpandNativeBodiesIn` -- the pre-lowering pass that
  substitutes a native's own `-native-body` into a call and, purely
  syntactically, walks the whole program to do so -- had no `fail`/`handle`
  arms in its own `switch`. Tcl's `switch` silently returns empty string
  for an unmatched case with no `default` arm, so *every* `fail`/`handle`
  node in a native-backend program was silently erased before lowering
  even began, corrupting the whole program into malformed IR (`an IR node
  must be a non-empty list`) the moment a native build touched one --
  which is unconditional for any program loading `web.bot` at all, since
  every top-level module function is eagerly reachable regardless of
  whether the entry program actually calls it. Fixed by adding `fail`/
  `handle` arms mirroring the pre-existing `block` case's own body-walking
  pattern.

## Generated-code baseline

No new runtime object model, no new allocation: `errorId` is a small,
transient Tcl-list value on interp/compile (never retained past a
`handle`'s own dispatch), and on native, `declared_error` is a plain `u32`
field on the existing `Vm` struct -- a `fail` costs one write plus the
pre-existing `error_exit` branch every other fallible call already takes;
a `handle` costs one extra comparison-and-branch per handler name at the
dispatch block, no allocation, no extra safepoint beyond the ones the
wrapped call already has.

## Tests

`tests/errors.test` (31 tests, new): parsing; propagation through a
declaring intermediate function; undeclared-propagation rejection (both
"the enclosing function doesn't re-declare" and "unhandled at the top
level, which declares none"); `fail` of an undeclared/undeclared-here name;
handler fallback value, handler not taken on success, handler early
`return` (taken and not taken), wrong-handler-type rejection; duplicate
handler and duplicate `errors`-clause rejection; partial handling (with
and without the required re-declaration); top-level closure; cross-module
signatures (both the success and the unhandled-rejection case); HIR
format/parse round-trip; callable-constructor-syntax removal; all-four-
backend parity across every branch of a two-error function, in both
per-path and single-multi-path-pass forms; `byte::from_int` itself,
exhaustively (in-range, below-range, above-range, unhandled-rejected),
cross-backend.

Updated for the callable-syntax removal: `tests/ascii.test`,
`tests/byte-set.test`, `tests/native-byte.test`, `tests/web-unreserved.test`,
`tests/surface-modules.test` -- literal `Byte(N)`/`Nibble(N)` arguments
(statically provable in range) become bare `N`, per the same "a bare Int
literal with its own exact-value fact is accepted with no explicit
`Byte(...)` at all" precedent `tests/ascii.test`'s own pre-existing
`ascii-accepts-provably-in-range-literal` test already established;
genuinely dynamic uses (a loop variable) become `byte::from_int(n): on
BelowRange: ... on AboveRange: ...`; `tests/native-byte.test`'s six tests
that specifically exercised the now-removed callable checked-constructor
syntax and its native lowering are removed (the property they pinned --
generic, cross-backend-identical checked interval-domain construction for
a genuinely dynamic value -- is now demonstrated by `tests/errors.test`'s
own `errors`/`fail`/`handle` coverage instead, and by `byte-set.test`'s own
rewritten `errors-generic-domain-check*` pair, which replaced its two
`Small(n)`-callable-syntax tests with an equivalent `error`/`fail`
`Small`-domain check function); `tests/byte-set.test`'s three "fails at the
boundary" tests updated from the old callable constructor's own `CORE
SEMANTIC RANGE` kind to the new mechanism's `CORE SEMANTIC UNCAUGHT-ERROR`
(an unhandled `fail` reaching the program boundary,
`core/completion.tcl`'s `atProgramBoundary` -- observed only via
`-strict 0`, per "Top-level closure" above); `tests/surface-modules.test`'s
own startup-allocation-shape counts updated for `byte::set`'s now-two-
handler-branch module init (5 `listnew` ops where there were 3, one extra
per unreachable-in-practice handler branch, still lowered like any `if`'s
untaken branch).

## Full regression / GC stress

`tclsh9.0 tests/all.tcl` (interp backend): **Total 2085, Passed 2085,
Skipped 0, Failed 0**. Same run's own second pass (`#### backend: compile`,
`tests/all.tcl`'s own built-in second invocation over the compile Tcl-
codegen backend): **Total 2085, Passed 2085, Skipped 0, Failed 0**.

`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: interp pass **Total
2085, Passed 2085, Skipped 0, Failed 0**; compile pass **Total 2085, Passed
2085, Skipped 0, Failed 0**.

`cargo test --release --manifest-path native/Cargo.toml`: **60 passed; 0
failed; 0 ignored**.

Getting a clean `tests/all.tcl` run (as opposed to each individual test
file passing on its own, which this milestone's own earlier development
had already confirmed) surfaced two further, real fixes not caught by
targeted single-file runs, both described in their own sections above and
both fixed before these final counts:

- `native/native.tcl`'s `ExpandNativeBodiesIn` had no `fail`/`handle` arms
  (silently erasing those nodes before native lowering).
- `native/lower.tcl`'s own temporary `UnsupportedStub`/catch-wrapping
  stopgap (added during this milestone's own native-lowering work, before
  `fail`/`handle` had *real* native codegen) was catching every `NATIVE
  UNSUPPORTED` diagnostic during lowering, not just `fail`/`handle`'s own,
  breaking the pre-existing, correct compile-time `NATIVE UNSUPPORTED`
  diagnostic for an unrelated, already-unsupported native
  (`UriQueryValue?`). Removed now that `fail`/`handle` lower for real and
  no longer need it.
- A handful of pre-existing test files (`tests/hir-range.test`,
  `tests/loop-in.test`, `tests/source-types.test`) used the removed
  callable `Byte(x)`/`Small(x)`/`Tags(x)`/`Big(x)` constructor syntax, or
  (`hir-range.test`) an ordinary unbound `error(...)` call as a generic
  "not a plain value" placeholder that this milestone's own new `error`
  keyword now shadows -- not caught by this milestone's own earlier,
  narrower test-migration pass, which covered only the files the original
  brief named directly (`tests/ascii.test`, `tests/byte-set.test`,
  `tests/native-byte.test`, `tests/web-unreserved.test`,
  `tests/surface-modules.test`). All migrated the same way: a literal,
  statically-provable argument becomes a bare literal; a genuinely dynamic
  one becomes an explicit `errors`/`fail`/`handle` function.

One further, unrelated, pre-existing bug was found (not fixed, out of this
milestone's scope) while migrating `tests/source-types.test`: a function
declared with the broadest possible result type, plain `-> int`, is
incorrectly rejected when its body's inferred value is a *multi-value*
exact-set fact (e.g. an `if`/`else` that can only ever return `0` or `78`)
-- confirmed present before this milestone (commit `09f7f4c`, `hir/
range.tcl`'s `verifyDeclaredResults`/`ProvesValueAcceptedBy`), unrelated to
`error`/`fail`/`handle`. Reported separately as a follow-up task; the one
affected test here was reshaped to declare the specific source-defined
result type instead of plain `int`, which is unaffected by it.

## Semantic source fence

Every runtime failure this milestone introduces or touches is a **declared**
completion: `byte::from_int`'s two possible errors are named in its own
`errors` clause and checked, statically, at every call site
(`hir/errorsets.tcl`), before any backend runs. No code path in this
milestone raises an undeclared runtime completion the way the old callable
`Byte(x)` constructor did -- the one remaining undeclared-looking runtime
outcome, `CORE SEMANTIC UNCAUGHT-ERROR`, is reached only by a program that
was already rejected under this project's own `-strict 1` default (an
unhandled `fail` reaching the top level, which `hir/errorsets.tcl` flags as
a static `UNHANDLED-ERROR` diagnostic); it is not a new hole, it is what
"known failure -> compile-time rejection" looks like when a caller chooses
to run a program with diagnostics deliberately suppressed. The invariant
this milestone set out to restore -- known failure rejected at compile
time, unknown failure a declared runtime completion, never an undeclared
one -- holds for every path through `byte::set`/`byte::from_int`/
`web::is_unreserved`'s own migration, and for the general `error`/`errors`/
`fail`/`handle` mechanism itself, on all four backends.
