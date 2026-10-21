# Variadics, vertical slice 1

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: a fixed parameter may
> also be a C float (`ffi::c::Float`, class `f32`), which takes a
> floating-point register as a fixed double does: System V's `%al` and
> Apple's v-register padding count it with the doubles (that report's
> section 11). A trailing argument is still never a float.

> A Botlish variadic parameter is a List the caller does not bracket. A C
> variadic call is a call whose signature is its own.

Two things share one marker word.

    fn sum(variadic numbers: List[int]) -> int:
        ...
    sum()          # sum([])
    sum(1, 2, 3)   # sum([1, 2, 3])

    fn inspect(variadic values: List) -> int:    # each call imprints the element
        ...

    extern c fn printf(format: ffi::c::Ptr[ffi::c::Char] read noescape, variadic) -> ffi::c::Int
    printf(cstring("%ld %.1f\n"), c_long(-7), 2.5)

A Botlish variadic function receives an ordinary immutable List. Resolution
collects a call's trailing arguments into one ordinary list construction, so
every analysis and every backend sees an ordinary call. There is no variadic
value, type or runtime representation.

A C variadic call passes each trailing argument as exactly one C ABI type,
promoted as C promotes it. Its machine signature is built for that one call:
x86-64 System V with its `%al` count, Linux AArch64 (AAPCS64), and Apple
AArch64's stack-only 8-byte slots. No Botlish List reaches C. Nothing is
marshalled at run time, and no format string is read.

The binding generator binds every `...` prototype a direct call can reach,
confirmed by the C compiler: 11 Tcl, 5 BoringSSL, 15 SDL3 and 3 Win32 API
names became bindings. A `va_list` stays a fixed parameter that nothing
represents.

## Contents

1. [Starting point](#1-starting-point)
2. [The parameter-section architecture](#2-the-parameter-section-architecture)
3. [Grammar](#3-grammar)
4. [Ordinary binding semantics](#4-ordinary-binding-semantics)
5. [Bare List imprinting](#5-bare-list-imprinting)
6. [Files and subsystems](#6-files-and-subsystems)
7. [HIR and HIRX](#7-hir-and-hirx)
8. [Evaluation and list materialization](#8-evaluation-and-list-materialization)
9. [The C variadic type rule](#9-the-c-variadic-type-rule)
10. [Default argument promotions](#10-default-argument-promotions)
11. [Cranelift: version and variadic capability](#11-cranelift-version-and-variadic-capability)
12. [Linux x86-64](#12-linux-x86-64)
13. [Linux AArch64](#13-linux-aarch64)
14. [Apple AArch64](#14-apple-aarch64)
15. [Integer and floating-point fixture results](#15-integer-and-floating-point-fixture-results)
16. [Pointers and sentinels](#16-pointers-and-sentinels)
17. [GC and coroutines](#17-gc-and-coroutines)
18. [Binding-generator census](#18-binding-generator-census)
19. [Newly supported Tcl declarations](#19-newly-supported-tcl-declarations)
20. [Newly supported Win32 declarations](#20-newly-supported-win32-declarations)
21. [Bindgen goldens and provenance](#21-bindgen-goldens-and-provenance)
22. [Negative diagnostics](#22-negative-diagnostics)
23. [Mutation testing](#23-mutation-testing)
24. [Performance](#24-performance)
25. [macOS GitHub Actions runs](#25-macos-github-actions-runs)
26. [Linux x86-64 regression](#26-linux-x86-64-regression)
27. [Linux AArch64 regression](#27-linux-aarch64-regression)
28. [Remaining limitations](#28-remaining-limitations)
29. [Forwarding and tuples: considerations only](#29-forwarding-and-tuples-considerations-only)
30. [What to run when changing this](#30-what-to-run-when-changing-this)

## 1. Starting point

Before this slice:

* **Botlish had no variadic functions.** Compilerpedia said so in
  concept.functions ("no variadic functions") and in error.arity ("no
  default arguments, optional parameters or variadic parameters"). `variadic`
  was an ordinary name, so `fn f(variadic xs: List[int])` was a syntax
  error.
* **`extern c fn` had no variadic form.** `...`, `..` and a trailing `.`
  were `EXTERN-SYNTAX` errors, and C-FFI.md section 1 said "there is no
  variadic ABI here". MACOS-AARCH64-MILESTONE-6.md (section 30) warned why
  declaring printf or open with a fixed prototype is wrong on Apple
  AArch64: the arguments go in registers while the callee reads the stack.
  It noted that Botlish had no way to declare a function variadic.
* **The binding generator refused every variadic prototype.** It used the
  `variadic` blocker: Tcl 11 API names, BoringSSL 5, SDL3 15, Win32 3, the
  Tcl stubs profile 9, and one in the fixture (`bgf_printf`). It refused
  `va_list` parameters separately (`va-list`: BoringSSL 2, SDL3 7, Win32 6,
  fixture 1). A variadic callback type was `unsupported-callback-signature`.

No test failed at baseline. The behavior was unsupported, not broken: a
variadic declaration could not be written, so no call could be wrong. The
corpus inventory (Gate A) is section 18's census.

## 2. The parameter-section architecture

A parameter list is a sequence of sections in one canonical order
(FLAGS.md, "Section order"). `surface/parser.tcl`'s `ParamSections` reads
one entry at a time, and each entry knows its section: `paramSectionOrder`,
with `EnterSection` refusing an entry that would go back.

Each marker is contextual:

* `flags :NAME` opens the flag section;
* `context NAME: T` opens the context section;
* `resume T` is the coroutine's resume clause.

Every one of these words stays an ordinary name everywhere else. FLAGS.md
already reserved a rank for "a terminal `variadic`". This slice fills it:
`ordinary -> flags -> context -> variadic -> resume`.

Each section has its own diagnostic code. `MALFORMED-FLAG-SECTION` and
`MALFORMED-CONTEXT-SECTION` exist; `MALFORMED-VARIADIC-SECTION` is new.

## 3. Grammar

```
paramList       := ordinary* [flagSection] [contextSection] [variadicSection] [resume]
variadicSection := "variadic" NAME ":" typeExpr       -- typeExpr a List type

externFn        := "extern" "c" "fn" NAME ["named" STRING]
                   "(" [param ("," param)* ["," "variadic"] [","]] ")" "->" resultType [resultFact]
```

**The Botlish section.** `variadic` opens it only when another name follows
it (`VariadicMarker`). `fn f(variadic)` and `fn f(variadic: int)` keep
declaring a parameter named `variadic`, as before. The section holds one
entry, `NAME: List[T]` or a bare `NAME: List`, and it is the last
parameter binding: only a resume clause may follow.

The parser reports, as `MALFORMED-VARIADIC-SECTION` at the offender:

* a second variadic section;
* an ordinary parameter, flag or context after the section;
* an entry without its type;
* a variadic trait requirement.

**The C marker.** In an `extern c fn` it is the bare word, after at least
one fixed parameter, with nothing after it and no name or type of its own
(`ExternVariadicMarker`: `variadic` not followed by `:`). Every misuse is
`EXTERN-SYNTAX`, with a message that names the form to write. C's `...`
stays an error, and its message now gives the spelling: `C's "..." is
written "variadic" in an extern c fn: ...`. No `...` token was added.

## 4. Ordinary binding semantics

`hir/variadic.tcl`'s `Arguments` resolves a call whose callee's interface
says `variadic 1` (hir/flags.tcl: the interface every call resolves
statically, which aliases copy). It keeps the first N arguments, where N is
the interface's ordinary count minus one. It replaces the rest with one
`list(...)` call node, the construction a List literal is, at the call's
origin (node `ID/variadic`), and it records `variadic {fixed N count K}` on
the call.

* Zero trailing arguments collect the empty list.
* Fixed parameters bind first; the List is the last ordinary parameter,
  before the flags. A call writes its trailing arguments before its flags:
  `report(10, 1, 2, :loud)`.
* **Method syntax** works because the receiver is the first argument.
  **Aliases** work because they keep the interface. **Calls from other
  functions, closures and application modules** all collect the same way.
  A method candidate's arity is `>=N` (`hir::resolve::CandidateArity`), so
  arity can settle a variadic candidate beside another module's
  same-named function (`va-method-arity-filter`).
* **A variadic function used as a value** is the ordinary function of its
  List parameter. A value has no statically known declaration to collect
  for, so a call through it passes the List itself: `apply(sum, [1, 2])`.
* **A List written as a trailing argument is one element.** There is no
  spread.
* **Each trailing argument is proven in the element type by its own
  proof** (`DiagnoseElements`, called from `hir::range::VerifyCall`). A List
  literal's static type keeps no element's range, so `[1, 9, 10]` is a
  List[int] that a List[Small] parameter would not admit. `smalls(1, 9, 10)`
  is admitted, and `smalls(1, n)` with an unproven `n` is a TYPE error at
  `n`.
* A variadic function implements no trait requirement and no context-trait
  operation, because those are fixed signatures.

## 5. Bare List imprinting

A bare `List` in the variadic section means `List[T]` for a fresh imprint
variable (`hir::variadic::ElementVariable`): the first of `T`, `T1`, ...
that is no word of the signature, no enclosing function's variable and no
visible type (`va-bare-list-fresh-variable`). It never means `List[any]`.

From there the existing imprint machinery (hir/imprint.tcl) takes over:

* The collected List establishes the variable. `inspect(1, 2)` is
  List[int], and `inspect("x")` is List[str].
* Heterogeneous arguments imprint their least upper bound, exactly as the
  same List literal does. No positional type is kept.
* An empty call collects List[never], the empty collection's own type
  (M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-SEMANTICS.md).
* An explicit imprint names the element: `inspect[int]()`.
* An imprinted callable is no value (`IMPRINT`), so `g = [inspect]` is
  rejected.

## 6. Files and subsystems

Production code (`git diff --stat` against the branch's base, tests and
generated output excluded) is 28 files, +1,264 / -96. That count includes
the Rust unit tests that live beside the code (`clif.rs`'s test modules,
about 200 lines).

| subsystem | files |
|---|---|
| grammar, AST, lowering, loader | surface/parser.tcl (`ParamSections`, `VariadicMarker`, `VariadicEntry`, `ExternDecl`, `ExternVariadicMarker`), surface/ast.tcl, surface/lower.tcl, surface/modules.tcl |
| HIR syntax and resolution | hir/syntax.tcl (`withVariadic`), hir/variadic.tcl (new), hir/flags.tcl, hir/resolve.tcl, hir/hir.tcl |
| proofs and checks | hir/range.tcl, hir/traits.tcl, hir/contexts.tcl, hir/warnings.tcl |
| HIR text | hir/format.tcl, hir/read.tcl |
| the C type rule | hir/cabi.tcl (`VariadicArgument`), core/cabi.tcl (`promoted`, `promotedBool`, the `variadic` contract key), hir/borrow.tcl (`cvarargs`, arity, refusals), hir/direct.tcl, hir/foreign.tcl |
| native lowering and NIR | native/lower.tcl (`variadic=1`, `varargs=`), native/src/nir.rs (`VarArg`, validation) |
| code generation | native/src/codegen/clif.rs (`c_call_signature`, `vararg_value`, `va_stub`, `va_stub_code`, the per-call import) |
| binding generator | tools/c-bindgen/model.tcl, probe.tcl (`prototypes`), emit.tcl, generate.tcl, report.tcl |

Tests and audit tools:

* tests/variadics.test (58 tests, new);
* tests/c-ffi.test's `cf-va-*` (27, new), with tests/cffi/fixture.c
  extended by genuine stdarg callees and machine-state capture;
* tests/c-bindgen.test (4 new tests, updated counts);
* tests/golden/variadics.bot (26 golden tests, new);
* audit/variadics/tools/ (a fuzzer and mutants, new);
* the C FFI and bindgen fuzzers, extended;
* 23 C FFI and 11 bindgen mutants, new;
* bench/variadics.tcl, new; bench/c-ffi.tcl, three rows added.

## 7. HIR and HIRX

HIR records three facts. Each is printed in HIR text and read back:

| where | field | text |
|---|---|---|
| a variadic function's block | `variadic N`: parameter N (its last ordinary one) is the List | ` variadic N` on the block line |
| a resolved variadic call | `variadic {fixed N count K}` | ` variadic FIXED COUNT` on the call head |
| a variadic `extern c fn`'s registry entry | contract and ABI `variadic 1`, the native of arity `*` | the foreign table's declaration (`hir::foreign`) |
| a variadic C call | `cvarargs`: per trailing argument `{c SPELLING class CLASS promoted P}` | (HIR's dict, the interchange) |

HIR interchange holds the HIR dict itself (HIR-INTERCHANGE.md), so all four
travel unchanged. `va-interchange` checks that the call facts and the values
of a decoded HIR equal the built one's on all four backends.
`cf-va-interchange` checks the same for a variadic C call: the declaration,
`cvarargs`, and the run.

Target identity is the existing rule. A variadic C program's HIR records its
target (it imports ffi::c), decoding refuses another target's text
(`cf-va-target-identity`), and the cache keys it by the full target
(`cf-va-cache`).

The interchange code has nothing variadic-specific to mutate: the dict is
the representation. Losing the facts in HIR text is mutated and killed
(section 23); losing the foreign table in interchange is the existing
`interchange-loses-foreign`.

## 8. Evaluation and list materialization

The collected List is the call's last argument, an ordinary `list(...)`
call. Arguments are evaluated once, in written order: the fixed ones, then
the trailing ones in order, then the List. An argument that fails ends the
call: earlier arguments ran once, later ones never (`va-evaluation-order`,
`va-evaluation-errors`, through an installed context's log).

Natively, the List is the backends' ordinary construction (`listnew`,
`va-native-specialized`). Its elements are owned like any List's, so
Strings, Lists and structs built in the arguments outlive the call
(`va-references-retained`). There is no new runtime function, allocation
path or ownership rule.

For a C call, the trailing arguments are evaluated in the same order and
passed directly. No List is built: `cvarargs` is a compile-time list of
how each operand is passed.

## 9. The C variadic type rule

`hir::cabi::VariadicArgument` gives each trailing argument exactly one C
type, from its static type:

| Botlish type | C type, class |
|---|---|
| a C integer scalar (`ffi::c::Int`, `ffi::c::ULong`, ...: an integer domain registered with `cabi` metadata) | that scalar, its class from the target's table |
| `bool` (`ffi::c::Bool`) | `_Bool`, class `bool` |
| `Float64` (`ffi::c::Double`) | `double`, class `f64` |
| `ffi::c::Ptr[T]`, `ffi::c::FnPtr[...]` | the pointer, class `ptr` |

Everything else is refused at the argument, in hir/borrow.tcl's `Problems`.
The refusal also sets `borrowRefused`, so a `-strict 0` build fails the call
(`cf-va-strict0-replay`):

* **A plain `int`, or a refinement of int with no C evidence**, is `TYPE`
  with "a Botlish integer, not a C type". A value that fits a C integer's
  range does not say whether the callee reads an int, a long or a long
  long. A literal goes through a converter, `fn c_long(n: ffi::c::Long) ->
  ffi::c::Long`, or comes from a declared parameter or a C result.
* **A value proven two C scalars at once** is `TYPE` with "its C type is
  ambiguous" (`cf-va-ambiguous-type`).
* **A String, a List, a struct or an erased (`any`) value** is `TYPE` with
  "not a C ABI value type".
* **Byte storage** is `FOREIGN-BORROW`. A trailing argument has no contract
  (no access, no escape), and byte storage reaches C only through a pointer
  parameter whose contract admits it.

**A trailing pointer** is accepted. It has no contract, so its escape is
unknown and the call is a direct edge (hir/direct.tcl: "argument N: a
pointer passed as a trailing argument, whose escape no contract states",
`cf-va-direct`). A call whose trailing arguments are scalars stays an
ordinary call.

**The Tcl backends** refuse a variadic C call at run time with
`NATIVE-ONLY`, as they refuse every C call (`cf-va-tcl-backends`).

## 10. Default argument promotions

`core::cabi::promoted` implements C11 6.5.2.2p6-7 for the compilation's
target table, never from a name:

* an integer narrower than the target's `int` is promoted to `int` (signed,
  since int holds every value of the narrower type: `unsigned short` too);
* `_Bool` is promoted to `int` (`promotedBool`);
* every integer at least as wide keeps its own class (`long` is i64 on
  LP64, i32 on LLP64);
* `double` stays `f64`, and a pointer stays `ptr`.

`cf-va-promotions-follow-the-target` checks every scalar on every target of
the table, LLP64's `long` included.

The NIR reader re-validates every `CLASS:PROMOTED` pair (nir.rs's
`VarArg::parse`). A pair is valid only when it is a promotion C performs, so
a front-end slip is a backend error, never a miscompiled call.

## 11. Cranelift: version and variadic capability

The pin is `cranelift-* 0.135` (Cargo.lock: cranelift-codegen 0.135.2),
unchanged.

1. **Does Cranelift represent the variadic boundary in foreign
   signatures?** No. `Signature` and `AbiParam` have no variadic marker in
   0.135.2, nor in 0.136.0 or 0.137.0-rc.1. Every parameter is placed as a
   named one.
2. **Does it support C variadic calls on the three targets?** Not as such.
   On System V (x86-64 and Linux AArch64) a variadic call places its
   trailing arguments exactly as named arguments of their promoted types,
   so a per-call signature is correct by construction, except for `%al`.
   On Apple AArch64 it is not.
3. **macOS AArch64:** with `CallConv::AppleAarch64`, a signature places
   every parameter by the named-argument rules (registers first).
   `AppleAarch64` does not make a call variadic. Section 14 has the
   technique used.
4. **Linux AArch64:** AAPCS64 passes variadic arguments as named ones.
   Cranelift's SystemV placement of the per-call signature is correct.
5. **Linux x86-64:** the per-call signature places integers and doubles
   correctly. Nothing sets `%al`: Cranelift cannot give a value a fixed
   register at a call, and `rax` is no System V argument register, so no
   ABI parameter can ever land in it.
6. **Does the pin need a local call-lowering adaptation?** Only for `%al`:
   a two-instruction stub (section 12). Apple's rule is expressed with
   ordinary signature parameters.
7. **Can it be expressed through supported APIs?** Yes. The signature is
   built with `Signature`/`AbiParam`, the import with `import_signature`,
   `declare_imported_user_function` and `import_function`. The stub's bytes
   go through `Module::define_function_bytes` with a `ModuleReloc`. No
   Cranelift patch was made, and no private API is used.
8. **Do mixed integers and doubles reveal deficiencies?** Not in the
   variadic lowering:
   * Integer and floating-point registers are counted per kind, as for
     fixed calls (`cf-abi-doubles-before-integers`).
   * Milestone 6's Apple narrow stack-store defect concerns extended
     narrow parameters: 0.135.2 stores an extended stack argument at
     register width. Every Apple trailing argument is an I64 or F64 of its
     own 8-byte slot, with no extension attribute, so it cannot arise.
   * The existing workaround for fixed parameters (`c_extended_parameters`)
     and its upgrade-detection test
     (`ffi_apple_extended_stack_argument_defect_still_present`) are
     unchanged.

The per-call signature is `c_call_signature`. The fixed parameters keep
`c_signature`'s placement and extension attributes. Trailing values are
appended as their promoted type (I32/I64/F64; on Apple, I64/F64), with no
extension attribute: C reads a promoted `int` as 32 bits. Every call gets
its own import of the C symbol, so two calls of one function may pass
different counts and types.

## 12. Linux x86-64

**%al.** System V requires the caller of a variadic function to state, in
`%al`, an upper bound of the vector registers it used (0 to 8). Botlish
states it exactly: the call's F64 parameter count, fixed ones included,
capped at 8 (`vector_registers`).

**The stub.** Cranelift cannot place `%al`, so a variadic call on x86-64
System V calls a stub instead of the C function. The stub is defined once
per (function, count) pair as `botlish_va_{FOREIGN}_{AL}` (a local symbol)
and is two instructions:

    b8 AL 00 00 00        mov $AL, %eax
    e9 rel32              jmp SYMBOL@PLT     (R_X86_64_PLT32, addend -4: a C compiler's tail call)

The JIT form, which places code independently of the symbols it binds, is
`movabs $SYMBOL, %r11; jmp *%r11`. The JIT never runs a C call, because a
program that calls C runs linked (C-FFI.md, section 12). It compiles one
only for its code: CLIF listings and sizes.

The stub touches nothing else:

* every argument register and the stack (the return address, the stack
  arguments) are exactly as the call left them;
* `rax` is no argument register;
* `r11` is the convention's scratch register.

The C function returns directly to the stub's caller. The CLIF listing
names the stub "%al=N stub of C NAME" (`cf-va-clif`). AGENTS.md records the
stub as the one register Botlish places itself.

**Evidence.** The fixture's `bcf_vcapture` and `bcf_vcapture_d` are
assembly entry points that record the machine state a call arrives in, then
return:

* rdi..r9;
* `rax`, whose low byte is `%al`;
* xmm0-7;
* 128 bytes of the caller's stack arguments.

`cf-va-abi-{none,small,ints,mixed,fixedd}` compare, value by value, three
records of the same call:

* the model's, from the psABI document (in the test, never from core::cabi
  or the compiler);
* Botlish's, on both native backends;
* GCC's, the C reference caller's (a volatile function pointer, so the
  compiler emits a true variadic call).

They agree on every scenario, `%al` included: 0 (no trailing argument), 1
(one double), 0 (twelve trailing ints after the fixed one, seven on the
stack), 8 (nine doubles among
integers and pointers, the ninth on the stack), and 3 (a fixed double and
two trailing ones).

Value-level oracles are genuine `va_arg` implementations:

* `bcf_vrecord` reads trailing arguments by a nibble-coded type list, up
  to 30;
* `bcf_vsum` takes ints, `bcf_vscale` doubles after a fixed double, and
  `bcf_vsentinel` a NULL-terminated pointer list.

GCC's prologue saves xmm0-7 for `va_arg` only when `%al` is nonzero, so a
wrong `%al` loses the doubles. The `va-al-omitted` and `va-al-zero` mutants
are killed this way, by the value tests and the fuzzer as well as the
capture.

## 13. Linux AArch64

AAPCS64 passes variadic arguments as named ones: integers in x0-x7, doubles
in v0-v7, then 8-byte stack slots. The per-call SystemV signature is
therefore the whole lowering. Botlish adds no padding and no stub, and does
not import Apple's rule.

* **Unit evidence** (`ffi_linux_aarch64_variadic_arguments_in_registers`,
  a disassembly of a call for `aarch64-unknown-linux-gnu`): after one fixed
  int, a trailing int is in w1, a double in d0 and a long in x2, with no
  stack store. Nine trailing ints take x1-x7, then sp+0 and sp+8.
  It passes on aarch64 under qemu-user here, and in CI's arm64 workflow
  natively (section 27).
* **Runtime evidence:** the same `cf-va-*` tests, value tests and capture
  scenarios run on Linux AArch64 with the aarch64 capture entry. The model
  is AAPCS64's: x0-x7, v0-v7, the stack.

## 14. Apple AArch64

Apple's convention ("Writing ARM64 code for Apple platforms") passes every
anonymous argument on the stack, each in its own 8-byte slot, even when an
x or v register is free. Fixed arguments keep their normal placement.

`c_call_signature` states this with ordinary signature parameters, the
technique rustc_codegen_cranelift uses, re-derived here:

* **The padding.** After the fixed parameters, the call adds synthetic
  zero parameters:
  * I64 ones for every x register the fixed ones left free, when any
    trailing argument is integer-class;
  * F64 ones for every v register the fixed ones left free, when any
    trailing argument is a double.

  The two kinds are counted apart: a fixed double uses a v register, not
  an x register (`ffi_apple_variadic_padding_per_kind`). They are internal
  to the lowering: no Botlish argument, never in NIR.
* **Trailing values** follow the padding as I64 (an integer-class value,
  sign- or zero-extended to its 8-byte slot) or F64. Apple's placement of a
  stack parameter is its natural size, so every one takes exactly an 8-byte
  slot, starting at the first stack argument offset.
* **Fixed parameters past x7**, already on the stack, keep their own
  placement (Milestone 6's rule, unchanged). The trailing arguments follow
  them.
* **Alignment** is the convention's own: every slot is 8 bytes.
* **Frames and GC roots** are unchanged. The padding are ordinary
  arguments of a call: no root, no new frame shape.

**Unit evidence** (aarch64 hosts; run under qemu-user here, and on macOS
CI): `ffi_apple_variadic_arguments_on_the_stack` disassembles a call with
one fixed int and a trailing int, double and long:

* the trailing values are stored to [sp], [sp, #8] and [sp, #16] (`str x`,
  `str d`, `str x`), the int as a whole 64-bit word;
* the fixed int is sign-extended into x0;
* x1-x6 and v0-v6 hold the padding;
* no trailing double is in v0.

**Runtime evidence:** on macOS the `cf-va-*` value tests and capture
scenarios run with Apple clang's C reference caller. The model is "stack,
8-byte slots" for every anonymous argument. Section 25 has the runs.

## 15. Integer and floating-point fixture results

`tests/cffi/fixture.c` gained genuine stdarg callees (section 12). The C FFI
fixture is extended, not replaced. Results on Linux x86-64 (local; CI on all
three hosts, sections 25-27):

| test | what | result |
|---|---|---|
| cf-va-values | 30 trailing arguments of every C integer type, `_Bool`, doubles and pointers, read back by `va_arg` of each promoted type | equal on both native backends |
| cf-va-arities | 0 to 40 trailing arguments | equal |
| cf-va-position-types | each value in each trailing position and type | equal |
| cf-va-doubles | doubles past the eight vector registers, among integers | equal |
| cf-va-abi-* | machine state against the psABI model and GCC's call (section 12) | equal, `%al` included |
| cf-va-clif | the per-call signature and the host's stub | as stated per convention |

The C FFI fuzzer (audit/c-ffi/tools/fuzz.tcl) now draws variadic functions
too. Each takes one to fourteen fixed parameters, va_start's never
narrower than int, and its one call passes 0 to 18 trailing arguments:
every integer type, `_Bool`, doubles (checked by bit pattern) and raw
pointers. Seeds 1-4 (6 programs each): 87 variadic functions, 468 trailing
arguments, no disagreement.

A fixed parameter may also be a C double (`ffi::c::Double`, recorded by
bit pattern), which every function can draw, variadic or not. The variadic
conventions count the floating-point registers a call's fixed doubles take
apart from the integer ones (the `%al` count, AAPCS64's v registers,
Apple's padding). The fuzzer drew no such parameter until the macOS
mutant run showed what that missed (section 25). Seeds 1-4 with it (10
programs each, x86-64): 146 variadic functions, 588 trailing arguments, no
disagreement.

## 16. Pointers and sentinels

* `bcf_vsentinel(tag, p1, p2, ..., NULL)` counts the pointers before the
  first NULL, the shape Tcl_AppendResult has (`cf-va-sentinel`).
* `bcf_vaddress` and `bcf_vaddress_bits` check that a trailing pointer
  arrives as the full 64-bit address. `va-pointer-truncated` (section 23)
  is killed by them.
* `ffi::c::null[T]()` is a valid trailing argument.
* A `FnPtr` is accepted as class `ptr`.
* A pointer makes the call direct (section 9).

## 17. GC and coroutines

**Botlish side.** `va-gc-stress` runs under `BOTLISH_NATIVE_GC_STRESS=1` on
both native backends. It builds forty Lists of Strings in variadic
arguments and keeps every one live while the next forty are allocated. `va-coroutine` and
`va-coroutine-calls` cover a variadic generator over its List and variadic
calls inside a coroutine body. The fuzzer takes `-gc-stress 1`.

**C side.** `cf-va-executable-gc-coroutine` makes variadic C calls with
managed values live:

* in a standalone executable;
* under GC stress;
* inside a coroutine before and after a yield.

Its calls have stack-argument areas: nine trailing ints, past x86-64's six
integer registers, and nine trailing doubles, past the eight vector
registers.

The stack guard and native errors are unchanged. The stub adds no frame:
`jmp`, not `call`, so stack walking never sees it.

## 18. Binding-generator census

The generator (tools/c-bindgen/) now binds every `...` prototype a direct
call can reach (C-BINDGEN.md, section 38):

* **The prototype.** Its variadic flag is the header parser's (the
  declarator's `...`). The C compiler confirms it: the prototype probe
  compiles `_Static_assert(__builtin_types_compatible_p(__typeof__(NAME),
  RENDERED))` for each one, so a `va_list` read as `...`, a `...` lost or a
  misread fixed parameter is `prototype-mismatch`, never a binding.
* **What stays unsupported.** A variadic function only a C thunk could call
  (static inline, macro-shadowed, a stub-table redirection) stays
  `variadic`: C cannot forward `...`. So does one with no fixed parameter.
* **`va_list`** stays `va-list`, a fixed parameter of a type nothing
  represents.
* **A variadic callback type** stays `unsupported-callback-signature`.

linux-x86_64; the other targets of each profile are the same:

| profile | variadic API names | bound | still unsupported |
|---|---:|---|---|
| tcl | 11 | 9 direct, 2 aliases | -- |
| tclstubs | 9 | -- | 9 (`variadic`: stub-table redirections, thunk-only) |
| boringssl | 5 (+2 `va_list`) | 5 direct | 2 `va-list` |
| sdl3 | 15 (+7 `va_list`) | 15 direct | 7 `va-list` |
| win32 (windows-x86_64-gnu) | 3 (+6 `va_list`) | 2 direct, 1 alias | 6 `va-list` |
| fixture | 3 + 1 alias (+1 `va_list`) | 3 | `bgf_vshadow` (thunk-only), `bgf_vprintf` (`va-list`) |

There are no variadic function-pointer typedefs in the bound corpus outside
Tcl's `Tcl_PanicProc` (C-ABI-TYPES.md), which stays unsupported.

**Coverage moved** (bound API names):

| profile | before | after |
|---|---|---|
| Tcl | 820 (89.8%) | 831 (91.0%) |
| BoringSSL | 3,977 (96.6%) | 3,982 (96.7%) |
| SDL3 | 1,102 (78.4%) | 1,117 (79.5%) |
| Win32 | 3,295 (87.8%) | 3,298 (87.9%) |

No nonvariadic output changed: every regenerated diff is the variadic rows,
their declarations, and the counts and percentages they move.

## 19. Newly supported Tcl declarations

| name | binding |
|---|---|
| Tcl_Panic | `extern c fn Tcl_Panic(format: ffi::c::Ptr[ffi::c::Char], variadic) -> unit` |
| Tcl_AppendResult | `(interp: ffi::c::Ptr[tcl::ctypes::Tcl_Interp], variadic) -> unit` |
| Tcl_AppendStringsToObj | `(objPtr: ffi::c::Ptr[tcl::ctypes::Tcl_Obj], variadic) -> unit` |
| Tcl_SetErrorCode | `(interp, variadic) -> unit` |
| Tcl_VarEval | `(interp, variadic) -> ffi::c::Int` |
| Tcl_ObjPrintf | `(format, variadic) -> ffi::c::Ptr[tcl::ctypes::Tcl_Obj]` |
| Tcl_AppendPrintfToObj | `(objPtr, format, variadic) -> unit` |
| TclBN_mp_init_multi, TclBN_mp_clear_multi | `(a: ffi::c::Ptr[tcl::ctypes::mp_int], variadic)` |
| mp_init_multi, mp_clear_multi | aliases, `named "TclBN_mp_init_multi"` / `"TclBN_mp_clear_multi"` |

**Runtime validation** (`cb-tcl-variadic`, libtcl9.0 as installed): the
generated `Tcl_AppendResult` appends a NULL-terminated list of strings to
an interpreter's result, on both native backends. A C program making the
same calls through the header gives the same result, `{[8, 18]}` on each.
The declarations themselves are checked against the C prototype by the
probe (section 18), not against a hand-written string.

## 20. Newly supported Win32 declarations

| name | binding |
|---|---|
| wsprintfA | `extern c fn wsprintfA(arg1: ffi::c::Ptr[ffi::c::Char], arg2: ffi::c::Ptr[ffi::c::Char], variadic) -> ffi::c::Int` |
| wsprintfW | `(arg1: ffi::c::Ptr[ffi::c::UShort], arg2: ffi::c::Ptr[ffi::c::UShort], variadic) -> ffi::c::Int` |
| wsprintf | `extern c fn wsprintf named "wsprintfW"(..., variadic) -> ffi::c::Int` (the UNICODE alias) |

Still unsupported: `FormatMessage(A/W)` (an `Arguments` parameter of type
`va_list *`) and `wvsprintf(A/W)` (a `va_list`).

**Validation is static.** The prototype probe, compiled for
windows-x86_64-gnu against MinGW-w64's headers, confirms each prototype at
generation. Nothing in this repository runs a Windows
binary, and calling `wsprintf` with an uncontrolled buffer only to show it
works was excluded by the brief. The fixture's alias `bgf_print` (`#define
bgf_print bgf_printf`, the shape of `wsprintf`) is called at run time
instead (`cb-fixture-run`).

## 21. Bindgen goldens and provenance

* `tools/c-bindgen.tcl check PROFILE -target committed` is current for
  every profile and target: fixture on 4 targets, tcl on 2, tclstubs,
  boringssl on 2, sdl3 on 2, win32.
* Generation is deterministic (`cb-fixture-deterministic`).
* tests/c-bindgen.test passes: 81 tests, 6 skipped (the BoringSSL and SDL3
  library constraints).
* The fixture's demo (`demo.bot` against `caller.c`) gained two variadic
  calls, `bgf_printf` and its alias `bgf_print`. They pass on both native
  backends.
* The bindgen fuzzer draws variadic prototypes with genuine stdarg bodies,
  plus `va_list` and thunk-only variadic refusals. Seeds 1, 7 and 23 (10
  programs each): 34 variadic prototypes, 139 trailing arguments, no
  disagreement.

## 22. Negative diagnostics

Every one is pinned with its location in tests/variadics.test or
tests/c-ffi.test, and the semantic ones also in tests/golden/variadics.bot.

| diagnostic | example |
|---|---|
| `MALFORMED-VARIADIC-SECTION` | a second section; a parameter, flag or context after it; `variadic a` without its type; a variadic trait requirement |
| `TYPE` at the declaration | `variadic xs: int`: "a variadic parameter is bound to the List of the call's trailing arguments: declare it List[ELEMENT] (or a bare List ...)" |
| `ARITY` | `weighted()`: "function weighted takes 1 fixed argument(s) before its variadic parameter, got 0 argument(s)" (with the flags named when there are any) |
| `TYPE` at a trailing argument | "argument 2 of weighted cannot be proven to satisfy int, the element type of its variadic parameter "numbers" (argument type: str)"; an unproven domain element likewise, with its facts |
| `IMPRINT` | an imprinted variadic function as a value; `inspect[int, str]()` |
| trait conformance | "f is variadic: a trait requirement is a fixed signature, and a variadic function is no implementation of one" |
| `EXTERN-SYNTAX` | no fixed parameter before `variadic`; anything after it; a name or type on it; C's `...` |
| `TYPE` (C) | a plain Int, a String, a List, a struct, an erased value; an ambiguous C type |
| `FOREIGN-BORROW` (C) | byte storage as a trailing argument |
| `ARITY` (C) | fewer than the fixed parameters |
| `DIRECT` (C) | a trailing pointer in a module that is not `direct module` |

Compilerpedia documents `MALFORMED-VARIADIC-SECTION`
(error.malformed-variadic-section, with a rejected example) and the
concept (concept.variadics, with a printf example run natively). It also
corrects the topics that said there were none: concept.functions,
error.arity, error.extern-syntax and concept.c-ffi.
`tools/compilerpedia.tcl check` passes. The static-compile census lists
`MALFORMED-VARIADIC-SECTION` as a parser kind, which no `static compile:`
block can produce.

## 23. Mutation testing

The campaign extends the existing harnesses:

* audit/c-ffi/tools/mutate.tcl and audit/c-bindgen/tools/mutate.tcl;
* a new audit/variadics/tools/mutate.tcl in the same format, for the
  ordinary side;
* for the AArch64-only mutants, the same edits run through a qemu-user
  cross build of the Rust unit tests here, and through tier.tcl's
  `c-ffi-mutants` on macOS (section 25).

Every mutant applies and is killed by a test failure, not an unrelated
build failure. Two kills, noted below, are by the NIR's own consistency
check.

**Ordinary variadics (22, audit/variadics/tools/mutants.txt).** All are
killed by tests/variadics.test:

* first trailing argument dropped;
* trailing arguments reversed;
* fixed count including the List;
* a single trailing argument passed as a scalar;
* the first trailing argument evaluated twice;
* no List for an empty call;
* arity not diagnosed;
* a non-List declaration accepted;
* trailing elements unproven;
* the element proof bypassed (List-literal admission);
* the interface not variadic;
* a bare List as `List[any]`;
* a method candidate of fixed arity (killed by `va-method-arity-filter`;
  it was the first survivor, see below);
* the lowering dropping the marker;
* a second section accepted;
* a parameter after the section accepted;
* HIR text dropping or ignoring the declaration and call marks (4);
* a trait implementation accepted;
* METHOD-ELIGIBLE reading the collected List.

**C variadics (23, `va-*` in audit/c-ffi/tools/mutants.txt).**

* Front end (12, all hosts): `extern c fn f(variadic)` accepted; a
  parameter after the marker; the registration dropping `variadic`; a
  plain Int admitted; an ambiguous scalar taking the first; byte storage as
  a plain TYPE (the `-strict 0` replay then misses it); no promotion
  (killed by the NIR's validation of the promotion pair); unsigned short
  promoted to unsigned int; the fixed arity unchecked; a trailing pointer
  not direct; trailing classes reversed; the last fixed argument taken for
  a trailing one (the NIR's operand-count check).
* x86-64 (5): `%al` omitted; `%al` always 0; the stub's PLT addend dropped
  (killed by the executable capture tests); the JIT stub's address one
  byte late; a trailing pointer truncated to 32 bits.
* AArch64 (6): Apple trailing arguments in registers; Apple integer
  padding skipped when no double trails; Apple narrow (4-byte) slots; a
  fixed double counted as an integer register; the fixed doubles ignored
  in the v padding; Linux AArch64 laid out as Apple's. Under qemu-user each
  is killed by `ffi_apple_variadic_*` or
  `ffi_linux_aarch64_variadic_arguments_in_registers`, and on macOS also by
  the runtime tests.

**Binding generator (11, `variadic-*`/`va-list-*` in
audit/c-bindgen/tools/mutants.txt).** Each is killed by a test of behavior
or the fuzzer, never only by the pinned comparison:

* the marker never emitted;
* the flag lost;
* a thunk forwarding `...`;
* no fixed parameter bound;
* the probe's answer ignored;
* the probe vacuous;
* the probe never asked;
* a variadic callback mapped;
* a `va_list` read as `...`;
* the marker spelled `...`;
* a variadic declaration's `named` dropped (killed by the new alias
  `bgf_print`'s run).

**Survivors found and closed:**

* `method-candidate-fixed-arity` passed every test: the filter's outcome
  was correct by trial builds either way. `va-method-arity-filter` now pins
  that arity settles the call (no `methodCalls` entry).
* `second-section-accepted`, first written to bypass one of two
  equivalent checks, was an equivalent mutant. It was rewritten to remove
  both.
* `va-stub-jit-jump-misplaced` survived the C FFI tests, because the JIT
  never runs a C call. The stub's encoding is now a pure function
  (`va_stub_code`), and `ffi_sysv_variadic_stub_relocations` pins that each
  form's relocation patches its jump's operand.

**Inapplicable mutants from the brief:**

* "Lose the marker during HIRX round-trip": interchange has no
  variadic-specific code, because the HIR dict is the representation
  (section 7).
* "Misclassify a variadic parameter as fixed": the C-side cases are
  `va-declaration-not-variadic` and `va-last-fixed-as-trailing`.

## 24. Performance

`bench/variadics.tcl` (ordinary calls) and `bench/c-ffi.tcl`'s `va` rows (C
calls), run with their defaults (best of 5 runs of 1,000,000 iterations) on a
4-core Linux x86-64 container, 2026-10-20, with nothing else running.
Differences of about 10 ns are within the loop's noise: the same loop alone
measured 37 to 51 ns across the C rows.

**Ordinary variadics** (cranelift, specialized; ns per call over the loop
alone, 48.4 ns per iteration):

| call | variadic | explicit List | fixed |
|---|---:|---:|---:|
| 0 trailing (`first()` / `first_list([])`, a length) | 61.7 | 51.3 | -- |
| 1 trailing (a length) | 90.0 | 103.1 | -- |
| 3 trailing (`sum(i, 1, 2)` / `sum_list([i, 1, 2])`) | 106.6 | 104.2 | -2.7 (`add3`) |
| 8 trailing (a sum) | 152.9 | 143.1 | -- |

The Tcl backends, us per iteration of the 3-trailing call:

| backend | variadic | explicit List |
|---|---:|---:|
| interp | 1,291 | 1,324 |
| compile | 54.5 | 52.8 |

200 call sites, ms: front end 561.6 (variadic) vs 582.7 (explicit List);
native lowering 246.2 vs 273.1.

A variadic call costs what the same call given the List literal costs,
within noise in both directions, because it is that call. The List
construction is the whole overhead over a fixed-arity function (`add3` is
lost in the loop), and it is the List the body receives. The collection is
one node per call, so compile cost is the explicit List program's.

**C variadic calls** (ns per call over the loop alone):

| call | ns |
|---|---:|
| `add(a, b)`, fixed, two ints | 4.9 |
| `vsum(2, a, a)`, variadic, two trailing ints (+ the %al stub, + C's `va_arg` loop) | 9.7 |
| `stack_tail(12 args)`, fixed, six on the stack | 5.2 |
| `vsum(11, ...)`, 11 trailing ints, six on the stack | 10.8 |
| `vscale(1.0, 4, 4 doubles)`, %al = 5, a Float64 result allocated | 40.1 |
| (for comparison: `big`, a fixed call whose u64 result is boxed) | 41.9 |

A variadic C call costs about 5 ns more than a fixed one of the same
arguments. That is the stub's `mov` and direct `jmp`, plus the callee's own
`va_arg` loop, which the fixed callee does not run. A stack spill adds
nothing measurable. The double row is dominated by allocating its Float64
result, as `big`'s boxed result is: the call itself is in the same few
nanoseconds. The numbers are measured in one
linked executable per program (`native::measure`), compilation and linking
excluded. Apple's padding costs one register move per padded register.
On macOS (section 25) that cost does not show: a variadic call with two or
eleven trailing arguments costs what a fixed call with as many stack
arguments costs.

## 25. macOS GitHub Actions runs

`.github/workflows/macos-arm64.yml` on macos-15 (Apple Silicon), Apple
clang 17. The shared development Mac was not used.

* [Run 39470112845](https://github.com/mwagner-webdev/botlish/actions/runs/39470112845) (`6b291a9`) ran the push's Tier C:
  `variadics.test`, `c-ffi.test`, `c-bindgen.test`, the golden suite on all
  four backends and the C FFI fuzzer, all under GC stress.
  * Everything passed except `cf-va-abi-mixed`:
    * every `cf-va-*` value test;
    * the Apple CLIF signature, `cf-va-clif`;
    * the other four capture scenarios;
    * the fuzzer, 111 variadic functions with 545 trailing arguments, no
      disagreement.
  * `cf-va-abi-mixed` failed in the harness, not in the ABI. Apple put its
    eighteen trailing arguments, 144 bytes, on the stack as the model
    says, and the fixture captured only 128.
  * The capture now keeps 256 bytes (`3781794`).
  * Its smoke job (Tier A, with the native Rust unit tests: the Apple
    placement tests on a real Apple host) and acceptance shard 1 passed.
    Shard 2 was cancelled by the next push.
* [Run 39482548143](https://github.com/mwagner-webdev/botlish/actions/runs/39482548143) (`3781794`), the final code:
  * smoke passed;
  * acceptance shards 1 and 2 passed: every Tcl test file on interp and
    compile, `c-ffi.test` with all five capture scenarios against Apple
    clang's own calls included, and every golden suite on four backends;
  * Tier C ran `c-ffi.test` and `variadics.test` on interp and compile
    (170 tests, 166 passed, 4 skipped, 0 failed), the C FFI's `va-*`
    mutants and `bench/c-ffi.tcl`.

**The mutants on macOS.** 23 mutants, 18 killed, 0 survived, 5 skipped:
the four x86-64 ones (`va-al-omitted`, `va-al-zero`,
`va-stub-jit-jump-misplaced`, `va-stub-plt-addend-dropped`) and
`va-linux-aarch64-is-apples`, which only a Linux AArch64 host can run.
Of the 18, the twelve front-end mutants and `va-pointer-truncated` are the
same mutants Linux kills, killed again on an Apple host. The five Apple
mutants are new evidence. Each fails at least one capture scenario
(`cf-va-abi-*`, which compares the machine state at the callee with Apple
clang's own call) and the Rust `apple_tests`:

| mutant | `c-ffi.test` | fuzzer | Rust |
|---|---|---|---|
| `va-apple-trailing-in-registers` | 13 failed (`cf-va-abi-fixedd`, `-ints`, `-mixed`, `-small`, `cf-va-arities`, ...) | killed | 2 failed |
| `va-apple-integer-padding-skipped` | 7 failed (`cf-va-abi-ints`, `cf-va-arities`, `cf-va-executable-gc-coroutine`, ...) | killed | 1 failed |
| `va-apple-narrow-slots` | 7 failed (`cf-va-abi-ints`, `cf-va-arities`, `cf-va-clif`, ...) | killed | 1 failed |
| `va-apple-doubles-counted-as-integers` | 1 failed (`cf-va-abi-fixedd`) | survived, then killed | 1 failed |
| `va-apple-double-registers-miscounted` | 3 failed (`cf-va-abi-fixedd`, `cf-va-doubles`, `cf-va-interchange`) | survived, then killed | 1 failed |

In that run, the fuzzer missed the two mutants that miscount fixed doubles
because it drew no fixed C double parameter. Only the `fixedd` capture
scenario and `ffi_apple_variadic_padding_per_kind` held that rule, the
thinnest coverage in this slice. The fuzzer now draws fixed doubles
(section 15), and the next run killed both with it:

* [Run 39502715587](https://github.com/mwagner-webdev/botlish/actions/runs/39502715587) (`aa4356c`, the fuzzer with fixed doubles):
  * Tier C ran the C FFI fuzzer, seeds 1 and 2 and seed 9 under GC
    stress: 108 variadic functions, 461 trailing arguments, no
    disagreement;
  * it then ran the five Apple mutants against the tests, the extended
    fuzzer and the Rust tests: 5 killed. The fuzzer now kills every one,
    `va-apple-doubles-counted-as-integers` and
    `va-apple-double-registers-miscounted` included (1 disagreement in
    6 programs each). The other three kill counts are as before or higher
    (`va-apple-narrow-slots` 5 programs, before 4);
  * smoke and acceptance shards 1 and 2 passed (shard 2: 100 Tcl test
    files on interp and 49 golden suites, `variadics.bot` among them, on
    four backends).

**The Apple benchmark** (`bench/c-ffi.tcl`, macos-15, ns: the loop alone,
the loop with the call, and the call over the loop):

| call | loop | + call | call |
|---|---:|---:|---:|
| `add(a, b)`, fixed | 26.8 | 23.9 | -2.8 |
| `stack_tail(12 args)`, fixed | 23.2 | 24.4 | 1.2 |
| `stack_tail(20 args)`, fixed | 26.9 | 35.6 | 8.7 |
| `vsum(2, a, a)`, variadic | 23.2 | 24.4 | 1.2 |
| `vsum(11, ...)`, variadic | 24.0 | 32.0 | 8.0 |
| `vscale(1.0, 4, 4 doubles)`, a Float64 result allocated | 27.4 | 62.4 | 34.9 |
| (`big`, a fixed call whose u64 result is boxed) | 26.0 | 42.4 | 16.4 |

The Apple padding is invisible:

* a two-trailing call costs what a fixed twelve-argument call costs (1.2 ns
  over the loop, below the loop's own noise, which makes `add` negative);
* eleven trailing arguments cost what twenty fixed ones do (8.0 against
  8.7), although every trailing one goes on the stack and the padding
  fills the free registers first.

The double row is again the result's allocation (Apple's allocator
measures slower than Linux's here, `big`'s boxed result as well).

## 26. Linux x86-64 regression

* **Local** (a 4-core container), `tclsh9.0 tests/local.tcl` on `93c6fb8`:
  * Tcl tests: 6,374 passed on interp and 6,369 on compile;
  * golden suites: 99 of 99 on all four backends (4,924 tests on interp);
  * one failure, `sc-census-exhaustive`, fixed in `6b291a9`.
* **Local GC stress:** `variadics.test` and `c-ffi.test` under
  `BOTLISH_NATIVE_GC_STRESS=1`, 167 passed, 0 failed.
* **[tests.yml, run 39470122809](https://github.com/mwagner-webdev/botlish/actions/runs/39470122809)** (`6b291a9`) succeeded:
  * the Tcl suite on interp and compile;
  * cranelift and cranelift-generic coverage;
  * the four golden shards beside their Tcl originals;
  * the native Rust unit tests;
  * the stub-linked executables;
  * the warning gate;
  * the method-filter audit.

  The GC-stress job runs on pushes to main only.
* **[tests.yml, run 39493572184](https://github.com/mwagner-webdev/botlish/actions/runs/39493572184)** (`3781794`, the final
  code) succeeded, the same jobs.
* **[static-decisions, run 39464864287](https://github.com/mwagner-webdev/botlish/actions/runs/39464864287)** (`93c6fb8`)
  succeeded: every golden suite's static decisions agree under the batched
  and the sequential scheduler.
* **[c-bindgen, run 39464912909](https://github.com/mwagner-webdev/botlish/actions/runs/39464912909)** (`93c6fb8`) succeeded:
  generation, every profile's check, and the acceptance tests.

## 27. Linux AArch64 regression

**[tests-arm64.yml, run 39470126646](https://github.com/mwagner-webdev/botlish/actions/runs/39470126646)** (`6b291a9`, on
ubuntu-24.04-arm) succeeded, every job:

* the Tcl suite on interp and compile, which includes `c-ffi.test`'s
  `cf-va-*`: the AArch64 capture of every scenario against GCC's own calls
  and AAPCS64's model;
* cranelift and cranelift-generic coverage;
* the four golden shards;
* the native Rust unit tests, natively and under GC stress, with
  `ffi_linux_aarch64_variadic_arguments_in_registers` and the Apple
  placement tests;
* the whole suite under GC stress.

**[tests-arm64.yml, run 39493576392](https://github.com/mwagner-webdev/botlish/actions/runs/39493576392)** (`3781794`, the final
code) succeeded, every job: the Tcl suite on interp and compile, both
native coverages, the four golden shards, the Rust unit tests natively and
under GC stress, and the whole suite under GC stress (8,533 tests: 8,437
passed, 96 skipped by host constraints, 0 failed).

## 28. Remaining limitations

* **Function values carry no variadicity.** A function type has no
  variadic marker, and a call through a value passes the List itself. A
  forwarding wrapper (`fn log(variadic xs: List[str]): sink(xs)`) passes
  its List as one argument of `sink`; there is no spread.
* **A bare List's function is no value**, as every imprinted callable.
* **A variadic function implements no trait requirement or context-trait
  operation.**
* **C: no `va_list`, no variadic callback type.** A C function receiving
  or forwarding a `va_list`, and a C function pointer of a variadic type,
  stay unsupported. So does a variadic function only a thunk could call
  (C cannot forward `...`), Tcl's stub-table redirections included.
* **C: the convention table.** Variadic calls are lowered for System V
  (x86-64, AArch64) and AppleAarch64. Any other convention is a codegen
  error, never a guess. Windows x64's convention (doubles duplicated in
  integer registers) would be its own row.
* **C: no format strings.** Nothing reads a format string or checks a call
  against one. A printf with a wrong conversion is the C program's
  undefined behavior, as in C.
* **C: types per argument.** A literal needs a converter (`c_long(-7)`).
  A shorter spelling, such as an inferred C type for a literal at a
  variadic position, would be a rule this slice deliberately does not make.

## 29. Forwarding and tuples: considerations only

Nothing here was implemented; these are the questions a later slice would
face.

* **Forwarding a List to a variadic Botlish function** (`sum(...xs)`, a
  spread) would need a call form whose trailing arguments are a List value.
  It is statically trivial: the List is the argument the call builds
  anyway. The cost is syntax, plus one more thing a call can be.
* **Forwarding to a C variadic function** would need each element's C type
  at the call. A List has one element type, so a homogeneous List of a C
  scalar could be expanded only when its length is statically known (an
  `extents` proof, as FIXED-LAYOUT-ARRAYS.md has). Anything else is runtime
  marshalling, which this design excludes.
* **A heterogeneous positional sequence** (a tuple) is what would type a
  `printf(fmt, x, y)` forwarded through a Botlish wrapper. It is a general
  type-system feature: an element type per position, its own subtyping and
  imprinting. It should be designed as such, never smuggled in through
  variadics. A bare List's least-upper-bound imprinting is deliberately not
  that.

## 30. What to run when changing this

AGENTS.md's "Variadics" section is the list:

* **The Botlish side:** tests/variadics.test, audit/variadics/tools/fuzz.tcl
  (several seeds, once with `-gc-stress 1`) and
  audit/variadics/tools/mutate.tcl.
* **The C side:** tests/c-ffi.test (its `cf-va-*`, also under GC stress),
  audit/c-ffi/tools/fuzz.tcl, the `va-*` mutants, and the `ffi_` Rust
  tests (the AArch64 placements on an AArch64 host).
* **The binding generator:** its checks (C-BINDGEN.md, section 35).
