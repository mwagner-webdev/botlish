//! The HTTP client: clients, their connection pools, and exchanges.
//!
//! Every object Botlish holds is a handle of one generation-checked table
//! (`OBJECTS`): a client or an exchange. Protocol work runs in bridge tasks
//! (an exchange's task, each connection's driver, Hyper's HTTP/2 tasks),
//! polled only by Botlish-scheduled runs.
//!
//! Connections (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, "Connection
//! management"): a client keeps, per origin (scheme, host, port),
//!
//! * at most one HTTP/2 connection, which every request to the origin
//!   shares (Hyper multiplexes streams; the server's concurrent-stream
//!   limit makes a request wait for a stream);
//! * HTTP/1.1 connections, at most `max_per_origin` open at once, each
//!   carrying one exchange at a time; one whose response body was read to
//!   its end goes back to the origin's idle list (keep-alive) and is reused
//!   while it is younger than `pool_idle`; one whose exchange was abandoned
//!   before the end of its body is closed, never reused.
//!
//! While a connection to an origin whose protocol is not known yet is being
//! made, other requests to it wait for it (it may be HTTP/2, which they
//! would share). A request is retried on another connection only when
//! Hyper hands it back unsent (`TrySendError::take_message`): never after
//! any byte of it may have been written, whatever its method.
//!
//! Timers, all in the Botlish clock: the connect timeout bounds a new
//! connection (resolution, TCP, TLS, the HTTP/2 handshake); the idle
//! timeout bounds each wait for the server (the response head, each body
//! chunk) while the client wants data -- never the application's own
//! pauses; the request deadline bounds the whole exchange.

use crate::body::{self, OfferError, Outgoing, Recv, Shared, Slot};
use crate::bridge::exec;
use crate::bridge::notices::notify;
use crate::bridge::slab::Slab;
use crate::bridge::time;
use crate::bridge::TaskKey;
use crate::net;
use crate::rt;
use crate::stream::{BoxStream, FdStream};
use crate::tls::{self, Proto, Versions};
use boring::ssl::SslContext;
use bytes::Bytes;
use http::header::{HeaderName, HeaderValue};
use hyper::body::Incoming;
use hyper::client::conn::{http1, http2};
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;
use std::sync::{Arc, Mutex};
use std::task::{Poll, Waker};

/// Notice kinds (`Notice::a`): an exchange's state changed (its head, a
/// chunk, its end or its failure), or its request body slot has room.
pub const NOTE_STATE: i64 = 1;
pub const NOTE_ROOM: i64 = 2;

/// A failure is reported to Botlish as FAIL_BASE - kind.
pub const FAIL_BASE: i64 = -100;

/// `write`'s answer when the request body is closed but the exchange did
/// not fail: the server ended the exchange early (its response is the
/// exchange's), or the body was finished.
pub const WRITE_CLOSED: i64 = -2;

/// What went wrong, as the Botlish errors name it (http.bot's `raise`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(i64)]
pub enum Kind {
    InvalidRequest = 1,
    Resolve = 2,
    Connect = 3,
    TlsVerify = 4,
    TlsHandshake = 5,
    Protocol = 6,
    Timeout = 7,
    Cancelled = 8,
    Closed = 9,
    Unsupported = 10,
    Trust = 11,
    Released = 12,
    Fault = 13,
}

/// Timeout phases (a Timeout failure's code).
pub const TIMEOUT_CONNECT: i64 = 1;
pub const TIMEOUT_DEADLINE: i64 = 2;
pub const TIMEOUT_IDLE: i64 = 3;

#[derive(Clone, Debug)]
pub struct Failure {
    pub kind: Kind,
    pub code: i64,
    pub port: i64,
    pub text: String,
    pub host: String,
}

impl Failure {
    pub fn new(kind: Kind, code: i64, text: impl Into<String>) -> Failure {
        Failure { kind, code, port: 0, text: text.into(), host: String::new() }
    }

    fn at(mut self, origin: &Origin) -> Failure {
        self.host = origin.host.clone();
        self.port = origin.port as i64;
        self
    }

    pub fn status(&self) -> i64 {
        FAIL_BASE - self.kind as i64
    }
}

thread_local! {
    /// The failure of the last constructor that failed (a client, a
    /// request refused before it had a handle): handle 0's.
    static LAST: RefCell<Option<Failure>> = const { RefCell::new(None) };
}

pub fn set_last(f: Failure) -> i64 {
    let s = f.status();
    LAST.with(|l| *l.borrow_mut() = Some(f));
    s
}

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct Origin {
    pub https: bool,
    pub host: String,
    pub port: u16,
}

impl Origin {
    /// host[:port], an IPv6 literal in brackets, the scheme's default port
    /// omitted: the Host header's and :authority's value.
    pub fn authority(&self) -> String {
        let host = if self.host.contains(':') { format!("[{}]", self.host) } else { self.host.clone() };
        let default = if self.https { 443 } else { 80 };
        if self.port == default {
            host
        } else {
            format!("{host}:{}", self.port)
        }
    }

    fn scheme(&self) -> &'static str {
        if self.https {
            "https"
        } else {
            "http"
        }
    }
}

pub struct Settings {
    pub versions: Versions,
    pub connect_us: u64,
    pub idle_us: u64,
    pub max_per_origin: usize,
    pub max_header_bytes: usize,
    pub pool_idle_us: u64,
    pub window: u32,
}

/// What an origin's connections share with it: the counts a connection's
/// destructor gives back and the requests waiting for a connection. A
/// connection never reaches the object table from a destructor (which may
/// run while the table is borrowed).
#[derive(Default)]
struct OriginShared {
    h1_open: std::cell::Cell<usize>,
    connecting: std::cell::Cell<usize>,
    waiters: RefCell<Vec<Waker>>,
}

impl OriginShared {
    fn wake(&self) {
        let waiters = std::mem::take(&mut *self.waiters.borrow_mut());
        for w in waiters {
            w.wake();
        }
    }

    fn park(&self, w: &Waker) {
        self.waiters.borrow_mut().push(w.clone());
    }
}

/// An HTTP/1.1 connection: its sender and the task driving it. Dropped, it
/// cancels the driver (which drops the stream and releases the descriptor)
/// and gives its origin's slot back.
struct H1Conn {
    sender: http1::SendRequest<Outgoing>,
    driver: TaskKey,
    idle_since: u64,
    shared: Rc<OriginShared>,
}

impl Drop for H1Conn {
    fn drop(&mut self) {
        exec::cancel(self.driver);
        self.shared.h1_open.set(self.shared.h1_open.get().saturating_sub(1));
        self.shared.wake();
    }
}

struct H2Conn {
    sender: http2::SendRequest<Outgoing>,
    driver: TaskKey,
}

impl Drop for H2Conn {
    fn drop(&mut self) {
        exec::cancel(self.driver);
    }
}

#[derive(Default)]
struct OriginState {
    proto: Option<Proto>,
    h2: Option<H2Conn>,
    h1_idle: Vec<H1Conn>,
    shared: Rc<OriginShared>,
}

pub struct ClientObj {
    settings: Rc<Settings>,
    tls: Option<SslContext>,
    origins: HashMap<Origin, OriginState>,
    exchanges: Vec<i64>,
}

/// An exchange's state as Botlish reads it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum XState {
    Pending,
    Head,
}

pub struct Head {
    pub status: u16,
    pub version: u32,
    pub headers: Vec<(HeaderName, HeaderValue)>,
}

pub struct ExchangeObj {
    client: i64,
    state: XState,
    head: Option<Head>,
    recv: Shared<Recv>,
    send: Option<Shared<Slot>>,
    failure: Option<Failure>,
    task: Option<TaskKey>,
    cancel: u64,
}

pub enum Object {
    Client(ClientObj),
    Exchange(ExchangeObj),
}

thread_local! {
    static OBJECTS: RefCell<Slab<Object>> = RefCell::new(Slab::default());
    /// Cancellation tokens: the exchanges carrying each, and the tokens
    /// already cancelled (a request carrying one fails at once).
    static TOKENS: RefCell<HashMap<u64, Vec<i64>>> = RefCell::new(HashMap::new());
    static CANCELLED: RefCell<HashSet<u64>> = RefCell::new(HashSet::new());
    static NEXT_TOKEN: std::cell::Cell<u64> = const { std::cell::Cell::new(1) };
}

/// Drop every object (the bridge's close): their tasks are the executor's,
/// which `exec::close` drops.
pub fn reset() {
    let all = OBJECTS.with(|o| std::mem::take(&mut *o.borrow_mut()));
    drop(all);
    TOKENS.with(|t| t.borrow_mut().clear());
    CANCELLED.with(|c| c.borrow_mut().clear());
    LAST.with(|l| *l.borrow_mut() = None);
}

fn insert(o: Object) -> i64 {
    OBJECTS.with(|t| t.borrow_mut().insert(o))
}

pub fn with<R>(h: i64, f: impl FnOnce(&mut Object) -> R) -> Option<R> {
    OBJECTS.with(|t| t.borrow_mut().get_mut(h).map(f))
}

fn with_exchange<R>(h: i64, f: impl FnOnce(&mut ExchangeObj) -> R) -> Option<R> {
    with(h, |o| match o {
        Object::Exchange(e) => Some(f(e)),
        _ => None,
    })
    .flatten()
}

fn with_client<R>(h: i64, f: impl FnOnce(&mut ClientObj) -> R) -> Option<R> {
    with(h, |o| match o {
        Object::Client(c) => Some(f(c)),
        _ => None,
    })
    .flatten()
}

pub fn counts() -> (usize, usize) {
    OBJECTS.with(|t| {
        let t = t.borrow();
        let mut clients = 0;
        let mut exchanges = 0;
        for h in t.handles() {
            match t.get(h) {
                Some(Object::Client(_)) => clients += 1,
                Some(Object::Exchange(_)) => exchanges += 1,
                None => {}
            }
        }
        (clients, exchanges)
    })
}

// ------------------------------------------------------------------ client

/// A new client: its settings and its TLS context (built now, so a trust
/// problem is the constructor's failure, not a request's).
pub fn client(settings: Settings, system_trust: bool, anchors: &[u8]) -> i64 {
    if settings.max_per_origin == 0 {
        return set_last(Failure::new(Kind::Unsupported, 0, "max_connections must be at least 1"));
    }
    let tls = match tls::context(system_trust, anchors, settings.versions) {
        Ok(ctx) => Some(ctx),
        Err(e) => return set_last(Failure::new(Kind::Trust, 0, e.text())),
    };
    insert(Object::Client(ClientObj { settings: Rc::new(settings), tls, origins: HashMap::new(), exchanges: Vec::new() }))
}

// ---------------------------------------------------------------- requests

/// What a request is made of, before the protocol is known.
pub struct Parts {
    pub method: http::Method,
    pub origin: Origin,
    pub target: String,
    pub headers: Vec<(HeaderName, HeaderValue)>,
}

/// Header names a request may not carry: the client owns connection
/// management and framing (HTTP/1.1's and HTTP/2's connection-specific
/// fields, RFC 9113 section 8.2.2), and the authority comes from the URI.
pub const FORBIDDEN: &[&str] = &[
    "connection",
    "keep-alive",
    "proxy-connection",
    "transfer-encoding",
    "upgrade",
    "te",
    "host",
    "content-length",
];

/// The request's header block (NAME NUL VALUE NUL ...), checked again here
/// whatever the Botlish side checked.
pub fn parse_headers(block: &[u8]) -> Result<Vec<(HeaderName, HeaderValue)>, Failure> {
    let mut out = Vec::new();
    if block.is_empty() {
        return Ok(out);
    }
    if *block.last().unwrap() != 0 {
        return Err(Failure::new(Kind::InvalidRequest, 0, "the header block is not terminated"));
    }
    let fields: Vec<&[u8]> = block[..block.len() - 1].split(|b| *b == 0).collect();
    if fields.len() % 2 != 0 {
        return Err(Failure::new(Kind::InvalidRequest, 0, "the header block holds a name without a value"));
    }
    for pair in fields.chunks(2) {
        let name = HeaderName::from_bytes(pair[0])
            .map_err(|_| Failure::new(Kind::InvalidRequest, 0, format!("invalid header name {:?}", String::from_utf8_lossy(pair[0]))))?;
        if pair[0].first() == Some(&b':') || FORBIDDEN.contains(&name.as_str()) {
            return Err(Failure::new(Kind::InvalidRequest, 0, format!("the client sets the {} header itself", name.as_str())));
        }
        let value = HeaderValue::from_bytes(pair[1])
            .map_err(|_| Failure::new(Kind::InvalidRequest, 0, format!("invalid value of header {}", name.as_str())))?;
        out.push((name, value));
    }
    Ok(out)
}

fn build(parts: &Parts, proto: Proto, body: Outgoing) -> Result<hyper::Request<Outgoing>, Failure> {
    let uri = match proto {
        Proto::H1 => parts.target.clone(),
        Proto::H2 => format!("{}://{}{}", parts.origin.scheme(), parts.origin.authority(), parts.target),
    };
    let mut b = hyper::Request::builder().method(parts.method.clone()).uri(uri);
    if proto == Proto::H1 {
        b = b.header(http::header::HOST, parts.origin.authority());
    }
    for (n, v) in &parts.headers {
        b = b.header(n.clone(), v.clone());
    }
    b.body(body).map_err(|e| Failure::new(Kind::InvalidRequest, 0, e.to_string()))
}

/// Start an exchange on CLIENT: its handle, or a failure status (LAST says
/// why).
pub fn request(client: i64, parts: Parts, body: Outgoing, deadline: Option<u64>, cancel: u64) -> i64 {
    let settings = match with_client(client, |c| c.settings.clone()) {
        Some(s) => s,
        None => return set_last(Failure::new(Kind::Released, 0, "the client was released")),
    };
    if !parts.origin.https && settings.versions == Versions::Http2 {
        return set_last(Failure::new(Kind::Unsupported, 0, "HTTP/2 over cleartext (h2c) is not supported: an http URI is HTTP/1.1").at(&parts.origin));
    }
    let slot = body.slot();
    let streamed = !slot.lock().unwrap().finished;
    let recv = Arc::new(Mutex::new(Recv::default()));
    let x = insert(Object::Exchange(ExchangeObj {
        client,
        state: XState::Pending,
        head: None,
        recv: recv.clone(),
        send: None,
        failure: None,
        task: None,
        cancel,
    }));
    if streamed {
        slot.lock().unwrap().producer = x;
        with_exchange(x, |e| e.send = Some(slot.clone()));
    }
    with_client(client, |c| c.exchanges.push(x));
    if cancel != 0 {
        if CANCELLED.with(|c| c.borrow().contains(&cancel)) {
            fail(x, Failure::new(Kind::Cancelled, 0, "the request's cancellation was already requested"));
            return x;
        }
        TOKENS.with(|t| t.borrow_mut().entry(cancel).or_default().push(x));
    }
    let task = crate::bridge::spawn("exchange", async move {
        let outcome = rt::until(deadline, exchange(x, client, settings, parts, body, recv)).await;
        match outcome {
            Ok(Ok(())) => {}
            Ok(Err(f)) => fail(x, f),
            Err(()) => fail(x, Failure::new(Kind::Timeout, TIMEOUT_DEADLINE, "the request's deadline passed")),
        }
    });
    with_exchange(x, |e| e.task = Some(task));
    x
}

/// Record F as X's failure (the first one counts) and wake its waiters.
fn fail(x: i64, f: Failure) {
    let changed = with_exchange(x, |e| {
        if e.failure.is_some() {
            return false;
        }
        e.failure = Some(f);
        if let Some(s) = &e.send {
            s.lock().unwrap().aborted = true;
        }
        true
    });
    if changed == Some(true) {
        notify(x, NOTE_STATE, 0);
    }
}

enum Conn {
    H1(H1Conn),
    H2(http2::SendRequest<Outgoing>),
}

enum Step {
    Take(Conn),
    Check(H1Conn),
    Closed,
    Connect(Rc<OriginShared>),
}

/// An origin's connecting count, held while a connection is being made and
/// given back whatever ends the attempt (success, failure, the exchange's
/// cancellation).
struct Connecting {
    shared: Rc<OriginShared>,
}

impl Drop for Connecting {
    fn drop(&mut self) {
        self.shared.connecting.set(self.shared.connecting.get().saturating_sub(1));
        self.shared.wake();
    }
}

async fn acquire(client: i64, origin: &Origin) -> Result<Conn, Failure> {
    loop {
        let step = std::future::poll_fn(|cx| {
            let r = with_client(client, |c| {
                let settings = c.settings.clone();
                let st = c.origins.entry(origin.clone()).or_default();
                if let Some(h2) = &st.h2 {
                    if !h2.sender.is_closed() {
                        return Poll::Ready(Step::Take(Conn::H2(h2.sender.clone())));
                    }
                    st.h2 = None;
                }
                let now = time::now();
                let mut stale = Vec::new();
                let mut found = None;
                while let Some(conn) = st.h1_idle.pop() {
                    let old = settings.pool_idle_us > 0 && now.saturating_sub(conn.idle_since) > settings.pool_idle_us;
                    if conn.sender.is_closed() || old {
                        stale.push(conn);
                        continue;
                    }
                    found = Some(conn);
                    break;
                }
                let shared = st.shared.clone();
                // Dropped here, outside any decision: each gives its slot back.
                let _ = stale;
                if let Some(conn) = found {
                    return Poll::Ready(Step::Check(conn));
                }
                let may_share = st.proto == Some(Proto::H2) || (st.proto.is_none() && origin.https && settings.versions != Versions::Http1);
                if may_share && shared.connecting.get() > 0 {
                    shared.park(cx.waker());
                    return Poll::Pending;
                }
                if shared.h1_open.get() + shared.connecting.get() >= settings.max_per_origin {
                    shared.park(cx.waker());
                    return Poll::Pending;
                }
                shared.connecting.set(shared.connecting.get() + 1);
                Poll::Ready(Step::Connect(shared))
            });
            r.unwrap_or(Poll::Ready(Step::Closed))
        })
        .await;
        match step {
            Step::Take(conn) => return Ok(conn),
            Step::Closed => return Err(Failure::new(Kind::Closed, 0, "the client was released").at(origin)),
            Step::Connect(shared) => return connect(client, origin, Connecting { shared }).await,
            Step::Check(mut conn) => {
                // An idle HTTP/1.1 connection is ready once Hyper finished
                // the previous message; one that closed meanwhile is dropped
                // (its slot given back) and the next is tried.
                if conn.sender.ready().await.is_ok() {
                    return Ok(Conn::H1(conn));
                }
                drop(conn);
            }
        }
    }
}

async fn connect(client: i64, origin: &Origin, guard: Connecting) -> Result<Conn, Failure> {
    let Some((settings, tls)) = with_client(client, |c| (c.settings.clone(), c.tls.clone())) else {
        return Err(Failure::new(Kind::Closed, 0, "the client was released").at(origin));
    };
    let shared = guard.shared.clone();
    let made = rt::within(settings.connect_us, async {
        let addrs = net::resolve(&origin.host, origin.port)
            .await
            .map_err(|e| Failure::new(Kind::Resolve, e.code, e.text).at(origin))?;
        let socket = net::connect(&addrs).await.map_err(|e| {
            let text = match e.addr {
                Some(a) => format!("{} ({a})", e.text),
                None => e.text,
            };
            Failure::new(Kind::Connect, e.code, text).at(origin)
        })?;
        let fd = FdStream::new(socket);
        let (stream, alpn): (BoxStream, Option<Proto>) = if origin.https {
            let ctx = tls.as_ref().ok_or_else(|| Failure::new(Kind::Trust, 0, "the client has no TLS configuration").at(origin))?;
            match tls::connect(ctx, &origin.host, fd).await {
                Ok(x) => x,
                Err(tls::TlsError::Verify(code, text)) => return Err(Failure::new(Kind::TlsVerify, code, text).at(origin)),
                Err(tls::TlsError::Handshake(text)) => return Err(Failure::new(Kind::TlsHandshake, 0, text).at(origin)),
            }
        } else {
            (Box::new(fd) as BoxStream, None)
        };
        let proto = match (settings.versions, alpn) {
            (Versions::Http2, Some(Proto::H2)) => Proto::H2,
            (Versions::Http2, _) => {
                return Err(Failure::new(Kind::Unsupported, 0, "the server did not negotiate HTTP/2 (ALPN h2), and the client allows HTTP/2 only").at(origin))
            }
            (Versions::Http1, _) => Proto::H1,
            (Versions::Negotiate, Some(p)) => p,
            (Versions::Negotiate, None) => Proto::H1,
        };
        handshake(stream, proto, &settings, &shared).await.map_err(|f| f.at(origin)).map(|c| (c, proto))
    })
    .await;
    let (conn, proto) = match made {
        Ok(Ok(x)) => x,
        Ok(Err(f)) => return Err(f),
        Err(()) => return Err(Failure::new(Kind::Timeout, TIMEOUT_CONNECT, "connecting took longer than the connect timeout").at(origin)),
    };
    // Registered with the origin: an HTTP/2 connection is shared from now
    // on; an HTTP/1.1 one counts against the origin's limit (its slot was
    // taken by handshake, the connecting one is given back by the guard).
    let r = with_client(client, |c| {
        let st = c.origins.entry(origin.clone()).or_default();
        st.proto = Some(proto);
        match conn {
            Made::H1(c1) => Some(Conn::H1(c1)),
            Made::H2(c2) => {
                let sender = c2.sender.clone();
                // A second HTTP/2 connection (two were made at once) replaces
                // none: the first one stays the origin's, this one serves
                // only its request and closes with it.
                match &st.h2 {
                    Some(h) if !h.sender.is_closed() => Some(Conn::H2(sender)),
                    _ => {
                        st.h2 = Some(c2);
                        Some(Conn::H2(sender))
                    }
                }
            }
        }
    })
    .flatten();
    drop(guard);
    r.ok_or_else(|| Failure::new(Kind::Closed, 0, "the client was released").at(origin))
}

enum Made {
    H1(H1Conn),
    H2(H2Conn),
}

async fn handshake(stream: BoxStream, proto: Proto, settings: &Settings, shared: &Rc<OriginShared>) -> Result<Made, Failure> {
    match proto {
        Proto::H1 => {
            let mut b = http1::Builder::new();
            b.max_header_size(settings.max_header_bytes.max(1024));
            b.max_buf_size(settings.max_header_bytes.max(16 * 1024));
            let (sender, conn) = b
                .handshake::<_, Outgoing>(stream)
                .await
                .map_err(|e| Failure::new(Kind::Protocol, 0, e.to_string()))?;
            let driver = crate::bridge::spawn("h1-connection", async move {
                let _ = conn.await;
            });
            shared.h1_open.set(shared.h1_open.get() + 1);
            Ok(Made::H1(H1Conn { sender, driver, idle_since: 0, shared: shared.clone() }))
        }
        Proto::H2 => {
            let mut b = http2::Builder::new(rt::Exec);
            b.timer(rt::Timer);
            b.max_header_list_size(settings.max_header_bytes.min(u32::MAX as usize) as u32);
            // The receive windows: how far a server may send ahead of a
            // program that does not read (the stream's), and of all its
            // streams together (the connection's).
            b.initial_stream_window_size(settings.window);
            b.initial_connection_window_size(settings.window.saturating_mul(4).min((1 << 31) - 1));
            b.adaptive_window(false);
            let (sender, conn) = b
                .handshake::<_, Outgoing>(stream)
                .await
                .map_err(|e| Failure::new(Kind::Protocol, 0, e.to_string()))?;
            let driver = crate::bridge::spawn("h2-connection", async move {
                let _ = conn.await;
            });
            Ok(Made::H2(H2Conn { sender, driver }))
        }
    }
}

/// The h2 error code of E's cause, when it has one (RST_STREAM, GOAWAY).
fn h2_code(e: &(dyn std::error::Error + 'static)) -> i64 {
    let mut cur: Option<&(dyn std::error::Error + 'static)> = Some(e);
    while let Some(err) = cur {
        if let Some(h2e) = err.downcast_ref::<h2::Error>() {
            if let Some(r) = h2e.reason() {
                return u32::from(r) as i64;
            }
        }
        cur = err.source();
    }
    -1
}

fn protocol(e: &hyper::Error) -> Failure {
    let mut text = e.to_string();
    let mut cur = std::error::Error::source(e);
    while let Some(c) = cur {
        text.push_str(": ");
        text.push_str(&c.to_string());
        cur = c.source();
    }
    let code = h2_code(e);
    if e.is_timeout() {
        return Failure::new(Kind::Timeout, TIMEOUT_IDLE, text);
    }
    Failure::new(Kind::Protocol, code, text)
}

/// The exchange's task: a connection, the request, the head, the body.
async fn exchange(x: i64, client: i64, settings: Rc<Settings>, parts: Parts, mut body: Outgoing, recv: Shared<Recv>) -> Result<(), Failure> {
    let origin = parts.origin.clone();
    let slot = body.slot();
    let mut attempts = 0;
    let (response, conn) = loop {
        attempts += 1;
        if attempts > 4 {
            return Err(Failure::new(Kind::Protocol, 0, "no connection would take the request (it was handed back unsent four times)").at(&origin));
        }
        // The connect timeout bounds getting a connection, waiting for a
        // pool slot included: a program holding MAX_CONNECTIONS unread
        // HTTP/1.1 responses of an origin gets a Timeout, not a wait
        // without end.
        let conn = match rt::within(settings.connect_us, acquire(client, &origin)).await {
            Ok(c) => c?,
            Err(()) => {
                return Err(Failure::new(
                    Kind::Timeout,
                    TIMEOUT_CONNECT,
                    "no connection to the origin within the connect timeout (every HTTP/1.1 connection the client may open to it is busy: are earlier responses unread?)",
                )
                .at(&origin))
            }
        };
        let proto = match &conn {
            Conn::H1(_) => Proto::H1,
            Conn::H2(_) => Proto::H2,
        };
        let req = build(&parts, proto, body)?;
        let sent = match conn {
            Conn::H1(mut c) => {
                let f = c.sender.try_send_request(req);
                // The idle timeout bounds the wait for the head.
                match head_wait(f, settings.idle_us, &slot).await {
                    Ok(r) => (r, Some(c)),
                    Err(()) => return Err(Failure::new(Kind::Timeout, TIMEOUT_IDLE, "the server sent no response head within the idle timeout").at(&origin)),
                }
            }
            Conn::H2(mut s) => {
                if s.ready().await.is_err() {
                    // The shared connection went away before this request
                    // was given to it: retry on another.
                    body = req.into_body();
                    forget_h2(client, &origin);
                    continue;
                }
                let f = s.try_send_request(req);
                match head_wait(f, settings.idle_us, &slot).await {
                    Ok(r) => (r, None),
                    Err(()) => return Err(Failure::new(Kind::Timeout, TIMEOUT_IDLE, "the server sent no response head within the idle timeout").at(&origin)),
                }
            }
        };
        match sent {
            (Ok(resp), conn) => break (resp, conn),
            (Err(mut e), conn) => {
                if let Some(req) = e.take_message() {
                    // Unsent: no byte of it reached the connection.
                    drop(conn);
                    if proto == Proto::H2 {
                        forget_h2(client, &origin);
                    }
                    body = req.into_body();
                    continue;
                }
                return Err(protocol(e.error()).at(&origin));
            }
        }
    };
    // The head.
    let head = Head {
        status: response.status().as_u16(),
        version: if response.version() == http::Version::HTTP_2 { 20 } else { 11 },
        headers: response.headers().iter().map(|(n, v)| (n.clone(), v.clone())).collect(),
    };
    let live = with_exchange(x, |e| {
        e.head = Some(head);
        e.state = XState::Head;
    });
    if live.is_none() {
        return Ok(());
    }
    notify(x, NOTE_STATE, 0);
    pump(x, &settings, &origin, recv, response.into_body()).await?;
    // The body was read to its end: an HTTP/1.1 connection may carry the
    // next exchange.
    if let Some(mut c) = conn {
        c.idle_since = time::now();
        give_back(client, &origin, c, &settings);
    }
    Ok(())
}

/// F (the response head), unless the server is silent for IDLE
/// microseconds once the request body is complete: while the application
/// still streams the body, the client is sending, not waiting.
async fn head_wait<F: std::future::Future>(f: F, idle: u64, slot: &Shared<Slot>) -> Result<F::Output, ()> {
    let mut f = std::pin::pin!(f);
    let mut sleep: Option<time::Sleep> = None;
    std::future::poll_fn(|cx| {
        if let Poll::Ready(v) = f.as_mut().poll(cx) {
            return Poll::Ready(Ok(v));
        }
        if idle == 0 {
            return Poll::Pending;
        }
        if sleep.is_none() {
            let mut s = slot.lock().unwrap();
            if s.finished || s.aborted {
                sleep = Some(time::Sleep::after(std::time::Duration::from_micros(idle)));
            } else {
                s.exchange = Some(cx.waker().clone());
            }
        }
        if let Some(sl) = sleep.as_mut() {
            if std::future::Future::poll(std::pin::Pin::new(sl), cx).is_ready() {
                return Poll::Ready(Err(()));
            }
        }
        Poll::Pending
    })
    .await
}

fn forget_h2(client: i64, origin: &Origin) {
    with_client(client, |c| {
        if let Some(st) = c.origins.get_mut(origin) {
            if st.h2.as_ref().is_some_and(|h| h.sender.is_closed()) {
                st.h2 = None;
            }
        }
    });
}

fn give_back(client: i64, origin: &Origin, conn: H1Conn, settings: &Settings) {
    let rest = with_client(client, |c| {
        let st = c.origins.entry(origin.clone()).or_default();
        if !conn.sender.is_closed() && st.h1_idle.len() < settings.max_per_origin {
            st.h1_idle.push(conn);
            st.shared.wake();
            None
        } else {
            Some(conn)
        }
    });
    // Not kept (the client is gone, the connection closed, the idle list is
    // full): dropped here, outside the table, giving its slot back.
    drop(rest);
}

/// Drive the response body into RECV, one chunk at a time: the next frame
/// is polled only once Botlish took the previous chunk.
async fn pump(x: i64, settings: &Settings, origin: &Origin, recv: Shared<Recv>, mut body: Incoming) -> Result<(), Failure> {
    use http_body_util::BodyExt;
    let unbounded = crate::faults::on(crate::faults::UNBOUNDED_RECV);
    loop {
        if !unbounded {
            std::future::poll_fn(|cx| {
                let mut r = recv.lock().unwrap();
                if r.chunks.is_empty() {
                    Poll::Ready(())
                } else {
                    r.pump = Some(cx.waker().clone());
                    Poll::Pending
                }
            })
            .await;
        }
        let frame = match rt::within(settings.idle_us, body.frame()).await {
            Ok(f) => f,
            Err(()) => return Err(Failure::new(Kind::Timeout, TIMEOUT_IDLE, "the server sent nothing within the idle timeout").at(origin)),
        };
        match frame {
            Some(Ok(frame)) => {
                // Trailers (HTTP/2, chunked HTTP/1.1) are not exposed.
                if let Ok(data) = frame.into_data() {
                    if data.is_empty() {
                        continue;
                    }
                    let mut r = recv.lock().unwrap();
                    r.bytes += data.len() as u64;
                    r.chunk_count += 1;
                    r.chunks.push_back(data);
                    let held = r.held();
                    r.max_buffered = r.max_buffered.max(held);
                    crate::bridge::stats::max(crate::bridge::stats::Counter::MaxHeld, held);
                    drop(r);
                    notify(x, NOTE_STATE, 0);
                }
            }
            None => {
                recv.lock().unwrap().eof = true;
                notify(x, NOTE_STATE, 0);
                return Ok(());
            }
            Some(Err(e)) => return Err(protocol(&e).at(origin)),
        }
    }
}

// ------------------------------------------------------- Botlish's queries

/// 0 pending, 1 the head is there, or a failure status.
pub fn state(x: i64) -> i64 {
    with_exchange(x, |e| match (&e.failure, e.state) {
        (_, XState::Head) => 1,
        (Some(f), _) => f.status(),
        (None, XState::Pending) => 0,
    })
    .unwrap_or(FAIL_BASE - Kind::Released as i64)
}

/// The head, serialized for http.bot's layouts (see `abi::bh_head`).
pub fn head_bytes(x: i64) -> Option<Vec<u8>> {
    with_exchange(x, |e| {
        let head = e.head.as_ref()?;
        let n = head.headers.len();
        let mut out = Vec::with_capacity(16 + 16 * n + 256);
        out.extend_from_slice(&(head.status as u32).to_le_bytes());
        out.extend_from_slice(&head.version.to_le_bytes());
        out.extend_from_slice(&(n as u32).to_le_bytes());
        out.extend_from_slice(&0u32.to_le_bytes());
        let mut offset = 16 + 16 * n;
        let mut entries = Vec::with_capacity(16 * n);
        let mut data = Vec::new();
        for (name, value) in &head.headers {
            let nb = name.as_str().as_bytes();
            let vb = value.as_bytes();
            entries.extend_from_slice(&(offset as u32).to_le_bytes());
            entries.extend_from_slice(&(nb.len() as u32).to_le_bytes());
            offset += nb.len();
            entries.extend_from_slice(&(offset as u32).to_le_bytes());
            entries.extend_from_slice(&(vb.len() as u32).to_le_bytes());
            offset += vb.len();
            data.extend_from_slice(nb);
            data.extend_from_slice(vb);
        }
        out.extend_from_slice(&entries);
        out.extend_from_slice(&data);
        Some(out)
    })
    .flatten()
}

/// Copy up to CAP bytes of X's body into DST: bytes (> 0), 0 nothing yet,
/// -1 the end, a failure status. Buffered bytes come before a failure.
///
/// # Safety
/// DST valid for CAP bytes of writes during this call.
pub unsafe fn read(x: i64, dst: *mut u8, cap: usize) -> i64 {
    let Some((recv, failure)) = with_exchange(x, |e| (e.recv.clone(), e.failure.as_ref().map(|f| f.status()))) else {
        return FAIL_BASE - Kind::Released as i64;
    };
    let mut r = recv.lock().unwrap();
    if !r.chunks.is_empty() {
        return r.take(dst, cap);
    }
    if let Some(s) = failure {
        return s;
    }
    r.take(dst, cap)
}

/// Offer DATA as the next chunk of X's request body.
pub fn write(x: i64, data: Bytes) -> i64 {
    let Some((slot, failure)) = with_exchange(x, |e| (e.send.clone(), e.failure.as_ref().map(|f| f.status()))) else {
        return FAIL_BASE - Kind::Released as i64;
    };
    if let Some(s) = failure {
        return s;
    }
    let Some(slot) = slot else {
        return set_last(Failure::new(Kind::InvalidRequest, 0, "the request's body is not streamed"));
    };
    match body::offer(&slot, data) {
        Ok(n) => n,
        Err(OfferError::TooLong) => {
            // The request cannot be completed as declared: the exchange
            // fails (its body aborts: HTTP/2 resets the stream, HTTP/1.1
            // closes the connection).
            let f = Failure::new(Kind::InvalidRequest, 0, "the body is longer than its declared length");
            let status = f.status();
            fail(x, f);
            status
        }
        Err(_) => WRITE_CLOSED,
    }
}

/// Whether X's request body slot has room (0/1), or a failure status.
pub fn room(x: i64) -> i64 {
    with_exchange(x, |e| match (&e.failure, &e.send) {
        (Some(f), _) => f.status(),
        (None, Some(s)) => body::has_room(s) as i64,
        (None, None) => 0,
    })
    .unwrap_or(FAIL_BASE - Kind::Released as i64)
}

pub fn finish(x: i64) -> i64 {
    let Some((slot, failure)) = with_exchange(x, |e| (e.send.clone(), e.failure.as_ref().map(|f| f.status()))) else {
        return FAIL_BASE - Kind::Released as i64;
    };
    if let Some(s) = failure {
        return s;
    }
    let Some(slot) = slot else { return 0 };
    match body::finish(&slot) {
        Ok(()) => 0,
        Err(OfferError::TooShort) => {
            let f = Failure::new(Kind::InvalidRequest, 0, "the body is shorter than its declared length");
            let status = f.status();
            fail(x, f);
            status
        }
        // The server ended the exchange before the body was complete (an
        // early response): nothing more to send; the response, if any, is
        // the exchange's.
        Err(_) => 0,
    }
}

/// The failure of X (0: the last constructor's), serialized: kind, code,
/// port (i64 each), the text's and the host's lengths (u32 each), then the
/// text and the host.
pub fn failure_bytes(x: i64) -> Vec<u8> {
    let f = if x == 0 {
        LAST.with(|l| l.borrow().clone())
    } else {
        with_exchange(x, |e| e.failure.clone()).flatten()
    };
    let f = f.unwrap_or_else(|| Failure::new(Kind::Released, 0, "no failure is recorded"));
    let mut out = Vec::with_capacity(32 + f.text.len() + f.host.len());
    out.extend_from_slice(&(f.kind as i64).to_le_bytes());
    out.extend_from_slice(&f.code.to_le_bytes());
    out.extend_from_slice(&f.port.to_le_bytes());
    out.extend_from_slice(&(f.text.len() as u32).to_le_bytes());
    out.extend_from_slice(&(f.host.len() as u32).to_le_bytes());
    out.extend_from_slice(f.text.as_bytes());
    out.extend_from_slice(f.host.as_bytes());
    out
}

// ----------------------------------------------------------- cancellation

pub fn new_token() -> i64 {
    NEXT_TOKEN.with(|n| {
        let t = n.get();
        n.set(t + 1);
        t as i64
    })
}

/// Cancel every exchange carrying TOKEN (and every later one): each fails
/// with Cancelled and its task is dropped now. How many were cancelled.
pub fn cancel(token: u64) -> i64 {
    if token == 0 {
        return 0;
    }
    CANCELLED.with(|c| c.borrow_mut().insert(token));
    let xs = TOKENS.with(|t| t.borrow_mut().remove(&token)).unwrap_or_default();
    let mut n = 0;
    for x in xs {
        let task = with_exchange(x, |e| if e.failure.is_none() && e.recv.lock().map(|r| !r.eof).unwrap_or(true) { e.task.take() } else { None }).flatten();
        if let Some(t) = task {
            fail(x, Failure::new(Kind::Cancelled, 0, "the request was cancelled"));
            exec::cancel(t);
            n += 1;
        }
    }
    n
}

// ------------------------------------------------------------ release

/// Release a handle. An exchange's task is cancelled (its futures dropped
/// now: an HTTP/2 stream is reset, an HTTP/1.1 connection mid-message is
/// closed). A client takes its connections and its exchanges with it (they
/// fail with Closed).
pub fn release(h: i64) -> i64 {
    let Some(o) = OBJECTS.with(|t| t.borrow_mut().remove(h)) else { return FAIL_BASE - Kind::Released as i64 };
    if crate::faults::on(crate::faults::RELEASE_LEAKS_TASKS) {
        std::mem::forget(o);
        return 0;
    }
    match o {
        Object::Exchange(mut e) => {
            if let Some(s) = &e.send {
                s.lock().unwrap().aborted = true;
            }
            if e.cancel != 0 {
                TOKENS.with(|t| {
                    if let Some(v) = t.borrow_mut().get_mut(&e.cancel) {
                        v.retain(|y| *y != h);
                    }
                });
            }
            with_client(e.client, |c| c.exchanges.retain(|y| *y != h));
            if let Some(t) = e.task.take() {
                exec::cancel(t);
            }
            drop(e);
        }
        Object::Client(mut c) => {
            let exchanges = std::mem::take(&mut c.exchanges);
            for x in exchanges {
                let task = with_exchange(x, |e| e.task.take()).flatten();
                fail(x, Failure::new(Kind::Closed, 0, "the client was released"));
                if let Some(t) = task {
                    exec::cancel(t);
                }
            }
            // Connections close as their states drop (their drivers are
            // cancelled; the descriptors go back to Botlish).
            drop(c);
        }
    }
    0
}

/// Pool counters over every client: (HTTP/1.1 idle, HTTP/1.1 open,
/// HTTP/2 open, connecting).
pub fn pool_counts() -> (usize, usize, usize, usize) {
    OBJECTS.with(|t| {
        let t = t.borrow();
        let mut out = (0, 0, 0, 0);
        for h in t.handles() {
            if let Some(Object::Client(c)) = t.get(h) {
                for st in c.origins.values() {
                    out.0 += st.h1_idle.len();
                    out.1 += st.shared.h1_open.get();
                    out.2 += st.h2.as_ref().is_some_and(|h| !h.sender.is_closed()) as usize;
                    out.3 += st.shared.connecting.get();
                }
            }
        }
        out
    })
}
