//! Botlish-owned threads and the cross-thread transport
//! (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md;
//! stdlib/thread.bot, stdlib/actor/remote.bot, core/thread.tcl).
//!
//! THREADS. A Botlish thread is an OS thread running one VM of the
//! program: `spawn` reserves a stack-overflow guard record (records.rs:
//! the 64-record table; never an unguarded thread), registers the thread
//! and starts it; the thread installs its guard, makes its VM *on itself*
//! from the program's factory (the image's read-only code and metadata,
//! shared; its own heap, constants' objects, statics, context area), and
//! runs the program function with the entry index and initialization bytes
//! the start gave (native/lower.tcl's thread dispatch). Its outcome --
//! the entry's result bytes, its failure's identity and message, or the
//! reason it never started -- stays in the registry until the joining VM
//! collects it (`release`); a VM is dropped on its own thread, before the
//! thread reports its end, and never moves. Stopping is cooperative: a
//! flag the thread reads and a wakeup of its port; nothing interrupts or
//! kills a thread. The registry is one mutex-guarded table, held only for
//! registry operations, never while Botlish code runs.
//!
//! PORTS. A VM that takes part in the transport has one port: a doorbell
//! (an eventfd, which its event loop watches through std::thread's Doorbell
//! trait) and a queue of notifications -- a message waiting on one of its
//! endpoints, room freed on an endpoint one of its senders waits for, a
//! thread it started has ended, a stop request. A producer pushes, then
//! rings; the consumer resets the doorbell before its last check of the
//! queue (`port_take`), so no notification is ever missed and none is
//! polled for.
//!
//! ENDPOINTS AND CALLS. An endpoint is a bounded queue of transfer bytes
//! owned by one port, named across VMs by (domain, slot, generation, key):
//! the domain is this process's random identity, the key a random 64-bit
//! word drawn when the endpoint opens, so an identity no endpoint gave out
//! names nothing (a sparse capability), and a reused slot's new generation
//! refuses an old identity. Every message's bytes carry their transfer
//! schema's fingerprint, compared with the endpoint's before it is queued.
//! A call is a message whose reply is routed back to the caller's reply
//! endpoint through a call record of this table (slot, generation, key):
//! it completes once -- with the service's reply, or with the failure the
//! transport observed (the request undelivered when its endpoint closed,
//! the service's VM ended owing it) -- and a reply to a completed,
//! cancelled or unknown call is stale. Nothing here holds a Botlish heap
//! object: messages are owned byte vectors, rebuilt by the receiving VM
//! (std::transfer).
use super::aot::ProgramEntry;
use super::error::RtError;
use super::value::*;
use super::vm::Vm;
use std::collections::VecDeque;
use std::sync::atomic::{AtomicBool, AtomicI64, Ordering};
use std::sync::{Arc, Condvar, Mutex, MutexGuard, Weak};

/// What makes a fresh Vm of the running program on the calling thread, with
/// its entry: shared by every thread of the program (a linked program's
/// record, the JIT's compiled image).
pub type VmFactory = dyn Fn() -> Result<(Box<Vm>, ProgramEntry), String> + Send + Sync;

/// The factory of the linked program LINKED (an executable's record): each
/// call makes a Vm of it on the calling thread (`program::instantiate_linked`).
pub fn linked_factory(linked: &'static super::program::LinkedProgram) -> Arc<VmFactory> {
    Arc::new(move || {
        // SAFETY: LINKED is the executable's own relocated record, valid for
        // the process's life.
        unsafe { super::program::instantiate_linked(linked) }
    })
}

/// A Vm's own part in threads and the transport: which entry it runs, its
/// initialization bytes, its thread's record, its port and what it took.
#[derive(Default)]
pub struct VmThread {
    /// What makes another Vm of this program (None: no thread can start,
    /// e.g. a native library's instance).
    pub factory: Option<Arc<VmFactory>>,
    /// The entry this Vm runs: 0 the entry program's, K the K-th thread
    /// entry's (1-based).
    pub entry: u32,
    pub init: Vec<u8>,
    /// This Vm's thread's record (a worker's).
    pub record: Option<Arc<Shared>>,
    /// The threads this Vm started that it has not released.
    pub children: Vec<u64>,
    port: Option<Arc<Port>>,
    /// The message `take` made current, and the notification `port_take`
    /// made current.
    current: Option<Message>,
    notice: (i64, i64),
}

impl VmThread {
    /// Closes this Vm's port, if it has one: its endpoints close (their
    /// queued messages are dropped and counted, the calls among them fail),
    /// the calls it took and owes fail with ServiceEnded, and every sender
    /// waiting for room on them is woken. What a Vm's end does.
    pub fn close_port(&mut self) {
        if let Some(port) = self.port.take() {
            close_port(&port);
        }
        self.current = None;
    }
}

// ---------------------------------------------------------------------------
// Statuses and codes (core/thread.tcl, stdlib/thread.bot)

const ST_STARTING: i64 = 0;
const ST_RUNNING: i64 = 1;
const ST_RETURNED: i64 = 2;
const ST_STOPPED: i64 = 3;
const ST_FAILED: i64 = 4;
const ST_START_FAILED: i64 = 5;
const ST_GONE: i64 = -1;

/// Transport results (stdlib/actor/remote.bot's codes).
const T_DELIVERED: i64 = 0;
const T_FULL: i64 = -1;
const T_CLOSED: i64 = -2;
const T_STALE: i64 = -3;
const T_UNAVAILABLE: i64 = -4;
const T_TOO_LARGE: i64 = -5;
const T_TYPE_MISMATCH: i64 = -6;
const T_NO_PORT: i64 = -7;
const T_SERVICE_ENDED: i64 = -8;
const T_UNDELIVERED: i64 = -9;
const T_MALFORMED: i64 = -10;

/// Port notification kinds.
const N_MESSAGE: i64 = 1;
const N_ROOM: i64 = 2;
const N_ENDED: i64 = 3;
const N_STOP: i64 = 4;

/// The largest message the transport takes (its encoded bytes).
const MAX_MESSAGE: usize = 64 << 20;
/// The most bytes one endpoint holds queued.
const MAX_QUEUED_BYTES: usize = 256 << 20;
/// Slot bits of an id: id = generation << SLOT_BITS | slot.
const SLOT_BITS: u32 = 20;
const SLOT_MASK: u64 = (1 << SLOT_BITS) - 1;

fn pack(slot: usize, generation: u32) -> u64 {
    ((generation as u64) << SLOT_BITS) | slot as u64
}

fn unpack(id: u64) -> (usize, u32) {
    ((id & SLOT_MASK) as usize, (id >> SLOT_BITS) as u32)
}

fn lock<T>(m: &Mutex<T>) -> MutexGuard<'_, T> {
    m.lock().unwrap_or_else(|poisoned| poisoned.into_inner())
}

// ---------------------------------------------------------------------------
// Counters

static STARTED: AtomicI64 = AtomicI64::new(0);
static RUNNING: AtomicI64 = AtomicI64::new(0);
static ENDED: AtomicI64 = AtomicI64::new(0);
static JOINED: AtomicI64 = AtomicI64::new(0);
static DETACHED: AtomicI64 = AtomicI64::new(0);
static START_FAILURES: AtomicI64 = AtomicI64::new(0);
static LIMIT_REFUSALS: AtomicI64 = AtomicI64::new(0);
static STALE_REPLIES: AtomicI64 = AtomicI64::new(0);
static UNDELIVERED: AtomicI64 = AtomicI64::new(0);
static MESSAGES: AtomicI64 = AtomicI64::new(0);
static FULL_REFUSALS: AtomicI64 = AtomicI64::new(0);

// ---------------------------------------------------------------------------
// The thread registry

/// A thread's lifecycle state.
enum State {
    Starting,
    Running,
    Returned { data: Vec<u8>, stopped: bool },
    Failed { identity: String, message: String },
    StartFailed(String),
}

/// One thread's shared record: its name, state, stop flag and the ports to
/// notify.
pub struct Shared {
    name: String,
    state: Mutex<State>,
    ended: Condvar,
    stop: AtomicBool,
    /// The starting VM's port, woken (N_ENDED) when this thread ends.
    parent: Mutex<Option<Weak<Port>>>,
    /// This thread's own port, woken (N_STOP) by a stop request.
    own: Mutex<Option<Weak<Port>>>,
    handle: Mutex<Option<std::thread::JoinHandle<()>>>,
    id: AtomicI64,
}

impl Shared {
    fn code(&self) -> i64 {
        match &*lock(&self.state) {
            State::Starting => ST_STARTING,
            State::Running => ST_RUNNING,
            State::Returned { stopped: false, .. } => ST_RETURNED,
            State::Returned { stopped: true, .. } => ST_STOPPED,
            State::Failed { .. } => ST_FAILED,
            State::StartFailed(_) => ST_START_FAILED,
        }
    }

    fn ended(&self) -> bool {
        self.code() >= ST_RETURNED
    }

    /// Records the thread's end and wakes whoever waits for it.
    fn finish(&self, state: State) {
        {
            let mut s = lock(&self.state);
            *s = state;
        }
        self.ended.notify_all();
        RUNNING.fetch_sub(1, Ordering::Relaxed);
        ENDED.fetch_add(1, Ordering::Relaxed);
        let parent = lock(&self.parent).as_ref().and_then(Weak::upgrade);
        if let Some(port) = parent {
            notify(&port, N_ENDED, self.id.load(Ordering::Relaxed), 0, None);
        }
    }
}

struct Slot {
    generation: u32,
    shared: Option<Arc<Shared>>,
}

struct Registry {
    slots: Vec<Slot>,
    free: Vec<usize>,
}

static REGISTRY: Mutex<Registry> = Mutex::new(Registry { slots: Vec::new(), free: Vec::new() });

fn registered(id: i64) -> Option<Arc<Shared>> {
    if id <= 0 {
        return None;
    }
    let (slot, generation) = unpack(id as u64);
    let registry = lock(&REGISTRY);
    let s = registry.slots.get(slot)?;
    if s.generation != generation {
        return None;
    }
    s.shared.clone()
}

/// What a thread's body needs: the program's factory, its entry, its
/// initialization bytes, its guard's reservation and mode.
struct Start {
    factory: Arc<VmFactory>,
    entry: u32,
    init: Vec<u8>,
    shared: Arc<Shared>,
    reservation: usize,
    executable: bool,
    destination: usize,
}

/// Starts entry ENTRY (named NAME) with INIT on a new thread of STACK
/// bytes: its id, -1 when no guard record is free, -2 - errno when the
/// system refuses the thread.
fn spawn(p: *mut Vm, entry: i64, name: &str, init: &[u8], stack: i64) -> i64 {
    let Some(factory) = vm(p).thread.factory.clone() else {
        // (A Vm that cannot start threads: a native library's instance.)
        return -2 - libc_enosys();
    };
    if entry <= 0 || entry > u32::MAX as i64 {
        return -2 - libc_einval();
    }
    let Some(reservation) = super::platform::reserve_guard() else {
        LIMIT_REFUSALS.fetch_add(1, Ordering::Relaxed);
        return -1;
    };
    let (executable, destination) = super::platform::guard_mode();
    let shared = Arc::new(Shared {
        name: name.to_string(),
        state: Mutex::new(State::Starting),
        ended: Condvar::new(),
        stop: AtomicBool::new(false),
        parent: Mutex::new(vm(p).thread.port.as_ref().map(Arc::downgrade)),
        own: Mutex::new(None),
        handle: Mutex::new(None),
        id: AtomicI64::new(0),
    });
    let id = {
        let mut registry = lock(&REGISTRY);
        let slot = match registry.free.pop() {
            Some(slot) => slot,
            None => {
                registry.slots.push(Slot { generation: 0, shared: None });
                registry.slots.len() - 1
            }
        };
        if slot as u64 > SLOT_MASK {
            drop(registry);
            super::platform::unreserve_guard(reservation);
            return -2 - libc_eagain();
        }
        let s = &mut registry.slots[slot];
        s.generation = s.generation.wrapping_add(1).max(1);
        s.shared = Some(shared.clone());
        pack(slot, s.generation) as i64
    };
    shared.id.store(id, Ordering::Relaxed);
    let start = Start {
        factory,
        entry: entry as u32,
        init: init.to_vec(),
        shared: shared.clone(),
        reservation,
        executable,
        destination,
    };
    RUNNING.fetch_add(1, Ordering::Relaxed);
    STARTED.fetch_add(1, Ordering::Relaxed);
    let label = format!("thread {name} ");
    // (The OS thread's name: the entry's own, the part a system's 15 bytes
    // keep -- tools show it.)
    let short = name.rsplit("::").next().unwrap_or(&name).to_string();
    let builder = std::thread::Builder::new().name(short).stack_size(stack.max(1 << 20) as usize);
    match builder.spawn(move || body(start, label)) {
        Ok(handle) => {
            *lock(&shared.handle) = Some(handle);
            vm(p).thread.children.push(id as u64);
            id
        }
        Err(error) => {
            RUNNING.fetch_sub(1, Ordering::Relaxed);
            STARTED.fetch_sub(1, Ordering::Relaxed);
            START_FAILURES.fetch_add(1, Ordering::Relaxed);
            super::platform::unreserve_guard(reservation);
            remove(id);
            -2 - error.raw_os_error().map_or(libc_eagain(), |e| e as i64)
        }
    }
}

fn libc_enosys() -> i64 {
    38
}
fn libc_einval() -> i64 {
    22
}
fn libc_eagain() -> i64 {
    11
}

/// Frees id's registry slot (its next start bumps the generation).
fn remove(id: i64) {
    let (slot, generation) = unpack(id as u64);
    let mut registry = lock(&REGISTRY);
    if let Some(s) = registry.slots.get_mut(slot) {
        if s.generation == generation && s.shared.is_some() {
            s.shared = None;
            registry.free.push(slot);
        }
    }
}

/// A thread's whole life (on the thread): its guard, its Vm, its entry, its
/// outcome; the Vm dropped here, before the end is reported.
fn body(start: Start, label: String) {
    let Start { factory, entry, init, shared, reservation, executable, destination } = start;
    let guard = match super::platform::install_reserved_guard(reservation, executable, destination, label.as_bytes()) {
        Ok(guard) => guard,
        Err(error) => {
            super::platform::unreserve_guard(reservation);
            START_FAILURES.fetch_add(1, Ordering::Relaxed);
            shared.finish(State::StartFailed(format!("the thread's stack-overflow guard could not be installed: {error}")));
            return;
        }
    };
    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| run_entry(&factory, entry, init, &shared)));
    let state = match outcome {
        Ok(state) => state,
        Err(_) => State::Failed { identity: "NATIVE BUG".to_string(), message: "the thread's VM panicked".to_string() },
    };
    if matches!(state, State::StartFailed(_)) {
        START_FAILURES.fetch_add(1, Ordering::Relaxed);
    }
    drop(guard);
    shared.finish(state);
}

/// Makes the thread's Vm and runs ENTRY in it: the outcome.
fn run_entry(factory: &Arc<VmFactory>, entry: u32, init: Vec<u8>, shared: &Arc<Shared>) -> State {
    let (mut vm, program) = match factory() {
        Ok(made) => made,
        Err(reason) => return State::StartFailed(format!("the thread's VM could not be made: {reason}")),
    };
    vm.thread.factory = Some(factory.clone());
    vm.thread.entry = entry;
    vm.thread.init = init;
    vm.thread.record = Some(shared.clone());
    *lock(&shared.state) = State::Running;
    let result = program(&mut *vm);
    let state = if result == NO_VALUE {
        let error = vm.error.take().unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
        let message = vm.describe_error(&error);
        let identity = declared_identity(&message).unwrap_or_else(|| error.error_code().join(" "));
        State::Failed { identity, message }
    } else {
        match bytes_payload(result) {
            Some(data) => State::Returned { data: data.to_vec(), stopped: shared.stop.load(Ordering::Relaxed) },
            None => State::Failed { identity: "NATIVE BUG".to_string(), message: "the thread entry's result is no byte storage".to_string() },
        }
    };
    // What this Vm started and never released: asked to stop and joined
    // (their outcomes dropped, counted), before this Vm goes.
    finish_children(&mut vm);
    vm.thread.close_port();
    drop(vm);
    state
}

/// The declared error's identity in an uncaught failure's MESSAGE
/// ("... <error NAME>"), if it is one.
fn declared_identity(message: &str) -> Option<String> {
    let start = message.find("<error ")? + "<error ".len();
    let rest = &message[start..];
    let end = rest.find(|c: char| c == '>' || c == ' ').unwrap_or(rest.len());
    Some(rest[..end].to_string())
}

/// The payload of V, a std::abi::bytes::Bytes (a one-field struct holding a
/// byte storage), or None.
fn bytes_payload<'a>(v: Value) -> Option<&'a [u8]> {
    if heap_kind(v) != KIND_STRUCT || struct_of(v).fields().len() != 1 {
        return None;
    }
    let storage = struct_of(v).fields()[0];
    if heap_kind(storage) != KIND_BYTES {
        return None;
    }
    Some(bytes_of(storage))
}

/// Asks every thread VM started and has not released to stop, and joins
/// them (blocking): their outcomes are dropped (counted as detached).
fn finish_children(vm: &mut Vm) {
    let children = std::mem::take(&mut vm.thread.children);
    for id in &children {
        if let Some(shared) = registered(*id as i64) {
            request_stop(&shared);
        }
    }
    for id in children {
        if let Some(shared) = registered(id as i64) {
            wait_ended(&shared, -1);
            reap(id as i64);
            DETACHED.fetch_add(1, Ordering::Relaxed);
        }
    }
}

fn request_stop(shared: &Arc<Shared>) -> bool {
    if shared.ended() {
        return false;
    }
    shared.stop.store(true, Ordering::Relaxed);
    let own = lock(&shared.own).as_ref().and_then(Weak::upgrade);
    if let Some(port) = own {
        notify(&port, N_STOP, shared.id.load(Ordering::Relaxed), 0, None);
    }
    true
}

/// Waits until SHARED's thread has ended or TIMEOUT microseconds passed
/// (negative: no bound): its status code. An ended thread's OS thread is
/// joined before this returns, so whatever its exit runs -- thread-local
/// destructors, a native library's per-thread cleanup (event_loop_linux
/// closes the loops the thread opened) -- has run when a waiter sees it
/// ended.
fn wait_ended(shared: &Arc<Shared>, timeout: i64) -> i64 {
    let deadline = (timeout >= 0).then(|| std::time::Instant::now() + std::time::Duration::from_micros(timeout as u64));
    let mut state = lock(&shared.state);
    loop {
        if matches!(*state, State::Returned { .. } | State::Failed { .. } | State::StartFailed(_)) {
            break;
        }
        match deadline {
            None => state = shared.ended.wait(state).unwrap_or_else(|p| p.into_inner()),
            Some(deadline) => {
                let now = std::time::Instant::now();
                if now >= deadline {
                    break;
                }
                state = shared.ended.wait_timeout(state, deadline - now).unwrap_or_else(|p| p.into_inner()).0;
            }
        }
    }
    let ended = matches!(*state, State::Returned { .. } | State::Failed { .. } | State::StartFailed(_));
    drop(state);
    if ended {
        let handle = lock(&shared.handle).take();
        if let Some(handle) = handle {
            let _ = handle.join();
        }
    }
    shared.code()
}

/// Joins id's OS thread (it has ended, or ends now) and frees its slot.
fn reap(id: i64) {
    if let Some(shared) = registered(id) {
        let handle = lock(&shared.handle).take();
        if let Some(handle) = handle {
            let _ = handle.join();
        }
        remove(id);
    }
}

/// When the program's main VM has completed (runtime::aot::run, the
/// driver's run): asks every thread still registered to stop and joins
/// it, within BOUND microseconds in all (BOTLISH_THREAD_EXIT_JOIN_US, 30 s
/// by default). Whether every thread ended: a thread still running past
/// the bound is reported on standard error, and the caller must keep the
/// program's image alive (the process ends with it running).
pub fn finish_all() -> bool {
    let live: Vec<Arc<Shared>> = lock(&REGISTRY).slots.iter().filter_map(|s| s.shared.clone()).collect();
    if live.is_empty() {
        return true;
    }
    for shared in &live {
        request_stop(shared);
    }
    let bound = std::env::var("BOTLISH_THREAD_EXIT_JOIN_US")
        .ok()
        .and_then(|t| t.parse::<i64>().ok())
        .unwrap_or(30_000_000);
    let deadline = std::time::Instant::now() + std::time::Duration::from_micros(bound.max(0) as u64);
    let mut all = true;
    for shared in &live {
        let left = deadline.saturating_duration_since(std::time::Instant::now()).as_micros() as i64;
        if wait_ended(shared, left) < ST_RETURNED {
            eprintln!("botlish: thread {} is still running at the program's end (it did not stop when asked)", shared.name);
            all = false;
            continue;
        }
        let id = shared.id.load(Ordering::Relaxed);
        reap(id);
        DETACHED.fetch_add(1, Ordering::Relaxed);
    }
    all
}

// ---------------------------------------------------------------------------
// Ports

/// One VM's place in the transport.
pub struct Port {
    doorbell: Doorbell,
    queue: Mutex<VecDeque<(i64, i64, i64)>>,
    /// Calls this port's VM took and has not answered: completed with
    /// ServiceEnded when the port closes.
    owed: Mutex<Vec<u64>>,
    closed: AtomicBool,
}

/// A doorbell: an eventfd (Linux), else a pipe's read end and write end.
struct Doorbell {
    read: i32,
    write: i32,
}

impl Doorbell {
    fn open() -> Result<Doorbell, i64> {
        #[cfg(target_os = "linux")]
        {
            // SAFETY: plain system call.
            let fd = unsafe { libc::eventfd(0, libc::EFD_NONBLOCK | libc::EFD_CLOEXEC) };
            if fd < 0 {
                return Err(std::io::Error::last_os_error().raw_os_error().unwrap_or(5) as i64);
            }
            Ok(Doorbell { read: fd, write: fd })
        }
        #[cfg(all(unix, not(target_os = "linux")))]
        {
            let mut fds = [0i32; 2];
            // SAFETY: plain system calls on our own descriptors.
            unsafe {
                if libc::pipe(fds.as_mut_ptr()) != 0 {
                    return Err(std::io::Error::last_os_error().raw_os_error().unwrap_or(5) as i64);
                }
                for fd in fds {
                    libc::fcntl(fd, libc::F_SETFL, libc::O_NONBLOCK);
                    libc::fcntl(fd, libc::F_SETFD, libc::FD_CLOEXEC);
                }
            }
            Ok(Doorbell { read: fds[0], write: fds[1] })
        }
        #[cfg(not(unix))]
        {
            Err(38)
        }
    }

    fn ring(&self) {
        #[cfg(unix)]
        {
            let one: u64 = 1;
            // SAFETY: a write of eight bytes from a local to our descriptor;
            // a full counter or pipe (EAGAIN) is already readable.
            unsafe { libc::write(self.write, (&one as *const u64).cast(), if self.read == self.write { 8 } else { 1 }) };
        }
    }

    fn reset(&self) {
        #[cfg(unix)]
        {
            let mut buffer = [0u8; 64];
            loop {
                // SAFETY: a read into a local buffer from our nonblocking
                // descriptor.
                let n = unsafe { libc::read(self.read, buffer.as_mut_ptr().cast(), buffer.len()) };
                if n <= 0 || self.read == self.write {
                    break;
                }
            }
        }
    }
}

impl Drop for Doorbell {
    fn drop(&mut self) {
        #[cfg(unix)]
        // SAFETY: closing our own descriptors, once.
        unsafe {
            libc::close(self.read);
            if self.write != self.read {
                libc::close(self.write);
            }
        }
    }
}

/// Pushes notification (KIND, A, B) onto PORT and rings its doorbell. With
/// FLAG, only when the flag was clear (one pending notification per
/// endpoint), which it sets.
fn notify(port: &Port, kind: i64, a: i64, b: i64, flag: Option<&mut bool>) {
    if port.closed.load(Ordering::Acquire) {
        return;
    }
    if let Some(flag) = flag {
        if *flag {
            return;
        }
        *flag = true;
    }
    lock(&port.queue).push_back((kind, a, b));
    port.doorbell.ring();
}

fn port_of(p: *mut Vm) -> Result<Arc<Port>, i64> {
    let thread = &mut vm(p).thread;
    if let Some(port) = &thread.port {
        return Ok(port.clone());
    }
    let doorbell = Doorbell::open().map_err(|errno| -2 - errno)?;
    let port = Arc::new(Port {
        doorbell,
        queue: Mutex::new(VecDeque::new()),
        owed: Mutex::new(Vec::new()),
        closed: AtomicBool::new(false),
    });
    if let Some(record) = &thread.record {
        *lock(&record.own) = Some(Arc::downgrade(&port));
        if record.stop.load(Ordering::Relaxed) {
            notify(&port, N_STOP, record.id.load(Ordering::Relaxed), 0, None);
        }
    }
    // The threads this VM started already: their ends notify this port.
    for id in &thread.children {
        if let Some(shared) = registered(*id as i64) {
            *lock(&shared.parent) = Some(Arc::downgrade(&port));
            if shared.ended() {
                notify(&port, N_ENDED, *id as i64, 0, None);
            }
        }
    }
    thread.port = Some(port.clone());
    Ok(port)
}

/// The next notification of this VM's port, made current: its kind, or -1
/// when there is none -- after resetting the doorbell and looking once
/// more, so that a notification pushed while the port was being drained
/// rings it again (never lost).
fn port_take(p: *mut Vm) -> i64 {
    let Some(port) = vm(p).thread.port.clone() else {
        return -1;
    };
    let mut next = lock(&port.queue).pop_front();
    if next.is_none() {
        port.doorbell.reset();
        next = lock(&port.queue).pop_front();
    }
    match next {
        Some((kind, a, b)) => {
            if kind == N_MESSAGE {
                // The endpoint's one pending notification is taken: a later
                // message notifies again.
                let mut transport = lock(&TRANSPORT);
                if let Some(e) = transport.endpoint_mut(a as u64) {
                    e.notified = false;
                }
            }
            vm(p).thread.notice = (a, b);
            kind
        }
        None => -1,
    }
}

fn close_port(port: &Arc<Port>) {
    port.closed.store(true, Ordering::Release);
    let mut transport = lock(&TRANSPORT);
    let mine: Vec<u64> = transport
        .endpoints
        .iter()
        .enumerate()
        .filter_map(|(slot, e)| {
            e.endpoint.as_ref().filter(|ep| Arc::ptr_eq(&ep.owner, port)).map(|_| pack(slot, e.generation))
        })
        .collect();
    for id in mine {
        transport.close_endpoint(id);
    }
    let owed: Vec<u64> = std::mem::take(&mut *lock(&port.owed));
    for call in owed {
        transport.complete(call, T_SERVICE_ENDED, Vec::new());
    }
}

// ---------------------------------------------------------------------------
// The transport

struct Message {
    data: Vec<u8>,
    /// The call this message is the request or the response of: (id, key).
    call: Option<(u64, u64)>,
    status: i64,
}

struct Endpoint {
    key: u64,
    fingerprint: [u8; 8],
    capacity: usize,
    owner: Arc<Port>,
    queue: VecDeque<Message>,
    bytes: usize,
    notified: bool,
    /// Senders waiting for room, first in line first: their ports and the
    /// token they wait with.
    waiters: VecDeque<(Weak<Port>, i64)>,
    /// Waiting senders told a place is theirs (N_ROOM), whose retry takes
    /// it: a granted place counts as taken for everyone else, so neither a
    /// sender that did not wait nor a later waiter takes it first.
    granted: Vec<(Weak<Port>, i64)>,
}

impl Endpoint {
    /// Whether one more message of LEN bytes fits beside the queue and the
    /// granted places, not counting sender GRANT's own grant.
    fn fits(&self, len: usize, grant: Option<usize>) -> bool {
        let reserved = self.granted.len() - grant.is_some() as usize;
        self.queue.len() + reserved < self.capacity && self.bytes + len <= MAX_QUEUED_BYTES
    }

    /// Grants every free place to the first waiting senders (pruning grants
    /// of ports that closed), each told with N_ROOM on its port.
    fn grant(&mut self, id: u64) {
        self.granted.retain(|(port, _)| port.upgrade().is_some_and(|p| !p.closed.load(Ordering::Acquire)));
        while self.queue.len() + self.granted.len() < self.capacity {
            let Some((port, token)) = self.waiters.pop_front() else { break };
            let Some(live) = port.upgrade() else { continue };
            if live.closed.load(Ordering::Acquire) {
                continue;
            }
            self.granted.push((port, token));
            notify(&live, N_ROOM, id as i64, token, None);
        }
    }
}

struct EndpointSlot {
    generation: u32,
    endpoint: Option<Endpoint>,
}

enum CallState {
    Pending,
    Taken(Weak<Port>),
    Done,
}

struct Call {
    key: u64,
    /// The caller's reply endpoint (id).
    reply: u64,
    state: CallState,
}

struct CallSlot {
    generation: u32,
    call: Option<Call>,
}

struct Transport {
    domain: i64,
    endpoints: Vec<EndpointSlot>,
    free: Vec<usize>,
    calls: Vec<CallSlot>,
    free_calls: Vec<usize>,
}

static TRANSPORT: Mutex<Transport> =
    Mutex::new(Transport { domain: 0, endpoints: Vec::new(), free: Vec::new(), calls: Vec::new(), free_calls: Vec::new() });

/// A random 62-bit word of the system's entropy (std's RandomState, as the
/// table hash's key is drawn: runtime/ops.rs).
fn random_word(salt: u64) -> u64 {
    use std::hash::{BuildHasher, Hasher};
    let mut h = std::collections::hash_map::RandomState::new().build_hasher();
    h.write_u64(salt);
    h.finish() & ((1 << 62) - 1)
}

impl Transport {
    fn domain(&mut self) -> i64 {
        if self.domain == 0 {
            self.domain = (random_word(0x646f6d61696e) | 1) as i64;
        }
        self.domain
    }

    fn endpoint_mut(&mut self, id: u64) -> Option<&mut Endpoint> {
        let (slot, generation) = unpack(id);
        let s = self.endpoints.get_mut(slot)?;
        if s.generation != generation {
            return None;
        }
        s.endpoint.as_mut()
    }

    /// The endpoint named by (DOMAIN, ID, KEY), or the code that refuses it.
    fn checked(&mut self, domain: i64, id: u64, key: u64) -> Result<&mut Endpoint, i64> {
        if domain != self.domain() {
            return Err(T_UNAVAILABLE);
        }
        let (slot, generation) = unpack(id);
        let Some(s) = self.endpoints.get_mut(slot) else { return Err(T_STALE) };
        if s.generation != generation {
            return Err(T_STALE);
        }
        match s.endpoint.as_mut() {
            Some(e) if e.key == key => Ok(e),
            Some(_) => Err(T_STALE),
            // (Closed: the slot's generation is kept until it is reused.)
            None => Err(T_CLOSED),
        }
    }

    fn open(&mut self, owner: Arc<Port>, capacity: usize, fingerprint: [u8; 8]) -> u64 {
        let slot = match self.free.pop() {
            Some(slot) => slot,
            None => {
                self.endpoints.push(EndpointSlot { generation: 0, endpoint: None });
                self.endpoints.len() - 1
            }
        };
        let s = &mut self.endpoints[slot];
        s.generation = s.generation.wrapping_add(1).max(1);
        let key = random_word(pack(slot, s.generation) ^ 0x656e64706f696e74);
        s.endpoint = Some(Endpoint {
            key,
            fingerprint,
            capacity: capacity.max(1),
            owner,
            queue: VecDeque::new(),
            bytes: 0,
            notified: false,
            waiters: VecDeque::new(),
            granted: Vec::new(),
        });
        pack(slot, s.generation)
    }

    /// Closes endpoint ID: its queued messages dropped (counted: the
    /// result), the calls among them failed (Undelivered), its waiting
    /// senders woken (their retry answers Closed). The slot keeps its
    /// generation until a later open reuses it.
    fn close_endpoint(&mut self, id: u64) -> i64 {
        let (slot, generation) = unpack(id);
        let Some(s) = self.endpoints.get_mut(slot) else { return 0 };
        if s.generation != generation {
            return 0;
        }
        let Some(e) = s.endpoint.take() else { return 0 };
        self.free.push(slot);
        let dropped = e.queue.len() as i64;
        UNDELIVERED.fetch_add(dropped, Ordering::Relaxed);
        for (port, token) in e.waiters.into_iter().chain(e.granted) {
            if let Some(port) = port.upgrade() {
                notify(&port, N_ROOM, id as i64, token, None);
            }
        }
        for m in e.queue {
            if let Some((call, _)) = m.call {
                if m.status == T_DELIVERED && !self.is_response(call, id) {
                    self.complete(call, T_UNDELIVERED, Vec::new());
                }
            }
        }
        dropped
    }

    /// Whether CALL's reply endpoint is ID (a queued response, not a request).
    fn is_response(&self, call: u64, id: u64) -> bool {
        let (slot, generation) = unpack(call);
        matches!(self.calls.get(slot), Some(CallSlot { generation: g, call: Some(c) }) if *g == generation && c.reply == id)
            || self.calls.get(slot).is_some_and(|s| s.generation != generation)
    }

    /// Queues MESSAGE on endpoint (DOMAIN, ID, KEY) unless it refuses it.
    /// With WAIT (a sender's port and token), a Full refusal registers the
    /// sender for the endpoint's next free place (N_ROOM).
    fn enqueue(&mut self, domain: i64, id: u64, key: u64, message: Message, wait: Option<(Weak<Port>, i64)>) -> i64 {
        let e = match self.checked(domain, id, key) {
            Ok(e) => e,
            Err(code) => return code,
        };
        if message.data.len() < 13 || &message.data[..4] != b"BOTX" {
            return T_MALFORMED;
        }
        if message.data[5..13] != e.fingerprint {
            return T_TYPE_MISMATCH;
        }
        if message.data.len() > MAX_MESSAGE {
            return T_TOO_LARGE;
        }
        // A waiting sender's retry after N_ROOM: the place granted to it.
        let grant = wait
            .as_ref()
            .and_then(|(port, token)| e.granted.iter().position(|(p, t)| t == token && p.ptr_eq(port)));
        // (Nobody overtakes a sender in line: a free place is granted to
        // the first waiting sender, and none is free while one waits.)
        if !e.fits(message.data.len(), grant) || (grant.is_none() && !e.waiters.is_empty()) {
            FULL_REFUSALS.fetch_add(1, Ordering::Relaxed);
            if let Some(i) = grant {
                // Granted but the bytes do not fit yet: first in line again.
                let waiter = e.granted.swap_remove(i);
                e.waiters.push_front(waiter);
            } else if let Some(waiter) = wait {
                if !e.waiters.iter().any(|(p, t)| *t == waiter.1 && p.ptr_eq(&waiter.0)) {
                    e.waiters.push_back(waiter);
                }
            }
            return T_FULL;
        }
        if let Some(i) = grant {
            e.granted.swap_remove(i);
        }
        e.bytes += message.data.len();
        e.queue.push_back(message);
        MESSAGES.fetch_add(1, Ordering::Relaxed);
        let owner = e.owner.clone();
        notify(&owner, N_MESSAGE, id as i64, 0, Some(&mut e.notified));
        T_DELIVERED
    }

    /// Completes CALL with STATUS and DATA: its response queued on the
    /// caller's reply endpoint (beyond its capacity: one per call), the
    /// call done. A call already done (or unknown) is stale.
    fn complete(&mut self, call: u64, status: i64, data: Vec<u8>) -> i64 {
        let (slot, generation) = unpack(call);
        let Some(s) = self.calls.get_mut(slot) else { return T_STALE };
        if s.generation != generation {
            return T_STALE;
        }
        let Some(c) = s.call.as_mut() else { return T_STALE };
        if matches!(c.state, CallState::Done) {
            return T_STALE;
        }
        if let CallState::Taken(port) = &c.state {
            if let Some(port) = port.upgrade() {
                lock(&port.owed).retain(|&x| x != call);
            }
        }
        c.state = CallState::Done;
        let reply = c.reply;
        let key = c.key;
        let Some(e) = self.endpoint_mut(reply) else {
            // The caller is gone: nothing waits for the response.
            self.free_call(call);
            return T_STALE;
        };
        e.bytes += data.len();
        e.queue.push_back(Message { data, call: Some((call, key)), status });
        let owner = e.owner.clone();
        notify(&owner, N_MESSAGE, reply as i64, 0, Some(&mut e.notified));
        T_DELIVERED
    }

    fn new_call(&mut self, reply: u64) -> (u64, u64) {
        let slot = match self.free_calls.pop() {
            Some(slot) => slot,
            None => {
                self.calls.push(CallSlot { generation: 0, call: None });
                self.calls.len() - 1
            }
        };
        let s = &mut self.calls[slot];
        s.generation = s.generation.wrapping_add(1).max(1);
        let id = pack(slot, s.generation);
        let key = random_word(id ^ 0x63616c6c);
        s.call = Some(Call { key, reply, state: CallState::Pending });
        (id, key)
    }

    fn free_call(&mut self, call: u64) {
        let (slot, generation) = unpack(call);
        if let Some(s) = self.calls.get_mut(slot) {
            if s.generation == generation && s.call.is_some() {
                s.call = None;
                self.free_calls.push(slot);
            }
        }
    }
}

/// The fingerprint a transfer's bytes carry (bytes 5..13), of a String
/// operand holding its sixteen hex digits.
fn fingerprint_of(text: &str) -> Option<[u8; 8]> {
    if text.len() != 16 {
        return None;
    }
    let n = u64::from_str_radix(text, 16).ok()?;
    Some(n.to_le_bytes())
}

// ---------------------------------------------------------------------------
// The runtime operation (NIR `threadop`)

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    // SAFETY: P is the running Vm, which generated code passes to every
    // helper.
    unsafe { &mut *p }
}

fn int(p: *mut Vm, v: Value, what: &str) -> Result<i64, Value> {
    if is_small(v) {
        Ok(small_of(v))
    } else {
        Err(vm(p).fail(RtError::Type { context: what.to_string(), expected: Kind::Int, got: v }))
    }
}

fn text<'a>(p: *mut Vm, v: Value, what: &str) -> Result<&'a str, Value> {
    if heap_kind(v) == KIND_STR {
        Ok(str_of(v).as_str())
    } else {
        Err(vm(p).fail(RtError::Type { context: what.to_string(), expected: Kind::Str, got: v }))
    }
}

fn bytes<'a>(p: *mut Vm, v: Value, what: &str) -> Result<&'a [u8], Value> {
    bytes_payload(v).ok_or_else(|| vm(p).fail(RtError::Type { context: what.to_string(), expected: Kind::Struct, got: v }))
}

/// A std::abi::bytes::Bytes of DATA, of shape SHAPE (the lowering's operand).
fn new_bytes_value(p: *mut Vm, data: &[u8], shape: Value) -> Value {
    let shape = if is_small(shape) { small_of(shape) as u32 } else { 0 };
    let storage = vm(p).new_bytes(data);
    if storage == NO_VALUE {
        return NO_VALUE;
    }
    let base = vm(p).temp_roots.len();
    vm(p).temp_roots.push(storage);
    let r = vm(p).new_struct(shape, vec![storage]);
    vm(p).temp_roots.truncate(base);
    r
}

/// `threadop CODE A0 .. A5` (core/thread.tcl's codes).
#[unsafe(no_mangle)]
pub extern "C" fn rt_thread_op(p: *mut Vm, code: Value, a0: Value, a1: Value, a2: Value, a3: Value, a4: Value, a5: Value) -> Value {
    match op(p, small_of(code), [a0, a1, a2, a3, a4, a5]) {
        Ok(v) => v,
        Err(failed) => failed,
    }
}

fn op(p: *mut Vm, code: i64, a: [Value; 6]) -> Result<Value, Value> {
    let n = |v: i64| vm(p).new_int(v);
    Ok(match code {
        // rt_spawn(index, name, init, stack)
        1 => {
            let index = int(p, a[0], "std::thread::start")?;
            let name = text(p, a[1], "std::thread::start")?.to_string();
            let init = bytes(p, a[2], "std::thread::start")?.to_vec();
            let stack = int(p, a[3], "std::thread::start")?;
            n(spawn(p, index, &name, &init, stack))
        }
        // rt_status(id)
        2 => {
            let id = int(p, a[0], "std::thread::status")?;
            n(registered(id).map_or(ST_GONE, |s| s.code()))
        }
        // rt_stop(id)
        3 => {
            let id = int(p, a[0], "std::thread::request_stop")?;
            n(registered(id).is_some_and(|s| request_stop(&s)) as i64)
        }
        // rt_await(id, timeout)
        4 => {
            let id = int(p, a[0], "std::thread::await_end")?;
            let timeout = int(p, a[1], "std::thread::await_end")?;
            n(registered(id).map_or(ST_GONE, |s| wait_ended(&s, timeout)))
        }
        // rt_result(id)
        5 => {
            let id = int(p, a[0], "std::thread::join")?;
            let data = registered(id).and_then(|s| match &*lock(&s.state) {
                State::Returned { data, .. } => Some(data.clone()),
                _ => None,
            });
            new_bytes_value(p, &data.unwrap_or_default(), a[5])
        }
        // rt_error(id): a failure's identity; rt_error_message(id): its text
        6 | 34 => {
            let id = int(p, a[0], "std::thread::join")?;
            let text = registered(id)
                .map(|s| match &*lock(&s.state) {
                    State::Failed { identity, message } => {
                        if code == 6 {
                            identity.clone()
                        } else {
                            message.clone()
                        }
                    }
                    State::StartFailed(reason) => reason.clone(),
                    _ => String::new(),
                })
                .unwrap_or_else(|| if id < -1 { (-2 - id).to_string() } else { String::new() });
            vm(p).new_str(&text)
        }
        // rt_release(id)
        7 => {
            let id = int(p, a[0], "std::thread::join")?;
            let Some(shared) = registered(id) else { return Ok(n(0)) };
            if !shared.ended() {
                return Ok(n(0));
            }
            reap(id);
            vm(p).thread.children.retain(|&c| c != id as u64);
            JOINED.fetch_add(1, Ordering::Relaxed);
            n(1)
        }
        // rt_stop_requested()
        8 => n(vm(p).thread.record.as_ref().is_some_and(|r| r.stop.load(Ordering::Relaxed)) as i64),
        // rt_capacity()
        9 => n(super::platform::free_guards() as i64),
        // rt_stat(i)
        10 => {
            let i = int(p, a[0], "std::thread::stats")?;
            let counter = |c: &AtomicI64| c.load(Ordering::Relaxed);
            n(match i {
                0 => counter(&STARTED),
                1 => counter(&RUNNING),
                2 => counter(&ENDED),
                3 => counter(&JOINED),
                4 => counter(&DETACHED),
                5 => counter(&START_FAILURES),
                6 => counter(&LIMIT_REFUSALS),
                7 => counter(&STALE_REPLIES),
                8 => {
                    let children = vm(p).thread.children.clone();
                    children.iter().filter(|&&id| registered(id as i64).is_some_and(|s| !s.ended())).count() as i64
                }
                9 => counter(&UNDELIVERED),
                10 => counter(&MESSAGES),
                11 => counter(&FULL_REFUSALS),
                _ => 0,
            })
        }
        // rt_port_open()
        11 => n(match port_of(p) {
            Ok(port) => port.doorbell.read as i64,
            Err(code) => code,
        }),
        // rt_port_take()
        12 => n(port_take(p)),
        13 => n(vm(p).thread.notice.0),
        14 => n(vm(p).thread.notice.1),
        // rt_port_close()
        15 => {
            vm(p).thread.close_port();
            n(0)
        }
        // rt_domain()
        16 => n(lock(&TRANSPORT).domain()),
        // rt_endpoint_open(capacity, fingerprint)
        17 => {
            let capacity = int(p, a[0], "std::actor::remote::export")?;
            let fingerprint = text(p, a[1], "std::actor::remote::export")?;
            let Some(fingerprint) = fingerprint_of(fingerprint) else { return Ok(n(T_MALFORMED)) };
            let port = match port_of(p) {
                Ok(port) => port,
                Err(code) => return Ok(n(code)),
            };
            let id = lock(&TRANSPORT).open(port, capacity.clamp(1, 1 << 20) as usize, fingerprint);
            n(id as i64)
        }
        // rt_endpoint_key(id)
        18 => {
            let id = int(p, a[0], "std::actor::remote::export")?;
            let mut transport = lock(&TRANSPORT);
            n(transport.endpoint_mut(id as u64).map_or(0, |e| e.key as i64))
        }
        // rt_endpoint_close(id): only the owner's
        19 => {
            let id = int(p, a[0], "std::actor::remote::close")?;
            let mine = vm(p).thread.port.clone();
            let mut transport = lock(&TRANSPORT);
            let owned = transport.endpoint_mut(id as u64).is_some_and(|e| mine.as_ref().is_some_and(|m| Arc::ptr_eq(&e.owner, m)));
            n(if owned { transport.close_endpoint(id as u64) } else { 0 })
        }
        // rt_send(domain, id, key, data, wait-token, -): a one-way message
        20 => {
            let domain = int(p, a[0], "std::actor::remote::send")?;
            let id = int(p, a[1], "std::actor::remote::send")? as u64;
            let key = int(p, a[2], "std::actor::remote::send")? as u64;
            let data = bytes(p, a[3], "std::actor::remote::send")?.to_vec();
            let token = int(p, a[4], "std::actor::remote::send")?;
            let wait = if token != 0 {
                match port_of(p) {
                    Ok(port) => Some((Arc::downgrade(&port), token)),
                    Err(code) => return Ok(n(code)),
                }
            } else {
                None
            };
            n(lock(&TRANSPORT).enqueue(domain, id, key, Message { data, call: None, status: T_DELIVERED }, wait))
        }
        // rt_request(domain, id, key, data, reply-endpoint, wait-token): a
        // call; its id, or a refusal code
        21 => {
            let domain = int(p, a[0], "std::actor::remote::call")?;
            let id = int(p, a[1], "std::actor::remote::call")? as u64;
            let key = int(p, a[2], "std::actor::remote::call")? as u64;
            let data = bytes(p, a[3], "std::actor::remote::call")?.to_vec();
            let reply = int(p, a[4], "std::actor::remote::call")? as u64;
            let token = int(p, a[5], "std::actor::remote::call")?;
            let port = match port_of(p) {
                Ok(port) => port,
                Err(code) => return Ok(n(code)),
            };
            let mut transport = lock(&TRANSPORT);
            // The reply endpoint must be this VM's own.
            if !transport.endpoint_mut(reply).is_some_and(|e| Arc::ptr_eq(&e.owner, &port)) {
                return Ok(n(T_NO_PORT));
            }
            let (call, call_key) = transport.new_call(reply);
            let wait = (token != 0).then(|| (Arc::downgrade(&port), token));
            let status = transport.enqueue(domain, id, key, Message { data, call: Some((call, call_key)), status: T_DELIVERED }, wait);
            if status != T_DELIVERED {
                transport.free_call(call);
                return Ok(n(status));
            }
            n(call as i64)
        }
        // rt_take(id): the next message of this VM's endpoint ID, current
        22 => {
            let id = int(p, a[0], "std::actor::remote")? as u64;
            let mine = vm(p).thread.port.clone();
            let mut transport = lock(&TRANSPORT);
            let Some(e) = transport.endpoint_mut(id) else { return Ok(n(0)) };
            if !mine.as_ref().is_some_and(|m| Arc::ptr_eq(&e.owner, m)) {
                return Ok(n(0));
            }
            let Some(m) = e.queue.pop_front() else { return Ok(n(0)) };
            e.bytes -= m.data.len().min(e.bytes);
            // A place freed: granted to the first waiting sender, told.
            e.grant(id);
            if let Some((call, _)) = m.call {
                // A request taken: this VM owes its reply.
                let (slot, generation) = unpack(call);
                if let Some(CallSlot { generation: g, call: Some(c) }) = transport.calls.get_mut(slot) {
                    if *g == generation && matches!(c.state, CallState::Pending) {
                        if let Some(port) = &mine {
                            c.state = CallState::Taken(Arc::downgrade(port));
                            lock(&port.owed).push(call);
                        }
                    } else if *g == generation && matches!(c.state, CallState::Done) {
                        // A response: the call record is freed.
                        transport.free_call(call);
                    }
                }
            }
            drop(transport);
            vm(p).thread.current = Some(m);
            n(1)
        }
        // rt_take_bytes()
        23 => {
            let data = vm(p).thread.current.as_ref().map(|m| m.data.clone()).unwrap_or_default();
            new_bytes_value(p, &data, a[5])
        }
        24 => n(vm(p).thread.current.as_ref().and_then(|m| m.call).map_or(0, |c| c.0 as i64)),
        25 => n(vm(p).thread.current.as_ref().and_then(|m| m.call).map_or(0, |c| c.1 as i64)),
        26 => n(vm(p).thread.current.as_ref().map_or(T_STALE, |m| m.status)),
        // rt_reply(domain, call, key, status, data)
        27 => {
            let domain = int(p, a[0], "std::actor::remote::reply")?;
            let call = int(p, a[1], "std::actor::remote::reply")? as u64;
            let key = int(p, a[2], "std::actor::remote::reply")? as u64;
            let status = int(p, a[3], "std::actor::remote::reply")?;
            let data = bytes(p, a[4], "std::actor::remote::reply")?.to_vec();
            let mut transport = lock(&TRANSPORT);
            if domain != transport.domain() {
                return Ok(n(T_UNAVAILABLE));
            }
            let (slot, generation) = unpack(call);
            let known = matches!(transport.calls.get(slot), Some(CallSlot { generation: g, call: Some(c) }) if *g == generation && c.key == key);
            if !known {
                STALE_REPLIES.fetch_add(1, Ordering::Relaxed);
                return Ok(n(T_STALE));
            }
            let r = transport.complete(call, status, data);
            if r == T_STALE {
                STALE_REPLIES.fetch_add(1, Ordering::Relaxed);
            }
            n(r)
        }
        // rt_cancel(call): the caller gives up on it; a later reply is stale
        28 => {
            let call = int(p, a[0], "std::actor::remote::cancel")? as u64;
            let mut transport = lock(&TRANSPORT);
            let (slot, generation) = unpack(call);
            if let Some(CallSlot { generation: g, call: Some(c) }) = transport.calls.get_mut(slot) {
                if *g == generation {
                    if let CallState::Taken(port) = &c.state {
                        if let Some(port) = port.upgrade() {
                            lock(&port.owed).retain(|&x| x != call);
                        }
                    }
                    c.state = CallState::Done;
                    transport.free_call(call);
                    return Ok(n(1));
                }
            }
            n(0)
        }
        // rt_entry_index(): this VM's entry (the thread dispatch)
        29 => n(vm(p).thread.entry as i64),
        // rt_init(): its initialization bytes
        30 => {
            let init = std::mem::take(&mut vm(p).thread.init);
            new_bytes_value(p, &init, a[5])
        }
        // rt_endpoint_queued(id)
        31 => {
            let id = int(p, a[0], "std::actor::remote")? as u64;
            let mut transport = lock(&TRANSPORT);
            n(transport.endpoint_mut(id).map_or(0, |e| e.queue.len() as i64))
        }
        // rt_take_text(): unused
        32 => vm(p).new_str(""),
        // rt_watch(thread, -): the port is told when THREAD ends
        33 => {
            let id = int(p, a[0], "std::thread::wait_end")?;
            let port = match port_of(p) {
                Ok(port) => port,
                Err(code) => return Ok(n(code)),
            };
            match registered(id) {
                Some(shared) => {
                    *lock(&shared.parent) = Some(Arc::downgrade(&port));
                    if shared.ended() {
                        notify(&port, N_ENDED, id, 0, None);
                    }
                    n(1)
                }
                None => {
                    notify(&port, N_ENDED, id, 0, None);
                    n(0)
                }
            }
        }
        _ => return Err(vm(p).fail(RtError::Bug(format!("unknown thread operation {code}")))),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ids_pack_and_unpack() {
        for (slot, generation) in [(0usize, 1u32), (5, 7), (SLOT_MASK as usize, u32::MAX)] {
            assert_eq!(unpack(pack(slot, generation)), (slot, generation));
        }
        assert!(pack(SLOT_MASK as usize, u32::MAX) < (1u64 << 62), "an id stays a small Int");
    }

    #[test]
    fn declared_identities_are_read_from_the_message() {
        assert_eq!(declared_identity("uncaught propagated error: <error worker::Refused>").as_deref(), Some("worker::Refused"));
        assert_eq!(declared_identity("uncaught propagated error: <error Refused {code: 3}>").as_deref(), Some("Refused"));
        assert_eq!(declared_identity("index 3 out of range"), None);
    }

    #[test]
    fn fingerprints_are_hex() {
        assert_eq!(fingerprint_of("0102030405060708"), Some(0x0102030405060708u64.to_le_bytes()));
        assert_eq!(fingerprint_of("xyz"), None);
    }

    /// The doorbell's reset-then-check never loses a notification: a push
    /// between the drain's empty check and its reset is seen by the recheck,
    /// and a push after the reset rings again.
    #[cfg(unix)]
    #[test]
    fn port_notifications_are_never_lost() {
        let port = Port {
            doorbell: Doorbell::open().expect("a doorbell"),
            queue: Mutex::new(VecDeque::new()),
            owed: Mutex::new(Vec::new()),
            closed: AtomicBool::new(false),
        };
        let readable = |fd: i32| {
            let mut pfd = libc::pollfd { fd, events: libc::POLLIN, revents: 0 };
            unsafe { libc::poll(&mut pfd, 1, 0) == 1 }
        };
        notify(&port, N_MESSAGE, 1, 0, None);
        assert!(readable(port.doorbell.read));
        assert_eq!(lock(&port.queue).pop_front(), Some((N_MESSAGE, 1, 0)));
        // Empty: the drain resets, then a producer pushes and rings.
        port.doorbell.reset();
        assert!(!readable(port.doorbell.read));
        notify(&port, N_ROOM, 2, 3, None);
        assert!(readable(port.doorbell.read), "a push after the reset rings again");
        let mut flag = false;
        notify(&port, N_MESSAGE, 4, 0, Some(&mut flag));
        notify(&port, N_MESSAGE, 4, 0, Some(&mut flag));
        assert_eq!(lock(&port.queue).len(), 2, "one pending notification per flag");
    }

    /// An endpoint is named by its domain, its slot and generation, and its
    /// key: another process's domain is Unavailable, a wrong key or an old
    /// generation Stale (nothing of the endpoint is reached), a closed
    /// endpoint Closed until its slot is reused, then Stale.
    #[cfg(unix)]
    #[test]
    fn endpoints_are_named_by_domain_generation_and_key() {
        let owner = Arc::new(Port {
            doorbell: Doorbell::open().expect("a doorbell"),
            queue: Mutex::new(VecDeque::new()),
            owed: Mutex::new(Vec::new()),
            closed: AtomicBool::new(false),
        });
        let mut t = Transport { domain: 0, endpoints: Vec::new(), free: Vec::new(), calls: Vec::new(), free_calls: Vec::new() };
        let domain = t.domain();
        let id = t.open(owner.clone(), 4, [0; 8]);
        let key = t.endpoint_mut(id).expect("open").key;
        let refused = |t: &mut Transport, domain: i64, id: u64, key: u64| t.checked(domain, id, key).err();
        assert_eq!(refused(&mut t, domain, id, key), None);
        assert_eq!(refused(&mut t, domain ^ 2, id, key), Some(T_UNAVAILABLE));
        assert_eq!(refused(&mut t, domain, id, key ^ 1), Some(T_STALE), "a key nobody was given names nothing");
        assert_eq!(refused(&mut t, domain, pack(unpack(id).0, unpack(id).1 + 1), key), Some(T_STALE));
        t.close_endpoint(id);
        assert_eq!(refused(&mut t, domain, id, key), Some(T_CLOSED));
        let again = t.open(owner, 4, [0; 8]);
        assert_eq!(unpack(again).0, unpack(id).0, "the slot is reused");
        assert_eq!(refused(&mut t, domain, id, key), Some(T_STALE), "the old capability names nothing of the new endpoint");
    }

    /// A call completes once: a second answer, an answer by a call id whose
    /// slot a later call reuses, and an answer to a caller whose reply
    /// route closed (its actor gone: the call cancelled) are all Stale and
    /// reach nobody.
    #[cfg(unix)]
    #[test]
    fn calls_complete_once() {
        let owner = Arc::new(Port {
            doorbell: Doorbell::open().expect("a doorbell"),
            queue: Mutex::new(VecDeque::new()),
            owed: Mutex::new(Vec::new()),
            closed: AtomicBool::new(false),
        });
        let mut t = Transport { domain: 0, endpoints: Vec::new(), free: Vec::new(), calls: Vec::new(), free_calls: Vec::new() };
        let reply = t.open(owner, 4, [0; 8]);
        let (call, _) = t.new_call(reply);
        assert_eq!(t.complete(call, T_DELIVERED, vec![1]), T_DELIVERED);
        assert_eq!(t.complete(call, T_DELIVERED, vec![2]), T_STALE, "a second answer reaches nobody");
        assert_eq!(t.endpoint_mut(reply).expect("open").queue.len(), 1, "one response queued");
        // The response taken: rt_take frees an answered call's record.
        t.free_call(call);
        let (again, _) = t.new_call(reply);
        assert_eq!(unpack(again).0, unpack(call).0, "the call's slot is reused");
        assert_eq!(t.complete(call, T_DELIVERED, vec![3]), T_STALE, "an old call id names nothing of the new call");
        t.close_endpoint(reply);
        assert_eq!(t.complete(again, T_DELIVERED, vec![4]), T_STALE, "a caller that is gone receives nothing");
    }

    /// Backpressure is first come, first served without a deadlock: a place
    /// freed on a full endpoint is granted to the first waiting sender
    /// (told with N_ROOM), whose retry takes it while everyone else --
    /// later waiters, senders that do not wait -- is refused; then the next.
    /// (Refusing a woken waiter because another waited behind it let two
    /// waiters refuse each other forever once the queue drained.)
    #[cfg(unix)]
    #[test]
    fn freed_places_are_granted_in_order() {
        let port = || {
            Arc::new(Port {
                doorbell: Doorbell::open().expect("a doorbell"),
                queue: Mutex::new(VecDeque::new()),
                owed: Mutex::new(Vec::new()),
                closed: AtomicBool::new(false),
            })
        };
        let (owner, a, b) = (port(), port(), port());
        let mut t = Transport { domain: 0, endpoints: Vec::new(), free: Vec::new(), calls: Vec::new(), free_calls: Vec::new() };
        let domain = t.domain();
        let fingerprint = [7u8; 8];
        let id = t.open(owner.clone(), 2, fingerprint);
        let key = t.endpoint_mut(id).expect("open").key;
        let message = || Message { data: [b"BOTX".as_slice(), &[1], &fingerprint, &[0]].concat(), call: None, status: T_DELIVERED };
        let send = |t: &mut Transport, waiting: Option<(&Arc<Port>, i64)>| {
            t.enqueue(domain, id, key, message(), waiting.map(|(p, token)| (Arc::downgrade(p), token)))
        };
        // What rt_take does: one message out, the freed place granted.
        let take = |t: &mut Transport| {
            let e = t.endpoint_mut(id).expect("open");
            let m = e.queue.pop_front().expect("a message");
            e.bytes -= m.data.len();
            e.grant(id);
        };
        let rooms = |p: &Arc<Port>| lock(&p.queue).drain(..).filter(|n| n.0 == N_ROOM).count();
        assert_eq!(send(&mut t, None), T_DELIVERED);
        assert_eq!(send(&mut t, None), T_DELIVERED);
        assert_eq!(send(&mut t, Some((&a, 1))), T_FULL);
        assert_eq!(send(&mut t, Some((&b, 2))), T_FULL);
        take(&mut t);
        assert_eq!((rooms(&a), rooms(&b)), (1, 0), "the first waiter is told");
        assert_eq!(send(&mut t, None), T_FULL, "a sender that does not wait never takes a granted place");
        assert_eq!(send(&mut t, Some((&b, 2))), T_FULL, "nor a later waiter");
        assert_eq!(t.endpoint_mut(id).expect("open").waiters.len(), 1, "a waiter's retry does not queue it twice");
        assert_eq!(send(&mut t, Some((&a, 1))), T_DELIVERED, "the granted waiter's retry takes its place");
        take(&mut t);
        take(&mut t);
        assert_eq!(rooms(&b), 1, "then the next waiter, even with the queue drained");
        assert_eq!(send(&mut t, Some((&b, 2))), T_DELIVERED);
        assert_eq!(send(&mut t, None), T_DELIVERED, "with nobody waiting, a free place is anyone's");
        let e = t.endpoint_mut(id).expect("open");
        assert!(e.waiters.is_empty() && e.granted.is_empty());
    }
}
