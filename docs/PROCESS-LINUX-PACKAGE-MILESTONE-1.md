# PROCESS-LINUX-PACKAGE-MILESTONE-1.md

The official package `process_linux` 0.1.0: launching, supervising, talking
to and terminating external processes from a Botlish program on Linux
x86-64, scheduled by the program's own event loop. A completion report.

The package is `../packages/process_linux` (its `README.md` and `GUIDE.md`
are the user's documentation); it grew from the census
MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md, whose experiment
(`../audit/managed-subprocess/`) stays as it was. The evidence is
`../audit/process-linux/` (fuzzer, mutants, clean room, results),
`../tests/process-linux.test` with `../tests/process/`, and
`../bench/process-linux.tcl`.

Contents: 1. Outcome -- 2. Implementation census -- 3. The public API --
4. Spawning and the native boundary -- 5. Event-loop integration --
6. Streams and backpressure -- 7. Cancellation, termination, reaping --
8. Authority and threads -- 9. The release -- 10. The clean room --
11. Tests, fuzzing, mutation -- 12. Measurements -- 13. Limitations --
14. Findings -- 15. Commands -- 16. Consequences for the agent TUI --
17. Answers.

## 1. Outcome

* **A published, reproducible package.** `process_linux-0.1.0.botpkg`,
  sha256 `c2a04db5df8a1b0326d5a606f50ec5dd89e873d1bb9239aab8856d932ad5f579`
  (50,322 bytes, 7 files), built twice in two fresh containers of the
  pinned author image, byte-identical with identical provenance records,
  recorded in `../packages/RELEASES.tsv`. It locks `event_loop_linux` 0.5.0,
  whose recorded release the same builds reproduced (`ecd9e811...`).
* **A small public API** (section 3): a `Command` value built without a
  shell, `spawn` returning an affine owner and an identity, byte streams
  (`read`, `write`, `close_stdin`, `close_output`), `wait`, `wait_until`,
  `exited?`, `status`, `interrupt`, `terminate`, `kill`, `send_signal`,
  `release` (the owner's cleanup), `finish`, `detach`, `shutdown`, `stats`;
  seven declared errors with payloads.
* **No language, compiler, runtime or standard-library change, and no
  second scheduler.** Every pipe and every child's exit (its pidfd) is a
  readiness watch of `event_loop_linux`; nothing polls, no thread, no
  signal handler.
* **The census's mechanism kept, its experimental shortcuts fixed**
  (section 2): a spec leak on every invalid command, a quadratic copy for
  partial writes, linear lookups, `pthread_t` as an owner identity that a
  later thread can reuse, no backstop when a VM ends with children, an
  `Exec` stage reported for a pidfd failure, and more.
* **Evidence.** 53 tests pass (the census's 42 scenarios ported and
  extended, the tty ones under a PTY, two VMs, GC stress, the documented
  programs, the adapter's own C test of 34 checks); 90 model-based fuzz
  sequences match an independent lifecycle model (10 under GC stress);
  29 mutants, every one killed by behavior (after fixing three weak kills
  and one weak detector the first run exposed); a clean room of 42 checks
  passes with only the single-file compiler and the published artifacts.

## 2. Implementation census

How each part of the experiment became the package (retained, refactored,
test-only, dropped):

| Experiment (audit/managed-subprocess) | Package | Why |
|---|---|---|
| `msp.c` spec builder (`msp_spec_*`), process-wide table of 64 | retained (`pl_spec_*`), specs owned by their thread, freed at the thread's end | correct; 64 in flight is ample since a spec lives only during `spawn` |
| a failed `spec_check` left the spec allocated | **fixed**: the module frees it on every path (`m-spec-leak` kills the regression) | after 64 invalid commands nothing could be spawned |
| one `-EINVAL` for every bad item | distinct codes (NUL, empty, `=`, NUL in a value) -> `InvalidCommand {item, reason}` | the brief: invalid specs apart from launch failures |
| `posix_spawn` + `pidfd_open`, parent-side cwd/file/pipe stages, `closefrom(3)`, default dispositions, empty mask | retained | demonstrated correct; `pidfd_spawn` stays a testing-build negative control |
| pidfd failure reported as `Exec`, child killed by PID only | **fixed**: `Stage::Pidfd`, the group killed too (unreaped: safe) | misleading stage; a child that forked before the kill escaped |
| pipe ends possibly numbered 0..2 (closed std streams) | **fixed**: lifted to >= 3 before the child's `dup2`s | a `dup2` could overwrite another |
| `pidfd_getpid`, `pidfd_send_signal` from glibc 2.39 | syscalls and the PID `posix_spawn` returns | keeps the requirement at glibc 2.34 |
| `msp_write` of a sliced copy per partial write | **refactored**: `pl_write(h, data, n, offset)`, the whole buffer borrowed | a 64 MiB write took 1,024 partial writes, each copying the rest: quadratic |
| fixed table of 1,024 children, linear scan at spawn | retained, documented (section 13) | the scan is microseconds beside a 0.25 ms spawn |
| module's linear `slot_of` scan per operation | **refactored**: direct index (`pl_index`: the handle's low 16 bits) | O(1) per read; the census noted "a handful of children" |
| owner = `pthread_t` | **refactored**: a per-thread token | a later thread can get an exited thread's `pthread_t` and reach its children |
| nothing when a thread ended with children | **added**: a key destructor kills and reaps them; `atexit` signals what an `exit()` cut short | no child outlives its VM unless detached |
| `msp_sweep()` for detached children, called by hand | **refactored**: a task per detached child reaps it on its exit watch (no keep-alive); the adapter sweeps orphaned ones at spawn | no zombie while the loop runs; a detached child never holds the loop open |
| yield per chunk written in the *scenario* | **moved into the package** (`fair`: every `burst` chunks) | the brief: fairness is the library's |
| re-arm the pidfd watch on exit | retained | multiple waiters (`m-exit-broadcast`) |
| alarm task posting into the exit registration | retained | no deadline wait exists in `std::event_loop` yet (section 5) |
| reaper: one task per dying child | retained; restarted if the loop's shutdown revoked its channel; falls back to a synchronous kill-and-reap when the loop can no longer deliver an exit | a dying child must never wait for a reaper that is gone |
| `terminate` signalled only a running leader | **refined**: the group gets SIGTERM, and once the leader has exited, members still running are killed (the final group kill, section 7) | the census left a descendant running after a normal exit |
| identity valid until the reaper retired the child | **fixed**: stale at the release; suspended operations woken (`StaleChild`) | the census's own hazard note |
| `close_stdin` returned the C call's integer | **fixed**: `unit` | found by the clean room's warning-clean build |
| subreaper, orphans, proc state, start time, byte search, ages | **dropped** (a coordinator's, or `pl_t_*` test probes) | not a library's facilities (section 7) |
| `MSP_*` flags reachable from the module | **test-only**: `PL_TESTING` archive, `pl_t_faults` | production reads no environment variable and has no fault switch |

## 3. The public API

    with context std::event_loop::create(64)
    with context event_loop_linux::create()
    with context event_loop_linux::native()
    with context process_linux::create()          # or create_with(Options {release_grace_us, burst})

*Commands* (`Command`, opaque): `command(executable, arguments)` (a path,
never searched; each argument exact bytes), `in_directory`, `with_env`,
`without_env`, `with_clear_env`, `with_stdin(Input::Pipe|Null|Inherit)`,
`with_stdin_file(path)`, `with_stdout`/`with_stderr(Output::Pipe|Null|
Inherit)`, `with_stdout_file`/`with_stderr_file(path, FileMode::Truncate|
Append)`, `with_group(Group::Own|Shared)`.

*Children*: `spawn(command) -> Spawned {owner: ChildOwner, child: Child}`;
`read(child, Stream::Stdout|Stderr) -> Bytes` (at most 64 KiB; empty only at
end of file); `write(child, bytes)`; `close_stdin`; `close_output`;
`wait -> ExitStatus`; `wait_until(child, deadline) -> bool`; `exited?`;
`status` (StillRunning until it exited); `interrupt`;
`terminate(child, grace_us) -> ExitStatus`; `kill`; `send_signal(child,
Signal::...)`; `pid`; `release(owner)` (the cleanup); `finish(owner,
grace_us) -> ExitStatus`; `detach(owner) -> pid`; `shutdown()`; `stats()`;
`now_us()`.

*Outcomes*: `ExitStatus {ending: Exited|Signaled|Dumped, code}`,
`success?`, `status_text`. A nonzero exit is never an error.

*Errors*: `InvalidCommand {item, reason}`, `LaunchFailed {stage, code}`
(`Stage::WorkingDirectory|File|Pipe|Exec|Pidfd|Limit`, positive errno),
`Unsupported {reason, code}`, `StaleChild`, `StreamClosed {stream}`,
`Interrupted`, `StillRunning`, `ProcessFault {reason, code}`.

`command` is `nomethod`: `"/bin/ls".command([...])` reads badly, and
METHOD-ELIGIBLE would otherwise suggest it.

## 4. Spawning and the native boundary

* `posix_spawn` (glibc's CLONE_VM|CLONE_VFORK: safe in a multithreaded
  process; exec's errno reported) then `pidfd_open` of the still-unreaped
  child: its PID cannot name another process before the reap. glibc 2.39's
  `pidfd_spawn` leaks its pidfd when exec fails (the census's reproducer):
  never used; the testing build's fault 8 keeps it as the control
  (`process-linux-adapter`: three leaked descriptors).
* Everything that can fail before exec is opened in the parent: the
  working directory (`O_PATH|O_DIRECTORY`, `fchdir` in the child), files,
  `/dev/null`, pipes. The stage says where (`process-linux-launch`).
* The child gets every signal's default disposition and an empty mask: a
  Botlish process ignores SIGPIPE, and an ignored disposition survives exec
  (`process-linux-inherit`; the control keeps SIGPIPE ignored). Every
  descriptor above 2 is closed (`closefrom(3)`), which matters only for a
  descriptor some library opened without close-on-exec: the test opens one
  (`pl_t_plain_fd`) to make the guarantee observable (`c-closefrom`).
* **Kernel and C library.** Linux 5.4 (pidfd_open and pidfd readiness 5.3,
  `waitid(P_PIDFD)` 5.4), group signals through a pidfd 6.9 (before it,
  `kill(-pgid)` while the leader is unreaped: its PID, the group's ID,
  cannot be reused; `process-linux-old-kernel`), glibc 2.34
  (`posix_spawn_file_actions_addclosefrom_np`). `create` probes
  `pidfd_open(getpid())` and `waitid(P_PIDFD)` (ECHILD on a supported
  kernel, EINVAL before 5.4); `spawn` re-checks. A kernel without pidfds
  and a process whose SIGCHLD is ignored (`SIG_IGN` or `SA_NOCLDWAIT`:
  children reaped behind the supervisor's back, their PIDs reusable before
  the pidfd is open) are `Unsupported` with their reason, never handled by
  PID numbers (`process-linux-unsupported`).
* **The boundary.** 33 private externs of scalars and borrowed bytes; no
  callback, thread or signal handler. Handles are `GEN << 16 | INDEX`; a
  stale one is `-ESTALE`, another thread's `-EPERM` (`c-generation`,
  `c-owner-thread`). Partial launch failures close everything they opened
  (`process-linux-exhaust`: RLIMIT_NOFILE 128, failures at the pipe stage
  with EMFILE, nothing leaked).

## 5. Event-loop integration

* **One scheduler.** stdin is watched writable, stdout and stderr readable,
  the pidfd readable; each watch delivers to a keep-alive Coalesce source of
  capacity 1. A task reads until EAGAIN, then waits for readiness
  (re-arming the one-shot watch). Fixed interest is no obstacle: each
  descriptor has one direction.
* **Fairness.** Every `burst` chunks (default 4) a read or write that did
  not wait yields to the loop. The census's starvation was a few
  milliseconds because a 64 KiB pipe usually runs dry between chunks; the
  test makes it unmistakable with a child that enlarges its pipe to 1 MiB
  and stays ahead: with yielding a 10 ms ticker's worst lateness was 3.7 ms
  over a second of 2.4 GB/s, without it 168 ms (section 12). The first
  mutation run found the fairness test unable to kill the no-yield mutant
  for two reasons, both fixed: the pipe drained between chunks, and the
  ticker measured lateness from the *last* coalesced expiry, so a task
  starved for a second that woke once with 100 expirations looked punctual.
  Lateness is now measured from the first pending expiry.
* **Multiple waiters.** Exit is one readiness record: the waiter that
  observes it re-arms the level-triggered pidfd watch for the next
  (`process-linux-waiters`: three waiters).
* **Deadline waits.** `std::event_loop` still has no deadline wait: as in
  the census, `wait_until` adopts an alarm task that posts into the exit
  registration at the deadline and is revoked on an early return; every
  wake re-checks the state. The duplication that remains: every library
  writes this alarm; a `std::event_loop::wait_until(reg, deadline)` would
  remove ~20 lines here and in the next library.
* **Liveness.** Stream and exit sources keep the loop alive while a task
  waits on them; the reaper waits on a channel (keeps nothing alive); a
  dying child keeps the loop alive through its exit watch until reaped; a
  detached child's watch keeps nothing alive (`process-linux-detach-
  outlive`: the program ends in under 2.5 s although its detached child
  sleeps 3 s).

## 6. Streams and backpressure

`read` takes at most one chunk; nothing is accumulated. A child whose pipe
is full blocks in its own write (`process-linux-backpressure`: an 8 MiB
producer paused and resumed). Writes complete through partial writes from
an offset into the borrowed buffer (`process-linux-stdin-partial`: a single
4 MiB write and 100,000-byte writes, the echo compared byte for byte).
EOF is independent of exit (`eof-early`, `exit-unread`, `inherited`); bytes
are bytes (`binary`: every byte value, invalid UTF-8, a character split
across reads). Output policies are the reader's (`limit`: a 4,096-byte tail
and a 1 MiB limit that terminates; `persist`: files). No sink abstraction
and no line splitter were added: the byte stream is the foundation a later
JSON-lines decoder needs, and no part of this milestone needed one.

## 7. Cancellation, termination, reaping

* **Interrupt** bumps the child's interrupt generation and posts to its
  registrations: suspended reads, writes, waits, terminations and
  finishes fail `Interrupted`; the child runs on (`process-linux-cancel`).
* **Terminate** sends SIGTERM to the group, waits the grace on the loop's
  timer, sends SIGKILL if the leader still runs, waits for its exit (on the
  thread, bounded, if the loop can no longer deliver it), then sends
  SIGKILL to the group once more.
* **The final group kill (a decision).** When supervision ends (release,
  finish, terminate), members of the child's group still running once the
  leader exited are killed. They had the same SIGTERM as the leader and as
  long as it took; waiting the rest of the grace for them is impossible
  without polling (no pidfd for a descendant, and the unreaped leader keeps
  `kill(-pgid, 0)` answering). Without it, a released child's background
  descendant ran on -- an implicit detachment (`process-linux-descendants`:
  a descendant ignoring SIGTERM, left by a leader that exited normally, is
  gone after the release; `m-final-group-kill`).
* **Release** is the owner's cleanup: exited, the child is concluded now;
  running, it gets SIGTERM and is handed to the reaper; the call returns in
  microseconds (`process-linux-release`: under 10 ms; an abandoned
  coroutine's unwinding releases the same way, `process-linux-abandon`).
  The identity is stale at once and suspended operations wake with
  `StaleChild` (`process-linux-release-reader`).
* **Reaping.** A child is reaped only once its supervision is over; signals
  after the reap are refused (`c-signal-after-reap`); a group signal after
  the leader's exit, while unreaped, reaches its descendants (`reap-order`;
  the eager-reap control shows the descendant surviving).
* **Shutdown.** The loop's shutdown revokes everything: reads end
  `StreamClosed`, waits `Interrupted`, the reaper kills and reaps
  synchronously; `process_linux::shutdown()` does the same for what is
  left (`process-linux-shutdown`). **A thread's end** kills and reaps what
  it still supervises (`process-linux-thread-end`, the adapter test).
* **What is not contained**: a descendant that leaves the group (setsid)
  survives (`process-linux-descendants`: alive, then killed by the test);
  a child of the supervisor's group (`Group::Shared`) is signalled alone.
  No subreaper (process-wide: a coordinator's) and no cgroups.

## 8. Authority and threads

`Processes` is made from `event_loop_linux::Native` and only an entry
program installs it; spawn without it is MISSING-CONTEXT, the externs are
PRIVATE-ACCESS, a forged owner OPAQUE-CONSTRUCTION
(`process-linux-authority`). Two Botlish-owned threads, each with its own
loop, driver and context, supervise children concurrently, 40 concurrent
spawns each seeing only descriptors 0, 1 and 2, distinct thread tokens
(`process-linux-threads`); a `Child` is refused as a thread entry's
parameter (THREAD-ENTRY-SIGNATURE); the adapter refuses another thread's
call; each VM's epoll watches its own children, so exits wake the right VM
by construction. The shared table is guarded by one mutex, never held
across a blocking call; descriptors are close-on-exec, so a concurrent
spawn inherits nothing.

## 9. The release

`tools/package-repository.tcl`'s `author::process_linux` compiles
`native/process_linux.c` with `-O2 -Wall -Wextra -Werror -fPIC -pthread`
(the same flags as every test build, `tools/process-linux.tcl`'s
`archiveFlags`), without `PL_TESTING`, runs `native add` (facts read from
the archive), stages the project's MIT license as the notice, audits
(`complete`) and packs with an evidence file; the provenance record is
bound to the artifact's sha256. The object records only the source's
basename (no build path), so the build is path-independent.

    botlish-package-build: Dockerfile sha256 45f9c049946710ae6c392b62676a74cf519207e59437351071dc1eab18cbae0b,
      FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852,
      Ubuntu snapshot 20261101T000000Z
    process_linux-0.1.0.botpkg             c2a04db5df8a1b0326d5a606f50ec5dd89e873d1bb9239aab8856d932ad5f579 (two builds)
    process_linux-0.1.0.provenance.json    7bc834efb4ac688cb391b7d3f65945ebdb5311b756a073a2af762a3168373171 (two builds)
    event_loop_linux-0.5.0.botpkg          ecd9e8114fa5bc24c2d23a2068e96ec2932e9386ca0cdb79fc568b9662146f77 (the recorded release)

The metadata names one target, linux-x86_64: `botlish add process_linux
-target linux-aarch64` is `PM UNSUPPORTED` ("supports linux-x86_64, not
linux-aarch64 ... nothing is assumed portable"), shown in the clean room.
The released archive defines exactly the module's 33 `pl_*` functions, no
`pl_t_*`, references no `pidfd_spawn` and no `getenv`
(`process-linux-release-archive`). Consumers need `cc` and `libc6-dev` to
link; authors need the pinned image (or any gcc and ar).

## 10. The clean room

`../audit/process-linux/cleanroom/`: Ubuntu 24.04 with `gcc` and
`libc6-dev` only, no network, no Tcl, Python, Rust or Git, no checkout or
adapter source; the single-file compiler (15,495,546 bytes), the three
artifacts and a prebuilt helper child copied in. 42 checks passed
(`results/checks.txt`):

* `botlish add` of process_linux, event_loop_linux and `ticker` -- a
  library written apart, depending on the driver itself -- gives one graph
  with one shared driver (`application event_loop_linux process_linux
  ticker`, `package process_linux event_loop_linux`, `package ticker
  event_loop_linux`); `verify` and both provenance records check; an
  unsupported target is refused, nothing installed.
* The program builds warning-free (87 s, 1.76 MB), holds the released
  adapter once and no probe, links only the C library.
* The workload: A in one directory and B in another (its own environment),
  without a shell; A's stdout and stderr streamed concurrently, every byte;
  three lines written to A's stdin 100 ms apart and closed; ticker's task
  kept a 50 ms period within 40 ms; A exited 0; B, ignoring SIGTERM with a
  descendant in its group, escalated to SIGKILL at its 300 ms grace (signal
  9), its stream ending once the group died; exact arguments (empty,
  spaces, `$HOME`, `*.txt`, UTF-8) byte for byte; at the end nothing owned,
  dying, watched, unreaped or held, descriptors and registrations deltas 0;
  B and its descendant gone, checked from outside.
* The failures: a missing executable (exec, 2), a missing directory
  (working directory, 2), a non-executable file (exec, 13), an invalid
  environment name (refused before starting), a nonzero exit as an outcome,
  stale identities for wait and signal, an old identity never reaching the
  slot's new child.

## 11. Tests, fuzzing, mutation

* `tests/process-linux.test`: 53 tests, 5 minutes; each scenario under an
  external watchdog, the processes it named checked from outside (a zombie
  counts as dead: a container's PID 1 may not reap orphans). The census's
  42 scenarios map to: launch, invalid, basic, streams, naive, stdin,
  stdin-partial, backpressure, binary, eof-early, exit-unread, exit-first,
  persist, limit, inherit, tty-inherit, tty-read, tty-raw, stdin-closed,
  cancel, terminate, descendants, inherited, reap-order, eager-reap,
  release, abandon, shutdown, detach, detach-outlive, waiters,
  watch-release, exhaust, stale, many, threads; the census's subreaper
  scenario is dropped (no subreaper in a library), its slice is the clean
  room's workload, its perf scenarios are the benchmark. New:
  close-output, fairness, unsupported, pidfd-fail, old-kernel,
  shared-group, release-reader, finish, thread-end, child-not-sendable,
  authority, warning-clean, adapter (34 C checks), release-archive,
  metadata, docs (every program of README and GUIDE compiled under
  `-warnings error` and run), gc-stress (11 scenarios with a collection at
  every allocation).
* `audit/process-linux/tools/fuzz.tcl`: random sequences of spawn (five
  kinds of child), drain, write, close, wait, terminate, kill, interrupt,
  exited?, release, finish and detach, compared line by line with an
  independent model written from the documented lifecycle (state, owner,
  stdin, pending signals), plus the end counters and the processes left.
  The generator emits only what the model can know without timing. 90
  sequences (seeds 1-40 of 24 operations, 41-50 of 24 under GC stress,
  51-90 of 40 operations): 0 different (`results/fuzz.txt`: the last). The first run found one difference,
  in the model: a detached child that exits while the loop finishes is,
  by design, not waited for.
* `audit/process-linux/tools/mutate.tcl` with 29 mutants (the census's 15
  ported, 14 new): every one KILLED by the test its `%%` line names
  (`results/mutants.txt`). Two lessons of the first run: three C mutants
  were "killed" in a second because they left a variable unused and the
  `-Werror` build failed -- a weak kill, now rewritten to compile, and the
  harness reports a C build failure as NOT-BUILT; and `m-fair` survived
  (section 5). `tools/mutant-catalogs.tcl`: 101 catalogs, 0 problems.

## 12. Measurements

`bench/process-linux.tcl -runs 3 -census audit/managed-subprocess/slice`
(4-core container, means of three runs; the census column is its
experiment's lab-perf, run beside it):

| Measure | process_linux 0.1.0 | census experiment |
|---|---:|---:|
| spawn call, mean (us) | 247 | 243 |
| spawn call, max (us) | 2,734 | |
| exit notification, mean (us) | 168 | 165 |
| exit notification, max (us) | 3,021 | |
| spawn, read to end, wait, release (us) | 1,215 | 1,167 |
| 64 MiB of stdout (ms) | 35.0 | 32.6 |
| 64 MiB: supervisor CPU (ms) | 32.5 | 30.7 |
| 64 MiB: 5 ms ticker, worst lateness (ms) | 0.22 | 2.62 (*) |
| 64 MiB: peak RSS (MiB) | 12.6 | 12.6 |
| 1 GiB of stdout (ms); peak RSS (MiB) | 449; 12.6 | |
| no child at all: peak RSS (MiB) | 12.6 | |
| two idle children, 2 s: CPU (us); loop turns | 210; 3.7 | 162 |
| polling control (exited? every 1 ms): CPU (us); turns | 67,280; 1,810 | 60,440 |
| flood 1 s, 10 ms ticker: worst lateness (ms) | 3.7 (2.4 GB read) | 2.2 (*) |
| flood, yielding off (control): worst lateness (ms) | 168.5 | |
| terminate, graceful (child takes 150 ms) (ms) | 150.7 | |
| terminate, forced (300 ms grace) (ms) | 300.9 | |
| 400 sequential spawn-wait-release (ms) | 443 | |
| 64 concurrent children (ms) | 67.5 | |
| after completion: owned, watches, children, descriptors, registrations | 0, 0, 0, 0, 0 | |

(*) The census measured lateness from the last coalesced expiry (section
5), which understates starvation, and its flood scenario yielded by hand;
the package's figures use the stricter measure and the package's own
yielding. Everything else is within noise of the experiment: the
production changes cost nothing measurable. Memory is flat: 1 GiB streams
through the same 12.6 MiB as an idle program.

## 13. Limitations

* Linux x86-64 only (nothing is architecture-specific; AArch64 needs a
  build and its tests). No macOS, Windows or `std::process`.
* At most 1,024 unreaped children per process; four watches per piped
  child against the driver's 4,096 per loop (about 1,024 per VM); 64 specs
  in flight. A spawn scans the table linearly (microseconds).
* No PTY children, no line splitter or JSON-lines decoder, no subreaper,
  no cgroups, no durable supervision (a supervisor killed by SIGKILL or a
  native fault orphans its children: the thread-end and atexit backstops
  run only on an orderly end).
* The process must not reap children behind the package (`waitpid(-1)`,
  `waitid(P_ALL)`, SIGCHLD ignored): checked for SIGCHLD, documented for the
  rest.
* `std::environ` is read at spawn without a lock: a library that calls
  `setenv` concurrently on another thread would race (nothing in Botlish
  does).
* Untested by scenario: the driver refusing a watch at spawn (it needs
  4,096 watches; the cleanup path, `retire`, is reviewed and shared with
  release), a kernel before 5.4 (simulated by the testing build's faults),
  a real kernel before 6.9 (simulated: fault 64).

## 14. Findings

* **ONE-CHAR-STRING-LITERAL on argument vectors.** A one-character
  argument -- `"/"`, `"-"`, `"1"`, `"*"` -- is common in a command and
  draws the warning, which has no way out but a different argument: the
  README's example lists `/usr` instead of `/`, the guide runs `seq 100000`
  instead of `seq 1 100000`. A product question for the warning (it is
  context-blind by design: WARNINGS-ONE-CHAR-STRING-LITERAL.md).
* **METHOD-ELIGIBLE on `command`.** Answered by `nomethod fn command` (the
  author's declaration), as the warning's design intends.
* **No forward references, handlers only on a statement's call, no
  integer division or bit operations** (the handle's index comes from the
  adapter: `pl_index`), **no typed empty vector outside a declared field**:
  all known friction, met again; none blocked the package.
* **F3** (slow compiles with method-style calls when `std::linux::fs` is
  imported) was avoided by keeping the clean room's fs use in a module of
  qualified calls.
* **The clean room found a real API wart**: `close_stdin` returned the C
  call's integer instead of `unit` (a handler of `StaleChild` completing
  with unit was refused): fixed before the release.

## 15. Commands

    export LANG=C.utf8 LC_ALL=C.utf8
    tclsh9.0 tests/process-linux.test -tmpdir "$(mktemp -d)"
    tclsh9.0 audit/process-linux/tools/fuzz.tcl -seeds 1-50
    tclsh9.0 audit/process-linux/tools/fuzz.tcl -seeds 41-50 -gc-stress 1
    tclsh9.0 audit/process-linux/tools/mutate.tcl
    tclsh9.0 tools/mutant-catalogs.tcl
    tclsh9.0 bench/process-linux.tcl -runs 3 -census audit/managed-subprocess/slice
    tools/package-build/author.sh image
    tools/package-build/author.sh build OUT -release process_linux event_loop_linux
    bash single/build.sh
    audit/process-linux/cleanroom/cleanroom.sh image
    audit/process-linux/cleanroom/repository.sh REPO OUT
    audit/process-linux/cleanroom/cleanroom.sh run single/out/botlish REPO RESULTS

(`tools/process-linux.tcl app DIR -testing 1` installs a test application;
the census's baseline needs `python3 -I audit/managed-subprocess/tools/
run.py --build` first.)

## 16. Consequences for the agent TUI

An implementation agent is now an ordinary supervised child: `command(
"/usr/local/bin/claude", ["--print", "--output-format", "stream-json",
...]).in_directory(worktree).with_env(...)`, its stdout read chunk by chunk
by one task, its stderr by another, prompts written to its stdin, its exit
awaited, a user's cancel as `terminate(child, grace)` reaching the
harness's whole process group (its shells and MCP servers), and the owner
held by the job's task so that closing a job -- or the TUI -- terminates it.
All of it shares the loop with the HTTP client (`http`, the PM
conversations) and the terminal's input watch. What the TUI still needs:

1. **A JSON-lines splitter** over chunks (a byte search in
   `std::abi::bytes`, or a small decoder package): the stream is ready for
   it.
2. **Thin adapters** per harness (Codex, Claude Code, OpenCode): their
   argument vectors, environment and output schema -- ordinary Botlish over
   this package, nothing native.
3. **For jobs that outlive the TUI, the coordinator** (the census's M3): a
   separate process that is its jobs' subreaper (the flag is process-wide,
   so never set inside this library), redirects their output to files
   (`with_stdout_file`, here today), journals (PID, start time, boot id) and
   serves the TUI over a Unix-domain socket -- the remaining IPC gap.

## 17. Answers

**A. Can an independently authored Botlish program supervise an external
process safely without raw syscalls, native handles or a shell?** Yes
(observed: the clean room). It imports the package, installs the context,
and uses values: a `Command`, an owner, an identity, Bytes, statuses and
declared errors. No descriptor, pidfd, PID-based signal or shell reaches
it; the native functions are private.

**B. Does ordinary affine ownership suffice for scope-bound supervision,
including asynchronous cleanup?** Yes (observed: release, abandon, finish,
shutdown, thread-end). The owner is an ordinary resource; its cleanup
cannot wait, so it sends SIGTERM and hands the child to a reaper task,
which the loop keeps alive until the child is reaped. Two backstops cover
what no task can: the loop's shutdown (synchronous kill and reap) and the
VM's thread ending (the adapter's key destructor).

**C. Can independently authored HTTP and subprocess packages share the
same event loop without special coordination?** Yes, by construction and
observed for the subprocess side with a third-party library: both are
event_loop_linux sources of the one shared driver instance the package
manager installs; the clean room ran `ticker` (an independent package over
the driver) beside process_linux on one loop, and the graph resolved one
driver. `http` was not built here (its Rust unit and BoringSSL provider are
a separate build); it locks the same `event_loop_linux` 0.5.0, so a graph
of both resolves one instance, and nothing in either package coordinates
with the other.

**D. Do launch, byte streams and pidfd-based exit observation stay safe
under concurrent VMs?** Yes (observed: `process-linux-threads`, the adapter
test, the clean room's VM). Each VM watches its own children with its own
epoll; children belong to the spawning thread's token; concurrent spawns
inherit no other VM's pipe; another thread's call is refused; a thread's
end reaps its children.

**E. Which experimental limitations remain, and which were removed?**
Removed: the spec leak, the quadratic partial writes, linear lookups,
`pthread_t` owners, the missing thread-end backstop, the misreported pidfd
stage, ad hoc sweeping, scenario-level yielding, the identity's validity
after release, the leftover group members after a normal exit, the
glibc-2.39-only calls, reachable negative-control flags, and the module's
warnings. Remaining (documented): the fixed table of 1,024 children per
process with a linear scan at spawn, 64 specs in flight, the alarm-task
deadline wait (no `std::event_loop` deadline wait yet), Linux x86-64 only.

**F. What is the minimum additional work for a durable coordinator and thin
harness adapters?** For adapters: a JSON-lines splitter and per-harness
command and schema code -- no native code. For the coordinator: a
Unix-domain socket package (watched like any descriptor), a job journal
(std::linux::fs today), reattachment by `pidfd_open` plus start-time
verification (a small addition to a coordinator's own adapter, as the
census demonstrated), and the subreaper flag set in the coordinator's own
process.
