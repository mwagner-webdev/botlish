//! Readiness without a poller of Rust's own.
//!
//! A Rust I/O object makes nonblocking system calls on a descriptor
//! Botlish handed it. When one would block it parks its waker here
//! (`park`) and the descriptor's wanted interest grows; Botlish asks for
//! the changes after each call (`next_interest`) and arms its own watch
//! (event_loop_linux::watch / rearm: EPOLLONESHOT). When the watch fires,
//! Botlish reports the readiness bits (`ready`): the watch is spent, the
//! wakers of the directions it covers are woken, and an interest still
//! wanted is asked for again.
//!
//! Descriptors are Botlish's to close: a Rust object that is done with
//! one calls `release`, which queues it; Botlish receives it from
//! `next_interest` as interest CLOSE, unwatches it, and then calls
//! `close_fd`. So a watch never outlives its descriptor and a reused
//! descriptor number never inherits a watch -- the package's rule
//! (unwatch before close), which a Rust destructor could not keep: the
//! watch is Botlish state.

use crate::stats::{self, Counter};
use std::cell::RefCell;
use std::collections::{HashMap, VecDeque};
use std::task::Waker;

pub const READ: u8 = 1;
pub const WRITE: u8 = 2;
/// next_interest's interest for a descriptor to unwatch and close.
pub const CLOSE: u8 = 4;

/// Readiness bits as event_loop_linux reports them.
pub const BIT_READABLE: i64 = 1;
pub const BIT_WRITABLE: i64 = 2;
pub const BIT_HANGUP: i64 = 4;
pub const BIT_ERROR: i64 = 8;

#[derive(Default)]
struct Fd {
    want: u8,
    armed: u8,
    read: Option<Waker>,
    write: Option<Waker>,
    queued: bool,
}

#[derive(Default)]
struct Registry {
    fds: HashMap<i32, Fd>,
    changes: VecDeque<i32>,
    closing: VecDeque<i32>,
}

thread_local! {
    static IO: RefCell<Registry> = RefCell::new(Registry::default());
}

pub fn reset() {
    IO.with(|r| *r.borrow_mut() = Registry::default());
}

/// Park W until FD is ready for DIR (READ or WRITE).
pub fn park(fd: i32, dir: u8, w: &Waker) {
    IO.with(|r| {
        let mut r = r.borrow_mut();
        let r = &mut *r;
        let e = r.fds.entry(fd).or_default();
        let slot = if dir == READ { &mut e.read } else { &mut e.write };
        if !slot.as_ref().is_some_and(|x| x.will_wake(w)) {
            *slot = Some(w.clone());
        }
        e.want |= dir;
        if e.armed & dir == 0 && !e.queued {
            e.queued = true;
            r.changes.push_back(fd);
            crate::exec::kick();
        }
    })
}

/// The next (fd, interest) Botlish should arm: READ|WRITE as wanted, or
/// CLOSE for a released descriptor. None when nothing changed.
pub fn next_interest() -> Option<(i32, u8)> {
    IO.with(|r| {
        let mut r = r.borrow_mut();
        if let Some(fd) = r.closing.pop_front() {
            stats::bump(Counter::InterestRequests);
            return Some((fd, CLOSE));
        }
        while let Some(fd) = r.changes.pop_front() {
            if let Some(e) = r.fds.get_mut(&fd) {
                e.queued = false;
                if e.want != 0 && e.want != e.armed {
                    e.armed = e.want;
                    stats::bump(Counter::InterestRequests);
                    return Some((fd, e.want));
                }
            }
        }
        None
    })
}

/// Botlish's watch of FD fired with BITS: wake the directions covered.
pub fn ready(fd: i32, bits: i64) -> usize {
    stats::bump(Counter::Readiness);
    let mut wake = Vec::new();
    IO.with(|r| {
        let mut r = r.borrow_mut();
        let r = &mut *r;
        let Some(e) = r.fds.get_mut(&fd) else { return };
        // EPOLLONESHOT: one report disarms the whole watch.
        e.armed = 0;
        let fault = bits & (BIT_HANGUP | BIT_ERROR) != 0;
        if bits & BIT_READABLE != 0 || fault {
            e.want &= !READ;
            wake.extend(e.read.take());
        }
        if bits & BIT_WRITABLE != 0 || fault {
            e.want &= !WRITE;
            wake.extend(e.write.take());
        }
        if e.want != 0 && !e.queued {
            e.queued = true;
            r.changes.push_back(fd);
        }
    });
    let n = wake.len();
    for w in wake {
        w.wake();
    }
    n
}

/// A Rust object is done with FD: Botlish unwatches and closes it.
pub fn release(fd: i32) {
    let _ = IO.try_with(|r| {
        if let Ok(mut r) = r.try_borrow_mut() {
            r.fds.remove(&fd);
            r.closing.push_back(fd);
            crate::exec::kick();
        }
    });
}

/// Botlish closes FD (after unwatching it).
pub fn close_fd(fd: i32) -> i64 {
    if unsafe { libc::close(fd) } == 0 {
        0
    } else {
        -(std::io::Error::last_os_error().raw_os_error().unwrap_or(5) as i64)
    }
}

pub fn watched() -> usize {
    IO.with(|r| r.borrow().fds.len())
}

/// Nonblocking read/write/recv helpers: Ok(n), or Err(WouldBlock) after
/// parking the waker.
pub fn read(fd: i32, buf: &mut [u8], w: &Waker) -> std::io::Result<usize> {
    loop {
        let n = unsafe { libc::read(fd, buf.as_mut_ptr().cast(), buf.len()) };
        if n >= 0 {
            return Ok(n as usize);
        }
        let e = std::io::Error::last_os_error();
        match e.kind() {
            std::io::ErrorKind::Interrupted => continue,
            std::io::ErrorKind::WouldBlock => {
                park(fd, READ, w);
                return Err(e);
            }
            _ => return Err(e),
        }
    }
}

pub fn write(fd: i32, buf: &[u8], w: &Waker) -> std::io::Result<usize> {
    loop {
        let n = unsafe { libc::send(fd, buf.as_ptr().cast(), buf.len(), libc::MSG_NOSIGNAL) };
        if n >= 0 {
            return Ok(n as usize);
        }
        let e = std::io::Error::last_os_error();
        match e.kind() {
            std::io::ErrorKind::Interrupted => continue,
            std::io::ErrorKind::WouldBlock => {
                park(fd, WRITE, w);
                return Err(e);
            }
            _ => return Err(e),
        }
    }
}
