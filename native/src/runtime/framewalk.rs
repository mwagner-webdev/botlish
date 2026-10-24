//! The native-frame GC root walker (x86-64 and AArch64, on the hosts of
//! `NATIVE_FRAME_ROOTS`): the runtime half of the native-stack-map mechanism
//! (see runtime::framemap's own doc for the compile-time half, and
//! codegen::clif's module doc for what generated code guarantees this walker
//! relies on).
//!
//! # Frame layout this walker assumes
//!
//! Cranelift's x86-64 SysV backend (cranelift-codegen 0.135.2, this repo's
//! pin) always opens a function's frame with exactly:
//!
//! ```text
//!     push rbp
//!     mov  rbp, rsp
//! ```
//!
//! with nothing before it (verified against `isa::x64::abi::X64ABIMachSpec::
//! gen_prologue_frame_setup`, which emits unconditionally, and against this
//! repo's own audit/native-scalar-asm/bench/fib.asm disassembly) whenever
//! that function makes any call -- which every function with a safepoint
//! does, by construction (`codegen::roots::is_safepoint` only fires for an
//! instruction that itself compiles to a runtime or Botlish call). This
//! crate's own runtime helpers (rt_closure_new, Vm::alloc, ...) are built with
//! the identical prologue shape because `.cargo/config.toml` forces
//! `-C force-frame-pointers=yes` for this crate's own build (confirmed by
//! disassembling this crate's own release binary, with and without that
//! flag -- see that config file's own comment).
//!
//! Given that shape, for any two frames where CALLER executes `call
//! CALLEE`:
//!
//! ```text
//!   [rbp_CALLEE + 0]  == rbp_CALLER          (pushed by CALLEE's own `push rbp`)
//!   [rbp_CALLEE + 8]  == return address in CALLER, right after the `call`
//!   rbp_CALLEE + 16   == CALLER's own SP at the moment of that `call`
//! ```
//!
//! The third line follows mechanically from the first two: `call` pushes an
//! 8-byte return address (SP drops by 8), then CALLEE's own `push rbp`
//! pushes another 8 bytes (SP drops by 8 more) before `mov rbp,rsp` reads
//! that final SP into `rbp_CALLEE` -- so CALLER's SP before the `call` is
//! `rbp_CALLEE + 16`, and (since none of our calls pass stack arguments --
//! at most a handful of I64s, always within the SysV integer-register
//! budget) SP is unchanged from just before the `call` to just after it
//! returns, which is exactly the SP `ir::UserStackMap::entries()`'s offsets
//! are relative to (codegen::clif's `mark_safepoint`,
//! `codegen::clif::DefineResult::safepoints`'s own doc).
//!
//! This is *exactly* the standard frame-pointer chain (the same one
//! `perf --call-graph fp`/libunwind's FP fallback/etc. already rely on),
//! applied uniformly across every frame in the ascent -- Botlish-compiled
//! and this crate's own Rust frames alike -- so the walk below needs no
//! special case to tell them apart while climbing: it simply asks
//! `runtime::framemap::ProgramMap` "is this return address inside some
//! compiled Botlish function?" at every level, processes it if so, and
//! keeps going either way. See `walk`'s own doc for why "keep going either
//! way" (rather than stopping at the first non-Botlish frame) is the
//! correct behavior, not a shortcut.
//!
//! # Why frame pointers, not DWARF/eh_frame
//!
//! A DWARF-CFI-based unwinder (as `wasmtime`/most production JITs use) is
//! more general -- it survives frame-pointer omission, and it is what a
//! "no register support merely for elegance" reading of the milestone
//! brief might otherwise reach for -- but it requires registering
//! `.eh_frame`-equivalent unwind tables with the process's own unwinder,
//! parsing them at collection time, and (for JIT code) either an
//! in-process CFI evaluator or a registered `__register_frame`-style
//! callback. That is real infrastructure this milestone does not need:
//! Cranelift already gives every frame here a stable, simple, statically
//! verifiable shape, and forcing frame pointers is a single build flag.
//! The compile-time metadata (runtime::framemap) does not encode this
//! choice anywhere -- a DWARF-based walker could read the very same table
//! -- so switching later remains possible without touching it.
//!
//! # AArch64
//!
//! The chain is the same AAPCS64 frame-record chain: x29 addresses a
//! 16-byte record `[x29 + 0] == caller's x29`, `[x29 + 8] == return address
//! (x30)`. Cranelift's AArch64 prologue (cranelift-codegen 0.135.2,
//! `isa::aarch64::abi::AArch64MachineDeps::gen_prologue_frame_setup`) is
//! `stp x29, x30, [sp, #-16]!; mov x29, sp`, and this crate's own Rust frames
//! keep frame pointers too (`-C force-frame-pointers=yes`, .cargo/config.toml).
//! What differs is the step from a record to the *caller's* stack pointer:
//! LLVM's AArch64 Linux prologues place a Rust helper's frame record at the
//! bottom of its callee-save area (`sub sp, sp, #N; stp x29, x30, [sp, #K]`),
//! so `record + 16` is not the SP of the Botlish frame that called it. The
//! walker therefore never derives that SP: on AArch64 the stack-map entries
//! are distances below the Botlish frame's *own* frame pointer, which the
//! callee's record holds as its saved x29 (codegen::clif's `define` converts
//! Cranelift's SP-relative offsets with the function's `frame_to_fp_offset`),
//! and a root's address is `caller_fp - entry` (`root_address`).
use super::framemap::ProgramMap;
use super::native_stack::NativeStack;
use super::value::Value;

/// Whether this host's collector finds `RootStorage::NativeFrame` roots by
/// walking native frames: the one capability that stack-map emission
/// (codegen::clif's `stack_maps`, and so codegen::roots's plan), root
/// publication (the fallback plan's `Vm::native_roots_ptr`), the shadow
/// stack (`Vm::new`), the root report (codegen::roots's `report`) and the
/// walk itself (`walk`, `walk_from`) all read, so that they always agree.
///
/// True on x86-64 and AArch64 Linux (glibc) and macOS, where every frame the
/// walk climbs keeps the frame-pointer chain this module's header describes:
/// Cranelift's own, and this crate's Rust frames, built with `-C
/// force-frame-pointers=yes` for exactly those triples (.cargo/config.toml).
///
/// True on Windows x86-64 (MSVC) too, with another way across Rust frames
/// (`windows`, below): LLVM's Win64 prologue sets the frame pointer *inside*
/// its frame (`sub rsp, N; lea rbp, [rsp+K]`, the `UWOP_SET_FPREG` form), so
/// `[rbp]` of a Rust helper's frame is no saved frame pointer, forced frame
/// pointers or not, and a frame-pointer walk reads garbage there
/// (WINDOWS-TOOLCHAIN-CENSUS.md, B2). Windows' own unwinder crosses those
/// frames instead, from their `.pdata`; Botlish frames keep Cranelift's
/// chain (WINDOWS-X86-64-MILESTONE-3.md).
///
/// False everywhere else: there the fallback plan holds every root -- a
/// function with a Botlish call keeps its roots on the shadow stack, one
/// without publishes its own frame's through `Vm::native_roots_ptr` -- and no
/// native frame is ever walked (WINDOWS-X86-64-MILESTONE-1.md, section 3).
/// The `fallback-roots` feature turns it off on any host, to test that plan
/// where the whole test suite runs (Cargo.toml).
pub const NATIVE_FRAME_ROOTS: bool = cfg!(all(
    any(
        all(any(target_arch = "x86_64", target_arch = "aarch64"), any(all(target_os = "linux", target_env = "gnu"), target_os = "macos")),
        all(target_arch = "x86_64", target_os = "windows", target_env = "msvc")
    ),
    not(feature = "fallback-roots")
));

/// Defensive cap against a malformed frame-pointer chain. The native
/// stack bound is the authoritative address range on Linux.
const MAX_FRAMES: usize = 1 << 22;

/// Reads the current frame pointer (`rbp`). `#[inline(always)]`: an
/// inlined call still executes with the caller's own frame pointer (this
/// function would otherwise establish a frame of its own between the caller
/// and whatever collection-triggering call site we actually want to start the
/// ascent from -- see `walk`'s own use).
#[cfg(all(target_arch = "x86_64", not(windows)))]
#[inline(always)]
fn current_fp() -> usize {
    let rbp: usize;
    // SAFETY: reads a register; no memory access, no side effect.
    unsafe {
        std::arch::asm!("mov {}, rbp", out(reg) rbp, options(nomem, nostack, preserves_flags));
    }
    rbp
}

/// Reads the current frame pointer (`x29`); `#[inline(always)]` as on x86-64.
#[cfg(target_arch = "aarch64")]
#[inline(always)]
fn current_fp() -> usize {
    let fp: usize;
    // SAFETY: reads a register; no memory access, no side effect.
    unsafe {
        std::arch::asm!("mov {}, x29", out(reg) fp, options(nomem, nostack, preserves_flags));
    }
    fp
}

/// The calling function's own frame record (its frame pointer): where a
/// native library's call puts the collector's walk ceiling
/// (runtime::library's `enter`, Vm::stack_ceiling). 0 on a host whose
/// frames are not walked by frame pointer (Windows walks by its unwinder,
/// which the ceiling bounds by stack pointer).
#[inline(always)]
pub fn frame_record() -> usize {
    #[cfg(any(all(target_arch = "x86_64", not(windows)), target_arch = "aarch64"))]
    {
        current_fp()
    }
    #[cfg(all(target_arch = "x86_64", windows))]
    {
        let sp: usize;
        // SAFETY: reads a register.
        unsafe { std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags)) };
        sp
    }
    #[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
    {
        0
    }
}

/// The address of the root a stack-map ENTRY of a safepoint names, for the
/// frame whose record is at RECORD (the callee of the Botlish frame the
/// safepoint belongs to) and holds CALLER_FP (that Botlish frame's own frame
/// pointer). x86-64: the entry is an offset from the Botlish frame's SP at
/// the call, which is `RECORD + 16` (this module's header derivation).
#[cfg(all(target_arch = "x86_64", not(windows)))]
#[inline]
fn root_address(record: usize, _caller_fp: usize, entry: u32) -> Option<usize> {
    record.checked_add(16)?.checked_add(entry as usize)
}

/// AArch64: the entry is the root's distance below CALLER_FP (header,
/// "AArch64").
#[cfg(target_arch = "aarch64")]
#[inline]
fn root_address(_record: usize, caller_fp: usize, entry: u32) -> Option<usize> {
    caller_fp.checked_sub(entry as usize)
}

/// Walks the native call stack from the current frame (see `current_fp`)
/// up through every Botlish-compiled frame it finds, calling VISIT once for
/// every live root's address at each one's own safepoint (an address the
/// caller may read for tracing and, for a future moving collector, write
/// back through to relocate the object it points to -- see this crate's
/// milestone report on why today's non-moving collector only ever reads
/// through it).
///
/// GC only ever runs from inside `Vm::alloc` (runtime/vm.rs's own doc),
/// reached only via a runtime-helper call a Botlish frame itself made
/// (directly, or through further runtime-helper nesting --
/// see this module's header) -- so "the current frame" at the moment this
/// is called is always some number of this crate's own Rust frames deep
/// inside a suspended Botlish call chain, never Botlish code itself. The
/// ascent therefore starts by climbing through those Rust frames (each
/// contributing no roots: `ProgramMap::roots_at` simply returns empty for
/// a return address that is not Botlish code at all) until it reaches the
/// first genuinely Botlish frame, then continues climbing *through*
/// Botlish frames and any further non-Botlish frames alike (a runtime
/// function that calls a closure -- `mutable_array::generate`'s, the affine
/// and mutable-vector bodies -- stays between two Botlish frames, so
/// stopping at the first non-Botlish return address would miss every
/// Botlish frame beyond it; `rt_call_value` itself jumps to the closure's
/// code in an optimized build), all the way to the outermost Botlish
/// activation and, one level further, the non-Botlish driver that first
/// called into it (main.rs's `(compiled.entry)(&mut *vm)`) -- where the
/// walk naturally ends, bounded by `MAX_FRAMES` and the monotonicity check
/// below as defensive backstops rather than as the intended termination
/// condition.
#[cfg(all(any(target_arch = "x86_64", target_arch = "aarch64"), not(windows)))]
pub fn walk(map: &ProgramMap, stack: Option<&NativeStack>, visit: impl FnMut(*mut Value)) {
    walk_from(map, current_fp(), stack, visit)
}

/// `walk`, starting at the frame record START instead of the current frame:
/// a stack that is not running now -- a suspended coroutine's, or a running
/// coroutine's resumer's (COROUTINES.md, runtime/coroutine.rs) -- whose chain
/// starts at the frame its stack switch opened. STACK bounds the walk to that
/// one stack, which is also where its chain ends (a coroutine stack's first
/// frame record holds a zero frame pointer).
///
/// Without `NATIVE_FRAME_ROOTS` it walks nothing: no frame of this host is
/// walkable, and none holds a root (the fallback plan).
#[cfg(all(any(target_arch = "x86_64", target_arch = "aarch64"), not(windows)))]
pub fn walk_from(map: &ProgramMap, start: usize, stack: Option<&NativeStack>, mut visit: impl FnMut(*mut Value)) {
    if !NATIVE_FRAME_ROOTS {
        return;
    }
    let mut record = start;
    for _ in 0..MAX_FRAMES {
        if record == 0 || record % 8 != 0 || stack.is_some_and(|s| !s.contains(record, 16)) {
            break;
        }
        // SAFETY: `record` is either the register value just read above (this
        // thread's own current frame, unconditionally valid) or, on a later
        // iteration, a value read from `[record + 0]` of a previous,
        // successfully-read frame -- i.e. a real saved frame-pointer this
        // same convention wrote, not attacker- or arbitrarily-controlled
        // data. `saved_fp > record` below additionally rejects any frame
        // whose chain does not monotonically ascend the (downward-growing)
        // native stack, as a backstop against misreading this invariant.
        let (saved_fp, return_addr) = unsafe {
            let base = record as *const usize;
            (*base, *base.add(1))
        };

        for &entry in map.roots_at(return_addr) {
            let Some(root_addr) = root_address(record, saved_fp, entry) else { break };
            if stack.is_some_and(|s| !s.contains(root_addr, 8)) { continue; }
            visit(root_addr as *mut Value);
        }

        if saved_fp <= record {
            break;
        }
        record = saved_fp;
    }
}

/// Windows x86-64 (WINDOWS-X86-64-MILESTONE-3.md): the walk starts from the
/// machine context `RtlCaptureContext` reports for it and climbs one frame at
/// a time, two ways:
///
///   * a frame whose return address is Botlish code (`ProgramMap::find`):
///     its stack pointer is the context's RSP -- the one it had at its call,
///     since the frame above was unwound to it -- so a safepoint root is at
///     `RSP + entry`, exactly as on Linux x86-64; its frame pointer is the
///     context's RBP, and Cranelift's frame record there gives its caller:
///     `[rbp]` the caller's RBP, `[rbp + 8]` the return address, `rbp + 16`
///     the caller's RSP (this module's header);
///   * any other frame -- the collector's own, a runtime helper, a Rust
///     frame between two Botlish ones (`mutable_array::generate`'s), the
///     driver below the program -- is unwound by Windows itself:
///     `RtlLookupFunctionEntry` finds its `.pdata` entry and
///     `RtlVirtualUnwind` applies it (a function with none is a leaf: the
///     return address is at RSP).
///
/// Windows' unwind of a Rust frame needs that frame's RSP and RBP (LLVM's
/// frame register), which the climb keeps exact: RtlVirtualUnwind restores
/// RBP where a frame saved it, and a Botlish frame's record holds its
/// caller's. The other nonvolatile registers are not restored across a
/// Botlish frame by the frame-record step, and no frame's unwind reads them.
///
/// The walk ends where the stack does: a zero return address (the thread's
/// first frame), an RSP outside the stack, or an RSP that does not ascend
/// (a defensive bound, like MAX_FRAMES). It never reads a root from a frame
/// that is not Botlish code, and only the stack-map entries of the
/// safepoint the return address names.
///
/// With BOTLISH_NATIVE_UNWIND_CHECK=1 every Botlish frame's step is also
/// taken by Windows' unwinder from the code's own unwind information (the
/// executable's `.pdata`, the JIT's function table: codegen::unwind) and
/// compared: the function's entry must span exactly its code, and the
/// caller's RIP, RSP and RBP must agree, and every callee-saved register
/// must be restored from inside the frame. A difference ends the process
/// with a NATIVE BUG report (`windows::check_failed`).
#[cfg(all(target_arch = "x86_64", windows))]
pub fn walk(map: &ProgramMap, stack: Option<&NativeStack>, mut visit: impl FnMut(*mut Value)) {
    if !NATIVE_FRAME_ROOTS {
        return;
    }
    let mut context = windows::Context::captured();
    windows::walk_context(map, &mut context, stack, windows::unwind_check(), &mut visit);
}

/// A stack that is not running now has no machine context to start from on
/// Windows, and none exists: Windows runs no native coroutine (NATIVE
/// UNSUPPORTED value), whose suspended and resumer stacks are what this is
/// for elsewhere. Win64 coroutines need a context-based start first.
#[cfg(all(target_arch = "x86_64", windows))]
pub fn walk_from(_map: &ProgramMap, _start: usize, _stack: Option<&NativeStack>, _visit: impl FnMut(*mut Value)) {
    if NATIVE_FRAME_ROOTS {
        unreachable!("a frame-record walk on Windows: no native coroutine runs there");
    }
}

#[cfg(all(target_arch = "x86_64", windows))]
pub mod windows {
    use super::{ProgramMap, Value, MAX_FRAMES};
    use crate::runtime::native_stack::NativeStack;
    use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
    use windows_sys::Win32::System::Diagnostics::Debug::{
        CONTEXT, KNONVOLATILE_CONTEXT_POINTERS, RtlCaptureContext, RtlLookupFunctionEntry, RtlVirtualUnwind, UNW_FLAG_NHANDLER,
    };

    /// A machine context, 16-byte aligned as Windows requires (windows-sys's
    /// CONTEXT is only 8: its M128A is two u64s).
    #[repr(C, align(16))]
    #[derive(Clone, Copy)]
    pub struct Context(pub CONTEXT);

    impl Context {
        /// The context of the caller of this function, inlined into it.
        #[inline(always)]
        pub fn captured() -> Context {
            // SAFETY: CONTEXT is plain data; RtlCaptureContext fills it.
            let mut context: Context = unsafe { std::mem::zeroed() };
            unsafe { RtlCaptureContext(&mut context.0) };
            context
        }
    }

    static FORCED: AtomicBool = AtomicBool::new(false);
    static CHECKED: AtomicUsize = AtomicUsize::new(0);
    /// The walks the check saw, and the frames of them Windows' unwinder
    /// crossed (Rust frames, the driver's, the system's below it): what the
    /// collector's way across Rust frames costs, in RtlVirtualUnwind calls.
    static WALKS: AtomicUsize = AtomicUsize::new(0);
    static UNWOUND: AtomicUsize = AtomicUsize::new(0);

    /// Whether BOTLISH_NATIVE_UNWIND_CHECK=1 (read once), or a test turned
    /// the check on (`force_unwind_check`).
    pub fn unwind_check() -> bool {
        static CHECK: std::sync::OnceLock<bool> = std::sync::OnceLock::new();
        FORCED.load(Ordering::Relaxed) || *CHECK.get_or_init(|| std::env::var("BOTLISH_NATIVE_UNWIND_CHECK").is_ok_and(|v| v == "1"))
    }

    /// Turns the check on for the rest of the process: a test's, which
    /// cannot set the environment of a process other tests run in.
    pub fn force_unwind_check() {
        FORCED.store(true, Ordering::Relaxed);
    }

    /// How many Botlish frames the check has compared in this process: a
    /// test's evidence that it ran.
    pub fn checked_frames() -> usize {
        CHECKED.load(Ordering::Relaxed)
    }

    static CHECKED_FUNCTIONS: AtomicUsize = AtomicUsize::new(0);

    /// BOTLISH_NATIVE_UNWIND_CHECK, when a program's stack-map table is
    /// installed (`Vm::set_framemap`): every function of MAP -- each direct
    /// function and generic entry of the program, the JIT's or the
    /// executable's -- has a function entry Windows finds from its first
    /// and its last byte, spanning exactly its code, with version 1
    /// unwind information. A difference ends the process (`check_failed`).
    pub fn check_map(map: &ProgramMap) {
        for function in map.functions() {
            for pc in [function.code_start, function.code_end - 1] {
                let mut image_base = 0u64;
                // SAFETY: looks up an address of Botlish code.
                let entry = unsafe { RtlLookupFunctionEntry(pc as u64, &mut image_base, std::ptr::null_mut()) };
                if entry.is_null() {
                    check_failed(pc as u64, "the function has no unwind entry");
                }
                // SAFETY: a function entry Windows returned; its unwind
                // information's first byte is in the same image or table.
                let (begin, end, version) = unsafe {
                    let base = image_base as usize;
                    let info = base + (*entry).Anonymous.UnwindInfoAddress as usize;
                    (base + (*entry).BeginAddress as usize, base + (*entry).EndAddress as usize, *(info as *const u8))
                };
                if (begin, end) != (function.code_start, function.code_end) || version != 1 {
                    check_failed(pc as u64, &format!(
                        "its unwind entry spans {begin:#x}..{end:#x} (unwind information version and flags {version:#x}), its code {:#x}..{:#x}",
                        function.code_start, function.code_end
                    ));
                }
            }
            CHECKED_FUNCTIONS.fetch_add(1, Ordering::Relaxed);
        }
    }

    /// The check's summary for a run's end (main.rs, runtime::aot): how many
    /// functions' entries and Botlish frames it compared, when it is on and
    /// a program ran (a command that only compiles or links has nothing to
    /// account for, and prints nothing).
    pub fn summary() -> Option<String> {
        (unwind_check() && CHECKED_FUNCTIONS.load(Ordering::Relaxed) > 0).then(|| {
            format!(
                "native unwind check: {} functions, {} Botlish frames, every one as Windows unwinds it; {} walks unwound {} other frames",
                CHECKED_FUNCTIONS.load(Ordering::Relaxed),
                CHECKED.load(Ordering::Relaxed),
                WALKS.load(Ordering::Relaxed),
                UNWOUND.load(Ordering::Relaxed)
            )
        })
    }

    /// This thread's stack: [low, high).
    fn thread_stack() -> (usize, usize) {
        let (mut low, mut high) = (0, 0);
        // SAFETY: writes the two bounds.
        unsafe { windows_sys::Win32::System::Threading::GetCurrentThreadStackLimits(&mut low, &mut high) };
        (low, high)
    }

    /// Unwinds the frame CONTEXT is in with Windows' unwinder; POINTERS, when
    /// given, receives where it restored each nonvolatile register from.
    /// Returns whether the frame had a function entry (false: a leaf).
    ///
    /// # Safety
    /// CONTEXT is a frame of this thread's stack, exact in RIP, RSP and in
    /// every register the frame's unwind reads.
    pub unsafe fn unwind_one(context: &mut Context, pointers: Option<&mut KNONVOLATILE_CONTEXT_POINTERS>) -> bool {
        let pc = context.0.Rip;
        let mut image_base = 0u64;
        let entry = unsafe { RtlLookupFunctionEntry(pc, &mut image_base, std::ptr::null_mut()) };
        if entry.is_null() {
            context.0.Rip = unsafe { *(context.0.Rsp as *const u64) };
            context.0.Rsp += 8;
            return false;
        }
        let mut handler_data = std::ptr::null_mut();
        let mut establisher_frame = 0u64;
        let pointers = pointers.map_or(std::ptr::null_mut(), |p| p as *mut _);
        unsafe {
            RtlVirtualUnwind(UNW_FLAG_NHANDLER, image_base, pc, entry, &mut context.0, &mut handler_data, &mut establisher_frame, pointers);
        }
        true
    }

    /// `super::walk` from CONTEXT, within STACK (the thread's own when None).
    pub fn walk_context(map: &ProgramMap, context: &mut Context, stack: Option<&NativeStack>, check: bool, visit: &mut dyn FnMut(*mut Value)) {
        let (low, high) = stack.map_or_else(thread_stack, |s| (s.low_bound, s.high_bound));
        let within = |address: usize, size: usize| address >= low && address.checked_add(size).is_some_and(|end| end <= high);
        if check {
            WALKS.fetch_add(1, Ordering::Relaxed);
        }
        for _ in 0..MAX_FRAMES {
            let (pc, sp) = (context.0.Rip as usize, context.0.Rsp as usize);
            if pc == 0 || !within(sp, 8) {
                break;
            }
            if let Some(function) = map.find(pc) {
                for &entry in function.roots_at(pc) {
                    let Some(root) = sp.checked_add(entry as usize) else { break };
                    if within(root, 8) {
                        visit(root as *mut Value);
                    }
                }
                let fp = context.0.Rbp as usize;
                if fp < sp || fp % 8 != 0 || !within(fp, 16) {
                    break;
                }
                // SAFETY: a Botlish frame's record, inside the stack.
                let (caller_fp, ret) = unsafe { (*(fp as *const u64), *((fp + 8) as *const u64)) };
                if check {
                    check_frame(function.code_start, function.code_end, context, (ret, fp as u64 + 16, caller_fp));
                }
                context.0.Rip = ret;
                context.0.Rsp = fp as u64 + 16;
                context.0.Rbp = caller_fp;
            } else {
                // SAFETY: the context is exact for this frame (super::walk).
                unsafe { unwind_one(context, None) };
                if check {
                    UNWOUND.fetch_add(1, Ordering::Relaxed);
                }
            }
            if (context.0.Rsp as usize) <= sp {
                break;
            }
        }
    }

    /// BOTLISH_NATIVE_UNWIND_CHECK: Windows' unwind of the Botlish frame
    /// CONTEXT is in -- the function CODE_START..CODE_END -- against the
    /// frame-record step's (RIP, RSP, RBP).
    fn check_frame(code_start: usize, code_end: usize, context: &Context, expected: (u64, u64, u64)) {
        let pc = context.0.Rip;
        let mut image_base = 0u64;
        // SAFETY: looks up a return address in Botlish code.
        let entry = unsafe { RtlLookupFunctionEntry(pc, &mut image_base, std::ptr::null_mut()) };
        if entry.is_null() {
            check_failed(pc, "no unwind entry: Windows takes the Botlish frame for a leaf");
        }
        // SAFETY: a function entry Windows returned.
        let (begin, end) = unsafe { ((*entry).BeginAddress, (*entry).EndAddress) };
        let (begin, end) = (image_base as usize + begin as usize, image_base as usize + end as usize);
        if (begin, end) != (code_start, code_end) {
            check_failed(pc, &format!("its unwind entry spans {begin:#x}..{end:#x}, its code {code_start:#x}..{code_end:#x}"));
        }
        let mut unwound = *context;
        let mut pointers = KNONVOLATILE_CONTEXT_POINTERS::default();
        // SAFETY: the context is exact for this frame.
        unsafe { unwind_one(&mut unwound, Some(&mut pointers)) };
        let got = (unwound.0.Rip, unwound.0.Rsp, unwound.0.Rbp);
        if got != expected {
            check_failed(pc, &format!("Windows unwinds it to (rip, rsp, rbp) {got:#x?}, its frame record to {expected:#x?}"));
        }
        // Every register the step restored, restored from this frame: its
        // saves lie between its stack pointer and its frame pointer, the
        // saved RBP at the frame pointer.
        let (sp, fp) = (context.0.Rsp as usize, context.0.Rbp as usize);
        // SAFETY: both views of the unions are arrays of pointers.
        let (integers, floats) = unsafe { (pointers.Anonymous2.IntegerContext, pointers.Anonymous1.FloatingContext) };
        for (register, pointer) in integers.iter().map(|p| *p as usize).enumerate().chain(floats.iter().map(|p| *p as usize).enumerate().map(|(i, p)| (16 + i, p))) {
            if pointer == 0 {
                continue;
            }
            let inside = if register == 5 { pointer == fp } else { pointer >= sp && pointer < fp };
            if !inside {
                check_failed(pc, &format!("register {register} restored from {pointer:#x}, outside its frame {sp:#x}..={fp:#x}"));
            }
        }
        CHECKED.fetch_add(1, Ordering::Relaxed);
    }

    /// Ends the process with the unwind check's report: a NATIVE BUG.
    pub fn check_failed(pc: u64, what: &str) -> ! {
        eprintln!("native unwind check: the Botlish frame at {pc:#x}: {what} (NATIVE BUG)");
        std::process::abort();
    }
}

#[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
pub fn walk_from(_map: &ProgramMap, _start: usize, _stack: Option<&NativeStack>, _visit: impl FnMut(*mut Value)) {}

#[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
pub fn walk(_map: &ProgramMap, _stack: Option<&NativeStack>, _visit: impl FnMut(*mut Value)) {
    // No frame-walker on this host: every function stays on the fallback
    // RootStorage rules (codegen::roots's `plan`, `native_frame_supported
    // = false`), so there is nothing for this walk to find -- see
    // codegen::clif's module doc and runtime::heap's `collect_with`.
}

#[cfg(all(test, any(target_arch = "x86_64", target_arch = "aarch64")))]
mod tests {
    use super::*;
    use crate::runtime::framemap::FunctionMap;

    /// The capability is the hosts': Linux (glibc) and macOS, by the
    /// frame-pointer chain, and Windows x86-64 (MSVC), by Windows' unwinder
    /// across Rust frames; none in a `fallback-roots` build.
    #[test]
    fn native_frame_roots_are_the_frame_pointer_and_unwinder_hosts() {
        assert_eq!(
            NATIVE_FRAME_ROOTS,
            cfg!(all(
                any(all(target_os = "linux", target_env = "gnu"), target_os = "macos", all(windows, target_env = "msvc", target_arch = "x86_64")),
                not(feature = "fallback-roots")
            ))
        );
    }

    /// Without the capability the walk never reads a frame: a map whose
    /// one function claims every return address on this stack, with a root
    /// at every safepoint, visits nothing.
    #[test]
    fn without_the_capability_nothing_is_walked() {
        let mut map = ProgramMap::new();
        map.push(FunctionMap { code_start: 0, code_end: usize::MAX, safepoints: vec![] });
        map.finish();
        let mut count = 0;
        walk(&map, None, |_| count += 1);
        assert_eq!(count, 0);
        if !NATIVE_FRAME_ROOTS {
            // A start record that would fault if dereferenced.
            walk_from(&map, 8, None, |_| panic!("walked a frame without the capability"));
        }
    }

    /// With an empty map, the walk still ascends this thread's own Rust
    /// call stack (there is always at least this test's own frame, its
    /// test-harness caller, ... down to the OS thread entry) without
    /// finding any roots, and terminates on its own -- confirming the
    /// bounds/termination logic is sound even with nothing Botlish on the
    /// stack at all (mirrors `Vm::reset`'s own `collect_with` call, made
    /// between runs with no Botlish frame active).
    #[test]
    fn walk_with_empty_map_finds_nothing_and_terminates() {
        let map = ProgramMap::new();
        let mut count = 0;
        walk(&map, None, |_| count += 1);
        assert_eq!(count, 0);
    }

    #[test]
    fn walk_stops_at_explicit_out_of_bounds_frame() {
        let map = ProgramMap::new();
        let stack = NativeStack { low_bound: 1, high_bound: 2, guard_low: 0,
            saved_sp: None, state: super::super::native_stack::StackState::Active };
        walk(&map, Some(&stack), |_| panic!("out-of-bounds walk visited root"));
    }

    /// A synthetic `ProgramMap` entry that can never match any real return
    /// address on this test's own call stack still lets `walk` terminate
    /// (it must not, e.g., loop forever waiting to find it).
    #[test]
    fn walk_terminates_when_registered_function_is_never_on_stack() {
        let mut map = ProgramMap::new();
        map.push(FunctionMap { code_start: 0x1000, code_end: 0x2000, safepoints: vec![(0x10, vec![0])] });
        map.finish();
        let mut count = 0;
        walk(&map, None, |_| count += 1);
        assert_eq!(count, 0);
    }
}
