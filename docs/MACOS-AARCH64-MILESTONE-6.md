# MACOS-AARCH64-MILESTONE-6.md

Milestone 6 of the macOS Apple Silicon port: the Apple AArch64 C ABI for
scalar and pointer calls, library linking and foreign symbol resolution on
`macos-aarch64`. Developed on Linux; every macOS fact below was observed on
GitHub's `macos-15` arm64 runners through `.github/workflows/macos-arm64.yml`
(the shared Apple Silicon development machine was not used). The audit it
updates is MACOS-AARCH64-PORT-AUDIT.md (sections 1, 5, 10, 15-17; its roadmap
calls this milestone entry 7); the milestones before it are
MACOS-AARCH64-MILESTONE-1.md to -5.md.

> A foreign call is correct only when the foreign implementation sees the
> exact values, locations, widths and lifetimes its ABI promises.

## Result

A Botlish program that declares C functions and libraries now links through
Apple's toolchain on macOS AArch64, calls them with Apple's arm64 C ABI and
returns its value through the ordinary native driver protocol -- on both
native backends and as a standalone Mach-O executable:

```text
Botlish -> HIR -> NIR -> Cranelift (apple_aarch64 foreign signatures) -> Mach-O object
        -> rustc -> cc (Apple clang) -> Apple ld (-L, -lNAME, no group) -> Mach-O executable
```

**Before** (main at 2786a81, every macOS run since milestone 5, e.g. run
[39365936272](https://github.com/mwagner-webdev/botlish/actions/runs/39365936272)):
native-status's `c-call` probe -- `extern c fn labs(x: std::ffi::c::Long) ->
std::ffi::c::Long`, `labs(-5)` -- was refused before the linker ran:

```text
error {NATIVE LINK} {native link failed: this program calls C or declares a C library
(symbols labs), and C calls are linked on Linux glibc only: on this host executables of
programs that call no C are supported, C calls not yet (MACOS-AARCH64-PORT-AUDIT.md, C FFI)}
```

and tests/platform/tier.tcl left c-ffi.test and c-bindgen.test out of the
acceptance tier (`notYet`).

**After** (every run from
[39375814220](https://github.com/mwagner-webdev/botlish/actions/runs/39375814220)
on): the same probe links and returns `5`; aot-facts.tcl's C-call checks on
the runner link a static library compiled there by Apple clang and the
system C library into one executable that prints `[42, -34458]` (libSystem's
`labs(-42)`, and `bcfx_widen(-1, 65535, 7)` through `named`, a signed char
and an unsigned short), `_labs` "(undefined) external ... (from libSystem)";
c-ffi.test and c-bindgen.test run in the acceptance tier (`notYet` is
empty).

What it took:

* **One gate** opened (`codegen/aot.rs`'s `C_CALLS`), **one link plan** per
  platform linker (Apple's ld rejects GNU's archive group and needs none),
  **Apple ld's words** kept in NATIVE LINK messages.
* **One Cranelift defect** found and worked around, which no test of a C
  callee's *values* could see: cranelift-codegen 0.135.2 stores an extended
  narrow *stack* argument under the Apple convention with an 8-byte store
  into its 1-, 2- or 4-byte slot, so the last one can overwrite up to seven
  bytes of the caller's frame above the argument area -- in the reduced
  case, the explicit stack slot Cranelift puts right above it, the kind of
  slot Botlish keeps GC roots and call scratch in. Botlish's foreign
  signature no longer asks for that extension
  (Apple's ABI has none for a stack slot); upstream fixed it the same way in
  0.136.0 (section 9).
* **Evidence** of the ABI against Apple clang: the machine state calls
  arrive in (registers, stack bytes), Apple clang's own calls of the same
  prototypes, C reading each of twenty arguments back, the full scalar
  matrix, plain char, pointers, and the runtime around C calls (GC stress,
  coroutines, the stack guard).

Gates, all on GitHub Actions runners (no shared Mac):

| Gate | What | Evidence |
|---|---|---|
| A | baseline: the refusal; ordinary Mach-O AOT passes | main's runs (above); milestone 5's aot-facts in every smoke job |
| B | a C fixture compiled by Apple clang, linked, its symbol resolved | aot-facts `c-library`, `c-call-run`; c-ffi.test `cf-fixture-built` |
| C | an `int -> int` call through the native linked run | native-status `c-call` 5; c-ffi.test's calls on both backends |
| D | the integer scalar matrix, boundaries | `cf-scalar-transport`, `cf-scalar-values`, `cf-char-target` |
| E | Apple-specific: narrow argument extension, packed stack arguments | `cf-abi-*`, `cf-clif-stack-parameters`, `ffi_apple_*` (section 9) |
| F | pointers | `cf-pointers`, `cf-pointer-mix`, `cf-pointer-width`, `cf-wild-address` |
| G | executables, GC, coroutines, the stack guard | `cf-executable`, `cf-gc-calls`, `cf-coroutine-calls`, `cf-c-stack-overflow`, Tier C under GC stress |
| H | the binding generator, linker diagnostics | c-bindgen.test, `cf-missing-library`, `cf-undefined-symbol`, `cf-wrong-architecture`, aot-facts' linker checks |
| I | broad acceptance | the acceptance tier, Tier C, the fuzzer, mutants (sections 24-25, 27) |

## 1. Initial macOS C FFI refusal

Milestone 5 left `C_CALLS = cfg!(target_os = "linux")`: `emit_executable`
refused a program whose NIR has a `foreign` or `link` entry on macOS before
the linker ran, for `-emit-native-executable` and for the native backends'
runs alike (`run_linked` links such a program to run it). native-status's
`c-call` probe recorded the refusal above; c-ffi.test was in tier.tcl's
`notYet` ("C calls are refused before the linker runs"), c-bindgen.test too
("the fixture's manifest records Ubuntu's clang, not Apple's"). The JIT
compiled such a program for inspection only (`native::clif`), its C symbols
bound to `rt_ffi_unlinked`.

## 2. The Linux C FFI architecture this milestone started from

Audited at 2786a81 (then main), by tracing `bcf::add(40, 2)` from source to
the C callee on Linux x86-64:

| # | Step | Where | Class |
|---|---|---|---|
| 1 | `extern c fn NAME [named "SYMBOL"](PARAMS) -> T [FACT]` and `extern c library "NAME"`: located `EXTERN-SYNTAX` errors | surface/parser.tcl `ExternDecl`, `ExternParam` | portable |
| 2 | The link symbol: the name, or `named`'s string, never decorated | the same; hir/foreign.tcl | portable (the object crate adds Mach-O's `_`) |
| 3 | C types: `std::ffi::c` scalars declared per compilation for its target, their width and signedness the target row's (`charSigned 1` for macos-aarch64) | core/cabi.tcl, hir/cabi.tcl `NamespaceTypeDecls` | portable (milestone 2) |
| 4 | HIR: the extern native `extern#KEY`, the `foreign` and `links` side tables, the ABI class of each parameter and result | hir/foreign.tcl | portable |
| 5 | HIRX and the cache: the side tables and the declarations travel; the target is in the cache key | hir/interchange.tcl, surface/cache.tcl | portable |
| 6 | Native lowering: the header's `link` lines and `foreign N "SYMBOL" params=... result=...` entries, `foreigncall` after the arguments and exposures | native/lower.tcl | portable |
| 7 | The C signature: the target triple's C convention, each integer parameter at its width, narrow ones `sext`/`uext`, the result unextended | codegen/clif.rs `c_signature`, codegen/target.rs `c_call_conv` | **arch** (milestone 2 chose `apple_aarch64`; this milestone found what it stores, section 9) |
| 8 | Argument conversion: an Int's word shifted and reduced to its width; a pointer word untagged; a bool's bit | clif.rs `foreign_call` | portable |
| 9 | Register and stack assignment, narrow-argument extension | Cranelift's ABI (`compute_arg_locs`, `gen_call_args`) | owned |
| 10 | Result conversion: extended by Botlish from its width, tagged or boxed; a pointer checked against the C pointer word | clif.rs `foreign_call` | portable |
| 11 | The import: `Linkage::Import` of the symbol | clif.rs `declare` | portable |
| 12 | Link plan: `default-linker-libraries=yes`, `-L` dirs, `-Wl,--start-group`, `-lNAME`..., `-Wl,--end-group` | codegen/aot.rs `link_plan_args` | **linux** (GNU ld's group) |
| 13 | Library search: `main.tcl -L DIR` (normalized), `--link-dir` | main.tcl, native/native.tcl, main.rs | portable |
| 14 | Static or dynamic: the linker's own `-lNAME` search | the system linker | owned |
| 15 | The run of a program that calls C: linked into a private directory, run in the driver protocol (`run_linked`) | main.rs | portable |
| 16 | Errors: NATIVE LINK with `linker_diagnostics`' lines; NATIVE ADDRESS, NATIVE BOOL, NATIVE CONTRACT-VIOLATION at run time | aot.rs, runtime/ffi.rs | **linux** wording |
| 17 | The gate: `C_CALLS` (Linux only) refused a C program on macOS before the link | aot.rs `emit_executable` | **the refusal** |
| 18 | The fixture: `cc -c -O2 -fPIC`, `ar rcs`; ELF-only assembly (`.type`, bare labels) for the dirty-register functions | tests/c-ffi.test, tests/cffi/fixture.c | **elf + linux test constraint** |
| 19 | Test constraints: `linuxNative` | c-ffi.test, c-bindgen.test, native-view/native-edit/layout-arrays (`nativeLinux` for the fixtures) | **linux** |
| 20 | The fuzzer's own type model: plain char signed except on Linux AArch64 | audit/c-ffi/tools/fuzz.tcl | portable (milestone 2) |
| 21 | The binding generator's committed fixture manifests: the generating clang's version string | tools/c-bindgen/fixture/expected/ | **toolchain pin** |

So the blockers were the gate (17), the GNU link plan (12), the linker's
wording (16), the fixture's assembly and constraints (18, 19), the
generator's manifests (21) -- and one that reading the code had not shown:
what Cranelift 0.135.2 actually stores for a narrow stack argument under the
Apple convention (7, 9; section 9).

## 3. Files and subsystems changed

Native backend:

- `native/src/codegen/aot.rs`: `C_CALLS` admits macOS AArch64; the link
  plan per `LinkerFlavor` (`link_plan_args_for`: GNU's group on Linux, none
  on macOS); `linker_diagnostics` keeps Apple ld's and clang's lines; unit
  tests of both plans, the host's flavor and the diagnostics.
- `native/src/codegen/target.rs`: `c_extended_parameters` (how many leading
  parameters of a foreign signature carry an extension attribute: eight
  under `AppleAarch64`, all elsewhere).
- `native/src/codegen/clif.rs`: `c_signature` asks it; `apple_tests`, two
  unit tests reading Cranelift's disassembly of an Apple C call (AArch64
  hosts).

Tests and tools:

- `tests/helpers.tcl`: `nativeCCalls`, a capability defined once.
- `tests/cffi/fixture.c`: the AArch64 assembly through `BCF_FUNCTION` (ELF or
  Mach-O spelling), the x86-64 assembly guarded from Apple; new functions:
  `bcf_capture` (assembly: the argument registers and stack bytes a call
  arrives in) and its accessors, `bcf_reference_narrow8`/`_pick` (the C
  compiler's own calls of the same prototypes), `bcf_pick` (twenty
  parameters, any one read back), `bcf_ninth`, `bcf_stack_tail`,
  `bcf_widen_char`, the pointer functions, `bcf_checked_div`, `bcf_deep`,
  `bcf_available` (macOS).
- `tests/c-ffi.test`: `nativeCCalls` for `linuxNative`; the ABI model and
  the new tests (sections 6-22); the host's convention, either linker's
  wording, `otool -L` beside `ldd`.
- `tests/c-bindgen.test`: `asRecordedToolchain` and
  `cb-fixture-current-provenance` (section 23); `nativeRun` on
  `nativeCCalls`.
- `tests/native-view.test`, `native-edit.test`, `layout-arrays.test`: their C
  oracles build where C calls run.
- `tests/platform/native-status.tcl`: macOS's `c-call` is 5.
- `tests/platform/aot-facts.tcl`: the C-call checks (a C library, a run, the
  import, the link command, the linker's words).
- `tests/platform/tier.tcl`: `notYet` empty; items `c-ffi-fuzz`,
  `c-ffi-mutants[=NAMES]`, `c-ffi-bench`.
- `audit/c-ffi/tools/mutate.tcl`: per-host mutants (`%%`), a timeout without
  timeout(1), SKIPPED; `mutants.txt`: 17 new mutants.
  `audit/native-aot/tools/mutants.txt`: the `C_CALLS` pair rewritten for
  the new gate.
- `bench/c-ffi.tcl`: two stack-argument rows.
- `audit/golden/migration/`: census rows for the new tests, the manifest
  regenerated.
- `.github/workflows/macos-arm64.yml`: the smoke job runs the driver's unit
  tests too (`--lib --bins`).

Documentation: this report, MACOS-AARCH64-PORT-AUDIT.md, C-FFI.md,
C-ABI-TYPES.md, docs/README.md, docs/INDEX.md, README.md, AGENTS.md,
Compilerpedia (`backend.platforms`, `backend.native-executable`,
`error.native-link`).

What did not change: the parser, the HIR, the foreign table, native
lowering, the C transport (`foreign_call`), the runtime, the startup crate,
the stub linker, `run_linked`, the driver protocol.

## 4. The macOS C linker plan

The link is milestone 5's -- rustc compiles the startup crate and runs the C
compiler driver (`cc`, Apple clang), which runs Apple's ld -- with the
program's link plan added in Apple's terms (`codegen/aot.rs`'s
`LinkerFlavor::Apple`, chosen by `cfg!(target_vendor = "apple")`):

```text
rustc ... -C link-arg=WORK/program.o
      -C default-linker-libraries=yes          rustc passes no -nodefaultlibs
      -C link-arg=-L/DIR ...                   one per -L
      -C link-arg=-lNAME ...                   the plan, in order: no group
      startup.rs -o EXECUTABLE
```

* **No archive group.** Apple's ld keeps searching every static archive
  while anything it could define is undefined ("there is no need to specify
  a static library multiple times on the command line", ld(1)), and rejects
  GNU's `--start-group` as an unknown option. The order of declarations
  therefore decides nothing: `cf-link-order` (an archive declared before
  the archive that needs it) passes on macOS with the bare list.
* **The C driver's default libraries.** `default-linker-libraries=yes` is
  kept: rustc's Apple link passes `-nodefaultlibs` and names `-liconv
  -lSystem -lc -lm` itself, which leaves out clang's compiler runtime
  (`libclang_rt.osx.a`), so with the C driver's defaults a C library
  compiled by clang finds the runtime helpers it may call, as in a C
  program's link. **No test can see the difference today**: the macOS
  mutation run (section 25) showed that `apple-default-libraries-dropped`
  survives every behavior test, which corrected this milestone's first
  account of it. The one helper the fixture uses, `__isPlatformVersionAtLeast`
  (`__builtin_available`; `cf-availability-check`, renamed from
  `cf-default-libraries`, links and returns 0 for `macOS 99`), is also
  defined by Rust's standard library -- `strings` of rustc 1.97's
  aarch64-apple-darwin `libstd` rlib shows `___isPlatformVersionAtLeast`
  and `___isOSVersionAtLeast` -- and the link reaches it first. The
  argument is pinned by `ffi_link_plan_apple_has_no_gnu_flags`, which
  kills the mutant.
* **No rpath, no SDK path, no Xcode path, no framework.** The SDK is the one
  `xcrun` names for rustc's `cc`, as for every executable since milestone 5.
* The order relative to rustc's own libraries is rustc's: the plan follows
  `program.o` at the end of the command, after rustc's `-liconv -lSystem
  -lc -lm` -- which does not matter to Apple's ld, for archives (searched
  until nothing more resolves) or dynamic libraries (two-level namespace:
  each import records the library that defines it).

The command rustc runs for a program calling the system C library and a
static C library from a directory whose name has a space, as aot-facts.tcl's
`c-link-command` prints it on the macOS runner (`WORK` the scratch directory,
its `/var` already resolved to `/private/var`):

```text
"cc" "LINKDIR/rustch74Eeg/symbols.o" "LINKDIR/executable.botlish_program.9908cd796904a79a-cgu.0.rcgu.o" ...
     "RELEASE/libbotlish_native.rlib" ... "SYSROOT/lib/rustlib/aarch64-apple-darwin/lib/libcompiler_builtins-a927747ff7623fdf.rlib"
     "-liconv" "-lSystem" "-lc" "-lm" "-arch" "arm64" "-mmacosx-version-min=11.0.0"
     "-o" "LINKDIR/executable" "-Wl,-dead_strip" "LINKDIR/program.o" "-LWORK/c lib" "-lbotlish_aot_facts"
```

(run 39377475266's smoke job; `c-link-command`: "-lbotlish_aot_facts and -L
its directory passed; GNU archive group: 0; -nodefaultlibs: 0"). The same
smoke job's ordinary executable is linked with `"-Wl,-dead_strip"
"-nodefaultlibs" "LINKDIR/program.o"`: milestone 5's command, unchanged for
a program that calls no C.

## 5. The preserved Linux linker plan

`LinkerFlavor::Gnu` produces exactly the arguments `link_plan_args` produced
before -- `default-linker-libraries=yes`, `-L` per directory, `-Wl,--start-
group`, `-lNAME` in the plan's order, `-Wl,--end-group` -- byte for byte
(`ffi_link_plan_is_one_linker_group` pins them; it now calls the GNU flavor
explicitly, so it runs on every host). `ffi_link_plan_apple_has_no_gnu_flags`
pins Apple's (no `-Wl,` argument at all; a directory with a space stays one
argument), and `ffi_link_plan_flavor_is_the_hosts` that each host gets its
platform's. On Linux x86-64 the command is rustc's lld link with the plan
last (aot-facts.tcl's `c-link-command`, this container):

```text
"cc" "-m64" ... "-Wl,--as-needed" "-Wl,-Bstatic" RLIBS "-Wl,-Bdynamic" "-lgcc_s" "-lutil"
     "-lrt" "-lpthread" "-lm" "-ldl" "-lc" ... "-fuse-ld=lld" ... "-o" "LINKDIR/executable"
     "-Wl,--gc-sections" "-pie" "-Wl,-z,relro,-z,now" "-Wl,-O1" "LINKDIR/program.o"
     "-LWORK/c lib" "-Wl,--start-group" "-lbotlish_aot_facts" "-Wl,--end-group"
```

(no `-nodefaultlibs`: the driver's default libraries follow.)

## 6. Static fixture build and symbol inspection

The C side of every test is C compiled on the runner by the host's own C
compiler -- Apple clang on macOS (the `cc` of the runner's Xcode), GCC on
Linux -- and archived by the host's `ar`; Botlish never compiles C:

```text
cc -c -O2 -fPIC tests/cffi/fixture.c -o DIR/fixture.o
ar rcs DIR/libbotlish_cffi_fixture.a DIR/fixture.o
```

(c-ffi.test's setup; a second archive that depends on the first for
`cf-link-order`.) The fixture's hand-written assembly -- the functions that
return a register with dirty bits above a narrow result, and `bcf_capture`
(section 8) -- is spelled for the object format through one macro,
`BCF_FUNCTION`: ELF's `.type NAME,%function` and bare label on Linux,
Mach-O's `_NAME` label (the C user label prefix) and no `.type` on macOS; a
call from assembly to C uses `BCF_CALL`, the prefixed name. The x86-64
assembly is guarded by `!defined(__APPLE__)` (no Intel macOS target).
Before the milestone the AArch64 assembly was ELF-only and would not have
assembled on macOS. A fixture that builds for the wrong target is caught
too: the `fixture-wrong-architecture` mutant compiles it with `-arch
x86_64` on macOS (section 25).

Inspection, on the macOS runner:

* `cf-fixture-built`: the object's header is the host's (`macho arm64
  object`, by milestone 5's header reader, tests/binary-header.tcl),
  and `nm -g` of the archive lists `_bcf_add`, `_bcf_capture`,
  `_bcf_dirty_short`, `_bcf_pick` and `_bcf_deep` as defined text symbols
  (`T`) -- C functions and assembly ones alike, each with exactly one
  underscore. A fixture that does not build fails this test instead of
  leaving the rest skipped.
* aot-facts.tcl's `c-library` builds a separate one-function library the
  same way and reads it back:

  ```text
  ok   c-library                    libbotlish_aot_facts.a: macho arm64 object, defines _bcfx_widen: 1
         facts.o:
         0000000000000000 T _bcfx_widen
  ```

The Botlish side names the function without the prefix (`extern c fn add
named "bcf_add"`): the link symbol is the C name, and the object crate adds
Mach-O's `_` when Cranelift's module writes the import, as it does for every
other symbol of a Mach-O object since milestone 5. `mach-o-symbol-double-
prefixed` (a mutant that adds a second `_` to the imported symbol on macOS)
is killed on macOS by 53 tests and the fuzzer: no C
call links.

## 7. Dynamic library support actually verified

`cf-shared-library` builds a one-function shared library on the runner --
`cc -dynamiclib -O2 shared.c -install_name DIR/libbotlish_cffi_shared.dylib`
on macOS, `cc -shared -fPIC` and `LD_LIBRARY_PATH` on Linux -- declares it
by `extern c library "botlish_cffi_shared"` and calls `bcfs_triple` through
`named`. What it checks, on both platforms:

| Check | macOS result |
|---|---|
| the native backends' linked run (`-L DIR`): cranelift, cranelift-generic | 42, 42 |
| a standalone executable, run directly | 42 |
| the executable records the library (`otool -L`; `ldd` on Linux) | yes |
| the library moved away: the executable does not start | yes |

So Apple's ld resolved `-lbotlish_cffi_shared` to the `.dylib`, the
executable depends on it at run time, and dyld loads it from the install
name the library carries. What this does **not** establish, and the milestone does
not claim: an rpath, `@rpath`/`@executable_path` install names, framework
linking, or any search-path policy of Botlish's own -- Botlish adds no
rpath on either platform, so a shared library must be where the platform's
loader finds it (its absolute install name on macOS; `LD_LIBRARY_PATH` or
the system's directories on Linux). The system C library is a dynamic
library too: `cf-system-symbol-resolved` checks that `labs` is imported
from libSystem (`nm -m`: "(undefined) external _labs (from libSystem)"),
from glibc on Linux (`nm -D`: `labs@GLIBC_...`), never defined inside the
executable.

## 8. Apple AArch64 calling-convention evidence

What Apple's ABI ("Writing ARM64 code for Apple platforms") changes from
AAPCS64 for the classes Botlish passes -- C integers of 1, 2, 4 and 8 bytes,
`_Bool`, and pointers, all in general-purpose registers and on the stack:

| Rule | AAPCS64 (Linux AArch64) | Apple arm64 |
|---|---|---|
| a narrow argument in a register | the callee extends it; the caller leaves the upper bits unspecified | the **caller** extends it to 32 bits by its type; the callee may rely on it |
| an argument on the stack | its own 8-byte slot | **natural size and alignment**, packed: a `char` takes one byte |
| plain `char` | unsigned | **signed** |
| `long`, pointers | 64 bits | 64 bits |
| the integer argument registers | x0-x7 | x0-x7 |

Botlish states none of this itself. The convention is the triple's
(`codegen::target::c_call_conv`: `CallConv::AppleAarch64`, milestone 2),
Cranelift assigns registers and offsets, and the extension attribute on a
narrow parameter (`sext` or `uext`, by the C class) is the one fact Botlish
contributes -- now only on the register parameters under Apple's
convention (section 9).

The evidence is of three kinds, kept apart:

1. **What a C callee computes from the call** (semantic): `bcf_pick`
   returns any one of its nineteen arguments as C compiled for that
   prototype reads it (`cf-abi-pick`); the echo and widen functions return
   a scalar as C saw it (`cf-scalar-values`, `cf-scalar-extension`,
   `cf-char-target`). A
   callee that extends a narrow argument itself (AAPCS64's) can hide a
   caller that did not; an Apple callee trusts the caller, so a wrong
   extension shows as a wrong value there, but not every mistake does.
2. **The machine state the call arrives in** (ABI-level): `bcf_capture`, a
   few instructions of assembly, saves x0-x7 (all 64 bits) before any
   compiled code runs and copies the 128 bytes at the stack pointer the
   caller left, where its stack arguments start. Each Botlish binding
   declares it with the prototype under test, so the capture is exactly
   what Botlish's call put where. `cf-abi-register-extension` and
   `cf-abi-stack-layout` check it against the ABI model in c-ffi.test
   (`::abi`: eight registers, natural stack placement, caller extension to
   32 bits on macos-aarch64; eight, 8-byte slots, no caller extension on
   linux-aarch64; six, 8-byte slots, 32 on x86-64) and, independently,
   against **Apple clang's own call** of the same prototype with the same
   values (`bcf_reference_narrow8`, `bcf_reference_pick`: C calling
   `bcf_capture` through a function pointer of that type). The model is
   only read where the ABI defines bits (a register's low 32 bits or the
   argument's width; each stack argument's own bytes, never padding).
3. **Compiler-owned facts** (static): `cf-abi-stack-layout-model` pins the
   model's own offsets for the twenty-argument prototype (Apple: 0, 1, 2,
   4, 6, 8, 12, 16, 24, 26, 28, 32 -- the offsets LLVM's Apple arm64 backend
   gives the same prototype, read from `clang --target=arm64-apple-macos11
   -S` while developing on Linux), `cf-clif-stack-parameters` and
   `cf-clif` the Cranelift signature, `clif::apple_tests` Cranelift's
   disassembly of a call (section 9), `cf-abi-classes-follow-the-target`
   the target table's plain char.

A fourth kind, **successful linking** (sections 4-7, 16-18: the libraries
found, the symbols resolved, the executable loads them), says nothing about
any of the three. None of them is offered as proof of another: the capture
shows what a call put where, the callee's values that the convention is
read the same way on both sides, and the static facts that Botlish asked
Cranelift for the right thing.

## 9. The Cranelift narrow-integer investigation

Milestone 5 flagged two things in cranelift-codegen 0.135.2's AArch64 ABI
(`isa/aarch64/abi.rs`): a comment in `compute_arg_locs` -- "sign- and zero-
extensions of data types less than 32 bits are not implemented yet" -- and
`get_ext_mode`. Reading the pinned source and compiling probe calls with it
settled both:

* **The comment is stale for registers.** `get_ext_mode` returns the
  signature's attribute under `AppleAarch64` (and `None` for every other
  AArch64 convention, whose callee extends), and `gen_call_args` extends a
  narrow register argument with it: `sxtb x0, w0`, `uxtb w1, w1`, `sxth x2,
  w2`, `uxth w3, w3`, `sxtw x4, w4`, `mov w5, w5` for i8/u8/i16/u16/i32/u32
  arguments -- extended to all 64 bits, which covers Apple's 32. Botlish's
  signature carries the attribute (`c_signature`: `sext`/`uext` by the C
  class), so its register arguments are extended exactly as Apple requires.
* **Stack arguments were wrong, in a way no semantic test of the callee
  sees.** `compute_arg_locs` gives a stack argument its natural size and
  alignment under `AppleAarch64` (a 1-byte slot for an i8, packed), as
  Apple's ABI says, but `gen_call_args` then applies the same extension to
  the stack slot and stores the *extended word*: an 8-byte `str` at a 1-, 2-
  or 4-byte slot's offset. Arguments are stored in order and each later
  slot is at a higher offset, so every argument's own bytes end up right and
  the callee reads correct values; but the last one writes up to seven bytes
  past the argument area -- into the calling function's frame, where
  Cranelift puts its explicit stack slots: in Botlish, the slot holding the
  frame's GC roots.

The reduced case -- one function, an explicit 16-byte stack slot holding a
sentinel, a call through an `apple_aarch64` signature of eight i64 register
parameters and then i64, i32 `sext`, i16 `sext`, i8 `sext` on the stack,
the slot read back after the call -- compiled for `aarch64-apple-darwin`
with the pinned crate (a standalone probe while investigating; the unit
tests' `call_disassembly` builds the same function through `c_signature`):

```text
  sub sp, sp, #32                  ; 16 bytes of arguments, the slot at sp+16
  str x0, [sp, #16]                ; the sentinel
  ...
  str x10, [sp]                    ; i64 at 0
  sxtw x10, w11
  str x10, [sp, #8]                ; i32 at 8: 8 bytes stored, [8, 16)
  sxth x9, w9
  str x9, [sp, #12]                ; i16 at 12: [12, 20) -- 4 bytes into the slot
  sxtb x8, w8
  str x8, [sp, #14]                ; i8 at 14: [14, 22) -- 6 bytes into the slot
  blr x8
  ldr x1, [sp, #16]                ; the sentinel, overwritten
```

The same probe for `aarch64-unknown-linux-gnu` stores `str w9, [sp, #8]`,
`strh w10, [sp, #16]`, `strb w11, [sp, #24]` (8-byte slots, no extension:
AAPCS64's callee extends), and for Apple without the attribute on the stack
parameters `str w9, [sp, #8]`, `strh w10, [sp, #12]`, `strb w11, [sp, #14]`:
exactly Apple's layout, nothing past it.

**The fix is Botlish's signature, not Cranelift's lowering.** Apple's rule
is that the caller extends an argument narrower than 32 bits *in its
register*; a stack argument has a slot of its natural size and nothing to
extend into. So `codegen::target::c_extended_parameters` says how many
integer-register parameters keep their attribute -- the eight in x0-x7
under `AppleAarch64`, every one elsewhere -- and `c_signature` leaves it off
the rest. The count is of integer-register parameters, not positions:
AAPCS64's register assignment, which Apple keeps, counts integers and
doubles separately (x0-x7, v0-v7). When this milestone was written every
Botlish C class was an integer register; the Float64 milestone, merged into
it before it reached main, added `std::ffi::c::Double`, and the merge made
`c_signature` skip the doubles in the count
(`ffi_apple_doubles_leave_the_integer_registers`; the mutant
`doubles-counted-as-integer-registers`; section 33). Botlish still places nothing: the
registers and offsets are Cranelift's. Linux is unchanged: x86-64's stack
slots are eight bytes (an extended store is the slot), and Cranelift ignores
the attribute for Linux AArch64.

**Upstream fixed it the same way.** cranelift-codegen 0.136.0's
`get_ext_mode` takes the argument's location and returns the attribute only
for a register under `AppleAarch64` ("stack-passed arguments use their
natural (possibly sub-word) size and are not extended"); the same probe built
against 0.136.0 stores `str w`/`strh`/`strb`. Botlish stays on 0.135.2 in
this milestone (no dependency change for a port milestone); the exception's
documentation names 0.136.0, and the unit test
`ffi_apple_extended_stack_argument_defect_still_present` pins the defect, so
the upgrade that fixes it fails that test and removes the exception.

**Evidence, three ways.**

* Static: `clif::apple_tests` (driver unit tests, on any AArch64 host, where
  Cranelift has its AArch64 backend: macOS's smoke job and Linux arm64's
  Rust job) compile a call through `c_signature` for `aarch64-apple-darwin`
  and read Cranelift's own disassembly: `str w` at 8, `strh` at 12, `strb`
  at 14, and the eight narrow register arguments extended
  (`ffi_apple_stack_arguments_stored_at_their_width`); with the attribute on
  every parameter, the 8-byte store at 14 (`..._defect_still_present`).
  Removing the exception fails the first (checked under qemu-user, and the
  `apple-stack-parameters-extended` mutant, section 25).
* ABI-level: `cf-abi-stack-layout` reads the bytes at the stack pointer a
  call arrives with, Botlish's and Apple clang's own call of the same
  prototype (section 14). It reads each argument's own bytes, which the
  defect leaves right, and nothing past the last one: it does not see the
  defect (the mutant survives it).
* Behavioral: `cf-abi-stack-tail-frame` keeps Lists alive across calls
  whose stack arguments end two bytes short of the 16-byte area, under GC
  stress, and shows that the fixed calls leave the frame intact. It is
  **not** a detector of the defect: with the defect put back (the
  `apple-stack-parameters-extended` mutant) it still passed on macOS --
  in the frames Botlish generates for that function, the bytes the extra
  store reaches hold no live root at the call (the argument area is sized
  for the function's largest call, and the roots are where its stack maps
  say). The defect is caught statically, by `cf-clif-stack-parameters` and
  the disassembly test above, which is why both exist.

## 10. Scalar argument results

Semantic results: C reads what Botlish passed. All on cranelift and
cranelift-generic, on the macOS runner (the acceptance tier, Tier C under
GC stress) as on Linux x86-64 and AArch64:

* `cf-scalar-transport` (C-FFI.md's, now on macOS): every C integer
  scalar both ways at both bounds -- `SChar` -128/127, `UChar` 0/255, plain
  `Char` the target's (-128/127 on macOS), `Short` -32768/32767, `UShort`
  65535, `Int` and `UInt` at their 32-bit bounds, `Long`, `ULong`,
  `LongLong` and `ULongLong` at 64-bit ones -- beyond the small-Int range
  as BigInts, both ways.
* `cf-scalar-values` (new): each scalar at 0, 1, 42, -1, -42, both bounds
  and their neighbours (signed), or 0, 1, 42, the most significant bit
  alone, one below it, the maximum and one below it (unsigned) -- values a
  truncation or a wrong extension changes -- through C's echo, and for the
  narrow ones through C's widening (`bcf_widen_*`: C converts the
  parameter to a 64-bit `long` itself, so the value is what C's code read
  from the register). 130 calls per backend (126 on Linux AArch64, whose plain
  `char` has no negative values), `exact` on both.
* `cf-abi-pick` (new): `bcf_pick(which, a1 ... a19)` returns argument
  `which` as C compiled for the twenty-parameter prototype reads it;
  Botlish calls it nineteen times with the same distinct values (narrow
  negatives, high unsigned values, a 64-bit negative) and gets back
  `[-2, 253, -1234, 65244, -123456789, 4275878552, -3, -4, 247, -30000,
  -128, 48879, -2000000000, 127, -81985529216486895, 128, -2, 2147483649,
  -1]` on both backends: no argument misplaced, overlapped, truncated or
  extended the wrong way, in registers or on the stack.
* `cf-scalar-extension`, `cf-stack-arguments` (C-FFI.md's): C sees
  `widen_schar(-1)` = -1, `widen_uchar(255)` = 255, `widen_short(-2)`,
  `widen_ushort(65535)`, `widen_int(-3)`, `widen_uint(4294967295)`; ten
  mixed arguments, the stack ones each at its own weight (763,
  55835297053).
* `cf-error-sentinel`: C's own `-1` for a zero divisor is a value Botlish
  source interprets (`[42, -42, -99]`), nothing translates it.

## 11. Scalar return results

* Every echo above returns its argument: the result at its C width,
  extended by Botlish from that width (`foreign_call`'s result conversion)
  and tagged or boxed as an Int.
* `cf-scalar-extension`'s `bcf_dirty_*` are assembly that returns a narrow
  value in a register whose upper bits are deliberately wrong
  (`BCF_FUNCTION`, Mach-O spelling on macOS): `dirty_uchar` 128,
  `dirty_schar` -128, `dirty_ushort` 32768, `dirty_short` -32768,
  `dirty_uint` 4294967280, `dirty_int` -16. Botlish reads only the
  result's own width, so it relies on no extension by the callee, whatever
  the platform's rule for results; Cranelift's signature asks for none
  (`c_signature` leaves the result unextended).
* `_Bool` results: `cf-bool-transport` and `cf-bool-invalid` -- C's true
  and false, results with dirty bits above the byte, and a byte that is
  neither 0 nor 1 (`NATIVE BOOL`, naming the function and the byte) -- pass
  on macOS unchanged.
* 64-bit results beyond the small-Int range (`echo_ulong(2^64-1)`,
  `echo_long(-2^63)`) are boxed exactly; `long long` results of the stack
  tests (`bcf_stack_tail`, `bcf_pick`) likewise.

## 12. Plain C `char` verification

Plain `char` is signed under Apple's arm64 ABI (as on x86-64) and unsigned
under AAPCS64. The target table has said so since milestone 2
(`core/cabi.tcl`'s `macos-aarch64` row: `charSigned 1`), so `std::ffi::c::Char`
on macOS is -128..127. This milestone checks it against the C compiler:

* `cf-char-target`: `bcf_widen_char(c)` returns `(long)c` as Apple clang
  compiles it -- for `-1`, `-128`, `127`, `-2` it returns `-1`,
  `-128`, `127`, `-2` (an unsigned `char` would give 255, 128, 127, 254),
  `echo_char` returns both bounds, and a value outside the range is a
  compile-time error: `TYPE: main.bot:4:16: argument 1 of bcf::echo_char
  cannot be proven to satisfy std::ffi::c::Char (argument type: int)` for
  `echo_char(128)`.
* `cf-abi-register-extension` passes `(char)-3` as the eighth argument: x7
  arrives `0xfffffffd` in its low 32 bits from Botlish's call and from
  Apple clang's own (sign extension: `char` is signed).
* `cf-abi-classes-follow-the-target` (milestone 2's) pins the class the
  target gives plain char per target; the fuzzer's type model has the same
  rule (section 24).

The `macos-plain-char-unsigned` mutant (the macOS row says unsigned) is
killed on macOS by six tests -- `cf-abi-pick`, `cf-abi-register-extension`,
`cf-abi-stack-layout`, `cf-char-target`, `cf-scalar-transport`,
`cf-scalar-values` -- and by the fuzzer, whose own model has plain char
signed there (section 25).

## 13. Narrow extension results

**Signed and unsigned narrow arguments in registers, observed at the
callee's entry** (`cf-abi-register-extension`): eight arguments, exactly
x0-x7, one of every narrow class -- `signed char -2`, `unsigned char 253`,
`short -1234`, `unsigned short 65244`, `int -123456789`, `unsigned int
4275878552`, `_Bool true`, `char -3`. What `bcf_capture` read in each
register's low 32 bits, Botlish's call and Apple clang's reference call
alike, against the model's expectation:

| Register | C type | Value | Low 32 bits expected and observed |
|---|---|---|---|
| x0 | `signed char` | -2 | `0xfffffffe` (sign-extended) |
| x1 | `unsigned char` | 253 | `0x000000fd` (zero-extended) |
| x2 | `short` | -1234 | `0xfffffb2e` (sign-extended) |
| x3 | `unsigned short` | 65244 | `0x0000fedc` (zero-extended) |
| x4 | `int` | -123456789 | `0xf8a432eb` |
| x5 | `unsigned int` | 4275878552 | `0xfedcba98` |
| x6 | `_Bool` | true | `0x00000001` |
| x7 | `char` | -3 | `0xfffffffd` (signed) |

(No mismatch on either backend: the test's result is `{} {}`.) On Linux
AArch64 the model reads only each argument's own width (AAPCS64's callee
extends), on x86-64 32 bits (GCC's and Clang's callers extend to 32 and
their callees rely on it).

How it is made: Cranelift extends a register argument by the signature's
attribute under `AppleAarch64` -- `sxtb x0, w0`, `uxtb w1, w1`, `sxth x2,
w2`, `uxth w3, w3`, `sxtw x4, w4`, `mov w5, w5`, `uxtb w6, w6`, `sxtb x7,
w7` in `clif::apple_tests` (to 64 bits, which includes Apple's 32), and
`c_signature` gives every register parameter its class's attribute.

Detection: `signed-argument-zero-extended` (a signed narrow parameter given
`uext`) and `unsigned-argument-sign-extended` are killed on Linux x86-64 by
`cf-abi-register-extension`, `cf-abi-stack-layout`, `cf-bool-lowering`,
`cf-clif` and `cf-clif-stack-parameters`, and on macOS by 10 and 9 tests,
the fuzzer and `ffi_apple_stack_arguments_stored_at_their_width` --
semantic tests alone would not do it everywhere: on Linux AArch64 the
callee re-extends and hides a wrong caller extension, which is why the
capture exists.

**Narrow results**: section 11.

## 14. Register and stack argument results

**The register boundary** (`cf-abi-register-boundary`): eight `long`s and a
`signed char` (`bcf_ninth(1, ..., 8, -100)` = -100; with zeros and 127 =
127), nine and a tenth `int` (`bcf_tenth(..., -7)` = -7): the first stack
argument, at the start of the argument area, arrives exact.

**Adjacent narrow stack arguments** (`cf-abi-stack-layout`): the
twenty-parameter prototype -- a selector and seven narrow arguments in
x0-x7, then twelve on the stack, adjacent narrow ones, a 64-bit one after
narrow ones and narrow ones after it. The bytes at the stack pointer the
call arrived with, Botlish's call and Apple clang's alike (the model's
offset, the argument's own little-endian bytes; padding not read):

| Argument | C type | Value | Apple offset | Bytes | AAPCS64 offset |
|---|---|---|---:|---|---:|
| s8 | `signed char` | -4 | 0 | `fc` | 0 |
| s9 | `unsigned char` | 247 | 1 | `f7` | 8 |
| s10 | `short` | -30000 | 2 | `d0 8a` | 16 |
| s11 | `signed char` | -128 | 4 | `80` | 24 |
| s12 | `unsigned short` | 48879 | 6 | `ef be` | 32 |
| s13 | `int` | -2000000000 | 8 | `00 6c ca 88` | 40 |
| s14 | `signed char` | 127 | 12 | `7f` | 48 |
| s15 | `long` | -81985529216486895 | 16 | `11 32 54 76 98 ba dc fe` | 56 |
| s16 | `unsigned char` | 128 | 24 | `80` | 64 |
| s17 | `short` | -2 | 26 | `fe ff` | 72 |
| s18 | `unsigned int` | 2147483649 | 28 | `01 00 00 80` | 80 |
| s19 | `signed char` | -1 | 32 | `ff` | 88 |

Thirty-three bytes where AAPCS64 takes ninety-six. The same test on Linux
AArch64 checks the right-hand offsets, on x86-64 fourteen 8-byte slots
after six registers; `cf-abi-stack-layout-model` pins the model's offsets
per target. `cf-abi-pick` (section 10) reads all twelve back through C.

**The frame around the call** (`cf-abi-stack-tail-frame`):
`bcf_stack_tail`'s stack arguments -- a `long` at 0, an `int` at 8, a
`short` at 12, a `signed char` at 14 -- end two bytes short of the 16-byte
area, where Cranelift 0.135.2's extended store would reach past it
(section 9). Sixty rounds keep a List in the frame across the call and
allocate after it; with and without GC stress, on both backends, the
result is `[60, 67, -700]`: every List survived the collection after each
call. That is evidence about the fixed code only: the same test passes with
the defect put back (section 9, section 25).

**Large arity**: twenty parameters is the largest prototype the fixture
has; the fuzzer generates up to 14 (section 24). Cranelift owns
the stack area's size and alignment (16 bytes at the call).

## 15. Pointer ABI results

Pointers are 64-bit words in general-purpose registers and 8-byte aligned
stack slots under both conventions; the evidence is that every bit
crosses:

* `cf-pointers` (C-FFI.md's): `std::ffi::c::null[T]()` into C is NULL, a NULL
  from C is null, a C address round-trips with its identity (C compares).
* `cf-pointer-width` (new) -- **64-bit round trips**: C's static address
  needs more than 32 bits (`bcf_needs_64_bits(p)` = 1: on macOS every
  user address is above the 4 GiB `__PAGEZERO`); `0xfffffffffffffff0` (every
  high bit set) and `0x00007ffffffffff0` (the top of the 47-bit user
  space) go into C and back through `bcf_echo_ptr` and C finds each
  identical to the original (`bcf_same` = 1), different from each other
  (0); neither is null on either side; NULL stays NULL. Result `[1, 1, 1,
  1, 0, 0, false, 0]` on both backends.
* `cf-pointer-mix` (new): twelve arguments, pointers among narrow and wide
  integers, four pointers in registers and two on the stack (beside
  narrow stack integers, so a pointer slot after a packed narrow one is
  8-byte aligned): C checks each against its expectation, a bit each --
  `4095` (`0xfff`, all twelve) on both backends.
* `cf-wild-address`: a returned address the Botlish C pointer word cannot
  hold (`0xf000000000000010`, a top-byte-tagged address) is `NATIVE
  ADDRESS` -- "the C function bcf::wild returned the address
  0xf000000000000010, which a Botlish C pointer cannot hold (its word keeps
  a sign-extended 60-bit address: a top-byte-tagged pointer is not one);
  the pointer is never truncated or masked" -- on macOS as on Linux.
* `cf-function-pointers`: a C function pointer comes back from C and is
  passed back for C to call.

Mutants: `pointer-argument-truncated` (a pointer argument passed as its low
32 bits) and `pointer-result-truncated` are killed on macOS by 12 and 4 tests
and the fuzzer each (section 25).

## 16. Named symbol and library resolution

* **A named symbol** (`cf-named-symbol`): `extern c fn plus named
  "bcf_add"(...)` -- the Botlish name `plus`, the link symbol `bcf_add`
  (`_bcf_add` in the Mach-O object, by the object crate) -- returns 42;
  `extern c fn bcf_add(...)` too; `extern c fn plus(...)` without `named`
  is NATIVE LINK (no C function `plus`). Calls of
  `named` functions run through every test above (`bcf::*` binds the
  fixture's functions by `named`). aot-facts.tcl's `c-call-run` does it
  in an executable: `widen named "bcfx_widen"` in a library of its own,
  `[42, -34458]`.
* **The system C library** (`cf-system-library`): `labs`, `abs` and
  `magnitude named "llabs"` declared by their prototypes, no library
  declared -- `[42, 7, 9223372036854775807]` on both backends -- and again
  with `extern c library "m"` (on macOS the math functions are libSystem's
  and `-lm` resolves to it; same result). `cf-system-symbol-resolved`: `_labs`
  "(undefined) external ... (from libSystem)" in the executable, never a
  definition of its own.
* **Several libraries** (`cf-link-order`): an archive declared before the
  archive it depends on links (`bcf_add_twice` = 42) on macOS without a
  group, because Apple's ld searches archives until nothing more resolves
  (section 4). `cf-link-directories` links two libraries from two
  directories.
* **Missing symbol** (`cf-undefined-symbol`): NATIVE LINK with Apple ld's
  "Undefined symbols for architecture arm64" and the symbol (section 18);
  an unused declaration needs no definition.
* **Missing library**: section 18.

## 17. `-L` search behavior

Botlish passes each `-L` directory as one argument to rustc (`-C
link-arg=-LDIR`), which passes it on to `cc` as one argv element, and the
linker's own search does the rest: no quoting, splitting or path rewriting
of Botlish's. `main.tcl -L DIR` normalizes DIR against its working
directory (`file normalize`) before the driver sees it.

`cf-link-directories`, on macOS and Linux:

| Case | Result |
|---|---|
| a directory whose path has spaces (`cf dir with spaces PID`) | 42 |
| two directories, each library in its own | 42 |
| a directory that does not exist, then one that does | 42 (at most the linker's warning) |
| a relative `-L` given to main.tcl from another working directory | `value: 42` |

aot-facts.tcl's `c-link-command` reads the command rustc ran for a program
linking a library from `WORK/c lib`: `"-LWORK/c lib"` is one argument after
`program.o`, followed by `"-lbotlish_aot_facts"`, with no `-Wl,--start-
group` and no `-nodefaultlibs` (section 4 has the macOS command). A wrong
architecture: section 18. The `link-dirs-dropped` mutant (no `-L` reaches
the linker) is killed by 51 c-ffi tests and the fuzzer on Linux x86-64
and the same on macOS.

## 18. Apple linker diagnostics

A failed link is NATIVE LINK whose message keeps the linker's own lines
(`linker_diagnostics`): before this milestone it kept GNU ld's and lld's
(`undefined reference`, `cannot find`, `ld:`, `collect2`); it now also keeps
Apple ld's undefined-symbol block and clang's closing line. Observed on the
macOS runner (aot-facts.tcl, run
[39376981482](https://github.com/mwagner-webdev/botlish/actions/runs/39376981482),
smoke job, and every smoke job since):

**A missing library** (`extern c library "botlish_aot_facts_missing"`):

```text
native link failed: the system linker could not link this program with the C functions and libraries it declares (libraries -lbotlish_aot_facts_missing):
error: linking with `cc` failed: exit status: 1
= note: ld: warning: ignoring duplicate libraries: '-lSystem'
ld: library 'botlish_aot_facts_missing' not found
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

**An undefined symbol** (`extern c fn botlish_aot_facts_nope`, called):

```text
native link failed: the system linker could not link this program with the C functions and libraries it declares (symbols botlish_aot_facts_nope; libraries -lbotlish_aot_facts):
error: linking with `cc` failed: exit status: 1
= note: ld: warning: ignoring duplicate libraries: '-lSystem'
Undefined symbols for architecture arm64:
"_botlish_aot_facts_nope", referenced from:
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

The `ignoring duplicate libraries: '-lSystem'` warning is Apple ld's
comment on rustc's own `-lSystem` beside the C driver's default one
(`default-linker-libraries=yes`, section 4); it is harmless, and appears
only in a failed link's message (a successful link's output is not shown).
The symbol is printed as the linker sees it (`_` prefixed); the first line
names it as declared.

c-ffi.test checks the same through the native backends' linked run:
`cf-missing-library` (NATIVE LINK naming the library: Apple's `library
'...' not found`, GNU ld's `cannot find -l...` or lld's `unable to find
library -l...`), `cf-undefined-symbol`
(`Undefined symbols` / `undefined reference`, case-insensitively), and
`cf-wrong-architecture`: an archive Apple clang compiled for `-arch x86_64`
(clang's other Linux target on Linux) is refused by the linker with a line
naming the archive and what is wrong with it (on Linux x86-64, `rust-lld:
error: .../libbotlish_cffi_foreign.a(foreign.o) is incompatible with
elf64-x86-64`), then the undefined symbol; nothing runs. The
`apple-linker-diagnostics-dropped` mutant (Apple's lines filtered out) is
killed by `ffi_linker_diagnostics_keep_the_linkers_words` (Rust, every
host) and, on macOS, by `cf-undefined-symbol` too.

A failed link publishes nothing (`cf-link-failure-keeps-executable`): an
executable linked earlier at the same path still runs (42), and no
`.botlish-aot-*` directory is left beside it -- as milestone 5 established
for ordinary executables, now for a C program's link failure.

## 19. Native linked-backend behavior

A program that calls C cannot run in the JIT: its symbols are the system
linker's to resolve. `run_linked` (C-FFI.md, unchanged) links it into a
private executable, runs it in the driver protocol (the result line on
`--result`, the program's output inherited) and removes it. On macOS that
link is the Apple link of section 4. Every c-ffi test that calls C on
`cranelift` or `cranelift-generic` goes this way, and main.tcl
(`cf-main-tcl`: `main.tcl -backend cranelift -L DIR` prints `value: 42` and
the program's own output in its place; `cf-argv`: the run's argument
vector) -- on macOS as on Linux. native-status.tcl's `c-call` probe
(`labs(-5)`) now records `5` for macos-aarch64 where it recorded the
refusal (section 1).

The native backends' results do not depend on the backend: every
two-backend test above returns the same on cranelift and
cranelift-generic.

## 20. Standalone C-call executable behavior

* `cf-executable`: `-emit-native-executable` of a program calling the
  fixture; the executable is moved out of its build directory, the
  application's source deleted, and run with an empty environment (`env
  -i`) -- 42, no Tcl, no rustc, no source. On macOS the executable is the
  Mach-O of milestone 5 (ad-hoc linker signature) with the fixture's code
  linked in.
* aot-facts.tcl `c-call-run` (macOS smoke, every push):
  `exit 0, stdout "[42, -34458]\n"` -- libSystem's `labs(-42)` and
  `bcfx_widen(-1, 65535, 7)` from a static library the runner's clang
  compiled, through `named`, a `signed char` and an `unsigned short` (C
  computes `c * 100000 + s + l` = -100000 + 65535 + 7); `c-call-import`:
  `_labs imported from libSystem`.
* `cf-system-symbol-resolved`, `cf-shared-library` (sections 7, 16): the
  imports are the platform's dynamic linker's.
* `cf-gc-calls`, `cf-coroutine-calls`, `cf-c-stack-overflow` (sections
  21-22) run as executables too.
* The stub linker still refuses a C program (`cf-stub-linker`), naming the
  linker that can: unchanged, and the stub is Linux x86-64 only anyway.

## 21. Coroutine and GC-stress results

* `cf-gc-calls` (new): 400 rounds of allocation around C calls (a String
  built by concatenation, Lists holding C results, `bcf_pick`'s twenty
  arguments), under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at
  every allocation site): `[400, 13, 412]` on both backends and as an
  executable.
* `cf-coroutine-calls` (new): C calls in a coroutine body before the first
  yield and between later ones (including the twelve-argument stack call),
  values held across yields and calls, a hundred coroutines, under GC
  stress: `[[6, -75, 0], 100, 2]` on both backends and as an executable.
  The C call runs on the coroutine's own stack: the Apple stack-argument
  area is the coroutine stack's, and the frame walk finds the roots there.
* `cf-abi-stack-tail-frame` (section 14), under GC stress.
* `cf-gc-stress` (C-FFI.md's: the read and write exposures under
  stress) runs on macOS; its Tcl and SHA-256 parts stand in their expected
  values where the libraries are absent, as on the runner (section 30).
* Tier C: c-ffi.test, c-bindgen.test, native-view.test, native-edit.test,
  layout-arrays.test and the c-ffi fuzzer (seeds 1, 2, 9) under GC stress
  on the macOS runner, run
  [39377475266](https://github.com/mwagner-webdev/botlish/actions/runs/39377475266):
  301 tests per pass (interp and compile drivers), 258 passed, 0 failed,
  43 skipped (the BoringSSL, Tcl, SDL3 and MinGW tests without their
  sources and libraries, c-bindgen's checks of the committed Linux
  bindings, x86-64's `cf-bool-register`, and six allocation-count and
  GC-stress tests of native-view, native-edit and layout-arrays that keep
  their own `nativeLinux` constraint, section 30); the fuzzer 30
  programs, 360 C functions, 0 disagreements.

## 22. Stack-overflow results

`cf-c-stack-overflow` (new): `bcf_deep(n)` recurses in C (a non-tail call
with a buffer per frame). With an exhausting depth, on the worker thread
and inside a coroutine (16 MiB native stack, `BOTLISH_NATIVE_STACK_BYTES`),
the stack guard of milestone 4 classifies the fault in C code as an
overflow of the published stack:

| Run | Result |
|---|---|
| `bcf::deep(100000000)`, cranelift (linked run) | `{LIMIT STACK} {native stack exhausted: too many nested calls}` |
| `bcf::deep(2000)` | `2000` |
| the deep call inside a coroutine, cranelift | `{LIMIT STACK} ...` |
| both as executables | exit status 1, `error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}` on stderr |

never a signal or a crash report. The guard needed no change: its handler
classifies by the faulting address against the guard of the stack
published as running, whoever's code faulted. aot-facts.tcl's
standalone-overflow checks (milestone 5's) pass unchanged in the same smoke
jobs.

## 23. C binding-generator compatibility

c-bindgen.test was in `notYet` because its fixture comparison
(`cb-fixture-current`) compared the regenerated fixture binding with the
committed one byte for byte, manifest included -- and the manifest records
the generating toolchain (`toolchain_version`: the C compiler's version
string, repeated in its `evidence` and `layout_abi` lines and layouts.tsv's
header; `preprocessed_tokens`: how many tokens its preprocessor produced,
which depends on its own headers). On macOS the runner's Apple clang
generates the binding, not the Ubuntu clang that generated the committed
one.

The oracle was not weakened: everything the generator derives from the C
compiler's answers -- every binding, every layout, every type, constant and
symbol, the thunks -- is still compared byte for byte. Only the provenance
is separated (`asRecordedToolchain`): the test puts the committed version
string back wherever the generation wrote its own and the committed token
count in `preprocessed_tokens`, and recomputes the manifest's checksums of
the files that held the version -- only when the toolchain is otherwise the
recorded one, the **same family (clang) and target triple**; anything else
is compared byte for byte, provenance included, and fails. The generator's
own `check` command stays byte for byte. A new test,
`cb-fixture-current-provenance`, prints both provenances, so the
difference is visible, not hidden:

```text
cb-fixture-current-provenance: linux-x86_64 generated with {Apple clang version 17.0.0 (clang-1700.0.13.5)} 1755, committed with {Ubuntu clang version 18.1.3 (1ubuntu1)} 1755
cb-fixture-current-provenance: linux-aarch64 generated with {Apple clang version 17.0.0 (clang-1700.0.13.5)} 1725, committed with {Ubuntu clang version 18.1.3 (1ubuntu1)} 1725
cb-fixture-current-provenance: macos-aarch64 generated with {Apple clang version 17.0.0 (clang-1700.0.13.5)} 1691, committed with {Ubuntu clang version 18.1.3 (1ubuntu1)} 1691
cb-fixture-current-provenance: windows-x86_64-gnu generated with {Apple clang version 17.0.0 (clang-1700.0.13.5)} 1757, committed with {Ubuntu clang version 18.1.3 (1ubuntu1)} 1757
```

(Tier C, run 39377475266.) Only the version string differs: Apple clang
17 and Ubuntu clang 18 preprocess the fixture's headers to the same number
of tokens for every target, and every binding, layout, shim and report
they generate is byte-identical -- `cb-fixture-current` passes on macOS
with the version string put back and nothing else.

c-bindgen.test's `nativeRun` tests -- generated bindings compiled and
called -- now run where C calls run (`nativeCCalls`), so on macOS too. The
Tcl, BoringSSL and SDL3 profile tests stay skipped on the runner, as on any
host without their pinned sources and libraries (section 30); nothing in
the generator changed.

## 24. Fuzzer results

`audit/c-ffi/tools/fuzz.tcl` (C-FFI.md's) generates programs of random C
signatures -- 0 to 14 parameters of every scalar class and raw and byte
pointers, past the argument registers onto the stack -- writes them as real
C, compiles them with the host's C compiler into a library, calls them from
Botlish on both native backends and compares what C saw of every argument
and the result with its own ABI model (its own table of widths and
signedness, plain char signed on every target but Linux AArch64,
independent of the compiler's). It ran on macOS for the first time:

| Host | Run | Programs | C functions | Disagreements |
|---|---|---:|---:|---:|
| macOS arm64 (Tier C, run 39377475266; GC stress on) | `-n 10 -seed 1` | 10 | 120 | 0 |
| macOS arm64 | `-n 10 -seed 2` | 10 | 120 | 0 |
| macOS arm64 | `-n 10 -seed 9 -gc-stress 1` | 10 | 120 | 0 |
| Linux x86-64 (C-FFI.md's recorded runs, audit/c-ffi/fuzz-result.txt) | seeds 1-4 (`-n 20`), 9 (`-n 10 -gc-stress 1`) | 90 | 1,080 | 0 |
| Linux x86-64 (this container, after this milestone's changes) | `-n 20 -seed 11`, `-n 10 -seed 12 -gc-stress 1` | 30 | 360 | 0 |

The fuzzer is a semantic oracle (section 8, kind 1): it would not see the
stack-overflow defect of section 9, whose stores leave every argument's own
bytes right. It did not need a change for macOS: its model already had
Apple's plain char (milestone 2), and it never models where an argument
goes, only what C reads.

## 25. Mutation results

`audit/c-ffi/tools/mutate.tcl` now takes per-host mutants -- a `%% TARGET
...` line after a mutant's header names the hosts that compile its code
differently; elsewhere it is SKIPPED, never counted as killed -- and runs
on macOS (its timeout no longer uses `timeout(1)`, which macOS lacks). 17
new mutants, each a bug this milestone's code or tests must catch:

| Mutant | What it breaks | Hosts | Linux x86-64 | macOS arm64 |
|---|---|---|---|---|
| `macos-link-plan-is-gnus` | macOS gets GNU ld's plan (the archive group) | macOS | skipped | killed: 53 tests (Apple's ld refuses every C link), the fuzzer, `ffi_link_plan_flavor_is_the_hosts` |
| `apple-plan-has-group` | Apple's plan keeps the group | all | killed: `ffi_link_plan_apple_has_no_gnu_flags` | killed: 53 tests, the fuzzer, the same Rust test |
| `apple-default-libraries-dropped` | Apple's plan keeps rustc's `-nodefaultlibs` | all | killed: `ffi_link_plan_apple_has_no_gnu_flags` | killed: the same Rust test **only** (section 4) |
| `link-dirs-dropped` | no `-L` reaches the linker | all | killed: 51 tests, the fuzzer, 2 Rust tests | killed: 51 tests, the fuzzer, 2 Rust tests |
| `apple-linker-diagnostics-dropped` | Apple ld's lines filtered out of NATIVE LINK | all | killed: `ffi_linker_diagnostics_keep_the_linkers_words` | killed: `cf-undefined-symbol`, the same Rust test |
| `apple-stack-parameters-extended` | section 9's defect back: stack parameters keep their extension | macOS, Linux AArch64 | skipped | killed: `cf-clif-stack-parameters`, `ffi_apple_stack_arguments_stored_at_their_width` (no semantic or capture test: section 9) |
| `apple-register-boundary-off-by-one` | x7 taken for a stack parameter, unextended | macOS, Linux AArch64 | skipped | killed: `cf-abi-pick`, `cf-abi-register-extension`, `cf-abi-stack-layout`, the fuzzer, the Rust test |
| `apple-convention-is-linuxs` | foreign calls compiled with AAPCS64 (SystemV), not Apple's | macOS | skipped | killed: 14 tests, the fuzzer, both `apple_tests` |
| `signed-argument-zero-extended` | a signed narrow argument zero-extended | macOS, Linux x86-64 | killed: 5 tests (`cf-abi-register-extension`, `cf-abi-stack-layout`, `cf-bool-lowering`, `cf-clif`, `cf-clif-stack-parameters`) | killed: 10 tests, the fuzzer, the Rust test |
| `unsigned-argument-sign-extended` | an unsigned narrow argument sign-extended | macOS, Linux x86-64 | killed: 4 tests | killed: 9 tests, the fuzzer, the Rust test |
| `short-class-is-int` | a 16-bit class given a 32-bit machine type | all | killed: 3 tests, the fuzzer | killed: 9 tests, the fuzzer, both `apple_tests` |
| `pointer-argument-truncated` | a pointer argument's low 32 bits only | all | killed: 13 tests, the fuzzer | killed: 12 tests, the fuzzer |
| `pointer-result-truncated` | a pointer result's low 32 bits only | all | killed: 6 tests, the fuzzer | killed: `cf-function-pointers`, `cf-pointer-mix`, `cf-pointer-width`, `cf-wild-address`, the fuzzer |
| `macos-plain-char-unsigned` | the macOS row's plain char unsigned | macOS | skipped | killed: `cf-abi-pick`, `cf-abi-register-extension`, `cf-abi-stack-layout`, `cf-char-target`, `cf-scalar-transport`, `cf-scalar-values`, the fuzzer |
| `mach-o-symbol-double-prefixed` | the import declared `_NAME`, so `__NAME` in the object | macOS | skipped | killed: 53 tests, the fuzzer |
| `link-failure-removes-earlier` | a link deletes the earlier executable before it knows it succeeds | all | killed: `cf-link-failure-keeps-executable` | killed: the same |
| `fixture-wrong-architecture` | the tests' fixture compiled for x86-64 on macOS | macOS | skipped | killed: 48 tests |

The Linux x86-64 run (this container, 2026-10-20) and the macOS run (run
[39379524425](https://github.com/mwagner-webdev/botlish/actions/runs/39379524425),
Tier C job 118485468440 at bad0deb, `CI-Tests: c-ffi-mutants`) are
recorded in `audit/c-ffi/mutate-result.txt`:

* **macOS arm64: 44 mutants, 44 killed, 0 survived, 0 skipped** (54
  minutes): the 27 of C-FFI.md -- every one now also killed on Apple
  Silicon, by tests that run there for the first time -- and the 17 above.
* **Linux x86-64: the 17 new ones, 10 killed, 0 survived**; the other 7
  are macOS's code (or AArch64's) and skip there. C-FFI.md's 27 were killed
  on this host before (its section 22).

Two kills deserve their caveat. `apple-default-libraries-dropped` is
killed by the argument-pinning unit test alone (section 4: no behavior on
the runner depends on the C driver's default libraries today), like
C-FFI.md's `link-group-dropped` on an lld host. `apple-stack-parameters-
extended` is killed only by the static tests: no test that runs the call
sees it (section 9).

`audit/native-aot/tools/mutants.txt`'s two `C_CALLS` mutants were rewritten
for the new gate: `c-calls-refused-on-macos` (the gate closed for macOS
again) and `c-calls-refused-on-linux`. The whole AOT set: **macOS, 14
mutants, 12 killed, 0 survived, 2 skipped** (Linux's code; same Tier C
job, 7 minutes) -- `c-calls-refused-on-macos` by native-status `c-call` and
aot-facts.tcl, which died with a Tcl error rather than a failed check under
it (fixed in 76e4073: `c-call-run` now reports a failed C link as `FAIL`,
with the linker's words); **Linux x86-64, 14 mutants, 11 killed, 0
survived, 3 skipped** (this container).

## 26. Performance observations

`bench/c-ffi.tcl` (C-FFI.md section 21; two rows added: `stack 12`, twelve
arguments with four on the stack on AArch64, and `stack 20`, `bcf_pick`'s
twenty with twelve on the stack), best of 5 runs of 100,000 calls per
program; ns per iteration of the loop without the call / with it / the
difference:

| Row | macOS arm64 (runner, run 39379524425) | Linux x86-64 (this container) |
|---|---|---|
| `count` (no argument) | 21.2 / 21.6 / 0.4 | 34.8 / 38.3 / 3.6 |
| `add` (two ints) | 26.0 / 22.7 / -3.2 | 33.8 / 36.3 / 2.5 |
| `big` (a 64-bit value beyond the small Int range, both ways) | 25.3 / 62.7 / 37.4 | 33.0 / 76.3 / 43.4 |
| `stack 12` (4 on the stack on AArch64, 6 on x86-64) | 25.9 / 23.1 / -2.9 | 34.7 / 40.4 / 5.7 |
| `stack 20` (12 on the stack on AArch64, 14 on x86-64) | 22.1 / 33.2 / 11.1 | 34.3 / 59.0 / 24.8 |
| `read 64` / `65536` / `1048576` (a read exposure) | 0.8 / 9.7 / -128.7 | 6.7 / 5.2 / 16.8 |
| `write 64` / `65536` / `1048576` (a write exposure: the detach copies) | 66.7 / 6006.5 / 94586.1 | 68.7 / 13165.4 / 84910.7 |

Compile and link, ms (best of 5):

| | macOS arm64 | Linux x86-64 |
|---|---:|---:|
| no C: `native::evalHir` (JIT) | 8.7 | 7.2 |
| no C: `native::executable` | 451.9 | 428.5 |
| calls C: `native::evalHir` (a linked run, `run_linked`) | 508.1 | 437.3 |
| calls C: `native::executable` | 465.8 | 456.1 |

(The two hosts are different machines -- a 3-core M1 VM, a 4-core x86-64
container -- so only each column's relations mean anything. SHA-256 rows
are skipped on both: no package-owned BoringSSL.)

What the numbers say:

* A C call is about free next to the loop on macOS (a few ns either way is
  the loop's noise, as on Linux): the fixture's functions are linked into
  the executable and called directly, with no per-call lookup.
* Arguments cost their conversions, not their placement: twelve stack
  arguments under Apple's packing add about 11 ns over a call without
  them; the 64-bit BigInt row is the boxing, on both hosts.
* Byte exposures behave as C-POINTER-BORROWING.md says on macOS too: a
  read is flat in the size (no copy), a write is linear (the detach).
* **Linking is the cost of calling C**, on both platforms: a program that
  calls C runs on the native backends as an executable linked for the
  run, so `native::evalHir` takes about 0.5 s instead of 9 ms -- the
  executable link's cost, Apple's ld as GNU's lld. aot-facts.tcl's
  `c-call-run` (a link and a run of the C library and libSystem) took 483
  ms on the runner.

## 27. macOS GitHub Actions run links

Workflow `.github/workflows/macos-arm64.yml` ("tests (macos arm64)"),
`macos-15` arm64 runners:

| Run | Commit | What it showed |
|---|---|---|
| [39365936272](https://github.com/mwagner-webdev/botlish/actions/runs/39365936272) | 2786a81 (main, before) | native-status `c-call`: the NATIVE LINK refusal; c-ffi.test and c-bindgen.test in `notYet` |
| [39375814220](https://github.com/mwagner-webdev/botlish/actions/runs/39375814220) | fe560af | smoke: the gate open, native-status `c-call` 5, the driver's unit tests (`clif::apple_tests`) on Apple Silicon; superseded by the next push before acceptance finished |
| [39376981482](https://github.com/mwagner-webdev/botlish/actions/runs/39376981482) | 248f284 | smoke: aot-facts' C-call checks -- `c-library`, `c-call-run`, `c-call-import`, Apple ld's missing-library and undefined-symbol diagnostics -- and one failure in the check itself (`c-link-command` compared `-L` with the unnormalized `/var/...` while rustc's argument had `/private/var/...`), fixed in 0866e38 |
| [39377475266](https://github.com/mwagner-webdev/botlish/actions/runs/39377475266) | 0866e38 | smoke: every aot-facts check, the C-call ones included, and the macOS link command of section 4; Tier C under GC stress: c-ffi.test, c-bindgen.test, native-view, native-edit, layout-arrays (301 tests per pass, 0 failed) and the fuzzer (0 disagreements), section 21; its acceptance shards were cancelled by the next push |
| [39379524425](https://github.com/mwagner-webdev/botlish/actions/runs/39379524425) | bad0deb | every job green: smoke; acceptance, both shards -- 197 Tcl test files on interp and 95 golden suites on all four backends, 0 failed, c-ffi.test and c-bindgen.test among them; Tier C: 44 of 44 C FFI mutants killed, 12 of 14 AOT mutants (2 Linux-only skipped), the benchmark (sections 25-26) |
| [39387800323](https://github.com/mwagner-webdev/botlish/actions/runs/39387800323) | 76e4073 | every job green: smoke (aot-facts with its failed-link report), both acceptance shards (c-ffi.test with `cf-availability-check`), the Linux control; the last code change of the milestone (38fe69f after it is documentation and main's README) |

## 28. Linux x86-64 regression results

The Linux link plan is byte-identical (`LinkerFlavor::Gnu`,
`ffi_link_plan_is_one_linker_group`), the foreign signature is unchanged on
Linux (`c_extended_parameters` is unbounded under every convention but
`AppleAarch64`), and the fixture's x86-64 assembly is the same text under a
narrower guard.

* `tests.yml` on the branch (workflow_dispatch) at 0866e38, run
  [39377717325](https://github.com/mwagner-webdev/botlish/actions/runs/39377717325):
  **success**, every job green -- the whole Tcl suite on interp and compile
  (duplicates included), its cranelift and cranelift-generic coverage, the
  four golden shards beside their Tcl originals, the native Rust unit
  tests, the stub-linked executables, the warning gate and the method-call
  filter audit; the GC-stress job runs on pushes to main only (skipped on
  a dispatch). The one later change to code under test, bad0deb's
  `cf-wrong-architecture` (a test), passes in this container and on macOS.
* This container (Linux x86-64): `tests/c-ffi.test` 84 tests, 81 passed, 3 skipped
  (`cf-availability-check`, macOS's, and the two BoringSSL tests: no
  package-owned BoringSSL here), 0 failed;
  the native Rust unit tests (`--lib --bins`); `tests/c-bindgen.test`;
  `tests/native-executable.test`, `tests/platform/aot-facts.tcl` (the new
  C-call checks: `c-link-command` shows lld's link with `-Wl,--start-group`
  around the plan); the mutants of section 25.
* The macOS workflow's `linux control` job (ubuntu x86-64) runs the same
  smoke tier, aot-facts included, on every push: green on every run above.

## 29. Linux AArch64 regression results

`tests-arm64.yml` on the branch (workflow_dispatch) at bad0deb, run
[39379530108](https://github.com/mwagner-webdev/botlish/actions/runs/39379530108)
(ubuntu-24.04-arm): the Tcl suite on interp and compile, its cranelift and
cranelift-generic coverage, the four golden shards and the native Rust unit
tests and the native GC-stress run (the whole suite under
`BOTLISH_NATIVE_GC_STRESS=1`, 89 minutes) all green -- **success**. The run
at fe560af,
[39375824830](https://github.com/mwagner-webdev/botlish/actions/runs/39375824830),
succeeded too. The later commits change no code that Linux AArch64
compiles differently: comments, the macOS-only `cf-availability-check`,
and aot-facts.tcl's failed-link path (exercised in this container, and run
by every macOS workflow's Linux control job). Linux AArch64 is where a wrong caller
extension is invisible to a callee (AAPCS64's callee extends), and where
Cranelift ignores the extension attribute: the capture tests check there
that Botlish's register arguments carry their own width's bits and its
stack arguments their own 8-byte slots (`cf-abi-stack-layout`'s AAPCS64
offsets), and `clif::apple_tests` -- an Apple-triple compilation, which
needs only Cranelift's AArch64 backend -- runs in the arm64 job's Rust
tests as on macOS. Before pushing, the Apple unit tests were also run on
this x86-64 container under qemu-user (the driver cross-built for
`aarch64-unknown-linux-gnu`), with and without the workaround (section 9).

## 30. Remaining C FFI limitations

On macOS, as on Linux, by design of this milestone (none is a regression):

* **No `float`, `long double`, aggregates by value, variadic calls,
  callbacks into Botlish, C++ or Objective-C**: unchanged from C-FFI.md
  section 26 (C `double` arrived with FLOAT64-MILESTONE-1.md; section 33).
  Variadic calls deserve a warning specific to Apple: Apple's arm64 ABI
  passes *every* anonymous argument of a variadic call on the stack, in
  8-byte slots, unlike AAPCS64 -- so declaring a variadic C function such
  as `open` or `printf` with a fixed prototype is not merely unsupported
  but wrong on macOS (the arguments go in registers, the callee reads the
  stack). Botlish has no way to declare one variadic; a binding must not
  pretend. (Since VARIADICS-VERTICAL-SLICE-1.md it has: an `extern c fn`
  ending in `variadic`, whose calls pass every trailing argument on
  Apple's stack in an 8-byte slot.)
* **Shared libraries**: linked and loaded (section 7), but no rpath,
  `@rpath`, framework or install-name policy of Botlish's: a library must
  be where dyld finds it. Frameworks (`-framework`) cannot be declared.
* **The stub linker** stays Linux x86-64's; macOS executables are rustc's
  (milestone 5).
* **The Tcl and BoringSSL acceptance tests** (`cf-tcl-acceptance`,
  `cf-sha256-*`) are skipped on the macOS runner: the Tcl CI build is not a
  linkable `-ltcl9.0` on the default path, and the SHA-256 binding declares
  `extern c library "stdc++"` (GNU's), which macOS spells `c++` -- a
  per-platform library list is a language question (audit section 10,
  roadmap 10). The generator's Tcl, BoringSSL and SDL3 profile tests are
  skipped there likewise.
* **Cranelift 0.135.2's Apple stack-argument store**: worked around, not
  fixed; the upgrade to 0.136.0 removes the workaround (section 9).
* **Outside C calls**: six tests of native-view, native-edit and
  layout-arrays (`nv-allocations`, `nv-gc-stress`, `ne-allocations`,
  `ne-gc-stress`, `la-native-allocations`, `la-gc-stress`: allocation
  counts and GC stress of views, edits and arrays) still carry their
  files' own `nativeLinux` constraint, from before the port (the rest of
  those files, their C oracles included, now runs on macOS). Enabling
  them is a later milestone's, and the constraint should then name a
  capability (`nativeCoroutines`, as tests/helpers.tcl's rule says).
* **macOS x86-64 (Intel)** is no target: the fixture's x86-64 assembly is
  guarded from Apple, and nothing claims Intel Macs.

## 31. Prerequisites for byte borrowing

The borrowing mechanism (C-POINTER-BORROWING.md: `hir/borrow.tcl`,
`ExposeStorage`/`KeepExposedAlive`, the write detach) is OS-neutral, and
c-ffi.test's borrowing tests through real C -- `cf-borrow-read`,
`cf-borrow-write`, `cf-borrow-sha256-shape`, `cf-borrow-refusals`,
`cf-result-provenance`, `cf-contract-violation` -- now run on macOS
because c-ffi.test does. That is not the borrowing milestone (roadmap 8),
and this milestone does not claim it. What it still needs:

1. **The borrowing tools on macOS**: audit/c-pointer-borrowing/tools uses
   `exec timeout` (macOS has none; audit/c-ffi/tools/mutate.tcl's
   `after`-based timeout is the pattern) and has no per-host mutant lines
   (`%%`, as c-ffi's now has).
2. **c-pointer-borrowing.test's real-C parts and the fuzzer on macOS**, also
   under GC stress (Tier C), and the non-syscall parts of abi-bytes and
   abi-mutable-bytes: an exposure's address is a payload address of the
   macOS heap, and `rt_bytes_addr`'s small-Int check (audit section 9,
   "47-bit Linux x86-64 user space" in its comment) must be confirmed for
   macOS addresses.
3. **A real byte-consuming C library on macOS**: the SHA-256 acceptance
   needs BoringSSL linked with libc++ (`c++`, not `stdc++`), which needs a
   per-platform library declaration or a binding per platform.
4. Nothing in the call ABI: an exposure is a pointer argument (section 15
   covers pointers in registers and on the stack), and a write-back is
   ordinary Botlish code after the call.

## 32. Prerequisites for Darwin IO

Darwin IO (roadmap 9) is libSystem through C calls behind `std::io::IO`, never
raw Darwin syscalls (the doctrine: Darwin's syscall interface is private).
This milestone supplies the call: libSystem functions declared by their
prototypes link and resolve (`cf-system-library`,
`cf-system-symbol-resolved`), with `std::ffi::c` types sized by the macOS row.
What Darwin IO still needs:

1. **Byte borrowing on macOS** (section 31): `write(int, const void *,
   size_t)` and `read` take byte buffers (`read noescape` and `write
   noescape` exposures).
2. **No variadic prototypes**: `open` and `fcntl` are variadic, and on
   Apple arm64 a fixed prototype for a variadic function passes its
   optional arguments in the wrong place (section 30). Darwin IO must use
   non-variadic entry points or wait for variadic support (which
   VARIADICS-VERTICAL-SLICE-1.md added: `extern c fn open(path: ...,
   flags: std::ffi::c::Int, variadic) -> std::ffi::c::Int`).
3. **errno**: Darwin's is `*__error()`, a thread-local reached through a
   function returning `int *`. Botlish has no C dereference; reading it
   needs a native view of a one-field layout (NATIVE-LAYOUT-VIEWS.md) or a
   different error protocol -- the Darwin IO milestone's decision.
4. **A platform module**: a `darwin`-style namespace designated a platform
   in core/cabi.tcl's `platforms` table (never by spelling), its context
   implementing `std::io::IO`, selected by `hir::contexts` on macos-aarch64
   while LinuxIO stays Linux's (the context-traits tests), and its
   directness from its retaining calls if any (C-FFI.md section 9).
5. **Its tests**: portable-io.test on macOS, a macOS twin of
   examples/io/hello.bot, golden suites declaring their host.

## 33. The merge with Float64

The Float64 milestone (FLOAT64-MILESTONE-1.md) reached main while this one
was on its branch, and added C `double` (`std::ffi::c::Double`, ABI class
`f64`) to the C FFI. On main, macOS refused every C call, so its double
tests ran on Linux only. Merging the two opened C calls with doubles on
macOS, and needed two changes beyond the textual merge:

* **The count of extended parameters.** `c_signature` gave the extension
  attribute to the first eight *parameters* under Apple's convention, true
  only while every C class used an integer register. With doubles before
  them, narrow integers in x0-x7 can be the ninth parameter or later and
  would lose the extension Apple's callee relies on. `c_signature` now
  counts integer-register parameters and skips the doubles. Checked three
  ways:
  - `ffi_apple_doubles_leave_the_integer_registers`, the disassembly of
    eight doubles then the eight narrow classes (`sxtb x0, w0` ... `sxtb x7,
    w7`), run under qemu-user for the merge and in every macOS smoke job;
  - `cf-abi-doubles-before-integers`, the same prototype through
    `bcf_capture`, against the C compiler's own call of it on every host;
  - the mutant `doubles-counted-as-integer-registers` (the old count back),
    which the unit test kills under qemu-user.
* **Doubles on macOS, validated.** float64.test's C double tests (round
  trips in v0-v7 and on the stack, mixed with integer parameters, NaN, the
  infinities and negative zero coming back) build their fixture wherever C
  calls run (`nativeCCalls`), so they run in the macOS acceptance tier.

CI for the merged branch: section 34.

## 34. CI of the merged branch

At 8210f85 (the merge with main and section 33's changes), every run green:

* **macOS**, run
  [39396419481](https://github.com/mwagner-webdev/botlish/actions/runs/39396419481):
  smoke, both acceptance shards, the Linux control job, and Tier C under
  GC stress: c-ffi.test and float64.test on interp and compile -- 140 tests
  each pass, 134 passed, 0 failed, 6 skipped (the BoringSSL and libtcl
  tests, x86-64's `cf-bool-register`, and float64.test's own Linux-only
  executable and GC-stress constraints; its C double tests ran) -- and two
  mutants: `doubles-counted-as-integer-registers` killed by
  `cf-abi-doubles-before-integers` and
  `ffi_apple_doubles_leave_the_integer_registers`,
  `apple-register-boundary-off-by-one` by four `cf-abi-*` tests, the
  fuzzer and both Apple register tests.
* **Linux x86-64**, `tests.yml` run
  [39396426013](https://github.com/mwagner-webdev/botlish/actions/runs/39396426013):
  every job green (GC stress runs on main's push).
* **Linux AArch64**, `tests-arm64.yml` run
  [39396429781](https://github.com/mwagner-webdev/botlish/actions/runs/39396429781):
  every job green, the native GC-stress run included.
