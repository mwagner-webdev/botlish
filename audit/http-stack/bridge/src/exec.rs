//! The bounded executor. Thread-local to the thread that opened it (the
//! Botlish loop's), polled only by `run`, which a Botlish task calls.
//!
//! The turn rule mirrors the Botlish scheduler's dispatch phase: `run`
//! polls exactly the tasks that were ready when it started (at most
//! BUDGET of them), each once, in the order they became ready; a task woken
//! during the run -- by itself or another -- is polled by a later run. A
//! task is queued at most once (its `queued` flag), so duplicate wakes cost
//! nothing, and a wake of a task that ended or was cancelled is recognized
//! by its generation and dropped.
//!
//! Wakes: on the loop thread inside a call they only enqueue (Botlish asks
//! `run`'s result, the ready count, after the call). Anywhere else -- a
//! foreign thread -- they enqueue under the inbox mutex and, when the inbox
//! goes from empty to non-empty, post one record to the registration
//! Botlish configured (`set_notify`), through the integration ABI. The
//! record is collected by the loop in a later turn; no Botlish code runs
//! on the waking thread.

use crate::stats::{self, Counter};
use std::cell::{Cell, RefCell};
use std::collections::VecDeque;
use std::future::Future;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::pin::Pin;
use std::sync::atomic::{AtomicBool, AtomicI64, AtomicU32, Ordering};
use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Wake, Waker};
use std::thread::ThreadId;

pub type TaskKey = u64;

/// Fault injection for the census's negative controls (`set_fault`).
pub const FAULT_LOST_FOREIGN_WAKE: u32 = 1; // a foreign wake enqueues but never posts
pub const FAULT_UNBOUNDED_RUN: u32 = 2; // run ignores its budget and its snapshot
pub const FAULT_WAKE_STALE_CHECK: u32 = 4; // run skips the generation check
pub const FAULT_NO_KICK: u32 = 8; // work made ready by an application call never kicks the executor

/// What wakers share across threads.
pub struct Shared {
    inbox: Mutex<Vec<TaskKey>>,
    loop_thread: ThreadId,
    endpoint: AtomicI64,
    slot: AtomicI64,
    generation: AtomicI64,
    fault: AtomicU32,
}

struct TaskCell {
    key: TaskKey,
    queued: AtomicBool,
    shared: Arc<Shared>,
}

thread_local! {
    static IN_CALL: Cell<bool> = const { Cell::new(false) };
    static RUNNING: Cell<bool> = const { Cell::new(false) };
    static KICK: Cell<bool> = const { Cell::new(false) };
}

/// Something the executor must settle (a ready task, a notice, a
/// readiness change) happened outside its own run: an application
/// coroutine's call spawned or woke a task, released an object, ... The
/// Botlish side asks after each such call (`take_kick`) and, when set,
/// posts a wake record to the executor's source -- the executor may be
/// parked on it, and nothing else would wake it.
pub fn kick() {
    if !RUNNING.with(|r| r.get()) {
        KICK.with(|k| k.set(true));
    }
}

pub fn take_kick() -> bool {
    let k = KICK.with(|k| k.replace(false));
    k && fault() & FAULT_NO_KICK == 0
}

pub(crate) fn set_in_call(v: bool) -> bool {
    IN_CALL.with(|c| c.replace(v))
}

impl Wake for TaskCell {
    fn wake(self: Arc<Self>) {
        self.wake_by_ref()
    }

    fn wake_by_ref(self: &Arc<Self>) {
        if self.queued.swap(true, Ordering::AcqRel) {
            if on_loop_thread(&self.shared) {
                stats::bump(Counter::WakesDuplicate);
            }
            return;
        }
        let local = on_loop_thread(&self.shared) && IN_CALL.with(|c| c.get());
        let was_empty = {
            let mut inbox = self.shared.inbox.lock().unwrap();
            let e = inbox.is_empty();
            inbox.push(self.key);
            e
        };
        if local {
            stats::bump(Counter::WakesLocal);
            kick();
            return;
        }
        stats::bump_shared(Counter::WakesForeign);
        if was_empty {
            self.shared.notify();
        }
    }
}

fn on_loop_thread(shared: &Shared) -> bool {
    std::thread::current().id() == shared.loop_thread
}

extern "C" {
    fn hs_notify_post(endpoint: i32, slot: i32, gen: i32, a: i64, b: i64) -> i32;
}

/// The `a` of a wake record (a readiness record's `a` is its bits, > 0).
pub const WAKE_RECORD: i64 = 0;

impl Shared {
    fn notify(&self) {
        if self.fault.load(Ordering::Relaxed) & FAULT_LOST_FOREIGN_WAKE != 0 {
            stats::bump_shared(Counter::ForeignWakesLost);
            return;
        }
        let endpoint = self.endpoint.load(Ordering::Acquire);
        if endpoint < 0 {
            stats::bump_shared(Counter::ForeignRefused);
            return;
        }
        let r = unsafe {
            hs_notify_post(
                endpoint as i32,
                self.slot.load(Ordering::Acquire) as i32,
                self.generation.load(Ordering::Acquire) as i32,
                WAKE_RECORD,
                0,
            )
        };
        // -EAGAIN (the endpoint is full) loses nothing: a full endpoint
        // holds records the loop has yet to collect, and collecting any of
        // them runs the executor task, which drains the whole inbox.
        if r == 0 {
            stats::bump_shared(Counter::ForeignPosts);
        } else {
            stats::bump_shared(Counter::ForeignRefused);
        }
    }
}

struct Task {
    future: Option<Pin<Box<dyn Future<Output = ()>>>>,
    cell: Arc<TaskCell>,
    waker: Waker,
    name: &'static str,
}

struct Exec {
    shared: Arc<Shared>,
    tasks: Vec<(u32, Option<Task>)>,
    free: Vec<u32>,
    ready: VecDeque<TaskKey>,
}

thread_local! {
    static EXEC: RefCell<Option<Exec>> = const { RefCell::new(None) };
}

fn key_of(generation: u32, index: u32) -> TaskKey {
    ((generation as u64) << 32) | index as u64
}

/// Open the executor on this thread (the Botlish loop's).
pub fn open() {
    EXEC.with(|e| {
        *e.borrow_mut() = Some(Exec {
            shared: Arc::new(Shared {
                inbox: Mutex::new(Vec::new()),
                loop_thread: std::thread::current().id(),
                endpoint: AtomicI64::new(-1),
                slot: AtomicI64::new(0),
                generation: AtomicI64::new(0),
                fault: AtomicU32::new(0),
            }),
            tasks: Vec::new(),
            free: Vec::new(),
            ready: VecDeque::new(),
        })
    });
}

pub fn is_open() -> bool {
    EXEC.with(|e| e.borrow().is_some())
}

pub fn loop_thread() -> Option<ThreadId> {
    EXEC.with(|e| e.borrow().as_ref().map(|x| x.shared.loop_thread))
}

/// Close: drop every task (their destructors run here, on the loop thread).
pub fn close() -> usize {
    let tasks = EXEC.with(|e| e.borrow_mut().take().map(|x| x.tasks).unwrap_or_default());
    let n = tasks.iter().filter(|t| t.1.is_some()).count();
    drop(tasks);
    n
}

/// Where a foreign wake posts (the endpoint of the Linux driver and the
/// registration tag Botlish gave), or -1: refuse foreign wakes.
pub fn set_notify(endpoint: i64, slot: i64, generation: i64) {
    EXEC.with(|e| {
        if let Some(x) = e.borrow().as_ref() {
            x.shared.slot.store(slot, Ordering::Release);
            x.shared.generation.store(generation, Ordering::Release);
            x.shared.endpoint.store(endpoint, Ordering::Release);
        }
    })
}

pub fn set_fault(bits: u32) {
    EXEC.with(|e| {
        if let Some(x) = e.borrow().as_ref() {
            x.shared.fault.store(bits, Ordering::Relaxed)
        }
    })
}

pub fn fault() -> u32 {
    EXEC.with(|e| e.borrow().as_ref().map(|x| x.shared.fault.load(Ordering::Relaxed)).unwrap_or(0))
}

/// Spawn a future; it is ready at once (polled by the next run).
pub fn spawn<F: Future<Output = ()> + 'static>(name: &'static str, future: F) -> TaskKey {
    stats::bump(Counter::Spawns);
    let key = EXEC.with(|e| {
        let mut e = e.borrow_mut();
        let x = e.as_mut().expect("hs_bridge: executor not open on this thread");
        let index = match x.free.pop() {
            Some(i) => i,
            None => {
                x.tasks.push((0, None));
                (x.tasks.len() - 1) as u32
            }
        };
        let slot = &mut x.tasks[index as usize];
        slot.0 = slot.0.wrapping_add(1).max(1);
        let key = key_of(slot.0, index);
        let cell = Arc::new(TaskCell { key, queued: AtomicBool::new(true), shared: x.shared.clone() });
        let waker = Waker::from(cell.clone());
        slot.1 = Some(Task { future: Some(Box::pin(future)), cell, waker, name });
        x.ready.push_back(key);
        key
    });
    kick();
    key
}

/// Cancel a task: its future is dropped now (on the loop thread); a later
/// wake of it is stale. False when it already ended.
pub fn cancel(key: TaskKey) -> bool {
    let task = EXEC.with(|e| {
        let mut e = e.borrow_mut();
        let x = e.as_mut()?;
        let index = (key & 0xffff_ffff) as usize;
        let slot = x.tasks.get_mut(index)?;
        if slot.0 as u64 != key >> 32 {
            return None;
        }
        let t = slot.1.take();
        if t.is_some() {
            x.free.push(index as u32);
        }
        t
    });
    let removed = task.is_some();
    if removed {
        stats::bump(Counter::Cancellations);
    }
    // A future being polled right now has no future in its slot; it is
    // dropped by run when its poll returns.
    drop(task);
    removed
}

pub fn live(key: TaskKey) -> bool {
    EXEC.with(|e| {
        let e = e.borrow();
        let Some(x) = e.as_ref() else { return false };
        match x.tasks.get((key & 0xffff_ffff) as usize) {
            Some(slot) => slot.0 as u64 == key >> 32 && slot.1.is_some(),
            None => false,
        }
    })
}

pub fn task_count() -> usize {
    EXEC.with(|e| e.borrow().as_ref().map(|x| x.tasks.iter().filter(|t| t.1.is_some()).count()).unwrap_or(0))
}

fn drain_inbox(x: &mut Exec) {
    let mut inbox = x.shared.inbox.lock().unwrap();
    x.ready.extend(inbox.drain(..));
}

/// Ready tasks now (the inbox included).
pub fn ready_count() -> usize {
    EXEC.with(|e| {
        let mut e = e.borrow_mut();
        let Some(x) = e.as_mut() else { return 0 };
        drain_inbox(x);
        x.ready.len()
    })
}

/// Poll at most BUDGET of the tasks ready when the run starts, each once.
/// Returns how many tasks are ready afterwards.
pub fn run(budget: usize) -> usize {
    stats::bump(Counter::Runs);
    let started = std::time::Instant::now();
    let fault = fault();
    let unbounded = fault & FAULT_UNBOUNDED_RUN != 0;
    let snapshot = EXEC.with(|e| {
        let mut e = e.borrow_mut();
        let x = e.as_mut().expect("hs_bridge: executor not open");
        drain_inbox(x);
        x.ready.len()
    });
    let limit = if unbounded { usize::MAX } else { snapshot.min(budget) };
    let mut polled = 0usize;
    RUNNING.with(|r| r.set(true));
    while polled < limit {
        // Take the next key and its future out of the table, so that the
        // poll can spawn, wake and cancel (each borrows the table).
        let next = EXEC.with(|e| {
            let mut e = e.borrow_mut();
            let x = e.as_mut().unwrap();
            if unbounded {
                drain_inbox(x);
            }
            let key = x.ready.pop_front()?;
            let index = (key & 0xffff_ffff) as usize;
            let current = x.tasks.get_mut(index);
            let Some(slot) = current else { return Some(None) };
            let generation_ok = slot.0 as u64 == key >> 32 || fault & FAULT_WAKE_STALE_CHECK != 0;
            let Some(task) = slot.1.as_mut().filter(|_| generation_ok) else {
                return Some(None);
            };
            task.cell.queued.store(false, Ordering::Release);
            let future = task.future.take()?;
            Some(Some((key, future, task.waker.clone(), task.name)))
        });
        let Some(next) = next else { break };
        let Some((key, mut future, waker, _name)) = next else {
            stats::bump(Counter::WakesStale);
            continue;
        };
        polled += 1;
        stats::bump(Counter::Polls);
        let mut cx = Context::from_waker(&waker);
        let result = catch_unwind(AssertUnwindSafe(|| future.as_mut().poll(&mut cx)));
        let done = match result {
            Ok(Poll::Ready(())) => {
                stats::bump(Counter::Completions);
                true
            }
            Ok(Poll::Pending) => false,
            Err(_) => {
                stats::bump(Counter::Panics);
                true
            }
        };
        let finished = EXEC.with(|e| {
            let mut e = e.borrow_mut();
            let x = e.as_mut().unwrap();
            let index = (key & 0xffff_ffff) as usize;
            let slot = &mut x.tasks[index];
            if slot.0 as u64 != key >> 32 || slot.1.is_none() {
                // Cancelled during its own poll.
                return Some(future);
            }
            if done {
                slot.1 = None;
                x.free.push(index as u32);
                Some(future)
            } else {
                slot.1.as_mut().unwrap().future = Some(future);
                None
            }
        });
        // A finished or cancelled future is dropped outside the borrow.
        drop(finished);
    }
    RUNNING.with(|r| r.set(false));
    // The executor settles everything after this run; what happened
    // during it needs no kick.
    KICK.with(|k| k.set(false));
    stats::max(Counter::MaxPollsPerRun, polled as u64);
    stats::max(Counter::MaxRunUs, started.elapsed().as_micros() as u64);
    let left = ready_count();
    if left > 0 {
        stats::bump(Counter::BudgetExhausted);
    }
    left
}

/// A future that is ready after yielding once: cooperative fairness inside
/// a protocol task that has more work than one poll should do.
pub fn yield_once() -> impl Future<Output = ()> {
    let mut yielded = false;
    std::future::poll_fn(move |cx| {
        if yielded {
            Poll::Ready(())
        } else {
            yielded = true;
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    })
}
