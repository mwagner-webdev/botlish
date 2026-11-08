# External tools, protocol 1

The normative specification of external tools
(EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md): how a package
declares a tool, how `botlish tool` resolves and runs it, the request a tool
receives, the diagnostics and report it may produce, and the native library
manifest (schema 2) a tool consumes. The implementation is `pm/tools.tcl`
(declaration, resolution, invocation), `native/library.tcl`'s `Manifest`
(the artifact manifest) and `native/support.tcl` (target support packages,
section 9); `tests/external-tools.test` checks every rule below.

Contents:

* [1. What a tool is](#1-what-a-tool-is)
* [2. The declaration](#2-the-declaration)
* [3. When a tool runs](#3-when-a-tool-runs)
* [4. Resolution](#4-resolution)
* [5. The invocation](#5-the-invocation)
* [6. The request](#6-the-request)
* [7. Diagnostics, the outcome and the report](#7-diagnostics-the-outcome-and-the-report)
* [8. The native library manifest, schema 2](#8-the-native-library-manifest-schema-2)
* [9. Target support packages](#9-target-support-packages)
* [10. Security](#10-security)
* [11. Evolution](#11-evolution)

## 1. What a tool is

A tool is a program an ordinary package carries, which a developer runs
explicitly to build or integrate something outside Botlish from what the
compiler produces: a C caller of a native library, an Android project, a
React Native module. It runs in an operating-system process of its own; it
never runs inside the compiler, never changes what a program means, and has
no access to the compiler's state. What it may rely on is documented here:
the request, and the artifacts the request names (section 8) -- never the
HIR, the compiler's internals or a checkout.

## 2. The declaration

A package declares its tools in `botlish.json` schema 4 (BOTLISH-JSON.md,
section 14):

    "tools": {
      TOOL: {
        "protocol": 1,
        "summary": "one line",
        "programs": {HOST: PATH, ...},
        "inputs": ["native-library"],          optional
        "environment": ["ANDROID_HOME", ...]    optional
      }, ...
    }

* **TOOL** is `[a-z][a-z0-9-]{0,63}`.
* **protocol** is the tool protocol the tool speaks: a positive integer.
  Any is accepted in a descriptor (a package that carries a tool of a newer
  protocol still installs); a tool command refuses a protocol it does not
  speak (section 4).
* **summary** is one line of 1 to 300 characters, without control
  characters.
* **programs** maps each host the tool runs on -- a compilation target's
  name, exactly as `-target` takes it -- to the archive path of its program:
  a native executable of that host (an ELF executable or position-
  independent executable of the host's machine, a Mach-O `MH_EXECUTE` of its
  CPU, a PE executable that is no DLL). The package manager checks each
  program when the package is packed and whenever its artifact is acquired,
  reading its bytes (`pm/binary.tcl`), never running it. A program is no
  script: protocol 1 runs native executables only, and discovers no
  interpreter.
* **inputs** are the artifact kinds the tool requires (protocol 1:
  `native-library`); a tool command refuses to run it without one.
* **environment** names the environment variables the tool reads, so that
  a developer is told (`tools`) and the request records whether each is
  set -- never its value.

Any other key is an error: there is no script, hook, install step, entry
point or permission key. A schema 1, 2 or 3 file using `tools` is refused
saying it is a schema 4 key. The author's audit (`native audit`, a pack's)
counts tool programs as declared native files.

## 3. When a tool runs

Only when `botlish tool` names it. Installing, updating, verifying or
removing the package, preparing a target view, importing its modules,
compiling (`-check`, a run, a build) a program that uses them, and listing
the project's tools (`botlish tools`) never run any program of a package. An
installed package's files are never executable (BOTPKG-FORMAT.md, section
10): a tool's program becomes an executable file only in the private
directory a tool command copies it into (section 5).

## 4. Resolution

    botlish tool [-project DIR] -out DIR [-artifact MANIFEST]... [-target T]
                 [-target-support NAME] [-report FILE] TOOL [ARG...]
    botlish tools [-project DIR]

The tool command's own options come before TOOL; every word after TOOL is
the tool's (section 5). Resolution reads the project's installation (the
package manager's record; a project without one has no tools,
TOOL-NOT-INSTALLED) and each installed package's own `botlish.json`, and
refuses, before anything runs:

| refusal | when |
|---|---|
| TOOL-UNKNOWN | no package of the project declares TOOL (or a qualified name's package or tool does not exist) |
| TOOL-AMBIGUOUS | a short name two or more of the project's dependencies declare: name one, `PACKAGE:TOOL`; no package is preferred |
| TOOL-NOT-DIRECT | only a package that is not one of the project's own dependencies (another package's dependency) declares it: only the project's direct dependencies provide the tools it runs |
| TOOL-PROTOCOL | the tool speaks a protocol this Botlish does not (protocol 1 only), or requires an input kind its protocol does not have |
| TOOL-HOST | the tool has no program for this host; the hosts it runs on are named |
| TOOL-PROGRAM | the installed program is missing, is not the file the installation record holds (size and CRC-32: it was changed), or is not an executable of this host (an editable dependency's program is whatever its directory holds: it has no record) |
| TOOL-INPUT | a required input kind has no `-artifact` |
| TOOL-ARTIFACT | an `-artifact` is not a schema 2 native library manifest, describes a library of another target than `-target`, or a file it describes is missing or not the one it describes (SHA-256) |
| TOOL-TARGET-SUPPORT | `-target-support NAME` names no installed dependency of the project with a support descriptor for the target |
| TOOL-OUTPUT | `-out` lies inside the project's `.bot_modules` (the installation, which no tool writes), or is no directory |
| TOOL-EXEC | the program cannot be started (the temporary directory does not allow execution; no `/bin/sh`) |
| TOOL-ARGUMENT | Windows only: a word Tcl's exec reads as a redirection (below) |

The **host** is the machine running the command (`pm::target::host`); the
program run is the host's, whatever `-target` names: the host runs the
tool, the target runs what the tool builds. `-target` (default: the host)
is the compilation target the request states and the artifacts are checked
against.

## 5. The invocation

The tool command locks the project (the package manager's lock: no package
operation runs meanwhile, the tool's own included), copies the program
into a private temporary directory (`file tempdir`: `TMPDIR`) and makes it
executable there, writes the request (section 6) beside it, and starts it:

* **arguments:** the words after TOOL, each exactly as given -- spaces,
  quotes, `$`, `;`, `*`, an empty word, a word starting with `<`, `>`, `|`
  or `2>`, a last `&`. On Unix the program is started through a fixed
  `/bin/sh` trampoline: every word is a positional parameter, prefixed with
  `x` so that Tcl's exec reads none as a redirection and stripped by the
  shell before `exec "$@"`; no word is ever shell text. On Windows Tcl's
  exec quotes each word for the C runtime's parser, and a word it would read
  as a redirection is TOOL-ARGUMENT (the request holds every argument
  exactly);
* **environment:** the command's own, plus `BOTLISH_TOOL_REQUEST`, the
  request's path;
* **working directory:** the command's;
* **standard streams:** the command's own: the tool writes to the
  terminal, or wherever the command's output goes, as it writes.

When it ends, the installation is checked against the record it had before
(every installed package's files, every target view, the record and the
graph): a tool that changed any of them fails the command, TOOL-MODIFIED,
whatever it returned. The temporary directory is removed.

## 6. The request

`BOTLISH_TOOL_REQUEST` names a UTF-8 JSON object, written by the tool
command for this invocation:

| member | value |
|---|---|
| `protocol` | `1` |
| `kind` | `"botlish-tool-request"` |
| `tool` | `{name, package, version, directory, program}`: the tool, its package's version, the installed package's directory (its data files are there) and the program's temporary copy |
| `compiler` | `{revision, command}`: the packaged compiler's source revision (`null` in a checkout), and the argument vector that runs this compiler (`["/path/botlish"]`, or `["/usr/bin/tclsh9.0", "/path/main.tcl"]`): a tool that compiles runs it, with arguments of its own, as a subprocess |
| `project` | the project's absolute path |
| `host` | the host (a target name) |
| `target` | the compilation target (`-target`, default the host) |
| `output` | the absolute output directory (`-out`, created) |
| `artifacts` | `[{kind, manifest, library, sha256}]`: each `-artifact`, checked (section 4): the manifest's absolute path, the library's name and the manifest's own SHA-256 |
| `targetSupport` | `null`, or `{package, version, directory}` for `-target-support NAME` |
| `environment` | `[{name, set}]`: each variable the declaration names, whether it is set |
| `arguments` | the words after TOOL, exactly |
| `diagnostics` | the path where the tool may write its structured diagnostics (section 7) |

Paths are absolute, in the host's own spelling (UTF-8). The request holds
no time, no secret and no environment variable's value; its paths are
those of this invocation (a tool's output should not depend on them).
A tool refuses a request whose `protocol` it does not speak.

## 7. Diagnostics, the outcome and the report

A tool reports to people on its standard error, in its own words. It may
also write, to the request's `diagnostics` path,

    {"diagnostics": [{"severity": "error"|"warning"|"note", "code": TEXT,
                      "message": TEXT, "file": PATH, "line": N, "column": N}]}

(`file`, `line` and `column` optional), which the tool command prints after
the tool ends, one line each (`PACKAGE:TOOL: SEVERITY: FILE:LINE:COLUMN:
MESSAGE (CODE)`), and records in the report. A file that is no such object
is one note saying so.

The command's exit status is the tool's, unchanged, when it exited (a line
`tool PACKAGE:TOOL (PACKAGE VERSION) exited with status N` follows a
non-zero one); 1 when it was ended by a signal (TOOL-CRASHED, naming the
signal), when it changed the installation (TOOL-MODIFIED; its own non-zero
status otherwise) and when it was refused before running (`error: MESSAGE
(PM TOOL-...)`); 2 for a malformed command line. `-report FILE` writes the
outcome as JSON, also for a refusal:

| member | value |
|---|---|
| `protocol`, `kind` | `1`, `"botlish-tool-report"` |
| `tool`, `package`, `version` | the tool resolved (`PACKAGE:TOOL`), or `null` |
| `stage` | `refused` (it did not run), `completed` (status 0), `failed` (another status), `crashed` (a signal), `modified` (it changed the installation) |
| `code`, `message` | the refusal's (`TOOL-AMBIGUOUS`, ...), or `null` |
| `exit`, `signal` | the status, or the signal's name (`SIGABRT`), or `null` |
| `diagnostics` | `[{severity, code, message, location}]` |
| `packagesChanged` | what the tool changed in the installation |

Package-manager refusals are never compiler diagnostics, and a tool's
failure is never reported as the compiler's.

## 8. The native library manifest, schema 2

`main.tcl -emit-native-library NAME` (NATIVE-LIBRARY-MILESTONE-1.md) writes
`NAME.manifest.json` beside the library: the C interface as data, from the
compiler's facts, never from symbols or source. Schema 2 keeps every member
of schema 1 and adds what makes it an artifact contract a tool can rely on
without the HIR:

| member | value |
|---|---|
| `compiler` | `{frontEnd, runtimeAbi}`: the front end's fingerprint (HIR-INTERCHANGE.md) and the runtime ABI fingerprint of the driver that built the library (`botlish-native runtime-abi`) |
| `sha256` | `{static, shared, header}`: each artifact file's SHA-256 (`shared` `null` without one): the build the manifest describes |
| `reentrancy` | `"refused"`: a call made while another runs on the instance is REENTRANT-CALL |
| `callbacks` | `[]`: a library export takes no callback |
| `ownership` | the conventions as data: `instance` (the caller owns it; `create`, `release`), `str-argument` (borrowed for the call, copied before it returns; NULL only with length 0), `str-result` (the caller owns it; `release`: `NAME_bytes_release`; NUL-terminated after its length; survives later calls and the instance), `error` (the caller owns it; `release`: `NAME_error_release`) |
| each export's `params[i].ownership` | `value` (a scalar) or `borrowed` (a str, `lifetime: "call"`) |
| each export's `result.ownership` | `value`, `none` (unit) or `owned` with its `release` function |
| each export's `error` | `{c: "NAME_error **", nullable: true, ownership: "owned", release: "NAME_error_release"}` |
| `targetSupport` | present only for a library linked with a target support package (section 9, schema 2): `{package, runtimeAbi, platform, toolchain}` -- the package, its runtime ABI fingerprint, the platform version it states (`{minimumApi: 21}` for android-aarch64) and the toolchain that linked it (`{name, revision}`). `target` is then the library's target, `link` the system libraries its runtime is linked with (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md) |

Its keys are written in a fixed order and two builds of one program give
the same bytes. A consumer checks `schema` (a schema 1 manifest records
neither the files nor ownership: rebuild the library), `kind`, `target` and
`abi` (the C ABI version, whose runtime API -- `create`, `destroy`, the
error accessors -- it knows; `api` lists every function), and that each file
it uses has the SHA-256 the manifest records; it reads every C type and every
release function from the manifest and refuses, rather than guesses, a type
or an ownership it does not know. `botlish tool -artifact` makes these
checks (section 4) before a tool runs.

## 9. Target support packages

A target support package supplies, for a target the compiler already
generates code for, the runtime artifacts an executable of that target is
linked with: today the runtime archive the system linker links
(`libbotlish_runtime.a`, native/runtime-archive). It is an ordinary package
(the experiment's is target-aware, schema 2, its archive declared as a
bundled static library so that the package manager verifies its format and
architecture like any other) whose package root -- its target view's, for
a target-aware package -- holds

    botlish-target-support.json
    {"schema": 1, "kind": "botlish-target-support",
     "target": "linux-x86_64", "triple": "x86_64-unknown-linux-gnu",
     "linker": "system",
     "runtime": {"archive": "runtime/libbotlish_runtime.a", "abi": FINGERPRINT},
     "systemLibraries": ["-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc"]}

The compiler reads it when, and only when, a compilation names the package:
`main.tcl -emit-native-executable -target-support NAME FILE.bot`. It is
found in the application's package tree of the program's target
(`.bot_modules/.targets/TARGET/NAME`, else `.bot_modules/NAME`), never the
host's, and checked before any linker runs (`native/support.tcl`; each a
`{NATIVE TARGET-SUPPORT KIND}` refusal): MISSING, DESCRIPTOR (none, another
schema, an unknown or missing member), UNKNOWN-TARGET (no target this
compiler generates code for), TARGET (another target than the
compilation's), TRIPLE, LINKER (only `system`), RUNTIME (the archive missing,
outside the package, a link, without an identity record, or built for
another triple), ABI (the descriptor's or the archive's fingerprint is not
this driver's), LIBRARIES (not the system linker's for the target). The
archive's **identity record** -- `BOTLISH-RUNTIME-IDENTITY v1 TRIPLE
FINGERPRINT`, NUL-padded, a static of the runtime archive
(`runtime::aotimage::identity_record`, evaluated when the runtime is
compiled) -- is read from the archive's bytes without running any of it: an
archive built for another operating system or C library of the same
architecture (an Android/Bionic runtime for Linux/glibc, or the reverse) is
refused, whatever its descriptor says. The driver links it
(`--runtime-archive`) with the system linker, checks its object format and
architecture again, and the executable's startup the program record's
fingerprint. A missing C compiler driver is the link's own error
(`NATIVE ... TOOLCHAIN`), never a target support refusal. A tool given
`-target-support NAME` receives the package's directory in its request and
passes `-target-support NAME` to the compiler it runs.

### Schema 2: a native library's runtime and its toolchain

A schema 2 descriptor (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md) states
the artifact kinds it supplies and links them with a toolchain it declares
as data -- the way a native library of another target than the host's is
made (`main.tcl -target android-aarch64 -target-support NAME
-emit-native-library LIB FILE.bot`):

    {"schema": 2, "kind": "botlish-target-support",
     "target": "android-aarch64", "triple": "aarch64-linux-android",
     "artifacts": ["native-library"],
     "platform": {"minimumApi": 21},
     "runtime": {"archive": "runtime/libbotlish_runtime.a", "abi": FINGERPRINT,
                 "relocation": "pic"},
     "systemLibraries": ["-ldl", "-llog", "-lunwind", "-ldl", "-lm", "-lc"],
     "toolchain": {"name": "Android NDK", "root": "ANDROID_NDK_ROOT",
       "revision": {"file": "source.properties", "key": "Pkg.Revision", "minimum": "28.0"},
       "hosts": {"linux-x86_64": "toolchains/llvm/prebuilt/linux-x86_64"},
       "tools": {"cc": "bin/clang", "ld": "bin/ld.lld", "objcopy": "bin/llvm-objcopy", "ar": "bin/llvm-ar"},
       "platformLibraries": "sysroot/usr/lib/aarch64-linux-android/{api}"}}

* `artifacts`: what the package supplies; only `native-library` (a schema 1
  package supplies the system linker's `native-executable`). Asking a
  package for another kind is ARTIFACT.
* `platform`: required exactly for a target whose operating system has a
  platform version (Android: `minimumApi`, the API level the library is
  linked for, `--target=TRIPLE` + `N`), never below the compiler's floor
  for its runtime (21): API.
* `runtime.relocation`: `"pic"`, the only model a shared library's archive
  may have: PIC. A link that still fails for a relocation that is not
  position-independent is `{NATIVE LIBRARY PIC}`.
* `systemLibraries`: must equal the target's (the compiler's statement of
  rustc's `native-static-libs` for the runtime built for it): LIBRARIES.
  Never an added flag.
* `toolchain`: where the host's toolchain is -- the environment variable
  `root` names its directory (nothing is searched), `revision` the file and
  key of its revision and the minimum, `hosts` its directory per host, `tools`
  a C driver, an LLVM linker, objcopy and archiver relative to it, and
  `platformLibraries` the directory of an API level's libraries. Paths are
  relative, `/`-separated, without `.`, `..` or an empty segment. The
  compiler composes the arguments itself; the descriptor adds none.

The checks of schema 1 apply unchanged (TARGET, TRIPLE, RUNTIME with the
identity record, ABI), and none of them runs anything. A toolchain that is
missing, older than the minimum, without this host's directory or a tool is
`{NATIVE LIBRARY TOOLCHAIN}` -- the host's, never the package's -- and one
without the package's API level is API. The library is linked as the host's
is (a relocatable link with the runtime archive, symbols localized, the
archive, the shared library: `-z defs`, `-z text`, `--gc-sections`, 16 KiB
segment alignment on Android) and its shared object is checked from its
bytes (`native/elf.tcl`: machine, type, alignment, no text relocation, no
glibc symbol version, only the stated system libraries needed, exactly the
public functions exported), or removed (`{NATIVE LIBRARY ELF}`). A failed
link leaves no file of an earlier build under the new names.

## 10. Security

Running a tool is running a program: the tool command starts it with the
user's own permissions, its environment and its working directory. There is
no sandbox and no capability restriction, and process isolation does not
keep a tool from reading or writing the user's files or the network. What
this specification guarantees is narrower and checked:

* nothing but `tool` runs a package's program, and `tool` runs exactly the
  one it resolved, never another as a fallback;
* the program run is the file the installation record holds;
* a tool cannot change the project's installed packages without the command
  failing (TOOL-MODIFIED), and cannot run a package operation on the project
  while it runs (the project is locked);
* a tool's arguments are never shell text.

A package that declares a tool deserves the trust a developer gives any
program they run; installing it requires none.

## 11. Evolution

A later protocol is a new number. A tool of protocol N runs only on a
Botlish that speaks N; a request of protocol N is refused by a tool that
does not. Protocol 1 reserves no member for the next: a tool must read the
members it needs and may ignore others only within the same protocol
number. A new artifact kind (an object file, an executable) is a new input
kind and a new protocol. Signed tool packages and an authority decision
before a tool runs (PACKAGE-ECOSYSTEM-ROADMAP.md, PM-4 and PM-7) are later
milestones; executable compiler extensions inside the compiler process are
not provided at all.
