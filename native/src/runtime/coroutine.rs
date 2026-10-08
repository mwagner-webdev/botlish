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
use super::native_stack::{NativeStack, StackState};
use super::ops::GenericEntry;
use super::value::*;
use super::vm::Vm;
use std::cell::RefCell;

pub const CO_FRESH: u8 = 0;
pub const CO_RUNNING: u8 = 1;
pub const CO_SUSPENDED: u8 = 2;
pub const CO_COMPLETED: u8 = 3;
pub const CO_FAILED: u8 = 4;
pub const CO_RELEASED: u8 = 5;

/// The bytes between a suspended stack's saved stack pointer and the frame
/// record `bl_co_switch` opened: the control words (8) and five callee-saved
/// registers (40).
pub const SWITCH_FRAME_OFFSET: usize = 48;

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
    /// A terminal failure: the error and its declared-error id (0: not a
    /// declared error), raised again by every later resume.
    pub failure: Option<Box<(RtError, u32)>>,
    /// The coroutine's stack, from its start until it is terminal.
    pub stack: Option<CoStack>,
    /// The coroutine's own stack pointer while it is suspended (or fresh).
    pub saved_sp: usize,
    /// The resumer's stack pointer while this coroutine runs.
    pub resumer_sp: usize,
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
    }
    values
}

// ---------------------------------------------------------------------------
// Stacks

/// One mapped coroutine stack: [base, base + guard) is PROT_NONE, the rest
/// is usable.
pub struct CoStack {
    base: usize,
    size: usize,
    guard: usize,
}

const GUARD_BYTES: usize = 64 * 1024;
const POOL_LIMIT: usize = 32;
const DEFAULT_STACK_BYTES: usize = 8 << 20;

thread_local! {
    static POOL: RefCell<Vec<CoStack>> = const { RefCell::new(Vec::new()) };
}

/// The usable size of every coroutine stack: BOTLISH_NATIVE_COROUTINE_STACK_BYTES
/// (at least 64 KiB) or 8 MiB. Address space only: pages are committed as
/// they are touched.
fn stack_bytes() -> usize {
    std::env::var("BOTLISH_NATIVE_COROUTINE_STACK_BYTES")
        .ok()
        .and_then(|text| text.parse::<usize>().ok())
        .filter(|&size| size >= 64 * 1024)
        .map(|size| (size + 4095) & !4095)
        .unwrap_or(DEFAULT_STACK_BYTES)
}

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

    fn top(&self) -> usize {
        self.base + self.size
    }

    /// A stack, and whether it came from the pool (rather than a fresh
    /// mapping).
    #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
    fn new() -> Result<(CoStack, bool), RtError> {
        let usable = stack_bytes();
        if let Some(stack) = POOL.with(|pool| {
            let mut pool = pool.borrow_mut();
            let at = pool.iter().position(|s| s.size - s.guard == usable)?;
            Some(pool.swap_remove(at))
        }) {
            return Ok((stack, true));
        }
        let size = usable + GUARD_BYTES;
        // SAFETY: a fresh private anonymous mapping; nothing else refers to it.
        unsafe {
            let base = libc::mmap(
                std::ptr::null_mut(),
                size,
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_PRIVATE | libc::MAP_ANONYMOUS | libc::MAP_NORESERVE | libc::MAP_STACK,
                -1,
                0,
            );
            if base == libc::MAP_FAILED {
                return Err(RtError::Semantic {
                    kind: "COROUTINE-STATE",
                    message: format!("cannot map a {size}-byte coroutine stack: {}", std::io::Error::last_os_error()),
                });
            }
            if libc::mprotect(base, GUARD_BYTES, libc::PROT_NONE) != 0 {
                libc::munmap(base, size);
                return Err(RtError::Bug(format!("cannot protect a coroutine stack guard: {}", std::io::Error::last_os_error())));
            }
            Ok((CoStack { base: base as usize, size, guard: GUARD_BYTES }, false))
        }
    }

    #[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
    fn new() -> Result<(CoStack, bool), RtError> {
        Err(RtError::Unsupported(
            "native coroutines need stack switching, implemented for x86-64 Linux only (COROUTINES.md)".to_string(),
        ))
    }
}

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
            #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
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

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
unsafe extern "C" {
    /// Saves the current context, storing its stack pointer through SAVE,
    /// and continues the context whose stack pointer is LOAD, which sees
    /// TRANSFER as the result of its own bl_co_switch call.
    fn bl_co_switch(save: *mut usize, load: usize, transfer: usize) -> usize;
    fn bl_co_trampoline();
}

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
unsafe fn bl_co_switch(_save: *mut usize, _load: usize, _transfer: usize) -> usize {
    unreachable!("no coroutine stack exists on this host")
}

/// The first frame of every coroutine stack (entered from bl_co_trampoline):
/// runs the body to its end, records the terminal state, and switches back
/// to the resumer of the final segment for good.
extern "C" fn co_body(p: *mut Vm, co: *mut CoroutineObj) -> ! {
    // SAFETY: CO is the running coroutine (rooted through Vm::co_current for
    // as long as it runs); P is the Vm every frame shares.
    unsafe {
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
            (*co).failure = Some(Box::new((error, id)));
            (*co).state = CO_FAILED;
        } else {
            (*co).value = result;
            (*co).state = CO_COMPLETED;
        }
        let mut finished = 0usize;
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
            saved_sp: 0,
            resumer_sp: 0,
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

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
unsafe fn prepare(_stack: &CoStack, _p: *mut Vm, _co: *mut CoroutineObj) -> usize {
    0
}

/// Runs one segment of CO (fresh or suspended, its transport slot already
/// holding the message): links it into the running chain, switches to its
/// stack, and returns its outcome when it yields or ends.
unsafe fn segment(p: *mut Vm, co: *mut CoroutineObj) -> Value {
    unsafe {
        (*co).resumer = (*p).co_current;
        (*p).co_current = co;
        (*co).state = CO_RUNNING;
        if let Some(stack) = &(*co).stack {
            (*p).publish_active_stack(Some(stack.bounds()));
        }
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
        (*co).value
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

/// The stack frame record a suspended context's walk starts at: the frame
/// bl_co_switch opened, `SWITCH_FRAME_OFFSET` above its saved stack pointer.
pub fn suspended_rbp(saved_sp: usize) -> usize {
    saved_sp + SWITCH_FRAME_OFFSET
}

#[cfg(all(test, target_arch = "x86_64", target_os = "linux"))]
mod tests {
    use super::*;
    use crate::runtime::metrics::{AllocMode, GcReason};
    use crate::runtime::vm::ProgramInfo;

    fn new_vm() -> Box<Vm> {
        Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }), AllocMode::Summary)
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
}
