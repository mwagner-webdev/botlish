# CI-RUNS.md -- superseded runs, merged branches' runs, the release gate, and the canary

GitHub-hosted runners are a limited pool: a fixed number of jobs run at
once for the account, and macOS jobs have a much smaller cap of their own.
One push to main starts about 16 macOS jobs (tests (macos arm64)'s 14 and
the macOS game's 2) and dozens of Linux and Windows jobs. On 2026-11-05 34
runs were queued; 13 of them tested code that was already obsolete. Some
were runs of main at commits that later merges had superseded. The others
were runs of branches already merged into main. One superseded main run (at
17b0e66) had held its place in its workflow's queue for four hours while
the run of main's newest commit waited behind it.

Three rules came out of that, and a fourth from the cost of a red push;
this document is their reference:

1. A newer push cancels a running test workflow on the same ref, on main
   too (section 1).
2. `prune-runs.yml` cancels the unfinished runs of branches that are fully
   in main (section 2).
3. A release is published only once every test of its commit is green,
   GC stress included, by a run of its own that a superseding push does not
   cancel (section 3).
4. Every test workflow first runs a canary, the tests likeliest to fail,
   for about ten minutes, and its expensive jobs wait for it (section 4).

`tools/ci/runs.py` implements the pruning and the release gate,
`tests/canary.tcl` and `tools/ci/history.py` the canary. Nothing in the
compiler reads any of it.

## 1. Superseded runs are cancelled, on main too

Every workflow that tests a push has a concurrency group per ref that
cancels a running member:

    concurrency:
      group: NAME-${{ github.ref }}
      cancel-in-progress: true

Main used to be exempt (`cancel-in-progress: ${{ github.ref !=
'refs/heads/main' }}`), so that every main run would finish. Main's history
shows that the exemption cost more than it bought: from 2026-10-22 to 11-05
main took 76 pushes in about eleven bursts. Inside a burst the pushes came
mostly less than an hour apart, while agents merged one after another.
Between bursts there were usually three hours or more. With the exemption,
a burst's first run kept its runners for the whole length of its jobs,
testing code the burst had already replaced, and the run of the burst's
last push waited behind it. Now the last push of each burst gets a complete
run as soon as runners free up. The ~3-hour GC-stress jobs finish too,
because the bursts end.

What is lost:

* **Which merge broke it.** Only the last push of a burst is tested on its
  own. If its run is red, the cause is one of the burst's merges (23 on
  2026-11-03).
* **Results during a long burst.** While pushes keep coming less than three
  hours apart, no GC-stress job on main finishes.
* **Cancelled runs say nothing.** A run on main cancelled by a newer push
  is neither red nor green. AGENTS.md's check of main's CI reads the latest
  run of each workflow.

The exceptions never cancel a running member:

* `scalar-asm-audit.yml` writes a commit back to main, and its push must not
  be cut off;
* `react-native-probe.yml` records every run as census evidence;
* `release-gate.yml` reads the state as it is when it runs (section 3);
* a tag's run is the release's (icy-tower-macos.yml:
  `cancel-in-progress: ${{ !startsWith(github.ref, 'refs/tags/') }}`);
* a release run is in a group of its own (section 3).

A newer member of a group still replaces one that is waiting, as GitHub
always does.

Tags no longer run the macOS and Windows test workflows (`push: branches:
["**"]` in macos-arm64.yml, windows-x86_64.yml and icy-tower-windows.yml).
A tag names a commit that was already tested where it was pushed: the
release gate takes a commit's runs from any ref.

## 2. Pruning the runs of merged branches

`prune-runs.yml` runs `tools/ci/runs.py prune` on every push to main
(documentation-only merges included), hourly, and by hand (`dry_run` only
reports). It lists every unfinished run (queued, in progress, waiting,
pending, requested) and cancels a run when:

* its branch still exists and the branch's tip is main's head or one of its
  ancestors (GitHub's comparison of the tip against main is `behind` or
  `identical`): the branch tests nothing that main's own runs do not; or
* its branch was deleted and the run's commit is in main.

Prune runs are in no concurrency group. In one, the next push to main or
the next hour replaced a run still waiting for a runner, and while the pool
was full, which is when pruning matters, none ever got one (2026-11-05:
three runs in a row replaced while queued). Runs that overlap are harmless:
each reads the state as it is, and a run already cancelled is only reported
as one it could not cancel. A prune run still needs a runner like any job.

It never cancels:

* **a run of main.** The concurrency groups already cancel main's
  superseded runs. Main's head may be a commit no workflow ran
  (scalar-asm-audit.yml's commit back, pushed with the workflow token), so
  "not main's head" would cancel the runs of the newest tested commit;
* **a run of a tag;**
* **a fork's pull request;**
* **a branch with any commit main does not have.** That is a branch ahead
  of main or diverged from it; its older commits' runs are left to its own
  concurrency groups.

## 3. The release gate

### Green

A commit's tests are **green** for a release when all of these hold:

| requirement | why |
|---|---|
| the commit is main's head or an ancestor of it | only reviewed code is released |
| `tests.yml`: a successful run whose GC-stress job (`tests (native GC-stress)`) succeeded | GC stress runs only on pushes: a manual run skips it, and a skipped job is no success |
| `tests-arm64.yml`: a successful run whose GC-stress jobs (`arm64 tests (native GC-stress, interp/compile)`) succeeded | the same, on Linux AArch64 |
| `macos-arm64.yml`: a successful run | macOS |
| `windows-x86_64.yml`: a successful run | Windows |
| `static-decisions.yml`: a successful run, if it ran at the commit | it runs only when the commit changed what it compares |
| the release's own build workflow: a successful run | single-executable.yml, icy-tower-windows.yml (the macOS release builds in its own run) |

Any run at the commit counts, on any ref and for any event, because a
commit is one tree. The newest successful one is taken. A requirement is
`pending` while a run of it is unfinished and none has succeeded, `failed`
when every run finished without success, and `missing` when nothing ran.
`tools/ci/runs.py check SHA --for RELEASE` prints the table, adds it to the
job summary, and writes `green` and `run_id` (the build run whose artifact
is published) as step outputs.

### Rolling releases: single-latest and icy-tower-windows-latest

`release-gate.yml` runs whenever one of the required workflows finishes
successfully on main (`workflow_run`), every three hours as a backstop, and
by hand (`dry_run`). For each rolling release it walks main's recent
`tests.yml` push runs, newest first, and stops at the first commit that one
of these settles:

* the release's tag already holds the commit, or a later one: nothing newer
  is green;
* the commit is not green: the walk goes on to the next older commit;
* a release run for the commit exists, in any state: nothing is dispatched.
  A failed release run is left to a person;
* otherwise the commit is due: the gate dispatches the release's workflow
  on main with `release=SHA`.

That dispatch makes a **release run** (`run-name: release SHA`). It builds
nothing. It checks the commit again (`runs.py check ... --require`), so a
release run started by hand is held to the same rule. It downloads the
artifact of the commit's green push run, which is the executable or game
that run built and tested. icy-tower-windows.yml then signs that game, when
signing is configured (ICY-TOWER-WINDOWS.md, "Signing"). Then it moves the
tag and uploads. The release job keeps its rule that a release of an
earlier commit never replaces a later one, because release runs can finish
out of order.

A release run's concurrency group is its own (`NAME-release`, never
cancelled). So a push that supersedes the commit while its release run
signs and publishes does not stop it: the release is still published. The
push cancels only the push runs of the build workflow and of the tests.
That is what makes the commit "superseded", and the superseding commit gets
its own release once its tests are green.

The gate holds no credential. Its token may only start workflows
(`actions: write`). Gate runs never overlap: a newer one replaces one still
waiting, and every run decides from the state as it is, so a replaced run
loses nothing.

### The tagged release: icy-tower-macos-vX.Y.Z

icy-tower-macos.yml's release runs on a tag. Its `tested` job runs first
and only reads runs. The game job, and so the release and publish jobs, run
only when `tested` finds the tagged commit green. Otherwise the run is
**deferred**: `tested` says so in a notice and in the job summary, and
every other job skips. Once the commit's tests are green, the gate
dispatches icy-tower-macos.yml on the tag again. It does so only when every
run on the tag finished successfully with its release job skipped (that is,
deferred) and the tag has no GitHub Release. A run in progress, a failed or
cancelled run, or a release that exists already leaves the tag to its runs
and to a person. The release job also checks `needs.tested.outputs.green`
itself (audit/macos-release/tests/test_workflow.py's
`test_release_waits_for_green_tests`; the mutant `release-before-green`).

A tag on a commit that will never be green waits forever. That happens to a
commit whose main runs a later push cancelled, or whose GC-stress jobs
never ran. Tag a commit whose tests are green instead: a burst's last push,
for instance. The gate's job summary lists each commit's requirements.

### By hand

* **Publish a green commit:** Actions, the release's workflow, Run
  workflow on main, with `release` set to the commit's full SHA.
* **Retry a failed release run:** re-run it. The gate never dispatches a
  second one for the same commit.
* **See what the gate would do:** run `release gate` with `dry_run`. The
  ci tools workflow's dry run does the same on every branch that changes
  the housekeeping.

## 4. The canary

A push that breaks a test used to cost a whole run on every host: at
13dd290, tests.yml's 16 jobs, tests-arm64.yml's 12, macos-arm64.yml's 11
and windows-x86_64.yml's 7, the longest of them hours, for a failure most
often in one or two test files. Most failures are predictable: a test fails
where it was just written or changed, and where it failed recently. So
every test workflow runs those first, on its own host, and starts the rest
only once they pass.

### What runs

`tests/canary.tcl` selects, in this order, while the estimated time fits in
its budget (`-budget`, 600 seconds):

1. **What the push changes:** the test files (`tests/*.test`) and golden
   suites (`tests/golden/*.bot`) the commits since the base add or change,
   the smallest first. The base is main's previous head on a push to main
   (`github.event.before`: every commit of the push, a burst's merges
   included), and the merge base with main otherwise, so a branch's every
   commit counts, not only its last push's. A base the history does not
   hold (a force push) falls back to HEAD's parent.
2. **What failed recently on this host:** `tests/canary.tsv`'s history
   entries for the host target, the most failing commits first.

An item's estimate is its duration in `tests/canary.tsv` (seconds on
linux-x86_64: a Tcl test file on interp, a golden suite on all four
backends), else one from its size. The selection runs through
`tests/platform/tier.tcl`, as the macOS and Windows tiers do (Tcl test
files on interp, golden suites on all four backends); the canary prints it
and adds it to the job summary, with what the budget left out.

| workflow | the canary | waits for it |
|---|---|---|
| tests.yml | job `canary`, beside `warning-gate` and `mutant-catalogs` | every other job, and for those two gates too |
| tests-arm64.yml | job `canary` | every other job |
| macos-arm64.yml | the smoke job's last step | system-linker, acceptance, app (and app-clean, link-plan-sdl3 and main-thread-startup after it), full |
| windows-x86_64.yml | job `canary` | every other job (acceptance and system-linker still also after smoke, whatever its result) |

tests.yml and tests-arm64.yml now run on every branch push, but there only
the canary (and tests.yml's two gates): their other jobs run, as before, on
pushes to main, on pull requests and when dispatched, and GC stress only on
pushes to main (and arm64's in a manual run). macOS and Windows run
everything on every push, as before, once the canary passes.

### The history

`tests/canary.tsv` is written by `tools/ci/history.py` from the GitHub API:
the pushes to main of the four test workflows created in the last 21 days,
and for every failed run the logs of its failed jobs, where the test
runners name what failed (tests/all.tcl's and tier.tcl's `Files with
failing tests`, the golden runner's suites, the golden check's
`DISAGREE`, `TCL TEST FAILED` and `SUITE NOT OK`). An item counts once per
commit, on the host its job ran on. A job that reports more than five
items is left out: a whole layer broke there, for one cause any of its
items shows. Durations come from the newest successful push run of
tests.yml on main (the interp job's per-file times, the golden shards'
per-suite times).

The first file, from 2026-10-15 to 11-05: 107 failed runs, the logs of
370 of their 373 failed jobs. A job reported zero to two items, or 15 to 30
(all of these on 2026-10-16, when every arm64 test and golden job failed at
five commits);
the history has 14 items, led by c-bindgen.test (16 commits, three hosts),
workload-icy-tower.test (14, arm64) and c-ffi.test (13, three hosts).

To refresh it: the `ci tools` workflow recomputes it on every run (a push
that changes `tools/ci/` or a workflow, or a manual run); its job summary
shows the difference from the committed file, and its log and its
`canary-records` artifact hold the new one. Commit it. Locally, with a
token: `GH_TOKEN=... GITHUB_REPOSITORY=mwagner-webdev/botlish python3 -I
tools/ci/history.py --write`.

### Locally

`tests/local.tcl` starts the same selection first (`-priority 1`, the
default; no budget): what the checkout changes against origin/main, its
working tree included, then the history for this host. `-fail-fast 1`
starts nothing more after the first failure (the running files finish)
and reports the rest as not run.

### What it costs, and what it is not

A green run starts its expensive jobs about fifteen minutes later than
before (the canary's build and its ten minutes); on main, where GC stress
takes three hours, that is under a tenth. A red push whose failure the
canary finds stops after one job per host (three on tests.yml).

The canary orders; it skips nothing. A test it runs runs again in its
ordinary job, and a failure it misses is found there as before. It is no
substitute for the checks AGENTS.md names for an area.

## 5. The housekeeping's own tests

`tools/ci/test_runs.py` (no network) runs the release check, the gate and
the pruning against a fake of the GitHub API over a small commit graph:

* green, pending, failed and missing requirements; skipped GC stress; any
  ref's runs at the commit; release runs that are no build;
* the gate's newest green commit, its tag rule, its rule against
  dispatching twice, and the deferral of tags;
* every case the pruning must and must not cancel.

It also checks the requests the API client makes. With PyYAML it checks
the workflows' side of the rules:

* every workflow that tests a push cancels a superseded run, main's
  included;
* only a release run publishes, after the check;
* the gate listens to every workflow a release waits for;
* only the two housekeeping workflows may start or cancel runs;
* every test workflow runs the canary on every branch push, its other
  jobs wait for it (a job that runs after a failed need checks the
  canary's result itself), and tests.yml and tests-arm64.yml run nothing
  else on a branch push.

It also tests `tools/ci/history.py` against fake runs and job logs: what
each test runner's report names, a commit counted once, the host from the
runner, a broken layer left out, a reason from the newest failure, and
items that no longer exist dropped.

`ci-tools.yml` runs the tests on every push that changes `tools/ci/` or a
workflow, on any branch. Then it runs the gate and the pruning against the
repository read-only (`--dry-run`), because `workflow_run` and `schedule`
triggers run only from main. While the rules were written, seventeen hand
mutations of runs.py (a skipped GC-stress job taken for success, a branch
ahead of main pruned, a tag moved backwards, a second dispatch, ...) were
all killed by these tests.

## 6. What to run when changing this

For a change to `tools/ci/`, to a workflow's concurrency or triggers, to a
release job, or to the name of a workflow or a GC-stress job that a
requirement names:

* `python3 -I tools/ci/test_runs.py`;
* for the canary, `tclsh9.0 tests/canary.test`, and a push to a branch:
  read every workflow's canary;
* `python3 -I audit/macos-release/tests/test_workflow.py` and that audit's
  mutants (`audit/macos-release/tools/mutate.py`) for icy-tower-macos.yml;
* `tclsh9.0 tools/mutant-catalogs.tcl`;
* push, and read the `ci tools` run's dry runs.

A new release goes into `RELEASES`, a new required workflow into `CORE`,
and both into release-gate.yml's `workflow_run` list. A new workflow that
tests a push gets the concurrency block of section 1. The tests check all
three.

## 7. Limits

* `workflow_run` and `schedule` run from main only, so the gate and the
  scheduled pruning start once their files are on main. The first release
  after that is the first green commit the gate sees.
* A release run publishes its push run's artifact, which expires after the
  repository's artifact retention (90 days by default). A commit's release
  run starts as soon as its tests are green.
* The gate must not overlap itself (two runs could dispatch one release
  twice), so it stays in its group, and there a newer run replaces one
  still waiting: under a full pool, every finished workflow on main
  replaces the waiting gate run, and the gate runs once the queue drains.
  A release waits for the end of a burst; nothing is lost.
* GitHub can delay or skip scheduled runs under load. The schedules are
  backstops, never the primary trigger.
* A run that GITHUB_TOKEN started, such as a gate's dispatch, may not
  itself trigger `workflow_run`. The gate does not depend on it: the test
  workflows that trigger it are pushes.
