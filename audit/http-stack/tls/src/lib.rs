//! hs_tls -- TLS over Botlish-managed nonblocking I/O, with the one
//! BoringSSL provider through the `boring` crate
//! (HTTP-STACK-INTEGRATION-CENSUS.md, "TLS").
//!
//! The record layer never blocks: `boring`'s synchronous stream runs over
//! an adapter whose reads and writes are the bridge's nonblocking system
//! calls; one that would block parks the current poll's waker on the
//! descriptor (Botlish arms the watch) and reports WouldBlock, which
//! BoringSSL surfaces as WANT_READ / WANT_WRITE, which the async wrapper
//! turns into Pending. A handshake is the same loop over
//! `MidHandshakeSslStream`.
//!
//! Policy is the configuration's, never the mechanism's: a client config
//! names its trust anchors (here the census's own test CA, never the
//! system store), always verifies the peer chain and the host name, and
//! offers ALPN protocols; a server config names its certificate and the
//! protocols it accepts. Nothing here disables verification.

use boring::asn1::Asn1Time;
use boring::bn::{BigNum, MsbOption};
use boring::ec::{EcGroup, EcKey};
use boring::hash::MessageDigest;
use boring::nid::Nid;
use boring::pkey::{PKey, Private};
use boring::ssl::{
    AlpnError, ErrorCode, HandshakeError, MidHandshakeSslStream, Ssl, SslAcceptor, SslConnector, SslMethod, SslStream,
    SslVerifyMode, SslVersion,
};
use boring::x509::extension::{BasicConstraints, KeyUsage, SubjectAlternativeName};
use boring::x509::store::X509StoreBuilder;
use boring::x509::{X509Builder, X509NameBuilder, X509};
use hs_bridge::slab::Slab;
use hs_hyper::iox::{BoxStream, FdStream};
use hs_hyper::Proto;
use std::cell::RefCell;
use std::future::Future;
use std::io::{Error, ErrorKind, Read, Write};
use std::pin::Pin;
use std::rc::Rc;
use std::task::{Context, Poll};

pub const ERR_TLS_VERIFY: i64 = -91000; // minus the X509 verify result
pub const ERR_TLS_ALPN: i64 = -91120; // no_application_protocol
pub const ERR_TLS_EOF: i64 = -91999; // the peer went away mid-handshake
pub const ERR_TLS_OTHER: i64 = -91998;

pub const ALPN_H1: i64 = 1;
pub const ALPN_H2: i64 = 2;
pub const ALPN_ODD: i64 = 4; // a protocol nobody serves

/// The census's PKI, made at run time with the provider (no files): a
/// trusted CA and an untrusted one, and leaves for each server scenario.
pub struct Pki {
    pub ca: X509,
    pub untrusted: (X509, PKey<Private>),
    pub ca_key: PKey<Private>,
}

fn key() -> PKey<Private> {
    let group = EcGroup::from_curve_name(Nid::X9_62_PRIME256V1).unwrap();
    PKey::from_ec_key(EcKey::generate(&group).unwrap()).unwrap()
}

fn serial() -> boring::asn1::Asn1Integer {
    let mut bn = BigNum::new().unwrap();
    bn.rand(64, MsbOption::MAYBE_ZERO, false).unwrap();
    bn.to_asn1_integer().unwrap()
}

fn name(cn: &str) -> boring::x509::X509Name {
    let mut b = X509NameBuilder::new().unwrap();
    b.append_entry_by_nid(Nid::COMMONNAME, cn).unwrap();
    b.build()
}

fn make_ca(cn: &str) -> (X509, PKey<Private>) {
    let k = key();
    let mut b = X509Builder::new().unwrap();
    b.set_version(2).unwrap();
    b.set_serial_number(&serial()).unwrap();
    b.set_subject_name(&name(cn)).unwrap();
    b.set_issuer_name(&name(cn)).unwrap();
    b.set_pubkey(&k).unwrap();
    b.set_not_before(&Asn1Time::days_from_now(0).unwrap()).unwrap();
    b.set_not_after(&Asn1Time::days_from_now(30).unwrap()).unwrap();
    b.append_extension(&BasicConstraints::new().critical().ca().build().unwrap()).unwrap();
    b.append_extension(&KeyUsage::new().critical().key_cert_sign().crl_sign().build().unwrap()).unwrap();
    b.sign(&k, MessageDigest::sha256()).unwrap();
    (b.build(), k)
}

/// A leaf for HOST signed by (CA, CA_KEY), valid from NOT_BEFORE to
/// NOT_AFTER (Unix seconds).
fn make_leaf(ca: &X509, ca_key: &PKey<Private>, host: &str, not_before: i64, not_after: i64) -> (X509, PKey<Private>) {
    let k = key();
    let mut b = X509Builder::new().unwrap();
    b.set_version(2).unwrap();
    b.set_serial_number(&serial()).unwrap();
    b.set_subject_name(&name(host)).unwrap();
    b.set_issuer_name(ca.subject_name()).unwrap();
    b.set_pubkey(&k).unwrap();
    b.set_not_before(&Asn1Time::from_unix(not_before as _).unwrap()).unwrap();
    b.set_not_after(&Asn1Time::from_unix(not_after as _).unwrap()).unwrap();
    let san = SubjectAlternativeName::new().dns(host).build(&b.x509v3_context(Some(ca), None)).unwrap();
    b.append_extension(&san).unwrap();
    b.sign(ca_key, MessageDigest::sha256()).unwrap();
    (b.build(), k)
}

fn unix_now() -> i64 {
    std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).map(|d| d.as_secs() as i64).unwrap_or(0)
}

enum Config {
    Client { connector: SslConnector, host: String },
    Server { acceptor: Rc<SslAcceptor> },
}

thread_local! {
    static PKI: RefCell<Option<Rc<Pki>>> = const { RefCell::new(None) };
    static CONFIGS: RefCell<Slab<Config>> = RefCell::new(Slab::default());
}

// Config handles share the bridge's handle namespace by a tag bit.
const TAG: i64 = 1 << 60;

fn pki() -> Rc<Pki> {
    PKI.with(|p| {
        p.borrow_mut()
            .get_or_insert_with(|| {
                let (ca, ca_key) = make_ca("Botlish census test CA");
                let untrusted = make_ca("Untrusted CA");
                Rc::new(Pki { ca, untrusted, ca_key })
            })
            .clone()
    })
}

fn alpn_wire(mask: i64) -> Vec<u8> {
    let mut out = Vec::new();
    for (bit, p) in [(ALPN_H2, &b"h2"[..]), (ALPN_H1, &b"http/1.1"[..]), (ALPN_ODD, &b"botlish-odd"[..])] {
        if mask & bit != 0 {
            out.push(p.len() as u8);
            out.extend_from_slice(p);
        }
    }
    out
}

/// A client config: trust the census CA only, verify the chain and HOST,
/// offer the ALPN protocols of MASK. Its handle.
pub fn client_config(host: &str, alpn: i64) -> i64 {
    let mut b = SslConnector::builder(SslMethod::tls()).unwrap();
    b.set_verify_cert_store(trust_store()).unwrap();
    b.set_verify(SslVerifyMode::PEER);
    b.set_min_proto_version(Some(SslVersion::TLS1_2)).unwrap();
    if alpn != 0 {
        b.set_alpn_protos(&alpn_wire(alpn)).unwrap();
    }
    let connector = b.build();
    CONFIGS.with(|c| c.borrow_mut().insert(Config::Client { connector, host: host.to_string() })) | TAG
}

/// Server certificate kinds.
pub const CERT_GOOD: i64 = 0; // localhost, by the trusted CA, valid now
pub const CERT_WRONG_HOST: i64 = 1; // other.example
pub const CERT_EXPIRED: i64 = 2; // localhost, expired yesterday
pub const CERT_UNTRUSTED: i64 = 3; // localhost, by an untrusted CA

/// A server leaf of kind CERT and its key (also quiche's).
pub fn leaf(cert: i64) -> (X509, PKey<Private>) {
    let pki = pki();
    let now = unix_now();
    match cert {
        CERT_WRONG_HOST => make_leaf(&pki.ca, &pki.ca_key, "other.example", now - 3600, now + 86400),
        CERT_EXPIRED => make_leaf(&pki.ca, &pki.ca_key, "localhost", now - 3 * 86400, now - 86400),
        CERT_UNTRUSTED => make_leaf(&pki.untrusted.0, &pki.untrusted.1, "localhost", now - 3600, now + 86400),
        _ => make_leaf(&pki.ca, &pki.ca_key, "localhost", now - 3600, now + 86400),
    }
}

/// The client trust policy: the census's test CA, nothing else.
pub fn trust_store() -> boring::x509::store::X509Store {
    let mut store = X509StoreBuilder::new().unwrap();
    store.add_cert(pki().ca.clone()).unwrap();
    store.build()
}

pub fn server_config(cert: i64, alpn: i64) -> i64 {
    let (leaf, k) = leaf(cert);
    let mut b = SslAcceptor::mozilla_intermediate_v5(SslMethod::tls()).unwrap();
    b.set_private_key(&k).unwrap();
    b.set_certificate(&leaf).unwrap();
    let accept = alpn_wire(alpn);
    b.set_alpn_select_callback(move |_, client| {
        // The first of the client's protocols this server accepts; none is
        // a fatal no_application_protocol alert (RFC 7301).
        let mut rest = client;
        while let Some((&n, tail)) = rest.split_first() {
            let n = n as usize;
            if tail.len() < n {
                break;
            }
            let (p, next) = tail.split_at(n);
            if contains(&accept, p) {
                return Ok(p);
            }
            rest = next;
        }
        Err(AlpnError::ALERT_FATAL)
    });
    let acceptor = Rc::new(b.build());
    CONFIGS.with(|c| c.borrow_mut().insert(Config::Server { acceptor })) | TAG
}

fn contains(wire: &[u8], p: &[u8]) -> bool {
    let mut rest = wire;
    while let Some((&n, tail)) = rest.split_first() {
        let n = n as usize;
        if tail.len() < n {
            return false;
        }
        if &tail[..n] == p {
            return true;
        }
        rest = &tail[n..];
    }
    false
}

pub fn live(h: i64) -> bool {
    h & TAG != 0 && CONFIGS.with(|c| c.borrow().get(h & !TAG).is_some())
}

pub fn release(h: i64) -> bool {
    CONFIGS.with(|c| c.borrow_mut().remove(h & !TAG).is_some())
}

pub fn reset() {
    let all = CONFIGS.with(|c| std::mem::take(&mut *c.borrow_mut()));
    drop(all);
}

/// The synchronous face of an FdStream for BoringSSL: valid only inside a
/// poll, whose context it parks the waker on.
struct Adapter {
    fd: FdStream,
    cx: *mut Context<'static>,
    pub eof: bool,
}

unsafe impl Send for Adapter {}

impl Adapter {
    fn cx(&mut self) -> &mut Context<'static> {
        assert!(!self.cx.is_null(), "hs_tls: I/O outside a poll");
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

fn with_cx<S, R>(adapter: impl Fn(&mut S) -> &mut Adapter, s: &mut S, cx: &mut Context<'_>, f: impl FnOnce(&mut S) -> R) -> R {
    adapter(s).cx = (cx as *mut Context<'_>).cast();
    let r = f(s);
    adapter(s).cx = std::ptr::null_mut();
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
        let r = with_cx(|s: &mut SslStream<Adapter>| s.get_mut(), &mut this.ssl, cx, |s| unsafe { s.ssl_read_uninit(buf.as_mut()) });
        match r {
            Ok(n) => {
                unsafe { buf.advance(n) };
                Poll::Ready(Ok(()))
            }
            Err(e) if e.code() == ErrorCode::ZERO_RETURN => Poll::Ready(Ok(())),
            Err(e) if want(e.code()) => Poll::Pending,
            Err(e) if e.code() == ErrorCode::SYSCALL && this.ssl.get_ref().eof => Poll::Ready(Ok(())),
            Err(e) => Poll::Ready(Err(Error::other(e.to_string()))),
        }
    }
}

impl hyper::rt::Write for TlsStream {
    fn poll_write(mut self: Pin<&mut Self>, cx: &mut Context<'_>, buf: &[u8]) -> Poll<std::io::Result<usize>> {
        let this = &mut *self;
        match with_cx(|s: &mut SslStream<Adapter>| s.get_mut(), &mut this.ssl, cx, |s| s.ssl_write(buf)) {
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
        match with_cx(|s: &mut SslStream<Adapter>| s.get_mut(), &mut this.ssl, cx, |s| s.shutdown()) {
            Ok(_) => Poll::Ready(Ok(())),
            Err(e) if want(e.code()) => Poll::Pending,
            Err(_) => Poll::Ready(Ok(())),
        }
    }
}

thread_local! {
    /// Handshakes completed and failed (with their last error code), for
    /// the census's reports.
    pub static OUTCOMES: RefCell<Vec<i64>> = const { RefCell::new(Vec::new()) };
}

fn record(code: i64) {
    OUTCOMES.with(|o| o.borrow_mut().push(code));
}

fn failure(mid: &MidHandshakeSslStream<Adapter>) -> i64 {
    let text = mid.error().to_string();
    if text.contains("NO_APPLICATION_PROTOCOL") {
        return ERR_TLS_ALPN;
    }
    // X509_V_ERR_INVALID_CALL (65): no verification ran (the handshake
    // ended before the peer's certificate) -- not a verification failure.
    if let Err(verify) = mid.ssl().verify_result() {
        if verify.as_raw() != 65 {
            return ERR_TLS_VERIFY - verify.as_raw() as i64;
        }
    }
    if mid.get_ref().eof || mid.error().code() == ErrorCode::SYSCALL {
        return ERR_TLS_EOF;
    }
    LAST_ERROR.with(|l| *l.borrow_mut() = text);
    ERR_TLS_OTHER
}

thread_local! {
    pub static LAST_ERROR: RefCell<String> = const { RefCell::new(String::new()) };
}

/// Drive a handshake to completion over the bridge.
struct Handshake {
    mid: Option<MidHandshakeSslStream<Adapter>>,
}

impl Future for Handshake {
    type Output = Result<SslStream<Adapter>, i64>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let mut mid = self.mid.take().expect("hs_tls: handshake polled after completion");
        mid.get_mut().cx = (cx as *mut Context<'_>).cast();
        let r = mid.handshake();
        match r {
            Ok(mut s) => {
                s.get_mut().cx = std::ptr::null_mut();
                record(0);
                Poll::Ready(Ok(s))
            }
            Err(HandshakeError::WouldBlock(mut m)) => {
                m.get_mut().cx = std::ptr::null_mut();
                self.mid = Some(m);
                Poll::Pending
            }
            Err(HandshakeError::Failure(m)) => {
                let code = failure(&m);
                record(code);
                Poll::Ready(Err(code))
            }
            Err(HandshakeError::SetupFailure(_)) => {
                record(ERR_TLS_OTHER);
                Poll::Ready(Err(ERR_TLS_OTHER))
            }
        }
    }
}

fn proto_of(ssl: &SslStream<Adapter>) -> Option<Proto> {
    match ssl.ssl().selected_alpn_protocol() {
        Some(b"h2") => Some(Proto::H2),
        Some(b"http/1.1") => Some(Proto::H1),
        _ => None,
    }
}

type Made = Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>>;

/// The client side of FD under config H: a future of the TLS stream and
/// the protocol ALPN chose.
pub fn client_stream(h: i64, fd: i32) -> Option<Made> {
    let (ssl, host) = CONFIGS.with(|c| match c.borrow().get(h & !TAG) {
        Some(Config::Client { connector, host }) => {
            let cfg = connector.configure().ok()?;
            Some((cfg.into_ssl(host).ok()?, host.clone()))
        }
        _ => None,
    })?;
    let _ = host;
    Some(handshake(ssl, FdStream::new(fd), true))
}

fn handshake(ssl: Ssl, fd: FdStream, connect: bool) -> Made {
    let adapter = Adapter { fd, cx: std::ptr::null_mut(), eof: false };
    Box::pin(async move {
        let mid = if connect { ssl.setup_connect(adapter) } else { ssl.setup_accept(adapter) };
        let s = Handshake { mid: Some(mid) }.await?;
        let proto = proto_of(&s);
        Ok((Box::new(TlsStream { ssl: s }) as BoxStream, proto))
    })
}

/// The server side under config H, for hs_hyper's accept loop.
pub fn server_wrap(h: i64) -> Option<hs_hyper::Wrap> {
    let acceptor = CONFIGS.with(|c| match c.borrow().get(h & !TAG) {
        Some(Config::Server { acceptor }) => Some(acceptor.clone()),
        _ => None,
    })?;
    Some(Rc::new(move |stream: FdStream| {
        match Ssl::new(acceptor.context()) {
            Ok(ssl) => handshake(ssl, stream, false),
            Err(_) => Box::pin(async { Err(ERR_TLS_OTHER) }) as Made,
        }
    }))
}

/// Provider identity as this crate's references resolved (the census's
/// single-provider check: compared with the C airlock's).
pub fn sha256_fn() -> usize {
    boring_sys::SHA256 as *const () as usize
}

pub fn evp_sha256() -> usize {
    unsafe { boring_sys::EVP_sha256() as usize }
}

pub fn api_version() -> i64 {
    boring_sys::BORINGSSL_API_VERSION as i64
}

pub fn outcomes() -> Vec<i64> {
    OUTCOMES.with(|o| o.borrow().clone())
}

pub fn erase<E: std::fmt::Debug>(_: E) -> Error {
    Error::from(ErrorKind::Other)
}
