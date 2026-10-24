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
//! for as long as an `OverflowGuard` lives: installed by the thread that runs
//! Botlish code (the driver's and an executable's worker thread, main.rs and
//! runtime/aot.rs) before it runs any, removed when the run is over. Vectored
//! handlers are process-wide; the guard claims an exception only when
//!
//!   * it is `STATUS_STACK_OVERFLOW`,
//!   * on the guarded thread (`GUARDED`, its thread id), while installed,
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
//! It then writes the driver's result line `error {NATIVE LIMIT STACK}
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
//! handler (`set_active_stack`): a double buffer, as the POSIX guard's -- the
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
//! touches neither the heap, the collector nor a lock: it reads atomics this
//! process stored before the fault, makes one WriteFile per partial write of
//! a static line (each writes at least a byte, so at most the line's length)
//! and calls TerminateProcess, which ends every thread of the process
//! without running DLL detach routines, TLS callbacks or the C runtime's
//! exit handlers, and does not return to its caller; should it ever return,
//! the handler fails fast (`int 0x29`, FAST_FAIL_FATAL_APP_EXIT). It runs on
//! the exhausted stack itself -- Windows has no alternate stack for
//! exception handlers -- inside the stack guarantee the kernel committed
//! for it; GUARANTEE is that room, measured (the report's "Experiments").
//!
//! The destination is resolved when the guard is installed, never in the
//! handler: the `--result` file's handle (`set_result_file`, a file the
//! driver keeps open for the whole run), else the process's standard output
//! (the driver) or standard error (an executable), as GetStdHandle names
//! them then.
use crate::runtime::native_stack::{NativeStack, StackState};
use std::io;
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
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

/// The calling thread's stack guarantee: SetThreadStackGuarantee of 0 asks.
pub fn stack_guarantee() -> u32 {
    let mut size = 0u32;
    // SAFETY: a query of the calling thread's own guarantee.
    unsafe { SetThreadStackGuarantee(&mut size) };
    size
}

/// GUARDED's value while no guard is installed.
const UNGUARDED: usize = 0;
/// GUARDED's value while a guard is being installed or removed: no
/// exception is claimed. No thread id: Windows' are multiples of four.
const BUSY: usize = usize::MAX;
/// The guarded thread's id, or UNGUARDED or BUSY.
static GUARDED: AtomicUsize = AtomicUsize::new(UNGUARDED);
/// Two slots of the running stack's reservation, `[low, high)`, and the one
/// in use.
static SLOTS: [[AtomicUsize; 2]; 2] = [[AtomicUsize::new(0), AtomicUsize::new(0)], [AtomicUsize::new(0), AtomicUsize::new(0)]];
static SLOT: AtomicUsize = AtomicUsize::new(0);
/// A standalone executable reports to standard error and exits 1.
static EXECUTABLE: AtomicBool = AtomicBool::new(false);
/// The `--result` file's handle (set_result_file), 0 for none.
static RESULT: AtomicUsize = AtomicUsize::new(0);
/// Where the handler writes: resolved at installation.
static DESTINATION: AtomicUsize = AtomicUsize::new(0);
const OVERFLOW_LINE: &[u8] = super::OVERFLOW_LINE;

/// Makes FILE where the driver's overflow report is written, with its other
/// result lines: the `--result` file, so that a program's own standard
/// output never carries it. FILE must stay open while a guard is installed.
pub fn set_result_file(file: &std::fs::File) {
    use std::os::windows::io::AsRawHandle;
    RESULT.store(file.as_raw_handle() as usize, Ordering::Relaxed);
}

/// Makes STACK the stack whose reservation the handler reports an overflow
/// of: the stack this thread runs on from now (runtime/coroutine.rs calls it
/// on arriving on a stack). A no-op while no guard is installed. Inlined, and
/// only atomic stores: it adds no frame to the stack it is called on.
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
    SLOTS[next][0].store(stack.low_bound, Ordering::Relaxed);
    SLOTS[next][1].store(stack.high_bound, Ordering::Relaxed);
    SLOT.store(next, Ordering::Release);
}

/// The reservation `[low, high)` the handler would read now, while a guard
/// is installed: what the runtime last published (tests).
pub fn published_stack() -> Option<(usize, usize)> {
    match GUARDED.load(Ordering::Acquire) {
        UNGUARDED | BUSY => None,
        _ => {
            let slot = SLOT.load(Ordering::Acquire);
            Some((SLOTS[slot][0].load(Ordering::Relaxed), SLOTS[slot][1].load(Ordering::Relaxed)))
        }
    }
}

/// Whether an exception with CODE and FLAGS, whose record holds
/// PARAMETERS, raised on the thread THREAD, is the exhaustion of the stack
/// published as running on the guarded thread.
#[inline(always)]
fn is_overflow(code: i32, flags: u32, parameters: &[usize], thread: usize) -> bool {
    if code != EXCEPTION_STACK_OVERFLOW || flags & EXCEPTION_SOFTWARE_ORIGINATE != 0 {
        return false;
    }
    let guarded = GUARDED.load(Ordering::Acquire);
    if guarded == UNGUARDED || guarded == BUSY || guarded != thread {
        return false;
    }
    let slot = SLOT.load(Ordering::Acquire);
    let (low, high) = (SLOTS[slot][0].load(Ordering::Relaxed), SLOTS[slot][1].load(Ordering::Relaxed));
    parameters.len() >= 2 && parameters[1] >= low && parameters[1] < high
}

unsafe extern "system" fn handler(info: *mut EXCEPTION_POINTERS) -> i32 {
    // SAFETY: Windows hands a vectored handler a valid record.
    let record = unsafe { &*(*info).ExceptionRecord };
    let count = (record.NumberParameters as usize).min(record.ExceptionInformation.len());
    if is_overflow(record.ExceptionCode, record.ExceptionFlags, &record.ExceptionInformation[..count], thread_token()) {
        write_overflow_line();
        terminate();
    }
    EXCEPTION_CONTINUE_SEARCH
}

/// Writes the overflow line to the destination resolved at installation:
/// one WriteFile per partial write, at most the line's length of them; a
/// failed one ends the attempt (nothing is retried).
fn write_overflow_line() {
    let out = DESTINATION.load(Ordering::Relaxed) as HANDLE;
    let mut rest = OVERFLOW_LINE;
    while !rest.is_empty() {
        let mut written = 0u32;
        // SAFETY: a static buffer, synchronous I/O on a handle that stays
        // open while the guard is installed.
        let ok = unsafe { WriteFile(out, rest.as_ptr(), rest.len() as u32, &mut written, std::ptr::null_mut()) };
        if ok == 0 || written == 0 || written as usize > rest.len() {
            break;
        }
        rest = &rest[written as usize..];
    }
}

/// Ends the process: exit status 0 for the driver (the line is its result),
/// 1 for a standalone executable.
fn terminate() -> ! {
    let status = if EXECUTABLE.load(Ordering::Relaxed) { 1 } else { 0 };
    // SAFETY: ends this process; TerminateProcess of the calling process
    // does not return.
    unsafe { TerminateProcess(GetCurrentProcess(), status) };
    // SAFETY: __fastfail(FAST_FAIL_FATAL_APP_EXIT): ends the process with
    // no handler run, should TerminateProcess ever have returned.
    unsafe { std::arch::asm!("int 0x29", in("ecx") 7, options(noreturn, nostack)) }
}

/// The installed guard: the vectored handler, first in the chain. Dropping
/// it removes the handler (the thread keeps its stack guarantee: Windows
/// never lowers one).
pub struct OverflowGuard {
    handler: *mut core::ffi::c_void,
}

impl OverflowGuard {
    /// Installs the guard for the driver (botlish-native and the driver
    /// protocol of an executable, runtime/aot.rs): the overflow line goes to
    /// the result file (or standard output) and the process exits 0. STACK
    /// is the calling thread's own stack, the one published first.
    pub fn install(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, false)
    }

    /// Installs the guard for a standalone executable's own run: the line goes
    /// to standard error and the process exits 1.
    pub fn install_executable(stack: &NativeStack) -> io::Result<Self> {
        Self::install_mode(stack, true)
    }

    fn install_mode(stack: &NativeStack, executable: bool) -> io::Result<Self> {
        if GUARDED.compare_exchange(UNGUARDED, BUSY, Ordering::AcqRel, Ordering::Relaxed).is_err() {
            return Err(io::Error::new(io::ErrorKind::AlreadyExists, "a stack-overflow guard is already installed"));
        }
        match Self::prepare(stack, executable) {
            Ok(handler) => {
                GUARDED.store(thread_token(), Ordering::Release);
                Ok(OverflowGuard { handler })
            }
            Err(error) => {
                GUARDED.store(UNGUARDED, Ordering::Release);
                Err(error)
            }
        }
    }

    /// Everything but the publication of the guarded thread, under BUSY.
    fn prepare(stack: &NativeStack, executable: bool) -> io::Result<*mut core::ffi::c_void> {
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
        let destination = match RESULT.load(Ordering::Relaxed) {
            _ if executable => (unsafe { GetStdHandle(STD_ERROR_HANDLE) }) as usize,
            0 => (unsafe { GetStdHandle(STD_OUTPUT_HANDLE) }) as usize,
            file => file,
        };
        DESTINATION.store(destination, Ordering::Relaxed);
        EXECUTABLE.store(executable, Ordering::Relaxed);
        publish(stack);
        // SAFETY: a handler with the vectored handler's ABI, first in the
        // chain; removed by Drop.
        let handler = unsafe { AddVectoredExceptionHandler(1, Some(handler)) };
        if handler.is_null() {
            return Err(io::Error::new(io::ErrorKind::Other, "AddVectoredExceptionHandler failed"));
        }
        Ok(handler)
    }
}

impl Drop for OverflowGuard {
    fn drop(&mut self) {
        GUARDED.store(BUSY, Ordering::Release);
        // SAFETY: the handler install added.
        unsafe { RemoveVectoredExceptionHandler(self.handler) };
        GUARDED.store(UNGUARDED, Ordering::Release);
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
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me), "no guard installed");
        let guard = OverflowGuard::install(&stack).expect("the guard installs");
        assert!(stack_guarantee() >= GUARANTEE);
        assert!(is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me));
        assert!(is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[0, stack.high_bound - 1], me));
        assert!(!is_overflow(ACCESS_VIOLATION, 0, &[1, inside], me), "an access violation in the stack");
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, EXCEPTION_SOFTWARE_ORIGINATE, &[1, inside], me), "raised by software");
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me + 4), "another thread");
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[], me), "raised with no address");
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, stack.low_bound - 1], me), "below the reservation");
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, stack.high_bound], me), "above it");
        assert!(OverflowGuard::install(&stack).is_err(), "one guard per process");
        drop(guard);
        assert!(!is_overflow(EXCEPTION_STACK_OVERFLOW, 0, &[1, inside], me), "the guard removed");
        drop(OverflowGuard::install_executable(&stack).expect("a guard installs again"));
    }
}
