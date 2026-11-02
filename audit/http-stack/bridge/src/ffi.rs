//! The guard every C export runs its body in.
//!
//! * Panics never unwind across the C ABI: a panic becomes ERR_PANIC.
//! * Calls come from the loop thread only (the executor's): any other
//!   thread gets ERR_WRONG_THREAD before anything is touched.
//! * No reentry: a call made while one runs is ERR_REENTRANT. (Rust never
//!   calls Botlish, so this cannot happen through the bridge; the check
//!   makes the claim observable instead of assumed.)
//! * While a call runs, wakes on the loop thread only enqueue (`exec`).

use crate::exec;
use crate::stats::{self, Counter};
use std::cell::Cell;
use std::panic::{catch_unwind, AssertUnwindSafe};

pub const ERR_PANIC: i64 = -90001;
pub const ERR_WRONG_THREAD: i64 = -90002;
pub const ERR_REENTRANT: i64 = -90003;
pub const ERR_STALE: i64 = -90004;
pub const ERR_NOT_OPEN: i64 = -90005;
pub const ERR_PROTOCOL: i64 = -90006;
pub const ERR_TLS: i64 = -90007;
pub const ERR_CANCELLED: i64 = -90008;

thread_local! {
    static ACTIVE: Cell<bool> = const { Cell::new(false) };
}

/// The thread the bridge was opened on (process-wide: a call from another
/// thread is told so, rather than finding no bridge of its own).
static OWNER: std::sync::Mutex<Option<std::thread::ThreadId>> = std::sync::Mutex::new(None);

pub fn set_owner() {
    *OWNER.lock().unwrap() = Some(std::thread::current().id());
}

/// Run F as one C call. OPEN: whether F requires an open bridge.
pub fn guard_with<F: FnOnce() -> i64>(open: bool, f: F) -> i64 {
    if open {
        match exec::loop_thread() {
            None if OWNER.lock().unwrap().is_some_and(|t| t != std::thread::current().id()) => return ERR_WRONG_THREAD,
            None => return ERR_NOT_OPEN,
            Some(t) if t != std::thread::current().id() => return ERR_WRONG_THREAD,
            _ => {}
        }
    }
    if ACTIVE.with(|a| a.replace(true)) {
        return ERR_REENTRANT;
    }
    stats::bump(Counter::Calls);
    let prev = exec::set_in_call(true);
    let started = std::time::Instant::now();
    let r = catch_unwind(AssertUnwindSafe(f));
    stats::max(Counter::MaxCallUs, started.elapsed().as_micros() as u64);
    exec::set_in_call(prev);
    ACTIVE.with(|a| a.set(false));
    match r {
        Ok(v) => v,
        Err(_) => {
            stats::bump(Counter::Panics);
            ERR_PANIC
        }
    }
}

pub fn guard<F: FnOnce() -> i64>(f: F) -> i64 {
    guard_with(true, f)
}

/// Copy SRC into the C buffer DST of CAP bytes; the count copied.
///
/// # Safety
/// DST must be valid for CAP bytes of writes (a Botlish write exposure:
/// C-POINTER-BORROWING.md, valid for this call only).
pub unsafe fn copy_out(src: &[u8], dst: *mut u8, cap: usize) -> usize {
    let n = src.len().min(cap);
    if n > 0 && !dst.is_null() {
        std::ptr::copy_nonoverlapping(src.as_ptr(), dst, n);
    }
    stats::add(Counter::BytesCopiedOut, n as u64);
    n
}

/// # Safety
/// SRC must be valid for LEN bytes of reads for this call only.
pub unsafe fn copy_in(src: *const u8, len: usize) -> Vec<u8> {
    stats::add(Counter::BytesCopiedIn, len as u64);
    if len == 0 || src.is_null() {
        return Vec::new();
    }
    std::slice::from_raw_parts(src, len).to_vec()
}
