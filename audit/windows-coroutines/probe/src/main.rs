//! The Win64 coroutine milestone's experiments (WINDOWS-X86-64-MILESTONE-5.md,
//! "Architecture comparison"). Run on a real Windows x86-64 host:
//!
//! ```text
//!   cargo run --release --manifest-path audit/windows-coroutines/probe/Cargo.toml
//! ```
//!
//! Two ways to give a coroutine a stack of its own on Windows, compared on
//! the same questions:
//!
//!   A. Windows fibers: ConvertThreadToFiberEx, CreateFiberEx, SwitchToFiber,
//!      DeleteFiber, ConvertFiberToThread.
//!   B. a stack switch of our own (`custom_switch`, below): the Win64
//!      callee-saved registers, XMM6-XMM15, MXCSR and the x87 control word
//!      saved on the stack it leaves, on a stack laid out as Windows lays
//!      out a thread's (a reservation, its top committed, a guard page below
//!      that) -- in three variants of what it does with the thread's TEB:
//!      nothing (mode 0), NT_TIB's StackBase and StackLimit, which winnt.h
//!      documents (mode 1), and those plus the TEB's DeallocationStack
//!      (0x1478) and GuaranteedStackBytes (0x1748), which nothing documents
//!      (mode 2).
//!
//! Every experiment runs in a child process -- this executable again, with
//! `PROBE_CHILD` naming the scenario as `key=value` words -- and the parent
//! prints what the child printed and how it ended (its exit code: an
//! NTSTATUS for a process Windows ended). A vectored exception handler
//! (`handler`) first in the chain reports a stack overflow, an access
//! violation, a guard-page violation or a bad stack with one line written by
//! WriteFile -- the record, the stack bounds Windows reports while the
//! handler runs, how much room it has -- and ends the process with
//! TerminateProcess(0x42), or passes the exception on.
//!
//! Lines starting `RESULT` are the probe's findings, one per question.
#[cfg(not(windows))]
fn main() {
    println!("windows-coroutines-probe: Windows x86-64 only");
}

#[cfg(windows)]
fn main() {
    probe::main()
}

#[cfg(windows)]
mod probe {
use std::cell::Cell;
use std::collections::BTreeMap;
use std::ffi::c_void;
use std::process::Command;
use std::sync::atomic::{AtomicU32, AtomicUsize, Ordering};
use std::time::Instant;
use windows_sys::Win32::Foundation::{CloseHandle, GetLastError, HANDLE};
use windows_sys::Win32::Storage::FileSystem::WriteFile;
use windows_sys::Win32::System::Console::{GetStdHandle, STD_OUTPUT_HANDLE};
use windows_sys::Win32::System::Diagnostics::Debug::{
    AddVectoredExceptionHandler, CONTEXT, EXCEPTION_CONTINUE_SEARCH, EXCEPTION_POINTERS, RtlCaptureContext,
    RtlLookupFunctionEntry, RtlVirtualUnwind, UNW_FLAG_NHANDLER,
};
use windows_sys::Win32::System::LibraryLoader::{
    GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, GetModuleFileNameW, GetModuleHandleExW,
};
use windows_sys::Win32::System::WindowsProgramming::FIBER_FLAG_FLOAT_SWITCH;
use windows_sys::Win32::System::Memory::{
    MEM_COMMIT, MEM_RESERVE, MEMORY_BASIC_INFORMATION, PAGE_GUARD, PAGE_READWRITE, VirtualAlloc, VirtualQuery,
};
use windows_sys::Win32::System::Threading::{
    ConvertFiberToThread, ConvertThreadToFiberEx, CreateFiberEx, CreateThread, DeleteFiber, FlsAlloc,
    FlsGetValue, FlsSetValue, GetCurrentProcess, GetCurrentThreadId, GetCurrentThreadStackLimits, GetExitCodeThread, INFINITE,
    IsThreadAFiber, STACK_SIZE_PARAM_IS_A_RESERVATION, SetThreadStackGuarantee, SwitchToFiber, TerminateProcess, TlsAlloc,
    TlsGetValue, TlsSetValue, WaitForSingleObject,
};

unsafe extern "C" {
    fn probe_c_add(a: i64, b: i32, c: i16) -> i64;
    fn probe_c_mix(a: f64, b: i64, c: f64) -> f64;
    fn probe_c_fill(buffer: *mut u8, n: i64, value: i32) -> i64;
    fn probe_set_errno(value: i32);
    fn probe_get_errno() -> i32;
    fn probe_c_deep(n: i32) -> i32;
    fn probe_c_wide(n: i32) -> i32;
}

const STATUS_STACK_OVERFLOW: u32 = 0xC000_00FD;
const STATUS_ACCESS_VIOLATION: u32 = 0xC000_0005;
const STATUS_GUARD_PAGE_VIOLATION: u32 = 0x8000_0001;
const STATUS_BAD_STACK: u32 = 0xC000_0028;
const STATUS_INVALID_UNWIND_TARGET: u32 = 0xC000_0029;
const ERROR_ALREADY_FIBER: u32 = 1280;
/// The guarantee the native stack guard asks for (runtime/platform/windows.rs).
const GUARANTEE: u32 = 32 << 10;
/// A coroutine stack's usable size by default (runtime/coroutine.rs), and
/// the room the guard's guarantee and Windows' last pages take below it.
const USABLE: usize = 8 << 20;
const MARGIN: usize = 64 << 10;

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
        if value < 0 { self.s("-").dec(value.unsigned_abs()) } else { self.dec(value as u64) }
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

// ---------------------------------------------------------------------------
// The thread's view of its stack

#[inline(always)]
fn rsp() -> usize {
    let sp: usize;
    // SAFETY: reads a register.
    unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
    sp
}

/// A TEB field (the TEB's own fields at gs:[OFFSET]): NT_TIB's StackBase at
/// 0x8, StackLimit at 0x10 and FiberData at 0x20 (winnt.h's NT_TIB and its
/// GetCurrentFiber), DeallocationStack at 0x1478 (undocumented).
#[inline(always)]
fn teb(offset: usize) -> usize {
    let value: usize;
    // SAFETY: reads the current thread's TEB.
    unsafe {
        match offset {
            0x8 => std::arch::asm!("mov {}, qword ptr gs:[0x8]", out(reg) value, options(nostack, preserves_flags, readonly)),
            0x10 => std::arch::asm!("mov {}, qword ptr gs:[0x10]", out(reg) value, options(nostack, preserves_flags, readonly)),
            0x20 => std::arch::asm!("mov {}, qword ptr gs:[0x20]", out(reg) value, options(nostack, preserves_flags, readonly)),
            0x1478 => std::arch::asm!("mov {}, qword ptr gs:[0x1478]", out(reg) value, options(nostack, preserves_flags, readonly)),
            _ => unreachable!(),
        }
    }
    value
}

/// The TEB's GuaranteedStackBytes (0x1748, undocumented; a ULONG).
#[inline(always)]
fn teb_guarantee() -> u32 {
    let value: u32;
    // SAFETY: reads the current thread's TEB.
    unsafe { std::arch::asm!("mov {:e}, dword ptr gs:[0x1748]", out(reg) value, options(nostack, preserves_flags, readonly)) };
    value
}

fn current_fiber() -> usize {
    teb(0x20)
}

fn limits() -> (usize, usize) {
    let (mut low, mut high) = (0, 0);
    // SAFETY: writes the two bounds.
    unsafe { GetCurrentThreadStackLimits(&mut low, &mut high) };
    (low, high)
}

/// The calling thread's (or fiber's) stack guarantee.
fn guarantee() -> u32 {
    let mut size = 0u32;
    // SAFETY: a query.
    unsafe { SetThreadStackGuarantee(&mut size) };
    size
}

fn set_guarantee(bytes: u32) -> (bool, u32) {
    let mut size = bytes;
    // SAFETY: the calling thread's (fiber's) own guarantee.
    let ok = unsafe { SetThreadStackGuarantee(&mut size) } != 0;
    (ok, size)
}

fn is_fiber() -> bool {
    // SAFETY: no preconditions.
    unsafe { IsThreadAFiber() != 0 }
}

fn query(address: usize) -> Option<MEMORY_BASIC_INFORMATION> {
    let mut info: MEMORY_BASIC_INFORMATION = unsafe { std::mem::zeroed() };
    // SAFETY: a query of this process's own address space.
    let n = unsafe { VirtualQuery(address as *const _, &mut info, std::mem::size_of::<MEMORY_BASIC_INFORMATION>()) };
    (n != 0).then_some(info)
}

fn region(address: usize) -> String {
    let Some(info) = query(address) else {
        return format!("VirtualQuery({address:#x}) failed: {}", unsafe { GetLastError() });
    };
    let state = match info.State {
        0x1000 => "commit",
        0x2000 => "reserve",
        0x10000 => "free",
        _ => "?",
    };
    format!("[{:#x}, {:#x}) {} KiB {state} protect={:#x}{}",
        info.BaseAddress as usize, info.BaseAddress as usize + info.RegionSize, info.RegionSize / 1024,
        info.Protect, if info.Protect & PAGE_GUARD != 0 { " (PAGE_GUARD)" } else { "" })
}

/// Whether [LOW, HIGH) is a stack Windows grows: an uncommitted reservation
/// at LOW, a committed guard page directly above it (runtime/platform/
/// windows.rs's confirmed_guard_page).
fn guard_page_confirmed(low: usize, high: usize) -> bool {
    let Some(bottom) = query(low) else { return false };
    if bottom.BaseAddress as usize != low || bottom.State != MEM_RESERVE {
        return false;
    }
    let above = low + bottom.RegionSize;
    let Some(guard) = query(above) else { return false };
    guard.BaseAddress as usize == above && above < high && guard.State == MEM_COMMIT && guard.Protect & PAGE_GUARD != 0
}

/// The committed bytes of [LOW, HIGH).
fn committed(low: usize, high: usize) -> usize {
    let mut at = low;
    let mut total = 0;
    while at < high {
        let Some(info) = query(at) else { break };
        let end = (info.BaseAddress as usize + info.RegionSize).min(high);
        if info.State == MEM_COMMIT {
            total += end - at;
        }
        at = end;
    }
    total
}

/// The stack as the running code sees it: GetCurrentThreadStackLimits, the
/// TEB's fields, the stack pointer, the guarantee, the guard page.
fn stack_facts(label: &str) {
    let (low, high) = limits();
    let sp = rsp();
    println!(
        "{label}: limits [{low:#x}, {high:#x}) {} KiB, NT_TIB StackBase {:#x} StackLimit {:#x}, DeallocationStack {:#x}, rsp {} KiB below the top \
         (in limits: {}), guarantee {} (TEB {}), guard page confirmed {}, fiber {} ({:#x})",
        (high - low) / 1024, teb(0x8), teb(0x10), teb(0x1478), (high - sp) / 1024, sp >= low && sp < high, guarantee(),
        teb_guarantee(), guard_page_confirmed(low, high), is_fiber(), if is_fiber() { current_fiber() } else { 0 });
}

// ---------------------------------------------------------------------------
// The handler

/// 0: terminate with 0x42 after writing; 1: pass the exception on.
static ACTION: AtomicU32 = AtomicU32::new(0);
/// KiB of stack it uses (1 KiB frames) before it writes.
static BURN: AtomicUsize = AtomicUsize::new(0);
/// The bounds of the stack the experiment means to exhaust, published
/// before it runs: the handler reports whether the fault lies in them.
static EXPECT_LOW: AtomicUsize = AtomicUsize::new(0);
static EXPECT_HIGH: AtomicUsize = AtomicUsize::new(0);

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
    let code = rec.ExceptionCode as u32;
    if ![STATUS_STACK_OVERFLOW, STATUS_ACCESS_VIOLATION, STATUS_GUARD_PAGE_VIOLATION, STATUS_BAD_STACK, STATUS_INVALID_UNWIND_TARGET]
        .contains(&code)
    {
        return EXCEPTION_CONTINUE_SEARCH;
    }
    let sp = rsp();
    // SAFETY: no preconditions.
    let out = unsafe { GetStdHandle(STD_OUTPUT_HANDLE) };
    let (low, high) = limits();
    let params = rec.NumberParameters as usize;
    let mut line = Line::new();
    line.s("handler code=").hex(code as u64).s(" flags=").hex(rec.ExceptionFlags as u64).s(" params=").dec(params as u64);
    for i in 0..params.min(3) {
        line.s(" p").dec(i as u64).s("=").hex(rec.ExceptionInformation[i] as u64);
    }
    line.s(" ctx_rsp=").hex(ctx.Rsp)
        .s(" limits=[").hex(low as u64).s(",").hex(high as u64).s(")")
        .s(" room_bytes=").signed(sp as i64 - low as i64)
        .s(" dispatch_bytes=").signed(ctx.Rsp as i64 - sp as i64)
        .s(" guarantee=").dec(teb_guarantee() as u64);
    let (elow, ehigh) = (EXPECT_LOW.load(Ordering::Relaxed), EXPECT_HIGH.load(Ordering::Relaxed));
    if params >= 2 && ehigh != 0 {
        let fault = rec.ExceptionInformation[1];
        line.s(" fault_in_expected_stack=").dec((fault >= elow && fault < ehigh) as u64)
            .s(" fault_above_its_low=").signed(fault as i64 - elow as i64)
            .s(" limits_are_expected=").dec((low == elow && high == ehigh) as u64);
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

fn expect_stack(low: usize, high: usize) {
    EXPECT_LOW.store(low, Ordering::Relaxed);
    EXPECT_HIGH.store(high, Ordering::Relaxed);
}

// ---------------------------------------------------------------------------
// Ways to grow and exhaust a stack

#[inline(never)]
fn exhaust(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust(depth + 1).wrapping_add(frame[depth % 256] as usize)
}

#[inline(never)]
fn recurse(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 256]);
    if depth == 0 {
        return 0;
    }
    recurse(depth - 1).wrapping_add(frame[depth % 256] as usize)
}

#[inline(never)]
fn exhaust_wide(depth: usize) -> usize {
    let frame = std::hint::black_box([depth as u8; 64 * 1024]);
    if depth == std::hint::black_box(usize::MAX) {
        return 0;
    }
    exhaust_wide(depth + 1).wrapping_add(frame[depth % 1024] as usize)
}

/// Cranelift's inline probe loop's access pattern, forever.
fn probe_loop() -> ! {
    // SAFETY: deliberately runs off the end of the stack.
    unsafe { std::arch::asm!("2:", "sub rsp, 4096", "mov qword ptr [rsp], 0", "jmp 2b", options(noreturn)) }
}

fn exhaust_by(kind: &str) -> i64 {
    match kind {
        "rust" => exhaust(0) as i64,
        "rust-wide" => exhaust_wide(0) as i64,
        // SAFETY: C functions of fixture.c.
        "c" => (unsafe { probe_c_deep(i32::MAX) }) as i64,
        "c-wide" => (unsafe { probe_c_wide(i32::MAX) }) as i64,
        "probe-loop" => probe_loop(),
        other => panic!("no kind {other}"),
    }
}

// ---------------------------------------------------------------------------
// The registers a switch keeps

/// Calls F(ARGS[0], ARGS[1], ARGS[2]) with RBX, RBP, RSI, RDI, R12-R15 and
/// both halves of XMM6-XMM15 loaded with values derived from SEED, and stores
/// what those registers hold when F returns into OUT: the eight integer
/// registers, then each XMM register's two halves. A switch that suspends
/// inside F and resumes later must give them back; the other side of the
/// switch uses another seed, so a register a switch neither saved nor
/// restored shows.
#[unsafe(naked)]
unsafe extern "C" fn pattern_call(_f: usize, _args: *const usize, _seed: u64, _out: *mut u64) {
    std::arch::naked_asm!(
        "push rbp", "push rbx", "push rdi", "push rsi", "push r12", "push r13", "push r14", "push r15",
        "sub rsp, 216",
        "movaps [rsp + 32], xmm6", "movaps [rsp + 48], xmm7", "movaps [rsp + 64], xmm8", "movaps [rsp + 80], xmm9",
        "movaps [rsp + 96], xmm10", "movaps [rsp + 112], xmm11", "movaps [rsp + 128], xmm12", "movaps [rsp + 144], xmm13",
        "movaps [rsp + 160], xmm14", "movaps [rsp + 176], xmm15",
        "mov [rsp + 192], r8",
        "mov [rsp + 200], r9",
        "mov rax, rcx",
        "mov r9, rdx",
        "lea rbx, [r8 + 1]", "lea rbp, [r8 + 2]", "lea rsi, [r8 + 3]", "lea rdi, [r8 + 4]",
        "lea r12, [r8 + 5]", "lea r13, [r8 + 6]", "lea r14, [r8 + 7]", "lea r15, [r8 + 8]",
        "lea r10, [r8 + 0x16]", "lea r11, [r8 + 0x26]", "movq xmm6, r10", "movq xmm0, r11", "punpcklqdq xmm6, xmm0",
        "lea r10, [r8 + 0x17]", "lea r11, [r8 + 0x27]", "movq xmm7, r10", "movq xmm0, r11", "punpcklqdq xmm7, xmm0",
        "lea r10, [r8 + 0x18]", "lea r11, [r8 + 0x28]", "movq xmm8, r10", "movq xmm0, r11", "punpcklqdq xmm8, xmm0",
        "lea r10, [r8 + 0x19]", "lea r11, [r8 + 0x29]", "movq xmm9, r10", "movq xmm0, r11", "punpcklqdq xmm9, xmm0",
        "lea r10, [r8 + 0x1a]", "lea r11, [r8 + 0x2a]", "movq xmm10, r10", "movq xmm0, r11", "punpcklqdq xmm10, xmm0",
        "lea r10, [r8 + 0x1b]", "lea r11, [r8 + 0x2b]", "movq xmm11, r10", "movq xmm0, r11", "punpcklqdq xmm11, xmm0",
        "lea r10, [r8 + 0x1c]", "lea r11, [r8 + 0x2c]", "movq xmm12, r10", "movq xmm0, r11", "punpcklqdq xmm12, xmm0",
        "lea r10, [r8 + 0x1d]", "lea r11, [r8 + 0x2d]", "movq xmm13, r10", "movq xmm0, r11", "punpcklqdq xmm13, xmm0",
        "lea r10, [r8 + 0x1e]", "lea r11, [r8 + 0x2e]", "movq xmm14, r10", "movq xmm0, r11", "punpcklqdq xmm14, xmm0",
        "lea r10, [r8 + 0x1f]", "lea r11, [r8 + 0x2f]", "movq xmm15, r10", "movq xmm0, r11", "punpcklqdq xmm15, xmm0",
        "mov rcx, [r9]", "mov rdx, [r9 + 8]", "mov r8, [r9 + 16]",
        "call rax",
        "mov r9, [rsp + 200]",
        "mov [r9], rbx", "mov [r9 + 8], rbp", "mov [r9 + 16], rsi", "mov [r9 + 24], rdi",
        "mov [r9 + 32], r12", "mov [r9 + 40], r13", "mov [r9 + 48], r14", "mov [r9 + 56], r15",
        "movdqu [r9 + 64], xmm6", "movdqu [r9 + 80], xmm7", "movdqu [r9 + 96], xmm8", "movdqu [r9 + 112], xmm9",
        "movdqu [r9 + 128], xmm10", "movdqu [r9 + 144], xmm11", "movdqu [r9 + 160], xmm12", "movdqu [r9 + 176], xmm13",
        "movdqu [r9 + 192], xmm14", "movdqu [r9 + 208], xmm15",
        "movaps xmm6, [rsp + 32]", "movaps xmm7, [rsp + 48]", "movaps xmm8, [rsp + 64]", "movaps xmm9, [rsp + 80]",
        "movaps xmm10, [rsp + 96]", "movaps xmm11, [rsp + 112]", "movaps xmm12, [rsp + 128]", "movaps xmm13, [rsp + 144]",
        "movaps xmm14, [rsp + 160]", "movaps xmm15, [rsp + 176]",
        "add rsp, 216",
        "pop r15", "pop r14", "pop r13", "pop r12", "pop rsi", "pop rdi", "pop rbx", "pop rbp",
        "ret",
    )
}

const REGISTER_NAMES: [&str; 8] = ["rbx", "rbp", "rsi", "rdi", "r12", "r13", "r14", "r15"];

/// The registers of a pattern_call with SEED that came back changed.
fn changed(seed: u64, out: &[u64; 28]) -> Vec<String> {
    let mut names = Vec::new();
    for (i, name) in REGISTER_NAMES.iter().enumerate() {
        if out[i] != seed + 1 + i as u64 {
            names.push(name.to_string());
        }
    }
    for x in 0..10u64 {
        let (low, high) = (out[8 + 2 * x as usize], out[9 + 2 * x as usize]);
        if low != seed + 0x16 + x {
            names.push(format!("xmm{}.low", 6 + x));
        }
        if high != seed + 0x26 + x {
            names.push(format!("xmm{}.high", 6 + x));
        }
    }
    names
}

fn pattern(f: usize, args: [usize; 3], seed: u64) -> Vec<String> {
    let mut out = [0u64; 28];
    // SAFETY: F is a function of three integer arguments that returns.
    unsafe { pattern_call(f, args.as_ptr(), seed, out.as_mut_ptr()) };
    changed(seed, &out)
}

fn mxcsr() -> u32 {
    let mut value = 0u32;
    // SAFETY: stores MXCSR into a local.
    unsafe { std::arch::asm!("stmxcsr [{}]", in(reg) &mut value, options(nostack, preserves_flags)) };
    value
}

fn set_mxcsr(value: u32) {
    // SAFETY: loads MXCSR from a local (a valid value: the default's flags).
    unsafe { std::arch::asm!("ldmxcsr [{}]", in(reg) &value, options(nostack, preserves_flags)) };
}

fn fpcw() -> u16 {
    let mut value = 0u16;
    // SAFETY: stores the x87 control word into a local.
    unsafe { std::arch::asm!("fnstcw [{}]", in(reg) &mut value, options(nostack, preserves_flags)) };
    value
}

fn set_fpcw(value: u16) {
    // SAFETY: loads the x87 control word from a local.
    unsafe { std::arch::asm!("fldcw [{}]", in(reg) &value, options(nostack, preserves_flags)) };
}

/// Rounding toward zero (MXCSR's RC, bits 13-14), and the x87's 24-bit
/// precision: what a context changes so that the other one can see it leak.
const MXCSR_TOWARD_ZERO: u32 = 0x1F80 | 0x6000;
const FPCW_SINGLE: u16 = 0x007F;

// ---------------------------------------------------------------------------
// Fibers (strategy A)

static MAIN: AtomicUsize = AtomicUsize::new(0);
static OTHER: AtomicUsize = AtomicUsize::new(0);

fn main_fiber() -> *mut c_void {
    MAIN.load(Ordering::Relaxed) as *mut c_void
}

fn to(fiber: *mut c_void) {
    // SAFETY: a fiber of this thread that is not running.
    unsafe { SwitchToFiber(fiber) };
}

fn back() {
    to(main_fiber());
}

fn convert(flags: u32) -> *mut c_void {
    // SAFETY: converts the calling thread.
    let main = unsafe { ConvertThreadToFiberEx(std::ptr::null(), flags) };
    assert!(!main.is_null(), "ConvertThreadToFiberEx: error {}", unsafe { GetLastError() });
    MAIN.store(main as usize, Ordering::Relaxed);
    main
}

struct Job {
    f: Option<Box<dyn FnOnce()>>,
}

unsafe extern "system" fn fiber_proc(param: *mut c_void) {
    // SAFETY: PARAM is the Job `fiber` leaked for this fiber.
    let job = unsafe { &mut *(param as *mut Job) };
    if let Some(f) = job.f.take() {
        f();
    }
    loop {
        back();
    }
}

/// A fiber that runs F (then switches to the main fiber for good).
fn fiber_with(commit: usize, reserve: usize, flags: u32, f: impl FnOnce() + 'static) -> *mut c_void {
    let job = Box::into_raw(Box::new(Job { f: Some(Box::new(f)) }));
    // SAFETY: a fiber of FIBER_PROC, whose parameter is leaked for its life.
    let fiber = unsafe { CreateFiberEx(commit, reserve, flags, Some(fiber_proc), job as *const c_void) };
    assert!(!fiber.is_null(), "CreateFiberEx: error {}", unsafe { GetLastError() });
    fiber
}

/// A fiber as the runtime makes them: 64 KiB committed, the usable size plus
/// the margin reserved, the floating-point state switched.
fn fiber(f: impl FnOnce() + 'static) -> *mut c_void {
    fiber_with(64 << 10, USABLE + MARGIN, FIBER_FLAG_FLOAT_SWITCH, f)
}

// ---------------------------------------------------------------------------
// The production design's pieces (runtime/coroutine.rs, Windows): the entry
// stub every coroutine fiber starts in, which records the stack pointer its
// bodies start from; the restart that starts a body there again on a fiber
// that was parked mid-body; the switch that records where it left (the
// collector's start for a suspended stack).

/// A parked fiber's next start: the stack pointer of its entry stub's call,
/// and the function and argument to enter there.
#[repr(C)]
struct Slot {
    top: usize,
    f: usize,
    arg: usize,
}

std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".def probe_fiber_entry",
    ".scl 2",
    ".type 32",
    ".endef",
    ".globl probe_fiber_entry",
    ".seh_proc probe_fiber_entry",
    "probe_fiber_entry:",
    "sub rsp, 40",
    ".seh_stackalloc 40",
    ".seh_endprologue",
    "mov qword ptr [rcx], rsp",
    "mov rax, qword ptr [rcx + 8]",
    "mov rcx, qword ptr [rcx + 16]",
    "call rax",
    "probe_fiber_return:",
    "int3",
    ".seh_endproc",
    "",
    ".p2align 4",
    ".def probe_fiber_restart",
    ".scl 2",
    ".type 32",
    ".endef",
    ".globl probe_fiber_restart",
    "probe_fiber_restart:",
    "mov rsp, qword ptr [rcx]",
    "lea rax, [rip + probe_fiber_return]",
    "push rax",
    "mov rax, qword ptr [rcx + 8]",
    "mov rcx, qword ptr [rcx + 16]",
    "jmp rax",
);

unsafe extern "C" {
    fn probe_fiber_entry(slot: *mut Slot);
    fn probe_fiber_restart(slot: *const Slot) -> !;
}

/// Where a context switched away: its fiber and the frame that switched.
#[derive(Clone, Copy, Default, Debug)]
struct Switched {
    fiber: usize,
    rip: u64,
    rsp: u64,
    rbp: u64,
}

thread_local! {
    /// A start of the fiber switched to: the Slot to restart it from.
    static RESTART: Cell<usize> = const { Cell::new(0) };
}

/// The production switch: records where it leaves, switches, and -- arrived
/// back -- restarts this fiber when what switched to it was a start.
#[inline(never)]
unsafe fn switch(save: *mut Switched, to_fiber: usize, restart: Option<*const Slot>) {
    let (rip, sp, bp): (u64, u64, u64);
    // SAFETY: reads registers.
    unsafe {
        std::arch::asm!("lea {}, [rip]", "mov {}, rsp", "mov {}, rbp", out(reg) rip, out(reg) sp, out(reg) bp,
            options(nomem, nostack, preserves_flags));
        *save = Switched { fiber: current_fiber(), rip, rsp: sp, rbp: bp };
    }
    if let Some(slot) = restart {
        RESTART.with(|r| r.set(slot as usize));
    }
    to(to_fiber as *mut c_void);
    let slot = RESTART.with(|r| r.replace(0));
    if slot != 0 {
        // SAFETY: the Slot of this fiber, whose top is its entry's.
        unsafe { probe_fiber_restart(slot as *const Slot) }
    }
}

/// Windows' virtual unwind from CONTEXT upward, within [LOW, HIGH): one
/// line per frame -- its RIP, the module it is in, its RSP's distance below
/// HIGH -- and how the walk ended.
fn walk(label: &str, mut context: Box<AlignedContext>, low: usize, high: usize) -> (usize, String) {
    let mut frames = 0;
    let end;
    loop {
        let (pc, sp) = (context.0.Rip, context.0.Rsp as usize);
        if pc == 0 {
            end = format!("a zero return address, rsp {} bytes below the top", high as i64 - sp as i64);
            break;
        }
        if sp < low || sp >= high {
            end = format!("rsp {sp:#x} outside the stack");
            break;
        }
        if frames >= 64 {
            end = "64 frames, no end".to_string();
            break;
        }
        println!("  {label} frame {frames}: rip {pc:#x} ({}) rsp {} bytes below the top", module_of(pc as usize), high - sp);
        let mut image_base = 0u64;
        // SAFETY: looks up and applies unwind information of this process's code.
        unsafe {
            let entry = RtlLookupFunctionEntry(pc, &mut image_base, std::ptr::null_mut());
            if entry.is_null() {
                context.0.Rip = *(context.0.Rsp as *const u64);
                context.0.Rsp += 8;
            } else {
                let mut handler_data = std::ptr::null_mut();
                let mut establisher = 0u64;
                RtlVirtualUnwind(UNW_FLAG_NHANDLER, image_base, pc, entry, &mut context.0, &mut handler_data, &mut establisher,
                    std::ptr::null_mut());
            }
        }
        frames += 1;
        if (context.0.Rsp as usize) <= sp {
            end = "rsp did not ascend".to_string();
            break;
        }
    }
    println!("  {label}: {frames} frames, ended at {end}");
    (frames, end)
}

#[repr(C, align(16))]
struct AlignedContext(CONTEXT);

fn captured() -> Box<AlignedContext> {
    // SAFETY: CONTEXT is plain data.
    let mut context: Box<AlignedContext> = Box::new(unsafe { std::mem::zeroed() });
    // SAFETY: fills it with the caller's context.
    unsafe { RtlCaptureContext(&mut context.0) };
    context
}

fn context_of(switched: &Switched) -> Box<AlignedContext> {
    // SAFETY: CONTEXT is plain data.
    let mut context: Box<AlignedContext> = Box::new(unsafe { std::mem::zeroed() });
    context.0.Rip = switched.rip;
    context.0.Rsp = switched.rsp;
    context.0.Rbp = switched.rbp;
    context
}

fn module_of(address: usize) -> String {
    let mut module = std::ptr::null_mut();
    // SAFETY: looks up the module containing ADDRESS, without a reference.
    let ok = unsafe {
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
            address as *const u16, &mut module)
    };
    if ok == 0 {
        return "no module".to_string();
    }
    let mut name = [0u16; 260];
    // SAFETY: writes at most 260 units.
    let n = unsafe { GetModuleFileNameW(module, name.as_mut_ptr(), 260) } as usize;
    let path = String::from_utf16_lossy(&name[..n]);
    let file = path.rsplit('\\').next().unwrap_or(&path).to_string();
    format!("{file}+{:#x}", address - module as usize)
}

// ---------------------------------------------------------------------------
// The custom switch (strategy B)

std::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl probe_custom_switch",
    "probe_custom_switch:",
    // rcx: where to store this context's stack pointer; rdx: the stack
    // pointer of the context to continue; r8: the TEB mode (0, 1, 2).
    "push rbp", "push rbx", "push rdi", "push rsi", "push r12", "push r13", "push r14", "push r15",
    "sub rsp, 200",
    "movaps [rsp], xmm6", "movaps [rsp + 16], xmm7", "movaps [rsp + 32], xmm8", "movaps [rsp + 48], xmm9",
    "movaps [rsp + 64], xmm10", "movaps [rsp + 80], xmm11", "movaps [rsp + 96], xmm12", "movaps [rsp + 112], xmm13",
    "movaps [rsp + 128], xmm14", "movaps [rsp + 144], xmm15",
    "stmxcsr [rsp + 160]",
    "fnstcw [rsp + 164]",
    "mov rax, qword ptr gs:[0x8]", "mov [rsp + 168], rax",
    "mov rax, qword ptr gs:[0x10]", "mov [rsp + 176], rax",
    "mov rax, qword ptr gs:[0x1478]", "mov [rsp + 184], rax",
    "mov eax, dword ptr gs:[0x1748]", "mov [rsp + 192], rax",
    "mov [rcx], rsp",
    "mov rsp, rdx",
    "cmp r8, 1",
    "jb 2f",
    "mov rax, [rsp + 168]", "mov qword ptr gs:[0x8], rax",
    "mov rax, [rsp + 176]", "mov qword ptr gs:[0x10], rax",
    "cmp r8, 2",
    "jb 2f",
    "mov rax, [rsp + 184]", "mov qword ptr gs:[0x1478], rax",
    "mov rax, [rsp + 192]", "mov dword ptr gs:[0x1748], eax",
    "2:",
    "ldmxcsr [rsp + 160]",
    "fldcw [rsp + 164]",
    "movaps xmm6, [rsp]", "movaps xmm7, [rsp + 16]", "movaps xmm8, [rsp + 32]", "movaps xmm9, [rsp + 48]",
    "movaps xmm10, [rsp + 64]", "movaps xmm11, [rsp + 80]", "movaps xmm12, [rsp + 96]", "movaps xmm13, [rsp + 112]",
    "movaps xmm14, [rsp + 128]", "movaps xmm15, [rsp + 144]",
    "add rsp, 200",
    "pop r15", "pop r14", "pop r13", "pop r12", "pop rsi", "pop rdi", "pop rbx", "pop rbp",
    "ret",
    "",
    // A fresh custom stack's first frame: entered by the switch's ret, with
    // r12 the body and r13 its argument; its own return address is the zero
    // the stack was prepared with (the end of the stack's chain).
    ".p2align 4",
    ".def probe_custom_trampoline",
    ".scl 2",
    ".type 32",
    ".endef",
    ".globl probe_custom_trampoline",
    ".seh_proc probe_custom_trampoline",
    "probe_custom_trampoline:",
    "sub rsp, 32",
    ".seh_stackalloc 32",
    ".seh_endprologue",
    "mov rcx, r13",
    "call r12",
    "int3",
    ".seh_endproc",
);

unsafe extern "C" {
    fn probe_custom_switch(save: *mut usize, load: usize, mode: usize);
    fn probe_custom_trampoline();
}

/// A stack laid out as Windows lays out a thread's: RESERVE bytes reserved,
/// the top COMMIT bytes committed, a guard page below them.
struct CustomStack {
    base: usize,
    top: usize,
    limit: usize,
}

fn custom_stack(reserve: usize, commit: usize) -> CustomStack {
    // SAFETY: a fresh private reservation, committed at its top.
    unsafe {
        let base = VirtualAlloc(std::ptr::null(), reserve, MEM_RESERVE, PAGE_READWRITE) as usize;
        assert!(base != 0, "VirtualAlloc: error {}", GetLastError());
        let top = base + reserve;
        let limit = top - commit;
        assert!(!VirtualAlloc(limit as *const c_void, commit, MEM_COMMIT, PAGE_READWRITE).is_null());
        assert!(!VirtualAlloc((limit - 4096) as *const c_void, 4096, MEM_COMMIT, PAGE_READWRITE | PAGE_GUARD).is_null());
        CustomStack { base, top, limit }
    }
}

/// Lays STACK out so that switching to it enters probe_custom_trampoline,
/// which calls BODY(ARG); the TEB fields the switch loads (modes 1 and 2)
/// describe STACK, with GUARANTEE_BYTES its guarantee.
fn prepare(stack: &CustomStack, body: extern "C" fn(usize) -> !, arg: usize, guarantee_bytes: u32) -> usize {
    // The switch's frame, lowest address first: 10 XMM registers (160),
    // MXCSR and the x87 control word (8), the four TEB fields (32), then r15
    // ... rbp (64) and the return address; above it the trampoline's own
    // (zero) return address.
    let sp = (stack.top - 16) & !15;
    let sp = sp - 272;
    let mut words = [0u64; 35];
    words[20] = 0x1F80 | (0x027F << 32);
    words[21] = stack.top as u64;
    words[22] = stack.limit as u64;
    words[23] = stack.base as u64;
    words[24] = guarantee_bytes as u64;
    // r15, r14, r13 (ARG), r12 (BODY), rsi, rdi, rbx, rbp.
    words[27] = arg as u64;
    words[28] = body as usize as u64;
    words[33] = probe_custom_trampoline as *const () as usize as u64;
    words[34] = 0;
    for (i, word) in words.iter().enumerate() {
        // SAFETY: the committed top of a stack nothing else uses.
        unsafe { *((sp + 8 * i) as *mut u64) = *word };
    }
    sp
}

static CUSTOM_MAIN: AtomicUsize = AtomicUsize::new(0);
static CUSTOM_SAVED: AtomicUsize = AtomicUsize::new(0);
static CUSTOM_MODE: AtomicUsize = AtomicUsize::new(0);

/// The arguments of a switch from the custom stack back to the thread's own
/// (`probe_custom_switch`'s: where to save, what to load, the mode).
fn custom_back_args() -> [usize; 3] {
    [CUSTOM_SAVED.as_ptr() as usize, CUSTOM_MAIN.load(Ordering::Relaxed), CUSTOM_MODE.load(Ordering::Relaxed)]
}

/// The same from the thread's stack to the custom stack's saved context.
fn custom_to_args() -> [usize; 3] {
    [CUSTOM_MAIN.as_ptr() as usize, CUSTOM_SAVED.load(Ordering::Relaxed), CUSTOM_MODE.load(Ordering::Relaxed)]
}

fn custom_back() {
    let [save, load, mode] = custom_back_args();
    // SAFETY: the thread's context, saved by the switch that entered here.
    unsafe { probe_custom_switch(save as *mut usize, load, mode) };
}

fn custom_to() {
    let [save, load, mode] = custom_to_args();
    // SAFETY: the custom stack's saved context.
    unsafe { probe_custom_switch(save as *mut usize, load, mode) };
}

static CUSTOM_KIND: std::sync::Mutex<String> = std::sync::Mutex::new(String::new());

extern "C" fn custom_body(_arg: usize) -> ! {
    let kind = CUSTOM_KIND.lock().unwrap().clone();
    let mode = CUSTOM_MODE.load(Ordering::Relaxed);
    match kind.as_str() {
        "facts" => {
            stack_facts(&format!("custom stack (mode {mode})"));
            custom_back();
            stack_facts(&format!("custom stack again (mode {mode})"));
        }
        "grow" => {
            let before = teb(0x10);
            let n = recurse(8192);
            println!("custom stack (mode {mode}) grew 2 MiB: returned {n}, StackLimit {before:#x} -> {:#x}", teb(0x10));
        }
        "overflow" | "overflow-c" | "overflow-probe-loop" => {
            let (low, high) = (CUSTOM_LOW.load(Ordering::Relaxed), CUSTOM_HIGH.load(Ordering::Relaxed));
            expect_stack(low, high);
            let way = match kind.as_str() { "overflow-c" => "c", "overflow-probe-loop" => "probe-loop", _ => "rust" };
            println!("returned {}", exhaust_by(way));
        }
        "panic" => {
            let caught = std::panic::catch_unwind(|| {
                std::panic::panic_any(7u32);
            });
            println!("custom stack (mode {mode}): a panic caught on it: {:?}", caught.map_err(|e| e.downcast_ref::<u32>().copied()));
        }
        "unwind" => {
            let (low, high) = (CUSTOM_LOW.load(Ordering::Relaxed), CUSTOM_HIGH.load(Ordering::Relaxed));
            let (frames, end) = walk(&format!("custom (mode {mode})"), captured(), low, high);
            println!("RESULT custom mode {mode} unwind from inside: {frames} frames, {end}");
        }
        "call" => {
            // SAFETY: fixture.c's functions.
            let r = unsafe { (probe_c_add(1 << 40, -3, 7), probe_c_mix(1.5, 4, 0.25), probe_c_deep(20000), probe_c_wide(16)) };
            println!("custom stack (mode {mode}): C calls {r:?}");
        }
        "regs" => {
            let mut all = Vec::new();
            for round in 0..3 {
                let changed = pattern(probe_custom_switch as *const () as usize, custom_back_args(), 0x2000_0000 + round);
                println!("custom stack (mode {mode}) side, round {round}: changed {changed:?}");
                all.extend(changed);
            }
            println!("RESULT custom mode {mode} keeps the custom side's callee-saved registers: changed {all:?}");
        }
        "float" => {
            set_mxcsr(MXCSR_TOWARD_ZERO);
            set_fpcw(FPCW_SINGLE);
            custom_back();
            println!("RESULT custom mode {mode}: the custom stack after a round trip: mxcsr {:#x} fpcw {:#x} (set {MXCSR_TOWARD_ZERO:#x} {FPCW_SINGLE:#x})", mxcsr(), fpcw());
        }
        "perf" => loop {
            custom_back();
        },
        other => println!("no custom kind {other}"),
    }
    loop {
        custom_back();
    }
}

static CUSTOM_LOW: AtomicUsize = AtomicUsize::new(0);
static CUSTOM_HIGH: AtomicUsize = AtomicUsize::new(0);

fn custom(mode: usize, kind: &str) {
    *CUSTOM_KIND.lock().unwrap() = kind.to_string();
    CUSTOM_MODE.store(mode, Ordering::Relaxed);
    let stack = custom_stack(USABLE + MARGIN, 64 << 10);
    CUSTOM_LOW.store(stack.base, Ordering::Relaxed);
    CUSTOM_HIGH.store(stack.top, Ordering::Relaxed);
    let thread_before = limits();
    CUSTOM_SAVED.store(prepare(&stack, custom_body, 0, GUARANTEE), Ordering::Relaxed);
    custom_to();
    match kind {
        "facts" => {
            stack_facts(&format!("thread after the custom stack switched back (mode {mode})"));
            custom_to();
            println!("RESULT custom mode {mode}: thread limits restored after switches: {}", limits() == thread_before);
        }
        "regs" => {
            let mut all = Vec::new();
            for round in 0..3 {
                let changed = pattern(probe_custom_switch as *const () as usize, custom_to_args(), 0x1000_0000 + round);
                println!("thread side, round {round}: changed {changed:?}");
                all.extend(changed);
            }
            println!("RESULT custom mode {mode} keeps the thread side's callee-saved registers: changed {all:?}");
            custom_to();
        }
        "float" => {
            println!("RESULT custom mode {mode}: the thread after the custom stack set its rounding: mxcsr {:#x} fpcw {:#x}", mxcsr(), fpcw());
            custom_to();
        }
        "perf" => {
            let n = 2_000_000;
            let started = Instant::now();
            for _ in 0..n {
                custom_to();
            }
            let ns = started.elapsed().as_nanos() as f64 / n as f64;
            println!("RESULT custom mode {mode} round trip (thread -> custom -> thread): {ns:.1} ns");
        }
        _ => {}
    }
}

// ---------------------------------------------------------------------------
// Child scenarios

fn params() -> BTreeMap<String, String> {
    let text = std::env::var("PROBE_CHILD").unwrap_or_default();
    text.split_whitespace().filter_map(|w| w.split_once('=').map(|(k, v)| (k.to_string(), v.to_string()))).collect()
}

/// Runs F on a thread made by CreateThread (a 16 MiB reservation), and
/// returns its exit code.
fn on_raw_thread(f: Box<dyn FnOnce() + Send>) -> u32 {
    unsafe extern "system" fn start(arg: *mut c_void) -> u32 {
        // SAFETY: ARG is the Box made below, used once.
        let f = unsafe { Box::from_raw(arg as *mut Box<dyn FnOnce() + Send>) };
        f();
        0
    }
    let arg = Box::into_raw(Box::new(f));
    // SAFETY: a thread running START once, waited for.
    unsafe {
        let thread = CreateThread(std::ptr::null(), 16 << 20, Some(start), arg.cast(), STACK_SIZE_PARAM_IS_A_RESERVATION, std::ptr::null_mut());
        assert!(!thread.is_null(), "CreateThread: {}", GetLastError());
        WaitForSingleObject(thread, INFINITE);
        let mut code = 0u32;
        GetExitCodeThread(thread, &mut code);
        CloseHandle(thread);
        code
    }
}

fn on_thread(kind: &str, f: impl FnOnce() + Send + 'static) {
    match kind {
        "main" => f(),
        "std" => std::thread::Builder::new().stack_size(16 << 20).spawn(f).unwrap().join().unwrap(),
        "raw" => {
            on_raw_thread(Box::new(f));
        }
        other => panic!("no thread {other}"),
    }
}

thread_local! {
    static RUST_TLS: Cell<u32> = const { Cell::new(0) };
}
static FLS_CALLED: AtomicUsize = AtomicUsize::new(0);
static FLS_VALUE: AtomicUsize = AtomicUsize::new(0);

unsafe extern "system" fn fls_callback(data: *const c_void) {
    FLS_CALLED.fetch_add(1, Ordering::Relaxed);
    FLS_VALUE.store(data as usize, Ordering::Relaxed);
}

fn child() -> ! {
    let p = params();
    let get = |k: &str, d: &str| p.get(k).cloned().unwrap_or_else(|| d.to_string());
    let scenario = get("scenario", "");
    BURN.store(get("burn", "0").parse().unwrap(), Ordering::Relaxed);
    ACTION.store(if get("action", "terminate") == "continue" { 1 } else { 0 }, Ordering::Relaxed);
    if get("handler", "yes") == "yes" {
        // SAFETY: a handler with the right ABI, first in the chain.
        assert!(!unsafe { AddVectoredExceptionHandler(1, Some(handler)) }.is_null());
    }
    let thread = get("thread", "std");
    let flags: u32 = if get("float", "1") == "1" { FIBER_FLAG_FLOAT_SWITCH } else { 0 };
    let kind = get("kind", "");
    let guarantee_bytes: u32 = get("guarantee", &GUARANTEE.to_string()).parse().unwrap();
    let mode: usize = get("mode", "0").parse().unwrap();
    let nested = get("nested", "0") == "1";
    on_thread(&thread, move || match scenario.as_str() {
        "fiber-facts" => fiber_facts(flags),
        "fiber-regs" => fiber_regs(flags),
        "fiber-tls" => fiber_tls(),
        "fiber-calls" => fiber_calls(),
        "fiber-unwind" => fiber_unwind(),
        "fiber-overflow" => fiber_overflow(&kind, guarantee_bytes, nested),
        "thread-overflow-after-fibers" => thread_overflow_after_fibers(),
        "fiber-lifetime" => fiber_lifetime(&kind),
        "fiber-perf" => fiber_perf(),
        "custom" => custom(mode, &kind),
        other => println!("no scenario {other}"),
    });
    std::process::exit(0)
}

fn fiber_facts(flags: u32) {
    stack_facts("thread before conversion");
    let (thread_low, thread_high) = limits();
    let thread_guarantee = guarantee();
    let main = convert(flags);
    println!("RESULT conversion: IsThreadAFiber {}, GetCurrentFiber (NT_TIB FiberData) is ConvertThreadToFiberEx's result: {}",
        is_fiber(), current_fiber() == main as usize);
    // SAFETY: a second conversion of a converted thread.
    let again = unsafe { ConvertThreadToFiberEx(std::ptr::null(), flags) };
    println!("RESULT a second ConvertThreadToFiberEx: {:?}, error {} (ERROR_ALREADY_FIBER is {ERROR_ALREADY_FIBER})", again, unsafe { GetLastError() });
    stack_facts("thread after conversion");
    let facts = std::rc::Rc::new(Cell::new((0usize, 0usize)));
    let seen = facts.clone();
    let a = fiber(move || {
        stack_facts("fiber, first entry");
        let (low, high) = limits();
        seen.set((low, high));
        println!("RESULT a fiber's reservation: {} KiB asked {} KiB; guard page confirmed {}; committed {} KiB; default guarantee {}",
            (high - low) / 1024, (USABLE + MARGIN) / 1024, guard_page_confirmed(low, high), committed(low, high) / 1024, guarantee());
        let (ok, previous) = set_guarantee(GUARANTEE);
        println!("RESULT SetThreadStackGuarantee({GUARANTEE}) on a fiber: ok {ok}, previous {previous}, now {} (TEB {}); guard page confirmed {}",
            guarantee(), teb_guarantee(), guard_page_confirmed(low, high));
        back();
        println!("RESULT a fiber's guarantee after a round trip to the thread's: {}", guarantee());
        stack_facts("fiber, resumed");
        let before = teb(0x10);
        let n = recurse(8192);
        println!("RESULT a fiber's stack grows by its guard page: 2 MiB of frames returned {n}, StackLimit {before:#x} -> {:#x}, \
                  guard page confirmed {}, committed {} KiB", teb(0x10), guard_page_confirmed(low, high), committed(low, high) / 1024);
        back();
    });
    to(a);
    let (low, high) = facts.get();
    println!("RESULT the thread's stack and guarantee after a fiber set its own: limits restored {}, guarantee {} (was {thread_guarantee})",
        limits() == (thread_low, thread_high), guarantee());
    to(a);
    to(a);
    stack_facts("thread after the fiber grew");
    println!("fiber reservation from the thread: low {}, guard {}", region(low), region(teb_region_above(low)));
    // SAFETY: a suspended fiber of this thread.
    unsafe { DeleteFiber(a) };
    println!("RESULT DeleteFiber of a suspended fiber: its reservation is now {}", region(low));
    let _ = high;
    // A fiber created from a fiber, with the default sizes.
    let b = fiber_with(0, 0, flags, || {
        let (low, high) = limits();
        println!("RESULT a fiber with the default sizes: {} KiB reserved, {} KiB committed, guard page confirmed {}",
            (high - low) / 1024, committed(low, high) / 1024, guard_page_confirmed(low, high));
        back();
    });
    to(b);
    // SAFETY: a suspended fiber.
    unsafe { DeleteFiber(b) };
    // SAFETY: converts back the conversion above.
    let ok = unsafe { ConvertFiberToThread() };
    println!("RESULT ConvertFiberToThread: ok {}, IsThreadAFiber {}, limits restored {}, guarantee {}",
        ok != 0, is_fiber(), limits() == (thread_low, thread_high), guarantee());
}

fn teb_region_above(low: usize) -> usize {
    query(low).map_or(low, |i| low + i.RegionSize)
}

fn fiber_regs(flags: u32) {
    convert(flags);
    let a = fiber_with(64 << 10, USABLE + MARGIN, flags, move || {
        let mut all = Vec::new();
        for round in 0..3 {
            let changed = pattern(SwitchToFiber as *const () as usize, [main_fiber() as usize, 0, 0], 0x2000_0000 + round);
            println!("fiber side, round {round}: changed {changed:?}");
            all.extend(changed);
        }
        println!("RESULT SwitchToFiber (float switch {}) keeps the fiber side's callee-saved registers: changed {all:?}", flags != 0);
        set_mxcsr(MXCSR_TOWARD_ZERO);
        set_fpcw(FPCW_SINGLE);
        back();
        println!("RESULT fiber (float switch {}) after a round trip: mxcsr {:#x} fpcw {:#x} (it set {MXCSR_TOWARD_ZERO:#x} {FPCW_SINGLE:#x})",
            flags != 0, mxcsr(), fpcw());
        back();
    });
    let mut thread_changed = Vec::new();
    for round in 0..3 {
        let changed = pattern(SwitchToFiber as *const () as usize, [a as usize, 0, 0], 0x1000_0000 + round);
        println!("thread side, round {round}: changed {changed:?}");
        thread_changed.extend(changed);
    }
    println!("RESULT SwitchToFiber (float switch {}) keeps the thread side's callee-saved registers: changed {thread_changed:?}", flags != 0);
    to(a);
    let (m, f) = (mxcsr(), fpcw());
    println!("RESULT thread (float switch {}) after the fiber set its rounding: mxcsr {m:#x} fpcw {f:#x}", flags != 0);
    to(a);
}

fn fiber_tls() {
    convert(FIBER_FLAG_FLOAT_SWITCH);
    // SAFETY: plain TLS and FLS slots of this process.
    let (tls, fls) = unsafe { (TlsAlloc(), FlsAlloc(Some(fls_callback))) };
    RUST_TLS.with(|c| c.set(7));
    // SAFETY: slots allocated above.
    unsafe {
        TlsSetValue(tls, 11 as *const c_void);
        FlsSetValue(fls, 21 as *const c_void);
        probe_set_errno(31);
    }
    let a = fiber(move || {
        // SAFETY: slots allocated above.
        let (rust, t, f, e) = unsafe { (RUST_TLS.with(|c| c.get()), TlsGetValue(tls) as usize, FlsGetValue(fls) as usize, probe_get_errno()) };
        println!("RESULT a fiber sees the thread's: Rust thread_local {rust} (set 7), TLS {t} (set 11), FLS {f} (set 21), errno {e} (set 31)");
        RUST_TLS.with(|c| c.set(8));
        // SAFETY: as above.
        unsafe {
            TlsSetValue(tls, 12 as *const c_void);
            FlsSetValue(fls, 22 as *const c_void);
            probe_set_errno(32);
        }
        back();
        // SAFETY: as above.
        let (f, e) = unsafe { (FlsGetValue(fls) as usize, probe_get_errno()) };
        println!("RESULT the fiber's own after a round trip: FLS {f} (set 22), errno {e} (set 32)");
        back();
    });
    to(a);
    // SAFETY: as above.
    let (rust, t, f, e) = unsafe { (RUST_TLS.with(|c| c.get()), TlsGetValue(tls) as usize, FlsGetValue(fls) as usize, probe_get_errno()) };
    println!("RESULT the thread after the fiber set its own: Rust thread_local {rust} (fiber set 8), TLS {t} (fiber set 12), FLS {f} (thread set 21), errno {e} (thread set 31)");
    to(a);
    let before = FLS_CALLED.load(Ordering::Relaxed);
    // SAFETY: a suspended fiber.
    unsafe { DeleteFiber(a) };
    println!("RESULT DeleteFiber runs the fiber's FLS callbacks: {} call(s), last value {}",
        FLS_CALLED.load(Ordering::Relaxed) - before, FLS_VALUE.load(Ordering::Relaxed));
}

fn fiber_calls() {
    convert(FIBER_FLAG_FLOAT_SWITCH);
    let thread_id = unsafe { GetCurrentThreadId() };
    let a = fiber(move || {
        let v: Vec<String> = (0..1000).map(|i| format!("{i}")).collect();
        let mut buffer = vec![0u8; 4096];
        // SAFETY: fixture.c's functions, a buffer of 4096 bytes.
        let c = unsafe { (probe_c_add(1 << 40, -3, 7), probe_c_mix(1.5, 4, 0.25), probe_c_fill(buffer.as_mut_ptr(), 4096, 3)) };
        println!("RESULT Rust and C on a fiber: {} strings (last {}), C {c:?}, same thread {}",
            v.len(), v[999], unsafe { GetCurrentThreadId() } == thread_id);
        let caught = std::panic::catch_unwind(|| std::panic::panic_any(7u32));
        println!("RESULT a panic caught on a fiber: {:?}", caught.map_err(|e| e.downcast_ref::<u32>().copied()));
        back();
        // Growth through MSVC-compiled frames (and __chkstk's), after a suspension.
        // SAFETY: fixture.c's recursions, well inside 8 MiB.
        let r = unsafe { (probe_c_deep(20000), probe_c_wide(64)) };
        println!("RESULT C recursion growing a fiber's stack after a suspension: {r:?}");
        back();
    });
    to(a);
    let caught = std::panic::catch_unwind(|| std::panic::panic_any(9u32));
    println!("RESULT a panic caught on the thread between the fiber's segments: {:?}", caught.map_err(|e| e.downcast_ref::<u32>().copied()));
    to(a);
}

/// Where a fiber parked by `restarted_body` left (the last restart's).
static RESTARTS: AtomicUsize = AtomicUsize::new(0);

#[inline(never)]
fn deep_then(n: usize, f: &dyn Fn()) -> usize {
    let frame = std::hint::black_box([n as u8; 64]);
    if n == 0 {
        f();
        return 0;
    }
    deep_then(n - 1, f) + frame[0] as usize
}

/// A body started on a parked fiber by a restart: its argument is the Slot.
extern "C" fn restarted_body(slot: usize) {
    let n = RESTARTS.fetch_add(1, Ordering::Relaxed);
    if n == 0 || n == 999 {
        let (low, high) = limits();
        // SAFETY: SLOT is this fiber's.
        let top = unsafe { (*(slot as *const Slot)).top };
        println!("restart {n}: the body's rsp {} bytes below the slot's top, rsp % 16 in the body {}", top - rsp(), rsp() % 16);
        let (frames, end) = walk(&format!("restarted body {n}"), captured(), low, high);
        println!("RESULT unwind from a restarted body ({n}): {frames} frames, {end}");
    }
    // Deep, then park mid-body: the next start restarts it from the top.
    deep_then(50, &|| {
        let mut parked = Switched::default();
        // SAFETY: back to the thread, which restarts this fiber next.
        unsafe { switch(&mut parked, MAIN.load(Ordering::Relaxed), None) };
    });
    println!("restarted body {n} returned from its park (a restart failed)");
    loop {
        back();
    }
}

extern "C" fn first_body(slot: usize) {
    let (low, high) = limits();
    // SAFETY: SLOT is this fiber's.
    let top = unsafe { (*(slot as *const Slot)).top };
    println!("entry stub: the body's rsp {} bytes below its top, rsp % 16 in the body {}, the stub's top % 16 {}, the top {} bytes below \
              the stack's high limit", top - rsp(), rsp() % 16, top % 16, high - top);
    let (frames, end) = walk("from inside a fiber (entry stub)", captured(), low, high);
    println!("RESULT unwind from inside a fiber started by the entry stub: {frames} frames, {end}");
    deep_then(20, &|| {
        let mut saved = Switched::default();
        // SAFETY: back to the thread.
        unsafe { switch(&mut saved, MAIN.load(Ordering::Relaxed), None) };
    });
    loop {
        back();
    }
}

/// A fiber starting in the entry stub with SLOT.
fn stub_fiber(slot: *mut Slot) -> *mut c_void {
    // SAFETY: the stub's ABI is a fiber proc's (Win64: RCX the parameter);
    // SLOT outlives the fiber.
    let fiber = unsafe {
        CreateFiberEx(64 << 10, USABLE + MARGIN, FIBER_FLAG_FLOAT_SWITCH,
            Some(std::mem::transmute::<unsafe extern "C" fn(*mut Slot), unsafe extern "system" fn(*mut c_void)>(probe_fiber_entry)),
            slot as *const c_void)
    };
    assert!(!fiber.is_null(), "CreateFiberEx: error {}", unsafe { GetLastError() });
    fiber
}

fn fiber_unwind() {
    convert(FIBER_FLAG_FLOAT_SWITCH);
    // A plain fiber proc, which Windows' fiber start calls.
    let a = fiber(|| {
        let (low, high) = limits();
        let (frames, end) = walk("from inside a fiber (plain proc)", captured(), low, high);
        println!("RESULT unwind from inside a fiber (its proc called by Windows' fiber start): {frames} frames, {end}");
        back();
    });
    to(a);
    // The entry stub.
    let slot = Box::into_raw(Box::new(Slot { top: 0, f: first_body as *const () as usize, arg: 0 }));
    // SAFETY: SLOT is leaked for the fiber's life.
    unsafe { (*slot).arg = slot as usize };
    let b = stub_fiber(slot);
    let mut here = Switched::default();
    // SAFETY: B's first entry; it parks inside Rust frames.
    unsafe { switch(&mut here, b as usize, None) };
    walk_suspended();
    // Restarts: B parked mid-body, started again from its top, a thousand times.
    // SAFETY: SLOT is B's.
    unsafe { (*slot).f = restarted_body as *const () as usize };
    for _ in 0..1000 {
        // SAFETY: restarts B from its slot's top.
        unsafe { switch(&mut here, b as usize, Some(slot)) };
    }
    println!("RESULT {} restarts of one fiber from its entry stub's top, each parked 50 frames deep", RESTARTS.load(Ordering::Relaxed));
}

/// Where the suspended fiber of `walk_suspended` left: its switch's record.
static SUSPENDED: AtomicUsize = AtomicUsize::new(0);

/// A fiber that suspends inside Rust frames, recording where, and the walk
/// of its suspended stack from the thread's side: what the collector does
/// with a suspended coroutine.
fn walk_suspended() {
    let bounds = std::rc::Rc::new(Cell::new((0usize, 0usize)));
    let seen = bounds.clone();
    let record = Box::into_raw(Box::new(Switched::default()));
    SUSPENDED.store(record as usize, Ordering::Relaxed);
    let a = fiber(move || {
        seen.set(limits());
        deep_then(30, &|| {
            // SAFETY: the record outlives the fiber; back to the thread.
            unsafe { switch(SUSPENDED.load(Ordering::Relaxed) as *mut Switched, MAIN.load(Ordering::Relaxed), None) };
        });
        loop {
            back();
        }
    });
    to(a);
    let (low, high) = bounds.get();
    // SAFETY: written by the fiber's switch before it switched.
    let saved = unsafe { *record };
    let (frames, end) = walk("suspended fiber (from the thread)", context_of(&saved), low, high);
    println!("RESULT unwind of a suspended fiber's stack from the thread, from where its switch left: {frames} frames, {end}; \
              the switch recorded the fiber: {}", saved.fiber == a as usize);
    // SAFETY: suspended.
    unsafe { DeleteFiber(a) };
}

fn fiber_overflow(kind: &str, guarantee_bytes: u32, nested: bool) {
    convert(FIBER_FLAG_FLOAT_SWITCH);
    let kind = kind.to_string();
    let a = fiber(move || {
        let run = move |label: &str| {
            if guarantee_bytes > 0 {
                set_guarantee(guarantee_bytes);
            }
            let (low, high) = limits();
            expect_stack(low, high);
            println!("{label}: limits [{low:#x}, {high:#x}) guarantee {}", guarantee());
            println!("returned {}", exhaust_by(&kind));
        };
        if nested {
            let outer = current_fiber();
            OTHER.store(outer, Ordering::Relaxed);
            let b = fiber(move || run("nested fiber"));
            to(b);
        } else {
            run("fiber");
        }
        back();
    });
    to(a);
}

/// The thread's own stack exhausted after fibers ran on it: its guarantee
/// and bounds as before.
fn thread_overflow_after_fibers() {
    let (ok, _) = set_guarantee(GUARANTEE);
    convert(FIBER_FLAG_FLOAT_SWITCH);
    let a = fiber(|| {
        set_guarantee(64 << 10);
        back();
    });
    to(a);
    let (low, high) = limits();
    expect_stack(low, high);
    println!("thread: set {ok}, guarantee {} after a fiber set 64 KiB on itself", guarantee());
    println!("returned {}", exhaust(0));
}

fn fiber_lifetime(kind: &str) {
    match kind {
        "proc-returns" => {
            let code = on_raw_thread(Box::new(|| {
                convert(FIBER_FLAG_FLOAT_SWITCH);
                unsafe extern "system" fn returns(_: *mut c_void) {
                    println!("the fiber proc returns");
                }
                // SAFETY: a fiber whose proc returns.
                let f = unsafe { CreateFiberEx(0, 0, FIBER_FLAG_FLOAT_SWITCH, Some(returns), std::ptr::null()) };
                to(f);
                println!("after the fiber whose proc returned (never printed if the thread ended)");
            }));
            println!("RESULT a fiber whose proc returns: the thread ended with exit code {code:#x} (its own code never ran on)");
        }
        "delete-current" => {
            let code = on_raw_thread(Box::new(|| {
                convert(FIBER_FLAG_FLOAT_SWITCH);
                let f = fiber(|| {
                    // SAFETY: deliberately deletes the running fiber.
                    unsafe { DeleteFiber(current_fiber() as *mut c_void) };
                    println!("after DeleteFiber of the running fiber (never printed)");
                });
                to(f);
                println!("after (never printed)");
            }));
            println!("RESULT DeleteFiber of the running fiber: the thread ended with exit code {code:#x}");
        }
        "host-fiber" => {
            // A host converted the thread; a library (the runtime) then
            // creates its own fibers, switching from the host's fiber and
            // back, and converts nothing.
            let host = convert(FIBER_FLAG_FLOAT_SWITCH);
            let was = is_fiber();
            let current = current_fiber();
            let a = fiber(|| {
                back();
            });
            to(a);
            // SAFETY: suspended.
            unsafe { DeleteFiber(a) };
            println!("RESULT on a thread a host converted: IsThreadAFiber {was}, the current fiber is the host's {}, a fiber of ours ran and \
                      returned to it, the thread is still a fiber {}", current == host as usize, is_fiber());
        }
        "create-many" => {
            convert(FIBER_FLAG_FLOAT_SWITCH);
            let n = 20_000;
            for _ in 0..n {
                let f = fiber(|| back());
                to(f);
                // SAFETY: suspended.
                unsafe { DeleteFiber(f) };
            }
            println!("RESULT {n} fibers created, entered and deleted, one at a time: the process is still well");
        }
        other => println!("no lifetime kind {other}"),
    }
}

fn fiber_perf() {
    convert(FIBER_FLAG_FLOAT_SWITCH);
    let a = fiber(|| loop {
        back();
    });
    let n = 2_000_000;
    to(a);
    let started = Instant::now();
    for _ in 0..n {
        to(a);
    }
    let ns = started.elapsed().as_nanos() as f64 / n as f64;
    println!("RESULT SwitchToFiber round trip (thread -> fiber -> thread, float switch): {ns:.1} ns");
    // The production switch: SwitchToFiber with its record of where it left.
    let b = fiber(|| loop {
        let mut s = Switched::default();
        // SAFETY: back to the thread.
        unsafe { switch(&mut s, MAIN.load(Ordering::Relaxed), None) };
    });
    to(b);
    let started = Instant::now();
    for _ in 0..n {
        let mut s = Switched::default();
        // SAFETY: to B, suspended in `switch`.
        unsafe { switch(&mut s, b as usize, None) };
    }
    let ns = started.elapsed().as_nanos() as f64 / n as f64;
    println!("RESULT the production switch's round trip (SwitchToFiber, the record, the restart check): {ns:.1} ns");
    // A fiber's life: created, entered once, deleted.
    let m = 5000;
    let started = Instant::now();
    for _ in 0..m {
        let f = fiber(|| back());
        to(f);
        // SAFETY: suspended.
        unsafe { DeleteFiber(f) };
    }
    let us = started.elapsed().as_nanos() as f64 / m as f64 / 1000.0;
    println!("RESULT a fiber's life (CreateFiberEx of 8 MiB + 64 KiB, first entry, DeleteFiber): {us:.2} us");
    // A restart: what a start on a pooled fiber costs.
    let slot = Box::into_raw(Box::new(Slot { top: 0, f: perf_body as *const () as usize, arg: 0 }));
    // SAFETY: SLOT is leaked.
    unsafe { (*slot).arg = slot as usize };
    let c = stub_fiber(slot);
    let mut here = Switched::default();
    // SAFETY: C's first entry.
    unsafe { switch(&mut here, c as usize, None) };
    let started = Instant::now();
    for _ in 0..n {
        // SAFETY: restarts C.
        unsafe { switch(&mut here, c as usize, Some(slot)) };
    }
    let ns = started.elapsed().as_nanos() as f64 / n as f64;
    println!("RESULT a start on a parked fiber (switch, restart from the top, a body that switches back): {ns:.1} ns");
    // Conversion.
    // SAFETY: undoes the conversion above.
    unsafe { ConvertFiberToThread() };
    let k = 100_000;
    let started = Instant::now();
    for _ in 0..k {
        // SAFETY: converts and converts back the calling thread.
        unsafe {
            ConvertThreadToFiberEx(std::ptr::null(), FIBER_FLAG_FLOAT_SWITCH);
            ConvertFiberToThread();
        }
    }
    let ns = started.elapsed().as_nanos() as f64 / k as f64;
    println!("RESULT ConvertThreadToFiberEx + ConvertFiberToThread: {ns:.0} ns");
}

extern "C" fn perf_body(_slot: usize) {
    let mut s = Switched::default();
    // SAFETY: back to the thread, parked: the next start restarts.
    unsafe { switch(&mut s, MAIN.load(Ordering::Relaxed), None) };
    loop {
        back();
    }
}

// ---------------------------------------------------------------------------
// The parent

struct Outcome {
    code: u32,
    stdout: String,
    stderr: String,
}

/// Runs SCENARIO in a child process, killed after a minute (a hang is an
/// outcome too: exit code 0xdead).
fn run(scenario: &str) -> Outcome {
    use std::io::Read;
    let mut child = Command::new(std::env::current_exe().unwrap())
        .env("PROBE_CHILD", scenario)
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .unwrap();
    let mut stdout = child.stdout.take().unwrap();
    let mut stderr = child.stderr.take().unwrap();
    let out = std::thread::spawn(move || {
        let mut text = Vec::new();
        let _ = stdout.read_to_end(&mut text);
        text
    });
    let err = std::thread::spawn(move || {
        let mut text = Vec::new();
        let _ = stderr.read_to_end(&mut text);
        text
    });
    let started = Instant::now();
    let code = loop {
        if let Some(status) = child.try_wait().unwrap() {
            break status.code().unwrap_or(-1) as u32;
        }
        if started.elapsed().as_secs() > 60 {
            let _ = child.kill();
            let _ = child.wait();
            break 0xdead;
        }
        std::thread::sleep(std::time::Duration::from_millis(20));
    };
    Outcome {
        code,
        stdout: String::from_utf8_lossy(&out.join().unwrap()).replace('\r', ""),
        stderr: String::from_utf8_lossy(&err.join().unwrap()).replace('\r', ""),
    }
}

fn experiment(name: &str, scenario: &str) -> Outcome {
    let o = run(scenario);
    println!("== {name}  [{scenario}]");
    println!("   exit {:#010x}", o.code);
    for line in o.stdout.lines() {
        println!("   {line}");
    }
    for line in o.stderr.lines().take(40) {
        println!("   err: {line}");
    }
    o
}

/// The most KiB the handler can burn and still write and terminate.
fn room(base: &str, max: usize) -> (Option<usize>, String) {
    let mut best = None;
    let mut first_failure = String::new();
    for kib in (0..=max).step_by(2) {
        let o = run(&format!("{base} burn={kib}"));
        if o.code == 0x42 && o.stdout.contains("handler code=0xc00000fd") {
            best = Some(kib);
        } else {
            first_failure = format!("at {kib} KiB: exit {:#010x}, stdout {:?}", o.code, o.stdout.lines().last().unwrap_or(""));
            break;
        }
    }
    (best, first_failure)
}

pub fn main() {
    if std::env::var("PROBE_CHILD").is_ok() {
        child();
    }
    println!("# Windows coroutine probe (WINDOWS-X86-64-MILESTONE-5.md)");
    println!("\n## A: fibers -- facts");
    experiment("fiber facts, std thread", "scenario=fiber-facts thread=std");
    experiment("fiber facts, raw thread", "scenario=fiber-facts thread=raw");
    experiment("fiber facts, main thread", "scenario=fiber-facts thread=main");

    println!("\n## A: fibers -- registers and floating-point state");
    experiment("fiber registers, float switch", "scenario=fiber-regs float=1");
    experiment("fiber registers, no float switch", "scenario=fiber-regs float=0");

    println!("\n## A: fibers -- TLS, FLS, errno");
    experiment("fiber TLS and FLS", "scenario=fiber-tls");

    println!("\n## A: fibers -- Rust, C and panics");
    experiment("fiber calls", "scenario=fiber-calls");

    println!("\n## A: fibers -- virtual unwind and restarts");
    experiment("fiber unwind", "scenario=fiber-unwind");

    println!("\n## A: fibers -- exhaustion");
    for kind in ["rust", "rust-wide", "c", "c-wide", "probe-loop"] {
        experiment(&format!("fiber overflow {kind}, 32 KiB guarantee"), &format!("scenario=fiber-overflow kind={kind}"));
    }
    experiment("fiber overflow rust, no guarantee asked", "scenario=fiber-overflow kind=rust guarantee=0");
    experiment("nested fiber overflow rust", "scenario=fiber-overflow kind=rust nested=1");
    experiment("nested fiber overflow probe loop", "scenario=fiber-overflow kind=probe-loop nested=1");
    experiment("fiber overflow rust, handler passes it on", "scenario=fiber-overflow kind=rust action=continue");
    experiment("fiber overflow rust, no handler", "scenario=fiber-overflow kind=rust handler=no");
    experiment("the thread's stack exhausted after fibers ran", "scenario=thread-overflow-after-fibers");
    for (name, base) in [
        ("fiber, 32 KiB guarantee, Rust frames", "scenario=fiber-overflow kind=rust"),
        ("fiber, 32 KiB guarantee, probe loop", "scenario=fiber-overflow kind=probe-loop"),
        ("fiber, no guarantee asked, Rust frames", "scenario=fiber-overflow kind=rust guarantee=0"),
    ] {
        let (best, failure) = room(base, 40);
        println!("RESULT room {name}: {} KiB burned and still reported; {failure}", best.map_or("none".to_string(), |b| b.to_string()));
    }

    println!("\n## A: fibers -- lifetime");
    for kind in ["proc-returns", "delete-current", "host-fiber", "create-many"] {
        experiment(&format!("fiber lifetime {kind}"), &format!("scenario=fiber-lifetime kind={kind}"));
    }

    println!("\n## A: fibers -- cost");
    experiment("fiber cost", "scenario=fiber-perf");

    for mode in 0..3 {
        println!("\n## B: custom switch, TEB mode {mode}");
        for kind in ["facts", "regs", "float", "call", "unwind", "grow", "panic", "overflow", "overflow-c", "overflow-probe-loop", "perf"] {
            experiment(&format!("custom mode {mode} {kind}"), &format!("scenario=custom mode={mode} kind={kind}"));
        }
    }
    println!("\nprobe finished");
}
}
