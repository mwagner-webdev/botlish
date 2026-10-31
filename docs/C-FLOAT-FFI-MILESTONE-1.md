# C-FLOAT-FFI-MILESTONE-1.md

C `float` and C `double` across the whole C FFI: `std::ffi::c::Float` (new) and
`std::ffi::c::Double` (completed) as C representations wherever a C type is
written -- extern parameters and results, function pointer signatures,
pointees, layout fields, fixed arrays and union alternatives, over byte
storage and over native memory -- with one boundary rule set, the native
lowering of binary32 and binary64, the binding generator's float and double
(typedef chains confirmed by the compiler, `long double` diagnosed), and the
static decisions the compiler makes from the same rules.

> The rule this milestone keeps: **C ABI types describe foreign
> representations; Botlish numeric types describe Botlish values.**
> `std::ffi::c::Float` is C's binary32 *representation*; its values are
> `Float64`s. Botlish has no binary32 number, and this milestone adds none.

```
Float64          Botlish's finite binary64 number            (a value type)
std::ffi::c::Double   C's double: IEEE 754 binary64, carrier Float64  (a C type)
std::ffi::c::Float    C's float:  IEEE 754 binary32, carrier Float64  (a C type)
DecimalRounded   a Botlish guarantee about a Float64's decimal   (a value type,
                 never a C type: decay it with std::float64::from_decimal_rounded)
```

## 1. Final semantics

### std::ffi::c::Double

* C's `double`, IEEE 754 binary64 on every supported target, 8 bytes,
  aligned to 8, ABI class `f64` (core/cabi.tcl's `floatingModels` and
  `floatingFormats`; never read from the carrier).
* Written as a C type it is the C representation `{cfloat Double}`
  (hir/cabi.tcl's `FloatingType`); its values are Float64s
  (`hir::cabi::Carrier`).
* Outbound (a call's argument, a field written or stored): exact -- every
  Float64 is a finite binary64, and a Float64 is never negative zero.
* Inbound (a call's result, a field read from bytes or native memory): NaN
  (any payload, either sign) and the infinities fail with `NonFiniteFloat`
  {result: NotANumber | PositiveInfinity | NegativeInfinity}; negative zero
  becomes 0.0; every other value, subnormals included, is itself.
* Where a type of *Botlish values* is written (a Botlish function's
  parameter, a binding's annotation), `std::ffi::c::Double` keeps meaning
  `Float64`, as FLOAT64-MILESTONE-1.md made it (`hir::types::resolveNamed`).

### std::ffi::c::Float

* C's `float`, IEEE 754 binary32 on every supported target, 4 bytes,
  aligned to 4, ABI class `f32`; the C representation `{cfloat Float}`,
  carrier Float64.
* Outbound: the Float64 is rounded to the nearest binary32, ties to even.
  A result that would be an infinity -- every Float64 from 2^128 - 2^103
  (340282356779733661637539395458142568448) up in magnitude -- fails with
  `NonFiniteFloat` of the infinity's sign *before* C is called or a byte is
  written; it is never clamped to FLT_MAX. A Float64 that rounds to a zero
  of either sign is +0 (an ordinary finite result, never an error); a
  subnormal binary32 result is kept.
* Inbound: NaN and the infinities are `NonFiniteFloat` as for a double;
  negative zero is 0.0; every finite binary32 widens *exactly* to a Float64
  (section 3).
* Only a C type names it. Where a type of Botlish values is written it is
  a TYPE error with its own message ("std::ffi::c::Float is C's float, a foreign
  representation (IEEE 754 binary32) that only a C type names ... Botlish
  has no binary32 number, and a C float's value is a Float64 here (write
  Float64)"), and an imprint where values exist refuses it.

### Distinct types

`{cfloat Float}`, `{cfloat Double}` and `Float64` are three types:
`Ptr[std::ffi::c::Float]` is never a `Ptr[std::ffi::c::Double]` (pointee identity is
invariant), a function pointer of a float signature is never one of a double
signature, an array of floats strides 4 bytes and one of doubles 8, a layout
field's type is one or the other. They share a carrier and nothing else
(cfl-types-distinct, cfl-pointer-identities, cfl-function-pointer-identities,
the `float-double-collapsed` mutant).

### Why `std::ffi::c::Float` does not imply a Botlish Float32

A binary32 is how C *stores and passes* a number, not a number Botlish
computes with. Every finite binary32 is a binary64, so the one Float64 type
holds every value a C float can deliver, with its arithmetic, equality,
proofs and printing unchanged; the rounding happens exactly where C's bits
cross, as part of the declared foreign boundary, not as a numeric
coercion of the language. A program that needs binary32 *arithmetic* (its
rounding after every operation) needs a Float32 value type, which is a
language milestone of its own (section 12).

## 2. Carrier and representation in the compiler

The C type metadata answers each question separately (core/cabi.tcl, "The
C floating types"):

| question | where | Float | Double |
|---|---|---|---|
| C spelling | `floatings` | `float` | `double` |
| Botlish carrier | `floatings`, `hir::cabi::Carrier` | Float64 | Float64 |
| format | target row's `floating` model -> `floatingModels` | binary32 | binary64 |
| size | `floatingFormats` | 4 | 8 |
| alignment | `floatingModels` | 4 | 8 |
| ABI class | `floatingFormats` (`hir::foreign::AbiClass`, nir.rs `CAbi`) | f32 | f64 |
| load/store representation | layout descriptor `{f WIDTH ENDIAN}`, native encoding bit 64 | 4-byte LE | 8-byte LE |
| argument / return lowering | codegen::clif `c_signature`, `foreign_call` | F32 | F64 |
| admission rule | `core::cabi::AdmitBits`, runtime `admit_c_float` | binary32 | binary64 |
| outbound rule | `core::cabi::Narrow`, runtime `narrow_c_float`, clif `foreign_float_argument` | checked RNE | exact |

`core::cabi::floatingInfo NAME TARGET` returns all of it for one target;
every target row names its floating model (`floating IEEE`: Linux x86-64
and AArch64, macOS AArch64, Windows x86-64 MSVC and GNU, Windows AArch64).
Nothing computes a width or an alignment from the carrier: the carrier is
consulted only where a *value* is typed (an argument's admission, a
LayoutStruct field's type, a view read's result type).

The boundary rules are written once in Tcl (core/cabi.tcl: `Narrow`,
`AdmitBits`, `EncodeFloating`, `DecodeFloating`, used by the Tcl backends,
the static decisions and the reference codec) and once natively
(runtime/value.rs: `narrow_c_float`, `admit_c_float`, used by every native
layout operation; codegen::clif emits the same two checks inline for a
call, with the same constants). Section 9 lists where each runs.

## 3. Exact widening, checked narrowing

**Widening is exact.** A finite binary32 has a 24-bit significand and an
exponent in -149..127; binary64 has 53 bits and -1074..1023, so every finite
binary32 *is* a binary64 and the conversion (`fpromote`, Rust's `as f64`,
Tcl's `binary scan r`) never rounds. The property is relied on explicitly
and tested: `cfl-widening-exact` admits a sample of significands in every
binary32 exponent (both signs) and narrows them back to the same bits; the
Rust `c_float_widening_is_exact` does the same natively; `cfl-c-subnormals`
receives subnormal floats from C unchanged.

**Narrowing is checked round-to-nearest, ties to even.**

```
finite Float64
  -> IEEE binary32, round to nearest, ties to even
  -> negative zero made zero
  -> finite: pass / store it
  -> infinity: NonFiniteFloat {result: PositiveInfinity | NegativeInfinity}
```

The conversion is the IEEE one of each implementation -- Cranelift's
`fdemote`, Rust's `as f32`, and in Tcl `binary format r` behind an explicit
threshold check (Tcl clamps an overflow to FLT_MAX by itself, which is
exactly what the check prevents) -- never decimal text. It is checked
against an oracle that uses integer arithmetic on the bits only
(`cflOracleBinary32` in the Tcl suite, `oracle` in value.rs's tests,
`narrow32` in the fuzzer), and against C's own `(float)` conversion
(`cfl-c-narrowing-is-c`: C's `float_from_double` and the bits C receives
for a `float` argument agree with the oracle on ties, subnormal midpoints and
values near the threshold).

Boundaries pinned (`cfl-narrow-boundaries`, `c_float_narrow_boundaries`):
0.0; the smallest subnormal 2^-149; 2^-150 (a tie, to even: 0); 1.5 x 2^-149
(a tie, to even: 2 x 2^-149); the smallest normal; 1 + 2^-24 (a tie: 1.0);
1 + 3 x 2^-24 (a tie: 1 + 2^-22); FLT_MAX; the double just below the
threshold (FLT_MAX); the threshold itself and beyond (NonFiniteFloat of the
sign); -1e-50 (+0).

## 4. Non-finite values and negative zero

Botlish values stay finite. Every inbound path admits through the one rule:
a call's float or double result (native: `fpromote` for a float, then the
existing finiteness test against f64::MAX and `r + 0.0`), a layout field
read from bytes (`bin_decode`, `core::binary::DecodeRepr`), a field or an
element read from native memory (`rt_native_load`, the row helpers), a whole
copy (`std::binary::load`, `std::binary::parse`). NaN of any payload is NotANumber,
an infinity its sign (cfl-c-nonfinite-results, cfl-memory-nonfinite,
cfl-bytes-nonfinite, cfl-admit-bits). Negative zero entering is 0.0 (C's
`-0.0f` and `-0.0` results, memory holding 0x80000000); a Botlish zero
leaving is +0 (C's `signbit` reports 0), and a tiny negative Float64 rounded
to a float is +0, never C's -0.0f (`n + 0.0` in codegen, `(x as f32) + 0.0`
natively, Tcl's `$x + 0.0`).

## 5. Pointers, loads and stores

`std::ffi::c::Ptr[std::ffi::c::Float]` and `std::ffi::c::Ptr[std::ffi::c::Double]` are ordinary
C pointer types (hir/cabi.tcl's `PointeeProblem` admits a C floating
pointee): affine, nominal by pointee, no arithmetic or dereference;
`null[T]()`, `clone`, `erase` and `retype[T]` imprint them like any pointee.
C functions take and return them (`mutate_float`, `dot` in the fixture).

Botlish reads and writes the memory they address the way it reads any native
memory: through a layout's view and edit (NATIVE-LAYOUT-VIEWS.md,
NATIVE-LAYOUT-WRITES.md). A float buffer is a layout of `array N of
std::ffi::c::Float`; `std::binary::element(v.xs, i)` loads 4 bytes and admits them
(widened exactly), `std::binary::store_element(e.xs, i, x)` narrows and stores 4
bytes -- one access, no copy of the buffer (cfl-arrays-and-pointers: C reads
every element Botlish stored at its own 4-byte place, Botlish reads what C's
`mutate_float` wrote). A field read through a view (`v.a`) is fallible for a
float or a double (NaN in memory); since a projection cannot carry a handler
of its own, such a read stands in a function that declares NonFiniteFloat
(the completion analysis charges it, and the affine release on its error
edge follows: hir/completions.tcl `CheckFloatReadLegality`, hir/affine.tcl
`FloatRead`), or the record is copied with `std::binary::load`, a call a handler
may follow. A store whose Float64 overflows writes nothing.

## 6. Layouts, structs, arrays, unions

A layout field may be `std::ffi::c::Float` (4 bytes) or `std::ffi::c::Double` (8),
its offset, bounds and overlap checked with those widths
(cfl-layout-declarations); `Float64` and a DecimalRounded type are no field
types (LAYOUT-FIELD-TYPE, with a message naming the two C types). The
representation is `{kind float format F width W endian little ctype C type
Float64}` (hir/layouts.tcl's `FloatingRepr`), the descriptor word
`{f WIDTH ENDIAN}`, the native encoding word's bit 64. A LayoutStruct's field
of a C floating type holds a Float64.

The brief's struct is pinned against the host C compiler
(cfl-layout-matches-c): `struct MixedFloats { uint8_t tag; float a; double
b; float c; }` is 24 bytes, aligned to 8, offsets 0, 4, 8, 16, on every
supported target, as `core::cabi::floatingInfo` states; C writes every field
with its own stores and Botlish reads them through a view (a float widened
exactly), Botlish stores through an edit and C reads the bits
(cfl-views-and-edits). Fixed arrays stride the C type's width
(FIXED-LAYOUT-ARRAYS.md; never the carrier's: the `stride-carrier-width`
mutant). A union's float alternative overlays the low 4 bytes of its double
alternative, and a store through it writes those 4 bytes alone (cfl-unions;
LAYOUT-UNIONS.md). Over byte storage, `std::binary::parse`, `std::binary::read`,
`std::binary::write`, `std::binary::emit` and the whole-array writes apply the same
rules on all four backends (cfl-bytes-parse, cfl-bytes-emit,
cfl-bytes-nonfinite; ported to tests/golden/c-float-ffi.bot).

**Errors are charged per call.** The layout natives register
NonFiniteFloat (core/binary.tcl), but a call is charged it only when it can
fail through a C floating value (hir/layouts.tcl's `CallErrors`,
`FloatErrors`): a read of a float or a double, a write or emit of a float;
never a write of a double, never an operation of a layout without floats.
A float-free program's calls carry exactly the errors they carried before
this milestone (cfl-layout-errors; the native-edit, layout-unions and
layout-arrays registration tests pin the registrations).

## 7. Direct calls

`extern c fn f(a: std::ffi::c::Float, b: std::ffi::c::Double) -> std::ffi::c::Float`
registers ABI classes `f32 f64 -> f32` (hir/foreign.tcl; NIR's foreign
table: `foreign 0 "f" params="f32 f64" result=f32`). A call with a float
parameter or a floating result declares NonFiniteFloat (a double parameter
alone does not: it is exact). Natively the call is one direct call through
the target's C signature (`(f32, f64) -> f32 system_v`); each float argument
is `fdemote`, `+ 0.0`, `|n| <= FLT_MAX` or NonFiniteFloat (`rt_float_nonfinite`)
before the call; a float result is `fpromote`d and admitted like a double's,
then boxed once (`rt_float_new`: no intermediate object, cfl-nir-clif). C's
own side effect proves an overflowing argument never reaches C
(cfl-counted-before-call).

**Static decisions** use the same rule (hir/completions.tcl's
`ExternNarrowing`, `core::cabi::Narrow`): a float argument whose value the
analysis knows exactly is narrowed while compiling -- an overflow makes the
call KNOWN-ERROR (handled or not), a fit removes the argument's obligation
(a call with no floating result then needs no handler). Values the analysis
cannot see fail at run time on every backend with exactly the decided
outcome (cfl-decided-narrowing, cfl-decided-equals-run: 3.4028235677973362e38
is FLT_MAX in both, 3.4028235677973366e38 NonFiniteFloat in both). A layout
write of an exactly known float is decided the same way
(`hir::layouts::WrittenFloatFormat`).

**Register exhaustion** (cfl-c-register-exhaustion, against the real C ABI on
the host): twelve floats past every target's eight floating-point argument
registers; twenty interleaved floats, doubles and integers of every width,
each class in its own registers before the stack; sixteen floats with a
float result; nine floats where the ninth is read back as bits from its stack
slot. Every argument arrives as exactly the value or bits it was.

## 8. Indirect calls and callbacks

Botlish has **no indirect call** of a C function pointer and **no callbacks**
(Botlish code called from C): C-FFI.md section 26 lists both as not built,
and this milestone does not build them. What exists is complete for floats:

* `std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Float, std::ffi::c::Double], return:
  std::ffi::c::Double}]` is a C function pointer type whose signature keeps its C
  types (`hir::cabi::ResolveCType` resolves a function type argument-wise);
  one of a float signature is never one of a double signature.
* C hands such a pointer out, Botlish holds it (affine), passes it back, and
  C calls it: `cfl-function-pointers` -- `cff_halver()` then
  `cff_apply_float(h, 3.0)` is 1.5, `cff_apply_float(h, 1.0e-45)` is 0.0
  (2^-149 halved is a tie, to even), `cff_apply_double(squarer(), 1.5)` and
  the mixed `cff_apply_mixed(scaler(), 0.1, 10.0)` -- every argument narrowed
  and every result admitted by the direct call's rules, since the calls
  Botlish makes are direct calls of C functions taking the pointer.
* When indirect calls or callbacks come, their arguments and results are
  C floating values of the signature's types, crossing by the same
  `Narrow`/`Admit` (codegen's `foreign_float_argument` and the result
  admission are per value, not per call kind).

## 9. Where each rule runs

| path | admit | narrow |
|---|---|---|
| extern call, native | clif `foreign_call` result: fpromote, finite test, `+0.0` | clif `foreign_float_argument`: fdemote, `+0.0`, `<= FLT_MAX` |
| extern call, Tcl backends | -- (NATIVE-ONLY) | `core::cabi::ExternImpl`: `NarrowValue` per f32 argument, then NATIVE-ONLY |
| bytes: parse, read, load, element (native) | runtime `bin_decode` -> `admit_c_float` | -- |
| bytes: write, emit, whole arrays (native) | -- | runtime `bin_encode` -> `narrow_c_float` |
| native memory: view, element, load, edit store | runtime `rt_native_load`, row helpers -> `admit_c_float` | `rt_native_store`, row helpers -> `narrow_c_float` |
| bytes, Tcl backends (interp; the Tcl compiler defers float layouts to the reference codec) | `core::binary::DecodeRepr` -> `DecodeFloating` | `core::binary::FloatPiece` -> `EncodeFloating` |
| compile time | -- | `ExternNarrowing`, `WrittenFloatFormat` -> `core::cabi::Narrow` |

The Tcl backends still refuse a C call (NATIVE-ONLY) and have no native
memory (a view of a non-null pointer is NATIVE-ONLY), but they apply the
narrowing before refusing, so an overflowing argument is NonFiniteFloat on
every backend (cfl-tcl-backends), and byte-storage layouts run there exactly
as natively.

## 10. NIR and code generation

No new NIR instruction was needed; the foreign representations are explicit
where NIR already carries a representation:

* `CAbi::F32` (`f32`) beside `F64` in the foreign table (nir.rs), with
  `floating()`; a foreign call may fail when its result is F32 or F64, when
  any parameter is F32, or when its result is a pointer or a Bool (as
  before).
* The layout encoding word (`binload`, `binstore`, `nativeload`,
  `nativestore`, the row operations) gains bit 64, "a C floating value of
  this width" (`LayoutEncoding` in native/lower.tcl; ops.rs's `BinEncoding`
  with `float: Option<CFloatFormat>`): a 4-byte floating encoding is
  binary32, an 8-byte one binary64; a signed floating word is malformed.
* Codegen (codegen/clif.rs): `c_type` maps F32 to Cranelift's F32;
  `c_signature` gives a float or a double no extension attribute and leaves
  the integer-register count alone (it is a floating-point register's);
  `foreign_call` narrows each F32 argument and admits each floating result as
  above. Memory loads and stores of floats go through the runtime helpers
  every layout field already uses (one helper call per field): binary32 is
  an encoding of those helpers, with its own 4-byte access, never an f64
  memory operation.

The semantic Float64 operations are untouched: the conversions are
foreign-representation operations at the boundary only, and the low-level
binary32 pieces (`CFloatFormat::Binary32`, `fdemote`/`fpromote` around a
call, the 4-byte encoding) are what a future Float32 would reuse.

## 11. Target ABI behavior

The C convention is the target triple's (`codegen::target::c_call_conv`);
Botlish decides only which Cranelift type each parameter has (F32, F64) and
that a floating parameter carries no extension attribute.

* **Linux x86-64 (SysV).** Floats and doubles take xmm0-xmm7 in order,
  whatever the integers between them; past eight, each stack argument has an
  8-byte slot, a float stored with `movss` (4 bytes). Checked from
  Cranelift's own disassembly (`c_float_sysv_xmm_exhaustion`: ten floating
  arguments among integers, the ninth and tenth at 0(%rsp) and 8(%rsp) by
  `movss`, a float result widened by `cvtss2sd`), and against real C on the
  host (cfl-c-register-exhaustion and every cfloatFixture test).
* **Linux AArch64 (AAPCS64).** Floating arguments take v0-v7 (s for a
  float, d for a double), counted apart from the integers; past them each
  stack argument has an 8-byte slot (`c_float_aapcs64_stack_slots`: the
  ninth and tenth floats stored as `str s` at [sp] and [sp, #8]; a float
  result widened by `fcvt d`).
* **macOS AArch64 (Apple).** The same registers; past them Apple packs a
  float into 4 bytes (`c_float_apple_floats_packed`: [sp] and [sp, #4]). The
  `c_extended_parameters` exception (Apple stack-passed *integer* arguments
  carry no extension attribute) never applies to a floating parameter, and
  the eight it counts are integer-register parameters only, as before
  (MACOS-AARCH64-MILESTONE-6.md).
* **Windows x86-64 (Microsoft x64).** Four positional registers shared by
  every kind: a float in the first position is xmm0, an int in the second
  rdx, a double in the third xmm2, a long long in the fourth r9; the fifth
  argument (a float) at 32(%rsp), past the shadow space, by `movss`, the
  sixth (a double) at 40(%rsp) by `movsd` (`c_float_win64_positions`).
  This is the lowering for the windows-x86_64 and windows-x86_64-gnu targets;
  no Windows binary was run.

The AArch64 checks run on AArch64 hosts (a Cranelift build has its host's
backend only); they were run here under qemu-user (an
aarch64-unknown-linux-gnu build of the driver's tests), and run natively in
CI's arm64 workflow and the macOS smoke job.

**Variadic C calls** (VARIADICS-VERTICAL-SLICE-1.md, which landed on main
alongside this milestone) take C floats among their *fixed* parameters
(SDL3's `SDL_RenderDebugTextFormat(renderer, float x, float y, fmt, ...)`
is now bound). A fixed float takes a floating-point register exactly as a
fixed double does, so the per-call signature counts it with the doubles:

* System V's `%al` bound counts F32 parameters as well as F64 ones
  (`vector_registers`; `ffi_sysv_variadic_vector_count_includes_fixed_floats`).
  No GCC-compiled callee shows an undercount (its prologue saves every
  vector register whenever `%al` is nonzero), so only the Rust test kills
  the `va-fixed-floats-not-vector-registers` mutant.
* Apple's padding counts a fixed float as a v register, not an x register
  (`c_call_signature`'s `fixed_floatings`;
  `ffi_apple_variadic_padding_after_fixed_floats`). Counted as an integer,
  it would leave x registers unpadded and pad the v registers past the
  stack, moving every trailing argument (the
  `va-apple-fixed-floats-counted-as-integers` mutant).
* A *trailing* argument is never a C float: no Botlish value is one (a
  Float64 is passed as a double, `hir::cabi::VariadicArgument`), and C
  promotes a float to a double anyway. NIR's `varargs=` rejects `f32` as
  either class (`ffi_c_float_never_a_vararg_class`;
  `va-float-vararg-parses`).

`cfl-c-variadic-fixed-floats` calls such a function against real C on the
host: two fixed floats (one narrowed), then nine int and double pairs that
`va_arg` reads back past the registers. The binding generator's fuzzer
draws fixed C floats and doubles in variadic prototypes (never a float as
the last fixed parameter, whose promoted type `va_start` requires) and
trailing doubles from Float64s.

## 12. The binding generator

`tools/c-bindgen` maps C `float` to `std::ffi::c::Float` and `double` to
`std::ffi::c::Double` wherever it maps a C scalar: parameters, results, pointees
(`float *` is `Ptr[std::ffi::c::Float]`), function pointer signatures and
callback typedefs, record fields, fixed array elements and union
alternatives (model.tcl's `Floating`, records.tcl's float branch).

* **Typedef chains** are the compiler's answer, as for integers: a typedef
  whose declaration chain ends in a floating type is confirmed by a
  `_Generic` probe of the typedef itself (codes 13 float, 14 double, 15 long
  double) and by `TypedefAbiProblem`; `bgf_real32` (a typedef of a typedef
  of `float`) is `std::ffi::c::Float`.
* **Verification**: layouts-check.c asserts each floating field's C type
  (`BOTLISH_FLOATING`: `__builtin_classify_type` is 8, the width, and
  `__builtin_types_compatible_p` with float or double), the runtime oracle
  (oracle.tcl) writes and reads float fields with C's own stores and loads
  (a float leaf, NaN-free values, an unselected union alternative never
  read), and generation probes every float array's extent.
* **`long double`** and the other floating types (`_Float16`, `__float128`,
  `__bf16`, `__ibm128`) stay unsupported, each with its blocker:
  `long-double` ("its representation is the target's (binary64, x87
  extended precision or binary128), and neither the FFI nor Botlish has a
  type of it"), `unsupported-floating`. A floating macro constant is
  `floating-constant` ("the generator binds integer constants only").
* **Fixture** (tools/c-bindgen/fixture): float and double functions, a
  float typedef chain, a float callback, a function returning a function
  pointer, `dot(const float *, const double *, size_t)`, records of floats
  and doubles (`bgf_mixed_floats`, `bgf_mixed_real`, `bgf_samples` with
  `float xs[4]` and `double ys[2][2]`), a union of a float and a double, an
  anonymous union with a float, and the former float blockers rewritten as
  `long double` ones so the unsupported paths stay covered.

**Regenerated bindings, audited** (every target of every profile; the
committed tree before this milestone was first regenerated unchanged, byte
for byte, so every difference is this milestone's):

| binding (linux-x86_64; win32 windows-x86_64-gnu) | bound before -> after | layouts before -> after |
|---|---|---|
| SDL3 | 1102 -> 1217 (+115: every float/double function) | 85 -> 103 (SDL_FRect, SDL_FPoint, SDL_FColor, SDL_Vertex, ...) |
| Tcl | 820 -> 829 (+9 double functions) | 34 -> 36 (Tcl_Obj: its internalRep's double) |
| Tcl stubs | 747 -> 756 | 34 -> 36 |
| BoringSSL | 3977 -> 3978 (RAND_add) | 118 -> 119 (rand_meth_st) |
| Win32 | 3295 -> 3304 | 996 -> 1015 |
| fixture | 39 -> 47 | -- |

Main's variadic C calls (VARIADICS-VERTICAL-SLICE-1.md), merged after these
counts were taken, bind variadic functions too. With both, every binding
was regenerated again: SDL3 1233 bound, Tcl 840, Tcl stubs 756, BoringSSL
3983, Win32 3307, the fixture 50. Some functions need both features, such
as SDL3's `SDL_RenderDebugTextFormat`, which has fixed floats and then
`...` (section 11).

The remaining floating blockers in the committed bindings are 11 floating
macro constants (SDL3 6, Win32 5) and none of `long double`; the fixture's
long double functions and records are its only `long-double` rows. The
runtime oracle (cb-tcl-layouts, cb-sdl3-layouts, cb-layout-oracle-fixture)
agrees with C on every newly emitted layout on both native backends.

## 13. DecimalRounded

DecimalRounded is not a C ABI type and is never passed implicitly: a
`DecimalRounded{minDecimalsPreserved: 2}` argument where `std::ffi::c::Float` or
`std::ffi::c::Double` is declared is a TYPE error ("a DecimalRounded value is no
Float64, and nothing converts one implicitly (std::float64::from_decimal_rounded
decays one ...)"), `std::float64::from_decimal_rounded(d)` passes; a C result
assigned where a DecimalRounded is declared is a TYPE error (a Float64 is no
DecimalRounded value); a DecimalRounded type is no extern result, pointee or
layout field (cfl-decimal-rounded, cfl-value-positions,
cfl-layout-declarations).

## 14. Tests, fuzzing and mutation

* **tests/c-float-ffi.test** (new, 37 tests): the type model, the facts per
  target, value positions, pointer and function pointer identities, ABI
  classes, the boundary procedures against the integer oracle (boundaries,
  6000 sampled doubles, admission, exact widening), static decisions and
  their agreement with runs, the Tcl backends, and against the C fixture
  (tests/cffi/cfloat-fixture.c, the brief's functions and more): values both
  ways, C's own conversion, non-finite results, subnormals, register
  exhaustion, MixedFloats against C, views and edits, non-finite memory,
  arrays and pointers, unions, function pointers, a variadic function with
  fixed floats; byte layouts on all four
  backends; declaration diagnostics; per-call error charging; HIR text,
  interchange and isolation; NIR and CLIF; a standalone executable; GC
  stress; DecimalRounded.
* **tests/golden/c-float-ffi.bot** (new): the three byte-storage tests,
  ported, on all four backends (the manifest's fragment rows); perturbation
  shows each can fail.
* **Rust**: runtime/value.rs `c_float_*` (the narrowing against an integer
  oracle on 20,000 doubles, the boundaries, admission, exact widening);
  codegen/clif.rs `c_float_sysv_xmm_exhaustion`, `c_float_win64_positions`,
  `ffi_sysv_variadic_vector_count_includes_fixed_floats` (x86-64 hosts),
  `c_float_aapcs64_stack_slots`, `c_float_apple_floats_packed`,
  `ffi_apple_variadic_padding_after_fixed_floats` (AArch64 hosts); nir.rs
  `ffi_c_float_never_a_vararg_class`.
* **tests/c-bindgen.test**: cb-fixture-floats, cb-layout-floats (new), and
  every expectation the bound floats changed (section 12).
* **audit/c-float-ffi/tools/fuzz.tcl** (new): random C signatures of floats,
  doubles and integers (up to fourteen parameters, a result whose bits the
  call names: NaN payloads, infinities, -0, subnormals) compiled as real C
  and called on both native backends, and random float layouts over bytes
  on all four backends, each against its own integer model (since
  RAW-C-FLOAT-FFI-MILESTONE-1.md it also draws raw parameters, results and
  fields by default; `-raw 0` draws exactly this milestone's programs, the
  seeds of section 16 among them). The C binding
  generator's fuzzers model floats now too: audit/c-bindgen/tools/fuzz.tcl
  draws float and double parameters, results and typedef chains (C reports
  their bits), layout-fuzz.tcl float and double fields, arrays and union
  alternatives, and both draw `long double` as the unsupported shape.
* **audit/c-float-ffi/tools/mutate.tcl** (new, mutants.txt): the brief's
  mutants -- f32 laid out as f64, an f32 load without widening (native and
  Tcl), unchecked narrowing (the call's and the runtime's), overflow clamped
  (native and Tcl), NaN or infinity admitted (a call's result, native
  memory, Tcl bytes), negative zero preserved (a result, an argument, a
  store, Tcl), Float and Double collapsed, a stride of the carrier's width --
  and further ones: an f32 parameter in the f64 class, a float parameter
  declaring no NonFiniteFloat, a static decision of its own threshold,
  uncharged float writes, infallible projections, the codec's float encoding
  dropped (native) or made binary64 (Tcl), the Tcl backends' narrowing
  skipped. The bindgen swaps are audit/c-bindgen/tools/mutants.txt's:
  `bindgen-float-as-double`, `bindgen-double-as-float`,
  `bindgen-long-double-as-double`, `bindgen-float-width-carrier`, and the
  retargeted `float-as-int` and `layout-float-as-integer`.

Results are in section 16.

## 15. Remaining C floating limitations

(RAW-C-FLOAT-FFI-MILESTONE-1.md adds `std::ffi::c::RawFloat` and
`std::ffi::c::RawDouble` beside these types: the same C facts, every bit
pattern carried, admission into Float64 an explicit step. Nothing below
changed for `std::ffi::c::Float` and `std::ffi::c::Double`.)

* No `long double` (any target), no `_Float16`/`__float128`/`_Complex`, no
  floating macro constants in bindings.
* No indirect call of an `FnPtr` and no callbacks into Botlish (an existing
  FFI limitation, section 8).
* No Botlish binary32 value: binary32 arithmetic (rounding after each
  operation) is not expressible; a program rounds explicitly only by
  crossing a C float boundary.
* A float field read through a view cannot carry its own handler (a
  projection has none); read it in a function that declares NonFiniteFloat.
* Allocation-site reports (`--alloc`) label a native float field load's
  allocation with the BigInt kind the load site already had (the encoding
  word is a run-time operand of the one helper); instrumentation only.
* Windows: lowered and checked from disassembly, never run.

**Places where std::ffi::c::Float is treated as its carrier's representation.**
The audit (every use of the carrier: `hir::cabi::Carrier` and every
`cfloat` case) found none that is a representation: the carrier types
*values* only -- an argument's admissibility, a LayoutStruct field's type, a
view read's result, the Tcl codec's value -- and every width, alignment,
stride, ABI class, load, store and conversion comes from the C type. One
dependency is recorded rather than removed: a layout descriptor word
`{f WIDTH ENDIAN}` and the native encoding word name a floating field's
*width*, and the format is read from it (`core::cabi::formatOfWidth`, 4
binary32, 8 binary64) -- sound for the IEEE model every target has, and the
place a format of a repeated width (an 8-byte `long double` beside binary64)
would put the format into the word.

## 16. Results

Linux x86-64 (this container):

| check | result |
|---|---|
| tests/c-float-ffi.test | 36 tests, all passed (the C fixture built and linked with rustc) |
| tests/golden/c-float-ffi.bot (4 backends) | 3/3 on each backend; perturbation: 3 inverted, 3 altered, all failed as required |
| tests/c-bindgen.test | 79 tests: 73 passed, 6 skipped (the BoringSSL and SDL3 library constraints), 0 failed; `tools/c-bindgen.tcl check PROFILE -target committed`: every profile and target current |
| Rust: `--lib c_float`, `--bin botlish-native c_float` | 5 and 2 passed |
| audit/c-float-ffi/tools/fuzz.tcl | seeds 2, 3, 7, 17, 41 (10 programs each: 80 calls, 40 layouts) and seed 5 under GC stress: 0 disagreements |
| audit/c-float-ffi/tools/mutate.tcl | 24 mutants, 24 killed |
| audit/c-bindgen fuzz.tcl, layout-fuzz.tcl | fuzz.tcl seeds 3, 17, 41 and seed 5 under GC stress: 0 disagreements; layout-fuzz.tcl seeds 2, 17, 41, seed 7 under GC stress, and linux-aarch64, macos-aarch64, windows-x86_64-gnu targets: 0 disagreements |
| Rust, whole (`--lib`, `--bin botlish-native`) | 267 and 43 passed |
| tests/local.tcl | 202 Tcl test files on interp and compile (6383 and 6378 passed, 12 and 17 skipped, 2128 golden duplicates skipped) and 100 golden suites on all four backends (4938, 4938, 4846 and 4948 tests passed); its one failure, compilerpedia.test's check of the generated stdlib topic (stale after stdlib/ffi/c.bot's header changed), fixed by regenerating it: compilerpedia.test 39 passed |
| warning gate (audit/refactor/tools/gate.tcl) | passed: the observed warnings are exactly the manifest |
| HIR interchange (roundtrip.tcl) | `-via interchange` and `-via cache` over c-float-ffi.bot, binary-layout.bot, layout-unions.bot, layout-arrays.bot, and `-via interchange` over the default twelve suites: 0 differ |
| compilation isolation (interleave.tcl) | the four suites above and the default twelve: 0 differ |
| other areas' fuzzers (seeds 3 and 17) | c-ffi, binary-layout, native-view, native-edit, layout-arrays, layout-unions: 0 disagreements; c-abi-types: 2 and 8, every one a program compiled for another target that the native driver refuses (NATIVE TARGET) -- identical on the tree before this milestone, unrelated to it |
| the existing mutants whose text this milestone retargeted | binary-layout 4, native-edit 5, native-view 2, layout-arrays 2, c-ffi 1 (and 1 macOS-only, skipped), target-model 2, error-payloads 1, c-bindgen 7: all applied and killed |

Linux AArch64: the Rust boundary tests (`--lib c_float`, 5 passed) and the
AArch64 lowering tests (`c_float_aapcs64_stack_slots`,
`c_float_apple_floats_packed`, and the existing `ffi_apple_*`) passed under
qemu-aarch64 from an aarch64-unknown-linux-gnu build. CI's tests-arm64.yml
on ubuntu-24.04-arm (run 39481296400, commit a5ea3c3): the Tcl suite on
interp and compile, its cranelift and cranelift-generic coverage, the golden
suites (four shards, beside their Tcl originals) and the native Rust unit
tests, plain and under GC stress, all passed -- c-float-ffi.test's C fixture,
register exhaustion and lowering tests among them, natively; and the whole
Tcl suite under GC stress (`BOTLISH_NATIVE_GC_STRESS=1`) passed.

Linux x86-64 CI (tests.yml, run 39481292379, commit a5ea3c3): every job
passed -- the Tcl suite on interp and compile, cranelift and
cranelift-generic coverage, the golden shards, the stub-linked executables,
the native Rust unit tests, the method-call filter audit, the warning gate
(its GC-stress job runs on main only). c-bindgen.yml (run 39478477382) and
static-decisions.yml (run 39478481243, the batched and the sequential
scheduler on every golden suite; commit 5ff1b02, whose front end a5ea3c3
leaves unchanged) passed.

macOS AArch64: C calls run there (MACOS-AARCH64-MILESTONE-6.md); the macOS
workflow runs on every push (smoke: the native build, its Rust tests, the
platform facts; acceptance: every test file not in `notYet`, c-float-ffi.test
included): run 39481243115 on commit a5ea3c3 passed.

Windows x86-64: compile and lowering only (section 11; the MinGW-w64
binding generated and verified as before); no run.

**After merging main's variadic C calls** (Linux x86-64, this container):

| check | result |
|---|---|
| tests/local.tcl | 204 Tcl test files on interp and compile (6525 and 6520 passed, 12 and 17 skipped, 2156 golden duplicates skipped) and 101 golden suites on all four backends (4977, 4977, 4885 and 4987 tests passed), 0 failed |
| tests/c-float-ffi.test, c-ffi.test, c-abi-types.test, c-bindgen.test | 37/37; 109 passed, 3 skipped; 73/73; 77 passed, 6 skipped (BoringSSL and SDL3 libraries), 0 failed |
| `tools/c-bindgen.tcl check PROFILE -target committed` | every profile and target current |
| Rust (`--lib`, `--bin botlish-native`) | 272 and 53 passed; under qemu-aarch64, the `ffi_` and `c_float` lowering tests (14, the Apple padding after fixed floats among them) passed |
| audit/c-ffi/tools/mutate.tcl | `va-al-zero`, `va-fixed-floats-not-vector-registers`, `va-float-vararg-parses` killed; `va-apple-fixed-floats-counted-as-integers` (AArch64 hosts) fails `ffi_apple_variadic_padding_after_fixed_floats` under qemu; every mutant of every harness still applies |
| fuzzers | audit/c-bindgen fuzz.tcl seeds 1-4 (33 variadic prototypes, 130 trailing arguments), audit/c-float-ffi fuzz.tcl seed 3, audit/c-ffi fuzz.tcl seed 3 (35 variadic calls): 0 disagreements |
| warning gate, `tools/compilerpedia.tcl check` | passed; 0 problems |

## 17. Seams for later

**Float32.** `std::ffi::c::Float`'s carrier is one table entry (core/cabi.tcl's
`floatings`: `carrier Float64`), read through `hir::cabi::Carrier`; the C
type, its format, its ABI class, its layout representation and the
bindgen's mapping never mention the carrier. A first-class Float32 would
change that entry (and the value-position rule that `std::ffi::c::Float` is a
TYPE error), and the boundary would become exact for it: `Narrow` binary32
of a Float32 is the identity, `Admit` keeps the finiteness and zero rules.
The low-level pieces it would reuse exist: the F32 Cranelift type at calls,
the 4-byte encoding, `CFloatFormat::Binary32`.

**long double.** A target row names its floating *model*
(`floatingModels`), and a model maps each C floating type to a format and
an alignment; `long double` is a new `floatings` row and a format per model
-- binary128 (AArch64 Linux), x87 extended in 16 bytes (x86-64 SysV),
binary64 (Apple AArch64, MSVC) -- with its own ABI class (a binary128 or x87
value travels differently from a double). The bindgen already classifies it
(code 15) and reports it; the descriptor word would carry the format
explicitly (section 15).

## 18. What to run when changing this

Files: core/cabi.tcl (the floating tables and the boundary procedures),
hir/cabi.tcl, hir/types.tcl's `cfloat` cases, hir/read.tcl, hir/imprint.tcl,
hir/foreign.tcl, hir/borrow.tcl, hir/completions.tcl (`ExternNarrowing`,
`LayoutCallErrors`, the projection rule), hir/affine.tcl (`FloatRead`),
hir/layouts.tcl (the float representation, `CallErrors`, `FloatErrors`,
`WrittenFloatFormat`, `ProjectionReadsFloat`), core/binary.tcl,
core/native.tcl, compiler/compiler.tcl, native/lower.tcl
(`LayoutEncoding`, the rows), native/src/nir.rs, codegen/clif.rs,
runtime/value.rs, runtime/ops.rs, runtime/nview.rs, tools/c-bindgen/.

Run `tests/c-float-ffi.test` (its fixture needs `cc`), `tclsh9.0
tests/local.tcl tests/golden/c-float-ffi.bot`, `tests/c-ffi.test`,
`tests/c-abi-types.test`, `tests/float64.test`, `tests/binary-layout.test`,
`tests/native-view.test`, `tests/native-edit.test`,
`tests/layout-arrays.test`, `tests/layout-unions.test`,
`audit/c-float-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/c-float-ffi/tools/mutate.tcl` (every mutant must still apply and
be killed), `cargo test --release --manifest-path native/Cargo.toml --lib
c_float` and `--bin botlish-native c_float` (the AArch64 ones on an AArch64
host or under qemu), and for the generator the C binding generator's checks
(AGENTS.md).
