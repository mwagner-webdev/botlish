# Notes for agents working in this repository

## Git workflow

Push finished work directly to `main`. This project does not use a
feature-branch-plus-pull-request review cycle: don't open a PR unless
explicitly asked to.

When you work on a branch instead (a session's own instructions can require
one), check `main`'s CI at both ends of the work
(MAIN-CI-FAILURES-2026-11.md, "Why they reached main and why they stayed"):

* **Before you branch off,** read the latest run of every workflow on
  `main` (the GitHub MCP server's `actions_list`, method
  `list_workflow_runs`, branch `main`). A run that is queued or in progress
  is acceptable. A red one is never branched off silently: tell the user
  which workflows and tests fail on `main` before you build on it, and keep
  that list, so your branch's failures are compared with it rather than
  dismissed as "main's own".
* **Before you merge a finished milestone into `main`,** check again:
  `main`'s latest runs and your branch's own. A branch push runs only the
  canary of each of the four test workflows (macOS: the smoke job; next
  section) and the jobs its message opts into (`[ci-full]`,
  `[ci-app-mutants]`, `[ci-probes]`); the rest runs only when dispatched
  (`workflow_dispatch` with the branch as the ref), so dispatch
  `tests.yml`, `tests-arm64.yml`, `macos-arm64.yml` and `windows-x86_64.yml`
  on the branch tip. A branch push's run that deferred to another (its
  summary says "Deferred: ... is tested by RUN") tested nothing: read the
  run it names. Don't merge onto a red
  `main` without telling the user. A failure on your branch that `main`'s
  latest run does not have is yours to fix before the merge. Pending runs
  are acceptable: report them as pending, never as passed.

A newer push cancels a running test workflow on the same ref, on `main`
too, so a run of `main` may end `cancelled`: it was superseded, and says
nothing either way. Read the latest run of the workflow instead. Merging a
branch makes its unfinished runs obsolete, and `prune-runs.yml` cancels
them (CI-RUNS.md; next section).

## CI housekeeping (cancellation, pruning, the release gate, the canary, deferral)

The runners are a shared, limited pool, and main's merges come in bursts
(CI-RUNS.md). Five rules keep obsolete, doomed and repeated runs off them
and keep releases honest; `tools/ci/runs.py` implements the second, the
third and the fifth, `tests/canary.tcl` the fourth. Keep it so:

* **A newer push cancels a running test workflow on the same ref, on main
  too:** a workflow that tests a push has `concurrency: group:
  NAME-${{ github.ref }}` and `cancel-in-progress: true`. Never exempt main
  again: a burst's last push gets the complete run. The only exceptions are
  a tag's run, a release run, scalar-asm-audit.yml (it writes back to
  main), react-native-probe.yml (census evidence) and release-gate.yml.
* **`prune-runs.yml` cancels the unfinished runs of branches fully in
  main** (the tip is main's or an ancestor; a deleted branch's run whose
  commit is in main). It never cancels a run of main, a tag or a fork, or
  of a branch with a commit main lacks; never give it such a rule. Main's
  head may be a commit no workflow ran (scalar-asm-audit's).
* **A release is published only once every test of its commit is green**,
  by a run nothing cancels. `CORE`: tests.yml and tests-arm64.yml with their
  GC-stress jobs *succeeded* (skipped is no success), macos-arm64.yml and
  windows-x86_64.yml with their acceptance jobs succeeded (a branch push's
  run has none), static-decisions.yml when it ran, and the release's own
  build workflow. Any run at the commit counts.
  - `release-gate.yml` (workflow_run of those workflows on main) dispatches
    single-executable.yml or icy-tower-windows.yml on main with
    `release=SHA` for main's newest green commit (`run-name: release SHA`,
    a concurrency group of its own, never cancelled). That release run
    builds nothing: it checks again (`runs.py check --require`) and
    publishes the artifact of the commit's green push run. A push that
    supersedes the commit meanwhile does not stop it.
  - A release tag's run waits for icy-tower-macos.yml's `tested` job. Until
    the commit's tests are green it is deferred, and the gate dispatches it
    on the tag again.
  - Never publish from a push run, never rebuild in a release run, never
    give the gate a credential or more than `actions: write`, and never
    give it a way to dispatch a release twice or move a tag backwards.
  - A release run holds `NAME-release`; its publish job's group is
    `NAME-publish`. Never put a job in the group its own run holds: GitHub
    fails such a job before it gets a runner (every release run did so
    until 2026-11-08; `test_no_job_waits_for_its_own_run`).
* **Every test workflow runs its host's canary first, and its expensive
  jobs wait for it** (CI-RUNS.md, "The canary"): tests.yml, tests-arm64.yml
  and windows-x86_64.yml a `canary` job, macos-arm64.yml the smoke job's
  last step. It runs, within about ten minutes, the test files and golden
  suites the push adds or changes, then the ones `tests/canary.tsv`'s
  history says failed recently on that host; tests.yml's runs the mutant
  catalogs and the warning gate first, as steps (a job of its own would
  wait for a runner before the expensive jobs could start: keep them steps).
  A branch push runs only the canary job, on every host (macOS: the smoke
  job and its Linux control), plus the opt-in jobs its head commit's message
  asks for (a marker counts anywhere in the message, prose included: write
  one only to ask for its jobs); every other job runs on pushes to main, on pull requests and
  when dispatched (its `if` holds `github.event_name != 'push' ||
  github.ref == 'refs/heads/main'`). Where this file asks for a workflow,
  or one of its jobs, "on the branch", dispatch it there, unless it is the
  canary job (macOS: the smoke job) or one a marker opts into. The canary
  orders, it never skips: never drop a job or a test because the canary
  passed, never let an expensive job start
  before it (a job that runs after a failed need checks the canary's
  result itself), and never give it an item list of its own beside its
  selection. `tools/ci/test_runs.py` checks the workflows' side. A new
  test workflow, or a new expensive job, waits for its host's canary, and
  a successful run counts for the release gate only with the jobs a branch
  push skips (`CORE`'s job names: GC stress, the acceptance tiers).
* **A branch push at a commit another run already tests defers to it**
  (CI-RUNS.md, "A commit already tested"): the step "Already tested at this
  commit?" (`.github/actions/twin`, `runs.py twin`) right after the
  checkout of every job a branch push runs finds main's push run at the
  commit (unfinished or successful) or another branch's successful push run
  that ran its canary, and the job skips every later step; an opt-in job after the
  canary reads the canary job's `deferred` output. A deferred run tested
  nothing (the release gate never counts it). Never let a run of main, a
  dispatched run or a pull request's run defer, never defer to a failed,
  cancelled or deferred run or to another branch's unfinished one, and never
  defer on an API error. A new job a branch push runs defers too.

If you change `tools/ci/`, a workflow's concurrency or triggers, a release
job, or the name of a workflow or of a GC-stress job a requirement names,
run `python3 -I tools/ci/test_runs.py` (it also checks the workflows' side
of these rules), `python3 -I audit/macos-release/tests/test_workflow.py`
and that audit's mutants for icy-tower-macos.yml, and
`tclsh9.0 tools/mutant-catalogs.tcl`. Then push and read the `ci tools`
run, which runs the gate, the pruning and the deferral read-only against the
repository's runs. A new required workflow goes into `CORE` and into
release-gate.yml's `workflow_run` list together (the tests check it).

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

The C backend (`ccompile/`, below) also compiles analyzed HIR, and is only as
precise as the analyses: every enhancement of type inference is analyzed for
what it gives the C target too ("The C backend", below).

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

## Depth-safe recursion (nesting is never Tcl's limit)

A syntactically valid program is never rejected, and no compilation fails,
because of how deep the program nests
(DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md): Tcl's limit of
nested evaluations (`interp recursionlimit`, 1000 by default; TCL LIMIT
STACK, "too many nested evaluations") is an implementation property, never
a language limit. The walks that follow source nesting -- the parser's
productions, the AST and loader walks, surface lowering, resolution,
inference, the range, completion and warning walks, HIR text, core IR and
its check, the Tcl compiler and native lowering, and the walks of what
else nests as deep as the source writes it (destructuring patterns,
written types, loops, Boolean conditions, inject blocks, layout
representations, module bindings, an affine type's drop descriptor over a
chain of declarations) -- stay recursive procedures, and each starts with
the guard

    if {[info level] > $::core::deep::bound} {tailcall ::core::deep::descend [info level 0]}

which, past a segment's frames, goes on in a new segment (a Tcl coroutine
holding the caller's variables, core/deep.tcl) that a driver resumes from
its own shallow frame; the interpreter's nesting stays one segment deep.
Keep it so:

* **Frontend algorithms over recursively nested source must not use host
  call-stack depth as a language limit.** A procedure whose recursion
  follows the program's nesting carries the guard and is listed in
  `audit/depth-safe-nesting/census.tsv`; a new one is found by
  `audit/depth-safe-nesting/tools/census.tcl` (and the probe, below).
  Never raise `interp recursionlimit` for the front end, catch TCL LIMIT
  STACK, retry, rewrite source before parsing, or add a nesting limit or a
  diagnostic for depth. `hir::Deep` and `core::deep::run` are drivers,
  never limit raisers.
* **A parser/build/type/lowering walk proportional to arbitrary
  expression nesting should use an explicit work stack or another
  depth-safe representation** -- here the guard's segments, whose stack is
  the driver's. A guarded procedure reaches its caller only through
  `upvar 1` or `uplevel 1` (deeper levels are another segment's), never
  yields, and passes no namespace variable by another name (`upvar #0
  ::x y`): a segment takes its caller's variables by value and gives them
  back, re-linking a namespace variable only under its own name. Nothing
  reads `info level` to decide what a program means (hir::semantic's
  instance budget is the instance stack's: `maxDepth`).
* Segments change where frames live, never what a walk computes: no
  segment-dependent result, order, error or diagnostic
  (tests/depth-safe-nesting.test's `dsn-segment-invariance` compiles with
  a segment every 3 frames).
* A nested node is never put into text whole: `regexp`, `string first`,
  `in`/`ni`, `lsort`, `switch` or a dict key on a syntax or AST node
  gives every node of its subtree a string, and `concat` gives one to every
  element of a list after the first -- quadratic memory in the nesting
  (590 MB for a List literal 400 deep). Join node lists with `list
  {*}...`, search syntax with `hir::syntax::words`.
* The reference interpreter's run (core::interp, core::forms, a Botlish
  call) is the program's own recursion, not the compiler's: it stays under
  the program recursion limit (core::useProgramRecursionLimit), and is
  never guarded (a Botlish coroutine's Tcl `yield` must reach its own
  resumer).

If you change core/deep.tcl, a guarded procedure's frame use, the census or
a walk over nesting, run `tests/depth-safe-nesting.test` (at Tcl's default
limit), `audit/depth-safe-nesting/tools/probe.tcl` (every path of every
specimen 1000 deep at the default limit: no TCL LIMIT STACK, and no
refusal the program 3 deep does not get too),
`audit/depth-safe-nesting/tools/census.tcl` (no recursive procedure
missing from the census; the specimens that cycle through forms once
more each, with `-fraction` their number of forms: `-kinds loops -fraction
3`, `-kinds mixed -fraction 4`, and `-kinds cond -depth 12 -fraction 3`,
whose traced Boolean analyses take over an hour 24 deep),
`audit/depth-safe-nesting/tools/fuzz.tcl`
(several seeds) and `audit/depth-safe-nesting/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed by a detector
its `!!` line names: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule).
`bench/nested-frontend.tcl` regenerates the scaling report.

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
containers (`single/smoke-test.sh`); once every test of the commit is green,
the release gate's release run publishes that build as the
`botlish-linux-x86_64` asset of the rolling `single-latest` prerelease
(CI-RUNS.md). The README's download button links to that tag and asset
name: rename either only together with the button. Its base kit is Tcl's
static library, which `single/basekit.sh` builds once from the pinned Tcl
9.0.1 source release and caches, linked with `single/basekit.c` as its main
program. That build is the one exception to "do not build Tcl 9 from
source" above: no package ships a static zipfs Tcl. `--basekit PATH` takes
a base kit `single/basekit.sh` linked before; a stock tclsh or prebuilt
zipkit is refused (next item). To run the test suite, still install the
`.deb`s.

* `single/package.tcl` packs exactly main.tcl, LICENSE, `core/`,
  `compiler/`, `hir/`, `surface/`, `service/`, `lsp/`, `pm/`, `ccompile/`,
  `native/*.tcl`, `stdlib/`,
  `compilerpedia/compilerpedia.tcl`, `compilerpedia/topics/` and
  `compilerpedia/generated/`, plus a `BUILD` file naming the source
  revision. If the compiler starts reading another file at run time, add
  it there. Never make main.tcl or the compiler depend on the single
  executable: `single/main.tcl` only sets the environment and sources
  main.tcl unchanged.
* The packaged compiler runs only its own Tcl library (SINGLE-EXECUTABLE.md,
  "Its own Tcl library"). Tcl starts without the user's `TCL_LIBRARY`
  (`single/basekit.c`; on macOS the launcher sets `tcl_library` first), and
  `single/main.tcl` keeps `auto_path` and the module path inside the
  packaged library: never `$TCLLIBPATH`, `$TCL9.0_TM_PATH` or the
  directories beside the executable. The compiler's children see those
  variables exactly as the user set them: put back after Tcl starts, never
  unset, replaced or set by the compiler. Never give the base kit Tcl's
  stock main (a stock tclsh or zipkit sources a decoy `TCL_LIBRARY`'s
  `init.tcl` before `single/main.tcl` runs; `single/build.sh` refuses
  one), and never create a Tcl interpreter in the compiler: `interp
  create` (one not `-safe`) runs `tclInit` again, with `TCL_LIBRARY` back.
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
  single executable's packing, startup or installation (`single/main.tcl`,
  `single/package.tcl`, `single/basekit.c`, `single/basekit.sh`)
  `audit/single-executable/tools/mutate.tcl` and both
  `single/smoke-test.sh` and `single/ffi-smoke-test.sh` after
  `single/build.sh`.

## The C backend (main.tcl -emit-c)

`ccompile/ccompile.tcl` (C-COMPILE-FREESTANDING-MILESTONE-1.md) writes an
analyzed HIR as freestanding C11: `PREFIX.h`, `PREFIX.c`,
`PREFIX_display.c`, `PREFIX.runtime.json` and, when the C uses it, a copy
of `ccompile/botlish_rt_v1.h`, the runtime-service interface. It compiles
one C function per instance of `hir::specialize` and reads `hir::range`'s
proofs, as native lowering does, and runs no C compiler. Keep it so:

* No semantics of its own: it consumes HIR and the existing analyses, adds
  no range analysis, never reads NIR or core IR, and changes nothing in
  `hir/`, `core/` or `surface/` for C's sake. A fact it needs and the
  analyses lack is the Int path (correct, slower) or C UNSUPPORTED, never
  an assumption.
* An Int is an `int64_t` only on a proof (its Range, its domain, or a
  representation chosen on one); `+ - *` are C arithmetic only when the
  operands' and `hir::range::add/sub/mul` of them fit int64_t. Never emit C
  signed arithmetic that can overflow, `<<` or `>>` of a negative, or `%`
  with a divisor that may be 0 or `-1` with INT64_MIN. Narrowing an Int to
  an `int64_t` reads `small`, on a proof only; the services' normalization
  (botlish_rt_v1.h) is what makes it exact.
* What C cannot implement is a call of a `botlish_rt_v1_*` service the
  interface declares, listed in the manifest: a missing provider is a link
  error, never a compilation error, a placeholder or a fake implementation.
  What the backend cannot translate is `C UNSUPPORTED` at the construct,
  never a symbol reference. A new service is a row of `ccompile::services`,
  a declaration and contract in botlish_rt_v1.h (a v2 header for an
  incompatible change), and the reference provider's implementation.
* The generated C stays freestanding C11: `stdint.h`, `stdbool.h`,
  `stddef.h` only; no allocation, I/O, `main`, extension or inline
  assembly; every global name prefixed; helpers emitted only when used; it
  compiles warning-free under tests/c-compile.test's flags (`-Wconversion`
  included). Errors are statuses: never terminate the process.
* The manifest and the C are deterministic and agree: the manifest names
  exactly the service symbols the C calls, per translation unit.
* Harnesses and providers stay outside the backend
  (`examples/c-freestanding/`), as integration code of a target's.
* Contexts (C-CONTEXTS-FREESTANDING-MILESTONE-1.md) are the front end's,
  translated, never re-decided: an installation is an object of the
  program function's frame (per run); a function's C parameters after its
  ordinary ones are one `T *` per context of its block's
  `requiredContexts`, in order, and a call passes exactly the callee's
  requirement (`ContextArgs`): the signature is its authority. Nothing
  writes through the pointer, but neither it nor the object is
  `const`-qualified: GCC 15 reports an initialized object passed to a
  pointer-to-const parameter "may be used uninitialized" after cloning a
  recursive function with its constant contents
  (`cc-ctx-no-const-context-pointers`). Never put a
  context in file-scope storage, a global or thread-local pointer, a
  registry, an environment struct handed to every function, a lookup or a
  runtime service; never compute a requirement, a selection or an
  injection in the backend (the trait plan and hir/contexts.tcl did), and
  never compile a HIR that failed context verification. No context name
  starts with `PREFIX_` (`ContextName`). A context the C subset cannot
  represent (a member of an unsupported type, affine state) is C
  UNSUPPORTED naming it.
* **Every enhancement of type inference is also analyzed for what it gives
  the C target.** The backend adds no analysis of its own, so its
  precision is the analyses': a new or sharper fact -- a type or a Range
  (hir/types.tcl, hir/range.tcl, a join's, a fold intermediate's, an
  operation's result), a semantic instance (hir/specialize.tcl), a
  function's contract (hir/signatures.tcl), a List length, an enum known
  statically -- can make an Int an `int64_t`, take a runtime service out of
  a program's manifest, or make a C UNSUPPORTED construct compile. Such a
  fact is an enhancement of the analyses, made for every backend, never a
  rule of the backend's. Run `main.tcl -emit-c` over the corpus of
  C-COMPILE-FREESTANDING-MILESTONE-1.md, section 14, before and after the
  change, and record in the change's report what it changes for C: which
  programs now compile, which values change representation, which services
  leave a manifest, which C UNSUPPORTED it removes -- or that it changes
  nothing for C. A fact the C target cannot use yet (the backend reads
  something else) is recorded too, as the backend's next step.
  `tests/c-compile.test` must still pass.

If you change `ccompile/`, `examples/c-freestanding/` or what the backend
reads (`hir::specialize`'s instances, `hir::range`'s results, the HIR node
kinds it compiles, the context facts `requiredContexts`, `installId` and
`loadId`), run `tests/c-compile.test` (its cross tests need clang,
ld.lld, qemu-user and the cross libgcc packages, and are skipped without
them), `tests/main-cli.test` and `tools/compilerpedia.tcl check`, and
`examples/c-freestanding/demo.sh`.

## The macOS application (Botlish.app)

On macOS the packaged compiler is an application bundle, not one file
(MACOS-AARCH64-MILESTONE-9.md; SINGLE-EXECUTABLE.md, "The macOS
application"): `single/macos/build.sh` makes `Botlish.app` -- the launcher
`Contents/MacOS/botlish` (`single/macos/launcher.c`), the driver
`Contents/MacOS/botlish-native`, `Contents/Frameworks/Tcl.framework`
(`single/macos/tcl-framework.sh`: Tcl's own framework build of the pinned
9.0.1, install name `@rpath/Tcl.framework/Versions/9.0/Tcl`), the compiler
archive `Contents/Resources/botlish.zip` (`single/package.tcl -archive`)
and `Contents/Resources/libbotlish_runtime.a` -- signs it ad hoc with the
hardened runtime (`single/macos/sign.sh`), verifies it
(`single/macos/verify.sh`) and archives it as `botlish-macos-aarch64.zip`.
macos-arm64.yml's `app` and `app-clean` jobs build and accept it on every
push to main and every dispatched run (a manual run with `app_only` runs
only them; a branch push runs neither); `botlish-macos.yml` releases it,
Developer ID-signed and notarized, for a tag `botlish-macos-vX.Y.Z`
(MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md). Keep it so:

* One staging procedure: both distributions pack what `single/package.tcl`'s
  `StageCompiler` stages; never a second file list. The macOS archive holds
  no Tcl library (the framework's) and no native executable (the bundle's).
* Never append data to a signed Mach-O, change a file after it is signed,
  or sign with `--deep`: sign inner code first (the framework's version,
  the driver, then the application). `single/macos/sign.sh` is the one
  statement of that order, for the ad hoc build and the release alike:
  never a second signing sequence. Executable code lives in
  `Contents/MacOS` and `Contents/Frameworks` only; nothing is extracted to
  a cache to run, and nothing is ever written into the bundle (the
  language server's copy of the standard library goes to
  `~/Library/Caches/botlish` or `$BOTLISH_CACHE_DIR`).
* A graphical program's executable is built with `-native-startup
  main-thread` (Executable startup policy, above): never make the
  application, the launcher or the driver choose it.
* The launcher only starts Tcl and the archive; it never implements the
  command line, and never prints on standard output. It accepts only the
  bundle's own Tcl (never one from `TCL_LIBRARY`, `DYLD_FRAMEWORK_PATH`,
  /Library/Frameworks or Homebrew) and finds its bundle from its own real
  path, never from argv[0], PATH or the working directory. The driver finds
  its runtime archive from its own path (`packaged_runtime_archive`), and
  single/main.tcl always runs the bundle's driver. Tcl starts in a UTF-8
  locale (`LC_ALL=UTF-8` while it initializes: Tcl 9.0.1 crashes in a
  non-ASCII path otherwise) and the user's `LC_ALL` is put back, exactly,
  before anything runs: never let the compiler's children see a locale
  the user did not set.
* The application's driver has no JIT: build.sh builds it with `cargo
  build --no-default-features` (the `jit` feature off; its own target
  directory) and refuses one whose `capabilities` say `jit 1`; verify.sh's
  `no JIT` group checks the binary. `-backend cranelift` and
  `cranelift-generic` are refused by main.tcl, naming `-aot-run`; `run`'s
  native default is `-aot-run`; the driver's run, bench, batch and vms are
  `NATIVE UNSUPPORTED jit`. Never ship a driver with the JIT, never
  re-route a JIT entry point to something else silently, and never add a
  JIT entitlement.
* Every unit (the framework's version, the driver, the application) is
  signed with the hardened runtime and no entitlement in every mode, so
  ordinary CI runs the bundle under it. Ad hoc signing is not
  notarization: never describe an ad hoc artifact as notarized or
  Gatekeeper-approved. The release's rules are Icy Tower's (next section
  but many: "Icy Tower.app and its release"), through the same
  `tools/macos-release/` core; the compiler's description is
  `single/macos/bundle.py`, its identifier fixed there
  (`io.github.mwagner-webdev.botlish`), never read from a GitHub variable
  (`MACOS_BUNDLE_ID` is the game's).
* A test or tool that runs the application uses a copy for anything that
  damages or changes it, and checks the bundle untouched afterwards.

If you change `single/macos/`, `single/main.tcl`, `single/package.tcl`,
`audit/macos-app/` or the driver's `packaged_runtime_archive`, dispatch
macos-arm64.yml on the branch (`app_only` for these alone) and read the
`app` and `app-clean` jobs (they run `single/macos/verify.sh`,
`single/smoke-test.sh`, `single/ffi-smoke-test.sh`,
`single/macos/app-test.sh`, `single/macos/compare.sh`, the release's
stages in ad hoc mode with `single/macos/acceptance.sh`, and
`bench/macos-app.tcl`), run `audit/macos-app/tools/mutate.tcl` (a push with
`[ci-app-mutants]`: every mutant in its `mutants.txt` must still apply and
be killed; update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), and the Linux single executable's
checks (single/build.sh, both smoke tests,
`audit/single-executable/tools/mutate.tcl`): the scripts are shared. If you
change sign.sh, acceptance.sh, `single/macos/bundle.py` or `release.py`,
`tools/macos-release/` or botlish-macos.yml, also run the release tests
and mutants (next section but many: test_botlish_release.py and
test_botlish_workflow.py beside Icy Tower's).

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

It starts the likeliest to fail first (`-priority 1`, the default): the
files and suites this checkout changes against origin/main, its working
tree included, then those that failed recently in CI on this host
(`tests/canary.tsv`), as the CI canary selects them (CI-RUNS.md, "The
canary"). `-fail-fast 1` starts nothing more after the first failure and
reports the rest as not run. It prints a line per file and suite, then
every failure with the command that reruns it, and exits 1 on any (or on
anything not run).

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
    stress) and, on pushes to main and manual runs, the GC-stress run. Run
    it on a branch with workflow_dispatch;
  - first, on every push to any branch and on every host, the canary
    (CI-RUNS.md, "The canary"), which the jobs above wait for. A branch
    push runs only the canary (and the jobs its message opts into), and
    none at a commit another run already tests: dispatch the workflows on
    the branch for the rest.

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

## Tests that hold on every host, and mutants that still apply

A test is written on one machine and run on four hosts and in several
temporary directories (MAIN-TEST-DEFECTS-2026-11.md has the cases). Keep
what it depends on in its code or its constraints:

* Wait for a child process by closing its pipeline (`open |[list ...] r`,
  read to the end, `close`) or by a plain `exec`: never by probing `/proc`,
  `ps` or a delay, which hold on Linux only, or only on a fast machine.
* Every tool a test runs is in its constraint. A library of another
  architecture is linked with `-fuse-ld=lld` (GNU ld links only its own) and
  the test carries an `lld` constraint.
* Never match a word against output that names a host path (the temporary
  directory, the checkout): map the paths out first (`string map [list $dir
  DIR]`). The native coverage jobs' temporary directory is
  `/tmp/native-coverage_XXXXXX`.

A change can break another audit's mutant: rewrite or duplicate the text it
replaces, and that mutant guards nothing until its own harness next runs.
`tclsh9.0 tools/mutant-catalogs.tcl` applies every mutant of every catalog
under `audit/` to the tree in memory (seconds; a step of `tests.yml`'s
canary job). Run it before pushing a change to code. A mutant it reports is
updated in the same change, kept a mutant of the same rule, and run through
its own harness (`-only NAME`). A new catalog whose files are not relative
to the repository root, or not named by `## FILE` lines, gets a row in the
tool's `Catalogs` table.

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
`stdlib/web.bot` 17 (its hex-digit table and `"%"`; its local-part and label
classes read `UnicodeChar`s since UNICODECHAR-CLASSIFIERS.md) and
`stdlib/linux/path.bot` 2 (`"/"`). Every other module is
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

`DISCARDED-MUTATION` (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md;
hir/discarded.tcl the facts, hir/warnings.tcl the pass) reads the checked
program as written -- a trait program's `traitSource`, any other program's
`checkedSource`, which hir::BuildFull keeps (for a program that uses a
mutable collection) before the elaborations rename a fold's intermediate
and rewrite MutableMap loops, and which `hir::warnings::run` drops from the
HIR every compilation returns (interchange text leaves it out too) -- and
reports two proven facts: a mutation (hir::mutvec's `place` receivers and
place arguments, written calls only) whose every destination is a place
that dies with its scope and is its path's last use
(`hir::mutvec::NoLaterUse`), whose value is discarded and whose callee is
confined (only its own places and its place parameters, transitively: no
context, function value, syscall, C call, yield or affine value); and a
fold's `continue` or bare `break` that every path reaches after mutating the
intermediate (a must-walk of the iteration, never `FoldExitsClean`, which
answers another question). Keep it so: never warn on a mutation some path
reads, on a place parameter's or a context's, on a call with another
effect, on anything affine, or on an exit only some paths reach after the
mutation; never read a name or a spelling (`push`, `set`); never analyze an
elaborated HIR as if it were written (`hir::discarded::Source` declines
one); no opt-out, no fixit, no claim that the call may be deleted (its
failure stays the program's). If you change any of that, `NoLaterUse` or
`UseMap`, how a fold, a loop, a handler or a place parameter binds, the
registry's ownership roles or runtime tags, `checkedSource`, or the
completion analysis's `reachedExprs`, run `tests/discarded-mutation.test`,
`audit/discarded-mutation/tools/fuzz.tcl` (several seeds: its model is its
own liveness and must-walk over the statements it generated) and
`audit/discarded-mutation/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), and the warning gate.
`audit/discarded-mutation/tools/census.tcl` (and `test-census.sh` for the
Tcl test files' programs) re-takes the repository census against
`audit/discarded-mutation/census.tsv`; `bench/discarded-mutation.tcl` the
compile-time costs.

## The warning gate

The shipped stdlib, libraries, examples and benchmarks compile clean under
Botlish's own warnings, except exactly the findings `audit/refactor/manifest.txt`
lists, each with the obstruction that keeps it open (REFACTOR-WARNINGS-CLEAN.md).
`audit/refactor/tools/gate.tcl` checks it -- every corpus program and a one-line
loader per library module, the observed warnings equal to the manifest (code
and location), and every program and loader without an entry compiling under
`-warnings error` -- and a step of `.github/workflows/tests.yml`'s canary job
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
  String-region test of the `peek()` idiom) read, not corpus. Never clean a
  warning out of it. The one exception is a language change that makes one
  of its programs stop compiling: migrate that program in the same change,
  only as far as compiling again takes. Every warning must keep its code
  and its text (only positions may move), and every program its results on
  every backend: compare against the tree before the change. Then list the
  edit in its README.md, beside the first one
  (NONPLACE-PARAMETER-MUTATION-CORRECTNESS-MILESTONE-1.md's).

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

## Folding loops

`fold CLAUSES with intermediate acc INITIAL:` (FOLD-LOOPS-MILESTONE-1.md)
is a loop that carries one value instead of collecting: a fold is a loop
node of any of the four kinds (`loop`, `listloop`, `countloop`,
`lockloop`) carrying `foldBinding` (the intermediate, a parameter of its
body scope) and `foldInitial` (`hir::isFold`, `hir::FoldInitials`). Its
operands are evaluated first, then the initial value once; a normal
completion of the body replaces the intermediate, `continue` keeps it, a
bare `break` and exhaustion yield it. Keep it so:

* One representation: never a fold node kind of its own, a second
  iteration machinery or a fold-specific lowering of a domain. Every
  analysis or backend that knows loop kinds handles the two fields where a
  loop's result or operands matter (the initial value is an operand after
  the loop's own; the body's value is the next intermediate, never
  discarded and never collected); core IR is `(fold INIT LOOP)`, the loop's
  block binding the intermediate last.
* Never build a List, a plan, a MutableArray or any object for the fold
  itself: natively the intermediate is one loop-carried register
  (`LoopResultStart`, `LoopResultAdd`, `LoopResultFinish`, the `fold`
  mode of a `loops` entry). A fold is never credited with its domain's
  cardinality (hir/cardinality.tcl) and never retained as a module
  binding's List.
* The intermediate's type is the join of the initial value's and every
  normal completion's, found by `hir::types::FoldBody`'s bounded fixpoint;
  a join only `any` covers is FOLD-INTERMEDIATE-TYPE (hir/fold.tcl), and
  the walk that finds it makes the intermediate and the fold poison so
  nothing restates it. Every walk of a fold re-decides its own poison and
  conflict (an enclosing recursive block walks it more than once). Never
  give the fold a default value on a `continue` or `break` path, a typed
  annotation of its own, or an implicit conversion.
* No mutable binding: the intermediate is immutable in its iteration (a
  DUPLICATE), and an affine one is AFFINE-FOLD-UNSUPPORTED (hir/affine.tcl)
  until its ownership protocol is designed.
* `fold` is contextual (`surface::parser::AtFold`: directly before a
  name); `with` and `intermediate` are words of its header only.

If you change any of that (the parser's `Fold`/`AtFold`, hir/fold.tcl,
`FoldBody`/`FoldResult`, the fold cases of the analyses, core IR's `fold`,
the evaluator's `Results`, the Tcl compiler's `FoldStart`/`ResultLine`,
native lowering's `LoopResult*`), run `tests/fold-loops.test`, its golden
suite (`tclsh9.0 tests/local.tcl tests/golden/fold-loops.bot`; it is
generated with its fragment by `audit/fold-loops/tools/golden-port.py`),
the loop test files (`loop-collecting`, `loop-counted`, `loop-in`, `loops`,
`native-listloop`) and `audit/fold-loops/tools/mutate.tcl` (every mutant
in its `mutants.txt` must still apply and be killed: update a mutant's text
when you change the code it mutates, keeping it a mutant of the same rule),
plus `tests/fold-loops.test` under `BOTLISH_NATIVE_GC_STRESS=1` for a change
to native lowering. `audit/fold-loops/tools/measure.sh` and
`economics.tcl` regenerate the report's measurements.

## Virtual construction across folds

A fold whose String or List intermediate the body only extends carries it
as a construction plan (FOLD-VIRTUAL-LIST-CONSTRUCTION-MILESTONE-1.md):
hir/construction.tcl's *plan fold*, a fourth carrier beside its plan
locals, parameters and results, lowered by native/lower.tcl's
`LoopResultStart`, `LoopResultBind`, `LoopBody` and `FoldValue`. Keep it
so:

* One construction mechanism: M8.a's pieces, `construct`, plan registers
  and nir.rs's `validate_plans` (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md).
  Never a fold-specific builder, NIR instruction, runtime object or helper,
  and never a rule keyed on how the body is spelled (`acc.append`): the
  decision reads value flow only (`FoldLinear`, `Context`, `Source`).
* Linearity is per iteration, and a `continue` or bare `break` targeting
  the fold is a reference to its intermediate (the "fold" marker `Uses`
  reads in LOOPS): it passes the current intermediate on. Never drop that,
  or an append computed before a break or continue is extended in place and
  becomes visible. A captured intermediate, or one another representation
  analysis claims, is never a plan; a fold is a plan only when some
  reference continues the construction and the body's trailing value is
  plan-producing.
* The fold's own value stays flat: materialized once at exhaustion and at
  a break (`FoldValue`). A fold as a plan source, a struct intermediate's
  List fields and fusion with collecting loops or `std::list::flat` are
  later milestones' (the report's follow-up), never a special case here.
* Declining is never an error: the eager lowering stays, its reason in
  the analysis' `foldWhy`. HIR, types, specialization keys, the Tcl
  backends and `-virtual-construction-opt 0` are unchanged.
* A plan-position sequence (`SequenceTo`) releases the affine values dead
  after each statement exactly as `Sequence` does.

If you change any of that, or what hir/construction.tcl or the loop
lowering's result handling does, run `tests/fold-virtual-construction.test`
(also under `BOTLISH_NATIVE_GC_STRESS=1`), its golden suite (`tclsh9.0
tests/local.tcl tests/golden/fold-virtual-construction.bot`; generated with
its fragment and census by `tclsh9.0
audit/fold-virtual-construction/tools/golden-port.tcl` from the Tcl tests'
own programs), `tests/virtual-construction.test`, `tests/fold-loops.test`,
`audit/fold-virtual-construction/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`: values against an independent model, decisions against an
independent model of the rule) and `audit/fold-virtual-construction/tools/
mutate.tcl` (every mutant in its `mutants.txt` must still apply and be
killed: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule; its native mutant rebuilds a private copy).
`audit/fold-virtual-construction/tools/measure.tcl` regenerates the
report's tables (`-root DIR` measures another checkout).

## Flattening Lists (std::list::flat)

`std::list::flat[T](lists: List[List[T]]) -> List[T]`
(LIST-FLAT-MILESTONE-1.md) removes exactly one level of nesting, in order,
eagerly: an ordinary root native (core/lists.tcl), `op listflat` natively
(ops.rs's `rt_list_flat`). Keep it so:

* One level, every element as it is: never recursive, no depth parameter,
  no predicate or mapping callback, no flattening by an element's runtime
  kind, and no element compared, hashed, converted or copied deeply. No
  `flat_map`, `flatten` or `concat_map` beside it, and no new loop syntax:
  a collecting loop bound to a name, then flat, is the composition.
* Linear, in every implementation: one pass over the outer List (kinds
  checked, lengths summed with saturating arithmetic, the collection
  ceiling refused before anything is allocated), one result of exactly the
  total length, each inner List copied into it once. Never build it by
  appending, never copy a prefix again, never allocate per element.
* No fusion, plan or builder: the operand is a completed List (a plan that
  reaches it is materialized: hir/construction.tcl's "flat-only native
  operation") and the result is an ordinary flat List. Fusing it with
  collecting loops or folds is a later milestone's, justified by its own
  escape and ownership analysis.
* Typing is by registration, never by name in hir/types.tcl: the result
  shape `{flat 0}` (List[List[E]] gives List[E]), the length form
  `-result-length {flat 0}` (N*M only when both lengths are stated), and
  `-element-kinds {list}`, which the one native-kind rule
  (`hir::types::NativeKindMismatch`, `ElementKindMismatch`) holds statically
  for an element type of a known other kind; `any` stays dynamic (the
  run-time TYPE names the element's position, the same text on every
  backend). An affine List is AFFINE-LIST-OPERATION-UNSUPPORTED (copy-out),
  like every element-wise List operation.

If you change any of that (core/lists.tcl's flat, `-element-kinds` in
core/native.tcl, the `flat` cases of hir/types.tcl, hir/exactvalue.tcl,
hir/modulebinding.tcl and hir/callables.tcl, `listflat` in native/lower.tcl,
nir.rs, codegen/clif.rs or ops.rs), run `tests/list-flat.test` (also under
`BOTLISH_NATIVE_GC_STRESS=1`), its golden suite (`tclsh9.0 tests/local.tcl
tests/golden/list-flat.bot`; generated with its fragment and census by
`python3 -I audit/list-flat/tools/golden-port.py`),
`audit/list-flat/tools/fuzz.tcl` (several seeds; once with `-profile large`,
once with `-gc-stress 1`), `python3 -I audit/list-flat/tools/oracle.py
selftest`, `cargo test --release --manifest-path native/Cargo.toml --lib
list_flat` and `audit/list-flat/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule), plus
`tests/method-receiver-types.test` for a change to the native-kind rule.
`audit/list-flat/tools/measure.tcl` regenerates the performance tables.

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

A statically selected trait implementation contributes its actual semantic
requirements to the specialized program -- its yields and protocols, its
context requirements -- and an unselected one contributes nothing. Every
analysis of the checked program reads the one *selected implementation
graph* (the HIR's `implementations`, hir::check's feedback:
`hir::coroutines::Implementations`, from the plan's own call resolution,
`hir::traits::PlanCalls`): the coroutine analysis, the context analysis
(`hir::contexts::Requirements`, a node per specialization), hir/staticdeps.tcl
and the legacy scheduler's units (`ImplementationTargets`). Never resolve a
trait operation's implementation anywhere else, never union a requirement's
implementations, and never let provider availability select one (SFIAE). A
specialization is named in it by `{FUNCTION WITNESSES BINDING}`
(`hir::traits::Specialization`), never by its clone key, whose selection the
graph decides. The plan calls an implementation it replaces through its
clone, by one rule for trait and context-trait operations
(`CallImplementationClone`), and checks that no action names a dropped
declaration or an unmade clone (`hir::traits::Dangling`, TRAIT-INTERNAL).
If you change any of that, run what TRAIT-IMPLEMENTATION-CONTEXT-
REQUIREMENTS-MILESTONE-1.md's "What to run when changing this" lists.

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

## Restricted context injection (inject blocks)

`inject context A, B:` and `inject no context:`
(RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md) run a block with exactly the
listed installed contexts' authority. Installation (entry top level),
selection (one implementation per context trait per program) and injection
(a computation's permission) are three things: an inject block never
installs, selects, constructs or copies a context. Keep it so:

* One representation: the block is the ordinary `if true:` (surface/
  lower.tcl's `inject` case) carrying `injects` (resolved identities) on the
  `if` expression; only hir/injection.tcl and hir/contexts.tcl read it, and
  HIR text prints it (`if injects (IDS)`). Never add a HIR or core IR node, a
  runtime operation, a permission table, a context copy, an actor-local
  context area or a per-coroutine context table for it, and never compile a
  function again per authority subset: the restriction is a proof, not code.
* One requirement analysis: a block's calls are judged by
  `hir::contexts::Requirements` (the transitive requirement over the same
  edges, `Targets`); a block is a use of what it injects (its function's
  grants), so nesting and callers are checked by the ordinary rule. Never
  add a second reachability, never read a requirement from a name, and never
  satisfy a missing injected context from the installed set.
* A context trait injected grants its operations through the selected
  implementation, never the implementing context's other functions; the
  monomorphized build is judged as written (`hir::injection::Judged`).
* Retained authority is followed, never assumed: every handle origin is a
  construction (`{auth IDS C}`), a parameter (substituted at calls) or
  foreign (installed context state, an affine payload); anything the
  provenance analysis cannot follow rejects a resume in a block
  (CONTEXT-RETAINED-AUTHORITY), never accepts it. Its soundness rests on the
  channels COROUTINE-CONTRACT, AFFINE-CAPTURE-UNSUPPORTED and
  AFFINE-ERASURE-UNSUPPORTED close: if one of those opens (an affine
  message, a capture of a handle, an erased handle), extend the analysis in
  the same change. Moving a handle without resuming it is no use of its
  authority: never reject that.
* CONTEXT-NOT-INJECTED and CONTEXT-RETAINED-AUTHORITY are obligations
  (`hir::methods::ObligationKinds`): an injection never selects a method
  candidate (SFIAE).
* Values cross freely (data, a copy of a context value, a function value,
  a mailbox address): passing a value is explicit delegation. Never extend
  the restriction to values without a design of its own.

If you change hir/injection.tcl, the grants or chain lines of
hir/contexts.tcl, the inject grammar (surface/parser.tcl's `Injection`,
surface/ast.tcl, surface/recover.tcl, surface/modules.tcl's `Walk`), its
lowering, its HIR text (hir/format.tcl, hir/read.tcl), the coroutine
contract rules above, or what a call's targets are, run
`tests/restricted-injection.test`, `tests/contexts.test`,
`tests/context-traits.test`, `tests/coroutines.test`,
`tests/static-compile.test`, `tests/method-resolution.test` and
`audit/restricted-injection/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), plus `tools/compilerpedia.tcl check` for its
topics (`concept.context-injection`, `error.context-not-injected`,
`error.context-retained-authority`, `error.duplicate-injected-context`).

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
extended it to every affine value, keeping both properties. The one
exception is a resource's (next sections but one: Resources): its release
runs its module's cleanup function, and in a program where a suspending
function owns one, releasing a suspended coroutine unwinds it so that its
frames' releases run -- the program's own release code, never anything
else.

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
guarantee). Any number of threads may be guarded at once, each with its own
record (`runtime/platform/records.rs`, PER-THREAD-RUNTIME-STATE-MILESTONE-1.md:
its token, its published stack, its mode, destination and label); the
process's handler is installed with the first guard and removed after the
last. Keep it so:

* The handler only classifies and reports: an address in the guard of the
  stack the faulting thread *published* as running, on a guarded thread
  (POSIX), or STATUS_STACK_OVERFLOW on a guarded thread at an address of the
  stack it published as running (Windows) -- the record found by the
  faulting thread's token, never another thread's -- writes the record's
  label and the result line and ends the process (`_exit`;
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
  inaccessible where Rust's runtime started the process (std's main-thread
  guard: the rustc linker's executables, Rust test binaries) and usable
  under a C main (the system linker's): the walk takes either, its usable
  bound then one page above the reported one. On
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
`native-stack-mutants`), and the macOS smoke job and a `[ci-full]` push
with `CI-Tests: native-stack-overflow.test rust native-stack-mutants` on a
branch (macOS facts are CI's: the shared Mac is not used); for the Windows
guard, the Windows workflow dispatched on the branch (its smoke job runs
the native stack checks, and `[ci-full]` with `CI-Tests:
native-stack-mutants` the mutants). `bench/native-stack-guard.tcl` compares a driver against a
baseline build (`-baseline-rev main`; the tier item `native-stack-bench`
on a macOS runner).

## Per-VM and per-thread runtime state

Several Vms of one compiled program may run at once, on threads of their
own (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md). A compiled program (its
machine code, its descriptor, `ProgramInfo` and the frame map, `Arc`-shared)
defines the environment; each Vm owns its instance of it -- heap, constants'
objects, statics, context area, roots, pending error -- and each OS thread
owns its native stack, its guard record and its thread-local runtime state
(callback transitions, the coroutine stack pool). Keep it so:

* The context area is the Vm's (`Vm::context_ptr`, `install_context_area`,
  zero when made, cleared by `reset`): generated code loads its base from the
  Vm at `VM_CONTEXT_OFFSET`, once in the entry block of a function that reads
  or writes the area (read-only, not `can_move`: Cranelift would sink a
  movable load back into loops), then the slot's constant offset. Never a data symbol, a process-wide or recycled buffer, a
  TLS base or a lookup; never an area per actor or coroutine. The layout and
  which implementation each requirement calls stay the program's: a Vm's
  construction selects nothing.
* Program metadata is the Vm's (`Vm::info`; ops.rs's `program(p)`): every
  runtime read of a shape, an enum, a native or a function's parameter names
  goes through the running Vm, and every renderer takes the program
  explicitly (`show`, `tcl_value`, `RtError::message`). Never a thread-local
  or process-wide current program, a swap per call, or the most recently
  made Vm's.
* A Vm stays on the thread that made it (its stack bounds, non-atomic
  backings, coroutine frames): never `Send` a Vm or its objects, never share
  a backing or a heap object between Vms, and never let thread-local state
  keep a Vm pointer past its transition (`callback.rs`'s ACTIVE) or a pooled
  coroutine stack its previous Vm (`prepare` writes the Vm per start).
* The guard's records are per thread (`records.rs`): a thread publishes only
  into its own (through a destructor-free thread-local holding its record's
  address; never a record cached in a Vm, whose guard may drop first), the
  handlers find a record by the faulting thread's token with atomic loads
  only (no thread-local, lock or allocation in a handler), and a record is
  released when its guard drops or its thread ends. A native stack overflow
  stays process-terminal: never end only the faulting thread, whatever its
  Vm's isolation.
* `botlish-native vms N` (main.rs's `concurrent_vms`) is a test harness, not
  a thread API: a Botlish program starts a thread with std::thread (next
  sections but several: Botlish-owned threads). Its collection hook
  and the heap's ownership check (`Heap::set_ownership_check`) are test
  hooks, None and off unless it sets them.

If you change any of that (vm.rs's context area or program, ops.rs's
`program`, show.rs, error.rs, platform/records.rs, guard.rs, windows.rs,
codegen/clif.rs's `context_addr`, the descriptor's context size, the harness),
run `tests/concurrent-vms.test` (also with `BOTLISH_NATIVE_GC_STRESS=1` set
for the whole file only when diagnosing: its GC-stress tests set it
themselves), `tests/contexts.test`, `tests/platform/aot-facts.tcl`,
`cargo test --release --manifest-path native/Cargo.toml --lib --bins` and
`--test native_stack`, `tests/native-library.test`, `tests/c-callbacks.test`
and `audit/per-thread-runtime/tools/mutate.tcl` (every mutant in its
`mutants.txt` that applies to the host must still apply and be killed by a
detector its `!!` line names: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the native
stack guard's checks above for a change to the guard. `bench/per-thread-runtime.tcl
-baseline BIN` compares the costs against a driver built before a change.

## Executable startup policy (worker, main-thread)

Which thread an executable runs its program on is a property of the
executable (MAIN-THREAD-STARTUP-MILESTONE-1.md), fixed when it is emitted --
main.tcl `-native-startup worker|main-thread`, `native::executable
-startup`, the driver's `--startup` -- and recorded in the program record's
`startup` word (`runtime::program::Startup`: 0 worker, 1 main-thread).
`worker`, the default and every target's, runs the program on a worker the
process's main thread starts and joins; `main-thread`, macOS AArch64's
only, runs the same body on the process's main thread and its stack, which
the link reserves (LC_MAIN, `-Wl,-stack_size,0x20000000`: 512 MiB, Apple
ld's arm64 maximum). Keep it so:

* The policy is the executable's: never chosen by an environment variable
  at launch, never inferred from a library, a framework, SDL3, a context, a
  coroutine or anything a program declares, and never a language
  annotation. It changes no semantic analysis, no HIR, no cache key.
* One body, one record: `runtime::aot::run` runs the same body on either
  thread (the Vm made on the thread that runs the program, the report, the
  snapshot, the guard, the program, the value or error); every linker's
  startup reads the record's policy before anything else
  (`aot::start_linked`, the stub's loader): never a second startup
  descriptor, a generated startup per policy, or a Vm made on one thread
  and moved to another. A panic of the body is "native executable panicked
  (NATIVE BUG)", status 1, under both policies (`catch_unwind` on the main
  thread). The record's layout is in the ABI fingerprint
  (`aotimage::abi_words`); an unknown word is refused, never the default.
* Refused before anything is written where unsupported
  (`codegen::aot::startup_refusal`, `codegen::target::main_thread_startup`,
  by the executable's target; the runtime's own `aot::MAIN_THREAD_STARTUP`
  agrees): `NATIVE UNSUPPORTED startup`, an existing executable kept, no
  linker run. Never substitute the worker silently. Linux's main thread has
  no confirmed guard (glibc reports none) and Windows' link.exe reserves
  1 MiB: a target joins only with its own discovery, reserve and
  acceptance.
* Nothing else changes: the JIT keeps its worker, a linked run (a program
  that calls C run by the driver) is always the worker's, a native library
  runs on its host's thread (its record's word is the worker's and ignored),
  the guard, the collector, coroutines and the C FFI are untouched, and no
  SDL, AppKit or event-loop code enters the runtime. The startup report
  ends in `startup`, `process-main-thread` and `stack` lines.

If you change the policy's representation (`Startup`, the record,
`linked_startup`), `aot::run`, `start_linked`, the link flags
(`startup_link_args`), the refusal, the driver's or the command line's
option, run `cargo test --release --manifest-path native/Cargo.toml --lib
-- aotimage program` and `--bin botlish-native -- aot:: target::`,
`tests/main-thread-startup.test` (also under `BOTLISH_NATIVE_GC_STRESS=1`),
`tests/system-linker.test`, `tests/aot-stub-linker.test`,
`tests/native-executable.test`, `tests/native-library.test`,
`tests/main-cli.test`, `tests/platform/native-status.tcl` and
`audit/native-aot/tools/mutate.tcl` and `audit/native-stack/tools/mutate.tcl`
(every mutant that applies to the host must still apply and be killed:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule; the `%% macos-aarch64` ones on macOS, the tier
items `native-aot-mutants` and `native-stack-mutants`), and push to read
macos-arm64.yml's `main-thread-startup` job: the policy through the
packaged application without the checkout, and the graphical census's
candidate A on it (`audit/macos-graphical-main-thread/tools/census.py
--strict`: SDL3's Cocoa driver, a window and Metal on the main thread,
every runtime probe, both linkers), every case as predicted.

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
GitHub Actions, `.github/workflows/macos-arm64.yml`: its smoke job on every
push to any branch (not documentation-only ones), the rest on every push to
main and when dispatched on a branch -- never on a shared development Mac,
and no acceptance depends on one.

* Every push runs Tier A on macOS (`smoke`: the host and its toolchains,
  Tcl 9.0.1 built from its pinned source by `tests/platform/setup-macos.sh`
  -- not Homebrew's newer Tcl, whose Unicode 17 case tables break the Tcl
  backends' Unicode 16 semantics -- `tests/platform/cabi-facts.tcl`, the
  native build and its Rust unit tests, `tests/platform/native-status.tcl`,
  `tests/platform/aot-facts.tcl` (the program object and an executable as
  the host's tools see them), `tests/platform/tier.tcl smoke`, the canary)
  and the same smoke on ubuntu as a control; a push to main and a
  dispatched run (`workflow_dispatch` on the branch) also Tier B
  (`tier.tcl acceptance`, six shards balanced by tests/canary.tsv's
  macOS costs: CI-RUNS.md, "Balanced shards"), the system linker and the
  application's jobs. Locally, `tclsh9.0 tests/platform/tier.tcl smoke`
  takes seconds, and `tier.tcl X.test Y.bot` runs any file or suite the
  way CI does.
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
  stack on a host that has native-frame roots (a native library's code,
  which runs where no guard of ours does, is the one exception: Native
  libraries, below); a host without the guard starts on the fallback plan.
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
* CI: `.github/workflows/windows-x86_64.yml` (windows-2025, production
  code, Tcl 9.0.1 built by `tests/platform/setup-windows.ps1`): the canary
  on every push; on a push to main and a dispatched run (`workflow_dispatch`
  on the branch) also the smoke job (the Rust tests, `native-status.tcl`, `aot-facts.tcl`'s
  COFF/PE checks and unwind information, C calls through link.exe and the
  C runtime matrix, `tests/platform/gc-workloads.tcl` under GC stress and
  under the unwind check, the 2048 executable, Windows I/O redirected by
  bash, cmd and PowerShell, dumpbin's headers and unwind information, the
  smoke tier and the Windows-relevant test files), the `roots` job (the
  fallback plan's Rust tests and GC workloads, `bench/root-plans.tcl`;
  `[ci-probes]` -- on a branch push too -- or a manual run adds
  `audit/windows-unwind`'s anchor probe)
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

## Android AArch64 (android-aarch64) and emitting for another target

android-aarch64 is a target of its own (ANDROID-AARCH64-TARGET-SUPPORT-
MILESTONE-1.md): Android on AArch64, Bionic's C library, the NDK's
`aarch64-linux-android` -- never linux-aarch64, whose instruction set, data
model and plain char it shares and whose C library, loader, system
libraries and runtime archive it does not. Its one artifact is a native
library, made on a Linux x86-64 host with the NDK and its target support
package. Keep it so:

* Emitting is not running: the driver emits machine code for another
  target only as a native library's object (`library --target TRIPLE`,
  `codegen::target::check_emit`): the program built for that target or for
  none, Cranelift's backend for its instruction set (the driver is built
  with `x86` and `arm64`), and the target's runtime with exactly the
  capabilities this driver's code generation reads from its own runtime
  (`runtime_capabilities` against `host_runtime`: frame roots, the stack
  guard, stack switching). Never run or JIT code of another target, never
  accept --target on another command, never emit for a target whose runtime
  the table does not state, and never let a host-only constant decide a
  target's code without that check.
* The runtime is Botlish's one runtime built for aarch64-linux-android
  (`tools/package.sh`): Android AArch64 joins Linux AArch64's platform layer,
  coroutine switch and frame walk where Bionic gives the same contract
  (pthread_getattr_np, POSIX signals, MAP_STACK); the Linux syscall
  transports stay Linux's. Never touch x18 (Android's shadow call stack),
  never assume a 4 KiB page, and never make a 2048-only runtime.
* A library of another target than the host's is linked with its target
  support package's runtime (schema 2: `artifacts`, `platform.minimumApi`,
  `runtime.relocation`, `toolchain`; native/support.tcl), never with the
  driver's own archive, by the toolchain the package declares as data (the
  NDK found through ANDROID_NDK_ROOT: nothing is searched). The compiler
  composes every argument (`LinkWithToolchain`: `--target=TRIPLE` + the
  minimum API, `-z defs`, `-z text`, 16 KiB segment alignment); a
  descriptor adds no flag, and its system libraries must equal the target's
  (`targetLibraries`). A missing toolchain is {NATIVE LIBRARY TOOLCHAIN},
  never a target support refusal.
* A library of another target resolves its link plan for that target's
  linker (the driver's `link-plan --target`, codegen::aot's
  `resolve_link_plan_for`; RN-HOST-STARTABLE-APPLICATION-LIBRARY-
  MILESTONE-1.md): that target's flavor and object format, a static
  archive holding its objects, a static library declared without a path
  searched in the -L directories only (never the host's toolchain
  directories). Never resolve another target's plan as the host's, drop it,
  or relax a host check (run, JIT) to make one pass.
* The shared object is checked from its bytes before it is reported
  (`ValidateShared`, native/elf.tcl): machine, type, alignment, no text
  relocation, no glibc symbol version, only the stated system libraries,
  exactly the public functions. A failed link leaves no earlier build's file
  under the new names. The manifest names the target and the package.
* No Android application knowledge in the compiler: no Activity, JNI
  generation, Gradle, APK, React Native, UI or event loop. The Android host
  under audit/android-aarch64-target/host is test infrastructure.

If you change any of that (codegen/target.rs's emission rules, codegen's
`isa_for_target`, codegen/library.rs's `supports`, the driver's --target,
native/library.tcl's toolchain link or `ValidateShared`, native/elf.tcl,
native/support.tcl's schema 2, the android row of core/cabi.tcl or
pm/target.tcl, the Android cfgs of the runtime), run
`tests/android-target.test` (its link half needs ANDROID_NDK_ROOT and the
Android runtime archive, `audit/android-aarch64-target/tools/package.sh`;
its execution half qemu-aarch64 and BOTLISH_ANDROID_ROOTS,
`tools/sysroot.sh`), `tests/target-model.test`, `tests/native-library.test`,
`tests/external-tools.test`, `cargo test --release --manifest-path
native/Cargo.toml --bin botlish-native target::` and
`audit/android-aarch64-target/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), and, after `single/build.sh`, its clean room
(`audit/android-aarch64-target/cleanroom/cleanroom.sh BOTLISH REPO NDK ROOTS
RESULTS`).

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
to the host must still apply and be killed), and on macOS (a `[ci-full]`
branch push with `CI-Tests: darwin-io.test ...`, or a dispatched run) the
darwin-io tests themselves.
`bench/darwin-io.tcl` (tier item `darwin-io-bench`) is the performance
report.

## Paths and the synchronous filesystem

Paths have two layers (WINDOWS-X86-64-MILESTONE-7.md): textual paths a
program writes (`std::linux::path::LinuxPath`, `std::windows::path::WindowsPath`,
`std::darwin::path::DarwinPath`: refinements of str, syntax only) and native
paths the system takes and returns (`std::PLATFORM::fs::NativePath`: Linux and
macOS bytes through `std::io::bytepath`, Windows UTF-16 code units held as
their UTF-16LE bytes: next section). The
portable layer is `std::io::fs` (FileError, OpenMode, EntryKind, the eager
trait FilePath); the platform layers are `std::linux::fs` (raw syscalls),
`std::windows::fs` (kernel32's wide functions) and `std::darwin::fs`
(libSystem). Keep it so:

* Never decode a native name lossily into a path: text from a native path is
  strict (`text`, else `std::io::path::NotText`), `display` is for people
  and never a path, and a portable listing fails with NotText rather than
  skip or misname an entry (the experiments: a lossy name opened another
  file). A native path is no `std::io::path::Path`.
* The path's type selects the filesystem: a witness's FilePath operations
  call its platform module, whose functions require its context; never
  select a filesystem at run time, add a dynamic dispatch, a fallback, or a
  context trait that chooses by installation.
* Windows paths are Win32's syntax (`PathKind`; one join for text and
  native paths): a bare drive designator joins without a separator, a
  verbatim path takes no `/`, `.`, `..` or empty component, any other no
  component ending with a period or a space; nothing is normalized and no
  filesystem observed. Every Win32 call is a wide function; never the ANSI
  code page, the C runtime or a POSIX layer.
* A File is opaque and affine (Windows: its HANDLE; Linux and macOS: a
  `std::io::fs::Owner`, the affine token only the standard library makes:
  the syscall side never names `std::ffi::c`); a failed read or write
  closes it, and the whole-file and directory operations close on every
  path. Ownership is not
  cleanup: never claim RAII. Short reads and writes are ordinary; completion
  continues after what the system reports, never restarts; no retry, no
  durability claim.
* Every failure is `FileError {reason, code}` with the system's code read
  right after the failed call (errno; `__error()`; GetLastError before
  any other call). Validation failures stay `NotAPath`.
* The Win32 and libSystem declarations are `private`; helpers of the
  platform modules are `private`; `of_valid_text` is an internal member
  (and std::abi::bytes's `utf16le_units`, std::windows::fs's units bridge).
* No watching, asynchronous I/O, event loop, metadata, links or renaming
  here (`fs-no-watchers`).

If you change any of that, or `std::abi::bytes::join`, `slice`,
`decode_utf8`, `encode_utf16le` or `decode_utf16le`, or the Linux path
syscalls, run `tests/filesystem.test` (its
Windows and macOS tests run on their hosts: the Windows workflow's smoke
and GC-stress steps, the macOS acceptance tier), `tests/linux-path.test`,
`tests/portable-io.test`, `tests/darwin-io.test`, `tests/windows-io.test`,
`tests/abi-bytes.test`, `audit/filesystem/tools/fuzz.tcl` (several seeds,
once with `-gc-stress 1`) and `audit/filesystem/tools/mutate.tcl` (every
mutant in its `mutants.txt` that applies to the host must still apply and
be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule; the `%% windows-x86_64` ones on
Windows, the tier item `filesystem-mutants`), and the warning gate.
`bench/filesystem.tcl` regenerates the performance table (`-baseline-rev
REV` against another revision, on the same machine).

## UTF-16LE on byte storage

`std::abi::bytes::encode_utf16le(text) -> Bytes` and
`decode_utf16le(data) -> str errors InvalidUtf16`
(UTF16-BYTE-STORAGE-MILESTONE-1.md) convert between a String and its
UTF-16LE bytes on the byte storage, platform-free, on every backend:
core/utf16text.tcl (Tcl's strict utf-16le) and native/src/runtime/ops.rs
(`rt_str_encode_utf16le`, `rt_bytes_decode_utf16le`: one allocation each,
no intermediate List or Rust String). std::windows::fs's NativePath holds
its units as those bytes. Keep it so:

* The format is UTF-16LE whatever the host: each unit's two bytes written
  and read explicitly, low byte first (`to_le_bytes`, `from_le_bytes`),
  never the payload reinterpreted as a `[u16]`. No byte-order mark (FF FE is
  U+FEFF: never detected, skipped or added), no terminator, no
  normalization; U+0000 is 00 00. Encoding is total.
* Decoding is strict: an odd byte count or an unpaired surrogate is the
  declared builtin error InvalidUtf16 (builtin error 13), never a
  replacement character or a panic. Never reuse InvalidUtf8 or
  std::io::path::NotText for it (the Windows path layer translates it to
  NotText), and never add a lossy public decoder, UTF-16BE, byte-order
  detection, code pages or a second string representation without a
  demonstrated need.
* A NativePath is its units' bytes, exactly (an unpaired surrogate
  included, no terminator): `text` is decode_utf16le, `display` the strict
  text or, for a name without one, the module's own lossy decoding (nothing
  but `display` calls it: never a path); the LPCWSTR of a Win32 call is the
  bytes and one NUL unit joined at the call boundary (`wide`), never stored.
  The path syntax reads the units through the internal
  `std::abi::bytes::utf16le_units` and stays the one statement of Win32's
  syntax: never a second parser over Strings.
* A listed name is measured in its find record by the internal
  `std::abi::bytes::utf16le_units_before_nul` (`std::byte_store::`'s, NIR
  `bytesutf16lenul`; UTF16-BYTE-STORAGE-MILESTONE-1.md, "Listing without a
  List"): the whole units of a byte range (pairs from its start, low byte
  first) before the first unit 0, all of them when there is none; the slice
  rule's declared errors, RANGE for an odd range, no allocation. A single
  00 byte, or 00 00 across two units, ends nothing. Keep it internal (never
  a public search or index of byte storage) and one rule in both runtimes
  (core/utf16text.tcl, ops.rs's `utf16le_units_before_nul`).

If you change any of that, run `tests/utf16-bytes.test`,
`tests/filesystem.test` (its Windows tests on Windows; `fs-windows-call-buffer`,
`fs-windows-entry-names` and `fs-windows-native-runtime` everywhere they
run), `tests/abi-bytes.test`,
`cargo test --release --manifest-path native/Cargo.toml --lib utf16le`,
`python3 -I audit/abi-bytes/tools/utf16-oracle.py selftest`,
`audit/abi-bytes/tools/utf16-fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/abi-bytes/tools/utf16-mutate.tcl` (every mutant in
`utf16-mutants.txt` must apply and be killed by the detector its `!!` line
names: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule; the tier item `utf16-mutants` on another
host), and the filesystem harnesses above. `bench/utf16-bytes.tcl` is the
performance report (`-baseline-rev REV`; the tier item `utf16-bench`).

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

An application of a parameterized struct is affine exactly when its fields,
its type arguments substituted, are
(AFFINE-PARAMETERIZED-APPLICATIONS-CORRECTNESS-MILESTONE-1.md):
`Box[Coroutine{...}]` of `struct Box[T]: value: T` is affine,
`Phantom[Coroutine{...}]` of `struct Phantom[T]: value: int` is not. Keep it
so:

* Never decide an application by its arguments ("any affine argument"), by
  its declaration's unsubstituted fields, or by a tree-, collection- or
  name-specific rule. `hir::structs::IsAffine ID ARGUMENTS` answers it from
  the declaration's summary (`AffinitySummary`: its affinity with every slot
  unrestricted and its relevant slots, a least fixpoint computed from
  `AppliedFieldTypes` and `hir::types::IsAffine`) and the application's own
  arguments. Keep the summary per declaration and an answer per whole
  application (`{ID ARGUMENTS}`), per registration (`ForgetAffinity`: every
  registry change clears both, and the drop descriptors derived from them);
  never an answer per declaration, never one computed while a summary is
  still provisional, and never unfold a recursive application to classify
  it.
* A walk of a struct type's components (drop descriptors) reads an
  application's applied fields and identifies a struct by its whole type,
  never by its declaration alone (`Box[Box[C]]`'s inner Box is another
  type). A recursive affine application is AFFINE-CONTAINER-UNSUPPORTED by
  the one declaration rule, judged by what its values own
  (`ApplicationIssue`; Recursive affine ownership, below), trees included.
* An affine application is never cut to `any` by a bound
  (`hir::types::MakeApplied`), as an affine List element is never cut.

A written application is the type the same application is inferred as
(WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md): an affine argument is an
argument like any other, and every position judges the application by its
affinity. Keep it so:

* Never reject a written application for an affine argument, and never let
  writing a type change what it is (`hir::resolve::ResolveApplied` builds
  the one canonical application). What makes a written application no type
  is `hir::structs::WrittenProblem`: a recursive affine application
  (`OwnedRecursion`), AFFINE-CONTAINER-UNSUPPORTED wherever it is written
  -- also as a phantom slot's argument. One that nests its affine argument
  in ever larger types (W[Coroutine{...}] of `next: List[W[List[T]]]`) is
  an ordinary type: every analysis of its components answers it from its
  declaration's summary (Declaration summaries, below). Never bring back a
  rejection of it.
* Imprinting reads where values of an argument exist:
  `hir::imprint::Occurrences` places an application's argument at its
  slot's positions (`hir::structs::SlotPositions`: the positions
  Occurrences gives the slot in the declaration's fields, a least fixpoint
  through `hir::structs::Fixpoint`, kept per registration and forgotten
  with the affinity facts). A variable is bound to an affine type only
  where no value of it exists (`Phantom[T]`, a pointee). Never take the
  affinity summary's relevant slots for positions (a struct affine by its
  own field holds values of its slots too; a function type's variable is a
  value position, as in a signature), never count a phantom slot as a value
  or a function type's variable as none.

If you change the affinity query (`hir/types.tcl`, `hir/structs.tcl`),
written applications' admission (`ResolveApplied`, `WrittenProblem`) or
slot positions (`SlotPositions`, `Occurrences`' application
case, `Placed`), `hir/affine.tcl`, contract-based call typing of
`Fn`/`Coroutine` callees
(`hir/types.tcl`'s `Call`, `hir/range.tcl`'s `VerifyStructuralCall`,
`hir/completions.tcl`), `hir::coroutines::ElaborateResumes`, the affine
specialization (`hir/traits.tcl`, `hir/semantic.tcl`'s affine instances,
`hir::signatures::CallableAdmits`), release or pending-temporary lowering in
any backend, or the drop runtimes (`core/affine.tcl`,
`native/src/runtime/affine.rs`), run `tests/affine.test`,
`tests/affine-applications.test`, `tests/written-affine-applications.test`,
`tests/coroutines.test`,
`audit/affine/tools/fuzz.tcl` (several seeds; its application programs,
`-applications N`, against their substitution oracle, and its written
programs, `-written N`),
`audit/affine/tools/mutate.tcl` and `audit/coroutines/tools/mutate.tcl`
(every mutant in both `mutants.txt` files must still apply and be killed;
the coroutine mutants of ownership and release edit `hir/affine.tcl` too).
A change to `hir::traits::Plan` for affine witnesses also means re-checking
the trait and context-trait mutants. A change to native drop or release
lowering also needs a `BOTLISH_NATIVE_GC_STRESS=1` run of
`tests/affine.test` and `tests/affine-applications.test` (its
`aa-native-nested-drop`: a scalar-replaced struct's opened affine field) and
`cargo test --release --manifest-path native/Cargo.toml --lib affine`. A
change to how an application's affinity is decided also runs
`tests/tree-struct.test`, `tests/trait-constrained-types.test` and their
mutation tools. `bench/affine.tcl` regenerates the
performance report. `hir::affine::verify` computes release scopes (and so
`AFFINE-PATH-RELEASE-UNSUPPORTED`) only for a program its whole-program
analysis accepts, a program-wide channel of the static decisions
(`hir/staticdeps.tcl`'s `C:verdict`, which lists that analysis's diagnostic
kinds): a change to that gate, to those kinds or to which joins can hold a
path-release diagnostic also needs `tests/static-economics.test` and the
static-decision harnesses (Static intrinsics, below).


## Declaration summaries (component analyses of parameterized types)

A parameterized nominal type is finite even where substituting its
arguments again and again is not: `struct W[T]: next: List[W[List[T]]]`
reaches W[C], W[List[C]], ... (PARAMETERIZED-DECLARATION-SUMMARIES-
MILESTONE-1.md). An analysis that answers for a value of a type from its
components -- Bearing, CarriedInto, Totality (HashClass, Hashable, the
total lowerings), SendClass, MentionsMutable, MayHoldVector, CanCarry,
the DecimalRounded guard, MutableComponent, ValueStability, the affinity
summary, the slot positions -- answers a named struct from its
declaration's summary (hir/summaries.tcl: one least fixpoint over the
declarations, `hir::summaries::Fixpoint`) and its own arguments' answers,
never by unfolding the application's fields. Keep it so:

* **Component analyses of parameterized nominal types must prefer
  declaration summaries over recursive substitution walks.** A new
  analysis that recursively unfolds applied struct fields
  (`hir::structs::AppliedFieldTypes` of what it meets, again and again)
  must justify, in its comment and in the report's census, why a finite
  declaration summary cannot express its result. Define it as a property
  of hir/summaries.tcl (`hir::summaries::define`: the classes algebra --
  levels joined over the slots' entries, one probe per class of argument
  -- or the union algebra), whose node is the walk of one declaration's
  applied fields, and read it with `Level` or `Union`.
* A property's classes are its own: what it reads at a slot position (a
  value held, a Fn argument type's `any`-ness, a callable's errors) decides
  its probes and its neutral argument. Never share one property's
  relevance or answers with another, and never assume one universal
  neutral.
* The summaries are facts of the registry: computed lazily, forgotten with
  the affinity facts (`hir::structs::ForgetAffinity` calls
  `hir::summaries::Forget`), never stored in HIR, interchange text or the
  cache, never keyed by a name.
* No depth limit or application count decides a semantic answer. The one
  bounded walk left in a migrated analysis is the reason text of a class
  that is not total (Totality, SendClass, MutableComponent,
  ValueStability): the class is the summary's; the walk follows field order
  and stops a non-uniform recursion grown twice (`hir::summaries::Whistle`,
  declarations on an expansive cycle only). Never decide a class by it.
  One question walks an application's parts once (`hir::summaries::Walk`;
  a later path reads that walk): never let a reason walk revisit an
  application once per path, which is exponential in a declaration with
  several recursive fields, and never keep a walk's result past its
  question.
* A genuine ownership rule is not a compiler guard: a recursive affine
  application stays AFFINE-CONTAINER-UNSUPPORTED (`OwnedRecursion`, next
  section).

If you change hir/summaries.tcl, a property's node, probes or classes, or
one of the analyses above, run `tests/parameterized-declaration-summaries.test`,
`tests/written-affine-applications.test`, `tests/hashable.test`,
`tests/value-identity.test`, `tests/typed-callable-escape.test`,
`tests/structural-contract-completions.test`, `tests/sendability.test`,
`tests/tree-struct.test`, `python3 -I audit/declaration-summaries/tools/oracle.py
selftest`, `audit/declaration-summaries/tools/fuzz.tcl` (several seeds; it
compares the compiler with the independent oracle and with the old walks,
audit/declaration-summaries/tools/reference.tcl, which
`extract-reference.py` regenerates from the revision before the summaries)
and `audit/declaration-summaries/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule), plus
the affine, tree-struct, value-identity and hashable mutation harnesses for
a change to code they mutate. `bench/declaration-summaries.tcl` regenerates
the scaling report.

## Recursive affine ownership (hir/ownership.tcl)

A recursive affine type -- one whose values nest affine values to any depth
through List, MutableVector or MutableArray elements -- has no finite drop
descriptor and is AFFINE-CONTAINER-UNSUPPORTED
(OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md). `hir::structs::
OwnedRecursion` asks `hir::ownership::Recursion`, which decides it on the
finite graph of declaration states (a declaration and which of its slots
hold affine arguments): through facts (which slots a declaration holds, by
fields alone or through an element: a least fixpoint), edges (the
applications a declaration's frame holds), the state graph's strongly
connected components; a type is recursive exactly when it reaches a
component with an internal edge that crosses an element. Keep it so:

* **Recursive affine ownership is decided from finite declaration-level
  ownership analysis. Do not determine it by recursively unfolding applied
  type terms or by a traversal depth or budget.** No depth, budget, type
  size or applied-type bound decides a verdict: a chain of a thousand
  finite affine declarations is accepted, and a recursion is found however
  deep it starts.
* **Non-uniform type growth is not itself invalid.** It matters only where
  the growing recurrence participates in actual value ownership: `next:
  List[W[List[T]]]` with no value of T held is unrestricted, `GrowA[T]`/
  `GrowB[T]` with T held is recursive. Never reject an application for
  growing, for being expansive (`hir::summaries::Expansive`), or for
  meeting its own declaration again through its arguments
  (`Box[List[Box[C]]]`, `Many[Many[C]]`: finite nesting); an application
  whose affinity dies out along its recursion (`Swap[int, C]` of `next:
  List[Swap[U, int]]`) is no recursion of affine values.
* A recursion of another declaration counts (`Holder[C]` of `t:
  Node[T]`): the verdict is any bad component reachable, the witness
  prefers one of the type's own declaration (its message wording). A
  declaration's own check (`apply`) reports a recursion that returns to
  it; one it only holds is its field type's application's
  (`VerifyDeclarations`, `ApplicationIssue`, which names an argument that
  is itself the recursive type first).
* A recursion through fields alone describes no finite value and is
  accepted; the drop descriptor walk cuts such a declaration where it meets
  it again (`hir::ownership::FieldCycle`), so every accepted type has a
  finite descriptor. Never let Descriptor decide recursion by failing or
  not ending; its assertion stays an internal error.
* The ownership edges are the drop descriptor's: struct fields (applied),
  anonymous struct fields, List, MutableVector and MutableArray elements, a
  refinement's base. A C pointer's pointee, a function or coroutine type's
  signature and an ImmutableSet are not edges. Never add an edge without
  the descriptor owning it.
* The facts are the registry's (`hir::ownership::Forget`, from
  `ForgetAffinity`), keyed by declaration identity, never stored in HIR,
  interchange text or the cache. A witness is built from the events'
  provenance after the verdict, along its own path only: never let a reason
  decide a verdict, and never instantiate a witness's growing arguments
  without its size cap (presentation only).

If you change hir/ownership.tcl, the descriptor's cut (hir/affine.tcl's
`DescriptorOf`), the struct checks that read it (`apply`,
`ApplicationIssue`, `WrittenProblem`, `RecursionMessage`) or the shared
fixpoint (`hir::summaries::Fixpoint`), run `tests/owned-recursion.test`,
`tests/affine-applications.test`, `tests/written-affine-applications.test`,
`tests/parameterized-declaration-summaries.test`, `tests/affine.test`,
`tests/tree-struct.test`, `python3 -I audit/owned-recursion/tools/oracle.py
selftest`, `audit/owned-recursion/tools/fuzz.tcl` (several seeds, with a
memory cap: `ulimit -v`; it compares the compiler with the independent
model and classifies every difference from the old walk,
audit/owned-recursion/tools/reference.tcl) and
`audit/owned-recursion/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the affine,
tree-struct and declaration-summaries mutation harnesses for a change to
code they mutate. `bench/owned-recursion.tcl` regenerates the scaling
report.

## The applied-type bound (hir/applied.tcl)

`aggregateDepth` / `appliedDepth` (hir/types.tcl) are precision and economy
bounds of the type lattice, not language validity limits
(APPLIED-TYPE-BOUND-PRECISION-MILESTONE-1.md): past `appliedDepth`
applications nested directly in arguments, `MakeApplied` keeps an
application's constructor and makes its arguments `any`, so that joins,
fixpoints, instance and memo keys stay finite. A part of a cut application
read back out of it is cut one application earlier than a value of that part
on its own; never check a value against it. Keep it so:

* Before using a bounded applied type to reject a declared construction,
  parameter, result or imprint, prefer the exact local declaration/value
  relationship when it is already available: a construction's field types
  are what its own field values or its written application establish
  (`hir::applied::VerifyConstruction`, `FieldExpected`), never
  `hir::types::StructField` of its own cut type; a projection of a value the
  program constructed reads the field value's type (`TypedProjection`);
  inference re-decides a bounded conflict or a constrained slot on the
  evidence (`TypedBinding`, `TypedIssue`).
* Never raise `appliedDepth` (or remove it) to make a program pass: the
  false rejection only moves deeper, and exact types in the HIR are
  quadratic (`atb-bound-unchanged`, the report's section 3). Precision is
  forgotten globally and cashed out locally: evidence lives in one typing
  walk's context (ctx `applied`) or one verification pass's memo
  (`hir::applied::Pass`), never in a HIR type, an interned type, an instance
  key or a side table; a written type the bound cut is recorded beside its
  bounded form (`exactParamTypes`, `exactResult`, `exactStructArgs`,
  `exactImprint`, the struct registry's `exactFields`), flat-encoded.
* Evidence comes only from what the program constructs (constructions,
  immutable aliases, projections, `if` branches) -- a slot no field
  establishes from its written argument -- never from a declaration of a
  value's position (a parameter read in its body stays its bounded type: not
  every way into a parameter is checked exactly). The exact layer only adds
  rejections: the bounded check of the value's HIR type runs first and
  decides every subtype, Range, refinement and kind question.
* No covariance (`App[int]` is no `App[any]`), no precision from `any`, no
  reading past a bounded part's horizon (`Parts`), no unfolding of a
  declaration (a constrained slot's class is the summaries' `Level` of its
  arguments' classes). Every walk of evidence is a loop over an explicit
  stack and no exact term is ever compared or keyed as a string.
* A deep difference is reported at the deepest construction inside the
  checked value whose slot it passes through (`Locate`), with the message
  the same at every depth; a program the bound cuts nothing of keeps its
  diagnostics byte for byte.

If you change `MakeApplied`, `Bound`, `hir/applied.tcl`, construction typing
or checking, imprint matching or the resolver's exact forms, run
`tests/applied-type-bound.test` (its deep generated specimens, 1000 deep),
`tests/depth-safe-nesting.test`, `tests/trait-constrained-types.test`,
`tests/affine-applications.test`, `tests/written-affine-applications.test`,
`python3 -I audit/applied-type-bound/tools/oracle.py selftest`,
`audit/applied-type-bound/tools/fuzz.tcl` (several seeds) and
`audit/applied-type-bound/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule).
`bench/applied-type-bound.tcl -baseline DIR` is the performance report.

## Resources (scope-bound cleanup)

`opaque resource struct R:` and `cleanup fn NAME(r: R, context ...):`
(LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md) make a value's
ownership operational: a resource is affine whatever its fields, and the
compiler calls its module's one cleanup function where its owner's lexical
scope ends -- at the end of the owning binding's sequence, never at its last
use -- and on every exit that leaves it (`hir::affine::Scoped`: the binding's
scope `last` is its sequence's end), in reverse acquisition order
(`OrderReleases`). A move transfers the obligation, the module's
destructuring discharges it, an explicit call of the cleanup is the early
release. The drop descriptor of a resource is `rK.` (entry K of the
program's cleanup table, hir/resources.tcl); the runtimes call the cleanup
(`affine#cleanup`, natively `cleanupcall` of the rooted cleanup block,
`affinedroprun` for an aggregate holding one). Where a suspending function
owns a resource (`hir::affine::Unwinds`, the HIR's `resources unwind`),
coroutine handles are scoped too and released by `coroutine#abandon`
(natively `coabandon`, descriptor `C`): the pending yield fails with the
internal `coroutine#abandoned`, which every suspension call's error edge
carries, so only the frames' release pads run. Keep it so:

* No general destructor: a resource is a module's opaque struct with exactly
  one cleanup, which takes it as its one ordinary parameter, declares no
  errors, returns unit, never yields, requires context structs only (never
  a context trait) and takes its parameter apart (RESOURCE-DECLARATION).
  Never add a destructor on another type, a drop trait, a per-value or
  run-time-chosen cleanup, `defer`, a finalizer, a reference count, a drop
  flag or any run-time ownership state; the collector never runs a cleanup.
* Lexical, not last use: never release a resource -- or, unwinding, a
  coroutine handle -- before its binding's sequence ends. A binding moved on
  some paths of a statement and kept on others is
  AFFINE-PATH-RELEASE-UNSUPPORTED, never released by a flag.
* The cleanup's context requirement is charged to every function that may
  release one (`hir::contexts::ReleaseEdges`; a value whose whole value is
  its function's result is exempt, `Returned`), so MISSING-CONTEXT reports a
  release where the context is not installed ("the release of this value").
* Release code runs with the pending error set aside and put back
  (native `preserving_pending`; the Tcl backends' handler-shaped catch), and
  a collection's drop roots what it took out while code runs (`drop_taken`).
  The plain drop forms stay allocation-free; the code-running ones are
  separate operations (`affinedroprun`, `mvcleardroprun`, ...), chosen by
  descriptor (NativeCallOp).
* Ordinary affine values keep last-use release: a program without resources
  is lowered as before (its HIR has no `resources` table).
* Scoping is a fact the static decisions read (Static intrinsics, below):
  a scoped binding's joins -- an `if` too -- are consumers of the ownership
  verdict (`hir::staticdeps::ScopedBy`, `PathJoins`), and whether the
  program unwinds is the waiting channel `C:unwind`. A new way for code to
  make a binding scoped, or for the program to unwind, goes into them.
* A cleanup is compiled where code that may release its resource is
  compiled, never because it is declared
  (NATIVE-UNUSED-CONTEXT-IMPORT-CORRECTNESS-MILESTONE-1.md): natively it is
  a value of each region whose release edges name it
  (`hir::contexts::releasedCleanups`, the edges the context analysis charges
  its requirement through; hir::specialize's `-releases`), and the cleanup
  table holds unit for one the program compiles nothing for
  (`LiveCleanups`, `CleanupTable`; the runtime refuses a unit entry). So a
  program that imports a module for its other declarations requires and
  loads none of its cleanups' contexts. Never root a cleanup
  unconditionally, never state a second "may release" rule beside
  `ReleaseEdges`, and never make an import compile by supplying, skipping or
  tolerating a load of a context the program does not install (the
  `UninstalledContext` NATIVE BUG stays the backstop).

If you change any of that (hir/resources.tcl, the resource cases of
hir/affine.tcl, hir/structs.tcl and hir/contexts.tcl, the cleanup and
abandonment runtimes in core/affine.tcl, core/coroutines.tcl,
native/src/runtime/{affine,coroutine,mutvec}.rs, native/lower.tcl's release
lowering, which cleanups native lowering compiles -- `releasedCleanups`,
hir/specialize.tcl's `ReleaseValues`, native/lower.tcl's `LiveCleanups`,
`LiveCleanup` and `CleanupTable` -- or std::event_loop's Owner), run
`tests/resources.test`, `tests/unused-context.test`,
`audit/unused-context-import/tools/mutate.tcl` (every mutant must still
apply and be killed by a test its `!!` line names),
`tests/event-loop.test` (its `el-owned-*`), `tests/event-loop-linux.test`
(`el-linux-owned`), `tests/affine.test`, `tests/coroutines.test`,
`audit/lexical-cleanup/tools/fuzz.tcl` (several seeds) and
`audit/lexical-cleanup/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule; run it in batches with
`-only` when the whole list would exceed a background task's limit), plus
the affine and coroutine harnesses for a change to `hir/affine.tcl`,
`tests/static-economics.test` and `audit/static-decisions/tools/mutate.tcl`
for a change to scoping or unwinding, and a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/resources.test` for a change to
the native release paths. `bench/lexical-cleanup.tcl` regenerates the
performance report.

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

## The event loop (std::event_loop)

`std::event_loop` (stdlib/event_loop.bot; EVENT-LOOP-MILESTONE-1.md) is one
thread-local scheduler of ordinary coroutines, written in ordinary Botlish
over MutableVectors, MutableArrays and the existing coroutines: tasks are
coroutines adopted by the opaque context `Loop`, and a driver is any
context implementing the context trait `std::event_loop::Driver` --
`std::event_loop::deterministic` (every backend) or the Linux package
`packages/event_loop_linux` (a C adapter over epoll and an eventfd, installed
into an application's `.bot_modules` by `tools/event-loop-linux.tcl
install`, which builds its archive there). Keep it so:

* No compiler, runtime or Tcl knowledge of the event loop: no native, NIR
  instruction, runtime object or syntax of it, and no promise, `async`,
  microtask queue or callback registry. The scheduler names no operating
  system: no descriptor, handle, epoll state or clock source in
  stdlib/event_loop.bot; native handles stay in a driver or its adapter.
* The application chooses the driver: only an entry program installs
  contexts. Never add a default driver, a runtime driver selection, or a way
  for a library to install, select or wrap one. A library that requires only
  the Loop (and an integration capability such as `event_loop_linux::Native`)
  can register, post, wait and revoke, never wait or turn the loop or drop
  its tasks: `run`, `turn`, `sync`, `shutdown` and `abandon` require the
  Driver.
* The turn is wait, collect (released holds, expired timers in (deadline,
  registration) order, at most `budget` records, round-robin over the
  driver's sources), dispatch (exactly the tasks ready when it begins, once
  each, FIFO) and observe (every observer registration live at its start,
  once, in registration order, only in a turn that collected or dispatched
  something). Never run work made ready during dispatch in the same turn,
  an observer twice in a turn or in an empty turn, and never let an
  observer, a channel or a timer nobody waits on keep the loop alive or
  awake.
* Revocation is generation-checked: a `Reg` is an identity, never an owner.
  A registration made by an `owned_*` operation has an `Owner`, a resource
  (Resources, below) whose cleanup `release` revokes it where the Owner's
  lexical scope ends (or explicitly); its Reg cannot revoke it (`revoke`
  answers false). Nothing else revokes implicitly -- never a drop action on
  a Reg, never one faked with last-use release -- and shutdown revokes every
  registration. Never deliver a record of an old generation, let a reused
  slot inherit events, or cancel a task as a side effect of revocation (an
  Owner's release wakes its waiters with Wake::Revoked and runs nothing
  else).
* Delivery is a registration's declared policy (Lossy, Coalesce, Reliable).
  Reliable never drops: a record without room is held by the driver
  (`hold_record`, `release_held`) and the backpressure reaches the producer
  (a full endpoint refuses posts with -EAGAIN). Never make a policy drop
  silently.
* An `IndexNotFound` of the scheduler's own tables is `SchedulerFault` (a
  scheduler bug, ending `run`), never an application error; a task's own
  failure is a recorded outcome that ends only that task.
* The native integration ABI (packages/event_loop_linux/native/
  botlish_event_loop.h, version 2: one loop per VM, named by a
  generation-checked handle; the version 1 functions reach the one open
  loop and are refused while several are, never routed to one of them; a
  loop closes with its driver or with the thread that opened it -- keep
  it so: no process-wide loop state): a post copies four scalars and never runs
  Botlish code; pumps run on the loop's thread inside the wait and never call
  Botlish. Never add a C-to-Botlish callback or a pointer in a record. A
  library that wakes the loop before its data is where its check can take it
  (SDL calls an event watch before it queues the event) announces what it
  woke for and keeps its prepare deadline near until check has taken it;
  never rely on the wake alone (`el-linux-sdl-hybrid-window`).
* The exploration's prototype (`audit/event-loop/src`) is evidence and the
  benchmark's baseline: never extend it or load it from production code.

If you change stdlib/event_loop.bot, stdlib/event_loop/deterministic.bot, the
Linux package, its C adapter or `examples/event-loop/`, run
`tests/event-loop.test` (on both passes, `CORE_BACKEND=interp` and
`compile`; directly, all four backends), `tests/event-loop-linux.test` (real
epoll, sockets and threads; its SDL3 tests need `tclsh9.0
tests/cffi/sdl3.tcl` and are skipped without it), `tests/context-traits.test`,
`tests/coroutines.test`, the warning gate (both modules are in its
manifest), `tools/compilerpedia.tcl generate` and `check`, and
`audit/event-loop/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule). `bench/event-loop.tcl` is
the performance report against the prototype.

## Same-thread actors (std::actor)

`std::actor` (stdlib/actor.bot; SAME-THREAD-ACTORS-MILESTONE-1.md) is
ordinary Botlish over `std::event_loop`: an actor is one ordinary
coroutine, hosted by a task the library adopts into the loop (`start`),
with typed mailboxes in the application-installed context `Actors`.
Communicating takes no context: `listen`, `receive`, `try_receive`, `send`,
`deliver` and `pause` are requests the actor's coroutine yields to its host
(protocol `resume Answer`, outward `Exit`), which performs them with the
Loop and Actors and resumes it with the answer. So an actor constructed
inside `inject no context:` receives and replies, and the compiler's own
requirement analysis proves it needs nothing. Keep it so:

* The actor-side operations require no context, ever (`actor-authority-
  requirements` pins them): never give `receive`, `send` or `listen` a
  context parameter, never make an actor hold the Loop or Actors to talk,
  and never replace the protocol with a context trait. What needs the
  scheduler's authority (open, start, post, close, drain, reap, stats,
  `sleep`'s timer) requires it, and stays the supervisor's.
* Restriction is construction's: an actor's authority is what its
  construction's inject block (or its constructor) had. Never claim `start`
  restricts anything, and never resume an actor inside an inject block (the
  host resumes it outside every block).
* Messages cross the non-generic mailbox table and protocol as `any` and are
  recovered with the one internal intrinsic `std::actor::recover[M]`
  (core/actor.tcl: the identity), called only by `recovered`, after
  checking that the answer carries the identity (slot, generation) of the
  receiver's own mailbox (`actor-source-recover`). Never call it anywhere
  else, never make it public, never add a second unchecked conversion, and
  never let an Answer carry a message of another mailbox.
* `Inbox[M]` is affine (an opaque token holding a null C pointer, as
  `std::io::fs::Owner`); `listen` consumes it and binds the mailbox to the
  actor's task for good, and a host serves only its own actor's bound
  mailboxes (a copied `Receiver` receives nothing elsewhere). `Address[M]`
  is unrestricted and send-only. Identity is (slot, generation): a close
  keeps the generation (Closed), a reuse bumps it (Stale), each mailbox
  incarnation has its own wake and room channels.
* Lifecycle: a host retires its actor (closes its mailboxes, counting what
  was queued undelivered, waking its room waiters with Closed) when the
  actor returns or fails, before its task ends with the actor's outcome;
  `reap` closes what the loop abandoned (`std::event_loop::owned?`). The
  library never consumes `take_outcomes`, keeps no scheduler of its own, and
  takes at most one message per actor per dispatch.
* Backpressure is event-driven: a full mailbox answers Full, `deliver`
  waits on the mailbox's room channel, each freed place wakes one waiting
  sender in FIFO order, a sender that did not wait cannot overtake one that
  does, and nothing ever polls a timer. Never drop an actor message.
* No native, NIR instruction, runtime object or Tcl runtime of actors:
  `std::actor::recover` (`same` in native/lower.tcl) is the whole compiler
  side (`actor-source-ordinary`). No OS threads, sendability, actor-local
  installation or runtime permission check here: the cross-thread transport
  is std::actor::remote's (Botlish-owned threads, below), which reaches an
  actor through its ordinary mailbox.

If you change stdlib/actor.bot, core/actor.tcl, the `same` lowering or
`std::event_loop::owned?`, run `tests/actor.test` (on both passes,
`CORE_BACKEND=interp` and `compile`; directly, all four backends; also under
`BOTLISH_NATIVE_GC_STRESS=1`), `tests/event-loop.test`,
`tests/restricted-injection.test`, `tests/coroutines.test`,
`tests/affine.test`, the warning gate, `tools/compilerpedia.tcl generate`
and `check`, and `audit/actor/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule). `bench/actor.tcl` is the performance report
against the census's Probe F.

## Sendability and the cross-VM value transfer (std::transfer)

`Sendable` (SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md) is the third
intrinsic trait (hir/traits.tcl's intrinsics, beside Hashable and
Equatable): a type is a witness when every value of it can be
reconstructed, with the same meaning, in another Botlish VM that shares
nothing with this one (`hir::types::SendClass`, with Totality's three
classes and reason paths). `std::transfer::encode(v)` writes such a value
into owned Bytes and `std::transfer::decode[T](data)` rebuilds a T in this
VM; both are written out after the checks (`hir::transfer::Elaborate`) as
`transfer#encode`/`transfer#decode` carrying the type's *schema*
(hir/transfer.tcl), which the Tcl codec (core/transfer.tcl) and the native
one (native/src/runtime/transfer.rs) read. Keep it so:

* Sendability is derived from checked types, never declared by a caller:
  no impl, registration or name makes a type Sendable. The one exception is
  an opaque struct's owner statement, its declaration's `sendable` clause
  (`fields`, `through(TO, FROM) as R`; the standard library's byte
  storage's `bytes(F)`/`mutable_bytes(F)`), whose parts the compiler checks
  (`hir::structs::ValidateSendable`, `ValidateSendableParts`,
  `hir::transfer::verifyDeclarations`). Never let an opaque struct without
  a clause be judged by its fields (a Reg's slot and generation are two
  Ints), never accept `any` (a clause over an `any` field is
  SENDABLE-DECLARATION), and never let one declaration make every
  application of a generic type sendable: an application is judged with
  its own arguments.
* Not sendable, ever: functions, coroutine handles and every affine value,
  C pointers and native views or edits, context structs (authority),
  refinements (a proof of this program), VM-relative identities
  (std::event_loop::Reg, std::actor's Address, Inbox and Receiver), `any`.
  Affinity is not sendability; never add an affine move between VMs here.
* The bytes hold no address, no shape or enum number and no Rc backing:
  values by canonical names (the schema's fingerprint, fields and enum
  cases sorted), every object rebuilt by the receiver's own constructors,
  a map's or set's derived state recomputed under the receiver's
  table-hash key (`through`). Never copy stored hashes, an index or a
  header between VMs, and never key compatibility by a program-relative
  number.
* Decoding never trusts the bytes: bounded reads, checked arithmetic, every
  value validated against the receiver's schema (domains, UTF-8, finite
  Float64, enum indices, stated lengths), declared errors (TransferMalformed,
  TransferVersion, TransferTypeMismatch, TransferInvalidValue,
  TransferLimit) and never a panic or NATIVE BUG; both directions iterative.
* The two codecs write the same bytes: change the format in both, with the
  version and tests/value-transfer.test's fixed vectors.
* A transfer's type is closed where it is compiled (TRANSFER-OPEN-TYPE
  otherwise), never a run-time schema guessed from a value. A body that
  transfers an imprint variable its signature's struct slot constrains to
  Sendable is planned per binding of it (`hir::traits::SelectingBinding`,
  `SendsVariable`: BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-
  MILESTONE-1.md), and a `Sendable` trait view per witness, before
  `hir::transfer::Elaborate` runs: each copy writes its closed schema.
  decode of a trait view stays TRANSFER-OPEN-TYPE.
* std::actor's same-VM messages stay ordinary values: never require
  Sendable of them.

If you change any of that (SendClass, the clause, `-sending`,
hir/transfer.tcl, either codec, the owners' TO and FROM functions), run
`tests/sendability.test`, `tests/value-transfer.test` (also under
`BOTLISH_NATIVE_GC_STRESS=1`), `cargo test --release --manifest-path
native/Cargo.toml --lib transfer`, `tools/compilerpedia.tcl check` and
`audit/value-transfer/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed by a detector its `!!` line names: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), plus the trait, Hashable and collection harnesses for a
change to code they share. `bench/value-transfer.tcl` is the performance
report.

## Botlish-owned threads and the cross-thread transport (std::thread, std::actor::remote)

A `thread fn NAME(init: I) -> R:` of a module is a thread entry
(BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md);
`std::thread::start(std::thread::entry(NAME), init)` runs it on an OS thread
of its own in a VM of its own, made on that thread from the program's one
image (native/src/runtime/thread.rs, the program function's dispatch in
native/lower.tcl). `std::actor::remote` carries typed messages and calls
between VMs as transfer bytes. Keep it so:

* One image, one HIR, one selection: an entry is a block of the program
  (`threadEntry`), compiled with every other; never a second compilation,
  program or image per entry. The selection of each context trait is the
  program's for every VM (CONTEXT-TRAIT-SELECTION-CONFLICT); each VM
  installs its own instances in its entry's body, checked flow-sensitively
  as the entry program's top level (hir/contexts.tcl's `entries`). Never
  give a worker its creator's contexts, a context parameter or a context
  in its initialization value, and never select per entry.
* An entry is named only as std::thread::entry's argument
  (THREAD-ENTRY-REFERENCE), declared at a module's top level
  (THREAD-ENTRY-PLACEMENT), with one closed sendable parameter and result
  (THREAD-ENTRY-SIGNATURE), environment-free and never suspending
  (THREAD-ENTRY-ENVIRONMENT). It requires nothing of a caller; its calls are
  its own obligations.
* Starting needs the Threads context; a start reserves a guard record
  before the thread exists (records.rs's `reserve`, `claim_as`): beyond the
  64 records it is ThreadLimit, never an unguarded thread. A Vm is made,
  run and dropped on its own thread (never Send); nothing of a heap crosses
  threads -- outcomes and messages are byte vectors, rebuilt by the
  receiving VM's constructors. A native fault on any thread stays
  process-terminal.
* Stopping is cooperative (a flag and a port notification): never kill,
  interrupt or detach a running thread's VM from under it. A join of an
  ended thread joins its OS thread (its exit's cleanup done). At the main
  VM's end every thread is asked to stop and joined within a bound
  (BOTLISH_THREAD_EXIT_JOIN_US); one still running keeps the image alive.
* The transport: every message's schema fingerprint checked against its
  endpoint's; endpoints and calls named by (domain, slot, generation, a
  random key); bounded queues; a freed place granted to the first waiting
  sender and held for its retry (never refuse a granted waiter, never let
  anyone overtake one); no polling anywhere -- a producer pushes then
  rings, the consumer resets before its last look. One mutex for the
  transport's tables, never held while Botlish code runs.
* Capabilities (Remote, Service, Reply) are opaque and sendable through
  their Identity; the rebuild functions (`*_in`) are internal members
  (core/transfer.tcl): never make one public or add a constructor of a
  capability from an Identity. std::actor::Address stays unsendable.
* A call completes once: with its reply, Undelivered (its endpoint closed
  with it queued) or ServiceEnded (its service's VM ended owing it); a
  second, late or unknown answer is Stale. Never leave a call waiting
  because its service went.
* The Tcl backends refuse a program that names an entry at lowering
  (BACKEND THREAD-UNAVAILABLE) and every runtime operation when reached
  (CORE SEMANTIC THREAD-UNAVAILABLE): never emulate threads there.

If you change hir/threads.tcl, the entry cases of hir/contexts.tcl,
hir/traits.tcl's Sendable selection, core/thread.tcl, the thread dispatch
or entry roots in native/lower.tcl, native/src/runtime/thread.rs, the guard
reservation (records.rs), stdlib/thread.bot, stdlib/actor/remote.bot,
std::actor's post_waiting, or event_loop_linux's per-loop state, run
`tests/threads.test` (its transport, ABI and broker tests need Linux, cc
and ar; the GC-stress ones run inside it), `cargo test --release
--manifest-path native/Cargo.toml --lib runtime::thread`,
`tests/sendability.test`, `tests/contexts.test`, `tests/actor.test`,
`tests/event-loop-linux.test`, `tests/concurrent-vms.test` and
`audit/threads/tools/mutate.tcl` (every mutant in its `mutants.txt` that
applies to the host must still apply and be killed by a detector its `!!`
line names: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), plus the per-thread runtime and
event-loop harnesses for a change to code they share.
`bench/threads.tcl` is the performance report.

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

## Character classes of a UnicodeChar

`std::char::is_tcl_alpha` and `std::char::is_tcl_alnum`
(UNICODECHAR-CLASSIFIERS.md) are the classes of `std::str::is_tcl_alpha` and
`std::str::is_tcl_alnum` (NATIVE-TCL-UNICODE.md), for a UnicodeChar. Keep it
so:

* One classification per class in each implementation, shared by both
  forms: core/tclcompat.tcl's `Classify`, ops.rs's `tcl_alpha_char` and
  `tcl_alnum_char`. Never a second table, and never a class that differs
  between the String and the character form.
* Total and allocation-free: no RANGE case, no `-runtime` tag,
  `-context-free 1`. Generated code classifies an ASCII scalar inline
  (A-Z and a-z, and 0-9 for alnum: codegen::clif's `CharIsTclAlpha`) and
  calls the helper for every other scalar. Never widen the inline rule past
  ASCII without the tables' proof.

If you change them or `std::web::emailish?`, run what
UNICODECHAR-CLASSIFIERS.md's "What to run when changing this" lists:
`tests/native-tcl-unicode.test`, the golden suite unicode-strings.bot, the
Rust tests `char_classifiers` and `inline_ascii_rule`, and
`audit/char-classifiers/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule). A
change to stdlib/web.bot also runs the warning gate, its probes and
`expect.tcl`.

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

### Payload-bearing cases

A case may declare a named-field payload, `Add {left: int, right: int},`,
constructed `Enum::Case {field: value, ...}` with every field exactly once
(PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md). Its value has the enum's type;
its identity is still (enum, case), its payload part of its value. Keep it
so:

* One construct: never a second tagged-union kind, a union layout, a
  positional case, a constructor function (a payload-free case stays a
  value: `E::C {}` is ENUM-PAYLOAD-UNEXPECTED; a payload-bearing case alone
  is ENUM-PAYLOAD-REQUIRED), a default field, a case type, a discriminant,
  an ordinal or a layout guarantee. A construction is an ordinary call of
  the internal root native `enum#case(PAYLOAD, "ID", "CASE")`
  (hir/resolve.tcl's CaseConstruction) whose payload is an anonymous struct
  checked like an error payload (`casePayloadOf`, VerifyCasePayload): never
  add a HIR node kind for it, and never let any other code call enum#case.
* Equality, hashing and rendering read (enum, case, payload), the payload by
  field name (never declaration or construction order); a payload-free
  case's hash, word and rendering are unchanged. Change core/value.tcl,
  core/hashing.tcl and ops.rs together.
* Representation is the backend's: natively a payload-free case stays an
  immediate word (also in an enum with payload-bearing cases) and a
  payload-bearing value is one EnumCaseObj (KIND_ENUMCASE) holding its
  payload; `enumeq` only for operands statically of payload-free enums
  (`hir::enums::IsPayloadFree`). Never box a payload-free case, read a word
  as a discriminant, or expose either.
* Every analysis that answers for a value from its components walks an
  enum's payloads (affinity, Totality, Sendable -- refused for payload enums
  until a transfer encoding exists --, MentionsMutable, MayHoldVector,
  Bearing, CarriedInto, CanCarry, MutableComponent, the DecimalRounded
  guard, privacy), an enum met again adding nothing; a new component
  analysis does too. An affine enum's values are released by a descriptor
  naming cases by their hexadecimal UTF-8 names (`e N.(K.HEX D)*`, never a
  position, never the letters `r`/`C`), and a recursive affine enum is
  AFFINE-CONTAINER-UNSUPPORTED (hir::enums::VerifyRecursion).
* A boundary that commits to a representation refuses a payload enum with
  its reason (C UNSUPPORTED, EXPORT-SIGNATURE, NOT-SENDABLE, a context
  struct's native layout); never emit a guessed one.

If you change any of that (hir/enums.tcl's payload section, CaseConstruction,
core/enums.tcl, the enum cases of core/value.tcl, core/hashing.tcl,
core/affine.tcl, core/mutvec.tcl, native/lower.tcl's EnumCaseValue and
ImmediateEnum, runtime/{value,heap,ops,show,affine,mutvec}.rs, the
component analyses' enum cases, HIR text's `enumcase` lines), run
`tests/payload-enums.test`, `tests/enums.test`, `audit/payload-enums/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/payload-enums/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), `cargo test --release --manifest-path native/Cargo.toml --lib
enum`, the enum, affine and declaration-summary harnesses for code they
share, and `tclsh9.0 tests/local.tcl tests/golden/structs-and-enums.bot`.

### Exhaustive match

`match VALUE:` with one `case Enum::Case:` arm per case
(PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md) selects the arm of the
value's case; the arm receives the payload whole (`case E::C p:`),
destructured (`case E::C {a, b: c}:`, struct destructuring's pattern) or
not at all. It is no node kind: surface/lower.tcl's Match writes an `if
true:` block (carrying `match`) binding the scrutinee once to a hygienic
`match#N`, then an `if` per arm testing the internal root native
`enum#is(match#N, "ID", "CASE")`, whose then-branch first binds
`enum#payload(match#N, "ID", "CASE")`, ending in `enum#unmatched()`;
hir/resolve.tcl's MatchSyntax resolves each arm's written case name as a
case expression's qualifier is. Keep it so:

* Exhaustiveness is proven, never tested at run time: hir/match.tcl holds
  every match to the scrutinee's statically known enum (TYPE for `any`, a
  non-enum, another enum's case), each case named exactly once
  (MATCH-DUPLICATE-CASE) and every declared case named
  (MATCH-NOT-EXHAUSTIVE, against EnumCases(E), never what an analysis
  knows of the value). Never add a wildcard, default, guard, alternative,
  literal, positional or nested-enum pattern, a dynamic type test or a
  fallback arm, and never let an exact-case fact excuse an arm.
* Selection reads the case's identity (enum, case) only: never `==`, a
  hash, a payload or a position (a payload holding a function, a mutable
  collection or an affine value is matched the same). enum#is observes the
  scrutinee; enum#payload moves it -- every arm takes the payload, so an
  affine scrutinee is moved on every path (a resource's included) and what
  an arm does not bind is released by its owner. Never make a selection
  consume, or an arm skip its payload.
* A payload is taken only under its own selection: the chain's shape
  (hir::match::chain) is checked in every compilation (MATCH-INVALID, the
  compiler's own failure) and again by every reader of HIR it did not
  build (hir/read.tcl, hir::interchange::decode: HIR PARSE, HIR
  INTERCHANGE MATCH), and enum#payload checks the identity at run time on
  every backend (UNMATCHED, never another case's payload). Never trust a
  match's exhaustiveness from text, and never add a public payload or
  discriminant accessor.
* The ownership analysis treats a branch of a constant condition (the root
  `true`/`false` a front end writes for a block) as never taken
  (hir::affine::ConstantCondition): a match's block always runs. Never
  widen that to a value an analysis decided.
* `match` and `case` are contextual words (surface/parser.tcl's AtMatch;
  `case` only as an arm's first word): `match = 1` and `case(name, check)`
  stay ordinary code. A match is a statement or the value of a binding,
  return or destructuring, like an if.
* Representation is the backends': natively `enumeq` with the case's word
  for an enum without payload-bearing cases (no payload operation: unit),
  `op enumis`/`op enumpayload` otherwise; the C backend compiles payload-
  free matches only, as it compiles payload-free enums only.

If you change any of that (the parser's Match, AtMatch, MatchCaseName,
surface/lower.tcl's Match, MatchSyntax and MatchSelection, hir/match.tcl,
the `enum-test`/`enum-payload` cases of hir/types.tcl and hir/callables.tcl,
core/enums.tcl's selections, `ConstantCondition`, native/lower.tcl's
EnumSelection, nir.rs's EnumIs/EnumPayload/EnumUnmatched, ops.rs's
rt_enum_is/rt_enum_payload, ccompile's selections, the HIR text's `if
match`), run `tests/exhaustive-match.test` (also with
`BOTLISH_SEMANTIC_ROLLBACK_AUDIT=1`), its golden suite (`tclsh9.0
tests/local.tcl tests/golden/exhaustive-match.bot`), `tests/payload-enums.test`,
`tests/enums.test`, `audit/exhaustive-match/tools/fuzz.tcl` (several seeds,
once with `-gc-stress 1`), `audit/exhaustive-match/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), `cargo test --release --manifest-path native/Cargo.toml
--lib enum`, plus the affine and coroutine harnesses for a change to
hir/affine.tcl and `tools/compilerpedia.tcl check` for a diagnostic.
`audit/mid-end-port/tools/kernel.tcl` compares the payload-enum kernel
(kernel/ranges-enums.bot) with the other five; `bench/exhaustive-match.tcl`
is the performance report.

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

### Consumed fold intermediates

A fold's intermediate holding a collection is consumed like a directly
called function's parameter -- no entry copy, the carried header mutated in
place -- only where no `continue` or bare `break` of its fold can run after
the iteration may have given the header away
(CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md; hir/mutvec.tcl's
`FoldExitsClean`, `FoldWalk`, `GivesHeader`, `FoldIncoming`). Keep it so:

* An exit after a give-away keeps the entry copy: such an exit carries the
  iteration's starting value (FOLD-LOOPS-MILESTONE-1.md, rules 5 and 6),
  which only the copy keeps. The give-aways are the convention's own facts
  (`PlaceArgument`, `ByReference`, `NoLaterUse`): never decide one by an
  operation's or a function's name, and never stop the walk short (an
  `if`'s branches join, a handler starts after any part of its call, an
  inner loop's body repeats).
* Every value a consumed fold binds its intermediate to -- its initial
  value, each normal completion -- is an exclusive position, wrapped in a
  share unless fresh or a move: never let one alias a live binding.
* It is an optimization: no diagnostic, rule or proof changes, no runtime
  state and no backend special case. `hir::mutvec::consumedFolds 0` is the
  copying elaboration, the tests' and the fuzzer's oracle (a front-end
  input: `surface::cache::Key`); never set it outside tests.

If you change any of that, or the copy convention it joins (`Eligible`,
`ExclusivePositions`, `Fresh`, `NoLaterUse`, `Moved`), run
`tests/consumed-fold-intermediates.test`, `tests/fold-loops.test`,
`tests/mutable-vector.test`, `audit/consumed-folds/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`) and `audit/consumed-folds/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed by a test
its `!!` line names: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule). `bench/consumed-folds.tcl`
is the performance report.

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

## Value parameters are never mutated (NONPLACE-PARAMETER-MUTATION)

A function's parameter not declared `place` is a value: the function's
own logical copy of its argument (NONPLACE-PARAMETER-MUTATION-CORRECTNESS-
MILESTONE-1.md). A mutation whose destination is rooted in one -- a
collection operation's receiver path, or the argument of another
function's place parameter (std::mutable_map's and std::mutable_set's
operations among them) -- is NONPLACE-PARAMETER-MUTATION, the call's own
problem (`hir::CheckingCall`), at the mutation, relating the parameter's
declaration (`hir::mutvec::IsValueParam`, `ValueParamMutation`, their two
uses in `hir::mutvec::verify`). Keep it so:

* The rule reads the destination's root binding only: a parameter of a
  function block (its `params`) that is not one of its `places`. Never
  read whether the parameter is returned or used later, its type, its
  callers, a name or an operation's spelling; never exempt an untyped, an
  imprinted, an affine or a nested function's parameter, a field path or a
  call through method syntax.
* A local is a place of its own whatever it was bound from: `w = v`, a
  field's copy, a destructured field are independent logical copies, and
  mutating them is legal. Never taint a value by its origin, and never
  turn the local copy into an alias (`hir::mutvec::Moved` moves a header
  only out of a binding the copy convention holds; a parameter of a
  function also called through a value never is).
* A context parameter, a loop variable, a fold's intermediate and a
  handler's payload binding are no value parameters (their scope is a
  construct's, or they are locals bound to the installed context).
* An error, never a warning or a lint; checked before any backend; no
  runtime check, no backend special case. The existing receiver rules
  (MUTABLE-PLACE-RECEIVER: a temporary, an enclosing function's binding, a
  module binding) report first.
* The fix is the program's: `place` for the caller's storage, a local copy
  for a local working value. Never recommend `place` for an affine
  parameter (a place parameter is never affine).

If you change any of that (hir/mutvec.tcl's value parameters or receiver
and place-argument checks, what a place path is, the copy convention's
`Moved`), run `tests/nonplace-parameter-mutation.test`, its golden suite
(`tclsh9.0 tests/local.tcl tests/golden/nonplace-parameter-mutation.bot`),
`tests/place-parameters.test`, `tests/mutable-vector.test`,
`tests/mutable-array.test`, `audit/mutable-vector/tools/fuzz.tcl` and
`audit/mutable-array/tools/fuzz.tcl` (several seeds: their
`valueparam` faults), and `audit/nonplace-parameter-mutation/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed by a
test its `!!` line names: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), plus the vector, array
and map harnesses (MutableVector, MutableArray, MutableMap above) for a
change to code they share. `tools/compilerpedia.tcl check` keeps the
topic (`error.nonplace-parameter-mutation`) and its examples true.

## Collection order and relational facts

`m.reorder(order)` and `s.reorder(order)` (PROVEN-COLLECTION-REORDERING.md)
replace a MutableMap's or MutableSet's iteration order and nothing else;
the order is a MutableSet holding exactly the collection's members, and
the compiler must know it at the call: the relational fact
SameMembers(order, m), proven by `hir/relations.tcl` (REORDER-NOT-PROVEN
otherwise). Keep it so:

* Order is not content: a reorder keeps every association (a map's stored
  key, its value, its stored hash), the length and the membership, and
  never adds content equality or a content hash to either collection.
  The arrangement is total (`complete`): a reorder run despite its
  diagnostic (a lenient build) still changes no content.
* The reorder trusts its proof: no run-time membership check in it, no
  OrderMismatch from it, no keyed hash computed again (it moves the stored
  hashes; the index keeps its slot count and is rebuilt from them). The
  permutation is ordinary Botlish in std::ordered_table, shared by both
  collections: no native, NIR instruction or runtime operation of it.
* The fact is relational, never a type: no scalar refinement, dependent
  type (`OrderOf[m]`), source-level `ensures`/`requires`, theorem
  language or runtime tag carries it. It comes only from the operations'
  contracts in `hir::relations`'s table (by declaration identity: `mints`,
  `requires`, `preserves`), never from a function's body, a name or a
  length; nothing crosses a function boundary but by a contract.
* The analysis is conservative and flow-sensitive: a membership change of
  either value -- a place argument of any call but a contract's
  `preserves`, a context member at any call that may change the installed
  context (`hir::cardinality::ContextSite`) -- loses the fact; a join
  keeps it exactly when every completing path proves it (places that
  shared a token on every path share one after: `JoinState`), a loop
  kills what its body may change on entry and after it. Never add an
  optimistic join, a length rule or a subset rule.
* REORDER-NOT-PROVEN has no call `subject` (it never steers a method
  decision) and is owned by an earlier rejection of its call or an
  argument (`hir::recovery::OwnedPositions`: no cascade after a type
  error).
* `std::mutable_set::table_of` and `of_table` are internal members
  (`core::native::declareInternalMember`, `nomethod`): std::mutable_map's
  access to a set's table, never API.

If you change `hir/relations.tcl`, its contracts, the order operations or
the engine's `count_shared`/`same_members?`/`arrangement`/`complete`/
`permute`/`permute_values`/`reindex`, run `tests/collection-reorder.test`,
`tests/ordered-table.test`, `tests/mutable-map.test`,
`tests/mutable-set.test`, the golden suite (`tclsh9.0 tests/local.tcl
tests/golden/collection-reorder.bot`), `python3 -I
audit/mutable-map/tools/oracle.py selftest`,
`audit/mutable-map/tools/fuzz.tcl` (several seeds; reorders are on by
default, `-reorders PERCENT`), `audit/collection-reorder/tools/proofs.tcl`
(several seeds: the compiler against an independent model of the rules
and against the programs' runs) and `audit/collection-reorder/tools/
mutate.tcl` (every mutant in its `mutants.txt` must still apply and be
killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), plus the collections' harnesses
(above) for a change to the engine. `bench/collection-reorder.tcl`
regenerates the performance report.

## Semantic value identity and ImmutableMap

An opaque struct may declare its identity apart from its representation
(REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md): `identity members(F)` (the
elements of List field F, in no order) or `identity associations(K, V)`
(the pairs of List fields K and V, in no order). `==`, the public hash and
the keyed table hash of its values read those entries only, by one rule in
each runtime (core::value::IdentityEqual and core::hashing::Identity;
ops.rs's `identity_equal` and `identity_walk`), and the witness predicates
(`hir::types::Totality`, so HashClass and the new intrinsic trait
Equatable's EqualityClass) read the identity's elements only.
`std::immutable_map::ImmutableMap[K satisfies Hashable, V]` is ordinary
Botlish over a frozen ordered table (stdlib/immutable_map.bot,
stdlib/ordered_table.bot's frozen section) that declares `identity
associations(keys, vals)`; `MutableMap.freeze` makes one, and
`MutableSet.freeze` makes an ImmutableSet. Keep it so:

* No user code defines equality or a hash: never add an `fn ==`, a
  `hash` implementation, an identity function, a derive or a registration;
  a new identity form is a row of `hir::structs::identityForms`, both
  runtimes' and the oracle's encodings, never an arbitrary body. The clause
  is part of the declaration (owner-only, one per type, no orphan); a
  struct with an identity is opaque, not a context, and immutable (no
  MutableVector, MutableArray, C pointer, view or affine component:
  `hir::structs::MutableComponent`). Never admit a mutable value.
* Equality is multiset equality of the entries (a pair is a unit), matched
  in place, then by hash buckets, then pairwise: equal hashes never decide
  equality, and an unhashable entry falls back to the pairwise comparison
  that refuses it. The hash is the form's tag, the count and the wrapping
  SUM of each entry's whole hash from a fresh state (a pair's: the entry
  tag, its key and its value), in both folds; never an XOR, an
  order-dependent fold, a keyed mix of the public hash, or a fold of a
  representation field. The runtimes find an identity by the struct's
  shape (Tcl: `core::value::setIdentityTest`, `hir::structs::RuntimeIdentity`;
  native: NIR `shape ... identity=`, `ShapeInfo.identity`, the program
  descriptor), never by a type's name.
* Totality reads an identity struct's identity elements only, named in
  the type's terms ("the members of", "the keys of", "the values of"),
  never its fields; ImmutableMap is Equatable and Hashable exactly when V
  is. Hashable refines Equatable (`hir::traits::Refines`, by the
  intrinsics' guarantees); never the reverse, and never a second witness
  table.
* ImmutableMap is no runtime kind: no native, NIR instruction or Tcl helper
  of it. Iteration is its frozen order (the loop protocol), lookups the
  frozen index of stored keyed hashes, `reordered` the relational
  contracts of hir/relations.tcl (no immutable-specific proof). ImmutableSet
  stays intrinsic (the report's "ImmutableSet" names the blockers); its
  public hash is unchanged.

If you change the identity grammar (surface/parser.tcl's
`IdentityClause`), `hir/structs.tcl`'s identity checks or
`RuntimeIdentity`, the identity branches of `hir/types.tcl`'s Totality or
hir/decimal.tcl's `Mentions`, `hir/traits.tcl`'s Equatable or `Refines`,
the HIR text of an identity, either runtime's identity equality or hashing
(core/value.tcl, core/hashing.tcl, core/immutableset.tcl,
native/src/runtime/ops.rs, the descriptor in program.rs, nir.rs's shape),
stdlib/immutable_map.bot, the frozen section of stdlib/ordered_table.bot or
a freeze, run `tests/value-identity.test`, `tests/immutable-map.test`, their
golden suites (`tclsh9.0 tests/local.tcl tests/golden/value-identity.bot
tests/golden/immutable-map.bot`), `python3 -I
audit/value-identity/tools/oracle.py selftest`, `python3 -I
audit/hashable/tools/oracle.py selftest`, `audit/value-identity/tools/fuzz.tcl`
(several seeds; once with `-gc-stress 1`) and
`audit/value-identity/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the Hashable,
mutable-map, collection-reorder and trait harnesses (above) for a change to
code they share, and the warning gate. `bench/value-identity.tcl`
regenerates the performance report.

## Tree structs and std::tree::walk

A `tree struct NAME[SLOTS]:` (TREE-STRUCT-MILESTONE-1.md) is an ordinary
immutable struct with exactly one recursive field, its *child field*, of
type `List[Self]` (Self the declaration applied to its own slots in order):
a finite rooted ordered tree value. The registry records the child field
(`hir::structs::treeField`, the sourceTypes entry's and HIR text's `tree
FIELD`), and everything that treats a tree specially reads that, never a
field that happens to be recursive. Keep it so:

* One shape: no second recursive field, no field of Self, no Self nested
  deeper or inside another container, map, set, function type or another
  application of the declaration, no mutual recursion (TREE-STRUCT-SHAPE);
  never opaque, a context or an identity struct (TREE-STRUCT-COMBINATION);
  never affine, also through an application (`Node[Coroutine...]`:
  AFFINE-CONTAINER-UNSUPPORTED). A general recursive type stays an ordinary
  `struct`'s (STRUCTS.md); never widen the tree shape to make one fit.
* A tree is a value: no reference, node handle, node id, parent link,
  pointer equality, mutation through a subtree or cycle, and nothing a
  program does may observe how the runtimes hold the recursion (today a
  struct object whose child List holds its children's objects: no arena).
  Never let equality, a hash or a walk read an address, an allocation order
  or a construction history.
* ==, the public hash, the keyed table hash and the printer of a tree mean
  exactly what they mean for any struct (the same comparisons in the same
  order, the canonical input byte for byte, the same text) and walk the
  topology with work stacks, never the host's recursion: core/value.tcl's
  TreeEqual and TreeShow, core/hashing.tcl's TreeEncode, ops.rs's
  `tree_equal` and `tree_walk` (the sinks' `open_nested`/`close_nested`),
  show.rs's `tree_show`. The runtimes learn the child slot from the
  registry (core::value's tree test) and the shape (NIR `tree=`,
  `ShapeInfo::tree`, the program descriptor, format 3): never by a type's
  name. Totality skips exactly the child field (hir::types::Totality).
* std::tree::walk (stdlib/tree.bot) is ordinary Botlish: one function whose
  every yield is its own, a preorder stack and a compacting breadth-first
  queue, no visited set. It reads the child field through the internal
  `std::tree::children` (core/tree.tcl: `-result-shape tree-children`,
  declareInternalMember; a static `structget` natively, `treechildren` only
  where no static type names the shape). Its nodes are typed as the tree's
  own type because a coroutine construction takes its outward type from the
  root call's semantic instance (hir::coroutines::InstanceOutward,
  hir::semantic::ConstructionOutward): never give the walk a callback, a
  cursor, a handle type or a trait view.

If you change any of that (the grammar's `tree` modifier, hir/structs.tcl's
tree section, `TreeChildrenProblem` or GenericLive's thunks, the tree cases
of hir/types.tcl, HIR text, the runtimes' tree walks, core/tree.tcl,
stdlib/tree.bot, the shape's `tree=`, the descriptor, or how a construction's
outward type is computed), run `tests/tree-struct.test`, its golden suite
(`tclsh9.0 tests/local.tcl tests/golden/tree-struct.bot`), `python3 -I
audit/tree-struct/tools/oracle.py selftest`, `audit/tree-struct/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/tree-struct/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule) and `cargo test --release --manifest-path native/Cargo.toml
--lib -- tree deep_trees program`, plus `tests/coroutines.test`,
`tests/semantic-instances.test` and `tests/structs.test` for a change to
construction typing or generic liveness, and the Hashable and value-identity
harnesses for a change to the hash walks. `bench/tree-struct.tcl` regenerates
the performance report.

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
functions (their declared types, and the inherited variables an untyped
parameter's contract takes from a callee's:
INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md, "Inherited imprint variables")
and intrinsics (`-imprint`), variables established by applied types left
to right, explicit imprints all or nothing in first-occurrence order.
Never add declared type parameters
(`fn f[T]`), a constraint written on a function or a variable (the only
constraints are a struct slot's, which a signature's applications carry:
Parameterized structs and constrained slots, above), or specialization
keyed by a variable (the trait monomorphization's specializations per
binding of a source-trait-constrained variable are a trait operation's
witness selection, not imprinting's). A nested function's signature names
an enclosing function's variable as that variable: rigid there, never bound
at the nested function's calls, constrained as the enclosing signature
constrains it (`hir::imprint::BlockSignature`'s own variables exclude
`EnclosingOf`; `ConstrainEnclosing` at resolution and in hir/read.tcl).
Enclosing variables are not a forwarder's inherited ones. Variables are
identified by name only, so never let a nested function bind a variable of
an enclosing one's name.

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

## Native link plan (static libraries, archive paths, frameworks)

`extern c library "NAME" static`, `extern c library "NAME" static at
"PATH"` and `extern c framework "NAME"` (NATIVE-LINK-PLAN-MILESTONE-1.md)
state a program's native dependencies in source; `extern c library "NAME"`
keeps its old meaning exactly. Keep it so:

* The plan states intent, never linker flags: HIR's `links`
  (hir/foreign.tcl's `LinkPlan`) holds each dependency's kind, name,
  linkage and an archive's path as written beside the directory it
  resolves from (`base`: the root of the declaring file's scope -- the
  application root, or a package instance's directory for a package's
  module -- surface/modules.tcl's `LinkDecls`; "" for a standard-library
  module or a program compiled from text). Never store a resolved path, a `-l`, `-framework` or `/LIBPATH:`
  in HIR, and never add a general linker-flags string, a linker script, an
  arbitrary build command or a computed name or path: every name is
  `nir::is_link_name`'s, every path a string literal with `/` separators.
* Declarations of one library merge into the strictest requirement
  (default < static < static at PATH), whichever comes first; two that no
  archive satisfies are LINK-CONFLICT. Never pick the first or the last.
* An archive path resolves from the application root (a package's
  module: its package instance's directory, never its consumer's), never
  the working directory, never the compiler's own files (the single
  executable's ZIP, Botlish.app's Resources). The root is a front-end input (in the cache
  key); the join is the driver's (codegen/aot.rs's `resolve_link_plan`),
  at every link: never cache an archive, a resolved path or a link.
* `static` is a requirement: the driver finds the archive (`static_archive_name`
  in the -L directories, then `default_library_dirs`) and checks it
  (`check_static_archive`, `archive_facts`: a regular file of objects of
  the host's format and architecture, no Windows import member) before any
  linker runs, and passes its absolute path. Never fall back to a shared
  library, `-lNAME` or another file, and never relabel a refusal: it is
  NATIVE LINK ARCHIVE.
* A framework is Apple's: UNSUPPORTED-PLATFORM for a target whose linker
  has none (`core::cabi::linksFrameworks`), `-framework NAME` and `-FDIR`
  on Apple's ld only. Never map a framework to a library elsewhere.
* Both host linkers (rustc, system) take one resolved plan
  (`link_plan_args_for`); the stub refuses any plan. A native library's
  shared library links the plan, its static library holds none of it and
  its manifest lists it (`dependencies`).

If you change any of that (the report's "What to run when changing this"
lists the files), run `tests/native-link-plan.test` (also with
`BOTLISH_NATIVE_LINKER=system` and under `BOTLISH_NATIVE_GC_STRESS=1`),
`tests/c-ffi.test`, `tests/system-linker.test`, `cargo test --release
--manifest-path native/Cargo.toml --bin botlish-native link_plan` and
`audit/native-link-plan/tools/mutate.tcl` (every mutant in its
`mutants.txt` that applies to the host must still apply and be killed:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), plus the C FFI, native-AOT, interchange and
isolation harnesses for a change to code they share, and
`tests/bot-modules.test` and `audit/bot-modules/tools/mutate.tcl` for a
change to how a declaring file's root is found (its scope's directory);
on macOS the `link-plan-sdl3` job (tests/platform/link-plan-sdl3.sh: static SDL3
through Botlish.app) and the acceptance tier, on Windows the workflow's
smoke and system-linker jobs (the import-library refusal).

## Native libraries (exported c fn)

`exported c fn NAME(PARAMS) -> T` declares a C export
(NATIVE-LIBRARY-MILESTONE-1.md): an ordinary Botlish function to every
backend and to its Botlish callers, which `native::library` (`main.tcl
-emit-native-library NAME`) also gives a C entry point in a static archive,
a shared library, a C header and a JSON manifest -- on Windows x86-64 a DLL
and its import library in place of the two libraries
(WINDOWS-X86-64-MILESTONE-8.md). Keep it so:

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
  call reads its own program through the Vm it runs in (`Vm::info`; no
  thread's current program to swap: Per-VM and per-thread runtime state,
  above). Never let two libraries share a symbol, a static or a program,
  and never fix a collision with a global lock or a singleton.
* Instances are explicit (`NAME_create`/`NAME_destroy`), thread-affine,
  one call at a time (WRONG-THREAD, REENTRANT-CALL), looked up by ticket
  (INVALID-INSTANCE). A library installs no signal handler, never `_exit`s
  and runs on its caller's stack. The walk of a call's stack ends at the
  call (`Vm::stack_ceiling`).
* A library bounds its own Botlish recursion (NATIVE-LIBRARY-MILESTONE-1.md,
  "Stack safety"): the driver emits its program through
  `nir::check_stack_limit`, so every function with a Botlish call checks
  its stack pointer against `Vm::stack_limit` in its prologue and fails
  with NATIVE LIMIT STACK, a fallible call its callers check. The limit is
  the running stack's (`NativeStack::stack_limit`: an eighth in reserve):
  a call takes its entry stack's (`Vm::stack_limit_at`, none on a stack
  the instance did not make, never another's), a coroutine switch the
  arrival stack's (`publish_active_stack`). Keep the check a library's
  only: never give an executable or the JIT the check or its call
  effects (the guard bounds them). An overflow in C or the runtime, or on
  a host's own stack, is still process-fatal, and no document may claim
  otherwise until a library-owned stack exists.
* A call made on a stack the instance did not make -- a host's fiber or
  coroutine stack -- runs there (WINDOWS-X86-64-MILESTONE-8.md, "Calls on
  a host's stack"): `Vm::entry_stack` (`entry_stack_at`, set by `enter`)
  is that stack, which bounds the collector's walk of the call and of a
  coroutine's resumer on it, and code back on it after a switch checks no
  limit. Never bound such a walk by the thread's own stack (it finds none
  of the call's frames: their roots are missed) or give it the thread's
  limit.
* A library leaves its host's thread as the host gave it: at the end of
  the outermost call of a library on a thread (`Active`) a Windows
  fiber conversion its coroutines needed is undone
  (`coroutine::library_call_ended`; a fiber the host made stays that
  fiber), and when the thread's last instance of the library is destroyed
  (or NAME_main's Vm ends with none left) its pooled coroutine stacks are
  freed (`release_pool`), so a host that destroyed every instance may
  unload the library with nothing of it left on its threads. Never keep a
  host thread converted, or a stack pooled, past those points; and never
  touch the pool's thread-local on a thread that never ran a coroutine
  (`POOL_USED`): its destructor's registration makes glibc keep the
  library mapped until the thread ends (`al-dlopen`).
* Fusion's `drop_unreferenced` keeps what the exports reach, not only
  what the program function reaches: a library export is called from C.
* A library's entry file holds declarations only (LIBRARY-TOP-LEVEL):
  creating an instance runs module static initialization, never a script.
  An application library's entry file is an entry program, run by
  NAME_main only (next section).
* Libraries are Linux glibc's (x86_64, aarch64) and Windows x86-64's
  (MSVC): `codegen::library::SUPPORTED`, `native/native.tcl`'s
  `libraries`. Never use `ld -r --gc-sections` for the archive: GNU ld
  2.42 makes the Rust standard library's weak references strong there and
  consumers fail to link.
* A Windows library (WINDOWS-X86-64-MILESTONE-8.md) is a DLL and its
  import library that link.exe links (`botlish-native library-dll`,
  `codegen::aot::link_windows_library`) from the program object and the
  runtime archive, its exports a module-definition file listing exactly
  the public functions (`windows_library_definition`), the static release
  C runtime and no other (`crt_args_for`'s policy), and both files checked
  from their bytes before they are reported (`ValidateDll`, native/pe.tcl:
  exactly the public exports, by name, none forwarded, no C runtime's DLL
  imported, the import library naming exactly them). Never export a name
  beyond the public ones (`/EXPORT`, `__declspec(dllexport)`, a .def line),
  never give the DLL an entry point or initializer of Botlish's (no
  DllMain, no `.CRT$X*` section: nothing Botlish runs under the loader
  lock; `nl-windows-loader-lock`), and never ship a static COFF library
  while two of them in one executable share their runtimes' symbols (the
  report's section 13). Its public functions carry unwind information like
  every Botlish function (`codegen::add_windows_unwind`'s `public`).

If you change any of that (NATIVE-LIBRARY-MILESTONE-1.md, "What to run when
changing this", lists the files; WINDOWS-X86-64-MILESTONE-8.md's section 19
the Windows ones), run `tests/native-library.test` (on Windows too: its
MSVC hosts need Visual Studio's x64 tools; the Windows workflow's smoke job
runs it), `tests/native-executable.test` and `tests/aot-stub-linker.test`
(also under `BOTLISH_NATIVE_GC_STRESS=1`), `cargo test --release
--manifest-path native/Cargo.toml --lib program` and `--bin botlish-native
windows_library`, `audit/native-library/tools/fuzz.tcl` (several seeds,
once with `-gc-stress 1`), for the stack check also
`tests/native-stack-overflow.test` and `audit/native-stack/tools/mutate.tcl`
(its `effects-*` mutants), and `audit/native-library/tools/mutate.tcl`
(every mutant in its `mutants.txt` that applies to the host must still
apply and be killed: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule; the `%% windows-x86_64` ones
on Windows: the tier item `native-library-mutants`), plus
`audit/native-aot/tools/mutate.tcl` for a change to the shared startup.
`audit/windows-library/probe.tcl` (its workflow) is the COFF/linker census
and `bench/native-library.tcl` the costs. `audit/compiler-service/probes/export/run.sh` (the Tcl
extension) and `audit/react-native/tools/host-spike.tcl` (Hermes) are the
foreign-host probes; `audit/react-native/tools/libmode.tcl` is history and
no longer runs.

## Application libraries (NAME_main: a host-startable entry program)

`-emit-native-library NAME -application FILE.bot` builds an ordinary entry
program as an application library
(RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md): a native library
with one more C function, `int32_t NAME_main(int argc, char **argv,
NAME_error **error)`, which makes a Vm on the calling thread, runs module
initialization and the entry program's own statements -- its
installations, its state, its loop -- to their end, and drops the Vm on
that thread before it returns its status. The host supplies the thread and
the call, never a context or the application's authority. Keep it so:

* No language construct, no resumable or host-driven Vm, no handle: a call
  is a whole run. Never keep a Vm between calls, hand C a Vm or instance of
  NAME_main's, add an init/event/iterate ABI, or let C put a context into a
  Vm. The entry program is checked as every entry program is
  (installations, requirements, one selection per context trait), for an
  executable or an application library alike; never relax a check for
  -application.
* One dispatch: NAME_create selects "initialize only"
  (runtime::thread::ENTRY_INITIALIZE_ONLY, reported -1:
  `core::thread::initializeOnly`) through M4's entry dispatch
  (native/lower.tcl's ThreadDispatch, emitted for an application or a
  program with thread entries), NAME_main the entry program (0). Never
  lower the entry program a second time, run module initialization twice,
  or let NAME_create run the entry program's statements. An application
  library's exports keep every export rule (EXPORT-ENVIRONMENT: the
  entry's authority never reaches a C caller); `main` is a reserved export
  name only there.
* Ordinary libraries are unchanged, byte for byte: no NAME_main, no
  `application` NIR line, LIBRARY-TOP-LEVEL and LIBRARY-NO-EXPORTS, manifest
  schema 2 (the React Native tool reads schema 2 only). Schema 3 is an
  application library's alone: schema 2 plus the `application` member;
  `botlish tool` (pm/tools.tcl) takes both, protocol 1 unchanged.
* argv is UTF-8, argv[0] included, copied before any Botlish code runs;
  refusals are statuses (ARGUMENT-COUNT, NULL-POINTER: INVOCATION;
  ARGUMENT-NULL, ARGUMENT-NOT-UTF8: BOUNDARY). *error is NULL after a
  success. A failure is the status and an owned error; nothing unwinds,
  nothing exits, no signal handler is installed (the library's stack check
  bounds recursion: NATIVE LIMIT STACK).
* NAME_main while the thread runs a call of the same library is
  REENTRANT-CALL; calls on different threads are independent Vms.
* The library's per-thread state (the owner token, the count of active
  calls, the count of live instances) is the slots of pthread keys with no
  destructor (runtime/library.rs's `thread_word`; on Windows plain
  thread-local words): never a `thread_local!`, never
  std::thread::current() in library code -- on Android Rust's
  thread-locals are pthread keys whose destructors run at thread exit, in
  code a host may have unloaded.
  Hosts must not unload a library while a thread that called it lives (the
  report's lifetime rule: glibc pins the library for pending thread-local
  destructors, Bionic does not); SDL's Android bootstrap keeps it loaded.
* The runtime ABI fingerprint digests the library boundary
  (runtime::library::SIGNATURES, `signatures_are_the_forwarders`) and the
  initialize-only index: change either and every target support package is
  rebuilt.

If you change any of that (native/library.tcl's application, the lowering
option `-application`, ThreadDispatch, runtime/library.rs, thread.rs's
entry index, codegen/library.rs's forwarder, aotimage.rs's fingerprint,
pm/tools.tcl's artifact check), run `tests/application-library.test` (its
`al-icy-tower-sdl-runapp` needs the package-owned libSDL3.so,
`tests/cffi/sdl3.tcl`, and SDL's pinned headers), `tests/native-library.test`,
`tests/external-tools.test`, `tests/threads.test`, `tests/android-target.test`
(with ANDROID_NDK_ROOT; its `at-application-run` and `at-application-unload`
also qemu-aarch64 and BOTLISH_ANDROID_ROOTS), `cargo test --release
--manifest-path native/Cargo.toml -- signatures abi_fingerprint` and
`audit/host-startable-library/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a detector its `!!` line
names: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule), plus the native-library and android-target
harnesses for a change to code they share.

## C callbacks (callback c fn)

`callback c fn NAME(PARAMS) -> T:` and `std::ffi::c::callback(NAME)`
(C-CALLBACK-MILESTONE-1.md) are synchronous C callbacks: a top-level,
environment-free function whose C signature's conversions are total,
declaring no errors and never suspending (hir/callbacks.tcl), and its C
function pointer -- the address of a C entry point the native backend emits
for it (native/src/codegen/callback.rs). C may call it only during a call of
a C function whose `FnPtr` parameter is noescape (`hir::foreign::CallsBack`,
NIR's `callbacks=1`): every such call goes through a transition shim that
records the waiting Botlish frame (`rt_ffi_open`, `rt_ffi_close`), and the
callback runs nested in that execution environment
(native/src/runtime/callback.rs). Keep it so:

* The pointer selects no execution environment and grants no authority:
  never create a Vm, actor, context or heap on callback entry, never run a
  callback on a thread, stack or moment no open transition of the calling
  thread permits (THREAD, INACTIVE, STACK are refused before any Botlish
  code), and never treat retention as permission: a captures or unknown
  `FnPtr` parameter is a retaining call (DIRECT) and no transition.
  Retained registrations, context-bearing callbacks and worker-thread entry
  are later milestones: never fake one with a transition.
* Never read a C frame: the collector's walk jumps from the callback's
  entry frame (`run`'s record) to the transition shim's
  (`framewalk::walk_segmented`, `Vm::callback_segments`), whose return
  address is the waiting Botlish frame's safepoint. Keep `ForeignCall` a
  safepoint, `run` and the shim real frames (never inlined, always
  calling), and the segment stack balanced (`rt_ffi_close` refuses a
  stale one). The tests' C fixture calls the nesting callbacks with its
  frame-pointer register holding no frame; keep it adversarial.
* The transition is the shim's frame record, handed on by the naked
  `rt_ffi_open` (its caller's frame register) on every host: never read it
  from a Rust frame's record (LLVM's Win64 frames keep none at their frame
  register) or derive it from a runtime helper's frame, which is gone
  when the helper returns. On Windows x86-64 (WINDOWS-X86-64-MILESTONE-9.md)
  a segment's entry is `run`'s stack pointer (`framewalk::frame_record`),
  the frame `windows::walk_context` arrives in from the callback's
  Botlish frames, and the jump resumes in the waiting Botlish frame at
  exactly its call of the shim (RIP `[t + 8]`, RSP `t + 16`, RBP `[t]`),
  never unwinding C, the entry point or the shim; a transition that is not
  a frame record above the entry on the walked stack, or whose return
  address is no Botlish code, is NATIVE CALLBACK BUG, never a walk that
  guesses. Keep `run`'s body at one stack pointer (no dynamic allocation
  in it). Every transition shim and callback entry point has unwind
  information (`codegen::callback::Defined`: the COFF object's `.pdata`,
  the JIT's function table), so that Windows' unwinder -- an exception's,
  a debugger's, BOTLISH_NATIVE_UNWIND_CHECK's -- never takes one for a
  leaf; the Windows fixture's nesting callbacks are called from an
  assembly frame with no function table entry (callback-fixture-win64.asm):
  keep it so, and keep the mixed-call fixture's nonvolatile registers
  checked.
* No Botlish error, panic or suspension crosses C, and no answer is made
  up: a failure the front end cannot exclude ends the process after its
  report (`Fatal::terminate`, `platform::report_fatal`), never returns a
  value to C. Never add a fallback value, a host error channel or
  unwinding through C.
* Conversions are total by construction: a callback's parameters are C
  integer scalars, Bool, RawFloat, RawDouble, Ptr, FnPtr (never a finite
  Float or Double: CALLBACK-SIGNATURE), its result one of those, Float64 (C
  double) or unit; raw values cross as their bits (bitcasts, never a
  conversion instruction). No libffi, executable-memory trampoline or
  run-time code generation: every entry point is a static function of the
  program.
* A callback's function is a root: its generic instance (open, its
  declared contract) through specialization's `-exports`, kept by fusion's
  dead-code elimination. Never let a caller's facts reach it.
* The fallback root plan refuses a callback at run time (NATIVE CALLBACK
  UNSUPPORTED, `runtime::callback::SUPPORTED`: `NATIVE_FRAME_ROOTS` and
  `framewalk::CROSSES_TRANSITIONS`); never enable one on a configuration
  whose collector does not cross a transition, and never by host name.
* A callback runs on the stack its transition left: the running stack
  (`Vm::running_stack`: a coroutine's, a native library call's host-made
  stack -- a host's fiber, a ucontext stack -- or the thread's). A
  library's callback enters its own waiting instance, never through the
  registry: a host's call of that instance stays REENTRANT-CALL.

If you change any of that (hir/callbacks.tcl, `hir::foreign::CallsBack`,
the callback-pointer shape, NIR's `callback`/`cbaddr`/`callbacks=1`,
codegen/callback.rs, the shim's call in clif.rs's `foreign_call`,
runtime/callback.rs, `walk_segmented`, the Windows walk's `jump`,
`Vm::foreign_open`, `callback_segments` or `running_stack`, the C side's
unwind information), run `tests/c-callbacks.test` (also under
`BOTLISH_NATIVE_GC_STRESS=1`), its golden suite (`tclsh9.0 tests/local.tcl
tests/golden/c-callbacks.bot`), `tests/native-library.test` (its
`nl-callbacks*`), `cargo test --release --manifest-path native/Cargo.toml
callback`, `audit/c-callbacks/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`) and `audit/c-callbacks/tools/mutate.tcl` (every mutant in
its `mutants.txt` that applies to the host must still apply and be killed:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule; the library mutants with `-tests
"tests/c-callbacks.test tests/native-library.test" -match "cb-*
nl-callbacks*"`), plus `tests/c-ffi.test`, `tests/coroutines.test` and
`tests/raw-c-float-ffi.test` for a change to code they share. On Windows
the same runs on the Windows workflow (dispatched on the branch, or a
`[ci-full]` push with `CI-Tests: c-callbacks.test native-library.test rust
c-callbacks-fuzz c-callbacks-mutants c-callbacks-library-mutants`), with
`tests/platform/native-status.tcl` (its `c-callback` probe) and
`tests/platform/gc-workloads.tcl -unwind-check 1`. `bench/c-callbacks.tcl`
regenerates the performance table (the tier item `c-callbacks-bench` on
Windows); `audit/c-callbacks/tools/raven-census.tcl` the Raven census.

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
acceptance tier of a dispatched run, and under GC stress a `[ci-full]`
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

## Raw C floating values (std::ffi::c::RawFloat, std::ffi::c::RawDouble)

`std::ffi::c::RawFloat` and `std::ffi::c::RawDouble` (RAW-C-FLOAT-FFI-
MILESTONE-1.md) are C's float and double carried exactly: every binary32 or
binary64 bit pattern -- NaN payloads, signaling NaNs, the infinities,
negative zero, subnormals -- with their finite counterparts' C facts
(core/cabi.tcl's `floatings`: `representation Float`/`Double`, `raw 1`).
Their canonical type is the runtime kind `rawfloat32`/`rawfloat64` in every
position (a C type and a type of values at once); the explicit operations
are `std::ffi::c::raw`'s (stdlib/ffi/c/raw.bot, over the internal
intrinsics `std::rawfloat::*`). Keep it so:

* Carrying is not admitting: a raw argument, result, field, element or
  alternative crosses as its bits (`bitcast`, integer loads and stores; NIR
  `rf32`/`rf64`, layout descriptor `{r W E}`, encoding bit 128) -- never
  an `fdemote`, `fpromote`, finiteness test, `+ 0.0` or NonFiniteFloat. A
  raw position never changes the C signature: the same F32/F64 class and
  registers as the finite type's (`raw_c_float_signature_is_the_finite_one`).
* Admission and narrowing are the finite types' own rules, called
  explicitly (`core::cabi::AdmitBits`/`Narrow`, `admit_c_float`/
  `narrow_c_float`): never a second implementation, never implicit. Never
  let a raw value be admitted where a Float64 is expected, a Float64 or an
  Int become a raw value, or RawFloat and RawDouble convert, and never
  make a raw type an alternative of a finite one anywhere (resolution,
  conversion, admission).
* A raw value is no number: no arithmetic, ordering, equality or hash
  (statically `hir::cabi::VerifyCallKinds`; at run time its own kind, in
  core/value.tcl's `incomparable` and core/hashing.tcl's `unhashable`, and
  ops.rs's refusals). Never represent one as an Int, never add a bitwise
  `==`, and never let a raw value be a trailing variadic argument.
* `std::ffi::c` stays free of compiled functions: the raw operations live
  in `std::ffi::c::raw`, imported by the programs that use them.
* The finite types' behavior is a compatibility contract: Float and Double
  admit, narrow and charge NonFiniteFloat exactly as before.
* The binding generator's `representations` choose raw per function and
  position (finite is the default); a stale or invalid rule is an error;
  every choice is in the manifest. Never special-case a library in the
  generator.

If you change any of that (the report's section 10 lists the files), run
`tests/raw-c-float-ffi.test` (its fixture needs `cc`), `tclsh9.0
tests/local.tcl tests/golden/raw-c-float-ffi.bot`, `tests/c-float-ffi.test`,
`tests/c-ffi.test`, `tests/c-abi-types.test`, `tests/hashable.test`, the
layout test files, `cargo test --release --manifest-path native/Cargo.toml
--lib c_float` and `--bin botlish-native raw_c_float`,
`audit/c-float-ffi/tools/fuzz.tcl` (several seeds, once with `-gc-stress
1`; it draws raw positions by default) and
`audit/c-float-ffi/tools/mutate.tcl` (every mutant must still apply and be
killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule; the raw ones are `raw-*`); for the
generator or a profile's representations the C binding generator's checks
with the pinned toolchain, and for Raven's `tests/raven.test`.

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
Windows workflow dispatched on the branch for a change to Win64's lowering, and the
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
* android-aarch64 is Android's, at API 21: the Android NDK's clang
  (`--target=aarch64-linux-android21`) against the NDK's sysroot, both from
  ANDROID_NDK_ROOT (toolchain.tcl's `AndroidNdk`), the NDK's directory shown
  as `$ANDROID_NDK_ROOT` in every generated file (`hide`). Never generate
  one with another compiler, the host's or a Linux C library's headers, or
  relabel linux-aarch64's (the same layouts, other prototypes and
  functions). SDL3's is committed; the c-bindgen workflow installs NDK r29
  by its SHA-256 to check it.

If you change `tools/c-bindgen/`, `tools/cheader/`, a profile or the
fixture, run `tclsh9.0 tests/c-bindgen.test`, `tools/c-bindgen.tcl check
PROFILE -target committed` for every profile (fixture, tcl, tclstubs,
boringssl, sdl3, win32; sdl3's android-aarch64 with ANDROID_NDK_ROOT),
`audit/c-bindgen/tools/fuzz.tcl` (several seeds),
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

A rejection is the block's result, never an exemption
(STATIC-COMPILE-EXPECTED-DIAGNOSTICS-MILESTONE-1.md): a block takes only the
diagnostics located in its own body, and a rejected block standing as a
statement ends no sequence for the checks (`hir::static::reifiedStatement`:
the types' reachability, the range, completion, ownership, relational and
emission walks), so it never hides a diagnostic of the code after it. Never
add an exemption, a suppression or a demotion for an expected diagnostic,
and a new analysis that stops at a statement that never completes reads
`reifiedStatement` too. Run-time decisions (the backends, exit releases,
`hir::mutvec::LaterIn`) keep the failure's control flow.

If you change the static grammar, `hir/static.tcl`, the loader's deferral of a
block's qualified references (`surface/modules.tcl`), how `fail` resolves or
lowers, the completion walk's `fail` case (`intended`), an analysis's
handling of a statement that never completes, `hir::Diagnose`'s
fields, `hir::BuildFull`, or SAME-FAILURE's fail sites, run
`tests/static-compile.test`, `tests/static-compile-expected-diagnostics.test`,
its golden suite (`tclsh9.0 tests/local.tcl
tests/golden/static-compile-expected-diagnostics.bot`),
`audit/static-compile/tools/fuzz.tcl` (several
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
(`C:erased`, `C:unwind`; never the gates `C:verdict` and `C:plan`): a
failing block consuming one waits while a failing block contributes to it,
so a consumer's verdict does not depend on where its contributors are
written. An edge into a waiting channel's part of the graph, or a new link
label the rule must skip, can therefore change an outcome, not only a build
count: check the fuzzer's layout claim on several seeds (17 and 41 among
them). If you change the
schedulers, the dependency analysis, the method-call seeds or build reuse
(`hir/hir.tcl`), or add a fact an analysis reads across functions (a summary,
an inferred contract, the erased-callable contract, a yield type, a diagnostic suppressed by reachability or by a whole-program
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
  (the shards finish within it); a newer push to the same ref, on main too,
  cancels it (CI-RUNS.md), so read the latest run. Don't wait idle for it: carry on, and before you call the change
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
  call stands at, a single deviation for any other), and the call's
  receiver is not poison there, unless a kind proof rules it out (next
  item). A call whose receiver the decided build poisons is judged by those
  same builds (its own stand-in may have poisoned it: a fold's `acc.f(x)`,
  HTTP-CLIENT-PACKAGE-MILESTONE-1.md's F2), and decides nothing only when
  every candidate's build poisons it; a rejection is dismissed for its
  receiver only when the reported program poisons it. Never take a poison
  of the decision's builds for an independent diagnostic's. The decision
  is the configuration in which every call has exactly the candidate it
  stands at applicable; a call with several is AMBIGUOUS-METHOD-CALL, with
  none NO-APPLICABLE-METHOD, and a call that is still moving at the
  certification's bound is ambiguous. The
  search (the kind waves, the trial rounds) only proposes stand-ins: never
  decide a call from a stand-in, a trial round, candidate order, a guess or
  an unrelated call's outcome, and never add a precedence.
* **Kind proofs exclude, never accept** (METHOD-DECISION-FILTER.md). A
  candidate is excluded only when the receiver the build gives makes the
  ordinary call invalid by kind (a native's first parameter, a module
  function's declared or inferred first-parameter contract, the plain value
  kinds only), by a named struct's declaration (a *declared* first
  parameter of another named struct declaration than the receiver's:
  `NominalMismatch`) or by a trait's conformance (a *declared* first
  parameter that is a trait the receiver does not satisfy:
  `TraitMismatch`). Never exclude a lexical name, by a domain or a
  refinement, by a struct's type arguments, by an inferred contract's struct
  or by a type's spelling, and never for a receiver of no kind (`any`, a
  trait view, an imprint variable, a function). The native rule is
  stated once (`NativeMismatch`, which a call's problems and the kind proofs
  both ask), and so is the trait rule (`hir::traits::Accept`, which a call's
  own admission check and `TraitMismatch` both ask). Certification never
  reads a waves' guess (`DefinedType`).
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
* **Reporting never decides** (METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md).
  The decision reads the check records of its own builds; what is reported
  of it is a separate projection, made after every build it reads: the
  reported program is the decided configuration with every rejected call
  resolved to no candidate (`hir::resolve::RejectedMethodChoice`: its
  written callee marked `methodRejected`, poison), and `hir::methods::Report`
  adds the rejections, first and in source order, with each candidate's
  reason and `notes` locating the candidates. A rejected call's placeholder
  is a stand-in, never a selection: never report its own checks, its
  obligations, its errors or the uses of its result, never give its
  parameters' contracts to the program, and never let a check, a cascade
  rule or a recovery rule read it. A rejection is reported only when it
  holds whatever the operands nobody established are (a poisoned operand:
  `Rejection`'s `why`); never drop a diagnostic located inside a rejected
  call for being there. Never make the decision read what is reported
  (`hir::recovery::reported`, a message, an order, a note), and never let
  a presentation rule move, add or remove a decision: `methodChoices` and
  `methodDecided` stay the decision's.

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
(`audit/golden/migration/census/`). If you change how a rejection is
reported (`Final`, `Report`, `Rejection`, `Diagnostic`, `SourceOrder`, the
`methodRejected` callee and its cases in hir/resolve.tcl, hir/types.tcl,
hir/structs.tcl and hir/contexts.tcl, or a diagnostic's `notes` and their
consumers: hir/recovery.tcl's `entries`, the compiler service, the language
server, main.tcl), also run `tests/compiler-service.test`, `tests/lsp.test`,
`tests/main-cli.test`, `tests/diagnostic-recovery.test`, `tests/imports.test`,
`tools/compilerpedia.tcl check`, the static-decisions harnesses (Static
intrinsics, above: the rounds read the reported program) and
`audit/method-resolution/tools/invariance.tcl` against the tree before the
change (`-root` of each tree, then `-compare`: no semantic difference --
decisions, choices, static outcomes, accepted programs' HIR -- over the
golden suites).

## Native argument kinds

A native's `-param-types` are the kinds its arguments must have, and the
ordinary call's check holds them statically
(METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md): an argument whose type is
of a known other kind -- in an ordinary call, a method-style call (the
receiver is argument 1) or an operator -- is a compile-time TYPE of the call
(`hir::range::VerifyNativeKinds`, inside `hir::CheckingCall`), and the call is
poison. The rule is stated once (`hir::types::NativeKindMismatch`; with a
rigid imprint variable, `NativeArgumentMismatch`): region inference, the
check and the method decision's kind proof (`hir::methods::NativeMismatch`)
ask it. Keep it so:

* No special case by callable, collection or spelling, no method-specific
  check, and no run-time check added to make up for a static one. The method
  decision reads the call's own diagnostic like any other problem; never give
  it a native rule of its own again, and never let a failure add, rank or
  retry a candidate (SFIAE, METHOD-SUGAR.md).
* `any` stays dynamic: never reject an argument whose kind is not known, and
  never apply the rule in a semantic instance's view (an instance types a
  body under one caller's argument types; the caller is held to the checked
  contract instead). It applies to calls the program wrote (`written`), never
  to one a construct lowers to (that construct checks its operands) or to
  core IR text.
* A check that says more about an argument keeps it: foreign calls, imprinted
  intrinsics, layout operations, floating-point operators and `/`, a
  mutation receiver the place check rejects, byte owners, C addresses,
  native views or edits and raw C floating values, DecimalRounded
  parameters (the report, section 7).
  A new such check takes its argument over the same way, never by reporting
  beside it.

If you change any of that, or a native's `-param-types`, run
`tests/method-receiver-types.test`, `tests/method-resolution.test`,
`tests/method-filter.test`, `tests/diagnostic-recovery.test` and
`audit/method-receiver-types/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), plus the method-call decision's harnesses (above).

## Callee kinds (NOT-CALLABLE)

A call whose callee's static type is of a known kind no call accepts -- an
Int, a String, a Bool, a List, a struct, an enum case, a C address -- is a
compile-time NOT-CALLABLE of the call (HTTP-CLIENT-PACKAGE-MILESTONE-1.md,
F4): the call's own check (`hir::range::VerifyCallable`, inside
`hir::CheckingCall`), located at the callee, naming the function a binding
hides as its related location, and the call is poison (`hir::types::Call`).
The rule is stated once (`hir::types::NotCallable`: the callable kinds are
a Block, a native and a coroutine handle); the check, the poison and
region inference's dead call ask it. Keep it so:

* A callee of no fixed kind -- `any`, an untyped parameter's value, a
  structural function type, a trait view, an imprint variable -- stays
  dynamic, checked when the call runs. Never judge a call in a semantic
  instance's view, or a call the program did not write (`written`; core IR
  text), and never add a run-time check for a static one.
* The method decision reads it like any problem of the call: a
  non-callable binding named like a function is no applicable candidate.
  Never give it a method rule of its own, and never let it add, rank or
  retry a candidate (SFIAE, METHOD-SUGAR.md).

If you change any of that, run `tests/not-callable.test`,
`tests/method-sugar.test`, `tests/enums.test`, `tests/method-resolution.test`,
`tests/method-filter.test`, `tests/diagnostic-recovery.test`,
`tests/static-compile.test` and `audit/not-callable/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed by a test its
`!!` line names: update a mutant's text when you change the code it
mutates, keeping it a mutant of the same rule), plus the method-call
decision's harnesses (above).

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

## Emission claims (`emits`)

`fn F(...) -> T errors E emits R1, R2:` (EMISSION-CLAIMS-MILESTONE-1.md)
states that F's outward yield trace -- its own yields and its ordinary
callees' (deep yields), never a coroutine it constructs -- is one token of
each declared recognizer: every normal completion has yielded exactly one
token with nothing unread, every finite prefix (before completion, at a
failure, abandoned) is viable. hir/emission.tcl certifies each claim at the
end of `hir::BuildFull` from F's declared parameter types and the code every
backend compiles, or reports why not (EMIT-*). Keep it so:

* A claim is a verified property, never a way to run F: no backend reads
  `emits`, `emissions` or a block's `recognizer`; no runtime validator,
  recognizer call, table, buffer, coroutine or authority for a claim
  (tests/emission-claims.test's `ec-claim-erased`, `ec-native-erasure`).
* Caller-independent: F is entered with its declared parameter facts only
  (`hir::emission::Declared`). Never read hir::range's or hir::specialize's
  instances, the program's call sites, an undeclared parameter's inferred
  contract or anything observed; a function no program calls is checked
  like any other. A domain-typed parameter trusts the callers' admission
  (VerifyCall), which a certificate never replaces (`ec-domain-admission`).
* Conservative: what the walk does not model (a trait operation, a trait or
  context-trait clone, an unknown HIR form, a recognizer without its table)
  is EMIT-UNSUPPORTED, an exhausted budget EMIT-BUDGET and nothing else --
  never a certificate, never "yields nothing". Wording: violations "may"
  (the facts over-approximate); "disproven" only with a run (the witness
  tool, audit/emission-claims/tools/witness.tcl), never from the compiler.
* One value analysis: the facts are hir/intset.tcl over hir::range's own
  transfers (add, sub, mul, `ModParts`, `BitOp`, `Narrowed`, `TypeFact`,
  `InductionBinding`, `DomainEntered`, `RegisteredSet`, `Paths`); the one
  rule only a set can state is `!=`'s hole. Never add a second arithmetic,
  comparison or domain rule in the checker.
* A counted loop drops only its zero-iteration exit, and only where
  `hir::range::DomainEntered` proves every start and end its operands may
  have enters it (EMISSION-COUNTED-LOOP-PRECISION-MILESTONE-1.md): never an
  exit of an iteration (a `break`, a `continue`, a `return`, a failure, the
  head after any iteration), never from a relation between the bounds, a
  caller's facts or an infinity read as a bound. A native's result set is its registration
  (`-result-range {intervals ...}`, std::char::scalar_value's surrogate
  gap), a contract of the implementation both runtimes uphold -- never a
  table beside the checker, never inferred from runs.
* One outcome model: what a recognizer code means is core/dfa.tcl's
  `Outcome`, `RunResult`, `Resume`, `Unread`; surface/dfa.tcl's Lower
  compiles it for one symbol, hir/emitdfa.tcl steps it over sets, both from
  the same table (`hir::syntax::withRecognizer`). Never restate a transition
  rule in either.
* Trust: a certificate is a proof only when this process derived it. The
  in-process memo reuses one only after `hir::emission::Valid` (every
  function its proof read by canonical fingerprint -- type facts included
  --, every recognizer, every registered result set, every composed
  statement); a HIR read from interchange text or the front-end cache is
  verified again (`hir::emission::reverify`, HIR INTERCHANGE EMISSION), and
  HIR text carries no tables (its claims are not proved). Never accept a
  certificate because its text looks right, and never put process history
  (reuse) into the HIR.
* Identity: the memo, the certificate table and a certificate's
  dependencies name a function by its binding's name, which identifies it
  only when no other function block of the compilation has that name
  (`hir::emission::Identified`; EMISSION-IDENTITY-AND-FEASIBILITY-
  CORRECTNESS-MILESTONE-1.md). A name of two functions selects nothing: no
  memo reuse or storage for its claim, no publication of its certificate,
  no composition with a certificate it finds, no validation of a
  dependency on it, and no memoizing a proof that read a function of such a
  name (`ReadsIdentified`). Each falls back to walking the code the claim
  or call actually names. Never let a name choose between two blocks,
  never refuse a proof (only a reuse) because a name is shared, and never
  invent a lexical identity to keep a reuse without a design of its own.
* Feasibility is a flag: `hir::emission::Facts` answers `{FEASIBLE ENV}`,
  and an environment with no binding (a function without parameters, before
  its first `bind`) is a feasible path's environment like any other. Never
  read feasibility, or any other fact, from whether an abstract value's
  text is empty.
* Diagnostics anchor at the claimed function (its unit: recovery, static
  sites) and are located at the yield or call; a claim whose code holds
  another diagnostic, poison or a hole is `dependent` and says nothing.
  Its code is what the walk reads, also without evaluating it: a call's
  callee reference (an unresolved name is typed `never`, which is no
  divergence) and the code of a helper whose `never` result the walk
  relies on (`hir::emission::Taint`; `Read`, a summary read for its code:
  its taint and fingerprint the claim's, never its violations;
  EMISSION-CALLEE-DEPENDENCY-CORRECTNESS-MILESTONE-1.md). Never stop the
  walk at a `never` it has not read, and never make a claim dependent on
  code its walk does not read.
  Messages never print an internal id. Every EMIT-* kind has a
  `std::compiler::DiagnosticCode` case and a Compilerpedia topic.
* Provenance: a fact the walk reads of code it does not walk -- a
  non-local binding's exact value and type (`RefValue`), the static type
  of a call through a function value with no target, whose `never` ends
  the walk or whose result it reads (`EvalCall`) -- is incomplete when the
  front end derived it from code holding a resolution diagnostic, poison
  or a syntax-dependent reference, and a claim reading it is dependent
  (`hir::emission::Dependent`: one memoized, cycle-safe search over the
  defining code of value bindings and the bodies of functions that declare
  no result; EMISSION-BINDING-PROVENANCE-CORRECTNESS-MILESTONE-1.md). A
  function's declared result, a parameter's declared type, a callee read
  only as a callee and a check diagnostic (an unhandled error) take no
  part: never follow a declared result into its body, make a check
  diagnostic a source, or ask at a value call typed `any` or `unit`. A
  compilation holding a source (`trusted` 0) neither reuses nor memoizes a
  certificate: provenance is no fingerprint (V2 reads as V1 does). Never
  record provenance in HIR, a certificate or a fact, and never widen the
  memo rule to every diagnostic or drop it.
* A claim is about the yield trace, never the result: a claimed function
  may complete with any value of its declared result (a coroutine source's
  record count, the -1 a protocol uses for its end). Never bring back a rule
  on a claimed function's result; a consumer tells a symbol from the end by
  `std::coroutine::done?` (CSV-EMISSION-VALIDATION-MILESTONE-1.md, section
  18; `ec-result-not-symbol`).

If you change hir/emission.tcl, hir/emitdfa.tcl, hir/intset.tcl, the
hir::range transfers above, core/dfa.tcl's outcome model or what Lower
generates from it, a native's `-result-range`, the clause's grammar,
lowering, loader walk or resolution, or the `emissions` table's trust
(interchange, the cache), run `tests/emission-claims.test`,
`tests/interval-sets.test`, `tests/dfa.test`, `audit/emission-claims/tools/
census.tcl` (no false proof; every case as expected),
`audit/emission-claims/tools/fuzz.tcl` (several seeds; 0 false proofs),
`audit/emission-claims/tools/loops.tcl` for a change to loops or their
bounds' facts (several seeds; 0 false certificates, 0 regressions),
`audit/emission-identity/tools/structure.tcl` for a change to the memo,
certificates, composition or branch facts (several seeds; 0 false
certificates, 0 history differences), `audit/emission-dependencies/tools/
census.tcl` (0 false certificates, no difference from its record) and
`audit/emission-claims/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus
`tests/hir-range.test` for a transfer, `tests/static-compile.test` and
`tools/compilerpedia.tcl check` for a diagnostic kind, and the
hir-interchange and compiler-service harnesses for a change to what they
cover, and `tests/csv-emission.test` (the CSV workload's claims, below).
`audit/emission-claims/tools/bench.tcl` regenerates the costs.

## Workloads (examples/dfa/csv)

`examples/dfa/csv/` (CSV-EMISSION-VALIDATION-MILESTONE-1.md) is production
`emits` on a second protocol: RFC 4180's strict ASCII profile
(`csv_strict.bot`) and a UTF-8 profile over scalar values and bytes
(`csv_utf8.bot`) as declared recognizers, always-quoted and selective
emitters certified against them, coroutine sources, sinks and an export
application. Keep it so:

* The profiles stay two modules with one stated policy each (the report's
  section 2); an emitter checks a character with the grammar's own guard
  (`quoted_char`, `text_char`), never a list of its own, and fails
  `UnsupportedCSVCharacter` rather than replace, strip or normalize.
* Every claim of the example is certified; a rejected variant (selective
  quoting's natural spelling, the census's mutants) lives in a test or
  `audit/csv-emission/census/mutants.txt`, never in the example. The
  example is not standard library, and no CSV package is published from it.
* Nothing claims formula safety: a formula-like value is written as it is.

If you change the example, the profiles or the emission checker, run
`tests/csv-emission.test`, and for the example or the profiles also
`audit/csv-emission/tools/differential.tcl` (`-part all`; every backend, the
reference interpreter and `oracle.py`: 0 disagreements, 0 failures),
`audit/csv-emission/tools/census.tcl` (every mutant as its class states;
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same mistake) and `python3 -I audit/csv-emission/tools/
oracle.py selftest`; for `export.bot`, `audit/csv-emission/tools/
cleanroom.sh` after `single/build.sh`. `audit/csv-emission/tools/bench.tcl`
regenerates the native costs.

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
SLICE-1.md): a playable Icy Tower-style game on Linux x86-64, Windows
x86-64 (ICY-TOWER-WINDOWS.md) and macOS AArch64
(ICY-TOWER-MACOS-MILESTONE-1.md) over the generated SDL3 binding. Keep its
layering:

* `tower.bot` (the rules: a frame is `step(world, input, dt)`), `hud.bot`
  (text) and `options.bot` (the command line) are pure: no SDL, no clock,
  no input device. They run, and `golden.bot` and `headless.bot` test them,
  on every backend. Never import SDL or `sdl` into them.
* `game.bot` is the program (the frame loop, play, failure reports,
  `main`), one source for every platform; an entry program only installs
  the contexts -- `main.bot` std::linux::io's, `main-windows.bot`
  std::windows::io's, `main-macos.bot` the macOS application's
  (`macos_app.bot`'s App: next section but one; and imports `macos_link`,
  the macOS executable's link plan), each `sdl::create()` --
  and runs `game::main`. Keep everything else out of the entries, and every
  platform name out of the other modules.
* `sdl.bot` is the one module with SDL's raw authority: every function of
  it that makes a retaining C call or a native view or edit requires its own
  `Sdl` context, so `render.bot`, `game.bot` and the entries stay ordinary modules
  (`workload-icy-tower-sdl-modules-warning-clean` checks
  `hir::direct::summary`). Do not mark a game module `direct module`. The
  macOS-only `macos_app.bot` is the one other module that calls C (libSystem's
  write and getenv, CoreFoundation's alert), mediated the same way by its
  own App context (`workload-icy-tower-app-module`); it calls no SDL.
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
every push to any branch); once every test of a commit of main is green,
its release run publishes that commit's tested build as the
`icy-tower-windows-latest` release the README's Windows button links to
(CI-RUNS.md):
run it on the branch for any change to the game, `tests/cffi/sdl3.tcl`,
the generator's MSVC target or `tools/cheader/`.
Its signing (ICY-TOWER-WINDOWS.md, "Signing") is the `sign` job's alone:
only that job, in a manual run (a release run of main among them), in the
`windows-signing` environment, sees signing credentials -- never give them to the build job,
a pull request or another workflow, never store a signing key or password
in GitHub (Azure Artifact Signing through OpenID Connect), and never let the
release publish an unsigned build while `WINDOWS_SIGNING` is set. Every
build's signing dry run must keep passing: the executable must run with a
signature appended.

The macOS executable (`build-macos.sh`, ICY-TOWER-MACOS-MILESTONE-1.md: a
Cocoa application on macOS AArch64, the pinned SDL3 linked into it as a
static archive) is built and played only by the `icy-tower (macos arm64)`
workflow (`.github/workflows/icy-tower-macos.yml`, every push to any
branch): Botlish.app from the commit, the archive from
`tests/platform/sdl3-static-macos.sh` (the recipe
`tests/platform/link-plan-sdl3.sh` shares), the macos-aarch64 binding
generated on the runner (none is committed), the tests' macOS section, the
oracle and the graphical acceptance. Keep it so:

* `main-macos.bot` installs `macos_app::create()` (the application's
  std::io::IO: next item) and `sdl::Sdl` and imports `macos_link` --
  nothing else; the startup policy is the build's (`-native-startup
  main-thread` in build-macos.sh), never the source's.
* `macos_app.bot` (ICY-TOWER-MACOS-APP-MILESTONE-1.md) is the macOS
  application's process environment: std::io::IO over std::darwin::write
  with std::darwin::io's completion policy (change the two together), and,
  only when the bundle's LSEnvironment sets `ICY_TOWER_ERROR_ALERTS=1`, the
  run's first standard-error text shown in a CoreFoundation alert
  (CFUserNotificationDisplayAlert: no SDL, no window, no second event loop)
  before the write returns. A terminal run of the Mach-O never shows one.
  Its C declarations are hand-written and private, checked against the SDK
  by `audit/icy-tower/tools/app-abi-check.py`; never move the alert, or any
  macOS name, into a shared module (`workload-icy-tower-app-module-shared-
  sources-untouched`): the Linux and Windows executables are built from the
  same sources as before.
* `macos_link.bot` declares the staged archive (`static at
  "native/macos/libSDL3.a"`, relative to the application root) and exactly
  the frameworks and libraries SDL3's sdl3.pc names, in its order:
  build-macos.sh refuses any other list. When SDL3's metadata changes, take
  its list (`sdl3-static-macos.sh link-interface PREFIX`); never add, drop or
  weaken an entry by hand, and never edit the generated binding to make it
  static.
* The graphical acceptance (`audit/icy-tower/tools/macos-session.py` with
  `macos-input.m`) reads the game from outside: the window system's
  windows, captures checked against the oracle's geometry, keys through
  Quartz's event taps, the close button through Accessibility (else
  Command-W). Never push SDL events, hook the game or add an option to it
  for a test, and never count an ENVIRONMENT-BLOCKED case as passed.
* The SDL call trace of a static SDL3 is a link-time wrapper
  (`audit/icy-tower/tools/traced-archive.sh`, sdltrace.c's
  `SDLTRACE_LINKED`), compared with the Linux executable's reference,
  `audit/icy-tower/trace-reference.txt`: rewrite it
  (`audit/icy-tower/tools/trace-reference.sh EXE write`, on Linux) in the
  same change as anything that changes what the game draws or calls
  (`workload-icy-tower-trace-reference` fails otherwise).

If you change the game, an entry, `macos_link.bot`, `build-macos.sh`, the
SDL3 profile, `sdl3-static-macos.sh` or the macOS harness, push and read
the workflow; for the port's mutants push with `[ci-icy-tower-mutants]` in
the head commit's message (`audit/icy-tower/mutate.tcl -macos 1`: every
mutant in `audit/icy-tower/macos-mutants.txt` must still apply and be killed
by the detector its `??` line names; update a mutant's text when you change
the code it mutates, keeping it a mutant of the same rule). To recheck a few
mutants, run them by name (`mutate.tcl -macos 1 ... NAME ...`, or a manual
run with `mutants` and `mutants_only`): only their detectors' baselines run.
The harness's application bundles live under the home directory, never the
temporary one, whose bundles LaunchServices' lookup did not find.

### Icy Tower.app and its release (Developer ID, notarization)

`examples/games/icy-tower/package-macos.sh` assembles `Icy Tower.app` from
build-macos.sh's executable, byte for byte (`macos/bundle.py`: a structured
Info.plist, the Mach-O and the bundle checked as a whole);
`tools/macos-release/credentials.py` validates the release's seven GitHub
values; `tools/macos-release/release.py` is the trust path as gated stages
(keychain, notarytool's credential validation, sign, verify, record an
acceptance, notarize, staple, Gatekeeper, tamper, package, publishable,
cleanup) in three modes, `adhoc` and `dry-run` for ordinary CI, `release`
for the `release` job (ICY-TOWER-MACOS-APP-MILESTONE-1.md). The core is
application-neutral and shared with Botlish.app's release
(MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md): each application supplies its
description (`examples/games/icy-tower/macos/bundle.py`,
`single/macos/bundle.py`: its name, units, identifier, ZIP, signing) and an
entry point (`macos/release.py`, `single/macos/release.py`). Keep it so:

* One validator and one trust path: an application's description never
  checks a credential, skips a stage or adds one of its own; a rule both
  applications need goes into the core. Never let one application's
  release read the other's identifier or overwrite its release (their tags,
  names and assets differ, and publish refuses an existing release).

* Credentials live only in the `macos-release` environment and reach only
  the `release` job of icy-tower-macos.yml, for an `icy-tower-macos-vX.Y.Z`
  tag, and of botlish-macos.yml, for a `botlish-macos-vX.Y.Z` tag, of main's
  history, pushed, run by hand or dispatched again by the
  release gate, and only once every test of the tagged commit is green (the
  `tested` job, CI-RUNS.md) -- never a branch, a pull request, a fork,
  `pull_request_target`, another job or another workflow;
  each secret only in the `env` of the step that reads it, never in a
  script, a `with` or a job's `env`; no step holding one traces commands.
  Nothing is committed: no certificate but Apple's public ones
  (`tools/macos-release/apple-ca/`, pinned by SHA-256 in credentials.py),
  no key, no password.
* The preflight runs before any Apple tool and reports every problem under
  its stable code without a byte of a secret; a malformed value is never
  left for `security`, `codesign` or `notarytool` to report. A release never
  takes test trust anchors, never falls back to an ad hoc or dry-run
  signature, never skips a stage (each refuses to run unless the stages it
  depends on passed: `publishable` checks the whole sequence, one CDHash
  and one ZIP digest), and never publishes over an existing release.
* No entitlement, no `--deep`, no JIT or library-validation exception:
  neither application needs one (the compiler's driver has no JIT). The
  hardened runtime is on in every mode, so ordinary CI runs each bundle
  under it.
* No job changes a trust setting (`add-trusted-cert`, `authorizationdb
  write`, `spctl --master-disable`): a release trusts Apple's root, which
  is the system's, and the dry run's throwaway identity, which no runner
  can trust without a person, has its signature classified
  ENVIRONMENT-BLOCKED -- only codesign's chain refusal, never any other
  failure, and never counted as passed.
* The notarization key must be laid out as App Store Connect's .p8 (the
  curve inside its ECPrivateKey): notarytool 1.0.0 (38) traps, printing
  nothing, on the same key re-encoded without it, so the preflight refuses
  that layout, and the fixtures make Apple's (`fixtures.apple_p8`). Relax
  it only with a notarytool version's evidence.
* A notarization timeout is not a rejection: resume the submission
  (`notarize --resume ID`; the workflow's `resume_run` and
  `resume_submission`), never upload another copy for it.
* Apple's tools are found on PATH (release.py never names their paths), so
  `audit/macos-release/`'s stand-ins can run every stage on any host.
* The README's macOS download button and link name a release by its tag
  (`icy-tower-macos-vX.Y.Z`; there is no rolling macOS tag): a newer
  published release updates them, in a change of its own after the release
  exists. Never point them at a tag whose release is not published.

If you change `package-macos.sh`, `macos/`, `macos_app.bot`,
`tools/macos-release/`, the release jobs or `macos-session.py app`, run
`audit/macos-release/tests/` (test_credentials, test_release,
test_workflow, test_botlish_release, test_botlish_workflow;
`tests/workload-icy-tower.test`'s `workload-icy-tower-release-tooling` runs
them) and
`audit/macos-release/tools/mutate.py` (every mutant in its `mutants.txt`
must still apply and be killed by a test its `!!` line names: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule) with the pinned environment of
`audit/macos-release/requirements.txt`, and push to read the game job's
bundle, LaunchServices and dry-run steps; the release path itself runs only
for a release tag.

## Program output: executables and `run` (PROGRAM-OUTPUT-MILESTONE-1.md)

A program's value is the language's (its last top-level statement) and the
test infrastructure's oracle; printing it is main.tcl's development view
only (PROGRAM-RESULT-PRINTING-CENSUS.md). Keep it so:

* A standalone executable writes nothing of its own when its program
  completes: status 0, standard output and error the program's alone
  (`runtime::aot::run`). Never print the value, a trailing line or a
  status there, and never add a switch that brings one back. A run-time
  error stays `MESSAGE (CODE)` on standard error with status 1.
* The driver protocol (`BOTLISH_NATIVE_RESULT=FILE`) is the one way to read
  an executable's value: tests use tests/helpers.tcl's `standaloneValue`
  and `bareValue`; shell scripts without Tcl compare the words of the
  result file's `value V` line, its quoting removed (the `value_words`
  idiom of single/ffi-smoke-test.sh). Never parse an executable's standard
  output for its value, and never strip a "last line" from it.
* `main.tcl run [OPTION...] FILE [ARG...]` runs one program as a command:
  no header, no value line, every word after FILE the program's argument,
  natively unless `-backend` says otherwise, status 0 (completed) or 1
  (rejected, failed: the diagnostics or the error on stderr), 2 for a
  malformed invocation; only `-backend`, `-warnings`, `-target`, `-L` and
  `-F` combine with it. single/main.tcl's `MayLink` knows its native
  default. main.tcl's default run keeps its `== FILE (BACKEND)` header and
  `value:` line: it is the Tcl backends' only output, Compilerpedia's
  `@output` check and many tests' observable.
* The exit status is planned as the program's top-level value -- an Int,
  or `unit` for 0 (success) -- with no early exit by design: never add an
  exit function, a top-level `return`, or a status from anything else.
  Until that milestone a completed program's status is 0. Icy Tower's
  declared C `exit` is a workaround of the game's, not a pattern.

If you change any of that, run `tests/native-executable.test`,
`tests/main-cli.test`, `tests/native-program-output.test`,
`tests/workload-2048.test`, `tests/workload-icy-tower.test`,
`audit/native-aot/tools/mutate.tcl` (its `result-printed` mutant) and, for
single/main.tcl, `audit/single-executable/tools/mutate.tcl` (its
`run-command-not-linking` mutant) and both smoke tests after
`single/build.sh`.

## Running a program as its executable (-aot-run)

`main.tcl -aot-run [OPTION...] FILE [-- ARG...]` (AOT-RUN-MILESTONE-1.md)
builds the program exactly as `-emit-native-executable` does and runs that
file as a command: `native::aotRun` lowers it with `native::ExecutableText`
(the one compilation of an executable, `native::executable`'s too), and
the driver's `aot-run` (native/src/aotrun.rs) links it with
`codegen::aot::emit_executable` into a private directory and starts it.
Keep it so:

* No second pipeline and no in-process run: never run the program in the
  driver's process, never cache an executable, never run a file this
  command did not just link. The directory is new every run (created
  exclusively, owner-only on Unix) and removed when the program ends
  (`-aot-keep` keeps it); a failed build or link runs nothing.
* The program's arguments are exactly the words after `--` (argv()[0] is
  FILE as typed); its standard streams, working directory and environment
  are the command's (a packaged compiler's own settings put back:
  `childEnvironment`, `--child-env`); nothing of its output passes through
  the compiler. Its exit status is the command's, 128+N for a signal on
  Unix; SIGTERM and SIGHUP are forwarded, SIGINT and SIGQUIT are not (the
  terminal sends them to the group); the program never outlives its
  command (the parent watch).
* The host's target only, and the startup policy the executable's
  (`-native-startup`): a foreign target is a usage error, main-thread where
  unsupported `NATIVE UNSUPPORTED startup`.
* The JIT is the driver's `jit` cargo feature (default on): `-aot-run`
  never needs it, and a driver without it refuses only the in-process
  commands (run, bench, batch, vms). Never make anything but those depend
  on the JIT, and never turn it off for a build other than Botlish.app's.

If you change aotrun.rs, launch.rs's Windows spawn and wait,
`native::aotRun`, `native::ExecutableText`, RunDriver's `run-command`
mode, main.tcl's `-aot-run` or JIT boundary, or the `jit` feature, run
`cargo test --release --manifest-path native/Cargo.toml --bin
botlish-native aot_run`, `tests/aot-run.test` (also with
`BOTLISH_NATIVE_LINKER=system` and `stub`, and with a driver built
`--no-default-features --target-dir native/target/no-jit`),
`tests/main-cli.test`, `tools/compilerpedia.tcl check` and
`audit/aot-run/tools/mutate.tcl` (every mutant in its `mutants.txt` must
still apply and be killed: update a mutant's text when you change the code
it mutates, keeping it a mutant of the same rule), and read the Windows
and macOS workflows on the branch. `bench/aot-run.tcl` measures the costs.

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

## Package-scoped modules (.bot_modules)

A package is an ordinary module tree installed under the immediate
`.bot_modules` directory of its owner (BOT-MODULES-MILESTONE-1.md):
ROOT/.bot_modules/NAME for the application's package NAME,
PKG/.bot_modules/D for package PKG's own package D. Every module file has an
owning scope -- the application, the standard library or one package
instance -- and an import is resolved by its first segment in the importing
file's scope only (`surface/modules.tcl`'s `Locate`): `std::...` the
standard library's; a segment naming a package installed in that scope the
package's (it claims the whole root namespace there); otherwise the scope's
own tree (the application's files; a package's own root namespace). Keep it
so:

* Downward only: never search a consumer's modules or packages, a sibling's
  or an ancestor's, a working directory, an environment variable or a path
  list, and never fall back from one origin to another. Two candidates are
  MODULE-COLLISION, never a precedence; a package named std is
  RESERVED-NAMESPACE. The entry file is no module and collides with
  nothing.
* No package manager in the compiler: never read `botlish.json`, a version,
  a lock, a registry or the network; the installed directories are the
  whole of a package's scope. Installation gives no privilege: a package's
  modules are ordinary modules (never standard-library modules: no
  internal namespace, no intrinsic), with the ordinary `private`, contexts,
  direct-module rules and C FFI; never add package-level visibility, an
  import alias or a version in source syntax.
* A package instance is its place in the logical dependency tree (physics,
  physics/geometry), never an absolute path, a version or a load order. A
  module's canonical identity is the instance and its namespace below the
  package's root (`Identity`): the application's and its direct packages'
  modules keep their spelling, a package's own package's begin with the
  instance (`physics/geometry::Point`, which no source can spell). Every
  stage after the loader keys a module by its identity: the loader
  rewrites a file's qualified spellings to identities wherever one differs
  (`RewriteQualified`), with the same traversal that checks them
  (`QualifiedRefs` and `RewriteQualified` are one `Walk`, and
  `surface::ast::MapChildren` is `Children`'s traversal). A new place where
  source writes a qualified name goes into `Walk`, never a second walker;
  never merge two instances by spelling downstream, and never parse a
  spelling where an identity is expected.
* A validator of identities accepts the instance separator "/"
  (core/ir.tcl's enum literal, core/type.tcl's `register`): keep any new
  one so.
* The loader's package probes go through the source seam's `directory`
  question (`surface::source::directory`, recorded in the snapshot) and are
  the front-end cache's dependencies (`probes`, `surface::cache::
  Dependencies`): a new resolution input goes there too. The physical
  package directories on the loading stack stop a symbolic-link cycle
  (CYCLE); never drop that guard.
* A package graph (`PACKAGES/.graph`; SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md,
  surface/modules.tcl's "Package graphs") makes the packages it names one
  instance each, shared by every scope that uses them: a graph package's instance and identity are its name, from every
  scope (`Instance`); a scope of the graph sees exactly the packages the
  graph says it uses (`Installed`), never another package's dependency, the
  application's modules or a hand-installed package; a graph package's own
  `.bot_modules` is never read; every graph package claims its root
  namespace in the application. The graph names scopes and packages and
  nothing else: never put a version, a lock or a source in it, never let
  the compiler choose or repair one, and read it through the seam
  (`Probe file`, a cache dependency). A malformed graph is PACKAGE-GRAPH,
  never a tree read instead. Hand-made nested trees (no graph) keep
  instance-by-place identities.

If you change resolution, identity, the rewrite, the seam's directory
question or the cache's probes, run `tests/bot-modules.test`,
`tests/imports.test`, `tests/application-modules.test`,
`tests/std-namespace.test`, `tests/surface-modules.test`,
`tests/hir-cache.test`, `tests/compiler-service.test`, `tests/lsp.test`,
`tests/compilation-isolation.test`, `tests/hir-interchange.test` and
`audit/bot-modules/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule), plus the
mutation harnesses whose mutants edit `CheckRef` or `CheckImports`
(module-privacy, error-payloads, hashable, type-predicates) and the
HIR-interchange and compiler-service ones for a change to the cache or the
seam. Icy Tower's builds stage the SDL3 binding as a package (`tools/
c-bindgen.tcl stage -package 1`); `tests/workload-icy-tower.test` and the
`icy-tower` workflows cover them.

## The package manager (pm/, botlish.json, .botpkg)

`pm/` (PACKAGE-MANAGER-MILESTONE-1.md, PACKAGE-MANAGER-MILESTONE-2.md,
PACKAGE-MANAGER-MILESTONE-3.md) is the package manager: `main.tcl
add|install|update|remove|verify|package|native` (`botlish add ...` in the
single executable), over local `.botpkg` artifacts (BOTPKG-FORMAT.md),
`botlish.json` (BOTLISH-JSON.md, schemas 1, 2 and 3) and, on the author's
side, provenance records (BOTPKG-PROVENANCE.md). It builds the
`.bot_modules` trees the compiler already reads (previous section) -- and,
for target-aware packages, their target views -- and, for an author, a
package directory and its release; nothing else. Keep it so:

* The compiler never reads `botlish.json`, a version, a lock, an artifact
  or `.bot_modules/.botlish`, and never loads `pm/`: main.tcl sources
  `pm/pm.tcl` only when its first argument is a package command, before the
  compiler is loaded. Never make compilation restore, update or check
  packages, and never add a version, an import alias or new syntax for
  packages. A hand-assembled `.bot_modules` compiles exactly as before.
* Nothing a package holds is executed -- at packing, inspection,
  verification or installation: no hook, script, build step, binary or
  compilation, no `exec` but `kill -0` (a lock holder's liveness), no
  socket, no network (`pm-no-network-in-sources`). Native archives travel
  as opaque files built on the author's side (`tools/package-repository.tcl`).
* Each package owns its direct requests and exact locks, and the
  application has one dependency graph (pm/graph.tcl;
  SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md; LANGUAGE-DESIGN-PRINCIPLES.md,
  section 2): every package once, at `.bot_modules/NAME` (no package has a
  `.bot_modules` of its own), at the one version every lock of it names,
  and `.bot_modules/.graph` (and each view's) written from it in the same
  transaction. Resolution is unification, never search: every demanded
  release is explored, and two demanded versions are a
  DEPENDENCY-CONFLICT naming every lock and its path. Never relax, move or
  override a lock -- the application's or an author's -- to make the graph
  agree, never make a second instance as a fallback, never select the
  first version visited, never let an editable directory satisfy a
  package's lock, never write a transitive lock into an application, and
  never let a lock change without `add`/`update` (install never moves one;
  `add` and `update` choose, within a request, the version the graph's
  locks hold, and say so). No peer dependencies and no override syntax: a
  departure is a language-design decision. Results and messages depend on
  no order (declarations, repositories, traversal: the catalog keeps its
  repositories sorted). A request's precision is its components (`1`,
  `1.2`, `1.2.3`): no operators, prereleases or ranges.
* Artifacts are immutable and validated whole before anything is written:
  the restricted ZIP profile, the path rules, the limits, streamed capped
  decompression, every CRC, and the descriptor in the artifact context
  (complete compatible locks, no sources). Never relax the reader to accept
  an archive another tool made, follow a link, write outside the staging
  directory, or choose between two artifacts claiming one release (no
  precedence among repositories). Repositories are named on the command
  line only: never search a parent, the working directory, a global
  directory or the environment.
* Every operation is one transaction (`pm/install.tcl`): stage, journal,
  rename, record, descriptor, commit marker; a failure rolls back and an
  interrupted one is rolled back (or finished, once committed) by the next
  command. A `.bot_modules` entry the record does not name is the user's:
  never modified, replaced or deleted; a managed package that changed is
  replaced only with `-force`.
* Integrity is not authenticity: a digest checks bytes against a record;
  never describe a local artifact as signed, verified or authenticated
  publisher content.
* One release is one artifact for every target it names (schema 2's
  `targets`): never several archives claiming one name and version for
  different targets, never a target suffix in a version, never a target
  file fetched apart from its artifact. The package's own metadata decides
  the targets it supports: never assume a package portable to a target it
  does not name (`UNSUPPORTED`), and never take common files alone for one.
* Target views (pm/view.tcl) are derived, never edited: the store
  (`.bot_modules/NAME`, PM-1's tree) is the installation; each view
  `.bot_modules/.targets/T` is a function of the store's record, the target,
  the consumer's origins and the manual packages it links, rebuilt in the
  same transaction as any change to them, and reused when its digest and
  files are unchanged. Preparing one target never touches another's view.
  The compiler knows only the directory's name (surface/modules.tcl's
  `ApplicationTree`: never a version, a record or native metadata), and an
  empty `.targets` is never left (it would hide every package). A
  `.targets` the manager did not make is the user's (MANUAL).
* Native files are inspected, never run (pm/binary.tcl: ELF, ar, Mach-O,
  PE/COFF read as bytes); a bundled library's every declared fact (format,
  architecture, kind, loader identity, loader dependencies, symbols) is
  checked against its file at packing and at every view, the driver's
  archive check still judging a link. A system library is verified only on
  its own target's host and only by the distribution's metadata (dpkg's
  database, a pkg-config record under /usr): never by a file merely present
  (/usr/local is no system metadata), never claimed for another target.
  The native closure is the application's, one loader namespace: a
  conflict (two bundles of one name, bundled against system, one loader
  identity for two libraries, a duplicate static symbol, static against
  shared, a source declaration against the metadata) is refused, never
  resolved by a choice the consumer did not make (`origins`).
* Metadata never injects a linker flag: link inputs reach the compiler as
  files of a view's `.lib` (searched like -L) and the source's own link
  declarations; a runtime search path is the application builder's
  `-runtime-path`, a structured driver option (`--runtime-path`), never
  package metadata. Deployment (`native deploy`, pm/deploy.tcl) places only
  files it records, as a transaction, and signs nothing.
* SHA-256 is the system's own tool at its fixed path (pm/sha256.tcl:
  `/usr/bin/sha256sum`, `/usr/bin/shasum`, `%SystemRoot%\System32\certutil.exe`),
  given the exact bytes, after a known-answer probe, else the Tcl
  implementation: never a tool found on PATH, never OpenSSL's command line,
  and never the native backend. SHA-1 (pm/sha1.tcl, the same rules) exists
  only to compute Git object identities for provenance checks: never an
  integrity digest of the package manager's own.
* The author's side (pm/author.tcl: `native add`, `native require`,
  `package stage`, `native audit`; PACKAGE-MANAGER-MILESTONE-3.md) builds
  nothing and runs nothing: an author builds native files with their own
  tools first, and the commands read them as bytes. Every fact a file can
  establish (format, architecture, loader identity, loader dependencies,
  exports, RUNPATH) is taken from the file, never typed by hand; what it
  cannot (which needs the system provides, what is opened at run time, a
  license) is the author's statement, and the reports say which is which.
  Never infer a library's name, origin or linkage intent from a file name,
  never auto-declare exports as required symbols, never record an observed
  system version as a requirement. Existing metadata or a file that
  differs is a CONFLICT unless `-replace`; staging copies regular files
  only (never follows a link), and `-replace` makes a directory exactly its
  source. An operation raises botlish.json's schema only to what its
  contents need. The author's side (author.tcl, sha1.tcl, release.tcl)
  is loaded by `pm::authoring`, only for the operations that use it: never
  source it with the rest of `pm/`, which every consumer command loads.
* Run-time dependencies (schema 3's `runtime`: a library opened by name, a
  facility) are never loader dependencies: never in `needs`, never in the
  link, never a problem of the native plan, never a reason an installation
  fails. A loader dependency is never declared as one.
* `package pack` of a target-aware package runs the audit and refuses an
  incomplete one (an unresolved loader dependency, a declared fact the
  file contradicts, an absolute or empty RUNPATH entry, an undeclared
  native binary, a platform library bundled, targets with different
  modules, a link or a C function no library provides); "partially
  verified" (facts this host cannot check) packs. A pure-Botlish package
  never runs the audit. Never add a way to skip it.
* Provenance (pm/release.tcl, BOTPKG-PROVENANCE.md) is evidence, never
  authentication: a record beside the artifact, bound to its SHA-256, never
  inside it; computed facts, the author's assertions and the checks made
  stay apart; a check an assertion fails stops the pack (nothing written);
  a record never holds a local path, a host path or a credential. Never
  describe a record as a signature or as verified provenance, never run git
  or another tool to "check" an assertion (the Git tree is recomputed from
  the files), and never put a time or a host fact in a record.
* One version, one artifact: `packages/RELEASES.tsv` records each release
  of this repository's packages by its SHA-256, once, never changed;
  `tools/package-repository.tcl` reports a rebuild that does not reproduce
  a recorded release as a CANDIDATE, and with `-release` refuses it (never
  publish a candidate). A change to a package's contents is a new version.
  The releases are built in the pinned author image
  (tools/package-build/: a base image by digest, Ubuntu's snapshot at one
  instant, Tcl 9 by SHA-256), whose independent builds reproduce them;
  never pin a tool by a mutable name there.

If you change `pm/`, the formats, `tools/package-repository.tcl`,
`tools/package-build/`, `packages/*/botlish.json` or main.tcl's dispatch, run
`tests/package-manager.test` (its `pm-shared-*` tests: the one graph), `tests/package-native.test` (its foreign
formats need clang and MinGW-w64; its linked runs the native backend),
`tests/package-authoring.test` (clang, lld and MinGW-w64 for its foreign
formats, git for its Git trees),
`tests/package-workloads.test` (its packages are packed for linux-x86_64 and
linux-aarch64: it needs the AArch64 GNU cross compiler, clang, cmake and
ninja, and the package-owned libSDL3 and libraven: `tests/cffi/sdl3.tcl`,
`tests/cffi/raven.tcl`), `tests/main-cli.test`, `tests/bot-modules.test`
and `audit/package-manager/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed: update a mutant's text when
you change the code it mutates, keeping it a mutant of the same rule; a
mutant's `%%` line names the test files that kill it). A change to
resolution, the graph file or what reads it (pm/graph.tcl, the graph parts
of pm/install.tcl, pm/view.tcl, pm/commands.tcl's `add`, `update` and
`package graph`, surface/modules.tcl's package graphs) also runs
`audit/shared-dependencies/tools/fuzz.tcl` (several seeds: the package
manager against its independent resolver, `oracle.py`, whose `selftest`
runs too), `audit/bot-modules/tools/mutate.tcl` (its `graph-*` mutants),
`tests/package-workloads.test`'s `pw-shared-*` (two libraries over one
event_loop_linux, run against epoll) and, after `single/build.sh`, the clean
room (`audit/shared-dependencies/cleanroom/cleanroom.sh image`, then
`repository.sh OUT` and `cleanroom.sh run single/out/botlish OUT RESULTS`:
the single-file compiler and published artifacts only, no network).
`bench/shared-dependencies.tcl` measures resolution against a baseline
checkout (`-root`). A change to a package's recipe or the author image also runs
`tools/package-build/author.sh build OUT -release` twice (two fresh
containers: their artifacts and records must be identical and equal the
recorded releases) and, on a branch, `package-reproducibility.yml`
(two runners). `bench/package-manager.tcl` measures its costs. A change to the single
executable's dispatch (`single/main.tcl`'s package commands) also runs the
single-executable checks above. A change to the compiler's target package
trees (`ApplicationTree`, `nativeDirs`) also runs the package-scoped-module
checks of the previous section and `tests/hir-cache.test`,
`tests/hir-interchange.test`, `tests/compiler-service.test` and
`tests/lsp.test`; one to `--runtime-path` the native-AOT checks
(`cargo test ... --bin botlish-native aot::`, `tests/native-link-plan.test`,
`tests/system-linker.test`).

## The raven release (desktop build, clean room)

`packages/raven` is released as one desktop-capable artifact
(RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md): `raven-VERSION.botpkg` holds, per
Linux target, the generated binding, the bridge's archive and Raven's
*desktop* build (X11 and the Vulkan renderer), which also runs headless; its
common files are the module, README.md and GUIDE.md (the consumer's
documentation), `examples/clicks` and Raven's license notices.
`tools/package-repository.tcl OUT raven` is its author's one operation
(`tools/package-build/author.sh build OUT -release raven` in the pinned
author image, for a release). Keep it so:

* One library for both configurations: never pack the headless build, and
  never add a second artifact, a feature flag or a variant of one release
  for headless use. A `raven` change of contents is a new version: the tool
  refuses to overwrite a different `NAME-VERSION.botpkg` (`-force` only
  for a local file the author means to replace).
* The event bridge (native/raven_bridge.c, RAVEN-BINDINGS.md section 5)
  only records: it never calls Botlish, never keeps a pointer Raven gave
  it, and its one input hook (`watch_input`) answers "not consumed" to
  every event, so watching a window changes nothing Raven does
  (`raven-input`). A press is an event of its own (KeyPressed,
  MousePressed), never derived from state; consecutive moves are one
  record. Every number a record holds is finite, so `events()`, `rect()`
  and `mouse_position()` declare no error: never make them fallible again
  for a value Raven cannot produce. A change to the record or its kinds
  bumps the bridge's ABI and raven.bot's check together.
* Builds are recognized by their configuration's stamp
  (tests/cffi/raven.tcl: `headless`, `desktop`), never by a library merely
  present; the desktop build's Vulkan headers are the pinned Khronos commit
  (never Raven's own unpinned download), the AArch64 libX11 the pinned,
  SHA-256-checked Ubuntu packages (author side only, never packed). Never
  download an unpinned input to make a build pass.
* libX11 is a declared *system* library (the bundled libraven's DT_NEEDED,
  verified by the system's metadata); the Vulkan loader and driver, the
  display, libX11-xcb and libdbus are opened at run time: schema 3
  run-time dependencies (the desktop and accessibility capabilities,
  PACKAGE-MANAGER-MILESTONE-3.md), never loader dependencies. Never bundle
  a graphics driver, the loader or X11, and never declare the loader as a
  system library (it would make headless use require it). A missing one is
  reported by `start`'s RavenFailed, whose detail lists every error Raven
  reported while it started (`startup_reasons`).
* The release's metadata is derived, never written in packages/raven:
  the recipe (`tools/package-repository.tcl`'s `author::raven`) imports
  each target's built files with `native add` and states the rest with
  `native require`; Raven's license and notices (licenses/raven/) travel
  in the artifact. The AArch64 cross build is configured with
  `-DCMAKE_SKIP_RPATH=ON`: without it CMake records the build machine's
  cache path (and an empty, current-directory entry) as the library's
  RUNPATH, which made raven 0.3.1 differ between machines and which the
  audit refuses.
* The package's documentation is checked: every ```botlish block of its
  README.md and GUIDE.md is a complete program (`raven-package-docs`
  compiles them and runs the test ones); a fragment goes in a plain fence.
  It documents what the wrapper does today, for a consumer who has only
  the artifact and the single-file compiler.
* The clean room (`audit/raven-cleanroom/`: `tools/cleanroom.sh`, its
  Dockerfile) holds operating-system facilities only -- never Tcl, Rust,
  CMake, Ninja, a checkout or a mount of one -- and runs with no network;
  its harness acts on the program only through the X server.

If you change `packages/raven`, the raven recipe of
`tools/package-repository.tcl`, `tests/cffi/raven.tcl` or
`audit/raven-cleanroom/`, run `tests/raven.test` (its desktop tests need
`tclsh9.0 tests/cffi/raven.tcl desktop`, Xvfb, Mesa's Vulkan driver,
python3 and libXtst), the `pw-raven-*` tests of
`tests/package-workloads.test`, `audit/raven-cleanroom/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), and the clean room (`audit/raven-cleanroom/tools/cleanroom.sh
image`, then `run single/out/botlish OUT/raven-VERSION.botpkg DIR` after
`single/build.sh`; the `raven clean room` workflow runs it on a push that
touches these files). The manual `tasks app (raven, manual)` workflow builds
the experiment's Tasks app with `audit/raven-cleanroom/tools/build-app.sh`
(the clean room's consumer build) and publishes it as an artifact: run it
after a change to `build-app.sh` or the release.

## The http and boringssl packages (HTTP client)

`packages/http` is the official HTTP/1.1 and HTTP/2 client with TLS
(HTTP-CLIENT-PACKAGE-MILESTONE-1.md; its README.md and GUIDE.md are the
user's documentation): Hyper and BoringSSL in a Rust unit
(`packages/http/native`, crate `botlish_http`, built and localized by
`tools/http-package.tcl` into `native/libbotlish_http.a`), driven by the
program's own event loop and the Linux driver package; `packages/boringssl`
is the provider (BoringSSL's pinned release, `packages/boringssl/PIN`, in
one archive of its own name, `libbotlish_boringssl.a`, with the provider's
identity symbol). `tools/package-repository.tcl`'s `author::boringssl` and
`author::http` are their release recipes. Keep it so:

* Nothing of them enters the compiler, the runtime, the standard library or
  the single executable: a consumer installs the released artifacts and
  compiles none of their native code. No Tokio runtime and no second
  scheduler: the unit's executor runs a bounded batch per `bh_step` (the
  module's budget) from a task of the loop, its timers are the loop's
  clock, its readiness the driver's watches; the only threads are the name
  resolver's, which answer and wake the loop (`botlish_event_post2`, which
  names the runtime's own loop: never the version 1 post, which another
  Botlish thread's loop makes refused).
* One thread of a process has the runtime at a time (std::thread: the
  resolver's pool and the process counters are shared): `bh_open` claims
  it, another thread's is refused (`ERR_OPEN_ELSEWHERE`, the module's
  `Fault`), and the claim ends at `bh_close` or with its thread
  (`http-one-thread`, `http-beside-thread`). Never let two threads' runtimes
  share the pool silently; per-thread runtimes need the pool and counters
  made per thread first.
* The public interface is Botlish values, declared errors and resources:
  no handle integer, Rust type, BoringSSL object or raw status reaches a
  program (every `bh_*` is `private`); a client and an exchange are
  resources released where their owners' scopes end. Never add a public
  function that takes or returns a handle, a descriptor or a pointer.
* TLS is verified, always: chain, host name (or IP address) and expiry,
  against the system's bundle and the anchors a program passes as data.
  Never add a switch, an option, an environment variable or a test-only
  path in the released unit that turns verification off or reads another
  trust file (the bundles are the documented `SYSTEM_BUNDLES`).
* Test-only behavior is the `testing` feature's (fault bits, counters, a
  counting allocator, the `bh_t_*` exports): the released unit compiles
  every fault check to `false` and exports only `bh_*`
  (`http-unit-exports`). Never read an environment variable in the unit.
* The provider is identified, not assumed: the unit references
  `botlish_boringssl_<tag>_<commit>`, which only the provider package's
  archive defines (`http-provider-identity`); the http package locks the
  boringssl release it was built against, and a graph with another release
  is a DEPENDENCY-CONFLICT. Never prefix, patch or bundle BoringSSL into
  the unit (boring-sys builds link-only against empty archives).
* Releases are reproducible: `--locked`, one codegen unit, remapped paths,
  deterministic archives; the pinned author image (tools/package-build/)
  carries the Rust toolchain. `http` 0.1.0 and 0.2.0 and `boringssl`
  0.20261020.0 are recorded in packages/RELEASES.tsv: any change under
  `packages/http` or `packages/boringssl` (its documentation included:
  the artifact holds it) is a new version, built and recorded as they
  were.

If you change `packages/http`, `packages/boringssl`, `tools/http-package.tcl`
or their recipes, run `tclsh9.0 tests/cffi/http.tcl` (it builds the
provider and both units into Botlish's cache), `tests/http-client.test`
(independent peers: Python's asyncio, ssl and `h2`, which it needs, and
nghttpd where installed), `tests/resources.test`,
`audit/http-client/tools/syntax-fuzz.tcl` (several seeds; URIs and header
fields against their oracles) and `audit/http-client/tools/mutate.tcl`
(every mutant in its `mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), plus the clean room for a change to what a consumer
installs or links (`audit/http-client/cleanroom/cleanroom.sh image`, then
`repository.sh OUT` and `cleanroom.sh run single/out/botlish OUT RESULTS`
after `single/build.sh`: the report's "Clean room").
`audit/http-client/tools/measure.tcl` regenerates the measurements.

## The process_linux package (supervised child processes)

`packages/process_linux` is the official package for launching,
supervising, talking to and terminating external processes on Linux x86-64
(PROCESS-LINUX-PACKAGE-MILESTONE-1.md; its README.md and GUIDE.md are the
user's documentation): a Botlish module over a C adapter
(`native/process_linux.c`, built on the author's side into
`native/libprocess_linux.a`: tools/process-linux.tcl for tests,
`tools/package-repository.tcl`'s `author::process_linux` for the release),
scheduled by the program's own event loop through the Linux driver package.
It grew from the census MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-
MILESTONE-1.md (audit/managed-subprocess, which stays the experiment).
Keep it so:

* No language, compiler or standard-library change for processes, and no
  second scheduler: every pipe and the child's exit (its pidfd) are
  event_loop_linux watches; no polling, no thread, no signal handler, no
  SIGCHLD handler, never `waitpid(-1)` or `waitid(P_ALL)`. A stream that
  keeps delivering yields to the loop every `burst` chunks (`fair`): never
  drop that.
* No shell, no PATH search: a command is an executable path and an exact
  argument vector; a NUL in any item is InvalidCommand before anything
  starts. Bytes stay bytes: nothing decodes, splits or accumulates a
  stream in the package.
* Identity safety: a child is signalled only through its pidfd (group
  signals with PIDFD_SIGNAL_PROCESS_GROUP; before Linux 6.9 kill(-PGID),
  only while the leader is unreaped), and reaped only once its supervision
  is over; never signal a PID number, never signal after the reap, never
  use glibc's `pidfd_spawn` (it leaks its pidfd when exec fails, where
  glibc lacks its fix: the testing build keeps it as a negative control,
  reported, never required). A kernel without
  pidfds, or a process whose SIGCHLD is ignored, is Unsupported -- never a
  fallback to PID numbers.
* Ownership: ChildOwner is an affine resource whose release (also at its
  lexical scope's end) sends SIGTERM and hands a running child to the
  reaper task (grace, SIGKILL, reap, retire); a cleanup never waits. The
  identity (Child) is StaleChild once its owner is released, at once.
  `detach` is the only way to outlive the owner. When supervision ends,
  members of the child's group still running once the leader exited are
  killed. Interrupt cancels waits, never the child.
* Threads: a child belongs to the thread (the token, never a pthread_t)
  that spawned it; another thread's call is refused; a thread's end kills
  and reaps the children it still supervises (`thread_ended`), and process
  exit sends SIGKILL to every supervised group (`process_ending`). Child is
  never sendable. No process-wide subreaper, cgroup or PTY in this package.
* Authority: starting a process requires the installed Processes context;
  every extern is `private`. The released archive defines exactly the
  module's `pl_*` functions and reads no environment variable; fault bits
  and probes (`pl_t_*`) exist only with PL_TESTING (tests/process/probe.bot).
* The adapter is built `-Werror`: a mutant of it must leave no variable
  unused, or its kill is a build failure, which the harness reports
  NOT-BUILT.

If you change packages/process_linux, tools/process-linux.tcl or the
recipe, run `tests/process-linux.test` (Linux x86-64, cc; its tty tests
need python3; it includes GC stress and the documentation's programs),
`audit/process-linux/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/process-linux/tools/mutate.tcl` (every mutant in
its `mutants.txt` must still apply and be killed by a test its `%%` line
names: update a mutant's text when you change the code it mutates, keeping
it a mutant of the same rule), the warning gate's view of the module (a
program importing it compiles under `-warnings error`), and, after
`single/build.sh`, the clean room (`audit/process-linux/cleanroom/
cleanroom.sh image`, then `repository.sh OUT RELEASES` and `cleanroom.sh
run single/out/botlish OUT RESULTS`). `process_linux` 0.1.0 is recorded in
packages/RELEASES.tsv: any change under `packages/process_linux` (its
documentation included) is a new version, built in the pinned author image
(`tools/package-build/author.sh build OUT -release process_linux`).
`bench/process-linux.tcl` regenerates the measurements.

## External tools and target support packages

A package may carry tools and target runtime artifacts
(EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md; BOTLISH-TOOLS.md
is the protocol, BOTLISH-JSON.md section 14 the key): `botlish.json` schema
4's `tools`, run only by `botlish tool` (pm/tools.tcl, a package-manager
command: the compiler is not loaded); a target support package's
`botlish-target-support.json`, read only by `-emit-native-executable
-target-support NAME` (native/support.tcl); and the native library
manifest, schema 2 (native/library.tcl's `Manifest`), what tools consume.
Keep it so:

* Installation never implies activation: no operation but `tool` runs a
  package's program -- not add, install, update, remove, verify, a view, an
  import, a compilation, `tools` -- and no installed file is ever
  executable (the program is copied into a private directory and made
  executable there, by `tool`, after its bytes are checked against the
  installation record). Never add a hook, a post-install step, automatic
  activation, a compiler pass, a plugin loaded into the compiler process,
  a grammar extension, an intrinsic or a diagnostic contributed by a
  package, or a tool the compiler starts by itself.
* Resolution is explicit: only the project's direct dependencies provide
  runnable tools; a short name two of them declare is TOOL-AMBIGUOUS, never
  resolved by order; a transitive package's tool is TOOL-NOT-DIRECT; an
  unknown protocol, a program for another host (the host's program runs,
  whatever -target says) and a changed or missing program are refused
  before anything runs. Never fall back to another tool.
* The process boundary: a tool's words reach it exactly, never as shell
  text -- Tcl's exec reads words starting with <, >, | or 2> as
  redirections, so Unix goes through the fixed /bin/sh trampoline
  (`pm::tools::trampoline`: positional parameters only), and a test that
  passes such words to a command does the same. The tool's exit status is
  the command's; a signal, or a change to the installation (the snapshot
  against the record taken before it ran), fails it. The project stays
  locked while a tool runs.
* Tool packages use ordinary dependencies: their locks join the one graph
  (pm/graph.tcl) like any package's; never resolve a tool's dependencies
  apart, never weaken a lock for one, no peer dependencies.
* The request carries paths, names and facts, never a value of the
  environment (only whether a declared variable is set), a time or compiler
  memory; a tool consumes artifacts, never the HIR. A new request member or
  input kind is a new protocol number.
* The manifest binds its build: each artifact's SHA-256, the runtime ABI
  fingerprint, ownership and release functions as data. Its keys stay in
  their fixed order and two builds give the same bytes; `tool -artifact`
  refuses a manifest whose files differ, of another schema or target.
  Library mode links with libbotlish_native.a beside the driver, else the
  runtime archive (what the single executable carries); single/main.tcl's
  `MayLink` counts -emit-native-library.
* Target support is declarative and explicit: the compiler reads a
  package's descriptor only when -target-support names it, from the
  compilation target's package tree (never the host's), and checks it --
  and the runtime archive's own identity record (`runtime::aotimage::
  identity_record`: the triple and `ABI_FINGERPRINT`, a static of
  native/runtime-archive, read from the bytes, never by running anything)
  -- before any linker runs. Never accept an archive for a target by its
  architecture alone (another OS or C library ABI is refused), never fall
  back to the driver's own runtime archive when the named package is
  missing, never let a descriptor add a linker flag (its system libraries
  are compared with the system linker's, never added), and never give a
  target support package code generation: an unknown target stays unknown.
  `ABI_FINGERPRINT` is the same digest `abi_fingerprint()` always computed
  (`abi_fingerprint_constant_is_the_digest_of_its_words`): never fork it.

If you change pm/tools.tcl, schema 4 (pm/descriptor.tcl), the tool command
dispatch (pm/commands.tcl, main.tcl, single/main.tcl), native/support.tcl,
`-target-support` (main.tcl, native::executable's -runtime-archive, the
driver's --runtime-archive and `runtime-abi`), the identity record, the
manifest, library mode's runtime archive, audit/external-tools/src/ or its
packages, run `tests/external-tools.test`, `tests/native-library.test`,
`tests/package-manager.test` (its descriptor tests), `tests/main-cli.test`,
`audit/external-tools/tools/mutate.tcl` (every mutant in its `mutants.txt`
must still apply and be killed by a test its `!!` line names: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule), `cargo test --release --manifest-path native/Cargo.toml --lib
aotimage` for the fingerprint or the record, `tests/system-linker.test` for
the driver's runtime archive, and, after `single/build.sh`, the clean room
(`audit/external-tools/tools/packages.sh OUT native/target/release
single/out/botlish`, then `audit/external-tools/cleanroom/cleanroom.sh
single/out/botlish OUT/repo RESULTS`; the single-executable workflow's
build job runs both).

## The React Native integration (botlish_react_native)

`integrations/react-native/` is the external tool package
`botlish_react_native` (BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md;
its README is the tool's documentation). Its protocol 1 tool
`react-native` turns a Botlish native library into a React Native New
Architecture npm package: a Pure C++ TurboModule, Android arm64-v8a. It
reads the library's manifest (schema 2), header and Android AArch64 shared
object. `examples/react-native/` holds the 2048 facade (`2048/game.bot`), a
second, unrelated library (`textkit/textkit.bot`) and the React Native
0.88.1 app that plays 2048 through the generated package
(`app/`, `useBotlish2048`). Keep it so:

* Nothing of React Native enters the compiler, the runtime, the standard
  library or the single executable. No Hermes, Node, Gradle, CMake or JNI
  knowledge, no compiler pass, no export or ABI change made for it. The
  compiler never loads the tool, and installing it runs nothing.
* The tool knows Botlish through the request and the manifest only. It
  reads no source, HIR, compiler internals or checkout file, and its
  templates are compiled in (`src/embed.c`). It checks every fact before it
  writes a byte:
  - the manifest's schema, C ABI version, target and runtime ABI;
  - the contracts (thread-affine, reentrancy refused, no callbacks, no
    native dependencies);
  - every export's C types and ownership;
  - every artifact's SHA-256;
  - the shared object's ELF: AArch64, 16 KiB segments, its SONAME, Bionic's
    libraries only, its C ABI exported.

  It refuses what it cannot read, under a stable `RN-*` code, never
  guessing a type or an ownership. No function name, method list or 2048
  rule is built in: names come from the manifest and the options. A new
  boundary type is a new mapping with its tests, never an `any`.
* The package's native interface is React Native's own. The app's Codegen
  generates it from the spec (`includesGeneratedCode` false). The package is
  a pure C++ dependency of autolinking; never ship Codegen output, a Gradle
  module, Java or Kotlin, and never patch `node_modules` or React Native.
  The React Native versions it generates for are a table (`reactNatives`):
  a version not in it is refused, never assumed compatible.
* The generated C++ is two layers. The core (`MODULECore`) knows no
  JavaScript engine. It owns the instance's thread affinity: a call from
  another thread is refused before the C ABI is entered, and the instance
  is destroyed on its own thread only (at once, at that thread's next call,
  or at its exit, never by a foreign thread). It also owns ownership (RAII:
  every owned result and error released on every path) and the number and
  string rules:
  - an int is a safe integer, never rounded;
  - a float64 is finite;
  - a string crosses by length, never by NUL.

  The TurboModule only turns a failure into a JavaScript error. Never make
  an instance `Send`, lock it for another thread, or destroy it from one.
  Never return a pointer into a Botlish VM to JavaScript, and never fall
  back to JavaScript when the native module is missing (`BotlishError`
  category `unavailable`).
* The 2048 rules stay Botlish's. The facade adds the played game's rules
  (seeded spawns, two starting tiles, the end and the win) over the
  unchanged engine, and the hook and the screen compute nothing of them.
  The hook calls the library only in effects and event handlers, never
  while rendering.
* Android: arm64-v8a only. The CMake file refuses another ABI, an API level
  below the package's, and a library that is not the recorded one. The APK
  carries the package's library as the Android build strips it
  (`llvm-strip --strip-unneeded`: `tools/inspect-apk.sh` checks it byte for
  byte), 16 KiB-aligned and zip-aligned. The example app extracts its
  native libraries at installation (`useLegacyPackaging`). Left in the
  APK, an arm64-v8a-only app does not start on a native-bridge device:
  React Native's SoLoader looks for them under the device's primary ABI.
  Keep extraction, which `inspect-apk.sh` checks, until SoLoader looks
  under the process's own ABI.
* The device builds (`-PbotlishDevice=plain|gc-stress`, the app's
  build.gradle) are for a phone without adb: a Self-test button, the
  result on the screen, and for gc-stress `BOTLISH_NATIVE_GC_STRESS=1` set
  in `MainApplication` as an application of its own. Without the property
  the build is the acceptance's: never let a device build's button,
  variable or package reach it. The self-test checks its snapshots on the
  device by `oracleDigest` (src/directions.ts), which must stay the
  interpreter's (`rn-selftest-oracle-digest`). `tools/device-builds.sh`
  runs both on the workflow's emulators and, over USB, on a phone.

If you change `integrations/react-native/`, `examples/react-native/` or the
native library manifest or C ABI it reads, run
`tests/react-native-package.test`. It needs ANDROID_NDK_ROOT. Give it
BOTLISH_RN_PACKAGES, a directory of the prebuilt Android target support
and game2048 packages, else it builds them. Give it BOTLISH_RN_APP, an app
`audit/react-native-2048/tools/build.sh` prepared, for its Jest and
TypeScript tests. Also run `audit/react-native-2048/tools/mutate.tcl`, with
the same environment (every mutant in its `mutants.txt` must still apply
and be killed by a test its `!!` line names: update a mutant's text when you
change the code it mutates, keeping it a mutant of the same rule). Then push
and read the `react-native 2048` workflow: `build.sh` from checkout to APK,
then `tools/android-acceptance.sh` on an Android emulator for each image.
The images are x86_64 ones that run the arm64-v8a APK through Android's
native bridge, one with 4 KiB and one with 16 KiB pages. After
`single/build.sh`, also run the clean room
(`audit/react-native-2048/cleanroom/cleanroom.sh single/out/botlish REPO
RESULTS`).

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
* A method-style call the decision rejects is poison in the program
  reported, never its placeholder candidate's call (Method-call decisions,
  "Reporting never decides"): never let a stand-in the decision needed
  reach a diagnostic, a contract, an obligation or an ownership role.
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
  raised diagnostics gives them too. So is the way to a module file: every
  diagnostic the loader reports from one (a load error, a reference error,
  a syntax error) carries `import` notes, the chain of imports that loaded
  it, the entry program's first (`surface::modules::ImportNotes`, recorded
  as each module is first loaded); notes are never part of a diagnostic's
  message, order or identity, and the service keeps their `kind`.
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
  `service::at`'s facts, semantic tokens `service::tokens`' (Syntax
  highlighting, below), Compilerpedia topics `service::explain`'s and the
  facts' own (by identity). Never match names, parse formatted CLI output,
  run a second analysis or resolver, or compute a type in `lsp/`. The one
  presentation choice: a program with no analysis (a loader error) also
  shows each diagnostic at its `import` notes, the loader's chain of imports
  to the module file it is in (`ImportMirror`); an analyzed program's
  module diagnostics stay in their own file. Never find an import yourself
  (by name or by parsing): only the loader's notes say which one.
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

`editors/vscode/` is a VS Code extension for the same server: a client
like the Neovim configuration, starting `main.tcl -lsp` (its server.js
works out the command) and adding nothing semantic. If you change it, or
the server's capabilities, options or URIs, run its `npm test` and
`xvfb-run -a npm run test:vscode` (VS Code itself; CI runs neither) in
`editors/vscode` after `npm ci`, and package it (`npm run package`).

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

## Syntax highlighting and the token IR

Everything that highlights Botlish reads one statement of what each token
is, or is checked against it (SYNTAX-HIGHLIGHTING-MILESTONE-1.md): the
token IR (`surface/tokens.tcl`: tokens, comments, lexical diagnostics with
their recovery roles, the inserted closers, and the identifiers a parse
read as contextual words), its highlight classes
(`surface::tokens::classes`), the command line's excerpts and color
(main.tcl's "Diagnostic presentation"), the compiler service's tokens
(`service::tokens`), the language server's semantic tokens, and the
generated editor grammars. The lexer and the parser stay in Tcl
(BOTLISH-LEXER-RATIONALE.md). Keep it so:

* One IR: `surface::tokens::toLexed (fromLexed L)` is exactly the lexer's
  result L, so the IR holds everything the parser reads; a later lexer in
  another language produces the IR and is checked by `validate`. Never let
  a highlighter read the lexer's or the parser's internals instead, and
  never add a syntax-tree level to the IR without a design of its own (the
  AST is no specified format).
* Contextual words are the parser's: every identifier it consumes as a word
  goes through `surface::parser::Word` (or `WordAt`), every such word is in
  `surface::parser::words`, and a word compared only to refuse a construct
  is in `refusedWords`. Never classify a word by its spelling anywhere
  else, and never let the recording change the AST (`surface::parse` drops
  the words; the AST of every file must stay what it was).
* Presentation never changes a diagnostic: excerpts and color are on only
  where `-color`/`-excerpts` say (auto: a terminal, a channel with Tcl's
  `-mode`; never on Windows; NO_COLOR, TERM=dumb), and a pipe or a file
  gets the plain format byte for byte. An excerpt reads the diagnostic's
  structured location and the text the compilation read (the revision's,
  else the source seam's), never the message text.
* `service::tokens` adds no semantics: lexical classes are the IR's,
  declarations and annotations the AST's spans, names the HIR's bindings; a
  name with no binding gets no token. Tokens are a revision's query index
  (prepare builds them, export and import carry them): a new derived kind
  goes into `service::import`'s list too. The server answers them by its
  stale rule (fresh; else wait for a pending analysis; else the unchanged
  text's) and never invents one.
* The editor grammars are generated (`tools/editor-grammars.tcl generate`):
  never edit editors/vscode/syntaxes/botlish.tmLanguage.json,
  editors/neovim/syntax/botlish.vim or the fixture's sample.classes.json by
  hand. The lexer's keywords are each in one group, every registered word
  has a pattern and no pattern names another (generation fails otherwise).
  A declared name (after `fn`, `struct`, `type`, `error`) is the syntax
  tree's (`grammars::Declared`), never a name a pattern merely follows.
  A new contextual word is registered, consumed with Word, given a pattern
  (TextMate and Vim, matching it only where the parser reads it) and placed
  in the fixture (editors/vscode/test/fixtures/sample.bot) where it is read.

If you change the lexer's recording (`comments`) or recovery metadata, the
parser's word recording, surface/tokens.tcl, main.tcl's presentation,
`service::tokens`, the server's semantic tokens, the generator or the
fixture, run tests/syntax-highlighting.test (its grammar tests need `vim`,
and `npm ci` in editors/vscode for VS Code's engine), tests/lsp.test,
tests/main-cli.test, tests/compiler-service.test, `tclsh9.0
tools/editor-grammars.tcl check`, `npm test` in editors/vscode,
`audit/syntax-highlighting/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code it mutates, keeping it a
mutant of the same rule), and on a branch tests.yml for
tests/lsp-neovim.test (`lsp-neovim-highlighting`, which needs Neovim); a
change to the lexer or the parser also compares the AST of every
repository `.bot` file with the tree before the change, and runs the
syntax-recovery and diagnostic-recovery harnesses (above).

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
* a reference, alias or matcher is broken;
* a page names a design document (`docs/NAME.md`, a README): the reference
  ships without `docs/` (the single executable, Botlish.app), so a page says
  what it means itself and points at other topics. There is no `docs:`
  header key. A standard-library comment may cite a document for its
  maintainers; the generator drops a citation it can (`cpt::Unreferenced`:
  a parenthetical of citations, a citation leading or ending one, a
  "-- see DOC", a sentence that is only citations), and a citation it
  cannot fails the check until the comment is reworded (keep the file's
  line count: the warning gate's manifest pins locations);
* a capability page's alias names an existing standard-library operation
  (a function or intrinsic, not a predicate: "read file" and
  std::linux::fs::read_file) and the page does not relate its topic or its
  module's (next paragraph).

State only what the compiler does today; document an absent facility as
absent (`capability.*`) with the nearest alternative. A change to the
command line updates `cliOptions` (main.tcl), the `cli.options` topic and
main.tcl's header comment (`tests/main-cli.test` checks all three).

**Cross-check the capability pages against the standard library's
registry.** `capability.*` pages say what Botlish lacks, and the stdlib
grows under them: `capability.files` said "no open exists" for months after
std::io::fs and std::linux::fs shipped, and sent a user to hand-written C
calls. So whenever you add, rename or remove a public standard-library
module, function or intrinsic (a new `stdlib/` module, a registered
native, a public declaration):

* list the capability pages (`tclsh9.0 main.tcl -help capability.overview`)
  and read every one whose subject the change touches -- by its title and
  STATUS, not only its aliases -- and run `-help` with the names a user
  would type for the new facility (`-help "read file"`, `-help timer`):
  each must lead to the real documentation;
* a page the change makes wrong is rewritten in the same change: the real
  documentation, its ID kept (other topics and help lines name it), its
  title saying "limited" or describing what exists, its `related:` naming
  the new modules' and operations' topics, an example that compiles;
* a page that stays right but whose alias now names an operation of the
  same spelling relates that operation's topic (`capability.null` relates
  std::ffi::c::null) or drops the alias.

The check catches only the mechanical case (an alias that is an
operation's name); a broader claim -- "no tasks" while std::event_loop
schedules them -- is found only by reading the pages, so read them.

## Declared-result diagnostics and the text documentation

A declared result that is not proven is reported with both sides of the
comparison (TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md):
`function result does not prove declared type T (result type: R, facts:
F); WHY`, as an argument's TYPE states its type
(`hir::range::verifyDeclaredResults`). Keep it so:

* R is the generic body's own inferred result (the block's
  `inferredResultType`: every normal completion joined) -- exactly what the
  admission proof was given -- presented as an argument's type is
  (`hir::semantic::ShowType` of `ShownArgType`, `FactsClause`,
  `MismatchClause`): never one branch's type, a semantic instance's (an
  instance types a scratch copy), the declared type or a refinement's
  carrier. Format it only on a mismatch, never add a second diagnostic for
  it, and never let the message change what is accepted, poisoned or
  reported: a poisoned or unresolved result keeps its one primary
  diagnostic.
* The pages that state facts of the compiler about strings, UTF-8, text
  construction, literal escapes and List typing are checked against it by
  tests/text-collection-docs-diagnostics.test: the escape table of
  `concept.strings` against the lexer, `encode_utf8`'s static type (List
  of Bytes only with `std::byte` loaded) against the checker, the costs
  `task.string-concatenation` states against `native::allocationReport`.
  A change that makes one false -- a new escape (`\u{...}`), encode_utf8
  typed whatever is imported, `append_char` carried by construction
  plans, a `std::str::join`, a `std::char::from_scalar_value` -- rewrites
  the page in the same change. `std::test::joined` is the test library's
  (quadratic): never recommend it for production text.

If you change the diagnostic or those pages (or what they state), run
tests/text-collection-docs-diagnostics.test, `tclsh9.0
tools/compilerpedia.tcl check`, `tclsh9.0
audit/text-collection-precision/tools/probes.tcl` and
`audit/text-collection-docs/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed by a test its `!!` line names:
update a mutant's text when you change the code or the page it mutates,
keeping it a mutant of the same rule); for the diagnostic, also the test
files and golden suites that pin its text (`grep -rl "does not prove
declared type" tests`) and `audit/text-collection-docs/tools/compare.tcl`
before and after (no semantic difference over the corpus).

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
