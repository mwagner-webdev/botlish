# React Native target census

Whether, and in what shape, the Botlish compiler can produce an installable
React Native package whose exported Botlish functions JavaScript calls as a
New Architecture Pure C++ TurboModule, on Android and iOS.

This is a census, not an implementation:

* **No compiler, runtime or library code was changed.** Everything this
  census built is probe material under `audit/react-native/` and one
  exploratory workflow, `.github/workflows/react-native-probe.yml`.
* Code claims cite `path:line` at commit `c8fb055`. React Native claims cite
  files of the published npm packages (`node_modules/react-native/...`).
* The versions are React Native **0.88.0** (npm `latest`, published
  2026-10-15), `@react-native/codegen` 0.88.0, `@react-native-community/cli`
  20.2.0, `create-react-native-library` 0.63.1, Hermes tag
  `hermes-v260318099.0.4` (the one `react-native/sdks/hermes-engine/
  version.properties` pins), Node 22, rustc 1.97.0, clang 18.1.3, Tcl 9.0.1.
  Section 9 has every tool version and command.

## Contents

1. [Executive conclusion](#1-executive-conclusion)
2. [Recommended architecture](#2-recommended-architecture)
3. [Current capability matrix](#3-current-capability-matrix)
4. [Type mapping matrix](#4-type-mapping-matrix)
5. [Android findings](#5-android-findings)
6. [iOS findings](#6-ios-findings)
7. [Compiler-plugin findings](#7-compiler-plugin-findings)
8. [External tooling and dependencies](#8-external-tooling-and-dependencies)
9. [Empirical results](#9-empirical-results)
10. [Proposed implementation slices](#10-proposed-implementation-slices)
11. [Non-goals and deferred work](#11-non-goals-and-deferred-work)
12. [Final recommendation](#12-final-recommendation)
13. [The React Native contract, as found](#13-the-react-native-contract-as-found)
14. [Async and coroutine semantics](#14-async-and-coroutine-semantics)
15. [The package-generation model](#15-the-package-generation-model)
16. [Reproducing the probes](#16-reproducing-the-probes)

## 1. Executive conclusion

**Viable after a small set of named prerequisites.** The React Native side
is plugin and glue work, and it is proven. The prerequisites are on the
Botlish side and are general compiler and runtime facilities, not React
Native ones.

* **The architecture works end to end with real Botlish code.**
  * JavaScript on Hermes (React Native's pinned tag) calls React Native's own
    `TurboModuleBinding`, which calls the Codegen-generated
    `NativeBotlishProbeCxxSpec<T>`, which calls a generated thin C++ adapter,
    which calls a C ABI, which calls Botlish-compiled machine code.
  * The probe covers Int, String, Bool, a declared error and range checks, at
    about a microsecond a call, and holds under `BOTLISH_NATIVE_GC_STRESS=1`.
  * Tcl generated every file in the chain that Codegen does not:
    * the C wrappers, by the library-mode stand-in from the HIR;
    * the spec, entry point, adapter and build metadata, by the package
      generator reading only the library's export manifest.
* **Packaging needs no app edits.** A stock `@react-native-community/cli init`
  app installs the generated package from its npm tarball. Then:
  * Android autolinking classifies it as a pure C++ dependency
    (`isPureCxxDependency: true`), with no Gradle module, Java or Kotlin.
  * The app's iOS Codegen registers its `RCTModuleProvider`.
  * Metro bundles its TypeScript for both platforms.
* **Botlish code ran in that stock app on both platforms** (section 9):
  * every probe call, with the results the host predicted;
  * on the Android x86_64 emulator, from the template's own release build,
    with the library built on a Linux host and no runtime patch;
  * on the iOS simulator, where the one change to Mac-made machine code
    was its Mach-O platform tag, which target-triple code generation sets
    by itself.
* **Botlish has no library mode.** It emits only whole-program executables,
  and its functions are not callable from C:
  * Its symbols are `botlish_fn_N` with an internal calling convention
    (`native/src/codegen/clif.rs:3-12`).
  * Only functions the program reaches are compiled
    (`native/lower.tcl:1567-1570`).
  * The program's tables exist only in the generated `main`
    (`native/src/codegen/aot.rs:74-192`).
  * The census's stand-in (`audit/react-native/tools/libmode.tcl`, 337
    lines of Tcl) built one from existing parts, so the gap is integration
    work, not new compiler theory. Section 7 lists what core must own.
* **Two prerequisites are about embedding, not React Native.**
  * Botlish must run on a thread of its own with a large stack. React
    Native's JS thread stack is 512 KiB to 1 MiB. On those stacks Botlish
    recursion killed the host process somewhere between 10,000 and 20,000
    frames (512 KiB) or 20,000 and 50,000 (1 MiB), with no diagnostic
    (section 9).
  * Symbol names must be unique per compilation. Two Botlish libraries in
    one binary linked silently and computed a wrong answer.
* **The mobile targets are close, unevenly.**
  * Android x86_64: the runtime builds unchanged once frame pointers are
    forced.
  * AArch64 Android and iOS: the runtime needs a one-line `cfg` fix
    (`audit/react-native/patches/runtime-aarch64-cfg.patch`) and code
    generation for the target's triple. Today the ISA is always the host's,
    and on a Mac that tags every Mach-O object as macOS.
  * Android is the closer of the two in compiler work: its x86_64 library
    needed nothing, and its objects carry no platform tag.

## 2. Recommended architecture

The plausible design held up: a deliberately boring generated C++ adapter
over a plain C ABI. Botlish never implements a C++ class or template, never
sees JSI, and the C ABI is testable from C alone. React Native churn
(Codegen's C++ API, autolinking, CocoaPods versus SwiftPM) stays in the
generated adapter and the plugin.

```
 app JS/TS     import { reverse } from 'react-native-foo'
                 |
 generated     src/index.ts ----------------------------- plugin (Tcl)
 by plugin     src/NativeFoo.ts  (Codegen TypeScript spec)
                 |  TurboModuleRegistry.getEnforcing('Foo')
                 |  = global.__turboModuleProxy('Foo')
 React Native  TurboModuleBinding, TurboModule (jsi::HostObject)
                 |
 RN Codegen    NativeFooCxxSpec<FooModule>   (per React Native version;
 (run by the     |                            shipped or app-generated)
  plugin)        |  bridging::callFromJs(...)
 generated     FooModule  (cpp/FooModule.{h,cpp}): JSI values <-> C values,
 by plugin       |        checked numbers, UTF-8, errors -> JS Error,
                 |        later: hand-off to the Botlish thread
 =============== C ABI: foo_botlish.h ===================== the boundary
 Botlish core  libfoo_botlish.a: exported C trampolines, library startup,
 (library        |               the Botlish runtime, compiled Botlish code
  mode)          |
               Botlish functions (ordinary module code)
```

Who owns what:

| Layer | Owner | Changes when |
|---|---|---|
| Botlish source | the user: an ordinary module, nothing React Native in it | the program changes |
| Library mode: `.a` per target, C header, export manifest | **compiler core** (general: any C host) | Botlish changes |
| TS spec, JS entry, C++ adapter, CMake, podspec, provider, `package.json`, `react-native.config.js` | **React Native plugin** (Tcl) | React Native changes |
| Codegen output (`NativeFooCxxSpec<T>`) | React Native Codegen, run by the plugin or the app | React Native changes |
| Gradle, CMake, NDK, CocoaPods, Xcode | React Native and the app's toolchain | never touched by Botlish |

Build paths:

* **Android.** The app's Gradle build runs the React Native Gradle plugin.
  Its autolinking adds the package's `android/CMakeLists.txt` to the app's
  `libappmodules.so`. That CMake file builds the adapter and imports
  `android/libs/${ANDROID_ABI}/libfoo_botlish.a`. The generated
  `autolinking.cpp` constructs `FooModule` when JS asks for module `Foo`.
* **iOS.** CocoaPods (or, later, SwiftPM) builds the package's pod: the
  adapter, the Objective-C++ `FooModuleProvider` and the vendored Botlish
  library (an `.xcframework` once device and simulator are both supported).
  The app's Codegen lists the provider in `RCTModuleProviders.mm` because
  `codegenConfig.ios.modulesProvider` names it.

Alternatives considered:

* **Botlish implementing the C++ spec class directly.** This needs C++ ABI
  knowledge: templates, `std::shared_ptr`, `jsi::Value`, vtables, exceptions.
  That is the arbitrary C++ FFI this milestone excludes, and it would bind
  the compiler to React Native's C++ API. Rejected.
* **A Java/Kotlin or Objective-C TurboModule calling C.** This adds a
  platform-specific layer per OS, plus JNI or Objective-C marshalling,
  for nothing the C++ path lacks. The Pure C++ path is React Native's
  recommended way to share code across platforms. Rejected.
* **Botlish producing JSI host functions itself** (a C ABI of `jsi::Value`s).
  This means exactly the C++ object model again. Rejected.
* **A Rust adapter.** No evidence calls for one: the adapter is C++ because
  Codegen's output is C++, and the C ABI side is generated by the compiler.

## 3. Current capability matrix

Status words: **works** (demonstrated), **stand-in** (demonstrated with the
census's probe tooling, missing from the compiler), **small** (a small
missing piece), **blocked** (needs a named milestone), **absent**.

| Capability | Android | iOS | Shared/compiler | Status | Evidence | Missing work |
|---|---|---|---|---|---|---|
| Exported C functions over Botlish functions | | | no export, no library output (`aot.rs:220-241`) | stand-in | `libmode.tcl`; C, Hermes host, CI | library mode (section 7) |
| Export roots (functions compiled though the program never calls them) | | | worklist starts at the program (`native/lower.tcl:1567-1570`) | absent | the probe's top level must call each export | roots from the export list |
| Library startup (Vm without `main`) | | | constants, ProgramInfo and stack maps exist only in the generated `main` (`aot.rs:74-192`) | stand-in | `libmode.tcl` captures `startup.rs` | a library startup in core |
| Uniform tagged entry per function | | | `botlish_entry_N` converts raw, short and ASCII ABIs (`clif.rs:422-540`) | works | the stand-in calls them | trampolines with C types |
| Per-compilation symbol names | | | `botlish_fn_N` / `botlish_entry_N` (`clif.rs:298-319`) | absent | two libraries link silently, wrong result | prefixing or local linkage |
| Several Botlish programs per process | | | thread-local `PROGRAM` is overwritten per `Vm::new` (`vm.rs:97-99,255`); context area process-wide (`clif.rs:267-281`) | absent | section 9 | per-Vm program info |
| Runtime compiles for the target | x86_64 yes; aarch64 no | no | duplicate `prepare` (`coroutine.rs:566-591`) | small | `cargo check`; CI | the one-line `cfg` patch |
| Frame pointers in runtime frames (GC walk) | not forced | not forced | `.cargo/config.toml:42-59` lists 4 triples | small | probe passes `RUSTFLAGS` | add the mobile triples |
| Machine code for the target | x86_64 host only; aarch64 needs an arm64 host | Mac host emits macOS-tagged Mach-O | ISA from `cranelift_native` (`codegen/mod.rs:164`); `check_host` (`target.rs:117-135`) | small | CI: object `platform 1` | ISA from the target triple |
| Target identity | absent | absent | 7 rows, no mobile (`core/cabi.tcl:81-88`) | absent | | android-*, ios-* rows |
| PIC object for a shared library | works (`R_X86_64_PLT32`; AArch64 GOT and `CALL26` only) | Mach-O arm64 is PIC | | works | `-shared -z text` link; CI readelf | |
| Static library production | stand-in (rustc staticlib + `ar`) | stand-in | | stand-in | 34.9 MB, 15.6 MB stripped | strip, LTO, size budget |
| Stack bounds and overflow guard | none (`runtime/mod.rs:38-39`) | none | guard installs a process-wide SIGSEGV handler and `_exit`s (`guard.rs:141-158`) | blocked | section 9 | embedding policy, platform modules |
| GC walk ends at the embedding boundary | | | walks the whole FP chain (`framewalk.rs:170-216`) | absent | survived GC stress on Linux | stop at the export frame |
| Dedicated Botlish thread, large stack | | | executables only (`runtime/aot.rs:39-47`) | stand-in | `host_async.cpp`: 256 MiB worker | a library startup option |
| Coroutines | refused at run time (`RtError::Unsupported`, `coroutine.rs:255-260`) on both ABIs: the switch is cfg'd to Linux and macOS | refused the same way | stackful, `thread_local` pool | small | | widen the switch's cfg to Android and iOS (same ELF / Mach-O assembly); test on device |
| C FFI from Botlish (`extern c fn`) | not linked | not linked | Linux and macOS only (`aot.rs:215-218`) | absent | | outside this milestone |
| HIR signatures for a plugin | | | `hir::signatures::of`, `hir::moduleSignatures` | works | `libmode.tcl` | |
| Plugin loading / subcommands | | | none; main.tcl not sourceable (`main.tcl:328-341,686`) | absent | section 7 | plugin facility |
| Machine-readable diagnostics | | | text only (`main.tcl:353-384`) | absent | | `-diagnostics json` or a Tcl API |
| Cross-compile toolchain discovery | NDK not used by Botlish | Xcode not used | rustc picks the host linker (`aot.rs:304`) | absent | | not needed for static libraries |
| React Native packaging and calls from JS | runs in a stock app's release build on the x86_64 emulator (CI); arm64-v8a links, not run | runs in a stock app on the simulator (CI), with the program object's platform retagged | | works | section 9 | productize the generator; ISA from the triple; an arm64 device run |

## 4. Type mapping matrix

The Codegen column is what React Native 0.88's TypeScript parser accepts in a
module spec (`@react-native/codegen/lib/parsers/typescript/modules/index.js`,
`parsers/parsers-primitives.js:295-326`); the C++ column is what the
generated `CxxSpec` hands the implementation
(`generators/modules/GenerateModuleH.js`). The adapter's parameter and result
types are its own: `bridging::callFromJs` converts through `Bridging<T>`.

| Botlish | C ABI (library mode) | Adapter C++ | Codegen spec | JS/TS observable | Ownership / lifetime | Status |
|---|---|---|---|---|---|---|
| `bool` | `bool` in, `bool *out` | `bool` | `boolean` | boolean (`asBool` rejects others) | value | **works** |
| `int` | `int64_t`, status 2 on an Int result outside int64 | `double`, checked: finite, integral, at most 2^53 - 1 in magnitude, both ways | `number` | number; `TypeError`/`RangeError` with `code` | value | **works** (stand-in) |
| `int` as `Int32` | as above | never `int`: `Bridging<int32_t>::fromJs` is a C cast of a double (`react/bridging/Number.h:41-45`), undefined for NaN or out of range | `CodegenTypes.Int32` | number | value | **poor fit**; use `number` |
| integer domain (`std::byte::Byte`, `std::ffi::c::Int`, `std::abi::I32`) | `int64_t` plus the domain's range check | `double`, range from the HIR | `number` (or `Int32` checked in the adapter) | number | value | **small** |
| Int beyond 2^53 | `int64_t` or decimal text | string | `string` | string; there is no BigInt in Codegen | copy | **poor fit**; a deliberate choice per API |
| `Float64` | `double`; NaN and ±Inf rejected; -0 normalized (Botlish has none, `value.rs:44-47`) | `double` | `CodegenTypes.Double` / `number` | number | value | **small** (runtime has `new_float`) |
| `Float` (binary32) | | | `CodegenTypes.Float` | | | **poor fit**: no Botlish type |
| `str` | `const uint8_t *, size_t` in (copied into the heap); `BotlishStr` out, borrowed until the thread's next call | `std::string` (copied from and to JSI UTF-8) | `string` | string; a lone surrogate arrives as U+FFFD (measured) | copy at each crossing | **works** (stand-in) |
| `UnicodeChar` | `uint32_t` scalar | checked one-scalar string | `string` | one-character string | value | **small** |
| `unit` result | no out parameter | `void` | `void` | `undefined` | | **works** |
| declared error | status 1 with identity and message | throw `Error` with `code` = canonical identity | (none: specs have no error types) | `Error`, `e.code === "NotPositive"` | message copied | **works**; payload is **small** |
| runtime error (`RANGE`, `TYPE`, ...) | status 1, identity = error code | `Error` with that code | | `Error` | | **works** |
| native stack exhaustion | executables: `NATIVE LIMIT STACK` then `_exit` | | | process killed | | **blocked**: embedding policy (sections 9, 14) |
| `std::abi::bytes::Bytes` / `MutableBytes` | `const uint8_t *, size_t` in (copied); out: bytes copied into a `jsi::ArrayBuffer` (`OwnedBytesBuffer`, `react/bridging/ArrayBuffer.h`) | `jsi::ArrayBuffer` | `ArrayBuffer` | ArrayBuffer; no TypedArray type in Codegen (pass `.buffer`) | copy both ways (no pin API, GC heap) | **small** |
| `List[T]`, T scalar | `const T *, size_t`; out: a Botlish-owned array borrowed like a String | `std::vector<T>` / `jsi::Array` | `ReadonlyArray<T>` / `Array<T>` | array | copy | **small** |
| `List[str]`, nested lists | needs an element protocol (count plus per-element accessors) | `jsi::Array` | `Array<string>` | array | copy | **medium**: library-mode ABI v2 |
| struct (nominal or anonymous) | one C struct per Botlish struct type, field order from `ShapeInfo` (`vm.rs:54-73`), built with `Vm::new_struct` (`vm.rs:772`) | Codegen's `NativeFooPointBridging<T>` or `jsi::Object` | object type alias (`type Point = {x: Double}`) | plain object | copy | **medium** |
| enum (payload-free) | case by name (ENUMS.md: no ordinal, no String conversion; the boundary encodes identity, not order) | string switch | TS string `enum` whose values are the case names, or a string-literal union | string | value | **small**, with an ABI-level case encoding that the language never sees |
| optional parameter, `T \| null` | | | `s?: string`, `string \| null` | undefined / null | | **blocked**: Botlish has no null or optional type (`-help capability.null`); a nullable *result* could map from a declared error at the plugin's choice |
| `UnsafeObject`, `UnsafeMixed`, `{[k: string]: T}` | | | `Object`, `UnsafeMixed`, index signature | any object | | **poor fit**: no dynamic or map type (only `ImmutableSet`) |
| callback argument | C function pointer plus userdata, called on the JS thread | `AsyncCallback` / `SyncCallback` | `(x: T) => void` | function | `LongLivedObject` lifetime | **blocked**: Botlish never calls an `FnPtr` (C-FFI.md:1188-1189; C-ABI-TYPES.md:671-683) |
| Promise result | the same synchronous C call, run on the Botlish thread | `AsyncPromise<T>` (`react/bridging/Promise.h:20-100`) settled from that thread | `Promise<T>` | Promise | result copied on the Botlish thread | **works** by hand (host); generator: **small** |
| event emitter | Botlish-initiated calls into the host | `emitOnValue` (generated) | `CodegenTypes.EventEmitter<T>` | subscription | | **blocked**: callbacks |
| `getConstants` | an export of no arguments | | `getConstants(): {...}` | object | | **small** |
| `Fn`, `Coroutine`, `MutableVector`, `MutableArray` values | | | | | affine or GC-managed values have no host handle | **deliberately unsupported** at this boundary |

Numbers deserve their own summary:

* JS has one number type, binary64. Botlish `int` is arbitrary precision.
* The adapter accepts only what converts exactly: an integral double of at
  most 2^53 - 1 in magnitude.
* It returns only what JS holds exactly. `add(2**53 - 1, 1)` throws
  `RangeError` rather than rounding.
* Codegen's `Int32` is a documentation type. The generated conversion is
  unchecked and undefined for NaN or out-of-range values, so a Botlish
  adapter must never rely on it.

## 5. Android findings

### General Android port prerequisites (not React Native)

* **Target identity.** Add `android-x86_64` and `android-aarch64` rows to
  `core/cabi.tcl:81-88`.
  * Model LP64; char signedness as on Linux: signed on x86_64, unsigned on
    AArch64.
  * Triples `x86_64-linux-android` and `aarch64-linux-android`.
  * target-lexicon parses Android as OS Linux, environment Android, so
    `same_target` (`target.rs:103-106`) would equate it with
    `linux-x86_64`. Keep it a target of its own, per AGENTS.md's
    "Compilation targets".
  * Whether the `linux` namespace (raw syscalls) is Android's too is a
    platform decision for that milestone: Android's seccomp filter limits
    syscalls.
* **Code for the target, from any host.**
  * The ISA must come from the target's triple, not `cranelift_native`
    (`codegen/mod.rs:148-166`).
  * The driver must build Cranelift with the backends it targets: today it
    keeps the default `host-arch` feature.
  * `check_host` (`target.rs:117-135`) must allow emitting objects (never
    running them) for another target.
  * Measured: the x86_64 Linux object is position-independent and links into
    a shared library under `-z text`. The AArch64 object (CI, arm64 host)
    uses only GOT-relative and `CALL26` relocations. ELF, PIC and no TLS fit
    Android's loader as they are.
* **The runtime.**
  * `x86_64-linux-android`: builds unchanged (1 min 45 s).
  * `aarch64-linux-android`: needs the `cfg` patch. With it, CI built the
    library.
  * Frame pointers must be forced: `.cargo/config.toml:42-59` lists four
    triples, and the GC's walker reads the runtime's own frames
    (`framewalk.rs:1-57`).
  * Rust std links `-ldl -llog -lunwind -lm -lc` on Android (measured with
    `--print native-static-libs`).
  * Bionic has `pthread_getattr_np`, so `runtime/platform/linux.rs` could
    serve Android's stack bounds once its cfg admits `target_os = "android"`.
    Today Android is a fallback host: a 32 MiB shadow stack, no overflow
    guard, no probestack (`vm.rs:248-254`, `native_stack.rs:101-103`).
* **ABIs.**
  * `arm64-v8a` (devices) and `x86_64` (emulators, Chromebooks) are the two
    Botlish can serve.
  * Cranelift has no 32-bit ARM or x86 backend, so `armeabi-v7a` and `x86`
    are out of reach whatever the effort.
  * The React Native 0.88 template builds all four
    (`reactNativeArchitectures=armeabi-v7a,arm64-v8a,x86,x86_64`). The
    generated package therefore compiles a stub for those two (every call
    fails with `BOTLISH_UNAVAILABLE`), so an unmodified app still builds.
* **API level.** The template's minSdk 24 is above Rust's Android baseline;
  nothing in the probe needed more.
* **Static, not shared.** The Botlish library is a static archive linked into
  the app's `libappmodules.so`. Android's page-size alignment, the loader's
  rules and stripping are therefore the app toolchain's.
  `-Wl,--exclude-libs,libfoo_botlish.a` keeps the runtime's 3,229 global
  symbols out of the `.so`'s dynamic table (2,243 dynamic exports without
  it, measured).

### React Native glue for Android

* **No Gradle module.** A package with the three `cxxModule*` keys in
  `react-native.config.js` and no `AndroidManifest.xml` or `build.gradle` is
  a pure C++ dependency (`@react-native-community/cli-config-android/build/
  config/index.js:112`).
* **CMake.** The React Native Gradle plugin's
  `GenerateAutolinkingNewArchitecturesFileTask` writes `autolinking.cpp`. It:
  * `add_subdirectory`s the package's CMake file (`...FileTask.kt:86`) and
    adds its target to `libappmodules.so`;
  * `#include`s `<cxxModuleHeaderName.h>`;
  * returns `std::make_shared<cxxModuleHeaderName>(jsInvoker)` when the
    module name matches `cxxModuleHeaderName::kModuleName` (`:164`).
  * So the class name, header name and module provider are one name, in
    namespace `facebook::react`.
* **No OnLoad.cpp edit.** The default `OnLoad.cpp` already falls back to
  `autolinking_cxxModuleProvider`
  (`ReactAndroid/cmake-utils/default-app-setup/OnLoad.cpp:63-75`). React
  Native's documentation edits it only for C++ code that lives in the app
  itself (`docs/the-new-architecture/pure-cxx-modules.md`).
* **Codegen.** With `includesGeneratedCode: true` the package ships
  `android/generated/jni/CMakeLists.txt` (target `react_codegen_<Name>Spec`)
  and `react-native.config.js` points `cmakeListsPath` at it. Without it,
  the app's Gradle Codegen writes a pure C++ dependency's spec into its own
  directory (`generatedPureCxxSourceDirectory`, `...FileTask.kt`'s
  `cmakeListsPathForDependency`).
* **No AAR.** An npm package with static archives per ABI is enough: the
  app's own native build makes the shared object.

## 6. iOS findings

### General iOS port prerequisites (not React Native)

* **"macOS arm64 works" is not "iOS works".** The instruction set, the
  Mach-O format and Apple's AArch64 calling convention are shared. The
  target, the object's platform, the SDK and the runtime build are not.
* **Target identity.** Add `ios-aarch64` (device) and
  `ios-aarch64-simulator` rows. They are two targets: a static library
  cannot hold both slices, because both are arm64.
  * Shipping them together is an `.xcframework`.
  * An x86_64 simulator (Intel Macs) needs Botlish's `macos-x86_64` native
    support, which does not exist (`aot.rs:204-207`). Defer it.
* **The object's platform.**
  * `cranelift-object` sets `LC_BUILD_VERSION` from the ISA's triple
    (`cranelift-object-0.135.2/src/backend.rs:177-271`).
  * Botlish's ISA is the host's, so CI measured `platform 1 minos 0.0.0`
    (macOS) on the iOS-simulator library's program object.
  * Building the ISA for `aarch64-apple-ios-sim` or `aarch64-apple-ios` sets
    platform 7 or 2. Section 9 records what Apple's linker did with platform
    1 (refused) and platform 7 (linked, and the app ran). No device build,
    platform 2, was attempted: it needs signing, and CI has no device.
* **The runtime.**
  * It needs the `cfg` patch and, like Android, forced frame pointers.
    Apple's ABI keeps frame records in calling functions; the config states
    it for macOS, `.cargo/config.toml:52-59`.
  * Build it with `IPHONEOS_DEPLOYMENT_TARGET=15.1`, React Native 0.88's
    minimum (`scripts/cocoapods/helpers.rb:83-85`). Rust's default object
    for iOS is otherwise tagged with an older minimum.
  * `runtime/platform/macos.rs`'s stack discovery (`pthread_get_stackaddr_np`,
    `mach_vm_region`) and the Mach-O spelling of the coroutine switch are
    candidates for iOS, untested there.
* **No JIT, no bitcode.** iOS forbids writable executable memory, but the
  library is ahead-of-time code. Bitcode is gone: Xcode 14 deprecated it and
  the App Store no longer takes it.

### React Native glue for iOS

* **Registration without app edits.** The package's
  `codegenConfig.ios.modulesProvider` maps the JS module name to an
  Objective-C++ class conforming to `RCTModuleProvider`.
  * The app's Codegen collects every dependency's map into
    `RCTModuleProviders.mm`
    (`scripts/codegen/generate-artifacts-executor/generateRCTModuleProviders.js:72-100`).
  * Measured: `@"BotlishProbe": @"BotlishProbeModuleProvider", //
    react-native-botlish-probe`.
  * A newer spelling, `ios.modules.NAME.className`, is parsed too, and a
    module claimed by two libraries is an error
    (`generate-artifacts-executor/utils.js:391-450`).
  * `create-react-native-library`'s C++ template uses a `+load` call of
    `registerCxxModuleToGlobalModuleMap` instead
    (`ReactCommon/CxxTurboModuleUtils.h:27`). The provider is the documented
    mechanism, and the one the probe uses; the census did not test the
    global map.
* **The pod.**
  * `install_modules_dependencies(s)` brings React Native's headers.
  * Folly is among them. `react/bridging/Bridging.h` includes
    `folly/dynamic.h`, so every C++ TurboModule depends on folly headers;
    found compiling on the host.
  * React Native 0.88 uses prebuilt dependencies and a prebuilt React core
    by default (`scripts/react_native_pods.rb:116-117`). The
    `ENV['RCT_USE_RN_DEP'] = '1'` that the library template's example
    Podfile sets "for C++ module" is now the default, and a stock app needs
    no Podfile edit.
* **CocoaPods is deprecated.** `pod install` prints "Calling `pod install`
  directly is deprecated ... moving away from Cocoapods"
  (`react_native_pods.rb:518-535`).
  * The replacement is Swift Package Manager (`npx react-native spm`,
    `scripts/setup-apple-spm.js`).
  * It scaffolds a `Package.swift` for libraries that ship none, translating
    their podspec (`scripts/spm/scaffold-package-swift.js`).
  * The plugin should ship a podspec now and its own `Package.swift`, a
    binary target for the `.xcframework`, as soon as that path is the
    default.

## 7. Compiler-plugin findings

### What exists

* **No plugin, hook or extension mechanism anywhere.**
  * main.tcl runs at top level, sources the compiler and ends with `exit`
    (`main.tcl:328-341,686`). It cannot be sourced as a library.
  * Its run backends for `.bot` files are a hard-coded dict
    (`main.tcl:458-463`).
  * `core::registerBackend` (`core/evaluator.tcl:547-578`) registers core-IR
    *evaluators*, not artifact emitters.
* **The real seam is the Tcl library**, which the repository's own tools
  drive:
  * `tools/c-bindgen.tcl`, `tools/compilerpedia.tcl` and 159 audit and tool
    scripts each `source` `native/native.tcl` (or `surface/surface.tcl`).
  * They compile with `surface::readProgramFile PATH -warnings ...
    -warning-channel "" -target T`.
  * They read the HIR after `hir::activate`. The rule for any new entry
    point is in AGENTS.md, "Compilation isolation".
* **Everything the React Native plugin needs from a compiled module is
  there:**
  * `hir::signatures::of` (`hir/signatures.tcl:194-212`) gives each
    parameter's declared type, the result and the declared errors.
  * `hir::moduleSignatures` (`hir/hir.tcl:1457-1475`) gives every module
    function.
  * `hir::originLocation` places a binding in its file.
  * `libmode.tcl` uses exactly these.
* **Native artifacts from Tcl:**
  * `native::nir` gives NIR text.
  * `native::object` gives a bare object, but only as a smoke test: the
    constant pool and program tables are missing (`native/native.tcl:45`,
    `869-875`).
  * `native::executable` gives the linked executable.
* **External tools.** The C-header tooling runs every tool with an argv list
  (`tools/cheader/toolchain.tcl:229-241`), never a shell.
* **Precedents:**
  * Loading a user Tcl file: c-bindgen profiles
    (`tools/c-bindgen/profile.tcl:66-75`).
  * Generating many files as a dict: `::cbind::generate::run`.
  * Deterministic, committed generated output: `generated/c/`.
* **No JSON** reader or writer in the tree. The prototype writes
  `package.json` with a 30-line tagged-value writer. Reading JSON can be
  `node`'s job: Node is a hard dependency of any React Native build anyway.

### Seam census

Classes: (1) React-Native-specific, stays in the plugin; (2) a general
compiler capability worth adding to core; (3) blocked on a separate
milestone.

| Operation | Today | Class |
|---|---|---|
| Inspect resolved functions and types | yes: `hir::signatures::of`, `hir::moduleSignatures` (needs `hir::activate`) | have |
| Select and export named functions | no exports at all | **2**: library mode's export list |
| Compile functions the program never calls | no (`native/lower.tcl:1567-1570`) | **2**: export roots |
| Request a native target | `-target` for the front end; machine code host-only | **2** (target rows, ISA from triple) |
| Obtain object/library artifacts | executables; a bare object without its tables | **2**: library mode |
| A stable C ABI and header | no | **2**: trampolines, header, export manifest |
| Add generated native shim sources | the plugin writes them; the app's toolchain builds them | **1** |
| Link extra native libraries | `extern c library` for Botlish's own link; the package's CMake/podspec for the app's | **1** |
| Emit auxiliary files, a directory, a package | tools write files; main.tcl writes beside its input (`main.tcl:596`) | **1** (plus **2**: an output-directory option) |
| Shell out to tools | `exec` with argv lists | have |
| Discover toolchains | `tools/cheader/toolchain.tcl` (C compilers only) | **1** (Node, Gradle, CocoaPods are the plugin's) |
| Validation before code generation | the plugin checks signatures | **1** |
| Hook after type checking or after native compilation | no hooks; a driver calls the steps in order | not needed: a driver composes them |
| Contribute CLI options or subcommands | no | **2**: a plugin facility |
| Structured diagnostics | text; `-diagnostics` list in Tcl with the location in the message (`core/errors.tcl:62-69`, `hir/recovery.tcl:196-207`) | **2**: positions as data |
| Plugin configuration | none | **1** (the plugin's manifest) |
| Cache generated artifacts | front-end cache only, HIR (`surface/cache.tcl:90-103`) | **1** (key on `hir::interchange::fingerprint`) |
| Participate in tests | `tests/local.tcl` runs `tests/*.test` | **2** (minor: a plugin's tests in the suite) |
| Botlish code callable from Tcl | no | **3** (library mode, then a Tcl extension) |
| Callbacks, events | no | **3** (FnPtr calls, C-ABI-TYPES.md:671-683) |

### The smallest coherent core extension

Five general capabilities, none of them React-Native-specific. Each would
equally serve a Python extension, a Node addon or a game-engine plugin.

1. **Library mode.**
   * Entry points: `native::library HIR -exports NAMES -target T -prefix P
     -out DIR`, and the command line `-emit-native-library -export NAME ...
     -o DIR`.
   * It writes `libP_botlish.a`, `P_botlish.h` and a machine-readable export
     manifest.
   * It owns:
     * export roots in native lowering;
     * Cranelift-generated C-ABI trampolines over the generic entries:
       checked C scalars, UTF-8 strings, statuses, the error identity;
     * a library startup in the runtime: what `startup.rs` does, as data
       rather than generated Rust;
     * per-compilation symbol names;
     * one-runtime-per-process rules.
   * It deliberately excludes host-language policy: no JSI, no JS number
     rules, no packaging.
2. **An embedding runtime.**
   * The library startup's choice of thread: a runtime thread with a
     configurable stack (the executable's 1 GiB worker, as an option), or
     the caller's.
   * The overflow guard for that thread with an embedded policy: report and
     abort, never `_exit` with a result line.
   * The GC's frame walk ends at the export's frame.
   * Several programs per process: per-Vm program info, a per-program context
     area.
3. **Code for a named target.**
   * New target rows: android-x86_64, android-aarch64, ios-aarch64,
     ios-aarch64-simulator.
   * Cranelift's ISA built from the row's triple, with the backends the
     driver supports.
   * The runtime built per target with the frame-pointer flag.
   * `check_host` split into "may emit" and "may run".
4. **A plugin facility.**
   * `main.tcl -plugin PATH` (or `botlish NAME ...`) sources a Tcl file that
     registers subcommands against a small, versioned Tcl API: compile,
     signatures, library mode, diagnostics as data, output directory.
   * It is the c-bindgen profile pattern made public: no hooks into the
     pipeline, no callbacks inside analyses.
   * main.tcl's top level becomes a proc so that the same API serves both.
5. **Diagnostics as data.**
   * Each diagnostic as `{code message file line column}`, through the API
     and through a `-diagnostics json` flag. A plugin can then map Botlish
     errors to `file:line` without parsing message text.

What is **not** needed:

* A custom-backend plugin interface.
* Pipeline hooks (a driver calls the steps).
* A Rust component.
* A plugin-specific cache inside core.
* Anything about JSI, Codegen, Gradle or CocoaPods.

### Tcl as the plugin language

The prototype answers this empirically. In Tcl it:

* reads the export manifest;
* derives every name;
* generates all of the package's text: JSON, TypeScript, C++, C, CMake,
  Ruby podspec, Objective-C++;
* runs `npx` Codegen from a React Native project;
* handles paths with spaces;
* and is deterministic: two runs, Codegen included, were byte-identical.

That takes 525 lines (`rnpackage.tcl`).

It also:

* orchestrated `rustc`, `ar`, `clang++`, `npm pack`/`npm install` and Gradle
  through the CI scripts;
* drove Hermes on the host;
* patched a Mach-O load command with `binary scan`/`binary format`.

Nothing called for another language. Tcl's one gap is JSON *reading*: leave
it to `node -p`, or a small parser in the plugin.

## 8. External tooling and dependencies

| Need | Required for | Optional? |
|---|---|---|
| Botlish (Tcl 9.0.1, its native driver, the runtime built per target) | library mode | no |
| `rustup` targets `x86_64-linux-android`, `aarch64-linux-android`, `aarch64-apple-ios`, `aarch64-apple-ios-sim` | building the runtime per target, until it ships prebuilt | no (unless the single executable ships the runtimes) |
| An arm64 host, or Cranelift cross-targeting | AArch64 objects | no, until slice 3 |
| Node 22 and the app's or package's `react-native` and `@react-native-community/cli` | Codegen (`npx @react-native-community/cli codegen --source library`), `npm pack` | no (Codegen can be left to the app with `includesGeneratedCode: false`) |
| `ar` | static archives | no |
| Android SDK, NDK 27.1.12297006, Gradle 9.4.1, JDK 17 | building the app | the app's, never the plugin's |
| Xcode 16+, CocoaPods (or SwiftPM), Ruby/Bundler | building the iOS app | the app's |
| `xcodebuild -create-xcframework`, `lipo` | packaging device and simulator slices | macOS only; needed once both slices exist |
| Hermes and folly sources, clang, glog | the host harness only | yes: CI and development only |
| An emulator or simulator | device tests | yes |

The plugin needs no globally installed React Native toolchain:

* Codegen ran with `npx --no-install` from a project's own `node_modules`.
* The package's tarball installed into an app that brought its own React
  Native.
* The plugin should take the React Native project to run Codegen from as an
  option (`-codegen-project` in the prototype), or leave Codegen to the app.

## 9. Empirical results

### Environment limits

This sandbox has no Android SDK or NDK (`dl.google.com` is refused by the
egress policy), no macOS, and cannot reach `reactnative.dev` or
`repo.reactnative.dev`. Maven Central redirects the `react-android` AAR
there. Instead:

* the React Native contract was read from the published npm packages and
  the `react-native-website` repository's 0.87/next docs (identical for
  `pure-cxx-modules.md`);
* JavaScript ran on a Hermes built here from React Native's pinned tag;
* the mobile builds ran in GitHub Actions (`react-native-probe.yml`).

### The host spike: JS to Botlish through React Native's C++ layer

`tclsh9.0 audit/react-native/tools/host-spike.tcl` (section 16) does, from
the committed tree:

1. `libmode.tcl` builds `librnprobe_botlish.a` from
   `audit/react-native/probe/rnprobe.bot`: six exports in 1.5 s.
2. `rnpackage.tcl` generates the package and runs React Native Codegen on
   it.
3. clang compiles the generated adapter, React Native's own
   `TurboModule.cpp`, `TurboModuleBinding.cpp`, `LongLivedObject.cpp` and
   `jsi-utils.cpp`, and `host/host_main.cpp`.
4. It links them with Hermes's `libhermesvm.so` and runs `host/probe.js`,
   which looks the module up exactly as `TurboModuleRegistry.getEnforcing`
   does (`global.__turboModuleProxy`,
   `Libraries/TurboModule/TurboModuleRegistry.js:17-31`).

Output (React Native 0.88.0, Hermes `hermes-v260318099.0.4`, x86-64 Linux):

```
add(2, 3) => 5
add(-7, 2**52) => 4503599627370489
add(2**53 - 1, 1) threw RangeError BOTLISH_INT_RANGE "add: the result is not a safe integer"
add(1.5, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
add(NaN, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
add("2", 1) threw Error undefined "Exception in HostFunction: Value is a string, expected a number"
add(1) threw Error undefined "Expected argument in position 1 to be passed"
reverse("héllo, wörld") => "dlröw ,olléh"
reverse("a😀b") => "b😀a"
reverse("\ud800") => "�"
reverse("") => ""
requirePositive(5) => 5
requirePositive(-1) threw Error NotPositive "requirePositive: uncaught propagated error: <error NotPositive>"
depth(1000) => 1000
same("añb", "añb") => true
same("a", "b") => false
pick(true, "left", "right") => "left"
pick(false, "left", "right") => "right"
pick(1, "left", "right") threw Error undefined "Exception in HostFunction: Value is a number, expected a boolean"
100000 reverse calls, last => "y99999x" in 77 ms
```

What this proves:

* The Codegen spec's own checks reject a wrong JS kind and a missing
  argument before the adapter runs. The adapter's checks catch what the spec
  admits: fractions, NaN, unsafe integers, results JS cannot hold.
* A declared Botlish error reaches JS as an `Error` whose `code` is its
  canonical identity.
* Strings cross by Unicode scalar value. Botlish reverses `a😀b` by scalars,
  and a lone surrogate becomes U+FFFD in JSI's UTF-8 conversion. That is a
  policy for the adapter to state or refuse, not a Botlish choice.
* A call costs 0.8 to 1.3 µs (100,000 `reverse` calls in 77 to 125 ms across
  runs), including JS's loop and string building.
* `BOTLISH_NATIVE_GC_STRESS=1` (a collection before every allocation) passes,
  including the two-String calls whose arguments the wrapper must root.
  Note what that covers: the GC's frame walk climbed through the C++ and
  Hermes frames above the call on Linux, where the runtime knows the
  thread's stack bounds. Android and iOS have no such bounds yet (section 3).

### Stack depth on a JavaScript thread's stack

`depth(n)` recurses without a tail call. The host harness ran it on the
calling thread, as a synchronous TurboModule call does:

| Stack | Largest `depth` that returned | First that killed the process |
|---|---|---|
| 512 KiB (iOS release JS thread: `NSThread` default, doubled only under `RCT_DEBUG`, `RCTJSThreadManager.mm:61-69`) | 10,000 | 20,000: SIGSEGV |
| 1 MiB (about an Android Java thread's default; the JS thread passes 0, `MessageQueueThreadSpec.kt:26`) | 20,000 | 50,000: SIGSEGV |
| 8 MiB | 100,000 | 200,000: SIGSEGV |

* There is no `NATIVE LIMIT STACK` and no JS exception: the guard exists
  only in executables and only on Linux and macOS.
* A Botlish executable gets a 1 GiB worker stack (`runtime/aot.rs:40-46`),
  and Botlish has no loops that accumulate (there is no assignment), so deep
  recursion is ordinary Botlish.
* A self tail call (`reverse_into`) is fine: 64,000 deep on 512 KiB.

### The asynchronous variant

`host/host_async.cpp` is a hand-written Promise-returning module:

* Its spec is `host/NativeBotlishAsync.ts`.
* Each call is posted to one Botlish worker thread with a 256 MiB stack,
  which settles React Native's `AsyncPromise`. The settlement is scheduled
  back to the JS thread through the module's `CallInvoker`.
* The JS thread's stack is 512 KiB.

```
depth(1000000) returned a [object Object] after 0 ms
depth(1000000) => 1000000 after 82 ms
reverse("héllo, wörld") => "dlröw ,olléh"
1000 queued reverse calls, last => "é999x"
tearing down with 1 JS task(s) unrun
runtime, module and Botlish worker torn down
```

* A million-frame recursion works off the JS thread, and the JS thread
  never waits.
* Calls run in order on one Vm, and the Vm's thread-local state stays on its
  thread.
* Teardown with work still queued (as a reload does it) joins the worker
  cleanly.
* All of it holds under GC stress.

### Two Botlish libraries in one binary

The probe library (`rnprobe_*`) and a second one from a different module
(`other_twice`) were linked into one C program:

* **The link succeeded with no diagnostic, and `other_twice(21)` returned
  140538536848112.**
* Both program objects define `botlish_fn_0`, `botlish_entry_0`, and so on.
  The linker took the first archive's, so the second library's wrappers
  called the first library's functions.
* The two runtimes' `rt_*` symbols merged the same way.
* Per-compilation symbol names, and a runtime that tolerates several
  programs, are hard requirements of library mode (section 7). A React
  Native app with two Botlish packages is otherwise silently wrong.

### Sizes

* `librnprobe_botlish.a`:
  * x86_64 Linux and Android: 34.9 MB, with the runtime's debug info
    (`native/Cargo.toml`'s `debug = 1`); 15.6 MB stripped (4.8 MB gzipped).
  * iOS simulator: 26.6 MB unstripped.
* Linked, the runtime plus the probe is about 525 KB of text (a stripped
  executable calling every export).
* The npm tarball with one unstripped ABI is 8.1 MB; with the iOS library,
  8.4 MB.

### Mobile CI (`react-native-probe.yml`)

Runs on the census branch:
[run 1](https://github.com/mwagner-webdev/botlish/actions/runs/39455138158),
[run 2](https://github.com/mwagner-webdev/botlish/actions/runs/39457386646),
[run 4](https://github.com/mwagner-webdev/botlish/actions/runs/39460827625),
[run 5](https://github.com/mwagner-webdev/botlish/actions/runs/39464674965)
and [run 6](https://github.com/mwagner-webdev/botlish/actions/runs/39470250205)
(Android only). Run 3 was cancelled; run 4 replaced it.

**Android arm64-v8a library** (ubuntu-24.04-arm, run 1):

* The runtime for `aarch64-linux-android` built with the `cfg` patch. The
  arm64 host's native backend emitted the program object.
* `readelf` of that object: `Machine: AArch64`, relocations only
  `R_AARCH64_ADR_GOT_PAGE` (19), `R_AARCH64_LD64_GOT_LO12_NC` (19) and
  `R_AARCH64_CALL26` (16), so it is position-independent.

**Android app** (ubuntu-latest, run 1):

* A stock `@react-native-community/cli@20.2.0 init` app, React Native 0.88.0,
  in a directory with a space in its name, installed the generated package
  from its `npm pack` tarball. `npx react-native config` reported it as
  `isPureCxxDependency: true` with the generated `cxxModule*` values. The
  only file of the app changed is its screen, `App.tsx`.
* `./gradlew assembleRelease` with the template's own four ABIs: **BUILD
  SUCCESSFUL in 4m 30s.** No Gradle, Java, Kotlin, `OnLoad.cpp` or
  `gradle.properties` change.
* The APK (56.6 MB) held `libappmodules.so` per ABI:

  | ABI | `libappmodules.so` | Botlish | dynamic `rnprobe_*` symbols |
  |---|---:|---|---:|
  | arm64-v8a | 691,056 bytes | the real library | 0 (`--exclude-libs`) |
  | x86_64 | 733,216 bytes | the real library | 0 |
  | armeabi-v7a | 115,560 bytes | the `BOTLISH_UNAVAILABLE` stub | 5 |
  | x86 | 175,096 bytes | the stub | 5 |

  So the runtime and the probe add about 560 to 575 KB to each 64-bit ABI.
  None has a `TEXTREL`. `NEEDED` adds `liblog.so`, `libdl.so` and `libm.so`
  to React Native's own.
* The emulator did not start in run 1: the emulator action's `sdkmanager`
  could not unpack the emulator package ("Error on ZipFile unknown
  archive"; it also warned that it cannot read SDK XML version 4). Run 2
  installs the current command-line tools first (`ci/android-emulator.sh`).

Run 2 rebuilt the same package with the two new exports:

* The release build succeeded again, in 4 min 34 s.
* The emulator binary installed, then would not start:
  `qemu-system-x86_64: error while loading shared libraries: libpulse.so.0`.
  The runner image lacks PulseAudio's and some X libraries. Run 4 installs
  them.

Runs 4 to 6 got the emulator running:

* Run 4's emulator never reached `adb`, and the script's timeout ended the
  step before it printed the emulator's log.
* [Run 5](https://github.com/mwagner-webdev/botlish/actions/runs/39464674965)
  printed it: the emulator exited at once, `Unknown AVD name [probe] ...
  there is no file probe.ini in $HOME/.android/avd`. The current
  command-line tools' `avdmanager` and emulator 37.2.12 disagree on the
  default AVD directory. Run 4's ten silent minutes fit the same failure.
* [Run 6](https://github.com/mwagner-webdev/botlish/actions/runs/39470250205)
  sets `ANDROID_AVD_HOME` for both. **Botlish code ran inside the stock
  React Native app on the Android emulator.**
  * The emulator (API 34, `google_apis`, x86_64, KVM) booted in about 30 s.
  * The release APK installed, and `MainActivity` started cold in 1.6 s.
  * Every probe line reached logcat, all as the host spike predicted:

    ```
    I ReactNativeJS: BOTLISH_PROBE add(2, 3) => 5
    I ReactNativeJS: BOTLISH_PROBE add(2**53 - 1, 1) threw RangeError BOTLISH_INT_RANGE "add: the result is not a safe integer"
    I ReactNativeJS: BOTLISH_PROBE add(1.5, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
    I ReactNativeJS: BOTLISH_PROBE reverse("héllo, wörld") => "dlröw ,olléh"
    I ReactNativeJS: BOTLISH_PROBE reverse("a😀b") => "b😀a"
    I ReactNativeJS: BOTLISH_PROBE requirePositive(5) => 5
    I ReactNativeJS: BOTLISH_PROBE requirePositive(-1) threw Error NotPositive "requirePositive: uncaught propagated error: <error NotPositive>"
    I ReactNativeJS: BOTLISH_PROBE depth(1000) => 1000
    I ReactNativeJS: BOTLISH_PROBE same("añb", "añb") => true
    I ReactNativeJS: BOTLISH_PROBE pick(false, "left", "right") => "right"
    I ReactNativeJS: BOTLISH_PROBE 100000 reverse calls => "y99999x" in 316 ms
    I ReactNativeJS: BOTLISH_PROBE done
    ```

* What ran was the x86_64 `libappmodules.so` of the template's unmodified
  release build:
  * the runtime built for `x86_64-linux-android`, without the `cfg` patch
    (frame pointers forced, as section 5 says);
  * the probe's program object exactly as the Linux host's native backend
    emits it, which the NDK's linker took as it is (Apple's refused the
    Mac's, below).
* A call cost about 3.2 µs, including JS's loop and string building, on an
  emulated device inside a CI runner.
* The same APK carried the arm64-v8a library, built on the arm64 runner.
  No arm64 device or emulator ran it in this census.

**iOS library** (macos-15, run 1):

* The runtime for `aarch64-apple-ios-sim` built with the `cfg` patch and
  `IPHONEOS_DEPLOYMENT_TARGET=15.1`: 26.6 MB unstripped.
* The program object, made by the Mac's own native backend:
  `LC_BUILD_VERSION platform 1 minos 0.0.0`, that is macOS (`otool -l`
  agrees).
* `pod install` failed in run 1 before it read the Podfile:
  `Unicode Normalization not appropriate for ASCII-8BIT` in CocoaPods'
  `installation_root`. macOS has no `C.utf8` locale, which the repository's
  workflows set for Tcl. Run 2 runs the iOS job under `en_US.UTF-8`.

**iOS app** (macos-15, Xcode 16.4, iPhoneSimulator 18.5 SDK, CocoaPods
1.15.2 from the template's Gemfile, run 2):

* `pod install` under `en_US.UTF-8` succeeded. React Native's own messages
  include the deprecation notice (section 6) and `[ReactNativeCore]
  Configuring xcconfig for prebuilt React Native Core`. The app's Podfile
  was not touched.
* **Build A**, the program object as the Mac makes it, failed at the link:

  ```
  ld: building for 'iOS-simulator', but linking in object file (.../ios/lib/librnprobe_botlish.a[424](program.o)) built for 'macOS'
  ```

* **Build B**, the same object with its `LC_BUILD_VERSION` rewritten to
  platform 7 (iOS simulator), minimum 15.1, by `tools/macho-platform.tcl`:
  **BUILD SUCCEEDED**.
  * The platform tag was the only thing between Mac-made Botlish code and
    an iOS app. The code, relocations and calling convention were already
    right, and the runtime built for `aarch64-apple-ios-sim` linked as it
    is.
  * Code generation for the iOS triple sets that tag by itself (section 6).
* The simulator (an iPhone 17 Pro device type) booted after 1 min 39 s, and
  the app installed and launched (`org.botlish.probeapp: 18896`).
* No `BOTLISH_PROBE` line reached the log stream within three minutes, and
  no crash report naming the app was found. A missing log line and a
  failure inside the app cannot be told apart from that alone. Run 4
  records the app's own log and process state, and runs the C stand-in as
  a control.

[Run 4](https://github.com/mwagner-webdev/botlish/actions/runs/39460827625)
repeated both builds (A failed with the same `ld` message, B succeeded) and
ran build B. **Botlish code ran inside the stock React Native app on the
iOS simulator.**

* The simulator booted in 1 min 36 s; the app launched as process 15423.
* Every probe line reached the log stream within the first second, all as
  the host spike predicted:

  ```
  BOTLISH_PROBE add(2, 3) => 5
  BOTLISH_PROBE add(2**53 - 1, 1) threw RangeError BOTLISH_INT_RANGE "add: the result is not a safe integer"
  BOTLISH_PROBE add(1.5, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
  BOTLISH_PROBE reverse("héllo, wörld") => "dlröw ,olléh"
  BOTLISH_PROBE reverse("a😀b") => "b😀a"
  BOTLISH_PROBE requirePositive(5) => 5
  BOTLISH_PROBE requirePositive(-1) threw Error NotPositive "requirePositive: uncaught propagated error: <error NotPositive>"
  BOTLISH_PROBE depth(1000) => 1000
  BOTLISH_PROBE same("añb", "añb") => true
  BOTLISH_PROBE pick(false, "left", "right") => "right"
  BOTLISH_PROBE 100000 reverse calls => "y99999x" in 190 ms
  BOTLISH_PROBE done
  ```

* So on the device side, the whole chain held:
  * the Mac's native backend made the machine code; its platform tag was
    the only change;
  * the runtime was built for `aarch64-apple-ios-sim`;
  * Codegen's spec and the generated adapter ran in a release build, with
    the JS bundled into the app and Hermes running it;
  * the module was registered by the package's `RCTModuleProvider`, which
    the app's own Codegen found through `modulesProvider`.
* A call cost about 1.9 µs, against 0.8 to 1.3 on the Linux host. That is
  JS's loop and string building included, on a shared CI Mac running a
  simulator.
* The C stand-in control was not needed, and did not run.
* `depth(1000)` ran on React Native's JS thread. The stack table above says
  how far beyond that it would go.
* Run 2 built the same app from the same sources and ran the same script,
  and saw no line. The likely cause is the log stream, not the app:
  * run 4's lines are timestamped before `simctl launch` had even returned;
  * a stream that attached later than its three-second head start would
    miss every one.
* [Run 5](https://github.com/mwagner-webdev/botlish/actions/runs/39464674965)
  launched only once the stream had printed its header. That took 7 s,
  more than the old head start, which fits that explanation without proving
  it. Run 5 then printed the same twelve lines, the 100,000 calls in 150 ms.
  Of the three runs that reached the simulator, runs 4 and 5 saw every
  line, and run 2, with the shorter head start, saw none.

## 10. Proposed implementation slices

The evidence supports this order. The host harness already proves the React
Native layer independent of a device, so plugin work can start on the host
right after library mode, before any mobile target exists.

1. **Runtime portability fixes** (core, tiny).
   * The `cfg` fix in `coroutine.rs`.
   * The four mobile triples in `.cargo/config.toml`'s frame-pointer list.
   * A CI job that `cargo check`s the runtime for them.
   * *Validation:* the runtime builds for all four with the repository's own
     build command; existing native tests unchanged.
2. **Library mode on the existing hosts** (core, general).
   * Export roots.
   * Cranelift-generated C trampolines for bool, int, Float64 and str.
   * A library startup.
   * Statuses and error identity.
   * Per-compilation symbol names.
   * The export manifest and the header.
   * *Validation:*
     * a C test calling every export on Linux x86-64 and AArch64 and macOS
       AArch64, under GC stress;
     * two libraries in one process, both correct;
     * `libmode.tcl` deleted.
3. **Embedding runtime** (core, general).
   * A runtime thread with a configurable stack and the overflow guard for
     that thread, with an embedded policy: report and abort, never `_exit`
     with a result line.
   * The GC walk stops at the export frame.
   * Several programs per process: per-Vm program info, per-program context
     area.
   * *Validation:* the host spike under GC stress, with `depth(1000000)` from
     a 512 KiB caller.
4. **Mobile targets** (core).
   * Target rows.
   * The ISA from the triple.
   * Mach-O platform and minimum OS.
   * Runtime builds per target.
   * Android's and iOS's stack discovery in `runtime/platform`.
   * *Validation:* four libraries from one host; CI links each into a React
     Native app; device or emulator runs.
5. **Plugin facility and diagnostics as data** (core, small; can run beside
   slice 2).
   * *Validation:* a test plugin's subcommand runs from main.tcl;
     diagnostics with positions as data.
6. **React Native plugin v1** (plugin, Tcl).
   * `rnpackage.tcl` made a product: a manifest, synchronous bool, int,
     Float64 and str, and the error mapping.
   * Android libraries per ABI, iOS `.xcframework`, the podspec.
   * *Validation:* this census's CI probe as a regression test, on emulator
     and simulator.
7. **Richer values** (core library-mode ABI v2, plus the plugin).
   * Bytes/ArrayBuffer, Lists of scalars and of Strings, structs, enums by
     case name, error payloads.
   * *Validation:* type-matrix rows move to "works", one test per row.
8. **Async** (plugin, on slice 3's thread).
   * Promise methods posted to the Botlish thread.
   * *Validation:* `host_async.cpp`'s behavior from generated code.
   * Later and separate: coroutine- or actor-hosted Botlish state across
     calls. That needs persistent roots and cross-call handles (section 14).

## 11. Non-goals and deferred work

* **Fabric/UI components**, view managers, a UI DSL.
* **Callbacks and event emitters.** Blocked on Botlish calling C function
  pointers (C-ABI-TYPES.md:671-683).
* **Values with no Botlish counterpart:** nullable and optional values (no
  null or optional type), `UnsafeObject`/maps (no map type), `Float`,
  `BigInt` (none in Codegen either).
* **Botlish state that outlives a call** (handles to Botlish values held by
  JS), coroutines across calls, an actor model.
* **32-bit Android ABIs** (no Cranelift backend), the x86_64 iOS simulator,
  Mac Catalyst, visionOS, tvOS.
* **Legacy bridge modules**, Expo modules and Nitro modules. Nitro is a
  `create-react-native-library` type; it is a different binding layer, not
  needed for a Pure C++ TurboModule.
* **`extern c fn` calls inside a mobile Botlish library.** Linking C from
  Botlish on mobile is the C FFI's port, after slice 4.
* **The `linux` platform on Android** (raw syscalls under seccomp).
* **Shipping the Botlish runtime prebuilt** in the single executable for
  every target, and size work (LTO, `panic=abort`, stripping) beyond
  stripping debug info.
* **SwiftPM packaging.** It should follow React Native's own move away from
  CocoaPods, not lead it.

## 12. Final recommendation

* **Should React Native support be a compiler plugin?**
  * Yes. Everything React-Native-specific is file generation and tool
    orchestration over a C ABI: the spec, the adapter, autolinking metadata,
    CMake, podspec, provider, Codegen invocation and number and string
    policy.
  * The prototype generated all of it without the compiler knowing React
    Native exists.
* **Should that plugin be primarily Tcl?**
  * Yes. The prototype is Tcl, generates every file deterministically,
    drives the ecosystem's tools with argv lists and handles paths with
    spaces.
  * Nothing in it called for Rust or for Botlish helpers.
* **What must change in compiler core?**
  * The general capabilities of section 7:
    1. library mode (export roots, C trampolines, library startup, unique
       symbols, export manifest);
    2. an embedding runtime (its own thread and stack, the walk boundary,
       several programs per process);
    3. code for mobile targets (target rows, ISA from the triple, runtime
       builds, the `cfg` fix);
    4. a small plugin facility with diagnostics as data.
  * None of it names React Native.
* **Is the thin C++ shim over Botlish's C ABI the recommended boundary?**
  * Yes. It confines React Native's C++ and Codegen churn to generated code,
    keeps the Botlish ABI testable from C, and is the shape React Native's
    own Pure C++ modules have.
  * Botlish never needs to implement `NativeFooCxxSpec<T>`.
* **Which platform is closer to viable today, Android or iOS?**
  * Android. Its x86_64 runtime builds unchanged, its objects need no
    platform tag, and its packaging needs no Gradle module. An x86_64
    emulator ran the very code a Linux host compiled, in the template's
    own release build.
  * iOS needs the `cfg` fix, target-triple code generation for the Mach-O
    platform, an `.xcframework`, and (soon) SwiftPM.
  * The simulator runs show how short that iOS list is. With only the
    platform tag rewritten, Mac-made Botlish code ran unchanged in a stock
    app.
* **What is the smallest credible vertical slice to implement next?**
  * Slices 1 and 2: the runtime portability fixes, then library mode on the
    existing Linux and macOS hosts.
  * Its acceptance test is this census's host spike with `libmode.tcl`
    deleted: the generated React Native package, Codegen's spec and React
    Native's own TurboModule code, calling compiler-produced exports on
    Hermes, under GC stress, with two libraries in one process.
  * The first device target after it is the Android x86_64 emulator run of
    section 9. CI already runs it with the stand-in, so the test is that run
    with compiler-produced exports in the stand-in's place.

## 13. The React Native contract, as found

### Pure C++ TurboModules and Codegen

* A spec is a TypeScript or Flow file named `Native*.ts` whose `Spec extends
  TurboModule`. `TurboModuleRegistry.getEnforcing<Spec>('Name')` gives JS the
  module (`docs/the-new-architecture/pure-cxx-modules.md`).
* Codegen generates `NativeNameCxxSpec<T>`, a CRTP template deriving
  `TurboModule`, a `jsi::HostObject` (`react/nativemodule/core/ReactCommon/
  TurboModule.h`).
  * Its constructor fills `methodMap_`.
  * Each method's invoker checks argument count and JS kind (`asNumber`,
    `asString`, `asBool`, `asObject`).
  * It then calls `bridging::callFromJs<R>(rt, &T::method, jsInvoker, self,
    args...)`.
  * So `T`'s methods may declare any parameter and result types that
    `Bridging<>` converts.
  * The generated header is byte-identical for iOS and Android (measured).
* TypeScript and Flow specs generate the same output: a four-method spec
  written both ways gave byte-identical Codegen output. The prototype writes
  TypeScript, the template's default.
* `--source library` makes the Codegen CLI generate a library's files only
  (`react-native-builder-bob`'s codegen target).

### Libraries, not apps

* `create-react-native-library` 0.63.1 `--type turbo-module --languages cpp`
  is the current library generator. Its layout is what the prototype
  follows:
  * `react-native.config.js` with `cxxModule*`;
  * `android/CMakeLists.txt` only;
  * `ios/OnLoad.mm`;
  * `includesGeneratedCode: true` with `outputDir`;
  * a podspec calling `install_modules_dependencies`;
  * bob's `codegen` target.
* Botlish should generate in that shape, not from the template: the
  template is a whole repository (example app, CI, lint), and the plugin
  needs its stable core only.
* **`includesGeneratedCode`:**
  * `true` ships Codegen's output. The app then skips that library
    (`generate-artifacts-executor/index.js:281-288`). The adapter is compiled
    against exactly the spec it was generated with, but the output is tied
    to the React Native version that generated it (`docs/the-new-
    architecture/codegen-cli.md`).
  * `false` lets the app's Codegen generate it.
  * Since the plugin regenerates the adapter per React Native version
    anyway, `true` costs little. Express the coupling with a
    `peerDependencies` range on `react-native`.

### Lifetime and threading

* A C++ TurboModule is created lazily on first access, one per JS runtime,
  and destroyed with it ("Native Modules are singleton",
  `docs/the-new-architecture/native-modules-lifecycle.md`).
* C++ modules have no `initialize`/`invalidate`: those are Android's and
  iOS's platform-module protocols. Their destructor is their teardown.
* Methods are synchronous JSI host functions on the JS thread
  (`TurboModule::create`). A `Promise` method returns at once and settles
  through `AsyncPromise`, whose `resolve`/`reject` may be called from any
  thread (`react/bridging/Promise.h`).

## 14. Async and coroutine semantics

* **What Codegen generates for a Promise method.** An invoker returning
  `jsi::Value`. The implementation returns `AsyncPromise<T>` (or any
  `jsi::Value`). There is nothing about threads; that is the
  implementation's choice.
* **Which thread calls it.** The JS thread, synchronously.
* **What may block.** Anything a synchronous method does blocks that
  thread. React Native's JS work stops for its duration, and on iOS it runs
  on a 512 KiB stack in release builds.
* **How completion is scheduled back.** `AsyncPromise::resolve` →
  `AsyncCallback` → `CallInvoker::invokeAsync` → the JS thread's queue
  (`ReactCommon/CallInvoker.h`). Measured in `host_async.cpp`.
* **Can a Botlish coroutine suspend without blocking the JS thread?**
  * Not across a return to JS today.
  * A coroutine is a Botlish value on its Vm's thread. Keeping one between
    two TurboModule calls needs a handle the host holds and the collector
    roots. The runtime has no persistent-root API, and a handle is affine.
  * Suspending *inside* one call on the Botlish thread is ordinary: the JS
    thread is not involved.
* **Where a Botlish runtime lives.** One Botlish thread per module instance,
  that is per JS runtime, owning one Vm. Measured.
  * The Vm's program info is thread-local and its context area
    process-wide (`vm.rs:97-99`; `clif.rs:267-281`).
  * So per-process or per-thread sharing between instances is unsafe today.
    Slice 3 makes per-instance state real.
* **Lifetime and shutdown.**
  * The module's destructor stops and joins the thread.
  * Promises left unsettled at teardown are dropped with the JS queue;
    `AsyncPromise` holds them weakly through `LongLivedObjectCollection`.
* **Reload and Fast Refresh.**
  * A full reload destroys the React instance, so the old module and its
    Botlish thread go and a new one starts with fresh module state.
  * Fast Refresh re-evaluates JavaScript only, so the native module and its
    Botlish state survive.
* **Packaging vs actor integration.** These are separate milestones. Slice
  8's Promise methods need only slice 3's thread. Botlish-side actors or
  long-lived coroutines across calls are a language and runtime design of
  their own.

## 15. The package-generation model

What the prototype generates, from React Native's conventions:

```
package.json            name, version, files, peerDependencies.react-native,
                        codegenConfig {name, type: modules, jsSrcsDir: src,
                        outputDir, android.javaPackageName,
                        ios.modulesProvider, includesGeneratedCode}
react-native.config.js  dependency.platforms.android.cxxModule*
src/NativeFoo.ts        the Codegen spec
src/index.ts            typed functions, JSDoc with the Botlish signature
cpp/FooModule.{h,cpp}   the adapter
botlish/foo_botlish.h   the C ABI (from library mode)
botlish/foo_unavailable.c  the C ABI's stub for CPUs without a library
android/CMakeLists.txt  adapter + imported libs/${ANDROID_ABI}/libfoo_botlish.a
android/libs/<abi>/     the Botlish libraries
android/generated/      Codegen (includesGeneratedCode)
ios/FooModuleProvider.mm  RCTModuleProvider
ios/lib/ (xcframework)  the Botlish library
ios/generated/          Codegen
Foo.podspec
```

* **A complete npm package or into an existing one?** A complete package
  directory, regenerated as a whole. Keep the user's own JS wrapper code in
  a separate package or a non-generated file, never in generated ones. A
  user who wants an existing package regenerates into a subdirectory.
* **Where metadata lives.**
  * A small manifest beside the Botlish module: the npm name, version,
    exports, optionally the JS module name and the Android package.
  * Not Botlish source: Botlish has no attributes, and the language keeps
    tooling out of its syntax.
  * Not `package.json`, which the plugin writes.
* **Defaults and derivations.** Everything shared across an app is derived
  from the npm name, which is unique in an app's `node_modules`.
  * The module name is the PascalCase of the name without `react-native-`.
    The JS module name must be unique in the app, and Codegen refuses
    duplicates on iOS.
  * The C++ class and header are `FooModule`: one namespace for every C++
    TurboModule, `facebook::react`, so a suffix avoids React Native's own
    names.
  * The Objective-C provider is `FooModuleProvider`: one runtime namespace.
  * The pod is `Foo`, the CMake target the npm name.
  * Every C symbol carries the library's prefix.
  * JS method names are camelCase, with collisions and the reserved names
    (`getConstants`, `constructor`, ...) refused.
  * The user must supply the npm name and the export list.
* **Determinism.** Yes: no time, host path or order. Two runs of the
  generator, Codegen included, were byte-identical.
* **What to commit.** The Botlish source and the manifest. The generated
  package is a build product, published to npm. Committing it is optional,
  like `generated/c/` here, and useful for review.
* **Ship Codegen output?** Yes (`includesGeneratedCode: true`), for the
  reason in section 13.
* **React Native version compatibility.** `peerDependencies.react-native`
  `>=MAJOR.MINOR`, the version the plugin generated and tested against. The
  plugin keeps a table of versions it knows.
* **Without a global toolchain.** Yes. Tools come from a project's
  `node_modules` through `npx --no-install`, which is the plugin's tool
  discovery: an explicit project directory, never a global install.
* **Surfacing tool errors.** Run each tool with an argv list and capture its
  output. On failure, report the command, its exit status and the tail of
  its output, prefixed with the step ("codegen", "npm pack"), as c-bindgen's
  toolchain adapter does.

## 16. Reproducing the probes

> Since NATIVE-LIBRARY-MILESTONE-1.md the host spike builds the probe with
> the compiler's own library mode (`exported c fn`, `main.tcl
> -emit-native-library`) and `rnpackage.tcl` reads its JSON manifest; that
> report's section 11 has the run. `libmode.tcl` no longer runs against the
> compiler, and the mobile probes run, by hand, at this census's revision
> (cc7e6e3b; `audit/react-native/README.md`). The list below is the
> material as this census used it.

The probe material:

* `audit/react-native/probe/rnprobe.bot`: the Botlish functions.
* `probe/standin.c`: the same C ABI written in C.
* `tools/libmode.tcl`: the library-mode stand-in.
* `tools/rnpackage.tcl`: the plugin prototype.
* `tools/host-spike.tcl`: the host probe.
* `tools/macho-platform.tcl`: reads or rewrites `LC_BUILD_VERSION`.
* `host/`: the Hermes harnesses and their scripts and spec.
* `app/App.tsx`: the probe app's screen.
* `ci/`: the workflow's steps.
* `patches/runtime-aarch64-cfg.patch`: the one-line runtime fix the AArch64
  mobile builds apply.

The host spike:

```sh
# React Native 0.88 with node_modules (any project or library):
npx create-react-native-library@0.63.1 --no-interactive --directory lib \
  --slug react-native-x --description x --author-name x --author-email x@x.invalid \
  --author-url https://x.invalid --repo-url https://x.invalid --type turbo-module \
  --languages cpp --example vanilla --tools jest --react-native-version 0.88.0
(cd lib && node .yarn/releases/yarn-*.cjs install)
# Hermes at React Native's pinned tag, and folly at its pinned version:
git clone --depth 1 --branch hermes-v260318099.0.4 https://github.com/facebook/hermes hermes
cmake -S hermes -B hermes-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DHERMES_ENABLE_TEST_SUITE=OFF
ninja -C hermes-build hermesvm          # needs libicu-dev
git clone --depth 1 --branch v2024.11.18.00 https://github.com/facebook/folly folly
apt-get install libgoogle-glog-dev libfmt-dev libdouble-conversion-dev libboost-dev
tclsh9.0 audit/react-native/tools/host-spike.tcl -work "/tmp/rn spike" \
  -react-native-project lib -hermes-src hermes -hermes-build hermes-build \
  -folly folly -stack-kib 512 ?-gc-stress 1?
```

The mobile probes: push a change under `audit/react-native/` (or dispatch
`react-native-probe.yml`, once the workflow is on the default branch).
* A head commit with the trailer `RN-Probe: android` skips the iOS job.
* Each job's log has:
  * the APK or app contents;
  * the object inspection;
  * the `BOTLISH_PROBE` lines the app logged.
* A failed simulator or emulator run also prints its diagnostics: the
  app's own log, crash reports, or the emulator's log.
