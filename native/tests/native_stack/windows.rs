//! The Windows half of the native stack checks (WINDOWS-X86-64-MILESTONE-4.md):
//! each kind of thread Botlish runs on, the guard on it (runtime/platform/
//! windows.rs), its stack exhausted for real -- by small frames, by 64 KiB
//! frames (Rust's __chkstk probes), by an inline probe loop like
//! Cranelift's -- in each reporting mode, and the faults that are not an
//! overflow of the guarded stack, each of which must end exactly as it does
//! without the guard. Every check that faults runs in a child process.
use botlish_native::runtime::native_stack::NativeStack;
use botlish_native::runtime::platform::{self, OverflowGuard};
use botlish_native::runtime::platform::windows::{confirmed_guard_page, stack_guarantee, GUARANTEE};
use std::process::Command;
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
        _ => {
            eprintln!("no child scenario {scenario}");
            std::process::exit(2)
        }
    }
    std::process::exit(0)
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
    if report.failures > 0 {
        println!("{} native stack checks failed", report.failures);
        std::process::exit(1);
    }
    println!("every native stack check passed");
}
