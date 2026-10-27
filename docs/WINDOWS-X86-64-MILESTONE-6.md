# WINDOWS-X86-64-MILESTONE-6.md

Milestone 6 of the Windows x86-64 port: Win64 variadic C calls. The census
is WINDOWS-TOOLCHAIN-CENSUS.md; the milestones before it are
WINDOWS-X86-64-MILESTONE-1.md (the driver, executables),
WINDOWS-X86-64-MILESTONE-2.md (C calls, MSVC fixtures, the C runtime
policy), WINDOWS-X86-64-MILESTONE-3.md (unwind information, native-frame
roots), WINDOWS-X86-64-MILESTONE-4.md (the stack guard) and
WINDOWS-X86-64-MILESTONE-5.md (coroutines). The variadic calls are
VARIADICS-VERTICAL-SLICE-1.md's, the same `extern c fn f(FIXED...,
variadic)` declarations and calls that already ran on Linux and macOS. The
work was developed on Linux.

> A variadic C call on Windows is an ordinary Botlish foreign call, subject
> to the same language-level contracts and borrowing rules as on Linux and
> macOS, lowered by the Win64 ABI and checked against real MSVC callees.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner through
  `.github/workflows/windows-x86_64.yml` (run and job named), production
  code only;
* **controlled experiment**: a test or a probe run on purpose, and where:
  Linux, or a Windows runner;
* **cross build**: compiled on Linux for `x86_64-pc-windows-msvc` and
  type-checked (`cargo check --tests`), never run there;
* **other hosts**: Linux x86-64 and AArch64 and macOS AArch64, where the
  code this milestone shares with them runs;
* **code inspection**: what the code does, read, not run.

No Wine and no WSL were used. Commits are named by their hashes on the
branch `claude/optimistic-brown-ton0v5`, where every CI run below ran.

## Contents

1. Result
2. The ABI model
3. The Cranelift investigation
4. Implementation
5. Fixtures
6. Real C runtime calls
7. GC, borrowing and errors
8. Tests and CI
9. Performance and code generation
10. Remaining limitations
11. Next milestones

## 1. Result

Every variadic C call Botlish lowers elsewhere now runs on Windows x86-64.
`native/native.tcl`'s `cVariadics` capability names windows-x86_64, so
`nativeCVariadics` holds there and every `cf-va-*` test runs on Windows.
Nothing in the language changed: no syntax, no type, no convention name,
no new foreign type, no change of the C promotions or of the borrowing
rules.

```botlish
import std::abi
import std::abi::bytes
import std::byte
import std::ffi::c
import std::list
import std::str

extern c library "legacy_stdio_definitions"
extern c fn snprintf(buffer: std::ffi::c::Ptr[std::ffi::c::Char] write noescape,
    size: std::ffi::c::ULongLong,
    format: std::ffi::c::Ptr[std::ffi::c::Char] read noescape, variadic) -> std::ffi::c::Int

fn nul() -> std::byte::Byte:
    0

fn cstring(text: str) -> std::abi::bytes::Bytes:
    std::abi::bytes::from_list(text.encode_utf8().append(nul()))

fn c_int(n: std::ffi::c::Int) -> std::ffi::c::Int:
    n

r = snprintf(std::abi::bytes::zeroed(std::abi::usize(32)), 32, cstring("%.3f|%d"), 3.14159, c_int(-42))
r.result
```

The MSVC C runtime's `snprintf` writes `3.142|-42` into the exposed buffer
(`cf-va-crt-snprintf`'s first call begins with these two conversions:
section 6). The double is `snprintf`'s fourth argument, so Win64 passes it
in xmm3 *and* r9, and the C runtime's `va_arg` reads it from r9's home
slot.

| Criterion | Status | Evidence |
|---|---|---|
| Variadic calls use the production foreign-call machinery | done | one `foreigncall` per call, the same exposures and keepalives as a fixed call (section 4; `cf-va-nir`, `cf-va-borrow-nir`) |
| Win64's variadic ABI, positions and duplication | real Windows | `cf-va-abi-*` (seven scenarios) against MSVC's own variadic calls and an independent model (section 5) |
| A float or double of the first four positions in both registers, as its bits | real Windows, controlled experiment | the captures (`both N` locations), `ffi_win64_variadic_doubles_in_both_registers` (section 5) |
| Fixed and trailing parameters at their positions | real Windows | `cf-va-abi-fixedd` (a named double at position 0), `cf-va-positions` |
| The default argument promotions | real Windows | `cf-va-abi-narrow`, `cf-va-values`, `cf-va-promotions-follow-the-target` (LLP64's 32-bit long) |
| Stack arguments past the fourth position | real Windows | `cf-va-abi-ints`, `-mixed`, `-doubles`; `cf-va-values` (30 trailing arguments) |
| MSVC `va_arg` callees read every tested type | real Windows | `cf-va-values`, `-positions`, `-doubles`, `-sentinel`, `-arities`, `-float-promotion` |
| Real C runtime calls | real Windows | `snprintf`, `_open`'s optional mode, user32's `wsprintfA` (section 6) |
| Fixed-arity calls unchanged | real Windows, controlled experiment | `cf-va-stubs`, `ffi_win64_fixed_calls_unchanged`, every `cf-abi-*` |
| Borrowing and GC | real Windows | `cf-va-crt-snprintf` and every `cf-va-*` under GC stress (section 7) |
| Coroutines and executables | real Windows | `cf-va-executable-gc-coroutine`, the CRT tests' executables |
| `nativeCVariadics` on Windows, after validation | done | native/native.tcl, tests/platform/native-status.tcl's `c-variadic` |
| Mutants killed | real Windows, Linux | section 8.4 |
| Linux and macOS unchanged | other hosts | section 8.5 |

## 2. The ABI model

### 2.1 Positions

Microsoft's x64 calling convention ("x64 calling convention", "Parameter
passing") assigns the first four arguments by position, whatever their
kind:

| Position | Integer or pointer | Float or double |
|---|---|---|
| 0 | rcx | xmm0 |
| 1 | rdx | xmm1 |
| 2 | r8 | xmm2 |
| 3 | r9 | xmm3 |
| 4 onward | stack | stack |

The caller reserves 32 bytes of shadow space at its stack pointer; the
fifth argument is in the 8-byte slot at 32, the sixth at 40, and so on.
Fixed and trailing arguments share one count: a variadic function's
trailing arguments continue the positions of its fixed ones.

### 2.2 Duplication

"Varargs": for a call of a variadic function, a floating-point value in
one of the first four positions must also be in the integer register of
its position, "in case the callee expects the value in the integer
registers". A variadic callee's `va_start` spills rcx, rdx, r8 and r9 into
their home slots (the shadow space), and `va_arg` reads every variadic
argument from memory -- a double of the first four positions from its
integer register's home slot. Where a callee takes a named double from is
its compiler's business; the rule makes either place right.

The rule is about the *callee's* convention, not about which side of the
`...` an argument is on: a caller duplicates every floating-point argument
of the first four positions of a call of a variadic function, named ones
included. LLVM does (X86ISelLowering's `LowerCall`: "Win64 ABI requires
argument XMM reg to be copied to the corresponding shadow reg if callee is
a varargs function"), and so does MSVC: **real Windows**, the reference
half of `cf-va-abi-fixedd` -- MSVC's own call of `int (*)(double, int,
...)` -- arrives with the named 0.75 in xmm0 and in rcx (section 5.1).
Botlish does the same. A fixed-arity call duplicates nothing.

The integer register holds the value's bits, not a conversion: a double's
64 bits, a C float's 32 in the low half (the rest of a register holding a
narrow argument is the ABI's undefined bits).

### 2.3 Promotions

C's default argument promotions are the existing ones (`core::cabi::
promoted`, VARIADICS-VERTICAL-SLICE-1.md section 10), read from the
target's row; nothing Windows-specific was added or changed:

| Source C type | Promoted (C) | Machine representation (Win64) |
|---|---|---|
| `signed char`, `unsigned char`, `char`, `short`, `unsigned short`, `_Bool` | `int` | 32 bits of a register or stack slot |
| `int`, `unsigned int` | itself | 32 bits |
| `long`, `unsigned long` | itself: 32 bits under LLP64, so not widened | 32 bits |
| `long long`, `unsigned long long`, a pointer | itself | 64 bits |
| `double` (Float64) | `double` | 64 bits, and at a position below 4 in both registers |
| `float` | `double` | -- (see below) |

Three things are kept apart. The *source type* is the trailing argument's
C type (`hir::cabi::VariadicArgument`, the call's `cvarargs` class). The
*promoted type* is `core::cabi::promoted` of it on the target (the
`promoted` class, which nir.rs's `VarArg::parse` re-validates as a
promotion C performs). The *machine representation* is the per-call
signature's parameter type (I32, I64, F64) and, on Win64, the stub's
copies.

A C float has no Botlish value type: a `std::ffi::c::Float` result is the
Float64 it exactly widens to (C-FLOAT-FFI-MILESTONE-1.md). Passed as a
trailing argument it is therefore already the double C's promotion makes
of a float, and `cf-va-float-promotion` checks that `va_arg(ap, double)`
reads `(double)0.1f`'s bits, `0x3fb99999a0000000`. A fixed `float`
parameter of a variadic function is a float (no promotion of a named
parameter): its xmm register holds it, and the stub copies its 64 bits,
whose low 32 are the float.

All of the promotion code is existing behavior; `cf-va-promotions-follow-
the-target` already pinned the windows-x86_64 row (`long` as `i32:i32`)
before this milestone. Nothing was corrected.

### 2.4 Outside the model

Aggregates by value, unprototyped calls, `va_list`, callbacks into
Botlish, vector types and `long double` are outside Botlish's foreign-call
contract and stay so (section 10).

## 3. The Cranelift investigation

### 3.1 What 0.135.2 states

The pin is cranelift-codegen 0.135.2, unchanged. **Code inspection** of
`isa/x64/abi.rs`:

* `compute_arg_locs` for `CallConv::WindowsFastcall` counts one
  position per parameter slot (`next_param_idx`), and
  `get_intreg_for_arg`/`get_fltreg_for_arg` pick rcx/rdx/r8/r9 or
  xmm0-xmm3 by that position: the positional assignment of section 2.1.
  It reserves the 32-byte shadow space before the first stack argument
  (`next_stack = 32`).
* Each parameter gets exactly one location: an F64 one xmm register, never
  an integer register too. `ir::Signature` and `AbiParam` have no variadic
  marker, and `ArgumentPurpose` has nothing that duplicates a value
  (`Normal`, `StructArgument`, `StructReturn`, `VMContext`).
* Nothing gives a value a fixed register at a call except the signature.

Cranelift releases since the pin were checked the same way: 0.136.0 to
0.136.4 and 0.137.0 (2026-10-20) have no variadic marker either, and
0.137.0's `compute_arg_locs` differs from 0.135.2's in one line (a
reference to `rc_for_type`'s argument).

### 3.2 The experiment

**Controlled experiment** (Linux, a scratch program against the pinned
crates, an ISA for `x86_64-pc-windows-msvc`): a function calling an
import with the per-call signature a variadic call needs -- the fixed
parameters, then each trailing argument as its promoted type -- compiled
by Cranelift and written as a COFF object, read back with its own listing
and objdump. Three calls:

| Call | Where the doubles went | The integer register of a double's position |
|---|---|---|
| `f(2, -5, 2.5)` | xmm2 | r8 never written |
| `f(6, 0.5, -9000000000LL, -1.25, -2.0, 7, 3.5)` | xmm1, xmm3; -2.0 and 3.5 in the stack slots at 32 and 48 | rdx holds **3.5's bits**, a scratch Cranelift used to load another constant; r9 never written |
| `f(0.75, 3, 1.5, -6, 2.5)` (a named double first) | xmm0, xmm2 | rcx never written; r8 never written |

The positions, the shadow space and the 8-byte stack slots are right. The
duplication is absent, and not harmlessly: in the second call an MSVC
callee's `va_arg(ap, double)` for 0.5 reads rdx's home slot and gets 3.5.

COFF detail the same objects show: a call of an import is `mov
.refptr.callee(%rip), %reg; call *%reg` (the `object` crate's stand-in
for a GOT), and a `PltRelative` relocation, which cranelift-object writes
for x86-64's PC-relative calls, is IMAGE_REL_AMD64_REL32 in COFF -- so a
`jmp rel32` to a C function is exactly MSVC's tail call `jmp callee`,
which link.exe resolves to the function or to its import thunk.

### 3.3 The options

| Option | Verdict |
|---|---|
| A Cranelift mechanism (a signature, a call convention, an ABI attribute) | none exists in 0.135.2 or any later release (3.1) |
| Pass a trailing double at a position below 4 as an I64 (its bits in the integer register only) | refused: what MSVC's `va_arg` reads, but not the ABI -- the xmm register stays empty, and a named double would not be duplicated at all |
| Pass each double twice, as an extra integer parameter | refused: under positional assignment every extra parameter shifts every later argument by one position (the brief's warning; the mutant `va-win64-extra-arguments` is this, killed) |
| Patch Cranelift (an ABI attribute duplicating a slot in `compute_arg_locs` and `gen_call_args`) | the right upstream change, not a local one: vendoring cranelift-codegen for a few lines of ABI is a fork to maintain; recorded as the upstream correction (section 10) |
| A stub between the call and the C function that copies the xmm registers into the integer registers of their positions | **chosen**: the technique System V's `%al` already uses (VARIADICS-VERTICAL-SLICE-1.md section 12), through supported APIs only |

## 4. Implementation

### 4.1 The lowering

All of it is in `native/src/codegen/clif.rs`; no other production file
changed code (native/native.tcl's capability is data).

* **`c_call_signature`** accepts `CallConv::WindowsFastcall` on x86-64
  (`win64`). A trailing argument is one more parameter of its promoted
  type, I32, I64 or F64 -- System V's construction, which Cranelift's
  windows_fastcall places at the next position. No padding. Windows on
  AArch64 shares the name `windows_fastcall` but not Win64's rules (every
  variadic argument in the integer registers): it stays a codegen error
  (`ffi_windows_aarch64_variadic_refused`, run on AArch64 hosts).
* **`shadow_positions`**: the mask of the first four positions whose
  parameter is a float or a double -- positions, never a per-kind count.
* **`VaStub`** says what a call's stub does: `Al(N)` (System V's `mov $N,
  %eax`) or `Shadow(MASK)` (Win64's copies). **`va_stub_for`** chooses it
  from the call's signature: System V on x86-64 always `Al`; Win64 `Shadow`
  when the mask is not empty, else no stub and a direct call; AArch64 none.
  `declare` defines one stub per (foreign function, `VaStub`) the program's
  calls use, and `foreign_call` calls the stub instead of the C function.
* **The stub** (`va_stub`, `va_stub_code`) is, per set position, one
  `movq %xmmI, R` -- `66 REX.W 0F 7E /r` (`SHADOW_COPIES`: rcx, rdx, r8,
  r9) -- then the jump the `%al` stub uses: `jmp rel32` in an object (a
  `X86CallPLTRel4`, -4: ELF's PLT32, COFF's REL32), `movabs $SYMBOL, %r11;
  jmp *%r11` in the JIT. Its legend in a CLIF listing names the copies:
  `botlish_va_0_x10 (rdx=xmm1,r9=xmm3 stub of C probe)`.

```text
botlish_va_0_x5 (rcx=xmm0,r8=xmm2 stub of C bcf::vscale), in an object:
  66 48 0f 7e c1      movq %xmm0, %rcx
  66 49 0f 7e d0      movq %xmm2, %r8
  e9 rel32            jmp bcf_vscale        (IMAGE_REL_AMD64_REL32)
```

### 4.2 What it keeps

* **The FFI contract.** Admission, the trailing argument rule, promotions,
  exposures, keepalives, directness and the result's conversion are the
  front end's and native lowering's, unchanged: NIR is identical for every
  target (`cf-va-nir`, `cf-va-borrow-nir`), and a variadic call is still
  one `foreigncall`.
* **Fixed-arity calls**: `c_call_signature` of a non-variadic declaration
  is still exactly `c_signature`, and `declare` makes stubs for variadic
  declarations only (`ffi_win64_fixed_calls_unchanged`, `cf-va-stubs`'s
  fixed-arity call with doubles, `va-win64-fixed-calls-stubbed`).
* **Calls with no floating-point argument in the first four positions**
  call the C function directly: no stub, no extra instruction.
* **Every other register and the stack.** The stub writes only the integer
  registers of positions holding a float or a double -- which those
  positions leave unused -- and reads only xmm0-xmm3; rsp, the return
  address, the shadow space and every stack argument are as the call left
  them. r11 (the JIT form's) is volatile and no argument register under
  both conventions.
* **Unwind information, stack walks and the stack guard.** The stub has no
  frame, no call and no `.pdata` entry: Windows treats a function without
  one as a leaf whose return address is at the stack pointer, which is
  true at every instruction of the stub. It jumps, never calls, so no
  stack ever holds a frame of it: by the time C runs, the return address
  on the stack is the Botlish caller's, whose unwind information
  milestone 3 emits. The collector never runs while C does (C does not
  call into the runtime), and the guard classifies a fault by address
  (milestone 4), not by function. `codegen::unwind`, `jitunwind`,
  `framewalk` and the guard are unchanged.
* **AGENTS.md's rule** that the one register Botlish places itself is
  System V's `%al` now names the two stubs, and forbids extending either
  or adding a third without showing first that no Cranelift signature of
  the pinned release can state the rule.

### 4.3 Files

| Area | Files |
|---|---|
| Lowering | `native/src/codegen/clif.rs` (`c_call_signature`, `VaStub`, `shadow_positions`, `va_stub_for`, `va_stub`, `va_stub_code`, `declare`, `foreign_call`; the `win64_variadic_tests` and an AArch64 test) |
| Capability | `native/native.tcl` (`cVariadics`), `tests/helpers.tcl` (its comment), `tests/platform/native-status.tcl` (`c-variadic`: `{value {printf windows_fastcall}}`, the probe's call through a stub) |
| Fixtures | `tests/cffi/fixture-win64.asm` (`bcf_vcapture`, `bcf_vcapture_d`), `tests/cffi/fixture.c` (the reference calls compiled on Windows too; two scenarios; `bcf_vrecord1`, `bcf_vfloat`, `bcf_byte_at`, `bcf_vword`) |
| Tests | `tests/c-ffi.test` (the Win64 row of the variadic model; `cf-va-stubs`, `-abi-doubles`, `-abi-narrow`, `-positions`, `-float-promotion`, `-borrow-nir`, `-crt-snprintf`, `-crt-open-mode`, `-dll-wsprintf`; `cf-va-win64-refused` removed) |
| Audits and bench | `audit/c-ffi/tools/mutants.txt` (nine Win64 mutants, a keepalive one, three rewritten, one stale one updated), `mutate.tcl` (the Windows host's name), `fuzz.tcl` (LLP64's long; built by tests/ctoolchain.tcl), `bench/c-ffi.tcl` (the same, and two rows), the golden census and manifest |
| CI | `.github/workflows/windows-x86_64.yml` (variadic calls under GC stress; their disassembly by dumpbin) |
| Documentation | this report, `AGENTS.md`, `docs/C-FFI.md`, `docs/INDEX.md`, Compilerpedia's `concept.variadics` and `error.native-codegen` |

## 5. Fixtures

### 5.1 Machine state: `bcf_vcapture`

`tests/cffi/fixture-win64.asm` gained `bcf_vcapture` (a `PROC FRAME`,
168 bytes of frame) and `bcf_vcapture_d` (a tail jump to it, the alias
fixture.c's Unix assembly makes with two labels). Before any compiled code
runs it saves rcx, rdx, r8, r9, rax and the low 64 bits of xmm0-xmm3 into
fixture.c's `bcf_vcapture_record` layout, and passes the caller's stack
pointer at its call -- the shadow space, then the stack arguments.

fixture.c's reference calls (`bcf_vreference_*`), each the C compiler's
own variadic call through a volatile pointer of the variadic prototype,
were left out on Windows; they now compile there, so each scenario is
captured twice per backend, from Botlish's call and from MSVC's.

c-ffi.test's variadic model (`::vabi`, `vabiLocations`) gained a
positional row from Microsoft's document -- never from core::cabi or the
compiler: four positions, the stack from 32, and a double of a position
below 4 at the location `{both N}`, checked in xmm N **and** in integer
register N, the same 64 bits. Each capture is compared with it value by
value:

| Scenario | Prototype and call | Win64 places |
|---|---|---|
| none | `vcapture(0)` | r0 |
| small | `vcapture(2, -5, 2.5)` | r0 r1 **b2** |
| ints | `vcapture(12, -1 ... 2147483647)` | r0-r3, nine stack slots from 32 |
| mixed | 18 trailing: ints, long longs, pointers, ten doubles | r0 r1 **b2** r3, fifteen slots 32-144 |
| fixedd | `vcapture_d(0.75, 3, 1.5, -6, 2.5)`: a *named* double at position 0 | **b0** r1 **b2** r3 s32 |
| doubles (new) | `vcapture(5, 0.5, -1.25, 6.0, -0.375, 1e300)` | r0 **b1 b2 b3** s32 s40 |
| narrow (new) | `vcapture(5, (signed char)-3, (unsigned char)200, (short)-30000, (unsigned short)65535, true)` | r0-r3 (promoted ints), s32 s40 |

(`bN` is `{both N}`.) Together they put a double in each of the four
positions -- position 0 as a named parameter -- alternate doubles with
integers, cross the four-register boundary with doubles and with
integers, and fill twenty positions. `cf-va-abi-model` pins the model's
places on every host target.

**Controlled experiment, any x86-64 host**: the Rust test
`ffi_win64_variadic_doubles_in_both_registers` JIT-compiles Win64 code for
three calls through the real lowering and stub into a naked `extern
"win64"` capture function, every argument loaded from memory (no constant
a register could hold by accident), and checks the same model: each
double of the first four positions in xmm *and* the integer register,
integers in theirs, everything else at 40 + 8n from the capture's stack
pointer. `ffi_win64_variadic_integers_direct` does the same for a call
that needs no stub. They run in every Linux build of the driver and in
the Windows smoke job's Rust tests.

### 5.2 `va_arg` consumers

MSVC compiles fixture.c's genuine `<stdarg.h>` callees, which read their
trailing arguments the way the C runtime does (from the home slots):

| Test | Callee | What it covers on Win64 |
|---|---|---|
| `cf-va-values` | `bcf_vrecord(count, kinds, kinds2, ...)` | 30 trailing arguments of every C type at both bounds (LLP64's `long` bounds), from position 3 to 32 |
| `cf-va-positions` (new) | `bcf_vrecord1(kinds, ...)`: one fixed parameter | doubles at positions 1-3 and past them, doubles alternating with ints, long longs, unsigned ints and pointers, promoted narrow values, fifteen arguments |
| `cf-va-doubles` | `bcf_vscale(double factor, int count, ...)` | a named double at position 0, trailing doubles at 2 and 3 and on the stack |
| `cf-va-arities` | `bcf_vsum(count, ...)` | 0 to 12 trailing ints |
| `cf-va-position-types` | `bcf_vrecord` | one position passing an int, a double, a pointer, a long in four calls |
| `cf-va-sentinel` | `bcf_vsentinel(tag, ...)` | NULL-terminated pointer lists, eleven past every register |
| `cf-va-float-promotion` (new) | `bcf_vrecord1(7, x)`, x a C float's Float64 | `va_arg(ap, double)` reads `(double)0.1f` |

The two kinds of evidence complement each other, as the brief asks: the
captures show the machine state, including the copies no particular
callee reads; the `va_arg` callees show what a callee compiled by the
platform's compiler makes of it.

## 6. Real C runtime calls

**Real Windows** (run 40572363212, section 8.3; the static release C
runtime, `/MT`, and link.exe), and every other host:

* **`cf-va-crt-snprintf`** (every host): the platform C runtime's
  `snprintf`, its buffer a MutableBytes exposed for writing and its format
  a Bytes exposed for reading, formats

  ```text
  "%.3f|%d|%lld|%g|%e|%u|%c|%s|%.2f|%5.1f|%x" (3.14159, -42, -9000000000LL, 0.1, 12345.678, 4000000000u, 65, "botlish", -2.5, 6.7, 255u)
    -> 74, "3.142|-42|-9000000000|0.1|1.234568e+04|4000000000|A|botlish|-2.50|  6.7|ff"
  "%d+%d=%d" (40, 2, 42)                     -> 7, "40+2=42"
  "%d-%d-%d" (1234, 5678, 9012), size 8      -> 14, "1234-56" (C99 truncation)
  "%.1f %.1f %.1f %.1f %.1f" (0.5 ... 4.75)  -> 19, "0.5 1.5 2.5 3.2 4.8"
  ```

  on both native backends, under GC stress and as a standalone executable.
  The first call's double is the fourth argument (r9 and xmm3); the last
  call's five doubles start there and continue on the stack.
* **`cf-va-crt-open-mode`** (Windows): the static C runtime's `_open(path,
  oflag, ...)` reads its third argument only when `oflag` has `_O_CREAT`.
  Created with `_S_IREAD` the file is read-only -- Tcl's `file attributes
  -readonly` says 1 and a later `_open(path, _O_WRONLY)` returns -1 --
  and with `_S_IREAD | _S_IWRITE` writable; a call without `_O_CREAT`
  passes no third argument.
* **`cf-va-dll-wsprintf`** (Windows): user32's `wsprintfA` (declared
  WINAPIV: Win64's C convention), through its import library user32.lib,
  formats `"%d %u %x %s %d"` into exposed storage on both backends and in
  an executable, which imports it from USER32.dll.

The executables keep milestone 2's C runtime policy: the static release
runtime, no other runtime library. `legacy_stdio_definitions.lib` is the
out-of-line definitions of the printf family that the UCRT's headers
define inline since Visual Studio 2015 (for code that is not C); it works
with the static runtime, and declaring it is the binding's business, as any
`extern c library`.

## 7. GC, borrowing and errors

* **Exposure and lifetime** (`cf-va-borrow-nir`): a variadic call's fixed
  pointer parameters expose byte storage exactly as a fixed call's --
  after every argument, a write exposure a private copy (`mbytesclone`,
  `mbytesaddr`, then `bytesaddr`), then the `foreigncall` with its
  `varargs=`, then a `keepalive` of each exposed storage. The mutant that
  drops the keepalives of a variadic call (`va-keepalive-dropped`) is
  killed by it.
* **A trailing argument is never byte storage** (FOREIGN-BORROW,
  `cf-va-type-refusals`) and a trailing pointer is a direct edge
  (`cf-va-direct`): unchanged.
* **GC stress**: the smoke job runs every `cf-va-*` test under
  `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
  site), so every capture, `va_arg` and C runtime test above also runs with
  collections between the argument evaluations, around the exposures and
  after the call. `cf-va-crt-snprintf` additionally runs its write-back
  under GC stress in-process and as an executable.
* **Coroutines** (`cf-va-executable-gc-coroutine`, which runs on Windows
  now): variadic calls with managed values held across them inside a
  coroutine, before its first yield and after it -- on Windows on a fiber
  (milestone 5) -- among them `bcf_vscale(1.0, 9, ...)`, whose doubles at
  positions 0, 2 and 3 go through the stub, under GC stress, on both
  backends and in an executable.
* **Error capture** is unchanged: the stub runs before C, never between
  C's return and the caller's reading of its result, so the window
  C-FFI-ERROR-CAPTURE-MILESTONE-1.md keeps empty stays empty. No variadic
  CRT test here reads `errno` (`_open`'s failure is checked by its -1).

## 8. Tests and CI

### 8.1 Commands

| What | Command | Where |
|---|---|---|
| The C FFI tests, the variadic ones among them | `tclsh9.0 tests/c-ffi.test` | every host; on Windows in the smoke tier, the acceptance tier and the system-linker job |
| The variadic tests under GC stress | `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/c-ffi.test -match 'cf-va-*'` | Windows smoke job (new step), Linux locally |
| The Rust tests of the lowering | `cargo test --release --manifest-path native/Cargo.toml --bin botlish-native ffi_` (`win64_variadic_tests`, `x86_64_variadic_tests`; `apple_tests` on AArch64) | every host's smoke or unit job |
| The native status | `tclsh9.0 tests/platform/native-status.tcl` | every host |
| The C FFI fuzzer | `tclsh9.0 audit/c-ffi/tools/fuzz.tcl -n N -seed S` (tier item `c-ffi-fuzz`) | Linux locally; Windows through `[ci-full]` |
| The mutants | `tclsh9.0 audit/c-ffi/tools/mutate.tcl -only va-...` (tier item `c-ffi-mutants=...`) | Linux locally; Windows through `[ci-full]` |
| The disassembly | `native::object` of a variadic program, `dumpbin /disasm` | Windows smoke job (new) |
| The benchmark | `tclsh9.0 bench/c-ffi.tcl` (tier item `c-ffi-bench`) | Linux locally; Windows through a manual run |

### 8.2 Linux, locally

On a 4-core Linux x86-64 container, at `68c2d46`:

* `tclsh9.0 tests/local.tcl`: Tcl tests on interp 7,362 passed and on
  compile 7,357 passed, 0 failed (97 and 102 skipped by host constraints,
  2,250 golden duplicates); 108 golden suites on all four backends, 0
  failed (interp and compile 5,180 tests each, cranelift-generic 5,088,
  cranelift 5,190); 2,740 s.
* `tests/c-ffi.test` (in that run, on interp and on compile): 123 passed,
  6 skipped (two of them the Windows-only `cf-va-crt-open-mode` and
  `cf-va-dll-wsprintf`), 0 failed; its `cf-va-*` under
  `BOTLISH_NATIVE_GC_STRESS=1`: 34 passed, 0 failed.
* `cargo test --release --manifest-path native/Cargo.toml --lib --bins`:
  299 + 99 passed, the seven `win64_variadic_tests` among them; `cargo
  check --tests --target x86_64-pc-windows-msvc` and `--target
  aarch64-unknown-linux-gnu` (cross builds): no error, no warning.
* `tests/platform/native-status.tcl`: every capability as recorded for
  linux-x86_64 (`c-variadic` `{printf system_v}`, its call now through the
  `%al=1` stub).
* `tools/compilerpedia.tcl check`: 849 topics, 635 examples, 0 problems.
* `audit/c-ffi/tools/fuzz.tcl -n 3 -seed 5`: 36 functions, 11 variadic, 58
  trailing arguments, 0 disagreements (the fuzzer as made portable).
* `tests/golden.test`: 9 passed (the manifest with the new census rows).

### 8.3 Windows

**Real Windows**, run [40572363212](https://github.com/mwagner-webdev/botlish/actions/runs/40572363212)
(`68c2d46`, windows-2025):

* smoke: the native Rust tests (293 + 102 passed, every
  `win64_variadic_tests` test among them: the Win64 calls through the stub
  executed on Windows itself); the native status, `c-variadic`
  `{printf windows_fastcall}` and every other capability as recorded; the
  objects, executables, GC workloads, census programs, Windows I/O and
  dumpbin steps; the variadic program's object, whose CLIF legend names
  its two stubs (`botlish_va_0_x2 (rdx=xmm1 stub of C probe)`,
  `botlish_va_0_x10 (rdx=xmm1,r9=xmm3 stub of C probe)`) and whose
  disassembly by dumpbin is section 9.3's.
* c-ffi.test on Windows, in the smoke tier on interp and on compile and
  in the new step under GC stress: every `cf-va-*` test passed --
  `cf-va-abi-none`, `-small`, `-ints`, `-mixed`, `-fixedd`, `-doubles`,
  `-narrow` against MSVC's own calls, the `va_arg` tests, the C runtime's
  `snprintf` and `_open`, the coroutine and executable test -- but one:
  `cf-va-dll-wsprintf`, whose expectation was wrong (28 characters for the
  29 of `-42 4000000000 beef botlish 7`; wsprintfA returned 29 and wrote
  exactly that text, on both backends and in the executable, imported from
  USER32.DLL). Under GC stress: `Total 129 Passed 35 Skipped 93 Failed 1`
  (`-match 'cf-va-*'`), the one failure the same.
* full, `CI-Tests: c-ffi-fuzz c-ffi-mutants=...`: the C FFI fuzzer, now
  built with MSVC, ok on seeds 1 and 2 and on seed 9 under GC stress
  (random fixed and variadic functions, doubles at every position, MSVC's
  `va_arg`); the mutants (section 8.4).
* The acceptance and system-linker jobs were cancelled by the next push.

[[run 2]]

### 8.4 Mutants

`audit/c-ffi/tools/mutants.txt` gained ten mutants: nine of the brief's
list (its promotion item is two existing mutants') and the naive
duplication it warns against, extra arguments. Three existing ones (`va-al-omitted`, `va-stub-jit-jump-misplaced`,
`va-stub-plt-addend-dropped`) were rewritten for the new code, keeping
their rules, the latter two now of both stubs; and one, `stub-links-c`,
had stopped applying before this milestone (aot.rs's stub-linker refusal
had moved) and was brought up to date. `mutate.tcl` names the Windows host
`windows-x86_64` now (it read `windows nt-x86_64` from `tcl_platform(os)`,
so no `%% windows-x86_64` mutant could have run there), and the fuzzer it
runs as a detector builds its C library with tests/ctoolchain.tcl and models
LLP64's `long`, so on Windows it is a real detector instead of one whose
every program fails to link -- which would have counted every mutant as
killed.

The Win64 mutants are `%% linux-x86_64 windows-x86_64`: every x86-64
build compiles Win64's lowering, and the Rust tests that run a Win64 call
through the stub in the JIT kill them on Linux; on Windows c-ffi.test's
MSVC captures and callees kill them as well.

**Linux x86-64, locally** (`mutate.tcl -only ...`, two runs; every
detector: c-ffi.test, six fuzzer programs, the `ffi_` Rust tests):

| Mutant | The brief's item | Killed by |
|---|---|---|
| `va-win64-no-shadow-copy` | omitting duplication | Rust: `ffi_win64_variadic_doubles_in_both_registers`, `_stub_positions` |
| `va-win64-wrong-integer-register` | the wrong general-purpose register | Rust: `_doubles_in_both_registers`, `_stub_bytes` |
| `va-win64-converted-not-copied` | a numeric conversion (cvttsd2si) instead of the bits | Rust: `_doubles_in_both_registers`, `_stub_bytes` |
| `va-win64-positions-by-kind` | integer and floating-point positions counted apart | Rust: `_stub_positions`, `_doubles_in_both_registers` |
| `va-win64-stack-slot-shifted` | a stack argument one slot late | Rust: four tests |
| `va-win64-extra-arguments` | (the naive duplication: extra arguments) | Rust: three tests |
| `va-narrow-not-promoted`, `va-unsigned-narrow-promoted-unsigned` (existing, every host; not run again: the promotions are front-end code this milestone does not change) | a promotion omitted or corrupted | c-ffi.test, the NIR's promotion check (VARIADICS-VERTICAL-SLICE-1.md section 23) |
| `va-win64-fixed-calls-stubbed` | variadic lowering applied to fixed-arity calls | c-ffi.test: `cf-va-stubs`, `cf-clif`, `cf-clif-stack-parameters`, `cf-bool-lowering` |
| `va-win64-fourth-position-missed` | the four-register boundary | Rust: `_doubles_in_both_registers`, `_stub_positions` |
| `va-keepalive-dropped` | a borrowed argument released early | c-ffi.test: `cf-va-borrow-nir` |
| `va-win64-capability-without-lowering` | the capability without the lowering | Rust: four tests |
| `va-al-omitted`, `va-al-zero` | (System V, rewritten / unchanged) | c-ffi.test's captures, the fuzzer, Rust |
| `va-stub-jit-jump-misplaced` | (both stubs' JIT jump) | Rust: the Win64 capture jumps into the misplaced address and the test process dies (SIGSEGV) |
| `va-stub-plt-addend-dropped` | (both stubs' object jump) | c-ffi.test's captures (8 tests), Rust |
| `va-pointer-truncated` | (existing) | c-ffi.test (6 tests), the fuzzer |
| `stub-links-c` | (existing, updated) | c-ffi.test: `cf-stub-linker` |

16 mutants, 16 killed, 0 survived.

**Windows** (`[ci-full]`, `CI-Tests: c-ffi-mutants=...`):

[[CI]]

### 8.5 Linux AArch64 and macOS

**macOS AArch64**, run [40572363052](https://github.com/mwagner-webdev/botlish/actions/runs/40572363052)
(`68c2d46`, macos-15): every job succeeded -- smoke (Tier A, the native
Rust tests with the Apple placement tests), the system linker, both
acceptance shards (c-ffi.test's new `cf-va-*` tests on Apple's convention:
the two new capture scenarios, the position matrix, the float promotion
and libSystem's `snprintf`), the full tier (the C FFI fuzzer on seeds 1, 2
and 9 under GC stress, ok; the mutants: 1 killed, `va-keepalive-dropped`,
and 11 skipped as x86-64's) and the Linux control.

[[Linux CI]]

## 9. Performance and code generation

### 9.1 What a call costs, by construction

**Code inspection** of the lowering:

* **A fixed-arity call** is unchanged: the same signature, the same
  instructions (no stub is ever made for one: `cf-va-stubs`).
* **A variadic call with no float or double in its first four positions**
  -- integer-only calls, and calls whose doubles all come after the fourth
  argument -- is a direct call through the per-call signature, exactly what
  a fixed call of that signature would be: no stub, no extra instruction.
* **A variadic call with floats or doubles there** calls the stub instead
  of the C function: one `movq` (5 bytes, a register-to-register move) per
  such position, at most four, then one direct `jmp` (5 bytes). The call
  site is the same size as a direct call. One stub per (C function, mask)
  a program uses -- at most fifteen per function -- each at most 25 bytes,
  aligned to 16.
* Nothing allocates, nothing is a safepoint, and no frame is pushed.

### 9.2 Measurements

`bench/c-ffi.tcl` (best of 5 runs of 100,000 iterations; ns per
iteration: the loop alone, the loop with the call, the difference; a
difference within about 5 ns is the loop's noise). It now builds its
fixture with tests/ctoolchain.tcl, so it runs with MSVC on Windows, and has
two rows more: `va 1.0` (one trailing double at the second position) and
`va mixed` (doubles and ints alternating past the four registers).

**Linux x86-64, locally** (4-core container, nothing else running), System
V's lowering, which this milestone does not change:

| Call | loop | + call | call |
|---|---:|---:|---:|
| `add(i, 1)`, fixed | 36.0 | 37.8 | 1.8 |
| `stack 12`, fixed, six on the stack | 35.8 | 39.3 | 3.5 |
| `va 2`: `vsum(2, a, a)` | 38.7 | 41.9 | 3.2 |
| `va 11`: eleven trailing ints | 39.5 | 42.7 | 3.2 |
| `va 1.0`: `vrecord1(7, 0.5)` | 34.6 | 39.3 | 4.7 |
| `va mixed`: seven trailing, alternating | 36.8 | 47.0 | 10.2 |
| `va 4.0`: `vscale(1.0, 4, ...)`, a Float64 result allocated | 36.1 | 71.8 | 35.6 |
| (`big`: a fixed call whose u64 result is boxed) | 35.5 | 68.6 | 33.0 |

**Windows x86-64**:

[[CI]]

### 9.3 The machine code

**Real Windows**: dumpbin's `/disasm` of the program object of section
8.3's variadic program (the smoke job's summary), its four calls of
`probe(int n, ...)` and `fixed(double, int, double)`:

```text
botlish_va_0_x2:
  66 48 0F 7E CA     movq        rdx,xmm1
  E9 00 00 00 00     jmp         botlish_variadic_probe
botlish_va_0_x10:
  66 48 0F 7E CA     movq        rdx,xmm1
  66 49 0F 7E D9     movq        r9,xmm3
  E9 00 00 00 00     jmp         botlish_variadic_probe

ints(a) = probe(3, a, a, a): no double, no stub
  movsxd  rcx,eax                                ; 3
  mov     rax,qword ptr [.refptr.botlish_variadic_probe]
  mov     rdx,r9 / mov r8,r9 (r9 = a)
  call    rax

one(x) = probe(1, x)
  movsd   xmm1,mmword ptr [rdx+8]                ; x, from its Float64
  movsxd  rcx,eax                                ; 1
  mov     rax,qword ptr [.refptr.botlish_va_0_x2]
  call    rax

mixed(a, x) = probe(7, x, a, x, a, x, a, x)
  movsd   xmm3,mmword ptr [r8+8]                 ; x: position 3
  mov     r8,rdx; sar r8,1                       ; a: position 2
  movsxd  rcx,eax                                ; 7: position 0
  mov     dword ptr [rsp+20h],r8d                ; a: position 4
  movsd   mmword ptr [rsp+28h],xmm3              ; x: position 5
  mov     dword ptr [rsp+30h],r8d                ; a: position 6
  movsd   mmword ptr [rsp+38h],xmm3              ; x: position 7
  mov     rax,qword ptr [.refptr.botlish_va_0_x10]
  movdqa  xmm1,xmm3                              ; x: position 1
  call    rax
```

Each call site is what a fixed call of the same signature would be, the
callee the stub instead of the C function when a double is in the first
four positions. The positions, the shadow space (the first stack argument
at `rsp+20h`) and the 8-byte slots are Cranelift's; an `int` is stored as
its 32 bits, which is all `va_arg(ap, int)` reads. The fixed-arity call
`fixed(x, a, x)` has no stub (the legend lists two). The stubs' padding
to 16 bytes is never executed.

## 10. Remaining limitations

* **Unprototyped calls, `va_list` and variadic callbacks** stay outside
  the contract (VARIADICS-VERTICAL-SLICE-1.md section 28): Win64's
  "unprototyped functions" rule (duplicate every floating-point argument
  of every call) has no case in Botlish, whose every foreign call has a
  prototype. `FormatMessage` (a `va_list *`) and `vsnprintf` stay
  unsupported.
* **Windows on AArch64** has its own variadic rules and no lowering: a
  codegen error, as before.
* **The printf family on Windows needs `legacy_stdio_definitions`.** The
  binding generator does not know this (the UCRT's headers define those
  functions inline, so it binds no symbol for them); a hand-written
  binding declares the library, as section 6's do.
* **Cranelift states no duplication.** The stub is the second place
  Botlish writes an argument register itself. A Cranelift ABI attribute
  that gives a parameter a second, integer-register slot under
  windows_fastcall (in `compute_arg_locs` and `gen_call_args`) would let a
  signature say it; then `va_stub_for`'s Win64 case and `SHADOW_COPIES`
  go, as `ffi_win64_variadic_doubles_in_both_registers` will show.
* **The C FFI fuzzer** runs on Windows only through the tier item
  `c-ffi-fuzz` (an opt-in `[ci-full]` push), not on every push.

## 11. Next milestones

* **Windows input and filesystem I/O.** The UCRT's `_open`/`_wopen` are
  variadic and now callable (section 6); kernel32's `CreateFileW`,
  `ReadFile` and `GetFileAttributesW` are fixed-arity and were callable
  before. What that milestone needs is a design of the Windows side of
  the portable I/O interface (paths as UTF-16, handles, the error model),
  not more calling convention. `snprintf` is available for formatting,
  through `legacy_stdio_definitions`.
* **Native-library generation on Windows** (`exported c fn`,
  NATIVE-LIBRARY-MILESTONE-1.md): this milestone removes the last
  calling-convention difference among the hosts for calls *from* Botlish.
  An export is a call *into* Botlish of a fixed prototype, so it needs no
  variadic lowering; it needs a DLL and a `.lib` from link.exe, the
  exports' `.pdata` (milestone 3's unwind information already covers
  every Botlish function), and the per-library private runtime that
  NATIVE-LIBRARY-MILESTONE-1.md builds with `objcopy` on Linux.
