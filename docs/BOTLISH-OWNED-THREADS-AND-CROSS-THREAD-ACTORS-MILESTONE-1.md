# BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md

Botlish-owned OS threads, independent VMs, typed cross-thread actors and
brokered upward calls. M4 of THREAD-ACTOR-ARCHITECTURE-CENSUS.md, a
completion report.

> A worker may request an operation from its owner without becoming its
> owner. The request crosses the thread boundary as a checked value; the
> operation executes under the destination actor's authority; the reply
> returns as another checked value.

Evidence labels, as the census's and M1-M3's:

* **observed**: a run printed it (the command is given);
* **static**: read from the code, or checked by a test that reads it;
* **CI**: a GitHub Actions run on another host;
* **projected**: a design consequence, not built or run here.

Environment: branch `claude/inspiring-davinci-idqbr0` from `main` at
`f2787af`, Linux 6.18.44 x86-64 (4 vCPUs, a shared container), Tcl 9.0.1
(`tclsh9.0`, the Ubuntu 25.04 packages), rustc 1.97.0. Every timed number
is from that one machine. The work is commits `6426bd6` (thread entries,
std::thread, the runtime registry), `310bb35` (event-loop ABI v2),
`bd73137` (the transport, std::actor::remote), `700f602` (the broker
integration), `ae4e289` (the tests, the fixes they found, diagnostics and
Compilerpedia) and the commits after it (mutation harness, benchmark,
documentation).

## Contents

1. [Executive result](#1-executive-result)
2. [Starting architecture](#2-starting-architecture)
3. [Thread-entry language model](#3-thread-entry-language-model)
4. [Context selection and installation](#4-context-selection-and-installation)
5. [Thread lifecycle](#5-thread-lifecycle)
6. [Native runtime integration](#6-native-runtime-integration)
7. [Event-loop ABI v2](#7-event-loop-abi-v2)
8. [Transport](#8-transport)
9. [Remote endpoints](#9-remote-endpoints)
10. [Request/reply](#10-requestreply)
11. [Generic Sendable specialization](#11-generic-sendable-specialization)
12. [Broker context](#12-broker-context)
13. [Exclusive-service integration](#13-exclusive-service-integration)
14. [Actor compatibility](#14-actor-compatibility)
15. [Memory and GC safety](#15-memory-and-gc-safety)
16. [Concurrency correctness](#16-concurrency-correctness)
17. [Backend and platform matrix](#17-backend-and-platform-matrix)
18. [Mutation testing](#18-mutation-testing)
19. [Performance](#19-performance)
20. [Regressions and CI](#20-regressions-and-ci)
21. [Remaining limitations](#21-remaining-limitations)
22. [Next milestone](#22-next-milestone)
23. [Reproducing](#23-reproducing)

## 1. Executive result

Implemented and working on Linux x86-64 (**observed**,
`tclsh9.0 tests/threads.test`, 21 tests):

* **Thread entries.** `thread fn NAME(init: I) -> R:` at a module's top
  level declares an entry; `std::thread::start(std::thread::entry(NAME),
  init)` runs it on a new OS thread in a VM of its own, made on that
  thread from the program's one compiled image. I and R are declared,
  closed, sendable types; init is copied in and the result copied back
  through std::transfer.
* **Per-VM contexts, program-wide selection.** An entry installs its own
  contexts with `with context` statements of its body and never has its
  creator's; each entry's installations are checked flow-sensitively like
  the entry program's; the selection of each context trait is one for the
  whole program (CONTEXT-TRAIT-SELECTION-CONFLICT otherwise).
* **Authority.** Starting needs the installed context std::thread::Threads,
  which restricted injection withholds (CONTEXT-NOT-INJECTED).
* **Lifecycle.** An affine join right (Thread[R]) and an unrestricted
  ThreadId; statuses Starting, Running, Returned, Stopped, Failed,
  StartFailed, Gone; join (ThreadFailed with the entry's error identity and
  message, ThreadStartFailed), bounded await_end, cooperative stop
  (request_stop, stop_requested?, a port wakeup), and at the program's end
  every running thread asked to stop and joined within a bound.
* **The M3 guard limit.** At most 64 guarded threads in a process (the
  main one's included): a start reserves its guard record before the
  thread exists, and beyond it is ThreadLimit -- never an unguarded thread.
  A worker's native stack overflow ends the process (NATIVE LIMIT STACK).
* **Event-loop ABI v2.** The Linux driver keeps one loop per VM in a table
  of 64 generation-checked handles; the version 1 functions reach the one
  open loop and are refused while several are open; a loop closes when its
  program closes the driver or the thread that opened it exits.
* **The transport.** Per-VM ports (an eventfd doorbell its event loop
  watches), bounded endpoints of owned transfer bytes with a schema
  fingerprint check, FIFO per sender, event-driven backpressure (a full
  endpoint's first waiting sender is granted the next free place), no
  polling anywhere.
* **std::actor::remote.** Remote[M] (export an ordinary mailbox), typed
  calls (serve_calls, call, reply) with correlation by call records,
  defined failures (Closed, Stale, Unavailable, TooLarge, TypeMismatch,
  Undelivered, ServiceEnded), capabilities that are sendable, opaque and
  sparse (a random 62-bit key per endpoint and call).
* **Generic Sendable.** TRANSFER-OPEN-TYPE is closed for a variable a
  struct slot constrains to Sendable: such a body is compiled once per
  binding, each copy writing its closed schema. decode of a trait view
  stays TRANSFER-OPEN-TYPE.
* **The broker.** examples/threads/broker: an owner VM holding the
  process's one exclusive device, a device-service actor, two worker VMs
  whose handlers call it through a DeviceBroker context holding only the
  service capability; 480 device operations, none overlapping, every
  call confirmed, also under GC stress.
* **Tcl backends.** interp and compile refuse a program that starts a
  thread at lowering (BACKEND THREAD-UNAVAILABLE); same-thread actors keep
  working there (tests/actor.test unchanged).

Deferred (section 21): an explicit call-cancellation operation, call
timeouts, a non-Linux Doorbell driver (threads themselves run where the
guard runs; the cross-thread transport needs an event loop that can watch
the port), Windows and macOS runtime evidence beyond CI, one function that
is both context-trait-specialized and Sendable-specialized (the trait plan
refuses the combination: TRAIT-INTERNAL), and a bounded join of a worker
VM's own children.

Found and fixed on the way (section 16): a transport deadlock between two
waiting senders, a worker VM's event loop outliving it, and a lowering
crash for every program that imports std::event_loop without installing
its Loop (a pre-existing bug that every thread program would have hit).

## 2. Starting architecture

**static**, from main at `f2787af` and the earlier milestones:

* **M1** (SAME-THREAD-ACTORS-MILESTONE-1.md): std::actor, ordinary Botlish
  over std::event_loop: an actor is one coroutine hosted by a task; its
  receives and sends are requests its host performs, so an actor built
  under `inject no context:` communicates with no context; affine
  Inbox[M], unrestricted Address[M], bounded mailboxes, room waits.
* **M2** (SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md): the intrinsic trait
  Sendable, std::transfer::encode/decode with the schema written into the
  call, two codecs writing the same bytes, decoding that never trusts its
  input; TRANSFER-OPEN-TYPE for any imprint variable.
* **M3** (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md): a Vm owns its context
  area and reads its own program metadata; 64 per-thread guard records;
  `botlish-native vms N` ran several Vms of one program at once -- but no
  Botlish program could start a thread.
* The census (THREAD-ACTOR-ARCHITECTURE-CENSUS.md) fixed the model this
  milestone builds: "a thread is a VM, an actor is a task, a thread entry
  is an entry program", and its Probe G showed copied messages between two
  VMs through the event-loop ABI, whose one static loop state (`E`) was
  the obstacle to a second loop.

What M4 needed, and found missing (**static**): a way to name a second
entry computation of one program image; a runtime that makes a Vm on a
new thread from that image; a thread's own context installations; a
Linux driver with more than one loop; a place for each VM in a transport;
remote mailbox identities that are sendable without being forgeable;
calls with correlation; and a generic transfer for typed transport
helpers (M2's TRANSFER-OPEN-TYPE).

## 3. Thread-entry language model

**Syntax** (surface/parser.tcl's function modifiers; `thread` combines
with no other modifier):

```botlish
# worker.bot -- a module
thread fn crunch(job: Job) -> Answer:
    Answer {label: job.label, value: fib(job.n)}
```

```botlish
# main.bot
import std::thread
import worker

fn run(context t: std::thread::Threads) -> int errors std::thread::ThreadLimit, std::thread::ThreadStartFailed, std::thread::ThreadFailed:
    {thread} = std::thread::start(std::thread::entry(worker::crunch), worker::Job {n: 20, label: "a"})
    std::thread::join(thread).value

with context std::thread::create(4)
run():
    ...
```

**Compilation** (**static**). An entry is an ordinary block of the
program's HIR with a `threadEntry` flag (hir/syntax.tcl's `withThread`,
the HIR text's ` thread` header, hir/read.tcl), so one compilation builds
one HIR, one specialization and one program image holding every entry.
`std::thread::entry(NAME)` is a native whose result shape is `thread-entry`
(core/thread.tcl, hir/types.tcl's ShapeResult): its type is
`std::thread::Entry[I, R]` of the entry's declared types
(hir/threads.tcl's `EntryType`), and natively a constant struct of the
entry's index and name (native/lower.tcl's `ThreadEntryValue`). The
program function's code is, after the module sections, a dispatch on
`threadop rt_entry_index` (native/lower.tcl's `ThreadDispatch`): index 0
runs the entry program's top level; index K decodes the thread's
initialization bytes as I, calls entry K's generic instance and encodes
its result as R. Each entry, and the owner functions its types' transfer
clauses call, are compilation roots like C exports (`-exports`), so their
instances are the open generic ones, never a caller's specialization.

**Static checking** (hir/threads.tcl's `verify`, `Problems`):

| Rule | Diagnostic |
|---|---|
| a module's top-level function, never the entry program's or nested | THREAD-ENTRY-PLACEMENT |
| exactly one declared parameter, a declared result, no flags, context or place parameters, no variadic or resume clause; both types closed and sendable | THREAD-ENTRY-SIGNATURE |
| environment-free (no capture) and never suspending | THREAD-ENTRY-ENVIRONMENT |
| named only as std::thread::entry's argument (never called, never a value), and std::thread::entry given only an entry by name | THREAD-ENTRY-REFERENCE |

Each is observed rejected by tests/threads.test (th-reject-placement,
-entries, -authority) at its exact line. A `static compile:` block
holding a nested `thread fn` or calling an entry is that block's rejection,
with the new DiagnosticCode cases ThreadEntryPlacement and
ThreadEntryReference (th-static-blocks, on interp, compile and cranelift);
the other kinds are classified never-a-block's in tests/static-compile.test's
census (a top-level declaration's; an installation's).

## 4. Context selection and installation

**Implementations are the program's; instances are each VM's.** A context
trait's operations compile to direct calls of the one implementation the
plan selected (TRAITS.md, CONTEXT-TRAITS.md); every VM runs the same
machine code, so a selection per entry would need code per entry. So
hir/contexts.tcl walks each entry's body exactly as the entry program's
top level -- statement by statement, installations growing in order --
and judges every call's obligations against the entry's own
installations (`EntryStatement`, the `entries` side table), while a
selection a later entry makes differently from the program's first is
CONTEXT-TRAIT-SELECTION-CONFLICT (**observed**: th-reject-conflict, two
entries installing the deterministic and the Linux driver).

**A worker never has its creator's contexts.** An entry requires nothing
of a caller (`Requirements` gives it an empty requirement: it is started,
never called), and its calls are its own obligations: a worker reaching
the owner's Device is MISSING-CONTEXT in the worker (**observed**:
th-reject-authority's `rogue`). A context parameter on an entry is
THREAD-ENTRY-SIGNATURE, and a context as an initialization value is not
sendable.

**Instances.** The native context area keeps one layout for every VM:
the slots of every context any entry installs (native/lower.tcl's
`ContextSlots` adds the `entries` installations), each VM's area its own
(M3), filled by its own installations; an installation in an entry's body
lowers in that entry's dispatch branch (`ContextInstallCall`).
**observed**: th-lifecycle's ledger workers see their own Ledger
(owner 7, three notes) while the main VM's stays owner 1 with one note.

Installation inside a branch of an entry's body is
CONTEXT-INSTALLATION-UNSUPPORTED, as at the entry program's top level.

## 5. Thread lifecycle

**API** (stdlib/thread.bot):

| Operation | Needs | Does |
|---|---|---|
| `create(LIMIT)` | -- | the Threads context: at most LIMIT (1..4096) of this VM's threads running at once |
| `start(E, INIT)`, `start_sized(E, INIT, STACK)` | Threads | a thread of entry E (64 MiB stack by default, at least 1 MiB): Started {thread: Thread[R], id: ThreadId}; ThreadLimit, ThreadStartFailed |
| `status(id)` | -- | Starting, Running, Returned, Stopped, Failed, StartFailed, Gone |
| `request_stop(id)`, `stop_requested?()` | -- | the cooperative stop flag, and a wakeup of the thread's port |
| `await_end(id, TIMEOUT_US)` | -- | blocks the calling OS thread until the thread ended or the bound passed |
| `join(thread)` | -- | the entry's value copied into this VM; ThreadFailed {identity, message}, ThreadStartFailed |
| `wait_end(id)`, `wait_stop()` | Loop, Port, Doorbell | the same waits as event-loop tasks: the thread's end, or a stop request, ring the port |
| `capacity()`, `stats()` | -- | free guard records; the process's thread and transport counters |

**Ownership.** Thread[R] is affine (its right is an opaque token holding a
null C pointer, as std::actor's Inbox): one owner collects the outcome;
dropping it detaches the thread (its outcome is dropped when it ends,
counted). ThreadId is unrestricted and only observes or asks.

**Bootstrap** (native/src/runtime/thread.rs's `spawn`, `body`,
`run_entry`), the brief's steps in order: reserve a guard record (or
ThreadLimit); register the thread; start the OS thread; on it install the
guard in the reserved record; make the VM from the program's factory
(statics, constants, an empty context area); set its entry index and
initialization bytes; run the program function, whose dispatch decodes the
bytes and runs the entry (its installations first); publish the outcome --
Returned/Stopped with the result bytes, Failed with the error's identity
(a declared error's canonical name, read from its message) and message,
or StartFailed with the reason the guard or the VM could not be made;
stop and join the VM's own children; close its port; drop the VM; then
mark the thread ended and notify its creator's port.

**Completion and joining.** An outcome stays in the registry until join
collects it (`rt_release` frees the slot). A join of an ended thread also
joins its OS thread (`wait_ended`), so whatever the thread's exit runs --
thread-local destructors, the Linux driver closing the loops it opened --
has run when join returns (**observed**: th-abi-loops' last probe).

**Failures.** A failed entry is ThreadFailed whose identity is the
error's canonical name (`ledger::Refused`, **observed**); a VM panic is
"NATIVE BUG"; an undecodable result is ThreadFailed with the transfer
error's name. A start the operating system refuses is ThreadStartFailed
with its errno.

**Shutdown.** Stopping is cooperative and never forced: the flag, a port
notification (N_STOP), and for a worker on an event loop `wait_stop`.
When the main VM completes, `finish_all` (runtime::aot::run, the driver's
run) asks every registered thread to stop and joins it within
BOTLISH_THREAD_EXIT_JOIN_US (30 s by default); a thread still running is
reported on standard error and the program's image is kept alive (the
process exits with it running) -- never freed under it.

## 6. Native runtime integration

* **One image, many VMs** (**static**). A VmFactory (thread.rs) makes a
  Vm of the running program on the calling thread: for an executable
  `program::instantiate_linked` of its record (the one place a Vm is built
  from a program's descriptor, shared by the three linkers' startups), for
  the JIT the compiled program kept alive. The factory travels in the
  Vm's thread state; a worker's Vm gets it too, so workers start workers.
* **Thread affinity.** A Vm is made, run and dropped on its own thread
  (it is not Send); only byte vectors and atomics cross threads.
* **Guards** (records.rs). `reserve` marks a free record RESERVED for a
  thread that does not exist yet; the new thread claims exactly that
  record (`claim_as`); `free_count` is std::thread::capacity. Every other
  guard rule of M3 is unchanged: per-thread records, handlers that read only
  the faulting thread's record, process-terminal overflow.
* **The runtime op family.** All thread and transport operations are one
  NIR op (`threadop CODE ...`, nir.rs's ThreadOp) and one helper,
  `rt_thread_op`, a member of ops.rs's helper list -- which the linked
  ABI fingerprint reads (`ops::HELPER_SIGNATURES`), so an executable built
  against another runtime is refused. core/thread.tcl is the one table of
  codes; std::thread's and std::actor::remote's internal members give them
  their types.
* **The context area** keeps M3's layout rule; a worker's slots for
  another entry's contexts stay zero and are never read (the obligations
  prove every load).

## 7. Event-loop ABI v2

`packages/event_loop_linux` 0.5.0 (native/botlish_event_loop.h,
`BOTLISH_EVENT_LOOP_ABI 2`):

* **Per-loop state.** The adapter's one static state became a table of 64
  loops (`LOOPS`), each with its own lock, epoll and eventfd, endpoints,
  watches, rotation and pumps. A loop is named by its handle,
  GEN * 64 + INDEX (`loop_of`): a closed loop's handle, or an older loop's
  in a reused entry, names nothing (-EPIPE).
* **Version 2 functions** name their loop: `botlish_event_post2(loop,
  endpoint, ...)`, `_wake2`, `_add_pump2`, `_remove_pump2`;
  `botlish_event_loop()` answers the one open loop's handle.
  event_loop_linux::loop_handle (Native) is what a program hands a library.
* **Compatibility.** The version 1 functions reach the one open loop while
  exactly one is, and are refused (-EPIPE) while several are -- never
  routed to one of them (**observed**: th-abi-loops, a C probe in both
  VMs: 1111 with one loop, 2211 with two, 1112 after the worker ended). A
  single-loop program's libraries keep working unchanged
  (tests/event-loop-linux.test, SDL3 included where built). A package
  whose archive was built against version 1 is not silently mixed with a
  version 2 module: event_loop_linux::create compares the adapter's
  `evl_abi()` with the module's and refuses a mismatch (DriverFault -71)
  before any loop runs; the package's version is 0.5.0 (the event-loop
  examples' and the shared-dependency workloads' locks moved with it).
* **Lifetime.** A loop closes when the program closes the driver
  (`event_loop_linux::close`) or when the thread that opened it exits (a
  pthread key's destructor, `own`): a worker VM's loop ends with its
  thread. Before this, a worker that did not close its driver left its loop
  open for the rest of the process -- its descriptors leaked and every
  version 1 call refused (found by th-abi-loops).
* **Wakeups.** A post signals the loop's eventfd under the loop's lock;
  the loop's reset-then-recheck protocol and the owed wake for pumps are
  M1's, per loop now (audit/event-loop's C mutants, updated to the
  per-loop code, still apply).
* **No migration.** A loop belongs to the VM, and the VM to its thread:
  nothing moves a loop.

## 8. Transport

**Path** (thread.rs's Port, Endpoint, Transport). A sender encodes the
message in its VM (std::transfer: the Sendable type checked statically,
its schema's fingerprint in the bytes), the runtime copies the bytes into
the destination endpoint's queue and notifies its owner port (once per
endpoint until drained); the destination VM's pump task -- an ordinary
task of its event loop, woken by the port's doorbell through the driver
(the context trait std::thread::Doorbell, implemented by
event_loop_linux::Native) -- takes each message, decodes it with its own
constructors and posts it into the actor's mailbox (`post_waiting`: it
waits for room, so a slow actor fills its mailbox, then the endpoint, then
its senders wait). No Botlish heap object, address or VM-local identity
crosses: a message is an owned `Vec<u8>`.

**Type validation.** Statically by the capability's type (Remote[M]
admits M only); at the transport by the fingerprint, bytes 5..13 of the
message against the endpoint's (TypeMismatch, never a delivery:
**observed** th-endpoints); at the receiver by M2's decoder, which never
trusts its input.

**Ordering.** FIFO per sender per endpoint: one queue, appended under the
transport's lock (**observed**: 4000 notes from four producers, each
sender's in order, th-transport).

**Bounds and backpressure.** An endpoint holds at most CAPACITY messages
and 256 MiB; a message is at most 64 MiB (TooLarge). A send beyond is
Full; `deliver` (a task's) and `call` (an actor's) wait instead: a Full
refusal registers the sender's port and token; each place freed is
*granted* to the first waiting sender and announced on its port (N_ROOM),
and its retry takes it while everyone else -- a later waiter, a sender
that did not wait -- is refused (`Endpoint::grant`, `fits`). **observed**:
th-backpressure, two waiting producers into an endpoint of 4 and a slow
mailbox of 2: every note arrives with at most one refusal per note
(a polling sender is refused thousands of times: the deliver-polls
mutant). The first version refused a woken waiter whenever another waited
behind it, which deadlocked two waiting senders once the queue drained
(found by th-transport, fixed, and pinned by
`freed_places_are_granted_in_order`).

**Locking.** One mutex guards the transport's tables, held for an
enqueue, a take, a completion; never while Botlish code runs, decodes or
encodes (encoding is before the send, decoding after the take).

## 9. Remote endpoints

* **Static types.** Remote[M satisfies Sendable], Service[Q, R],
  Reply[R]: opaque structs of a std::actor::remote::Identity {domain, id,
  key} (Words: integers that fit a context slot, so a broker context holds
  one).
* **Identity.** domain: the process's random identity (another process's
  capability is Unavailable); id: slot and generation; key: a random 62-bit
  word drawn at open. An identity no endpoint gave out names nothing
  (Stale), a closed endpoint's is Closed until its slot is reused, then
  Stale (**observed** th-endpoints; `endpoints_are_named_by_domain_
  generation_and_key`).
* **Sendable, not forgeable.** Each type's `sendable through(OUT, IN) as
  Identity` clause copies the identity; IN, which rebuilds a capability
  from an Identity, is an internal member of the standard library
  (core/transfer.tcl), so a program cannot build one (INTERNAL-NAMESPACE:
  th-reject-forgery) or construct the opaque struct (OPAQUE-CONSTRUCTION).
  Retyping through a copy is refused by the fingerprint, and Identity bytes
  do not decode as a capability (TransferTypeMismatch).
* **The M2 compatibility issue** (the brief's section 10) is resolved by
  its first option: a transport-owned capability whose representation is
  validated by the transport (domain, generation, key) with explicit
  Unavailable semantics; the copy is ordinary M2 transfer of the identity.
* **Local addresses stay local.** std::actor::Address[M] is not sendable
  (NOT-SENDABLE: th-reject-authority), and Remote[Address[...]] is no
  type (TRAIT-NOT-SATISFIED).
* **Closure.** `close(remote)` closes the endpoint: queued messages are
  dropped and counted (Undelivered for calls), waiting senders woken (their
  retry is Closed); a VM's port closing closes its endpoints.

## 10. Request/reply

* **Correlation.** `rt_request` makes a call record (slot, generation,
  key) whose reply endpoint is the caller's own; the service receives the
  call's body and a Reply[R]; `reply` completes the record once and queues
  the response on the recorded reply endpoint, notified like a message.
  A response is matched to the waiting call by its id
  (`call`'s loop over the caller's responses).
* **Coroutine-aware waiting.** `call` is an actor's request: the actor is
  suspended -- its host task parked, its thread's loop free -- until the
  response arrives (**static**: call yields to its host, which waits on the
  caller's reply mailbox; nothing in the path blocks the OS thread).
  **observed**: a broker worker's loop runs four actors at once -- two
  handlers with calls outstanding, a ticker sleeping on timers and a
  joiner -- and all of them finish (th-broker).
* **Errors.** CallFailed {reason}: Closed, Stale, Unavailable, TooLarge,
  TypeMismatch; Undelivered when the service's endpoint closed with the
  request queued; ServiceEnded when the service's VM ended owing the
  answer (its port's owed calls are completed then). **observed**:
  th-calls -- one answered, one Undelivered, two ServiceEnded, none left
  waiting.
* **Duplicates and lateness.** A call completes once; a second answer, an
  answer by a reused slot's old id, or an answer to a caller whose reply
  route closed is Stale and reaches nobody (`calls_complete_once`;
  stats().stale_replies counts them).
* **Cancellation.** There is no explicit cancel operation in this
  milestone: a call is cancelled when its caller's reply route closes (its
  actor ended), and a later answer is Stale. The runtime's rt_cancel
  (code 28) exists for a later API and is unused.

## 11. Generic Sendable specialization

M2's TRANSFER-OPEN-TYPE is closed exactly where the transport needed it
(hir/traits.tcl's `SelectingBinding`, `SendsVariable`;
hir/types.tcl's `IsClosedType ... specialized`; hir/range.tcl's
`VerifySending`): a function whose transfer is of an imprint variable that
a struct slot constrains to Sendable is planned like a trait-polymorphic
function -- one clone per binding of that variable -- so each clone's
transfer is of a closed type and writes its closed schema. No run-time
schema, no `any`. `std::transfer::fingerprint[T]()` (internal) gives a
generic export its endpoint's fingerprint the same way.

**observed** (tests/sendability.test's `sd-open-type`, rewritten): a
generic `seal(e: Envelope[T])` writes exactly the bytes of the caller's
closed type on interp, compile and cranelift. decode of a trait view
(`decode[Sendable]`) stays TRANSFER-OPEN-TYPE (`sd-decode-trait-view`,
Compilerpedia's error.transfer-open-type).

Limitation (**observed** while building std::actor::remote): one function
cannot be both specialized for a context trait's selection and per binding
of a Sendable variable (the trait plan reports TRAIT-INTERNAL "no imprinted
binding"). So the generic remote operations require only struct contexts
(Loop, Actors, Port), never the Doorbell trait, and a VM serves its port
once with std::thread::serve.

## 12. Broker context

The upward-call API is an ordinary context of the application's own:

```botlish
# broker.bot
context struct DeviceBroker:
    service: std::actor::remote::Service[DeviceOp, DeviceReply]

fn read_device(addr: int, c: std::actor::remote::Caller[DeviceReply], context b: DeviceBroker, resume std::actor::Answer) -> DeviceReply errors std::actor::remote::CallFailed, std::actor::Closed:
    std::actor::remote::call(b.service, DeviceOp {kind: 0, addr: addr, value: 0}, c)
```

**Authority contract** (**static**, checked by the compiler and pinned by
th-requirements and th-reject-authority):

* a worker installs a DeviceBroker of the service capability it received
  as its initialization value -- never the owner's Device, its handle or
  its context (a context is not sendable);
* broker operations require DeviceBroker only; a handler actor gets it by
  injection, and an actor allowed only the loop cannot ask
  (CONTEXT-NOT-INJECTED);
* the operation runs in the owner's VM, under the owner's Device, inside
  the owner's device-service actor: the call carries a value there and a
  value back, never code and never authority;
* no new language mechanism: the broker is a context struct, the service
  an exported mailbox, the call std::actor::remote::call.

## 13. Exclusive-service integration

`examples/threads/broker` (build.sh, then `main.tcl run main.bot`):

* **owner** (main.bot): acquires the process's one device
  (native/device.c: a second acquirer, in any VM, is refused), opens its
  service, starts the device-service actor (one call at a time; each
  operation suspends inside its device bracket, so an overlap would show
  in the device's own counters), starts two workers with the service in
  their initialization values, and a supervisor task that waits for both
  workers (`wait_end`), then closes the service and the port;
* **workers** (worker.bot): each installs its own loop, Linux driver,
  actors, port and DeviceBroker; two handler actors make 60 writes and
  read-backs each through the broker; a ticker sleeps 20 times meanwhile;
  a joiner collects the reports, sends the summary home and stops the loop.

**observed** (th-broker; also th-broker-gc-stress): first acquire true,
second false; per worker 240 calls, 120 confirmed read-backs, 0 failures,
20 ticks; the device saw 480 operations, 0 overlaps, the owner holding it
throughout. Shutdown accounting: both workers joined, the service closed,
the ports closed, every actor's outcome reaped.

## 14. Actor compatibility

std::actor's same-VM semantics are unchanged (**observed**:
tests/actor.test on both passes). The one addition is `post_waiting` (a
task's post that waits for room), which the pump uses; same-VM messages
stay ordinary values (never required Sendable); std::actor::Address stays
unsendable; no second scheduler exists: remote messages arrive in the
destination actor's ordinary mailbox through an ordinary task.

## 15. Memory and GC safety

* **Independent heaps.** Each VM's collector walks only its own thread's
  stack and heap (M3); nothing of one heap is referenced by another: the
  transport holds byte vectors, the registry outcomes as byte vectors and
  strings.
* **Transport buffers** are owned by the transport from the send until
  the take; the receiving VM decodes from its own Bytes copy; a closing
  endpoint drops its queue (counted: stats().undelivered).
* **GC stress** (**observed**): th-lifecycle-gc-stress (64 VMs, each
  collecting at every allocation site), th-transport-gc-stress (5 VMs),
  th-broker-gc-stress (3 VMs).
* **Poisoning and ownership checks** are M3's test hooks
  (`botlish-native vms`), unchanged; the thread runtime adds no shared
  heap object to check.

## 16. Concurrency correctness

* **No lost wakeup.** A port producer pushes then rings; the consumer
  resets the doorbell before its last look (`port_take`); a notification
  between the two rings again (`port_notifications_are_never_lost`).
* **Backpressure without deadlock or overtaking** (section 8;
  `freed_places_are_granted_in_order`, th-backpressure).
* **Shutdown races.** A call completes exactly once whichever comes
  first -- the reply, the endpoint's close, the service VM's end
  (th-calls; `calls_complete_once`); a stop request before a worker's port
  exists is delivered when it opens (`port_of`); a thread's end before its
  creator served its port is delivered then too.
* **Lifetimes.** A join sees the ended thread's exit done (section 5); a
  loop handle names nothing after its thread exits (th-abi-loops).
* **Found and fixed:** the waiting-senders deadlock (section 8); the
  worker loop that outlived its VM (section 7); and every program
  importing std::event_loop without installing its Loop failed native
  lowering ("context load ... which the program does not install (NATIVE
  BUG)", reproduced on main at `f2787af` with `import std::event_loop` and
  `1`): a resource's cleanup is a root of the program whatever it
  releases, and a cleanup whose context no region installs is now
  unreachable code (native/lower.tcl's `InCleanup`), since every release
  point is charged its cleanup's requirement.

## 17. Backend and platform matrix

| Host | Threads (lifecycle, limit, overflow) | Transport, remote actors, ABI v2, broker | Evidence |
|---|---|---|---|
| Linux x86-64 | runs | runs | **observed** (this machine) |
| Linux AArch64 | expected to run (same code, the AArch64 guard) | expected to run | **CI** pending (tests-arm64.yml) |
| macOS AArch64 | expected to run (the guard's macOS discovery) | needs a Doorbell driver: event_loop_linux is Linux's | **CI** pending (macos-arm64.yml) |
| Windows x86-64 | expected to run (the guard's Windows records) | refused: no doorbell (port open fails, -2 - ENOSYS) | **CI** pending (windows-x86_64.yml) |
| interp, compile | refused at lowering (BACKEND THREAD-UNAVAILABLE) | the runtime operations refuse when reached | **observed** th-tcl-refusal |

tests/threads.test gates its lifecycle tests on the host's stack guard and
JIT (`botlishThreads`) and its transport tests on Linux with C calls
(`threadTransport`); the macOS and Windows rows are what the CI runs
record (section 20).

## 18. Mutation testing

audit/threads/tools/mutate.tcl (29 mutants in
audit/threads/tools/mutants.txt, each with its named detector: a
threads.test test or a Rust unit test), in a private copy of the
checkout whose native backend each Rust mutant rebuilds. Layers: lifecycle
and the guard (an unguarded start beyond the records, a start ignoring its
authority's limit, a stop flag never set, a failed entry reported
returned); endpoint identity (key, generation and schema checks, close,
the internal rebuild, an unconstrained Remote); backpressure (a woken
waiter refused in line, a grant not held, a polling deliver, a pump that
drops on a full mailbox); delivery (a silent doorbell, a message
delivered twice); calls (owed and queued calls forgotten, a second
answer, a reused call slot); the ABI (version 1 routed to the first of
several loops, a worker's loop left open); the compiler (entry calls,
entry sendability, entry obligations and requirements, the selection
conflict, branch installations, the Tcl refusal).

The brief's defects that no small edit expresses (moving a Vm between
threads, enqueuing a heap pointer, freeing a buffer early: the types
refuse them), or that other harnesses already kill (a shared context area,
the wrong VM's metadata, a dropped wakeup between check and wait), are
listed with their defenses in mutants.txt's header.

Results: section 20's table.

## 19. Performance

`tclsh9.0 bench/threads.tcl -runs 3` (bench/threads/main.bot; times
per operation, best and worst of three processes): see the table below,
filled from that run.

## 20. Regressions and CI

Filled from the runs (below).

## 21. Remaining limitations

* **Transport-domain scope.** A capability names an endpoint of this
  process's transport; another process's is Unavailable. No distributed
  or cross-process actors, and the bytes are no stable network format.
* **Cancellation and timeouts.** No explicit cancel and no call timeout:
  a caller that wants a bound runs a timer beside its call in another
  actor. rt_cancel is unused.
* **Platforms.** The transport needs an event loop that watches a
  descriptor: today only event_loop_linux implements std::thread::Doorbell.
  macOS (kqueue) and Windows (an IOCP or event handle doorbell) drivers
  are future work; threads without the transport run wherever the guard
  does (CI to confirm).
* **Specialization combination.** A function cannot be both
  context-trait-specialized and Sendable-specialized (section 11).
* **Limits.** 64 guarded threads per process (M3's table); a worker's
  stack reserves 64 MiB of address space by default (start_sized), plus
  each actor's two coroutine stacks; a Threads authority at most 4096; an
  endpoint at most 256 MiB queued, a message 64 MiB. For mobile and
  embedded hosts the 64 MiB default and the per-actor stacks are the
  numbers to lower.
* **Joining children.** A worker VM that ends with running children asks
  them to stop and joins them without a bound.
* **Stop is cooperative.** A worker that never reads stop_requested? or
  waits on its port runs until the program's end, which then waits 30 s
  and exits with it running.
* **Method resolution** (pre-existing, found by the benchmark): with both
  std::actor and std::actor::remote imported, `remote.send(m)` on a
  Remote resolves to std::actor::send and fails IMPRINT instead of
  selecting std::actor::remote::send; the qualified call works.
* **Native faults** stay process-terminal: a worker's stack overflow ends
  the process (th-overflow), as memory corruption would.

## 22. Next milestone

* **Embedding.** A host application (React Native's JavaScript thread, a
  GUI main thread, ASP.NET) that owns its threads needs a Botlish VM made
  on a host thread and driven by the host's loop: a Doorbell
  implementation over the host's loop, and a native-library entry that
  starts a VM of an entry on the calling thread rather than a new one.
* **Mobile.** A smaller default stack and per-actor stacks; a Doorbell
  for kqueue (iOS, macOS) and ALooper (Android).
* **Supervision.** Restart policies and supervision trees over
  wait_end, ThreadFailed and ServiceEnded; call timeouts and an explicit
  cancel.
* **Transport.** A doorbell per platform; a multi-producer queue to
  replace the one transport mutex if contention measurements call for it.

## 23. Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/threads.test
tclsh9.0 audit/threads/tools/mutate.tcl
tclsh9.0 bench/threads.tcl -runs 3
```
