# Strict typed parameters

Botlish functions may now declare an optional parameter type:

```botlish
fn f(x: T, y: U) -> V:
    ...
```

The core semantic rule, unchanged from the brief:

> A parameter annotation is a compile-time proof obligation, not a runtime
> contract check.

A call is legal only when the compiler can *prove* every argument's
possible values are a subset of its parameter's accepted values. A merely
unproven argument is rejected exactly like a proven-incompatible one --
there is no third outcome that inserts a runtime guard.

## Outcome

Implemented and regression-tested. Parameter annotations parse, resolve
against the same named-type machinery result annotations already use
(including source-defined integer-domain types), are retained as semantic
HIR metadata, seed body facts unconditionally from the declaration alone,
and are enforced at every statically-resolved call site through one new,
local, non-interprocedural verification pass (`hir::range::
verifyDeclaredParams`) that mirrors the existing `verifyDeclaredResults`
pass almost exactly. No production file gained a Byte/Small/Tiny-specific
branch; the one new pass and the one new seeding step in `hir::types::
Block` are both fully generic over `core::type`/`hir::range`'s existing
value-set machinery.

New: `tests/typed-parameters.test` (50 cases). Full suite (`tclsh9.0 tests/
all.tcl`, interp/compile/cranelift, native backend built) and `cargo test
--release --manifest-path native/Cargo.toml` both pass unmodified; see
"Tests" below for exact counts.

## Syntax

```
param        := IDENT [ ":" TypeName ]
function     := "fn" IDENT "(" [ param { "," param } [ "," ] ] ")"
                [ "->" TypeName ] ":" suite
```

```botlish
fn identity_small(x: Small) -> Small:
    x

fn combine(x: Small, y: Small) -> Int:
    x + y

fn f(x):                    # untyped parameters remain legal
    x

fn f(x: Small, y):          # mixed typed/untyped is allowed
    x
```

No composite/generic type syntax (`fn f(x: List[T]):`), no typed locals, no
defaults, no named arguments, no overloading, no variadics -- all
unchanged and out of scope, exactly as before this milestone.

### Grammar note: "()"'s ":" is never the suite's ":"

Since a Botlish function's parameter list is always inside `(...)`, and the
lexer already suppresses NEWLINE/INDENT tracking inside any bracket pair,
a parameter's own `:` can never be confused with the suite's own `:`
(which appears only after the closing `)`, and possibly after a `->
TypeName`). This needed no lexer change and no lookahead: `surface/parser.
tcl::Function`'s per-parameter loop simply checks for a `:` token
immediately after the parameter name and, if present, requires a type
`IDENT`; if absent, the parameter is untyped, exactly as before. Pinned
directly: `typed-param-parse-7`/`-8` parse `fn f(x: Small): x` and
`fn f(x: Small) -> Small: x` and assert the suite's own single statement /
result type came through unambiguously.

## Semantic model: admissibility, not nominal subtyping

The central distinction the brief asked for is real and is what the
implementation is built around:

- **Nominal subtype** (`core::type::subtype`, unchanged): an explicit
  parent relationship declared by `type Child = Parent in Domain`, or
  ordinary named-type evidence inclusion. `Tiny <: Small` because `Tiny`'s
  own declaration says so.
- **Call admissibility** (new: `hir::range::VerifyCall`'s two-part check):
  an argument satisfies a parameter's declared type `T` when the compiler
  can prove `possibleValues(arg) ⊆ acceptedValues(T)`, using *either* of:
  1. `hir::types::subtype(argType, T)` -- nominal subtype, or
  2. `hir::range::ProvesType(argRange, T)` -- the argument's strongest
     known Range/exact-set fact is a subset of `T`'s own integer-domain
     facts (`core::type::integerFacts`).

Both halves are the *exact* two checks `hir::range::verifyDeclaredResults`
already used for declared **results**, reused verbatim for parameters, not
reimplemented. This is why two independently-declared `Int in 0..3` types
(`A`/`B`) are nominally distinct (neither `<:` the other) and yet a `B`
value is admissible wherever an `A` parameter is declared: `core::type::
subtype(B, A)` is false, but `ProvesType` succeeds because `B`'s own
`core::type::integerFacts` domain is a value-subset of `A`'s.

No conversion, wrapper, or retagging happens for such a call: the runtime
value is unchanged, and it is *never* constructed as a nominal `A` first.
Inside the callee, the parameter is simply governed by `T`'s own contract
from the declaration -- this is a compile-time reinterpretation at the
call boundary, not a caller-side mutation (the caller's own binding is
still statically `B` everywhere else in its own scope).

## Architecture: surface → HIR → checking

### 1. Surface AST (`surface/parser.tcl`, `surface/ast.tcl`)

A `function` node's `params` field grows from `{NAME SPAN}` pairs to
`{NAME SPAN TYPE TYPESPAN}` tuples (`TYPE`/`TYPESPAN` are `""` for an
untyped parameter). `surface/ast.tcl`'s debug pretty-printer prints
`name:Type` for a typed parameter, matching the milestone's own canonical
form (`fn f(x: T, y: U) -> V:`; the debug dumper's own pre-existing
convention has no space around most punctuation, e.g. `(x:Small y)`, which
this feature follows rather than inventing a separate rule for).

### 2. Lowering (`surface/lower.tcl`, `hir/syntax.tcl`)

`surface::lower::Node`'s `function` case now also builds a `paramTypes`
list (the raw, unresolved type-name strings, parallel to `params`) and
passes it to `hir::syntax::blockNode`, which grew one new optional
argument for it (default: all-`""`, so every existing caller -- `hir::
syntax::fromIR`, and any hand-built HIR syntax -- is unaffected and
untyped, exactly as before). The `block` syntax node's header comment
documents the new field.

### 3. Resolution (`hir/resolve.tcl`)

The `block` case's existing per-parameter loop (which already creates each
parameter's `BindingId`) now also, per parameter, normalizes its raw type
name through `core::type::normalize` -- the *same* call `declaredResult`
already uses -- producing a `declaredParamTypes` list (parallel to
`params`, one raw type form or `""` per parameter) stored as a new field on
the block expression. An unresolvable name (`MissingType`) is a `TYPE`
diagnostic located at the block expression (the same location precision
`declaredResult`'s own unknown-type diagnostic already uses), and that
parameter is treated as untyped from there on -- never a parse error, and
never silently ignored (spec: "Reject `fn f(x: MissingType): x` with a
compile-time located diagnostic").

Forward/declaration ordering is identical to `declaredResult`'s: no
separate rule was added, because `hir::sourcetypes::apply` (which resolves
every `type X = Y in D` declaration a program and its loaded modules
contain, in dependency order) already runs *before* `hir::resolve::
program` even starts, so every source-defined type a parameter annotation
could name is already registered by the time this loop's `core::type::
normalize` call runs, regardless of where in the file the `type`
declaration and the function's own definition each appear.

### 4. Semantic types (`hir/types.tcl::Block`)

This is the one change that makes fact-seeding, nominal-subtype checking,
*and* result-contract interaction all fall out of already-existing generic
machinery, rather than needing three separate mechanisms:

```tcl
foreach b [dict get $node params] declaredType [dict get $node declaredParamTypes] {
    if {$declaredType ne {}} {
        dict set ctx types $b $declaredType
    }
}
```

added right where `Block` already seeds `self`'s own assumed type before
walking the body. From here on, every `ref` to a typed parameter inside
its own body is typed as `T` (nominally) by the *pre-existing* `BindingType`
lookup (`ctx types` is checked before falling back to `any`) -- with three
consequences, all for free:

- **Nominal admissibility and result-contract interaction** (`hir::types::
  subtype`) see the parameter's real declared type, so `fn f(x: Tiny) ->
  Small: x` verifies through ordinary subtype proof (`Tiny <: Small`), and
  `fn f(x: Small) -> Tiny: x` is correctly *rejected* (`Small` is not
  `<: Tiny`, and the body proves nothing narrower).
- **Range/exact-set fact seeding** (`hir::range::ConstrainType`, wholly
  pre-existing) is applied to *every* `ref` expression using that
  expression's own semantic type (`hir::typeOf`), which is now `T` for a
  typed parameter instead of always `any`. `ConstrainType` intersects the
  current flow fact with `TypeFact(T)` (`core::type::integerFacts`-
  derived), so a `Byte`-typed `x`'s very first reference already carries
  `[0, 255]`, with **zero changes to `hir/range.tcl` itself** -- this
  mechanism was built for the previous milestone's declared-result seeding
  and is name-agnostic (no `Byte`/`Small` anywhere in it).
- **Closed-caller strengthening never widens the declared baseline**
  (spec #23, #80): `ConstrainType` always *intersects*, so a caller-derived
  fact from `hir::range::analyze`'s pre-existing interprocedural fixpoint
  can only ever narrow a typed parameter's effective fact, never exceed its
  own declared domain -- verified directly (`typed-param-closed-call-
  strengthens`, `typed-param-declared-baseline-not-exceeded`), with no new
  code in that fixpoint at all.

### 5. Call admissibility (`hir/range.tcl`, new)

`hir::range::verifyDeclaredParams` is the one new checking pass, and it is
deliberately structured to mirror `verifyDeclaredResults` rather than
extend `hir::range::analyze`'s interprocedural closed-call fixpoint:

- It runs once per block (and once for the program root), each time with
  its own **local**, non-interprocedural `AnalyzeInstance` call (`id
  "verify"`, `instanceCalls {}` -- the same shape `verifyDeclaredResults`'s
  own local proof already uses), collecting a Range for every expression in
  that one block's own body.
- `hir::range::VerifyCallArguments` walks that body (via the pre-existing,
  generic `hir::children`, stopping at a nested `block` -- "a nested
  block's body is its own region," `hir::range::Expr`'s own long-standing
  rule) and calls `hir::range::VerifyCall` on every `call` expression found.
- `VerifyCall` only checks a call whose `target` field already resolved to
  a directly-known block (`{block B}}` -- set by the *existing*, unmodified
  `hir::types::Call`). For each of `B`'s typed parameters, it checks the
  corresponding argument's semantic type and local Range against the
  declared type via the two-part `subtype`-or-`ProvesType` proof above,
  diagnosing `TYPE` (located at the argument expression) on failure.

This design is what makes spec #24 ("an invalid caller must not pollute
the callee fixpoint") true *by construction*, not by an ordering argument:
`verifyDeclaredParams` never touches `hir::range::analyze`'s `calls`/
`contributions` fold at all, so there is no shared state for a rejected
call to corrupt. It also means a **recursive** call's own argument is
checked soundly with no special-casing: a self-call inside a block's own
body is just another `call` expression the very same local pass already
visits, and it reads the *same* body-local Range facts (including the
declared-parameter seeding above) the rest of the block's proof uses --
`typed-param-valid-recursive` / `-invalid-recursive` pin both directions.

`verifyDeclaredParams` is called from `hir::buildSyntax` immediately after
`verifyDeclaredResults`, so an invalid call is rejected at the same phase,
before any backend (interp, compile, cranelift) is ever invoked --
interp/compile/cranelift therefore agree by construction: they never see
the invalid program at all (the `{CORE SEMANTIC TYPE}` diagnostic is raised
during HIR construction itself, `hir::buildSyntax`'s own `-strict`
handling, identical to every other semantic diagnostic in this compiler).

## Module signatures / cross-module calls

Botlish combines a program and every module it transitively loads into
*one* HIR before any checking runs (`surface/modules.tcl`), so a
cross-module call is, by the time `hir::types::infer`/`hir::range::
verifyDeclaredParams` see it, an ordinary direct call with a fully resolved
target -- no separate module-signature lookup mechanism was needed for
soundness. `hir::moduleSignatures` (pre-existing helper, unused by any
production code path -- confirmed no caller outside its own definition and
tests) was updated to report each exported function's real declared
parameter types instead of a placeholder `any` per parameter, for parity
with its own result-type field and for any future tooling that queries it,
but this is descriptive metadata, not part of the enforcement path.
`typed-param-valid-cross-module` / `-invalid-cross-module` load a
throwaway namespace module (the same pattern `source-types.test`'s own
cross-module test already established) and confirm both directions at the
real module boundary.

## HIR serialization

`hir/format.tcl`'s block header line grew a dedicated `ParamList` (mirrors
the existing `BindingList`, adding `:TYPE` -- `hir::types::show` -- after a
typed parameter's own `BINDING NAME`):

```
block s3 (b1 x:int[Small], b2 y) captures () declares int[Small]
```

`hir/read.tcl` grew the exact inverse (`ParamList`, `(?::([^: ]+))?` on the
existing `BINDING NAME` grammar) and sets `declaredParamTypes` by running
each typed entry's text back through the pre-existing `ParseType`. A plain
HIR with no typed parameters is unaffected (empty type suffix, same as
before); `typed-param-hir-roundtrip` proves `format → parse → format` is
byte-identical for the milestone's own sample payload, and
`-hir-roundtrip-preserves-type` proves the read-back HIR's
`declaredParamTypes` is semantically live, not just textually round-tripped.

## No runtime check, no new Error completion

- No checked-constructor call, kind guard, or range guard is emitted for a
  legal typed call, on any backend: `typed-param-no-runtime-check-1`
  confirms a legal call's own HIR node has exactly one callee and one
  argument child, added by nothing; `-2`/`-3` confirm ordinary
  interp/compile execution and agreement are unaffected.
- No new native helper was added: `typed-param-no-search-helper` searches
  `core::native::names` for `*check_param*`/`*validate_argument*`/
  `*assert_parameter*`/`*param*type*` and finds none (spec #97).
- A total function with a typed parameter stays total: `typed-param-no-
  new-error-completion` confirms `fn f(x: Small) -> Int: x + 1`'s own
  `resultType` is plain `int`, not widened to any error-carrying form, by
  the addition of the parameter annotation alone.
- `git diff --stat` against this branch's parent shows no change to
  `native/lower.tcl` or any `native/src/**` Rust source: parameter typing
  is enforced entirely in HIR construction, before native lowering exists.

## Byte integration microscope

Using the real, source-defined `Byte`/`Nibble` (`lib/byte.bot`, from the
prior milestone), with no library changes:

```botlish
fn byte_identity(x: Byte) -> Byte:
    x

fn low_nibble(x: Byte) -> Nibble:
    bit_and(x, 15)
```

`typed-param-body-fact-byte` and `-byte-low-nibble-microscope` confirm,
via the same local `AnalyzeInstance` the new checking pass itself uses,
that `x`'s own Range fact is `[0, 255]` from the declaration alone --
*before* any caller is ever analyzed, exactly spec #21-22's "body fact
seeding" and "open-call independence" requirements. No new codegen rule
was added; `native/lower.tcl` and `native/src/**` are unmodified, so
whatever guard-elimination benefit this seeding unlocks downstream (spec
#31, #100) is a consequence of feeding an already-generic mechanism a
better fact, not of any new peephole.

## Dynamic/function-value call handling

Audited directly (`hir::types::Call`'s existing target resolution) rather
than assumed. A call's `target` field resolves to `{block B}` -- the only
shape `VerifyCall` checks -- exactly when ordinary, single-pass, whole-
program semantic inference (`hir::types::infer`, run once in `hir::
buildSyntax`, before `hir::specialize` exists at all) can already prove the
callee's exact identity: an ordinary direct call, or a call forwarded
through an immutable binding whose own type stayed precise. A call whose
callee's static type has degraded to `any` -- because it passed through an
**untyped** higher-order parameter, a list, or anything else this
compiler's existing (and unextended) type system cannot track precisely --
resolves `target` to `""` and is, by construction, invisible to
`VerifyCall`; per spec #36, typed-parameter contracts are enforced only for
exact/direct calls, and this is exactly where the boundary already falls
without any new logic to draw it.

This was empirically probed, not just reasoned about: a `Byte`-typed
`take_byte` passed through an untyped `apply(f, v): f(v)` and invoked with
`9999`:

```botlish
fn take_byte(x: Byte) -> int:
    x

fn apply(f, v):
    f(v)

apply(take_byte, 9999)
```

compiles (the inner `f(v)` call's target is unresolved, so it is outside
this feature's scope by design) and evaluates to the real, unclamped
`9999` identically on interp, compile, *and* cranelift -- confirmed
directly with `main.tcl -backend {interp,compile,cranelift}`. This matters
because it shows the milestone's chosen scope boundary does not cause
silent wrong answers: `hir::range::ConstrainType`'s declared-type seeding
inside `take_byte`'s own body is a *narrowing intersection*
(`hir::range::intersect`), never a hard replacement -- when the caller's
real value genuinely falls outside the declared domain, the intersection
of an (in this open-call case, unconstrained) caller fact with the
declared fact is a range computation, not a value computation, so no
backend's actual arithmetic result is affected by it. No representation-
specialization or unchecked-guard-elimination work exists yet in this
codebase that would make an unproven dynamic call's mismatched range fact
observable as a wrong *value* (items 28-30's own scope boundary); should a
future milestone add such an optimization, it would need to consult
`hir::range::OpenInstances` (the pre-existing mechanism that already
excludes a block reachable through a materialized/escaping value from
interprocedural caller-fact folding) the same way that mechanism already
protects the *result*-contract seeding this milestone's own declared-
parameter seeding is modeled on.

**Chosen, documented limitation** (spec #36-38's own offered escape
hatch): typed-parameter contracts are enforced for exact/direct calls
only. A fuller, sound treatment of a typed function escaping as a
first-class value would need a real function-*type* system (tracking a
value's full parameter-type signature through arbitrary storage and
higher-order calls, not just its arity/kind as today), which is out of
this milestone's explicit scope (spec #75: "do not add variance/general
function-subtyping unless needed for soundness") and is not needed for
soundness today, per the empirical check above and the declared-result
milestone's own identical, already-accepted precedent ("Dynamic calls are
precise only while their block value type remains specific... Calls
through `any` remain imprecise," `CROSS-MODULE-REFINED-SIGNATURES.md`).

## Sample payload and acceptance table

```botlish
type Small = Int in 0..10
type Tiny = Small in 0..3
type OtherTiny = Int in 0..3

fn identity_small(x: Small) -> Small:
    x

fn widen_tiny(x: Tiny) -> Small:
    x

fn combine(x: Small, y: Small) -> Int:
    x + y

fn make_other() -> OtherTiny:
    2
```

| Call | Result |
|---|---|
| `identity_small(7)` | valid |
| `identity_small(0)`, `identity_small(10)` | valid (both endpoints) |
| `identity_small(11)`, `identity_small(-1)` | compile error |
| `widen_tiny(2)` | valid (`Tiny <: Small`, nominal) |
| `identity_small(make_other())` | valid (`OtherTiny` same-domain sibling) |
| `combine(3, 8)` | valid |
| `take_a(B-value)`, `A`/`B` both `Int in 0..3` | valid; `A != B`, `A !<: B`, `B !<: A` |
| `take_small(make_other())`, `Small = 0..10`, `OtherTiny = 0..3` | valid |
| `take_small(make_wider())`, `Wider = 0..20` (no narrower flow fact) | compile error |
| `take_mark(4)`, `take_mark(12)`, `Marks = {0,4,8,12}` | valid |
| `take_mark(5)` | compile error |
| `take_mark(x)`, `x` known only `[0,12]` | compile error |
| `take_mark(x)`, `x` known exactly `{0,8}` | valid |
| `id_int(5)`, `id_str("hi")` (`x: int`, `x: str`) | valid |
| `id_int("hi")` | compile error (wrong primitive kind) |
| cross-module `take_small(7)` / `take_small(99)` | valid / compile error |
| `f(x: Small): f(x + 100)` | compile error (recursive call, own argument unprovable) |

All rows above are pinned 1:1 by named tests in `tests/typed-parameters.
test` (see "Tests").

## Diagnostics

Example (`identity_small(11)`):

```
argument for parameter "x" cannot be proven to satisfy int[Small]
(argument type: int, facts: [11, 11])
```

located at the argument expression, using the existing semantic/type
diagnostic family (`hir::Diagnose hir TYPE ...`, surfaced as `{CORE
SEMANTIC TYPE}` by `hir::buildSyntax`'s own `-strict` handling -- the same
errorcode `verifyDeclaredResults`'s own diagnostic already used). The
message never implies a runtime cast or check could save the call; it
states what was proven (or not) about the argument, the parameter it
belongs to, and the declared type, mirroring the phrasing spec #34 asked
for. Internally, "proven incompatible" and "not proven" are not
distinguished as separate diagnostic categories (spec #35 allows, but does
not require, telling them apart) -- both are the identical compile-time
rejection under the strict model, and doing so would have needed a second
proof pass with no behavioral difference in outcome.

## Tests

New: `tests/typed-parameters.test`, 50 cases -- parser (typed/multiple/
mixed parameters, a typed parameter plus a result annotation, an unknown
type as a semantic-only error, a malformed/missing-type colon, suite-colon
non-ambiguity with and without a result type, canonical formatting),
semantic valid calls (literal-in-interval, both endpoints, nominal
subtype, same-domain sibling, independent narrower domain, exact-in-sparse
subset, multiple arguments, builtin `int`/`str`, cross-module, recursive),
semantic invalid calls (literal outside interval, both directions,
sparse-literal absence, wider-interval-not-proven-subset, interval-cannot-
prove-sparse, a genuinely unproven argument, wrong primitive kind, a
recursive call's own bad argument, unknown parameter type, cross-module,
diagnostic content), untyped/mixed-parameter non-regression, no-runtime-
check evidence (HIR shape, interp/compile agreement, no new native
helper), body-fact seeding (`Byte` and a source-defined `Small`, both
caller-independent), result-contract interaction (trivial same-type,
narrower-result correctly rejected, narrow-parameter/wide-result via
ordinary subtype), closed-call strengthening (never widening the declared
baseline), no-new-error-completion, the Byte/Nibble codegen microscope,
and HIR round-trip (both textual identity and semantic re-read).

`tclsh9.0 tests/all.tcl` (interp and compile backends, native backend
built with `cargo build --release`): full suite passes, including the new
file, with no regression in any pre-existing test. `cargo test --release
--manifest-path native/Cargo.toml` passes unmodified (no Rust source
changed by this milestone). GC-stress
(`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`): [see below].

## Required-question summary

Architecture: parameter annotations live in the surface `function` node's
`params` tuples (raw type-name text) and, after lowering, the `block`
syntax node's `paramTypes`; `hir/resolve.tcl` normalizes them into
`declaredParamTypes` (a resolved-type-form list parallel to `params`),
retained as ordinary HIR metadata (never discarded after checking -- any
downstream pass can query it, exactly as `declaredResult` already could).
Module signatures need no separate propagation path because modules are
combined into one HIR before checking. Call admissibility is checked once,
in `hir::buildSyntax`, via the new `hir::range::verifyDeclaredParams`,
which every backend shares by construction (it runs before any backend
exists). No runtime validation is inserted anywhere -- confirmed by
`git diff --stat` showing no change to `core/`, `native/lower.tcl`, or any
`native/src/**` Rust source.

Semantics: `x: T` means every legal caller has already statically proved
`possibleValues(x) ⊆ acceptedValues(T)`; there is no runtime failure mode
from the annotation itself. A definitely-incompatible argument and a
merely-unproven one are both compile-time errors -- the strict model has
no middle ground. The explicit mechanism for establishing an uncertain
value's membership remains the pre-existing checked constructor/predicate
(`Small(x)`/`Small?(x)`), untouched by this milestone. Nominal subtype
implies admissibility; admissibility can also succeed without nominal
subtype (the same-domain-sibling case); same-domain siblings remain
nominally distinct types that may still satisfy each other's parameter
contracts through value-set proof alone, with no conversion generated.

Facts: a declared parameter's own type unconditionally seeds its body's
range/exact-set facts (via the pre-existing `ConstrainType`/`TypeFact`),
independent of any caller; closed-caller facts (the pre-existing
interprocedural fixpoint, untouched) can only narrow that baseline, never
widen past it, because the same seeding is an intersection at every
reference, not a one-time initial value; an invalid call cannot enter that
fixpoint at all, since `verifyDeclaredParams` runs as an independent local
pass that never touches its `calls`/`contributions` machinery; a declared
parameter remains useful with no closed callers at all (open-call
independence), confirmed directly for `Byte`/`Nibble` and for a
source-defined `Small`.

Codegen: no new NIR instruction, no ABI/representation change, no
`ByteRep`/`Int64Rep`, and no new possible `Error` completion were added by
parameter typing itself; existing guard-elimination machinery may benefit
from the now-precise parameter facts where it already consults Range, with
no parameter-specific peephole added to make that happen.

## Explicitly out of scope (unchanged)

Typed locals, generic/parameterized parameter syntax, `List[UnicodeChar]`,
variance rules, overloading, variadics, predicate flow refinement (`if
Byte?(x): ...` narrowing `x`), ASCII, character literals, `ImmutableSet`,
`byte::set`, and representation specialization were not touched. `lib/
byte.bot`'s own function signatures are unmodified except for the two
throwaway microscope functions used only inside `tests/typed-parameters.
test` (never added to the library itself). Searching every file this
milestone changed for `Byte`/`Nibble`/`Small`/`Tiny` finds only test/doc
occurrences and the pre-existing, unrelated source in `lib/byte.bot` --
confirmed by `git diff` against this branch's parent touching no
Byte-specific production logic.

## Next roadmap decision

With strict typed parameters landed, the accepted rejection of "merely
unproven" arguments (spec #67, #88's own required tests) is the real
ergonomic pressure point the brief anticipated: a program that has an
Int and wants to call a bounded-parameter function must either receive it
already narrowed by a declared result type, or go through an explicit
checked constructor -- there is still no way to *locally* refine an
arbitrary value's type from a runtime test (`if Byte?(x): ...`) the way
flow-sensitive comparison narrowing already refines ranges. That predicate
flow refinement is the most immediately useful next step this milestone's
own restrictions expose; minimal parameterized container typing
(`List[UnicodeChar]` → `ImmutableSet[Byte]`) remains the other, independent
next-concrete-blocker path the original motivation (`byte::set`) will
eventually need.
