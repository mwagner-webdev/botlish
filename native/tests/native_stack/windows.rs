//! The Windows half of the native stack checks (WINDOWS-X86-64-MILESTONE-4.md):
//! each kind of thread Botlish runs on, the guard on it (runtime/platform/
//! windows.rs), its stack exhausted for real -- by small frames, by 64 KiB
//! frames (Rust's __chkstk probes), by an inline probe loop like
//! Cranelift's -- in each reporting mode, and the faults that are not an
//! overflow of the guarded stack, each of which must end exactly as it does
//! without the guard. Every check that faults runs in a child process.
//!
//! And coroutine stacks (WINDOWS-X86-64-MILESTONE-5.md: a coroutine's stack is
//! a fiber, runtime/coroutine/windows.rs): each one exhausted -- at its start,
//! after yields, at the bottom of main -> a -> b -> c, by 64 KiB frames and by
//! the probe loop -- in the driver's and an executable's mode; the stack the
//! guard reads at every point of a nested lifecycle; the faults on and around
//! coroutine stacks that are not an overflow; and a switch made at every
//! offset near the end of the stack it leaves.
use botlish_native::runtime::coroutine::{rt_co_create, rt_co_release, rt_co_resume, rt_co_start, rt_co_yield, CoroutineObj};
use botlish_native::runtime::metrics::AllocMode;
use botlish_native::runtime::native_stack::NativeStack;
use botlish_native::runtime::ops::GenericEntry;
use botlish_native::runtime::platform::{self, OverflowGuard};
use botlish_native::runtime::platform::windows::{confirmed_guard_page, stack_guarantee, GUARANTEE};
use botlish_native::runtime::value::*;
use botlish_native::runtime::vm::{ProgramInfo, Vm};
use std::process::Command;
use std::rc::Rc;
use std::sync::atomic::{AtomicUsize, Ordering};
use windows_sys::Win32::Foundation::{CloseHandle, EXCEPTION_STACK_OVERFLOW, GetLastError};
use windows_sys::Win32::System::Diagnostics::Debug::RaiseException;
use windows_sys::Win32::System::Threading::{
    CreateThread, INFINITE, STACK_SIZE_PARAM_IS_A_RESERVATION, WaitForSingleObject,
};

const OVERFLOW_LINE: &str = "error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}";
/// STATUS_STACK_OVERFLOW and STATUS_ACCESS_VIOLATION as exit codes.
const STACK_OVERFLOW: u32 = 0xC000_00FD;
const ACCESS_VIOLATION: u32 = 0xC000_0005;

#[inline(always)]
fn current_sp() -> usize {
    let sp: usize;
    // SAFETY: reads a register.
    unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
    sp
}

// ---------------------------------------------------------------------------
// Threads

/// Runs F on a thread made by CreateThread itself with a reservation of
/// STACK bytes: no Rust runtime set its stack guarantee.
fn on_raw_thread<T: Send + 'static>(stack: usize, f: impl FnOnce() -> T + Send + 'static) -> T {
    unsafe extern "system" fn start(arg: *mut core::ffi::c_void) -> u32 {
        // SAFETY: ARG is the Box<Box<dyn FnOnce()>> made below, used once.
        let f = unsafe { Box::from_raw(arg as *mut Box<dyn FnOnce()>) };
        f();
        0
    }
    let result = std::sync::Arc::new(std::sync::Mutex::new(None));
    let out = result.clone();
    let job: Box<dyn FnOnce()> = Box::new(move || {
        *out.lock().unwrap() = Some(f());
    });
    let arg = Box::into_raw(Box::new(job));
    // SAFETY: the thread runs START once and is waited for before RESULT is
    // read.
    unsafe {
        let thread = CreateThread(std::ptr::null(), stack, Some(start), arg.cast(), STACK_SIZE_PARAM_IS_A_RESERVATION, std::ptr::null_mut());
        assert!(!thread.is_null(), "CreateThread failed: {}", GetLastError());
        WaitForSingleObject(thread, INFINITE);
        CloseHandle(thread);
    }
    result.lock().unwrap().take().expect("the thread ran")
}

/// The threads every check runs on: the process's main thread, std's
/// default thread, a 1 MiB and a 1 GiB std thread (the driver's and a
/// standalone executable's worker), and a 1 MiB thread of CreateThread's.
const THREADS: &[&str] = &["main", "std-default", "std-1MiB", "std-1GiB", "raw-1MiB"];

fn on_thread<T: Send + 'static>(name: &str, f: impl FnOnce() -> T + Send + 'static) -> T {
    match name {
        "main" => f(),
        "std-default" => std::thread::spawn(f).join().unwrap(),
        "std-1MiB" => std::thread::Builder::new().stack_size(1 << 20).spawn(f).unwrap().join().unwrap(),
        "std-1GiB" => std::thread::Builder::new().stack_size(1 << 30).spawn(f).unwrap().join().unwrap(),
        "raw-1MiB" => on_raw_thread(1 << 20, f),
        other => panic!("no thread {other}"),
    }
}

// ---------------------------------------------------------------------------
// Ways to exhaust a stack

/// Recurses with a 256-byte frame until the stack ends.
#[inline(never)]
fn exhaust(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust(depth + 1).wrapping_add(frame[depth % 256] as usize)
}

/// The same to DEPTH levels only.
#[inline(never)]
fn recurse(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == 0 {
        return 0;
    }
    recurse(depth - 1).wrapping_add(frame[depth % 256] as usize)
}

/// The same with 64 KiB frames, which Rust probes a page at a time
/// (__chkstk) before using them.
#[inline(never)]
fn exhaust_wide(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 64 * 1024]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust_wide(depth + 1).wrapping_add(frame[depth % 1024] as usize)
}

/// Cranelift's inline probe loop's access pattern: the stack pointer moved
/// down a page at a time, each page touched at its lowest address, until the
/// stack ends.
fn probe_loop() -> ! {
    // SAFETY: deliberately runs off the end of the stack.
    unsafe { std::arch::asm!("2:", "sub rsp, 4096", "mov qword ptr [rsp], 0", "jmp 2b", options(noreturn)) }
}

fn touch(address: usize) {
    // SAFETY: deliberately not safe: a fault is the point.
    let byte = unsafe { std::ptr::read_volatile(address as *const u8) };
    std::hint::black_box(byte);
}

// ---------------------------------------------------------------------------
// Child scenarios (each runs alone, in its own process)

/// One scenario, named by `BOTLISH_STACK_TEST_CHILD`:
///
///   guard:THREAD:MODE   installs the guard on THREAD (`driver`,
///                       `executable`, `result-file`; `wide`: driver, 64 KiB
///                       frames; `probe-loop`: driver, Cranelift's probe
///                       pattern; `finite`: driver, a recursion that fits;
///                       `dropped`: installs and drops one, then exhausts with
///                       none; `reinstalled`: installs a second after dropping
///                       one; `unguarded`: never installs one) and exhausts
///                       the stack; prints `returned` if it ever returns
///   fault:KIND          a fault that is not the guarded stack's overflow, the
///                       guard installed on a 1 MiB std thread: `null`,
///                       `reserved` (the guarded stack's uncommitted
///                       reservation, which only a skipped guard page
///                       reaches), `guard-page` (the system's guard page: the
///                       stack grows), `raised` (STATUS_STACK_OVERFLOW by
///                       RaiseException), `raised-in-stack` (the same on
///                       the guarded thread, its record naming its stack),
///                       `other-thread` (another thread's
///                       stack exhausted), `other-thread-raised` (another
///                       thread raising STATUS_STACK_OVERFLOW at an address
///                       of the guarded stack)
///   fault:KIND:unguarded  the same without the guard
fn child(scenario: &str) -> ! {
    let parts: Vec<&str> = scenario.split(':').collect();
    match parts.as_slice() {
        ["guard", thread, mode] => {
            let mode = mode.to_string();
            on_thread(thread, move || {
                let stack = NativeStack::current().expect("the thread's stack");
                if mode == "result-file" {
                    let path = std::env::var("BOTLISH_STACK_TEST_RESULT").expect("a result file");
                    let file = std::fs::File::create(path).expect("the result file");
                    platform::set_result_file(&file);
                    std::mem::forget(file);
                }
                if mode == "unguarded" {
                    println!("returned {}", exhaust(0));
                    return;
                }
                if mode == "dropped" || mode == "reinstalled" {
                    drop(OverflowGuard::install(&stack).expect("the first guard installs"));
                    if mode == "dropped" {
                        println!("returned {}", exhaust(0));
                        return;
                    }
                }
                let installed = if mode == "executable" { OverflowGuard::install_executable(&stack) } else { OverflowGuard::install(&stack) };
                match installed {
                    Ok(_guard) => {
                        let n = match mode.as_str() {
                            "wide" => exhaust_wide(0),
                            "probe-loop" => probe_loop(),
                            "finite" => recurse(2000),
                            _ => exhaust(0),
                        };
                        println!("returned {n}");
                    }
                    Err(error) => println!("refused: {error}"),
                }
            });
        }
        ["fault", kind] | ["fault", kind, _] => {
            let kind = kind.to_string();
            let guarded = parts.len() == 2;
            on_thread("std-1MiB", move || {
                let stack = NativeStack::current().expect("the thread's stack");
                let _guard = guarded.then(|| OverflowGuard::install(&stack).expect("the guard installs"));
                match kind.as_str() {
                    "null" => touch(8),
                    "reserved" => touch(stack.low_bound + (64 << 10)),
                    "guard-page" => {
                        // The lowest committed page's neighbour: the system's
                        // guard page, which commits and moves down.
                        let mut address = current_sp() & !0xfff;
                        while address > stack.low_bound && touch_is_committed(address - 4096) {
                            address -= 4096;
                        }
                        touch(address - 8);
                    }
                    // SAFETY: deliberately raises the code with no record.
                    "raised" => unsafe { RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 0, std::ptr::null()) },
                    "other-thread" => {
                        std::thread::Builder::new().stack_size(1 << 20).spawn(|| exhaust(0)).unwrap().join().ok();
                    }
                    // STATUS_STACK_OVERFLOW raised by software on the
                    // guarded thread itself, its record naming an address of
                    // its own stack: exactly a real exhaustion's record but
                    // for EXCEPTION_SOFTWARE_ORIGINATE.
                    "raised-in-stack" => {
                        let arguments = [1usize, stack.low_bound + 4096];
                        // SAFETY: deliberately raises the code.
                        unsafe { RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 2, arguments.as_ptr()) };
                    }
                    // STATUS_STACK_OVERFLOW raised by another thread, its
                    // record naming an address of the guarded stack.
                    "other-thread-raised" => {
                        let address = stack.low_bound + 4096;
                        std::thread::spawn(move || {
                            let arguments = [1usize, address];
                            // SAFETY: deliberately raises the code.
                            unsafe { RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 2, arguments.as_ptr()) };
                        }).join().ok();
                    }
                    other => panic!("no fault {other}"),
                }
                println!("survived");
            });
        }
        _ => coroutine_child(&parts),
    }
    std::process::exit(0)
}

// ---------------------------------------------------------------------------
// Coroutine stacks

fn new_vm() -> Box<Vm> {
    Vm::new(Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
        AllocMode::Summary)
}

/// A zero-argument Block whose code is the Rust function CODE (the generic
/// entry ABI), standing in for a compiled coroutine body.
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

/// A coroutine of BODY, rooted for the rest of the run.
fn coroutine(p: *mut Vm, body: GenericEntry) -> Value {
    // SAFETY: P is the Vm of this thread's run.
    unsafe {
        let block = thunk(&mut *p, body);
        (*p).temp_roots.push(block);
        let handle = rt_co_create(p, block);
        (*p).temp_roots.push(handle);
        handle
    }
}

/// The bounds of the coroutine running now on P's thread.
fn running_bounds(p: *mut Vm) -> NativeStack {
    // SAFETY: called from a coroutine body, so co_current is that coroutine.
    unsafe { (*(*p).co_current).stack.as_ref().expect("a running coroutine has a stack").bounds() }
}

/// What one child scenario shares with the coroutine bodies it runs.
static VM: AtomicUsize = AtomicUsize::new(0);
static HANDLE: AtomicUsize = AtomicUsize::new(0);
static OFFSET: AtomicUsize = AtomicUsize::new(0);
static ADDRESS: AtomicUsize = AtomicUsize::new(0);

fn vm_ptr() -> *mut Vm {
    VM.load(Ordering::Relaxed) as *mut Vm
}

/// Runs F on a std thread of STACK bytes with a Vm and the guard installed
/// in MODE (`driver`, `executable`; `none`: no guard), as main.rs and
/// runtime/aot.rs install it.
fn guarded(mode: &str, stack_bytes: usize, f: impl FnOnce(*mut Vm, NativeStack) + Send + 'static) {
    let mode = mode.to_string();
    std::thread::Builder::new()
        .stack_size(stack_bytes)
        .spawn(move || {
            let mut vm = new_vm();
            let p: *mut Vm = &mut *vm;
            VM.store(p as usize, Ordering::Relaxed);
            let stack = NativeStack::current().expect("the thread's stack");
            let _guard = match mode.as_str() {
                "none" => None,
                "executable" => Some(OverflowGuard::install_executable(&stack).expect("the guard installs")),
                _ => Some(OverflowGuard::install(&stack).expect("the guard installs")),
            };
            f(p, stack);
        })
        .unwrap()
        .join()
        .unwrap();
}

/// Where accesses stop growing STACK: below it Windows raises
/// STATUS_STACK_OVERFLOW (WINDOWS-X86-64-MILESTONE-4.md, "Experiments": the
/// guarantee and two pages above the reservation's bottom).
fn edge(stack: &NativeStack) -> usize {
    stack.low_bound + stack_guarantee() as usize + 2 * 4096
}

extern "C" fn yield_forever(p: *mut Vm, _: Value, _: *const Value) -> Value {
    loop {
        rt_co_yield(p, UNIT);
    }
}

extern "C" fn exhaust_at_start(_: *mut Vm, _: Value, _: *const Value) -> Value {
    make_small(exhaust(0) as i64)
}

extern "C" fn exhaust_after_yield(p: *mut Vm, _: Value, _: *const Value) -> Value {
    rt_co_yield(p, make_small(1));
    rt_co_yield(p, make_small(2));
    make_small(exhaust(0) as i64)
}

extern "C" fn exhaust_wide_at_start(_: *mut Vm, _: Value, _: *const Value) -> Value {
    make_small(exhaust_wide(0) as i64)
}

extern "C" fn probe_loop_after_yield(p: *mut Vm, _: Value, _: *const Value) -> Value {
    rt_co_yield(p, make_small(1));
    probe_loop()
}

/// main -> a -> b -> c: each starts the next and yields; each resume goes on
/// down to c, which exhausts its stack on its first resume.
extern "C" fn nested_c(p: *mut Vm, _: Value, _: *const Value) -> Value {
    rt_co_yield(p, make_small(3));
    make_small(exhaust(0) as i64)
}

extern "C" fn nested_b(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let c = coroutine(p, nested_c);
    rt_co_start(p, c);
    rt_co_yield(p, make_small(2));
    rt_co_resume(p, c, UNIT)
}

extern "C" fn nested_a(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let b = coroutine(p, nested_b);
    rt_co_start(p, b);
    rt_co_yield(p, make_small(1));
    rt_co_resume(p, b, UNIT)
}

/// Reads ADDRESS while running on a coroutine stack.
extern "C" fn touch_address(_: *mut Vm, _: Value, _: *const Value) -> Value {
    touch(ADDRESS.load(Ordering::Relaxed));
    UNIT
}

/// Reads this coroutine stack's own uncommitted reservation, far below its
/// committed part: an access violation in the running stack, never its
/// exhaustion (only a frame that skipped the guard page gets there).
extern "C" fn touch_own_reservation(p: *mut Vm, _: Value, _: *const Value) -> Value {
    touch(running_bounds(p).low_bound + (64 << 10));
    UNIT
}

/// STATUS_STACK_OVERFLOW raised by software on a coroutine stack, its record
/// naming that stack: exactly a real exhaustion's record but for
/// EXCEPTION_SOFTWARE_ORIGINATE.
extern "C" fn raise_on_own_stack(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let arguments = [1usize, running_bounds(p).low_bound + 4096];
    // SAFETY: deliberately raises the code.
    unsafe { RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 2, arguments.as_ptr()) };
    UNIT
}

/// Calls F(ARG) with the stack pointer at SP (16-byte aligned, on the
/// running stack, below every live frame and at most a page below what is
/// committed) and restores it after.
///
/// # Safety
/// SP must lie in the running stack, below every live frame, within reach of
/// its guard page.
unsafe fn call_at(sp: usize, f: extern "C" fn(usize), arg: usize) {
    // SAFETY: the caller's contract; r12 is callee-saved, so it holds the
    // old stack pointer across the call (whose shadow space is the 32 bytes
    // above SP, below every live frame).
    unsafe {
        std::arch::asm!(
            "mov r12, rsp",
            "mov rsp, {sp}",
            "call {f}",
            "mov rsp, r12",
            sp = in(reg) sp,
            f = in(reg) f,
            in("rcx") arg,
            out("r12") _,
            clobber_abi("C"),
        );
    }
}

/// Recurses with 512-byte frames -- each one written, so the stack grows by
/// its guard page as it goes -- until the stack pointer is within 1 KiB of
/// TARGET, then calls F with the stack pointer at TARGET.
#[inline(never)]
fn descend_then(target: usize, f: extern "C" fn(usize)) {
    let frame = std::hint::black_box([target as u8; 512]);
    if current_sp() > target + 1024 {
        descend_then(target, f);
    } else {
        // SAFETY: TARGET is below this frame, within a page of it.
        unsafe { call_at(target & !15, f, 0) };
    }
    std::hint::black_box(&frame);
}

extern "C" fn resume_handle(_: usize) {
    rt_co_resume(vm_ptr(), HANDLE.load(Ordering::Relaxed) as Value, UNIT);
}

extern "C" fn start_handle(_: usize) {
    rt_co_start(vm_ptr(), HANDLE.load(Ordering::Relaxed) as Value);
}

extern "C" fn yield_unit(_: usize) {
    rt_co_yield(vm_ptr(), UNIT);
}

/// Resumes HANDLE from OFFSET bytes above where this coroutine's stack stops
/// growing.
extern "C" fn resume_near_edge(p: *mut Vm, _: Value, _: *const Value) -> Value {
    descend_then(edge(&running_bounds(p)) + OFFSET.load(Ordering::Relaxed), resume_handle);
    UNIT
}

/// Yields from OFFSET bytes above where this coroutine's stack stops growing.
extern "C" fn yield_near_edge(p: *mut Vm, _: Value, _: *const Value) -> Value {
    descend_then(edge(&running_bounds(p)) + OFFSET.load(Ordering::Relaxed), yield_unit);
    UNIT
}

/// The publication check: what the guard reads at each point of a nested
/// lifecycle, against the stack that runs there.
static PUBLISHED: std::sync::Mutex<Vec<String>> = std::sync::Mutex::new(Vec::new());

fn expect_published(at: &str, stack: &NativeStack) {
    let published = platform::published_stack();
    let wanted = Some((stack.low_bound, stack.high_bound));
    if published != wanted {
        PUBLISHED.lock().unwrap().push(format!("{at}: published {published:x?}, running {wanted:x?}"));
    }
    // And Windows' own account of the running stack is the same one.
    let windows = NativeStack::current().expect("the running stack");
    if (windows.low_bound, windows.high_bound) != (stack.low_bound, stack.high_bound) {
        PUBLISHED.lock().unwrap().push(format!("{at}: Windows reports [{:#x}, {:#x}), running {wanted:x?}", windows.low_bound, windows.high_bound));
    }
}

extern "C" fn publication_b(p: *mut Vm, _: Value, _: *const Value) -> Value {
    expect_published("b started", &running_bounds(p));
    rt_co_yield(p, UNIT);
    expect_published("b resumed", &running_bounds(p));
    UNIT
}

extern "C" fn publication_a(p: *mut Vm, _: Value, _: *const Value) -> Value {
    expect_published("a started", &running_bounds(p));
    let b = coroutine(p, publication_b);
    rt_co_start(p, b);
    expect_published("a after starting b", &running_bounds(p));
    rt_co_yield(p, UNIT);
    expect_published("a resumed", &running_bounds(p));
    rt_co_resume(p, b, UNIT);
    expect_published("a after b completed", &running_bounds(p));
    // A released suspended coroutine's fiber is pooled and started again.
    let c = coroutine(p, yield_forever);
    rt_co_start(p, c);
    expect_published("a after starting c", &running_bounds(p));
    UNIT
}

/// The coroutine scenarios (`coroutine_child`'s names):
///
///   co:SHAPE:MODE         a coroutine's stack exhausted -- `fresh`, `after-
///                         yields`, `nested` (main -> a -> b -> c), `wide`
///                         (64 KiB frames at its start), `probe-loop` (after
///                         a yield) -- the guard in MODE (`driver`,
///                         `executable`); prints `returned` if it ever
///                         returns
///   co-fault:KIND         a fault that is not an overflow, guard installed:
///                         `own-reservation` (a running coroutine's
///                         uncommitted reservation), `suspended-reservation`
///                         (a suspended one's, from the thread),
///                         `thread-reservation-from-coroutine` (the thread's,
///                         from a running coroutine), `raised-in-coroutine`
///                         (STATUS_STACK_OVERFLOW raised by software on a
///                         coroutine stack, naming it)
///   co-fault:KIND:unguarded  the same without the guard
///   co-sweep:DIRECTION:X  a switch made X bytes above where the stack it
///                         leaves stops growing; prints `completed`
///   co-publication        the published stack along a nested lifecycle
fn coroutine_child(parts: &[&str]) {
    match parts {
        ["co", shape, mode] => {
            let shape = shape.to_string();
            guarded(mode, 64 << 20, move |p, _| {
                let body: GenericEntry = match shape.as_str() {
                    "fresh" => exhaust_at_start,
                    "after-yields" => exhaust_after_yield,
                    "nested" => nested_a,
                    "wide" => exhaust_wide_at_start,
                    "probe-loop" => probe_loop_after_yield,
                    other => panic!("no shape {other}"),
                };
                let handle = coroutine(p, body);
                rt_co_start(p, handle);
                rt_co_resume(p, handle, UNIT);
                rt_co_resume(p, handle, UNIT);
                println!("returned");
            });
        }
        ["co-fault", kind] | ["co-fault", kind, _] => {
            let kind = kind.to_string();
            let mode = if parts.len() == 3 { "none" } else { "driver" };
            guarded(mode, 64 << 20, move |p, stack| {
                match kind.as_str() {
                    "own-reservation" => {
                        rt_co_start(p, coroutine(p, touch_own_reservation));
                    }
                    "suspended-reservation" => {
                        let handle = coroutine(p, yield_forever);
                        rt_co_start(p, handle);
                        // SAFETY: a live suspended coroutine with a stack.
                        touch(unsafe { (*(handle as *mut CoroutineObj)).stack.as_ref().unwrap().bounds().low_bound } + (64 << 10));
                    }
                    "thread-reservation-from-coroutine" => {
                        ADDRESS.store(stack.low_bound + (64 << 10), Ordering::Relaxed);
                        rt_co_start(p, coroutine(p, touch_address));
                    }
                    "raised-in-coroutine" => {
                        rt_co_start(p, coroutine(p, raise_on_own_stack));
                    }
                    other => panic!("no fault {other}"),
                }
                println!("survived");
            });
        }
        ["co-sweep", direction, offset] => {
            let direction = direction.to_string();
            let offset: usize = offset.parse().expect("an offset");
            OFFSET.store(offset, Ordering::Relaxed);
            guarded("driver", 4 << 20, move |p, stack| {
                match direction.as_str() {
                    "resume-from-thread" => {
                        let handle = coroutine(p, yield_forever);
                        rt_co_start(p, handle);
                        HANDLE.store(handle as usize, Ordering::Relaxed);
                        descend_then(edge(&stack) + offset, resume_handle);
                    }
                    "start-from-thread" => {
                        // A start on a pooled fiber: the thread is already a
                        // fiber and the pool holds one, as for every start but
                        // a thread's first.
                        let warm = coroutine(p, yield_forever);
                        rt_co_start(p, warm);
                        rt_co_release(p, warm);
                        HANDLE.store(coroutine(p, yield_forever) as usize, Ordering::Relaxed);
                        descend_then(edge(&stack) + offset, start_handle);
                    }
                    "fresh-start-from-thread" => {
                        // A thread's first start: its conversion to a fiber,
                        // CreateFiberEx and the fiber's setup, all near the
                        // edge.
                        HANDLE.store(coroutine(p, yield_forever) as usize, Ordering::Relaxed);
                        descend_then(edge(&stack) + offset, start_handle);
                    }
                    "resume-from-coroutine" => {
                        let inner = coroutine(p, yield_forever);
                        rt_co_start(p, inner);
                        HANDLE.store(inner as usize, Ordering::Relaxed);
                        rt_co_start(p, coroutine(p, resume_near_edge));
                    }
                    "yield-from-coroutine" => {
                        let handle = coroutine(p, yield_near_edge);
                        rt_co_start(p, handle);
                        rt_co_resume(p, handle, UNIT);
                    }
                    other => panic!("no direction {other}"),
                }
                println!("completed");
            });
        }
        ["co-publication"] => {
            guarded("driver", 64 << 20, |p, stack| {
                expect_published("thread", &stack);
                let a = coroutine(p, publication_a);
                rt_co_start(p, a);
                expect_published("thread after a yielded", &stack);
                rt_co_resume(p, a, UNIT);
                expect_published("thread after a completed", &stack);
                let mismatches = PUBLISHED.lock().unwrap();
                if mismatches.is_empty() {
                    println!("publication ok");
                } else {
                    println!("{}", mismatches.join("; "));
                }
            });
        }
        _ => {
            eprintln!("no child scenario {}", parts.join(":"));
            std::process::exit(2)
        }
    }
}

/// A coroutine's own stack exhausted: at its start, after yields, at the
/// bottom of main -> a -> b -> c, by 64 KiB frames and by the probe loop, in
/// the driver's mode; and once in an executable's.
fn coroutine_checks(report: &mut Report) {
    for shape in ["fresh", "after-yields", "nested", "wide", "probe-loop"] {
        let outcome = run_child(&format!("co:{shape}:driver"));
        report.check(&format!("coroutine {shape}"), outcome.is_overflow_line(), outcome.brief());
    }
    let outcome = run_child("co:nested:executable");
    report.check("coroutine nested executable", outcome.code == 1 && outcome.stdout.is_empty() && outcome.stderr.trim_end() == OVERFLOW_LINE,
        outcome.brief());
}

/// Faults on and around coroutine stacks that are not the running stack's
/// exhaustion, with the guard installed: never the overflow line, and each
/// ends exactly as it does without the guard.
fn coroutine_fault_checks(report: &mut Report) {
    for (kind, expected) in [("own-reservation", ACCESS_VIOLATION), ("suspended-reservation", ACCESS_VIOLATION),
        ("thread-reservation-from-coroutine", ACCESS_VIOLATION), ("raised-in-coroutine", STACK_OVERFLOW)] {
        let with = run_child(&format!("co-fault:{kind}"));
        let without = run_child(&format!("co-fault:{kind}:unguarded"));
        let same = with.code == without.code && with.stdout == without.stdout;
        report.check(&format!("coroutine fault {kind}"), !with.relabelled() && same && with.code == expected,
            format!("{}; without the guard: {}", with.brief(), without.brief()));
    }
}

/// A switch made X bytes above where the stack it leaves stops growing, for
/// X from 0 to 2 KiB in 16-byte steps: wherever the switch path (the
/// helper's frames, SwitchToFiber's own, the arriving side) meets the end of
/// the stack, the run either completes or ends in the overflow line -- never
/// a crash. Both must occur, or the sweep missed the edge. A start on a
/// pooled fiber -- the helper's frames and the pool's, more than a resume's
/// -- is swept from 0 to 4 KiB in 16-byte steps, and a thread's first start
/// -- its conversion, CreateFiberEx and the fiber's setup, which take more of
/// the stack than a switch -- from 0 to 64 KiB in 512-byte steps.
fn coroutine_sweep_checks(report: &mut Report) {
    for (direction, step, steps) in [("resume-from-thread", 16, 128), ("start-from-thread", 16, 256),
        ("fresh-start-from-thread", 512, 128), ("resume-from-coroutine", 16, 128), ("yield-from-coroutine", 16, 128)] {
        let (mut completed, mut overflowed, mut failures) = (0, 0, Vec::new());
        for offset in (0..=steps * step).step_by(step) {
            let outcome = run_child_with(&format!("co-sweep:{direction}:{offset}"), &[("BOTLISH_NATIVE_COROUTINE_STACK_BYTES", "262144")]);
            if outcome.code == 0 && outcome.stdout.trim() == "completed" {
                completed += 1;
            } else if outcome.is_overflow_line() {
                overflowed += 1;
            } else {
                failures.push(format!("{offset}: {}", outcome.brief()));
            }
        }
        report.check(&format!("coroutine sweep {direction}"), failures.is_empty() && completed > 0 && overflowed > 0,
            format!("{overflowed} overflowed, {completed} completed{}", if failures.is_empty() { String::new() } else { format!(", failed at {}", failures.join(", ")) }));
    }
}

/// The stack the guard reads -- and the one Windows reports -- is the one
/// that runs, at every point of a nested lifecycle.
fn coroutine_publication_check(report: &mut Report) {
    let outcome = run_child("co-publication");
    report.check("coroutine publication", outcome.code == 0 && outcome.stdout.trim() == "publication ok", outcome.brief());
}

/// Whether the page at ADDRESS is committed without a guard (VirtualQuery):
/// the walk down to the system's guard page.
fn touch_is_committed(address: usize) -> bool {
    use windows_sys::Win32::System::Memory::{MEM_COMMIT, MEMORY_BASIC_INFORMATION, PAGE_GUARD, VirtualQuery};
    // SAFETY: a query into a local.
    unsafe {
        let mut info: MEMORY_BASIC_INFORMATION = std::mem::zeroed();
        VirtualQuery(address as *const _, &mut info, std::mem::size_of::<MEMORY_BASIC_INFORMATION>()) != 0
            && info.State == MEM_COMMIT && info.Protect & PAGE_GUARD == 0
    }
}

struct Outcome {
    code: u32,
    stdout: String,
    stderr: String,
}

impl Outcome {
    /// Exit status 0 with exactly the overflow line on standard output: the
    /// driver's report of a stack overflow.
    fn is_overflow_line(&self) -> bool {
        self.code == 0 && self.stdout.trim_end() == OVERFLOW_LINE
    }

    fn relabelled(&self) -> bool {
        self.stdout.contains("NATIVE LIMIT STACK") || self.stderr.contains("NATIVE LIMIT STACK")
    }

    fn brief(&self) -> String {
        format!("exit {:#x} stdout {:?} stderr {:?}", self.code, self.stdout.trim(), self.stderr.trim())
    }
}

fn run_child_with(scenario: &str, environment: &[(&str, &str)]) -> Outcome {
    let output = Command::new(std::env::current_exe().expect("the test executable"))
        .env("BOTLISH_STACK_TEST_CHILD", scenario)
        .envs(environment.iter().copied())
        .output()
        .expect("the child ran");
    Outcome {
        code: output.status.code().unwrap_or(-1) as u32,
        stdout: String::from_utf8_lossy(&output.stdout).replace("\r\n", "\n"),
        stderr: String::from_utf8_lossy(&output.stderr).replace("\r\n", "\n"),
    }
}

fn run_child(scenario: &str) -> Outcome {
    run_child_with(scenario, &[])
}

// ---------------------------------------------------------------------------
// Checks

struct Report {
    failures: usize,
}

impl Report {
    fn check(&mut self, name: &str, ok: bool, detail: impl AsRef<str>) {
        println!("{} {name}: {}", if ok { "ok  " } else { "FAIL" }, detail.as_ref());
        if !ok {
            self.failures += 1;
        }
    }
}

/// Each thread's stack as the runtime reads it: the stack pointer inside it,
/// the system's guard page above its uncommitted reservation, and its stack
/// guarantee before the guard asks for its own.
fn facts(report: &mut Report) {
    for &thread in THREADS {
        let (stack, sp, guard_page, guarantee) = on_thread(thread, || {
            let stack = NativeStack::current().expect("the thread's stack");
            (stack, current_sp(), confirmed_guard_page(&stack), stack_guarantee())
        });
        report.check(&format!("facts {thread}"), stack.contains(sp, 8) && guard_page && stack.guard_low == stack.low_bound,
            format!("reservation [{:#x}, {:#x}) {} KiB, sp {} KiB below its top, guard page confirmed {guard_page}, stack guarantee {guarantee} bytes",
                stack.low_bound, stack.high_bound, (stack.high_bound - stack.low_bound) / 1024, (stack.high_bound - sp) / 1024));
    }
    let after = on_thread("raw-1MiB", || {
        let stack = NativeStack::current().expect("the thread's stack");
        let guard = OverflowGuard::install(&stack).expect("the guard installs");
        let after = stack_guarantee();
        drop(guard);
        (after, stack_guarantee())
    });
    report.check("guarantee", after.0 >= GUARANTEE && after.1 == after.0,
        format!("a thread of CreateThread's: {} bytes with the guard installed (it needs {GUARANTEE}), {} after it is dropped", after.0, after.1));
}

/// The guard on each thread: an exhausted stack ends in the overflow line
/// and exit status 0 (the driver); the executable and result-file modes;
/// 64 KiB frames, Cranelift's probe pattern; a recursion that fits; a
/// dropped guard leaves the process as it was.
fn guard_checks(report: &mut Report) {
    for &thread in THREADS {
        let outcome = run_child(&format!("guard:{thread}:driver"));
        report.check(&format!("guard {thread} driver"), outcome.is_overflow_line(), outcome.brief());
    }
    let outcome = run_child("guard:std-1MiB:executable");
    report.check("guard std-1MiB executable", outcome.code == 1 && outcome.stdout.is_empty() && outcome.stderr.trim_end() == OVERFLOW_LINE,
        outcome.brief());
    let path = std::env::temp_dir().join(format!("botlish-native-stack-{}.result", std::process::id()));
    let outcome = run_child_with("guard:std-1MiB:result-file", &[("BOTLISH_STACK_TEST_RESULT", path.to_str().unwrap())]);
    let written = std::fs::read_to_string(&path).unwrap_or_default();
    let _ = std::fs::remove_file(&path);
    report.check("guard std-1MiB result-file", outcome.code == 0 && outcome.stdout.is_empty() && written.trim_end() == OVERFLOW_LINE,
        format!("{} result file {:?}", outcome.brief(), written.trim()));
    for mode in ["wide", "probe-loop"] {
        let outcome = run_child(&format!("guard:std-1MiB:{mode}"));
        report.check(&format!("guard std-1MiB {mode}"), outcome.is_overflow_line(), outcome.brief());
    }
    let outcome = run_child("guard:std-1MiB:finite");
    report.check("guard std-1MiB finite", outcome.code == 0 && outcome.stdout.trim().starts_with("returned "), outcome.brief());
    // A dropped guard leaves the process as it was: Windows' and Rust's own
    // report of an overflow (STATUS_STACK_OVERFLOW), never the line; and a
    // second guard installs and reports.
    let dropped = run_child("guard:std-1MiB:dropped");
    let unguarded = run_child("guard:std-1MiB:unguarded");
    report.check("guard std-1MiB dropped", !dropped.relabelled() && dropped.code == STACK_OVERFLOW && dropped.code == unguarded.code,
        format!("{}; never installed: {}", dropped.brief(), unguarded.brief()));
    let outcome = run_child("guard:std-1MiB:reinstalled");
    report.check("guard std-1MiB reinstalled", outcome.is_overflow_line(), outcome.brief());
}

/// Exceptions that are not the guarded stack's exhaustion, with the guard
/// installed: never the overflow line, and each ends exactly as it does
/// without the guard.
fn fault_checks(report: &mut Report) {
    for (kind, expected) in [("null", Some(ACCESS_VIOLATION)), ("reserved", Some(ACCESS_VIOLATION)), ("guard-page", Some(0)),
        ("raised", Some(STACK_OVERFLOW)), ("raised-in-stack", Some(STACK_OVERFLOW)), ("other-thread", Some(STACK_OVERFLOW)),
        ("other-thread-raised", Some(STACK_OVERFLOW))] {
        let with = run_child(&format!("fault:{kind}"));
        let without = run_child(&format!("fault:{kind}:unguarded"));
        let same = with.code == without.code && with.stdout == without.stdout;
        report.check(&format!("fault {kind}"), !with.relabelled() && same && Some(with.code) == expected,
            format!("{}; without the guard: {}", with.brief(), without.brief()));
    }
}

pub fn main() {
    if let Ok(scenario) = std::env::var("BOTLISH_STACK_TEST_CHILD") {
        child(&scenario);
    }
    let mut report = Report { failures: 0 };
    facts(&mut report);
    guard_checks(&mut report);
    fault_checks(&mut report);
    coroutine_checks(&mut report);
    coroutine_fault_checks(&mut report);
    coroutine_publication_check(&mut report);
    coroutine_sweep_checks(&mut report);
    if report.failures > 0 {
        println!("{} native stack checks failed", report.failures);
        std::process::exit(1);
    }
    println!("every native stack check passed");
}
