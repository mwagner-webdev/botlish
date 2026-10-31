# RAW-C-FLOAT-FFI-MILESTONE-1.md

Lossless C floating-point values: `std::ffi::c::RawFloat` and
`std::ffi::c::RawDouble`, explicit representations of C's IEEE 754 binary32
and binary64 that carry every bit pattern -- NaN of any sign and payload,
quiet or signaling, both infinities, negative zero, subnormals -- through
every place a C floating value crosses, with admission into Botlish's
finite `Float64` an explicit, checked step. Validated against the real
Raven GUI library through its generated binding.

> The rule this milestone keeps: **foreign representations may express
> values outside Botlish's ordinary value domains. Carrying those
> representations is permitted; admitting them into a more restrictive
> Botlish domain requires an explicit, checked conversion.**

```
Float64                Botlish's finite binary64 number           (a value type)
std::ffi::c::Double    C's double, carrier Float64: admitted       (a C type)
std::ffi::c::Float     C's float, carrier Float64: admitted        (a C type)
std::ffi::c::RawDouble C's double, every binary64 bit pattern      (a C type and a value type)
std::ffi::c::RawFloat  C's float, every binary32 bit pattern       (a C type and a value type)
```

`std::ffi::c::Float` and `std::ffi::c::Double` are unchanged
(C-FLOAT-FFI-MILESTONE-1.md): every existing program compiles and runs
exactly as before (section 8).

## Contents

1. [Semantics and public API](#1-semantics-and-public-api)
2. [Representation in the compiler and the runtimes](#2-representation-in-the-compiler-and-the-runtimes)
3. [Conversions and errors](#3-conversions-and-errors)
4. [C ABI and bit preservation](#4-c-abi-and-bit-preservation)
5. [Raven: the generated binding and the wrapper](#5-raven-the-generated-binding-and-the-wrapper)
6. [Raven integration results](#6-raven-integration-results)
7. [Tests](#7-tests)
8. [Compatibility of the finite C types](#8-compatibility-of-the-finite-c-types)
9. [Limitations, and the callback milestone](#9-limitations-and-the-callback-milestone)
10. [What to run when changing this](#10-what-to-run-when-changing-this)

## 1. Semantics and public API

### The types

`std::ffi::c::RawFloat` is C's `float` and `std::ffi::c::RawDouble` C's
`double`, held exactly as C holds them. They are importable with
`std::ffi::c` (intrinsic types of the namespace, like `Float` and `Double`)
and written wherever a type is written:

* as C types: an `extern c fn`'s parameters and result, a function
  pointer's signature (`std::ffi::c::FnPtr[Fn{args: [std::ffi::c::RawFloat],
  return: std::ffi::c::RawDouble}]`), a pointee
  (`std::ffi::c::Ptr[std::ffi::c::RawFloat]`), a layout field, a fixed
  array's element, a union alternative;
* as types of values: a Botlish function's parameter or result, a List's
  element, a struct field -- unlike `std::ffi::c::Float`, whose values are
  `Float64`s and which is a TYPE error where a type of values is written.

Each has exactly its finite counterpart's C facts on every target: the
same format (binary32, binary64), size, alignment and register class
(`core::cabi::floatingInfo RawFloat T` equals `floatingInfo Float T` in
every C fact, `rcf-types`). So a raw position and a finite one are the
same machine signature; only what the Botlish side receives differs.

They are distinct types: `RawFloat` is not `Float`, `RawDouble` not
`Double`, neither is `Float64`, and `RawFloat` is not `RawDouble`.
`Ptr[RawFloat]` is no `Ptr[Float]`, and a function pointer of a raw
signature no function pointer of a finite one (`rcf-no-implicit-conversion`).
The same register class is no type identity.

### What a raw value is not

A raw value is no number. It has:

* no arithmetic and no ordering: `x + 1.0`, `x < y`, `-x`,
  `std::float64::truncate(x)` are compile-time TYPE errors naming the
  explicit operations (`rcf-no-number`); through an erased value (a
  `List[any]` element, an untyped parameter) the runtime refuses the same
  (`rcf-erased-no-number`): the value has a runtime kind of its own, never
  an Int's or a Float64's;
* no equality and no hash: `x == y` is a compile-time TYPE error ("bit
  identity and numeric equality differ (two NaNs, two zeros), so compare its
  bits ... or the Float64 it admits to"), `hash(x)` TRAIT-NOT-SATISFIED
  (RawFloat and RawDouble are neither Equatable nor Hashable), and an erased
  `==` or `hash` is the run-time EQUALITY error on every backend. The
  choice between bit identity and numeric equality is the program's: it
  compares `double_to_bits` results or admitted `Float64`s;
* no implicit conversion: a raw value is never admitted where a `Float64`
  is expected, a `Float64` never becomes a raw value where one is
  expected, and an Int is no raw value.

A raw value needs no authority: representing a NaN is no memory access. A
module that makes, inspects, converts and passes raw values to C by value
is ordinary (`direct module` on it is STALE-DIRECT-MODULE, `rcf-no-authority`).

### The operations: `std::ffi::c::raw`

The explicit operations live in their own standard module,
`std::ffi::c::raw` (`stdlib/ffi/c/raw.bot`), imported by the programs that
use them; a program that only declares raw externs and passes their values
on needs only `std::ffi::c`. (Placing them in `std::ffi::c`'s own module
would compile them into every program that imports `std::ffi::c` -- every
generated binding -- for nothing.)

| operation | result | meaning |
|---|---|---|
| `float_from_bits(b: FloatBits)` | `RawFloat` | the binary32 whose bit pattern is `b` |
| `float_to_bits(x)` | `FloatBits` | `x`'s bit pattern, exactly |
| `float_to_float64(x)` | `Float64 errors NonFiniteFloat` | `std::ffi::c::Float`'s admission, explicitly |
| `float_from_float64(x)` | `RawFloat errors NonFiniteFloat` | `std::ffi::c::Float`'s narrowing, explicitly |
| `double_from_bits(b: DoubleBits)` | `RawDouble` | the binary64 whose bit pattern is `b` |
| `double_to_bits(x)` | `DoubleBits` | `x`'s bit pattern, exactly |
| `double_to_float64(x)` | `Float64 errors NonFiniteFloat` | `std::ffi::c::Double`'s admission, explicitly |
| `double_from_float64(x)` | `RawDouble` | exact and total |
| `float_finite?`, `float_nan?`, `float_infinite?`, `float_zero?`, `float_negative?` | `bool` | read from the bits alone |
| `double_finite?` ... `double_negative?` | `bool` | the same for binary64 |

`FloatBits` is `Int in 0..4294967295` and `DoubleBits`
`Int in 0..18446744073709551615`: the bit pattern's domain is a proof
obligation, so `float_from_bits(4294967296)` is a compile-time TYPE error
(`rcf-no-implicit-conversion`, the golden `rcf-bits-proven`) and a checked
program can never pass a pattern that does not exist. `negative?` is the
sign bit: true for `-0.0`, a negative number, `-inf`, and a NaN whose sign
bit is set. So negative zero is `x.double_zero?() and x.double_negative?()`
and positive infinity `x.double_infinite?() and not x.double_negative?()`.

The functions follow the standard library's conversion spelling
(`std::int::to_string` / `from_string`): `X_to_Y` and `X_from_Y` pairs, `?`
predicates, `nomethod` on the constructors (a bit pattern or a Float64 is
no receiver), method syntax on the rest (`x.double_nan?()`).

A raw value's display -- a program result, a message -- is its C type and
every hexadecimal digit of its bits, identically on every backend
(`rcf-display`):

```
<C float 0x7fa00000>     a signaling NaN
<C double 0x8000000000000000>   negative zero
```

### Example: raw inspection, then explicit admission

```botlish
import std::ffi::c
import std::ffi::c::raw

extern c library "m"
extern c fn nan(tag: std::ffi::c::Ptr[std::ffi::c::Char]) -> std::ffi::c::RawDouble

fn describe(x: std::ffi::c::RawDouble) -> list:
    if x.double_nan?():
        return ["NaN", x.double_to_bits()]
    if x.double_zero?() and x.double_negative?():
        return ["negative zero"]
    v = x.double_to_float64():
        on NonFiniteFloat {result}:
            return ["infinite", result]
    ["number", v]
```

The same value through the finite binding (`-> std::ffi::c::Double`) would
have failed the call with NonFiniteFloat before `describe` could look at it.
Raven's wrapper (section 5) writes its finite accessor as exactly this
explicit step: `slider.slider_raw_value().float_to_float64()`.

## 2. Representation in the compiler and the runtimes

### The C ABI metadata: one table

`core/cabi.tcl`'s `floatings` table has two more rows, and nothing else
describes a C floating type:

```
Float     {c float  carrier Float64    representation Float  raw 0}
Double    {c double carrier Float64    representation Double raw 0}
RawFloat  {c float  carrier rawfloat32 representation Float  raw 1}
RawDouble {c double carrier rawfloat64 representation Double raw 1}
```

`representation` names the model entry (`floatingModels`) whose format and
alignment the type has: a raw type's is its finite counterpart's, so the
two can never differ in a C fact. `floatingInfo` returns `raw` beside the
format, size, alignment and ABI class. No parallel foreign type system was
added: every consumer of C floating facts (layouts, foreign signatures,
pointees, the binding generator's verification) reads the same rows.

### The front end

* **One canonical type in every position.** A finite C floating type is
  `{cfloat NAME}` with carrier `Float64`; a raw one's canonical type *is*
  its carrier, the runtime kind `rawfloat32` / `rawfloat64` -- a C type and
  a type of values at once, as a C integer scalar is both. `hir::cabi::
  FloatingType RawDouble` is `rawfloat64`; `hir::types::resolveNamed`
  resolves `std::ffi::c::RawDouble` to it where values are typed, and
  `hir::cabi::ResolveCType` where a C type is named. One spelling, one
  type, so HIR text and interchange round-trip without a position-dependent
  reading (`rcf-hir-text`, `rcf-interchange-isolation`).
* `hir::cabi::IsFloating` (any C floating type), `IsFiniteFloating`
  (`{cfloat ...}`: admitted, narrowed) and `IsRawFloating` say which;
  `Carrier` maps only the finite ones to `Float64`. `hir::types::kindOf`,
  `semantic` and `Totality` take a raw type as the primitive kind it is.
* The kinds' bare names are never source-spellable ("`rawfloat64` is not a
  type: a raw C floating value's type is spelled std::ffi::c::RawDouble"),
  as `cptr` is not.
* **Foreign declarations** (`hir/foreign.tcl`): a raw position's ABI class
  is `rf32` / `rf64` -- its finite counterpart's class, marked raw -- and
  a raw parameter or result charges no NonFiniteFloat (`rcf-abi-classes`).
* **Layouts** (`hir/layouts.tcl`): a raw field's representation is
  `{kind float format F width W ... raw 1}` and its descriptor words
  `{r WIDTH ENDIAN}`: `FloatErrors` (which reads `f`) charges nothing, so a
  layout operation over raw fields declares no NonFiniteFloat
  (`rcf-layout-errors`).
* **Static checks** (`hir::cabi::VerifyCallKinds`): `==` of a raw operand,
  and a raw value given to a native of another kind, are TYPE errors; a raw
  value is no trailing variadic argument (`hir::cabi::VariadicArgument`).

### The Tcl runtime

A raw value is `{rawfloat32 BITS}` / `{rawfloat64 BITS}` (BITS the
unsigned pattern, canonical decimal): a primitive kind of `core/type.tcl`
and `core/value.tcl`, in the `incomparable` and `unhashable` lists
(`core::value::equal` and `core::hashing::Encode` refuse it with their own
message). The byte codec (`core/binary.tcl`) reads and writes `r` words as
the unsigned integer of the width, wrapped and unwrapped: no admission, no
narrowing. The Tcl compiler defers a layout holding one to the reference
codec (`core::binary::HoldsRaw`). The Tcl backends refuse a C call
(NATIVE-ONLY) exactly as before, without narrowing a raw argument first
(`rcf-tcl-backends`).

### The native runtime

A raw value is a `FloatObj` (the object a `Float64` is) of a heap kind of
its own, `KIND_RAWF32` or `KIND_RAWF64`, its `bits` the pattern
(zero-extended for binary32): `Kind::RawFloat32` / `RawFloat64` for kind
tests, messages and the host transport (`{rawfloat64 BITS}`), refused by
`equal` and the hash walk, displayed by `show` as the Tcl runtime does. The
collector treats it as a leaf.

* **Layouts**: the encoding word gains bit 128, "a raw C floating
  representation of this width" (`native::lower::LayoutEncoding`, ops.rs's
  `BinEncoding::raw`; never signed, never also bit 64). `bin_decode` makes
  a raw value of the bytes, `bin_encode` writes a raw value's bits; every
  load and store path -- bytes, native views and edits, array rows --
  already funnels through these two.
* **Operations**: the internal intrinsics `std::rawfloat::from_bits32`
  ... `narrow64` (one family below std, as every qualified intrinsic but
  the platforms' and the C ABI's is: STD-NAMESPACE.md;
  `core::native::declareInternalNamespace`: only the standard library
  imports them or names their members, `rcf-intrinsics-internal`;
  `std::ffi::c::raw`'s functions are their declared spelling) lower to the NIR ops `rawfrombits32` ... `rawnarrow64`,
  runtime helpers `rt_raw_from_bits`, `rt_raw_bits`, `rt_raw_admit`,
  `rt_raw_narrow` (runtime/ffi.rs) on both native backends.
* **Calls**: NIR's foreign table names `rf32` / `rf64` (`CAbi::RawF32`,
  `RawF64`: `floating()` -- a floating-point register, no extension --
  and `raw_floating()`), section 4.

### Why a runtime kind, not an Int with a nominal type

Representing a raw value as the Int of its bits under a nominal static type
would have reused the integer layout paths, but natives' parameter kinds
are checked at run time only: through any untyped or erased path, Int
arithmetic and Int equality would have applied to a raw value. A kind of
its own makes every operation the type checker refuses also refused at run
time, on all four backends.

## 3. Conversions and errors

**Admission** (`float_to_float64`, `double_to_float64`) is the finite C
types' own rule, called explicitly: a NaN of any payload is NonFiniteFloat
`{result: NotANumber}`, an infinity `{result: PositiveInfinity}` or
`NegativeInfinity`; negative zero becomes `0.0`; every other value,
subnormals included, is itself -- a binary32 widened exactly (every finite
binary32 is a binary64). One implementation per runtime: `core::cabi::
AdmitBits` (Tcl) and `runtime::value::admit_c_float` (native), the very
procedures a finite field read or a finite call result uses
(`rcf-admission`; `rcf-c-finite-unchanged` checks that the explicit
admission of a raw result is exactly the finite call's outcome for every
sampled pattern).

**Narrowing** (`float_from_float64`) is the finite float's own rule:
round to nearest, ties to even (`fdemote`, Rust's `as f32`, Tcl's `binary
format r` behind its threshold), a subnormal kept, a negative number too
small for a float `+0`; a magnitude that rounds to an infinity -- from
2^128 - 2^103 up -- is NonFiniteFloat of its sign, never clamped to
FLT_MAX (`rcf-narrowing`: 3.4028235677973362e38 is FLT_MAX,
3.4028235677973366e38 NonFiniteFloat). A finite ordinary number never
silently becomes an infinity through it. `double_from_float64` is exact and
total: every Float64 is a finite binary64 with one zero.

**Bits**: `from_bits` takes a pattern its static type proves in range;
`to_bits` returns exactly the pattern (`-result-range` gives its range to
the range analysis). Arbitrary raw binary32 values -- an infinity, a NaN of
any payload -- are constructed only through their bits: no Float64 is one.

| operation | errors |
|---|---|
| `*_from_bits`, `*_to_bits`, `double_from_float64`, classifications | none |
| `float_to_float64`, `double_to_float64` | NonFiniteFloat (NaN, ±inf) |
| `float_from_float64` | NonFiniteFloat (overflow to ±inf) |
| a C call with only raw floating positions | none of its own (the finite rules charge NonFiniteFloat to a finite float parameter or floating result only) |
| a layout read or write of a raw field, element or alternative | none of its own |

## 4. C ABI and bit preservation

**Same ABI classes.** A raw float is passed and returned as C `float`, a
raw double as C `double`: `c_signature` gives `RawF32` Cranelift's `F32`
and `RawF64` `F64` (`machine_floating()`), floating-point registers, no
extension attribute, the integer-register count untouched, exactly as for
`F32` / `F64` -- under System V, AAPCS64, Apple AArch64 and Win64 alike
(the C convention is still `codegen::target::c_call_conv`'s). The Rust test
`raw_c_float_signature_is_the_finite_one` compiles a twelve-argument call
of interleaved raw floats, raw doubles and integers for System V and for
Win64 and requires Cranelift's disassembly to be byte-identical to the
finite call's (x86-64 hosts); `rcf-nir-clif` checks the platform signature
`(f32, f64) -> f32` of a raw extern in the CLIF. Variadic padding and
System V's `%al` count raw floating fixed parameters as floating-point
registers (`floating()`), like the finite ones.

**What crosses as bits.**

| crossing | how | bit-exact |
|---|---|---|
| argument | the object's bits loaded as an integer, `bitcast` to F32/F64 (`movd`/`movq` on x86-64, `fmov` on AArch64) | yes: a register move never alters a bit |
| result | `bitcast` of the result register to I32/I64, boxed by `rt_raw_new` | yes |
| layout field, element, union alternative (bytes, native views and edits) | an integer load or store of the width (`bin_decode`/`bin_encode`) | yes: no floating-point instruction touches it |
| construction, extraction, copying, storage in Botlish values | the pattern as an integer | yes |

No conversion instruction (`fdemote`, `fpromote`, a finiteness test, `+ 0.0`)
is emitted for a raw position (`rcf-nir-clif`: zero `fdemote`/`fpromote`,
no FLT_MAX constant). Every test of section 7 requires exact bits for every
sampled pattern, signaling NaNs included -- `0x7fa00000`, `0x7fa00001`,
`0x7f800001`, `0x7ff4000000000000`, `0x7ff0000000000001` -- through C
calls in registers and on the stack (`rcf-c-arguments`, `rcf-c-results`,
`rcf-c-register-exhaustion`), native memory, arrays and unions.

**What the ABI does not promise, and Botlish does not claim.** Bit
preservation ends where the C callee computes. A C function that converts,
promotes or does arithmetic on a signaling NaN quiets it (IEEE 754 requires
it); one compiled with fast-math flags may canonicalize NaNs or flush
subnormals; a variadic C function receives a float only after promotion to
double, which is a conversion -- so a raw value is never a trailing
argument (refused statically). The fixture (`tests/cffi/rawfloat-
fixture.c`) therefore never computes on a float: it copies bits with
`memcpy` or returns its argument register. On the supported targets
(x86-64 System V and Win64, AAPCS64, Apple AArch64) floating arguments and
results travel in SSE / SIMD registers, which move bits unchanged; an x87
convention (i386's float return in `st(0)`, which quiets a signaling NaN)
would break that, and no supported target uses one.

Where it was measured: everything above ran on Linux x86-64 (this
container). The AArch64 conventions share the code paths (the same
`bitcast` and loads; the AAPCS64 and Apple placements are the finite types'
own, checked by C-FLOAT-FFI-MILESTONE-1.md's lowering tests) and run in
CI's arm64 and macOS workflows; Windows lowering is the same code, checked
for x86-64 Win64 by the Rust test above, never run here.

## 5. Raven: the generated binding and the wrapper

### The binding generator: representation rules

A profile may now choose, per function and position, that the binding
writes a C float or double raw (`tools/c-bindgen/profile.tcl`'s
`representations`, applied by `::cbind::model::Representations`):

```tcl
representations {
    {name values  functions {Rslider_get_value Rspin_box_get_value} raw {result}}
    {name setters functions {Rslider_set_value Rspin_box_set_value} raw {value}}
    {name ranges  functions {Rspin_box_set_range} raw {minimum maximum}}
}
```

* Finite is the default: a position no rule names is
  `std::ffi::c::Float` / `Double` as before.
* The C ABI is still derived from the headers and the compiler's answers;
  a rule changes only the Botlish type written (`std::ffi::c::Float` to
  `RawFloat`, `Double` to `RawDouble`), never the native signature
  (`cb-representations` compiles both spellings of one C function and
  finds the same machine classes, `f64 rf32 -> rf64` against
  `f64 f32 -> f64`).
* A stale or invalid rule is the profile's error, never a silent no-op: a
  function the headers do not declare, a parameter the function does not
  have, a position that is no C float or double (`bgf_dot`'s `size_t n`),
  a position another rule already chose, an unknown key
  (`cb-representations`).
* Every choice is in the manifest, with its rule (`representation
  Rslider_get_value result raw {representation values}`), and the report
  lists the positions bound raw.
* No API, symbol or library is special-cased in the generator: Raven's
  choices are its profile's data.

The Raven binding was regenerated for linux-x86_64 and linux-aarch64 with
the repository's pinned toolchain (clang 21.1.8 of Ubuntu 26.04, in an
Ubuntu 26.04 chroot made from `ubuntu-base-26.04-base-amd64.tar.gz` with
`.devcontainer/setup-c-toolchain.sh`, as C-BINDGEN-UBUNTU-26.04-HANDOFF.md
describes). The diff is exactly the five functions:

```
extern c fn Rslider_set_value(slider: std::ffi::c::UInt, value: std::ffi::c::RawFloat) -> unit
extern c fn Rslider_get_value(slider: std::ffi::c::UInt) -> std::ffi::c::RawFloat
extern c fn Rspin_box_set_range(spin_box: std::ffi::c::UInt, minimum: std::ffi::c::RawDouble, maximum: std::ffi::c::RawDouble) -> unit
extern c fn Rspin_box_set_value(spin_box: std::ffi::c::UInt, value: std::ffi::c::RawDouble) -> unit
extern c fn Rspin_box_get_value(spin_box: std::ffi::c::UInt) -> std::ffi::c::RawDouble
```

plus their `report.tsv` rows, six `representation` manifest lines and the
report's new "C floating representations" section. The other 150 Raven
functions that use C floats keep their finite types; no blanket change was
made. In the same chroot, `tools/c-bindgen.tcl check PROFILE -target
committed` reports every target of every profile current (fixture, tcl,
tclstubs, boringssl, sdl3, win32, raven): the generator change alters no
other binding byte.

### The wrapper (`packages/raven/raven.bot`)

The caller chooses between the C value and its admission:

| function | type | what |
|---|---|---|
| `slider_raw_value(slider)` | `-> std::ffi::c::RawFloat` | Raven's float, every bit |
| `slider_value(slider)` | `-> Float64 errors NonFiniteFloat` | **unchanged contract**, now written as the explicit admission `slider.slider_raw_value().float_to_float64()` |
| `set_slider_value(slider, value)` | `Float64`, `errors NonFiniteFloat` | **unchanged contract**: `std::ffi::c::raw::float_from_float64(value)`, the explicit narrowing |
| `set_slider_raw_value(slider, value)` | `RawFloat`, `errors NonFiniteFloat` | finite bit patterns exactly (-0.0, subnormals); a NaN or an infinity is refused before Raven runs |
| `spin_box(minimum, maximum)` | `-> Widget` | a spin box, watched by the bridge |
| `spin_box_raw_value(spin_box)` | `-> RawDouble` | Raven's double, every bit |
| `spin_box_value(spin_box)` | `-> Float64 errors NonFiniteFloat` | explicit admission |
| `set_spin_box_value(spin_box, value)` | `Float64` | exact (every Float64 is a double) |
| `set_spin_box_raw_value(spin_box, value)` | `RawDouble` | any bits |
| `set_spin_box_raw_range(spin_box, minimum, maximum)` | `RawDouble` ×2 | any bits: an infinite bound is an unbounded side |

**Raven's preconditions stay Raven's.** That C accepts a `float` does not
make every IEEE 754 value meaningful to the function. Raven's source
decides which raw setters may pass anything:

* the spin box guards a NaN explicitly (`spin_box.c`: `if (value != value)
  return; /* NaN */`), clamps with C comparisons (defined for infinities)
  and formats its value only with `snprintf("%.*f")` (defined for
  infinities and NaN), so its raw setters pass any bits;
* the slider snaps, clamps and paints its value with no guard (a NaN would
  reach geometry code, where a float-to-int conversion of NaN is undefined
  behavior in C), so `set_slider_raw_value` passes finite patterns only --
  `-0.0` and subnormals exactly -- and refuses a NaN or an infinity with
  NonFiniteFloat before calling Raven.

Unrestricted non-finite round trips (NaN payloads, signaling NaNs) are the
C fixture's (section 7), never Raven's. `examples/raven/` (the counter)
uses neither control and is unchanged.

## 6. Raven integration results

`tests/raven/raw.bot` drives the real `libraven.so` (Raven v0.1.3, the
headless build of `tests/cffi/raven.tcl`) through the wrapper, on both
native backends, and `raven-raw` compares every bit with a C program making
the same calls against the same library (`tests/raven/raw_oracle.c`). Each
step: the bits Raven holds, their admitted value, their sign bit.

| step | bits | admitted | sign |
|---|---|---|---|
| slider: `set_slider_value(0.5)` | 1056964608 (0x3f000000) | 0.5 | false |
| slider: raw -0.0 | 2147483648 (0x80000000) | 0.0 | **true** |
| slider: raw subnormal 0x00000001 | 1 | 1.401298464324817e-45 | false |
| slider: raw NaN | refused before Raven: NotANumber | -- | -- |
| slider after the refusal | 1 (unchanged) | 1.401298464324817e-45 | false |
| slider: `set_slider_value(0.1)` | 1036831949 (binary32 0.1) | 0.10000000149011612 | false |
| spin box: `set_spin_box_value(2.5)` | 4612811918334230528 | 2.5 | false |
| spin box: raw NaN 0x7ff8000000000001 | 4612811918334230528 (Raven ignores a NaN) | 2.5 | false |
| spin box: raw -0.0 | 9223372036854775808 | 0.0 | **true** |
| spin box: raw +inf, range -10..10 | 4621819117588971520 (clamped to 10.0) | 10.0 | false |
| spin box: range -inf..+inf, raw +inf | 9218868437227405312 (+inf) | **PositiveInfinity** (NonFiniteFloat) | false |
| a frame drawn | `true` | | |
| spin box after the frame | +inf | PositiveInfinity | false |
| spin box: raw -inf | 18442240474082181120 | NegativeInfinity | true |
| spin box: range 0..1 | 0 (Raven clamps -inf to 0.0) | 0.0 | false |

The C oracle prints `1056964608 2147483648 1 1 1036831949
4612811918334230528 4612811918334230528 9223372036854775808
4621819117588971520 9218868437227405312 1 9218868437227405312
18442240474082181120 0` -- the same bits, step for step. So a real GUI
library returned a non-finite C double (a spin box with an unbounded
range), which the raw accessor carries and the finite accessor refuses
with NonFiniteFloat, and a negative zero, which the finite path would have
normalized.

The rest of Raven's tests (install, warning-clean -- `raw` among the
scenarios, under `-warnings error` --, authority, Tcl backends, the
example headless, events, lifecycle, timers, the bridge ABI) pass
unchanged; `raven-desktop` needs a desktop build, Xvfb and a Vulkan driver
and was skipped here (CI's `c-bindgen` workflow runs it).

## 7. Tests

| test | what |
|---|---|
| `tests/raw-c-float-ffi.test` (new, 31 tests) | the type model and its facts per target; positions; no implicit conversion; the intrinsics internal to the standard library; no arithmetic, ordering, equality or hash (statically and through erased values on all four backends); ABI classes and error charging; no authority; invalid positions; bit round trips, classification, display, admission and narrowing on all four backends; byte layouts with raw fields, arrays and unions on all four backends; C calls against `tests/cffi/rawfloat-fixture.c` -- arguments, results, pass-through, register exhaustion with integers interleaved and a stack-passed result, the finite bindings' unchanged behavior; the record layout against C; native views, edits, arrays, unions and pointers over C's memory; function pointers of raw signatures; the Tcl backends' refusal; HIR text, interchange and isolation; NIR and CLIF; a standalone executable; GC stress |
| `tests/golden/raw-c-float-ffi.bot` (new, 13 tests, all four backends) | bit round trips, classification, admission, narrowing, byte layouts and emission, and seven compile-time rejections (arithmetic, ordering, equality, implicit admission, implicit raw, a format change, an unproven bit pattern); `audit/golden/tools/perturb.tcl`: 13 inverted and 13 altered, all failed as required |
| `tests/raven.test` `raven-raw` (new) | section 6 |
| `tests/c-bindgen.test` `cb-representations` (new) | section 5's generator rules |
| `audit/c-float-ffi/tools/fuzz.tcl` (extended; `-raw 1` by default) | C-FLOAT-FFI-MILESTONE-1.md's fuzzer of random real C signatures and float layouts now makes a parameter, a result or a layout field raw three times in ten: a raw argument is any bit pattern (NaN payloads of both signs, signaling NaNs, the infinities, -0, subnormals) and its integer model expects exactly those bits in C, exactly C's bits in a raw result (both native backends) and a raw field read, written and emitted (all four backends), and never NonFiniteFloat from a raw position, beside finite floats and integers in the same signatures; `-raw 0` draws the earlier milestone's programs exactly |
| Rust: `raw_c_float_codec_keeps_every_bit`, `raw_c_float_helpers` (runtime::ops), `raw_float_classes` (nir), `raw_c_float_signature_is_the_finite_one` (codegen::clif, x86-64 hosts) | the encoding word, the codec on signaling NaNs and both zeros, the helpers' rules, the classes' parsing and refusal as varargs, the machine signature |

The bit patterns every test carries, binary32 and binary64: +0, -0, +inf,
-inf, quiet NaNs of both signs and several payloads, signaling NaNs, the
smallest and largest subnormals, the smallest normal, the largest finite of
both signs, and ordinary values (1.0, 0.1, -2.5). Results compare bits, so
no numeric comparison can hide a sign or a payload.

**Mutation** (`audit/c-float-ffi/tools/mutate.tcl`, whose default
detectors now include `tests/raw-c-float-ffi.test`): 16 raw mutants --
an argument converted numerically instead of moved, a result admitted, a
float result widened before its bits are taken, the finite ABI class for a
raw position, a raw field's descriptor finite or integer, the Tcl codec
dropping the sign, the native codec quieting a NaN, a double's pattern
boxed as a signed word, bitwise `==`, the static number check removed,
Float64 as a raw double's carrier, a raw float with a double's
representation, a raw trailing variadic argument, the Tcl admission of the
wrong format, an unpadded native display. The binding generator's
harness has two more (`bindgen-representations-ignored`,
`bindgen-representation-of-any-type`). Results: section 7.1.

### 7.1 Results

Linux x86-64 (this container):

| check | result |
|---|---|
| `tests/raw-c-float-ffi.test` | 31 tests, all passed (the fixture built and linked) |
| `tests/golden/raw-c-float-ffi.bot` | 13/13 on interp, compile, cranelift-generic and cranelift; perturbation 13/13 and 13/13 |
| `tests/raven.test` | 11 tests: 10 passed, 1 skipped (`raven-desktop`: no desktop build here) |
| `tests/c-bindgen.test` | in the pinned Ubuntu 26.04 chroot (`.devcontainer/setup-c-toolchain.sh`, `BOTLISH_NATIVE_LINKER=system`): 91 tests, 85 passed, 6 skipped, 0 failed (`cb-representations` among them); on this Ubuntu 24.04 host every test but `cb-tcl-current` passes, and that one fails identically on the untouched tree (the host's Tcl headers differ from 26.04's) |
| `tools/c-bindgen.tcl check PROFILE -target committed` (pinned chroot) | every target of fixture, tcl, tclstubs, boringssl, sdl3, win32 and raven current |
| Rust `--lib`, `--bin botlish-native` | 309 and 115 passed |
| `tests/c-float-ffi.test`, `c-abi-types.test`, `c-ffi.test`, `float64.test`, `hashable.test`, `binary-layout.test`, `native-view.test`, `native-edit.test`, `layout-arrays.test`, `layout-unions.test`, `static-compile.test`, `compilerpedia.test` | all passed (one expectation of `cfl-type-facts` updated: `core::cabi::floatingNames` now lists the four rows) |
| `tools/compilerpedia.tcl check` | 0 problems (the new `concept.raw-c-floats` topic's examples run) |
| `tests/local.tcl` (every Tcl test file on interp and compile, every golden suite on all four backends; run in parts after a timeout and a container restart) | all 112 golden suites on interp, compile, cranelift-generic and cranelift: pass. Of the 245 Tcl test files on both Tcl backends, five failed on a first pass and four of those failures were this milestone's: three tests that enumerate the native registry and did not yet list the raw intrinsics (`me-nomethod-native-default-off`, `ns-no-nested-stdlib` -- which moved the intrinsics from `std::ffi::rawfloat` to `std::rawfloat`, one family below std -- and `linux-syscall-native-registered`) and `nl-no-string-ternary` (a string-valued `expr ?:` in `AbiClass`, rewritten with `if`); all fixed, and the files re-run pass. The fifth is `c-bindgen.test`'s `cb-tcl-current`, which fails identically on the untouched tree on this Ubuntu 24.04 host and passes in the pinned chroot (row above) |
| `audit/hir-interchange/tools/roundtrip.tcl -suites "raw-c-float-ffi.bot c-float-ffi.bot binary-layout.bot"` | `-via interchange`: 27 artifacts and outcomes compared, 0 differ; `-via cache`: 30, 0 differ |
| mutation | `audit/c-float-ffi/tools/mutate.tcl`: 40 mutants (C-FLOAT-FFI-MILESTONE-1.md's 24, six with their text updated to this code, and the 16 `raw-*`), 40 killed, 0 survived; the other harnesses' mutants whose text this milestone updated -- binary-layout's `width-native-lower`, c-abi-types' `ptr-as-int`, native-view's `view-is-a-pointer`, c-ffi's `va-float-vararg-parses` -- and the generator's two new ones (`bindgen-representations-ignored`, `bindgen-representation-of-any-type`, both by a test of behavior) all apply and are killed; every mutant of every harness still applies but two in `aot.rs` (`link-failure-removes-earlier`, `system-loses-static`), which did not apply before this milestone either |
| `audit/c-float-ffi/tools/fuzz.tcl` | seeds 1, 2, 3, 7, 11 (6 programs each: 48 calls, 24 layouts) and seed 4 under GC stress, raw positions drawn: 0 disagreements; seed 1 with `-raw 0`: 0 disagreements |

## 8. Compatibility of the finite C types

The finite types' contract is unchanged, and checked:

* `tests/c-float-ffi.test` (37 tests) and its golden suite pass with no
  change but the one listing of the table's names: narrowing boundaries,
  non-finite results, negative zero, layouts, function pointers, static
  decisions, executables, GC stress.
* `rcf-c-finite-unchanged` binds the very C functions of the raw tests
  finite and checks, for every sampled pattern, that the finite call's
  outcome (a Float64, or NonFiniteFloat with its payload) equals the raw
  call's explicit admission, that negative zero still enters as `+0`, and
  that a Botlish zero still leaves positive.
* The finite types acquire no new behavior: no raw type is an alternative
  in overload or method resolution, conversion or admission (a raw value
  is never admitted where a finite type is expected, `rcf-no-implicit-
  conversion`); no finite position became raw anywhere but the five Raven
  functions a profile names.
* Every existing mutant still applies: the six whose code this milestone
  changed (`width-native-lower`, `va-float-vararg-parses`,
  `float-double-collapsed`, `extern-float-class-f64`,
  `extern-narrowing-undeclared`, `native-float-encoding-as-integer`) were
  rewritten against the new code, each a mutant of the same rule; two that
  already did not apply on the untouched tree and target the function this
  milestone edits (`ptr-as-int`, `view-is-a-pointer`: an indentation drift)
  were brought back. (`link-failure-removes-earlier` and
  `system-loses-static`, in `native/src/codegen/aot.rs`, did not apply
  before this milestone either and are unrelated to it.)

## 9. Limitations, and the callback milestone

* **No callbacks yet.** `FnPtr` signatures accept the raw types
  (`rcf-function-pointers`: C hands out and calls a pointer of a raw
  signature), but no Botlish function can be one (C-FFI.md, "Not here").
  When callbacks come, a callback parameter declared `RawDouble` receives
  C's bits without any check that could fail before the body runs -- the
  admission step this milestone makes explicit is then the body's choice,
  which is the point. The callback trampoline will need the same two
  pieces the direct call uses: `bitcast` of the incoming register into a
  raw value (`rt_raw_new`, which allocates: the trampoline runs where the
  collector may run) and, for a raw result, the value's bits moved into the
  result register. Nothing here couples to that implementation.
* **A raw value is a heap object natively** (like a Float64): each raw
  result or field read allocates one `FloatObj`, and `double_to_bits` of a
  pattern of 2^62 or more is a BigInt. A future unboxed representation
  (the C word machinery of C-FFI-ERROR-CAPTURE-MILESTONE-2.md) could remove
  the allocation where a value does not escape.
* **No raw variadic argument**: C promotes a trailing float to a double, a
  conversion (section 4); declare the parameter or admit the value.
* **No equality or hash** of raw values (section 1); compare bits.
* **No Float32 and no IEEE arithmetic** on raw values: by design.
* **No `long double`**: unchanged (the generator reports it).
* **The Tcl backends** run every raw operation but refuse a C call and
  native memory, as for every C type.
* **Binding generator**: a representation rule names positions of
  functions; record fields stay finite in generated layouts (a hand-written
  layout may declare raw fields). The macOS and Windows bindings of Raven
  are not generated (RAVEN-BINDINGS.md, "Not done").
* **Signaling NaNs** are carried exactly by Botlish; what a C callee does
  with one is the callee's (section 4).

## 10. What to run when changing this

Files: `core/cabi.tcl` (the `floatings` rows, `rawFloatingOf`,
`floatingInfo`, the raw values and intrinsics), `core/type.tcl`,
`core/value.tcl` and `core/hashing.tcl` (the kinds and refusals),
`core/binary.tcl` (`r` words), `hir/cabi.tcl` (`FloatingType`,
`IsFloating`, `IsFiniteFloating`, `IsRawFloating`, `Carrier`,
`VerifyCallKinds`, `VariadicArgument`), `hir/types.tcl` (`resolveNamed`,
`kindOf`, `semantic`, `Totality`), `hir/foreign.tcl` (`AbiClass`, error
charging), `hir/imprint.tcl`, `hir/layouts.tcl` (`FloatingRepr`,
`ReprDescriptor`), `compiler/compiler.tcl`, `stdlib/ffi/c.bot`,
`stdlib/ffi/c/raw.bot`, `native/lower.tcl` (`LayoutEncoding`, the natives),
`native/src/nir.rs` (`CAbi::RawF32/RawF64`, the ops),
`native/src/codegen/clif.rs` (`raw_float_argument`, `raw_float_result`,
the ops), `native/src/runtime/{value,vm,ops,ffi,show,heap,metrics}.rs`,
`tools/c-bindgen/{profile,model,report}.tcl`,
`tools/c-bindgen/profiles/raven.tcl`, `packages/raven/raven.bot`.

Run `tests/raw-c-float-ffi.test` (its fixture needs `cc`), `tclsh9.0
tests/local.tcl tests/golden/raw-c-float-ffi.bot`, `tests/c-float-ffi.test`,
`tests/c-ffi.test`, `tests/c-abi-types.test`, `tests/hashable.test`, the
layout test files (binary-layout, native-view, native-edit, layout-arrays,
layout-unions), `cargo test --release --manifest-path native/Cargo.toml
--lib c_float` and `--bin botlish-native raw_c_float`,
`audit/c-float-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/c-float-ffi/tools/mutate.tcl` (every mutant must still apply
and be killed; its raw mutants are `raw-*`), and for the generator or the Raven
profile the C binding generator's checks (AGENTS.md) with the pinned
toolchain, then `tests/raven.test` (`tclsh9.0 tests/cffi/raven.tcl` builds
the library).
