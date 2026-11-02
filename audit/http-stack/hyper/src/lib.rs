//! hs_hyper -- Hyper 1.x (HTTP/1.1 and HTTP/2, client and server) under
//! the Botlish event loop, with no Tokio runtime
//! (HTTP-STACK-INTEGRATION-CENSUS.md, "Hyper integration").
//!
//! Every protocol object is a bridge task: connection drivers, HTTP/2
//! streams Hyper spawns, per-exchange body pumps. Botlish holds handles
//! (one generation-checked table for every kind) and moves body bytes in
//! chunks through `body::Recv` and `body::Outgoing`. Application logic --
//! what a server answers, what a client reads and how fast -- is the
//! Botlish program's: a server request arrives as an exchange handle a
//! Botlish coroutine answers.

pub mod body;
pub mod iox;
pub mod rt;

use body::{Outgoing, Recv, Shared, Slot, K_ERROR, K_HEAD, K_READY, K_REQUEST};
use bytes::Bytes;
use hs_bridge::ffi::{ERR_CANCELLED, ERR_PROTOCOL, ERR_STALE};
use hs_bridge::notices::notify;
use hs_bridge::slab::Slab;
use hs_bridge::TaskKey;
use hyper::body::Incoming;
use hyper::{Request, Response};
use iox::{BoxStream, FdStream};
use std::cell::RefCell;
use std::collections::VecDeque;
use std::future::Future;
use std::pin::Pin;
use std::rc::Rc;
use std::sync::{Arc, Mutex};
use std::task::{Poll, Waker};

/// Fault injection (the lifetime probe's negative control): releasing an
/// object does not cancel its tasks.
pub const FAULT_RELEASE_LEAKS_TASKS: u32 = 128;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Proto {
    H1,
    H2,
}

impl Proto {
    pub fn of(code: i64) -> Proto {
        if code == 2 {
            Proto::H2
        } else {
            Proto::H1
        }
    }
}

/// How a connection's byte stream is made from its descriptor: plaintext,
/// or a TLS handshake (hs_tls), which may pick the protocol by ALPN.
pub type Wrap = Rc<dyn Fn(FdStream) -> Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>>>;

pub struct Settings {
    /// HTTP/2 initial stream window (bytes); None: Hyper's default.
    pub h2_window: Option<u32>,
    /// HTTP/2 keep-alive interval (microseconds of the Botlish clock).
    pub h2_keepalive_us: Option<u64>,
}

thread_local! {
    static SETTINGS: RefCell<Settings> = const { RefCell::new(Settings { h2_window: None, h2_keepalive_us: None }) };
}

pub fn configure(h2_window: Option<u32>, h2_keepalive_us: Option<u64>) {
    SETTINGS.with(|s| *s.borrow_mut() = Settings { h2_window, h2_keepalive_us });
}

enum Sender {
    H1(hyper::client::conn::http1::SendRequest<Outgoing>),
    H2(hyper::client::conn::http2::SendRequest<Outgoing>),
}

pub struct Respond {
    response: Option<Response<Outgoing>>,
    waker: Option<Waker>,
}

pub struct Exchange {
    pub conn: i64,
    pub status: i64,
    pub method: String,
    pub path: String,
    pub head: bool,
    pub error: i64,
    pub recv: Shared<Recv>,
    pub send: Option<Shared<Slot>>,
    respond: Option<Shared<Respond>>,
    tasks: Vec<TaskKey>,
}

pub struct Client {
    proto: Proto,
    sender: Option<Sender>,
    error: i64,
    task: Option<TaskKey>,
    driver: Option<TaskKey>,
    exchanges: Vec<i64>,
    pub negotiated: Option<Proto>,
}

pub struct Server {
    proto: Proto,
    wrap: Option<Wrap>,
    pending: VecDeque<i64>,
    accept: Option<TaskKey>,
    pub accepted: u64,
    conns: Vec<i64>,
}

/// An accept loop: the authority to take connections from a listening
/// socket for a server. Releasing it closes the socket; the connections
/// already accepted are their own objects and live on.
pub struct Listener {
    #[allow(dead_code)]
    server: i64,
    task: Option<TaskKey>,
}

pub struct Conn {
    server: i64,
    task: Option<TaskKey>,
    pub error: i64,
    pub negotiated: Option<Proto>,
}

pub enum Object {
    Client(Client),
    Server(Server),
    Listener(Listener),
    Conn(Conn),
    Exchange(Exchange),
}

thread_local! {
    pub static OBJECTS: RefCell<Slab<Object>> = RefCell::new(Slab::default());
}

pub fn reset() {
    let all = OBJECTS.with(|o| std::mem::take(&mut *o.borrow_mut()));
    drop(all);
}

fn insert(o: Object) -> i64 {
    OBJECTS.with(|t| t.borrow_mut().insert(o))
}

pub fn with<R>(h: i64, f: impl FnOnce(&mut Object) -> R) -> Option<R> {
    OBJECTS.with(|t| t.borrow_mut().get_mut(h).map(f))
}

pub fn with_exchange<R>(h: i64, f: impl FnOnce(&mut Exchange) -> R) -> Option<R> {
    with(h, |o| match o {
        Object::Exchange(e) => Some(f(e)),
        _ => None,
    })
    .flatten()
}

fn new_exchange(conn: i64) -> (i64, Shared<Recv>) {
    let recv = Arc::new(Mutex::new(Recv::default()));
    let h = insert(Object::Exchange(Exchange {
        conn,
        status: 0,
        method: String::new(),
        path: String::new(),
        head: false,
        error: 0,
        recv: recv.clone(),
        send: None,
        respond: None,
        tasks: Vec::new(),
    }));
    (h, recv)
}

fn add_task(h: i64, task: TaskKey) {
    with(h, |o| match o {
        Object::Exchange(e) => e.tasks.push(task),
        Object::Client(c) => c.task = Some(task),
        Object::Conn(c) => c.task = Some(task),
        Object::Server(s) => s.accept = Some(task),
        Object::Listener(l) => l.task = Some(task),
    });
}

fn fail(h: i64, code: i64) {
    wake_waiting();
    with(h, |o| match o {
        Object::Exchange(e) => {
            e.error = code;
            e.recv.lock().unwrap().error = code;
        }
        Object::Client(c) => c.error = code,
        Object::Conn(c) => c.error = code,
        Object::Server(_) | Object::Listener(_) => {}
    });
    notify(h, K_ERROR, code);
}

/// Release a handle: its tasks are cancelled (their futures dropped now),
/// so a Hyper connection closes its stream, an HTTP/2 stream is reset, and
/// later notices for the handle are stale. A client or server-side
/// connection takes its exchanges with it (they fail); a server's
/// listener does not take its accepted connections.
pub fn release(h: i64) -> i64 {
    let Some(o) = OBJECTS.with(|t| t.borrow_mut().remove(h)) else { return ERR_STALE };
    // The stale-completion control: released objects' tasks keep running.
    if hs_bridge::exec::fault() & FAULT_RELEASE_LEAKS_TASKS != 0 {
        std::mem::forget(o);
        return 0;
    }
    let mut cancel = Vec::new();
    let mut fail_exchanges = Vec::new();
    match &o {
        Object::Exchange(e) => {
            cancel.extend(e.tasks.iter().copied());
            if let Some(s) = &e.send {
                s.lock().unwrap().aborted = true;
            }
        }
        Object::Client(c) => {
            cancel.extend(c.task.iter().copied());
            cancel.extend(c.driver.iter().copied());
            fail_exchanges.extend(c.exchanges.iter().copied());
        }
        Object::Conn(c) => cancel.extend(c.task.iter().copied()),
        Object::Server(s) => cancel.extend(s.accept.iter().copied()),
        Object::Listener(l) => cancel.extend(l.task.iter().copied()),
    }
    for t in cancel {
        hs_bridge::exec::cancel(t);
    }
    // The connection is gone: its exchanges cannot complete.
    for x in fail_exchanges {
        if with_exchange(x, |_| ()).is_some() {
            fail(x, ERR_CANCELLED);
        }
    }
    drop(o);
    0
}

// ---------------------------------------------------------------- client

/// Start a client connection over STREAM (made by WRAP from FD, or given).
pub fn client(proto: Proto, make: Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>>) -> i64 {
    let h = insert(Object::Client(Client {
        proto,
        sender: None,
        error: 0,
        task: None,
        driver: None,
        exchanges: Vec::new(),
        negotiated: None,
    }));
    let task = hs_bridge::spawn("client-connect", async move {
        let (stream, alpn) = match make.await {
            Ok(x) => x,
            Err(code) => return fail(h, code),
        };
        let proto = alpn.unwrap_or(proto);
        let (window, keepalive) = SETTINGS.with(|s| (s.borrow().h2_window, s.borrow().h2_keepalive_us));
        let driver: Pin<Box<dyn Future<Output = ()>>>;
        let sender = match proto {
            Proto::H1 => match hyper::client::conn::http1::handshake::<_, Outgoing>(stream).await {
                Ok((sender, conn)) => {
                    driver = Box::pin(async move {
                        let _ = conn.await;
                    });
                    Sender::H1(sender)
                }
                Err(_) => return fail(h, ERR_PROTOCOL),
            },
            Proto::H2 => {
                let mut b = hyper::client::conn::http2::Builder::new(rt::Exec);
                b.timer(rt::Timer);
                if let Some(w) = window {
                    b.initial_stream_window_size(w);
                    b.initial_connection_window_size(w.max(65535) * 4);
                }
                if let Some(k) = keepalive {
                    b.keep_alive_interval(std::time::Duration::from_micros(k));
                    b.keep_alive_while_idle(true);
                }
                match b.handshake::<_, Outgoing>(stream).await {
                    Ok((sender, conn)) => {
                        driver = Box::pin(async move {
                            let _ = conn.await;
                        });
                        Sender::H2(sender)
                    }
                    Err(_) => return fail(h, ERR_PROTOCOL),
                }
            }
        };
        let d = hs_bridge::spawn("client-conn", driver);
        let live = with(h, |o| {
            if let Object::Client(c) = o {
                c.sender = Some(sender);
                c.driver = Some(d);
                c.negotiated = Some(proto);
            }
        });
        if live.is_none() {
            hs_bridge::exec::cancel(d);
            return;
        }
        wake_waiting();
        notify(h, K_READY, if proto == Proto::H2 { 2 } else { 1 });
    });
    add_task(h, task);
    h
}

pub fn client_state(h: i64) -> i64 {
    with(h, |o| match o {
        Object::Client(c) if c.error != 0 => c.error,
        Object::Client(c) => match c.negotiated {
            Some(Proto::H2) if c.sender.is_some() => 2,
            Some(Proto::H1) if c.sender.is_some() => 1,
            _ => 0,
        },
        Object::Conn(c) if c.error != 0 => c.error,
        Object::Conn(c) => match c.negotiated {
            Some(Proto::H2) => 2,
            Some(Proto::H1) => 1,
            None => 0,
        },
        _ => ERR_STALE,
    })
    .unwrap_or(ERR_STALE)
}

fn take_sender(client: i64) -> Option<Sender> {
    with(client, |o| match o {
        Object::Client(c) => match &c.sender {
            Some(Sender::H2(s)) => Some(Sender::H2(s.clone())),
            Some(Sender::H1(_)) => c.sender.take(),
            None => None,
        },
        _ => None,
    })
    .flatten()
}

fn put_sender(client: i64, s: Sender) {
    with(client, |o| {
        if let Object::Client(c) = o {
            if let Sender::H1(_) = s {
                c.sender = Some(s);
            }
        }
    });
}

/// Send a request on CLIENT. STREAMING: Botlish sends the request body in
/// chunks (`offer`, `finish`); otherwise it is empty. The exchange handle.
pub fn request(client: i64, method: &str, path: &str, streaming: bool) -> i64 {
    let Some(proto) = with(client, |o| match o {
        Object::Client(c) => c.negotiated.or(Some(c.proto)),
        _ => None,
    })
    .flatten() else {
        return ERR_STALE;
    };
    let (h, recv) = new_exchange(client);
    let body = if streaming {
        let (b, slot) = Outgoing::new(h);
        with_exchange(h, |e| e.send = Some(slot));
        b
    } else {
        Outgoing::full(Bytes::new())
    };
    let uri = match proto {
        Proto::H2 => format!("http://localhost{path}"),
        Proto::H1 => path.to_string(),
    };
    let req = Request::builder().method(method).uri(uri).header("host", "localhost").body(body);
    let Ok(req) = req else {
        let _ = release(h);
        return ERR_PROTOCOL;
    };
    with(client, |o| {
        if let Object::Client(c) = o {
            c.exchanges.push(h)
        }
    });
    let task = hs_bridge::spawn("client-request", async move {
        // Wait for the connection (HTTP/1: for the previous exchange).
        let sender = std::future::poll_fn(|cx| {
            if let Some(s) = take_sender(client) {
                return Poll::Ready(Some(s));
            }
            let gone = with(client, |o| matches!(o, Object::Client(c) if c.error != 0)).unwrap_or(true);
            if gone {
                return Poll::Ready(None);
            }
            // Woken when a client's sender becomes available (the
            // handshake finished, an HTTP/1 exchange gave it back) or the
            // client failed: one waiter list for every client.
            WAITING.with(|w| w.borrow_mut().push(cx.waker().clone()));
            Poll::Pending
        })
        .await;
        let Some(mut sender) = sender else { return fail(h, ERR_CANCELLED) };
        let ready = match &mut sender {
            Sender::H1(s) => s.ready().await.is_ok(),
            Sender::H2(s) => s.ready().await.is_ok(),
        };
        if !ready {
            return fail(h, ERR_PROTOCOL);
        }
        let response = match sender {
            Sender::H1(mut s) => {
                let f = s.send_request(req);
                put_sender(client, Sender::H1(s));
                wake_waiting();
                f.await
            }
            Sender::H2(mut s) => s.send_request(req).await,
        };
        match response {
            Ok(resp) => {
                let status = resp.status().as_u16() as i64;
                let live = with_exchange(h, |e| {
                    e.status = status;
                    e.head = true;
                })
                .is_some();
                if !live {
                    return;
                }
                notify(h, K_HEAD, status);
                body::pump(h, recv, resp.into_body()).await;
            }
            Err(_) => fail(h, ERR_PROTOCOL),
        }
    });
    with_exchange(h, |e| e.tasks.push(task));
    h
}

thread_local! {
    static WAITING: RefCell<Vec<Waker>> = const { RefCell::new(Vec::new()) };
}

/// Wake requests waiting for a client's sender (a connection became
/// ready, or an HTTP/1 sender came back).
pub fn wake_waiting() {
    let w = WAITING.with(|w| std::mem::take(&mut *w.borrow_mut()));
    for w in w {
        w.wake();
    }
}

// ---------------------------------------------------------------- server

pub fn server(proto: Proto, wrap: Option<Wrap>) -> i64 {
    insert(Object::Server(Server {
        proto,
        wrap,
        pending: VecDeque::new(),
        accept: None,
        accepted: 0,
        conns: Vec::new(),
    }))
}

/// Accept connections for SERVER on the nonblocking listening socket FD.
/// The listener's handle: releasing it stops accepting and closes FD.
pub fn listen(server: i64, fd: i32) -> i64 {
    if with(server, |o| matches!(o, Object::Server(_))) != Some(true) {
        return ERR_STALE;
    }
    let listener = insert(Object::Listener(Listener { server, task: None }));
    let task = hs_bridge::spawn("accept", async move {
        let _listener = FdStream::new(fd); // released to Botlish when the loop ends
        loop {
            let accepted = std::future::poll_fn(|cx| {
                let c = unsafe { libc::accept4(fd, std::ptr::null_mut(), std::ptr::null_mut(), libc::SOCK_NONBLOCK | libc::SOCK_CLOEXEC) };
                if c >= 0 {
                    return Poll::Ready(Ok(c));
                }
                let e = std::io::Error::last_os_error();
                if e.kind() == std::io::ErrorKind::WouldBlock {
                    hs_bridge::io::park(fd, hs_bridge::io::READ, cx.waker());
                    return Poll::Pending;
                }
                Poll::Ready(Err(e))
            })
            .await;
            match accepted {
                Ok(c) => {
                    // Small HTTP/2 frames (WINDOW_UPDATE, SETTINGS acks)
                    // must not wait for Nagle: an accepted socket gets
                    // TCP_NODELAY as a connected one does.
                    let one: i32 = 1;
                    unsafe { libc::setsockopt(c, libc::IPPROTO_TCP, libc::TCP_NODELAY, (&one as *const i32).cast(), 4) };
                    let wrap = with(server, |o| match o {
                        Object::Server(s) => {
                            s.accepted += 1;
                            s.wrap.clone()
                        }
                        _ => None,
                    })
                    .flatten();
                    let stream = FdStream::new(c);
                    let make: Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>> = match wrap {
                        Some(w) => w(stream),
                        None => Box::pin(async move { Ok((Box::new(stream) as BoxStream, None)) }),
                    };
                    serve_stream(server, make);
                }
                Err(_) => return,
            }
        }
    });
    add_task(listener, task);
    listener
}

/// Serve one connection of SERVER over the stream MAKE yields; the
/// connection's handle. Each request becomes an exchange queued on the
/// server (`next_request`) and noticed (K_REQUEST).
pub fn serve_stream(server: i64, make: Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>>) -> i64 {
    let Some(proto) = with(server, |o| match o {
        Object::Server(s) => Some(s.proto),
        _ => None,
    })
    .flatten() else {
        return ERR_STALE;
    };
    let conn = insert(Object::Conn(Conn { server, task: None, error: 0, negotiated: None }));
    with(server, |o| {
        if let Object::Server(s) = o {
            s.conns.push(conn)
        }
    });
    let task = hs_bridge::spawn("server-conn", async move {
        let (stream, alpn) = match make.await {
            Ok(x) => x,
            Err(code) => return fail(conn, code),
        };
        let proto = alpn.unwrap_or(proto);
        with(conn, |o| {
            if let Object::Conn(c) = o {
                c.negotiated = Some(proto)
            }
        });
        let service = hyper::service::service_fn(move |req: Request<Incoming>| {
            let (h, recv) = new_exchange(conn);
            let respond = Arc::new(Mutex::new(Respond { response: None, waker: None }));
            with_exchange(h, |e| {
                e.method = req.method().to_string();
                e.path = req.uri().path().to_string();
                e.head = true;
                e.respond = Some(respond.clone());
            });
            let pump = hs_bridge::spawn("server-recv", body::pump(h, recv, req.into_body()));
            with_exchange(h, |e| e.tasks.push(pump));
            let queued = with(server, |o| match o {
                Object::Server(s) => {
                    s.pending.push_back(h);
                    true
                }
                _ => false,
            });
            if queued == Some(true) {
                notify(server, K_REQUEST, h);
            }
            async move {
                let response = std::future::poll_fn(|cx| {
                    let mut r = respond.lock().unwrap();
                    match r.response.take() {
                        Some(x) => Poll::Ready(x),
                        None => {
                            r.waker = Some(cx.waker().clone());
                            Poll::Pending
                        }
                    }
                })
                .await;
                Ok::<_, std::convert::Infallible>(response)
            }
        });
        let (window, keepalive) = SETTINGS.with(|s| (s.borrow().h2_window, s.borrow().h2_keepalive_us));
        let result = match proto {
            Proto::H1 => {
                let mut b = hyper::server::conn::http1::Builder::new();
                b.timer(rt::Timer);
                b.serve_connection(stream, service).await
            }
            Proto::H2 => {
                let mut b = hyper::server::conn::http2::Builder::new(rt::Exec);
                b.timer(rt::Timer);
                if let Some(w) = window {
                    b.initial_stream_window_size(w);
                    b.initial_connection_window_size(w.max(65535) * 4);
                }
                if let Some(k) = keepalive {
                    b.keep_alive_interval(std::time::Duration::from_micros(k));
                }
                b.serve_connection(stream, service).await
            }
        };
        if result.is_err() {
            fail(conn, ERR_PROTOCOL);
        }
    });
    add_task(conn, task);
    conn
}

/// The next request SERVER received (an exchange handle), or 0.
pub fn next_request(server: i64) -> i64 {
    with(server, |o| match o {
        Object::Server(s) => s.pending.pop_front().unwrap_or(0),
        _ => ERR_STALE,
    })
    .unwrap_or(ERR_STALE)
}

/// Answer server exchange H with STATUS; STREAMING: the body follows in
/// chunks (`offer`, `finish`), else it is empty.
pub fn respond(h: i64, status: u16, streaming: bool) -> i64 {
    let Some(respond) = with_exchange(h, |e| e.respond.take()).flatten() else { return ERR_STALE };
    let body = if streaming {
        let (b, slot) = Outgoing::new(h);
        with_exchange(h, |e| e.send = Some(slot));
        b
    } else {
        Outgoing::full(Bytes::new())
    };
    let Ok(response) = Response::builder().status(status).body(body) else { return ERR_PROTOCOL };
    let mut r = respond.lock().unwrap();
    r.response = Some(response);
    if let Some(w) = r.waker.take() {
        w.wake();
    }
    0
}

/// Offer a chunk of H's outgoing body: bytes accepted, 0 when the slot is
/// full (wait for a K_SEND notice).
pub fn offer(h: i64, data: Bytes) -> i64 {
    match with_exchange(h, |e| e.send.clone()).flatten() {
        Some(slot) => body::offer(&slot, data),
        None => ERR_STALE,
    }
}

pub fn finish(h: i64) -> i64 {
    match with_exchange(h, |e| e.send.clone()).flatten() {
        Some(slot) => {
            body::finish(&slot);
            0
        }
        None => ERR_STALE,
    }
}

pub fn exchange_status(h: i64) -> i64 {
    with_exchange(h, |e| if e.error != 0 { e.error } else if e.head { e.status.max(1) } else { 0 }).unwrap_or(ERR_STALE)
}

/// Copy up to CAP bytes of H's incoming body into DST (see Recv::take).
///
/// # Safety
/// DST valid for CAP bytes of writes during this call.
pub unsafe fn recv(h: i64, dst: *mut u8, cap: usize) -> i64 {
    match with_exchange(h, |e| e.recv.clone()) {
        Some(r) => r.lock().unwrap().take(dst, cap),
        None => ERR_STALE,
    }
}

/// Counters of H: 0 received bytes, 1 received chunks, 2 bytes taken by
/// Botlish, 3 bytes accepted for sending, 4 bytes Hyper took to send,
/// 5 chunks buffered now (receive side), 6 HTTP status.
pub fn exchange_stat(h: i64, i: i32) -> i64 {
    with_exchange(h, |e| {
        let r = e.recv.lock().unwrap();
        let s = e.send.as_ref().map(|s| {
            let s = s.lock().unwrap();
            (s.accepted, s.taken)
        });
        match i {
            0 => r.bytes as i64,
            1 => r.chunk_count as i64,
            2 => r.taken as i64,
            3 => s.map(|x| x.0 as i64).unwrap_or(0),
            4 => s.map(|x| x.1 as i64).unwrap_or(0),
            5 => r.chunks.len() as i64,
            6 => e.status,
            7 => r.max_buffered as i64,
            _ => -1,
        }
    })
    .unwrap_or(ERR_STALE)
}

/// The path (and method) of server exchange H, copied into DST.
///
/// # Safety
/// DST valid for CAP bytes of writes.
pub unsafe fn exchange_path(h: i64, dst: *mut u8, cap: usize) -> i64 {
    match with_exchange(h, |e| format!("{} {}", e.method, e.path)) {
        Some(s) => hs_bridge::ffi::copy_out(s.as_bytes(), dst, cap) as i64,
        None => ERR_STALE,
    }
}

pub fn object_count() -> usize {
    OBJECTS.with(|o| o.borrow().len())
}

/// Server SERVER's live connections (a listener's release leaves them).
pub fn server_conns(server: i64) -> i64 {
    with(server, |o| match o {
        Object::Server(s) => s.conns.iter().filter(|c| with(**c, |_| ()).is_some()).count() as i64,
        _ => ERR_STALE,
    })
    .unwrap_or_else(|| {
        // A released server: count connections that still name it.
        OBJECTS.with(|t| {
            let t = t.borrow();
            t.handles().iter().filter(|h| matches!(t.get(**h), Some(Object::Conn(c)) if c.server == server)).count() as i64
        })
    })
}

/// Plaintext stream factory for FD.
pub fn plain(fd: i32) -> Pin<Box<dyn Future<Output = Result<(BoxStream, Option<Proto>), i64>>>> {
    Box::pin(async move { Ok((Box::new(FdStream::new(fd)) as BoxStream, None)) })
}

/// In-memory connection pair (deterministic driver): a client of CLIENT
/// proto and a connection served by SERVER. The client handle.
pub fn mem_pair(server: i64, proto: Proto, capacity: usize) -> i64 {
    let (a, b) = iox::mem_pair(capacity);
    serve_stream(server, Box::pin(async move { Ok((Box::new(b) as BoxStream, None)) }));
    client(proto, Box::pin(async move { Ok((Box::new(a) as BoxStream, None)) }))
}
