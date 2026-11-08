# ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md

## Cross-compiled Botlish native libraries for Android, using independently distributed target support

> A compilation target describes where generated code executes. A target
> support package supplies the runtime artifacts required there. The
> compiler produces portable, documented build artifacts; application
> integration remains the responsibility of external tools.

Evidence is marked **observed** (run in this environment, output shown or
committed under `audit/android-aarch64-target/results/`), **static** (read
from source or artifacts), **CI** (a workflow step) or **projected** (what a
later milestone can build on). The base is main at `91f41e16`; the host is
Linux x86-64 (4 cores, Ubuntu 24.04, Tcl 9.0.1, rustc 1.97.0).

## Contents

1. [Executive result](#1-executive-result)
2. [Starting census](#2-starting-census)
3. [Android target model](#3-android-target-model)
4. [Cross-target code generation](#4-cross-target-code-generation)
5. [Runtime port](#5-runtime-port)
6. [Target support package](#6-target-support-package)
7. [Native-library emission](#7-native-library-emission)
8. [Runtime ABI integrity](#8-runtime-abi-integrity)
9. [Android ELF validation](#9-android-elf-validation)
10. [Android execution](#10-android-execution)
11. [2048 integration](#11-2048-integration)
12. [GC and lifecycle](#12-gc-and-lifecycle)
13. [Cleanroom reproduction](#13-cleanroom-reproduction)
14. [Negative tests](#14-negative-tests)
15. [Mutation testing](#15-mutation-testing)
16. [Regressions](#16-regressions)
17. [Performance and footprint](#17-performance-and-footprint)
18. [CI/platform matrix](#18-ciplatform-matrix)
19. [Remaining limitations](#19-remaining-limitations)
20. [Next milestones](#20-next-milestones)

## 1. Executive result

**Implemented, and partially validated.** From a Linux x86-64 host, the
distributed single-file compiler and an independently installed Android
AArch64 target support package build the unchanged 2048 engine into a
genuine Android AArch64 shared library (`libgame.so`), which Android's own
dynamic linker (`/system/bin/linker64`) and C library (Bionic), taken from
Google's arm64-v8a system images of **API 21, 24 and 35**, load with
`dlopen` and run: 160 deterministic moves and spawns give the interpreter's
321 states, score and facts, and the four declared errors cross the C ABI
with their identities (observed). That execution is **Android's userspace
under qemu-aarch64's user-mode emulation on the Linux host's kernel**, not an
Android device or emulator: no x86-64 or AArch64 Android emulator runs in
this container (no KVM, and Google's emulator does not run arm64 images on
x86-64 hosts). By the milestone's own rule (section 21 of the brief) the
result is therefore *partially validated*: everything is implemented and
tested, the library's ELF and loading are Android's own, and device or
emulator execution is the missing evidence (section 19).

| | status |
|---|---|
| `android-aarch64`, a target of its own (Bionic, `aarch64-linux-android`) | implemented, observed |
| code for Android AArch64 emitted on Linux x86-64; never run there | implemented, observed |
| Botlish's native runtime built for Android/Bionic, no 2048-specific runtime | implemented, observed |
| an ordinary `.botpkg` target support package, descriptor schema 2 (artifacts, `minimumApi`, relocation, declared toolchain) | implemented, observed |
| `-target-support` for `-emit-native-library`, linked by the NDK, never the host linker | implemented, observed |
| ELF: AArch64 shared object, 16 KiB-aligned, no text relocation, Bionic's libraries only | observed (the NDK's `llvm-readelf` and `native/elf.tcl`) |
| header and manifest (schema 2 + `targetSupport`), SHA-256-bound | observed |
| loaded and run by Android's linker and Bionic (API 21, 24, 35) | observed, under qemu-user |
| 2048 parity with the interpreter | observed (API 21, 24, 35) |
| GC stress, many instances, thread affinity, runtime workloads | observed, under qemu-user |
| 16 KiB pages | observed under qemu-user's 16 KiB page size with Android 15's linker in its 16 KiB mode (a 4 KiB-aligned control refused); no 16 KiB device |
| clean room: the single-file compiler, the packages, the NDK, no checkout | observed, 20/20 |
| negative tests, mutation testing | observed (section 14, 15) |
| a device or the Android emulator | **not observed** |
| Botlish-owned threads, actors, an Android doorbell, UI, JNI, React Native | out of scope (projected) |

The compiler gained no Android application knowledge: no Activity, JNI
generation, Gradle, APK, React Native or UI (static: the new compiler code
is the target row, the driver's emission rule, schema 2 and the toolchain
link, the ELF reader). The Android host that runs the library is test
infrastructure under `audit/android-aarch64-target/host`.

## 2. Starting census

Read before anything was built (static; `91f41e16`).

**Where the compiler assumed "compilation host == generated-code target":**

| place | assumption | class |
|---|---|---|
| `main.rs`: `check_host` before run, bench, batch, vms, object, executable, library, link-plan | every emitted object is the host's target | valid for running; **invalid for emitting a library** |
| `codegen/mod.rs` `isa()`: `cranelift_native::builder_with_options` | the ISA is the host's | valid for the JIT; **invalid for cross emission** |
| `native/Cargo.toml`: `cranelift-codegen` default features (`host-arch` only) | an x86-64 driver has no AArch64 backend | **invalid for cross emission** |
| `clif.rs`, `roots.rs`, `nir.rs`: `framewalk::NATIVE_FRAME_ROOTS`, `native_stack::depth_checked`, `stack_probes()`; `fusion.rs`: `coroutine::STACK_SWITCHING` | the runtime that will run the code is this driver's own | target-specific runtime behavior: valid only where the target's runtime has the same constants |
| `clif.rs`: AArch64 stack-map form chosen by `module.isa().name() == "aarch64"` | -- | already target-correct |
| `define_program_record`: `abi_fingerprint()` of the driver's runtime | the target's runtime has the same fingerprint | must be checked (section 8) |
| `codegen/library.rs` `SUPPORTED`, `native::capabilities libraries` | libraries are made for the host (Linux glibc) | **invalid for a library of another target** |
| `native/library.tcl`: `-target` other than the host refused; GNU `ld -r`, `objcopy`, `ar`, `cc -shared`; glibc's system libraries | the host's toolchain links | **invalid for another target** |
| `native/support.tcl` (schema 1): linker `system` only; LIBRARIES compared for the host only; `-target-support` an option of executables only (main.tcl) | target support links executables | extended |
| `core/cabi.tcl`: no Android row; `pm/target.tcl`: no Android format or C library | -- | extended |
| `nir.rs`'s `target` line: present only when the HIR depends on its target | a pure program has no target | valid: such code may be emitted for any target |

**Runtime census (Linux assumptions).** Rust spells Android `target_os =
"android"`, never `"linux"`, so each of the runtime's ~50 Linux gates was a
decision: the platform layer (`platform/linux.rs`: `pthread_getattr_np`,
`gettid`), the POSIX signal guard (`guard.rs`: `sigaction`, `sigaltstack`,
`SA_ONSTACK`), the AArch64 coroutine switch (ELF spelling), the coroutine
stack mapping (`MAP_STACK | MAP_NORESERVE`), the Vm's stack bounds and stack
publication, the frame walk's `NATIVE_FRAME_ROOTS` (which also required
`target_env = "gnu"`). Every function those gates use is Bionic's too
(static, and observed by the build and by the runs). The Linux syscall
transports (`syscall.rs`) are the `std::linux` platform's, not Android's.
The thread doorbell uses `eventfd` on Linux and a pipe elsewhere: Android
takes the pipe (unchanged). Page size: coroutine stacks are rounded with
`sysconf(_SC_PAGESIZE)`; guard sizes come from the thread attributes; the
`4096` in `aotimage.rs` belongs to the x86-64 Linux stub loader only
(static). Frame pointers are forced per target in `.cargo/config.toml`,
which had no Android entry.

## 3. Android target model

`core/cabi.tcl`:

    android-aarch64 {os android arch aarch64 model LP64 charSigned 0 triple aarch64-linux-android floating IEEE}

Android is an operating system of its own: Linux's kernel, Bionic, the NDK's
toolchain, the arm64-v8a ABI. It shares linux-aarch64's instruction set,
data model, plain `char` (unsigned) and AAPCS64 calling convention, and
nothing else that matters to a library: C library, loader, system
libraries, runtime archive, minimum OS version. No standard namespace is
its platform interface (`std::linux` stays Linux's), so `std::linux::*`
imports are UNSUPPORTED-PLATFORM for it. target-lexicon reads the triple as
`Linux` with environment `Android`, and `same_target` compares environments,
so Linux and Android AArch64 code are never interchangeable (observed:
`botlish-native target aarch64-linux-android` reports `runs 0 emits 1`).

**Minimum API level: 21.** The NDK's lowest. The runtime archive links at
every level from 21 (observed: `-z defs` links at 21, 22, 23 and 24; Rust's
standard library reaches newer Bionic functions weakly), and the library
built for API 21 runs on Android 5.0's (API 21), 7.0's (API 24) and 15's
(API 35) Bionic (observed). The floor is the compiler's statement of its
runtime (`native::support::platformVersions`: android 21); a package states
its level (`platform.minimumApi`), the link uses it
(`--target=aarch64-linux-android21`), and a level below the floor is API.
Linking for a higher level is not harmless: the same objects linked for API
35 get packed RELR relocations and only a GNU hash table, and Android 5.0's
linker refuses them ("empty/missing DT_HASH", observed), which is why
`api-ignored` is a mutant (section 15).

The package manager knows the target (`pm/target.tcl`): format ELF, machine
183, C library `bionic`, libraries named as Linux's (`libX.a`, `libX.so`), and
Bionic's and the NDK's stable libraries (`libc.so`, `libm.so`, `libdl.so`,
`liblog.so`, `libandroid.so`, ...) as platform libraries that are never
bundled.

## 4. Cross-target code generation

**May emit is not may run.** `codegen::target::check_emit(program, target)`
answers whether this driver may emit machine code *to keep* for TARGET:

1. the program was built for TARGET or for no target in particular (its NIR
   `target` line);
2. this driver's Cranelift has TARGET's instruction set (the driver is now
   built with `cranelift-codegen`'s `x86` and `arm64` features);
3. TARGET's runtime has exactly the capabilities this driver's code
   generation reads from its own runtime: `RuntimeCapabilities {frame_roots,
   stack_guard, stack_switching}` from `runtime_capabilities(target)` (a table
   per target: Linux glibc x86-64/AArch64, Android AArch64, macOS AArch64,
   Windows x86-64 MSVC) against `host_runtime()` (the constants). A
   `fallback-roots` test build emits for no other target.

`check_host` is unchanged and still decides running. The driver's
`--target TRIPLE` is an option of `library` only (`--target is an option of
library ...` otherwise, observed), and with it `check_emit` replaces
`check_host`; without it nothing changed. `botlish-native target TRIPLE`
reports `emits` beside `runs`.

**The ISA.** `isa_for_target(target)`: the host's exact `isa(true)` for the
host's target (unchanged objects), else `cranelift_codegen::isa::lookup`
of the triple with the baseline ISA, `is_pic = true`, and the target's
stack probes (`target_stack_probes`: where the target's runtime has the
guard). The C convention of foreign calls is the triple's
(`c_call_conv`: SystemV/AAPCS64 for Android); Botlish-internal and helper
calls use the ISA default, which on AArch64 is AAPCS64, the convention the
Android runtime's `extern "C"` helpers are compiled with. Stack maps on
AArch64 are distances below the frame pointer (the form already chosen by
the ISA, not the host). Cranelift never allocates x18, Android's shadow
call stack register.

**Position independence.** The object is PIC: it references data and
helpers through the GOT, and the shared library links with `-z text`
(observed: no `TEXTREL`; the `pic-off` mutant -- a non-PIC object -- fails
the link, section 15).

Observed (`at-driver-library-object`): the same NIR, `library --target
aarch64-linux-android`, gives an ELF relocatable object of machine 183
(AArch64); without `--target`, machine 62 (x86-64).

## 5. Runtime port

The runtime is Botlish's one runtime (`native/runtime-archive`, the
`botlish-native` crate) built with `cargo build --release --target
aarch64-linux-android -p botlish-runtime`, rustc's own Android standard
library, and the NDK's clang as the target C compiler (no C code is
compiled; no runtime source was forked). Changes:

* the shared Linux gate `all(target_os = "linux", any(x86_64, aarch64))`
  became `any(that, all(target_os = "android", target_arch = "aarch64"))` at
  its 29 sites (platform layer, guard, Vm stack bounds and publication,
  coroutines and their stacks, aot startup, tests); the AArch64 coroutine
  switch's ELF spelling and `NATIVE_FRAME_ROOTS` name Android AArch64; the
  syscall transports stay Linux's;
* `.cargo/config.toml`: `force-frame-pointers=yes` for
  `aarch64-linux-android`, as for every other target the walker climbs.

Facilities (observed unless marked):

| facility | Android AArch64 |
|---|---|
| VM, constants, statics, strings, bytes, Lists, structs, MutableVector, Int arithmetic, errors | observed (2048, the stress workloads) |
| native-library exports, instance lifecycle, thread affinity, reentrancy refusal | observed (lifecycle, thread); reentrancy static (the shared runtime code) |
| GC with native-frame roots, under stress | observed (`BOTLISH_NATIVE_GC_STRESS=1` triples the lifecycle run's time: 259 ms to 848 ms; results equal) |
| a library's own stack-limit check (`Vm::stack_limit`) | static: the same code; the limit is the calling thread's stack (`pthread_getattr_np`) less an eighth, at least 64 KiB above its low end, so it never reaches ART's protected region at the bottom of a Java thread's stack |
| the signal stack guard | compiled (POSIX signals, Bionic); a library never installs it (unchanged rule) |
| coroutines (stack switching) | compiled, the Linux AArch64 code; not exercised on Android |
| Botlish-owned threads (`std::thread`) | compiled (the pipe doorbell); not exercised on Android |
| cross-thread actors, an Android doorbell | absent (no Android event-loop driver exists) |

Page size: nothing in the runtime assumes 4 KiB (section 2); under qemu's
16 KiB page size Bionic, the library and the runtime ran (section 10).
M4's 64 MiB default worker stack reservation is untouched; for Android, a
smaller reservation (e.g. 8 MiB, Bionic's default being 1 MiB) is the
recommendation for a later milestone that runs Botlish threads there.

## 6. Target support package

`botlish_target_android_aarch64-0.1.0.botpkg` (9,207,925 bytes) is an
ordinary target-aware package (schema 2 `botlish.json`): its
`android-aarch64` view holds the runtime archive, declared a bundled static
library (verified as ELF AArch64 by the package manager like any other), and

```json
{
  "schema": 2,
  "kind": "botlish-target-support",
  "target": "android-aarch64",
  "triple": "aarch64-linux-android",
  "artifacts": ["native-library"],
  "platform": {"minimumApi": 21},
  "runtime": {"archive": "runtime/libbotlish_runtime.a", "abi": "e6c1492eceebb13c", "relocation": "pic"},
  "systemLibraries": ["-ldl", "-llog", "-lunwind", "-ldl", "-lm", "-lc"],
  "toolchain": {
    "name": "Android NDK",
    "root": "ANDROID_NDK_ROOT",
    "revision": {"file": "source.properties", "key": "Pkg.Revision", "minimum": "28.0"},
    "hosts": {"linux-x86_64": "toolchains/llvm/prebuilt/linux-x86_64"},
    "tools": {"cc": "bin/clang", "ld": "bin/ld.lld", "objcopy": "bin/llvm-objcopy", "ar": "bin/llvm-ar"},
    "platformLibraries": "sysroot/usr/lib/aarch64-linux-android/{api}"
  }
}
```

**Descriptor schema 2** (BOTLISH-TOOLS.md, section 9; `native/support.tcl`)
keeps schema 1's checks and adds, generically: `artifacts` (only
`native-library` so far: ARTIFACT otherwise), `platform` (required exactly
for an operating system with a platform version; Android's `minimumApi`,
never below the floor: API), `runtime.relocation` (`pic`: PIC) and
`toolchain`. The toolchain is data: the environment variable naming its root
(nothing is searched, no path hard-coded in the compiler or the package),
the revision file, key and minimum, the directory per host, the tools and
the API libraries' directory, every path relative and validated. The NDK
layout is in the package; the compiler composes every argument itself, so
the descriptor adds no flag (`systemLibraries` must equal the compiler's
statement for the target, `targetLibraries`, which is rustc's
`native-static-libs` for the Android archive: `-ldl -llog -lunwind -ldl -lm
-lc`, observed).

**Build** (`tools/package.sh`, observed; `results/` holds `build.txt`):

    rustc rustc 1.97.0 (2d8144b78 2026-07-07)
    cargo cargo 1.97.0 (c980f4866 2026-06-30)
    rust-target aarch64-linux-android
    ndk 29.0.14206865
    api 21
    runtime-abi e6c1492eceebb13c
    archive-sha256 ce09b46b89a0f357a9eb1f564da49bca55e9be418c6bf2cbc146e9f5d9b1592c

The NDK is r29 (`android-ndk-r29-linux.zip`, SHA-1
`87e2bb7e9be5d6a1c6cdf5ec40dd4e0c6d07c30b`, the value Google's repository
manifest states; observed). The package script refuses an archive whose
identity record is not `aarch64-linux-android` with the driver's runtime
ABI. A consumer never builds the runtime (section 13).

## 7. Native-library emission

    botlish -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library game -out lib engine.bot

(observed, the installed packages' view):

    target support: botlish_target_android_aarch64 (android-aarch64, runtime .../.bot_modules/.targets/android-aarch64/botlish_target_android_aarch64/runtime/libbotlish_runtime.a)
    static: lib/libgame.a
    shared: lib/libgame.so
    header: lib/game.h
    manifest: lib/game.manifest.json

`native::library` with a target support package (`LinkWithToolchain`):

1. the driver emits the library's object for the target (`library OUT NAME
   FILE.nir --target aarch64-linux-android`);
2. the NDK's `ld.lld -r` links it with the package's runtime archive (only
   the members it needs);
3. `llvm-objcopy --strip-debug --keep-global-symbols` keeps exactly the
   public functions global;
4. `llvm-ar rcs` makes `libgame.a`;
5. the NDK's `clang --target=aarch64-linux-android21 -shared -Wl,-z,defs
   -Wl,-z,text -Wl,--gc-sections -Wl,-z,max-page-size=16384
   -Wl,-soname,libgame.so ... -ldl -llog -lunwind -ldl -lm -lc` makes
   `libgame.so`, which is checked from its bytes (section 9).

The toolchain is found before anything is written (a missing one is never a
broken package); a failed link deletes the earlier build's files of the same
names first (observed, `at-toolchain-failures`). The header is unchanged in
form; the manifest is schema 2 with `target {android-aarch64,
aarch64-linux-android}`, `link` the Android runtime's libraries, and a new
member `targetSupport {package, runtimeAbi, platform {minimumApi: 21},
toolchain {name, revision}}` (BOTLISH-TOOLS.md, section 8). PM-7A's `tool
-artifact` check (schema, kind, target, digests) applies to it unchanged.

## 8. Runtime ABI integrity

The Android archive's identity record, read from its bytes:

    BOTLISH-RUNTIME-IDENTITY v1 aarch64-linux-android e6c1492eceebb13c

and the host driver's `runtime-abi` is `e6c1492eceebb13c` (observed): the
fingerprint's 26 scalar words (the Vm's size and the offsets generated code
uses, the root plan, the program record's layout) and the helpers' names
and arities are the same in the two builds, so the program record the x86-64
driver writes is the one the Android runtime's startup accepts. No
fingerprint input changed (the value is the one PM-7A's merge reported).
The check is enforced three times: the package script, `native::support`'s
ABI and RUNTIME refusals before linking (a Linux/glibc AArch64 archive is
refused for Android whatever its descriptor states: `at-support-linux-
archive`), and the program record at instance creation. The
`android-runtime-shadow-roots` mutant (Android's runtime on the shadow-stack
root plan) changes the Android fingerprint and is refused (section 15).

## 9. Android ELF validation

`native/elf.tcl` reads the shared object (no tool run); `ValidateShared`
refuses and removes one that is not the target's. The NDK's `llvm-readelf`
agrees (observed):

    Type:    DYN (Shared object file)
    Machine: AArch64
    LOAD  0x000000 ... R E 0x4000
    LOAD  0x0aec80 ... RW  0x4000
    LOAD  0x0b2b70 ... RW  0x4000
    GNU_STACK ... RW
    NEEDED  libdl.so  liblog.so  libm.so  libc.so
    SONAME  libgame.so
    FLAGS   BIND_NOW

* exports: exactly the 23 public functions (`game_create` ... `game_over`);
  every runtime symbol local;
* symbol versions: Bionic's `LIBC` only, no `GLIBC_`;
* no `TEXTREL`, no program interpreter, no executable stack;
* 16 KiB alignment on every `LOAD` (the compiler passes
  `-z max-page-size=16384` explicitly: NDK r28 and later default to it, and
  the check holds for any NDK).

`libgame.so` is 1,069,712 bytes, `libgame.a` 13,666,740 (the runtime's
whole relocatable link; `--gc-sections` of the shared link drops what the
exports do not reach).

## 10. Android execution

**The environment.** `tools/sysroot.sh` downloads Google's arm64-v8a
emulator system images from Google's SDK repository and checks each against
the SHA-1 the repository's manifest states:

| API | image | SHA-1 | Bionic location |
|---|---|---|---|
| 21 (Android 5.0) | `arm64-v8a-21_r04.zip` | `c4375f1b4b4cd21a8617660e25f621cedcbd8332` | `/system/lib64` |
| 24 (Android 7.0) | `arm64-v8a-24_r09.zip` | `e88ebdf4533efa0370603ee4ab0e7834e0cc364f` | `/system/lib64` |
| 35 (Android 15) | `arm64-v8a-35_r02.zip` | `2026a06409db630b56711afdbffb457c1dbaed49` | `/apex/com.android.runtime` (the runtime APEX, unpacked from the dynamic-partition image by `lpunpack.py`) |

`tools/android-run.sh ROOT PROGRAM` runs an NDK-built PIE under
`qemu-aarch64 -L ROOT` (qemu-user 8.2.2): the program's interpreter is
Android's `/system/bin/linker64`, which loads Bionic's `libc.so`, `libdl.so`,
`libm.so` and `liblog.so` from the image and then, on `dlopen`, the Botlish
library. What runs is Android's userspace on the host's kernel (via qemu's
syscall translation): no Android kernel, zygote, ART, property service
(`android_get_device_api_level()` answers -1) or SELinux.

**The host** (`host/host2048.c`, built by the NDK for
`aarch64-linux-android21`): `dlopen(LIB, RTLD_NOW)`, every export resolved
with `dlsym` and typed from the generated header, `game_abi_version()`
checked, then the C ABI driven as the manifest says: every str result
copied and released with `game_bytes_release`, every error read and
released with `game_error_release`.

Observed on each image (API 21, 24, 35): the library loads and every mode
passes (sections 11, 12). With `-p 16384` qemu presents 16 KiB pages
(`AT_PAGESZ`, `sysconf(_SC_PAGESIZE)` = 16384, qemu's own mmap granularity)
and Android 15's linker loads in its 16 KiB mode: the compiler's library
loads and runs (`thread`: WRONG-THREAD from the other thread, the owner's
game scores 28), while the same objects linked 4 KiB-aligned are refused
(`dlopen failed: empty/missing DT_HASH/DT_GNU_HASH ...`) and load with 4 KiB
pages (`at-android-16k-control`). That is 16 KiB evidence of the ELF and of
Bionic's loader, not of a 16 KiB device's kernel.

## 11. 2048 integration

`audit/external-tools/2048/engine.bot` over `examples/games/2048/game2048.bot`,
both unchanged, installed as PM-7A installed them (the engine is the
ordinary package `game2048`). `tools/parity.tcl` plays PM-7A's script --
a new game, two spawns, 160 moves and spawns from the linear congruential
sequence, then score, over, first_empty and four erroneous calls -- through
the Android host, and the interpreter (`-backend interp -target
android-aarch64`, the same engine module from the same package view) plays
the same steps. Observed (`results/parity.txt`; library and host built for
API 21):

    == API 21
    PASS states equal the interpreter's (321 states)
    PASS score, over and first_empty equal the interpreter's (744, 1, -1)
    PASS declared errors cross the C ABI with their identities
    PASS the final score is positive (tiles merged)
    parity: 160 steps, 321 states, score 744, host run 128 ms
    == API 24   (the same four PASS lines; host run 140 ms)
    == API 35   (the same four PASS lines; host run 151 ms)

The errors, as the C ABI reports them (status 1, a declared Botlish error,
its canonical identity): `InvalidState`, `InvalidDirection`,
`game2048::CellOccupied`, `InvalidSpawn`.

## 12. GC and lifecycle

Observed under qemu with Android 15's Bionic (`at-android-lifecycle`,
`at-android-stress`; API 21 and 24 too during development):

* `lifecycle 50`: fifty instances created, each plays a 24-call game (score
  28), destroyed; two instances interleaved, the first destroyed and the
  second still playing; the destroyed one refused with `ERROR 4
  INVALID-INSTANCE` without being touched.
* `thread`: an instance called from another pthread is refused (`4
  WRONG-THREAD`) and keeps working on its own thread: no implicit migration.
* the runtime workloads (`stress/stress.bot`, `host/stress.c`): a
  6,000-character, 14,000-byte string of astral and accented characters, its
  length in scalar values, a reversed astral string, 500 nested structs with
  their Lists, a MutableVector grown to 5,000, and an error with a payload
  `{count: 300, text: "item-299"}` raised after 300 allocations, read
  through `stress_error_field_*`; every round on two alternating instances
  equal to the first, and equal to the interpreter's
  `[6000, "ßb😀éa", 3494390, 37492500]`.
* `BOTLISH_NATIVE_GC_STRESS=1` (a collection before every allocation, read
  by each instance's heap from the process environment): the same results
  for both programs; the 20-instance lifecycle takes 848 ms against 259 ms
  without (observed), so the collector runs inside the library.

Each instance owns its Vm, heap and statics (the existing library
runtime); a destroyed instance never disturbs another (observed above).

## 13. Cleanroom reproduction

`cleanroom/cleanroom.sh BOTLISH REPO NDK ROOTS RESULTS`: a fresh `/tmp`
room holding a copy of the single-file compiler (`single/build.sh` from
this change, 15,473,311 bytes), the two `.botpkg` artifacts, `engine.bot`,
`host2048.c` and the game's calls; `env -i HOME=ROOM/home PATH=/usr/bin:/bin
LANG=C.UTF-8 TMPDIR=ROOM/tmp ANDROID_NDK_ROOT=NDK`; the room the working
directory; the whole run under `strace -f`. Observed
(`results/cleanroom.txt`):

    PASS A the packages installed for android-aarch64
    PASS B the library linked with the installed package's runtime
    PASS B an AArch64 ELF shared object
    PASS B every loadable segment 16 KiB-aligned
    PASS B needs Bionic's libc, libdl, liblog and libm only
    PASS B no text relocation
    PASS B the manifest is android-aarch64's and binds the shared library
    PASS C api-21: 321 states as the interpreter's
    PASS C api-21: the declared errors cross the C ABI
    PASS C api-21: instances and thread affinity
    PASS C api-24: 321 states as the interpreter's
    PASS C api-24: the declared errors cross the C ABI
    PASS C api-24: instances and thread affinity
    PASS C api-35: 321 states as the interpreter's
    PASS C api-35: the declared errors cross the C ABI
    PASS C api-35: instances and thread affinity
    PASS D a removed target support package is refused, precisely
    PASS the run reached nothing of the checkout (/home/user/botlish)
    PASS the run used no Tcl but the single file's own
    PASS the run built no runtime (no cargo, no rustc)

The runtime archive the library links is the installed package's (the
`target support:` line names `.bot_modules/.targets/android-aarch64/...`);
`at-library-package-runtime` shows the link fails when that archive is
replaced, so no other archive stands in. Declared inputs outside the room:
the NDK (`ANDROID_NDK_ROOT`), the Android userspaces (`ROOTS`), qemu-user,
and the system's `/usr/bin` tools. The room is a scrubbed process
environment with strace evidence, not a container (Docker's daemon is not
available here, as for PM-7A).

**Reproducibility.** Two builds of the library from one checkout give the
same `libgame.a`, `libgame.so`, `game.h` and manifest, byte for byte
(`at-library-deterministic`, observed). The package's archive is the
cargo build's; its SHA-256 is recorded in `build.txt`, not promised
identical across machines or toolchains.

## 14. Negative tests

`tests/android-target.test` (21 tests), each refusal its own kind,
observed:

| case | outcome |
|---|---|
| unknown target / a target with no Botlish runtime (`aarch64-unknown-linux-musl`) | driver `emits 0`; `NATIVE TARGET ... no Botlish native runtime exists` |
| `--target` on `run` | usage error: `--target is an option of library` |
| a program built for linux-x86_64 emitted for Android | `NATIVE TARGET ... built for target linux-x86_64`, no object |
| a program built for android-aarch64 run on the Linux host | `NATIVE TARGET ... runs only on its own target's host` |
| `-target android-aarch64 -emit-native-library` without a package | `NATIVE TARGET ... name the target support package`, nothing linked, no package selected silently |
| an Android executable | `NATIVE TARGET-SUPPORT ARTIFACT` (the package supplies native libraries) |
| schema 1 package for a library | ARTIFACT |
| `"relocation": "static"` | PIC |
| `minimumApi` 19 | API, with the runtime-floor reason |
| no `platform`; an unknown member; `artifacts` naming an executable; a toolchain root or tool path outside the toolchain | DESCRIPTOR |
| system libraries differing from Android's | LIBRARIES |
| a wrong fingerprint | ABI |
| a linux-aarch64 descriptor for android-aarch64 | TARGET |
| the wrong triple | TRIPLE |
| an archive whose identity record is Linux/glibc AArch64 | RUNTIME: "the same architecture, another operating system or C library ABI" |
| `ANDROID_NDK_ROOT` unset; an NDK of revision 27.2; a tool missing; no directory for this host | `NATIVE LIBRARY TOOLCHAIN` (never TARGET-SUPPORT) |
| an NDK without API 21's libraries | API |
| the link fails | `NATIVE LIBRARY TOOL ld`; the earlier build's `.a`, `.so` and manifest gone |
| a link failing for a non-PIC relocation | `NATIVE LIBRARY PIC` |
| a shared object 4 KiB-aligned | `NATIVE LIBRARY ELF`, removed |
| the package's archive replaced | the link fails (undefined symbols): no other runtime is used |
| the Android archive built from this source | its identity record is `aarch64-linux-android` with the driver's runtime ABI (`at-runtime-identity`: a runtime built differently, or stale, fails it) |

The tests that need nothing but the native build run everywhere the suite
runs (fake archives and fake NDKs); the link half needs `ANDROID_NDK_ROOT`
and the Android runtime archive, the execution half qemu-aarch64 and
`BOTLISH_ANDROID_ROOTS`, else they are skipped by constraint. Observed:

    android-target.test:	Total	21	Passed	21	Skipped	0	Failed	0      (146 s; results/tests.txt)

## 15. Mutation testing

`audit/android-aarch64-target/tools/mutate.tcl`: each mutant of
`mutants.txt` applied to a private copy, its named tests run; a mutant that
edits Rust rebuilds the copy's driver (and, for a runtime edit, the Android
archive); a detector skipped by its constraints never counts as a kill or a
survival (NOT-RUN). Observed:

**26 / 26 killed**, each by a named detector (`results/mutation.txt`):

| mutant | the bug | killed by |
|---|---|---|
| `emit-refused` | every non-host emission refused again | `at-driver-library-object`, `at-library-elf` |
| `host-isa` | Cranelift configured for the host whatever the target | `at-driver-library-object`, `at-library-elf` |
| `any-target-has-a-runtime` | every target taken to have a runtime with this driver's capabilities | `at-driver-refusals`, `at-driver-target-report` |
| `run-with-target` | `--target` accepted by `run` (host code run as Android's) | `at-driver-refusals` |
| `pic-off` | a non-host object not position-independent | `at-library-elf` |
| `android-linked-as-host` | an android-aarch64 library without a package made for the host, silently | `at-library-needs-support` |
| `target-not-passed` | the target not passed to the driver | `at-library-elf` |
| `host-linker` | the host's cc links the shared library | `at-library-elf` |
| `support-ignored-for-libraries` | -target-support read but not given to the library | `at-library-elf` |
| `driver-runtime` | the driver's Linux runtime linked instead of the package's | `at-library-elf`, `at-library-package-runtime` |
| `api-ignored` | linked for API 35, not the package's minimum | `at-android-2048` (Android 5.0's linker refuses it) |
| `alignment-4k` | 4 KiB segment alignment | `at-library-elf`, `at-android-16k-control` |
| `alignment-unchecked` | a 4 KiB-aligned object passes the check | `at-library-alignment-checked` |
| `stale-output-kept` | a failed link leaves the earlier build's files | `at-toolchain-failures` |
| `pic-unmapped` | a non-PIC link failure reported as a plain tool failure | `at-toolchain-failures` |
| `toolchain-error-as-support` | a missing toolchain reported as a broken package | `at-toolchain-refusals` |
| `revision-unchecked` | an NDK older than the minimum used | `at-toolchain-refusals` |
| `linux-archive-accepted` | an archive of another OS of the same architecture accepted | `at-support-linux-archive` |
| `descriptor-trusted` | the archive's identity record not read | `at-support-linux-archive` |
| `relocation-unchecked` | a static-relocation runtime linked into a shared library | `at-support-refusals` |
| `api-floor-ignored` | an API level below the floor accepted | `at-support-refusals` |
| `artifact-unchecked` | a schema 1 package taken for a library's | `at-support-refusals`, `at-executable-refused` |
| `android-runtime-shadow-roots` | Android's runtime on the shadow-stack root plan | `at-runtime-identity` |
| `manifest-host-target` | the manifest names the host's target | `at-library-manifest` |
| `thread-affinity-ignored` | an instance answers another thread (Android's runtime) | `at-android-lifecycle` |
| `runtime-from-checkout` | the runtime read from the compiler's tree, not the package | `at-library-package-runtime` |


The first run surfaced a harness defect, not a test gap: after the
Android-runtime mutant was restored, the copy's Android archive kept the
mutated fingerprint, so the next mutants' detectors were skipped by their
constraint and counted as survivals. The harness now rebuilds the archive
after any runtime edit and reports skipped detectors as NOT-RUN; the three
mutants were rerun and killed. The runtime mutant itself then showed as
NOT-RUN -- its own mismatched archive skips the tests that need a matching
one -- so the invariant became a test of its own, `at-runtime-identity`
("the Android archive built from this source has this driver's runtime
ABI"), which kills it. A fourth survivor (`api-floor-ignored`) was a real gap:
with the real NDK, the toolchain's own API check also refused API 19, so a
test that compared only the refusal's kind could not tell the reasons apart.
`at-support-refusals` now checks the reason too.

**Other catalogs.** Four mutants of other harnesses edited code this change
rewrote and no longer applied (`tools/mutant-catalogs.tcl`); each was
updated keeping its rule: external-tools' `support-host-tree` (killed by
`et-target-support-target-tree`), native-aot's `library-record-main-thread`
(killed: `mts-library-record`), target-model's `driver-runs-any-target`
(killed: `tm-main-native-target`, `tm-native-driver-boundary`,
`tm-native-refuses-another-target`) and native-stack's
`win-executable-unguarded` (a Windows-only mutant: its cfg names Android
AArch64 now; Windows CI's tier item `native-stack-mutants` runs it). All 93
catalogs apply (observed: 3,239 mutants, 0 problems).

## 16. Regressions

Observed on this container, each with a private `-tmpdir`:

| run | result |
|---|---|
| `tests/android-target.test` | 21 / 21 (146 s, API 21, 24 and 35) |
| `tests/native-library.test` | 28 / 28 |
| `tests/external-tools.test` | 48 / 48 (`et-target-support-refusals`' unknown target is now `ios-aarch64`: android-aarch64 is known) |
| `tests/target-model.test` | 25 / 25 (the table pins gained the android row) |
| `tests/c-abi-types.test` | 73 / 73 (the same) |
| `tests/package-native.test` | 38 / 39, 1 skipped (its constraint) |
| `tests/main-cli.test` | 72 / 72 |
| `tests/system-linker.test` | 15 / 15 |
| `cargo test --release --bin botlish-native -- target:: aot::` | 38 / 38 |
| `tools/compilerpedia.tcl check` | 0 problems |
| `tools/mutant-catalogs.tcl` | 93 catalogs, 0 problems |

Linux, macOS and Windows output is unchanged where the target is unchanged:
the host's target takes the old ISA path (`isa(true)`), `check_host` is the
old check, the host library link is the old one, schema 1 descriptors read
as before, and no program loads the Android package unless it names it
(static; `tests/native-library.test` and `tests/system-linker.test`
observed). Linux AArch64 still means glibc (`same_target` compares
environments). The ABI fingerprint is unchanged (`e6c1492eceebb13c`). CI:
the branch's pushes run tests.yml's canary, macos-arm64.yml and
windows-x86_64.yml (section 18).

## 17. Performance and footprint

Observed on this container (4 cores, Linux x86-64; medians of 5-9 runs
unless stated; `audit/android-aarch64-target/results/bench.txt`).

**Compiler and build.**

| measure | value |
|---|---|
| the driver, stripped (the single executable packs it) | 8,938,432 bytes before, 9,986,448 after (+1,048,016: Cranelift's AArch64 backend, now in every x86-64 driver) |
| the same, gzip -6 (the single executable's archive deflates its files) | 2,878,173 before, 3,240,197 after (+362,024) |
| the single executable from this change | 15,473,311 bytes (no Android runtime inside: the target support package carries it) |
| `botlish -version` (single executable, 9 runs) | 132 ms (PM-7A measured 131 ms; unchanged within noise) |
| the 2048 library's object, emitted for the host / for android-aarch64 | 33 ms / 34 ms (65,936 bytes) |
| `native::support::select` of the Android package | 525 ms, of which 555 ms reading the 43.9 MB archive's identity record (`identity`: the whole archive read into memory and searched; a candidate for a streamed read) |
| `native::support::toolchain` (the NDK found and its revision read) | 0.15 ms |
| `ld.lld -r` / `llvm-objcopy` / `llvm-ar` / `clang -shared` | 123 / 81 / 10 / 29 ms |
| the shared object's check (`native/elf.tcl`, 1.07 MB) | 342 ms (Tcl's byte loop over `.dynsym`) |
| `-emit-native-library game` for android-aarch64, single executable, end to end | 2.4 s |
| the Android runtime archive (unstripped, debug info 1) | 43,920,038 bytes (the host's: 41,216,156) |
| the target support package | 9,207,925 bytes |
| `libgame.so` / `libgame.a` / `game.h` / `game.manifest.json` | 1,069,712 / 13,666,740 / 5,858 / 10,639 bytes |
| repeated builds | byte-identical library, archive, header and manifest |

The default compiler grows by Cranelift's AArch64 backend only; the
Android runtime is distributed separately, and a compilation that does not
name the package reads nothing of it.

**Android runtime** (the Android host's `bench 2000`, three runs each,
CLOCK_MONOTONIC inside the program). These times are **qemu-user's TCG
emulation of AArch64 on x86-64**: they bound nothing on a device, and no
comparison with native Linux numbers is drawn from them.

| measure | API 21 | API 35 |
|---|---:|---:|
| `dlopen` of `libgame.so` | 0.66-0.70 ms | 1.35-1.60 ms |
| instance creation | 9.0-9.8 ms | 11.6-13.1 ms |
| first exported call (`new_game`) | 2.9-3.1 ms | 2.6-3.0 ms |
| `move` (a str in, an owned str out, released) | 194-203 µs | 277-287 µs |
| `score` (a str in, an int out) | 44-47 µs | 52-62 µs |
| instance destruction | 4.4-6.0 ms | 5.4-5.8 ms |

Resident memory is not reported: under qemu-user a process's resident set
is qemu's own, translator included. Memory items for a device run: the
runtime's static data, one Vm per instance, and Bionic's default 1 MiB
thread stacks for any Botlish thread (M4's 64 MiB reservation is the
recommendation to revisit: section 5).

## 18. CI/platform matrix

| area | evidence |
|---|---|
| Linux x86-64 compiler execution | observed |
| cross-target AArch64 object generation | observed |
| Android runtime archive build | observed (cargo, NDK r29) |
| native-library link with the NDK | observed |
| Android ELF and ABI checks | observed |
| Android AArch64 execution | observed under qemu-user with Android's linker and Bionic (API 21, 24, 35); **no device or emulator** |
| 2048 interpreter parity | observed (API 21, 24, 35) |
| Android GC stress | observed (qemu-user) |
| 16 KiB page-size execution | observed under qemu-user's 16 KiB pages with Android 15's linker; **no 16 KiB device** |
| macOS or Windows hosts cross-compiling | not attempted (the descriptor's `hosts` names linux-x86_64 only; static: nothing in the emission is Linux-host-specific, the NDK layout per host would be the package's) |
| CI | the push runs the standard workflows; none installs the NDK or qemu, so `tests/android-target.test`'s link and execution halves are skipped there by constraint and its refusal half runs (projected: an NDK job) |
| React Native integration, Android SDL3 UI, Android cross-thread actors | projected |

## 19. Remaining limitations

* **No device or emulator run.** The execution evidence is Android's own
  userspace (linker64, Bionic, liblog) under qemu-user on a Linux kernel: no
  zygote, ART, SELinux, property service or Android kernel, no Java thread
  hosting the calls, no JNI. A JNI smoke test inside an APK on a device or
  an arm64 emulator (an AArch64 host with KVM) is the next evidence to get.
* **16 KiB pages** are qemu's presentation, not a 16 KiB kernel.
* **Hosts.** The package declares the NDK's linux-x86_64 directory only;
  other hosts are a descriptor entry away but untested.
* **Artifacts.** Only native libraries; an Android executable is ARTIFACT.
* **Threads and event loops.** `std::thread` and coroutines compile for
  Android and are not exercised there; no Android doorbell, so remote actors
  have no Android transport. The 64 MiB worker stack reservation is untuned
  for mobile.
* **The runtime archive** carries the whole `botlish-native` crate
  (Cranelift included: 43.9 MB unstripped); the shared link's
  `--gc-sections` drops it from `libgame.so`, but the package and `libgame.a`
  pay for it.
* **The package's toolchain minimum** (`28.0`) is the revision whose default
  alignment is 16 KiB; the compiler passes the alignment explicitly, so the
  minimum is policy, not need.

## 20. Next milestones

1. **Device evidence.** A JNI host in a minimal APK (test infrastructure,
   built by an external tool) on an arm64 device or emulator, a 16 KiB
   device among them; an NDK job in CI.
2. **`botlish-android`** (an external tool package, PM-7A's protocol):
   consumes the manifest and `libgame.so` built here, generates the
   Activity/JNI glue and Gradle files, aligns the APK's ZIP entries to 16
   KiB (`zipalign -P 16`), invokes Gradle; depends on this target package.
3. **`botlish-react-native`**: the TurboModule spec and JSI adapter over the
   same manifest (PM-7A's `host-module` shape), Codegen from the app's own
   `node_modules`, the same library.
4. **Android threads**: a stack reservation policy for mobile, an Android
   doorbell (ALooper) for the remote-actor transport, both packages of their
   own.
