# audit/react-native

The probes of the React Native target census (REACT-NATIVE-TARGET-CENSUS.md):
Botlish functions called from JavaScript as a Pure C++ TurboModule. Nothing
here is part of the compiler. Nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` loads it.

Since NATIVE-LIBRARY-MILESTONE-1.md the Botlish side is the compiler's own
library mode: `rnprobe.bot` declares its functions `exported c fn`, and
`main.tcl -emit-native-library rnprobe` builds `librnprobe.a`, `rnprobe.h`
and the manifest `rnprobe.json`. The host probe runs on it. The mobile
probes do not yet: building a native library for an Android or iOS target
is not part of that milestone, so `.github/workflows/react-native-probe.yml`
runs, by hand only, at the census's revision (cc7e6e3b), where the stand-in
`libmode.tcl` still worked.

* `probe/rnprobe.bot` -- the exported Botlish functions (Int, String, Bool,
  a declared error, non-tail recursion), each a root of its own.
* `tools/rnpackage.tcl` -- a prototype of the React Native plugin's
  generator.
  * From the library's JSON manifest and C header it writes a complete
    package: `package.json` with `codegenConfig`, `react-native.config.js`,
    the TypeScript spec and entry point, the C++ adapter (one library
    instance per module, created by its first call on the JS thread), the
    Android CMake file, the iOS module provider and podspec.
  * With `-codegen-project` it also runs Codegen.
* `tools/host-spike.tcl` -- the host probe.
  * Library (the compiler's), package, Codegen, React Native's TurboModule
    sources and `host/host_main.cpp`, on a Hermes built at React Native's
    pinned tag, running `host/probe.js`.
  * Then `host/host_async.cpp` (Promise methods on a Botlish worker thread
    that owns its own library instance) running `host/async.js`.
* `tools/macho-platform.tcl` -- reads or rewrites a Mach-O object's
  `LC_BUILD_VERSION`.

History (the mobile path, run at the census's revision):

* `tools/libmode.tcl` -- the stand-in for the library mode the compiler then
  lacked. It no longer runs against the current compiler: it read the
  executable link's startup crate, which the program descriptor replaced,
  and called functions by symbols that are now local to the program object.
  It also showed the defect the milestone fixed (an export specialized for
  the constants its top level happened to pass).
* `probe/standin.c` -- libmode's C ABI written in C, the mobile control.
* `app/App.tsx` -- the probe app's screen.
* `ci/` -- the steps of `.github/workflows/react-native-probe.yml`:
  * the Botlish library for a mobile Rust target (libmode);
  * a stock React Native 0.88 app with the generated package installed from
    its npm tarball;
  * the emulator and simulator runs.
* `patches/runtime-aarch64-cfg.patch` -- the one-line runtime fix the AArch64
  Android and iOS builds applied. Without it the runtime did not compile for
  them: `prepare` was defined twice.

To run any of these, check the census's revision out beside this one
(`git worktree add DIR cc7e6e3b`) and run them there.

```
tclsh9.0 audit/react-native/tools/host-spike.tcl -work DIR -react-native-project RN-PROJECT \
    -hermes-src HERMES -hermes-build HERMES-BUILD -folly FOLLY ?-stack-kib 512? ?-gc-stress 1?
```

REACT-NATIVE-TARGET-CENSUS.md, section 16, has the prerequisites.
