# WINDOWS-X86-64-MILESTONE-2.md

Milestone 2 of the Windows x86-64 port: C calls, linked runs with their
argument vector, and Windows console I/O behind the portable `io::IO`.
The census is WINDOWS-TOOLCHAIN-CENSUS.md, the first milestone
WINDOWS-X86-64-MILESTONE-1.md (its section 9 proposed this slice). Developed
on Linux. Every Windows fact below was observed on GitHub's `windows-2025`
runners through `.github/workflows/windows-x86_64.yml`, running production
code: no probe patch, no `BOTLISH_PROBE_*` variable, no Wine, no WSL.

> A Botlish program calls C on Windows through the same `extern c fn`
> machinery as on Linux and macOS, linked by link.exe, and prints through
> kernel32's WriteFile behind `io::IO`. Nothing of Botlish's sits between
> the Win64 C ABI, the Windows API and the program's own bytes.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (run and job named);
* **controlled experiment**: a test or a unit test run on Linux, or a
  fixture that makes Windows behave on demand on the runner (the WriteFile
  injector, the handle launcher);
* **code inspection**: what the code does, read, not run.

## Result

```botlish
import io
import windows::io

fn hello() errors io::WriteFailed:
    io::print_line("Hello, world!")

with context windows::io::create()

hello():
    on io::WriteFailed:
        unit
```

examples/io/hello-windows.bot is examples/io/hello.bot with another
context. On Windows `hello` compiles to a direct call of
`windows::io::write_text`, whose writes are kernel32's `GetStdHandle` and
`WriteFile`. Its standalone executable prints `Hello, world!` into a file,
a pipe, cmd's and PowerShell's redirections, byte for byte, and imports
only system DLLs.

```text
Botlish -> HIR -> NIR (windows-x86_64) -> Cranelift (windows_fastcall) -> COFF object
        -> rustc --target=x86_64-pc-windows-msvc, +crt-static, /NODEFAULTLIB:<other runtimes>
        -> link.exe (/LIBPATH:DIR, NAME.lib, kernel32.lib) -> NAME.exe -> GetStdHandle/WriteFile
```

| Criterion | Status | Evidence |
|---|---|---|
| Windows `extern c fn` works, the FFI contract unchanged | real Windows | native-status `c-call`, `c-byte-borrow`; c-ffi.test, c-byte-borrowing.test, c-float-ffi.test (section 7) |
| The Win64 C ABI against MSVC-built callees | real Windows | c-ffi.test's `cf-abi-*` with fixture-win64.asm's capture (section 2) |
| Real MSVC static libraries and DLL import libraries | real Windows | aot-facts `c-library`, `c-call-run`, `crt-*`; c-ffi.test's `cf-shared-library`, `cf-link-*` |
| `-L` as `/LIBPATH`, `NAME.lib`, several libraries, no GNU group | real Windows | aot-facts `c-link-command` (link.exe's own command line) |
| Actionable NATIVE LINK diagnostics from real link.exe failures | real Windows | aot-facts `c-link-missing-library` (LNK1181), `c-link-undefined-symbol` (LNK2001/LNK1120), `crt-library-md` (LNK2019 `__imp_`, with the driver's explanation) |
| A documented C runtime policy, validated | real Windows | section 3.3: the static runtime for every executable; `/MT` and `/MD` static libraries and DLLs, each measured |
| Relocatable executables | real Windows | aot-facts (moved, run elsewhere, PATH reduced to System32); windows-io.test's `wi-hello-executable` (source deleted, empty PATH) |
| Linked-run argv on Windows | real Windows | argv.test's `argv-linked-run-*` (section 4) |
| Windows `io::IO` through GetStdHandle/WriteFile/GetLastError | real Windows | windows-io.test (section 5) |
| Real programs use it (2048 demo, examples) | real Windows | the workflow's Windows I/O step; workload-2048.test's `workload-2048-demo-windows-executable` |
| GC across C calls under `BOTLISH_NATIVE_GC_STRESS=1` | real Windows | `cf-gc-calls`, byte-borrowing's stress tests, `wi-gc-stress`, `wi-short-write-completed` (section 6) |
| Linux x86-64, Linux AArch64 and macOS unchanged | PENDING | section 7.4 |

## Contents

1. Implementation summary
2. Win64 ABI validation
3. MSVC linking, the C runtime, diagnostics
4. Linked-run argv
5. Windows IO
6. GC and borrowing
7. Tests and CI
8. Remaining limitations
9. Next milestones

## 1. Implementation summary

The milestone opens one gate, replaces one placeholder, adds one launcher
and two library modules, and makes the tests able to run against
Microsoft's toolchain.

* **C calls on Windows.** `codegen::aot::C_CALLS` includes
  `windows`+`msvc`+`x86_64`; `native::capabilities`' `cCalls` lists
  `windows-x86_64` (which tests/helpers.tcl's `nativeCCalls` reads). The
  foreign-call machinery is unchanged: the same contracts, borrowing,
  directness and lowering; Cranelift's `windows_fastcall` (chosen by
  `codegen::target::c_call_conv` from the triple since milestone 1) places
  the arguments.
* **Variadic C calls stay refused on Windows**: `c_call_signature` has no
  Win64 variadic lowering, so such a call is a codegen error
  ("variadic C call of NAME: no variadic call lowering for the
  windows_fastcall convention"), as it was. A new capability,
  `cVariadics` (`nativeCVariadics`), says where variadic calls run, so that
  the variadic tests are constrained by it rather than by the operating
  system.
* **The C runtime.** Every Windows executable -- one that calls C too --
  links the static release C runtime and excludes every other Microsoft
  runtime library (`crt_args`; section 3.3). Milestone 1's placeholder,
  the dynamic runtime for programs that call C, is gone.
* **NATIVE LINK's explanation of `__imp_`** (`link_hint`): link.exe's
  unresolved `__imp_NAME` is a dynamic-runtime library's import, and the
  message says so (section 3.4).
* **Linked runs with their argument vector** (native/src/launch.rs): on
  Windows the driver writes the command line itself and starts the linked
  executable with `CreateProcessW` (section 4). `runtime::aot::
  utf16_from_wtf8` is the strict inverse of milestone 1's
  `wtf8_from_utf16`.
* **The `windows` platform** (core/cabi.tcl's `platforms`): `windows` and
  everything under it are UNSUPPORTED-PLATFORM for every other operating
  system's target, as `linux` and `darwin` are for theirs.
* **lib/windows.bot** and **lib/windows/io.bot** (section 5), with
  examples/io/hello-windows.bot and examples/games/2048/demo-windows.bot.

### 1.1 Files

| Area | Files |
|---|---|
| Native backend | `native/src/codegen/aot.rs` (C_CALLS, `crt_args`, `OTHER_MSVC_RUNTIMES`, `link_hint`, tests), `native/src/launch.rs` (new), `native/src/main.rs` (`run_linked_executable`), `native/src/runtime/aot.rs` (`utf16_from_wtf8`), `native/src/runtime/ops.rs` (tests), `native/native.tcl` (`cCalls`, `cVariadics`) |
| Front end | `core/cabi.tcl` (the `windows` platform row) |
| Libraries and programs | `lib/windows.bot`, `lib/windows/io.bot`, `examples/io/hello-windows.bot`, `examples/games/2048/demo-windows.bot` |
| Test infrastructure | `tests/ctoolchain.tcl` (new: the host's C toolchain, MSVC's on Windows), `tests/helpers.tcl` (constraints, `withEnvironment`, `runBare`), `tests/binary-header.tcl` (PE import functions), `tests/cffi/fixture.c` (MSVC-portable), `tests/cffi/fixture-win64.asm` (new), `tests/cffi/writefile-inject.c` (new), `tests/cffi/win-launch.c` (new), `tests/platform/print-link-args.c` (new) |
| Tests | `tests/windows-io.test` (new), `tests/argv.test`, `tests/c-ffi.test`, `tests/c-byte-borrowing.test`, `tests/c-float-ffi.test`, `tests/float64.test`, the layout test files (native-view, native-edit, layout-arrays, layout-unions), `tests/workload-2048.test`, `tests/target-model.test` |
| Platform scripts and CI | `tests/platform/native-status.tcl`, `tests/platform/aot-facts.tcl`, `tests/platform/tier.tcl`, `.github/workflows/windows-x86_64.yml` |
| Audits | `audit/native-aot/tools/mutants.txt`, `audit/context-traits/tools/{mutate.tcl,mutants.txt}` (Windows I/O mutants), `audit/c-ffi/tools/mutants.txt`, the golden census and manifest, `audit/refactor/manifest.txt` (the warning gate's corpus) |
| Documentation | this report, `AGENTS.md`, `docs/ARGV.md`, `docs/C-FFI.md`, `docs/INDEX.md`, Compilerpedia's topics and generated stdlib |

The census and milestone 1's report are unchanged.

## 2. Win64 ABI validation

### 2.1 What the ABI is

Microsoft's x64 calling convention (Win64), as Cranelift's
`windows_fastcall` implements it and the C compiler's own calls show it:

* the first four arguments **by position**: an integer or pointer in rcx,
  rdx, r8, r9, a float or double in xmm0-xmm3; the other register of the
  same position is unused (a double at position 1 is in xmm1, and rdx
  carries nothing);
* every later argument in its own 8-byte stack slot, above 32 bytes of
  **shadow space** the caller reserves at its stack pointer;
* the stack 16-byte aligned at the call;
* the result in rax (xmm0);
* a narrow argument's register bits above its width are undefined: the
  callee extends (MSVC's callees do);
* **LLP64**: `int` and `long` are 32 bits, `long long` and pointers 64.

### 2.2 The fixtures

`tests/cffi/fixture.c` is the C side of every C FFI test. It was written for
GCC and Clang (GNU-syntax inline assembly, `__attribute__`), so it was made
portable to MSVC's cl, unchanged on Unix:

* `BCF_NOINLINE`, `BCF_LONG_64`, `BCF_PICK_LONG`/`BCF_MIX_LONG` (the
  prototypes keep `long`, which is 32 bits on Windows; the tests choose
  values every target's `long` holds or read the target's width);
* the variadic references are left out on `_WIN32` (no Botlish call can
  reach them there);
* `bcf_capture_record_win64` records the machine state Win64's capture
  saves.

cl has no x64 inline assembly, so the assembly fixture.c's functions are on
Unix is `tests/cffi/fixture-win64.asm`, MASM assembled by ml64:

* the dirty-result functions (`bcf_dirty_*`): a narrow result whose
  register bits above its width are set the other way, which the caller
  must extend itself;
* `bcf_capture`: saves rcx, rdx, r8, r9 and the low 64 bits of xmm0-xmm3
  before any compiled code runs, and the caller's stack pointer at its call
  (entry rsp plus the return address), where the shadow space and the stack
  arguments are. A `PROC FRAME` with its unwind data (`.allocstack`).

`tests/ctoolchain.tcl` builds every fixture with the host's toolchain: on
Windows `cl /nologo /c /O2 /W3 /std:c11 /MT`, `ml64`, `lib`, and `cl /LD`
for a DLL with its import library. Its environment is vcvars64.bat's
(found with vswhere), captured once and set for those tools' runs alone:
Botlish's own links never run in it.

### 2.3 The model and the checks

c-ffi.test's ABI model (`cfAbi*`) states where each argument of a
prototype goes, per target, from the platform documents -- never from
core::cabi or the compiler. Win64's entries: four positions, the 32-byte
shadow-space base of the stack arguments, 8-byte slots, `xmm0-xmm3`
captured. The `cf-abi-*` tests call `bcf_capture` with a prototype twice,
once from Botlish and once from C (the fixture's own call of the same
prototype), and compare both with the model:

| test | what it shows on Win64 |
|---|---|
| `cf-abi-register-extension` | narrow arguments (every narrow class, `_Bool`, plain char) in the four registers: the argument's own bits as the caller wrote them; past the four, in their stack slots |
| `cf-abi-doubles-before-integers` | eight doubles then integers: the first four doubles in xmm0-xmm3, everything after on the stack, eight bytes each (no per-kind counting) |
| `cf-abi-mixed-positions` (new) | doubles and integers interleaved: position 0 and 2 in xmm0 and xmm2, 1 and 3 in rdx and r9, the other six on the stack after the shadow space |
| `cf-abi-mixed-model` (new) | the model's places of that prototype per target (runs on every host) |
| `cf-abi-stack-alignment` (new) | the stack pointer 16-byte aligned at every call with none, an odd number or sixteen stack slots, in Botlish's calls and C's |
| `cf-abi-stack-layout` / `-model` | twenty arguments of mixed width: each in its own 8-byte slot after the 32-byte shadow space |
| `cf-abi-register-boundary` | exactly the four argument registers, one argument past them and two: a narrow argument at the start of the stack area exact |
| `cf-abi-pick` | each of nineteen arguments, in registers and on the stack, read back by C compiled for the prototype: nothing misplaced, overlapped, truncated or extended the wrong way |
| `cf-abi-stack-tail-frame` | a call whose stack arguments end short of a 16-byte boundary leaves the caller's frame intact under GC stress |
| `cf-scalar-extension` | C sees a narrow argument extended by its type; Botlish extends a narrow result itself, whatever the callee left above it (fixture-win64.asm's dirty results) |
| `cf-scalar-values`, `cf-abi-classes-follow-the-target`, `cf-pointer-width` | every C integer scalar at its bounds both ways, with LLP64's widths (`long` 32 bits); a pointer crosses with all 64 bits |
| `cf-va-win64-refused` (new) | a variadic C call is a codegen error, from the CLIF listing, a linked run and an executable alike; the front end takes the program |

**Real Windows** (run 39614972492, smoke job 119273457148): every `cf-abi-*`
test passed against the MSVC-built fixture on both Tcl backends' runs.

## 3. MSVC linking, the C runtime, diagnostics

### 3.1 The link

The link plan of milestone 1 (`LinkerFlavor::Msvc`) is now exercised by
real links:

```text
-C link-arg=/LIBPATH:DIR     for each -L DIR
-C link-arg=NAME.lib         for each extern c library "NAME"
```

**Real Windows**: aot-facts `c-link-command` captures link.exe's command
line as rustc runs it (through `tests/platform/print-link-args.c` as
`RUSTC`, the Windows counterpart of the Unix wrapper script, which runs the
real rustc with `--print link-args`):

```text
"C:\Program Files\Microsoft Visual Studio\18\Enterprise\VC\Tools\MSVC\14.51.36231\bin\HostX64\x64\link.exe" "/NOLOGO" ...
```

with `botlish_aot_facts.lib`, `/LIBPATH:` the library's directory (a path
with a space), no `--start-group`, and `/NODEFAULTLIB:msvcrt.lib`,
`ucrt.lib`, `vcruntime.lib` among the runtime exclusions.

### 3.2 Static libraries and DLLs

**Real Windows**:

* aot-facts `c-library`: cl compiles `bcfx_widen`, lib archives
  `botlish_aot_facts.lib`; the COFF object defines `bcfx_widen` undecorated.
* `c-call-run`: a program calling it and the C library's `labs` links and
  runs standalone from another directory, PATH reduced to System32:
  `[42, -34458]` (narrow signed and unsigned arguments, a `named` symbol;
  `long` 32 bits).
* `c-call-import`: `labs` is imported from no DLL -- it is the static C
  runtime's, linked into the executable -- and the executable imports no C
  runtime DLL.
* c-ffi.test's `cf-shared-library`: a DLL built by `cl /LD`, linked through
  its import library `NAME.lib`, loaded from PATH at run time by both native
  backends' linked runs and a standalone executable; without the file the
  executable does not start.
* `cf-link-directories`: a `-L` directory with spaces, two at once, a
  missing one beside a present one, a relative one main.tcl resolves.
* `cf-system-symbol-resolved-windows`: a kernel32 function is imported from
  `KERNEL32.dll`, `labs` from no DLL, and no C runtime DLL is imported.

### 3.3 The C runtime

**The policy.** Every Windows executable Botlish links -- one that calls C
too -- links the **static release C runtime** (`+crt-static`: libcmt,
libvcruntime, the static UCRT) and **excludes every other Microsoft runtime
library** (`/NODEFAULTLIB:` for msvcrt, msvcrtd, vcruntime, vcruntimed,
ucrt, ucrtd, libcmtd, libvcruntimed, libucrtd, msvcprt, msvcprtd,
libcpmtd: `OTHER_MSVC_RUNTIMES`). So:

* an executable holds one C runtime and imports only the system's DLLs: it
  runs on a Windows without the Visual C++ redistributable, C calls or not;
* a static C library must be compiled for the static runtime, `/MT` --
  cl's default;
* a DLL keeps the runtime it was linked with, behind its own exports, as
  every Windows DLL does.

Milestone 1 linked the dynamic runtime for a program that calls C, so that
a `/MD` library would link. That was a placeholder decided before any C
call ran on Windows. It is replaced because the dynamic runtime makes every
C-calling executable depend on `VCRUNTIME140.dll` -- the hello world of
section 5 included, which calls only kernel32 -- and because a library's
default-library directive (`/DEFAULTLIB:MSVCRT` or `LIBCMT`) beside
another runtime gives link.exe two C runtimes, which it links with a
warning (LNK4098), each with its own heap, errno and stdio state.

**The matrix, measured** (real Windows, aot-facts `crt-*`; each library
calls snprintf, malloc, strlen, strtol and free):

| library | result |
|---|---|
| static, `/MT` | links, runs (1238), the executable imports no C runtime DLL |
| static, `/MD` | **does not link**: link.exe resolves the `__imp_` imports of runtime functions something else already linked (LNK4217: `malloc`, `free`, `__stdio_common_vsprintf` from libucrt.lib) and refuses the others (LNK2019: unresolved external symbol `__imp_strtol`) -- NATIVE LINK, with the driver's explanation (section 3.4) |
| DLL, `/MT` | links through its import library, runs; neither the executable nor the DLL imports a C runtime DLL |
| DLL, `/MD` | links, runs; the executable imports no C runtime DLL, the DLL imports `VCRUNTIME140.dll` and the UCRT's API sets (`api-ms-win-crt-*`): it needs the redistributable where it runs |

So the one combination the policy refuses is a `/MD` static library, and it
is refused loudly, by link.exe, never linked with a second runtime. Whether
such a library links at all depends on which runtime functions the rest of
the program happens to pull in (the `__imp_` references link.exe resolves
itself are exactly those); the policy does not rely on it.

### 3.4 Diagnostics

`linker_diagnostics` keeps link.exe's `error LNK` and `warning LNK` lines,
as milestone 1 made it; NATIVE LINK quotes them after its own first line.
**Real Windows**, from aot-facts and c-ffi.test:

```text
native link failed: the system linker could not link this program with the C functions and libraries it declares (libraries botlish_aot_facts_missing.lib):
error: linking with `link.exe` failed: exit code: 1181
= note: LINK : fatal error LNK1181: cannot open input file 'botlish_aot_facts_missing.lib'
```

```text
native link failed: ... (symbols botlish_aot_facts_nope; libraries botlish_aot_facts.lib):
error: linking with `link.exe` failed: exit code: 1120
= note: program.o : error LNK2001: unresolved external symbol botlish_aot_facts_nope
...executable.exe : fatal error LNK1120: 1 unresolved externals
```

An undefined C symbol is LNK2001 (the reference is in the program's object,
not a library member's), not LNK2019 as the unit test had assumed; the
tests accept either.

A `/MD` library's unresolved `__imp_NAME` is the one failure whose cause is
not in the linker's words, so NATIVE LINK adds a line (`link_hint`,
link.exe only):

```text
an unresolved __imp_ symbol is a reference compiled to be imported from a DLL: a C library compiled for the dynamic C runtime (cl /MD) refers to the runtime's functions so, and a Botlish executable links the static C runtime (/MT, cl's default) and no other: compile the library with /MT, or, for a function a DLL exports, link the DLL's import library
```

## 4. Linked-run argv

A program that calls C runs on the native backends as an executable the
driver links for the run (C-FFI.md), started with the run's argument
snapshot. On Unix the snapshot's bytes are the process's vector, argument
zero included (`CommandExt::arg0`). A Windows process receives one command
line, and `std::process` writes it with the executable's path as argument
zero, so milestone 1 refused a linked run on Windows outright.

`native/src/launch.rs` writes the command line itself:

* each snapshot argument decoded from WTF-8 to UTF-16
  (`runtime::aot::utf16_from_wtf8`: a valid UTF-8 argument to its UTF-16,
  an unpaired surrogate's three-byte form to that surrogate);
* argument zero between quotes: the C runtime reads it with no escapes, so
  it may hold anything but a quotation mark;
* every other argument between quotes, a quotation mark as `\"`, the
  backslashes before one or before the closing quote doubled (2n+1 and 2n);
* started with `CreateProcessW`, the executable named separately
  (`lpApplicationName`): no shell, no PATH search, nothing joined naively;
  the standard handles passed as inheritable duplicates
  (`STARTF_USESTDHANDLES`), a missing one as it is; the run's environment
  variables set in the driver's own environment first.

A snapshot no Windows process can receive is refused before anything runs,
`NATIVE UNSUPPORTED foreign`, naming the argument: bytes that are no WTF-8,
a NUL, a quotation mark in argument zero, a line over 32767 UTF-16 units.
The empty snapshot is refused on every host (a process has an argument
zero).

**Controlled experiment** (Rust, every host):
`launch_command_line_round_trips_through_the_runtimes_split` writes
command lines for vectors of spaces, tabs, quotes, backslash runs before
quotes and at the end, empty arguments, a UNC path, astral scalars and
unpaired surrogates, and splits each with a transcription of Rust's own
Windows splitter: every vector comes back. `launch_refuses_...` checks the
refusals; `argv_windows_wtf8_decodes_back_to_its_units` the encoding's
round trip.

**Real Windows** (argv.test, run 39614972492):

| test | shows |
|---|---|
| `argv-linked-run-same-values-as-in-process` | thirteen arguments (argument zero `C:\dir with space\prog`, the empty argument, spaces, a tab, quotes, backslashes before a quote and at the end, a UNC-like path, `%PATH%`, NFC and NFD, BMP and astral scalars): both native backends' linked runs read exactly what an in-process run of the same snapshot reads; the same under GC stress |
| `argv-linked-run-one-argument` | argument zero alone; two hundred arguments |
| `argv-linked-run-unpaired-surrogate-is-the-declared-error` | an unpaired surrogate reaches the program and fails `argv()` with InvalidArgumentEncoding, as in-process |
| `argv-linked-run-empty-vector-refused` | NATIVE UNSUPPORTED foreign |
| `argv-linked-run-windows-refusals` | invalid WTF-8 and a quote in argument zero refused, naming the argument |
| `argv-linked-run-same-as-standalone` | the same program built standalone and started by Tcl's exec reads the same arguments as its linked run given that argument zero |

Milestone 1's `argv-windows-*` tests (standalone executables) still pass.

## 5. Windows IO

### 5.1 The platform namespace

`core::cabi`'s `platforms` designates `windows` the Windows platform's: an
import of `windows` or anything under it compiles for windows-x86_64 and
windows-x86_64-gnu (a Windows target too) and is UNSUPPORTED-PLATFORM for
every Linux and macOS target, naming the root. A namespace merely named like
an operating system (`win32`, `macos`) is no platform's
(`tm-os-named-module-is-no-platform`).

### 5.2 lib/windows.bot

An ordinary module of three `extern c fn`s, by their documented prototypes
for LLP64, linked through `extern c library "kernel32"`:

```botlish
extern c fn c_get_std_handle named "GetStdHandle"(which: ffi::c::ULong) -> ffi::c::Ptr[ffi::c::Void]
extern c fn c_write_file named "WriteFile"(file: ffi::c::Ptr[ffi::c::Void] noescape, buffer: ffi::c::Ptr[ffi::c::Void] read noescape, count: ffi::c::ULong, written: ffi::c::Ptr[ffi::c::Void] write noescape, overlapped: ffi::c::Ptr[ffi::c::Void] noescape) -> ffi::c::Int
extern c fn c_get_last_error named "GetLastError"() -> ffi::c::ULong
```

* A HANDLE is `void *`: an `ffi::c::Ptr[ffi::c::Void]`, never an integer or
  a descriptor. A DWORD is `ffi::c::ULong` (32 bits on LLP64), BOOL
  `ffi::c::Int`.
* The buffer is `read noescape` (exposed as it is); its count is derived
  from the one value (no count parameter a caller could get wrong); the
  DWORD WriteFile writes its count into is a 4-byte MutableBytes, `write
  noescape`, read back by a one-field layout. A DWORD holds at most
  4294967295, so a larger Bytes is asked for in part: a short write by
  construction (`request`).
* `write_file` is one WriteFile, synchronous (no OVERLAPPED), and a
  `WriteResult {ok, count, last_error}`: WriteFile's BOOL, the count it
  reported, and the last-error code a failed call left, read with
  GetLastError **right after** the call. Between the two runs only the
  write-back value of the count's exposure (two small allocations) and the
  BOOL's test (`wi-last-error-read-first` pins the NIR); the allocator and
  the collector make no Win32 call that sets the last-error code. The code
  is never folded into the count, and never read after a success.
* `standard_handle` is GetStdHandle as it is now (SetStdHandle may change
  it). NULL (the process has no handle for the device) is told apart with
  `null?`; INVALID_HANDLE_VALUE is a pointer Botlish cannot compare with (a
  C pointer has no equality) and is left to WriteFile, which refuses it.
* Every pointer parameter is noescape, so no call retains anything: the
  module is ordinary, not `direct` (`wi-authority`).

### 5.3 lib/windows/io.bot: WindowsIO

`opaque context struct WindowsIO` holds the process's standard output and
error **devices**, never a handle: a handle is the process's slot, read
when a write needs it, and a C pointer cannot live in a context anyway (an
installed context is erased: AFFINE-ERASURE-UNSUPPORTED, which
`wi-context-holds-devices` pins). So every write uses the handle the
process has at that moment -- a console, a file or a pipe -- and nothing is
opened, duplicated or closed.

* `write(data)`, `write_error(data)`: one WriteFile, the raw result.
* `write_text`, `write_error_text`: io::IO's operations, by structural
  satisfaction from their own module (CONTEXT-TRAITS.md): a call of
  `io::print_line` with WindowsIO installed is a direct call of
  `windows::io::write_text`, no dispatch, no hidden argument
  (`wi-same-function-two-platforms`).
* The completion policy is LinuxIO's and DarwinIO's: all of the text or
  io::WriteFailed. A short write is completed by writing the rest; a
  failure (whatever its code: no retry), a write that makes no progress and
  a device with no handle are io::WriteFailed. No count, handle or code
  escapes.
* The bytes are the text's UTF-8, exactly: no UTF-16 conversion, no
  console code page, no CRLF translation. A redirected output receives the
  program's bytes; a console shows them through its output code page
  (section 8).
* Borrowed handles: nothing in the module closes one; there is no
  CloseHandle.

### 5.4 Real programs

examples/io/hello-windows.bot, and examples/games/2048/demo-windows.bot
(demo.bot's game, demo_play.bot, with WindowsIO installed). **Real
Windows** (the workflow's "Windows I/O" step): main.tcl
`-emit-native-executable` builds both; hello's output is byte-compared with
`Hello, world!\nunit\n` written to a file by bash, through a pipe, through
cmd's `>` redirection and through PowerShell's
`Start-Process -RedirectStandardOutput`; stderr is empty; the demo writes
the same 851 bytes, 37 lines, into a file and, under GC stress, through a
pipe; workload-2048.test's `workload-2048-demo-windows-executable` compares
them with the Linux demo's game and runs it through main.tcl on both native
backends.

### 5.5 Tests

windows-io.test has two halves. **Every host** (front end): the platform
rule and its every route (interchange, NATIVE TARGET), the C declarations
and their contracts, the last-error read, the DWORD request, the context's
contents and selection (MISSING-CONTEXT, AMBIGUOUS-CONTEXT-IMPLEMENTATION),
authority, the Tcl backends' NATIVE-ONLY, the C-free parts on the Tcl
backends, and a compile of every Windows execution program. **Windows**
(`windowsIO`), each a real process writing to a real file or pipe:

| test | shows |
|---|---|
| `wi-hello-executable` | moved, source deleted, empty PATH: exactly `Hello, world!\nunit\n`, nothing on stderr, the same under GC stress; imports KERNEL32.dll and no C runtime DLL |
| `wi-routing-utf8` | print, print_line, write_error, write_error_line to the right streams; é two bytes, 𝄞 four, LF one byte |
| `wi-text-edges` | the empty String writes nothing; CR LF and a tab pass as bytes; an empty line is one LF |
| `wi-pipes` | through a pipe Tcl's exec reads; 256 KiB through a pipe read 4 KiB at a time, in order |
| `wi-large-write` | 1 MiB in one print, byte for byte |
| `wi-repeated-writes` | 2000 print_lines are 2000 WriteFiles of a whole line |
| `wi-short-write-completed` | short writes completed (5 then 9; 3, 4, 2, then 5), also under GC stress |
| `wi-write-failures` | WriteFile's failure with 5, 232 and 109, and no progress, are io::WriteFailed, not retried; after a short write too |
| `wi-stderr-short-and-failed` | the same for standard error |
| `wi-raw-results` | the raw layer: a count, a short count (7 of 14), FALSE with the exact code (5, 232) |
| `wi-steady-completion` | 256 KiB in 64 WriteFiles of at most 4 KiB |
| `wi-real-failures` | Windows' own refusals (section 5.6) |
| `wi-borrowed-handles` | no CloseHandle names a standard handle; output before and after a failure reaches the same handle |
| `wi-native-backends` | both native backends' linked runs; main.tcl passes the output through before its value line |
| `wi-gc-stress` | the same bytes under a collection at every allocation |

Windows does not fail a synchronous WriteFile on demand -- to a file, a
console or a pipe it writes everything or fails -- so short writes and
chosen failures come from `tests/cffi/writefile-inject.c`, a static library
linked into the test program. Called first (`bcfw_install`), it rewrites
the program's own import address table: every slot importing WriteFile goes
to the injector, which follows a plan (`BCFW_PLAN`: write at most N bytes,
write nothing, or fail with a last-error code) and otherwise calls the real
WriteFile, and logs every call (`BCFW_LOG`); the CloseHandle slots count the
calls that would close a standard handle. The program calls the real
kernel32 symbol; nothing in Botlish knows the injector exists. It is the
counterpart of Linux's `strace -e inject=write` and macOS's dyld interposer
(tests/cffi/write-inject.c). The program's value goes to the driver
protocol's result file (`BOTLISH_NATIVE_RESULT`), so a broken standard
output does not hide it.

### 5.6 Windows' own refusals

`tests/cffi/win-launch.c` starts a program with a standard output Windows
refuses to write, in a process of its own. **Real Windows**
(`wi-real-failures`): a portable print and then a raw write of the same
program, under each mode:

| standard output | portable print | raw WriteFile | `null?` |
|---|---|---|---|
| inherited (control) | writes | `[true, 3, 0]` | false |
| a file opened read-only | io::WriteFailed | FALSE, `ERROR_ACCESS_DENIED` (5) | false |
| a pipe whose read end is closed | io::WriteFailed | FALSE, `ERROR_NO_DATA` (232) | false |
| NULL (no handle) | io::WriteFailed, before any WriteFile | FALSE, `ERROR_INVALID_HANDLE` (6) | true |
| INVALID_HANDLE_VALUE | io::WriteFailed | FALSE, `ERROR_INVALID_HANDLE` (6) | false |

## 6. GC and borrowing

Nothing in the collector changed. A C call on Windows is lowered exactly
as elsewhere: the arguments are evaluated, the exposures made after them
and kept alive by a `keepalive` after the call; every root live across the
call is in the shadow stack (Windows' fallback plan, milestone 1); a C
function cannot allocate Botlish memory, so no collection happens inside it.
The write-back values (the count's MutableBytes, WriteResult) are built
after the call, where a collection may happen, and hold no pointer of C's.

**Real Windows**:

* c-ffi.test's `cf-gc-calls`: C calls inside allocation-heavy loops under
  GC stress, on both backends and in an executable;
* c-byte-borrowing.test's stress tests: read and write exposures to the
  fixture and the C library under a collection at every allocation;
* windows-io.test's `wi-gc-stress`, `wi-hello-executable` and
  `wi-short-write-completed` under GC stress: the same bytes and the same
  WriteFile sequences;
* `tests/platform/gc-workloads.tcl -repeat 5`: 133 runs, 0 failed;
* the native-status probe `c-byte-borrow` (memcmp reading two exposures,
  memset writing a private copy; `size_t` declared `ULongLong`, its width on
  LLP64 as on LP64).

## 7. Tests and CI

### 7.1 The workflow

`.github/workflows/windows-x86_64.yml`, extended (no new workflow):

* **Native objects and executables** (aot-facts.tcl): milestone 1's COFF
  and PE checks, then C calls with MSVC's cl and lib, link.exe's command
  line, LNK1181 and LNK2001/LNK1120, and the C runtime matrix.
* **Windows I/O** (new step): hello and the 2048 demo as executables, into
  files and pipes, through bash, cmd and PowerShell (section 5.4).
* **Native status**: C calls and byte exposure run, Windows I/O runs, a
  variadic call is NATIVE CODEGEN (new probes `windows-write`,
  `windows-io`, `windows-executable`, `c-variadic`).
* **Smoke tier and the Windows-relevant test files**: c-ffi.test,
  windows-io.test, c-byte-borrowing.test and c-float-ffi.test join argv,
  targets, executables, the command line, applications, the 2048 workload,
  native.test and c-abi-types.
* **Acceptance** (four shards): every Tcl test file on interp, now with C
  calls, so every C FFI and native layout test file runs its native tests
  against MSVC-built fixtures.

### 7.2 Commands

```sh
tclsh9.0 tests/windows-io.test           # front end everywhere; execution on Windows
tclsh9.0 tests/argv.test -match 'argv-linked-run-*'
tclsh9.0 tests/c-ffi.test
tclsh9.0 tests/platform/native-status.tcl -verbose 1
tclsh9.0 tests/platform/aot-facts.tcl -verbose 1
tclsh9.0 tests/platform/tier.tcl smoke windows-io.test c-ffi.test
tclsh9.0 tests/platform/tier.tcl windows-io-mutants   # Windows I/O's mutants
cargo test --release --manifest-path native/Cargo.toml --lib --bins
```

### 7.3 Results on Windows

PENDING

### 7.4 Linux and macOS

PENDING

### 7.5 Mutants

PENDING

## 8. Remaining limitations

Refused on Windows, each with its own error:

| Capability | Today on windows-x86_64 | Owner |
|---|---|---|
| variadic C calls | `NATIVE CODEGEN` ("no variadic call lowering for the windows_fastcall convention") | Win64 variadics (section 9) |
| a static C library compiled for `/MD` | `NATIVE LINK`, link.exe's LNK2019 `__imp_NAME` with the driver's explanation | by policy (section 3.3); compile it `/MT` |
| native coroutines | `NATIVE UNSUPPORTED value` | a coroutine milestone (milestone 1, section 8) |
| stack guard | none (milestone 1) | the vectored-exception guard |
| native-frame GC roots | the fallback plan (shadow stack) | unwind metadata |
| a linked run of a snapshot no Windows process can receive | `NATIVE UNSUPPORTED foreign` (section 4) | by design |

Known limits:

* **The console.** WindowsIO writes UTF-8 bytes. Redirected to a file or a
  pipe they are exact (section 5). A console window shows them through its
  output code page: with the console's default OEM code page (437, 850)
  text beyond ASCII is shown wrongly, with code page 65001 (`chcp 65001`)
  correctly. Botlish neither switches the code page (a process-wide
  setting the user chose) nor converts to UTF-16 for `WriteConsoleW`. A CI
  runner's output is never a console, so nothing here observed a console
  window: what one shows is stated from the documented behaviour, not
  measured.
* **Only output.** No standard input, files, process exit status,
  overlapped I/O or console modes on Windows (the brief's exclusions).
* **INVALID_HANDLE_VALUE** is not told apart before WriteFile: a C pointer
  has no equality in Botlish, so WriteFile's ERROR_INVALID_HANDLE reports it
  (`wi-real-failures`).
* **The driver sets its own environment for a linked run** on Windows
  (`set_var` before `CreateProcessW`), sound because the driver is
  single-threaded there and exits after the run.
* **C test fixtures need MSVC.** The tests build their C side with
  vswhere's Visual Studio (tests/ctoolchain.tcl); without it the fixture
  tests are skipped, never failed. The Tcl library and BoringSSL acceptance
  tests are skipped on Windows (`tclLibrary`, `boringssl`: no Windows build
  of either is set up), as are the generated-binding runs (the C binding
  generator's fixture has no MSVC target: `fixtureHostBinding`).
* **Windows I/O's `%% windows-x86_64` mutants** (six of the thirteen) are
  killed only by Windows runs (section 7.5); the tier item
  `windows-io-mutants` runs them on a Windows runner.
* **The golden suites run on the Tcl backends only** on Windows, as in
  milestone 1 (their runner is a coroutine).
* **rustc must match** the driver's own, as on every host (milestone 1).

## 9. Next milestones

Independent slices, in the order they make Windows programs more useful:

1. **Win64 variadic C calls.** Win64 passes a variadic floating argument
   in both its integer and its floating register (and the callee spills the
   four registers to the shadow space). A per-call signature that states it
   (`c_call_signature`), checked against MSVC's own calls of printf-shaped
   fixtures the way `cf-va-*` checks System V and Apple, then
   `nativeCVariadics` for windows-x86_64.
2. **Windows input and files** behind portable contexts: ReadFile on the
   standard input handle, then CreateFileW/ReadFile/WriteFile/CloseHandle
   for files, whose handles a context *owns* (unlike the borrowed standard
   handles here), with paths as UTF-16 (`windows::path`).
3. **A console-aware text path**: WriteConsoleW for a handle that is a
   console (GetConsoleMode), UTF-8 everywhere else, decided per handle.
4. **Unwind metadata** (`.pdata`/`.xdata`, `RtlVirtualUnwind`): native-frame
   GC roots on Windows, then the vectored-exception stack guard and Win64
   coroutines (milestone 1, section 9).
5. **MSVC bindings** from the C binding generator (the Windows SDK's
   headers with clang's MSVC target), beside the committed MinGW one.
