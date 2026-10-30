//! The QUIC / HTTP/3 exports (hs_quiche).

use hs_bridge::ffi::{copy_in, guard};

pub fn reset() {
    hs_quiche::reset();
}

pub fn live(h: i64) -> bool {
    hs_quiche::live(h)
}

pub fn release(h: i64) -> i64 {
    hs_quiche::release(h)
}

/// Settings for endpoints made later: the idle timeout (ms) and the
/// maximum pacing rate (bytes per second, 0 unlimited).
#[no_mangle]
pub extern "C" fn hs_q_configure(idle_ms: i64, pacing_rate: i64) -> i64 {
    guard(|| {
        hs_quiche::configure(idle_ms.max(1) as u64, pacing_rate.max(0) as u64);
        0
    })
}

/// A server endpoint on the bound UDP socket FD, certificate CERT (the
/// TLS kinds), stream window WINDOW bytes.
#[no_mangle]
pub extern "C" fn hs_q_server(fd: i64, cert: i64, window: i64) -> i64 {
    guard(|| hs_quiche::server(fd as i32, cert, window.max(1) as u64))
}

/// A client endpoint on FD connecting to 127.0.0.1:PORT as HOST.
#[no_mangle]
pub unsafe extern "C" fn hs_q_client(fd: i64, port: i64, host: *const u8, host_len: u64, window: i64) -> i64 {
    guard(|| {
        let h = String::from_utf8_lossy(&copy_in(host, host_len as usize)).into_owned();
        hs_quiche::client(fd as i32, port as u16, &h, window.max(1) as u64)
    })
}

#[no_mangle]
pub extern "C" fn hs_q_state(h: i64) -> i64 {
    guard(|| hs_quiche::state(h))
}

#[no_mangle]
pub unsafe extern "C" fn hs_q_request(h: i64, method: *const u8, method_len: u64, path: *const u8, path_len: u64, streaming: i64) -> i64 {
    guard(|| {
        let m = String::from_utf8_lossy(&copy_in(method, method_len as usize)).into_owned();
        let p = String::from_utf8_lossy(&copy_in(path, path_len as usize)).into_owned();
        hs_quiche::request(h, &m, &p, streaming != 0)
    })
}

#[no_mangle]
pub extern "C" fn hs_q_next_request(h: i64) -> i64 {
    guard(|| hs_quiche::next_request(h))
}

#[no_mangle]
pub extern "C" fn hs_q_respond(s: i64, status: i64, streaming: i64) -> i64 {
    guard(|| hs_quiche::respond(s, status as u16, streaming != 0))
}

#[no_mangle]
pub unsafe extern "C" fn hs_q_offer(s: i64, data: *const u8, len: u64) -> i64 {
    guard(|| {
        // Nothing is copied into a full slot.
        if hs_quiche::stat(s, 2) < 0 {
            return hs_bridge::ffi::ERR_STALE;
        }
        hs_quiche::offer(s, copy_in(data, len as usize))
    })
}

#[no_mangle]
pub extern "C" fn hs_q_finish(s: i64) -> i64 {
    guard(|| hs_quiche::finish(s))
}

#[no_mangle]
pub extern "C" fn hs_q_status(s: i64) -> i64 {
    guard(|| hs_quiche::status(s))
}

#[no_mangle]
pub unsafe extern "C" fn hs_q_recv(s: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| hs_quiche::recv(s, buf, cap as usize))
}

#[no_mangle]
pub unsafe extern "C" fn hs_q_path(s: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| hs_quiche::path(s, buf, cap as usize))
}

#[no_mangle]
pub extern "C" fn hs_q_stat(h: i64, i: i64) -> i64 {
    guard(|| hs_quiche::stat(h, i))
}
