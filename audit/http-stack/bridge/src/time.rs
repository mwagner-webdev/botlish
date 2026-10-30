//! Rust timers in the Botlish driver's clock.
//!
//! The clock is what Botlish passes in (`set_now`, from
//! `std::event_loop::now()`: the driver's monotonic microseconds, virtual
//! under the deterministic driver). Nothing here reads a system clock:
//! a `Sleep` is due when the Botlish clock reaches its deadline, and the
//! earliest pending deadline is what a Botlish timer registration waits
//! for (`next_deadline`), after which Botlish calls `fire`.
//!
//! Libraries that think in `std::time::Instant` (Hyper's `Timer`) see the
//! Botlish clock through `instant_of`/`micros_of`: an Instant is BASE plus
//! the Botlish microseconds, BASE an Instant fixed when the bridge opened.
//! Only differences of such Instants are meaningful, which is all Hyper
//! asks of them. quiche, which reads `Instant::now()` itself, is the
//! exception the census records: its deadlines are converted from the
//! Durations it reports, and a timer may fire early by the skew between
//! the two readings (counted as `TimersEarly`).

use crate::stats::{self, Counter};
use std::cell::{Cell, RefCell};
use std::cmp::Reverse;
use std::collections::{BinaryHeap, HashMap};
use std::future::Future;
use std::pin::Pin;
use std::sync::OnceLock;
use std::task::{Context, Poll, Waker};
use std::time::{Duration, Instant};

thread_local! {
    static NOW: Cell<u64> = const { Cell::new(0) };
    static SET_AT: Cell<Option<Instant>> = const { Cell::new(None) };
    static TIMERS: RefCell<Timers> = RefCell::new(Timers::default());
}

static BASE: OnceLock<Instant> = OnceLock::new();

#[derive(Default)]
struct Timers {
    heap: BinaryHeap<Reverse<(u64, u64)>>,
    entries: HashMap<u64, Entry>,
    next_id: u64,
}

struct Entry {
    deadline: u64,
    waker: Option<Waker>,
}

pub fn set_now(us: u64) {
    NOW.with(|n| {
        // The driver's clock is monotonic; a smaller value is ignored.
        if us > n.get() {
            n.set(us)
        }
    });
    SET_AT.with(|s| s.set(Some(Instant::now())));
}

/// The Botlish clock now, extrapolated from the last reading Botlish
/// passed in by the real time elapsed since: for converting a library's
/// "in D from now", which that library measured just now. Under the
/// deterministic driver nothing calls it (virtual time has no elapsed
/// real time worth adding, and the in-memory probes have no such library).
pub fn fresh_now() -> u64 {
    let base = now();
    let elapsed = SET_AT.with(|s| s.get()).map(|t| t.elapsed().as_micros() as u64).unwrap_or(0);
    base.saturating_add(elapsed)
}

pub fn now() -> u64 {
    NOW.with(|n| n.get())
}

pub fn reset() {
    NOW.with(|n| n.set(0));
    TIMERS.with(|t| *t.borrow_mut() = Timers::default());
}

fn base() -> Instant {
    *BASE.get_or_init(Instant::now)
}

pub fn instant_of(us: u64) -> Instant {
    base() + Duration::from_micros(us)
}

pub fn micros_of(i: Instant) -> u64 {
    i.saturating_duration_since(base()).as_micros() as u64
}

/// Microseconds of D, rounded up: a deadline is never earlier than asked.
pub fn ceil_micros(d: Duration) -> u64 {
    let n = d.as_nanos();
    n.div_ceil(1000) as u64
}

/// The earliest pending deadline, or None.
pub fn next_deadline() -> Option<u64> {
    TIMERS.with(|t| {
        let mut t = t.borrow_mut();
        loop {
            let Reverse((deadline, id)) = *t.heap.peek()?;
            match t.entries.get(&id) {
                Some(e) if e.deadline == deadline => return Some(deadline),
                _ => {
                    t.heap.pop();
                }
            }
        }
    })
}

pub fn pending() -> usize {
    TIMERS.with(|t| t.borrow().entries.len())
}

/// Wake every timer due at NOW. Returns how many fired.
pub fn fire(now_us: u64) -> usize {
    set_now(now_us);
    let mut wakers = Vec::new();
    TIMERS.with(|t| {
        let mut t = t.borrow_mut();
        while let Some(&Reverse((deadline, id))) = t.heap.peek() {
            if deadline > now_us {
                break;
            }
            t.heap.pop();
            if let Some(e) = t.entries.get_mut(&id) {
                if e.deadline == deadline {
                    if let Some(w) = e.waker.take() {
                        wakers.push(w);
                    }
                }
            }
        }
    });
    let n = wakers.len();
    stats::add(Counter::TimersFired, n as u64);
    for w in wakers {
        w.wake();
    }
    n
}

/// A future ready when the Botlish clock reaches its deadline. Send and
/// Sync (Hyper requires it of a Sleep); it is only ever polled on the
/// loop thread, where its entry lives.
pub struct Sleep {
    id: u64,
    deadline: u64,
}

impl Sleep {
    pub fn until(deadline: u64) -> Sleep {
        let id = TIMERS.with(|t| {
            let mut t = t.borrow_mut();
            t.next_id += 1;
            t.next_id
        });
        Sleep { id, deadline }
    }

    pub fn after(delay: Duration) -> Sleep {
        Sleep::until(now().saturating_add(ceil_micros(delay)))
    }

    pub fn deadline(&self) -> u64 {
        self.deadline
    }

    pub fn reset(&mut self, deadline: u64) {
        self.deadline = deadline;
        TIMERS.with(|t| {
            let mut t = t.borrow_mut();
            if let Some(e) = t.entries.get_mut(&self.id) {
                e.deadline = deadline;
                t.heap.push(Reverse((deadline, self.id)));
            }
        });
    }
}

impl Future for Sleep {
    type Output = ();

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        if now() >= self.deadline {
            TIMERS.with(|t| t.borrow_mut().entries.remove(&self.id));
            return Poll::Ready(());
        }
        let (id, deadline) = (self.id, self.deadline);
        TIMERS.with(|t| {
            let mut t = t.borrow_mut();
            match t.entries.get_mut(&id) {
                Some(e) if e.deadline == deadline => {
                    if !e.waker.as_ref().is_some_and(|w| w.will_wake(cx.waker())) {
                        e.waker = Some(cx.waker().clone());
                    }
                }
                _ => {
                    t.entries.insert(id, Entry { deadline, waker: Some(cx.waker().clone()) });
                    t.heap.push(Reverse((deadline, id)));
                }
            }
        });
        Poll::Pending
    }
}

impl Drop for Sleep {
    fn drop(&mut self) {
        let _ = TIMERS.try_with(|t| {
            if let Ok(mut t) = t.try_borrow_mut() {
                t.entries.remove(&self.id);
            }
        });
    }
}
