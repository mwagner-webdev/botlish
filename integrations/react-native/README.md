# botlish_react_native

A Botlish external tool package (tool protocol 1, BOTLISH-TOOLS.md): its
tool `react-native` turns a compiled Botlish native library into an npm
package that a React Native app with the New Architecture installs as a
Pure C++ TurboModule. The design and its evidence are
BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md.

Nothing here is part of the compiler. The compiler never loads this tool,
and installing the package runs nothing: the tool runs only when
`botlish tool` names it, in a process of its own.

## What it reads, and what it refuses

The tool reads the native library's documented artifacts, never Botlish
source or HIR:

* `LIB.manifest.json` (schema 2, NATIVE-LIBRARY-MILESTONE-1.md);
* `LIB.h`, the C header;
* `libLIB.so`, the shared object.

Before it writes a byte it checks:

* the manifest's schema 2 and C ABI version 1;
* the target `android-aarch64` (`aarch64-linux-android`), matching the
  request's `-target`;
* that the library's runtime ABI equals its target support package's;
* the threading (`thread-affine`) and reentrancy (`refused`) contracts, no
  callbacks, no native dependencies;
* every export's C types and ownership, exactly as the C ABI states them
  for its boundary type;
* the SHA-256 of the shared object, the static library and the header,
  against the manifest;
* the shared object, from its bytes:
  - an AArch64 `ET_DYN`;
  - every loadable segment aligned to at least 16 KiB;
  - SONAME `libLIB.so`;
  - only Bionic's `libc.so`, `libm.so`, `libdl.so` and `liblog.so` needed,
    and no glibc symbol version;
  - no text relocation;
  - its whole C ABI exported.

A manifest it cannot read completely is refused with a diagnostic, never
guessed at:

* a boundary type other than `int`, `bool`, `float64` and `str` (and a
  `unit` result);
* an unknown ownership or contract;
* a method name JavaScript reserves.

Each refusal has a stable code: `RN-REQUEST`, `RN-USAGE`, `RN-MANIFEST`,
`RN-TARGET`, `RN-RUNTIME-ABI`, `RN-UNSUPPORTED`, `RN-ARTIFACT`, `RN-ELF`,
`RN-NAME`, `RN-REACT-NATIVE`, `RN-ANDROID-API`, `RN-OUTPUT` and `RN-WRITE`.

## Use

In a Botlish project with the library's sources:

    botlish add botlish_target_android_aarch64 -repository REPO -target android-aarch64
    botlish add botlish_react_native -repository REPO
    ANDROID_NDK_ROOT=... botlish -target android-aarch64 \
        -target-support botlish_target_android_aarch64 \
        -emit-native-library game -out lib game.bot
    botlish tool -out generated/react-native-botlish-game \
        -artifact lib/game.manifest.json -target android-aarch64 \
        react-native generate [-name NPM-NAME] [-module MODULE] [-version V] \
        [-react-native 0.88] [-android-api N] [-license SPDX] [-replace]
    (cd generated/react-native-botlish-game && npm pack)

The options:

* `-name`: the npm package. Default `react-native-botlish-LIB`, with `_`
  read as `-`.
* `-module`: the JavaScript module name, which must be unique in the app.
  Default `Botlish` and the library name in PascalCase.
* `-version`: the npm version. Default `0.1.0`.
* `-react-native`: the React Native minor version to generate for. The tool
  knows `0.88` (tested with 0.88.1) and refuses any other.
* `-android-api`: the app's minimum API level. Default React Native's floor
  (24), never below the library's own (21).
* `-license`: an SPDX expression. Default `UNLICENSED`.
* `-replace`: generate again over a package this tool made; the tool removes
  only the files its record names.

Into an app:

    npm install ./react-native-botlish-game-0.1.0.tgz

Then build for arm64-v8a alone: set `reactNativeArchitectures=arm64-v8a` in
`android/gradle.properties`. React Native's autolinking needs no other
change: the package is a pure C++ dependency whose Codegen the app runs.

## What it writes

| file | what |
|---|---|
| `package.json` | the npm package: `codegenConfig` (the spec, app-owned Codegen), `peerDependencies.react-native` (`>=0.88.0 <0.89.0`), the platforms (`android`: `arm64-v8a`; `ios`: none) |
| `react-native.config.js` | Android autolinking of a pure C++ dependency (`cxxModule*`); iOS disabled |
| `src/NativeMODULE.ts` | the Codegen spec: one method per export, plus `botlishDiagnostics` |
| `src/index.ts` | the entry point. It checks argument counts and types (`TypeError`) and the safe integer and finite number rules (`RangeError`), and turns native failures into `BotlishError` (`category`, `identity`, `fields`). It also exports `declaredErrors`, `library` and `diagnostics()` |
| `cpp/MODULECore.{h,cpp}` | the C ABI layer, which knows no JavaScript engine. It enforces the instance's thread, refuses reentrant calls and releases every owned result and error on every path. It checks numbers again and counts what it does |
| `cpp/MODULEModule.{h,cpp}` | the TurboModule: Codegen's `NativeMODULECxxSpec` over the core; a failure becomes a thrown JavaScript error |
| `android/CMakeLists.txt` | the adapter's static target. It refuses any ABI but arm64-v8a, and an app API below the package's. It checks `libLIB.so` against its SHA-256 and links it as an imported shared library, which the Android build packages |
| `native/android/arm64-v8a/libLIB.so`, `include/LIB.h`, `botlish/LIB.manifest.json` | the library, its header and its manifest, unchanged |
| `botlish-react-native.json` | the record. It names the generator, the library and its digests and ABIs, React Native's range, the Android ABI and API levels, and the files |
| `README.md` | the package's own documentation |

The output is deterministic: no time, host path or directory order.

## The module at run time

* Calls are synchronous, on React Native's JavaScript thread.
* A Botlish instance is created at the module's first call, on that thread,
  which owns it from then on.
* A call from another thread is refused with `BotlishError` invocation
  `WRONG-THREAD` before the C ABI is entered.
* The instance is destroyed on its own thread only:
  - at once, when the module goes on that thread;
  - otherwise at that thread's next call into the library, or at its exit
    (a reload ends React Native's JavaScript thread).
* Lifecycle events are logged to logcat under the tag `BotlishRN`.
* `adb shell setprop debug.botlish.rn.trace 1` also logs every call's
  thread.

## Build (the author's side)

    integrations/react-native/package.sh OUT BOTLISH...

The script compiles the tool statically for linux-x86_64, with its templates
embedded (`src/embed.c`), and packs `OUT/repo/botlish_react_native-0.1.0.botpkg`.
The package carries the tool's sources under `source/`.
