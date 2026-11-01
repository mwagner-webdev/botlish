# C-FFI.md

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: C `float` is
> `std::ffi::c::Float` (binary32, its values Float64s: a Float64 passed to one is
> rounded to nearest, ties to even, and an overflow is `NonFiniteFloat`
> before C runs), and `std::ffi::c::Float` and `std::ffi::c::Double` are C types of
> pointees, function pointer signatures and layout fields too; `long double`
> stays out (sections 3 and 26).

`extern c library` and `extern c fn`: Botlish's first real C calls. A
program declares the C functions it calls, by their C signatures and the
contract of each pointer parameter, and the libraries it links; the native
backends compile every call to a direct call of the linked symbol with the
platform C calling convention, and the system linker resolves the symbols.

> Keep C interop truthful and low-level. Reuse the platform ABI and linker
> where they already solve the machine problem; reuse Botlish's existing
> value, borrowing and capability mechanisms where they already solve the
> language problem. Do not create a second C ecosystem inside the Botlish
> compiler.

```botlish
# sha256.bot -- an application module (examples/ffi/sha256/)
import std::abi
import std::abi::bytes
import std::ffi::c

extern c library "crypto"
extern c library "stdc++"

extern c fn SHA256 named "botlish_bssl_SHA256"(
    data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape,
    len: std::ffi::c::ULong,
    out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape
) -> std::ffi::c::Ptr[std::ffi::c::UChar] alias out

fn digest(data: std::abi::bytes::Bytes) -> std::abi::bytes::Bytes:
    written = data.SHA256(std::abi::bytes::length(data).value, std::abi::bytes::zeroed(std::abi::usize(32)))
    std::abi::bytes::freeze(written.out)
```

`digest` hands BoringSSL the input Bytes' own storage for reading (no
copy), a private copy of a fresh 32-byte MutableBytes for writing, and gets
the bytes C wrote back as `written.out`; the pointer SHA256 returns is
exactly `out`, so the call yields unit in its place. Nothing in the module
is `direct`: both pointers are noescape.

This milestone builds the call, on the substrates three earlier milestones
built for it: the C ABI value types (C-ABI-TYPES.md), temporary byte
exposure under a per-parameter contract (C-POINTER-BORROWING.md, whose
section 14 is the hook this fills) and the module-level capability boundary
(DIRECT-MODULES.md). It adds no value, type, borrowing or capability
mechanism of its own: what is new is the declaration, its registration as a
foreign native, the ABI transport and the link.

## Contents

* [1. Syntax](#1-syntax)
* [2. Declarations](#2-declarations)
* [3. The ABI surface](#3-the-abi-surface)
* [4. Contracts](#4-contracts)
* [5. Calls](#5-calls)
* [6. Byte borrowing and write-back](#6-byte-borrowing-and-write-back)
* [7. Pointer results](#7-pointer-results)
* [8. Transport: nothing is truncated](#8-transport-nothing-is-truncated)
* [9. direct](#9-direct)
* [10. Representation](#10-representation)
* [11. Linking](#11-linking)
* [12. Backends](#12-backends)
* [13. Targets](#13-targets)
* [14. Static compile, interchange, cache, isolation](#14-static-compile-interchange-cache-isolation)
* [15. The single executable](#15-the-single-executable)
* [16. Examples](#16-examples)
* [17. The Tcl binding](#17-the-tcl-binding)
* [18. The BoringSSL binding](#18-the-boringssl-binding)
* [19. Standalone executables](#19-standalone-executables)
* [20. GC stress](#20-gc-stress)
* [21. Performance](#21-performance)
* [22. Tests, fuzzing, mutants](#22-tests-fuzzing-mutants)
* [23. Regression](#23-regression)
* [24. Architectural boundaries](#24-architectural-boundaries)
* [25. For a binding generator](#25-for-a-binding-generator)
* [26. Not here](#26-not-here)
* [27. What to run when changing this](#27-what-to-run-when-changing-this)
* [28. Files](#28-files)

## 1. Syntax

Three top-level declarations, in any module or the entry program:

```
externLibrary := "extern" "c" "library" STRING ["static" ["at" STRING]]
externFramework := "extern" "c" "framework" STRING

externFn      := "extern" "c" "fn" NAME ["named" STRING]
                 "(" [param ("," param)* ["," "variadic"] [","]] ")"
                 "->" resultType [resultFact]
param         := NAME ":" type [access] [escape]
access        := "read" | "write"
escape        := "noescape" | "proven" "noescape" | "captures"
resultType    := type | "unit"
resultFact    := "independent" | "alias" NAME
```

```botlish
extern c library "botlish_cffi_fixture"

extern c fn add named "bcf_add"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int
extern c fn nothing named "bcf_nothing"() -> unit
extern c fn sum named "bcf_sum"(data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape, count: std::ffi::c::ULong) -> std::ffi::c::ULong
extern c fn keep named "bcf_keep"(p: std::ffi::c::Ptr[std::ffi::c::Void] captures) -> unit
```

* **No body.** An extern c fn is a declaration of a C function, not a
  Botlish function with a magic call inside: a `:` after the signature is an
  error, and so is an `errors` clause (C reports no Botlish error).
* **`c` is the ABI**, the only one: `extern fn`, `extern rust fn` are
  errors naming it.
* **A library is its linker name**, the `NAME` of the platform linker's
  `-lNAME` (`"crypto"` for `libcrypto.a`/`libcrypto.so`): letters, digits
  and `_ + . -`, not starting with `-`. A path or a `-l` flag is an error
  naming the form, and so is an unquoted name. (A file name such as
  `"libcrypto.a"` is a name the linker will not find: `-llibcrypto.a`.)
* **`static`** requires the library's static archive, and **`static at
  "PATH"`** names its file, relative to the application root (a
  package's module: its package's directory) unless absolute; **`extern c
  framework "NAME"`** links an Apple framework
  (NATIVE-LINK-PLAN-MILESTONE-1.md; section 11).
* **`named "SYMBOL"`** overrides the link symbol (section 2): letters,
  digits, `_ . $`, not starting with a digit. One `named` per declaration.
* **The signature is the C signature**: every parameter typed, the result
  type required (`-> unit` for void). A variadic C function (C's `...`)
  ends its parameters with the bare word `variadic`, after at least one
  fixed parameter, with nothing after it and no name or type of its own:
  each call passes its own C types (VARIADICS-VERTICAL-SLICE-1.md; `..`,
  `...` and a trailing `.` stay errors, the `...` one naming `variadic`).
* **Facts** follow a parameter's type and the result type; each is stated
  at most once.
* **Declarations are top-level** (a module's or the entry program's own),
  never inside a function or a block.

Every word after `extern` (`c`, `library`, `named`, `read`, `write`,
`noescape`, `proven`, `captures`, `independent`, `alias`) is contextual: an
ordinary name everywhere else (`cf-parse-contextual`). Every malformed form
is a located `EXTERN-SYNTAX` error naming what is wrong and the remedy
(`cf-parse-errors`, `cf-parse-messages`), and a recovering parse reports
each one once (`cf-parse-recover`).

## 2. Declarations

**Identity.** An extern c fn's identity is its Botlish qualified name --
`boringssl::SHA256` for module `boringssl`'s `SHA256`, the bare name for
the entry program's -- exactly a function's. It is a member of its module
(`boringssl::SHA256(...)`, or method syntax through the module's import:
`data.SHA256(...)`, `cf-method-syntax`), visible in the whole declaring
unit like a type, and the entry program's are visible in the entry program
only (`cf-entry-program-declares`). Two declarations of one qualified name
are `DUPLICATE`, never merged, whatever their signatures; a function and an
extern of one name are the ordinary duplicate binding; two modules may
declare the same C symbol, each with its own Botlish name and contract
(`cf-decl-duplicate`). There is no registry of symbols: Botlish module
identity is independent of linker symbol identity, and two declarations of
one symbol with different signatures are each their author's ABI promise --
not diagnosed, since no check could cover every external linkage, and no
whole-program C symbol-type verification is attempted.

**The link symbol** is the declaration's name, or `named`'s string. `named`
changes exactly the symbol: the Botlish name stays the declaration's
(`cf-named-symbol`). It is how a binding gives a C function a Botlish name
(`plus` for `bcf_add`) and how it binds a symbol that is no Botlish name at
all (BoringSSL's prefixed `botlish_bssl_SHA256`).

**A library is a link-plan entry, never a function's.** `extern c library`
adds a name to the program's link plan; it associates with no extern c fn,
and an extern c fn names no library. The system linker resolves every
symbol against every library of the plan (section 11), so a library may be
declared in the module that binds its functions, in another module, or in
the entry program, and one library may serve functions declared in several
modules (`cf-direct-two-modules-one-library`). The plan holds each name
once, in first-declaration order -- the loader's order: a module's own
declarations after its imports', the entry program's last
(`cf-link-plan`). Declarations of one library merge into the strictest
requirement (the linker's choice, a static archive, a named archive); two
that no archive satisfies are `LINK-CONFLICT` (NATIVE-LINK-PLAN-MILESTONE-1.md,
"Conflicting and repeated declarations").

**Validation** is the front end's and located: every type must be a C ABI
value type (`cf-decl-types`), every fact one its parameter or result can
have (`cf-decl-facts`, section 4).

## 3. The ABI surface

C-ABI-TYPES.md's value universe, and C `_Bool` (C-BINDGEN.md, "C bool"),
nothing else:

| C | Botlish | ABI class |
|---|---|---|
| `signed char`, `unsigned char`, `char` | `std::ffi::c::SChar`, `std::ffi::c::UChar`, `std::ffi::c::Char` | `i8`, `u8`; `char` by the target (`i8` on x86-64 and Apple AArch64, `u8` on Linux AArch64) |
| `short`, `unsigned short` | `std::ffi::c::Short`, `std::ffi::c::UShort` | `i16`, `u16` |
| `int`, `unsigned int` | `std::ffi::c::Int`, `std::ffi::c::UInt` | `i32`, `u32` |
| `long`, `unsigned long` | `std::ffi::c::Long`, `std::ffi::c::ULong` | `i64`, `u64` on LP64 (`i32`, `u32` on LLP64) |
| `long long`, `unsigned long long` | `std::ffi::c::LongLong`, `std::ffi::c::ULongLong` | `i64`, `u64` |
| `_Bool` (`bool` of `<stdbool.h>`) | `std::ffi::c::Bool`, which is Botlish's `bool` | `bool`: one byte, 0 or 1, zero-extended like `u8` |
| `T *` | `std::ffi::c::Ptr[T]` (T a scalar, `std::ffi::c::Void`, an opaque struct, a pointer) | `ptr` |
| `R (*)(A...)` | `std::ffi::c::FnPtr[Fn{args: [...], return: R}]` | `ptr` |
| `void` (result) | `unit` | `void` |

A parameter's ABI class is its type's width and signedness on the
compilation's target, read from the type registry's `cabi` metadata
(`core::type::cabiScalar`), never from its name (`cf-abi-classes-follow-
the-target`: `long` is 64 bits for `-target linux-x86_64` and 32 for
`windows-x86_64`, plain `char` signed on x86-64 and unsigned on
`linux-aarch64`). size_t, uint8_t and the other typedefs are a binding
author's (or a future generator's) choice of the scalar the target's ABI
probe says they are (`size_t` is `std::ffi::c::ULong` on LP64): the compiler
knows no typedef.

`std::ffi::c::Double` (C `double`, Botlish's Float64; FLOAT64-MILESTONE-1.md) is
a parameter and result type too: it travels in the target's floating-point
registers (the stack beyond them), a Float64 passed out is never negative
zero, and a double returned that is not finite -- NaN or an infinity -- is
the call's declared error `NonFiniteFloat` (a declaration whose result is
Double declares it).

A variadic declaration's trailing arguments are typed per call
(VARIADICS-VERTICAL-SLICE-1.md): each is a C integer scalar, `std::ffi::c::Bool`,
Float64 (`double`), an `std::ffi::c::Ptr` or an `std::ffi::c::FnPtr` -- a plain `int`,
a String, a List, a struct, byte storage or an erased value is refused at
the call -- passed as C's default argument promotions make it (an integer
narrower than `int`, and `_Bool`, as `int`). The call's machine signature is
its own: x86-64 System V states the vector registers it used in `%al`,
Linux AArch64 passes the trailing arguments as AAPCS64 passes any, and Apple
AArch64 passes every one of them on the stack in an 8-byte slot. A
`va_list` parameter is a fixed one, which nothing here represents.

Not here, each an error at the declaration: C `float` and `long double`,
structs or unions by value, arrays (a parameter `uint8_t out[32]` is the pointer it
decays to), a `va_list`, `unit` as a parameter, an imprint variable in a
signature (one C function has one ABI), a Botlish value type that is no C
type (`int`, `str`, `Bytes`: byte storage reaches C only through a pointer
parameter's contract, section 6).

## 4. Contracts

Each declaration is registered with exactly the foreign call contract a
`-foreign` native has (core/cabi.tcl's `NormalizeForeign`,
C-POINTER-BORROWING.md section 3) -- one representation, which every
consumer reads:

```
params      {name type access escape} per parameter (access and escape
            only on pointers; access only on data pointers)
result      the C result type, or unit
provenance  unknown | independent | {alias PARAM}   (pointer results only)
```

| written | contract |
|---|---|
| `read` / `write` | access `read` / `write`; nothing written: `unknown` |
| `noescape` | escape `declared-noescape` (the binding author's statement) |
| `proven noescape` | escape `proven-noescape` (evidence: an analysis, a compiler attribute) |
| `captures` | escape `captures` (C may keep the pointer past the call) |
| nothing | escape `unknown` |
| `independent` | provenance `independent`: the result points into no argument |
| `alias P` | provenance `{alias P}`: the result is exactly parameter P's pointer |
| nothing (pointer result) | provenance `unknown` |

An absent fact is `unknown`, and `unknown` is never treated as the
favorable answer: an unknown escape retains (section 9) and admits no
exposure, an unknown access admits no exposure, an unknown provenance admits
no exposure on the same call (section 7). `const` in the C declaration is no
fact: SHA256's `const uint8_t *data` is `read` because its author says so,
and noescape only because they say that too. Proven and declared noescape
are equivalent for every decision here; the distinction is the record of
the evidence (C-POINTER-BORROWING.md, "evidence").

A fact is a pointer's: `read`/`write` on a scalar or a function pointer, a
provenance on a non-pointer result, and an `alias` naming a parameter that
is not one or is of another type, are located `TYPE` errors at the
declaration (`cf-decl-facts`). Where the facts come from -- a header, an
ABI probe, a compiler's `nocapture`/`returned` attribute, a person -- is
nothing the compiler knows (section 25).

A function pointer parameter's escape is also its callback contract
(C-CALLBACK-MILESTONE-1.md, section 8): `noescape` (declared or proven) on
a `std::ffi::c::FnPtr` parameter says C may call the pointer during the
call and keeps it no longer, so every call of that function is a *foreign
transition* during which C may call a Botlish callback back (NIR's
`callbacks=1`). `captures` or nothing stated is a retaining call (section 9)
and no transition: a callback C calls then, or later, is refused at run
time. A data pointer's noescape says nothing of callbacks.

## 5. Calls

A call of an extern c fn is an ordinary call node of a root native
`extern#KEY` (`KEY` the qualified name; `#` is no source spelling). It is
typed, admitted and checked by the machinery every call has:

* **Arguments** are held to the declared C types by the ordinary admission
  proof: a C scalar is an integer domain, so an `int` argument needs its
  range proven (a literal, a comparison, a declared `std::ffi::c::Int`
  parameter), never wrapped or truncated (`cf-call-typing`); a pointer
  parameter admits an `std::ffi::c::Ptr` of exactly its type, or byte storage
  under its contract (section 6).
* **Arity** is the C signature's: a call passing another number of
  arguments is a compile-time `ARITY` naming the declaration ("bcf::add is a
  C function of 2 parameter(s), its declaration's C signature, and this
  call passes 1 argument(s)").
* **The result** is the declared C type -- an integer domain value, an
  affine `std::ffi::c::Ptr`, an `std::ffi::c::FnPtr`, unit -- or, with a write
  exposure, the write-back struct (section 6).
* **Not a value.** An extern c fn is only called: bound, passed or returned
  as a value it is `TYPE` ("bcf::add can only be called directly: it is a C
  function (extern c fn), and a call through a function value would have no
  C signature, no contract and no link symbol", `cf-not-a-value`). A C
  function pointer value is `std::ffi::c::FnPtr`, which Botlish passes and
  receives but never calls (`cf-function-pointers`).
* **Ownership.** Every parameter observes: an affine `Ptr` argument stays
  its owner's (an observed temporary needs an owner first: bind it).

## 6. Byte borrowing and write-back

Exactly C-POINTER-BORROWING.md, through real C. A byte-pointee parameter
(`Char`, `SChar`, `UChar`, `Void`) whose contract says noescape and states
an access admits existing storage for the one call:

* **read noescape**: an `std::abi::bytes::Bytes` or `MutableBytes` is exposed as
  it is -- its own storage's address, no copy (`cf-borrow-read`);
* **write noescape**: a `MutableBytes` is detached into a private copy, C
  writes the copy, and the call's value is the write-back struct
  `{result: R, NAME: MutableBytes}` (NAME the parameter's), the caller's
  value and every copy of it unchanged (`cf-borrow-write`, against real C:
  the SHA-256 acceptance's original MutableBytes is still all zeros after
  BoringSSL wrote the digest).

Refused, `FOREIGN-BORROW`, as for every foreign call: storage where the
contract may keep the pointer (captures, unknown), an immutable Bytes at a
write parameter, a pointee that is not byte-sized (`cf-borrow-refusals`).
There is no pointer value of byte storage, ever: a Bytes is never an
`std::ffi::c::Ptr`. C strings are bytes: a `const char *` argument is a Bytes
holding the string and its NUL, which the binding (not the compiler) adds
(`examples/ffi/tcl/demo.bot`'s `script`).

The exposures are made after every argument is evaluated, and kept alive
by a `keepalive` of each exposed storage after the call (NIR in section 10);
an unchecked (`-strict 0`) program's refused exposure replays the refusal at
run time, the C call never made (`cf-strict0-replay`).

**C error state** (C-FFI-ERROR-CAPTURE-MILESTONE-1.md,
C-FFI-ERROR-CAPTURE-MILESTONE-2.md). A C function that fails the POSIX way
returns a sentinel and leaves the reason in errno; its binding reads errno
right after the call (`std::darwin::errno()`: a C call of `__error()`,
`__errno_location()` on glibc, and a native view). Nothing the compiler
inserts runs in between: the keepalive is no machine code, a write-back
value is fields -- the C result and the private copies -- built only where
a use needs an object, and a 64-bit integer result is the machine word C
returned (a C word, section 8), compared with its sentinel as it is --
`(size_t)-1` included -- and boxed only at its first use that needs an Int.
So the comparison of the result and the errno read follow the call
directly, with no allocation, safepoint or runtime call, whatever the
result's value and whatever the lowering: this foreign-result transport is
a correctness rule of native lowering, not an optimization, and
`-struct-opt 0`, `-specialize 0` and the other representation policies
keep it (a write-back value escape analysis leaves alone -- a binding a
closure captures, struct scalar replacement off -- is held as fields all
the same, and built at its first use that needs it, a loop's at the
loop's entry). The compiler knows no error convention: it reads no errno,
adds no field, translates nothing -- it only adds nothing. What it does not
cover: a C `float`/`double` result (a Float64 is a heap object, built by
the call), a value returned from the function that made the call before
anything read errno, and what the program itself builds before its read
(C-FFI-ERROR-CAPTURE-MILESTONE-2.md, section 32). `tests/c-ffi-error-
capture.test` proves it in NIR, in the object file's machine code, by
single-stepping the executable, and with an allocator that changes errno,
in every lowering mode.

## 7. Pointer results

A pointer result is truthful: SHA256 returns `uint8_t *`, so its
declaration's result is `std::ffi::c::Ptr[std::ffi::c::UChar]`, never a void
pretending C's register is ignored (C-POINTER-BORROWING.md section 14 had to
declare it unit; the provenance fact is what lets it stay a pointer). What a
call yields depends on where the result points, which only the contract can
say:

| provenance | the call's result |
|---|---|
| `independent` | a fresh `std::ffi::c::Ptr` (`Tcl_CreateInterp`) |
| `alias P`, P a raw `Ptr` argument | a new `std::ffi::c::Ptr` of the same address (`bcf_echo_ptr`) |
| `alias P`, P exposed byte storage | unit in its place: a pointer into Botlish storage never outlives the call (SHA256's `out`) |
| `unknown`, nothing exposed | a fresh `std::ffi::c::Ptr` (C-ABI-TYPES.md's raw pointers) |
| `unknown`, storage exposed | `FOREIGN-BORROW`: the result may point into the exposure (memchr's shape, `cf-result-provenance`) |

**The contract is checked where the run sees it.** An `alias P` result that
is not exactly P's address is a `CONTRACT-VIOLATION` failure right after the
call -- for an exposure (the result discarded) and for a raw pointer alike
(`cf-contract-violation`, `bcf_reverse_off` returning `out + 1`). It is a
development assertion of the binding's contract: one compare and a
never-taken branch, always on. No other fact can be checked by observing a
call (an escape or an access is a property of C's code, not of its result),
so none is.

## 8. Transport: nothing is truncated

| Botlish word | to C | from C |
|---|---|---|
| small Int (`(n << 1) \| 1`), a narrow scalar | `n`, reduced to the class width; extended by the call's signature (`sext`/`uext`) | sign- or zero-extended from the class width by Botlish, whatever the callee left in the register's other bits, then tagged |
| Int, a 64-bit scalar | `n`: inline for a small Int, `rt_ffi_int_word` for a BigInt | the machine word itself, a C word (an `i64` or `u64` register: C-FFI-ERROR-CAPTURE-MILESTONE-2.md), compared as it is (`cwlt` ... against a `cword` constant or an Int) and made an Int at its first use that needs one (`cwbox`: tagged when it fits the small range, else a BigInt, `rt_ffi_box_i64`, `rt_ffi_box_u64`) |
| C address word (`(a << 4) \| 0b1110`) | `a` (an arithmetic shift: null, word 14, is 0) | `(a << 4) \| 0b1110` when `a` fits the word's sign-extended 60 bits, else a `NATIVE ADDRESS` failure |
| exposure address (a small Int, `bytesaddr`/`mbytesaddr`) | the address | -- |
| bool (`false`, `true`) | the byte 0 or 1, zero-extended to the register like an `unsigned char` (on x86-64 to its 32 low bits, as GCC and Clang callees read a `_Bool`) | the result byte: 0 is `false`, 1 is `true`, anything else a `NATIVE BOOL` failure naming the function and the byte, never a bool made of one bit (`cf-bool-invalid`) |

The admission proof has already held every scalar argument inside its C
type's range, so converting one never wraps. Every canonical x86-64 address,
user or kernel, and every untagged AArch64 one fits a C address word; a
top-byte-tagged AArch64 pointer does not, and is a failure naming the
function and the address, never a masked or truncated pointer
(`cf-wild-address`, `bcf_wild` returning `0xf000000000000010`). Every C
integer scalar crosses both ways at both bounds (`cf-scalar-transport`,
2^64 - 1 as a BigInt both ways); a narrow result is correct whatever is in
the register beyond its width (`cf-scalar-extension`: the fixture's
hand-written `bcf_dirty_*` return 0x80 in a register of 0x5555...80);
arguments past the argument registers go on the stack
(`cf-stack-arguments`, ten mixed arguments).

What a call arrives in is checked against the target's C ABI itself
(MACOS-AARCH64-MILESTONE-6.md): the fixture's `bcf_capture`, assembly,
records the argument registers, all 64 bits each, and the bytes at the
stack pointer at its entry, before any compiled code can extend or move
them, and `bcf_reference_*` make the same calls from C. A model of the
host target's ABI written from its documents (six or eight argument
registers; Apple's packed stack slots or one 8-byte slot each; the caller
extending a narrow register argument to 32 bits on Apple AArch64 and
x86-64, only its own width defined on Linux AArch64) predicts both
(`cf-abi-register-extension`, `cf-abi-stack-layout`), and `bcf_pick`, C
compiled for a twenty-parameter prototype, reads each argument back
(`cf-abi-pick`): a callee that trusts its caller's extension, as Apple
clang's does, turns a wrongly extended register into a wrong value.

## 9. direct

A foreign call is not direct by being foreign (`cf-direct-noescape-
ordinary`): a module whose C calls are all noescape -- which pass raw
pointers, receive them, expose bytes for one call -- is ordinary. Directness
comes from what a C function may do with authority after the call returns:

* a call of an extern c fn whose contract **may retain a pointer** -- a
  pointer parameter with escape `captures` or `unknown`
  (`core::cabi::RetainingParameters`, the borrowing milestone's direct hook)
  -- is an **authority source**, a direct edge of the calling unit like a
  call into a designated direct module, named by the declaration and the
  retaining parameter (`cf-direct-retaining`: "bcf::keep, a C function whose
  contract lets it retain pointer authority past the call (parameter "p":
  escape captures)");
* it is mediated exactly as any edge is: from a function requiring a context
  the calling unit declares itself (`cf-direct-contextualized`), or
  acknowledged by `direct module` (`cf-direct-declared`);
* **declaring** a retaining extern designates nothing: a module that only
  declares one is ordinary (stale if marked `direct module`), and the
  authority is its callers' -- a call of it from its own module is an edge
  too (`cf-direct-not-predesignated`);
* the capability boundary is the module: one C library can be bound by an
  ordinary module (its noescape functions) and a direct one (its retaining
  function) (`cf-direct-two-modules-one-library`); `main.tcl -direct` names
  a retaining C call among the edges (`cf-direct-summary`).

No syntax was added for it -- no `direct fn`, no `unsafe`, no per-call
marker -- and directness still lives in the HIR (`moduleDecls`, `direct`),
never in the registry (DIRECT-MODULES.md). The hook DIRECT-MODULES.md
section 9 anticipated as a third designation source turned out to be an
edge: a retaining call is authority where it is made, not a property of the
module that declares the function.

## 10. Representation

**AST** (surface/ast.tcl): `externlib {library librarySpan}` and `externfn
{name nameSpan symbol symbolSpan params paramsSpan resultType
resultTypeSpan provenance provenanceSpan}`, each parameter `{name nameSpan
type typeSpan access escape factsSpan}`. surface/lower.tcl collects them
(`ExternDeclOf`, `LinkDeclOf`, with the unit's namespace) and the loader
hands every unit's to the build (`-foreign-decls`, `-link-decls`).

**HIR** (hir/foreign.tcl). The build registers each declaration as the
compilation-local root native `extern#KEY`, with the contract as its
`-foreign` metadata and `{key namespace name symbol abi}` as its `extern`
metadata, and binds its spelling in its unit's scope (a root-kind binding;
hygiene names it `extern#KEY` once resolution is done, keeping the
spelling). The HIR keeps two side tables:

```
foreign   KEY -> {key namespace name symbol native origin contract abi}
          boringssl::SHA256 -> {... symbol botlish_bssl_SHA256
            contract {vars {} params {{name data type {cptr {refined int std::ffi::c::UChar}}
              access read escape declared-noescape} {name len ...}
              {name out ... access write escape declared-noescape}}
              result {cptr ...} provenance {alias out}}
            abi {params {ptr u64 ptr} result ptr}}
links     {{library crypto origins {...}} {library stdc++ origins {...}}}
```

and its `declarations` capture the registry (compilation isolation,
section 14). A call is an ordinary `call` node whose target is the native,
with the borrowing milestone's `borrows` transport on it: no new HIR node
kind, because nothing about a C call differs at HIR level from a foreign
call the borrow fixture has always had -- what differs is below.

**NIR** (native/lower.tcl, native/src/nir.rs) has a distinct instruction,
because a C call is neither a Botlish call, a runtime op nor a syscall
register call, and a string tag on one of those would hide the ABI:

```
link "crypto"
link "stdc++"
foreign 0 "botlish_bssl_SHA256" params="ptr u64 ptr" result=ptr alias=2 name="boringssl::SHA256"
...
func 5 "digest" params=1 ...
    %6 = structget 0 %5 @e356
    %7 = op mbytesclone %6 @e349                     # the write exposure's private copy
    %8 = op bytesaddr %0 @e349                       # the exposures, after every argument
    %9 = op mbytesaddr %7 @e349
    %10 = foreigncall 0 %8 %1 %9 exposed=0,2 discard @e349
    %11 = op keepalive %0 @e349
    %12 = op keepalive %7 @e349
    %13 = structnew 0 %7 @e349                       # the MutableBytes over the copy C wrote
    %14 = structnew 1 %13 %10 @e349                  # {out: ..., result: unit}
```

(As it was when this milestone landed. Since C-FFI-ERROR-CAPTURE-
MILESTONE-1.md the write-back value is fields wherever escape analysis keeps
it virtual -- here `%7` and `%10` -- and a `structnew` is emitted only at a
use that needs the object: `digest`'s `written.out`, handed to
`std::abi::bytes::freeze`, builds the MutableBytes there (`structnew 0 %7` after
the keepalives), and the struct is never built.)

The header's `foreign N` entries are the program's foreign table, numbered
on first use: the link symbol, each parameter's ABI class, the result's,
the alias parameter, the Botlish name (for messages); `link` lines are the
link plan. `foreigncall F ARGS [exposed=I,...] [discard]` names its callee
declaration, the ABI signature (the table entry), the borrow plan
(`exposed=`, which operands are exposure addresses) and the result kind
(the entry's `result`; `discard` a result that aliases an exposure: checked,
then unit). The parser validates every operand count and index.

**Code** (native/src/codegen/clif.rs). Each table entry is a Cranelift
import (`Linkage::Import`) declared with the target's C calling convention
(`codegen::target::c_call_conv`: `system_v` on Linux x86-64 and AArch64,
`apple_aarch64` on macOS AArch64, section 13) and its C signature: each
integer parameter at its exact width, the narrow ones `sext`/`uext` by
their class -- under Apple's convention only the eight passed in integer
registers, counted apart from the doubles, which take the floating-point
ones (`c_extended_parameters`: Apple gives a stack argument a slot of its
natural size, which Cranelift 0.135.2 would overrun storing it extended) --
pointers 64-bit words, the result at its width with no extension (the
caller extends it, section 8).
A `foreigncall` is one direct `call` of the import, with the transport
inline around it (`cf-clif`). It is a safepoint of the native stack maps
(conservatively: no C function can reach the collector today; a 64-bit
result outside the small-Int range is boxed, `rt_ffi_box_i64`). A
`keepalive` after it emits nothing: its operand's liveness is the root
plan's, from the NIR.

## 11. Linking

A program whose NIR has a `foreign` or `link` entry is linked by the system
linker; every other program is linked exactly as before. The plan reaches
the linker in its own terms (codegen/aot.rs's `LinkerFlavor`): GNU ld's on
Linux, below, and Apple's ld's on macOS, which takes the same `-L` and `-l`
arguments without the group (it rejects `--start-group`, and keeps
searching every static archive while anything it could define is
undefined, so the order never decides a link there either: `cf-link-order`
runs on macOS too).

**The invocation.** The rustc linker (`BOTLISH_NATIVE_LINKER=rustc`, the
default, which links every standalone executable) builds the executable
from the program's object, the startup crate and the runtime library, and
passes the link plan to the system linker it drives (`cc`):

```
rustc ... --extern botlish_native=.../libbotlish_native.rlib
      -C link-arg=.../program.o
      -C default-linker-libraries=yes                 cc's own default libraries, last
      -C link-arg=-L/DIR ...                          one per -L
      -C link-arg=-Wl,--start-group
      -C link-arg=-lcrypto -C link-arg=-lstdc++       the plan, in order
      -C link-arg=-Wl,--end-group
      startup.rs -o EXECUTABLE
```

`default-linker-libraries=yes` (only for a program that calls C) makes rustc
drop its `-nodefaultlibs`, so the C compiler driver appends its default
libraries -- libgcc, libc and the dynamic loader libc names as needed --
after the plan, as in any C program's link. Without it the plan follows
rustc's own system libraries, and GNU ld has already dropped an as-needed
library nothing had referenced yet: on Linux AArch64, BoringSSL's stack
protector reads `__stack_chk_guard`, which only the dynamic loader defines,
and the link failed ("DSO missing from command line"; found by the arm64 CI
run; on x86-64 the canary is thread-local and the Rust runtime already
references the loader, so it cannot show there).

The libraries are one linker group, so their order never decides a static
link: an archive declared before the archive that needs it still resolves
it (`cf-link-order`). Shared or static is the linker's choice by its own
search rules (`-lNAME` finds `libNAME.so` -- `libNAME.dylib` or `.tbd` on
macOS -- before `libNAME.a` in a directory); Botlish adds no rpath, no
`-Bstatic`, no pkg-config. A shared library is then loaded at run time from
wherever the platform's loader looks: the directories `LD_LIBRARY_PATH`
names on Linux, the install name the library records on macOS
(`cf-shared-library`).

On macOS, `default-linker-libraries=yes` gives the link Apple clang's own
default libraries, libSystem and its compiler runtime (`libclang_rt.osx.a`),
which rustc's `-nodefaultlibs` link leaves out, so C compiled by clang finds
the runtime helpers it may call, as in a C program's link. No test can see
the runtime missing today: the one helper the tests' C calls,
`__isPlatformVersionAtLeast` (`__builtin_available`, `cf-availability-check`),
is also defined by Rust's standard library, which the link reaches first;
`ffi_link_plan_apple_has_no_gnu_flags` pins the argument (the
`apple-default-libraries-dropped` mutant is killed by it alone).

**Library search.** `main.tcl -L DIR` (repeatable) adds DIR to the linker's
search path for both native backends and `-emit-native-executable`
(`native::withLinkDirs DIRS SCRIPT` in Tcl, `--link-dir DIR` to
`botlish-native`). The system's default directories are searched as always.
A link directory is a link-time input only: it never shapes a HIR, so it is
in no cache key.

**Symbols are resolved once.** The linker resolves every symbol when the
program is linked; the running program makes direct calls. There is no
`dlopen`, no `dlsym`, no symbol-name processing at run time: the only
strings a C call can touch are the Botlish name in its two failure messages.

**Failures are the linker's.** A library the linker cannot find, or a symbol
no library defines, compiles through the whole front end and fails at the
native link as `{NATIVE LINK}`: "native link failed: the system linker could
not link this program with the C functions and libraries it declares
(symbols botlish_bssl_SHA256; libraries -lcrypto -lstdc++):" followed by
the linker's own lines (`cf-missing-library`, `cf-undefined-symbol`) --
GNU ld's, lld's or collect2's on Linux; Apple ld's on macOS (`ld: library
'NAME' not found`, `Undefined symbols for architecture arm64:` with a
`"_SYMBOL", referenced from:` line per symbol, a wrong-architecture
library's `found architecture 'x86_64', required architecture 'arm64'`,
`cf-wrong-architecture`). Never a front-end error: a missing library is not
an `UNKNOWN-NAMESPACE`, an undefined symbol not a `TYPE`. A failed link
publishes nothing: an executable linked earlier at its destination is left
as it was (`cf-link-failure-keeps-executable`). A declaration no call reaches needs no
definition: only the functions a program calls enter the table.

**The native backends' runs.** `-backend cranelift` and `cranelift-generic`
JIT a program into the `botlish-native` process; a C symbol, however, must
be resolved by the linker against the declared libraries. So a program that
calls C is linked as a standalone executable in a private temporary
directory (`botlish-run-PID-NONCE`, removed after) with the same link plan
as `-emit-native-executable`, and run as a child process with the run's
argument vector (`cf-argv`), the output inherited (main.tcl's
`-output inherit`: native program output stays main.tcl's own,
`cf-main-tcl`), and its result written to a result file
(`BOTLISH_NATIVE_RESULT`; `BOTLISH_NATIVE_RUNS` for a benchmark's runs) in
the driver's own protocol (runtime/aot.rs's `driver_protocol`). One
mechanism, two entry points: the run and the executable cannot disagree
about FFI. The JIT still compiles such a program when only its code is
inspected (`native::clif`, `native::nir`), its C symbols bound to
`rt_ffi_unlinked`, which aborts if it is ever called. Allocation reports and
batch timing measure in-process JIT runs only and report a program that
calls C `{NATIVE UNSUPPORTED foreign}`.

**The system linker** (`BOTLISH_NATIVE_LINKER=system`, and `auto`'s for a
program that calls C: the single executable's;
SINGLE-EXECUTABLE-FFI-MILESTONE-1.md) passes the same plan to the same
platform linker without rustc: the host's C compiler driver links the
program object (which carries the program's startup record,
`botlish_program`) and the precompiled runtime archive
`libbotlish_runtime.a` (`botlish_runtime.lib`, with link.exe, on Windows):

```
cc -pie -Wl,--eh-frame-hdr -Wl,-z,relro,-z,now -Wl,--gc-sections -o EXECUTABLE
   program.o
   -L/DIR ... -Wl,--start-group -lcrypto -lstdc++ -Wl,--end-group      the plan, as above
   .../libbotlish_runtime.a -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc  the runtime's own
```

The driver appends its default libraries after all of it, as for any C
program, so the as-needed rule above holds the same way. Its failures are
this section's (`NATIVE LINK` with the linker's own lines), and its own:
no C compiler driver, no linker, an unusable runtime archive (`NATIVE LINK
TOOLCHAIN`, `NATIVE LINK RUNTIME`). Every C test file passes with it on
Linux (CI's system-linker jobs, x86-64 and AArch64).

**The stub linker** (`BOTLISH_NATIVE_LINKER=stub`) appends a program image
to the prebuilt `botlish-aot-stub`; it links no native library, so it
refuses a program that calls C, naming what it calls and the linkers that
can (`cf-stub-linker`).

**Static archives and frameworks** (NATIVE-LINK-PLAN-MILESTONE-1.md). The
plan above is a library's when it is declared without `static`, and is
unchanged. A library declared `static` is no `-lNAME`: before any linker
runs, the driver resolves the plan (codegen/aot.rs's `resolve_link_plan`)
-- `static at PATH` is PATH joined to the root the front end recorded
(the application's, or the declaring package's directory), `static` alone the first `libNAME.a` (`NAME.lib`) of the -L
directories and then the toolchain's own (the C driver's and GNU ld's on
Linux, ld(1)'s defaults on macOS, `LIB` on Windows) -- checks the file (a
regular file, an `ar` archive of objects of the host's format and
architecture; never a shared library, a `.tbd` stub, a linker script, a
thin archive or a Windows import library) and passes it by its absolute
path at the library's place in the plan, inside the group on Linux. A
framework becomes Apple's `-framework NAME` after the libraries, with
`-F DIR` (main.tcl's `-F`, `--framework-dir` to the driver) after the -L
directories; no other linker is given either. A resolution failure is
`NATIVE LINK ARCHIVE` (`nlp-static-refusals`, `nlp-static-shared-only`), and
`BOTLISH_NATIVE_LINK_LOG` records which file each static library was and
why (`link plan: static NAME: PATH (declared at "native/libNAME.a")`). The
driver's `link-plan FILE.nir` (`native::linkPlan HIR`) prints the resolved
plan without linking.

## 12. Backends

| backend | declares C functions only | declares a library | calls C |
|---|---|---|---|
| interp | runs | runs | `NATIVE-ONLY` at the call, after its exposures were modeled |
| compile | runs | runs | `NATIVE-ONLY` at the call |
| cranelift, cranelift-generic | runs (JIT, as ever) | linked with the plan, run as a process | linked with the plan, run as a process |
| executable (rustc linker) | links | links the plan | links the plan; needs at run time only the libraries it linked dynamically |
| executable (system linker) | links | links the plan | links the plan, the same way, without rustc (section 11) |
| executable (stub linker) | links | `NATIVE LINK`: refused | `NATIVE LINK`: refused (section 11) |

A library is linked whether or not a function of it is called: the plan is
the program's (section 2), so a declared library that does not exist fails
the native link even of a program that calls nothing (`cf-missing-library`),
as it would for a C program linked with `-lNAME`; a declaration no call
reaches adds nothing to the link.

The Tcl backends have no machine to call C on, and there is no Tcl-side
FFI to keep the matrix symmetric: "bcf::add is a C function (extern c fn):
calling it runs only on the native backends (cranelift, cranelift-generic,
a native executable), which link and call the C library; the Tcl backends
have no machine to call it on" (`cf-tcl-backends`). Golden suites cannot
call C (they cannot link a library or say where one is), so the C FFI's
tests are Tcl tests (section 22).

## 13. Targets

**Linux x86-64**: implemented and tested end to end here (SysV: six integer
argument registers, the rest on the stack).

**Linux AArch64**: the same code path -- Cranelift's platform convention is
AAPCS64 there, plain `char` is unsigned by the target table, the fixture's
dirty-register functions have AArch64 versions, and rustc-linked
executables are supported. Tested natively by `tests-arm64.yml` on
GitHub's ubuntu-24.04-arm runners: every C FFI test runs there, the Tcl
and BoringSSL SHA-256 acceptance included, and passes (section 23). The
first arm64 run found the one AArch64-specific bug, the BoringSSL link's
as-needed loader (section 11, fixed), and two tests that had assumed
x86-64's signed plain `char` (now the target's).

**macOS AArch64** (MACOS-AARCH64-MILESTONE-6.md): the same code path, with
Apple's arm64 C ABI and Apple's linker. Cranelift's `apple_aarch64`
convention places the arguments -- eight integers in x0-x7 and eight
doubles in v0-v7, each kind counted on its own, the rest on the stack at
their natural size and alignment, packed (a `char` one byte, a `short` at
the next even offset) -- and extends a narrow register argument to 32
bits, the caller's duty there; Botlish declares a stack-passed narrow
argument without the extension attribute (section 10), and counts the
integer registers apart from the doubles (`cf-abi-doubles-before-integers`).
float64.test's C double tests run there too. Plain `char` is
signed. Every C FFI test runs on GitHub's macos-15 arm64 runners against
the fixture compiled by Apple clang, and the machine state each call
arrives in matches Apple clang's own calls of the same prototypes
(`cf-abi-*`). Symbols are their C names: the object crate writes Mach-O's
`_` user label prefix, for a C function's symbol as for Botlish's own.
macOS's IO is a binding of this kind (MACOS-AARCH64-MILESTONE-8.md):
stdlib/darwin.bot declares libSystem's `write`, `read`, `open` (variadic),
`close` and `__error` as `extern c fn` with byte-borrowing contracts, and
stdlib/darwin/io.bot puts them behind `std::io::IO`; no extern c library is needed,
libSystem being in every macOS executable's link.

**Windows x86-64** (WINDOWS-X86-64-MILESTONE-2.md): the same code path,
with the Win64 C ABI (Cranelift's `windows_fastcall`: four positional
registers shared by the integer and floating kinds, a 32-byte shadow space,
every further argument in its own 8-byte stack slot, LLP64's 32-bit
`long`) and Microsoft's link.exe through rustc: `extern c library "NAME"`
is `NAME.lib` (a static library or a DLL's import library), `-L DIR` is
`/LIBPATH:DIR`, and there is no archive group (link.exe searches every
library until nothing more resolves). Every executable links the static
release C runtime and excludes every other Microsoft runtime, so a static
C library compiled for `/MT` (cl's default) shares it, and one compiled for
`/MD` does not link: its calls of the runtime are `__imp_` imports, which
link.exe resolves against the static runtime only for a function something
else linked anyway (LNK4217) and otherwise refuses (LNK2019, NATIVE LINK
with the driver's explanation). A DLL keeps its own runtime, `/MT` or `/MD`
(section "The C runtime" of the milestone report). The machine state each call arrives in is checked
against MSVC-built callees (tests/cffi/fixture.c with
tests/cffi/fixture-win64.asm's capture). Variadic C calls run on Windows
since WINDOWS-X86-64-MILESTONE-6.md: Win64 passes each float or double of a
variadic call's first four positions in both its xmm register and its
position's integer register, which a stub before the jump to C copies
(`va_stub`); the C runtime's printf family is inline in MSVC's headers, so
a binding of `snprintf` declares `extern c library
"legacy_stdio_definitions"`, its out-of-line definitions. Windows I/O is a binding
of this kind: stdlib/windows.bot declares kernel32's GetStdHandle, WriteFile
and GetLastError, stdlib/windows/io.bot puts them behind `std::io::IO`.

Elsewhere the native backends already refuse executables (Linux glibc,
macOS AArch64 and Windows x86-64 only), so they refuse a program that calls
C the same way. A `-target`
other than the host's chooses the ABI classes of a compilation (its HIR),
never a cross-link: linking is for the host, and the driver refuses to run
or link a program built for another target at all (`NATIVE TARGET`,
MACOS-AARCH64-MILESTONE-2.md), so a Windows LLP64 `long` is never passed to
a Linux C function.

**The calling convention** of a foreign call is the target triple's C
convention, selected where its signature is built
(`native/src/codegen/target.rs`'s `c_call_conv`, called by `clif.rs`'s
`c_signature`): `system_v` on Linux, `apple_aarch64` on macOS AArch64 --
never the generic AArch64 one there -- `windows_fastcall` on Windows
x86-64, and Cranelift lowers it (registers,
stack placement, narrow-argument extension). Botlish-to-Botlish calls and
runtime helper calls keep the ISA's default convention. The one exception
Botlish makes to Cranelift's lowering is what it asks of it: no extension
of an Apple stack argument (section 10), whose slot has nothing to extend
into.

## 14. Static compile, interchange, cache, isolation

**Static compile.** A `static compile:` block calling an extern c fn is
decided like any block: an arity mismatch, an unproven C scalar range, a
refused exposure, an unmediated retaining call are `compiler::
DiagnosticCode` values (`Arity`, `Type`, `ForeignBorrow`, `Direct`), an
accepted block is the ordinary call, and nothing is executed at compile
time -- the C function is never called by the compiler (`cf-static-compile`).

**HIR interchange** carries everything a C call needs past the front end:
the `foreign` and `links` side tables are the HIR's own, and the extern
natives' registrations are part of its `declarations`. A HIR written as
`.hirx` and read back in a fresh process lowers to the identical NIR and
runs (`cf-interchange`).

**The front-end cache** keeps a program that calls C as its build; a binding
module's text is a dependency like any imported module's, so a changed
library name, link symbol, signature or contract is a miss
(`cf-cache`). The front end reads no new input: no header, no library, no
link directory.

**Compilation isolation.** The extern natives and the link plan are a
declaration registry: `hir::foreign::capture`/`Install` are in
`hir::declarations`, every build drops the previous compilation's extern
natives first (`Reset`), and `hir::activate` re-installs a HIR's own. So
compiling another program -- with other externs of the same names, or none
-- never changes an earlier HIR's lowering, and no later compilation links
an earlier one's library (`cf-isolation`).

## 15. The single executable

The Botlish compiler executable is self-contained for ordinary Botlish
programs. Native FFI programs additionally depend on the host native linker
and the libraries they explicitly declare.

Concretely (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md): the single executable
(SINGLE-EXECUTABLE.md) links standalone executables with `auto` -- the stub
linker, which needs no toolchain, for a program that calls no C; the system
linker for one that calls C or declares a library -- and carries the
precompiled runtime archive the system linker links. So a program that
calls C links and runs with `-emit-native-executable` and on the native
backends (`-backend cranelift` links it to run it) wherever the host has a
C compiler driver and the declared libraries: no rustc, no Rust library, no
checkout (`single/ffi-smoke-test.sh`, in a stock container with only gcc
installed). Without a C compiler driver such a program's link is refused
(`NATIVE LINK TOOLCHAIN`, saying how to install one); the Tcl backends run
it to its first C call, as anywhere. The compiler bundles no Tcl,
BoringSSL or system development library, and never will by this design: a
library is the program's declaration and the host's file.

## 16. Examples

**A scalar function.**

```botlish
import std::ffi::c

extern c library "m"

extern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long

labs(-42)                               # 42 (labs is libc's; "m" shows a library)
```

**A pointer function.** Raw pointers cross as raw machine addresses; the
pointee is an opaque struct, the result's provenance states where it comes
from.

```botlish
import std::ffi::c

extern c library "tcl9.0"

opaque struct Interp:
    tag: unit

extern c fn Tcl_CreateInterp() -> std::ffi::c::Ptr[Interp] independent
extern c fn Tcl_DeleteInterp(interp: std::ffi::c::Ptr[Interp] noescape) -> unit

interp = Tcl_CreateInterp()
alive = not interp.null?()
Tcl_DeleteInterp(interp)
alive
```

**Bytes, read noescape.**

```botlish
import std::abi
import std::abi::bytes
import std::ffi::c
import std::str

extern c library "botlish_cffi_fixture"

extern c fn sum named "bcf_sum"(data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape, count: std::ffi::c::ULong) -> std::ffi::c::ULong

data = std::abi::bytes::from_list(std::str::encode_utf8("hello"))
sum(data, std::abi::bytes::length(data).value)        # 532: C read the Bytes' own storage
```

**MutableBytes, write noescape.** The call returns the bytes C wrote; the
caller's MutableBytes is unchanged (the imports and library as above).

```botlish
extern c fn fill named "bcf_fill"(out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape, count: std::ffi::c::ULong, seed: std::ffi::c::UChar) -> unit

m = std::abi::bytes::zeroed(std::abi::usize(5))
r = fill(m, 5, 7)
std::abi::bytes::freeze(r.out)                         # the bytes 7 44 81 118 155
# r.result is unit; m is still five zero bytes
```

**A direct retaining call.** A function that keeps its pointer is declared
`captures`; calling it is direct authority, acknowledged by the calling
module:

```botlish
direct module

import std::ffi::c

extern c library "botlish_cffi_fixture"

extern c fn keep named "bcf_keep"(p: std::ffi::c::Ptr[std::ffi::c::Void] captures) -> unit
extern c fn address named "bcf_address"() -> std::ffi::c::Ptr[std::ffi::c::Void] independent

p = address()
keep(p)
```

Without `direct module` the call is `DIRECT`: "the entry program uses
direct authority in its top-level code: it calls keep, a C function whose
contract lets it retain pointer authority past the call (parameter "p":
escape captures), and top-level code has no context, so the call is never
mediated; move it into a function that requires a context defined by the
entry program, or declare the module direct with `direct module` as its
first line".

**A renamed native symbol.**

```botlish
extern c fn plus named "bcf_add"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int

plus(40, 2)                                       # 42; the link symbol is bcf_add
```

**A library dependency.** BoringSSL's static `libcrypto.a` needs the C++
runtime's `operator delete`: the binding declares that library too, as a
link-plan entry like any other.

```botlish
extern c library "crypto"
extern c library "stdc++"
```

## 17. The Tcl binding

`examples/ffi/tcl/tcl.bot` binds three functions of the installed Tcl 9 C
library (`libtcl9.0.so`), by their tcl.h signatures:

```botlish
extern c library "tcl9.0"

opaque struct Interp:
    tag: unit

extern c fn Tcl_CreateInterp() -> std::ffi::c::Ptr[Interp] independent

extern c fn Tcl_EvalEx(
    interp: std::ffi::c::Ptr[Interp] noescape,
    script: std::ffi::c::Ptr[std::ffi::c::Char] read noescape,
    numBytes: std::ffi::c::Long,
    flags: std::ffi::c::Int
) -> std::ffi::c::Int

extern c fn Tcl_DeleteInterp(interp: std::ffi::c::Ptr[Interp] noescape) -> unit
```

Tcl 9's `Tcl_Eval` is a macro, `Tcl_EvalEx(interp, script, TCL_INDEX_NONE,
0)`: the library exports `Tcl_EvalEx`, so that is what the binding declares,
and its `eval(interp, script)` is the macro's Botlish spelling. `Tcl_Size`
is `ptrdiff_t`, a C `long` on LP64. `examples/ffi/tcl/demo.bot` creates an
interpreter (non-null), evaluates `puts {hello from Tcl}; flush stdout`
(`TCL_OK`; Tcl prints the line), evaluates `error {deliberately}` (not
`TCL_OK`) and deletes the interpreter:

```
$ tclsh9.0 main.tcl -backend cranelift examples/ffi/tcl/demo.bot
hello from Tcl
[true, true, true]
```

on both native backends, from an application-module binding, with no
warning (`cf-tcl-acceptance`). The error text is not read: retrieving it
returns a `const char *`, and Botlish has no operation reading C memory
(no dereference, no C string: C-ABI-TYPES.md).

## 18. The BoringSSL binding

`examples/ffi/sha256/boringssl.bot` (the declaration at the top of this
document) binds `SHA256` of BoringSSL's pinned release, the header
archaeology's (`audit/c-header/profiles/boringssl.tcl`), whose
`include/openssl/sha2.h` declares `uint8_t *SHA256(const uint8_t *data,
size_t len, uint8_t out[SHA256_DIGEST_LENGTH])`.

**The library** is package-owned and static. `tclsh9.0
tests/cffi/boringssl.tcl` fetches the release into Botlish's cache
(audit/c-header/tools/fetch.tcl), builds `libcrypto.a` once with CMake and
Ninja under `BORINGSSL_PREFIX=botlish_bssl` (BoringSSL's own symbol-prefix
build), and prints its directory (`$BOTLISH_BORINGSSL_DIR`, else
`boringssl/COMMIT-botlish_bssl` in the cache; never the repository). Every
symbol it defines is prefixed, so the binding's `named
"botlish_bssl_SHA256"` can never be satisfied by an ambient system
OpenSSL: without this build the link fails. Botlish's compiler and runtime
never build, fetch or need it; a program reaches it only by `extern c
library "crypto"` and `-L`.

`examples/ffi/sha256/demo.bot` checks the digests of `""`, `"abc"` and
`"The quick brown fox jumps over the lazy dog"` byte for byte against their
published values, the write-back `MutableBytes` holding the digest C wrote,
the input Bytes and the original MutableBytes unchanged:

```
$ tclsh9.0 main.tcl -backend cranelift -L "$(tclsh9.0 tests/cffi/boringssl.tcl)" examples/ffi/sha256/demo.bot
[true, true, true, true, true, true]
```

on both native backends (`cf-sha256-acceptance`).

## 19. Standalone executables

`-emit-native-executable` (or `native::executable`) links a program that
calls C with its declared libraries into a standalone executable that runs
with no Tcl, no rustc and no source (`cf-executable`); the SHA-256 demo's
executable contains BoringSSL (its `botlish_bssl_SHA256` defined inside, no
libcrypto needed at run time: `cf-sha256-executable`).

## 20. GC stress

Under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site) the exposures survive real C calls: the fixture's read and write
borrows, the Tcl script bytes and the SHA-256 read and write borrows
(`cf-gc-stress`), and every fuzzer program (section 22). Until
C-CALLBACK-MILESTONE-1.md C could not reach the collector during a call,
and the synthetic `read_reentrant` (`cb-liveness-reentrant`) was the guard
of an exposed storage's liveness across a collection inside one; now a
callback can allocate during a foreign call, and c-callbacks.test's
`cb-exposure-survives` holds an exposure across real callbacks that
collect.

## 21. Performance

`bench/c-ffi.tcl` (Linux x86-64, a 4-core container with another job
running beside it, 2026-10-17; cranelift specialized, best of 5 runs,
compilation and linking excluded). The calls are of the fixture's
functions; each row is ns per iteration of a loop of 100,000 calls, beside
the same loop without the call, and their difference:

| call | loop | + call | call |
|---|---:|---:|---:|
| `bcf_count()`: no argument, an unsigned long result | 32.3 | 32.6 | 0.3 |
| `bcf_add(i, 1)`: two ints, an int result | 32.2 | 44.5 | 12.3 |
| `bcf_echo_ulonglong(2^64 - 1)`: a BigInt both ways | 31.5 | 77.2 | 45.7 |
| `bcf_sum(data, 0)`, a 64-byte Bytes exposed for reading | 33.5 | 48.7 | 15.2 |
| the same, 64 KiB | 68.1 | 69.6 | 1.4 |
| the same, 1 MiB | 549.1 | 431.5 | -117.6 |
| `bcf_fill(m, 0, 0)`, a 64-byte MutableBytes exposed for writing | 34.6 | 124.1 | 89.5 |
| the same, 64 KiB | 66.9 | 13,086.4 | 13,019.5 |
| the same, 1 MiB | 562.5 | 90,684.3 | 90,121.8 |

(The 1 MiB loops' time is mostly building their input once, amortized: the
difference there is that setup's noise.) SHA-256 through the static
BoringSSL, `sha256::digest` per call (one read exposure, one 32-byte write
exposure):

| input | per digest | throughput |
|---|---:|---:|
| 64 B | 0.64 us | 100.8 MB/s |
| 1 KiB | 1.22 us | 839.9 MB/s |
| 64 KiB | 44.91 us | 1,459.4 MB/s |
| 1 MiB | 634.01 us | 1,653.9 MB/s |

Compile and link, ms, best of 5 (front end excluded):

| program | `native::evalHir` (lower, compile, run) | `native::executable` (rustc link) |
|---|---:|---:|
| `x + 2`, no C | 7.2 | 422.1 |
| `bcf::add(40, 2)` | 422.9 | 397.2 |

What this shows:

* **A C call is an ordinary native call.** A call with no argument costs
  less than the loop's own noise; two int arguments and a result cost about
  12 ns with their conversions and the result's list element; nothing
  spawns a process, opens a library or looks up a symbol per call.
* **Read-only bytes are never copied.** The read exposure's cost does not
  grow with the storage (64 B, 64 KiB and 1 MiB within the noise).
* **A write exposure costs its detach copy**, linear in size (13 us for 64
  KiB, 90 us for 1 MiB), exactly as C-POINTER-BORROWING.md measured for the
  synthetic fixture; a 64-bit value beyond the small Int range costs a
  BigInt conversion each way (~45 ns).
* **SHA-256 runs at BoringSSL's speed**: past a few KiB the digest is the
  hash's own work (1.6 GB/s), the borrowing's cost vanishing beside it.
* **The link is an FFI program's cost.** `-backend cranelift` links a
  temporary executable for each run of a program that calls C: about 0.4 s
  of system link and process start, against 7 ms for a JIT run. An
  executable pays the link once, and costs the same with or without C.
  That is the price of resolving symbols with the platform linker, the
  design's point; nothing links twice.

## 22. Tests, fuzzing, mutants

**`tests/c-ffi.test`** (84 tests) covers the grammar and its
errors, declarations, the HIR table, ABI classes per target, the link plan,
call typing, borrowing through real C, pointer results and the contract
check, the transport, NIR and CLIF, the backend matrix, linking and its
failures, executables, the stub linker, main.tcl, direct, static compile,
interchange, the cache, isolation, the Tcl and BoringSSL acceptance and GC
stress -- and, since MACOS-AARCH64-MILESTONE-6.md, the target's C ABI
itself (`cf-abi-*`: register extension and stack layout against the C
compiler's own calls, every argument of a twenty-parameter prototype read
back), the scalar matrix, plain char, pointer width, system and shared
libraries, `-L` directories, a wrong-architecture library, a failed link,
and GC stress, coroutines and the stack guard around C calls. Its C side is
`tests/cffi/fixture.c`, compiled with the host C compiler into a static
archive in a private directory (test infrastructure only); it runs wherever
C calls do (`nativeCCalls`: Linux x86-64 and AArch64, macOS AArch64,
Windows x86-64, where tests/ctoolchain.tcl builds it with MSVC's cl, lib
and ml64); the
Tcl tests need a linkable `libtcl9.0`, the BoringSSL ones the package-owned
build (skipped when it is not built).

**The fuzzer** (`audit/c-ffi/tools/fuzz.tcl`) generates programs of random C
signatures -- 0 to 14 parameters of every scalar class, raw pointers (null
or an address), read and write byte pointers (`noescape` or `proven
noescape`); scalar, void, independent and alias pointer results; with and
without `named` -- writes them as real C, compiles them into a library,
binds and calls them with values drawn toward each type's bounds, and
compares what C saw of every argument, the result, the write-back bytes and
the caller's unchanged bytes with its own ABI model; on the Tcl backends
every program must be `NATIVE-ONLY`.

| run | programs | C functions | disagreements |
|---|---:|---:|---:|
| `-seed 1`, `-seed 2`, `-seed 3` (`-n 20`, 12 functions each) | 60 | 720 | 0 |
| `-seed 4 -n 20` | 20 | 240 | 0 |
| `-seed 9 -n 10 -gc-stress 1` | 10 | 120 | 0 |
| macOS arm64, under `BOTLISH_NATIVE_GC_STRESS=1` (tier.tcl's `c-ffi-fuzz`: `-seed 1`, `-seed 2`, `-seed 9 -gc-stress 1`, `-n 10` each; MACOS-AARCH64-MILESTONE-6.md) | 30 | 360 | 0 |

The fuzzer's model is independent of the compiler's (its own table of C
widths and signedness, its own conversion rule, its own byte arithmetic),
and it kills 12 of the mutants below on its own (6 programs per mutant).

**Mutants** (`audit/c-ffi/tools/mutate.tcl`, `mutants.txt`): each a
deliberate bug, run against `tests/c-ffi.test` and the fuzzer in a private
copy of the tree.

27 mutants, 27 killed: the 18 the brief lists (the table's first 18 rows)
and 9 more. One run of all 27 (29 minutes) killed 26; the linker
group's mutant survived it, on this host for a real reason: rustc's x86-64
linker here is lld, which resolves static archives in any order, so
dropping the group changes nothing it links (GNU ld and gold do need it:
the same two archives fail to link with `cc -fuse-ld=bfd` and `gold`).
`codegen::aot`'s `ffi_link_plan_is_one_linker_group` now pins the
arguments, the mutation tool runs the `ffi_` Rust tests for native mutants,
and a second run of the two linker mutants killed both.

| mutant | killed by |
|---|---|
| `named-ignored` (the parser drops `named`) | 46 tests, the fuzzer |
| `botlish-name-as-symbol` (the foreign table names the Botlish name) | 13 tests, the fuzzer |
| `library-dropped` (the plan loses its last library) | 35 tests, the fuzzer |
| `unsigned-result-sign-extended` | `cf-scalar-transport`, `cf-scalar-extension`, the fuzzer |
| `signed-result-zero-extended` | `cf-scalar-transport`, `cf-scalar-extension`, `cf-stack-arguments`, the fuzzer |
| `long-always-64` (C long's class 64 bits whatever the target) | `cf-abi-classes-follow-the-target` |
| `pointer-untag-forgotten` (a pointer argument passed tagged) | 5 tests, the fuzzer |
| `pointer-tag-forgotten` (a returned address untagged) | `cf-pointers`, `cf-gc-stress` |
| `captures-borrow-allowed` (a captures parameter admits an exposure) | `cf-borrow-refusals`, `cf-strict0-replay` |
| `read-bytes-copied` (a read exposure of a private copy) | 9 tests, the fuzzer |
| `original-mutablebytes-mutated` (C writes the owner's storage) | 6 tests (the SHA-256 acceptance among them), the fuzzer |
| `keepalive-dropped` | `cf-nir` |
| `argument-after-exposure` (a read exposure made before later arguments run) | `cf-nir` |
| `every-extern-direct` | 38 tests, the fuzzer |
| `retaining-not-direct` | 7 tests (`cf-direct-*`) |
| `nearest-library` (each function's library the last its unit declares, only those linked) | `cf-link-plan`, `cf-link-order`, `cf-missing-library`, the SHA-256 tests |
| `extern-state-shared` (activation does not re-install a HIR's externs) | `cf-isolation`, `cf-interchange` |
| `interchange-loses-foreign` | `cf-interchange` |
| `alias-check-dropped` | `cf-contract-violation` |
| `address-masked` (an unrepresentable address masked) | `cf-wild-address` |
| `unsigned-64-result-boxed-signed` | `cf-scalar-transport`, the fuzzer |
| `unsigned-64-argument-truncated` (a BigInt argument passed as 0) | `cf-scalar-transport`, `cf-stack-arguments`, the fuzzer |
| `link-group-dropped` | `ffi_link_plan_is_one_linker_group` (and `cf-link-order` where the linker is GNU ld or gold) |
| `stub-links-c` (the stub linker accepts a program that calls C) | `cf-stub-linker` |
| `tcl-backends-return-zero` (the Tcl backends run a C call as 0) | `cf-tcl-backends`, `cf-static-compile`, the fuzzer |
| `unknown-provenance-exposed` (memchr's shape admitted) | `cf-result-provenance` |
| `extern-arity-unchecked` | `cf-call-typing`, `cf-static-compile` |

Two are killed by the NIR shape test alone, and that is what they can be:
a missing keepalive or an exposure made before a later argument's code is
observable only if a collection runs while the exposure is open, and no
collection can run inside a real C call (section 20); the borrowing
milestone's synthetic reentrant test guards the liveness itself.

**The macOS Apple Silicon mutants** (MACOS-AARCH64-MILESTONE-6.md, section
25): 17 more, for the link plan per platform, Apple's argument extension and
stack packing, the scalar and pointer transport and the fixture. A mutant of
code one host compiles differently carries a `%% TARGET ...` line and is
SKIPPED elsewhere, never counted as killed; the tool runs on macOS through
tier.tcl's `c-ffi-mutants` item. On macOS all 44 are killed (run
39379524425); on Linux x86-64 the 10 new ones that apply there are.

| mutant | Linux x86-64 | macOS arm64 |
|---|---|---|
| `macos-link-plan-is-gnus` | skipped | 53 tests, the fuzzer, `ffi_link_plan_flavor_is_the_hosts` |
| `apple-plan-has-group` | `ffi_link_plan_apple_has_no_gnu_flags` | 53 tests, the fuzzer, the same |
| `apple-default-libraries-dropped` | `ffi_link_plan_apple_has_no_gnu_flags` | the same only (section 11) |
| `link-dirs-dropped` | 51 tests, the fuzzer, 2 Rust tests | the same |
| `apple-linker-diagnostics-dropped` | `ffi_linker_diagnostics_keep_the_linkers_words` | `cf-undefined-symbol`, the same |
| `apple-stack-parameters-extended` | skipped | `cf-clif-stack-parameters`, `ffi_apple_stack_arguments_stored_at_their_width` |
| `apple-register-boundary-off-by-one` | skipped | 3 `cf-abi-*` tests, the fuzzer, the same Rust test |
| `apple-convention-is-linuxs` | skipped | 14 tests, the fuzzer, both `apple_tests` |
| `signed-argument-zero-extended` | 5 tests | 10 tests, the fuzzer, `ffi_apple_stack_arguments_stored_at_their_width` |
| `unsigned-argument-sign-extended` | 4 tests | 9 tests, the fuzzer, the same |
| `short-class-is-int` | 3 tests, the fuzzer | 9 tests, the fuzzer, both `apple_tests` |
| `pointer-argument-truncated` | 13 tests, the fuzzer | 12 tests, the fuzzer |
| `pointer-result-truncated` | 6 tests, the fuzzer | 4 tests, the fuzzer |
| `macos-plain-char-unsigned` | skipped | 6 tests, the fuzzer |
| `mach-o-symbol-double-prefixed` | skipped | 53 tests, the fuzzer |
| `link-failure-removes-earlier` | `cf-link-failure-keeps-executable` | the same |
| `fixture-wrong-architecture` | skipped | 48 tests |
| `doubles-counted-as-integer-registers` (after the merge with FLOAT64-MILESTONE-1.md) | skipped | `cf-abi-doubles-before-integers`, `ffi_apple_doubles_leave_the_integer_registers` |

`apple-stack-parameters-extended` is caught only statically: the defect it
puts back (an extended narrow stack argument stored at register width)
leaves every argument's bytes right, so no test that runs the call sees it,
`cf-abi-stack-tail-frame` included.

## 23. Regression

On this checkout (Linux x86-64, Tcl 9.0.1, rustc 1.97.0):

| suite | result |
|---|---|
| `tests/local.tcl` (every Tcl test file on interp and compile, every golden suite on four backends through the front-end cache) | 5,772 + 5,768 Tcl tests passed, 2,098 golden duplicates skipped each; 92 golden suites, every test passed on every backend (4,721 / 4,721 / 4,629 / 4,731). One failure, fixed: `compilation-isolation.test`'s `ci-declarations-recorded` pins the declaration state's keys, which now include `foreign` |
| `tests/c-ffi.test` | 55 passed; under `BOTLISH_NATIVE_GC_STRESS=1` 55 passed; with `BOTLISH_NATIVE_LINKER=stub` (CI's stub job) 11 passed, 44 skipped (they need the rustc linker) |
| the executable test files with the stub linker (the `stub-linker` job's command) | 2,394 passed, 56 skipped, 0 failed |
| `tests/aot-stub-linker.test` (also under GC stress) | 6 passed |
| `tests/c-pointer-borrowing.test` under GC stress; its fuzzer (`-seed 3`; `-seed 5 -gc-stress 1`); its mutants | 61 passed; 0 disagreements; 22 / 22 killed |
| `audit/direct-modules/tools/fuzz.tcl` (seeds 1, 2); its mutants | 0 disagreements; 18 / 18 killed |
| `audit/c-abi-types/tools/fuzz.tcl`; its mutants | 0 disagreements; 26 / 26 killed |
| `audit/compilation-isolation/tools/interleave.tcl`; its mutants | 80 artifacts and outcomes, 0 differ; 14 / 14 killed |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange`, `-via cache`; its mutants | 90 and 100 compared, 0 differ; 27 / 27 killed |
| `audit/static-compile/tools/fuzz.tcl`; its mutants | 0 disagreements; 21 / 21 killed |
| `audit/static-decisions/tools/fuzz.tcl` (seeds 17, 41); its mutants | 0 failures; 73 / 73 killed (one run stopped at the 2-hour background limit after 50, all killed; the other 23 then with `-only`) |
| the warning fuzzers (`method-eligible`, `many-boolean-arguments`, `fixed-arity-list-return`, `proves-naming`: 300 seeds each), `audit/imports/tools/fuzz.tcl` | 0 failures |
| the warning gate | passed: the observed warnings are exactly the manifest |
| `cargo test --release` (also under GC stress) | 237 runtime and 34 codegen unit tests passed |
| `tests/native-coverage.tcl` of `c-ffi.test` and `compilation-isolation.test`, both native backends | 43 native, 31 backend-independent, 0 failed |
| the single executable (`single/build.sh`) | builds; refuses a program that calls C or declares a library with the stub's `NATIVE LINK`, runs it on the Tcl backends to its first C call |

CI on `main` at the milestone's last code commit (4b98494), every workflow
green:

| workflow | result |
|---|---|
| `tests.yml` (Linux x86-64) | success: the Tcl suite on interp and compile (the BoringSSL acceptance built by its cached step), cranelift and cranelift-generic coverage, the Rust unit tests, the stub-linked executables, the warning gate, the golden shards, GC stress |
| `tests-arm64.yml` (Linux AArch64, ubuntu-24.04-arm) | success: interp 7,819 passed and compile 7,815 passed, 0 failed, no C FFI test skipped; coverage, golden shards, Rust unit tests, GC stress |
| `static-decisions.yml` (batched against sequential scheduling, every golden suite) | success (also on the branch before the merge) |
| `single-executable.yml`, `bench.yml`, `scalar-asm-audit.yml` | success |

The 2048 workload is untouched (`tests/workload-2048.test` passes locally
and in CI).

## 24. Architectural boundaries

| statement | |
|---|---|
| Botlish does not parse C headers during normal compilation. | **Confirmed.** The front end reads Botlish source; header archaeology (audit/c-header/) is research tooling nothing in the compiler loads. |
| Botlish does not analyze C implementations. | **Confirmed.** Every fact is the declaration's; the compiler never reads C code or object code (the link is the linker's). |
| `extern c library "foo"` means the platform linker's native library name. | **Confirmed.** It becomes `-lfoo`, searched by the linker's own rules (plus `-L`). |
| An extern function is not associated with one library. | **Confirmed.** The plan is the program's; every symbol is resolved against all of it (`cf-link-plan`, `cf-link-order`). |
| The system linker resolves symbols. | **Confirmed.** At link time, through rustc driving `cc`; nothing at run time. |
| A foreign call is not automatically direct. | **Confirmed.** Only a contract that may retain a pointer (captures, unknown) makes a call an authority source (`cf-direct-noescape-ordinary`). |
| Temporary byte borrowing still requires noescape. | **Confirmed.** The admission is the borrowing milestone's, unchanged (`cf-borrow-refusals`). |
| Raw foreign Ptr values can cross calls independently of borrowing. | **Confirmed.** A `Ptr` is a raw address word, passed and returned as one; a pointer result is borrowing's concern only when the same call exposes storage (section 7). |
| No callback/export mechanism exists yet. | **Confirmed** at the time; native libraries export C symbols since NATIVE-LIBRARY-MILESTONE-1.md, and C calls Botlish back synchronously since C-CALLBACK-MILESTONE-1.md (`callback c fn`, `std::ffi::c::callback`). Botlish still never calls an `FnPtr`. |
| No aggregate/varargs ABI exists yet. | **Confirmed** at the time; varargs since VARIADICS-VERTICAL-SLICE-1.md (`variadic`, a per-call signature). Structs, unions and arrays by value are declaration errors (floating point was too until FLOAT64-MILESTONE-1.md added `std::ffi::c::Double`; `float` and `long double` still are). |

## 25. For a binding generator

The declaration is meant to be emitted mechanically from a declaration IR
such as the header archaeology's: one `extern c library` line per library,
one `extern c fn` per function, its parameters one per line, every fact a
word after its type:

```botlish
extern c library "foo"

extern c fn foo_frob named "foo_frob_v2"(
    handle: std::ffi::c::Ptr[Foo] noescape,
    data: std::ffi::c::Ptr[std::ffi::c::UChar] read proven noescape,
    len: std::ffi::c::ULong
) -> std::ffi::c::Int
```

Nothing in it needs a hand-written construct: no body, no wrapper, no
attribute syntax. A generator may choose a contract from headers, ABI
probes, compiler-produced `nocapture`/`returned` attributes (`proven
noescape`, `alias`) or manual metadata; compilation reads the contract and
never cares where it came from. The generator is `tools/c-bindgen.tcl`
(C-BINDGEN.md): a development tool that interrogates the C compiler and
writes exactly these declarations, which compile like hand-written ones.

## 26. Not here

* Header parsing in the compiler: whole-API bindings are generated by a
  development tool (C-BINDGEN.md) as ordinary source, and compiling them
  needs no header, preprocessor or C compiler.
* C `float` and `long double` (`double` is `std::ffi::c::Double`,
  FLOAT64-MILESTONE-1.md), structs, unions and arrays by value, `va_list`,
  bitfields. (Variadic calls are VARIADICS-VERTICAL-SLICE-1.md's: no format
  string is read, no runtime argument list built.)
* Calling an `FnPtr` from Botlish. (Exported C symbols are
  NATIVE-LIBRARY-MILESTONE-1.md's; synchronous callbacks -- Botlish code C
  calls during a call whose function pointer parameter is noescape -- are
  C-CALLBACK-MILESTONE-1.md's; retained callback registrations are not
  here yet.)
* `dlopen`/`dlsym`, lazy binding, a runtime library path policy.
* C strings, a dereference, reading C memory, an ownership policy for
  `Ptr` (who frees what), retained stable storage (C-POINTER-BORROWING.md
  section 15).
* A Tcl-side FFI (libffi or otherwise) for the interp and compile backends.
* A package manager, library downloads, or a way to pick a static or a
  shared library beyond the linker's own search rules (section 11).

## 27. What to run when changing this

If you change the grammar (surface/parser.tcl's `ExternDecl`), hir/foreign.tcl,
the extern cases of hir/resolve.tcl, hir/hygiene.tcl, hir/borrow.tcl or
hir/direct.tcl, core/cabi.tcl's contract or `ExternImpl`, native/lower.tcl's
foreign table or `BorrowCall`, `Inst::ForeignCall` (native/src/nir.rs),
`foreign_call`/`c_signature` (codegen/clif.rs), `c_call_conv`/
`c_extended_parameters` (codegen/target.rs), runtime/ffi.rs, the link step
(codegen/aot.rs's `link_plan_args_for`, `linker_diagnostics`,
`emit_executable`) or the linked
run (main.rs's `run_linked`, runtime/aot.rs's `driver_protocol`), run
`tests/c-ffi.test` (also under `BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`) and
`audit/c-ffi/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), plus
`tests/c-pointer-borrowing.test`, `tests/c-ffi-error-capture.test` and the
borrowing mutants for a change to the shared exposure or to what follows a
C call (the write-back value, the keepalive, the result's conversion),
`tests/direct-modules.test` and its mutants for a change to the
direct edge, and the isolation and interchange audits for a change to the
registry. Build BoringSSL once (`tclsh9.0 tests/cffi/boringssl.tcl`) so the
acceptance tests run. `bench/c-ffi.tcl` regenerates section 21. A change to
variadic calls (VARIADICS-VERTICAL-SLICE-1.md, "What to run when changing
this") also needs the `ffi_` Rust tests on an AArch64 host, which carry the
Apple and Linux AArch64 placements.

## 28. Files

| file | |
|---|---|
| surface/parser.tcl | `AtExternDecl`, `ExternDecl`, `ExternParam`: the grammar and its `EXTERN-SYNTAX` errors |
| surface/ast.tcl, surface/lower.tcl, surface/modules.tcl | the AST nodes, their collection per unit, the loader passing them to the build |
| hir/foreign.tcl | registration, validation, the link plan, bindings, the side tables, capture/Install |
| hir/hir.tcl, hir/declarations.tcl, hir/resolve.tcl, hir/hygiene.tcl, hir/semantic.tcl, hir/warnings.tcl | the build's options and side tables, isolation, the root-kind bindings and their names |
| hir/borrow.tcl | the extern arity, the result provenance, not-a-value, a variadic call's trailing C types (`cvarargs`) |
| hir/cabi.tcl (`VariadicArgument`), core/cabi.tcl (`promoted`) | a trailing argument's one C type and its default argument promotion |
| hir/direct.tcl | the retaining call as an authority source |
| core/native.tcl, core/cabi.tcl | `-extern` metadata, `isExtern`, `displayName`; the provenance in the contract, `ExternImpl` (NATIVE-ONLY) |
| native/lower.tcl, native/native.tcl, main.tcl | the foreign table, `foreigncall`, link directories, `-L` |
| native/src/nir.rs, codegen/clif.rs, codegen/roots.rs, codegen/mod.rs | the NIR, the C call and its transport (a variadic call's per-call signature, `c_call_signature`, and x86-64's stubs, `va_stub`: System V's `%al`, Win64's copies of the first four positions' floating-point arguments into their integer registers), the safepoint, the JIT's unlinked symbols |
| native/src/codegen/target.rs | the target's C convention, and which parameters carry an extension attribute (Apple's stack-passed ones do not) |
| native/src/codegen/aot.rs, native/src/main.rs, native/src/runtime/aot.rs | the link plan's arguments (per `LinkerFlavor`), linker failures, the stub's refusal, the linked run and its driver protocol |
| native/src/runtime/ffi.rs, runtime/error.rs | the slow paths and the two failures |
| examples/ffi/ | the Tcl and BoringSSL bindings and demos |
| tests/c-ffi.test, tests/cffi/fixture.c, tests/cffi/boringssl.tcl | the tests, the C fixture (its assembly in ELF or Mach-O spelling), the package-owned BoringSSL |
| tests/platform/aot-facts.tcl, tests/platform/native-status.tcl | a C library and a C call as the host's tools see them, the linker's command line and words; the `c-call` probe |
| audit/c-ffi/tools/, audit/c-ffi/*-result.txt | the fuzzer, the mutation tool and its mutants; their recorded runs |
| bench/c-ffi.tcl | the performance report |
