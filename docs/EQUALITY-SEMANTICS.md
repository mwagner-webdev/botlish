# EQUALITY-SEMANTICS.md

> Partially superseded by the semantic census,
> [EQUALITY-SEMANTIC-CENSUS.md](../audit/equality-semantics/EQUALITY-SEMANTIC-CENSUS.md).
> Its comparability relation also rejects applications that differ only in
> type arguments (a slot no field names lets their values be equal) and
> disjoint integer domains (a fact about values, not a different kind); the
> census recommends structural comparability. Its Level 1 check in semantic
> instances would make validity depend on instance budgets; the census
> recommends the generic HIR only. Its Level 2 contracts would have to be
> kind-level CHECKED requirements, which callable conversion erases. The
> census's section 12 is the revised first milestone.

How Botlish's `==` treats operands of unrelated types, why that makes the
`ONE-CHAR-STRING-LITERAL` warning's advice unsafe at comparisons, and a
checked model of equality on the pattern of integer-domain admission. An
analysis and a proposal: nothing here changes the compiler. The evidence is
`audit/equality-semantics/`: the census tool, its output, and the probe
programs with a runner.

## Outcome

* **`==` has no static rule.** Every pair of operands is accepted, and the
  answer is decided at run time by `core::value::equal`'s first rule:
  "values of different kinds are never equal". `'-' == "-"`, `1 == 1.0`,
  `Color::Red == Light::Red` and `P {x: 1} == Q {x: 1}` all compile and are
  `false`. A comparison with a callable compiles too, and fails at run time
  with `EQUALITY`. The checker knows both operands' types, and for literals
  their exact values, yet decides none of these.
* **That is what makes the warning's advice unsafe.** The warning says "a
  single character is written as a character literal". Where the literal is
  compared with a `str`, following it turns a working comparison into one
  that is always false, with no diagnostic. The warning's own milestone
  measured this: 22 of the corpus's rewrites changed a program's result,
  and 8 made a scanner loop forever (WARNINGS-ONE-CHAR-STRING-LITERAL.md,
  "Corpus findings"). The warning is right about the literal. The fault is
  in `==`, which turns a type error into a silent `false`. The warning's
  rules forbid a context gate and a fixit (AGENTS.md), and they should: no
  warning can fix this from the literal's side.
* **The rest of the language is already strict about the same question.**
  - An integer domain admits a value only with a proof. An unproven value
    is a static `TYPE` error at the site, or at the call that creates the
    obligation, never a run-time check.
  - `MutableSet[str].contains('-')` is a static `TYPE` error. The same
    question asked of an `ImmutableSet` or with `==` is a silent `false`.
  - `hash` already has a checked admission: a statically unhashable argument
    is `TRAIT-NOT-SATISFIED`, a Hashable one lowers to the total operation.
    Equality computes the same classification (`hir::types::Totality`) and
    uses it only to choose an operation, never to reject one.
  - Semantic instances already report "this function is invalid for this
    call" at the call that needs the instance.
* **The census** (`audit/equality-semantics/tools/census.tcl`) classifies
  every `==` and `!=` of the corpus by its operands' static types. Of 1,993
  sites, 1,506 compare compatible types and 441 have an operand of unknown
  kind. 44 are statically disjoint (always `false`), 2 compare Lists or
  sets whose elements share no value (equal only when both are empty), and
  4 more are disjoint in a semantic instance. 49 of those 50 are in test
  suites that pin today's semantics, and the last is an example that
  demonstrates it. The standard
  library (334 sites) and the benchmarks have none. A static rule therefore
  costs the corpus nothing outside the tests of the rule it replaces.
* **Recommendation: a checked equality.** Level 1 now; Level 2 as a
  decision of its own, because it reverses one already recorded. Both are
  static, and neither adds a run-time check:
  1. **Comparability.** `==` and `!=` are admitted when the operands' static
     types are comparable, and rejected statically when they are disjoint
     (different kinds, different declarations or shapes, element types that
     share no value) or refused (no equality: a callable, a MutableArray, a
     C pointer). The check runs on every definition and on every semantic
     instance, reported at the call that needs the instance. An operand of
     unknown kind (`any`) passes and keeps today's run-time semantics.
  2. **Equality in contract inference.** A comparison of an untyped
     parameter with an operand of known kind gives the parameter that kind's
     contract (`c == '-'` makes `c` a `UnicodeChar` parameter), as a call of
     `f(x: Small)` makes an untyped `n` an `int[Small]` parameter today. A
     caller passing a String is then rejected at its call, with the chain.
     The contract-inference milestone decided the opposite on purpose
     (`ic-unconstrained-stays-any`: "equality and set membership impose no
     concrete type"), so Level 2 needs that decision revisited, not just
     an implementation.

  Level 1 meets the `==` half of the warning's second autofix-graduation
  criterion: "a static rejection of `==` between a String and a
  UnicodeChar, so a comparison rewrite can never be silently wrong". A
  third level, which rejects comparisons with operands of unknown kind
  unless a kind test admits them, is the full analogue of integer domains.
  The census measures its cost, and this report recommends against it
  ("Level 3", below): the test framework's universal `std::test::equal`
  depends on comparing values of unknown kind.

## The trigger: a one-character literal at a comparison

```botlish
fn hyphen?(c: str) -> bool:
    c == "-"              # warning: ONE-CHAR-STRING-LITERAL
```

The warning reports `"-"` and states the idiom: a single character is
written as a character literal (docs/README.md, "Strings and characters").
Followed here, it gives

```botlish
fn hyphen?(c: str) -> bool:
    c == '-'              # no diagnostic; always false
```

The value is unchanged ('-' denotes the same character), and the program is
broken. The warning milestone named the three outcomes of such a rewrite:

* a declared `str` parameter rejects it statically;
* a native's `str` parameter accepts it and fails at run time;
* a comparison accepts it and is silently `false`.

The first is a type error, the second a run-time type error. The third is
the only silent one, and it is the common case: 56 of the 97 findings the
warning first reported were comparisons. The milestone made the warning
context-blind and not autofixable because of it, and recorded the open
question: "`==` of a String and a UnicodeChar type-checks and is always
`false`: a language-design question about kind-mismatched equality, not a
warning candidate".

The same hazard came up while landing UNICODECHAR-CLASSIFIERS.md:

* **In `emailish?`.** `label_char?(c)` was `std::str::is_tcl_alnum(c) or c ==
  "-"`. Respelling `"-"` as `'-'` was correct only because the same change
  made `c` a `UnicodeChar`. Respelling it alone would have made every
  hyphenated domain invalid, with no diagnostic.
* **In a public binding.** `std::web::local_extra_chars` changed from a set
  of Strings to a set of characters. A program outside `std::web` that asked
  `local_extra_chars.contains("-")` would get `false` from then on, also with
  no diagnostic. None exists in the repository, which is the only reason the
  change was safe.

In both cases the program the warning steers toward is right, and the
compiler cannot tell it from the broken one. Making the respelling either
keep its meaning or fail to compile is the language's job, not the
warning's.

## What `==` is today

**Surface.** `a == b` is a call of the root native `==`; `a != b` lowers to
`if a == b: false else: true` (surface/lower.tcl). A DecimalRounded operand
selects DecimalRounded's own `==` (hir/decimal.tcl). For every other kind,
Float64 included, `==` is the one equality (hir/operators.tcl leaves it as
it is).

**Registration** (core/primitives.tcl): `-param-types {any any} -result-type
bool -runtime structural-equality -context-free 1 -ownership {equality
equality}`. Both parameters are `any`: no operand is ever rejected, and the
call adds nothing to an untyped parameter's inferred contract.

**Semantics** (`core::value::equal`, mirrored by native/src/runtime/ops.rs):

* Callables, MutableArrays, MutableVectors, coroutine handles and C
  addresses have no equality: comparing one raises `EQUALITY`.
* A DecimalRounded operand of the type-blind `==` raises `EQUALITY`. Two
  statically DecimalRounded operands use the precise `DecimalRounded#==` at
  their types' precision.
* Otherwise, **values of different kinds are never equal**.
* Within a kind:
  - Ints, Strings, Bools and characters compare by value, and Float64s
    numerically.
  - Enums compare by declaration and case, and named structs by declaration
    then fields. Anonymous structs compare by field set then fields.
  - Lists compare element by element, sets as sets, Results by tag and
    payload.

**Static treatment.**

* The checker's exact values do not decide `==`. `"-" == '-'`, with both
  exact values known, has no `known` outcome.
* `hir::types::Totality` classifies each operand's type for equality:
  - `total` means equality never raises;
  - `none` means it always raises (a callable);
  - `unknown` means no runtime kind is fixed.

  Native lowering reads the classes to choose an operation, never to reject
  one:
  - two Ints become `ieq`, two Strings `streq`, two characters `chareq`, two
    enums `enumeq`, two Float64s `f64eq`;
  - two total types of any other pairing become `veqtotal`;
  - everything else becomes `veq`.

  So `c == '-'` with `c: str` is `veqtotal`, a helper call that answers
  `false`.

**Collections.**

* `std::immutable_set::contains` and `from_list` use the same type-blind
  equality (`setcontains`, `setcontainstotal`). An `ImmutableSet[str]` asked
  about `'-'` answers `false`.
* `MutableSet[T]` and `MutableMap[K, V]` declare their key parameter as `T`
  or `K`, so a needle of another type is a static `TYPE` error.

**The probes.** Each is a program in `audit/equality-semantics/probes/`.
`tclsh9.0 audit/equality-semantics/tools/probes.tcl` runs them on interp and
cranelift, which agree on every one:

| probe | the comparison | today |
|---|---|---|
| kinds-disjoint | `c == '-'` with `c: str`; `"-" == '-'`; `1 == "1"`; `1 == 1.0`; `[1] == ["1"]` | all `false`, no diagnostic |
| nominal-and-shape | two enums' `Red`; `P {x: 1} == Q {x: 1}`; a named and an anonymous struct; `["a"] == ['a']`; `{x: 1} == {y: 1}` | all `false`; `[] == []` is `true` |
| immutable-set-needle | an `ImmutableSet` of Strings asked about `'-'` | `false` |
| mutable-set-needle | a `MutableSet[str]` asked about `'-'` | static `TYPE`: "cannot be proven to satisfy str (argument type: UnicodeChar)" |
| callables | two functions | compiles (`-check`: ok); `EQUALITY` at run time |
| untyped-parameter | `fn hyphen?(c): c == '-'` called with `"-"` | `false` |
| contract-then-comparison | `fn f(c)` whose body passes `c` to `std::str::length` (so its inferred contract is `str`) and compares it with `'-'` | `false`: a comparison of a `str` parameter with a character, in the definition itself |
| kind-test-narrows | `if string?(c): c == "-"` | `[true, false]`: the kind test narrows `c` to `str` |
| generic-instance | `fn same?(a, b): a == b` called with `("-", '-')` | `false` |
| mixed-kinds-set | an `ImmutableSet` of `1`, `"1"`, `'1'` | membership by kind: `1.0` is not in it |
| domain-constant-outside | `x == 12` with `x: Small` (`Int in 0..9`) | `false`, no diagnostic |

## Integer domains: the model to follow

An integer domain (`type Small = Int in 0..9`; SOURCE-DEFINED-INTEGER-
DOMAINS.md) admits a value only with a proof, and no run-time check is ever
inserted. The probes show the whole model:

* **domain-literal-outside.** `f(12)` with `f(x: Small)` is rejected
  statically: "argument for parameter "x" cannot be proven to satisfy
  int[Small] (argument type: int, facts: [12, 12] {12})".
* **domain-unproven-int.** An Int read from a List is rejected: its facts are
  `[-∞, +∞]`. Nothing is assumed and nothing is checked at run time.
* **domain-admitted-by-comparison.** `if n >= 0 and n <= 9: f(n)` is
  admitted: the comparisons are the proof (`hir::range::Paths`).
* **domain-untyped-forwarder.** `fn g(n): f(n)` has no declared type. The
  body gives `n` an inferred contract, `int[Small]`, so `g(3)` is admitted
  and `g(12)` is rejected *at the call*, with the chain: "the parameter type
  inferred from the function body ... argument 1 of f (declared int[Small])
  requires int[Small] (at 6:7)".

Equality is the opposite case. The compiler has the facts that would decide
a comparison, and admits it anyway. An integer-domain rule asks "can this
value be outside?", and on "maybe" it rejects. Equality never asks "can
these two values be equal?", so on "never" it answers `false` at run time.

Two mechanisms the model needs already exist.

* **Checked admission (`hash`; HASHABLE-AND-KEYED-HASH.md).** The public
  `hash` is registered `-hashing {0 checked}`:
  - a statically unhashable argument is `TRAIT-NOT-SATISFIED`;
  - a Hashable one lowers to the total `hashtotal`;
  - an argument of unknown type is hashed dynamically.

  That is Level 1's refused case, already built for the sibling operation
  over the same `Totality` walk.
* **Instance validity (hir/semantic.tcl, "Validity").** Every semantic
  instance is verified with its concrete types, and a diagnostic there is
  reported at the call that needed the instance. The function is not
  rejected, and other calls are unaffected. A comparability check placed
  in that verification (beside `hir::range::verifyBlocks`) covers generic
  code at no extra cost: `same?("-", '-')` would be an invalid instance,
  reported at its call.

## The census

`tclsh9.0 audit/equality-semantics/tools/census.tcl -sites FILE` compiles
every program of examples/, bench/ and tests/golden/, and a loader of every
standard-library module. Each comparison site is visited once, in the
generic HIR (a library module's sites are counted once, however many
programs load it). Classes:

* **refused**: an operand has no equality;
* **unknown**: an operand fixes no runtime kind;
* **disjoint-kind**: two fixed, different kinds;
* **disjoint-nominal**: one kind, different declarations or shapes;
* **disjoint-domain**: integer domains that do not meet, or a constant
  outside the other operand's domain;
* **empty-only**: Lists or sets whose elements share no value;
* **compatible**: the types share a value.

| class | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| refused | 0 | 0 | 0 | 0 | 0 |
| unknown | 6 | 43 | 3 | 389 | 441 |
| disjoint-kind | 0 | 0 | 0 | 23 | 23 |
| disjoint-nominal | 0 | 1 | 0 | 20 | 21 |
| disjoint-domain | 0 | 0 | 0 | 0 | 0 |
| empty-only | 0 | 0 | 0 | 2 | 2 |
| compatible | 328 | 256 | 3 | 919 | 1506 |
| total | 334 | 300 | 6 | 1353 | 1993 |

`instance-disjoint` counts the sites that are not disjoint in the generic
HIR but are disjoint in some semantic instance the compilation used:

| | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| instance-disjoint | 0 | 0 | 0 | 4 | 4 |

**No disjoint comparison outside the tests.** No site in the standard
library or the benchmarks compares disjoint or refused types, in the generic
HIR or in any instance. The examples have one, `examples/surface/15-enums.bot`'s
`same(Light::Red) == same(Signal::Red)`, which demonstrates that two enums'
same-named cases are different values.

**The 43 disjoint golden sites test today's semantics.** All of them pin
`false`:

* kinds:
  - float64.bot's `1.0 == 1` and `0.0 == 0`;
  - core-semantics.bot's `1 == "1"`;
  - strings.bot's `'A' == 65` and `'A' == "A"`;
  - lists-and-sets.bot's `'-' == 45`;
  - stdlib-namespaces.bot's String against Int;
  - abi-bytes.bot's Bytes against a List, a String and an Int;
  - an ABI register word or an anonymous struct against an Int, a struct
    against a List;
* declarations:
  - two enums' `Car` (collections.bot, structs-and-enums.bot), two enums'
    `Red` (values.bot);
  - `I64` against `Isize` and `U64` against `Usize` (abi-numeric.bot);
  - two layouts' structs (binary-layout.bot), an opaque `Bytes` against a
    look-alike (opaque.bot), `Person` against `Account`;
* shapes: anonymous structs with different fields, a named against an
  anonymous struct (structs-and-enums.bot);
* the warning's own hazard: warning-programs.bot's
  `oc-comparison-with-a-string-warns/char` pins that `text == '"'`, with
  `text: str`, is `false` for `"\""`. That is the respelling's silent
  change, kept as a test.

The two **empty-only** sites are tests too: an `ImmutableSet[UnicodeChar]`
against an `ImmutableSet[int]` (lists-and-sets.bot), and `List[int]` against
`List[str]` (native-values.bot).

**The 4 instance-disjoint sites are tests of kind tolerance:**

* core-semantics.bot's `register_equality(name, left: any, right: any,
  expected)`, a harness for `==` of every pair of kinds;
* range-and-contract-values.bot's `ic-unconstrained-stays-any`, which pins
  that `eq_x?(c): c == "x"` accepts `eq_x?(1)`;
* warning-programs.bot's `oc-character-accepting-context-warns`, two
  sites: `is_comma(c): c == ',' or c == ","`, called with `","` and with
  `','`, deliberately kind-tolerant.

All four would be Level 1 rejections, at the call that needs the instance.
The first has declared `any` parameters, and an instance sees through a
declared `any` today, as every instance check does. Exempting an operand
*declared* `any` is a possible refinement of Level 1. The census shows
nothing outside the tests that would need it.

**Unknown sites.** 441 sites (22%) have an operand of unknown kind, 389 of
them in golden suites, most of those registration helpers' untyped
parameters. By what Level 2 would do with them:

| unknown operand | stdlib | examples | bench | golden | all |
|---|---:|---:|---:|---:|---:|
| untyped-parameter | 2 | 14 | 3 | 342 | 361 |
| both-unknown | 2 | 8 | 0 | 24 | 34 |
| computed | 2 | 21 | 0 | 23 | 46 |

Outside the golden suites, 19 sites compare an untyped parameter with an
operand of known kind:

* `bench/source-checks.bot`'s `is_underscore?(c): c == "_"`;
* `examples/stdlib/ai_text_clean.bot`'s emoji tests;
* `stdlib/web.bot`'s `char_is?(i, c)` and `domain?(start)`'s `j == start`;
* `bench/sum-refined.bot`, `matmul.bot` and `string_reverse.bot` (Ints).

Level 2 would type each parameter. No instance of any of them is disjoint,
so on today's corpus Level 2 rejects nothing outside the tests.

The other 33 sites outside the tests stay unknown under Level 2:

* `std::test::equal(expected, actual)`, which is `actual == expected` of two
  values of any kind;
* `std::test::describe`, whose `v == true` is a kind test by equality: there
  is no `bool?`;
* the MutableArray tables of `examples/stdlib/csv_records.bot` and
  `hashtable.bot`;
* `matmul.bot`'s List elements;
* `std::ordered_table`'s `key_at(e) == key`, whose operands are the
  constrained imprint variable `K` on both sides: comparable by
  construction, but unknown to a kind-only relation.

**Coverage.** 27 compilations fail, and the census skips them:

* entries that need staging: bench.tcl's experimental programs, Icy Tower's
  SDL binding, the C binding generator's demos, the event loop's Linux
  package;
* entries for another platform, compiled here for the host;
* modules that are not programs on their own: a `main` that requires a
  context, the DFA lexers;
* the two examples rejected on purpose (09, 10);
* the loaders of two internal namespaces, whose modules other loaders reach.

`census.txt` lists them. Every standard-library module is covered.

## Other languages

* **Strict static equality.** Go, Swift, Rust, Haskell and Kotlin reject `==`
  between unrelated static types:
  - Go: "mismatched types";
  - Swift: no `==` for `String` and `Character`;
  - Rust: no `PartialEq<char> for String`;
  - Haskell: `Eq a => a -> a -> Bool`;
  - Kotlin: `EQUALITY_NOT_APPLICABLE` for incompatible types.

  Java rejects `==` between incomparable reference types, but its `equals`
  is type-blind. That is a known source of bugs, which static analyzers
  flag.
* **Universal equality.** Scala 2 kept universal equality and warns that a
  comparison of unrelated types "will always yield false". Scala 3 made
  strict equality opt-in (`CanEqual`).
* **Botlish today** is Python at the static level: any two values compare,
  and kind decides. At run time it is OCaml, whose polymorphic equality
  raises on functional values, as `EQUALITY` does.
* **Dynamic values.** Go compares two interface values of different dynamic
  types as `false`, but rejects the static types that can never be equal.
  This report recommends the same split for Botlish: static rejection where
  types are known, today's semantics where they are not.

## A checked equality

### Comparability

Two static types A and B are **comparable** when some value of A can equal
some value of B under `==`. Every relation below is between static types,
computed from the checker's types alone (the census tool implements this
relation):

* **refused**: either type's equality totality is `none`;
* **unknown**: either type fixes no runtime kind;
* **disjoint** when any of these holds, else **comparable**:
  - the kinds differ;
  - the kind is the same and the declarations differ: enums, named structs,
    or a named and an anonymous struct;
  - anonymous structs differ in field sets;
  - a field pair is disjoint;
  - the type arguments of two applications are disjoint;
  - List or set element types are disjoint (**empty-only**: only `[] == []`
    can hold). The rule rejects this case too. `std::list::length(xs) == 0`
    states an emptiness test.

Comparability is an intrinsic relation, like Hashable's witnesses. No user
declaration makes two types comparable, and nothing adds an `Equatable`, a
derive or user-defined equality (HASHABLE-AND-KEYED-HASH.md forbids all
three).

Integer domains and refinements stay comparable with their carrier and with
each other: `Small` and `Byte` share values. A comparison that range facts
decide (`x == 12` with `x: Small`) is a value-level fact, and is out of
scope here. Rejecting decided comparisons would also reject guards that
restate a proof, which the language uses on purpose (the decided re-check
of a refinement predicate; M6-RANGE-DECIDED-BRANCH-LOWERING.md lowers them
to their branch).

### Level 1: reject disjoint and refused comparisons

`==` (and therefore `!=`) and `std::immutable_set::contains` (its needle
against the set's element type) are checked where they are written.
`std::immutable_set::from_list` compares a List's elements with each other,
and they have one static element type, so it has nothing to check. The
check runs on the generic body and on every semantic instance:

* **disjoint**: a new error kind, `EQUALITY-NEVER`, reported at the
  comparison: "== of str and UnicodeChar is always false: no String is a
  UnicodeChar". In an instance it is reported at the call that needs the
  instance, with the instance chain, as instance diagnostics are today.
* **refused**: a second kind, `EQUALITY-UNDEFINED`, or the existing
  `TRAIT-NOT-SATISFIED` with the wording `hash`'s checked admission prints. It
  replaces today's run-time `EQUALITY` wherever the static type proves it.
* **unknown** and **comparable**: admitted as today. Their run-time
  semantics is unchanged, and so is native lowering (`veqtotal`, `veq` and
  the per-kind operations).

What this gives:

* **The warning's respelling at a comparison becomes total.** With an
  operand of fixed kind `str` or `UnicodeChar`, exactly one spelling of a
  one-character literal compiles, and it is the one whose comparison can be
  true. Today both compile, and the wrong one is silently false.
* **No valid program changes meaning.** Every rejected comparison had a
  constant result (`false`, or `EQUALITY`). A program that relied on the
  constant writes it.
* **Diagnostics, never a run-time check.** As with domains, nothing is
  inserted into generated code.

### Level 2: equality in contract inference

`fn hyphen?(c): c == '-'` passes Level 1's check of its definition,
because `c` is `any` in the generic body. The untyped-parameter probe calls
it with `"-"` and gets `false`. Level 1 rejects that call only through the
semantic instance `hyphen?` for `str`. Instances are opportunistic: they are
made only for a call whose target block is statically known, and only
within budgets (16 per block, 2,000 in all, a nesting limit;
hir/semantic.tcl). A call through a callable value, or past a budget, makes
none. Whether a program is rejected must not depend on budgets.

The integer-domain answer is contract inference. A body that passes an
untyped parameter to `f(x: Small)` gives it the contract `int[Small]`
(INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md). In the same way, a comparison
whose other operand has a fixed comparable kind gives the parameter that
kind as its contract:

| comparison in the body | inferred contract of `c` |
|---|---|
| `c == '-'` | `UnicodeChar` |
| `c == "-"` | `str` |
| `c == Color::Red` | `Color` |
| `c == [1, 2]` | `List[int]` |
| `c == d`, both untyped | none (relational: checked per instance, Level 1) |

The inferred contract is a CHECKED requirement in hir/signatures.tcl's
terms, the class a native's `-param-types` give a wrapper
(INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md, "Trusted and checked"), not a
TRUSTED one. The body is not seeded with it, because it compiles without it:
`==` takes any value. A caller whose argument has a known type that is not
admissible is rejected at compile time, the way domain-untyped-forwarder's
`g(12)` is. A caller whose argument is `any` is accepted, with today's
run-time semantics.

Two consequences follow from the existing rules of contract inference:

* **It reverses a recorded decision.** The contract-inference milestone
  made equality and set membership impose nothing ("the 44 unconstrained
  parameters are values only compared with `==`, tested for set membership,
  stored, or returned"), and pinned it: `ic-unconstrained-stays-any`
  (intrinsic-contracts.test and its golden port) requires `eq_x?(c): c ==
  "x"` to accept `eq_x?(1)`. Under Level 2 that call is a static `TYPE`
  error. Revisiting the decision is the language's call, which is why this
  report separates Level 2 from Level 1.
* **Kind tolerance needs a kind test.** Two comparisons that give one
  parameter two kinds have no meet, and contract inference reports that as
  a conflict ("cannot infer a sound type for parameter ...";
  INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md, Q6). warning-programs.bot's
  `is_comma(c): c == ',' or c == ","` is such a function. Written with a
  kind test (`if string?(c): c == "," else: c == ','`), it keeps its
  meaning, because a use under a test of the parameter constrains nothing.

Level 2 changes what an existing cross-function fact holds, the inferred
parameter contracts, so their consumers must be re-checked:

* **Method selection.** The kind proofs read a module function's declared,
  trusted-inferred and checked-inferred first-parameter contracts
  (`hir::methods::ParamKinds`; METHOD-DECISION-FILTER.md). A candidate whose
  body compares its receiver with a character becomes inapplicable to a
  String receiver. That is applicability, which SFIAE allows: an
  argument's admission by "the declared and inferred parameter contracts"
  is one of its applicability rules. It still moves decisions, so the
  method-resolution and method-filter harnesses, including the reference
  audit, must accept it.
* **Static decisions.** A contract is a cross-function fact: the
  static-decision harnesses and the batched-against-sequential comparison
  (CI's `static-decisions` workflow) must agree.
* **Not affected.** `MANY-BOOLEAN-ARGUMENTS` reads only trusted contracts
  (AGENTS.md: "never a CHECKED one"), and a structural `Fn` type never holds
  a checked requirement.

### Level 3: proof for unknown operands

The full analogue of an integer domain also rejects an operand of unknown
kind unless something admits it:

* a contract (Level 2);
* a kind test (`string?(x)`, `integer?(x)`, `list?(x)`), which narrows an
  operand the way `n >= 0 and n <= 9` admits an Int (the probe
  kind-test-narrows: `if string?(c): c == "-"` already narrows `c` to `str`
  today);
* a declared type.

Under Level 3 every comparison that compiles has comparable operands, so the
run-time kind mismatch, and `veq`'s kind dispatch with it, could only be
reached by a compiler bug. "Values of different kinds are never equal"
would become "values of different kinds are never compared".

**What Level 3 costs.** Level 3 rejects every comparison an operand of
unknown kind reaches, unless something admits that operand:

* **The corpus.** It would reject 33 sites outside the tests and 47 inside
  them: the 24 golden `both-unknown` and 23 `computed` ones.
* **The test framework.** It has no way through: `std::test::equal`
  compares an expectation and an actual value whose kinds the framework
  cannot know, by design (GOLDEN-TEST-FRAMEWORK.md). Admitting it would need
  generics or an `Equatable`, both of which the language rules out.
* **Imprint variables.** Comparing `K` with `K`, the same imprint variable,
  would need comparability to be relational over imprints, beyond kinds.

Level 3 is the right end state only if the language gains a way to say "a
value of one comparable type" without naming the type.

### What changes, and what to run

Level 1 adds:

* two diagnostic kinds, each with a `std::compiler::DiagnosticCode` case
  and a census row (tests/static-compile.test, `sc-census-exhaustive`);
* Compilerpedia topics with rejected examples (`tools/compilerpedia.tcl
  check`);
* a check in `hir::range::verifyBlocks`, or beside it, which semantic
  instances already run, and a `-equality checked` registration role read
  by registration, never by a native's name. The role is like `-hashing`,
  for `==` and `std::immutable_set::contains`.

Tests and documents to update:

* The tests that pin a constant cross-kind result become rejection tests:
  the 45 golden sites above and the 4 instance-disjoint ones, their Tcl
  originals, and `examples/surface/15-enums.bot`'s demonstration.
* The language reference's "Values of different kinds are never equal
  (`1.0 == 1` is false)" becomes "Values of different kinds are never
  compared (`1.0 == 1` is rejected)".

The rest is what AGENTS.md lists for a new diagnostic, a front-end check and
compilation isolation (none: the check reads the HIR's own types). The
warning gate's corpus must stay clean; the census's corpus columns show
what it would reject.

The ONE-CHAR-STRING-LITERAL warning does not change. It stays
context-blind, with no fixit and no opt-out. After Level 1 its advice can
no longer silently break a comparison, and its milestone's second
graduation criterion is half met. The other half is an explicit
character-to-String conversion, which `std::str::append_char("", c)`
already provides.

## Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 audit/equality-semantics/tools/probes.tcl
tclsh9.0 audit/equality-semantics/tools/census.tcl -sites /tmp/equality-sites.tsv
```

The census takes about 35 minutes on the 4-core container: it compiles
237 programs and loaders, each from scratch (pass `-cache DIR` to keep their
HIRs for a second run against the same front end).
