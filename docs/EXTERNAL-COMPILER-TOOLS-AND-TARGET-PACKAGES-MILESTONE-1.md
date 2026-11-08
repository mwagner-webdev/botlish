# EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md

## PM-7A: explicit compiler extensions through ordinary packages, external tools and target support packs

> An extension package is an ordinary package until the developer explicitly
> invokes an extension it provides.

This milestone is the first, deliberately narrow part of PM-7
(PACKAGE-ECOSYSTEM-ROADMAP.md, section 10). It establishes three boundaries
-- what an external tool can rely on from a compilation (the artifact
manifest), how an explicitly selected package's tool runs (the tool
protocol), and how an optional package supplies a target's runtime artifacts
(target support packages) -- and proves them from the distributed
single-file compiler with a generated C caller and a React-Native-shaped
host module of the 2048 engine. The normative specifications are
BOTLISH-TOOLS.md (protocol 1, the manifest's schema 2, the support
descriptor) and BOTLISH-JSON.md section 14 (schema 4's `tools`).

Evidence is marked as **observed** (run here, output shown or committed),
**static** (read from the source), **CI** (a workflow step that runs it) or
**projected** (what a later milestone can build on).

## Contents

1. [Executive result](#1-executive-result)
2. [Starting-state census](#2-starting-state-census)
3. [Extension architecture](#3-extension-architecture)
4. [Package manifest changes](#4-package-manifest-changes)
5. [Tool invocation](#5-tool-invocation)
6. [Tool protocol](#6-tool-protocol)
7. [Artifact manifest](#7-artifact-manifest)
8. [Target support packages](#8-target-support-packages)
9. [Dependency resolution](#9-dependency-resolution)
10. [Cleanroom experiment](#10-cleanroom-experiment)
11. [2048 experiment](#11-2048-experiment)
12. [Security boundary](#12-security-boundary)
13. [Compatibility](#13-compatibility)
14. [Tests](#14-tests)
15. [Mutation testing](#15-mutation-testing)
16. [Performance and footprint](#16-performance-and-footprint)
17. [Remaining limitations](#17-remaining-limitations)
18. [Next milestones](#18-next-milestones)

## 1. Executive result

**Implemented.** Every completion criterion holds on Linux x86-64, observed
from the single-file compiler in a clean room:

| criterion | where |
|---|---|
| 1. a `.botpkg` can declare an external tool | schema 4 `tools` (section 4); `abi_tools`, `hostgen`, the probe packages |
| 2. installing it executes nothing | `et-install-runs-nothing`; clean room B |
| 3. an explicit command resolves and runs it in a subprocess | `botlish tool` (section 5) |
| 4. arguments and paths without shell interpolation | the `/bin/sh` trampoline; `et-tool-argv-exact`, `et-tool-unicode-paths`; clean room B |
| 5. a documented, versioned protocol | BOTLISH-TOOLS.md, protocol 1 |
| 6. failures and protocol mismatches reported accurately | `et-tool-protocol`, `-exit-status`, `-crash`, `-diagnostics`, `-report-refusal` |
| 7. dependencies and author locks stay authoritative | `et-tool-lock-binding` (section 9) |
| 8. a `.botpkg` can declare target support artifacts | `botlish_target_linux` (section 8) |
| 9. the compiler selects a compatible runtime artifact for a supported target | `-target-support`; `et-target-support-links`; clean room C |
| 10. missing or incompatible support is refused precisely | nine refusal kinds, `et-target-support-*` |
| 11. no package can register a compiler pass | no mechanism exists: section 3 |
| 12. a native library writes a manifest sufficient for a C caller | manifest schema 2 (section 7) |
| 13. a tool consumes it without the HIR | `emit-caller`, `host-module` (C, the manifest only) |
| 14. a clean room with only the compiler and packages runs a tool | section 10 |
| 15. the tool generates a foreign caller of a real Botlish library | experiment D |
| 16. the caller runs and keeps the error and ownership contracts | section 11 |
| 17. the 2048 engine, unchanged, is the realistic consumer | section 11 |
| 18. ordinary packages and compilations are unaffected | section 13 |
| 19. no Android or React Native in the compiler | section 3 |
| 20. tests and mutation testing | sections 14 and 15 |

Two findings changed the plan. The single-file compiler could not build a
native library at all (it carries the system linker's runtime archive, not
`libbotlish_native.a`): fixed, since experiment D depends on it. And Tcl's
`exec`, the only process primitive the package manager has, reads a word
starting with `<`, `>`, `|` or `2>` as a redirection: a tool's arguments go
through a fixed `/bin/sh` trampoline instead.

## 2. Starting-state census

Read before anything was built (static, except where marked observed).
TUI-CLEANROOM-PACKAGE-MILESTONE-1.md, which the brief names, does not exist
in this repository; the package clean rooms that do are
SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md's and
RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md's, whose pattern section 10 follows.

**1. What ordinary `.botpkg` packages already do.** PM-1 to PM-3: pure-Botlish
packages; target-aware packages (schema 2) whose target views carry
per-target files and bundled native libraries, every bundled file's format
and architecture checked at packing and at every view derivation
(`pm/binary.tcl`, reading bytes); run-time dependencies (schema 3); one
dependency graph with binding locks (SHARED-PACKAGE-DEPENDENCIES-
MILESTONE-1.md); transactional installation; an installation record of
every file's size and CRC-32. **Nothing a package holds is ever run**, and
the archive format cannot represent an executable bit (BOTPKG-FORMAT.md,
sections 9 and 10).

**2. What external tools invoking the compiler already do.** The
repository's own tools drive the compiler as a Tcl library
(`tools/c-bindgen.tcl`, 159 audit scripts: REACT-NATIVE-TARGET-CENSUS.md,
section 7) or through its command line. The React Native prototype
generator (`audit/react-native/tools/rnpackage.tcl`) already reads **only**
the native library's manifest and header -- "It never reads Botlish source
or HIR: the C ABI is the boundary" -- and refused any manifest schema but 1.

**3. What is genuinely missing for target support.** The system linker's
runtime archive comes from beside the driver (`codegen/aot.rs`'s
`packaged_runtime_archive`) or `BOTLISH_NATIVE_RUNTIME`, an environment
override for tests; nothing lets a package supply one, nothing selects one
explicitly, and nothing can tell an archive's target from its bytes beyond
its object format and machine (`archive_machine`): a Linux/glibc and an
Android/Bionic AArch64 archive are both "ELF AArch64". The runtime ABI
fingerprint existed (`aotimage::abi_fingerprint`, checked by every startup)
but only as a function computed at run time: no archive stated it.

**4. What is missing from the exported native-library metadata.** The
manifest (schema 1) stated the interface but not the build it describes
(no file digests: a manifest could sit beside another build's archive), not
the compiler or runtime ABI, and ownership only in prose (`types.str.rule`).

**5. What would otherwise require modifying compiler internals.** The React
Native census proposed a plugin facility, "`main.tcl -plugin PATH` sources a
Tcl file that registers subcommands" -- code inside the compiler process.
PM-7A provides the same reach out of process: a tool gets the compiler's
command in its request and runs it, and nothing is sourced into the
compiler.

**6. Existing conventions made documented interfaces.** The manifest
(BOTLISH-TOOLS.md, section 8, now normative); the runtime ABI fingerprint
(`botlish-native runtime-abi`, the runtime archive's identity record); the
package manager's binary inspection (now also for tool programs).

**Observed census finding.** The single executable built from main
(`f2787af`) refused library mode:

    $ botlish -emit-native-library chk -out lib chk.bot
    chk.bot: native runtime archive missing: .../native-f41f8542-.../libbotlish_native.a;
    run cargo build --release --manifest-path native/Cargo.toml (NATIVE NOT-BUILT)

## 3. Extension architecture

Three categories, one package format:

| category | what it holds | how it acts | who reads it |
|---|---|---|---|
| ordinary library package | Botlish modules, target files, native libraries | its modules are imported | the compiler (`.bot_modules`) |
| external tool package | schema 4 `tools`: a native program per host | run by `botlish tool`, only, in its own process | the package manager |
| target support package | a runtime archive and `botlish-target-support.json` | linked into an executable when `-target-support` names it | the compiler, when named |

A package may be several at once (a tool package with modules, a target
support package a tool depends on). None of them can:

* change the grammar, register an intrinsic, replace type checking, modify
  context selection, contribute a diagnostic or a code-generation pass --
  no such mechanism exists, in the compiler or the package manager
  (static: the compiler reads a support descriptor as data and a tool never
  runs in its process);
* run code because it is installed, imported, compiled against or listed
  (section 12);
* add a target the compiler cannot generate code for (UNKNOWN-TARGET).

The compiler knows nothing of Android, JNI, Gradle, React Native, Codegen
or TypeScript: the only new compiler code is `native/support.tcl` (a
descriptor and an archive's identity record), the driver's
`--runtime-archive` and `runtime-abi`, and the manifest's new members. There
is no task graph, workflow language, event bus or lifecycle hook: a tool
receives a request, reads artifacts, writes outputs.

## 4. Package manifest changes

`botlish.json` **schema 4** = schema 3 + `tools` (BOTLISH-JSON.md section 14):

```json
{
  "schema": 4,
  "name": "abi_tools",
  "version": "0.1.0",
  "dependencies": {},
  "tools": {
    "emit-caller": {
      "protocol": 1,
      "summary": "generates a C command-line caller of a Botlish native library from its manifest",
      "programs": {"linux-x86_64": "tools/linux-x86_64/emit-caller"},
      "inputs": ["native-library"]
    }
  }
}
```

* A schema 1-3 file using `tools` is refused ("a schema 4 key"); a PM-3
  reader refuses schema 4 whole: never half-read (`et-schema3-tools-refused`).
* Every key is validated (`et-tools-invalid`: nine malformed declarations,
  each named); unknown keys (`script`) are errors.
* Each program is checked as a native executable of its host when packed
  and at every artifact acquisition (`pm::tools::ExecutableProblem` over
  `pm/binary.tcl`: ELF executable or PIE of the machine, Mach-O
  `MH_EXECUTE`, a PE executable that is no DLL; `et-pack-checks-programs`).
* The author's audit counts tool programs as declared native files.
* **Target support needed no manifest key.** The existing schema 2 model
  already expresses a target's runtime artifact: the experiment's support
  package declares its archive as a bundled static library (verified like
  any other) and carries its descriptor in its target view (section 8).

## 5. Tool invocation

    botlish tools [-project DIR]
    botlish tool [-project DIR] -out DIR [-artifact LIB.manifest.json]...
                 [-target T] [-target-support NAME] [-report FILE] TOOL [ARG...]

`tool` and `tools` are package-manager commands (`pm/tools.tcl`): main.tcl
dispatches them before loading the compiler, and the single executable does
not install its native backend for them. Observed:

    $ botlish tools
    abi_tools:emit-caller (abi_tools 0.1.0), protocol 1, hosts linux-x86_64, inputs native-library
        generates a C command-line caller of a Botlish native library from its manifest
    hostgen:host-module (hostgen 0.1.0), protocol 1, hosts linux-x86_64, inputs native-library
        generates a JavaScript-like host module (spec, adapter, package and build manifests) over a Botlish native library
    $ botlish tool -out gen -artifact lib/game.manifest.json emit-caller
    emit-caller: .../gen/game_caller.c, 8 exports of game

**Resolution** (BOTLISH-TOOLS.md, section 4): short or qualified
(`abi_tools:emit-caller`) names; only the project's direct dependencies
provide runnable tools; ambiguity, a transitive-only tool, an unknown
protocol, another host's program, a changed or missing program, a missing
or foreign input, an output inside `.bot_modules` are each a refusal of its
own (`PM TOOL-...`), before anything runs.

**The process boundary.** The program is checked against the installation
record (size, CRC-32) and its host's format, copied into a private
temporary directory, made executable there, and started with the words
after TOOL. Tcl's `exec` -- the only process primitive the package manager
has, and what the repository's tools use -- reads `<x`, `>x`, `|x`, `2>x`
and a final `&` as redirections. Observed in this milestone's first test
run: the test harness's own `exec` swallowed them. On Unix the tool starts
as

    /bin/sh -c 'n=$#; while [ "$n" -gt 0 ]; do a=$1; shift; set -- "$@" "${a#x}"; n=$((n - 1)); done; exec "$@"' sh xPROGRAM xARG...

-- each word a positional parameter prefixed with `x` and stripped by the
shell, never shell text, `exec` replacing the shell so that exit statuses
and signals are the tool's. `et-tool-argv-exact` passes `"a b"`, `"ünï €"`,
quotes, `$(touch pwned)`, `` `id` ``, `;`, `|x`, `>y`, `<z`, `2>w`, an empty
word, `-out`, `--help`, `*` and `&`, and reads them back byte for byte. On
Windows a redirection-like word is refused (TOOL-ARGUMENT).

**Outcome.** Standard streams are the command's; the exit status is the
tool's (`et-tool-exit-status`: 7), a signal fails it (`et-tool-crash`:
`SIGABRT`, TOOL-CRASHED), a change to the installation fails it
(`et-tool-modified`: TOOL-MODIFIED, whatever the tool returned), and a
refusal is `error: MESSAGE (PM TOOL-...)`, status 1. Structured diagnostics
are printed with their locations (`et-tool-diagnostics`):

    probe: the input is broken (its own words)
    probe_tools:probe: error: in.txt:3:7: the input is broken (PROBE-BROKEN)
    probe_tools:probe: warning: something odd (PROBE-ODD)
    tool probe_tools:probe (probe_tools 0.1.0) exited with status 3

`-report FILE` writes the outcome as JSON, also for a refusal
(`stage: refused, code: TOOL-AMBIGUOUS`).

## 6. Tool protocol

Protocol 1 (BOTLISH-TOOLS.md, sections 6 and 7): `BOTLISH_TOOL_REQUEST`
names a JSON request (observed, shortened):

```json
{
  "protocol": 1,
  "kind": "botlish-tool-request",
  "tool": {"name": "probe", "package": "probe_tools", "version": "0.1.0",
           "directory": ".../app/.bot_modules/probe_tools", "program": "/tmp/tcl_YwgVTS/probe"},
  "compiler": {"revision": null, "command": ["/usr/bin/tclsh9.0", "/home/user/botlish/main.tcl"]},
  "project": ".../app", "host": "linux-x86_64", "target": "linux-x86_64",
  "output": ".../out", "artifacts": [], "targetSupport": null,
  "environment": [],
  "arguments": ["say", "a b", "|x", ">y", "$(touch pwned)", "", "ünï"],
  "diagnostics": "/tmp/tcl_YwgVTS/diagnostics.json"
}
```

Versioning is a number on each side: a tool declares the protocol it
speaks, the command runs only one it speaks (TOOL-PROTOCOL), and a tool
refuses a request of another (`toolkit.h`'s `tk_open_request`). No
negotiation. Paths are absolute. The environment is inherited (a tool may
need its SDK's variables) and never copied into the request: the declared
variables are reported by name and whether set (`et-tool-environment`
checks that a value never appears). The compiler's command lets a tool
compile -- the Android packager of section 18 runs
`botlish -emit-native-library` itself.

## 7. Artifact manifest

The native library manifest (`NAME.manifest.json`), **schema 2**, is the
artifact contract. Its new members (observed, the 2048 library's):

```json
"compiler": {"frontEnd": "2eaaf73f78781403-5254432", "runtimeAbi": "d554d5ff4c234348"},
"sha256": {"static": "...", "shared": "...", "header": "..."},
"reentrancy": "refused", "callbacks": [],
"ownership": {
  "instance": {"owner": "caller", "create": "game_create", "release": "game_destroy"},
  "str-argument": {"owner": "caller", "lifetime": "call", "copied": true, "null": "length-zero"},
  "str-result": {"owner": "caller", "release": "game_bytes_release", "terminated": "nul-after-length", "survives": "..."},
  "error": {"owner": "caller", "release": "game_error_release", "survives": "..."}},
...
{"name": "move", "symbol": "game_move",
 "botlish": "move(state: str, direction_code: int) -> str errors InvalidDirection, InvalidState",
 "params": [{"name": "state", "type": "str", "c": ["const uint8_t *", "size_t"], "ownership": "borrowed", "lifetime": "call"},
            {"name": "direction_code", "type": "int", "c": ["int64_t"], "ownership": "value"}],
 "result": {"type": "str", "c": "game_bytes *", "ownership": "owned", "release": "game_bytes_release"},
 "error": {"c": "game_error **", "nullable": true, "ownership": "owned", "release": "game_error_release"},
 "errors": [{"name": "InvalidDirection", "fields": []}, {"name": "InvalidState", "fields": []}]}
```

* **Completeness for a C caller** (section 11): numeric widths and
  signedness (`int64_t`), Booleans (`bool`), str ownership and lifetime,
  output allocation and release, the error contract (statuses, identity,
  typed fields), nullability, instance lifecycle, thread affinity and
  reentrancy, and the absence of callbacks. An export the ABI cannot carry
  is already refused at compilation (EXPORT-SIGNATURE,
  NATIVE-LIBRARY-MILESTONE-1.md); nothing incomplete is emitted.
* **Bound to its build:** each file's SHA-256 (coreutils' `sha256sum` at its
  system path: library mode is Linux glibc's). `botlish tool -artifact`
  checks schema, kind, target and every digest (`et-tool-artifact-checked`:
  another build's archive under the manifest is TOOL-ARTIFACT, "the manifest
  belongs to another build of a").
* **Deterministic:** two builds of one program give byte-identical
  manifests and libraries (`nl-manifest`; observed: `cmp` of both).
* **No HIR.** Both sample tools are C programs that read the request and
  the manifest and nothing else; `rnpackage.tcl` now reads schemas 1 and 2.

**Library mode from the single executable.** `native::library` links a
library's object with `libbotlish_native.a` beside the driver, else with
`libbotlish_runtime.a` -- the same runtime plus an executable's C `main`,
whose archive member a relocatable link never pulls in (observed: `nm`
shows no `main`; the static libraries are byte-identical in size).
single/main.tcl counts `-emit-native-library` as a run that may link, so
the runtime archive is installed for it (`et-library-runtime-archive`).

## 8. Target support packages

    botlish -emit-native-executable -target-support botlish_target_linux hello.bot
    target support: botlish_target_linux (linux-x86_64, runtime .../.bot_modules/.targets/linux-x86_64/botlish_target_linux/runtime/libbotlish_runtime.a)
    executable: hello

The package (`audit/external-tools/packages/botlish_target_linux`, built by
`tools/packages.sh` from a native build) is target-aware (schema 2): its
linux-x86_64 view holds the archive, declared a bundled static library, and

```json
{
  "schema": 1,
  "kind": "botlish-target-support",
  "target": "linux-x86_64",
  "triple": "x86_64-unknown-linux-gnu",
  "linker": "system",
  "runtime": {"archive": "runtime/libbotlish_runtime.a", "abi": "d554d5ff4c234348"},
  "systemLibraries": ["-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc"]
}
```

**Selection is explicit and target-relative**: only `-target-support NAME`
reads it (`et-target-support-explicit`: an installed one changes nothing
otherwise), from the compilation target's package tree, never the host's
(`et-target-support-target-tree`: with `-target linux-aarch64`, the AArch64
tree's package is selected and accepted, then the driver refuses to make
another host's machine code).

**Compatibility, before any linker runs** (`native/support.tcl`):

| refusal | observed by |
|---|---|
| MISSING (not installed; removed: never the driver's own archive instead) | `et-target-support-missing`, `-removed`; clean room C |
| DESCRIPTOR (no descriptor: no support package; another schema; an unknown member) | `-no-descriptor`, `-refusals` |
| UNKNOWN-TARGET (`android-aarch64`: no code generation) | `-refusals` |
| TARGET, TRIPLE, LINKER, LIBRARIES | `-refusals` |
| ABI (descriptor or archive fingerprint not the driver's) | `-refusals`, `-archive-identity` |
| RUNTIME (outside the package; no identity record; another triple) | `-refusals`, `-archive-identity` |

**The identity record.** The runtime archive now carries a static, a
160-byte record `BOTLISH-RUNTIME-IDENTITY v1 x86_64-unknown-linux-gnu
d554d5ff4c234348` (native/runtime-archive: its build script's TARGET, and
`aotimage::ABI_FINGERPRINT`, the fingerprint made a compile-time constant
over the unchanged words, `abi_fingerprint_constant_is_the_digest_of_its_words`).
It occurs exactly once in `libbotlish_runtime.a` and nowhere in the driver
or `libbotlish_native.a` (observed). The compiler reads it from the
archive's bytes without running anything: an archive whose record names
`x86_64-linux-android` -- the same architecture, another OS and C library
ABI -- is refused for linux-x86_64 ("the same architecture, another
operating system or C library ABI, whose runtime is never
interchangeable"), whatever its descriptor claims. That is the Android
case of the brief made concrete on the host the tests run on.

**Three failure classes stay distinct**: unknown target
(UNKNOWN-TARGET), known target without its package (MISSING), package
present but host toolchain missing -- the driver's own `NATIVE AOT
TOOLCHAIN` (`et-target-support-toolchain`: no TARGET-SUPPORT word in it).
The driver links the archive with the system linker (`--runtime-archive`;
`BOTLISH_NATIVE_LINKER=rustc` is refused, never ignored), checks its
object format and architecture again, and the executable's startup the
program record's fingerprint. The link ignores `BOTLISH_NATIVE_RUNTIME`
when a package is named (`et-target-support-links` sets it to a missing
file).

## 9. Dependency resolution

Tool and target support packages are resolved by the one graph like any
package (static: `pm/graph.tcl` is unchanged, and nothing in `pm/tools.tcl`
resolves). `et-tool-lock-binding` (observed): a tool package locking
`shared_lib 0.1.0` added to a project that locks `shared_lib 0.2.0` is a
DEPENDENCY-CONFLICT naming both locks, and nothing is installed; where the
locks agree, one `shared_lib` instance serves both and the tool runs. A tool
command never resolves, downloads or installs: it runs what the graph
installed, and holds the project's lock while it runs, so a tool cannot run
a package operation on its own project. No peer dependencies, no overrides;
the mutants `lock-weakened` and `tool-deps-apart` (section 15) are the
loopholes this rules out.

## 10. Cleanroom experiment

`audit/external-tools/cleanroom/cleanroom.sh BOTLISH REPO RESULTS`: a fresh
`/tmp` directory with a copy of the single executable, the packed artifacts
(`tools/packages.sh`, which the single executable itself packs in CI) and
the experiments' inputs; `env -i HOME=ROOM/home PATH=/usr/bin:/bin
LANG=C.UTF-8 TMPDIR=ROOM/tmp`; the working directory the room's; the whole
run under `strace -f`. Observed with the single executable built from this
change (`single/build.sh`, 14,855,760 bytes), results in
`audit/external-tools/results/cleanroom.txt`:

    PASS A ordinary package imported and run
    PASS B installing, verifying, compiling and listing ran no tool
    PASS B the installed program is not executable
    PASS B tool ran exactly the named tool once
    PASS B arguments arrived exactly
    PASS B a tool's exit status is the command's
    PASS C an executable linked with the target support package's runtime
    PASS C a removed target support package is refused, precisely
    PASS D a generated C caller of the real library compiled and ran
    PASS E a host module's adapter compiled into a host and ran
    PASS 2048 the C caller played as the interpreter
    PASS 2048 the host module played as the interpreter
    PASS the run reached nothing of the checkout (/home/user/botlish)
    PASS the run used no Tcl but the single file's own

B's probe package is packed inside the room by the single executable. The
trace check refuses any access to the checkout and any system Tcl library
or `tclsh` execution. CI: the single-executable workflow's build job runs
`packages.sh` (packing with the built executable) and the clean room after
the C FFI smoke test. Docker is not available in this container; the room
is a scrubbed process environment with strace evidence, not a container
image (the raven clean room's is).

## 11. 2048 experiment

`audit/external-tools/2048/engine.bot` is a C ABI over the engine of
`examples/games/2048/game2048.bot`, which is installed unchanged as the
ordinary package `game2048`. The C ABI carries int, bool, Float64 and str;
a game crosses as its state text, `"SCORE C0 ... C15"`, and the exports are
`new_game`, `move`, `changes`, `spawn`, `first_empty`, `spawn_first`,
`score` and `over`, with declared errors `InvalidState`,
`InvalidDirection`, `InvalidSpawn` and the engine's own
`game2048::CellOccupied`. It compiles warning-free under `-warnings error`
(no integer division exists, so a row is found by comparison).

* **D (C caller).** `emit-caller` generates `game_caller.c` and
  `game_caller.build.json` from the manifest: every parameter's C type, the
  result's out-parameter, the release functions, from the manifest; it
  refuses a C ABI version, a type or an ownership it does not know. It is
  compiled with `-std=c99 -Wall -Wextra -Werror` against the header and the
  static archive and fed 160 deterministic steps (a linear congruential
  sequence): its 321 states equal the interpreter's, element for element,
  and the final score is positive (merges happened). Its error lines carry
  the contracts as data:

      move	error	declared	InvalidState
      move	error	declared	InvalidDirection
      spawn	error	declared	game2048::CellOccupied
      spawn	error	declared	InvalidSpawn

  Every str result is copied and released with `game_bytes_release`, every
  error with `game_error_release`, as the manifest says.
* **E (host module).** `host-module` generates `src/NativeGame.ts` (a spec
  that Node's type stripping loads: `newGame move changes spawn firstEmpty
  spawnFirst score over Game`), `adapter/game_host.{h,c}`, `package.json`
  (naming the library, the manifest's SHA-256 and the runtime ABI),
  `CMakeLists.txt` (built with CMake and Ninja here) and a copy of the
  library. A host harness calls the adapter with JavaScript-like values: 80
  steps equal the interpreter's states, and the host's own policy holds --
  `BotlishError InvalidState`, `TypeError ARGUMENT-TYPE`, `RangeError
  NUMBER-NOT-SAFE-INTEGER` for 1.5 and for 2^53 + 1, `TypeError
  ARGUMENT-COUNT`, `TypeError NO-SUCH-METHOD`.
* **Determinism.** Two runs of both tools on one manifest give
  byte-identical outputs (`et-tools-deterministic`: 9 files), and nothing
  they generate names the checkout (`et-tool-output-self-contained`).
* **The oracle** is the ordinary interpreter (`-backend interp`) running
  `oracle.bot`, which imports the same `engine` module and plays the same
  steps.

## 12. Security boundary

A tool is a program run with the user's permissions: no sandbox, no
capability restriction, and process isolation alone keeps nothing from
reading files or the network (BOTLISH-TOOLS.md, section 10). What is
guaranteed, and tested:

* no package-manager operation, import, compilation or listing runs a
  package's program (`et-install-runs-nothing`: the probe's marker file
  stays empty through add, verify, install, tools, a run and `-check` of a
  program importing it, and remove); no installed file is executable (mode
  0644, observed);
* `tool` runs exactly the program it resolved, after checking its bytes
  against the installation record, never a fallback
  (`et-tool-runs-only-the-named-one`, `et-tool-program-changed`,
  `et-tool-program-missing`);
* a tool's words are never shell text;
* a tool that changes the installation fails the command, and cannot run a
  package operation on its project while it runs.

The request holds no environment value. Signed tool packages and a
separate authority decision before a tool runs remain PM-4's and PM-7's.

## 13. Compatibility

* Ordinary compilations are unchanged: the compiler loads nothing new on
  their path but `native/support.tcl`'s procedures (defined, not run), and
  reads a support descriptor only for `-target-support`.
* `botlish.json` schemas 1-3 read and write exactly as before; only a
  descriptor declaring tools needs schema 4. `pm-descriptor-schema` now
  pins schema 5 as unsupported and the messages' "1, 2, 3 and 4".
* The native library's C ABI, header and library bytes are unchanged; the
  manifest is schema 2 (every schema 1 member kept; `nl-manifest` updated).
* The runtime ABI fingerprint's value is unchanged by this milestone
  (`d554d5ff4c234348` before and after on the branch: a constant over the
  same words). Merging main brought the thread milestone's runtime helpers,
  which are fingerprint inputs: the merged driver reports
  `e6c1492eceebb13c`, still the digest of its words
  (`abi_fingerprint_constant_is_the_digest_of_its_words`). The observed
  records in this report and in audit/external-tools/results/ are the
  branch's, before that merge. The driver's `runtime-abi` command and
  `--runtime-archive` option are new; the runtime archive gained one
  160-byte static.
* Existing packages (sdl3, sdlkit, raven, event_loop_linux) are schema 2/3
  and untouched.
* The compiler gained no Android or React Native dependency.

## 14. Tests

`tests/external-tools.test`, 48 tests (Linux x86-64; the AArch64 fixtures
need clang and lld, the TypeScript check Node): the manifest, library mode
with the runtime archive, schema 4's validation and canonical form, the
pack's program checks, activation, resolution, the process boundary, the
request, inputs, every target support refusal, the target tree, the
toolchain distinction, both 2048 experiments, determinism. Observed:

    external-tools.test:	Total	48	Passed	48	Skipped	0	Failed	0      (1 min 46 s)

Runs after the change, observed on this container (Linux x86-64, Tcl
9.0.1, rustc 1.97, each with a private `-tmpdir`):

| run | result |
|---|---|
| `tests/external-tools.test` | 48 / 48 |
| `tests/native-library.test` | 28 / 28 (`nl-manifest` now expects schema 2) |
| `tests/package-manager.test` | 86 / 86 (`pm-descriptor-schema`: schema 4 read, 5 refused; `pm-no-network-in-sources`: the one start of a tool, in `pm::tools::Spawn`, allowed beside the SHA tools and `kill -0`) |
| `tests/package-native.test` | 38 / 39, 1 skipped (its constraint) |
| `tests/package-authoring.test` | 29 / 30, 1 skipped (its constraint) |
| `tests/bot-modules.test` | 68 / 69, 1 skipped |
| `tests/system-linker.test` | 15 / 15 (the driver's runtime archive selection) |
| `tests/main-cli.test` | 72 / 72 (`-target-support` in `cliOptions`, `cli.options` and main.tcl's header; usage lines within 80 columns) |
| `cargo test --lib -- aotimage program` | 13 / 13 (with the two new tests of the constant fingerprint and the identity record) |
| `cargo test --bin botlish-native -- aot::` | 29 / 29 |
| `tools/compilerpedia.tcl check` | 0 problems (the new topics `cli.tools`, `backend.target-support`, `error.native-target-support`) |
| `tools/mutant-catalogs.tcl` | 89 catalogs, 0 problems, after six mutants of other catalogs were updated (section 15) |
| `python3 -I tools/ci/test_runs.py` | 44 / 44 (the workflow change) |
| the native-aot harness's unmutated baseline | ok: `cargo test --bin botlish-native aot` and `--lib aotimage program`, `tests/native-executable.test`, `argv.test`'s standalone tests, `workload-2048.test`'s bench executable, `tests/system-linker.test`, `tests/main-thread-startup.test`, `tests/platform/aot-facts.tcl` |
| `audit/golden/migration/merge.tcl -check 1` | clean: 48 census rows for the new tests |
| the clean room (section 10) | 14 / 14 |

CI: the single-executable workflow's build job now runs `packages.sh` with
the built executable and the clean room under strace (section 10);
tests.yml runs `tests/external-tools.test` with the whole Tcl suite (its
tests need a Linux x86-64 host and cc; the AArch64 fixtures clang and lld,
the TypeScript check a Node that strips types, else they are skipped).

## 15. Mutation testing

`audit/external-tools/tools/mutate.tcl` applies each mutant of
`mutants.txt` to a private copy and runs the tests its `!!` line names
(`-match`); a mutant is killed only when a named detector fails, against a
baseline in which every detector passes. Observed: **18 / 18 killed**, each
by a named detector (5 min 37 s):

| mutant | the bug | killed by |
|---|---|---|
| `run-on-install` | a tool's program runs when its package is installed (a post-install hook) | `et-install-runs-nothing` |
| `run-on-import` | a package's tool runs when a program imports it | `et-install-runs-nothing` |
| `ambiguous-first` | an ambiguous short name runs the first package's tool | `et-tool-ambiguous` |
| `shell-concatenated` | the words are joined into one shell command line | `et-tool-argv-exact` |
| `protocol-unchecked` | an unknown protocol is run as if spoken | `et-tool-protocol` |
| `missing-program-succeeds` | a missing program "runs" successfully | `et-tool-program-missing` |
| `exit-ignored` | a tool's exit status becomes success | `et-tool-exit-status` |
| `support-host-tree` | the support package is read from the host's tree | `et-target-support-target-tree` |
| `support-any-os` | an archive of another OS ABI, same architecture, is accepted (Linux's for Android) | `et-target-support-archive-identity` |
| `support-abi-ignored` | the runtime ABI fingerprints are not compared | `et-target-support-refusals`, `-archive-identity` |
| `support-fallback` | a missing support package falls back to the driver's own archive | `et-target-support-missing`, `-removed` |
| `lock-weakened` | disagreeing locks no longer conflict | `et-tool-lock-binding` |
| `tool-deps-apart` | a tool package's dependencies are resolved apart from the graph | `et-tool-lock-binding` |
| `manifest-no-ownership` | the manifest states no ownership of a result | `et-manifest-binds-build`, `et-2048-caller` |
| `manifest-other-build` | a manifest is accepted for another build's files | `et-tool-artifact-checked` |
| `modification-unchecked` | a tool may change the installed packages | `et-tool-modified` |
| `helper-from-checkout` | the generated caller includes a helper from the generator's own tree | `et-tool-output-self-contained` |
| `guessed-signature` | the generated caller guesses every result is an `int64_t` | `et-2048-caller` |

No survivor. `support-abi-ignored` has two edits (static): with only the
descriptor's comparison removed, the archive's record would still disagree
with the descriptor -- the two checks guard each other.

**Other catalogs.** Six mutants of other harnesses edited code this change
rewrote and no longer applied (`tools/mutant-catalogs.tcl`); each was
updated to the current code, keeping its rule:
`single-executable`'s `package-commands-install-native` (the package
commands now include `tool` and `tools`: **killed**, by smoke-test.sh's
"a package command installed the native backend"), and `native-aot`'s
`sys-runtime-variable-ignored`, `sys-failed-link-replaces`,
`cli-drops-main-thread`, `api-replaces-main-with-worker` and
`fingerprint-ignores-record` (the fingerprint's words are now a constant
array, whose length the mutant shortens with them): **5 / 5 killed** by
their harness (`audit/native-aot/tools/mutate.tcl -only ...`, each a
rebuilt private native backend): `system-linker-runtime-failures`,
`system-linker-link-failures`, `mts-cli-refused`, `mts-api-refused` (with
aot-facts.tcl and native-status.tcl) and the Rust test
`abi_fingerprint_covers_the_program_record`.

## 16. Performance and footprint

Observed on this container (4 cores; medians; the single executables of
main `f2787af` and of this change, built by `single/build.sh`):

| measure | before | after |
|---|---:|---:|
| single executable | 14,832,650 bytes | 14,855,736 bytes (+23,086, +0.16%: pm/tools.tcl, native/support.tcl, the topics) |
| `botlish -version` (15 runs) | 128 ms | 131 ms |
| a small program, interpreted (9 runs) | 166 ms | 159 ms |
| `botlish tools` (one tool package) | -- | 24 ms |
| `botlish tool probe ok` | -- | 34 ms |
| the probe program run directly | -- | 2 ms |
| `-emit-native-library` of the 2048 engine, single executable | refused | 1.4 s |
| the manifest's three SHA-256s (13.9 MB archive, 0.9 MB library, header) | -- | 16 ms |
| runtime archive | -- | +160 bytes (the identity record) |

The startup differences are within run-to-run noise: an ordinary
invocation loads nothing new but a few procedure definitions, and the
package commands load `pm/tools.tcl` with the rest of `pm/`. A tool
invocation costs about 32 ms over the program itself: loading the package
manager, reading the installed descriptors, checking the program against
the record, copying it, writing the request and snapshotting the
installation twice -- independent of the tool, and small beside any build a
tool performs. The packages: `abi_tools` 17,222 bytes, `hostgen` 17,891,
`game2048` 3,067, `botlish_target_linux` 9,044,281 (39.9 MB unpacked: the
runtime archive). The test file takes 1 min 46 s, the clean room 53 s.

## 17. Remaining limitations

* **Hosts.** Tools and target support packages run where the package
  manager and the system linker do; tested on Linux x86-64 only. On Windows
  a redirection-like argument is refused (Tcl's exec has no escape), and
  macOS and Windows host programs are inspected (Mach-O, PE) but no tool
  for them was built or run.
* **Inputs.** Protocol 1 knows one artifact kind, `native-library`;
  executables, objects and HIR interchange are not tool inputs. A tool that
  needs them runs the compiler itself (the request's `compiler.command`).
* **Target support** supplies the system linker's runtime archive only:
  no startup objects, no stub for the stub linker, no per-target C runtime,
  no minimum platform/API version (Android's `minSdkVersion` would be one).
  It cannot add a target: the compiler generates machine code for the
  host's target only (NATIVE TARGET), so a non-host support package is
  selected and checked but not yet linked.
* **The fingerprint of an archive** is read from its identity record; an
  archive built before this milestone has none and is refused. A record a
  forged archive states falsely is caught at startup by the program
  record's fingerprint, not before.
* **No sandbox, no signatures, no authority prompt** (section 12).
* **Scripts.** A tool program is a native executable; protocol 1 discovers
  no interpreter (a Tcl or JavaScript tool ships as an executable that
  embeds its runtime).
* **Library mode** is Linux glibc's (x86_64, aarch64), as before.

## 18. Next milestones

1. **Android target pack** (generic target support work, not application
   logic): an `android-aarch64` target row (Bionic, the NDK's triple), the
   runtime built for it with its identity record, Cranelift code for a
   non-host target and a cross link (`check_host` split into "may emit" and
   "may run": REACT-NATIVE-TARGET-CENSUS.md, section 7), the NDK as the
   host toolchain the system linker names. The selection and refusals of
   section 8 apply unchanged; the minimum API level becomes a descriptor
   fact.
2. **Android 2048** (`botlish-android`, an external tool package): consumes
   the 2048 library built for android-aarch64 with `-target-support`,
   generates the Activity/JNI glue and Gradle files, invokes Gradle
   explicitly, produces an APK. It depends on the target pack as an ordinary
   dependency.
3. **React Native 2048** (`botlish-react-native`): `host-module`'s shape,
   grown into the census's package model -- a TurboModule spec, a JSI C++
   adapter over the same manifest, CMake and podspec files, Codegen run from
   the app's own `node_modules`, an optional hook as generated output.
4. **Authority** (PM-4, PM-7B): signed tool packages, and a recorded,
   explicit decision before a newly installed tool's first run.
