# M7.a.a: empty-collection admissibility and applied-type canonicalization

## Outcome

Implemented and regression-tested, exactly to the milestone's stated scope.
A statically **provably empty** immutable `List`/`ImmutableSet` now satisfies
any declared element type at a parameter or result boundary, at any nesting
depth, without making non-empty applied-collection admissibility covariant.
The adjacent `encode_utf8`/`List[Byte]` applied-type canonicalization defect
M7.a found is fixed at its root, generically, with no Byte-specific code.
Three invalid/vacuous M4/M5/M6 fixtures are repaired with legal adversarial
twins, and the vacuous `funcHeaderCount` helper is fixed and its dependent
assertions revalidated against real header counts.

Both changes are two small, surgical edits:

- `hir/range.tcl`: `ProvesValueAcceptedBy`'s List/ImmutableSet branch now
  calls a new four-line recursive helper, `AggregateAdmits`, instead of a
  bare `eq`.
- `hir/types.tcl`: `ShapeResult`'s `typed` case now folds `MakeList
  $resolved` (the already-computed, already-validated resolved type)
  instead of `MakeList $name` (the bare symbolic name).

No other production file changed. `core/`, `native/`, and `lib/*.bot` are
untouched (`git diff --stat`: only `hir/range.tcl`, `hir/types.tcl`, and
seven test files, plus one new test file).

Full suite (`tclsh9.0 tests/all.tcl`, interp and compile backends, native
backend built with `cargo build --release --manifest-path native/Cargo.toml`):
**2214/2214 passing, 0 failed**, 78 test files, including the new
`tests/empty-collection-admissibility.test` (24 tests) and every
pre-existing test (with the specific rewrites this report documents).
`cargo test --release --manifest-path native/Cargo.toml` was **not run**:
no Rust production file changed (only `hir/range.tcl`/`hir/types.tcl`, both
Tcl), per this milestone's own instruction to run the Rust suite only when
Rust production files change.

## Semantic decision

> A statically proven empty immutable collection satisfies a required
> element type because it contains no element that can violate the
> contract.

Formally, for the two registered applied-aggregate constructors (List,
ImmutableSet; MINIMAL-APPLIED-LIST-TYPES.md / MINIMAL-IMMUTABLE-SET.md):

```
Constructor[never] admissible as Constructor[T]   for every T
```

where `Constructor[never]` is not "element type unknown" but the specific,
narrow representation `hir::types::MakeList`/`MakeSet` themselves only ever
produce by folding zero elements (see the producer census below) --
`never` here is Botlish's bottom type used as a fold seed, not a general
"anything goes" escape hatch.

The rule composes structurally, not merely at the top level: admissibility
recurses into a List/Set's element position, so a *nested* empty aggregate
is checked the same way one level down (`[[]]` against `List[List[int]]`),
without ever treating the *enclosing*, non-empty aggregate as covariant.

## Why this is not covariance

Covariance would be:

```
Constructor[A] admissible as Constructor[B]   whenever A <: B
```

for arbitrary `A`/`B` including non-empty values. This milestone adds
exactly one admissible pair beyond the pre-existing invariant-equality rule:
`Constructor[never] -> Constructor[T]`, for every `T`, and *only* for that
one specific, narrow left-hand side. Every other pair is decided exactly as
before:

- `List[A] -> List[B]` for `A != B`, both non-`never`: still rejected
  (`nonempty-list-byte-to-int-still-rejected`,
  `nonempty-list-int-to-byte-still-rejected`,
  `nonempty-list-still-invariant-small-domain`).
- `ImmutableSet[A] -> ImmutableSet[B]`, `A != B`, non-empty: still rejected
  (`nonempty-set-still-invariant`).
- A checked-domain violation inside a non-empty List literal is still a
  compile error (`checked-domain-negative-control-still-checked`,
  `takes_bytes([256])`): the empty rule never means "element constraints
  ignored for `List[T]`".
- `hir::types::subtype`'s own List case (used for
  `hir/specialize.tcl`'s unrelated positional-shape lattice) is untouched --
  still covariant there, still never called by `ProvesValueAcceptedBy`,
  exactly as MINIMAL-APPLIED-LIST-TYPES.md originally decided.

The soundness argument for the one new pair is not "emptiness is a kind of
subtyping"; it is direct: a value of type `Constructor[never]` provably has
zero members, so *every* universally-quantified claim about its members
("every member satisfies `T`") is vacuously true, for every `T`
simultaneously. This is why the same left-hand side (`never`) can be
admissible against *arbitrarily different* `T`s in the same program
(`List[Small]`, `List[str]`, `List[Byte]` all accept `[]`) with no
contradiction, which a genuine subtyping relation between two fixed types
could never do.

## Current empty-collection representation audit (spec item 4)

Traced directly from `hir/types.tcl`, not assumed from M7.a's report.

`hir::types::MakeList elem positions shaped depth` folds `elem` starting
from the literal atom `never` (its own default seed) over the positions
given. `lub never X` is defined (`hir::types::lub`) to return `canonical(X)`
unconditionally -- so the fold's running value changes away from `never`
the instant it is unioned with *any* real element's type. The only way
`MakeList`'s result stays `{list never}` is for the fold to run over **zero**
positions. `MakeSet elem depth` similarly starts from whatever `elem` it is
given (never a fold in the multi-argument sense) and is called with `elem =
never` only when its own caller already computed "the source has no known
elements".

Producers of `{list never}` (a bare, un-nested `List[never]`), inventoried
by reading every call site of `MakeList`/`AggregateOfValue` reachable from
ordinary (non-specialization) semantic inference -- the analysis
`hir::range::verifyDeclaredParams`/`verifyDeclaredResults` actually run
against, once, program-wide, before specialization exists:

| producer | code path | zero-element condition |
|---|---|---|
| list literal `[]` | `hir::types::Call`, native `list`'s `-result-shape elements` -> `ShapeResult`'s `elements` case -> `MakeList never $argTypes 1` | `$argTypes` is the literal's own argument list; empty iff the literal is spelled with no elements |
| a `listloop`'s own natural (non-break) completion, as a value | `hir::types::Expr`'s `listloop` case: `MakeList $bodyType` unconditionally, joined with break types | Not "zero elements" in the same literal sense, but sound by the identical vacuous-quantification argument: `MakeList $bodyType` is `{list never}` only when `$bodyType` itself is `never` (the body's own normal path never completes), and in that case the *only* way the `listloop` construct itself completes normally is by executing zero iterations -- any executed iteration would diverge the enclosing function, not merely contribute an element -- so reaching this point normally already forces the runtime value to have zero elements |
| `list_append`'s own result on an already-`never`-elemented source, when the appended value is *also* `never`-typed | `ShapeResult`'s `append` case: `MakeList (lub elem[list] elem[appended])` | Only if the appended value's own type is `never` too (an always-diverging expression), in which case the whole `list_append` call is itself unreachable (never completes normally) -- moot |

**Conclusion (answers spec questions 1-2):** every current ordinary-inference
producer of `{list never}` types a value that either (a) is a literal `[]`
with zero source elements, or (b) can only be *reached* (complete normally)
at runtime when the actual collection has zero elements, by an argument
about what "complete normally" must mean for that specific construct. There
is no producer of `{list never}` that means "element type merely unknown" --
that state is represented differently (a broad `list`/`immutableSet`, or
`any`), and is *never* accepted by the new rule (`AggregateAdmits` only
special-cases the literal atom `never`, never a broad kind -- confirmed by
`nested-nonempty-inner-list-still-invariant` and the
`set-construct-heterogeneous`/`set-construct-broad-source-also-broad`
pre-existing pins, unaffected by this milestone). `List[never]` is
guaranteed to mean empty today (**Q2: yes**).

`hir::specialize.tcl`'s own separate per-instance region inference
(`inferRegion`, used only for codegen, never for the admissibility check
this milestone changes) additionally produces `{list never}` via
`AggregateOfValue` for a runtime constant empty list -- the identical
"zero elements" condition, confirmed by inspection; this path was already
audited by M7.a (S05c) and is unaffected by this milestone's own change,
which touches nothing in `hir/specialize.tcl`.

## ImmutableSet[never] audit (spec item 5)

`immutable_set_from_list` is `ImmutableSet`'s **sole** value producer
(confirmed by exhaustive grep: no other native registers `-result-type
immutableSet` or an `immutable-set`-shaped `-result-shape`; `resolveApplication`'s
`ImmutableSet` arm only ever runs against an already-resolved *source type
annotation*, never a value). Its own `-result-shape {immutable-set 0}` ->
`ShapeResult`'s `immutable-set` case:

```tcl
set elem [elementOf [lindex $argTypes $l]]
if {$elem eq ""} { return $result }          ;# broad/heterogeneous source
return [MakeSet $elem 0]
```

`elementOf` returns `""` for a broad/unresolved source List (never `never`),
and the literal atom `"never"` only when the source List's own element type
is itself `never` -- i.e. only when the source List is *itself* one of the
provably-empty producers audited above. There is no path from a broad or
heterogeneous source to `ImmutableSet[never]`: those go to the broad
`immutableSet` kind instead. **Q3: yes, `ImmutableSet[never]` is guaranteed
to mean empty today**, by the identical "zero elements folded" argument as
List, transported through exactly one generic native metadata case with no
Set-specific emptiness code. The same rule therefore covers both aggregate
families (`AggregateAdmits` is written once, generically, over
`IsList`/`IsSet`, never duplicated).

## Chosen contextual/admissibility model (spec items 8-9, required Q8)

**Model A** (of the three candidates spec item 7 lists): *admissibility
alone knows the argument satisfies the declared type; the argument's own
observed type/specialization identity is untouched.*

Concretely: `hir::range::ProvesValueAcceptedBy` (consulted only by
`VerifyCall`/`verifyDeclaredParams` and `verifyDeclaredResults`, both of
which run once, program-wide, in `hir::buildSyntax`, strictly *before*
`hir::specialize.tcl` ever runs) is the only file this milestone's semantic
rule touches. `hir::specialize::KeyType`, `Analyze`, and `Handle` are
byte-for-byte unchanged.

**Why this is not "just" a convenient minimal diff, but the correct model:**
`hir::types::Block`'s pre-existing, unmodified declared-parameter-type
seeding (`STRICT-TYPED-PARAMETERS.md`'s own mechanism, `hir/types.tcl` line
~917) already assigns every reference to a declared parameter its *declared*
type, unconditionally, during the single whole-program semantic-inference
pass -- independent of any particular call site, and in particular
independent of whether that pass is re-run per specialized instance (it is
not: it runs exactly once). So the callee's own body is checked, once, for
every operation it performs, against the full declared contract, before any
caller (empty or not) is even considered. `hir::specialize.tcl`'s own
per-instance region inference (`inferRegion`) never re-verifies admissibility
for an internal call -- it only *elides* provably-dead branches/guards, using
whatever facts a specific instance's own view provides. Under Model A this
means:

- **Static legality (spec item 8's hard requirement) is unaffected by
  specialization identity, structurally, not by luck.** The function body
  was already legal (or illegal) before any instance existed.
- **What Model A actually costs is codegen *precision*, not soundness**,
  and only inside the one specific instance an empty caller creates: that
  instance's own internal `hir::range`/aot facts see `xs : List[never]`
  rather than `xs : List[int]`, so an internal branch that could have been
  proven `AlwaysFalse`/`AlwaysTrue` from the declared element domain stays
  `Unknown` in *that* instance. This is the exact-same category of loss M7.a
  already found and named (S05d, "declared aggregate parameter theorem
  lost in specialization") -- this milestone does not fix S05d; it
  establishes that the *new* empty-caller case is a special, provably
  harmless instance of it (see "Specialization interaction" below), not a
  new problem needing the same fix.

Models B (instantiate the empty value's type to the declared `List[T]`
before specialization) and C (retain the empty-specific identity while
separately representing the declared theorem as an entry theorem) were
both considered and rejected for M7.a.a specifically because they would
require touching `hir::specialize.tcl`'s Analyze/seeding logic -- exactly
the "M7.b's aggregate theorem transport" work M7.a already recommended and
explicitly deferred, and which this milestone's own brief (item 47) says to
implement "only the minimum prerequisite" of. Given Model A already
satisfies every one of M7.a.a's hard soundness requirements (verified
directly, next section) with zero specialization-code change, no part of B
is a necessary prerequisite here; B remains exactly the same shape of
future work M7.a scoped it as, applying equally to the empty case and to
the pre-existing `List[Byte]`-vs-`List[int]` case (see "Revised M7.b
scope").

## Declared parameter interaction (spec items 7-9, 39; required Q11-13)

**Q11 (instance key):** `f([])`, for `f(xs: List[int])`, keys the call's own
instance `List[never]` -- identical to how an *undeclared* parameter's `[]`
caller was already keyed before this milestone (S05c). Confirmed directly:
`mixed-callers-two-separate-instances` inspects `hir::specialize::analyze`'s
own `used` instance labels and finds exactly `{consume<List[never]>
consume<List[int]>}`.

**Q12 (view inside that instance):** `xs`'s view inside `f<List[never]>` is
`List[never]` (the key, unrestored -- the pre-existing "specific key skips
M1 seeding" rule, unchanged). This is strictly *less precise* than the
generic/declared view, exactly like the pre-existing `List[Byte]`/`List[int]`
case (M7A's S05d) -- but see Q13.

**Q13 (can the body use every operation `List[int]` guarantees?) Required:
yes.** Verified directly, not merely argued: `generic-body-usability-empty-
caller` compiles

```botlish
fn helper(xs: List[int]) -> int:
    1
fn consume(xs: List[int]) -> int:
    helper(xs)
consume([])
```

with zero diagnostics, on every backend (part of the full suite). This holds
*because* legality of `helper(xs)` inside `consume`'s body was already
decided, once, against `consume`'s own declared `List[int]` parameter type,
independent of `consume([])` or any other caller (see "Chosen model"
above) -- `hir::specialize`'s later, per-instance, less-precise view of `xs`
is consulted only for codegen facts (dead-branch elimination, guard
removal), never for re-deciding legality.

**Q14 (does an empty-specific theorem survive anywhere)?** Yes, exactly one:
the instance *identity* itself (`List[never]`) is empty-specific, and
`hir::range`'s own entry-range/type-fact machinery for that instance
therefore never learns the declared `int` element domain. No *unsound*
theorem survives; only a *precision* fact ("this instance's `xs` view is
`List[never]`, not `List[int]`") is visible where the declared theorem
would have been more precise.

## Declared result interaction (spec item 11)

Symmetric by construction: `verifyDeclaredResults` calls the identical
`ProvesValueAcceptedBy`/`AggregateAdmits`, so no separate code path exists
to diverge. `empty-list-satisfies-declared-result` (`fn empty() -> List[int]:
[]`) and `empty-set-satisfies-declared-result` (`-> ImmutableSet[Small]:
immutable_set_from_list([])`) both compile; `nonempty-list-result-still-
invariant` (`-> List[Byte]` actually returning `List[int]`) is still
rejected. **Q38 (result/parameter symmetry): the same relation governs
both, verified with both positive and negative tests on each side.**

## Specialization interaction / mixed callers (spec items 41-43; required
Q15-16)

**Q15 (do `f([])` and `f([1,2])` share an instance)? Deliberate answer: no.**
Two separate instances, `f<List[never]>` and `f<List[int]>` -- unchanged
specialization-identity policy, extending the pre-existing undeclared-
parameter behavior (S05c) uniformly to declared parameters now that the
call is legal. Verified directly (`mixed-callers-two-separate-instances`).

**Q16 (can adding a non-empty caller make an empty theorem leak
unsoundly)? Required: no. Confirmed: no**, and *structurally* so, not merely
by testing: since the two calls key to different instances, there is no
shared mutable state (`hir::specialize`'s instances are addressed purely by
`{block, keyArgs}`) through which one caller's facts could reach the
other's. `mixed-callers-adding-third-caller-stays-sound` adds a third,
different non-empty caller (`consume([4, 5])`) to the same program and
confirms the instance set is still exactly `{consume<List[never]>
consume<List[int]>}` (the third caller reuses the existing `List[int]`
instance, per the ordinary element-kind-only `KeyType` rule, unaffected by
this milestone). `empty-listloop-nonempty-caller-still-correct` and
`generic-body-usability-mixed-callers-both-compile` confirm both instances'
own runtime/legality behavior independently, in the same program.

## Empty listloop behavior (spec items 10, 40)

Preserved, and now demonstrated for a *declared* parameter too (previously
only observable for undeclared parameters, S05c): `empty-caller-instance-
loop-body-statically-dead` inspects the real NIR text and confirms the
`List[never]`-keyed instance's own listloop body is lowered as `unreachable`,
while the `List[int]`-keyed instance's body is not. This is the *existing*
compiler behavior (dead-branch elimination from `hir::specialize`'s own
per-instance facts), simply now reachable through a legal, declared-
parameter call path; nothing in this milestone's own change (which touches
only `hir/range.tcl`'s admissibility check and `hir/types.tcl`'s `ShapeResult`)
alters `hir::specialize`/`native::lower`'s dead-code analysis. Runtime
correctness (not merely dead-code elimination) is confirmed independently
by `empty-listloop-runtime-zero-iterations`/`-nonempty-caller-still-correct`
on all four backends (interp, compile, cranelift-generic, cranelift).

## Nested empty collection behavior (spec items 14, 43)

- `[[]]` (`List[List[never]]`) against declared `List[List[int]]`: accepted
  (`nested-empty-inner-list-satisfies-nested-declared-type`) -- the *outer*
  list is non-empty (one element), so admissibility recurses into that
  element and finds it, itself, provably empty against the inner `List[int]`.
- `[]` itself (not wrapped) against the same declared `List[List[int]]`:
  accepted directly, since the outer value's own top-level element type is
  already `never` (`nested-outer-empty-satisfies-nested-declared-type`).
- `[[1]]` against declared `List[List[Byte]]`: **rejected**
  (`nested-nonempty-inner-list-still-invariant`) -- the inner list has a
  real, non-empty, plain-`int` element, so nothing in the recursion ever
  reaches the `never` base case; this is the adversarial control proving
  the recursion does not accidentally make the *outer* non-empty List
  covariant merely because nesting is involved.

## Non-empty invariance controls (spec items 15-16, 35-37)

All using a source-defined bounded domain (`Byte = Int in 0..255`, plus
`Small = Int in 0..10` for the plain acceptance side), never relying on
Byte's specific name in the admissibility code itself:

- `List[Byte] -> List[int]`, `List[int] -> List[Byte]`, both with real,
  non-empty values: still rejected
  (`nonempty-list-byte-to-int-still-rejected`,
  `nonempty-list-int-to-byte-still-rejected`).
- `List[Small]` (a real `Small` value) `-> List[Byte]`: still rejected
  (`nonempty-list-still-invariant-small-domain`) -- same-domain-shaped
  siblings still do not lift through the container, exactly as
  MINIMAL-APPLIED-LIST-TYPES.md originally decided, unaffected by this
  milestone.
- `ImmutableSet[Byte]` (real value) `-> ImmutableSet[int]`: still rejected
  (`nonempty-set-still-invariant`).
- `takes_bytes([256])`: still a compile-time TYPE rejection
  (`checked-domain-negative-control-still-checked`) -- the empty rule is
  never "element constraints ignored for `List[T]`" (spec item 16, required).

## `encode_utf8` canonicalization root cause (spec items 17-22; required
Q18-24)

**Q18 (why did `encode_utf8` produce `{list Byte}`)?** `hir/types.tcl`'s
`ShapeResult` `typed` case (added by a *previous* milestone,
SYMBOLIC-TYPE-IDENTITY.md, to fix a *different*, narrower soundness gap --
whether the guaranteed value range actually fits the resolved name's
domain) correctly computed and validated `set resolved [core::type::normalize
$name]`, then validated `ProvesType` against it -- but its final line
returned `[MakeList $name]`, folding the **bare symbolic name** (`"Byte"`,
a one-word Tcl string) as the element type, not the `$resolved` value it had
just computed and proven admissible one line above.

**Q19 (where should `Byte` have been resolved)?** It already *was* resolved,
correctly, into the local variable `$resolved` -- the defect was purely a
"used the wrong variable" bug in the final `MakeList` call, one line below
where the correct value existed.

Why this was not caught by SYMBOLIC-TYPE-IDENTITY.md's own thorough test
suite: `hir::types::show`'s `list` case calls `core::type::show` on the
element, and `core::type::show` *normalizes its own input first*
(`core/type.tcl`, `proc core::type::show {type} { set type [normalize
$type]; ... }`). So displaying `{list Byte}` prints `List[int[Byte]]` --
identical to displaying the *correctly* canonical `{list {refined int
{Byte}}}` -- masking the representational difference in every test that
compared `hir::types::show` text (every one of SYMBOLIC-TYPE-IDENTITY.md's
own 9 tests, plus this milestone's own `symbolic-type-identity-canonical-
byte` etc., all of which still pass and are still correct as *display*
assertions). The bug only manifests where two *stored* type values are
compared directly without going through `show` -- exactly `List[T]`
admissibility's own `AggregateAdmits`/(pre-existing) `eq` check, which none
of SYMBOLIC-TYPE-IDENTITY.md's tests exercised (its own tests probe
`list_get(encode_utf8(...), 0)`'s *scalar* result type, which happens to be
"healed" by `core::type::subtype`'s own internal normalization when compared
against a scalar declared parameter -- verified directly by tracing
`hir::types::subtype`'s fallback to `core::type::subtype [semantic $a] $b`
for that case, which itself calls `normalize`).

**Q20 (the one canonical semantic representation afterward)?**
`{list {refined int {Byte}}}` -- the identical form `hir::types::
resolveApplication`'s `List` arm already produces for a *declared*
`List[Byte]` annotation (`MakeList [core::type::normalize "Byte"] ...`).
After this fix, `encode_utf8(...)`'s inferred type and a declared
`List[Byte]`'s resolved type are the *same Tcl value*, confirmed by direct
structural (`eq`) comparison, not merely identical display text
(`symbolic-type-identity-structural-equality-not-display-text`).

**Q21 (is the fix generic over applied result metadata)? Yes.** The fix is
in `ShapeResult`'s shared, single `typed` case -- the same code path every
current and future `-result-shape {typed NAME LO HI}` native goes through;
nothing Byte-specific was added (spec item 18/required: no Byte-specific
fix). `MakeList $resolved` folds whatever `NAME` resolves to in the
*compiling program*, per the pre-existing, unmodified lazy-resolution/
compilation-isolation design (SYMBOLIC-TYPE-IDENTITY.md) -- confirmed by
`symbolic-type-identity-narrow-byte-param-still-rejected` (a same-spelled
but narrower local `Byte` still correctly falls back to broad `list`, so it
still does not satisfy a declared `List[Byte]` parameter either).

**Q22 (did any other native result-shape declaration have the same
defect)?** No -- see the census below.

**Q23 (does `encode_utf8(...) -> List[Byte]` now satisfy invariant
admissibility normally)? Required: yes. Confirmed:**
`symbolic-type-identity-satisfies-declared-list-byte-parameter` compiles

```botlish
type Byte = Int in 0..255
fn consume(bytes: List[Byte]) -> int:
    1
consume(encode_utf8("A"))
```

with zero diagnostics.

**Q24 (are incompatible named domains still distinguished)? Required:
yes.** `symbolic-type-identity-negative-control-list-int-still-rejected`
confirms `encode_utf8(...)` (`List[Byte]`) does **not** satisfy a declared
`List[int]` parameter -- canonicalization narrows to the *resolved named*
type, never collapses distinct named/unnamed domains merely because both
have runtime `int` kind.

## Canonical applied-type representation (spec item 19)

Unchanged, and now uniformly upheld: `List[T]`/`ImmutableSet[T]`'s one
canonical semantic form remains `{list ELEM}`/`{immutableSet ELEM}` with
`ELEM` itself already fully resolved/canonical (MINIMAL-APPLIED-LIST-
TYPES.md's original invariant). Before this fix, exactly one producer
(`ShapeResult`'s `typed` case) violated that invariant by storing an
unresolved element; after the fix, every producer of an applied-aggregate
type -- source declarations (`resolveApplication`), ordinary List/Set
construction (`elements`/`element`/`append`/`immutable-set` shapes), and
native semantic-fact metadata (`typed`) -- stores the identical canonical
form for the identical semantic element, regardless of provenance (spec
item 19's own requirement, now actually true rather than assumed).

## Native result-shape census (spec item 21)

Every `-result-shape` producer in the codebase, and whether it could
exhibit the same defect (storing something other than an already-canonical
type inside an aggregate form):

| shape kind | producer(s) | builds ELEM from | canonical by construction? |
|---|---|---|---|
| `elements` | `list` (`core/primitives.tcl`) | the literal's own already-typed argument expressions (`argTypes`, themselves outputs of `hir::types::infer`) | yes -- never introduces a new symbolic name |
| `element` | `list_get` (`core/lists.tcl`) | `elementOf` of an already-canonical source List type | yes -- reads, never constructs, a name |
| `append` | `list_append` (`core/lists.tcl`) | `lub` of an already-canonical source element and an already-typed appended value | yes |
| `immutable-set` | `immutable_set_from_list` (`core/immutableset.tcl`) | `elementOf` of an already-canonical source List type | yes |
| `typed` | `encode_utf8` (`core/strings.tcl`) -- the **only** current user | a **symbolic name** resolved fresh, at inference time, against the live source-type registry | **no, before this fix** -- the one producer that introduces a name needing its own resolution step, and the one line (`MakeList $name` vs `MakeList $resolved`) that dropped the resolution result. Fixed. |

Only `typed` resolves a *name* rather than reading an already-resolved type
off an argument, which is exactly why it was the one shape kind capable of
this defect; the other four are structurally incapable of it (they have no
symbolic-name resolution step at all). `encode_utf8` remains the sole
current user of `{typed NAME LO HI}` (confirmed by the same grep
SYMBOLIC-TYPE-IDENTITY.md ran, re-run here with the identical result), so
the fix's generic-vs-specific claim is validated by the shared code path,
not by breadth of current use.

## Test-hygiene repairs (spec items 23, 25-30, 98 required Q25-31)

**Q25 (which fixtures analyzed invalid programs without saying so)?**

1. `tests/setfromlist-equality-total.test`'s `setfromlist-empty-list-stays-
   generic`: compiled `mk_int([])` for a declared `List[int]` parameter --
   illegal under the *pre-M7.a.a* language rule -- and only ever ran because
   this file's own `sourceHir`/`nirOf` helpers always pass `-strict 0`.
2. `tests/checked-domain-proof-provenance.test`'s `checked-domain-shared-
   instance-byte-set`: called `byte::set(chars)` with `chars` left
   *undeclared* inside `dyn`, so a broad/`any` argument was passed where
   `byte::set`'s own declared `List[UnicodeChar]` parameter is required --
   illegal under `STRICT-TYPED-PARAMETERS.md`, again masked only by
   `-strict 0`.
3. `tests/hir-range.test`'s `condition-outcome-12`: passed a Bearing
   callable (`dyn`, with a declared parameter type and declared errors)
   through `caller`'s untyped higher-order parameter `g` -- illegal under
   `TYPED-CALLABLE-ESCAPE-SOUNDNESS.md` -- and separately left `caller`'s
   own declared `-> Byte` result unproven.

**Q26 (which were replaced with legal twins)?** All three, in place (same
test name, same intent, corrected/replaced source):

1. Replaced with `setfromlist-empty-list-strict-legal-conservative-instance`
   (plain `-strict 1` compile, zero diagnostics asserted directly) plus a
   new `setfromlist-empty-list-runtime-empty-result` runtime control.
2. Replaced by declaring `dyn(chars: List[UnicodeChar])` -- the fix M7.a's
   audit itself proposed ("a legal caller whose collection argument is
   dynamically supplied while still respecting the declared `List
   [UnicodeChar]` contract"): still a *dynamically supplied* argument (not
   a literal), now legal because it is declared.
3. Replaced with M7.a's own constructed legal twin, scenario S03b
   (`audit/m7a-instance-selection/tools/scenarios.tcl`): `dyn` is left
   undeclared and locally handles `byte::from_int`'s own errors itself
   (never Bearing), so it legally erases through `caller`'s untyped `g` --
   the identical adversarial *shape* (shared instance, one safe literal
   caller, one genuinely open caller through `callvalue`), now a real
   program. The test now additionally asserts `0` diagnostics directly,
   not merely by construction.

**Q27 (which remain intentionally invalid)?** None in the files this
milestone touched -- every previously-invalid fixture identified by M7.a's
audit is now a legal twin; there is no fixture in scope this report keeps
as "intentionally invalid, labeled as such" (M7.a.a's own scope was to
*repair*, not to relabel-and-keep, the specific fixtures M7.a named).

**Q28 (are intentionally invalid cases now explicitly labeled)? Required:
yes** -- vacuously satisfied here since none remain in the repaired set;
every replacement's own doc comment explains, by name, which pre-existing
milestone/audit finding it repairs and why the original was invalid, so a
future reader cannot mistake the *history* for a currently-invalid fixture.

**Q29 (what was wrong with `funcHeaderCount`)?** `regexp -all -line PATTERN
STRING` **already returns the match count directly** when `-inline` is not
given (Tcl's own documented behavior) -- wrapping that integer in `llength`
always returned `1` (the length of a one-word Tcl value), regardless of how
many headers actually matched, silently making every "exactly one shared
instance" assertion in the file vacuously true.

**Q30 (what do the repaired assertions actually prove)?** With
`funcHeaderCount` returning the real count:
`checked-domain-shared-instance-from-int` (already using a legal fixture)
continues to report `1` -- a real, previously-accidentally-true assertion,
now genuinely verified. `checked-domain-shared-instance-byte-set`, with its
now-legal-and-still-dynamic `dyn(chars: List[UnicodeChar])` fixture, also
now genuinely reports `1` (verified by the passing test) -- i.e. the
declared-but-dynamic caller and the literal-argument caller really do share
one `byte::set<List[UnicodeChar]>` NIR instance, which is the actual
soundness-relevant fact these fixtures exist to pin (no per-instance
optimization could soundly treat that shared instance's own inner checked
construction as unconditionally safe, since the dynamic caller's argument
contents are not statically known).

**Q31 (does the legal open/shared-instance fixture genuinely broaden the
entry fact)? Required: yes.** `condition-outcome-12`'s replacement passes
`45` through `dyn`, itself only reachable via `caller`'s untyped `g`
(`callvalue`), into the shared `byte::from_int<int>` instance -- confirmed
directly (not merely asserted): the test's own body computes
`hir::range::ConditionOutcome` for both of `byte::from_int`'s comparisons
(`value < 0`, `value > 255`) against the shared instance and gets `{}`
(Unknown) for both, even though the *other* caller (`byte::from_int(45)`
alone) would have decided both `AlwaysFalse` -- exactly the widening
`OpenInstances`/entry-range-join machinery produces for a genuinely
unconstrained caller, the fact this fixture is meant to pin.

## Generated-code/instance deltas (spec item 34)

None outside the intended, newly-*reachable* code path. This milestone is a
semantic/admissibility change, not a codegen change:
`hir::specialize`/`native::lower` are unmodified. The only "new" generated
code is for programs that previously failed to compile at all (an empty
literal against a declared aggregate parameter/result) -- there is no
before/after comparison to make for those, since "before" is a compile
error, not a program. For every program that already compiled before this
milestone, nothing changed: the frozen corpus (`bench/uri-steady.bot`,
`bench/refined-checks.bot`) contains no declared-List/Set parameter called
with an empty literal, so the M7A audit's own frozen-corpus census (19/17/
7055 B/14 guards for `uri-steady`; 39/33/16743 B/24 guards for
`refined-checks`) is untouched by construction -- confirmed by the full
suite's own frozen-corpus tests (`tests/checked-domain-proof-provenance.test`,
`tests/setfromlist-equality-total.test`'s own `byte::set`-through-the-real-
file tests) passing unmodified.

## M1-M7.a regression controls

- `hir-specialize.test`'s own pre-existing pins of `List[never]` instance
  labels/keys (`grow<List[never], int>`, etc.) are structural-identity
  facts this milestone does not touch (specialization code unchanged) --
  all pass unmodified, confirming no accidental identity-policy change.
- M1's declared-parameter-fact transport (`applied-type-param-body-fact`),
  M2's callable-identity pins, M3/M4's equality-totality pins
  (`setcontains-equality-total.test`, and every *other*
  `setfromlist-equality-total.test` fixture besides the one repaired here),
  M5's real `checked-domain-*` proofs (Q1-Q3), and M6's `ConditionOutcome`
  pins (`condition-outcome-1` through `-11`) all pass unmodified -- full
  suite, both backends.
- MINIMAL-APPLIED-LIST-TYPES.md's/MINIMAL-IMMUTABLE-SET.md's own invariance
  pins (`applied-type-invariant-sibling-rejected`,
  `set-type-invariant-subtype-element-rejected`, etc.) pass unmodified --
  the two rewritten tests in those files (`applied-type-construct-empty`,
  `set-construct-empty-satisfies-declared`) are the *only* tests in either
  file whose expected outcome changed, and both changes are exactly the
  language-semantics change this milestone makes, not incidental breakage.

## Tests

**New file:** `tests/empty-collection-admissibility.test`, 24 tests --
List/Set empty-literal acceptance (source-defined domain, string element),
paired non-empty invariance controls (Byte domain, both directions, plus
same-domain-sibling), the checked-domain negative control, result-position
symmetry (both positive and negative), nested empty collections (`[[]]`
against `List[List[int]]`, bare `[]` against the same, and the non-empty-
inner-list adversarial control), the mandatory generic-function-body-
usability regression (spec items 8/39) and its mixed-caller variant, empty-
listloop runtime behavior on all four backends plus a mixed-caller variant,
the deliberate mixed-caller specialization-identity pins (two separate
instances; a third caller does not perturb them; the empty instance's own
listloop body is statically `unreachable` in NIR while the non-empty
instance's is not), and the join-behavior documentation tests (spec item
12).

**Extended:** `tests/symbolic-type-identity.test`, +4 tests -- the actual
aggregate/parameter-boundary admissibility case this milestone's
canonicalization fix repairs (which none of that file's original 9 tests,
all scalar/element-read-focused, exercised): direct acceptance of
`encode_utf8(...)` by a declared `List[Byte]` parameter, a *structural*
(not merely display-text) equality proof between `encode_utf8`'s inferred
type and a declared `List[Byte]`'s resolved type, and two negative controls
(a declared `List[int]` parameter still rejects it; a same-spelled but
narrower local `Byte` still falls back and is still rejected).

**Rewritten in place** (same test name kept where the milestone's own
semantic change is exactly what the name already describes; renamed only
where the old name asserted the now-false outcome):
- `tests/applied-types.test`: `applied-type-construct-empty` (was
  "rejected", now "accepted", per this milestone's own language change).
- `tests/immutable-set.test`: `set-construct-empty-satisfies-nothing` ->
  `set-construct-empty-satisfies-declared` (symmetric rename).
- `tests/setfromlist-equality-total.test`: `setfromlist-empty-list-stays-
  generic` -> `setfromlist-empty-list-strict-legal-conservative-instance`
  (+ one new runtime-control test), per M4's own repair mandate.
- `tests/checked-domain-proof-provenance.test`: `funcHeaderCount` fixed;
  `checked-domain-shared-instance-byte-set`'s fixture corrected in place
  (same test name, legal source).
- `tests/hir-range.test`: `condition-outcome-12`'s fixture replaced in
  place with M7.a's own S03b legal twin (same test name), plus a
  diagnostic-count assertion added to the test body.

Full suite: `tclsh9.0 tests/all.tcl` (interp and compile backends, native
backend built with `cargo build --release --manifest-path native/
Cargo.toml`): **2214/2214 passing, 0 failed**, 78 test files, confirmed by
direct run (not carried over from a prior report).

## GC-stress policy

This milestone touches only `hir/range.tcl` (a new pure static-analysis
helper, `AggregateAdmits`, and its one call site) and `hir/types.tcl` (one
variable substituted in an existing static-type-construction function,
`ShapeResult`). No root, safepoint, collector, object-representation,
stack-map, or closure-layout code was touched, and `hir::specialize.tcl`
(the file `native/lower.tcl`'s codegen actually keys allocation/rooting
decisions from) is unmodified.

```
Local GC stress: not run; no GC-sensitive production code changed.
CI GC-stress: relies on .github/workflows/tests.yml's gc-stress job on the
next push to main, per this milestone's own scope instruction (item 56).
```

## Source-fence confirmation

`git diff --stat` against the pre-milestone tree: `hir/range.tcl` (+45/-9),
`hir/types.tcl` (+17/-1), and eight test files (seven modified, one new).
Zero lines changed in `core/`, `native/`, `lib/*.bot`, `surface/`, or any
other `hir/*.tcl` file. `encode_utf8`'s own native registration
(`core/strings.tcl`) is byte-for-byte unchanged -- the canonicalization fix
is entirely inside the generic consumer (`hir/types.tcl::ShapeResult`), per
spec item 22's explicit prohibition on touching the native metadata itself
beyond what a genuine root-cause fix requires (it did not require touching
it at all). Runtime UTF-8 encoding, List layout, Byte runtime
representation, native ABI, and allocation behavior are all unchanged --
this is a static-type-canonicalization fix only (spec item 22, confirmed
by the diffstat and by every runtime-parity test in the full suite passing
unmodified).

## Required empty-semantics questions (spec item 59)

1. **What exactly proves an immutable collection is empty?** Its stored
   static type is the specific form `MakeList`/`MakeSet` fold to when given
   zero elements -- `{list never}`/`{immutableSet never}` -- traced above to
   mean exactly "zero elements were ever folded in, or the value can only
   be reached at runtime with zero elements" for every current producer.
2. **Is `List[never]` guaranteed to mean empty today?** Yes (producer
   census above).
3. **Is `ImmutableSet[never]` guaranteed to mean empty today?** Yes
   (`immutable_set_from_list` is the sole producer, and only reaches
   `never` when its own source List is itself provably empty).
4. **`[] -> List[Int]` after M7.a.a?** Accepted.
5. **`[] -> List[Byte]`?** Accepted (same rule; not Byte-specific).
6. **`[] -> List[String]`?** Accepted (`empty-list-satisfies-string`) --
   proves the rule is about emptiness, not integer domains.
7. **Does non-empty `List[Int] -> List[Byte]` remain invalid? Required:
   yes.** Confirmed (`nonempty-list-int-to-byte-still-rejected`, and the
   reverse direction, `nonempty-list-byte-to-int-still-rejected`).
8. **Is the new rule contextual typing, admissibility, a bottom-element
   rule, or another model?** It is implemented as **admissibility**: one
   additional case inside `hir::range::ProvesValueAcceptedBy`
   (`AggregateAdmits`), consulted at the same two call sites
   (`VerifyCall`/`verifyDeclaredResults`) that already decided every other
   admissibility question. It is *conceptually* a narrow bottom-element
   rule ("`never`-elemented aggregate admissible for any `T`"), but nothing
   about contextual/bidirectional type inference was added: the argument's
   own type (`List[never]`) is computed exactly as before, with no
   inference-direction change, and no unification variable is introduced.
9. **Why does that model not introduce ordinary covariance?** Because the
   rule is keyed on the specific atom `never` at the element position, not
   on a subtyping relation between two arbitrary element types -- see "Why
   this is not covariance" above and its accompanying negative controls,
   all of which pass.
10. **Does the same rule apply to declared results?** Yes, by shared
    implementation (`verifyDeclaredResults` and `VerifyCall` both call
    `ProvesValueAcceptedBy`) -- verified with dedicated result-position
    tests, both positive and negative.

## Required specialization questions (spec item 60)

11. **Instance key for `f([])`, `f(xs: List[Int])`?** `List[never]` --
    identical to the pre-existing undeclared-parameter behavior, unchanged
    by this milestone (verified: `mixed-callers-two-separate-instances`).
12. **View of `xs` inside that instance?** `List[never]` (the key,
    unrestored by M1's declared-type seeding, since the key is "specific") --
    a precision loss, never a soundness one (see below).
13. **Can the body use every operation `List[Int]` guarantees? Required:
    yes.** Confirmed directly (`generic-body-usability-empty-caller`),
    because legality is decided once, globally, against the declared type,
    independent of specialization (see "Chosen model").
14. **Does an empty-specific theorem survive anywhere?** Only as reduced
    *precision* inside that one instance's own codegen facts (its `xs` view
    lacks the declared `int` element domain) -- never as an unsound claim
    usable to reject or misclassify code the declaration guarantees.
15. **Do `f([])`/`f([1,2])` share an instance? Deliberate answer: no** --
    Model A leaves `hir::specialize`'s pre-existing element-kind identity
    policy completely unchanged; the empty and non-empty calls key
    differently, exactly as an undeclared parameter's calls already did.
16. **Can adding the non-empty caller make an empty theorem leak unsoundly?
    Required: no. Confirmed: no** -- the two calls address different
    instances by construction; there is no shared instance state for a
    theorem to leak through (`mixed-callers-adding-third-caller-stays-
    sound`).
17. **Does M7.b's planned aggregate theorem transport need revision?** Yes
    in scope, not in direction -- see "Revised M7.b scope" below: the
    empty-caller case is now a known, harmless special case of the same
    underlying precision gap (S05d) transport would close, and should be
    covered by the same future work, not fixed separately.

## Required canonicalization questions (spec item 61)

18. **Why did `encode_utf8` produce `{list Byte}`?** `ShapeResult`'s `typed`
    case's final line, `MakeList $name`, used the bare symbolic name
    instead of the `$resolved` value the same case had already computed
    and validated one line above.
19. **Where should `Byte` have been resolved?** It already was --
    correctly -- into `$resolved`; the fix is using that existing value.
20. **What is the one canonical semantic representation afterward?**
    `{list {refined int {Byte}}}`, identical to what a declared `List[Byte]`
    annotation resolves to -- confirmed by direct structural (`eq`)
    comparison, not display text.
21. **Is the fix generic over applied result metadata?** Yes -- one shared
    `ShapeResult` case, no name-specific branch.
22. **Did any other native result-shape declaration have the same defect?**
    No (census above: `typed` is the only shape kind that resolves a
    symbolic name at all; `encode_utf8` is its only current user).
23. **Does `encode_utf8(...) -> List[Byte]` now satisfy invariant
    admissibility normally? Required: yes.** Confirmed.
24. **Are incompatible named domains still distinguished? Required: yes.**
    Confirmed (`List[int]` still rejects it).

## Required testing-hygiene questions (spec item 62)

25. **Which previous fixtures analyzed invalid programs without saying
    so?** `setfromlist-empty-list-stays-generic` (M4),
    `checked-domain-shared-instance-byte-set` (M5), `condition-outcome-12`
    (M6) -- see "Test-hygiene repairs" above for exactly what made each one
    illegal.
26. **Which were replaced with legal twins?** All three, in place.
27. **Which remain intentionally invalid?** None in the repaired set.
28. **Are intentionally invalid cases now explicitly labeled as such?
    Required: yes** -- vacuously, since none remain; every replacement's
    doc comment records the original defect for posterity instead.
29. **What was wrong with `funcHeaderCount`?** `llength` of `regexp -all`'s
    own already-integer return value is always `1`.
30. **What do the repaired header-count assertions actually prove?** That
    `byte::set`'s literal-argument caller and its now-legal
    declared-but-dynamic caller genuinely share one NIR instance (real
    count: `1`, verified, not vacuously true).
31. **Does the legal open/shared-instance fixture genuinely broaden the
    entry fact? Required: yes.** Confirmed directly via `ConditionOutcome`
    returning Unknown for both of `byte::from_int`'s comparisons under the
    shared instance.

## Stop condition

All conditions from the brief hold:

1. Provably empty immutable Lists (and ImmutableSets) satisfy declared
   `List[T]`/`ImmutableSet[T]` contexts -- parameters and results alike.
2. The rule is admissibility-based and narrow (keyed on the literal atom
   `never` at the element position); ordinary List/Set covariance was not
   introduced (every non-empty invariance control still fails, verified).
3. ImmutableSet received the identical rule, justified by a direct audit
   showing its own type representation soundly proves emptiness
   (`immutable_set_from_list` is its sole producer).
4. Non-empty invariant applied-type negative controls still fail (List and
   Set, both directions, plus same-domain siblings, plus the checked-domain
   negative control).
5. Callee bodies retain every capability their declared collection
   parameter type promises, even when reached with an empty argument
   (verified directly, the mandatory adversarial regression).
6. Mixed empty/non-empty callers are sound under the chosen (Model A,
   identity-unchanged) specialization model (verified directly, including
   a third-caller stability check).
7. `char::encode_utf8` (`encode_utf8`, its real source spelling) has the
   canonical semantic `List[Byte]` result type, verified structurally, not
   merely by display text.
8. The canonicalization fix is generic (one shared `ShapeResult` case),
   never Byte-name-specific.
9. The self-contradictory `List[Byte]` admissibility failure is gone
   (verified: `encode_utf8(...)` now satisfies a declared `List[Byte]`
   parameter with zero diagnostics).
10. The M4/M5/M6 invalid/vacuous fixtures this milestone was asked to
    repair are repaired with legal twins (none left labeled-but-kept, since
    none needed to be).
11. `funcHeaderCount` really counts headers; its two dependent assertions
    (`checked-domain-shared-instance-byte-set`,
    `checked-domain-shared-instance-from-int`) are revalidated against the
    real count and both now genuinely (not vacuously) pass.
12. No M7.b satisfiability (hypothesis-satisfiability/`Narrowed`) work is
    bundled in -- `hir/range.tcl`'s `Narrowed`/`ConditionOutcome` machinery
    is untouched by this milestone beyond the one new `AggregateAdmits`
    helper's own, unrelated, admissibility check.
13. No family-1b/closedness work is bundled in -- `hir::specialize.tcl`/
    `hir::aot.tcl`/`hir::blockescape.tcl` are untouched.
14. Ordinary full regressions pass: 2214/2214, both backends, 78 files.
15. Local GC stress was not run (not required); CI's `gc-stress` job
    remains the gate, per the milestone's own explicit scope (no
    GC-sensitive production code was touched).
16. The FINAL SEMANTIC SOURCE FENCE (SYMBOLIC-TYPE-IDENTITY.md) remains
    intact except for the one narrowly necessary correction to
    `encode_utf8`'s canonicalization consumer this milestone explicitly
    licensed (`hir/types.tcl::ShapeResult`, not the native metadata itself,
    which is unchanged).
17. This report gives an updated, small M7.b scope (below).

## Revised M7.b scope

M7.a's own recommended scope (see M7A-INSTANCE-SELECTION-THEOREM-AUDIT.md,
"Recommended M7.b scope") was:

```
1. FORMALIZE hypothesis satisfiability (A)
2. TRANSPORT the declared aggregate parameter theorem (B)
3. PIN the reviewed identity semantics (C)
4. REPAIR the illegal and vacuous fixtures (D)
5. Regression coverage
6. Re-run the frozen census
```

M7.a.a has now fully consumed **item 4 (D)**: the three fixtures M7.a named
(M4 empty-list, M5 `byte::set` shared-instance, M6 `condition-outcome-12`)
are repaired, `funcHeaderCount` is fixed, and the `-from-int` fixture's own
"genuinely dynamic" caller gap was already legal and needed no repair (only
`checked-domain-shared-instance-byte-set` and `condition-outcome-12` were
actually illegal; `setfromlist-empty-list-stays-generic` was illegal for a
different reason -- the very language rule this milestone changed). M7.b no
longer needs to touch any of these fixtures.

**Item 2 (B, declared aggregate parameter theorem transport) requires one
explicit amendment**, not a scope change: it must now be specified to cover
the empty-caller case *identically* to the pre-existing `List[Byte]`-vs-
`List[int]` case, as one theorem, not two:

- **Instance key:** unchanged by B -- `List[never]` for an empty caller,
  `List[K]` (the observed element kind) for any other caller. B is *not*
  an identity change; per M7.a's own scoping and this milestone's
  confirmation, extending M1's declared-type seeding to a "specific"
  (aggregate) key changes zero instance keys.
- **Observed emptiness theorem:** the instance's own key, `List[never]`,
  already *is* this theorem (nothing new for B to add or preserve).
- **Declared element theorem:** currently unavailable inside a
  `List[never]`-keyed (or any other specific-keyed) instance's own view;
  B's job is to seed it there too, exactly as it must for `List[Byte]`'s
  `List[int]`-keyed instance. There is no reason to special-case `never` as
  the element kind -- B's proposed mechanism ("extend M1's seeding to keys
  of the same constructor, `List[K]`, `K != never`" per M7.a's own
  write-up) should simply drop the `K != never` exclusion: seeding the
  declared `List[int]` element domain into a `List[never]`-keyed instance's
  view is exactly as sound as seeding it into a `List[int]`-keyed one (the
  declared type is a global entry invariant, proven at every legal call,
  independent of which specific key that call happens to produce), and
  strictly more useful, since it lets a *declared* empty-caller instance's
  own dead-code analysis and any future entry-Range work see the same
  facts a `List[int]`-keyed instance already would.
- **View type:** post-B, `xs`'s view inside `f<List[never]>` should become
  the declared `List[int]` (adopted outright, exactly as the `any`/generic
  case already does today) rather than staying `List[never]` -- this is a
  pure precision gain; M7.a.a already proved (Model A) that *soundness*
  never depended on this seeding, so B remains purely an optimization,
  never a prerequisite for M7.a.a's own stop conditions.
- **Listloop element semantics:** unaffected either way for the
  empty-caller instance specifically, since its own listloop body is
  already proven `unreachable` by existing dead-code analysis regardless of
  which element-type view is seeded (verified in this milestone,
  `empty-caller-instance-loop-body-statically-dead`) -- B would not change
  *whether* the loop body is reachable there, only what static facts would
  be available *if* it somehow were.

**Items 1 (A), 3 (C), 5, and 6 are unchanged** from M7.a's own
specification -- this milestone did not touch `hir::range`'s `Narrowed`/
`ConditionOutcome` machinery, `hir::specialize`'s identity policy, or the
frozen corpus, so none of A/C/the frozen-census requirement needs revision.
Item 5's regression-coverage list should additionally include this
milestone's own new tests (`tests/empty-collection-admissibility.test`,
`tests/symbolic-type-identity.test`'s four additions) as reviewed contracts
to keep passing, alongside M7.a's own S01-S14/S03b list.

```text
M7.b (revised)
    1. FORMALIZE hypothesis satisfiability (A) -- unchanged from M7.a.
    2. TRANSPORT the declared aggregate parameter theorem (B) -- unchanged
       mechanism, widened by dropping B's own "K != never" exclusion so a
       List[never]-keyed (empty-caller) instance's view is also seeded with
       the declared element type, symmetrically with every other
       "specific"-keyed instance. Zero instance-key change either way.
    3. PIN the reviewed identity semantics (C) -- unchanged from M7.a.
    4. (CONSUMED by M7.a.a) -- no fixture repair work remains.
    5. Regression coverage -- M7.a's S01-S14/S03b list, plus this
       milestone's own new tests, re-pinned as reviewed contracts.
    6. Re-run the frozen census -- unchanged requirement (uri-steady
       19/17/7055 B/14 guards; refined-checks 39/33/16743 B/24 guards),
       confirmed already unaffected by M7.a.a (see "Generated-code/instance
       deltas" above).
```
