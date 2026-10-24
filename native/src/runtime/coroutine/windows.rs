//! Windows x86-64 (MSVC): a coroutine's stack is a Windows fiber
//! (WINDOWS-X86-64-MILESTONE-5.md). Everything above this module -- the
//! states, the transport slot, segments, releases, the pool, the collector's
//! walk -- is the code Linux and macOS run (runtime/coroutine.rs); this
//! module gives it the same four things their assembly does: a stack
//! (`CoStack`), a context to start on it (`prepare`), a switch
//! (`bl_co_switch`) and where a suspended stack's walk starts
//! (`SwitchPoint`, read by `super::suspended_rbp`).
//!
//! # Why fibers
//!
//! A Windows stack is more than memory and registers: the TEB names the
//! running stack (NT_TIB's StackBase and StackLimit, and the undocumented
//! DeallocationStack and GuaranteedStackBytes), and Windows reads it to grow
//! the stack by its guard page, to raise STATUS_STACK_OVERFLOW with the
//! stack's own guarantee committed, to answer GetCurrentThreadStackLimits
//! and to dispatch and unwind exceptions (a Rust panic among them). A switch
//! that keeps only the registers leaves all of that describing the other
//! stack (the report's "Architecture comparison": growth, C calls and panics
//! fail on such a stack; with NT_TIB's fields alone the guarantee and the
//! limits are the thread's). SwitchToFiber keeps every one of them, with
//! the Win64 callee-saved state (XMM6-XMM15 included) and, with
//! FIBER_FLAG_FLOAT_SWITCH, MXCSR and the x87 control word: all of it
//! documented, none of it a TEB offset of ours.
//!
//! # A fiber's life
//!
//! `CoStack::new` makes the thread a fiber when it is not one yet
//! (`thread_fiber`: ConvertThreadToFiberEx, converted back when the thread
//! ends; a thread something else made a fiber is left as it is), creates the
//! fiber (`CreateFiberEx`: the usable size plus `GUARD_BYTES` reserved,
//! `COMMIT_BYTES` committed, the floating-point state switched) and enters it
//! once: its first frame, `bl_co_fiber_entry`, records the stack pointer its
//! bodies start from and calls `co_fiber_setup`, which asks the fiber's own
//! stack guarantee (a fiber starts with none), records the fiber's stack as
//! Windows reports it, confirms its guard page and parks -- switches back,
//! never to continue there. A fiber whose setup does not hold is deleted and
//! the start refused, before any Botlish code could run on it.
//!
//! A parked fiber is started by a switch carrying a start (`prepare`'s
//! `SwitchPoint`): arrived back inside its own `bl_co_switch`, the fiber
//! finds the start and restarts (`bl_co_fiber_restart`): its stack pointer
//! back to the entry's, a return address into the entry (so that its frames
//! unwind as a fresh fiber's do), and a jump to `co_body`. Whatever the
//! fiber parked in -- its setup, a finished body's last switch, the yield of
//! a coroutine released while suspended -- is abandoned, as the POSIX hosts
//! abandon a pooled stack's old frames: no frame on a coroutine stack owns a
//! value with a destructor. So every coroutine stack is restartable, and the
//! pool keeps fibers exactly as it keeps POSIX stacks (`super::POOL`);
//! `DeleteFiber` (which runs the fiber's FLS callbacks: the C runtime's
//! per-fiber data) frees one the pool has no room for, never the running
//! one.
//!
//! # Switching
//!
//! `bl_co_switch` records where it leaves -- the running fiber and its own
//! frame's RIP, RSP and RBP, the start of the collector's walk of the stack it
//! leaves (runtime::framewalk's Windows `walk_from`) -- and calls
//! SwitchToFiber; the side that arrives publishes its stack for the guard
//! (runtime/coroutine.rs's `segment`, `co_body`, `rt_co_yield`), after the
//! switch, as on every host. TLS stays the thread's (Rust's thread-locals,
//! the runtime's own among them, are shared by every fiber of a thread);
//! FLS follows the fiber (the C runtime's errno is per fiber, read right
//! after the call that set it, as every binding does).
use super::super::error::RtError;
use super::super::framewalk::windows::Frame;
use super::super::native_stack::NativeStack;
use super::super::platform::windows::{confirmed_guard_page, current_stack, stack_guarantee, GUARANTEE};
use super::super::vm::Vm;
use super::{co_body, stack_bytes, CoroutineObj, GUARD_BYTES, POOL, POOL_LIMIT};
use std::cell::Cell;
use std::ffi::c_void;
use windows_sys::Win32::System::Threading::{
    ConvertFiberToThread, ConvertThreadToFiberEx, CreateFiberEx, DeleteFiber, IsThreadAFiber, SetThreadStackGuarantee,
    SwitchToFiber,
};
use windows_sys::Win32::System::WindowsProgramming::FIBER_FLAG_FLOAT_SWITCH;

/// What a fresh fiber's stack commits at once: one page, a thread's default
/// (the linker's /STACK commit). Windows commits the rest by the guard page
/// as the fiber grows, as it grows a thread's, and a pooled fiber keeps what
/// it grew. Every page committed is charged to the system's commit limit
/// whether or not it is touched: the setup's guarantee adds its 32 KiB
/// below (the report's "Performance": what a fresh fiber commits).
const COMMIT_BYTES: usize = 4 << 10;

/// Where a context switched away: the fiber it runs on and the frame of its
/// `bl_co_switch` -- for a suspended stack the start of the collector's walk
/// (`super::suspended_rbp`) -- or, from `prepare`, a fresh coroutine's start:
/// the fiber to start it on and its Slot (`start`, nonzero only then).
#[derive(Clone, Copy, Debug, Default)]
pub struct SwitchPoint {
    pub fiber: usize,
    pub frame: Frame,
    pub start: usize,
}

/// A fiber's own record, its parameter: what its entry and its restarts
/// read. `top` is written by `bl_co_fiber_entry` (offset 0), `p` and `co` by
/// `prepare` (offsets 8 and 16), the rest by `co_fiber_setup`.
#[repr(C)]
struct Slot {
    /// The stack pointer of the entry's call: where every body starts.
    top: usize,
    /// The coroutine the next start runs: `co_body(p, co)`.
    p: *mut Vm,
    co: *mut CoroutineObj,
    /// Where the fiber's creator switched from: where its setup parks.
    creator: SwitchPoint,
    /// What its setup found: the fiber's stack as Windows reports it, its
    /// stack guarantee, and whether it grows by a guard page.
    stack: Option<NativeStack>,
    guarantee: u32,
    guard_page: bool,
}

/// One coroutine stack: a fiber, parked whenever no coroutine runs on it,
/// with its Slot (which holds its stack, `bounds`) and the usable size it was
/// made for.
pub struct CoStack {
    fiber: usize,
    slot: *mut Slot,
    usable: usize,
}

std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".def bl_co_fiber_entry",
    ".scl 2",
    ".type 32",
    ".endef",
    ".globl bl_co_fiber_entry",
    // A coroutine fiber's first frame (CreateFiberEx's start routine; RCX
    // its Slot). Its 40 bytes -- the shadow space of the body it calls, and
    // alignment -- are described to Windows' unwinder, so every frame above
    // it unwinds into the fiber's start as a fresh fiber's does.
    ".seh_proc bl_co_fiber_entry",
    "bl_co_fiber_entry:",
    "sub rsp, 40",
    ".seh_stackalloc 40",
    ".seh_endprologue",
    "mov qword ptr [rcx], rsp",
    "call {setup}",
    // The return address of every body's first frame: setup's, and
    // co_body's after a restart. Nothing returns here.
    "bl_co_fiber_return:",
    "int3",
    ".seh_endproc",
    "",
    // A start of a parked fiber (RCX its Slot): the stack pointer back to
    // the entry's call, its return address pushed as that call pushed it,
    // and co_body(p, co) entered as if called there.
    ".p2align 4",
    ".def bl_co_fiber_restart",
    ".scl 2",
    ".type 32",
    ".endef",
    ".globl bl_co_fiber_restart",
    "bl_co_fiber_restart:",
    "mov rsp, qword ptr [rcx]",
    "lea rax, [rip + bl_co_fiber_return]",
    "push rax",
    "mov rdx, qword ptr [rcx + 16]",
    "mov rcx, qword ptr [rcx + 8]",
    "jmp {body}",
    setup = sym co_fiber_setup,
    body = sym co_body,
);

// Their argument is a Slot.
unsafe extern "C" {
    fn bl_co_fiber_entry(slot: *mut c_void);
    fn bl_co_fiber_restart(slot: *const c_void) -> !;
}

thread_local! {
    /// The Slot of the fiber this thread switches to when that switch is a
    /// start (set by `bl_co_switch` right before it switches, taken by the
    /// fiber that arrives): a thread-local, shared by every fiber of the
    /// thread, so the arriving side reads what the leaving side wrote.
    static START: Cell<usize> = const { Cell::new(0) };
    static THREAD_FIBER: ThreadFiber = const { ThreadFiber { state: Cell::new(UNKNOWN), fiber: Cell::new(0) } };
}

/// The running fiber: NT_TIB's FiberData (winnt.h's GetCurrentFiber).
#[inline(always)]
fn current_fiber() -> usize {
    let fiber: usize;
    // SAFETY: reads the current thread's TEB.
    unsafe { std::arch::asm!("mov {}, qword ptr gs:[0x20]", out(reg) fiber, options(nostack, preserves_flags, readonly)) };
    fiber
}

const UNKNOWN: u8 = 0;
/// The runtime made the thread a fiber, and converts it back when the
/// thread ends.
const CONVERTED: u8 = 1;
/// Something else did (an embedding): the runtime leaves it as it is.
const HOSTED: u8 = 2;

/// Whether, and by whom, this thread was made a fiber, and the fiber the
/// runtime's conversion made.
struct ThreadFiber {
    state: Cell<u8>,
    fiber: Cell<usize>,
}

impl Drop for ThreadFiber {
    /// The thread ends: a conversion of the runtime's is undone, while the
    /// thread runs on the fiber it made (nothing runs on another then).
    fn drop(&mut self) {
        // SAFETY: the calling thread's own fiber state.
        if self.state.get() == CONVERTED && unsafe { IsThreadAFiber() } != 0 && current_fiber() == self.fiber.get() {
            unsafe { ConvertFiberToThread() };
        }
    }
}

/// Makes the calling thread a fiber, which SwitchToFiber needs on both
/// sides, unless it is one: converted by the runtime once per thread (with
/// the floating-point state switched), or by something else, whose
/// conversion it neither repeats nor undoes.
fn thread_fiber() -> Result<(), RtError> {
    // SAFETY: a query of the calling thread.
    if unsafe { IsThreadAFiber() } != 0 {
        THREAD_FIBER.with(|t| {
            if t.state.get() == UNKNOWN {
                t.state.set(HOSTED);
            }
        });
        return Ok(());
    }
    // SAFETY: converts the calling thread, which is no fiber.
    let fiber = unsafe { ConvertThreadToFiberEx(std::ptr::null(), FIBER_FLAG_FLOAT_SWITCH) } as usize;
    if fiber == 0 {
        return Err(RtError::Semantic {
            kind: "COROUTINE-STATE",
            message: format!("cannot make the thread a fiber for its coroutines: {}", std::io::Error::last_os_error()),
        });
    }
    THREAD_FIBER.with(|t| {
        t.state.set(CONVERTED);
        t.fiber.set(fiber);
    });
    Ok(())
}

/// Whether the runtime converted the calling thread to a fiber (tests).
pub fn thread_converted() -> bool {
    THREAD_FIBER.with(|t| t.state.get() == CONVERTED)
}

impl CoStack {
    /// The fiber's stack, as Windows reported it to the fiber's setup
    /// (`CoStack::new` returns no stack whose setup reported none).
    pub fn bounds(&self) -> NativeStack {
        // SAFETY: the Slot of this CoStack's fiber, which lives as long as
        // the fiber and was written by its setup before `new` returned.
        match unsafe { (*self.slot).stack } {
            Some(stack) => stack,
            None => unreachable!("a coroutine fiber without its recorded stack"),
        }
    }

    /// A stack, and whether it came from the pool (rather than a fresh
    /// fiber).
    pub(super) fn new() -> Result<(CoStack, bool), RtError> {
        thread_fiber()?;
        let usable = stack_bytes();
        if let Some(stack) = POOL.with(|pool| {
            let mut pool = pool.borrow_mut();
            let at = pool.iter().position(|s| s.usable == usable)?;
            Some(pool.swap_remove(at))
        }) {
            return Ok((stack, true));
        }
        let reserve = usable + GUARD_BYTES;
        let slot = Box::into_raw(Box::new(Slot {
            top: 0,
            p: std::ptr::null_mut(),
            co: std::ptr::null_mut(),
            creator: SwitchPoint::default(),
            stack: None,
            guarantee: 0,
            guard_page: false,
        }));
        // SAFETY: a fiber of the entry, whose parameter (SLOT) lives as long
        // as the fiber. The entry has a fiber routine's ABI: Win64, its one
        // argument in RCX.
        let fiber = unsafe {
            let entry: unsafe extern "system" fn(*mut c_void) =
                std::mem::transmute(bl_co_fiber_entry as unsafe extern "C" fn(*mut c_void));
            CreateFiberEx(COMMIT_BYTES, reserve, FIBER_FLAG_FLOAT_SWITCH, Some(entry), slot as *const c_void)
        } as usize;
        if fiber == 0 {
            let error = std::io::Error::last_os_error();
            // SAFETY: no fiber refers to it.
            drop(unsafe { Box::from_raw(slot) });
            return Err(RtError::Semantic { kind: "COROUTINE-STATE", message: format!("cannot create a {reserve}-byte coroutine stack: {error}") });
        }
        // The fiber's setup, which parks it.
        // SAFETY: a fresh fiber of this thread; its setup switches back.
        unsafe { bl_co_switch(&mut (*slot).creator, SwitchPoint { fiber, ..SwitchPoint::default() }, 0) };
        // SAFETY: written by the setup before it parked.
        let (stack, guarantee, guard_page) = unsafe { ((*slot).stack, (*slot).guarantee, (*slot).guard_page) };
        match stack {
            Some(_) if guarantee >= GUARANTEE && guard_page => Ok((CoStack { fiber, slot, usable }, false)),
            _ => {
                // SAFETY: the fiber is parked; nothing else refers to it.
                unsafe {
                    DeleteFiber(fiber as *const c_void);
                    drop(Box::from_raw(slot));
                }
                Err(RtError::Bug(format!(
                    "a coroutine fiber's stack is not one the stack guard can watch: {}, stack guarantee {guarantee} bytes (it needs {GUARANTEE}), guard page confirmed {guard_page}",
                    stack.map_or("no bounds".to_string(), |s| format!("[{:#x}, {:#x})", s.low_bound, s.high_bound))
                )))
            }
        }
    }
}

/// A parked fiber's first frame after its entry (`bl_co_fiber_entry`): asks
/// the fiber's stack guarantee -- a fiber starts with none, and the
/// guarantee is the fiber's own, kept by every switch -- records the stack
/// Windows reports for it and whether it grows by a guard page, and parks.
/// Nothing resumes it: the next switch to the fiber is a start, which
/// restarts it at its top (`bl_co_switch`).
extern "C" fn co_fiber_setup(slot: *mut Slot) -> ! {
    // SAFETY: SLOT is this fiber's (its parameter), written only here while
    // the creator waits for the switch below.
    unsafe {
        let mut size = GUARANTEE;
        SetThreadStackGuarantee(&mut size);
        (*slot).guarantee = stack_guarantee();
        if let Ok(stack) = current_stack() {
            (*slot).guard_page = confirmed_guard_page(&stack) && stack.contains((*slot).top, 8);
            (*slot).stack = Some(stack);
        }
        let mut parked = SwitchPoint::default();
        bl_co_switch(&mut parked, (*slot).creator, 0);
    }
    std::process::abort()
}

impl Drop for CoStack {
    fn drop(&mut self) {
        if self.fiber == 0 {
            return;
        }
        let returned = POOL.try_with(|pool| {
            let mut pool = pool.borrow_mut();
            if pool.len() < POOL_LIMIT {
                pool.push(CoStack { fiber: self.fiber, slot: self.slot, usable: self.usable });
                true
            } else {
                false
            }
        });
        if returned != Ok(true) {
            // Deleting the running fiber would end the thread (DeleteFiber's
            // documented behavior): no coroutine running now ever drops its
            // stack.
            if self.fiber == current_fiber() {
                eprintln!("a running coroutine's fiber was released (NATIVE BUG)");
                std::process::abort();
            }
            // SAFETY: a parked fiber of this thread and its Slot, which
            // nothing refers to once the fiber is gone.
            unsafe {
                DeleteFiber(self.fiber as *const c_void);
                drop(Box::from_raw(self.slot));
            }
        }
        self.fiber = 0;
    }
}

/// A fresh coroutine's start on STACK's parked fiber: `co_body(p, co)` from
/// the fiber's top, when the switch to the returned point arrives there.
pub(super) unsafe fn prepare(stack: &CoStack, p: *mut Vm, co: *mut CoroutineObj) -> SwitchPoint {
    // SAFETY: the Slot of a parked fiber, which reads it only when started.
    unsafe {
        (*stack.slot).p = p;
        (*stack.slot).co = co;
    }
    SwitchPoint { fiber: stack.fiber, frame: Frame::default(), start: stack.slot as usize }
}

/// Saves the current context -- its fiber and this frame, through SAVE --
/// and continues LOAD: SwitchToFiber to its fiber, which goes on where it
/// switched away, or -- LOAD a start (`prepare`) -- restarts at its top.
/// Returns TRANSFER when this context is continued (every caller passes 0).
///
/// Never inlined: the frame it records is its own, whose RIP lies in its
/// body and whose RSP and RBP are what they are at the call of
/// SwitchToFiber (a Win64 body moves no stack pointer), which is what
/// Windows' unwinder needs to climb from it.
#[inline(never)]
pub(super) unsafe fn bl_co_switch(save: *mut SwitchPoint, load: SwitchPoint, transfer: usize) -> usize {
    let (rip, rsp, rbp): (u64, u64, u64);
    // SAFETY: reads registers.
    unsafe {
        std::arch::asm!("lea {}, [rip]", "mov {}, rsp", "mov {}, rbp", out(reg) rip, out(reg) rsp, out(reg) rbp,
            options(nomem, nostack, preserves_flags));
    }
    // SAFETY: SAVE is the caller's record (a coroutine object's field, or a
    // local); LOAD's fiber is a fiber of this thread that is not running.
    unsafe {
        *save = SwitchPoint { fiber: current_fiber(), frame: Frame { rip, rsp, rbp }, start: 0 };
        if load.start != 0 {
            START.with(|start| start.set(load.start));
        }
        SwitchToFiber(load.fiber as *const c_void);
    }
    // Continued: a start of this (parked) fiber restarts it.
    let start = START.with(|start| start.replace(0));
    if start != 0 {
        // SAFETY: this fiber's own Slot, whose top its entry recorded.
        unsafe { bl_co_fiber_restart(start as *const c_void) }
    }
    transfer
}
