// Rust equivalent of bench/experimental/game-server.bot: the game-server
// workload of EVENT-LOOP-EXPLORATION.md (audit/event-loop/src/gameserver.bot)
// on a port of the audit's prototype scheduler (evloop.bot) and of its
// deterministic virtual-clock driver (simdrv.bot), at the entry's scale
// (CONNS connections of LINES lines, a world of TICKS ticks every PERIOD
// microseconds, a budget of 8 records per turn, no scheduler trace).
//
// Invoked by bench/bench.tcl; see bench/equivalents/rust/fib.rs for the
// --runs/value/best_us protocol shared by every equivalent. Every run builds
// everything from scratch -- the loop, the driver, its script -- and runs the
// loop to its end, as one run of the Botlish program does. The value is the
// Botlish program's: the scheduler's counters (turns, dispatched, completed,
// observed, stale), the number and checksum of the values sent, the checksum
// of the tasks' results (id, value pairs in completion order: the ids depend
// on the free list's reuse order) and the trace's line and character counts
// (so its texts are the Botlish ones, "t=TURN: text"). It is printed as
// core::value::show renders a Botlish List of Int.
//
// How the Botlish structure maps:
//
// * evloop's tasks are Botlish coroutines of one protocol: a segment yields
//   an int request (-1: run me again; else the slot of the registration it
//   waits on) or returns the task's result. Here a task is an async fn --
//   Rust's own stackless coroutine -- boxed as Pin<Box<dyn Future<Output =
//   i64>>> and resumed by the scheduler itself (run_task), a single-threaded
//   executor with a no-op waker: nothing is ever woken through a Waker, the
//   loop decides who runs. `wait`/`yield_now` await a Suspend future that,
//   on its first poll, writes its request to the request register and
//   returns Pending; resumed, it is Ready, and `wait` reads the loop's wake
//   registers, as evloop::wait does right after its yield. A wait inside an
//   awaited async fn (pathfind, inside a session) suspends the whole task,
//   as Botlish's deep yield does.
// * Botlish coroutines start eagerly: `coroutine {step, first} = f(...)` runs
//   f up to its first yield inside the constructing code. `start` polls a new
//   task once, right there, and takes its request as `first` (Ready at that
//   poll: done at start); so its side effects -- slots and task ids
//   allocated, replies posted -- happen in the spawner's segment, in the
//   Botlish order, before `adopt` gives it a task id.
// * The dialogue (resumed with a Line, yields a Reply) and the AI agent
//   (resumed with a Tick, yields a Move) are coroutines of their own
//   protocols that their owners resume directly, never scheduled: explicit
//   state machines with a resume method.
// * evloop's int rows and registers become structs: a registration is
//   addressed by (slot, gen), slots and task ids come from LIFO free lists
//   and a slot's generation is bumped when it is freed or revoked, as in
//   evloop; a registration's waiters (evloop's linked FIFO) and queued events
//   (its event nodes) are VecDeques, the run queue (evloop's two-stack FIFO)
//   a VecDeque of task ids. A task's handle lives in its row while it is
//   ready or parked: evloop's parked set and its swap-remove are storage,
//   never a decision. Everything that decides -- the turn structure,
//   periods_due, coalesced expiries, one-shot timers freed on dispatch, wake
//   validity, live_work?/next_deadline, the observer phase -- is evloop's.
//   periods_due divides (evloop finds the same quotient by doubling and a
//   binary search: Botlish has no division).
// * The contexts: the Loop, the driver and the request register are one Env
//   shared through Rc (RefCells; no borrow is held across an await or a
//   resume). evloop::Driver and gameserver::Net are traits Sim implements,
//   selected statically as the context traits are.
// * The workload's tasks never fail: evloop's TaskFailed/IndexNotFound
//   results are not ported (no handler of the program fires).
use std::cell::{Cell, RefCell};
use std::collections::VecDeque;
use std::fmt;
use std::future::Future;
use std::hint::black_box;
use std::pin::Pin;
use std::rc::Rc;
use std::task::{Context, Poll, RawWaker, RawWakerVTable, Waker};
use std::time::Instant;

// ---------------------------------------------------------------------------
// evloop: the scheduler

/// What made a task ready (evloop's woke_*), and try_take's "nothing" (-1).
#[derive(Clone, Copy, PartialEq, Eq)]
enum Reason {
    Empty = -1,
    Ready = 0,
    Event = 1,
    Timer = 2,
    Revoked = 3,
    Turn = 4,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum RegKind {
    Timer,
    Source,
    Channel,
    Turn,
}

/// A registration's identity: its slot and the generation it had when made.
#[derive(Clone, Copy)]
struct Reg {
    slot: i64,
    gen: i64,
}

/// What woke a task: the reason, the registration's slot, and the event's
/// two ints (a timer's a: the intervals missed and coalesced).
#[derive(Clone, Copy)]
struct Event {
    reason: Reason,
    #[allow(dead_code)]
    slot: i64,
    a: i64,
    b: i64,
}

/// run or turn called while a task is being dispatched (a nested loop).
struct LoopReentered;

type Task = Pin<Box<dyn Future<Output = i64>>>;

/// What a segment of a task ended with.
enum Segment {
    Yielded(i64),
    Done(i64),
}

struct TaskRow {
    /// The handle while the task is ready or parked (None while it runs).
    step: Option<Task>,
    reason: Reason,
    slot: i64,
    gen: i64,
    a: i64,
    b: i64,
    #[allow(dead_code)]
    live: bool,
}

struct Registration {
    gen: i64,
    kind: RegKind,
    live: bool,
    keep: bool,
    waiters: VecDeque<usize>,
    deadline: i64,
    period: i64,
    cap: i64,
    /// Queued events of a source or channel; a timer's expiries are only
    /// counted (npend).
    events: VecDeque<(i64, i64)>,
    npend: i64,
    #[allow(dead_code)]
    dropped: i64,
    seq: i64,
    #[allow(dead_code)]
    delivered: i64,
}

/// evloop's counters and the registers this workload never reads.
#[derive(Default)]
#[allow(dead_code)]
struct Stats {
    dispatched: i64,
    collected: i64,
    stale: i64,
    failed: i64,
    completed: i64,
    suppressed: i64,
    reentered: i64,
    observed: i64,
    spawned: i64,
    maxready: i64,
    idle_turns: i64,
    turn_collected: i64,
    turn_dispatched: i64,
    current: usize,
}

struct Loop {
    ready: VecDeque<usize>,
    tasks: Vec<TaskRow>,
    t_free: Vec<usize>,
    regs: Vec<Registration>,
    r_free: Vec<usize>,
    observers: Vec<(usize, i64)>,
    turn: i64,
    now: i64,
    dispatching: bool,
    stopping: bool,
    budget: i64,
    seq: i64,
    tracing: bool,
    keepwait: i64,
    wake: Event,
    stats: Stats,
    trace: Vec<String>,
    results: Vec<i64>,
}

impl Loop {
    /// A Loop that dispatches at most BUDGET native records per turn;
    /// TRACING records a trace of every scheduling decision.
    fn create(budget: i64, tracing: bool) -> Loop {
        Loop {
            ready: VecDeque::new(),
            tasks: Vec::new(),
            t_free: Vec::new(),
            regs: Vec::new(),
            r_free: Vec::new(),
            observers: Vec::new(),
            turn: 0,
            now: 0,
            dispatching: false,
            stopping: false,
            budget,
            seq: 0,
            tracing,
            keepwait: 0,
            wake: Event { reason: Reason::Ready, slot: -1, a: 0, b: 0 },
            stats: Stats::default(),
            trace: Vec::new(),
            results: Vec::new(),
        }
    }

    /// A line of the trace (evloop::log; evloop's notes when tracing).
    fn log(&mut self, text: fmt::Arguments) {
        let line = format!("t={}: {}", self.turn, text);
        self.trace.push(line);
    }

    // -- Tasks

    fn new_task(&mut self) -> usize {
        let id = match self.t_free.pop() {
            Some(id) => id,
            None => {
                self.tasks.push(TaskRow { step: None, reason: Reason::Ready, slot: -1, gen: 0, a: 0, b: 0, live: false });
                self.tasks.len() - 1
            }
        };
        let t = &mut self.tasks[id];
        t.reason = Reason::Ready;
        t.slot = -1;
        t.gen = 0;
        t.a = 0;
        t.b = 0;
        t.live = true;
        self.stats.spawned += 1;
        id
    }

    fn retire_task(&mut self, id: usize) {
        self.tasks[id].live = false;
        self.t_free.push(id);
    }

    /// Make task ID (its handle in its row) ready with REASON from
    /// registration SLOT/GEN.
    fn make_ready(&mut self, id: usize, reason: Reason, slot: i64, gen: i64, a: i64, b: i64) {
        let t = &mut self.tasks[id];
        t.reason = reason;
        t.slot = slot;
        t.gen = gen;
        t.a = a;
        t.b = b;
        self.ready.push_back(id);
        let n = self.ready.len() as i64;
        if n > self.stats.maxready {
            self.stats.maxready = n;
        }
    }

    fn complete(&mut self, id: usize, value: i64) {
        self.stats.completed += 1;
        self.results.push(id as i64);
        self.results.push(value);
        self.retire_task(id);
    }

    /// The first waiter of SLOT, removed from its FIFO.
    fn pop_waiter(&mut self, slot: usize) -> Option<usize> {
        let r = &mut self.regs[slot];
        let id = r.waiters.pop_front()?;
        if r.keep {
            self.keepwait -= 1;
        }
        Some(id)
    }

    // -- Registrations

    fn new_reg(&mut self, kind: RegKind, keep: bool, cap: i64) -> Reg {
        let slot = match self.r_free.pop() {
            Some(slot) => slot,
            None => {
                self.regs.push(Registration {
                    gen: 1,
                    kind,
                    live: false,
                    keep,
                    waiters: VecDeque::new(),
                    deadline: -1,
                    period: 0,
                    cap,
                    events: VecDeque::new(),
                    npend: 0,
                    dropped: 0,
                    seq: 0,
                    delivered: 0,
                });
                self.regs.len() - 1
            }
        };
        let seq = self.seq;
        let r = &mut self.regs[slot];
        r.kind = kind;
        r.live = true;
        r.keep = keep;
        r.waiters.clear();
        r.deadline = -1;
        r.period = 0;
        r.cap = cap;
        r.events.clear();
        r.npend = 0;
        r.dropped = 0;
        r.seq = seq;
        r.delivered = 0;
        self.seq += 1;
        Reg { slot: slot as i64, gen: r.gen }
    }

    /// True when REG still names a live registration.
    fn live(&self, reg: Reg) -> bool {
        if reg.slot < 0 || reg.slot >= self.regs.len() as i64 {
            return false;
        }
        let r = &self.regs[reg.slot as usize];
        r.gen == reg.gen && r.live
    }

    /// A one-shot timer at DEADLINE, or a repeating one (PERIOD > 0) whose
    /// first expiry is DEADLINE.
    fn timer(&mut self, deadline: i64, period: i64) -> Reg {
        let reg = self.new_reg(RegKind::Timer, true, 1);
        let r = &mut self.regs[reg.slot as usize];
        r.deadline = deadline;
        r.period = period;
        if self.tracing {
            self.log(format_args!("timer {} at {} every {}", reg.slot, deadline, period));
        }
        reg
    }

    fn every(&mut self, period: i64) -> Reg {
        let now = self.now;
        self.timer(now + period, period)
    }

    /// A source of native (driver) records; KEEP: a task waiting on it keeps
    /// the loop alive.
    fn source(&mut self, keep: bool, cap: i64) -> Reg {
        let reg = self.new_reg(RegKind::Source, keep, cap);
        if self.tracing {
            self.log(format_args!("source {} keep {}", reg.slot, keep as i64));
        }
        reg
    }

    /// A channel Botlish code posts to.
    fn channel(&mut self, cap: i64) -> Reg {
        let reg = self.new_reg(RegKind::Channel, false, cap);
        if self.tracing {
            self.log(format_args!("channel {}", reg.slot));
        }
        reg
    }

    /// A once-per-turn registration.
    fn observer(&mut self) -> Reg {
        let reg = self.new_reg(RegKind::Turn, false, 0);
        self.observers.push((reg.slot as usize, reg.gen));
        if self.tracing {
            self.log(format_args!("observer {}", reg.slot));
        }
        reg
    }

    fn free_reg(&mut self, slot: usize) {
        let r = &mut self.regs[slot];
        r.gen += 1;
        r.live = false;
        self.r_free.push(slot);
    }

    /// A one-shot timer that fired: no longer live, but its generation
    /// stands until its wake is dispatched.
    fn spend_timer(&mut self, slot: usize) {
        let r = &mut self.regs[slot];
        if r.period == 0 {
            r.live = false;
        }
    }

    /// Revoke REG: queued events are discarded, a wake already queued is
    /// suppressed at dispatch, every waiter is made ready with Revoked.
    /// Revoking twice, or a stale Reg, does nothing (returns 0).
    fn revoke(&mut self, reg: Reg) -> i64 {
        let stale = reg.slot < 0 || reg.slot >= self.regs.len() as i64 || self.regs[reg.slot as usize].gen != reg.gen;
        if stale {
            if self.tracing {
                self.log(format_args!("revoke stale {}", reg.slot));
            }
            return 0;
        }
        let slot = reg.slot as usize;
        let r = &mut self.regs[slot];
        let discarded = r.npend;
        r.live = false;
        r.gen = reg.gen + 1;
        r.events.clear();
        r.npend = 0;
        if self.tracing {
            self.log(format_args!("revoke {} discarding {}", slot, discarded));
        }
        while let Some(id) = self.pop_waiter(slot) {
            self.make_ready(id, Reason::Revoked, reg.slot, reg.gen, 0, 0);
        }
        self.r_free.push(slot);
        1
    }

    /// Deliver event (A, B) to registration SLOT, expected at generation
    /// GEN: its first waiter is made ready, else the event is queued, else
    /// it is counted and dropped. Returns 0 for a stale record, else 1.
    fn deliver(&mut self, slot: i64, gen: i64, reason: Reason, a: i64, b: i64) -> i64 {
        let stale = slot < 0 || slot >= self.regs.len() as i64 || {
            let r = &self.regs[slot as usize];
            r.gen != gen || !r.live
        };
        if stale {
            self.stats.stale += 1;
            if self.tracing {
                self.log(format_args!("stale record for {} gen {}", slot, gen));
            }
            return 0;
        }
        let s = slot as usize;
        self.regs[s].delivered += 1;
        if let Some(id) = self.pop_waiter(s) {
            self.make_ready(id, reason, slot, gen, a, b);
        } else if self.regs[s].npend >= self.regs[s].cap {
            self.regs[s].dropped += 1;
            if self.tracing {
                self.log(format_args!("overflow {}", slot));
            }
        } else {
            let r = &mut self.regs[s];
            r.events.push_back((a, b));
            r.npend += 1;
        }
        1
    }

    /// Post (A, B) to a channel or source REG from Botlish code. Returns 0
    /// when REG is not live (nothing happens).
    fn post(&mut self, reg: Reg, a: i64, b: i64) -> i64 {
        if !self.live(reg) {
            return 0;
        }
        self.deliver(reg.slot, reg.gen, Reason::Event, a, b)
    }

    /// REG's next queued event without suspending (reason Empty: nothing
    /// queued).
    fn try_take(&mut self, reg: Reg) -> Event {
        if !self.live(reg) {
            return Event { reason: Reason::Revoked, slot: reg.slot, a: 0, b: 0 };
        }
        let r = &mut self.regs[reg.slot as usize];
        if r.npend == 0 || r.kind == RegKind::Timer {
            return Event { reason: Reason::Empty, slot: reg.slot, a: 0, b: 0 };
        }
        let (a, b) = r.events.pop_front().expect("a queued event");
        r.npend -= 1;
        Event { reason: Reason::Event, slot: reg.slot, a, b }
    }

    // -- Parking and adoption

    /// Park task ID (handle STEP) on registration SLOT, or make it ready at
    /// once when the registration has something for it (or is not live).
    fn park(&mut self, step: Task, id: usize, slot: i64) {
        self.tasks[id].step = Some(step);
        if slot < 0 || slot >= self.regs.len() as i64 {
            self.make_ready(id, Reason::Revoked, slot, 0, 0, 0);
            return;
        }
        let s = slot as usize;
        let r = &mut self.regs[s];
        let gen = r.gen;
        if !r.live {
            self.make_ready(id, Reason::Revoked, slot, gen, 0, 0);
            return;
        }
        let npend = r.npend;
        if r.kind == RegKind::Timer && npend > 0 {
            r.npend = 0;
            self.spend_timer(s);
            self.make_ready(id, Reason::Timer, slot, gen, npend - 1, 0);
            return;
        }
        if npend > 0 {
            let (a, b) = r.events.pop_front().expect("a queued event");
            r.npend = npend - 1;
            self.make_ready(id, Reason::Event, slot, gen, a, b);
            return;
        }
        r.waiters.push_back(id);
        if r.keep {
            self.keepwait += 1;
        }
    }

    /// What a segment's request means: -1 ready again; a slot, park there.
    fn after_segment(&mut self, step: Task, id: usize, code: i64) {
        if code == -1 {
            self.tasks[id].step = Some(step);
            self.make_ready(id, Reason::Ready, -1, 0, 0, 0);
        } else {
            self.park(step, id, code);
        }
    }

    // -- The turn's phases

    /// The live timer slot with the earliest deadline <= NOW (smallest
    /// sequence among equals).
    fn earliest_timer(&self, n: usize, now: i64) -> Option<usize> {
        let mut best: Option<usize> = None;
        for (slot, r) in self.regs[..n].iter().enumerate() {
            if r.live && r.kind == RegKind::Timer && r.deadline >= 0 && r.deadline <= now {
                match best {
                    None => best = Some(slot),
                    Some(b) => {
                        let bd = self.regs[b].deadline;
                        if r.deadline < bd || (r.deadline == bd && r.seq < self.regs[b].seq) {
                            best = Some(slot);
                        }
                    }
                }
            }
        }
        best
    }

    fn fire_timer(&mut self, slot: usize, now: i64) {
        let deadline = self.regs[slot].deadline;
        let period = self.regs[slot].period;
        let due = if period > 0 { periods_due(deadline, period, now) } else { 1 };
        let missed = due - 1;
        self.regs[slot].deadline = if period > 0 { deadline + due * period } else { -1 };
        if self.tracing {
            self.log(format_args!("timer {} fires late {} missed {}", slot, now - deadline, missed));
        }
        if let Some(id) = self.pop_waiter(slot) {
            self.spend_timer(slot);
            let gen = self.regs[slot].gen;
            self.make_ready(id, Reason::Timer, slot as i64, gen, missed, 0);
            return;
        }
        // Nobody waits: the expiries are coalesced into one pending count.
        let r = &mut self.regs[slot];
        r.npend += due;
        if period == 0 {
            r.deadline = -1;
        }
    }

    /// Expire the timers due at NOW, earliest deadline first; returns how
    /// many fired.
    fn expire_timers(&mut self, now: i64) -> i64 {
        let n = self.regs.len();
        let mut fired = 0;
        while let Some(best) = self.earliest_timer(n, now) {
            self.fire_timer(best, now);
            fired += 1;
        }
        fired
    }

    /// Collect at most the budget of native records from the driver;
    /// returns how many were delivered.
    fn collect_records(&mut self, d: &mut impl Driver) -> i64 {
        let mut count = 0;
        let mut taken = 0;
        while taken < self.budget {
            let Some(r) = d.take_record() else { break };
            taken += 1;
            count += self.deliver(r.slot, r.gen, Reason::Event, r.a, r.b);
        }
        count
    }

    /// Drop the entries of revoked observers from the observer list.
    fn compact_observers(&mut self) {
        let regs = &self.regs;
        self.observers.retain(|&(slot, gen)| regs[slot].gen == gen && regs[slot].live);
    }

    fn ready_count(&self) -> usize {
        self.ready.len()
    }

    /// Whether anything can still happen: ready work, or a task waiting on a
    /// registration that keeps the loop alive.
    fn live_work(&self) -> bool {
        self.ready_count() > 0 || self.keepwait > 0
    }

    /// The earliest deadline of a timer some task waits on, or -1.
    fn next_deadline(&self) -> i64 {
        let mut best = -1;
        for r in &self.regs {
            if r.live && r.kind == RegKind::Timer && !r.waiters.is_empty() {
                let d = r.deadline;
                if d >= 0 && (best == -1 || d < best) {
                    best = d;
                }
            }
        }
        best
    }
}

/// How many whole periods past DEADLINE NOW is (>= 1 when NOW >= DEADLINE):
/// the expiries a repeating timer owes.
fn periods_due(deadline: i64, period: i64, now: i64) -> i64 {
    if now < deadline {
        return 0;
    }
    1 + (now - deadline) / period
}

/// The environment a task runs in: the installed contexts (the Loop and the
/// driver) and the register a suspending segment writes its request to.
struct Env {
    ev: RefCell<Loop>,
    sim: RefCell<Sim>,
    request: Cell<i64>,
}

fn noop_raw_waker() -> RawWaker {
    fn no_op(_: *const ()) {}
    fn clone(_: *const ()) -> RawWaker {
        noop_raw_waker()
    }
    static VTABLE: RawWakerVTable = RawWakerVTable::new(clone, no_op, no_op, no_op);
    RawWaker::new(std::ptr::null(), &VTABLE)
}

/// Run task STEP's next segment.
fn resume(env: &Env, step: &mut Task) -> Segment {
    // SAFETY: the vtable's functions do nothing and never touch the pointer.
    let waker = unsafe { Waker::from_raw(noop_raw_waker()) };
    let mut cx = Context::from_waker(&waker);
    match step.as_mut().poll(&mut cx) {
        Poll::Ready(value) => Segment::Done(value),
        Poll::Pending => Segment::Yielded(env.request.get()),
    }
}

/// Construct a task eagerly, as a Botlish coroutine construction does: its
/// first segment runs now; the result is its handle and what that segment
/// yielded (or returned).
fn start<F: Future<Output = i64> + 'static>(env: &Env, task: F) -> (Task, Segment) {
    let mut step: Task = Box::pin(task);
    let first = resume(env, &mut step);
    (step, first)
}

/// Hand a started task to the scheduler (evloop::adopt).
fn adopt(env: &Env, step: Task, first: Segment) -> usize {
    match first {
        Segment::Done(value) => {
            drop(step);
            let mut ev = env.ev.borrow_mut();
            let id = ev.new_task();
            if ev.tracing {
                ev.log(format_args!("task {} done at start {}", id, value));
            }
            ev.complete(id, value);
            id
        }
        Segment::Yielded(code) => {
            let mut ev = env.ev.borrow_mut();
            let id = ev.new_task();
            if ev.tracing {
                ev.log(format_args!("adopt task {} wants {}", id, code));
            }
            ev.after_segment(step, id, code);
            id
        }
    }
}

/// A task's suspension: the first poll yields REQUEST to the scheduler, the
/// next (the scheduler resuming the task) completes.
struct Suspend<'a> {
    env: &'a Env,
    request: i64,
    yielded: bool,
}

impl Future for Suspend<'_> {
    type Output = ();
    fn poll(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<()> {
        if self.yielded {
            Poll::Ready(())
        } else {
            self.yielded = true;
            self.env.request.set(self.request);
            Poll::Pending
        }
    }
}

/// Run again in the next turn (evloop::yield_now).
async fn yield_now(env: &Env) {
    Suspend { env, request: -1, yielded: false }.await
}

/// Wait for REG's next event, timer, turn or revocation (evloop::wait).
async fn wait(env: &Env, reg: Reg) -> Event {
    if !env.ev.borrow().live(reg) {
        return Event { reason: Reason::Revoked, slot: reg.slot, a: 0, b: 0 };
    }
    Suspend { env, request: reg.slot, yielded: false }.await;
    env.ev.borrow().wake
}

/// Resume task ID, already out of every queue (evloop::run_task).
fn run_task(env: &Env, id: usize) {
    let mut step = {
        let mut ev = env.ev.borrow_mut();
        let (reason, slot, gen, a, b) = {
            let t = &ev.tasks[id];
            (t.reason, t.slot, t.gen, t.a, t.b)
        };
        let valid = match reason {
            Reason::Event | Reason::Timer | Reason::Turn => ev.regs[slot as usize].gen == gen,
            _ => true,
        };
        if !valid {
            ev.stats.suppressed += 1;
            if ev.tracing {
                ev.log(format_args!("suppress wake of task {} from revoked {}", id, slot));
            }
        }
        let effective = if valid { reason } else { Reason::Revoked };
        // A fired one-shot timer is freed once its wake is dispatched.
        if valid && reason == Reason::Timer {
            let r = &ev.regs[slot as usize];
            if !r.live && r.period == 0 {
                ev.free_reg(slot as usize);
            }
        }
        // A suppressed wake carries nothing of the event it was for.
        ev.wake = if valid {
            Event { reason: effective, slot, a, b }
        } else {
            Event { reason: effective, slot, a: 0, b: 0 }
        };
        ev.stats.current = id;
        ev.dispatching = true;
        ev.stats.dispatched += 1;
        ev.stats.turn_dispatched += 1;
        if ev.tracing {
            ev.log(format_args!("run task {} reason {}", id, effective as i64));
        }
        ev.tasks[id].step.take().expect("a dispatched task has its handle")
    };
    let segment = resume(env, &mut step);
    match segment {
        Segment::Done(value) => {
            drop(step);
            let mut ev = env.ev.borrow_mut();
            ev.dispatching = false;
            if ev.tracing {
                ev.log(format_args!("task {} done {}", id, value));
            }
            ev.complete(id, value);
        }
        Segment::Yielded(code) => {
            let mut ev = env.ev.borrow_mut();
            ev.dispatching = false;
            ev.after_segment(step, id, code);
        }
    }
}

/// The observer phase: every turn registration live when it starts, in
/// registration order, runs its first waiting task once.
fn observe(env: &Env) {
    let n = env.ev.borrow().observers.len();
    let mut dead = 0;
    for i in 0..n {
        let task = {
            let mut ev = env.ev.borrow_mut();
            let (slot, gen) = ev.observers[i];
            if ev.regs[slot].gen == gen && ev.regs[slot].live {
                let waiter = ev.pop_waiter(slot);
                if let Some(id) = waiter {
                    let turn = ev.turn;
                    let t = &mut ev.tasks[id];
                    t.reason = Reason::Turn;
                    t.slot = slot as i64;
                    t.gen = gen;
                    t.a = turn;
                    t.b = 0;
                    ev.stats.observed += 1;
                }
                waiter
            } else {
                dead += 1;
                None
            }
        };
        if let Some(id) = task {
            run_task(env, id);
        }
    }
    if dead > 0 {
        env.ev.borrow_mut().compact_observers();
    }
}

/// One scheduling turn without waiting: collect, dispatch, observe. Returns
/// how many tasks it dispatched.
fn turn(env: &Env) -> Result<usize, LoopReentered> {
    let (n, collected) = {
        let mut ev = env.ev.borrow_mut();
        let mut sim = env.sim.borrow_mut();
        if ev.dispatching {
            ev.stats.reentered += 1;
            return Err(LoopReentered);
        }
        ev.turn += 1;
        ev.now = sim.clock();
        ev.stats.turn_dispatched = 0;
        let now = ev.now;
        let timers = ev.expire_timers(now);
        let records = ev.collect_records(&mut *sim);
        let collected = timers + records;
        ev.stats.turn_collected = collected;
        ev.stats.collected += records;
        let n = ev.ready_count();
        if ev.tracing {
            ev.log(format_args!("collect timers {} records {} ready {}", timers, records, n));
        }
        (n, collected)
    };
    // Exactly the tasks ready now, in the order they became ready.
    for _ in 0..n {
        let id = env.ev.borrow_mut().ready.pop_front().expect("a ready task");
        run_task(env, id);
    }
    if collected + n as i64 > 0 {
        observe(env);
    } else {
        env.ev.borrow_mut().stats.idle_turns += 1;
    }
    Ok(n)
}

/// Drive the loop until nothing can happen any more (or a driver that can
/// never deliver again). Returns the number of turns.
fn run(env: &Env) -> Result<i64, LoopReentered> {
    let first = {
        let mut ev = env.ev.borrow_mut();
        if ev.dispatching {
            ev.stats.reentered += 1;
            return Err(LoopReentered);
        }
        ev.stopping = false;
        ev.now = env.sim.borrow().clock();
        ev.turn
    };
    loop {
        let deadline = {
            let mut ev = env.ev.borrow_mut();
            if ev.stopping {
                if ev.tracing {
                    ev.log(format_args!("stopped"));
                }
                break;
            }
            if !ev.live_work() {
                if ev.tracing {
                    ev.log(format_args!("no live work"));
                }
                break;
            }
            if ev.ready_count() > 0 {
                env.sim.borrow().clock()
            } else {
                ev.next_deadline()
            }
        };
        let available = env.sim.borrow_mut().block(deadline);
        {
            let mut ev = env.ev.borrow_mut();
            if available < 0 && ev.ready_count() == 0 && ev.next_deadline() == -1 {
                if ev.tracing {
                    ev.log(format_args!("driver exhausted"));
                }
                break;
            }
        }
        turn(env)?;
    }
    Ok(env.ev.borrow().turn - first)
}

/// The environment the loop waits in (evloop's context trait Driver).
trait Driver {
    fn clock(&self) -> i64;
    fn block(&mut self, deadline: i64) -> i64;
    fn take_record(&mut self) -> Option<Record>;
}

// ---------------------------------------------------------------------------
// simdrv: the deterministic driver (a virtual clock and a script of records)

#[derive(Clone, Copy)]
struct Record {
    slot: i64,
    gen: i64,
    a: i64,
    b: i64,
}

struct Scripted {
    when: i64,
    record: Record,
    released: bool,
}

struct ScriptLine {
    conn: i64,
    delay: i64,
    cmd: i64,
    arg: i64,
}

struct Sim {
    now: i64,
    script: Vec<Scripted>,
    #[allow(dead_code)]
    released: i64,
    /// Released records not yet taken: avail[read..].
    avail: Vec<Record>,
    read: usize,
    /// The deadlines the loop blocked with, in order.
    #[allow(dead_code)]
    waits: Vec<i64>,
    lines: Vec<ScriptLine>,
    sent: Vec<i64>,
}

impl Sim {
    fn create() -> Sim {
        Sim { now: 0, script: Vec::new(), released: 0, avail: Vec::new(), read: 0, waits: Vec::new(), lines: Vec::new(), sent: Vec::new() }
    }

    /// Script a record for registration (SLOT, GEN) at time WHEN; those due
    /// at the same time are released in the order they were scripted.
    fn inject(&mut self, when: i64, slot: i64, gen: i64, a: i64, b: i64) {
        self.script.push(Scripted { when, record: Record { slot, gen, a, b }, released: false });
    }

    fn release_due(&mut self) {
        let now = self.now;
        for s in self.script.iter_mut() {
            if !s.released && s.when <= now {
                self.avail.push(s.record);
                s.released = true;
                self.released += 1;
            }
        }
    }

    /// The earliest time of a record not yet released, or -1.
    fn next_due(&self) -> i64 {
        let mut best = -1;
        for s in &self.script {
            if !s.released && (best == -1 || s.when < best) {
                best = s.when;
            }
        }
        best
    }

    fn available(&self) -> i64 {
        (self.avail.len() - self.read) as i64
    }

    /// Connection CONN's line, a record DELAY microseconds after it is
    /// attached.
    fn line(&mut self, conn: i64, delay: i64, cmd: i64, arg: i64) {
        self.lines.push(ScriptLine { conn, delay, cmd, arg });
    }
}

impl Driver for Sim {
    fn clock(&self) -> i64 {
        self.now
    }

    /// Never sleeps: one virtual microsecond per visit, then the clock moves
    /// to the next scripted record or DEADLINE, whichever comes first.
    fn block(&mut self, deadline: i64) -> i64 {
        self.waits.push(deadline);
        self.now += 1;
        self.release_due();
        let now = self.now;
        let next = self.next_due();
        let target = if self.available() > 0 || (deadline >= 0 && deadline <= now) {
            now
        } else if next == -1 && deadline == -1 {
            -1
        } else if next == -1 {
            deadline
        } else if deadline == -1 || next < deadline {
            next
        } else {
            deadline
        };
        if target == -1 {
            return -1;
        }
        if target > now {
            self.now = target;
            self.release_due();
        }
        self.available()
    }

    fn take_record(&mut self) -> Option<Record> {
        let r = *self.avail.get(self.read)?;
        self.read += 1;
        Some(r)
    }
}

// ---------------------------------------------------------------------------
// gameserver: the workload

/// What the network gives a program (gameserver's context trait Net).
trait Net {
    fn attach(&mut self, conn: i64, slot: i64, gen: i64) -> i64;
    fn send(&mut self, conn: i64, value: i64) -> i64;
    fn hangup(&mut self, conn: i64) -> i64;
    fn ack(&mut self, conn: i64) -> i64;
}

impl Net for Sim {
    /// Each of CONN's lines becomes a record of (SLOT, GEN), its delay after
    /// now.
    fn attach(&mut self, conn: i64, slot: i64, gen: i64) -> i64 {
        let now = self.now;
        let mut count = 0;
        for l in &self.lines {
            if l.conn == conn {
                self.script.push(Scripted { when: now + l.delay, record: Record { slot, gen, a: l.cmd, b: l.arg }, released: false });
                count += 1;
            }
        }
        count
    }

    fn send(&mut self, conn: i64, value: i64) -> i64 {
        self.sent.push(conn);
        self.sent.push(value);
        1
    }

    fn hangup(&mut self, conn: i64) -> i64 {
        self.sent.push(conn);
        self.sent.push(-1);
        1
    }

    fn ack(&mut self, conn: i64) -> i64 {
        conn
    }
}

#[derive(Clone, Copy)]
struct Line {
    cmd: i64,
    arg: i64,
}

#[derive(Clone, Copy)]
struct Reply {
    kind: i64,
    value: i64,
}

struct Tick {
    n: i64,
}

struct Move {
    x: i64,
}

// Reply kinds.
const SAY_KIND: i64 = 1;
const FIND_KIND: i64 = 3;
const BYE_KIND: i64 = 4;

// Steps of pathfinding between yields.
const CHUNK: i64 = 10;

/// A dialogue: a coroutine of its own protocol (resumed with a Line, yields
/// a Reply), driven directly by its session.
struct Dialogue {
    conn: i64,
    state: DialogueState,
}

enum DialogueState {
    /// At a yield whose resumption is the next line.
    AwaitLine,
    /// At the find reply's yield: its resumption is the path found.
    AwaitFound,
    Done,
}

impl Dialogue {
    fn start(conn: i64) -> (Dialogue, Reply) {
        (Dialogue { conn, state: DialogueState::AwaitLine }, Reply { kind: SAY_KIND, value: 1000 + conn })
    }

    /// The next reply, or the final one (a bye) when the dialogue completes.
    fn resume(&mut self, line: Line) -> Reply {
        match self.state {
            DialogueState::AwaitLine => {
                if line.cmd == 9 {
                    self.state = DialogueState::Done;
                    Reply { kind: BYE_KIND, value: self.conn }
                } else if line.cmd == 1 {
                    self.state = DialogueState::AwaitFound;
                    Reply { kind: FIND_KIND, value: line.arg }
                } else {
                    Reply { kind: SAY_KIND, value: 3000000 + line.arg }
                }
            }
            DialogueState::AwaitFound => {
                self.state = DialogueState::AwaitLine;
                Reply { kind: SAY_KIND, value: 2000000 + line.arg }
            }
            DialogueState::Done => panic!("a finished dialogue resumed"),
        }
    }
}

/// An AI agent: its own protocol (resumed with a Tick, yields a Move),
/// advanced directly, one step per world tick.
struct Agent {
    pos: i64,
}

impl Agent {
    fn start() -> (Agent, Move) {
        (Agent { pos: 0 }, Move { x: 0 })
    }

    fn resume(&mut self, tick: Tick) -> Move {
        self.pos += tick.n;
        Move { x: self.pos }
    }
}

/// gameserver's say: an application line in the trace.
fn say(env: &Env, text: fmt::Arguments) {
    env.ev.borrow_mut().log(text);
}

fn turn_now(env: &Env) -> i64 {
    env.ev.borrow().turn
}

/// Pathfinding: a scheduler task that yields every CHUNK steps and posts its
/// result (twice the length) to CH.
async fn pathfinder(env: Rc<Env>, n: i64, ch: Reg) -> i64 {
    for i in 0..n {
        if i % CHUNK == 0 {
            yield_now(&env).await;
        }
    }
    env.ev.borrow_mut().post(ch, n * 2, 0);
    n
}

async fn pathfind(env: &Rc<Env>, n: i64) -> i64 {
    let ch = env.ev.borrow_mut().channel(1);
    let (step, first) = start(env, pathfinder(env.clone(), n, ch));
    adopt(env, step, first);
    let e = wait(env, ch).await;
    env.ev.borrow_mut().revoke(ch);
    e.a
}

fn out(env: &Env, conn: i64, value: i64, outbox: Reg) {
    env.ev.borrow_mut().post(outbox, conn, value);
}

async fn session(env: Rc<Env>, conn: i64, reg: Reg, outbox: Reg) -> i64 {
    // Lines handled, the largest and the total `now - arg` of TALK lines.
    let mut handled = 0;
    let mut max_lag = 0;
    let mut total_lag = 0;
    let (mut dialogue, first) = Dialogue::start(conn);
    out(&env, conn, first.value, outbox);
    loop {
        let e = wait(&env, reg).await;
        if e.reason != Reason::Event {
            break;
        }
        handled += 1;
        if e.a == 2 {
            let lag = env.ev.borrow().now - e.b;
            if lag > max_lag {
                max_lag = lag;
            }
            total_lag += lag;
        }
        if env.ev.borrow().tracing {
            say(&env, format_args!("conn {} cmd {} in turn {}", conn, e.a, turn_now(&env)));
        }
        let reply = dialogue.resume(Line { cmd: e.a, arg: e.b });
        let reply = if reply.kind == FIND_KIND {
            let found = pathfind(&env, reply.value).await;
            say(&env, format_args!("conn {} path found in turn {}", conn, turn_now(&env)));
            dialogue.resume(Line { cmd: 100, arg: found })
        } else {
            reply
        };
        if reply.kind == BYE_KIND {
            break;
        }
        out(&env, conn, reply.value, outbox);
        // Demand-driven reading: one more line may be read for this
        // connection.
        env.sim.borrow_mut().ack(conn);
    }
    env.sim.borrow_mut().hangup(conn);
    env.ev.borrow_mut().revoke(reg);
    say(&env, format_args!("conn {} closed in turn {}", conn, turn_now(&env)));
    say(&env, format_args!("conn {} lines {}", conn, handled));
    say(&env, format_args!("conn {} max lag us {}", conn, max_lag));
    say(&env, format_args!("conn {} total lag us {}", conn, total_lag));
    handled
}

async fn acceptor(env: Rc<Env>, listener: Reg, outbox: Reg, max: i64) -> i64 {
    for _ in 0..max {
        let e = wait(&env, listener).await;
        if e.reason != Reason::Event {
            break;
        }
        let conn = e.a;
        let reg = env.ev.borrow_mut().source(true, 16);
        env.sim.borrow_mut().attach(conn, reg.slot, reg.gen);
        let (step, first) = start(&env, session(env.clone(), conn, reg, outbox));
        adopt(&env, step, first);
    }
    env.ev.borrow_mut().revoke(listener);
    max
}

/// The once-per-turn output flush: everything the sessions posted this
/// turn, sent in one batch.
async fn flusher(env: Rc<Env>, outbox: Reg) -> i64 {
    let obs = env.ev.borrow_mut().observer();
    let mut total = 0;
    loop {
        let t = wait(&env, obs).await;
        if t.reason != Reason::Turn {
            break;
        }
        let mut count = 0;
        loop {
            let m = env.ev.borrow_mut().try_take(outbox);
            if m.reason != Reason::Event {
                break;
            }
            env.sim.borrow_mut().send(m.a, m.b);
            count += 1;
        }
        if count > 0 {
            say(&env, format_args!("flush {} in turn {}", count, t.a));
            total += count;
        }
    }
    total
}

async fn world(env: Rc<Env>, period: i64, ticks: i64) -> i64 {
    let clock = env.ev.borrow_mut().every(period);
    let (mut agent, first) = Agent::start();
    let mut pos = first.x;
    for _ in 0..ticks {
        let e = wait(&env, clock).await;
        let m = agent.resume(Tick { n: 1 + e.a });
        pos = m.x;
        say(&env, format_args!("world tick, agent at {}", m.x));
    }
    env.ev.borrow_mut().revoke(clock);
    pos
}

// ---------------------------------------------------------------------------
// The program (bench/experimental/game-server.bot)

#[derive(Clone, Copy)]
struct Params {
    conns: i64,
    lines: i64,
    period: i64,
    ticks: i64,
    budget: i64,
}

/// A fold of VALUES that depends on their order (every value >= -1).
fn checksum(values: &[i64]) -> i64 {
    let mut h = 7;
    for &v in values {
        h = (h * 31 + v + 2) % 1_000_000_007;
    }
    h
}

fn script(env: &Rc<Env>, p: Params) {
    let listener = env.ev.borrow_mut().source(true, p.conns + 4);
    {
        let mut sim = env.sim.borrow_mut();
        for c in 1..=p.conns {
            sim.inject(4 + c, listener.slot, listener.gen, c, 0);
            let spacing = 3 + c % 3;
            for k in 0..p.lines {
                if k % 4 == 1 {
                    sim.line(c, 1 + k * spacing, 1, 10 * (1 + (c + k) % 5));
                } else {
                    sim.line(c, 1 + k * spacing, 2, c * 100 + k);
                }
            }
            sim.line(c, 6 + p.lines * spacing, 9, 0);
        }
    }
    let outbox = env.ev.borrow_mut().channel(4096);
    let (a, af) = start(env, acceptor(env.clone(), listener, outbox, p.conns));
    adopt(env, a, af);
    let (f, ff) = start(env, flusher(env.clone(), outbox));
    adopt(env, f, ff);
    let (w, wf) = start(env, world(env.clone(), p.period, p.ticks));
    adopt(env, w, wf);
}

fn run_once(p: Params) -> Vec<i64> {
    let env = Rc::new(Env { ev: RefCell::new(Loop::create(p.budget, false)), sim: RefCell::new(Sim::create()), request: Cell::new(0) });
    script(&env, p);
    let value = match run(&env) {
        Ok(turns) => {
            let ev = env.ev.borrow();
            let sim = env.sim.borrow();
            let chars: usize = ev.trace.iter().map(|line| line.chars().count()).sum();
            vec![
                turns,
                ev.stats.dispatched,
                ev.stats.completed,
                ev.stats.observed,
                ev.stats.stale,
                sim.sent.len() as i64,
                checksum(&sim.sent),
                checksum(&ev.results),
                ev.trace.len() as i64,
                chars as i64,
            ]
        }
        Err(LoopReentered) => vec![-2],
    };
    // The tasks the loop still owns (the flusher) hold the Env: release them
    // so the Env is freed with the run.
    let leftover = std::mem::take(&mut env.ev.borrow_mut().tasks);
    drop(leftover);
    value
}

fn show(values: &[i64]) -> String {
    let items: Vec<String> = values.iter().map(|v| v.to_string()).collect();
    format!("[{}]", items.join(", "))
}

fn main() {
    let mut runs: u32 = 5;
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        if arg == "--runs" {
            runs = args.next().expect("--runs needs a value").parse().expect("--runs must be an integer");
        }
    }
    let p = Params { conns: 12, lines: 18, period: 25, ticks: 12, budget: 8 };

    run_once(black_box(p)); // untimed warmup
    let mut best = f64::MAX;
    let mut value = Vec::new();
    for _ in 0..runs {
        let t0 = Instant::now();
        // black_box on the parameters stops the optimizer from noticing the
        // run is loop-invariant and hoisting it out after the first one.
        value = run_once(black_box(p));
        let us = t0.elapsed().as_secs_f64() * 1_000_000.0;
        if us < best {
            best = us;
        }
    }

    println!("value: {}", show(&value));
    println!("best_us: {:.3}", best);
}
