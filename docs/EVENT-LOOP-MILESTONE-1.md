# EVENT-LOOP-MILESTONE-1.md

Production scheduler, deterministic testing and Linux native integration:
the event loop as a standard-library facility.

EVENT-LOOP-EXPLORATION.md showed that one thread-local scheduler, written in
ordinary Botlish over the existing coroutines, contexts and affine values,
can coordinate independently written native event sources. Two compiler
milestones then removed the coroutine-effect defects it found
(CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md,
TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md). This milestone turns
the prototype into permanent code: `std::event_loop`, its deterministic
driver, and a production Linux driver with a native integration ABI. It
changes no compiler, runtime or backend file.

> Adding a library may add events and consume scheduling capacity. It must
> not silently change the rules under which unrelated Botlish code
> executes.

## Contents

1. Result
2. Starting evidence
3. Architecture
4. Public API
5. Scheduling semantics
6. Timer implementation
7. Native delivery
8. Linux driver
9. Ownership
10. Host compatibility
11. Performance
12. Testing
13. Compiler consistency
14. Portability
15. Remaining limitations
16. Recommended next milestone
17. What to run when changing this

## 1. Result

**Production code** (all new files; nothing in `core/`, `hir/`, `surface/`,
`compiler/` or `native/` changed):

| what | where |
|---|---|
| the scheduler, `std::event_loop` | `stdlib/event_loop.bot` |
| the deterministic driver, `std::event_loop::deterministic` | `stdlib/event_loop/deterministic.bot` |
| the Linux driver, a package with its C adapter | `packages/event_loop_linux/` (`event_loop_linux.bot`, `native/event_loop_linux.c`) |
| the native integration ABI (version 1) | `packages/event_loop_linux/native/botlish_event_loop.h` |
| the package's installer | `tools/event-loop-linux.tcl` |
| examples | `examples/event-loop/` |
| deterministic tests (every backend) | `tests/event-loop.test`, `tests/event-loop/*.bot` |
| native tests (real epoll, sockets, threads, SDL3) | `tests/event-loop-linux.test`, `tests/event-loop/native/` |
| mutation harness | `audit/event-loop/tools/mutate.tcl`, `mutants.txt` |
| performance report | `bench/event-loop.tcl`, `bench/event-loop/benchwork.bot` |
| the feedback-union test | `tests/traits.test` (`trait-implementation-yield-stale-edge`), `tests/event-loop.test` (`el-hoststep-feedback-exact`) |

**What changed from the prototype**, each with its evidence (section 12):

* A **deadline heap** replaces the per-expiry scan of every registration
  (section 6): O(log n) per expiry, and a timer nobody waits on is not in
  it.
* **Delivery policies** replace unconditional dropping (section 7): Lossy,
  Coalesce and Reliable; Reliable never drops -- a record without room
  stays with the driver, which takes nothing more from that source, and the
  backpressure reaches the native producer.
* **Round-robin source fairness** in the driver contract (section 7): a
  quiet source's record is collected in the first turn after it arrives,
  beside two 200-record bursts (the prototype's FIFO driver: 50 turns).
* **Fault channels** (section 5.6): an `IndexNotFound` of the scheduler's own
  tables is `SchedulerFault`, a scheduler bug that ends `run`; a task's own
  `IndexNotFound` is its outcome, as `TaskFailed` and a `DriverFault` it
  received are.
* **Three prototype bugs fixed**, each with a regression test: a one-shot
  timer two tasks waited on woke only the first, and the second never ran
  (`el-heap-broadcast`); `abandon` left released tasks in the waiter lists,
  so a later revocation woke a dead task (`abandon-keeps-waiters`, a
  mutant); the FIFO record queue let one source delay another by
  `burst / budget` turns (`el-fairness-quiet-source`).
* **A lost-wakeup bug in the production adapter, found by the mutation
  work and fixed** (section 7.2): a `botlish_event_wake()` landing in the
  window before the eventfd's reset was swallowed. The race test that
  shows the fix widens that window on purpose.
* **Capabilities made explicit**: the scheduler's internal tables, row
  offsets and registers are private; a `Reg` is opaque; the Driver gates
  waiting, turning and dropping tasks; a native source needs the Linux
  driver's integration capability (`event_loop_linux::Native`), which only
  an installed Linux driver makes.

**What remains experimental or absent**: the Linux driver is the only
native driver (no Windows, macOS or mobile driver); no automatic cleanup of
registrations (section 9); no production host embedding (section 10); the
integration ABI is version 1, Linux-only. The exploration's prototype
(`audit/event-loop/src`) stays as evidence and as the benchmark's baseline.

## 2. Starting evidence

The exploration (EVENT-LOOP-EXPLORATION.md, `audit/event-loop/`)
established one scheduler on four backends, driver selection by context
traits, bounded turns with precise once-per-turn observers,
generation-checked revocation, epoll/eventfd integration with producer
threads and SDL3, the hybrid wakeup protocol, callback containment in C, no
allocation per dispatch -- and the prototype's limits: quadratic timer
expiry, FIFO source unfairness, dropping as the only overflow behavior, and
no automatic cleanup of affine resources.

Two compiler milestones made a scheduler whose driver may suspend correct:

* CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md: a trait operation
  (`d.block(...)`) never takes a same-named visible function as its callee.
  The production scheduler names its driver operations freely (`clock`,
  `block`, `take_record`, ...) and `audit/event-loop/tools/original-names.tcl`
  keeps checking the prototype under its intended names.
* TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md: the yields of a trait
  operation are its selected implementation's. The host-stepped driver
  (section 10) depends on it: the scheduler is unchanged, the selected
  `block` yields.

The re-inspection of the current tree found what the reports did not say:

* The standard library cannot ship a native archive: a standard module's
  `extern c library ... static at PATH` has no root to resolve from
  (NATIVE-LINK-PLAN-MILESTONE-1.md, section 8). A package's archive path
  resolves from its instance directory (section 9 there). So the scheduler
  and the deterministic driver are standard library, and the Linux driver is
  a package an application installs (`tools/event-loop-linux.tcl install
  APP`), with its archive built there by the host's C compiler.
* Context-owned affine state (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md)
  lets the installed `Loop` own the task handles in MutableVectors, moved in
  by `adopt` and out by the dispatch, with no runtime ownership state.
* An `extern c fn` cannot be `nomethod` (`nomethod extern c fn` is a syntax
  error), so a C call whose first argument is a converted Int is written
  with method syntax to satisfy METHOD-ELIGIBLE (`ci(fd).evl_watch(...)`).

## 3. Architecture

Three responsibilities, kept apart in the code and in the types.

**The scheduler** (`std::event_loop`, ordinary Botlish over MutableVectors,
MutableArrays and coroutines) owns tasks, the ready queue, registrations,
timers, the turn, fairness, revocation and shutdown. It knows no operating
system: no descriptor, handle, epoll state or clock source appears in it.
Its state is the opaque context struct `Loop`: parallel integer tables
(tasks, registrations, events), the task handles, a deadline heap and a
register array -- one value the application installs.

**The driver** is any context implementing the context trait
`std::event_loop::Driver`: `clock`, `block(deadline)`, `take_record`,
`record_gen`, `record_a`, `record_b`, `hold_record`, `release_held`. It
supplies time, waiting, wakeups and native records, and adds no scheduling
rule. Only an entry program installs contexts, so only the application
chooses the driver: two installed drivers are
AMBIGUOUS-CONTEXT-IMPLEMENTATION, none is MISSING-CONTEXT, and a library
that tries to install one is CONTEXT-INSTALLATION-UNSUPPORTED (all three are
`tests/event-loop.test` rejections). There is no runtime driver selection.

**Event sources** register with the loop -- `source`, `channel`, `timer`,
`observer` -- and deliver records tagged with a registration's identity. A
library function that requires only `Loop` can register, post, wait and
revoke; it cannot make the loop wait or turn, or drop its tasks: `run`,
`turn`, `sync`, `shutdown` and `abandon` also require the Driver. A native
source additionally needs `event_loop_linux::Native` (endpoints, readiness
watches, wakeups), which `event_loop_linux::native()` makes only from an
installed Linux driver -- so a library needing native integration under the
deterministic driver is a compile-time MISSING-CONTEXT
(`el-linux-static-capability`), never a silently different driver. The
driver audit (`el-static-audit`, `el-linux-audit`; `hir::contexts::summary`)
checks that no library of the scenario programs requires the driver.

Native producer threads never run Botlish code: they post records to an
endpoint, which the loop's own thread collects in a later turn
(section 8).

## 4. Public API

The programming model in one example -- every line is ordinary Botlish
(`examples/event-loop/01-run-task.bot`):

    with context std::event_loop::create(64)               the scheduler
    with context std::event_loop::deterministic::create()  the driver
    coroutine {step, first} = count("left", 2)             an ordinary coroutine
    std::event_loop::adopt(step, first)                    ... moved into the loop
    std::event_loop::run()                                 turns until nothing is live

**Tasks.** A task is an ordinary coroutine of one protocol,
`Coroutine{args: [], return: int, errors: [TaskFailed, IndexNotFound,
SchedulerFault, DriverFault]}` (a coroutine with fewer errors is admitted).
Its spawner constructs it -- the first segment runs at once, in the
spawner -- and `adopt(step, first)` moves the handle into the Loop and
returns the task's id (a serial number, never reused). Adopting twice, or
resuming after adopting, is USE-AFTER-MOVE. A task yields to the loop with
`yield_now()` (ready again next turn), `wait(reg)` (an `Event`) or
`sleep(delay)`; it may own and resume other coroutines directly
(`03-child.bot`): their yields return to the task, never to the loop.

**Registrations** (`Reg`, opaque: only the scheduler makes one):

| call | what |
|---|---|
| `after(delay)`, `every(period)`, `timer(deadline, period)` | timers (microseconds of the driver's clock) |
| `source(delivery, capacity, :keep_alive)` | native records; `:keep_alive` makes a waiting task keep the loop alive |
| `channel(delivery, capacity)` | events Botlish code posts; never keeps the loop alive |
| `observer()` | once per turn (section 5.3) |
| `post(reg, a, b)` | `Posted::Accepted`, `Coalesced`, `Dropped`, `Refused` (Reliable, full) or `NotLive` |
| `wait(reg)`, `try_take(reg)` | an `Event {reason: Wake, a, b, count}` |
| `revoke(reg)` | ends it (section 9); `live?(reg)` |
| `pending`, `delivered`, `dropped` | a registration's counters |

`Delivery` is `Lossy`, `Coalesce` or `Reliable` (section 7); `Wake` is
`Ready`, `Event`, `Timer`, `Turn`, `Revoked` or `Empty`.

**The application's operations** (they require the Driver): `run()`,
`turn()`, `sync()` (read the clock before registering timers outside the
loop), `shutdown(rounds)`, `abandon()`. `stop()` is a Loop operation, so a
task can request it (a quit command): it ends the current `run` after its
turn.

**Observation**: `take_outcomes()` (each finished task's id, `Ending` and
value), `stats()`, `now()`, `turn_number()`, `current_task()`, and the
trace (`create(budget, :trace)` records every scheduling decision;
`log(text)` adds an application line; `trace()` returns them, each
`t=TURN: TEXT`).

**Low-level, for drivers and integrations** (stable within ABI version 1,
not the application's primary API): the Driver trait's operations, and
`native_slot(reg)`, `native_generation(reg)` -- the two C ints a native
producer tags its records with. A `Reg` cannot be made from them.

**The deterministic driver** (`std::event_loop::deterministic`): `create()`
(virtual time 0), `inject(when, reg, a, b)` (a scripted record released at
virtual time WHEN), `inject_tag(when, slot, gen, a, b)` (a record with an
explicit tag: stale, unused or reused slots), `advance(delta)`,
`advance_to(time)` (a segment that takes time), `waits()` (every deadline
the loop blocked with), `undelivered()`.

**The Linux driver** (`event_loop_linux`, section 8): `create()` (the
driver context `Linux`), `native()` (the integration capability `Native`),
`endpoint(capacity)`, `endpoint_id(e)`, `endpoint_count(e)`,
`close_endpoint(e)`, `watch(fd, interest, reg)`, `rearm(w)`,
`readable(w)`, `unwatch(w)`, `wake()`, `close()`, `status()`, `stats()`,
`now_us()`, `cpu_us()`.

**Examples** (`examples/event-loop/`; each run by `tests/event-loop.test` on
every backend, the native one by `tests/event-loop-linux.test`):

| the brief's example | file |
|---|---|
| running an ordinary coroutine from an event loop | `01-run-task.bot` |
| waiting for an event or timer | `02-wait.bot` |
| directly resuming a child coroutine inside a handler | `03-child.bot` |
| registering a once-per-turn observer | `04-observer.bot` |
| explicitly revoking a registration | `05-revoke.bot` |
| integrating a native source through a context | `native/ticker.bot` (with `ticker.c`, `main.bot`, `build.sh`) |
| testing the same application with the deterministic driver | `native/test.bot` (the same `ticks.bot` as `main.bot`) |

The API is documented inline in the modules (the header of
`stdlib/event_loop.bot` states the turn, fairness, delivery, liveness,
revocation and error rules), and `tools/compilerpedia.tcl generate` makes a
topic of every public declaration (`tclsh9.0 main.tcl -help
std::event_loop::wait`).

## 5. Scheduling semantics

### 5.1 The turn (frozen)

A turn is, in order (unchanged from the exploration's section 4.1 except
where marked):

1. **wait** -- the driver blocks until a native record, a wakeup or the
   earliest deadline a task waits on; it polls (deadline 0) when ready work
   exists. A timer nobody waits on imposes no deadline.
2. **collect** -- (new) the holds the driver may release; expired timers,
   in (deadline, registration) order; then at most `budget` native records,
   which the driver hands over round-robin among its sources (new). Each
   record goes to its registration, its generation checked: the first
   waiter becomes ready, else the event is queued under the registration's
   Delivery policy (new).
3. **dispatch** -- exactly the tasks ready when this phase starts, each
   once, in the order they became ready (FIFO, whatever made them ready).
   Work made ready during the phase -- a yield, a post, an adoption, a
   revocation's wakes -- runs in the next turn.
4. **observe** -- every observer registration live when this phase starts
   runs its first waiting task once, in registration order, only in a turn
   whose collect or dispatch did something.

### 5.2 Fairness

Cooperative and bounded, never wall-clock:

* A ready task runs within one turn of becoming ready, however many others
  yield continuously or replenish the queue (`el-fairness-bystander`,
  `el-fairness-storm`: a 61-generation self-spawning storm advances one
  generation per turn; `el-fairness-continuous`: a 40-yield task runs once
  per turn).
* A turn collects at most `budget` records (`el-fairness-budget`).
* **Source fairness (new)**: the driver serves its sources round-robin, one
  record per source in turn, a source's records in order. The exploration
  established fairness between ready tasks but its driver queue was FIFO
  across sources: a record released behind two 200-record bursts was
  collected 50 turns later. Round-robin is the narrowest change that bounds
  it (a quota or credit scheme adds state and tuning for no stronger
  guarantee at this budget): the same record is now collected in the first
  turn after its release (`el-fairness-quiet-source`); natively, a record
  posted to a quiet endpoint behind a 256-record burst to another is
  collected in the first turn (`el-linux-rotation`, measured with Lossy
  sources so that no hold masks the order; an adapter serving one source
  while it has records delivers it in the fifth), and a quiet producer
  beside two 20,000-record floods is served promptly
  (`el-linux-quiet-source`). The scheduling contract itself did not change:
  the round-robin is the driver's, stated in the Driver trait's
  documentation and kept by both drivers.
* A task that takes one event per wake handles one event per turn; draining
  with `try_take` in the wake keeps up with its share (`el-fairness-drain`).
* Not promised: preemption (a segment that never yields holds the thread)
  and progress under a host that withholds turns (section 10).

### 5.3 Observers

As the exploration's section 4.3, now tested on the production scheduler
(`el-observers-*`, `04-observer.bot`): registered before or during a
dispatch phase, an observer runs in that turn's phase; registered during an
observer phase, in the next turn; revoked before its place, never (its task
wakes with `Wake::Revoked`); revoking itself, its current run completes. An
observer never keeps the loop alive (`el-observers-liveness`), never makes
it poll (`el-linux-idle`: one kernel sleep per idle 300 ms with or without
one), and never runs in an empty turn (`el-observers-empty-turn`). It is not
an idle callback, a zero-delay timer or a frame clock: frame work is a
repeating timer (`el-timers-frames`), continuous activity is `yield_now`.

### 5.4 Liveness

`run` returns when no task is ready and no task waits on a registration
that keeps the loop alive (timers, and sources made `:keep_alive`), on
`stop`, or when the driver reports it can never deliver again (`block`
returns -1: a deterministic script that ran out). Channels, observers and
optional sources never keep it alive (`el-errors-liveness-stop-shutdown`).

### 5.5 Reentrancy

`run`, `turn`, `shutdown` and `abandon` from inside a dispatch fail with
`LoopReentered` (`el-errors-reentered`). Resuming a task's own child
coroutines inside its segment is ordinary (`03-child.bot`).

### 5.6 Errors and contract boundaries

The four kinds the brief distinguishes, as they are now:

1. **Application errors.** A task's declared failure (`fail
   std::event_loop::TaskFailed {code: N}`), its own `IndexNotFound` (an
   index its code supplied) and a `DriverFault` it received from a driver
   operation end that task, are recorded (`take_outcomes`: `Ending::Failed`,
   `IndexNotFound`, `DriverFault`, with the code), and affect nothing else
   (`el-errors-recorded`, `el-fault-channels`). A failure in a task's first
   segment reaches its spawner, because construction is eager
   (`el-errors-construction`).
2. **Scheduler-internal indexes.** Every index the scheduler derives from its
   own tables is checked (MutableVector and MutableArray operations raise
   `IndexNotFound`); each public operation maps that to `SchedulerFault`
   (its `*_checked` body inside a handler), and `run`/`turn`/`shutdown` end
   with it. `SchedulerFault` is documented as a scheduler bug, never an
   application condition. A task that receives it from a scheduler
   operation should let it propagate: the loop records the task's outcome
   and `run` then fails (`el-fault-channels`).
   *Why `IndexNotFound` was not removed:* the indexes are integers stored in
   the scheduler's own rows (a slot in a waiter list, a heap position, a
   task id in a queue); no current proof facility relates such a stored
   integer to a vector's length, and removing the checks would need either
   unchecked operations (rejected by the brief) or proof minting
   (`ContractViolation`, separate language work). The checks stay; their
   failure is reported as what it would be -- a bug -- and the exact
   limitation is recorded here and in section 15.
3. **Adapter contract violations.** A record for a timer or an observer is
   counted (`Stats.invalid_records`) and dropped; a record whose generation
   is not the slot's current one, or for a slot nobody uses, is stale
   (`Stats.stale_records`) and dropped. Neither can reach a task. The C
   adapter refuses invalid endpoint ids and watch ids (`-EINVAL`) and checks
   a watch's (slot, generation) on every rearm and close.
4. **Normal native failures.** The driver's `DriverFault {code}` carries a
   negated errno (a failed `epoll_wait`, an adapter that failed to open:
   `event_loop_linux::status()`); endpoint posts report `-EAGAIN` (full),
   `-EPIPE` (closed) to the producer, never to Botlish.

A handler's declared failure never terminates unrelated tasks; a scheduler
fault ends `run` for everyone, because the scheduler's state can no longer
be trusted.

### 5.7 Changed exploratory claims

| exploration (section 4) | production contract | reason |
|---|---|---|
| "at most `cap` per registration; the excess is counted and dropped" | the registration's Delivery policy; Reliable never drops | sources with information that cannot be discarded (section 7) |
| "bounded delay behind bursts, not fairness between sources" | round-robin among the driver's sources | `el-fairness-quiet-source`: 50 turns to 1 |
| "`IndexNotFound`, the one error every scheduler operation may raise" | `SchedulerFault` for the scheduler's own tables; a task's own `IndexNotFound` is its outcome | separates scheduler bugs from application errors |
| a one-shot timer wakes its first waiter | a one-shot timer wakes every waiter, then is spent | the prototype's second waiter never ran (`el-heap-broadcast`) |
| `abandon` (a Loop operation) | requires the Driver; LoopReentered inside a dispatch | dropping the program's tasks is the application's decision |

## 6. Timer implementation

**Structure.** A binary min-heap in one `MutableVector[int]` of registration
slots, ordered by (deadline, registration sequence); each timer's row holds
its heap position, so removal from the middle is O(log n). A timer enters
the heap when its first waiter parks and leaves it when its last waiter is
woken or it is revoked: a timer nobody waits on imposes no deadline and
costs nothing per turn (`el-heap-interest`: the loop sleeps once through
200 expiries of an unwatched 5 us timer, whose late waiter then receives
them coalesced). Expiry pops the top while its deadline is due: O(log n)
per expiry, nothing per unexpired timer.

**Rules kept** (`el-timers-*`, `el-heap-*`): monotonic deadlines on the
driver's clock, read once per turn; deterministic order for equal deadlines
(registration order); generation-safe -- a revoked timer leaves the heap and
its slot's next registration starts clean; a repeating timer reports missed
intervals in one wake and stays on its period's grid; no catch-up loop (a
10 s jump of a 10 us timer is one wake reporting 999,999 missed, computed by
doubling); a one-shot timer wakes all its waiters, and its slot is freed
only when every wake it made has been dispatched (its `inflight` count), so a
reused slot cannot inherit a wake.

**Measurements** (section 11): «TIMER-TABLE»

## 7. Native delivery

### 7.1 Delivery policies

A source or channel queues at most CAPACITY undelivered events; its
`Delivery` says what happens beyond:

* **Lossy** -- the excess is counted (`dropped(reg)`) and dropped: a stream
  where only the latest matters (mouse motion), or an explicitly lossy
  feed.
* **Coalesce** -- one pending event, replaced by the latest, with a count
  of the events it stands for (`Event.count`): readiness notifications,
  motion. Readiness of a socket is a Coalesce source: the task reads the
  byte stream itself, so the stream's semantics stay the kernel's.
* **Reliable** -- never drops. A Botlish `post` to a full Reliable
  registration is `Refused` (the poster decides); a native record without
  room is *held*: the driver keeps it, unconsumed, first in its source and
  takes nothing more from that source (`hold_record`) until the
  registration has drained to half its capacity (`release_held`, a
  low-water mark, so a consumer taking one event per turn does not cost a
  hold and a release per record). An endpoint that fills while held refuses
  its producer's posts (`-EAGAIN`): the backpressure reaches the producer,
  whose policy (wait, coalesce, drop) is its own and visible to it. Storage
  stays bounded: the registration's capacity plus the endpoint's.
* **Timers** coalesce (missed intervals are counted, never queued).

These are the distinctions the demonstrated sources need, and nothing more:
no priority classes, no per-event policy, no unbounded queue. A source that
cannot meet its requirement with bounded storage is visible -- held
records, refused posts and dropped counts are counters (`Stats`,
`event_loop_linux::stats()`), never silent.

Tests: `el-delivery-posts`, `-consumers` (Botlish posts under each policy),
`-reliable-records` (12 records into room for 2: nothing dropped, in order,
the excess held and released as room appears), `-lossy-coalesce-records`,
`-quiet-beside-held` (a quiet source is delivered in the turn its record
is released while a Reliable source is held), `-revoke-held` (revoking a
held registration releases its source at the driver; its remaining records
arrive stale and are dropped; nothing stays held; the slot's next
registration gets none of them); natively `el-linux-flood` (two producer
threads, 20,000 records each, slow Reliable consumers: nothing lost or
reordered, producers paced by refused posts, no endpoint over capacity,
every hold released).

### 7.2 Wakeup protocol

The Linux adapter's eventfd is readable while a wakeup is owed. A post
appends to its endpoint ring and marks the endpoint pending under one
mutex; the empty-to-non-empty edge of the pending list writes the eventfd
once per batch. Before sleeping, the loop drains the pending list; when the
eventfd may hold signals from polls that skipped the kernel (section 7.3),
the loop resets it *and then* looks at the pending list again, so a post
between the two still wakes the sleep.

**A bug found and fixed.** That re-check covers posts, which leave a pending
endpoint behind. A `botlish_event_wake()` -- the hybrid protocol's wake, a
library that only signals and lets its pump post on the loop's thread --
leaves nothing to find: a wake landing between the loop's first look and
the reset was swallowed, and the loop slept with the pumped source's event
waiting until something else woke it. A wake is now *owed* until the
pumps' checks run (`wake_owed`, set by the wake, cleared when the checks
run), and the reset path polls instead of sleeping while one is owed. The
mutation work found it: the mutant that removes the re-check
(`c-reset-without-recheck`) survived every test, because nothing made a
post land in the window; reasoning about why showed the same window loses
a wake even in the unmutated adapter.

**The evidence.** `el-linux-wake` posts 300 jittered records and 40 racing
pairs from a producer thread and requires every one to wake the sleeping
loop at once (none waits for the 50 ms heartbeat);
`el-linux-lost-wakeup-control` runs the deliberately racy protocol
(`BOTLISH_EVENT_LOOP_FAULT=lost-wakeup`, the exploration's negative
control, kept) and requires the same measurement to catch it.
`el-linux-reset-window` (`tests/event-loop/native/race.bot`) attacks the
reset window directly: `BOTLISH_EVENT_LOOP_STRESS=reset-window` (tests
only; no protocol change) widens it to 2 ms, the receiver makes every
record cross it (two busy turns, then a sleep), and records come in pairs
0.8 ms apart with 20 ms between pairs, so the second of a pair lands in the
window and nothing else wakes the loop soon after -- first as posts, then as
wakes of a pumped source (`fixture.c`'s `fx_pumped`). Every record must
arrive within 5 ms (measured: at most 1.6 ms), and the adapter's count of
resets (`Stats.resets`, 80 per phase) shows the window was entered every
time. The mutants `c-post-never-signals`, `c-reset-without-recheck` and
`c-wake-not-owed` (the bug put back) are killed by these tests (section
12).

### 7.3 Turns without a system call

While tasks are ready the loop polls. A poll with no armed watch has
nothing for the kernel to report but the eventfd, and the posted endpoints
were just read in memory, so the adapter skips `epoll_wait` (counted as
`polls_skipped`) and owes the eventfd a reset before the next real sleep.
The exploration's prototype made one `epoll_pwait2` per turn while work was
ready; the ping-pong benchmark's row (section 11) shows the difference.

## 8. Linux driver

**What it is.** `packages/event_loop_linux/event_loop_linux.bot` (the
contexts `Linux` and `Native`) over `native/event_loop_linux.c` (705 lines):
CLOCK_MONOTONIC in microseconds; one epoll instance, `epoll_pwait2` with a
microsecond timeout (`epoll_wait` rounded up where the kernel lacks it);
one eventfd; endpoint rings (up to 256, each a bounded FIFO under the one
mutex); readiness watches (up to 4,096, EPOLLONESHOT, tagged with the
registration's slot and generation); pumps (up to 16); the round-robin
rotation of sources with records; holds. Its functions take and return C
scalars only.

**Installing.** `tclsh9.0 tools/event-loop-linux.tcl install APP` copies the
package to `APP/.bot_modules/event_loop_linux` and builds
`native/libevent_loop_linux.a` there (`-O2 -Wall -Wextra -Werror`); the
module links it by `extern c library "event_loop_linux" static at
"native/libevent_loop_linux.a"`, resolved from the package instance
(NATIVE-LINK-PLAN-MILESTONE-1.md). Native programs only: the Tcl backends
refuse a C call.

**The requirements** (the brief's list) and where each is checked:

| requirement | evidence |
|---|---|
| sleep without losing notifications | `el-linux-wake`, `el-linux-lost-wakeup-control`, `el-linux-reset-window`, mutants `c-post-never-signals`, `c-reset-without-recheck`, `c-wake-not-owed` |
| wake when native work arrives | `el-linux-wake`, `el-linux-sdl-wakeup`, `el-linux-sdl-hybrid` |
| honor deadlines while it owns the wait | `el-linux-idle`, `el-linux-gameserver` (timers beside sockets) |
| bounded batches | the scheduler's budget (`collect-unbounded` mutant), `el-linux-flood` |
| no starvation of quiet descriptors | `el-linux-rotation`, `el-linux-quiet-source`, `el-linux-gameserver` (quiet connections beside a flooding client), mutant `c-source-drained-first` |
| registration and revocation without stale delivery | `el-linux-inflight` (records in flight with an old generation dropped; the slot's next registration gets exactly its own 100), mutant `c-watch-generation-unchecked` |
| descriptor shutdown and errors | watch records carry hang-up and error bits (`a` = 4, 8); `el-linux-gameserver` closes connections mid-run; `unwatch` before `close` |
| thread-local Botlish execution | posts from threads only queue; `el-linux-mixed` |
| producers signal without running Botlish | the ABI (below) has no callback into Botlish |

**The buffered-lines regression** (`el-linux-buffered-lines`): readiness
describes the kernel's buffer, never a reader's. Eleven lines arrive in one
write; the reader that takes every complete buffered line before re-arming
readiness answers all eleven; the reader that waits for readiness after
every line stalls after the first (the exploration's bug, kept as the
negative half of the test). The package documents the rule at `watch` and
the ABI at the pump's `prepare`: a library holding complete events must
return a deadline that is not in the future.

**The native integration ABI** (`botlish_event_loop.h`, version 1):

* `botlish_event_post(endpoint, slot, gen, a, b)` from any thread: 0 (queued,
  the loop woken if it sleeps), `-EAGAIN` (full: backpressure), `-EPIPE`
  (closed), `-EINVAL`. A record is four scalars, copied; nothing refers to
  the producer's memory, so ephemeral callback memory never reaches Botlish
  (an adapter copies event data into the record, as `tests/event-loop/
  native/sdl.c` does for SDL events).
* `botlish_event_wake()` from any thread: wake without a record (pumps
  run).
* Pumps, for a library that can neither post from a thread nor be watched:
  `prepare(user, deadline) -> deadline` before the loop sleeps and
  `check(user)` after every wake, both on the loop's thread, inside the
  wait, never calling Botlish; `botlish_event_add_pump`, `_remove_pump`
  (loop thread only); `botlish_event_now()`.
* Teardown: `close_endpoint` discards an endpoint's undelivered records and
  makes later posts `-EPIPE` (tell the producer first); `unwatch` drops a
  watch (the descriptor stays the program's); `close()` closes everything.
* Notification, never execution: posting never runs Botlish code; the
  scheduler checks the generation and applies the policy when the loop's
  thread collects the record.

**SDL3** (`tests/event-loop/native/sdl.c`, `evsdl.bot`; when
`tests/cffi/sdl3.tcl` has built SDL3, else those tests are skipped and
reported): the exploration's modes on the production loop -- the wakeup
protocol (an SDL event watch posts from SDL's threads), the hybrid (a watch
wakes, a pump copies on the loop's thread), a pure pump with a 10 ms cap,
and the naive negative control. `el-linux-mixed` runs SDL3, the game server
with a flooding client, a producer's posts, timers and the base workload W
in one process, in both initialization orders. SDL3 is the tests'
dependency, never the event loop's. Measurements: section 11.

## 9. Ownership

**Now: explicit.** A `Reg` is an identity, not an owner. `revoke(reg)`
guarantees (`el-revocation-*`): no handler invocation after it -- queued
events are discarded, a wake already queued for a task becomes
`Wake::Revoked` at dispatch and carries no event data, records in flight
with the old generation are dropped as stale, also after the slot is
reused; waiters wake with `Wake::Revoked` in the order they waited and stay
independently owned; code already running is not undone (a handler revoking
its own registration completes its invocation); revoking twice, or through
a copy, does nothing; revocation never cancels a task (tasks a registration
started finish after it is revoked). A slot whose generation would leave a C
int is retired, never reused.

Nothing revokes a registration implicitly: a task that ends without
revoking, or is abandoned, leaves its registration registered
(`el-ownership-no-drop-action`, a NEGATIVE test stating today's behavior),
and `shutdown(rounds)` revokes every registration, runs at most ROUNDS turns
while tasks are ready (the woken waiters may finish), then abandons what is
left -- each remaining coroutine released without running any of its code.
Registered handlers therefore never outlive the scheduler's explicitly
managed lifetime.

**Future: lexical scope.** The intended contract -- an affine resource has
one owner, and its implicit cleanup occurs when the owner's lexical scope
ends -- is not implemented here, and it is not faked: today's last-use
release (COROUTINES.md, "Release at the last use") would revoke a
registration whose token is kept in scope but no longer read, which is
exactly what the brief forbids (`el-ownership-explicit`: a `Reg` kept but no
longer read keeps its registration). `Reg` is unrestricted today, so making
it a resource later is a type change: a registration made affine with a
lexical drop action would make every `revoke` the explicit early release,
and `shutdown` the release of what no scope owns. The scheduler needs no
change for that beyond the type: revocation is already idempotent and
generation-checked.

## 10. Host compatibility

The scheduler never assumes it owns `main` or the thread's lifecycle: it
waits only through `block(deadline)`. The exploration's host-stepped driver
is kept as a regression on the production scheduler
(`tests/event-loop/stepdrv.bot`, `hoststep.bot`, `el-hoststep`): its `block`
yields each deadline to the host that resumes the program as a coroutine;
the host receives the deadlines 100 and 200, then the loop's two turns, on
every backend. The exploration's copy (`audit/event-loop/repro/
host-stepped-driver/`, `tests/context-traits.test`'s
`ct-implementation-yield-event-loop`) still passes.

**Driver kinds, investigated.** Three kinds were named in the brief:

* *independently wakeable, deadline-aware* (Linux): `block` returns at a
  record, a wakeup or the deadline;
* *externally paced* (the host-stepped driver, the deterministic driver):
  `block` returns when the host (or the script) says so; a deadline is
  advisory;
* *requiring active pumping* (SDL without a wakeup source).

The scheduler needs no distinction between them: the same code runs under
all three, and every scheduling rule -- turns, ordering, revocation,
ownership -- is the scheduler's (the deterministic and native tests check
the same rules). Pumping turned out to be a property of a *source*, not of
a driver: the Linux driver runs a source's pump inside its wait
(`botlish_event_add_pump`), so an SDL source pumps under the Linux driver
and a network source does not. What differs is one documented capability,
**deadline honoring**: a driver that owns the wait honors deadlines (late by
at most a turn's work plus wake latency); an externally paced driver honors
them only as well as its host advances it, and a host that does not
advance the loop gets no timer. A type-level distinction would add API for
no rule the scheduler can enforce, so none was added.

Not implemented: production host embedding (an SDL or GUI host owning the
pump, persistent scheduler state across exported calls). A future embedding
milestone drives the same scheduler through `turn()` or a driver like
`stepdrv.bot`; it does not need a second scheduler.

## 11. Performance

**Methodology.** `tclsh9.0 bench/event-loop.tcl` builds both applications
in a temporary directory -- the prototype (`audit/event-loop/src`, its
`evn.c` compiled as `libevn.a`) and the production scheduler with the Linux
package -- and runs the same workloads (`bench/event-loop/benchwork.bot`
mirrors the prototype's `benchwork.bot`) on the native backend
(cranelift), best of 3 runs by CPU time, each a fresh process, in one run on
one machine. Allocations come from the native allocation report under the
deterministic driver, as the difference between two sizes of the same
program, with each driver's own allocation sites left out (the drivers
allocate per turn for their own bookkeeping). The machine: a 4-core container (Intel Xeon @ 2.10 GHz, Linux 6.18, 15 GB), shared: treat times as orders of magnitude.

«PERF-TABLES»

## 12. Testing

**Deterministic** (`tests/event-loop.test`; 87 tests). Each
scenario program (`tests/event-loop/*.bot`, an application root with its
helper modules) is compiled with `-warnings error` and run on the pass's
backends, which must agree on the whole trace: interp and cranelift in the
interp pass, compile and cranelift-generic in the compile pass, all four
when the file runs directly. The claims are then checked on the trace. The
brief's adversarial list, covered:

| brief | tests |
|---|---|
| saturated ready queues, continuously yielding and self-replenishing tasks | `el-fairness-continuous`, `-storm`, `-bystander` |
| quiet tasks beside high-volume sources | `el-fairness-quiet-source`, `el-delivery-quiet-beside-held`, `el-compose-active` |
| observer registration and revocation, empty turns | `el-observers-*` |
| timer expiration, missed intervals, cancellation, equal deadlines | `el-timers-*`, `el-heap-*` |
| stale generations, revocation during dispatch | `el-revocation-*`, `el-delivery-revoke-held` |
| coroutine ownership transfer | rejections `adopt-twice`, `resume-adopted` (USE-AFTER-MOVE), `capture-task`, `el-ownership-direct` |
| nested scheduling rejection | `el-errors-reentered` |
| handler errors and shutdown | `el-errors-*`, `el-fault-channels`, `el-ownership-no-drop-action` |
| event overflow and backpressure | `el-delivery-*` |
| inactive-library noninterference, initialization orders | `el-compose-inactive` (W's trace identical alone and with an inactive library initialized before or after it), `el-compose-active` |
| the driver and capability boundaries | rejections `two-drivers`, `missing-driver`, `library-installs`, `loop-internals`, `forge-reg`, `private-helper`, `handler-callback`, `wrong-protocol`; `el-static-audit` |
| host-stepped driver, feedback union | `el-hoststep`, `el-hoststep-feedback-exact` |
| the examples | `el-example-*` |

**Native** (`tests/event-loop-linux.test`; 23 tests, on this
container: Linux x86-64, real epoll, eventfd, TCP sockets, producer threads,
SDL3 built by `tests/cffi/sdl3.tcl`): the application is built the way an
application installs the package; each program runs once on cranelift.
Native buffered-data stalls (`el-linux-buffered-lines`: the correct reader
answers all eleven buffered lines and then sees the client's later BYE
through its re-armed watch), lost-wakeup races (`el-linux-wake` with its
positive control, `el-linux-reset-window` with the race window widened),
source rotation without backpressure (`el-linux-rotation`), floods with
backpressure (`el-linux-flood`, `-quiet-source`; a watchdog makes a lost
record fail the test instead of hanging it), revocation against records in flight
(`el-linux-inflight`), the game server on sockets (`el-linux-gameserver`),
SDL3 in four modes and the mixed workload (`el-linux-sdl-*`,
`el-linux-mixed`), the native example (`el-linux-example`), the static
capability rejection and the driver audit. The timing bounds are generous
enough for a loaded 4-core container; each failure message carries its
measurement.

**Cross-backend.** The deterministic driver is ordinary Botlish: every
deterministic scenario and example runs identically on interp, compile,
cranelift-generic and cranelift. The Linux driver runs on cranelift (the
native backends; the Tcl backends refuse a C call).

**Mutation** (`tclsh9.0 audit/event-loop/tools/mutate.tcl`): «MUTATION»

**Exploration evidence.** «AUDIT-RUNS»

**Regression suites.** `tclsh9.0 tests/local.tcl -jobs 1 tests/event-loop.test
tests/context-traits.test tests/coroutines.test tests/traits.test
tests/affine.test tests/hir-interchange.test tests/hir-cache.test`: every
Tcl file on interp and compile passed (296 and 297 tests; 104 golden
duplicates skipped), and the seven golden suites that replace those
duplicates passed on all four backends (359 tests each); 29 minutes. The
warning gate passed (`audit/refactor/tools/gate.tcl`: 77 corpus programs, 32
library loaders, the manifest's two new `fails` entries for the modules
compiled as entry programs), and `tools/compilerpedia.tcl check` reported no
problem (930 topics, 650 examples run).

## 13. Compiler consistency

No compiler file changed; the event loop depends on the corrected
trait-implementation yield inference only through the host-stepped driver,
whose selected `block` yields.

**The proof obligation.** `hir::check` checks a program as written until
the coroutine analysis's feedback -- the trait-operation edges the previous
check's typing found -- stops growing, and the feedback is the *union* of
every check's edges (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md,
"Why a union"). An edge found by an early check stays even if the settled
check's typing would no longer find it -- a *stale* edge, which could add a
yield, a protocol constraint, or a diagnostic.

**The argument.** The feedback changes a check's typing in exactly two
ways: a coroutine's outward (yield and return) type gains the yields of the
implementations its edges reach, and its resume protocol gains the
implementations' declared `resume` types and use-site parameter types.
Neither can *change* a type silently:

* outward types must agree -- a coroutine whose segments end with two
  different types is COROUTINE-RESULT-MISMATCH (also two integer domains),
  and a declared result type does not depend on edges at all;
* a coroutine has exactly one resume protocol -- a second, different one is
  COROUTINE-RESUME-CONFLICT;
* with fewer edges, a type the edges would fix is not yet fixed: a
  zero-message yield's value is `unit`, a construction of a function that
  does not yet yield is not a coroutine, and neither is a trait witness.

So across checks a type only goes from unfixed to fixed, and a fixed type
stays the same unless a mismatch or conflict is reported. A trait
operation's witness, and with it every edge and specialization the plan
derives, is a function of those types. For a program the settled check
accepts, every type an earlier check fixed is the settled one, so every
edge an earlier check found is one the settled check's typing finds again:
**no stale edge in an accepted program.** In a rejected program a widening
(reported) can strand an edge; its only possible effect is on which
*dependent* diagnostics are reported.

**The adversarial test** (`tests/traits.test`,
`trait-implementation-yield-stale-edge`) constructs the stranding: `f`
yields a `WA` itself and, through a trait operation `emit` whose
implementation is reachable only through the trait, an `int`; `g`
constructs `f` and calls the trait operation `op` on `f`'s first value. The
first check binds both operations (`first` is a `WA`), the second adds
`emit`'s `int` yield, `f`'s outward type becomes `any`
(COROUTINE-RESULT-MISMATCH) and `op` is bound no more
(TRAIT-NOT-SATISFIED): the settled union holds one stale edge. Its effect:
`g` is still taken to yield, so the dependent COROUTINE-RHS-NOT-YIELDING
that the same mismatch written directly reports is not reported -- the
program is rejected either way, by the same root diagnostic. With `f`'s
result declared, and in the accepted variant, the settled check finds every
edge it was told. The test computes the stale set directly (the settled
union minus `hir::coroutines::Implementations` of the settled HIR, after
`hir::activate`). `el-hoststep-feedback-exact` checks the production
host-stepped program the same way: its one edge (`d.block()` bound to
`stepdrv::block`) is exact. A sweep of the golden suites that combine traits
and coroutines (`coroutines.bot`, `traits.bot`, `callable-contracts.bot`,
`structs-and-enums.bot`) found no stale edge.

For the event loop specifically the question cannot arise: a context
trait's implementation is selected by installation (one provider per
program), never by a type the feedback could change.

**Conclusion:** no compiler change and no follow-up are needed for
correctness. A presentation follow-up is possible: in the rejected program
above, TRAIT-NOT-SATISFIED on `any` is itself a dependent of the mismatch,
which diagnostic recovery (DIAGNOSTIC-RECOVERY.md) could suppress; it is
recorded in section 15, not fixed.

## 14. Portability

Only Linux has a native driver. What the design leaves for other platforms:

* **The scheduler** has no platform state: time is the driver's microseconds
  of one monotonic clock; a record is (slot, generation, a, b); waiting is
  `block(deadline)`. A Windows, macOS or mobile driver implements the same
  eight operations.
* **Wakeable handles.** The Linux driver wakes with an eventfd inside one
  epoll set. Windows needs an equivalent that a message pump can also wait
  on (`MsgWaitForMultipleObjectsEx` with an event, or posting a thread
  message); macOS a CFRunLoop source or a kqueue `EVFILT_USER`. The ABI's
  post/wake/pump split is platform-neutral; its header and its endpoint ids
  are not (C ints, POSIX error codes).
* **Readiness vs completion.** Watches report readiness (EPOLLONESHOT) and
  the program reads the descriptor itself. Windows' IOCP reports
  completions and owns buffers: a Windows source would post completion
  records (with copied data or a handle the program owns), not readiness;
  the scheduler is unaffected, the package API (`watch`) is Linux's.
* **Thread ownership.** The driver assumes the thread that installed it runs
  the loop (one driver per process). GUI hosts that require the main thread
  (macOS AppKit, iOS) fit; a host that calls back on its own thread needs an
  embedding milestone (section 10).
* **Host pacing.** A desktop GUI host owns its message pump; the scheduler
  can be advanced by it (`turn()`, or an externally paced driver), at the
  cost of deadline honoring (section 10). A mobile host's lifecycle
  (suspension, background limits) is a source of events (lifecycle records,
  Reliable) and a pacing constraint, not a scheduling rule.
* **Shutdown.** `shutdown` is explicit and bounded; a mobile host that kills
  a suspended process runs no shutdown, so a source must not rely on it for
  persistence.
* **File watching** fits as an ordinary source (inotify records, Coalesce or
  Reliable), outside this milestone.

## 15. Remaining limitations

Concrete and reproducible:

1. **Scheduler-internal checks.** Every table access is a checked operation
   whose failure is `SchedulerFault` (section 5.6). Removing them needs a
   proof facility for indexes stored in the scheduler's own tables.
2. **Collections.** The tables are strided `MutableVector[int]` rows (20
   integers per registration, 10 per task) with private offset constants,
   because a MutableVector of structs is a vector of values (a field update
   is a read-modify-write of the whole struct); the ready queue is two
   stacks, because MutableVector has no removal at the front; per-turn loop
   counters live in a register array, because a loop cannot update a local;
   an empty typed vector is `from_list([])` in a function with a declared
   result. None of these cost an allocation per dispatch; they cost
   readability.
3. **`extern c fn` cannot be `nomethod`**, so C calls whose first argument is
   a converted Int are written with method syntax
   (`packages/event_loop_linux/event_loop_linux.bot`,
   `examples/event-loop/native/ticker.bot`).
4. **The standard library cannot ship native code**, so the Linux driver is
   a package installed per application (section 2).
5. **`stop` is a Loop operation**: code holding only the Loop (a library's
   task) can end the current `run`. It cannot run the loop or drop tasks.
6. **No automatic registration cleanup** (section 9): a forgotten `Reg`
   stays registered until `revoke` or `shutdown`
   (`el-ownership-no-drop-action`).
7. **The ABI is Linux's** (POSIX error codes, C int endpoint ids) and
   version 1.
8. **Diagnostic presentation**: in a program the feedback union strands an
   edge in (section 13), a dependent TRAIT-NOT-SATISFIED on `any` is
   reported beside the root COROUTINE-RESULT-MISMATCH
   (`trait-implementation-yield-stale-edge`).

## 16. Recommended next milestone

**Lexical-scope resource cleanup** (the affine-resource contract of
section 9): it is the one guarantee the brief asks for that this milestone
had to leave explicit, it is a language change the event loop cannot make
by itself, and the event loop is ready to use it unchanged -- `Reg` becomes
an affine resource whose scope end revokes it, `revoke` its explicit early
release. The native drivers for other platforms and host embedding come
after it, because both multiply the places a forgotten registration can
hold native resources.

## 17. What to run when changing this

* `tclsh9.0 tests/event-loop.test` (all four backends), or through
  `tests/local.tcl` (both passes);
* `tclsh9.0 tests/event-loop-linux.test` (needs `cc`, `ar`; SDL3's tests
  need `tclsh9.0 tests/cffi/sdl3.tcl`);
* `tclsh9.0 audit/event-loop/tools/mutate.tcl` (every mutant must still
  apply and be killed);
* `tests/context-traits.test`, `tests/coroutines.test`, `tests/traits.test`
  (`trait-implementation-yield-*`);
* `tclsh9.0 audit/refactor/tools/gate.tcl`, `tclsh9.0 tools/compilerpedia.tcl
  generate` then `check`;
* `tclsh9.0 bench/event-loop.tcl` for the performance report.
