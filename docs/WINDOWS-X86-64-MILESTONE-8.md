# WINDOWS-X86-64-MILESTONE-8.md

Milestone 8 of the Windows x86-64 port: native libraries as Windows DLLs.
A Botlish program compiled by `native::library` (`main.tcl
-emit-native-library NAME`) becomes, on Windows x86-64 with MSVC's
toolchain, a DLL and its import library that an ordinary C or C++ program
loads with `LoadLibraryW` and `GetProcAddress` or links through the import
library -- with the C ABI, the lifecycle, the errors and the ownership
rules of NATIVE-LIBRARY-MILESTONE-1.md unchanged. The milestones before it
are WINDOWS-X86-64-MILESTONE-1.md (the driver, executables) to
WINDOWS-X86-64-MILESTONE-7.md (paths and files); the native library facility
it extends is NATIVE-LIBRARY-MILESTONE-1.md's. The work was developed on
Linux.

> A Botlish library can enter a Windows process it does not own, execute
> under its declared contract, maintain its own runtime and resources, and
> leave the host's execution environment intact.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (Visual Studio 2022's
  x64 tools, link.exe, cl, dumpbin) through
  `.github/workflows/windows-library-probe.yml` (the COFF/linker census) or
  `.github/workflows/windows-x86_64.yml` (the production path and its
  tests), run named;
* **real Linux**: observed in this repository's Linux x86-64 container and in
  Linux CI;
* **cross-built**: a Windows object or the Windows runtime archive built on
  Linux (Cranelift's `--target x86_64-pc-windows-msvc`; `cargo build
  --target x86_64-pc-windows-msvc -p botlish-runtime`, which links nothing)
  and read with LLVM's tools -- never run;
* **code inspection**: what the code does, read, not run.

No Wine and no WSL were used. Commits are on the branch
`ccr-1df6df44-mpq9ii`, where every CI run below ran.

## Contents

1. Result
2. Starting state
3. The COFF/linker census
4. Artifacts
5. The C ABI
6. Export roots
7. Initialization and the loader lock
8. The runtime boundary: threads, reentrancy, stacks
9. GC and unwinding
10. Coroutines inside exported calls
11. The C runtime, ownership and unloading
12. Several libraries in one process
13. Static COFF libraries: why none is shipped
14. Toolchain and diagnostics
15. Tests, fuzzing, mutation testing
16. Performance and size
17. CI
18. Remaining limitations
19. Files changed, and what to run

## 1. Result

PENDING-RESULT

## 2. Starting state

* **Native libraries** (NATIVE-LIBRARY-MILESTONE-1.md) were made on Linux
  glibc only. The driver writes a *library program object* -- the program's
  machine code, its descriptor and `LinkedProgram` record with local
  symbols, and the public C functions, Cranelift-written forwarders and
  trampolines over `runtime::library` -- and `native::library` (Tcl) linked
  it with GNU binutils: `ld -r` with the runtime archive, `objcopy
  --keep-global-symbols` leaving exactly the public names global, `ar`, and
  `cc -shared`. Two libraries in one process share nothing because each
  carries a private runtime copy whose every symbol is local.
* **The Windows port** (milestones 1 to 7) runs native code, links
  executables with link.exe (rustc's linker by default; the system linker
  from a Developer environment), calls C under the Win64 convention, keeps
  GC roots in native frames walked with Windows' unwinder across Rust
  frames, has unwind information for every Botlish function (encoded by
  `codegen::unwind`), a stack guard, coroutines on Windows fibers and the
  static release C runtime in every executable. `codegen::library::
  SUPPORTED`, `native::capabilities`' `libraries` and the driver's `library`
  command all refused Windows.

What this milestone could reuse unchanged: the program object (Cranelift
writes COFF for the Windows target), the descriptor and record, the
runtime's library ABI (`runtime::library`), the export roots, the frame
walk with its ceiling, the library-mode stack check, the system linker's
tool discovery, runtime archive, system libraries and CRT policy. What it
had to add or fix is the rest of this report.

## 3. The COFF/linker census

`audit/windows-library/probe.tcl` (the `windows library probe` workflow)
builds two libraries, `one` and `two`, from two programs that both define
an error `Negative` and export `twice` and `tag`, and records what MSVC's
tools do with them. It is evidence, not a test: it prints every row and
fails only when it cannot run. Runs 42919823801 and 42933890368 (the
second with E1's TLS directory, E5's output and E6's response file;
windows-2025, image
windows-2025-vs2026 20261103.298.1, Windows Server 2025 10.0.26100, rustc
1.99.1, the runtime archive `botlish_runtime.lib` 22,502,940 bytes):

| Experiment | Result |
|---|---|
| E1, the production path (`native::library`: `botlish-native library-dll`, a module-definition file, `link.exe /DLL`) | `one.dll` 592,896 bytes and `one.lib` 4,950 bytes in 2.5 s (the first build, cold); `two.dll` 614,400 bytes in 0.9 s. Each exports 17 names, exactly its public functions. Imports: `kernel32.dll`, `api-ms-win-core-synch-l1-2-0.dll`, `ntdll.dll`, `bcryptprimitives.dll`, and `KERNEL32.dll` again (the C runtime's import, through kernel32.lib, beside the standard library's raw-dylib one). No TLS callback. DLL characteristics 0x160 (dynamic base, NX compatible, high-entropy addresses); stack reserve 1 MiB (the host's matters, not the DLL's). |
| E1, a host's `GetProcAddress` | all 17 public names found; none of 11 internal ones (`botlish_library_call`, `botlish_library_create`, `botlish_program`, `botlish_fn_0`, `botlish_entry_0`, `rt_fail_declared`, `rust_begin_unwind`, `main`, `DllMain`, ...) |
| E2, `/EXPORT:` options instead of the .def file | the same 17 names; the export directory names the output file (`e2.dll`). The .def file is kept: one input states the library's name and its exports, and link.exe checks it |
| E3, neither | 0 exports, no import library: no input exports anything by itself; the program object has no `/EXPORT` directive |
| E4, `lib /DEF` alone | an import library whose import objects equal link.exe's |
| E5, static libraries (each program object merged with the runtime archive by `lib.exe`: 22.5 MB each) | one alone in an executable works (`twice: 42`); **both in one executable link with no error at all** (0 LNK2005) and run: `twice: 42 63`, and a buffer of one library released through the other is *accepted* -- one runtime copy answers for both; with `/FORCE:MULTIPLE` the same (0 LNK4006) |
| E6, the candidate: each library's private symbols renamed (`llvm-objcopy --redefine-syms`), the objects archived again | 4,965 defined symbols renamed in 1,879 objects per library, 0 failures, about 5 minutes per library; the renamed archives (23.2 MB each) built through a response file; both in one executable: 0 LNK2005, but 4 unresolved externals (LNK2019), so the link fails |

E5 is the decisive row, and stronger than expected: two static Botlish
libraries in one executable are not refused by the linker. `lib.exe`
archives are searched member by member, a member is pulled once, so the
second library's program object binds to the members the first library's
references already pulled: one runtime silently serves both, by link
order -- exactly what the brief forbids (section 13).

## 4. Artifacts

```sh
tclsh9.0 main.tcl -emit-native-library example -out output example.bot
```

from a Developer Command Prompt (or after `vcvars64.bat`; section 14)
writes

```text
output/
    example.dll            the library: the program and a private runtime;
                           exports exactly the public C functions
    example.lib            the DLL's import library (link.exe's /IMPLIB)
    example.h              the C interface
    example.manifest.json  the interface as data
```

and prints `shared:`, `import:`, `header:` and `manifest:` lines. No
static library is made on Windows (section 13): `-shared 0`, which asks for
a static library only, is refused (`NATIVE UNSUPPORTED library`), and the
import library is no static copy of the implementation -- it holds 2 + N
short import objects naming `example.dll` and three COFF members link.exe
writes (the import descriptor, the null descriptor and the thunk terminator;
`native::pe::importLibrary` reads them).

**How it is made** (`native::library`'s Windows branch, `botlish-native
library-dll`, `codegen::aot::link_windows_library`):

```text
Botlish source
  -> front end, export records      (unchanged)
  -> native::nir -exports           (unchanged)
  -> botlish-native library-dll DIR NAME FILE.nir
       the library program object   (codegen::emit_library_object:
                                     COFF, the record local, the public
                                     functions global, unwind information
                                     for every function, the public ones
                                     included)
       NAME.def                     LIBRARY NAME.dll / EXPORTS, one line
                                    per public function
       link.exe /DLL /DEF:NAME.def /IMPLIB:NAME.lib /OUT:NAME.dll
                /MACHINE:X64 /INCREMENTAL:NO /OPT:REF /OPT:ICF
                /NXCOMPAT /DYNAMICBASE /Brepro
                NAME.program.obj [the program's link plan]
                botlish_runtime.lib legacy_stdio_definitions.lib
                kernel32.lib ntdll.lib userenv.lib ws2_32.lib dbghelp.lib
                libcmt.lib libvcruntime.lib libucrt.lib
                /NODEFAULTLIB:(every other Microsoft runtime)
  -> native::library::ValidateDll   both files read from their bytes
                                    (native/pe.tcl); removed on a failure
  -> NAME.h, NAME.manifest.json     (Tcl, from the export records)
```

The link runs in a private directory beside the outputs and publishes the
two files by rename only when both were made; `native::library` deletes the
previous build's DLL, import library and manifest first, so a failed build
never leaves another build's files under the new names. `/Brepro` makes the
time stamps link.exe writes (the PE header's, the export directory's, the
import library's members') a hash of the contents, not the link's time:
two builds of one library are the same bytes, as on Linux, so the
manifest's digests are the library's (`nl-manifest` builds twice and
compares; without `/Brepro` the first MSVC run's two manifests differed).

**The header** is the Linux header with two Windows additions: a paragraph
of the contract (loading, `LoadLibraryW`/`GetProcAddress`, no Botlish code
at load, the DLL's own C runtime, the unloading precondition), and every
function declared `NAME_API`, which is `__declspec(dllimport)` unless the
host defines it first. The C signatures are the same bytes. It compiles as C
(`/std:c11`) and C++ (`/std:c++17`) at `/W4 /WX` (`nl-windows-cxx-host`).

**The manifest** stays schema 2, additively and target-aware
(`library::Manifest`): on Windows `artifacts` is `{static: null, shared:
"NAME.dll", import: "NAME.lib", header}`, `sha256` the same keys (certutil's
digests, `library::Sha256`), `link` is empty (a consumer links the import
library, which `artifacts` names; the DLL holds its system libraries and C
runtime), and `lifecycle` gains `unload`, the unloading precondition. A
Linux manifest is byte for byte what it was: no `import` member, no
`unload`. `pm::tools::Artifact` checks the `import` file's digest where
there is one.

## 5. The C ABI

Unchanged, and the same code: the trampolines and forwarders
(`codegen::library::define`) are written in the module's target C
convention, which for `x86_64-pc-windows-msvc` is Cranelift's
`windows_fastcall`; the runtime half (`runtime::library`) is the same Rust.
The types (int64_t, bool, double, UTF-8 pointer and length in, an owned
`NAME_bytes` out, unit), the statuses (OK, DECLARED, RUNTIME, BOUNDARY,
INVOCATION, INTERNAL), the error objects and their accessors, the
out-parameters, the release functions: every Linux test of them runs on
Windows from MSVC-built hosts with the same expected output (section 15).

A trampoline as Cranelift writes it for Windows (cross-built, disassembled
with llvm-objdump), `chk_checked(instance, int64_t n, double x, bool b,
const uint8_t *s, size_t s_len, int64_t *out, chk_error **error)`:

```text
pushq %rbp; movq %rsp, %rbp; subq $0x80, %rsp
movq %rbx, 0x60(%rsp); movq %rsi, 0x68(%rsp); movq %rdi, 0x70(%rsp)   saves
movq %rcx, %rbx                       instance         (position 1: RCX)
movq 0x30(%rbp), %rsi                 s                (position 5: stack, past the shadow space)
movq 0x38(%rbp), %rdi                 s_len            (6)
movq 0x40(%rbp), %r10                 out              (7)
movq 0x48(%rbp), %r11                 error            (8)
movq %rdx, 0x30(%rsp)                 n -> word 0      (2: RDX)
movq %xmm2, %rcx; movq %rcx, 0x38(%rsp)   x -> word 1  (3: XMM2, by position)
movzbq %r9b, %rcx; movq %rcx, 0x40(%rsp)  b -> word 2  (4: R9, zero-extended)
...  botlish_library_call(record, instance, 0, words, out, error)
```

Win64's positional rule (a double in the third position travels in XMM2,
the fourth argument in R9 whatever its class, the fifth on the stack after
the 32-byte shadow space) is Cranelift's; Botlish asks only for the
signature. A `bool` is zero-extended from its low byte (`uextend`), never
read as a register's whole width. `nl-windows-win64-abi` calls an export of
eight parameters of all four classes (thirteen C positions) and one of six
doubles from C, and calls an export through `tests/cffi/nl-win64-probe.asm`,
an ml64 caller that holds a sentinel in every nonvolatile register (RBX,
RBP, RDI, RSI, R12 to R15, both halves of XMM6 to XMM15), places nine
arguments by hand and compares every one afterwards, on a success and on a
failure that allocates. On Windows (the first MSVC run, run 42922582948): `mix = 1015347`, `fsum = 18`, `sum6 = 91` and the failing `sum6(-3)`'s `Negative value=0`, every nonvolatile register as the caller left it on both calls, plainly and under GC stress.

Exports are fixed-prototype functions: nothing of the variadic call work
(WINDOWS-X86-64-MILESTONE-6.md) applies to them, and a host calls them with
no adapter of Botlish's.

## 6. Export roots

Nothing Windows-specific: an export is compiled for its declared contract
(`hir/specialize.tcl`'s `ProgramValues`), its generic instance kept by
fusion (`drop_unreferenced` starts at the exports), its trampoline calling
that instance's generic entry through the record's code table. The
reproductions run on Windows as on Linux: `nl-export-root-checked`
(`checked(-5)` fails with `Rejected code=-5` though the only Botlish caller
passes 1), `nl-export-root-token-count` (a 1,120-byte input gives 321 tokens,
the reference interpreter's count, though the only Botlish caller tokenizes
six characters), `nl-export-root-no-caller` (an export no Botlish code calls;
`add1(INT64_MAX)` is `RESULT-OUT-OF-RANGE`), `nl-export-imported-module`,
and `nl-abi-types`' declared errors (`Odd count=3 flag=true items=(other)
note="odd ä" ratio=0.5`). All of them pass on Windows (the first MSVC run, run 42922582948) as on Linux.

## 7. Initialization and the loader lock

There is no `DllMain` of Botlish's and no initializer of Botlish's. The
DLL's entry point is the static C runtime's `_DllMainCRTStartup` (libcmt),
which initializes the C runtime and calls the C runtime's own default
`DllMain`. `NAME_create`, called by the host after `LoadLibraryW` returned
(or at any time through the import library), is the one initialization
boundary: it reads the record, builds the Vm and runs the program's module
static initialization, exactly as on Linux.

What runs under the loader lock is what the DLL's initializer tables and
TLS directory hold, so that is what was checked:

* **The runtime archive** (botlish_runtime.lib: Botlish's runtime, the Rust
  standard library, every dependency) holds no `.CRT$XC*` or `.CRT$XI*`
  initializer (no static constructor) in any member. Built on the Windows
  runner (rustc 1.99.1) it has no `.CRT$` section at all; cross-built from
  Linux (1,826 members, 1,379 of them short import objects of the standard
  library's and windows-sys' raw-dylib imports) it has one, the standard
  library's `.CRT$XLB`, its TLS callback, which runs thread-local
  destructors when a thread or the process *detaches* and does nothing at
  attach. No member of the cross-built archive has a `.drectve` section (so
  none carries `/EXPORT` or `/DEFAULTLIB` directives); E3 shows the same of
  the Windows-built one by its effect (nothing exported without the .def
  file).
* **The program object** has no `.CRT$` section.
* **The DLL**: a TLS directory (the C runtime's, for the standard
  library's `#[thread_local]` statics) with no callback at all, in the
  census's DLLs (E1) and in `nl-windows-loader-lock`'s. Its
  entry point is link.exe's default for `/DLL` (no `/ENTRY` is given), the
  C runtime's `_DllMainCRTStartup`: it initializes the C runtime and calls
  `DllMain`, which is the C runtime's empty default -- neither the program
  object nor any member of the runtime archive defines or references a
  `DllMain` (llvm-nm over the cross-built archive).

`nl-windows-loader-lock` checks all three on every run (no initializer in
the program object or the archive, no more TLS callbacks than `.CRT$XL*`
sections in the archive, the C runtime's entry point), and the mutant
`loader-lock-initializer` (a `.CRT$XCU` initializer added to the runtime)
is killed by it. Section 11 has what runs at unload.

Initialization tests: `nl-lifecycle` (create, destroy, recreate, fifty
instances made and destroyed, destroyed, NULL and garbage handles refused),
`nl-two-instances`, `nl-windows-load-library` (three load-create-call-
destroy-unload cycles), and a failed creation frees the half-made instance
and leaves `*instance` NULL (unchanged code).

## 8. The runtime boundary: threads, reentrancy, stacks

**Thread affinity and reentrancy** are the unchanged registry checks
(`checkout`): an instance records the creating thread's Rust `ThreadId`,
which a thread the host created with `CreateThread` gets on its first
library call like any other. `nl-threads` (a call and a destroy from
another thread are `WRONG-THREAD`; four instances on four Windows threads
allocate at once), `nl-reentrant` (a call from inside a call of the same
instance, through a C function the export called, is `REENTRANT-CALL`;
another instance is fine) run on Windows from MSVC hosts. On Windows the C
function a library imports must come from a DLL or library it declares: a
DLL cannot import from the executable that loads it, so the tests' host
callback is `nlhost.dll`'s `host_callback`, forwarding to the function the
host registers (`nlHostCallback`) -- what a real Windows host does.

**Stack limits** are the library-mode check (NATIVE-LIBRARY-MILESTONE-1.md,
"Stack safety"), on Windows unchanged in code: `nir::check_stack_limit`
gives every function with a Botlish call a prologue comparison with
`Vm::stack_limit`; the limit is the running stack's low bound
(GetCurrentThreadStackLimits' DeallocationStack, below the guard page and
the reservation's uncommitted part) plus an eighth of the stack, between 64
KiB and 1 MiB. No stack guard is installed (the executable's vectored
handler would end the host), and Windows' stack probes still grow the stack
page by page. `nl-stack-safety` (the main thread's 1 MiB stack, threads of
512 KiB and 1 MiB reserved with `STACK_SIZE_PARAM_IS_A_RESERVATION`):
`depth(100000000)` is `NATIVE LIMIT STACK` and the instance answers
`depth(1000)` next; `nl-stack-safety-coroutine` (a coroutine's fiber stack
bounds recursion the 512 KiB thread's could not hold).

**Calls on a host's stack** -- found and fixed by this milestone, on every
host. A call made on a stack the instance did not make (a fiber the host
created, a `ucontext` stack) took no stack limit (`Vm::stack_limit_at`, by
design) -- but its collections walked the *thread's* stack bounds, which
hold none of the call's frames: the walk stopped at its first frame and
every root in the call's Botlish frames was missed. And after a coroutine
switched back to such a stack, `publish_active_stack(None)` gave the code
there the thread's limit. Both are fixed by `Vm::entry_stack`: `enter`
sets it to the stack the call entered on when that is not the thread's
(`entry_stack_at`: on Windows the running fiber's stack, from the thread
environment block SwitchToFiber keeps; elsewhere a stack unbounded below and
bounded above by the call's ceiling), the collector's walk of the running
stack and of a coroutine's resumer use it, and a switch back to it gives
the limit 0. `nl-stack-safety-foreign-stack` now runs coroutines and
allocates on the host's stack (a `ucontext` on Linux, a host fiber on
Windows): without the fix, its run under GC stress fails with `chain(300):
status 5 NATIVE BUG` on Linux (observed, real Linux); with it, `chain(300) =
600` plainly and under GC stress. The mutant `entry-stack-ignored` restores
the defect.

**What still ends the process**: a C function or a runtime helper
exhausting the stack's reserve by itself, and recursion past a host-made
stack's end (no limit applies there): Windows raises STATUS_STACK_OVERFLOW,
which no handler of the library's claims. A Windows structured exception in
Botlish code (an access violation in C it called) is the host's to handle;
the library catches none.

## 9. GC and unwinding

**The walk's ceiling** works as on Linux, by stack pointer: `enter` records
its own RSP (`framewalk::frame_record`), the collector's walk of the
thread's stack is bounded above by it (`Vm::stack_ceiling`), and the walk
(`framewalk::windows::walk_context`) stops at the first frame at or above
it. Host frames are never read. `nl-walk-boundary` (instance `first` holds a
MutableVector across a C call whose callback runs instance `second`, which
collects; a walk that climbed past `second`'s call would mark `first`'s
vector) returns 28 three times on Windows; the mutant `stack-ceiling-unset`
breaks it.

**Unwind information for the public functions.** Every Botlish function of a
Windows object had `.pdata`/`.xdata` (WINDOWS-X86-64-MILESTONE-3.md); a
library object's forwarders and trampolines, written by
`codegen::library::define`, had none -- and they have frames (`push rbp`,
a stack slot for the argument words, callee-saved registers). Windows'
unwinder takes a function without a function table entry for a leaf: an
exception dispatched through an export (a host's `__try` around the call, a
debugger's or a profiler's stack trace, `RtlCaptureStackBackTrace` in a
callback) would read a return address from the trampoline's frame. Now
`library::define` returns each public function's `UNWIND_INFO`
(`codegen::unwind`, from Cranelift's prologue description, as for every
Botlish function) and `add_windows_unwind` writes them beside the program's.
Cross-built evidence: a library object of one export has 20 `.pdata`
entries, 16 of them the public functions'. `nl-windows-unwind-through`
finds a function table entry for every public function's address
(`RtlLookupFunctionEntry`) and, inside a C callback Botlish code called,
takes a stack trace that crosses the Botlish frames, the runtime and the
trampoline back to the host function that called the export. On Windows (the first MSVC run, run 42922582948): an entry for each of the 16 public functions at its exact address, and the trace reaches the caller, plainly and under GC stress.
The mutant `public-unwind-dropped` removes the entries.

**Roots across C transitions and nested instances**: `nl-nested-libraries`
(library outer's export calls C, which calls library inner, then outer shows
an enum from its own program) and `nl-walk-boundary` run under
`BOTLISH_NATIVE_GC_STRESS=1` on Windows; every behavior test runs both
plainly and under GC stress and requires the same output (`nlRunBoth`).

## 10. Coroutines inside exported calls

An export may drive coroutines (on Windows, fibers:
WINDOWS-X86-64-MILESTONE-5.md); it never suspends across the C boundary
(EXPORT-ENVIRONMENT). Fibers need the calling thread to be a fiber too, and
the runtime made a thread one with `ConvertThreadToFiberEx` *once per
thread*, converting it back only when the thread ended. In an executable the
thread is the runtime's; in a DLL it is the host's, and leaving it converted
changes it: `ConvertThreadToFiber` fails on a thread that is already a fiber
(ERROR_ALREADY_FIBER), so a host that makes its own fibers after a library
call would break, and a thread that outlives an unloaded library would stay
converted. The narrow library-mode boundary (`runtime::library`'s
`CallDepth`, `coroutine::library_call_ended`,
`coroutine::windows::restore_thread`): at the end of the outermost call of
a library on a thread, a conversion the runtime made is undone
(`ConvertFiberToThread`, while the thread runs on that fiber, which the end
of a call guarantees), and the thread's state is forgotten, so the next
call asks again. A thread the host made a fiber is left as it is, and a
coroutine switches from and back to the host's fiber. Pooled fibers
survive a conversion's end (a fiber belongs to no thread state).

`nl-windows-fibers`: after a call that ran coroutines, a plain thread is no
fiber (and the host converts it afterwards); on the host's own fiber, the
call's coroutines run and the thread is still that fiber; on a fiber the
host created, the call runs there; after the host converts back, a call is
again on a plain thread. All as stated on Windows (the first MSVC run, run 42922582948). `nl-coroutine-inside` (201 calls
driving a recursive yielding function on the general runtime, under GC
stress) and `nl-stack-safety-coroutine` run on Windows. The mutant
`fiber-left-converted` removes the restore.

**Coroutine stacks and unloading.** The runtime pools coroutine stacks per
thread (32 at most), and frees the pool when the thread ends. A host may
unload a library while threads that used it live on -- and once the
library is unloaded its thread-local destructors never run, so those
threads' pooled stacks (on Windows, fibers of up to 8 MiB reserved each)
would leak. Now when a thread's last live instance of a library is destroyed
(`LIVE_INSTANCES`, `instance_gone`), its pool is freed
(`coroutine::release_pool`, on every host: a mapping each, a fiber each on
Windows). `nl-coroutine-stacks-released` counts the stacks (made 12.5 MiB to
be recognizable): pooled while an instance lives, kept while one of two
does, freed with the last, also a worker thread's at its last destroy, on
Linux and Windows; the mutant `stacks-kept-after-last-instance` keeps them.

## 11. The C runtime, ownership and unloading

**One C runtime per DLL, its own.** The DLL links the static release C
runtime (libcmt, libvcruntime, the static UCRT) and excludes every other
Microsoft runtime -- `crt_args_for`'s executable policy
(WINDOWS-X86-64-MILESTONE-2.md, "The C runtime"), applied to the DLL. It
imports only the system's DLLs: in the census (E1) `kernel32.dll`,
`api-ms-win-core-synch-l1-2-0.dll`, `ntdll.dll` and `bcryptprimitives.dll`
(the standard library's raw-dylib imports) and `KERNEL32.dll` (the C
runtime's), no `VCRUNTIME140.dll`, `ucrtbase.dll` or `api-ms-win-crt-*`;
`ValidateDll` refuses a DLL that imports a C runtime's DLL, on every build. A host compiled for the
static runtime (`/MT`) and one compiled for the dynamic runtime (`/MD`)
use it alike (`nl-windows-crt`: the same output from both, results kept
across calls and the instance's destruction, the host's own `malloc`/`free`
beside it): the DLL's `malloc`ed buffers and boxed errors live in its own
runtime's heap, which is why only its own release functions may free them.
`ValidateDll` refuses a DLL importing a C runtime's DLL (`nl-windows-validate`;
the mutant `dll-crt-dynamic` links the dynamic runtime and is refused).

**Ownership** is unchanged: a String result is a `malloc`ed copy (`owned_buffer`)
the caller releases with `NAME_bytes_release`, an error is the caller's until
`NAME_error_release`; both survive later calls, collections and the
instance's destruction (`nl-abi-results-survive`); releasing clears the
caller's variable, releasing a cleared one is harmless, releasing another
library's buffer, or a fabricated one, is refused with INVOCATION and
nothing is dereferenced (each library keeps live sets, `BUFFERS` and
`ERRORS`: `nl-abi-types`, `nl-two-libraries`, the fuzzer's lifecycle).
The mutant `str-result-borrowed` hands out a pointer into the Botlish heap.

**Unloading.** Destroying an instance and unloading the DLL are two things.
The contract (header, manifest `lifecycle.unload`, Compilerpedia's
`backend.native-library`): **before `FreeLibrary`, destroy every instance
and release every result and error the library handed out; nothing of the
library -- a buffer, an error, a function's address -- is usable once it is
unloaded.** Releasing a result after the unload would call code that is
gone; the tests never do it (no controlled negative test of undefined
behavior). What the library does to make that precondition sufficient:
no thread keeps a coroutine stack of it once its instances are gone
(section 10), no host thread is left converted to a fiber, and the DLL
creates no thread and pins nothing. `nl-windows-unload`: a worker thread
loads nothing, creates an instance, runs coroutines, destroys it and waits;
the main thread unloads the DLL while the worker still runs -- the DLL is
gone (`GetModuleHandleW` finds nothing), no coroutine stack of it is left,
the worker is no fiber -- and the worker then ends normally (exit code 0);
twice, the second time after a reload. On Windows (the first MSVC run, run 42922582948): both rounds unload (`FreeLibrary ok, still loaded: no, coroutine stacks left: 0`) and the worker exits with 0 after each, plainly and under GC stress.

## 12. Several libraries in one process

A DLL is its own module: its symbols are not visible to another module
except through its export table, and two DLLs' runtime copies -- statics,
thread-locals, the instance registry, the live sets, the coroutine pool, the
table-hash key -- are separate by construction. What the milestone verified
is that the export table holds the public functions and nothing else:

* the module-definition file lists exactly the public names
  (`windows_library_definition`, unit-tested);
* no input adds an export: neither the program object nor any member of the
  runtime archive has a `.drectve` section (section 7), and the probe's E3
  links the DLL without a module-definition file: it exports nothing and
  link.exe makes no import library;
* `ValidateDll` compares the export table read from the PE file with the
  public names (and the import library's import objects with them) before
  the build is reported, and `nl-windows-exports` compares them, and
  dumpbin's reading of the table, on every run (on Windows, the first MSVC run, run 42922582948: the same names, none by ordinal only, none forwarded, the import library one code import of `chk.dll` per public function);
* `nl-windows-load-library`: GetProcAddress finds every public function and
  none of `botlish_library_call`, `botlish_library_create`,
  `botlish_program`, `botlish_fn_0`, `botlish_entry_0`, `rt_fail_declared`,
  `main`, `DllMain`, `rust_begin_unwind`.

`nl-two-libraries` (two libraries from different programs, both defining
an error `Negative` with different payloads and exporting `twice` and `tag`,
300 alternating rounds with allocating String results, each library's error
with its own payload, one library's buffer released through the other
refused, one library's instance given to the other refused, under GC
stress), `nl-nested-libraries` (one DLL's call reaching the other's through
C, the outer program's enum shown after), and `nl-windows-load-library`
(both loaded explicitly, one unloaded while the other answers, then
reloaded) run from MSVC hosts. The linked hosts link both import libraries;
the explicit host links neither.

## 13. Static COFF libraries: why none is shipped

The brief's rule: a static COFF library ships only if two of them coexist
in one executable with independent runtimes, by construction, not by link
order. On Linux that holds because `ld -r` merges the program object and
the runtime archive into *one* object, whose private symbols `objcopy`
then makes local: nothing outside the object can bind to them. COFF has no
partial link (link.exe has no `-r`; lib.exe only collects members), so a
static `NAME.lib` is the program object plus the runtime archive's members,
each member's runtime symbols external -- they must be, or the members could
not reach one another.

The census (section 3, experiments E5 and E6; real Windows):

* **One static library alone works**: `one_static.lib` (the program
  object and the runtime archive's members, 22.5 MB) linked into a C host
  runs (`twice: 42`).
* **Two do not coexist, and nothing says so.** Both linked into one host:
  link.exe reports no duplicate symbol (0 LNK2005) and the host runs. An
  archive member is pulled once, by the first undefined reference it
  resolves, so the second library's program object binds to the runtime
  members the first library's references already pulled. With
  `/FORCE:MULTIPLE` the same (0 LNK4006): `twice: 42 63` from the two
  libraries, and a result buffer of `one` released through `two`'s
  release function is *accepted* -- which two independent runtimes refuse
  (`nl-two-libraries`: "one library's buffer released through the other
  refused"). One runtime serves both libraries, chosen by link order.
* **The candidate mechanism (E6)**: renaming every symbol a library's
  objects define, but its public functions, with a prefix of the library's
  own (`llvm-objcopy --redefine-syms`, both definitions and references, in
  the program object and every runtime member) works mechanically -- 4,965
  symbols in 1,879 objects, no failure -- and costs about 5 minutes per library
  on the runner -- and is not enough: the two renamed archives in one
  executable leave 4 externals unresolved (LNK2019; the probe does not name
  them). E6 extracted none of the archive's short import objects (the
  standard library's raw-dylib imports of ntdll, bcryptprimitives and the
  API sets, which no import library on the link line provides), the likely
  cause, not established. A sound static library would need that step
  too, and then a test that two of them are independent; neither exists.

**The decision: no static COFF library.** The production path is the DLL
and its import library; `-shared 0` is refused on Windows, and nothing
named `NAME_static.lib` is made. A sound static library needs every private
symbol of one library's objects -- the runtime's, the standard library's,
the program's -- given a name of that library's own, consistently in
definitions and references, COMDAT sections, weak externals and `.refptr`
pointers included, and the result checked: a COFF symbol-rewriting step
over about 1,800 archive members per build. That is the "large
general-purpose COFF rewriting subsystem" the brief warns against, and it
would bring a tool MSVC's toolchain does not have (LLVM's objcopy) into
every Windows library build. The reproducer of the unresolved isolation
problem is the probe's E5 (`audit/windows-library/probe.tcl` on any Windows
runner with Visual Studio's x64 tools; the `windows library probe`
workflow): two static libraries made the obvious way link into one
executable without a diagnostic and share one runtime.


## 14. Toolchain and diagnostics

A Windows library is linked by Microsoft's link.exe found as the system
linker finds it (`codegen::aot::system_linker`): `BOTLISH_NATIVE_SYSTEM_LINKER`
when set, else `link.exe` on PATH, confirmed by its banner (Git's coreutils
`link` is refused); its libraries and the Windows SDK's are found through
the `LIB` environment a Developer Command Prompt (`vcvars64.bat`) sets. The
runtime archive is the system linker's: `botlish_runtime.lib` beside the
driver, or `BOTLISH_NATIVE_RUNTIME`, checked to be a COFF x86-64 archive.
That is the existing policy for system-linked executables on Windows: the
compiler has no Visual Studio discovery of its own, and does not fall back
to another linker, CRT or architecture. (rustc's linker, which finds
link.exe by itself, cannot link a DLL with exactly the public exports: a
`cdylib` exports every `#[no_mangle]` function of every crate, the
runtime's hundreds of helpers among them.)

`native::library` asks the driver (`botlish-native system-linker`) for the
tool and the runtime archive *before* lowering anything
(`library::WindowsToolchain`), so a missing toolchain is said at once. The
failures, each its own error code with the tool's words kept
(`nl-windows-diagnostics`, Compilerpedia's `error.native-library`):

| Failure | Error code |
|---|---|
| no link.exe (none on PATH, BOTLISH_NATIVE_SYSTEM_LINKER naming none, another toolset's `link`) | NATIVE LIBRARY TOOLCHAIN |
| the runtime archive missing, not an archive, of another machine | NATIVE LIBRARY RUNTIME |
| the link failed: a library or a C function no input provides, any LNK error | NATIVE LIBRARY LINK (the LNK lines; for a program that calls C its declared plan, and link_hint's explanation of `__imp_` symbols) |
| the archive lacks a runtime helper the program calls (another build's) | NATIVE LIBRARY RUNTIME |
| the DLL is not the library (an export missing or extra, a C runtime DLL imported, ...) | NATIVE LIBRARY PE (both files removed) |
| a library of another target than the host's | NATIVE TARGET (no Windows cross link: section 18) |
| `-shared 0` on Windows | NATIVE UNSUPPORTED library |
| certutil failing (the manifest's digests) | NATIVE LIBRARY TOOL certutil |

`BOTLISH_NATIVE_LINK_LOG=FILE` appends the link's command line and output,
as for executables.

## 15. Tests, fuzzing, mutation testing

**The test file.** `tests/native-library.test` is one file for both
library hosts: 41 tests, every host test written once, its C written for
both compilers (`nlPrelude`: `<windows.h>` and `NL_REGISTER` there,
pthreads here, one `nl_thread_start`/`nl_thread_join` over CreateThread or
pthread_create), built by MSVC's cl in vcvars64's environment on Windows
(`nlExecutable`: `/O1 /W3 /std:c11`, or `/TP /EHsc /std:c++17` for a C++
host, `-crt MT|MD`) and by cc on Linux. A host calls the library through
its import library (`nlLink`), or loads it with `LoadLibraryW` and
`GetProcAddress` (`nlLoaderC`, which declares each library's function
pointer types under its own name). Constraints say what a test needs:
`nativeLibraries` (the host builds libraries: a C compiler and the runtime
archive), `elfLibraries` (Linux's archive and symbols), `windowsLibraries`,
`noNativeLibraries` (the refusal).

| Tests | Linux | Windows |
|---|---|---|
| export roots, export checks, front end (`nl-export-root-*`, `nl-export-imported-module`, `nl-front-end-*`, `nl-library-checks`, `nl-library-export-list`) | run | run |
| the C ABI (`nl-abi-types`, `nl-abi-results-survive`), lifecycle, threads, reentrancy | run | run (MSVC hosts) |
| coroutines, stack safety (also on a host's own stack: a fiber on Windows, a `makecontext` stack on Linux), the walk's ceiling, `nl-coroutine-stacks-released` | run | run |
| several libraries and instances (`nl-two-*`, `nl-nested-libraries`) | run | run |
| `nl-symbols`, `nl-two-libraries-shared` (ELF symbol tables, archives) | run | -- |
| `nl-windows-*` (12: explicit loading, exports, validation, diagnostics, unwinding through the trampoline, the loader lock, a C++ host, `/MT` and `/MD` hosts, fibers, unloading, the Win64 convention) | -- | run |
| `nl-unsupported-host` (a host the capability table gives no libraries: macOS) | -- | -- (runs on macOS) |
| `nl-manifest`, `nl-main-cli`, `nl-sample` (section 19's sample, as it is given) | run | run (the host's artifacts) |

Linux x86-64, locally: 30 run, 0 failed (12 skipped: the Windows tests and
the refusal); with `BOTLISH_NATIVE_GC_STRESS=1`, the same. Windows x86-64
(MSVC; the canary of run 42945387449 at 8031ed76): 39 run, 0 failed (3
skipped: `nl-symbols` and `nl-two-libraries-shared`, ELF's, and
`nl-unsupported-host`); every host built by cl and run plainly and, where
the test says so (`nlRunBoth`), under GC stress. Getting there took three
MSVC runs: the first (42922582948) failed five tests -- one a defect of
`native::library` (the toolchain asked before the program's own checks),
four of the tests themselves (a `/TP` that compiled the import library as
C++, a C `long` argument unproven in 32 bits, two builds outside vcvars'
environment, a TLS callback count taken from the cross-built archive);
the second (42933903890) failed `nl-manifest` alone, two builds' manifests
differing, which `/Brepro` fixed (section 4).

**The fuzzer.** `audit/native-library/tools/fuzz.tcl` generates a library
of eight random exports -- one to eight parameters of int, bool, Float64
and str mixed (so positions past the fourth, which Win64 passes on the
stack, in every class), a result of each type or unit, some failing with a
declared error carrying a payload -- calls each 24 times from a generated
C host with the boundary's edge values (INT64_MIN and INT64_MAX, -0.0, NaN
and the infinities, the smallest subnormal, the empty String, NULL with
length 0 and with a length, embedded NULs, invalid UTF-8 and a surrogate's
encoding, 9,000-byte text) and runs random lifecycle sequences on up to
three instances (live, destroyed and never-made handles, double releases,
a foreign buffer); every line the host prints is compared with an
independent model of the C ABI written in Tcl from
NATIVE-LIBRARY-MILESTONE-1.md's rules, never from the compiler. Linux:
seeds 1 to 6, 192 calls and 37 to 56 lifecycle steps each, 0
disagreements; seed 6 again and seed 7 (12 exports, 288 calls, 94
lifecycle steps) plainly and under GC stress, 0 disagreements. Windows:
WINDOWS-FUZZ-PENDING.

**Mutation testing.** `audit/native-library/tools/mutate.tcl` runs on
Windows too now (a private copy made by Tcl, an overrunning run ended with
taskkill; the tier item `native-library-mutants`). Its catalog has 40
mutants: the 26 of NATIVE-LIBRARY-MILESTONE-1.md (two updated to the code
they mutate now, `stack-check-not-emitted` and `stack-limit-not-followed`)
and 14 new ones:

| Mutant | Host | Killed by |
|---|---|---|
| `dll-export-omitted` (the .def file leaves out a public function) | all | `windows_library_link_is_a_dll_of_the_static_runtime` |
| `dll-internal-exported` (the DLL exports `botlish_library_call`) | Windows | WINDOWS-MUTANT |
| `dll-import-library-misnamed` | Windows | WINDOWS-MUTANT |
| `dll-crt-dynamic` (VCRUNTIME140 and the UCRT, not the static CRT) | all | `windows_library_link_is_a_dll_of_the_static_runtime` |
| `dll-validation-extra-exports` (ValidateDll ignores an extra export) | Windows | WINDOWS-MUTANT |
| `dll-validation-runtime-imports` (ValidateDll ignores a CRT DLL import) | Windows | WINDOWS-MUTANT |
| `public-unwind-dropped` (no unwind information for the public functions) | Windows | WINDOWS-MUTANT |
| `win64-convention-ignored` (the public functions use System V on Windows) | Windows | WINDOWS-MUTANT |
| `loader-lock-initializer` (the program object gains a `.CRT$XCU` initializer) | Windows | WINDOWS-MUTANT |
| `fiber-left-converted` (the outermost call's end keeps the thread a fiber) | Windows | WINDOWS-MUTANT |
| `str-result-borrowed` (a String result points into the heap) | all | `nl-abi-results-survive`, `nl-abi-types`, `nl-two-instances` |
| `invalid-handle-dereferenced` | all | `nl-lifecycle` |
| `stacks-kept-after-last-instance` | all | `nl-coroutine-stacks-released` |
| `entry-stack-ignored` (a host's stack walked within the thread's) | all | `nl-stack-safety-foreign-stack` |

Linux x86-64 (the whole catalog, every detector): 40 mutants, 32 killed,
0 survived, 8 skipped (the Windows-only ones). Windows x86-64:
WINDOWS-MUTANTS-PENDING.

The brief's other mutant ideas are covered where they apply: an internal
symbol exported, a public one missing, the import library's name, the
dynamic CRT, the convention, unwind information, the loader lock, a host
fiber left converted, a borrowed result, an invalid handle, a host's stack
(above); "a destroyed instance stays live", "wrong thread accepted",
"reentrancy accepted", "a released buffer kept" and "a foreign buffer
freed" are the milestone-1 mutants, which run on Windows now; "a DLL's
runtime shared with another's" cannot be written as a source mutant (two
DLLs' runtime copies are separate modules whatever the source says: the
only way to share one is to export it, which `dll-internal-exported` is).

## 16. Performance and size

`bench/native-library.tcl` (the tier item `native-library-bench`) builds a
library of five exports, a C reference library of the same functions, and
measures, best of five runs of 200,000 calls: the build, the sizes, loading
and unloading (a copy of the library loaded by path, so no earlier load is
reused), creating and destroying an instance, each call against the C
reference's, the same under GC stress, and the same functions called from
Botlish code in an executable's loop (what a call costs without the
boundary). The library's functions: `add` (two Ints), `scale` (a Float64),
`echo` (a str, 10 bytes and 4 KiB: copied in, validated, copied out),
`words` (`words(16)` collects 16 Strings, each made by `concat`, into a
List and returns its length: 17 allocations), `fail_if` (a declared error
with a payload).

**Windows x86-64** (windows-2025 runner, MSVC 14.4x, `/O1` hosts):
WINDOWS-PERF-PENDING

**Linux x86-64** (the development container, 4 cores, idle; for
comparison):

| Measure | Value |
|---|---:|
| build (`native::library`, five exports) | 400 ms |
| shared library (`libbl.so`) | 879,936 bytes |
| static archive (`libbl.a`) | 14,046,168 bytes |
| exported functions | 20 (5 exports, 15 forwarders) |
| C reference library | 15,840 bytes |
| load and unload | 31.7 us |
| create and destroy | 23.5 us |

| Call | Botlish | Botlish, GC stress | C reference | from Botlish code (an executable's loop) |
|---|---:|---:|---:|---:|
| int (`add`) | 80.2 ns | 86.1 ns | 0.8 ns | 2.5 ns |
| Float64 (`scale`) | 133.2 ns | 347.2 ns | 0.7 ns | |
| short str (`echo`, 10 bytes) | 144.2 ns | 248.0 ns | 11.8 ns | |
| longer str (`echo`, 4 KiB) | 392.4 ns | 384.8 ns | 58.5 ns | |
| allocating (`words(16)`) | 1,419.1 ns | 4,557.4 ns | 162.9 ns | 1,430.3 ns |
| declared error (`fail_if`) | 391.8 ns | 376.2 ns | 0.9 ns | |

A library call's fixed cost, about 78 ns on Linux (`add`: 80.2 ns through
the boundary, 2.5 ns from Botlish code), is the boundary's: the registry's
lookup and thread check, the reentrancy flag, entering the Vm (its stack
ceiling, stack limit and entry stack, the program), `catch_unwind`, and
the arguments' and result's conversion. For a call that does work it
disappears in the noise: `words(16)` costs the same through the boundary as
from an executable's loop (1,419 against 1,430 ns). A declared error costs
about 310 ns more than a result (the error object, its identity and its
payload copied out of the heap); a str argument and result about 64 ns
more than an Int at 10 bytes (validated, copied in and out). This
milestone adds to a call a thread-local counter's increment and decrement
(`CallDepth`), the entry stack's save, set and restore, and at the
outermost call's end one thread-local read (`library_call_ended`, which on
Linux does nothing else).

## 17. CI

What runs where:

* **`tests (windows x86-64)`** (`.github/workflows/windows-x86_64.yml`,
  windows-2025, MSVC from Visual Studio 2022's x64 tools): the canary on
  every push; on a push to main and a dispatched run the smoke job, whose
  tier now includes `native-library.test` and whose new step "Native
  libraries (DLL, MSVC hosts)" runs the fuzzer (seed 1 also under GC
  stress, seed 2 with 12 exports and 120 lifecycle steps) and the
  benchmark; the acceptance tier (four shards) runs `native-library.test`
  again with every Windows-relevant test file. `[ci-full]` or a manual run
  with `tier: full` adds the GC-stress tier; its `tests` input (or a
  `CI-Tests:` trailer) names tier items such as `native-library-mutants=...`.
* **`windows library probe`** (`.github/workflows/windows-library-probe.yml`,
  on a push that changes the probe and by hand): the census of section 3,
  its log uploaded.
* **Linux x86-64, Linux AArch64, macOS AArch64** (`tests.yml`,
  `tests-arm64.yml`, `macos-arm64.yml`): the existing native-library tests
  on Linux (the file runs on both Linux workflows; the new
  `nl-coroutine-stacks-released` and the foreign-stack test's GC check
  among them) and `nl-unsupported-host` on macOS.

Runs of this branch:

CI-RUNS-PENDING

## 18. Remaining limitations

* **No static COFF library** (section 13).
* **No Windows cross-linking**: a Windows library is made on Windows (the
  driver can emit the COFF object from Linux, `library --target
  x86_64-pc-windows-msvc`, but nothing links it there; nothing claims it).
* **A Developer environment is needed to build** (section 14); a consumer
  needs nothing but the DLL (and the import library to link it).
* **Stack overflow outside Botlish recursion** ends the host (section 8),
  as on Linux; no SEH exception is recovered from.
* **C callbacks** (`callback c fn`) stay refused on Windows (C-CALLBACK-
  MILESTONE-1.md: the walk does not cross a foreign transition there); a
  library may call C, and C may call another library's exports.
* **Unloading**: the precondition of section 11 is the host's to keep.
* **Unchanged from NATIVE-LIBRARY-MILESTONE-1.md**: synchronous, thread-
  affine instances, the boundary types, no macOS or iOS libraries.

## 19. Files changed, and what to run

**The production path.**

* `native/src/codegen/library.rs`: `SUPPORTED` and `supports` name Windows
  x86-64 (MSVC); `define` returns each public function's `Defined` (its
  size and Windows `UNWIND_INFO`).
* `native/src/codegen/mod.rs`: `add_windows_unwind` writes the public
  functions' entries beside the program's.
* `native/src/codegen/clif.rs`: `windows_unwind` shared with the library
  writer.
* `native/src/codegen/aot.rs`: `windows_library_definition`,
  `windows_library_link_args`, `link_windows_library` (and the unit test
  `windows_library_link_is_a_dll_of_the_static_runtime`).
* `native/src/main.rs`: the driver's `library-dll DIR NAME FILE.nir`.
* `native/src/runtime/library.rs`: `public_names`; `enter`'s
  `entry_stack`; `CallDepth` (the outermost call's end); `LIVE_INSTANCES`
  and `instance_gone`.
* `native/src/runtime/vm.rs`: `Vm::entry_stack`, `entry_stack_at`; the
  collector's walk and `publish_active_stack` follow it.
* `native/src/runtime/coroutine.rs`: `release_pool`, `library_call_ended`,
  `CoStack::discard`; `native/src/runtime/coroutine/windows.rs`:
  `restore_thread`, the fiber's `discard`.
* `native/library.tcl`: the Windows branch of `native::library`,
  `WindowsToolchain`, `ValidateDll`, the Windows header and manifest,
  certutil's digests; `native/pe.tcl` (new): the PE and import-library
  reader; `native/native.tcl`: the `libraries` capability.
* `main.tcl`: the `import:` line and the help text; `pm/tools.tcl`: an
  artifact's `import` digest.

**Tests, tools, CI, documents.**

* `tests/native-library.test`: portable harness (MSVC's cl on Windows, the
  import library, `nl_thread`, `nlHostCallback`), the ported tests, and the
  new ones (`nl-coroutine-stacks-released`, `nl-windows-*`,
  `nl-unsupported-host`); `tests/cffi/nl-win64-probe.asm` (new).
* `audit/native-library/tools/fuzz.tcl` (new), `mutate.tcl` (Windows),
  `mutants.txt` (fourteen new, two updated); `audit/target-model/tools/
  mutants.txt` (one updated).
* `audit/windows-library/probe.tcl` and
  `.github/workflows/windows-library-probe.yml` (new): the census.
* `bench/native-library.tcl` (new).
* `tests/platform/tier.tcl`: `native-library-fuzz`, `-mutants`, `-bench`.
* `.github/workflows/windows-x86_64.yml`: the smoke job's library step and
  `native-library.test` among its files.
* `docs/NATIVE-LIBRARY-MILESTONE-1.md` (forward reference),
  `docs/INDEX.md`, `AGENTS.md` (Native libraries), Compilerpedia's
  `backend.native-library` and `error.native-library`.

**Building and consuming a sample library on Windows** (from a Developer
Command Prompt, or a shell after `vcvars64.bat`; Tcl 9.0.1 and the native
backend built as WINDOWS-X86-64-MILESTONE-1.md says), `example.bot` being

```botlish
error Rejected:
    code: int

exported c fn checked(n: int) -> int errors Rejected:
    if n < 0:
        fail Rejected {code: n}
    n * 2
```

```bat
tclsh9.0 main.tcl -emit-native-library example -out output example.bot
rem output\example.dll, example.lib, example.h, example.manifest.json
cl /nologo /W4 /Ioutput host.c output\example.lib /Fe:output\host.exe
output\host.exe
```

where `host.c` is

```c
#include <stdio.h>
#include "example.h"

int main(void) {
    example_instance *in; example_error *e = NULL; int64_t r;
    if (example_create(&in, &e) != example_STATUS_OK) return 1;
    if (example_checked(in, 21, &r, &e) == example_STATUS_OK)
        printf("%lld\n", (long long) r);
    example_destroy(in);
    return 0;
}
```

The host runs beside `example.dll` (the loader's first directory), or
loads it itself with `LoadLibraryW(L"example.dll")` and finds
`example_create`, `example_checked`, ... with `GetProcAddress`.

**What to run when changing this.** Everything NATIVE-LIBRARY-MILESTONE-1.md's
section 16 lists, and:

* `tclsh9.0 tests/native-library.test` on Windows (Visual Studio's x64
  tools; the Windows workflow's smoke job) and on Linux;
* `cargo test --release --manifest-path native/Cargo.toml --bin
  botlish-native windows_library` and `--lib program`;
* `tclsh9.0 audit/native-library/tools/fuzz.tcl -seed S` (several seeds,
  once with `-gc-stress 1`), on both hosts;
* `tclsh9.0 audit/native-library/tools/mutate.tcl` (every mutant that
  applies to the host; on Windows the tier item `native-library-mutants`,
  a `[ci-full]` push with `CI-Tests: native-library-mutants`);
* `tclsh9.0 bench/native-library.tcl` for the costs;
* `tclsh9.0 audit/windows-library/probe.tcl` (its workflow) for a change to
  the link;
* for the runtime's coroutine and stack changes, what AGENTS.md lists for
  coroutines and for the native stack guard; `tools/mutant-catalogs.tcl`.
