//! hs_quiche -- core quiche (QUIC + HTTP/3) under the Botlish event loop,
//! no tokio-quiche (HTTP-STACK-INTEGRATION-CENSUS.md, "quiche
//! integration").
//!
//! An *endpoint* is one UDP socket Botlish handed over (a server's: many
//! connections routed by connection ID; a client's: one) and one bridge
//! task. Each poll of that task does a bounded amount of work and gives
//! the rest back to Botlish:
//!
//! * receive at most RECV_BUDGET datagrams (a socket with nothing parks on
//!   Botlish readiness);
//! * hand each connection's HTTP/3 events to its streams (at most
//!   EVENT_BUDGET), reading a stream's body only while its one-chunk
//!   buffer is empty -- an unread chunk leaves the bytes in quiche, whose
//!   stream flow control then stops the peer;
//! * send at most SEND_BUDGET packets, each no earlier than quiche's
//!   pacing time (`SendInfo::at`): a packet due later waits on a bridge
//!   timer, i.e. a Botlish timer registration;
//! * arm one bridge timer per connection at quiche's `timeout()` and call
//!   `on_timeout()` when it fires.
//!
//! A poll that exhausted a budget wakes itself and returns: the next poll
//! is in a later executor run, after every other ready Botlish task.
//!
//! Clocks: quiche reads `Instant::now()` itself and reports deadlines as
//! Durations from it; they become Botlish deadlines by adding them to the
//! Botlish clock (rounded up). Both are CLOCK_MONOTONIC on Linux, but no
//! numeric relation between them is assumed: a timer that fires a little
//! early finds nothing due in quiche (`timeout()` is then still Some, a
//! few microseconds away) and is re-armed -- counted, never lost.

use boring::ssl::{SslContextBuilder, SslMethod, SslVerifyMode};
use hs_bridge::ffi::{ERR_PROTOCOL, ERR_STALE};
use hs_bridge::notices::notify;
use hs_bridge::slab::Slab;
use hs_bridge::time::{self, Sleep};
use hs_bridge::{io, TaskKey};
use quiche::h3::NameValue;
use std::cell::RefCell;
use std::collections::{HashMap, VecDeque};
use std::future::Future;
use std::net::{SocketAddr, SocketAddrV4};
use std::pin::Pin;
use std::rc::Rc;
use std::task::{Context, Poll, Waker};
use std::time::Instant;

pub const RECV_BUDGET: usize = 32;
pub const SEND_BUDGET: usize = 32;
pub const EVENT_BUDGET: usize = 64;
const MAX_DATAGRAM: usize = 1350;
const CHUNK: usize = 16 * 1024;
/// Our connection IDs' length: a short-header packet does not carry it.
const CID_LEN: usize = 16;
const TIMER_SLACK_US: u64 = 1000;

pub const K_READY: i64 = 1;
pub const K_HEAD: i64 = 2;
pub const K_DATA: i64 = 3;
pub const K_END: i64 = 4;
pub const K_SEND: i64 = 5;
pub const K_REQUEST: i64 = 6;
pub const K_ERROR: i64 = 9;

pub const FAULT_IGNORE_TIMEOUT: u32 = 16; // quiche's timeout() is never armed (no PTO, no idle timer)
pub const FAULT_DROP_FIRST: u32 = 32; // a server drops the first datagram it receives (a lost Initial)

#[derive(Default, Clone, Copy, Debug)]
pub struct Stats {
    pub datagrams_in: u64,
    pub datagrams_out: u64,
    pub paced_deferred: u64,
    pub pacing_wait_us: u64,
    pub timeouts_fired: u64,
    pub timeouts_early: u64,
    pub budget_yields: u64,
    pub polls: u64,
    pub send_blocked: u64,
    pub connections: u64,
    pub max_pending_body: u64,
    pub max_quiche_ready_bytes: u64,
}

struct Stream {
    endpoint: i64,
    conn: usize,
    id: u64,
    status: i64,
    method: String,
    path: String,
    head: bool,
    error: i64,
    // receive side
    chunk: Option<Vec<u8>>,
    unread: bool, // quiche holds body bytes we have not read
    eof: bool,
    received: u64,
    taken: u64,
    // send side
    out: Option<Vec<u8>>,
    fin_pending: bool,
    finished: bool,
    accepted: u64,
    sent: u64,
    // server: respond pending
    respond: Option<(u16, bool)>,
    responded: bool,
}

struct Conn {
    q: quiche::Connection,
    #[allow(dead_code)]
    h3: Option<quiche::h3::Connection>,
    peer: SocketAddr,
    timer: Option<Sleep>,
    paced: Option<(Vec<u8>, SocketAddr, Sleep)>,
    streams: HashMap<u64, i64>,
    ready_noticed: bool,
    closed_noticed: bool,
}

pub struct Endpoint {
    fd: i32,
    server: bool,
    local: SocketAddr,
    config: quiche::Config,
    h3_config: quiche::h3::Config,
    conns: Vec<Option<Conn>>,
    by_cid: HashMap<Vec<u8>, usize>,
    pending: VecDeque<i64>,
    pending_requests: VecDeque<(i64, String, String, bool)>,
    waker: Option<Waker>,
    task: Option<TaskKey>,
    pub stats: Stats,
    error: i64,
    next_cid: u64,
}

enum Object {
    Endpoint(Rc<RefCell<Endpoint>>),
    Stream(Stream),
}

thread_local! {
    static OBJECTS: RefCell<Slab<Object>> = RefCell::new(Slab::default());
}

const TAG: i64 = 1 << 61;

fn insert(o: Object) -> i64 {
    OBJECTS.with(|t| t.borrow_mut().insert(o)) | TAG
}

pub fn live(h: i64) -> bool {
    h & TAG != 0 && OBJECTS.with(|t| t.borrow().get(h & !TAG).is_some())
}

fn endpoint(h: i64) -> Option<Rc<RefCell<Endpoint>>> {
    OBJECTS.with(|t| match t.borrow().get(h & !TAG) {
        Some(Object::Endpoint(e)) if h & TAG != 0 => Some(e.clone()),
        _ => None,
    })
}

fn with_stream<R>(h: i64, f: impl FnOnce(&mut Stream) -> R) -> Option<R> {
    if h & TAG == 0 {
        return None;
    }
    OBJECTS.with(|t| match t.borrow_mut().get_mut(h & !TAG) {
        Some(Object::Stream(s)) => Some(f(s)),
        _ => None,
    })
}

pub fn reset() {
    let all = OBJECTS.with(|t| std::mem::take(&mut *t.borrow_mut()));
    drop(all);
}

/// Release an endpoint (its task cancelled: every connection and stream
/// goes with it, the socket comes back to Botlish to close) or a stream
/// (reset by the endpoint at its next poll).
pub fn release(h: i64) -> i64 {
    let Some(o) = OBJECTS.with(|t| t.borrow_mut().remove(h & !TAG)) else { return ERR_STALE };
    match o {
        Object::Endpoint(e) => {
            let task = e.borrow_mut().task.take();
            if let Some(t) = task {
                hs_bridge::exec::cancel(t);
            }
            let fd = e.borrow().fd;
            io::release(fd);
            // Its streams can never complete.
            let streams: Vec<i64> = OBJECTS.with(|t| {
                let t = t.borrow();
                t.handles().into_iter().filter(|x| matches!(t.get(*x), Some(Object::Stream(s)) if s.endpoint == h)).collect()
            });
            for s in streams {
                with_stream(s | TAG, |st| st.error = hs_bridge::ffi::ERR_CANCELLED);
                notify(s | TAG, K_ERROR, hs_bridge::ffi::ERR_CANCELLED);
            }
        }
        Object::Stream(s) => {
            if let Some(e) = endpoint(s.endpoint) {
                let mut e = e.borrow_mut();
                if let Some(Some(c)) = e.conns.get_mut(s.conn) {
                    let _ = c.q.stream_shutdown(s.id, quiche::Shutdown::Read, 0);
                    let _ = c.q.stream_shutdown(s.id, quiche::Shutdown::Write, 0);
                    c.streams.remove(&s.id);
                }
                if let Some(w) = e.waker.take() {
                    w.wake();
                }
            }
        }
    }
    0
}

fn tls_builder(server_cert: Option<i64>) -> SslContextBuilder {
    let mut b = SslContextBuilder::new(SslMethod::tls()).unwrap();
    match server_cert {
        Some(kind) => {
            let (leaf, key) = hs_tls::leaf(kind);
            b.set_certificate(&leaf).unwrap();
            b.set_private_key(&key).unwrap();
        }
        None => {
            b.set_verify_cert_store(hs_tls::trust_store()).unwrap();
            b.set_verify(SslVerifyMode::PEER);
        }
    }
    b
}

thread_local! {
    /// Settings for endpoints made later: idle timeout (ms) and maximum
    /// pacing rate (bytes per second; 0: unlimited).
    static SETTINGS: std::cell::Cell<(u64, u64)> = const { std::cell::Cell::new((10_000, 0)) };
}

pub fn configure(idle_ms: u64, pacing_rate: u64) {
    SETTINGS.with(|s| s.set((idle_ms, pacing_rate)));
}

fn config(server_cert: Option<i64>, window: u64) -> quiche::Config {
    let mut c = quiche::Config::with_boring_ssl_ctx_builder(quiche::PROTOCOL_VERSION, tls_builder(server_cert)).unwrap();
    c.set_application_protos(quiche::h3::APPLICATION_PROTOCOL).unwrap();
    c.verify_peer(server_cert.is_none());
    let (idle, rate) = SETTINGS.with(|s| s.get());
    c.set_max_idle_timeout(idle);
    if rate > 0 {
        // quiche 0.30's default recovery (CUBIC) never delays a packet:
        // its get_packet_send_time() returns now. Only the gcongestion
        // recovery (BBR2) has a pacer that sets SendInfo::at.
        c.set_cc_algorithm(quiche::CongestionControlAlgorithm::Bbr2Gcongestion);
        c.set_max_pacing_rate(rate);
    }
    c.set_max_recv_udp_payload_size(MAX_DATAGRAM);
    c.set_max_send_udp_payload_size(MAX_DATAGRAM);
    c.set_initial_max_data(window * 8);
    c.set_initial_max_stream_data_bidi_local(window);
    c.set_initial_max_stream_data_bidi_remote(window);
    c.set_initial_max_stream_data_uni(window.max(65536));
    c.set_initial_max_streams_bidi(100);
    c.set_initial_max_streams_uni(100);
    c.enable_pacing(true);
    c
}

fn local_addr(fd: i32) -> SocketAddr {
    let port = hs_bridge_port(fd);
    SocketAddr::V4(SocketAddrV4::new([127, 0, 0, 1].into(), port))
}

fn hs_bridge_port(fd: i32) -> u16 {
    unsafe {
        let mut addr: libc::sockaddr_in = std::mem::zeroed();
        let mut len = std::mem::size_of::<libc::sockaddr_in>() as u32;
        libc::getsockname(fd, (&mut addr as *mut libc::sockaddr_in).cast(), &mut len);
        u16::from_be(addr.sin_port)
    }
}

fn new_cid(ep: &mut Endpoint) -> quiche::ConnectionId<'static> {
    ep.next_cid += 1;
    let mut id = [0u8; CID_LEN];
    boring::rand::rand_bytes(&mut id).unwrap();
    id[..8].copy_from_slice(&ep.next_cid.to_be_bytes());
    quiche::ConnectionId::from_vec(id.to_vec())
}

fn spawn(h: i64, ep: Rc<RefCell<Endpoint>>) {
    let task = hs_bridge::spawn("quic-endpoint", EndpointTask { h, ep: ep.clone() });
    ep.borrow_mut().task = Some(task);
}

/// A server endpoint on the bound UDP socket FD with certificate CERT
/// (hs_tls kinds) and stream window WINDOW bytes.
pub fn server(fd: i32, cert: i64, window: u64) -> i64 {
    let ep = Rc::new(RefCell::new(Endpoint {
        fd,
        server: true,
        local: local_addr(fd),
        config: config(Some(cert), window),
        h3_config: quiche::h3::Config::new().unwrap(),
        conns: Vec::new(),
        by_cid: HashMap::new(),
        pending: VecDeque::new(),
        pending_requests: VecDeque::new(),
        waker: None,
        task: None,
        stats: Stats::default(),
        error: 0,
        next_cid: 0,
    }));
    let h = insert(Object::Endpoint(ep.clone()));
    spawn(h, ep);
    h
}

/// A client endpoint on FD connecting to 127.0.0.1:PORT as HOST (SNI and
/// the verified name).
pub fn client(fd: i32, port: u16, host: &str, window: u64) -> i64 {
    let mut cfg = config(None, window);
    let local = local_addr(fd);
    let peer = SocketAddr::V4(SocketAddrV4::new([127, 0, 0, 1].into(), port));
    let mut ep = Endpoint {
        fd,
        server: false,
        local,
        config: quiche::Config::new(quiche::PROTOCOL_VERSION).unwrap(),
        h3_config: quiche::h3::Config::new().unwrap(),
        conns: Vec::new(),
        by_cid: HashMap::new(),
        pending: VecDeque::new(),
        pending_requests: VecDeque::new(),
        waker: None,
        task: None,
        stats: Stats::default(),
        error: 0,
        next_cid: 0,
    };
    let scid = new_cid(&mut ep);
    match quiche::connect(Some(host), &scid, local, peer, &mut cfg) {
        Ok(q) => {
            ep.by_cid.insert(scid.to_vec(), 0);
            ep.conns.push(Some(Conn { q, h3: None, peer, timer: None, paced: None, streams: HashMap::new(), ready_noticed: false, closed_noticed: false }));
            ep.stats.connections += 1;
        }
        Err(_) => ep.error = ERR_PROTOCOL,
    }
    ep.config = cfg;
    let ep = Rc::new(RefCell::new(ep));
    let h = insert(Object::Endpoint(ep.clone()));
    spawn(h, ep);
    h
}

/// 0 handshaking, 1 established (a server: listening), or an error.
pub fn state(h: i64) -> i64 {
    let Some(ep) = endpoint(h) else { return ERR_STALE };
    let e = ep.borrow();
    if e.error != 0 {
        return e.error;
    }
    if e.server {
        return 1;
    }
    match e.conns.first() {
        Some(Some(c)) if c.q.is_closed() => peer_code(&c.q),
        Some(Some(c)) if c.h3.is_some() => 1,
        Some(Some(_)) => 0,
        _ => ERR_PROTOCOL,
    }
}

fn peer_code(q: &quiche::Connection) -> i64 {
    let code = q.peer_error().or(q.local_error()).map(|e| e.error_code as i64).unwrap_or(0);
    // A TLS alert closes with CRYPTO_ERROR (0x100 + alert): the same
    // codes the TCP TLS probe reports, offset.
    -92000 - code
}

fn new_stream(endpoint: i64, conn: usize, id: u64) -> Stream {
    Stream {
        endpoint,
        conn,
        id,
        status: 0,
        method: String::new(),
        path: String::new(),
        head: false,
        error: 0,
        chunk: None,
        unread: false,
        eof: false,
        received: 0,
        taken: 0,
        out: None,
        fin_pending: false,
        finished: false,
        accepted: 0,
        sent: 0,
        respond: None,
        responded: false,
    }
}

/// A request on client endpoint H: METHOD PATH, STREAMING: a body follows
/// in chunks. The stream handle (sent at the endpoint's next poll).
pub fn request(h: i64, method: &str, path: &str, streaming: bool) -> i64 {
    let Some(ep) = endpoint(h) else { return ERR_STALE };
    let s = insert(Object::Stream(new_stream(h, 0, u64::MAX)));
    let mut e = ep.borrow_mut();
    e.pending_requests.push_back((s, method.to_string(), path.to_string(), streaming));
    if let Some(w) = e.waker.take() {
        w.wake();
    }
    s
}

pub fn next_request(h: i64) -> i64 {
    match endpoint(h) {
        Some(ep) => ep.borrow_mut().pending.pop_front().unwrap_or(0),
        None => ERR_STALE,
    }
}

fn wake_endpoint_of(s: i64) {
    let Some(ep) = with_stream(s, |st| st.endpoint).and_then(endpoint) else { return };
    let w = ep.borrow_mut().waker.take();
    if let Some(w) = w {
        w.wake();
    }
}

pub fn respond(s: i64, status: u16, streaming: bool) -> i64 {
    let r = with_stream(s, |st| {
        if st.responded {
            return ERR_STALE;
        }
        st.respond = Some((status, streaming));
        st.responded = true;
        if !streaming {
            st.fin_pending = true;
        }
        0
    })
    .unwrap_or(ERR_STALE);
    wake_endpoint_of(s);
    r
}

pub fn offer(s: i64, data: Vec<u8>) -> i64 {
    let r = with_stream(s, |st| {
        if st.finished || st.fin_pending || st.error != 0 {
            return ERR_STALE;
        }
        if st.out.is_some() {
            return 0;
        }
        let n = data.len() as i64;
        st.accepted += n as u64;
        st.out = Some(data);
        n
    })
    .unwrap_or(ERR_STALE);
    if r > 0 {
        wake_endpoint_of(s);
    }
    r
}

pub fn finish(s: i64) -> i64 {
    let r = with_stream(s, |st| {
        st.fin_pending = true;
        0
    })
    .unwrap_or(ERR_STALE);
    wake_endpoint_of(s);
    r
}

pub fn status(s: i64) -> i64 {
    with_stream(s, |st| if st.error != 0 { st.error } else if st.head { st.status.max(1) } else { 0 }).unwrap_or(ERR_STALE)
}

/// Copy up to CAP bytes of S's body into DST: n, 0 nothing yet, -1 end.
///
/// # Safety
/// DST valid for CAP bytes of writes.
pub unsafe fn recv(s: i64, dst: *mut u8, cap: usize) -> i64 {
    let (r, wake) = with_stream(s, |st| {
        if let Some(c) = st.chunk.as_mut() {
            let n = hs_bridge::ffi::copy_out(c, dst, cap);
            c.drain(..n);
            st.taken += n as u64;
            let emptied = c.is_empty();
            if emptied {
                st.chunk = None;
            }
            return (n as i64, emptied && (st.unread || !st.eof));
        }
        if st.error != 0 {
            return (st.error, false);
        }
        if st.eof {
            return (-1, false);
        }
        (0, false)
    })
    .unwrap_or((ERR_STALE, false));
    if wake {
        wake_endpoint_of(s);
    }
    r
}

/// "METHOD PATH" of server stream S.
///
/// # Safety
/// DST valid for CAP bytes of writes.
pub unsafe fn path(s: i64, dst: *mut u8, cap: usize) -> i64 {
    match with_stream(s, |st| format!("{} {}", st.method, st.path)) {
        Some(t) => hs_bridge::ffi::copy_out(t.as_bytes(), dst, cap) as i64,
        None => ERR_STALE,
    }
}

/// Stream counters (0 received, 1 taken, 2 accepted to send, 3 sent,
/// 4 buffered now) or endpoint counters (10.. : Stats fields in order).
pub fn stat(h: i64, i: i64) -> i64 {
    if let Some(ep) = endpoint(h) {
        let s = ep.borrow().stats;
        return match i {
            10 => s.datagrams_in,
            11 => s.datagrams_out,
            12 => s.paced_deferred,
            13 => s.pacing_wait_us,
            14 => s.timeouts_fired,
            15 => s.timeouts_early,
            16 => s.budget_yields,
            17 => s.polls,
            18 => s.send_blocked,
            19 => s.connections,
            20 => s.max_pending_body,
            21 => s.max_quiche_ready_bytes,
            _ => return -1,
        } as i64;
    }
    with_stream(h, |st| match i {
        0 => st.received as i64,
        1 => st.taken as i64,
        2 => st.accepted as i64,
        3 => st.sent as i64,
        4 => st.chunk.as_ref().map(|c| c.len()).unwrap_or(0) as i64,
        _ => -1,
    })
    .unwrap_or(ERR_STALE)
}

struct EndpointTask {
    h: i64,
    ep: Rc<RefCell<Endpoint>>,
}

impl Future for EndpointTask {
    type Output = ();

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        let h = self.h;
        let mut e = self.ep.borrow_mut();
        e.stats.polls += 1;
        e.waker = Some(cx.waker().clone());
        let mut more = false;
        more |= receive(&mut e, h, cx);
        // Client requests Botlish made since the last poll.
        start_requests(&mut e, h);
        for i in 0..e.conns.len() {
            more |= service(&mut e, h, i, cx);
        }
        // Drop closed connections (their streams fail).
        for i in 0..e.conns.len() {
            let closed = matches!(&e.conns[i], Some(c) if c.q.is_closed());
            if closed && e.server {
                let c = e.conns[i].take().unwrap();
                for (_, s) in c.streams {
                    if with_stream(s, |st| if !st.eof && st.error == 0 { st.error = ERR_PROTOCOL }).is_some() {
                        notify(s, K_ERROR, ERR_PROTOCOL);
                    }
                }
            }
        }
        if more {
            // A budget ran out: the rest is for a later run.
            e.stats.budget_yields += 1;
            cx.waker().wake_by_ref();
        }
        Poll::Pending
    }
}

/// Receive at most RECV_BUDGET datagrams. True when the budget ran out.
fn receive(e: &mut Endpoint, h: i64, cx: &mut Context<'_>) -> bool {
    let mut buf = [0u8; 65535];
    for _ in 0..RECV_BUDGET {
        let mut from: libc::sockaddr_in = unsafe { std::mem::zeroed() };
        let mut len = std::mem::size_of::<libc::sockaddr_in>() as u32;
        let n = unsafe { libc::recvfrom(e.fd, buf.as_mut_ptr().cast(), buf.len(), 0, (&mut from as *mut libc::sockaddr_in).cast(), &mut len) };
        if n < 0 {
            let err = std::io::Error::last_os_error();
            if err.kind() == std::io::ErrorKind::WouldBlock {
                io::park(e.fd, io::READ, cx.waker());
            }
            return false;
        }
        e.stats.datagrams_in += 1;
        if e.server && e.stats.datagrams_in == 1 && hs_bridge::exec::fault() & FAULT_DROP_FIRST != 0 {
            // The lost-packet scenario: QUIC must recover by its own
            // timers (the client's PTO retransmits its Initial).
            continue;
        }
        let peer = SocketAddr::V4(SocketAddrV4::new(u32::from_be(from.sin_addr.s_addr).into(), u16::from_be(from.sin_port)));
        let pkt = &mut buf[..n as usize];
        let Ok(hdr) = quiche::Header::from_slice(pkt, CID_LEN) else { continue };
        let index = match e.by_cid.get(hdr.dcid.as_ref()) {
            Some(&i) => i,
            None if e.server && hdr.ty == quiche::Type::Initial => {
                let scid = new_cid(e);
                let local = e.local;
                let Ok(q) = quiche::accept(&scid, None, local, peer, &mut e.config) else { continue };
                e.conns.push(Some(Conn { q, h3: None, peer, timer: None, paced: None, streams: HashMap::new(), ready_noticed: false, closed_noticed: false }));
                let i = e.conns.len() - 1;
                e.by_cid.insert(scid.to_vec(), i);
                e.by_cid.insert(hdr.dcid.to_vec(), i);
                e.stats.connections += 1;
                i
            }
            None => continue,
        };
        let local = e.local;
        if let Some(Some(c)) = e.conns.get_mut(index) {
            let _ = c.q.recv(pkt, quiche::RecvInfo { from: peer, to: local });
        }
        let _ = h;
    }
    true
}

fn start_requests(e: &mut Endpoint, h: i64) {
    if e.server {
        return;
    }
    let Some(Some(c)) = e.conns.get_mut(0) else { return };
    let Some(h3) = c.h3.as_mut() else { return };
    while let Some((s, method, path, streaming)) = e.pending_requests.pop_front() {
        let headers = vec![
            quiche::h3::Header::new(b":method", method.as_bytes()),
            quiche::h3::Header::new(b":scheme", b"https"),
            quiche::h3::Header::new(b":authority", b"localhost"),
            quiche::h3::Header::new(b":path", path.as_bytes()),
        ];
        match h3.send_request(&mut c.q, &headers, !streaming) {
            Ok(id) => {
                c.streams.insert(id, s);
                with_stream(s, |st| {
                    st.id = id;
                    st.method = method;
                    st.path = path;
                    if !streaming {
                        st.finished = true;
                    }
                });
            }
            Err(quiche::h3::Error::StreamBlocked) => {
                e.pending_requests.push_front((s, method, path, streaming));
                return;
            }
            Err(_) => {
                with_stream(s, |st| st.error = ERR_PROTOCOL);
                notify(s, K_ERROR, ERR_PROTOCOL);
            }
        }
    }
    let _ = h;
}

/// One connection's events, sends, timers. True when a budget ran out.
fn service(e: &mut Endpoint, h: i64, i: usize, cx: &mut Context<'_>) -> bool {
    let server = e.server;
    let fd = e.fd;
    let fault = hs_bridge::exec::fault();
    let mut new_requests = Vec::new();
    let mut more = false;
    let h3_config = &e.h3_config;
    let stats = &mut e.stats;
    let Some(Some(c)) = e.conns.get_mut(i) else { return false };
    // HTTP/3 over an established connection.
    if c.h3.is_none() && c.q.is_established() {
        match quiche::h3::Connection::with_transport(&mut c.q, h3_config) {
            Ok(h3) => c.h3 = Some(h3),
            Err(_) => {
                let _ = c.q.close(false, 0x101, b"h3");
            }
        }
    }
    if !server && !c.ready_noticed && (c.h3.is_some() || c.q.is_closed()) {
        c.ready_noticed = true;
        notify(h, K_READY, if c.q.is_closed() { peer_code(&c.q) } else { 1 });
    }
    if !server && c.q.is_closed() && !c.closed_noticed {
        // A client's connection ended (an error, the idle timeout): its
        // waiters see the state change.
        c.closed_noticed = true;
        notify(h, K_ERROR, peer_code(&c.q));
    }
    if let Some(h3) = c.h3.as_mut() {
        for _ in 0..EVENT_BUDGET {
            match h3.poll(&mut c.q) {
                Ok((id, quiche::h3::Event::Headers { list, more_frames })) => {
                    if server {
                        let mut st = new_stream(h, i, id);
                        for hd in &list {
                            match hd.name() {
                                b":method" => st.method = String::from_utf8_lossy(hd.value()).into_owned(),
                                b":path" => st.path = String::from_utf8_lossy(hd.value()).into_owned(),
                                _ => {}
                            }
                        }
                        st.head = true;
                        st.eof = !more_frames;
                        let s = insert(Object::Stream(st));
                        c.streams.insert(id, s);
                        new_requests.push(s);
                    } else if let Some(&s) = c.streams.get(&id) {
                        let status = list
                            .iter()
                            .find(|hd| hd.name() == b":status")
                            .and_then(|hd| std::str::from_utf8(hd.value()).ok()?.parse::<i64>().ok())
                            .unwrap_or(0);
                        with_stream(s, |st| {
                            st.status = status;
                            st.head = true;
                            st.eof = !more_frames;
                        });
                        notify(s, K_HEAD, status);
                    }
                }
                Ok((id, quiche::h3::Event::Data)) => {
                    if let Some(&s) = c.streams.get(&id) {
                        with_stream(s, |st| st.unread = true);
                    }
                }
                Ok((id, quiche::h3::Event::Finished)) => {
                    if let Some(&s) = c.streams.get(&id) {
                        let ended = with_stream(s, |st| {
                            st.eof = true;
                            st.chunk.is_none() && !st.unread
                        });
                        if ended == Some(true) {
                            notify(s, K_END, 0);
                        }
                    }
                }
                Ok((id, quiche::h3::Event::Reset(code))) => {
                    if let Some(&s) = c.streams.get(&id) {
                        with_stream(s, |st| st.error = -93000 - code as i64);
                        notify(s, K_ERROR, -93000 - code as i64);
                    }
                }
                Ok(_) => {}
                Err(quiche::h3::Error::Done) => break,
                Err(_) => break,
            }
        }
        // Read bodies into empty one-chunk buffers; write offered chunks.
        let streams: Vec<(u64, i64)> = c.streams.iter().map(|(a, b)| (*a, *b)).collect();
        let mut buf = vec![0u8; CHUNK];
        for (id, s) in streams {
            let want_read = with_stream(s, |st| st.unread && st.chunk.is_none()).unwrap_or(false);
            if want_read {
                match h3.recv_body(&mut c.q, id, &mut buf) {
                    Ok(n) => {
                        let ended = with_stream(s, |st| {
                            st.received += n as u64;
                            st.chunk = Some(buf[..n].to_vec());
                            st.unread = true; // quiche may hold more; asked again when emptied
                            stats.max_pending_body = stats.max_pending_body.max(n as u64);
                            false
                        });
                        let _ = ended;
                        notify(s, K_DATA, n as i64);
                    }
                    Err(quiche::h3::Error::Done) => {
                        let ended = with_stream(s, |st| {
                            st.unread = false;
                            st.eof && st.chunk.is_none()
                        });
                        if ended == Some(true) {
                            notify(s, K_END, 0);
                        }
                    }
                    Err(_) => {}
                }
            }
            // How much quiche itself holds for streams Botlish is not
            // reading: bounded by the stream window.
            if let Ok(cap) = c.q.stream_capacity(id) {
                let _ = cap;
            }
            send_stream(h3, &mut c.q, id, s, stats);
        }
    }
    // Packets, paced. quiche's times are relative to its own reading of
    // the clock, so they are converted with a fresh Botlish-clock reading,
    // not the turn's (a deadline from the turn's start fires early by the
    // time the turn has run: the first run of this probe fired 20 of 21
    // timers early).
    let now_us = time::fresh_now();
    if let Some((pkt, to, sleep)) = c.paced.as_mut() {
        if Pin::new(sleep).poll(cx).is_ready() {
            let (pkt, to) = (pkt.clone(), *to);
            c.paced = None;
            if !send_to(fd, &pkt, to, cx, stats) {
                return more;
            }
        } else {
            return more;
        }
    }
    let mut out = [0u8; MAX_DATAGRAM];
    let mut sent = 0;
    loop {
        if sent == SEND_BUDGET {
            more = true;
            break;
        }
        match c.q.send(&mut out) {
            Ok((n, info)) => {
                let wait = info.at.saturating_duration_since(Instant::now());
                if wait.as_micros() > 0 {
                    // Not before quiche's pacing time: a bridge timer (a
                    // Botlish timer registration) sends it.
                    let deadline = now_us + time::ceil_micros(wait);
                    stats.paced_deferred += 1;
                    stats.pacing_wait_us += time::ceil_micros(wait);
                    let mut sleep = Sleep::until(deadline);
                    let _ = Pin::new(&mut sleep).poll(cx);
                    c.paced = Some((out[..n].to_vec(), info.to, sleep));
                    break;
                }
                if !send_to(fd, &out[..n], info.to, cx, stats) {
                    // EAGAIN: quiche considers it sent; datagram loss is
                    // QUIC's to recover. Counted.
                    stats.send_blocked += 1;
                    break;
                }
                sent += 1;
            }
            Err(quiche::Error::Done) => break,
            Err(_) => break,
        }
    }
    // quiche's timer, in the Botlish clock. quiche decides when it is due
    // (its own clock): a zero timeout() is due now. Otherwise one bridge
    // timer waits for the converted deadline; it is moved only when the
    // deadline moves earlier, or later by more than TIMER_SLACK_US (moving
    // it on every poll by the conversion's microseconds of jitter starved
    // it: the first version of this loop spun for 300,000 turns with the
    // timer always a few microseconds ahead). A bridge timer that expires
    // before quiche thinks it is due counts as early and is re-armed.
    if fault & FAULT_IGNORE_TIMEOUT == 0 {
        match c.q.timeout() {
            Some(d) if d.is_zero() => {
                fire_timeout(c, stats);
                more = true;
            }
            Some(d) => {
                let deadline = now_us + time::ceil_micros(d);
                let t = c.timer.get_or_insert_with(|| Sleep::until(deadline));
                if deadline < t.deadline() || deadline > t.deadline() + TIMER_SLACK_US {
                    t.reset(deadline);
                }
                if Pin::new(t).poll(cx).is_ready() {
                    c.timer = None;
                    if c.q.timeout().is_some_and(|d| d.is_zero()) {
                        fire_timeout(c, stats);
                    } else {
                        stats.timeouts_early += 1;
                    }
                    more = true;
                }
            }
            None => c.timer = None,
        }
    }
    for s in new_requests {
        e.pending.push_back(s);
        notify(h, K_REQUEST, s);
    }
    more
}

fn fire_timeout(c: &mut Conn, stats: &mut Stats) {
    if std::env::var_os("HS_QUICHE_DEBUG").is_some() {
        eprintln!("quiche timeout: closed {} draining {} established {}", c.q.is_closed(), c.q.is_draining(), c.q.is_established());
    }
    c.q.on_timeout();
    c.timer = None;
    stats.timeouts_fired += 1;
}

fn send_stream(h3: &mut quiche::h3::Connection, q: &mut quiche::Connection, id: u64, s: i64, stats: &mut Stats) {
    let Some((respond, out, fin)) = with_stream(s, |st| (st.respond.take(), st.out.take(), st.fin_pending && !st.finished)) else { return };
    if let Some((status, streaming)) = respond {
        let headers = vec![quiche::h3::Header::new(b":status", status.to_string().as_bytes())];
        if h3.send_response(q, id, &headers, !streaming).is_err() {
            with_stream(s, |st| st.respond = Some((status, streaming)));
            if let Some(o) = out {
                with_stream(s, |st| st.out = Some(o));
            }
            return;
        }
        if !streaming {
            with_stream(s, |st| st.finished = true);
            return;
        }
    }
    if let Some(chunk) = out {
        match h3.send_body(q, id, &chunk, false) {
            Ok(n) if n == chunk.len() => {
                with_stream(s, |st| st.sent += n as u64);
                notify(s, K_SEND, 0);
            }
            Ok(n) => {
                with_stream(s, |st| {
                    st.sent += n as u64;
                    st.out = Some(chunk[n..].to_vec());
                });
                stats.send_blocked += 1;
                return;
            }
            Err(_) => {
                with_stream(s, |st| st.out = Some(chunk));
                stats.send_blocked += 1;
                return;
            }
        }
    }
    if fin && h3.send_body(q, id, b"", true).is_ok() {
        with_stream(s, |st| st.finished = true);
    }
}

fn send_to(fd: i32, pkt: &[u8], to: SocketAddr, cx: &mut Context<'_>, stats: &mut Stats) -> bool {
    let SocketAddr::V4(v4) = to else { return false };
    let mut addr: libc::sockaddr_in = unsafe { std::mem::zeroed() };
    addr.sin_family = libc::AF_INET as u16;
    addr.sin_port = v4.port().to_be();
    addr.sin_addr.s_addr = u32::from(*v4.ip()).to_be();
    let n = unsafe {
        libc::sendto(fd, pkt.as_ptr().cast(), pkt.len(), 0, (&addr as *const libc::sockaddr_in).cast(), std::mem::size_of::<libc::sockaddr_in>() as u32)
    };
    if n < 0 {
        if std::io::Error::last_os_error().kind() == std::io::ErrorKind::WouldBlock {
            io::park(fd, io::WRITE, cx.waker());
        }
        return false;
    }
    stats.datagrams_out += 1;
    true
}
