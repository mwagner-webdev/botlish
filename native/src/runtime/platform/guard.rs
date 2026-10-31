//! The POSIX native stack-overflow guard (MACOS-AARCH64-MILESTONE-4.md),
//! shared by the hosts whose faults are signals: Linux x86-64 and AArch64
//! and macOS AArch64 (Windows' is windows.rs, by the same contract: mod.rs).
//! What differs by host is only how the current thread's stack is found and
//! how a thread is named (`current_stack`, `thread_token`: linux.rs,
//! macos.rs).
//!
//! A fault on the guarded thread at an address in the guard region of the
//! stack running now -- the thread's own, or the coroutine stack it switched
//! to (runtime/coroutine.rs) -- is that stack's exhaustion: the handler
//! writes the driver's result line `error {NATIVE LIMIT STACK} {...}` (a
//! standalone executable: to its standard error) and ends the process with
//! `_exit`. Any other fault -- another address, another thread, a guard not
//! running now -- goes to the disposition the process had before the guard
//! was installed, never to NATIVE LIMIT STACK.
//!
//! Why that is a valid recovery: NATIVE LIMIT STACK is terminal for a native
//! invocation (no Botlish handler catches it, on any host or backend), so
//! nothing of the run is resumed. The handler never returns into the
//! faulting code, never unwinds a frame (Rust, C, assembly or Botlish),
//! runs no destructor and touches neither the heap, the collector nor a
//! coroutine: there is no runtime state to restore because the run is over.
//! It runs on an alternate signal stack of its own (SA_ONSTACK): the stack
//! that overflowed cannot hold its frame, and a coroutine stack never holds a
//! handler's. It reads only lock-free atomics this same thread stored before
//! the fault, and calls only write, _exit, sigaction and raise, which POSIX
//! lists as async-signal-safe (and the host's thread_token: gettid on Linux,
//! pthread_self on macOS). The line is the text the driver writes for an
//! RtError::StackOverflow (runtime/error.rs), so the host reads it the
//! ordinary way.
//!
//! Which stack runs is published by the runtime, never inferred by the
//! handler: `set_active_stack` on every coroutine switch, by the side that
//! arrives (runtime/coroutine.rs), so the pushes of a switch land on the
//! stack it leaves while that stack is still the published one.
//! Publication is a double buffer -- the new bounds go to the slot not in
//! use, then one release store selects it -- so a fault at any instruction,
//! a publication's own included, reads one consistent (guard, stack) pair.
//!
//! One guard per process, installed by the thread that runs Botlish code
//! (the driver's and an executable's worker thread, main.rs and aot.rs), and
//! only that thread publishes while it is installed.
use crate::runtime::native_stack::NativeStack;
use std::cell::UnsafeCell;
use std::io;
use std::mem::MaybeUninit;
use std::sync::atomic::{AtomicBool, AtomicI32, AtomicUsize, Ordering};

/// GUARDED's value while no guard is installed.
const UNGUARDED: usize = 0;
/// GUARDED's value while a guard is being installed or removed: every fault
/// is deferred.
const BUSY: usize = usize::MAX;
/// The guarded thread's `thread_token`, or UNGUARDED or BUSY.
static GUARDED: AtomicUsize = AtomicUsize::new(UNGUARDED);
/// Two slots of the active stack's (guard_low, low_bound) and the one in use.
static SLOTS: [[AtomicUsize; 2]; 2] = [[AtomicUsize::new(0), AtomicUsize::new(0)], [AtomicUsize::new(0), AtomicUsize::new(0)]];
static SLOT: AtomicUsize = AtomicUsize::new(0);
/// A standalone executable reports to standard error and exits 1.
static EXECUTABLE: AtomicBool = AtomicBool::new(false);
/// Where the driver's result lines go (set_result_file): standard output,
/// or the file of botlish-native's `--result`.
static RESULT_FD: AtomicI32 = AtomicI32::new(libc::STDOUT_FILENO);
const OVERFLOW_LINE: &[u8] = super::OVERFLOW_LINE;

/// The signals a guard hit raises: SIGSEGV, or SIGBUS (macOS reports a
/// protection fault on a mapped page so).
const SIGNALS: [libc::c_int; 2] = [libc::SIGSEGV, libc::SIGBUS];

/// The dispositions SIGNALS had before the guard: written before the handler
/// is installed and only read while it is.
struct Previous(UnsafeCell<[MaybeUninit<libc::sigaction>; 2]>);
// SAFETY: written only by `OverflowGuard::install` before the handler that
// reads it exists, under GUARDED's BUSY state (one installer at a time).
unsafe impl Sync for Previous {}
static PREVIOUS: Previous = Previous(UnsafeCell::new([MaybeUninit::uninit(), MaybeUninit::uninit()]));

/// Makes FILE the one the driver's overflow report is written to, with its
/// other result lines: the `--result` file, so that a program's own
/// standard output never carries it. FILE must stay open while a guard is
/// installed.
pub fn set_result_file(file: &std::fs::File) {
    RESULT_FD.store(std::os::unix::io::AsRawFd::as_raw_fd(file), Ordering::Relaxed);
}

/// Makes STACK the stack whose guard region the handler reports as an
/// overflow: the stack this thread runs on from now (runtime/coroutine.rs
/// calls it on arriving on a stack). A no-op while no guard is installed.
/// Inlined, and only atomic stores: it adds no frame to the stack it is
/// called on.
#[inline(always)]
pub fn set_active_stack(stack: &NativeStack) {
    if GUARDED.load(Ordering::Relaxed) == UNGUARDED {
        return;
    }
    publish(stack);
}

#[inline(always)]
fn publish(stack: &NativeStack) {
    let next = SLOT.load(Ordering::Relaxed) ^ 1;
    SLOTS[next][0].store(stack.guard_low, Ordering::Relaxed);
    SLOTS[next][1].store(stack.low_bound, Ordering::Relaxed);
    SLOT.store(next, Ordering::Release);
}

/// The (guard_low, low_bound) the handler would read now, while a guard is
/// installed: what the runtime last published (tests).
pub fn published_stack() -> Option<(usize, usize)> {
    match GUARDED.load(Ordering::Acquire) {
        UNGUARDED | BUSY => None,
        _ => {
            let slot = SLOT.load(Ordering::Acquire);
            Some((SLOTS[slot][0].load(Ordering::Relaxed), SLOTS[slot][1].load(Ordering::Relaxed)))
        }
    }
}

/// Whether a fault at ADDRESS, on the thread running the handler, is the
/// exhaustion of the stack published as running.
#[inline(always)]
fn is_overflow(address: usize) -> bool {
    let guarded = GUARDED.load(Ordering::Acquire);
    if guarded == UNGUARDED || guarded == BUSY || guarded != super::thread_token() {
        return false;
    }
    let slot = SLOT.load(Ordering::Acquire);
    let guard_low = SLOTS[slot][0].load(Ordering::Relaxed);
    let low_bound = SLOTS[slot][1].load(Ordering::Relaxed);
    address >= guard_low && address < low_bound
}

extern "C" fn fault_handler(signal: libc::c_int, info: *mut libc::siginfo_t, _: *mut libc::c_void) {
    // SAFETY: the kernel hands an SA_SIGINFO handler a valid siginfo_t.
    let (address, code) = unsafe { ((*info).si_addr() as usize, (*info).si_code) };
    if is_overflow(address) {
        report_overflow();
    }
    defer(signal, code);
}

/// Writes the overflow line and ends the process: exit status 0 for the
/// driver (the line is its result), 1 for a standalone executable.
fn report_overflow() -> ! {
    let executable = EXECUTABLE.load(Ordering::Relaxed);
    let fd = if executable { libc::STDERR_FILENO } else { RESULT_FD.load(Ordering::Relaxed) };
    let mut rest = OVERFLOW_LINE;
    while !rest.is_empty() {
        // SAFETY: write(2) of a static buffer.
        let written = unsafe { libc::write(fd, rest.as_ptr().cast(), rest.len()) };
        if written > 0 {
            rest = &rest[written as usize..];
        } else if written < 0 && io::Error::last_os_error().kind() == io::ErrorKind::Interrupted {
            continue;
        } else {
            break;
        }
    }
    // SAFETY: _exit(2) has no preconditions.
    unsafe { libc::_exit(if executable { 1 } else { 0 }) }
}

/// Writes the fatal report of a run that cannot go on and ends the process
/// (C-CALLBACK-MILESTONE-1.md: a callback C called that failed, or that ran
/// where no execution environment permits it): RESULT, the driver's result
/// line, to the result file with exit status 0 while the driver's guard is
/// installed (its result, as the overflow line is); else LINE on standard
/// error with exit status 1 (a standalone executable, a native library's
/// host). Only write(2) and _exit(2): it runs inside C's frames, whose
/// locks atexit handlers or stdio might need, and never returns to them.
pub fn report_fatal(result: &[u8], line: &[u8]) -> ! {
    let guarded = !matches!(GUARDED.load(Ordering::Relaxed), UNGUARDED | BUSY);
    let driver = guarded && !EXECUTABLE.load(Ordering::Relaxed);
    let (fd, mut rest) = if driver { (RESULT_FD.load(Ordering::Relaxed), result) } else { (libc::STDERR_FILENO, line) };
    while !rest.is_empty() {
        // SAFETY: write(2) of a live buffer.
        let written = unsafe { libc::write(fd, rest.as_ptr().cast(), rest.len()) };
        if written > 0 {
            rest = &rest[written as usize..];
        } else if written < 0 && io::Error::last_os_error().kind() == io::ErrorKind::Interrupted {
            continue;
        } else {
            break;
        }
    }
    // SAFETY: _exit(2) has no preconditions.
    unsafe { libc::_exit(if driver { 0 } else { 1 }) }
}

/// The si_code values of a fault an instruction raised, which POSIX names
/// and Linux (asm-generic/siginfo.h) and Darwin (sys/signal.h) number alike.
const SEGV_MAPERR: libc::c_int = 1;
const SEGV_ACCERR: libc::c_int = 2;
const BUS_ADRALN: libc::c_int = 1;
const BUS_ADRERR: libc::c_int = 2;
const BUS_OBJERR: libc::c_int = 3;

/// Hands SIGNAL to the disposition the process had before the guard -- an
/// ignored one becomes the default: a fault cannot be ignored -- exactly as
/// if the guard had never been installed. A fault an instruction raised
/// (CODE one of the fault codes above) happens again when the handler
/// returns and that instruction runs again, now under that disposition (the
/// default ends the process with the signal; Rust's own reports a hit of the
/// guard it knows). Any other signal -- sent by a process, or a fault code
/// not listed -- is raised again, so that it is never lost. Never relabel an
/// unrelated fault.
fn defer(signal: libc::c_int, code: libc::c_int) {
    let index = if signal == SIGNALS[0] { 0 } else { 1 };
    let faulted = match signal {
        libc::SIGSEGV => code == SEGV_MAPERR || code == SEGV_ACCERR,
        _ => code == BUS_ADRALN || code == BUS_ADRERR || code == BUS_OBJERR,
    };
    // SAFETY: PREVIOUS[index] was initialized before this handler was
    // installed; sigaction and raise are async-signal-safe.
    unsafe {
        let mut action = (*PREVIOUS.0.get())[index].assume_init();
        if action.sa_sigaction == libc::SIG_IGN {
            action.sa_sigaction = libc::SIG_DFL;
        }
        libc::sigaction(signal, &action, std::ptr::null_mut());
        if !faulted {
            libc::raise(signal);
        }
    }
}

/// The installed guard: the handler for SIGSEGV and SIGBUS and this thread's
/// alternate signal stack, and the published stack. Dropping it restores
/// what was there before.
pub struct OverflowGuard {
    _alt_stack: Vec<u8>,
    old_stack: libc::stack_t,
}

impl OverflowGuard {
    /// Installs the guard for the driver (botlish-native and the driver
    /// protocol of an executable, runtime/aot.rs): the overflow line goes to
    /// the result descriptor and the process exits 0. STACK is this thread's
    /// own stack, the one published first.
    pub fn install(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, false)
    }

    /// Installs the guard for a standalone executable's own run: the line goes
    /// to standard error and the process exits 1.
    pub fn install_executable(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, true)
    }

    fn install_mode(stack: &NativeStack, executable: bool) -> io::Result<Self> {
        if stack.guard_low >= stack.low_bound {
            return Err(io::Error::new(io::ErrorKind::Unsupported, "the thread's stack has no confirmed guard"));
        }
        if GUARDED.compare_exchange(UNGUARDED, BUSY, Ordering::AcqRel, Ordering::Relaxed).is_err() {
            return Err(io::Error::new(io::ErrorKind::AlreadyExists, "a stack-overflow guard is already installed"));
        }
        // At least 64 KiB, and the host's SIGSTKSZ (128 KiB on macOS): the
        // handler itself needs little, the kernel's signal frame more.
        let mut alt_stack = vec![0u8; libc::SIGSTKSZ.max(64 * 1024)];
        // SAFETY: plain POSIX calls on this thread's own signal state; every
        // failure undoes what came before it.
        unsafe {
            let previous = &mut *PREVIOUS.0.get();
            for (slot, signal) in previous.iter_mut().zip(SIGNALS) {
                if libc::sigaction(signal, std::ptr::null(), slot.as_mut_ptr()) != 0 {
                    let error = io::Error::last_os_error();
                    GUARDED.store(UNGUARDED, Ordering::Release);
                    return Err(error);
                }
            }
            let mut old_stack = std::mem::zeroed();
            let new_stack = libc::stack_t { ss_sp: alt_stack.as_mut_ptr().cast(), ss_flags: 0, ss_size: alt_stack.len() };
            if libc::sigaltstack(&new_stack, &mut old_stack) != 0 {
                let error = io::Error::last_os_error();
                GUARDED.store(UNGUARDED, Ordering::Release);
                return Err(error);
            }
            publish(stack);
            EXECUTABLE.store(executable, Ordering::Relaxed);
            let mut action: libc::sigaction = std::mem::zeroed();
            action.sa_sigaction = fault_handler as *const () as usize;
            action.sa_flags = libc::SA_SIGINFO | libc::SA_ONSTACK;
            libc::sigemptyset(&mut action.sa_mask);
            for (installed, signal) in SIGNALS.into_iter().enumerate() {
                if libc::sigaction(signal, &action, std::ptr::null_mut()) != 0 {
                    let error = io::Error::last_os_error();
                    for (slot, signal) in previous.iter().zip(SIGNALS).take(installed) {
                        libc::sigaction(signal, slot.as_ptr(), std::ptr::null_mut());
                    }
                    libc::sigaltstack(&old_stack, std::ptr::null_mut());
                    GUARDED.store(UNGUARDED, Ordering::Release);
                    return Err(error);
                }
            }
            GUARDED.store(super::thread_token(), Ordering::Release);
            Ok(Self { _alt_stack: alt_stack, old_stack })
        }
    }
}

impl Drop for OverflowGuard {
    fn drop(&mut self) {
        GUARDED.store(BUSY, Ordering::Release);
        // SAFETY: restores the dispositions and the alternate stack install
        // replaced; PREVIOUS is initialized while a guard exists.
        unsafe {
            let previous = &*PREVIOUS.0.get();
            for (slot, signal) in previous.iter().zip(SIGNALS) {
                libc::sigaction(signal, slot.as_ptr(), std::ptr::null_mut());
            }
            libc::sigaltstack(&self.old_stack, std::ptr::null_mut());
        }
        GUARDED.store(UNGUARDED, Ordering::Release);
    }
}
