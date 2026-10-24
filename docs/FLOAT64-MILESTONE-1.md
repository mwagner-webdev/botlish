# Float64, milestone 1: completion report

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: `std::ffi::c::Double` is a
> C representation (`{cfloat Double}`) wherever a C type is written -- an
> extern's parameters and result, a pointee (`Ptr[std::ffi::c::Double]`, section
> 7's "not yet"), a function pointer's signature, a layout field -- and still
> `Float64` where a value type is; C `float` is `std::ffi::c::Float` beside it.

Botlish has a primitive floating-point type, `Float64`: the finite IEEE 754
binary64 numbers. This report says what a program can now write, how each
layer implements it, how finiteness is enforced, what was tested where, and
what still assumes Float64 specifically.

Float64 is the first member of a family. Float32, Float80 and Float128 are
expected later; precision-guaranteed decimal types (`DecimalRounded` and the
like) are separate future work and are not part of Float64. Exact IEEE
representation-sensitive behavior (bit patterns, NaN payloads, signed zero,
rounding modes) is not exposed as a programming model.

## 1. Language behavior

```botlish
x = 1.5
y = -2.0
[x + y, x - y, x * y, x / y, -x]        # [-0.5, 3.5, -3.0, -0.75, -1.5]
[x < y, x <= y, x > y, x >= y, x == y, x != y]

fn mean(a: Float64, b: Float64) -> Float64 errors NonFiniteFloat:
    (a + b) / 2.0

m = mean(x, y):
    on NonFiniteFloat:
        0.0
```

* **Values.** A Float64 is a finite binary64 number. NaN, +Inf and -Inf are
  never values. There is no negative zero: every operation, the value
  constructor and the C boundary make -0.0 the one zero, so `==` is an
  equivalence and `hash` agrees with it. Subnormal numbers are values.
* **Literals.** `DIGITS.DIGITS`, then optionally `e` or `E`, an optional
  sign and `DIGITS`: `0.0`, `1.5`, `10.0`, `2.5e-3`, `6.02e23`. A point
  needs a digit on both sides (`.5` and `5.` are not numbers). Leading zeros
  are rejected, as they are for Ints. A letter right after the literal is
  rejected too. `-3.25` is negation applied to `3.25`, as `-3` is for an
  Int. A literal beyond the largest finite Float64 is a syntax error where
  it is written. A literal too small to tell from zero is `0.0`
  (round to nearest). See section 3 for the typing rule.
* **Operators.** `+ - * /`, unary `-` and `< <= > >=` on two Float64
  operands are the Float64 operations, correctly rounded (nearest, ties to
  even). `==` and `!=` are the language's one equality, so `1.0 == 1` is
  `false`. Comparisons do not chain, as before.
* **No implicit conversion.** An Int and a Float64 together are a TYPE
  error where the operator is written:
  `the operands of "+" are Float64 and int: a Float64 operation needs Float64
  operands, and nothing converts one implicitly (std::float64::from_int makes an
  Int a Float64)`.
* **Division.** `/` divides Float64 values and nothing else. There is no
  integer division: `7 / 2` is
  `"/" divides floating-point numbers, and neither operand here is one (the
  operands are int and int): Botlish has no integer division` (TYPE).
* **Non-finite results are errors.** A result that is not finite fails with
  the declared builtin error `NonFiniteFloat`. That covers overflow, any
  division by zero (`1.0 / 0.0`, `-1.0 / 0.0`, `0.0 / 0.0`, `1.0 / -0.0`)
  and any other NaN. `NonFiniteFloat` is an ordinary declared error: an `on`
  handler catches it, an `errors` clause admits it, and an unhandled one is
  the compile-time UNHANDLED-ERROR. It is never clamped, and no
  `isnan`/`isinf` exists. The name describes the condition, not the type,
  so every future width will fail with the same error.
* **Which non-finite result it was** (section 15). The error carries the
  payload `{result: NonFiniteResult}`, the builtin enum's
  `PositiveInfinity`, `NegativeInfinity` or `NotANumber`:

  ```botlish
  fn ratio(a: Float64, b: Float64) -> Float64:
      a / b:
          on NonFiniteFloat {result}:
              if result == NonFiniteResult::NotANumber:
                  return 0.0
              -1.0
  ```

  Overflow and division by zero give the infinity of the result's sign;
  only `0.0 / 0.0` gives `NotANumber`. Division by `-0.0` is division by
  zero, the one zero, so `1.0 / -0.0` is `PositiveInfinity`. The payload is
  a fact about one failure, read by the handler where it happened. No value
  is ever NaN or an infinity, and no operation tests a value for being one.
* **Annotations.** `Float64` is a type name wherever a type can be written:
  parameters, results, struct fields, `List[Float64]`, `Fn{...}`
  contracts. An untyped parameter used with a Float64 operand is inferred
  `Float64` (the operation's checked contract), so `half(3)` of
  `fn half(x): x / 2.0` is rejected at the call.
* **Conversions** (`import std::float64`, the whole standard-library addition):
  * `std::float64::from_int(n)` gives the nearest Float64, ties to even, from the
    exact Int at any size; an Int beyond the range fails with
    `NonFiniteFloat`.
  * `std::float64::truncate(x)` gives the integer part, toward zero, exact at any
    magnitude; it never fails.
  * Nothing else: no rounding modes, no math library, no text conversion, no
    bit access.
* **Printing.** A program's Float64 result shows as the shortest decimal
  that reads back to the same number, always with a point: positional for
  decimal exponents -4 to 15 (`0.1`, `3.0`, `123456.789`), otherwise
  `D.DDDeN` (`1.0e100`, `5.0e-324`). Every backend prints the same text.

## 2. Typed local bindings were not added

The milestone brief writes `x: Float64 = 1.5`. Botlish has no typed local
bindings for any type: STRICT-TYPED-PARAMETERS.md and
MINIMAL-APPLIED-LIST-TYPES.md deferred them, and adding them would be a
language feature for every type (grammar, lowering, a binding-level check
and its diagnostics), not part of a float type. So `x = 1.5` binds the
Float64 1.5, and `Float64` annotations work everywhere Botlish already has
annotations. If typed locals are wanted, they belong in their own milestone,
and Float64 needs nothing special from them.

## 3. The literal-typing rule (temporary, deliberately not binding)

**Rule:** a decimal literal is the Float64 nearest its decimal value. A
literal without a point is an Int, as before. Nothing else decides a
literal's type: not the binding, the parameter or the operator it reaches.

The rule lives in exactly one procedure, `surface::lower::DecimalConstant`.
The lexer produces a `DECIMAL` token holding the exact digits (exponent
marker lowercased). The parser keeps a `decimal TEXT` AST node with that
exact text. Lowering asks DecimalConstant for the constant: today
`Float64 CANONICAL-TEXT`, or the out-of-range syntax error. So the exact
decimal survives up to that one decision, and a later milestone can change
it in that one place, without touching the lexer, the parser or the AST.
For example, a precision-aware literal type, or contextual typing from a
`DecimalRounded` annotation. `tests/float64.test`'s
`float-literal-decimal-rule-one-place` pins this.

Contextual typing was considered and not chosen: Botlish has no typed
locals (section 2) and no bidirectional typing, so a context would rarely
exist, and a mechanism built for one type would bind the future design
more than a single, replaceable rule does.

## 4. Type system and IR

* **The family.** `core/type.tcl`'s `floats` table holds one row per float
  type: `Float64 {width 64 precision 53 minExponent -1022 maxExponent 1023
  namespace float64}`. A float type is a primitive and a scalar kind
  (`core::type::floatTypes`, `isFloat`, `floatInfo`, `scalarKinds`). Every
  check that used to list the scalar kinds by hand now asks
  `scalarKinds`/`isFloat` (section 8). A float type is never an Int with
  exceptions: its own kind `{Float64 X}` (`core/value.tcl`), its own hash
  tag, its own heap kind natively.
* **Operator resolution** (`hir/operators.tcl`, new) decides an operator's
  meaning by its operands' static types, inside `hir::types::infer`.
  * The source frontend marks the calls it writes for operators
    (`hir::syntax::withOperator`: `+ - * / < <= > >= neg`).
  * After a typing walk, every marked call with an operand of a float type T
    is rewritten into an ordinary call of the root native `T#OP` (unary
    minus loses its synthetic `0`). The program is then typed again, until
    nothing changes (a fixpoint, usually one extra walk).
  * Every later stage sees an ordinary native call: the checks, the
    completion proofs, interchange, Core IR, every backend. Semantic
    instances and specializations re-type bodies but never choose again, so
    no instance runs another operation than the program does.
  * An operand of another kind is the TYPE diagnostic above, and the call
    is poison: no cascade. An unresolved `/` is the integer-division TYPE
    diagnostic.
  * A `+` written in Core IR text is the Int native it names: resolution
    applies only to source operators.
  * This is not overloading. Nothing is declared, nothing dispatches at run
    time, and the set of meanings is one table, `core::float::operators`.
  * The `T#OP` natives cannot be spelled in source (`#` starts a comment).
* **Natives** (`core/float.tcl`, new) are registered per float type, from
  the table:
  * `T#+ T#- T#* T#/`: errors `NonFiniteFloat`.
  * `T#neg`.
  * `T#< T#<= T#> T#>=`: Bool results.
  * `NS::from_int` and `NS::truncate`.
  * The root `/` exists only to be the spelling's callee. It has no Int
    meaning, and at run time (Core IR only) it raises TYPE.
* **Core IR.** `(const Float64 TEXT)` takes exactly the canonical text of a
  finite number, so a non-canonical or non-finite text is malformed IR.
  `(const 1.5)` untyped is still the String "1.5".
* **HIR text and interchange** carry the constants and the resolved calls
  unchanged. `hir/format.tcl` and `hir/read.tcl` needed nothing new: a
  resolved operator is an ordinary native call. The front-end fingerprint
  changes with the front end, as it must.
* **C.** `std::ffi::c::Double` is `Float64` under its C name (section 7).

## 5. Finite-only enforcement

Every path that makes a Float64 checks finiteness before a value exists.

| Path | Where | Check |
|---|---|---|
| Tcl backends (interp, compile) | `core::float::apply` -> `Make` | a zero divisor, a Tcl domain error (a NaN result: Tcl raises on `0.0 / 0.0` but returns `Inf` for `1.0 / 0.0` and on overflow), or a result `isfinite` rejects: `{error NonFiniteFloat RESULT}` (`Classify`, `DivisionByZero`), raised as the declared error with its payload |
| Constant folding | the same `core::float::apply` (section 6) | the same code |
| Native code | `codegen::clif`'s `float_op` | the unboxed result `r + 0.0` (negative zero becomes zero), then `fabs(r) <= f64::MAX` (false for NaN and both infinities); otherwise `rt_float_nonfinite` fails with the builtin error, given the result's class (`non_finite_code`: NaN, or the infinity's sign) |
| A native called as a value | `runtime::ops`'s `float_apply` (`apply_op`) | the same check in Rust (`FloatType::admit`) |
| from_int | `rt_f64_from_int`, `core::float::FromIntNative` | an Int beyond the range has no finite nearest value |
| C results | `codegen::clif`'s foreign call | the same `fabs <= MAX` check on the returned double |
| Literals | `surface::lower::DecimalConstant` | an out-of-range literal is a syntax error |
| NIR and HIR text, Core IR | `nir.rs`'s `float TYPE BITS`, `core::ir`'s CheckShape | the bits or text must be a finite, non-negative-zero value of the type |

Comparisons compute with ordered conditions (`fcmp lt`, ...). Equality
compares the canonical bits (`f64eq`, `core::value::equal`), which is exact
numeric equality because no NaN and no -0.0 exist. So no backend can show a
NaN-shaped surprise.

## 6. Constant folding

A native may carry a `-fold` command (`core/native.tcl`). Each float
operation and from_int/truncate has one: `core::float::Fold`, which calls
the same `core::float::apply` the run-time implementation calls. The
completion analysis (`hir/completions.tcl`'s `FoldCall`, read through
`ExactValueOf` and `NativeEffectiveFacts`) and the exact-value analysis
(`hir/exactvalue.tcl`) fold a call whose arguments are exactly known:
literals, bindings of them, earlier folded calls, single-value Int ranges.

* A finite result is a normal completion: no handler needed, and the
  value is known downstream.
* A non-finite result means the call can never complete normally: it is
  KNOWN-ERROR, handled or not, as for any decided declared error. So
  `1.0 / 0.0` is a compile-time error. No non-finite value is ever embedded
  in a program.

Folding decides; it does not replace. The program still contains the call,
and every backend computes it at run time. So a folded and an unfolded
`1.0 / 0.0` cannot behave differently: the folded one never compiles. And
the folded value of a finite call equals the run-time value because they
are one computation.

Fidelity of compile-time to target arithmetic:

* Tcl's `expr` doubles are binary64 with round-to-nearest-even on every
  supported host.
* The native code uses the target's IEEE instructions in the default
  rounding mode: Cranelift never enables fast-math or flush-to-zero.
* `float-decided-equals-run` checks twenty decided operations against the
  same operations at run time, bit for bit.
* `float-arithmetic-parity` and `float-from-int-parity` check random
  operations on all four backends.

The conservative choices:

* Nothing folds unless every argument is exactly known.
* from_int rounds correctly from the exact bignum on both runtimes (Rust:
  round-to-odd then round-to-nearest-even).

## 7. FFI: C `double`

`std::ffi::c::Double` is a C ABI value type for `extern c fn` parameters and
results (`hir/cabi.tcl`). It is Float64 itself, so a program needs no
conversion. Its ABI class is `f64` (`hir/foreign.tcl`, `nir::CAbi::F64`).
Cranelift places it by the target's C convention
(`codegen::target::c_call_conv`): the floating-point argument registers
(xmm0-7 on SysV x86-64, d0-d7 on AAPCS64), then the stack, with integer and
floating-point parameters filling their own register classes.

* **Out:** a finite Float64 is unboxed and passed as is. A Float64 is never
  negative zero, so C never receives one.
* **In:** the returned double is normalized (`+ 0.0`) and checked for
  finiteness before it becomes a Float64. NaN, +Inf or -Inf fail the call
  with `NonFiniteFloat`, whose payload says which of the three C returned,
  so a declaration whose result is `std::ffi::c::Double` declares that error,
  and callers handle it. Negative zero becomes zero.
* The Tcl backends refuse every C call (`NATIVE-ONLY`), these included.

Not added:

* `Ptr[std::ffi::c::Double]` as a pointee.
* C `float` and `long double`: they have no Botlish type yet.
* Double support in the binding generator (`tools/c-bindgen.tcl` still
  reports `double` declarations as unsupported). Mapping it is a generator
  change plus a regeneration of every committed profile, a step for its
  own change.

## 8. Integer-only assumptions found and fixed

The audit of the pipeline found these places that enumerated the value
kinds or assumed the only number is Int. All now include the float family,
through `core::type::scalarKinds`/`isFloat`, not a second list:

* `hir::types::IsEqualityTotal`: the kinds whose `==` never fails.
* `hir/methodfilter.tcl`'s comparable kinds (now `hir/methods.tcl`'s kind
  proofs: METHOD-DECISION-FILTER.md).
* `hir/modulebinding.tcl`'s value kinds.
* `hir/mutvec.tcl`'s `MayHoldVector`: a float holds no vector.
* `hir/containers.tcl`'s `NonRetaining`.
* `hir/aot.tcl`'s structural equality.
* `hir/exactvalue.tcl`'s exact scalar kinds.
* `core/hashing.tcl`'s kind tags.
* `core/ir.tcl`'s const shapes.
* The lexer: `/` was an unknown character, and `1.5` lexed as a projection
  of the Int 1.
* The parser's handled-call rule: a handler could follow only a call
  syntax, so `a / b:` with `on NonFiniteFloat:` was a syntax error. Now an
  arithmetic operator expression may be handled too.
* The legality diagnostics named the callee `"Float64#/"`. They now say
  `this Float64 "/"` (and an extern by its declared name).

Checked and left unchanged, because they are correct for floats:

* The range analysis (`hir/range.tcl`): it keys on the Int natives'
  identity, so a Float64 comparison yields no Int range fact.
* Branch-form conditions: a Float64 comparison is an ordinary Bool call.
* The Tcl compiler (`compiler/`): it compiles native calls generically.

## 9. Backend changes

* **Tcl backends.** A value is the list `{Float64 X}`, X the Tcl double
  (`core/value.tcl`). `core::float` computes with `expr` and checks every
  result (section 5).
* **Native representation.** A Float64 is a heap object, `FloatObj {header,
  bits}`:
  * Its kind is `KIND_FLOAT`, and its header records a float-type code.
  * It holds no references, so the GC traces nothing in it.
  * A value word is a pointer like any boxed value. Botlish functions pass
    and return Float64s as ordinary tagged words. So no calling-convention,
    register-class or spill-slot change was needed for calls between
    Botlish functions, on any target.
  * A number is unboxed only inside one operation. The op loads the f64
    (`load.f64` at `FLOAT_BITS_OFFSET`), computes, checks, and boxes with
    `rt_float_new`, the one allocation and safepoint. A float register
    never lives across a call or a safepoint.
* **Constants.** A constant is a static `FloatObj` in the constant table
  (`Const::Float`, NIR `float Float64 0xBITS`). The AOT image format
  serializes it (tag 5: type prefix and bits). The ABI fingerprint covers
  `FLOAT_BITS_OFFSET`. Standalone executables (rustc and stub linkers)
  embed constants like the JIT's.
* **NIR and codegen.**
  * Opcodes `f64add f64sub f64mul f64div f64neg f64lt f64le f64gt f64ge
    f64eq f64fromint f64trunc`, mapped to `(FloatType, FloatOp)` by
    `OpCode::float`.
  * Arithmetic and comparisons are Cranelift's `fadd fsub fmul fdiv fcmp`,
    which select each target's own scalar double instructions: SSE2 on
    x86-64, FP/SIMD on AArch64. Negation is `0.0 - x`, so the negation of
    zero is zero.
  * `op_may_allocate` and `op_may_error` list the arithmetic ops, so stack
    maps and error edges cover them.
* **Runtime.** `rt_float_new`, `rt_float_nonfinite`, `rt_f64_from_int`,
  `rt_f64_trunc`, `float_apply` (natives called as values), equality,
  hashing (the same FNV of the little-endian bits as `core/hashing.tcl`),
  `show` (shortest round-trip digits in the same layout as
  `core::float::text`) and the Tcl-value bridge.

## 10. Platforms and backends tested

All four backends (interp, compile, cranelift-generic, cranelift) run every
value test of `tests/float64.test` and the golden suite, and must agree.

**Verified in this change** (Linux x86-64):

* the whole Tcl suite (`tests/local.tcl`);
* the float tests on all four backends;
* JIT and standalone executables, with the rustc and the stub linker;
* `BOTLISH_NATIVE_GC_STRESS=1`;
* the C fixture round trip (SysV: xmm registers, stack beyond eight
  doubles, interleaved with integer registers).

**Passed in CI on this change's branch:**

* Linux x86-64: `tests.yml`, every job. That includes the whole Tcl suite
  on interp and compile, its cranelift and cranelift-generic coverage,
  every golden suite on every backend beside its Tcl originals, the stub
  linker, the warning gate and the native Rust tests.
* Linux AArch64: `tests-arm64.yml`, every job. That includes the C double
  round trip in AAPCS64's d-registers, the golden suites on all four
  backends, the native Rust tests (also under GC stress) and the whole
  suite under `BOTLISH_NATIVE_GC_STRESS=1`.
* macOS AArch64: `macos-arm64.yml`'s Tier A smoke and Tier B acceptance
  (Apple AArch64). C calls were refused there before linking, as for every
  C call (the C-call port belongs to the macOS roadmap), so the C double
  tests were Linux-only by constraint. Since MACOS-AARCH64-MILESTONE-6.md
  they run wherever C calls do (`nativeCCalls`), macOS included.
* `static-decisions.yml`: every golden suite, `float64.bot` included,
  decided alike by the batched and the sequential scheduler.

**Not run:** Windows x86-64 (no runner). `float-target-independent`
compiles the same program for every target of the C ABI table, the Windows
ones included, and gets identical HIR types and decided values: the
semantics name no platform.

## 11. What was deliberately not added

* Float32, Float80, Float128.
* DecimalRounded or any exact/decimal/arbitrary-precision float.
* A numeric tower, implicit coercions.
* Integer division.
* A math library, fast-math, mixed precision.
* `isnan`/`isinf`, NaN or infinity values, bit casting. (The error's
  `NonFiniteResult` payload, section 15, is a deliberate deviation from the
  brief: it describes a failure at the boundary where it happened, never a
  value.)
* Raw IEEE construction, serialization or float text APIs.
* Typed locals (section 2).

## 12. Extension points, and what still assumes Float64

A new width is, by design:

* a row of `core::type::floats`;
* its `core::float::Round`;
* a `FloatType` variant in `runtime/value.rs` (`parse`, `code`, `prefix`,
  `kind`, `admit`);
* its NIR prefix in `native::lower::FloatNatives`;
* its codegen load/store type.

Its natives, operator resolution, folding, the error, the checks above and
the HIR need nothing new. These places still name Float64 or binary64 and
would need work for another width:

1. **`core::float::Round`** accepts width 64 only. Its comment records why
   binary32 could round each binary64 result once (innocuous for `+ - * /`)
   and why a wider type needs arithmetic of its own: Tcl has no binary80 or
   binary128.
2. **`core::float::bits64`, `Decompose`, `Text`.** The canonical text and
   the hash read a Tcl double, so they are binary64-specific.
3. **`core/hashing.tcl`.** One kind tag (12) for Float64. A second type
   needs its own tag.
4. **The Rust runtime.**
   * `FloatObj.bits: u64`, `float64_of`, `float_text(f64)`.
   * `rt_f64_from_int`/`rt_f64_trunc`, and the arithmetic arms of
     `float_apply`.
   * They `match` on the one `FloatType` variant, so adding a variant makes
     each a compile error to resolve (deliberate), but the bodies are
     f64-only.
5. **NIR opcodes** are per width (`F64Add`, ...). A second width adds its
   own family (`F32Add`, ...) mapped through `OpCode::float`, rather than a
   type operand. `native/lower.tcl` names Float64 in three places beside
   `FloatNatives`' prefix table: the `Float64` case of `Const`, the `f64eq`
   selection of `==` in `NativeCallOp`, and `FloatConstText`'s
   `core::float::bits64`.
6. **Codegen** loads and stores `types::F64`. `float_op`'s finiteness bound
   is `f64::MAX`, and its constants are `f64const`. Both need the width's
   Cranelift type, which exists for 32-bit floats but not for 80- or 128-bit
   ones. Float80/Float128 would need software arithmetic or runtime calls
   on most targets, and this is where backend capability stays separate
   from the semantic type.
7. **The C ABI.** `nir::CAbi::F64`, `hir/foreign.tcl`'s `f64` class and its
   `NonFiniteFloat` rule, and `hir::cabi::DoubleName` are C `double`
   specifically. `float` would be a second name and class.
8. **`surface::lower::DecimalConstant`** gives every decimal literal the type
   Float64 (section 3). That is the intended single point to revise.
9. **`hir::types::resolveNamed`** maps `std::ffi::c::Double` to `Float64`.

## 13. Tests

* **`tests/float64.test`** (55 tests, new) covers:
  * the lexer and parser, and the literal rule;
  * canonical text and Core IR literals;
  * the value kind, negative zero, the family table;
  * arithmetic, comparisons, equality, run-time values, joins and closures,
    aggregates, List inference;
  * resolution and its diagnostics: mixed operands, no integer division,
    Core IR `+`, no overloading;
  * NonFiniteFloat: unhandled, at run time (division by +0.0 and -0.0, of a
    positive, a negative and a zero dividend; overflow of + - * and /),
    propagation, decided at compile time, decided equals run;
  * NonFiniteFloat's payload: the result of every way to fail (overflow,
    division by +0.0 and -0.0, from_int, a native called as a value, a C
    result), whole and destructured bindings, the builtin enum in the entry
    program and in a module, a program's own `fail`, the uncaught rendering,
    HIR text and interchange;
  * conversions, and parity of the Tcl and native runtimes (from_int, text,
    random arithmetic);
  * HIR text and interchange, NIR, CLIF, GC stress, standalone
    executables;
  * C double: the type, the round trip on both native backends, NaN/+Inf/-Inf
    rejection, -0 normalization in both directions, the Tcl refusal;
  * target independence.
* **`tests/cffi/float-fixture.c`** is the C side.
* **`tests/golden/float64.bot`** (35 golden tests) ports the
  source-observable halves of 19 of those tests. Its fragment and census
  rows are in `audit/golden/migration/`. Every row is SPLIT: the Tcl tests
  also pin printed text and messages, so they keep running.
  `audit/golden/tools/perturb.tcl` shows each one can fail.
* **Existing tests updated** for the new behavior:
  * `surface-lexer.test`: `/` is a token now.
  * `mutable-array-type.test`: `1.5` is a Float64, not a parse error.
  * `stdlib-namespaces.test`: the inventories, and NonFiniteFloat is
    builtin error 4, which moves LayoutLengthMismatch, NativeViewNull and
    NativeEditNull to 5-7.
  * `linux-syscall.test`: the qualified-native inventory.
  * `c-ffi.test`: the value-type message names `std::ffi::c::Double`.
  * `compilerpedia.test` and `main-cli.test`: the help-line examples, since
    `1.5` and `/` are no longer syntax errors.
* **Compilerpedia.**
  * New: `concept.floats` (replacing `capability.floats`), notes for `/`,
    `std::float64::from_int`, `std::float64::truncate` and the `float64` module.
  * Updated: the operator pages, `capability.integer-division` (matching
    the new TYPE message) and `concept.integers`.

## 14. Remaining limitations

* **Performance.** Every native Float64 result allocates a heap object.
  Unboxed float locals and registers would be an optimization in the
  existing scalar-replacement and raw-ABI style (RAW-INT-ABI.md); the
  semantics would not change.
* **Static reasoning** about floats goes no further than exact operands.
  There are no Float64 ranges, so a computation the compiler cannot decide
  must handle or declare `NonFiniteFloat`, as `float64.test` shows.
* **No Float64-to-String conversion.** Only a program's printed result
  shows a Float64.
* None about names any more: section 16.

## 15. Follow-up: NonFiniteFloat says which result it was

A handler can tell the three non-finite results apart: the error's payload
is `{result: NonFiniteResult}`. Section 1 shows the language behavior; this
is how it is built.

* **A builtin enum.** `NonFiniteResult` (`PositiveInfinity`,
  `NegativeInfinity`, `NotANumber`) is declared by the runtime
  (`core::native::declareEnum`, in `core/float.tcl`). Every compilation's
  enum registry has it (`hir::enums::Reset`), under its bare name, in every
  module, like the builtin errors. No program declares the name, as an
  enum, struct, trait, type or layout, and no HIR text prints it: a HIR read
  back gets it from its own registry. Its cases name results, not a type,
  so every future float width raises the same three.
* **Builtin error payloads.** `core::native::declareErrorPayload` gives a
  builtin error the fields of an anonymous struct, and
  `hir::errordecls::fields` answers for builtin errors from there. The
  whole payload machinery then applies unchanged: handler destructuring and
  binding, `fail NonFiniteFloat {result: ...}` in a program's own code, and
  MISSING-ERROR-PAYLOAD for a bare `fail NonFiniteFloat`. NonFiniteFloat is
  the only builtin error with a payload.
* **The Tcl backends** classify in `core::float`:
  * `Classify` maps a non-finite double to NaN, or to the infinity of its
    sign.
  * `DivisionByZero` maps a zero divisor to the dividend's sign, or to
    NotANumber for `0.0 / 0.0`.
  * `failDeclared` carries the payload struct to `core::native::invoke`,
    which checks that a payload-bearing builtin error comes with one.
* **The native backend** passes the class to
  `rt_float_nonfinite(vm, code)`:
  * Generated code computes it from the unboxed result: an `fcmp uno`, then
    the sign.
  * `float_apply` and `rt_f64_from_int` compute it in Rust
    (`non_finite_code`).
  * The runtime fills the payload slots like any declared error's: the case
    word and the anonymous shape are the program's own, found in its tables
    by name.
  * Native lowering declares that shape and enum in every program whose
    runtime may raise the error (`RuntimeRaises`, `PayloadTables`). So
    neither startup and neither image format changed.
* **Folding** still decides only the error's name: KNOWN-ERROR does not
  depend on which result it was.

## 16. Follow-up: names Tcl reads as numbers

Before this change, a program naming anything `nan`, `inf` or `infinity`,
in any letter case, broke the compiler:

* `fn nan(x): x + 1` failed with
  `domain error: argument not in valid range (ARITH DOMAIN)`;
* a struct `inf` became `Inf`.

Tcl's `expr` converts its result to a number when the result string looks
like one. The front end selected names with `expr {$c ? $name : ...}` in
hundreds of places, so the bug was in the compiler, not in Float64; Float64
only makes such names likelier. A one-element list of such a name has the
same problem.

The fix is a rule: the compiler never selects a value that may be a string
with `expr`'s `?:`.

* 218 `[expr {[dict exists D K] ? [dict get D K] : DEFAULT}]` became
  `[dict getdef D K DEFAULT]`.
* Every other ternary that could select a variable, a command result or an
  interpolation became an `if` (a statement where it was a whole `set` or
  `return`). `if` never converts its result.
* Ternaries over numbers, and over constant strings that do not read as
  numbers, stayed.
* Merging into main, which had gained fixed layout arrays meanwhile,
  brought 15 more such ternaries (core/binary.tcl, core/native.tcl,
  hir/format.tcl, hir/layouts.tcl, hir/resolve.tcl, native/lower.tcl),
  rewritten the same way; three mutants of layout arrays and native
  views quote them and were updated with them.
* The mutation harnesses' mutant texts were rewritten with the code they
  mutate; all 835 still apply. The 40 rewritten mutants, run by their
  harnesses, are all killed. One of them,
  `propagation-copies-affine-payload`, survived at first, and it also
  survived on the tree before this change: its only test reached no
  releasing re-raise. `ep-affine-propagation-releasing` (with its golden
  port) now kills it (ERROR-PAYLOADS.md, section 42).

`tests/numeric-looking-names.test` holds it:

* `nl-no-string-ternary` scans the compiler's sources for a ternary that
  may select a string.
* `nl-names-front-end` and `nl-names-backends` compile 27 programs with
  such names and with names of the same length and letter case that Tcl
  never reads as numbers. The programs name functions, parameters,
  locals, fields, structs, enums and cases, errors and payload fields,
  types, traits, refinements, coroutines, flags, layouts, modules and
  static blocks. The two outcomes must be the same: diagnostics, warnings,
  every backend's value and HIR interchange.
* Planting the old `expr` in two identity procedures makes 19 of the
  programs differ.
