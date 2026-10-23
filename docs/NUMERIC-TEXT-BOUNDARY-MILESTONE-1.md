# NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md -- numbers to and from text

Status: implemented (completion report). The first coherent numeric/text
conversion surface of the standard library, application-driven: the Icy
Tower vertical slice (ICY-TOWER-VERTICAL-SLICE-1.md, "What was missed and
not added") wrote its own Int to String, String to Int, Float64 rounding and
DecimalRounded display, and the test framework and the 2048 demo had written
the first two copies of Int to String before it. This milestone adds four
operations, each an explicit standard-library call with one rule, and
replaces the workload's and the framework's hand-written routines with them.

It is not a formatting framework: no format strings, interpolation, locale,
digit grouping, bases, Float64 text, caller-chosen DecimalRounded precision,
DecimalRounded parsing or implicit coercion.

The code: `core/inttext.tcl` (Int text both ways, `InvalidIntegerText`),
`core/float.tcl` (`round`), `core/decimal.tcl` (`decimal_rounded#to_string`),
`hir/decimal.tcl` (the precision elaboration and the static check),
`native/src/runtime/inttext.rs`, `native/src/runtime/decimal.rs`
(`text_at`, `round_at_small`), `native/src/runtime/ops.rs` (`rt_f64_round`,
`with_int_text`), the NIR ops `inttostr`, `strtoint`, `f64round` and
`d64tostr` (`native/src/nir.rs`, `native/src/codegen/clif.rs`,
`native/lower.tcl`).

## 1. The public API

```
import std::int
import std::float64
import std::decimal_rounded

std::int::to_string(n)            int -> str                 n.to_string()
std::int::from_string(s)          str -> int, errors InvalidIntegerText   (nomethod)
std::float64::round(x)            Float64 -> int             x.round()
std::decimal_rounded::to_string(x)
                                  DecimalRounded{minDecimalsPreserved: N} -> str
                                                             x.to_string()
```

| operation | rule | fails |
|---|---|---|
| `std::int::to_string(n)` | n's canonical decimal text (section 2) | never |
| `std::int::from_string(s)` | the Int whose canonical text is s | `InvalidIntegerText` for any other text |
| `std::float64::round(x)` | the Int nearest x's exact binary value, a half to the even Int | never |
| `std::decimal_rounded::to_string(x)` | round(x, N) half to even, exactly N fraction digits, N x's static guarantee | never |

`std::int` is a new namespace of two intrinsics (no module file, like
`std::char`): the Int operators themselves stay root natives that need no
import. `round` joins `std::float64`'s `from_int` and `truncate`;
`to_string` joins `std::decimal_rounded`'s `round`. Naming follows the
existing conversions: an observation lives in its source type's namespace
(`std::char::scalar_value`, `std::float64::truncate`), so a number's text is
`std::int::to_string` and its inverse `std::int::from_string` beside it, not
a second spelling in `std::str`. No duplicate was added: `std::test::int_text`,
the framework's own copy, was removed (section 12).

**Methods.** `to_string` and `round` read as methods and are ones:
`n.to_string()`, `x.round()`, `world.best.to_string()` on a field
projection. With both `std::int` and `std::decimal_rounded` imported,
`x.to_string()` resolves by the receiver's kind (the method filter excludes
the other candidate by its first parameter). `from_string` is registered
`-nomethod 1`: a String is no receiver of an Int's parse, and
`"12".from_string()` is NOMETHOD-CALL. All four take one parameter, so none
can draw METHOD-ELIGIBLE.

## 2. The integer text grammar

```
INT-TEXT  =  "0"  |  [ "-" ] DIGIT19 { DIGIT }
DIGIT19   =  "1" .. "9"          (ASCII only)
DIGIT     =  "0" .. "9"          (ASCII only)
```

This is not a new textual language: it is `core::value::isCanonicalInt`,
`^(?:0|-?[1-9][0-9]*)$`, the canonical text an Int already has -- its runtime
payload, its core IR and HIR constants and its printed display -- which is
the source integer literal's rule (decimal digits, no leading zeros:
surface/lexer.tcl) with a minus sign for a negative number. Every text
`to_string` writes is accepted and every accepted text is one `to_string`
writes, so the grammar describes the Ints exactly once:

| text | accepted | why |
|---|---|---|
| `0`, `7`, `-7`, `123456`, `-999999999999999999999999999999999` | yes | canonical |
| empty, `-` | no | no digits |
| `+1` | no | the literal syntax has no unary plus, and `to_string` never writes one |
| `01`, `-01`, `00` | no | the literal's no-leading-zeros rule |
| `-0` | no | zero has one text, `0` (source `-0` is the expression minus zero, not a literal) |
| `1.0`, `1e3`, `0x10`, `1_000` | no | no fraction, exponent, base prefix or separator: Botlish has none in integer literals |
| ` 1`, `1 `, `1\n` | no | no whitespace anywhere |
| `1x`, `x1`, `--1` | no | the whole text must be the number: nothing is ignored |
| `١٢`, `１` | no | non-ASCII digits (Tcl's `string is digit` would take them; the rule is the regexp's ASCII ranges, natively `u8::is_ascii_digit`) |

There is no length limit: an Int has any size, and so does its text.

## 3. Parse failure: InvalidIntegerText

A rejected text completes the call with the builtin declared error
`InvalidIntegerText` (payload-free, builtin error 11: declared by
core/inttext.tcl after core/listlength.tcl's `LengthMismatch`, so every
existing builtin error keeps its id; `native/src/runtime/error.rs`'s
`ERR_INVALID_INTEGER_TEXT`). It is ordinary: the caller handles it (`on
InvalidIntegerText:`) or declares it (`errors InvalidIntegerText`), and an
unhandled undeclared call is UNHANDLED-ERROR at compile time. The name is
the condition, not the function, so a later parser of integer text reuses
it. The parser never returns zero, clamps, stops early or ignores a suffix.

`from_string` has no fold, deliberately: a fold that decides a call fails
makes it KNOWN-ERROR *whatever handles it* (hir/completions.tcl), and a
constant invalid text that a program handles (`std::int::from_string("1x")`
with a handler) is a legitimate program, not a compile-time error
(`nt-int-from-string-declared`). `to_string` and `round` do fold: they never
fail, and a constant call is decided by the run's own computation (the
Tcl implementation, as `truncate`'s is).

## 4. The round-trip guarantee

For every Int x, `std::int::from_string(std::int::to_string(x)) == x`; for
every text t `from_string` accepts, `std::int::to_string(from_string(t)) ==
t`. Both directions are tested on every backend at the small-Int (2^62),
i64, u64 and u128 boundaries, both signs, and on 120 seeded random Ints of
up to 300 digits (`nt-int-round-trip`); the fuzzer adds Ints of up to 400
digits and corrupted texts against an independent oracle (section 10).

## 5. Float64 rounding

`std::float64::round(x)` is the Int nearest x, a value exactly halfway
between two Ints going to the even one:

```
 1.4 -> 1     1.5 -> 2     2.5 -> 2     3.5 -> 4
-0.5 -> 0    -1.5 -> -2   -2.5 -> -2
```

* **One rounding rule.** Float64 arithmetic rounds to nearest, ties to even
  (IEEE 754), and DecimalRounded observes round(x, P) half to even; this is
  round(x, 0) of the same model. The Tcl implementation is literally
  `core::decimal::RoundAt [DoubleRat x] 0`, the procedure every
  DecimalRounded observation uses -- no second rounding implementation.
  Half away from zero was rejected: nothing in Botlish uses it, and it would
  make `round` disagree with DecimalRounded{minDecimalsPreserved: 0}.
* **The exact binary value.** The input to the rule is x's exact value, not
  its shortest decimal text: 0.49999999999999994 (one ulp below 0.5) rounds
  to 0, 2.5000000000000004 to 3, -2.5000000000000004 to -3, and
  4503599627370495.5 (2^52 - 1/2, odd floor) to 4503599627370496
  (`nt-float-round-exact-binary`, which also checks each literal's bit
  pattern).
* **Total and exact.** Every finite Float64 is within half of some Int, and
  Int is arbitrary precision: `round(1.7976931348623157e308)` is its exact
  309-digit integer. There is no overflow error, no errors clause and no
  NonFiniteFloat.
* **Beside truncate.** `std::float64::truncate(x)` is unchanged (toward
  zero); the two are documented together (`stdlib.std::float64::round`,
  `concept.floats`): -2.7 truncates to -2 and rounds to -3. No floor or
  ceiling was added.

Natively `rt_f64_round` is `f64::round_ties_even` -- exact, since rounding a
finite binary64 to an integral one always lands on a binary64 (below 2^52
the integer fits the significand; above it every binary64 is one) -- then
the integral value converted exactly, as `rt_f64_trunc` converts its own: a
small Int below 2^62, else `BigInt::from_f64`. A Rust test pins it against
the exact `round_at(x, 0)` on halves, their neighbors and magnitudes far
beyond 2^62 (`f64_round_is_round_at_zero`).

## 6. DecimalRounded text

`std::decimal_rounded::to_string(x)`, x of static type
`DecimalRounded{minDecimalsPreserved: N}`, is the decimal text of round(x,
N), half to even:

* exactly N digits after the point for N > 0, trailing zeros kept: `2.0`,
  `2.00`, `25.00`;
* for N = 0 no point at all: `2` (ordinary integer-looking text; the
  existing program-result display already wrote it so);
* a "-" only before a nonzero result: DecimalRounded has no observable
  negative zero, so -0.04 at one place is `0.0` and -0.004 at two `0.00`;
* never a digit of the representation: the constant 0.295 at two places is
  represented by a binary64 *above* 0.295 (so that it rounds to 0.30, the
  decimal it spells), whose own digits are 0.29500000000000003996...; its
  text is `0.30`; a value weakened to fewer places shows only those
  (DecimalRounded{minDecimalsPreserved: 3} 1.255 passed as one place shows
  `1.3`);
* `maxDecimalsPreserved` changes nothing: the text is at minDecimalsPreserved,
  which the schema keeps at or below the ceiling. No API requests more
  digits (that would reopen the ceiling's semantics).

It is the display main.tcl already printed for a program's DecimalRounded
result (`hir::decimal::Display`, `core::decimal::text`), now an ordinary
String-producing operation: the same procedure, not a second set of rules.

It never fails for a valid value. `UnrepresentableDecimal` belongs to
quantization (`std::decimal_rounded::round`), not to display.

## 7. How the precision reaches the formatter

No value carries a precision: a DecimalRounded value is `{DecimalRounded X}`
in the Tcl runtime and a boxed binary64 natively, as before. The precision
is the argument's static type's, written into the call by the compiler,
exactly as for the decay and the comparisons:

```
std::decimal_rounded::to_string(x)      (the check form, after typing)
  -> decimal_rounded#to_string(x, N)    (hir::decimal::Elaborate, after every check)
```

`hir::decimal::Elaborate` reads N from the argument's refined type
(`hir::decimal::Precision`) and appends it as a constant Int, so no backend
reads a type or chooses a precision (`nt-dr-to-string-elaborated` pins the
elaborated call and the two-element runtime value).

* **Unknown precision.** An unrefined DecimalRounded type cannot be written
  (REFINEMENT-PARAMETER), and an unrefined static type reaching the call is
  `PrecisionUnknown`'s TYPE ("is made a String here, ... its type states
  none"). An argument statically of another kind -- a Float64, an Int -- is a
  new TYPE diagnostic of `hir::decimal::verify` ("the argument of
  std::decimal_rounded::to_string is Float64, not a DecimalRounded value
  ..."). The same check now covers `std::float64::from_decimal_rounded`,
  which used to accept a Float64 argument and fail only at run time.
* **Erased values.** A value whose static type is erased (an untyped
  parameter: `any`) is not elaborated; the check form refuses to run (the
  Tcl backends' run-time TYPE, the existing `core::decimal::Unelaborated`;
  native lowering has no implementation of the check form, NATIVE
  UNSUPPORTED) -- never digits no type guarantees (`nt-dr-to-string-erased`).

## 8. Reuse of the existing machinery

| need | reused | new |
|---|---|---|
| Int text (Tcl) | `core::value::show`'s Int case (the payload's canonical text) | -- |
| Int text (native) | the hash walk's stack formatter `decimal_text`, now `ops::with_int_text`, shared by hashing, `show::int_text` (program results, messages, the host transport) and `rt_int_to_str` | one routine for all four (it was two: `show::int_text` used Rust's `Display`) |
| Int parsing (Tcl) | `core::value::isCanonicalInt` and `core::value::int`, the constructor HIR and core IR constants use | -- |
| Int parsing (native) | num-bigint's decimal parser, which NIR's `int` constants use, on text the canonical check accepted (it would also take `+` and `_`); an i64 parse below 19 digits | `inttext::is_canonical_int` |
| Float64 rounding (Tcl) | `core::decimal::RoundAt` of `DoubleRat` | -- |
| DecimalRounded text (Tcl) | `core::decimal::text` / `RoundedText`, main.tcl's display | -- |
| DecimalRounded text (native) | `decimal::round_at` / `exact` | `text_at` (RoundedText's layout) and its machine path `round_at_small` |

Nothing parses or formats a second way: the canonical Int text has one
definition per runtime, and the backends agree on every case of the tests
and the fuzzer.

## 9. Performance

* **Display rounds once.** `to_string` rounds once at its known N
  (`RoundAt` / `round_at`), never through the proven-precision search
  (`Proven`) that quantization's representation choice uses.
* **A machine path where obviously safe.** Natively `round_at_small`
  computes round(x, P) with u128 arithmetic when it is exact: P <= 19 and
  x's scaled significand below 2^127 -- every |x| < 2^10 at every such P, and
  any x too small to reach a unit of 10^-P. It implements the same tie rule
  on the same exact value m x 2^e; anything else goes to the big-integer
  `round_at`. A Rust test compares the two at every P <= 19 on about 40,000
  values (subnormals to 2^70) and, for each, the decimal tie at P nearest it
  and that tie's two neighbors -- 3.2 million comparisons
  (`decimal_round_at_small_matches_round_at`); the fuzzer's precisions 0 to
  25 exercise both paths against the oracle.
* **Measured** (cranelift JIT, 2,000,000 calls in a loop, best of three,
  the empty loop subtracted):

  | operation | before (the workload's Botlish routine) | after |
  |---|---:|---:|
  | Int to text (Ints of up to 11 digits) | 1.23 us (`hud::int_text`, digits by subtraction) | 0.16 us |
  | DecimalRounded{1} to text | 1.25 us (`hud::metres_text`: decay, x10, nearest, tenths) | 0.23 us |

* **The workload.** Unchanged within noise: 6000 headless frames take 0.15
  s before and after (the summary is built once), 3000 dummy-driver frames
  1.60 s and 1.62 s (SDL's software renderer dominates a frame,
  ICY-TOWER-VERTICAL-SLICE-1.md). The executable is 3.5 KB smaller.

## 10. Tests and mutants

* **`tests/numeric-text.test`** -- 27 tests. Every value test runs on
  interp, compile, cranelift-generic and cranelift, which must agree, with
  inputs passed through parameters and loop elements so every backend's own
  implementation computes them; plus the folds' registrations, the
  literals' bit patterns, a representation's binary64, the elaborated HIR
  call, the NIR ops, the builtin error's index against error.rs, and a
  standalone executable.
* **`tests/golden/numeric-text.bot`** -- 27 golden tests porting the
  source-observable ones (15 whole, 12 the observable half of a SPLIT test;
  census `audit/golden/migration/census/numeric-text.tsv`, fragment
  `audit/golden/migration/fragments/numeric-text.tsv`, manifest
  regenerated). `audit/golden/tools/perturb.tcl`: 27 of 27 fail inverted, 27
  of 27 altered.
* **`audit/numeric-text/tools/fuzz.tcl`** -- random Ints of up to 400
  digits, canonical and corrupted texts (a "+", a leading zero, "-0",
  spaces, a letter, a fraction, an exponent, "_", a non-ASCII digit, a
  newline, a doubled sign), random binary64s of every magnitude with exact
  halves and their neighbors, and random binary64s quantized at precisions
  0 to 25 and shown, all in one program run on the four backends and
  compared with **`oracle.py`**, written from this report's rules with
  Python's integers, fractions and decimals (no shared code): seed 1 (60
  cases of each kind) and seeds 2, 3 and 17 (100 of each), 0
  disagreements in 1,828 cases.
* **Rust unit tests** -- `int_text_canonical_grammar`,
  `int_text_round_trips`, `int_text_helpers_round_trip_through_values`,
  `f64_round_is_round_at_zero`, `decimal_text_at_rounds_once_half_to_even`,
  `decimal_round_at_small_matches_round_at`; the existing hash tests
  (`decimal_text_is_to_string`, `int_and_char_hashes_are_their_to_string_bytes`)
  pin the shared Int formatter.
* **`audit/numeric-text/tools/mutate.tcl`** -- 26 mutants, each in one
  runtime (Tcl and native separately) or in the front end, **26 killed**:

  | the bug | Tcl | native |
  |---|---|---|
  | the Int formatter drops the minus sign | int-drops-minus | native-int-drops-minus |
  | the Int formatter emits a leading zero | int-leading-zero | native-int-leading-zero |
  | the parser accepts trailing junk | parse-trailing-junk | native-parse-trailing-junk |
  | the parser accepts a leading zero | parse-leading-zero | native-parse-leading-zero |
  | round goes half away from zero | round-half-away | native-round-half-away |
  | round truncates | round-truncates | native-round-truncates |
  | the DecimalRounded text is the Float64's shortest text | dr-float-text | native-dr-float-text |
  | it shows one hidden digit more | dr-extra-digit | native-dr-extra-digit |
  | it rounds a half up | dr-half-up | native-dr-half-up |
  | it drops trailing zeros | dr-trailing-zeros | native-dr-trailing-zeros |
  | it keeps a negative zero | dr-negative-zero | native-dr-negative-zero |
  | a constant Int's decided text differs from a run's | int-fold-wrong | -- |
  | the elaborated precision is one too many | dr-precision-off-by-one | -- |
  | a Float64 argument is not rejected statically | dr-float-accepted | -- |
  | the parse's declared error is not checked natively | -- | native-strtoint-unchecked |

## 11. Icy Tower

| removed | now |
|---|---|
| `hud::digit`, `fits`, `digits`, `int_text` (digits by subtraction) | `n.to_string()` |
| `hud::nearest` (`truncate(x +- 0.5)`, half away from zero) | `x.round()` (ties to even) |
| `hud::tenths_text`, `metres_text` (decay, x10, nearest, pad, slice, spell) | `m.to_string()` |
| `options::number` (at most 18 digits, a character at a time) | `std::int::from_string`, a negative number refused |

* hud.bot is 85 lines (146 before); `timer_text` and `summary` no longer
  declare NonFiniteFloat (the old `nearest` and `metres_text` did, for their
  Float64 arithmetic), and `status_lines` is total. render.bot shows a
  milestone floor's number with `p.floor.to_string()`. Across the game's
  modules and stdlib/test.bot: 76 lines added, 157 removed (the golden
  suite's new tests included).
* **Behavior.** The summaries of 8 seeds x 4 frame counts match oracle.py,
  and 49 of 50 summaries match the previous executable's. The one
  difference is the canonicalized rounding: seed 3 after 60 frames has the
  player at exactly x = 286.5, shown 287 before and 286 now; oracle.py's
  `nearest` is now Python's `round` (ties to even on the exact value). The
  command line now reads a number as the canonical text of a nonnegative
  Int: `--frames 007` and `--seed -5` are usage errors (007 was 7), and a
  seed may have any number of digits (it was at most 18).
* **Tests.** The golden suite keeps every test and its expectations
  (`icy-int-text` and `icy-tenths-text` now observe the stdlib conversions
  through the HUD's uses) and gains two:
  `icy-options-numbers-of-any-length`, and
  `icy-summary-shows-positions-at-the-nearest-int` (x = -2.5, camera 633.5:
  ties to even both ways), plus three usage errors in `icy-options-errors`.
  The second was added because the rewritten mutant `camera-truncated`
  survived without it: nothing pinned how the summary rounds a fractional
  position. 67 golden tests pass on the four backends; `tests/workload-icy-
  tower.test` 15 of 15 (the headless and dummy-driver executables
  included); `audit/icy-tower/mutate.tcl` 26 of 26 killed (four mutants of
  the removed code rewritten against the new calls, each the same kind of
  application bug: `best-shown-cut-off`, `camera-truncated`,
  `timer-without-quantizing`, `number-negative-accepted`); `oracle.py
  compare`: 0 differences. The committed executable is rebuilt
  (`build.sh`, `-warnings error`).

## 12. The repository's other conversion routines

| routine | what it did | now |
|---|---|---|
| `stdlib/test.bot`'s `digit_value`, `digits_from`, `int_text` (the public `std::test::int_text`) | Int to text by subtraction, for reports | removed: `describe`, `diagnostic_text`, `summary_line` and `report` use `std::int::to_string`; its glyph table keeps only the punctuation. The framework's tests that called `std::test::int_text` (`gf-int-text`, `gf-gc-stress`, framework-semantics.bot, ownership.bot) call `std::test::describe`, whose Int text is the same, and the framework mutant `int-text-drops-sign` mutates `describe`'s Int branch (killed) |
| the 2048 demo's `digit`, `fits`, `digits`, `decimal` (examples/games/2048/demo_play.bot) | Int to text by subtraction | **kept**: AGENTS.md and POST-2048-PRODUCT-FIXES.md keep the 2048 workload's workarounds as its evidence ("do not rewrite them with a new convenience"); POST-2048's S1 row now says where the stdlib closed it |
| `stdlib/web.bot`'s `hex_digits`, `hex_pair` | a byte as two hexadecimal digits (URI percent-encoding) | kept: base 16 and fixed width, intentionally different (bases are out of scope) |
| `audit/hash-table/drivers/*.bot`'s `int_of` | a nonnegative decimal argument, unchecked | kept: the drivers of a finished experiment whose results are recorded with them |
| `audit/compiler-service/probes/json/json_tokens.bot`'s `digits_end` | the end of a JSON number token | kept: a tokenizer's scan, no conversion |
| `tests/golden/struct-representation.bot`'s `substring("0123456789", ...)` | a key name per index | kept: a test fixture's names, no conversion |

## 13. Effects on existing behavior and tests

* **`int::NAME` is now the missing standard namespace.** The loader reports
  a qualifier that is a standard namespace's short name as the namespace it
  misses (UNKNOWN-NAMESPACE with the hint ``import std::int``), as it
  already did for `str::...`; it reports NOT-AN-ENUM for a built-in type
  qualifier only when no standard namespace has that name. So `int::Car`
  moved from NOT-AN-ENUM to UNKNOWN-NAMESPACE -- the right diagnosis for
  the likelier mistake, `int::to_string(n)` without its `std::`.
  `enum-qualifier-not-an-enum` (tests/enums.test and its golden port, now
  `.../bool`) keeps its theorem with `bool::Car`, a built-in type no
  namespace is named after.
* **Registry inventories** that pin the natives exactly were extended:
  tests/stdlib-namespaces.test (`ns-root-inventory`: the internal
  `decimal_rounded#to_string`; `ns-qualified-inventory`: `std::int`, `round`,
  `to_string`; `ns-error-signatures`: InvalidIntegerText, the twelfth
  builtin error), tests/method-eligible.test
  (`me-nomethod-native-default-off`: `std::int::from_string` is the one new
  nomethod native) and tests/linux-syscall.test (`int` is a standard value
  family).
* `std::float64::from_decimal_rounded` of a statically non-DecimalRounded
  argument is now rejected at compile time (it failed at run time before).
* `std::test::int_text` is gone (section 12).

## 14. Can application code now display the numeric semantics it declared?

**Yes, for Int and DecimalRounded.** An Int is shown, and read back, by its
canonical decimal text in one call each, exactly, at any size. A
DecimalRounded value is shown as the decimal its type declares --
`DecimalRounded{minDecimalsPreserved: 1}` as one place, rounded half to
even, zeros kept, no negative zero -- by `x.to_string()`, with the precision
taken from the declaration itself, never reconstructed from the binary64
behind it: the Icy Tower HUD's height and timer are `best.to_string()` and
`shown.to_string()` where they were a decay, a multiplication, a hand-made
rounding and a digit speller. A Float64 is rounded to an Int by the
language's one rounding rule.

**Not for Float64 text.** A Float64's own digits still reach the user only
as a program's printed result; there is no `std::float64::to_string`
(deliberately out of scope: shortest-round-trip versus fixed versus
scientific is a formatting decision this milestone does not make).

## 15. Remaining gaps

* Float64 to String (the format decision above) and String to Float64.
* String to DecimalRounded (parsing a decimal into a guarantee), and a
  caller-chosen precision within a DecimalRounded type's range.
* Any base but ten, digit grouping, padding and alignment (Icy Tower and
  2048 pad by hand), format strings and interpolation.
* Integer division and `floor`/`ceiling` of a Float64.
* A DecimalRounded value of erased static type has no text (by design: no
  precision is known); natively the check form is a lowering refusal, on
  the Tcl backends a run-time TYPE -- both clean, neither shows digits.
* A standalone executable's type-blind result printing still shows
  `<DecimalRounded>`: a program that wants the digits builds them with
  `to_string`.
* Static folding of `std::decimal_rounded::to_string` of a constant (not
  needed: the call is cheap, and folding it would have to run after
  elaboration).

## What to run when changing this

The files: `core/inttext.tcl`, `core/float.tcl`'s `Nearest`,
`core/decimal.tcl`'s `text`/`RoundedText`/`ToStringNative`,
`hir/decimal.tcl`'s `verify` and `Elaborate` cases of
`std::decimal_rounded::to_string` and `std::float64::from_decimal_rounded`,
`native/src/runtime/inttext.rs`, `ops.rs`'s `with_int_text`,
`decimal_text` and `rt_f64_round`, `decimal.rs`'s `text_at`,
`round_at_small` and `rt_decimal_to_str`, the four NIR ops, the natives
table of `native/lower.tcl`. Run `tests/numeric-text.test`, its golden
suite (`tclsh9.0 tests/local.tcl tests/golden/numeric-text.bot`),
`audit/numeric-text/tools/fuzz.tcl` (several seeds), `python3 -I
audit/numeric-text/tools/oracle.py selftest`,
`audit/numeric-text/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule) and `cargo test
--release --manifest-path native/Cargo.toml --lib -- int_text f64_round
decimal_ hash`; for a change to the DecimalRounded parts also
`tests/decimal-rounded.test` and its harnesses (AGENTS.md, "DecimalRounded
and scalar refinements"); for a change to the shared Int formatter also the
hashing harnesses (AGENTS.md, "Hashable and the keyed table hash"); for a
change to the Icy Tower game its own (AGENTS.md, "Workloads
(examples/games/icy-tower)").
