# C-ABI-TYPES.md

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: `std::ffi::c::Float`
> (C `float`, binary32) and `std::ffi::c::Double` (C `double`, binary64) are C
> representations `{cfloat NAME}` whose values are Float64s, admitted as
> pointees (`Ptr[std::ffi::c::Float]`, `Ptr[std::ffi::c::Double]`) and in function
> pointer signatures; C `long double` still has no type ("No `size_t`; one
> floating type").

The smallest C ABI type universe the header archaeology justifies: C integer
scalars by identity, `std::ffi::c::Void`, typed data pointers, function-pointer
types, and the five pointer operations -- plus the general callable
imprinting `std::ffi::c::null[T]()` needs.

> Model the C ABI values Botlish actually needs. Do not model the C
> language.

```botlish
import std::ffi::c

opaque struct SSL:               # the pointee identity of C's `struct ssl_st`
    tag: unit

fn status(p: std::ffi::c::Ptr[SSL]) -> bool:
    p.null?()

fn demo() -> bool:
    p = std::ffi::c::null[SSL]()      # std::ffi::c::Ptr[SSL]: imprinted at the call
    q = p.clone()                # a second alias: same address, same type
    v = std::ffi::c::erase(q)         # std::ffi::c::Ptr[std::ffi::c::Void] (q is moved)
    r = std::ffi::c::retype[SSL](v)   # std::ffi::c::Ptr[SSL] again (v is moved)
    status(r) and p.null?()

fn add(a: std::ffi::c::UChar, b: std::ffi::c::UChar) -> int:
    a + b                        # Botlish arithmetic: add(255, 255) is 510
```

> Continued by C-FFI.md: `extern c fn` calls C with exactly these types
> (linkage, the calling convention and the transport are there).

This milestone builds the value and type substrate that `extern c fn` and
`exported c fn` will use. It does not call C: there is no linkage, no symbol
lookup, no calling-convention lowering, no callback and no header import.
After it, the next C FFI work should be about linking and calling functions,
not about inventing another value or type system -- and nothing here makes
Botlish a C compiler, a C ownership system or a conventional generic
language.

## Contents

* [The substrate in one picture](#the-substrate-in-one-picture)
* [C integer scalars](#c-integer-scalars)
* [Targets](#targets)
* [std::ffi::c::Void](#fficvoid)
* [std::ffi::c::Ptr\[T\]](#fficptrt)
* [The pointer operations](#the-pointer-operations)
* [Function pointers](#function-pointers)
* [Imprinting](#imprinting)
* [Representation](#representation)
* [Layouts and pointers](#layouts-and-pointers)
* [Decisions](#decisions)
* [Diagnostics](#diagnostics)
* [Evidence: the archaeology, category by category](#evidence-the-archaeology-category-by-category)
* [What is not here](#what-is-not-here)
* [Remaining blockers for the C FFI](#remaining-blockers-for-the-c-ffi)
* [Testing](#testing)
* [Compiler performance](#compiler-performance)
* [What to run when changing this](#what-to-run-when-changing-this)
* [Files](#files)

## The substrate in one picture

```
std::ffi::c::Char ... std::ffi::c::ULongLong   C integer ABI identities
        |                            (an integer domain per C type, its range
        v                            the compilation's target's)
ordinary Botlish Int values

std::ffi::c::Void                         a permanently incomplete pointee

std::ffi::c::Ptr[T]                       a typed opaque C data pointer: affine,
                                     explicitly cloneable, nullable, not an
                                     Int, no ownership semantics

std::ffi::c::FnPtr[Fn{args: [..], return: R}]
                                     a C function pointer: signature-bearing,
                                     distinct from data pointers, not callable
                                     yet

std::ffi::c::null[T]()                    Ptr[T]: an explicit result imprint
std::ffi::c::null?(p)                     the pointer-zero test
std::ffi::c::clone(p)                     a second alias
std::ffi::c::erase(p)                     Ptr[T] -> Ptr[Void]
std::ffi::c::retype[T](p)                 Ptr[Void] -> Ptr[T]
```

Everything is reached through `import std::ffi::c`, like every other namespace
(IMPORTS.md). `stdlib/ffi/c.bot` is the namespace's module file: it documents
it, and declares nothing a file spells -- the scalars are the namespace's
intrinsic type declarations, `Void`, `Ptr` and `FnPtr` its intrinsic types,
and the operations its intrinsic natives (`core/cabi.tcl`).

## C integer scalars

```
std::ffi::c::Char    std::ffi::c::SChar    std::ffi::c::UChar
std::ffi::c::Short   std::ffi::c::UShort
std::ffi::c::Int     std::ffi::c::UInt
std::ffi::c::Long    std::ffi::c::ULong
std::ffi::c::LongLong  std::ffi::c::ULongLong
```

Each is an **integer domain** -- the existing `type Child = Int in LO..HI`
machinery (SOURCE-DEFINED-INTEGER-DOMAINS.md) -- whose range is exactly the
compilation's target's range of that C type, and whose registry entry also
records which C type it is on which target: `{c {unsigned long} target
windows-x86_64 bits 32 signed 0}` (core::type's `-c-abi`, read by
`core::type::cabiOf`). Nothing reads a width or a signedness from a name.

**Why not fixed-width names.** `std::ffi::c::Long` means C `long`, not "a signed
64-bit integer": it is 64 bits on LP64 (Linux, macOS) and 32 on LLP64
(Windows). A binding that says `long` must keep saying `long` on every
target, and the width is the target's fact. `I32`-style names would bake one
data model into every binding.

**Identity is not width.** On Windows x86-64 `std::ffi::c::Int` and `std::ffi::c::Long`
are both `Int in -2^31..2^31-1`, and they stay two types: identity is the
registry name (the existing rule for domains: two declarations of one range
are never identified), so `core::type::subtype std::ffi::c::Int std::ffi::c::Long` is
0 both ways and a parameter declared `std::ffi::c::Long` is a `long` parameter
whatever value reaches it. A *value* moves between them by its range, like
between any two domains: an `std::ffi::c::Int` argument is admitted where an
`std::ffi::c::Long` is declared because its range proves it fits. The declared
type is what a later C call lowers by.

**Values are Ints.** There is no second arithmetic universe. `a + b` of two
`std::ffi::c::UChar`s is Botlish addition (255 + 255 is 510, an Int); there is no
integer promotion, no usual arithmetic conversion, no wrapping and no
truncation -- C's source-level arithmetic rules are not the FFI value
boundary's business. Into a scalar, an Int goes only where its range proves
it fits (the ordinary admission rule of every domain, hir/range.tcl): `fn
f(x: int) -> std::ffi::c::UInt: x` is rejected, and the guarded version is
accepted. The analyses see the exact bounds through `core::type::
integerFacts`, as for every domain, so a later C call can prove "fits C
unsigned long" from ordinary facts.

**Plain char** is `std::ffi::c::Char`, distinct from `SChar` and `UChar`, and its
signedness is the target's: signed on x86-64 (Linux, macOS, Windows) and on
Apple and Windows AArch64, unsigned on Linux AArch64. It is never Botlish's
Byte and never `unsigned char` silently.

**No `size_t`; one floating type.** The binding generator knows
from its ABI probe which C type `size_t` (`ptrdiff_t`, `wchar_t`, `int64_t`,
...) is on a profile, and emits an alias of it (`size_t` -> `std::ffi::c::ULong`
on LP64); the archaeology found numeric typedef identity not worth making
nominal (C-HEADER-ARCHAEOLOGY.md item 63). `double` appears in 1 + 7
functions of the subject libraries: floats were their own language milestone
(FLOAT64-MILESTONE-1.md), which added `std::ffi::c::Double`, C `double` as
Botlish's Float64 under its C name, for `extern c fn` parameters and results
(passed in the target's floating-point registers; a NaN or an infinity
returned by C fails the call with `NonFiniteFloat`). It is a value type, not
a pointee: `Ptr[std::ffi::c::Double]` is not admitted yet. C `float` and `long
double` have no Botlish type.

**`_Bool` came later.** Neither subject library uses it in its public API,
so it was left out here; SDL3 uses it in 506 of its 1,405 API names, and the
binding generator's milestone added `std::ffi::c::Bool`, which is Botlish's own
`bool` with C `_Bool`'s ABI (one byte, 0 or 1; C-FFI.md section 3,
C-BINDGEN.md "C bool"). A pointer may point to one (`std::ffi::c::Ptr[std::ffi::c::Bool]`)
and a function pointer's signature may hold one. It is the only primitive
that milestone added.

## Targets

`core/cabi.tcl` is Botlish's own target table; ordinary compilation never asks
a C compiler:

| target | data model | `long` | `long long` | plain `char` | pointer | triple |
|---|---|---:|---:|---|---:|---|
| linux-x86_64 | LP64 | 64 | 64 | signed | 64 | x86_64-unknown-linux-gnu |
| linux-aarch64 | LP64 | 64 | 64 | **unsigned** | 64 | aarch64-unknown-linux-gnu |
| macos-x86_64 | LP64 | 64 | 64 | signed | 64 | x86_64-apple-darwin |
| macos-aarch64 | LP64 | 64 | 64 | signed | 64 | aarch64-apple-darwin |
| windows-x86_64 | LLP64 | **32** | 64 | signed | 64 | x86_64-pc-windows-msvc |
| windows-x86_64-gnu | LLP64 | **32** | 64 | signed | 64 | x86_64-pc-windows-gnu |
| windows-aarch64 | LLP64 | **32** | 64 | signed | 64 | aarch64-pc-windows-msvc |

A target is an operating system and an architecture: linux-aarch64 and
macos-aarch64 share an instruction set, a data model and a pointer width,
and are two targets (plain `char`, the C calling convention, the object
format and every platform interface differ). The triple is the name the
native backend knows a target by (MACOS-AARCH64-MILESTONE-2.md). On Windows
the C toolchain's ABI family is part of the target: windows-x86_64 is MSVC's,
windows-x86_64-gnu MinGW-w64's (C-BINDGEN-LAYOUTS.md added it for the Win32
bindings, whose record layouts MinGW-w64's compiler decided). Their rows agree;
they are two targets because C facts probed with one toolchain are that
toolchain's, never the other's.

`char` is 8 bits, `short` 16 and `int` 32 on all of them. A compilation's
target is `-target NAME` (main.tcl; `surface::compile`, `surface::
readProgramFile` and `surface::modules::compileProgramFile` take the same
option), the host's by default (`core::cabi::hostTarget`; a host outside the
table can still compile everything but `import std::ffi::c`, which then needs
`-target`). The target changes static types, and the HIR records it
(`hir::cabi::targetOf`; "" for a HIR that read no target fact, which is
every target's): the Tcl backends run a program compiled for any target,
and the native backends only one compiled for the host's own target
(`NATIVE TARGET` otherwise, MACOS-AARCH64-MILESTONE-2.md). Linux x86-64 and
AArch64 and macOS AArch64 reach machine code with C calls -- macOS since
MACOS-AARCH64-MILESTONE-6.md, where a real callee compiled by Apple clang
sees plain `char` signed, every scalar at its width and signedness and every
stack argument at Apple's packed offset (tests/c-ffi.test's `cf-abi-*`);
the other rows are metadata, tested as such (`ca-lp64-llp64`,
`ca-char-signedness`, `ca-scalar-matrix-llp64`, tests/target-model.test).

**Isolation.** When a file imports `std::ffi::c`, the loader (`surface/
modules.tcl`'s `LoadNamespace`) adds the eleven scalar declarations for the
compilation's target to the module's own (`hir::cabi::NamespaceTypeDecls`),
so they are ordinary per-compilation source types: registered by
`hir::sourcetypes::apply`, recorded in the HIR's `declarations`, re-installed
by `hir::activate`, printed in HIR text as

```
type std::ffi::c::Long parent Int domain interval -2147483648 2147483647 cabi {long} windows-x86_64
```

and read back by re-deriving the metadata from the C type and the target (a
range that disagrees with them is refused). A HIR compiled for one target
keeps its widths whatever is compiled after it (`ca-target-isolation`), and
interchange text and the front-end cache carry them (`ca-target-interchange`;
the target is part of `surface::cache::Key`). No new registry was needed.
Interchange text read as a compilation for another target is refused, never
reinterpreted (`hir::interchange::decode -target`, HIR-INTERCHANGE.md).

## std::ffi::c::Void

C's `void`, as a **permanently incomplete pointee**: it exists so that
`std::ffi::c::Ptr[std::ffi::c::Void]` -- C's `void *` -- is well typed. It is not
`unit`, not a top type, not `any`, not `never` and not a type of values: a
parameter, a result, a List element, a struct field, a layout field, a C
signature's argument and a construction `std::ffi::c::Void {...}` of it are all
rejected with one message (`hir::cabi::VoidMessage`). Statically it is the
pointee identity `void` inside `{cptr void}`, never a type a value has.

A C function returning `void` will return Botlish's `unit`: a C signature's
result is `unit` (`FnPtr[Fn{args: [...], return: unit}]`), never a fictitious
value of `Void`.

## std::ffi::c::Ptr[T]

A **typed opaque C data pointer**: an address with a statically known
pointee identity, `{cptr T}` in HIR (hir/types.tcl). Valid pointees
(`hir::cabi::PointeeProblem`):

| pointee | example | C |
|---|---|---|
| `std::ffi::c::Void` | `Ptr[std::ffi::c::Void]` | `void *` |
| a C integer scalar | `Ptr[std::ffi::c::Int]`, `Ptr[std::ffi::c::Char]` | `int *`, `char *` |
| an opaque struct | `Ptr[SSL]` | `SSL *` (`struct ssl_st *`) |
| a pointer | `Ptr[Ptr[SSL]]`, `Ptr[Ptr[Ptr[Tcl_Obj]]]` | `SSL **`, ... |
| a function pointer | `Ptr[FnPtr[Fn{...}]]` | a pointer to a callback variable |

Everything else is rejected, because nothing gives it a C representation
contract: `int`, `bool`, `str`, `List[int]`, an enum, a `Fn`, an ordinary
(non-opaque) struct, `LayoutStruct[L]`, and an integer domain that is not one
of the C scalars (`std::binary::U32`, `std::byte::Byte`). Nesting is structural, to any
depth: nothing special-cases two or three levels; the archaeology's maximum
of three is not a limit.

**Not an Int.** A pointer has pointer-width representation but no numeric
domain: no arithmetic, ordering, bitwise operation, range reasoning or
integer conversion exists, in either direction. `p + 1`, `p < q`, `bit_and(p,
1)` and passing a pointer where an `int` is declared are compile-time TYPE
errors (`hir::cabi::verify`: "a pointer is an opaque address, not an Int");
an Int where a pointer is declared, or given to `retype`, is the ordinary
TYPE mismatch. There is no `std::ffi::c::Ptr[T](n)`, no `from_int`, and no
public way at all to make a pointer from an Int.

**Invariant, no implicit conversion.** `Ptr[A]` is a `Ptr[B]` only when A is
B. In particular `Ptr[Foo]` is *not* a subtype of `Ptr[Void]`, though C
converts implicitly: the bridges are the explicit `erase` and `retype`. Two
different pointer types join to the bare runtime kind `cptr` (a pointer of no
single pointee), which is still affine and fits no declared pointer
parameter.

**Affine.** A pointer has one usable owner: binding, passing, returning and
storing it move it, the moved name is dead (`USE-AFTER-MOVE`), and
`p.clone()` is the one way to hold two aliases. This is the existing affine
machinery (AFFINE-VALUES.md) -- `hir::types::AffineRoot` gains the C address
types, and nothing else is C-specific: a struct or a List holding a pointer
is affine by the ordinary rule, a closure cannot capture one
(`AFFINE-CAPTURE-UNSUPPORTED`), `==`, `hash` and ImmutableSet membership are
`AFFINE-EQUALITY-UNSUPPORTED`, an untyped function given one is specialized
for it, and a declared error path moves and releases it like any affine
value. The same rules decide the rest, with no pointer exception: an error
payload may carry a pointer (`fail Failed {handle: p}`, destructured by its
handler); a coroutine may own one as an argument, but a coroutine's
segments may not end with one (`COROUTINE-CONTRACT`: a completed coroutine
returns its cached result again); a MutableVector, a MutableArray and a List
may own pointers; so may a context struct -- installation moves it into the
installed context, which owns it, and a contextual function observes it
where it is stored, never copying it out (`AFFINE-CONTEXT-COPY-OUT`;
CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md: before it, installing one was
`AFFINE-ERASURE-UNSUPPORTED`) -- but not an ImmutableSet. A pointer owns nothing,
so its owner's death releases nothing:
`hir::affine::Descriptor` gives it no descriptor, and an aggregate that owns
only pointers needs no release at all.

**Affinity is not ownership.** A raw pointer means *an opaque foreign address
with a statically known pointee identity* -- not that the program owns,
must free, uniquely references, controls the lifetime of, or may dereference
the pointee. Affinity makes aliasing visible (`clone` is written), nothing
more; ownership, reference counting and freeing belong to the wrappers a
binding builds on top.

## The pointer operations

| operation | type | ownership | native code |
|---|---|---|---|
| `std::ffi::c::null[T]()` | `Ptr[T]` | -- | the constant word |
| `std::ffi::c::null?(p)`, `p.null?()` | any C pointer -> `bool` | observes `p` | one comparison |
| `std::ffi::c::clone(p)`, `p.clone()` | `p`'s own type | observes `p` | none (the same word) |
| `std::ffi::c::erase(p)` | `Ptr[T]` -> `Ptr[Void]` | moves `p` | none |
| `std::ffi::c::retype[T](p)` | `Ptr[Void]` -> `Ptr[T]` | moves `p` | none |

None reads memory, calls foreign code, allocates or retains anything. `clone`
copies the address, never the pointee, and touches no reference count: it is
deliberate alias creation, not `AddRef`. A null pointer is an ordinary
`Ptr[T]` value -- there is no nullable wrapper, no `Option[Ptr[T]]` and no
Botlish-wide null: null belongs to the C pointer universe, as a
distinguished representation `null?` inspects -- and cloning, erasing and
retyping it keep it null; no object is allocated for it.

`erase` exists for data pointers only: a function pointer given to it is
rejected ("data and function pointers are distinct, and nothing converts
one into the other"), and `retype` takes exactly a `Ptr[Void]` (a
`Ptr[Foo]` must be erased first). `retype[Foo](p)` means *use the same bits
with pointee identity Foo*; it proves nothing about the pointee -- that a
Foo lives there, alignment, lifetime, ownership or safety.

## Function pointers

```botlish
std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Ptr[std::ffi::c::Void]], return: std::ffi::c::Int}]   # int (*)(void *)
std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Ptr[std::ffi::c::Void]], return: unit}]          # void (*)(void *)
```

A C function pointer is its own type category, `{cfnptr F}`, F the
canonical structural function type `{fn {args ... return R errors {}}}`: the
existing signature structure (STRUCTURAL-FUNCTION-TYPES.md), reused, with
the C ABI marker `FnPtr` around it. Ordinary type syntax, no C declarator:
the argument types and the result must be C ABI value types (a scalar, a
`Ptr`, a `FnPtr`; the result also `unit`), and no `errors` (C reports
none).

It is distinct from a data pointer (no `erase`/`retype` of it, no conversion
to or from `Ptr[Void]`: C has no portable object/function pointer
equivalence) and from a Botlish `Fn` (neither is a subtype of the other: a
Botlish function value is not a C function pointer, and calling a `FnPtr`
from Botlish is rejected until C calls exist). It shares the data pointer's
runtime kind and its operations `null?` and `clone`. It is **affine**, like a
data pointer, for consistency: both are raw foreign addresses whose lifetime
Botlish does not manage (a function pointer can point into an unloaded
library or a freed trampoline), and Botlish's own `Fn` values are
unrestricted only because Botlish manages their lifetime. C returns them
(an `extern c fn` result), the test fixture makes them, and since
C-CALLBACK-MILESTONE-1.md `std::ffi::c::callback(NAME)` makes one of a
`callback c fn` NAME: the address of its C entry point, of exactly its
declared C signature, affine like the others. Nothing converts a Botlish
`Fn` into one, and Botlish still never calls a `FnPtr`. A null one still
has no operation (`null[T]()` makes a `Ptr[T]`).

The archaeology's specimens (`ca-fnptr-specimens`):

| C | Botlish |
|---|---|
| `int (*)(void *)` | `FnPtr[Fn{args: [Ptr[Void]], return: Int}]` |
| `void (*)(void *)` | `FnPtr[Fn{args: [Ptr[Void]], return: unit}]` |
| `int (*)(int, X509_STORE_CTX *)` | `FnPtr[Fn{args: [Int, Ptr[X509_STORE_CTX]], return: Int}]` |
| `int (*)(char *, int, int, void *)` | `FnPtr[Fn{args: [Ptr[Char], Int, Int, Ptr[Void]], return: Int}]` |
| `Tcl_ObjCmdProc` | `FnPtr[Fn{args: [Ptr[Void], Ptr[Tcl_Interp], Int, Ptr[Ptr[Tcl_Obj]]], return: Int}]` |
| `Tcl_FreeProc *` | `FnPtr[Fn{args: [Ptr[Char]], return: unit}]` |
| a function returning a callback | `FnPtr[Fn{args: [Int], return: FnPtr[Fn{...}]}]` |
| a pointer to a callback typedef | `Ptr[FnPtr[Fn{...}]]` |

(every name in `std::ffi::c::`, the opaque tags declared by the binding). A
callback typedef (`Tcl_ObjCmdProc`) is a binding-generator alias of its
`FnPtr` type -- naming the protocol is generator policy, not a compiler
primitive. **Variadic** function pointers are deferred: no spelling exists
for one, so Tcl's one variadic callback type (`Tcl_PanicProc`) cannot be
written yet. Vararg *calling* exists since VARIADICS-VERTICAL-SLICE-1.md (an
`extern c fn` ending in `variadic`, each call's trailing types its own); a
function pointer's type carries no per-call trailing types, so a variadic
callback stays unsupported (C-BINDGEN.md's `unsupported-callback-signature`).

## Imprinting

`std::ffi::c::null[T]()` is not a generic function, a template, a monomorphized
native or a native per T: there is one `null`, and the brackets supply the
**imprint** that determines its statically returned pointer type. The
mechanism is general -- user functions take part through exactly the same
path -- and it is not generics: there are no declared type parameters
(`fn f[T](...)` stays a syntax error), no constraints, no instantiation,
and no specialization keyed by a variable.

```botlish
fn first(xs: List[T]) -> T errors IndexNotFound:   # T established by the List
    std::list::at(xs, 0)

fn lookup(m: MutableArray[K], key: K) -> K:        # K established, then used
    key

fn empty() -> List[T]:                             # T only in the result
    []

first(["a"])           # str
empty[int]()           # List[int]: the result-only T supplied at the call
first[int]([])         # an explicit imprint also constrains the arguments
```

The rules (hir/imprint.tcl):

* **Variables.** In a function's parameter and result annotations, a name of
  one capital letter, optionally followed by digits (`T`, `K`, `V`, `T2`),
  that names no visible type is an imprint variable, `{imprint T}` in HIR.
  Everywhere else such a name is the unknown type it always was.
* **Establishing.** A variable is established by an argument when it occurs
  inside an applied type of the parameter: an element of `List`,
  `ImmutableSet`, `MutableArray` or `MutableVector`, a pointee of
  `std::ffi::c::Ptr`, a type of an `std::ffi::c::FnPtr` signature. The argument's static
  type there says what it is.
* **Using.** A bare parameter `x: T`, or `T` inside a `Fn` type, establishes
  nothing: it uses a variable an *earlier* parameter established (left to
  right). `fn identity(x: T) -> T` and `fn sizeof(x: T) -> int` are rejected
  at their declaration ("unknown or invalid type ... no type named T is
  visible here, and as an imprint variable T is not established"), with the
  ordinary TYPE kind: from the program's point of view T is an invalid type
  there.
* **Result-only.** A variable that occurs only in the result is supplied at
  each call: `null[SSL]()`, `empty[int]()`; without one the call is rejected.
* **Explicit imprints** `f[A, B](...)` (also `x.f[A](...)` and `ns::f[A](...)`)
  are all or nothing, in the order the variables first occur in the
  signature (parameter types left to right, then the result). Without them
  every variable must be established by the arguments; two arguments that
  establish a variable differently are rejected (an empty List says
  nothing). The imprinted parameter types are what the arguments are then
  held to, by the ordinary admission proof.
* **The body** is checked once, for every T: a variable is rigid there --
  related only to itself, `never` and `any` -- so `fn bad(xs: List[T]) -> T:
  5` is rejected. It is compiled once, its T values handled as values of any
  type.
* **Nested functions.** A nested function's signature is written in the
  enclosing function's body, where a type naming the enclosing function's
  variable is that variable (an explicit imprint, an applied construction):
  so is a name in the nested signature. Only the variables no enclosing
  function has are the nested function's own, bound at its calls; an
  enclosing one is rigid there, as in the enclosing body (constrained as
  the enclosing signature constrains it), established without an argument
  (`fn g(x: T)` is fine inside a function that has T), never bound at a call
  of the nested function, and every argument is held to it: in
  `fn outer(b: Box[T])`, a nested `fn g(c: Box[T]) -> List[T]` takes `b`
  but not `Box {value: "s"}` (TYPE). A nested function whose every variable
  is an enclosing one has no imprint signature: it takes no explicit
  imprint and may be used as a value (`hir::imprint::BlockSignature`,
  `EnclosingOf`, `ConstrainEnclosing`). Before, the nested function bound such a T anew
  at each call while its body's captured values kept the enclosing T --
  one term `{imprint T}` for two variables -- and an ill-typed program
  was accepted.
* **Affinity.** A variable bound where values of it exist must not be an
  affine type (the body may copy its values); one that occurs only as a
  pointee (`Ptr[T]`) may be any valid pointee, a pointer included.
* **Not a value.** An imprinted callable is only called: `g = empty` and `g =
  std::ffi::c::null` are rejected (a function value has no call site to imprint
  at).

**What existed, what changed, what did not.** Before this milestone Botlish
had no type variables anywhere: `fn first(xs: List[T]) -> T` was "unknown
type T". It had imprinting of *types* from construction values
(`std::mutable_array::create`'s element from its default, `LayoutStruct[L]` from a
layout, NATIVE-BOTLISH-LOWERING-IMPL.md §6.3), per-native result rules
(`-result-shape`), and semantic instances that recover "result type ==
parameter type" from an untyped body (OPPORTUNISTIC-SEMANTIC-INSTANCES.md).
This milestone added:

* the variable form `{imprint T}` and its rigid relations (hir/types.tcl);
* signature resolution with variables and the establishment check
  (`hir::resolve::ResolveTypeExpr`'s IMPRINTS, `hir::imprint::CheckSignature`);
* one binding path for every statically known callee
  (`hir::imprint::Signature`/`Bind`/`Substitute`, from `hir::types::Call`;
  `hir::range::VerifyCall` and `VerifyImprintedNative` hold arguments to the
  imprinted parameters) -- a Botlish function's signature is its declared
  types, an intrinsic's its registry entry's `-imprint` (core/native.tcl);
* the syntax `NAME[TYPE, ...](...)`, `ns::NAME[...](...)`, `x.NAME[...](...)`
  (surface/parser.tcl; the token after `]` decides between it and an applied
  type's construction `NAME[TYPE] {...}`), a call's `imprint` field in HIR
  and in HIR text (`call native(std::ffi::c::null) imprint [SSL]`);
* the `IMPRINT` diagnostic (and its `std::compiler::DiagnosticCode::Imprint`).

No specialization or instance machinery changed: an imprinted function is
one codegen function; a semantic instance of it is requested only when an
argument is a subtype of its rigid declared type (an empty List), as for any
declared parameter. What remains impossible: a variable established by a
bare argument; a variable inside a `Fn` type establishing anything; a
variable that is a type of a struct field (no user generic types); passing an
imprinted function as a value; imprinting an affine type where values of it
exist; ordering imprints by name.

> Since TRAIT-CONSTRAINED-IMPRINTED-TYPES.md, a struct may declare type
> slots (`struct Map[K satisfies Hashable, V]:`): a field's type may name a
> slot, and matching an application `Map[K, V]` establishes K and V like
> any applied type, with the slot's constraint as a fact about K. Functions
> still declare no type parameters and no constraints.

## Representation

**HIR.** The C types are semantic type facts, never strings a later pass
reparses: a scalar is the canonical domain type `{refined int
{std::ffi::c::Long}}` whose registry entry carries the C ABI metadata; a data
pointer `{cptr POINTEE}`; a function pointer `{cfnptr {fn {...}}}`; a
variable `{imprint T}`. Types print as the programmer spells them --
`std::ffi::c::ULong`, `std::ffi::c::Ptr[SSL]`, `std::ffi::c::Ptr[std::ffi::c::Void]`,
`std::ffi::c::FnPtr[Fn{args: [...], return: R}]` -- and HIR text reads them back
(`hir::read::ParseType`). The bare kind `cptr` (a pointer of no single
pointee, the join of two pointer types) prints as `cptr`.

**Interpreter** (core/value.tcl, core/cabi.tcl). `{cptr ADDRESS}`: its own
kind, the address bits as an unsigned decimal, 0 for null. Never an Int (`
core::value::intOf` refuses it), no equality, no hash, shown as `<C pointer
0x1000>`. The Tcl backends have no machine addresses; null and the fixture
are its only sources.

**Native** (native/src/runtime/value.rs). An immediate word, `(address << 4)
| 0b1110`, null the bare tag (14): never heap-allocated, never a GC root, no
pointee descriptor -- `Ptr[Foo]` and `Ptr[Bar]` are the same bits. The low
four bits are disjoint from every other kind's (a small Int's `...1`, a
UnicodeChar's `100`, an enum case's `10010`, a heap pointer's `000`, the
constants 2, 6 and 10), so the existing kind checks need no change. The
payload is the address as a sign-extended 60-bit number: every canonical
x86-64 address (user or kernel, 4- or 5-level paging) and every untagged
AArch64 address round-trips; an AArch64 pointer with a top-byte tag
(TBI/MTE) does not, and the C call boundary will have to check (or box)
such an address, the way an Int has small and big forms. (The test
fixture makes addresses 0..2^59-1 only, so `ca-ptr-wide-address` exercises
the non-negative half up to its top; the negative half waits for a C call
to return one.) NIR has five ops: `cptrnull` (a constant), `cptrisnull` (one
`icmp_imm` with 14), `cptrsame` (clone, erase and retype: the SSA value
itself, no machine instruction) and the fixture-only `cptrfixture` and
`cptrfixtureaddress` (`ca-native-code` pins the first three and that none
calls a helper or allocates). Inside the uniform `Value` word a
raw 64-bit address cannot be unboxed whole -- the word 0 means "error
pending" and an 8-aligned word would be traced as a heap object -- so the
target-width representation proper (rule 60) is for the C call boundary
(raw registers), which does not exist yet.

## Layouts and pointers

**C scalars are layout fields with no C-specific rule** (BINARY-LAYOUT.md's
"Scalar encodings": the encoding follows from the interval). `field n:
std::ffi::c::UInt at 0` is a 4-byte unsigned field; `std::ffi::c::Long` is 8 bytes on
LP64 and 4 on LLP64; `std::ffi::c::Char` signed or unsigned by target
(`ca-layout-target-encodings`); 4000000000 round-trips through
`std::binary::emit` and `std::binary::parse` on every backend.

> **Follow-up (NATIVE-LAYOUT-VIEWS.md).** Pointer fields now exist and are
> *native-only*: a layout with one is read through a native view of live
> native memory (`std::binary::native::view`, `NativeView[L]`), where the pointer
> is the one foreign memory holds -- the first mechanism below -- and
> `std::binary::parse` / `std::binary::emit` of it are `LAYOUT-NATIVE-ONLY`. The
> paragraphs below are this milestone's account. NATIVE-LAYOUT-WRITES.md
> then wrote them: through a native edit (`std::binary::store`), and into byte
> storage only by the explicit foreign encoding of an existing pointer
> (`std::binary::write_foreign`) -- still never decoded back from bytes.

**Pointer fields remain deliberately unsupported** (LAYOUT-FIELD-TYPE: "a C
pointer, not a binary scalar: imprinting arbitrary bytes into it would
fabricate a pointer"). `std::binary::parse(L, bytes)` accepts arbitrary bytes; if
it could produce a `Ptr[T]`, any byte string would become authority to an
address nothing gave the program. The archaeology makes pointer fields the
next layout requirement (52 + 27 structs need only that), and the safe
mechanisms are still open: imprinting from actual foreign storage (a view of
memory C handed over), a trusted pointer-valued scalar path only foreign
memory can fill, or another capability-preserving mechanism. This milestone
decides none of them.

**Pointer to a layout-backed struct.** A complete C struct has two separate
facts: its nominal pointee identity (an opaque struct, what `Ptr[...]`
names) and, when a consumer allocates or reads it, its physical layout (a
`layout`). `Ptr[LayoutStruct[L]]` is rejected: `LayoutStruct[L]` is a Botlish
value imprinted from bytes, not a pointee identity. Linking the two facts
(reading a `LayoutStruct[L]` through a `Ptr[Tag]`) waits for foreign memory
access.

## Decisions

* **Opaque pointee identities use `opaque struct`** (OPAQUE-STRUCTS.md), no
  new declaration form. An opaque struct is a nominal identity with a
  representation only its module sees; as a pointee it names the foreign
  object, and its Botlish fields are never the pointee's layout. The binding
  generator emits one per incomplete tag (`opaque struct SSL:` with a
  placeholder field such as `tag: unit`); its owner could construct a
  Botlish value of it, which is never a foreign object and can never become
  a pointer (there is no address-of). An ordinary struct is rejected as a
  pointee: its public fields would read as a C layout.
* **Pointee `const`** is not represented. With no dereference, store or view,
  it has no observable consequence in the core yet; the binding generator's
  IR keeps it (2,549 + 538 parameters) until memory access gives it meaning.
  `volatile`, `restrict` and nullability annotations: none (0 uses).
* **Equality** is not provided: a pointer is affine, and `==` of an affine
  value is AFFINE-EQUALITY-UNSUPPORTED for every affine type; an exception
  for pointers would weaken that uniform rule. Address identity, if a
  binding needs it, is one observing operation (both arguments `observe`d)
  to add with the C calls.
* **Hashing and containers** follow the affine rules: a List, MutableVector
  or MutableArray may own pointers, an ImmutableSet may not.
* **Null proof refinement** (`if not p.null?()` establishing non-null) is not
  built: `null?` is an ordinary Boolean predicate. The proof machinery
  (REFINEMENT-VALUES.md) refines carriers by declared refinements; a
  non-null pointer fact would be a new kind of fact, and nothing consumes
  one yet.
* **Function pointers are affine** (above), and **variadic** ones deferred
  (variadic calls of declared C functions are VARIADICS-VERTICAL-SLICE-1.md's).
* **Typedefs, enums and arrays** are generator concerns: integer typedefs are
  aliases of the scalar the probe found, callback typedefs aliases of their
  `FnPtr`, opaque-handle typedefs the opaque struct's name; a C enum is the
  probed integer scalar plus generated constants (its storage is an ABI
  probe fact, and Botlish's closed `enum` would reject the values C passes);
  an array parameter is a pointer to the call, an array field a future
  layout repetition. No `std::ffi::c::Typedef`, no C enum type, no C array type.

## Diagnostics

| situation | kind | message (abridged) |
|---|---|---|
| invalid pointee `Ptr[int]`, `Ptr[str]`, ordinary struct, ... | TYPE | invalid pointee in std::ffi::c::Ptr[int]: int has no C representation ... |
| `std::ffi::c::Void` as a value type, or constructed | TYPE | std::ffi::c::Void is C's void: an incomplete type with no values ... |
| a pointer as an Int (`p + 1`, `p < q`, an `int` parameter) | TYPE | argument 1 of + is std::ffi::c::Ptr[std::ffi::c::Int], a C pointer, where + requires int ... |
| an Int as a pointer (`take(1234)`, `retype[A](1234)`) | TYPE | ... cannot be proven to satisfy std::ffi::c::Ptr[A] (argument type: int) |
| `std::ffi::c::Ptr[A](1234)` | UNKNOWN-SYMBOL | std::ffi::c::Ptr is a type, not a value or a function: no pointer is made from an Int ... |
| implicit pointer-type mismatch | TYPE | ... cannot be proven to satisfy std::ffi::c::Ptr[SSL] (argument type: std::ffi::c::Ptr[Ctx]) |
| `retype` of a non-`Ptr[Void]` | TYPE | ... a pointer's pointee identity is never converted implicitly (std::ffi::c::erase ...) |
| `erase` of a function pointer | IMPRINT | ... the C function pointer ... where a data pointer std::ffi::c::Ptr[T] is required: data and function pointers are distinct ... |
| a function pointer where `Ptr[Void]` or `Fn` is declared | TYPE | the ordinary mismatch |
| calling a function pointer | TYPE | cb is a C function pointer ...: Botlish cannot call one yet |
| invalid C signature | TYPE | invalid signature in std::ffi::c::FnPtr[...]: argument 1: int is not a C ABI value type ... |
| a pointer layout field | LAYOUT-FIELD-TYPE | ... imprinting arbitrary bytes into it would fabricate a pointer ... (since NATIVE-LAYOUT-VIEWS.md: the field is legal, and `std::binary::parse`/`emit` of its layout is LAYOUT-NATIVE-ONLY) |
| bare unestablished imprint variable | TYPE | unknown or invalid type for parameter "x": no type named T is visible here, and as an imprint variable T is not established ... |
| missing / wrong number of / unbindable explicit imprints | IMPRINT | empty: imprint variable T is not established ...; convert takes 2 imprint(s), [A, B] ...; std::ffi::c::null: T is imprinted as int, which cannot be a pointee ... |
| an imprinted callable as a value | IMPRINT | empty has imprint variables, so it is not a value ... |
| moves, captures, equality | the affine kinds | USE-AFTER-MOVE, AFFINE-CAPTURE-UNSUPPORTED, AFFINE-EQUALITY-UNSUPPORTED |

Existing kinds are used wherever they describe the error; the one new kind,
`IMPRINT`, is the imprinting mechanism's (not C's), recoverable in a `static
compile:` block as `std::compiler::DiagnosticCode::Imprint`. `UNKNOWN-TARGET` is
the loader's, for `import std::ffi::c` on a host outside the target table with no
`-target`.

## Evidence: the archaeology, category by category

| category | evidence (C-HEADER-ARCHAEOLOGY.md) | here |
|---|---|---|
| integer scalars | in essentially every function; `long` 8 bytes here, 4 on Windows; plain `char` fields in 6 + 2 structs | `std::ffi::c::Char` ... `ULongLong`, target-resolved |
| `Ptr[T]` | 3,012 of 3,109 BoringSSL and 884 of 919 Tcl functions take or return pointers; 2,098 + 405 opaque-struct pointers | typed pointers over opaque struct identities |
| `Ptr[Ptr[T]]` | 367 + 68 functions, depth up to 3 | structural nesting, any depth |
| `Ptr[Void]` | 421 + 106 `void *` parameters, every userdata (57 of Tcl's 66 callbacks pass `void *clientData`) | `std::ffi::c::Void` and `erase`/`retype` |
| function-pointer type | 145 + 112 callback typedefs; 451 + 52 functions take callbacks | `std::ffi::c::FnPtr[Fn{...}]` |
| `Void` | required for `void *` | an incomplete pointee |

Omitted, and why: floats (1 + 7 functions; their own milestone); `_Bool` (0
public uses; added later for SDL3, `std::ffi::c::Bool`); `size_t`/`ptrdiff_t`/`wchar_t` as primitives (generator
aliases: typedef identity is not worth making nominal); C enums (21 + 2
signatures, probed integer scalar + constants); arrays (49 + 5 fields: future
layout repetition; parameters decay to pointers); varargs and `va_list` (5 +
11 and 2 functions, each with a non-variadic sibling); by-value aggregates
(0); unions and bitfields (layout features, behind pointers in every
function); `volatile`/`restrict`/nullability (0); pointee `const` (no
consequence without dereference).

## What is not here

`extern c fn`, `exported c fn`, linking, symbol lookup, calling conventions,
C calls, callbacks, trampolines, captured callbacks, header import or parsing
in the compiler, binding generation, C compiler invocation during
compilation, dereference (`*p`, `load`, `store`, fields, indexing),
pointer arithmetic, C strings, ownership (free, retain, borrow, unique
pointers), nullability inference, C integer promotions, varargs, aggregates
by value, floats, unions, bitfields, fixed arrays, a general unsafe mode,
and general generic declarations.

## Remaining blockers for the C FFI

> **Follow-up (C-POINTER-BORROWING.md).** Passing existing Botlish byte
> storage to a C pointer parameter now exists as a call-boundary capability:
> a per-parameter foreign call contract (access read | write, escape
> noescape | captures | unknown) admits an `std::abi::bytes::Bytes` or
> `MutableBytes` for one call, never as a `Ptr` value. An `extern c fn`
> attaches the same contract to its parameters (that document's section
> 14).

For **`extern c fn`**:

1. a declaration form and its linkage: the link symbol (asm labels,
   `#pragma redefine_extname` and `BORINGSSL_PREFIX` renames are the
   generator's), static and dynamic linker inputs (the stub linker and the
   rustc linker both);
2. ABI call lowering: integer scalars by the width and signedness their
   metadata records (sign/zero extension into registers), pointers as raw
   machine words (unboxing the tagged word, and checking the 60-bit payload
   of a returned address), SysV/AAPCS64 register assignment for integers
   and pointers only (no aggregates, no varargs; `double` since
   FLOAT64-MILESTONE-1.md);
3. the C boundary's restrictions: no Botlish error or `yield` crosses a C
   frame; a stack-walk/GC story for C frames between Botlish frames;
4. rejecting a HIR whose C target is not the host for native code.

For **`exported c fn`** and **static callback passing**:

1. producing a `FnPtr` value from a top-level, non-capturing Botlish
   function with a C signature (its address, a C-ABI entry trampoline into
   the Botlish calling convention) -- done: `callback c fn` and
   `std::ffi::c::callback` (C-CALLBACK-MILESTONE-1.md), for synchronous,
   non-retaining callbacks into the active execution environment;
2. a null function pointer operation (`null[T]()` makes a `Ptr[T]`) --
   still open;
3. the same error/yield restrictions in the other direction -- done
   (C-CALLBACK-MILESTONE-1.md: CALLBACK-SIGNATURE, CALLBACK-ENVIRONMENT,
   and a run-time failure ends the process);
4. userdata: already expressible as `Ptr[Void]` with `erase`/`retype`.

No new basic value type is on either list.

## Testing

`tests/c-abi-types.test` (all four backends where a program runs):
targets and data models; the scalar matrix and both bounds of every scalar
on three targets; LP64/LLP64 and plain-char metadata; arithmetic and
narrowing; distinct identity; printing and HIR text; target isolation,
interchange and the cache key; the namespace; Void; pointer formation,
pointee validation, the operations, bit preservation (through the fixture's
`address_of`), no implicit conversion, not-an-Int; affinity (move, clone,
equality, capture, aggregates, generic functions, error paths); function
pointers (every archaeology specimen, invalid signatures, distinctness,
affinity); error payloads, coroutines, vectors and contexts holding pointers;
addresses beyond 32 bits up to the fixture's largest, and the fixture's own
range; layouts; imprinting independent of FFI (structured input,
results, result-only, bare input, established variables, explicit
imprints, ordering, conflicts, parametric bodies, not-a-value, affinity, one
path for user functions and intrinsics, method sugar, HIR text); generated
native code.

**Non-null pointers in tests.** This milestone has no source of a non-null
pointer. `core::cabi::installTestFixture`, called from Tcl by a test process,
registers `ffi_fixture::address[T](n)`, `ffi_fixture::function_address[F](n)`
and `ffi_fixture::address_of(p)`; nothing in the compiler, the libraries or
main.tcl calls it, so no program outside a test process can name them, and
the native ops they lower to (`cptrfixture`, `cptrfixtureaddress`) are
reachable from no other native.

**Mutants.** `audit/c-abi-types/tools/mutate.tcl` applies the 26 mutants of
`audit/c-abi-types/tools/mutants.txt` one at a time (the native ones to a
private copy of `native/`, rebuilt) and runs `tests/c-abi-types.test` and the
fuzzer against each: target data models (`ulong-64-on-llp64`,
`char-always-signed`, `scalar-metadata-dropped`, `hir-text-trusts-range`,
`target-not-isolated`), pointer identity (`ptr-as-int`,
`implicit-ptr-conversion`, `null-loses-pointee`, `clone-loses-pointee`,
`void-constructible`, `arbitrary-pointee`, `retype-accepts-function-pointers`,
`fnptr-erasable`), ownership (`clone-consumes`, `pointer-not-affine`,
`pointer-released-as-coroutine`), representation (`erase-changes-bits-interp`,
`erase-changes-bits-native`, `null-test-native-wrong-constant`,
`address-word-truncated`) and imprinting (`imprint-only-intrinsics`,
`bare-variable-accepted`, `imprint-variable-not-rigid`,
`imprint-affine-binding`, `imprint-explicit-ignored`,
`imprinted-callable-as-value`). All 26 are killed (2026-10-16).
`address-word-truncated` (the native word keeping 32 bits of the address)
survived the first run: every test and fuzz address fit in 32 bits. It is
killed by `ca-ptr-wide-address`, and the fuzzer now draws addresses up to
2^59-1.

**Fuzz.** `audit/c-abi-types/tools/fuzz.tcl` generates pointer chains
(nesting, pointee categories, clone/erase/retype sequences, invalid pointees
and retypes), scalar bound probes on random targets and imprinting calls,
each with its outcome computed by an independent model in the fuzzer (its
own copy of the data models), and runs every accepted program on every
backend that runs its target here (`backendsFor`, keyed by the HIR's target:
all four for the host's, the Tcl backends for another, whose program the
native driver refuses: NATIVE TARGET): 0 disagreements in 40 programs each
for seeds 1, 17 and 41. After the compilation-targets milestone it ran other
targets' programs natively too and reported every refusal as a disagreement
(seeds 1, 2 and 7: 3, 9 and 4; seed 7 is mutate.tcl's, so its fuzz verdict
killed every mutant); since keying the backends by target (2026-10-21) it
reports 0 for seeds 1-7, 17, 41 and 99 and in 300 programs each for seeds 11
and 12, and at mutate.tcl's seed kills 15 of the 26 mutants by itself (the
test file kills all 26).

## Compiler performance

`bench/c-abi-types.tcl -k 100 -runs 3` (2026-10-16, a 4-core container
running other jobs: ratios, not absolute times, are the point): programs of
100 functions with four C-typed parameters each, beside the same programs
with ordinary types.

| shape | C front end | ordinary | ratio | C NIR | ordinary | ratio |
|---|---:|---:|---:|---:|---:|---:|
| 400 pointers to 100 distinct opaque structs (vs `List[S]`) | 1200 ms | 1348 ms | 0.89 | 60 ms | 125 ms | 0.48 |
| 400 pointers nested 6 deep (vs `List` nested 6 deep) | 2176 ms | 2067 ms | 1.05 | 111 ms | 112 ms | 0.99 |
| 400 C scalar parameters (vs `int`) | 564 ms | 458 ms | 1.23 | 44 ms | 39 ms | 1.12 |
| 400 function pointers of 4-argument C signatures (vs `Fn{...}`) | 1586 ms | 780 ms | 2.03 | 27 ms | 57 ms | 0.46 |
| 100 `null[T]()` of distinct pointees + an imprinted call (vs plain calls) | 964 ms | 457 ms | 2.11 | 90 ms | 51 ms | 1.76 |

Every shape is linear in K (the same ratios hold at K = 5): no instance,
registration or walk grows with the number of distinct pointer types. The
constant factors that remain are the ordinary costs of what the C programs
say, not of the representation: a pointer is affine, so the ownership
analysis tracks moves and (empty) releases of every pointer binding where an
unrestricted List or `Fn` needs none; a function-pointer parameter's
signature is resolved and validated argument by argument; and the imprinted
programs declare an opaque struct per function, which their twins do not.

## What to run when changing this

If you change `core/cabi.tcl`, `hir/cabi.tcl`, `hir/imprint.tcl`, the `cptr`,
`cfnptr` or `imprint` cases of `hir/types.tcl`, the pointer or imprint parts
of `hir/resolve.tcl`, `hir/range.tcl`, `hir/read.tcl`, `hir/format.tcl`,
`surface/parser.tcl` or `surface/modules.tcl`, or the C address word or ops
(`native/src/runtime/value.rs`, `ops.rs`, `show.rs`, `native/src/nir.rs`,
`codegen/clif.rs`, `native/lower.tcl`), run `tests/c-abi-types.test`,
`audit/c-abi-types/tools/fuzz.tcl` (several seeds) and
`audit/c-abi-types/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed), plus the affine harnesses (AFFINE-VALUES.md) for a
change to affinity, and the isolation and interchange audits
(COMPILATION-ISOLATION.md, HIR-INTERCHANGE.md) for a change to how the
scalars are declared or printed. `bench/c-abi-types.tcl` regenerates the
compile-cost table.

## Files

| file | what |
|---|---|
| `core/cabi.tcl` | targets, data models, scalar metadata; the `cptr` value; the operations; the test fixture |
| `hir/cabi.tcl` | scalar declarations per target; `Ptr`/`FnPtr` resolution; pointee and signature validation; the not-an-Int check |
| `hir/imprint.tcl` | imprint variables, establishment, binding, substitution, verification |
| `hir/types.tcl` | `{cptr P}`, `{cfnptr F}`, `{imprint T}`; affinity; display |
| `stdlib/ffi/c.bot` | the namespace's module file |
| `native/src/runtime/value.rs`, `ops.rs`, `show.rs`, `nir.rs`, `codegen/clif.rs`, `native/lower.tcl` | the C address word and its ops |
| `tests/c-abi-types.test` | the tests |
| `audit/c-abi-types/tools/` | mutants and fuzzer |
| `bench/c-abi-types.tcl` | compile cost |
