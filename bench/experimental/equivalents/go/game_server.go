// Go equivalent of bench/experimental/game-server.bot: the game-server
// workload of EVENT-LOOP-EXPLORATION.md (audit/event-loop/src/gameserver.bot)
// on the audit's prototype scheduler (audit/event-loop/src/evloop.bot) and its
// deterministic virtual-clock driver (audit/event-loop/src/simdrv.bot).
//
// Invoked by bench/bench.tcl; see bench/equivalents/go/fib.go for the
// --runs/value/best_us protocol shared by every equivalent: one untimed warmup
// run of the whole workload, then N timed runs, each building everything from
// scratch (loop, driver, script, tasks) as one Botlish program run does. The
// printed value has core::value::show's "[a, b, ...]" shape.
//
// Coroutines. A Botlish coroutine is started eagerly (its construction runs
// it to its first yield, side effects included, inside the code that makes
// it) and is resumed with a value of its protocol. Coroutine[R, Y] is one over
// Go 1.23's iter.Pull, whose coroutines switch without the scheduler: Start
// runs the body to its first yield and returns what it yielded (or returned,
// when it completed at once: Done), Resume passes the resume value through a
// field the body's yield returns, and Release drops a coroutine without
// resuming it (iter.Pull's stop: a suspended body is unwound, never resumed,
// as Botlish releases a dropped coroutine). A scheduler task is a
// Coroutine[struct{}, int]: its body yields its request (-1, run again, or the
// slot of the registration it waits on) and, resumed with nothing, reads what
// woke it from the loop's wake register, as evloop::wait does. Its yield
// function is handed to the helpers it calls (wait, yieldNow, pathfind), so a
// yield inside a called function suspends the whole task: Botlish's deep
// yield. The dialogue (resume Line, yields Reply) and the AI agent (resume
// Tick, yields Move) are coroutines of their own protocols, resumed directly
// by the session and the world that own them.
//
// The scheduler. evloop's int rows become structs and slices: a registration
// (addressed by Reg{slot, gen}, slots reused from a LIFO free list, the
// generation bumped when one is freed or revoked) keeps its waiters as an
// intrusive FIFO through the task rows and its bounded event queue as a slice;
// a task id comes from a LIFO free list, and its row holds its handle while it
// is parked (Botlish's parked set); the run queue (two stacks of handles in
// Botlish) is one FIFO of (handle, id). What the value observes is kept
// exactly: the turn (block, expire timers in deadline then registration
// order, collect at most `budget` records, dispatch exactly the tasks ready
// when the phase starts, run the observers only in a turn that collected or
// dispatched something), coalesced timer expiries, one-shot timers freed when
// their wake is dispatched, the wake validity check, live work and the next
// deadline, results as (id, value) pairs in completion order, and the
// application log's lines ("t=TURN: text"). periods_due's doubling and binary
// search compute 1 + (now - deadline) / period, which Go divides directly.
// The scheduler trace (tracing 1) is ported too, off as in the benchmark.
//
// The driver. simdrv's Sim: a virtual clock (each block() visit costs one
// microsecond), a script of records released in scripted order once the clock
// reaches their time (the same linear scans), and the scripted network
// (attach turns a connection's lines into records at now + delay). Botlish's
// installed contexts, the Loop and the Sim (the Driver and Net traits are
// selected statically), are passed explicitly. The workload's error handlers
// (IndexNotFound, TaskFailed) never fire in this script and are not modeled.
//
// expect: [112, 604, 74, 112, 0, 480, 972395168, 705481770, 209, 5838]
package main

import (
	"errors"
	"fmt"
	"iter"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

// ---------------------------------------------------------------------------
// Coroutines

// abandoned unwinds a suspended coroutine its owner releases: iter.Pull's
// stop makes its yield return false, and the body must return.
type abandoned struct{}

// Coroutine is an eagerly started Botlish coroutine: resumed with an R, it
// yields a Y, or completes returning one.
type Coroutine[R, Y any] struct {
	next   func() (Y, bool)
	stop   func()
	in     R
	result Y
	done   bool
}

// Start constructs a coroutine of BODY and runs it to its first yield; it
// returns the coroutine and what that segment yielded (or returned).
func Start[R, Y any](body func(yield func(Y) R) Y) (*Coroutine[R, Y], Y) {
	co := &Coroutine[R, Y]{}
	co.next, co.stop = iter.Pull(func(yield func(Y) bool) {
		defer func() {
			if p := recover(); p != nil {
				if _, ok := p.(abandoned); !ok {
					panic(p)
				}
			}
		}()
		co.result = body(func(v Y) R {
			if !yield(v) {
				panic(abandoned{})
			}
			return co.in
		})
	})
	var none R
	return co, co.Resume(none)
}

// Resume runs the coroutine's next segment with IN as the value of the yield
// it is suspended at: what it yields next, or what it returns (Done).
func (co *Coroutine[R, Y]) Resume(in R) Y {
	co.in = in
	v, ok := co.next()
	if !ok {
		co.done = true
		return co.result
	}
	return v
}

// Done is std::coroutine::done?.
func (co *Coroutine[R, Y]) Done() bool { return co.done }

// Release drops the coroutine: a suspended one is unwound, never resumed.
func (co *Coroutine[R, Y]) Release() { co.stop() }

// Task is the scheduler's task protocol, Coroutine{args: [], return: int}.
type Task = Coroutine[struct{}, int]

// Suspend is a task's yield: it hands the scheduler its request.
type Suspend = func(int) struct{}

// ---------------------------------------------------------------------------
// evloop

// Registration kinds.
const (
	kindTimer   = 1
	kindSource  = 2
	kindChannel = 3
	kindTurn    = 4
)

// Wake reasons: what made a task ready.
const (
	wokeReady   = 0
	wokeEvent   = 1
	wokeTimer   = 2
	wokeRevoked = 3
	wokeTurn    = 4
)

var errLoopReentered = errors.New("LoopReentered")

// Reg is a registration's identity: its slot and the generation it had when
// made.
type Reg struct{ slot, gen int }

// Event is what woke a task: the reason, the registration's slot and the
// event's two ints (a timer's a: the intervals missed and coalesced).
type Event struct{ reason, slot, a, b int }

type pair struct{ a, b int }

type registration struct {
	gen, kind    int
	live, keep   bool
	whead, wtail int // the waiters' FIFO, linked through taskRow.next
	nwait        int
	deadline     int
	period       int
	cap          int
	queue        []pair // the undelivered events, from qhead
	qhead        int
	npend        int // queued events (a timer's: coalesced expiries)
	dropped      int
	seq          int
	delivered    int
}

func (r *registration) enqueue(a, b int) {
	r.queue = append(r.queue, pair{a, b})
	r.npend++
}

func (r *registration) dequeue() pair {
	p := r.queue[r.qhead]
	r.qhead++
	if r.qhead == len(r.queue) {
		r.queue, r.qhead = r.queue[:0], 0
	}
	r.npend--
	return p
}

type taskRow struct {
	next                    int // the next waiter of the registration it waits on
	reason, slot, gen, a, b int // the wake that made it ready
	live                    bool
	parked                  *Task // its handle while it waits on a registration
}

type readyTask struct {
	step *Task
	id   int
}

// readyQueue is the run queue: a FIFO of (handle, id).
type readyQueue struct {
	buf  []readyTask
	head int
}

func (q *readyQueue) len() int { return len(q.buf) - q.head }

func (q *readyQueue) push(t readyTask) {
	if q.head > 0 && len(q.buf) == cap(q.buf) {
		n := copy(q.buf, q.buf[q.head:])
		clear(q.buf[n:])
		q.buf, q.head = q.buf[:n], 0
	}
	q.buf = append(q.buf, t)
}

func (q *readyQueue) pop() readyTask {
	t := q.buf[q.head]
	q.buf[q.head] = readyTask{}
	q.head++
	if q.head == len(q.buf) {
		q.buf, q.head = q.buf[:0], 0
	}
	return t
}

// Loop is evloop's installed scheduler state.
type Loop struct {
	ready     readyQueue
	tasks     []taskRow
	tFree     []int
	regs      []registration
	rFree     []int
	observers []Reg
	trace     []string
	results   []int

	budget      int
	tracing     bool
	turn        int
	now         int
	dispatching bool
	stopping    bool
	seq         int
	wake        Event
	current     int
	keepwait    int

	dispatched, collected, stale, suppressed, completed int
	reentered, observed, spawned, maxReady, idleTurns   int
	turnCollected, turnDispatched                       int
}

// newLoop is a Loop that dispatches at most BUDGET native records per turn;
// TRACING records a trace of every scheduling decision.
func newLoop(budget int, tracing bool) *Loop {
	return &Loop{budget: budget, tracing: tracing}
}

func cat(text string, n int) string { return text + strconv.Itoa(n) }

func (ev *Loop) note(text string) {
	if ev.tracing {
		ev.log(text)
	}
}

// log is an application note in the trace, recorded also when scheduler
// tracing is off.
func (ev *Loop) log(text string) {
	ev.trace = append(ev.trace, cat("t=", ev.turn)+": "+text)
}

// Tasks

func (ev *Loop) newTask() int {
	var id int
	if n := len(ev.tFree); n == 0 {
		id = len(ev.tasks)
		ev.tasks = append(ev.tasks, taskRow{})
	} else {
		id = ev.tFree[n-1]
		ev.tFree = ev.tFree[:n-1]
	}
	ev.tasks[id] = taskRow{next: -1, reason: wokeReady, slot: -1, live: true}
	ev.spawned++
	return id
}

func (ev *Loop) retireTask(id int) {
	ev.tasks[id].live = false
	ev.tFree = append(ev.tFree, id)
}

// pushReady makes task ID (handle STEP) ready with REASON from registration
// SLOT/GEN.
func (ev *Loop) pushReady(step *Task, id, reason, slot, gen, a, b int) {
	t := &ev.tasks[id]
	t.reason, t.slot, t.gen, t.a, t.b = reason, slot, gen, a, b
	ev.ready.push(readyTask{step, id})
	if n := ev.ready.len(); n > ev.maxReady {
		ev.maxReady = n
	}
}

func (ev *Loop) complete(id, value int) {
	ev.completed++
	ev.results = append(ev.results, id, value)
	ev.retireTask(id)
}

// unpark takes parked task ID's handle out of the parked set.
func (ev *Loop) unpark(id int) *Task {
	t := &ev.tasks[id]
	step := t.parked
	t.parked = nil
	return step
}

// popWaiter removes the first waiter of SLOT from its FIFO (-1 when none).
func (ev *Loop) popWaiter(slot int) int {
	r := &ev.regs[slot]
	id := r.whead
	if id == -1 {
		return -1
	}
	next := ev.tasks[id].next
	r.whead = next
	if next == -1 {
		r.wtail = -1
	}
	ev.tasks[id].next = -1
	r.nwait--
	if r.keep {
		ev.keepwait--
	}
	return id
}

// Registrations

func (ev *Loop) newReg(kind int, keep bool, cap int) Reg {
	var slot int
	if n := len(ev.rFree); n == 0 {
		slot = len(ev.regs)
		ev.regs = append(ev.regs, registration{gen: 1})
	} else {
		slot = ev.rFree[n-1]
		ev.rFree = ev.rFree[:n-1]
	}
	r := &ev.regs[slot]
	r.kind = kind
	r.live = true
	r.keep = keep
	r.whead, r.wtail, r.nwait = -1, -1, 0
	r.deadline, r.period = -1, 0
	r.cap = cap
	r.queue, r.qhead, r.npend = r.queue[:0], 0, 0
	r.dropped = 0
	r.seq = ev.seq
	r.delivered = 0
	ev.seq++
	return Reg{slot, r.gen}
}

// isLive is evloop::live?: REG still names a live registration.
func (ev *Loop) isLive(reg Reg) bool {
	if reg.slot < 0 || reg.slot >= len(ev.regs) {
		return false
	}
	r := &ev.regs[reg.slot]
	return r.gen == reg.gen && r.live
}

// timer is a one-shot timer at DEADLINE, or a repeating one (PERIOD > 0)
// whose first expiry is DEADLINE.
func (ev *Loop) timer(deadline, period int) Reg {
	reg := ev.newReg(kindTimer, true, 1)
	r := &ev.regs[reg.slot]
	r.deadline = deadline
	r.period = period
	if ev.tracing {
		ev.note(cat("timer ", reg.slot) + cat(" at ", deadline) + cat(" every ", period))
	}
	return reg
}

func (ev *Loop) every(period int) Reg { return ev.timer(ev.now+period, period) }

// source is a source of driver records; KEEP: a task waiting on it keeps the
// loop alive. At most CAP undelivered events are queued.
func (ev *Loop) source(keep bool, cap int) Reg {
	reg := ev.newReg(kindSource, keep, cap)
	if ev.tracing {
		k := 0
		if keep {
			k = 1
		}
		ev.note(cat("source ", reg.slot) + cat(" keep ", k))
	}
	return reg
}

// channel is a registration Botlish code posts to.
func (ev *Loop) channel(cap int) Reg {
	reg := ev.newReg(kindChannel, false, cap)
	if ev.tracing {
		ev.note(cat("channel ", reg.slot))
	}
	return reg
}

// observer is a once-per-turn registration.
func (ev *Loop) observer() Reg {
	reg := ev.newReg(kindTurn, false, 0)
	ev.observers = append(ev.observers, reg)
	if ev.tracing {
		ev.note(cat("observer ", reg.slot))
	}
	return reg
}

func (ev *Loop) freeReg(slot int) {
	r := &ev.regs[slot]
	r.gen++
	r.live = false
	ev.rFree = append(ev.rFree, slot)
}

// spendTimer: a one-shot timer that fired is no longer live, but its
// generation stands until its wake is dispatched (or it is revoked).
func (ev *Loop) spendTimer(slot int) {
	if ev.regs[slot].period == 0 {
		ev.regs[slot].live = false
	}
}

// revoke discards REG's queued events and wakes its waiters with
// wokeRevoked; a stale REG does nothing (0).
func (ev *Loop) revoke(reg Reg) int {
	if reg.slot < 0 || reg.slot >= len(ev.regs) || ev.regs[reg.slot].gen != reg.gen {
		if ev.tracing {
			ev.note(cat("revoke stale ", reg.slot))
		}
		return 0
	}
	slot := reg.slot
	r := &ev.regs[slot]
	discarded := r.npend
	r.live = false
	r.gen = reg.gen + 1
	r.queue, r.qhead, r.npend = r.queue[:0], 0, 0
	if ev.tracing {
		ev.note(cat("revoke ", slot) + cat(" discarding ", discarded))
	}
	for {
		id := ev.popWaiter(slot)
		if id == -1 {
			break
		}
		ev.pushReady(ev.unpark(id), id, wokeRevoked, slot, reg.gen, 0, 0)
	}
	ev.rFree = append(ev.rFree, slot)
	return 1
}

// deliver hands event (A, B) to registration SLOT, expected at generation
// GEN: its first waiter is made ready, else the event is queued, else it is
// counted and dropped. 0 for a stale record, else 1.
func (ev *Loop) deliver(slot, gen, reason, a, b int) int {
	if slot < 0 || slot >= len(ev.regs) || ev.regs[slot].gen != gen || !ev.regs[slot].live {
		ev.stale++
		if ev.tracing {
			ev.note(cat("stale record for ", slot) + cat(" gen ", gen))
		}
		return 0
	}
	r := &ev.regs[slot]
	r.delivered++
	if id := ev.popWaiter(slot); id != -1 {
		ev.pushReady(ev.unpark(id), id, reason, slot, gen, a, b)
	} else if r.npend >= r.cap {
		r.dropped++
		if ev.tracing {
			ev.note(cat("overflow ", slot))
		}
	} else {
		r.enqueue(a, b)
	}
	return 1
}

// post (A, B) to a channel or source REG; 0 when REG is not live.
func (ev *Loop) post(reg Reg, a, b int) int {
	if !ev.isLive(reg) {
		return 0
	}
	return ev.deliver(reg.slot, reg.gen, wokeEvent, a, b)
}

// Parking and adoption

// park task ID on registration SLOT, or make it ready at once when the
// registration has something for it (or is not live).
func (ev *Loop) park(step *Task, id, slot int) {
	if slot < 0 || slot >= len(ev.regs) {
		ev.pushReady(step, id, wokeRevoked, slot, 0, 0, 0)
		return
	}
	r := &ev.regs[slot]
	gen := r.gen
	if !r.live {
		ev.pushReady(step, id, wokeRevoked, slot, gen, 0, 0)
		return
	}
	npend := r.npend
	if r.kind == kindTimer && npend > 0 {
		r.npend = 0
		ev.spendTimer(slot)
		ev.pushReady(step, id, wokeTimer, slot, gen, npend-1, 0)
		return
	}
	if npend > 0 {
		p := r.dequeue()
		ev.pushReady(step, id, wokeEvent, slot, gen, p.a, p.b)
		return
	}
	t := &ev.tasks[id]
	t.next = -1
	t.parked = step
	if r.wtail == -1 {
		r.whead = id
	} else {
		ev.tasks[r.wtail].next = id
	}
	r.wtail = id
	r.nwait++
	if r.keep {
		ev.keepwait++
	}
}

// afterSegment: a request of -1 is ready again, a slot parks there.
func (ev *Loop) afterSegment(step *Task, id, code int) {
	if code == -1 {
		ev.pushReady(step, id, wokeReady, -1, 0, 0, 0)
	} else {
		ev.park(step, id, code)
	}
}

// adopt hands a task to the scheduler: STEP was constructed by the caller
// (its first segment already ran), FIRST is what that segment yielded.
func (ev *Loop) adopt(step *Task, first int) int {
	id := ev.newTask()
	if step.Done() {
		if ev.tracing {
			ev.note(cat("task ", id) + cat(" done at start ", first))
		}
		ev.complete(id, first)
	} else {
		if ev.tracing {
			ev.note(cat("adopt task ", id) + cat(" wants ", first))
		}
		ev.afterSegment(step, id, first)
	}
	return id
}

// What tasks call (they yield to the scheduler through Y)

// yieldNow: run again in the next turn.
func (ev *Loop) yieldNow(y Suspend) { y(-1) }

// wait for REG's next event (or its timer, its turn, its revocation).
func (ev *Loop) wait(y Suspend, reg Reg) Event {
	if !ev.isLive(reg) {
		return Event{wokeRevoked, reg.slot, 0, 0}
	}
	y(reg.slot)
	return ev.wake
}

// tryTake is REG's next queued event without suspending: reason wokeEvent,
// or -1 when nothing is queued (wokeRevoked when REG is not live).
func (ev *Loop) tryTake(reg Reg) Event {
	if !ev.isLive(reg) {
		return Event{wokeRevoked, reg.slot, 0, 0}
	}
	r := &ev.regs[reg.slot]
	if r.npend == 0 || r.kind == kindTimer {
		return Event{-1, reg.slot, 0, 0}
	}
	p := r.dequeue()
	return Event{wokeEvent, reg.slot, p.a, p.b}
}

// The turn

// runTask resumes task ID (handle STEP), already out of every queue.
func (ev *Loop) runTask(step *Task, id int) {
	t := ev.tasks[id]
	reason, slot, gen := t.reason, t.slot, t.gen
	valid := true
	if reason == wokeEvent || reason == wokeTimer || reason == wokeTurn {
		valid = ev.regs[slot].gen == gen
	}
	effective := reason
	if !valid {
		ev.suppressed++
		if ev.tracing {
			ev.note(cat("suppress wake of task ", id) + cat(" from revoked ", slot))
		}
		effective = wokeRevoked
	}
	// A fired one-shot timer is freed once its wake is dispatched.
	if valid && reason == wokeTimer && !ev.regs[slot].live && ev.regs[slot].period == 0 {
		ev.freeReg(slot)
	}
	// A suppressed wake carries nothing of the event it was for.
	ev.wake = Event{effective, slot, 0, 0}
	if valid {
		ev.wake.a, ev.wake.b = t.a, t.b
	}
	ev.current = id
	ev.dispatching = true
	ev.dispatched++
	ev.turnDispatched++
	if ev.tracing {
		ev.note(cat("run task ", id) + cat(" reason ", effective))
	}
	code := step.Resume(struct{}{})
	ev.dispatching = false
	if step.Done() {
		if ev.tracing {
			ev.note(cat("task ", id) + cat(" done ", code))
		}
		ev.complete(id, code)
		return
	}
	ev.afterSegment(step, id, code)
}

// earliestTimer is the live timer slot below N with the earliest deadline
// <= NOW (smallest sequence among equals), or -1.
func (ev *Loop) earliestTimer(n, now int) int {
	best := -1
	for slot := 0; slot < n; slot++ {
		r := &ev.regs[slot]
		if !r.live || r.kind != kindTimer {
			continue
		}
		d := r.deadline
		if d < 0 || d > now {
			continue
		}
		if best == -1 {
			best = slot
		} else if bd := ev.regs[best].deadline; d < bd || (d == bd && r.seq < ev.regs[best].seq) {
			best = slot
		}
	}
	return best
}

// periodsDue is how many whole periods past DEADLINE NOW is (>= 1 when
// NOW >= DEADLINE): evloop's doubling and binary search find
// 1 + floor((now - deadline) / period).
func periodsDue(deadline, period, now int) int {
	if now < deadline {
		return 0
	}
	return 1 + (now-deadline)/period
}

func (ev *Loop) fireTimer(slot, now int) {
	r := &ev.regs[slot]
	deadline, period := r.deadline, r.period
	due := 1
	if period > 0 {
		due = periodsDue(deadline, period, now)
	}
	missed := due - 1
	if period > 0 {
		r.deadline = deadline + due*period
	} else {
		r.deadline = -1
	}
	if ev.tracing {
		ev.note(cat("timer ", slot) + cat(" fires late ", now-deadline) + cat(" missed ", missed))
	}
	if id := ev.popWaiter(slot); id != -1 {
		ev.spendTimer(slot)
		ev.pushReady(ev.unpark(id), id, wokeTimer, slot, r.gen, missed, 0)
		return
	}
	// Nobody waits: the expiries are coalesced into one pending count.
	r.npend += due
	if period == 0 {
		r.deadline = -1
	}
}

// expireTimers expires the timers due at NOW, earliest deadline first
// (registration order among equal deadlines); it returns how many fired.
func (ev *Loop) expireTimers(now int) int {
	n := len(ev.regs)
	fired := 0
	for {
		best := ev.earliestTimer(n, now)
		if best == -1 {
			break
		}
		ev.fireTimer(best, now)
		fired++
	}
	return fired
}

// collectRecords delivers at most the budget of driver records; it returns
// how many were delivered (a stale record is taken, counted, and does
// nothing).
func (ev *Loop) collectRecords(d *Sim) int {
	count := 0
	for taken := 0; taken < ev.budget; {
		slot := d.takeRecord()
		if slot < 0 {
			break
		}
		taken++
		count += ev.deliver(slot, d.recordGen(), wokeEvent, d.recordA(), d.recordB())
	}
	return count
}

// compactObservers drops the entries of revoked observers.
func (ev *Loop) compactObservers() {
	keep := ev.observers[:0]
	for _, o := range ev.observers {
		if r := &ev.regs[o.slot]; r.gen == o.gen && r.live {
			keep = append(keep, o)
		}
	}
	ev.observers = keep
}

// observe is the observer phase: every turn registration live when it
// starts, in registration order, runs its first waiting task once.
func (ev *Loop) observe() {
	n := len(ev.observers)
	dead := 0
	for i := 0; i < n; i++ {
		o := ev.observers[i]
		if r := &ev.regs[o.slot]; r.gen != o.gen || !r.live {
			dead++
			continue
		}
		id := ev.popWaiter(o.slot)
		if id == -1 {
			continue
		}
		step := ev.unpark(id)
		t := &ev.tasks[id]
		t.reason, t.slot, t.gen, t.a, t.b = wokeTurn, o.slot, o.gen, ev.turn, 0
		ev.observed++
		ev.runTask(step, id)
	}
	if dead > 0 {
		ev.compactObservers()
	}
}

// runTurn is one scheduling turn without waiting: collect, dispatch,
// observe. It returns how many tasks it dispatched.
func (ev *Loop) runTurn(d *Sim) (int, error) {
	if ev.dispatching {
		ev.reentered++
		return 0, errLoopReentered
	}
	ev.turn++
	ev.now = d.clock()
	ev.turnDispatched = 0
	timers := ev.expireTimers(ev.now)
	records := ev.collectRecords(d)
	collected := timers + records
	ev.turnCollected = collected
	ev.collected += records
	n := ev.ready.len()
	if ev.tracing {
		ev.note(cat("collect timers ", timers) + cat(" records ", records) + cat(" ready ", n))
	}
	for i := 0; i < n; i++ {
		t := ev.ready.pop()
		ev.runTask(t.step, t.id)
	}
	if collected+n > 0 {
		ev.observe()
	} else {
		ev.idleTurns++
	}
	return n, nil
}

// liveWork: ready work, or a task waiting on a registration that keeps the
// loop alive.
func (ev *Loop) liveWork() bool {
	return ev.ready.len() > 0 || ev.keepwait > 0
}

// nextDeadline is the earliest deadline of a timer some task waits on, or -1.
func (ev *Loop) nextDeadline() int {
	best := -1
	for slot := range ev.regs {
		r := &ev.regs[slot]
		if r.live && r.kind == kindTimer && r.nwait > 0 {
			if d := r.deadline; d >= 0 && (best == -1 || d < best) {
				best = d
			}
		}
	}
	return best
}

// run drives the loop until nothing can happen any more (or a driver that
// can never deliver again); it returns the number of turns.
func (ev *Loop) run(d *Sim) (int, error) {
	if ev.dispatching {
		ev.reentered++
		return 0, errLoopReentered
	}
	ev.stopping = false
	ev.now = d.clock()
	first := ev.turn
	for {
		if ev.stopping {
			ev.note("stopped")
			break
		}
		if !ev.liveWork() {
			ev.note("no live work")
			break
		}
		var deadline int
		if ev.ready.len() > 0 {
			deadline = d.clock()
		} else {
			deadline = ev.nextDeadline()
		}
		available := d.block(deadline)
		if available < 0 && ev.ready.len() == 0 && ev.nextDeadline() == -1 {
			ev.note("driver exhausted")
			break
		}
		if _, err := ev.runTurn(d); err != nil {
			return 0, err
		}
	}
	return ev.turn - first, nil
}

// abandon releases every task the loop still owns without running it (a
// released coroutine is unwound, never resumed); it returns how many.
func (ev *Loop) abandon() int {
	dropped := 0
	for ev.ready.len() > 0 {
		t := ev.ready.pop()
		t.step.Release()
		ev.retireTask(t.id)
		dropped++
	}
	for id := range ev.tasks {
		if step := ev.tasks[id].parked; step != nil {
			ev.tasks[id].parked = nil
			step.Release()
			ev.retireTask(id)
			dropped++
		}
	}
	if ev.tracing {
		ev.note(cat("abandon ", dropped))
	}
	return dropped
}

// ---------------------------------------------------------------------------
// simdrv: the deterministic driver and its scripted network

type record struct {
	when, slot, gen, a, b int
	released              bool
}

type released struct{ slot, gen, a, b int }

type connLine struct{ conn, delay, cmd, arg int }

// Sim is simdrv's installed driver state.
type Sim struct {
	now     int
	script  []record
	avail   []released // released records, taken from read on
	read    int
	current released
	waits   []int
	lines   []connLine
	sent    []int
}

func newSim() *Sim { return &Sim{} }

// inject scripts a record for registration (SLOT, GEN) at time WHEN.
func (s *Sim) inject(when, slot, gen, a, b int) {
	s.script = append(s.script, record{when: when, slot: slot, gen: gen, a: a, b: b})
}

func (s *Sim) clock() int { return s.now }

func (s *Sim) releaseDue() {
	for i := range s.script {
		r := &s.script[i]
		if !r.released && r.when <= s.now {
			s.avail = append(s.avail, released{r.slot, r.gen, r.a, r.b})
			r.released = true
		}
	}
}

// nextDue is the earliest time of a record not yet released, or -1.
func (s *Sim) nextDue() int {
	best := -1
	for i := range s.script {
		if r := &s.script[i]; !r.released && (best == -1 || r.when < best) {
			best = r.when
		}
	}
	return best
}

func (s *Sim) available() int { return len(s.avail) - s.read }

// block never sleeps: each visit costs one microsecond, then the clock
// advances to the next scripted record or DEADLINE, whichever comes first.
func (s *Sim) block(deadline int) int {
	s.waits = append(s.waits, deadline)
	s.now++
	s.releaseDue()
	now := s.now
	next := s.nextDue()
	var target int
	switch {
	case s.available() > 0:
		target = now
	case deadline >= 0 && deadline <= now:
		target = now
	case next == -1 && deadline == -1:
		target = -1
	case next == -1:
		target = deadline
	case deadline == -1 || next < deadline:
		target = next
	default:
		target = deadline
	}
	if target == -1 {
		return -1
	}
	if target > now {
		s.now = target
		s.releaseDue()
	}
	return s.available()
}

func (s *Sim) takeRecord() int {
	if s.read >= len(s.avail) {
		return -1
	}
	s.current = s.avail[s.read]
	s.read++
	return s.current.slot
}

func (s *Sim) recordGen() int { return s.current.gen }
func (s *Sim) recordA() int   { return s.current.a }
func (s *Sim) recordB() int   { return s.current.b }

// line: connection CONN's line (CMD, ARG) arrives DELAY microseconds after
// the connection is attached.
func (s *Sim) line(conn, delay, cmd, arg int) {
	s.lines = append(s.lines, connLine{conn, delay, cmd, arg})
}

func (s *Sim) attach(conn, slot, gen int) int {
	count := 0
	for _, l := range s.lines {
		if l.conn == conn {
			s.inject(s.now+l.delay, slot, gen, l.cmd, l.arg)
			count++
		}
	}
	return count
}

func (s *Sim) send(conn, value int) int {
	s.sent = append(s.sent, conn, value)
	return 1
}

func (s *Sim) hangup(conn int) int {
	s.sent = append(s.sent, conn, -1)
	return 1
}

func (s *Sim) ack(conn int) int { return conn }

// ---------------------------------------------------------------------------
// gameserver

type Line struct{ cmd, arg int }
type Reply struct{ kind, value int }
type Tick struct{ n int }
type Move struct{ x int }

// Reply kinds.
const (
	sayKind  = 1
	findKind = 3
	byeKind  = 4
)

// Steps of pathfinding between yields.
const chunk = 10

func (ev *Loop) say(text string, n int) { ev.log(cat(text, n)) }

// dialogue is a session's conversation: a coroutine of its own protocol,
// driven directly by its session.
func dialogue(conn int) (*Coroutine[Line, Reply], Reply) {
	return Start(func(yield func(Reply) Line) Reply {
		first := yield(Reply{sayKind, 1000 + conn})
		cmd, arg := first.cmd, first.arg
		for cmd != 9 {
			var line Line
			if cmd == 1 {
				found := yield(Reply{findKind, arg})
				line = yield(Reply{sayKind, 2000000 + found.arg})
			} else {
				line = yield(Reply{sayKind, 3000000 + arg})
			}
			cmd, arg = line.cmd, line.arg
		}
		return Reply{byeKind, conn}
	})
}

// pathfinder is a scheduler task that yields every `chunk` steps and posts
// its result (twice the length) to CH.
func pathfinder(ev *Loop, n int, ch Reg) (*Task, int) {
	return Start(func(y Suspend) int {
		for i := 0; i < n; i++ {
			if i%chunk == 0 {
				ev.yieldNow(y)
			}
		}
		ev.post(ch, n*2, 0)
		return n
	})
}

// pathfind spawns a pathfinder and waits (suspending the calling task Y) for
// its result.
func pathfind(ev *Loop, y Suspend, n int) int {
	ch := ev.channel(1)
	step, first := pathfinder(ev, n, ch)
	ev.adopt(step, first)
	e := ev.wait(y, ch)
	ev.revoke(ch)
	return e.a
}

func session(ev *Loop, net *Sim, conn int, reg, outbox Reg) (*Task, int) {
	return Start(func(y Suspend) int {
		// lines handled, the largest and the total `now - arg` of TALK lines
		handled, maxLag, totalLag := 0, 0, 0
		talk, first := dialogue(conn)
		defer talk.Release()
		ev.post(outbox, conn, first.value)
		for {
			e := ev.wait(y, reg)
			if e.reason != wokeEvent {
				break
			}
			handled++
			if e.a == 2 {
				lag := ev.now - e.b
				if lag > maxLag {
					maxLag = lag
				}
				totalLag += lag
			}
			if ev.tracing {
				ev.say(cat("conn ", conn)+cat(" cmd ", e.a)+" in turn ", ev.turn)
			}
			reply := talk.Resume(Line{e.a, e.b})
			final := reply
			if reply.kind == findKind {
				found := pathfind(ev, y, reply.value)
				ev.say(cat("conn ", conn)+" path found in turn ", ev.turn)
				final = talk.Resume(Line{100, found})
			}
			if final.kind == byeKind {
				break
			}
			ev.post(outbox, conn, final.value)
			// Demand-driven reading (backpressure).
			net.ack(conn)
		}
		net.hangup(conn)
		ev.revoke(reg)
		ev.say(cat("conn ", conn)+" closed in turn ", ev.turn)
		ev.say(cat("conn ", conn)+" lines ", handled)
		ev.say(cat("conn ", conn)+" max lag us ", maxLag)
		ev.say(cat("conn ", conn)+" total lag us ", totalLag)
		return handled
	})
}

func acceptor(ev *Loop, net *Sim, listener, outbox Reg, max int) (*Task, int) {
	return Start(func(y Suspend) int {
		for i := 0; i < max; i++ {
			e := ev.wait(y, listener)
			if e.reason != wokeEvent {
				break
			}
			conn := e.a
			reg := ev.source(true, 16)
			net.attach(conn, reg.slot, reg.gen)
			step, first := session(ev, net, conn, reg, outbox)
			ev.adopt(step, first)
		}
		ev.revoke(listener)
		return max
	})
}

// flusher is the once-per-turn output flush: everything the sessions posted
// this turn, sent in one batch.
func flusher(ev *Loop, net *Sim, outbox Reg) (*Task, int) {
	return Start(func(y Suspend) int {
		obs := ev.observer()
		total := 0
		for {
			t := ev.wait(y, obs)
			if t.reason != wokeTurn {
				break
			}
			count := 0
			for {
				m := ev.tryTake(outbox)
				if m.reason != wokeEvent {
					break
				}
				net.send(m.a, m.b)
				count++
			}
			if count > 0 {
				ev.say(cat("flush ", count)+" in turn ", t.a)
				total += count
			}
		}
		return total
	})
}

// agent is an AI agent: its own protocol, advanced one step per world tick.
func agent() (*Coroutine[Tick, Move], Move) {
	return Start(func(yield func(Move) Tick) Move {
		pos := 0
		for {
			x := pos
			tick := yield(Move{x})
			pos = x + tick.n
		}
	})
}

func world(ev *Loop, period, ticks int) (*Task, int) {
	return Start(func(y Suspend) int {
		clock := ev.every(period)
		ai, first := agent()
		defer ai.Release()
		pos := first.x
		for k := 0; k < ticks; k++ {
			e := ev.wait(y, clock)
			m := ai.Resume(Tick{1 + e.a})
			pos = m.x
			ev.say("world tick, agent at ", m.x)
		}
		ev.revoke(clock)
		return pos
	})
}

// ---------------------------------------------------------------------------
// The program (game-server.bot)

const (
	conns  = 12
	lines  = 18
	period = 25
	ticks  = 12
)

// checksum is a fold of VALUES that depends on their order.
func checksum(values []int) int {
	h := 7
	for _, v := range values {
		h = (h*31 + v + 2) % 1000000007
	}
	return h
}

func script(ev *Loop, d *Sim) {
	listener := ev.source(true, conns+4)
	for c := 1; c <= conns; c++ {
		d.inject(4+c, listener.slot, listener.gen, c, 0)
		spacing := 3 + c%3
		for k := 0; k < lines; k++ {
			if k%4 == 1 {
				d.line(c, 1+k*spacing, 1, 10*(1+(c+k)%5))
			} else {
				d.line(c, 1+k*spacing, 2, c*100+k)
			}
		}
		d.line(c, 6+lines*spacing, 9, 0)
	}
	outbox := ev.channel(4096)
	a, af := acceptor(ev, d, listener, outbox, conns)
	ev.adopt(a, af)
	f, ff := flusher(ev, d, outbox)
	ev.adopt(f, ff)
	w, wf := world(ev, period, ticks)
	ev.adopt(w, wf)
}

func runOnce() []int {
	ev := newLoop(8, false)
	d := newSim()
	// The loop still owns the tasks waiting when it ran out of work (the
	// flusher): release them, as the end of a Botlish run does.
	defer ev.abandon()
	script(ev, d)
	turns, err := ev.run(d)
	if err != nil {
		return []int{-2}
	}
	chars := 0
	for _, line := range ev.trace {
		chars += utf8.RuneCountInString(line)
	}
	return []int{turns, ev.dispatched, ev.completed, ev.observed, ev.stale, len(d.sent), checksum(d.sent), checksum(ev.results), len(ev.trace), chars}
}

func show(values []int) string {
	parts := make([]string, len(values))
	for i, v := range values {
		parts[i] = strconv.Itoa(v)
	}
	return "[" + strings.Join(parts, ", ") + "]"
}

func parseArgs() int {
	runs := 5
	for i := 1; i < len(os.Args); i++ {
		if os.Args[i] != "--runs" {
			panic("unexpected argument " + os.Args[i])
		}
		i++
		if i >= len(os.Args) {
			panic("--runs needs a value")
		}
		v, err := strconv.Atoi(os.Args[i])
		if err != nil {
			panic("--runs must be an integer")
		}
		runs = v
	}
	return runs
}

func main() {
	runs := parseArgs()

	value := runOnce()
	best := float64(1<<63 - 1)
	for i := 0; i < runs; i++ {
		t0 := time.Now()
		value = runOnce()
		dt := float64(time.Since(t0)) / float64(time.Microsecond)
		if dt < best {
			best = dt
		}
	}

	fmt.Printf("value: %s\n", show(value))
	fmt.Printf("best_us: %.3f\n", best)
}
