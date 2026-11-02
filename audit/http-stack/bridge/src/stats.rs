//! Counters the census reads (`hs_stat`): what crossed the boundary, how
//! often, and what the executor did. Loop-thread counters are plain cells;
//! the ones a foreign thread may touch are atomics.

use std::cell::Cell;
use std::sync::atomic::{AtomicU64, Ordering};

macro_rules! counters {
    ($($name:ident = $index:expr),* $(,)?) => {
        #[derive(Clone, Copy, Debug)]
        #[repr(i32)]
        pub enum Counter { $($name = $index),* }
        pub const COUNTERS: &[(&str, Counter)] = &[$((stringify!($name), Counter::$name)),*];
    };
}

counters! {
    Calls = 0,          // guarded FFI calls (Botlish -> Rust crossings)
    Runs = 1,           // exec::run calls
    Polls = 2,          // future polls
    Spawns = 3,
    Completions = 4,
    WakesLocal = 5,     // wakes on the loop thread, inside a call
    WakesForeign = 6,   // wakes from another thread (or outside a call)
    WakesDuplicate = 7, // a wake of a task already queued
    WakesStale = 8,     // a wake of a task that no longer exists
    ForeignPosts = 9,   // records posted for foreign wakes
    ForeignRefused = 10,// posts refused (-EAGAIN, -EPIPE, -ENOSYS)
    BudgetExhausted = 11, // runs that left ready work behind
    TimersFired = 12,
    TimersEarly = 13,   // timer wakes that found nothing due (clock skew)
    InterestRequests = 14, // (fd, interest) changes handed to Botlish
    Readiness = 15,     // readiness reports from Botlish
    Notices = 16,
    Panics = 17,
    MaxPollsPerRun = 18,
    BytesCopiedOut = 19, // bytes copied into Botlish-owned storage
    BytesCopiedIn = 20,
    ForeignWakesLost = 21, // fault injection: foreign wakes not posted
    Cancellations = 22,
    MaxCallUs = 23,     // the longest guarded call (microseconds)
    MaxRunUs = 24,      // the longest exec::run
}

thread_local! {
    static LOCAL: [Cell<u64>; 32] = Default::default();
}

static SHARED: [AtomicU64; 32] = [const { AtomicU64::new(0) }; 32];

pub fn bump(c: Counter) {
    add(c, 1);
}

pub fn add(c: Counter, n: u64) {
    LOCAL.with(|l| {
        let cell = &l[c as usize];
        cell.set(cell.get() + n)
    });
}

pub fn max(c: Counter, n: u64) {
    LOCAL.with(|l| {
        let cell = &l[c as usize];
        if n > cell.get() {
            cell.set(n)
        }
    });
}

/// For counters a foreign thread may bump.
pub fn bump_shared(c: Counter) {
    SHARED[c as usize].fetch_add(1, Ordering::Relaxed);
}

pub fn get(i: i32) -> i64 {
    if !(0..32).contains(&i) {
        return -1;
    }
    let local = LOCAL.with(|l| l[i as usize].get());
    (local + SHARED[i as usize].load(Ordering::Relaxed)) as i64
}

pub fn reset() {
    LOCAL.with(|l| l.iter().for_each(|c| c.set(0)));
    SHARED.iter().for_each(|c| c.store(0, Ordering::Relaxed));
}
