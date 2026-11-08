# CI-RUNS.md -- superseded runs, merged branches' runs, the release gate, the canary, and commits already tested

GitHub-hosted runners are a limited pool: a fixed number of jobs run at
once for the account, and macOS jobs have a much smaller cap of their own.
One push to main starts about 16 macOS jobs (tests (macos arm64)'s 14 and
the macOS game's 2) and dozens of Linux and Windows jobs. On 2026-11-05 34
runs were queued; 13 of them tested code that was already obsolete. Some
were runs of main at commits that later merges had superseded. The others
were runs of branches already merged into main. One superseded main run (at
17b0e66) had held its place in its workflow's queue for four hours while
the run of main's newest commit waited behind it.

Three rules came out of that, a fourth from the cost of a red push, and a
fifth from the cost of a commit tested twice; this document is their
reference:

1. A newer push cancels a running test workflow on the same ref, on main
   too (section 1).
2. `prune-runs.yml` cancels the unfinished runs of branches that are fully
   in main (section 2).
3. A release is published only once every test of its commit is green,
   GC stress included, by a run of its own that a superseding push does not
   cancel (section 3).
4. Every test workflow first runs a canary, the tests likeliest to fail,
   for about ten minutes, and its expensive jobs wait for it; a branch
   push runs only the canary, on every host (section 4).
5. A branch push at a commit another run already tests defers to that run
   and runs nothing (section 5).

`tools/ci/runs.py` implements the pruning, the release gate and the
deferral, `tests/canary.tcl` and `tools/ci/history.py` the canary. Nothing
in the compiler reads any of it.

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
| `tests.yml`: a successful run whose GC-stress jobs (`tests (native GC-stress, interp/compile)`) succeeded | GC stress runs only on pushes: a manual run skips it, and a skipped job is no success |
| `tests-arm64.yml`: a successful run whose GC-stress jobs (`arm64 tests (native GC-stress, interp/compile)`) succeeded | the same, on Linux AArch64 |
| `macos-arm64.yml`: a successful run whose acceptance jobs (`acceptance (Tier B, macOS arm64, shard N/4)`) succeeded | macOS; a branch push runs only the smoke job (section 4), a deferred run nothing (section 5), a manual run with `app_only` only the application's jobs |
| `windows-x86_64.yml`: a successful run whose acceptance jobs (`acceptance (Windows x86-64, shard N/4)`) succeeded | Windows; a branch push runs only the canary, a deferred run nothing |
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

The job that publishes is in a group of its own too, `NAME-publish`, so
that two release runs never move the tag and upload at once. It must never
be `NAME-release`. A job that asks for the group its own run holds waits
for its run, which waits for the job, and GitHub fails the job before it
gets a runner. Every release run of single-executable.yml and
icy-tower-windows.yml failed that way, from the gate's first dispatch
(run 42208024676, 2026-11-06) until the publish jobs were renamed
(2026-11-08): the gate dispatched them, but nothing was ever published.

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
| tests.yml | job `canary`, after its steps for the two cheap gates (every mutant applies, the warning gate) | every other job |
| tests-arm64.yml | job `canary` | every other job |
| macos-arm64.yml | the smoke job's last step | system-linker, acceptance, app (and app-clean, link-plan-sdl3 and main-thread-startup after it), full |
| windows-x86_64.yml | job `canary` | every other job (acceptance and system-linker still also after smoke, whatever its result) |

The two cheap gates are steps of tests.yml's canary job, not jobs: on
2026-11-05, as jobs of their own, the warning gate waited 55 minutes for a
runner after the canary had passed, and the expensive jobs waited with it.
Each step runs whatever an earlier one found, so one red push reports all
three.

### A branch push runs only the canary, on every host

Every test workflow runs on every branch push, but there only its canary
job: tests.yml's and tests-arm64.yml's `canary`, windows-x86_64.yml's
`canary`, macos-arm64.yml's `smoke` (whose last step is the canary) with
its `linux control`. The other jobs run on pushes to main, on pull requests
(on macOS and Windows a fork's: a same-repository pull request's push
already ran) and when dispatched (`workflow_dispatch` with the branch as
the ref; macOS's and Windows' default inputs run their ordinary jobs), and
GC stress only on pushes to main (and arm64's in a manual run).

A branch push still runs the opt-in jobs its head commit's message asks
for: `[ci-full]` (macOS's and Windows' `full`, with its `CI-Tests:` and
`CI-GC-Stress:` trailers), `[ci-app-mutants]` (macOS's `app-mutants`) and
`[ci-probes]` (Windows' `roots`, with its probes). A marker counts
anywhere in the message, prose included (`contains()`): the commit that
introduced this rule named all three in its description and so queued
every opt-in job on its branch, hours of macOS and Windows runners, until
the next push cancelled them. Write a marker in a commit message only to
ask for its jobs.

Until 2026-11-08 macOS and Windows ran everything on every push. Their
runners are the pool's scarcest, and most of those runs tested a commit a
later push replaced: of macos-arm64.yml's last 100 push runs before the
change (2026-11-06 to 11-08), 75 were branch pushes, 55 of them cancelled by
a newer push to their branch (and 20 of main's 25 by a newer push to main),
and a successful run took 71 minutes to 9 hours from its start, queue
included. A branch is merged at its tip, which the merge rule (AGENTS.md,
"Git workflow") tests with a dispatched run of every test workflow: the
pushes before it get the canary's quick verdict, on every host.

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
canary finds stops after one job per host. A branch push costs one job
per host (two on macOS: the smoke job and its Linux control).

The canary orders; it skips nothing. A test it runs runs again in its
ordinary job, and a failure it misses is found there as before. It is no
substitute for the checks AGENTS.md names for an area.

## 5. A commit already tested

A commit is one tree: two runs of a workflow at one commit test the same
code. Branch pushes repeat commits: a branch that
merges main and is then pushed beside main (main fast-forwarded to it), a
commit pushed to a second branch, a branch moved back to a commit it had.
Of macos-arm64.yml's last 100 push runs on 2026-11-08, 18 tested 9
commits twice, each once on main and once on a branch (fe607ecc's two runs
were created two seconds apart).

So a run of a test workflow on a **push to a branch other than main** first
asks whether another run of the same workflow already tests its commit
(`tools/ci/runs.py twin`, the composite action `.github/actions/twin`, the
step "Already tested at this commit?" right after the checkout of the
canary job and of every other job a branch push runs). It defers to:

1. **main's push run at the commit**, while it is unfinished or once it
   succeeded. Main's run is the whole workflow, and only a newer push to
   main cancels it, which supersedes the commit there too;
2. else **another branch's push run at the commit** that finished,
   succeeded and ran its canary step (`Canary`): an unfinished one may be
   cancelled by its own branch's next push, and a deferred one tested
   nothing.

A push run of the same commit is at least the test a branch push is: the
same canary, or the whole workflow, and the same head commit, so the same
opt-in jobs (a commit's message is part of it). A failed or cancelled run
is no twin: the push tests the commit itself, and a failure is seen where it
was pushed. A dispatched run, a pull request's run and a run of main never
defer: they were asked for, or they are what the release gate and every
merge read (section 3).

A deferred run skips every later step of its jobs (and the jobs that wait
for its canary skip), succeeds, writes `deferred=true` and the twin's URL
as the step's outputs and "Deferred: commit SHA is tested by RUN" to its job
summary. **Its result is the twin's: read that run.** The release gate never
counts it (it has no GC-stress or acceptance job: section 3).

The lookup costs one request (the runs at the commit) and, for another
branch's run, one more (its jobs); a run of main asks nothing. An API error,
or an answer it cannot read, never defers: the run tests its commit and the
step says why, as a warning.

Not done: deferring by tree rather than commit. Its case would be a merge
whose tree equals its branch tip's (4 of the 94 merges into main from
2026-09-15 to 11-08), and that is a commit of main, which never defers.

## 6. The housekeeping's own tests

`tools/ci/test_runs.py` (no network) runs the release check, the gate,
the pruning and the deferral against a fake of the GitHub API over a small
commit graph:

* green, pending, failed and missing requirements; skipped GC stress; a
  macOS or Windows run without its acceptance tier (a branch push's, a
  deferred one's); any ref's runs at the commit; release runs that are no
  build;
* the gate's newest green commit, its tag rule, its rule against
  dispatching twice, and the deferral of tags;
* every case the pruning must and must not cancel;
* every twin a branch push must and must not defer to (main's unfinished,
  successful, failed and cancelled runs; another branch's unfinished,
  failed, deferred and tested ones; another workflow, commit or kind of
  run; itself), who never defers, and the command's outputs, summary and
  errors (which never defer).

It also checks the requests the API client makes. With PyYAML it checks
the workflows' side of the rules:

* every workflow that tests a push cancels a superseded run, main's
  included;
* only a release run publishes, after the check;
* no job asks for the concurrency group its own run holds, in any kind of
  run its workflow has (its groups' expressions are evaluated for each);
* the gate listens to every workflow a release waits for;
* only the two housekeeping workflows may start or cancel runs;
* every test workflow runs the canary on every branch push, its other
  jobs wait for it (a job that runs after a failed need checks the
  canary's result itself), and a branch push runs nothing else on any
  host but macOS's Linux control and the jobs its message opts into;
* every job a branch push runs defers with it: the canary job (and a job
  that does not wait for it) by its own twin step right after its
  checkout, every later step skipped once it defers, with `actions: read`;
  an opt-in job after the canary by the canary job's `deferred` output.

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

## 7. What to run when changing this

For a change to `tools/ci/`, to a workflow's concurrency or triggers, to a
release job, or to the name of a workflow or a GC-stress job that a
requirement names:

* `python3 -I tools/ci/test_runs.py`;
* for the canary, `tclsh9.0 tests/canary.test`, and a push to a branch:
  read every workflow's canary;
* `python3 -I audit/macos-release/tests/test_workflow.py` and that audit's
  mutants (`audit/macos-release/tools/mutate.py`) for icy-tower-macos.yml;
* `tclsh9.0 tools/mutant-catalogs.tcl`;
* push, and read the `ci tools` run's dry runs (the gate, the pruning, and
  what a branch push at main's head would defer to).

A new release goes into `RELEASES`, a new required workflow into `CORE`,
and both into release-gate.yml's `workflow_run` list. A new workflow that
tests a push gets the concurrency block of section 1, a canary job that a
branch push runs alone and that defers (section 5), and, in `CORE`, the
jobs a branch push skips. The tests check all of it. A new job a branch
push runs (an opt-in job) defers too.

## 8. Limits

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
* A branch push deferred to main's unfinished run gets no verdict of its
  own: if a newer push to main cancels that run, the commit is tested
  nowhere until something runs it again (a dispatch, or the branch's next
  push). Main's queue can also hold the twin for hours, longer than the
  canary would have taken. Both are bounded by the commit being main's: the
  branch adds nothing to it.
* A branch push's canary is not the branch's verdict. The merge rule
  (AGENTS.md) dispatches every test workflow on the branch tip; a dispatched
  run never defers.
