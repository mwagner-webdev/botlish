# MAIN-CI-FAILURES-2026-11-13.md

The CI failures on `main` from 2026-11-09 to 2026-11-13: every distinct
cause, what fixes it, why each reached `main`, and proposed changes to the
canary and to AGENTS.md that would have kept most of them off it. It
follows MAIN-CI-FAILURES-2026-11.md (to 11-02) and
MAIN-TEST-DEFECTS-2026-11.md (to 11-04).

Method: every completed workflow run on `main` created between 2026-11-09
06:02 and 11-13 21:21 UTC (600 runs, 291 of them for 25 pushes), through
the GitHub API. For each failed run, the logs of its failed jobs. Main's
runs at 14937461 (the head when this was written) were still running, so
the jobs that had finished by then were read too. The fixes were checked
on Linux x86-64 with rustc 1.100.0 (section 4). Linux AArch64, macOS and
Windows are for CI to confirm.

## Contents

1. [Summary](#1-summary)
2. [The failures, one by one](#2-the-failures-one-by-one)
3. [Why they reached main](#3-why-they-reached-main)
4. [What this change fixes, and how it was checked](#4-what-this-change-fixes-and-how-it-was-checked)
5. [Proposed changes to the canary](#5-proposed-changes-to-the-canary)
6. [Proposed changes to AGENTS.md](#6-proposed-changes-to-agentsmd)
7. [Left open](#7-left-open)

## 1. Summary

14 push runs on `main` failed in the window, plus three jobs of the runs
still in progress at 14937461. They have six causes. Two of them are the same
event: stable Rust moved from 1.99.1 to 1.100.0 under `main` (on the
runners from 2026-11-12; main's first run with it was at ede621b1 on 11-13),
and no commit changed.

| # | Failure | Cause | Runs | Status |
|---|---|---|---:|---|
| 1 | "can't find crate for `botlish_native`" in every executable link | rustc 1.100's cargo writes no `target/release/deps` | 7 (every test workflow, c-bindgen, two icy-tower) | fixed on main (ce54fead, 13d08355) |
| 2 | `argv-focused-valid-fuzz`, `native-tcl-unicode-lowercase-all-scalars` | `std::str::lowercase` natively used Rust std's case tables, which rustc 1.100 moved past Unicode 16 | 3 jobs so far (Linux, macOS, Windows), every native tests job to come | **fixed here** |
| 3 | `ci tools` fails in `history.py` | GitHub API 502 (twice) and a cut-off body, with no retry | 3 | **fixed here** |
| 4 | every arm64 job fails installing Tcl | `ports.ubuntu.com` unresolved or reset, with no retry | 2 (9 jobs) | **fixed here** |
| 5 | React Native self-test "802 lines" | the self-test ran twice in one process | 1 | fixed on main (db3599ed) |
| 6 | `vt-large` under cranelift coverage | not reproduced; its report was cut off | 1 | **made diagnosable here** |

Main's last commit with every test green is cdb751b0 (2026-11-11 22:34),
which is what the release gate still publishes.

The classes behind them:

- **An unpinned toolchain is an input no commit changes.** Causes 1 and 2
  came from `rustup toolchain install stable` on every runner. Nothing ran
  the new toolchain before `main` did. The canary selects by what a push
  changes and by recent failures, and a new rustc is neither. Cause 2 had
  happened once before: rustc 1.97's Unicode 17 tables. The fix then was a
  list of the scalars 1.97 added, which the next toolchain was bound to
  outgrow.
- **CI infrastructure without retries.** Causes 3 and 4 are single network
  failures that each failed a whole run. On arm64 that was every job,
  before anything was tested.
- **A merge with its full runs pending.** 14937461 merged the rustc 1.100
  follow-up with only the canaries done. Its own message says so, and
  AGENTS.md allows it. The first expensive job to finish, an hour later,
  found cause 2.
- **A report that hides the failure.** The coverage job printed the
  suite's first 20,000 characters. Those are the unsupported tests'
  reports, so `vt-large`'s never appeared.

## 2. The failures, one by one

Run ids are GitHub Actions run ids on `main`.

### 2.1 Rust 1.100: the startup crate's dependencies (fixed on main)

- **Where:** at ede621b1 (11-13 16:10): tests 43459993377, tests (linux
  arm64) 43459993384, tests (macos arm64) 43459993534, tests (windows
  x86-64) 43459993108, c-bindgen 43459993218, icy-tower 43459993126,
  icy-tower (windows x86-64) 43459993044.
- **Symptom:** every rustc-linked executable failed:
  `error[E0463]: can't find crate for botlish_native`
  (`startup.rs:1:5`). The canary was the first job to fail on each host,
  with c-ffi.test, application-library.test, c-bindgen.test,
  external-tools.test and coroutine-fusion.test (Windows).
- **Cause:** rustc 1.100's cargo writes `target/release/build/PKG/HASH/out`
  and no `deps/`. The rustc linker searched only `deps/`, and the build
  cache restored 1.99.1's stale `deps/`.
- **Fix:** ce54fead searches both layouts; 13d08355 keys the build cache by
  the toolchain (`rustc -vV`'s release and commit). At 14937461, c-bindgen
  and all three icy-tower workflows are green, and so are the canaries of
  every test workflow.

### 2.2 Rust 1.100: Unicode case tables (fixed here)

- **Where:** at 14937461, `argv-focused-valid-fuzz` (iterations 11, 22 and
  29) is the only failure in each of the jobs that had finished:
  - tests 43489783150, `tests (system-linked executables)` (4,651 tests,
    one failed);
  - tests (macos arm64) 43489783290, `system linker (macOS arm64)` (4,651,
    one failed);
  - tests (windows x86-64) 43489783453, `smoke (Windows x86-64, MSVC)`
    (1,287 tests on interp and on compile, one failed each).

  It fails in every native configuration, not only with the system linker:
  it reproduced here with the default linker. The interp, compile, coverage
  and GC-stress jobs were still running and will fail the same way. So does
  `native-tcl-unicode-lowercase-all-scalars` (`cranelift-generic:plane0
  cranelift:plane0 cranelift-generic:plane1 cranelift:plane1`), which none
  of the finished jobs ran.
- **Symptom:** the fuzz program lowercases random arguments. Natively,
  U+A7DD lowercased to U+0277, U+A7E2 to U+027C and U+AB6C to U+AB4B. On the
  Tcl backends, which are the reference, each stays unchanged.
- **Cause:** `rt_str_lower` (native/src/runtime/ops.rs) defined Botlish's
  Unicode 16 simple mapping as Rust's `char::to_lowercase` minus a fixed
  list: U+0130, plus the 28 scalars Unicode 17 added in rustc 1.97. rustc
  1.100's tables map 20 more scalars: U+A7DD, U+A7E2, U+AB6C, U+AB6D and
  16 in U+1DF40..U+1DF7E. The Rust unit test's oracle was built the same
  way, so it moved with the implementation and passed.
- **Fix:** a lowercase table generated from the reference,
  `native/src/runtime/lower16.rs`: 1,460 scalars in 187 runs, written by
  `tools/unicode-lowercase.tcl` from `core::strings::lowercase`.
  `rt_str_lower` reads it, so the mapping no longer depends on which rustc
  builds the runtime. tests/native-tcl-unicode.test checks three things:
  that the committed table is what the generator writes
  (`native-tcl-unicode-lowercase-table-generated`), the new scalars, and,
  as before, every scalar on every backend. The Rust unit tests check the
  table's shape and the known facts, rustc 1.100's additions included.
- **Why the canary missed it:** neither test file changed, and neither was
  in `tests/canary.tsv`'s history. The canary at 14937461 passed on every
  host.

### 2.3 `ci tools`: one failed API read fails the run (fixed here)

- **Where:** 42774643433 (cfd6ecfa, 11-10), 43459993343 (ede621b1),
  43489783093 (14937461).
- **Symptom:** the step `history.py --write`, which recomputes the
  canary's records, died with a traceback. Twice it was `GET
  /actions/runs/N/jobs: HTTP 502 Server Error`. Once it was
  `http.client.IncompleteRead(450292 bytes read, 962797 more expected)`.
  Every other step had passed.
- **Cause:** `tools/ci/runs.py`'s `Api.request` asked once. Recomputing
  the history makes hundreds of reads, so a rare server error becomes a
  regular red run.
- **Fix:** reads (GET) are asked again on an HTTP 5xx or a transport error
  (a connection, a timeout, a cut-off body). They are retried up to four
  times in all, after 2, 5 and 10 seconds, and a failure that persists is
  still an `ApiError`. Writes (a dispatch, a cancel) are never repeated,
  because a repeated dispatch is a second release run. A transport error
  on a write is now an `ApiError` too, not a traceback. Nothing that
  decides changes: the twin still defers on no error. Three new tests in
  tools/ci/test_runs.py cover this.
- **Why it matters beyond the red:** this is the step that keeps the
  canary's history current. It failed on three of the window's `ci tools`
  runs, so the recomputed records that would have named this week's
  failures never appeared.

### 2.4 arm64: the Tcl packages' download (fixed here)

- **Where:** tests (linux arm64) 42788961535 (46ab0919, 11-10): the
  canary, with `curl: (56) Recv failure: Connection reset by peer`.
  43029812107 (eeaf1e3e, 11-11): all eight jobs that started, with
  `curl: (6) Could not resolve host: ports.ubuntu.com`.
- **Cause:** `.devcontainer/setup.sh` fetched the three `.deb` files with
  one `curl -fsSLO` each.
- **Fix:** `curl --retry 5 --retry-all-errors --retry-delay 10
  --connect-timeout 30`. `--retry-all-errors` also covers a name that does
  not resolve, which plain `--retry` does not. (tests/platform/setup-macos.sh
  already retried its Tcl source download.)

### 2.5 React Native: two self-tests in one process (fixed on main)

- **Where:** react-native 2048 42908123555 (f06de8e6, 11-10), `android (4
  KiB pages)`.
- **Symptom:** "the module's snapshots differ from the interpreter's (802
  lines)": two runs' 401 lines each, sorted together.
- **Fix:** db3599ed, the next push. It splits the log into runs and holds
  each to the interpreter. No later main run of that workflow failed.

### 2.6 `vt-large` under cranelift coverage (not reproduced; made diagnosable here)

- **Where:** tests 43162363612 (023dfaa3, 11-12), `tests (cranelift
  coverage)`: one test `failed (native backend bugs)`, `vt-large` (64 KiB
  of bytes, 20,000 Ints and a 2,000-entry map round-tripped through
  `std::transfer`).
- **Not reproduced:** it passed six times here under `CORE_BACKEND=cranelift`
  (42 s each), and in main's coverage job at cdb751b0 the day before. No
  later coverage job on main had finished when this was written: at
  ede621b1 it was skipped behind the failed canary.
- **What hid it:** tests/native-coverage.tcl printed
  `[string range $output 0 20000]`. The suite's unsupported tests (acceptance-4,
  scope-5 and the rest) come first in that output, and their reports filled
  all 20,000 characters, so the one failure that mattered never appeared.
  The job ran 3 h 14 min and left nothing to diagnose.
- **Fix:** the job now prints each failed test's own report, from tcltest's
  `==== NAME` to `==== NAME FAILED` (the middle elided past 12,000
  characters). A failed test with no report is named, followed by the
  output's last 6,000 characters. The next occurrence will say what
  happened.

### 2.7 Also seen: runs that never start

Main's four test workflows at 73c32da8 (11-11 20:24) are still `queued`
two days later. Later pushes to main did not cancel them, and
`prune-runs.yml` never touches main's runs, by rule. They test nothing and
hold no runner, but they do appear among the release gate's candidates.
They may need cancelling by hand.

## 3. Why they reached main

**The toolchain is an input nothing tests before main.**

- AGENTS.md tells every session, and `.devcontainer/setup.sh` tells every
  runner, to install `stable`. Rust's six-week releases therefore land on
  every workflow at once, on whatever commit is current, at a time no one
  chose.
- In this window that cost two distinct defects. Their symptoms appear in
  dozens of jobs across four hosts, and no change in the repository is
  responsible for them.
- A branch tested green on Wednesday merges red on Thursday. ede621b1's
  branch had every dispatched workflow green at 943b75c0 on 1.99.1.
- The structural defect is an unstated dependency: the native runtime's
  semantics depended on the Rust standard library's Unicode version, and
  CI's results depended on cargo's directory layout.
- The first Unicode drift (rustc 1.97) was answered by listing its
  additions. The comment beside that list predicted the next failure ("a
  toolchain whose tables add more fails there") instead of preventing it.

**The canary cannot see an environment change.**

- `tests/canary.tcl` selects the test files a push changes, then the host's
  recent failures. A new rustc changes no test file. The Unicode drift's
  two test files had no recent failures, so the canary passed on every
  host at 14937461 and the expensive jobs found the failure.
- Cause 1 was caught by the canary only because c-ffi.test and
  c-bindgen.test happened to be in the history for other reasons.

**Merging with full runs pending.**

- AGENTS.md's merge rule says "Pending runs are acceptable: report them as
  pending, never as passed".
- That rule is reasonable for a change whose risk the canary covers. For
  a change motivated by an environment change it is not: the canary does
  not select by that change.
- 14937461 was the rustc 1.100 follow-up, merged with every expensive job
  pending. It was exactly the commit whose full results would have shown
  cause 2 before main did.

**Infrastructure that fails a run on one packet.**

- 5 of the 14 failed runs (causes 3 and 4) tested nothing about the
  product.
- MAIN-CI-FAILURES-2026-11.md's mitigation 8 ("Retry infrastructure, never
  tests") was never written down as a rule. The network calls added since
  then did not retry.

**Most commits never get a full result.**

- 17 of 22 completed `tests` push runs on main in the window were cancelled
  by a newer push (cancel-in-progress, CI-RUNS.md section 1). Each other
  test workflow lost 15 runs the same way.
- A failure that appears is therefore attributed to whatever commit's run
  survived, not to the commit that caused it. That is why the window looks
  like seven separate breakages at ede621b1.

## 4. What this change fixes, and how it was checked

All checks were run on Linux x86-64 with rustc 1.100.0 (0ef1bc386
2026-11-09) and Tcl 9.0.1.

| Failure | Change | Checked here |
|---|---|---|
| Unicode case tables (2.2) | `native/src/runtime/lower16.rs`, generated by `tools/unicode-lowercase.tcl` from `core::strings::lowercase` and read by `rt_str_lower`; the Rust oracle uses it; a test that the table is the generator's; rustc 1.100's scalars among the known facts (four in the Tcl test, six in the Rust one) | native-tcl-unicode.test 126 of 126 (it was 1 failing before); argv.test 71 passed, 6 skipped (Windows-only), 0 failed (it was failing before); `cargo test --lib -- lowercase string_alloc` 18 of 18; `tools/unicode-lowercase.tcl check` ok |
| API reads (2.3) | `Api.reading`: GET retried on 5xx and transport errors, writes never; transport errors on writes are ApiError | `tools/ci/test_runs.py` 66 of 66 (three new tests); `audit/macos-release/tests/test_workflow.py` 25 of 25 |
| Tcl download (2.4) | `fetch` with `--retry 5 --retry-all-errors` in `.devcontainer/setup.sh` | `bash -n`; CI decides (arm64 runners) |
| Coverage report (2.6) | each failed test's own report, from tcltest's output | the reporting path with a synthetic log (`-log`); CI decides |

Also run:

- `tools/mutant-catalogs.tcl`: 108 catalogs, 3,717 mutants, 0 problems.
- `tools/compilerpedia.tcl check`: 1,300 topics, 778 examples, 0 problems.
- `cargo test --release --lib`: 348 of 348.
- The whole local suite, `tests/local.tcl`: every Tcl test file on interp
  and compile, and every golden suite on four backends, through the
  front-end cache from empty.
  - 700 of its 702 items passed and none failed.
  - The two left were warning-gate.test's passes, still running when the
    background task's two-hour limit stopped it.
  - warning-gate.test, run on its own afterwards, passed 6 of 6.

## 5. Proposed changes to the canary

These are proposals; none is implemented here. They are ordered by how
much of this window each would have caught before main.

**C1. Know the toolchain, and select by it.**

- `tools/ci/history.py` records the Rust toolchain of the newest green run
  per host in `tests/canary.tsv`, as a new line `toolchain HOST
  rustc-RELEASE-COMMIT`. The build-native action already prints this name.
- When a run's toolchain differs from that record, `tests/canary.tcl` says
  so first. It then selects every test file that declares itself
  toolchain-sensitive, before the history.
- A file declares this with a header line, `# canary: toolchain -- REASON`,
  in the style of the golden suites' `# golden-host:`. That is a property
  of the file, not an item list beside the canary's selection (AGENTS.md
  forbids such a list).
- The first ones: native-tcl-unicode.test (Rust's Unicode data),
  c-ffi.test, native-executable.test, system-linker.test and
  aot-stub-linker.test (the link and cargo's layout), numeric-text.test
  (Rust's number formatting).
- Together they cost about two and a half minutes on linux-x86_64
  (`tests/canary.tsv`'s durations: 146 s).
- This would have caught both rustc 1.100 defects in the canary of the
  first push after the change, on every host, and named the cause
  ("toolchain changed: rustc-1.99.1-... to rustc-1.100.0-...") above the
  failures.

**C2. Refresh the history now.**

- The `ci tools` job's recomputation failed on three of its recent runs
  (section 2.3), so `tests/canary.tsv` still describes the 21 days before
  2026-11-10.
- This branch's `ci tools` run (43524786870) recomputed it with the
  retrying reads. Its `canary-records` artifact adds application-library.test
  (linux-x86_64, linux-aarch64), external-tools.test (linux-x86_64) and
  coroutine-fusion.test (windows-x86_64), and moves c-ffi.test and
  c-bindgen.test to 2026-11-13.
- main's runs at 14937461 had not finished, so argv.test and
  native-tcl-unicode.test are not in it yet. Commit the records of the
  first `ci tools` run after those runs finish.

**C3. Select by source, not only by test file.**

- AGENTS.md already says, per area, "If you change X, run Y". The canary
  reads none of it: a push that changes `native/src/runtime/ops.rs` or
  `.devcontainer/setup.sh`, and no test file, gets only the history.
- Encode those sentences as data, for example `covers PATH-GLOB ITEM`
  lines in `tests/canary.tsv` beside `history`, `duration` and `cost`.
  Then a changed source selects the test files its section names, the
  smallest first, after the changed test files.
- The sections are long and drift. A first version could cover only the
  native runtime and the CI tooling, the two areas of this window.

**C4. Run the canary on a schedule against the newest toolchain.**

- A daily scheduled run of each test workflow's canary job on main,
  installing the newest stable Rust (beside the pinned one, if A1 below is
  taken), with C1's selection.
- It turns "stable moved under main" from a red merge into a report the
  morning after Rust's release, before any push depends on it.

## 6. Proposed changes to AGENTS.md

Ready-to-apply text, by section. None is applied here.

**A1. "Building the native (Cranelift) backend": pin the toolchain.**
Replace the `rustup toolchain install stable` advice with:

> The Rust toolchain is pinned: `native/rust-toolchain.toml` names the
> release every build uses (`.devcontainer/setup.sh`, every workflow, the
> package author image), so a new stable Rust reaches the repository only
> as a commit. A toolchain bump is a change of its own, on a branch: every
> test workflow dispatched on it, merged only green. Never install
> `stable` in CI. rustc 1.100 reached every workflow at once on
> 2026-11-13 and broke the link (cargo's new layout) and
> `std::str::lowercase` (Rust's Unicode 17+ tables) with no commit
> (MAIN-CI-FAILURES-2026-11-13.md).

This is a decision for the maintainer. It moves the cost of upgrades from
surprise red to scheduled bumps, and it needs the pin in five places
(setup.sh, setup-macos.sh, setup-windows.ps1, the package author image,
`single/`).

**A2. A new section after "Character classes of a UnicodeChar": Unicode
data is the language's, never the toolchain's.**

> Every Unicode fact Botlish defines (case mapping, character classes) is
> Unicode 16's, as the reference (Tcl 9.0.1, core/strings.tcl,
> core/tclcompat.tcl) has it. The native runtime takes it from a committed
> table generated from the reference (`native/src/runtime/lower16.rs`,
> `tools/unicode-lowercase.tcl`) or from a pinned crate
> (`unicode-general-category`), never from Rust's standard library:
> `char::to_lowercase`, `to_uppercase`, `is_alphabetic`, `is_numeric`,
> `is_whitespace` and `str::trim` read tables each stable Rust may
> update. A Rust test's oracle never uses them either: it would move with
> the implementation. If you change the table, its generator or
> `core::strings::lowercase`, run `tools/unicode-lowercase.tcl check` and
> tests/native-tcl-unicode.test.

**A3. "Git workflow": no merge with pending runs for a change outside the
canary's sight.** After "Pending runs are acceptable: report them as
pending, never as passed.":

> Except for a change the canary cannot select by: one motivated by
> something outside the repository (a new toolchain, runner image or
> external service), or one that changes how CI builds or installs
> (`.github/actions/`, `.devcontainer/setup.sh`, `native/Cargo.lock`, a
> workflow's toolchain or cache). Such a change merges only once its
> dispatched runs have finished: 14937461, the rustc 1.100 follow-up,
> merged with them pending, and its first finished job found the
> Unicode drift.

**A4. "CI housekeeping": retry infrastructure, never tests.** A sixth
rule:

> * **Infrastructure retries, tests never do.** Every network operation a
>   workflow or a CI tool makes outside a test is retried on a transient
>   failure: downloads with `curl --retry 5 --retry-all-errors`,
>   `tools/ci/runs.py`'s reads (`Api.reading`). A write that could act
>   twice (a dispatch, a release, a push) is never repeated, and a test is
>   never re-run to make it pass. Five of the 14 failed runs of
>   2026-11-09..13 were one lost packet each.

**A5. "Tests that hold on every host": a report shows the failure.**

> A tool that summarizes a test run (tests/native-coverage.tcl, tier.tcl,
> the golden check) prints each failed test's own report, never a prefix
> of the run's output: the cranelift coverage job's first 20,000
> characters were all unsupported tests', and the one failure in it
> (vt-large, 023dfaa3) left no trace.

## 7. Left open

- **`vt-large`:** not reproduced. The next failure will print its report.
- **The other hosts:** the Unicode fix is host-independent (the same Rust
  code and table), but Linux AArch64, macOS and Windows confirm it only in
  CI.
- **Main's runs at 14937461:** at the time of writing, their remaining
  jobs were still running. Failures there of argv.test and
  native-tcl-unicode.test are cause 2, which this change fixes. Anything
  else is new and not described here.
- **The queued ghost runs at 73c32da8** (section 2.7).
- **The proposals of sections 5 and 6.**
