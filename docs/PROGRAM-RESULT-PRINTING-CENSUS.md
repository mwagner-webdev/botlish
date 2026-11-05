# PROGRAM-RESULT-PRINTING-CENSUS.md

Every Botlish program has a value, its last top-level statement, and two of
the three ways to run a program print it: `main.tcl` (and the single-file
compiler `botlish`, which is main.tcl) writes `   value: SHOWN` after the
program's own output, and a standalone executable writes `SHOWN` and a
newline as its last line of standard output. That was the language's first
output channel, and for a long time its only one. It now gets in the way of
programs whose standard output is their product -- Unix-style utilities, a
CSV exporter writing to a pipe -- which cannot avoid the trailing line.

This is a census of what removing that printing would touch. It answers
four questions:

1. what assumptions have built up around the printed value (sections 3
   and 4);
2. how the printed value differs from what Botlish code can format itself
   (section 5);
3. whether the assertions on printed output can become golden tests
   (section 6);
4. what else in the repository would block a removal (section 7).

Nothing is changed here: no file outside `docs/` was edited.

Evidence labels, as in HTTP-SHIPPING-CENSUS.md:

* **observed**: read in this checkout (revision `f643566`) at the cited
  place, or printed by a command run for this census (section 9);
* **cited**: a claim of another report, named;
* **inferred**: follows from code or rules read here, not exercised.

Counts of tests and examples come from greps and reads of the files, not
from running the suites; they are rounded where a test is generated in a
loop or a helper hides the assertion.

## Contents

1. Answer
2. Three things called "the program's value"
3. What prints today, and how the surfaces already disagree
4. Assumptions that have built up
5. The printed value against Botlish's own text formatting
6. Can the output assertions become golden tests?
7. What else blocks a removal
8. What a removal has to decide
9. Method

## 1. Answer

* **The printing is two separable features over one semantic fact.** The
  program's *value* (the last top-level statement) is part of the language
  and is the oracle of almost the whole test infrastructure: the Tcl tests
  compare backends by it in-process (thousands of call sites), the golden
  runner reads a suite's report as it, Compilerpedia checks 379 `@value`
  lines against it, and the native driver hands it back to Tcl through its
  result protocol. None of that involves printing. What is printed is
  main.tcl's `value:` line and the executable's last line. A removal can
  and should keep the value as the evaluation API's result and remove only
  the two presentations (section 2).
* **The printed value is a debug rendering, not text output.** Strings are
  quoted and escaped (`"two\nlines"`), enum cases are shown by a spelling
  ENUMS.md says is "debug rendering only, never a String conversion", and
  opaque structs as `<opaque M::T>`. It already differs between the CLI and
  an executable: a DecimalRounded result is `0.30` under main.tcl and
  `<DecimalRounded>` from the executable; a program ending in a function
  shows `<block (a b)>` on interp and from an executable, but fails with
  NATIVE UNSUPPORTED under `main.tcl -backend cranelift` (observed,
  section 3.3).
* **But for some values the printer is the only way to text.** A Float64's
  digits, an enum case's name, a struct's or a List's generic rendering and
  every non-scalar value reach the user only through the printed result:
  there is no `std::float64::to_string`, no enum reflection by design, no
  generic `show`, no String join (section 5). `stdlib/test.bot` re-implements
  a subset of the printer in Botlish and gives up on the rest ("a value with
  no text form").
* **Two capability gaps make the printed value load-bearing.** The Tcl
  backends (interp, compile) cannot print at all -- the only `std::io::IO`
  contexts make raw syscalls or C calls, which they refuse -- so on them
  the value is the program's *only* observable output. And Botlish has no
  exit status: the golden runner interprets a suite's report itself, Icy
  Tower declares C's `exit(3)` to report failure, and Compilerpedia tells
  users to "make the outcome the program's value and test it outside"
  (section 4.2).
* **About 300 Tcl tests would change; golden tests can take over almost
  none of them.** Roughly 35-40 tests pin the presentation itself and would
  be rewritten with the feature; roughly 50-60 compare an executable's
  printed value with the in-process value; roughly 200 more run a process
  (main.tcl or an executable) and read the value line as their only
  observable. Golden suites run in-process and cannot observe a process's
  standard output, exit status or argv, so they can carry the *computation*
  these tests check -- which in-process tests and 14 direct golden ports
  already carry -- never the process behavior they exist for. Those tests
  need explicit output instead, and on the Tcl backends there is none
  (section 6).
* **The blockers are capabilities and contracts, not code.** Before the
  executables stop printing, a program needs an exit status and, for the
  Tcl backends and the CLI tests that run on them, either an output channel
  or a retained way to show the value. Compilerpedia's contract (379
  `@value` examples, a dozen topics that tell users the value is printed
  for them), two diagnostics that say "a result is shown", the smoke tests
  and CI steps that grep `value:`, Icy Tower's headless mode (whose only
  output is its value) and the fuzzers that split the trailing line off the
  output all follow (section 7). Four CI and script comparisons of two
  runs' outputs would keep passing on empty output: they need a fixed
  expectation before anything changes. Section 8 lists the decisions.

## 2. Three things called "the program's value"

| | what it is | who reads it | printed? |
|---|---|---|---|
| **The value** | the last top-level statement of the entry program (Compilerpedia's `concept.program-value`): an expression, a binding's value, an `if`'s branch, a declared function, `unit` for an empty program | the evaluation APIs return it: `core::evalProgram` (core/evaluator.tcl:708, "Returns the value of the last expression"), `core::compiler::evalUnit`/`evalHir`, `native::evalHir` | no |
| **The driver's result line** | `value V` in the host's runtime value representation (`tcl_value`, native/src/runtime/show.rs:349), or `error CODE MESSAGE` | `native::evalHir` parses it (native/native.tcl's `Outcome`); `botlish-native run` writes it to standard output or to `--result PATH` (native/src/main.rs:122-127, :972-981); a linked executable writes it to `BOTLISH_NATIVE_RESULT` (native/src/runtime/aot.rs:22-32, `driver_protocol`) | an internal transport, not console output |
| **The printed value** | main.tcl's `   value: SHOWN` line (main.tcl:730) and the executable's `SHOWN` line (aot.rs:317) | people, and every script and test that reads a process's standard output | yes |

Only the third row is the feature in question (observed). The first two are
how the test suite, the golden runner, Compilerpedia's checker and the
native backend's in-process runs see a program's outcome; a removal that
keeps them leaves all of that unchanged.

## 3. What prints today, and how the surfaces already disagree

### 3.1 main.tcl (and the single-file compiler)

For each input file, `runFile` (main.tcl:603-748) prints (observed):

```
== FILE (BACKEND)                       always (main.tcl:606)
...the program's own output...          native backends only, as written
   value: SHOWN                         ShowResult (main.tcl:596-601, :730)
   type:  NAME : TYPE                   -backend compile only, per top-level binding (:731-735)
   block #N refinements: ...            per Block in the value (:736-746, the "scope probe")
```

* SHOWN is `hir::decimal::Display` of the value at the static type of the
  HIR's last root (main.tcl:596-601, hir/decimal.tcl:998): the type-blind
  `core::value::show $value 1` (core/value.tcl:1008), except that a
  DecimalRounded value whose type states a precision shows its digits.
* Errors are printed on **standard output** as `   error: MESSAGE (CODE)`
  plus `help:` and `note:` lines (main.tcl:520-583), and the run exits 1 if
  any input failed (main.tcl:1018-1031). Warnings go to standard error.
* Every non-option argument is an input file (main.tcl:382): there is no
  way to pass arguments to the program but `-argv TEXT`, and several files
  run one after another, each with its header.
* The order -- header, output, value -- is a pinned property
  (POST-2048-PRODUCT-FIXES.md, S15; tests/native-program-output.test).
  Since S15 a native run's output goes straight to main.tcl's descriptors
  and its result comes back through `--result` (cited).
* The usage text says "Each program's output is printed, then its value"
  (main.tcl:302).

### 3.2 A standalone executable

`runtime::aot::run`'s body (native/src/runtime/aot.rs:277-322), shared by
the rustc, stub and system linkers' startups (observed):

* success: `writeln!(stdout, "{}", show(result))`, exit status 0; a failed
  write of that line is `NATIVE IO` on standard error and status 1;
* a Botlish or runtime error: `MESSAGE (CODE)` on standard error, status 1;
* a native stack overflow: the guard's `OVERFLOW_LINE`,
  `error {NATIVE LIMIT STACK} {native stack exhausted: too many nested
  calls}`, on standard error, status 1 (platform/mod.rs:36) -- the driver
  protocol's Tcl-list format, unlike every other executable error;
* `show` is native/src/runtime/show.rs:10's, the native mirror of
  `core::value::show`, with no static type.

### 3.3 Observed divergences between the surfaces

Run for this census (section 9) on Linux x86-64 with the rustc linker:

| program's value | `main.tcl` (interp) | `main.tcl -backend cranelift` | the executable |
|---|---|---|---|
| `[42, "two\nlines", 'c', {a: 1, b: true}]` | `   value: [42, "two\nlines", 'c', {a: 1, b: true}]` | the same | `[42, "two\nlines", 'c', {a: 1, b: true}]` |
| `0.1 + 0.2` (Float64) | `   value: 0.30000000000000004` | the same | `0.30000000000000004` |
| `0.1 + 0.2` as `DecimalRounded{minDecimalsPreserved: 2}` | `   value: 0.30` | `   value: 0.30` | `<DecimalRounded>` |
| a function `add` | `   value: <block (a b)>` and `   block #0 refinements: (none)` | `   error: the native backend cannot return a Block to the host ... (NATIVE UNSUPPORTED value)`, status 1 | `<block (a b)>` |
| examples/io/hello.bot (prints, ends in `unit`) | `   error: ... (CORE SEMANTIC NATIVE-ONLY)`, status 1 | `Hello, world!` then `   value: unit` | `Hello, world!` then `unit` |
| a runaway recursion | -- | `   error: native stack exhausted ... (NATIVE LIMIT STACK)` on stdout, status 1 | `error {NATIVE LIMIT STACK} {...}` on stderr, status 1 |

So the printed value is already not one contract: the CLI applies static
types the executable does not have (DECIMAL-ROUNDED-MILESTONE-1.md and
NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md, section 15, record the
`<DecimalRounded>` case as known), the CLI's native run cannot transport a
Block or a coroutine handle (show.rs:420-437; Compilerpedia's NATIVE
UNSUPPORTED value topic advises "end the program with data"), errors go to
standard output from the CLI and to standard error from the executable, and
main.tcl's own lines end in CRLF on Windows while a program's output is its
bytes (tests/native-program-output.test's `mainEol`).

## 4. Assumptions that have built up

### 4.1 In the language and the compiler

* **There is no `main`; the top level is the program, and its last
  statement is the result** (`concept.program-value`, concepts.topic:5996:
  "There is no `main` function: the top level is the program."). A
  top-level `return` is RETURN-OUTSIDE-CALLABLE (core/completion.tcl:71-73),
  whose topic advises "write the value as the last line instead of
  `return`. To leave early, put the code in a function and call it"
  (errors-control.topic:628-630): a program cannot end early except through
  structured control flow or a C `exit` (inferred).
* **"A result is shown, never owned."** An affine value as the program's
  result is AFFINE-ERASURE-UNSUPPORTED with exactly that reason
  (hir/affine.tcl:505, :569; errors-ownership.topic:536 "End the program
  with an unrestricted value"). The rule is sound on its own terms -- the
  value is released nowhere -- but its message states the printing.
* **The result must be transportable.** The native driver cannot hand a
  Block or a coroutine handle back to the host (show.rs:420-437), so
  `main.tcl -backend cranelift` rejects a program whose value is a function
  (errors-runtime.topic:1418-1466). An executable prints it.
* **The result's static type drives its display.** `ShowResult` reads the
  type of the HIR's last root (main.tcl:596-601) for DecimalRounded's
  precision (hir/decimal.tcl:992-1003); NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md
  calls `std::decimal_rounded::to_string` "the display main.tcl already
  printed for a program's DecimalRounded result" (cited, :187).
* **Blocks in the value are scope probes.** main.tcl prints the refinements
  visible in each Block of the value (header :221-223, code :736-746), and
  the interpreter keeps a finished program's frames alive when its value
  holds a Block, "for example as a refinement probe"
  (core/evaluator.tcl:732-739; docs/README.md:918). No test asserts a
  `block #N refinements:` line (grep of tests/).
* **A module file is not an entry program because of its last
  declaration.** REFACTOR-WARNINGS-CLEAN.md (:82-84, :373-378) records five
  modules that cannot compile as entry programs, three of them because "an
  entry program's value is its last declaration and theirs cannot be a
  value" (a context function, a trait-polymorphic function).
* **A function as the last statement is a use of it as a value**
  (hir/contexts.tcl:628-640; CONTEXT-FUNCTION-VALUE,
  errors-control.topic:1232: "This includes returning the function as a
  body's or the program's last expression").

### 4.2 At the process boundary

* **No exit status.** "Botlish has no exit-status facility, so the report
  is interpreted here" (tests/golden/run.tcl:14-18;
  GOLDEN-TEST-FRAMEWORK.md:398-403). Compilerpedia's
  `capability.process-exit-status` (capabilities.topic:68-87): "There is no
  `exit` operation ... Make the outcome the program's value and test it
  outside: ... a script compares the printed value." Icy Tower declares
  `extern c fn exit(status: std::ffi::c::Int) -> unit` with the comment
  "C's exit(3): the process's exit status, which Botlish cannot set"
  (examples/games/icy-tower/game.bot:45-46, :22-26), which exists only where
  C calls link and bypasses the runtime's own exit path (inferred).
  ICY-TOWER-VERTICAL-SLICE-1.md lists "a process exit status" as missing
  (cited, item 8); COMPILERPEDIA-REPORT.md's S10 the same.
* **The Tcl backends cannot print.** Every `std::io::IO` context
  (std::linux::io, std::darwin::io, std::windows::io) bottoms out in a raw
  syscall or a C call, which interp and compile refuse with NATIVE-ONLY by
  design: they "do not imitate a syscall" (core/linuxabi.tcl:55-60, :145;
  main.tcl:88-89). POST-2048-PRODUCT-FIXES.md keeps "S15's STDLIB half"
  open: "the Tcl backends cannot print" (cited, :158-160, :306). On the
  reference interpreter the printed value is the program's only output
  (observed: hello.bot on interp, section 3.3).
* **No portable input.** `std::io` is output only ("Not here
  (deliberately): input, files ..." stdlib/io.bot:33-35); reading standard
  input is `std::linux::io::read` or `std::darwin::io::read` on byte
  storage, native backends only; Windows has no standard-input operation
  (observed: stdlib/*/io.bot).
* **The executable's last line is part of its observable interface.**
  examples/linux/read-stdin.bot:23-25 documents its output as
  `hello from stdin` then `17  <- the bytes written (the runner prints the
  result)`; examples/linux/write.bot ends with the byte count.

### 4.3 In the documentation and the built-in reference

* README.md:72-79 shows `hello` printing `Hello, world!` then `unit`, with
  "(An executable prints its program's value last: here `unit`.)";
  README.md:241 introduces the tour with "Every program below runs, with
  the value shown ...".
* docs/README.md: :97 (`run natively: what it prints, then its value`),
  :143-158 (the Values table's Display column is the printer's format),
  :2291 (`# expect:` comments), :2661-2666 (an executable "prints the
  program's final value followed by a newline"; argv shown through the
  printed List), :2763-2764 (`<DecimalRounded>` from an executable),
  :2888-2900 (output between the header and the value line).
* Other design documents that state it: SINGLE-EXECUTABLE.md:30-31, :179;
  POST-2048-PRODUCT-FIXES.md section 2; 2048-ENGINE-WORKLOAD.md:193-194;
  MACOS-AARCH64-MILESTONE-5.md:316; FUZZING-EXAMPLES-AOT.md:82-84;
  OPAQUE-STRUCTS.md:249-252; ELIF.md:155; ICY-TOWER-VERTICAL-SLICE-1.md:520;
  MULTI-VALUE-RESULTS.md:77; IDIOMATIC-BOTLISH.md:70 (cited).
* main.tcl's header still says the value is shown "with runtime evidence
  shown as "text"#{Type}" (main.tcl:85): stale since REFINEMENT-VALUES.md
  removed runtime evidence (core/value.tcl's display comment).
* AGENTS.md's "Native program output" rule (AGENTS.md:5007-5014) pins how
  main.tcl's native runs share its descriptors (`-output inherit`, results
  through `--result`, never a pipe parsed for results). It does not require
  the value line, and a removal keeps it.
* **Compilerpedia makes the printed value part of its teaching.**
  `task.print-output`: "on every backend the program's value is printed for
  you" (tasks.topic:209); `concept.program-value` (above); `cli.output` (the
  "value line", backends.topic:791-831); `cli.exit-status` ("0 after
  printing the program's value", :833-856); `backend.native-executable`
  (:129-143); `backend.io` ("The program's value is printed on every
  backend", :424-468); `backend.native-only` and errors-runtime.topic:211-214
  ("return the result as the program's value, which every backend prints");
  `capability.process-exit-status` (above); concepts.topic:4953 ("The report
  is a value: make it the program's value"). Its examples state the value:
  379 `@value` lines (259 in hand-written topics, 120 generated from
  notes/stdlib.notes) against 380 accepting examples, and 3 `@output`
  examples (COMPILERPEDIA.md:140-179: "end such a program with a plain
  `0`"). `tools/compilerpedia.tcl check` evaluates `@value` examples
  in-process through `cpt::Shown`, a copy of main.tcl's `ShowResult`, and
  runs an `@output` example through main.tcl, requiring its `   value:` line
  as well (cited: tools/compilerpedia.tcl:738-886).
* packages/raven/GUIDE.md:264, shipped in the raven artifact: "A Botlish
  program cannot choose its exit status: a test reports its verdict as its
  value (`botlish` prints it), which a script can check." Its clean-room
  experiment greps `'^   value: "TEST PASS: '`
  (audit/raven-cleanroom/results/agent-experiment/run-test.sh:18).

### 4.4 In the examples and workloads

* Of 104 `.bot` files under examples/, 67 are entry programs; about 50 of
  them print nothing and exist to show their value (lists of Booleans in
  examples/ffi/*/demo.bot, `std::event_loop::trace()` in the event-loop
  examples, `summary` in icy-tower/headless.bot, raven/main.bot's click
  count). 25 carry `# expect:` and 2 `# expect-error:` comments (plus 5 in
  examples/hir/ and 11 in bench/), which tests/surface-samples.test,
  audit/refactor/tools/expect.tcl and bench/bench.tcl check in-process with
  `core::value::show $result 1`: the convention states the value in the
  printer's format but reads no printed output.
* Printing programs end in a value they do not want: io/hello*.bot and the
  2048 demos end `on std::io::WriteFailed: unit`, so their executables'
  last line is `unit` (pinned by tests/workload-2048.test:128-164).
  examples/dfa/csv/export.bot "writes a file rather than standard output"
  because of the trailing line (CSV-EMISSION-VALIDATION-MILESTONE-1.md:650-653,
  :924-926: "a program whose standard output is its product (a CSV
  exporter writing to a pipe) cannot avoid the trailing line").
  audit/dfa/tools/differential.tcl:224-226 drops the line ("The executable
  prints the program's value, unit, last.").
* Icy Tower's entry programs end with `result`, the String `game::main`
  returns -- "the run's summary line" (game.bot:22) -- so the executable's
  last line is that summary, quoted; in `--headless` mode it is the
  executable's only output (section 4.6). `--help` prints the usage and
  returns `"help"` (game.bot:189-192), so `icy-tower --help` should end
  with a `"help"` line (inferred from the code; not run: it needs SDL3).
* The fuzzers parse the value off the output: FUZZING-ARGV-PROGRAMS.md:343-349
  and :376-381 ("the aot value is the trailing integer of stdout", "value
  possibly glued to the echo"), fuzz/scripts/replay.tcl:255-264,
  FUZZING-JSON.md:52-54 ("the aot value line dropped"),
  fuzz/windows/replay-json.ps1:74 (`# drop the value line`).

### 4.5 In the tests

Section 6 classifies them. The scale (observed, greps of tests/):

* about 9,850 `test` definitions in 266 files and 117 golden suites;
* the in-process value is the oracle of the large majority:
  `outcomeUnderHir` 390 call sites in 117 files, `sourceAgree` 198 in 46,
  `outcomeUnder` 76 in 36, direct `native::evalHir` 132,
  `core::evalProgram` 106, `core::compiler::evalHir` 47 -- unaffected by a
  removal of the printing;
* about 125 tests run main.tcl or `botlish` as a process, about 75 of them
  reading a `value:` line; no helper in tests/helpers.tcl wraps main.tcl
  (each file has its own: main-cli.test's `runMain`, main-recursion.test's
  `mainValue` with `regexp {^   (value|error): (.*)$}`,
  native-program-output.test's `mainRun`, target-model.test's `tmMain`, ...);
* about 300 tests in about 70 files build or run an executable, through
  `runStandalone` and `runBare` (tests/helpers.tcl:194, :233), which return
  the whole standard output: for a program that prints nothing, exactly
  the printed value;
* the golden manifest tags 216 rows `MAIN-TCL` (NOT-EXPRESSIBLE 197, DIRECT
  14, HARNESS-DIFFERENCE 5) and 372 `STDOUT` (NOT-EXPRESSIBLE 330).

### 4.6 In tools, scripts and CI

Outside tests/*.test (observed, greps and reads of .github/, single/,
bench/, audit/, fuzz/, tools/, tests/platform/):

**They read main.tcl's `value:` line** (they would break):

* CI: windows-x86_64.yml:249-254 runs fib.bot, uri-steady and the 2048
  benchmark under main.tcl and compares `sed -n 's/^   value: //p'` with
  the expected value (plain, GC stress, unwind check).
* The shipped compiler's acceptance: single/smoke-test.sh compares every
  backend's `== ` and `value:` lines with interp's (:113-118), greps about
  ten exact value lines (:174-305) and the whole hello transcript
  `== hello.bot (BACKEND)`, `Hello, world!`, `   value: unit` (:211);
  single/ffi-smoke-test.sh:330-331; single/macos/app-test.sh about a dozen
  `*"value: ..."` matches. single-executable.yml and macos-arm64.yml run
  them, and audit/single-executable/tools/mutate.tcl and
  audit/macos-app/tools/mutate.tcl judge their mutants by them.
* bench/actor.tcl:47-54 (`regexp {^\s+value: (.*)$}`, an error if absent).
* Audit tools: equality-semantics/tools/run.tcl and probes.tcl,
  trait-impl-context-trait/tools/run.tcl, thread-actor/tools/run.tcl and
  native-app.tcl, icy-tower/context-refactor/tools/repro.tcl (which AGENTS.md
  names as a check to run), windows-toolchain/tools/probe.tcl,
  aot-state-2026-09-28/run.py, and the raven clean room
  (acceptance/inside.sh, results/agent-experiment/*.sh).
* tools/compilerpedia.tcl:853-864 for the 3 `@output` examples.
* fuzz/scripts/replay.tcl:247-320, which reads both channels ("in-process
  stdout: `   value: V`", "aot stdout: V") and filters `== `, `value:`,
  `help:`, `type:` and `block ` lines.

**They read an executable's last line** (they would break):

* CI: windows-x86_64.yml:273-284 (fib's and 2048's values from the
  executables, plain, GC stress, unwind check) and :330-341
  (`printf 'Hello, world!\nunit\n' > wio/hello.expected`, compared for a
  file, a pipe, cmd and PowerShell); macos-arm64.yml:584-585
  (`[ "$(./identity)" = "[1, 1]" ]`).
* single/smoke-test.sh:157, :223, single/ffi-smoke-test.sh:204-212 and
  :280-284, single/macos/app-test.sh (:153, :219, :390-397, :414).
* tests/platform/gc-workloads.tcl:105-121 (the executable's trimmed output
  against the compile backend's value), aot-facts.tcl:409-413, :635-643,
  native-status.tcl:613, :625, link-plan-sdl3.sh:159-162.
* bench/golden-aot.tcl:51-53 (the golden report's `P passed, F failed` from
  an executable's printed value).
* audit/dfa/tools/differential.tcl:224-226 drops the last line
  unconditionally: after a removal it would silently drop a line of real
  output. audit/abi-bytes/tools/fuzz.tcl:505-511 and
  audit/mutable-bytes/tools/fuzz.tcl (:553-669) compare the printed counts
  with their oracles; audit/macos-graphical-main-thread/tools/census.py:122
  parses "the Botlish program's printed value" as the last line.
* **Icy Tower's headless mode prints nothing but its value**:
  `game::headless` returns the summary String (game.bot:170) and the entry
  program's value is that String, so audit/icy-tower/oracle.py:180-182
  (`stdout.strip().strip('"')` against its own `summary`),
  tools/xvfb-session.py and tools/macos-session.py read the summary from
  the printed value. After a removal the game would have to print it.
* fuzz/baselines/*.tsv (32 files) record executables' bare printed values.

**They compare two runs' outputs** (they would pass vacuously, comparing
two empty outputs): icy-tower-macos.yml:272-275 and
icy-tower-windows.yml:164-171 (two copies' `--headless` output),
single/macos/compare.sh (`both`), bench/c-ffi-error-capture.tcl:397-398.
These are the dangerous ones: they keep passing while checking nothing.

**Unaffected**: everything built on the driver protocol -- most of bench/
(bench.tcl and 2048.tcl through `native::measure`; 47 files use
`native::evalHir`, `measure`, `Driver` or `Outcome`) and 63 audit tools;
the `# expect:` readers (audit/refactor/tools/expect.tcl and
bench/bench.tcl evaluate in-process; fuzz/scripts/inventory.tcl only
records them); pm/, packages/, lsp/, service/, editors/; native libraries;
and the Rust tests (none checks an executable's printed value).

## 5. The printed value against Botlish's own text formatting

The printer is `core::value::show` (core/value.tcl:1008) and its native
mirror `show` (native/src/runtime/show.rs:10, :107-289), checked against each
other by tests/value-display.test. What Botlish code can produce as a String
is what `std::int`, `std::decimal_rounded`, `std::str` and `std::char` offer
(observed: the registry, compilerpedia/generated/stdlib.topic):

| value | printed as | Botlish code's own text |
|---|---|---|
| Int | `42` | `std::int::to_string` -- the same canonical text (one formatter per runtime: NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md) |
| Float64 | shortest round-trip decimal, `0.30000000000000004` | **none**: no `std::float64::to_string` (deliberately deferred, NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md section 14: "A Float64's own digits still reach the user only as a program's printed result"); `std::float64::round` then `std::int::to_string` gives an Int's digits |
| DecimalRounded | CLI: its digits at the static type's precision (`0.30`); executable: `<DecimalRounded>` | `std::decimal_rounded::to_string` -- the CLI's digits, never the executable's |
| String | quoted and escaped: `"two\nlines"` | the text itself; quoting and escaping by hand (test.bot's `quoted`, `escaped`) |
| UnicodeChar | `'c'` | `"".append_char(c)`, unquoted |
| Bool | `true` / `false` | none; an `if` choosing a literal |
| `unit` | `unit` | -- |
| List | `[a, b]`, elements rendered recursively | a loop and `std::str::concat`; no join (test.bot writes its own `joined`) |
| struct | `{a: 1}` / `Name {a: 1}`, fields in slot order | by hand, per struct: no reflection over fields |
| opaque struct | `<opaque M::T>` | only through the owner module's API |
| enum case | `Name::Case`, "debug rendering only (ENUMS.md): ... never a String conversion or a serialization contract" (core/value.tcl:1033-1036) | none generically: case names, ordinals and `case_name` are excluded by design (ENUMS.md); a `match` by hand |
| ImmutableSet, MutableVector, MutableArray, Result | `{...}`, `<mutable-vector [...]>`, `<mutable-array [...]>`, `ok(v)` | iteration and concatenation by hand |
| function, native, coroutine | `<block (a b)>`, `<native +>`, `<coroutine>` | none |
| C pointer, raw C float | `<C pointer 0x...>`, `<C float 0x...>` | none for pointers (no `Ptr -> Int`); a raw float's bits as an Int, in decimal |

Three differences matter for a removal:

* **The printed value is not text output.** It is one line of literal-like
  debug rendering per program, never the program's text: a String is
  quoted and escaped, so even a program whose value *is* its output cannot
  produce raw bytes, several lines, or no trailing newline through it. A
  utility has to print through `std::io` (or `std::linux::io::write` for
  bytes) whether or not the value is printed.
* **It is the only renderer of what Botlish code cannot format.** Float64
  digits, enum names and generic structure are reachable only through it.
  `stdlib/test.bot`'s `describe` (:282-298) is a Botlish re-implementation
  for Int, String, Bool and List, and says "a value with no text form" for
  the rest; it builds brackets and quotation marks from a one-character
  table (`glyph`) because of the ONE-CHAR-STRING-LITERAL warning. What else
  is absent is listed in NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md section 15:
  Float64 text, padding, alignment, format strings and interpolation.
* **It knows static types only under main.tcl.** The CLI's display is
  `hir::decimal::Display` at the result's static type; the executable has
  only the run-time value. A removal makes that disagreement moot; a
  replacement that keeps a debug display would have to pick one.

## 6. Can the output assertions become golden tests?

**What a golden test can observe.** A golden suite is an ordinary program
whose value is its report; tests/golden/run.tcl runs it in-process on the
four backends (`native::evalHir`, `core::compiler::evalHir`,
`core::evalProgram`) and reads the report from the returned value
(run.tcl:101-135). It never reads printed output, and cannot: "What Botlish
cannot observe -- HIR, Core IR or NIR text, allocation or release counts,
warnings, stdout -- stays in the Tcl suite" (tests/golden/README.md:148-150),
and `native::evalHir` drops what a program writes by default
(tests/native-program-output.test's `native-output-evalhir-discards`). A
golden test cannot run main.tcl, an executable, argv, a descriptor or an
exit status.

So the golden framework is **independent of the printing** -- a removal
leaves it untouched -- but **dependent on the value** (row 1 of section 2)
and on the driver's result protocol for its native legs. A removal must keep
both.

**The tests that read printed output**, classified (sizes approximate):

| class | what the test checks | tests | golden? | after a removal |
|---|---|---|---|---|
| (i) the presentation itself | the exact header, output and value bytes: native-program-output.test (11), value-display.test, decimal-rounded.test's `dr-main-display` and executable `<DecimalRounded>` case, direct-hir-native.test:288 (`value:` and `type:` lines), main-cli.test's `cli-explicit-ir-still-runs`, native-executable.test's `output-kinds`, opaque-struct.test:1395, system-linker and aot-stub-linker "prints its value" | 35-40 | no: it is the feature | rewritten or removed with it |
| (ii) the printed value as an oracle of a computation | an executable's value equals the in-process value: the `aotParity` family (native-executable, exact-callable-executable, loop-collecting, packed-ascii, raw-int-abi, short-string, string-allocation), `flAotParity`, `maAotParity`, `mcAotParity`, `executableParity`, `executableValue` (direct-hir-native and five others), struct/enum/dormant-instance parity, tests/platform/gc-workloads.tcl and aot-facts.tcl | 50-60 | the computation, yes -- and it already is: the in-process side of each test checks it, and 14 of these rows are DIRECT golden ports (callable-contracts.bot, loop-collecting.bot, mutable-array.bot, bits-bytes-hashing.bot) | what remains is "the executable runs, relocated, with an empty PATH, under GC stress": a process test that needs the program to print, class (iii) |
| (iii) process behavior observed through the value line | the warning CLI (warnings, fixed-arity-list-return, many-boolean-arguments, method-eligible, one-char-string-literal, proves-naming, same-failure: 44 tests, about 26 reading `value:` to mean "it ran"); fresh-process, working-directory, bundled-compiler and interchange tests (16); main-recursion.test (5); linked runs under main.tcl (c-ffi, system-linker, darwin-io, windows-io, workload-2048, main-thread-startup: 11); executables at the boundary (abi-bytes 22, abi-mutable-bytes 20, argv 20, system-linker 14, native-link-plan 14, c-ffi 14, main-thread-startup 17, filesystem 6, c-ffi-error-capture 6, aot-stub-linker 6, c-bindgen 5, c-byte-borrowing 5, linux-syscall 4); and executables whose expected output is the program's text *plus* the trailing value (contexts.test:763 `"Hello, world!\n14\n"`, portable-io, darwin-io, windows-io, coroutines.test:846, workload-2048) | about 200 | no: argv, descriptors, linking, a fresh process, the CLI's warning policy are exactly what golden tests cannot observe | each must print what it checks (`std::io::print_line`, or bytes), drop the trailing line, or check an exit status; the Tcl-backend ones (main-recursion, the warning CLI on interp) have no output to switch to |

The manifest agrees: of its 216 `MAIN-TCL` rows 197 are NOT-EXPRESSIBLE,
and of its 372 `STDOUT` rows 330 (observed, tests/golden/manifest.tsv).

**Conclusion.** Golden tests can replace none of the printed-output
assertions as such; they can only carry the computation an assertion
happens to check, and for class (ii) the suite already does. The honest
replacement for classes (ii) and (iii) is explicit program output plus an
exit status, in the same Tcl tests. In the other direction, golden suites
could one day run as ordinary utilities -- print their report through
`std::io`, exit 1 on a failure -- once Botlish has an exit status and the
Tcl backends an output channel; until then the runner's interpretation of
the value is the design (GOLDEN-TEST-FRAMEWORK.md, "Exit status").

## 7. What else blocks a removal

In dependency order; the first three are capabilities, the rest are
contracts and consumers.

| # | blocker | where | what it needs |
|---|---|---|---|
| B1 | **No exit status.** A utility cannot report failure except by an uncaught run-time error; the golden runner, Raven's guide, Compilerpedia and Icy Tower's C `exit` all work around it. | section 4.2 | an exit-status facility (an `std::process` operation, or a decided meaning for an Int value) on every backend, including the Tcl ones and the driver protocol |
| B2 | **The Tcl backends cannot print.** With the value gone, `main.tcl -backend interp` shows a program nothing at all, and the reference interpreter's CLI tests (main-recursion, the warning-CLI family) lose their only observable. | core/linuxabi.tcl:55-60; POST-2048 S15 | either an `std::io::IO` context the Tcl backends can run -- not through the syscall transports, which they refuse to imitate by design, so a new output operation of their own, a decision against the I/O sections of AGENTS.md ("no compiler knowledge of printing") -- or a debug display of the value that the CLI keeps for them |
| B3 | **No text for Float64 and no generic formatting.** Removing the printer removes the only route of a Float64's digits, an enum case's name and a struct's rendering to the user. | section 5 | `std::float64::to_string` (NUMERIC-TEXT's deferred decision), or a retained debug display |
| B4 | **Compilerpedia's contract.** 379 `@value` examples (checked in-process: unaffected), 3 `@output` examples whose check requires a `value:` line, and the topics of section 4.3 that teach the printed value and its workarounds. | compilerpedia/topics/, tools/compilerpedia.tcl:853-866 | the topics rewritten in the same change (`tools/compilerpedia.tcl check` fails otherwise), the `@output` check's value requirement dropped |
| B5 | **Rules and messages that mention the shown result.** AFFINE-ERASURE-UNSUPPORTED's "a result is shown, never owned"; the NATIVE UNSUPPORTED value refusal, which applies wherever the value is handed to the host -- main.tcl's native runs, to print it, and the in-process test helpers. | hir/affine.tcl:505, :569; show.rs:420-437 | reword the first; decide whether main.tcl still fetches a value it no longer prints (if not, a program ending in a function runs under main.tcl's native backends as it does in an executable); an affine result stays an error (nothing owns it to release it) |
| B6 | **CLI features hung on the value line.** `-backend compile`'s `type:` lines and the Block refinement probes print only beside the value. | main.tcl:731-746 | keep them under an inspection option, or drop them |
| B7 | **Process tests read the value line** (section 6, classes (ii) and (iii)). | about 250 tests | rewritten to explicit output and exit status, after B1 and B2 |
| B8 | **Scripts, CI and the fuzzers read it.** Four CI steps, the single-executable and Botlish.app acceptance scripts (and the mutation harnesses judged by them), four tests/platform scripts, about ten audit tools, Icy Tower's oracle and session drivers, the fuzz replay and its 32 baselines. Four comparisons of two runs' outputs would keep passing on empty output, and the DFA differential would silently drop a real line. | section 4.6 | updated in the same change; the vacuous comparisons given a non-empty expectation first; Icy Tower's headless mode made to print its summary |
| B9 | **Documentation.** README.md's hello transcript, docs/README.md's sections, the design documents of section 4.3, packages/raven/GUIDE.md (shipped in an artifact: a raven release changes its contents, so a new version) | section 4.3 | rewritten; GUIDE.md through a new raven release |
| B10 | **No portable input, no program arguments through the CLI.** Not caused by the printing, but a utility needs them: `std::io` has no read, Windows none at all, and main.tcl takes every argument as an input file (`-argv` aside). | stdlib/io.bot:33-35; main.tcl:382 | a portable read; a `run` form of the CLI that passes arguments |

**Not blockers** (observed): the driver protocol's `value` line (an internal
transport, written to a file when the program owns standard output), the
golden runner, `native::evalHir`, `-check`, the language server and the
compiler service (they never run a program), native libraries
(`exported c fn` has no program value at its boundary), and the in-process
test helpers.

## 8. What a removal has to decide

The census suggests these decisions, in this order; each recommendation is
the one the evidence above points to.

1. **Keep the value; remove its printing.** The value stays the result of
   `core::evalProgram`, `core::compiler::evalHir`/`evalUnit` and
   `native::evalHir` and of the driver protocol. Removing it would break
   the golden framework, Compilerpedia's checker and thousands of tests for
   no gain.
2. **Give programs an exit status first (B1).** Without it a utility cannot
   say "no match" or "bad input", and an executable that stops printing
   loses the only success signal scripts have today. Whether it is an
   operation (`std::process::exit(status)`-like, which needs a meaning on
   the Tcl backends and in the driver protocol) or a meaning given to the
   program's value is a language decision; the second would keep the value
   load-bearing and re-create this census's problem for Int-valued
   programs.
3. **Executables: print nothing on success.** Their error path (message on
   standard error, status 1) is already a utility's; the overflow line's
   Tcl-list format could become `MESSAGE (CODE)` like the rest.
4. **main.tcl: separate running from inspecting.** The current mode is a
   development tool whose header and value line the test suite, the smoke
   tests and Compilerpedia rely on, and which is the Tcl backends' only
   output (B2, B3). A distinct way to run a program as a utility -- no
   header, no value, the program's own arguments, its exit status -- unblocks
   utilities without first solving B2 and B3; a later step can make the
   value line opt-in.
5. **Then migrate the consumers** (B4-B9) in the change that flips each
   default, the process tests of section 6 to explicit output.

## 9. Method

Read and grepped in this checkout at `f643566`: main.tcl, core/value.tcl,
core/evaluator.tcl, core/completion.tcl, core/linuxabi.tcl, hir/decimal.tcl,
hir/affine.tcl, hir/contexts.tcl, native/src/main.rs,
native/src/runtime/{aot,show}.rs, native/native.tcl, stdlib/{io,test}.bot,
stdlib/*/io.bot, tests/golden/run.tcl, tests/helpers.tcl, the tests, tools,
workflows, documents, Compilerpedia topics and examples cited above, and
tests/golden/manifest.tsv (its `MAIN-TCL` and `STDOUT` notes and `class`
column).

Run, with Tcl 9.0.1 and a release build of `native/`, `LANG=C.utf8`, in a
scratch directory:

```sh
tclsh9.0 main.tcl -backend interp|compile|cranelift FILE.bot
tclsh9.0 main.tcl -emit-native-executable FILE.bot && ./FILE
BOTLISH_NATIVE_STACK_BYTES=1048576 ./deep
```

for the programs of section 3.3: a List of an Int, a String with a newline,
a character and a struct; `0.1 + 0.2` as a Float64 and as
`DecimalRounded{minDecimalsPreserved: 2}`; a program ending in a function;
examples/io/hello.bot; and an unbounded recursion. No test suite was run.
