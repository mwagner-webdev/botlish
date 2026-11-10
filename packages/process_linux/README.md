# process_linux -- supervised child processes for Botlish on Linux

`process_linux` launches external programs, talks to them over their
standard streams, observes how they end, and terminates them, for Botlish
programs on Linux x86-64. Everything is scheduled by the program's own event
loop (`std::event_loop` with the `event_loop_linux` driver): a task that
reads a child's output, writes its input or waits for its exit suspends only
itself, while timers, other children and other libraries' work (an HTTP
client, a terminal interface) keep running.

* **No shell.** A command is an executable path and an exact argument
  vector; a shell is an executable like any other
  (`command("/bin/sh", ["-c", text])`), never implied.
* **Bytes are bytes.** stdout and stderr are read chunk by chunk, stdin is
  written chunk by chunk, as `std::abi::bytes::Bytes`: NUL, invalid UTF-8
  and characters split across chunks arrive exactly as written. Nothing is
  buffered or accumulated for you; a full pipe pushes back on the child.
* **Ownership.** A started child is an owner (`ChildOwner`, a resource) and
  an identity (`Child`). The owner's scope bounds the supervision: when it
  ends -- normally, on an error, or because the task holding it was
  abandoned -- a child that still runs is asked to stop (SIGTERM to its
  process group), given a grace period, then killed (SIGKILL) and reaped, in
  the background. Only `detach` lets a process outlive its owner.
* **Cancellation is not termination.** `interrupt(child)` cancels the
  child's suspended reads, writes and waits and leaves the child running;
  `terminate`, `kill` and `send_signal` are the operating system's side.
* **No PID-reuse hazard.** Every signal goes through the child's pidfd,
  and a child is reaped only once its supervision is over: no operation can
  reach an unrelated process that got a reused PID.
* **Explicit authority.** Starting a process requires the `Processes`
  context, which only the application's entry program installs.

GUIDE.md is the user's guide: commands, streams, exit statuses and errors,
cancellation and termination, ownership and cleanup, detachment, process
groups, threads, prerequisites, limits and performance.

## Installing

With the single-file compiler (`botlish`) and a repository holding the
released artifacts (`process_linux-0.1.0.botpkg`,
`event_loop_linux-0.5.0.botpkg`):

    botlish add process_linux -repository REPO -target linux-x86_64
    botlish add event_loop_linux -repository REPO -target linux-x86_64

The second line is for the program's own use of the driver (it installs
it); the graph holds one `event_loop_linux`, the one `process_linux` locks,
shared with every other package that uses the driver (`http`, for one).

What the host needs to link a program (the system linker: a program that
calls C): a C compiler driver (`cc`) and the C library's development files
(Ubuntu: `gcc`, `libc6-dev`). Nothing is compiled from the package's
sources: the adapter is the package's prebuilt archive.

What the host needs to run one: Linux 5.4 or later (pidfds; 6.9 or later
for group signals through a pidfd, with a safe fallback before it) and
glibc 2.34 or later. A process whose SIGCHLD is ignored cannot supervise
children (its children would be reaped behind its back): every spawn there
is `Unsupported`.

## A first program

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

fn say(text: str, context io: std::linux::io::LinuxIO):
    std::linux::io::write_text(text.append_char('\n')):
        on std::io::WriteFailed:
            unit

# The work: run `ls -l /usr` and count its output, without a shell. Every
# failure is a declared error the caller handles.
fn list_usr(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::linux::io::LinuxIO) -> int errors process_linux::InvalidCommand, process_linux::LaunchFailed, process_linux::Unsupported, process_linux::StaleChild, process_linux::StreamClosed, process_linux::Interrupted, process_linux::ProcessFault, std::event_loop::SchedulerFault:
    {owner, child} = process_linux::spawn(process_linux::command("/bin/ls", ["-l", "/usr"]))
    total = std::mutable_array::create(1, 0)
    loop:
        chunk = child.read(process_linux::Stream::Stdout)
        size = std::abi::bytes::length(chunk).value
        if size == 0:
            break
        total.set(0, total.at(0) + size):
            on IndexNotFound:
                unit
    status = child.wait()
    bytes = total.at(0):
        on IndexNotFound:
            0
    say("ls: ".concat(process_linux::status_text(status)).concat(", ").concat(std::int::to_string(bytes)).concat(" bytes"))
    process_linux::release(owner)
    0

# A task of the loop: the work, its failures reported.
fn task(context p: process_linux::Processes, ev: std::event_loop::Loop, n: event_loop_linux::Native, io: std::linux::io::LinuxIO) -> int errors std::event_loop::TaskFailed, IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault:
    list_usr():
        on process_linux::LaunchFailed {code}:
            say("could not start ls: errno ".concat(std::int::to_string(code)))
            1
        on process_linux::InvalidCommand {item, reason}:
            say(item.concat(": ").concat(reason))
            1
        on process_linux::Unsupported {reason}:
            say(reason)
            1
        on process_linux::StaleChild:
            1
        on process_linux::StreamClosed:
            1
        on process_linux::Interrupted:
            1
        on process_linux::ProcessFault {reason}:
            say(reason)
            1

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

Build and run it:

    botlish -emit-native-executable main.bot
    ./main

`run()` returns once nothing can happen any more: every task has ended and
every released child has been reaped.

## What this release does not do

No shell, no PATH search, no pseudo-terminal children, no line splitter or
JSON-lines decoder (read chunks and split them yourself), no process-wide
subreaper, no cgroup containment, no durable job records (a child dies or is
orphaned with a supervisor that crashes), no macOS or Windows. GUIDE.md,
section 12, says what each means and what to do instead.
