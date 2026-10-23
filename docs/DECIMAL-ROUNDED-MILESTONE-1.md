# DECIMAL-ROUNDED-MILESTONE-1.md -- `DecimalRounded`, the first precision-guaranteed numeric refinement

Status: implemented (completion report). This milestone adds
`DecimalRounded{minDecimalsPreserved: N}` (optionally with
`maxDecimalsPreserved: M`), the first *scalar refinement* of Botlish: a type
whose integer parameters are compiler-known facts. It specifies a decimal
guarantee, not a representation; the compiler proves the guarantee for
decimal constants and their arithmetic, makes its loss a type event,
reads every observation at the guaranteed precision, and implements the
values with ordinary binary64 machinery where that is proven sufficient.

The code: `hir/refinements.tcl` (the scalar-refinement schema),
`hir/decimal.tcl` (literal typing, operator resolution, proofs,
verification, elaboration, display), `core/decimal.tcl` (exact arithmetic,
the rounding rule, the representation choice, the Tcl runtime),
`native/src/runtime/decimal.rs` (the native runtime's exact helpers), and
hooks in `hir/types.tcl`, `hir/range.tcl`, `hir/operators.tcl`,
`hir/interchange.tcl`, the parser and the native lowering.

Contents:

1. Language syntax
2. Semantic definition
3. The rounding rule
4. The lower bound
5. The upper bound
6. Literal typing and construction
7. The scalar-refinement infrastructure
8. The proof representation
9. Proof rules for each operation
10. Comparisons and equality
11. Weakening, decay and minting
12. How proof loss appears
13. Runtime representation
14. Where Float64 is an implementation detail (and the audit of dependences)
15. Constant folding
16. Target independence
17. Worked examples
18. Diagnostics
19. Tests, audits and CI
20. Conservative limitations
21. Seams for later work
22. What to run when changing this

## 1. Language syntax

A scalar refinement is a type name followed by braces holding integer
parameters, `NAME{PARAM: INT, ...}`. The fields are separated by commas or
line breaks:

```botlish
fn tax_rate() -> DecimalRounded{minDecimalsPreserved: 2}:
    0.19

fn rate() -> DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}:
    0.1955

fn price(x: DecimalRounded{
    minDecimalsPreserved: 2
    maxDecimalsPreserved: 4
}) -> int:
    1
```

It stands wherever a type annotation does: a parameter, a declared result,
a struct field, an element type (`List[DecimalRounded{...}]`). There are no
angle brackets and no type parameters: a member of the family is one type
whose parameters are numbers (`surface::parser::ScalarRefinement`, AST
`{refine NAME FIELDS}`). A malformed field -- no colon, a value that is not
an integer literal, a field written twice, two fields on one line without a
comma -- is a syntax error where it is written.

The library surface is two intrinsics: `std::float64::from_decimal_rounded(x)`
(after `import std::float64`) and `std::decimal_rounded::round[T](x)` (after `import
decimal_rounded`), and one builtin error, `UnrepresentableDecimal`.

## 2. Semantic definition

A value of `DecimalRounded{minDecimalsPreserved: N}` stands for a
mathematically intended number t (a real number; for every value the
compiler makes, a rational it knows exactly at the point it proves it). The
type guarantees, for every P with 0 <= P <= N:

    round(v, P) = round(t, P)

where v is the value as the implementation holds it and round is the
rounding rule of section 3. This is the "nested" form of "rounding it to N
places gives the intended decimal": it holds at N *and at every coarser
precision*, so a value correct to 4 places is correct to 2 (weakening,
section 11) and an observation at any precision up to N reads the intended
decimal. Correct rounding at N alone would not give that. The binary64
nearest 0.15 is 0.14999999999999999444...: it rounds to 0.15 at two places,
as 0.15 does, but to 0.1 at one place, where 0.15 is a tie that rounds to
0.2. Under the nested definition that binary64 represents the decimal 0.15
to 0 places only (it fails at P = 1), so the compiler represents the
constant 0.15 by the next binary64 up, 0.15000000000000002220..., which
holds it to 16 places.

What the type does *not* say:

* nothing about the representation: the compiler chooses it (today a
  binary64, section 13) and may choose differently later;
* nothing about digits beyond N: they may be anything the representation
  happens to hold, and no observation reads them (section 10);
* nothing exact: `DecimalRounded` is not a decimal floating-point type,
  not fixed point, not a rational and not an exact decimal. 0.1 + 0.2 is
  not exactly 0.3 inside; it is a value whose decimal at the guaranteed
  places is 0.3;
* no magnitude: the type states no range, which is why arithmetic on a
  value known only by its type proves nothing (section 9).

`Float64` is the opposite contract: a concrete finite binary64 whose every
bit is relevant and observable (FLOAT64-MILESTONE-1.md). The two are
different kinds with different values; nothing converts between them
implicitly.

## 3. The rounding rule

Round to nearest, ties to even, of the exact value: at P places a number
lying exactly halfway between two P-place decimals goes to the one whose
last digit is even. 1.245 is 1.24 at two places, 1.235 is 1.24, 1.255 is
1.26, -1.245 is -1.24, 2.5 is 2 at zero places, 0.005 is 0.00. A zero
result has no sign (-0.004 rounds to 0.00). The rule reads the exact value
(a rational: a literal's digits, a binary64's exact binary value), never a
host floating-point formatting of it: `core::decimal::RoundHalfEven` and
`RoundAt` (integer arithmetic on Tcl's arbitrary-precision integers) and
`runtime/decimal.rs`'s `round_half_even` (`num-bigint`), which agree by
construction and by test (`dr-rounding-rule`, `dr-boundaries-*`, the
fuzzer's independent rounding).

It is the same rule as binary64's own round-to-nearest, and the one
`std::float64::from_int` already uses; nothing in Botlish gave a reason to
choose another.

## 4. The lower bound

`minDecimalsPreserved: N` (required, 0 to 1000) is the precision the
program may rely on: every observation of the value -- a comparison,
equality, a decay to Float64, its display -- reads round(v, P) for a P <=
N its static type states, and gets round(t, P). N = 0 guarantees the
integer rounding. The upper limit 1000 is a schema bound on the parameter,
not a property of any representation (binary64 holds no more than 1074
fraction digits, and a constant's proof checks every place up to N).

## 5. The upper bound

`maxDecimalsPreserved: M` (optional; M >= N, also 0 to 1000) is an
*observation ceiling*: no behavior of the program may depend on
distinctions finer than M places, whatever digits the representation
carries. It constrains semantics, never storage.

The rule that enforces it is the observation rule itself: every
observation reads at most the guaranteed precision N of its operands' static
types (section 10), and N <= M for every valid type, so no observation ever
reads beyond the ceiling -- comparisons, `==`, branch conditions on them,
the decay to Float64 and the display all read N places. Hashing and the
type-blind equality of an aggregate, which would read the representation,
are refused (section 10). Two correct implementations, one carrying more
hidden bits than the other, therefore make every decision alike.

As a type fact, the ceiling is never dropped or raised: a value of
`DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}` is not a
`DecimalRounded{minDecimalsPreserved: 2}` (whose observations a later
milestone could make finer) nor a `{..., maxDecimalsPreserved: 6}`; a value
with no ceiling, or a higher one, does stand where a lower ceiling is
required (it is then observed less finely, which is safe). A type with M <
N describes no value and is `REFINEMENT-PARAMETER`.

Display precision, guaranteed precision and the ceiling are three
different numbers. This milestone displays exactly N places (section 13):
the guaranteed precision, which is never above the ceiling.

## 6. Literal typing and construction

The lexer, parser and AST keep every decimal literal's exact spelling, as
before. The lowering (`surface::lower::DecimalConstant`) still writes a
Float64 constant for it -- and now also records the literal's canonical
exact decimal on the node (`hir::syntax::withDecimal`, the `decimal`
field). It decides nothing else.

**The choice is made in exactly one place: `hir::decimal::resolve`**, which
`hir::operators::resolve` calls first, after every typing walk of
`hir::types::infer`'s fixpoint. A *decimal constant expression* -- a
decimal literal, or unary minus or `+ - * /` of decimal constant
expressions -- becomes a DecimalRounded constant expression exactly where a
refined DecimalRounded type is expected (`hir::decimal::Expectations`):

* the value of a function whose declared result is one: its final
  expression, a branch of an `if` there, a `return`'s value;
* an argument of a parameter declared as one;
* a field of a struct construction whose field is declared as one;
* an element of a List literal where a List of them is expected (by any of
  the above);
* a handler's value, where the handled call's result type is one;
* an operand of an operator whose other operand is statically one.

Then its literals mean their exact source decimals -- the HIR const becomes
`DecimalRounded TEXT`, TEXT the canonical exact decimal, and its value is a
representation chosen from that decimal alone (`core::decimal::constant`,
never from the Float64 the literal would otherwise have been); its
operators become the DecimalRounded operations; and its root's static type
is the expected type (`decimalExpected`, with `decimalReason` saying where
the expectation comes from), which section 9's proof must establish.
Everywhere else a decimal literal is the Float64 it was: there is no global
literal inference, and there are no typed local bindings (`x = 0.5` is a
Float64, as before).

So the meaning of `0.295` in a two-place context is the decimal 0.295,
which rounds (half to even) to 0.30 -- although the binary64 nearest 0.295
is 0.29499999999999998446..., which rounds to 0.29. The representation the
compiler picks for it is the next binary64 up, 0.29500000000000004
(section 13).

A value computed at run time from Float64 values is made a DecimalRounded
value only by `std::decimal_rounded::round[T](x)` (section 11), which quantizes:
it never pretends a Float64 already is a decimal.

## 7. The scalar-refinement infrastructure

`hir/refinements.tcl` is generic over a schema table, `families`; this
milestone declares one family (LIST-CARDINALITY-REFINEMENTS.md adds the
second, `List[T]{length: N}`, with the order `exactly`):

    DecimalRounded:
        base         DecimalRounded (core/type.tcl's primitive)
        params       minDecimalsPreserved  required, 0..1000, order atLeast
                     maxDecimalsPreserved  optional, 0..1000, order atLeast,
                                           absent = inf (no ceiling)
        constraints  maxDecimalsPreserved atLeast minDecimalsPreserved

Every operation on refined types reads only the schema (no procedure of the
file names a parameter; `dr-schema-generic` pins it):

| concern | where |
|---|---|
| declaration / schema | `families` |
| validation | `Problems`, `Resolve` (REFINEMENT-PARAMETER, every problem named) |
| canonical representation | `{srefined FAMILY FACTS}`, FACTS the stated parameters in schema order (`Canonical`): equal types are equal values, whatever the written order |
| type equality | value equality of the canonical form |
| implication / weakening | `Implies` (each parameter by its order; an absent optional parameter takes its `absent` value), which `hir::types::subtype` asks |
| joins | `Lub` (each parameter's weaker value), `Glb` (stronger; "" when a constraint breaks) |
| formatting / interchange | `Show` (the source spelling, which HIR text writes) and `Parse` (which `hir::read` uses); interchange holds the canonical form itself |
| decay | every member is a subtype of the family's base type, which states no fact |
| proof attachment | the proved facts live on HIR nodes (`decimalExpected`, the root's type) and in the elaborated observations (section 10) |

A parameter's *order* says which values are stronger facts; `atLeast` is the
one this family needs (a larger minimum is a stronger guarantee; a larger
or absent ceiling is a stronger, i.e. finer-observable, value). A later
family adds its row and, if needed, an order (`atMost` for a magnitude
bound, `exactly` for a List length): `List[T]{length: 4}` and
`ExactDecimal{minScale: 2, maxMagnitude: 40000}` are rows, not new type
machinery. Scalar refinements are distinct from the *refinement values* of
`refined type NAME = CARRIER` (REFINEMENT-VALUES.md, `hir/refine.tcl`):
those are nominal predicates proven by `proves`; these are compiler-known
integer facts of a built-in family.

The bare base type `DecimalRounded` exists inside the compiler (a value of
unknown precision, the join of incompatible facts) but is no annotation:
written alone it is REFINEMENT-PARAMETER, and an operation that needs a
precision rejects a value whose type states none.

## 8. The proof representation

For every node of a DecimalRounded constant expression the compiler knows
two numbers exactly (`hir::decimal::Facts`): the *true value* t, the exact
rational of the expression's mathematics (the literals' decimals, then
exact rational `+ - * /`, `core::decimal::TrueOperation`), and the
*implementation value* x, the binary64 the run will compute (each literal's
chosen representation, then each binary64 operation correctly rounded,
computed with exact rationals and the IEEE 754 rounding definition --
`core::decimal::ExactOperation`, never host floating point). The proof of
the root at precision N is

    Proven(x, t) >= N

where `core::decimal::Proven` is the largest P such that round(x, Q) =
round(t, Q) for every Q <= P (`exact` when x = t, which satisfies every
precision). This is the brief's "ideal value plus enclosure" with the
tightest possible enclosure: for a constant the implementation value is not
bounded, it is known, so the proof never loses precision to interval
widening and never accepts a constant a run would get wrong. Two further
outcomes: `nonfinite` (some binary64 result is not finite) and `undefined`
(a division by an exactly zero true value).

For a value that is not a constant -- a parameter, a call's result, a field
-- the only fact is its type: t lies in the rounding cell of its N-place
decimal. That fact does not compose (section 9).

## 9. Proof rules for each operation

**Constants: `+ - * /` and unary minus.** The result guarantee is not
computed from the operands' guarantees at all (no `min(lhs, rhs)`): it is
Proven(x, t) of the result itself, from the exact operation on the
operands' exact true values and the correctly rounded binary64 operation on
their exact implementation values. Each operation therefore keeps exactly
what it keeps:

* addition and subtraction keep the absolute error of their operands plus
  the result's rounding, and can lose places to cancellation:
  `0.1 * 3.0 - 0.3` is 5.55e-17 in binary64 and is proven to 15 places, not
  16;
* a large magnitude leaves few fraction places: `1.0e20 + 0.01` is proven to
  1 place (binary64 holds about 15 to 17 significant digits in all);
* multiplication and division scale the relative error: `0.1 * 10.0` is
  exactly 1 (proven at every precision) though 0.1 alone holds 16 places,
  and `1.0 / 3.0` is proven to 16;
* unary minus is exact, and the rounding rule is symmetric, so -x keeps x's
  guarantee;
* a division by an exactly zero true value has no value to round:
  DECIMAL-PRECISION ("divides by a value whose exact decimal value is zero"),
  even when the binary64 divisor is a nonzero approximation (`1.0 / (0.1 *
  3.0 - 0.3)` is 1.8e16 in binary64); a binary64 result that is not finite
  is NonFiniteFloat instead (section 15). The two events are distinct.

The expectation, not the operands, decides the type: a constant is accepted
at its expected type exactly when it is proven to that type's N, else
DECIMAL-PRECISION reports how many places it is proven to.

**Values known only by their type.** No rule is sound, so arithmetic on
them is rejected (DECIMAL-GUARANTEE-LOST) rather than given a type. Of such
an operand only "t is in the cell of its N-place decimal d" is known, and
rounding is discontinuous: a result's exact value lies in an interval of
positive width around the combination of the decimals, and the type states
no position, so for every precision P there are operands whose results lie
on both sides of a P-place boundary. For example, with `a` and `b` of
`DecimalRounded{minDecimalsPreserved: 2}` both displaying 0.00, a + b may be
anything in (-0.01, 0.01): 0.004 + 0.004 = 0.008 rounds to 0.01, 0.001 +
0.001 = 0.002 to 0.00 -- not even its zero-place decimal is fixed (take
decimals summing to 0.5). Retaining `min` of the operands' guarantees would
be the unsound inference rule the brief warns about; the `blind-min` mutant
(section 19) is that rule, and the tests reject it. A program computes with
such values by decaying them to Float64 and quantizing the result back
(section 11): the loss and the re-establishment are both written in the
program.

Unary minus of such a value is exact and keeps its type. Comparisons are
observations, not arithmetic (section 10).

## 10. Comparisons and equality

**The rule.** `a < b`, `<=`, `>`, `>=` and `==` of two DecimalRounded
operands compare round(a, P) with round(b, P), P the smaller of the two
operands' guaranteed precisions; `!=` is the negation of `==`. (A decimal
constant operand has the other operand's type, so P is always a declared
precision; a value whose type states no precision is TYPE.) The precision
is written into the call after every check (`hir::decimal::Elaborate`: the
check form `DecimalRounded#<` becomes `decimal_rounded#less(a, b, P)`), so
no backend chooses it.

**Soundness.** Each operand's P-place decimal is its true value's
(section 2), so the decision is a function of the true values alone: `a <
b` holds exactly when round(t_a, P) < round(t_b, P), which implies t_a <
t_b. When the true values' P-place decimals are equal, the true values may
be in either order or equal, and `<` and `>` are both false: the
conservative choice is "not provably ordered", never a guess from the
representations. At two places 1.235 and 1.244 are both 1.24: `<` is false,
`==` is true.

**Equality** is therefore "the same decimal at P", an equivalence on the
values of one type, and the one equality model of this milestone. It is
explicit about what it is: two values equal at two places may be unequal
at three, and a comparison of a two-place and a three-place value reads two
places. No hidden digit decides anything, so the ceiling holds.

**Refused.** Equality that does not know the precision is refused rather
than given a fragile meaning: `==` of a List or struct holding
DecimalRounded values (TYPE: "a DecimalRounded value is equal to another at
the precision its type guarantees, which equality of a value holding one
does not know"), an `ImmutableSet` of them (TYPE, as an annotation and as a
call's result: a set hashes and compares its members by value), and the
type-blind `==` and `hash` a value can still reach at run time -- through an
untyped function's parameters, for instance -- which stop with EQUALITY on
every backend instead of comparing representations (`core::value::equal`,
`core::hashing::Mix`, the native `equal` and `rt_hash`).

## 11. Weakening, decay and minting

**Weakening is subtyping** (`hir::refinements::Implies`):
`DecimalRounded{minDecimalsPreserved: 4}` stands where 2 places are
required, `{2}` where `{2, max 4}` is, `{2, max 6}` where `{2, max 4}` is;
never the reverse, and never a ceiling dropped or raised (section 5). The
join of two refined types keeps each parameter's weaker value
(`{4, max 6}` and `{2}` join to `{2, max 6}`), so an `if` whose branches
have different guarantees has the weaker one.

**Decay is visible.** Every refined type is a subtype of the base, and a
value decays to a number of another kind only through
`std::float64::from_decimal_rounded(x)`: the Float64 nearest round(x, N), N the
precision x's static type guarantees -- the guaranteed decimal, never the
representation's hidden digits, so every representation and every backend
give the same Float64. Its representation need not change, and in fact it
does: the decay normalizes to the decimal (0.29500000000000004 at two
places decays to 0.3).

**Minting needs a proof or a quantization.** A Float64 is never a
DecimalRounded value (TYPE, "nothing converts one implicitly"), and a value
never gains a stronger type without a proof (TYPE: "a value of
DecimalRounded{minDecimalsPreserved: 2} is known only to 2 decimal places,
and a guarantee is never strengthened without a proof"). The two ways to
get a guarantee are a decimal constant the compiler proves (section 9) and
`std::decimal_rounded::round[T](x)`, which establishes it by quantizing: its
decimal is x's exact binary value rounded half to even to T's places (the
Float64 1.005 is 1.00499999999999989..., so it is 1.00 at two places), and
its representation is chosen to satisfy every place up to N; when none
does -- a decimal finer than binary64 resolves at its magnitude, such as
4873863637.854281 at nine places -- it fails with the declared builtin
error `UnrepresentableDecimal`. T is imprinted explicitly and must be a
refined DecimalRounded type.

## 12. How proof loss appears

Proof loss is never silent and never a silent Float64 fallback:

* a constant not proven to the expected places: DECIMAL-PRECISION, with the
  places it is proven to ("this result is only proven correct to 16 decimal
  places, but the declared result of ratio requires
  DecimalRounded{minDecimalsPreserved: 17}"), the exact value and the
  binary64 value as secondary explanation;
* arithmetic on values known only by their guarantee:
  DECIMAL-GUARANTEE-LOST. The operation's value is *poison*
  (DIAGNOSTIC-RECOVERY.md): nothing that only restates the loss is
  reported, and no backend compiles it;
* a value that does not have the type its position requires: TYPE, with a
  clause in semantic terms (`hir::decimal::MismatchClause`: strengthening,
  a dropped or raised ceiling, Float64 where DecimalRounded is required and
  the reverse, a value of unknown precision);
* a weaker guarantee where no stronger one is required is simply the
  weaker type: the join of an `if`'s branches, a value weakened through a
  parameter.

## 13. Runtime representation

**Values.** A DecimalRounded value is a binary64 under its own value kind
-- `{DecimalRounded X}` in the Tcl runtime (`core::decimal::value`), a
boxed `FloatObj` with heap kind `KIND_DECIMAL` (float-type code 1) natively
-- the same size and boxing as a Float64, and **no precision metadata**:
the refinement is erased after the proof. The only facts that survive to
run time are the precisions the elaboration writes into the observations as
integer arguments (`decimal_rounded#less(a, b, 2)`, NIR's `d64lt a b p`),
because those operations need a P and the value does not carry one; and the
kind tag itself, which lets the type-blind operations (`==`, `hash`, an
untyped display) refuse a DecimalRounded value instead of reading its
representation. Arithmetic is the binary64 operation on the
representations (`d64add` ... `d64neg`, which are `f64add` ... `f64neg`
with another result kind); the observations call exact helpers
(`rt_decimal_cmp`, `rt_decimal_to_f64`, `rt_decimal_round`, on
`num-bigint`).

**The representation of a constant** is chosen from its exact decimal alone
(`core::decimal::Represent`): among the binary64 nearest it and its two
neighbors, the one proven at the highest precision, then the nearest.
Usually that is the nearest binary64; for a decimal tie the nearest
binary64 rounds the wrong way (1.245, whose nearest binary64 is
1.24500000000000010658..., which rounds to 1.25), the neighbor
(1.2449999999999998845...) is chosen. The choice is a deterministic
function of the decimal, the same on every target, and invisible to the
program.

**Display.** A program's printed result (`main.tcl`'s `ShowResult`,
`hir::decimal::Display`; Compilerpedia's example check reads the same)
shows a DecimalRounded value as round(v, N) with exactly N places, N the
guarantee of its static type in the result (through Lists, structs and an
`if`): `{amount: 20.00, rate: 0.196}` for `19.995` at two places and
`0.1955` at three. Where the static type does not say N -- an element of a
List that also holds other kinds -- and in a standalone executable, whose
result printing is type-blind (`runtime/aot.rs`'s `show`), the value shows
`<DecimalRounded>`: a print that does not know the precision prints no
digits, so it can never expose digits beyond the guarantee (or the
ceiling).

## 14. Where Float64 is an implementation detail

Binary64 is used for: each value's representation; the arithmetic of
`+ - * /` and unary minus at run time; the proofs, which simulate exactly
that arithmetic; the representation chosen for a constant and for a
quantization. None of it is part of the type's meaning, and HIR,
interchange and the type system say nothing about it.

The audit the brief asks for -- every place where DecimalRounded semantics
might depend on Float64:

| place | status |
|---|---|
| HIR interchange stored each constant's `value`, its binary64 | **fixed**: `hir::interchange::encode` blanks a DecimalRounded constant's `value` and `decode` chooses it again from the exact decimal (`WithoutRepresentations`, `WithRepresentations`); the text holds `literal {DecimalRounded 0.295}` and the type, never 0.29500000000000004 (`dr-interchange`). HIR text never held it. |
| type-blind `==`, `hash` and display would read the representation | **fixed**: they refuse a DecimalRounded value (EQUALITY) or show no digits (section 10, 13) |
| the decay to Float64 could return the representation | **fixed by definition**: it returns the Float64 of round(v, N) |
| which constants are accepted depends on binary64 (0.1 is proven to 16 places, not 17; 1.0e23 to none) | **an implementation capacity, not a semantic dependence**: the guarantee means the same; whether *this* compiler can prove it with *its* representation decides acceptance -- the brief's "conservative proof failure is acceptable". It is the same on every target (section 16). A strategy with a wider representation would accept more, never fewer. |
| a decimal literal beyond binary64's range (1.0e309) is a syntax error "outside the range of Float64", even where a DecimalRounded type is expected | **capacity, documented**: the lowering still writes a Float64 constant first (section 6); no representation of this implementation holds such a value, so no program changes meaning. A non-binary64 strategy would move the range check after literal typing. |
| `NonFiniteFloat` is raised by a DecimalRounded operation whose binary64 result overflows (`1.0e300 * 1.0e300` is a finite decimal) | **capacity, documented; name kept**: the error is the implementation's (its payload's `NonFiniteResult` describes the binary64 result). A later representation without overflow at that magnitude would raise it at another magnitude or not at all; the name may then deserve a neutral spelling. Not renamed speculatively, as the brief asks. |
| `UnrepresentableDecimal` depends on which decimals binary64 resolves | **capacity, documented**: the quantization's contract is "the decimal, or this error" |
| the Tcl runtime bridges a native value as `{DecimalRounded X}`, X a Tcl double | representation only: it is the value's representation, never shown |

No dependence changes what an accepted program means, so none is a blocker.

## 15. Constant folding

A DecimalRounded constant's proof *is* its folding: the compiler computes,
exactly, the binary64 the run computes, and accepts the constant only at
the precision that value is proven to. A run then performs exactly those
operations on exactly those representations (the representations are
chosen from the decimals, the same in the front end and every backend), so
folding and running cannot differ: `dr-folding-parity` checks the
verifier's implementation value against every backend's computed bits, and
the fuzzer checks every accepted constant's run value on four backends.
Nothing evaluates with host floating point, and no constant gains a
guarantee its run does not have. The arithmetic natives keep Float64's
`-fold` rule: a constant whose binary64 computation is not finite is
decided while compiling, by the completion analysis, as KNOWN-ERROR
(NonFiniteFloat), which a handler does not excuse -- the existing Float64
rule, unchanged.

Inside a `static compile:` block a proof failure is a recoverable
diagnostic like any other: the block becomes `std::compiler::CompilerError` with
`DiagnosticCode::DecimalPrecision`, `DecimalGuaranteeLost` or
`RefinementParameter` (`dr-static-compile`; the golden suite's bodies).

## 16. Target independence

Nothing in the proofs, the representation choice, the rounding or the
observations reads the target: the exact arithmetic is integer arithmetic,
binary64 is the same IEEE 754 format on every target, and the native
helpers are portable Rust on `num-bigint`. `dr-target-independent` compiles
the same programs for linux-x86_64, linux-aarch64 and macos-aarch64 and
requires identical HIR (minus the target fields) and identical diagnostics;
the native arithmetic is the target's IEEE binary64 instruction set, which
rounds identically, and the observations' helpers are the same code. CI
runs the test file and the golden suite on Linux AArch64
(`tests-arm64.yml`) and macOS AArch64 (`macos-arm64.yml`'s acceptance
tier, which runs every test file not listed in `notYet`), beside Linux
x86-64.

## 17. Worked examples

Each output below is `tclsh9.0 main.tcl` on this tree (the same on every
backend).

**Preserved: constants proven where they stand.**

```botlish
fn tax_rate() -> DecimalRounded{minDecimalsPreserved: 2}:
    0.19

fn total() -> DecimalRounded{minDecimalsPreserved: 2}:
    19.99 + 5.01

fn ratio() -> DecimalRounded{minDecimalsPreserved: 16}:
    1.0 / 3.0

fn cents(x: DecimalRounded{minDecimalsPreserved: 2}) -> DecimalRounded{minDecimalsPreserved: 2}:
    x

{rate: tax_rate(), total: total(), ratio: ratio(), tie: cents(0.295), float_tie: 0.295}
```

    value: {float_tie: 0.295, rate: 0.19, ratio: 0.3333333333333333, tie: 0.30, total: 25.00}

`0.295` as an argument of `cents` is the decimal 0.295, 0.30 at two places;
the same literal in `float_tie` is a Float64.

**Lost: one place too many.**

```botlish
fn ratio() -> DecimalRounded{minDecimalsPreserved: 17}:
    1.0 / 3.0

ratio()
```

    error: e2.bot:2:5: this result is only proven correct to 16 decimal places,
    but the declared result of ratio requires DecimalRounded{minDecimalsPreserved: 17}
    (its exact value is 1/3 = 0.33333333333333333333...; its binary64 computation
    gives 0.3333333333333333148296162562473909929394..., which rounds to
    0.33333333333333331 at 17 places where the exact value rounds to
    0.33333333333333333) (CORE SEMANTIC DECIMAL-PRECISION)

**Preserved and lost: cancellation.** `0.1 * 3.0 - 0.3` is 5.55e-17 as a
Float64, and as `DecimalRounded{minDecimalsPreserved: 3}` it is 0.000, the
exact value's three-place decimal. Required to 16 places:

    error: e3.bot:5:5: this result is only proven correct to 15 decimal places,
    but the declared result of tiny16 requires DecimalRounded{minDecimalsPreserved: 16}
    (its exact value is 0.0; its binary64 computation gives
    5.5511151231257827021181583404541015625e-17, which rounds to
    0.0000000000000001 at 16 places where the exact value rounds to
    0.0000000000000000) (CORE SEMANTIC DECIMAL-PRECISION)

**Lost: magnitude.** `1.0e20 + 0.01` is proven to one place: required to
two it is DECIMAL-PRECISION ("only proven correct to 1 decimal place"),
declared to one it is `100000000000000000000.0`.

**Lost: arithmetic on parameters, and how to compute anyway.**

```botlish
fn add(a: DecimalRounded{minDecimalsPreserved: 2}, b: DecimalRounded{minDecimalsPreserved: 2}) -> DecimalRounded{minDecimalsPreserved: 2}:
    a + b
```

    error: e4.bot:2:5: no decimal place of this sum can be proved: its operands
    are DecimalRounded{minDecimalsPreserved: 2} and DecimalRounded{minDecimalsPreserved: 2},
    values known only to the precision their types guarantee, and rounding is
    discontinuous -- ... (CORE SEMANTIC DECIMAL-GUARANTEE-LOST)

The program says where the guarantee is given up and where it is
established again:

```botlish
import std::float64
import std::decimal_rounded

fn add(a: DecimalRounded{minDecimalsPreserved: 2}, b: DecimalRounded{minDecimalsPreserved: 2}) -> DecimalRounded{minDecimalsPreserved: 2} errors NonFiniteFloat, UnrepresentableDecimal:
    sum = std::float64::from_decimal_rounded(a) + std::float64::from_decimal_rounded(b)
    std::decimal_rounded::round[DecimalRounded{minDecimalsPreserved: 2}](sum)

fn safe(a: DecimalRounded{minDecimalsPreserved: 2}, b: DecimalRounded{minDecimalsPreserved: 2}) -> DecimalRounded{minDecimalsPreserved: 2}:
    a.add(b):
        on NonFiniteFloat:
            0.00
        on UnrepresentableDecimal:
            0.00

[safe(0.004, 0.004), safe(0.10, 0.20), safe(1.245, 0.001)]
```

    value: [0.00, 0.30, 1.24]

The first element shows what the decay means: each operand decays to its
two-place decimal (0.00), so the sum is the sum of the *guaranteed*
decimals, 0.00 -- not the 0.01 of the intended 0.004 + 0.004, which the
types never guaranteed.

**Observations at the guaranteed precision.** With `cheaper(a, b)` = `a <
b` on two-place values, `1.234.cheaper(1.235)` is true (1.23 < 1.24) and
`1.235.cheaper(1.244)` is false (both 1.24), and `1.235 == 1.244` between
two-place values is true. With a ceiling, `c(1.2344) == c(1.2301)` is true
for `c` of `{2, max 4}`: the values differ only beyond the guarantee.

**Lost: a ceiling dropped.**

```botlish
fn open(x: DecimalRounded{minDecimalsPreserved: 2}) -> int:
    1

fn capped(x: DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}) -> int:
    open(x)
```

    error: e6.bot:5:10: argument for parameter "x" cannot be proven to satisfy
    DecimalRounded{minDecimalsPreserved: 2} (argument type:
    DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}); observations
    of a value of DecimalRounded{minDecimalsPreserved: 2, maxDecimalsPreserved: 4}
    are limited to 4 decimal places (its maxDecimalsPreserved), and
    DecimalRounded{minDecimalsPreserved: 2} states no upper bound: an upper
    precision bound is never dropped or raised (CORE SEMANTIC TYPE)

**Non-finite versus imprecise.** `1.0e300 * 1.0e300` declared as
`DecimalRounded{minDecimalsPreserved: 0}` is KNOWN-ERROR (NonFiniteFloat:
the binary64 result overflows); `1.0 / (0.1 * 3.0 - 0.3)` is
DECIMAL-PRECISION ("divides by a value whose exact decimal value is
zero"), though its binary64 quotient, 1.8e16, is finite.

## 18. Diagnostics

| situation | kind | std::compiler::DiagnosticCode |
|---|---|---|
| malformed parameters, unknown parameter, out of range, `max < min`, a bare `DecimalRounded`, a family that has none (`Float64{...}`) | REFINEMENT-PARAMETER | RefinementParameter |
| a malformed field (no colon, a non-integer, a repeat, no separator) | syntax error | -- |
| a constant not proven to the required places; a division by an exactly zero decimal | DECIMAL-PRECISION | DecimalPrecision |
| arithmetic on values known only by their guarantee | DECIMAL-GUARANTEE-LOST | DecimalGuaranteeLost |
| a guarantee minted without proof, strengthened, a ceiling dropped or raised, Float64/DecimalRounded mixed (operators and arguments), an observation of a value of unknown precision, aggregate equality, a set of DecimalRounded values, `std::decimal_rounded::round` not imprinted with a refined type | TYPE | Type |
| the binary64 computation of a constant is not finite | KNOWN-ERROR | KnownError |
| type-blind `==` or `hash` of a DecimalRounded value at run time | EQUALITY (run time) | -- |
| a quantization no representation holds | `UnrepresentableDecimal` (declared builtin error, the tenth: its native id is BUILTIN_ERROR_ID_BASE + 9, after the binary errors, so existing ids are unchanged) | -- |

Each has a Compilerpedia topic: `concept.decimal-rounded`,
`error.refinement-parameter`, `error.decimal-precision`,
`error.decimal-guarantee-lost`, `stdlib.std::float64::from_decimal_rounded`,
`stdlib.std::decimal_rounded::round`, `stdlib.module.std::decimal_rounded`; the TYPE
and EQUALITY diagnostics that mention DecimalRounded point to the concept
page (its `match:` lines). `concept.floats`'s literal rule now names the
exception.

## 19. Tests, audits and CI

* **`tests/decimal-rounded.test`** (42 tests): parsing (both separators,
  every malformed field), parameter validation (ten combinations),
  canonical form and text, the schema's genericity, the implication matrix
  and joins, literal typing in every context, exact source intent, the
  one-place literal choice, unrepresentable precision, very small (5.0e-324
  at 324/325 places) and very large (1.0e22 exact, 1.0e23 and 1.0e300 not)
  constants, the rounding rule, the two-place boundaries 1.234..1.255
  (displayed and compared), weakening, refused strengthening (six forms),
  decay, quantization (and UnrepresentableDecimal), proven arithmetic of
  every operator, the run's representation, proof loss, opaque arithmetic,
  "not blind min", mixing, non-finite versus imprecise, comparisons,
  equality, refused equality (static and at run time) and sets, the upper
  bound (observations and types), display (structs, ifs, mixed Lists,
  type-blind), main.tcl's printing on every backend, folding parity,
  runtime parity over a walked List, static compile reification, HIR text,
  interchange, target independence, the NIR, and a standalone executable.
  Every value test runs on interp, compile, cranelift-generic and cranelift
  and requires them to agree on the display *and on every value's
  representation bit for bit* (`core::value::show`'s REVEAL).
* **`tests/golden/decimal-rounded.bot`** (37 golden tests, all four
  backends): the source-observable half of the Tcl tests, observed by
  comparisons at the guaranteed precision (a golden suite cannot import
  `float64`: `tests/golden/float64.bot` is an application module of that
  name beside it, MODULE-COLLISION). Its manifest rows are in
  `audit/golden/migration/fragments/decimal-rounded.tsv` and the Tcl tests'
  classification in `census/decimal-rounded.tsv`; `perturb.tcl` shows every
  golden test fails when inverted (37/37) and when altered (37/37).
* **`audit/decimal-rounded/tools/fuzz.tcl`**: random decimal constant
  expressions near rounding boundaries, at random precisions, on four
  backends, against an oracle independent of `core/decimal.tcl` (its own
  rationals, binary64 decoding and half-even rounding): every accepted
  constant's run value must round right at every place up to N and display
  its exact decimal; a DECIMAL-PRECISION claim must be self-consistent
  (accepted at the claimed places, its representation genuinely wrong one
  place further); a KNOWN-ERROR must overflow in Tcl's own binary64; a
  comparison of run-time values must decide by the two decimals. Seeds 1,
  2, 3, 5, 7, 9, 17, 41, 99 and 123 at 300 constants each (376 cases per
  seed; per seed 64% to 71% of the constants accepted, 28% to 35%
  DECIMAL-PRECISION, 1% to 2% KNOWN-ERROR): no disagreement.
* **`audit/decimal-rounded/tools/mutate.tcl`** with `mutants.txt`: 24
  mutants -- the rounding rule (Tcl and native), a proof claiming one place
  more, the representation always the nearest binary64, an unchecked
  quantization (Tcl and native), comparisons of representations (Tcl and
  native), comparisons at the finer precision, a decay returning the
  representation (Tcl and native), type-blind equality and hashing of
  representations, an extra displayed place, sets allowed, a droppable
  ceiling, an unchecked `max >= min`, an optional minimum, the blind-min
  rule, negation losing its guarantee, unreported mixing, handlers not
  typed, an unreported zero divisor and interchange keeping the
  representation. Detectors: the test file, the fuzzer, and for a native
  mutant a rebuild and `cargo test --lib decimal`. Result: see the end of
  this section.
* **Native**: `cargo test --release --lib decimal` (4 tests: the nearest
  binary64 of six decimals across binary64's range against Rust's own
  parser, ties, the representation of a tie, quantization).
* **The existing suites**: `tests/local.tcl` (200 Tcl test files on
  interp and compile, 98 golden suites on four backends: 6,278 and 6,273 Tcl
  tests, 4,882 / 4,882 / 4,790 / 4,892 golden tests) passes. The changes it
  required were inventories (`stdlib-namespaces.test`, `linux-syscall.test`'s
  value-family namespaces), the DiagnosticCode count (`golden-framework.test`,
  `framework-semantics.bot`, `static-compile.test`'s `sc-codes-one-to-one`)
  and the static-compile census. Also run, all passing: the decimal tests
  under `BOTLISH_NATIVE_GC_STRESS=1` and with the stub linker,
  `aot-stub-linker.test` and the `aotimage` Rust tests (the constants'
  heap kind), the interchange and cache tests and their roundtrip audits
  (the default suites and `decimal-rounded.bot`, 0 differences) and mutants
  (27/27 killed), `compilation-isolation.test`, the warning gate,
  `golden.test`, `method-eligible.test`, `diagnostic-recovery.test`, and the
  golden framework's mutants (20/20 killed, run with `-suites 0`: the
  framework test file and fuzzer as detectors) after the new
  `std::test::code_name` cases. `tools/compilerpedia.tcl check` passes.
* **CI** on the branch before it was merged with main (head `aad6a63`):
  `tests.yml` (the whole Tcl suite with duplicates on interp and compile,
  its native coverage, every golden suite beside its Tcl originals, the
  Rust tests, the stub-linked executables, the warning gate) passed;
  `macos-arm64.yml` (smoke and the acceptance tier, which includes
  `decimal-rounded.test` and `decimal-rounded.bot`) passed;
  `tests-arm64.yml` (the Tcl suite, native coverage, golden suites and Rust
  tests on Linux AArch64, also under GC stress) passed;
  `static-decisions.yml` (every golden suite under the batched and the
  sequential scheduler, on `099bf70`, the same front end) passed with no
  disagreement. The merge with main (the layout-unions milestone) changed
  only the DiagnosticCode counts and an inventory in three tests; the
  merged tree passes `tests/local.tcl` (201 Tcl test files, 0 failures on
  interp and compile; 99 golden suites on four backends, 0 failures).

Mutation result: 24 mutants, 24 killed, none survived. The test file kills
every one; the fuzzer independently kills the ones that change a
constant's accepted value or a comparison (round-half-up, proven-one-more,
compare-representation in both runtimes, display-extra-place, blind-min);
the Rust tests kill the native rounding, comparison and decay mutants. The
native unchecked quantization was caught only by the test file
(`dr-quantize`'s UnrepresentableDecimal case), so `decimal_quantize` now
also checks an unrepresentable quantization.

## 20. Conservative limitations

* Only decimal constant expressions are proven. Arithmetic on any other
  DecimalRounded value is rejected (section 9); a program decays, computes
  with Float64 and quantizes back, and says so.
* A literal is a DecimalRounded constant only in the typed contexts of
  section 6; there is no typed local binding, so a constant cannot be named
  except as a function's result.
* Display shows exactly the guaranteed places; there is no formatting
  operation (no DecimalRounded-to-String), and a standalone executable's
  type-blind result printing shows `<DecimalRounded>`. (Since
  NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md, `std::decimal_rounded::to_string(x)`
  is that display as an ordinary String, at the precision of x's static
  type; caller-chosen precisions and formatting remain absent.)
* Equality is the precision-aware comparison only; aggregates of
  DecimalRounded values cannot be compared, hashed or put in a set.
* The representation strategy is binary64 for every value; acceptance is
  bounded by what binary64 holds (section 14).
* There is no C FFI for DecimalRounded (the next milestone): a C `double`
  is a Float64, and a DecimalRounded value reaches C only through the
  explicit decay, so it is not ABI-compatible by definition.

## 21. Seams for later work

* **Proving more.** The proof attachment point is the expected type of a
  constant expression's root; a later analysis that knows more about a
  non-constant operand (a magnitude refinement, `ExactDecimal`'s exact
  scale, a Range of decimals) can give `hir::decimal::Facts` an enclosure
  instead of a point and accept arithmetic it proves, without changing the
  type or the observation rule. Exact decimals compose where rounded ones do
  not: `ExactDecimal{minScale: 2, maxMagnitude: 40000}`'s sums are exact,
  and its decay to DecimalRounded is a proof, not a quantization.
* **Further refinement families** are schema rows (section 7): `List[T]{
  length: 4}` (order `exactly`; landed, LIST-CARDINALITY-REFINEMENTS.md,
  which also added applied bases and a family's `interface`), magnitude
  bounds (`atMost`). The parser's `NAME{...}` form, validation, canonical
  form, implication, joins, text and interchange are already generic.
* **Choosing a representation.** Because only the guarantee is semantic,
  the compiler may later ask, per expression, *what is the cheapest
  implementation that proves the requested contract*: Float32 where the
  places and magnitudes fit; fixed point or integer-scaled arithmetic where
  a scale is known (cents in an Int); wider intermediates where binary64
  falls short (accepting constants this milestone rejects); SIMD and
  reassociation or fused operations wherever the proof still holds after
  the change (the proof simulates the chosen operations, so it validates
  each rewrite); relaxed arithmetic whose error bound fits inside the cell.
  The places to change are the representation choice
  (`core::decimal::Represent`), the simulated operations
  (`ExactOperation`) and native lowering's d64 operations; HIR,
  interchange and the observations do not change. There is no global
  fast-math flag, by design.
* **FFI.** A later conversion to `std::ffi::c::Double` can be the explicit decay
  (forget the guarantee) or a proof that a value's representation is the C
  value wanted; DecimalRounded never becomes a C type itself.

## 22. What to run when changing this

If you change the refinement grammar, `hir/refinements.tcl`,
`hir/decimal.tcl`, `core/decimal.tcl`, the `srefined` cases of
`hir/types.tcl`, the DecimalRounded cases of `hir/range.tcl`,
`hir/operators.tcl`, `hir/interchange.tcl`, `core/value.tcl`,
`core/hashing.tcl`, `main.tcl`'s display, native lowering's d64 operations
or `native/src/runtime/decimal.rs` (or the value-kind code in
`value.rs`/`ops.rs`/`show.rs`): run `tests/decimal-rounded.test`,
`tclsh9.0 tests/local.tcl tests/golden/decimal-rounded.bot`,
`audit/decimal-rounded/tools/fuzz.tcl` (several seeds),
`audit/decimal-rounded/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule) and `cargo test
--release --manifest-path native/Cargo.toml --lib decimal`; for a change to
interchange, also the HIR-interchange audits (AGENTS.md).
