//! botlish_http -- the native unit of Botlish's `http` package
//! (HTTP-CLIENT-PACKAGE-MILESTONE-1.md): an HTTP/1.1 and HTTP/2 client on
//! Hyper 1.12, TLS on BoringSSL (through `boring`), driven by the Botlish
//! event loop with no Tokio runtime. A static library whose only global
//! symbols are the `bh_*` C functions (`abi`; the test unit adds `bh_t_*`):
//! the author's build localizes everything else, so its private copy of the
//! Rust standard library never meets the Botlish runtime's. BoringSSL is
//! NOT inside it: the unit is compiled against the provider package's
//! headers and the final link takes the provider's archives.
//!
//! Layers: `bridge` (executor, readiness, timers, notices, handles, the FFI
//! guard), `net` (resolution off the loop thread, connection), `stream`
//! and `tls` (byte streams), `body` (chunks at the boundary), `client`
//! (clients, pools, exchanges), `abi` (the C functions).

pub mod abi;
pub mod body;
pub mod bridge;
pub mod client;
pub mod faults;
pub mod net;
pub mod rt;
pub mod stream;
pub mod tls;

#[cfg(feature = "testing")]
pub mod testing;

pub mod provider {
    include!(concat!(env!("OUT_DIR"), "/provider.rs"));
}
