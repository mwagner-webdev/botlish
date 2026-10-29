//! Native coroutines (COROUTINES.md): eagerly started, affine, stackful.
//!
//! A started coroutine runs on a native stack of its own, mapped by this
//! module, and suspension is a stack switch. Every frame between the
//! coroutine's entry and a `yield` -- Botlish frames at any depth, and the
//! runtime's own helper frames -- simply stays where it is while suspended,
//! so a deep yield needs nothing of the code generator but one fact: a call
//! that may suspend is a GC safepoint (it is: every coroutine operation is
//! classified as possibly allocating, `ops::op_may_allocate`, so `may_gc`
//! reaches every caller through `nir::summarize_call_effects` exactly like a
//! real allocation does).
//!
//! # Operations (helpers generated code calls; NIR `op co...`)
//!
//! | helper            | operands          | result                          |
//! |-------------------|-------------------|---------------------------------|
//! | rt_co_create      | thunk Block       | a fresh handle (allocates)      |
//! | rt_co_start       | handle            | first outward value, or 0       |
//! | rt_co_resume      | handle, message   | next outward value, or 0        |
//! | rt_co_resume0     | handle            | the same, zero-message protocol |
//! | rt_co_yield       | outward value     | the resume message              |
//! | rt_co_done        | handle            | Bool: completed or failed       |
//! | rt_co_release     | handle            | unit: the handle is dead        |
//!
//! start/resume return 0 exactly when the segment ended with an unhandled
//! error of the body: the error is pending in the Vm, as for any failed call,
//! so a `handle` around the call (or the caller's own error exit) treats it
//! like every other failure. Nothing coroutine-specific crosses the boundary.
//!
//! # States
//!
//! FRESH -> (start) RUNNING -> SUSPENDED -> (resume) RUNNING -> ... ->
//! COMPLETED (the final value is cached and returned again by every later
//! resume) or FAILED (the error is cached and raised again). A terminal
//! coroutine runs no code and holds no stack. RUNNING is defensive: an
//! affine handle cannot be resumed from inside its own segment
//! (COROUTINE-RUNNING otherwise). RELEASED: the handle is dead
//! (`rt_co_release`, placed by the compiler right after the handle's last
//! use) and the coroutine holds nothing any more -- a suspended one's stack
//! went straight back to the pool; nothing can reach it again (a resume of
//! it is a compiler bug, COROUTINE-STATE).
//!
//! # Stacks and switching (x86-64 Linux)
//!
//! A stack is an anonymous mapping with a PROT_NONE guard region below the
//! usable range (`CoStack`); finished stacks go back to a small per-thread
//! pool instead of `munmap`. `bl_co_switch` saves the SysV callee-saved
//! registers (rbx, rbp, r12-r15) and the MXCSR/x87 control words on the
//! current stack, stores its stack pointer, loads the other one and returns
//! there. It opens a standard `push rbp; mov rbp, rsp` frame first, so a
//! suspended stack's frame-pointer chain starts at `saved_sp + 48` and the
//! ordinary GC frame walker (runtime::framewalk) reads it like any other.
//! A fresh stack is prepared so that the first switch "returns" into
//! `bl_co_trampoline`, which pushes a zero frame pointer (the end of the
//! stack's chain) and calls `co_body`: the thunk's generic entry, then the
//! terminal state, then a final switch back that never returns.
//!
//! # AArch64 (Linux and macOS)
//!
//! The same design with the AAPCS64 callee-saved state: `bl_co_switch` opens
//! a frame record (`stp x29, x30, [sp, #-16]!; mov x29, sp`), saves x19-x28,
//! d8-d15 (the low halves of v8-v15, all AAPCS64 preserves) and FPCR, so a
//! suspended stack's chain starts at `saved_sp + 160`. x18 is never touched.
//! A fresh stack's first switch restores x19 = P, x20 = CO, x29 = 0 and
//! x30 = `bl_co_trampoline`, whose `ret` therefore enters the trampoline; it
//! opens a record with a zero frame pointer (the end of the chain) and calls
//! `co_body`.
//!
//! macOS on Apple Silicon (MACOS-AARCH64-MILESTONE-3.md) uses the same
//! instructions (`aarch64_switch!`, `aarch64_trampoline!`) under Mach-O
//! spelling: Apple's AAPCS64 variant adds the reserved x18 (never touched),
//! a mandatory frame-pointer chain (kept: the record is the first thing the
//! switch opens) and a 128-byte red zone below sp (never written: every store
//! below sp is a pre-indexed one that moves sp first, and a fresh stack's
//! context lies wholly above its initial sp). A stack is a plain anonymous
//! mapping (no MAP_STACK on Darwin) whose guard and size are multiples of the
//! host page size (16 KiB there).
//!
//! # Windows x86-64 (MSVC)
//!
//! A coroutine's stack is a Windows fiber (WINDOWS-X86-64-MILESTONE-5.md,
//! coroutine/windows.rs): SwitchToFiber is the switch, because a Windows
//! stack is also the TEB's account of it (its bounds, its guard page, its
//! stack guarantee), which Windows reads to grow it, to report its
//! exhaustion and to unwind it, and which only the fiber switch keeps. The
//! module gives this one the same pieces the assembly above does -- a stack
//! (`CoStack`, a fiber with its own stack guarantee), a fresh start
//! (`prepare`), a switch (`bl_co_switch`) and a suspended stack's walk start
//! (`SwitchPoint`, its fiber and the frame its switch left) -- so everything
//! below is the code Linux and macOS run.
//!
//! # GC
//!
//! Running coroutines form a chain (`Vm::co_current` and each one's
//! `resumer`): every one is a root, and the collector walks the current
//! stack plus, for each link, the resumer's stack from where it switched
//! away. A suspended coroutine is reached through its handle like any object:
//! marking it walks its suspended stack (precise stack maps, the same
//! per-safepoint roots as for the main stack). An unreachable suspended
//! coroutine is swept, and its stack returned to the pool with nothing run
//! (no frame on it owns a Rust value with a destructor). The cached final
//! value and the cached failure's values are traced like any field.
use super::error::RtError;
#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
use super::native_stack::{NativeStack, StackState};
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
use super::ops::GenericEntry;
use super::value::*;
use super::vm::Vm;
use std::cell::RefCell;

/// Whether native coroutines run here: the host has the stack switch they
/// run on (the hosts `CoStack::new` makes a stack for) and its collector
/// finds roots in native frames (runtime::framewalk's NATIVE_FRAME_ROOTS: a
/// suspended coroutine's frames are walked like the running stack's; the
/// fallback plan's shadow stack cannot hold a suspended coroutine's roots,
/// and is never made coroutine-aware). Elsewhere starting one is NATIVE
/// UNSUPPORTED (`rt_co_start`). The coroutine fusion pass (codegen::fusion)
/// runs only where it is true, so fusing a coroutine never makes a program
/// run that the general runtime refuses.
pub const STACK_SWITCHING: bool = cfg!(any(
    all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")),
    all(target_os = "macos", target_arch = "aarch64"),
    all(windows, target_arch = "x86_64", target_env = "msvc")
)) && super::framewalk::NATIVE_FRAME_ROOTS;

pub const CO_FRESH: u8 = 0;
pub const CO_RUNNING: u8 = 1;
pub const CO_SUSPENDED: u8 = 2;
pub const CO_COMPLETED: u8 = 3;
pub const CO_FAILED: u8 = 4;
pub const CO_RELEASED: u8 = 5;

/// Where a context switched away (`bl_co_switch`'s SAVE): its stack pointer
/// on the POSIX hosts; on Windows its fiber and the frame its switch left
/// (coroutine/windows.rs).
#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
pub type SwitchPoint = usize;
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
pub use windows::SwitchPoint;

#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
mod windows;
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
use windows::{bl_co_switch, prepare};
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
pub use windows::{thread_converted, CoStack};

/// The bytes between a suspended stack's saved stack pointer and the frame
/// record `bl_co_switch` opened: the control words (8) and five callee-saved
/// registers (40).
#[cfg(not(target_arch = "aarch64"))]
pub const SWITCH_FRAME_OFFSET: usize = 48;

/// AArch64: FPCR (one 16-byte slot), d8-d15 (64) and x19-x28 (80).
#[cfg(target_arch = "aarch64")]
pub const SWITCH_FRAME_OFFSET: usize = 160;

#[repr(C)]
pub struct CoroutineObj {
    pub hdr: Header,
    pub state: u8,
    /// The zero-argument Block whose call is the coroutine's body; UNIT once
    /// terminal (its captures are garbage from then on).
    pub thunk: Value,
    /// The transport slot: the outward value of the last segment (a yield's,
    /// or the final result), and the resume message on its way in.
    pub value: Value,
    /// A terminal failure: the error, its declared-error id (0: not a
    /// declared error) and its payload's field values with their shape
    /// (ERROR-PAYLOADS.md; empty for a payload-free error), raised again by
    /// every later resume. A payload a coroutine can fail with is
    /// unrestricted (hir/coroutines.tcl), so raising it again copies values
    /// that may be shared.
    pub failure: Option<Box<(RtError, u32, Vec<Value>, u32)>>,
    /// The coroutine's stack, from its start until it is terminal.
    pub stack: Option<CoStack>,
    /// The coroutine's own stack pointer while it is suspended (or fresh):
    /// on Windows its fiber and the frame its switch left (`SwitchPoint`).
    pub saved_sp: SwitchPoint,
    /// The resumer's stack pointer while this coroutine runs (on Windows,
    /// the same of the resumer).
    pub resumer_sp: SwitchPoint,
    /// The coroutine whose segment resumed this one (null: the main stack),
    /// while this one runs.
    pub resumer: *mut CoroutineObj,
}

pub fn coroutine_of<'a>(v: Value) -> &'a mut CoroutineObj {
    debug_assert_eq!(heap_kind(v), KIND_COROUTINE);
    unsafe { &mut *(v as *mut CoroutineObj) }
}

/// Values a coroutine object refers to directly (not its stack's roots).
pub fn fields(co: &CoroutineObj) -> Vec<Value> {
    let mut values = vec![co.thunk, co.value];
    if let Some(failure) = &co.failure {
        values.extend(failure.0.values());
        values.extend(failure.2.iter().copied());
    }
    values
}

// ---------------------------------------------------------------------------
// Stacks

/// One mapped coroutine stack: [base, base + guard) is PROT_NONE, the rest
/// is usable. (Windows': a fiber, coroutine/windows.rs.)
#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
pub struct CoStack {
    base: usize,
    size: usize,
    guard: usize,
}

/// Below a stack's usable bytes: on the POSIX hosts its PROT_NONE guard; on
/// Windows the room its reservation keeps below them for the stack's
/// guarantee, its guard page and the page Windows never commits.
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
const GUARD_BYTES: usize = 64 * 1024;
const POOL_LIMIT: usize = 32;
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
const DEFAULT_STACK_BYTES: usize = 8 << 20;

thread_local! {
    static POOL: RefCell<Vec<CoStack>> = const { RefCell::new(Vec::new()) };
}

/// The usable size of every coroutine stack: BOTLISH_NATIVE_COROUTINE_STACK_BYTES
/// (at least 64 KiB, rounded up to a page) or 8 MiB. Address space only: pages are committed as
/// they are touched.
///
/// Read once per process, not at every start (a pooled one's included):
/// reading the environment takes the standard library's environment lock
/// and, on Windows, GetEnvironmentVariableW and a 1 KiB buffer on the stack
/// that starts the coroutine, which made a pooled start need more than 2 KiB
/// of it where a resume needs 350 bytes (WINDOWS-X86-64-MILESTONE-5.md,
/// section 8.2).
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
fn stack_bytes() -> usize {
    static BYTES: std::sync::OnceLock<usize> = std::sync::OnceLock::new();
    *BYTES.get_or_init(|| {
        std::env::var("BOTLISH_NATIVE_COROUTINE_STACK_BYTES")
            .ok()
            .and_then(|text| text.parse::<usize>().ok())
            .filter(|&size| size >= 64 * 1024)
            .map(round_to_page)
            .unwrap_or(DEFAULT_STACK_BYTES)
    })
}

/// SIZE rounded up to a multiple of the host's page size, which is not 4 KiB
/// everywhere (16 KiB on Apple Silicon). Read once per call: it is a few
/// instructions, and a stack is mapped rarely.
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
fn round_to_page(size: usize) -> usize {
    // SAFETY: sysconf has no preconditions.
    let page = unsafe { libc::sysconf(libc::_SC_PAGESIZE) };
    let page = if page > 0 { page as usize } else { 4096 };
    (size + page - 1) & !(page - 1)
}

/// Windows x86-64's pages are 4 KiB.
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
fn round_to_page(size: usize) -> usize {
    (size + 4095) & !4095
}

/// How a coroutine stack is mapped: Linux marks it MAP_STACK and reserves no
/// swap; Darwin has no MAP_STACK (its stack-ness is only in the thread
/// library) and MAP_NORESERVE is a no-op there, so a stack is a plain private
/// anonymous mapping. Both commit pages as they are touched.
#[cfg(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
const MAP_FLAGS: libc::c_int = libc::MAP_PRIVATE | libc::MAP_ANONYMOUS | libc::MAP_NORESERVE | libc::MAP_STACK;
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
const MAP_FLAGS: libc::c_int = libc::MAP_PRIVATE | libc::MAP_ANONYMOUS;

#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
impl CoStack {
    pub fn bounds(&self) -> NativeStack {
        NativeStack {
            low_bound: self.base + self.guard,
            high_bound: self.base + self.size,
            guard_low: self.base,
            saved_sp: None,
            state: StackState::Active,
        }
    }

    #[cfg_attr(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"))), allow(dead_code))]
    fn top(&self) -> usize {
        self.base + self.size
    }

    /// A stack, and whether it came from the pool (rather than a fresh
    /// mapping).
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
    fn new() -> Result<(CoStack, bool), RtError> {
        let usable = stack_bytes();
        if let Some(stack) = POOL.with(|pool| {
            let mut pool = pool.borrow_mut();
            let at = pool.iter().position(|s| s.size - s.guard == usable)?;
            Some(pool.swap_remove(at))
        }) {
            return Ok((stack, true));
        }
        let guard = round_to_page(GUARD_BYTES);
        let size = usable + guard;
        // SAFETY: a fresh private anonymous mapping; nothing else refers to it.
        unsafe {
            let base = libc::mmap(std::ptr::null_mut(), size, libc::PROT_READ | libc::PROT_WRITE, MAP_FLAGS, -1, 0);
            if base == libc::MAP_FAILED {
                return Err(RtError::Semantic {
                    kind: "COROUTINE-STATE",
                    message: format!("cannot map a {size}-byte coroutine stack: {}", std::io::Error::last_os_error()),
                });
            }
            if libc::mprotect(base, guard, libc::PROT_NONE) != 0 {
                libc::munmap(base, size);
                return Err(RtError::Bug(format!("cannot protect a coroutine stack guard: {}", std::io::Error::last_os_error())));
            }
            Ok((CoStack { base: base as usize, size, guard }, false))
        }
    }

    #[cfg(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"))))]
    fn new() -> Result<(CoStack, bool), RtError> {
        Err(RtError::Unsupported(
            "native coroutines need stack switching, implemented for Linux x86-64 and AArch64, macOS AArch64 and Windows x86-64 only (COROUTINES.md)".to_string(),
        ))
    }
}

#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
impl Drop for CoStack {
    fn drop(&mut self) {
        let returned = POOL.try_with(|pool| {
            let mut pool = pool.borrow_mut();
            if pool.len() < POOL_LIMIT {
                pool.push(CoStack { base: self.base, size: self.size, guard: self.guard });
                true
            } else {
                false
            }
        });
        if returned != Ok(true) {
            #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
            // SAFETY: the mapping this stack owns; no frame on it is live.
            unsafe {
                libc::munmap(self.base as *mut libc::c_void, self.size);
            }
        }
        self.size = 0;
    }
}

/// How many stacks are pooled now (tests and the performance report).
pub fn pooled_stacks() -> usize {
    POOL.with(|pool| pool.borrow().len())
}

// ---------------------------------------------------------------------------
// The switch (x86-64 SysV)

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl bl_co_switch",
    ".type bl_co_switch,@function",
    "bl_co_switch:",
    "push rbp",
    "mov rbp, rsp",
    "push rbx",
    "push r12",
    "push r13",
    "push r14",
    "push r15",
    "sub rsp, 8",
    "stmxcsr [rsp]",
    "fnstcw [rsp + 4]",
    "mov [rdi], rsp",
    "mov rsp, rsi",
    "ldmxcsr [rsp]",
    "fldcw [rsp + 4]",
    "add rsp, 8",
    "pop r15",
    "pop r14",
    "pop r13",
    "pop r12",
    "pop rbx",
    "pop rbp",
    "mov rax, rdx",
    "ret",
    ".size bl_co_switch, .-bl_co_switch",
    ".p2align 4",
    ".globl bl_co_trampoline",
    ".type bl_co_trampoline,@function",
    "bl_co_trampoline:",
    "push rbp",
    "mov rbp, rsp",
    "sub rsp, 8",
    "mov rdi, r12",
    "mov rsi, r13",
    "call {body}",
    "ud2",
    ".size bl_co_trampoline, .-bl_co_trampoline",
    body = sym co_body,
);

/// The AArch64 switch and trampoline instructions, shared by the ELF and
/// Mach-O spellings below: only the symbol directives differ between them.
/// The register contract is AAPCS64 and Apple's variant of it: x19-x28, the
/// low halves of v8-v15 and the frame record are saved, FPCR is carried with
/// the context, and x18 (reserved by Apple platforms) is never touched.
#[cfg(target_arch = "aarch64")]
macro_rules! aarch64_switch {
    () => {
        concat!(
            "stp x29, x30, [sp, #-16]!\n",
            "mov x29, sp\n",
            "stp x19, x20, [sp, #-16]!\n",
            "stp x21, x22, [sp, #-16]!\n",
            "stp x23, x24, [sp, #-16]!\n",
            "stp x25, x26, [sp, #-16]!\n",
            "stp x27, x28, [sp, #-16]!\n",
            "stp d8, d9, [sp, #-16]!\n",
            "stp d10, d11, [sp, #-16]!\n",
            "stp d12, d13, [sp, #-16]!\n",
            "stp d14, d15, [sp, #-16]!\n",
            "mrs x9, fpcr\n",
            "str x9, [sp, #-16]!\n",
            "mov x9, sp\n",
            "str x9, [x0]\n",
            "mov sp, x1\n",
            "ldr x9, [sp], #16\n",
            "msr fpcr, x9\n",
            "ldp d14, d15, [sp], #16\n",
            "ldp d12, d13, [sp], #16\n",
            "ldp d10, d11, [sp], #16\n",
            "ldp d8, d9, [sp], #16\n",
            "ldp x27, x28, [sp], #16\n",
            "ldp x25, x26, [sp], #16\n",
            "ldp x23, x24, [sp], #16\n",
            "ldp x21, x22, [sp], #16\n",
            "ldp x19, x20, [sp], #16\n",
            "ldp x29, x30, [sp], #16\n",
            "mov x0, x2\n",
            "ret\n",
        )
    };
}

#[cfg(target_arch = "aarch64")]
macro_rules! aarch64_trampoline {
    () => {
        concat!(
            "mov x30, xzr\n",
            "stp x29, x30, [sp, #-16]!\n",
            "mov x29, sp\n",
            "mov x0, x19\n",
            "mov x1, x20\n",
            "bl {body}\n",
            "brk #1\n",
        )
    };
}

#[cfg(all(target_arch = "aarch64", target_os = "linux"))]
std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl bl_co_switch",
    ".type bl_co_switch,%function",
    "bl_co_switch:",
    aarch64_switch!(),
    ".size bl_co_switch, .-bl_co_switch",
    ".p2align 4",
    ".globl bl_co_trampoline",
    ".type bl_co_trampoline,%function",
    "bl_co_trampoline:",
    aarch64_trampoline!(),
    ".size bl_co_trampoline, .-bl_co_trampoline",
    body = sym co_body,
);

// Mach-O: C symbols carry a leading underscore and there is no `.type` or
// `.size`. Nothing else differs from the ELF text above.
#[cfg(all(target_arch = "aarch64", target_os = "macos"))]
std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl _bl_co_switch",
    "_bl_co_switch:",
    aarch64_switch!(),
    ".p2align 4",
    ".globl _bl_co_trampoline",
    "_bl_co_trampoline:",
    aarch64_trampoline!(),
    body = sym co_body,
);

#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
unsafe extern "C" {
    /// Saves the current context, storing its stack pointer through SAVE,
    /// and continues the context whose stack pointer is LOAD, which sees
    /// TRANSFER as the result of its own bl_co_switch call.
    fn bl_co_switch(save: *mut usize, load: usize, transfer: usize) -> usize;
    fn bl_co_trampoline();
}

#[cfg(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc"))))]
unsafe fn bl_co_switch(_save: *mut usize, _load: usize, _transfer: usize) -> usize {
    unreachable!("no coroutine stack exists on this host")
}

/// The first frame of every coroutine stack (entered from bl_co_trampoline;
/// on Windows from a fiber's restart, coroutine/windows.rs): runs the body
/// to its end, records the terminal state, and switches back to the resumer
/// of the final segment for good.
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
extern "C" fn co_body(p: *mut Vm, co: *mut CoroutineObj) -> ! {
    // SAFETY: CO is the running coroutine (rooted through Vm::co_current for
    // as long as it runs); P is the Vm every frame shares.
    unsafe {
        // Arrived on this fresh stack (segment's doc).
        if let Some(stack) = &(*co).stack {
            (*p).publish_active_stack(Some(stack.bounds()));
        }
        let thunk = (*co).thunk;
        let result = if heap_kind(thunk) == KIND_CLOSURE {
            let c = closure_of(thunk);
            let entry: GenericEntry = std::mem::transmute(c.code);
            entry(p, thunk, std::ptr::null())
        } else {
            (*p).fail(RtError::Bug("a coroutine's body is not a Block".to_string()))
        };
        (*co).thunk = UNIT;
        if result == NO_VALUE {
            let error = (*p)
                .error
                .take()
                .unwrap_or_else(|| RtError::Bug("a coroutine body failed without recording an error".to_string()));
            let id = (*p).declared_error;
            (*p).declared_error = 0;
            let payload = std::mem::take(&mut (*p).declared_payload);
            let shape = (*p).declared_payload_shape;
            (*co).failure = Some(Box::new((error, id, payload, shape)));
            (*co).state = CO_FAILED;
        } else {
            (*co).value = result;
            (*co).state = CO_COMPLETED;
        }
        let mut finished = SwitchPoint::default();
        bl_co_switch(&mut finished, (*co).resumer_sp, 0);
    }
    std::process::abort()
}

// ---------------------------------------------------------------------------
// Helpers

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_co_create(p: *mut Vm, thunk: Value) -> Value {
    vm(p).alloc(
        CoroutineObj {
            hdr: Header::new(KIND_COROUTINE, false),
            state: CO_FRESH,
            thunk,
            value: UNIT,
            failure: None,
            stack: None,
            saved_sp: SwitchPoint::default(),
            resumer_sp: SwitchPoint::default(),
            resumer: std::ptr::null_mut(),
        },
        0,
    )
}

/// The eager start: the body from its beginning to its first boundary.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_start(p: *mut Vm, handle: Value) -> Value {
    let co = handle as *mut CoroutineObj;
    // SAFETY: HANDLE is a live coroutine object (static typing; a guard
    // otherwise), referenced only through raw pointers across the switch.
    unsafe {
        if (*co).state != CO_FRESH {
            return vm(p).fail(RtError::Semantic { kind: "COROUTINE-STATE", message: "the coroutine was already started".to_string() });
        }
        if !super::framewalk::NATIVE_FRAME_ROOTS {
            return vm(p).fail(RtError::Unsupported(
                "native coroutines need GC roots in native frames: the fallback root plan (a fallback-roots build) runs none (COROUTINES.md)"
                    .to_string(),
            ));
        }
        let stack = match CoStack::new() {
            Ok((stack, reused)) => {
                vm(p).metrics.record_coroutine_stack(reused);
                stack
            }
            Err(error) => return vm(p).fail(error),
        };
        // Stacks are not heap bytes, but each started coroutine should pace
        // collection, or abandoned ones would never be reclaimed.
        vm(p).heap.note_growth(16 * 1024);
        (*co).saved_sp = prepare(&stack, p, co);
        (*co).stack = Some(stack);
        segment(p, co)
    }
}

/// Lays out a fresh stack so that switching to it enters bl_co_trampoline
/// with r12 = P and r13 = CO. Returns the stack pointer to switch to.
#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
unsafe fn prepare(stack: &CoStack, p: *mut Vm, co: *mut CoroutineObj) -> usize {
    let top = stack.top() & !15;
    // MXCSR 0x1F80 and the x87 control word 0x037F: the SysV defaults.
    let control: usize = 0x1F80 | (0x037F << 32);
    let words: [usize; 10] = [
        control,                          // top - 80: control words
        0,                                // r15
        0,                                // r14
        co as usize,                      // r13
        p as usize,                       // r12
        0,                                // rbx
        0,                                // rbp: the end of the chain
        bl_co_trampoline as *const () as usize, // return address of the switch
        0,                                // the trampoline frame's return slot
        0,
    ];
    let sp = top - 8 * words.len();
    for (i, word) in words.iter().enumerate() {
        // SAFETY: within the usable range of a stack nothing else uses.
        unsafe { *((sp + 8 * i) as *mut usize) = *word };
    }
    sp
}

/// AArch64: the same contract; the first switch restores x19 = P, x20 = CO,
/// x29 = 0 (the end of the chain) and returns to x30 = bl_co_trampoline.
#[cfg(target_arch = "aarch64")]
unsafe fn prepare(stack: &CoStack, p: *mut Vm, co: *mut CoroutineObj) -> usize {
    let top = stack.top() & !15;
    // In bl_co_switch's restore order, lowest address first: FPCR (0: round
    // to nearest, no traps, the default of a new thread on Linux and Darwin
    // alike; `a_new_context_starts_with_the_threads_fpcr` pins it) and its
    // pad, d14/d15 ...
    // d8/d9 (zero), x27/x28 ... x21/x22 (zero), x19/x20, then the frame
    // record x29/x30.
    let mut words = [0usize; 22];
    words[18] = p as usize; // x19
    words[19] = co as usize; // x20
    words[20] = 0; // x29: the end of the chain
    words[21] = bl_co_trampoline as *const () as usize; // x30
    let sp = top - 8 * words.len();
    for (i, word) in words.iter().enumerate() {
        // SAFETY: within the usable range of a stack nothing else uses.
        unsafe { *((sp + 8 * i) as *mut usize) = *word };
    }
    sp
}

#[cfg(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc"))))]
unsafe fn prepare(_stack: &CoStack, _p: *mut Vm, _co: *mut CoroutineObj) -> usize {
    0
}

/// Runs one segment of CO (fresh or suspended, its transport slot already
/// holding the message): links it into the running chain, switches to its
/// stack, and returns its outcome when it yields or ends.
///
/// Stack publication (the overflow guard's, runtime::platform): each side of a
/// switch publishes the stack it arrives on, right after the switch returns
/// to it -- here, `co_body` and `rt_co_yield` -- and nothing publishes before
/// switching away. bl_co_switch's pushes land on the stack it leaves, which
/// is therefore still the published one when they could fault; and arriving
/// code publishes before it can grow its stack past where it was (the
/// publication is inlined atomic stores in a frame that already exists).
unsafe fn segment(p: *mut Vm, co: *mut CoroutineObj) -> Value {
    unsafe {
        (*co).resumer = (*p).co_current;
        (*p).co_current = co;
        (*co).state = CO_RUNNING;
        bl_co_switch(&mut (*co).resumer_sp, (*co).saved_sp, 0);
        (*p).co_current = (*co).resumer;
        (*co).resumer = std::ptr::null_mut();
        let outer = (*p).co_current;
        let outer_stack = if outer.is_null() { None } else { (*outer).stack.as_ref().map(|s| s.bounds()) };
        (*p).publish_active_stack(outer_stack);
        match (*co).state {
            CO_SUSPENDED => (*co).value,
            CO_COMPLETED => {
                (*co).stack = None;
                (*co).value
            }
            CO_FAILED => {
                (*co).stack = None;
                reraise(p, co)
            }
            state => vm(p).fail(RtError::Bug(format!("a coroutine segment ended in state {state}"))),
        }
    }
}

/// Raises CO's cached terminal failure again (stable terminal failure).
unsafe fn reraise(p: *mut Vm, co: *mut CoroutineObj) -> Value {
    unsafe {
        let Some(failure) = &(*co).failure else {
            return vm(p).fail(RtError::Bug("a failed coroutine has no cached failure".to_string()));
        };
        let (error, id) = (failure.0.clone(), failure.1);
        (*p).declared_error = id;
        (*p).declared_payload.clear();
        (*p).declared_payload.extend_from_slice(&failure.2);
        (*p).declared_payload_shape = failure.3;
        (*p).error = Some(error);
        NO_VALUE
    }
}

fn resume(p: *mut Vm, handle: Value, message: Value) -> Value {
    let co = handle as *mut CoroutineObj;
    // SAFETY: as in rt_co_start.
    unsafe {
        match (*co).state {
            CO_SUSPENDED => {
                (*co).value = message;
                segment(p, co)
            }
            // Stable terminal success: the cached result, no body code.
            CO_COMPLETED => (*co).value,
            // Stable terminal failure: the cached error, no body code.
            CO_FAILED => reraise(p, co),
            CO_RUNNING => vm(p).fail(RtError::Semantic {
                kind: "COROUTINE-RUNNING",
                message: "the coroutine is already running: a coroutine cannot resume itself".to_string(),
            }),
            CO_RELEASED => vm(p).fail(RtError::Semantic {
                kind: "COROUTINE-STATE",
                message: "the coroutine was released after its handle's last use: nothing can resume it (a compiler bug)"
                    .to_string(),
            }),
            _ => vm(p).fail(RtError::Semantic { kind: "COROUTINE-STATE", message: "the coroutine was never started".to_string() }),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_co_resume(p: *mut Vm, handle: Value, message: Value) -> Value {
    resume(p, handle, message)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_co_resume0(p: *mut Vm, handle: Value) -> Value {
    resume(p, handle, UNIT)
}

/// Suspends the running coroutine with outward VALUE; returns the message
/// the next resume delivers.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_yield(p: *mut Vm, value: Value) -> Value {
    // SAFETY: the running coroutine is rooted through Vm::co_current; its
    // fields are only touched through the raw pointer around the switch.
    unsafe {
        let co = (*p).co_current;
        if co.is_null() {
            return vm(p).fail(RtError::Semantic {
                kind: "YIELD-OUTSIDE-COROUTINE",
                message: "yield outside a coroutine: no coroutine is running here".to_string(),
            });
        }
        (*co).value = value;
        (*co).state = CO_SUSPENDED;
        bl_co_switch(&mut (*co).saved_sp, (*co).resumer_sp, 0);
        // Resumed: arrived on this coroutine's stack again (segment's doc).
        if let Some(stack) = &(*co).stack {
            (*p).publish_active_stack(Some(stack.bounds()));
        }
        // NO_VALUE: abandoned (rt_co_abandon), the abandonment pending in the
        // Vm -- the yield fails with it, and the frames unwind through their
        // release pads.
        (*co).value
    }
}

/// Abandons coroutine HANDLE, whose handle is dead, in an unwinding program
/// (`coabandon`; hir/affine.tcl's Unwinds,
/// LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md): a suspended
/// coroutine is resumed with its pending yield failing with the internal
/// abandonment (ERR_COROUTINE_ABANDONED), which no handler handles -- every
/// frame's release pad for it runs (the cleanups of the resources the frames
/// own, the abandonment of the coroutines they own) and nothing else does --
/// and then it is released (`rt_co_release`). The releaser's own pending
/// failure, if it releases on an error edge, is set aside meanwhile. A
/// run-time fault of the release code is the abandonment's failure. Any
/// other state is a plain release. Idempotent.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_abandon(p: *mut Vm, handle: Value) -> Value {
    let co = handle as *mut CoroutineObj;
    // SAFETY: as in rt_co_start: HANDLE is a live coroutine object, touched
    // through the raw pointer around the switch; it is rooted meanwhile.
    unsafe {
        if (*co).state != CO_SUSPENDED || (*co).stack.is_none() {
            return rt_co_release(p, handle);
        }
        vm(p).metrics.record_coroutine_abandoned();
        let rooted = vm(p).temp_roots.len();
        vm(p).temp_roots.push(handle);
        let unwound = super::affine::preserving_pending(p, || {
            vm(p).declared_error = super::error::ERR_COROUTINE_ABANDONED;
            vm(p).declared_payload.clear();
            vm(p).fail(RtError::Semantic { kind: "COROUTINE-ABANDONED", message: "a coroutine was abandoned".to_string() });
            (*co).value = NO_VALUE;
            let outcome = segment(p, co);
            if outcome != NO_VALUE {
                // A body that completed instead: it caught nothing (no
                // handler can name the abandonment), so it cannot have.
                return vm(p).fail(RtError::Bug("an abandoned coroutine completed".to_string())) != NO_VALUE;
            }
            if vm(p).declared_error == super::error::ERR_COROUTINE_ABANDONED {
                // Unwound to its end: the abandonment is spent.
                vm(p).error = None;
                vm(p).declared_error = 0;
                vm(p).declared_payload.clear();
                return true;
            }
            // A run-time fault of a release on the way out.
            false
        });
        vm(p).temp_roots.truncate(rooted);
        rt_co_release(p, handle);
        if unwound { UNIT } else { NO_VALUE }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_co_done(_p: *mut Vm, handle: Value) -> Value {
    let co = coroutine_of(handle);
    // RELEASED is unreachable here (the handle is dead); it is terminal.
    if matches!(co.state, CO_COMPLETED | CO_FAILED | CO_RELEASED) { TRUE } else { FALSE }
}

/// Releases coroutine HANDLE, whose handle is dead from here: native/lower.tcl
/// emits `corelease` right after the handle's last use, which the affine
/// analysis found (hir/coroutines.tcl's Releases). A suspended coroutine's
/// stack goes back to the pool at once instead of when a collection finds
/// the handle unreachable -- nothing on it runs again either way, and no
/// frame on it owns a Rust value with a destructor (as when one is swept) --
/// and every coroutine drops its thunk, cached result and cached failure.
/// Never observable, never fails, never allocates.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_release(p: *mut Vm, handle: Value) -> Value {
    let co = coroutine_of(handle);
    if matches!(co.state, CO_RUNNING | CO_RELEASED) {
        // Released already (by another owner, in a branch: the compiler's
        // releases are idempotent), or -- defensive -- running: a dead
        // handle is never one of the running chain.
        return UNIT;
    }
    vm(p).metrics.record_coroutine_release(co.state == CO_SUSPENDED && co.stack.is_some());
    co.stack = None;
    co.thunk = UNIT;
    co.value = UNIT;
    co.failure = None;
    co.state = CO_RELEASED;
    UNIT
}

/// A terminal, failed coroutine holding the pending error, which it takes
/// from the Vm exactly as `co_body` takes a body's unhandled failure: the
/// error, its declared id and its payload (COROUTINE-FUSION-MILESTONE-1.md).
/// The coroutine fusion pass (codegen::fusion) emits it (`cofailed`) where a
/// fused coroutine's segment fails; resuming the object (`coresume0`) raises
/// the failure again through `reraise`, so the resume that ran the segment
/// and every later one fail as a general coroutine's do. It never ran and
/// never runs code: no thunk, no stack.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_failed(p: *mut Vm) -> Value {
    // Allocated first: a collection the allocation runs still finds the
    // pending error's values where the Vm roots them.
    let handle = vm(p).alloc(
        CoroutineObj {
            hdr: Header::new(KIND_COROUTINE, false),
            state: CO_FAILED,
            thunk: UNIT,
            value: UNIT,
            failure: None,
            stack: None,
            saved_sp: SwitchPoint::default(),
            resumer_sp: SwitchPoint::default(),
            resumer: std::ptr::null_mut(),
        },
        0,
    );
    let vm = vm(p);
    let error = vm
        .error
        .take()
        .unwrap_or_else(|| RtError::Bug("a fused coroutine failed without recording an error".to_string()));
    let id = vm.declared_error;
    vm.declared_error = 0;
    let payload = std::mem::take(&mut vm.declared_payload);
    let shape = vm.declared_payload_shape;
    coroutine_of(handle).failure = Some(Box::new((error, id, payload, shape)));
    handle
}

/// The stack frame record a suspended context's walk starts at: the frame
/// bl_co_switch opened, `SWITCH_FRAME_OFFSET` above its saved stack pointer.
#[cfg(not(all(windows, target_arch = "x86_64", target_env = "msvc")))]
pub fn suspended_rbp(saved_sp: usize) -> usize {
    saved_sp + SWITCH_FRAME_OFFSET
}

/// Windows: the frame a suspended context's walk starts at is the frame its
/// bl_co_switch recorded (RIP, RSP and RBP), from which Windows' unwinder
/// climbs (runtime::framewalk's `walk_from`).
#[cfg(all(windows, target_arch = "x86_64", target_env = "msvc"))]
pub fn suspended_rbp(saved_sp: SwitchPoint) -> super::framewalk::windows::Frame {
    saved_sp.frame
}

#[cfg(all(
    test,
    any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")),
    not(feature = "fallback-roots")
))]
mod tests {
    use super::*;
    use crate::runtime::metrics::{AllocMode, GcReason};
    use crate::runtime::vm::ProgramInfo;

    fn new_vm() -> Box<Vm> {
        Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }), AllocMode::Summary)
    }

    /// A zero-argument Block whose code is the Rust function CODE (the
    /// generic entry ABI), standing in for a compiled thunk.
    fn thunk(vm: &mut Vm, code: GenericEntry) -> Value {
        let caps: Box<[Value]> = Vec::new().into_boxed_slice();
        vm.alloc(
            ClosureObj {
                hdr: Header::new(KIND_CLOSURE, false),
                func: 0,
                arity: 0,
                code: code as *const () as usize,
                ncaps: 0,
                caps: Box::into_raw(caps) as *mut Value,
            },
            0,
        )
    }

    /// Yields 1, then the message + 10, then returns the second message * 2.
    extern "C" fn counting(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let m = rt_co_yield(p, make_small(1));
        let n = rt_co_yield(p, make_small(small_of(m) + 10));
        make_small(small_of(n) * 2)
    }

    /// Fails at once with a semantic error.
    extern "C" fn failing(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        unsafe { (*p).fail(RtError::Semantic { kind: "RANGE", message: "boom".to_string() }) }
    }

    /// Fails with declared error 3 carrying a two-field payload: a heap Int
    /// and a String (ERROR-PAYLOADS.md), allocating with collections forced
    /// on the way.
    extern "C" fn failing_payload(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        unsafe {
            let big = (*p).new_big(num_bigint::BigInt::from(5u8) << 90u32);
            (*p).temp_roots.push(big);
            let text = (*p).new_str("payload");
            (*p).temp_roots.push(text);
            let name = (*p).new_str("Overflow");
            let fields = [big, text];
            let r = super::super::ops::rt_fail_declared_payload(p, 3, name, 0, 2, fields.as_ptr());
            (*p).temp_roots.pop();
            (*p).temp_roots.pop();
            r
        }
    }

    /// Returns at once: a coroutine need not reach a yield.
    extern "C" fn immediate(_p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        make_small(7)
    }

    /// Yields, allocating heavily (with collections forced) both before and
    /// after the yield, and yields once more.
    extern "C" fn allocating(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        for _ in 0..50 {
            unsafe { (*p).new_big(num_bigint::BigInt::from(1u8) << 100u32) };
        }
        let m = rt_co_yield(p, make_small(5));
        for _ in 0..50 {
            unsafe { (*p).new_big(num_bigint::BigInt::from(1u8) << 100u32) };
        }
        rt_co_yield(p, m);
        make_small(0)
    }

    thread_local! {
        static INNER: std::cell::Cell<Value> = const { std::cell::Cell::new(0) };
    }

    /// Starts and resumes another coroutine (counting) inside its own
    /// segments: nested coroutines, each on its own stack.
    extern "C" fn outer(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let t = thunk(unsafe { &mut *p }, counting);
        unsafe { (*p).temp_roots.push(t) };
        let inner = rt_co_create(p, t);
        unsafe { (*p).temp_roots.push(inner) };
        INNER.with(|c| c.set(inner));
        let a = rt_co_start(p, inner);
        let m = rt_co_yield(p, a);
        let b = rt_co_resume(p, inner, m);
        make_small(small_of(b) * 100)
    }

    // Every test roots the values only its own Rust frames hold
    // (`Vm::temp_roots`), as compiled code's stack maps root its operands, so
    // the tests hold under BOTLISH_NATIVE_GC_STRESS=1 too.

    #[test]
    fn yields_resumes_and_keeps_its_final_result() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, counting);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_done(&mut *vm, co), FALSE);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        assert_eq!(rt_co_done(&mut *vm, co), FALSE);
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(5)), make_small(15));
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(21)), make_small(42));
        assert_eq!(rt_co_done(&mut *vm, co), TRUE);
        // Stable terminal success: the same value, no body code.
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(999)), make_small(42));
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(42));
        assert!(coroutine_of(co).stack.is_none());
        assert!(vm.co_current.is_null());
    }

    #[test]
    fn a_failure_is_terminal_and_raised_again() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, failing);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), NO_VALUE);
        assert_eq!(vm.error.take().map(|e| e.message()), Some("boom".to_string()));
        assert_eq!(rt_co_done(&mut *vm, co), TRUE);
        assert_eq!(rt_co_resume0(&mut *vm, co), NO_VALUE);
        assert_eq!(vm.error.take().map(|e| e.error_code()), Some(vec!["CORE", "SEMANTIC", "RANGE"]));
    }

    #[test]
    fn error_payload_of_a_failed_coroutine_is_cached_and_raised_again() {
        // ERROR-PAYLOADS.md: a failed coroutine keeps its declared error's
        // payload with the failure (a GC root while cached) and raises the
        // same payload again on every later resume.
        let mut vm = new_vm();
        vm.heap.set_stress_for_test(true);
        let t = thunk(&mut vm, failing_payload);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), NO_VALUE);
        assert_eq!(vm.declared_error, 3);
        assert_eq!(vm.declared_payload.len(), 2);
        assert_eq!(str_of(vm.declared_payload[1]).as_str(), "payload");
        vm.declared_error = 0;
        vm.declared_payload.clear();
        vm.error = None;
        for _ in 0..3 {
            vm.collect_for_test(GcReason::Explicit);
            assert_eq!(rt_co_resume0(&mut *vm, co), NO_VALUE);
            assert_eq!(vm.declared_error, 3);
            assert_eq!(vm.declared_payload.len(), 2);
            assert_eq!(super::super::show::show(vm.declared_payload[0]), (num_bigint::BigInt::from(5u8) << 90u32).to_string());
            assert_eq!(str_of(vm.declared_payload[1]).as_str(), "payload");
            assert_eq!(crate::runtime::ops::rt_clear_declared_error(&mut *vm), 0);
            assert!(vm.declared_payload.is_empty());
        }
    }

    #[test]
    fn return_before_any_yield_completes_at_the_start() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, immediate);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(7));
        assert_eq!(rt_co_done(&mut *vm, co), TRUE);
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(7));
    }

    #[test]
    fn collections_inside_and_between_segments_keep_live_values() {
        let mut vm = new_vm();
        vm.heap.set_stress_for_test(true);
        // Values held only by these Rust frames are rooted by hand (compiled
        // code's own operands are, by its stack maps).
        let t = thunk(&mut vm, allocating);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(5));
        let message = vm.new_big(num_bigint::BigInt::from(3u8) << 80u32);
        vm.temp_roots.push(message);
        vm.collect_for_test(GcReason::Explicit);
        // The message is rooted only by the transport slot across the
        // switch, then by the coroutine's own stack while it allocates.
        let back = rt_co_resume(&mut *vm, co, message);
        assert_eq!(back, message);
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(0));
    }

    #[test]
    fn nested_coroutines_run_on_their_own_stacks() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, outer);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        let inner = INNER.with(|c| c.get());
        vm.temp_roots.push(inner);
        assert_eq!(rt_co_done(&mut *vm, inner), FALSE);
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(2)), make_small(1200));
        assert_eq!(rt_co_done(&mut *vm, co), TRUE);
        assert_eq!(rt_co_done(&mut *vm, inner), FALSE);
    }

    #[test]
    fn an_abandoned_suspended_coroutine_is_collected_and_its_stack_pooled() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, counting);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        assert!(coroutine_of(co).stack.is_some());
        let before = pooled_stacks();
        vm.temp_roots.clear();
        vm.collect_for_test(GcReason::Explicit);
        assert_eq!(pooled_stacks(), before + 1);
        // A pooled stack is reused by the next start.
        let t = thunk(&mut vm, immediate);
        vm.temp_roots.push(t);
        let again = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(again);
        assert_eq!(rt_co_start(&mut *vm, again), make_small(7));
        assert_eq!(pooled_stacks(), before + 1);
    }

    #[test]
    fn yield_outside_a_coroutine_is_an_error() {
        let mut vm = new_vm();
        assert_eq!(rt_co_yield(&mut *vm, UNIT), NO_VALUE);
        assert_eq!(
            vm.error.take().map(|e| e.error_code()),
            Some(vec!["CORE", "SEMANTIC", "YIELD-OUTSIDE-COROUTINE"])
        );
    }

    // -- Machine-boundary tests (MACOS-AARCH64-MILESTONE-3.md): the switch's
    // ABI contract, observed through running code rather than read off the
    // assembly. They run on every host that has native coroutines.

    /// Calls F(P, A, B) with every callee-saved general-purpose register
    /// (and, on AArch64, d8-d15) loaded with a pattern derived from SEED, and
    /// returns how many of them differ afterwards. A call that suspends and
    /// resumes inside F, or a switch that forgets one of them, shows as a
    /// count -- provided the context the switch lands in used another seed
    /// (the resumer's and the coroutine's do), or a register left as it was
    /// would look restored.
    #[cfg(target_arch = "aarch64")]
    #[unsafe(naked)]
    extern "C" fn pattern_call(_f: usize, _p: *mut Vm, _a: Value, _b: Value, _seed: usize) -> usize {
        std::arch::naked_asm!(
            "stp x29, x30, [sp, #-16]!",
            "mov x29, sp",
            "stp x19, x20, [sp, #-16]!",
            "stp x21, x22, [sp, #-16]!",
            "stp x23, x24, [sp, #-16]!",
            "stp x25, x26, [sp, #-16]!",
            "stp x27, x28, [sp, #-16]!",
            "stp d8, d9, [sp, #-16]!",
            "stp d10, d11, [sp, #-16]!",
            "stp d12, d13, [sp, #-16]!",
            "stp d14, d15, [sp, #-16]!",
            "str x4, [sp, #-16]!",
            "mov x16, x0",
            "mov x0, x1",
            "mov x1, x2",
            "mov x2, x3",
            "add x19, x4, #0x13",
            "add x20, x4, #0x14",
            "add x21, x4, #0x15",
            "add x22, x4, #0x16",
            "add x23, x4, #0x17",
            "add x24, x4, #0x18",
            "add x25, x4, #0x19",
            "add x26, x4, #0x1a",
            "add x27, x4, #0x1b",
            "add x28, x4, #0x1c",
            "add x9, x4, #0x8",
            "fmov d8, x9",
            "add x9, x4, #0x9",
            "fmov d9, x9",
            "add x9, x4, #0xa",
            "fmov d10, x9",
            "add x9, x4, #0xb",
            "fmov d11, x9",
            "add x9, x4, #0xc",
            "fmov d12, x9",
            "add x9, x4, #0xd",
            "fmov d13, x9",
            "add x9, x4, #0xe",
            "fmov d14, x9",
            "add x9, x4, #0xf",
            "fmov d15, x9",
            "blr x16",
            "ldr x4, [sp], #16",
            "mov x9, xzr",
            "add x10, x4, #0x13",
            "cmp x19, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x14",
            "cmp x20, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x15",
            "cmp x21, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x16",
            "cmp x22, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x17",
            "cmp x23, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x18",
            "cmp x24, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x19",
            "cmp x25, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x1a",
            "cmp x26, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x1b",
            "cmp x27, x10",
            "cinc x9, x9, ne",
            "add x10, x4, #0x1c",
            "cmp x28, x10",
            "cinc x9, x9, ne",
            "fmov x11, d8",
            "add x10, x4, #0x8",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d9",
            "add x10, x4, #0x9",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d10",
            "add x10, x4, #0xa",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d11",
            "add x10, x4, #0xb",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d12",
            "add x10, x4, #0xc",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d13",
            "add x10, x4, #0xd",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d14",
            "add x10, x4, #0xe",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "fmov x11, d15",
            "add x10, x4, #0xf",
            "cmp x11, x10",
            "cinc x9, x9, ne",
            "mov x0, x9",
            "ldp d14, d15, [sp], #16",
            "ldp d12, d13, [sp], #16",
            "ldp d10, d11, [sp], #16",
            "ldp d8, d9, [sp], #16",
            "ldp x27, x28, [sp], #16",
            "ldp x25, x26, [sp], #16",
            "ldp x23, x24, [sp], #16",
            "ldp x21, x22, [sp], #16",
            "ldp x19, x20, [sp], #16",
            "ldp x29, x30, [sp], #16",
            "ret",
        )
    }

    #[cfg(all(target_arch = "x86_64", not(windows)))]
    #[unsafe(naked)]
    extern "C" fn pattern_call(_f: usize, _p: *mut Vm, _a: Value, _b: Value, _seed: usize) -> usize {
        std::arch::naked_asm!(
            "push rbp",
            "mov rbp, rsp",
            "push rbx",
            "push r12",
            "push r13",
            "push r14",
            "push r15",
            "sub rsp, 8",
            "mov [rsp], r8",
            "mov rax, rdi",
            "mov rdi, rsi",
            "mov rsi, rdx",
            "mov rdx, rcx",
            "lea rbx, [r8 + 1]",
            "lea r12, [r8 + 2]",
            "lea r13, [r8 + 3]",
            "lea r14, [r8 + 4]",
            "lea r15, [r8 + 5]",
            "call rax",
            "mov r9, [rsp]",
            "xor r8d, r8d",
            "lea r10, [r9 + 1]",
            "cmp rbx, r10",
            "setne r10b",
            "movzx r10d, r10b",
            "add r8, r10",
            "lea r10, [r9 + 2]",
            "cmp r12, r10",
            "setne r10b",
            "movzx r10d, r10b",
            "add r8, r10",
            "lea r10, [r9 + 3]",
            "cmp r13, r10",
            "setne r10b",
            "movzx r10d, r10b",
            "add r8, r10",
            "lea r10, [r9 + 4]",
            "cmp r14, r10",
            "setne r10b",
            "movzx r10d, r10b",
            "add r8, r10",
            "lea r10, [r9 + 5]",
            "cmp r15, r10",
            "setne r10b",
            "movzx r10d, r10b",
            "add r8, r10",
            "mov rax, r8",
            "add rsp, 8",
            "pop r15",
            "pop r14",
            "pop r13",
            "pop r12",
            "pop rbx",
            "pop rbp",
            "ret",
        )
    }

    /// Windows x86-64: the Win64 callee-saved state -- RBX, RBP, RDI, RSI,
    /// R12-R15 and both halves of XMM6-XMM15 -- loaded from SEED around
    /// F(P, A, B); the count of those that differ afterwards.
    #[cfg(all(target_arch = "x86_64", windows))]
    #[unsafe(naked)]
    extern "C" fn pattern_call(_f: usize, _p: *mut Vm, _a: Value, _b: Value, _seed: usize) -> usize {
        std::arch::naked_asm!(
            "push rbp", "push rbx", "push rdi", "push rsi", "push r12", "push r13", "push r14", "push r15",
            "sub rsp, 200",
            "movaps [rsp + 32], xmm6", "movaps [rsp + 48], xmm7", "movaps [rsp + 64], xmm8", "movaps [rsp + 80], xmm9",
            "movaps [rsp + 96], xmm10", "movaps [rsp + 112], xmm11", "movaps [rsp + 128], xmm12", "movaps [rsp + 144], xmm13",
            "movaps [rsp + 160], xmm14", "movaps [rsp + 176], xmm15",
            // The fifth argument, above the return address and the caller's
            // shadow space: 40 bytes above the entry's stack pointer.
            "mov rax, [rsp + 304]",
            "mov [rsp + 192], rax",
            "mov r10, rcx",
            "mov rcx, rdx",
            "mov rdx, r8",
            "mov r8, r9",
            "lea rbx, [rax + 1]", "lea rbp, [rax + 2]", "lea rdi, [rax + 3]", "lea rsi, [rax + 4]",
            "lea r12, [rax + 5]", "lea r13, [rax + 6]", "lea r14, [rax + 7]", "lea r15, [rax + 8]",
            "lea r11, [rax + 0x16]", "movq xmm6, r11", "lea r11, [rax + 0x26]", "movq xmm0, r11", "punpcklqdq xmm6, xmm0",
            "lea r11, [rax + 0x17]", "movq xmm7, r11", "lea r11, [rax + 0x27]", "movq xmm0, r11", "punpcklqdq xmm7, xmm0",
            "lea r11, [rax + 0x18]", "movq xmm8, r11", "lea r11, [rax + 0x28]", "movq xmm0, r11", "punpcklqdq xmm8, xmm0",
            "lea r11, [rax + 0x19]", "movq xmm9, r11", "lea r11, [rax + 0x29]", "movq xmm0, r11", "punpcklqdq xmm9, xmm0",
            "lea r11, [rax + 0x1a]", "movq xmm10, r11", "lea r11, [rax + 0x2a]", "movq xmm0, r11", "punpcklqdq xmm10, xmm0",
            "lea r11, [rax + 0x1b]", "movq xmm11, r11", "lea r11, [rax + 0x2b]", "movq xmm0, r11", "punpcklqdq xmm11, xmm0",
            "lea r11, [rax + 0x1c]", "movq xmm12, r11", "lea r11, [rax + 0x2c]", "movq xmm0, r11", "punpcklqdq xmm12, xmm0",
            "lea r11, [rax + 0x1d]", "movq xmm13, r11", "lea r11, [rax + 0x2d]", "movq xmm0, r11", "punpcklqdq xmm13, xmm0",
            "lea r11, [rax + 0x1e]", "movq xmm14, r11", "lea r11, [rax + 0x2e]", "movq xmm0, r11", "punpcklqdq xmm14, xmm0",
            "lea r11, [rax + 0x1f]", "movq xmm15, r11", "lea r11, [rax + 0x2f]", "movq xmm0, r11", "punpcklqdq xmm15, xmm0",
            "call r10",
            "mov r9, [rsp + 192]",
            "xor eax, eax",
            "lea r10, [r9 + 1]", "cmp rbx, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 2]", "cmp rbp, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 3]", "cmp rdi, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 4]", "cmp rsi, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 5]", "cmp r12, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 6]", "cmp r13, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 7]", "cmp r14, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "lea r10, [r9 + 8]", "cmp r15, r10", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm6", "lea r11, [r9 + 0x16]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm6, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x26]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm7", "lea r11, [r9 + 0x17]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm7, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x27]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm8", "lea r11, [r9 + 0x18]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm8, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x28]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm9", "lea r11, [r9 + 0x19]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm9, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x29]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm10", "lea r11, [r9 + 0x1a]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm10, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2a]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm11", "lea r11, [r9 + 0x1b]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm11, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2b]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm12", "lea r11, [r9 + 0x1c]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm12, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2c]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm13", "lea r11, [r9 + 0x1d]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm13, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2d]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm14", "lea r11, [r9 + 0x1e]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm14, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2e]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movq r10, xmm15", "lea r11, [r9 + 0x1f]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "pshufd xmm0, xmm15, 0xee", "movq r10, xmm0", "lea r11, [r9 + 0x2f]", "cmp r10, r11", "setne r11b", "movzx r11d, r11b", "add rax, r11",
            "movaps xmm6, [rsp + 32]", "movaps xmm7, [rsp + 48]", "movaps xmm8, [rsp + 64]", "movaps xmm9, [rsp + 80]",
            "movaps xmm10, [rsp + 96]", "movaps xmm11, [rsp + 112]", "movaps xmm12, [rsp + 128]", "movaps xmm13, [rsp + 144]",
            "movaps xmm14, [rsp + 160]", "movaps xmm15, [rsp + 176]",
            "add rsp, 200",
            "pop r15", "pop r14", "pop r13", "pop r12", "pop rsi", "pop rdi", "pop rbx", "pop rbp",
            "ret",
        )
    }

    /// Yields from inside pattern_call; its result is how many registers
    /// the yield (the switch away and back) changed.
    extern "C" fn clobbering_body(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let changed = pattern_call(rt_co_yield as *const () as usize, p, make_small(1), 0, 0x2000);
        make_small(changed as i64)
    }

    #[test]
    fn callee_saved_registers_survive_every_switch() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, clobbering_body);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        let vm_ptr: *mut Vm = &mut *vm;
        // The resumer's side: the switch into a fresh stack and back from the
        // yield, then the resume of the suspended context.
        assert_eq!(pattern_call(rt_co_start as *const () as usize, vm_ptr, co, 0, 0x1000), 0);
        assert_eq!(rt_co_done(vm_ptr, co), FALSE);
        assert_eq!(pattern_call(rt_co_resume as *const () as usize, vm_ptr, co, UNIT, 0x1000), 0);
        // The coroutine's side: its own registers across the yield.
        assert_eq!(rt_co_done(vm_ptr, co), TRUE);
        assert_eq!(rt_co_resume0(vm_ptr, co), make_small(0));
    }

    #[cfg(target_arch = "aarch64")]
    fn read_fpcr() -> u64 {
        let v: u64;
        // SAFETY: reads the thread's floating-point control register.
        unsafe { std::arch::asm!("mrs {}, fpcr", out(reg) v, options(nomem, nostack)) };
        v
    }

    #[cfg(target_arch = "aarch64")]
    fn write_fpcr(v: u64) {
        // SAFETY: sets the thread's rounding mode; tests restore it.
        unsafe { std::arch::asm!("msr fpcr, {}", in(reg) v, options(nomem, nostack)) };
    }

    #[cfg(target_arch = "aarch64")]
    fn read_sp() -> u64 {
        let v: u64;
        // SAFETY: reads sp.
        unsafe { std::arch::asm!("mov {}, sp", out(reg) v, options(nomem, nostack)) };
        v
    }

    /// FPCR travels with a context: the body changes its rounding mode and
    /// yields; the resumer must see its own mode, and the body its own again.
    #[cfg(target_arch = "aarch64")]
    extern "C" fn fpcr_body(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let before = read_fpcr();
        write_fpcr(before | (3 << 22));
        rt_co_yield(p, make_small(1));
        let kept = read_fpcr() == before | (3 << 22);
        write_fpcr(before);
        make_small(if kept && before == 0 { 1 } else { 0 })
    }

    /// The initial context's FPCR is 0, the default of a new thread on Linux
    /// and Darwin alike (`prepare` writes the constant).
    #[cfg(target_arch = "aarch64")]
    #[test]
    fn a_new_context_starts_with_the_threads_fpcr() {
        assert_eq!(read_fpcr(), 0, "a thread's default FPCR is not the 0 prepare() installs");
    }

    #[cfg(target_arch = "aarch64")]
    #[test]
    fn fpcr_is_part_of_the_context() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, fpcr_body);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        assert_eq!(read_fpcr(), 0, "the coroutine's rounding mode leaked into its resumer");
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(1));
        assert_eq!(read_fpcr(), 0);
    }

    thread_local! {
        static SP_SEEN: std::cell::RefCell<Vec<u64>> = const { std::cell::RefCell::new(Vec::new()) };
    }

    /// Records the stack pointer at the body, across a yield, and at the end.
    #[cfg(target_arch = "aarch64")]
    extern "C" fn sp_body(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        SP_SEEN.with(|seen| seen.borrow_mut().push(read_sp()));
        rt_co_yield(p, make_small(1));
        SP_SEEN.with(|seen| seen.borrow_mut().push(read_sp()));
        rt_co_yield(p, make_small(2));
        SP_SEEN.with(|seen| seen.borrow_mut().push(read_sp()));
        make_small(3)
    }

    /// AArch64 faults on a misaligned sp-based access, so a wrong initial or
    /// restored sp would be a crash; this pins the value itself (the
    /// published ABI keeps sp 16-byte aligned at every call boundary) and
    /// that it lies on the coroutine's own mapping.
    #[cfg(target_arch = "aarch64")]
    #[test]
    fn the_stack_pointer_is_aligned_and_on_the_coroutines_stack() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, sp_body);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        SP_SEEN.with(|seen| seen.borrow_mut().clear());
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        let bounds = coroutine_of(co).stack.as_ref().unwrap().bounds();
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(2));
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(3));
        let seen = SP_SEEN.with(|seen| seen.borrow().clone());
        assert_eq!(seen.len(), 3);
        for sp in seen {
            assert_eq!(sp % 16, 0, "sp {sp:#x} is not 16-byte aligned");
            assert!(bounds.contains(sp as usize, 0), "sp {sp:#x} is outside the coroutine stack");
        }
    }

    /// The frame-record chain of a suspended coroutine, from the record
    /// `bl_co_switch` opened: each (frame pointer, return address) pair up
    /// to the zero record the trampoline opened.
    #[cfg(not(windows))]
    fn chain_of(co: Value) -> Vec<(usize, usize)> {
        let co = coroutine_of(co);
        let bounds = co.stack.as_ref().unwrap().bounds();
        let mut record = suspended_rbp(co.saved_sp);
        let mut chain = Vec::new();
        loop {
            // AArch64 keeps every record 16-byte aligned; x86-64's trampoline
            // record sits at 8 mod 16 (its call is aligned by its own sub).
            let alignment = if cfg!(target_arch = "aarch64") { 16 } else { 8 };
            assert_eq!(record % alignment, 0, "frame record {record:#x} is misaligned");
            assert!(bounds.contains(record, 16), "frame record {record:#x} is outside the coroutine stack");
            let (fp, ra) = unsafe { (*(record as *const usize), *((record + 8) as *const usize)) };
            chain.push((fp, ra));
            if fp == 0 {
                return chain;
            }
            assert!(fp > record, "the chain does not ascend: {fp:#x} after {record:#x}");
            assert!(chain.len() < 64, "the chain does not end");
            record = fp;
        }
    }

    #[cfg(not(windows))]
    #[test]
    fn a_suspended_stacks_frame_chain_ends_in_the_trampolines_zero_record() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, counting);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        // switch -> rt_co_yield -> counting -> co_body -> trampoline.
        let chain = chain_of(co);
        assert!(chain.len() >= 3, "{chain:x?}");
        assert_eq!(*chain.last().unwrap(), (0, 0));
        // Every earlier record returns into code (a nonzero address).
        assert!(chain[..chain.len() - 1].iter().all(|&(_, ra)| ra != 0), "{chain:x?}");
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(0)), make_small(10));
    }


    // -- Windows x86-64 (WINDOWS-X86-64-MILESTONE-5.md): a coroutine's stack is
    // a fiber of its own, as Windows itself reports it while the coroutine
    // runs; its switch's record is where Windows' unwinder climbs a suspended
    // stack from; a pooled fiber starts at its top again.

    /// Windows' unwinder from a suspended coroutine's switch record up to
    /// the end of its fiber's stack: each frame's (RIP, RSP), and whether the
    /// climb ended at a zero return address inside the stack.
    #[cfg(windows)]
    fn unwound_from(co: Value) -> (Vec<(u64, u64)>, bool) {
        use crate::runtime::framewalk::windows::{unwind_one, Context};
        let co = coroutine_of(co);
        let bounds = co.stack.as_ref().unwrap().bounds();
        let mut context = Context::at(suspended_rbp(co.saved_sp));
        let mut frames = Vec::new();
        for _ in 0..64 {
            let (pc, sp) = (context.0.Rip, context.0.Rsp);
            if pc == 0 {
                return (frames, bounds.contains(sp as usize, 8));
            }
            assert!(bounds.contains(sp as usize, 8), "rsp {sp:#x} outside the coroutine's stack after {frames:x?}");
            frames.push((pc, sp));
            // SAFETY: a frame of a suspended stack of this thread, exact in
            // RIP, RSP and RBP (bl_co_switch's record), then as unwound.
            unsafe { unwind_one(&mut context, None) };
            assert!(context.0.Rsp > sp, "the climb does not ascend: {:#x} after {sp:#x}", context.0.Rsp);
        }
        (frames, false)
    }

    #[cfg(windows)]
    #[test]
    fn a_suspended_stack_unwinds_to_its_fibers_start() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, counting);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        // bl_co_switch -> rt_co_yield -> counting -> co_body -> the fiber's
        // entry -> Windows' fiber start, ended by a zero return address.
        let (frames, ended) = unwound_from(co);
        assert!(ended, "{frames:x?}");
        assert!(frames.len() >= 5, "{frames:x?}");
        let entry = windows_entry_range();
        assert!(frames.iter().any(|&(pc, _)| entry.contains(&(pc as usize))), "no frame in the fiber's entry: {frames:x?}");
        assert_eq!(rt_co_resume(&mut *vm, co, make_small(0)), make_small(10));
    }

    /// The code of the fibers' entry stub, whose return address every
    /// coroutine body's first frame holds.
    #[cfg(windows)]
    fn windows_entry_range() -> std::ops::Range<usize> {
        unsafe extern "C" {
            fn bl_co_fiber_entry(slot: *mut std::ffi::c_void);
        }
        let start = bl_co_fiber_entry as *const () as usize;
        start..start + 32
    }

    #[cfg(windows)]
    thread_local! {
        static SEEN: std::cell::RefCell<Vec<(crate::runtime::native_stack::NativeStack, u32, usize, bool)>> = const { std::cell::RefCell::new(Vec::new()) };
    }

    /// Records the stack Windows reports while the body runs, its stack
    /// guarantee, its stack pointer and whether the thread is a fiber, then
    /// yields and records them again.
    #[cfg(windows)]
    extern "C" fn reporting(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        use crate::runtime::platform::windows::{current_stack, stack_guarantee};
        let sp: usize;
        // SAFETY: reads a register.
        unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
        // SAFETY: a query of the calling thread.
        let fiber = unsafe { windows_sys::Win32::System::Threading::IsThreadAFiber() } != 0;
        SEEN.with(|seen| seen.borrow_mut().push((current_stack().unwrap(), stack_guarantee(), sp, fiber)));
        rt_co_yield(p, make_small(1));
        SEEN.with(|seen| seen.borrow_mut().push((current_stack().unwrap(), stack_guarantee(), sp, fiber)));
        make_small(2)
    }

    #[cfg(windows)]
    #[test]
    fn a_coroutine_runs_on_a_fiber_of_its_own_with_the_guards_guarantee() {
        use crate::runtime::platform::windows::{confirmed_guard_page, current_stack, stack_guarantee, GUARANTEE};
        std::thread::spawn(|| {
            let thread = current_stack().unwrap();
            let thread_guarantee = stack_guarantee();
            let mut vm = new_vm();
            let t = thunk(&mut vm, reporting);
            vm.temp_roots.push(t);
            let co = rt_co_create(&mut *vm, t);
            vm.temp_roots.push(co);
            SEEN.with(|seen| seen.borrow_mut().clear());
            assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
            let bounds = coroutine_of(co).stack.as_ref().unwrap().bounds();
            // The thread's own stack and guarantee, as before.
            let back = current_stack().unwrap();
            assert_eq!((back.low_bound, back.high_bound), (thread.low_bound, thread.high_bound));
            assert_eq!(stack_guarantee(), thread_guarantee);
            assert!(thread_converted(), "the runtime made the thread a fiber");
            assert_eq!(rt_co_resume0(&mut *vm, co), make_small(2));
            let seen = SEEN.with(|seen| seen.borrow().clone());
            assert_eq!(seen.len(), 2);
            for (stack, guarantee, sp, fiber) in seen {
                // What Windows reports while the body runs is the coroutine's
                // own stack: its bounds, a guard page, its guarantee.
                assert_eq!((stack.low_bound, stack.high_bound), (bounds.low_bound, bounds.high_bound));
                assert!(stack.contains(sp, 8), "rsp {sp:#x} outside {:#x}..{:#x}", stack.low_bound, stack.high_bound);
                assert!(stack.high_bound - stack.low_bound >= stack_bytes(), "a reservation smaller than the usable size");
                assert!(guarantee >= GUARANTEE, "the fiber's guarantee is {guarantee}");
                assert!(fiber);
                let _ = confirmed_guard_page;
            }
            assert!(bounds.high_bound <= thread.low_bound || bounds.low_bound >= thread.high_bound, "the fiber's stack overlaps the thread's");
        })
        .join()
        .unwrap();
    }

    #[cfg(windows)]
    fn read_mxcsr() -> u32 {
        let mut value = 0u32;
        // SAFETY: stores MXCSR into a local.
        unsafe { std::arch::asm!("stmxcsr [{}]", in(reg) &mut value, options(nostack, preserves_flags)) };
        value
    }

    #[cfg(windows)]
    fn write_mxcsr(value: u32) {
        // SAFETY: loads a valid MXCSR (the default's masks); tests restore it.
        unsafe { std::arch::asm!("ldmxcsr [{}]", in(reg) &value, options(nostack, preserves_flags)) };
    }

    /// MXCSR travels with a context (FIBER_FLAG_FLOAT_SWITCH): the body
    /// rounds toward zero and yields; the resumer keeps its own mode, and
    /// the body its own again.
    #[cfg(windows)]
    extern "C" fn mxcsr_body(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let before = read_mxcsr();
        write_mxcsr(before | 0x6000);
        rt_co_yield(p, make_small(1));
        let kept = read_mxcsr() == before | 0x6000;
        write_mxcsr(before);
        make_small(if kept && before == 0x1F80 { 1 } else { 0 })
    }

    #[cfg(windows)]
    #[test]
    fn mxcsr_is_part_of_the_context() {
        let mut vm = new_vm();
        let t = thunk(&mut vm, mxcsr_body);
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        assert_eq!(read_mxcsr(), 0x1F80);
        assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
        assert_eq!(read_mxcsr(), 0x1F80, "the coroutine's rounding mode leaked into its resumer");
        assert_eq!(rt_co_resume0(&mut *vm, co), make_small(1));
        assert_eq!(read_mxcsr(), 0x1F80);
    }

    #[cfg(windows)]
    thread_local! {
        static TOPS: std::cell::RefCell<Vec<usize>> = const { std::cell::RefCell::new(Vec::new()) };
    }

    /// Records its stack pointer, then yields forever.
    #[cfg(windows)]
    extern "C" fn top_recording(p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        let sp: usize;
        // SAFETY: reads a register.
        unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
        TOPS.with(|tops| tops.borrow_mut().push(sp));
        loop {
            rt_co_yield(p, UNIT);
        }
    }

    /// A pooled fiber -- its coroutine completed, released while suspended,
    /// or swept -- starts its next coroutine at its top again: the same
    /// stack, the same stack pointer at the body.
    #[cfg(windows)]
    #[test]
    fn a_pooled_fiber_starts_again_at_its_top() {
        std::thread::spawn(|| {
            let mut vm = new_vm();
            TOPS.with(|tops| tops.borrow_mut().clear());
            let mut stacks = Vec::new();
            for round in 0..4 {
                let t = thunk(&mut vm, top_recording);
                vm.temp_roots.push(t);
                let co = rt_co_create(&mut *vm, t);
                vm.temp_roots.push(co);
                assert_eq!(rt_co_start(&mut *vm, co), UNIT);
                stacks.push(coroutine_of(co).stack.as_ref().unwrap().bounds().low_bound);
                match round {
                    // Released while suspended, parked mid-body.
                    0 | 1 => {
                        rt_co_release(&mut *vm, co);
                    }
                    // Abandoned: swept by the collector.
                    _ => {
                        vm.temp_roots.clear();
                        vm.collect_for_test(GcReason::Explicit);
                    }
                }
            }
            let tops = TOPS.with(|tops| tops.borrow().clone());
            assert_eq!(tops.len(), 4);
            assert!(tops.iter().all(|&sp| sp == tops[0]), "{tops:x?}");
            assert!(stacks.iter().all(|&low| low == stacks[0]), "one fiber for every round: {stacks:x?}");
        })
        .join()
        .unwrap();
    }

    #[cfg(windows)]
    #[inline(never)]
    fn descend(depth: usize) -> usize {
        let frame = std::hint::black_box([depth as u8; 1024]);
        if depth == 0 { frame[0] as usize } else { descend(depth - 1) + frame[1] as usize }
    }

    /// A body 64 KiB of frames deep, which grows its fiber's stack.
    #[cfg(windows)]
    extern "C" fn deep_body(_p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        std::hint::black_box(descend(64));
        UNIT
    }

    /// What a fiber commits (WINDOWS-X86-64-MILESTONE-5.md, "Performance"):
    /// fresh, after its setup, its first page and the guard region with the
    /// setup's guarantee, none of the rest of its reservation; pooled after a
    /// coroutine ran 64 KiB deep on it, what that coroutine grew it to.
    #[cfg(windows)]
    #[test]
    fn a_fresh_fiber_commits_its_guarantee_and_a_page() {
        use crate::runtime::platform::windows::{committed_bytes, GUARANTEE};
        std::thread::spawn(|| {
            let (stack, pooled) = CoStack::new().unwrap();
            assert!(!pooled, "a fresh thread's pool is empty");
            let bounds = stack.bounds();
            let fresh = committed_bytes(&bounds);
            drop(stack);
            let mut vm = new_vm();
            let t = thunk(&mut vm, deep_body);
            vm.temp_roots.push(t);
            let co = rt_co_create(&mut *vm, t);
            vm.temp_roots.push(co);
            assert_eq!(rt_co_start(&mut *vm, co), UNIT);
            let (stack, pooled) = CoStack::new().unwrap();
            assert!(pooled && stack.bounds().low_bound == bounds.low_bound, "the one fiber, pooled twice");
            let grown = committed_bytes(&stack.bounds());
            println!(
                "a_fresh_fiber_commits_its_guarantee_and_a_page: of a {} KiB reservation, a fresh fiber commits {} KiB; after a coroutine 64 KiB deep, {} KiB",
                (bounds.high_bound - bounds.low_bound) >> 10,
                fresh >> 10,
                grown >> 10
            );
            assert!(fresh >= GUARANTEE as usize, "a fresh fiber commits {fresh} bytes, less than its guarantee");
            assert!(fresh <= GUARANTEE as usize + (32 << 10), "a fresh fiber commits {fresh} bytes");
            assert!(grown >= fresh + (64 << 10), "a fiber that ran 64 KiB deep commits {grown} bytes");
        })
        .join()
        .unwrap();
    }

    /// A thread something else made a fiber stays one, its fiber unchanged:
    /// the runtime switches from it and back, converting nothing.
    #[cfg(windows)]
    #[test]
    fn a_thread_made_a_fiber_by_its_host_stays_the_hosts() {
        use windows_sys::Win32::System::Threading::{ConvertFiberToThread, ConvertThreadToFiberEx, IsThreadAFiber};
        std::thread::spawn(|| {
            // SAFETY: converts this thread, then converts it back at the end.
            let host = unsafe { ConvertThreadToFiberEx(std::ptr::null(), 0) } as usize;
            assert_ne!(host, 0);
            let mut vm = new_vm();
            let t = thunk(&mut vm, counting);
            vm.temp_roots.push(t);
            let co = rt_co_create(&mut *vm, t);
            vm.temp_roots.push(co);
            assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
            assert_eq!(rt_co_resume(&mut *vm, co, make_small(5)), make_small(15));
            assert_eq!(rt_co_resume(&mut *vm, co, make_small(21)), make_small(42));
            let current: usize;
            // SAFETY: NT_TIB's FiberData.
            unsafe { std::arch::asm!("mov {}, qword ptr gs:[0x20]", out(reg) current, options(nostack, preserves_flags, readonly)) };
            assert_eq!(current, host, "the runtime switched back to another fiber than the host's");
            assert!(!thread_converted());
            // SAFETY: the host's own conversion, undone by the host.
            unsafe {
                assert_ne!(IsThreadAFiber(), 0);
                assert_ne!(ConvertFiberToThread(), 0);
            }
        })
        .join()
        .unwrap();
    }

    #[test]
    fn repeated_lifecycles_map_one_stack_and_reuse_it() {
        let mut vm = new_vm();
        let before = vm.metrics.coroutines.stacks_mapped;
        let reused_before = vm.metrics.coroutines.stacks_reused;
        let pooled = pooled_stacks();
        for i in 0..300 {
            let t = thunk(&mut vm, counting);
            vm.temp_roots.push(t);
            let co = rt_co_create(&mut *vm, t);
            vm.temp_roots.push(co);
            assert_eq!(rt_co_start(&mut *vm, co), make_small(1));
            match i % 3 {
                // Completed.
                0 => {
                    assert_eq!(rt_co_resume(&mut *vm, co, make_small(5)), make_small(15));
                    assert_eq!(rt_co_resume(&mut *vm, co, make_small(21)), make_small(42));
                    assert!(coroutine_of(co).stack.is_none());
                }
                // Released while suspended.
                1 => {
                    rt_co_release(&mut *vm, co);
                    assert!(coroutine_of(co).stack.is_none());
                }
                // Abandoned: left for the collector.
                _ => {}
            }
            vm.temp_roots.clear();
            if i % 50 == 49 {
                vm.collect_for_test(GcReason::Explicit);
            }
        }
        vm.collect_for_test(GcReason::Explicit);
        let mapped = vm.metrics.coroutines.stacks_mapped - before;
        let reused = vm.metrics.coroutines.stacks_reused - reused_before;
        assert_eq!(mapped + reused, 300);
        // Stacks go back to the pool as their coroutines end, so the number
        // of mappings stays far below the number of starts (abandoned ones
        // wait for a collection, at most 50 at a time here).
        assert!(mapped <= 52, "{mapped} stacks mapped for 300 sequential coroutines");
        assert!(pooled_stacks() >= pooled);
        assert!(pooled_stacks() <= POOL_LIMIT);
    }
}

/// The fallback root plan runs no native coroutine (STACK_SWITCHING): its
/// shadow stack cannot hold a suspended coroutine's roots, and it is never
/// made coroutine-aware (WINDOWS-X86-64-MILESTONE-3.md, -5.md). A start is
/// NATIVE UNSUPPORTED, before any stack is made.
#[cfg(all(test, feature = "fallback-roots"))]
mod fallback_tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    extern "C" fn never(_p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
        panic!("a coroutine body ran on the fallback root plan")
    }

    #[test]
    fn the_fallback_plan_refuses_native_coroutines() {
        assert!(!STACK_SWITCHING);
        let mut vm = Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }), AllocMode::Summary);
        let caps: Box<[Value]> = Vec::new().into_boxed_slice();
        let t = vm.alloc(
            ClosureObj { hdr: Header::new(KIND_CLOSURE, false), func: 0, arity: 0, code: never as *const () as usize, ncaps: 0, caps: Box::into_raw(caps) as *mut Value },
            0,
        );
        vm.temp_roots.push(t);
        let co = rt_co_create(&mut *vm, t);
        vm.temp_roots.push(co);
        let before = pooled_stacks();
        assert_eq!(rt_co_start(&mut *vm, co), NO_VALUE);
        assert_eq!(vm.error.take().map(|e| e.error_code()), Some(vec!["NATIVE", "UNSUPPORTED", "value"]));
        assert!(coroutine_of(co).stack.is_none());
        assert_eq!(pooled_stacks(), before);
    }
}
