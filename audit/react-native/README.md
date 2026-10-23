# audit/react-native

The probes of the React Native target census (REACT-NATIVE-TARGET-CENSUS.md):
Botlish functions called from JavaScript as a Pure C++ TurboModule. Nothing
here is part of the compiler. Nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` loads it.

The Botlish library is the compiler's own (NATIVE-LIBRARY-MILESTONE-1.md):
`main.tcl -emit-native-library rnprobe` writes `librnprobe.a`, `rnprobe.h`
and `rnprobe.manifest.json`, and the package generator reads only those.

* `probe/rnprobe.bot` -- the exported Botlish functions (`exported c fn`:
  Int, String, Bool, a declared error, non-tail recursion). It holds
  declarations only.
* `tools/rnpackage.tcl` -- a prototype of the React Native plugin's
  generator.
  * From the library's manifest and header it writes a complete package:
    `package.json` with `codegenConfig`, `react-native.config.js`, the
    TypeScript spec and entry point, the C++ adapter (one library instance
    per module, made on the JS thread), the Android CMake file, the iOS
    module provider and podspec.
  * With `-codegen-project` it also runs Codegen.
* `tools/host-spike.tcl` -- the host probe.
  * Library, package, Codegen, React Native's TurboModule sources and
    `host/host_main.cpp`, on a Hermes built at React Native's pinned tag,
    running `host/probe.js`.
  * Then `host/host_async.cpp` (Promise methods on a Botlish worker thread
    that owns its own instance) running `host/async.js`.
* `tools/macho-platform.tcl` -- reads or rewrites a Mach-O object's
  `LC_BUILD_VERSION`.
* `app/App.tsx` -- the probe app's screen.

```
tclsh9.0 audit/react-native/tools/host-spike.tcl -work DIR -react-native-project RN-PROJECT \
    -hermes-src HERMES -hermes-build HERMES-BUILD -folly FOLLY ?-stack-kib 512? ?-gc-stress 1?
```

REACT-NATIVE-TARGET-CENSUS.md, section 16, has the prerequisites.

## History

The census built its library with a stand-in, and its mobile runs keep
using it, from the census's own tree:

* `tools/libmode.tcl` -- the stand-in for the library mode the compiler
  lacked: C wrappers over the functions' generic entries, built from the
  executable link's captured startup crate. It no longer runs against this
  tree (the milestone's shared startup removed what it captured).
* `probe/standin.c` -- the census's C ABI (libmode.tcl's `rnprobe_botlish.h`)
  in C, for telling a React Native failure from a Botlish one.
* `ci/` -- the steps of `.github/workflows/react-native-probe.yml`: the
  Botlish library for a mobile Rust target, a stock React Native 0.88 app
  with the generated package installed from its npm tarball, the emulator
  and simulator runs. The workflow runs by hand only and checks out the
  census's tree (its `CENSUS_REF`): a mobile native library (an Android or
  iOS runtime and link) is outside the milestone.
* `patches/runtime-aarch64-cfg.patch` -- the one-line runtime fix the AArch64
  Android and iOS builds applied. Without it the runtime did not compile for
  them: `prepare` was defined twice.
