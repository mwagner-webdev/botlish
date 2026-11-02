//! Sockets and the executor fixtures the census's scheduling tests use:
//! a self-waking spinner (bounded progress and its negative control), a
//! future a foreign thread completes (the cross-thread wake and its lost-
//! wake control), a bridge sleep (Botlish-clock timers), and panics
//! inside a task and inside a call (containment).

use hs_bridge::ffi::{guard, ERR_STALE};
use hs_bridge::notices::notify;
use hs_bridge::slab::Slab;
use hs_bridge::time::Sleep;
use hs_bridge::{exec, TaskKey};
use std::cell::RefCell;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::task::{Poll, Waker};

pub const K_DONE: i64 = 7;

struct Fixture {
    task: TaskKey,
    done: Arc<Mutex<i64>>,
}

thread_local! {
    static FIXTURES: RefCell<Slab<Fixture>> = RefCell::new(Slab::default());
}

// Fixture handles live in their own table; to keep one handle namespace
// with hs_hyper's objects, they are offset by this many generations.
const TAG: i64 = 1 << 62;

pub fn live(h: i64) -> bool {
    h & TAG != 0 && FIXTURES.with(|f| f.borrow().get(h & !TAG).is_some())
}

pub fn release(h: i64) -> i64 {
    match FIXTURES.with(|f| f.borrow_mut().remove(h & !TAG)) {
        Some(x) => {
            exec::cancel(x.task);
            0
        }
        None => ERR_STALE,
    }
}

pub fn reset() {
    let all = FIXTURES.with(|f| std::mem::take(&mut *f.borrow_mut()));
    drop(all);
}

fn start<F>(make: impl FnOnce(i64, Arc<Mutex<i64>>) -> F) -> i64
where
    F: std::future::Future<Output = ()> + 'static,
{
    let done = Arc::new(Mutex::new(0));
    let h = FIXTURES.with(|f| f.borrow_mut().insert(Fixture { task: 0, done: done.clone() })) | TAG;
    let task = exec::spawn("fixture", make(h, done));
    FIXTURES.with(|f| {
        if let Some(x) = f.borrow_mut().get_mut(h & !TAG) {
            x.task = task
        }
    });
    h
}

/// A fixture's result: 0 while it runs.
#[no_mangle]
pub extern "C" fn hs_fixture_result(h: i64) -> i64 {
    guard(|| FIXTURES.with(|f| f.borrow().get(h & !TAG).map(|x| *x.done.lock().unwrap()).unwrap_or(ERR_STALE)))
}

/// A future that wakes itself N times (a protocol task with much ready
/// work), then completes with N.
#[no_mangle]
pub extern "C" fn hs_fx_spinner(n: i64) -> i64 {
    guard(|| {
        start(move |h, done| async move {
            for _ in 0..n {
                exec::yield_once().await;
            }
            *done.lock().unwrap() = n;
            notify(h, K_DONE, n);
        })
    })
}

/// A future completed by another OS thread after DELAY_US microseconds of
/// real time: its wake comes from that thread.
#[no_mangle]
pub extern "C" fn hs_fx_foreign(delay_us: i64) -> i64 {
    guard(|| {
        struct Gate {
            fired: AtomicBool,
            waker: Mutex<Option<Waker>>,
        }
        let gate = Arc::new(Gate { fired: AtomicBool::new(false), waker: Mutex::new(None) });
        let g2 = gate.clone();
        let started = std::time::Instant::now();
        std::thread::spawn(move || {
            std::thread::sleep(std::time::Duration::from_micros(delay_us.max(0) as u64));
            g2.fired.store(true, Ordering::Release);
            if let Some(w) = g2.waker.lock().unwrap().take() {
                w.wake();
            }
        });
        start(move |h, done| async move {
            std::future::poll_fn(|cx| {
                *gate.waker.lock().unwrap() = Some(cx.waker().clone());
                if gate.fired.load(Ordering::Acquire) {
                    Poll::Ready(())
                } else {
                    Poll::Pending
                }
            })
            .await;
            // Microseconds from the thread's start to this poll (latency).
            let us = started.elapsed().as_micros() as i64;
            *done.lock().unwrap() = us.max(1);
            notify(h, K_DONE, us);
        })
    })
}

/// A future that sleeps DELAY_US of the Botlish clock, then completes with
/// the Botlish time it woke at.
#[no_mangle]
pub extern "C" fn hs_fx_sleep(delay_us: i64) -> i64 {
    guard(|| {
        start(move |h, done| async move {
            Sleep::after(std::time::Duration::from_micros(delay_us.max(0) as u64)).await;
            let now = hs_bridge::time::now() as i64;
            *done.lock().unwrap() = now.max(1);
            notify(h, K_DONE, now);
        })
    })
}

/// A task that panics when polled (contained: counted, dropped).
#[no_mangle]
pub extern "C" fn hs_fx_panic_task() -> i64 {
    guard(|| {
        start(|_, _| async {
            panic!("census: a panicking task");
        })
    })
}

/// A call that panics (contained: ERR_PANIC, nothing unwinds into C).
#[no_mangle]
pub extern "C" fn hs_fx_panic_call() -> i64 {
    guard(|| panic!("census: a panicking call"))
}

/// A call from a thread that is not the loop's: ERR_WRONG_THREAD.
#[no_mangle]
pub extern "C" fn hs_fx_wrong_thread() -> i64 {
    guard(|| std::thread::spawn(|| crate::hs_tasks()).join().unwrap_or(-1))
}

pub fn socket(kind: i32, port: u16, listen: bool, connect: bool) -> i64 {
    unsafe {
        let fd = libc::socket(libc::AF_INET, kind | libc::SOCK_NONBLOCK | libc::SOCK_CLOEXEC, 0);
        if fd < 0 {
            return -(std::io::Error::last_os_error().raw_os_error().unwrap_or(5) as i64);
        }
        let one: i32 = 1;
        libc::setsockopt(fd, libc::SOL_SOCKET, libc::SO_REUSEADDR, (&one as *const i32).cast(), 4);
        let mut addr: libc::sockaddr_in = std::mem::zeroed();
        addr.sin_family = libc::AF_INET as u16;
        addr.sin_port = port.to_be();
        addr.sin_addr.s_addr = u32::from_ne_bytes([127, 0, 0, 1]);
        let p = (&addr as *const libc::sockaddr_in).cast();
        let len = std::mem::size_of::<libc::sockaddr_in>() as u32;
        let r = if connect { libc::connect(fd, p, len) } else { libc::bind(fd, p, len) };
        if r < 0 {
            let e = std::io::Error::last_os_error();
            if !(connect && e.raw_os_error() == Some(libc::EINPROGRESS)) {
                libc::close(fd);
                return -(e.raw_os_error().unwrap_or(5) as i64);
            }
        }
        if listen && libc::listen(fd, 128) < 0 {
            let e = std::io::Error::last_os_error();
            libc::close(fd);
            return -(e.raw_os_error().unwrap_or(5) as i64);
        }
        if kind == libc::SOCK_STREAM && !listen {
            libc::setsockopt(fd, libc::IPPROTO_TCP, libc::TCP_NODELAY, (&one as *const i32).cast(), 4);
        }
        fd as i64
    }
}

pub fn local_port(fd: i32) -> i64 {
    unsafe {
        let mut addr: libc::sockaddr_in = std::mem::zeroed();
        let mut len = std::mem::size_of::<libc::sockaddr_in>() as u32;
        if libc::getsockname(fd, (&mut addr as *mut libc::sockaddr_in).cast(), &mut len) < 0 {
            return -(std::io::Error::last_os_error().raw_os_error().unwrap_or(5) as i64);
        }
        u16::from_be(addr.sin_port) as i64
    }
}

/// Shrink FD's kernel buffers (bytes; a slow-consumer test makes the
/// socket's own buffering small, so Hyper's and the peer's show).
#[no_mangle]
pub extern "C" fn hs_sock_buffers(fd: i64, bytes: i64) -> i64 {
    guard(|| unsafe {
        let v = bytes as i32;
        libc::setsockopt(fd as i32, libc::SOL_SOCKET, libc::SO_RCVBUF, (&v as *const i32).cast(), 4);
        libc::setsockopt(fd as i32, libc::SOL_SOCKET, libc::SO_SNDBUF, (&v as *const i32).cast(), 4);
        0
    })
}

/// The process's resident set (kilobytes), for the stalled-consumer test.
#[no_mangle]
pub extern "C" fn hs_rss_kb() -> i64 {
    guard_rss()
}

fn guard_rss() -> i64 {
    std::fs::read_to_string("/proc/self/statm")
        .ok()
        .and_then(|s| s.split_whitespace().nth(1).and_then(|x| x.parse::<i64>().ok()))
        .map(|pages| pages * 4)
        .unwrap_or(-1)
}

/// The accidental-Tokio control: a bridge task that calls tokio::spawn, as
/// a library written for a Tokio runtime would. No Tokio runtime exists
/// (none is ever started), so Tokio panics; the panic is contained (the
/// task is dropped and counted) and nothing else is affected.
#[cfg(feature = "tokio-control")]
#[no_mangle]
pub extern "C" fn hs_fx_tokio_spawn() -> i64 {
    guard(|| {
        start(|h, done| async move {
            let _ = tokio::spawn(async {});
            *done.lock().unwrap() = 1;
            notify(h, K_DONE, 1);
        })
    })
}
