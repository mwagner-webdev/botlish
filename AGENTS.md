# Notes for agents working in this repository

## Git workflow

Push finished work directly to `main`. This project does not use a
feature-branch-plus-pull-request review cycle: don't open a PR unless
explicitly asked to.

## Documentation layout

The root `README.md` is the project overview. Everything else is in `docs/`:
`docs/README.md` is the language and implementation reference (the former
root README), and every design document, milestone report and audit this
file names (`DIRECT-HIR-NATIVE-PATH.md`, `COROUTINES.md`, ...) is
`docs/NAME.md`, listed in `docs/INDEX.md`. Code comments, tests and the
documents themselves cite them by bare name too. A comment citing "README
§N" or a README section by name means `docs/README.md`, unless it sits
beside a README of its own (`tests/golden/README.md`, an `audit/`
directory's). A new design document goes in `docs/`, with a line in
`docs/INDEX.md`, never in the repository root; a link in one to a file
outside `docs/` starts with `../`.

## Compiler architecture (three representations)

* **HIR** (`hir/`) is the authoritative semantic representation; every analysis
  fact lives in it or in its side tables.
* **Core IR** (`core/`) is the small executable representation of the Tcl
  reference interpreter. HIR lowers to it (`hir::lower`); neither compiler
  compiles from it.
* **The Tcl compiler** (`compiler/`) compiles HIR as a front end built it
  (`core::compiler::evalHir`, or `compileHir` once and `evalUnit` per run). Its
  core IR entry points (the registered `compile` backend through
  `core::evalProgram`; `generatedCode`, `programTypes`, `bindingTypes`,
  `unitHir`) are for core IR *text* someone wrote, which `hir::build` reads
  into HIR. Never hand them the output of `hir::lower` for a HIR you have:
  that rebuilds a weaker HIR (no declared types, module identity, `errors`
  clauses). Compile the HIR (`tests/direct-hir-native.test`'s
  `direct-hir-compile-*` tests guard this; DIRECT-HIR-NATIVE-PATH.md, "The
  Tcl compiler compiles HIR").
* **NIR** (`native/`) is the production executable representation. Native
  compilation starts from resolved, analyzed HIR (`native::lowered`,
  `native::evalHir`, `native::executable`, ...) and never goes through Core IR:
  do not add a native entry point that accepts Core IR, and do not lower HIR to
  Core IR and rebuild HIR from it (`tests/direct-hir-native.test` guards this).
  `DIRECT-HIR-NATIVE-PATH.md` has the details. Tests that run Core-IR-text
  programs on `cranelift` or `compile` do so through harness backends in
  `tests/helpers.tcl` that hand the compiler the HIR the program was lowered
  from (or read hand-written IR text into HIR); they are not production entry
  points.

## Compilation isolation

A compilation registers its declarations in process-wide registries that the
analyses and the backends read by bare name: the source-defined entries of
`core::type` (a domain or a refinement; a type registers no native),
`hir::structs`, `hir::enums`, `hir::errordecls`, `hir::traits`,
`hir::imports` and `hir::layouts`. Every HIR records the state its build left behind (its
`declarations` side table, `hir/declarations.tcl`), and every entry point that
reads the registries for a HIR it is given calls `hir::activate` first, so
compiling another program never changes an earlier HIR's lowering or run
(COMPILATION-ISOLATION.md). Two rules keep it so:

* A new registry -- process-wide state a build fills from the program's
  declarations and something reads later -- goes into
  `hir::declarations::capture` and `Install`.
* A new entry point that reads the registries for a HIR it is given (a
  backend, an analysis a tool calls, a printer) calls `hir::activate $hir`
  before reading anything. Code that writes the registries (a build, a read
  of HIR text) calls `hir::declarations::invalidate` first and stamps the
  HIR it returns.

If you change either, or what a build or `hir::read` registers, run
`tests/compilation-isolation.test`,
`audit/compilation-isolation/tools/interleave.tcl` (every golden suite's
artifacts and outcomes, right after its own compilation and after all the
others, must be identical) and `audit/compilation-isolation/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed). Core IR
text has no declarations: core IR kept and run on a Tcl backend after another
compilation still reads the later one's (run a HIR, or lower it again).

## HIR interchange

`hir/interchange.tcl` (HIR-INTERCHANGE.md) writes an analyzed HIR as text --
`main.tcl -emit-hir-interchange` writes `FILE.hirx`, which `main.tcl` runs on
any backend -- and reads it back in any process with the same front end, as if
it had just been built. It holds the HIR dict itself (minus `traitSource`)
and relies on compilation isolation for the rest: everything a backend reads
must be in the HIR, its side tables or its `declarations`. So a new fact a
backend reads from process state, rather than from the HIR, breaks it the way
it breaks isolation. Text is valid for the front end that built it only (a
fingerprint of `core`, `hir`, `surface` and stdlib's Tcl libraries; the backends
are left out because they never shape a HIR -- keep it so: a backend must not
define or change a front-end procedure or register a type or native). Never
add a way to skip that check or to read another front end's text; a front end
written in Botlish needs a specified schema and a validating reader first (a
format version 2).

The front-end cache (`surface/cache.tcl`, opt-in through `BOTLISH_HIR_CACHE`
or `surface::readProgramFile -cache DIR`; the test harness unsets the
variable) keeps program files' HIRs in that format. A hit must equal the
build, so the key and the dependencies must hold everything a build reads: if
the front end starts reading another input -- an environment variable, a file
other than an imported module, an option of `compileProgramFile` -- add it to
`surface::cache::Key` or `Dependencies`, never leave it out.

If you change what a backend reads, the HIR's side tables, the format, the
cache or what the front end reads, run `tests/hir-interchange.test`,
`tests/hir-cache.test`, `audit/hir-interchange/tools/roundtrip.tcl` with
`-via interchange` and `-via cache` (every HIR, artifact and outcome of the
suites, written and then read by a fresh process that runs no build, must be
identical; `-suites all` for the whole corpus) and
`audit/hir-interchange/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule).

## Installing Tcl 9

This project's reference evaluator requires Tcl 9.x (`core/core.tcl` checks
this at load time and refuses to run under older Tcl versions, since
Botlish's String semantics count Unicode scalar values, and older Tcl builds
cannot represent astral characters correctly). The canonical baseline for
this repo is `tclsh9.0`.

Do **not** build Tcl 9 from source (slow, and easy to get subtly wrong).
Instead, install it exactly the way `.github/workflows/tests.yml` and
`.github/workflows/bench.yml` do: three `.deb` packages pulled straight from
Ubuntu 25.04 (plucky)'s universe pool, installed with `dpkg -i`:

```sh
set -eu
cd /tmp
base=http://archive.ubuntu.com/ubuntu/pool/universe
curl -fsSLO "$base/libt/libtommath/libtommath1_1.3.0-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/tcl9.0_9.0.1+dfsg-1_amd64.deb"
sudo dpkg -i libtommath1_1.3.0-1_amd64.deb libtcl9.0_9.0.1+dfsg-1_amd64.deb tcl9.0_9.0.1+dfsg-1_amd64.deb
echo 'puts "Tcl [info patchlevel], tcltest [package require tcltest 2.5]"' | tclsh9.0
```

On arm64 the same three packages, with `arm64` for `amd64`, come from
`http://ports.ubuntu.com/ubuntu-ports/pool/universe` (`.devcontainer/setup.sh`
picks by `dpkg --print-architecture`).

This installs the `tclsh9.0` binary and it is the canonical baseline for
this repo. Use `tclsh9.0` to run everything in this repo (`tests/all.tcl`,
`main.tcl`, `bench/*.tcl`, etc.), matching CI.

Also set `LANG=C.utf8 LC_ALL=C.utf8` (glibc ships `C.utf8` built in, no
`locale-gen` needed): Tcl 9's I/O encoding profile is strict by default,
and with no locale the system encoding falls back to `iso8859-1`, which
makes writing non-ASCII/astral output fail outright instead of being
silently mangled.

### Tcl's `expr` reads a numeric-looking result as a number

`expr` converts its result to a number when the result string looks like
one: `expr {$c ? $name : ""}` is `Inf` for the name `inf` or `infinity`
and a domain error for `nan` (any letter case, and a one-element list of
such a name). Botlish names and String text are strings in the compiler,
so the compiler never selects a value that may be a string with `expr`'s
`?:`. Write `if` (a statement, or `[if {C} {set a} else {set b}]`) or
`[dict getdef D K DEFAULT]` instead. A ternary over numbers, or over
constant strings that do not read as numbers, is fine.
`tests/numeric-looking-names.test` checks the sources for the rule
(`nl-no-string-ternary`) and compiles programs with such names against the
same programs renamed (FLOAT64-MILESTONE-1.md, section 16). Compare
strings with `eq`/`ne`, never `==` (`"nan" == "nan"` is false,
`"inf" == "Infinity"` true).

### Known Tcl core bug: compiled `incr` wraps instead of promoting at the i64 boundary

Confirmed directly (BYTE-NIBBLE-BIT-ARITHMETIC.md's own account has the full
trace) and **still present as of Tcl 9.0.4 and the 9.1a1 alpha** -- not
fixed upstream, so there is currently no newer version to pin instead.
A minimal standalone reproduction, for filing an upstream bug report, is
committed at `tcl-incr-i64-wrap-bug.tcl` (run with `tclsh9.0
tcl-incr-i64-wrap-bug.tcl`):

```tcl
proc p {} { set v 9223372036854775807; incr v; return $v }
puts [p]   ;# -9223372036854775808 -- WRONG (silently wraps)

set v 9223372036854775807
incr v
puts $v    ;# 9223372036854775808  -- correct (typed at tclsh's own top level, not compiled)
```

`incr` as it runs inside a compiled `proc` (`generic/tclExecute.c`'s
`INST_INCR_SCALAR1_IMM`/`INST_INCR_SCALAR_IMM` handler) computes the
overflow-detecting sum correctly, but on the *overflow* branch re-derives
the result via plain `Tcl_WideInt` addition (`TclNewIntObj`/`TclSetIntObj`
with `w + increment`) instead of promoting to a bignum -- the exact
computation that just overflowed, repeated, then stored as if it hadn't.
Verified via direct source diff across `core-9-0-1`, `core-9-0-2`,
`core-9-0-3`, `core-9-0-4` and `core-9-1-a1` (github.com/tcltk/tcl): the
relevant lines are byte-for-byte identical in every one of them; none of
their release notes mention it. `incr` typed directly at tclsh's
interactive top level (uncompiled) is unaffected -- only code inside a
`proc`, where bytecode compilation applies, hits this.

**Practical consequence for any code in this repo**: never use `incr` in a
loop whose counter could plausibly reach `i64::MAX`/`i64::MIN`
(9223372036854775807 / -9223372036854775808) -- use
`set v [expr {$v + 1}]` instead, which correctly uses Tcl 9's ordinary
arbitrary-precision `expr` arithmetic. Botlish's own `Int` is
arbitrary-precision (this project's whole point), so any Tcl-side loop that
iterates over or reconstructs a range of Botlish Int values is a candidate
for this -- `hir/range.tcl`'s `ExactOf` hit it exactly this way; see that
file's own comment.

**Do not "fix" this by pinning a newer Tcl 9**: no released or alpha
version fixes it (checked above), and the Ubuntu packages newer than
`9.0.1+dfsg-1` (`9.0.2`, `9.0.3`, `9.0.4`, all still in the same `universe`
pool path) require `glibc >= 2.42`, which this sandbox's (and, as of this
writing, GitHub Actions' `ubuntu-latest`) base image does not have --
installing one over `9.0.1` breaks `tclsh9.0` outright (`GLIBC_2.42' not
found`) until it's downgraded back. `9.0.1` remains the correct pin for
both this reason and because it is not actually behind on this specific
bug.

## Building the native (Cranelift) backend

`cargo build --release --manifest-path native/Cargo.toml` needs a rustc new
enough for the pinned `cranelift-*`/`wasmtime-internal-*` crates (rustc
1.95+; the sandbox's preinstalled toolchain can be older and will fail with
"is not supported by the following packages"). Fix with:

```sh
rustup toolchain install stable --profile minimal
rustup default stable
```

then build as usual. Without this, `cranelift`/`cranelift-generic` tests
and benchmarks report `{error {NATIVE NOT-BUILT}}` instead of running.

## The single-file compiler and the stub linker

`single/build.sh` builds `single/out/botlish` (SINGLE-EXECUTABLE.md): a Tcl 9
zipkit holding main.tcl, the compiler stack, both native executables and the
runtime archive, needing only glibc (and, to link a program that calls C,
the host's C compiler driver: SINGLE-EXECUTABLE-FFI-MILESTONE-1.md). The workflow `.github/workflows/single-executable.yml`
builds it on every push to `main` and smoke-tests it in stock Ubuntu
containers (`single/smoke-test.sh`), then publishes it as the
`botlish-linux-x86_64` asset of the rolling `single-latest` prerelease. The
README's download button links to that tag and asset name: rename either
only together with the button. Its base kit is a static tclsh that the
script builds once from the pinned Tcl 9.0.1 source release. That build is
the one exception to "do not build Tcl 9 from source" above: no package ships
a static zipfs tclsh. `--basekit PATH` uses a prebuilt zipkit instead. To run
the test suite, still install the `.deb`s.

* `single/package.tcl` packs exactly main.tcl, LICENSE, `core/`,
  `compiler/`, `hir/`, `surface/`, `service/`, `lsp/`, `native/*.tcl`, `stdlib/`,
  `compilerpedia/compilerpedia.tcl`, `compilerpedia/topics/` and
  `compilerpedia/generated/`, plus a `BUILD` file naming the source
  revision. If the compiler starts reading another file at run time, add
  it there. Never make main.tcl or the compiler depend on the single
  executable: `single/main.tcl` only sets the environment and sources
  main.tcl unchanged.
* Standalone executables have three linkers, chosen by
  `BOTLISH_NATIVE_LINKER`: `rustc` (the default), `stub` (no toolchain:
  `botlish-aot-stub` with the program image appended,
  `native/src/runtime/aotimage.rs`) and `system` (the host's C compiler
  driver, link.exe on Windows, linking the program object and the
  precompiled runtime archive; next item); `auto`, the single
  executable's, is `system` for a program that calls C and `stub` for any
  other where the stub runs. The stub is Linux x86-64's only; macOS AArch64
  executables are Mach-O, linked by rustc or the system linker through
  Apple's ld (MACOS-AARCH64-MILESTONE-5.md): never extend the stub, or write
  a linker, loader or signing step, for Mach-O. A program that calls C is linked on
  the same hosts (`codegen/aot.rs`'s `C_CALLS`), with the platform linker's
  own link plan (`LinkerFlavor`: GNU ld's archive group on Linux, never on
  macOS, whose ld rejects it; MACOS-AARCH64-MILESTONE-6.md). If you change
  which hosts link (`EXECUTABLES`, `C_CALLS`), the
  rustc link, the generated startup or `runtime::aot::run`, also run
  `tests/native-executable.test`, `tests/platform/aot-facts.tcl` and
  `audit/native-aot/tools/mutate.tcl` (every mutant in its `mutants.txt`
  that applies to the host must still apply and be killed). A test that reads an
  executable's `botlish_fn_N` symbols (objdump, `strace -k`: the rustc and
  system linkers' executables have them) carries `symbolLinker`, one that
  links a program that calls C `cLinker`, one of rustc's own invocation
  `rustcLinker` (`tests/helpers.tcl`). CI's `stub-linker` and
  `system-linker` jobs run every executable test file with those linkers.
* The system linker (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md) never runs Rust
  when an application is linked. Keep it so:
  - The runtime archive is `native/runtime-archive` (the `botlish-runtime`
    staticlib, a default member of `native/`'s workspace, so the standard
    `cargo build` makes it beside the driver; features forwarded): the
    runtime library plus the executable's C `main`, no code generator. Never
    compile Rust, a C startup source or anything of the runtime's at link
    time, and never link the compiler driver into an application.
  - The program object is the link's only object: its `botlish_program`
    record is the program's startup data, as for every linker
    (`runtime::program`), and the archive's `main`
    (`runtime::aot::linked_main`) starts it as the rustc startup crate
    does. Never a startup object, a second metadata format, generated
    machine code, fixed addresses or a patched executable.
  - The link is the platform linker's, in the rustc linker's link plan
    (`system_link_args`: `link_plan_args_for`'s plan unwrapped, the runtime
    archive and `runtime_system_libraries`, which
    `native/runtime-archive/libraries.tcl` checks against rustc's `--print
    native-static-libs` in `single/build.sh` and every host's system-linker
    CI job: when it fails, change the list, never the check); every path
    and name one argument of a structured command, never a shell string.
    The tool is `cc` (link.exe on Windows) found on PATH, never in the
    working directory, or `BOTLISH_NATIVE_SYSTEM_LINKER`; on Windows from a
    Developer environment: the system linker has no Visual Studio discovery
    of its own. No rustc fallback: `auto` never chooses rustc.
  - Failures carry a kind (`LinkError`: `NATIVE LINK|AOT TOOLCHAIN`,
    `... RUNTIME`, an archive without a helper the program calls among
    them: `undefined_helper`) when they are no error of the program's plan;
    the plan's own stay the linker's words, as the rustc linker's.
  - Nothing on a linked startup's path takes a runtime helper's address:
    the ABI fingerprint `program::read_linked` checks reads
    `ops::HELPER_SIGNATURES` (names and counts), never `helpers()`, whose
    addresses would keep every helper in every executable and library
    (`system-linker-keeps-only-reached-helpers`; the helper list is one
    macro, so the two cannot disagree).
* The three startups build the Vm identically because they share it: the
  startup crate (`codegen/aot.rs`'s constant `STARTUP`),
  `aotimage::Loaded::instantiate` (the stub's) and the runtime archive's
  `main` (`runtime::aot::linked_main`, the system linker's) all read the
  program object's `botlish_program` record with
  `runtime::program::instantiate_linked`, the one place a Vm is built from
  a program's descriptor (native libraries use it too:
  NATIVE-LIBRARY-MILESTONE-1.md, next sections).
  `BOTLISH_NATIVE_STARTUP_REPORT` shows what one installed;
  `tests/system-linker.test` requires the three reports equal. Never
  generate per-program startup code again. If you change the descriptor,
  the record, `program::instantiate`, `runtime::aot::run`,
  `rust_process_setup` or `linked_main`, `constants::install`, what
  `emit_object` emits (sections, relocation types: `codegen::aot::image`
  rejects any type it does not handle), the image format, or the ABI
  fingerprint's inputs, run `cargo test --release --manifest-path
  native/Cargo.toml --lib -- aotimage program` and `--bin botlish-native
  aot::`, `tests/aot-stub-linker.test`, `tests/system-linker.test`,
  `tests/native-library.test`, and the executable test files with the stub
  and with the system linker. The `stub-linker` and `system-linker` jobs in
  `.github/workflows/tests.yml` have the commands. Run them once more under
  `BOTLISH_NATIVE_GC_STRESS=1`. A change to the system linker also runs
  `audit/native-aot/tools/mutate.tcl` (its `sys-*` mutants), and one to the
  single executable's packing or installation (`single/main.tcl`,
  `single/package.tcl`) `audit/single-executable/tools/mutate.tcl` and both
  `single/smoke-test.sh` and `single/ffi-smoke-test.sh` after
  `single/build.sh`.

## Running the tests locally

Run the tests locally with `tclsh9.0 tests/local.tcl`, not `tests/all.tcl`.
It runs, in parallel (`-jobs N`, default the processor count; one process
per test file or suite, each with a private `-tmpdir`):

* **every Tcl test file on interp and compile** (`-backends`; CORE_BACKEND
  when set), minus the Tcl tests a golden test duplicates: the ones the
  manifest classifies FROZEN-DUPLICATE-ORACLE (`tests/golden/manifest.tsv`'s
  `freeze` column; LARGE-SCALE-GOLDEN-MIGRATION.md, "Freeze
  classification"), whose whole theorem golden tests carry on every backend.
  They are reported skipped, by the constraint `goldenDuplicate`
  (`BOTLISH_SKIP_GOLDEN_DUPLICATES=1`, tests/helpers.tcl). Everything Botlish
  source cannot express keeps running in Tcl: compiler and runtime internals,
  the parser, warnings, several programs, `main.tcl`, executables and the
  process boundary, run-time-only failures, the internal half of every SPLIT
  test, and every Tcl test whose golden port is weaker;
* **every golden suite on all four backends**, in their place, **through the
  front-end cache** (`.hirx` entries; HIR-INTERCHANGE.md).

It prints a line per file and suite, then every failure with the command
that reruns it, and exits 1 on any.

What it costs, measured on a 4-core container (2026-10-15):

| run | wall | CPU |
|---|---:|---:|
| `tests/local.tcl`, warm cache | 26 min | 6,060 s |
| `tests/local.tcl`, empty cache | 33 min | 7,710 s |
| `tests/all.tcl` (every Tcl test, one file at a time) | 93 min | 5,590 s |
| every Tcl test at the same parallelism (`tests/local.tcl -all 1 -parts tcl`) | 26 min | 6,100 s |

* **The speed-up over `tests/all.tcl` (93 minutes to 26-33) is the
  parallelism.**
* **The golden layer is free once the cache is warm.** The 2,043 duplicated
  Tcl tests cost about 600 s of process time per run (both passes). The
  golden corpus on four backends costs 630 s with a warm cache and 2,160 s
  with an empty one.

* **Narrow it to what an edit touches.** `tclsh9.0 tests/local.tcl
  tests/affine.test tests/coroutines.test` runs those files minus their
  duplicated tests, plus the golden suites that hold those tests'
  replacements, so the run still covers what the files covered. A `X.bot`
  argument runs that suite; `-parts tcl` or `-parts golden` runs one layer.
  - With an empty cache the golden front ends are most of a narrow run's
    cost: those two files took 35 s this way, against 14 s run directly on
    interp.
  - So, while iterating on one area, `tclsh9.0 tests/X.test` (every test of
    the file) is the quickest check. Run `tests/local.tcl` (narrowed, or
    whole) before pushing.
  - The test files, fuzzers and mutation harnesses the sections below name
    for an area are run as named.
* **Run the golden suites with the front-end cache.** `tests/local.tcl`
  always does, unless told not to.
  - **Which directory:** `BOTLISH_HIR_CACHE` when set; otherwise this
    checkout's own directory under the user's cache directory
    (`~/.cache/botlish/hir/`, or `$XDG_CACHE_HOME`, or `%LOCALAPPDATA%`). The
    run then removes the entries another front end wrote, so the directory
    stays at one front end's worth (about 190 MB).
  - **Why it pays:** a suite whose text, imported modules and front end
    (`core/`, `hir/`, `surface/`, stdlib's Tcl libraries) are unchanged is read
    from its entry, not compiled again. The key leaves out `compiler/` and
    `native/`, so after an edit there the golden corpus costs only the
    backends' runs, a fraction of the Tcl tests it replaces
    (GOLDEN-VS-TCL-BENCHMARK.md). A hit equals the build exactly (the cache
    is audited for it).
  - **One suite:** run a single golden suite the same way with
    `tclsh9.0 tests/local.tcl SUITE.bot`, not a bare
    `tests/golden/run.tcl`, which uses no cache unless `BOTLISH_HIR_CACHE`
    is set.
  - **Opting out:** `-hir-cache ""` turns the cache off, for timing the
    front end.
  - **The Tcl tests never use it,** and neither does CI: every CI run
    compiles from scratch.
* **When a golden test fails,** its Tcl originals are its manifest rows
  (`old_file`, `old_test`). `tclsh9.0 tests/X.test` runs every test of a
  file, and `tests/local.tcl -all 1` runs every Tcl test, duplicates
  included, as CI does.
* **CI runs every test, every time:**
  - the whole Tcl suite, duplicates included, on interp and compile;
  - its coverage on cranelift and cranelift-generic;
  - every golden suite on every backend beside its Tcl originals
    (`audit/golden/tools/check.tcl`);
  - the native Rust unit tests;
  - the stub-linked executables;
  - the warning gate;
  - on pushes to main, the GC-stress run;
  - on pushes to main that change the front end, the golden suites'
    static decisions under the batched and the sequential scheduler
    (`static-decisions.yml`, about 80 minutes; Static intrinsics, "The
    sequential comparison runs in CI, never locally");
  - on Linux arm64 (`.github/workflows/tests-arm64.yml`, ubuntu-24.04-arm):
    the Tcl suite on interp and compile, its cranelift and cranelift-generic
    coverage, the golden suites, the native Rust unit tests (also under GC
    stress) and, except on pull requests, the GC-stress run. Run it on a
    branch with workflow_dispatch.

  A push or pull request that changes only Markdown files and `docs/` starts
  no workflow (their `paths-ignore`). Renaming or removing a design document
  can still fail a test: `tools/compilerpedia.tcl check` takes a code-shaped
  word the sources cite as a document's name only while `docs/NAME.md`
  exists. Run `tclsh9.0 tools/compilerpedia.tcl check` before pushing one.

  Never set `BOTLISH_SKIP_GOLDEN_DUPLICATES` or run `tests/local.tcl` in a
  workflow: `tests/golden-duplicates.test` fails if one does.
* **The skipped set is the manifest's, never a list kept by hand.** A Tcl
  test leaves it when its port is reclassified, through the census and the
  fragments (Golden tests, below).

## Running Linux tests from Windows with WSL

The Windows development machine has an Ubuntu 24.04 WSL distribution with
the repository toolchain already installed. Run Linux-native validation from
PowerShell through that distribution, using the mounted Windows checkout:

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 && tclsh9.0 tests/local.tcl'
```

The WSL checkout is the same working tree as the Windows checkout, not a
separate clone. Check `git status` before running tests and do not stash or
discard changes merely to switch environments.

## Running tests concurrently

Two test runs that share a working directory or a checkout interfere unless
each has its own tcltest temporary directory, and the failures look like real
bugs (`couldn't open ".../contexts-scratch/p79.bot": no such file or
directory`). This covers an agent parallelizing its own runs, two sessions in
one checkout, and a Windows run beside a WSL run (same tree, above). What is
shared (TEST-SUITE-COST.md section 4 has the measurements):

* **tcltest's temporary directory is the current working directory** unless
  `-tmpdir` is given. Test files create fixed-name scratch directories in it
  (`abi-bytes-scratch`, `argv-aot`, `contexts-scratch`, ...) and delete or
  sweep them, so two runs of the *same* test file with one temporary directory
  delete each other's files. Pass a private absolute directory:
  `tclsh9.0 tests/all.tcl -tmpdir /tmp/run-A ...` (tcltest forwards it to
  every per-file child process). *Different* test files sharing one
  temporary directory, two or three at a time, ran the whole suite cleanly.
  `tests/native-coverage.tcl` gives the suite it runs a private `-tmpdir` (and
  keeps its log there) by itself.
* **`native/target/release`.** Every native test runs `botlish-native` from
  there, and the executable (AOT) tests link `libbotlish_native.rlib` at test
  time. A `cargo build` during a run swaps them under it. A copied tree needs
  all of `native/target` (a symlink to the original works); a copy with only
  the binary fails every AOT test with `runtime library missing`. A symlink
  is only for a tree nothing rebuilds: the mutation harnesses whose private
  tree rebuilds the native backend (`audit/*/tools/mutate.tcl` with a native
  mutant selected, `audit/golden/tools/tree.tcl`) copy the directory a linked
  `native/target` points to, never the link (a copied link builds every
  mutant into the original checkout's `native/target`), and a new one must
  too.

So for concurrent runs in one checkout: one `-tmpdir` per run, and no native
rebuild until they finish:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
CORE_BACKEND=interp tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
CORE_BACKEND=compile tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
wait
```

A run started from the repository root without `-tmpdir` and interrupted
leaves its scratch directories in the working tree: check `git status` before
committing.

Outside its tcltest temporary directory, nothing a test does may use a fixed
name; new tests and tools must keep it that way:

* A test that needs a throwaway module next to the standard ones wraps its
  body in `withPrivateLibrary` (`tests/helpers.tcl`), which points
  `$::core::libraryDir` at a per-process copy of `stdlib/` in the tcltest
  temporary directory. Never write into the real `stdlib/`.
* A script or audit tool keeps its scratch files in a `file tempdir` directory
  (or under a name with `[pid]`) and removes it when it finishes, never under a
  fixed name in the working directory or the repository; one that runs a test
  file passes it a private `-tmpdir`.

## Native GC-stress validation

`BOTLISH_NATIVE_GC_STRESS=1` forces a GC attempt at every allocation site,
which is how native stack-walking/root-tracking bugs get caught. This used
to be a manual step agents were required to run locally on every relevant
change; it is no longer mandatory by hand. It now runs automatically in CI
on every push to `main`, as the `gc-stress` job in
`.github/workflows/tests.yml`.

Before touching anything in `native/` that affects stack walking, roots, or
allocation (GC, stack maps, escape analysis, block/root storage), check
whether the most recent `gc-stress` run on `main` passed. A prior failure
there is a standing signal worth reproducing and fixing, not something to
work around.

Agents are not restricted from running GC-stress locally as well, on top of
what CI covers — do so whenever it's diagnostically useful (e.g. to
reproduce a CI failure, or to validate a stack-walking change before
pushing). To run it locally on Linux, build the release backend and run the
suite with stress enabled:

```sh
export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/all.tcl
```

From Windows, run the same thing inside WSL for Linux GC-stress results
when validating the Linux frame walk or the Linux stack guard: Windows-native
execution walks its frames another way (Windows' unwinder across Rust
frames) and guards its stack another way (a vectored exception handler:
"Windows x86-64 (MSVC)", below), so it validates neither:

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1 && cargo build --release --manifest-path native/Cargo.toml && tclsh9.0 tests/all.tcl'
```

## Compiler warnings

Warnings (`hir/warnings.tcl`, WARNINGS-SAME-RETURN.md) are on by default and
have exactly one global policy per compilation: `-warnings default|off|error`
(`surface::compile`/`readProgramFile`, `main.tcl`). There are deliberately no
`-Wfoo` switches, groups, levels or source suppression: don't add them, and
don't add a warning that is not backed by a compiler proof. The test harness
(`tests/helpers.tcl`) sets `BOTLISH_WARNINGS=off` as the process default,
because tcltest counts stderr output as a test-file error; `tests/warnings.test`
passes its policy explicitly on every compile. Benchmark and analysis scripts
that compile corpus sources pass `-warnings off` themselves.

`METHOD-ELIGIBLE` (WARNINGS-METHOD-ELIGIBLE.md) is backed by a checked proof,
the round-trip law: the sugared spelling of every call it reports must parse,
resolve to the same callee and compile to the same program. If you change
method sugar, the resolver's candidate gathering or what the frontend records
in a call's `written` marker, run `tests/method-eligible.test` and
`audit/method-eligible/tools/fuzz.tcl`. `nomethod fn` is a declaration by the
function's author that method syntax to it is an error; it is not a warning
suppression, and there is still no call-site suppression to add.

`FIXED-ARITY-LIST-RETURN` (WARNINGS-FIXED-ARITY-LIST-RETURN.md) reads the
frontend's `written {form list}` provenance, milestone 1's exit enumeration
(`Exits`/`Leaves`) and completion walk, `hir::exact::AliasRoot`,
`hir::resolve::CandidateIdentity` and the block's `declaredResult`. If you change
any of those, or how a list literal, an else-less `if` or a result annotation
lowers, run `tests/fixed-arity-list-return.test` and
`audit/fixed-arity-list-return/tools/fuzz.tcl`. A list-typed result annotation
(`-> list`, `-> List[T]`) is a real type the checker proves, not a suppression;
do not add another opt-out (MULTI-VALUE-RESULTS.md). Library
modules' own findings print for every program that loads them, so tests that
import `stdlib/*.bot` and assert on a complete warning set filter by code or file.
Since the warning-driven refactor (next section) only two modules carry any,
all `ONE-CHAR-STRING-LITERAL` and all listed in `audit/refactor/manifest.txt`:
`stdlib/web.bot` 23 (its hex-digit table, `"%"`, and the local-part and label
classes) and `stdlib/linux/path.bot` 2 (`"/"`). Every other module is
warning-clean, `stdlib/io.bot` included (its line operations append the newline
as a character, `std::str::append_char`).

`SAME-FAILURE` (WARNINGS-SAME-FAILURE.md) reads the `fail` sites of a function's
own body (milestone 1's `BodyExprs`, which never enters a nested function), each
`fail` node's `name` and `reachable` flag, the block's resolved `declaredErrors`,
the canonical module-qualified error identities (`hir/errordecls.tcl`) and the
completion walk (`hir::completions::reachedExprs`, which records `fail` sites
and never enters a nested function either). If you change any of those, or how
`fail`, `errors` or an on-handler body lowers or resolves, run
`tests/same-failure.test` and `audit/same-failure/tools/fuzz.tcl`.

`PROVES-NAMING` (WARNINGS-PROVES-NAMING.md) reads, per function declaration, the
block's resolved proof contract (`proofs`, `hir/resolve.tcl`'s
`ResolveProofs`), its `params` minus its `flags`, its `declaredResult`, and the
declaring binding's written name (hygiene's recorded `spelling`, else the name
without a `#N` suffix, then `hir::warnings::MemberName` for a module's
qualified spelling). It runs no walk and reads no reachability. If you change
the proof-clause grammar or validation, how a declared result or the flag
section is recorded, hygiene's renames (`hir/hygiene.tcl`: `spelling`,
`qualifyModules`), or the naming convention in REFINEMENT-VALUES.md ("Naming"),
run `tests/proves-naming.test` and `audit/proves-naming/tools/fuzz.tcl`. The
response to this warning is a rename; do not add an opt-out, a reverse rule
(`?` implies bool) or a check on functions without `proves`.

`ONE-CHAR-STRING-LITERAL` (WARNINGS-ONE-CHAR-STRING-LITERAL.md) reads, per
`const` node, its exact value (`hir::exact::Of`: exact String values) and
measures it with the reference `std::str::length` (`core::strings::length`); the one
String const the frontend synthesizes, a context parameter's
`context#load("ID")` key, is recognized by `hir::contexts::isLoad` and never
reported. If you change how a String or character literal lexes, lowers or reads
back from HIR text, the exact value of a constant, `std::str::length`, or build a
String const anywhere in the frontend (`tests/one-char-string-literal.test`'s
`oc-synthesized-string-consts-enumerated` lists every place that does), run
`tests/one-char-string-literal.test` and
`audit/one-char-string-literal/tools/fuzz.tcl`. The warning is context-blind and
not autofixable on purpose: do not add a context gate, an opt-out, the
character spelling to its message or data, or a fixit.

`MANY-BOOLEAN-ARGUMENTS` (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md) reads, per call,
the frontend's `written` provenance (`function`/`method` only), the call's
`reachable` flag and `args`, the callee reference resolved through aliases by
`hir::resolve::CandidateIdentity` to a declaring `bind` of a block (or a root
native and its registry `paramTypes`), the block's `params` minus its `flags`,
and the parameter types the checker proves (`hir::signatures::entryTypes`:
declared, else the TRUSTED inferred contract -- never a CHECKED one). Its
evidence is an argument that is a reference to the root `true` or `false`,
which is how the frontend lowers those keywords; flag arguments are the
trailing `bool` constants hir/flags.tcl appends and are never read. If you
change call provenance, how `true`/`false` or a call's arguments lower, the
flag transport (`hir::flags::ResolveCall`), alias resolution, the trusted /
checked split of `hir/signatures.tcl`, or a native's parameter types, run
`tests/many-boolean-arguments.test` and
`audit/many-boolean-arguments/tools/fuzz.tcl`. The warning counts literals
only and is not autofixable on purpose: do not count flags, bindings or
computed bools, follow exact values, group per callee, warn on a declaration
without call evidence, print a flag spelling, or add a fixit or an opt-out
(FLAGS.md, "Boolean arguments", records the graduation criteria).

## The warning gate

The shipped stdlib, libraries, examples and benchmarks compile clean under
Botlish's own warnings, except exactly the findings `audit/refactor/manifest.txt`
lists, each with the obstruction that keeps it open (REFACTOR-WARNINGS-CLEAN.md).
`audit/refactor/tools/gate.tcl` checks it -- every corpus program and a one-line
loader per library module, the observed warnings equal to the manifest (code
and location), and every program and loader without an entry compiling under
`-warnings error` -- and the `warning-gate` job of `.github/workflows/tests.yml`
runs it on every push and pull request (`tests/warning-gate.test` pins that it
passes and that it fails on a planted warning).

If you add or change a program in `examples/`, `bench/` or `stdlib/`, run
`tclsh9.0 audit/refactor/tools/gate.tcl`:

* A new warning is answered in the code -- convert it, annotate the result
  type, merge the exits or guards, or mark the callee `nomethod` for a stated
  reason -- never by adding a manifest entry. The manifest grows only at a
  re-audit that names an obstruction no mechanism of the language closes, per
  finding.
* An entry leaves the manifest when its finding closes, with the closing
  verified: `audit/refactor/tools/probe.tcl` (behavior probes against the tree
  before the change, every backend) and `audit/refactor/tools/expect.tcl`
  (every `# expect:` value, every backend).
* A manifested literal that moves (a line added above it) is a location drift
  the gate reports: update its line and column in the manifest.
* A new corpus program must be listed (with its entries, if any).
* Do not edit `audit/refactor/kickoff-corpus/`: it is the frozen,
  warning-bearing fixture the backend-independence CLI tests (and one
  String-region test of the `peek()` idiom) read, not corpus.

## Refinement values

`refined type NAME = CARRIER` and `proves PARAM: NAME` (REFINEMENT-VALUES.md)
are generic: no compiler or runtime file may name a corpus refinement or its
predicate (`tests/refinement-values.test` greps for `Emailish`,
`UriQueryValue`, `emailish?`, `uri_query_value?`), and a refined value has
exactly its carrier's representation -- never add a runtime tag, wrapper or
check to recover one. If you change the proof contract resolution
(`hir/resolve.tcl`'s `ResolveProofs`), implications, call keys or a
validator's completion facts (`hir/refine.tcl`), the `if` join, the
decided-call rule or how a call's completion facts flow and a handled call
joins its handlers (`hir/types.tcl`'s `Call` and `Handle`), repeatability
(`hir/repeatable.tcl`), a native's `-context-free` classification, or how
`-> unit` and a proof clause parse, run `tests/refinement-values.test`,
`tests/refinement-validators.test`, `tests/emailish-predicate.test` and
`audit/refinement-values/tools/fuzz.tcl` (validators are on by default;
`-validators 0` reproduces the predicate-only generator's runs).

## No type is callable

No type declaration makes the type callable or gives it a predicate
(ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md): `T`, `T(x)`, `T?`, `ns::T?` and
`x.T?()` are unknown names unless the program declares a function of that
name. An integer domain is entered through an ordinary converter (a function
whose declared result is the domain, checked like any result) or admitted
by comparisons, whose range facts both analyses derive through `and`, `or`
and `not` (`hir::range::Paths`/`OutcomeFacts`); a refinement through its
owner's `proves` predicates and validators. A Range proves a domain, never a
refinement (`hir::range::ProvesType`). Never register a native, a value or a
method candidate from a type declaration, never resolve a missing name by
its spelling (`NAME?`), and never lower a native by a type's name;
`-tests-type` is for explicitly registered type tests (the kind and Result
tag tests), never of a refinement. If you change type-declaration
registration (`hir/sourcetypes.tcl`), the resolver's or loader's handling of
an unknown name, `Paths`/`OutcomeFacts`/`ProvesType`, or the completion
analysis's `BranchOutcome`, run `tests/type-predicates.test`,
`audit/refinement-values/tools/fuzz.tcl -domains 1` (several seeds) and
`audit/type-predicates/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).

## Branch-form Boolean conditions

An `if` condition is lowered as a branch, not as a Bool to branch on
(BRANCH-FORM-BOOLEAN-LOWERING.md). `hir/condition.tcl` states, once, which
expressions have a branch form -- the root Booleans and the `if`s `and`,
`or`, `not` and `!=` lower to (surface/lower.tcl) -- and the two compilers
emit it: the Tcl compiler's `CompileCondition` as one Tcl test built from
`&&`, `||`, `!` and `?:` (an operand's code inside its side, a command
substitution), native lowering's `Condition` as branches to the `if`'s two
arms (`StaticOutcome` applies M6's range-decided rule through the Boolean
structure; `BranchDemand` lets an inlined region consumer branch itself).
It changes representation only: every operand runs where, and only where,
its value form runs it, once, in order. HIR is unchanged (no branch node,
flag or side table), the interpreter evaluates conditions as values, and a
Bool used as a value is still built. Never add backend-specific Boolean
semantics, a Boolean node to HIR or Core IR, a peephole over materialized
Bools, or proof reasoning to the lowering (`hir::range::Paths` stays the
analyses', with its own budget; the lowering has none).

If you change `hir/condition.tcl`, the compilers' condition lowering
(compiler/compiler.tcl's `CompileIf`, `CompileCondition`, `ConditionIf`,
`ConditionBranch`, `BoolResult`; native/lower.tcl's `If`, `Condition`,
`ConditionIf`, `ConditionBody`, `BodyTarget`, `StaticOutcome`,
`BranchDemand`, `EmitRegionConsumerCondition`), how `and`/`or`/`not`/`!=`
lower, the releases after a branch's statements, or region-consumer
inlining, run `tests/branch-form-boolean.test`, its golden suite
(`tclsh9.0 tests/local.tcl tests/golden/branch-form-boolean.bot`) and
`audit/branch-form-boolean/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).
`bench/branch-form-boolean.tcl` regenerates the performance report
(`-root DIR` measures another checkout; `-programs FILES` real programs).

## Traits

Traits (TRAITS.md) are eager, one-way, entirely static views: a trait-typed
value is its concrete witness's value, and every backend compiles a
monomorphized program with no trait type, no trait operation and no
trait-polymorphic function (`hir::traits::monomorphize`). Never add trait
knowledge below HIR: no runtime trait value, wrapper, tag, vtable,
dictionary, witness argument or indirect call for a trait operation, and no
trait code in `core/`, `compiler/`, `native/` (`tests/traits.test`'s
`trait-source-audit`, `-principal-nir`, `-machine-code-direct`,
`-allocation-free` and `-code-quality-identical` pin this). Conformance reads
only the witness's owner namespace's own declarations: never the call
site's imports or another namespace.

If you change conformance (`hir::traits::satisfies` and what it reads), trait
views in inference (`hir/types.tcl`'s subtype/lub/narrow of views,
`hir::traits::Accept`/`EntryView`/`ViewResult`/`TypeCall`), the semantic
instance key of a trait parameter (`hir/semantic.tcl`), the plan or build 2
(`hir::traits::Plan`, hir/resolve.tcl's clone/planned-call resolution), run
`tests/traits.test`, `audit/traits/tools/fuzz.tcl` and
`audit/traits/tools/mutate.tcl` (which needs every mutant in
`audit/traits/tools/mutants.txt` to still apply: update a mutant's text when
you change the code it mutates, and keep it a mutant of the same rule).
`audit/traits/tools/evidence.tcl` regenerates `audit/traits/principal/`.
`hir::BuildFull` runs the plan only on a program with no diagnostic, and its
diagnostics are a static site's: a program-wide channel of the static
decisions (`hir/staticdeps.tcl`'s `C:plan`, which lists the plan's
diagnostic kinds and the calls they are reported at). A change to that gate,
to those kinds or to where they are anchored also needs
`tests/static-economics.test` (`se-property-plan-gate`, `se-equal-plan-gate`)
and the static-decision harnesses (Static intrinsics, below).

## Hashable and the keyed table hash

`Hashable` (HASHABLE-AND-KEYED-HASH.md) is an intrinsic trait: an ordinary
trait to its clients (a parameter, a view, a requirement `hash`), whose
witnesses only the language implementation supplies. A type is a witness
when every value of it has total equality and total hashing
(`hir::types::HashClass`, read from the runtimes' own refusal lists
`core::value::incomparable` and `core::hashing::unhashable`); `any`, an
imprint variable and a view of another trait are unknown, never witnesses.
The public `hash` is unchanged (outputs pinned) and admits `checked`: a
statically non-Hashable argument is TRAIT-NOT-SATISFIED, a Hashable one
lowers to the total `hashtotal` (no EQUALITY edge), anything else stays the
dynamic hash. `std::table_hash::of` is the private keyed hash: SipHash-1-3 of the
canonical walk (never a mix of the public hash), keyed by a process-local
secret drawn once from the system, `required` Hashable, internal to the
standard library. Keep it so:

* No user witness: never let a declaration, an `impl`, a field or a name
  make a type Hashable, and never add custom hashing, identity hashing, an
  `Equatable` or a derive. A user trait, struct, enum, layout or type named
  `Hashable` stays a collision.
* No Botlish value of the secret, no key argument, no way to read or set it
  but the test hooks (`core::hashing::useTableHashKey`, the driver's
  `--table-hash-key`, which only `native/native.tcl` passes), and no
  observable table hash: the namespace `table_hash` is internal
  (`core::native::declareInternalNamespace`): INTERNAL-NAMESPACE for an
  import or a qualified name outside the standard library,
  INTERNAL-INTRINSIC-VALUE for its native taken as a value.
* Admission is registration metadata (`-hashing {K required|checked}`),
  never a check keyed on a native's name; the totality walk is one
  statement for both operations: never a second list of kinds.
* The two folds share one canonical walk per runtime
  (`core::hashing::Encode`; ops.rs's `walk` over a `CanonicalSink`): change
  both runtimes together, and the oracle (`audit/hashable/tools/oracle.py`)
  with them.

If you change any of that (the report's "What to run when changing this"
lists the files), run `tests/hashable.test`, `tests/native-hashing.test`,
`tests/traits.test`, the golden suites `hashable.bot` and
`hashable-admission.bot` (`tclsh9.0 tests/local.tcl
tests/golden/hashable.bot tests/golden/hashable-admission.bot`),
`audit/hashable/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`),
`audit/hashable/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), `python3 -I
audit/hashable/tools/oracle.py selftest` and `cargo test --release
--manifest-path native/Cargo.toml --lib hash`. `audit/hashable/tools/census.tcl`
regenerates the witness census; `bench/hashable.tcl` the performance report.

## Parameterized structs and constrained slots

A struct may declare type slots, `struct Pair[A, B]:`, each optionally
constrained by one trait, `struct Map[K satisfies Hashable, V]:`
(TRAIT-CONSTRAINED-IMPRINTED-TYPES.md). Its types are its applications
`{nstruct ID ARGS}`; a constrained imprint variable is `{imprint K
TRAITS}`. Functions stay imprinted: matching `Map[K, V]` establishes K and
V as any applied type does, and gives the body the constructor's
obligation, K itself known to satisfy Hashable -- never the trait view.
Keep it so:

* No function-side generics: never add `fn f[K, V]`, a `where` or
  `requires` clause, a constraint on a function or on a bare imprint
  variable, predicates, scalar constraints, higher-kinded or associated
  types, parameterized traits, enums, errors, layouts or contexts. A
  function's constraints are exactly what the applications of its own
  signature give it (`hir::imprint::Constrain`); a body never adds one to
  its contract.
* A constraint validates an imprint, never establishes one: a variable no
  argument or explicit imprint establishes is IMPRINT as before, and a
  failed constraint is TRAIT-NOT-SATISFIED, checked after imprinting.
* Satisfaction is the ordinary trait satisfaction (`hir::traits::satisfies`;
  Hashable's witness predicate): never a second, structural check of a
  slot, and `any` satisfies nothing. An application is checked wherever a
  type is written and wherever a binding makes one
  (`hir::structs::verifyApplications`, `VerifyDeclarations`,
  `hir::imprint::Bind`); a field's nested application over a slot needs the
  enclosing declaration to state the obligation.
* An application's identity is its constructor and arguments: no witness,
  trait set or constraint in it, and none in a specialization key (native
  instances are keyed by the concrete application; the trait plan's
  specializations per binding by the variables a source trait constrains,
  `SelectingBinding`). Applications are invariant; no variance policy.
* No runtime existence: every application shares its constructor's one
  representation (one Tcl struct kind, one NIR shape), with no type
  arguments, witness object or check at run time.
* An argument is bounded at its application's own aggregate depth
  (`hir::types::MakeApplied`; applications nest `appliedDepth` deep): cut a
  level earlier than its fields' values, it would admit none of them.
* The slots and constraints are part of the struct registry entry (a
  declaration registry: isolation and interchange carry them); HIR text
  prints them on the declaration and reading derives each variable's
  constraints from it.

If you change the slot grammar or n-ary applications (surface/parser.tcl's
`TypeExpr`, `StructDecl`, `TypeSlots`), `hir/structs.tcl`'s slots,
`AppliedFieldTypes` or `ApplicationProblem`, the application cases of
`hir/types.tcl` (`MakeApplied`, `InferApplication`, `Totality` of a
constrained variable), `hir/imprint.tcl`'s applications, `Obligations`,
`Constrain` or `Bind`, `hir/resolve.tcl`'s `ResolveApplied`, the
constrained-variable cases of `hir/traits.tcl` (`satisfies`,
`TypeImprintCall`, `ImprintPolys`, `SelectingBinding`, the plan's imprint
specializations) or the HIR text of slots, run
`tests/trait-constrained-types.test`, its golden suite (`tclsh9.0
tests/local.tcl tests/golden/trait-constrained-types.bot`),
`audit/trait-constrained-types/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`) and `audit/trait-constrained-types/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), plus the trait, Hashable and C ABI type harnesses (above
and below) for a change to code they share, and the static-decision
harnesses for a change to the plan. `bench/trait-constrained-types.tcl`
regenerates the performance report.

## Context traits

Context traits (CONTEXT-TRAITS.md) are environment abstractions resolved
entirely before any backend runs: a `context trait` has no value, slot, tag,
table or runtime representation; the one installed context implementing it
is selected statically at each top-level call (exactly one, never ranked,
never by whether its implementation's own requirements are met: SFIAE);
every function whose requirement includes a context trait is cloned for the
selection by the trait monomorphization (`hir::traits::Plan`), and every
operation becomes a direct call of the selected context's implementation.
Never add a runtime provider lookup, a context-trait slot in the native
context area, a hidden context or dictionary argument, or context-trait code
in `core/`, `compiler/` or `native/` (the one exception is the dead-code
placeholder `context#unreachable`, which never runs). Satisfaction reads only
the concrete context's owner namespace (`hir::contexts::satisfiesTrait`).

If you change satisfaction (`hir::contexts::satisfiesTrait`,
`TraitImplementation`), selection (`hir::contexts::Obligations`), the binding
check (`CheckTraitBindings`), context-trait typing (`hir::traits::TypeCall`,
`hir::types::ShapeResult`'s context-trait case), the plan's context-trait
actions or the planned-call resolution (`hir/resolve.tcl`'s
`ResolvePlannedCall`), or stdlib/io.bot, stdlib/linux/io.bot, stdlib/linux/path.bot,
run `tests/context-traits.test`, `tests/portable-io.test`,
`tests/linux-path.test`, `audit/context-traits/tools/fuzz.tcl` and
`audit/context-traits/tools/mutate.tcl` (every mutant in
`audit/context-traits/tools/mutants.txt` must still apply: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule). Changing `hir::traits::Plan` also means re-checking the trait mutants
(`audit/traits/tools/mutants.txt`).

## Direct modules

Raw, ambient authority is acknowledged at the module boundary
(DIRECT-MODULES.md): a module is designated direct by its file's first line,
`direct module`, or -- an intrinsic namespace -- by
`core::native::declareDirectNamespace` (the syscall transports
std::linux::abi::x86_64 and std::linux::abi::aarch64; stdlib/linux/sys.*.bot and
stdlib/linux.bot are declared ones). A call in module U of a callable of another designated module
is a direct edge of U, mediated only when the function making it requires a
context (struct or context trait) U declares itself; an unmediated edge makes
U inferred direct, and the marker must agree (DIRECT without it,
STALE-DIRECT-MODULE with one nothing needs); a non-direct module may not take
a direct callable as a value (DIRECT-CALLABLE-VALUE). The entry program is a
module like any other. Keep it so:

* Never add a call-, function- or block-level form (`direct fn`, `direct
  f()`, `unsafe`), a suppression, a per-function exception inside a direct
  module, or a runtime direct bit; never read directness from a module's
  name, path or library, and never let a context of another module (or a
  caller's context) mediate. A context constructor gets no exemption (it is
  callable anywhere): a construction that needs authority requires an
  earlier context of its module (DIRECT-MODULES.md, "Context
  construction").
* A caller reads a module's designation, never its inference, and directness
  lives in the HIR (`moduleDecls`, `direct`), never in a registry: keep both
  (no channel in hir/staticdeps.tcl depends on them, and compilation
  isolation holds by construction).
* A program that calls `linux`, `std::linux::sys` or a transport itself (an
  example, a golden suite, a test program) is low-level: it starts with `direct module`, or
  mediates the calls through a context of its own.

If you change hir/direct.tcl, the marker's grammar or loading
(surface/parser.tcl, surface/modules.tcl), the intrinsic metadata, what a
call's target or a context's owner is, or context parameters, run
`tests/direct-modules.test`, `audit/direct-modules/tools/fuzz.tcl` (several
seeds) and `audit/direct-modules/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when you
change the code it mutates, keeping it a mutant of the same rule).

## Module privacy and CONTEXT-RESOURCE-ESCAPE

`private` (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md) makes a
top-level declaration -- a function, module binding, type, refinement,
error, struct, enum, trait, context trait, layout or extern c fn --
accessible only to code of the module that declares it. One fact decides
every check: the module declarations' `private` sets (`moduleDecls`, which
the loader records, surface/modules.tcl's `ModuleDecl`), read through
`hir::privacy::Entry` and `Denied` (hir/privacy.tcl). Keep it so:

* Never add a second visibility fact, a runtime check, tag or wrapper, a
  `public`, `internal`, `friend` or package level, or a per-call
  exception. Declarations stay public by default; never mark library
  declarations private by usage counts. Access is decided by the
  canonical module identity (the namespace path): no import, parent,
  child, entry program or name component grants it.
* `private` and `opaque` are orthogonal: privacy is who may name a
  declaration, opacity who may build and take apart a value. Never let one
  imply the other.
* A private member of an imported module is invisible to method syntax
  (`hir::resolve::MethodCandidates`): the call means what it would mean
  without it, and is PRIVATE-ACCESS only when nothing else applies. A
  private function implements no trait or context-trait requirement
  (`hir::traits::ImplInfo`'s `private`). Never let a name match make a
  private declaration a candidate.
* PRIVATE-TYPE-ESCAPE (`hir::privacy::verify`) judges every public
  declaration of a module (never the entry program's) by its declared and
  inferred interface: parameters, results, errors, proof clauses, context
  requirements, a struct's fields unless it is opaque, a layout's fields,
  a refinement's carrier, a trait's requirements, an extern's C signature.
  An opaque struct's hidden fields are no interface.

`CONTEXT-RESOURCE-ESCAPE` (hir/resourceescape.tcl) reads the direct-module
analysis's `contextualized` status (`direct units`, its discharging
contexts), the checked types of a crossing's call, arguments or value
(`hir::typeOf`), the struct registry's opacity and owner, the module
declarations' private sets and the trait-call marker, on the program as
written (`traitSource`). It reports one warning per exposing declaration;
never add an opt-out, a fixit, a level, a warning on a declaration no other
unit uses, or a rule that reads a name. If you change the parser's
modifier, the loader's records or checks, method candidates, trait or
context-trait conformance, `hir/privacy.tcl`, `hir/resourceescape.tcl`, the
direct-module statuses or what interchange keeps, run
`tests/module-privacy.test`, `tests/context-resource-escape.test`,
`tests/workload-icy-tower.test`, `audit/module-privacy/tools/fuzz.tcl`
(several seeds) and `audit/module-privacy/tools/mutate.tcl` (every mutant
in its `mutants.txt` must still apply and be killed: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule), plus the direct-modules, traits, context-traits, opaque-struct and
interchange harnesses for a change to code they share.
`audit/module-privacy/tools/warning-census.tcl` re-runs the repository
census of the warning (audit/module-privacy/census/).

## Coroutines

Coroutines (COROUTINES.md) are eagerly started, affine resumable
computations: `yield` is a statically tracked deep control effect, and every
coroutine operation is an internal root native (`coroutine#create`,
`#start`, `#resume`, `#yield`, `#release`, and `std::coroutine::done?`).
Ownership is entirely static: there is no runtime moved state, no copy, fork
or clone operation, no iterator protocol, no exhaustion error and no
resumable error -- don't add any (`tests/coroutines.test`'s `co-source-*` tests pin this). A handle is an
affine value (next section): where it may live is decided by
`hir::affine::Consumer` for every affine value alike, and a new place (a
closure capture, an erasing argument, a mutable container) is a deliberate
extension of that discipline, never a side effect.
Contexts and context traits stay static: a coroutine's providers are the
ones selected at its construction, and suspension adds no context or trait
machinery to either runtime.

A coroutine is released right after its handle's last use
(`hir::affine::Releases`, COROUTINES.md "Release at the last use"):
every backend emits the release after that statement (`hir/lower.tcl`'s
`Seq`, the Tcl compiler's `CompileSequence`, `native/lower.tcl`'s `Sequence`)
and keeps the statement's value. An exit that leaves the handle's scope
first -- a `return`, `fail`, `break` or `continue`, or a call propagating a
declared error -- releases it there (`hir::affine::ExitReleases`,
COROUTINES.md "Release on every early exit"): before the exit (after its
value, for a handle the value uses), and on a call's error edge through a
handler-shaped catch that releases and propagates the same error on
(`hir/lower.tcl`'s `ReleasingOnError`, the Tcl compiler's
`ReleasingOnError`/`CompileHandle`, `native/lower.tcl`'s `Call`/`Handle`
pads). An error edge uses the call's type-level `calleeErrors`, never the
completion proofs. A release must stay unobservable -- it never runs
Botlish code (a released suspended Tcl coroutine is unwound by an error no
handler catches) and never changes a value -- and must never release a
coroutine some live binding still owns. The affine-values milestone
extended it to every affine value, keeping both properties.

If you change the coroutine grammar (`yield`, the coroutine binding, the
resume clause), `hir/coroutines.tcl` (protocols, the yield effect),
`hir/affine.tcl` (the ownership analysis), how a construction lowers (`surface/lower.tcl`'s
`CoroutineBind`) or resolves (`hir/resolve.tcl`'s `CoroutineResume`), a
segment's error facts (`hir/completions.tcl`'s `NativeCallFacts`), where
releases go or how they lower, the Tcl runtime (`core/coroutines.tcl`) or the
native one
(`native/src/runtime/coroutine.rs`, the GC's walk of suspended and resumer
stacks in `heap.rs`/`vm.rs`), run `tests/coroutines.test`,
`audit/coroutines/tools/fuzz.tcl` (several seeds) and
`audit/coroutines/tools/mutate.tcl` (every mutant in
`audit/coroutines/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule; native mutants rebuild a private copy of `native/`, never this
checkout's). A change to native stack switching or its GC walk also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/coroutines.test` and
`cargo test --release --manifest-path native/Cargo.toml --lib coroutine`.
`bench/coroutines.tcl` regenerates the performance report.

Native coroutines switch stacks with hand-written x86-64 and AArch64
assembly on Linux x86-64, Linux AArch64 and macOS AArch64
(MACOS-AARCH64-MILESTONE-3.md), and with Windows fibers on Windows x86-64
(WINDOWS-X86-64-MILESTONE-5.md; "Windows x86-64 (MSVC)", below); elsewhere,
and on the fallback root plan, the native backend reports them unsupported
(the Tcl backends run them everywhere). The AArch64 switch is
one text (`aarch64_switch!`, `aarch64_trampoline!` in
runtime/coroutine.rs) in ELF and Mach-O spelling: change it for both, run
the coroutine Rust tests on Linux AArch64 (CI's arm64 workflow, or
qemu-user) and on macOS (the macOS workflow's smoke job runs them), and
never touch x18. A Tcl test that needs coroutines, the collector around
them or native counters carries `nativeCoroutines` (tests/helpers.tcl), a
capability of the host target, not `nativeLinux`.

## Coroutine fusion

The native driver fuses coroutines (COROUTINE-FUSION-MILESTONE-1.md,
native/src/codegen/fusion.rs): a coroutine whose handle never leaves the
function that constructs it, and whose yielding call chain is
environment-free and non-recursive, is compiled into that function -- the
chain inlined once as a template, a copy per start and resume over the same
registers, a state register, no coroutine object, stack, switch or runtime
coroutine operation. It is a NIR-to-NIR pass in the driver's load path
(main.rs), so the JIT, objects, executables and every inspection command
compile the fused program. Keep it so:

* Fusion never changes what a program means. A site it cannot prove keeps
  the general runtime (reported `kept` with its reason), never an error;
  every rewritten function is validated (`nir::validate_function`) or
  discarded. Never weaken a condition of `fuse_site` (a handle use it does
  not follow, a recursive or capturing yielding function, more than one
  live coroutine of a site) without the proof in the report.
* The general runtime stays the oracle: `BOTLISH_NATIVE_COROUTINE_FUSION=0`
  turns the pass off, `cranelift-unfused` (tests/helpers.tcl) runs a
  program so, and tests/coroutines.test's `coAgree` and the coroutine
  fuzzer compare fused code with it on every program. A test or audit tool
  that reads the general runtime's own objects, stacks or release counters
  (`native::allocationReport`'s `coroutines`) reads them inside
  `withoutCoroutineFusion`; never make such a test pass by fusing. One that
  inspects a producer's machine code finds it in the fused consumer, where
  fusion copied it (tests/c-ffi-error-capture.test's `ecHolders`).
* A copy per operation keeps the control flow graph exact (a segment
  returns only to the operation that ran it): never share one copy between
  operations through a run-time return address without the validator's and
  the root plan's precision argument (the report, 4.3). The dispatch's
  edges to every continuation are the one imprecision left: a plan register
  is cleared where the template suspends at a yield whose continuation does
  not read it, and where it completes or fails (`clear_plans`, 4.5, with
  liveness that follows each yield into its own continuation); never drop
  the clearing or stop its liveness at a yield.
* The only runtime addition is `op cofailed` (`rt_co_failed`): a fused
  coroutine's cached failure, raised again by `coresume0`. Fusion adds no
  coroutine-specific code to the collector or codegen.
* Fusion runs only where native coroutines exist
  (`runtime::coroutine::STACK_SWITCHING`): it must not make a program run
  where the general runtime refuses it.

If you change fusion.rs, nirtext.rs, `cofailed`, `live_at_many`/`def_use`,
or what NIR the coroutine operations lower to, run
`tests/coroutine-fusion.test`, `tests/coroutines.test`,
`audit/coroutines/tools/fuzz.tcl` (several seeds; its default backends
include cranelift-unfused), `cargo test --release --manifest-path
native/Cargo.toml --bin botlish-native -- fusion nirtext` and
`audit/coroutine-fusion/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule), and
take the census of a whole run (`audit/coroutine-fusion/tools/census.tcl
-run tclsh9.0 tests/local.tcl -parts golden`): a site kept because its
fused function "does not validate" is a fusion bug to fix, never a fallback
to accept. `audit/coroutine-fusion/tools/evidence.tcl` regenerates the
native evidence (commit it); `bench/coroutine-fusion.tcl` is the
performance report.

## The native stack guard

A native run that exhausts a stack -- the worker thread's or a coroutine's,
in Botlish code, the runtime or C -- ends in `NATIVE LIMIT STACK` on every
host the native backend runs on (MACOS-AARCH64-MILESTONE-4.md,
NATIVE-STACK-OVERFLOW.md, WINDOWS-X86-64-MILESTONE-4.md): Linux x86-64 and
AArch64, macOS AArch64 and Windows x86-64, `native_stack_overflow_supported()`.
One contract serves them all (`runtime/platform/mod.rs`: `OverflowGuard`
installed by the thread that runs Botlish code for as long as it runs it,
`set_result_file`, `OVERFLOW_LINE`, exit status 0 for the driver and 1 for
an executable), with one mechanism per exception model: POSIX signals,
`runtime/platform/guard.rs`, where a host adds only how the current
thread's stack and guard are found and how a thread is named
(`platform/linux.rs`: glibc's report; `platform/macos.rs`: libpthread's
bounds, the usable low bound and the guard confirmed with `mach_vm_region`);
and Windows' STATUS_STACK_OVERFLOW, `runtime/platform/windows.rs` (a
vectored exception handler first in the chain, run in the thread's stack
guarantee). Keep it so:

* The handler only classifies and reports: an address in the guard of the
  stack *published* as running, on the guarded thread (POSIX), or
  STATUS_STACK_OVERFLOW on the guarded thread at an address of the stack
  published as running (Windows), writes the result line and ends the process (`_exit`;
  TerminateProcess). It never resumes, unwinds, allocates or touches the
  runtime, and it uses nothing but lock-free atomics stored before the
  fault and calls that take no lock (async-signal-safe ones; WriteFile and
  TerminateProcess), its destination resolved before the fault. Any other
  fault or exception goes on as if the guard did not exist (the
  disposition the process had before it; the next vectored handler);
  never relabel one -- an access violation, also one in a stack's
  uncommitted reservation, is never an overflow.
* A guard is confirmed, never assumed from a reported stack end: a host
  that cannot confirm one reports none (`guard_low == low_bound`) and
  install refuses it. The macOS main thread's lowest reported page is
  itself inaccessible: its usable bound is above the reported one. On
  Windows an exhausted stack is an exception, not an address range: install
  confirms the system's guard page above the uncommitted reservation and a
  stack guarantee of at least `GUARANTEE` (measured: never lower it without
  measuring the handler's path again), and refuses otherwise.
* Every coroutine switch publishes the stack it *arrives* on, after the
  switch (runtime/coroutine.rs's `segment`, `co_body`, `rt_co_yield`), never
  the one it is about to switch to: bl_co_switch's pushes (on Windows,
  SwitchToFiber's) land on the stack it leaves. Publication stays inlined
  atomic stores (no frame of its own), double-buffered on every host; the
  Windows guard claims STATUS_STACK_OVERFLOW at an address of the
  published stack's reservation (a coroutine fiber's, or the thread's).
* NATIVE LIMIT STACK is terminal: no in-process recovery, no Botlish
  handler, no new error, and no call effect for it where native frames
  hold the roots (only the fallback plan's shadow stack can fail a call).
  Its line is RtError::StackOverflow's.

A Tcl test of an overflow carries `nativeStackGuard` (tests/helpers.tcl), a
capability of the host target, not `nativeLinux`, and one of a coroutine's
stack `nativeCoroutines` too. If you change the guard, a host's stack
discovery, publication or the switch, the stack probes or
`native_stack_overflow_supported()`, run `cargo test --release
--manifest-path native/Cargo.toml --test native_stack` (it runs every
faulting check in a child process: never fault in a test's own process),
the Rust tests (also under `BOTLISH_NATIVE_GC_STRESS=1`),
`tests/native-stack-overflow.test`, `tests/coroutines.test`,
`tests/platform/native-status.tcl`,
`audit/native-stack/tools/mutate.tcl` (every mutant in its `mutants.txt`
that applies to the host must still apply and be killed: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule; a mutant of `platform/macos.rs` runs on macOS only, of
`platform/windows.rs` on Windows only: the tier item
`native-stack-mutants`), and the macOS smoke job and `CI-Tests:
native-stack-overflow.test rust native-stack-mutants` on a branch (macOS
facts are CI's: the shared Mac is not used); for the Windows guard, the
Windows workflow on the branch (its smoke job runs the native stack
checks, and `[ci-full]` with `CI-Tests: native-stack-mutants` the
mutants). `bench/native-stack-guard.tcl` compares a driver against a
baseline build (`-baseline-rev main`; the tier item `native-stack-bench`
on a macOS runner).

## Linux AArch64

The native backend runs on Linux AArch64 (the `tests-arm64.yml` CI jobs) with
the x86-64 feature set except what is tied to the x86-64 instruction set:
the JIT, native-frame stack maps (runtime/framewalk.rs; on AArch64 a stack
map entry is a root's distance below its own frame's FP, codegen::clif's
`define`), the stack-overflow guard (runtime/platform/), coroutines
and rustc-linked executables, and Linux syscalls through the AArch64
transport (next section). The `stub` linker remains x86-64 only: the Tcl
tests that need it carry `stubLinker`. A Tcl test that needs the native
runtime on Linux (coroutines, stack maps, GC-stress evidence), or makes
syscalls only through the portable wrappers (`std::linux::write`, `std::linux::read`,
`std::linux::io`), carries `nativeLinux`; one that runs the x86-64 transport or
reads x86-64 machine code carries `linuxX86_64`, the AArch64 transport's
`linuxAarch64`; one that only needs a standalone executable,
`executableAot`. A test that only compiles a transport (its NIR, CLIF, a
diagnostic) needs no host, like any NIR or CLIF test: it names `-target`
when it compiles through `std::linux::sys`. Golden suites that make live syscalls through one
transport declare `# golden-host: linux-x86_64 -- REASON` (or
`linux-aarch64`; tests/golden/run.tcl). Never gate a test on `linuxX86_64`
for anything but running the x86-64 instruction set or syscall ABI. A change to the
walker, the switch or root lowering needs a GC-stress run on both
architectures; CI's arm64 workflow has one.

## macOS arm64 (the port in progress)

The native backend is being ported to macOS on Apple Silicon
(MACOS-AARCH64-PORT-AUDIT.md: the Linux assumptions by subsystem, the
census of what passes there today, the CI and the roadmap; one milestone
at a time). Develop on Linux (or macOS); the Apple Silicon testing runs in
GitHub Actions, `.github/workflows/macos-arm64.yml`, on every push to any
branch (not documentation-only ones) -- never on a shared development Mac,
and no acceptance depends on one.

* Every push runs Tier A on macOS (`smoke`: the host and its toolchains,
  Tcl 9.0.1 built from its pinned source by `tests/platform/setup-macos.sh`
  -- not Homebrew's newer Tcl, whose Unicode 17 case tables break the Tcl
  backends' Unicode 16 semantics -- `tests/platform/cabi-facts.tcl`, the
  native build and its Rust unit tests, `tests/platform/native-status.tcl`,
  `tests/platform/aot-facts.tcl` (the program object and an executable as
  the host's tools see them), `tests/platform/tier.tcl smoke`), Tier B (`tier.tcl acceptance`, two
  shards) and the same smoke on ubuntu as a control. Locally, `tclsh9.0
  tests/platform/tier.tcl smoke` takes seconds, and `tier.tcl X.test
  Y.bot` runs any file or suite the way CI does.
* Tier C is opt-in: `[ci-full]` in the message of a push's head commit
  runs the acceptance tier under GC stress, in three shards; a `CI-Tests:`
  trailer in that message narrows it to tier.tcl items (`CI-Tests:
  coroutines.test enums.bot`; `all` is the whole census), and
  `CI-GC-Stress: 1` adds GC stress to them. Once the workflow is on main, a
  manual run (`workflow_dispatch`: `tier`, `tests`, `gc_stress`) does the
  same on any branch.
* What each native capability does on each host -- works, or its exact
  refusal -- is recorded in `tests/platform/native-status.tcl`, and the
  test files that do not pass on macOS yet, with their causes, in
  `tier.tcl`'s `notYet`. A milestone that changes either updates it in the
  same change (and the audit's census). Never weaken a test to make macOS
  green; a file joins `notYet` only with a cause the census records and a
  milestone owns (a capability not ported yet, or a host-toolchain
  difference such as c-bindgen.test's), never for a regression.
* Linux CI is unchanged and stays the authority for Linux: run tests.yml
  and tests-arm64.yml (and static-decisions.yml for a front-end change) on
  the branch with workflow_dispatch before a port change merges. A
  macOS-motivated test constraint names a capability, never the OS.

## Windows x86-64 (MSVC)

The native backend runs on Windows x86-64 with Microsoft's toolchain
(WINDOWS-X86-64-MILESTONE-1.md; the census and the toolchain decision are
WINDOWS-TOOLCHAIN-CENSUS.md): the driver and runtime built for
`x86_64-pc-windows-msvc`, executables linked by rustc with `link.exe`,
`windows-x86_64` the one native Windows target. Keep it so:

* MSVC is the supported Windows toolchain. Never add a second native
  Windows backend for MinGW: `windows-x86_64-gnu` stays a target row of the
  binding generator (its committed Win32 binding), and the driver refuses a
  program built for it (`same_target` compares the triple's environment:
  NATIVE TARGET). The startup crate is compiled with the driver's own
  `--target`, never whatever rustc's host is.
* Code generation, the object writer and the link stay Cranelift's, the
  `object` crate's and rustc's -- or, for the system linker, link.exe's,
  the one a Developer environment puts on PATH: no Windows assembler,
  object rewrite, linker, CRT startup or Visual Studio discovery of
  Botlish's (rustc finds link.exe and the SDK without a Developer Command
  Prompt; the system linker is told where it is). The system linker links
  with rustc's CRT policy (below) and `/INCREMENTAL:NO` (an incremental
  link's thunks would move a function's address off its code). The object
  is the same COFF for both Windows environments; never add a
  target-specific object transformation.
* The link plan is `LinkerFlavor::Msvc`'s (`/LIBPATH:DIR`, `NAME.lib`, no
  group): never a GNU flag to link.exe. Every executable -- one that calls
  C too -- links the static release C runtime (`crt_args`, `+crt-static`)
  and excludes every other Microsoft runtime library (`/NODEFAULTLIB:`,
  `OTHER_MSVC_RUNTIMES`), so it holds one C runtime and imports only the
  system's DLLs: never let it import `VCRUNTIME140.dll` or the UCRT, never
  link a second runtime beside the static one, and never impose the
  executable's runtime on anything else (the driver; a DLL keeps its own)
  (WINDOWS-X86-64-MILESTONE-2.md, "The C runtime"). A static C library must
  be `/MT`: a `/MD` one's `__imp_` imports of the runtime fail to link
  (LNK2019; `link_hint` explains them), and that is the policy's answer,
  never a reason to link the dynamic runtime.
* C calls run on Windows (`C_CALLS`; WINDOWS-X86-64-MILESTONE-2.md): the
  Win64 convention is Cranelift's `windows_fastcall`, checked against
  MSVC-built callees (tests/cffi/fixture.c with fixture-win64.asm's
  register and stack capture; c-ffi.test's `cf-abi-*` Win64 model:
  positional registers, the 32-byte shadow space, 8-byte stack slots,
  LLP64's 32-bit `long`). Variadic C calls run on Windows too
  (WINDOWS-X86-64-MILESTONE-6.md): every argument at its position, and a
  call of a variadic function passes each float or double of the first
  four positions -- fixed ones included -- in both its xmm register and
  its position's integer register, as its own 64 bits (the Win64 stub,
  Compilation targets below). It is checked against MSVC's own variadic
  calls (fixture-win64.asm's `bcf_vcapture`, c-ffi.test's `cf-va-abi-*`
  Win64 model) and MSVC-built `va_arg` callees: never count the positions
  per kind, convert a double instead of copying its bits, pass a duplicate
  as an extra argument (it shifts every later position), or apply the rule
  to a fixed-arity call. The tests build their C fixtures with MSVC's cl, lib
  and ml64 through tests/ctoolchain.tcl, whose vcvars64.bat environment is
  set for those tools' runs alone: Botlish's own links never run in it.
* A linked run (a program that calls C, run by the native backends) starts
  its executable with the run's argument snapshot: on Windows with a
  command line the driver writes (`native/src/launch.rs`) and
  `CreateProcessW`, never `std::process` (whose argument zero is the
  executable's path), a shell or a naive join; a snapshot no Windows
  process can receive (no WTF-8, a NUL, a quotation mark in argument zero,
  a line over 32767 units) is NATIVE UNSUPPORTED, never replaced.
* Windows I/O (stdlib/windows.bot, stdlib/windows/io.bot): the `windows`
  namespace is the Windows platform's (core/cabi.tcl's `platforms`);
  kernel32's GetStdHandle, WriteFile and GetLastError through ordinary
  `extern c fn`s, the last-error code read right after the failed call. A
  standard handle is borrowed: never close one, never cache it in a
  context (WindowsIO holds devices: a cached handle would outlive the
  process replacing it, although a context may own a pointer since
  CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md).
  No Win32 call in `io` or any portable module, no console mode, code page
  or UTF-16 conversion of the bytes, no compiler knowledge of printing.
* An executable's name ends in `.exe` (`codegen::aot::executable_path`: a
  name without an extension gets it); `native::executable` returns the
  file, and a test runs that file, never the name it passed.
* GC roots: one capability, `runtime::framewalk::NATIVE_FRAME_ROOTS`,
  decides stack-map emission (`clif.rs`'s `stack_maps`), the root plan,
  the shadow stack (`Vm::new`), the root report and the walk itself. It is
  true on Windows since WINDOWS-X86-64-MILESTONE-3.md: Botlish frames keep
  Cranelift's frame-pointer chain and stack maps, and the walk crosses
  every other frame (the collector's, runtime helpers, a runtime function
  that calls a closure such as `std::mutable_array::generate`, the driver) with
  Windows' unwinder (`RtlLookupFunctionEntry`,
  `RtlVirtualUnwind`: framewalk's `windows`). LLVM's Win64 prologue puts
  the frame pointer inside the frame: never walk a Rust frame by its RBP on
  Windows, forced frame pointers or not, and never add a second, diverging
  check of the capability.
* Unwind information: every Botlish function has Windows x64 unwind
  information, encoded by `codegen::unwind` from Cranelift's own prologue
  description (`UnwindInst`), never by Cranelift 0.135.2's winx64 encoder,
  which restores callee-saved registers from the wrong slots
  (`cranelift_windows_encoding_defect_still_present`: when it fails, check
  Cranelift's encoding against Windows' unwinder before taking it). A
  prologue of another shape is an error, never described approximately.
  The COFF object carries it in `.pdata`/`.xdata` (`add_windows_unwind`;
  the same COFF for both Windows environments); the JIT registers it with
  `RtlAddFunctionTable` (`codegen::jitunwind`: code, data and unwind
  information in one reserved range, the function table's base; the table
  deleted before the code is released, which `CompiledProgram`'s field
  order does). `BOTLISH_NATIVE_UNWIND_CHECK=1` compares every Botlish
  function's entry and every walked Botlish frame with Windows' unwinder
  and reports a count on standard error at the end of a run.
* Depth: the stack guard (`runtime/platform/windows.rs`,
  WINDOWS-X86-64-MILESTONE-4.md; "The native stack guard", above) bounds
  recursion, as on Linux and macOS: no function checks its depth, no
  Botlish call can fail for the stack (`depth_checked` is false where
  native frames hold the roots), and no shadow stack is allocated.
  Native-frame roots need the guard (`native_stack.rs`'s assertion): never
  bring back a stack-pointer check, a depth token or a call effect for the
  stack on a host that has native-frame roots; a host without the guard
  starts on the fallback plan.
* The fallback plan (shadow-stack roots and depth, leaf frames published,
  no walk) remains the bootstrap of a host without native-frame roots: the
  `fallback-roots` cargo feature builds it on any host, to run the suite
  with it (a test build, never shipped; CI's Windows `roots` job runs its
  Rust tests and the GC workloads). It does not support coroutines (a
  suspended coroutine's shadow slots break the shadow stack's order) and
  refuses them (`rt_co_start`: NATIVE UNSUPPORTED; `STACK_SWITCHING` is
  false, so nothing fuses one either): never make it coroutine-aware, and
  never let it run one; a host with native coroutines needs native-frame
  roots.
* Coroutines (WINDOWS-X86-64-MILESTONE-5.md, runtime/coroutine/windows.rs):
  a coroutine stack is a Windows fiber -- CreateFiberEx with
  FIBER_FLAG_FLOAT_SWITCH, the thread made a fiber once by
  ConvertThreadToFiberEx (converted back when it ends; a thread something
  else made a fiber is left as it is, never converted back) -- and the
  switch is SwitchToFiber, under the code every host shares
  (runtime/coroutine.rs). Keep it so:
  - Never write a TEB field (NT_TIB's StackBase or StackLimit, the
    DeallocationStack, the GuaranteedStackBytes) or switch a stack pointer
    across stacks yourself: Windows reads them to grow a stack, to raise
    STATUS_STACK_OVERFLOW and to unwind, and only the fiber switch keeps
    them (the report's experiments: a custom switch fails growth, C calls
    and panics without them, and needs two undocumented offsets with them).
  - A fiber gets its own stack guarantee (`GUARANTEE`, the guard's) and its
    guard page is confirmed in its setup, on the fiber, before any Botlish
    code runs there; a fiber that fails either is deleted and the start
    refused. A fiber starts with no guarantee: never assume the thread's.
  - `bl_co_switch` records its own frame (RIP, RSP, RBP), which is where the
    collector's walk of the stack it leaves starts (framewalk's Windows
    `walk_from`, Windows' unwinder from there, within that stack's bounds):
    keep it never inlined, and record nothing but what it holds at the call
    of SwitchToFiber.
  - Every fiber is pooled as a POSIX stack is: a start of a parked fiber
    restarts it at its entry's top (`bl_co_fiber_restart`), whatever it
    parked in, with the entry's return address under the body, so its
    frames unwind into Windows' fiber start. Never resume a parked fiber
    any other way, never pool a running one, and never DeleteFiber the
    running fiber (it would end the thread).
  - TLS is the thread's and FLS the fiber's: keep runtime state in
    thread-locals (shared by every fiber of the thread); never move it to
    FLS without a reason the report records.
* Stack probes are on on Windows (`codegen::stack_probes`): Windows
  commits a thread's stack a page at a time, and a frame that skipped the
  system's guard page would fault in the uncommitted reservation (an
  access violation, which the guard never relabels) instead of raising the
  STATUS_STACK_OVERFLOW the guard reports. They are stack growth, not the
  guard: never turn them off.
* Arguments: a Windows process's command line, split by the Microsoft C
  runtime's rules (Rust's `args_os`), each argument's UTF-16 as WTF-8
  (`runtime::aot::wtf8_from_utf16`): never `OsString`'s internal encoding,
  never a lossy conversion (ARGV.md, "Windows").
* What each native capability does on Windows is recorded in
  `tests/platform/native-status.tcl` (its windows-x86_64 row) and
  `native/native.tcl`'s `capabilities` table (which tests/helpers.tcl's
  `executableAot`, `nativeCCalls`, `nativeCoroutines`, `nativeStackGuard`,
  `nativeFrameRoots` (and from the last two `nativeDepthChecked`: false on
  Windows since its guard) and the golden runner read); the test files that do not pass on
  Windows yet,
  with their causes, in `tests/platform/tier.tcl`'s `notYetByHost`. A
  milestone that changes one updates it in the same change; never weaken a
  test to make Windows green. A test that needs a capability carries its
  constraint; a test of the root plan or of call effects expects the
  host's by `nativeFrameRoots`/`nativeDepthChecked`; a test of C scalar
  widths reads the target's row (`long` is 32 bits on Windows); one that
  reads main.tcl's output untranslated expects CRLF from main.tcl's own
  lines on Windows.
* CI: `.github/workflows/windows-x86_64.yml` on every push (windows-2025,
  production code, Tcl 9.0.1 built by `tests/platform/setup-windows.ps1`):
  the smoke job (the Rust tests, `native-status.tcl`, `aot-facts.tcl`'s
  COFF/PE checks and unwind information, C calls through link.exe and the
  C runtime matrix, `tests/platform/gc-workloads.tcl` under GC stress and
  under the unwind check, the 2048 executable, Windows I/O redirected by
  bash, cmd and PowerShell, dumpbin's headers and unwind information, the
  smoke tier and the Windows-relevant test files), the `roots` job (the
  fallback plan's Rust tests and GC workloads, `bench/root-plans.tcl`;
  `[ci-probes]` or a manual run adds `audit/windows-unwind`'s anchor probe)
  and the acceptance tier in four shards; `[ci-full]` or a manual run adds
  the GC-stress tier.
  Neither Wine nor WSL is an authority for Windows; a `-gnu` cross build
  under Wine is a development aid only.

If you change Windows coroutines (runtime/coroutine/windows.rs, the
Windows `walk_from`, the Windows guard's publication), run the Rust tests
on Windows (`cargo test --lib coroutine`, `--bins suspended_root`), `cargo
test --test native_stack` there (its coroutine exhaustion, publication,
fault and sweep checks), `tests/coroutines.test`,
`tests/native-stack-overflow.test`, `tests/platform/native-status.tcl`,
`tests/platform/aot-facts.tcl` and `tests/platform/gc-workloads.tcl
-unwind-check 1` (its coroutine workloads) on Windows, the probe
(`.github/workflows/windows-coroutines-probe.yml`, for a change to what
it measured), and `audit/native-stack/tools/mutate.tcl` and
`audit/windows-unwind/tools/mutate.tcl` (their `win-*`, `walk-suspended-*`
and `switch-*` mutants on Windows: the tier items `native-stack-mutants`
and `windows-unwind-mutants`), plus the coroutine harnesses above.

If you change Windows unwind information (`codegen::unwind`,
`add_windows_unwind`, `codegen::jitunwind`), the Windows walk
(`framewalk::windows`) or Cranelift's version, run
the Rust tests (on Windows too: the JIT's function table and the virtual
unwind tests run there only), `tests/platform/gc-workloads.tcl
-unwind-check 1` and `tests/platform/aot-facts.tcl` on Windows, and
`audit/windows-unwind/tools/mutate.tcl` (every mutant in its `mutants.txt`
that applies to the host must still apply and be killed; on Windows the
tier item `windows-unwind-mutants`).

If you change the Windows link plan, the CRT policy, executable naming,
`EXECUTABLES`/`C_CALLS`, `same_target`, `NATIVE_FRAME_ROOTS` or what reads
it, the stack probes, the Windows argument encoding or the linked-run
launcher, run the Rust tests, `tests/native-executable.test`,
`tests/target-model.test`, `tests/argv.test`, `tests/c-ffi.test`,
`tests/platform/native-status.tcl`, `tests/platform/aot-facts.tcl`,
`tests/platform/gc-workloads.tcl` (also with a `fallback-roots` driver:
`cargo build --release --features fallback-roots` into another target
directory, `BOTLISH_NATIVE_BIN` pointing at it),
`audit/native-aot/tools/mutate.tcl` and
`audit/target-model/tools/mutate.tcl` on Linux, and the Windows workflow on
the branch. If you change stdlib/windows.bot or stdlib/windows/io.bot, run
`tests/windows-io.test`, `tests/portable-io.test`,
`tests/context-traits.test` and `audit/context-traits/tools/mutate.tcl
-only 'windows-*'` (its `%% windows-x86_64` mutants on Windows: the tier
item `windows-io-mutants`), and the warning gate.

## Compilation targets

A compilation target (core/cabi.tcl's table; MACOS-AARCH64-MILESTONE-2.md)
is an operating system *and* an architecture, named to the native backend
by its triple: linux-aarch64 and macos-aarch64 share an instruction set, not
a target. On Windows the C toolchain's ABI family is part of it too:
windows-x86_64 (MSVC's) and windows-x86_64-gnu (MinGW-w64's,
C-BINDGEN-LAYOUTS.md) have equal rows and are two targets. Keep it so:

* Never read an operating system from an architecture, a pointer width or a
  data model, and never take a matching architecture for a matching target
  (C facts, module selection, interchange, the cache key, native
  execution). The table is the one target representation: a new fact goes
  in its row, never a second table (the driver reads the triple; Cranelift
  derives the C convention and the object format from it).
* The `linux` namespace and everything under it are the Linux platform's,
  `darwin` and everything under it the macOS platform's (core/cabi.tcl's
  `platforms`, surface/modules.tcl's `PlatformCheck`): UNSUPPORTED-PLATFORM
  for a target of another operating system. A platform is designated in
  that table, never read from a namespace's spelling. Never map one
  platform's module to another system's, and add no Darwin syscall
  transport (Darwin IO is libSystem's, below). An
  architecture-specific namespace that is no platform's stays every
  system's.
* A build reads the target in three places (ModuleFile's architecture file,
  PlatformCheck, std::ffi::c's scalars), and the HIR records the target only then
  (`hir::cabi::targetOf`; the loader's `targetRead`): a new place that reads
  the target sets it too. A HIR built for one target is never taken for
  another's: `hir::interchange::decode -target` refuses it, the cache key
  holds the full target, and the driver refuses to run or emit machine code
  for another target's program (`NATIVE TARGET`). Never add a way around
  either.
* Foreign C signatures use `codegen::target::c_call_conv` (the triple's C
  convention: AppleAarch64 on Apple AArch64); Botlish-internal and runtime
  helper calls the ISA's default. Never hard-code a convention, a register
  or a stack placement: Cranelift owns them. Botlish decides only what it
  asks of them: a narrow parameter's extension attribute, which Apple's
  stack-passed parameters do not carry (`c_extended_parameters`:
  cranelift-codegen 0.135.2 stores an extended stack argument at register
  width, past its slot; fixed in 0.136.0, where
  `ffi_apple_extended_stack_argument_defect_still_present` fails and the
  exception goes). The registers are counted per kind, as AAPCS64 does:
  the eight that keep it are integer-register parameters, never the first
  eight positions (doubles take v0-v7; `cf-abi-doubles-before-integers`).
  The registers Botlish places itself are those of a variadic call's stub
  (`va_stub`, `va_stub_for`; Variadics, below), because Cranelift can give
  no value a fixed register at a call, nor one value two argument
  registers: x86-64 System V's `%al` (`mov`), and Win64's copy of each
  float or double of the first four positions from its xmm register into
  its position's integer register (`movq`, WINDOWS-X86-64-MILESTONE-6.md),
  then a jump to the C function. A Win64 call with no floating-point
  argument there needs no stub. Never extend either to another register or
  argument, never give a stub a frame or a call, and never add a third
  without first showing, as that report's experiment does, that no
  Cranelift signature of the pinned release can state the rule.
* A test that compiles a Linux program (one importing `linux::*`) compiles
  it for `linuxTarget` (tests/helpers.tcl: the host's own on Linux) and runs
  it on `backendsFor` its HIR's target; the golden runner, the warning
  gate and Compilerpedia's example check (tools/compilerpedia.tcl) do the
  same for a program that imports one (`surface::modules::PlatformTarget`).
  Never skip such a test by operating system instead.

If you change the target table, `hostTarget`, the platform rule, what makes
a HIR record its target, interchange's or the cache's target check, NIR's
`target` line or native/src/codegen/target.rs, run
`tests/target-model.test`, `tests/linux-syscall-transports.test`,
`tests/c-abi-types.test`, `tests/hir-cache.test`, `cargo test --release
--manifest-path native/Cargo.toml --bin botlish-native target::` and
`audit/target-model/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), and keep the
Compilerpedia topics that state these rules true (`backend.targets`,
`error.unsupported-platform`, `error.hir-interchange-target`,
`error.native-target`; `tools/compilerpedia.tcl check`). Apple clang checks
the macOS row in every macOS smoke job (`tests/platform/cabi-facts.tcl`),
and `tests/platform/native-status.tcl` the native target boundary.

## Linux syscall transports

A raw Linux syscall is one architecture's transport
(LINUX-SYSCALL-TRANSPORTS.md, LINUX-X86-64-SYSCALL.md):
`std::linux::abi::x86_64::syscall` ({rax, rdi, rsi, rdx, r10, r8, r9}, `syscall`)
and `std::linux::abi::aarch64::syscall` ({x8, x0..x5}, `svc #0`), each over its
own `std::abi::ARCH::Register64`, with its own address bridges. They are rows of
one table, `core::linuxabi`'s `transports`: the contract (hir/syscall.tcl),
escape analysis (hir/escape.tcl), lowering (native/lower.tcl) and the Tcl
refusal read the row of the native a call names. Never name a transport, its
register type or its op outside the table, never let one architecture's
register word reach the other's transport, and never give a transport
knowledge of a syscall (numbers are source data). A third architecture is a
row, a Rust boundary (native/src/runtime/syscall.rs) and an `std::abi::ARCH`
module.

Everything above the transports is one source: `linux` (stdlib/linux.bot),
`std::linux::io` and `io` name no register, number or transport. What differs by
architecture is `std::linux::sys`, an architecture-specific module
(`stdlib/linux/sys.x86_64.bot`, `stdlib/linux/sys.aarch64.bot`): the loader
(surface/modules.tcl's `ModuleFile`) picks `stdlib/P.ARCH.bot` by the
compilation target's architecture (`-target`, the host's by default) when
there is no `stdlib/P.bot` -- for a Linux target only: `linux::*` is the Linux
platform's (Compilation targets, below). Keep both files' surfaces identical
(`lst-linux-sys-same-surface`). The front-end cache records both candidate
paths of every imported namespace (`surface::cache::Dependencies`); a new
input that selects a file must go there too.

If you change the transports, the table, the bridges, `std::linux::sys` or the
loader rule, run `tests/linux-syscall.test`,
`tests/linux-syscall-transports.test`, `tests/abi-bytes.test`,
`tests/abi-mutable-bytes.test`, the golden suites `linux-io.bot`,
`linux-transports.bot` and `abi-bytes-native.bot`,
`audit/linux-x86-64-syscall/tools/fuzz.tcl`, the abi-bytes and mutable-bytes
mutation tools and `cargo test --release --manifest-path native/Cargo.toml
--lib syscall`; for a change to the loader rule or the cache, also
`tests/hir-cache.test` and `audit/hir-interchange/tools/roundtrip.tcl -via
cache`. Without an arm64 machine, the AArch64 side can be checked under
qemu-user: build the driver with `--target aarch64-unknown-linux-gnu`
(linker `aarch64-linux-gnu-gcc`), point `BOTLISH_NATIVE_BIN` at a script
that runs it through `qemu-aarch64 -L /usr/aarch64-linux-gnu`, and set
`::tcl_platform(machine)` to `aarch64` before sourcing a test file (its
executable tests need a native arm64 host); CI's arm64 workflow
(`workflow_dispatch` on a branch) runs everything natively.

## Darwin IO (libSystem)

macOS's IO is libSystem's C functions, never a syscall
(MACOS-AARCH64-MILESTONE-8.md): Darwin's kernel interface is private, its C
library the stable one. `darwin` (stdlib/darwin.bot, a designated direct
module) declares `write`, `read`, `open`, `close` and `__error` as
`extern c fn` by their SDK prototypes and wraps each in one C call;
`std::darwin::io` (stdlib/darwin/io.bot) is the opaque `DarwinIO` context
implementing `std::io::IO` with std::linux::io's completion policy; `std::darwin::path`
(stdlib/darwin/path.bot) is `DarwinPath`. `darwin` is the macOS platform's in
core/cabi.tcl's `platforms` (Compilation targets, below). Keep it so:

* No Darwin syscall, syscall number, `svc #0x80`, x16 or transport, and no
  compiler, runtime or Tcl knowledge of IO: every effect is an ordinary C
  call through the C FFI and byte borrowing (write's buffer `read noescape`,
  read's `write noescape`, open's path `read noescape`), every constant the
  SDK's (`di-sdk-facts` compares them on macOS), never Linux's.
* Darwin reports failure as C does (-1, the reason in errno), never as
  Linux's `-errno`: a result holds the C result and, separately, the errno,
  read only after a failure and right after the call, before anything that
  could call C (`di-errno-read-first` pins the NIR). errno is read through
  `__error()` and a native view of a one-field layout: no pointer
  dereference operator, no stored or cached errno pointer, no global errno.
  Nothing runs between `std::darwin::read`'s call and its errno read but the
  keepalive (no machine code) and the comparison: its write-back value is
  fields (C FFI error capture, below); never add a statement there.
* `open` is declared with its genuine variadic prototype; the creation mode
  is its one trailing argument, an `std::ffi::c::UShort` (macOS's `mode_t`).
  Never declare a variadic C function with a fixed trailing parameter: on
  Apple arm64 the two travel in different places.
* std::io::IO stays platform-free: DarwinIO satisfies it structurally from its
  own module; never add a runtime dispatch, a registration or an OS check to
  stdlib/io.bot. The completion policy is LinuxIO's (no retry of EINTR or
  EAGAIN); change both or neither.
* A test that runs Darwin IO carries `darwinIO` (tests/helpers.tcl: a
  capability -- the host's target is the darwin platform's and C calls
  link), never an OS check. Faults are injected with tests/cffi/write-
  inject.c (a dyld interposer of libSystem's `write`), never by a test
  hook in the library.

If you change stdlib/darwin.bot, stdlib/darwin/io.bot, stdlib/darwin/path.bot, the
platform row, or what they rely on (the C FFI's contracts, byte borrowing,
native views, variadic calls, context-trait satisfaction), run
`tests/darwin-io.test` (its front-end half runs on every host),
`tests/context-traits.test`, `tests/portable-io.test`,
`tests/target-model.test`, `tests/workload-2048.test` and
`audit/context-traits/tools/mutate.tcl` (its `darwin-*` mutants run on
macOS through the tier item `darwin-io-mutants`; every mutant that applies
to the host must still apply and be killed), and on macOS (a branch push
with `CI-Tests: darwin-io.test ...`) the darwin-io tests themselves.
`bench/darwin-io.tcl` (tier item `darwin-io-bench`) is the performance
report.

## Affine values

Affinity (AFFINE-VALUES.md) is a compositional property of a value's type:
the coroutine handle is the one primitive affine root, and a struct,
anonymous struct or List that owns an affine value is affine too
(`hir::types::Affinity`/`IsAffine`, the one query every ownership decision
asks). An affine value has one usable owner and moves through bindings,
arguments, results, struct fields and List elements; it is released where
its owner dies, by its type's static drop descriptor (`coroutine#release`,
or `affine#drop`/`affinedrop` for an aggregate). `Fn{...}` and
`Coroutine{...}` share one callable contract (args, return, errors) and stay
distinct callable kinds: never add an implicit conversion between them, a
runtime callable-kind dispatch, or runtime ownership state (a moved flag, a
reference count, an ownership object): `tests/affine.test`'s
`af-native-runtime-source`, `af-generic-dual` and `af-native-evidence` pin
this. An exact function value stays unrestricted. A generic (untyped)
function given an affine argument is specialized for it by the trait
monomorphization (`hir::traits::NeedsAffinePlan`, `AffineWitnesses`), never
dispatched at run time; `hir/affine.tcl` must never ask whether a value is a
coroutine, only whether its type is affine. The terms are unrestricted,
affine, move, release/drop, callable contract and callable kind; an affine
value is not a reference, a borrow or a linear value, and may be dropped
unused.

If you change the affinity query (`hir/types.tcl`, `hir/structs.tcl`),
`hir/affine.tcl`, contract-based call typing of `Fn`/`Coroutine` callees
(`hir/types.tcl`'s `Call`, `hir/range.tcl`'s `VerifyStructuralCall`,
`hir/completions.tcl`), `hir::coroutines::ElaborateResumes`, the affine
specialization (`hir/traits.tcl`, `hir/semantic.tcl`'s affine instances,
`hir::signatures::CallableAdmits`), release or pending-temporary lowering in
any backend, or the drop runtimes (`core/affine.tcl`,
`native/src/runtime/affine.rs`), run `tests/affine.test`,
`tests/coroutines.test`, `audit/affine/tools/fuzz.tcl` (several seeds),
`audit/affine/tools/mutate.tcl` and `audit/coroutines/tools/mutate.tcl`
(every mutant in both `mutants.txt` files must still apply and be killed;
the coroutine mutants of ownership and release edit `hir/affine.tcl` too).
A change to `hir::traits::Plan` for affine witnesses also means re-checking
the trait and context-trait mutants. A change to native drop or release
lowering also needs a `BOTLISH_NATIVE_GC_STRESS=1` run of
`tests/affine.test` and `cargo test --release --manifest-path
native/Cargo.toml --lib affine`. `bench/affine.tcl` regenerates the
performance report. `hir::affine::verify` computes release scopes (and so
`AFFINE-PATH-RELEASE-UNSUPPORTED`) only for a program its whole-program
analysis accepts, a program-wide channel of the static decisions
(`hir/staticdeps.tcl`'s `C:verdict`, which lists that analysis's diagnostic
kinds): a change to that gate, to those kinds or to which joins can hold a
path-release diagnostic also needs `tests/static-economics.test` and the
static-decision harnesses (Static intrinsics, below).

## Context-owned affine state

An installed context owns what it holds, affine members included
(CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md): `with context EXPR` moves the
value into the installed context (context#install's ownership role is
`move`), and a context parameter is no second owner -- its binding names the
installed storage, never moved, copied or released
(`hir::affine::IsContextBinding`; `IsAffineBinding` is 0 for it). Every
expression reaching into it is a *context place* (`hir::affine::
ContextPlace`: the binding, a field projection of a context place, an
element place of a collection at one), and an affine value there is
observed where it is stored, never copied out (`ContextConsumer`:
AFFINE-CONTEXT-COPY-OUT). Keep it so:

* One meaning per form: a projection of a context place is a place step,
  never a copy that becomes a move where a move is expected; an element
  place (a native registered `-element-place`, `std::mutable_vector::
  element`, `std::mutable_array::element`) is the place of an element
  whose receiver is a context place (MUTABLE-PLACE-RECEIVER otherwise),
  never a value, and read by registration, never by name. Moving out of a
  context goes through a collection member's explicit moves (push in;
  take, pop, swap out); a direct member is owned for the program's
  lifetime and only observed or cloned explicitly.
* No borrow system: never add a reference type, a borrowed or observing
  parameter, a lifetime, a place binding (`s = c.v.element(0)` stays
  AFFINE-CONTEXT-COPY-OUT) or an implicit clone; never extend place
  observation to places not rooted at a context parameter (an owned local's
  affine field stays AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE) without a
  design of its own. An observation through an element place whose call's
  later argument may run code is rejected (`LaterArgumentRunsCode`): never
  drop that check.
* No lifecycle: nothing releases what an installed context owns at the
  program's end (affinity is at most once), and there is no destructor,
  scoped installation or runtime ownership state; a close is the program's
  explicit operation.
* Natively a C address word (a pointer, a native view or edit) is an
  immediate context-slot leaf (`native::lower::ContextLeaves`'s `cptr`) and
  a collection header is rooted by `ctxroot`; never admit a kind whose word
  may be a heap pointer as an immediate leaf, and never add a resource
  table to the runtime.
* An affine struct's unrestricted collection slots are copied like an
  unrestricted struct's (`hir::mutvec::ShareDescriptor` lists them): an
  unrestricted vector beside an affine member stays a value.

If you change any of that (the report's "What to run when changing this"
lists the files), run `tests/context-affine.test`, `tests/contexts.test`,
`tests/context-traits.test`, `tests/affine.test`, `tests/coroutines.test`,
`tests/mutable-vector.test`, `tests/mutable-array.test`,
`tests/c-abi-types.test`, `tests/workload-icy-tower.test`,
`audit/contexts/tools/fuzz.tcl -owned 1` (several seeds) and
`audit/context-affine/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the affine,
coroutine, mutable-vector and mutable-array harnesses for a change to
`hir/affine.tcl` or `hir/mutvec.tcl` (above), a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/context-affine.test` for a change
to the native slots, and `tclsh9.0 audit/icy-tower/context-refactor/tools/
repro.tcl` (a reproducer whose outcome changes is a census finding that
changed: update the census).

## DecimalRounded and scalar refinements

`DecimalRounded{minDecimalsPreserved: N}` (optionally `maxDecimalsPreserved:
M`; DECIMAL-ROUNDED-MILESTONE-1.md) is a guarantee, not a representation:
rounding the value half to even to any P <= N places gives its intended
decimal. It is the one family of the scalar-refinement schema
(`hir/refinements.tcl`), which owns validation, the canonical form
`{srefined FAMILY FACTS}`, implication, joins and the text. Keep it so:

* Never name `minDecimalsPreserved` or `maxDecimalsPreserved` outside the
  schema table (`dr-schema-generic`); a new family or order is a schema
  row, never type machinery of its own. Scalar refinements are not the
  refinement values of `refined type` (hir/refine.tcl).
* The literal choice is made only in `hir::decimal::resolve` (inside the
  inference fixpoint): a decimal constant expression where a refined
  DecimalRounded type is expected means its exact source decimal; every
  other decimal literal stays a Float64. Never add global literal inference
  or typed locals for it.
* Only decimal constant expressions are proven, by exact simulation of the
  binary64 operations a run performs (`hir::decimal::Facts`,
  `core::decimal::ExactOperation`): never host floating point, never a rule
  from the operands' precisions (no `min`). Arithmetic on any other
  DecimalRounded value is DECIMAL-GUARANTEE-LOST: never give it a type.
* Every observation reads at most the guaranteed precision of its operands'
  static types, written into the call by `hir::decimal::Elaborate` (no
  backend chooses one): comparisons and `==` at the smaller precision, the
  decay at N, the display at N. Type-blind `==`, `hash`, sets and display
  never read a representation (EQUALITY, TYPE, `<DecimalRounded>`). No
  precision metadata at run time; HIR interchange carries a constant's exact
  decimal, never its binary64 (`hir::interchange::WithoutRepresentations`).
* Nothing converts between Float64 and DecimalRounded implicitly: the decay
  is `std::float64::from_decimal_rounded`, minting is a proof or
  `std::decimal_rounded::round[T]` (UnrepresentableDecimal).

If you change any of that (DECIMAL-ROUNDED-MILESTONE-1.md, "What to run
when changing this", lists the files), run `tests/decimal-rounded.test`,
`tclsh9.0 tests/local.tcl tests/golden/decimal-rounded.bot`,
`audit/decimal-rounded/tools/fuzz.tcl` (several seeds),
`audit/decimal-rounded/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule) and `cargo test
--release --manifest-path native/Cargo.toml --lib decimal`.

## Numbers and text

`std::int::to_string`, `std::int::from_string`, `std::float64::round` and
`std::decimal_rounded::to_string` (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md) are
explicit conversions with one rule each. Keep it so:

* An Int's text is its canonical decimal text, `core::value::isCanonicalInt`
  (`0 | -?[1-9][0-9]*`, ASCII digits), both ways: from_string accepts
  exactly what to_string writes, else the declared builtin error
  InvalidIntegerText. Never accept a "+", a leading zero, "-0", whitespace,
  a suffix, a base prefix or a non-ASCII digit, and never give from_string a
  fold (a fold that fails is KNOWN-ERROR whatever handles it). One Int
  formatter per runtime: `core::value::show`, natively `ops::with_int_text`
  (hashing, display, messages and to_string).
* round is round half to even of the exact binary value (core::decimal's
  `RoundAt` at 0), total and exact at any magnitude: never half away from
  zero, never through decimal text, never an overflow error.
* A DecimalRounded value's text is `core::decimal::text` (natively
  `decimal::text_at`) at the precision its static type guarantees, which
  `hir::decimal::Elaborate` writes into the call
  (`decimal_rounded#to_string(x, N)`): never a precision stored in a value,
  never a digit of the representation, never a search over precisions, and
  no operation shows more places than minDecimalsPreserved.
* No implicit number-to-text conversion and no format strings.

If you change any of that, run what NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md's
"What to run when changing this" lists: `tests/numeric-text.test`, its
golden suite, `audit/numeric-text/tools/fuzz.tcl` (several seeds), its
oracle's selftest, `audit/numeric-text/tools/mutate.tcl` (every mutant in
its `mutants.txt` must still apply and be killed: update a mutant's text
when you change the code it mutates, keeping it a mutant of the same rule)
and the Rust tests it names.

## List length refinements

`List[T]{length: N}` (LIST-CARDINALITY-REFINEMENTS.md) is the scalar-refinement
schema's second family (`hir/refinements.tcl`): an ordinary immutable List
whose exact length the compiler knows. Keep it so:

* A refinement is knowledge, never representation: no tag, header, wrapper,
  check or allocation for a refined List on any backend, no conversion at
  decay, and no specialization or instance keyed by a length. Its one
  run-time operation is the explicit validator `std::list::with_length[T](xs)`
  (`list#with_length`, `listwithlen`), which returns its operand.
* One canonical representation: a constant List length is stated by the
  type (`{srefined List {length N} BASE}`) and read from it
  (`hir::cardinality::DefinedLength`, `TypedLength`,
  `hir::types::MeasuredValue`); never add a second constant-length fact
  beside it. A new source mints through `-result-length` (core/native.tcl)
  or the type rules, never by a native's name, and the schema names no
  parameter outside its table (`llr-schema-generic`).
* Exact length is an equality fact: never order it like a bound, invent a
  range in a join, or mint it from an inequality. Admission never inserts a
  length check: recovering a length takes a proof or the validator.
* A minted length is an implementation fact: it crosses a function boundary
  only as a declaration (the family's `declared` interface,
  `hir::types::ForgetInferred`): undeclared results, semantic instances,
  imprint bindings, trait witnesses, callable contracts, mutable element
  contracts and handler admission forget it.
* No MutableVector or MutableArray length refinement, no symbolic or
  relational length, no user-defined key. FIXED-ARITY-LIST-RETURN reads no
  refinement: a declared `List[T]{length: N}` result is a list result type
  like `List[T]`, and an undeclared literal exit warns as before.

If you change the List row or the schema's `exactly`, applied-base or
interface machinery, the refined-List cases of `hir/types.tcl`, the length
guard (`hir/refine.tcl`'s `MeasuredEquality`), admission and its messages
(`hir/range.tcl`), the size forms (`hir/cardinality.tcl`), the proofs that
read them (`hir/completions.tcl`), the copy types (`hir/layouts.tcl`'s
`CopyType`, `CopiedFieldType`), a forgetting boundary, the validator
(`hir/listlength.tcl`, `core/listlength.tcl`, `listwithlen`) or a
`-result-length`/`-measures` registration, run
`tests/list-length-refinement.test`,
`audit/list-length-refinement/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/list-length-refinement/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule) and `cargo test --release --manifest-path native/Cargo.toml
--lib list_with_length`, plus `tests/decimal-rounded.test` with its fuzzer
and mutants for a schema change, `tests/fixed-arity-list-return.test`, and
the layout harnesses (above) for a change to copy types or extent proofs.
`bench/list-length-refinement.tcl` regenerates the performance report.

## Enums

Enums (ENUMS.md) are named, closed, nominal sums of payload-free cases:
`enum Name:` declares one type `{enum ID}` (ID the declaration identity, a
module's `ns::Name`) and its cases; `Name::Case` resolves, as a *type*
qualifier (never a namespace), to a `const` node of the value `{enum ID
CASE}`. A case's identity is (enum identity, case name): never a spelling
alone, never a position. Never add an ordinal, integer or String conversion,
an ordering, a reflection operation (`cases`, `case_count`, `case_name`), an
anonymous enum, a case alias or value, or a global case namespace (a bare
case name must stay unbound); no semantic check may read a case's position
(`hir::enums::cases` keeps declaration order for diagnostics and future
exhaustiveness only). Native case words carry an enum number and a case
number that are representation only: printing and hashing read the names from
the program's enum table. Affinity is derived from the case descriptors'
payloads (`hir::enums::IsAffine`), never decided by being an enum.

If you change the enum grammar (`surface/parser.tcl`'s `EnumDecl`),
`hir/enums.tcl`, the `{enum ID}` cases of `hir/types.tcl`, case resolution
(`hir/resolve.tcl`'s `ResolveEnumCase`, `surface/modules.tcl`'s
`EnumQualifier`), the HIR text of enums (`hir/format.tcl`, `hir/read.tcl`), the
Tcl runtime's enum value, equality or hashing (`core/value.tcl`,
`core/hashing.tcl`), or the native word, enum table, `enumeq` or `rt_hash`
case (`native/lower.tcl`, `native/src/runtime/{value,ops,show}.rs`), run
`tests/enums.test`, `audit/enums/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/enums/tools/mutate.tcl` (every mutant in
`audit/enums/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of the
same rule) and `cargo test --release --manifest-path native/Cargo.toml --lib
enum`. `bench/enums.tcl` regenerates the performance report.

## Error payloads

An error is a nominal identity that may carry a statically known named-field
payload (ERROR-PAYLOADS.md): `error NAME:` and `field: Type` lines, `fail NAME
{field: value}`, `on NAME:` / `on NAME details:` / `on NAME {a, b: c}:`. `on`
discriminates the identity only: never add value patterns, guards, payload-
or shape-driven handler selection, a handler-specific destructuring rule, an
implicit `message`/`code` field, a key/value payload access or a
`Result`/`Error[E]` encoding. The payload is the anonymous struct of the
declared fields (`hir::errordecls::payloadType`), checked like a named
construction (`hir/resolve.tcl`'s `ResolveStruct` with `payloadOf`,
`hir::range::VerifyPayload`); handler destructuring is the ordinary
destructuring expansion over the handler's payload binding
(`surface/lower.tcl`'s `Handlers`). A payload-free error keeps its
one-word representation everywhere (Tcl `{errorId NAME}`, native
`faildeclared ID NAME` with no payload slots): never make every error carry a
payload object. Natively a payload travels field-wise in the Vm's payload
slots (`Vm::declared_payload`, a GC root) -- never box it to transport it.
A coroutine may not fail with an error whose payload is affine
(`hir::coroutines::AffineProtocol`): its cached failure is raised again.

If you change the error declaration or payload grammar, `hir/errordecls.tcl`,
the `fail`/`handle` resolution, typing, affine flow or lowering in any
backend, `errorId` (`core/value.tcl`), the native payload slots
(`native/src/runtime/{vm,ops,coroutine}.rs`, `Inst::Fail`/`DeclaredPayload`)
or `hir::warnings::FailSites`, run `tests/error-payloads.test`,
`tests/errors.test`, `tests/same-failure.test`, `tests/affine.test`,
`tests/coroutines.test`, `audit/error-payloads/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/error-payloads/tools/mutate.tcl`
(every mutant in `audit/error-payloads/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), `audit/same-failure/tools/mutate.tcl`
and `cargo test --release --manifest-path native/Cargo.toml --lib
error_payload`. `bench/error-payloads.tcl` regenerates the performance
report.


### Error identity

A source-defined error's identity is canonical and module-qualified
(ERROR-PAYLOADS.md, "Module-qualified error identity"): `NS::Name` for module
NS's `error Name`, the bare `Name` for the entry program's and for the
runtime's builtin errors. Every spelling (`fail`, `on`, `errors` clauses, a
function type's `errors` list) is resolved once, in the namespace of the code
that writes it (`hir::errordecls::resolve`), and everything downstream --
HIR, contracts, completion sets, Core IR, `errorId`, native ids, rendering,
`SAME-FAILURE` -- holds the canonical string. Never key, compare or dispatch
by a short name, never add an `import error` form, an alias or a
compatibility spelling, and never let a module see the entry program's
errors. If you change error-name resolution or authorization
(`hir/errordecls.tcl`, `surface/modules.tcl`'s error references,
`surface::parser::ErrorName`), run `tests/namespaced-errors.test`,
`tests/imports.test`, `tests/same-failure.test`,
`audit/error-payloads/tools/fuzz.tcl` (its namespaced programs; once with
`-fault wrong-namespace`), `audit/error-payloads/tools/mutate.tcl` (its
identity mutants) and `audit/same-failure/tools/mutate.tcl`
(`same-short-name-grouped`). A stdlib error moved into its module is spelled
qualified by every user outside it, the audit tools, probes and mutant texts
included.

### Completion precision through untyped callables

The completion analysis never turns lost precision into "no errors"
(STATIC-COMPLETION-PROOFS.md, "Precision and the erased-callable contract"):
an uncontracted call (callee `any` or a bare kind) is charged by its callee's
callable fact (`hir::completions::CallableFact`: exact, contract, clean or
unknown), an unknown one the erased-callable contract, and an incomplete
summary falls back to the callee's declared contract (`EffectiveFacts`,
`Fallback`). Fallbacks are may-sets only (never a KNOWN-ERROR).

Identity precision and contract precision are separate
(VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md): a call through a structural `Fn` or
`Coroutine` type is bounded by its contract whatever callable it holds -- an
exact fact may narrow it, nothing widens it, and the erased-callable contract
never reaches it. That is sound only because every value acquiring a
structural type is checked against it (`hir::completions::Subsume`,
`SubsumeHandle`: what it raises through a callable it captured or receives,
with untyped inputs standing for every value their calls pass, `Possible`).
Never charge a structural call the erased-callable contract again, never
trust a contract a value acquired without that check, and never let an
unknown uncontracted call be charged less than the erased-callable contract
(which includes contravariant erasure: what a structural `Fn`'s argument types
carry into a callable's untyped parameters).

If you change the walker's call, handle or bind cases,
`EffectiveFacts`/`Fallback`/`IndirectFacts`, the callable facts, the
erased-callable contract (`erasedErrorsOf`, `staticsOf`,
`hir::callables::CarriedErrors`), the boundary check (`Subsume`,
`SubsumedRaises`, `SubsumeHandle`, `Possible`) or `hir/affine.tcl`'s error
edges, run `tests/structural-contract-completions.test`,
`tests/higher-order-completions.test`, `tests/error-payloads.test`,
`audit/structural-contracts/tools/fuzz.tcl` (several seeds; once with
`-fault carrier`, `-fault unknown`, `-fault drop`),
`audit/error-payloads/tools/fuzz.tcl -fault unhandled` (the unhandled error on
every path, the untyped `generic` one included),
`audit/structural-contracts/tools/mutate.tcl` and
`audit/error-payloads/tools/mutate.tcl` (its completion mutants: every mutant
in both `mutants.txt` files must still apply and be killed); a change to the
affine error edges also needs the affine and coroutine harnesses above, and
one to the golden suites' layout `tests/golden.test`
(`bench/callback-registry.tcl` measures a registry beside erased callables).

## MutableVector

`MutableVector[T]` (MUTABLE-VECTOR.md) is a growable mutable VALUE: a
runtime *header* (the identity of one logical value, mutated in place) over
a copy-on-write *backing*. A mutation never rebinds anything: its receiver
must be a *place* (a local, parameter or context parameter of the same
function, or a field path from one), checked by `hir::mutvec::verify`
(`MUTABLE-PLACE-RECEIVER`, `MUTABLE-PLACE-CAPTURE`). Value semantics come
from the logical copies `hir::mutvec::Elaborate` writes out
(`mutable_vector#share`: read-outs of a place, entries into one; a
function's own place returned moves its header out instead). Never add a
reference, an alias between places, a rebinding, an assignment, or runtime
ownership state (an owner, a moved bit, an affine flag: `mv-runtime-source`
pins this); the backing's `Rc` count is copy-on-write bookkeeping only.

Affinity is the element's (`hir::types::IsAffine`): an affine vector is
never shared, moves whole, and moves elements only through push/swap in and
pop/take/swap/consuming iteration out; `at` of an affine element is
`AFFINE-ELEMENT-COPY-OUT`; clear, a failed swap and a dying vector release
by the static descriptor (`v`D), first to last.

If you change the vector type, `hir/mutvec.tcl`, the vector cases of
`hir/affine.tcl` (consumers, consuming loops, `LoopDomain`, path releases),
consuming-loop lowering (`hir/lower.tcl`, `core/evaluator.tcl`,
`compiler/compiler.tcl`, `native/lower.tcl`) or either runtime
(`core/mutvec.tcl`, `native/src/runtime/mutvec.rs`), run
`tests/mutable-vector.test`, `audit/mutable-vector/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/mutable-vector/tools/mutate.tcl`
(every mutant in `audit/mutable-vector/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib mutvec`, plus the affine and
coroutine harnesses for any change to `hir/affine.tcl` (above). A change to
native tracing, growth or drops also needs a `BOTLISH_NATIVE_GC_STRESS=1`
run of `tests/mutable-vector.test`. `bench/mutable-vector.tcl` regenerates
the performance report.

## MutableArray

`MutableArray[T]` (MUTABLE-ARRAY.md) is MutableVector's fixed-length
sibling and follows the same model: a VALUE, a header over a copy-on-write
backing (Tcl: a `{mutarray ID}` over the shared Tcl list in
`core::mutarray::store`; native: `MutArrayObj` over an `Rc<[Value]>`), its
mutations made through places (`MUTABLE-PLACE-RECEIVER`,
`MUTABLE-PLACE-CAPTURE`), its logical copies written out by
`hir::mutvec::Elaborate` (`mutable_vector#share`, descriptor `h`; `d`, a
copy of whatever the value is at run time, inside a generic body whose
static type is too imprecise to say). It used to have reference semantics: never
reintroduce an alias between two arrays, a reference, or runtime ownership
state. Like a vector it is covariant (MutableArray[S] <: MutableArray[T]
when S <: T; the raw kind `mutarray` is MutableArray[any]) while a typed
parameter admits exactly its contract (`hir::range::AggregateAdmits`); an
erased array holds a copy, so no erasure check guards it (only the
callable contracts of its elements, `hir::callables::Bearing`).

Affinity is the element's: an affine array moves whole, is never shared,
and moves elements only through swap/set in and swap/consuming iteration
out (there is no take, pop or clear: a fixed-size array has no empty slot);
`at`, `freeze` and a copy's source of an affine element are
`AFFINE-ELEMENT-COPY-OUT`; a failed swap, a displaced `set` element, a
failing factory's earlier results and a dying array release by the static
descriptor (`a`D), first to last. The specialization key keeps an affine
array's element (`hir::specialize::ElementKeyType`): erased, an instance
would see an unrestricted array and drop nothing.

Every collection operation's ownership behavior is registration metadata,
never a name: `-ownership` roles (core/native.tcl: `repeat` for create's
value -- an affine one is `AFFINE-DUPLICATION-UNSUPPORTED` --, `factory`
for generate's, `move`, `place`, `copy-out`, ...), `-drop-form` (the
dropping variant hir/mutvec.tcl retargets an affine operation to),
`-result-length` (hir/cardinality.tcl) and the receiver role
(`hir::mutvec::OpKind`). Do not add a check keyed on a native's name
(`mat-id-4` fences `hir/`, `compiler/` and `surface/`); register a role.
`std::mutable_array::generate(n, f)` calls F once per slot, in index order, under
the callable-contract model (`hir::containers::VerifyFactory`, `-errors-from`).

If you change the array runtime (`core/mutarray.tcl`, the array section of
`native/src/runtime/ops.rs`), its registrations or roles, the array cases of
`hir/types.tcl` (affinity, subtype, lub, narrow), `hir/range.tcl`'s
admission, `hir/containers.tcl`, `hir/mutvec.tcl`, `hir/affine.tcl`'s
`NativeConsumer`, consuming-loop lowering or `hir/specialize.tcl`'s key, run
`tests/mutable-array.test`, `tests/mutable-vector.test`,
`tests/mutable-array-type.test`, `audit/mutable-array/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/mutable-array/tools/mutate.tcl`
(every mutant in `audit/mutable-array/tools/mutants.txt` must still apply
and be killed) and `cargo test --release --manifest-path native/Cargo.toml
--lib mutarray`, plus the vector, affine and coroutine harnesses above for
any change they name. A change to native tracing or drops also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/mutable-array.test`.
`bench/mutable-array.tcl` regenerates the performance report.

## MutableMap, MutableSet and place parameters

`std::mutable_map::MutableMap[K satisfies Hashable, V]` and
`std::mutable_set::MutableSet[T satisfies Hashable]`
(ORDERED-MUTABLE-MAP-SET.md) are ordinary Botlish: opaque parameterized
structs over MutableVectors, sharing the internal engine `std::ordered_table`
(stdlib/ordered_table.bot, `core::native::declareInternalModule`: no program
imports it). Iteration is insertion order; the private keyed hash
(`std::table_hash::of`) decides where an entry lives in the index, never
where it appears. Keep it so:

* No runtime map or set: no native, NIR instruction, runtime object or Tcl
  helper of either collection, and no compiler knowledge of them beyond the
  loop protocol's table (`hir::iteration`'s `iterables`). A new collection
  that needs a language seam gets a general one, with its own tests and
  mutants, never a collection-specific rule.
* Placement uses the keyed table hash only, computed once per operation and
  stored per entry: never the public `hash`, a post-mix of it, an unkeyed
  fast path or a recomputation in a helper. A probe compares a key only at
  an entry whose stored hash is equal; equality decides identity. Nothing
  observable may depend on the hidden key: no API exposes a slot, a stored
  hash, a capacity, the load or the probe order.
* Keys keep their type (MutableVector[K]): a probe of Int or String keys
  lowers to `ieq`/`streq`, a structural key to `veqtotal`, never the
  fallible `veq`. Neither collection is Hashable, and `==` of two refuses
  them at run time naming the opaque values, never their representation
  (core/value.tcl's and ops.rs's opaque-struct cases).
* Replacement keeps a key's position and its stored key; removal leaves a
  dead entry (hash -1) that compaction drops, in order, in place; removal
  then insertion appends. The policy (7/10 load, power-of-two slots of at
  least 8, the garbage rule) is the engine's and may change: never let a
  test of a program's behavior depend on it -- tests/ordered-table.test is
  the one white-box test of the representation.
* The engine's own method calls are written so the kind proofs decide them
  (a qualified call where a lexical name would be a second candidate):
  every program importing the collections compiles their modules.
* A loop over a collection is the loop protocol (hir/iteration.tcl): the
  owner module's `iteration_end`, `iteration_live?` and `iteration_at`,
  `nomethod` and internal to the standard library (INTERNAL-NAMESPACE for a
  program naming one), elaborated after the checks into a counted loop over
  a logical copy (MutableVector's snapshot rule). Never materialize the
  collection for a loop, and never let a lockstep loop iterate one.
* A place parameter (`place m: T`, PLACE-PARAMETERS.md) is the caller's
  place: no entry copy, never moved, read out by copy; its argument is a
  place of the caller, never a temporary, a module binding, an enclosing
  function's binding or a place another argument of the call overlaps.
  Never give it a runtime existence, a reference type, a function-value
  form or an affine type, and never let it implement a trait requirement.
  A call giving a place to a place parameter resizes every vector under it
  for `hir::cardinality`'s MutableVector length proofs (`VectorLength`,
  `ResizedPlaces`, `Mutated`).

If you change the collections or the engine (stdlib/mutable_map.bot,
stdlib/mutable_set.bot, stdlib/ordered_table.bot), the loop protocol
(hir/iteration.tcl, its uses in hir/types.tcl, hir/affine.tcl,
hir/lockstep.tcl, surface/modules.tcl's `CheckInternal`), place parameters
(surface/parser.tcl's `PlaceMarker`, hir/syntax.tcl's `withPlaces`, the
places of hir/resolve.tcl, hir/format.tcl and hir/read.tcl, hir/mutvec.tcl's
place section and its uses in `Elaborate`), the MutableVector index proofs
(hir/cardinality.tcl's `VectorLength`, `ResizedPlaces`, `Mutated`; the
`mutvec` bounds family) or the opaque equality refusals, run
`tests/mutable-map.test`, `tests/mutable-set.test`,
`tests/collection-iteration.test`, `tests/ordered-table.test`,
`tests/place-parameters.test`, `tests/vector-bounds.test`, their golden
suites (`tclsh9.0 tests/local.tcl tests/golden/mutable-map.bot
tests/golden/mutable-set.bot tests/golden/collection-iteration.bot
tests/golden/place-parameters.bot`), `python3 -I
audit/mutable-map/tools/oracle.py selftest`,
`audit/mutable-map/tools/fuzz.tcl` (several seeds; once with `-gc-stress 1`,
once with `-profile large -backends "compile cranelift-generic cranelift"`)
and `audit/mutable-map/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the vector and
array harnesses (above) for a change to hir/mutvec.tcl or hir/cardinality.tcl,
the Hashable and trait-constrained-type harnesses for a change to how keys
are constrained or hashed, and the warning gate (the three modules are
warning-clean). `bench/mutable-map.tcl` regenerates the performance report.

## Fixed binary layouts

A `layout` (BINARY-LAYOUT.md) is a compile-time schema of a fixed number of
bytes -- explicit size, alignment and per-field offsets, scalar fields whose
integer domain is exactly one fixed-width encoding's, nested layouts by value
-- and `LayoutStruct[L]` the immutable struct its imprinting
(`std::binary::parse(L, data)`) produces and its emission (`std::binary::emit(v)`)
consumes. `hir/layouts.tcl`'s registry is the one representation of a
resolved layout: `LayoutStruct[L]` is the named struct `{nstruct
LayoutStruct[L]}`, whose schema `hir/structs.tcl` reads from it, never a
second registration. Never add a layout struct declaration (`LayoutStruct
Foo:`, `layout struct Foo:`) or make a layout a parameterized struct (`struct
Foo[T]:` is an ordinary type constructor, no layout's:
TRAIT-CONSTRAINED-IMPRINTED-TYPES.md), a runtime layout object or value, a layout
read at run time by a compiled backend (the Tcl compiler and native lowering
read the descriptor constant statically: one `binary scan`/`binary format`,
one `binload`/`binstore` per scalar field), structural compatibility between
two layouts, a prefix parse, a cursor, a retained input buffer, an implied
overlay, an alignment rule a resolved layout must satisfy, or a check keyed
on a binary operation's name (register a `-layout` role). A layout knows no
C: a C layer emits resolved layouts.

If you change the layout grammar, `hir/layouts.tcl`, the `LayoutStruct`
cases of `hir/types.tcl` and `hir/resolve.tcl`, the registration order in
`hir/sourcetypes.tcl`, the layout cases of `hir/escape.tcl`, the HIR text of
layouts, the binary operations' registrations (`core/binary.tcl`,
`core/native.tcl`'s `-layout`), the Tcl compiler's `CompileLayoutOperation`,
native lowering's `LayoutCall`/`LayoutDecode`/`LayoutEncode` or the native
ops (`binload`, `binstore`, `byteszeroed`), run `tests/binary-layout.test`,
its golden suite (`tclsh9.0 tests/local.tcl tests/golden/binary-layout.bot`),
`audit/binary-layout/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/binary-layout/tools/mutate.tcl` (every mutant in
`audit/binary-layout/tools/mutants.txt` must still apply and be killed:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule) and `cargo test --release --manifest-path
native/Cargo.toml --lib bin_`. The registry is a declaration registry
(compilation isolation and HIR interchange, above), and a new diagnostic
kind is classified in `tests/static-compile.test`'s census.
`bench/binary-layout.tcl` regenerates the performance report.

## Native layout views

A native view (NATIVE-LAYOUT-VIEWS.md) reads an ordinary `layout` from live
native memory: `std::binary::native::view(L, p)` is `NativeView[L]`, the
address word of the data pointer `p` (observed; `NativeViewNull` for null),
each field read when projected (`v.f`: one load at the layout's offset),
`std::binary::load(v)` the `LayoutStruct[L]` of all of them. One layout, one
registry entry and one descriptor serve both backings; there is no second
description language. Keep it so:

* Never add `extern c struct`, a C layout rule, `repr(C)` or any
  representation guarantee for an ordinary Botlish value (an address, a
  stable offset, pinning): a layout is an explicit external description,
  and a struct stays the compiler's.
* A pointer field (`std::ffi::c::Ptr[T]`, `std::ffi::c::FnPtr[F]`) is native-only:
  read through a view it is the pointer memory holds; bytes never become one
  (`std::binary::parse` and `std::binary::emit` of its layout are
  `LAYOUT-NATIVE-ONLY`). Never let byte storage, an Int or a layout make a
  pointer, and never add pointer arithmetic, `Ptr <-> Int` or a dereference
  outside the view's field reads.
* Views are read-only: no setter, write or writable view; writing is a
  separate capability, `NativeEdit[L]` (next section), never a view's. No
  native allocation or native record.
* `NativeView[L]` is its own nominal type: never a pointer, a LayoutStruct
  or another layout's view; unrestricted, with no equality. A field read is
  elaborated after the checks to `binary#view_field(v, FIELD)` with the
  field's descriptor entry, so no backend reads a layout; its receiver must
  be statically a view (`hir::layouts::verifyInstance`).
* `std::binary::native` is designated direct (`declareDirectNamespace`): making a
  view is a direct edge; declaring layouts, `std::binary::parse` and reading a
  view someone else made are not. Never move directness onto the layout.
* The Tcl backends have no native memory: they refuse a view of a non-null
  pointer (`NATIVE-ONLY`) and never imitate a read.
* `ffi_fixture::memory[T](bytes)` (core/cabi.tcl's `installTestFixture`) is a
  test process's own; nothing else may call it.

If you change any of that (NATIVE-LAYOUT-VIEWS.md, "What to run when
changing this", lists the files), run `tests/native-view.test` (its C oracle,
tests/cffi/nview-fixture.c, needs `cc`), `tests/binary-layout.test`,
`tests/c-abi-types.test`, `tests/direct-modules.test`,
`audit/native-view/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`),
`audit/native-view/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib nview`, plus the binary-layout
harnesses (above) for a change to the layout registry or the descriptor.
`bench/native-view.tcl` regenerates the performance report.

## Native layout writes

The write half (NATIVE-LAYOUT-WRITES.md) has two deliberately different
mechanisms: `std::binary::native::edit(L, p)` is `NativeEdit[L]`, write authority
over live native memory (`std::binary::store(e, L.f, v)`: one store of the field's
width at its offset), and `std::binary::write(d, L.f, v)` /
`std::binary::write_foreign(d, L.p, q)` write one field of a
`std::abi::bytes::MutableBytes` as a new value. A write names its field by a
static designator, `L.f` or a path `L.inner.x`, resolved to a constant with
the leaf's absolute offset and encoding. Keep it so:

* `NativeEdit[L]` is `{nedit L}`: its own nominal type, never a
  `NativeView[L]` with a flag, a subtype of one either way, a pointer, a
  `MutableBytes` or a struct. A view never becomes an edit (no upgrade, no
  conversion); write authority is made from a pointer by
  `std::binary::native::edit`, which is `std::binary::native`'s and so direct; storing
  through an edit someone made, and every byte write, are not.
* Native memory is raw: one layout's integer field and another's pointer
  field can alias an address, so a holder of write authority can pun bits
  into a pointer (`ne-native-memory-is-raw`). That is why making an edit is
  direct: never make it ordinary, and never let byte storage (Botlish
  values) decode into a pointer, which is the law that holds.
* An edit is unrestricted, non-owning authority: never add affinity,
  uniqueness, a borrow rule, pinning, lifetime regions or ownership of the
  memory, and never claim exclusive access. A store is an ordinary store:
  no volatile, atomic or fenced access, never cached or merged (each one a
  runtime call).
* A store or write touches exactly its field's bytes: never the record, its
  padding or a neighbour; a store never copies the record through bytes,
  allocates or reads a `LayoutStruct` (one `nativestore`/`nativestoreptr`
  with constant operands). Scalar encoding is ops.rs's `bin_encode`, shared
  with `binstore`, and checks the range before anything is written.
* The value is held to the field's type statically (`VerifyWriteValue`): a
  scalar proven in its domain, a pointer field exactly its declared
  `Ptr`/`FnPtr` type -- no C conversion, truncation, implicit erasure or Int.
  A pointer stored or encoded is observed, never moved; nothing records a
  dependency on it or keeps it alive (lifetime protocols are a wrapper's).
* `MutableBytes` stays a value: a write returns a fresh storage and never
  writes its operand (MUTABLE-BYTES.md); its size must be exactly the
  layout's (`LayoutLengthMismatch`). Pointers enter bytes only through the
  explicit `std::binary::write_foreign`, into a pointer field: an ordinary
  `std::binary::write` or `std::binary::emit` of one stays `LAYOUT-NATIVE-ONLY`, and
  `std::binary::parse` of a pointer layout stays rejected whatever the bytes hold.
  Never add `Ptr -> Int`, `Ptr -> Bytes` or any decoding of a pointer from
  bytes.
* No native record allocation, `extern c struct`, layout guarantee for an
  ordinary struct, bitfields or `std::ffi::c::Bool` fields here
  (NATIVE-LAYOUT-WRITES.md section 22 records what a generated layout will
  need; fixed arrays are FIXED-LAYOUT-ARRAYS.md's and unions
  LAYOUT-UNIONS.md's, next sections).
* `ffi_fixture::memory_bytes(p, n)` (the oracle of a native write) is a test
  process's own, like `ffi_fixture::memory`.

If you change any of that (NATIVE-LAYOUT-WRITES.md, "What to run when
changing this", lists the files), run `tests/native-edit.test` (its C
oracle, tests/cffi/nedit-fixture.c, needs `cc`), `tests/native-view.test`,
`tests/binary-layout.test`, `tests/c-abi-types.test`,
`tests/c-pointer-borrowing.test`, `tests/direct-modules.test`,
`audit/native-edit/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`,
once with `-backends "interp compile cranelift-generic cranelift"`),
`audit/native-edit/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib nview`, plus the native-view and
binary-layout harnesses for a change to code they share (`bin_encode`,
`ViewBase`, the native types' subtype rule). `bench/native-edit.tcl`
regenerates the performance report.

## Fixed layout arrays

A layout field may be a fixed array, `field NAME: array N of E at OFFSET`
(FIXED-LAYOUT-ARRAYS.md): repetition in an external representation, element
i at the field's offset plus i times E's own width (a scalar's encoding, a
nested layout's size with its tail padding, a row's whole width), E any
representation (a scalar, a C scalar, a pointer, a nested layout, another
array). Its copied value is an ordinary List of exactly N element values;
read through a view or an edit it is a live array, `NativeView[array N of
E]` / `NativeEdit[array N of E]` (std::binary::element, std::binary::store_element,
std::binary::load). Keep it so:

* No new object model: never add a FixedArray type, a runtime array object,
  a slice, an array value distinct from a List, a String conversion of a
  character array, or pointer arithmetic. A layout knows no C: no C
  alignment or padding rule computes a stride or an extent.
* The extent is part of the representation, not of the List's type: a
  whole-array write, store or emit checks every List's length before the
  first byte is written (the declared LayoutExtentMismatch), unless the
  completion analysis proves it (`-bounds {extents V}`: a literal, a
  counted loop, a branch on std::list::length, a copy std::binary::load or
  std::binary::parse made); a proven write has no failure path in native code.
  An element index is checked the same way (`-bounds {index narray ...}`,
  IndexNotFound). Never weaken either to a run-time-only check, and never
  read an extent from a List's type.
* Read and write authority stay distinct inside arrays: an array read
  through a view is a view's (store_element through it is BINARY-OPERAND),
  an element of an array of records is its own view or edit. Pointer
  authority is recursive: bytes never decode into a pointer inside an
  array (parse of a layout holding one is LAYOUT-NATIVE-ONLY), and an
  array of pointers is encoded only by std::binary::write_foreign.
* An element access is O(1): one load or store at the array's address plus
  the index times the stride, never a copy of the array; a copy allocates
  exactly the List (and records) it returns.
* Arrays and unions compose orthogonally (LAYOUT-UNIONS.md, next sections):
  an array of unions strides the union's declared size, a union's
  alternative may be an array; neither knows the other beyond the
  representation it holds.

If you change the array grammar (surface/parser.tcl's `ArrayTypeExpr`, the
static designator indices), hir/layouts.tcl's representations
(`ResolveRepr`, `ReprOfTerm`, `ResolveArrayTerm`, `FieldPath`, the array
problems),
the extent and index proofs (hir/completions.tcl's `ExtentsVerdict`,
`ReprValueVerdict`, `ExactCopy`, the narray bounds; hir/cardinality.tcl's
`extent` result length), core/binary.tcl's array codec, the Tcl compiler's
`LayoutLeaves`, native lowering (`ElementAccess`, `ArrayRead`,
`ArrayCheck`, `ReprWrite`) or the row helpers (native/src/runtime/nview.rs),
run `tests/layout-arrays.test` (its C oracle, tests/cffi/narray-fixture.c,
needs `cc`), its golden suite (`tclsh9.0 tests/local.tcl
tests/golden/layout-arrays.bot`), `tests/binary-layout.test`,
`tests/native-view.test`, `tests/native-edit.test`,
`audit/layout-arrays/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/layout-arrays/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule), the
binary-layout, native-view and native-edit mutation tools (they mutate the
same code) and `cargo test --release --manifest-path native/Cargo.toml --lib
nview`. A change to the generator's arrays (tools/c-bindgen/records.tcl's
`ArrayField`, verify.tcl's array checks, oracle.tcl's array leaves) is a
change to the generator (next sections' checks; regenerate and commit).
`bench/layout-arrays.tcl` regenerates the performance report.

## Union layouts

A `union layout U:` (LAYOUT-UNIONS.md) declares several interpretations of
the same bytes -- `alternative NAME: TYPE`, every one at the union's first
byte, any representation (a scalar, a C scalar, a pointer, a nested layout,
a fixed array, another union), with an explicit `size` and `align` that are
never computed -- held by value in a field, an array element or another
union's alternative. Arrays repeat representation; unions overlap it.
Keep it so:

* A union is no sum type: never add a tag, a case, an active alternative,
  a discriminant, a pattern match, a conversion between alternatives or a
  check of which one was last written. Selecting an alternative is
  interpretation: a native read is one load at the alternative's address
  (`ViewBase` folds the union's offset), never a whole-union load, a copy,
  an allocation or a cached value, and costs the same for the first and the
  sixty-fourth alternative.
* Overlap is declared only by a union: an ordinary layout's fields never
  share a byte (LAYOUT-FIELD-OVERLAP). Never infer a union, accept overlap
  elsewhere, or let a union's size or alignment be computed from its
  alternatives; an alternative wider than its union is an error.
* A union has no copied value: no `LayoutStruct` of a union or of anything
  holding one by value, so `std::binary::parse`, `std::binary::emit`, `std::binary::load`
  and whole-array writes of one are `LAYOUT-UNION` (`std::compiler::DiagnosticCode`
  `LayoutUnion`), statically and, for a program compiled unchecked, when the
  call runs. Bytes are read and written one alternative at a time through a
  static designator (`std::binary::read(data, L.u.alt)`, `std::binary::write`,
  `std::binary::write_foreign`); a designator names an alternative, never the
  union. Never make a copied union a struct of every alternative, a byte
  blob with interpretation methods, or anything else, without a design
  decision recorded in LAYOUT-UNIONS.md ("The copied-value decision").
* A write touches exactly its alternative's bytes: a narrow alternative
  never zeroes or normalizes the rest of the union, nor the bytes around it.
* Pointer authority is recursive through alternatives: bytes never become a
  pointer through any alternative (`std::binary::read` or `std::binary::parse` of a
  pointer path is `LAYOUT-NATIVE-ONLY`); native write authority may store
  scalar bits that a pointer alternative then reads (raw native memory),
  and a pointer stored through an alternative is observed, never moved.
* A union is a declaration registry entry (`hir/layouts.tcl`, `union 1`):
  compilation isolation, HIR text (`union layout ...`) and interchange
  carry it; a same-named record of another compilation is never taken for
  it.

If you change the union grammar (surface/parser.tcl's `LayoutDecl`),
hir/layouts.tcl's union cases (`IsUnion`, `ReprUnionPath`, `UnionRefusal`,
`FieldPath` through unions, the overlap and bounds checks), `std::binary::read`
(core/binary.tcl, core/native.tcl's registration, native/lower.tcl's
`LayoutCall`), the union cases of `ViewBase`, `ReprRead`/`ReprWrite`,
`ViewFieldType`, `hir/completions.tcl`'s `ExactCopy`/`ExtentsVerdict`, or the
HIR text of a union, run `tests/layout-unions.test` (its C oracle,
tests/cffi/nunion-fixture.c, needs `cc`), its golden suite (`tclsh9.0
tests/local.tcl tests/golden/layout-unions.bot`), `tests/layout-arrays.test`,
`tests/binary-layout.test`, `tests/native-view.test`,
`tests/native-edit.test`, `audit/layout-unions/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/layout-unions/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), the layout-arrays, binary-layout, native-view and
native-edit mutation tools (they mutate the same code) and `cargo test
--release --manifest-path native/Cargo.toml --lib nview`. A change to the
generator's unions (tools/c-bindgen/records.tcl's `Synthetic`, `Block`,
`Base`, `Members`; probe.tcl's `anonymous`; verify.tcl's `Fields` and
`anonymous`; oracle.tcl's `Selected`) is a change to the generator (the C
binding generator's checks below; regenerate and commit).
`bench/layout-unions.tcl` regenerates the performance report.

## C ABI types and imprinting

`std::ffi::c` (C-ABI-TYPES.md) is the C ABI value universe: the C integer scalars
`std::ffi::c::Char` ... `std::ffi::c::ULongLong` (integer domains whose ranges are the
compilation's C target's -- `-target`, the host's by default; core/cabi.tcl
is the one target table), `std::ffi::c::Void` (a pointee only), the affine
`std::ffi::c::Ptr[T]` and `std::ffi::c::FnPtr[Fn{...}]`, and `null[T]()`, `null?`,
`clone`, `erase`, `retype[T]`. It calls no C. Keep it a model of C's ABI,
not of C: no width or signedness read from a name (the registry entry's
`cabi` metadata, `core::type::cabiOf`), no C integer promotion, no implicit
pointer conversion or covariance, no integer-to-pointer conversion or
pointer arithmetic, no dereference, no ownership operation on `Ptr`, no
nullable wrapper, no pointer layout field, no runtime pointee descriptor,
and no C compiler in ordinary compilation. A non-null pointer in a test comes
only from `core::cabi::installTestFixture`, which nothing but a test process
calls; never add a public way to make one.

The scalars are per-compilation source types the loader declares for the
target when a file imports std::ffi::c (`hir::cabi::NamespaceTypeDecls`): the
target is a front-end input, in `surface::cache::Key`. Imprinting
(hir/imprint.tcl) is general, not generics: one binding path for Botlish
functions (their declared types) and intrinsics (`-imprint`), variables
established by applied types left to right, explicit imprints all or
nothing in first-occurrence order. Never add declared type parameters
(`fn f[T]`), a constraint written on a function or a variable (the only
constraints are a struct slot's, which a signature's applications carry:
Parameterized structs and constrained slots, above), or specialization
keyed by a variable (the trait monomorphization's specializations per
binding of a source-trait-constrained variable are a trait operation's
witness selection, not imprinting's).

If you change core/cabi.tcl, hir/cabi.tcl, hir/imprint.tcl, the `cptr`,
`cfnptr` or `imprint` cases of hir/types.tcl, how the scalars are declared,
printed or read, the call imprint syntax, or the C address word and its ops
(native/src/runtime/value.rs, ops.rs, show.rs, nir.rs, codegen/clif.rs,
native/lower.tcl), run `tests/c-abi-types.test`,
`audit/c-abi-types/tools/fuzz.tcl` (several seeds) and
`audit/c-abi-types/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), plus the affine
harnesses for a change to affinity and the isolation and interchange audits
for a change to the scalars' declarations. `bench/c-abi-types.tcl`
regenerates the compile-cost table.

## C pointer borrowing (temporary byte exposure)

A foreign call's pointer parameter may admit existing `std::abi::bytes::Bytes` or
`std::abi::bytes::MutableBytes` storage for that one call
(C-POINTER-BORROWING.md): only when its contract (core/native.tcl's
`-foreign`; an `extern c fn` declaration's later) says, for that parameter,
`escape proven-noescape|declared-noescape`, a known `access` (read | write),
and a byte-sized pointee (Char, SChar, UChar by registry metadata, or Void).
`hir/borrow.tcl` decides it and records the transport on the call
(`borrows`); every backend lowers from that field. Keep it so:

* No pointer value of byte storage, ever: no `BorrowedPtr`, no operation
  turning a Bytes into an `std::ffi::c::Ptr`, no internal `cptr` for an exposure
  (`cb-no-pointer-value`, `cb-no-pointer-producing-native`), and no
  FFI-specific byte type (`std::ffi::c::Bytes`, `PinnedBytes`, ...).
* No fact from anything but the contract: `const` (read access) is not
  noescape, an absent fact is `unknown`, and `unknown` never admits
  exposure; never read a fact from a C type, a parameter or function name or
  a namespace. Facts are per parameter.
* A write exposure is a private copy (the detach): MutableBytes stays a
  value, and the written bytes come back as the call's
  `{result: R, NAME: MutableBytes}`. Never expose an owner's own storage
  writable.
* Exposures are made after every argument is evaluated and kept alive by a
  `keepalive` after the operation; the syscall bridges and the foreign call
  share `ExposeStorage`/`KeepExposedAlive` (native/lower.tcl): no other code
  emits an address op or a keepalive. The C side never names the Linux
  syscall ABI and the syscall side never names `std::ffi::c`.
* The borrow fixture (`core::cabi::installBorrowFixture`, `ffi_fixture::`) is
  a test process's own; nothing else may call it.

If you change any of that (the files are C-POINTER-BORROWING.md's "What to
run when changing this" list), run `tests/c-pointer-borrowing.test` and
`tests/c-byte-borrowing.test` (real C: the host compiler's fixture and the
system C library; both also under `BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-pointer-borrowing/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`) and `audit/c-pointer-borrowing/tools/mutate.tcl` (every
mutant in its `mutants.txt` that applies to the host must still apply and be
killed: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule; a `%% macos-aarch64` mutant runs on macOS
only: the tier item `c-borrow-mutants`, MACOS-AARCH64-MILESTONE-7.md), plus
`tests/abi-bytes.test`, `tests/abi-mutable-bytes.test`,
`tests/linux-syscall.test` and the abi-bytes and mutable-bytes mutation tools
for a change to the shared exposure mechanism. `bench/c-pointer-borrowing.tcl`
regenerates the performance table.

## C calls (extern c fn, extern c library)

`extern c fn NAME [named "SYMBOL"](PARAMS) -> TYPE [FACT]` and `extern c
library "NAME"` (C-FFI.md) are a truthful C ABI declaration with no body and
a link-plan entry. A declaration is registered as the compilation-local
root native `extern#KEY` with exactly the foreign call contract a
`-foreign` native has (hir/foreign.tcl), so its calls are typed, admitted,
exposed, judged direct and lowered by the one foreign-call machinery
(hir/borrow.tcl, hir/direct.tcl, native/lower.tcl's `BorrowCall`). Keep it
so:

* Never add a second contract representation, a body, a wrapper or a Tcl-side
  FFI: the Tcl backends refuse a C call (`NATIVE-ONLY`, `core::cabi::
  ExternImpl`). No fact comes from a name, a C type or a header: an absent
  fact is `unknown`, which never admits an exposure and always retains.
* A library is the linker's `-lNAME`, associated with no function; symbols
  are resolved by the system linker at link time, never at run time (no
  `dlopen`, `dlsym` or symbol string on the call path). The native backends
  run a program that calls C as an executable linked with the same plan
  as `-emit-native-executable` (native/src/main.rs's `run_linked`); the stub
  linker refuses one. Ordinary programs link and run exactly as before.
* A pointer result is truthful and its provenance (`independent`, `alias
  P`, unknown) is the contract's; a returned address the C pointer word
  cannot hold fails (`NATIVE ADDRESS`), never truncated. Retaining calls
  (escape captures or unknown) are direct edges of the calling unit; a
  declaration designates nothing.
* The registry is a declaration registry (`hir::foreign::capture`/`Install`):
  compilation isolation and HIR interchange carry it.
* C calls run on Linux x86-64 and AArch64, on macOS AArch64
  (MACOS-AARCH64-MILESTONE-6.md) and on Windows x86-64 with MSVC's
  toolchain (WINDOWS-X86-64-MILESTONE-2.md). The link plan is the platform
  linker's (codegen/aot.rs's `LinkerFlavor`): GNU ld's archive group on
  Linux, byte for byte, the bare `-L`/`-l` list on macOS, whose ld rejects
  the group, link.exe's `/LIBPATH:DIR` and `NAME.lib` on Windows; never a
  GNU-only flag in Apple's or Microsoft's plan, an rpath, an SDK path or a
  decorated (`_`) symbol of ours. The target's C ABI is checked against
  real callees and the C compiler's own calls (c-ffi.test's `cf-abi-*`,
  `bcf_capture`; on Windows fixture-win64.asm's): a change to a foreign
  signature's types or extension attributes needs them on macOS (the
  acceptance tier), Linux AArch64 (tests-arm64.yml) and Windows (the
  Windows workflow), not only here.

If you change any of that (C-FFI.md, "What to run when changing this", lists
the files), run `tests/c-ffi.test` (also under `BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`) and
`audit/c-ffi/tools/mutate.tcl` (every mutant in its `mutants.txt` must still
apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule), plus the borrowing,
direct-module, isolation and interchange harnesses above for a change to
what they cover. The BoringSSL acceptance tests need the package-owned
static BoringSSL: `tclsh9.0 tests/cffi/boringssl.tcl` builds it once into
Botlish's cache (never the repository); without it they are skipped.
`bench/c-ffi.tcl` regenerates the performance report.

## Native libraries (exported c fn)

`exported c fn NAME(PARAMS) -> T` declares a C export
(NATIVE-LIBRARY-MILESTONE-1.md): an ordinary Botlish function to every
backend and to its Botlish callers, which `native::library` (`main.tcl
-emit-native-library NAME`) also gives a C entry point in a static archive,
a shared library, a C header and a JSON manifest. Keep it so:

* An export is a compilation root under its declaration only: its generic
  instance, open (`hir::specialize::ProgramValues` materializes it), never
  an instance its Botlish callers specialized. Never give an export a fact
  of its call sites, never read its C ABI from them, and never disable
  specialization of internal calls because a function is exported.
  Export identity is the resolved block (`hir::exports::of`/`select`),
  never a name searched for in NIR or symbols.
* Exported, public and foreign are three things: a module's functions are
  visible to importers unless `private` (which decides Botlish names only:
  a `private exported c fn` is still a C export), `extern c fn` is a C
  function Botlish calls, `exported c fn` a Botlish function C calls. No
  attribute system, no export of anything but an environment-free
  top-level function whose boundary types are declared (the EXPORT-*
  checks run in every compilation, `hir::exports::verify`).
* The C ABI is C types only: no `Value`, Vm, Rust type or GC pointer
  crosses. An Int result outside `int64_t` is a BOUNDARY error, never
  wrapped; a `str` result is a `malloc`ed copy the caller releases, never a
  pointer into the heap; an error is an owned object whose identity and
  scalar fields are data (the NIR error table), never parsed from its
  message. Nothing unwinds across the boundary (`guarded`).
* A library's every symbol but its public C names is local (`objcopy
  --keep-global-symbols`): each library carries a private runtime, and a
  call makes its own program the thread's current one and restores the
  previous one (`ProgramScope`). Never let two libraries share a symbol,
  a static or the active program, and never fix a collision with a global
  lock or a singleton.
* Instances are explicit (`NAME_create`/`NAME_destroy`), thread-affine,
  one call at a time (WRONG-THREAD, REENTRANT-CALL), looked up by ticket
  (INVALID-INSTANCE). A library installs no signal handler, never `_exit`s
  and runs on its caller's stack: stack overflow is process-fatal there,
  and no document may claim otherwise until a library-owned stack exists.
  The walk of a call's stack ends at the call (`Vm::stack_ceiling`).
* A library's entry file holds declarations only (LIBRARY-TOP-LEVEL):
  creating an instance runs module static initialization, never a script.
* Libraries are Linux glibc's (x86_64, aarch64: `codegen::library::
  SUPPORTED`, `native/native.tcl`'s `libraries`). Never use `ld -r
  --gc-sections` for the archive: GNU ld 2.42 makes the Rust standard
  library's weak references strong there and consumers fail to link.

If you change any of that (NATIVE-LIBRARY-MILESTONE-1.md, "What to run when
changing this", lists the files), run `tests/native-library.test`,
`tests/native-executable.test` and `tests/aot-stub-linker.test` (also under
`BOTLISH_NATIVE_GC_STRESS=1`), `cargo test --release --manifest-path
native/Cargo.toml --lib program` and `audit/native-library/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), plus `audit/native-aot/tools/mutate.tcl` for a change to
the shared startup. `audit/compiler-service/probes/export/run.sh` (the Tcl
extension) and `audit/react-native/tools/host-spike.tcl` (Hermes) are the
foreign-host probes; `audit/react-native/tools/libmode.tcl` is history and
no longer runs.

## C FFI error capture

A C function that fails the POSIX way (a sentinel result, the reason in
errno) is read by its binding right after the call -- a C call of
`__errno_location()`/`__error()` and a native view -- and nothing the
compiler inserts may run in between (C-FFI-ERROR-CAPTURE-MILESTONE-1.md,
C-FFI-ERROR-CAPTURE-MILESTONE-2.md): no allocation, no safepoint that can
collect, no runtime or C call -- whatever the lowering. Keep it so:

* The foreign-result transport is a correctness rule of native lowering,
  never an optimization (native/lower.tcl's "Foreign-result transport"):
  `-struct-opt 0`, `-escape-opt 0`, `-specialize 0`, the legacy width
  policy and `-struct-nesting 0` turn off aggregate optimization, never
  the transport. Never gate `MandatoryWriteBack`, the C words or the
  pending objects on an optimization flag, and never re-create the eager
  representation as an option: the one way to it is the test-only fault
  injection `-fault eager-foreign-result` (BOTLISH_NATIVE_FAULT), the
  detectors' positive control.
* A write-back value `{result: R, NAME: MutableBytes}` is fields
  (`hir::escape::WriteBackResult`, `WriteBackTree`, `WriteBackCut`, the
  write-back cases of `NestingPlan`; and where the analysis does not take
  it, `MandatoryWriteBack`), built only where a use needs an object: a
  MutableBytes read whole (`OpenedFieldObject`), a closed one a pending
  object (`PendingObject`, built by `TaggedField`), the struct where the
  value must be one (`MaterializeVirtual`, a capture's included), a loop
  body's at the loop's entry (`HoistDeferredUses`). Never build one at the
  call, and never open a MutableBytes past a use that runs more often than
  its binding without building it at the loop's entry.
* A 64-bit C integer result is a C word (nir.rs's `i64`/`u64` kinds,
  `cword`, `cwbox`, `cwlt` ...): the word C returned, compared as it is
  (`WordComparison`), boxed at its first use that needs an Int
  (`WordTagged`, after every operand of that use). A word is never an
  argument, a parameter, a result, a capture, a join of two kinds or the
  operand of anything but `cwbox` and the word comparisons (nir.rs's
  validate rejects each); every consumer of field registers takes
  `TaggedFields`. A comparison never allocates: a BigInt operand goes to
  `rt_ffi_word_cmp`, and `rt_int_cmp` and `rt_ffi_int_word` borrow BigInts,
  never copy them.
* `op keepalive` is no machine code: what keeps an exposed storage a root
  is its NIR use (codegen::roots's liveness, the stack maps). Never turn it
  back into a call, and never weaken the NIR keepalive itself.
* The compiler knows no error convention: no errno intrinsic, no automatic
  errno field, no error translation, no annotation, no rule keyed on a C
  function's name. A binding reads its function's error state itself, right
  after the call, in the function that made it (a value returned unread
  leaves the error state to the caller's code); the compiler only adds
  nothing in between.
* Windows' convention is the Win32 one, GetLastError: stdlib/windows.bot's
  `write_file` reads it right after WriteFile the same way
  (`wi-last-error-read-first` pins the window). c-ffi-error-capture.test's
  C tests run POSIX's convention (errno, read, open, close) and need
  `posixErrno`: they skip on Windows, whose C runtime has neither.

If you change the write-back value's representation (the `WriteBackResult`,
`WriteBackTree`, `WriteBackPaths`, `WriteBackCut` and write-back cases of
`NestingPlan` in hir/escape.tcl; `BorrowCall`, `FieldValue`, `FieldOut`,
`OpenedFieldObject`, `OpenedOwnerStorage`, `MandatoryWriteBack`,
`PendingObject`, `TaggedField(s)`, `JoinWordKinds`, `HoistDeferredUses` and
the opened-call case of `StructFields` in native/lower.tcl), the C words
(`AssignWord`, `WordTagged`, `WordComparison`; nir.rs's word kinds and ops;
codegen::clif's `box_word`, `word_compare` and foreign result;
runtime/ffi.rs's `rt_ffi_word_cmp`), the keepalive's codegen, a foreign
call's result conversion or what errno() lowers to, run
`tests/c-ffi-error-capture.test` (its machine-code tests read the object
file with `objdump`; its trace needs Linux and ptrace; its `ec-modes-*`
tests every lowering mode), `tests/c-pointer-borrowing.test`,
`tests/c-byte-borrowing.test`, `tests/windows-io.test`,
`tests/darwin-io.test` (its `di-errno-allocator` runs on macOS: the
acceptance tier of every branch push, and under GC stress a `[ci-full]`
push with `CI-Tests: darwin-io.test c-ffi-error-capture.test`), all also
under `BOTLISH_NATIVE_GC_STRESS=1`, the struct and transport tests
(`tests/struct-scalar-replacement.test`, `tests/value-transport.test`),
`cargo test --release --manifest-path native/Cargo.toml -- c_word
ffi_word_cmp ffi_int_word`,
`audit/c-pointer-borrowing/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule; its
error-capture mutants are killed by tests/c-ffi-error-capture.test, which
it runs) and the `native/lower.tcl` mutants of `audit/c-ffi/tools/mutate.tcl`. `bench/c-ffi-error-capture.tcl`
(`-root DIR` for a baseline checkout; the tier item `c-capture-bench` on
macOS; its `errno` part every shape and lowering; `-instructions 1`
callgrind's instruction counts, which a shared machine does not scatter
as it does times) is the performance report.

## C floating types (std::ffi::c::Float, std::ffi::c::Double)

C `float` and `double` are C representations whose values are Float64s
(C-FLOAT-FFI-MILESTONE-1.md): `{cfloat Float}` (binary32) and `{cfloat
Double}` (binary64), written only where a C type is -- an extern's
parameters and result, a function pointer's signature, a pointee, a layout
field or element -- with `hir::cabi::Carrier` their values' type. Keep it so:

* Never add a Botlish Float32 (or Float80, Float128) to support them, and
  never let `std::ffi::c::Float` name a type of values: there it is a TYPE error;
  `std::ffi::c::Double` there is Float64.
* Every fact is the C type's, never the carrier's: format, size,
  alignment, ABI class, layout width, element stride and the outbound rule
  come from core/cabi.tcl's `floatings`, `floatingModels` and
  `floatingFormats` (a target row's `floating` model). The two types never
  collapse into one, and neither is Float64.
* The boundary is one rule, written once per implementation: Admit (NaN and
  the infinities are NonFiniteFloat with their NonFiniteResult, negative zero
  zero, a binary32 widened exactly) and Narrow (binary32 rounded to nearest,
  ties to even, an overflow NonFiniteFloat before C runs or a byte is
  written -- never clamped, never decimal text -- a zero +0). core/cabi.tcl
  (`Narrow`, `AdmitBits`, the codec) for the Tcl backends and the static
  decisions, runtime/value.rs (`narrow_c_float`, `admit_c_float`) natively,
  codegen::clif's foreign call with the same checks inline. Never add a path
  of its own, a fast-math or flush-to-zero mode, or a different rule at
  compile time (`ExternNarrowing`, `WrittenFloatFormat` call `Narrow`).
* A call is charged NonFiniteFloat only where it can fail through a C
  floating value (`hir::layouts::CallErrors`; an extern with a float
  parameter or a floating result): a float-free program's calls keep exactly
  their errors.
* A DecimalRounded value is never a C float or double: no implicit decay,
  and a C result never acquires a guarantee. `long double` has no type (the
  binding generator reports `long-double`); never map it to Float64.
* A C float takes a floating-point register wherever a convention counts
  them (System V's `%al`, Apple's variadic padding: `vector_registers`,
  `c_call_signature`): count `CAbi::floating()`, never F64 alone. A
  trailing variadic argument is never a float (NIR's `varargs=` rejects
  `f32`).

If you change any of that (the report's section 18 lists the files), run
`tests/c-float-ffi.test` (its fixture needs `cc`), its golden suite
(`tclsh9.0 tests/local.tcl tests/golden/c-float-ffi.bot`), `tests/c-ffi.test`,
`tests/c-abi-types.test`, `tests/float64.test`, the layout test files
(binary-layout, native-view, native-edit, layout-arrays, layout-unions),
`audit/c-float-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`), `audit/c-float-ffi/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule) and
`cargo test --release --manifest-path native/Cargo.toml --lib c_float` and
`--bin botlish-native c_float` (the AArch64 lowering tests run on an AArch64
host, or under qemu-user from an `aarch64-unknown-linux-gnu` build); for the
generator's float and double, its checks (the C binding generator, below).

## Variadics

Variadic parameters and variadic C calls (VARIADICS-VERTICAL-SLICE-1.md) are
two things with one marker word. Keep both as they are:

* **Botlish: `fn f(FIXED..., variadic xs: List[T])`** (or a bare `List`,
  whose element each call imprints) is the last parameter binding (only a
  resume clause follows), at most once. The body sees an ordinary
  immutable List; resolution (`hir/variadic.tcl`'s `Arguments`) collects a
  call's trailing arguments into one ordinary list construction, the
  call's last argument, and records `variadic {fixed N count K}` on it.
  Never add a variadic value, type, runtime representation, spread,
  tuple, heterogeneous sequence or per-position type, never make a bare
  List `List[any]`, and never let a call through a value collect (a value
  has no declaration: it passes the List). Each trailing argument is
  proven in the element type by its own proof (`DiagnoseElements`), never
  the List literal's static type.
* **C: `extern c fn f(FIXED..., variadic) -> R`**, a bare marker after at
  least one fixed parameter (never an `...` token). Each call's trailing
  arguments are held to exactly one C ABI type each
  (`hir::cabi::VariadicArgument`: a C scalar, `std::ffi::c::Bool`, Float64,
  `Ptr`, `FnPtr`; a plain Int, a String, a List, a struct, byte storage or
  an erased value refused), promoted by `core::cabi::promoted` (C's default
  argument promotions, target-relative), recorded on the call (`cvarargs`)
  and lowered to a per-call machine signature (`codegen/clif.rs`'s
  `c_call_signature`): x86-64 System V through the `%al` stub, Linux
  AArch64 as AAPCS64, Apple AArch64 with the free x0-x7/v0-v7 padded so
  every trailing argument is on the stack in an 8-byte slot, Win64
  (x86-64 only) by position through the stub copying the first four
  positions' floats and doubles into their integer registers
  (WINDOWS-X86-64-MILESTONE-6.md). Never build
  a runtime argument list, use libffi, read a format string, infer
  variadicity from a name, a format attribute or a library, give a trailing
  pointer a contract (it is a direct edge, `hir/direct.tcl`), or lower a
  variadic call on a convention the table has not checked (any other is a
  codegen error). A `va_list` is a fixed parameter of a type nothing
  represents; a variadic callback type stays unsupported.

If you change the Botlish side (the grammar's `ParamSections`/
`VariadicEntry`, `hir/variadic.tcl`, the variadic cases of hir/resolve.tcl,
hir/flags.tcl, hir/range.tcl, hir/format.tcl, hir/read.tcl, hir/traits.tcl,
hir/contexts.tcl, hir/warnings.tcl, surface/lower.tcl), run
`tests/variadics.test`, `audit/variadics/tools/fuzz.tcl` (several seeds,
once with `-gc-stress 1`) and `audit/variadics/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule). If you change the C side (ExternDecl's marker,
`VariadicArgument`, `promoted`/`promotedBool`, the variadic cases of
hir/borrow.tcl, hir/direct.tcl, hir/foreign.tcl, native/lower.tcl's
`varargs=`, nir.rs's `VarArg`, `c_call_signature`, `vararg_value`,
`va_stub`, `va_stub_for`, `shadow_positions`), run `tests/c-ffi.test`
(its `cf-va-*`, also under `BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-ffi/tools/fuzz.tcl`, `audit/c-ffi/tools/mutate.tcl -only va-...`
(the `va-*` mutants; the AArch64 ones apply on an AArch64 host, the Win64
ones on an x86-64 host, killed by their Rust tests everywhere and by
c-ffi.test's MSVC captures on Windows: `CI-Tests: c-ffi-mutants=...` in a
`[ci-full]` push), `cargo test --release --manifest-path native/Cargo.toml
--bin botlish-native ffi_` (the `x86_64_variadic_tests` and
`win64_variadic_tests` here -- the latter runs a Win64 call through its
stub in the JIT on any x86-64 host; the Apple and Linux AArch64 placements
on an AArch64 host: CI's arm64 workflow and the macOS smoke job), the
Windows workflow on the branch for a change to Win64's lowering, and the
binding generator's checks for a change to what it emits (next sections).

## C header archaeology (a research instrument)

`audit/c-header/` (C-HEADER-ARCHAEOLOGY.md) preprocesses BoringSSL's and
Tcl's public headers with the installed C toolchain, parses the output into
an exploratory FFI IR and counts what a first C FFI would need. It is
research tooling, not the FFI: nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` may load it, `tests/local.tcl` and CI do not run
it, and ordinary Botlish compilation must never depend on a C preprocessor
or compiler. Its toolchain adapter, declaration parser, IR utilities, macro
records and classifier and preprocessing pipeline are the C header library
`tools/cheader/`, which the binding generator (next section) shares; the
audit's tools load them with `::chdr::use`. Only
`tools/cheader/toolchain.tcl` builds command lines (the `BOTLISH_C_*`
variables). Keep it that way: a new tool asks the adapter, never `exec`s a
compiler itself.

If you change `tools/cheader/` (`cdecl.tcl`, `ir.tcl`, `macros.tcl`,
`macrocat.tcl`, `pipeline.tcl`), `audit/c-header/tools/run.tcl` or the
census, run `tclsh9.0 audit/c-header/tests/parser.test` and
`tests/corpus.test` (no toolchain needed), then `tools/fetch.tcl` once and
`tools/all.tcl`: the oracle must stay at 0 rejected with every planted
check caught, every thunk sample as predicted on gcc and clang. Commit the
regenerated `results/` and `unsupported/` (they are deterministic; only
`timing.txt` changes run to run). A change to `tools/cheader/` is a change
to the generator too: run its checks (next section).

## The C binding generator (a development tool)

`tools/c-bindgen.tcl` (C-BINDGEN.md) generates ordinary Botlish bindings
(`extern c library`, `extern c fn`, opaque pointee types, typed constants)
and C thunks from real C headers, by interrogating the C compiler for the
profile's target: `_Generic` and data-directive probes compiled to
assembly, a symbol probe of `&(NAME)`, clang's `-O2` IR of the shim for
evidence. The committed bindings are `generated/c/PROFILE/TARGET/` and the
fixture's `tools/c-bindgen/fixture/expected/TARGET/`. Keep it so:

* The compiler never loads the generator or `tools/cheader/`, never learns
  that a module was generated, and compiling a generated binding needs no
  header, preprocessor or C compiler. A generated module is an ordinary
  module, never `direct module`.
* Never interpret C in Tcl beyond the archaeology's parser and the macro
  classifier: every type, value and symbol is the compiler's answer. No
  name is special: no API, symbol or prefix spelled in the generator; a
  link symbol is the symbol probe's. A stub-table redirection is never a
  symbol.
* Contracts default to unknown; no fact from a C type (`const` is no
  fact), a name or a namespace; a manual fact is the profile's, emitted as
  declared, a compiler fact `proven`, both with their source in the
  manifest; conflicting sources and stale policy are errors.
* Never approximate: a declaration outside the C ABI universe is
  unsupported with its blocker in the report, never mapped to something
  that compiles. `std::ffi::c::Bool` is the one primitive this milestone added;
  do not add another to make a binding pass.
* Output is deterministic (no time, temporary path, host path, hash or
  directory order), and every committed binding is what generation
  produces: after changing the generator, a profile or a pinned source,
  regenerate (`tools/c-bindgen.tcl generate PROFILE -target T`) and commit
  the diff.
* Record layouts (C-BINDGEN-LAYOUTS.md: `NS/layouts.bot`, `layouts.tsv`,
  `layouts-check.c`) are the target C compiler's answers -- sizeof,
  _Alignof, offsetof and each member's type, probed -- never a layout rule
  computed in Tcl or Botlish: no padding, alignment, packing or bitfield
  rule anywhere in the generator. A field a layout cannot represent (a
  flexible array member, a bitfield, `long double`, `_Bool`, an array of
  one of those) blocks its record and every record holding it by value,
  with its reason in the manifest: never flatten, approximate or
  reinterpret it, and never extend the layout language from the generator.
  A fixed array of representable elements is a layout field (`array N of
  E`, FIXED-LAYOUT-ARRAYS.md) whose extents are the compiler's answers (one
  probe per dimension), never the declaration's expressions. A layout and
  the record's opaque pointee identity stay two declarations; a pointer
  field keeps its pointee's identity.
* A C union is a `union layout` (LAYOUT-UNIONS.md) whose alternatives are
  at the offsets the compiler gives (a member off the union's start is
  `union-member-offset`, never assumed 0); a union of representable
  alternatives is no blocker, and a blocked one is blocked by its
  alternatives' own root reasons. An anonymous member that is no struct
  inside a struct (an anonymous union; an anonymous struct inside a union)
  is a synthetic layout of its own, named by its place
  (`CONTAINER_memberN`), held by a generated field: never flatten it into
  overlapping fields, never promote it, never drop it. Its members are
  probed through the record that names them (C11's promoted names), its
  size, alignment and members' offsets within it are clang's record layout
  (`-fdump-record-layouts`, the toolchain adapter's `recordLayouts`), and
  the two must agree; a synthetic layout whose record is blocked is not
  emitted (`layout-unheld`). The manifest maps every promoted C name to its
  generated path (`promoted` rows); layouts-check.c checks every
  alternative, and a synthetic layout's members through its record, and
  generation compares every synthetic layout's size and alignment with a
  fresh record layout dump.
* A generated layout is its target's and its toolchain's: windows-x86_64-gnu
  is MinGW-w64's (Windows x86-64, the GNU ABI), the Win32 profile's target;
  windows-x86_64 is MSVC's, clang's `x86_64-pc-windows-msvc` with MSVC's
  and the Windows SDK's own headers, which exist only on a Windows host with
  Visual Studio (ICY-TOWER-WINDOWS.md: `CheckCrossHeaders` refuses it
  wherever clang searches no Universal CRT). Never generate, label or check
  one as the other, never let another C library's headers stand in for
  MSVC's, and add no MSVC tool beyond clang's MSVC target and no GNU-vs-MSVC
  comparison. No MSVC binding is committed (no Linux job could check one):
  the Icy Tower Windows build generates SDL3's where it builds the game.

If you change `tools/c-bindgen/`, `tools/cheader/`, a profile or the
fixture, run `tclsh9.0 tests/c-bindgen.test`, `tools/c-bindgen.tcl check
PROFILE -target committed` for every profile (fixture, tcl, tclstubs,
boringssl, sdl3, win32), `audit/c-bindgen/tools/fuzz.tcl` (several seeds),
`audit/c-bindgen/tools/layout-fuzz.tcl` (several seeds, for the host and
with `-target` for each cross target), `audit/c-bindgen/tools/layout-scale.tcl`
for a change to the layout pass (linear in the records) and
`audit/c-bindgen/tools/mutate.tcl` (every mutant in
`audit/c-bindgen/tools/mutants.txt` must still apply and be killed by a test
of behavior or the fuzzer, not only by the pinned comparison: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule). The Tcl, BoringSSL and SDL3 tests need their pinned sources
(`tools/c-bindgen.tcl fetch PROFILE`) and libraries (`tests/cffi/
boringssl.tcl`, `tests/cffi/sdl3.tcl`, the installed libtcl9.0) and are
skipped without them; their `linux-aarch64` generation on an x86-64 host
needs the arm64 cross C library where clang finds it (`gcc-aarch64-linux-gnu`,
which brings `libc6-dev-arm64-cross`; the headers package alone is not
enough, and generation then stops rather than read the host's headers). The
Win32 binding and the fixture's windows-x86_64-gnu target need MinGW-w64's
cross headers and import libraries (`mingw-w64-x86-64-dev`, version 13.0.0:
the profile pins its version macros), `llvm-nm` and, for the second
compiler, `gcc-mingw-w64-x86-64`. The
`c-bindgen` workflow
(`.github/workflows/c-bindgen.yml`) runs all of it, on Ubuntu 26.04 with the
toolchain `.devcontainer/setup-c-toolchain.sh` pins (clang 21.1.8): every
committed binding records the clang that generated it, so regenerate and
check with that toolchain (an Ubuntu 26.04 container or chroot running the
script), never with another clang. macOS bindings of real
libraries need the macOS SDK (`BOTLISH_C_SYSROOT_macos_aarch64`, or a Mac).

## Static intrinsics

`static compile:` (STATIC-COMPILE.md) is a recoverable semantic-compilation
boundary: hir/static.tcl decides each block by ordinary whole-program builds
of the syntax with the block's body in place, reading the diagnostics as
data, and replaces it -- before resolution -- by its body (accepted) or by an
ordinary `fail std::compiler::CompilerError {...}` reifying the diagnostic
(rejected). No HIR expression kind, Core IR form, NIR instruction or runtime
operation knows static intrinsics: never add one, never invoke the compiler at
run time, never serialize the body to text and re-parse it, never catch a Tcl
error or an `internal` diagnostic as a rejection (a compiler failure fails the
compilation), and never give `CompilerError` a case per diagnostic or a default
`Unknown` code. `static` is the introducer of compiler-directed syntax only (no
storage/member meaning), its operations are compiler vocabulary (only
`compile`: no `static parse:`, `static assert_*:`, test framework, syntactic
functions or compile-time evaluation yet), and `compiler::*` is reached only
through `import std::compiler`.

Every error diagnostic kind the front end can report is classified in
`tests/static-compile.test`'s `sc-census-exhaustive`: a kind a block can
produce has exactly one `std::compiler::DiagnosticCode` case (`stdlib/compiler.bot`,
`hir::static::codes`, the Botlish enum spelling of the kind); every other kind
is listed with the reason it never is. Adding a diagnostic kind anywhere in
`hir/` or `surface/modules.tcl` therefore means classifying it there (and, if
recoverable, adding its case to both). A diagnostic with further locations
records them as `related` origins (`hir::Diagnose`'s last argument), never only
in its message text. The tests' and the fuzzer's expectations spell their
`DiagnosticCode` cases themselves (`scPayloadOf`, the fuzzer's `codeCases`):
never derive an expected code from `hir::static::codes` or `CodeOf`.

If you change the static grammar, `hir/static.tcl`, the loader's deferral of a
block's qualified references (`surface/modules.tcl`), how `fail` resolves or
lowers, the completion walk's `fail` case (`intended`), `hir::Diagnose`'s
fields, `hir::BuildFull`, or SAME-FAILURE's fail sites, run
`tests/static-compile.test`, `audit/static-compile/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`) and `audit/static-compile/tools/mutate.tcl`
(every mutant in `audit/static-compile/tools/mutants.txt` must still apply and
be killed: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule). `bench/static-compile.tcl` regenerates the
performance report.

How many builds deciding the blocks takes is the scheduler's business, never
the program's (STATIC-COMPILE.md, "Decision economics";
STATIC-DECISION-ECONOMICS.md): the *sequential* order (one typed rejection per
build) defines every outcome, and the default *batched* scheduler continues
that order on one build for every block whose dependencies
(`hir/staticdeps.tcl`) nothing rejected since has changed. Never make an
outcome depend on the scheduler, never add a source-layout rule or annotation
to make compilation cheaper, and never key a reused method-call decision by
name. A missed cross-function channel shows up as a `mispredicted` build or a
difference from `BOTLISH_STATIC_SCHEDULER=sequential`: add its edge to
`hir/staticdeps.tcl`, not a special case to the scheduler. The sequential
order's waiting rule (STATIC-COMPILE.md, "The waiting rule";
`hir::staticdeps::Waiting`) reads that analysis's waiting channels
(`C:erased`, `C:budget:B`; never the gates `C:verdict` and `C:plan`): a
failing block consuming one waits while a failing block contributes to it,
so a consumer's verdict does not depend on where its contributors are
written. An edge into a waiting channel's part of the graph, or a new link
label the rule must skip, can therefore change an outcome, not only a build
count: check the fuzzer's layout claim on several seeds (17 and 41 among
them). If you change the
schedulers, the dependency analysis, the method-call seeds or build reuse
(`hir/hir.tcl`), or add a fact an analysis reads across functions (a summary,
an inferred contract, the erased-callable contract, an instance budget, a
yield type, a diagnostic suppressed by reachability or by a whole-program
verdict such as the ownership analysis's, which withholds release scopes and
`AFFINE-PATH-RELEASE-UNSUPPORTED` from a program it rejects, or the trait
plan's gate, which reports its diagnostics only for a program with no other;
or a diagnostic that prints an internal id in a new form -- `hir::static::
InternalIds` knows `block(eN)` and `function eN` only -- or a binding's, a
reference's or a function's `name`, which hygiene may have renamed `NAME#N`
with a number counted over the whole program: never print `name`, print
`hir::semantic::SourceName` for a binding, `RefName` for a `ref` or `bind`
node and `CallableName` (or `hir::signatures::Name`) for a function, and pin
the message with an `se-equal-hygiene-*` reproducer; or move a check across
the completion walk in `hir::CheckOnce`, or make a diagnostic depend on
another's presence: a site's contract-boundary edges read
`beforeCompletions`, since a first diagnostic reported before that walk is no
contract-boundary report and stays first whatever the program erases), run
`tests/static-economics.test`, `tests/static-compile.test`, `tests/golden.test`
(`golden-static-economics`), `audit/static-decisions/tools/fuzz.tcl` (several
seeds) and `audit/static-decisions/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed, the economic ones -- a build too
many -- as much as the semantic ones), and check the golden suites' batched
against sequential comparison in CI (next section). `bench/static-decisions.tcl`
regenerates the economics report.

### The sequential comparison runs in CI, never locally

`audit/static-decisions/tools/compare.tcl` compiles each golden suite under
the batched scheduler and the sequential reference and requires them to
agree. The sequential order is one whole-program build per typed rejection:
mutable-array.bot takes 69 rounds and 205 builds, destructuring.bot 69 rounds
(953 and 205 builds before METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md). On a
GitHub runner that is 24 and 9 minutes; in an agent's container it is several
times slower (under the old method-call decision mutable-array.bot did not
finish in 2 h 37 min), close to the 2-hour background-task limit, and it
starves everything else on the machine. So:

* **Never run it locally.** Don't run `compare.tcl` on a golden suite, all
  of them or one, and don't compile one under
  `BOTLISH_STATIC_SCHEDULER=sequential`. A small program of your own (a
  reproducer of a disagreement CI found) is fine.
* **The `static-decisions` workflow runs it**
  (`.github/workflows/static-decisions.yml`), one job for mutable-array.bot
  and the other suites in four shards:
  - automatically on every push to main that changes `core/`, `hir/`,
    `surface/`, `stdlib/`, a golden suite or `audit/static-decisions/tools/`,
    which covers every change the list above names;
  - on demand, on any branch, when you judge your change likely to move a
    decision (the schedulers, the dependency analysis, a new cross-function
    fact) and want the verdict before main has it: push the branch, then
    dispatch the workflow on it (`workflow_dispatch` of
    `static-decisions.yml` with your branch as the ref: the GitHub MCP
    server's `actions_run_trigger`, method `run_workflow`, or `gh workflow
    run static-decisions.yml --ref BRANCH`). The optional `suites` input (file
    names, separated by spaces or commas) narrows it.
* **Read its result.** A run takes about 30 minutes, mutable-array.bot's job
  (the shards finish within it), and on main it may first wait for the run
  before it. Don't wait idle for it: carry on, and before you call the change
  done read the run's jobs. Each job's summary lists every suite's rounds and
  builds under both schedulers, and any `DISAGREE` or `DOES NOT COMPILE`. If
  the run has not finished, report it as pending, never as passed.
* **A failing run on main is a standing signal**, like a failing `gc-stress`
  run: reproduce the disagreement on a small program and fix it.

## Method-call decisions

`hir::DecideMethodCalls` (`hir/methods.tcl`;
METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md) decides which function a
method-style call means by the rule of METHOD-SUGAR.md: the one visible
candidate whose ordinary call is valid. Keep it so:

* **A candidate is judged by the call's own checks.** A diagnostic carries a
  `subject` -- the call -- only when the call's own check against its callee
  reported it: code inside `hir::CheckingCall $e {...}` (hir/hir.tcl;
  `hir::Diagnose` adds it). A call's problems are the diagnostics whose
  subject it is (minus the obligation kinds, `ObligationKinds`) and a
  native's kind mismatch (`NativeMismatch`). A new check of a call's
  arguments, flags, imprint, instance or context requirements against its
  callee goes inside `CheckingCall`; a check of a value by the construct
  that uses it (an outer call's parameter is the *outer* call's, an
  operator, a declared result or binding type, a capture) never does. Never judge a candidate by where a
  diagnostic is located, by a subtree, by comparing messages, or by what
  every candidate "shares".
* **Relative to the decided program.** A candidate is applicable when the
  call has no problem of its own in the build of the decided configuration
  with only that call moved to it (the decided build for the candidate the
  call stands at, a single deviation for any other), or when a kind proof
  rules it out (next item). The decision is the configuration in which
  every call has exactly the candidate it stands at applicable; a call with
  several is AMBIGUOUS-METHOD-CALL, with none NO-APPLICABLE-METHOD, and a
  call that is still moving at the certification's bound is ambiguous. The
  search (the kind waves, the trial rounds) only proposes stand-ins: never
  decide a call from a stand-in, a trial round, candidate order, a guess or
  an unrelated call's outcome, and never add a precedence.
* **Kind proofs exclude, never accept** (METHOD-DECISION-FILTER.md). A
  candidate is excluded only when the receiver the build gives makes the
  ordinary call invalid by kind (a native's first parameter, a module
  function's declared or inferred first-parameter contract, the plain value
  kinds only) or by a named struct's declaration (a *declared* first
  parameter of another named struct declaration than the receiver's:
  `NominalMismatch`). Never exclude a lexical name, by a domain or a
  refinement, by a struct's type arguments, by an inferred contract's struct
  or by a type's spelling. The native rule is stated once
  (`NativeMismatch`, which a call's problems and the kind proofs both ask).
  Certification never reads a waves' guess (`DefinedType`).
* **Checked, not trusted.** `hir::methodKindProofs 0`
  (`BOTLISH_METHOD_KIND_PROOFS=0`) is the reference rule: every candidate
  judged by its own build. `hir::methodReferenceAudit 1`
  (`BOTLISH_METHOD_REFERENCE_AUDIT=1`) decides by both and fails unless the
  decisions and the HIR are identical; `hir::methodBuildAudit 1` rebuilds
  every reused build. None is a front-end input (no cache key, no new
  interchange rule). Builds are counted as `methodTrials`
  (`methodDeviations` among them), `methodFinals` and `methodReused`.
* The seeds across static rounds (`hir::static::MethodSeeds`) fix a call's
  decision as made; a seeded call is not certified again.
* **Obligations never select** (SFIAE, LANGUAGE-DESIGN-PRINCIPLES.md;
  SFIAE-MILESTONE-1.md). What a selected function needs of the environment
  it is called in -- an error handled, a context installed (MISSING-CONTEXT),
  exactly one installed implementation of a required context trait
  (AMBIGUOUS-CONTEXT-IMPLEMENTATION), mediated authority (DIRECT) -- is an
  obligation of the call, one of `hir::methods::ObligationKinds`, never a
  candidate's problem: never take a kind out of that list or count context
  availability against a candidate. A new diagnostic of that nature joins
  the list; a feature that would choose another operation because one fails
  an obligation is a language-design decision, never an implementation
  detail.

If you change `hir/methods.tcl`, `hir::DecideMethodCalls`,
`hir::CheckingCall` or any check that uses it, `hir::Diagnose`'s fields,
`hir::resolve::MethodCandidates`, the contracts `hir/signatures.tcl` records
on a first parameter, `hir::types::kindOf`, or when a struct type is a
subtype of a named one (`hir::types::subtype`), run
`tests/method-resolution.test`, `tests/method-filter.test`,
`tests/static-economics.test`, `tests/static-compile.test`,
`tests/method-sugar.test`, `audit/method-resolution/tools/oracle.tcl` (the
independent oracle; 200 seeds, and 200 with `-contexts 1`),
`audit/method-filter/tools/fuzz.tcl`
(several seeds), `audit/method-resolution/tools/mutate.tcl` and
`audit/method-filter/tools/mutate.tcl` (every mutant in each must still
apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule), and the golden suites that
decide method calls under the reference audit (`bench/method-filter.tcl
-suites SUITES -audit 1`; mutable-array.bot takes long by the reference
rule). A new test file's tests get census rows
(`audit/golden/migration/census/`).

## Declared recognizers (dfa and class)

`class NAME = ITEMS` and `dfa NAME over bytes|ascii|unicode:`
(DFA-COROUTINE-MILESTONE-2.md) declare finite-state recognizers in an
ordinary module that imports `std::dfa`. surface/dfa.tcl checks each
declaration where it is written (the loader calls `expand` once a file's
imports are loaded) and lowers a recognizer before HIR to ordinary
coroutine functions -- `NAME`, constructed with the token's first symbol,
resumed with `std::dfa::Symbol`, yielding 0 and completing with how many
symbols it left unread, and `NAME#run` -- whose transitions are one call of
the internal root native `dfa#transition(state, c, TABLE)` over a constant
table (core/dfa.tcl; natively a byte table, a NIR `switch` or nested
comparisons: native/lower.tcl's `DfaTransition`). Keep it so:

* No DFA runtime, scheduler, ownership model, coroutine operation or HIR
  or Core IR node: a recognizer is its generated functions, failing
  `std::dfa::UnrecognizedInput {recognizer, state, symbol}` and
  `std::dfa::UnexpectedEnd {recognizer, state}`. Never add `=>`
  (non-consuming moves), actions, priorities, longest match, backtracking,
  regex syntax or an explicit rejection of an ordinary symbol.
* `accept before N` is bounded statically (`Bounds`, `CallLookahead`): on a
  symbol N is at most the fewest symbols any path to the state consumed,
  at the end less than that (or 0); `call D then STATE` takes only a callee
  that leaves at most the current symbol. A recognizer keeps no input: the
  driver gives back what a token left unread from a buffer of the
  recognizers' static lookahead (examples/dfa). Never let a recognizer hand
  back a symbol before its first, or store symbols.
* A declaration's diagnostics are reported at the declaration (a HIR hole
  carrying its report, hir/resolve.tcl's `ResolveHole`) and taint its unit:
  never a diagnostic from generated code, never a cascade. Every kind is
  classified in tests/static-compile.test's census and has a Compilerpedia
  topic (compilerpedia/topics/dfa.topic) with a rejected example.
* Generated names hold a `#` (no source spells them) and are `nomethod`;
  String constants the lowering writes are `synthesized` (no
  ONE-CHAR-STRING-LITERAL). The compiler service's facts of a
  declaration's names are the checker's (surface/dfa.tcl's `Fact`, the
  HIR's `dfaNames`), never a resolution of the service's own.
* The table is the transitions' one representation after checking: the
  Tcl backends look it up (`core::dfa::Lookup`), native lowering expands it
  at compile time; `switch` and `rtabload8/16` are general NIR, never a
  DFA-only opcode. `dfa#transition`'s `-result-range nonneg` is what lets
  the range analysis prove a state and native lowering drop its check.
* `surface::dfa::lowering` (compact | tree) is a front-end input
  (`surface::cache::Key`); `-dfa-dispatch` / BOTLISH_NATIVE_DFA_DISPATCH a
  backend option. The exploration's preprocessor is retired: never add a
  second DFA compiler (audit/dfa keeps its results as history).

If you change the grammar (surface/parser.tcl's `ClassDecl`, `DfaDecl`,
`DfaItems`, `DfaTransition`), surface/dfa.tcl, core/dfa.tcl, stdlib/dfa.bot,
native/lower.tcl's `DfaTransition`/`DfaTable`/`DfaSearch`/`DfaRawIn`, NIR
`switch` or `rtabload` (native/src/nir.rs, codegen/clif.rs), the service's
`DfaNameIndex`, or examples/dfa, run `tests/dfa.test`,
`tests/dfa-workloads.test`, `tests/static-compile.test`,
`tests/compilerpedia.test`, `cargo test --release --manifest-path
native/Cargo.toml --bin botlish-native switch_tests`,
`audit/dfa/tools/differential.tcl -suite DIR -fuzz 2000 -seeds 1-12`
(JSONTestSuite's test_parsing in DIR; 0 disagreements) and
`audit/dfa/tools/mistakes.tcl` (every structural and lookahead mistake
static, the grammar ones caught or recorded as surviving). The warning
gate's corpus leaves examples/dfa out: tests/dfa-workloads.test's
`dfa-workloads-warning-clean` compiles its modules under `-warnings error`
instead (answer a warning in the code, as the gate asks). `bench/dfa.tcl`
regenerates the
performance report and `audit/dfa/tools/evidence.tcl` the native evidence.

## Workloads (examples/games/2048)

`examples/games/2048/` is the first workload of the post-golden stress-test
series (2048-ENGINE-WORKLOAD.md): a 2048 engine as an ordinary module
(`game2048.bot`), its demo, its golden suite and its benchmark program. The
engine is not standard library and must not move into `stdlib/` (it would ship
in the single executable): it is an application module, the file beside its
programs, which every entry point compiles as they are (`tclsh9.0 main.tcl
-backend cranelift examples/games/2048/demo.bot`; `examples/games/2048/run.tcl`
adds `-suite`, `-hirx OUT FILE.bot` and `-backend B FILE.bot`).
The demo is the application module `demo_play.bot` (the game's presentation
and play loop, requiring `std::io::IO`) and one entry per platform, `demo.bot`
(Linux, `std::linux::io`) and `demo-darwin.bot` (macOS, `std::darwin::io`): keep
everything but the context's installation in demo_play.bot
(MACOS-AARCH64-MILESTONE-8.md, section 22).
`tests/workload-2048.test` runs the suite, the warning check, the benchmark
checksum, the demo executable (also under GC stress), the demo under
main.tcl's native backends and, on macOS, the Darwin demo's executable in
the ordinary suite; `bench/2048.tcl` is the
performance report. If you change the engine or the suite, also run
`audit/2048/mutate.tcl` (every mutant in `audit/2048/mutants.txt` must
still apply and be killed; each mutant is a private application directory,
the suite beside the mutated engine) and `audit/golden/tools/perturb.tcl
examples/games/2048/golden.bot` (it copies a suite's application modules, the
engine, beside every perturbed copy). The workload's golden suite is not in `tests/golden/`: its tests port
no Tcl test, so they have no manifest rows. The workload keeps its
workarounds for what Botlish lacks (no Int-to-String, division, fold, typed
empty vector, List length facts, ...): they are its evidence
(POST-2048-PRODUCT-FIXES.md); do not rewrite them with a new convenience.

## Workloads (examples/games/icy-tower)

`examples/games/icy-tower/` is the real-time workload (ICY-TOWER-VERTICAL-
SLICE-1.md): a playable Icy Tower-style game on Linux x86-64 and Windows
x86-64 (ICY-TOWER-WINDOWS.md) over the generated SDL3 binding. Keep its
layering:

* `tower.bot` (the rules: a frame is `step(world, input, dt)`), `hud.bot`
  (text) and `options.bot` (the command line) are pure: no SDL, no clock,
  no input device. They run, and `golden.bot` and `headless.bot` test them,
  on every backend. Never import SDL or `sdl` into them.
* `game.bot` is the program (the frame loop, play, failure reports,
  `main`), one source for every platform; an entry program only installs
  the contexts -- `main.bot` std::linux::io's, `main-windows.bot`
  std::windows::io's, both `sdl::create()` -- and runs `game::main`. Keep
  everything else out of the entries, and every platform name out of the
  other modules.
* `sdl.bot` is the one module with raw authority: every function of it
  that makes a retaining C call or a native view or edit requires its own
  `Sdl` context, so `render.bot`, `game.bot` and the entries stay ordinary modules
  (`workload-icy-tower-sdl-modules-warning-clean` checks
  `hir::direct::summary`). Do not mark a game module `direct module`.
* SDL's objects stay behind that context (ICY-TOWER-CONTEXT-REFACTOR-
  CENSUS.md): the installed `Sdl` owns the open session -- the window,
  the renderer and the scratch memory as affine pointers in a private
  Session it keeps in its vector (CONTEXT-OWNED-AFFINE-STATE-
  MILESTONE-1.md: no native-memory record holds them) -- and `render.bot`
  and `game.bot` call operations that take and return values only. The
  opaque `Sdl` itself is the one affine value outside `sdl.bot`: the entry
  programs install it. Never give a function outside `sdl.bot` a C pointer,
  a native view or edit, or a struct holding one, never call SDL from
  another module, and never add a public `sdl.bot` function that returns
  the session's view or a pointer (anything a public function returns,
  every importer gets). A struct of `sdl.bot` that holds a pointer, a view
  or an edit is opaque (an importer reads a view it holds without any
  authority). `workload-icy-tower-sdl-airlock` and
  `workload-icy-tower-sdl-records-opaque` check it.
* Inside `sdl.bot`, every function whose parameter or result is a C
  pointer, a native view or edit (or holds one, an opaque struct
  excepted), every layout of native memory and the session record are
  `private` (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md): helpers may
  take and return pointers and views, and no importer can call them. Each
  operation is a public wrapper and a private `session_*` function that
  reaches the session's pointers where the context stores them
  (`sdl.open.element(0)`); never copy a session pointer out of the context
  to share it (a helper that needs one declares the context, or takes an
  explicit clone). Keep a new pointer-taking helper private; never make one
  public to call it from another module (CONTEXT-RESOURCE-ESCAPE reports
  that). `workload-icy-tower-sdl-helpers-private` and
  `workload-icy-tower-no-resource-escape` check it, and
  `workload-icy-tower-baseline-warnings` pins the twelve warnings the
  original boundary (audit/icy-tower/context-refactor/baseline/) draws.
* The SDL binding is the committed generated one (generated/c/sdl3/), staged
  beside the game by `build.sh` (tools/c-bindgen.tcl stage); on Windows,
  `build-windows.sh` generates the windows-x86_64 (MSVC) binding from the
  same pinned headers on the Windows host and stages it the same way (none
  is committed: C binding generator, above). Never copy a binding into the
  example directory or hand-write a parallel SDL declaration.
* The game makes no variadic C call (it was written while Windows' native
  backend refused them; WINDOWS-X86-64-MILESTONE-6.md lowers them now, and
  the design stays). SDL's error text is copied out of SDL (`SDL_strlcpy`
  into the session's text buffer, read through its layout) and reported by
  `game.bot` through `std::io`, never by `SDL_Log`. An SDL enumeration
  constant's C type is the target's (`unsigned int` on Linux, `int` with
  MSVC): never write a game type that holds one as one C scalar.
* `build.sh` builds the stripped executable at
  `audit/icy-tower/artifacts/icy-tower`, which is committed: rebuild and
  commit it in the same change as anything it is built from.
* `audit/icy-tower/oracle.py` is an independent implementation of the
  rules, written from the report's rules section: a rule change changes
  the report, the oracle and the golden suite's expectations together.

If you change the game, `stdlib/float64.bot` or what it relies on, run
`tests/workload-icy-tower.test` (its executable tests need the
package-owned libSDL3.so, `tclsh9.0 tests/cffi/sdl3.tcl`, and are skipped
without it), `audit/icy-tower/mutate.tcl` (every mutant in
`audit/icy-tower/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule) and `python3 audit/icy-tower/oracle.py compare EXECUTABLE`;
for a change to `sdl.bot`, `render.bot`, `game.bot` or an entry, also compare the SDL
call trace of the old and new executables
(`audit/icy-tower/context-refactor/tools/trace-compare.sh OLD NEW`: every
draw, poll and release with its arguments must be the same);
`audit/icy-tower/tools/xvfb-session.py` plays the executable in a real X11
window (an SDL3 built with the x11 driver: build.sh says how) and
`audit/icy-tower/tools/perf.tcl` is the performance report. CI's
`icy-tower` workflow (`.github/workflows/icy-tower.yml`) runs all of it.
The Windows executable (`build-windows.sh`, the Windows section of
tests/workload-icy-tower.test, which needs SDL3.dll built by
`tests/cffi/sdl3.tcl` on Windows) is built and tested only by the
`icy-tower (windows x86-64)` workflow (`.github/workflows/icy-tower-windows.yml`,
every push to any branch), which also publishes main's build as the
`icy-tower-windows-latest` release the README's Windows button links to:
run it on the branch for any change to the game, `tests/cffi/sdl3.tcl`,
the generator's MSVC target or `tools/cheader/`.
Its signing (ICY-TOWER-WINDOWS.md, "Signing") is the `sign` job's alone:
only that job, on main or a manual run, in the `windows-signing`
environment, sees signing credentials -- never give them to the build job,
a pull request or another workflow, never store a signing key or password
in GitHub (Azure Artifact Signing through OpenID Connect), and never let the
release publish an unsigned build while `WINDOWS_SIGNING` is set. Every
build's signing dry run must keep passing: the executable must run with a
signature appended.

## Application modules, native program output, the recursion limit

Three product rules (POST-2048-PRODUCT-FIXES.md):

* **Application modules** (IMPORTS.md, "Application modules";
  `surface::modules::ResolveModule`). A program file's application root is
  the directory of its entry file; an import an application file writes of a
  namespace outside `std` is `ROOT/NAME.bot`, and nothing else (the standard
  library is `std::NAME`: next section). Never make resolution read the
  working directory, an environment variable, a parent directory or a path
  list, never let a standard-library module's imports see the application,
  and never prefer one candidate silently. The root is a front-end input: it
  is in `surface::cache::Key` and each import's application path in
  `Dependencies`. If you change resolution, run
  `tests/application-modules.test`, `tests/std-namespace.test`,
  `tests/imports.test`, `tests/surface-modules.test`, `tests/hir-cache.test`
  and `audit/hir-interchange/tools/mutate.tcl`.
* **Native program output.** main.tcl runs native programs with
  `native::evalHir ... -output inherit`: the program writes to main.tcl's own
  standard output and error, and `botlish-native --result PATH` carries the
  result lines (the overflow guard's report included:
  `runtime::platform::set_result_file`). Never route a program's output through a
  pipe of main.tcl, buffer it, or parse it for results. Everything else
  (`native::evalHir` with no `-output`, `native::Driver`) drops it, so tests
  stay quiet. `tests/native-program-output.test` pins the bytes and the order.
* **The recursion limit.** Entry points that run programs on the Tcl backends
  (main.tcl, `tests/golden/run.tcl`) call `core::useProgramRecursionLimit`
  (core/core.tcl); never give one a number of its own. `core::evalProgram`
  and the compiler raise nothing themselves (tests/compiler-opt.test's
  opt-tail-2 checks a compiled tail call under 1000). `tests/main-recursion.test`.

## The standard library: the namespace std

Every public standard-library namespace is under the compiler-owned root
`std` (STD-NAMESPACE.md): `std::list`, `std::str`, `std::abi::x86_64`,
`std::linux::io`, `std::ffi::c`, `std::test`, `std::compiler`, ... Their
source is `stdlib/`, the directory of the namespace std
(`$::core::libraryDir`, beside `core/`: the checkout's or the single
executable's), and every qualified intrinsic is registered under its
canonical `std::` name (`std::list::at`). Keep it so:

* One canonical identity per symbol: never add a flat alias (`list::at`), a
  prelude, an implicit import or a second registration of an intrinsic. A
  new public intrinsic or module goes under `std::`; internal `#` natives
  (`mutable_vector#consume`) are no namespace's and stay as they are.
* A path's first segment decides its origin (std's directory or the
  application root): never search, never fall back from one to the other (a
  missing application `list` is UNKNOWN-NAMESPACE with a hint, never
  `std::list`), never let an application file be a standard namespace
  (RESERVED-NAMESPACE), and never read the standard library's location from
  the working directory, the application or the environment.
  `$::core::libraryDir` is the one override, for tests (`withPrivateLibrary`):
  a module a test writes there is `std::NAME`.
* A leading `::` roots a path (`::std::list::at`) and is never part of an
  identity: the parser keeps types and error names canonical and records
  `rooted` on imports, qualified values and constructions only, which the
  loader alone reads (a rooted qualifier is never a type of the file).
* Never decide anything by a namespace's spelling: a native's collection,
  platform, layout role or receiver is its registration's
  (`hir::mutvec::CollectionOf`, `core::cabi::platformOf`'s whole-path
  roots), never `string match mutable_array*` or a first segment.
* Compilerpedia documents what the registry and `stdlib/` hold
  (`tools/compilerpedia.tcl generate`, recursive over `stdlib/`).
  `audit/stdlib-census/tools/census.tcl` is the inventory: regenerate
  `audit/stdlib-census/after.tsv` when the public surface changes.

If you change the namespace model (`surface/modules.tcl`'s resolution,
`surface/parser.tcl`'s rooted paths, `stdlib/`'s location), run
`tests/std-namespace.test`, `tests/imports.test`,
`tests/application-modules.test`, `tests/surface-modules.test`,
`tests/stdlib-namespaces.test`, `tests/hir-cache.test`,
`audit/imports/tools/fuzz.tcl` (several seeds) and
`audit/hir-interchange/tools/mutate.tcl`; a change to the single
executable's packing also `single/smoke-test.sh` after `single/build.sh`.

## Diagnostic recovery

A rejected compilation reports every independent diagnostic it finds and
nothing that only restates an earlier one (DIAGNOSTIC-RECOVERY.md): the
strict boundaries (`surface::lower::Finish`, `hir::BuildSyntax`,
`surface::parse` without `-recover`, the loader's `RaiseReferenceErrors`)
raise them as one error through `core::raiseDiagnostics` (the first one's
code and text, a line per further one, the list as `-diagnostics`), in the
build's order. Keep it so:

* Never suppress a diagnostic by comparing message text, and never merge
  two at distinct written sites (two uses of one missing import are two:
  merging them made one static compile block's diagnostic depend on
  another's, a scheduler disagreement). A dependency is semantic: poison, a
  resolution failure's taint (`hir/recovery.tcl`), a construct the parser
  skipped (`surface::parser::Independent`), one written construct the front
  end expanded.
* A value an analysis proved invalid in every context is poison
  (hir/types.tcl, "Poison"), never `any`: a new check of that kind makes its
  expression poison, and a composite that propagates a child's `never` asks
  `hir::types::Halts`, never `eq never`, for divergence. Poison exists only
  where its diagnostic does (reachable code of a source program), never in a
  valid program's HIR, and no backend compiles it: a lenient HIR runs with
  its diagnostics, so a new backend entry point compiles
  `hir::recovery::runnable` of its HIR (checked again without poison). A
  check that holds a value to a declared boundary skips a poisoned one.
* The source frontend checks a program whose resolution failed. A new way
  for one top-level unit to depend on another, beyond referring to a binding
  it declares, goes into `hir::recovery::Tainted`.
* A rejected `static compile:` block's CompilerError stays its first
  diagnostic: only that one is scheduler-independent.
* A strict front end's message for one diagnostic is exactly what it always
  was; a test that pins one diagnostic of a program that has several reads
  the first entry of `-diagnostics`, never the first line of the message (a
  message may span lines).

If you change poison, the missing-import diagnosis of method syntax
(`hir::structs::ProjectionProblem`, `UnimportedCandidates`), a call's
grouped unhandled set (`hir::completions::Unhandled`), `hir/recovery.tcl`,
the strict boundaries, the loader's accumulation or the parser's and the
lexer's recovery, run `tests/diagnostic-recovery.test`,
`audit/diagnostic-recovery/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule) and
`audit/diagnostic-recovery/tools/efficiency.tcl` (the corpus: every known
primary in the first compilation, no cascade, every case clean once fixed).

## The compiler service and the source seam

`service/service.tcl` (COMPILER-SERVICE-MILESTONE-1.md) is the compiler's
analysis as one in-process Tcl interface: workspaces with unsaved documents,
immutable analysis revisions, their diagnostics, position queries and
Compilerpedia topics; `main.tcl -check` is its command-line client. It has
no semantics of its own. Keep it so:

* Program source enters the front end only through `surface::source`
  (surface/source.tcl): `exists` and `text`, answered by the provider in
  force (the disk unless a caller runs a compilation in a snapshot of an
  overlay) and recorded per compilation. Never read a program's or a
  module's path with `core::ReadFile`, `open`, `file exists` or `file isfile`
  in the front end; a new place that acquires source goes through the seam.
  Never substitute sources by wrapping or renaming a command (`file`,
  `core::ReadFile`, a compiler procedure): it is not a seam, and renaming a
  compiled command makes the next build recompile the compiler
  (COMPILER-SERVICE-CENSUS.md, "A measurement artifact").
* Line endings are normalized once, by `surface::source::normalize` at the
  seam, for files and buffers alike: never a second normalization or a
  second definition of the text. A provider answers for the paths it is
  given and never decides resolution (the loader's, search-free).
* The front-end cache validates an entry by the snapshot's contents, and
  keeps only a compilation whose every answer came from the disk
  (`surface::source::persistable`): never key or validate by "is it a
  buffer", never store one.
* A diagnostic's location is data at its producer -- the parser's
  `surface::syntaxEntries`, the loader's `Error`, `hir::recovery::entries`,
  `hir::warnings::Rejection` and `entry` (core::raiseDiagnostics' `summary`,
  `location`, `related`) -- never parsed out of its text. A new producer of
  raised diagnostics gives them too.
* The service reports the strict compilation's diagnostics -- the very
  entries it raises, in its order, `hir::recovery::reported` deciding what
  is dependent -- and the warnings the compilation attached: never filter,
  merge, reword or add one. Past a syntax error it reports the syntax
  errors, first and unchanged, then what the recovered analysis reports
  (next section but one): its outcome is `syntax` whenever there is one,
  and its `semantics` (`full`, `partial`, `none`) says how much it
  analyzed. Every query reads its revision through
  `service::Use`, which activates the revision's HIR (COMPILATION-ISOLATION.md);
  a revision never changes once made (derived indexes are computed from it
  on first use and released with it); no query runs or compiles code; no
  protocol, JSON, URI, UTF-16 column or event loop in the service (a
  transport's). Hover text never shows an internal id: types through
  `hir::types::presented`, functions through `hir::signatures::text`.

If you change the seam, the cache's use of it, a diagnostic producer, or the
service, run `tests/compiler-service.test`, `tests/main-cli.test`,
`tests/diagnostic-recovery.test`, `tests/hir-cache.test`,
`audit/compiler-service/tools/mutate.tcl`,
`audit/diagnostic-recovery/tools/mutate.tcl`,
`audit/hir-interchange/tools/mutate.tcl` and
`audit/hir-interchange/tools/roundtrip.tcl -via cache` (each mutant must
still apply and be killed); `bench/compiler-service.tcl` regenerates the
performance report.

## The language server

`lsp/` (LSP-MILESTONE-1.md) is `main.tcl -lsp`: a Language Server Protocol
server on stdin and stdout, a consumer of the compiler service that adds
transport, scheduling and presentation, never semantics. Keep it so:

* Every semantic answer is the service's: diagnostics are
  `service::diagnostics` re-encoded, hover, definition and references are
  `service::at`'s facts, Compilerpedia topics `service::explain`'s and the
  facts' own (by identity). Never match names, parse formatted CLI output,
  run a second analysis or resolver, or compute a type in `lsp/`.
* Layers: `transport.tcl` (bytes, Content-Length framing, nothing else),
  `json.tcl` (typed values: a category is never guessed from a Tcl
  string), `jsonrpc.tcl` (messages, no LSP method knowledge), then
  `server.tcl`. JSON and JSON-RPC stay replaceable by a native
  implementation: never let a handler reach below `lsp::rpc`/`lsp::json`'s
  interface.
* stdout carries protocol messages only (the worker's stdout its private
  protocol's); logs go to stderr. The server never writes a source file:
  open documents are the workspace's overlay.
* Positions are converted only in `positions.tcl`, against one exact
  normalized text: the one a revision analyzed, or the one the request was
  made in. A revision answers a position of other text only through
  `Mapping` (identical text, or the unchanged prefix and suffix of one
  edit), and returns a location only where it maps into the text that file
  has now. Never shift offsets by line numbers or guess.
* Only a fresh revision publishes (`Fresh`: every source it read is still
  what the editor and the disk hold); a result older than the one applied
  for its program is obsolete. A stale hover says so; a stale definition or
  references waits while an analysis that will answer fresh is pending.
* Programs and ownership are `UpdateRoots` and `Owner`'s one rule (the
  standard library is no program; a document another open program reads is
  its module; the earlier opened owns): no second rule elsewhere.
* Both schedulers run `service::analyze`; the worker's revisions return as
  `service::export` text (HIR interchange inside) through
  `service::import`, never another serialization of compiler semantics. A
  worker never outlives the server or its own replacement (killed and
  reaped), a crash is reported and recovered from, and the worker is no
  daemon. Test hooks (`BOTLISH_LSP_FAULT`) are environment-only, never
  reachable from the protocol.
* Advertise only implemented capabilities; a new one comes with its tests
  over real pipes.

If you change `lsp/`, `service::export`/`import`, `-lsp`'s options or the
Neovim configuration, run `tests/lsp.test`, `tests/lsp-neovim.test` (it
needs Neovim: `BOTLISH_NVIM=PATH`; CI installs a pinned release),
`tests/compiler-service.test`, `tests/main-cli.test` and
`audit/lsp/tools/mutate.tcl` (every mutant in its `mutants.txt` must still
apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule); for a scheduling change
also `bench/lsp.tcl` (both schedulers, the census's workloads), and for
packaging `single/smoke-test.sh` after `single/build.sh` (its `-lsp`
session).

## Syntax recovery

`-check`, the compiler service and the language server analyze a program
past its syntax errors (SYNTAX-RECOVERY-MILESTONE-1.md); a run, a build and
every inspecting option still stop at them. surface/recover.tcl replaces
each malformed statement -- the innermost statement holding a damaged
position: a construct the parser failed on, a lexical guess (a bracket it
closed, a string it ended, a character it skipped), the top-level region of
a layout problem -- by a `hole` that keeps only what the tokens before the
damage establish; lowering makes it HIR `syntax#hole` refs
(`hir::syntax::holeNode`), each with a SYNTAX-HOLE diagnostic that taints
its unit and is never reported. Keep it so:

* A hole is no value: never `unit`, `never`, `any`, a default or a guessed
  completion. It is poison to inference (no divergence:
  `hir::types::Halts` is false for it), unknown to the range and completion
  analyses, and its innermost function (`holeBlocks`) has no inferred
  result, contract or semantic instance: only its declaration's types are
  facts (a hover shows its signature only when it declares every type).
* What a hole binds is read from its valid prefix alone
  (`surface::recover::Hole`): `NAME =` and `fn NAME` bind NAME; a form the
  prefix does not decide, a destructuring, a coroutine binding or a region
  that swallowed the next line may bind any name (`binds`), and a reference
  a binding hole may capture is `syntaxDependent`
  (`hir::resolve::AfterBindingHole`): no binding, definition, references or
  diagnostic. A top-level hole may declare a type, an extern or install a
  context, and a module's may declare any member (the loader's
  `DependentReference`). Never read meaning from the tokens after the
  damage, and never find a binding by spelling.
* Dependent diagnostics are suppressed by that dependency model
  (`hir::recovery::Tainted`, `Recovered`), never by comparing messages or
  positions; the syntax diagnostics are the parser's, first, unchanged.
* A recovered HIR (`syntaxRecovery`) never runs and is never built or
  cached: every backend refuses it (`hir::recovery::runnable`, `HIR
  SYNTAX-RECOVERED`), the front-end cache never stores it, a strict
  compilation raises the syntax errors, and a `static compile:` block of
  such a program is a hole, never decided. Only `-recover-syntax 1`
  (`surface::readProgramFile`) makes one: never pass it from a path that
  runs or builds.

If you change any of that (surface/recover.tcl, the damage record of
surface/parser.tcl and surface/lexer.tcl, hole lowering in surface/lower.tcl,
the loader's recovery in surface/modules.tcl, hir/recovery.tcl, the hole and
`syntaxDependent` cases of hir/resolve.tcl, hir/types.tcl, hir/range.tcl,
hir/completions.tcl, hir/signatures.tcl and hir/static.tcl, the service's
partial revisions or the server's choice between a partial and a complete
revision), run `tests/syntax-recovery.test`, `tests/compiler-service.test`,
`tests/lsp.test`, `tests/lsp-neovim.test` (Neovim), `tests/main-cli.test`,
`tests/diagnostic-recovery.test`, `audit/syntax-recovery/tools/fuzz.tcl`
(several seeds) and `audit/syntax-recovery/tools/mutate.tcl` (every mutant
in its `mutants.txt` must still apply and be killed: update a mutant's text
when you change the code it mutates, keeping it a mutant of the same rule),
plus the compiler-service, diagnostic-recovery, LSP and hir-interchange
mutation tools for a change to what they cover.
`audit/syntax-recovery/tools/experiments.tcl` prints what the experiments'
programs and their repairs establish; `bench/syntax-recovery.tcl` regenerates
the performance report, and `bench/lsp.tcl -malformed 1` the language
server's editing session through syntax errors.

## Compilerpedia (the built-in reference)

`main.tcl -help` (COMPILERPEDIA.md) reads `compilerpedia/`: the engine
`compilerpedia/compilerpedia.tcl`, hand-written topics in
`compilerpedia/topics/*.topic`, and `compilerpedia/generated/stdlib.topic`,
which `tclsh9.0 tools/compilerpedia.tcl generate` writes from
`core::native`'s registry, `stdlib/*.bot` and `compilerpedia/notes/stdlib.notes`
(never edit the generated file). Help reads only those files: it never
compiles, loads a module or starts a backend, and the "help:" lines main.tcl
prints under diagnostics and warnings are looked up from the printed code
and message -- never add a topic field to a diagnostic, change a message or
the CompilerError text for Compilerpedia's sake.

`tclsh9.0 tools/compilerpedia.tcl check` must pass (`tests/compilerpedia.test`
runs it); it fails when:

* a diagnostic code or kind the source can report has no topic (`code:`) --
  a new `hir::Diagnose` kind, loader `Error KIND`, parser `FailCode`,
  `core::semanticError` kind, literal `throw` code or Rust error-code vector
  needs one, with a rejected example where a source program produces it;
* a registered warning lacks its topic in `topics/warnings.topic` with the
  five required sections and an example that warns and one that does not --
  a warning without a documented rationale cannot land;
* a public intrinsic lacks a note in `notes/stdlib.notes`, or a note or the
  generated file is stale (regenerate and commit after changing a native's
  registration or a library declaration);
* an example no longer compiles, runs or is rejected as stated: when the
  compiler learns to prove a pattern a proof page lists as a limitation, or
  changes a rule, update the page, never the example's expectation alone;
* a reference, alias or matcher is broken.

State only what the compiler does today; document an absent facility as
absent (`capability.*`) with the nearest alternative. A change to the
command line updates `cliOptions` (main.tcl), the `cli.options` topic and
main.tcl's header comment (`tests/main-cli.test` checks all three).

## Golden tests (Botlish-native test framework)

`stdlib/test.bot` (GOLDEN-TEST-FRAMEWORK.md) is an ordinary Botlish library:
a test suite is an installed `context struct Suite` whose `MutableVector`
holds the registered cases, each a deferred `Fn{args: [], return:
std::test::Match}`; the runner is an ordinary coroutine. It has no syntax, no
compiler knowledge and no natives of its own: never add test syntax, a
`test` keyword, an assertion form, a catch-all error, a test-only native,
module-initializer registration or discovery, or compiler knowledge of
PASS/FAIL to support it; record the friction instead (the report's
"Recurring boilerplate" and "Findings"). The library may import `compiler`
to read `std::compiler::CompilerError`, and nothing knows static blocks.

`tests/golden/*.bot` are ported Tcl tests, each listed in
`tests/golden/manifest.tsv` with its Tcl original, which stays in the Tcl
suite, authoritative, unchanged. `tests/golden.test` runs the suites and
fails when a suite's reported tests differ from the manifest's; a new or
removed golden test is a manifest row added or removed. `rejects_at` pins
line and column in the suite file: adding lines above one moves it (update
the test). `tests/golden/README.md` is the porting guide.

The manifest maps *every* Tcl test that runs (LARGE-SCALE-GOLDEN-MIGRATION.md)
and is generated: never edit it by hand. A golden test's row lives in its
suite's fragment (`audit/golden/migration/fragments/SUITE.tsv`), a Tcl test's
classification in its file's census (`audit/golden/migration/census/FILE.tsv`);
a new Tcl test gets a census row (KEEP-INTERNAL for a test of compiler
internals). Regenerate with `tclsh9.0 audit/golden/migration/merge.tcl -names
audit/golden/migration/tcl-names.txt` (refresh the names with
`audit/golden/tools/check.tcl -full 1 -names-out FILE` when tests were added).
A new golden test must be able to fail: run `audit/golden/tools/perturb.tcl` on
its suite. By default `tests/golden.test` runs the eight validation-sample
suites (`BOTLISH_GOLDEN_SUITES=all` or a list of files runs others); CI's
`golden` shards run every suite on every backend beside its Tcl originals
(`check.tcl -shard I/4`). Locally, `tests/local.tcl` runs every suite on
every backend, through the front-end cache (Running the tests locally,
above). A suite that cannot run on a backend declares
`# golden-exclude: BACKEND -- REASON` in its leading comments; keep such tests
in a companion suite so the main suite keeps all four backends. A suite that
runs on one host only (live syscalls through one architecture's transport)
declares `# golden-host: linux-x86_64 -- REASON` (or `linux-aarch64`):
elsewhere it compiles but does not run. A suite whose syscalls go through
the portable wrappers needs no host. On such a host check.tcl accepts a row whose Tcl original a host
constraint skipped (`host-skip`) with its golden test passing or
host-excluded; every other row must still be "old pass, new pass".

If you change `stdlib/test.bot`, run `tests/golden-framework.test`,
`tests/golden.test`, `tclsh9.0 tests/golden/run.tcl`,
`audit/golden/tools/fuzz.tcl` (several seeds, once with `-gc-stress 1`)
and `audit/golden/tools/mutate.tcl` (every mutant in
`audit/golden/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), and the warning gate (`stdlib/test.bot` is in its manifest). If
you change a compiler diagnostic, `std::compiler::DiagnosticCode` or the
completion analysis, also run `tests/golden.test` and
`audit/golden/tools/check.tcl` (old and new tests side by side; with
`-mutants` it runs existing mutants against both). `bench/golden-framework.tcl`
regenerates the performance report.
