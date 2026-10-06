# Test suite cost: where local runs spend their time, and how to cut it

## Outcome

`tclsh9.0 tests/all.tcl` (the interp pass plus the compile pass) costs **4811 s
of test wall time**, measured at 08b81e7 on a 4-core cloud container with three
test files running at a time; a quiet serial run is roughly 10-20% faster, about
65-75 minutes. Agents run it repeatedly, most painfully after merging `main`
into a branch. This document measures where that time goes and evaluates ways to
run less of it locally, other than the two already on the roadmap (the
botlish-native test framework, a self-hosted compiler) and other than
segmenting by compiler tier.

The short version:

* **Most of the cost is the same work done twice, not too many tests.** 5411 of
  5724 tests execute exactly the same programs on exactly the same backends in
  both outer passes. The front end builds every program's HIR twice. Several
  test files recompute their own results. Removing that redundancy (sections
  3.1-3.3), together with the bitshift fix (section 2) and two test rewrites
  that keep what the tests check (csv property rows as data,
  interpreter-sized workloads), takes a full serial run from 4811 s to about
  **1505 s (−69%)** in the model of section 3.4, and to about **378 s with a
  4-worker pool**. The redundancy removal alone, on top of the bitshift fix,
  gives about 1630 s (−66%).
* **The Rust driver is not the bottleneck.** The Tcl front end (28%) and the Tcl
  HIR→NIR lowering (36%) dominate; the `botlish-native` process (spawn,
  Cranelift compile, run) is 4%. Caching or batching native runs cannot pay off
  much.
* **The cost is concentrated.** The 50 slowest tests are 50.7% of the suite. One
  test alone was 9.2% (fixed in 0b190c6, section 2).
* **Proc-level change-based test selection does not work well here.** For the
  153 recent commits that touch anything a test reads, it still selects a median
  97% of the suite (99.5% for the commits that change code; file granularity),
  because the core pipeline procs run in nearly every test.
* **Many merges need no run at all.** 16 of the 32 merges in the history
  produced a tree that, on every path a test reads, equals one of their parents;
  13 of them brought nothing relevant into the branch (mostly the scalar-asm
  bot's corpus commits). Provided that parent's tree had a recorded green run
  (locally or in CI), a tree-hash check can skip them mechanically.

Measurement also found gate holes (section 7): a test file whose failures never
reach the summary, an estimated 164 native-running tests that the gc-stress job
runs unstressed, backend and compile-state leaks between tests, and Rust unit
tests that no workflow runs.

All numbers below were taken at 08b81e7 (2026-10-05). Since then `main` has
gained the bitshift fix (0b190c6), range-analysis speedups
(RANGE-FIXPOINT-SCALING.md), memoized instance views in native lowering
(4ca69cb) and two test files, so absolute times and the lowering share have
drifted; the structure of the cost has not. Every saving from the analysis of
option families was re-derived by an independent adversarial check, and where
that check corrected a first estimate the corrected figure is used. The
stand-in reuse (3.3), the compile-once estimate (section 9) and the composition
in section 3.4 come from a single final review and were not re-checked
independently. Combined figures are a model (per-test category times composed
per option), not one measured end-to-end run.

## How it was measured

* **Timing run.** Every test file ran once per outer backend (284 units, 3
  parallel workers), with tcltest's `test` wrapped to record, per test: wall
  time; exclusive time in each pipeline stage, via enter/leave execution traces
  on the stage entry points — *front* (`surface::compile`,
  `surface::readProgramFile`, `hir::build`, `hir::buildSyntax`,
  `hir::readFile`), *nlower* (`native::lowered`, the Tcl HIR→NIR lowering),
  *driver* (`native::Driver`, the `botlish-native` process), *exec*
  (`core::RunWithBackend`, interp/compile reference execution), *hlower*
  (`hir::lower`); the backend of every `core::RunWithBackend` call; the number
  of native runs; child `tclsh` spawns; project files opened. The wrapper adds
  no measurable overhead (3.9 s vs 3.85 s plain for `structs.test`). With 3-4
  concurrent workers the times are about 1.1-1.2x a quiet serial run.
* **Footprint run.** The same, plus every Tcl proc each test executed
  (self-removing first-hit execution traces, re-armed per test) and, for every
  outermost front/nlower/driver call, a hash of its full input, to find exact
  repeats. About 1.9x slower; used for footprints and repeat counts, not times.
  About 222 tests per pass failed under this heavier instrumentation, so their
  footprints are partial.
* **History.** For the last 300 non-merge commits and all 32 merges at
  08b81e7, the changed procs, top-level `variable` declarations, other
  top-level code and other files were extracted per commit, and selection was
  simulated against the footprints.
* **Bitshift.** gdb breakpoints on libtommath, `tcl::unsupported::representation`,
  and a scaling series (section 2).
* **CI history.** About 200 `tests.yml` runs from 2026-09-13 to 2026-10-05,
  from the GitHub API.

The instrumentation scripts are not committed; the methods above are enough to
reproduce them.

## 1. Where the time goes

| Stage | Share of 4811 s |
|---|---|
| Tcl native lowering (`native::lowered`) | 36.2% (1742 s) |
| Front end (surface parse, HIR build and check) | 28.0% (1347 s) |
| Reference execution (interp/compile) | 16.4% (791 s) |
| `botlish-native` process (spawn + Cranelift + run) | 4.0% (193 s) |
| `hir::lower` | 0.2% |
| Everything else (test code, child `tclsh`, AOT links) | ~15% |

Process startup is negligible (11 s for all 284 units). A trivial program costs
about 2.1 ms of front end, 2.1 ms of lowering and 4.4 ms of driver (of which a
bare `exec` is 1.6 ms).

**Outer passes.** 5411 of 5724 tests run the same `core::RunWithBackend` calls
on the same backends under `CORE_BACKEND=interp` and `=compile`:

* 3346 make no `core::RunWithBackend` call at all: 2960 frontend, HIR and
  analysis tests that run no program, and 386 that run native code directly
  through `native::evalHir` or `native::executable` (about 1428 s over both
  passes);
* 2065 choose their backends explicitly (`outcomeUnder`, `outcomeUnderHir`,
  `differential`, or an explicit `core::useBackend` with save/restore).

Only 313 tests in 47 files depend on the outer backend; they cost 30 s of the
compile pass. Every `[core::useBackend]` read in a `tests/*.test` file is a
save/restore; the one read of the outer backend is helpers.tcl's `coreScoping`
constraint (`tests/helpers.tcl:86`). Nothing reads `::env(CORE_BACKEND)` except
`helpers.tcl` and `all.tcl` (`native-coverage.tcl` sets it). In 199 CI runs the
compile job never failed while the interp job passed.

**The tail.** Top 50 tests = 50.7% of the suite, top 100 = 61.9%, top 400 =
81.7%. The slowest files (both passes): `stdlib` 639 s, `native-tiny-leaf-pressure`
587 s (10 tests), `native-csv-records` 496 s, `native-bitshift` 452 s,
`typed-mutarray-builder` 399 s, `native-hashtable` 193 s.

**Exact repeats.** Within one test process, 36% of outermost front-end calls
(22.9% of front time) compile an input already compiled in that process; 11.7%
of lowering time and 20.8% of driver time are likewise repeats (`cranelift` and
`cranelift-generic` often produce byte-identical NIR).

## 2. The bitshift test (fixed: 0b190c6)

`native-bitshift.test`'s `bitshift-shift-count-max-shift-boundary` took 221 s
per pass, 9.2% of the suite, all in reference execution; the native backends
did the same work in milliseconds. gdb showed exactly four conversions of
17,477-limb (about 1,048,577-bit) integers to decimal per pass (2^1048576 and
−3·2^1048576, on interp and on compile), about 55 s each:

* `core::value::int` validated every Int with `isCanonicalInt`, a `regexp`,
  including results straight from `expr`. Matching needs the object's string, so
  Tcl 9.0.1's `UpdateStringOfBignum` ran libtommath 1.3.0's `mp_radix_size` —
  which in 1.3.0 runs a full digit-at-a-time `mp_div_d` loop just to *count*
  the digits — and then `mp_to_radix`, the same loop again. Each step is a
  128/64-bit division through libgcc's `__udivti3` (one `div r64`), serially
  dependent on the previous remainder: about 9 ns per limb step, 5.5·10⁹ steps,
  49-51 s. Measured scaling, ×4 per doubling of bits: 2^65536 (2^16 bits)
  0.19 s, 2^131072 0.77 s, 2^262144 3.0 s, 2^524288 12.1 s, 2^1048576 51 s.
* `Tcl_RegExpExecObj` → `Tcl_GetUnicodeFromObj` then replaced the bignum
  internal representation with a string one, so the next shift re-parsed the
  315,653 digits: another 6.4 s.

0b190c6 adds `core::value::intFromNumber`, an unchecked constructor for integers
Tcl computed (arithmetic, bitwise and shift results, `hash`, loop induction
values, lengths and counts), and keeps the check for text. The test now takes
about 0.14 s per pass. `scalarbits-computed-int-stays-number` checks without
timing that computed Ints keep a bignum payload with no string form.
libtommath's development branch sizes the output with a logarithm (one quadratic
pass instead of two) but still converts one digit per division.

## 3. Remove repeated work (every run)

### 3.1 Run backend-independent tests once

Record, in pass 1, which tests use the outer backend; in pass 2 re-run only
those.

* `tests/helpers.tcl`: register an alias backend `outer` with the outer
  backend's own commands and select it, so an explicit
  `core::useBackend interp|compile|cranelift*` stays distinguishable from a run
  under the default; derive the `coreScoping` constraint from the outer backend;
  trace `core::RunWithBackend` and set a flag when it runs under `outer`; wrap
  `test` (composing with the native-coverage wrapper) to log tests that used
  `outer`, failed, were skipped or carry `coreScoping`. Children that source
  helpers.tcl log against the parent test through an environment variable.
* `tests/all.tcl`: pass 1 runs everything under interp with the log enabled;
  pass 2 runs under compile only the logged tests (`-file` restricted to their
  files, other names skipped by the wrapper). A file that errored at top level
  in pass 1 re-runs whole. `BOTLISH_FULL_PASSES=1` keeps today's behavior.

Saving on its own: about **2110 s net of the bitshift fix** (44% of today's
4811 s run, 48% of the 4368 s left after the fix; 2331 s before netting). It
halves whatever the backend-independent tests still cost, so after sections 3.2
and 3.3 it is about 1370 s (section 3.4). A coarser file-level variant saves
1883 s (39%). Running only the 313 tests whose executions differ between the
passes, under compile and without their neighbours, passed (309 pass, 4
`coreScoping` skips), so none of them depends today on a test that pass 2 would
skip.

Prerequisite, a **backend-leak guard**: fail any test that leaves
`core::useBackend` changed. Today `tests/source-types.test` (three places that
set `interp` without restoring) and `tests/conjunctive-entry-facts.test` (an
`lmap` over backends that leaves `cranelift` selected) leak, and as a result 5
`source-types` tests never actually run under compile.

What is lost: a warm `compiler/compiler.tcl` cache variant in pass 2
(accidental coverage) and a second sample of nondeterministic native failures.
A scheduled `BOTLISH_FULL_PASSES=1` run that diffs per-test outcomes covers
both.

Zero-code interim: agents run `CORE_BACKEND=interp tclsh9.0 tests/all.tcl`
locally; CI keeps its compile job.

### 3.2 The front end builds every program twice

`hir/resolve.tcl:100` sets `methodCalls` to an empty dict for every program, so
every `hir::buildSyntax` whose first build reaches the static checks
(`hir/hir.tcl:361`) enters `hir::DecideMethodCalls`, which always finishes with
a full `BuildOnce` (`hir/hir.tcl:572`). When no method call is undecided, that
build gets the same nodes, options and (empty) choices as the first, so it
produces the same HIR. The doc comment above `DecideMethodCalls`
(`hir/hir.tcl:483`) says "a program without one is built once". The double build
came in with baaf79a; `strict-references.test`'s `sr-legal-program-is-typed`
already works around it with `lsort -unique`.

The redundant build is **42.6-44.6% of all front-end time: about 573-601 s,
12% of the suite**, and user compiles get roughly 40-48% faster in the front end
(on a quiet machine: csv_records about 885 → 510 ms, `import web` about
245 → 130 ms). Over 3977 redundant builds in 20 test files, the redundant build
produced byte-identical HIR and identical `::hir`/`::core`/`::surface`/`::native`
namespace state, and all 20 files pass with an early return in place (checked on
current `main`). Fix: return early when nothing is undecided (or memoize
`BuildOnce` by `choices` within one `buildSyntax`), correct both comments, and
add a test that counts `BuildOnce` calls for a program with no multi-candidate
method call.

### 3.3 Tests that recompute their own results

| Test | Problem | Fix | Saving (both passes) |
|---|---|---|---|
| `native-tiny-leaf-pressure` | `tinyLeafPressure::measure` lowers each HIR 3 times per inlining side (`evalHir`, `nir`, `codeSize` each lower); the raw-ABI growth sweep repeats all of the parity tests' measurements, and the tagged-ABI sweep recompiles the same fixtures' front end | lower once per side, pass the NIR to `native::Driver run` and `size`; memoize `measure` and the HIR inside the test file (or key the memo on the `BOTLISH_NATIVE_*` knobs too) | 422 s (8.8%) |
| `corpus::driven` (`examples/stdlib/corpus.tcl`; stdlib, typed-mutarray-builder) | recompiles strictly once per missing builtin error: 4 compiles per `csv_records` case | one `-strict 0` compile, then at most one compile of `corpus::handled` | 283 s (5.9%) |
| `native-csv-records` property tests | 150 reference rows become one ~900-conjunct `and` chain; front cost is superlinear in it (`hir::completions::Conjuncts`) | pass expected rows as list literals to a fixed checker; keep the 40-row tests | 170-260 s |
| fib / two-calls / `opt-tail-5` parity | the tree-walking interpreter (~200-265 µs per call) runs native-sized workloads | fib(22)→fib(16), g(25)→g(18), collatz(27)→collatz(7), updating the expected values and `raw-fib-outer-frontier`'s literal 22; same properties | 127 s (2.6%) |
| `cranelift-generic` stand-in | on `struct-shape` the stand-in runs `cranelift` (`examples/stdlib/corpus.tcl:152`, `outcomeUnder*` in helpers.tcl), and the backend loop then runs `cranelift` again with identical HIR and options | compute `cranelift` first and reuse it | 69 s (1.4%) |

The `Conjuncts` superlinearity (it re-walks the nested-if chain at every level)
is a compiler scalability bug in its own right. The fuzz smoke tests (263 s over
both passes) do not depend on the outer backend (they choose backends
explicitly, or, like method-eligible's tool, never read `CORE_BACKEND`) and run
identically in both passes; section 3.1 halves them, or a `firstPass`
constraint does.

### 3.4 Combined

| Step (cumulative) | Serial | 4 workers | 8 workers |
|---|---|---|---|
| measured at 08b81e7 | 4811 s | 1206 s | 603 s |
| bitshift fix (done) | 4368 s | 1095 s | 548 s |
| + sections 3.2 and 3.3 | 2877 s (60%) | 722 s | 361 s |
| + section 3.1 | **1505 s (31%)** | **378 s** | 189 s |

The fixes overlap (for example `corpus::driven` removes compiles the
double-build fix would otherwise halve); the table composes them, it does not
add them. The parallel columns assume the prerequisites of section 4.

## 4. Run in parallel

`tests/all.tcl` runs files one after another and the passes one after another.
A pool over (file × backend) units, longest first, brings the post-bitshift
serial run (about 4370-4380 s, depending on whether per-process load is counted)
to 1095 s at 4 workers and 548 s at 8; after section 3, about 378 s at 4
workers. Three prerequisites:

* A private tcltest `-tmpdir` per unit (tests create fixed names such as
  `abi-bytes-scratch` and `argv-aot` in the working directory).
* **16 tests in 9 files write fixed-name modules into the real `lib/`**
  (`[file join $::core::libraryDir X.bot]`): applied-types (3), byte-set (1),
  errors (2), immutable-set (3), method-sugar (1), source-types (1),
  structural-fn-types (1), typed-callable-escape (2), typed-parameters (2).
  Starting a file's two units together failed spuriously in 7 of 30 trials
  (`no such module file .../lib/appliedtypeslib2.bot`). Give each run a private
  library directory or unique module names.
* `audit/stdlib-namespaces/tools/fuzz.tcl:450` (spawned by
  `stdlib-namespaces.test`'s `ns-fuzz-smoke`) uses a fixed
  `.fuzz-stdlib-namespaces` directory in the repository root; two concurrent
  instances delete each other's scratch directory. Use `file tempdir`.

A persisted duration cache is not worth it on 4 cores (alphabetical order is
within 4 s of longest-first); at 8-16 workers a hard-coded list of the dozen
longest files, run first, comes within about 5 s of it. Splitting the long
files pays only at about 16 workers while both passes share one pool
(323 → 274 s), or at 8+ workers once only one pass runs (323 → 279 s at 8).
Sharding with `-match` lists must give the last shard the complement (`-skip`
everything assigned elsewhere), or newly added tests silently run in no shard.

For edit loops: last-failed first, then changed test files, then the rest, with
fail-fast, reports a failure in the commit's own test file after a median of
about 14 s. This shortens time to feedback; it does not shrink a green run.

## 5. Do not run at all when nothing relevant changed

* **Tree-key skip.** Hash the working tree (including untracked files) minus
  what no test reads (`*.md`, `audit/native-scalar-asm/**`, `fuzz/**`,
  `.github/**`, `.devcontainer/**`, `LICENSE`), together with
  `[info patchlevel]`, the Rust inputs (`native/**` minus `*.tcl`,
  `Cargo.lock`) and `rustc -vV` — not the binary's hash, which embeds absolute
  build paths and differs per worktree; `rustc` matters because AOT tests link
  at test time — plus `LANG`/`LC_ALL`, the `BOTLISH_*` environment and the
  tools tests are constrained on. After a full, unfiltered green run (no
  `-file`, `-match` or `-skip`, and only the expected constraint skips), write
  a stamp under `$(git rev-parse --git-common-dir)` (shared by all worktrees);
  also accept trees that CI passed on `main` (looked up by tree, since CI does
  not run on bot commits). With that path list, **16 of the 32 merges need no
  run** once the matching parent has a stamp or a CI pass: 13 brought nothing
  relevant into the branch, and 3 produced the same tree as their other
  parent. Of the last 300 non-merge commits, 79 are bot
  corpus regenerations and 71 of the other 221 touched nothing relevant.
* **Per-test-file key cache.** Key each file on its path-level dependency
  closure; adds test-only and data-only edits. Mean merge run 53% → 42% of a
  full run; code commits still run everything.
* **Proc footprints (Ekstazi-style): measured, not worth building.** Over the
  153 commits that touch something test-relevant, file-granularity selection
  keeps a median 96.8% (mean 69.5%) of the suite; test granularity a median
  86.5% (mean 62.3%). The distribution is bimodal, but the low mode is almost
  entirely data-only and test-only edits: of the 100 commits that change code,
  90 select 95% or more (median 99.5%) and only 4 select under 20%. The gain over
  the per-file key cache is about 3 points, against a 1.9x instrumented sweep, a
  134 MB index and blind spots (child processes, procs that run only at compiler
  load, data read via `source`, `glob` or `file exists`, and new procs that
  capture unqualified calls). For merges, selecting only tests whose footprint
  meets *both* sides' diffs would give a mean 32.6% only if `main`'s side were
  always taken as tested; using only what CI had actually passed at merge time
  it is 38.5%, no better than re-running what the merge brought in.
* **Persistent compile caches** (front end and lowering results on disk, keyed
  on the input and a hash of the stage's sources): about 27% of a full run per
  commit on average without selection (21% once section 3.2 lands), but about
  6% on top of footprint-based selection, and a stage's cache is cold whenever
  its own sources change. Deferred: it is only sound after the ambient-knob and
  order-dependence fixes of section 7.

## 6. Move the gate into CI

CI runs only on pushes to `main` and on pull requests; agent branches get no CI,
so agents gate locally — often interp, compile, native coverage and GC-stress.
GENERIC-PREDICATE-PROOF-LOSS.md records several such rounds repeated after
rebases; ABI-BYTES.md records a full re-run after a flaky test. Of 203 push runs
from 2026-09-13 to 2026-10-05, 6 were red anyway (5 of them test or example
failures).

* Trigger `tests.yml` on agent branches too, sharded (an LPT shard plan from a
  committed timings file that fails if any test file is in no shard or two), with
  one aggregating required job, and the tree-key skip as a fast path.
* Locally, before pushing: the agent's own changed test files plus a **91 s
  smoke set** — a greedy weighted set cover over proc footprints (487 tests
  covering all 2280 procs the interp pass executes). It is a local sanity check,
  never a gate: only 93 of 5724 tests run a proc that no other test runs
  (median 277 tests per proc), and of 29 injected bugs in peripheral procs it
  caught 16 of the 20 that the full interp pass caught (9 escaped even the full
  pass). Per push, local cost becomes 2-7% of today's run; after a merge,
  nothing.
* The exposure this removes: had each landing run the 80-minute suite between
  merging and pushing, `main` would have moved during that window before 45% of
  the 201 pushes (39% another session, 5% only bot commits), each forcing
  another merge and run. This is modelled exposure; the actual re-merge rate was
  not measured.
* An AGENTS.md landing protocol says when to run what; without a CI gate, at
  least "a merge that brought only docs or the scalar-asm corpus is not
  re-tested". Moving the corpus off `main` adds nothing on top of that rule.

## 7. Gate holes found along the way

Every reduction above leans harder on the remaining gate; the fixes below should
land before the reductions that depend on them (section 10):

* `tests/native-tiny-leaf-inline.test` has no `cleanupTests`: `all.tcl` reports
  `Total 0` for it, and its 34 tests could fail without the summary showing it.
  The runner should also assert the number of files sourced and the totals.
* **GC-stress coverage leaks.** Tests set `BOTLISH_NATIVE_GC_STRESS` directly 53
  times and unset it 54 times; after an unset, the rest of the file runs
  unstressed in the gc-stress job. By static estimate that is 164
  native-running tests in 23 files (about 318 s per pass), e.g. 28 tests of
  `native.test` after `native-listget-fast-7`; confirmed dynamically for
  `native-escape.test` and `native-tcl-unicode.test`. (`native-alloc.test` and
  `string-allocation.test` unset it for the whole file on purpose.) Hoisting the
  file-local save/restore `withEnv` (`abi-bytes.test:89`,
  `abi-mutable-bytes.test:89`, `abi-numeric.test:81`, `linux-syscall.test:90`)
  into helpers.tcl and using it instead of bare set/unset — including in the two
  `gcStress` helpers that unset (`exact-callable-key.test`,
  `typed-mutarray-builder.test`) — fixes it. The gc-stress job also runs both
  outer passes; the second repeats the first's stressed native work (2092 of
  the 2094 tests that reached the driver in the footprint run send identical
  driver commands in both passes).
* **Backend leak**: the 5 `source-types` tests of section 3.1.
* **Order-dependent compile state**: `hir::errordecls` and `hir::sourcetypes`
  state carries over between compiles. Deduplication, test-level sharding,
  selection and caching all assume tests are order-independent (the file-level
  pool does not); reset that state per top-level compile, and run a rotating
  per-test isolation job.
* **Ambient knobs**: `BOTLISH_NATIVE_*` variables are set in 33 test files, and
  13 of the compiler's 63 knob-like namespace variables are set directly in 15
  more. Options passed explicitly (the lowering already takes them) are a
  prerequisite for any sound compile cache.
* `cargo test --release` (211 `#[test]` in `native/src`) runs in no workflow.
* **No compile-time benchmark.** `bench/bench.tcl` excludes compile time, so the
  double build of section 3.2 landed unnoticed by any performance check. A
  `bench/compile.tcl` that times the front end, lowering and the major analyses
  on the stdlib corpus, with a regression warning in bench.yml, would have
  caught it. A per-test time budget probably would not have: the redundant build
  (about 1.75x on the front end, 1.2x on front end plus lowering) spreads 579 s
  over 11448 test instances and pushes only 1 of them over a 15 s budget (37
  over a 10 s one). If a budget is added, it must count child CPU time
  (`cutime`/`cstime`), or it misses the fuzz smokes and AOT tests.

## 8. Not worth it (measured)

* A persistent `botlish-native` server, or caching driver outcomes by NIR: the
  driver is 4% of the suite.
* Dropping `cranelift-generic` from the default backend lists: it is about 10% of
  lowering time and the only unspecialized-baseline coverage.
* Module summaries for `lib/` imports: on an idle machine `import web` costs
  about 250 ms of front end and `import linux` about 110 ms, everything else at
  most about 35 ms; the programs' own code dominates.
* Persistent worker processes: first-call warm-up is about 30 ms.
* Segmenting by compiler tier: not needed for any of the above.

## 9. For the botlish-native test framework

What the measurements say the framework should make the default:

1. **Backends are declared per test**; the front end runs once per program and
   fans out. There is no ambient "run everything again under backend X" pass.
2. **Compile once, run many**: inputs are data (`argv()` works on all four
   backends), and per-case compilation is opt-in for tests about exact-value
   facts. Converting the string-input corpus cases this way would save about
   106 s per full run (2.2%) even after section 3. The driver needs a run-many
   mode: `bench` already compiles once and runs N times with `vm.reset()`
   between runs, but with one argv and only the last result reported; run-many
   needs a per-run argv vector and a per-run outcome. `batch` is a timing mode.
3. **Workload sizes per backend**, so the interpreter is never handed
   native-sized work.
4. **No ambient environment**: options are data; each test gets a private
   scratch directory.
5. **Compile-failure tests run the front end only** (today's 4064 front-only
   test instances, compile failures plus front-end and analysis tests, cost
   221 s, 4.6%).
6. **Tiers and scales as attributes**, per-test CPU timing including children,
   fail-fast, rerun-failed, changed-first ordering.
7. **Selection from the static import graph**, not traced footprints.
8. **A result cache** keyed by (program hash, compiler id, runtime id, backend,
   options), for programs whose effect analysis proves no `argv()`, syscalls or
   IO: this is where language-level determinism pays off.
9. **GC-stress by replaying compiled artifacts**, not by re-running the pipeline.

## 10. Recommended order

1. AGENTS.md, no code: run `CORE_BACKEND=interp` locally (CI keeps compile);
   do not re-run after a merge that brought only docs or the corpus.
2. The `DecideMethodCalls` early return plus the `BuildOnce`-count test (1-2 h;
   ~12% of the suite, faster user compiles).
3. `native-tiny-leaf-pressure` lower-once and `corpus::driven` (about 1 h each).
4. Gate holes that need no design (section 7): `cleanupTests`, the `withEnv`
   hoist for GC-stress, the backend-leak guard, `cargo test` in CI.
5. `bench/compile.tcl`.
6. Per-compile reset of `hir::errordecls`/`hir::sourcetypes` state, the
   rotating isolation job, and explicit options instead of ambient knobs: the
   prerequisites of step 7's deduplication and of any later caching.
7. Tree-key skip; the `lib/` writer and stdlib-namespaces fuzz scratch-dir fixes
   plus the parallel pool; the pass-2 deduplication (replaces step 1's
   interp-only rule).
8. The remaining section 3.3 fixes.
9. CI gate on agent branches with the landing protocol.

After steps 1-3 and the skip rule, a typical post-merge iteration goes from a
full 4811 s run to about 13 minutes on average (about 3 minutes once step 7's
pool and deduplication land), because half of merges skip the run entirely and
the rest run a suite a third of today's size (about 1590 s serial).
