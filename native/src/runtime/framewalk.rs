//! The x86-64 native-frame GC root walker: the runtime half of the
//! native-stack-map mechanism (see runtime::framemap's own doc for the
//! compile-time half, and codegen::clif's module doc for what generated
//! code guarantees this walker relies on).
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
//! crate's own runtime helpers (rt_cell_new, Vm::alloc, ...) are built with
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
use super::framemap::ProgramMap;
use super::value::Value;

/// A defensive bound on how many frames the ascent will ever visit before
/// giving up: not a real limit on legitimate recursion depth (that is
/// `RuntimeStack`'s own `ss_limit` check's job, unchanged by this
/// milestone -- see codegen::clif's `prologue_depth_token`), purely a
/// guard against an unbounded loop if the frame-pointer chain is ever
/// somehow corrupted or misread. Generous relative to any depth
/// `RuntimeStack`'s own bound (`vm::SHADOW_STACK_SLOTS`) would allow.
const MAX_FRAMES: usize = 1 << 22;

/// Reads the current value of the `rbp` register. `#[inline(always)]`: an
/// inlined call still executes with the caller's own `rbp` (this function
/// would otherwise establish a frame of its own between the caller and
/// whatever collection-triggering call site we actually want to start the
/// ascent from -- see `walk`'s own use).
#[cfg(target_arch = "x86_64")]
#[inline(always)]
fn current_rbp() -> usize {
    let rbp: usize;
    // SAFETY: reads a register; no memory access, no side effect.
    unsafe {
        std::arch::asm!("mov {}, rbp", out(reg) rbp, options(nomem, nostack, preserves_flags));
    }
    rbp
}

/// Walks the native call stack from the current frame (see `current_rbp`)
/// up through every Botlish-compiled frame it finds, calling VISIT once for
/// every live root's address at each one's own safepoint (an address the
/// caller may read for tracing and, for a future moving collector, write
/// back through to relocate the object it points to -- see this crate's
/// milestone report on why today's non-moving collector only ever reads
/// through it).
///
/// GC only ever runs from inside `Vm::alloc` (runtime/vm.rs's own doc),
/// reached only via a runtime-helper call a Botlish frame itself made
/// (directly, or through further runtime-helper/`rt_call_value` nesting --
/// see this module's header) -- so "the current frame" at the moment this
/// is called is always some number of this crate's own Rust frames deep
/// inside a suspended Botlish call chain, never Botlish code itself. The
/// ascent therefore starts by climbing through those Rust frames (each
/// contributing no roots: `ProgramMap::roots_at` simply returns empty for
/// a return address that is not Botlish code at all) until it reaches the
/// first genuinely Botlish frame, then continues climbing *through*
/// Botlish frames and any further non-Botlish frames alike (a `CallValue`
/// dispatch nests `rt_call_value` -- non-Botlish -- between two Botlish
/// frames, so stopping at the first non-Botlish return address would miss
/// every Botlish frame beyond it), all the way to the outermost Botlish
/// activation and, one level further, the non-Botlish driver that first
/// called into it (main.rs's `(compiled.entry)(&mut *vm)`) -- where the
/// walk naturally ends, bounded by `MAX_FRAMES` and the monotonicity check
/// below as defensive backstops rather than as the intended termination
/// condition.
#[cfg(target_arch = "x86_64")]
pub fn walk(map: &ProgramMap, mut visit: impl FnMut(*mut Value)) {
    let mut rbp = current_rbp();
    for _ in 0..MAX_FRAMES {
        if rbp == 0 || rbp % 8 != 0 {
            break;
        }
        // SAFETY: `rbp` is either the register value just read above (this
        // thread's own current frame, unconditionally valid) or, on a later
        // iteration, a value read from `[rbp + 0]` of a previous,
        // successfully-read frame -- i.e. a real saved frame-pointer this
        // same convention wrote, not attacker- or arbitrarily-controlled
        // data. `saved_rbp > rbp` below additionally rejects any frame
        // whose chain does not monotonically ascend the (downward-growing)
        // native stack, as a backstop against misreading this invariant.
        let (saved_rbp, return_addr) = unsafe {
            let base = rbp as *const usize;
            (*base, *base.add(1))
        };

        for &offset in map.roots_at(return_addr) {
            // This safepoint's own SP (this module's header derivation),
            // plus this root's byte offset within it.
            let addr = (rbp + 16 + offset as usize) as *mut Value;
            visit(addr);
        }

        if saved_rbp <= rbp {
            break;
        }
        rbp = saved_rbp;
    }
}

#[cfg(not(target_arch = "x86_64"))]
pub fn walk(_map: &ProgramMap, _visit: impl FnMut(*mut Value)) {
    // No frame-walker on this host: every function stays on the fallback
    // RootStorage rules (codegen::roots's `plan`, `native_frame_supported
    // = false`), so there is nothing for this walk to find -- see
    // codegen::clif's module doc and runtime::heap's `collect_with`.
}

#[cfg(all(test, target_arch = "x86_64"))]
mod tests {
    use super::*;
    use crate::runtime::framemap::FunctionMap;

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
        walk(&map, |_| count += 1);
        assert_eq!(count, 0);
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
        walk(&map, |_| count += 1);
        assert_eq!(count, 0);
    }
}
