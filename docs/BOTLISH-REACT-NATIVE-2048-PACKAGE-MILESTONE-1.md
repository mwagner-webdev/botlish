# BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md

## A separately distributed React Native integration for Botlish native libraries, proven by a playable Android 2048 application

> A Botlish native library describes its public ABI in a machine-readable
> manifest. An independently distributed integration tool converts that ABI
> into a host-framework module. React Native owns presentation and
> application lifecycle; Botlish owns the application logic.

Evidence is marked:

* **observed**: run in this environment, with the output shown or committed
  under `audit/react-native-2048/results/`;
* **static**: read from source or artifacts;
* **CI**: a step of `.github/workflows/react-native-2048.yml`, with its run
  linked;
* **projected**: what a later milestone can build on.

The base is main at `a6977d56`. The host is Linux x86-64 (4 cores, Ubuntu
24.04, Tcl 9.0.1, rustc 1.97.0, Node 22.22, OpenJDK 21, Android NDK r29 for
the Botlish libraries and r27.1 for the app). It has no KVM and no Android
emulator.

## Contents

1. [Executive result](#1-executive-result)
2. [Starting census](#2-starting-census)
3. [Chosen React Native version](#3-chosen-react-native-version)
4. [External tool package](#4-external-tool-package)
5. [Generator architecture](#5-generator-architecture)
6. [Manifest mapping](#6-manifest-mapping)
7. [Generated npm package](#7-generated-npm-package)
8. [Codegen](#8-codegen)
9. [Android native integration](#9-android-native-integration)
10. [Native ABI ownership](#10-native-abi-ownership)
11. [Thread affinity and lifecycle](#11-thread-affinity-and-lifecycle)
12. [Error mapping](#12-error-mapping)
13. [2048 facade](#13-2048-facade)
14. [React hook](#14-react-hook)
15. [Playable app](#15-playable-app)
16. [Android execution](#16-android-execution)
17. [Independent second library](#17-independent-second-library)
18. [Cleanroom reproduction](#18-cleanroom-reproduction)
19. [GC and lifecycle testing](#19-gc-and-lifecycle-testing)
20. [Negative testing](#20-negative-testing)
21. [Mutation testing](#21-mutation-testing)
22. [Performance and footprint](#22-performance-and-footprint)
23. [Regression and CI](#23-regression-and-ci)
24. [Remaining platform gaps](#24-remaining-platform-gaps)
25. [Next milestones](#25-next-milestones)

## 1. Executive result

`botlish_react_native` is implemented and packed as a tool package of its
own. With the single-file compiler and three published packages, it turns
a Botlish native library into an installable React Native 0.88 New
Architecture npm package. It writes nothing for an input it cannot check;
the generated code accepts no value it cannot convey exactly. Observed, locally and
in a clean room:

* React Native's own Codegen generates the package's native interface;
* the generated C++ compiles and links into a React Native 0.88.1 Android
  release build;
* the APK carries the real arm64-v8a Botlish library, as the Android build
  strips it, with 16 KiB pages and zip alignment.

The 2048 rules run in Botlish, and the hook and the screen compute none of
them. The generated C++ core's ownership, thread affinity, lifecycle and
number and string rules hold on the host, also under GC stress, and the
game played through it is the interpreter's, snapshot for snapshot. A
second, unrelated library goes through the same generator into the same
app.

**Android execution is partially validated.** The app was not observed
running in an Android application process in this session:

* this host has no KVM, and Google's emulator refuses an arm64 guest on an
  x86_64 host, also when its `qemu-system-aarch64` is run directly
  (observed, section 16);
* the workflow that runs the APK on GitHub's Android emulators
  (`react-native-2048.yml`'s `android` jobs, two images) stayed queued
  behind a saturated runner pool for the whole session, and never started.

The Android acceptance is implemented and committed, with the oracle it
compares against (section 16). Its result is CI evidence still to come.
Until a run of it passes, what sections 15 and 16 say of the app on Android
is designed and built, not observed.

| | status |
|---|---|
| `botlish_react_native`, a schema 4 package with one protocol 1 tool (`react-native`), a static linux-x86_64 program | implemented, observed |
| installing it runs nothing; `botlish tool` runs it explicitly in its own process | observed (`rn-tool-installed-not-run`, the clean room's trace) |
| the generator reads the manifest, header and shared object only: no source, HIR, compiler internals or checkout file | static (`src/main.c`), observed (the clean room's strace) |
| every input checked before a byte is written: schema, C ABI version, target, runtime ABI, contracts, C types, ownership, SHA-256 of every artifact, the shared object's ELF | implemented, observed (`rn-refuse-*`: 27 refusal tests) |
| a React Native 0.88 New Architecture npm package: Codegen spec, checked TypeScript entry point, C++ core and TurboModule, CMake guards, pure C++ autolinking | implemented, observed |
| React Native's own Codegen generates the native interface (app-owned, `includesGeneratedCode: false`) | observed (Gradle's `generateReact_45_native_45_botlish_45_gameCodegen*` tasks) |
| the generated C++ compiles against React Native 0.88.1 and links into `libappmodules.so`; the APK carries the real arm64-v8a library | observed (local Gradle release builds; `inspect-apk.sh`) |
| ownership, thread affinity, lifecycle, number and string rules of the generated core | observed on the host (34 + 24 checks, GC stress) |
| the 2048 rules in Botlish (seeded spawns, scoring, the end, the win); the hook computes none | implemented, observed (401 snapshots equal to the interpreter's through the generated core on the host) |
| `useBotlish2048()` and a playable 2048 screen (swipes, buttons, score, New game, game over, win) | implemented; Jest observed (28 tests: 10 of the hook and the snapshot reader, 17 of the generated entry point, 1 without the native module) |
| a second, unrelated library through the same generator, both packages in one app | observed (host harness, TypeScript, Jest, the APK) |
| a clean room: the single-file compiler and packages only, then npm, Codegen and Gradle | observed (section 18) |
| the app on Android: Hermes, the TurboModule, the Botlish library in an Android application process | **partially validated**: the acceptance is implemented (section 16) but was not observed in this session (no KVM here; its CI runs stayed queued) |
| mutation testing | 44/44 killed, each by a detector it names; observed (section 21) |
| iOS, Android ABIs other than arm64-v8a, asynchronous workers | not supported (section 24) |

The compiler, the runtime and the standard library are unchanged (static:
the change adds `integrations/`, `examples/react-native/`,
`audit/react-native-2048/`, a test file and a workflow, and edits nothing
else besides AGENTS.md and docs/INDEX.md). No Botlish language semantics,
native-library ABI, Android target support or M4 threading was modified: no
correctness defect required it.

## 2. Starting census

**PM-7A** (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md;
BOTLISH-TOOLS.md) provided what the tool rides on:

* the schema 4 `tools` declaration;
* `botlish tool`'s resolution and process boundary, and the protocol 1
  request;
* the native library manifest, schema 2: each artifact's SHA-256, the
  runtime ABI, ownership as data, threading and reentrancy.

Its `hostgen:host-module` prototype (`audit/external-tools/src/hostgen.c`)
and the `toolkit.h` it shares were **reused**: the strict JSON reader is
`integrations/react-native/src/json.h`, verbatim plus one accessor. The
prototype's request and manifest reading were extended: the target and
target support, every SHA-256, the ELF, the threading and reentrancy
contracts, every C type and ownership, each export's declared errors.
**Replaced**: the prototype's "JavaScript-like host" values (`hv_value`) and
its single-file adapter. The real generator writes Codegen's TypeScript
spec and two C++ layers over JSI (section 5).

**The React Native census** (REACT-NATIVE-TARGET-CENSUS.md) solved the
React Native side. Its findings are reused:

* the Pure C++ TurboModule over a C ABI;
* the `cxxModule*` keys that make a package a pure C++ dependency of
  Android autolinking (no Gradle module, no Java or Kotlin);
* the safe-integer rule;
* the JS errors built in C++ with `jsi::JSError`;
* the emulator boot recipe (`audit/react-native/ci/android-emulator.sh`:
  the current command-line tools, `ANDROID_AVD_HOME`).

The census's `rnpackage.tcl` generator is history, not reused:

* it was Tcl, run from the checkout;
* it shipped Codegen output, and a stub for 32-bit ABIs;
* its adapter destroyed the instance in the module's destructor on
  whatever thread that ran.

Its probes ran an x86_64 library on an x86_64 emulator. No arm64 code ran on
Android there.

**The Android target** (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md)
provided the rest:

* `-target android-aarch64 -target-support botlish_target_android_aarch64
  -emit-native-library`;
* a 16 KiB-aligned `lib<name>.so`: SONAME set, Bionic's libraries only,
  localized runtime, exactly the C ABI exported;
* a manifest with `targetSupport` (runtime ABI, `minimumApi` 21, the NDK
  revision).

It was partially validated: Android's linker and Bionic under qemu-user, no
application process, no ART, no JNI. Closing that gap is this milestone's
Android acceptance (section 16).

What the earlier QEMU-user runs did not exercise, and the Android run must:

* zygote and ART;
* the app's own `libappmodules.so`, linked against the Botlish library and
  loaded by Android's package manager from the APK;
* Hermes and JSI;
* React Native's JavaScript thread and its lifetime across reloads;
* SELinux;
* the property service (the generator's trace switch);
* `Os.setenv` from Kotlin (GC stress in the app process).

**Which thread runs a synchronous TurboModule method:** React Native's
JavaScript thread. Bridgeless Android names it `mqt_v_js`
(`ReactInstance.kt:124`, `MessageQueueThreadImpl.kt:153`).

**Who owns the module:** `ReactInstance.destroy()` quits the JavaScript
thread first (`reactQueueConfiguration.destroy()`), then invalidates the
TurboModule manager (`ReactInstance.kt:419-427`). So a reload ends the
instance's owner thread before the module is destroyed, typically on
another thread. Section 11 is designed for exactly that.

## 3. Chosen React Native version

**React Native 0.88.1**, npm's `latest` on 2026-11-08 (static: the
registry's dist-tags). The app fixture is `@react-native-community/cli@20.2.0
init --version 0.88.1`, its `package-lock.json` committed. The pinned
versions:

| component | version |
|---|---|
| react-native, @react-native/codegen, @react-native/gradle-plugin, template | 0.88.1 |
| react | 19.3.0 |
| Hermes | `com.facebook.hermes:hermes-android` 260318099.0.5 (React Native 0.88.1's `HERMES_VERSION_NAME`) |
| react-android | 0.88.1 |
| @react-native-community/cli | 20.2.0 |
| Node | 22 (22.22 here) |
| Gradle | 9.4.1 (the template's wrapper) |
| Android Gradle Plugin | 9.2.1 (the React Native Gradle plugin's version catalog) |
| Kotlin | 2.2.0 |
| compileSdk, targetSdk, minSdk, build tools | 37, 36, 24, 37.0.0 |
| NDK | 27.1.12297006 for the app (the template's); r29 (29.0.14206865) for the Botlish libraries (target support requires 28.0+) |
| CMake | 3.22.1 |
| Java | 17 in CI (Zulu), 21 here |

The generator's table of React Native versions (`reactNatives` in
`src/main.c`) holds `0.88` only. The generated `peerDependencies` is
`"react-native": ">=0.88.0 <0.89.0"`, and `-react-native 0.89` or `0.87` is
refused (RN-REACT-NATIVE). The reason is that Codegen's C++ interface,
`Bridging<>`, and the pure C++ autolinking with app-owned Codegen are
checked per minor version: the last of these first appears in this
version's Gradle plugin (`ReactPlugin.kt:422-482`,
`GenerateAutolinkingNewArchitecturesFileTask.kt:105-122`).

## 4. External tool package

`integrations/react-native/` is the source of the package
`botlish_react_native` 0.1.0. Its descriptor (`package/botlish.json`,
schema 4):

    "tools": {"react-native": {"protocol": 1,
      "programs": {"linux-x86_64": "tools/linux-x86_64/react-native"},
      "inputs": ["native-library"]}}

`package.sh OUT BOTLISH...` is the author's side. It compiles `src/embed.c`,
which embeds the templates into `templates.h`, then the tool:
`-std=c99 -O2 -Wall -Wextra -Werror -static`, stripped, 841,736 bytes, no
shared library of the host needed. It stages the descriptor, the README,
the program and the tool's own sources (`source/`, for whoever audits what
they run), and packs it with `botlish package pack`. The result is
`botlish_react_native-0.1.0.botpkg`, 409,014 bytes holding 17 files
(observed).

A developer installs it like any package: `botlish add botlish_react_native
-repository REPO`, a direct dependency, resolved and locked by PM's one
graph. Nothing runs at installation (observed, `rn-tool-installed-not-run`):

* `tools` lists it;
* the installed program is not executable;
* nothing appears beside the project's files.

The invocation follows PM-7A's conventions (the tool command's options
before the tool's name):

    botlish tool -out generated/react-native-botlish-game \
        -artifact lib/game.manifest.json -target android-aarch64 \
        react-native generate [-name NPM] [-module MODULE] [-version V] \
        [-react-native 0.88] [-android-api N] [-license SPDX] [-replace]

`-target android-aarch64` is needed: `botlish tool` checks the artifact
against the target the request states, the host's by default. No Node,
React Native or Tcl is needed to generate: npm and React Native's Codegen
run later, in the app's build.

## 5. Generator architecture

**Generic.** The tool is generic: it holds nothing of any one library.
Every name comes from the manifest or the options:

* the module, `Botlish` and the library name in PascalCase, or `-module`;
* the spec, `<Module>Spec`;
* the C++ class, `<Module>Module` in `facebook::react`, the name autolinking
  constructs;
* the core namespace, `botlish_rn_<module>`;
* the CMake targets, `botlish_rn_<module>` and `botlish_library_<lib>`;
* the Java package `org.botlish.rn.<module>`, which Codegen requires;
* each method, the camelCase of the export's name.

A name that collides or is reserved is refused (section 20). The templates
are text with `@KEY@` holes (`templates/*.in`); the per-export pieces are
written by `main.c` from the manifest's types.

**2048-specific.** The 2048 code lives in `examples/react-native/`:

* the facade, `2048/game.bot`;
* the app's hook, `app/src/useBotlish2048.ts`;
* the screen;
* the self-test.

`rn-two-libraries-apart` checks that the second library's package holds
neither "game" nor "2048" anywhere.

**Two C++ layers.**

* `cpp/<Module>Core.{h,cpp}` knows no JavaScript engine. Its arguments are
  what JavaScript can pass (a double for a number, a `std::string`), and a
  failure is data (`Failure`). Everything the C ABI requires is here:
  ownership, thread, lifecycle, the number and string rules. It is compiled
  unchanged on the host against the host build of the same library: the
  two headers are byte-identical (`cmp`, observed), which is what the host
  harnesses test.
* `cpp/<Module>Module.{h,cpp}` derives from Codegen's
  `Native<Module>CxxSpec<T>`. Each method calls the core and turns a
  `Failure` into a thrown JavaScript error. It holds no policy.

## 6. Manifest mapping

| Botlish | C ABI (manifest) | core C++ | TurboModule C++ | Codegen spec | JavaScript |
|---|---|---|---|---|---|
| `int` | `int64_t` / `int64_t *` | `double` in, checked: finite, integral, at most 2^53 - 1 in magnitude; out: `double` if safe | `double` | `number` | a safe integer; otherwise `RangeError` BOTLISH_ARGUMENT_RANGE in, BOTLISH_UNSAFE_RESULT out |
| `float64` | `double` / `double *` | `double`, finite (-0 enters as 0, the C ABI's rule) | `double` | `number` | a finite number; otherwise `RangeError` |
| `bool` | `bool` / `bool *` | `bool` | `bool` | `boolean` | `boolean` |
| `str` | `const uint8_t *, size_t` / `LIB_bytes *` (owned) | `std::string` (length, not NUL) | `jsi::String` (UTF-8 by length) | `string` | `string`; a lone surrogate arrives as U+FFFD (Hermes' UTF-8 conversion) |
| `unit` result | none | `void` | `void` | `void` | `undefined` |
| declared error | status 1, `LIB_error **` (owned) | `Failure` (category declared, identity, typed fields) | `Error` named BotlishError | (Codegen has no error types) | `BotlishError` |

Anything else is refused (RN-UNSUPPORTED), never mapped to `any` or
guessed: another boundary type, another C type for a known one, another
ownership, a C ABI version other than 1, callbacks, native dependencies. A
payload field the C ABI marks `other` (NonFiniteFloat's `result`) arrives
as `null`, and an int field outside the safe range as its decimal text.

## 7. Generated npm package

The 2048 package (observed: 14 files, 1,151,883 bytes unpacked; the
tarball 452,355 bytes):

    package.json  react-native.config.js  README.md  botlish-react-native.json
    src/NativeBotlishGame.ts  src/index.ts
    cpp/BotlishGameCore.{h,cpp}  cpp/BotlishGameModule.{h,cpp}
    android/CMakeLists.txt
    include/game.h  botlish/game.manifest.json
    native/android/arm64-v8a/libgame.so

* `package.json`:
  - name and version;
  - `main`, `types` and `react-native`, all `src/index.ts` (Metro and
    TypeScript consume the source);
  - `files`;
  - `peerDependencies.react-native` `>=0.88.0 <0.89.0`;
  - `codegenConfig`: `{name: BotlishGameSpec, type: modules, jsSrcsDir:
    src, android.javaPackageName, includesGeneratedCode: false}`;
  - `botlish.platforms`: `{android: {abis: [arm64-v8a], minimumApi: 24},
    ios: null}`.
* `botlish-react-native.json`, the record:
  - the generator's name, version and protocol;
  - the package's names: module, spec, C++ class, CMake target;
  - the library: name, manifest schema, C ABI, target and triple, the front
    end's fingerprint, the runtime ABI, the target support package, the
    toolchain, the SHA-256 of the manifest, shared object, header and
    static archive, the exports;
  - React Native's range and tested version, the New Architecture, Hermes,
    the Pure C++ TurboModule and app-owned Codegen;
  - Android's ABIs and API levels (library 21, React Native 24, package 24)
    and its 16 KiB page size;
  - `ios: null`;
  - the files written.
* The library, its header and its manifest are copied byte for byte
  (`rn-generate-artifacts-unchanged`).

The output is deterministic. Two generations into directories of different
paths are byte-identical (`rn-generate-deterministic`), and no generated
file names a host path (`rn-generate-no-host-path`): CMake reaches the
library through `${CMAKE_CURRENT_LIST_DIR}`.

The app installs it from its tarball (`npm install
./react-native-botlish-game-0.1.0.tgz`; observed in `build.sh` and the clean
room). Nothing under `node_modules` is edited.

## 8. Codegen

The app's Codegen generates the native interface; the package ships none.
React Native 0.88's Gradle plugin handles a pure C++ dependency whose
`codegenConfig.includesGeneratedCode` is not true (`ReactPlugin.kt:468-482`):

* it registers `generate<Dep>CodegenSchemaFromJavaScript` and
  `generate<Dep>CodegenArtifactsFromSchema` per dependency;
* it writes their output to
  `app/build/generated/source/codegen/pureCxx/<libraryName>/`;
* autolinking's CMake adds that `jni/CMakeLists.txt` (target
  `react_codegen_<Spec>`) before the package's own, whose target links it
  (`GenerateAutolinkingNewArchitecturesFileTask.kt:105-122`).

Observed in the app's release build:

    > Task :app:generateReact_45_native_45_botlish_45_gameCodegenSchemaFromJavaScript
    > Task :app:generateReact_45_native_45_botlish_45_gameCodegenArtifactsFromSchema
    > Task :app:generateReact_45_native_45_botlish_45_textkitCodegenSchemaFromJavaScript
    > Task :app:generateReact_45_native_45_botlish_45_textkitCodegenArtifactsFromSchema

`pureCxx/BotlishGameSpec/jni` then holds `BotlishGameSpec.h`,
`BotlishGameSpec-generated.cpp`, `CMakeLists.txt` and `react/`, with
`NativeBotlishGameCxxSpec<T>` in `BotlishGameSpecJSI.h`. The generated
`BotlishGameModule.cpp` compiled against it and React Native 0.88.1's JSI
and bridging headers, with NDK 27.1's clang (observed: `BUILD SUCCESSFUL`,
section 9).

`npx react-native config` reports the package as `isPureCxxDependency:
true` with `cxxModuleCMakeListsModuleName: botlish_rn_botlishgame`,
`cxxModuleHeaderName: BotlishGameModule` and `libraryName:
BotlishGameSpec` (observed). Registration needs no app change:

* `autolinking.cpp` includes `<BotlishGameModule.h>`;
* it returns `std::make_shared<BotlishGameModule>(jsInvoker)` when the
  module name is `BotlishGameModule::kModuleName`, which the Codegen base
  class defines;
* the template's default `OnLoad.cpp` falls back to the autolinked
  provider.

## 9. Android native integration

`android/CMakeLists.txt` (generated) does four things in order:

1. It refuses any `ANDROID_ABI` but `arm64-v8a`, with a message naming
   `reactNativeArchitectures=arm64-v8a`.
2. It refuses an `ANDROID_PLATFORM_LEVEL` below the package's API level.
3. It checks `native/android/arm64-v8a/libgame.so` against the SHA-256
   recorded at generation (`file(SHA256 ...)`), and refuses a missing or
   different file.
4. It imports the library as a `SHARED IMPORTED` target, builds the adapter
   as a static library linking `jsi reactnative react_codegen_<Spec>`, the
   imported library and `log`, and joins `libappmodules.so`.

The Android Gradle Plugin packages an imported shared library a CMake
target links: there is no Gradle module, no `jniLibs` and no Java (observed:
`lib/arm64-v8a/libgame.so` in the APK, and `libappmodules.so` NEEDs
`libgame.so`).

The app's only build change is `reactNativeArchitectures=arm64-v8a` in
`android/gradle.properties`. Its other changes are its own: the screen, and
`MainActivity`'s test extras (section 15).

What the APK holds, from its bytes (`tools/inspect-apk.sh`, observed on the
local build and in CI):

* ABIs: `arm64-v8a` only.
* `libgame.so`:
  - 756,136 bytes in the APK against 1,093,032 in the package;
  - the APK's copy is byte for byte `llvm-strip --strip-unneeded` of the
    package's (the Android build's `stripReleaseDebugSymbols`), SHA-256
    `7d39ae04...`;
  - the package's copy is the manifest's, `b0f61943...`;
  - `.text`, `.rodata` and the dynamic symbols are identical to the
    package's.
* Every shared object's `LOAD` segments are aligned to `0x4000`, and
  `zipalign -c -P 16 4` reports "Verification successful".
* `libappmodules.so` defines no Botlish runtime symbol: the adapter calls
  the library's C ABI; there is no second runtime in it.
* Each Botlish library carries its own private runtime, by design of native
  libraries (NATIVE-LIBRARY-MILESTONE-1.md). Two libraries in one app are
  two runtimes in two `.so` files, never one runtime twice in one file.

Library loading is the Android loader's, through `libappmodules.so`'s
`NEEDED`. React Native loads `libappmodules.so` (`SoLoader`) when the
instance starts. There is no `System.loadLibrary` of Botlish's.

## 10. Native ABI ownership

The core follows the manifest's ownership as data:

* the instance (`create`/`destroy`, the caller's);
* `str-argument`, borrowed for the call: the core passes
  `std::string::data()` and `size()`, never a NUL-terminated length;
* `str-result`, the caller's, released with `LIB_bytes_release`;
* errors, the caller's, released with `LIB_error_release`.

Both owned kinds are RAII objects (`OwnedBytes`, `OwnedError`), released on
every path: success, a declared error, a JavaScript exception while
building the result, `std::bad_alloc`. Everything is copied out of the C
ABI's buffers before they are released. JavaScript never sees a pointer
into a Botlish VM: strings are copied into `jsi::String` by length.

Counters make releases observable (`diagnostics()` in TypeScript,
`botlishDiagnostics` on the module): results acquired and released, errors
acquired and released, calls, nanoseconds inside the C ABI, instances
created, destroyed, orphaned and reaped. Observed:

* on the host, `resultsAcquired == resultsReleased` and `errorsAcquired ==
  errorsReleased` after every scenario (game: 8 errors in the checks;
  stress: 4,020 results and 80 errors, under `BOTLISH_NATIVE_GC_STRESS=1`
  too);
* on Android, the self-test checks the same equalities (implemented, not
  observed in this session: section 16).

## 11. Thread affinity and lifecycle

Native-library instances are thread-affine and refuse reentrancy. The core
enforces both itself, before the C ABI is entered:

* **Creation.** The instance is created at the module's first call, on the
  calling thread, which owns it from then on (`Slot::owner`).
* **Wrong thread.** A call from another thread is refused:
  `BotlishError`, category invocation, `WRONG-THREAD`, naming both thread
  ids. The library's own refusal stays as a second line.
* **Reentrancy.** A call during a call is refused: invocation
  `REENTRANT-CALL`. It is unreachable from JavaScript today (no callbacks),
  but kept.
* **Destruction, on the owner thread only:**
  - the module destroyed on its owner thread destroys the instance at once;
  - the module destroyed on another thread **orphans** the instance:
    nothing is destroyed there. The owner thread destroys it at its next
    call into the library (`Reaper::sweep`, *reaped on call*) or at its
    exit (a `thread_local` `Reaper`'s destructor, *reaped at exit*);
  - a thread that ends before its module destroys the instance on that
    thread. The module's later calls are refused (`INSTANCE-GONE`), and its
    destruction later, anywhere, destroys nothing twice.
* **Invalidation.** `invalidate()` makes every later call fail
  (`INVALIDATED`).
* **Never** is an instance made `Send`, locked for another thread, or
  destroyed by one.

The `thread_local` Reaper is registered *after* the thread's first
successful `LIB_create`. At thread exit it is therefore destroyed before
the Botlish runtime's own thread-local state, which `LIB_create`
registered first. The runtime's coroutine stack pool returns stacks with
`try_with` too (`runtime/coroutine.rs:337`).

**Observed on the host** (`harness/game_core.cpp`, 34 checks), each case
with its counters:

* `wrong-thread-refused`;
* `destroyed-on-owner-thread`;
* `foreign-destruction-orphans` (orphaned +1, destroyed +0);
* `orphan-reaped-on-owner-call` (reaped +1, destroyed +1);
* `reaped-at-thread-exit`;
* `dead-owner-refused` (`INSTANCE-GONE`);
* `no-double-destroy` (no destroy failure);
* `invalidated-refused`;
* `one-instance-per-module`.

**On Android**, React Native's lifecycle is the case above:
`ReactInstance.destroy()` quits the JavaScript thread before the TurboModule
manager. Lifecycle events go to logcat (tag `BotlishRN`), and
`setprop debug.botlish.rn.trace 1` adds every call's thread. The
acceptance compares the instance's thread with `mqt_v_js` and checks that a
reload destroys the old instance on its own thread (section 16).

## 12. Error mapping

| what | JavaScript |
|---|---|
| a declared Botlish error (status 1) | `BotlishError`, `category: 'declared'`, `identity` the canonical name (`InvalidSnapshot`, `game2048::CellOccupied`), `fields` its payload, `code: 'BOTLISH_DECLARED'` |
| a runtime error (status 2) | `BotlishError` `runtime`, `identity` the runtime's code |
| a boundary error (status 3: a string not UTF-8, an Int result outside int64) | `BotlishError` `boundary` |
| an invocation error (status 4, or the core's own: WRONG-THREAD, REENTRANT-CALL, INVALIDATED, INSTANCE-GONE) | `BotlishError` `invocation` |
| an internal error (status 5) | `BotlishError` `internal` |
| the native module absent (iOS, another ABI, the old architecture, Jest) | `BotlishError` `unavailable`, `MODULE-UNAVAILABLE`; nothing falls back to JavaScript |
| a missing or extra argument, a wrong JavaScript type | `TypeError`, `code` BOTLISH_ARGUMENT_COUNT / BOTLISH_ARGUMENT_TYPE, before the native module is called |
| an int that is no safe integer, a float64 that is not finite | `RangeError` BOTLISH_ARGUMENT_RANGE (in TypeScript first, and again in the core for a direct native call) |
| an int result beyond 2^53 - 1 | `RangeError` BOTLISH_UNSAFE_RESULT |

Every `BotlishError` also has `method`, `library` and a message prefixed
with the method. `declaredErrors` lists each function's declared errors,
and `isBotlishError(e, identity)` tests one. The C++ throws an `Error`
named `BotlishError` with those properties (`jsi::JSError` keeps the
value). The TypeScript entry point rethrows it as its own `BotlishError`
class, so that `instanceof` works per package. Errors of the second
library's package are not the first's (`textkit-not-game-error`).

## 13. 2048 facade

`examples/react-native/2048/game.bot` is the native library `game`. It is
an ordinary Botlish entry file of declarations over the unchanged engine
(the package `game2048`, `examples/games/2048/game2048.bot`). It adds the
rules a played game has and the engine leaves to its caller:

* a 32-bit LCG spawn generator (Numerical Recipes' constants) whose state
  travels in the snapshot;
* two tiles at the start;
* after every move that changes the board, a tile on an empty cell drawn
  from the generator's high bits, a 4 one time in ten;
* the end (`game2048::game_over?`) and the win (a tile of 2048 or more).

A game crosses the boundary as a versioned snapshot, 23 fields:

    2048/1 RNG SCORE MOVES CHANGED OVER WON C0 C1 ... C15

The exports:

* `new_game(seed: int) -> str`;
* `move(state: str, direction_code: int) -> str errors InvalidDirection,
  InvalidSnapshot`;
* `score(state: str) -> int errors InvalidSnapshot`;
* `place(state: str, row: int, column: int, tile: int) -> str errors
  InvalidPlacement, InvalidSnapshot, game2048::CellOccupied`.

A snapshot the library did not make is checked, never trusted: its OVER
and WON fields must be the facts of its board (`snapshot-facts-checked`).
The file is warning-clean under `-warnings error`. Its constants are
functions because an export is environment-free (EXPORT-ENVIRONMENT).

Identical seeds and moves give identical snapshots everywhere they ran.
Observed:

* the interpreter, the compile backend and the native backend
  (`tools/oracle.tcl 42 DIRECTIONS BACKEND`): the self-test's 400 moves of
  seed 42, 401 identical snapshots;
* the host library through the generated core: 401 snapshots of seed 42
  and the self-test's 400 moves, byte-identical to the interpreter's;
* `rn-core-oracle`: 80 moves of seed 7.

The Android module and hook are in section 16. The 400 moves reach game
over: move 251 is the last that changes the board, score 3,064.

## 14. React hook

`useBotlish2048({seed, start?, onSnapshot?})`
(`examples/react-native/app/src/useBotlish2048.ts`) returns:

* `board` (16 cells), `score`, `moves`, `gameOver`, `won`, `changed`,
  `seed`, `snapshot` and `error`;
* `move(direction)` and `restart(seed?)`.

It holds the library's latest snapshot and computes nothing of the rules
(`src/snapshot.ts` only reads the text). Its React contract, each part
tested in Jest with the module replaced by a recorder
(`__tests__/useBotlish2048.test.tsx`: 9 tests, and one of the snapshot reader), the recorder throwing if
called while a test component renders:

* No native call while rendering. The first game is made in an effect;
  every move and restart in the event that asks for it.
* The latest snapshot is also in a ref. Moves made before React renders
  again each continue from the one before, exactly once: `move 0 from 0`,
  `move 2 from 1`, `move 3 from 2`.
* Strict Mode, whose effects run twice, makes one game and repeats no move.
* Rerendering calls nothing native and keeps the game.
* Unmounting calls nothing native. Two consumers play their own games,
  and unmounting one leaves the other working: the module and its instance
  belong to React Native, not to a component.
* A failure is shown (`error`) and changes no state.

## 15. Playable app

`examples/react-native/app/` is the React Native 0.88.1 template with:

* `App.tsx`: the board (4×4, tiles colored by value), the score, New game,
  four arrow buttons (accessibility and tests), a status line, the
  game-over overlay and the win message;
* the hook;
* the self-test screen;
* `MainActivity` extras: `mode` and `start` as launch options, `gcStress`
  setting `BOTLISH_NATIVE_GC_STRESS=1` with `Os.setenv` before any
  instance, and `reload` calling `ReactHost.reload`.

A swipe on the board (`PanResponder`, 24 points at least, the larger axis)
or an arrow reads one direction. The hook asks the library, React renders
the new snapshot. Every input, snapshot and input-to-render latency is
logged as `BOTLISH_RN ...` lines.

What was observed of the app without an Android device:

* TypeScript (`tsc --noEmit`) over the app and both generated entry points;
* Jest: 28 tests (section 14; `results/jest.txt`);
* Gradle release builds of the app with both packages, locally and in the
  clean room (section 18). Codegen ran for both specs; the adapters were
  compiled against React Native 0.88.1 with the NDK the app pins (r27.1)
  and linked into `libappmodules.so`.
* The APK (`tools/inspect-apk.sh`; `results/apk-report.txt`):
  - it holds arm64-v8a libraries only;
  - `libgame.so` and `libtextkit.so` are the generated packages' libraries
    as the Android build strips them: `llvm-strip --strip-unneeded` of the
    package's file gives the packaged file byte for byte, and `.text`,
    `.rodata` and the dynamic symbols are the package's;
  - `libappmodules.so` NEEDs both and defines no Botlish runtime symbol;
  - every shared object's segments are 16 KiB-aligned, and
    `zipalign -c -P 16` passes;
  - the JavaScript bundle is Hermes bytecode (its magic, `c6 1f bc 03`)
    holding both entry points (`BotlishGame`, `BotlishTextkit`), the hook
    and the self-test.

The screen itself (the board drawn, swipes on it, the overlay) is Android
evidence: section 16.

## 16. Android execution

**Status: partially validated.** The acceptance below is implemented and
committed. It was not observed in this session.

`audit/react-native-2048/tools/android-acceptance.sh APK EXPECTED OUT` runs
on whatever emulator or device `adb` sees. EXPECTED is `build.sh`'s output:
the interpreter's oracles. It installs the release APK and passes or fails
six phases:

1. **selftest.** The JavaScript self-test (`src/SelfTest.tsx`) reports
   `failures=0`. Its 401 module snapshots and 401 hook states must equal the
   interpreter's (`oracle-42.txt`). The JavaScript engine must be Hermes.
   Each Botlish instance must be created on React Native's JavaScript
   thread (`mqt_v_js`, from `ps -T`, compared with the adapter's log line),
   and every call must come from that thread (the module's own
   `diagnostics()`). `libgame.so` and `libtextkit.so` must be mapped in the
   app process (`/proc/PID/maps`, the paths recorded).
   The self-test also checks, inside the app process:
   - every error category and code;
   - the win and the end;
   - the number and string rules (unsafe integers, NaN, embedded NULs, a
     mebibyte);
   - the second library;
   - the first-call and per-call times (section 22).
2. **reload.** React Native is reloaded three times (`ReactHost.reload`,
   the launch extra `reload`). Each time the runtime and its TurboModules
   are made again, a new Botlish instance is created, and the old one is
   destroyed on its own thread: at its thread's exit or its next call,
   never by a foreign thread (the `BotlishRN` log's `destroyed on thread T
   (...)`). The self-test must pass each time.
3. **gc-stress.** The self-test under `BOTLISH_NATIVE_GC_STRESS=1`, set by
   `Os.setenv` before any instance exists. It must give the same snapshots.
4. **play.** The game is played by swipes on the screen (`input swipe`),
   including a rapid burst, with the app sent to the background and
   back, then New game. Each swipe must be applied exactly once, each
   snapshot must be the interpreter's (`play-oracle.txt`,
   `restart-oracle.txt`), and no second instance may appear. Every call's
   thread is traced in this phase only (`debug.botlish.rn.trace`).
5. **win, over.** The game is started one move from 2048, then one move
   from the end. The screen's view hierarchy must show the win, then the
   game-over overlay, with screenshots kept.
6. **exit.** The back key finishes the activity, then the process stops.
   No native crash may appear anywhere in the run (`DEBUG`,
   `AndroidRuntime`, `libc` fatal lines).

`tools/dev-reload.sh DEBUG-APK APP OUT` is React Native's development
reload. The debug build gets its bundle from Metro on the runner (`adb
reverse tcp:8081`) and is reloaded twice with the R key twice (React
Native's `DoubleTapReloadRecognizer`). Each reload must make a new instance
of both libraries and destroy the old ones on their own threads, and the
self-test must pass again.

**Where it runs.** The workflow's `android` jobs run it on GitHub's Linux
runners, with KVM, on two emulator images:

| job | images (`emulator.sh` boots the first that runs arm64-v8a code) | also |
|---|---|---|
| 4 KiB pages | API 34, 33, 30 `google_apis` x86_64 | the clean room's APK; the development reload with Metro |
| 16 KiB pages | API 35, 36 `google_apis_ps16k` x86_64 | |

Both images are x86_64. The arm64-v8a APK runs through Android's ARM
native bridge, and `emulator.sh` requires the image to list arm64-v8a in
`ro.product.cpu.abilist` (`ro.dalvik.vm.native.bridge`). So a passing run
shows the app's arm64 code, Hermes, React Native, the adapters and Botlish,
executing *translated* in a real Android application process: zygote, ART,
the package manager's library loading, SELinux, the JavaScript thread and
its reloads. It does not show native AArch64 execution (section 24).

**What happened in this session.** Every push of the branch started the
workflow, and each run stayed `queued`: the repository's runners were busy
with other branches' runs that had been going for hours. Each newer push
cancelled the queued run, as the workflow's concurrency group intends. The
latest run is linked in section 23; its result is the Android evidence.

**Locally**, this host has no `/dev/kvm`. Observed, with the emulator 37.2.13
and `system-images;android-30;aosp_atd;arm64-v8a`:

* `emulator -avd ... -accel off`: `FATAL | Avd's CPU Architecture 'arm64'
  is not supported by the QEMU2 emulator on x86_64 host. System image must
  match the host architecture.`
* Its own `qemu-system-aarch64-headless`, run directly to skip the
  launcher's check, starts. But the `ranchu` machine it builds has no PCI
  bus on this host (`PCI bus not available for hda`, also with the AVD's
  audio off), and the input devices it adds are PCI devices
  (`virtio_input_multi_touch_pci_*`).

So no Android userland ran here. QEMU-user runs of the library (the Android
target milestone's) were not repeated: the milestone does not count them as
Android execution.

## 17. Independent second library

`examples/react-native/textkit/textkit.bot` is a library unrelated to
2048. Its exports cover every boundary type the generator maps:

* `scalar_count`, an Int;
* `reversed` and `repeated`, strings;
* `palindrome`, a Bool;
* `mean` and `alnum_share`, Float64s;
* `require_text`, unit;
* `EmptyText`, a declared error with no payload;
* `TooLong {limit, length}`, a typed payload;
* NonFiniteFloat, whose payload field the C ABI cannot convey.

The same generator, with no option, made `react-native-botlish-textkit`:
module `BotlishTextkit`, 7 methods. Observed:

* its core passes 24 host checks:
  - Unicode by scalar values (`a😀b` is 3; reversal keeps astral
    characters);
  - embedded NULs, the empty string, a mebibyte;
  - the payload's typed fields (`limit` 4, `length` 6);
  - NonFiniteFloat's `other` field;
  - unit;
  - the ownership counters;
* both cores live in one process, apart: their namespaces, libraries,
  instances and counters (`coexist-*`);
* the two packages share no name: module, spec, C++ class and namespace,
  CMake targets, C prefix (`rn-two-libraries-apart`);
* the second package holds nothing of 2048;
* both install into one app, type-check and link into one
  `libappmodules.so`, which NEEDs `libgame.so` and `libtextkit.so`;
* the self-test calls both (Android: section 16).

## 18. Cleanroom reproduction

`audit/react-native-2048/cleanroom/cleanroom.sh BOTLISH REPO RESULTS`. Its
inputs:

* the single-file compiler (`single/build.sh`: 15,474,259 bytes);
* the published packages: `botlish_target_android_aarch64`, `game2048`,
  `botlish_react_native`;
* the application's own sources: `game.bot`, `textkit.bot`, and the app
  fixture without `node_modules`.

Observed locally (`audit/react-native-2048/results/cleanroom/`:
`summary.txt`, `programs.txt`). The inputs, by SHA-256:

| input | SHA-256 |
|---|---|
| the single-file compiler | `dce53168...e061` |
| `botlish_react_native-0.1.0.botpkg` | `5ee66dc0...a37e` |
| `botlish_target_android_aarch64-0.1.0.botpkg` | `89b32e84...f009` |
| `game2048-0.1.0.botpkg` | `9c014780...53a5` |

1. **Botlish, traced.** The steps ran with an empty environment (`env -i`:
   HOME and TMPDIR in the room, the system's PATH, ANDROID_NDK_ROOT),
   under `strace -f`:
   - the packages installed as ordinary dependencies;
   - the library built for android-aarch64;
   - its manifest checked against its files;
   - `botlish tools`, then `botlish tool ... react-native generate`.

   They opened no file of this checkout and started no Tcl of the system.
   The programs they started:
   - the single executable (6 times) and its native driver, unpacked into
     the room's cache (2);
   - the NDK's `clang`, `ld.lld`, `llvm-ar` and `llvm-objcopy`;
   - the tool's program, from a private directory (1) after `/bin/sh`'s
     trampoline;
   - `sha256sum` (26), `sed`, `cut` and `tr`.
2. **npm and React Native**, with the room's npm and Gradle caches:
   - `npm pack` of the generated package;
   - `npm ci` of the app's locked dependencies;
   - `npm install` of the tarball;
   - the second library's package, generated and installed the same way;
   - TypeScript, and Jest (28 passed);
   - the Android release build: BUILD SUCCESSFUL in 5 min 6 s. Codegen ran
     from the app, for both packages
     (`generateReact_45_native_45_botlish_45_{game,textkit}Codegen*`); the
     app's own Codegen tasks were skipped, as it has no spec of its own.

   Neither the app nor the packages name this checkout.
3. **The APK** (20,601,745 bytes) holds arm64-v8a libraries only.
   `libgame.so` is the generated package's library as the Android build
   strips it. Every segment is 16 KiB-aligned, and `zipalign -c -P 16`
   passes.

The external dependencies (React Native, Hermes, Gradle's plugins) come
from npm's registry, Google's Maven and Maven Central: they are the app's,
not Botlish's. This host reaches them through a proxy. Its variables pass
into the room, and the run was given a Gradle properties file and a Maven
Central mirror (`GRADLE_PROPERTIES`, `GRADLE_INIT_DIR`), which are
environment, not inputs. The workflow's build job runs the same clean room
after `single/build.sh`, without them, and its 4 KiB android job runs the
acceptance on the clean room's APK (section 16; pending).

## 19. GC and lifecycle testing

* **Host, observed.** `game_core stress 20` plays twenty games of 200
  moves, with failing calls among them (4,100 calls). Under
  `BOTLISH_NATIVE_GC_STRESS=1` it gives the same 20 final states as
  without, and every owned result and error is released (4,020 and 80).
  Without GC stress the time in the C ABI is 30.7 µs per call; with it,
  189.0 µs (section 22).
* **Lifecycle, observed on the host:**
  - instance creation, at most one per module;
  - destruction on the owner thread;
  - a foreign thread's destruction orphaning, then reaped at the owner's
    next call or at its exit;
  - a thread ending before its module;
  - invalidation, double invalidation;
  - many instances on one thread;
  - repeated failures and releases.
* **Android** (implemented, not observed in this session: section 16):
  GC stress in the app process, three reloads and module reconstruction,
  the development reload with Metro, background and foreground.

## 20. Negative testing

`tests/react-native-package.test` holds 27 refusal tests. Each checks the
exit status and the code, and that nothing was written. They run through
`botlish tool`, or through a hand-made protocol 1 request, so that each of
the tool's own checks is reached:

* **`botlish tool`'s own refusals:** an unknown tool (TOOL-UNKNOWN), no
  artifact (TOOL-INPUT), a Linux library for android-aarch64
  (TOOL-ARTIFACT), output in `.bot_modules` (TOOL-OUTPUT).
* **The request:** another protocol (RN-REQUEST, status 2), a target that
  is not the library's (RN-TARGET), a Linux library for its own target
  (RN-TARGET), an unknown command (RN-USAGE, status 2).
* **The manifest:** schema 1 (RN-MANIFEST); C ABI version 2
  (RN-UNSUPPORTED); a parameter of an unknown type, a result of an unknown
  type, a str result the callee owns, a threading contract other than
  thread-affine (RN-UNSUPPORTED); a malformed runtime ABI, and one that is
  not the target support package's (RN-RUNTIME-ABI).
* **The artifacts:** a missing shared object, a header not the manifest's,
  a stale or substituted shared object (RN-ARTIFACT); a Linux/glibc shared
  object with its digest recorded, a 4 KiB-aligned one, a missing exported
  symbol (RN-ELF).
* **Names:** two exports with one JavaScript name; a reserved name
  (`delete`, `constructor`, `diagnostics`, `get_constants`); an invalid npm
  name, `../escape`, a module name with shell metacharacters, a version, a
  license, a library name with `../` (RN-NAME, RN-MANIFEST).
* **Versions and API levels:** React Native 0.87 or 0.89 (RN-REACT-NATIVE),
  an app API level below 24 (RN-ANDROID-API).
* **Output:** a non-empty directory the tool did not make; a previous
  package without `-replace`, or with a file someone else put there
  (RN-OUTPUT).
* **Diagnostics:** every refusal is also a structured diagnostic in the
  request's diagnostics file.
* **CMake** (`rn-cmake-guards`): another ABI, an API level below 24, a
  library not the recorded one.
* **The JavaScript layer** (Jest): fractional, NaN, infinite and unsafe
  integers; a wrong JavaScript type; `null`; missing and extra arguments;
  an unknown method; a native failure that is not a BotlishError passing
  unchanged; no native module.
* **The core** (host): every number rule, embedded NULs, invalid UTF-8 at
  the C boundary (`boundary`), the empty string, a mebibyte, a wrong
  thread, a dead owner thread, an invalidated module.

## 21. Mutation testing

`audit/react-native-2048/tools/mutate.tcl` with `mutants.txt`: 44 mutants,
each with the detector tests that must kill it. `tools/mutant-catalogs.tcl`
applies all of them (95 catalogs, 0 problems).

Observed (`results/mutation.txt`): **44/44 killed**, each by a detector
its `!!` line names. The harness runs each mutant in a private copy of the
tree, against a baseline in which every detector passes unmutated.

| what the mutants break | mutants | killed by |
|---|---:|---|
| the generator's checks: types, ownership, digests, target, runtime ABI, C ABI version, ELF (machine, libraries, 16 KiB), React Native version, names, output | 12 | the `rn-refuse-*` tests |
| what the generator writes: methods from the manifest, distinct module names, the Codegen configuration, paths relative to the package, the library and its ABI directory, the CMake ABI and digest guards, no second runtime | 9 | `rn-generate-*`, `rn-two-libraries-apart`, `rn-cmake-guards` |
| the generated C++ core: unsafe and fractional integers, strings by length both ways, error identity and categories, released results and errors, thread affinity, one instance per module, invalidation, destruction on the owner thread, reaping | 13 | `rn-core-game`, `rn-core-textkit`, `rn-core-gc-stress` |
| the generated TypeScript entry point: unsafe integers, argument counts, error identity, no JavaScript fallback | 4 | `rn-js-jest` |
| the hook: no call while rendering, the latest snapshot, no new game on rerender, one call per move, no rules in JavaScript, nothing native at unmount | 6 | `rn-js-jest` |

Two mutants survived the first full run, and each exposed a weakness that
was fixed:

* **`guessed-param-type`** (a parameter of an unknown type guessed instead
  of refused). Its first text guessed a string. The generator's C type
  check then refused the parameter, whose C type is `int64_t`, with the
  same code, so the mutant changed nothing observable. Rewritten to guess
  what the C type suggests (an int), it is killed by `rn-refuse-param-type`.
* **`any-thread`** (the core uses the instance from whichever thread
  calls). Its detector, `wrong-thread-refused`, only checked for a
  WRONG-THREAD failure, and the library's own thread-affinity refusal
  gives the same code. The check now also requires the adapter's message
  ("belongs to thread") and an unchanged call counter, so it proves that
  the refusal comes before the C ABI is entered.

Both were rerun (`-only guessed-param-type,any-thread`): killed.
`tools/mutant-catalogs.tcl` applies every mutant of every catalog under
`audit/` (95 catalogs, 0 problems).

## 22. Performance and footprint

**Observed on the host** (x86-64, 4 cores):

| measure | value |
|---|---|
| `botlish tool ... react-native generate` for `game`: the request, the checks (digests, ELF), the package written | 0.49 to 0.51 s (1.2 s the first time, with cold caches); two runs give identical trees |
| a 2048 move through the generated core and the C ABI, Linux build of the library: the snapshot text parsed, the move, the spawn, the text written | 30.7 µs per call, the mean of 4,100 calls (`game_core stress 20`; `results/host/stress-diagnostics.txt`) |
| the same under `BOTLISH_NATIVE_GC_STRESS=1` | 189.0 µs per call, the same 20 final states |

The time is the core's own measurement of its C ABI calls (`nativeNanos`).
The JSI conversion and the JavaScript side are Android measurements: the
self-test logs the first call of each library and the mean of the timed
moves (`BOTLISH_RN timing ...`), and the acceptance logs each launch's
`TotalTime` and each played swipe's input-to-render latency. They are in
the CI run's artifacts (pending, section 16).

**Footprint, observed** (`results/footprint.txt`; local release builds,
React Native 0.88.1, arm64-v8a only):

| artifact | bytes |
|---|---:|
| `botlish_react_native-0.1.0.botpkg` (17 files, 956,028 unpacked) | 409,014 |
| the tool's program (static, stripped) | 841,736 |
| `react-native-botlish-game-0.1.0.tgz` (14 files, 1,151,883 unpacked) | 452,355 |
| `react-native-botlish-textkit-0.1.0.tgz` | 425,017 |
| `libgame.so`: the package's (the manifest's) / in the APK | 1,093,032 / 756,136 |
| `libtextkit.so`: the package's / in the APK | 1,055,160 / 732,104 |
| the React Native template's APK, arm64-v8a, no Botlish package | 19,028,306 |
| the 2048 app's APK, both packages | 20,601,745 (+1,573,439, +8.3%) |
| `libappmodules.so`: the template's / the app's (both adapters, both Codegen specs, the app) | 145,912 / 264,680 |
| the JavaScript bundle: the template's / the app's (both entry points, the screens) | 1,012,412 / 1,031,056 |

Each Botlish library carries its own localized runtime, about 0.7 MB
stripped, so two libraries cost two runtimes. Sharing one runtime between
libraries is not a goal of the native-library ABI
(NATIVE-LIBRARY-MILESTONE-1.md: a library's symbols are private).

## 23. Regression and CI

**Observed locally** (`LANG=C.utf8`, Tcl 9.0.1, the native backend built):

| run | result |
|---|---|
| `tests/react-native-package.test` (ANDROID_NDK_ROOT, prebuilt Android packages, BOTLISH_RN_APP) | 47/47 |
| `tests/external-tools.test` | 48/48 |
| `tests/native-library.test` | 28/28 |
| `tests/android-target.test` | 17 passed, 4 skipped (`androidRun`, `androidRun16k`: qemu-aarch64 and Android roots not set up here) |
| `tests/package-manager.test` | 86/86 |
| `tests/workload-2048.test` | 9 passed, 2 skipped (`darwinIO`, `windowsIO`) |
| `audit/react-native-2048/tools/mutate.tcl` | 44/44 killed (section 21) |
| `tools/compilerpedia.tcl check` | 0 problems |
| `tools/mutant-catalogs.tcl` | 95 catalogs, 0 problems |
| `python3 -I tools/ci/test_runs.py` (a new workflow) | OK |
| `audit/react-native-2048/tools/build.sh`, checkout to APK | passed |
| `cleanroom.sh` (section 18) | passed |

The compiler, the runtime, the standard library and the single executable
are unchanged, so no other test file's outcome can change. The change's
own files are new, besides AGENTS.md and docs/INDEX.md (static: the
branch's diff against `a6977d56`).

**CI.** `.github/workflows/react-native-2048.yml` runs on every push that
touches the integration, the example, the 2048 engine, the audit or the
Android packaging script. It is a test workflow with the
`react-native-2048-${{ github.ref }}` concurrency group (CI-RUNS.md);
nothing in the release gate requires it. Its runs on this branch:

@@CI-RUNS@@

Main's own workflows were queued or in progress, none red among those
completed, when this branch was made (`a6977d56`) and when it was last
checked.

## 24. Remaining platform gaps

* **AArch64 hardware.** The Android runs are x86_64 emulators executing
  the arm64-v8a APK through Android's ARM native bridge. GitHub's Linux
  runners have KVM for x86_64 guests only, and Google's emulator runs arm64
  system images on arm64 hosts only (macOS, which GitHub's runners give no
  nested virtualization). So in those runs every arm64 instruction of the
  app runs translated: Hermes, React Native, the adapter and Botlish. Native AArch64
  execution of the same library remains the Android target milestone's
  (qemu-user, Bionic) evidence. Software emulation of an arm64 Android on
  this x86_64 host is refused by the emulator (section 16). A physical
  device or an arm64 emulator on an arm64 host with KVM is the missing
  evidence for native execution inside an app.
* **Android execution itself** (section 16): the acceptance is
  implemented, and was not observed in this session. Until a run of the
  workflow's `android` jobs passes, the app on Android, the reloads (also
  the development reload with Metro, `tools/dev-reload.sh`), GC stress in
  the app process and the measurements on Android are unproven.
* **iOS.** Not supported. The package declares `ios: null`, iOS
  autolinking is disabled, and no podspec or module provider is written.
  It needs:
  - a Botlish iOS library (code generation and a runtime for
    `aarch64-apple-ios`; the census measured the platform tag as the only
    blocker for Mac-made code);
  - an `RCTModuleProvider` and podspec template;
  - a simulator run.

  The TypeScript and the core C++ are platform-neutral.
* **Other Android ABIs.** `armeabi-v7a` and `x86` have no Cranelift
  backend. `x86_64` has no Botlish Android target yet. The CMake file
  refuses each with a message; there is no stub.
* **Asynchronous calls.** Synchronous only. A Promise method would run the
  instance on a Botlish-owned thread (M4) and settle through
  `AsyncPromise`; that is a later milestone (section 25).
* **The old architecture and Expo Go** are not supported.

## 25. Next milestones

* **Standalone Android 2048** (projected): the same facade under a native
  Android UI, without React Native: Kotlin, JNI over the same C ABI. A JNI
  generator would be another tool package beside this one, reusing its
  core layer and checks.
* **Asynchronous modules** (projected): a generated `Promise` method per
  export, the library's instance owned by one Botlish thread (M4's
  `std::thread`), each call's arguments and result copied across.
  Thread affinity holds by construction, since the instance never leaves
  that thread. The census's `host_async.cpp` measured the hand-off.
* **Host-driven VM embedding** (projected): a host's run loop drives the
  Botlish event loop (an Android Looper doorbell), for libraries whose
  calls suspend.
* **iOS** (projected): section 24's three steps.
