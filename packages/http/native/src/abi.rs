//! The C ABI of the unit: the `bh_*` functions http.bot declares
//! (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "The C ABI"). Every function takes
//! and returns C scalars; byte buffers are Botlish exposures valid for one
//! call (C-POINTER-BORROWING.md): `read noescape` for bytes Rust copies in,
//! `write noescape` for bytes Rust copies out. Every body runs in
//! `bridge::ffi::guard`: no panic unwinds into Botlish (a panic is
//! ERR_PANIC, the package's Fault), only the loop thread may call, and no
//! call reenters.
//!
//! Status conventions: a handle is positive; a failure is
//! `client::FAIL_BASE - kind` (<= -100), whose detail `bh_failure` copies
//! out; the guard's own refusals are -90001..-90005.

#![allow(clippy::missing_safety_doc)]

use crate::body::Outgoing;
use crate::bridge::ffi::{copy_in, copy_out, guard, guard_with, ERR_REENTRANT};
use crate::bridge::{exec, io, notices, stats, time};
use crate::client::{self, Failure, Kind, Origin, Parts, Settings};
use crate::tls::Versions;
use bytes::Bytes;

/// One record of `bh_step`'s and `bh_drain`'s buffer: four little-endian
/// i64 (http.bot's layout `StepRecord`).
const RECORD: usize = 32;
const R_SUMMARY: i64 = 0;
const R_NOTICE: i64 = 1;
const R_INTEREST: i64 = 2;

// ------------------------------------------------------------ lifecycle

/// Open the bridge on this thread (the loop's): 0, or ERR_REENTRANT when
/// it is open already.
#[no_mangle]
pub extern "C" fn bh_open(_flags: i64) -> i64 {
    guard_with(false, || {
        if exec::is_open() {
            return ERR_REENTRANT;
        }
        // The provider this unit was built against must be the one linked
        // (a reference to its identity symbol: another provider, or none,
        // fails the link instead of running silently: B2).
        crate::provider::check();
        exec::open();
        crate::bridge::ffi::set_owner();
        time::reset();
        io::reset();
        notices::reset();
        stats::reset();
        crate::net::open();
        0
    })
}

/// Close the bridge: every client and exchange released, every task
/// dropped (on this thread), queued name resolutions dropped and the
/// resolver's workers told to end. How many tasks were still live. The
/// descriptors the closed objects held come back from `bh_drain` (interest
/// 4) for Botlish to unwatch and close.
#[no_mangle]
pub extern "C" fn bh_close() -> i64 {
    guard(|| {
        client::reset();
        crate::net::shutdown();
        let n = exec::close() as i64;
        notices::reset();
        n
    })
}

/// Where a foreign thread's wake posts: the Linux driver's endpoint id and
/// the registration tag (std::event_loop::native_slot/native_generation).
#[no_mangle]
pub extern "C" fn bh_set_notify(endpoint: i64, slot: i64, generation: i64) -> i64 {
    guard(|| {
        exec::set_notify(endpoint, slot, generation);
        0
    })
}

/// The BoringSSL API version this unit was compiled against.
#[no_mangle]
pub extern "C" fn bh_provider() -> i64 {
    guard_with(false, crate::tls::api_version)
}

// ------------------------------------------------------------ scheduling

unsafe fn records(buf: *mut u8, cap: usize, left: i64) -> i64 {
    let room = cap / RECORD;
    if room == 0 {
        return 0;
    }
    let mut out: Vec<[i64; 4]> = Vec::with_capacity(room.min(64));
    out.push([R_SUMMARY, left, 0, -1]);
    let mut more = false;
    while out.len() < room {
        let h = notices::take();
        if h < 0 {
            break;
        }
        let n = notices::current().unwrap();
        out.push([R_NOTICE, n.handle, n.a, n.b]);
    }
    while out.len() < room {
        match io::next_interest() {
            Some((fd, interest)) => out.push([R_INTEREST, fd as i64, interest as i64, 0]),
            None => break,
        }
    }
    if out.len() == room && (notices::pending() > 0 || io::has_changes()) {
        more = true;
    }
    out[0][2] = more as i64;
    out[0][3] = time::next_deadline().map(|d| d as i64).unwrap_or(-1);
    let mut bytes = Vec::with_capacity(out.len() * RECORD);
    for r in &out {
        for v in r {
            bytes.extend_from_slice(&v.to_le_bytes());
        }
    }
    copy_out(&bytes, buf, cap);
    out.len() as i64
}

/// One executor step at Botlish time NOW: the timers due fire, then a
/// bounded run polls at most BUDGET of the tasks ready when it starts.
/// Into BUF (CAP bytes), records of 32 bytes: first the summary (kind 0:
/// tasks ready now, 1 when more records wait for bh_drain, the earliest
/// timer deadline or -1), then notices (kind 1: handle, note, value) and
/// readiness changes (kind 2: descriptor, interest 1 read, 2 write, 3
/// both, 4 unwatch and close). The count of records.
#[no_mangle]
pub unsafe extern "C" fn bh_step(budget: i64, now: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| {
        let now = now.max(0) as u64;
        time::set_now(now);
        time::fire(now);
        let left = exec::run(budget.max(0) as usize) as i64;
        records(buf, cap as usize, left)
    })
}

/// The records a step left (its summary said more), without running
/// anything; also after bh_close, whose objects' descriptors come back
/// here.
#[no_mangle]
pub unsafe extern "C" fn bh_drain(buf: *mut u8, cap: u64) -> i64 {
    guard_with(false, || {
        let left = if exec::is_open() { exec::ready_count() as i64 } else { 0 };
        records(buf, cap as usize, left)
    })
}

/// Botlish's watch of FD reported BITS (event_loop_linux: 1 readable,
/// 2 writable, 4 hang-up, 8 error). How many wakers were woken.
#[no_mangle]
pub extern "C" fn bh_io_ready(fd: i64, bits: i64) -> i64 {
    guard(|| io::ready(fd as i32, bits) as i64)
}

/// Close FD (Botlish unwatched it first): 0 or -errno.
#[no_mangle]
pub extern "C" fn bh_close_fd(fd: i64) -> i64 {
    guard_with(false, || io::close_fd(fd as i32))
}

// ------------------------------------------------------------ clients

/// A client. VERSIONS: 0 negotiate (ALPN h2 and http/1.1), 1 HTTP/1.1
/// only, 2 HTTP/2 only. Timeouts in microseconds of the loop clock (0: no
/// limit). WINDOW: HTTP/2's receive window per stream, bytes (the
/// connection's is four times it). SYSTEM_TRUST: 1 to trust the system bundle; ANCHORS: PEM
/// certificates trusted besides (LEN 0: none). Its handle, or a failure
/// status (bh_failure(0) says why).
#[no_mangle]
pub unsafe extern "C" fn bh_client(
    versions: i64,
    connect_us: i64,
    idle_us: i64,
    max_per_origin: i64,
    max_header_bytes: i64,
    pool_idle_us: i64,
    window: i64,
    system_trust: i64,
    anchors: *const u8,
    anchors_len: u64,
) -> i64 {
    guard(|| {
        let Some(versions) = Versions::of(versions) else {
            return client::set_last(Failure::new(Kind::Unsupported, versions, "unknown version policy"));
        };
        let pem = copy_in(anchors, anchors_len as usize);
        let settings = Settings {
            versions,
            connect_us: connect_us.max(0) as u64,
            idle_us: idle_us.max(0) as u64,
            max_per_origin: max_per_origin.clamp(0, 1 << 16) as usize,
            max_header_bytes: max_header_bytes.clamp(1024, 1 << 24) as usize,
            pool_idle_us: pool_idle_us.max(0) as u64,
            window: window.clamp(65535, (1 << 31) - 1) as u32,
        };
        client::client(settings, system_trust != 0, &pem)
    })
}

fn text(bytes: Vec<u8>, what: &str) -> Result<String, Failure> {
    String::from_utf8(bytes).map_err(|_| Failure::new(Kind::InvalidRequest, 0, format!("the {what} is not UTF-8")))
}

/// Start an exchange on CLIENT: METHOD, the origin (HTTPS 1 or 0, HOST
/// without brackets, PORT), TARGET (the path and query, from "/"), the
/// header block (NAME NUL VALUE NUL ...), the body: BODY's bytes, then --
/// STREAMED 1 -- chunks by bh_write until bh_finish; LENGTH the whole
/// body's declared length (-1 unknown: chunked or HTTP/2 DATA frames).
/// DEADLINE: loop-clock microseconds (0 none). CANCEL: a token (0 none).
/// Its handle, or a failure status (bh_failure(0)).
#[no_mangle]
pub unsafe extern "C" fn bh_request(
    client: i64,
    method: *const u8,
    method_len: u64,
    https: i64,
    host: *const u8,
    host_len: u64,
    port: i64,
    target: *const u8,
    target_len: u64,
    headers: *const u8,
    headers_len: u64,
    body: *const u8,
    body_len: u64,
    streamed: i64,
    length: i64,
    deadline: i64,
    cancel: i64,
) -> i64 {
    guard(|| {
        let parsed = (|| -> Result<(Parts, Outgoing), Failure> {
            let m = copy_in(method, method_len as usize);
            let method = http::Method::from_bytes(&m).map_err(|_| Failure::new(Kind::InvalidRequest, 0, "the method is not a token"))?;
            let host = text(copy_in(host, host_len as usize), "host")?;
            if host.is_empty() {
                return Err(Failure::new(Kind::InvalidRequest, 0, "the host is empty"));
            }
            if !(1..=65535).contains(&port) {
                return Err(Failure::new(Kind::InvalidRequest, port, "the port is outside 1..65535"));
            }
            let origin = Origin { https: https != 0, host, port: port as u16 };
            // The authority and the target are checked as http's URI
            // grammar has them.
            origin
                .authority()
                .parse::<http::uri::Authority>()
                .map_err(|_| Failure::new(Kind::InvalidRequest, 0, "the host is not a valid URI host"))?;
            let target = text(copy_in(target, target_len as usize), "target")?;
            if !target.starts_with('/') || target.parse::<http::uri::PathAndQuery>().is_err() {
                return Err(Failure::new(Kind::InvalidRequest, 0, "the request target is not a path (and query)"));
            }
            let headers = client::parse_headers(&copy_in(headers, headers_len as usize))?;
            let first = Bytes::from(copy_in(body, body_len as usize));
            let declared = (length >= 0).then_some(length as u64);
            let outgoing = if streamed != 0 {
                if let Some(n) = declared {
                    if (first.len() as u64) > n {
                        return Err(Failure::new(Kind::InvalidRequest, 0, "the body is longer than its declared length"));
                    }
                }
                let (o, slot) = Outgoing::streamed(0, declared);
                if !first.is_empty() {
                    crate::body::offer(&slot, first).map_err(|_| Failure::new(Kind::InvalidRequest, 0, "the body's first chunk was refused"))?;
                }
                o
            } else {
                if declared.is_some_and(|n| n != first.len() as u64) {
                    return Err(Failure::new(Kind::InvalidRequest, 0, "the body's length differs from its declared length"));
                }
                Outgoing::full(first)
            };
            Ok((Parts { method, origin, target, headers }, outgoing))
        })();
        match parsed {
            Ok((parts, body)) => {
                let deadline = (deadline > 0).then_some(deadline as u64);
                client::request(client, parts, body, deadline, cancel.max(0) as u64)
            }
            Err(f) => client::set_last(f),
        }
    })
}

/// 0 pending, 1 the response head is there, or a failure status.
#[no_mangle]
pub extern "C" fn bh_state(x: i64) -> i64 {
    guard(|| client::state(x))
}

/// X's response head, serialized (http.bot's layouts `HeadRecord` and
/// `FieldRecord`): status, version (11 or 20), the field count, 0 (u32
/// each); per field the name's offset and length and the value's (u32
/// each, offsets from the start); then the bytes. Copied when CAP holds
/// all of it. Its size, or a failure status (no head).
#[no_mangle]
pub unsafe extern "C" fn bh_head(x: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| match client::head_bytes(x) {
        Some(b) => {
            if b.len() <= cap as usize {
                copy_out(&b, buf, cap as usize);
            }
            b.len() as i64
        }
        None => client::state(x).min(client::FAIL_BASE - Kind::Released as i64),
    })
}

/// Copy up to CAP bytes of X's response body into BUF: bytes (> 0), 0
/// nothing yet (wait for X), -1 the end, or a failure status.
#[no_mangle]
pub unsafe extern "C" fn bh_read(x: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| client::read(x, buf, cap as usize))
}

/// Offer LEN bytes as the next chunk of X's request body: the count
/// accepted, 0 when the one-chunk slot is still full (wait for X), -2 when
/// the body is closed (the server ended the exchange), or a failure status.
#[no_mangle]
pub unsafe extern "C" fn bh_write(x: i64, data: *const u8, len: u64) -> i64 {
    guard(|| {
        // The slot is checked before the copy: a full slot copies nothing.
        match client::room(x) {
            0 => 0,
            1 => client::write(x, Bytes::from(copy_in(data, len as usize))),
            s => s,
        }
    })
}

/// End X's request body: 0, or a failure status.
#[no_mangle]
pub extern "C" fn bh_finish(x: i64) -> i64 {
    guard(|| client::finish(x))
}

/// The failure of X (0: of the last constructor or call that failed
/// before it had a handle), serialized (http.bot's layout `FailureRecord`):
/// kind, code, port (i64 each), the reason's and the host's lengths (u32
/// each), then both texts. Copied when CAP holds it; its size.
#[no_mangle]
pub unsafe extern "C" fn bh_failure(x: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| {
        let b = client::failure_bytes(x);
        if b.len() <= cap as usize {
            copy_out(&b, buf, cap as usize);
        }
        b.len() as i64
    })
}

/// Release a client or an exchange.
#[no_mangle]
pub extern "C" fn bh_release(h: i64) -> i64 {
    guard(|| client::release(h))
}

/// A new cancellation token.
#[no_mangle]
pub extern "C" fn bh_token() -> i64 {
    guard(client::new_token)
}

/// Cancel TOKEN's exchanges (and every later one carrying it): how many.
#[no_mangle]
pub extern "C" fn bh_cancel(token: i64) -> i64 {
    guard(|| client::cancel(token.max(0) as u64))
}

/// The counters (http.bot's layout `StatsRecord`: 21 i64), copied when CAP
/// holds them; their size.
#[no_mangle]
pub unsafe extern "C" fn bh_stats(buf: *mut u8, cap: u64) -> i64 {
    guard_with(false, || {
        let (clients, exchanges) = if exec::is_open() { client::counts() } else { (0, 0) };
        let (h1_idle, h1_open, h2_open, connecting) = if exec::is_open() { client::pool_counts() } else { (0, 0, 0, 0) };
        let (workers, started) = crate::net::workers();
        let s = |c: stats::Counter| stats::get(c as i32);
        let values: [i64; 21] = [
            clients as i64,
            exchanges as i64,
            exec::task_count() as i64,
            io::watched() as i64,
            crate::net::outstanding() as i64,
            workers as i64,
            started as i64,
            h1_idle as i64,
            h1_open as i64,
            h2_open as i64,
            connecting as i64,
            s(stats::Counter::Calls),
            s(stats::Counter::Runs),
            s(stats::Counter::Polls),
            s(stats::Counter::Notices),
            s(stats::Counter::BytesCopiedOut),
            s(stats::Counter::BytesCopiedIn),
            s(stats::Counter::MaxPollsPerRun),
            s(stats::Counter::MaxCallUs),
            s(stats::Counter::Panics),
            s(stats::Counter::MaxHeld),
        ];
        let mut b = Vec::with_capacity(168);
        for v in values {
            b.extend_from_slice(&v.to_le_bytes());
        }
        if b.len() <= cap as usize {
            copy_out(&b, buf, cap as usize);
        }
        b.len() as i64
    })
}
