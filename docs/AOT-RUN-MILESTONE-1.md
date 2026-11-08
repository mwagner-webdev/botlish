# AOT-RUN-MILESTONE-1.md

One public command that compiles a Botlish program with the ordinary
ahead-of-time pipeline, links a standalone executable, runs it at once and
gives the command its arguments, standard streams, exit status and
signals: `main.tcl -aot-run FILE [-- ARG...]` (`botlish -aot-run ...` in a
packaged compiler). It needs no JIT, so it is how the macOS distribution,
whose native backend has none (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md),
runs a program natively; in every other build it sits beside the JIT,
which keeps its behavior.

> Running a program "natively" without a JIT means building exactly the
> executable `-emit-native-executable` builds and running that file: no
> second compilation pipeline, no in-process execution, no cache of
> executables, and nothing that can run an executable this command did not
> just link.

Every claim below is marked:

* **[executed]** run on the platform it is about: Linux x86-64 in this
  repository's sandbox (an Intel Xeon @ 2.10 GHz, 4 processors, Linux 6.18)
  or a GitHub Actions runner of the host named;
* **[inspected]** read from code, a tool's output or a log, without
  running the claim's program on that platform;
* **[pending]** a CI run on that platform that had not finished when this
  report was written (section 9 says which);
* **[not implemented]** absent, by design or for now.

The milestone's acceptance criteria:

| # | criterion | where |
|---|---|---|
| 1 | one public AOT-run command on the four native targets | section 2; tested on each (section 9) |
| 2 | the normal AOT compiler and linker | section 3 (`native::ExecutableText`, `emit_executable`); `aotr-equals-emitted` |
| 3 | no JIT dependency | section 3: the driver built without its JIT runs it (`aotr-no-jit-driver`) |
| 4 | arguments forwarded exactly | section 4 (`aotr-arguments`) |
| 5 | standard streams behave normally | section 4 (`aotr-streams`, `aotr-stdin`, `aotr-broken-pipe`) |
| 6 | exit status preserved by platform convention | section 5 |
| 7 | failures never execute stale binaries | section 6 (`aotr-rejected-never-runs`, `aotr-link-failure-never-runs`; the mutant `stale-executable-run`) |
| 8 | temporary artifacts safely managed | section 6 |
| 9 | concurrent invocations do not collide | section 6 (`aotr-concurrent`) |
| 10 | target and startup-policy limitations enforced | section 7 |
| 11 | macOS Cocoa through AOT-run on the main thread | section 7; MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 18 |
| 12 | existing AOT and JIT-capable builds unchanged | section 9 (the JIT build's tests on every host) |

## Contents

1. [Existing native execution modes](#1-existing-native-execution-modes)
2. [Chosen CLI contract](#2-chosen-cli-contract)
3. [AOT pipeline reuse](#3-aot-pipeline-reuse)
4. [Arguments and standard streams](#4-arguments-and-standard-streams)
5. [Exit and signal semantics](#5-exit-and-signal-semantics)
6. [Temporary artifacts](#6-temporary-artifacts)
7. [Target and startup policy](#7-target-and-startup-policy)
8. [Native FFI and link-plan behavior](#8-native-ffi-and-link-plan-behavior)
9. [Tests on each target](#9-tests-on-each-target)
10. [Positive controls and mutants](#10-positive-controls-and-mutants)
11. [Performance measurements](#11-performance-measurements)
12. [Limitations](#12-limitations)
13. [Exact files changed](#13-exact-files-changed)
14. [What to run when changing this](#14-what-to-run-when-changing-this)

## 1. Existing native execution modes

[inspected] Before this milestone a Botlish program ran natively in one of
four ways, all through the driver `botlish-native` (native/src/main.rs),
which main.tcl starts as a child process with the program's NIR:

| route | how it runs | JIT? |
|---|---|---|
| `-backend cranelift` / `cranelift-generic`, `run`'s native default | the driver's `run`: Cranelift's `JITModule` compiles the NIR into the driver's own memory and calls it (`execute`) | yes |
| `bench`, `batch`, `vms` (test and benchmark harnesses) | the same in-process code | yes |
| a program that calls C, on the routes above | the driver's `run_linked`: links an executable into a private directory and runs it in the driver protocol | no code generated in-process, but reached only through `run` |
| `-emit-native-executable` | the driver's `executable`: `ObjectModule`, the program object, the runtime, the link (`codegen::aot::emit_executable`) | no |

The interpreter (`interp`) and the Tcl compiler (`compile`) run in
main.tcl's own process and never involve the driver. `-emit-clif` and
`-emit-vcode` inspected the code through the JIT's module.

So the only native route that did not need the JIT built a file and
stopped; running it was the user's business, and the C-calling linked run
was a JIT command's way of running one kind of program.

## 2. Chosen CLI contract

```
main.tcl -aot-run [OPTION...] FILE [-- ARG...]
```

* FILE is one `.bot`, `.hir` or `.hirx` program (core IR text has no native
  path: refused). The words after `--` are the program's arguments, exactly;
  without `--` it has none. argv()[0] is FILE as typed, as for `run` and
  every backend's run.
* The options are those that decide how the program compiles and links:
  `-warnings`, `-target` (the host's only: section 7), `-L`, `-F`,
  `-native-startup worker|main-thread` and `-aot-keep`. Anything that runs,
  inspects or builds another way (`-backend`, `-check`, `-emit-*`, a second
  FILE, ...) is a usage error, status 2, before anything compiles
  (`aotr-usage`) -- never silently ignored.
* Nothing of the compiler's is printed when the program compiles without
  warnings: no `==` header, no `value:` line. Standard output and error are
  the program's (section 4). Warnings, a rejection and a failed link go to
  standard error, after `FILE: `.
* `run`'s native default (`main.tcl run FILE`, no `-backend`) is unchanged
  where the native backend has a JIT, and is `-aot-run` where it has none
  (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 3): the user did not
  choose the JIT there. An explicit `-backend cranelift` without a JIT is
  refused instead, naming `-aot-run` (`aotr-no-jit-refused`).
* `-version` says which: `native JIT: available`, or `native JIT:
  unavailable (programs run natively as executables: -aot-run)`.

Why a flag of main.tcl and not a `botlish aot-run` subcommand: main.tcl's
command line is flags plus FILE, and `run` is its one subcommand, kept for
"a program as a command". `-aot-run` is that with the build made explicit,
and it is spelled like `-emit-native-executable`, whose pipeline it is.
Compilerpedia documents it (`cli.aot-run`, `cli.options`), and the error
topic of its codes (`NATIVE UNSUPPORTED jit`, `NATIVE UNSUPPORTED
aot-run`).

[executed, Linux x86-64] `tests/aot-run.test`'s `aotr-usage`,
`aotr-arguments`, `aotr-no-arguments`, `aotr-no-jit-refused`,
`aotr-no-jit-run-default`, `aotr-jit-available`.

## 3. AOT pipeline reuse

The command is two halves, each the existing code's:

* main.tcl reads the program as `-emit-native-executable` does
  (`nativeProgramHir`: `surface::readProgramFile`, or a `.hir`/`.hirx`
  file), and `native::aotRun` (native/native.tcl) lowers it with
  `native::ExecutableText` -- the readiness check (`-aot-spec`'s contract,
  NATIVE AOT NOT-READY) and the NIR of an executable. `native::executable`
  now calls the same procedure: there is one compilation of an executable,
  not two that could drift.
* the driver's new `aot-run` command (native/src/aotrun.rs) calls
  `codegen::aot::emit_executable` -- the function `executable` calls: the
  same program object, runtime, link plan, linker
  (`BOTLISH_NATIVE_LINKER`) and startup record -- with the private
  directory's path, then starts that file.

Nothing in `aot-run` compiles code into the driver's memory
(`aotr-no-jit-route` checks the source: `aotrun.rs` names neither
`CraneliftJit` nor `execute(`, and `native::aotRun` calls `RunDriver` with
`aot-run`, never `run`), and the driver built without its JIT runs it
unchanged (`aotr-no-jit-driver`, below). `aotr-equals-emitted` runs a
program both ways -- through `-aot-run`, and through
`-emit-native-executable` and then the executable -- and requires the same
output, error and status, plainly and under `BOTLISH_NATIVE_GC_STRESS=1`.

The JIT became a cargo feature of the driver (`jit`, on by default:
native/Cargo.toml) so that this could be shown, not just claimed. `cargo
build --release --no-default-features` builds a driver with no
`cranelift-jit` crate in it:

* `run`, `bench`, `batch` and `vms` report `NATIVE UNSUPPORTED jit` (the
  linked run of a C-calling program included: it is the JIT's `run`);
* `-emit-clif` and `-emit-vcode` inspect the code from the object module
  instead (`codegen::inspect`: the module an executable is linked from);
* `botlish-native capabilities` prints `jit 0` (`jit 1` with the feature),
  which `native::jitAvailable` reads;
* the runtime archive's crate depends on the driver crate with
  `default-features = false`, so the archive never holds the JIT.

[executed, Linux x86-64] With such a driver (`native/target/no-jit`, made
with `--target-dir native/target/no-jit`) `aotr-no-jit-driver` passes:
`capabilities` says `jit 0`, the four in-process commands are refused,
`-emit-clif` works, and `-aot-run` and `-emit-native-executable` behave as
with the JIT. The stripped driver is 8,580,040 bytes against the JIT
driver's 8,900,808 (−320,768 bytes, 3.6%); `nm` finds 71 `cranelift_jit`
symbols in the latter and none in the former.

## 4. Arguments and standard streams

* **Arguments.** main.tcl builds the program's argument vector as `run`
  does (FILE as typed, then the words after `--`, each as its UTF-8 bytes)
  and native::RunDriver writes it to an argument file (`--argv-file`), as
  for every driver run: no command-line length limit and no quoting. The
  driver starts the executable with exactly that vector: on Unix with
  `Command::arg0` for argument zero, on Windows with the command line
  launch.rs writes for `CreateProcessW` (the MSVC runtime's splitting rules
  reversed; a vector no Windows process can receive is `NATIVE UNSUPPORTED
  aot-run`, never altered). `aotr-arguments`: spaces, the empty argument,
  option-like words (`-v`, `--`), non-ASCII text, a second `--`, and
  argv()[0].
* **Standard streams.** main.tcl starts the driver with its own standard
  input, output and error (`exec ... <@stdin >@stdout 2>@stderr`: the
  driver protocol's lines go to a result file), and the driver starts the
  program with its own, so the program reads and writes the command's
  streams directly: nothing passes through a pipe of the compiler, nothing
  is buffered, and the program's output is never parsed. `aotr-streams`
  (stdout the program's bytes, stderr its lines, nothing of the
  compiler's), `aotr-stdin` (a C reader counts every byte of its input),
  `aotr-broken-pipe` (a reader that stops early sees the program's own
  broken pipe, no message of the compiler's).
* **Working directory and environment.** The user's: the build directory is
  never the program's working directory (`aotr-working-directory`: a file
  found by a relative name in the user's directory, not in the build
  directory or the source's). The one exception is a packaged compiler's
  own settings: single/main.tcl sets `BOTLISH_NATIVE_BIN`,
  `BOTLISH_NATIVE_LINKER` and others for its native backend, and records
  how the user had them (`::single::userEnvironment`); main.tcl passes that
  record on (`--child-env`), and the driver restores each variable for the
  child -- unset, or the user's value -- so the program sees the
  environment the user gave the command.

## 5. Exit and signal semantics

* **Exit status.** The program's exit code is the command's
  (`aotr-exit-status`: a C `exit(3)`'s 3, a completed program's 0). On
  Windows an exit code is 32 bits; `childExitStatus` hands Tcl's `exit` the
  signed value of the same bits. A run-time failure is the executable's own
  (`MESSAGE (CODE)` on stderr, status 1: `aotr-runtime-error`, a native
  stack overflow).
* **A child ended by a signal (Unix).** Status 128+N, the convention of
  POSIX shells' `$?`, and one line on stderr, `FILE: the program was ended
  by signal N (NAME)` -- except for SIGINT and SIGPIPE, which a shell does
  not report either (`aotr-signal-status`: SIGTERM, 143).
* **Signals to the command (Unix).** The driver waits for the child as
  system(3) does. SIGINT and SIGQUIT come from the terminal to the whole
  foreground process group, the program included, so they are not sent
  again (`aotr-interrupt-group`: Ctrl-C ends the program and the private
  directory is removed). SIGTERM and SIGHUP, which a process is sent by
  name, are forwarded to the program (`aotr-terminate-command`). main.tcl
  itself is the driver's parent and runs nothing meanwhile.
* **The command killed.** If main.tcl ends first (SIGKILL, a closed
  terminal), the driver sees its parent change (`getppid`, every 100 ms;
  `--parent-pid` covers a parent that ended before the driver's watch
  began) and sends the program SIGTERM: it never outlives the command that
  ran it (`aotr-parent-killed`). On Windows the driver waits on the parent's
  process handle beside the child's and terminates the child when the
  parent ends; the console's Ctrl+C and Ctrl+Break reach every attached
  process, the program's included, and the driver ignores them while it
  waits.
* **An interruption before the program starts** -- a signal during the
  build, or the parent gone -- stops the run there: `interrupted (NAME)
  before the program started: nothing ran`, status 128+N (1 for the
  parent). Nothing is started after an interruption.

## 6. Temporary artifacts

* The executable is built in a directory made for this run alone:
  `botlish-aot-run-PID-NONCE-COUNT` under the system's temporary directory
  (`std::env::temp_dir`: `$TMPDIR`, `GetTempPathW`), created exclusively --
  a name that exists already, whoever made it, is never used, and creation
  is retried with a new name -- and on Unix with mode 0700, so no other user
  can read the program or put a file there before it runs.
* It is removed when the program has ended, also when the build failed or
  the run was interrupted. `-aot-keep` keeps it, with the program's NIR
  beside the executable, and says on stderr where (`aotr-keep`: owner-only,
  the two files, the kept executable runs again alike).
* **No stale executable.** The directory is new every run, so there is never
  an earlier executable at the path; and the child is started only after
  `emit_executable` returned the file it linked. A rejected program and a
  failed link run nothing, also right after a successful run of the same
  file (`aotr-rejected-never-runs`, `aotr-link-failure-never-runs`).
* **Concurrency.** Four runs of one program at once each build in a
  directory of their own and print their own arguments; nothing is left
  (`aotr-concurrent`).
* The build needs no writable working directory
  (`aotr-unwritable-working-directory`), and paths with spaces and
  non-ASCII letters work for the source, the application root and the
  temporary directory (`aotr-unicode-paths`).

## 7. Target and startup policy

* **Target.** `-aot-run` runs the program here, so `-target` of another host
  is a usage error naming the host (status 2, nothing compiled); the driver
  would refuse it too (`NATIVE TARGET`, the shared `same_target` check).
  Which hosts link executables at all is `codegen::aot`'s unchanged
  `EXECUTABLES`: Linux x86-64 and AArch64, macOS AArch64, Windows x86-64
  (MSVC). There is no cross-compilation and no emulation.
* **Startup policy.** `-native-startup worker|main-thread` is the
  executable's, recorded in its program record exactly as for
  `-emit-native-executable` (MAIN-THREAD-STARTUP-MILESTONE-1.md); without
  it the executable is the worker's (`aotr-worker-default`: the startup
  report's `startup worker`). main-thread is macOS AArch64's only; elsewhere
  it is `NATIVE UNSUPPORTED startup`, refused before anything is written,
  and nothing runs (`aotr-main-thread-refused`). On macOS `aotr-main-thread`
  runs a program on the process's main thread (its startup report's
  `process-main-thread 1`), and the application's acceptance runs an AppKit
  and Metal canary through `-aot-run -native-startup main-thread`
  (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 18).

## 8. Native FFI and link-plan behavior

A program that calls C is linked as `-emit-native-executable` links it: its
`extern c library`, `static`, `static at` and `extern c framework`
declarations, `-L` and `-F`, the link plan of NATIVE-LINK-PLAN-MILESTONE-1.md
and the platform linker. There was no reason to give it a route of its own:
the run is an executable's run in every case. The JIT build's linked run of
a C-calling program (`run_linked`) is unchanged; `-aot-run` does not use it.
`aotr-stdin`, `aotr-working-directory`, `aotr-exit-status` and
`aotr-signal-status` are C-calling programs (`aotrCCalls`: the host links
C and has the tests' C linker), and `aotr-link-failure-never-runs` a
missing library.

## 9. Tests on each target

`tests/aot-run.test`: 33 tests -- 30 of behavior, 3 positive controls.
Their constraints name capabilities, never an operating system: `aotRun`
(the host links executables), `unixSignals`, `aotrPython` (the interrupt
helper, tests/aot-run-interrupt.py, sends signals to process groups),
`aotrCCalls`, `aotrMainThread` / `aotrNoMainThread`, `aotrStackGuard`,
`aotrCoroutines`, `aotrNoJitDriver` (a driver built without its JIT in
`native/target/no-jit`), `aotrWindowsKill` (Windows' `taskkill` and
`tasklist`: `aotr-parent-killed-windows` kills main.tcl alone with
TerminateProcess and requires the program gone and the directory removed).

| host | where | result |
|---|---|---|
| Linux x86-64, rustc linker | this sandbox | [executed] 31 passed, 2 skipped (`aotr-main-thread`, macOS's; `aotr-parent-killed-windows`) |
| Linux x86-64, system linker | this sandbox | [executed] 31 passed, 2 skipped |
| Linux x86-64, stub linker | this sandbox | [executed] 22 passed, 11 skipped (the C-calling tests: the stub links no C; the macOS and Windows tests) |
| Linux x86-64 | `tests` workflow (ubuntu-latest), its canary | [executed] the changed file runs first on every push; see section 9.1 |
| Linux AArch64 | `tests (linux arm64)` (ubuntu-24.04-arm) | [executed] canary on the branch push; see section 9.1 |
| Windows x86-64 (MSVC) | `tests (windows x86-64)` (windows-2025), canary | [executed] see section 9.1 |
| macOS AArch64 | `tests (macos arm64)` (macos-15): the smoke job's canary, the acceptance tier, the app jobs | [executed] the canary (section 9.1); the acceptance tier and the app jobs [pending] |

The JIT build's own tests are unchanged and run as before on every host
that has the JIT: the native backend's test files, the golden suites on
cranelift and cranelift-generic, the GC-stress runs.

### 9.1 CI runs

The branch `ccr-7f920867-5n2fuj`:

* `29bcbe2` (the JIT a cargo feature, Botlish.app without it): Linux x86-64
  and Linux AArch64 green; Windows x86-64's canary failed three tests of
  aot-run.test, all three the tests' own reading of Windows output -- main.tcl's
  lines end in CRLF (`aotr-jit-available`'s regular expression), the
  startup report's `process-main-thread` is `unknown` on Windows (as
  main-thread-startup.test reads it), and the kept directory's path is
  Windows' spelling -- fixed in `a822905`, no change to the command.
* `a822905`: Linux x86-64 and Linux AArch64 (canaries) green; macOS
  AArch64's smoke job, whose canary runs the changed test files first,
  aot-run.test among them, green [executed, macOS]; Windows' and macOS's
  later jobs superseded by the next push.
* `460fcee` (adds `aotr-parent-killed-windows`): [pending] at the time of
  writing -- Windows' canary runs aot-run.test there, the full Linux suites
  were dispatched; MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 24,
  lists the runs.

## 10. Positive controls and mutants

**Positive controls** (in tests/aot-run.test): `aotr-control-arguments`
(the argument comparison fails for arguments the program was not given),
`aotr-control-left` (what a kept run leaves is seen: the cleanup check is no
tautology), `aotr-control-status` (the status check tells 3 from 0).

**Mutants** (`audit/aot-run/tools/mutants.txt`, 22; the harness
`audit/aot-run/tools/mutate.tcl` builds each in a private copy, rebuilds
the driver, and runs the driver's `aot_run` unit tests and
tests/aot-run.test; the unmutated tree must pass both first). Each is one of
the failures the milestone names:

| mutant | the bug | [executed, Linux x86-64] killed by |
|---|---|---|
| `shared-directory` | one fixed directory for every run | the unit test `aot_run_private_directories_are_new_and_private`; `aotr-concurrent`, `aotr-keep`, `aotr-control-left` |
| `existing-directory-reused` | a name that exists already is used | the unit test |
| `directory-not-private` | mode 0755 | the unit test; `aotr-keep` |
| `directory-left` | never removed | the unit test; 16 tests that check nothing is left |
| `exit-status-lost` | nonzero status replaced with success | `aotr-exit-status`, `aotr-runtime-error`, `aotr-control-status` |
| `signal-death-as-exit` | a signal death reported as exit 1 | `aotr-signal-status` |
| `termination-not-forwarded` | SIGTERM/SIGHUP not sent on | `aotr-terminate-command` |
| `parent-not-watched` | the program outlives main.tcl | `aotr-parent-killed` |
| `argv0-is-the-executable` | argv()[0] the private path | `aotr-arguments` |
| `stdin-not-forwarded` | standard input not the command's | `aotr-stdin` |
| `stdout-captured` | the program's output captured | 18 tests (`aotr-arguments`, `aotr-streams`, `aotr-equals-emitted`, ...) |
| `startup-policy-dropped` | main-thread silently ignored | `aotr-main-thread-refused` |
| `signal-status-not-128` | main.tcl's status for a signal 1 | `aotr-signal-status` |
| `foreign-target-accepted` | another host's target compiled | `aotr-usage` |
| `jit-refusal-removed` | `-backend cranelift` without a JIT not refused | `aotr-no-jit-refused`, `aotr-no-jit-driver` |
| `stale-executable-run` | a failed build runs what an earlier run left | the unit test; 16 tests (the mutant needs a directory that outlives its run, so every test that checks nothing is left fails too; `aotr-link-failure-never-runs` is among them by construction: the earlier run's executable prints the new run's arguments) |
| `arguments-split` | an argument with a space becomes two | `aotr-arguments`, `aotr-control-arguments`, `aotr-no-jit-run-default` |
| `arguments-reordered` | the arguments reversed | `aotr-arguments`, `aotr-no-jit-run-default` |
| `argument-dropped` | the last argument lost | 10 tests (`aotr-arguments`, `aotr-exit-status`, `aotr-keep`, ...) |
| `wrong-working-directory` | the program runs in its build directory | `aotr-working-directory` |
| `stderr-captured` | the program's standard error captured | `aotr-arguments`, `aotr-no-arguments`, `aotr-runtime-error`, `aotr-streams` |
| `jit-route` | the driver asked to run the program in-process (the JIT's `run`) | 26 tests (`aotr-arguments`, `aotr-equals-emitted`, `aotr-control-left`, ...: the JIT's run reports no status, and takes none of aot-run's options) |

[executed, Linux x86-64] `tclsh9.0 audit/aot-run/tools/mutate.tcl`: the
unmutated tree passed both detectors first; 22 mutants, 22 killed, none
survived, none skipped (in two runs: the first fifteen, then the seven
added with `-only`). A mutant counts as killed only when it built and a
detector failed on it. Six change Unix code only (their `%%` line names
the Unix hosts); none has been judged on Windows or macOS.

## 11. Performance measurements

`bench/aot-run.tcl` measures, best of N runs: the phases in one process
(the front end, NIR lowering, the driver's object, the link, the whole
`native::executable` and `native::aotRun`), whole commands in fresh
processes (the interpreter, `-emit-native-executable`, the executable
alone, both together, `-aot-run`, the JIT), and the time from starting a
command to the program's first line of output. The macOS and Windows smoke
jobs run it (`AOT-run costs`), so those numbers come from those hosts.

They are evidence of what the command costs, not grounds for another
pipeline.

### 11.1 Linux x86-64

[executed] This sandbox, otherwise idle: an Intel Xeon @ 2.10 GHz, 4
processors, Linux 6.18; the rustc linker (a checkout's default); best of 7
(`tclsh9.0 bench/aot-run.tcl -runs 7`). `hello` is a line through
std::linux::io; `2048` the engine's benchmark (365 lines, 200 moves).

Phases in one process, ms:

| program | front end | NIR lowering | object (driver, Cranelift) | link | native::executable | native::aotRun | driver: linked / started |
|---|---:|---:|---:|---:|---:|---:|---:|
| hello | 414.7 | 107.9 | 6.6 | 139.9 | 284.6 | 252.3 | 132.1 / 132.4 |
| 2048 | 264.0 | 337.6 | 23.9 | 126.1 | 552.2 | 559.2 | 156.3 / 156.7 |

Commands, each a fresh process (main.tcl's own startup included), ms:

| program | interpreter | -emit-native-executable | the executable | emit + run | -aot-run | -backend cranelift (JIT) |
|---|---:|---:|---:|---:|---:|---:|
| hello | -- (native IO only) | 1076.8 | 2.5 | 1079.3 | 966.0 | 858.9 |
| 2048 | 7634.9 | 980.8 | 7.2 | 988.0 | 1009.4 | 867.6 |

Time from starting the command to the program's first line of output
(hello), ms: `-aot-run` 924.0; the emitted executable alone 1.6; the JIT
913.5.

What this says:

* **The front end and lowering are most of it.** The driver's own share --
  Cranelift, the object, the link and starting the child -- is 130-160 ms
  of an `-aot-run` of about a second; Cranelift itself 7-24 ms, the rustc
  link about 130 ms. Starting the child after the link costs well under a
  millisecond (linked / started).
* **`-aot-run` costs what compiling and then running costs**: 966 against
  1079 ms for hello and 1009 against 988 for 2048 -- the same work, within
  the runs' spread (the separate commands pay main.tcl's startup twice for
  hello's, once less for -aot-run's single process).
* **Against the JIT**: `-aot-run` is 100-140 ms slower end to end (the
  link), and its time to the first output is within 1% of the JIT's on
  hello (924 against 914 ms): the JIT also compiles the whole program
  first, and both are dominated by the front end.
* A run of an executable that is already built is milliseconds: a build
  cache would save the second; this milestone keeps none (section 12).

### 11.2 macOS AArch64 and Windows x86-64

The `AOT-run costs` step of macos-arm64.yml's and windows-x86_64.yml's
smoke jobs prints the same tables on those runners; bench/macos-app.tcl
in the `app` job measures `-aot-run` from the JIT-less Botlish.app
(MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 26). [pending] their
figures at the time of writing.

## 12. Limitations

* **[not implemented] No cache.** Every run compiles and links again. A
  cache of executables would be a cache of *trusted* executables -- what
  this milestone rules out ("never run a stale executable") -- and the
  front-end cache (HIR-INTERCHANGE.md) already takes the front end's share
  where it is enabled.
* **The link needs the host's toolchain**, as `-emit-native-executable`
  does: rustc (the default in a checkout), the C compiler driver (the
  system linker: the single executable's and Botlish.app's choice), or the
  stub (Linux x86-64, no C). On macOS that is Apple's Command Line Tools;
  nothing here bundles a linker or an SDK.
* **Windows**: the signal semantics are Windows' (no 128+N; the console
  events reach every process). The parent watch is tested there by
  `aotr-parent-killed-windows` (taskkill of main.tcl alone); Ctrl+C to the
  console is not tested on Windows (a CI runner has no console to send it
  to).
* **Ctrl-C on Windows** while the program runs is the program's to handle;
  the driver only ignores it.
* **One program per command.** No REPL, no watch mode, no build of several
  programs.

## 13. Exact files changed

The milestone's own (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 29,
lists the distribution's):

| file | change |
|---|---|
| `native/src/aotrun.rs` | new: the driver's `aot-run` command (private directory, build, child process, signals, parent watch, result lines) and its unit tests |
| `native/src/launch.rs` | Windows: `spawn`, `exit_code`, `wait_watching` (the parent's handle beside the child's, Ctrl+C ignored); `run` = spawn and wait |
| `native/src/main.rs` | `aot-run`'s options and dispatch; `capabilities`; the JIT behind the `jit` feature, its commands refused without it |
| `native/src/codegen/mod.rs` | the JIT behind the feature; `inspect` (CLIF and VCode from the object module) |
| `native/Cargo.toml`, `native/runtime-archive/Cargo.toml` | the `jit` feature (default); the archive without it |
| `native/native.tcl` | `native::aotRun`, `native::ExecutableText` (shared with `native::executable`), `native::jitAvailable`; `RunDriver`'s `run-command` mode |
| `main.tcl` | `-aot-run`, `-aot-keep`, `--`; `aotRunProgram`, `childEnvironment`, `childExitStatus`; the JIT boundary; `-version`'s JIT line |
| `single/main.tcl` | `::single::userEnvironment` (what it set for the native backend, as the user had it) |
| `compilerpedia/topics/backends.topic`, `errors-runtime.topic` | `cli.aot-run`, `cli.options`, `cli.run`, `backend.cranelift`; the codes `jit` and `aot-run` |
| `tests/aot-run.test`, `tests/aot-run-interrupt.py` | new: section 9's tests and the signal helper |
| `audit/aot-run/tools/mutants.txt`, `mutate.tcl` | new: section 10's mutants and harness |
| `bench/aot-run.tcl` | new: section 11's measurements |
| `.github/workflows/macos-arm64.yml`, `windows-x86_64.yml` | the smoke jobs' `AOT-run costs` step |
| `audit/native-aot/tools/mutants.txt`, `audit/single-executable/tools/mutants.txt`, `audit/target-model/tools/mutants.txt` | mutant texts updated where the code they mutate moved |

## 14. What to run when changing this

If you change `native/src/aotrun.rs`, `native::aotRun`,
`native::ExecutableText`, RunDriver's `run-command` mode, main.tcl's
`-aot-run` or its JIT boundary, `childEnvironment` or single/main.tcl's
`userEnvironment`, or the driver's `jit` feature, run:

* `cargo test --release --manifest-path native/Cargo.toml --bin
  botlish-native aot_run`;
* `tclsh9.0 tests/aot-run.test`, once with each linker
  (`BOTLISH_NATIVE_LINKER=system`, `stub`) and, for the JIT boundary, with a
  driver built without its JIT (`cargo build --release --no-default-features
  --manifest-path native/Cargo.toml --target-dir native/target/no-jit`);
* `tests/main-cli.test` and `tools/compilerpedia.tcl check`;
* `tclsh9.0 audit/aot-run/tools/mutate.tcl` (every mutant must still apply
  and be killed: update a mutant's text when you change the code it
  mutates, keeping it a mutant of the same rule);
* the Windows and macOS workflows on the branch (their canaries and smoke
  jobs run aot-run.test and the bench), and for the packaged compiler the
  macOS app jobs (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, section 28).
