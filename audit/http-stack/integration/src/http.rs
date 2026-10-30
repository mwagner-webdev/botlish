//! The Hyper exports (hs_hyper): clients, servers, exchanges, bodies.

use bytes::Bytes;
use hs_bridge::ffi::{copy_in, guard, ERR_STALE};
use hs_hyper::Proto;

/// HTTP/2 settings for later connections: WINDOW (initial stream window,
/// bytes; 0 Hyper's default) and KEEPALIVE_US (0: none).
#[no_mangle]
pub extern "C" fn hs_h_configure(window: i64, keepalive_us: i64) -> i64 {
    guard(|| {
        hs_hyper::configure((window > 0).then_some(window as u32), (keepalive_us > 0).then_some(keepalive_us as u64));
        0
    })
}

/// A server of PROTO (1 HTTP/1.1, 2 HTTP/2; with TLS, ALPN decides) whose
/// connections are made by TLS (a TLS server config handle) or plaintext
/// (0). Its handle.
#[no_mangle]
pub extern "C" fn hs_h_server(proto: i64, tls: i64) -> i64 {
    guard(|| {
        let wrap = if tls != 0 {
            #[cfg(feature = "tls")]
            {
                match crate::tls::server_wrap(tls) {
                    Some(w) => Some(w),
                    None => return ERR_STALE,
                }
            }
            #[cfg(not(feature = "tls"))]
            return ERR_STALE;
        } else {
            None
        };
        hs_hyper::server(Proto::of(proto), wrap)
    })
}

/// Accept on the listening socket FD (the server task owns it now).
#[no_mangle]
pub extern "C" fn hs_h_listen(server: i64, fd: i64) -> i64 {
    guard(|| hs_hyper::listen(server, fd as i32))
}

/// A client of PROTO over the connected socket FD, through TLS (a TLS
/// client config handle; SNI and verification from it) or plaintext (0).
#[no_mangle]
pub extern "C" fn hs_h_client(fd: i64, proto: i64, tls: i64) -> i64 {
    guard(|| {
        let make = if tls != 0 {
            #[cfg(feature = "tls")]
            {
                match crate::tls::client_stream(tls, fd as i32) {
                    Some(m) => m,
                    None => return ERR_STALE,
                }
            }
            #[cfg(not(feature = "tls"))]
            return ERR_STALE;
        } else {
            hs_hyper::plain(fd as i32)
        };
        hs_hyper::client(Proto::of(proto), make)
    })
}

/// A client of PROTO connected in memory to a connection of SERVER, each
/// direction holding at most CAPACITY bytes (the deterministic driver).
#[no_mangle]
pub extern "C" fn hs_h_mem_pair(server: i64, proto: i64, capacity: i64) -> i64 {
    guard(|| hs_hyper::mem_pair(server, Proto::of(proto), capacity.max(1) as usize))
}

/// A client's (or server connection's) state: 0 connecting, 1 HTTP/1.1,
/// 2 HTTP/2 (negotiated), or an error.
#[no_mangle]
pub extern "C" fn hs_h_client_state(h: i64) -> i64 {
    guard(|| hs_hyper::client_state(h))
}

/// Send a request (METHOD, PATH: bytes Botlish exposes for this call) on
/// CLIENT; STREAMING: its body follows in chunks. The exchange handle.
#[no_mangle]
pub unsafe extern "C" fn hs_h_request(client: i64, method: *const u8, method_len: u64, path: *const u8, path_len: u64, streaming: i64) -> i64 {
    guard(|| {
        let m = String::from_utf8_lossy(&copy_in(method, method_len as usize)).into_owned();
        let p = String::from_utf8_lossy(&copy_in(path, path_len as usize)).into_owned();
        hs_hyper::request(client, &m, &p, streaming != 0)
    })
}

/// The next request SERVER received, or 0.
#[no_mangle]
pub extern "C" fn hs_h_next_request(server: i64) -> i64 {
    guard(|| hs_hyper::next_request(server))
}

#[no_mangle]
pub extern "C" fn hs_h_respond(h: i64, status: i64, streaming: i64) -> i64 {
    guard(|| hs_hyper::respond(h, status as u16, streaming != 0))
}

/// Offer LEN bytes of H's outgoing body: accepted bytes, or 0 when the
/// one-chunk slot is full (wait for a SEND notice).
#[no_mangle]
pub unsafe extern "C" fn hs_h_offer(h: i64, data: *const u8, len: u64) -> i64 {
    guard(|| {
        // The slot's state is checked before the copy: a full slot copies
        // nothing.
        let full = hs_hyper::with_exchange(h, |e| e.send.as_ref().map(|s| s.lock().unwrap().chunk.is_some())).flatten();
        match full {
            None => ERR_STALE,
            Some(true) => 0,
            Some(false) => hs_hyper::offer(h, Bytes::from(copy_in(data, len as usize))),
        }
    })
}

#[no_mangle]
pub extern "C" fn hs_h_finish(h: i64) -> i64 {
    guard(|| hs_hyper::finish(h))
}

/// 0 pending, the HTTP status (a server exchange: 1) once the head is
/// there, or an error.
#[no_mangle]
pub extern "C" fn hs_h_status(h: i64) -> i64 {
    guard(|| hs_hyper::exchange_status(h))
}

/// Copy up to CAP bytes of H's incoming body into BUF (a Botlish write
/// exposure): bytes, 0 nothing yet, -1 end, an error.
#[no_mangle]
pub unsafe extern "C" fn hs_h_recv(h: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| hs_hyper::recv(h, buf, cap as usize))
}

/// "METHOD PATH" of server exchange H, copied into BUF.
#[no_mangle]
pub unsafe extern "C" fn hs_h_path(h: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| hs_hyper::exchange_path(h, buf, cap as usize))
}

#[no_mangle]
pub extern "C" fn hs_h_stat(h: i64, i: i64) -> i64 {
    guard(|| hs_hyper::exchange_stat(h, i as i32))
}

/// SERVER's live accepted connections (also after SERVER is released).
#[no_mangle]
pub extern "C" fn hs_h_server_conns(server: i64) -> i64 {
    guard(|| hs_hyper::server_conns(server))
}

#[no_mangle]
pub extern "C" fn hs_h_objects() -> i64 {
    guard(|| hs_hyper::object_count() as i64)
}
