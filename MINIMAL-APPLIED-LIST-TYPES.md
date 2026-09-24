# Minimal applied List[T] types

Botlish type annotations can now name an *applied* type:

```botlish
fn consume(xs: List[Small]) -> Int:
    ...
```

`List[T]` is the one type constructor this milestone registers. The syntax,
the resolution mechanism, and the internal representation are all generic
over the constructor's *name* -- nothing in the parser, the resolver, or
the diagnostic formatter is specific to the word "List" -- so a future
`ImmutableSet[T]` needs another registry entry and a `MakeSet`-shaped
builder, never a grammar or representation change.

## Outcome

Implemented and regression-tested, exactly to the milestone's stated
scope. `List[T]` parses (including recursively, `List[List[T]]`),
resolves against a small generic type-constructor registry, is retained as
ordinary HIR metadata in `declaredParamTypes`/`declaredResult`, and is
enforced at parameter and result boundaries by one small addition
(`hir::range::ProvesValueAcceptedBy`) factored out of the two existing
admissibility checks (`verifyDeclaredParams`/`verifyDeclaredResults`) from
STRICT-TYPED-PARAMETERS.md. Ordinary (non-specialization) semantic
inference now also computes a List value's concrete element type, using
the *same* `{list ELEM}` structural form `hir/types.tcl` already used
internally for specialization's own aggregate facts -- not a second,
parallel representation. The canonical existing List element-read
primitive (`list_get`) statically returns `T` for a `List[T]` argument,
and that recovered `T` composes with zero new code with the pre-existing
bounded-integer Range machinery (`List[Small] -> Small -> [0, 10]`).
Typed-callable escape soundness (the immediately preceding milestone)
needed no change at all: a function whose only declared parameter is
`List[Small]` is still, by the pre-existing, unmodified `hir::callables::
Bearing`, a "typed callable," so passing it through an untyped
higher-order parameter is still rejected.

New: `tests/applied-types.test`, 51 cases. Full suite (`tclsh9.0 tests/
all.tcl`, interp and compile backends, native backend built with `cargo
build --release`): **1819/1819 passing, 0 failed**, including the new file
and every pre-existing test (two of them intentionally updated -- see
"Tests" -- to reflect *more precise*, not different, inferred types).
`cargo test --release --manifest-path native/Cargo.toml`: **60/60
passing**, no Rust source changed. GC-stress (`BOTLISH_NATIVE_GC_STRESS=1
tclsh9.0 tests/all.tcl`): see "Tests" for the confirmed count.

## Motivating future signature

```botlish
fn set(chars: List[UnicodeChar]) -> ImmutableSet[Byte]:
    ...
```

This milestone builds only the `List[T]` half of that signature's
plumbing: generic applied-type syntax/resolution, and the fact that a List
parameter's element type is real, usable, compositional static
information (not a runtime check). `UnicodeChar`, character literals,
`ImmutableSet[T]`, and `byte::set` itself remain entirely unimplemented,
exactly as scoped.

## Type-expression syntax

```
TypeExpr := TypeName
          | TypeName "[" TypeExpr "]"
```

`surface::parser::TypeExpr` (new, `surface/parser.tcl`) is the one place
this grammar lives, replacing the single-`IDENT` consumption a parameter's
`: T` and a suite's `-> T` used before. It is syntactically generic over
the head name -- it does not know "List" is special -- and recursive, so
`List[List[Small]]` needs no separate rule.

The grammar is **unary-only by choice** (spec item 7's first option): a
bracketed type argument is exactly one `TypeExpr`, never a comma list. This
was not merely "simpler to implement": `hir/read.tcl`'s HIR text format
already used `,` to separate a *refined* type's evidence names
(`int[Small,Tiny]`) and a block's parameter list (`b1 x:T, b2 y`), so a
comma-separated type-argument list would have made an applied type's own
serialized text ambiguous with those existing conventions without a new
escaping rule. Unary syntax sidesteps that for free, and `List` is the
only constructor this milestone needs anyway. `List[A, B]` is therefore
already a syntax error (the comma is simply not part of a `TypeExpr`), not
a semantic arity error -- pinned directly (`applied-type-malformed-comma-
arity`).

**Representation**: an absent annotation is still `""`, exactly as
before. A **bare** name (no brackets) is still the *plain string*
`"Small"` -- byte-identical to the pre-milestone representation, which is
why every existing bare-type-name test (`typed-param-parse-1`, `-2b`,
`-3`, `-5`, `-9`, ...) needed no change at all. An **applied** type is the
2-element list `{NAME ARG}`, `ARG` itself a `TypeExpr` (so `List[Small]` is
`{List Small}`, and `List[List[Small]]` is `{List {List Small}}`). Since a
lexed identifier can never itself be a multi-word Tcl list, `llength
$typeExpr == 1` is an exact, unambiguous test for "bare name" with no
sentinel tag needed.

This representation is carried unchanged through `surface/lower.tcl`
(`paramTypes`/`resultType` were already opaque per-parameter payloads) and
`hir/syntax.tcl`'s `blockNode` (which only checks list *length*, never
interprets an entry's contents), so neither file needed a code change.

## Canonical applied-type representation

There is exactly one structural form: `{list ELEM}`, where `ELEM` is
itself a resolved type. This is **not a new representation invented for
this milestone** -- it is the aggregate-fact form `hir/types.tcl` already
used, exclusively during `hir::specialize`'s own per-instance region
inference, before this work started (its own file header already
documented it: "`{list ELEM}` a list whose every element has static type
ELEM"). This milestone's actual change is narrower than it looks: making
that pre-existing form (a) reachable from ordinary (non-specialization)
semantic inference, and (b) reachable from a source type annotation via
resolution, rather than inventing a second parallel "applied type" concept
that would have needed its own equality, `show`, `subtype`, and `lub`
rules independently of the ones `hir/types.tcl` already had.

Nesting composes for free through the existing `MakeList`/`Bound`/
`Unshaped` machinery: `List[List[Small]]` resolves to `{list {list
{refined int {Small}}}}` by applying the same `MakeList` call twice, one
level at a time, with no new nesting-specific code.

## Type constructor registration and resolution

`hir/types.tcl` gains a small generic registry:

```tcl
variable constructors [dict create List 1]     ;# NAME -> arity
```

and two procs:

* `hir::types::resolveNamed NAME` -- the canonical type for a *bare* name:
  `core::type::normalize NAME` (unchanged) unless `NAME` is itself a
  registered constructor, in which case it is an arity error ("`List`
  requires 1 type argument(s)"), not "unknown type" (spec item 5).
* `hir::types::resolveApplication CTOR ARGTYPES` -- the canonical type for
  `CTOR` applied to (already-resolved) `ARGTYPES`: unknown-constructor,
  not-a-constructor (`core::type::valid CTOR`, i.e. an ordinary named/
  primitive type used with brackets), and arity are each their own
  rejection; `List`'s own case is the only `switch` arm, `[MakeList
  [lindex $argTypes 0] {} 0 0]`.

`hir::resolve::ResolveTypeExpr` (new, `hir/resolve.tcl`) is the bridge:
for a bare `TypeExpr` it calls `resolveNamed`; for an applied one it
resolves the argument first (recursively) and calls `resolveApplication`.
It replaces the two `core::type::normalize $paramType`/`$declared` calls
`hir/resolve.tcl`'s block-processing loop already had -- everywhere else
(diagnostics, module signatures, HIR format/read) is unaffected by
construction, because those call sites only ever see the *already-resolved*
type value, never the raw `TypeExpr`.

Both new procs live in `hir/types.tcl`, not `core/type.tcl`: `{list ELEM}`
is not a valid *core* type (`core::type::normalize` would reject it --
confirmed directly, `core::type::normalize {list int}` raises "malformed
type"), because it is a **static/HIR-level** extension of the value-type
lattice, exactly the layer `hir/types.tcl`'s own file header already
described ("static types more precise than value types"). `core/type.tcl`
is untouched by this milestone -- zero lines changed, confirmed by `git
diff --stat`.

## Why this is not general generics

* No user-defined type constructor: `List` is the only registered name,
  hardcoded in one `dict create` and one `switch` arm. There is no `type
  Box[T] = ...` declaration form.
* No generic function/method declarations: `fn identity[T](x: T) -> T:`
  does not exist and was not added. `list_get`'s own "argument 0 is
  `List[T]`, result is `T`" behavior is the *existing* `-result-shape
  {element 0 1}` native-metadata mechanism (`core/lists.tcl`, pre-dating
  this milestone), not a source-level generic function.
* No unification/inference variables: nothing introduces `α`/`T0`/`?Element`.
  The only "inference" this milestone does is computing a *concrete*
  element type from a list literal's own already-typed elements (an LUB
  fold, `hir::types::MakeList`) -- never solving for an unknown.
* No contextual/bidirectional typing: `f([1, 2])` against `f(xs: List
  [Small])` is not magically `List[Small]`; `[1, 2]`'s type is decided
  from the literals alone, exactly as `combine(1, 2)` was before typed
  parameters existed.

`type Small = Int in 0..10` (a **nominal** declaration, `hir/sourcetypes.
tcl`, pre-existing) and `List[Small]` (a **structural** application of an
existing constructor to that nominal argument) are deliberately different
mechanisms: the former adds a new name to the compilation's type registry
with its own domain/parent facts; the latter builds an ordinary composite
value from names that already exist, the same way `{refined int {Small}}`
itself is a structural composition of the primitive `int` and the
nominal name `Small`. `List[Small]` created in two separate places in one
compilation is the *same* semantic type because it is built from the same
constructor identity and the same argument identity -- no second
`Small`-specific registration is needed, and none is done.

## List[T] semantic identity (spec 10, 83-88)

Equality is **structural**, recursively over constructor identity and
argument identity -- literally Tcl list `eq` on two already-canonical
`{list ELEM}` values, never a formatted-string comparison. `List[Small]`
and `List[Tiny]` are distinct applied types even though `Tiny <: Small`
(`applied-type-semantic-equality`); two independent `List[Small]`
applications in the same compilation are the identical value structurally
(`applied-type-structural-not-nominal`), so no synthesized global name like
`"List[Small]"` is ever registered anywhere -- confirmed by `git diff`
touching no code path near `core::type::register`.

This is deterministic and stable because element types are already
canonical (`core::type::normalize`'s own `Make` sorts/dedupes evidence),
so two structurally-equal applied types are always Tcl-`eq`, and the
existing `dict`/interning machinery (`hir::types::intern`, which already
used the type value itself as a dict key before this milestone) needed no
change to keep working correctly for the new form.

## List mutability audit (spec 17-18, 25, 104 Q17-18)

Audited directly (`core/lists.tcl`): List has exactly three native
operations, `list_length`, `list_get`, `list_append`. `list_append`
*returns a new list*; it does not mutate its argument (`Items`/`lappend`
operate on a **copy** taken from the input list's items, and the input
list value itself is never written back into). Botlish's runtime has a
wholly separate `MutableArray` abstraction (`core/mutarray.tcl`,
`mutable_array_allocate`/`_get`/`_set`) for the one case where in-place
mutation is actually needed. **List is immutable/persistent** -- there is
no operation that could observe two aliases of "the same List" diverge.

## Initial invariance rule (spec 24-26, 40-42, 69-70)

Despite List being immutable (which *would* make covariance sound), this
milestone deliberately keeps `List[T]` admissibility **invariant**:

```
List[A] admissible as List[B]  iff  A and B are the identical resolved type
```

Reusing `hir::types::subtype`'s existing List handling was considered and
rejected: that function's list case is *covariant* by design (`subtype
{list A} {list B}` recurses into `subtype A B`), because it exists to
support `hir/specialize.tcl`'s own positional-shape lattice (used for
specialization-key subsumption, an unrelated internal concern this
milestone must not disturb) -- reusing it for applied-type admissibility
would have silently made `List[Tiny]` satisfy a `List[Small]` parameter
via `Tiny <: Small`, which spec item 70 explicitly asks to reject in this
milestone. Nor does `ProvesType` apply: it means integer-domain value-set
membership, and `core::type::integerFacts {list ...}` simply raises (a
`{list ...}` type has no `base`).

So `hir::range::ProvesValueAcceptedBy` (new, factoring what spec item 42
asked for) dispatches once, explicitly:

```tcl
proc hir::range::ProvesValueAcceptedBy {argType argRange declared} {
    if {[hir::types::IsList $declared]} {
        return [expr {[hir::types::Unshaped $argType] eq $declared}]
    }
    return [expr {[hir::types::subtype $argType $declared] || [ProvesType $argRange $declared]}]
}
```

-- an applied `declared` type is checked by exact equality (after
stripping the argument's own *positional* shape, see "List construction"
below); an ordinary `declared` type keeps exactly STRICT-TYPED-PARAMETERS.
md's original two-part proof, completely unchanged. Both
`verifyDeclaredParams`'s `VerifyCall` and `verifyDeclaredResults` now call
this one shared proc instead of duplicating the `subtype`-or-`ProvesType`
disjunction inline -- the factoring spec item 42 asked to consider, done
because applied types made the two call sites' logic actually diverge for
the first time.

This also means scalar admissibility is **not** automatically lifted
through `List`: `take_a(B-value)` (scalar, `A`/`B` independent same-domain
`Int in 0..3` siblings) remains valid from STRICT-TYPED-PARAMETERS.md, but
`take_ListA(List[B])` is rejected -- pinned side by side
(`applied-type-invariant-sibling-scalar-still-valid` /
`applied-type-invariant-sibling-rejected`). A scalar admissibility proof
concerns one value at one call boundary; a container's compatibility rule
is a policy about the container's *own* element-identity contract (what
future code reading from it is entitled to assume), which is a strictly
stronger, and deliberately more conservative, question -- especially
before any variance/aliasing audit exists for a future mutable or
reference-like container.

## List construction element inference (spec 15-21)

`core/primitives.tcl`'s `list` native (what `[a, b]` lowers to) already
carried `-result-shape elements`; `core/lists.tcl`'s `list_get`/
`list_append` already carried `-result-shape {element 0 1}`/`{append 0
1}`. Before this milestone, `hir::types::Call` only consulted
`-result-shape` while `hir/specialize.tcl` was running its own per-
instance region inference (`inferRegion`, gated by `$spec` in the code).
This milestone's one change to `hir::types::Call`: it now consults
`-result-shape` **unconditionally**, in ordinary whole-program semantic
inference too, whenever the call is not already dead. No new inference
code was written for element typing -- `ShapeResult`/`MakeList`, both
pre-existing, do all of it.

**Positional shape is deliberately stripped outside specialization.**
`MakeList`'s pre-existing behavior can produce a 3-element *shaped* form
(`{list ELEM {P0 P1 ...}}`) for a small (`<= 8`), not-fully-uniform list --
this is exactly what already let `hir/specialize.tcl` track e.g. `[1,
"a"]`'s two positions separately. Feeding that form straight into ordinary
inference would have two bad consequences: (a) `[tinyValue, smallValue]`
(item 17's own required case: `Tiny <: Small`, `lub(Tiny, Small) = Small`)
would keep its *shaped* form (`{list Small {Tiny Small}}`) rather than
collapsing to plain `List[Small]`, even though the milestone explicitly
wants it to; and (b) that shaped form would need a second HIR round-trip
notation (`ParseType` would need to parse "list[Tiny, Small]" too). So
`hir::types::Call`, when *not* specializing, applies the pre-existing
`hir::types::Unshaped` to the `ShapeResult` output before using it:

```tcl
if {!$dead && [dict get $meta resultShape] ne ""} {
    set result [ShapeResult $hir [dict get $meta resultShape] $argExprs $argTypes $result]
    if {!$spec} {
        set result [Unshaped $result]
    }
}
```

`hir/specialize.tcl`'s own region inference (`$spec` true) is completely
unaffected -- it still gets the full shaped form exactly as before this
milestone, confirmed by `hir-specialize-14`/`-16`/`-17` passing unmodified
in *behavior* (their expected *text* needed updating only because
`hir::types::show`'s own notation changed, see "Tests").

* **Homogeneous** (`[one(), two()]`, both `Small`): `List[Small]`
  (`applied-type-construct-homogeneous`).
* **LUB across a subtype sibling** (`[tinyValue, smallValue]`, `Tiny <:
  Small`): `List[Small]`, because `Unshaped` strips the shape once the
  fold's own `elem` already equals `Small`
  (`applied-type-construct-lub-sibling`).
* **Same-domain siblings, no parent relation** (`[A-value, B-value]`, `A`/
  `B` both independently-declared `Int in 0..3`): neither `List[A]` nor
  `List[B]` -- the element LUB has no shared evidence, so it is the broad
  `int`, giving `List[int]`
  (`applied-type-construct-same-domain-siblings-not-conflated`).
* **Heterogeneous** (`[1, "x"]`): element LUB is `any`, so `MakeList`'s
  own pre-existing rule collapses it to the plain, pre-existing `list`
  kind -- never a false `List[int]`/`List[str]`
  (`applied-type-construct-heterogeneous`).
* **Empty** (`[]`): `{list never}` (`List[never]` when shown) --
  `MakeList`'s own pre-existing "no elements, fold starts at `never`"
  result. It satisfies no `List[T]` parameter (`applied-type-construct-
  empty`), with no contextual-typing special case added to rescue it, per
  spec item 20-21's explicit choice.

## Parameter and result contracts (spec 23, 27-28)

`hir::types::Block` needed **no change**: it already seeds a declared
parameter's binding with its declared type directly
(`STRICT-TYPED-PARAMETERS.md`'s own mechanism), and that seeding is
type-shape-agnostic -- `List[Small]` flows through exactly the same one
line of code a scalar `Byte` always did. So `applied-type-param-body-fact`
confirms `xs`'s declared type inside `consume(xs: List[Small])` is
unconditionally `List[Small]`, with no caller in the program at all.

Parameter/result verification (`hir/range.tcl`'s `VerifyCall`/
`verifyDeclaredResults`) needed exactly the one-line swap to
`ProvesValueAcceptedBy` described above, plus fixing two pre-existing
diagnostic-formatting call sites that had been calling `core::type::show`
(the interpreter's own, `{list ...}`-ignorant formatter) directly instead
of `hir::types::show` -- invisible before this milestone because a
declared type was always a plain core type, and a real bug this milestone
would otherwise have shipped with an uncaught Tcl error ("`core::type:
malformed type "list ..."`") on the very first applied-type rejection
diagnostic. Both are now `hir::types::show`, matching every other
diagnostic call site.

## Element-read projection (spec 29-33, 58, 71, 90-93)

`list_get`'s own pre-existing `-result-shape {element 0 1}` metadata
already says "argument 0 must be a list; the result is argument 0's
element type" -- exactly spec item 58's own suggested shape, and it
needed **zero changes**. Making `hir::types::Call` consult it in ordinary
inference (the one change described above) is what makes `list_get(xs,
0)` on a `List[Small]`-typed `xs` statically return `Small`.

**The vertical proof** (spec 90-93) needed no new code either:
`hir::range::ConstrainType`, called on every call's result inside
`hir::range::Call`, already intersects the flow range with `TypeFact
(hir::typeOf ...)` -- and `hir::typeOf` for `list_get(xs, 0)` is now
`Small`, so `TypeFact(Small)` (the pre-existing `core::type::integerFacts`
lookup) already yields `[0, 10]` with no List-specific code anywhere in
`hir/range.tcl`. `applied-type-element-read-range-fact` pins this
end-to-end, through `hir::range::AnalyzeInstance`, the same local proof
pass `verifyDeclaredResults` itself uses.

`list_get`'s existing bounds behavior (a `{CORE SEMANTIC RANGE}` error for
an out-of-range index) is completely unchanged -- confirmed directly
(`applied-type-element-read-preserves-bounds-error`); only the
*successful* value's static type improved.

**Iteration**: Botlish has no dedicated loop-over-a-list traversal
construct in the surface language today (`loop` is a bare `while true`-
style construct with no iterator binding), so spec item 32's "propagate T
to a traversal binding if one exists and is localized" has nothing to
attach to. `list_get` is the one canonical read primitive, and it is
covered.

## Interaction with source-defined scalar domains (spec 82)

A `List[Small]` type argument obeys exactly the same visibility/resolution
rules ordinary declared parameter/result types already did: `hir::
sourcetypes::apply` registers every `type X = Y in D` declaration before
`hir::resolve::program` runs at all, so a forward reference to a
same-file `type Small = ...` inside a `List[Small]` annotation resolves
correctly regardless of declaration order -- no special-casing was added
inside brackets (`applied-type-source-defined-argument`).

## Scalar-domain / sparse exact-set vertical proof (spec 91-93)

The `[0, 10]` proof above is the interval case; a sparse exact-set element
type composes exactly as compositionally, through the *identical*,
unmodified path (`core::type::integerFacts` already special-cases an
`exact` integer domain the same way it does an `interval` one) -- no
separate test was needed to demonstrate this since no List-specific code
exists in that path at all to have a separate failure mode for sparse
domains.

## Container erasure vs. callable-contract erasure (spec 14, 36, 76)

These are deliberately different outcomes, and both are tested side by
side:

* **Container erasure is sound as mere lost precision.** `fn passthrough
  (x): x` erases a `List[Small]` argument's element type to `any`/broad
  `list` (an untyped parameter has no declared type to seed with, exactly
  as before this milestone) -- `passthrough(xs)` **alone** remains legal
  (`applied-type-erasure-passthrough-alone-is-legal`). Only a *later*
  typed use of the now-imprecise value is rejected: `consume(passthrough
  (make_smalls()))` fails, because `consume`'s own parameter check
  (`ProvesValueAcceptedBy`) correctly finds no proof, not because erasure
  itself was disallowed (`applied-type-erasure-vs-consume`). No runtime
  re-validation is ever inserted to "rescue" the erased value.
* **Callable-contract erasure remains a soundness rejection**, unchanged,
  because that is a *caller obligation* problem
  (`TYPED-CALLABLE-ESCAPE-SOUNDNESS.md`'s own distinction), not a mere
  loss of proof precision: `hir::callables::Bearing` still flags `consume`
  (whose only parameter is `List[Small]`) as a typed callable purely
  because `declaredParamTypes` has a non-empty entry -- it never inspects
  *what shape* that entry is -- so `apply(consume, [one()])` (an untyped
  higher-order call) is still rejected by the completely unmodified
  `hir::callables::verify` pass (`applied-type-callable-escape-still-
  rejected`). Exact aliasing (`f = consume`) remains fully first-class,
  also unaffected (`applied-type-callable-escape-exact-alias-still-
  legal`).

The distinction is architectural, not incidental: a container's element
type is a fact about *values already in the caller's hands*, so losing it
only weakens what the compiler can later prove about that particular
value. A function's parameter type is a fact about *what every future
caller must supply*, so losing the connection between a callable value and
its declaring block would let some already-compiled call site's argument
go unchecked entirely -- a real soundness hole, not merely a less precise
type.

## Typed-callable soundness regression (spec 38, 75, 106 Q27)

Directly audited: `hir::callables.tcl` was not touched by this milestone
at all (`git diff` confirms zero lines changed). It remains correct
automatically because `Bearing`'s own contract ("`>= 1` non-empty
`declaredParamTypes` entry") already generalized over type *shape*, never
assuming a declared type was a flat scalar.

## HIR serialization (spec 43-44)

`hir::types::show`'s own `list` case (already the single, pre-existing
"canonical formatter" for every static type, `hir/types.tcl`) grew a
second branch: the pre-existing 3-element *shaped* form keeps its old
`list[P0, P1, ...]` notation (an internal, never-source-spellable
specialization concept -- see "List construction" above), while the
2-element *unshaped* form -- the only one a declared `List[T]` annotation
or ordinary post-milestone inference now produces -- renders as `List[T]`,
matching the source syntax directly (so a diagnostic quoting it is
directly source-legible). Per the codebase's own pre-existing convention
(a refined scalar type already shows as `int[Small]`, never bare
`Small`), a `List[Small]` parameter shows as `List[int[Small]]` -- one
formatter, reused consistently, not two drifting ones.

`hir::read::ParseType` grew the exact inverse: `^List\[(.+)\]$`, greedy
(so it correctly finds the *last* `]` even for `List[List[...]]`),
recursing into `ParseType` on the captured inner text. The existing
lowercase `^([a-z]+)\[...\]$` regex (for `int[Small]`-style refined types)
is untouched and cannot collide, since it requires an all-lowercase head
and `List` is capitalized by design.

`applied-type-hir-roundtrip`/`-nested` prove `format -> parse -> format`
is byte-identical for a program using `List[Small]` in both parameter and
result position, and for a nested `List[List[Small]]` parameter;
`applied-type-hir-roundtrip-preserves-type` proves the read-back HIR's
`declaredParamTypes` is a live, structurally-equal applied type, not just
round-tripped text.

One incidental, backward-compatible fix was needed in `surface/ast.tcl`'s
debug pretty-printer: it built a parameter list's text via bare
`"($params)"` string interpolation of a Tcl *list* value, which (only
once an element could contain `[`/`]`, i.e. only once an applied type
existed) triggers Tcl's own eval-safety brace-quoting of that one
element. Switched to an explicit `[join $params { }]`, which produces
byte-identical output to the old behavior for every pre-existing (bracket-
free) case and the intended unbraced text for the new one
(`applied-type-parse-canonical-format`).

## Module signatures and cross-module behavior (spec 45, 74)

`hir::moduleSignatures` needed **no change**: it already reported each
exported function's real `declaredParamTypes`/`resultType` entries
verbatim (STRICT-TYPED-PARAMETERS.md's own prior update), so an applied
type simply flows through the same field unmodified
(`applied-type-module-signature`). Cross-module enforcement needed no
change either, for the same reason STRICT-TYPED-PARAMETERS.md's own
cross-module tests needed none: `surface/modules.tcl` combines a program
and every module it loads into one HIR before any checking runs, so a
cross-module call is, by the time `verifyDeclaredParams` sees it, an
ordinary direct call with a fully resolved target
(`applied-type-cross-module-valid`/`-invalid`).

## Runtime representation and codegen impact (spec 94-97)

No runtime file changed (`core/**` is untouched; `native/lower.tcl` and
every `native/src/**` Rust source are untouched -- confirmed by `git diff
--stat` and by `cargo test` needing no rebuild-affecting change). A
`List[Small]` value is represented at runtime exactly like an ordinary
List always was: no packed storage, no per-list generic tag, no
specialized allocation shape. `hir::specialize`'s own specialization-key
generation is unaffected by this milestone (its own key text already
distinguished list *element types* before this milestone, via the same
`hir::types::show`-based `label` proc `native/lower.tcl`'s own `instance=`
NIR attribute also reuses) -- this milestone changed that function's
*notation* (`list<int>` to `List[int]`), never its *behavior*, so
`List[Small]` and `List[Tiny]` were and remain distinguished by
specialization exactly when their element types already differed, with no
new distinguishing power added or removed by this work.

## Tests

New: `tests/applied-types.test`, 51 cases -- syntax (bare-name backward
compatibility, applied, nested, result position, canonical AST
formatting, four malformed-syntax parse failures, the unary-only comma
rejection), resolution (unknown constructor, not-a-constructor, bare-List
arity, unknown type argument, a source-defined argument), semantic
identity (structural equality vs. nominal subtype, cross-application
structural sharing), HIR round-trip (`show`, nested `show`, format/parse/
format identity for flat and nested applied types, live re-read type),
module signatures, List construction (homogeneous, LUB-across-a-subtype-
sibling, same-domain-siblings-not-conflated, heterogeneous, empty),
parameter contracts (accepted, rejected-broad, rejected-non-list,
caller-independent body fact), result contracts (accepted, rejected),
the invariant-sibling and invariant-subtype-element required rejections
(each paired with the scalar case that remains valid, to make the
contrast explicit), element-read type/range-fact/bounds-preservation,
alias and return propagation, the erasure-vs-consume soundness contrast,
cross-module (valid and invalid), typed-callable escape regression (still
rejected; exact alias still legal), and repeated/sequential compilation
isolation.

Two pre-existing tests needed their *expected value* updated, not
weakened: `types-2` and `hir-type-3` each construct a one-element `[n]`
list at the HIR level and print its inferred type; that type is now the
strictly more precise `List[int]` instead of the previous bare `list`,
which is exactly this milestone's own stated goal. Several
`hir-specialize.test`/`native.test` cases had hardcoded
`hir::types::show`-derived label/key text (`list<int>` /
`grow<list<never>, int>` / a NIR `instance="list<int>, int"` attribute)
that needed the same mechanical `list<T>` -> `List[T]` notation update,
with **zero change to any of those tests' actual assertions or observed
program behavior** -- confirmed by re-running each file and diffing only
the textual constant, never the logic. Two `examples/hir/*.hir` sample
fixtures (`04-refinement.hir`, `06-refined-strings.hir`) needed the same
one-line regeneration for an internal `[]`/heterogeneous-list construction
whose inferred type text changed from `list` to `List[never]`/
`List[result]`; both were regenerated mechanically (`hir::format
[hir::build [hir::lower [hir::readFile ...]] -strict 0]`) and diffed to
confirm the change was exactly, and only, that one annotation.

`tclsh9.0 tests/all.tcl` (interp and compile backends, native backend
built with `cargo build --release`): **1819/1819 passing, 0 failed**,
including the new file, with no regression in any pre-existing test.
`cargo test --release --manifest-path native/Cargo.toml`: **60/60
passing** (no Rust source changed by this milestone).
GC-stress (`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`): **1819/1819
passing, 0 failed** -- identical to the ordinary run, confirming no
rooting/allocation-behavior regression from this milestone's own HIR
construction changes.

## Deferred (unchanged from the brief)

`UnicodeChar`, character literals, `ImmutableSet[T]`, `byte::set`, ASCII
work, predicate/flow refinement (`if List::all(xs, Small?): ...`),
variance (covariant or contravariant), user-defined generic type
constructors or functions, typed locals, contextual/bidirectional list-
literal typing, casts, a checked broad-to-`List[T]` conversion function,
and any representation specialization (packed/unboxed/monomorphized List
storage) -- none of these were added, and every one of the "was X added?"
questions below is "no."

## Required architecture questions

1. **Canonical internal representation of `List[T]`?** The pre-existing
   `hir/types.tcl` structural form `{list ELEM}` -- the same one
   specialization's own aggregate-fact inference already used.
2. **Structural or globally registered per application?** Structural: two
   applications of `List` to the same argument type are the identical
   value by Tcl-list equality; nothing is registered in `core::type`'s
   (or any other) global name registry for an applied type.
3. **How is a type constructor distinguished from an ordinary named
   type?** Membership in `hir::types::constructors` (`dict create List
   1`), a table entirely separate from `core::type`'s own named-type
   registry.
4. **How is constructor arity checked?** `hir::types::resolveApplication`
   compares the resolved-argument-list length against the registry's
   arity number for that constructor name.
5. **Is the parser generic over constructor names?** Yes --
   `surface::parser::TypeExpr` recognizes `NAME "[" TypeExpr "]"`
   for any identifier `NAME`; it never checks that `NAME` is `"List"`.
6. **Can a future `ImmutableSet[T]` reuse the syntax and internal
   representation without parser changes?** Yes (as designed and stated
   above) for the *syntax* and the *resolution mechanism* (one more
   registry entry and `switch` arm). Its own *resolved-type* shape would
   need its own small structural form analogous to `{list ELEM}` (e.g.
   `{set ELEM}`) inside `hir/types.tcl`, plus `subtype`/`lub`/`show`
   arms for it there, exactly mirroring how `{list ELEM}` itself is
   defined today -- no new *architecture* is needed, only the same
   pattern repeated once.
7. **How does a List literal acquire its element type?** Through
   `-result-shape elements`, pre-existing native metadata on the `list`
   native (`core/primitives.tcl`), now consulted by ordinary (not just
   specialization) `hir::types::Call`.
8. **What happens for heterogeneous elements?** The element LUB fold
   (pre-existing `hir::types::MakeList`) reaches `any`, which collapses to
   the plain, pre-existing broad `list` kind -- never a false precise
   `List[T]`.
9. **What happens for an empty List?** `{list never}` (shown as
   `List[never]`) -- `never` is `MakeList`'s own fold starting value with
   zero elements to fold over; it satisfies no `List[T]` parameter.
10. **What existing operation recovers `T` from `List[T]`?**
    `list_get`'s pre-existing `-result-shape {element 0 1}`.
11. **Does that operation seed existing scalar facts for `T`
    afterward?** Yes, through the pre-existing, unmodified
    `hir::range::ConstrainType`/`TypeFact` -- no new code.
12. **Does any runtime List object carry generic metadata?** No.

## Required semantic questions

13. **Is `List[A]` nominally the same as `List[B]` when `A`/`B` have equal
    numeric domains?** No -- structural equality compares the resolved
    element *type* (by name/evidence), not the numeric domain it
    happens to admit.
14. **Is scalar admissibility automatically lifted through List?** No.
15. **Is `List[Tiny]` accepted as `List[Small]` because `Tiny <: Small`?**
    No, by explicit design (the initial invariance rule).
16. **Why is List invariant initially?** List is in fact immutable, which
    *would* make covariance sound -- but this milestone deliberately does
    not add a general variance system merely because one instance happens
    to be safe; the concrete payload (`List[UnicodeChar]`) needs exact
    equality, not covariance, and reusing the pre-existing (covariant)
    `hir::types::subtype` list case would have been reusing code built
    for an unrelated purpose (specialization-key subsumption) rather than
    a deliberate soundness decision.
17. **What are the actual existing List mutability semantics?**
    Immutable/persistent: `list_append` returns a new list and never
    writes through its argument; mutation exists only via the separate
    `MutableArray` abstraction.
18. **Does losing `List[T]` through an untyped value constitute a
    soundness failure or merely lost proof precision?** Lost precision --
    demonstrated directly (`applied-type-erasure-passthrough-alone-is-
    legal`), contrasted with the callable case, which *is* a soundness
    concern and remains rejected.
19. **Can a broad List later be passed to `List[T]` without recovering
    proof?** No.
20. **Is any runtime scan inserted to recover that proof?** No.

## Required integration questions

21. **Can `List[Small]` be used in a typed parameter?** Yes.
22. **Can it be used in a declared result?** Yes.
23. **Does a direct call enforce it before backend selection?** Yes --
    `hir::range::verifyDeclaredParams`/`verifyDeclaredResults` run inside
    `hir::buildSyntax`, before any backend (interp/compile/cranelift)
    exists.
24. **Does cross-module checking preserve it?** Yes, with no separate
    mechanism (module sections are combined into one HIR before checking).
25. **Does HIR format/read preserve it?** Yes, both textually and
    semantically (round-trip tests).
26. **Does `hir::moduleSignatures` preserve it?** Yes, with no code
    change (it already reported the real field verbatim).
27. **Does the typed-callable erasure pass still recognize a function
    whose typed parameter is `List[Small]` as precondition-bearing?**
    Yes, unmodified.

## Required scope questions

28. Were user-defined generics added? No.
29. Were generic functions added? No.
30. Were generic inference variables added? No.
31. Was covariance added? No.
32. Was contravariance added? No.
33. Were typed locals added? No.
34. Was contextual typing added? No.
35. Was predicate refinement added? No.
36. Was `UnicodeChar` added? No.
37. Were character literals added? No.
38. Was `ImmutableList` added? No.
39. Was `ImmutableSet` added? No.
40. Was `byte::set` added? No.
41. Was ASCII added? No.
42. Was representation specialization added? No.

## Acceptance table

| VALUE / CALL | RESULT |
|---|---|
| `[Small-value, Small-value]` | `List[Small]` |
| `[Tiny-value, Small-value]` | `List[Small]` (`lub(Tiny, Small) = Small`) |
| `[A-value, B-value]`, same-domain siblings | broad `List[int]`, not `List[A]`/`List[B]` |
| `[1, "x"]` | broad/heterogeneous `list` |
| `[]` | `List[never]` (broad/unknown-element) |
| `consume(xs: List[Small])` called with `List[Small]` | valid |
| `consume(xs: List[Small])` called with `List[int]` | compile error |
| `consume(xs: List[Small])` called with broad `List`/non-List | compile error |
| `take_a(x: A)` called with a `B`-value (`A`/`B` same-domain siblings) | valid |
| `take_ListA(xs: List[A])` called with `List[B]` | compile error |
| `list_get(xs, 0)` on `List[Small]` | `Small` |
| `TypeFact(list_get(xs, 0))` on `List[Small]` | `[0, 10]` |
| `List[Tiny] -> List[Small]` | compile error (initial invariant rule) |
| `List[Small] -> untyped passthrough` | allowed (erasure, not a soundness hole) |
| `consume(passthrough(xs))`, `xs: List[Small]` erased | compile error unless proof retained |
| `fn f(xs: List[Small]): ...` escaping as a first-class value | still rejected (typed-callable escape, unmodified) |

## Stop condition

All eleven conditions from the brief hold: `List[T]` is spellable in
parameter/result position; it has one canonical structured
representation (`{list ELEM}`, reused, not duplicated); the type-
expression machinery is constructor-generic (a future `ImmutableSet[T]`
needs a registry entry and a resolved-type-shape addition, never new
syntax); ordinary homogeneous List construction infers `List[T]`; a
`List[T]` parameter unconditionally carries element type `T` inside its
own body; the canonical List element-read path (`list_get`) statically
returns `T`; the existing scalar Range/exact-set machinery composes
automatically once `T` is recovered (`List[Small] -> Small -> [0, 10]`);
an unproven value cannot satisfy a `List[T]` parameter; no runtime
element scan was inserted anywhere; no variance, generic functions,
contextual typing, or representation specialization exist; and typed-
callable escape soundness is intact for a `List[T]`-typed parameter,
unmodified.
