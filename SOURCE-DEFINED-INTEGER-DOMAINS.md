# Source-Defined Integer Domains

This milestone moves the authoritative definitions of Byte/Nibble/LowNibble/
HighNibble out of compiler-side Tcl registration (`core/scalarbits.tcl`) and
into ordinary Botlish source (`lib/byte.bot`), by adding one dedicated
declaration to the language:

```botlish
type Child = Parent in Domain
```

where `Domain` is one inclusive integer interval (`LO..HI`) or one finite
set of integers (`{V, V, ...}`). Everything downstream of the type system —
result-contract verification, range/exact-set analysis, checked
constructors, native lowering — is unchanged: it already consumed a
canonical integer-domain descriptor by name, whether that name was
registered from Tcl or, now, from Botlish source.

## Outcome

Implemented, migrated, and regression-tested. `core/scalarbits.tcl` no
longer defines Byte/Nibble/LowNibble/HighNibble; `lib/byte.bot` does, as
four ordinary `type` declarations. No production file downstream of the
type system (`hir/range.tcl`, `hir/types.tcl`, `hir/specialize.tcl`,
`native/lower.tcl`, `native/src/**`) needed to change — confirmed directly
by `git diff --stat`, not just by argument: those files are untouched by
this milestone.

Full regression: `tclsh9.0 tests/all.tcl` (interp + compile backends),
targeted native/Cranelift parity tests, and a new dedicated test file
(`tests/source-types.test`, 44 cases) for the generic feature independent
of Byte. See "Tests" below for exact commands and results.

## Syntax and grammar

```
type-declaration :=
    "type" TypeName "=" TypeName "in" integer-domain

integer-domain :=
    signed-int ".." signed-int
    | "{" signed-int ("," signed-int)* [","] "}"

signed-int := ["-"] INT
```

A type declaration is legal only at the top level of a program or module
(never nested in a function/if/loop body — enforced by the parser, not by
convention: `surface/parser.tcl`'s `topLevel` flag). It is syntax, not an
ordinary statement: `surface/ast.tcl`'s new `typedecl` node carries `name`,
`nameSpan`, `parent`, `parentSpan`, `domain` (itself `{kind interval lo ..
hi ..}` or `{kind exact values {..} spans {..}}`), never lowered through
`surface/lower.tcl`'s ordinary `Node` dispatch — it is filtered out of a
program/module's executable statement list before lowering
(`surface::lower::SplitTypeDecls`) and carried separately into
`hir::buildSyntax` as a new `-type-decls` option.

**`..` and `{`/`}` are reused, not reserved elsewhere.** `..` was already
tokenized as a *reserved-and-erroring* two-character sequence
(`surface/lexer.tcl`, "'..' is reserved for future range syntax"); this
milestone gives it a real meaning instead of an error, and only inside a
type declaration's interval — the lexer change is exactly turning that one
case from "report a diagnostic" to "emit a `..` token" (12 lines). `{` and
`}` had *no* prior meaning at all: Botlish blocks are `:` plus indentation,
not braces, so before this milestone `{`/`}` were plain "unexpected
character" errors. Adding them as ordinary bracket tokens (tracked for
newline/indentation suppression exactly like `(`/`[`, so a multi-line
`{...}` domain works for free, trailing comma included, by the same
mechanism `Arguments`'s trailing comma already uses) is additive, with zero
risk of reinterpreting existing brace-free source.

**`type` is a new reserved keyword; `in` is not.** Auditing the current
corpus (`lib/*.bot`, `examples/**/*.bot`) for `type`/`in` used as an
ordinary identifier (function name, parameter, binding) found none — only
prose inside comments. Reserving `type` globally (`surface/lexer.tcl`'s
keyword list) is therefore compatibility-safe, and simpler than a
context-sensitive `type`. `in`, by contrast, is a broadly useful ordinary
word; nothing requires reserving it globally, so it stays an ordinary
`IDENT` — the parser recognizes it only by spelling, exactly where the
grammar expects it (right after a type declaration's parent name,
`surface/parser.tcl::TypeDecl`), the same contextual-recognition pattern
already used for `->` result-type parsing (`allowFunctionResult`). A
program is free to bind a value or a function named `in` anywhere else.

**No expression evaluation, no new operator.** `0..255` and `{1, 4, 7}` are
parsed directly into a domain descriptor by dedicated grammar
(`surface/parser.tcl::Domain`/`IntervalDomain`... folded into `Domain`,
`ExactDomain`, `SignedInt`); nothing here reuses the ordinary expression
grammar, calls it, or introduces a general range/set *value*. Only integer
literals (with an optional leading `-`) are accepted — a name, a call, or
an arithmetic expression after `in` is a syntax error (`SignedInt` requires
an `INT` token, no fallback to `Expression`).

## Semantic model

`type Child = Parent in Domain` establishes:

- **Child is a distinct nominal type.** Two declarations with identical
  domains (`type A = Int in 0..15` / `type B = Int in 0..15`) are never
  structurally identified: each gets its own entry in `core::type`'s
  registry, keyed by its own declared name.
- **Child <: Parent**, explicitly, from the declaration's own `Parent`
  spelling — never inferred from numeric-domain inclusion. `Nibble` and
  `LowNibble`, both `Byte in 0..15`, are siblings: `Nibble <: Byte`,
  `LowNibble <: Byte`, but neither is a subtype of the other, and a type
  numerically compatible with `Nibble`'s domain but declared `Int in 0..15`
  independently (no `Byte` parent at all) is *not* a `Byte` subtype either.
- **values(Child) = values(Parent) ∩ Domain**, and the declared `Domain`
  must already be a subset of the parent's own domain — checked at
  declaration time (`core::type::integerDomainSubset`, see "Parent/subtype
  validation" below), not assumed.

`Int` is not a `core::type`-registered name: it is the literal spelling a
declaration's `Parent` may use to mean "the compiler's own primitive
integer type, no nominal parent" — mirrored exactly by the *pre-existing*
`Byte` registration, which always had `-base int` and no `-parents` at all.
A declared type name may never be `Int` itself (redefinition is rejected,
see "Parent/subtype validation").

## Parser/surface representation

`surface/ast.tcl`'s `typedecl` node (documented in its own header) is the
dedicated surface AST representation — never a `bind`, and it produces no
node under `surface/lower.tcl`'s ordinary `Node` dispatch. `surface/lower.
tcl::SplitTypeDecls` separates a statement list into `{EXECUTABLE DECLS}`;
`TypeDeclOf` turns a `typedecl` node into the plain dict
`hir::buildSyntax`'s `-type-decls` option and `hir/sourcetypes.tcl` consume.
`surface/modules.tcl` does the same per module section (`state typeDecls`,
accumulated dependency-first alongside `state sections`), and allows
`typedecl` at module top level next to `function`/`bind`.

## Type-environment / registry architecture

`core/type.tcl`'s registry (`core::type::registry`, a flat Tcl dict `NAME
-> metadata`) is unchanged in shape — this milestone reuses it, not a
parallel representation. Two additions:

- `core::type::register` takes a new `-source 0|1` flag (default 0,
  unchanged for every existing/compiler-registered type); `-source 1`
  entries are exactly the ones a source declaration adds.
- `core::type::unregister NAME` removes a `-source 1` entry (raises for a
  `-source 0` one — a real bug, never a reset).

`core::type::integerDomainSubset childDomain parentDomain` is the one new
domain-algebra primitive (interval/interval, interval/exact, exact/interval,
exact/exact — see "Parent/subtype validation"), and
`core::type::CheckedConstruct`/`core::type::declareIntConstructor` are the
generic constructor/predicate registration `core/scalarbits.tcl`'s own
`CheckedConstruct` + `foreach typeName {Byte Nibble LowNibble HighNibble}`
loop used to do by hand for exactly those four names — moved, not
duplicated, so a source declaration and a (hypothetical, still-possible)
future compiler registration share the identical constructor
implementation.

`hir/sourcetypes.tcl` (new) is where a *batch* of declarations (everything
a program plus every module it loads declares, in dependency-load order)
becomes registry entries: cycle detection, unknown/wrong-kind-parent
diagnostics, domain-subset validation, then `core::type::register` +
`core::type::declareIntConstructor` per declaration, in an order that
resolves same-batch forward parent references via DFS
(`hir::sourcetypes::Resolve`).

## Compilation isolation

This is the one place source ownership creates a problem compiler-side
registration never had: `core::type::registry` and `core::native::registry`
are process-global, but two different Botlish programs can validly declare
the *same spelling* with *different* domains, in the same long-lived Tcl
process (tests, a REPL, a batch driver).

**The model:** `hir::buildSyntax` calls `hir::sourcetypes::apply DECLS`
before resolution. When `DECLS` is non-empty, `apply` first unregisters
everything the *previous* non-empty-`DECLS` call registered
(`hir::sourcetypes::generation`), then registers the new batch fresh. When
`DECLS` is empty, `apply` does nothing at all — neither reset nor
register — and leaves the registry exactly as it is.

That second rule is deliberate and load-bearing, not an afterthought: every
internal re-derivation of an *already built* program's HIR (the Tcl
compiler backend's own `GenerateUnit` calling `hir::build` on already-
lowered core IR, the native backend's `ExpandNativeBodies`/
`ModuleNativeBridge`/`buildProgramHir` path, `hir/specialize.tcl`'s
per-instance re-inference) goes through `hir::buildSyntax`/`hir::build`
too, with **no type declarations of its own** — core IR has no type-
declaration syntax. If `apply` reset unconditionally on every call, the
compile backend's *own* second pass over a program that itself declared
`type Small = Int in 0..10` would immediately unregister `Small` again,
right as it is about to embed `core::type::AssertCanonical` calls against
it in generated Tcl — breaking the very compile it is part of. This was
caught empirically while building this milestone (see "Tests" —
`native-byte.test`'s cranelift/compile-backend parity tests exercise
exactly this path) and is why the empty-`DECLS` case is a no-op rather than
a reset.

**What this guarantees, concretely (and what it does not):**

- Repeated compilation of the same program, in one process, succeeds every
  time: each compile's own non-empty `DECLS` resets and re-registers, never
  hitting "already registered" — `tests/source-types.test`'s
  `source-type-repeated-compilation`.
- Two *sequential* programs — build A, consume A, build B, consume B — with
  colliding same-spelled, different-domain declarations never see each
  other's domain: by the time B's `hir::buildSyntax` call runs, A's own
  build (and everything A did with the resulting HIR up to that point) is
  already finished — `source-type-sequential-non-leaking-compilation`.
- What it does **not** guarantee: two *live* HIR objects from two different
  `hir::buildSyntax` calls, holding conflicting same-spelled declarations,
  both still needing correct name-based resolution *after* a third,
  colliding build has run in between. Compiled Tcl procs
  (`core::compiler::cache`) and native code both persist for the rest of
  the process and re-consult `core::type`/`core::native` by bare name at
  every future invocation; a later, colliding declaration would shadow an
  earlier one's meaning for anything that looks it up again after that
  point.

**Why this is the right line to draw here, not a gap papered over:** giving
every source-declared type a truly compilation-scoped identity (so two
live, colliding registrations could coexist correctly) requires threading a
compilation/program identity through every name-based lookup —
`core::type::normalize`, `::subtype`, `::integerFacts`, `core::native::
metadata`, the compiled-Tcl-proc's own embedded contract checks — a real
redesign of otherwise name-keyed machinery, exactly what items 93/136/16 of
this milestone's brief ask *not* to do (no production changes to
`hir/range.tcl`, `native/lower.tcl`, `native/src/**`; "prefer program-local
state when reasonably aligned with current architecture," not forced).
This compiler has no other notion of concurrent or nested compilation
today — nothing in `hir/`, `compiler/`, or `native/` passes a compilation
identity anywhere, and every actual caller in this codebase (every test,
`main.tcl`, the module loader) builds, consumes, and moves on before
building the next thing. The reset-on-next-batch model matches that usage
exactly, is proven against it by the isolation tests above, and is
documented here rather than silently relied upon — see "Deferred features"
for what a fuller compilation-scoped environment would need.

## Module/name resolution

`core::type`'s registry has **no namespace concept** — this was already
true of the four compiler-registered names it replaces (`Byte` etc. were
always looked up by bare name, with no `byte::` qualification ever
possible for a *type*, only for the ordinary functions built over them).
This milestone inherits that, deliberately, rather than inventing type
namespacing as a side effect: a source declaration registers under its
bare spelling, in the one flat, compilation-scoped registry above,
regardless of which module declared it. Two *co-loaded* modules each
declaring `type Small = ...` collide exactly the way two modules each
trying to define an unqualified root native would — `core::type::register`
raises "already declared" (surfaced as a proper, located diagnostic by
`hir::sourcetypes.tcl`), covered by `source-type-duplicate-declaration`
(same-batch case).

A module's own declared types become available to any *other* code only
when that code is loaded as a dependency — and dependency discovery
(`surface/modules.tcl::QualifiedRefs`) is driven purely by qualified
*value* references (`mod::name`), which type declarations have no syntax
for. Concretely: a program that calls `byte::high_nibble(...)` transitively
loads `lib/byte.bot`, which registers `Byte`/`Nibble`/`LowNibble`/
`HighNibble` as a side effect of being loaded for its *functions* — so
`web.bot` (which already calls `byte::high_nibble`) gets them "for free,"
exactly as needed. A program that wants to use `Byte` as *its own* result
type, without ever calling a `byte::` function, currently has no mechanism
to load `lib/byte.bot` at all: there is no `mod::TypeName` qualified
result-type spelling. This is the one real, load-bearing limitation of the
milestone's own scope decision (item 89's own anticipated gap) — not
special-cased away, and not silently worked around; `tests/source-types.
test`'s `source-type-cross-module` test demonstrates the *supported* shape
(a synthetic module whose *function* is referenced, carrying its type
along), which is exactly `byte.bot`'s own shape.

## Canonical integer-domain representation

One representation, reused everywhere: `core::type::NormalizeIntegerDomain`
(pre-existing) still produces `{interval LO HI}` / `{exact {V...}}`
(sorted, deduplicated by construction — this milestone's own duplicate
check runs *before* that, rejecting a duplicate as a declaration error
rather than silently canonicalizing it; see "Parser/surface" tests and
"Deferred features"). `hir/sourcetypes.tcl::CanonicalDomain` reshapes a
parsed `typedecl` domain into exactly that same `-integer-domain` input
shape and lets `core::type::register` do the one real canonicalization
pass — no `SourceIntegerDomain`/`RuntimeIntegerDomain`/`RangeIntegerDomain`
was added.

## Parent/subtype validation

`core::type::integerDomainSubset child parent` is the one generic
operation every combination of interval/exact child and interval/exact
parent goes through (no per-shape special-casing in the caller):

- interval ⊆ interval: bound comparison.
- exact ⊆ interval: every value within bounds.
- exact ⊆ exact: every value a parent member.
- interval ⊆ exact (the interesting case — a sparse parent): every integer
  in the child's own interval must be a parent member, checked by walking
  the interval (bounded by a declaration-time-only limit,
  `core::type::maxIntervalUnderExactParent = 100000`, distinct from
  `hir/range.tcl`'s own, separate 32-value *optimizer* budget — see next
  section). Sound and exact, not approximated by min/max alone: `Sparse =
  {1,2,4,5}`, `Child = Sparse in 1..2` is accepted; `Child = Sparse in 1..4`
  is rejected (`3` is missing) — `source-type-interval-under-sparse-exact`.

Parentage is checked one level at a time (child against its *direct*
parent's own domain), which is sufficient for transitivity by construction:
`C <: B`, `B <: A` each individually verified subset-safe implies `C <: A`
is subset-safe too — verified directly (`source-type-transitivity`, `A =
Int in 0..255`, `B = A in 0..31`, `C = B in 0..7`).

## Optimizer exact-set budget vs. semantic domain size

`hir/range.tcl`'s own `maxExactValues = 32` is an *analysis-precision*
budget (how large an exact-value fact the optimizer's own representation
tracks before widening to interval-only), pre-existing and untouched. This
milestone's own semantic domain size is unrelated and unbounded by that
number: a 40-value source-declared exact type (`tests/source-types.test`'s
`source-type-over-budget-exact-set-stays-semantically-exact`) keeps exact
checked-constructor semantics for every one of its 40 values (`Big(0)`,
`Big(78)` succeed; `Big(1)` fails with the same `{CORE SEMANTIC RANGE}` as
any other domain violation) while `hir::range::TypeFact` — which already
degrades gracefully via the pre-existing `Normalize` cap, needing no
change — represents it only as its interval hull `[0, 78]` once the
optimizer would need more than 32 exact values. No language-level
declaration limit exists for exact-set *size*; `maxIntervalUnderExactParent`
(100,000, previous section) is a distinct, narrower, purely compile-time-
cost bound on one specific validation shape, not on the type itself.

## HIR serialization

`hir::buildSyntax` stores its own `hir::sourceTypes` field: an ordered list
of `{name .. parent .. domain ..}` (dependency order, canonical domain
form). `hir::format` prints a preamble line per entry —

```
type Byte parent Int domain interval 0 255
type HighNibble parent Byte domain exact 0 16 32 48 ... 240
```

— before its existing `program ...` header; `hir::read::Program` consumes
any such leading lines first (`hir::read::TypeDecls`), re-running them
through the *same* `hir::sourcetypes::apply` a fresh source compile uses,
before parsing a single expression line. A plain HIR with no source types
is printed and read back byte-for-byte as before this milestone
(`source-type-hir-roundtrip-no-decls-unaffected`); one with source types
round-trips through `format`→`parse`→`format` identically, for both an
interval chain (`Byte`/`Nibble`) and a finite domain (`Tags`), with a
following `hir::range::TypeFact`/`core::type::subtype`/execution check
proving the reconstructed registration is not just textually identical but
semantically live (`source-type-hir-roundtrip-interval`,
`-hir-roundtrip-exact`).

## Constructor behavior

Every source-declared integer-domain type automatically gets a checked
constructor (`Small(x)`) and predicate (`Small?`), via
`core::type::declareIntConstructor` — the exact generic mechanism the four
migrated names always used, not a new implementation. Interp and compile
agree on both success and failure (`source-type-constructors-interp-
compile-parity`, `differential`). Cranelift's pre-existing limitation —
checked constructors have no native lowering (no core-IR "raise" primitive
a `-native-body` could compose) — carries over unchanged and is reported,
not silently compiled unchecked: `native-byte-constructors-cranelift-
unsupported` asserts the exact `{NATIVE UNSUPPORTED {native Byte}}` outcome
for a Byte constructor now declared in source, matching what the same call
raised when Byte was compiler-registered.

## Migration of Byte/Nibble declarations

`core/scalarbits.tcl` keeps only the five bitwise primitives (`bit_and`,
`bit_or`, `bit_xor`, `shift_left`, `shift_right`) and their registration;
the block that used to register `Byte`/`Nibble`/`LowNibble`/`HighNibble`
(`core::type::register` × 4, `core::type::definePredicate` × 4, a
`CheckedConstruct`/constructor-registration loop) is gone, replaced by a
one-paragraph comment pointing at `lib/byte.bot` and this document. Two
small, genuinely dead helper procs (`InRange`, `IsHighNibble` — never
actually called; the real registrations always used the generic
`-integer-domain` validator) were removed along with it rather than kept
"for safety."

`lib/byte.bot` gained 20 lines: four `type` declarations, matching the
milestone's own worked example almost verbatim —

```botlish
type Byte = Int in 0..255

type Nibble = Byte in 0..15
type LowNibble = Byte in 0..15

type HighNibble = Byte in {
    0, 16, 32, 48,
    64, 80, 96, 112,
    128, 144, 160, 176,
    192, 208, 224, 240
}
```

No existing function (`high_nibble`, `low_nibble`, `nibble`, `complement`,
`position_low`, `position_high`) changed at all — they still call
`bit_and`/`bit_or`/`bit_xor`/`shift_left`/`shift_right` and declare the
same result types by the same spellings. No caller changed either:
`byte::high_nibble` etc. are referenced exactly as before by `lib/web.bot`
and every test.

## Before/after: canonical metadata

|              | BEFORE (compiler Tcl)        | AFTER (`lib/byte.bot`)       |
|--------------|-------------------------------|-------------------------------|
| **Byte**     | `core::type::register Byte -base int -integer-domain {interval 0 255}` | `type Byte = Int in 0..255` |
| parent       | Int (no `-parents`)          | Int (no nominal parent)      |
| domain       | `{interval 0 255}`           | `{interval 0 255}`           |
| **Nibble**   | `-parents Byte -integer-domain {interval 0 15}` | `type Nibble = Byte in 0..15` |
| parent       | Byte                          | Byte                          |
| domain       | `{interval 0 15}`            | `{interval 0 15}`            |
| **LowNibble**| `-parents Byte -integer-domain {interval 0 15}` | `type LowNibble = Byte in 0..15` |
| parent       | Byte                          | Byte                          |
| domain       | `{interval 0 15}`            | `{interval 0 15}`            |
| **HighNibble** | `-parents Byte -integer-domain {exact {0 16 ... 240}}` | `type HighNibble = Byte in {0,16,...,240}` |
| parent       | Byte                          | Byte                          |
| domain       | `{exact {0 16 32 ... 240}}`  | `{exact {0 16 32 ... 240}}`  |

`Nibble`/`LowNibble` remain distinct siblings (identical domain, distinct
registry entries, neither a subtype of the other) both before and after;
`HighNibble` remains positioned (`0xA0` for `0xAB`'s high nibble, never
`0x0A`) — unaffected, since no arithmetic changed.

## Before/after: refined-checks facts, NIR/codegen

No independent before/after byte-count study was run; the evidence instead
comes from the pre-existing regression tests that assert *exact* values and
*exact* structural properties, run unmodified (their own expected results
were never edited by this migration):

- `native-refined-checks-cranelift-value` / `-compile-cranelift-agree`:
  `bench/refined-checks.ir` (which calls `web::high_nibble`) still computes
  `[400, 0]` on cranelift, compile, and interp alike.
- `native-byte-high-nibble-nir-is-mask-not-branch`: `byte::high_nibble`'s
  own NIR still lowers to a raw `iand` with no comparison/branch
  instruction, for an unconstrained argument.
- `native-refined-checks-no-old-ladder`: `lib/web.bot`'s own source text
  still contains no branch-ladder fallback and still calls
  `byte::high_nibble`/`byte::nibble`.

All three pass against the post-migration source unmodified. Since
`hir/range.tcl`, `native/lower.tcl`, and `native/src/**` are byte-for-byte
untouched by this milestone (`git diff` confirms it directly), and the
canonical domain metadata these tests' underlying facts are derived from is
identical before and after (previous section), this is treated as
sufficient evidence of no NIR/machine-code regression, rather than
re-deriving a separate function-count/byte-count table from scratch.

## Generic non-Byte demonstrations

`tests/source-types.test` is entirely Byte-independent (its own synthetic
`Small`/`Tags`/`A`/`B`/`C`/`Sparse`/`Big`/`Widget` types), and includes,
among others, exactly the two demonstrations items 143-144 ask for:

- `source-type-not-special-cased`: `type Small = Int in 10..20` used as an
  ordinary function's result type, verified and executed, with no compiler
  change specific to that name.
- `source-type-sparse-result-contract` / `-sparse-fact-seeding`: a
  synthetic 4-value sparse type (`{0,4,8,12}`) flowing through
  `bit_and(x,12)`, proven by the same generic exact-set transfer
  `hir/range.tcl` already had.

## Tests

New: `tests/source-types.test` (44 cases) — parser/surface, semantic
validation (cycle/unknown-parent/wrong-kind-parent/duplicate/empty-range/
empty-set/duplicate-exact-value/builtin-redefinition), domain-subset
validation (all four shape combinations), result contracts (valid/invalid/
sparse/interval-cannot-prove-sparse), constructors (success/failure/sparse/
interp-compile parity), nominal distinctness/explicit-parent/transitivity,
range/exact fact seeding (interval/sparse/dense-canonicalization), the
over-budget exact-set case, compilation isolation (repeated compile,
sequential non-leaking compile), module tests (same-module forward parent,
cross-module, unused-declaration-no-runtime-code), HIR round-trip
(interval, exact, and "no decls, unaffected"), and the `explain` diagnostic.

Updated: `tests/native-byte.test` (+6 cases: Byte/Nibble/LowNibble/
HighNibble checked-construction success/boundary/exact-vs-interval/
nominal-distinctness through the real module-loaded `byte.bot`, plus the
Cranelift-unsupported-constructor case); `tests/refined-signatures.test`
(its `HighNibble`-shaped generic-machinery tests now declare a local
`HighNibble` instead of relying on global registration — items 106, 135 —
and its Byte-vertical-specific domain/subtype tests now load `byte.bot` for
real, `loadByteLibrary`); `tests/scalarbits.test` (Byte-domain-specific
raw-IR tests removed — `Byte` is no longer a root native — bitwise-
primitive tests unchanged); `tests/surface-lexer.test` /
`tests/surface-parser.test` (the four obsolete "`..` is reserved" tests
rewritten for `..`'s new, real meaning).

Full suite: `tclsh9.0 tests/all.tcl` (interp + compile backends) — 1634+44
cases (excluding the small number of newly-added/adjusted files' own
counts, recounted after this migration), all passing. Targeted
native/Cranelift parity: `tests/native-byte.test`,
`tests/native-bitshift.test`, `tests/native-tiny-leaf-inline.test`,
`tests/hir-closed-call-params.test`, `tests/hir-range-bitop.test`,
`tests/hir-range-exact.test` — all passing unmodified (bar the two files
above whose only changes were removing a stale global-registration
assumption, not their actual assertions).

## Deferred features / explicit non-goals

Everything the brief marks out of scope stayed out of scope: no type-level
expression evaluation or compile-time metaprogramming (a domain is parsed
directly into a descriptor, never evaluated); no parameter-type
annotations (`fn f(x: T)` remains unsupported — result-only, as before); no
union/intersection/domain-algebra syntax; no arbitrary predicate
refinements; no inferred parent (`Parent` is always explicit); no alias
syntax; no enums, no structural/record types, no fixed-width runtime
representation, no new runtime tag, no hidden source-defined validator
function (validity is decided by the same generic
`IntegerDomainValidator`/`integerFacts` every refined int type already
used); no first-class types or runtime reflection over them; no ASCII/
String/Bytes work; no expansion of native checked-constructor support (the
Cranelift limitation is preserved, not solved); no broadening of tiny-leaf
inlining or a new call-site budget (both explicitly untouched, per the
brief's own item 133-134/139); duplicates in a finite domain are rejected
(a declaration error), not silently canonicalized — the deliberate,
documented choice for item 41, matching this milestone's general
preference for rejecting likely-mistaken input over silently accepting it.

A fuller compilation-scoped type environment — where two live, colliding
same-spelled declarations from different builds could coexist correctly
for as long as their own compiled artifacts are separately in use — is the
one architectural extension this milestone deliberately leaves for later,
documented in "Compilation isolation" above rather than attempted; it would
require threading a compilation identity through every `core::type`/
`core::native` lookup site, which is a different, larger piece of work than
adding the language feature itself.
