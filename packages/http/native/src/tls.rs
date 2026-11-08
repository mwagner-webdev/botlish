//! TLS over Botlish-managed nonblocking I/O, with the one BoringSSL
//! provider through the `boring` crate.
//!
//! The record layer never blocks: BoringSSL runs over an adapter whose reads
//! and writes are the bridge's nonblocking system calls; one that would
//! block parks the current poll's waker on the descriptor (Botlish arms the
//! watch) and reports WouldBlock, which BoringSSL surfaces as WANT_READ /
//! WANT_WRITE, which the futures here turn into Pending.
//!
//! Trust is the client configuration's, and nothing else's
//! (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "TLS and trust policy"):
//!
//! * the store is built here, from the system bundle (`system`: the first
//!   regular file of `SYSTEM_BUNDLES`, a fixed list, read when the client is
//!   made) and the application's anchors (PEM bytes the application
//!   passes); it is the store verification uses. The provider's default
//!   verify paths are never loaded and no environment variable
//!   (SSL_CERT_FILE, SSL_CERT_DIR) is read: the context is built without
//!   `set_default_verify_paths`;
//! * verification is always on: the chain to an anchor, validity times,
//!   and the host name (or IP address, for a literal) against the
//!   certificate, with partial wildcards refused. There is no switch that
//!   turns any of it off;
//! * SNI carries the host name (never an IP literal); ALPN offers the
//!   protocols the configuration allows, and the server's choice decides
//!   HTTP/2 or HTTP/1.1.

use crate::stream::{BoxStream, FdStream};
use boring::ssl::{ErrorCode, HandshakeError, MidHandshakeSslStream, Ssl, SslContext, SslContextBuilder, SslMethod, SslStream, SslVerifyMode, SslVersion};
use boring::x509::store::X509StoreBuilder;
use boring::x509::verify::X509CheckFlags;
use boring::x509::X509;
use std::future::Future;
use std::io::{Error, Read, Write};
use std::pin::Pin;
use std::task::{Context, Poll};

/// The system trust bundles, in the order they are tried: Debian and
/// Ubuntu, Fedora and RHEL (two layouts), openSUSE, Alpine and others.
pub const SYSTEM_BUNDLES: &[&str] = &[
    "/etc/ssl/certs/ca-certificates.crt",
    "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem",
    "/etc/pki/tls/certs/ca-bundle.crt",
    "/etc/ssl/ca-bundle.pem",
    "/etc/ssl/cert.pem",
];

/// The protocols a client may negotiate.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Versions {
    /// Offer h2 and http/1.1; the server chooses (HTTP/1.1 without ALPN).
    Negotiate,
    /// HTTP/1.1 only.
    Http1,
    /// HTTP/2 only: a server that does not select h2 is a failure.
    Http2,
}

impl Versions {
    pub fn of(code: i64) -> Option<Versions> {
        match code {
            0 => Some(Versions::Negotiate),
            1 => Some(Versions::Http1),
            2 => Some(Versions::Http2),
            _ => None,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Proto {
    H1,
    H2,
}

/// Why a client's trust store could not be made.
#[derive(Debug)]
pub enum TrustError {
    /// System trust was asked for and no bundle of SYSTEM_BUNDLES exists.
    NoSystemBundle,
    /// A bundle exists and could not be read or holds no certificate.
    Unreadable(String),
    /// The application's anchors are not PEM certificates.
    BadAnchors(String),
    /// Neither system trust nor anchors: nothing could be verified.
    Empty,
    /// The provider refused a step (out of memory, ...).
    Provider(String),
}

impl TrustError {
    pub fn text(&self) -> String {
        match self {
            TrustError::NoSystemBundle => format!("no system trust bundle exists (looked for {})", SYSTEM_BUNDLES.join(", ")),
            TrustError::Unreadable(t) => t.clone(),
            TrustError::BadAnchors(t) => format!("the trust anchors are not PEM certificates: {t}"),
            TrustError::Empty => "the configuration trusts nothing: neither the system bundle nor anchors".into(),
            TrustError::Provider(t) => format!("BoringSSL refused the trust store: {t}"),
        }
    }
}

fn provider(e: boring::error::ErrorStack) -> TrustError {
    TrustError::Provider(e.to_string())
}

/// The bundle system trust reads, if any.
pub fn system_bundle() -> Option<&'static str> {
    SYSTEM_BUNDLES.iter().copied().find(|p| std::fs::metadata(p).map(|m| m.is_file()).unwrap_or(false))
}

fn alpn_wire(versions: Versions) -> Vec<u8> {
    let mut out = Vec::new();
    let protos: &[&[u8]] = match versions {
        Versions::Negotiate => &[b"h2", b"http/1.1"],
        Versions::Http1 => &[b"http/1.1"],
        Versions::Http2 => &[b"h2"],
    };
    for p in protos {
        out.push(p.len() as u8);
        out.extend_from_slice(p);
    }
    out
}

/// A client's TLS context: its trust store, verification, ALPN.
pub fn context(system: bool, anchors: &[u8], versions: Versions) -> Result<SslContext, TrustError> {
    let mut store = X509StoreBuilder::new().map_err(provider)?;
    let mut count = 0usize;
    if system {
        let path = system_bundle().ok_or(TrustError::NoSystemBundle)?;
        let pem = std::fs::read(path).map_err(|e| TrustError::Unreadable(format!("{path}: {e}")))?;
        let certs = X509::stack_from_pem(&pem).map_err(|e| TrustError::Unreadable(format!("{path}: {e}")))?;
        if certs.is_empty() {
            return Err(TrustError::Unreadable(format!("{path} holds no certificate")));
        }
        for c in certs {
            // A bundle may list one certificate twice; that is no error.
            if store.add_cert(c).is_ok() {
                count += 1;
            }
        }
    }
    if !anchors.is_empty() {
        let certs = X509::stack_from_pem(anchors).map_err(|e| TrustError::BadAnchors(e.to_string()))?;
        if certs.is_empty() {
            return Err(TrustError::BadAnchors("no certificate".into()));
        }
        for c in certs {
            if store.add_cert(c).is_ok() {
                count += 1;
            }
        }
    }
    if count == 0 {
        return Err(TrustError::Empty);
    }
    let mut b = SslContextBuilder::new(SslMethod::tls()).map_err(provider)?;
    b.set_verify(SslVerifyMode::PEER);
    b.set_verify_cert_store(store.build()).map_err(provider)?;
    b.set_min_proto_version(Some(SslVersion::TLS1_2)).map_err(provider)?;
    b.set_alpn_protos(&alpn_wire(versions)).map_err(provider)?;
    Ok(b.build())
}

/// Why a TLS connection failed.
#[derive(Debug)]
pub enum TlsError {
    /// Certificate verification failed: the X.509 verify result and its text.
    Verify(i64, String),
    /// Anything else of the handshake (the provider's error, an alert, the
    /// peer gone).
    Handshake(String),
}

/// The synchronous face of an FdStream for BoringSSL: valid only inside a
/// poll, whose context it parks the waker on.
pub struct Adapter {
    fd: FdStream,
    cx: *mut Context<'static>,
    eof: bool,
}

unsafe impl Send for Adapter {}

impl Adapter {
    fn cx(&mut self) -> &mut Context<'static> {
        assert!(!self.cx.is_null(), "botlish_http: TLS I/O outside a poll");
        unsafe { &mut *self.cx }
    }
}

impl Read for Adapter {
    fn read(&mut self, buf: &mut [u8]) -> std::io::Result<usize> {
        let cx = self.cx() as *mut Context<'static>;
        let r = self.fd.read_sync(unsafe { &mut *cx }, buf);
        if let Ok(0) = r {
            self.eof = true;
        }
        r
    }
}

impl Write for Adapter {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let cx = self.cx() as *mut Context<'static>;
        self.fd.write_sync(unsafe { &mut *cx }, buf)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

fn with_cx<R>(s: &mut SslStream<Adapter>, cx: &mut Context<'_>, f: impl FnOnce(&mut SslStream<Adapter>) -> R) -> R {
    s.get_mut().cx = (cx as *mut Context<'_>).cast();
    let r = f(s);
    s.get_mut().cx = std::ptr::null_mut();
    r
}

pub struct TlsStream {
    ssl: SslStream<Adapter>,
}

fn want(code: ErrorCode) -> bool {
    code == ErrorCode::WANT_READ || code == ErrorCode::WANT_WRITE
}

impl hyper::rt::Read for TlsStream {
    fn poll_read(mut self: Pin<&mut Self>, cx: &mut Context<'_>, mut buf: hyper::rt::ReadBufCursor<'_>) -> Poll<std::io::Result<()>> {
        let this = &mut *self;
        let r = with_cx(&mut this.ssl, cx, |s| unsafe { s.ssl_read_uninit(buf.as_mut()) });
        match r {
            Ok(n) => {
                unsafe { buf.advance(n) };
                Poll::Ready(Ok(()))
            }
            Err(e) if e.code() == ErrorCode::ZERO_RETURN => Poll::Ready(Ok(())),
            Err(e) if want(e.code()) => Poll::Pending,
            // A peer that closes the TCP connection without close_notify:
            // the end of the stream (HTTP's own framing says whether the
            // message was complete: a truncated body is Hyper's error).
            Err(e) if e.code() == ErrorCode::SYSCALL && this.ssl.get_ref().eof => Poll::Ready(Ok(())),
            Err(e) => Poll::Ready(Err(Error::other(e.to_string()))),
        }
    }
}

impl hyper::rt::Write for TlsStream {
    fn poll_write(mut self: Pin<&mut Self>, cx: &mut Context<'_>, buf: &[u8]) -> Poll<std::io::Result<usize>> {
        let this = &mut *self;
        match with_cx(&mut this.ssl, cx, |s| s.ssl_write(buf)) {
            Ok(n) => Poll::Ready(Ok(n)),
            Err(e) if want(e.code()) => Poll::Pending,
            Err(e) => Poll::Ready(Err(Error::other(e.to_string()))),
        }
    }

    fn poll_flush(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        Poll::Ready(Ok(()))
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<std::io::Result<()>> {
        let this = &mut *self;
        match with_cx(&mut this.ssl, cx, |s| s.shutdown()) {
            Ok(_) => Poll::Ready(Ok(())),
            Err(e) if want(e.code()) => Poll::Pending,
            Err(_) => Poll::Ready(Ok(())),
        }
    }
}

impl Drop for TlsStream {
    /// Local release: one attempt to send close_notify, never a wait for
    /// the socket or for the peer's answer. A peer is not told anything
    /// more than this one nonblocking write achieves.
    fn drop(&mut self) {
        let waker = std::task::Waker::noop();
        let mut cx = Context::from_waker(waker);
        let _ = with_cx(&mut self.ssl, &mut cx, |s| s.shutdown());
    }
}

/// Drive a handshake to completion over the bridge.
struct Handshake {
    mid: Option<MidHandshakeSslStream<Adapter>>,
}

fn failure(mid: &MidHandshakeSslStream<Adapter>) -> TlsError {
    // X509_V_ERR_INVALID_CALL (65): no verification ran (the handshake
    // ended before the peer's certificate) -- not a verification failure.
    if let Err(verify) = mid.ssl().verify_result() {
        if verify.as_raw() != 65 {
            return TlsError::Verify(verify.as_raw() as i64, verify.error_string().to_string());
        }
    }
    if mid.get_ref().eof {
        return TlsError::Handshake("the server closed the connection during the TLS handshake".into());
    }
    TlsError::Handshake(mid.error().to_string())
}

impl Future for Handshake {
    type Output = Result<SslStream<Adapter>, TlsError>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let mut mid = self.mid.take().expect("botlish_http: handshake polled after completion");
        mid.get_mut().cx = (cx as *mut Context<'_>).cast();
        match mid.handshake() {
            Ok(mut s) => {
                s.get_mut().cx = std::ptr::null_mut();
                Poll::Ready(Ok(s))
            }
            Err(HandshakeError::WouldBlock(mut m)) => {
                m.get_mut().cx = std::ptr::null_mut();
                self.mid = Some(m);
                Poll::Pending
            }
            Err(HandshakeError::Failure(m)) => Poll::Ready(Err(failure(&m))),
            Err(HandshakeError::SetupFailure(e)) => Poll::Ready(Err(TlsError::Handshake(e.to_string()))),
        }
    }
}

/// The client side of a TLS connection to HOST over FD: the stream and the
/// protocol the server selected by ALPN (None: it selected none).
pub async fn connect(ctx: &SslContext, host: &str, fd: FdStream) -> Result<(BoxStream, Option<Proto>), TlsError> {
    let mut ssl = Ssl::new(ctx).map_err(|e| TlsError::Handshake(e.to_string()))?;
    let ip = crate::net::literal(host);
    if ip.is_none() {
        ssl.set_hostname(host).map_err(|e| TlsError::Handshake(e.to_string()))?;
    }
    {
        let param = ssl.param_mut();
        param.set_hostflags(X509CheckFlags::NO_PARTIAL_WILDCARDS);
        match ip {
            Some(ip) => param.set_ip(ip),
            None => param.set_host(host),
        }
        .map_err(|e| TlsError::Handshake(e.to_string()))?;
    }
    let adapter = Adapter { fd, cx: std::ptr::null_mut(), eof: false };
    let mid = ssl.setup_connect(adapter);
    let s = Handshake { mid: Some(mid) }.await?;
    let proto = match s.ssl().selected_alpn_protocol() {
        Some(b"h2") => Some(Proto::H2),
        Some(b"http/1.1") => Some(Proto::H1),
        _ => None,
    };
    Ok((Box::new(TlsStream { ssl: s }) as BoxStream, proto))
}

/// The BoringSSL API version this unit was compiled against (the
/// provider's headers): `bh_provider` reports it.
pub fn api_version() -> i64 {
    boring_sys::BORINGSSL_API_VERSION as i64
}
