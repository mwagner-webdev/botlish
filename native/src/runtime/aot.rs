//! Standalone executable startup. The initializer contains only constants,
//! function metadata and relocated stack maps; program instructions are
//! already machine code in the linked object.
//!
//! Process arguments (ARGV.md): the generated `main` collects the real
//! argument vector (`process_argv`) into one owned `Vec<Vec<u8>>` copy (it
//! does not borrow the C startup array) and passes it to `run`, which
//! installs it in the Vm as the run's argument snapshot before the program's
//! entry function executes. On Linux and macOS the vector is the
//! `argc`/`argv` the C runtime hands the process (glibc's, libSystem's),
//! which Rust's runtime keeps and `std::env::args_os` returns as raw
//! `OsString`s, i.e. the exact bytes, never decoded. On Windows a process
//! has one UTF-16 command line, which Rust's runtime splits into arguments
//! by the Microsoft C runtime's rules; each argument's UTF-16 code units are
//! encoded here as WTF-8 (`wtf8_from_utf16`), losslessly: valid UTF-16 is
//! its UTF-8, an unpaired surrogate the three bytes no valid UTF-8 holds.
//! Nothing is validated here: UTF-8 validation belongs to the `argv()`
//! operation (`ops.rs`'s `rt_argv`), so malformed arguments -- invalid UTF-8
//! on Linux, an unpaired surrogate on Windows -- cannot fail a program that
//! never asks for them. `argc == 0` yields an empty snapshot, and `argv()`
//! an empty List.
//!
//! The driver protocol (C-FFI.md, "Running a program that calls C"). The
//! driver runs a program that calls C by linking it as an executable -- the
//! one way its foreign symbols are resolved, by the system linker -- and
//! running that, with `BOTLISH_NATIVE_RESULT` naming a file: the executable
//! then reports exactly as `botlish-native run` does (result lines `value
//! V` / `error CODE MESSAGE` in the host value format, the overflow guard's
//! report among them) to that file instead of printing its value, and
//! leaves its standard output and error to the program. With
//! `BOTLISH_NATIVE_RUNS=N` it runs the program N times, as `bench` does,
//! reporting `times` and `timing` lines (`BOTLISH_NATIVE_COMPILE_US`, the
//! driver's compile and link time, is the timing line's first field). An
//! ordinary run of the executable, with neither variable, is unchanged.
//!
//! `BOTLISH_NATIVE_STARTUP_REPORT=PATH` makes the executable write what its
//! startup installed to PATH (`Vm::startup_report`) before the program
//! runs, which then runs as ever: how the tests compare the startups of the
//! rustc, stub and system linkers (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
//! After the Vm's report come the startup's own facts (`startup_facts`): the
//! policy the record names, whether the thread running the program is the
//! process's main thread, and the stack the Vm found it on.
//!
//! The startup policy (MAIN-THREAD-STARTUP-MILESTONE-1.md;
//! runtime::program's `Startup`): where the program runs is a property of
//! the executable, the `startup` word of its `botlish_program` record, which
//! `start_linked` reads on the thread that entered `main` before anything
//! else is decided. `worker` (the default, every target's) runs the program
//! on a thread `run` creates with a stack of `BOTLISH_NATIVE_STACK_BYTES`
//! (1 GiB by default) and joins; `main-thread` (macOS AArch64 only:
//! `MAIN_THREAD_STARTUP`) runs it on the calling thread -- the process's
//! main thread -- on the stack the link reserved for it (LC_MAIN's 512 MiB,
//! codegen::aot's `MAIN_STACK_BYTES`), which the environment cannot resize.
//! Both run one body (`run`): the same Vm, made on the thread that runs the
//! program, the same guard on that thread's stack, the same reports, lines
//! and statuses -- a panic included, which is `native executable panicked
//! (NATIVE BUG)`, status 1, on either thread. The driver's JIT keeps its own
//! worker (main.rs) and a native library runs on its host's thread
//! (runtime::library): neither reads the policy.
//!
//! `BOTLISH_NATIVE_RUNTIME_FAULT=panic` is a test-only fault injection: the
//! runtime panics on the program's thread right before the program's entry,
//! which is how the tests prove the panic line of both policies
//! (tests/main-thread-startup.test). Any other value is ignored.
use super::error::RtError;
use super::metrics::AllocMode;
use super::program::{LinkedProgram, Startup};
use super::show::{show, tcl_list, tcl_value};
use super::value::{NO_VALUE, Value};
use super::vm::Vm;
use std::io::Write;

/// Whether this target's executables may start on the process's main thread
/// (`Startup::MainThread`): macOS AArch64, where the census
/// (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md) and MAIN-THREAD-STARTUP-
/// MILESTONE-1.md validated it -- the main thread's stack discovered with a
/// confirmed guard, LC_MAIN's stack size honoured, the guard, the
/// collector and coroutines unchanged. Not Linux: glibc reports no guard for
/// the main thread, so the stack guard refuses it; not Windows: its main
/// thread's stack is the link's reservation (1 MiB unless it reserves more),
/// never validated. Code generation refuses the policy elsewhere before
/// anything is linked (codegen::aot), and `run` refuses a record that names
/// it anyway.
pub const MAIN_THREAD_STARTUP: bool = cfg!(all(target_os = "macos", target_arch = "aarch64"));

pub type ProgramEntry = extern "C" fn(*mut Vm) -> Value;

/// This process's own argument vector, argument zero first, as the run's
/// argument snapshot: the raw bytes of every argument on Unix, the WTF-8 of
/// every argument's UTF-16 on Windows (the module doc).
pub fn process_argv() -> Vec<Vec<u8>> {
    #[cfg(unix)]
    {
        use std::os::unix::ffi::OsStringExt;
        std::env::args_os().map(|a| a.into_vec()).collect()
    }
    #[cfg(windows)]
    {
        use std::os::windows::ffi::OsStrExt;
        std::env::args_os().map(|a| wtf8_from_utf16(a.encode_wide())).collect()
    }
}

/// The WTF-8 encoding of the UTF-16 code units UNITS (an argument of a
/// Windows command line): every surrogate pair and every other scalar value
/// as its UTF-8, and an unpaired surrogate -- which UTF-16 text may hold and
/// no Unicode scalar is -- as the three-byte form of its code unit
/// (U+D800-U+DFFF: `ED A0 80`..`ED BF BF`), which strict UTF-8 rejects. So
/// the encoding is lossless, a valid argument's bytes are exactly its UTF-8,
/// and `argv()` refuses an invalid one with the same declared error as
/// invalid UTF-8 on Linux. Written here rather than read from `OsString`'s
/// internal encoding, which Rust leaves unspecified.
pub fn wtf8_from_utf16(units: impl IntoIterator<Item = u16>) -> Vec<u8> {
    let mut bytes = Vec::new();
    for decoded in char::decode_utf16(units) {
        match decoded {
            Ok(c) => bytes.extend_from_slice(c.encode_utf8(&mut [0; 4]).as_bytes()),
            Err(e) => {
                let unit = e.unpaired_surrogate();
                bytes.extend_from_slice(&[0xE0 | (unit >> 12) as u8, 0x80 | ((unit >> 6) & 0x3F) as u8, 0x80 | (unit & 0x3F) as u8]);
            }
        }
    }
    bytes
}

/// The UTF-16 code units whose WTF-8 encoding (`wtf8_from_utf16`) is BYTES:
/// its exact inverse, for the driver writing a Windows command line from an
/// argument snapshot (WINDOWS-X86-64-MILESTONE-2.md, "Linked runs"). None
/// when BYTES encodes no units: bytes that are not well-formed generalized
/// UTF-8 (a stray or missing continuation byte, an overlong form, a value
/// past U+10FFFF), or a surrogate pair written as two three-byte surrogates
/// -- WTF-8 writes a pair as its scalar's four bytes, so decoding those six
/// bytes would give units that encode back to other bytes.
pub fn utf16_from_wtf8(bytes: &[u8]) -> Option<Vec<u16>> {
    let mut units = Vec::with_capacity(bytes.len());
    // Whether the last unit pushed was a lead surrogate written alone.
    let mut lone_lead = false;
    let mut i = 0;
    while i < bytes.len() {
        let first = bytes[i];
        let (length, initial, minimum) = match first {
            0x00..=0x7F => (1, first as u32, 0),
            0xC0..=0xDF => (2, (first & 0x1F) as u32, 0x80),
            0xE0..=0xEF => (3, (first & 0x0F) as u32, 0x800),
            0xF0..=0xF7 => (4, (first & 0x07) as u32, 0x1_0000),
            _ => return None,
        };
        let tail = bytes.get(i + 1..i + length)?;
        let mut code = initial;
        for &b in tail {
            if b & 0xC0 != 0x80 {
                return None;
            }
            code = (code << 6) | (b & 0x3F) as u32;
        }
        if code < minimum || code > 0x10_FFFF {
            return None;
        }
        i += length;
        if (0xD800..=0xDFFF).contains(&code) {
            if code >= 0xDC00 && lone_lead {
                return None;
            }
            lone_lead = code < 0xDC00;
            units.push(code as u16);
            continue;
        }
        lone_lead = false;
        let mut buffer = [0u16; 2];
        units.extend_from_slice(char::from_u32(code)?.encode_utf16(&mut buffer));
    }
    Some(units)
}

/// What Rust's own startup does to the process before a Rust `main` runs
/// (`std::rt::lang_start`'s `init`), for the one executable whose `main` is
/// not Rust's: a system-linked one (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md),
/// whose C `main` is the runtime archive's (`linked_main`, below). An
/// executable the rustc or stub linker links, or the driver, gets this from
/// Rust itself and never calls it. On Unix:
///
///   * a standard descriptor (0, 1, 2) the process was started without is
///     opened on /dev/null, so no file the program opens later takes its
///     place;
///   * SIGPIPE is ignored, so a write to a closed pipe is the `EPIPE` error a
///     program handles (NATIVE IO, a declared error), never a kill;
///   * on macOS the main thread is named `main`.
///
/// What it does not do is install Rust's handler for an overflow of a Rust
/// thread's own guard page (`stack_overflow::init`, not public): the runtime's
/// own guard (runtime/platform/) reports a Botlish stack's overflow either
/// way, and any other fault ends the process by the signal itself instead of
/// by Rust's message and abort. Nothing on Windows: its other half of
/// Rust's startup is that same handler.
pub fn rust_process_setup() {
    #[cfg(unix)]
    unsafe {
        let mut devnull = -1;
        for fd in 0..3 {
            if libc::fcntl(fd, libc::F_GETFD) == -1 && std::io::Error::last_os_error().raw_os_error() == Some(libc::EBADF) {
                // The lowest free descriptor: FD itself, as the earlier ones
                // are open.
                if devnull == -1 || libc::dup(devnull) == -1 {
                    devnull = libc::open(c"/dev/null".as_ptr(), libc::O_RDWR, 0);
                    if devnull == -1 {
                        libc::abort();
                    }
                }
            }
        }
        if libc::signal(libc::SIGPIPE, libc::SIG_IGN) == libc::SIG_ERR {
            libc::abort();
        }
        #[cfg(target_vendor = "apple")]
        libc::pthread_setname_np(c"main".as_ptr());
    }
}

/// The executables' startup (codegen::aot's startup crate, the rustc
/// linker's; `linked_main`, the system linker's): the policy of the program
/// object's record LINKED, read and checked on the calling thread -- the
/// process's main thread -- before anything is decided (`program::
/// startup_of`), then the program run by that policy (`run`), the record
/// read by `program::instantiate_linked` on the thread that runs it. A
/// record it cannot read is NATIVE STARTUP, status 1. Returns the exit
/// status.
///
/// # Safety
/// As `program::read_linked`: LINKED is the record the program object
/// defines, relocated by the link.
pub unsafe fn start_linked(linked: &'static LinkedProgram) -> i32 {
    // SAFETY: the caller's contract.
    let startup = match unsafe { super::program::startup_of(linked) } {
        Ok(startup) => startup,
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            return 1;
        }
    };
    run(startup, process_argv(), move || {
        // SAFETY: the caller's contract.
        match unsafe { super::program::instantiate_linked(linked) } {
            Ok(started) => started,
            Err(error) => {
                eprintln!("{error} (NATIVE STARTUP)");
                std::process::exit(1);
            }
        }
    })
}

/// The runtime archive's `main` (native/runtime-archive): a system-linked
/// executable's startup (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md). What Rust's
/// own startup does to the process (`rust_process_setup`), then exactly what
/// the rustc linker's startup crate does (codegen::aot's `STARTUP`):
/// `start_linked` of the program object's record LINKED, the process ended
/// by `std::process::exit` (which flushes Rust's standard output). A panic
/// outside the program's own body is status 101, as a Rust `main`'s.
///
/// # Safety
/// As `program::read_linked`: LINKED is the record the program object
/// defines, relocated by the link.
pub unsafe fn linked_main(linked: &'static LinkedProgram) -> i32 {
    let status = std::panic::catch_unwind(|| -> i32 {
        rust_process_setup();
        // SAFETY: the caller's contract.
        unsafe { start_linked(linked) }
    });
    match status {
        Ok(status) => std::process::exit(status),
        Err(_) => {
            let _ = std::io::Write::flush(&mut std::io::stdout());
            101
        }
    }
}

/// Runs the program INIT makes, with the argument snapshot ARGV, by the
/// startup policy STARTUP (the module doc): on a worker it creates and joins,
/// or on the calling thread. Either way one body runs on that thread: INIT
/// (the Vm and the entry, made there), the startup report, the snapshot, the
/// driver protocol or the guard and the program, and its value or error.
/// Returns the exit status.
pub fn run(startup: Startup, argv: Vec<Vec<u8>>, init: impl FnOnce() -> (Box<Vm>, ProgramEntry) + Send + 'static) -> i32 {
    let protocol = std::env::var_os("BOTLISH_NATIVE_RESULT").filter(|p| !p.is_empty());
    let report = std::env::var_os("BOTLISH_NATIVE_STARTUP_REPORT").filter(|p| !p.is_empty());
    let body = move || -> i32 {
        let (mut vm, entry) = init();
        if let Some(path) = report {
            // What the startup installed (Vm::startup_report), before any of
            // the program runs: the evidence that every linker's startup
            // builds the same Vm (tests/system-linker.test), and that each
            // policy runs it where it says (tests/main-thread-startup.test).
            if let Err(error) = std::fs::write(&path, format!("{}{}", vm.startup_report(), startup_facts(startup, &vm))) {
                eprintln!("{}: {error} (NATIVE IO)", std::path::Path::new(&path).display());
                return 2;
            }
        }
        vm.set_argv(argv);
        debug_assert!(matches!(vm.metrics.mode, AllocMode::Off));
        if let Some(path) = protocol {
            return driver_protocol(std::path::Path::new(&path), &mut vm, entry);
        }
        #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
        let _guard = {
            let stack = super::native_stack::NativeStack::current().expect("the thread's stack bounds");
            super::platform::OverflowGuard::install_executable(&stack).expect("the stack-overflow guard")
        };
        injected_fault();
        let result = entry(&mut *vm);
        if result == NO_VALUE {
            let error = vm
                .error
                .take()
                .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
            eprintln!("{} ({})", vm.describe_error(&error), error.error_code().join(" "));
            return 1;
        }
        match writeln!(std::io::stdout().lock(), "{}", show(result)) {
            Ok(()) => 0,
            Err(error) => {
                eprintln!("{error} (NATIVE IO)");
                1
            }
        }
    };
    let status = match startup {
        Startup::Worker => {
            let stack_size = std::env::var("BOTLISH_NATIVE_STACK_BYTES")
                .ok()
                .and_then(|text| text.parse::<usize>().ok())
                .filter(|&size| size >= 1 << 20)
                .unwrap_or(1 << 30);
            match std::thread::Builder::new().stack_size(stack_size).spawn(body) {
                Ok(worker) => match worker.join() {
                    Ok(status) => status,
                    Err(_) => panicked(),
                },
                Err(error) => {
                    eprintln!("{error} (NATIVE STARTUP)");
                    1
                }
            }
        }
        Startup::MainThread if MAIN_THREAD_STARTUP => on_this_thread(body),
        Startup::MainThread => {
            eprintln!("this executable starts its program on the process's main thread (startup policy main-thread), which executables of this target do not support: only macOS aarch64's do (NATIVE STARTUP)");
            1
        }
    };
    // BOTLISH_NATIVE_UNWIND_CHECK's account (runtime::framewalk).
    #[cfg(all(windows, target_arch = "x86_64"))]
    if let Some(summary) = super::framewalk::windows::summary() {
        eprintln!("{summary}");
    }
    status
}

/// BODY's status, run on the calling thread, a panic in it caught where the
/// worker's `join` would catch it and reported the same way (`panicked`):
/// it never unwinds into the executable's `main` (Rust's, or the runtime
/// archive's C `main`). A stack overflow is no panic: the guard reports it
/// and ends the process before anything unwinds.
pub fn on_this_thread(body: impl FnOnce() -> i32) -> i32 {
    match std::panic::catch_unwind(std::panic::AssertUnwindSafe(body)) {
        Ok(status) => status,
        Err(_) => panicked(),
    }
}

/// The report of a panic on the program's thread, whichever that is
/// (Rust's panic hook has printed the panic's own message first): status 1.
fn panicked() -> i32 {
    eprintln!("native executable panicked (NATIVE BUG)");
    1
}

/// `BOTLISH_NATIVE_RUNTIME_FAULT=panic` (the module doc): a panic on the
/// program's thread, where a runtime defect would raise one.
fn injected_fault() {
    if std::env::var_os("BOTLISH_NATIVE_RUNTIME_FAULT").is_some_and(|v| v == "panic") {
        panic!("BOTLISH_NATIVE_RUNTIME_FAULT=panic: a panic injected on the program's thread");
    }
}

/// The startup's own facts after the Vm's report (the module doc): the
/// policy STARTUP, `thread main` or `thread worker` (whether the calling
/// thread is the process's main thread, as the host says: libpthread's
/// `pthread_main_np` on macOS, the thread id against the process id on
/// Linux; no line on Windows, which has no such question), and the usable
/// bytes and confirmed guard of the stack VM was made on (its
/// `NativeStack`; none on a host without stack discovery).
fn startup_facts(startup: Startup, vm: &Vm) -> String {
    let mut facts = format!("startup {}\n", startup.name());
    #[cfg(target_vendor = "apple")]
    // SAFETY: no preconditions.
    let main = Some(unsafe { libc::pthread_main_np() } == 1);
    // Both ids from the kernel: never libc's getpid, which every executable
    // would then import (a program making raw syscalls links none of
    // libc's: tests/linux-syscall.test).
    #[cfg(target_os = "linux")]
    // SAFETY: no preconditions.
    let main = Some(unsafe { libc::syscall(libc::SYS_gettid) == libc::syscall(libc::SYS_getpid) });
    #[cfg(not(any(target_vendor = "apple", target_os = "linux")))]
    let main: Option<bool> = None;
    if let Some(main) = main {
        facts.push_str(if main { "thread main\n" } else { "thread worker\n" });
    }
    if let Some(stack) = vm.native_stack() {
        facts.push_str(&format!("stack usable {} guard {}\n", stack.high_bound - stack.low_bound, stack.low_bound - stack.guard_low));
    }
    facts
}

/// Runs the program as `botlish-native run` (or `bench`) would and writes its
/// result lines to PATH (the header's "driver protocol"). Returns the exit
/// status: 0 whenever the result lines were written, a program error
/// included.
fn driver_protocol(path: &std::path::Path, vm: &mut Vm, entry: ProgramEntry) -> i32 {
    let mut file = match std::fs::File::create(path) {
        Ok(file) => file,
        Err(error) => {
            eprintln!("{}: {error} (NATIVE IO)", path.display());
            return 2;
        }
    };
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64", target_env = "msvc")))]
    let _guard = {
        super::platform::set_result_file(&file);
        let stack = super::native_stack::NativeStack::current().expect("the thread's stack bounds");
        super::platform::OverflowGuard::install(&stack).expect("the stack-overflow guard")
    };
    injected_fault();
    let runs = std::env::var("BOTLISH_NATIVE_RUNS").ok().and_then(|n| n.parse::<usize>().ok()).filter(|n| *n > 0);
    let mut lines = Vec::new();
    let mut result = NO_VALUE;
    let mut nanos = Vec::new();
    let mut best = u128::MAX;
    for run in 0..runs.unwrap_or(1) {
        if run > 0 {
            vm.reset();
        }
        let started = std::time::Instant::now();
        result = entry(&mut *vm);
        let elapsed = started.elapsed();
        nanos.push(elapsed.as_nanos().to_string());
        best = best.min(elapsed.as_micros());
        if result == NO_VALUE {
            break;
        }
    }
    if let Some(runs) = runs {
        let compile = std::env::var("BOTLISH_NATIVE_COMPILE_US").unwrap_or_else(|_| "0".to_string());
        lines.push(format!("times {}", nanos.join(" ")));
        lines.push(format!("timing {compile} {best} {runs} {}", vm.heap.collections));
    }
    if result == NO_VALUE {
        let error = vm
            .error
            .take()
            .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
        let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
        lines.push(tcl_list(&["error".to_string(), tcl_list(&code), vm.describe_error(&error)]));
    } else {
        match tcl_value(result) {
            Ok(value) => lines.push(tcl_list(&["value".to_string(), value])),
            Err(error) => {
                let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
                lines.push(tcl_list(&["error".to_string(), tcl_list(&code), error.message()]));
            }
        }
    }
    for line in lines {
        if writeln!(file, "{line}").is_err() {
            return 2;
        }
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The main-thread policy's body runs on the calling thread, and a panic
    /// in it is the worker's report and status, never an unwind out of
    /// `run` (MAIN-THREAD-STARTUP-MILESTONE-1.md, "Panic behavior").
    #[test]
    fn startup_on_this_thread_catches_a_panic() {
        let caller = std::thread::current().id();
        assert_eq!(on_this_thread(|| if std::thread::current().id() == caller { 7 } else { 0 }), 7);
        assert_eq!(on_this_thread(|| panic!("an injected panic")), 1);
    }

    /// A record naming the main-thread policy on a target without it is
    /// refused before its program is made or run: INIT never runs.
    #[test]
    fn startup_main_thread_refused_where_unsupported() {
        if MAIN_THREAD_STARTUP {
            return;
        }
        let status = run(Startup::MainThread, Vec::new(), || panic!("the program must not be made"));
        assert_eq!(status, 1);
    }
}
