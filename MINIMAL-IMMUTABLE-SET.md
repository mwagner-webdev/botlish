# Minimal ImmutableSet[T]: the generic immutable-set foundation

## Outcome

`ImmutableSet[T]` is now a first-class, structural applied type, exactly
parallel to `List[T]` (MINIMAL-APPLIED-LIST-TYPES.md), with a real, distinct
runtime value kind on every backend. A `List[T]` value converts to
`ImmutableSet[T]` through one generic native, `immutable_set_from_list`,
whose `List[T] -> ImmutableSet[T]` relationship is expressed the same way
`list`/`list_get`/`list_append`'s own element-typing already is (native
`-result-shape` metadata `hir/types.tcl` already consulted in ordinary
inference) -- no source-level generic function, no new inference machinery.
`immutable_set_contains` is a second native returning `Bool`: absence is an
ordinary `false`, not a failure, for any query value whose required
equality comparisons are defined; if determining membership actually
requires comparing against a runtime kind for which ordinary Botlish
equality is undefined (Block/Native/MutableArray), the pre-existing
`EQUALITY` failure propagates, exactly as it already does for `==`.
Construction deduplicates by Botlish's existing
generic value equality (`core::value::equal`/`rt_value_eq`); set equality
(`==`) is independent of construction/insertion order. The reference
representation is deliberately the simplest sound one: an ordinary
deduplicated vector, O(n^2) construction and membership, no hashing, no
bitmap, no perfect hash, no compile-time constant-set lowering -- this
milestone commits only to *semantics*, never to a representation.

`ImmutableSet` is registered as the applied-type constructor registry's
*second* entry (`hir/types.tcl`'s `constructors` dict), added with **zero**
parser change and **zero** change to `List[T]`'s own inference, invariance,
runtime representation, or tests -- confirming the List milestone's own
closing claim that a future unary container needs only another registry
entry and a parallel structural-type addition, never new syntax.

Full regression (`tclsh9.0 tests/all.tcl`, interp and compile backends,
native backend built with `cargo build --release`): see "Full regression /
GC stress" below for exact counts. `cargo test --release --manifest-path
native/Cargo.toml`: **60/60 passing**. New `tests/immutable-set.test`: **66
tests**, passing on interp, compile, and under
`BOTLISH_NATIVE_GC_STRESS=1`.

`byte::set`, ASCII, Byte bitmaps, perfect hashing, static/compile-time set
lowering, overloading, variadics, set literals, set iteration, and set
algebra were **not** added -- see "Deferred" and the "Required scope
questions" section.

## Semantic definition of ImmutableSet[T]

An immutable set whose members have semantic element type `T`: membership
is fixed at construction and never mutated afterward (no `insert!`,
`remove!`, `with_added`, or any other membership-changing operation exists).
Equality of two `ImmutableSet` values is *set* equality: independent of
construction order, of internal storage order, and of how many times a
member was repeated in the source before deduplication. `ImmutableSet` has
no semantic iteration order and exposes no indexing or iteration API.

## Applied-type integration

`ImmutableSet[T]` reuses `surface::parser::TypeExpr`'s existing unary
applied-type grammar (`NAME "[" TypeExpr "]"`, MINIMAL-APPLIED-LIST-
TYPES.md) verbatim: `surface/parser.tcl` needed **zero** lines changed. The
grammar was already generic over the constructor's name, never special-
cased to "List" -- this milestone is the intended proof of that design.

Resolution reuses `hir::resolve::ResolveTypeExpr` unchanged: a bare name
goes through `hir::types::resolveNamed`, an applied one through
`hir::types::resolveApplication`. Both procs needed only additive changes:

```tcl
variable constructors [dict create List 1 ImmutableSet 1]
...
switch -- $ctor {
    List         { return [MakeList [lindex $argTypes 0] {} 0 0] }
    ImmutableSet { return [MakeSet  [lindex $argTypes 0] 0] }
}
```

## Canonical static representation

One structural applied-type form, `{immutableSet ELEM}`, added to
`hir/types.tcl` alongside the pre-existing `{list ELEM}`/`{list ELEM
{P0..}}` forms -- **not** a nested/positional shape like List's own
(item 39): a set is semantically unordered, so `MakeSet` is `MakeList`'s
element-typing half only, with no positions/shape machinery at all. It is
never globally registered under a synthesized nominal name: `ImmutableSet
[Small]` created in two independent places in one compilation is the
identical Tcl value `{immutableSet {refined int {Small}}}` by ordinary
structural equality (confirmed directly, `core::type::isNamed {ImmutableSet
[Small]}` is `0`), never a second registration.

## Naming: why "immutableSet", not "ImmutableSet", is the shared internal tag

Every layer that must independently agree on "this is a set" -- the
runtime value kind tag (`core/value.tcl`'s `{immutableSet ITEMS}`), the
`core::type` broad/unknown-element primitive, the HIR structural applied-
type's own first element, and every native's `-param-types` spelling of "a
set operand" -- uses the identical lowercase-initial string `"immutableSet"`.
This is **not** incidental: `hir::types::narrow`'s fact-preserving check
(`fact eq [kindOf $current]`, used every time a native call's declared
parameter type narrows a binding's fact) only keeps a *precise* applied
type (rather than collapsing it to the bare declared parameter kind) when
the native's own `-param-types` text is spelled exactly like the
structural tag. `List`/`"list"` already relies on this identity; giving
`ImmutableSet` a *different* internal spelling from its own structural tag
would have silently broken precision-preservation the first time
`immutable_set_contains(s, x)` ran. The user-facing, source-spellable
constructor name stays `"ImmutableSet"` (capitalized), registered only in
`hir::types::constructors` and used only in `hir::types::show`'s display
text -- exactly the same `List`/`"list"` split, just made explicit here
because there was no legacy precedent to lean on.

## Initial invariance

Exactly List[T]'s own rule, for the identical reason:

```
ImmutableSet[A] admissible as ImmutableSet[B] iff A and B are the
identical resolved semantic type
```

`hir::range::ProvesValueAcceptedBy` grew one combined branch:

```tcl
if {[hir::types::IsList $declared] || [hir::types::IsSet $declared]} {
    return [expr {[hir::types::Unshaped $argType] eq $declared}]
}
```

`Tiny <: Small` does **not** imply `ImmutableSet[Tiny] <: ImmutableSet
[Small]` (pinned: `set-type-invariant-subtype-element-rejected`, contrasted
with the scalar case `take_small(tinyValue)`, which remains valid:
`set-type-invariant-subtype-scalar-still-valid`). Two independently-
declared same-domain siblings `A`/`B` (`type A = Int in 0..3`, `type B =
Int in 0..3`) do not lift through the container either: `ImmutableSet[B]`
does not satisfy an `ImmutableSet[A]` parameter even though a scalar
`B`-value remains admissible where a scalar `A` is required (pinned side by
side: `set-type-sibling-rejected` / `set-type-sibling-scalar-still-valid`).

`hir::types::subtype` itself needed **no** dedicated `IsSet` branch at all:
adding `immutableSet` to `IsSpecific`'s tag set (`{native block list
immutableSet}`) is sufficient, because `subtype`'s existing structure
already short-circuits to "true" on exact match (`$a eq $b`, checked before
any kind-specific branch) and falls through to the generic
`IsSpecific($b) -> return 0` fallback for anything else -- exactly the
invariant behavior wanted, achieved by *not* adding a covariant branch
(unlike `IsList`'s own dedicated, deliberately covariant case, which exists
only for `hir/specialize.tcl`'s unrelated positional-shape lattice and must
not be reused here).

## LUB behavior

`lub(ImmutableSet[A], ImmutableSet[A]) = ImmutableSet[A]` (the pre-existing
`$a eq $b` fast path). `lub(ImmutableSet[A], ImmutableSet[B])` for `A != B`
widens straight to the broad `immutableSet` kind -- **not** to
`ImmutableSet[lub(A,B)]`, deliberately diverging from `List[T]`'s own `lub`
(which *does* compute an element-wise lub, for `hir/specialize.tcl`'s own
heterogeneous-tracking reasons):

```tcl
if {[IsSet $a] && [IsSet $b]} {
    return immutableSet
}
```

A set value already has a fixed, already-resolved element identity;
widening two distinct set-valued branches to the broad kind is the more
conservative choice and keeps invariance simple, per the brief's own
explicit instruction.

## Runtime representation

### Interp/compile (Tcl)

`{immutableSet ITEMS}` (`core/value.tcl`), structurally identical to
`{list ITEMS}` but under its own tag, so `core::value::kind` can never
confuse the two. `core/immutableset.tcl` (new) is the natives' home:

```tcl
proc core::immutableset::Dedup {items} {     ;# O(n^2), first-occurrence order
    ...
}
proc core::immutableset::fromList {l} { ... }
proc core::immutableset::contains {s v} { ... }

core::native::register immutable_set_from_list -arity 1 \
    -impl core::immutableset::fromList -param-types {list} \
    -result-type immutableSet -runtime {set-alloc structural-equality} \
    -result-shape {immutable-set 0} -context-free 1
core::native::register immutable_set_contains -arity 2 \
    -impl core::immutableset::contains -param-types {immutableSet any} \
    -result-type bool -runtime structural-equality -context-free 1
```

`core::value::equal`, `core::value::show`, and `core::value::containsBlock`
each grew one case; `core::hashing.tcl`'s generic `hash` native (an
unrelated bootstrap primitive, pre-existing, operating on *any* value) grew
one order-independent (XOR-combined) case too, so it stays total for the
new kind instead of silently mishandling it (`Mix`'s switch had no
`default` arm and would otherwise have returned the empty string).

### Native (Rust)

A new heap kind, structurally identical to `ListObj` (a raw pointer + a
count) but under its own `Header::kind` byte:

```rust
pub const KIND_SET: u8 = 9;
pub struct SetObj { pub hdr: Header, pub len: usize, pub ptr: *mut Value }
```

`Kind::ImmutableSet` is a new `Kind` enum variant (`value.rs`), named
`"immutableSet"` by `Kind::name()`/`Kind::parse()` for the identical reason
given above. `Vm::new_set` mirrors `Vm::new_list` exactly (same
`MAX_COLLECTION_LENGTH` construction-limit check, same allocation
accounting). Two new runtime helpers, `rt_set_from_list`/`rt_set_contains`
(`ops.rs`), both `extern "C"`, both reachable from generated code as
ordinary helper calls (see "Native codegen" below) and from a *dynamically
dispatched* native value through `apply_op`'s exhaustive `OpCode` match
(`invoke_native`).

## Why the first representation is deliberately simple

The brief is explicit that this milestone must not commit to a
representation, only to semantics. Hashing, bitmaps, and perfect hashing
are all *plausible future representations* the brief names outright --
adding any of them now would make a representation choice part of
`ImmutableSet`'s semantics prematurely, before the actual consumer
(`byte::set`, and the four-element URI-unreserved-characters set it
exists for) has even been built. An O(n^2) vector scan is completely
adequate for a four-element set and gives the simplest possible reference
behavior against which any future representation can be checked for
behavioral equivalence.

## Construction from List[T]

`immutable_set_from_list`'s `List[T] -> ImmutableSet[T]` relationship is
expressed as one more native `-result-shape` case,
`{immutable-set L}` (`core/native.tcl`'s `ValidShape`, `hir/types.tcl`'s
`ShapeResult`):

```tcl
immutable-set {
    lassign $shape _ l
    set elem [elementOf [lindex $argTypes $l]]
    if {$elem eq ""} { return $result }      ;# broad/heterogeneous source
    return [MakeSet $elem 0]
}
```

This reuses `elementOf`, the *same* accessor `element`/`append` already use
for `List`'s own element type -- no `ImmutableSet`-specific inference code
beyond this one case, and no source-level generic function anywhere. It
required no generic inference variables: at every actual call, `elem` is
already a concrete, resolved semantic type by the time `ShapeResult` runs.

## Deduplication semantics

Duplicates are eliminated by `core::value::equal`/`rt_value_eq`, O(n^2),
keeping first-occurrence order as a documented implementation/display
detail only (never semantic). `from_list([A, A, B, A])` behaves exactly as
the two-member set `{A, B}` -- pinned directly for both Int
(`set-dedup-collapses-duplicates`) and UnicodeChar (`set-dedup-char`)
members, and for the spec's own worked example
(`set-dedup-required-payload`, `one()` called three times collapsing to one
member).

**Audited equality totality (spec item 18)**: `core::value::equal` (and its
native mirror, `equal`/`rt_value_eq`) is total for every runtime kind
*except* Block, Native, and MutableArray, which have no structural equality
at all (a pre-existing restriction, unrelated to this milestone: comparing
two Blocks with `==` already raises `{CORE SEMANTIC EQUALITY}`). This
milestone reuses that existing rule verbatim, per the brief's own
instruction not to invent set-specific coercive equality: `immutable_set_
from_list` therefore inherits the *same* restriction, not a new one --
confirmed and pinned directly
(`set-shallow-immutability-multi-block-members-equality-undefined`: two
Block-kind list elements make dedup raise `EQUALITY`, because deduplicating
them requires comparing them). A **single** Block-kind element (or any list
whose only duplicates are of ordinarily-comparable kinds) constructs fine,
since dedup never needs to compare it against anything
(`set-construction-block-member-single-ok`) -- this is exactly the
"shallow immutability" contrast the brief asks to document (see below).

## Membership semantics

`immutable_set_contains(set, value)` returns `Bool` for any query whose
required equality comparisons are defined: absence is an ordinary `false`,
not a failure (pinned:
`set-membership-absent`). A query value of a different *ordinary*
comparable kind than the set's members simply never matches --
`contains({'A','B'}, 65)` is `false`, not a `TYPE` error (`set-membership-
cross-kind-false`), and `contains({'A','B'}, 65)` never conflates
UnicodeChar with Int. This is a **different** contract from a typed
parameter: `fn f(b: Byte): ...` remains a compile-time precondition on
legal callers, while a membership query is a total value comparison
operation over an arbitrary Botlish value.

The one honest, documented exception (never invented specifically for
sets, reused unchanged from `equal`): if the queried value, or a set member
being compared against it, is Block/Native/MutableArray, that one
comparison raises the same pre-existing `EQUALITY` trap `==` already has
for those kinds. This is a real, if narrow, consequence of reusing
existing equality exactly as instructed (spec items 17-18) rather than
inventing a "callables never match" special case that would itself have
been the forbidden set-specific coercive equality.

A dynamically wrong **first** operand is the ordinary dynamic `TYPE` error
(`immutable_set_contains(123, x)` -- `set-membership-wrong-first-argument-
is-type-error`), distinct from an ordinary absent-value query.

### Static membership checking: Outcome A (simple total membership)

`immutable_set_contains`'s static signature is `-param-types {immutableSet
any}`: the compiler proves only that the first argument is *some*
`ImmutableSet`, never that the second argument matches the set's declared
element type. This is Outcome A of the brief's own two acceptable choices,
chosen because Outcome B (a "localized dependent static relation" proving
the queried value admissible to the set's own element type) would need
either a new per-call-site dependent-typing mechanism or `-param-types`
itself becoming argument-dependent -- neither of which exists anywhere else
in this codebase's native-metadata system, and building one merely to
tighten this one native's second parameter would be exactly the scope
creep the brief explicitly forbids ("do not broaden scope merely to obtain
Outcome B"). Outcome A is also semantically sufficient: a mismatched value
simply compares unequal, so there is no soundness gap to close.

## Value/set equality

`==` between two `ImmutableSet` values is set equality: same cardinality,
and every member of one has an equal member in the other (both operands
already deduplicated, so this is exactly a bijection test). Independent of
construction order (`set-equality-examples`'s full acceptance table) and
never object identity. `ImmutableSet != List`, even with the identical
member sequence (`set-equality-not-list-equality`) -- different runtime
kinds are never `==`-comparable as equal by `core::value::equal`'s very
first check. `UnicodeChar 'A' != Int 65` inside a set the same way they are
everywhere else (`set-equality-char-vs-int`). Nested containers compare
correctly and recursively: a set of Lists (`set-equality-nested-list-
members`) and a set of `ImmutableSet`s (`set-equality-nested-set-members`,
using the *same* order-independent set-equality rule recursively).

## Shallow immutability

`ImmutableSet`'s immutability is about its own membership/container
structure, not about the values it contains. An element that is itself a
Block (already legal inside an ordinary `List`) is not additionally
prohibited: a singleton (or otherwise never-mutually-compared) set of Block
members constructs and holds correctly
(`set-construction-block-member-single-ok`); the only surfaced restriction
is the pre-existing equality-undefined-for-callables rule, and only when
dedup or membership genuinely needs to *compare* two such values (see
"Deduplication"/"Membership semantics" above). No transitive/deep
immutability type system was introduced.

## Container erasure vs. callable-contract erasure

Identical distinction to `List[T]`'s own (MINIMAL-APPLIED-LIST-TYPES.md),
pinned side by side for `ImmutableSet`:

* **Container erasure is mere lost precision.** `passthrough(s)` alone
  (an untyped parameter has no declared type to seed with) remains legal
  (`set-erasure-passthrough-alone-is-legal`); only a *later* typed use of
  the now-imprecise value is rejected
  (`set-erasure-vs-consume`) -- no runtime scan is ever inserted to
  "rescue" the erased value.
* **Callable-contract erasure remains a soundness rejection**, completely
  unmodified: `hir::callables::Bearing` still flags a function whose only
  parameter is `ImmutableSet[Small]` as a typed callable purely because
  `declaredParamTypes` is non-empty (it never inspects *what shape* that
  entry is), so passing it through an untyped higher-order parameter is
  still rejected by `hir::callables::verify`, itself never touched by this
  milestone (`set-callable-escape-still-rejected`). Exact aliasing
  (`f = consume`) remains fully first-class
  (`set-callable-escape-exact-alias-still-legal`).

## Parameter and result contracts

`hir::types::Block` needed no change: a declared `ImmutableSet[T]`
parameter seeds its binding's type exactly the way any scalar or `List[T]`
parameter always has, so `s`'s declared type inside `f(s: ImmutableSet
[Small])` is unconditionally `ImmutableSet[Small]`, with no caller in the
program at all (`set-param-body-fact`). `hir::range::verifyDeclaredResults`
rejects a body whose static type is merely broad `ImmutableSet`
(`set-result-rejected-broad`) or whose element type is a broad/unrefined
`Int` rather than `Small`'s own evidence (`set-result-rejected-wrong-
element`) -- no element scan at the result boundary, purely the same
structural-equality check used for parameters.

## UnicodeChar integration

`immutable_set_from_list(['-', '.', '_', '~'])` infers `ImmutableSet
[UnicodeChar]` (`set-construct-unicodechar`) through the *identical*
`-result-shape` path a `Small`-element set uses -- **zero** UnicodeChar-
specific code exists anywhere in this milestone's diff. This is the direct
precursor payload for the eventual `byte::set`, verified end to end with
the spec's own exact worked example
(`set-required-unicodechar-payload`): `contains(chars(), '-')` true,
`contains(chars(), 'A')` false, `contains(chars(), 45)` false (Int 45 never
equals UnicodeChar '-', even though '-' *is* U+002D).

## Module retained-value audit

Module-scope binding retention (`hir/modulebinding.tcl`) proves two facts:
context-freedom and a *structural* immutable-value proof (not merely a
type). `immutable_set_from_list` needed one addition to `ImmutableNative`,
directly parallel to the pre-existing `list_append` case:

```tcl
immutable_set_from_list {
    set sourceProof [lindex $proofs 0]
    if {[lindex $sourceProof 0] ne "list"} {
        return {bad unknown "immutable_set_from_list source List is not structurally known"}
    }
    return [list ok [list set [lindex $sourceProof 1]]]
}
```

A module-scope `digits = immutable_set_from_list([one(), one()])` (element
type `Small`, an ordinary source-defined Int refinement) **is** retained:
confirmed directly by allocation-site attribution -- exactly one
`setfromlist` allocation happens at module-startup time, reused by every
later call (`set-module-retained-value`, mirroring `surface-modules-
immutable-value-once-native`'s own methodology).

**Documented limitation, out of scope to fix**: `chars = immutable_set_
from_list(['-', '.', '_', '~'])` at module scope is **not yet** retainable
-- audited and traced to a **pre-existing** gap from the UnicodeChar
milestone, not something this milestone introduces:
`hir::modulebinding::ImmutableExpr`'s own `const` case accepts only `{int
str bool unit}` literal kinds, never `UnicodeChar` (UNICODE-CHAR-LITERALS.md's
own commit never touched `hir/modulebinding.tcl` at all). So even the bare
List literal `['-', '.', '_', '~']` fails this proof today, independent of
`ImmutableSet` entirely; `immutable_set_from_list`'s own new proof case
above is unreachable for it, for a reason that has nothing to do with sets.
Per the brief's own explicit instruction ("if this fails ... report the
limitation clearly. Do not broaden unrelated module initialization
semantics just to force the test"), this is reported, not silently
patched, and pinned as an explicit expected-failure test
(`set-module-retained-value-unicodechar-limitation`) so a future fix to the
UnicodeChar gap shows up as an intentional change to this file's own
expectation, never a silent regression.

## HIR serialization

`hir::read::ParseType` grew the exact mirror of its own `List[...]` case:

```tcl
if {[regexp {^ImmutableSet\[(.+)\]$} $text -> inner]} {
    return [list immutableSet [ParseType $inner $number]]
}
```

placed alongside (order-independent of) the `List[...]` regex, since the
two head words can never collide. `hir::types::show` grew the matching
render case. Round-trip (`format -> parse -> format`) is byte-identical for
a function using `ImmutableSet[Small]` in parameter and result position
(`set-hir-roundtrip`), and for the nested combinations `List[ImmutableSet
[Small]]`/`ImmutableSet[List[Small]]` (parse-level:
`set-type-parse-nested-in-list`/`set-type-parse-list-nested-in-set`;
full-roundtrip: the same `set-hir-roundtrip` test declares both in one
signature). The read-back HIR's `declaredParamTypes` is a live, structurally
-equal applied type, not merely round-tripped text
(`set-hir-roundtrip-preserves-type`).

## Module signatures

`hir::moduleSignatures` needed **zero** changes: it already reports each
exported function's real `declaredParamTypes`/`resultType` verbatim, and an
applied `ImmutableSet[T]` type simply flows through that same, unmodified
field (`set-module-signature`). Cross-module enforcement needed no separate
mechanism either, for the identical pre-existing reason `List[T]`'s own
cross-module tests needed none: module sections are combined into one HIR
before `hir::range::verifyDeclaredParams` ever runs, so a cross-module call
is an ordinary direct call by the time admissibility is checked
(`set-cross-module-valid`/`set-cross-module-invalid`).

## Interpreter / compile / native parity

All four backends (interp, compile, cranelift-generic, cranelift) agree on
construction, dedup, membership, equality, and the dynamic `TYPE` error on
a wrong first operand
(`set-parity-construction-and-membership`/`set-parity-unicodechar`/
`set-parity-wrong-first-argument`). Display text is consistent between
interp and compile, since both Tcl-side and Rust-side dedup are the
identical first-occurrence-order O(n^2) algorithm (`set-parity-show`).

## GC tracing

A native `ImmutableSet`'s members are traced exactly like a `List`'s
elements, added to every place `KIND_LIST` already appears in `heap.rs`:
the mark phase (`stack.extend_from_slice(set_of(v).items())`), `object_
size`, and `free_object`. No new GC concept: `SetObj` is structurally
`ListObj` with a different `Header::kind` byte, so it inherits the
existing non-moving mark-and-sweep collector's whole design unchanged.
`rt_set_from_list` is registered as allocating (`op_may_allocate`), which
is what makes `codegen::roots`' generic safepoint-liveness analysis root
its live operands automatically -- no manual rooting code was written
anywhere; the existing "every allocating helper call is a safepoint, every
register live across it gets a shadow-stack slot" policy already covers
it, exactly as it covers `rt_list_append`.

Verified directly, not merely asserted: a set of String/List members
constructs and answers membership correctly on the native backend
(`set-native-pointer-members-basic`); repeated recursive construction of
sets containing fresh Strings and Lists survives 300 levels of recursion
under `BOTLISH_NATIVE_GC_STRESS=1`, which forces a collection before *every*
single allocation (`set-native-gc-stress-pointer-members`); and a set built
from a heap-valued String, with the originating local binding gone out of
scope and an intervening allocation-heavy padding computation run in
between, still answers membership correctly under GC stress -- proving the
set itself, not merely a surviving caller-side reference, is what keeps its
members alive (`set-native-pointer-member-liveness`).

## Allocation baseline

`immutable_set_from_list(['-', '.', '_', '~'])` allocates exactly one
`ImmutableSet` object in addition to the source List that already exists
(`set-allocation-baseline`) -- no construction fusion (the temporary List
argument is real and separately counted), no constant-set folding (this
call is lowered as an ordinary runtime call at every occurrence, never
hoisted to a compile-time table). This is the explicit baseline the future
representation audit (bitmap/hash-consing/perfect-hash/static-lookup) will
compare against.

## Tests

New: `tests/immutable-set.test`, **66 tests**. Coverage: applied-type
resolution and syntax reuse (no parser change), nested type syntax in both
directions, bare-arity rejection, registry genericity, structural-not-
nominal identity, same-base-different-evidence contrast, initial
invariance (subtype-element and same-domain-sibling, each paired with the
scalar case that remains valid), construction inference (precise,
UnicodeChar, heterogeneous, erasure-broadened, empty, empty-satisfies-
nothing), membership (present/absent/cross-kind-false/wrong-first-operand-
TYPE-error), dedup (Int, UnicodeChar, the spec's own worked payload),
order-independent equality (the full acceptance table, char-vs-int,
not-list-equality, runtime-value-not-display-text, nested List members,
nested ImmutableSet members), the shallow-immutability single-vs-multi-
Block-member contrast, container erasure vs. callable-contract-erasure
(with the typed-callable-escape regression pinned), the two required
worked payloads (basic and UnicodeChar) verified end to end through both
static facts and a runtime result, parameter body seeding, result
contracts (broad and wrong-element rejection), HIR round-trip (flat and
both nesting directions), module signatures, cross-module (valid and
invalid), module retained values (the positive case plus the documented
UnicodeChar limitation, pinned rather than silently absent), repeated/
sequential compilation isolation, four-way backend parity, the allocation
baseline, and three native-backend GC tests (basic pointer members, deep
recursive GC stress, and originating-binding-gone pointer-member
liveness).

Every pre-existing suite continues to pass unmodified, especially
`source-types.test`, `typed-parameters.test`, `typed-callable-escape.test`,
`applied-types.test`, `unicode-char.test`, `range.test`, `specialization.
test` (`hir-specialize.test`), `native.test`, and `surface-modules.test`.

## Full regression / GC stress

```
tclsh9.0 tests/all.tcl                                (interp + compile)
cargo test --release --manifest-path native/Cargo.toml
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
```

* `tclsh9.0 tests/all.tcl` (interp and compile backends, native backend
  built with `cargo build --release --manifest-path native/Cargo.toml`):
  **1960/1960 passing, 0 failed** on each backend (1894 pre-existing +
  66 new `tests/immutable-set.test` cases), including every pre-existing
  test unmodified.
* `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passing** -- unchanged from the pre-milestone baseline (no pre-existing
  Rust unit test needed modification; the new Rust code is exercised
  through the Tcl-driven `tests/immutable-set.test` suite's own native/
  cranelift-backend cases, not new `#[test]` functions).
* `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **1960/1960
  passing, 0 failed** on each backend -- identical to the ordinary run,
  confirming no rooting/allocation-behavior regression anywhere in this
  milestone's own construction/membership/GC-tracing code.

## Deferred (unchanged from the brief)

`byte::set`, ASCII predicates/types, `web::is_unreserved`, any URI logic
change, a `Byte`/`UnicodeChar`/small-finite-domain bitmap or domain-indexed
bitset, perfect hashing, minimal perfect hashing, a general hash table,
hash-consing, compile-time hash generation, static/constant-set lowering,
overloading (a second `set(...)`-shaped constructor), variadics, a set
literal (`{1,2,3}` or similar), set iteration, set algebra (union,
intersection, difference, symmetric difference, subset, superset),
predicate flow refinement, and any representation specialization of
`Byte`/`Int64` -- none of these were added. Representation specialization
notes for the future audit:

* `ImmutableSet[Byte]` -- a 256-bit bitmap candidate (small, dense,
  fully-known domain).
* `ImmutableSet[<small finite bounded type>]` -- a domain-indexed bitset
  candidate, generalizing the Byte case.
* A small compile-time-constant set (e.g. `byte::set(['-', '.', '_',
  '~'])`'s own eventual four-element table) -- a comparison-chain
  candidate, entirely decidable at compile time.
* A generic hash-stable scalar set -- an immutable/perfect-hash candidate
  once the domain is not small/dense enough for a bitset.

Any future representation may change only *performance and storage*: the
semantic reference behavior fixed by this milestone -- membership, dedup,
set equality, and element semantic type -- must not change underneath it.

## Required architecture questions

1. **Canonical static representation of `ImmutableSet[T]`?** The structural
   HIR form `{immutableSet ELEM}` (`hir/types.tcl`), parallel to but
   independent of `{list ELEM}`.
2. **Structural or nominal?** Structural. `core::type::isNamed
   {ImmutableSet[Small]}` is `0`; nothing is registered under a
   synthesized name anywhere.
3. **Did the existing applied-type parser need any change?** No --
   confirmed, `surface/parser.tcl` has zero lines changed in this
   milestone's diff.
4. **How is `ImmutableSet` registered as a unary constructor?** One more
   entry in `hir::types::constructors` (`ImmutableSet 1`) plus one `switch`
   arm in `hir::types::resolveApplication`.
5. **What is the internal broad/unknown-element set type?** The bare
   primitive `immutableSet` (`core::type::primitives`), the exact lowercase
   analogue of List's own broad `list`.
6. **Is bare `ImmutableSet` source-spellable?** No -- it is intercepted by
   `hir::types::resolveNamed`'s constructor-arity check before
   `core::type::normalize` is ever consulted, exactly like bare `List`.
7. **Runtime representation on interp/compile?** `{immutableSet ITEMS}`, a
   tagged Tcl list structurally identical to `{list ITEMS}` under a
   distinct tag.
8. **Native representation?** `SetObj { hdr, len, ptr }`
   (`native/src/runtime/value.rs`), structurally identical to `ListObj`
   under `Header::kind = KIND_SET` (9), a value distinct from `KIND_LIST`
   (3).
9. **Is the runtime kind distinct from List?** Yes, on both backends,
   confirmed by construction (a different tag/kind byte) and by test
   (`set-equality-not-list-equality`; `set-construction-block-member-
   single-ok` checks `core::value::kind` is literally `immutableSet`).
10. **How does GC trace set members?** Identically to how it traces a
    List's elements: `heap.rs`'s mark phase gained one `KIND_SET =>
    stack.extend_from_slice(set_of(v).items())` arm alongside `KIND_LIST`'s
    own.
11. **Does construction allocate?** Yes, exactly one `ImmutableSet` object
    (plus whatever the source List already needed).
12. **Does membership allocate?** No.
13. **Does a set expose semantic iteration order?** No -- no iteration API
    exists at all in this milestone.

## Required semantic questions

14. **What does immutability mean here?** No operation mutates an existing
    `ImmutableSet`'s membership; there is no `insert!`/`remove!`/`clear!`
    and no persistent `with_added` (deferred).
15. **Shallow membership immutability, or transitive deep immutability?**
    Shallow: the *container* is immutable; an element that is itself a
    mutable/reference-like value (a Block) is not additionally restricted
    beyond its own pre-existing equality limitations.
16. **How are duplicates handled?** Eliminated at construction by
    `core::value::equal`/`rt_value_eq`, O(n^2), keeping first-occurrence
    order as an implementation/display detail.
17. **What equality relation defines duplicate membership?** The
    language's ordinary existing generic value equality -- no set-specific
    coercive equality was invented.
18. **Is set equality independent of construction order?** Yes.
19. **Is `ImmutableSet[T]` invariant initially?** Yes.
20. **Is scalar value-domain admissibility lifted through the set
    container?** No -- pinned side by side with the scalar case that
    remains valid (`set-type-sibling-rejected`/`-sibling-scalar-still-
    valid`).
21. **Can a membership query use a value of another runtime kind?** Yes,
    returning `false` for an ordinary comparable-kind mismatch. The one
    documented exception (Block/Native/MutableArray, inherited unmodified
    from `==`) is spelled out above under "Membership semantics".
22. **Does membership absence produce Error?** No -- an ordinary `Bool`
    completion, never a Result/Error.
23. **Can element-type information be erased through an untyped ordinary
    value?** Yes, as lost proof precision (`set-erasure-passthrough-
    alone-is-legal`).
24. **Can that erased value later satisfy `ImmutableSet[T]` without
    recovering proof?** No (`set-erasure-vs-consume`); no runtime set scan
    is ever inserted to rescue it.

## Required construction questions

25. **What operation implements the first construction path?**
    `immutable_set_from_list` (root native, `core/immutableset.tcl`).
26. **How is `List[T] -> ImmutableSet[T]` represented in static metadata?**
    A native `-result-shape` case, `{immutable-set L}`, consumed by
    `hir::types::ShapeResult` exactly like `element`/`append` already are
    for `List`.
27. **Did this require generic source functions?** No.
28. **What happens when source List type is broad?** The result is the
    broad `immutableSet` kind, never a false precise `ImmutableSet[T]`.
29. **What happens for `List[never]`?** `immutable_set_from_list([])`
    infers `ImmutableSet[never]`, satisfying no `ImmutableSet[T]`
    parameter under initial invariance (no contextual typing added to
    rescue it).
30. **Does construction introduce a new Error completion?** No new
    Error-*completion* type; it can raise the pre-existing `EQUALITY`
    runtime trap in the documented multi-callable-member case (see
    "Deduplication semantics") -- not a new failure *mode*, an inherited
    one.
31. **Are duplicate values eliminated at construction?** Yes.
32. **Does construction preserve insertion order semantically?** No --
    first-occurrence order is kept only as an implementation/display
    detail, never a semantic guarantee.

## Required integration questions

33. **Static type of `immutable_set_from_list(['-', '.', '_', '~'])`?**
    `ImmutableSet[UnicodeChar]`.
34. **Did UnicodeChar require any set-specific typing code?** No.
35. **Does a function parameter `ImmutableSet[Small]` seed that type
    unconditionally?** Yes.
36. **Do result contracts understand it?** Yes.
37. **Do module signatures preserve it?** Yes.
38. **Does HIR format/read preserve it?** Yes, textually and semantically.
39. **Does typed-callable escape protection still work for a function
    taking `ImmutableSet[T]`?** Yes, unmodified
    (`hir/callables.tcl`: zero lines changed).

## Required runtime questions

40. **Complexity of first-version construction?** O(n^2) (a linear scan
    per candidate member against the accumulator so far).
41. **Complexity of membership?** O(n) (a linear scan of the set's
    members).
42. **Complexity of set equality?** O(n^2) (a linear "does A's member
    appear in B" scan per member, both operands already deduplicated).
43. **Why were those complexities accepted?** The brief explicitly asks
    for the simplest sound representation, deferring hashing/bitmaps to a
    later representation audit; the intended immediate consumer is a
    four-element set.
44. **Is any hashing used?** No -- `ImmutableSet`'s own membership/equality
    never hashes. (The *pre-existing, unrelated* generic `hash` native
    gained a case so it stays total for the new kind, per the equality-
    totality audit above; this is not part of `ImmutableSet`'s own
    semantics and exposes no new API.)
45. **Is any Byte bitmap used?** No.
46. **Does the set correctly retain pointer-valued members across GC?**
    Yes.
47. **Was this demonstrated under GC stress with heap-valued elements?**
    Yes (`set-native-gc-stress-pointer-members`,
    `set-native-pointer-member-liveness`).

## Required scope questions

48. Was `byte::set` added? No.
49. Was ASCII added? No.
50. Was URI logic modified? No.
51. Was a bitmap added? No.
52. Was a hash table added? No.
53. Was perfect hashing added? No.
54. Was compile-time static-set lowering added? No.
55. Was overloading added? No.
56. Was variadicity added? No.
57. Was a set literal added? No.
58. Was set iteration added? No.
59. Was set algebra added? No.
60. Was predicate refinement added? No.
61. Was representation specialization added? No.

## Acceptance table

| EXPRESSION / CALL | RESULT |
|---|---|
| `immutable_set_from_list([one(), one()])` (element `Small`) | `ImmutableSet[Small]` |
| `immutable_set_from_list(['-', '.', '_', '~'])` | `ImmutableSet[UnicodeChar]` |
| `immutable_set_from_list(passthrough([1, "x"]))` (erased/heterogeneous) | broad `ImmutableSet` |
| `immutable_set_from_list([])` | `ImmutableSet[never]` |
| `immutable_set_contains(immutable_set_from_list([1,2,3]), 2)` | `true` |
| `immutable_set_contains(immutable_set_from_list([1,2,3]), 4)` | `false` |
| `immutable_set_contains(immutable_set_from_list(['A','B']), 'A')` | `true` |
| `immutable_set_contains(immutable_set_from_list(['A','B']), 65)` | `false` |
| `immutable_set_from_list([1,1,2]) == immutable_set_from_list([1,2])` | `true` |
| `immutable_set_from_list([1,2]) == immutable_set_from_list([2,1])` | `true` |
| `immutable_set_from_list(['A']) == immutable_set_from_list([65])` | `false` |
| `ImmutableSet[Small]` -> parameter of the identical type | valid |
| `ImmutableSet[Tiny]` -> `ImmutableSet[Small]` parameter | compile error |
| `ImmutableSet[B]` -> `ImmutableSet[A]` parameter (same-domain siblings) | compile error |
| scalar `B`-value -> scalar `A` parameter (existing value-set proof) | valid |
| precise set -> untyped passthrough | allowed (erasure) |
| erased set -> typed `ImmutableSet[T]` parameter | compile error |
| typed callable taking `ImmutableSet[T]` -> untyped higher-order parameter | compile error |
| `immutable_set_contains(123, x)` | `{CORE SEMANTIC TYPE}` |
| `immutable_set_from_list(123)` | `{CORE SEMANTIC TYPE}` |

## Stop condition

All conditions from the brief hold: `ImmutableSet[T]` is a first-class
structural applied type with a distinct, immutable runtime value kind on
every backend. A `List[T]` converts to `ImmutableSet[T]` through one
generic builtin construction relationship, expressed as native metadata,
never a source-level generic function. Construction deduplicates members by
ordinary Botlish value equality. Membership returns an ordinary `Bool` for
any query whose required equality comparisons are defined over a valid
set; it is not unconditionally total, since ordinary Botlish equality
itself is undefined for some runtime kinds (Block/Native/MutableArray),
and a membership query that actually requires comparing against one of
those propagates the pre-existing `EQUALITY` failure instead of returning
`Bool`. Set equality is independent of insertion/
construction order. The first runtime representation is deliberately
simple (an O(n^2) deduplicated vector) and commits to no hashing, bitset,
or compile-time lookup lowering. Typed parameters/results/HIR/module
metadata understand `ImmutableSet[T]` without any runtime whole-set
validation. UnicodeChar works as an ordinary set element type with zero
special-case code. `byte::set`, ASCII, URI changes, Byte bitsets, perfect
hashing, static set lowering, predicate refinement, and Byte/Int64
representation specialization were not started.
