# SAME-THREAD-ACTORS-MILESTONE-1.md

Typed actors over `std::event_loop`, with explicitly restricted authority.

> An actor owns its state and receives messages through explicitly granted
> capabilities. Its authority comes from the contexts injected when its
> computation is constructed, not from the contexts installed in its
> containing application or possessed by its supervisor.

```botlish
s = inject no context:                         # the actor's authority: none
    coroutine {step, first} = calculator(work_inbox)
    std::actor::spawned(step, first)
s.start()                                       # the scheduler's authority
std::actor::post(work, Work {n: 7, reply: replies})
std::event_loop::run()
```

```botlish
fn calculator(inbox: std::actor::Inbox[Work]) -> std::actor::Exit:
    rx = inbox.listen():                        # no context
        on std::actor::Closed:
            return std::actor::exit(-1)
    served = fold with intermediate k 0:
        w = rx.receive():                       # no context
            on std::actor::Closed:
                break
        w.reply.send(w.n * w.n)                 # no context
        k + 1
    std::actor::exit(served)
```

This milestone makes same-thread actors an ordinary standard-library
module, `std::actor`, over the existing coroutines and `std::event_loop`. A
calculation actor constructed inside `inject no context:` -- in an
application that has installed a network, a storage, a clock, the event loop
and the mailbox administration -- receives typed messages and replies, and
the compiler's own context-requirement analysis proves it needs nothing to
do so.

## Contents

1. Executive result
2. Starting state
3. Architecture
4. Context-free communication
5. Public API
6. Affine receive ownership
7. Message semantics
8. Mailbox behavior
9. Actor lifecycle
10. Restricted injection
11. Scheduler compatibility
12. Backend results
13. GC and resource correctness
14. Mutation testing
15. Performance
16. Documentation and compatibility
17. Next milestones
18. Files, and what to run when changing this

---

## 1. Executive result

**Implemented.**

* **`std::actor`** (`stdlib/actor.bot`), ordinary Botlish over
  `std::event_loop`: typed mailboxes in an application-installed context
  (`std::actor::Actors`), unrestricted send-only `Address[M]`, affine
  `Inbox[M]` receive rights, `Receiver[M]` (what an actor receives through
  once it has listened), and `open`, `listen`, `receive`, `try_receive`,
  `send`, `deliver` (a send that waits for room), `pause`, `sleep`,
  `spawned`, `start`, `post`, `close`, `drain`, `queued`, `reap`, `stats`,
  `exit`.
* **Context-free communication.** `listen`, `receive`, `try_receive`,
  `send`, `deliver` and `pause` require no context. They are requests an
  actor's coroutine yields to its *host*, a task `start` adopts into the
  loop beside it, which performs them with the Loop and the mailbox table
  and resumes the actor with the answer (section 4). The scheduler's
  authority stays the host's; the actor holds none of it.
* **The acceptance.** One application, one thread, one VM, one heap, one
  `std::event_loop`, the same installed implementations: a privileged
  supervisor actor (Network, Storage, Clock, Loop, Actors), a Storage-only
  archivist and a contextless calculator. The calculator answers its own
  work and asks the supervisor -- through an address delegated in each
  message -- to perform the one privileged operation it cannot
  (`tests/actor/authority.bot`). Every forbidden operation, put into the
  same program with every context still installed, is CONTEXT-NOT-INJECTED
  at the inject boundary (17 variants), and laundering a privileged
  coroutine into an actor is CONTEXT-RETAINED-AUTHORITY (section 10).
* **Ownership and identity.** The receive right is affine; `listen`
  consumes it and binds the mailbox to the actor's task for good. Addresses
  are typed, opaque and generation-checked: a closed mailbox answers
  Closed, a reused slot's old address Stale, and nothing reaches a
  replacement (section 6, 7).
* **Bounded mailboxes, event-driven room waits.** A full mailbox answers
  Full and drops nothing; `deliver` waits on the mailbox's room channel,
  each freed place wakes one waiting sender, first come first served, and
  no timer is ever involved (section 8).
* **Lifecycle.** A host closes its actor's mailboxes the moment the actor
  returns or fails (queued messages counted undelivered, senders waiting
  for room woken with Closed) and ends its task with the actor's outcome;
  `reap` closes what a shutdown abandoned. Nobody has to read a diagnostics
  list for a mailbox to close (section 9).
* **All four backends**, one trace each, for nine scenario programs, also
  under `BOTLISH_NATIVE_GC_STRESS=1` (section 12, 13). 67 tests; 23 of 23
  mutants killed by a named detector (section 14).
* **Cost.** Natively a message costs 2.3 µs, about 1.2 µs over a bare
  event-loop channel (Probe F's postbox: 0.7 µs over); the difference is
  the host's two coroutine switches per request. Restriction itself costs
  nothing at run time. An idle actor reserves two coroutine stacks (section
  15).

**One compiler-side addition**, and why it is the smallest sound one
(section 4.3): the internal intrinsic `std::actor::recover[M](x)`, the
identity on every backend (`core/actor.tcl`; natively no NIR operation),
which the library calls exactly once, after checking that a message carries
the identity of the receiver's own mailbox. Everything else is ordinary
Botlish, plus one event-loop query, `std::event_loop::owned?(task)`
(section 9.4). No native, NIR instruction, runtime object, scheduler,
permission table or context-installation rule was added.

**Not implemented** (the brief's non-goals): OS threads, cross-thread
messaging, sendability, serialization, actor migration, preemption, actor-
local installation or selection, runtime permission checks, supervision
trees, selective receive, futures.

## 2. Starting state

* **THREAD-ACTOR-ARCHITECTURE-CENSUS.md** concluded "a thread is a VM, an
  actor is a task" and built Probe A (`audit/thread-actor/probe-a/`):
  typed `Postbox[M]` tables held as fields of an application context,
  generation-checked addresses, FIFO delivery over Reliable channels. Two
  things were conventions: a receive right had one holder, and a failed
  actor's mailbox closed. Every actor also required the Loop and the
  application's `Mail` context to receive.
* **RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md** added `inject context
  ...:` and `inject no context:` -- a computation uses exactly the contexts
  it lists, checked transitively and across coroutine handles -- and named
  what `std::actor` still needed (its section 16): "an inbox capability
  that is not the Loop".
* **EVENT-LOOP-MILESTONE-1.md** froze the four-phase turn, fairness,
  liveness, Delivery policies, revocation and outcomes. A task is a
  `Coroutine{args: [], return: int, ...}`; `wait(reg)` yields the slot and
  reads the wake from the Loop's registers, so waiting requires the Loop.

## 3. Architecture

```
 one thread, one VM, one heap
 ┌────────────────────────────────────────────────────────────────────────┐
 │ installed (entry program): Loop, Driver, Actors, Network, Storage, ... │
 │                                                                        │
 │ std::event_loop: the turn (wait, collect, dispatch, observe)           │
 │   task: host(calculator) ── resumes ──> calculator coroutine           │
 │          │  answers                       (inject no context:          │
 │          │  <── yields requests ──        listen/receive/send/deliver) │
 │          └─ Actors (mailbox table), Loop (channels, waits)             │
 │   task: host(archivist)  ── resumes ──> archivist (Storage)            │
 │   task: host(supervisor) ── resumes ──> supervisor (everything)        │
 │   task: an ordinary coroutine (adopted directly)                       │
 └────────────────────────────────────────────────────────────────────────┘
```

| owner | owns |
|---|---|
| the application (installed contexts) | `Actors`: every mailbox's row, its queue, its two channels (the receiver's wake, the senders' room); the actor records. The Loop and the driver, as before. |
| an actor | its coroutine: its private state (locals, fold intermediates, child coroutines); the receive rights it listened to |
| a host (a loop task) | the actor's coroutine, moved in by `start`; nothing else -- it is std::actor's code, resumed by the loop |
| `std::event_loop` | the hosts (adopted tasks), the channels, the turn, every scheduling decision |

**Authority** is construction's: the actor's code may use what its
construction's inject block (or constructor) had. **Scheduling** is the
loop's: hosts are ordinary tasks. **Memory** is shared by value semantics:
two actors never alias. **Parallelism** is not supplied: actors on one
thread are cooperative.

## 4. Context-free communication

### 4.1 The constraint

A computation constructed inside `inject no context:` can use no installed
context, transitively. Its only shared mutable state would be a context
(Botlish has no references, and MutableVector, MutableArray and MutableMap
are values). So the only channel between such a computation and anything
else is its own coroutine protocol: what it yields and what it is resumed
with. Receiving and sending must therefore be requests a contextless actor
yields to whoever resumes it, and that resumer must hold the mailboxes.

### 4.2 The alternatives the brief listed

| | what it would take | verdict |
|---|---|---|
| **A. Narrow value capabilities** (`wait` on an opaque endpoint without the Loop) | `wait`'s yield is context-free already, but the wake's data is read from the Loop's registers; delivering it without the Loop means resuming tasks with a message, which changes every task's protocol (`Coroutine{args: [], ...}`) and still carries two Ints, never a typed payload | not sufficient alone: typed payloads still need a resumer that can reach them |
| **B. Scheduler-mediated coroutine messages** | the actor yields its requests to a host task and is resumed with the answers; the host holds the Loop and the mailboxes | **selected** |
| **C. A context trait** (inject only "receive from my inbox") | the acceptance is `inject no context:`; a trait injected is still a context | rejected by the brief, and unnecessary |

### 4.3 What the language allowed, and the one addition

B needs a host that is generic in the message type. The experiments
(`audit/actor/experiments/`, each rejected as its README states) found
every typed route closed:

| what was tried | result |
|---|---|
| a generic resume protocol, `fn recv(resume Delivery[M]) -> M` | `unknown or invalid resume type Delivery[M]`: a resume clause names a declared struct type, never an imprint variable (COROUTINES.md, points 10-13) |
| a library host coroutine holding the application's typed postbox, `coroutine ... = host(mail.ints)` with `place b: Box[M]` | MUTABLE-PLACE-RECEIVER: a coroutine's arguments are captured, and a place cannot be |
| a typed postbox in a library context | a context struct takes no type slots (`hir/structs.tcl`) |
| an erased payload recovered as M: `fn unwrap(b: Box[M]) -> M: b.payload` (`payload: any`) | TYPE: "function result does not prove declared type M"; also as an argument, also for a concrete struct (`argument ... cannot be proven to satisfy Pt (argument type: any)`) |

The checker is right to refuse all four: an `any` carries no proof of its
type. So a *generic* library that mediates typed messages for contextless
actors must pass them through the non-generic parts (the mailbox table, the
protocol) as `any` and needs one way back. That way back is the one
addition:

```tcl
core::native::register std::actor::recover -arity 1 -impl core::actor::recover \
    -param-types {any} -result-type any -context-free 1 -nomethod 1 \
    -ownership {move} -imprint {vars {T} params {any} result {imprint T}}
core::native::declareInternalMember std::actor::recover
```

* It is the identity at run time (Tcl: `return $x`; natively the operand's
  register, `same` in `native/lower.tcl`): it converts and checks nothing.
* It is internal: a program naming it is INTERNAL-NAMESPACE
  (`reject-recover-internal.bot`).
* It has one caller, `recovered` (`stdlib/actor.bot`), which uses it only
  after checking that the answer carries the slot and generation of the
  very mailbox whose `Receiver[M]` it holds:

  ```botlish
  private nomethod fn recovered(rx: Receiver[M], a: Answer) -> M errors Closed:
      if a.status != a_message or a.slot != rx.slot or a.gen != rx.gen:
          fail Closed
      std::actor::recover[M](a.payload)
  ```

* **Why the value is an M.** Every value queued under a mailbox's identity
  was put there by `send`, `deliver` or `post` with an `Address[M]` of that
  mailbox, and the send's own argument check proved it an M at the sender.
  `open[M]` makes the Address and the Inbox of one mailbox with one M, both
  opaque (unforgeable), and a reused slot gets a new generation, so no
  identity names two mailboxes. `actor-source-recover` pins the single,
  guarded call; the mutant `recover-unguarded` removes the guard and is
  killed by it.
* **Why not a typed alternative.** Making resume protocols generic (the
  first row) would fix the receive side only: a coroutine has one outward
  type, so a contextless actor could then send exactly one message type --
  the calculator of section 10, which sends Results and Requests, could not
  exist -- and the host would still have no typed storage to read from. A
  general dynamic type check is impossible without run-time types
  (applications of a parameterized struct share one representation, a
  `Fn` contract is not observable). The keyed identity is the narrowest
  sound recovery available.

### 4.4 Why it grants no broader authority

* The actor-side functions require no context; the compiler computes it
  (`actor-authority-requirements`: `hir::contexts::required` of `listen`,
  `receive`, `try_receive`, `send`, `deliver`, `pause`, `exit`, `spawned`
  and of the calculator is empty).
* What a request can do is fixed by the host: receive from the actor's own
  bound mailboxes, send to an address the actor holds, yield a turn. A
  request is an opaque `Exit` value: an actor cannot forge one
  (`reject-forge-request.bot`), so it cannot ask its host to open, close,
  register, revoke, adopt, read a clock or touch another actor's mailbox.
* `sleep` needs a timer, which is the scheduler's: it requires the Loop.
  A contextless actor cannot sleep (`actor-authority-calc-actor-sleep`).
* A request the actor yields is answered by its own host only, and the
  host serves receives only from mailboxes its actor listened to: a copied
  `Receiver` receives nothing elsewhere (`actor-identity`).

## 5. Public API

```
std::actor::create() -> Actors                                (install it)

# the administration: Loop + Actors
nomethod fn open(capacity) -> Opened[M]        open[Work](8): {to: Address[M], inbox: Inbox[M]}
fn start(a: Spawned) -> int                    the host task's id (adopt's)
nomethod fn post(to, m) -> Sent                a send from code that is no actor
nomethod fn close(to) -> int                   the administration's stop; undelivered count
nomethod fn drain(inbox) -> List[M]            the queue, and the mailbox closed (top level)
nomethod fn queued(to) -> int
fn reap() -> int                               after a shutdown: abandoned actors' mailboxes
fn stats() -> Stats

# in an actor: no context
fn listen(inbox: Inbox[M]) -> Receiver[M] errors Closed
fn receive(rx: Receiver[M]) -> M errors Closed
fn try_receive(rx: Receiver[M]) -> List[M] errors Closed       one or none
fn send(to: Address[M], m: M) -> Sent                          Delivered, Full, Closed, Stale
fn deliver(to: Address[M], m: M) -> Sent                       waits while Full
fn pause()                                                     the next turn
nomethod fn sleep(delay)                                       requires the Loop
nomethod fn exit(value: int) -> Exit                           an actor's last expression

nomethod fn spawned(step, first) -> Spawned                    no context: out of the inject block
```

`Sent` is `Delivered | Full | Closed | Stale`; the module's error is
`std::actor::Closed`. An actor function's result type is `std::actor::Exit`
(its yields and its return share the outward type: COROUTINES.md point
19). Its errors are an event-loop task's: `std::event_loop::TaskFailed`,
`IndexNotFound`. `tests/actor/*.bot` and `concept.actors` are the
representative programs; `tests/actor/authority.bot` is the brief's
scenario.

**Departures from the brief's provisional list.** There is no `Postbox[M]`
type: a context struct takes no type slots and a library cannot hold the
application's postbox (section 4.3), so the typed storage is one
library context, `Actors`, typed at its interface. `close` takes an
Address (the administration's stop, and the cleanup after a failed
construction), and the top level receives with `drain`.

## 6. Affine receive ownership

* `Inbox[M]` holds an opaque, private token whose one field is a null C
  pointer -- `std::io::fs::Owner`'s device (AFFINE-VALUES.md: a struct is
  affine when it holds an affine value). No compiler change was needed.
* `listen` consumes the Inbox: a second listen, a second actor given the
  same Inbox, a second `drain` are rejected (`reject-listen-twice.bot`
  USE-AFTER-MOVE, `reject-copy-inbox.bot` AFFINE-NOT-DEFINITELY-LIVE,
  `reject-drain-twice.bot` USE-AFTER-MOVE). (`reject-copy-inbox.bot` is
  USE-AFTER-MOVE since PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md: the
  ownership analysis takes an inject block, `if true:`, as run, so the
  Inbox moved into the first actor is definitely moved for the second.)
* An Inbox cannot be made from an Address (`listen(address)` is IMPRINT),
  forged (OPAQUE-CONSTRUCTION) or read apart (OPAQUE-REPRESENTATION).
* `listen` binds the mailbox to the actor's task for good; a host serves a
  receive only for its own actor's bound mailboxes, so a `Receiver` copied
  into another actor receives nothing there (Closed) while the owner gets
  everything (`actor-identity`; mutant `receiver-not-bound`).
* **A replayed listen.** An actor's first value (its first request) is an
  ordinary copyable value, so a supervisor can start actor Y with X's first
  request, a `listen` of X's mailbox. Y's host then binds X's mailbox to Y;
  X's own listen of it is refused (Closed), Y receives nothing through its
  own Receiver (Closed: its own listen was never performed), and X's
  mailbox closes with Y. A mailbox is bound once, and nobody reads another's
  messages (`actor-replay`; mutant `rebind-allowed`). More generally,
  `spawned` does not check that its two arguments belong together: a
  mismatched pair makes the host perform the other actor's first request.
  A listen binds once (above), a receive is served only from the host's own
  actor's bound mailboxes, and a send or deliver sends that request's
  message to that request's address again -- a duplicate the code holding
  both values could cause, since it holds the Actors that `start` requires,
  never a read of the message (an `Exit` is opaque) or a send to an
  address nobody gave it: a first request precedes every receive, so its
  address came from the actor's construction.
* **Dropping** an Inbox runs nothing (an affine release runs no code). A
  mailbox whose Inbox was dropped before any actor listened -- e.g. moved
  into a construction that failed -- stays open until the administration
  closes it by address (`actor-lifecycle-construction`) or a shutdown and
  `reap` close it.
* An affine *message* is out of scope: no message of an affine type ever
  crosses a mailbox -- `post`, `send`, `deliver` and `receive` hold values
  of M, so M is never imprinted affine there (`reject-affine-message.bot`,
  IMPRINT at the post). `open[Coroutine{...}]` itself imprints since
  WRITTEN-AFFINE-APPLICATIONS-MILESTONE-1.md: an Address and an Inbox hold
  no message, so open's M stands where no value of it exists (it used to be
  refused there, when every argument of an application counted as a value
  position).

## 7. Message semantics

* **Typing.** `send(to: Address[M], m: M)`: the message is checked against
  M at the call (`reject-wrong-type.bot`, TYPE).
* **Values.** A send is a logical copy: a message holding a MutableVector, a
  MutableArray and a MutableMap is the sender's value at the send, and
  neither side's later mutation reaches the other (`actor-values-snapshot`,
  Probe C's scenario, all backends and GC stress).
* **Order.** FIFO per mailbox; several senders' messages interleave in
  dispatch order, each sender's in its own order (`actor-identity`).
* **Identity.** (slot, generation). A close keeps the generation: sends are
  Closed. A reuse bumps it: the old address is Stale and never reaches the
  replacement (`actor-probe-a-identity`, `actor-identity`,
  `actor-lifecycle-construction`; mutants `generation-unchecked`,
  `generation-not-bumped`, `closed-accepts`). Each incarnation has its own
  channels (`reused-channels`). There is one mailbox table per thread, so
  "another postbox" cannot exist; no global registry or name lookup exists.
* **Delegation.** An address is a value: a contextless actor that receives
  the supervisor's address in a message can send to it, and the supervisor
  acts on the request with its own authority -- explicit delegation, not a
  context grant (section 10).

## 8. Mailbox behavior

* **Bounded.** `open[M](capacity)`. `send` answers Full at capacity and
  drops nothing.
* **Room waits.** `deliver` waits on the mailbox's Reliable room channel.
  Each taken message from a mailbox with waiting senders grants one place:
  the waiting count moves to a reservation and one event is posted, which
  wakes the first waiter (the loop's FIFO waiter order). While senders wait
  or hold a reservation, a sender that did not wait is Full: it cannot
  overtake. A woken sender's place is reserved, so it never finds the
  mailbox full again.
* **No lost wakeup, no storm.** The receiver's wake is posted only when its
  host is waiting (a flag set right before the wait; one thread, so nothing
  runs between); room events are posted only for waiting senders and only
  for a freed place (`actor-room-events`: 4 waits, 4 wakes, none from a
  mailbox that was never full, no timer).
* **Closure.** A close revokes both channels: the waiting receiver wakes
  and answers Closed, every room waiter wakes with Closed -- also when the
  slot is reused before it runs (its channel was that incarnation's) --
  and later sends are Closed (`actor-room-close`).
* **Fairness among senders** is first come, first served
  (`actor-room-fifo`: p1 p2 AA BB CC DD, DD's earlier `send` Full).

## 9. Actor lifecycle

### 9.1 Construction

Eager, as every coroutine: the actor's first segment runs inside the
constructor, in the inject block. A failure there reaches the constructor
as the construction's error, never the loop. The actor is not started: the
Inbox moved into it is gone with it, and the administration closes the
mailbox by address (`actor-lifecycle-construction`: undelivered 1, then
Closed). A failed construction started anyway is a Failed task, never a
Returned one: its host resumes it once, which raises its cached failure
(mutant `failed-construction-returned`).

### 9.2 Hosting

`start` constructs the host (`host(actor, first, ...)`, std::actor's own
coroutine), adopts it and returns the task id. The host's first segment
only yields, so the actor's first request is served in the next turn, as
any adoption's. The host then loops: perform the request, resume the actor
with the answer. It takes at most one message per actor per dispatch: a
queued message found after a delivery in the same dispatch makes it yield
the turn first (mutant `batch-per-dispatch`).

### 9.3 Ending

When the actor returns, fails with TaskFailed, IndexNotFound,
SchedulerFault or DriverFault, its host retires it: every mailbox it
listened to closes (queued messages counted undelivered; room waiters woken
with Closed; the waiting receiver, if any, Closed), its record is freed,
and the host ends with the actor's outcome -- its exit value, or the same
error with its payload, which the loop records under the task's id
(`actor-lifecycle-failure-reaped`; mutants `failure-not-reaped`,
`return-not-reaped`). Other actors and tasks are unaffected.

### 9.4 Abandonment and reap

`std::event_loop::shutdown` revokes every registration, so every waiting
receive and room wait answers Closed and cooperative actors finish within
the rounds; then it abandons the rest, releasing them without running any
of their code. `std::actor::reap()` closes the mailboxes of every actor
whose task the loop no longer owns although its host never ended it, and
every mailbox the shutdown left without a live channel
(`actor-shutdown`). The one event-loop addition is the query that needs:

```botlish
fn owned?(task: int, context ev: Loop) -> bool errors SchedulerFault
```

-- whether the loop still owns task TASK (adopt's id): ready, being
dispatched or waiting. It reads the task table and changes no scheduling
rule. **Progress contract:** an actor that returns or fails is reaped at
once by its host, with nothing to call; only abandonment (which runs no
code, by design) needs `reap`, after the shutdown, once the top level has
drained what it wants.

**Outcomes** are never consumed or hidden: `take_outcomes` reports actors
and ordinary tasks alike (`actor-coexist-outcomes`; mutant
`reaper-steals-outcomes`).

### 9.5 Cleanup semantics

Cooperative cleanup runs when an actor gets a turn (a Closed receive, a
Stop message): `idle: closed, cleaning up` in `actor-shutdown`. Forced
abandonment releases the actor without running its code (no finalizer:
COROUTINES.md, "Release at the last use"); its mailboxes are closed by
`reap`, from outside.

## 10. Restricted injection

`tests/actor/authority.bot` is the brief's section 12, on every backend:

```
t=0: main: started the supervisor, task 0
t=1: supervisor: started the calculator, task 1
t=1: supervisor: started the archivist, task 2
t=5: supervisor: transmitted for calculation 3 at clock 101
t=6: supervisor: result 1 by calculator = 49
t=7: supervisor: result 4 by archivist = 1
t=8: supervisor: result 2 by calculator = 6765
t=9: supervisor: result 3 by supervisor = 1
t=9: supervisor: closed the archivist's mailbox, undelivered 0
t=10: main: task 0 ended with 1
t=10: main: task 1 ended with 3
t=10: main: task 2 ended with 1
t=10: main: the network carried 42
t=10: main: storage holds 5
...
```

* The calculator (`inject no context:`) answers Square and Fib(20) and, for
  Upload, delivers a Request to the supervisor's address, which the
  supervisor delegated in the message; the supervisor transmits over the
  Network with its own authority and replies to the address the request
  names.
* The archivist (`inject context Storage:`) stores.
* **The compiler's analysis** (`actor-authority-requirements`):

  | function | required contexts |
  |---|---|
  | `calculator` | none |
  | `archivist` | Storage |
  | `supervisor` | Clock, Network, Storage, std::actor::Actors, std::event_loop::Loop |
  | `std::actor::listen`, `receive`, `try_receive`, `send`, `deliver`, `pause`, `exit`, `spawned` | none |

* **Negative evidence, in the same program, every context installed**
  (`acVariant`: one operation substituted into a probe function the
  actor calls):

  | put into the calculator | result |
  |---|---|
  | `transmit(1)` (Network), `store(1)` (Storage), `read_clock()` (Clock) | CONTEXT-NOT-INJECTED |
  | `std::event_loop::now()`, `channel(...).revoke()`, `revoke(after(5))`, `stop()`, `take_outcomes()`, `log(...)` | CONTEXT-NOT-INJECTED |
  | `std::actor::sleep(1)`, `std::actor::stats()`, `std::actor::open[Result](1)` | CONTEXT-NOT-INJECTED |

  | put into the archivist | result |
  |---|---|
  | Network, Clock, the Loop, Actors | CONTEXT-NOT-INJECTED |
  | its own Storage (unchanged program) | ok |

  Every diagnostic is located at the actor's construction in its inject
  block. Reading the supervisor's context parameter inside the block is
  CONTEXT-NOT-INJECTED; handing an actor built in the block a privileged
  coroutine the supervisor constructed is CONTEXT-RETAINED-AUTHORITY.
  The restriction is the inject boundary itself: no separate entry
  program, no missing installation.

## 11. Scheduler compatibility

`tests/actor/coexist.bot` runs a ping-pong pair of actors (30 rounds each,
60 turns), a failing actor, a ticker on a repeating 10 us timer, a reader of
a driver source (records at t=12 and t=27), a quiet task posting once, and
a failing ordinary task. The ticks fire at 10, 20, 30, 40, 50, the records
are taken at 12 and 27, the quiet task's event in the next turn, and every
outcome is reported. The turn, its fairness, liveness, revocation and
outcomes are unchanged: hosts are ordinary tasks, mailbox channels never
keep the loop alive, and the library adds no scheduling rule.

## 12. Backend results

`tests/actor.test` has 67 tests. Each of the nine scenario programs
(`tests/actor/{actors,authority,values,lifecycle,room,shutdown,coexist,identity,replay}.bot`)
is compiled once under `-warnings error` and run on every backend of the
run, which must give one outcome: the whole trace, every `t=TURN: TEXT`
line, identical. The claims are then read from that trace. The authority
variants, the 15 rejections and the source invariants are front-end tests.

| run | backends per scenario | result |
|---|---|---|
| `tclsh9.0 tests/actor.test` (directly) | interp, compile, cranelift-generic, cranelift | 67 of 67 |
| `CORE_BACKEND=interp` (as `tests/local.tcl` and CI run it) | interp, cranelift | 67 of 67 |
| `CORE_BACKEND=compile` | compile, cranelift-generic | 67 of 67 |
| both passes under `BOTLISH_NATIVE_GC_STRESS=1` (section 13) | as above | the 30 scenario tests, 30 of 30 |

**Regression** (the suites the change touches, AGENTS.md's "Same-thread
actors" list):

| suite | result |
|---|---|
| `tests/event-loop.test`, interp and compile passes | 91 of 91, each |
| `tests/event-loop-linux.test` (real epoll, sockets, threads) | 15 passed, 10 skipped (its SDL3 tests: `tests/cffi/sdl3.tcl` not built here), 0 failed |
| `tests/restricted-injection.test` | 45 of 45 |
| `tests/coroutines.test` | 81 of 81 |
| `tests/affine.test` | 48 of 48 |
| `tests/contexts.test` | 74 of 74 |
| `tests/context-traits.test` | 61 of 61 |
| the warning gate (`audit/refactor/tools/gate.tcl`) | passed: 86 corpus programs, 40 library loaders, 34 manifest entries |
| `tools/compilerpedia.tcl check` | 1201 topics, 727 examples run, 0 problems |
| the golden manifest (`audit/golden/migration/merge.tcl -names audit/golden/migration/tcl-names.txt -check 1`) | regenerated with the new census rows; consistent |

The restricted-injection, coroutine, affine and context suites ran on the
interp pass. `tests/local.tcl` as a whole, the other platforms' workflows
and `static-decisions.yml` were not run for this change (no front-end rule
changed; the front end's fingerprint changes because `core/` and stdlib
did, so cached HIRs are rebuilt once).

**Environment.** A 4-core Linux x86-64 container (kernel 6.18), Tcl 9.0.1
(`tclsh9.0`), rustc 1.97.0, the native backend built with `cargo build
--release --manifest-path native/Cargo.toml`, `LANG=C.utf8 LC_ALL=C.utf8`.

**To reproduce:**

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/actor.test -tmpdir "$(mktemp -d)"
CORE_BACKEND=interp tclsh9.0 tests/actor.test -tmpdir "$(mktemp -d)"
CORE_BACKEND=compile tclsh9.0 tests/actor.test -tmpdir "$(mktemp -d)"
BOTLISH_NATIVE_GC_STRESS=1 CORE_BACKEND=interp tclsh9.0 tests/actor.test -tmpdir "$(mktemp -d)"
tclsh9.0 audit/actor/tools/mutate.tcl -detectors-only 1
tclsh9.0 bench/actor.tcl -runs 3
```

## 13. GC and resource correctness

**Under `BOTLISH_NATIVE_GC_STRESS=1`** (a collection attempt at every
allocation site), every test that runs a scenario -- the nine `agree`
tests and the 21 that read their traces -- passes in both passes
(cranelift beside interp, cranelift-generic beside compile): 30 of 30 each,
the 37 front-end tests skipped by `-match`. Each `agree` test requires the
native trace to equal the Tcl backend's, so a collection that lost or
corrupted a suspended actor, a host, a queued message or a mailbox row
would show as a different trace. The scenarios keep actors suspended across
turns in every state the library has: waiting for a message, waiting for
room, holding a reservation, paused, sleeping on a timer, abandoned by a
shutdown, and failed.

**What is released, and when.**

| object | released |
|---|---|
| a message | when it is received, or when its mailbox closes (counted undelivered): the pool node's payload is replaced by `0` (`stdlib/actor.bot`'s `shut`, the receive path), so no taken or dropped message stays reachable |
| a mailbox | its channels revoked and its row reset when it closes; its slot reused with a new generation and new channels |
| an actor's coroutine | when its host ends (the host's last use of the handle; an affine release, COROUTINES.md) or when the loop abandons the host |
| a host | when its task ends or is abandoned, as every loop task |
| an actor record | freed on retirement, reused by the next `start` |

Evidence: the scenarios end with no mailbox open (`open mailboxes 0` in
`actor-probe-a-accounting`, `actor-shutdown`, `actor-coexist-outcomes`) and
no actor running (`actor-probe-a-accounting`, `actor-lifecycle-accounting`,
`actor-shutdown`); every message is either received or counted undelivered
(`delivered = received + undelivered` in `actor-probe-a-accounting`,
`actor-lifecycle-accounting` and `actor-shutdown`); after
2,000 actors stop, their stacks are back (section 15: virtual +1,028 KiB,
RSS +2,820 KiB above the level before they were created).

**Not covered.** The tables (rows, channel registrations, the payload pool)
grow to the program's peak number of open mailboxes and queued messages and
do not shrink; their slots are reused. A long-running program that once
held many mailboxes keeps their rows (14 Ints each).

## 14. Mutation testing

`audit/actor/tools/mutate.tcl` (`audit/actor/tools/mutants.txt`): each
mutant is a deliberate bug in one rule, applied to a private copy of the
compiler, library and tests (the checkout is never modified), with a `!!`
line naming the tests meant to detect it. A mutant is killed only when one
of its named detectors fails.

**Result: 23 mutants, 23 killed by a named detector**
(`tclsh9.0 audit/actor/tools/mutate.tcl -detectors-only 1`, the interp pass:
interp and cranelift; `audit/actor/results/mutants-interp.txt`).

| rule | mutant | killed by |
|---|---|---|
| receive-right uniqueness | `inbox-copyable` (the token holds an Int) | `actor-static-copy-inbox`, `-listen-twice`, `-drain-twice` |
| | `receiver-not-bound` (a receive served for any open mailbox) | `actor-identity` |
| | `rebind-allowed` (listen binds a bound mailbox) | `actor-replay` |
| recovery | `recover-unguarded` (no identity check before `recover`) | `actor-source-recover` |
| context-free communication | `receive-needs-loop`, `send-needs-actors` | `actor-agree-authority`, `actor-authority-requirements`, `actor-authority-run` |
| reaping | `failure-not-reaped`, `return-not-reaped` | `actor-lifecycle-failure-reaped`, `-accounting`, `actor-probe-a-accounting`, `actor-authority-run` |
| | `failed-construction-returned` | `actor-lifecycle-construction` |
| | `reap-skips-abandoned`, `owned-always` (stdlib/event_loop.bot) | `actor-shutdown` |
| | `reaper-steals-outcomes` (retiring takes the loop's outcomes) | `actor-coexist-outcomes`, `actor-lifecycle-failure-reaped` |
| identity | `generation-unchecked`, `generation-not-bumped`, `closed-accepts` | `actor-probe-a-identity`, `actor-identity`, `actor-lifecycle-construction` (`-failure-reaped`) |
| | `reused-channels` (a reused slot keeps revoked channels) | `actor-room-close`, `actor-room-reservation` |
| wakeups and room | `lost-wakeup` | `actor-probe-a-request-reply`, `actor-authority-run`, `actor-values-snapshot` |
| | `no-room-wake` | `actor-room-fifo`, `actor-room-events`, `actor-probe-a-backpressure` |
| | `reservation-ignored` (a woken sender's place can be taken) | `actor-room-reservation` |
| | `room-storm` (every take wakes a sender) | `actor-room-events` |
| | `close-keeps-room-waiters` | `actor-room-close`, `actor-lifecycle-failure-reaped` |
| accounting | `undelivered-uncounted` | `actor-lifecycle-accounting`, `actor-probe-a-accounting`, `actor-shutdown` |
| scheduling | `batch-per-dispatch` (every queued message in one dispatch) | `actor-probe-a-request-reply` |

**What the mutants found.** Three mutants survived the first rounds, and
each led to a change, not to a weaker mutant:

* `rebind-allowed` survived because nothing started two actors on one
  mailbox. A replayed first request does (section 6): `actor-replay`. Its
  first version did not discriminate either -- the impostor ended, and its
  retirement closed the mailbox, before the rightful actor's listen was
  served -- so each listener now pauses a turn after its listen.
* `room-overtaken` (a sender that did not wait may take a place before the
  waiting senders) was equivalent: `put` refused a send while senders
  waited (`m_rwait > 0`) *and* while the queue and the reservations filled
  the mailbox, and the first condition implies the second -- a sender
  waits only after a Full answer, and every freed place is granted to a
  waiter at once (`grant_room`), so while one waits, `count + reserved`
  is the capacity. The redundant condition was removed; its replacement,
  `reservation-ignored`, drops the reservation from the second, and
  `actor-room-reservation` (a send in the turn a waiter is woken, before it
  runs: Full) kills it.
* `reused-channels` survived because no test sent through a reused slot's
  room channel; the reservation phase of `room.bot` does.

The static mutants are judged by the front end alone and the run-time ones
on interp and cranelift; `-backend all` runs the four.

## 15. Performance

`tclsh9.0 bench/actor.tcl -runs 3`: `bench/actor/main.bot` natively
(cranelift) on the Linux driver (`packages/event_loop_linux`, real clock),
three fresh processes; the census's Probe F workloads plus the milestone's
own. Every actor of the measured phases is constructed inside `inject no
context:` except the "unrestricted" pair, the same actor code constructed
outside any block. A 4-core container (Intel Xeon @ 2.10GHz, Linux 6.18,
Tcl 9.0.1, rustc 1.97.0), shared: the rows are relative costs. Wall equals
CPU within a few percent (one thread). The output is
`audit/actor/results/bench-cranelift.txt`.

| phase | ops | µs per op, best (worst) | Probe F (census 12.6) |
|---|---:|---:|---:|
| raw channel ping-pong (two tasks, ints) | 40,000 | 1.06 (1.08) | 1.46-1.70 |
| contextless actors, `int` ping-pong | 40,000 | 2.28 (2.41) | `Postbox[int]` 2.21-2.44 |
| unrestricted actors, `int` ping-pong | 40,000 | 2.24 (2.53) | -- |
| contextless actors, `Msg` ping-pong (64-char str, a fresh 8-element List) | 40,000 | 2.50 (2.56) | `Postbox[Msg]` 2.19-2.58 |
| request/reply round trip (send, receive, reply, receive) | 20,000 | 4.81 (5.33) | -- |
| `deliver` into a full mailbox (capacity 4; 19,996 room waits) | 20,000 | 2.89 (3.68) | -- (Probe A polled) |
| ring of 100 actors, hop | 20,000 | 2.53 (2.92) | 1.78-3.05 |
| create an idle actor (open, construct, start, its listen served) | 2,000 | 30.5 (37.4) | 13-50 |
| stop it (one message, run to completion, reaped by its host) | 2,000 | 16.6 (30.4) | 9-35 |
| fail it (one message, TaskFailed, reaped by its host) | 2,000 | 14.3 (21.9) | -- |
| `int` ping-pong beside 50 spinning tasks | 40,000 | 20.9 (22.1) | -- |

| memory | added | per actor | Probe F |
|---|---|---|---|
| 2,000 idle actors | RSS +17,908 KiB, virtual +32,760,836 KiB | 9 KiB resident, 16 MiB reserved (two coroutine stacks, `MAP_NORESERVE`) | RSS +8,488 KiB, virtual +16,248,324 KiB (one stack) |
| after stopping them | RSS +2,820 KiB, virtual +1,028 KiB | stacks returned | RSS +1,404 KiB, virtual +516 KiB |

**Reading.**

* **A message costs about 1.2 µs over the bare channel** (2.28 against
  1.06 µs per hop); Probe F's postbox cost about 0.7 µs over its own. The
  difference is the host: every request is two more coroutine switches
  (actor to host and back) and an `Exit` and an `Answer` value. That is
  the price of an actor that holds no context, and it is well inside what
  an actor needs; nothing measured asks for a native mailbox.
* **Restriction costs nothing at run time**: contextless and unrestricted
  actors run the same code at the same speed (2.28 and 2.24 µs, within the
  runs' spread). The inject block is a proof, not a mechanism.
* **Room waits are events**: a producer four messages ahead of its
  consumer waits for room on 19,996 of its 20,000 deliveries, at 2.89 µs
  per message including the wait; no timer fires.
* **Fairness is the loop's**: beside 50 spinning tasks, each ping-pong hop
  takes one turn of 51 dispatches (about 0.4 µs per dispatch), as for any
  task.
* **The dominant cost of an idle actor is address space**: two 8 MiB
  stack reservations, the actor's and its host's, against Probe F's one
  (its actors received for themselves, with the Loop). Resident memory is
  9 KiB per actor. The stacks are returned when the actors end. A host per
  actor is what keeps the scheduling the loop's (one host serving many
  actors would be a second scheduler); the stack size is the process-wide
  knob `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` (section 17).
* **Creation and destruction** vary up to 2x between runs on this shared
  machine; they are dominated by stack mapping (the pool keeps 32).

## 16. Documentation and compatibility

* New: `stdlib/actor.bot`, `core/actor.tcl`, `concept.actors` and the
  generated `stdlib.module.std::actor` topics in Compilerpedia, AGENTS.md's
  "Same-thread actors (std::actor)", this report, `docs/INDEX.md`.
* Changed: `stdlib/event_loop.bot` gains `owned?` (no existing function
  changed); `native/lower.tcl` lowers `std::actor::recover` as its operand
  (`same`); `core/core.tcl` loads `core/actor.tcl`. The front end's
  fingerprint covers `core/` and stdlib, so cached HIRs of every program are
  rebuilt once.
* Existing programs are unaffected: no syntax, rule or diagnostic changed;
  the restricted-injection, event-loop, coroutine and affine suites pass
  unchanged (section 12).

## 17. Next milestones

* **Sendability (census M2).** `Address[M]` is opaque and therefore
  `local` under the census's rule: it is not promised to cross threads.
  The copy operation and SEND-NOT-SENDABLE come first.
* **Per-thread runtime state (M3)** and **Botlish-owned threads (M4).** A
  cross-thread `Address` needs a loop identity in the native ABI and an
  inbound bridge task that copies messages into the receiving thread's
  `Actors`; the host design does not change.
* **Recovery.** `std::actor::recover` would become unnecessary if the
  language gained a typed way through a non-generic carrier (generic
  resume protocols plus sum types, or contexts with type slots); the
  internal call site would then be replaced, never widened.
* **Mobile.** Each actor reserves one coroutine stack (8 MiB of address
  space, `MAP_NORESERVE`) plus its host's: section 15's memory figures.
  Many-actor workloads on 32-bit or memory-constrained targets need a
  smaller per-thread stack size (a runtime knob today), not a different
  actor model.

## 18. Files, and what to run when changing this

| file | what |
|---|---|
| `stdlib/actor.bot` | the library |
| `core/actor.tcl` | `std::actor::recover`, internal |
| `native/lower.tcl` | `same`: the recovery's lowering |
| `stdlib/event_loop.bot` | `owned?` |
| `tests/actor.test`, `tests/actor/*.bot` | scenarios, authority variants, rejections, source invariants |
| `audit/actor/tools/mutate.tcl`, `mutants.txt` | the mutation harness |
| `bench/actor.tcl`, `bench/actor/` | the performance report |
| `audit/actor/experiments/` | the typed routes section 4.3 found closed |
| `audit/actor/results/` | the benchmark's and the mutation run's output (sections 14, 15) |
| `compilerpedia/topics/concepts.topic` (`concept.actors`), `compilerpedia/generated/stdlib.topic` | the reference |
| `audit/golden/migration/census/actor.tsv` | the tests' census rows |

AGENTS.md, "Same-thread actors (std::actor)", has the rules to keep and the
commands to run.
