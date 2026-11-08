//! Windows x86-64 (MSVC): the thread's stack and the stack-overflow guard
//! (WINDOWS-X86-64-MILESTONE-4.md).
//!
//! Windows grows a thread's stack itself. Its reservation is
//! `[DeallocationStack, StackBase)` (`GetCurrentThreadStackLimits`); the
//! committed part sits at the top, with a guard page (`PAGE_GUARD`) directly
//! below it, and the rest of the reservation below that is uncommitted. An
//! access to the guard page commits it and moves the guard down a page;
//! when no room is left for the next guard page above the bottom of the
//! reservation and the thread's stack guarantee, Windows raises
//! `STATUS_STACK_OVERFLOW` (0xC00000FD) on that thread, with the guarantee
//! committed for its handlers to run in. So an exhausted Windows stack is an
//! exception, not a fault in an address range: `NativeStack::guard_low`
//! equals `low_bound` here, and what the guard confirms instead is the
//! system's guard page (`confirmed_guard_page`) and a stack guarantee large
//! enough for its reporting path (`GUARANTEE`).
//!
//! The guard is a vectored exception handler, first in the process's chain,
//! for as long as an `OverflowGuard` lives on some thread: one guard per
//! thread that runs Botlish code (the driver's and an executable's worker
//! thread, main.rs and runtime/aot.rs; each VM thread of the driver's
//! concurrent-VM harness), any number at once, each with its own record
//! (records.rs, PER-THREAD-RUNTIME-STATE-MILESTONE-1.md); the handler is
//! added with the first and removed after the last. Vectored handlers are
//! process-wide; the guard claims an exception only when
//!
//!   * it is `STATUS_STACK_OVERFLOW`,
//!   * on a guarded thread (one holding a record: its thread id),
//!   * at an address (the record's second parameter: the access that could
//!     not grow the stack) inside the reservation of the stack published as
//!     running -- the thread's own, or the coroutine fiber it switched to
//!     (WINDOWS-X86-64-MILESTONE-5.md; runtime/coroutine.rs publishes the
//!     stack it arrives on, after each switch, as on the POSIX hosts),
//!   * and raised by Windows' memory manager, not by software: the record's
//!     flags lack `EXCEPTION_SOFTWARE_ORIGINATE`, which RaiseException sets
//!     (WINDOWS-X86-64-MILESTONE-4.md, "Experiments": 0 for every real
//!     exhaustion, 0x80 for RaiseException's).
//!
//! It then writes the thread's label (empty but in the concurrent-VM
//! harness) and the driver's result line `error {NATIVE LIMIT STACK}
//! {...}` (a standalone executable: to its standard error) with WriteFile
//! and ends the process with TerminateProcess: exit status 0 for the driver
//! (the line is its result), 1 for an executable, as the POSIX guard does
//! (guard.rs). Every other exception -- an access violation anywhere (also
//! in the stack's uncommitted reservation, which only a frame that skipped
//! the guard page reaches: a missing stack probe, never exhaustion), any
//! exception on another thread, a `STATUS_STACK_OVERFLOW` that names no
//! address of the guarded stack or that software raised (RaiseException's)
//! -- continues the search as if the guard did not exist: never
//! relabelled.
//!
//! Which stack runs is published by the runtime, never inferred by the
//! handler (`set_active_stack`), by each thread into its own record only: a
//! double buffer, as the POSIX guard's -- the
//! new bounds go to the slot not in use, then one release store selects it --
//! so an exception at any instruction, a publication's own included, reads
//! one consistent reservation. Every stack it can name has the guarantee the
//! handler needs: the thread's (installation asks it) and every coroutine
//! fiber's (runtime/coroutine/windows.rs asks it on the fiber, before any
//! Botlish code runs there: a fiber starts with none, and its guarantee is
//! its own).
//!
//! Why that is a valid recovery: NATIVE LIMIT STACK is terminal for a native
//! invocation, so nothing of the run is resumed. The handler never returns
//! into the faulting code, never unwinds a frame, runs no destructor, and
//! touches neither the heap, the collector nor a lock: it reads atomics the
//! faulting thread stored before the fault (its record, found by its thread
//! id), makes one WriteFile per partial write of its label and a static line (each writes at least a byte, so at most the line's length)
//! and calls TerminateProcess, which ends every thread of the process
//! without running DLL detach routines, TLS callbacks or the C runtime's
//! exit handlers, and does not return to its caller; should it ever return,
//! the handler fails fast (`int 0x29`, FAST_FAIL_FATAL_APP_EXIT). It runs on
//! the exhausted stack itself -- Windows has no alternate stack for
//! exception handlers -- inside the stack guarantee the kernel committed
//! for it; GUARANTEE is that room, measured (the report's "Experiments").
//!
//! The destination is resolved when a guard is installed, into its record,
//! never in the handler: the `--result` file's handle (`set_result_file`, a file the
//! driver keeps open for the whole run), else the process's standard output
//! (the driver) or standard error (an executable), as GetStdHandle names
//! them then.
use super::records::{self, Record};
use crate::runtime::native_stack::{NativeStack, StackState};
use std::io;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Mutex;
use windows_sys::Win32::Foundation::{EXCEPTION_STACK_OVERFLOW, HANDLE};
use windows_sys::Win32::Storage::FileSystem::WriteFile;
use windows_sys::Win32::System::Console::{GetStdHandle, STD_ERROR_HANDLE, STD_OUTPUT_HANDLE};
use windows_sys::Win32::System::Diagnostics::Debug::{
    AddVectoredExceptionHandler, EXCEPTION_CONTINUE_SEARCH, EXCEPTION_POINTERS, RemoveVectoredExceptionHandler,
};
use windows_sys::Win32::System::Memory::{MEM_COMMIT, MEM_RESERVE, MEMORY_BASIC_INFORMATION, PAGE_GUARD, VirtualQuery};
use windows_sys::Win32::System::SystemServices::EXCEPTION_SOFTWARE_ORIGINATE;
use windows_sys::Win32::System::Threading::{
    GetCurrentProcess, GetCurrentThreadId, GetCurrentThreadStackLimits, SetThreadStackGuarantee, TerminateProcess,
};

/// The stack guarantee the guard needs: the room Windows keeps committed at
/// a stack's end for the handlers of its `STATUS_STACK_OVERFLOW`. Measured
/// on Windows Server 2025 (WINDOWS-X86-64-MILESTONE-4.md, "Experiments"):
/// a vectored handler starts with about the guarantee left above the
/// reservation's last page, which is never committed -- the exception
/// arrives with some 4 KiB more and the dispatcher takes 3.7 to 3.8 KiB of
/// it -- and 3.5 KiB less when the stack ran out in a probe loop
/// (Cranelift's pattern): about 29 KiB with this guarantee, 5.2 KiB on a
/// thread that asked for none. The handler's path is WriteFile (120 bytes)
/// and TerminateProcess of this process, which completed with those 5.2
/// KiB, the least any experiment left (ending another process takes 4.7
/// KiB). So 32 KiB leaves it more than five times what it has been seen to
/// need, where no guarantee leaves it about that. Rust's runtime asks 20
/// KiB for its own threads; the guard asks its own, and refuses to install
/// when the thread does not have it.
pub const GUARANTEE: u32 = 32 << 10;

/// The calling thread's own stack: the reservation the system made for it
/// (`GetCurrentThreadStackLimits`), its lowest address the lowest a frame of
/// it can ever reach. No guard range below it (`guard_low == low_bound`):
/// Windows reports its exhaustion by an exception (the module doc). Its
/// bounds limit the frame walk.
pub fn current_stack() -> io::Result<NativeStack> {
    let (mut low, mut high) = (0, 0);
    // SAFETY: writes the two bounds.
    unsafe { GetCurrentThreadStackLimits(&mut low, &mut high) };
    if low == 0 || high <= low {
        return Err(io::Error::new(io::ErrorKind::InvalidData, "GetCurrentThreadStackLimits reported no stack"));
    }
    Ok(NativeStack { low_bound: low, high_bound: high, guard_low: low, saved_sp: None, state: StackState::Active })
}

/// The calling thread's id: what the guard records for the thread it guards
/// and compares in its handler (a read of the thread's own TEB).
#[inline(always)]
pub fn thread_token() -> usize {
    // SAFETY: no preconditions.
    unsafe { GetCurrentThreadId() as usize }
}

/// The region of pages VirtualQuery reports at ADDRESS: its base, its size,
/// its state and its protection. None when the query fails.
fn region(address: usize) -> Option<(usize, usize, u32, u32)> {
    // SAFETY: a query of this process's own address space into a local.
    unsafe {
        let mut info: MEMORY_BASIC_INFORMATION = std::mem::zeroed();
        if VirtualQuery(address as *const _, &mut info, std::mem::size_of::<MEMORY_BASIC_INFORMATION>()) == 0 {
            return None;
        }
        Some((info.BaseAddress as usize, info.RegionSize, info.State, info.Protect))
    }
}

/// Whether STACK -- the calling thread's -- still grows by Windows' guard
/// page: from its lowest address an uncommitted reservation, and directly
/// above that a committed guard page (`PAGE_GUARD`). Confirmed, never
/// assumed: a stack with nothing left to grow (committed to its bottom) or
/// laid out otherwise reports its exhaustion as no exception the guard
/// claims, and the guard refuses it.
pub fn confirmed_guard_page(stack: &NativeStack) -> bool {
    let Some((base, size, state, _)) = region(stack.low_bound) else { return false };
    if base != stack.low_bound || state != MEM_RESERVE {
        return false;
    }
    let Some((guard, _, state, protect)) = region(base + size) else { return false };
    guard == base + size && guard < stack.high_bound && state == MEM_COMMIT && protect & PAGE_GUARD != 0
}

/// How many bytes of STACK's reservation are committed (VirtualQuery's
/// regions within its bounds): what the stack charges against the system's
/// commit limit, touched or not (tests, the report's memory measurement).
pub fn committed_bytes(stack: &NativeStack) -> usize {
    let (mut at, mut committed) = (stack.low_bound, 0);
    while at < stack.high_bound {
        let Some((base, size, state, _)) = region(at) else { break };
        let end = (base + size).min(stack.high_bound);
        if state == MEM_COMMIT {
            committed += end - at.max(base);
        }
        at = end;
    }
    committed
}

/// The calling thread's stack guarantee: SetThreadStackGuarantee of 0 asks.
pub fn stack_guarantee() -> u32 {
    let mut size = 0u32;
    // SAFETY: a query of the calling thread's own guarantee.
    unsafe { SetThreadStackGuarantee(&mut size) };
    size
}

/// The process's vectored handler and how many guards are installed: added
/// with the first, removed after the last. Installation and removal only,
/// never the handler: a lock is fine.
struct Installed {
    guards: usize,
    handler: usize,
}
static INSTALLED: Mutex<Installed> = Mutex::new(Installed { guards: 0, handler: 0 });
/// The `--result` file's handle (set_result_file), 0 for none.
static RESULT: AtomicUsize = AtomicUsize::new(0);
const OVERFLOW_LINE: &[u8] = super::OVERFLOW_LINE;

/// Makes FILE where the driver's overflow report is written, with its other
/// result lines: the `--result` file, so that a program's own standard
/// output never carries it. Read when a guard is installed; FILE must stay
/// open while one is.
pub fn set_result_file(file: &std::fs::File) {
    use std::os::windows::io::AsRawHandle;
    RESULT.store(file.as_raw_handle() as usize, Ordering::Relaxed);
}

/// Makes STACK the stack whose reservation the handler reports an overflow
/// of on this thread: the stack this thread runs on from now
/// (runtime/coroutine.rs calls it on arriving on a stack). A no-op on a
/// thread without a guard; never another thread's record. Inlined, and only
/// a thread-local read and atomic stores: it adds no frame to the stack it
/// is called on.
#[inline(always)]
pub fn set_active_stack(stack: &NativeStack) {
    records::publish((stack.low_bound, stack.high_bound));
}

/// The reservation `[low, high)` the handler would read now for an
/// exception on this thread, while it is guarded: what the runtime last
/// published on it (tests).
pub fn published_stack() -> Option<(usize, usize)> {
    records::mine().map(Record::words)
}

/// How many threads are guarded now (tests, the concurrent-VM harness).
pub fn guarded_threads() -> usize {
    records::in_use()
}

/// The record of THREAD, when an exception with CODE and FLAGS, whose
/// record holds PARAMETERS, raised on THREAD, is the exhaustion of the
/// stack THREAD published as running.
#[inline(always)]
fn is_overflow(code: i32, flags: u32, parameters: &[usize], thread: usize) -> Option<&'static Record> {
    if code != EXCEPTION_STACK_OVERFLOW || flags & EXCEPTION_SOFTWARE_ORIGINATE != 0 {
        return None;
    }
    let record = records::find(thread)?;
    let (low, high) = record.words();
    (parameters.len() >= 2 && parameters[1] >= low && parameters[1] < high).then_some(record)
}

unsafe extern "system" fn handler(info: *mut EXCEPTION_POINTERS) -> i32 {
    // SAFETY: Windows hands a vectored handler a valid record.
    let record = unsafe { &*(*info).ExceptionRecord };
    let count = (record.NumberParameters as usize).min(record.ExceptionInformation.len());
    if let Some(guard) = is_overflow(record.ExceptionCode, record.ExceptionFlags, &record.ExceptionInformation[..count], thread_token()) {
        let out = guard.destination() as HANDLE;
        let mut label = [0u8; records::LABEL_BYTES];
        let len = guard.label(&mut label);
        write_all(out, &label[..len]);
        write_all(out, OVERFLOW_LINE);
        terminate(guard.executable());
    }
    EXCEPTION_CONTINUE_SEARCH
}

/// Writes BYTES to OUT: one WriteFile per partial write, at most the
/// bytes' length of them; a failed one ends the attempt (nothing is
/// retried).
fn write_all(out: HANDLE, bytes: &[u8]) {
    let mut rest = bytes;
    while !rest.is_empty() {
        let mut written = 0u32;
        // SAFETY: a live buffer, synchronous I/O on a handle that stays
        // open while the guard is installed.
        let ok = unsafe { WriteFile(out, rest.as_ptr(), rest.len() as u32, &mut written, std::ptr::null_mut()) };
        if ok == 0 || written == 0 || written as usize > rest.len() {
            break;
        }
        rest = &rest[written as usize..];
    }
}

/// Ends the process: exit status 0 for the driver (the line is its result),
/// 1 for a standalone executable (EXECUTABLE). Terminal for every thread
/// (NATIVE-STACK-OVERFLOW.md): the faulting thread may hold any lock.
fn terminate(executable: bool) -> ! {
    let status = if executable { 1 } else { 0 };
    // SAFETY: ends this process; TerminateProcess of the calling process
    // does not return.
    unsafe { TerminateProcess(GetCurrentProcess(), status) };
    // SAFETY: __fastfail(FAST_FAIL_FATAL_APP_EXIT): ends the process with
    // no handler run, should TerminateProcess ever have returned.
    unsafe { std::arch::asm!("int 0x29", in("ecx") 7, options(noreturn, nostack)) }
}

/// The installed guard of one thread: its record and, while any guard is
/// installed, the process's vectored handler, first in the chain. Dropping
/// it releases the record; the last one dropped removes the handler (the
/// thread keeps its stack guarantee: Windows never lowers one).
pub struct OverflowGuard {
    record: usize,
}

impl OverflowGuard {
    /// Installs the guard for the driver (botlish-native and the driver
    /// protocol of an executable, runtime/aot.rs): the overflow line goes to
    /// the result file (or standard output) and the process exits 0. STACK
    /// is the calling thread's own stack, the one published first.
    pub fn install(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, false, b"")
    }

    /// Installs the guard for a standalone executable's own run: the line goes
    /// to standard error and the process exits 1.
    pub fn install_executable(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, true, b"")
    }

    /// Installs the driver's guard with LABEL written before its line (the
    /// concurrent-VM harness's "vm N ").
    pub fn install_labelled(stack: &NativeStack, label: &[u8]) -> io::Result<Self> {
        Self::install_mode(stack, false, label)
    }

    /// Installs the guard of a Botlish thread (runtime/thread.rs) in the
    /// record its start reserved, in the starting thread's mode.
    pub fn install_reserved(stack: &NativeStack, reservation: usize, executable: bool, destination: usize, label: &[u8]) -> io::Result<Self> {
        Self::install_in(stack, executable, Some(destination), label, Some(reservation))
    }

    fn install_mode(stack: &NativeStack, executable: bool, label: &[u8]) -> io::Result<Self> {
        Self::install_in(stack, executable, None, label, None)
    }

    fn install_in(stack: &NativeStack, executable: bool, given: Option<usize>, label: &[u8], reservation: Option<usize>) -> io::Result<Self> {
        if records::mine().is_some() {
            return Err(io::Error::new(io::ErrorKind::AlreadyExists, "this thread's stack-overflow guard is already installed"));
        }
        let prepared = Self::prepare(stack, executable)?;
        let destination = given.unwrap_or(prepared);
        let mut installed = INSTALLED.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        if installed.guards == 0 {
            // SAFETY: a handler with the vectored handler's ABI, first in the
            // chain; removed after the last guard drops.
            let handler = unsafe { AddVectoredExceptionHandler(1, Some(handler)) };
            if handler.is_null() {
                return Err(io::Error::new(io::ErrorKind::Other, "AddVectoredExceptionHandler failed"));
            }
            installed.handler = handler as usize;
        }
        match records::claim_as(reservation, thread_token(), (stack.low_bound, stack.high_bound), executable, destination, label) {
            Ok(record) => {
                installed.guards += 1;
                Ok(OverflowGuard { record })
            }
            Err(error) => {
                if installed.guards == 0 {
                    // SAFETY: the handler added above.
                    unsafe { RemoveVectoredExceptionHandler(installed.handler as *mut core::ffi::c_void) };
                    installed.handler = 0;
                }
                Err(error)
            }
        }
    }

    /// This thread's stack guarantee and guard page, confirmed, and the
    /// report's destination.
    fn prepare(stack: &NativeStack, executable: bool) -> io::Result<usize> {
        let mut size = GUARANTEE;
        // SAFETY: the calling thread's own guarantee; a request smaller than
        // the current one is ignored, so it never lowers it.
        if unsafe { SetThreadStackGuarantee(&mut size) } == 0 {
            return Err(io::Error::last_os_error());
        }
        let guarantee = stack_guarantee();
        if guarantee < GUARANTEE {
            return Err(io::Error::new(io::ErrorKind::Unsupported,
                format!("the thread's stack guarantee is {guarantee} bytes, the guard needs {GUARANTEE}")));
        }
        if !confirmed_guard_page(stack) {
            return Err(io::Error::new(io::ErrorKind::Unsupported, "the thread's stack has no confirmed guard page"));
        }
        // SAFETY: GetStdHandle reads the process's standard handles.
        Ok(match RESULT.load(Ordering::Relaxed) {
            _ if executable => (unsafe { GetStdHandle(STD_ERROR_HANDLE) }) as usize,
            0 => (unsafe { GetStdHandle(STD_OUTPUT_HANDLE) }) as usize,
            file => file,
        })
    }
}

impl Drop for OverflowGuard {
    fn drop(&mut self) {
        // First the record: from now on no exception of this thread is
        // claimed.
        records::release(self.record);
        let mut installed = INSTALLED.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        installed.guards -= 1;
        if installed.guards == 0 {
            // SAFETY: the handler the first guard added.
            unsafe { RemoveVectoredExceptionHandler(installed.handler as *mut core::ffi::c_void) };
            installed.handler = 0;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn this_threads_stack_contains_the_stack_pointer_and_grows_by_a_guard_page() {
        let stack = current_stack().unwrap();
        let local = 0u8;
        assert!(stack.contains(&local as *const u8 as usize, 1));
        assert_eq!(stack.guard_low, stack.low_bound, "no address range is a guard on Windows");
        assert!(confirmed_guard_page(&stack), "the system's guard page lies above the uncommitted reservation");
    }

    /// A reservation laid out as a stack: confirmed only while an
    /// uncommitted bottom lies directly below a committed guard page.
    #[test]
    fn a_guard_page_is_confirmed_only_above_an_uncommitted_reservation() {
        use windows_sys::Win32::System::Memory::{MEM_RELEASE, PAGE_READWRITE, VirtualAlloc, VirtualFree};
        const PAGE: usize = 4096;
        // SAFETY: a private reservation, committed and released here.
        unsafe {
            let base = VirtualAlloc(std::ptr::null(), 16 * PAGE, MEM_RESERVE, PAGE_READWRITE) as usize;
            assert_ne!(base, 0);
            let stack = NativeStack { low_bound: base, high_bound: base + 16 * PAGE, guard_low: base, saved_sp: None, state: StackState::Active };
            assert!(!confirmed_guard_page(&stack), "nothing committed");
            assert_ne!(VirtualAlloc((base + 12 * PAGE) as *const _, 4 * PAGE, MEM_COMMIT, PAGE_READWRITE), std::ptr::null_mut());
            assert!(!confirmed_guard_page(&stack), "committed directly above the reservation: no guard page");
            assert_ne!(VirtualAlloc((base + 11 * PAGE) as *const _, PAGE, MEM_COMMIT, PAGE_READWRITE | PAGE_GUARD), std::ptr::null_mut());
            assert!(confirmed_guard_page(&stack), "a guard page above the reservation");
            assert_ne!(VirtualAlloc(base as *const _, 11 * PAGE, MEM_COMMIT, PAGE_READWRITE), std::ptr::null_mut());
            assert!(!confirmed_guard_page(&stack), "committed to its bottom: nothing left to grow");
            VirtualFree(base as *mut _, 0, MEM_RELEASE);
        }
    }

    /// Only STATUS_STACK_OVERFLOW the memory manager raised, on the guarded
    /// thread, at an address of its stack, is an overflow; nothing is one
    /// while no guard is installed.
    #[test]
    fn only_the_guarded_stacks_overflow_is_claimed() {
        const ACCESS_VIOLATION: i32 = 0xC000_0005_u32 as i32;
        let stack = current_stack().unwrap();
        let inside = stack.low_bound + 4096;
        let me = thread_token();
        let claimed = |code, flags, parameters: &[usize], thread| is_overflow(code, flags, parameters, thread).is_some();
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me), "no guard installed");
        let guard = OverflowGuard::install(&stack).expect("the guard installs");
        assert!(stack_guarantee() >= GUARANTEE);
        assert!(claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me));
        assert!(claimed(EXCEPTION_STACK_OVERFLOW, 0, &[0, stack.high_bound - 1], me));
        assert!(!claimed(ACCESS_VIOLATION, 0, &[1, inside], me), "an access violation in the stack");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, EXCEPTION_SOFTWARE_ORIGINATE, &[1, inside], me), "raised by software");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me + 4), "another thread");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[], me), "raised with no address");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, stack.low_bound - 1], me), "below the reservation");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, stack.high_bound], me), "above it");
        assert!(OverflowGuard::install(&stack).is_err(), "one guard per thread");
        // Another thread installs its own guard beside this one, and its
        // stack is claimed only on it (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md).
        let (theirs, their_id) = std::thread::spawn(|| {
            let stack = current_stack().unwrap();
            let guard = OverflowGuard::install(&stack).expect("a second thread's guard installs");
            let id = thread_token();
            let inside = stack.low_bound + 4096;
            let claimed = is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], id).is_some();
            drop(guard);
            ((stack.low_bound + 4096, claimed), id)
        })
        .join()
        .unwrap();
        assert!(theirs.1, "the other thread's overflow on its own stack");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, theirs.0], me), "the other thread's stack, raised here");
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], their_id), "this stack, raised on the other thread");
        assert!(claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me), "this guard outlives the other's");
        drop(guard);
        assert!(!claimed(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me), "the guard removed");
        drop(OverflowGuard::install_executable(&stack).expect("a guard installs again"));
    }
}
