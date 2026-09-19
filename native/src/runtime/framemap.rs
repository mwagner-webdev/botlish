//! Native stack maps: a PC-indexed table mapping a live, compiled Botlish
//! function's machine code to its GC-root locations, for
//! `runtime::framewalk`'s x86-64 native-frame walker to consult only when a
//! collection actually runs (see that module's doc for the walk itself, and
//! codegen::roots's `RootPlan::safepoint_slots` for where the root-location
//! data originates).
//!
//! Deliberately abstract about *why* a location is described this way:
//! everything here is function-relative offsets (a PC offset from a
//! function's own code start; a root's byte offset from that safepoint's
//! own stack pointer, exactly as Cranelift's own `ir::UserStackMap::
//! entries()` reports it -- see codegen::clif's `mark_safepoint`), not raw
//! process addresses or an x86-64-specific frame-pointer notion. Only
//! `runtime::framewalk`'s actual walk is x86-64-specific (rbp-chain
//! arithmetic); this table itself would serve an aarch64 (frame-pointer
//! register x29) or a `.eh_frame`/DWARF-CFI-based walker just as well,
//! since "PC -> function -> safepoint -> SP-relative root offsets" does not
//! mention rbp anywhere.
//!
//! Ownership/lifetime: one `ProgramMap` is built once, right after
//! `CraneliftJit::compile_actual` finalizes the JIT module's code (the only
//! point absolute function addresses are known), and lives exactly as long
//! as that code can execute -- i.e., for as long as the owning
//! `CompiledProgram`'s `JITModule` is kept alive (see codegen/mod.rs).
//! `Vm` holds an `Rc` clone of the same table so `runtime::heap`'s
//! collector can consult it without borrowing back through
//! `CompiledProgram`. Not used for the AOT object-file path (`emit_object`
//! is a link/codegen smoke test only -- see codegen/mod.rs's module doc --
//! it never runs, so it has no `Vm` to register metadata with).

/// One compiled Botlish function's code range and safepoint table:
/// `CompiledFunction` in the milestone brief's own sketch.
pub struct FunctionMap {
    /// Absolute start address of this function's machine code (JIT-only:
    /// see this module's doc).
    pub code_start: usize,
    pub code_end: usize,
    /// (pc_offset, live_roots), sorted by `pc_offset` (a function-relative
    /// byte offset from `code_start`, matching Cranelift's `UserStackMap`
    /// convention -- codegen::clif's `mark_safepoint`) for binary search.
    /// `pc_offset` is a *return* address, i.e. the PC immediately after the
    /// call this safepoint is attached to -- see codegen::clif's doc and
    /// Cranelift's own `machinst::buffer::MachBuffer::push_user_stack_map`
    /// doc, both confirmed against this repo's pinned cranelift-codegen
    /// 0.135.2. Each `live_roots` entry is a byte offset from that
    /// safepoint's own stack pointer (`RootLocation` in the brief's
    /// sketch): the address of a live root is `sp + offset`, where `sp` is
    /// this safepoint's frame's stack pointer as `runtime::framewalk`
    /// derives it (never a raw process address stored here).
    pub safepoints: Vec<(u32, Vec<u32>)>,
}

impl FunctionMap {
    /// The live-root byte offsets at PC (an absolute address already known
    /// to fall within `code_start..code_end`), or an empty slice if PC is
    /// not a recorded safepoint (either a genuinely safepoint-free function,
    /// e.g. a generic-entry trampoline, or -- impossible in practice, since
    /// every lookup PC is itself a real return address this same compiler
    /// emitted -- a PC that is not a call return address at all).
    fn roots_at(&self, pc: usize) -> &[u32] {
        let offset = match u32::try_from(pc - self.code_start) {
            Ok(o) => o,
            Err(_) => return &[],
        };
        match self.safepoints.binary_search_by_key(&offset, |&(o, _)| o) {
            Ok(i) => &self.safepoints[i].1,
            Err(_) => &[],
        }
    }
}

/// A whole program's compiled functions, indexed by code address for the
/// frame-walker's PC lookups. Includes both a NIR function's "direct" entry
/// point (`botlish_fn_N`, real per-function stack maps) and its generic
/// "entry" trampoline (`botlish_entry_N`, always an empty safepoint table --
/// see codegen/mod.rs): both are genuinely Botlish-compiled code the walker
/// must recognize and continue through (never treat as a foreign boundary),
/// even though only the former ever roots anything.
pub struct ProgramMap {
    /// Sorted by `code_start`, non-overlapping (JIT-compiled functions
    /// never share code ranges), for `find`'s binary search.
    functions: Vec<FunctionMap>,
}

impl ProgramMap {
    pub fn new() -> Self {
        ProgramMap { functions: Vec::new() }
    }

    pub fn push(&mut self, f: FunctionMap) {
        self.functions.push(f);
    }

    /// Finalizes the table for lookup: must be called once after every
    /// `push`, before any `find`.
    pub fn finish(&mut self) {
        self.functions.sort_by_key(|f| f.code_start);
    }

    /// The function containing PC, if any -- `None` means PC is not
    /// Botlish-compiled code at all (a Rust runtime frame, or the outer
    /// driver that first called into compiled code): the frame-walker's own
    /// boundary condition (see `runtime::framewalk`'s doc).
    pub fn find(&self, pc: usize) -> Option<&FunctionMap> {
        let i = self.functions.partition_point(|f| f.code_start <= pc);
        if i == 0 {
            return None;
        }
        let f = &self.functions[i - 1];
        (pc < f.code_end).then_some(f)
    }

    /// The live-root byte offsets (from that safepoint's own SP) at PC, an
    /// absolute address the caller already knows lies within some
    /// registered function (typically from a prior `find`). Empty if PC is
    /// not a recorded safepoint within it.
    pub fn roots_at(&self, pc: usize) -> &[u32] {
        match self.find(pc) {
            Some(f) => f.roots_at(pc),
            None => &[],
        }
    }
}

impl Default for ProgramMap {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fm(start: usize, end: usize, safepoints: Vec<(u32, Vec<u32>)>) -> FunctionMap {
        FunctionMap { code_start: start, code_end: end, safepoints }
    }

    #[test]
    fn find_locates_containing_function() {
        let mut m = ProgramMap::new();
        m.push(fm(0x1000, 0x1100, vec![]));
        m.push(fm(0x2000, 0x2200, vec![]));
        m.finish();
        assert_eq!(m.find(0x1050).unwrap().code_start, 0x1000);
        assert_eq!(m.find(0x2199).unwrap().code_start, 0x2000);
        assert!(m.find(0x1100).is_none(), "code_end is exclusive");
        assert!(m.find(0x1900).is_none(), "gap between functions");
        assert!(m.find(0x500).is_none(), "before every function");
        assert!(m.find(0x9999).is_none(), "after every function");
    }

    #[test]
    fn roots_at_looks_up_by_exact_offset() {
        let mut m = ProgramMap::new();
        m.push(fm(0x1000, 0x1100, vec![(0x10, vec![0, 8]), (0x40, vec![8])]));
        m.finish();
        assert_eq!(m.roots_at(0x1010), &[0, 8]);
        assert_eq!(m.roots_at(0x1040), &[8]);
        assert!(m.roots_at(0x1020).is_empty(), "not a recorded safepoint");
        assert!(m.roots_at(0x9000).is_empty(), "not in any function at all");
    }

    #[test]
    fn functions_pushed_out_of_order_are_still_found() {
        let mut m = ProgramMap::new();
        m.push(fm(0x3000, 0x3100, vec![]));
        m.push(fm(0x1000, 0x1100, vec![]));
        m.push(fm(0x2000, 0x2100, vec![]));
        m.finish();
        assert_eq!(m.find(0x1050).unwrap().code_start, 0x1000);
        assert_eq!(m.find(0x2050).unwrap().code_start, 0x2000);
        assert_eq!(m.find(0x3050).unwrap().code_start, 0x3000);
    }
}
