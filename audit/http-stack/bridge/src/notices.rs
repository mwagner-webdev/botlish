//! Notices: how Rust tells a waiting Botlish coroutine that something it
//! waits on changed. A notice names the Rust handle (generation and index)
//! and two scalars; Botlish drains them after each call and posts each to
//! the registration it keeps for that handle's index -- after checking
//! that the handle there is still the notice's (a released and reused
//! index is stale). Rust never touches the scheduler.

use crate::stats::{self, Counter};
use std::cell::RefCell;
use std::collections::VecDeque;

#[derive(Clone, Copy, Debug)]
pub struct Notice {
    pub handle: i64,
    pub a: i64,
    pub b: i64,
}

thread_local! {
    static QUEUE: RefCell<VecDeque<Notice>> = const { RefCell::new(VecDeque::new()) };
    static CURRENT: RefCell<Option<Notice>> = const { RefCell::new(None) };
}

pub fn notify(handle: i64, a: i64, b: i64) {
    stats::bump(Counter::Notices);
    crate::exec::kick();
    let _ = QUEUE.try_with(|q| q.borrow_mut().push_back(Notice { handle, a, b }));
}

/// The next notice's handle (it becomes current), or -1.
pub fn take() -> i64 {
    let n = QUEUE.with(|q| q.borrow_mut().pop_front());
    CURRENT.with(|c| *c.borrow_mut() = n);
    n.map(|n| n.handle).unwrap_or(-1)
}

pub fn current() -> Option<Notice> {
    CURRENT.with(|c| *c.borrow())
}

pub fn pending() -> usize {
    QUEUE.with(|q| q.borrow().len())
}

pub fn reset() {
    QUEUE.with(|q| q.borrow_mut().clear());
    CURRENT.with(|c| *c.borrow_mut() = None);
}
