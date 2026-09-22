# Cross-module refined signatures

## Outcome

Ordinary Botlish functions may now declare an optional result contract:

```botlish
fn high_nibble(b) -> HighNibble:
    bit_and(b, 240)
```

This is a statically verified language contract, not an optimizer hint. No
wrapper, runtime type descriptor, evidence object, allocation, or nominal
payload is added. The value remains an ordinary Int. Result-only declarations
are supported; parameter declarations are deliberately deferred.

## Before and the exact loss

Module loading already preserved identity correctly. Surface loading combines
dependency sections into one HIR; resolution maps a qualified reference to
the module BindingId; hygiene gives it a stable qualified name; and a direct
call targets the resolved Block ExprId. Arity comes from block parameters.
Specialization keys Block ExprId plus argument types into an InstanceId.

The loss was in ordinary block inference, not qualification. The body of
`byte::high_nibble` called `bit_and`, whose signature returns plain `int`.
`hir::types::Block` stored that as `resultType`, the binding became
`{block E 1 int}`, callers read the same type, and specialization initialized
from that plain result.

Before this change:

| expression | caller type | range | exact | HIR signature |
|---|---|---|---|---|
| `byte::high_nibble(b)` | `int` | `[0,240]` | `{0,16,...,240}` when body call facts converged | direct block returning `int` |
| `byte::nibble(h)` | `int` | `[0,15]` | omitted as dense | direct block returning `int` |
| local `web::high_nibble(b)` | `int` | `[0,15]` | omitted | inferred from plain-int calls |

The old range precision was body-derived and did not establish semantic
identity.

## Design and representation

Direction A was selected: ordinary Botlish block signatures are first-class.
Direction B, extending the typed native bridge, would make a native wrapper
the price of retaining ordinary source meaning and was rejected.

The parser records an optional result type on the function AST. Lowering
carries it on the ordinary syntax block. Resolution normalizes it through
`core::type`. HIR stores `declaredResult`, the separately observed
`inferredResultType`, and the authoritative public `resultType`. Block types,
bindings, direct calls, `hir::moduleSignatures`, and specialized instances all
use that public result. Specialization does not widen it away. An unannotated
forwarding wrapper still infers the refined result from its inner call.

`ExpandNativeBodies` and `ModuleNativeBridge` were not changed. Their raw
program-core-IR reach limitation still exists for native executable-body
substitution, but ordinary typed stdlib functions no longer depend on them.

## Verification

Definition-site checking first accepts an inferred semantic subtype. For a
refined integer result implemented with generic Int operations, bounded range
facts must prove that every reachable result belongs to the declared domain.

- Interval domains require a contained interval.
- Exact domains require a contained exact set.
- `[0,240]` alone cannot prove `HighNibble`.
- `{0,32,240}` can prove it.
- Branch joins such as `{0,240}` compose through the existing finite-set join.
- Returning `15` as `HighNibble` is a `TYPE` diagnostic.

For constant `x & C`, range analysis enumerates submasks only while the
existing 32-value budget permits it. Thus `0xF0` proves the sparse 16 values,
`0x0F` canonicalizes to `[0,15]`, and larger domains fall back to intervals.
No scalar type name is present in this transfer.

## Canonical domains and hierarchy

`core::type::register -integer-domain` now stores the canonical meaning:

```text
Byte        interval 0 255
Nibble      interval 0 15, parent Byte
LowNibble   interval 0 15, parent Byte
HighNibble  exact {0,16,...,240}, parent Byte
```

Registration validates the descriptor and derives the semantic validator.
`core::type::integerFacts` derives optimizer facts from the same metadata.
There is no separately maintained validator/range/exact triple.

Explicit parents establish `Nibble`, `LowNibble`, and `HighNibble` as Byte
subtypes. `Nibble` and `LowNibble` remain distinct siblings. `HighNibble`
remains positioned: `0xA0`, not logical `0x0A`.

## Type-to-fact seeding

`hir::range::TypeFact` converts the general type-system query into the range
lattice and intersects it with existing flow facts. It is applied to
parameter/local references and successful native or ordinary direct calls.
It never widens a more precise flow fact.

```text
Byte        -> [0,255]
Nibble      -> [0,15]
LowNibble   -> [0,15]
HighNibble  -> [0,240] + {0,16,...,240}
```

Dense exact sets are normalized away, so Byte never materializes 256 values
and Nibble does not retain a redundant 16-value list. HighNibble keeps its
sparse set. Existing `<`, `>=`, `==`, and `!=` narrowing filters the seeded
set: `h < 100` retains `{0,16,32,48,64,80,96}`, and `h != 160` removes 160.
Joins and immutable bindings use the same existing lattice paths.

## After: real byte/web chain

The six declarations in `lib/byte.bot` are result-only and verified:

| function | public result | status |
|---|---|---|
| `high_nibble` | `HighNibble` | declared and verified |
| `low_nibble` | `LowNibble` | declared and verified |
| `nibble` | `Nibble` | declared and verified |
| `complement` | `Byte` | declared and verified |
| `position_low` | `LowNibble` | declared and verified |
| `position_high` | `HighNibble` | declared and verified |

Because parameter contracts are deferred, the total implementations mask
their output where required, making each result contract true for every Int
argument rather than assuming an unchecked input type.

The real `web.bot` call facts are now:

```text
byte::high_nibble(...)
  target: byte::high_nibble<generic>
  type: int[HighNibble]
  range: [0,240]
  exact: {0,16,32,48,64,80,96,112,128,144,160,176,192,208,224,240}

byte::nibble(h)
  target: byte::nibble<int>
  argument type: int[HighNibble]
  type: int[Nibble]
  range: [0,15]

web local high_nibble(...)
  declaration: none
  inferred result: int[Nibble]
  range: [0,15]
```

The immutable binding and direct return paths preserve these types without a
runtime recheck. Same-module, cross-module, forwarding, and specialized calls
have parity. Open/dynamic calls remain limited by the existing function-value
type: precision is available when the block value itself retains its
`{block E arity result}` form, but a call through `any` remains `any`. No
higher-order type-system redesign was attempted.

`hex_pair` receives a Nibble index, but NIR still contains `op listget`.
Existing list bounds lowering does not consume this fact to remove the check;
no ListGet optimization was added.

## Native microscope

The refined-checks microscope reports ordinary HIR bindings:

```text
byte::high_nibble : block(e2)/1 -> int[HighNibble]
byte::nibble      : block(e14)/1 -> int[Nibble]
local high_nibble: block(e74)/1 -> int[Nibble]
```

NIR remains call-based and is not inlined. Most importantly, the intended
next-milestone problem remains visible in `byte::nibble`:

```text
%6 = op ishr %0 %4
```

VCode and object disassembly were captured from the same `program.nir`; this
milestone added no NIR opcode and no Cranelift lowering. The generic tagged
shift/helper path therefore remains the next independent code-generation
problem. The current refined-checks image is 16,713 machine-code bytes across
27 NIR functions; this is a continuity measurement, not an optimization
claim.

## Scope and deferred work

No shift lowering or helper removal, inlining, ASCII work, `is_unreserved`
rewrite, `join`, Bytes/Utf8Bytes, String construction, checked-constructor
native support, known-bits analysis, finite-set budget change, or
bottom/unreachable representation was added. `lib/web.bot` still uses the
compact `byte::nibble(byte::high_nibble(b))` source and `is_unreserved` is
untouched.

The new domain metadata should make future checked constructor lowering
easier because one registry entry now supplies validation and optimizer facts,
but constructors remain unsupported on Cranelift for arbitrary unchecked
input. No general refined-parameter runtime checking was introduced.

## Required question summary

1. The type was lost when ordinary block inference stored the generic Int
   body result as the block result.
2. The fix spans surface syntax, ordinary HIR block metadata, type inference,
   specialization preservation, and range seeding; module resolution itself
   was already correct.
3. Neither native expansion bridge was extended.
4. Ordinary functions now carry their own canonical result signature.
5. Optional `.bot` result declarations use `fn f(...) -> Type:`.
6. They are statically verified language contracts.
7. Result-only declarations are supported.
8. Parameter declarations are not supported yet.
9. Consequently no unproved-argument runtime policy is introduced.
10. No runtime wrapper or evidence object exists.
11. Byte domain metadata is in its `core::type` registry entry.
12. HighNibble sparse metadata is in the same registry.
13. Validation and facts derive from that one descriptor.
14. Registration validation plus exhaustive scalar tests prevent drift.
15. HighNibble seeds interval and exact facts.
16. Nibble normalizes to interval only.
17. Byte avoids exact enumeration.
18. All three nibble types are explicit Byte subtypes.
19. Nibble and LowNibble remain distinct.
20. Exact sets, unlike the interval hull alone, prove sparse contracts.
21. Same-module calls retain the result.
22. Cross-module calls retain it.
23. Specialized instances retain it.
24. Forwarding wrappers infer it.
25. The web helper infers Nibble without an annotation.
26. Immutable bindings retain it.
27. Branch narrowing filters its exact set.
28. Direct forwarding adds no validation.
29. Dynamic calls are precise only while their block value type remains
   specific.
30. Calls through `any` remain imprecise.
31. `byte::high_nibble` in web is HighNibble.
32. Its range is `[0,240]`.
33. Its exact set has the 16 multiples of 16.
34. `byte::nibble` returns Nibble.
35. The web helper infers Nibble.
36. `hex_digits` receives a Nibble.
37. Existing bounds lowering does not remove `listget`.
38. No runtime checks were introduced by signatures.
39. The source remains compact.
40. `is_unreserved` is unchanged.
41. `shift_right` code generation was not changed.
42. No shift helper was removed.
43. No inlining was added.
44. ASCII was not added.
45. `join` was not added.
46. Bytes was not added.
47. Checked constructors were not made native-supported.
48. Bottom/unreachable finite sets were not added.

## Files changed

- `surface/lexer.tcl`, `surface/parser.tcl`, `surface/lower.tcl`
- `hir/syntax.tcl`, `hir/resolve.tcl`, `hir/types.tcl`
- `hir/specialize.tcl`, `hir/range.tcl`, `hir/hir.tcl`
- `hir/format.tcl`, `hir/read.tcl`
- `core/type.tcl`, `core/scalarbits.tcl`
- `lib/byte.bot`
- `tests/refined-signatures.test`
- this report

## Validation and corpus audit

- `tests/refined-signatures.test`: 15/15.
- Existing scalarbits, type, exact-range, range, surface module, parser,
  lowering, and HIR round-trip suites pass.
- `tclsh9.0 tests/all.tcl` passes for interp and compile, including native
  test coverage and the existing bounded-set adversarial cases.
- `cargo test --release --manifest-path native/Cargo.toml`: 60/60.
- Linux `BOTLISH_NATIVE_GC_STRESS=1` release build plus full suite passes.
- `refined-checks` remains `[400, 0]` on native.
- The existing 13-program regression is covered by the full suite: values,
  allocations, machine-code generation, and function counts show no broad
  semantic regression.

The standard 13-program corpus contains no values of these four scalar
refinements, so type seeding adds zero sparse exact sets there. In the actual
web/refined-checks path, sparse exact facts appear only on HighNibble-typed
expressions and call results; Byte/Nibble/LowNibble remain interval-only.
This is bounded by the unchanged budget of 32.
