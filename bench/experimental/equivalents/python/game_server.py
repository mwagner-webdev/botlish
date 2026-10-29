#!/usr/bin/env python3
# Python equivalent of bench/experimental/game-server.bot: the game-server
# workload of EVENT-LOOP-EXPLORATION.md (audit/event-loop/src/gameserver.bot)
# on the audit's prototype scheduler (audit/event-loop/src/evloop.bot) and its
# deterministic virtual-clock driver (audit/event-loop/src/simdrv.bot).
#
# How the Botlish structure maps here:
#
#   evloop's Loop      class Loop. The int rows of registrations and tasks are
#                      objects (Registration, Task); a registration's waiter
#                      FIFO and its bounded event queue are deques; the run
#                      queue (two stacks of handles in Botlish) is one FIFO
#                      deque of (handle, id); the parked set a dict. What the
#                      value observes is kept exactly: slots addressed by
#                      (slot, gen) with a LIFO free list and generation bumps,
#                      task ids from a LIFO free list, the turn structure
#                      (block -> expire timers -> at most `budget` records ->
#                      dispatch the tasks ready at the phase start, FIFO ->
#                      observers only when the turn collected or dispatched
#                      something), coalesced timer expiries, one-shot timers
#                      freed when their wake is dispatched, wake validity
#                      checks, and the same linear scans for the earliest
#                      timer and the next deadline.
#   tasks              generators. A Botlish task is an eagerly started
#                      coroutine: Co.start() runs it to its first yield (its
#                      side effects -- slot and id allocation, posts -- happen
#                      there, inside the spawner, in the same order). A task
#                      yields its int request (-1: run again; else the slot it
#                      waits on) and is resumed with no message; what woke it
#                      is read from the loop's wake registers after the yield,
#                      as evloop::wait does. Botlish's deep yield (a yield in a
#                      called function suspends the whole task) is `yield
#                      from` on the helpers wait, yield_now and pathfind.
#   dialogue, agent    coroutines of their own protocols (resume Line, yields
#                      Reply; resume Tick, yields Move) driven directly by
#                      their owner with send(); a StopIteration's value is the
#                      coroutine's return value (done?).
#   simdrv's Sim       class Sim: the virtual clock (each block() visit costs
#                      one microsecond), the script of records (released, in
#                      scripted order, once the clock reaches their time: the
#                      same linear scans), the scripted network (attach turns a
#                      connection's lines into records at now + delay).
#   contexts           the installed Loop and Sim are passed explicitly.
#
# The workload's error handlers (IndexNotFound, TaskFailed, LoopReentered)
# never fire in this script and are not modeled beyond what the value needs.
#
# Invoked by bench/bench.tcl; see bench/equivalents/python/fib.py for the
# --runs/value/best_us protocol shared by every equivalent: one untimed
# warmup run of the whole workload, then N timed runs, each building
# everything from scratch (loop, driver, script) as one Botlish program run
# does. The printed value has core::value::show's "[a, b, ...]" shape.
#
# expect: [112, 604, 74, 112, 0, 480, 972395168, 705481770, 209, 5838]
import sys
import time
from collections import deque

# ---------------------------------------------------------------------------
# evloop

# Registration kinds.
KIND_TIMER = 1
KIND_SOURCE = 2
KIND_CHANNEL = 3
KIND_TURN = 4

# Wake reasons: what made a task ready.
WOKE_READY = 0
WOKE_EVENT = 1
WOKE_TIMER = 2
WOKE_REVOKED = 3
WOKE_TURN = 4


class Reg:
    """A registration's identity: its slot and the generation it had when made."""

    __slots__ = ("slot", "gen")

    def __init__(self, slot, gen):
        self.slot = slot
        self.gen = gen


class Registration:
    """A registration's row (evloop's r_* fields)."""

    __slots__ = ("gen", "kind", "live", "keep", "waiters", "deadline", "period",
                 "cap", "pending", "npend", "dropped", "seq", "delivered")

    def __init__(self):
        self.gen = 1
        self.waiters = deque()
        self.pending = deque()


class Task:
    """A task's row (evloop's t_* fields): the wake it is ready with."""

    __slots__ = ("reason", "slot", "gen", "a", "b", "live")


class Co:
    """An eagerly started coroutine handle over a generator."""

    __slots__ = ("gen", "done")

    def __init__(self, gen):
        self.gen = gen
        self.done = False

    def start(self):
        try:
            return next(self.gen)
        except StopIteration as stop:
            self.done = True
            return stop.value

    def resume(self, message=None):
        try:
            return self.gen.send(message)
        except StopIteration as stop:
            self.done = True
            return stop.value


class LoopReentered(Exception):
    pass


class Loop:
    def __init__(self, budget, tracing):
        self.ready = deque()  # (handle, id), FIFO
        self.parked = {}  # id -> handle
        self.tasks = []
        self.t_free = []
        self.regs = []
        self.r_free = []
        self.observers = []  # (slot, gen), registration order
        self.trace = []
        self.results = []
        self.budget = budget
        self.tracing = tracing
        self.turn_no = 0
        self.now = 0
        self.dispatching = False
        self.stopping = False
        self.seq = 0
        self.dispatched = 0
        self.collected = 0
        self.stale = 0
        self.failed = 0
        self.completed = 0
        self.wake_reason = 0
        self.wake_slot = 0
        self.wake_a = 0
        self.wake_b = 0
        self.keepwait = 0
        self.suppressed = 0
        self.reentered = 0
        self.observed = 0
        self.spawned = 0
        self.maxready = 0
        self.turn_collected = 0
        self.turn_dispatched = 0
        self.current = 0
        self.idle_turns = 0

    # -- tracing ------------------------------------------------------------

    def note(self, text):
        if self.tracing:
            self.trace.append("t=%d: %s" % (self.turn_no, text))

    # Application notes in the same trace: recorded also when tracing is off.
    def log(self, text):
        self.trace.append("t=%d: %s" % (self.turn_no, text))

    # -- tasks --------------------------------------------------------------

    def new_task(self):
        if self.t_free:
            tid = self.t_free.pop()
            t = self.tasks[tid]
        else:
            tid = len(self.tasks)
            t = Task()
            self.tasks.append(t)
        t.reason = WOKE_READY
        t.slot = -1
        t.gen = 0
        t.a = 0
        t.b = 0
        t.live = True
        self.spawned += 1
        return tid

    def retire_task(self, tid):
        self.tasks[tid].live = False
        self.t_free.append(tid)

    def push_ready(self, step, tid, reason, slot, gen, a, b):
        t = self.tasks[tid]
        t.reason = reason
        t.slot = slot
        t.gen = gen
        t.a = a
        t.b = b
        self.ready.append((step, tid))
        if len(self.ready) > self.maxready:
            self.maxready = len(self.ready)

    def complete(self, tid, value):
        self.completed += 1
        self.results.append(tid)
        self.results.append(value)
        self.retire_task(tid)

    def unpark(self, tid):
        return self.parked.pop(tid)

    def pop_waiter(self, r):
        if not r.waiters:
            return -1
        tid = r.waiters.popleft()
        if r.keep:
            self.keepwait -= 1
        return tid

    # -- registrations ------------------------------------------------------

    def new_reg(self, kind, keep, cap):
        if self.r_free:
            slot = self.r_free.pop()
            r = self.regs[slot]
        else:
            slot = len(self.regs)
            r = Registration()
            self.regs.append(r)
        r.kind = kind
        r.live = True
        r.keep = keep
        r.waiters.clear()
        r.deadline = -1
        r.period = 0
        r.cap = cap
        r.pending.clear()
        r.npend = 0
        r.dropped = 0
        r.seq = self.seq
        r.delivered = 0
        self.seq += 1
        return Reg(slot, r.gen)

    def live(self, reg):
        if reg.slot < 0 or reg.slot >= len(self.regs):
            return False
        r = self.regs[reg.slot]
        return r.gen == reg.gen and r.live

    def timer(self, deadline, period):
        reg = self.new_reg(KIND_TIMER, 1, 1)
        r = self.regs[reg.slot]
        r.deadline = deadline
        r.period = period
        if self.tracing:
            self.note("timer %d at %d every %d" % (reg.slot, deadline, period))
        return reg

    def after(self, delay):
        return self.timer(self.now + delay, 0)

    def every(self, period):
        return self.timer(self.now + period, period)

    def source(self, keep, cap):
        reg = self.new_reg(KIND_SOURCE, keep, cap)
        if self.tracing:
            self.note("source %d keep %d" % (reg.slot, keep))
        return reg

    def channel(self, cap):
        reg = self.new_reg(KIND_CHANNEL, 0, cap)
        if self.tracing:
            self.note("channel %d" % reg.slot)
        return reg

    def observer(self):
        reg = self.new_reg(KIND_TURN, 0, 0)
        self.observers.append((reg.slot, reg.gen))
        if self.tracing:
            self.note("observer %d" % reg.slot)
        return reg

    def free_reg(self, slot):
        r = self.regs[slot]
        r.gen += 1
        r.live = False
        self.r_free.append(slot)

    # A one-shot timer that fired: no longer live, but its generation stands
    # until its wake is dispatched (or the timer revoked).
    def spend_timer(self, r):
        if r.period == 0:
            r.live = False

    def revoke(self, reg):
        slot = reg.slot
        if slot < 0 or slot >= len(self.regs) or self.regs[slot].gen != reg.gen:
            if self.tracing:
                self.note("revoke stale %d" % slot)
            return 0
        r = self.regs[slot]
        discarded = r.npend
        r.live = False
        r.gen = reg.gen + 1
        r.pending.clear()
        r.npend = 0
        if self.tracing:
            self.note("revoke %d discarding %d" % (slot, discarded))
        while True:
            tid = self.pop_waiter(r)
            if tid == -1:
                break
            self.push_ready(self.unpark(tid), tid, WOKE_REVOKED, slot, reg.gen, 0, 0)
        self.r_free.append(slot)
        return 1

    # Deliver event (A, B) to SLOT, expected at generation GEN: its first
    # waiter is made ready, else the event is queued, else it is dropped.
    def deliver(self, slot, gen, reason, a, b):
        if slot < 0 or slot >= len(self.regs):
            stale = True
        else:
            r = self.regs[slot]
            stale = r.gen != gen or not r.live
        if stale:
            self.stale += 1
            if self.tracing:
                self.note("stale record for %d gen %d" % (slot, gen))
            return 0
        r.delivered += 1
        tid = self.pop_waiter(r)
        if tid != -1:
            self.push_ready(self.unpark(tid), tid, reason, slot, gen, a, b)
        elif r.npend >= r.cap:
            r.dropped += 1
            if self.tracing:
                self.note("overflow %d" % slot)
        else:
            r.pending.append((a, b))
            r.npend += 1
        return 1

    def post(self, reg, a, b):
        if not self.live(reg):
            return 0
        return self.deliver(reg.slot, reg.gen, WOKE_EVENT, a, b)

    # -- parking and adoption -----------------------------------------------

    def park(self, step, tid, slot):
        if slot < 0 or slot >= len(self.regs):
            self.push_ready(step, tid, WOKE_REVOKED, slot, 0, 0, 0)
            return
        r = self.regs[slot]
        gen = r.gen
        if not r.live:
            self.push_ready(step, tid, WOKE_REVOKED, slot, gen, 0, 0)
            return
        npend = r.npend
        if r.kind == KIND_TIMER and npend > 0:
            r.npend = 0
            self.spend_timer(r)
            self.push_ready(step, tid, WOKE_TIMER, slot, gen, npend - 1, 0)
            return
        if npend > 0:
            a, b = r.pending.popleft()
            r.npend = npend - 1
            self.push_ready(step, tid, WOKE_EVENT, slot, gen, a, b)
            return
        self.parked[tid] = step
        r.waiters.append(tid)
        if r.keep:
            self.keepwait += 1

    def after_segment(self, step, tid, code):
        if code == -1:
            self.push_ready(step, tid, WOKE_READY, -1, 0, 0, 0)
        else:
            self.park(step, tid, code)

    # Hand a task to the scheduler: its first segment already ran (Co.start)
    # and FIRST is what it yielded (or returned).
    def adopt(self, step, first):
        tid = self.new_task()
        if step.done:
            if self.tracing:
                self.note("task %d done at start %d" % (tid, first))
            self.complete(tid, first)
        else:
            if self.tracing:
                self.note("adopt task %d wants %d" % (tid, first))
            self.after_segment(step, tid, first)
        return tid

    # -- what tasks call (with `yield from`) --------------------------------

    def wait(self, reg):
        if not self.live(reg):
            return (WOKE_REVOKED, reg.slot, 0, 0)
        yield reg.slot
        return (self.wake_reason, self.wake_slot, self.wake_a, self.wake_b)

    def try_take(self, reg):
        if not self.live(reg):
            return (WOKE_REVOKED, reg.slot, 0, 0)
        slot = reg.slot
        r = self.regs[slot]
        if r.npend == 0 or r.kind == KIND_TIMER:
            return (-1, slot, 0, 0)
        a, b = r.pending.popleft()
        r.npend -= 1
        return (WOKE_EVENT, slot, a, b)

    # -- the turn -----------------------------------------------------------

    def run_task(self, step, tid):
        t = self.tasks[tid]
        reason = t.reason
        slot = t.slot
        if reason == WOKE_EVENT or reason == WOKE_TIMER or reason == WOKE_TURN:
            valid = self.regs[slot].gen == t.gen
        else:
            valid = True
        if not valid:
            self.suppressed += 1
            if self.tracing:
                self.note("suppress wake of task %d from revoked %d" % (tid, slot))
        effective = reason if valid else WOKE_REVOKED
        # A fired one-shot timer is freed once its wake is dispatched.
        if valid and reason == WOKE_TIMER:
            r = self.regs[slot]
            if not r.live and r.period == 0:
                self.free_reg(slot)
        self.wake_reason = effective
        self.wake_slot = slot
        if valid:
            self.wake_a = t.a
            self.wake_b = t.b
        else:
            self.wake_a = 0
            self.wake_b = 0
        self.current = tid
        self.dispatching = True
        self.dispatched += 1
        self.turn_dispatched += 1
        if self.tracing:
            self.note("run task %d reason %d" % (tid, effective))
        code = step.resume()
        self.dispatching = False
        if step.done:
            if self.tracing:
                self.note("task %d done %d" % (tid, code))
            self.complete(tid, code)
            return
        self.after_segment(step, tid, code)

    # The live timer slot with the earliest deadline <= NOW (smallest
    # sequence among equals), or -1.
    def earliest_timer(self, n, now):
        best = -1
        regs = self.regs
        for slot in range(n):
            r = regs[slot]
            if r.live and r.kind == KIND_TIMER:
                d = r.deadline
                if d >= 0 and d <= now:
                    if best == -1:
                        best = slot
                    else:
                        bd = regs[best].deadline
                        if d < bd or (d == bd and r.seq < regs[best].seq):
                            best = slot
        return best

    def fire_timer(self, slot, now):
        r = self.regs[slot]
        deadline = r.deadline
        period = r.period
        # The expiries owed: 1 + floor((now - deadline) / period).
        due = periods_due(deadline, period, now) if period > 0 else 1
        missed = due - 1
        r.deadline = deadline + due * period if period > 0 else -1
        if self.tracing:
            self.note("timer %d fires late %d missed %d" % (slot, now - deadline, missed))
        tid = self.pop_waiter(r)
        if tid != -1:
            self.spend_timer(r)
            self.push_ready(self.unpark(tid), tid, WOKE_TIMER, slot, r.gen, missed, 0)
            return
        # Nobody waits: the expiries are coalesced into one pending count.
        r.npend += due
        if period == 0:
            r.deadline = -1

    def expire_timers(self, now):
        n = len(self.regs)
        fired = 0
        while True:
            best = self.earliest_timer(n, now)
            if best == -1:
                break
            self.fire_timer(best, now)
            fired += 1
        return fired

    def collect_records(self, d):
        count = 0
        taken = 0
        while taken < self.budget:
            slot = d.take_record()
            if slot < 0:
                break
            taken += 1
            count += self.deliver(slot, d.record_gen(), WOKE_EVENT, d.record_a(), d.record_b())
        return count

    def compact_observers(self):
        regs = self.regs
        self.observers = [(slot, gen) for slot, gen in self.observers
                          if regs[slot].gen == gen and regs[slot].live]

    # Every turn registration live when the phase starts, in registration
    # order, runs its first waiting task once.
    def observe(self):
        n = len(self.observers)
        dead = 0
        for i in range(n):
            slot, gen = self.observers[i]
            r = self.regs[slot]
            if r.gen == gen and r.live:
                tid = self.pop_waiter(r)
                if tid != -1:
                    step = self.unpark(tid)
                    t = self.tasks[tid]
                    t.reason = WOKE_TURN
                    t.slot = slot
                    t.gen = gen
                    t.a = self.turn_no
                    t.b = 0
                    self.observed += 1
                    self.run_task(step, tid)
            else:
                dead += 1
        if dead > 0:
            self.compact_observers()

    def turn(self, d):
        if self.dispatching:
            self.reentered += 1
            raise LoopReentered()
        self.turn_no += 1
        self.now = d.clock()
        self.turn_dispatched = 0
        timers = self.expire_timers(self.now)
        records = self.collect_records(d)
        collected = timers + records
        self.turn_collected = collected
        self.collected += records
        n = len(self.ready)
        if self.tracing:
            self.note("collect timers %d records %d ready %d" % (timers, records, n))
        ready = self.ready
        for _ in range(n):
            step, tid = ready.popleft()
            self.run_task(step, tid)
        if collected + n > 0:
            self.observe()
        else:
            self.idle_turns += 1
        return n

    def live_work(self):
        return len(self.ready) > 0 or self.keepwait > 0

    # The earliest deadline of a timer some task waits on, or -1.
    def next_deadline(self):
        best = -1
        for r in self.regs:
            if r.live and r.kind == KIND_TIMER and r.waiters:
                d = r.deadline
                if d >= 0 and (best == -1 or d < best):
                    best = d
        return best

    def run(self, d):
        if self.dispatching:
            self.reentered += 1
            raise LoopReentered()
        self.stopping = False
        self.now = d.clock()
        first = self.turn_no
        while True:
            if self.stopping:
                self.note("stopped")
                break
            if not self.live_work():
                self.note("no live work")
                break
            deadline = d.clock() if self.ready else self.next_deadline()
            available = d.block(deadline)
            if available < 0 and not self.ready and self.next_deadline() == -1:
                self.note("driver exhausted")
                break
            self.turn(d)
        return self.turn_no - first


def periods_due(deadline, period, now):
    if now < deadline:
        return 0
    return (now - deadline) // period + 1


# Run again in the next turn (continuous activity).
def yield_now():
    yield -1


# ---------------------------------------------------------------------------
# simdrv: the deterministic driver and scripted network


class Sim:
    def __init__(self):
        self.now = 0
        self.script = []  # [when, slot, gen, a, b, released], in scripted order
        self.avail = []  # released records (slot, gen, a, b) not yet taken
        self.read = 0
        self.released = 0
        self.rec_slot = 0
        self.rec_gen = 0
        self.rec_a = 0
        self.rec_b = 0
        self.waits = []
        self.lines = []  # (conn, delay, cmd, arg)
        self.sent = []

    def inject(self, when, slot, gen, a, b):
        self.script.append([when, slot, gen, a, b, False])

    def clock(self):
        return self.now

    def release_due(self):
        now = self.now
        for rec in self.script:
            if not rec[5] and rec[0] <= now:
                self.avail.append((rec[1], rec[2], rec[3], rec[4]))
                rec[5] = True
                self.released += 1

    # The earliest time of a record not yet released, or -1.
    def next_due(self):
        best = -1
        for rec in self.script:
            if not rec[5]:
                t = rec[0]
                if best == -1 or t < best:
                    best = t
        return best

    def available(self):
        return len(self.avail) - self.read

    def block(self, deadline):
        self.waits.append(deadline)
        self.now += 1
        self.release_due()
        now = self.now
        nxt = self.next_due()
        if self.available() > 0:
            target = now
        elif deadline >= 0 and deadline <= now:
            target = now
        elif nxt == -1 and deadline == -1:
            target = -1
        elif nxt == -1:
            target = deadline
        elif deadline == -1 or nxt < deadline:
            target = nxt
        else:
            target = deadline
        if target == -1:
            return -1
        if target > now:
            self.now = target
            self.release_due()
        return self.available()

    def take_record(self):
        if self.read >= len(self.avail):
            return -1
        self.rec_slot, self.rec_gen, self.rec_a, self.rec_b = self.avail[self.read]
        self.read += 1
        return self.rec_slot

    def record_gen(self):
        return self.rec_gen

    def record_a(self):
        return self.rec_a

    def record_b(self):
        return self.rec_b

    # The scripted network (gameserver's Net).

    def line(self, conn, delay, cmd, arg):
        self.lines.append((conn, delay, cmd, arg))

    def attach(self, conn, slot, gen):
        now = self.now
        count = 0
        for c, delay, cmd, arg in self.lines:
            if c == conn:
                self.inject(now + delay, slot, gen, cmd, arg)
                count += 1
        return count

    def send(self, conn, value):
        self.sent.append(conn)
        self.sent.append(value)
        return 1

    def hangup(self, conn):
        self.sent.append(conn)
        self.sent.append(-1)
        return 1

    def ack(self, conn):
        return conn


# ---------------------------------------------------------------------------
# gameserver: the workload

# Reply kinds.
SAY_KIND = 1
FIND_KIND = 3
BYE_KIND = 4

# Steps of pathfinding between yields.
CHUNK = 10


# A dialogue: its own protocol (resumed with a Line (cmd, arg), yields a
# Reply (kind, value)), driven directly by its session.
def dialogue(conn):
    cmd, arg = yield (SAY_KIND, 1000 + conn)
    while cmd != 9:
        if cmd == 1:
            found = yield (FIND_KIND, arg)
            line = yield (SAY_KIND, 2000000 + found[1])
        else:
            line = yield (SAY_KIND, 3000000 + arg)
        cmd, arg = line
    return (BYE_KIND, conn)


# Pathfinding: a scheduler task that yields every CHUNK steps and posts its
# result (twice the length) to CH.
def pathfinder(ev, n, ch):
    for i in range(n):
        if i % CHUNK == 0:
            yield from yield_now()
    ev.post(ch, n * 2, 0)
    return n


def pathfind(ev, n):
    ch = ev.channel(1)
    step = Co(pathfinder(ev, n, ch))
    first = step.start()
    ev.adopt(step, first)
    e = yield from ev.wait(ch)
    ev.revoke(ch)
    return e[2]


def session(ev, net, conn, reg, outbox):
    # lines handled, the largest and the total `now - arg` of TALK lines
    handled = 0
    max_lag = 0
    total_lag = 0
    talk = Co(dialogue(conn))
    first = talk.start()
    ev.post(outbox, conn, first[1])
    while True:
        reason, _, a, b = yield from ev.wait(reg)
        if reason != WOKE_EVENT:
            break
        handled += 1
        if a == 2:
            lag = ev.now - b
            if lag > max_lag:
                max_lag = lag
            total_lag += lag
        if ev.tracing:
            ev.log("conn %d cmd %d in turn %d" % (conn, a, ev.turn_no))
        reply = talk.resume((a, b))
        if reply[0] == FIND_KIND:
            found = yield from pathfind(ev, reply[1])
            ev.log("conn %d path found in turn %d" % (conn, ev.turn_no))
            final = talk.resume((100, found))
        else:
            final = reply
        if final[0] == BYE_KIND:
            break
        ev.post(outbox, conn, final[1])
        # Demand-driven reading: one more line may be read for this connection.
        net.ack(conn)
    net.hangup(conn)
    ev.revoke(reg)
    ev.log("conn %d closed in turn %d" % (conn, ev.turn_no))
    ev.log("conn %d lines %d" % (conn, handled))
    ev.log("conn %d max lag us %d" % (conn, max_lag))
    ev.log("conn %d total lag us %d" % (conn, total_lag))
    return handled


def acceptor(ev, net, listener, outbox, most):
    for _ in range(most):
        reason, _, a, _ = yield from ev.wait(listener)
        if reason != WOKE_EVENT:
            break
        conn = a
        reg = ev.source(1, 16)
        net.attach(conn, reg.slot, reg.gen)
        step = Co(session(ev, net, conn, reg, outbox))
        first = step.start()
        ev.adopt(step, first)
    ev.revoke(listener)
    return most


# The once-per-turn output flush: everything the sessions posted this turn,
# sent in one batch.
def flusher(ev, net, outbox):
    obs = ev.observer()
    total = 0
    while True:
        reason, _, turn, _ = yield from ev.wait(obs)
        if reason != WOKE_TURN:
            break
        count = 0
        while True:
            m_reason, _, conn, value = ev.try_take(outbox)
            if m_reason != WOKE_EVENT:
                break
            net.send(conn, value)
            count += 1
        if count > 0:
            ev.log("flush %d in turn %d" % (count, turn))
            total += count
    return total


# An AI agent: its own protocol (resumed with a Tick's n, yields a Move's x),
# advanced directly, one step per world tick.
def agent():
    pos = 0
    while True:
        x = pos
        n = yield x
        pos = x + n


def world(ev, period, ticks):
    clock = ev.every(period)
    ai = Co(agent())
    pos = ai.start()
    for _ in range(ticks):
        _, _, missed, _ = yield from ev.wait(clock)
        x = ai.resume(1 + missed)
        pos = x
        ev.log("world tick, agent at %d" % x)
    ev.revoke(clock)
    return pos


# ---------------------------------------------------------------------------
# The entry (bench/experimental/game-server.bot)

CONNS = 12
LINES = 18
PERIOD = 25
TICKS = 12


# A fold of VALUES that depends on their order (every value >= -1).
def checksum(values):
    h = 7
    for v in values:
        h = (h * 31 + v + 2) % 1000000007
    return h


def script(ev, d):
    listener = ev.source(1, CONNS + 4)
    for c in range(1, CONNS + 1):
        d.inject(4 + c, listener.slot, listener.gen, c, 0)
        spacing = 3 + c % 3
        for k in range(LINES):
            if k % 4 == 1:
                d.line(c, 1 + k * spacing, 1, 10 * (1 + (c + k) % 5))
            else:
                d.line(c, 1 + k * spacing, 2, c * 100 + k)
        d.line(c, 6 + LINES * spacing, 9, 0)
    outbox = ev.channel(4096)
    a = Co(acceptor(ev, d, listener, outbox, CONNS))
    ev.adopt(a, a.start())
    f = Co(flusher(ev, d, outbox))
    ev.adopt(f, f.start())
    w = Co(world(ev, PERIOD, TICKS))
    ev.adopt(w, w.start())


def run_once():
    ev = Loop(8, 0)
    d = Sim()
    script(ev, d)
    turns = ev.run(d)
    sent = list(d.sent)
    trace = list(ev.trace)
    chars = 0
    for line in trace:
        chars += len(line)
    return [turns, ev.dispatched, ev.completed, ev.observed, ev.stale,
            len(sent), checksum(sent), checksum(list(ev.results)), len(trace), chars]


def parse_args(argv):
    runs = 5
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        i += 1
    return runs


if __name__ == "__main__":
    runs = parse_args(sys.argv[1:])

    run_once()  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once()
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print("value: [" + ", ".join(str(v) for v in value) + "]")
    print(f"best_us: {best:.3f}")
