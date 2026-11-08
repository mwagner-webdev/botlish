# C-COMPILE-FREESTANDING-MILESTONE-1: portable C as a compilation target, with explicit runtime integration points

Completion report. Botlish programs can now be written as freestanding C11
(`main.tcl -emit-c`) that a target's own C toolchain compiles. The generated
C implements what portable C implements correctly and calls *runtime
services* for the rest; a program whose services are missing compiles and
fails only to link, naming the missing symbol, and a deterministic manifest
lists every service the C references.

Evidence is marked throughout as **[inspection]** (read in the code),
**[test]** (tests/c-compile.test, which runs in the ordinary suite),
**[run]** (a compiler, linker or program actually run during this
milestone, with the command), **[emulated]** (run under qemu-user, an
emulator: not hardware) and **[design]** (an intention not implemented
yet). Nothing here was run on embedded hardware.

## 1. Outcome and implemented scope

Implemented:

* `ccompile/ccompile.tcl`, the C backend: analyzed HIR to C, one C function
  per specialized function instance of `hir/specialize.tcl`, the integer
  representation chosen from `hir/range.tcl`'s proofs (section 8).
* `ccompile/botlish_rt_v1.h`, the runtime-service interface, version 1:
  seven Int services (section 9).
* `main.tcl -emit-c [-out DIR] FILE...`: writes `FILE.h`, `FILE.c`,
  `FILE_display.c`, `FILE.runtime.json` and, only when the C uses it,
  `botlish_rt_v1.h`. No C compiler runs (section 11 of the brief).
* The manifest `FILE.runtime.json` (section 10).
* `C UNSUPPORTED`: every construct the backend cannot translate correctly is
  a compile-time error at the construct, never a service reference (section
  7).
* Outside the compiler, in `examples/c-freestanding/`: a hosted test
  harness, a freestanding Linux startup harness (no C library: `_start` and
  system calls for x86-64, AArch64, RISC-V 64, s390x, ARMv7 and i386), a
  static-arena provider of the Int services, two example programs and
  `demo.sh`, which reproduces the demonstrations.
* `tests/c-compile.test` (38 tests): parity with interp, compile and
  cranelift; the link boundary; the manifest; no-libc builds and runs;
  cross-architecture compilation and emulated execution; the diagnostics; the
  command line.
* Compilerpedia: `backend.c`, `error.c-unsupported`, `error.c-runtime-limit`,
  `-emit-c` in `cli.options`. The single executable packs `ccompile/`.

Acceptance criteria (brief, section 15), each with its evidence:

| criterion | evidence |
|---|---|
| a real program compiles to valid, readable C | [test] 13 corpus programs, a generated one and 9 repository examples; [run] section 4's excerpts |
| a nontrivial subset executes with matching semantics | [test] `cc-parity-*` (gcc and clang, -O0 and -O2) against interp, compile, cranelift; `cc-parity-generated` (120 boundary expressions) |
| a service-free program builds with no runtime and no hosted library | [test] `cc-freestanding-objects`, `cc-freestanding-executable`; [emulated] `cc-cross-execution` |
| a program needing a service compiles without its provider | [test] `cc-missing-service-compiles` |
| the object then genuinely fails to link | [test] `cc-missing-service-link-error`; [run] section 11 |
| a deterministic manifest names the services | [test] `cc-manifest-lists-the-services`, `cc-deterministic` |
| a supplied implementation links and runs | [test] `cc-supplied-service`, `cc-provider-limit`; [run] section 12 |
| unsupported translation is reported honestly | [test] `cc-unsupported-*`, `cc-cli-unsupported` |
| no weakening of integer, ownership or error semantics | section 8, 9; [test] `cc-parity-bounds`, `cc-parity-generated`, the error programs |
| existing backend regressions pass | section 16 |

Not implemented (deliberately; brief, section 13): a general embedded
runtime, allocation, Strings, Lists of unknown length, closures,
coroutines, contexts, I/O, threads, floating point.

## 2. Starting compiler architecture

[inspection] Botlish has three representations (AGENTS.md, "Compiler
architecture"): HIR, the authoritative semantic representation; core IR,
the reference interpreter's; and NIR, native lowering's. The backends:

* **interp** runs the core IR `hir::lower` produces.
* **compile** (`compiler/compiler.tcl`, "tcl compile") compiles HIR itself
  to Tcl procedures: one walk over the analyzed HIR, choosing
  representations (boxed values or bare integers), with no semantic analysis
  of its own. Its entry is `core::compiler::compileHir`; main.tcl selects it
  with `-backend compile`.
* **cranelift** (`native/lower.tcl`, 13,300 lines) lowers HIR to NIR text,
  which the Rust driver (`native/src/`) compiles with Cranelift. Before
  lowering it runs `hir::specialize::analyze` (call-site specialization: a
  function *instance* per combination of argument kinds, each closed when
  every call reaching it is a direct call the analysis saw) and
  `hir::range::analyze` (proven integer Ranges per instance, per expression,
  per parameter and per result), then the raw-Int ABI plan, escape and
  struct analyses.

How a backend consumes the compiler's facts [inspection]: types are
`hir::typeOf` of an instance's *view* (`hir::specialize::view`), a call's
callee instance is the instance's `calls` table, a self tail call is
`hir::aot::selfTailCalls`, an expression's Range `hir::range::of`. Errors
are HIR `fail` and `handle` nodes over declared identities
(`hir::errorDecls`); a run-time error of the language is
`core::semanticError KIND` (mod by zero: `CORE SEMANTIC ARITHMETIC`).

Backends are not plugins [inspection]: interp and compile register
themselves with `core::registerBackend` (core IR runners); the native
backends are named in main.tcl. There is no mechanism for separately
packaged compiler backends.

**Which representation the C backend consumes.** The brief prefers the
representation the other backends consume. The C backend consumes analyzed
HIR together with the very analyses native lowering consumes
(`hir::specialize`, `hir::range`), as the Tcl compiler and native lowering
both do. It does not consume NIR: NIR's operands are the Rust runtime's
tagged words and heap objects (`op listnew`, `rbox`, GC roots, runtime
helper calls by the runtime's ABI), a representation that presupposes a
collector and that portable freestanding C should not inherit. No new
backend-neutral lowering was needed, and no C-specific assumption entered
the language model: nothing in `hir/`, `core/` or `surface/` changed.

## 3. Backend and operation census

Classified before the implementation and updated with what the
implementation found ([inspection] of `core/primitives.tcl`,
`core/scalarbits.tcl`, the HIR node kinds of `hir/hir.tcl`; [test] where
marked).

**A. Direct C operations** -- C expresses them correctly:

| operation | C | condition |
|---|---|---|
| `+ - *` on Ints | `int64_t` arithmetic | both operands' and the exact result's Ranges fit int64_t |
| `< <= > >= ==` on Ints | `int64_t` comparison | both operands fit |
| `mod` | `PREFIX_i64_mod` (C `%`, Euclidean fix-up, `INT64_MIN % -1` avoided) | both operands fit; a zero divisor is checked unless its Range excludes 0 |
| `bit_and bit_or bit_xor` | `& | ^` | both operands fit (exact-width types are two's complement) |
| `shift_right` | `PREFIX_i64_shr` (floor for negatives without `>>` of a negative) | the operand fits; the amount checked against 0..1048576 unless proven |
| `shift_left` | `PREFIX_i64_shl` (a multiplication: `<<` of a negative is undefined) | operand and result proven to fit, amount proven 0..62 |
| Bool, unit, `not`/`and`/`or` (lowered to `if`), `==` of Bools, enums, unit | `bool`, `unsigned char`, C conditions | |
| enum cases | C enumeration constants | payload-free (all enums are) |
| named and anonymous structs, projection | C structs by value, members | not recursive, not context, not affine, no declared identity |
| a List literal | a C struct of its elements | its length is its type (`[a, b]`) |
| functions, direct calls | static C functions | the instance is closed (only direct calls) |
| self tail calls | parameter assignment and `goto top` | `hir::aot::selfTailCalls` |
| `if`, `elif`, bare loops, counted loops (all four directions), folds, `break`, `continue`, `return` | `if`, `for (;;)`, `goto` | |
| declared errors, `fail`, `on` handlers | status codes, a dispatch | payload-free |
| run-time errors (mod by zero, shift range) | a status with Botlish's own code and message | |

**B. Portable runtime operations** -- freestanding C could implement them,
with support code: arbitrary-precision Int arithmetic (implemented as
runtime *services* in this milestone, section 9, because a correct big-number
implementation is a library of its own, not generated code), Lists of any
length and Strings (need storage: an allocation service), the display of a
big Int as text (a service), equality and hashing of aggregates, sets,
maps.

**C. Target-provided operations** -- need the environment: allocation, I/O
(Botlish's I/O is a context over Linux system calls, Darwin's libSystem or
Win32), clocks, threads, event sources, C calls (`extern c fn`: in C, an
ordinary external declaration; the natural target-integration mechanism of
a later milestone [design]).

**D. Unsupported in this milestone** (C UNSUPPORTED, section 7): Strings,
Lists of unknown length and loops over them, collecting loops whose List is
used, closures and function values, Float64 and DecimalRounded, error
payloads, Result values, contexts and context traits, coroutines and yields,
MutableVector/Array/Map/Set, byte storage, C pointers and the C FFI,
layouts, traits in a value position, bitwise operations and `shift_left`
of Ints the compiler cannot prove fit int64_t.

The distinction the brief asks for holds in the implementation: a class B
or C operation this milestone defines a service for (the Int services)
compiles to a service call; every class D construct is a compile-time
diagnostic. No class D construct becomes a symbol reference.

## 4. Generated C architecture

For `FILE.bot`, with PREFIX the file name as a C identifier ([inspection]
`ccompile::Assemble`; [run] `examples/c-freestanding/demo.sh`):

* **`PREFIX.h`** -- the interface: `PREFIX_status` (an `int`; `PREFIX_OK`
  is 0, then one macro per declared error and per run-time error the C can
  raise), `PREFIX_unit`, one C enumeration per enum, one C struct per
  aggregate in definition order, `PREFIX_value` (the program's value type),
  and the entry points `PREFIX_run`, `PREFIX_status_code`,
  `PREFIX_status_message`, `PREFIX_show`.
* **`PREFIX.c`** -- the program: static helpers (only those it uses),
  prototypes, one static function per instance, `PREFIX_run`, the status
  tables. Every function returns a status and writes its result through a
  pointer: `static PREFIX_status PREFIX_3_gcd(int64_t a, int64_t b, int64_t
  *out)`.
* **`PREFIX_display.c`** -- optional: the value as text, written into a
  caller's buffer exactly as a run prints it (`core::value::show`). It is a
  translation unit of its own so that a program that never displays its
  value links nothing displaying needs (`int.to_decimal`).
* **`PREFIX.runtime.json`** -- the manifest.
* **`botlish_rt_v1.h`** -- a copy of the interface, written only when the
  generated code uses one of its declarations.

Every C expression an operand carries is free of side effects; everything
that can fail or has an effect (a call, a service, a check) is a statement
before it, so C's unspecified evaluation order never matters. Joins (an
`if`'s value, a handled call's) are variables assigned in each branch,
their representation decided once every branch is compiled.

The generated C of `examples/c-freestanding/programs/traffic.bot` (no
service) -- a struct by value, enum constants, `int64_t` arithmetic the
Range of the domain `Ticks` proves cannot overflow:

```c
static traffic_status traffic_2_tick(traffic_State p_s_7, traffic_State *out)
{
    int64_t v_left_8 = (p_s_7).f_left;
    traffic_State j1 = traffic_State_zero;
    if (v_left_8 < INT64_C(1)) {
        traffic_Light r2;
        traffic_status st3 = traffic_3_next((p_s_7).f_light, &r2);
        if (st3 != traffic_OK) {
            return st3;
        }
        traffic_Light v_n_10 = r2;
        int64_t r4;
        traffic_status st5 = traffic_4_duration(v_n_10, &r4);
        if (st5 != traffic_OK) {
            return st5;
        }
        j1 = ((traffic_State){.f_light = v_n_10, .f_left = r4});
    } else {
        j1 = ((traffic_State){.f_light = (p_s_7).f_light, .f_left = (v_left_8 - INT64_C(1))});
    }
    *out = j1;
    return traffic_OK;
}
```

A self tail call is a loop, and `mod` checks its divisor first:

```c
static traffic_status traffic_7_gcd(int64_t p_a_27, int64_t p_b_28, int64_t *out)
{
top:;
    if (p_b_28 == INT64_C(0)) {
        *out = p_a_27;
        return traffic_OK;
    }
    if (p_b_28 == 0) {
        return traffic_ARITHMETIC_MOD_ZERO;
    }
    int64_t a1 = p_b_28;
    int64_t a2 = traffic_i64_mod(p_a_27, p_b_28);
    p_a_27 = a1;
    p_b_28 = a2;
    goto top;
}
```

(The second divisor test is redundant: `hir::range` does not represent "not
0" after `b == 0` fails. It is correct, and the C compiler removes it.)

`factorial.bot`'s product does not fit int64_t; the parameter (`[1, 30]`)
does:

```c
static factorial_status factorial_1_factorial(int64_t p_n_2, botlish_rt_v1_int *out)
{
    botlish_rt_v1_int j1 = factorial_int_of_i64(0);
    if (p_n_2 <= INT64_C(1)) {
        j1 = factorial_int_of_i64(INT64_C(1));
    } else {
        botlish_rt_v1_int r2;
        factorial_status st3 = factorial_1_factorial((p_n_2 - INT64_C(1)), &r2);
        if (st3 != factorial_OK) {
            return st3;
        }
        botlish_rt_v1_int n4;
        factorial_status st5 = factorial_int_mul(factorial_int_of_i64(p_n_2), r2, &n4);
        if (st5 != factorial_OK) {
            return st5;
        }
        j1 = n4;
    }
    *out = j1;
    return factorial_OK;
}

/* a * b of two Ints: inline while it fits int64_t, else the service. */
static factorial_status factorial_int_mul(botlish_rt_v1_int a, botlish_rt_v1_int b, botlish_rt_v1_int *result)
{
    botlish_rt_v1_status status;
    int64_t product;
    if (a.big == NULL && b.big == NULL && factorial_i64_mul_ok(a.small, b.small, &product)) {
        *result = factorial_int_of_i64(product);
        return factorial_OK;
    }
    status = botlish_rt_v1_int_mul(a, b, result);
    return status == BOTLISH_RT_V1_OK ? factorial_OK : factorial_rt_status(status);
}
```

## 5. Freestanding target assumptions

The target contract [inspection, test]:

* **C11, freestanding** (`-std=c11 -ffreestanding`): only `<stdint.h>`,
  `<stdbool.h>` and `<stddef.h>`. No `malloc`, no `stdio`, no `main`, no
  operating system, no compiler extension (the generated C compiles under
  `-pedantic-errors`), no inline assembly, no floating point.
* **`int64_t` and `uint64_t`** must exist. C11 makes the exact-width types
  optional; where they exist they are two's complement with no padding,
  which is what makes `& | ^` of negative values and the conversions in the
  helpers exact. Every target tested has them, including 8-bit AVR.
* **`int` of at least 16 bits** (statuses, enumerations, the compare
  helper's result): C guarantees it. Nothing assumes `int` is 32 bits:
  AVR and MSP430 (16-bit `int`) compile warning-free with `-Wconversion`
  [run].
* **No assumption** of pointer size, byte order, `CHAR_BIT`, alignment or
  calling convention: no value is reinterpreted, serialized or laid out;
  structs are C's own. Big-endian s390x runs the corpus [emulated].
* **Stack.** Botlish calls are C calls on the C stack. C cannot detect stack
  exhaustion: a program recursing deeper than the target's stack is the
  target's undefined behavior, not a Botlish error (the native backend's
  `NATIVE LIMIT STACK` has no portable equivalent). Self tail calls are
  loops and use no stack.
* **The toolchain's own obligations.** GCC and Clang document that a
  freestanding environment must provide `memcpy`, `memmove`, `memset` and
  `memcmp`: they may call them for a struct copy whatever the source says
  (observed: clang -O0 references `memcpy` and `memset` [run]). A 32-bit
  (or smaller) target's compiler calls its runtime library for 64-bit
  `%` and sometimes `*` (section 15's table). These are obligations of the
  C toolchain and its target, not Botlish's; the manifest does not list
  them.

## 6. Supported Botlish constructs

[inspection] `ccompile::Expr` and its callees; [test] `cc-parity-*`:

* functions with parameters and results of the supported types, direct
  calls of their closed instances, self tail calls (loops), recursion;
* top-level values a function reads (file-scope objects written by the
  program before any function runs);
* Int (section 8), Bool, unit, enums, named structs (opaque too), anonymous
  structs, a List literal as a value (a struct of its elements: the
  program's final `[a, b, c]` is the common case);
* `if`/`elif`/`else` as a statement and as a value, conditions built of
  `and`, `or`, `not`, `!=` (all lowered to `if` before any backend);
* `loop:` (bare), counted loops `from`/`down from` ... `to`/`through`, a
  collecting counted loop whose List is discarded, folds over either,
  `break`, `continue`, `return`;
* declared errors: `fail E`, `errors` clauses, handled calls with `on E:`
  handlers (nested, completing or leaving);
* the run-time errors of `mod` (division by zero) and the shifts (amount
  out of range), with Botlish's own codes and messages.

## 7. Unsupported constructs and diagnostics

Everything in class D (section 3) is `C UNSUPPORTED`, raised by
`ccompile::program` through `core::raiseDiagnostics` (one entry per
construct), each located and worded the same way [test]
`cc-unsupported-*`:

    s.bot:3:5: the C backend cannot compile a String yet (Compilerpedia's
    backend.c lists what it compiles); this is a limit of the backend, not a
    missing runtime service (C UNSUPPORTED)
    help: botlish -help error.c-unsupported

When a function cannot be compiled, its callers stop without a diagnostic
of their own, and every other function the program uses is compiled too,
so each independent construct is reported, not only the first
(`cc-unsupported-several`). `main.tcl -emit-c` prints them, exits 1 and
writes nothing (`cc-cli-unsupported`). A `.ir` input is `C INPUT`. Both
codes have a Compilerpedia topic (`error.c-unsupported`), and
`tools/compilerpedia.tcl check` now scans `ccompile/` for codes.

The backend's internal consistency is checked too: a join or a result
whose representation was never decided would leave a placeholder in the
text, and assembly refuses to return such C (an internal error, never
output).

## 8. Integer and value representation correctness

**The rule** [inspection] `ccompile::ReprOf`, `Arith`, `OpRange`:

* An Int is an `int64_t` (`i64`) exactly where an existing proof says it
  fits: its Range (`hir::range::of` in the instance being compiled), its
  type's integer domain (`hir::range::TypeFact`), or a representation
  chosen earlier on such a proof. Everything else is a `botlish_rt_v1_int`:
  `{int64_t small; const botlish_rt_v1_bignum *big;}`, the value inline
  while it fits int64_t.
* `a + b`, `a - b`, `a * b` are C arithmetic only when both operands' Ranges
  *and* `hir::range::add/sub/mul` of them fit int64_t: the exact result is
  then an int64_t, so no C signed overflow (undefined behavior) can happen,
  and no intermediate exceeds it. Otherwise the operation is a helper with
  a portable fast path: an overflow test that cannot itself overflow
  (`b >= 0 ? a <= INT64_MAX - b : a >= INT64_MIN - b`; for `*`, the
  magnitudes multiplied in 32-bit halves, with no division), and a service
  call when the exact result does not fit.
* Widening an `int64_t` to an Int is free (`big = NULL`). Narrowing an Int
  to an `int64_t` happens only where a proof says the value fits, and is a
  read of `small`: the services' **normalization** obligation (a result
  that fits int64_t is returned small, botlish_rt_v1.h) is what makes that
  read exact. The C backend never narrows on anything but a proof.
* A function's parameters are carried as their entry Ranges allow (every
  call of a closed instance is one the analysis saw); its result as an
  `int64_t` when every completion of its body is one, else as the range
  analysis's result Range allows; a recursive function's result as the
  Range allows (its body cannot be compiled before its own calls). A fold's
  intermediate is an `int64_t` when its initial value and every normal
  completion of its body are proven to fit -- each intermediate is one of
  those. A struct field is carried as its declared type allows (a domain:
  `int64_t`; `int`: an Int), never by what one construction held.
* `mod` is Euclidean in C as in Botlish (`r < 0 ? r + |b|` without
  computing `|b|`, which overflows for INT64_MIN, and `b == -1` answered 0
  without `INT64_MIN % -1`, which overflows). The zero divisor raises
  Botlish's `mod: division by zero (CORE SEMANTIC ARITHMETIC)`, with or
  without a service.
* `shift_right` of a negative value is computed as the complement's shift
  (C's `>>` of a negative is implementation-defined); `shift_left` as a
  multiplication (C's `<<` of a negative is undefined).

No new range analysis was built: every fact is `hir::range`'s or a domain's.
Where it proves nothing the C is correct and slower (the Int path), and the
manifest says what it needs.

**Values, ownership, errors** [inspection]: Botlish values are immutable,
so C structs passed and returned by value are the semantics, not an
approximation; no C pointer to a Botlish value is ever created or shared
(the only pointers are result out-parameters and the provider's
immutable big numbers). Affine values are unsupported, so no release is
needed. A declared error is a status that propagates to the innermost
handler or out of the function; a handler selects by identity only; a
run-time error of the language is a status no handler catches, as on every
backend; nothing terminates the process.

**Evidence** [test]: `cc-parity-bounds` (the int64_t edges: INT64_MAX + 1,
INT64_MIN - 1, INT64_MAX², INT64_MIN * -1, `mod(INT64_MIN, -1)`, Euclidean
`mod` of big negatives, `3037000499²` against `3037000500²`, a 24-digit
literal), `cc-parity-generated` (60 boundary operations both proven and on
the Int path, 120 values), `cc-parity-domains` (bitwise operations of
negatives, shifts), each at -O0 and -O2 with gcc and clang, against interp,
compile and cranelift.

## 9. Runtime-service interface

`ccompile/botlish_rt_v1.h` [inspection]:

| service | symbol | contract |
|---|---|---|
| int.add, int.sub, int.mul | `botlish_rt_v1_int_add` ... | exact result, normalized |
| int.mod | `botlish_rt_v1_int_mod` | Euclidean; the caller guarantees b != 0 |
| int.compare | `botlish_rt_v1_int_compare` | -1/0/1; total |
| int.from_decimal | `botlish_rt_v1_int_from_decimal` | a literal outside int64_t |
| int.to_decimal | `botlish_rt_v1_int_to_decimal` | text of a big value; display only; total |

* **Version**: every symbol carries `v1`; an incompatible interface is
  `botlish_rt_v2_` with its own header, so a program and a provider of
  different versions fail to link instead of disagreeing.
* **Representation**: `botlish_rt_v1_int` is part of the interface; the big
  number behind it is the provider's own type (`struct
  botlish_rt_v1_bignum`, opaque to the program). Nothing of the compiler's
  internal representation is exposed.
* **Ownership and lifetime**: a big number is immutable and owned by the
  provider; the program copies the handle freely, never frees or inspects
  it; the provider keeps it valid at least until the program's entry
  function returns (an arena reset between runs, or never freeing, both
  qualify). Services never retain or modify their operands.
* **Errors**: a fallible service returns 0 or `BOTLISH_RT_V1_LIMIT` (its
  storage cannot hold the result); it never returns a wrong value. The
  program turns LIMIT into its terminal status `C RUNTIME LIMIT`, and any
  status the interface does not define into `C RUNTIME FAULT`; no Botlish
  handler catches either (resource exhaustion is outside the language, as
  on every backend).
* **Granularity**: one symbol per operation; a program requires exactly the
  ones its C calls, and a provider may implement any subset. There is no
  initialization service and no global runtime object, so a program that
  needs no service links no runtime at all.

The model is not tied to C [design]: the same service list could back a
native target without the Rust runtime. No existing runtime was refactored
for it.

## 10. Runtime-requirements manifest

`PREFIX.runtime.json` [inspection, test]:

```json
{
  "format": "botlish-c-runtime-requirements",
  "format_version": 1,
  "runtime_abi": "1",
  "program": "factorial",
  "source": "factorial.bot",
  "entry": "factorial_run",
  "c_standard": "C11",
  "hosted": false,
  "headers": ["stdbool.h", "stddef.h", "stdint.h"],
  "target_requirements": ["a freestanding C11 implementation", "int64_t and uint64_t (exact-width two's complement types)", "no hosted library, allocation, I/O or entry point (the embedding calls the entry)"],
  "runtime_header": "botlish_rt_v1.h",
  "translation_units": [
    {"file": "factorial.c", "role": "program", "required_services": ["int.mul"]},
    {"file": "factorial_display.c", "role": "display", "required_services": ["int.to_decimal"]}
  ],
  "required_services": [
    {
      "service": "int.mul",
      "symbol": "botlish_rt_v1_int_mul",
      "header": "botlish_rt_v1.h",
      "description": "a * b of two Ints",
      "required_by": ["factorial.c"]
    },
    ...
  ]
}
```

**What "required" means**: a service is required by a translation unit
when that unit's C contains a call of it -- in a function of an instance
the program reaches (the instances `PREFIX_run` calls, transitively),
including calls inside helpers, and including paths no run takes (an
overflow branch). Code the analyses prove unreachable is not compiled and
requires nothing; there are no unused declarations (helpers are emitted
only when used). So the list is exactly the symbols the C references
(`cc-manifest-lists-the-services` extracts them from the text), an upper
bound of what a link needs: an optimizing C compiler may prove a call
unreachable and drop it -- gcc -O2 removed every service call from a
`gcd` whose arguments were constants [run], and clang -O2 dropped
`int.compare` and `int.mod` for some targets (`cc-cross-targets` therefore
checks the references unoptimized). The program and the display unit are
listed separately: a firmware that never displays its value needs only the
first. Entries are sorted, the file is generated from the compilation alone
(no time, path or host), and two generations are byte-identical
(`cc-deterministic`). It is an integration contract for future tooling,
not a package manager: nothing reads or resolves it yet.

## 11. Missing-service compilation and link demonstration

The real operation: `factorial(30)`'s product exceeds int64_t, so its
multiplication needs `int.mul`. [run] (`examples/c-freestanding/demo.sh`;
gcc 13.3.0, GNU ld 2.42):

    $ tclsh9.0 main.tcl -emit-c factorial.bot
    c: factorial.h
    c: factorial.c
    c: factorial_display.c
    c: factorial.runtime.json
    c: botlish_rt_v1.h
    runtime services: int.mul, int.to_decimal
    $ cc -std=c11 -pedantic -Wall -Wextra -Werror -O0 -ffreestanding -c factorial.c
    $ nm -u factorial.o
                     U botlish_rt_v1_int_mul
    $ cc -std=c11 -DBOTLISH_PROGRAM=factorial -DBOTLISH_PROGRAM_HEADER='"factorial.h"' \
         harness/host_main.c factorial.c factorial_display.c -o factorial
    /usr/bin/ld: ...: in function `factorial_int_mul':
    factorial.c:(.text+0x253): undefined reference to `botlish_rt_v1_int_mul'
    /usr/bin/ld: ...: in function `factorial_show0':
    factorial_display.c:(.text+0x242): undefined reference to `botlish_rt_v1_int_to_decimal'
    collect2: error: ld returned 1 exit status

The Botlish compilation succeeded; the C compiled; the link failed on
exactly the manifest's two symbols. [test] `cc-missing-service-compiles`,
`cc-missing-service-link-error`.

## 12. Supplied-service integration demonstration

`examples/c-freestanding/providers/botlish_rt_v1_int_arena.c` is an
independent provider of all seven Int services, outside the compiler:
freestanding C11 (no allocation, no library call), sign-magnitude numbers
of 32-bit limbs in a fixed static arena (`BOTLISH_RT_INT_ARENA_LIMBS`,
default 65536), schoolbook arithmetic and bitwise long division, LIMIT
when the arena is full. [run]:

    $ cc ... harness/host_main.c factorial.c factorial_display.c \
         providers/botlish_rt_v1_int_arena.c -o factorial
    $ ./factorial
    value: 265252859812191058636308480000000

[test] `cc-supplied-service` (30!, against the reference),
`cc-provider-limit` (an 8-limb arena: `error: a runtime service could not
complete an operation: its provider's storage is exhausted (C RUNTIME
LIMIT)`), and every parity test links it (the big values of
`cc-parity-bounds`). It also ran with no C library on six architectures
(section 15).

## 13. Entry-point and embedding model

The generated program has no `main` and no startup [inspection]:

* `PREFIX_status PREFIX_run(PREFIX_value *value)` runs the program and, on
  `PREFIX_OK`, writes its value. The embedding -- a desktop harness, a
  firmware's startup, an existing firmware calling a Botlish component --
  calls it.
* `PREFIX_status_code(status)` and `PREFIX_status_message(status)` name an
  error as every Botlish backend reports it ("mod: division by zero",
  "CORE SEMANTIC ARITHMETIC").
* `PREFIX_show(&value, buffer, capacity)` (the display unit) writes the
  value's text into a caller's buffer and returns its length, snprintf-like.
* Every global symbol carries PREFIX (`cc-public-names-prefixed`), so
  several programs link into one image; all other functions are static.
* `PREFIX_run` is not reentrant when a function reads a top-level value
  (a file-scope object).

Two harnesses, outside the generated program
(`examples/c-freestanding/harness/`): `host_main.c` (hosted: prints
`value: TEXT` or `error: MESSAGE (CODE)`, what the tests compare) and
`linux_start.c` (freestanding: `_start`, the `write` and `exit` system calls
per architecture, the four memory functions the toolchain requires, and on
ARM the `raise` Linux's libgcc calls). The same program source links with
either.

## 14. Cross-backend semantic parity

[test] Each `cc-parity-*` program is compiled to C once, built with gcc and
with clang at -O0 and at -O2 under `-std=c11 -pedantic-errors -Wall -Wextra
-Werror -Wshadow -Wstrict-prototypes -Wmissing-prototypes -Wconversion
-Wsign-conversion -Wcast-qual -Wundef`, linked with the reference provider,
run, and its line required to equal the line interp, compile and cranelift
give the same HIR (which must agree among themselves):

| program | covers |
|---|---|
| recursion | fib, gcd (tail loop, Int path), fact(20) and fact(25) (int64_t and big) |
| loops | every counted-loop direction and end kind, continue, break, empty domains, bare loops, fold without a clause, a discarded collecting loop, return from loops |
| errors | declared errors, nested handlers, handlers that fail again, discarded handled calls |
| never-joins | `if` and handlers whose every branch leaves |
| bounds | the int64_t boundary cases of section 8 |
| domains | integer domains, bitwise operations of negatives, shifts |
| statics | top-level values read by functions, a structured top-level value, tail recursion |
| structs | named, nested and anonymous structs, enums, equality of mixed kinds, empty List and struct |
| pure | the service-free traffic controller |
| mod-zero, mod-zero-big | the division-by-zero error, with and without a service |
| shift-range, shift-negative | the shift-amount error |
| generated | 60 random boundary operations (`+ - * < == mod`), each proven and on the Int path |
| examples | the nine `examples/surface` programs the backend compiles (`cc-parity-examples`) |

**The repository's corpus** [run]: of the 33 programs of
`examples/surface`, `examples/stdlib`, `examples/refinement` and `bench`
(the warning gate's corpus directories, minus the platform ones), 2 are
rejected by the front end on purpose (`09-mutual-recursion`,
`10-duplicate-binding`), 11 compile to C -- every one agrees with interp,
compile and cranelift -- and 20 are C UNSUPPORTED: Lists of unknown length
(6), values of no static type (4), Strings (2), ImmutableSet (3), a
function or native as a value (2), `integer?` (1), an erased enum (1), a
nested unsupported type (1). That census found three defects of the
backend, fixed and now under test: a binding only a discarded branch read
left an unused C variable, the display unit defined an unused helper (both
fatal under -Werror), and an instance specialization keyed by the bare kind
`enum` (`fn same(x)` called with cases of two enums) raised an internal
error instead of C UNSUPPORTED (`cc-unsupported-erased-enum`).

All pass (section 16). Interp is not compared on million-deep recursion
(Tcl's recursion limit stops it first: `TCL LIMIT STACK`); a C self tail
call is a loop.

## 15. Freestanding and toolchain validation

**Strict diagnostics** [run, test]: every corpus program compiles warning-free
with gcc 13.3.0 and clang 18.1.3 under the flag set of section 14 at -O0,
-O2, -O3 and -Os (-O0/-O2 in the test suite).

**No hosted library** [test] `cc-freestanding-objects`: `traffic`'s two
objects, compiled `-ffreestanding` at -O1, -O2 and -Os by gcc and clang,
have no undefined symbol at all. `cc-freestanding-executable`: linked with
`-nostdlib -static` and `linux_start.c` on Linux x86-64, the program runs
from `_start` and prints its value -- no C library, no Botlish runtime, no
provider.

**Other architectures, compiled** [test] `cc-cross-targets`; [run] for the
rest. `clang --target=T -ffreestanding` compiles the generated C with the
strict flags for thumbv6m-none-eabi (Cortex-M0), thumbv7m-none-eabi
(Cortex-M3), riscv32-unknown-elf, riscv64-unknown-elf, msp430-none-elf
(16-bit `int`), avr with `-mmcu=atmega328p` (8-bit), m68k, mips (big
endian), powerpc (big endian), sparc, hexagon, s390x, aarch64 and i386.
What each object leaves undefined (llvm-nm), the toolchain's helpers
separated from Botlish's services:

| target | service-free program | factorial (int.mul) |
|---|---|---|
| x86-64, aarch64, riscv64, s390x | nothing | the two services |
| thumbv7m, riscv32, mips, powerpc, sparc, i386 | `__aeabi_uldivmod` / `__umoddi3` (64-bit `%`) | the two services |
| thumbv6m (Cortex-M0) | `__aeabi_uldivmod` | `__aeabi_lmul` + the two services |
| msp430 | `__mspabi_remull` | `__mspabi_mpyll` + the two services |
| m68k | `__umoddi3` | `__muldi3` + the two services |
| hexagon | `__hexagon_umoddi3`, `memcpy` | the two services |
| avr (atmega328p) | `__umoddi3`, `__do_copy_data` | `__muldi3`, `memcpy`, `__do_copy_data` + the two services |

(Measured at -O2. The 64-bit `%` is `mod`'s; the display unit uses no
division: its digits are made by subtraction.)

**Other architectures, executed** [test] `cc-cross-execution`
[emulated]: eight corpus programs, each built by clang 18 with ld.lld 18,
`-nostdlib -static`, the startup harness and the reference provider, for
aarch64, riscv64, s390x (big endian) and armv7 (with the toolchain's own
`libgcc.a` from Ubuntu's cross package, for `__aeabi_uldivmod`) run under
qemu-user 8.2.2, and for i386 (with i686 `libgcc.a`) run natively: 40 runs,
every line equal to interp's and compile's. This is emulation and a 32-bit
mode of an x86-64 machine, not embedded hardware; no physical device was
tested, and no bare-metal (non-Linux) image was linked.

Reproduce [run]:

    examples/c-freestanding/demo.sh OUT
    tclsh9.0 tests/c-compile.test
    # one cross build by hand:
    tclsh9.0 main.tcl -emit-c -out OUT examples/c-freestanding/programs/traffic.bot
    clang --target=aarch64-linux-gnu -fuse-ld=lld -std=c11 -O2 -ffreestanding \
        -nostdlib -static -fno-stack-protector -fno-pic \
        -DBOTLISH_PROGRAM=traffic -DBOTLISH_PROGRAM_HEADER='"traffic.h"' -I OUT \
        examples/c-freestanding/harness/linux_start.c OUT/traffic.c OUT/traffic_display.c -o traffic
    qemu-aarch64 ./traffic

## 16. Existing regression results

[run] on this branch, Linux x86-64, Tcl 9.0.1:

* `tests/c-compile.test`: 38 tests, 38 passed (gcc 13.3.0, clang 18.1.3,
  ld.lld 18.1.3, qemu-user 8.2.2, the cross libgcc 13 packages installed).
* `tests/main-cli.test`: 72 passed (the option table, the usage width and
  the cli.options topic cover `-emit-c` and the new `-out`).
* `tests/compilerpedia.test`: 43 passed; `tools/compilerpedia.tcl check`: 0
  problems.
* `tools/mutant-catalogs.tcl`: 88 catalogs, 3128 mutants, 0 problems.
* `tests/std-namespace.test`: 36 passed; `tests/bot-modules.test`: 68
  passed, 1 skipped (SDL3 not built). Both pack a bundled compiler with
  `single/package.tcl`, which now stages `ccompile/`.
* `tests/golden.test`: 9 passed; `audit/golden/migration/merge.tcl -check 1`
  passes (the new test file's census rows and the regenerated manifest).

The other backends are untouched: no file of `core/`, `hir/`, `surface/`,
`compiler/` or `native/` changed. main.tcl gained `emitC` and the option;
`-out` is now accepted by `-emit-c` as well as `-emit-native-library`. The
full local suite (`tests/local.tcl`) was not run here.

CI on the branch (commit 58b222c, the workflows a branch push starts): the
Linux x86-64 canary -- the mutant catalogs, the warning gate, then the test
files the push changes, `tests/c-compile.test` among them -- passed, as did
the Linux arm64 canary, the macOS smoke tier (with its canary step) and
acceptance shard 3 of 4, the Windows canary and root-plan jobs, and both
Icy Tower workflows (Windows and macOS). When this report was written the
remaining macOS acceptance shards, the macOS system-linker and Botlish.app
jobs and the Windows smoke job were still queued: pending, not passed. On a
branch push the full Linux suites (tests.yml and tests-arm64.yml beyond
their canaries) do not run; they run on main, or when dispatched on the
branch before a merge (AGENTS.md, "Git workflow").

## 17. Known limitations

* The subset (sections 6, 7): no Strings, Lists of unknown length,
  closures, floats, payloads, contexts, coroutines or FFI.
* Precision is the range analysis's: a fold's intermediate, a result of
  `shift_right` of a negative value or a function whose recursion the
  analysis widens is an Int, carried and computed on the (correct, slower)
  Int path, and links a provider. Integer domains are the program's way to
  keep values in int64_t.
* Bitwise operations and `shift_left` of unproven Ints are unsupported
  (no services for them in v1).
* No stack-depth protection (section 5); no reentrancy when top-level values
  are read by functions.
* The manifest is an upper bound of a link's needs; the toolchain's own
  helpers (section 15) are not listed.
* The provider is a reference, not a production bignum library: quadratic
  algorithms, a static arena, one thread.
* Packaging: the backend is a directory of the compiler (`ccompile/`, packed
  into the single executable), loaded only for `-emit-c`; there is no
  plugin mechanism to load it from a package yet.
* Not tested on hardware; bare-metal linking (a linker script, an ELF
  without an operating system) was not exercised.

## 18. Recommended next milestone

**Stackless coroutines and cooperative events on C.** Botlish coroutines
are statically analyzed (protocols, yield effects, affine handles) and the
native backend already *fuses* the ones whose handles never leave their
constructor (COROUTINE-FUSION-MILESTONE-1.md: a state register, the chain
copied per resume, no stack). The same discipline lowers to C as a state
machine: a coroutine's frame a C struct of its live locals and a state
enum, `resume` a `switch` over the state. Declared recognizers
(DFA-COROUTINE-MILESTONE-2.md) already compile to transition tables a C
`switch` expresses directly. Concretely:

1. Compile fusable coroutines (fusion's conditions) to C state machines;
   keep every other one C UNSUPPORTED -- never a thread or a stack.
2. An event-source service family in `botlish_rt_v2`/an extension header
   (`event.wait`, `clock.monotonic`), the target's, with
   `std::event_loop::Driver` implemented over it in Botlish, so the
   scheduler stays ordinary Botlish (EVENT-LOOP-MILESTONE-1.md).
3. `extern c fn` declarations as direct C calls (the target's device APIs as
   link-time obligations in the program's own source, listed in the
   manifest), and an allocation service so Lists and Strings of unknown
   length can be represented.

The architecture already permits it: statuses compose with resumption
(an error is a status at any yield), every function is static C with its
state explicit, and nothing in this milestone assumes a thread or an
operating system.
