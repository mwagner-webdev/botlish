# MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md

Managed child processes, concurrent I/O, cancellation and supervision in
Botlish: a capability census and an executable clean-room experiment. Can a
Botlish program supervise long-running external programs -- coding-agent
harnesses such as Codex, Claude Code and OpenCode -- reliably, while its
event loop and an interactive terminal stay responsive?

A census, not an implementation milestone. No compiler, runtime,
standard-library or package behavior changed. The experiment's code is
`../audit/managed-subprocess/` (its README lists it): an experimental C
adapter, an experimental Botlish module over it, a deterministic helper
child, 42 scenarios, a vertical slice, a threads experiment, a
crash-recovery experiment, reproducers, measurements and 15 mutants.

Evidence labels, used throughout:

* **Observed** -- demonstrated by a program or test run here (Linux 6.18,
  glibc 2.39, x86-64, the native backend; the run's output is in
  `../audit/managed-subprocess/results/`).
* **Static** -- established by reading code or existing tests.
* **Inferred** -- follows from documented semantics, not exercised here.
* **Projected** -- a proposal, not demonstrated.

## Contents

1. Answer and recommendation
2. What exists today (inventory)
3. Capability and gap matrix
4. Process and stream ownership
5. Event-loop integration
6. Exit observation and process groups
7. Cancellation and termination
8. Durability and restart recovery
9. Terminals and PTYs
10. Threads and actors
11. Other platforms
12. The vertical slice, and the commands
13. Negative tests, fault injection, mutants, limitations
14. Measurements
15. A proposed public API
16. Milestones
17. Answers to the census's questions

## 1. Answer and recommendation

**Today a compiled Botlish program cannot start a process** (static): the
standard library has no spawn, wait, signal, process-group, environment or
terminal operation, and nothing in `packages/` adds one. The compiler's own
subprocesses (`exec` in `pm/tools.tcl`, the test harness, the linkers) are
its Tcl implementation's and reach no program. The raw syscall transport
can technically fork and exec (`repro/raw-fork.bot`, observed), but not
with arguments, an environment or a descriptor plan, and only by running
Botlish code in a forked copy of a multithreaded VM: no API can rest on it.

**The language, the event loop and the Linux driver are nevertheless
sufficient.** An experimental module (`slice/msp.bot`, 896 lines, a fifth
of them comments) over an experimental C adapter of 37 scalar functions
(`native/msp.c`, 963 lines) supervises children correctly on Linux, every
property observed by a scenario:

* launch without a shell, exact argument boundaries (empty, spaces,
  quotes, UTF-8, `$HOME`, `*`), an inherited environment with overrides and
  removals or an explicit one, a working directory; a launch failure
  distinct from a failed run and classified by stage (the spec, the
  working directory, a redirection file, a pipe, exec);
* stdout, stderr and stdin as non-blocking pipes whose readiness is the
  existing driver's ordinary descriptor watches, read and written by
  ordinary tasks concurrently, with backpressure in both directions and
  bytes kept as bytes (NUL, invalid UTF-8, a character split across reads);
* exit observed through the child's pidfd, watched like any descriptor --
  no second scheduler, no polling, no thread, no signal handler;
* cancellation of a suspended read, write or wait without touching the
  child; termination as SIGTERM to the child's process group, a grace
  period and SIGKILL, with no PID-reuse hazard (signals go through the
  pidfd, never a number);
* a scope-bound owner whose release terminates a running child
  asynchronously (a cleanup cannot wait, so a reaper task does), explicit
  detachment as the only way to outlive the owner, stale handles refused
  after slot reuse, no zombie or descriptor left after 400 sequential and
  64 concurrent children, no registration left after the vertical slice;
* independent VMs on Botlish-owned threads supervising their own children,
  a child's identity refused across VMs at compile time.

**Recommendation.** Deliver subprocess supervision as a **Linux platform
package first** (`process_linux`, beside `event_loop_linux`, with its own
native adapter, as `http` has), not in `std`: the native code needs an
archive, and the standard library cannot carry one
(HTTP-SHIPPING-CENSUS.md). Grow the **portable surface** -- the spec, the
exit status, the errors, the owner/identity pair, the stream operations --
into `std::process` only when a second platform's driver exists (macOS has
no event-loop driver, Windows none either), so that the portable API is
proven by two implementations rather than designed from one. **No language
change is needed.** Three small, general facilities would remove the
experiment's workarounds (section 16, M0): a wait on a registration with a
deadline (or on several), a way to read the process environment, and a
byte search in `std::abi::bytes`.

**Durable jobs need a separate coordinator process.** Pipes die with their
reader, exit statuses go only to an ancestor, and a PID alone is no
identity (section 8, observed): implementation jobs that survive the TUI
need a coordinator that is their subreaper, writes their output to files,
keeps job records of (PID, start time, boot id), and serves the TUI as a
client. Botlish can write that coordinator with the package above; the one
missing piece is local IPC (Unix-domain sockets), a package-level gap.

## 2. What exists today (inventory)

All static unless marked.

| Area | What exists | What does not |
|---|---|---|
| Process creation | nothing in `std` or `packages/` | spawn, exec, wait, kill, process groups |
| Raw syscalls | `std::linux` (read, write, openat, close, getdents64, mkdirat, unlinkat); the transports reach any syscall from a direct module (fork/execve/wait4 observed: `repro/raw-fork.bot`) | argv/envp arrays, a safe post-fork path |
| C FFI | `extern c fn`, byte borrowing for one call (`read noescape`, `write noescape`; byte-sized pointees), layouts, native views and edits | a pointer array to several borrowed storages, native allocation (`repro/posix-spawn-ffi.bot`, observed) |
| Event loop | tasks, timers, sources, channels, delivery policies, owned registrations, revocation, stop, shutdown, abandon | waiting on several registrations at once, or on one with a deadline; `now()` is the turn's clock (HTTP F6) |
| Linux driver | epoll; one-shot readiness watches of any descriptor (readable/writable, hang-up and error bits, 4096 per loop); endpoints for foreign posts; pumps; `cpu_us` | changing a watch's interest (HTTP B5) |
| Resources | `opaque resource struct` + `cleanup fn` at the owner's lexical scope's end, on every exit, on coroutine abandonment | a cleanup that waits (it may not yield: `repro/cleanup-cannot-wait.bot`, observed) |
| Threads, actors | a VM per thread, typed transfers, `std::actor::remote` across threads | cross-process IPC |
| Files | `std::linux::fs`: paths, open, read, write, entries | the descriptor of a `File` (opaque: it cannot be a child's stdout) |
| Standard I/O | `std::linux::io`: stdin, stdout, stderr | termios, raw mode, isatty |
| Process facts | `argv()` | the environment (no getenv), the PID, signals |
| Signals | the runtime ignores SIGPIPE at startup (`runtime::aot::rust_process_setup`; Rust's own startup elsewhere) and guards SIGSEGV/SIGBUS for stack overflow | any other disposition; no SIGCHLD handler |
| Bytes | length, slice, join, UTF-8/UTF-16 codecs | indexing or searching (on purpose: ABI-BYTES.md) |
| Arithmetic | Int | integer division (HTTP B9) |
| The TUI package | -- | not in this repository: its input model could not be inspected (section 9) |

Two facts of the runtime matter for every child (observed): **a Botlish
process ignores SIGPIPE, and ignored dispositions survive exec** -- a child
started without resetting them ignores SIGPIPE too (the `inherit`
scenario's negative control: `sigpipe ign`), so a pipeline like
`child | head` behaves differently under a Botlish supervisor. And **every
descriptor the runtime and the driver open is close-on-exec**: with
`closefrom(3)` turned off, the child still sees only `0 1 2`.

## 3. Capability and gap matrix

"Experiment" says what the experimental module does; the gap column says
what kind of work a product needs (P: a platform package's native adapter,
S: a small standard-library or driver addition, L: a language change).

| Capability | Today | Experiment | Label | Gap |
|---|---|---|---|---|
| Launch without a shell | none | posix_spawn, explicit path; a shell only as an explicit executable | observed (`basic`, `launch`) | P |
| Exact argument vector | none | one exact byte string per argument; a NUL refused at the spec | observed | P |
| Environment | no read at all | inherited with overrides/removals, or explicit | observed | P; reading it: S |
| Working directory | none | opened in the parent (`O_PATH|O_DIRECTORY`), fchdir in the child: a failure is the cwd's, not exec's | observed | P |
| Launch failure vs exit | -- | `LaunchFailed{stage, code}` vs `ExitStatus{Exited/Signaled/Dumped, code}` | observed | P |
| stdin incremental, closable | none | non-blocking writes, the task waits for room, close at any time; EPIPE as `StreamClosed` | observed (`stdin`, `stdin-closed`) | P |
| stdout/stderr concurrently, as bytes | none | two tasks, 64 KiB chunks, no buffering in the supervisor | observed (`streams`, `binary`) | P |
| Non-blocking I/O in the loop | driver watches (any fd) | pipes and the pidfd as watches; one direction per descriptor, so fixed interest is no obstacle | observed | none |
| Cancelling a read/wait | -- | `interrupt`: an interrupt generation and a posted record | observed (`cancel`, `naive`) | P |
| Graceful stop, escalation | -- | SIGTERM to the group, grace, SIGKILL, through the pidfd | observed (`terminate`) | P |
| Process tree | -- | own process group by default; escapees (setsid) need a subreaper or cgroups | observed (`descendants`, `subreaper`) | P (cgroups: inferred) |
| Scope exit | resources exist | release terminates asynchronously; `finish` waits; `detach` consumes the owner | observed (`release`, `abandon`, `shutdown`, `detach`) | P |
| Other VMs | per-VM runtime | per-VM children; `Child` not sendable; adapter refuses another thread | observed (`threads`, `repro-send-child`, `msp-test`) | none |
| Portability | Linux syscalls, Darwin and Windows IO | Linux only | static | P per platform + driver packages |
| Waiting on two things | one registration per wait | a helper task posts into the waited registration at the deadline | observed | S (a deadline wait) |
| Line splitting of output | no byte search | an adapter `memchr` | observed (`binary`) | S |
| PTY children | none | not built | inferred (section 9) | P |
| Durable supervision | -- | job records with start times; reattach through a pidfd | observed (`recovery.py`) | P + a coordinator; IPC: P |

## 4. Process and stream ownership

**Four lifetimes, kept apart** (observed):

| Lifetime | Bounded by | In the experiment |
|---|---|---|
| The Botlish owner (`ChildOwner`) | its lexical scope, or an explicit `release`/`finish`/`detach` | an affine resource; moved like any |
| The identity (`Child`) | its slot's generation | an ordinary value; after release `StaleChild` (also once the slot is reused: `stale`, `msp-test`) |
| The operating-system process | its exit and its reaping | reaped only once the supervision is over (section 6) |
| The streams | their own end of file and close | EOF is not exit (`eof-early`, `inherited`); a descendant can hold them open |
| The observing tasks and registrations | the child's retirement | registrations revoked, watches removed, descriptors closed only after the reap |

What each event does, as the module behaves:

| Event | Behavior | Evidence |
|---|---|---|
| Normal scope exit / `release` | exited: reap and retire now; running: SIGTERM to its group, handed to the reaper (grace, SIGKILL, reap, retire); returns in microseconds (24 µs) | `release`: graceful one gone, ignoring one escalated |
| Explicit wait | `wait`/`wait_until` on the pidfd watch; several waiters each woken | `two-waiters` |
| Explicit termination | `terminate(child, grace)` returns the status | `terminate` |
| Abandoned coroutine | its unwinding releases the owner: as `release` | `abandon` |
| Loop shutdown | waits revoked (`StreamClosed`), owners released; `msp::shutdown()` kills and reaps synchronously what the reaper did not reach | `shutdown` |
| Cancelling a read or wait | `Interrupted`; the child runs on and stays owned; later reads work | `cancel` |
| Closing stdin | the child reads EOF; later writes `StreamClosed` | `stdin` |
| Exit with unread output | the bytes stay readable after exit; a child with more unread output than the pipe holds cannot exit (it blocks in write) | `exit-unread` |
| Releasing while running | as scope exit; nothing is left behind | `release` |
| Detaching | streams closed, handle stale, the process runs on; reaped by `sweep` if it ends while the supervisor runs; otherwise reparented | `detach`, `detach-outlive` |

**The default.** Four alternatives were compared:

* *Kill synchronously in the cleanup* (SIGKILL the group, reap): bounded
  and simple, but never graceful -- an agent harness loses its chance to
  flush a transcript or remove a lock file. The experiment keeps it only as
  `shutdown`, for the end of a program.
* *Terminate gracefully in the cleanup*: impossible as such -- a cleanup
  may not yield (`repro/cleanup-cannot-wait.bot`: RESOURCE-DECLARATION), and
  blocking the loop's thread for a grace period would freeze everything.
* *Hand the dying child to a reaper* (the experiment's default): the
  cleanup sends SIGTERM and pushes the handle into the context's dying set;
  a reaper task gives each a task of its own (grace on the loop's timer,
  SIGKILL, reap, retire). Graceful, non-blocking, and the loop stays alive
  until the child is reaped (its exit watch is a keep-alive source).
* *Explicit detachment*: only by consuming the owner (`detach`), never by
  abandoning it.

Recommended: the third as the default, `finish` (await the same sequence
and get the status) and `detach` as the explicit alternatives, and
**ownership transfer as plain affine moves**: an owner moved into a
supervisor context's collection (context-owned affine state) is a
supervisor-owned process, with no new mechanism. A durable identity that a
*later* process reattaches to is a different thing (section 8) and belongs
to a coordinator, not to the resource. No implicit detachment arises
anywhere: an abandoned owner is released (observed: `abandon`).

Two hazards the model must document (observed): an identity used by a
second task after the owner was released is `StaleChild` (the slice once
read a released child's status that way and got a garbage code before the
module checked it: now refused); and a SIGTERM sent right after spawn can
kill a child before it installs its handler (the `release` scenario first
raced its child's `ignore:15`).

## 5. Event-loop integration

**No second scheduler** (observed). Every stream and every exit is a
readiness watch of the existing driver (`event_loop_linux::watch`), each
delivering to a registration of the scheduler (Coalesce, capacity 1,
keep-alive); a task reads or writes until EAGAIN, then waits for readiness
(`readable`, which re-arms the one-shot watch). The pidfd becomes readable
once the child has exited (Linux 5.3+), so the exit is one more watch.

* **Fixed interest is no obstacle here**: each descriptor has one direction
  (stdin writable, stdout and stderr readable, the pidfd readable), so the
  driver's B5 limitation (no interest change) never applies.
* **Readiness is single-consumer.** A record wakes the first waiter only.
  The slice had two tasks waiting for one child's exit; the second woke
  only when the registration was revoked. The module now re-arms the
  level-triggered pidfd watch when it observes an exit, which wakes the
  next waiter (`two-waiters`; mutant `m-exit-broadcast`). A product needs
  either this rule or a broadcast primitive.
* **No select.** A wait takes one registration. Deadline waits
  (`wait_until`, used by `terminate`) adopt a small alarm task that posts
  into the waited registration when a timer fires, and revoke the timer on
  an early return; every wake re-checks the state, so a coalesced record
  loses nothing. It works (observed: `terminate`, mutant `m-alarm`), but
  every library will rewrite it: a deadline wait is the first
  standard-library addition this census recommends.
* **Fairness is the reader's.** A read that finds data returns it without
  yielding; a child that floods its stdout therefore keeps a reading task
  running, and a 5 ms ticker was 1.7 to 4.9 ms late in three runs (and
  missed up to two ticks) while 64 MiB streamed without a yield
  (`perf-throughput`). With one `yield_now()` per chunk a continuous flood
  left a 10 ms ticker on time: 100 of 100 ticks, none missed, at most 0.07
  to 2.3 ms late across the runs (`perf-flood`). A package should yield
  every chunk (or every few), as the http executor's budget does.
* **Memory is the kernel's.** The supervisor buffers nothing: a read
  takes at most one 64 KiB chunk, and what a child writes ahead is bounded
  by the pipe's capacity (64 KiB here: a child with 30,000 unread bytes
  exits, one with 200,000 cannot until they are read: `exit-unread`). An
  output policy -- stream to a consumer, persist to a file (redirection at
  spawn, `persist`), keep a bounded tail, terminate past a limit (`limit`:
  the last 4,096 bytes kept, the child terminated after 1 MiB) -- is the
  reader's code, never an implicit accumulation. A blocking control (the
  `c-nonblock` mutant: the parent's ends left blocking) hangs the loop
  outright.
* **Liveness**: stream and exit registrations keep the loop alive while a
  task waits on them; the reaper waits on a channel that keeps nothing
  alive; dying children keep it alive through their exit watch until
  reaped. A program's `run()` ends once its children are reaped (observed:
  every scenario's end counters).
* **Clocks**: deadlines use the driver's clock read now (`msp_now`, the
  same CLOCK_MONOTONIC as `evl_now`), never `std::event_loop::now()`, the
  turn's (HTTP F6).
* **Capacity**: 4096 watches per loop, four per child with every stream
  piped: about 1024 children per VM (the experimental adapter's table also
  holds 1024, per process).

## 6. Exit observation and process groups

**pidfd, not SIGCHLD** (observed on Linux 6.18). The adapter starts a child
with `posix_spawn` (glibc implements it with `clone(CLONE_VM|CLONE_VFORK)`,
safe in a multithreaded process -- static, from glibc's design -- and
reports exec's errno to the parent: observed) and opens the
pidfd of the still-unreaped child at once (`pidfd_open`: race-free, the PID
cannot name another process before the parent reaps it). Exit is observed
by the pidfd's readiness, peeked with `waitid(P_PIDFD, WNOHANG|WNOWAIT)`,
and reaped by a separate call. No SIGCHLD handler is installed and
`waitid(P_ALL)`/`waitpid(-1)` are never called: either would steal the
children of every other library in the process.

**Signals name a process, never a number** (observed). Signals go through
the pidfd (`pidfd_send_signal`; `PIDFD_SIGNAL_PROCESS_GROUP`, Linux 6.9, for
the group). A process signal after the reap is `ESRCH`, never a stranger
(`msp-test`). A process group outlives its leader's reaping while any
member lives, and a group signal through the reaped leader's pidfd still
reaches it: the pidfd names the group by the leader's kernel `struct pid`,
not by a number a new process could reuse (`repro/group-after-reap.c`,
found by the mutant `c-wnowait`). The adapter is more conservative than
the kernel: it reaps a child only once its supervision is over and refuses
every signal after that, so a group signal after the leader's *exit* is
sent while the leader is unreaped (`reap-order`: delivered; the descendant
gone). The negative control that reaps at the first status check
(`eager-reap`) shows what that rule protects: afterwards the adapter
refuses the group signal and the descendant survives. On kernels before
6.9 the adapter falls back to `kill(-pgid)`, which is safe while the leader
is unreaped (its PID, the group's ID, cannot be reused) and also while any
member lives; only after the whole group has died and been reaped could
the number name another group (inferred: not run on such a kernel).

**A glibc defect** (observed, `repro/pidfd-spawn-leak.c`): glibc 2.39's
`pidfd_spawn`, which would do spawn and pidfd in one call, leaves its
pidfd open when exec fails and returns no descriptor to close -- one
leaked descriptor per failed launch (the `launch` scenario's first run
leaked exactly its four exec failures). `posix_spawn` leaks nothing. The
adapter uses `posix_spawn` + `pidfd_open` and keeps `pidfd_spawn` only as a
negative control (`msp-test`, mutant `c-leaking-spawn`).

**Process groups.** Each child leads a group of its own by default
(`POSIX_SPAWN_SETPGROUP`), so `terminate` and release reach its ordinary
descendants. Kernel compatibility: `pidfd_open` and pidfd polling need
Linux 5.3, `waitid(P_PIDFD)` 5.4, group signals through a pidfd 6.9
(inferred from the kernel's documentation; observed only on 6.18).

## 7. Cancellation and termination

**Cancellation is not termination** (observed). `interrupt(child)` bumps
the child's interrupt generation and posts a record to its registrations:
every suspended read, write or wait of the child fails `Interrupted`
(99.7 ms after it began, as scheduled), the child keeps running, and a
later read gets its output (`cancel`). Interrupting twice, or an idle
child, is harmless. The naive reader's deadlock (reading stdout to its end
while the child blocks on a full stderr) is detected exactly this way: a
watchdog task interrupts the read after 1.5 s (`naive`).

**Termination** (observed, `terminate`):

| Case | Result | Time |
|---|---|---|
| traps SIGTERM, takes 150 ms | exited 143 | 150.6 ms |
| ignores SIGTERM, grace 300 ms | signal 9, one escalation | 301.6 ms |
| ignores SIGTERM, exits by itself after 200 ms | exited 0 (no escalation) | 152 ms after the request |
| already exited (unreaped) | its status; a signal to it is accepted and harmless | -- |
| terminate twice | the same status | -- |
| after release | `StaleChild` (-116), no signal | -- |
| stopped by the terminal (SIGTTIN) | SIGTERM stays pending; signal 9 at the deadline | 300 ms |
| B in the slice, cancelled from the terminal | signal 9 | 300.5 ms |

**Descendants** (observed). A descendant in the child's group dies with
it (`descendants`). One that leaves with `setsid()` survives the group's
termination, reparented to PID 1 (`descendants`: alive afterwards); the
operating system offers no group guarantee for it. With the supervisor as
the child subreaper (`PR_SET_CHILD_SUBREAPER`) the escapee is reparented to
the supervisor when its parent dies, found among the process's children
that the table does not know, killed and reaped (`subreaper`: found 1,
killed 1, none after). But the subreaper flag is process-wide: every
orphan of every library becomes the process's, so it belongs to a
dedicated coordinator process, not to an application that also runs other
libraries. Cgroup v2's `cgroup.kill` is the only kernel mechanism that
reaches an adversarial tree; this container's cgroups are v1 (no
`cgroup.kill`), so it is inferred, not tested. The target is ordinary
harnesses, not a sandbox: a child that double-forks and changes session is
contained only by a subreaper or a cgroup.

**Inherited pipes** (observed, `inherited`): a descendant that inherited
the child's stdout keeps it open after the child exited -- the leader's
exit was observed after 1.1 ms, its stdout's end of file only after 1.5 s,
when the descendant ended. A group SIGKILL after the leader's exit (leader
unreaped) ends the descendant and the stream at once (1.4 ms).

**Escalation policy, as implemented**: stop writing to stdin is the
caller's (close it first); SIGTERM to the group; wait the grace period on
the loop's timer; SIGKILL to the group; wait for exit; reap; close the
streams; report. Cancellation during termination (an interrupt of the
waiting task) makes the terminating call fail `Interrupted` but never
undoes a signal already sent; the reaper's own termination is
uninterruptible.

## 8. Durability and restart recovery

`tools/recovery.py` plays a persistent coordinator around the Botlish
supervisor `slice/durable.bot`, which starts three jobs, writes their
records (name, PID, start time from `/proc/PID/stat` field 22, process
group, working directory) with `std::linux::fs`, and is then SIGKILLed (no
cleanup runs). Observed, with the coordinator as the subreaper
(`results/recovery-subreaper.txt`) and without (`recovery-no-subreaper.txt`):

| What | After the supervisor's crash |
|---|---|
| P1: piped stdout, writes every 100 ms | dies of SIGPIPE at its next write (0.3 s); its status is seen only by an ancestor subreaper |
| P2: piped, silent | survives, reparented (to the coordinator, or PID 1) |
| P2's descendant | survives, in P2's group |
| P1's and P2's pipes | gone with their reader: no output after the crash is recoverable |
| P3: stdout and stderr to files | completes normally: 64 bytes at the crash, all 260 afterwards; exit 0 seen by the subreaper only |
| Exit information | the subreaper coordinator reaps every orphan with its status; without it, nothing observes them |
| Process-group membership | kept: P2's group survives and is signalled as a whole |
| Reattachment | `pidfd_open(PID)`, then the record's start time verified against `/proc`: the pidfd names the recorded process (a PID that verified after the open cannot have been reused in between); SIGTERM to P2's group through the pidfd works for a process that is not the coordinator's child; a forged record (another start time) is refused |

What can and cannot be recovered:

| Situation | Recoverable |
|---|---|
| The TUI closes, the coordinator runs | everything: the TUI is a client |
| Only the UI restarts | everything, by reconnecting to the coordinator |
| The coordinator restarts (children alive) | processes: yes (pidfd + start time; signals; exit *observed* by pidfd readiness); exit *status*: only if the new coordinator is their ancestor subreaper, otherwise lost; pipes: lost (file output survives) |
| The coordinator is killed | as above; piped jobs die at their next write |
| The host reboots | no process; job records and output files survive; a record's boot id (`/proc/sys/kernel/random/boot_id`) says its PIDs mean nothing any more (inferred: not exercised) |

The architecture this requires (projected, from the observations above):

1. **A persistent coordinator process**, separate from the TUI, that is its
   jobs' subreaper (so it collects every status, descendants' included),
   runs one job per process group, and writes each job's output to files
   (append-only logs the TUI tails), never to pipes that die with a reader.
2. **A job journal**: job id, PID, start time, boot id, process group,
   working directory, worktree and branch, output paths, state, exit
   information, termination policy -- written before the job is reported
   started and after each transition. A live process handle is never
   persisted: the pidfd is reopened and verified.
3. **The TUI as a client** over local IPC. Botlish has no socket API; a
   Unix-domain socket is reachable through the raw syscall transport from a
   direct module (socket, bind, connect, with a `sockaddr_un` built as
   bytes: inferred) or through a small package, and its descriptors are
   watched like any other.

A coordinator also solves the subreaper conflict of section 7: it runs no
unrelated library.

## 9. Terminals and PTYs

**The published TUI package is not in this repository**, and its report was
not available (as for TEXT-AND-COLLECTION-PRECISION-CENSUS.md): its input
model could not be inspected. What can be said from the repository and the
experiment:

* **Terminal input is an ordinary event-loop source** (observed): the slice
  watches its own stdin (descriptor 0) with `event_loop_linux::watch`,
  reads only after readiness (`std::linux::io::read` is blocking, so a read
  without readiness would block the loop), and reacts to a typed line while
  two children stream, a timer ticks and a cancellation escalates. A TUI
  package that reads the terminal another way (a blocking read on a thread,
  a polling loop) would compete with this; one that registers descriptor 0
  as a watch composes with it. **Integration work: the TUI package must
  take its input as a watch of the application's loop** -- the one thing
  to verify against its code.
* **`std` has no termios** (static): raw mode, window size and `isatty`
  are the TUI package's own (C or ioctl through the raw transport). The
  slice stays in cooked mode, so it has nothing to restore; the harness
  checked the terminal's attributes unchanged after every PTY run but
  `tty-raw`'s, whose child changes them on purpose.
* **Children must not get the terminal by default** (observed). A child in
  a process group of its own given the terminal as stdin is stopped by the
  kernel (SIGTTIN) on its first read, never exits, and takes SIGKILL to end
  (`tty-read`: state `T`). A child in the supervisor's group given the
  terminal can change its mode: `tty-raw` left the PTY in raw mode,
  corrupting the supervisor's terminal. The experiment's default is pipes
  for all three streams, and `/dev/null` is available for stdin.
* **PTY children** (inferred, not built). A harness that insists on a
  terminal needs a pseudo-terminal: `posix_openpt`, `grantpt`, `unlockpt`,
  and a child that is a session leader (`POSIX_SPAWN_SETSID`) opening the
  slave without `O_NOCTTY` -- which makes it the controlling terminal on
  Linux, so `posix_spawn`'s file actions suffice. The master is one more
  watched descriptor; resizing is an ioctl. Separate from pipe supervision,
  and not the default merely because the application is a TUI.
* **The harnesses do not need one** (static, partly): Claude Code has a
  non-interactive mode with structured I/O (`claude --print
  --output-format stream-json --input-format stream-json`, from its own
  `--help` here; not run); Codex and OpenCode are not installed here, and
  their batch modes (`codex exec`, `opencode run`) are inferred from their
  documentation, not verified. Agent harnesses should be supervised over
  pipes with structured (JSON-lines) output; a PTY is the fallback for a
  tool that changes behavior on a terminal.

## 10. Threads and actors

* **A child belongs to the VM that spawned it** (observed). The `threads`
  experiment runs two Botlish-owned threads, each installing its own loop,
  driver and process context, supervising a child concurrently (2,000,170
  and 3,000,080 bytes read, exits 11 and 22, nothing left live). Exit and
  readiness wake the right loop by construction: each VM's pidfds and pipes
  are watched by its own epoll instance, so nothing routes a wake between
  threads (unlike http's resolver, which posts across threads).
* **A child's identity cannot cross VMs** (observed,
  `repro-send-child.bot`): `msp::Child` is an opaque struct without a
  `sendable` clause, so a thread entry taking one is refused at compile time
  (THREAD-ENTRY-SIGNATURE). The adapter's thread check is the second line:
  another thread's call on a handle is `-EPERM` (`msp-test`).
* **Other VMs ask the owner.** A supervising VM receives typed commands
  (start, write, interrupt, terminate) through `std::actor::remote` and
  answers with typed results (bytes, statuses) -- the model the brief
  prefers, which needs no change (projected: not exercised).
* **Process-wide state** a process package must respect (static and
  observed): the SIGPIPE disposition (reset in every child), close-on-exec
  on every descriptor (a concurrent spawn on another thread must not
  inherit a pipe: O_CLOEXEC everywhere and `closefrom(3)` in the child), the
  subreaper flag (process-wide: a coordinator's, section 7), any
  `waitpid(-1)` (never), and the adapter's table (locked). No global signal
  handler is needed or installed.

## 11. Other platforms

Linux was the experiment's only platform. The others, from local sources
(static) or documentation (inferred):

| Concern | Linux (observed) | macOS AArch64 | Windows x86-64 |
|---|---|---|---|
| Spawn | posix_spawn + pidfd_open | posix_spawn (Apple's `POSIX_SPAWN_CLOEXEC_DEFAULT` closes every other descriptor: inferred) | `CreateProcessW` with `STARTUPINFOEXW` and `PROC_THREAD_ATTRIBUTE_HANDLE_LIST` (all in the committed Win32 binding, `generated/c/win32/`: static) and a quoted command line (the driver already writes one: `native/src/launch.rs`) |
| Pipes | non-blocking pipes, epoll | pipes, kqueue (inferred) | anonymous pipes cannot be overlapped: named pipes (`CreateNamedPipeW`, in the binding) with IOCP (`CreateIoCompletionPort`, `GetQueuedCompletionStatus`: in the binding) |
| Exit notification | pidfd readiness | kqueue `EVFILT_PROC`/`NOTE_EXIT` while the child is unreaped (inferred) | the process handle is waitable (`WaitForSingleObject`, `RegisterWaitForSingleObject`: in the binding) |
| Identity safety | pidfd | the unreaped zombie reserves the PID; kqueue registration (inferred) | a process handle pins the process object (inferred) |
| Tree termination | process groups; subreaper; cgroups v2 | process groups; no subreaper | Job Objects: `CreateJobObjectW`, `AssignProcessToJobObject`, `TerminateJobObject`, `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`, completion-port notification (`JOBOBJECT_ASSOCIATE_COMPLETION_PORT`): all in the binding (static) -- stronger than process groups: a job's descendants cannot leave it unless allowed (inferred) |
| Graceful stop | SIGTERM | SIGTERM | no signal: `GenerateConsoleCtrlEvent` for a console process group (`CREATE_NEW_PROCESS_GROUP`), else a protocol of the child's; `TerminateJobObject` is the hard stop |
| Arguments, paths | bytes | bytes | UTF-16, the command line re-parsed by the child's C runtime (WTF-8 conventions already exist: ARGV.md) |
| Event-loop driver | `event_loop_linux` | **none** | **none** |

Barriers, classified: on both other platforms the first barrier is a
**driver package** (kqueue; IOCP), which `std::event_loop` already
abstracts; then a **native adapter** per platform (the spawn plan, the
handles, the tree mechanism). None is a language limitation. The portable
surface should hide groups, signals and pidfds behind `terminate(grace)`
and `kill()`; signal numbers stay a Linux/macOS extension.

## 12. The vertical slice, and the commands

`slice/slice.bot` (observed, `results/runs/slice.txt`, under a PTY): child
A (its own directory, `cwd chunks:15:40 err:... lines:3 exit:0`) streams
stdout and a stderr warning and reads three lines the slice feeds it 100 ms
apart; child B (another directory, a descendant in its group, ignores
SIGTERM, streams every 20 ms) runs until the harness types `c` on the
terminal; a ticker reports both children's byte counts every 100 ms from a
shared context (`board.bot`); the controller task terminates B (SIGTERM
ignored, SIGKILL at 300 ms, its descendant killed with the group); A exits
0. At the end: nothing owned, nothing live, one escalation, no descriptor
or registration left, nothing for `shutdown` to kill, the terminal's
attributes unchanged, every PID and the descendant gone (checked from
outside). Elapsed: 0.8 s.

The optional concurrent HTTP request was not attempted: the `http` package
needs its Rust unit and the BoringSSL provider built (`tests/cffi/http.tcl`)
and its one-runtime-thread rule is irrelevant to one VM; nothing in the
slice would change (both are watches and timers of one loop).

Commands (Linux x86-64; Tcl 9.0.1 and the native backend installed as
AGENTS.md says):

    export LANG=C.utf8 LC_ALL=C.utf8
    python3 -I audit/managed-subprocess/tools/run.py --build      # every scenario
    python3 -I audit/managed-subprocess/tools/run.py --only slice # the slice, under a PTY
    python3 -I audit/managed-subprocess/tools/recovery.py         # crash recovery
    python3 -I audit/managed-subprocess/tools/recovery.py --no-subreaper
    python3 -I audit/managed-subprocess/tools/mutate.py           # the mutants
    cd audit/managed-subprocess/slice && tclsh9.0 ../../../main.tcl -check repro-send-child.bot
    tclsh9.0 main.tcl -check audit/managed-subprocess/repro/posix-spawn-ffi.bot
    tclsh9.0 main.tcl -check audit/managed-subprocess/repro/cleanup-cannot-wait.bot
    tclsh9.0 main.tcl run audit/managed-subprocess/repro/raw-fork.bot
    cc -O2 audit/managed-subprocess/repro/pidfd-spawn-leak.c -o leak && ./leak
    cc -O2 audit/managed-subprocess/repro/group-after-reap.c -o grp && ./grp

A single scenario by hand: `slice/lab-io HELPER streams TMPDIR` (HELPER is
`slice/bin/msp-child`).

The results in `results/` are from the census's base (52e0ff5a). Merged
with main (at 861a1a4d; main's later commits before the merge changed only
its CI), the whole harness was run again: every program rebuilt, 42 of 42
scenarios passed; `tools/mutant-catalogs.tcl` reported 100 catalogs and 0
problems.

## 13. Negative tests, fault injection, mutants, limitations

Every scenario runs under an external watchdog: a hang is reported as
`TIMEOUT` and fails (the harness's runs, and the mutation runs, count
timeouts as detections, never as passes).

| Brief's case | Scenario | Result |
|---|---|---|
| Missing executable | `launch` | `exec -2` (ENOENT) |
| Permission denied | `launch` | `exec -13` (a non-executable file, a directory) |
| Relative name | `launch` | not searched: `exec -2` |
| Invalid working directory | `launch` | `working-directory -2`; a file as cwd: `-20` (ENOTDIR) |
| Redirection file | `launch` | `file -2` |
| NUL in an argument | `launch` | `spec -22`, before anything starts |
| Descriptors exhausted (RLIMIT_NOFILE 128) | `exhaust` | the 30th launch: `pipe -24` (EMFILE), nothing half-made, nothing leaked |
| Broken stdin | `stdin-closed` | `StreamClosed` (EPIPE; the supervisor ignores SIGPIPE) |
| Writes larger than the pipe | `stdin-partial` | partial writes completed: 1,000,000 bytes echoed |
| stdout EOF before exit | `eof-early` | EOF while running; exit 4 300 ms later |
| stderr open after stdout closed | `eof-early` | read afterwards |
| Large stderr while stdout unread | `streams`, `naive` | concurrent: both 1 MiB; naive: the deadlock, detected |
| Exit between spawn and registration | `exit-first`, `latency` | level-triggered: seen late, never lost |
| Exit between status check and wait | `two-waiters`, `latency` (200 runs) | seen |
| Cancellation racing exit | `terminate` (exits during grace) | exit status, no escalation |
| Ignored graceful termination | `terminate`, `release`, `slice` | escalated |
| Failed or repeated signals | `terminate` | harmless; stale after release |
| Parent abandonment | `abandon`, `shutdown`, `recovery.py` | released / killed / section 8 |
| Descendant survival | `descendants`, `subreaper`, `recovery.py` | section 7 |
| PID or handle reuse | `stale`, `msp-test`, `recovery.py` | refused (generation; pidfd; start time) |
| Watch released during delivery | `watch-release` | the next child of the slot gets its own data only |

Native fault injection: the adapter's negative controls are spawn flags
(keep the signal dispositions, keep the descriptors, reap eagerly, the
leaking `pidfd_spawn`) and `RLIMIT_NOFILE` for the pipe stage.

**Mutants** (`tools/mutants.txt`, in the repository's catalog format so
`tools/mutant-catalogs.tcl` keeps checking that they apply;
`results/mutants.txt`): 15 mutants of the adapter and the module, every one
killed by the scenario its `!!` line names (a hang counts, through the
watchdog):

| Mutant | What it breaks | Killed by |
|---|---|---|
| `c-sigdefault` | children keep the supervisor's dispositions (SIGPIPE ignored) | `inherit` |
| `c-nonblock` | the parent's pipe ends stay blocking | `streams` (the loop hangs) |
| `c-wnowait` | the status check reaps without recording it | `reap-order` (a slot and descriptors leak) |
| `c-generation` | handles' generations unchecked | `stale` |
| `c-group-signal` | signals reach the child only | `descendants` (an in-group descendant survives) |
| `c-cwd-in-parent` | the working directory not checked as a directory in the parent | `launch` (misreported as exec) |
| `c-leaking-spawn` | glibc's `pidfd_spawn` | `launch` (four descriptors leak) |
| `m-interrupt` | interrupts change nothing | `cancel` |
| `m-alarm` | deadline waits never wake | `terminate` |
| `m-escalate` | no SIGKILL | `terminate` |
| `m-release-term` | a release sends no SIGTERM | `release` (an extra escalation) |
| `m-read-eagain` | EAGAIN read as end of file | `streams` (the child blocks forever) |
| `m-write-partial` | a short write counted as complete | `stdin-partial` |
| `m-retire-on-release` | retirement's condition inverted | `release` |
| `m-exit-broadcast` | the exit watch not re-armed | `two-waiters` (the second waiter hangs) |

Two needed a second round, recorded in the results file: `m-read-eagain`
first did not compile (a weak kill, rewritten), and `m-write-partial`
survived -- no scenario wrote more than the pipe held, so no write was ever
partial -- until `stdin-partial` was added. `c-wnowait` also corrected this
census's account of reaping (section 6).

**Limitations of the experiment.** Linux x86-64 only (the AArch64 build
was not tried; nothing in it is architecture-specific); one helper child,
no real agent harness run; no PTY child; no HTTP beside it; cgroups not
available; the module is not warning-clean and uses linear scans (a
handful of children per VM); the adapter's table is fixed (1024 children,
64 specs).

**Compiler obstructions met** (not fixed; F2-F4 are another line's work):

* **F3 reproduced**: `durable.bot` imports `std::linux::fs` and built its
  record lines with method-style `.concat`; on the census's base (52e0ff5a)
  its compilation ran over 180 s and was killed; with qualified
  `std::str::concat` calls it compiles in 28 s. The module avoids method
  syntax on strings for this reason. On main after F3's fix (19d057aa,
  merged with this census) the method-style file compiles in 66 s, the
  qualified one in 26 s: much better, still two and a half times the
  qualified cost.
* Friction, already known: no typed empty `MutableVector` (an affine
  vector is made from its first element), no integer division (the
  measurements divide in Python), a rebinding inside an `if` block shadows
  instead of updating (the module's first slot bug), handlers attach to the
  outermost call (an argument's errors need a binding of their own), only
  the five string escapes (a NUL string is decoded from bytes).

## 14. Measurements

Measured on this container (4 cores, shared), one run each unless
stated; `results/runs/perf-*.txt`. No thresholds: the point is bounded
behavior.

| Measure | Result |
|---|---|
| Spawn call (spec, posix_spawn, pidfd, four watches) | mean 246 µs, max 2.0 ms (200 runs; 262 and 277 µs means in two earlier runs) |
| Exit notification (the child's last instruction to the waiting task) | mean 149 µs, max 353 µs (earlier: 169, 171 µs) |
| Spawn, read to end, wait, release | mean 1.10 ms |
| 64 MiB of stdout | 29.1 ms (about 2.2 GiB/s; 30 to 38 ms across the runs); 1,024 chunks of 64 KiB; 1,034 `msp_read` calls, 9 of them EAGAIN; supervisor CPU 27.8 ms |
| Native calls per chunk | one read per chunk; per EAGAIN one re-arm and one wait |
| Peak memory | 16.3 MB while 64 MiB streamed, the same as an idle run: nothing accumulates |
| Backpressure | an unread 8 MiB producer sleeps in `anon_pipe_write`; the paused supervisor holds 1.8 to 4.8 MB resident |
| Idle: two children, 2 s | 154 µs of CPU, 3 loop turns, 3 driver blocks |
| Polling control (exited? every 1 ms) | 62 ms of CPU, 1,814 turns: about 400 times the event-driven CPU |
| Scheduling under a flood | 10 ms ticker, one yield per chunk: 100 of 100 ticks, at most 67 µs late (0.7 and 2.3 ms in earlier runs); no yield (the 64 MiB stream), 5 ms ticker: 1.7 to 4.9 ms late, up to two ticks missed |
| Cancel to graceful exit | 150.6 ms (the child's own 150 ms) |
| Escalation | SIGKILL at 301.6 ms of a 300 ms grace |
| Many children | 400 sequential spawn-wait-release: 420 ms; 64 at once: 65 ms; no wrong status, zombie or descriptor left |
| stdin: 4 MiB to a child that reads after 300 ms | 305 ms; 95 EAGAIN; a 10 ms ticker kept ticking (30 ticks) |
| stdin: 1,000,000 bytes in 100,000-byte writes (beyond the pipe) | 36 native writes: every write partial, completed after readiness |
| stdout and stderr 1 MiB each, concurrently | 2.4 ms |

The supervisor's figures include the runtime's fixed cost (about 16 MB
resident for any native program with the driver). The CPU the harness
reports per run (`[harness] ... CPU`) is wait4's, which includes the
supervisor's reaped children.

## 15. A proposed public API (projected)

Names are conceptual; nothing here is implemented beyond the experiment.

    # std::process (portable, once two platforms implement it)
    struct Command                 executable, arguments, environment
                                   (inherit + overrides | explicit),
                                   directory, stdin/stdout/stderr policy
                                   (Pipe | Null | Inherit | File(path,
                                   append)), tree policy (Own | Shared)
    error LaunchFailed {stage: Stage, code: int}
    enum Stage: Spec, WorkingDirectory, File, Pipe, Exec, Limit
    struct ExitStatus {ending: Exited | Signaled | Dumped, code: int}
    error Interrupted; error StreamClosed; error StaleChild

    # process_linux (the package; std::process's later Linux implementation)
    context Processes              the authority to start processes (an
                                   entry installs it, from event_loop_linux's
                                   Native; restricted injection withholds it)
    spawn(command) -> {owner: ChildOwner, child: Child}
    read(child, Stdout | Stderr) -> Bytes          one chunk; empty at EOF
    write(child, bytes); close_stdin(child)
    wait(child) -> ExitStatus; wait_until(child, deadline) -> bool
    interrupt(child)                               cancel waits, not the child
    terminate(child, grace) -> ExitStatus          the group: TERM, grace, KILL
    kill(child)
    release(owner)  [cleanup]                      async terminate if running
    finish(owner, grace) -> ExitStatus
    detach(owner)                                  the only way to outlive it
    lines(child, stream) -> ...                    a line splitter over chunks

Operations live on the child identity, not on separate stream resources:
a stream has no lifetime of its own worth owning (it is closed when the
child is retired), and separate stream owners would let a program release
stdout while the child still writes it. A stream *can* be closed early
(`close_stdin`; a `close_output` would be its pair).

Authority: `Processes` is the only way in. A restriction that cannot be
enforced (a list of permitted executables, while the child itself can exec
anything) is no security boundary and must not be presented as one; a
library that needs processes requires the context and the application
decides. The native functions stay private behind the module.

## 16. Milestones

Each independently useful:

* **M0. Small general additions** (S, std and the driver): a deadline wait
  (`wait_until(reg, deadline)`) or a wait on several registrations in
  `std::event_loop`; reading the environment (`std::process::environment()`
  or `std::linux`); a byte search in `std::abi::bytes` (`find`); the
  driver's interest change (HTTP B5). None is subprocess-specific.
* **M1. `process_linux` 0.1**: the experiment's adapter and module made a
  package -- pidfd, groups, the reaper, interrupts, file redirection,
  `finish`/`detach`; generation-checked handles; yields per chunk; tests
  against the helper child under GC stress; mutants; a clean room with the
  single-file compiler. The agent TUI's minimum.
* **M2. Lines and structured output**: an incremental line splitter over
  chunks (with a byte search, M0), bounded-tail and spill-to-file sinks,
  limits that terminate.
* **M3. The coordinator**: a Botlish daemon that is its jobs' subreaper,
  journals job records (PID, start time, boot id), writes outputs to files,
  reattaches after a restart, and serves a client over a Unix-domain socket
  (a small socket package: the remaining IPC gap).
* **M4. PTY children** (if a harness needs one): openpt, controlling
  terminal through `POSIX_SPAWN_SETSID`, the master as a watch, resize.
* **M5. macOS**: an `event_loop_darwin` driver (kqueue), then the process
  adapter (posix_spawn, `EVFILT_PROC`).
* **M6. Windows**: an IOCP driver, then the adapter (`CreateProcessW`,
  named pipes, Job Objects).
* **M7. `std::process`**: the portable surface over M1, M5 and M6.

## 17. Answers to the census's questions

**A. Process ownership.** Yes (observed). A child is an affine owner and an
ordinary identity; the owner's scope bounds the supervision, not the
process: releasing it terminates a running child asynchronously (a reaper
task, because a cleanup cannot wait), `finish` waits for the same, and only
`detach` lets the process outlive its owner. The identity is refused
(`StaleChild`) once the owner is gone, also after its slot is reused.

**B. Event-loop composition.** Yes (observed): pipes and the pidfd are
watches of the existing driver; tasks wait on their registrations; no
second scheduler, no polling, no thread, no signal handler. Two rules a
product must keep: re-arm the level-triggered exit watch so every waiter
wakes, and yield while a stream keeps delivering. A deadline wait in
`std::event_loop` would remove the experiment's one workaround.

**C. Cancellation.** Yes for ordinary descendants (observed): SIGTERM to the
child's own process group, a grace period on the loop's timer, SIGKILL,
all through the pidfd, which names the group by the leader's kernel
object, never by a number -- no PID-reuse hazard. A descendant that leaves the group
(setsid) escapes it; a subreaper coordinator finds and kills it, a cgroup
v2 would contain it (not available here). Not a sandbox.

**D. Durability.** A persistent coordinator, separate from the TUI: the
jobs' subreaper (it alone sees their exit statuses), one process group per
job, output to files (pipes die with their reader: SIGPIPE), a journal of
(PID, start time, boot id) records reattached through `pidfd_open` and
start-time verification (observed), the TUI as a client over local IPC. A
host restart keeps only the journal and the files.

**E. Terminal integration.** Yes, if the TUI takes its input as a watch of
the application's loop (observed for stdin; the published TUI package is
not in this repository and was not inspected). Children must get pipes,
never the terminal (observed: a background-group child reading it stops;
a foreground one can leave it raw). `std` has no termios: raw mode is the
TUI package's.

**F. Actor isolation.** Yes (observed): a child is its spawning VM's; its
identity is not sendable (compile-time refusal); the adapter refuses
another thread; each VM's epoll watches its own children. Other VMs send
typed commands to the owner (`std::actor::remote`).

**G. Portability.** Portable: the command, the environment and directory,
stream policies, the owner/identity pair, read/write/close, wait with a
deadline, interrupt, terminate-with-grace, kill, detach, exit status and
the errors. Platform-specific: signals and process groups, pidfds,
subreapers and cgroups (Linux), kqueue process filters (macOS), Job
Objects, console control events and named pipes with IOCP (Windows), PTYs
and ConPTY, durable identities (start time and boot id; a Windows process
creation time).

**H. Remaining language gaps.** None that requires the language. Package
work: the process adapter per platform, drivers for macOS and Windows, a
socket package for coordinator IPC, a termios binding (the TUI's).
Standard-library or driver work: a deadline (or multi-registration) wait,
the environment, a byte search, the driver's interest change. Compiler
defects that hurt: F3 (method-style calls with `std::linux::fs` imported:
over 180 s for one file here before its fix, 66 s against 26 s after).

**I. Agent-framework readiness.** The smallest remaining set for an initial
clean-room agent TUI -- direct HTTP for the PM conversations (`http`
0.2.0, ready), thin subprocess adapters for implementation agents -- is:
**`process_linux` (M1)** with **a line splitter (M2)** for JSON-lines
output, the TUI package's input as a watch of the same loop, and, for jobs
that must survive the TUI, **the coordinator (M3)** with a Unix-domain
socket. Everything else -- macOS, Windows, PTYs, `std::process` -- can
follow. A coding agent is then an ordinary supervised process with a
working directory, an argument vector, a JSON-lines stdout and a
termination policy: nothing agent-specific in the language or the runtime.
