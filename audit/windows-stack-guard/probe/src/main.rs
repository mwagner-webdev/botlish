//! The Windows stack guard's feasibility probe (WINDOWS-X86-64-MILESTONE-4.md,
//! "Experiments"). Run on a real Windows x86-64 host:
//!
//! ```text
//!   cargo run --release --manifest-path audit/windows-stack-guard/probe/Cargo.toml
//! ```
//!
//! Every experiment that exhausts a stack or faults runs in a child process
//! -- this executable again, with `PROBE_CHILD` naming the scenario as
//! `key=value` words -- and the parent prints what the child printed and how
//! it ended (its exit code: an NTSTATUS for a process Windows ended). A
//! vectored exception handler (`handler`) installed first in the chain sees
//! the exception, writes one line describing it with WriteFile -- the
//! record, the stack pointers, how much of the thread's stack was left --
//! and ends the process with TerminateProcess(0x42), or passes the exception
//! on, as the scenario asks.
//!
//! What it establishes (each line of the report names its scenario):
//!
//!   facts       each kind of thread's stack: GetCurrentThreadStackLimits,
//!               NT_TIB's StackBase and StackLimit, the guard page below the
//!               committed part (VirtualQuery), its stack guarantee
//!   overflow    which exception arrives when a stack is exhausted in Rust,
//!               in MSVC-compiled C, by 64 KiB frames (Rust's and MSVC's
//!               probes), by an inline probe loop like Cranelift's, and on a
//!               thread with Rust's guarantee, without any, with a larger one
//!   room        how many bytes the handler can still use before its write
//!               and termination fail, per guarantee
//!   stack-use   how many bytes the reporting path itself uses (WriteFile to
//!               a pipe, a file, the null device; TerminateProcess), by
//!               painting the stack below it
//!   faults      what arrives for a null read, a read of the stack's
//!               uncommitted reservation, a read of its guard page, an
//!               exception raised by RaiseException, an overflow on another
//!               thread
//!   unhandled   the same overflow with no handler of the probe's: Rust's own
#[cfg(not(windows))]
fn main() {
    println!("windows-stack-guard-probe: Windows x86-64 only");
}

#[cfg(windows)]
fn main() {
    probe::main()
}

#[cfg(windows)]
mod probe {
use std::collections::BTreeMap;
use std::process::Command;
use std::sync::atomic::{AtomicU32, AtomicUsize, Ordering};
use windows_sys::Win32::Foundation::{CloseHandle, EXCEPTION_ACCESS_VIOLATION, EXCEPTION_STACK_OVERFLOW, GetLastError, HANDLE};
use windows_sys::Win32::Storage::FileSystem::WriteFile;
use windows_sys::Win32::System::Console::{GetStdHandle, STD_ERROR_HANDLE, STD_OUTPUT_HANDLE};
use windows_sys::Win32::System::Diagnostics::Debug::{
    AddVectoredExceptionHandler, EXCEPTION_CONTINUE_SEARCH, EXCEPTION_POINTERS, RaiseException,
};
use windows_sys::Win32::System::Memory::{MEMORY_BASIC_INFORMATION, VirtualQuery};
use windows_sys::Win32::System::Threading::{
    CreateThread, GetCurrentProcess, GetCurrentThreadId, GetCurrentThreadStackLimits, INFINITE,
    STACK_SIZE_PARAM_IS_A_RESERVATION, SetThreadStackGuarantee, TerminateProcess, WaitForSingleObject,
};

unsafe extern "C" {
    fn probe_c_deep(n: i32) -> i32;
    fn probe_c_wide(n: i32) -> i32;
}

// ---------------------------------------------------------------------------
// A line formatted without allocating (the handler's)

struct Line {
    buf: [u8; 1024],
    len: usize,
}

impl Line {
    fn new() -> Self {
        Line { buf: [0; 1024], len: 0 }
    }

    fn s(&mut self, text: &str) -> &mut Self {
        for &b in text.as_bytes() {
            if self.len < self.buf.len() {
                self.buf[self.len] = b;
                self.len += 1;
            }
        }
        self
    }

    fn hex(&mut self, value: u64) -> &mut Self {
        self.s("0x");
        let mut started = false;
        for shift in (0..16).rev() {
            let digit = ((value >> (shift * 4)) & 15) as u8;
            if digit != 0 || started || shift == 0 {
                started = true;
                let c = if digit < 10 { b'0' + digit } else { b'a' + digit - 10 };
                if self.len < self.buf.len() {
                    self.buf[self.len] = c;
                    self.len += 1;
                }
            }
        }
        self
    }

    fn dec(&mut self, value: u64) -> &mut Self {
        let mut digits = [0u8; 20];
        let mut n = value;
        let mut i = digits.len();
        loop {
            i -= 1;
            digits[i] = b'0' + (n % 10) as u8;
            n /= 10;
            if n == 0 {
                break;
            }
        }
        for &d in &digits[i..] {
            if self.len < self.buf.len() {
                self.buf[self.len] = d;
                self.len += 1;
            }
        }
        self
    }

    fn signed(&mut self, value: i64) -> &mut Self {
        if value < 0 {
            self.s("-").dec(value.unsigned_abs())
        } else {
            self.dec(value as u64)
        }
    }

    /// WriteFile of the line to OUT: whether every byte was written.
    fn write(&self, out: HANDLE) -> bool {
        let mut rest = &self.buf[..self.len];
        while !rest.is_empty() {
            let mut written = 0u32;
            // SAFETY: a buffer of this frame, synchronous I/O.
            let ok = unsafe { WriteFile(out, rest.as_ptr(), rest.len() as u32, &mut written, std::ptr::null_mut()) };
            if ok == 0 || written == 0 {
                return false;
            }
            rest = &rest[written as usize..];
        }
        true
    }
}

#[inline(always)]
fn rsp() -> usize {
    let sp: usize;
    // SAFETY: reads a register.
    unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
    sp
}

/// NT_TIB's StackLimit (winnt.h's NT_TIB at the TEB's start, the TEB at
/// gs:[0x30]): the lowest committed address of the thread's stack.
#[inline(always)]
fn tib_limit() -> usize {
    let limit: usize;
    // SAFETY: reads the current thread's TEB.
    unsafe { std::arch::asm!("mov {}, qword ptr gs:[0x10]", out(reg) limit, options(nostack, preserves_flags, readonly)) };
    limit
}

/// NT_TIB's StackBase.
#[inline(always)]
fn tib_base() -> usize {
    let base: usize;
    // SAFETY: as tib_limit.
    unsafe { std::arch::asm!("mov {}, qword ptr gs:[0x8]", out(reg) base, options(nostack, preserves_flags, readonly)) };
    base
}

fn limits() -> (usize, usize) {
    let (mut low, mut high) = (0, 0);
    // SAFETY: writes the two bounds.
    unsafe { GetCurrentThreadStackLimits(&mut low, &mut high) };
    (low, high)
}

/// The thread's current stack guarantee (SetThreadStackGuarantee of 0 asks).
fn guarantee() -> u32 {
    let mut size = 0u32;
    // SAFETY: a query.
    unsafe { SetThreadStackGuarantee(&mut size) };
    size
}

// ---------------------------------------------------------------------------
// The handler

/// The thread the handler claims (0: any).
static CLAIM: AtomicU32 = AtomicU32::new(0);
/// Where it writes (a HANDLE).
static OUT: AtomicUsize = AtomicUsize::new(0);
/// KiB of stack it uses (1 KiB frames) before it writes.
static BURN: AtomicUsize = AtomicUsize::new(0);
/// 0: terminate with 0x42 after writing; 1: pass the exception on.
static ACTION: AtomicU32 = AtomicU32::new(0);

#[inline(never)]
fn burn_then_write(kib: usize, line: &Line, out: HANDLE) -> bool {
    let pad = std::hint::black_box([0x5au8; 1024]);
    let ok = if kib == 0 { line.write(out) } else { burn_then_write(kib - 1, line, out) };
    std::hint::black_box(&pad);
    ok
}

unsafe extern "system" fn handler(info: *mut EXCEPTION_POINTERS) -> i32 {
    // SAFETY: Windows hands a vectored handler valid pointers.
    let (rec, ctx) = unsafe { (&*(*info).ExceptionRecord, &*(*info).ContextRecord) };
    let code = rec.ExceptionCode;
    if code != EXCEPTION_STACK_OVERFLOW && code != EXCEPTION_ACCESS_VIOLATION {
        return EXCEPTION_CONTINUE_SEARCH;
    }
    let sp = rsp();
    let out = OUT.load(Ordering::Relaxed) as HANDLE;
    // SAFETY: no preconditions.
    let me = unsafe { GetCurrentThreadId() };
    let claim = CLAIM.load(Ordering::Relaxed);
    let mut line = Line::new();
    if claim != 0 && claim != me {
        line.s("handler declined code=").hex(code as u32 as u64).s(" on thread ").dec(me as u64).s(", claims ").dec(claim as u64).s("\n");
        line.write(out);
        return EXCEPTION_CONTINUE_SEARCH;
    }
    let (low, high) = limits();
    let params = rec.NumberParameters as usize;
    line.s("handler code=").hex(code as u32 as u64)
        .s(" flags=").hex(rec.ExceptionFlags as u64)
        .s(" params=").dec(params as u64);
    for i in 0..params.min(4) {
        line.s(" p").dec(i as u64).s("=").hex(rec.ExceptionInformation[i] as u64);
    }
    line.s(" address=").hex(rec.ExceptionAddress as u64)
        .s(" ctx_rsp=").hex(ctx.Rsp)
        .s(" handler_rsp=").hex(sp as u64)
        .s(" dispatch_bytes=").signed(ctx.Rsp as i64 - sp as i64)
        .s(" low=").hex(low as u64)
        .s(" high=").hex(high as u64)
        .s(" tib_limit=").hex(tib_limit() as u64)
        .s(" room_bytes=").signed(sp as i64 - low as i64)
        .s(" ctx_rsp_above_low=").signed(ctx.Rsp as i64 - low as i64);
    if params >= 2 {
        line.s(" fault_above_low=").signed(rec.ExceptionInformation[1] as i64 - low as i64)
            .s(" fault_in_stack=").dec((rec.ExceptionInformation[1] >= low && rec.ExceptionInformation[1] < high) as u64);
    }
    let burn = BURN.load(Ordering::Relaxed);
    line.s(" burned_kib=").dec(burn as u64).s("\n");
    let written = burn_then_write(burn, &line, out);
    if ACTION.load(Ordering::Relaxed) == 1 {
        return EXCEPTION_CONTINUE_SEARCH;
    }
    // SAFETY: ends this process.
    unsafe { TerminateProcess(GetCurrentProcess(), if written { 0x42 } else { 0x43 }) };
    loop {
        std::hint::spin_loop();
    }
}

// ---------------------------------------------------------------------------
// Ways to exhaust a stack

/// Rust recursion with 256-byte frames.
#[inline(never)]
fn exhaust(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust(depth + 1).wrapping_add(frame[depth % 256] as usize)
}

/// Rust recursion with 64 KiB frames (probed by __chkstk).
#[inline(never)]
fn exhaust_wide(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 64 * 1024]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust_wide(depth + 1).wrapping_add(frame[depth % 1024] as usize)
}

/// Cranelift's inline probe loop's access pattern: the stack pointer moved
/// down a page at a time, each page touched at its lowest address, forever.
fn probe_loop() -> ! {
    // SAFETY: deliberately runs off the end of the stack.
    unsafe {
        std::arch::asm!(
            "2:",
            "sub rsp, 4096",
            "mov qword ptr [rsp], 0",
            "jmp 2b",
            options(noreturn)
        )
    }
}

/// Commits at least KIB of stack below the caller (a frame __chkstk probes).
#[inline(never)]
fn commit(kib: usize) {
    let frame = std::hint::black_box([0u8; 256 * 1024]);
    std::hint::black_box(&frame[..kib.min(256) * 1024]);
}

// ---------------------------------------------------------------------------
// Threads

fn on_thread(kind: &str, f: Box<dyn FnOnce() + Send>) {
    match kind {
        "main" => f(),
        "std" => std::thread::Builder::new().stack_size(16 << 20).spawn(f).unwrap().join().unwrap(),
        "raw" => {
            unsafe extern "system" fn start(arg: *mut core::ffi::c_void) -> u32 {
                // SAFETY: ARG is the Box made below, used once.
                let f = unsafe { Box::from_raw(arg as *mut Box<dyn FnOnce() + Send>) };
                f();
                0
            }
            let arg = Box::into_raw(Box::new(f));
            // SAFETY: a thread with a 16 MiB reservation running START once.
            unsafe {
                let thread = CreateThread(std::ptr::null(), 16 << 20, Some(start), arg.cast(), STACK_SIZE_PARAM_IS_A_RESERVATION, std::ptr::null_mut());
                assert!(!thread.is_null(), "CreateThread: {}", GetLastError());
                WaitForSingleObject(thread, INFINITE);
                CloseHandle(thread);
            }
        }
        other => panic!("no thread kind {other}"),
    }
}

fn region(address: usize) -> String {
    let mut info: MEMORY_BASIC_INFORMATION = unsafe { std::mem::zeroed() };
    // SAFETY: a query of this process's own address space.
    let n = unsafe { VirtualQuery(address as *const _, &mut info, std::mem::size_of::<MEMORY_BASIC_INFORMATION>()) };
    if n == 0 {
        return format!("VirtualQuery({address:#x}) failed: {}", unsafe { GetLastError() });
    }
    let state = match info.State {
        0x1000 => "commit",
        0x2000 => "reserve",
        0x10000 => "free",
        _ => "?",
    };
    format!("[{:#x}, {:#x}) {} KiB {state} protect={:#x}{} allocation_base={:#x}",
        info.BaseAddress as usize, info.BaseAddress as usize + info.RegionSize, info.RegionSize / 1024,
        info.Protect, if info.Protect & 0x100 != 0 { " (PAGE_GUARD)" } else { "" }, info.AllocationBase as usize)
}

// ---------------------------------------------------------------------------
// Child scenarios

fn params() -> BTreeMap<String, String> {
    let text = std::env::var("PROBE_CHILD").unwrap_or_default();
    text.split_whitespace()
        .filter_map(|w| w.split_once('=').map(|(k, v)| (k.to_string(), v.to_string())))
        .collect()
}

fn child() -> ! {
    let p = params();
    let get = |k: &str, d: &str| p.get(k).cloned().unwrap_or_else(|| d.to_string());
    let scenario = get("scenario", "");
    let thread = get("thread", "std");
    let set_guarantee: u32 = get("guarantee", "0").parse().unwrap();
    let out = match get("out", "stdout").as_str() {
        // SAFETY: no preconditions.
        "stdout" => unsafe { GetStdHandle(STD_OUTPUT_HANDLE) },
        "stderr" => unsafe { GetStdHandle(STD_ERROR_HANDLE) },
        path => {
            use std::os::windows::io::IntoRawHandle;
            std::fs::File::create(path.strip_prefix("file:").unwrap_or(path)).unwrap().into_raw_handle()
        }
    };
    OUT.store(out as usize, Ordering::Relaxed);
    BURN.store(get("burn", "0").parse().unwrap(), Ordering::Relaxed);
    ACTION.store(if get("action", "terminate") == "continue" { 1 } else { 0 }, Ordering::Relaxed);
    let main_thread = unsafe { GetCurrentThreadId() };
    let claim = get("claim", "self");
    if get("handler", "yes") == "yes" {
        // SAFETY: a handler with the right ABI, first in the chain.
        let h = unsafe { AddVectoredExceptionHandler(1, Some(handler)) };
        assert!(!h.is_null());
    }
    let kind = get("kind", "rust");
    let thread_kind = thread.clone();
    on_thread(&thread_kind, Box::new(move || {
        let before = guarantee();
        let mut set_ok = 1;
        let mut previous = 0;
        if set_guarantee > 0 {
            let mut size = set_guarantee;
            // SAFETY: the calling thread's own guarantee.
            set_ok = unsafe { SetThreadStackGuarantee(&mut size) };
            previous = size;
            if set_ok == 0 {
                println!("SetThreadStackGuarantee({set_guarantee}) failed: error {}", unsafe { GetLastError() });
            }
        }
        let after = guarantee();
        let (low, high) = limits();
        // SAFETY: no preconditions.
        let me = unsafe { GetCurrentThreadId() };
        CLAIM.store(match claim.as_str() { "self" => me, "main" => main_thread, _ => 0 }, Ordering::Relaxed);
        println!("thread {thread} id={me} limits=[{low:#x}, {high:#x}) {} KiB tib=[{:#x}, {:#x}) rsp={:#x} guarantee before={before} set={set_guarantee} ok={set_ok} previous={previous} after={after}",
            (high - low) / 1024, tib_limit(), tib_base(), rsp());
        match scenario.as_str() {
            "facts" => {
                let limit = tib_limit();
                println!("committed: {}", region(limit));
                println!("below it:  {}", region(limit - 1));
                println!("below that:{}", region(limit - 4096 - 1));
                println!("lowest:    {}", region(low));
                commit(128);
                println!("after committing 128 KiB more: tib_limit={:#x} guard {}", tib_limit(), region(tib_limit() - 1));
            }
            "overflow" => {
                let n = match kind.as_str() {
                    "rust" => exhaust(0) as i64,
                    "rust-wide" => exhaust_wide(0) as i64,
                    // SAFETY: C functions of fixture.c.
                    "c" => (unsafe { probe_c_deep(i32::MAX) }) as i64,
                    "c-wide" => (unsafe { probe_c_wide(i32::MAX) }) as i64,
                    "probe-loop" => probe_loop(),
                    other => panic!("no kind {other}"),
                };
                println!("returned {n}");
            }
            "fault" => {
                match kind.as_str() {
                    // SAFETY: deliberately not: a fault is the point.
                    "null" => unsafe { std::hint::black_box(std::ptr::read_volatile(8 as *const u8)); },
                    // The stack's reservation, far below what is committed.
                    "reserved" => unsafe { std::hint::black_box(std::ptr::read_volatile((low + (64 << 10)) as *const u8)); },
                    // The guard page: the stack grows.
                    "guard" => unsafe { std::hint::black_box(std::ptr::read_volatile((tib_limit() - 8) as *const u8)); },
                    "raised-overflow" => unsafe { RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 0, std::ptr::null()) },
                    "raised-overflow-params" => unsafe {
                        let args = [1usize, low + 4096];
                        RaiseException(EXCEPTION_STACK_OVERFLOW as u32, 0, 2, args.as_ptr())
                    },
                    other => panic!("no fault {other}"),
                }
                println!("survived tib_limit={:#x}", tib_limit());
            }
            "stack-use" => stack_use(),
            other => panic!("no scenario {other}"),
        }
    }));
    std::process::exit(0)
}

/// The stack the reporting path itself uses: the region below this frame is
/// painted, the path runs, and the lowest byte it changed is found.
fn stack_use() {
    commit(256);
    let (pipe, file, null) = {
        use std::os::windows::io::IntoRawHandle;
        let file = std::fs::File::create(std::env::temp_dir().join(format!("probe-{}.txt", std::process::id()))).unwrap().into_raw_handle();
        let null = std::fs::OpenOptions::new().write(true).open("NUL").unwrap().into_raw_handle();
        // SAFETY: no preconditions.
        (unsafe { GetStdHandle(STD_OUTPUT_HANDLE) }, file, null)
    };
    let sleeper = Command::new(std::env::current_exe().unwrap()).env("PROBE_CHILD", "scenario=sleep").spawn().unwrap();
    let sleeper_handle = {
        use std::os::windows::io::AsRawHandle;
        sleeper.as_raw_handle()
    };
    let mut line = Line::new();
    line.s("error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}\n");
    for (name, out) in [("pipe", pipe), ("file", file), ("null", null), ("terminate-other", sleeper_handle)] {
        let used = painted(|| {
            if name == "terminate-other" {
                // SAFETY: a child of this process.
                unsafe { TerminateProcess(out, 7) };
            } else {
                line.write(out);
            }
        });
        println!("stack-use {name}: {used} bytes below the caller's stack pointer");
    }
}

const PAINT: usize = 192 << 10;

/// Runs F with the PAINT bytes below this frame painted, and returns how far
/// below the stack pointer F wrote.
#[inline(never)]
fn painted(f: impl FnOnce()) -> usize {
    let sp = rsp();
    let start = sp - PAINT;
    // SAFETY: committed stack below this frame (stack_use committed 256 KiB),
    // painted by an instruction that uses no stack.
    unsafe {
        std::arch::asm!("rep stosb", inout("rdi") start => _, inout("rcx") PAINT - 64 => _, in("al") 0xa5u8, options(nostack, preserves_flags));
    }
    f();
    let mut lowest = sp;
    for address in start..sp - 64 {
        // SAFETY: the painted region.
        if unsafe { std::ptr::read_volatile(address as *const u8) } != 0xa5 {
            lowest = address;
            break;
        }
    }
    sp - lowest
}

// ---------------------------------------------------------------------------
// The parent

struct Outcome {
    code: u32,
    stdout: String,
    stderr: String,
}

fn run(scenario: &str) -> Outcome {
    let output = Command::new(std::env::current_exe().unwrap()).env("PROBE_CHILD", scenario).output().unwrap();
    Outcome {
        code: output.status.code().unwrap_or(-1) as u32,
        stdout: String::from_utf8_lossy(&output.stdout).replace('\r', ""),
        stderr: String::from_utf8_lossy(&output.stderr).replace('\r', ""),
    }
}

fn show(name: &str, o: &Outcome) {
    println!("== {name}");
    println!("   exit {:#010x}", o.code);
    for line in o.stdout.lines() {
        println!("   out: {line}");
    }
    for line in o.stderr.lines() {
        println!("   err: {line}");
    }
}

fn experiment(name: &str, scenario: &str) -> Outcome {
    let o = run(scenario);
    show(&format!("{name}  [{scenario}]"), &o);
    o
}

/// The most KiB the handler can burn and still write and terminate, by a
/// sweep in 1 KiB steps up to MAX (each step its own process).
fn room(base: &str, max: usize) -> (Option<usize>, String) {
    let mut best = None;
    let mut first_failure = String::new();
    for kib in 0..=max {
        let o = run(&format!("{base} burn={kib}"));
        if o.code == 0x42 && o.stdout.contains("handler code=0xc00000fd") {
            best = Some(kib);
        } else {
            first_failure = format!("at {kib} KiB: exit {:#010x}, stdout {:?}, stderr {:?}", o.code,
                o.stdout.lines().last().unwrap_or(""), o.stderr.lines().last().unwrap_or(""));
            break;
        }
    }
    (best, first_failure)
}

pub fn main() {
    if let Ok(scenario) = std::env::var("PROBE_CHILD") {
        if scenario == "scenario=sleep" {
            std::thread::sleep(std::time::Duration::from_secs(60));
            std::process::exit(0);
        }
        child();
    }
    println!("# Windows stack guard probe");
    println!("# {}", std::env::consts::ARCH);
    println!("\n## facts");
    for thread in ["main", "std", "raw"] {
        experiment(&format!("facts {thread}"), &format!("scenario=facts thread={thread}"));
    }

    println!("\n## overflow");
    for kind in ["rust", "rust-wide", "c", "c-wide", "probe-loop"] {
        for thread in ["std", "raw", "main"] {
            experiment(&format!("overflow {kind} on {thread}"), &format!("scenario=overflow kind={kind} thread={thread}"));
        }
    }
    for g in [32768, 65536, 262144] {
        experiment(&format!("overflow rust, guarantee {g}"), &format!("scenario=overflow kind=rust thread=std guarantee={g}"));
        experiment(&format!("overflow rust on raw, guarantee {g}"), &format!("scenario=overflow kind=rust thread=raw guarantee={g}"));
    }
    experiment("guarantee larger than the stack", "scenario=facts thread=std guarantee=33554432");
    experiment("guarantee 1 MiB", "scenario=overflow kind=rust thread=std guarantee=1048576");

    println!("\n## reporting destinations");
    let path = std::env::temp_dir().join(format!("probe-result-{}.txt", std::process::id()));
    let o = experiment("overflow, report to a file", &format!("scenario=overflow kind=rust thread=std out=file:{}", path.display()));
    let written = std::fs::read_to_string(&path).unwrap_or_default();
    println!("   file: {:?} (exit {:#010x})", written.trim(), o.code);
    let _ = std::fs::remove_file(&path);
    experiment("overflow, report to stderr", "scenario=overflow kind=rust thread=std out=stderr");

    println!("\n## room");
    for (name, base) in [
        ("std thread, Rust's guarantee", "scenario=overflow kind=rust thread=std"),
        ("raw thread, no guarantee", "scenario=overflow kind=rust thread=raw"),
        ("std thread, 32 KiB", "scenario=overflow kind=rust thread=std guarantee=32768"),
        ("std thread, 64 KiB", "scenario=overflow kind=rust thread=std guarantee=65536"),
        ("c on std thread, Rust's guarantee", "scenario=overflow kind=c thread=std"),
        ("probe loop on std thread, Rust's guarantee", "scenario=overflow kind=probe-loop thread=std"),
    ] {
        let (best, failure) = room(base, 80);
        println!("room {name}: {} KiB burned and still reported; {failure}", best.map_or("none".to_string(), |b| b.to_string()));
    }

    println!("\n## stack-use");
    experiment("the reporting path's own stack", "scenario=stack-use thread=std handler=no");

    println!("\n## faults");
    for kind in ["null", "reserved", "guard", "raised-overflow", "raised-overflow-params"] {
        experiment(&format!("fault {kind}, report and pass on"), &format!("scenario=fault kind={kind} thread=std action=continue"));
        experiment(&format!("fault {kind}, no handler"), &format!("scenario=fault kind={kind} thread=std handler=no"));
    }
    experiment("overflow on a thread the handler does not claim", "scenario=overflow kind=rust thread=std claim=main");

    println!("\n## unhandled");
    for kind in ["rust", "c", "probe-loop"] {
        experiment(&format!("overflow {kind}, no handler"), &format!("scenario=overflow kind={kind} thread=std handler=no"));
        experiment(&format!("overflow {kind}, handler passes it on"), &format!("scenario=overflow kind={kind} thread=std action=continue"));
    }
    println!("\nprobe finished");
}
}
