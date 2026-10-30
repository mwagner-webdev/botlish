//! hs_native -- the census's one Rust linking unit: a static library whose
//! only global symbols are the `hs_*` C functions below
//! (tools/build.tcl localizes everything else, so its private copy of the
//! Rust standard library never meets the Botlish runtime's). BoringSSL is
//! NOT inside it: tools/build.tcl removes the members boring-sys bundled
//! and the final link takes the one provider's archives.
//!
//! Every function takes and returns C scalars; byte buffers are Botlish
//! exposures valid for one call (C-POINTER-BORROWING.md): `read noescape`
//! for bytes Rust copies in, `write noescape` for bytes Rust copies out.
//! Every body runs in `hs_bridge::guard`: no panic unwinds into Botlish,
//! only the loop thread may call, no call reenters.

#![allow(clippy::missing_safety_doc)]

use hs_bridge::ffi::{guard, guard_with, ERR_STALE};
use hs_bridge::{exec, io, notices, stats, time};

#[cfg(feature = "count-alloc")]
mod alloc;
mod fixtures;
#[cfg(feature = "hyper")]
mod http;
#[cfg(feature = "quiche")]
mod h3;
#[cfg(feature = "tls")]
mod tls;

// ------------------------------------------------------------ lifecycle

/// Open the bridge on this thread (the loop's). 0.
#[no_mangle]
pub extern "C" fn hs_open(_flags: i32) -> i64 {
    guard_with(false, || {
        if exec::is_open() {
            return hs_bridge::ffi::ERR_REENTRANT;
        }
        exec::open();
        hs_bridge::ffi::set_owner();
        time::reset();
        io::reset();
        notices::reset();
        stats::reset();
        // The negative controls select a fault by environment (test-only,
        // like BOTLISH_EVENT_LOOP_FAULT): the same program, a broken bridge.
        if let Some(bits) = std::env::var("HS_CENSUS_FAULT").ok().and_then(|v| v.parse::<u32>().ok()) {
            exec::set_fault(bits);
        }
        0
    })
}

/// 1 when fault BIT is in force.
#[no_mangle]
pub extern "C" fn hs_has_fault(bit: i64) -> i64 {
    guard(|| (exec::fault() as i64 & bit != 0) as i64)
}

/// The fault bits in force (hs_bridge::exec::FAULT_*, hs_quiche's).
#[no_mangle]
pub extern "C" fn hs_fault() -> i64 {
    guard(|| exec::fault() as i64)
}

/// Close the bridge: every object released, every task dropped (on this
/// thread). How many tasks were still live.
#[no_mangle]
pub extern "C" fn hs_close() -> i64 {
    guard(|| {
        #[cfg(feature = "quiche")]
        h3::reset();
        #[cfg(feature = "hyper")]
        hs_hyper::reset();
        #[cfg(feature = "tls")]
        hs_tls::reset();
        fixtures::reset();
        let n = exec::close() as i64;
        notices::reset();
        n
    })
}

/// Where a foreign thread's wake posts: the Linux driver's endpoint id and
/// the registration tag (std::event_loop::native_slot/native_generation).
/// ENDPOINT -1: foreign wakes are refused.
#[no_mangle]
pub extern "C" fn hs_set_notify(endpoint: i64, slot: i64, generation: i64) -> i64 {
    guard(|| {
        exec::set_notify(endpoint, slot, generation);
        0
    })
}

/// Fault injection for the negative controls (hs_bridge::exec::FAULT_*).
#[no_mangle]
pub extern "C" fn hs_set_fault(bits: i64) -> i64 {
    guard(|| {
        exec::set_fault(bits as u32);
        0
    })
}

// ------------------------------------------------------------ scheduling

/// One bounded run at Botlish time NOW: polls at most BUDGET of the tasks
/// ready when it starts. The number ready afterwards.
#[no_mangle]
pub extern "C" fn hs_run(budget: i64, now: i64) -> i64 {
    guard(|| {
        time::set_now(now.max(0) as u64);
        exec::run(budget.max(0) as usize) as i64
    })
}

/// 1 when an application call since the last run left the executor
/// something to settle (exec::kick); the Botlish side then posts a wake
/// record to the executor's source. Clears the flag.
#[no_mangle]
pub extern "C" fn hs_kick() -> i64 {
    guard(|| exec::take_kick() as i64)
}

/// Tasks ready now (no polling).
#[no_mangle]
pub extern "C" fn hs_ready() -> i64 {
    guard(|| exec::ready_count() as i64)
}

/// The earliest Rust deadline (Botlish clock), or -1.
#[no_mangle]
pub extern "C" fn hs_next_deadline() -> i64 {
    guard(|| time::next_deadline().map(|d| d as i64).unwrap_or(-1))
}

/// Fire the Rust timers due at NOW; how many fired.
#[no_mangle]
pub extern "C" fn hs_fire(now: i64) -> i64 {
    guard(|| {
        let n = time::fire(now.max(0) as u64);
        if n == 0 {
            stats::bump(stats::Counter::TimersEarly);
        }
        n as i64
    })
}

#[no_mangle]
pub extern "C" fn hs_tasks() -> i64 {
    guard(|| exec::task_count() as i64)
}

// ------------------------------------------------------------ readiness

/// Botlish's watch of FD reported BITS (event_loop_linux: 1 readable,
/// 2 writable, 4 hang-up, 8 error). Wakers woken.
#[no_mangle]
pub extern "C" fn hs_io_ready(fd: i64, bits: i64) -> i64 {
    guard(|| io::ready(fd as i32, bits) as i64)
}

thread_local! {
    static INTEREST: std::cell::Cell<i64> = const { std::cell::Cell::new(0) };
}

/// The descriptor of the next readiness change Botlish must make, or -1;
/// hs_interest() then says which: 1 read, 2 write, 3 both, 4 unwatch and
/// close. Also after hs_close (the closed objects' descriptors).
#[no_mangle]
pub extern "C" fn hs_next_interest() -> i64 {
    guard_with(false, || match io::next_interest() {
        Some((fd, interest)) => {
            INTEREST.with(|i| i.set(interest as i64));
            fd as i64
        }
        None => -1,
    })
}

#[no_mangle]
pub extern "C" fn hs_interest() -> i64 {
    guard_with(false, || INTEREST.with(|i| i.get()))
}

/// Close FD (Botlish unwatched it first).
#[no_mangle]
pub extern "C" fn hs_close_fd(fd: i64) -> i64 {
    guard_with(false, || io::close_fd(fd as i32))
}

// ------------------------------------------------------------ notices

/// The next notice's handle (it becomes current), or -1.
#[no_mangle]
pub extern "C" fn hs_take_notice() -> i64 {
    guard(notices::take)
}

#[no_mangle]
pub extern "C" fn hs_notice_a() -> i64 {
    guard(|| notices::current().map(|n| n.a).unwrap_or(0))
}

#[no_mangle]
pub extern "C" fn hs_notice_b() -> i64 {
    guard(|| notices::current().map(|n| n.b).unwrap_or(0))
}

// ------------------------------------------------------------ counters

#[no_mangle]
pub extern "C" fn hs_stat(i: i64) -> i64 {
    guard_with(false, || stats::get(i as i32))
}

#[no_mangle]
pub extern "C" fn hs_stats_reset() -> i64 {
    guard_with(false, || {
        stats::reset();
        0
    })
}

/// Release any handle (an HTTP client, server, connection or exchange; a
/// QUIC endpoint or stream; a fixture). ERR_STALE when it is not live.
#[no_mangle]
pub extern "C" fn hs_release(h: i64) -> i64 {
    guard(|| {
        #[cfg(feature = "hyper")]
        if hs_hyper::with(h, |_| ()).is_some() {
            return hs_hyper::release(h);
        }
        #[cfg(feature = "quiche")]
        if h3::live(h) {
            return h3::release(h);
        }
        #[cfg(feature = "tls")]
        if hs_tls::live(h) {
            return if hs_tls::release(h) { 0 } else { ERR_STALE };
        }
        if fixtures::live(h) {
            return fixtures::release(h);
        }
        ERR_STALE
    })
}

// ------------------------------------------------------------ sockets

/// The transport operations the HTTP transport airlock grants: loopback
/// sockets, nonblocking, close-on-exec. A descriptor or -errno.
#[no_mangle]
pub extern "C" fn hs_tcp_listen(port: i64) -> i64 {
    guard(|| fixtures::socket(libc::SOCK_STREAM, port as u16, true, false))
}

#[no_mangle]
pub extern "C" fn hs_tcp_connect(port: i64) -> i64 {
    guard(|| fixtures::socket(libc::SOCK_STREAM, port as u16, false, true))
}

#[no_mangle]
pub extern "C" fn hs_udp_bind(port: i64) -> i64 {
    guard(|| fixtures::socket(libc::SOCK_DGRAM, port as u16, false, false))
}

#[no_mangle]
pub extern "C" fn hs_local_port(fd: i64) -> i64 {
    guard(|| fixtures::local_port(fd as i32))
}
