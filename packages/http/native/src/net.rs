//! Transport: name resolution and TCP connection establishment.
//!
//! * Resolution (`resolve`) is `getaddrinfo`, which blocks, so it never runs
//!   on the loop thread (HTTP-SHIPPING-CENSUS.md's B12): a bounded pool of
//!   worker threads (at most `WORKERS`, started on demand) takes jobs from
//!   one queue, runs `getaddrinfo` and nothing else, stores the answer in
//!   the job's slot and wakes the waiting task -- a foreign wake, which the
//!   bridge turns into one record posted through the event loop's
//!   integration ABI. A worker never touches the executor, a handle or
//!   Botlish. A job whose task was cancelled still runs (getaddrinfo cannot
//!   be interrupted); its answer is dropped, and its wake is stale. The
//!   queue is bounded (`QUEUE_LIMIT`): a resolution beyond it fails at once.
//!   `shutdown` (the bridge's close) drops the queued jobs and tells the
//!   workers to end after the job they run; `outstanding` counts the jobs
//!   not yet answered.
//! * Literal IPv4 and IPv6 hosts are never resolved.
//! * Connection (`connect`) tries the candidates in the order
//!   `getaddrinfo` returned them (RFC 6724's order), one at a time: a
//!   nonblocking `connect`, readiness through the bridge, `SO_ERROR`. A
//!   refused or unreachable candidate gives way to the next; the first
//!   success wins; when all fail, the last failure is reported. The whole
//!   phase is bounded by the client's connect timeout (`client.rs`). This is
//!   sequential fallback, not Happy Eyeballs (RFC 8305): documented.

use crate::bridge::io;
use std::collections::VecDeque;
use std::ffi::{CStr, CString};
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6};
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::{Arc, Condvar, Mutex, OnceLock};
use std::task::{Poll, Waker};

pub const WORKERS: usize = 4;
pub const QUEUE_LIMIT: usize = 256;

/// Why name resolution failed: getaddrinfo's EAI code and its text.
#[derive(Clone, Debug)]
pub struct ResolveError {
    pub code: i64,
    pub text: String,
}

/// Why connecting failed: the last candidate's errno, its text, and the
/// address tried.
#[derive(Clone, Debug)]
pub struct ConnectError {
    pub code: i64,
    pub text: String,
    pub addr: Option<SocketAddr>,
}

type Answer = Result<Vec<SocketAddr>, ResolveError>;

#[derive(Default)]
struct JobState {
    answer: Option<Answer>,
    waker: Option<Waker>,
}

struct Job {
    host: String,
    port: u16,
    state: Arc<Mutex<JobState>>,
}

struct Pool {
    queue: Mutex<VecDeque<Job>>,
    ready: Condvar,
    workers: AtomicUsize,
    idle: AtomicUsize,
    stop: AtomicBool,
    outstanding: AtomicUsize,
    started: AtomicUsize,
}

fn pool() -> &'static Pool {
    static POOL: OnceLock<Pool> = OnceLock::new();
    POOL.get_or_init(|| Pool {
        queue: Mutex::new(VecDeque::new()),
        ready: Condvar::new(),
        workers: AtomicUsize::new(0),
        idle: AtomicUsize::new(0),
        stop: AtomicBool::new(false),
        outstanding: AtomicUsize::new(0),
        started: AtomicUsize::new(0),
    })
}

/// Jobs queued or running whose answer has not been stored yet.
pub fn outstanding() -> usize {
    pool().outstanding.load(Ordering::Relaxed)
}

/// Worker threads alive now, and started in total.
pub fn workers() -> (usize, usize) {
    let p = pool();
    (p.workers.load(Ordering::Relaxed), p.started.load(Ordering::Relaxed))
}

/// The bridge opened: workers may run again.
pub fn open() {
    pool().stop.store(false, Ordering::Release);
}

/// The bridge closed: queued jobs are dropped (their tasks are gone), and
/// every worker ends once its current job is answered.
pub fn shutdown() {
    let p = pool();
    p.stop.store(true, Ordering::Release);
    let dropped = std::mem::take(&mut *p.queue.lock().unwrap());
    p.outstanding.fetch_sub(dropped.len(), Ordering::Relaxed);
    p.ready.notify_all();
}

fn worker() {
    let p = pool();
    loop {
        let job = {
            let mut q = p.queue.lock().unwrap();
            loop {
                if p.stop.load(Ordering::Acquire) {
                    p.workers.fetch_sub(1, Ordering::Relaxed);
                    return;
                }
                if let Some(job) = q.pop_front() {
                    break job;
                }
                p.idle.fetch_add(1, Ordering::Relaxed);
                q = p.ready.wait(q).unwrap();
                p.idle.fetch_sub(1, Ordering::Relaxed);
            }
        };
        let answer = getaddrinfo(&job.host, job.port);
        let waker = {
            let mut s = job.state.lock().unwrap();
            s.answer = Some(answer);
            s.waker.take()
        };
        p.outstanding.fetch_sub(1, Ordering::Relaxed);
        // A foreign wake: the bridge posts a record to the loop (exec.rs).
        if let Some(w) = waker {
            w.wake();
        }
    }
}

fn submit(job: Job) -> Result<(), ResolveError> {
    let p = pool();
    let mut q = p.queue.lock().unwrap();
    if q.len() >= QUEUE_LIMIT {
        return Err(ResolveError { code: -1, text: "too many name resolutions are pending".into() });
    }
    q.push_back(job);
    p.outstanding.fetch_add(1, Ordering::Relaxed);
    let need_worker = p.idle.load(Ordering::Relaxed) == 0 && p.workers.load(Ordering::Relaxed) < WORKERS;
    drop(q);
    if need_worker {
        p.workers.fetch_add(1, Ordering::Relaxed);
        p.started.fetch_add(1, Ordering::Relaxed);
        let spawned = std::thread::Builder::new().name("botlish-http-resolve".into()).stack_size(256 * 1024).spawn(worker);
        if spawned.is_err() {
            p.workers.fetch_sub(1, Ordering::Relaxed);
        }
    }
    p.ready.notify_one();
    Ok(())
}

/// A literal address of HOST (IPv4 dotted quad, or IPv6 without brackets).
pub fn literal(host: &str) -> Option<IpAddr> {
    host.parse::<IpAddr>().ok()
}

/// The candidate addresses of HOST:PORT. A literal answers at once.
pub async fn resolve(host: &str, port: u16) -> Result<Vec<SocketAddr>, ResolveError> {
    if let Some(ip) = literal(host) {
        return Ok(vec![SocketAddr::new(ip, port)]);
    }
    let state = Arc::new(Mutex::new(JobState::default()));
    submit(Job { host: host.to_string(), port, state: state.clone() })?;
    std::future::poll_fn(|cx| {
        let mut s = state.lock().unwrap();
        match s.answer.take() {
            Some(a) => Poll::Ready(a),
            None => {
                s.waker = Some(cx.waker().clone());
                Poll::Pending
            }
        }
    })
    .await
}

fn getaddrinfo(host: &str, port: u16) -> Answer {
    let Ok(node) = CString::new(host) else {
        return Err(ResolveError { code: libc::EAI_NONAME as i64, text: "the host name holds a NUL".into() });
    };
    let service = CString::new(port.to_string()).unwrap();
    let mut hints: libc::addrinfo = unsafe { std::mem::zeroed() };
    hints.ai_family = libc::AF_UNSPEC;
    hints.ai_socktype = libc::SOCK_STREAM;
    hints.ai_protocol = libc::IPPROTO_TCP;
    hints.ai_flags = libc::AI_ADDRCONFIG | libc::AI_NUMERICSERV;
    let mut res: *mut libc::addrinfo = std::ptr::null_mut();
    let rc = unsafe { libc::getaddrinfo(node.as_ptr(), service.as_ptr(), &hints, &mut res) };
    if rc != 0 {
        let text = unsafe { CStr::from_ptr(libc::gai_strerror(rc)) }.to_string_lossy().into_owned();
        let text = if rc == libc::EAI_SYSTEM {
            format!("{text}: {}", std::io::Error::last_os_error())
        } else {
            text
        };
        return Err(ResolveError { code: rc as i64, text });
    }
    let mut out = Vec::new();
    let mut cur = res;
    while !cur.is_null() {
        let ai = unsafe { &*cur };
        if let Some(addr) = unsafe { sockaddr(ai.ai_addr, ai.ai_addrlen) } {
            if !out.contains(&addr) {
                out.push(addr);
            }
        }
        cur = ai.ai_next;
    }
    unsafe { libc::freeaddrinfo(res) };
    if out.is_empty() {
        return Err(ResolveError { code: libc::EAI_NONAME as i64, text: "no address of a supported family".into() });
    }
    Ok(out)
}

/// # Safety
/// SA points to LEN bytes of a socket address getaddrinfo returned.
unsafe fn sockaddr(sa: *const libc::sockaddr, len: libc::socklen_t) -> Option<SocketAddr> {
    if sa.is_null() {
        return None;
    }
    match (*sa).sa_family as i32 {
        libc::AF_INET if len as usize >= std::mem::size_of::<libc::sockaddr_in>() => {
            let a = &*(sa as *const libc::sockaddr_in);
            let ip = Ipv4Addr::from(u32::from_be(a.sin_addr.s_addr));
            Some(SocketAddr::V4(SocketAddrV4::new(ip, u16::from_be(a.sin_port))))
        }
        libc::AF_INET6 if len as usize >= std::mem::size_of::<libc::sockaddr_in6>() => {
            let a = &*(sa as *const libc::sockaddr_in6);
            let ip = Ipv6Addr::from(a.sin6_addr.s6_addr);
            Some(SocketAddr::V6(SocketAddrV6::new(ip, u16::from_be(a.sin6_port), a.sin6_flowinfo, a.sin6_scope_id)))
        }
        _ => None,
    }
}

fn errno() -> i64 {
    std::io::Error::last_os_error().raw_os_error().unwrap_or(libc::EIO) as i64
}

fn os_text(code: i64) -> String {
    std::io::Error::from_raw_os_error(code as i32).to_string()
}

/// A connected stream's descriptor, owned until the stream takes it over:
/// dropped, it is released to Botlish (unwatched, then closed).
pub struct Socket {
    fd: i32,
}

impl Socket {
    /// Hand the descriptor to a stream (which releases it when dropped).
    pub fn into_fd(self) -> i32 {
        let fd = self.fd;
        std::mem::forget(self);
        fd
    }
}

impl Drop for Socket {
    fn drop(&mut self) {
        io::release(self.fd);
    }
}

fn open_socket(addr: &SocketAddr) -> Result<Socket, ConnectError> {
    let family = if addr.is_ipv4() { libc::AF_INET } else { libc::AF_INET6 };
    let fd = unsafe { libc::socket(family, libc::SOCK_STREAM | libc::SOCK_NONBLOCK | libc::SOCK_CLOEXEC, 0) };
    if fd < 0 {
        let code = errno();
        return Err(ConnectError { code, text: os_text(code), addr: Some(*addr) });
    }
    // Small HTTP/2 frames (WINDOW_UPDATE, SETTINGS acks) must not wait for
    // Nagle.
    let one: libc::c_int = 1;
    unsafe {
        libc::setsockopt(fd, libc::IPPROTO_TCP, libc::TCP_NODELAY, (&one as *const libc::c_int).cast(), 4);
    }
    Ok(Socket { fd })
}

fn start_connect(sock: &Socket, addr: &SocketAddr) -> Result<bool, i64> {
    let rc = unsafe {
        match addr {
            SocketAddr::V4(a) => {
                let mut sin: libc::sockaddr_in = std::mem::zeroed();
                sin.sin_family = libc::AF_INET as libc::sa_family_t;
                sin.sin_port = a.port().to_be();
                sin.sin_addr = libc::in_addr { s_addr: u32::from(*a.ip()).to_be() };
                libc::connect(sock.fd, (&sin as *const libc::sockaddr_in).cast(), std::mem::size_of::<libc::sockaddr_in>() as u32)
            }
            SocketAddr::V6(a) => {
                let mut sin6: libc::sockaddr_in6 = std::mem::zeroed();
                sin6.sin6_family = libc::AF_INET6 as libc::sa_family_t;
                sin6.sin6_port = a.port().to_be();
                sin6.sin6_addr = libc::in6_addr { s6_addr: a.ip().octets() };
                sin6.sin6_flowinfo = a.flowinfo();
                sin6.sin6_scope_id = a.scope_id();
                libc::connect(sock.fd, (&sin6 as *const libc::sockaddr_in6).cast(), std::mem::size_of::<libc::sockaddr_in6>() as u32)
            }
        }
    };
    if rc == 0 {
        return Ok(true);
    }
    let e = errno();
    if e == libc::EINPROGRESS as i64 || e == libc::EINTR as i64 {
        return Ok(false);
    }
    Err(e)
}

fn socket_error(fd: i32) -> i64 {
    let mut err: libc::c_int = 0;
    let mut len = std::mem::size_of::<libc::c_int>() as libc::socklen_t;
    let rc = unsafe { libc::getsockopt(fd, libc::SOL_SOCKET, libc::SO_ERROR, (&mut err as *mut libc::c_int).cast(), &mut len) };
    if rc != 0 {
        return errno();
    }
    err as i64
}

fn connected(fd: i32) -> bool {
    let mut ss: libc::sockaddr_storage = unsafe { std::mem::zeroed() };
    let mut len = std::mem::size_of::<libc::sockaddr_storage>() as libc::socklen_t;
    unsafe { libc::getpeername(fd, (&mut ss as *mut libc::sockaddr_storage).cast(), &mut len) == 0 }
}

async fn connect_one(addr: SocketAddr) -> Result<Socket, ConnectError> {
    let sock = open_socket(&addr)?;
    match start_connect(&sock, &addr) {
        Ok(true) => return Ok(sock),
        Ok(false) => {}
        Err(code) => return Err(ConnectError { code, text: os_text(code), addr: Some(addr) }),
    }
    let fd = sock.fd;
    let mut armed = false;
    std::future::poll_fn(|cx| {
        if armed {
            // Woken: the watch fired (writable, hung up, in error) -- or
            // something else of this task's did (a timer), so the socket's
            // state is asked, never assumed. SO_ERROR reports a failure;
            // getpeername says whether the connection is established.
            let e = socket_error(fd);
            if e != 0 && e != libc::EINPROGRESS as i64 && e != libc::EALREADY as i64 {
                return Poll::Ready(Err(e));
            }
            if connected(fd) {
                return Poll::Ready(Ok(()));
            }
        }
        armed = true;
        io::park(fd, io::WRITE, cx.waker());
        Poll::Pending
    })
    .await
    .map_err(|code| ConnectError { code, text: os_text(code), addr: Some(addr) })?;
    Ok(sock)
}

/// Connect to the first of ADDRS that accepts.
pub async fn connect(addrs: &[SocketAddr]) -> Result<Socket, ConnectError> {
    let mut last = ConnectError { code: libc::EHOSTUNREACH as i64, text: "no address to connect to".into(), addr: None };
    for addr in addrs {
        match connect_one(*addr).await {
            Ok(s) => return Ok(s),
            Err(e) => last = e,
        }
    }
    Err(last)
}
