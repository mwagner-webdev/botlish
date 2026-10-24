//! Native stack bounds and guards, as the host's thread library and kernel
//! report and enforce them (MACOS-AARCH64-MILESTONE-4.md).
//!
//! Not a libtest harness (`harness = false` in Cargo.toml): `main` runs on
//! the process's own main thread, which libtest never runs a test on, so the
//! main thread's facts are observed here as they are. Every check that
//! faults on purpose runs in a child process -- this same executable, re-run
//! with `BOTLISH_STACK_TEST_CHILD` naming the scenario -- and the parent
//! reads its exit status, its terminating signal and its output: nothing
//! faults in the parent.
//!
//! Prints one line per check (and the raw facts each one saw, for the CI
//! log) and exits 1 if any check failed.
//!
//! Only on the hosts with the native stack guard (runtime::native_stack's
//! `native_stack_overflow_supported`): Linux x86-64 and AArch64, macOS
//! AArch64. Elsewhere -- Windows, whose guard is a later milestone
//! (WINDOWS-X86-64-MILESTONE-1.md) -- it says so and checks nothing. The
//! checks are the module `guarded`, which spans the rest of the file (not
//! indented, to keep its history).
#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
fn main() {
    guarded::main()
}

#[cfg(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"))))]
fn main() {
    println!("native_stack: this host has no native stack guard (runtime::native_stack::native_stack_overflow_supported): nothing to check");
}

#[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
mod guarded {
use botlish_native::runtime::coroutine::{rt_co_create, rt_co_resume, rt_co_start, rt_co_yield, CoroutineObj};
use botlish_native::runtime::metrics::AllocMode;
use botlish_native::runtime::native_stack::NativeStack;
use botlish_native::runtime::ops::GenericEntry;
use botlish_native::runtime::platform::{self, OverflowGuard};
use botlish_native::runtime::value::*;
use botlish_native::runtime::vm::{ProgramInfo, Vm};
use std::process::{Command, ExitStatus};
use std::rc::Rc;
use std::sync::atomic::{AtomicUsize, Ordering};

// ---------------------------------------------------------------------------
// Raw facts, straight from the thread library (not the runtime's reading)

#[derive(Clone, Copy, Debug)]
struct Raw {
    /// The lowest usable address of the stack.
    low: usize,
    /// One past its highest address.
    high: usize,
    /// The guard size the thread library reports, where it reports one.
    reported_guard: Option<usize>,
}

#[cfg(target_os = "macos")]
fn raw_stack() -> Raw {
    // SAFETY: both read the current thread's own descriptor.
    unsafe {
        let thread = libc::pthread_self();
        let high = libc::pthread_get_stackaddr_np(thread) as usize;
        let size = libc::pthread_get_stacksize_np(thread);
        Raw { low: high - size, high, reported_guard: None }
    }
}

#[cfg(target_os = "linux")]
fn raw_stack() -> Raw {
    // SAFETY: the attribute object is initialized by pthread_getattr_np and
    // destroyed once read.
    unsafe {
        let mut attr = std::mem::MaybeUninit::<libc::pthread_attr_t>::uninit();
        assert_eq!(libc::pthread_getattr_np(libc::pthread_self(), attr.as_mut_ptr()), 0);
        let mut attr = attr.assume_init();
        let mut base: *mut libc::c_void = std::ptr::null_mut();
        let mut size = 0usize;
        let mut guard = 0usize;
        assert_eq!(libc::pthread_attr_getstack(&attr, &mut base, &mut size), 0);
        assert_eq!(libc::pthread_attr_getguardsize(&attr, &mut guard), 0);
        libc::pthread_attr_destroy(&mut attr);
        Raw { low: base as usize, high: base as usize + size, reported_guard: Some(guard) }
    }
}

fn page_size() -> usize {
    // SAFETY: no preconditions.
    unsafe { libc::sysconf(libc::_SC_PAGESIZE) as usize }
}

#[inline(always)]
fn current_sp() -> usize {
    let sp: usize;
    // SAFETY: reads a register.
    unsafe {
        #[cfg(target_arch = "x86_64")]
        std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags));
        #[cfg(target_arch = "aarch64")]
        std::arch::asm!("mov {}, sp", out(reg) sp, options(nomem, nostack, preserves_flags));
    }
    sp
}

/// The mapping containing ADDRESS: its start, its end and its protection
/// (`rwx` letters, `---` for none), or None when nothing is mapped there.
#[cfg(target_os = "macos")]
fn region(address: usize) -> Option<(usize, usize, String)> {
    #[repr(C, packed(4))]
    #[derive(Default)]
    struct BasicInfo64 {
        protection: i32,
        max_protection: i32,
        inheritance: u32,
        shared: u32,
        reserved: u32,
        offset: u64,
        behavior: i32,
        user_wired_count: u16,
    }
    const VM_REGION_BASIC_INFO_64: i32 = 9;
    unsafe extern "C" {
        static mach_task_self_: libc::mach_port_t;
        fn mach_vm_region(task: libc::mach_port_t, address: *mut u64, size: *mut u64, flavor: i32,
            info: *mut i32, count: *mut u32, object_name: *mut libc::mach_port_t) -> libc::kern_return_t;
    }
    let mut start = address as u64;
    let mut size = 0u64;
    let mut info = BasicInfo64::default();
    let mut count = (std::mem::size_of::<BasicInfo64>() / 4) as u32;
    let mut object = 0;
    // SAFETY: every out-parameter points at storage of the size COUNT says.
    let kr = unsafe {
        mach_vm_region(mach_task_self_, &mut start, &mut size, VM_REGION_BASIC_INFO_64,
            (&mut info as *mut BasicInfo64).cast(), &mut count, &mut object)
    };
    if kr != 0 || start as usize > address {
        return None;
    }
    let p = info.protection;
    let text = format!("{}{}{}", if p & 1 != 0 { "r" } else { "-" }, if p & 2 != 0 { "w" } else { "-" },
        if p & 4 != 0 { "x" } else { "-" });
    Some((start as usize, (start + size) as usize, text))
}

#[cfg(target_os = "linux")]
fn region(address: usize) -> Option<(usize, usize, String)> {
    let maps = std::fs::read_to_string("/proc/self/maps").ok()?;
    for line in maps.lines() {
        let mut fields = line.split_whitespace();
        let range = fields.next()?;
        let perms = fields.next()?;
        let (a, b) = range.split_once('-')?;
        let (a, b) = (usize::from_str_radix(a, 16).ok()?, usize::from_str_radix(b, 16).ok()?);
        if a <= address && address < b {
            return Some((a, b, perms[..3].to_string()));
        }
    }
    None
}

fn describe_region(address: usize) -> String {
    match region(address) {
        Some((start, end, prot)) => format!("{prot} [{start:#x}, {end:#x}) ({} KiB)", (end - start) / 1024),
        None => "unmapped".to_string(),
    }
}

// ---------------------------------------------------------------------------
// Threads

/// Runs F on a thread the thread library creates with STACK bytes (None: its
/// default) and GUARD bytes of guard (None: its default), as a raw pthread so
/// that the guard size can be chosen.
fn on_pthread<T: Send + 'static>(stack: Option<usize>, guard: Option<usize>, f: impl FnOnce() -> T + Send + 'static) -> T {
    extern "C" fn start(arg: *mut libc::c_void) -> *mut libc::c_void {
        // SAFETY: ARG is the Box<Box<dyn FnOnce()>> made below, used once.
        let f = unsafe { Box::from_raw(arg as *mut Box<dyn FnOnce()>) };
        f();
        std::ptr::null_mut()
    }
    let result = std::sync::Arc::new(std::sync::Mutex::new(None));
    let out = result.clone();
    let job: Box<dyn FnOnce()> = Box::new(move || {
        *out.lock().unwrap() = Some(f());
    });
    let arg = Box::into_raw(Box::new(job));
    // SAFETY: the attribute object lives until pthread_create returns; the
    // thread is joined before RESULT is read.
    unsafe {
        let mut attr = std::mem::MaybeUninit::<libc::pthread_attr_t>::uninit();
        assert_eq!(libc::pthread_attr_init(attr.as_mut_ptr()), 0);
        let mut attr = attr.assume_init();
        if let Some(stack) = stack {
            assert_eq!(libc::pthread_attr_setstacksize(&mut attr, stack), 0);
        }
        if let Some(guard) = guard {
            unsafe extern "C" {
                // POSIX; the libc crate declares it for neither host.
                fn pthread_attr_setguardsize(attr: *mut libc::pthread_attr_t, guard: libc::size_t) -> libc::c_int;
            }
            assert_eq!(pthread_attr_setguardsize(&mut attr, guard), 0);
        }
        let mut thread = std::mem::MaybeUninit::<libc::pthread_t>::uninit();
        assert_eq!(libc::pthread_create(thread.as_mut_ptr(), &attr, start, arg.cast()), 0);
        libc::pthread_attr_destroy(&mut attr);
        assert_eq!(libc::pthread_join(thread.assume_init(), std::ptr::null_mut()), 0);
    }
    result.lock().unwrap().take().expect("the thread ran")
}

/// The threads every fact is gathered on, by name: the process's main
/// thread, std's default thread, a 1 MiB and a 1 GiB std thread (the
/// driver's and a standalone executable's worker, main.rs and runtime/aot.rs),
/// and raw pthreads with a four-page guard and with none.
const THREADS: &[&str] = &["main", "std-default", "std-1MiB", "std-1GiB", "pthread-guard-4-pages", "pthread-no-guard"];

fn on_thread<T: Send + 'static>(name: &str, f: impl FnOnce() -> T + Send + 'static) -> T {
    match name {
        "main" => f(),
        "std-default" => std::thread::spawn(f).join().unwrap(),
        "std-1MiB" => std::thread::Builder::new().stack_size(1 << 20).spawn(f).unwrap().join().unwrap(),
        "std-1GiB" => std::thread::Builder::new().stack_size(1 << 30).spawn(f).unwrap().join().unwrap(),
        "pthread-guard-4-pages" => on_pthread(Some(1 << 20), Some(4 * page_size()), f),
        "pthread-no-guard" => on_pthread(Some(1 << 20), Some(0), f),
        other => panic!("no thread {other}"),
    }
}

// ---------------------------------------------------------------------------
// The runtime: its reading of a stack, its guard and its coroutines

const OVERFLOW_LINE: &str = "error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}";

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

/// Recurses with a 256-byte frame until the stack ends.
#[inline(never)]
fn exhaust(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust(depth + 1).wrapping_add(frame[depth % 256] as usize)
}

/// The same with a 64 KiB frame: a frame larger than any guard page, which
/// only stack probes keep from stepping over the guard.
#[inline(never)]
fn exhaust_wide(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 64 * 1024]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust_wide(depth + 1).wrapping_add(frame[depth % 1024] as usize)
}

/// Calls F(ARG) with the stack pointer at SP (16-byte aligned, on the
/// running stack, below the current stack pointer) and restores it after:
/// the call then has exactly SP - low_bound bytes of stack left.
///
/// # Safety
/// SP must lie in the usable part of the stack running now, below every
/// live frame.
#[cfg(target_arch = "x86_64")]
unsafe fn call_at(sp: usize, f: extern "C" fn(usize), arg: usize) {
    // SAFETY: the caller's contract; r12 is callee-saved, so it holds the
    // old stack pointer across the call.
    unsafe {
        std::arch::asm!(
            "mov r12, rsp",
            "mov rsp, {sp}",
            "call {f}",
            "mov rsp, r12",
            sp = in(reg) sp,
            f = in(reg) f,
            in("rdi") arg,
            out("r12") _,
            clobber_abi("C"),
        );
    }
}

#[cfg(target_arch = "aarch64")]
unsafe fn call_at(sp: usize, f: extern "C" fn(usize), arg: usize) {
    // SAFETY: as above; x20 is callee-saved.
    unsafe {
        std::arch::asm!(
            "mov x20, sp",
            "mov sp, {sp}",
            "blr {f}",
            "mov sp, x20",
            sp = in(reg) sp,
            f = in(reg) f,
            in("x0") arg,
            out("x20") _,
            clobber_abi("C"),
        );
    }
}

/// What one child scenario shares with the coroutine bodies it runs (each
/// child runs one scenario: plain statics).
static VM: AtomicUsize = AtomicUsize::new(0);
static HANDLE: AtomicUsize = AtomicUsize::new(0);
static OFFSET: AtomicUsize = AtomicUsize::new(0);
static ADDRESS: AtomicUsize = AtomicUsize::new(0);

fn vm_ptr() -> *mut Vm {
    VM.load(Ordering::Relaxed) as *mut Vm
}

/// Runs F on a 64 MiB thread with a Vm and the guard installed in MODE
/// (`driver`: the line on the result descriptor, exit 0; `executable`: on
/// standard error, exit 1), as main.rs and runtime/aot.rs install it; `none`
/// installs no guard.
fn guarded(mode: &str, f: impl FnOnce(*mut Vm, NativeStack) + Send + 'static) {
    let mode = mode.to_string();
    std::thread::Builder::new()
        .stack_size(64 << 20)
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

/// Reads the byte at ADDRESS (which may fault: what the parent observes).
fn touch(address: usize) {
    // SAFETY: deliberately not safe: a fault is the point.
    let byte = unsafe { std::ptr::read_volatile(address as *const u8) };
    std::hint::black_box(byte);
}

// Coroutine bodies (each a Block's generic entry).

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

/// Makes the page 256 KiB above this coroutine stack's low end (far below
/// the body's own frames) inaccessible, and reads it: a fault inside the
/// running stack's usable range, which is not its guard.
extern "C" fn touch_inside_own_stack(p: *mut Vm, _: Value, _: *const Value) -> Value {
    touch(protected_page(running_bounds(p).low_bound + (256 << 10)));
    UNIT
}

/// Starts a sibling coroutine (it stays suspended, its stack mapped after
/// this one's), then reads the sibling's guard from this running one.
extern "C" fn touch_sibling_guard(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let sibling = coroutine(p, yield_forever);
    rt_co_start(p, sibling);
    // SAFETY: SIBLING is a live suspended coroutine with a stack.
    touch(unsafe { (*(sibling as *mut CoroutineObj)).stack.as_ref().unwrap().bounds().guard_low });
    UNIT
}

/// The page containing ADDRESS rounded up to a page boundary, made
/// PROT_NONE; returns an address inside it.
fn protected_page(address: usize) -> usize {
    let page = page_size();
    let start = (address + page - 1) & !(page - 1);
    // SAFETY: a page of the running stack far below every live frame.
    assert_eq!(unsafe { libc::mprotect(start as *mut libc::c_void, page, libc::PROT_NONE) }, 0);
    start + 64
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

/// Resumes HANDLE from OFFSET bytes above this coroutine's stack's low end.
extern "C" fn resume_near_edge(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let low = running_bounds(p).low_bound;
    // SAFETY: OFFSET is far below this body's own frame on a fresh 8 MiB stack.
    unsafe { call_at(low + OFFSET.load(Ordering::Relaxed), resume_handle, 0) };
    UNIT
}

/// Yields from OFFSET bytes above this coroutine's stack's low end.
extern "C" fn yield_near_edge(p: *mut Vm, _: Value, _: *const Value) -> Value {
    let low = running_bounds(p).low_bound;
    // SAFETY: as in resume_near_edge.
    unsafe { call_at(low + OFFSET.load(Ordering::Relaxed), yield_unit, 0) };
    UNIT
}

/// The publication check: what the guard reads at each point of a nested
/// lifecycle, against the stack that runs there.
static PUBLISHED: std::sync::Mutex<Vec<String>> = std::sync::Mutex::new(Vec::new());

fn expect_published(at: &str, stack: &NativeStack) {
    let published = platform::published_stack();
    let wanted = Some((stack.guard_low, stack.low_bound));
    if published != wanted {
        PUBLISHED.lock().unwrap().push(format!("{at}: published {published:x?}, running {wanted:x?}"));
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
    UNIT
}

// ---------------------------------------------------------------------------
// Child scenarios (each runs alone, in its own process)

/// One scenario, named by `BOTLISH_STACK_TEST_CHILD`:
///
///   touch:THREAD:WHERE    no guard: reads a byte on THREAD -- the lowest
///                         the thread library reports (`reported-low`), the
///                         runtime's lowest usable one (`usable-low`), the
///                         top or the bottom of the runtime's confirmed guard
///                         (`guard-top`, `guard-bottom`) -- and prints
///                         `survived`
///   guard:THREAD:MODE     installs the guard on THREAD (`driver`,
///                         `executable`, `result-file`; `wide`: driver, with
///                         64 KiB frames; `dropped`: installs and drops one
///                         first, then exhausts with none; `reinstalled`:
///                         installs a second after dropping one;
///                         `touch-guard-bottom`: reads the guard's lowest
///                         byte instead) and exhausts the stack; prints
///                         `refused: ...` when the stack has no confirmed
///                         guard, `returned` if the recursion ever returns
///   co:SHAPE              a coroutine's stack exhausted: `fresh`, `after-
///                         yields`, `nested` (main -> a -> b -> c)
///   fault:KIND            a fault that is not an overflow, guard installed:
///                         `null`, `elsewhere`, `read-only`, `inside-stack`
///                         and `inside-coroutine-stack` (a page of the running
///                         stack's usable range made inaccessible),
///                         `suspended-guard`, `sibling-guard-from-coroutine`,
///                         `thread-guard-from-coroutine`, `other-thread`,
///                         `sent`
///   fault:KIND:unguarded  the same without the guard
///   sweep:DIRECTION:X     a coroutine switch made X bytes above the low end
///                         of the stack it leaves; prints `completed`
///   publication           the published stack along a nested lifecycle
fn child(scenario: &str) -> ! {
    let parts: Vec<&str> = scenario.split(':').collect();
    match parts.as_slice() {
        ["touch", thread, place] => {
            let place = place.to_string();
            // The kernel's own signal, not Rust's report of it: std's
            // handler would turn a fault in what it takes for the guard into
            // its stack-overflow abort.
            // SAFETY: restores the default disposition before anything faults.
            unsafe {
                libc::signal(libc::SIGSEGV, libc::SIG_DFL);
                libc::signal(libc::SIGBUS, libc::SIG_DFL);
            }
            on_thread(thread, move || {
                let raw = raw_stack();
                let stack = NativeStack::current().expect("the thread's stack");
                touch(match place.as_str() {
                    "reported-low" => raw.low,
                    "usable-low" => stack.low_bound,
                    "guard-top" => stack.low_bound - 1,
                    "guard-bottom" => stack.guard_low,
                    other => panic!("no place {other}"),
                });
                println!("survived");
            });
        }
        ["guard", thread, mode] => {
            let mode = mode.to_string();
            on_thread(thread, move || {
                let stack = NativeStack::current().expect("the thread's stack");
                if mode == "result-file" {
                    let path = std::env::var("BOTLISH_STACK_TEST_RESULT").expect("a result file");
                    let file = std::fs::File::create(path).expect("the result file");
                    platform::set_result_fd(std::os::unix::io::AsRawFd::as_raw_fd(&file));
                    std::mem::forget(file);
                }
                if mode == "touch-guard-bottom" {
                    // The lowest byte of the confirmed guard, read with the
                    // guard installed: inside the running stack's guard, so
                    // the guard reports it, however far below the stack.
                    let _guard = OverflowGuard::install(&stack).expect("the guard installs");
                    touch(stack.guard_low);
                    println!("returned");
                    return;
                }
                if mode == "unguarded" {
                    println!("returned {}", exhaust(0));
                    return;
                }
                if mode == "dropped" || mode == "reinstalled" {
                    // A guard installed and dropped: the process is as before
                    // (`dropped`), and a second guard installs (`reinstalled`).
                    drop(OverflowGuard::install(&stack).expect("the first guard installs"));
                    if mode == "dropped" {
                        println!("returned {}", exhaust(0));
                        return;
                    }
                }
                let installed = if mode == "executable" { OverflowGuard::install_executable(&stack) } else { OverflowGuard::install(&stack) };
                match installed {
                    Ok(_guard) => {
                        let n = if mode == "wide" { exhaust_wide(0) } else { exhaust(0) };
                        println!("returned {n}");
                    }
                    Err(error) => println!("refused: {error}"),
                }
            });
        }
        ["co", shape] => {
            let shape = shape.to_string();
            guarded("driver", move |p, _| {
                let body: GenericEntry = match shape.as_str() {
                    "fresh" => exhaust_at_start,
                    "after-yields" => exhaust_after_yield,
                    "nested" => nested_a,
                    other => panic!("no shape {other}"),
                };
                let handle = coroutine(p, body);
                rt_co_start(p, handle);
                rt_co_resume(p, handle, UNIT);
                rt_co_resume(p, handle, UNIT);
                println!("returned");
            });
        }
        ["fault", kind] | ["fault", kind, _] => {
            let kind = kind.to_string();
            let mode = if parts.len() == 3 { "none" } else { "driver" };
            guarded(mode, move |p, stack| {
                let page = page_size();
                match kind.as_str() {
                    // A null pointer's page.
                    "null" => touch(8),
                    // An inaccessible page that is no stack's.
                    "elsewhere" => unsafe {
                        let base = libc::mmap(std::ptr::null_mut(), page, libc::PROT_NONE,
                            libc::MAP_PRIVATE | libc::MAP_ANONYMOUS, -1, 0);
                        touch(base as usize + 64);
                    },
                    // A write to a read-only page: a protection fault.
                    "read-only" => unsafe {
                        let base = libc::mmap(std::ptr::null_mut(), page, libc::PROT_READ,
                            libc::MAP_PRIVATE | libc::MAP_ANONYMOUS, -1, 0);
                        std::ptr::write_volatile(base as *mut u8, 1);
                    },
                    // A suspended coroutine's guard, from the thread's stack.
                    "suspended-guard" => unsafe {
                        let handle = coroutine(p, yield_forever);
                        rt_co_start(p, handle);
                        let co = handle as *mut CoroutineObj;
                        touch((*co).stack.as_ref().unwrap().bounds().guard_low);
                    },
                    // The thread stack's guard, from a running coroutine.
                    "thread-guard-from-coroutine" => {
                        ADDRESS.store(stack.low_bound - 1, Ordering::Relaxed);
                        let handle = coroutine(p, touch_address);
                        rt_co_start(p, handle);
                    }
                    // A page inside the thread's usable stack, made
                    // inaccessible: a fault in the running stack that is not
                    // its guard.
                    "inside-stack" => touch(protected_page(stack.low_bound + (1 << 20))),
                    // The same inside a running coroutine's stack.
                    "inside-coroutine-stack" => {
                        rt_co_start(p, coroutine(p, touch_inside_own_stack));
                    }
                    // A suspended sibling's guard, from a running coroutine.
                    "sibling-guard-from-coroutine" => {
                        rt_co_start(p, coroutine(p, touch_sibling_guard));
                    }
                    // The guarded stack's guard, read by another thread.
                    "other-thread" => {
                        let address = stack.low_bound - 1;
                        std::thread::spawn(move || touch(address)).join().ok();
                    }
                    // A SIGSEGV sent, not raised by a fault.
                    "sent" => unsafe {
                        libc::raise(libc::SIGSEGV);
                    },
                    other => panic!("no fault {other}"),
                }
                println!("survived");
            });
        }
        ["sweep", direction, offset] => {
            let direction = direction.to_string();
            let offset: usize = offset.parse().expect("an offset");
            OFFSET.store(offset, Ordering::Relaxed);
            guarded("driver", move |p, stack| {
                match direction.as_str() {
                    "resume-from-thread" => {
                        let handle = coroutine(p, yield_forever);
                        rt_co_start(p, handle);
                        HANDLE.store(handle as usize, Ordering::Relaxed);
                        // SAFETY: far below this frame on a 64 MiB stack.
                        unsafe { call_at(stack.low_bound + offset, resume_handle, 0) };
                    }
                    "start-from-thread" => {
                        HANDLE.store(coroutine(p, yield_forever) as usize, Ordering::Relaxed);
                        // SAFETY: as above.
                        unsafe { call_at(stack.low_bound + offset, start_handle, 0) };
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
        ["publication"] => {
            guarded("driver", |p, stack| {
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
            eprintln!("no child scenario {scenario}");
            std::process::exit(2)
        }
    }
    std::process::exit(0)
}

struct Outcome {
    status: ExitStatus,
    stdout: String,
    stderr: String,
}

impl Outcome {
    fn signal(&self) -> Option<i32> {
        std::os::unix::process::ExitStatusExt::signal(&self.status)
    }

    /// Exit status 0 with exactly the overflow line on standard output: the
    /// driver's report of a stack overflow.
    fn is_overflow_line(&self) -> bool {
        self.signal().is_none() && self.status.code() == Some(0) && self.stdout.trim_end() == OVERFLOW_LINE
    }

    fn brief(&self) -> String {
        match self.signal() {
            Some(signal) => format!("killed by signal {signal} ({})", signal_name(signal)),
            None => format!("exit {} stdout {:?}", self.status.code().unwrap_or(-1), self.stdout.trim()),
        }
    }
}

fn signal_name(signal: i32) -> &'static str {
    match signal {
        libc::SIGSEGV => "SIGSEGV",
        libc::SIGBUS => "SIGBUS",
        libc::SIGABRT => "SIGABRT",
        libc::SIGILL => "SIGILL",
        libc::SIGTRAP => "SIGTRAP",
        _ => "other",
    }
}

fn run_child(scenario: &str) -> Outcome {
    run_child_with(scenario, &[])
}

fn run_child_with(scenario: &str, environment: &[(&str, &str)]) -> Outcome {
    let output = Command::new(std::env::current_exe().expect("the test executable"))
        .env("BOTLISH_STACK_TEST_CHILD", scenario)
        .envs(environment.iter().copied())
        .output()
        .expect("the child ran");
    Outcome {
        status: output.status,
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
    }
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

    fn note(&self, text: impl AsRef<str>) {
        println!("     {}", text.as_ref());
    }
}

/// The thread library's facts on every thread of THREADS: the current stack
/// pointer lies inside the reported stack, its bottom is page-aligned,
/// nested calls stay inside it, and what is mapped around it.
fn facts(report: &mut Report) {
    let page = page_size();
    report.note(format!("page size {page} bytes ({} KiB)", page / 1024));
    for &thread in THREADS {
        let (raw, sp, nested_ok, below, below_page, at_low, at_top) = on_thread(thread, move || {
            let raw = raw_stack();
            let sp = current_sp();
            // Nested ordinary calls: each one's stack pointer is inside the
            // stack and below its caller's.
            fn nest(depth: usize, raw: Raw, outer: usize) -> bool {
                let sp = current_sp();
                let ok = sp < outer && sp >= raw.low && sp < raw.high;
                std::hint::black_box([0u8; 64]);
                if depth == 0 { ok } else { ok && nest(depth - 1, raw, sp) }
            }
            let nested_ok = nest(200, raw, sp);
            (raw, sp, nested_ok, describe_region(raw.low - 1), describe_region(raw.low - page),
                describe_region(raw.low), describe_region(raw.high - 1))
        });
        let size = raw.high - raw.low;
        let inside = sp >= raw.low && sp < raw.high;
        // The low end is page-aligned; the top need not be (macOS puts the
        // thread's descriptor right above its stack).
        let aligned = raw.low % page == 0;
        report.check(&format!("facts {thread}"), inside && raw.low < raw.high && nested_ok && aligned,
            format!("stack [{:#x}, {:#x}) {} KiB, sp {sp:#x} ({} KiB below the top), bottom page-aligned {aligned}, top {}, nested calls inside {nested_ok}{}",
                raw.low, raw.high, size / 1024, (raw.high - sp) / 1024,
                if raw.high % page == 0 { "page-aligned".to_string() } else { format!("{} bytes into a page", raw.high % page) },
                raw.reported_guard.map(|g| format!(", reported guard {g} bytes")).unwrap_or_default()));
        report.note(format!("the byte below: {below}"));
        report.note(format!("a page below:  {below_page}"));
        report.note(format!("lowest usable: {at_low}"));
        report.note(format!("highest:       {at_top}"));
    }
}

/// What the runtime's bounds mean, observed in child processes with no
/// handler: the lowest usable byte is readable; both ends of a confirmed
/// guard kill the process with SIGSEGV or SIGBUS; and the runtime's low
/// bound differs from the thread library's exactly when the reported lowest
/// byte is not readable (the macOS main thread).
fn guard_probes(report: &mut Report, guarded: &[(&'static str, bool)]) {
    for &(thread, has_guard) in guarded {
        let (raw_low, low) = on_thread(thread, || (raw_stack().low, NativeStack::current().expect("the stack").low_bound));
        let outcome = |place: &str| run_child(&format!("touch:{thread}:{place}"));
        let faulted = |o: &Outcome| matches!(o.signal(), Some(libc::SIGSEGV | libc::SIGBUS));
        let survived = |o: &Outcome| o.status.success() && o.stdout.trim() == "survived";
        let usable = outcome("usable-low");
        report.check(&format!("touch {thread} usable-low"), survived(&usable), usable.brief());
        let reported = outcome("reported-low");
        report.check(&format!("touch {thread} reported-low"), survived(&reported) == (raw_low == low),
            format!("{} (the runtime's low bound is {})", reported.brief(), if raw_low == low { "the reported one" } else { "above the reported one" }));
        for place in ["guard-top", "guard-bottom"] {
            let o = outcome(place);
            report.check(&format!("touch {thread} {place}"), !has_guard || faulted(&o),
                if has_guard { o.brief() } else { format!("no confirmed guard: {}", o.brief()) });
        }
    }
}

/// The runtime's reading of each thread's stack (NativeStack::current): the
/// thread library's bounds, and a guard below exactly when one is confirmed.
/// Returns, per thread, whether the runtime found a guard.
fn runtime_facts(report: &mut Report) -> Vec<(&'static str, bool)> {
    let page = page_size();
    let mut guarded = Vec::new();
    for &thread in THREADS {
        let (raw, stack, below) = on_thread(thread, || {
            let stack = NativeStack::current().expect("the runtime reads the stack");
            (raw_stack(), stack, region(stack.low_bound - 1))
        });
        let has_guard = stack.guard_low < stack.low_bound;
        let guard = stack.low_bound - stack.guard_low;
        // The runtime's top is the thread library's; its low bound is the
        // reported one, or above it where the reported bottom is
        // inaccessible (guard_probes checks which).
        let same_bounds = stack.high_bound == raw.high && stack.low_bound >= raw.low && stack.low_bound < raw.high;
        // The guard is what the host reports (Linux) or the inaccessible
        // mapping that ends at the stack (macOS), never an assumption.
        let guard_as_host_says = match raw.reported_guard {
            Some(reported) => stack.low_bound == raw.low && guard == reported,
            None => has_guard == matches!(&below, Some((_, end, prot)) if prot == "---" && *end == stack.low_bound)
                && (!has_guard || below.as_ref().is_some_and(|(start, _, _)| *start >= stack.guard_low)),
        };
        // Every thread Botlish runs on (a std thread) and a thread made with
        // a four-page guard has one; the process's main thread is reported.
        let required = match thread {
            "std-default" | "std-1MiB" | "std-1GiB" => has_guard && guard >= page,
            "pthread-guard-4-pages" => has_guard && guard >= 4 * page,
            _ => true,
        };
        report.check(&format!("runtime stack {thread}"), same_bounds && guard_as_host_says && required,
            format!("[{:#x}, {:#x}){}, guard {}", stack.low_bound, stack.high_bound,
                if stack.low_bound == raw.low { String::new() } else { format!(" ({} KiB above the reported bottom)", (stack.low_bound - raw.low) / 1024) },
                if has_guard { format!("[{:#x}, {:#x}) {} KiB", stack.guard_low, stack.low_bound, guard / 1024) } else { "none confirmed".to_string() }));
        guarded.push((thread, has_guard));
    }
    guarded
}

/// The guard on each thread: a stack with a confirmed guard, exhausted, ends
/// in the overflow line and exit status 0 (the driver), and one without is
/// refused; the executable and result-file modes; a 64 KiB frame.
fn guard_checks(report: &mut Report, guarded: &[(&'static str, bool)]) {
    for &(thread, has_guard) in guarded {
        if thread == "std-default" {
            continue;
        }
        let outcome = run_child(&format!("guard:{thread}:driver"));
        let ok = if has_guard { outcome.is_overflow_line() } else { outcome.status.success() && outcome.stdout.starts_with("refused:") };
        report.check(&format!("guard {thread} driver"), ok, outcome.brief());
        // The whole confirmed guard is the guard: its lowest byte too (16
        // KiB below a created thread's stack on macOS, 56 MiB below the
        // main thread's).
        if has_guard {
            let outcome = run_child(&format!("guard:{thread}:touch-guard-bottom"));
            report.check(&format!("guard {thread} guard bottom"), outcome.is_overflow_line(), outcome.brief());
        }
    }
    let outcome = run_child("guard:std-1MiB:executable");
    report.check("guard std-1MiB executable", outcome.signal().is_none() && outcome.status.code() == Some(1)
        && outcome.stdout.is_empty() && outcome.stderr.trim() == OVERFLOW_LINE, format!("{} stderr {:?}", outcome.brief(), outcome.stderr.trim()));
    let path = std::env::temp_dir().join(format!("botlish-native-stack-{}.result", std::process::id()));
    let outcome = run_child_with("guard:std-1MiB:result-file", &[("BOTLISH_STACK_TEST_RESULT", path.to_str().unwrap())]);
    let written = std::fs::read_to_string(&path).unwrap_or_default();
    let _ = std::fs::remove_file(&path);
    report.check("guard std-1MiB result-file", outcome.status.success() && outcome.stdout.is_empty() && written.trim() == OVERFLOW_LINE,
        format!("{} result file {:?}", outcome.brief(), written.trim()));
    let outcome = run_child("guard:std-1MiB:wide");
    report.check("guard std-1MiB 64 KiB frames", outcome.is_overflow_line(), outcome.brief());
    // A dropped guard leaves the process as it was: the exhaustion is the
    // thread library's and Rust's (SIGABRT, or the signal), never the line;
    // and a second guard installs and reports.
    let dropped = run_child("guard:std-1MiB:dropped");
    let unguarded = run_child("guard:std-1MiB:unguarded");
    report.check("guard std-1MiB dropped", !dropped.stdout.contains("NATIVE LIMIT STACK") && dropped.signal().is_some()
        && dropped.signal() == unguarded.signal(), format!("{}; never installed: {}", dropped.brief(), unguarded.brief()));
    let outcome = run_child("guard:std-1MiB:reinstalled");
    report.check("guard std-1MiB reinstalled", outcome.is_overflow_line(), outcome.brief());
}

/// A coroutine's own stack exhausted: at its start, after yields, and at the
/// bottom of main -> a -> b -> c.
fn coroutine_checks(report: &mut Report) {
    for shape in ["fresh", "after-yields", "nested"] {
        let outcome = run_child(&format!("co:{shape}"));
        report.check(&format!("coroutine {shape}"), outcome.is_overflow_line(), outcome.brief());
    }
}

/// Faults that are not the running stack's exhaustion, with the guard
/// installed: never the overflow line, and each ends exactly as it does
/// without the guard (the same signal, or -- a SIGSEGV sent rather than
/// raised by a fault -- what the previous disposition does with it). Every
/// memory fault kills the process.
fn fault_checks(report: &mut Report) {
    for kind in ["null", "elsewhere", "read-only", "inside-stack", "inside-coroutine-stack", "suspended-guard",
        "sibling-guard-from-coroutine", "thread-guard-from-coroutine", "other-thread", "sent"] {
        let with = run_child(&format!("fault:{kind}"));
        let without = run_child(&format!("fault:{kind}:unguarded"));
        let relabelled = with.stdout.contains("NATIVE LIMIT STACK") || with.stderr.contains("NATIVE LIMIT STACK");
        let same = with.signal() == without.signal() && with.status.code() == without.status.code() && with.stdout == without.stdout;
        let killed = kind == "sent" || matches!(with.signal(), Some(libc::SIGSEGV | libc::SIGBUS | libc::SIGABRT));
        report.check(&format!("fault {kind}"), !relabelled && same && killed,
            format!("{}; without the guard: {}", with.brief(), without.brief()));
    }
}

/// A coroutine switch made X bytes above the low end of the stack it leaves,
/// for X from 0 to 1.5 KiB in 16-byte steps: whichever instruction of the
/// switch path (the helper's frames, bl_co_switch's pushes, the arriving
/// side) the stack ends at, the run either completes or ends in the overflow
/// line -- never a crash. Both must occur, or the sweep missed the edge.
fn sweep_checks(report: &mut Report) {
    for direction in ["resume-from-thread", "start-from-thread", "resume-from-coroutine", "yield-from-coroutine"] {
        let (mut completed, mut overflowed, mut failures) = (0, 0, Vec::new());
        for offset in (0..=1536).step_by(16) {
            let outcome = run_child(&format!("sweep:{direction}:{offset}"));
            if outcome.status.success() && outcome.stdout.trim() == "completed" {
                completed += 1;
            } else if outcome.is_overflow_line() {
                overflowed += 1;
            } else {
                failures.push(format!("{offset}: {}", outcome.brief()));
            }
        }
        report.check(&format!("sweep {direction}"), failures.is_empty() && completed > 0 && overflowed > 0,
            format!("{overflowed} overflowed, {completed} completed{}", if failures.is_empty() { String::new() } else { format!(", failed at {}", failures.join(", ")) }));
    }
}

/// The stack the guard reads is the one that runs, at every point of a
/// nested lifecycle (the thread's, a's, b's, back again).
fn publication_check(report: &mut Report) {
    let outcome = run_child("publication");
    report.check("publication", outcome.status.success() && outcome.stdout.trim() == "publication ok", outcome.brief());
}

pub fn main() {
    if let Ok(scenario) = std::env::var("BOTLISH_STACK_TEST_CHILD") {
        child(&scenario);
    }
    let mut report = Report { failures: 0 };
    facts(&mut report);
    let guarded = runtime_facts(&mut report);
    guard_probes(&mut report, &guarded);
    guard_checks(&mut report, &guarded);
    coroutine_checks(&mut report);
    fault_checks(&mut report);
    publication_check(&mut report);
    sweep_checks(&mut report);
    if report.failures > 0 {
        println!("{} native stack checks failed", report.failures);
        std::process::exit(1);
    }
    println!("every native stack check passed");
}
} // mod guarded
