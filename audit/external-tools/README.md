# audit/external-tools

The experiments of EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md
(PM-7A): explicit compiler extensions through ordinary packages. Nothing
here is part of the compiler or the package manager; the compiler never
reads it.

| path | what |
|---|---|
| `src/toolkit.h` | what the sample tools share: a strict JSON reader, the protocol 1 request, the native library manifest (schema 2) as data, structured diagnostics, output files (C99, the C library only) |
| `src/emit-caller.c` | the `abi_tools` package's tool: from a library's manifest, a C program that calls its exports from tab-separated command lines (experiment D) |
| `src/hostgen.c` | the `hostgen` package's `host-module` tool, shaped like the future React Native generator: a TypeScript spec, a C adapter over a JavaScript-like host's values, `package.json` and `CMakeLists.txt` (experiment E) |
| `src/probe-tool.c` | the tests' fixture tool: records every run, its exact arguments and its request; exits, crashes, reports diagnostics or tampers on demand |
| `packages/` | the experiment's package sources: `abi_tools`, `hostgen` (schema 4 tools), `game2048` (the 2048 engine as an ordinary package) and `botlish_target_linux` (a linux-x86_64 target support package) |
| `2048/engine.bot` | a C ABI over the unchanged 2048 engine: the game as state text, built as the native library `game` |
| `tools/packages.sh` | the author's side: compiles the tools, assembles the target support package from a native build, packs everything with the compiler it is given |
| `tools/mutate.tcl`, `tools/mutants.txt` | the mutation harness: 18 mutants, each killed by the tests its `!!` line names |
| `cleanroom/cleanroom.sh` | the clean room: the single-file compiler and the packed artifacts only, an empty environment, strace evidence that nothing of the checkout and no system Tcl is touched |
| `cleanroom/harness.c` | the JavaScript-like host that drives the generated adapter (the tests and the clean room) |
| `results/` | the clean room's recorded outcome |

Run:

    tclsh9.0 tests/external-tools.test
    tclsh9.0 audit/external-tools/tools/mutate.tcl [-only NAME,...]
    single/build.sh
    audit/external-tools/tools/packages.sh OUT native/target/release single/out/botlish
    audit/external-tools/cleanroom/cleanroom.sh single/out/botlish OUT/repo RESULTS
