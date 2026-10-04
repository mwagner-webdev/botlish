# ABI numeric domains: abi::I8 ... abi::Usize

## Outcome

The first ABI-domain layer above the x86-64 `Register64` transport exists,
and it is **ordinary Botlish**: ten nominal structs, ten source-defined
integer domains, ten checked creators (`lib/abi.bot`), and ten register
encoders (`lib/abi/x86_64.bot`). No type, function, error or rule of the
family is known to the compiler.

```botlish
x = abi::u32(n)                      # n, proven 0 <= n <= 2^32 - 1, or an error
m = x.value                          # exactly n again: an ordinary Int
r = abi::x86_64::from_u32(x)         # the x86-64 register word (zero-extended)
linux::abi::syscall({rax: abi::x86_64::register64(39), rdi: r})
```

```
ordinary computation in Int
    --abi::u32(...)------------->  abi::U32        checked/proven domain     (lib/abi.bot)
    --abi::x86_64::from_u32----->  Register64      x86-64 transport          (lib/abi/x86_64.bot)
    --linux::abi::syscall------->  the kernel                                (unchanged)
```

The two theorems the milestone asked for hold, and are tested:

1. **Every ABI numeric value represents exactly one ordinary mathematical
   Botlish Int together with proof that it lies in the declared domain; no
   fixed-width arithmetic semantics leak into ordinary Botlish.** An ABI
   value is a struct whose one field is typed with the domain: every
   construction must prove the field statically (no run-time guard exists),
   `.value` is the Int itself, and a struct has no arithmetic (`abi::u8(255)
   + 1` is the ordinary TYPE error; `abi::u8(255).value + 1` is the Int 256,
   and back into U8 only through `abi::u8`, which reports
   `AbiIntegerAboveRange`).
2. **Every ABI numeric domain encodes into the correct x86-64 64-bit register
   bit pattern without weakening its mathematical domain, including the full
   unsigned U64/Usize range.** Signed values are sign-extended, unsigned
   values zero-extended; `U64 2^63 -> 0x8000000000000000`, `U64 2^64-1 ->
   0xffffffffffffffff`, written as ordinary Int arithmetic on the value.
   `Register64` did not change.

Compiler changes were made only where the generic machinery had a real
gap; all are general (none mentions an ABI type):

* **The completion proof now reads a field projection's declared domain**
  (`hir/completions.tcl`), as `hir/range.tcl` already did. Without it,
  `byte::from_int(x.value)` for `x: abi::U8` demanded a `BelowRange`
  handler (while the same value through a local did not): source-defined
  domains did not aid the error proof at a projection.
* **Mismatch diagnostics** (`hir/range.tcl`): they print Int facts only when
  both the value and the declared type may be Ints, and name a nominal
  struct mismatch. Passing an `abi::U64` where an `abi::Usize` is required
  now reads "...cannot be proven to satisfy abi::Usize (argument type:
  abi::U64); abi::U64 and abi::Usize are distinct named struct types: a
  named struct type is nominal, and no value is ever converted from one to
  another implicitly" instead of "... (argument type: abi::U64, facts:
  [-∞, +∞])".
* **A duplicate `type`/`error` declaration names the module declaration it
  collides with** (`hir/sourcetypes.tcl`, `hir/errordecls.tcl`), and
  **module files are parsed once per process** (`surface/modules.tcl`) --
  both consequences of `abi::x86_64` now loading `lib/abi.bot` (below,
  "Dependency and global names").

Natively, the wrappers disappear: a proven-valid constant creation is a
single `retmulti` of its argument (no comparison, no fail path, no struct,
no allocation), and `from_i32(abi::i32(42))` is two such register moves end
to end. The remaining costs are pinned and explained below ("Optimization
frontier"): `from_u64`/`from_usize` keep one comparison (and on the
upper-half path one BigInt subtraction) at run time even for a constant; an
upper-half word below `-2^62` is a BigInt in transit; and a comparison with
a bound outside the small-Int range is a run-time helper call.

## Source declarations

### `abi` (lib/abi.bot)

```botlish
namespace abi

error AbiIntegerBelowRange
error AbiIntegerAboveRange

type I8Value = Int in -128..127
type I16Value = Int in -32768..32767
type I32Value = Int in -2147483648..2147483647
type I64Value = Int in -9223372036854775808..9223372036854775807

type U8Value = Int in 0..255
type U16Value = Int in 0..65535
type U32Value = Int in 0..4294967295
type U64Value = Int in 0..18446744073709551615

# TARGET-DEPENDENT: the address/size width of the only supported target,
# Linux x86-64 (64 bits).
type IsizeValue = Int in -9223372036854775808..9223372036854775807
type UsizeValue = Int in 0..18446744073709551615

struct I8:
    value: I8Value
# ... likewise I16 I32 I64 U8 U16 U32 U64 Isize Usize, each over its own domain

fn i8(value: int) -> I8 errors AbiIntegerBelowRange, AbiIntegerAboveRange:
    if value < -128:
        fail AbiIntegerBelowRange
    elif value > 127:
        fail AbiIntegerAboveRange
    else:
        I8 {value: value}
# ... likewise i16 i32 i64 u8 u16 u32 u64 isize usize, each with its own
#     two literal bounds
```

The file's header documents the family as **ABI numeric domains, not
fixed-width arithmetic types**, with the `u8(255)` example, the recommended
model (Int computation, checked/proven conversion, architecture transport),
and the rule that Isize/Usize are for foreign boundaries, not collection
indexing.

**Why this shape.** It is the `Register64` precedent exactly
(LINUX-X86-64-SYSCALL.md): a `type Child = Int in LO..HI` declaration
carries the domain to every analysis that reads integer domains (range
analysis, completion proofs, raw-Int lowering), and a one-field nominal
struct carries the identity. The domain types alone could not be the ABI
types: a source `type` is a *subtype of Int*, so `I32Value` would accept
arithmetic (`x + 1` is an Int) and would be accepted wherever an Int is --
the opposite of a boundary value. The struct is what makes `abi::I32` and
`abi::U32` distinct and arithmetic-free. Botlish has no generics over
nominal types and no macros, so the ten members are written out; each is
the same three branches.

**Names.** Types are uppercase (`I32`), creators lowercase (`i32`) and
documented as checked conversions from Int, not constructors. A source `type`
is a member of its namespace (IMPORTS.md), so the domains are
`abi::I8Value` ... `abi::UsizeValue`, beside the structs and creators; a
consumer writes `x: abi::U8Value` after `import abi`, or binds the short name
with `import type abi::U8Value`. Source `error` declarations are still
global, unqualified names (hir/errordecls.tcl), hence the errors
`AbiIntegerBelowRange`/`AbiIntegerAboveRange` keep their `Abi` prefix.

### Dependency and global names

`abi::x86_64`'s encoders name the ABI types, so `lib/abi/x86_64.bot` declares
`import abi`, and **every program that imports `abi::x86_64` -- the raw
`register64`/`to_int` included -- also loads `lib/abi.bot`** (a dependency of
the module, not of the program's source: the program can use none of `abi`
without its own `import abi`), with the two global error names and the ten
generic predicate natives every source `type` gets (`abi::U8Value?`, ...).
The layering requires the edge (`abi::U32 -> abi::x86_64::Register64`), and
one namespace is one file, so the encoders cannot live in a module that
loads only when used.

* **Collisions.** The first version used the brief's conceptual names
  (`U8Value`, ...) as *global* type names; a program declaring its own `type
  U8Value` and calling `register64` then stopped compiling, so they were
  prefixed (`U8Value`). IMPORTS.md removed the problem at the root: the
  domain types are `abi::U8Value` ..., members of namespace `abi`, and a
  program's own `type U8Value` is a different type (`U8Value`, not
  `abi::U8Value`) that coexists with it (`abi-numeric-namespaced-types`). The
  two errors are still global (`error` declarations are not namespaced), so
  a program declaring `error AbiIntegerAboveRange` collides with the module's
  and the message says where the other is.
* **Compile time.** The extra module costs compile time, dominated by
  lexing and parsing the two commented library files. Module ASTs are now
  cached by path and exact file text (`surface::modules::ParseModule`;
  parsing is a pure function of both, so the cache cannot go stale), so a
  repeated compilation in one process (a test file, a batch driver) parses
  each library file once. Compiling `examples/linux/getpid.bot`
  (`surface::readProgramFile`, Linux x86-64, Tcl 9.0.1, median of three
  processes):

  | | first compilation in a process | repeated |
  |---|---|---|
  | before this milestone | 36 ms | 12 ms |
  | now | 96 ms | 32 ms |

  Without the cache a repeated compilation took about 79 ms. The NIR and
  the run time are unchanged.

### Exact domains

| type | domain |
|---|---|
| `abi::I8` | `-128 .. 127` |
| `abi::I16` | `-32768 .. 32767` |
| `abi::I32` | `-2147483648 .. 2147483647` |
| `abi::I64` | `-9223372036854775808 .. 9223372036854775807` |
| `abi::U8` | `0 .. 255` |
| `abi::U16` | `0 .. 65535` |
| `abi::U32` | `0 .. 4294967295` |
| `abi::U64` | `0 .. 18446744073709551615` (the full unsigned 64-bit range) |
| `abi::Isize` | signed ABI address/size-width integer: today `-2^63 .. 2^63 - 1` |
| `abi::Usize` | unsigned ABI address/size-width integer: today `0 .. 2^64 - 1` |

`tests/abi-numeric.test` pins every interval from the compiled program's own
source-type table (`abi-numeric-exact-domains`).

### Isize and Usize: the target dependency

`IsizeValue`/`UsizeValue` are declared in their own clearly marked
section of `lib/abi.bot`: "TARGET-DEPENDENT ... The only supported target today is
Linux x86-64, whose address size is 64 bits. This pair of declarations is
the one place that width is chosen." The architecture side
(`lib/abi/x86_64.bot`) says where that width meets the register: Isize/Usize
are encoded at x86-64's 64-bit width. No target-parametric type machinery
was built. A 32-bit target would change exactly those two declarations and
its own architecture layer.

They are **nominally distinct** from I64/U64: different structs, and their
domains are separate declarations with no parent (not aliases, not
subtypes: `core::type::subtype IsizeValue I64Value` is 0). `fn f(x:
abi::Usize)` rejects an `abi::U64` at compile time; `abi::isize(1) ==
abi::i64(1)` is false. The documentation describes them as "unsigned/signed
ABI address/size-width integer; currently 64-bit on the supported x86-64
target", never as "always 64-bit".

`list_length`, string lengths and indexes remain ordinary `Int`;
`list_get(xs, abi::usize(0))` is a TYPE error (tested).

### Creators and errors

```
abi::i8(value: int)    -> abi::I8     errors AbiIntegerBelowRange, AbiIntegerAboveRange
abi::i16(value: int)   -> abi::I16    errors ...
abi::i32(value: int)   -> abi::I32    errors ...
abi::i64(value: int)   -> abi::I64    errors ...
abi::u8(value: int)    -> abi::U8     errors ...
abi::u16(value: int)   -> abi::U16    errors ...
abi::u32(value: int)   -> abi::U32    errors ...
abi::u64(value: int)   -> abi::U64    errors ...
abi::isize(value: int) -> abi::Isize  errors ...
abi::usize(value: int) -> abi::Usize  errors ...
```

* Each returns the ABI value representing exactly its argument, or fails
  with **`AbiIntegerBelowRange`** (value < the domain's minimum) or
  **`AbiIntegerAboveRange`** (value > its maximum). Never truncation.
* **One pair of errors for the whole family**, not twenty: the creator a call
  names already identifies the domain; the error says which bound. This is
  `byte::from_int`'s and `register64`'s two-error granularity, so callers can
  still treat the two directions differently.
* The error surface is statically visible: each creator declares both, and
  the call-specific completion proof (STATIC-COMPLETION-PROOFS.md) computes
  each call's effective set -- `abi::u8(42)` needs no handler,
  `abi::u8(256)` is a compile-time `KNOWN-ERROR` naming
  `AbiIntegerAboveRange`, and a dynamic Int must be handled or declared.
* No `ContractViolation` semantics: a failing `abi::u8(user_input)` is an
  ordinary declared error.
* Direct construction (`abi::U8 {value: x}`) is equally sound without
  privacy: a named construction must prove each field statically
  (STRUCTS.md), so `abi::U8 {value: 256}` and `fn wrap(x: int): abi::U8
  {value: x}` are compile-time TYPE errors.

### Back to Int: `x.value`

The conversion back is the field projection **`x.value`**, uniform over the
whole family, returning exactly the Int the value represents (`U8 255 ->
255`, `I8 -1 -> -1`, `U64 2^64-1 -> 18446744073709551615`; tested for every
type and every boundary). It never sign-extends, truncates or reinterprets:
it reads the one field.

Why not `abi::to_int(x)`: Botlish has no overloading, and one function over
ten nominal types needs either overloading or a closed-family intrinsic --
the milestone asked for neither merely to obtain the spelling. Ten
`abi::i32_to_int` functions would only repeat the projection. The projection
is the smallest coherent interface: no new function, resolved statically by
the receiver's nominal type, and its static type is the domain
(`int[U32Value]`), so the proof survives (`abi::usize(u.value)` for `u:
abi::U64` needs no handler; `byte::from_int(x.value)` for `x: abi::U8` needs
none).

### Nominal behavior, arithmetic, equality

* Parameters are nominal (`abi-numeric-nominal-parameters`): I32 is not U32,
  I64 is not Isize, U64 is not Usize, and a plain Int is not a U32 -- each a
  compile-time TYPE error with the nominal clause above. The explicit route
  is through Int: `abi::usize(u64_value.value)`.
* No arithmetic or ordering: `+`, `*`, `<` on an ABI value are the ordinary
  run-time TYPE error any struct operand gets (`+: expected int, got abi::U8
  {value: 255}`), identically on all four backends. Nothing in the language
  needed to change to prevent it; no implicit `.value` exists.
* The language's structural equality applies within a type (`abi::u8(1) ==
  abi::u8(1)`) and never across nominal types, whatever the domains.
* No wrapping, saturating, bitwise, cast, promotion or pointer API exists,
  and none was added.

## Register encoding (lib/abi/x86_64.bot)

```botlish
fn from_i8(value: abi::I8) -> Register64:
    Register64 {word: value.value}
# from_i16, from_i32, from_i64, from_isize, from_u8, from_u16, from_u32:
# the same one line, each typed with its own ABI struct

fn from_u64(value: abi::U64) -> Register64:
    v = value.value
    if v > 9223372036854775807:
        Register64 {word: v - 18446744073709551616}
    else:
        Register64 {word: v}
# from_usize: the same, typed abi::Usize
```

**Why it is correct.** `Register64` is a 64-bit bit pattern; its `word` holds
that pattern's signed (two's-complement) reading, one Int per pattern.

* **Signed values are sign-extended.** The sign extension of a signed n-bit
  value v to 64 bits is the pattern whose signed reading is v itself, so the
  word is v: `I8 -1 -> 0xffffffffffffffff`, `I8 -128 -> 0xffffffffffffff80`,
  `I32 -2^31 -> 0xffffffff80000000`, `I8 127 -> 0x000000000000007f`. A
  negative value is never reread as a positive number first.
* **Unsigned values are zero-extended**: the pattern whose *unsigned* reading
  is v. Below 2^63 (all of U8/U16/U32 and the lower half of U64/Usize) its
  signed reading is v again. For `2^63 <= v < 2^64` the top bit is set and
  the signed reading of the same 64 bits is `v - 2^64`: `U64 2^63 ->
  0x8000000000000000` (word `-2^63`), `U64 2^64-1 -> 0xffffffffffffffff`
  (word `-1`).

Each encoder is total and check-free: its parameter's domain proves every
construction (range analysis proves `v - 2^64` in `-2^63..-1` on the
upper-half branch), so none declares an error and none needs a handler.

**`Register64` itself did not change.** The smallest clean solution was the
first one the brief listed: keep the signed physical word and construct the
identical two's-complement bit pattern from the unsigned domain. The U64
domain is never routed through `register64(Int)` (which would reject its
upper half, and still does: `register64(2^64-1)` is `KNOWN-ERROR`), and it is
never reduced to `0 .. 2^63-1`. `register64(Int)` remains one route into the
transport, unchanged.

**Bit transport is not interpretation.** `abi::x86_64::to_int` still reads
every word signed, as raw Linux results need: `to_int(from_u64(abi::u64(2^64
- 1)))` is `-1`, and `from_u64(abi::u64(2^64-1)) == from_i64(abi::i64(-1))`
(the same bits). No `to_uint64(Register64)` or other reverse API was added.

### Spelling without overloading

One encoder per ABI type, named for the type it accepts (`from_i32`,
`from_usize`), exactly as the creator's name selects the domain (`abi::i32`,
`abi::usize`). Each is an ordinary, nominally typed function: `from_usize`
does not accept an `abi::U64`, `from_u32` no plain Int (tested). This is not
an overload system: there is no dispatch on argument types anywhere, and no
name means two functions. The caller has an ABI value of a known nominal
type and names its encoder, just as it names its creator. A
compiler-recognized `register64` accepting the closed family would have made
the existing ordinary-Botlish `register64` an intrinsic, and taught the
compiler the family -- the opposite of the brief's preference.

Within a register literal:

```botlish
linux::abi::syscall({
    rax: abi::x86_64::register64(nr),
    rdi: abi::x86_64::from_i32(fd),
    rdx: abi::x86_64::from_usize(count),
})
```

### Exact register-bit tests

Three layers, none relying on `to_int`'s signed reading for the unsigned
cases:

1. **The 64 bits of every encoder's word, on every backend**
   (`abi-numeric-register-bit-patterns`): 21 cases, each word formatted as
   its 64-bit two's-complement pattern and compared with the expected hex
   literal:

   ```
   I8(-1)    ffffffffffffffff     I8(-128)   ffffffffffffff80   I8(127)  000000000000007f
   I16(-1)   ffffffffffffffff     I16(min)   ffffffffffff8000
   I32(-1)   ffffffffffffffff     I32(min)   ffffffff80000000   I32(max) 000000007fffffff
   I64(-1)   ffffffffffffffff     I64(min)   8000000000000000   Isize(-1) ffffffffffffffff
   U8(255)   00000000000000ff     U16(65535) 000000000000ffff   U32(max) 00000000ffffffff
   U64(0)    0000000000000000     U64(2^63-1) 7fffffffffffffff  U64(2^63) 8000000000000000
   U64(2^63+1) 8000000000000001   U64(max)   ffffffffffffffff
   Usize(2^63) 8000000000000000   Usize(max) ffffffffffffffff
   ```

2. **What the kernel boundary receives** (Rust unit test
   `abi_numeric_words_are_their_register_bit_patterns`,
   native/src/runtime/syscall.rs): each word is built the way generated code
   builds it -- the value itself for signed and lower-half unsigned values,
   and for the upper half the runtime's own `rt_int_sub(v, 2^64)` on BigInt
   operands, exactly `from_u64`'s `isub` -- and the `i64` that
   `register_word` hands `botlish_linux_x86_64_syscall` is compared, as a
   `u64`, with the expected pattern (`0x8000_0000_0000_0000`,
   `0xffff_ffff_ffff_ffff`, ...). It also pins which words stay BigInts in
   transit.

3. **Nothing between encoder and kernel** (`abi-numeric-syscall-operands-are-
   the-encoded-words`): in the NIR of a getpid call whose argument registers
   are `from_u64(u64(2^64-1))`, `from_i8(i8(-1))`, `from_u32(u32(2^32-1))`,
   `from_usize(usize(3))`, each `syscall_linux_x86_64` operand is that
   encoder's own `callmulti` result register; the call returns the same pid
   as the plain `raw_getpid()` (getpid ignores its argument registers, so
   this is the only live syscall, as before), and the path allocates no
   struct and no BigInt.

## Native representation

### Physical representation

An ABI value is, physically, its one Int field: a tagged 64-bit word in a
register (an immediate for `-2^62 <= v <= 2^62 - 1`, a static constant for
a literal, otherwise a BigInt pointer), the struct erased by the existing
struct scalar replacement. CLIF of a constant creator instance (`abi::i32` called with 42):

```
function u0:64(i64, i64) -> i64 system_v {      ; (vm, value)
block2(v0: i64, v1: i64):
    v3 -> v1
    jump block0
...
block0:
    return v3
}
```

`fn f(x: abi::U8)` receives `x.0` (the field) in a register; `x.value + 1`
is raw machine arithmetic (`runbox`, `riadd`, `rbox`) because `0..255`
survived into native lowering (`abi-numeric-typed-parameter-is-raw`). This is
not a calling convention: nothing says an `abi::I32` is a 32-bit slot, and a
closed instance may receive a constant or a raw word; machine meaning begins
only at `from_*`.

### Inspected cases

Each probe consumes the value inside a function called 1001 times
(`fn probe(n: int) -> int: <expr> + n`), on the default (specialized)
native backend:

| expression | creator instance | encoder instance | allocations |
|---|---|---|---|
| `abi::i32(42).value` | `retmulti %0` | -- | 0 |
| `abi::u32(42).value` | `retmulti %0` | -- | 0 |
| `abi::i64(-1).value` | `retmulti %0` | -- | 0 |
| `abi::u64(42).value` | `retmulti %0` | -- | 0 |
| `to_int(from_i32(abi::i32(42)))` | `retmulti %0` | `retmulti %0` | 0 |
| `to_int(from_u32(abi::u32(4294967295)))` | `retmulti %0` | `retmulti %0` | 0 |
| `to_int(from_u64(abi::u64(18446744073709551615)))` | `retmulti %0` | `igt`, `isub` | 0 |
| `to_int(from_u64(abi::u64(9223372036854775808)))` | `retmulti %0` | `igt`, `isub` | 1001 BigInt |

* **Wrappers allocate nothing** (no `structnew` anywhere in these programs).
* **Proven checks disappear**: a constant creator instance has no
  comparison, no fail path (`retmulti %0`). This is the generic M6 /
  `PureDecidedCondition` machinery the previous milestone extended; nothing
  ABI-specific was added. A dynamic creator keeps exactly its two
  comparisons and two declared-error paths, U64's bound `2^64-1` a static
  constant (no run-time arithmetic).
* **Provably invalid constants** are compile-time `KNOWN-ERROR`s through the
  existing completion proof (no ABI constant evaluator).
* `abi::i64(-1)`: the literal `-1` is source `0 - 1`, lowered (as for any
  small negative literal) to one raw subtraction and a box -- no allocation.
* The unspecialized baseline (`-specialize 0`, `cranelift-generic`)
  materializes one struct per ABI value that crosses a call, as it does for
  every struct (STRUCTS.md); 1001 `i32(42)` probes: 1001 structs.

### U64 and BigInt

* `U64` values `2^63 .. 2^64-1` are ordinary arbitrary-precision Ints: a
  literal is a static BigInt constant (never allocated), a computed one a
  heap BigInt, exactly as before (`abi::u64(2^64-1).value + 1` is `2^64`).
* `U64(2^64-1)` needs no BigInt *allocation* anywhere: the constant is
  static, and its word `-1` is a small Int (`from_u64`'s BigInt subtraction
  returns an immediate).
* `U64(2^63)`'s word is `-2^63`, outside the 63-bit small-Int range, so it is
  a BigInt while it is a tagged Int: one allocation per encoding (pinned,
  `abi-numeric-upper-u64-frontier`). In general an upper-half value `v`
  allocates its word iff `2^63 <= v < 2^63 + 2^62` (word `< -2^62`). The
  BigInt does not survive *past* register lowering: the syscall helper reads
  it as its `i64` word (`register_word`); the bits reach the kernel exactly
  (the Rust test above).

### Optimization frontier (remaining avoidable overhead)

1. **Struct field facts do not reach a closed instance.** The encoder
   instance is selected by its parameter's type (`instance="abi::U64"`), and
   range analysis tracks Int bindings only, so inside `from_u64` the value is
   known to be in `0..2^64-1`, not to be the caller's constant. Its `if v >
   2^63-1` therefore runs (one BigInt comparison through the runtime's slow
   path) and, on the upper-half path, one BigInt `isub`, even for
   `from_u64(abi::u64(2^64-1))`. `from_usize` is the same. Removing this
   needs per-field Range facts carried through struct construction, call
   results and instance entry (or a semantic instance keyed on field facts) --
   a general range-analysis extension, not an ABI rule, and deliberately not
   attempted here.
2. **The word of `2^63 <= v < 2^63 + 2^62` is a heap BigInt in transit**
   (above): a property of the 63-bit small-Int representation. Folding (1)
   would make constant cases static constants; a dynamic word in that range
   would still be boxed unless a raw `i64` transport representation reached
   the syscall operand.
3. **Comparisons with big bounds are helper calls.** A dynamic `abi::i64` or
   `abi::isize` creation (both bounds), and `abi::u64` or `abi::usize`
   (the upper bound), compares against a static BigInt constant; the native
   fast path needs both operands to be small Ints, so each such comparison
   is a run-time helper call even for a small argument (the previous
   milestone's dynamic `register64(n)` has the same shape). Deciding a
   comparison of a small operand with a static constant outside the small
   range from the constant's sign would be a general lowering improvement;
   it was not attempted here.
4. **The conversion calls remain calls.** Tiny-leaf inlining
   (TINY-EXACT-LEAF-INLINING.md) admits straight-line bodies of `const`,
   `ref`, `bind` and native calls only; a `struct`/`project` body (every
   creator's success path, every encoder) is not eligible, so each conversion
   is a direct call of a one-instruction function -- the same residual the
   previous milestone reported for `register64(39)`. No check and no
   allocation is involved.

Everything else on the canonical path is zero: no struct, no comparison in
creators or in signed/narrow encoders, no allocation.

## Compiler changes

| file | change | why |
|---|---|---|
| `hir/completions.tcl` | the walker's `project` case returns the Range the projected field's declared type implies (`hir::range::ConstrainType`) and records it, as `hir::range::Expr`'s `project` case already does | requirement 20: `fn f(x: abi::U8)` must know `0 <= x.value <= 255` *for the error proof too*; previously only a local bound to the projection carried it |
| `hir/range.tcl` | `FactsClause`: a TYPE diagnostic prints `facts: ...` only for an Int-kinded (or kind-less) value; `MismatchClause`: two different named structs get the nominal reason | requirement 32: a nominal mismatch must not read like an Int-range problem |
| `hir/range.tcl` | the same rule for "function result does not prove declared type" | consistency |
| `hir/sourcetypes.tcl`, `hir/errordecls.tcl` | `ElsewhereClause`: a duplicate *error* name whose earlier declaration is in another file says where it is, and that error names are program-wide (types are namespace members, IMPORTS.md) | the `abi::x86_64 -> abi` dependency brings the two global error names a program may not know it loaded |
| `surface/modules.tcl` | `ParseModule`: module ASTs cached by `{path, file text}` | the dependency's compile-time cost |
| `native/src/runtime/syscall.rs` | one Rust unit test (no runtime change) | requirement 27: the bits the kernel receives |

All are general: they apply to every struct field typed with a source
domain (`byte::Byte` fields included), every named struct mismatch, every
duplicate declaration and every module. No change to `core/`,
`native/lower.tcl`, the NIR, CLIF generation or the runtime's behavior.

**Behavior changes for existing programs.**

* The completion proof is now as precise at a projection as at a local, in
  both directions: a call whose errors the projection's domain rules out
  needs no handler (the purpose), and a call it proves *always* fails is now
  the compile-time `KNOWN-ERROR` it already was when written through a local
  (`check(s.v + 11)` with `s.v: Int in 0..10` and `check` failing above 10).
  Native code is unaffected (lowering reads no completion-proof result).
* Three pinned expectations in `tests/structs.test` changed, each from a glob
  that matched the old `, facts: ...` suffix to the exact new text:
  `struct-error-nominal-mismatch` (the nominal clause; no facts for a struct
  argument) and `struct-error-wrong-field-type` /
  `struct-error-no-implicit-guard` (an `int` or `any` value for a declared
  `str` field: no Int facts).
* `tests/linux-syscall.test`'s module-binding fixture also copies
  `lib/abi.bot` (its expectation is unchanged).

### How range facts survive into HIR and analysis

* A field typed `U8Value` is `int[U8Value]` in HIR (`hir::structs::fieldType`),
  so `x.value`'s static type carries the domain.
* `hir/range.tcl` reads the interval at every projection (`ConstrainType`):
  native lowering sees `x.value` in `0..255` (raw arithmetic; check-free
  encoders).
* `hir/completions.tcl` now does the same, so the call-specific error proof
  uses it: `abi::u16(x.value)` needs no handler for `x: abi::U8`, and
  `abi::i8(x.value)` can only fail above.
* At construction, `hir::range::VerifyStruct` proves the field from the
  creator's comparison narrowing (or the parameter domain in an encoder).

## Tests

`tests/abi-numeric.test`: 41 tests, every one naming its backends (the same
result whatever `CORE_BACKEND` is), and none disturbing a suite-wide
`BOTLISH_NATIVE_GC_STRESS`.

* **Library:** module path; ten structs, one `value` field each, typed with
  its own domain; the exact ten intervals; Isize/Usize equal to I64/U64 on
  this target yet separately declared (no parent, not subtypes); the compiler
  knows no ABI type (no native, and no non-comment line of `core/`, `hir/`,
  `native/`, `surface/`, `compiler/` or any Rust source names a member,
  domain or error, and the only abi natives are `linux::abi::syscall` and
  the ten generic predicates every source `type` gets); names (a
  program's own `U8Value` beside `register64` and beside `abi::U8Value`; a
  real *error* name collision names `lib/abi.bot`; a same-file duplicate
  unchanged).
* **Boundaries, one test per type, all four backends:** min-1, min, min+1,
  -1, 0, 1, min/2, max/2, max-1, max, max+1, `-2^128`, `2^128`; for U64/Usize
  also `2^63-1`, `2^63`, `2^63+1`; for I64/Isize also `2^63`, `-2^63-1`. Each
  accepted value returns through `.value` unchanged and encodes as its word
  (independent Tcl oracle); each rejected one is the declared error of its
  bound.
* **Round trips** (U64 `0, 1, 2^63-1, 2^63, 2^64-1` among them), **no
  wrapping** (`u8 255 + 1 = 256`, `i8 -128 - 1 = -129`, `u64 max + 1 = 2^64`,
  re-entry only through the creator).
* **Static proofs:** both extremes of every domain need no handler; one past
  each bound, of every domain, is `KNOWN-ERROR` naming exactly that bound's
  error (the complete list the message gives); dynamic Ints must be handled; the
  unhandled obligation is reported at the creator call; field domains survive
  (`byte::from_int(x.value)` as a direct argument, widening, one-sided
  narrowing); explicit conversion through Int; direct construction needs
  proof.
* **Nominal:** parameters (with the exact new diagnostic), equality, no
  arithmetic or ordering (TYPE on all backends), collection lengths stay Int.
* **Encoding:** the 21 bit patterns above; bits are transport, not
  interpretation; encoders total and nominal; `register64` unchanged.
* **Native evidence:** constant creators and narrow encoders are single
  `retmulti`s with no op, fail path or struct and 0 allocations; dynamic
  creators keep exactly two checks with a static bound; typed parameters are
  raw; the U64 frontier pinned (one `igt` and one `isub`; 0 allocations for
  `2^64-1`, 1001 BigInts for `2^63`, 0 for a lower-half Usize); syscall
  operands are the encoders' results; GC stress over Lists of ABI values and
  BigInt words.
* **Examples:** `examples/abi/numeric-domains.bot` on all backends;
  `examples/linux/getpid.bot` unchanged.
* **Seeded fuzz** (below).

Rust: `abi_numeric_words_are_their_register_bit_patterns` (above). Like the
previous milestone's Rust tests it runs with `cargo test --release`, which CI
does not run (CI builds the backend and runs the Tcl suites).

`tests/linux-syscall.test` runs unchanged except one fixture line: its
module-binding test copies `lib/abi/x86_64.bot` into a temporary library
directory, and now also copies `lib/abi.bot`, which the encoders use.

## Fuzz results

`audit/abi-numeric-domains/tools/fuzz.tcl` (pure conversions only; no
syscall is fuzzed). Per seeded program, for **all ten domains** at once: V
values per domain strongly biased to `min-1, min, min+1, -1, 0, 1, max-1,
max, max+1` and the `2^63` transition (`2^63-1, 2^63, 2^63+1, 2^64-1,
-2^63, -2^63-1`), plus uniform in-domain values, arbitrary 64-bit patterns
(read signed and unsigned) and arbitrary BigInts up to `2^100`; checked
against an independent Tcl oracle on every backend:

* dynamic creation, `.value` and the encoded word;
* the round trip through a typed parameter re-created twice from `.value`
  with no handler (a compile-time proof, and a run-time value check);
* narrowing between two random domains through Int;
* one constant per domain: no diagnostic in range, else `KNOWN-ERROR` naming
  the bound (and the right value in range).

Mutation check of the fuzzer itself (scratch library copies, not committed):
an upper-half encoding off by one, a U16 upper bound off by one, and an I8
lower bound off by one were each detected.

```
$ tclsh9.0 audit/abi-numeric-domains/tools/fuzz.tcl -n 200 -seed 1
abi-numeric-fuzz programs 200 values 50600 out-of-range 20978 constant-checks 2000 failures 0
    (interp, compile, cranelift-generic, cranelift)

$ tclsh9.0 audit/abi-numeric-domains/tools/fuzz.tcl -n 30 -seed 5001 -gc-stress 1 \
      -backends "cranelift-generic cranelift"
abi-numeric-fuzz programs 30 values 7590 out-of-range 3098 constant-checks 300 failures 0
```

(`audit/abi-numeric-domains/fuzz-result.txt`.)

Plus the in-suite seeded fuzz (`abi-numeric-fuzz`: 2 seeds x 10 domains x
24 values, four backends, one seed again under GC stress natively): 0
failures.

## Regression

On the final tree, Linux x86-64, Tcl 9.0.1, rustc 1.97 (each suite run in
its own working and tcltest temporary directory):

| run | result |
|---|---|
| `CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5088 tests: 5088 passed, 0 failed |
| `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` | 5088 tests: 5084 passed, 4 skipped (the existing `coreScoping` constraint), 0 failed |
| `BOTLISH_NATIVE_GC_STRESS=1 CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5088 tests: 5088 passed, 0 failed |
| `tclsh9.0 tests/native-coverage.tcl` | 5122 tests on cranelift: 2162 native, 2831 independent, 69 passed-partial, 60 unsupported (all pre-existing test-only natives and constructs), **0 failed** |
| `cargo test --release` (native/) | 152 + 28 passed, 0 failed (one new test) |

The only failures seen along the way were the expected pins listed under
"Behavior changes for existing programs" (three `structs.test`
expectations, the `linux-syscall.test` fixture), updated with the change.
The previous milestone's figures were 5047 tests and 151 + 28 Rust tests;
the difference is this milestone's 41 new tests and one Rust test.

## Review

An independent adversarial review (soundness of the completion-proof change,
every bound and encoder, the diagnostic change, test and fuzzer quality,
the report's claims) found the bounds, the encoders and the completion
change's soundness correct. Changed as a result:

* **A regression fixed:** the domain types were first named `U8Value` ...,
  and because `abi::x86_64` now loads `lib/abi.bot`, a program declaring its
  own `type U8Value` (or `error AbiIntegerAboveRange`) and using only
  `register64` stopped compiling, with an error at its own declaration. The
  types were then `U8Value` ... (now `abi::U8Value`, IMPORTS.md), and the
  dependency's compile-time cost is measured and reduced (module parse
  cache).
* The mismatch diagnostics print facts only when both sides may be Ints
  (not for a function-typed argument, nor for an Int passed to a struct
  parameter), and the result-type diagnostic follows the same rule.
* Tests sharpened: the KNOWN-ERROR checks compare the complete error list
  for both bounds of every domain (the fuzzer likewise); the collections
  test pins the exact TYPE error; the "compiler knows no ABI type" scan
  covers `compiler/` and every Rust source at any depth.
* The report now states the completion change's second direction (a newly
  provable KNOWN-ERROR), the comparison-with-big-constant helper calls, the
  exact small-Int range, the changed `structs.test` pins, and that CI does
  not run `cargo test`.

## Milestone report

1. **Source declarations:** above ("`abi` (lib/abi.bot)"): ten
   `type AbiXValue = Int in LO..HI` domains and ten one-field structs
   `struct X: value: AbiXValue`.
2. **Creators and errors:** `abi::i8 ... abi::usize`, each `(value: int) -> X
   errors AbiIntegerBelowRange, AbiIntegerAboveRange`.
3. **Exact ranges:** the table above; U64/Usize include `2^63 .. 2^64-1`.
4. **Isize/Usize width:** their two domain declarations in `lib/abi.bot`'s
   marked TARGET-DEPENDENT section, chosen for the only supported target
   (Linux x86-64, 64-bit addresses); the x86-64 layer encodes them at 64
   bits.
5. **Nominally distinct from I64/U64:** yes -- distinct structs, separately
   declared domains; not interchangeable as parameters, never equal.
6. **Back to Int:** `x.value`, the field projection, exactly the represented
   Int, statically typed with the domain.
7. **Ordinary Botlish or compiler help:** entirely ordinary Botlish. General
   compiler improvements were made alongside (projection facts in the
   completion proof; mismatch and duplicate-declaration diagnostics; a
   module parse cache); none knows the family.
8. **Range facts in HIR/analysis:** the field type is `int[AbiXValue]`; range
   analysis and (now) the completion proof read the interval at every
   projection; constructions are proven by `VerifyStruct`.
9. **Proven creator checks:** generic M6 decided branches plus
   `PureDecidedCondition` (no condition evaluated) under the call's instance
   entry facts: a constant's creator instance is `retmulti %0`; an invalid
   constant is `KNOWN-ERROR`.
10. **Signed encoding:** sign extension = the value itself as the signed
    word.
11. **Unsigned encoding:** zero extension = the value below `2^63`, `v -
    2^64` (same bits, signed reading) at or above.
12. **High-bit U64/Usize:** as the negative word `v - 2^64`; in transit a
    small Int or (for words below `-2^62`) a BigInt read back as its exact
    `i64` by the syscall helper.
13. **Register64 representation change:** none.
14. **Spelling:** one nominally typed encoder per ABI type,
    `abi::x86_64::from_i8 ... from_usize`; no dispatch on argument types,
    hence no overloading.
15. **Native physical representation:** one tagged 64-bit word in a register
    (immediate / static constant / BigInt pointer), struct erased.
16. **Allocation:** none on the canonical specialized path (creators,
    signed and narrow encoders, `U64 2^64-1`); one BigInt per encoding for
    upper-half words below `-2^62`; the unspecialized baseline materializes
    structs at calls.
17. **BigInt for upper-half U64:** constants are static; computed values are
    BigInts as any Int there; `from_u64`'s `isub` returns a small Int unless
    the word is below `-2^62`; the BigInt ends at the syscall helper's `i64`
    read.
18. **Register-bit tests:** 21 patterns on all backends, the Rust boundary
    test, the NIR operand test.
19. **Interpreter/compiler differential:** every pure test runs on interp,
    compile, cranelift-generic and cranelift and requires agreement.
20. **Fuzz:** above.
21. **Full regression:** above.
22. **raw getpid():** unchanged (`examples/linux/getpid.bot` untouched; it,
    and all 37 `linux-syscall.test` tests, pass -- the one fixture line
    aside).
23. **Optimizer limitations discovered:** the frontier above (struct field
    facts, upper-half BigInt words, comparisons with big static bounds as
    helper calls, struct-bodied functions not inlined), plus: the completion proof leaves a counted loop's induction variable
    unseeded (deliberately, `hir/completions.tcl`), so `abi::u8(i)` in
    `loop i from 0 to 256:` needs a handler although `hir/range.tcl` proves
    `i` in `0..255`; and arithmetic on a struct is a run-time, not a
    compile-time, TYPE error.
24. **Before borrowed ABI memory views:**
    * *Private/trusted construction.* ABI numerics and Register64 are sound
      without privacy because every in-domain value is valid. A view
      (`{address, length}`) is not: arbitrary construction forges pointers.
      `abi::Bytes` needs a construction only trusted code can perform.
    * *Struct field facts.* A view's length will typically be an
      `abi::Usize` field; checks against it (and the frontier above) need
      field facts that flow through constructions and calls.
    * *Global names.* Every new error adds a global name (as
      `AbiInteger*Range` do); domain types are namespace members now
      (`abi::I8Value`...), but `error` declarations are not yet namespaced,
      which would keep a growing ABI layer from colliding with programs.
    * *Counted-loop proofs.* Index/length loops that convert to `abi::Usize`
      will want the completion proof to seed the induction variable.
    * *The bound-register-struct frontier* (LINUX-X86-64-SYSCALL.md) still
      applies to wrapper code that binds a register literal to a variable.
