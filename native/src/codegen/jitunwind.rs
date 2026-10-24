//! The JIT's Windows unwind tables (WINDOWS-X86-64-MILESTONE-3.md): the
//! `UNWIND_INFO` of every function the JIT compiles (codegen::unwind),
//! registered with Windows' unwinder through `RtlAddFunctionTable` for as
//! long as the code exists, so that `RtlLookupFunctionEntry` and
//! `RtlVirtualUnwind` -- exception dispatch, debuggers, profilers, ETW,
//! runtime::framewalk's cross-check -- know a Botlish frame as the AOT
//! executable's `.pdata` describes it.
//!
//! A dynamic function table holds image-relative 32-bit addresses: every
//! function's start and end and every `UNWIND_INFO` must lie within 4 GiB
//! above the table's base. cranelift-jit's own memory providers do not
//! promise that (the system provider maps each allocation where the system
//! puts it), so on Windows the JIT allocates from `CodeMemory`, one address
//! range reserved up front and committed as it is used: code, data and the
//! unwind information (a read-only data object of the same module, made
//! before the module is finalized) share it, and its base is the table's.
//!
//! Lifetimes, in `CompiledProgram`'s field order: the table (`FunctionTable`)
//! is registered after `finalize_definitions`, before any code runs (the
//! code is reachable only through the `CompiledProgram` it returns); it is
//! deleted when the `CompiledProgram` is dropped, then the module, and with
//! it this memory, is released. A program runs only while its
//! `CompiledProgram` exists (main.rs keeps it for every run and drops the Vm
//! first), so no frame of its code is on any stack by then.
use cranelift_jit::{BranchProtection, JITMemoryKind, JITMemoryProvider};
use cranelift_module::{ModuleError, ModuleResult};
use std::io;
use windows_sys::Win32::System::Diagnostics::Debug::{
    FlushInstructionCache, IMAGE_RUNTIME_FUNCTION_ENTRY, IMAGE_RUNTIME_FUNCTION_ENTRY_0, RtlAddFunctionTable,
    RtlDeleteFunctionTable,
};
use windows_sys::Win32::System::Memory::{
    MEM_COMMIT, MEM_RELEASE, MEM_RESERVE, PAGE_EXECUTE_READ, PAGE_NOACCESS, PAGE_PROTECTION_FLAGS, PAGE_READONLY,
    PAGE_READWRITE, VirtualAlloc, VirtualFree, VirtualProtect,
};
use windows_sys::Win32::System::Threading::GetCurrentProcess;

/// The address range one compilation's code and data may use: far more than
/// any program's code, and below 4 GiB, the reach of a function table's
/// 32-bit addresses. Reserved, not committed: it costs address space only.
const RESERVATION: usize = 1 << 30;
const PAGE: usize = 4096;

fn align_up(value: usize, align: usize) -> usize {
    (value + align - 1) & !(align - 1)
}

/// What a segment's pages become when the module is finalized.
#[derive(Clone, Copy, PartialEq, Eq)]
enum Kind {
    Code,
    ReadOnly,
    Writable,
}

impl Kind {
    fn of(kind: JITMemoryKind) -> Kind {
        match kind {
            JITMemoryKind::Executable => Kind::Code,
            JITMemoryKind::ReadOnly => Kind::ReadOnly,
            JITMemoryKind::Writable => Kind::Writable,
        }
    }

    fn protection(self) -> PAGE_PROTECTION_FLAGS {
        match self {
            Kind::Code => PAGE_EXECUTE_READ,
            Kind::ReadOnly => PAGE_READONLY,
            Kind::Writable => PAGE_READWRITE,
        }
    }
}

/// Committed pages of one kind, at OFFSET in the range: LEN bytes, USED of
/// them handed out. Writable (read-write) until finalized, then the kind's
/// protection; a finalized segment is never handed out again.
struct Segment {
    offset: usize,
    len: usize,
    used: usize,
    kind: Kind,
    finalized: bool,
}

/// The JIT's memory on Windows: one reserved range (`RESERVATION` bytes at
/// `base`), committed page by page into segments laid out in order; `next`
/// is the offset of the first page no segment holds. Released when dropped
/// (cranelift-jit's providers leak instead; here the code's owner,
/// `CompiledProgram`, decides its lifetime: this module's doc).
pub struct CodeMemory {
    base: *mut u8,
    next: usize,
    segments: Vec<Segment>,
}

// SAFETY: the range is owned by this value alone; JITMemoryProvider asks
// for Send, and nothing here is tied to a thread.
unsafe impl Send for CodeMemory {}

impl CodeMemory {
    pub fn reserve() -> io::Result<CodeMemory> {
        // SAFETY: reserves fresh address space; no memory is touched.
        let base = unsafe { VirtualAlloc(std::ptr::null(), RESERVATION, MEM_RESERVE, PAGE_NOACCESS) } as *mut u8;
        if base.is_null() {
            return Err(io::Error::last_os_error());
        }
        Ok(CodeMemory { base, next: 0, segments: Vec::new() })
    }

    /// The range's first address: the function table's base.
    pub fn base(&self) -> usize {
        self.base as usize
    }

    /// Commits LEN bytes at OFFSET (pages of the range no segment holds).
    fn commit(&mut self, offset: usize, len: usize) -> io::Result<()> {
        if offset + len > RESERVATION {
            return Err(io::Error::new(io::ErrorKind::OutOfMemory, "the JIT's reserved code range is exhausted"));
        }
        // SAFETY: commits pages inside this value's own reservation.
        let at = unsafe { VirtualAlloc(self.base.add(offset).cast(), len, MEM_COMMIT, PAGE_READWRITE) };
        if at.is_null() {
            return Err(io::Error::last_os_error());
        }
        Ok(())
    }
}

impl JITMemoryProvider for CodeMemory {
    fn allocate(&mut self, size: usize, align: u64, kind: JITMemoryKind) -> io::Result<*mut u8> {
        let align = usize::try_from(align).ok().filter(|a| a.is_power_of_two() && *a <= PAGE).ok_or_else(|| {
            io::Error::new(io::ErrorKind::InvalidInput, "an alignment the JIT's code range does not provide")
        })?;
        let kind = Kind::of(kind);
        let base = self.base;
        let fits = |s: &Segment| s.kind == kind && !s.finalized && align_up(s.used, align) + size <= s.len;
        if let Some(segment) = self.segments.iter_mut().find(|s| fits(s)) {
            let at = align_up(segment.used, align);
            segment.used = at + size;
            // SAFETY: inside the segment's committed pages.
            return Ok(unsafe { base.add(segment.offset + at) });
        }
        // The last segment grows into the pages right after it; any other
        // kind, or a finalized segment, starts a new one there.
        let last = self.segments.len().checked_sub(1).filter(|&i| self.segments[i].kind == kind && !self.segments[i].finalized);
        if let Some(i) = last {
            let at = align_up(self.segments[i].used, align);
            let grow = align_up(at + size, PAGE) - self.segments[i].len;
            self.commit(self.next, grow)?;
            self.next += grow;
            let segment = &mut self.segments[i];
            segment.len += grow;
            segment.used = at + size;
            // SAFETY: inside the segment's committed pages.
            return Ok(unsafe { base.add(segment.offset + at) });
        }
        let len = align_up(size.max(1), PAGE);
        self.commit(self.next, len)?;
        self.segments.push(Segment { offset: self.next, len, used: size, kind, finalized: false });
        let offset = self.next;
        self.next += len;
        // SAFETY: the segment's first committed byte.
        Ok(unsafe { base.add(offset) })
    }

    fn finalize(&mut self, _branch_protection: BranchProtection) -> ModuleResult<()> {
        for segment in self.segments.iter_mut().filter(|s| !s.finalized) {
            // SAFETY: the segment's own committed pages.
            unsafe {
                let at = self.base.add(segment.offset);
                let mut old = 0;
                if VirtualProtect(at.cast(), segment.len, segment.kind.protection(), &mut old) == 0 {
                    return Err(ModuleError::Allocation { err: io::Error::last_os_error() });
                }
                if segment.kind == Kind::Code && FlushInstructionCache(GetCurrentProcess(), at.cast(), segment.len) == 0 {
                    return Err(ModuleError::Allocation { err: io::Error::last_os_error() });
                }
            }
            segment.finalized = true;
        }
        Ok(())
    }

    unsafe fn free_memory(&mut self) {
        if !self.base.is_null() {
            // SAFETY: releases this value's whole reservation (its owner has
            // ended every use of it: the module doc).
            unsafe { VirtualFree(self.base.cast(), 0, MEM_RELEASE) };
            self.base = std::ptr::null_mut();
            self.segments.clear();
        }
    }
}

impl Drop for CodeMemory {
    fn drop(&mut self) {
        // SAFETY: as free_memory.
        unsafe { self.free_memory() }
    }
}

/// A function table registered with Windows: its entries, which Windows
/// reads in place (`RtlAddFunctionTable` does not copy them), live here
/// until `RtlDeleteFunctionTable` in `drop`.
pub struct FunctionTable {
    entries: Vec<IMAGE_RUNTIME_FUNCTION_ENTRY>,
}

impl FunctionTable {
    /// Registers FUNCTIONS -- (start address, size, address of its
    /// UNWIND_INFO) -- relative to BASE, every address in [BASE, BASE + 4
    /// GiB), in address order. An address outside that, or Windows refusing
    /// the table, is an error: never a partial or approximate table.
    pub fn register(base: usize, functions: &[(usize, u32, usize)]) -> Result<FunctionTable, String> {
        let relative = |address: usize| {
            address.checked_sub(base).and_then(|r| u32::try_from(r).ok()).ok_or_else(|| {
                format!("address {address:#x} is outside the 4 GiB above the function table's base {base:#x}")
            })
        };
        let mut entries = Vec::with_capacity(functions.len());
        for &(start, size, info) in functions {
            let begin = relative(start)?;
            entries.push(IMAGE_RUNTIME_FUNCTION_ENTRY {
                BeginAddress: begin,
                EndAddress: begin.checked_add(size).ok_or("a function past the table's reach")?,
                Anonymous: IMAGE_RUNTIME_FUNCTION_ENTRY_0 { UnwindInfoAddress: relative(info)? },
            });
        }
        entries.sort_by_key(|e| e.BeginAddress);
        if entries.windows(2).any(|pair| pair[0].EndAddress > pair[1].BeginAddress) {
            return Err("overlapping functions in the function table".to_string());
        }
        let count = u32::try_from(entries.len()).map_err(|_| "too many functions for one function table")?;
        // SAFETY: the entries stay where they are until drop deletes the
        // table (a Vec's buffer does not move while it is not resized).
        if !unsafe { RtlAddFunctionTable(entries.as_ptr(), count, base as u64) } {
            return Err(format!("RtlAddFunctionTable refused {count} functions: {}", io::Error::last_os_error()));
        }
        Ok(FunctionTable { entries })
    }

    /// The entries, image-relative to the base: (begin, end, UNWIND_INFO).
    #[cfg(test)]
    pub fn entries(&self) -> Vec<(u32, u32, u32)> {
        // SAFETY: every entry was written with UnwindInfoAddress.
        self.entries.iter().map(|e| (e.BeginAddress, e.EndAddress, unsafe { e.Anonymous.UnwindInfoAddress })).collect()
    }
}

impl Drop for FunctionTable {
    fn drop(&mut self) {
        // SAFETY: deletes the table `register` added, by its address. A
        // failure (no such table) leaves nothing registered either.
        unsafe { RtlDeleteFunctionTable(self.entries.as_ptr()) };
    }
}

/// Where `define_unwind_data` put each function's UNWIND_INFO: the data
/// object, and per NIR function the offsets in it of its direct function's
/// and its generic entry's.
pub struct UnwindData {
    id: cranelift_module::DataId,
    offsets: Vec<(Option<usize>, Option<usize>)>,
}

/// Defines one read-only data object of MODULE holding every UNWIND_INFO of
/// DEFINES (4-byte aligned, as the format requires): in this module's memory,
/// so within the function table's reach. Before `finalize_definitions`.
pub fn define_unwind_data(
    module: &mut cranelift_jit::JITModule,
    defines: &[super::clif::DefineResult],
) -> Result<Option<UnwindData>, super::BackendError> {
    use cranelift_module::Module;
    let mut bytes = Vec::new();
    let mut offsets = Vec::with_capacity(defines.len());
    let mut place = |info: &Option<Vec<u8>>| {
        info.as_ref().map(|info| {
            let at = align_up(bytes.len(), 4);
            bytes.resize(at, 0);
            bytes.extend_from_slice(info);
            at
        })
    };
    for define in defines {
        offsets.push((place(&define.direct_unwind), place(&define.entry_unwind)));
    }
    if bytes.is_empty() {
        return Ok(None);
    }
    let error = |e: ModuleError| super::BackendError::Codegen(format!("the JIT's unwind information: {e}"));
    let id = module.declare_anonymous_data(false, false).map_err(error)?;
    let mut data = cranelift_module::DataDescription::new();
    data.define(bytes.into_boxed_slice());
    data.set_align(4);
    module.define_data(id, &data).map_err(error)?;
    Ok(Some(UnwindData { id, offsets }))
}

/// Registers every function of DEFINES that has an UNWIND_INFO in DATA, at
/// the addresses MODULE finalized, relative to BASE (`CodeMemory::base`).
pub fn register(
    module: &cranelift_jit::JITModule,
    symbols: &super::clif::Symbols,
    defines: &[super::clif::DefineResult],
    base: usize,
    data: Option<UnwindData>,
) -> Result<Option<FunctionTable>, super::BackendError> {
    let Some(data) = data else { return Ok(None) };
    let (blob, _) = module.get_finalized_data(data.id);
    let mut functions = Vec::new();
    for (i, (define, (direct, entry))) in defines.iter().zip(&data.offsets).enumerate() {
        if let Some(at) = direct {
            functions.push((module.get_finalized_function(symbols.direct[i]) as usize, define.direct_size, blob as usize + at));
        }
        if let Some(at) = entry {
            functions.push((module.get_finalized_function(symbols.entry[i]) as usize, define.entry_size, blob as usize + at));
        }
    }
    FunctionTable::register(base, &functions).map(Some).map_err(|e| super::BackendError::Codegen(format!("the JIT's function table: {e}")))
}

/// Windows' unwinder against the JIT's code, on a real Windows host
/// (WINDOWS-X86-64-MILESTONE-3.md, section 7): the function table's
/// entries, a virtual unwind of a call chain of JIT frames to the
/// instructions that called them, the callee-saved registers they restore,
/// the collector's walk with every Botlish frame checked against Windows'
/// unwind, and the table's removal with its code.
#[cfg(test)]
pub(crate) mod tests {
    use super::super::{Backend, CompileOptions, CompiledProgram, CraneliftJit};
    use crate::runtime::framewalk::windows::{self as walk, Context};
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::value::{make_small, Value};
    use crate::runtime::vm::{ProgramInfo, Vm};
    use std::cell::RefCell;
    use std::collections::{HashMap, HashSet};
    use std::rc::Rc;
    use std::sync::Mutex;
    use std::sync::atomic::{AtomicUsize, Ordering};
    use windows_sys::Win32::Foundation::STATUS_SINGLE_STEP;
    use windows_sys::Win32::System::Diagnostics::Debug::{
        AddVectoredExceptionHandler, CONTEXT, EXCEPTION_CONTINUE_EXECUTION, EXCEPTION_CONTINUE_SEARCH, EXCEPTION_POINTERS,
        KNONVOLATILE_CONTEXT_POINTERS, RemoveVectoredExceptionHandler, RtlLookupFunctionEntry,
    };
    use windows_sys::Win32::System::Threading::GetCurrentThreadId;

    /// The address the test's foreign C function SYMBOL resolves to in the
    /// JIT (codegen::CraneliftJit; everywhere else foreign symbols resolve to
    /// a stub that never runs).
    pub fn foreign(symbol: &str) -> Option<*const u8> {
        (symbol == "botlish_test_unwind_probe").then_some(probe as *const u8)
    }

    /// One frame of a virtual unwind: its RIP, RSP and RBP, and how many
    /// callee-saved registers its unwind restored and from where.
    #[derive(Debug, Clone)]
    struct Frame {
        rip: usize,
        rsp: usize,
        rbp: usize,
        restored: Vec<(usize, usize)>,
        registers: [u64; 7],
    }

    thread_local! {
        static FRAMES: RefCell<Vec<Frame>> = const { RefCell::new(Vec::new()) };
    }
    /// Where `call_with_magics` returns to: the frame the unwind stops at.
    static LABEL: AtomicUsize = AtomicUsize::new(0);
    /// What `call_with_magics` puts in RBX, RSI, RDI and R12-R15.
    const MAGICS: [u64; 7] = [
        0x0b0b_1111_0b0b_1111,
        0x5151_2222_5151_2222,
        0xd1d1_3333_d1d1_3333,
        0x1212_4444_1212_4444,
        0x1313_5555_1313_5555,
        0x1414_6666_1414_6666,
        0x1515_7777_1515_7777,
    ];

    fn registers(context: &Context) -> [u64; 7] {
        let c = &context.0;
        [c.Rbx, c.Rsi, c.Rdi, c.R12, c.R13, c.R14, c.R15]
    }

    /// The foreign function the test programs call: unwinds from itself with
    /// Windows' unwinder alone, every frame, until `LABEL` (at most 200
    /// frames), and records them in FRAMES.
    extern "C" fn probe() {
        let mut context = Context::captured();
        let label = LABEL.load(Ordering::Relaxed);
        let mut frames = Vec::new();
        for _ in 0..200 {
            let mut pointers = KNONVOLATILE_CONTEXT_POINTERS::default();
            let before = context;
            // SAFETY: an exact context of this thread, climbing.
            unsafe { walk::unwind_one(&mut context, Some(&mut pointers)) };
            // SAFETY: both views are arrays of pointers.
            let (integers, floats) = unsafe { (pointers.Anonymous2.IntegerContext, pointers.Anonymous1.FloatingContext) };
            let restored = integers
                .iter()
                .map(|p| *p as usize)
                .enumerate()
                .chain(floats.iter().map(|p| *p as usize).enumerate().map(|(i, p)| (16 + i, p)))
                .filter(|&(_, p)| p != 0)
                .collect();
            frames.push(Frame {
                rip: before.0.Rip as usize,
                rsp: before.0.Rsp as usize,
                rbp: before.0.Rbp as usize,
                restored,
                registers: registers(&context),
            });
            if context.0.Rip as usize == label {
                frames.push(Frame { rip: label, rsp: context.0.Rsp as usize, rbp: context.0.Rbp as usize, restored: Vec::new(), registers: registers(&context) });
                break;
            }
        }
        FRAMES.with(|f| *f.borrow_mut() = frames);
    }

    /// Calls ENTRY(VM) with MAGICS in the callee-saved registers, recording
    /// in LABEL where the call returns to (one place: never inlined). With
    /// STEP, the call runs with the trap flag set: the first single-step
    /// exception comes at the entry's first instruction.
    #[inline(never)]
    fn call_with_magics(entry: super::super::ProgramEntry, vm: *mut Vm, step: bool) -> Value {
        let result: u64;
        // SAFETY: a Win64 call of the program's entry; RBX is saved and
        // restored around it, the other callee-saved registers are inputs the
        // callee preserves, and the stack is 16-byte aligned at the call
        // (8 pushed + 40 = 48 below the block's aligned stack pointer; the
        // flags' push and pop balance). Setting the trap flag needs the
        // single-step handler installed (`windows_unwinds_every_instruction_of_jit_code`).
        unsafe {
            std::arch::asm!(
                "push rbx",
                "mov rbx, {rbx}",
                "lea r9, [rip + 2f]",
                "mov [rdx], r9",
                "sub rsp, 40",
                "test r11, r11",
                "jz 3f",
                "pushfq",
                "or qword ptr [rsp], 0x100",
                "popfq",
                "3:",
                "call r10",
                "2:",
                "add rsp, 40",
                "pop rbx",
                rbx = const MAGICS[0],
                in("rdx") LABEL.as_ptr(),
                in("r10") entry,
                in("r11") u64::from(step),
                in("rcx") vm,
                in("rsi") MAGICS[1],
                in("rdi") MAGICS[2],
                in("r12") MAGICS[3],
                in("r13") MAGICS[4],
                in("r14") MAGICS[5],
                in("r15") MAGICS[6],
                lateout("rax") result,
                clobber_abi("win64"),
            );
        }
        result
    }

    fn compile(text: &str) -> CompiledProgram {
        let program = crate::nir::parse(text).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        CraneliftJit.compile(&program, &options).unwrap_or_else(|e| panic!("{}", e.message()))
    }

    fn vm(compiled: &CompiledProgram, stress: bool) -> Box<Vm> {
        let info = ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() };
        let mut vm = Vm::new(Rc::new(info), AllocMode::Off);
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        vm.heap.set_stress_for_test(stress);
        vm
    }

    /// `<program>` calls `wide`, which holds eight values across its call of
    /// `down`, which recurses DEPTH times with one value live across each
    /// call, then calls the probe and allocates a list.
    fn chain(depth: u32) -> String {
        format!(
            concat!(
                "nir 1 call-effects=1 statics=0\n",
                "foreign 0 \"botlish_test_unwind_probe\" params=\"\" result=void name=\"t::probe\"\n\n",
                "func 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
                "    %0 = int {depth}\n    %1 = call 1 %0\n    ret %1\nend\n\n",
                "func 1 \"wide\" params=1 env=0 regs=18 pnames=\"n\" captures=0\n{wide}end\n\n",
                "func 2 \"down\" params=1 env=0 regs=10 pnames=\"n\" captures=0\n",
                "    %1 = int 1\n    %2 = op ilt %0 %1\n    br %2 L0 L1\n",
                "  label L0\n    %3 = foreigncall 0\n    %4 = op listnew %0 %1 %0\n    %5 = op listlen %4\n    ret %5\n",
                "  label L1\n    %6 = op isub %0 %1\n    %7 = call 2 %6\n    %8 = op iadd %7 %0\n    %9 = op iadd %8 %6\n    ret %9\nend\n",
            ),
            depth = depth,
            wide = WIDE,
        )
    }

    /// `wide`'s body: eight values held across its call of function 2.
    const WIDE: &str = concat!(
        "    %1 = op imul %0 %0\n    %2 = op iadd %1 %0\n    %3 = op imul %2 %0\n    %4 = op iadd %3 %1\n",
        "    %5 = op imul %4 %0\n    %6 = op iadd %5 %2\n    %7 = op imul %6 %3\n    %8 = op iadd %7 %4\n",
        "    %9 = call 2 %0\n",
        "    %10 = op iadd %9 %1\n    %11 = op iadd %10 %2\n    %12 = op iadd %11 %3\n    %13 = op iadd %12 %4\n",
        "    %14 = op iadd %13 %5\n    %15 = op iadd %14 %6\n    %16 = op iadd %15 %7\n    %17 = op iadd %16 %8\n",
        "    ret %17\n",
    );

    /// The value `chain(depth)` computes.
    fn chain_value(depth: i64) -> i64 {
        let n = depth;
        let (a1, a2) = (n * n, n * n + n);
        let a3 = a2 * n;
        let a4 = a3 + a1;
        let (a5, a6) = (a4 * n, a4 * n + a2);
        let a7 = a6 * a3;
        let a8 = a7 + a4;
        let mut down = 3; // the list of three at n = 0
        for k in 1..=n {
            down += k + (k - 1);
        }
        down + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8
    }

    /// Every function's entry, as RtlLookupFunctionEntry finds it from any
    /// address of its code, spans exactly its code and names its UNWIND_INFO;
    /// once the program is dropped, none is found any more.
    #[test]
    fn every_jit_function_is_registered_for_its_code_only() {
        let compiled = compile(&chain(3));
        let table = compiled._unwind.as_ref().expect("a function table");
        let ranges: Vec<(usize, usize)> = compiled
            .direct_entries
            .iter()
            .chain(&compiled.generic_entries)
            .map(|&start| {
                let entry = compiled.framemap.find(start).expect("in the stack-map table");
                (entry.code_start, entry.code_end)
            })
            .collect();
        assert_eq!(table.entries().len(), ranges.len());
        for &(start, end) in &ranges {
            for pc in [start, start + 1, (start + end) / 2, end - 1] {
                let mut base = 0u64;
                // SAFETY: a lookup of an address of this process.
                let entry = unsafe { RtlLookupFunctionEntry(pc as u64, &mut base, std::ptr::null_mut()) };
                assert!(!entry.is_null(), "no entry for {pc:#x} in {start:#x}..{end:#x}");
                // SAFETY: an entry Windows returned.
                let (begin, finish, info) = unsafe { ((*entry).BeginAddress, (*entry).EndAddress, (*entry).Anonymous.UnwindInfoAddress) };
                assert_eq!((base as usize + begin as usize, base as usize + finish as usize), (start, end));
                // SAFETY: the UNWIND_INFO's first byte, in this program's memory.
                let version = unsafe { *((base as usize + info as usize) as *const u8) };
                assert_eq!(version, 1, "UNWIND_INFO version 1, no flags");
            }
            let mut base = 0u64;
            // SAFETY: as above.
            let after = unsafe { RtlLookupFunctionEntry(end as u64, &mut base, std::ptr::null_mut()) };
            assert!(after.is_null() || unsafe { base as usize + (*after).BeginAddress as usize } == end, "{end:#x} past the function");
        }
        let starts: Vec<usize> = ranges.iter().map(|r| r.0).collect();
        drop(compiled);
        for start in starts {
            let mut base = 0u64;
            // SAFETY: a lookup only: no code is read.
            let entry = unsafe { RtlLookupFunctionEntry(start as u64 + 1, &mut base, std::ptr::null_mut()) };
            assert!(entry.is_null(), "{start:#x} still registered after its code was released");
        }
    }

    /// Windows' unwinder alone, from inside the probe, climbs every JIT frame
    /// of the chain to the instruction that called it: each Botlish frame's
    /// return address follows a call, a direct call's target is the frame
    /// above's function, each step agrees with Cranelift's frame record, and
    /// at the caller of the program's entry every callee-saved register holds
    /// again what the caller put there -- restored through the frames that
    /// saved them, which the eight values `wide` holds force.
    #[test]
    fn windows_unwinds_jit_frames_to_their_callers() {
        let depth = 4;
        let compiled = compile(&chain(depth));
        let mut vm = vm(&compiled, false);
        let result = call_with_magics(compiled.entry, &mut *vm, false);
        assert_eq!(result, make_small(chain_value(depth as i64)), "the program's value");
        let frames = FRAMES.with(|f| f.borrow().clone());
        let label = LABEL.load(Ordering::Relaxed);
        assert_eq!(frames.last().map(|f| f.rip), Some(label), "the unwind reached the entry's caller: {frames:#x?}");
        // [probe's own frames] down(0) down(1) ... down(depth) wide <program> [label]
        let botlish: Vec<&Frame> = frames.iter().filter(|f| compiled.framemap.find(f.rip).is_some()).collect();
        assert_eq!(botlish.len(), depth as usize + 3, "{frames:#x?}");
        let first = frames.iter().position(|f| compiled.framemap.find(f.rip).is_some()).unwrap();
        assert!(frames[first..frames.len() - 1].iter().all(|f| compiled.framemap.find(f.rip).is_some()), "one run of Botlish frames");
        let function = |rip: usize| compiled.direct_entries.iter().position(|&start| compiled.framemap.find(rip).unwrap().code_start == start);
        let expected: Vec<Option<usize>> = std::iter::repeat_n(Some(2), depth as usize + 1).chain([Some(1), Some(0)]).collect();
        assert_eq!(botlish.iter().map(|f| function(f.rip)).collect::<Vec<_>>(), expected);
        for (i, frame) in botlish.iter().enumerate() {
            // The instruction before the return address is a call: direct
            // (e8 rel32) to the function of the frame below, or indirect (the
            // probe's, an imported symbol).
            // SAFETY: the JIT's code, readable while the program exists.
            let code = unsafe { std::slice::from_raw_parts((frame.rip - 6) as *const u8, 6) };
            if i == 0 {
                assert!(code[3] == 0xff || code[4] == 0xff, "an indirect call before {:#x}: {code:02x?}", frame.rip);
            } else {
                assert_eq!(code[1], 0xe8, "a direct call before {:#x}: {code:02x?}", frame.rip);
                let target = (frame.rip as isize + i32::from_le_bytes(code[2..6].try_into().unwrap()) as isize) as usize;
                assert_eq!(Some(target), compiled.direct_entries.get(function(botlish[i - 1].rip).unwrap()).copied(), "the call before {:#x}", frame.rip);
            }
            // Windows' step lands where Cranelift's frame record says the
            // caller's stack pointer is.
            let next = frames.iter().position(|f| f.rip == frame.rip && f.rsp == frame.rsp).unwrap() + 1;
            assert_eq!(frames[next].rsp, frame.rbp + 16, "the caller's stack pointer is above the frame record");
            // Saves come from the frame itself.
            for &(register, at) in &frame.restored {
                assert!(if register == 5 { at == frame.rbp } else { at >= frame.rsp && at < frame.rbp }, "register {register} from {at:#x}: {frame:#x?}");
            }
        }
        assert!(
            botlish.iter().any(|f| f.restored.iter().any(|&(r, _)| [3, 6, 7, 12, 13, 14, 15].contains(&r))),
            "some Botlish frame saves a callee-saved register: {frames:#x?}"
        );
        assert_eq!(frames.last().unwrap().registers, MAGICS, "the entry's caller's callee-saved registers, restored");
    }

    /// The collector's own walk over the same frames under GC stress, every
    /// Botlish frame of every collection checked against Windows' unwind
    /// (BOTLISH_NATIVE_UNWIND_CHECK's check, forced on: a mismatch ends the
    /// test process), and the value right.
    #[test]
    fn the_collectors_walk_agrees_with_windows_on_jit_frames() {
        if !crate::runtime::framewalk::NATIVE_FRAME_ROOTS {
            return; // a fallback-roots build: no frame is walked
        }
        walk::force_unwind_check();
        let before = walk::checked_frames();
        let depth = 6;
        let compiled = compile(&chain(depth));
        let mut vm = vm(&compiled, true);
        let result = (compiled.entry)(&mut *vm);
        assert_eq!(result, make_small(chain_value(depth as i64)));
        assert!(vm.heap.collections > 0);
        assert!(walk::checked_frames() >= before + depth as usize + 3, "every Botlish frame of the collection checked");
    }

    /// What Win64 preserves across a call: RBX, RBP, RSI, RDI, R12-R15 and
    /// XMM6-XMM15.
    type Preserved = ([u64; 8], [(u64, i64); 10]);

    fn preserved(c: &CONTEXT) -> Preserved {
        // SAFETY: the XMM registers' view of CONTEXT's floating-point area.
        let x = unsafe { &c.Anonymous.Anonymous };
        let xmm = [x.Xmm6, x.Xmm7, x.Xmm8, x.Xmm9, x.Xmm10, x.Xmm11, x.Xmm12, x.Xmm13, x.Xmm14, x.Xmm15].map(|r| (r.Low, r.High));
        ([c.Rbx, c.Rbp, c.Rsi, c.Rdi, c.R12, c.R13, c.R14, c.R15], xmm)
    }

    /// A Botlish function's activation while the program is single-stepped:
    /// where its call left the stack pointer and the return address, and
    /// what its caller expects back.
    struct Activation {
        start: usize,
        entry_rsp: u64,
        ret: u64,
        preserved: Preserved,
    }

    /// The single-stepped run's state, kept by the exception handler.
    #[derive(Default)]
    struct Stepping {
        thread: u32,
        functions: Vec<(usize, usize)>,
        activations: Vec<Activation>,
        checked: usize,
        offsets: HashSet<(usize, usize)>,
        deepest: HashMap<usize, u64>,
        returns: usize,
        elsewhere: usize,
        failures: Vec<String>,
    }

    static STEPPING: Mutex<Option<Stepping>> = Mutex::new(None);

    impl Stepping {
        /// The instruction at CONTEXT's RIP, about to run: one step of
        /// Windows' unwinder from here must reach the innermost activation's
        /// caller -- its return address, the stack pointer above it, and
        /// every preserved register as the function found it.
        fn instruction(&mut self, context: &CONTEXT) {
            let (rip, rsp) = (context.Rip, context.Rsp);
            while self.activations.last().is_some_and(|a| a.ret == rip && a.entry_rsp + 8 == rsp) {
                self.activations.pop();
            }
            if rip as usize == LABEL.load(Ordering::Relaxed) {
                return; // back in the test: the run is over
            }
            let Some(&(start, _)) = self.functions.iter().find(|&&(s, e)| s <= rip as usize && (rip as usize) < e) else {
                self.elsewhere += 1;
                return;
            };
            let offset = rip as usize - start;
            if offset == 0 {
                // SAFETY: the return address the call just pushed.
                let ret = unsafe { *(rsp as *const u64) };
                self.activations.push(Activation { start, entry_rsp: rsp, ret, preserved: preserved(context) });
            }
            let Some(top) = self.activations.last() else {
                self.failures.push(format!("{start:#x}+{offset}: Botlish code outside any activation"));
                return;
            };
            if top.start != start {
                self.failures.push(format!("{start:#x}+{offset}: the innermost activation is {:#x}'s", top.start));
                return;
            }
            let depth = self.deepest.entry(start).or_default();
            *depth = (*depth).max(top.entry_rsp - rsp);
            // SAFETY: the function's code, readable while the program exists.
            if unsafe { *(rip as *const u8) } == 0xc3 {
                self.returns += 1;
            }
            let mut unwound = Context(*context);
            // SAFETY: this thread's exact context at an instruction boundary,
            // unwound one frame; nothing is written but the copy.
            let found = unsafe { walk::unwind_one(&mut unwound, None) };
            self.checked += 1;
            self.offsets.insert((start, offset));
            let got = (unwound.0.Rip, unwound.0.Rsp, preserved(&unwound.0));
            let want = (top.ret, top.entry_rsp + 8, top.preserved);
            if !found || got != want {
                self.failures.push(format!("{start:#x}+{offset}: entry found {found}; unwound to {got:#x?}, the caller is {want:#x?}"));
            }
        }
    }

    /// The vectored exception handler of the single-stepped run: each trap
    /// of its thread is an instruction to check, and the trap flag is set
    /// again until the run is back at LABEL.
    unsafe extern "system" fn single_step(pointers: *mut EXCEPTION_POINTERS) -> i32 {
        // SAFETY: Windows passes the exception's record and the thread's context.
        let (code, context) = unsafe { ((*(*pointers).ExceptionRecord).ExceptionCode, &mut *(*pointers).ContextRecord) };
        if code != STATUS_SINGLE_STEP {
            return EXCEPTION_CONTINUE_SEARCH;
        }
        let mut stepping = STEPPING.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        // SAFETY: no precondition.
        let thread = unsafe { GetCurrentThreadId() };
        let Some(s) = stepping.as_mut().filter(|s| s.thread == thread) else {
            return EXCEPTION_CONTINUE_SEARCH;
        };
        s.instruction(context);
        if context.Rip as usize != LABEL.load(Ordering::Relaxed) {
            context.EFlags |= 0x100;
        }
        EXCEPTION_CONTINUE_EXECUTION
    }

    /// `<program>` calls `wide` (eight values across its call of `down`, a
    /// recursion of depth 3) and two functions that hold SMALL and LARGE raw
    /// integers across their call of the leaf `pass` (the call's argument is
    /// the last of them, so all are computed before it): frames of more than
    /// one page and of more than five, which Cranelift probes
    /// (codegen::stack_probes) unrolled and in a loop. Raw integers are no
    /// roots, and nothing allocates or calls the runtime: every instruction
    /// is Botlish code.
    fn stepped(small: usize, large: usize) -> String {
        let spill = |id: usize, k: usize| {
            let raw: Vec<String> = (1..=k).chain(k + 3..=2 * k + 3).map(|r| r.to_string()).collect();
            let mut text = format!(
                "func {id} \"spill{k}\" params=1 env=0 regs={} pnames=\"n\" captures=0 rawregs=\"{}\"\n    %1 = op runbox %0\n",
                2 * k + 5,
                raw.join(" ")
            );
            for i in 2..=k {
                text.push_str(&format!("    %{i} = op riadd %{} %1\n", i - 1));
            }
            text.push_str(&format!("    %{} = op rbox %{k}\n    %{} = call 5 %{}\n    %{} = op runbox %{}\n", k + 1, k + 2, k + 1, k + 3, k + 2));
            for i in 1..=k {
                text.push_str(&format!("    %{} = op riadd %{} %{i}\n", k + 3 + i, k + 2 + i));
            }
            text.push_str(&format!("    %{} = op rbox %{}\n    ret %{}\nend\n", 2 * k + 4, 2 * k + 3, 2 * k + 4));
            text
        };
        format!(
            concat!(
                "nir 1 call-effects=1 statics=0\n\n",
                "func 0 \"<program>\" params=0 env=0 regs=6 pnames=\"\" captures=0\n",
                "    %0 = int 3\n    %1 = call 1 %0\n    %2 = call 3 %0\n    %3 = call 4 %0\n",
                "    %4 = op iadd %1 %2\n    %5 = op iadd %4 %3\n    ret %5\nend\n\n",
                "func 1 \"wide\" params=1 env=0 regs=18 pnames=\"n\" captures=0\n{wide}end\n\n",
                "func 2 \"down\" params=1 env=0 regs=8 pnames=\"n\" captures=0\n",
                "    %1 = int 1\n    %2 = op ilt %0 %1\n    br %2 L0 L1\n",
                "  label L0\n    %3 = int 3\n    ret %3\n",
                "  label L1\n    %4 = op isub %0 %1\n    %5 = call 2 %4\n    %6 = op iadd %5 %0\n    %7 = op iadd %6 %4\n    ret %7\nend\n\n",
                "{small}\n{large}\n",
                "func 5 \"pass\" params=1 env=0 regs=1 pnames=\"x\" captures=0\n    ret %0\nend\n",
            ),
            wide = WIDE,
            small = spill(3, small),
            large = spill(4, large),
        )
    }

    /// The value `stepped(small, large)` computes: `wide`'s, and each spill
    /// function's K*3 + (1 + ... + K)*3.
    fn stepped_value(small: i64, large: i64) -> i64 {
        let spilled = |k: i64| 3 * (k + k * (k + 1) / 2);
        chain_value(3) + spilled(small) + spilled(large)
    }

    /// Windows' unwinder at every instruction of JIT code, not only at its
    /// calls: the program runs single-stepped (the trap flag; a vectored
    /// exception handler sees each instruction before it runs), and from
    /// each instruction of a Botlish function one RtlVirtualUnwind step
    /// must reach the function's caller exactly -- through its prologue (the
    /// push, the frame pointer, the stack probes, the allocation, the
    /// saves), its body and its epilogue to its `ret`.
    #[test]
    fn windows_unwinds_every_instruction_of_jit_code() {
        let (small, large) = (700, 3000);
        let compiled = compile(&stepped(small, large));
        let mut vm = vm(&compiled, false);
        let functions: Vec<(usize, usize)> = compiled
            .direct_entries
            .iter()
            .chain(&compiled.generic_entries)
            .map(|&start| {
                let entry = compiled.framemap.find(start).expect("in the stack-map table");
                (entry.code_start, entry.code_end)
            })
            .collect();
        // SAFETY: no precondition.
        let thread = unsafe { GetCurrentThreadId() };
        *STEPPING.lock().unwrap() = Some(Stepping { thread, functions, ..Stepping::default() });
        // SAFETY: a handler that only acts on this thread's single steps.
        let handler = unsafe { AddVectoredExceptionHandler(1, Some(single_step)) };
        assert!(!handler.is_null());
        let result = call_with_magics(compiled.entry, &mut *vm, true);
        // SAFETY: the handler added above.
        unsafe { RemoveVectoredExceptionHandler(handler) };
        let s = STEPPING.lock().unwrap().take().unwrap();
        assert_eq!(result, make_small(stepped_value(small as i64, large as i64)), "the program's value");
        assert!(s.failures.is_empty(), "{} of {} instructions unwound wrongly; the first: {:#?}", s.failures.len(), s.checked, &s.failures[..s.failures.len().min(6)]);
        assert!(s.activations.is_empty(), "every activation returned: {} left, the innermost at {:#x}", s.activations.len(), s.activations.last().map_or(0, |a| a.start));
        for (id, &start) in compiled.direct_entries.iter().enumerate() {
            for offset in [0, 1, 4] {
                assert!(s.offsets.contains(&(start, offset)), "function {id}: offset {offset} not stepped");
            }
        }
        let frame = |id: usize| s.deepest[&compiled.direct_entries[id]];
        assert!(frame(3) > 4096 && frame(4) > 5 * 4096, "frames of more than one and five pages: {} and {}", frame(3), frame(4));
        assert!(s.returns >= 6 + 4, "every function's ret stepped: {}", s.returns);
        eprintln!(
            "windows_unwinds_every_instruction_of_jit_code: {} instructions unwound ({} distinct), {} elsewhere; frames of {} and {} bytes",
            s.checked,
            s.offsets.len(),
            s.elsewhere,
            frame(3),
            frame(4)
        );
    }
}
