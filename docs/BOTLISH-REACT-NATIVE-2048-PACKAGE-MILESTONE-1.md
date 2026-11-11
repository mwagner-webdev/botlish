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

**Android execution is observed on both emulator images, Android 14 with
4 KiB pages and Android 15 with 16 KiB pages, through the ARM native
bridge: every phase but GC stress.** Run 12 passed both Android jobs. The
CI evidence (sections 16 and 23):

* Run 8: the app crashed at launch on both emulator images, before any
  JavaScript or Botlish code ran. React Native's library loader (SoLoader)
  looked for the unextracted libraries under the device's primary ABI,
  x86_64, not the app's arm64-v8a. The app now extracts its native
  libraries at installation.
* Run 9, on the Android 14 x86_64 image with the ARM native bridge (4 KiB
  pages), passed every phase, for the build's APK and for the clean room's:
  - the self-test in the app process, under Hermes: 401 module snapshots
    and 401 hook states, each equal to the interpreter's;
  - every Botlish call on React Native's JavaScript thread;
  - three reloads, each destroying the old instances on their own threads;
  - 24 swipes on the screen, every one applied exactly once;
  - the win and the game over on the screen;
  - a clean exit, with no crash;
  - the debug build's development reload with Metro, twice.

  The app's arm64 code ran translated by the native bridge, not natively.
  It ran natively on a phone, in the device builds (section 16).

**The gaps:**

* **GC stress in the app process: demonstrated on a phone, by hand; on
  the CI emulators it cannot be.** On a realme GT 7, which runs arm64
  code natively, the GC-stress device build took 258.2 µs a call in
  Botlish and the plain build 38.8 µs: 6.7x, over the acceptance's 2x
  (the host: 6.2x). Every check of both self-tests passed (below, and
  section 16, "Device builds"). The owner read both off the phone's
  screen; no CI job runs on arm64 hardware. On the emulators:
  - In run 9 the GC-stress phase passed, but the library ran no slower
    under it than without it. The activity sets the variable with
    `Os.setenv`, and the arm64 library, which runs on the native bridge's
    own libc, did not see it.
  - Run 10 set the variable from the process's start instead, through
    Android's `wrap.PACKAGE` property. That starts the process through a
    wrapper without the native bridge, and the app could not load its
    arm64 libraries.

  The acceptance now reports the phase as NOT DEMONSTRATED on a
  native-bridge device, never as passed. A device that runs arm64 code
  natively checks it. GC stress of the libraries through the same
  generated core is observed on the host (section 19).

  The device builds (section 16, "Device builds") take the check to a
  phone without adb (and CI runs them on both emulator images, run 13).
  On the phone, with the variable set as its process started, the
  GC-stress build's self-test passed:
  - 401 snapshots, digest `fbee79e6`, the interpreter's;
  - 258.2 µs a call in Botlish, against the plain build's 38.8 µs;
  - every other check of the self-test.
* **The 16 KiB-page image** (Android 15, page size 16384) passed in run 12,
  with every phase but GC stress, as the 4 KiB image did. The app's
  extracted, 16 KiB-aligned libraries were loaded by a 16 KiB-page kernel.
  Its first run, run 11, failed only because the acceptance counted a
  crash of Google Play services, another process on the device, as the
  app's. The acceptance has counted the app's own crashes only since.

This host has no KVM, and Google's emulator refuses an arm64 guest on an
x86_64 host, also when its `qemu-system-aarch64` is run directly (observed,
section 16).

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
| `useBotlish2048()` and a playable 2048 screen (swipes, buttons, score, New game, game over, win) | implemented; Jest observed (34 tests: 10 of the hook and the snapshot reader, 17 of the generated entry point, 1 without the native module, 6 of the device builds and the self-test's digest) |
| device builds for a phone without adb (`-PbotlishDevice=plain`, `gc-stress`): a Self-test button, the result on the screen, the GC-stress build beside the plain one | implemented; both APKs built and inspected locally; **on a phone (realme GT 7, arm64 natively) both self-tests passed, and GC stress took effect in the library: 258.2 against 38.8 µs a call (6.7x)** (section 16); `tools/device-builds.sh` passed on both CI emulator images (run 13), GC stress NOT DEMONSTRATED there through the bridge |
| a second, unrelated library through the same generator, both packages in one app | observed (host harness, TypeScript, Jest, the APK) |
| a clean room: the single-file compiler and packages only, then npm, Codegen and Gradle | observed (section 18) |
| the app on Android: Hermes, the TurboModule, the Botlish library in an Android application process | **observed on Android 14 (4 KiB pages), translated by the ARM native bridge** (CI, runs 9 to 13: every phase but GC stress); GC stress in the app process not demonstrable on a native-bridge emulator; **observed on Android 15 (16 KiB pages) too** (CI, runs 12 and 13: every phase but GC stress); **natively on a phone (realme GT 7), by hand: the device builds' self-tests, GC stress taking effect (6.7x)** (section 16) |
| mutation testing | 48/48 killed, each by a detector it names; observed (section 21) |
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
  instance, and `reload` calling `ReactHost.reload`;
* the device builds' Self-test button and the self-test's result on the
  screen (section 16, "Device builds"). The default build shows neither.

A swipe on the board (`PanResponder`, 24 points at least, the larger axis)
or an arrow reads one direction. The hook asks the library, React renders
the new snapshot. Every input, snapshot and input-to-render latency is
logged as `BOTLISH_RN ...` lines.

What was observed of the app without an Android device:

* TypeScript (`tsc --noEmit`) over the app and both generated entry points;
* Jest: 34 tests (section 14; `results/jest.txt`). Six of them are the
  device builds' screens and the self-test's digest
  (`__tests__/deviceBuild.test.tsx`).
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
  - the manifest's `extractNativeLibs` is true, so the libraries
    (compressed in the APK) are extracted at installation (section 16);
  - the JavaScript bundle is Hermes bytecode (its magic, `c6 1f bc 03`)
    holding both entry points (`BotlishGame`, `BotlishTextkit`), the hook
    and the self-test.

The screen itself (the board drawn, swipes on it, the overlay) is Android
evidence: section 16.

## 16. Android execution

**Status:**

* **Observed on Android 14, 4 KiB pages, through the ARM native bridge**
  (CI, runs 9 to 13): every phase but GC stress, for the build's APK and
  the clean room's, and the development reload with Metro.
* **GC stress in the app process: not demonstrable on a native-bridge
  emulator** (run 10, below). The acceptance reports it there as NOT
  DEMONSTRATED.
* **On a phone** (realme GT 7, arm64 natively), by hand: both device
  builds' self-tests passed, and **GC stress took effect in the library**:
  258.2 µs a call under it, 38.8 µs without (6.7x; "Device builds",
  below).
* **Observed on Android 15, 16 KiB pages, through the ARM native bridge**
  (CI, runs 12 and 13): every phase but GC stress. Run 11 failed there on another
  process's crash, which the acceptance counted as the app's (below).

The runs and their results follow the description.

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
3. **gc-stress.** The self-test under `BOTLISH_NATIVE_GC_STRESS=1`. It
   must give the same snapshots, and its C ABI time per call must be at
   least twice the self-test's: a collection before every allocation makes
   a move 6.2 times slower on the host, so this shows that stress took
   effect in the library. The activity sets the variable with `Os.setenv`
   before React Native starts.
   - On a device that runs the app's arm64 code through a native bridge,
     the library's libc does not see it (run 9, below), and no other route
     keeps the bridge (run 10, below). There the phase is reported NOT
     DEMONSTRATED, with its measurement, in the summary and in the result
     line, never as passed.
   - On a device that runs arm64 natively, a phase without the slowdown
     fails.
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
workflow. Runs 1 to 7 stayed `queued`, because the repository's runners
were busy with other branches' runs that had been going for hours, and
each newer push cancelled the queued run, as the workflow's concurrency
group intends.

**Run 8** (`be3d4018`) got its runners after three to four hours. Observed
(the jobs' logs and `summary.txt` artifacts, section 23):

* Both images booted with the ARM native bridge:
  - `sdk_gphone64_x86_64`: API 34, `abilist x86_64,arm64-v8a`,
    `native.bridge libndk_translation.so`, 4 KiB pages, booted in 25 s;
  - `sdk_gphone16k_x86_64`: API 35, the same ABIs and bridge, 16 KiB
    pages.
* The APK installed as arm64-v8a (`installed abi arm64-v8a`).
* **The app crashed at launch on both images**, before any JavaScript
  ran: `com.facebook.soloader.SoLoaderDSONotFoundError: couldn't find DSO
  to load: libreactnative.so`, raised from `MainApplication.onCreate`
  through `DefaultNewArchitectureEntryPoint.load`. Every phase failed
  after it, and the acceptance reported each failure: no self-test line,
  no Hermes, no mapped Botlish library, no board on the screen, seven
  crash lines.

The cause is React Native's library loader on a native-bridge device, not
Botlish. No Botlish code had run yet, and `libreactnative.so` is React
Native's own library. The facts:

* AGP keeps an app's native libraries inside the APK by default: the
  APK's manifest said `extractNativeLibs=false`.
* SoLoader 0.12.1, React Native 0.88.1's, then loads them through
  `DirectApkSoSource`. It builds the path from
  `SysUtil.getSupportedAbis()[0]`, which is `Build.SUPPORTED_ABIS`
  (static: its bytecode, `javap -c`). On these devices that is `x86_64`,
  so SoLoader looked in `base.apk!/lib/x86_64`. An arm64-v8a-only APK
  has no such directory, and the process, which runs arm64 code through
  the bridge, needs `lib/arm64-v8a`.
* A real arm64 device lists `arm64-v8a` first, and is not affected.

**The fix** (`examples/react-native/app/android/app/build.gradle`): the
app extracts its native libraries at installation (`packaging { jniLibs {
useLegacyPackaging = true } }`, which sets `extractNativeLibs="true"`).
They then lie in the app's native library directory, `lib/arm64`, where
SoLoader's `ApplicationSoSource` looks first. An extracted library is
loaded from its file, so what a 16 KiB device needs is the ELF alignment,
which every library has. In the APK they are now compressed, so
`zipalign -P 16` has no `.so` entry to page-align. `inspect-apk.sh` now
also requires `extractNativeLibs=true` in the APK's manifest.

The generator, the generated package and the Botlish libraries are
unchanged. The fix is the app's own packaging, as any arm64-only React
Native 0.88 app would need to start on such a device.

**Run 9** (`8bf01899`), job `android (4 KiB pages)`, on
`sdk_gphone64_x86_64`: Android 14 (API 34), `abilist x86_64,arm64-v8a`,
`native.bridge libndk_translation.so`, 4 KiB pages. It ran the acceptance
on the build's APK, again on the clean room's APK, then the development
reload. Every one passed (`result: passed`, three times). Observed (the
job's log and artifact `rn2048-android-0`):

* **Self-test.** `failures=0`, `env hermes=true reactNative=0.88.1 os=android
  api=34`, and both libraries' metadata (target, ABI, the manifest's and
  the shared object's SHA-256, the runtime ABI).
  - 401 module snapshots and 401 hook states equal the interpreter's.
  - Each library's instance was created on React Native's JavaScript
    thread `mqt_v_js`, and all its calls (game 4,819, textkit 10,015) were
    made on that thread.
  - `libgame.so` and `libtextkit.so` were mapped from the app's native
    library directory, `/data/app/.../lib/arm64/`, where they were
    extracted.
* **Reloads.** Each of the three reloads passed the self-test again with
  the interpreter's snapshots, made a new instance of each library, and
  destroyed the old one on its own thread with status 0.
  - On the clean room's APK every old instance was destroyed when its
    thread exited.
  - On the build's APK, reload 2's old game instance was first orphaned
    (`its module went on thread 5251; its own thread 5233 destroys it`),
    then destroyed on its own thread 5233. This is the foreign-thread path
    of section 11, observed in the app.
  - After three reloads the process counters balance: game 4 instances
    created, 3 destroyed (at thread exit; 1 orphaned first on the build's
    APK), 19,244 results acquired and released, 32 errors acquired and
    released; textkit 24 results and 12 errors, each acquired and
    released.
* **GC stress: passed, but not demonstrated.** The self-test passed with
  the interpreter's snapshots, and the app process logged the variable as
  set. But a call's time in the C ABI was 83.13 µs under "stress" against
  98.36 µs without it for the build's APK, and 78.44 against 80.87 µs for
  the clean room's, where the host is 6.2 times slower under stress. So the library's runtime did not see the
  variable. `Heap::new` reads it with `getenv`, and the arm64 library runs
  on the native bridge's arm64 libc, which very likely kept the
  environment it was given at process start. The acceptance now sets the
  variable from the process's start and checks its cost (phase 3 above);
  the run that checks it is pending (section 23).
* **Play.**
  - 24 swipes on the screen, 8 of them in a burst. Every one was read once,
    in order, and applied exactly once.
  - 25 snapshots equal the interpreter's, and New game made the
    interpreter's game of seed 43.
  - 26 traced calls, all on the JavaScript thread and none on any other.
  - One instance across background and foreground.
  - Input to render took 13.43 ms on average (12.59 ms for the clean room's
    APK).
* **Win, over, exit.** The screen showed "won" after the move that made
  2048, and "game over" after the last move. The back key ended the
  activity, and no native crash or fatal exception occurred in any phase.
* **Development reload** (the debug build, its bundle from Metro over `adb
  reverse`). The self-test passed with Metro's bundle under Hermes. Both
  of React Native's double-R reloads passed it again, each making a new
  instance of each library and destroying the old one on its own thread
  (status 0).

This is the app's arm64 code (Hermes, React Native, the adapters and
Botlish) running translated in a real Android application process.

The job `android (16 KiB pages)` of run 9 was cancelled, still queued, by
the push that corrected the GC-stress phase (section 23).

**Run 10** (`b60b76dc`), job `android (4 KiB pages)`, ran on the same image.
Its build type was `userdebug` and `ro.debuggable` was 1, and it set
`wrap.com.botlish2048` to `BOTLISH_NATIVE_GC_STRESS=1` for the GC-stress
phase.

* **The GC-stress phase failed.** The app crashed at launch before any
  JavaScript ran: `SoLoaderULError: dlopen failed:
  ".../lib-main/libc++_shared.so" is for EM_AARCH64 (183) instead of
  EM_X86_64 (62)`, raised through `WrapperInit.main`. A process started
  through a wrapper does not get the native bridge, so it cannot load the
  arm64 libraries at all. The route fails on this device for a reason
  that has nothing to do with Botlish. With run 9's measurement, GC
  stress in the app process cannot be shown on a native-bridge emulator.
  The acceptance no longer uses the property, and reports the phase as NOT
  DEMONSTRATED there (above).
* **Every other phase passed again**:
  - the self-test, with 401 module snapshots and hook states equal to the
    interpreter's, on `mqt_v_js`;
  - three reloads. Reload 3's old game instance was again orphaned when
    its module went on another thread (6300), then destroyed by its own
    thread (6293);
  - play: 24 swipes, each applied exactly once, with 25 snapshots equal to
    the interpreter's;
  - the win, the game over and the exit.

  The two crash lines the run counted are the GC-stress launch's.
* **The corrected textkit timing:** 3.41 µs per call.

Its `android (16 KiB pages)` job was cancelled, still queued, by the push
of the acceptance's corrected GC-stress phase (`bc4bb613`).

**Run 11** (`bc4bb613`), job `android (4 KiB pages)`, ran on the same image.
Every phase passed for both APKs, and the development reload with Metro
passed. Each acceptance ended `result: passed, but NOT DEMONSTRATED on this
device: gc-stress`, with the measurement:

* the build's APK: `NOT DEMONSTRATED gc-stress: no sign of stress in the
  library (67.49 us per call in the C ABI, 0.5x the self-test's 132.25
  us)`;
* the clean room's APK: 60.60 µs against 58.37 µs, 1.0x.

The textkit timing now reads 2.01 to 2.12 µs per call. Reload 2's old game
instance was again orphaned when its module went on another thread, then
destroyed on its own thread.

**Run 11's 16 KiB job** (`android (16 KiB pages)`,
[job 129156321360](https://github.com/mwagner-webdev/botlish/actions/runs/42609322660/job/129156321360))
ran on `sdk_gphone16k_x86_64`: Android 15 (API 35), `abilist
x86_64,arm64-v8a`, `native.bridge libndk_translation.so`, page size 16384.
This is the image's first run.

**Observed in the app process:**
* **Self-test.** `env hermes=true reactNative=0.88.1 os=android api=35`,
  and 401 module snapshots equal to the interpreter's.
  - Both libraries' instances were created on `mqt_v_js`.
  - `libgame.so` and `libtextkit.so` were mapped from
    `/data/app/.../lib/arm64/`: the extracted, 16 KiB-aligned libraries
    loaded by a 16 KiB-page kernel.
  - The first call took 85.28 ms (the instance made), the second 0.31 ms.
* **Reloads 2 and 3** passed the self-test again with the interpreter's
  snapshots. Each destroyed the old instances on their own threads with
  status 0, and the counters balance: 14,032 results and 24 errors, each
  acquired and released.
* **The GC-stress phase's launch** passed its self-test with the
  interpreter's snapshots. A move took 74.26 µs from JavaScript (68.45 µs
  in the C ABI, 5.82 µs JSI and adapter), and textkit 2.27 µs a call.
* **Play.** 24 swipes, each read once and applied exactly once; 25
  snapshots equal to the interpreter's; every call on the JavaScript
  thread. Input to render took 15.41 ms on average.
* **Win, over, exit.** The screen showed "won" and "game over", and the
  exit had no crash.

**Why it failed.** The acceptance counted the crashes of another process
as the app's.
* Google Play services (`com.google.android.gms.persistent`, pid 2216)
  crashed during the run, with five Java exceptions and one SIGSEGV
  (`Fatal signal 11 ... pid 2216 (.gms.persistent)`). The device also
  listed two tombstones, whose processes the acceptance does not read.
* The acceptance's crash patterns matched any process. Seeing the SIGSEGV,
  it stopped waiting for the self-test, which was still running: its
  last line was `ok textkit-empty`. So the hook states and the timing
  were not captured, the first reload's wait broke the same way, and the
  GC-stress ratio had no self-test timing to compare.
* None of the six crash lines is the app's.

**The fix** (`android-acceptance.sh`, `dev-reload.sh`): only the app's own
crashes count, matched by the process each report names:
* AndroidRuntime's `Process: com.botlish2048, PID`;
* libc's `pid N (com.botlish2048)`;
* debuggerd's `>>> com.botlish2048 <<<`.

Other processes' crash lines are counted apart and noted, never as the
app's. Checked against the runs' own logs: the filter finds the app's
crashes of runs 8 and 10 and none of run 11's six lines.

The clean room's APK and the development reload are the 4 KiB job's
alone.

**Run 12** (`304ba6bd`) passed both Android jobs. Every acceptance ended
`result: passed, but NOT DEMONSTRATED on this device: gc-stress`.

The job `android (16 KiB pages)`
([job 129284261090](https://github.com/mwagner-webdev/botlish/actions/runs/42644203711/job/129284261090))
ran on `sdk_gphone16k_x86_64`: Android 15 (API 35), the native bridge,
page size 16384.
* **Self-test.** `failures=0`, `env hermes=true reactNative=0.88.1
  os=android api=35`.
  - 401 module snapshots and 401 hook states equal the interpreter's.
  - Each library's instance was created on `mqt_v_js`, and all its calls
    (game 4,819, textkit 10,015) were made there.
  - Both libraries were mapped from `/data/app/.../lib/arm64/`: extracted,
    16 KiB-aligned, loaded by a 16 KiB-page kernel.
* **Reloads.** All three passed the self-test again with the interpreter's
  snapshots, and each destroyed the old instances on their own threads
  with status 0. The counters balance: 19,244 results and 32 errors, each
  acquired and released.
* **GC stress: NOT DEMONSTRATED.** 142.76 µs a call in the C ABI, 0.8x the
  self-test's 183.82 µs. The self-test under it passed, with the
  interpreter's snapshots.
* **Play.** 24 swipes, each read once and applied exactly once; 25
  snapshots equal to the interpreter's; every call on the JavaScript
  thread; one instance across background and foreground.
* **Win, over, exit.** The screen showed "won" and "game over", and the
  app neither crashed nor raised a fatal exception in any phase. The
  acceptance noted `3 crash lines of other processes on the device (not
  the app's)`.

The job `android (4 KiB pages)`
([job 129284261160](https://github.com/mwagner-webdev/botlish/actions/runs/42644203711/job/129284261160)),
on Android 14, passed for the build's APK (GC stress 0.7x) and for the
clean room's (0.9x), and the development reload with Metro passed. On the
clean room's APK, reloads 1 and 2 both went the foreign-thread way: the
old instance was orphaned when its module went on another thread, then
destroyed on its own thread. This happened for the game library in both
reloads and for textkit in reload 2, so the process counted 2 and 1
orphaned instances, with every destruction's status 0.

**Device builds.** The acceptance drives the app with launch extras
through adb, and a phone in hand has none. The Gradle property
`-PbotlishDevice` (`android/app/build.gradle`) makes the same app for a
device:

* `plain` is the app with a **Self-test** button under the game. The
  self-test shows its result on the screen:
  - "passed", or the checks that failed;
  - whether GC stress is on;
  - the digest of the module's 401 snapshots against the interpreter's;
  - the time per call.

  "Back to the game" returns to the board.
* `gc-stress` is the same, plus `BOTLISH_NATIVE_GC_STRESS=1`, set with
  `Os.setenv` in `MainApplication.onCreate`, before React Native starts and
  so before any Botlish instance exists. It is an application of its own
  (`com.botlish2048.gcstress`, "2048 GC stress"), installed beside the
  plain one.
* Without the property the build is the acceptance's, unchanged. Its
  `MainApplication` holds no `setenv`, and its `MainActivity` passes no
  `device` option, so the game shows no button (observed in the three
  APKs' dex, and by `rn-js-jest`'s `deviceBuild.test.tsx`).

The self-test now checks the module's snapshots against the interpreter's
on the device itself. FNV-1a of the 401 lines (`src/digest.ts`) must equal
`oracleDigest` in `src/directions.ts`, which `rn-selftest-oracle-digest`
recomputes from the Botlish interpreter. The CI's line-by-line comparison
from logcat stays.

`build.sh` builds both device APKs after the acceptance's
(`app-device-plain.apk`, `app-device-gc-stress.apk`). They differ from it
in their dex, their manifest and, for gc-stress, their package. Each
passes `inspect-apk.sh`: the Botlish libraries are byte for byte the
packages' as stripped, 16 KiB-aligned, extracted at installation.

`tools/device-builds.sh DIR OUT` uses them as a person does, on any device
adb sees. For each build it checks:

* the package and the label;
* a launch from the launcher with no extras;
* the build's line on the game screen and, for the GC-stress build, the
  variable set as its process started;
* a tap on Self-test, failures=0 and the digest's check;
* the screen's "passed" and "GC stress: on" or "off";
* "Back to the game", and no crash of the app.

Then it compares the two builds' time per call in the C ABI. The rule is
the acceptance's: at least 2x passes, and through a native bridge a lower
ratio is NOT DEMONSTRATED. Run against a phone over USB, it is the
acceptance's GC-stress check on hardware. Both Android jobs of the
workflow run it after the other phases; run 13 passed it on both images
(below).

**On a phone, observed.** The owner of the project installed both
locally built APKs on a realme GT 7 (Android version and page size not
recorded). The APKs hold arm64-v8a code only, so they install only where
it runs. Both looked right. The GC-stress build's self-test screen read:

```
Botlish self-test: passed
GC stress: on (this build)
401 snapshots, digest fbee79e6 (the interpreter's: fbee79e6)
a 2048 move: 260.3 µs, 258.2 µs of it in Botlish (4001 calls)
a textkit call: 0.93 µs (10,000 calls)
```

So every check of the self-test passed in an app process whose arm64 code
runs natively, with `BOTLISH_NATIVE_GC_STRESS=1` in the libc the
libraries use:
* the snapshots equal the interpreter's;
* the contracts and errors held;
* the hook equalled the module;
* ownership balanced;
* the instances belonged to the JavaScript thread.

and the plain build's, on the same phone:

```
Botlish self-test: passed
GC stress: off (this build)
401 snapshots, digest fbee79e6 (the interpreter's: fbee79e6)
a 2048 move: 39.7 µs, 38.8 µs of it in Botlish (4001 calls)
a textkit call: 0.79 µs (10,000 calls)
```

**GC stress took effect in the library on hardware.** 258.2 µs a call in
Botlish under it, 38.8 µs without: 6.7x, where the acceptance asks for
2x. The host's Linux build of the same library gives 6.2x (189.0 against
30.7 µs, section 19), so the phone's slowdown is that of the forced
collection attempts at every allocation site, not noise. On the
emulators the same comparison stays at 1.0x (run 13, below). The textkit
call barely changes (0.93 against 0.79 µs): `scalarCount("abc")`
allocates little to collect.

What this evidence is, and is not:
* it is one self-test of each build, read off the screen by the owner
  and reported here, not `tools/device-builds.sh` over USB and not a CI
  job: the two runs were taken at different times, and no log of either
  is committed;
* the margin, 6.7x against a threshold of 2x, leaves no doubt of the
  verdict, and the snapshots' digest, the contracts, the hook and
  ownership passed under stress.

The JSI and adapter share was 0.9 µs a call in the plain build (2.1 µs
under GC stress), against 5 to 8 µs translated by the bridge (section
22).

**Run 13** (`aadb691c`, the device builds) passed every job. The
acceptance and the development reload passed as in run 12, every
acceptance ending `result: passed, but NOT DEMONSTRATED on this device:
gc-stress`. `tools/device-builds.sh` then passed on both images
([job 129684027788](https://github.com/mwagner-webdev/botlish/actions/runs/42770087048/job/129684027788),
Android 15 with page size 16384;
[job 129684027875](https://github.com/mwagner-webdev/botlish/actions/runs/42770087048/job/129684027875),
Android 14 with 4 KiB pages), for both builds:

* the package and the label: `com.botlish2048` "Botlish2048", and
  `com.botlish2048.gcstress` "2048 GC stress", installed side by side;
* a launch from the launcher with no extras showed the build's line ("Device
  build", "GC-stress build") and the Self-test button. The GC-stress build
  logged `BOTLISH_NATIVE_GC_STRESS=1` as its process started, and the plain
  build logged nothing of it;
* the button's self-test passed, its digest `fbee79e6` the interpreter's;
* the screen said "Botlish self-test: passed" and "GC stress: off (this
  build)" or "on";
* "Back to the game" returned to the board, with no crash of either app.

The comparison came out NOT DEMONSTRATED, as through the bridge it must:
95.12 against 95.07 µs a call in the C ABI with 16 KiB pages, 86.65
against 86.83 µs with 4 KiB pages (1.0x). The CI-built device APKs'
SHA-256 are `e0f35307...` (plain) and `85036416...` (gc-stress); they are
the `rn2048-build` artifact's `app-device-plain.apk` and
`app-device-gc-stress.apk`.

**Run 14** (`7dd3a578`) passed on its second attempt. On the first, the
16 KiB job's app died in its self-test because Android itself did:
`system_server` crashed (SIGSEGV in the package manager's
`ComponentResolver$ServiceIntentResolver.queryIntentForPackage`, x86_64
framework code on a binder thread), every app logged
`DeadSystemException`, and the three reloads timed out without a running
activity. Every later phase of that job passed, on a fresh process.

**Main's run for the merge** (`f06de8e6`) failed in the 4 KiB job's first
self-test, though nothing in it was wrong: the self-test ran twice in one
process. The first run logged its environment and its 401 module
snapshots, then the screen mounted again and a second run began in the
same JavaScript runtime (its first call took 0.167 ms: the instance
existed) before the first had drawn a hook state; one hook run and one
`selftest done failures=0` followed. That is what Android creating the
activity again looks like, on a cold emulator right after installation.
The acceptance concatenated both runs into 802 lines against the
interpreter's 401 and failed. It now splits a log into runs
(`splitRuns`: a run begins at index 0, each line goes to the run whose
next index it is) and holds every run to the interpreter's game: each
run's snapshots a prefix of it, at least one run whole, no stray line,
every finished run `failures=0`, and the last run started finished. Both
logs read again: main's passes, run 14's first 16 KiB attempt still
fails; a changed snapshot in a second run, a second run's failure, an
unfinished last run and a stray line fail. When the screen mounts again,
the summary says so and keeps the ActivityManager lines.

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
   - the Android release build: BUILD SUCCESSFUL in 4 min 47 s. Codegen ran
     from the app, for both packages
     (`generateReact_45_native_45_botlish_45_{game,textkit}Codegen*`); the
     app's own Codegen tasks were skipped, as it has no spec of its own.

   Neither the app nor the packages name this checkout.
3. **The APK** (11,285,621 bytes) holds arm64-v8a libraries only.
   `libgame.so` is the generated package's library as the Android build
   strips it. Every segment is 16 KiB-aligned, and `zipalign -c -P 16`
   passes. The manifest's `extractNativeLibs` is true: checked with the
   same `aapt2` command `cleanroom.sh` now runs, which this run predates
   by minutes.

The external dependencies (React Native, Hermes, Gradle's plugins) come
from npm's registry, Google's Maven and Maven Central: they are the app's,
not Botlish's. This host reaches them through a proxy. Its variables pass
into the room, and the run was given a Gradle properties file and a Maven
Central mirror (`GRADLE_PROPERTIES`, `GRADLE_INIT_DIR`), which are
environment, not inputs. **In CI, observed**, the workflow's build job ran the same clean room
after `single/build.sh`, on a GitHub runner without the proxy and its
settings, before the app's packaging fix (section 16) ([job 128893618768](https://github.com/mwagner-webdev/botlish/actions/runs/42533820805/job/128893618768),
at `be3d4018`): result passed.
* The Botlish steps touched nothing of the checkout and ran no Tcl of the
  system.
* Jest passed 28 tests, and the release build took 3 min 17 s.
* The APK, 20,604,081 bytes, holds arm64-v8a libraries only. Its
  `libgame.so` is the package's as stripped, its segments are 16 KiB
  aligned, and it is zip-aligned.

Its single executable (15,917,955 bytes) and packages were built on the
runner, so their digests differ from the local ones.

**Run 9's clean room** ([job 128981303373](https://github.com/mwagner-webdev/botlish/actions/runs/42562346693/job/128981303373),
at `8bf01899`, after the packaging fix) passed again. Jest passed 28 tests,
and the release build took 3 min 8 s. Its APK, 11,287,309 bytes, SHA-256
`ca32b1b3...`, passed the APK checks, the new one included: `ok the native
libraries are extracted at installation (extractNativeLibs true)`.

That APK, built in the clean room from the single-file compiler and
published packages alone, then passed the whole Android acceptance on the
4 KiB emulator (section 16, run 9).

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
* **Android, observed** (CI runs 9 to 13, Android 14 with 4 KiB pages and
  Android 15 with 16 KiB pages, both through the ARM native bridge:
  section 16; the counts below are run 9's):
  - three reloads, each making new instances of both libraries and
    destroying the old ones on their own threads;
  - one old instance of each library orphaned by a foreign thread first,
    then destroyed by its own;
  - two development reloads with Metro;
  - background and foreground with one instance;
  - every acquired result and error released (19,244 and 32).

  GC stress in the app process is **not demonstrated**, and cannot be on
  a native-bridge emulator. `Os.setenv` does not reach the library's arm64
  libc (run 9), and a wrapper-started process gets no native bridge, so it
  cannot load the app (run 10). GC stress through the generated core is
  the host's evidence above, with the same Botlish runtime built for the
  host.
* **On a phone, observed** (realme GT 7; section 16, "Device builds").
  The GC-stress device build's self-test passed in an app process that
  runs arm64 natively, with the variable set before any instance existed:
  its snapshots were the interpreter's and ownership balanced. Its 258.2
  µs a call in Botlish against the plain build's 38.8 µs (6.7x; the host
  6.2x) shows the stress taking effect in the library. Read off the
  screen by hand, one run of each.

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

`audit/react-native-2048/tools/mutate.tcl` with `mutants.txt`: 48 mutants,
each with the detector tests that must kill it. `tools/mutant-catalogs.tcl`
applies all of them (95 catalogs, 0 problems).

Observed (`results/mutation.txt`): **48/48 killed**, each by a detector
its `!!` line names, in a full run with the device builds. The earlier full
run, before them, killed 44/44 (its record follows in the same file). The harness runs each mutant in a private copy of the
tree, against a baseline in which every detector passes unmutated.

| what the mutants break | mutants | killed by |
|---|---:|---|
| the generator's checks: types, ownership, digests, target, runtime ABI, C ABI version, ELF (machine, libraries, 16 KiB), React Native version, names, output | 12 | the `rn-refuse-*` tests |
| what the generator writes: methods from the manifest, distinct module names, the Codegen configuration, paths relative to the package, the library and its ABI directory, the CMake ABI and digest guards, no second runtime | 9 | `rn-generate-*`, `rn-two-libraries-apart`, `rn-cmake-guards` |
| the generated C++ core: unsafe and fractional integers, strings by length both ways, error identity and categories, released results and errors, thread affinity, one instance per module, invalidation, destruction on the owner thread, reaping | 13 | `rn-core-game`, `rn-core-textkit`, `rn-core-gc-stress` |
| the generated TypeScript entry point: unsafe integers, argument counts, error identity, no JavaScript fallback | 4 | `rn-js-jest` |
| the hook: no call while rendering, the latest snapshot, no new game on rerender, one call per move, no rules in JavaScript, nothing native at unmount | 6 | `rn-js-jest` |
| the device builds: the Self-test button in the default build, any `device` value taken, a stale `oracleDigest`, the digest's multiplication in floating point | 4 | `rn-js-jest`, `rn-selftest-oracle-digest` |

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
**On Android, observed** (CI run 9; Android 14 on an x86_64 emulator,
*every arm64 instruction translated by the native bridge*, so the absolute
numbers are not those of an arm64 phone):

| measure | the build's APK | the clean room's APK |
|---|---:|---:|
| first launch of the self-test (`am start -W` TotalTime; install, translation, Hermes, the bundle) | 1,864 ms | 823 ms |
| later launches (TotalTime: play, win, over) | 326 to 353 ms | 307 to 338 ms |
| the game library's first call, its instance made | 33.66 ms | 10.02 ms |
| its second call | 0.41 ms | 0.31 ms |
| the text library's first call, its instance made | 17.60 ms | 7.80 ms |
| a 2048 move, mean of 4,001 calls, from JavaScript | 103.40 µs | 85.28 µs |
| of it in the C ABI (the Botlish library) | 98.36 µs | 80.87 µs |
| of it in JSI and the generated adapter | 5.05 µs | 4.41 µs |
| a swipe on the screen to the new board rendered, mean of 24 | 13.43 ms | 12.59 ms |

The adapter and JSI cost about 5 µs a call, about 5 % of a move. The move
itself is the Botlish library's: 2048's rules over the snapshot text,
translated by the bridge. The same library built for the host x86-64 takes
30.7 µs.

The textkit line of the log (`10000 scalarCount calls: 5995.84 us per
call` and `2577.84`) is wrong by a factor of 1,000. The self-test
multiplied milliseconds by 100 where it should have multiplied by 0.1,
so the true figures are about 6.0 and 2.6 µs a call. The self-test is
corrected. Run 11 logged 2.01 to 2.12 µs a call. Run 10 logged 3.41 µs,
on another runner whose game
move took 165.23 µs from JavaScript (155.53 µs in the C ABI, 9.70 µs JSI
and adapter) and whose input to render averaged 18.50 ms. Run 12's
Android 15 image with 16 KiB pages, on another runner, took 1,974 ms to
the first launch, 83.15 ms to the game library's first call, 196.52 µs a
move from JavaScript (183.82 µs in the C ABI, 12.70 µs JSI and adapter),
4.98 µs a textkit call and 21.35 ms from input to render; the same run's
clean room APK, on the 4 KiB image, 67.84 µs a move (64.73 and 3.12 µs)
and 10.07 ms. The runners differ that much between runs, and these
figures cannot separate a page size's share from a runner's.

**On a phone** (realme GT 7, arm64 natively; the device builds, section
16; one self-test of each, read off the screen):

| measure | plain build | GC-stress build |
|---|---:|---:|
| a 2048 move from JavaScript, mean of 4,001 calls | 39.7 µs | 260.3 µs |
| of it in the C ABI (the Botlish library) | 38.8 µs | 258.2 µs |
| of it in JSI and the generated adapter | 0.9 µs | 2.1 µs |
| a textkit call, mean of 10,000 | 0.79 µs | 0.93 µs |

Natively the adapter and JSI cost under a microsecond a call, about 2 % of
a move; translated by the bridge they cost 5 to 8 µs. The move itself,
38.8 µs, is near the host x86-64 build's 30.7 µs.

**Footprint, observed** (`results/footprint.txt`; local release builds,
React Native 0.88.1, arm64-v8a only). Native libraries are compressed in
the APK and extracted at installation, the app's packaging (section 16).
The template was built with the same packaging.

| artifact | bytes |
|---|---:|
| `botlish_react_native-0.1.0.botpkg` (17 files, 956,028 unpacked) | 409,014 |
| the tool's program (static, stripped) | 841,736 |
| `react-native-botlish-game-0.1.0.tgz` (14 files, 1,151,883 unpacked) | 452,355 |
| `react-native-botlish-textkit-0.1.0.tgz` | 425,017 |
| `libgame.so`: the package's (the manifest's) / installed (stripped) / compressed in the APK | 1,093,032 / 756,136 / 361,015 |
| `libtextkit.so`: the package's / installed / compressed in the APK | 1,055,160 / 732,104 / 336,588 |
| the React Native template's APK, arm64-v8a, no Botlish package | 10,622,082 |
| the 2048 app's APK, both packages | 11,285,609 (+663,527, +6.2%) |
| `libappmodules.so` installed: the template's / the app's (both adapters, both Codegen specs, the app) | 145,912 / 264,680 |
| the JavaScript bundle: the template's / the app's (both entry points, the screens) | 1,012,412 / 1,031,388 |
| installed native code the two Botlish packages add (both libraries, the `libappmodules.so` difference) | 1,607,008 |

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
| `audit/react-native-2048/tools/mutate.tcl` | 48/48 killed (section 21) |
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

* runs 1 to 7 (`4d1fc581` to `d25b5c0d`): each stayed queued until the
  next push cancelled it, with no runner assigned;
* run 8, at `be3d4018`, the tested commit of this report:
  [react-native 2048 #8](https://github.com/mwagner-webdev/botlish/actions/runs/42533820805).
  - **build: success** (observed, 2026-11-09 00:12 UTC). `build.sh` ran
    from checkout to APK. It stops at the first failed check, so on a
    GitHub runner it observed all of these:
    - the host checks of both cores, the stricter thread check included;
    - GC stress, with the same 20 final states;
    - the 401 snapshots, identical to the interpreter's;
    - TypeScript, Jest and the release build;
    - the APK inspection.

    The job then made the debug build for Metro (BUILD SUCCESSFUL in
    1 min 30 s), the single-file compiler, and the clean room (section 18).
  - **android (16 KiB pages): failure**
    ([job 128909277779](https://github.com/mwagner-webdev/botlish/actions/runs/42533820805/job/128909277779),
    03:29 to 03:52 UTC), and **android (4 KiB pages): failure**
    ([job 128909277826](https://github.com/mwagner-webdev/botlish/actions/runs/42533820805/job/128909277826),
    04:00 to 04:13 UTC). Both emulators booted. The app crashed at launch
    in React Native's SoLoader (`couldn't find DSO to load:
    libreactnative.so`), and so did every phase after it. The cause and
    the fix are in section 16.
* run 9, at `8bf01899`, the app's packaging fix:
  [react-native 2048 #9](https://github.com/mwagner-webdev/botlish/actions/runs/42562346693).
  - **build: success**: the build and the clean room, the extraction
    check included (section 18).
  - **android (4 KiB pages): success**
    ([job 129017340836](https://github.com/mwagner-webdev/botlish/actions/runs/42562346693/job/129017340836)):
    the acceptance of the build's APK and of the clean room's, and the
    development reload with Metro, every phase passed (section 16). Its
    GC-stress phase passed without demonstrating GC stress (section 16).
  - **android (16 KiB pages): cancelled** while still queued, by the push
    of the corrected GC-stress phase.
* run 10, the GC-stress phase through `wrap.PACKAGE` and the self-test's
  textkit timing:
  [react-native 2048 #10](https://github.com/mwagner-webdev/botlish/actions/runs/42577642784),
  at `b60b76dc`.
  - **build: success.**
  - **android (4 KiB pages): failure**
    ([job 129066467473](https://github.com/mwagner-webdev/botlish/actions/runs/42577642784/job/129066467473)),
    in the GC-stress phase alone. A wrapper-started process has no native
    bridge (section 16). Every other phase passed.
  - **android (16 KiB pages): cancelled** while still queued, by the push
    of `bc4bb613`.

  The acceptance's GC-stress phase is changed after it: no wrapper, and
  NOT DEMONSTRATED on a native-bridge device.
* run 11, at `bc4bb613`, the GC-stress phase reporting NOT DEMONSTRATED:
  [react-native 2048 #11](https://github.com/mwagner-webdev/botlish/actions/runs/42609322660).
  - **build: success.**
  - **android (4 KiB pages): success**
    ([job 129156321062](https://github.com/mwagner-webdev/botlish/actions/runs/42609322660/job/129156321062)).
    Every phase passed for the build's and the clean room's APK, and the
    development reload with Metro passed. GC stress was NOT DEMONSTRATED
    (0.5x and 1.0x), as the summary and the result line say (section 16).
  - **android (16 KiB pages): failure**
    ([job 129156321360](https://github.com/mwagner-webdev/botlish/actions/runs/42609322660/job/129156321360)),
    the image's first run. Every phase ran in the app process on Android
    15 with 16 KiB pages, but the acceptance counted Google Play services'
    crash as the app's (section 16). The acceptance counts the app's own
    crashes only since.
* run 12, at `304ba6bd`, only the app's own crashes counted:
  [react-native 2048 #12](https://github.com/mwagner-webdev/botlish/actions/runs/42644203711).
  - **build: success.**
  - **android (16 KiB pages): success**
    ([job 129284261090](https://github.com/mwagner-webdev/botlish/actions/runs/42644203711/job/129284261090)).
    Android 15, page size 16384: every phase passed, with GC stress NOT
    DEMONSTRATED (0.8x). Three crash lines of other processes were noted.
  - **android (4 KiB pages): success**
    ([job 129284261160](https://github.com/mwagner-webdev/botlish/actions/runs/42644203711/job/129284261160)).
    Android 14: both APKs and the development reload with Metro passed,
    with GC stress NOT DEMONSTRATED (0.7x and 0.9x).

  Every acceptance ended `result: passed, but NOT DEMONSTRATED on this
  device: gc-stress`.
* run 13, at `aadb691c`, the device builds:
  [react-native 2048 #13](https://github.com/mwagner-webdev/botlish/actions/runs/42770087048).
  - **build: success**, the two device APKs among its outputs.
  - **android (16 KiB pages): success**
    ([job 129684027788](https://github.com/mwagner-webdev/botlish/actions/runs/42770087048/job/129684027788)):
    the acceptance as in run 12, then `device-builds.sh`: every check
    passed, GC stress NOT DEMONSTRATED (1.0x).
  - **android (4 KiB pages): success**
    ([job 129684027875](https://github.com/mwagner-webdev/botlish/actions/runs/42770087048/job/129684027875)):
    both APKs' acceptance, the development reload with Metro, and
    `device-builds.sh`: every check passed, GC stress NOT DEMONSTRATED
    (1.0x).
* run 14, at `7dd3a578`: green on its second attempt; the first lost its
  16 KiB job's app to an Android `system_server` crash (section 16).
* main's run for the merge, at `f06de8e6`: the build, the 16 KiB job and
  both jobs' device builds green; the 4 KiB job's acceptance failed on a
  self-test that ran twice in one process, which the acceptance now
  checks run by run (section 16).

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
  this x86_64 host is refused by the emulator (section 16). On a phone, a
  realme GT 7, the device builds ran natively (section 16, "Device
  builds"). That was observed by the project's owner, not by CI: no CI
  job runs on arm64 hardware, so a regression there is found only by
  running the device builds again (or `tools/device-builds.sh` over USB).
* **GC stress in the app process** (section 16): not demonstrable on a
  native-bridge emulator, so CI cannot check it. The variable does not
  reach the library's arm64 libc, and a wrapper-started process gets no
  bridge. On a phone (realme GT 7) it was demonstrated by hand: 6.7x, the
  self-tests passing. A CI job on arm64 hardware would make it a standing
  check.
* **16 KiB pages on hardware.** The 16 KiB-page Android 15 image passed
  (runs 12 and 13), through the native bridge like the 4 KiB one. The
  phone's page size was not recorded, so a 16 KiB device running arm64
  natively is still to come.
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
