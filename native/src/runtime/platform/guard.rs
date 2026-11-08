//! The POSIX native stack-overflow guard (MACOS-AARCH64-MILESTONE-4.md),
//! shared by the hosts whose faults are signals: Linux x86-64 and AArch64
//! and macOS AArch64 (Windows' is windows.rs, by the same contract: mod.rs).
//! What differs by host is only how the current thread's stack is found and
//! how a thread is named (`current_stack`, `thread_token`: linux.rs,
//! macos.rs).
//!
//! A fault on a guarded thread at an address in the guard region of the
//! stack that thread runs now -- its own, or the coroutine stack it switched
//! to (runtime/coroutine.rs) -- is that stack's exhaustion: the handler
//! writes the thread's label (empty but in the concurrent-VM harness) and
//! the driver's result line `error {NATIVE LIMIT STACK} {...}` (a
//! standalone executable: to its standard error) and ends the process with
//! `_exit`. Any other fault -- another address, an unguarded thread, a guard
//! not running now on the faulting thread -- goes to the disposition the
//! process had before the first guard was installed, never to NATIVE LIMIT
//! STACK.
//!
//! Why that is a valid recovery: NATIVE LIMIT STACK is terminal for a native
//! invocation (no Botlish handler catches it, on any host or backend), so
//! nothing of the run is resumed. The handler never returns into the
//! faulting code, never unwinds a frame (Rust, C, assembly or Botlish),
//! runs no destructor and touches neither the heap, the collector nor a
//! coroutine: there is no runtime state to restore because the run is over.
//! It runs on an alternate signal stack of its own (SA_ONSTACK): the stack
//! that overflowed cannot hold its frame, and a coroutine stack never holds a
//! handler's. It reads only lock-free atomics the faulting thread stored
//! before the fault (its record, found by its token: records.rs), and calls
//! only write, _exit, sigaction and raise, which POSIX lists as
//! async-signal-safe (and the host's thread_token: gettid on Linux,
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
//! One guard per thread that runs Botlish code (the driver's and an
//! executable's worker thread, main.rs and aot.rs; each VM thread of the
//! driver's concurrent-VM harness), any number of them at once
//! (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md): each has its own record, its
//! own alternate signal stack and its own publication, and only it publishes
//! into its record. The process's handler is installed with the first guard
//! and the previous dispositions put back after the last one drops.
use super::records::{self, Record};
use crate::runtime::native_stack::NativeStack;
use std::cell::UnsafeCell;
use std::io;
use std::mem::MaybeUninit;
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::Mutex;

/// How many guards are installed: the process's handler is while this is
/// not 0. Installation and removal only, never a handler: a lock is fine.
static INSTALLED: Mutex<usize> = Mutex::new(0);
/// Where the driver's result lines go (set_result_file): standard output,
/// or the file of botlish-native's `--result`.
static RESULT_FD: AtomicI32 = AtomicI32::new(libc::STDOUT_FILENO);
const OVERFLOW_LINE: &[u8] = super::OVERFLOW_LINE;

/// The signals a guard hit raises: SIGSEGV, or SIGBUS (macOS reports a
/// protection fault on a mapped page so).
const SIGNALS: [libc::c_int; 2] = [libc::SIGSEGV, libc::SIGBUS];

/// The dispositions SIGNALS had before the first guard: written before the
/// handler is installed and only read while it is.
struct Previous(UnsafeCell<[MaybeUninit<libc::sigaction>; 2]>);
// SAFETY: written only by `OverflowGuard::install` before the handler that
// reads it exists, under INSTALLED's lock (one installer at a time).
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
/// overflow on this thread: the stack this thread runs on from now
/// (runtime/coroutine.rs calls it on arriving on a stack). A no-op on a
/// thread without a guard; never another thread's record. Inlined, and only
/// a thread-local read and atomic stores: it adds no frame to the stack it
/// is called on.
#[inline(always)]
pub fn set_active_stack(stack: &NativeStack) {
    records::publish((stack.guard_low, stack.low_bound));
}

/// The (guard_low, low_bound) the handler would read now for a fault on
/// this thread, while it is guarded: what the runtime last published on it
/// (tests).
pub fn published_stack() -> Option<(usize, usize)> {
    records::mine().map(Record::words)
}

/// How many threads are guarded now (tests, the concurrent-VM harness).
pub fn guarded_threads() -> usize {
    records::in_use()
}

/// The faulting thread's record, when a fault at ADDRESS on it -- the
/// thread running the handler -- is the exhaustion of the stack it
/// published as running.
#[inline(always)]
fn is_overflow(address: usize) -> Option<&'static Record> {
    let record = records::find(super::thread_token())?;
    let (guard_low, low_bound) = record.words();
    (address >= guard_low && address < low_bound).then_some(record)
}

extern "C" fn fault_handler(signal: libc::c_int, info: *mut libc::siginfo_t, _: *mut libc::c_void) {
    // SAFETY: the kernel hands an SA_SIGINFO handler a valid siginfo_t.
    let (address, code) = unsafe { ((*info).si_addr() as usize, (*info).si_code) };
    if let Some(record) = is_overflow(address) {
        report_overflow(record);
    }
    defer(signal, code);
}

/// Writes BYTES to FD: write(2) until done, a failure ending it.
fn write_all(fd: libc::c_int, bytes: &[u8]) {
    let mut rest = bytes;
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
}

/// Writes RECORD's label and the overflow line and ends the process: exit
/// status 0 for the driver (the line is its result), 1 for a standalone
/// executable. Terminal for every thread (NATIVE-STACK-OVERFLOW.md): the
/// faulting thread may hold any lock or be inside any foreign code, so no
/// other thread is assumed able to go on.
fn report_overflow(record: &Record) -> ! {
    let executable = record.executable();
    let fd = if executable { libc::STDERR_FILENO } else { record.destination() as libc::c_int };
    let mut label = [0u8; records::LABEL_BYTES];
    let len = record.label(&mut label);
    write_all(fd, &label[..len]);
    write_all(fd, OVERFLOW_LINE);
    // SAFETY: _exit(2) has no preconditions.
    unsafe { libc::_exit(if executable { 1 } else { 0 }) }
}

/// Writes the fatal report of a run that cannot go on and ends the process
/// (C-CALLBACK-MILESTONE-1.md: a callback C called that failed, or that ran
/// where no execution environment permits it): RESULT, the driver's result
/// line, to the result file with exit status 0 while a driver's guard is
/// installed (its result, as the overflow line is) -- after this thread's
/// label when the guard is this thread's own; a foreign thread C created
/// holds none, and its report is the process's, through any guarded
/// thread's record -- else LINE on standard error with exit status 1 (a
/// standalone executable, a native library's host). Only write(2) and
/// _exit(2), and the records' atomic lookups: it runs inside C's frames,
/// whose locks atexit handlers or stdio might need, and never returns to
/// them.
pub fn report_fatal(result: &[u8], line: &[u8]) -> ! {
    let own = records::find(super::thread_token());
    let record = own.or_else(records::any).filter(|r| !r.executable());
    match record {
        Some(record) => {
            let fd = record.destination() as libc::c_int;
            if own.is_some() {
                let mut label = [0u8; records::LABEL_BYTES];
                let len = record.label(&mut label);
                write_all(fd, &label[..len]);
            }
            write_all(fd, result);
        }
        None => write_all(libc::STDERR_FILENO, line),
    }
    // SAFETY: _exit(2) has no preconditions.
    unsafe { libc::_exit(if record.is_some() { 0 } else { 1 }) }
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

/// The installed guard of one thread: its record, its alternate signal
/// stack and, while any guard is installed, the process's handler for
/// SIGSEGV and SIGBUS. Dropping it releases the record and restores the
/// thread's alternate stack, and the last one dropped restores the
/// dispositions the first one replaced.
pub struct OverflowGuard {
    _alt_stack: Vec<u8>,
    old_stack: libc::stack_t,
    record: usize,
}

impl OverflowGuard {
    /// Installs the guard for the driver (botlish-native and the driver
    /// protocol of an executable, runtime/aot.rs): the overflow line goes to
    /// the result descriptor and the process exits 0. STACK is this thread's
    /// own stack, the one published first.
    pub fn install(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, false, b"")
    }

    /// Installs the guard for a standalone executable's own run: the line goes
    /// to standard error and the process exits 1.
    pub fn install_executable(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, true, b"")
    }

    /// Installs the driver's guard with LABEL written before its lines (the
    /// concurrent-VM harness's "vm N "): which thread overflowed is in its
    /// report.
    pub fn install_labelled(stack: &NativeStack, label: &[u8]) -> io::Result<Self> {
        Self::install_mode(stack, false, label)
    }

    /// Installs the guard of a Botlish thread (runtime/thread.rs) in the
    /// record its start reserved (RESERVATION), in the starting thread's
    /// mode: EXECUTABLE, and its report's DESTINATION.
    pub fn install_reserved(stack: &NativeStack, reservation: usize, executable: bool, destination: usize, label: &[u8]) -> io::Result<Self> {
        Self::install_in(stack, executable, Some(destination), label, Some(reservation))
    }

    fn install_mode(stack: &NativeStack, executable: bool, label: &[u8]) -> io::Result<Self> {
        Self::install_in(stack, executable, None, label, None)
    }

    fn install_in(stack: &NativeStack, executable: bool, destination: Option<usize>, label: &[u8], reservation: Option<usize>) -> io::Result<Self> {
        if stack.guard_low >= stack.low_bound {
            return Err(io::Error::new(io::ErrorKind::Unsupported, "the thread's stack has no confirmed guard"));
        }
        if records::mine().is_some() {
            return Err(io::Error::new(io::ErrorKind::AlreadyExists, "this thread's stack-overflow guard is already installed"));
        }
        if label.len() > records::LABEL_BYTES {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "the guard's label is too long"));
        }
        // At least 64 KiB, and the host's SIGSTKSZ (128 KiB on macOS): the
        // handler itself needs little, the kernel's signal frame more.
        let mut alt_stack = vec![0u8; libc::SIGSTKSZ.max(64 * 1024)];
        let mut installed = INSTALLED.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        // SAFETY: plain POSIX calls on the process's dispositions (under the
        // lock: one installer at a time) and this thread's own signal stack;
        // every failure undoes what came before it.
        unsafe {
            if *installed == 0 {
                install_handler()?;
            }
            let mut old_stack = std::mem::zeroed();
            let new_stack = libc::stack_t { ss_sp: alt_stack.as_mut_ptr().cast(), ss_flags: 0, ss_size: alt_stack.len() };
            if libc::sigaltstack(&new_stack, &mut old_stack) != 0 {
                let error = io::Error::last_os_error();
                if *installed == 0 {
                    restore_handler();
                }
                return Err(error);
            }
            let destination = destination.unwrap_or_else(|| RESULT_FD.load(Ordering::Relaxed) as usize);
            match records::claim_as(reservation, super::thread_token(), (stack.guard_low, stack.low_bound), executable, destination, label) {
                Ok(record) => {
                    *installed += 1;
                    Ok(Self { _alt_stack: alt_stack, old_stack, record })
                }
                Err(error) => {
                    libc::sigaltstack(&old_stack, std::ptr::null_mut());
                    if *installed == 0 {
                        restore_handler();
                    }
                    Err(error)
                }
            }
        }
    }
}

/// Saves SIGNALS' dispositions and installs the handler for them.
///
/// # Safety
/// Under INSTALLED's lock, with no guard installed.
unsafe fn install_handler() -> io::Result<()> {
    // SAFETY: the caller's contract; PREVIOUS is written only here.
    unsafe {
        let previous = &mut *PREVIOUS.0.get();
        for (slot, signal) in previous.iter_mut().zip(SIGNALS) {
            if libc::sigaction(signal, std::ptr::null(), slot.as_mut_ptr()) != 0 {
                return Err(io::Error::last_os_error());
            }
        }
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
                return Err(error);
            }
        }
        Ok(())
    }
}

/// Restores the dispositions `install_handler` saved.
///
/// # Safety
/// Under INSTALLED's lock, after `install_handler` succeeded, with no guard
/// left.
unsafe fn restore_handler() {
    // SAFETY: the caller's contract: PREVIOUS is initialized.
    unsafe {
        let previous = &*PREVIOUS.0.get();
        for (slot, signal) in previous.iter().zip(SIGNALS) {
            libc::sigaction(signal, slot.as_ptr(), std::ptr::null_mut());
        }
    }
}

impl Drop for OverflowGuard {
    fn drop(&mut self) {
        // First the record: from now on no fault of this thread is claimed.
        records::release(self.record);
        let mut installed = INSTALLED.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        // SAFETY: restores this thread's alternate stack, and, after the
        // last guard, the dispositions the first replaced (under the lock).
        unsafe {
            libc::sigaltstack(&self.old_stack, std::ptr::null_mut());
            *installed -= 1;
            if *installed == 0 {
                restore_handler();
            }
        }
    }
}
