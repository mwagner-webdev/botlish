# MAIN-TEST-DEFECTS-2026-11.md

By 2026-11-04 every failure left on `main`'s CI was a defect of a test or of
the test tooling, not of the compiler: three tests that assumed something
about the machine they ran on, and a mutation catalog whose mutant no longer
applied. This report gives each defect's cause and fix, a fifth defect of
the same kind that no CI job showed (ten more mutants that no longer apply,
eleven in nine catalogs in all), what the five have in common, why they got
through and stayed, and what keeps the class out. It follows
MAIN-CI-FAILURES-2026-11.md, whose analysis of why failures reach `main` and
stay there still holds.

Method: the logs of `main`'s CI runs from 2026-11-01 to the latest
completed one (bdd5e3d, 2026-11-04; section 2.5);
each failure reproduced in a Linux x86-64 container before it was fixed, and
the fix checked there (section 5). Every mutation catalog under `audit/`
checked against `main`'s tree, and each mutant that does not apply traced to
the first commit of `main`'s history where it stopped applying.

## Contents

1. [Summary](#1-summary)
2. [The defects](#2-the-defects)
3. [What the defects have in common](#3-what-the-defects-have-in-common)
4. [Why they got through, and why they stayed](#4-why-they-got-through-and-why-they-stayed)
5. [What this change does, and how it was checked](#5-what-this-change-does-and-how-it-was-checked)
6. [Mitigation of the class](#6-mitigation-of-the-class)
7. [Left open](#7-left-open)

## 1. Summary

| Defect | Where it failed | Since | Cause | Fix |
|---|---|---|---|---|
| `pn-concurrent-target-compiles` (tests/package-native.test) | macOS, system linker job | PM-2 (2026-11-02); failed once, 11-04, in 26 macOS executions | waited for its child processes by probing `/proc`, which macOS does not have, then read their output after a fixed 200 ms | wait by closing each process's pipeline |
| `pa-add-refusals` (tests/package-authoring.test) | Linux x86-64: interp, compile, system-linked executables, GC stress, both native coverage runs | PM-3's merge, 9bcdf6f (11-03); every run since | linked an AArch64 library with whatever linker clang found: the author's AArch64 cross binutils, absent on the runners, where GNU ld refuses (`unrecognised emulation mode: aarch64linux`) | link with `-fuse-ld=lld`; an `lld` constraint |
| `pa-pack-refuses-incomplete` (tests/package-authoring.test) | Linux x86-64: both native coverage runs | 9bcdf6f; every run since | asserted that `pack`'s output has no word `native`; the output names the repository path, and the coverage jobs' temporary directory is `/tmp/native-coverage_XXXXXX` | match the output with the path mapped out |
| `struct-ignores-non-hashable-field` (audit/hashable/tools/mutants.txt) | `audit/hashable/tools/mutate.tcl`: NOT-APPLIED (no CI job runs it) | sendability (2026-11-03) | the text it replaces now occurs twice in hir/types.tcl: `SendComponents` copies `Components`' loop | the text extended by a line only `Components` has |
| ten more mutants in eight catalogs | their harnesses: NOT-APPLIED (none ran) | 2026-10-30 to 11-03 | four milestones rewrote or duplicated the text they replace (section 2.4) | each updated to the code it mutates, the same rule; each run through its harness and killed |

`pn-bundled-checks` (tests/package-native.test) had the same unstated
dependency as `pa-add-refusals` (it links with `-fuse-ld=lld` under a
constraint that checks only clang), latent because every runner that runs it
has lld. It now carries the `lld` constraint too.

None of these is a defect of the product: the package manager, the hashing
and the analyses behave as their reports document, on every host. Each
defect is a test, or an audit's mutant, that encoded something true where it
was written and not stated anywhere a check could see.

## 2. The defects

### 2.1 `pn-concurrent-target-compiles`: a wait that only Linux has

The test starts four compilations at once, two per target, to show that
each reads its own target view. It started them with `exec ... &`, waited
with

```tcl
while {[file isdirectory /proc/$pid] && ![catch {exec ps -o stat= -p $pid} s] && ![string match Z* $s]} { after 50 }
```

slept 200 ms, and read their output files.

- **Where `/proc` exists** (Linux), the loop waits until each child is a
  zombie, and the 200 ms is slack.
- **Where it does not** (macOS; the test's `unixFiles` constraint let it run
  there, and kept it off Windows), the condition is false at once: the
  loop never waits, and the test reads whatever the children have written
  200 ms after the last one started. On the macOS runner that was too
  little for the fourth: main's run 41787767392 (bdd5e3d) read `{==
  main.bot (interp)}`, the header main.tcl prints before the program's
  value, in its place.
- **Reproduced on Linux** by renaming `/proc` in the probe: with the 200 ms
  the children finished in time here (the container is fast); with 20 ms
  all four outputs were empty. The test passed on Linux only because the
  probe worked there, and on macOS only when the machine was fast enough.
- **Fix:** each child is a pipeline opened for reading (`open |[list ...
  2>@1] r`); all four start before any is read, and each is read to its end
  and closed, which waits for the process. Nothing probes the process
  table, and nothing sleeps. The `unixFiles` constraint guarded only the
  probe and is gone, so the test now runs on Windows too.
- **A concurrent fix.** While this change was in progress, the per-thread
  runtime milestone's merge (905baee2) replaced the `/proc` probe on `main`
  with `ps -o stat= -p PID`, which macOS has. That wait works on Linux and
  macOS; it still polls, still reads after a fixed 200 ms (harmless once
  the wait holds) and still keeps the test off Windows. The merge of `main`
  into this change keeps the pipeline wait.

### 2.2 `pa-add-refusals`: a linker the test did not name

The test builds files that are not native libraries of linux-x86_64 and
checks that `native add` refuses each, saying what it is. The first is a
shared library of another architecture:

```tcl
exec clang --target=aarch64-linux-gnu -shared -fPIC -nostdlib -o libarm.so -Wl,-soname,libarm.so.1 f.c
```

- **What clang links with.** Without `-fuse-ld`, clang links an AArch64
  target with `aarch64-linux-gnu-ld` if that is installed, and otherwise with
  the host's `/usr/bin/ld` (clang's `-###` shows the choice). The host's GNU
  ld links only x86-64: `unrecognised emulation mode: aarch64linux`.
- **Why it passed where it was written.** PM-3's report records the file
  passing 30 of 30 "with clang, lld, MinGW-w64 and git present". That
  container also had the AArch64 GNU cross toolchain, which
  `tests/package-workloads.test` needs, and so the cross linker. The test's
  constraints, `linuxCc clang`, name neither.
- **Where it failed.** Every Linux x86-64 job of `tests.yml` that runs the
  file (the Ubuntu runners install no cross binutils: `.devcontainer/setup.sh`),
  from PM-3's arrival on `main` on (section 2.5).
  STATIC-COMPILE-EXPECTED-DIAGNOSTICS-MILESTONE-1.md,
  WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md,
  SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md and
  CSV-EMISSION-VALIDATION-MILESTONE-1.md each record it, correctly, as
  main's failure and the container's.
- **Fix:** the link names LLVM's linker, `-fuse-ld=lld`, which links every
  target and which `tests/package-native.test` already uses for the same
  purpose; the test carries a new `lld` constraint (`ld.lld` on PATH), so a
  host without it skips the test instead of failing it. The Ubuntu runners
  have lld (`pn-bundled-checks` links with it and passes there).
  Installing cross binutils on the runners would also have worked, but it
  would make the test depend on a package nobody declares; a constraint
  states the dependency where the test is.

### 2.3 `pa-pack-refuses-incomplete`: a word in a path

Among its checks, the test packs a pure-Botlish package and asserts that the
output mentions no native audit:

```tcl
[regexp {audit|native} [dict get $p out]]   ;# expected 0
```

`pack`'s output names the artifact it wrote:

```
packed purely 1.0.0: /tmp/native-coverage_CSzCHf/tmp/pa-9976-repo-3/purely-1.0.0.botpkg
```

`tests/native-coverage.tcl` runs the suite with its temporary directory
under `file tempdir native-coverage`, so in the two coverage jobs the path
itself matches `native`. Everywhere else (the suite jobs' temporary
directory is the checkout) it does not, which is why the test failed only
there, and why `native-coverage.tcl` classed it "failed (native backend
bugs)" although no native code was involved. Reproduced here with a
temporary directory named like the coverage jobs'.

**Fix:** the assertion reads the output with the repository path replaced
(`string map [list $repo REPO]`). The property it states -- a pure package
is packed without an audit or native output -- is unchanged.

### 2.4 Eleven mutants that no longer apply

Each audit's mutation harness reads a catalog of deliberate bugs, exact text
replacements whose replaced text must occur exactly once. A mutant whose
text no longer does is reported NOT-APPLIED -- by its harness, when it runs.
No CI job runs the mutation harnesses (each takes from minutes to hours),
and each milestone runs the harnesses of its own area. So a change that
rewrites or duplicates text another audit's mutant replaces breaks that
mutant silently, and the rule the mutant guarded goes unguarded until
somebody runs that harness.

Checking every catalog under `audit/` (84 catalogs, 2,968 mutants; section
6.1) against `main` found eleven such mutants. The one already known,
`struct-ignores-non-hashable-field`, is one of them:

| Catalog | Mutant | What broke it | Commit (date) | Killed now by |
|---|---|---|---|---|
| hashable | `struct-ignores-non-hashable-field` | `SendComponents` (SendClass's loop) copies `Components`' `if {$class eq "none"}` block: the text occurs twice | 8b0a692, sendability (11-03) | 5 tests of hashable.test (`hb-hash-static-rejection`, ...); the fuzzer, 4 of 8 programs |
| mutable-map | `set-value-storage` | a `sendable through(...)` clause now follows MutableSet's field | 8b0a692, sendability (11-03) | `ms-no-value-storage` |
| direct-modules | `method-obligation-dropped` | `ObligationKinds` gained `CONTEXT-NOT-INJECTED CONTEXT-RETAINED-AUTHORITY` | 9f9cc95, restricted injection (11-02) | `dm-method-sugar-two-candidates` |
| method-receiver-types | `context-obligation-selects`, `error-obligation-selects` | the same line | 9f9cc95 (11-02) | `mrt-context-obligation-never-selects`, `mrt-error-obligation-never-selects` |
| method-resolution | `ambiguous-context-is-a-problem`, `missing-context-is-a-problem` | the same line | 9f9cc95 (11-02) | method-resolution.test (`mr-sfiae-competing-candidates`, `mr-diag-obligations-of-the-placeholder`, ...) |
| enums | `bare-case-accepted` | the emission-claims resolver added a second `set b [Lookup hir $scope $name]` | 46ff149, emission claims (11-02) | `enum-cases-not-injected`; the fuzzer, 10 of 25 programs |
| hir-interchange | `decode-skips-activation` | `decode` now re-verifies emission claims between `hir::activate` and `return` | 46ff149 (11-02) | `hx-roundtrip-in-process` |
| c-ffi | `link-failure-removes-earlier` | `emit_object(program)` became `emit_executable_object(program, startup)` | ccc51dd, main-thread startup (10-29; on `main` 10-30) | `cf-link-failure-keeps-executable` |
| native-link-plan | `system-loses-static` | `system_link_args` gained `startup` | ccc51dd (10-29; on `main` 10-30) | `nlp-linkers-agree` |

Three properties of the list:

- **Four milestones in six days, none of them the owner.** Each change was
  correct; each touched code that another area's audit mutates. The
  per-thread runtime milestone, merged during this change, did update the
  other harnesses' mutants of the code it changed (its commit c2a30bcc);
  with `tools/mutant-catalogs.tcl` that step stops depending on knowing
  which harnesses to run. The
  restricted-injection milestone updated its own mutant of
  `ObligationKinds` (`obligation-selects`) and broke the five others that
  edit the same line.
- **Two ways to break a mutant.** Seven rewrote the text (a parameter, a
  list member, a clause). Two duplicated it: new code mirroring existing
  code (`SendComponents` is `Components` for another class; the emission
  claims resolve a name the way a reference does), which makes a correct
  mutant ambiguous without touching its target.
- **Running one's own harness finds this; nothing finds the others.** The
  main-thread startup milestone ran `audit/native-aot` and
  `audit/native-stack`, found three stale native-aot mutants (two broken by
  earlier milestones) and rewrote them (MAIN-THREAD-STARTUP-MILESTONE-1.md).
  The same change broke `audit/c-ffi`'s and `audit/native-link-plan`'s
  mutants of the code it edited, whose harnesses it had no reason to run;
  they stayed broken for a week.

Two edits in the catalogs name a file no commit holds: the macOS Icy Tower
mutants `binding-scalar-type` and `binding-scalar-type-traced` edit the SDL3
binding the macOS job generates and stages (`@binding/`). They are outside
any tree check by design.

### 2.5 When each appeared, and how often it failed

From every run of `main`'s `tests.yml`, `macos-arm64.yml`,
`windows-x86_64.yml` and `tests-arm64.yml` completed from 2026-11-01 to
bdd5e3d (the runs of later commits were still queued):

| Test | First failing run | Runs and outcome since |
|---|---|---|
| `pn-concurrent-target-compiles` | 41787767392 (bdd5e3d, 11-04), system linker job; its acceptance shard passed the same file | macOS: the file ran in 26 jobs from PM-2's merge (1ed72b5, 11-02) on, and failed in that one: **intermittent**. Linux arm64: passed in every job (the `/proc` wait works there). Windows: skipped (`unixFiles`) |
| `pa-add-refusals` | 41682255326 (9bcdf6f, PM-3's merge into `main`, pushed 11-03 17:14; its jobs ran 11-04 01:47 to 05:22) | `tests.yml`: failed in all six runs since, in every job that runs the file (interp, compile, system-linked, both GC-stress passes, both coverage jobs): **deterministic**, the same linker error each time. Linux arm64, macOS, Windows: skipped (`linuxX86Host`) |
| `pa-pack-refuses-incomplete` | the same run | classed "failed" in 12 of 12 coverage jobs, passed in every other job: **deterministic**, in the coverage jobs only |

Before 9bcdf6f every `tests.yml` run on `main` from 11-01 (23 runs) passed.
From 9bcdf6f to bdd5e3d these two tests were the only failures: the same
6 of 14 jobs red in each run, every other job green. Three of the four
reports that record `pa-add-refusals` (section 4) were written, from their
own containers' runs, before `main`'s first run of it had started: the
runners were saturated, and the push's jobs waited eight and a half hours.

## 3. What the defects have in common

Each defect's outcome depended on something the test or the mutant did not
state, and that the check run when it was written did not vary:

| Defect | What it depended on | Varied by |
|---|---|---|
| `pn-concurrent-target-compiles` | the host's process table (`/proc`), the machine's speed | the host (macOS) |
| `pa-add-refusals` | a package the author's container had (AArch64 binutils) | the runner's image |
| `pa-pack-refuses-incomplete` | the name of the temporary directory | the job (native coverage) |
| eleven mutants | the exact text of code another area owns | later milestones |

In every case the author's own run was the one run in which the assumption
held: the author's Linux host, the author's toolchain, the author's
temporary directory, the code as it stood when the mutant was written. A
check that runs only where its assumption holds cannot report the
assumption. That is the class: **tests whose correctness depends on an
unstated property of their environment, validated only in the environment
where the property holds.** MAIN-CI-FAILURES-2026-11.md's section 3.1 (a
default target, a glob rule, POSIX lock liveness, a system Python's library
version) is the same class; the mutants are its form for test artifacts
that depend on the code rather than on the host.

## 4. Why they got through, and why they stayed

**The validation environment was the author's.**

- PM-2 and PM-3 were validated in Linux x86-64 containers with more tools
  than CI installs. Neither report claims macOS or the Ubuntu runner for
  these files; each records what it ran.
- `tests.yml` runs a branch only when dispatched. PM-3's report records its
  branch's macOS and Windows runs, not a `tests.yml` run; its post-merge
  follow-up (a9b29ba) fixed the one failure `main`'s Windows run showed.
- The native coverage jobs are the only place whose temporary directory
  holds the word `native`, and they run only in `tests.yml`.

**A mutant's validity is checked only by its own harness.** AGENTS.md says,
for every area, "every mutant in its `mutants.txt` must still apply and be
killed" -- for the harnesses the changed area's section names. A milestone
that edits `hir/methods.tcl` for injection runs the restricted-injection
mutants, and has no reason to run method-resolution's. Nothing ran the
others' catalogs, and the harnesses' NOT-APPLIED status reaches no one who
did not run them.

**Red on `main` was recorded instead of fixed.** `pa-add-refusals` failed on
every Linux x86-64 `tests.yml` run of `main` from PM-3 on (section 2.5).
Four milestone reports, written between 11-03 20:32 and 11-05 05:46, list
it as main's own failure, with its cause, and merge. Each was right by
AGENTS.md's rule (since MAIN-CI-FAILURES-2026-11.md): "tell the user which
workflows and tests fail on `main` before you build on it, and keep that
list". The rule asks for a report; it does not ask anyone to fix the
failure. A one-line fix was documented four times.

**A permanently failing test hides itself and others.**

- While `pa-add-refusals` failed on every Linux job, any new failure in
  `package-authoring.test` would have been a second line under "Files with
  failing tests: package-authoring.test", the file already listed.
- `pa-pack-refuses-incomplete` was exactly that, in the coverage jobs, and
  every report that mentions it does so as part of the known failure.
- `audit/package-manager/tools/mutate.tcl` kills a mutant when any test of
  its detector files fails, and runs no unmutated baseline first. Where
  `pa-add-refusals` fails regardless (the runners; this container before
  the fix), every one of the 30 mutants that `package-authoring.test`
  detects is reported killed whatever it does. 15 of the 84 harnesses run
  their detectors on the unmutated tree first and refuse a failing
  baseline (actor, direct-modules, native-aot, restricted-injection,
  value-transfer and the 2048 and Icy Tower workloads' among them); the
  package manager's is not one of them.

## 5. What this change does, and how it was checked

| Item | Change | Checked here (Linux x86-64) |
|---|---|---|
| `pn-concurrent-target-compiles` | pipelines closed to wait; `unixFiles` dropped | passes 4 of 4 runs; the old wait, with `/proc` renamed and 20 ms, fails with four empty outputs |
| `pa-add-refusals` | `-fuse-ld=lld`; `lld` constraint | fails before (`unrecognised emulation mode: aarch64linux`), passes after |
| `pn-bundled-checks` | `lld` constraint | passes |
| `pa-pack-refuses-incomplete` | the repository path mapped out of the output | fails before, passes after, in a temporary directory named like the coverage jobs' |
| both files | | `tests/local.tcl tests/package-native.test tests/package-authoring.test`: 67 passed on interp and on compile (2 skipped each: MinGW-w64); package-authoring.test also on cranelift-generic |
| eleven mutants | each updated to the code it mutates, removing or changing exactly what it did before | `tools/mutant-catalogs.tcl`: every mutant applies (84 catalogs at 17b0e66; 85 and 2,988 mutants after merging `main`'s per-thread runtime milestone); each of the eleven run through its own harness (`-only NAME`) and killed: table of 2.4 |
| `tools/mutant-catalogs.tcl` | new: every mutant of every catalog applied in memory | 2.6 s; against `main`'s tree it reports exactly the eleven |
| `tests.yml` | new job `mutant-catalogs` | YAML validated; CI decides |
| AGENTS.md | "Tests that hold on every host, and mutants that still apply" | -- |
| audit/emission-claims/census/mistakes.txt | its format line `@@ NAME FILE EXPECT DESCRIPTION` is now a comment, as in the other censuses | its census skipped it already (no block); the case list is unchanged |

Not run here: macOS and Windows, where `pn-concurrent-target-compiles` now
runs (the workflows run on the branch push: section 7).

## 6. Mitigation of the class

### 6.1 Done here

**A check of every catalog on every push.** `tools/mutant-catalogs.tcl`
reads every catalog under `audit/` (a `.txt` file with a `<<<<` line) and
applies each mutant's blocks, in order, to an in-memory copy of the files
they name: the harnesses' own rule (once, or every occurrence for `<<<<
all`), with no compilation and no test run. It knows the three catalog forms
(`## FILE` lines; a census's `@@ NAME FILE`; the DFA mistakes' one file) and
the catalogs whose files are not relative to the repository root, in one
table; a new catalog of another form fails the check until it is listed,
never passes unread. It takes under three seconds, so `tests.yml` runs it as
its own job on every push to `main` and every dispatch. The break of section
2.4 then fails the push that causes it, naming the mutant, the file and the
first line of the text, instead of waiting for a harness someone else runs.

**Rules for the tests themselves** (AGENTS.md, "Tests that hold on every
host, and mutants that still apply"): wait for a child by closing its
pipeline; name every tool a test runs in its constraint, and link another
architecture with lld; never match a word against output that holds a host
path. They are the three defects of section 2, stated as the rule each
broke.

### 6.2 Recommended

Ordered by what each would have caught here.

1. **Fix a test defect on `main` instead of recording it.** AGENTS.md's
   branching rule asks a session to list main's failures and compare its
   own with them. It could also say: a failure on `main` that is a test's
   (not the product's) and has a known cause is fixed in the next session
   that finds it, in its own commit, before that session's milestone
   merges. `pa-add-refusals` would have been red for one run instead of
   every run for two days. This is MAIN-CI-FAILURES-2026-11.md's
   mitigation 2 ("stop the line"), narrowed to the cheap case.
2. **Vary the environment the author's run does not.** Each defect would
   have failed in the author's own run under one changed variable:
   - **a temporary directory with an adversarial name**: `tests/local.tcl`
     could name its private `-tmpdir`s with words tests are likely to grep
     for (`native-error-audit-...`) and a space, which also catches
     unquoted paths;
   - **the reference image**: a milestone's last local run in a container
     provisioned by `.devcontainer/setup.sh` alone (the runners' image),
     not the development container with every cross toolchain installed;
   - **a host relabeled**: MAIN-CI-FAILURES-2026-11.md's mitigation 3 (an
     environment override of the host-answering functions) generalizes to
     `/proc`: a test-only switch under which `file isdirectory /proc/...`
     is false would have shown 2.1 on Linux.
3. **A baseline before mutants.** A harness that runs its detectors on the
   unmutated tree first, and refuses to report kills when the baseline
   fails, cannot count a broken test as 30 killed mutants. 15 of 84
   harnesses do; the others need a few lines each, or one shared
   procedure where they already share tooling (`audit/golden/tools/tree.tcl`
   serves several).
4. **Capability probes, not presence checks.** `lld` on PATH is a presence
   check; the dependency is "clang can link an AArch64 shared library". A
   constraint that links a one-line library at constraint time (a few tens
   of milliseconds) states the dependency exactly and survives a clang
   without lld support or a broken install. The same holds for `cc`, MinGW
   and the macOS tools in these files.
5. **Mutants that anchor on what is unique.** Two of the eleven broke by
   duplication. A mutant whose replaced text includes the line that names
   its procedure, or a neighbouring statement only its target has, survives
   a mirror of its code; the repaired hashable and enums mutants do that
   now. The catalog check reports the break either way; the anchor makes it
   rarer.

## 7. Left open

- **macOS and Windows** run `pn-concurrent-target-compiles` with the new
  wait for the first time on this change's branch push; Windows had never
  run it (the old `unixFiles` constraint). Their results are CI's. A pass
  on macOS shows little by itself: the old wait failed there once in 26
  runs.
- **The package-manager harness's kills** were not re-run here: section 4's
  point about its missing baseline concerns hosts where
  `pa-add-refusals` failed, which this change ends.
- **Mitigations 6.2** are recommendations; none is implemented.
