# MAIN-CI-FAILURES-2026-11.md

The post-merge CI failures on `main` from 2026-10-28 to 2026-11-02: every
distinct cause, what fixed it, and what would keep each class of cause out
of `main`, including what the golden test framework could do.

Method: every completed workflow run on `main` in the window, and in the
five days before it (920 runs, through the GitHub API). For each failing
run, the logs of its failed jobs, with each failing test traced to the
first and the last run it appears in. The fixes were checked on Linux
x86-64 (section 5). Their effect on Linux AArch64, macOS and Windows is
for CI to confirm after the push.

## Contents

1. [Summary](#1-summary)
2. [Was it more than usual?](#2-was-it-more-than-usual)
3. [The failures, one by one](#3-the-failures-one-by-one)
4. [Why they reached main and why they stayed](#4-why-they-reached-main-and-why-they-stayed)
5. [What this change fixes, and how it was checked](#5-what-this-change-fixes-and-how-it-was-checked)
6. [Root-cause mitigations](#6-root-cause-mitigations)
7. [What the golden test framework could do](#7-what-the-golden-test-framework-could-do)

## 1. Summary

The window had 35 failed workflow runs on `main`, from 15 distinct causes.
Four of them account for most of the red on November 1 and 2. All four are
tests that encoded an assumption about the host:

| Failure | Assumption | Red on | Since |
|---|---|---|---|
| `workload-icy-tower-release-tooling` | the system `python3` has a recent enough `cryptography` | Linux AArch64 | 2026-11-01 12:23 |
| `pm-remove`, `pm-crash-recovery`, `pm-lock-busy` | `glob *` skips dot-files; a lock holder's liveness can be checked (`/proc`, `kill -0`) | Windows | 2026-11-01 12:37 |
| `pn-unsupported-target` | the host is linux-x86_64 | Linux AArch64, macOS, Windows | 2026-11-02 05:39 |
| `pn-view-crash-recovery` | a lock holder's liveness can be checked | Windows | 2026-11-02 05:39 |

None of these is a defect of the product. The code behaves as its milestone
reports document on every host. Each test was written and run only on
Linux x86-64, and the three milestones that added them (the Icy Tower.app
release tooling, PM-1, PM-2) merged before the other hosts' results were
in. PACKAGE-MANAGER-MILESTONE-1.md says so itself: "Not run on macOS,
Windows or Linux AArch64".

The other eleven causes:

- **A semantic interaction across hosts.** A Linux-validated front-end
  change turned a macOS-only audit program's run-time error into a
  compile-time one. Fixed on `main` already.
- **Two shared-state races in Rust unit tests.**
- **A macOS acceptance tier that outgrew its time limit.**
- **A git race in a workflow that pushes to `main` itself.**
- **Three flaky graphical or timing tests.**
- **Two infrastructure failures:** a lost runner and an artifact upload
  timeout.
- **An access violation in the Windows driver's unit tests**, seen once and
  not reproduced.

This change fixes the four host-assumption failures, the two races, the
time limit and the workflow race. Section 5 lists what it leaves open.

The causes behind them are structural. Linux x86-64 and AArch64 CI run only
after a merge. Results from the other hosts arrive hours after the next
merges, or never: about 40% of main's macOS and Windows runs were cancelled
while still queued. And once `main` was red on a host, later merges treated
red on that host as "main's own" (section 4).

## 2. Was it more than usual?

By raw count, no. These are pushes to `main` and their workflow runs:

| Window | Pushes | Failed runs | Pushes with a failed run | Where |
|---|---:|---:|---:|---|
| 2026-10-22 to 10-27 | 47 | 45 | 24 | tests (x86-64) 12, Windows 13, c-bindgen 9, scalar-asm-audit 3, macOS 3, arm64 2, icy-tower 2, react-native probe 1 |
| 2026-10-28 to 11-02 | 45 | 35 | 19 | arm64 12, macOS 10, Windows 6, icy-tower (macOS) 4, scalar-asm-audit 2, tests (x86-64) 1 |
| of which 11-01 and 11-02 | 14 | 28 | **13** | arm64 12, macOS 7, Windows 5, icy-tower (macOS) 4 |

What changed is concentration and location. On November 1 and 2, 13 of 14
pushes left a workflow red. Nearly all of that red sat in the three
workflows that never run on a branch before its merge (Linux AArch64) or
whose branch results nobody waits for (macOS, Windows).

A failed-run count also overstates the number of defects. A failure that
stays on `main` fails every later push: the 12 failed arm64 runs are three
causes, two of them persistent.

## 3. The failures, one by one

Run ids are GitHub Actions run ids on `main`. "Fixed here" means by this
change.

### 3.1 Host assumptions in new tests (the persistent red)

**`workload-icy-tower-release-tooling`** (`tests/workload-icy-tower.test`).

- **Where:** Linux AArch64, every Tcl job, from run 41306276031 (c5b72f62,
  11-01 12:23, the merge carrying f5f4d358, "Icy Tower.app, Developer ID
  release tooling") to the last run in the window.
- **Symptom:** `test_credentials 1 {child process exited abnormally}
  test_release 1 {...}`.
- **Cause:** the test runs `audit/macos-release/tests` with whatever
  `python3` the host has, as long as `cryptography` and `yaml` import. The
  arm64 runner's `python3` imports Ubuntu 24.04's `cryptography` 41.x.
  `credentials.py` reads `Certificate.not_valid_before_utc`, which exists
  only from cryptography 42 on, and fails with an AttributeError.
  Reproduced here with cryptography 41.0.7: 54 of 63 credential tests fail
  that way. With the pinned environment, 63 of 63 pass.
- **Why only arm64:** the x86-64 runner's `python3` happens to have a newer
  cryptography (the test ran and passed in `tests.yml`). The icy-tower
  workflows pass `BOTLISH_RELEASE_PYTHON`, a virtual environment holding
  the pins.
- **Fixed here:** the `releaseTooling` constraint now requires the pinned
  environment, every package of `audit/macos-release/requirements.txt` and
  `examples/games/icy-tower/macos/requirements.txt` at its pinned version.
  Another version is not the environment the tooling is written for, and is
  no evidence either way. The suites now run in the icy-tower workflows
  (Linux and macOS, pinned) and are skipped in `tests.yml` and
  `tests-arm64.yml`.

**`pn-unsupported-target`** (`tests/package-native.test`).

- **Where:** Linux AArch64 (every Tcl job and the system-linked one), macOS
  (system linker and acceptance) and Windows (acceptance), from run
  41395294975 (1ed72b5e, 11-02 05:39, PM-2) to the last run in the window.
- **Symptom:** `1 PROJECT {error: the project APP has no botlish.json (PM
  PROJECT)} ...`.
- **Cause:** the test packs a package supporting linux-x86_64 only, then
  runs `pm add outer` without `-target`. `pm add` prepares the host's
  target (`pm/install.tcl`), which on those hosts the package does not
  support, so the add refuses with TARGET. The test's `pm` helper does not
  check the status, and everything after it cascades.
- **Fixed here:** the add names `-target linux-x86_64`, as its neighbour
  `pn-unprepared-target-diagnostic` already does.

**`pm-remove`** (`tests/package-manager.test`).

- **Where:** Windows acceptance, from run 41307355435 (effecc7d, 11-01
  12:37, the first main run after PM-1 that started at all) on.
- **Symptom:** the listing of `.bot_modules` was `.botlish geometry`
  instead of `geometry`.
- **Cause:** Tcl's `glob *` skips names starting with a dot on Unix, not on
  Windows.
- **Fixed here:** the listing leaves out dot-entries explicitly.

**`pm-crash-recovery`, `pm-lock-busy`** (`tests/package-manager.test`) and
**`pn-view-crash-recovery`** (`tests/package-native.test`).

- **Where:** Windows acceptance, the first two since effecc7d and the third
  since 1ed72b5e.
- **Symptom:** `PM LOCKED ... this host cannot tell whether it still runs`
  where the tests expected an automatic rollback, or `BUSY`.
- **Cause:** `pm::install::ProcessAlive` reads `/proc` or `kill -0`. On a
  host with neither it answers "cannot tell". `pm` then refuses a held lock
  as LOCKED (never BUSY) and rolls an interrupted operation back only when
  given `-recover`. That is the documented design
  (PACKAGE-MANAGER-MILESTONE-1.md, "Transactions"); the tests encoded only
  the Unix branch.
- **Fixed here:** both files state the host rule themselves (`/proc` or a
  Unix `kill -0`), so a defect in `pm`'s own answer cannot change what the
  tests expect. Where liveness is unknown, the command after a crash
  passes `-recover` (`afterInterruption`), and a held lock is expected to
  be LOCKED rather than BUSY. Both answers refuse to run beside the holder,
  which is the property under test.

### 3.2 A semantic interaction across hosts (fixed before this change)

**`mts-main-process-semantics`** and the main-thread census
(`tests/main-thread-startup.test`,
`audit/macos-graphical-main-thread/tools/census.py`).

- **Where:** macOS (main-thread startup, system linker, an acceptance
  shard), from run 41188731958 (69fad1b4, 10-31 09:26) to 41395294946
  (1ed72b5e).
- **Cause:** METHOD-RECEIVER-TYPE-CORRECTNESS-MILESTONE-1.md made a
  native's argument kinds a compile-time check. The audit program
  `audit/macos-graphical-main-thread/programs/errors.bot` produced its
  run-time TYPE error with `erased(true) + erased(false)`, which is now
  rejected at compile time. That made 15 census cases `FAILED-BUILD
  (UNEXPECTED)`.
- **Why it slipped through:** the program is built only by macOS jobs. The
  milestone's own CI evidence names `tests.yml` and `static-decisions.yml`,
  both Linux.
- **Fixed by:** 6d9cbbc7 ("errors.bot's runtime error through `any`"),
  merged in 666b6f8e. The first green run was 41407791117.

### 3.3 Shared state in parallel unit tests

**`codegen::clif::win64_variadic_tests`** (Windows smoke, run 40769307835,
ecc5fd69, 10-28).

- **Symptom:** `ffi_win64_variadic_integers_direct` saw `argument 2 (l) in
  r8: 0xfffffffde78ee600` and `argument 3 (i) in r9: 0xbff4000000000000`.
  Those are -9000000000 and -1.25, the arguments of
  `ffi_win64_variadic_doubles_in_both_registers`.
- **Cause:** both tests execute JIT code that calls `capture`, which writes
  one `static mut CAPTURED`. The test harness runs them on parallel
  threads.
- **Fixed here:** a mutex is held from clearing `CAPTURED` to reading it
  back. The tests run on any x86-64 host and pass here.

**`runtime::platform::macos::tests::region_reads_the_protection_of_a_mapping`**
(macOS smoke, run 41188731958, once).

- **Symptom:** `confirmed_guard_low(base + page)` returned 24 pages below
  the mapping.
- **Cause:** the test assumed nothing inaccessible lies below a fresh
  three-page `mmap`. The kernel placed it directly above another
  `PROT_NONE` mapping (made by a test on another thread), and the guard walk
  stepped into it, as it should.
- **Fixed here:** the mapping is four pages, with an accessible sentinel
  page under the guard, so the walk ends inside the test's own mapping.
  This was type-checked for `aarch64-apple-darwin` here; it runs only on
  macOS.

### 3.4 Capacity: a tier that outgrew its time limit

**macOS acceptance (Tier B)**, 2 shards, `timeout-minutes: 75`.

- **Where:** runs 41244352962, 41330625054, 41348966603, 41407791117 and
  41422986595 were cut off in the golden phase. Shard durations grew from
  54–56 minutes (run 41184440191) to 61–76; the Tcl test files alone took
  57–73. No golden suite had failed before the cut-off.
- **Cause:** every milestone adds test files and suites, while the shard
  count stayed fixed. `tests/platform/tier.tcl` shards round-robin by
  index, not by cost.
- **Fixed here:** three shards (`.github/workflows/macos-arm64.yml`; the
  Tier C job already uses three).

### 3.5 A workflow that pushes to main

**`scalar-asm-audit`**: runs 40583076780 (ff0826c3, 10-27), 40638181568
(803223e6, 10-28) and 41057758189 (cae2fb3e, 10-30).

- **Symptom:** the regeneration itself passed. Then `git rebase
  origin/main` conflicted in `audit/native-scalar-asm/README.md`, whose
  revision line another regeneration (or a merge carrying one) had
  rewritten meanwhile.
- **Cause:** the workflow does not cancel in progress, so a queued run
  regenerates from an older commit than main's tip.
- **Healed on its own:** each time, the next run pushed a corpus.
- **Fixed here:** on a conflicting rebase or a rejected push, the run
  regenerates from the tip itself (rebuilding the backend for its sources)
  and tries again, up to three times. Neither side's corpus is the tip's
  in that situation, so taking either side would be wrong.

### 3.6 Flaky tests (made diagnosable or tolerant, not reproduced)

**`el-linux-inflight`** (`tests/event-loop-linux.test`), arm64 GC-stress,
compile pass. Run 41298098392 (f70542b1), once.

- **Symptom:** `stale records` was 0 where at least one was expected.
- **What it requires:** a record of r1's old generation collected after the
  revocation. The producer cannot run out first: it posts 2000 records
  against backpressure, retrying `-EAGAIN`, and stops only when E1 closes.
  The scheduler counts every later old-generation record as stale. A
  revocation with a held record schedules its release (`revoke_checked`,
  `schedule_release`), and `evl_release` puts E1 back into rotation.
- **A normal run here** (x86-64): `e1 discarded at close 0`, `stale records
  286`, 27 holds and 27 releases. So stale = 0 means that nothing E1's
  producer posted after the revocation was collected before the close.
  Either the release was lost (E1 left paused) or the producer was starved
  for that whole window.
- **Not reproduced:** 25 runs under `BOTLISH_NATIVE_GC_STRESS=1` on x86-64
  passed.
- **Changed here:** the program also reports the loop's holds and releases
  and what the driver took. On a failure the test shows those lines and the
  close count instead of a bare 0, which tells the two explanations apart.

**icy-tower (macOS), graphical acceptance case `restart`**: runs
41328556692 and 41395294950. Both look like synthetic Quartz key events
lost or delayed on the hosted runner:

- **First run:** the held Right key never reached the game. The summary
  shows round 1, the player still at the centre (`x=227`), not over.
  `Game.press` confirms a press by the player's move, and on failure
  releases the key, takes the focus again and retries, three times. The
  case did not check that result, so it reported a game that does not end.
- **Second run:** the player's feet row (579) lay inside the oracle's range
  (546 to 680). The failing part was the centring check, consistent with
  the Right key-up arriving late.
- **Changed here:** the case reports "Right reaches the game" with the
  press's own account. An unconfirmed press now fails as an input failure,
  not as game behavior; it is still a FAILED case, never a pass.

**icy-tower (macOS), LaunchServices case `app-gatekeeper`**: run
41450398416, "the game never started" failed after every Gatekeeper check
had passed. `macos-session.py` found a process of the bundle within 3 s of
Done. LaunchServices can register an instance of a refused bundle while
Gatekeeper's dialog is up and end it after Done.

- **Changed here:** a process found after Done counts as a started game
  only if it shows a window or is still running 5 s later. The game opens
  its window at once and waits for its player, so a started game does both.
  The case records the process's facts (parent, arguments, whether it had a
  window, whether it was still running), so a recurrence is explained.

### 3.7 Infrastructure (not fixed)

- **`tests` (x86-64), job "method-call decision (oracle, reference
  audit)"** (run 40769307831): the step is recorded as still running after
  the job ended, the log is unavailable, and there was no timeout. This is
  a lost runner. The same step passed on the next run.
- **icy-tower (macOS), `actions/upload-artifact`** (run 41348966717):
  `CreateArtifact` timed out after 5 attempts. Every test step had passed.

### 3.8 An access violation in the Windows driver's unit tests (not reproduced)

- **What happened:** in the `main` run of 29422cd9 (41450398631, still in
  progress at this writing), the `botlish-native` unit-test binary ended
  with `0xc0000005` after 66 of 121 tests had reported.
- **Not deterministic:** the same commit's branch run (41450393999) passed
  the step.
- **Candidates:** the tests still running at the crash were the dense
  switch, the context-area object, and the two mutarray-inline tests,
  which execute JIT code against the runtime.
- **What this change adds:** a diagnostic, not a fix. When a test binary
  crashes, the smoke step runs its tests again on one thread, where libtest
  prints each name before the test runs. The next crash then names its
  test, or shows that only concurrency triggers it. The step still fails.

## 4. Why they reached main and why they stayed

**Linux CI runs after the merge.**

- `tests.yml` and `tests-arm64.yml` trigger on pushes to `main` and on pull
  requests. This repository merges branches into `main` directly, without
  pull requests (AGENTS.md), so neither workflow sees a branch unless
  someone dispatches it.
- Every arm64-only failure in the window was therefore first visible after
  its merge: the release tooling's Python and `pn-unsupported-target`.
- AGENTS.md asks for a dispatch before merging only for port changes, and
  some milestones dispatch `tests.yml` anyway. None of the three milestones
  above dispatched `tests-arm64.yml`.

**The other hosts' results arrive late, or never.**

- macOS and Windows run on every branch push, but a full run takes hours
  (the arm64 GC-stress job alone took 4 h 18 min).
- One push to `main` starts about 60–80 jobs across the workflows, and the
  account's runners are saturated. On November 2 the `tests` runs of
  76521a55 (09:43) and 29422cd9 (13:08) had still not started at 18:30.
- The macOS and Windows workflows keep one pending run per ref, so a newer
  push cancels the older pending one. In the window, 17 of 44 macOS and 19
  of 45 Windows `tests` runs on `main` were cancelled before starting.
  Those commits have no result on those hosts, and a failure there cannot
  be attributed to a single commit.
- A milestone that waits for its branch's cross-host results waits half a
  day. In practice the three milestones above did not wait, and said so.

**Red on main normalizes red.**

- Once `main` was red on macOS and Windows, branch reports classified those
  hosts' failures as "main's own".
- The LIST-FLAT merge's message did this explicitly ("The macOS and
  Windows failures are main's own (package-manager.test,
  package-native.test, ...)"). It was true that time, but nothing checked
  it.
- A new failure in a file that already fails, or in a shard that already
  times out, is invisible under that reading. The timed-out macOS shard
  hid its own golden phase every time.

**Tests encode the host they were written on.** The persistent failures
are not exotic. Each is a plain host assumption:

- a default target;
- a Unix glob rule;
- a POSIX liveness check;
- a system Python's library version.

Running the test file once on the other host would have shown each of them.

**Unit tests share process state.** Rust's test harness runs tests on
parallel threads of one process. A `static mut` buffer, and an assumption
about what lies next to a fresh mapping, are both sound when one test runs
alone and wrong when several run together.

**Budgets are fixed while the suites grow.** A 75-minute limit that the
tier approaches a few minutes per milestone gives no warning. The first
symptom is a cancelled job, and it lands on whichever push is slowest that
day.

## 5. What this change fixes, and how it was checked

| Failure | Change | Checked here (Linux x86-64) |
|---|---|---|
| `pn-unsupported-target` | `-target linux-x86_64` on the add | package-native.test 38 of 38 (one skipped: MinGW), interp and compile |
| `pm-remove` | dot-entries excluded from the listing | package-manager.test 74 of 74, interp and compile |
| `pm-crash-recovery`, `pm-lock-busy`, `pn-view-crash-recovery` | host-stated liveness, `-recover` where unknown, LOCKED expected there | as above. The Windows branch was exercised with `ProcessAlive` patched to answer "cannot tell" for the run: all five tests pass, then the file was restored |
| `workload-icy-tower-release-tooling` | constraint requires the pinned environment | skipped with the system Python (cryptography 50.0.1) and with 41.0.7; runs and passes in a virtual environment from `audit/macos-release/requirements.txt` |
| Win64 variadic capture race | `CAPTURE_LOCK` | `cargo test --bin botlish-native win64_variadic`: 6 of 6 |
| macOS mapping-protection test | sentinel page | `cargo check --tests --target aarch64-apple-darwin`; runs on macOS only |
| macOS acceptance timeouts | three shards | YAML validated; CI decides |
| scalar-asm-audit race | regenerate from the tip on a conflict | YAML validated; CI decides |
| Windows unit-test crash | diagnostic rerun on one thread | YAML validated |
| `el-linux-inflight` | the evidence on failure (holds, releases, driver counts, E1 at close) | 25 runs under GC stress pass; the new lines checked |
| icy-tower (macOS) `restart`, `app-gatekeeper` | an unconfirmed press reported as such; a refused bundle's transient process told from a started game | `macos-session.py selftest`; runs on macOS only (icy-tower-macos.yml) |

`tclsh9.0 tests/local.tcl tests/package-manager.test tests/package-native.test
tests/workload-icy-tower.test` passes.

Not run here, because only test files changed:
`audit/package-manager/tools/mutate.tcl`. On a Unix host the changed tests
expect exactly what they expected before (liveness known; `glob *` already
skips dot-entries), so the mutants they kill are unchanged.

Left open:

- **`el-linux-inflight`:** not reproduced, only made diagnosable;
- **the `restart` case's late key-up:** a lost key event stays a failure,
  by the harness's rule;
- **the Windows access violation;**
- **the two infrastructure failures.**

## 6. Root-cause mitigations

Ordered by how much of this window each would have prevented.

1. **Results from every host before a merge, compared against main's
   known failures.**
   - The cheap part is a rule: a merge into `main` waits for its branch's
     `macos-arm64` and `windows-x86_64` runs and a dispatched
     `tests-arm64.yml`.
   - A branch's failures are then diffed against a machine-readable
     ledger of main's known failures (test, host, since, owner), never
     dismissed as "main's own" by inspection. Anything not in the ledger
     blocks the merge.
   - The tier logs already print "Files with failing tests" and tcltest's
     `==== NAME ... FAILED` lines, so such a diff is a small tool.
   - This alone would have stopped all four persistent failures and the
     errors.bot interaction.

2. **Stop the line when main is red.** AGENTS.md already treats a failing
   `gc-stress` or `static-decisions` run on `main` as a standing signal.
   Extend that to every host's tests workflow: the next session that
   touches `main` fixes or reverts before merging anything else. The PM-1
   failures stayed red for 30 hours across six merges.

3. **Make host assumptions testable on one machine.**
   - Most of the persistent failures need no foreign runner to find, only
     a foreign answer to "which host is this":
     - `core::cabi::hostTarget`;
     - `pm::target::host`;
     - `pm::install::ProcessAlive`;
     - `glob`'s dot-file rule.
   - A test-only override honored in test processes and in the `main.tcl`
     children they start would let Linux CI run each suspect test file as
     linux-aarch64, macos-aarch64 and windows-x86_64. It would be an
     environment variable read only by those functions, in the style of
     `BOTLISH_PM_FAULT`.
   - Every test must then pass or carry a host constraint. This change
     did that by hand for the lock tests.

4. **Pin every external tool a test runs, and constrain on the pin.**
   - The release tooling is now constrained on its pins.
   - The C binding generator is the model: it records and checks the clang
     that made every binding.
   - Any test that `exec`s a system interpreter or library-dependent tool
     should check its version and skip otherwise. Runner image updates
     (the arm64 image's Python, Homebrew's Tcl on macOS) are drift no one
     schedules.

5. **Isolate unit tests that touch process state.**
   - No `static mut` in a test without a lock.
   - No test that reads the memory map, signal dispositions or the
     environment assumes it is alone.
   - Running the native Rust tests under a process-per-test runner
     (`cargo nextest`) in at least one CI job would turn shared-state races
     into deterministic passes, and a crash into a named test.

6. **Budget the tiers by measured cost.**
   - `tier.tcl` could balance shards by recorded per-file durations
     instead of round-robin.
   - A job should warn at 80% of its `timeout-minutes`, in the summary,
     before it is cancelled.
   - Superseded queued runs on `main` (`tests.yml` and `tests-arm64.yml`
     have no concurrency group, so every push queues a full run) could be
     dropped when a newer push of the same workflow is pending, as the
     macOS and Windows workflows already do. That trades per-commit
     attribution on Linux for hours of feedback latency, so it is a
     decision for the maintainer, not this change.

7. **Flaky graphical acceptance: verify input delivery before judging.**
   - `case_restart` could confirm that the held key moved the player (any
     frame with `x != 227`) and send it once more if not, recording lost
     input as an environment fact, never as a pass.
   - `app-gatekeeper` could record the found process's command line and
     parent, to tell a transient assessment process from a started game.

8. **Retry infrastructure, never tests.** An artifact upload that only a
   release tag consumes need not fail a push. A job lost with its runner
   (no log, a step still "in progress") can be re-run once automatically.
   A test failure is never retried.

## 7. What the golden test framework could do

None of the 15 causes was in a golden suite. The golden shards passed on
every arm64 run in the window, and the macOS and Windows golden phases
passed wherever they ran. The failing tests are of the kinds
GOLDEN-TEST-FRAMEWORK.md says stay in Tcl or outside Botlish:

- the process boundary (`pm`, `main.tcl`);
- Python tooling;
- Rust unit tests;
- graphical harnesses;
- CI scripts.

That is partly why the golden suites stayed green. A suite is a Botlish
program, host-independent unless it says otherwise (`# golden-host:`), and
the runner checks that declaration. So the framework would not have
caught these failures as it stands. The planned extensions bear on the
classes above as follows.

**Performance tests, against the time-limit class (3.4).**

- If the framework records each suite's compile and run time per backend
  (it measures them already for its reports) in a machine-readable form,
  `tier.tcl` can shard by measured cost.
- A budget check can then fail a merge that grows a tier past a share of
  its job's limit, as the mutation harnesses fail an "economic" mutant.
  The macOS creep from 54 to 76 minutes would have been a reported trend,
  not five cancelled jobs.
- This needs the timings to cover the Tcl test files a tier runs too, not
  only the suites.

**Integrated oracle tests, against the phase-change class (3.2).**

- `errors.bot` existed to fail at run time with TYPE. When the front end
  learned to reject it statically, nothing on Linux noticed, because the
  program's expected outcome lived only in a macOS census.
- An oracle mode in which a case states the phase and kind of its outcome
  (accepted and failing at run time with TYPE, or rejected at compile time
  with a given code) would make "this program now fails at a different
  phase" a failure on every host. The runner can observe it even where the
  library cannot (a run-time-only failure aborts a suite in-library).
- More generally, a host-specific harness should keep the host-independent
  half of its expectations as a golden suite that runs on Linux on every
  push.

**Mutation tests, against the host-assumption class (3.1).**

- The framework's mutants change code. The persistent failures of this
  window are what *environment mutants* would find: the same suite run
  with the host relabeled (target, path syntax, process liveness), every
  case required to pass or carry a declared host expectation.
- For golden suites the static half is free: compiling every suite for
  every target of `core/cabi.tcl`'s table (front end only: static
  decisions, `rejects_at`) on one Linux machine catches a target-dependent
  expectation without the target's runner.
- For the Tcl suite it is mitigation 3 above, run as a mutation pass.

**Host-dependent expectations as data.**

- Today a suite runs everywhere or is excluded from a host (`#
  golden-exclude:`, `# golden-host:`).
- An expectation keyed by a target fact (BUSY where liveness is known,
  LOCKED where it is not) would let a case state host-dependent behavior
  instead of being excluded. It needs a way for the runner to hand target
  facts to the suite as data; the static `-target` already exists.

**Repetition, against the flaky class (3.6).**

- The runner already reruns suites to check isolation. A repeat-and-shuffle
  mode, run before a merge on suites that use coroutines, the event loop
  or timing, would surface order and timing dependence while it is cheap.
- This applies only to tests ported to golden form. `el-linux-inflight`,
  with real threads and epoll, is not.

The leverage is uneven. Performance budgets and environment mutation
address classes that recur; the oracle mode addresses one class that cost
two days this time. The largest lever in this window was procedural
(mitigations 1 and 2), and no framework feature replaces it.
