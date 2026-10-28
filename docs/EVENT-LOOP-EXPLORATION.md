# EVENT-LOOP-EXPLORATION.md

An exploratory milestone: can Botlish have **one coherent, thread-local
event-loop scheduling model** that stays predictable when an application
integrates several independently developed native libraries, some with
event loops of their own?

The work is a set of working prototypes with recorded evidence, all under
`audit/event-loop/` (no change to the compiler, the runtime or the standard
library):

| what | where |
|---|---|
| the scheduler: one module over ordinary coroutines | `audit/event-loop/src/evloop.bot` |
| a deterministic driver (virtual clock, scripted records) | `src/simdrv.bot` |
| the Linux driver: epoll, eventfd, monotonic clock, TCP, producer threads | `native/evn.c`, `src/evn.bot` |
| SDL3 in five coordination modes, SDL3's own host, a lifecycle barrier | `native/evsdl.c`, `native/evsdlhost.c`, `src/evsdl.bot`, `src/evsdlhost.bot` |
| the Win32 probe (message pump, window procedure, modal loops) | `native/win32/evwin32.c`, `native/win32/README.md` |
| workloads: a game server, composition libraries, probes | `src/gameserver.bot`, `src/quietlib.bot`, `src/busylib.bot`, `src/workload.bot`, `src/mixed.bot`, `src/sdlprobe.bot`, `src/wakeprobe.bot`, `src/benchwork.bot`, `src/ownedreg.bot` |
| scenario programs (`a-*` deterministic, `b-*` native, `s-*` must be rejected) | `src/*.bot` |
| a prototype foreign-lifetime analysis and its fixtures | `tools/lifetime.tcl`, `lifetime/` |
| the evidence harness and the benchmark | `tools/check.tcl` (+ `claims.tcl`, `static.tcl`, `native.tcl`, `native-more.tcl`), `tools/bench.tcl` |
| a compiler bug found on the way, reduced | `repro/trait-op-yield-edge/` |

Every claim in this report is either **verified** (a named check in
`tools/check.tcl` that ran in this sandbox and passed), **Wine** (run only
under Wine on Linux: a development aid, never Windows evidence, AGENTS.md),
**compiled** (cross-compiled or type-checked, not run) or **projected**
(reasoned from source code and documentation, not run). Section 11 has the
commands.

## Contents

1. [Result](#1-result)
2. [Starting evidence](#2-starting-evidence)
3. [Competing architectures](#3-competing-architectures)
4. [Proposed semantics](#4-proposed-semantics)
5. [Coroutine integration](#5-coroutine-integration)
6. [Host and library composition](#6-host-and-library-composition)
7. [The synchronous callback boundary](#7-the-synchronous-callback-boundary)
8. [Resource ownership](#8-resource-ownership)
9. [Platform matrix](#9-platform-matrix)
10. [Performance](#10-performance)
11. [Testing](#11-testing)
12. [Compiler implications](#12-compiler-implications)
13. [Recommended next milestone](#13-recommended-next-milestone)

---

## 1. Result

**A unified, thread-local scheduler is viable, and most of what makes it
predictable in a mixed native application is already in the language.**
One unmodified scheduler module (`evloop.bot`, ordinary Botlish over the
existing coroutines, MutableVectors and contexts) ran under eight drivers:
the deterministic driver on all four backends; the Linux epoll driver; the
epoll driver with SDL3 coordinated four different ways; SDL3's wait as the
loop's wait; and SDL3's own application host at 60 Hz and in "waitevent"
mode. What the experiments established:

* **Driver ownership is an application decision the compiler enforces,
  without any new feature.** The driver is a context implementing the
  context trait `evloop::Driver`; only an entry program can install a
  context (`CONTEXT-INSTALLATION-UNSUPPORTED` for a library that tries), two
  installed drivers are `AMBIGUOUS-CONTEXT-IMPLEMENTATION`, and a native
  library that needs a driver capability (`evloop::NativePumps`) the
  installed driver lacks is `MISSING-CONTEXT` -- an incompatible combination
  is a compile-time error, never a silently different driver. (Verified:
  `s-two-drivers`, `s-library-installs`, `s-sdl-needs-pumps`.)
* **Fairness is bounded and measurable.** A turn collects at most a budget
  of native records and dispatches exactly the tasks ready when its
  dispatch phase starts; continuous activity runs once per turn; a task
  made ready runs in the next turn whatever else is saturating the loop.
  (Verified on all four backends; native: quiet connections stay under
  16 ms worst-case, 0.4 ms mean, beside a 3000-line flood and a 20 000-post
  producer.)
* **Revocation has a precise contract** -- no handler invocation after
  revocation, including wakes already queued -- implemented with generation
  counters and checked at dispatch, independently of the coroutines a
  registration woke or started. (Verified.)
* **No synchronous Botlish callback was needed.** Every native callback in
  the experiments (SDL filters and watches on foreign threads, SDL's
  `SDL_AppEvent`, Win32 window procedures, cross-thread `SendMessage`) was
  contained by C code that copies scalars, answers from a policy the program
  set beforehand, and posts a record. The two cases that look irreducible
  were handled without one: a **modal loop** holding the thread (the native
  pump moved to a host fiber; Wine only), and a **lifecycle event whose
  handling must finish before the callback returns** (a C barrier holds the
  reporting thread while the program's handler runs in an ordinary turn on
  the loop's thread; verified on Linux with SDL3).
* **The scheduler allocates nothing per dispatch**: zero allocations per
  `yield_now` resume and per channel event, 0.2-0.6 us per dispatch
  natively (section 10).

What failed, or is not established:

* **No drop action.** An affine registration token cannot revoke its
  registration when it dies: a released affine value runs no code
  (AFFINE-VALUES.md). A task that ends or is abandoned holding a token
  leaves its registration registered (verified negative, `a-ownership`).
  This is the one obligation the future resource design must meet
  (section 8).
* **Embedding across exported calls is impossible today.** A Botlish native
  library cannot keep a scheduler -- tasks or a context -- between two calls
  from its host (NATIVE-LIBRARY-MILESTONE-1.md: no context, no suspension
  across the boundary, no mutable module state). The host-driven
  experiments therefore invert control inside one executable with a C fiber.
* **A host that waits for events ("waitevent") cannot honor a deadline**,
  and SDL3's needs a kick event before its first iteration or the loop never
  starts (verified: a 1.0 s gap during which a 100 ms deadline was not
  serviced).
* **Windows is untested.** The Win32 probe cross-compiles and passes under
  Wine; nothing in this report is Windows evidence. macOS, iOS and Android
  are projections (section 9).
* **Cooperative limits are real**: a segment that does not yield holds the
  thread -- including a lifecycle barrier's reporting thread (250 ms held by
  a 300 ms segment, verified).
* **One compiler bug** was found and reduced (section 12): the coroutine
  analysis takes a context-trait operation call `d.wait(...)` for a call of
  a same-named yielding function of the trait's module.

## 2. Starting evidence

What the current implementation offered, and what each fact decided:

| fact (current repository) | consequence for an event loop |
|---|---|
| Coroutines are eager, affine, resumed with zero or one struct message; `yield` is a deep, statically tracked effect (COROUTINES.md) | a task is an ordinary coroutine; "spawn" runs the first segment inside the spawner; helpers like `wait` and `sleep` can yield from any depth -- no async colouring beyond the static yield effect |
| A coroutine's messages and results must be unrestricted (AFFINE-VALUES.md, 65) | event payloads reach tasks as copies; an affine token cannot travel in a message (`s-owned-message`: COROUTINE-CONTRACT) |
| Releasing an affine value runs no Botlish code (COROUTINES.md, "Release at the last use") | an abandoned task is unwound silently; a dropped token cannot revoke anything |
| An installed context may own affine values in MutableVectors (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md); element places observe but are not mutation receivers | the scheduler owns its tasks in vectors of handles; a slab of optional tasks is not expressible, so tables are parallel int vectors and tasks move between queues |
| Contexts are installed only at the entry program's top level; a function value that requires a context is rejected (CONTEXTS.md) | only the application chooses the driver; handlers that need the loop must be coroutines, not callbacks (`s-handler-callback`) |
| A context trait is satisfied by the one installed context implementing it, from its owner's namespace only (CONTEXT-TRAITS.md) | drivers are context-trait implementations; a library cannot retrofit a capability onto a driver |
| Botlish code cannot be called from C except through a native library's exported functions, which carry no state or suspension across calls (C-FFI.md, NATIVE-LIBRARY-MILESTONE-1.md) | every native callback must be contained in C; host-driven embedding needs a C fiber |
| Static archives link through `extern c library "NAME" static at "PATH"` (NATIVE-LINK-PLAN-MILESTONE-1.md) | adapters are small C archives beside the program |
| The standard library's I/O is syscalls (Linux), libSystem (macOS) and kernel32 (Windows), with no readiness or wait API | the drivers are new C; the I/O libraries need no change |
| SDL3 and Win32 bindings are generated; Icy Tower polls SDL once per frame (ICY-TOWER-VERTICAL-SLICE-1.md) | SDL is a real native library to integrate, with real callbacks |

## 3. Competing architectures

### 3.1 Where the scheduler lives

| option | verdict |
|---|---|
| **a Botlish module owning tasks in a context** (built) | works on every backend; driver and sources are contexts |
| a C or runtime scheduler calling Botlish handlers | impossible today (no callbacks into Botlish), and would make every handler a reentrant callback |
| one coroutine per source, resumed by the application | composes badly: N sources need N resume sites, and nothing bounds a source's share of the thread |

### 3.2 How tasks, waits and payloads are represented

| option | measured |
|---|---|
| **zero-message protocol, `int` requests, wake registers in the context; tables as parallel int vectors; handles moved between a FIFO, a parked set (swap-remove) and per-registration waiter lists (linked through int vectors)** (built) | 0 allocations per dispatch and per turn on the yield path; O(1) park, wake and FIFO |
| struct requests and struct wake messages (`Want`, `Wake`) | 1 to 2 allocations per step (the first spike) |
| a slab of optional tasks (`MutableVector[Cell]`, `cell.task.pop()`) | not expressible: an element place is not a mutation receiver (MUTABLE-PLACE-RECEIVER) |
| a slab of one-element Lists (`swap(i, [task])`) | expressible, one allocation per park |

### 3.3 How handlers are written

Handlers are **tasks**: a coroutine that waits on a registration in a loop.
A function value cannot require a context (`CONTEXT-FUNCTION-VALUE`), so a
callback could not even reach the loop; a coroutine's providers are fixed at
its construction, so a task can. "Start a task per event" is a listener task
that constructs one (the game server's acceptor); "once per turn" is a task
waiting on an observer registration.

### 3.4 How independent sources share the one wait

The decisive comparison (SDL3 events pushed by a producer thread at about 2 ms
intervals, SDL's own timer thread, a producer thread's posts, a 7 ms timer,
then a 200 ms idle sleep; `b-sdl-*.bot`, verified, one representative run):

| mode | SDL events: max latency (late > 5 ms) | posts: max | 7 ms timer: worst lateness | idle 200 ms: wakeups, CPU |
|---|---:|---:|---:|---:|
| 1 wakeup: SDL's filter copies and posts (eventfd) | 3.7 ms (0) | 4.8 ms | 3.1 ms | 1, 96 us |
| 2 pump: a check hook copies, sleeps capped at 10 ms | 10.1 ms (68 of 260) | 0.5 ms | 0.4 ms | **20**, 1233 us |
| 3 hybrid: a watch wakes, a check hook copies | 0.2-12 ms (0-7) | 0.3-8.9 ms | 0.5-5.5 ms | 1, 127 us |
| 4 naive: the check hook alone (negative control) | **98.8 ms (123)** | 2.5 ms | 1.0 ms | 1, 136 us |
| 5 SDL's wait is the loop's wait | 1.1 ms (0) | 4.2 ms | 1.1 ms | 1, **5898 us** |
| host 60 Hz: SDL's host iterates; one turn per iteration | 17.3 ms (174) | 17.2 ms | 6.7 ms, 18 missed | (host-paced) |
| host "waitevent": an iteration only after an SDL event | 1.4 ms (0) | 3.4 ms | 2.4 ms | gap **1.0 s** |

(Hybrid's range is two runs: the 12 ms run had a machine-wide hiccup that
also delayed its posts and timers. The claims are written to hold through
such runs; section 11.)

* The **wakeup protocol** (a thread-safe post plus an eventfd edge) and the
  **hybrid** (a wakeup from the library's own callback, the data copied on
  the loop's thread) are the protocols to standardize: immediate, and one
  wakeup per idle sleep.
* The **pump protocol** (prepare/check, GLib's model) is necessary for a
  library that has no callback and no descriptor -- it is the only way to
  include it -- but must poll: its cap is both its latency bound and its
  idle cost.
* **Letting a library own the wait** keeps that library fast and degrades
  everything else; its own idle behaviour becomes the program's (SDL's
  events-only wait costs 30x the CPU).
* A **host-driven** loop runs at the host's pace; the scheduler's deadlines
  are requests, not guarantees (section 6).

### 3.5 How an external host advances the scheduler

| option | verdict |
|---|---|
| the host calls an exported Botlish function per iteration | impossible today: an export cannot require a context or suspend, and nothing else persists between calls |
| **the host's loop runs on a C fiber; the driver's `block` switches to it and returns when the host calls back** (built: `evsdlhost.c`, SDL_EnterAppMainCallbacks) | works; Botlish is never called back; one turn per host iteration |
| the same inversion for Win32 modal loops (`evwin32.c`) | Wine only: 33-36 turns ran inside a 2.4 s modal dialog, against none without it |

## 4. Proposed semantics

### 4.1 The scheduling turn

A **turn** is, in order:

1. **wait** -- the driver blocks until a native record is available, a wakeup
   arrives or the earliest deadline a task waits on passes; it does not
   block when ready work exists (it polls), and it does not block for a
   timer nobody waits on;
2. **collect** -- expired timers, earliest deadline first (registration
   order among equal deadlines), then at most `budget` native records in
   the order the driver delivers them; each record goes to its
   registration: its first waiter becomes ready, else the event is queued
   (at most `cap` per registration; the excess is counted and dropped);
3. **dispatch** -- exactly the tasks ready when this phase starts, in the
   order they became ready; work made ready during the phase (a yield, a
   post, a spawn, a revocation's wakes) runs in the next turn;
4. **observe** -- every observer registration live when this phase starts
   runs its waiting task once, in registration order -- only in a turn whose
   collect or dispatch did something.

A wakeup that delivers nothing (a stale record, a spurious eventfd edge) is
an **empty turn**: no observer runs in it (`a-observers`).

### 4.2 Ordering and fairness guarantees

What holds, given cooperative tasks:

* **Readiness order is FIFO, whatever made a task ready.** A wake by an
  event, a timer, a revocation or a `yield_now` gets no priority. Within one
  collect phase, timers precede native records and records keep the
  driver's order -- a tie rule for things that became ready at the same
  instant, not a priority.
* **Bounded per-turn work.** A turn dispatches at most the tasks ready at its
  start (each at most once) and collects at most `budget` records; a source
  cannot fill a turn (`a-fairness`: never more than 8 of a 400-record
  burst).
* **No starvation of ready work.** A ready task runs within one turn of
  becoming ready, however many others yield continuously or replenish the
  queue (`a-fairness`: a bystander runs in the next turn beside a 61-
  generation self-spawning storm, a 40-step greedy task and a flood).
* **Bounded delay behind bursts, not fairness between sources.** The driver's
  record queue is FIFO: a record behind a burst of B waits B/budget turns
  (`a-fairness`: 50 turns behind 400). The Linux adapter adds per-descriptor
  quotas and credit; a production driver should round-robin sources.
* **A task handling one event per wake runs at one event per turn.** Draining
  the queue with `try_take` inside the wake is the efficient form; under a
  host that grants one turn per iteration it is the difference between 60
  events per second and all of them (`b-sdl-host60`, first run).

What does **not** hold, and is not promised: preemption (a segment that
never yields holds the thread, the lifecycle barrier's reporting thread
included), wall-clock progress under a host that withholds turns, and
fairness between sources sharing one native queue.

### 4.3 Once-per-turn observers

`evloop::observer()` makes a turn registration; a task waiting on it runs
once in every eligible turn. Precisely (`a-observers`, all four backends):

* registered **before or during a dispatch phase**: runs in that turn's
  observer phase; registered **during an observer phase**: first runs in the
  next turn;
* **revoked before its place in the phase** (by an earlier observer):
  skipped; its task wakes with `woke_revoked` in the next dispatch, never
  having run as an observer;
* **revoking itself**: the current run completes; there is no next;
* an observer **never keeps the loop alive** and never causes a turn: an
  idle loop sleeps (one wakeup and about 100 us of CPU per 300 ms sleep with
  an observer registered, `b-wake`), and run returns while an observer still
  waits;
* it is **not** a timer and not a frame clock: frame work is a repeating
  timer (`a-timers`: 6 frames over 306 turns).

This is stronger than Tcl's `after idle` (which runs "when idle", not once
per turn, and whose re-registration from inside the callback defers to the
next idle point) and avoids the `after 0` busy loop: nothing about an
observer makes the loop poll.

### 4.4 Timers

* One monotonic clock (CLOCK_MONOTONIC natively; the virtual clock in
  `simdrv`), read once per turn; `after`/`every` count from the turn's time
  (`evloop::sync` reads the clock outside the loop).
* A **repeating timer never queues missed expiries**: one wake reports the
  intervals missed (`a.missed`), and the next deadline stays on the period's
  grid (`a-timers`: a 350 us segment of a 100 us timer reports 2 missed and
  the timer stays on its grid; a 10 s jump reports 999 999, computed by
  doubling, not per interval).
* An unwatched timer's expiries coalesce into a count its next waiter
  receives at once.
* A timer is late by at most one turn's work plus the driver's wake latency
  when the loop owns the wait; under a host, by up to the host's period or
  arbitrarily ("waitevent").

### 4.5 Liveness, errors, shutdown, reentrancy

* **Live** = a task is ready, or a task waits on a registration that keeps the
  loop alive (timers, and sources registered with `keep 1`). Channels,
  observers and optional sources (`keep 0`) do not. `run` returns when
  nothing is live (or on `stop`, or when the driver says no record can ever
  arrive).
* A task's **declared failure** (`TaskFailed`, or `IndexNotFound`, the one
  error every scheduler operation may raise) ends that task and is recorded;
  nothing else is affected. A failure in a task's **first segment** reaches
  the spawner, because construction is eager.
* **Shutdown** revokes every registration (waiters wake with `woke_revoked`
  and may finish), runs a bounded number of turns, then abandons what is
  left: each remaining coroutine is released without running any of its
  code.
* **Reentrancy**: `run` or `turn` from inside a dispatch (a nested loop, Tcl's
  `vwait` inside a handler) fails with `LoopReentered` (`a-errors`). Direct
  resumption of a task's own child coroutines inside its segment is ordinary
  and allowed.

### 4.6 Revocation

`revoke(reg)` bumps the registration's generation and guarantees:

1. no handler invocation after it: queued events are discarded, and a wake
   already queued for a task is checked against the generation at dispatch
   and replaced by `woke_revoked` -- with no event data (`a-revocation`);
2. waiters wake with `woke_revoked`, in the order they waited; they are not
   cancelled -- they decide what to do;
3. code already running is not undone: a handler revoking its own
   registration completes its invocation;
4. records still in flight from the native side carry the old generation
   and are dropped as stale, also after the slot is reused;
5. revoking twice, or through a stale copy, does nothing;
6. tasks a registration started are independent of it: they finish after it
   is revoked.

## 5. Coroutine integration

* **Adoption moves ownership.** `coroutine {step, first} = task(...)` runs the
  first segment; `evloop::adopt(step, first)` moves the handle into the
  loop's context. Adopting twice, or resuming after adopting, is
  `USE-AFTER-MOVE` (`s-adopt-twice`, `s-resume-adopted`): direct and
  scheduled advancement coexist, never for the same coroutine at once.
* **One coroutine, many kinds of wake, no duplication.** A task is moved
  between the run queue, the parked set and waiter lists as its waits
  change (timer, channel, source, turn); only handles move.
* **Direct advancement inside handlers is ordinary.** Each game-server
  session drives its own dialogue coroutine (its own protocol: `resume
  Line`, yields `Reply`); the world task advances an AI coroutine one step
  per tick (`a-gameserver`, `b-gameserver`).
* **No delegation.** A child coroutine's yields go to its resumer, never to
  the scheduler (COROUTINES.md, point 14): a dialogue that needs a path
  replies "find", and its session -- a task -- spawns the pathfinding task
  and waits on its result channel. This is explicit forwarding; a
  `yield from` would be a language feature, and nothing here required one.
* **One protocol per scheduler.** Every task is `Coroutine{args: [], return:
  int, errors: [TaskFailed, IndexNotFound]}`; a coroutine of another
  protocol is a `TYPE` error at `adopt` (`s-wrong-protocol`) and is driven
  directly by its owner instead. Because Botlish has no catch-all error, the
  protocol enumerates the errors it carries -- every task inherits
  `IndexNotFound` from the scheduler's own operations.
* **Eager start is visible.** Spawning runs the task until its first wait,
  inside the spawner; a task that should start later begins with
  `yield_now`.

## 6. Host and library composition

### 6.1 The invariants

| # | invariant | status | evidence |
|---|---|---|---|
| 1 | importing or initializing an inactive library changes no other work's order or progress | **verified** (deterministic: byte-identical traces, turns included, library initialized before or after; native: the base workload's order identical in both initialization orders) | `a-compose-*`, `b-mixed-*` |
| 2 | a busy source cannot indefinitely starve an unrelated ready continuation | **verified** (bounded by one turn; native: quiet connections 0.2-16 ms worst case beside a flood) | `a-fairness`, `b-gameserver`, `b-mixed-*` |
| 3 | an adapter cannot process an unbounded stream before returning | **verified** (`budget` per turn; the Linux adapter's per-descriptor quota and credit: 2971 pauses for credit, its ring never above capacity) | `a-fairness`, `b-gameserver` |
| 4 | work registered while the loop sleeps is not lost | **verified**, with a positive control: the racy protocol delays 15-21 posts to the heartbeat (up to 41 ms), the eventfd protocol none; 2000 randomly timed posts at the C level, none held to the 1 s deadline | `b-wake`, `b-wake-broken`, `evn_test` |
| 5 | deadlines are not silently postponed because a library polls | **verified for the loop's own wait** (timers late by < 0.5 ms); **violated by construction** when a library or host owns the wait: a pump-only library postpones events to its cap, a naive one to the next unrelated wake (99 ms), SDL's "waitevent" host by 1.0 s | `b-sdl-*` |
| 6 | host-driven execution keeps the scheduling semantics, at the host's pace | **verified** (SDL3 host, 60 Hz: the same turn semantics, one turn per iteration, missed timer intervals coalesced; all deliveries) with the acknowledged limit that progress happens only when the host iterates | `b-sdl-host60`, `b-sdl-hostwait` |
| 7 | incompatible host requirements are reported, not resolved silently | **verified** statically (two drivers; a capability the driver lacks; a library installing a context); dynamically, a host that cannot start the loop without help is detected (SDL's "waitevent" needs a kick) | `s-*`, `b-sdl-hostwait` |

Invariant 1 cannot be stated as "noninterference": an active source always
consumes turns. What holds is that it cannot reorder another library's work
or take more than its bounded share of a turn.

### 6.2 Linux: one process, every source

`b-mixed-sdl-first.bot` and `b-mixed-net-first.bot` run SDL3 (hybrid
coordination), the TCP game server with a 2000-line flooding client, a
producer thread's posts, the probe's timers and tasks and the base workload
W together, initialized in both orders (verified, one run each):

| | SDL first | network first |
|---|---:|---:|
| SDL events delivered / max latency | 260 / 0.2 ms | 260 / 0.3 ms |
| posts delivered / max latency | 200 / 0.3 ms | 200 / 0.3 ms |
| replies (quiet, quiet, flood) | 41 / 41 / 2001 | 41 / 41 / 2001 |
| quiet connections' worst network-to-handler latency | 0.2 / 0.4 ms | 0.3 / 0.3 ms |
| the flood's worst latency (paced by credit and TCP) | 50 ms | 48 ms |
| 7 ms timer worst lateness | 0.5 ms | 0.2 ms |
| W's own order | identical | identical |

The game server alone (`b-gameserver`: four clients, one a 3000-line flood,
a 20 000-post producer thread, a 20 ms world timer) delivers every reply,
keeps the quiet connections under 16 ms worst case, and reads the flood only
on demand.

### 6.3 Windows (Wine only)

The probe (`native/win32/evwin32.c`) waits on the wakeup event, a socket's
`WSAEventSelect` event and the thread's message queue with one
`MsgWaitForMultipleObjectsEx`; a window procedure copies messages and
answers from a policy table; SDL3's windows, being the thread's, share the
same wait (compiled only). Under Wine 9.0 + Xvfb both modes deliver all 200
posts and 200 posted messages, contain a cross-thread `SendMessage(WM_CLOSE)`
(the window still exists; the procedure ran on its own thread) and handle a
socket; in a 2.4 s modal dialog the direct mode runs no turn while the
inverted mode runs 33-36. None of it is Windows evidence.

## 7. The synchronous callback boundary

| native callback | thread | needs an immediate answer | contained how | status |
|---|---|---|---|---|
| SDL event filter / watch | any (here: producer and timer threads, 310 of 311 calls) | filter: keep or drop | copy + post; answer from a policy set beforehand (50 events dropped by policy) | verified |
| an SDL callback inside a task's own C call (a nested native dispatch) | the loop's, nested | -- | copy + post; delivered in a later turn, never inside the segment | verified (all modes) |
| SDL_AppEvent (SDL's host) | the loop's | continue / quit | copy; C policy decides quit | verified |
| Win32 window procedure (WM_CLOSE, WM_GETMINMAXINFO, WM_QUERYENDSESSION) | the window's (cross-thread SendMessage is marshaled into its pump) | yes | copy; policy table | Wine |
| a modal loop (MessageBox, window move/size) | the loop's, held inside DispatchMessage | -- | pump on a host fiber; the modal loop's WM_TIMER switches to the loop for a turn | Wine |
| WILL_ENTER_BACKGROUND (SDL: "do any life cycle handling in an event filter while the event was being queued", SDL_androidevents.c) | the lifecycle thread | **the handling itself** | barrier: post to the loop, hold the reporting thread until the loop's handler acknowledges (or a deadline) | verified (Linux, simulated reporting thread) |

**Conclusion: C-side containment suffices for every case tested, without a
synchronous Botlish callback.** Two boundaries are irreducible and need
more than a copy -- both were handled by keeping Botlish on its own thread
and stack:

* **A foreign loop that holds the thread** (Win32 modal loops, SDL's host,
  iOS's run loop): run the foreign loop on a fiber and give the scheduler
  turns between its callbacks. Botlish code never runs inside the foreign
  callback's frame, so there is no reentrancy into a running segment.
* **Work that must finish before a callback returns** (mobile lifecycle):
  the barrier. Its cost is the cooperative limit: the reporting thread waits
  for the current segment to end (250 ms behind a 300 ms segment) and is
  released by a deadline if the program never answers.

Reentrancy: a native library cannot run a second Botlish handler while one
is in progress, because no native code can call Botlish at all; the
scheduler refuses a nested turn (`LoopReentered`). The irreducible
reentrancy boundary is the C one -- SDL calls its filter synchronously
inside `SDL_PushEvent` from a task's segment -- and the adapter keeps it in
C.

**Where a synchronous Botlish callback would still be needed** (not
encountered, analysed): a callback whose answer depends on program state
that cannot be precomputed into a policy -- custom hit-testing of a
borderless window (`WM_NCHITTEST`, `SDL_SetWindowHitTest`), a renderer's
per-frame callback that must draw before returning. With the inverted
loop, the adapter can run one bounded turn and read the answer the program
left in a policy cell -- possible only when the callback does not arrive
inside a Botlish segment. The smallest facility that would cover the rest
is not a callback feature but a runtime one: **a scheduler entry point a
foreign stack can resume while the program's stack is parked** -- what the
C fiber does by hand -- with a static rule that the turn it runs cannot
reach the segment that called out.

## 8. Resource ownership

* **Identity.** A registration is `Reg {slot, gen}` (unrestricted): revoking
  through a stale copy does nothing, so copies are harmless.
* **Owned registrations.** `ownedreg::Owned` makes ownership affine with a
  zero-cost marker (a null `std::ffi::c::Ptr`, an immediate word): one owner;
  moved into a task at its construction (the thunk moves its arguments);
  never through a resume message (`COROUTINE-CONTRACT`); two owners are
  `USE-AFTER-MOVE` (`s-owned-twice`); `release(token)` consumes it and
  revokes (verified, `a-ownership`).
* **No borrow.** Reading the registration out of a token consumes the token:
  `peek` hands it back together with the identity (the "thread it through"
  idiom), which is clumsy and allocates.
* **The missing piece.** When a token dies unreleased -- its task finished,
  or was abandoned at shutdown -- the coroutine and the token are released,
  and the registration stays registered (verified negative). Revocation by
  cleanup needs an obligation the language does not have.

Obligations the future affine/resource design must meet for event
registrations:

1. **A drop action that runs no Botlish code**: releasing a resource value
   invokes a registered runtime-level action (here: revoke slot, generation)
   -- consistent with "a release never runs Botlish code" and with releases
   at last use, on every early exit and on abandonment.
2. **Drop order** on abandonment and on a context's (absent) teardown must
   be specified: today nothing a context owns is released at program end.
3. **Moves through construction only** stays right: an unreceived message
   would drop a resource silently.
4. **Observation without consumption** (a borrow-free way to read a
   resource's identity) would remove the `peek` idiom.

Registration lifetime and coroutine lifetime stay independent without a
task hierarchy: the loop owns tasks; registrations are rows; revocation wakes
waiters but never touches tasks it did not wake.

## 9. Platform matrix

| platform | scheduler + deterministic driver | native driver | SDL3 | host-driven | status |
|---|---|---|---|---|---|
| Linux x86-64 | all four backends | epoll, eventfd, TCP, threads | five modes, host, barrier | SDL host via ucontext fiber | **verified** |
| Linux AArch64 | same code | same C | same | same | projected (nothing architecture-specific; not run) |
| macOS AArch64 | same code | kqueue (an `EVFILT_USER` wakeup) | hybrid works the same; SDL's Cocoa backend pumps the main run loop | CFRunLoop observers or SDL's host | projected |
| Windows x86-64 | same code | MsgWaitForMultipleObjectsEx (64-handle limit: sockets beyond it need IOCP) | shares the thread's message queue | fibers (also the runtime's coroutine mechanism) | compiled; **Wine only** |
| iOS | same code | -- | SDL's host is a CADisplayLink on the main run loop (`src/main/ios/SDL_sysmain_callbacks.m`) | the only model: host-driven, main thread | projected |
| Android | same code | ALooper (`ALooper_addFd`, a pipe or eventfd wakeup) on the app's own thread | SDL runs the app on its own thread; lifecycle comes from the Java thread | not needed | projected |

**Mobile census.** What carries over unchanged: the turn, the ordering and
fairness rules, revocation, observers, the deterministic driver, C-side
containment. What needs a separate driver class:

* **iOS** owns the main thread's run loop (UIApplicationMain): the scheduler
  can only be host-driven -- a CADisplayLink or CFRunLoopObserver gives it
  turns, exactly the `evsdlhost.c` model, and the same inversion (the
  Botlish main parked in a C call) is what lets the host's callbacks give it
  turns. Deadlines are requests to the host (a CFRunLoopTimer per earliest
  deadline is the faithful mapping).
* **Android** lets the app own a thread (SDL does: `SDLActivity` starts the
  app thread), so the Linux design applies with ALooper in place of epoll;
  lifecycle callbacks arrive on the Java UI thread and must be handled before
  they return -- the barrier, crossing threads.
* **Suspension is not cancellation and not disposal.** A suspended process
  keeps every task and registration; nothing is revoked or released. On
  resume, timers that expired during suspension are late: a repeating timer
  reports the missed intervals (one wake), never a burst. The monotonic
  clock matters: CLOCK_MONOTONIC stops during suspend on Linux and Android,
  CLOCK_BOOTTIME does not; a driver must state which it uses.
* **Fairness applies only while the loop may run.** Nothing here implies
  background execution; the barrier gives the program one chance to save
  state before the system suspends it, bounded by a deadline.
* An assumption that would make mobile hard, and the prototype avoids: that
  the program owns `main` and its thread's loop. A library-mode Botlish
  (NATIVE-LIBRARY-MILESTONE-1.md) cannot be host-driven today because
  nothing survives between calls (section 1).

## 10. Performance

Measured with `tclsh9.0 audit/event-loop/tools/bench.tcl` (native
Cranelift; the deterministic driver for allocations, the epoll driver and
real time for costs; best of 3 runs; one 4-core container, nothing else
running).

| workload | dispatches | turns | CPU | per dispatch | per turn |
|---|---:|---:|---:|---:|---:|
| 100 tasks x 1000 `yield_now` | 100,000 | 1,000 | 23.2 ms | 0.23 us | 23 us |
| channel ping-pong, 100,000 events | 200,000 | 100,000 | 124 ms | 0.62 us | 1.2 us |
| 10 tasks x 200 sleeps | 2,000 | 200 | 5.7 ms | 2.9 us | 29 us |
| 100 tasks x 200 sleeps | 20,000 | 200 | 60 ms | 3.0 us | 302 us |
| 1000 tasks x 20 sleeps | 20,000 | 20 | 336 ms | 16.8 us | 16.8 ms |

* **Allocations: 0 per dispatch** for a `yield_now` and **0 per event**
  for a channel post and wait (two dispatches), counted by the native
  allocation report as the difference between two sizes of the same
  program (50,000 more dispatches; 5,000 more events), with the
  deterministic driver's own sites left out (it allocates per turn, its own
  bookkeeping: 10,000 more allocations at the larger size). The scheduler's
  allocations are its setup (59 and 42), the same at both sizes. Before the
  fix (section 11, bugs found) a dispatch cost about 5 allocations.

* **Wakeup latency** (`b-wake`, epoll driver, a producer thread posting at
  jittered 1 ms intervals): post to dispatch mean 0.09-0.11 ms, max 0.3-3 ms
  over 300 posts; the deliberately racy protocol: up to 41 ms.
* **Idle**: a 300 ms sleep takes one wakeup and 90-120 us of CPU, with or
  without an observer registered; SDL3 in the hybrid mode adds nothing
  (127 us per 200 ms), a 10 ms polling cap costs 20 wakeups and 1.2 ms per
  200 ms, and SDL's own events-only wait 5.9 ms per 200 ms.
* **Limits.** The prototype finds each expired timer by a scan of every
  registration, once per expiry: O(registrations x expiries) per turn,
  which is quadratic when all timers expire together (the sleep rows: 3 us
  per dispatch at 10 and 100 sleepers, 16.8 us at 1000). A production
  scheduler needs a deadline heap (or a timer wheel), O(log n) per expiry. The
  per-turn `epoll_pwait2` poll while work is ready costs a system call per
  turn (the ping-pong row). Times are a shared container's: treat them as
  orders of magnitude.

## 11. Testing

All evidence is `tools/check.tcl`:

```
tclsh9.0 tests/cffi/sdl3.tcl                              # once: the headless SDL3 (optional)
tclsh9.0 audit/event-loop/tools/check.tcl                 # everything
tclsh9.0 audit/event-loop/tools/check.tcl -parts sim      # deterministic, all four backends
tclsh9.0 audit/event-loop/tools/check.tcl -parts static   # must-reject programs, driver audit
tclsh9.0 audit/event-loop/tools/check.tcl -parts lifetime # the lifetime analysis
tclsh9.0 audit/event-loop/tools/check.tcl -parts native   # C adapters, Linux, SDL3, Win32 under Wine
tclsh9.0 audit/event-loop/tools/check.tcl -only a-fairness  # one scenario
tclsh9.0 audit/event-loop/tools/bench.tcl                 # section 10
```

(`LANG=C.utf8 LC_ALL=C.utf8`, `tclsh9.0` and the release native backend, as
for the test suite.)

**Recorded result** (this sandbox, 2026-10-28, Linux x86-64, 4 cores, the
headless SDL3 built, MinGW-w64 13 and Wine 9.0 installed): **129 of 129
claims hold** -- sim 61 (every `a-*` program with identical outcomes on
interp, compile, cranelift-generic and cranelift), static 13, lifetime 5,
native 50 (the Win32 probe's two modes under Wine among them). The
deterministic part takes about 5 minutes and the whole check under half an
hour, most of it compilation (each native program runs a few seconds of
real time).

What the parts cover:

* **sim** (all four backends, outcomes required identical; each program
  compiled with `-warnings error`): `a-smoke`, `a-fairness` (saturation:
  continuous activity, a self-replenishing queue, two 200-record floods, a
  bystander, a ticker), `a-observers` (registration during dispatch and
  during the phase, revocation before and during, self-revocation, empty
  turns, liveness), `a-timers` (missed intervals, grid, equal deadlines, a
  10 s jump, coalescing, frames vs turns, bounded queues), `a-revocation`
  (the six revocation rules), `a-errors` (failures, eager-construction
  failure, nested turn, liveness, stop, shutdown, abandonment),
  `a-gameserver` (the workload), `a-ownership` (tokens; two negative
  claims), `a-compose-*` (inactive and active libraries, init order).
* **static**: eleven programs the compiler must reject, each with its
  diagnostic, and the driver audit (a library function that requires the
  driver is reported; the experiments' own programs have none).
* **lifetime**: the prototype analysis on its four fixtures and on every
  experiment program.
* **native**: the adapter's C tests (the buffered-lines stall below, the
  cross-thread wakeup race), `b-wake` and its positive control, the game
  server, the five SDL modes, the SDL host at 60 Hz and "waitevent", the
  lifecycle barrier, the mixed process in both initialization orders, the
  Win32 probe under Wine.

Deliberately adversarial cases: the racy wakeup protocol (positive control
for lost wakeups); the naive SDL mode (negative control for postponed
events); a 61-generation self-spawning task storm; floods on sockets and
cross-thread queues with demand-driven reading; revocation racing a queued
wake, in-flight native records and slot reuse; a nested turn; tokens
dropped unreleased; a 300 ms non-yielding segment against the lifecycle
barrier; a host that never iterates.

Bugs the tests found in the prototype (fixed, each now pinned): a
connection paused for credit with complete lines buffered in the adapter
stalled forever once its peer stopped sending -- level-triggered readiness
does not cover a library's own buffer (`evn_test buffered-lines` fails
without the fix: 9 of 11 lines); `SDL_PushEvent` returns false when a filter
drops the event, so retrying duplicated events or spun forever; timers made
before the first turn read time 0; a suppressed wake still exposed its
event's payload; trace strings and per-turn scratch arrays allocated on
every dispatch.

Known limitations: the native claims are timing bounds on a shared machine,
written loosely enough to hold through its hiccups (each prints its
measurement); the interpreter runs the deterministic suite in minutes;
Windows is Wine; nothing ran on macOS, AArch64 or mobile.

## 12. Compiler implications

**Implemented in the compiler: nothing.** Everything above runs on the
current compiler. Implemented outside it, as audits over HIR:

* **The driver audit** (`tools/static.tcl`): lists every function whose
  transitive context requirements include `evloop::Driver` -- the authority
  to make the loop wait and turn -- and reports the ones in modules the
  application declares to be libraries. The requirement is already visible
  (`main.tcl -contexts`); no new diagnostic is needed.
* **The foreign-lifetime analysis** (`tools/lifetime.tcl`): with the one fact
  a foreign contract has today -- a pointer result is `independent`, `alias
  P` or (by default, and for every generated binding) unknown -- it reports
  an unknown-provenance pointer that is **captured by deferred work** (a
  task's construction) or **bound before a statement that may suspend and
  used after it**. Fixtures: `l-capture-unknown` and `l-across-yield` are
  reported, `l-capture-independent` and `l-copied` are not; all four are
  accepted by the compiler today; the experiments' own programs have no
  finding.

Why it stays an audit: unknown provenance is every generated binding's
default, so a compiler warning on it would flag owned handles
(`SDL_CreateWindow`'s window) as readily as borrows (`SDL_GetError`'s
string). The missing compiler information is a **validity fact** on a
pointer result: `owned` (valid until released), `static`, or `until NAME`
(valid until the next call of a named function or library), declared by
profiles in the binding generator. With it, two narrow, proof-backed
warnings follow directly from this analysis -- a borrow held across a
suspension, and a borrow captured by deferred work.

Findings for the compiler and language:

* **Bug: a context-trait operation is taken for a same-named yielding
  function of the trait's module** in the coroutine call graph
  (`repro/trait-op-yield-edge/`: `d.wait(5)` with a yielding `wait(reg:
  Reg)` in the same module; the value is the trait's, but the program is
  rejected with `UNWRAPPED-YIELD`). Worked around by naming the driver
  operations `clock` and `block`.
* **Friction** recorded while writing a thousand lines of scheduler: element
  places cannot receive mutations, so optional slots become parallel
  vectors; every scheduler operation carries `IndexNotFound`, which every
  task protocol must then list (no catch-all); a discarded collecting loop
  still builds its List, and an argument expression is evaluated before the
  callee can decide it is unused (trace strings); `METHOD-ELIGIBLE` fires on
  most internal helpers (`nomethod` everywhere); `loop` is a keyword (a
  context named `ev`); forward references require callee-first ordering;
  there is no integer division (`periods_due` doubles instead).

## 13. Recommended next milestone

**EVENT-LOOP-MILESTONE-1: the scheduler and the Linux driver as a library,
with the wakeup protocol as the native integration ABI.** Narrowly:

1. Fix the trait-operation yield-edge bug (section 12).
2. Promote `evloop`'s semantics -- section 4, unchanged -- into a standard
   library module with the deterministic driver for tests: the turn,
   budgets, observers, timers on a heap, generation-checked revocation,
   `LoopReentered`.
3. A runtime-provided Linux driver (epoll, eventfd, monotonic clock)
   implementing the driver trait, and a small C ABI for native libraries:
   `post(slot, gen, a, b)` (thread-safe, edge-signalled), `wake()`, and the
   pump hooks for libraries that cannot be woken -- so an SDL-style library
   integrates by a few lines of C, as `evsdl.c`'s hybrid mode does.
4. Carry the claims of `audit/event-loop/tools/check.tcl` over as the
   module's tests.

Deferred, each needing its own design: a drop action for resources (section
8); validity facts for foreign pointers and the two warnings (section 12);
host-driven embedding without a C fiber (a scheduler entry point a foreign
stack can resume); Windows, macOS and mobile drivers, after a Windows run of
the probe.
