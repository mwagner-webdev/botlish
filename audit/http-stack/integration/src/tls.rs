//! The TLS exports (hs_tls): configurations Botlish makes and hands to
//! hs_h_server / hs_h_client, and the provider-identity probes.

use hs_bridge::ffi::{copy_in, guard, guard_with};

/// A client configuration: trust the census's test CA only, verify the
/// chain and HOST (bytes Botlish exposes), offer the ALPN protocols of
/// MASK (1 http/1.1, 2 h2, 4 a protocol nobody serves). Its handle.
#[no_mangle]
pub unsafe extern "C" fn hs_tls_client(host: *const u8, host_len: u64, alpn: i64) -> i64 {
    guard(|| {
        let h = String::from_utf8_lossy(&copy_in(host, host_len as usize)).into_owned();
        hs_tls::client_config(&h, alpn)
    })
}

/// A server configuration with certificate CERT (0 good, 1 wrong host,
/// 2 expired, 3 by an untrusted CA) accepting the ALPN protocols of MASK.
#[no_mangle]
pub extern "C" fn hs_tls_server(cert: i64, alpn: i64) -> i64 {
    guard(|| hs_tls::server_config(cert, alpn))
}

/// The handshakes so far: how many (I = -1), or the outcome of the I-th
/// (0 success, or an ERR_TLS_* code).
#[no_mangle]
pub extern "C" fn hs_tls_outcome(i: i64) -> i64 {
    guard(|| {
        let o = hs_tls::outcomes();
        if i < 0 {
            o.len() as i64
        } else {
            o.get(i as usize).copied().unwrap_or(1)
        }
    })
}

pub fn server_wrap(h: i64) -> Option<hs_hyper::Wrap> {
    hs_tls::server_wrap(h)
}

pub fn client_stream(h: i64, fd: i32) -> Option<std::pin::Pin<Box<dyn std::future::Future<Output = Result<(hs_hyper::iox::BoxStream, Option<hs_hyper::Proto>), i64>>>>> {
    hs_tls::client_stream(h, fd)
}

/// Provider identity as the Rust unit's references resolved: SHA256's
/// address, EVP_sha256()'s method table, the API version it was compiled
/// against.
#[no_mangle]
pub extern "C" fn hs_bssl_sha256_fn() -> i64 {
    guard_with(false, || hs_tls::sha256_fn() as i64)
}

#[no_mangle]
pub extern "C" fn hs_bssl_evp_sha256() -> i64 {
    guard_with(false, || hs_tls::evp_sha256() as i64)
}

#[no_mangle]
pub extern "C" fn hs_bssl_api_version() -> i64 {
    guard_with(false, hs_tls::api_version)
}
