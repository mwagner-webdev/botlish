# PROGRAM-OUTPUT-MILESTONE-1.md

Standalone executables print only what their program writes, and
`main.tcl run FILE ARG...` runs a program as a command: the first
implementation milestone after PROGRAM-RESULT-PRINTING-CENSUS.md, which
found what the automatic printing of a program's value had become load-
bearing for. Everything that census's section 8 recommends is done here
except the exit status, which is decided (below) and left to its own
milestone.

## Outcome

```console
$ tclsh9.0 main.tcl -emit-native-executable examples/io/hello.bot
$ examples/io/hello
Hello, world!
$ printf 'hello from stdin\n' | tclsh9.0 main.tcl run examples/linux/read-stdin.bot
hello from stdin
$ tclsh9.0 main.tcl run tool.bot -n 3 'two words'      # argv(): tool.bot -n 3 'two words'
```

Before, the executable's last line was `unit`, and a program whose
standard output is its product (a CSV exporter, a filter in a pipe) could
not avoid it. Now:

| | standard output and error | completed | rejected / failed |
|---|---|---|---|
| a standalone executable | the program's own, nothing else | status 0 | the error on stderr, `MESSAGE (CODE)`, status 1 (unchanged) |
| `main.tcl run FILE ARG...` | the program's own, nothing else | status 0 | diagnostics on stderr after `FILE: `, or the run-time error as an executable writes it; status 1 |
| `main.tcl FILE...` (unchanged) | `== FILE (BACKEND)`, the program's output, `   value: V` | status 0 | `   error:` lines on stdout, status 1 |

The program's value itself is unchanged: the last top-level statement,
returned by `core::evalProgram`, `core::compiler::evalHir` and
`native::evalHir`, reported by the driver protocol, read by the golden
runner, Compilerpedia's checker and the test suite.

## 1. Executables print no value

`runtime::aot::run` (native/src/runtime/aot.rs), the one body every
linker's startup runs (rustc's startup crate, the stub's loader, the
system linker's `linked_main`), no longer writes `show(result)` after a
completed program: it returns status 0. Its error path is untouched, and so
is the driver protocol: with `BOTLISH_NATIVE_RESULT=FILE` the executable
writes `value V` (the host's value format) or `error CODE MESSAGE` to FILE,
as `botlish-native run` does, which is now the one way to read an
executable's value. A failed write of the value line used to be `NATIVE IO`,
status 1; there is no such write any more.

The native printer (runtime/show.rs's `show`) stays: run-time error
messages render values with it, and ops.rs's unit tests pin it.

## 2. `main.tcl run`

`main.tcl run [OPTION...] FILE [ARG...]` (and `botlish run ...` in the
single-file compiler) runs FILE as an executable built from it runs:

* no header, no `value:` line, no `type:` or refinement-probe lines: the
  program's standard output and error are its own, and its standard input
  is run's;
* argv() is FILE as typed, then every word after it, an option-like one
  too (`run tool.bot -hir` passes `-hir` to the program);
* status 0 when the program completes, 1 when it is rejected (each
  diagnostic on stderr after `FILE: `, with its `help:` line, as the build
  options report them) or fails at run time (on stderr as an executable
  writes it, `MESSAGE (CODE)`), 2 for a malformed invocation;
* it runs natively (`cranelift`) unless `-backend` says otherwise -- as its
  executable would; the Tcl backends run it too, but cannot print;
* of the options only `-backend`, `-warnings`, `-target`, `-L` and `-F`
  combine with it; anything that inspects, builds, checks or injects argv
  (`-hir`, `-emit-native-executable`, `-check`, `-argv`, ...) is a usage
  error, never ignored.

main.tcl's default run is unchanged: it is the development view, which
prints the value on every backend. It stays because the Tcl backends have
no other output (they refuse the syscall and C transports by design), and
because Compilerpedia's examples, the smoke tests and many process tests
read its `value:` line (the census, section 7: B2, B3, B4). Making the
value line opt-in there is a later step, once those have another channel.

single/main.tcl's `MayLink` -- whether a run may link, so the runtime
archive is installed for it -- knows that `run` is a native run unless
`-backend` says otherwise, and stops at FILE (the words after it are the
program's): a program that calls C (on macOS, every printing one, through
libSystem) links under `run` with a fresh cache.

### Known limits

* A program whose value is a function or a coroutine handle fails under
  `run` on the native backends with NATIVE UNSUPPORTED value, as under
  `-backend cranelift`: the driver cannot hand such a value back, and `run`
  goes through the driver. Its executable runs it. With the exit status
  below such a value will be an error of the program anyway.
* Arguments reach the program as Tcl decoded them: in a checkout without a
  UTF-8 locale, non-ASCII arguments are mis-decoded, as `-argv`'s are; the
  single-file compiler recodes them (single/main.tcl).
* A native stack overflow under `run` is reported as `native stack
  exhausted: too many nested calls (NATIVE LIMIT STACK)`, where an
  executable writes the guard's own line, `error {NATIVE LIMIT STACK}
  {...}`.

## 3. The exit status (decided, not implemented)

The exit status will be the program's top-level value: an Int is the
status, `unit` means 0 (success). There is no early exit, by design: no
exit operation and no top-level `return` (RETURN-OUTSIDE-CALLABLE stays);
a program ends by its last statement or by a run-time error. This
milestone does not implement it: a completed program's status is 0 under
`run` and in an executable, whatever its value.

What the implementing milestone will meet (from the census and this
work):

* The value then has to be a status: which other types qualify (Bool?) and
  what a List, a String or a struct means (an error at compile time, most
  likely) is its decision. Many example programs end with a value to show
  (about 50, section 4.4 of the census) and every golden suite ends with
  its report, which the golden runner reads in-process: those keep working
  under main.tcl's development run but would not be statuses.
* An Int status outside 0..255 (or the host's range: Windows has 32 bits)
  needs a rule.
* The driver protocol, `native::evalHir`, `run` and the executables must
  agree; the Tcl backends compute the same status from the same value.
* Icy Tower's declared C `exit(3)` (examples/games/icy-tower/game.bot) is an
  early exit by a C call, which the design rules out for Botlish itself: the
  game would return its status instead.

## 4. What changed

| area | change |
|---|---|
| runtime | aot.rs's `run`: no value line; its module comment states the ordinary run's outcome and the protocol as the way to read a value |
| CLI | main.tcl: the `run` form (parser, usage, header comment, `runProgram`); single/main.tcl's `MayLink` |
| tests | tests/helpers.tcl's `standaloneValue` and `bareValue` (the protocol); about 70 test files that read an executable's standard output migrated: the value through the protocol, a program's output without the trailing value line, plain runs pinned to empty output; tests/main-cli.test's eight `cli-run-*` tests; native-executable.test's `native-executable-prints-no-value`; their census rows and the regenerated manifest |
| CI and scripts | windows-x86_64.yml (the executables' values, Windows I/O's expected output), macos-arm64.yml (the main-thread job), icy-tower-macos.yml and icy-tower-windows.yml (their comparisons of two runs now require a summary line), single/smoke-test.sh (and `run`: output, arguments, a rejection), single/ffi-smoke-test.sh (values through the protocol's words, `run` of a program that calls C with a fresh cache), single/macos/app-test.sh and compare.sh |
| tools | bench/golden-aot.tcl and bench/c-ffi-error-capture.tcl, audit/abi-bytes and audit/mutable-bytes fuzzers, audit/dfa/tools/differential.tcl (it dropped the last line unconditionally), audit/macos-graphical-main-thread/tools/census.py, fuzz/scripts/replay.tcl, fuzz/scripts/baseline.sh (a value column), fuzz/windows/replay-json.ps1, tests/platform's aot-facts.tcl, native-status.tcl, gc-workloads.tcl and link-plan-sdl3.sh |
| Icy Tower | game.bot's `main` prints the run's summary line itself (its `--headless` mode printed nothing but its value); the entry programs end in `unit`; the committed executable audit/icy-tower/artifacts/icy-tower rebuilt |
| mutants | audit/native-aot's `result-not-printed` (the old rule) replaced by `result-printed`; audit/single-executable's new `run-command-not-linking` |
| documentation | README.md's hello transcript, docs/README.md, Compilerpedia (the new `cli.run`; `cli.usage`, `cli.output`, `cli.exit-status`, `backend.native-executable`, `backend.io`, `backend.native-only`, `task.print-output`, `capability.process-exit-status`, `concept.program-value`), example comments, AGENTS.md's "Program output" section, the census's status |

Shell scripts that run where no Tcl is (the single-file compiler's smoke
tests in clean containers, CI steps) read an executable's value as the
words of its result file's `value V` line, its quoting removed: `[42, -1]`
is `value list int 42 int -1`, a String `str TEXT`.

Not changed: the program's value and every in-process reader of it; the
driver protocol; main.tcl's default run; AFFINE-ERASURE-UNSUPPORTED's
message ("a result is shown, never owned": the development run still shows
it); the overflow guard's line; native libraries (no program value at their
boundary). fuzz/baselines/*.tsv were recorded while executables printed
their value and are left as recorded, and so are the milestone reports that
describe an executable printing its value (ABI-BYTES.md, MUTABLE-BYTES.md,
FUZZING-EXAMPLES-AOT.md, FUZZING-ARGV-PROGRAMS.md,
SINGLE-EXECUTABLE-FFI-MILESTONE-1.md, MACOS-AARCH64-PORT-AUDIT.md, ...):
they are records of their time, and so is the golden migration census's
description of the tests this milestone migrated
(audit/golden/migration/census/: what a test observed when it was
classified).

## 5. Validation

On Linux x86-64 (Tcl 9.0.1, the release native backend, the pinned SDL3
built by tests/cffi/sdl3.tcl):

* `tclsh9.0 tests/local.tcl`, the whole local run: Tcl tests 8,735 passed
  on interp and 8,730 on compile, one failure on each -- package-
  authoring.test's `pa-add-refusals`, which links an AArch64 library with
  clang and this host's linker has no AArch64 emulation (its documented
  requirement: clang, lld and MinGW-w64), unrelated to this change; the 117
  golden suites on all four backends, 0 failed.
* Every test file the migration changed passed on its own run (about 75
  files; the macOS- and Windows-only tests in them were edited by reading),
  among them tests/workload-icy-tower.test's executable tests with SDL3
  (headless summary, dummy driver, GC stress, the oracle over 8 seeds, the
  SDL call trace against its reference, valgrind) and the eight new
  `cli-run-*` tests.
* tests/native-executable.test with `BOTLISH_NATIVE_LINKER=stub`, with
  `=system` (18 passed, 2 skipped: rustc-linker tests) and under
  `BOTLISH_NATIVE_GC_STRESS=1` (20 passed).
* `cargo test --release --manifest-path native/Cargo.toml --lib --
  aotimage program` (11 passed) and `--bin botlish-native aot::` (29).
* audit/native-aot/tools/mutate.tcl -only result-printed: the baseline
  (native-executable, argv, 2048, system-linker, main-thread-startup,
  aot-facts, native-status) passes; the mutant is killed by six detectors.
* single/build.sh, then single/smoke-test.sh and single/ffi-smoke-test.sh
  against single/out/botlish: both pass, `run` included (a printing
  program, its arguments, a rejection, a program that calls C with a fresh
  cache). audit/single-executable/tools/mutate.tcl -only
  run-command-not-linking,backend-run-not-linking,runtime-always-installed:
  3 killed (the new one by the FFI smoke test's `run` of b).
* `tclsh9.0 tools/compilerpedia.tcl check`: 1,219 topics, 742 examples, 0
  problems. audit/refactor/tools/gate.tcl: passed (Icy Tower's game is
  built under `-warnings error` too).
* audit/abi-bytes/tools/fuzz.tcl and audit/mutable-bytes/tools/fuzz.tcl in
  their executable modes (`-mode write`, `-mode read`; seeds 11, 23, 37):
  0 failures. bench/golden-aot.tcl on one suite: the AOT and JIT reports
  agree.
* Not run here: fuzz/scripts/replay.tcl and baseline.sh (they need the fuzz
  campaign's AFL-built targets), audit/dfa/tools/differential.tcl (it needs
  JSONTestSuite), the macOS census tool, and every macOS and Windows path:
  those run in the macOS and Windows workflows, and the Linux workflows
  (tests, tests-arm64, single-executable, icy-tower) were dispatched on the
  branch.

## 6. Open items

From the census, still open: the exit status (section 3); output on the
Tcl backends (B2); Float64 text and generic formatting (B3); portable
standard input (B10); main.tcl's value line as an opt-in; the overflow
line's format in executables.

## What to run when changing this

tests/native-executable.test, tests/main-cli.test,
tests/native-program-output.test, tests/system-linker.test,
tests/aot-stub-linker.test, tests/workload-2048.test,
tests/workload-icy-tower.test (its executable tests need
`tclsh9.0 tests/cffi/sdl3.tcl`), `cargo test --release --manifest-path
native/Cargo.toml --lib -- aotimage program` and `--bin botlish-native
aot::`, audit/native-aot/tools/mutate.tcl, and for single/main.tcl
audit/single-executable/tools/mutate.tcl with both smoke tests after
single/build.sh; push to read the macOS and Windows workflows.
