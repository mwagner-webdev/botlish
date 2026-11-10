# The process_linux package: a user's guide

`process_linux` supervises external processes from a Botlish program on
Linux x86-64: it starts them without a shell, streams their standard input
and output as bytes, observes how they end, and terminates them -- all
through the program's own event loop. This guide is the package's
reference; README.md is the overview and a first program.

Contents: 1. The contexts -- 2. Commands -- 3. Spawning -- 4. Streams --
5. Exit -- 6. Cancellation and termination -- 7. Ownership and cleanup --
8. Detachment -- 9. Process groups -- 10. Threads -- 11. Errors --
12. Prerequisites, limits and what this release does not do.

## 1. The contexts

A program that supervises processes installs four contexts in its entry
program, in this order:

    with context std::event_loop::create(64)         the scheduler
    with context event_loop_linux::create()          the Linux driver (epoll)
    with context event_loop_linux::native()          the driver's integration capability
    with context process_linux::create()             the process authority (Processes)

`Processes` is the authority to start processes. Only an entry program can
install a context, so a library that needs processes declares
`context p: process_linux::Processes` on its functions and the application
decides whether to give it one; it cannot start a process where the
application did not install the context, and the package's native functions
are private (there is no other way in). The context is made from the
driver's `Native`, so it cannot exist without the Linux driver.

`process_linux::create_with(options)` sets two things:
`release_grace_us`, how long a released child that still runs is given
between SIGTERM and SIGKILL (default 2 s), and `burst`, how many chunks a
stream that keeps delivering reads or writes before its task yields to the
loop (default 4).

Every operation that waits -- `read`, `write`, `wait`, `wait_until`,
`terminate`, `finish` -- suspends the calling task only, so it must run in a
task of the loop (`std::event_loop::adopt`). Operations that do not wait
(`spawn`, `interrupt`, `send_signal`, `kill`, `release`, `detach`) can run
anywhere, also before the loop runs.

## 2. Commands

A `Command` is a value describing what to start, built from
`process_linux::command(executable, arguments)` with the `with_*`
functions (each returns a new Command):

| Function | What it sets |
|---|---|
| `command(executable, arguments)` | the executable's path (also argv[0]) and the arguments after it, each exactly these bytes |
| `in_directory(c, dir)` | the working directory (default: the supervisor's) |
| `with_env(c, name, value)` | sets NAME in the child's environment (later settings win) |
| `without_env(c, name)` | removes NAME |
| `with_clear_env(c)` | starts from an empty environment (only what `with_env` sets) |
| `with_stdin(c, Input::Pipe / Null / Inherit)` | stdin a pipe the program writes (default), /dev/null, or the supervisor's own |
| `with_stdin_file(c, path)` | stdin read from a file |
| `with_stdout(c, Output::Pipe / Null / Inherit)`, `with_stderr(...)` | stdout or stderr a pipe the program reads (default), /dev/null, or the supervisor's own |
| `with_stdout_file(c, path, FileMode::Truncate / Append)`, `with_stderr_file(...)` | stdout or stderr written to a file (created with mode 0666 less the umask) |
| `with_group(c, Group::Own / Shared)` | whether the child leads a process group of its own (default) or stays in the supervisor's (section 9) |

The executable is a path, never searched for in PATH; a relative path is
resolved in the child's working directory, as execve resolves it. There is
no shell: arguments are never split, quoted, globbed or expanded (`"$HOME"`
and `"*"` reach the child as those characters). To run a shell command,
start the shell explicitly: `command("/bin/sh", ["-c", text])`.

Arguments, environment names and values, paths are `str`: their UTF-8
bytes reach the child. A C string cannot hold a NUL, so an item holding one
is `InvalidCommand` (section 3), as is an empty executable, an empty
environment name or one containing `=`.

Every stream defaults to a pipe. A child that reads its stdin waits for the
program to write it, so close stdin (`close_stdin`) once you have nothing to
write, or give it `Input::Null`. Do not give a child the terminal unless it
is meant to have it: a child of its own process group that reads an
inherited terminal is stopped by the kernel (SIGTTIN), and one of the
supervisor's group can leave the terminal in raw mode.

## 3. Spawning

    {owner, child} = process_linux::spawn(command)

returns the child's owner and its identity (section 7), or fails before
anything runs:

* `InvalidCommand {item, reason}` -- the command cannot be started as
  written: ITEM names the part ("executable", "argument 3", "environment
  name", "environment value of PATH", "directory", "stdout file") and
  REASON what is wrong ("contains NUL", "is empty", "contains '='").
* `LaunchFailed {stage, code}` -- the operating system refused: STAGE says
  where (`Stage::WorkingDirectory`, `File` -- a redirection file or
  /dev/null --, `Pipe`, `Pidfd`, `Limit` -- the adapter's table of children
  is full --, all opened in the supervisor before the child exists, or
  `Exec` itself) and CODE the errno (2 no such file, 13 permission denied,
  20 not a directory, 8 not an executable format, 24 too many open files).
  A failed launch leaves nothing running and no descriptor open.
* `Unsupported {reason, code}` -- this process cannot supervise children
  safely: the kernel has no pidfds, or SIGCHLD is ignored in the process.
* `ProcessFault` -- the driver refused a watch, or another internal failure
  that is no property of the command.

A program that starts and then fails is no error: it has an exit status
(section 5). `spawn("/bin/false")` succeeds; its `wait` returns
`exited 1`.

The child starts with the default disposition of every signal and an empty
signal mask -- whatever the supervisor's (a Botlish program ignores
SIGPIPE; the child does not inherit that) -- and with no descriptor open
but its three standard streams.

## 4. Streams

    chunk = child.read(process_linux::Stream::Stdout)     # or Stream::Stderr
    child.write(bytes)
    child.close_stdin()
    child.close_output(process_linux::Stream::Stderr)

* `read` returns the next chunk of the stream, at most 64 KiB, waiting until
  there is one. An empty `Bytes` is end of file -- and only that: a read
  never returns empty because nothing is there yet. Reads after end of file
  return empty again.
* `write` writes all of its bytes: as much as the pipe takes at once, the
  rest after waiting for room. The writing task waits; the loop does not.
* `close_stdin` closes the child's stdin: it reads end of file. Later writes
  fail `StreamClosed`.
* `close_output` stops reading stdout or stderr: later reads fail
  `StreamClosed`, and the child's next write to it fails (by default the
  child dies of SIGPIPE).

The two output streams are independent: read them from two tasks. A child
that writes much to stderr while you read only stdout fills the stderr pipe
and blocks -- and so never finishes stdout. Read every piped stream you do
not close or redirect.

**End of file is not exit.** A child's stdout can close while it runs, and
stay open after it exited: a descendant that inherited the pipe keeps it
open (section 9). Output a child wrote before it exited stays readable after
it exited. Wait for exit with `wait`, read streams to end of file with
`read`, and do not take one for the other.

**Nothing is buffered here.** A read takes at most one chunk; what a child
writes ahead waits in the kernel's pipe (64 KiB), and a child whose pipe is
full blocks in its own write until you read (backpressure). Keeping the
output -- whole, a bounded tail, in a file, until a limit -- is your code's
decision, chunk by chunk:

```botlish
import event_loop_linux
import process_linux
import std::abi::bytes
import std::event_loop
import std::int
import std::io
import std::linux::io
import std::mutable_array
import std::str

# The last LIMIT bytes of C's stdout, and how many bytes it wrote in all;
# C is terminated once it wrote more than MAXIMUM.
struct Tail:
    kept: std::abi::bytes::Bytes
    total: int

fn tail(c: process_linux::Child, limit: int, maximum: int, context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> Tail errors process_linux::StaleChild, process_linux::StreamClosed, process_linux::Interrupted, process_linux::ProcessFault, std::event_loop::SchedulerFault:
    kept = std::mutable_array::create(1, std::abi::bytes::from_list([]))
    total = std::mutable_array::create(1, 0)
    loop:
        chunk = c.read(process_linux::Stream::Stdout)
        size = std::abi::bytes::length(chunk).value
        if size == 0:
            break
        seen = total.at(0):
            on IndexNotFound:
                0
        total.set(0, seen + size):
            on IndexNotFound:
                unit
        held = kept.at(0):
            on IndexNotFound:
                std::abi::bytes::from_list([])
        joined = std::abi::bytes::join([held, chunk])
        length = std::abi::bytes::length(joined).value
        last = if length > limit:
            joined.slice(length - limit, length):
                on LowerUnderrun:
                    joined
                on UpperOverrun:
                    joined
        else:
            joined
        kept.set(0, last):
            on IndexNotFound:
                unit
        if seen + size > maximum:
            c.terminate(1000000)
            break
    final = kept.at(0):
        on IndexNotFound:
            std::abi::bytes::from_list([])
    count = total.at(0):
        on IndexNotFound:
            0
    Tail {kept: final, total: count}

# The last 20 bytes of seq's output, and its size (seq writes 588,895
# bytes, far within the 1 MB maximum).
fn work(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> str errors process_linux::InvalidCommand, process_linux::LaunchFailed, process_linux::Unsupported, process_linux::StaleChild, process_linux::StreamClosed, process_linux::Interrupted, process_linux::ProcessFault, std::event_loop::SchedulerFault:
    {owner, child} = process_linux::spawn(process_linux::command("/usr/bin/seq", ["100000"]))
    t = child.tail(20, 1000000)
    status = child.wait()
    process_linux::release(owner)
    last = std::abi::bytes::decode_utf8(t.kept):
        on InvalidUtf8:
            "(not UTF-8)"
    process_linux::status_text(status).concat(", ").concat(std::int::to_string(t.total)).concat(" bytes, ending ").concat(last)

fn say(text: str, context io: std::linux::io::LinuxIO):
    std::linux::io::write_text(text.append_char('\n')):
        on std::io::WriteFailed:
            unit

fn task(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::linux::io::LinuxIO) -> int errors std::event_loop::TaskFailed, IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault:
    text = work():
        on process_linux::InvalidCommand:
            "invalid command"
        on process_linux::LaunchFailed:
            "launch failed"
        on process_linux::Unsupported:
            "unsupported"
        on process_linux::StaleChild:
            "stale"
        on process_linux::StreamClosed:
            "closed"
        on process_linux::Interrupted:
            "interrupted"
        on process_linux::ProcessFault:
            "fault"
    say(text)
    0

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native, p: process_linux::Processes, io: std::linux::io::LinuxIO) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered, std::event_loop::TaskFailed, IndexNotFound:
    coroutine {step, first} = task()
    std::event_loop::adopt(step, first)
    std::event_loop::run()

with context std::linux::io::create()
with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
with context process_linux::create()
main():
    on std::event_loop::SchedulerFault:
        -1
    on std::event_loop::DriverFault:
        -2
    on std::event_loop::LoopReentered:
        -3
    on std::event_loop::TaskFailed:
        -4
    on IndexNotFound:
        -5
```

To keep a child's output beyond the supervisor's life, redirect it to a
file at spawn (`with_stdout_file(c, path, FileMode::Append)`): nothing then
passes through the supervisor, and the file survives it.

**Fairness.** A stream that always has data -- a child that floods its
stdout -- would keep its reading task running without ever waiting. Every
`burst` chunks (default 4) a read or write that did not wait yields to the
loop first, so timers and other tasks keep their pace (a 10 ms ticker stays
on time while 2 GiB/s stream: PROCESS-LINUX-PACKAGE-MILESTONE-1.md's
measurements).

## 5. Exit

    status = child.wait()                 # ExitStatus
    exited = child.wait_until(deadline)   # bool: the deadline is process_linux::now_us()'s clock
    child.exited?()                       # without waiting
    child.status()                        # without waiting: StillRunning until it exited

An `ExitStatus` is `{ending, code}`: `Ending::Exited` with the exit status
(0..255), `Ending::Signaled` with the signal that ended it, `Ending::Dumped`
with the signal and a core dump. `process_linux::success?(s)` is a normal
exit with status 0; `status_text(s)` is "exited 3", "signal 9", "core 6".
A nonzero exit is an outcome, never an error.

Exit is observed through the child's pidfd, which the Linux driver watches
like any descriptor: no polling, no SIGCHLD handler, no thread. Any number
of tasks may wait for one child; each is woken. A child that exited before
anyone waited is seen at once. Deadlines are in microseconds on
`process_linux::now_us()`, the clock the loop's timers use
(`std::event_loop::now()` is the turn's clock: read `now_us()` for a
deadline).

## 6. Cancellation and termination

These are different things:

* `child.interrupt()` cancels the child's suspended `read`, `write`, `wait`,
  `wait_until`, `terminate` and `finish` calls: each fails `Interrupted`. The
  child keeps running and stays owned; later operations work again.
  Interrupting twice, or a child nobody waits on, is harmless. Use it for
  watchdogs and user cancellation of a *wait*.
* `child.terminate(grace_us)` ends the child: SIGTERM to its process group,
  `grace_us` for it to exit, SIGKILL to the group if it did not, its exit;
  then whatever is left of its group is killed (members still running once
  the leader exited). Returns how it ended. Interrupted, it fails
  `Interrupted` -- signals already sent stay sent.
* `child.kill()` sends SIGKILL to the group now and does not wait.
* `child.send_signal(Signal::...)` sends one signal (Hangup, Interrupt,
  Quit, Kill, User1, User2, Terminate, Continue, Stop) to the group.

```botlish
import event_loop_linux
import process_linux
import std::event_loop
import std::io
import std::linux::io
import std::str

# Run C until DEADLINE_US from now; then ask it to stop and give it two
# seconds before SIGKILL. How it ended.
fn bounded(c: process_linux::Child, deadline_us: int, context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> process_linux::ExitStatus errors process_linux::StaleChild, process_linux::Interrupted, process_linux::ProcessFault, std::event_loop::SchedulerFault:
    if c.wait_until(process_linux::now_us() + deadline_us):
        c.wait()
    else:
        c.terminate(2000000)

# sleep 10, bounded to half a second: terminated (SIGTERM ends it).
fn work(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native) -> str errors process_linux::InvalidCommand, process_linux::LaunchFailed, process_linux::Unsupported, process_linux::StaleChild, process_linux::StreamClosed, process_linux::Interrupted, process_linux::ProcessFault, std::event_loop::SchedulerFault:
    {owner, child} = process_linux::spawn(process_linux::command("/bin/sleep", ["10"]).with_stdin(process_linux::Input::Null))
    status = child.bounded(500000)
    process_linux::release(owner)
    "sleep: ".concat(process_linux::status_text(status))

fn say(text: str, context io: std::linux::io::LinuxIO):
    std::linux::io::write_text(text.append_char('\n')):
        on std::io::WriteFailed:
            unit

fn task(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::linux::io::LinuxIO) -> int errors std::event_loop::TaskFailed, IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault:
    text = work():
        on process_linux::InvalidCommand:
            "invalid command"
        on process_linux::LaunchFailed:
            "launch failed"
        on process_linux::Unsupported:
            "unsupported"
        on process_linux::StaleChild:
            "stale"
        on process_linux::StreamClosed:
            "closed"
        on process_linux::Interrupted:
            "interrupted"
        on process_linux::ProcessFault:
            "fault"
    say(text)
    0

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native, p: process_linux::Processes, io: std::linux::io::LinuxIO) -> int errors std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered, std::event_loop::TaskFailed, IndexNotFound:
    coroutine {step, first} = task()
    std::event_loop::adopt(step, first)
    std::event_loop::run()

with context std::linux::io::create()
with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
with context process_linux::create()
main():
    on std::event_loop::SchedulerFault:
        -1
    on std::event_loop::DriverFault:
        -2
    on std::event_loop::LoopReentered:
        -3
    on std::event_loop::TaskFailed:
        -4
    on IndexNotFound:
        -5
```

A signal sent right after `spawn` can reach a child before it installed its
own handler (it then dies of the default action): a child that must clean
up on SIGTERM gets a moment to start.

Signals go through the child's pidfd, never a PID number, and the child is
reaped only once its supervision is over (section 7): until then its PID --
and its process group's ID -- cannot name another process, so no signal of
this package can reach an unrelated process through a reused PID.

## 7. Ownership and cleanup

`spawn` returns two values:

* the **owner**, a `ChildOwner`: an affine resource -- one owner, moved,
  never copied. It bounds the *supervision*.
* the **identity**, a `Child`: an ordinary value the operations take. Copy
  it to as many tasks as need it.

Supervision ends in one of three ways:

* **`process_linux::release(owner)`** -- also what happens where the
  owner's lexical scope ends: at the end of its block, on every early exit
  (a `return`, a failure), and when a task holding it is abandoned
  (unwound). A child that exited is reaped now (any member of its group
  still running is killed first). One that still runs is sent SIGTERM (its
  group) and handed to the context's reaper task, which waits the release
  grace, sends SIGKILL if it still runs, waits for its exit, reaps it and
  retires it (its watches, registrations and descriptors). `release` itself
  returns at once: a cleanup cannot wait. The loop stays alive until the
  child is reaped, so `std::event_loop::run()` returns only after every
  released child is gone.
* **`process_linux::finish(owner, grace_us)`** -- the same sequence, waited
  for: SIGTERM, the grace, SIGKILL, the reap; returns how it ended.
  Interrupted, it hands the child to the reaper as `release` would.
* **`process_linux::detach(owner)`** -- section 8.

Once its owner is released, the identity is `StaleChild` for every
operation, at once (a read or wait already suspended on it wakes and fails
`StaleChild`); also when another child later gets its slot. Moving the
owner -- into a struct, a vector of a supervisor's context, another
function -- moves the supervision with it; there is no other transfer.

**The end of a program.** Let the loop run: `run()` returns when every task
is done and every released child reaped. `std::event_loop::shutdown`
revokes every registration: a read or write then fails `StreamClosed`, a
wait `Interrupted`, and the reaper kills (SIGKILL) and reaps what it was
terminating. `process_linux::shutdown()` kills and reaps every child still
supervised, at once, synchronously. And when a VM's thread ends (the program
ends) with children still supervised -- released without the loop run
again, or never released because the program ended first -- the adapter
kills their groups (SIGKILL) and reaps them: no child outlives its VM unless
it was detached. That is a backstop, not a graceful end: release and run
the loop for a graceful one.

What cannot be cleaned up: a supervisor killed by SIGKILL, or one whose
process ends by a native fault, runs no cleanup; its children are orphaned
(reparented to PID 1, or a subreaper). Durable supervision across
supervisor crashes is a coordinator's job (section 12).

## 8. Detachment

    pid = process_linux::detach(owner)

lets a process outlive its owner. The supervisor's ends of its pipes close:
a piped stdin reads end of file, and a write to a piped stdout or stderr
fails (by default the child dies of SIGPIPE) -- so detach a child whose
output goes to files or /dev/null. The identity goes stale. The process
keeps running, in its own process group, and is never signalled by this
package again. While this VM's loop runs, its exit is reaped (it never
becomes a zombie of the supervisor) without keeping the loop alive; once the
supervisor exits it is reparented. `detach` returns its process ID, for the
application's own records.

## 9. Process groups

By default a child leads a process group of its own. `terminate`, `kill`,
`send_signal` and the end of supervision signal the whole group, so the
child's ordinary descendants -- the shell's pipeline, a build's compilers,
an agent's tools -- are signalled with it, also after the child itself
exited (while it is unreaped its group's ID cannot be reused, and the group
signal names the group by the leader's kernel object). When supervision
ends, members still running once the leader exited are killed.

What this does not cover:

* a descendant that leaves the group (`setsid`, `setpgid`): it survives the
  group's termination, as the operating system offers no group guarantee
  for it. A process that must contain a whole tree, adversarial
  descendants included, needs a cgroup or a subreaper -- a coordinator's
  facilities, not a library's (the subreaper flag is process-wide: setting
  it inside a library would capture every orphan of every other library);
* a child started with `Group::Shared`: it stays in the supervisor's own
  group, and signals reach the child alone (signalling the group would
  signal the supervisor).

A descendant that inherited the child's stdout or stderr keeps the pipe
open: the stream's end of file comes when the last holder closes it, which
can be long after the child's exit (section 4).

## 10. Threads

A child belongs to the VM that spawned it. Each Botlish-owned thread
(`std::thread`) that supervises processes installs its own loop, driver and
`Processes` context, and its children's pipes and pidfds are watched by its
own epoll instance: a child's exit wakes exactly its VM. A `Child` is not
sendable -- a thread entry taking one is refused at compile time -- and the
adapter refuses a call on another thread's child. Another VM asks the owning
VM to act (std::actor::remote's typed messages).

Concurrent spawns on several threads are safe: every descriptor is
close-on-exec and every child closes everything but its three streams, so
no child inherits another VM's pipe. When a thread ends, the children it
still supervises are killed and reaped (section 7); a child it detached
keeps running.

## 11. Errors

| Error | Raised by | Meaning |
|---|---|---|
| `InvalidCommand {item, reason}` | spawn | the command cannot be started as written; nothing started |
| `LaunchFailed {stage, code}` | spawn | the operating system refused at STAGE with errno CODE; nothing left |
| `Unsupported {reason, code}` | spawn | this process cannot supervise children safely |
| `StaleChild` | every operation on a Child; finish, detach | the identity's owner was released, or its slot reused |
| `StreamClosed {stream}` | read, write | the stream is no pipe, was closed, the child closed its stdin (EPIPE), or the loop shut down |
| `Interrupted` | read, write, wait, wait_until, terminate, finish | interrupt(child) cancelled it, or (waits) the loop shut down |
| `StillRunning` | status | the child has not exited |
| `ProcessFault {reason, code}` | any | a failure of the adapter or the driver, no property of the child |
| `std::event_loop::SchedulerFault` | any that waits | the scheduler's own failure |

Codes are the operating system's errno values, positive.

## 12. Prerequisites, limits and what this release does not do

**Prerequisites.** Linux 5.4 or later (pidfd_open and pidfd readiness: 5.3;
waitid on a pidfd: 5.4), on x86-64; group signals through a pidfd need 6.9
(before it, the group is signalled with kill(-PGID) while the leader is
unreaped, which is as safe). glibc 2.34 or later. A kernel without pidfds is
`Unsupported`, never handled by PID numbers. Do not call `waitpid(-1)` or
ignore SIGCHLD anywhere in a process that uses this package: both reap
children behind its back (the package itself installs no signal handler and
never waits for a child it did not start). To link: `cc` and the C
library's development files.

**Limits.** At most 1,024 unreaped children per process, every VM together
(`LaunchFailed` at `Stage::Limit` beyond); four readiness watches per child
with every stream piped, so about 1,024 children per VM with the driver's
4,096 watches; at most 64 commands being spawned at the same instant. A read
returns at most 64 KiB. The adapter's table is searched linearly at spawn
(1,024 slots: microseconds, beside the spawn's own 0.2 ms); every other
operation finds its child directly.

**Performance** (one 4-core machine; PROCESS-LINUX-PACKAGE-MILESTONE-1.md
has the measurements): a spawn takes about 0.25 ms, an exit reaches its
waiting task in about 0.15 ms, stdout streams at about 2 GiB/s, two idle
children cost the supervisor nothing (no polling), and a released child
that ignores SIGTERM is killed at its grace period.

**Not in this release**, by design or for later:

* no shell and no PATH search (start `/bin/sh` or resolve the path
  yourself);
* no pseudo-terminal children (a program that insists on a terminal);
* no line splitter, JSON-lines or SSE decoder: read chunks and split them;
* no process-wide subreaper and no cgroup containment (section 9);
* no durable supervision: a child's pipes die with its supervisor, and a
  restarted supervisor cannot reattach to a child's streams or learn its
  exit status unless it is the child's subreaper. Jobs that must survive
  their supervisor need a coordinator process that redirects their output to
  files, keeps records (PID, start time, boot id), is their subreaper, and
  serves clients over local IPC -- built with this package, not part of it;
* no macOS or Windows (a portable `std::process` will follow once a second
  platform's implementation exists).
