//! Code generation backends for NIR.
//!
//! A backend turns a validated NIR program into something executable. The
//! only one today is Cranelift (`clif`), used two ways that share all of the
//! translation:
//!
//!   * JIT (`CraneliftJit`): compile in memory and run in this process
//!   * object (`emit_object`): position-independent code and relative GC maps
//!     for AOT linking; `aot::emit_executable` adds startup and the runtime
//!
//! Semantics live in NIR and the runtime; nothing here may change what a
//! program means.

pub mod aot;
pub mod clif;
pub mod fusion;
pub mod library;
#[cfg(all(windows, target_arch = "x86_64"))]
pub mod jitunwind;
pub mod nirtext;
pub mod roots;
pub mod target;
pub mod unwind;

use crate::nir::{FuncId, Program};
use crate::runtime::framemap;
use crate::runtime::ops::helpers;
use crate::runtime::value::*;
use crate::runtime::vm::Vm;
use cranelift_codegen::isa::OwnedTargetIsa;
use cranelift_codegen::settings::{self, Configurable};
use cranelift_jit::{JITBuilder, JITModule};
use std::collections::HashMap;

#[derive(Debug)]
pub enum BackendError {
    /// Cranelift rejected the generated code (or the host is unsupported).
    Codegen(String),
    /// NIR the translation does not expect: a backend bug.
    Bug(String),
}

impl BackendError {
    pub fn error_code(&self) -> &'static str {
        match self {
            BackendError::Codegen(_) => "NATIVE CODEGEN",
            BackendError::Bug(_) => "NATIVE BUG",
        }
    }

    pub fn message(&self) -> &str {
        match self {
            BackendError::Codegen(m) | BackendError::Bug(m) => m,
        }
    }
}

pub use crate::runtime::constants::Const;

#[derive(Default)]
pub struct ConstPool {
    pub entries: Vec<Const>,
    index: HashMap<Const, usize>,
}

impl ConstPool {
    pub fn index(&mut self, c: Const) -> usize {
        if let Some(i) = self.index.get(&c) {
            return *i;
        }
        self.entries.push(c.clone());
        self.index.insert(c, self.entries.len() - 1);
        self.entries.len() - 1
    }
}

pub type ProgramEntry = extern "C" fn(*mut Vm) -> Value;

/// One allocating NIR instruction, compiled (CompileOptions::alloc_sites):
/// codegen/clif.rs's Translator interns one of these per allocating
/// instruction it translates (never per dynamic execution -- a hot loop's
/// one static instruction is one Site regardless of how many times it
/// runs), in `CompiledProgram::sites`, 1-based (id 0 means "unattributed"
/// -- see runtime/vm.rs's `alloc_site`). This backend does not interpret
/// `hir_expr`: it is native/lower.tcl's opaque "@ExprId" annotation
/// (nir::Function::origins), resolved to a source location only on the Tcl
/// side (native.tcl), which is where HIR lives.
pub struct Site {
    pub func: FuncId,
    pub func_name: String,
    pub hir_expr: Option<u32>,
    /// The NIR operation ("strcat", "listappend", "cell", "closure", ...):
    /// distinguishes, e.g., two String-allocating sites by which runtime
    /// helper actually allocated (req: runtime-helper attribution).
    pub operation: &'static str,
    pub object_kind: u8,
}

/// A program compiled to machine code, ready to run.
pub struct CompiledProgram {
    pub entry: ProgramEntry,
    pub pool: ConstPool,
    /// Address of each function's generic entry.
    pub generic_entries: Vec<usize>,
    /// Address of each function's direct function (`botlish_fn_N`), for
    /// the tests that follow its code (codegen::jitunwind's).
    #[cfg(all(test, windows, target_arch = "x86_64"))]
    pub direct_entries: Vec<usize>,
    pub clif: Option<String>,
    /// Pre-regalloc Cranelift VCode emitted by the lowering pipeline.
    pub vcode: Option<String>,
    /// Machine code bytes of each function (with its generic entry).
    pub code_sizes: Vec<u32>,
    /// Empty unless compiled with CompileOptions::alloc_sites.
    pub sites: Vec<Site>,
    /// PC-indexed GC stack-map table for every compiled function (both its
    /// direct entry and its generic entry -- see framemap's own doc): built
    /// once, right here, after `finalize_definitions` makes absolute code
    /// addresses available, the only point they exist. `Vm::set_framemap`
    /// gives the collector (runtime/framewalk.rs) its own `Rc` clone.
    pub framemap: std::rc::Rc<framemap::ProgramMap>,
    /// This program's module-static slot count (nir::Program's own
    /// `statics`, MODULE-STATIC-RETAINED-VALUES.md): `install_constants`
    /// sizes the Vm's static storage to this, once, alongside the ordinary
    /// constant table.
    statics: u32,
    /// The code's Windows function table (codegen::jitunwind): deleted
    /// before the module below releases the code (fields drop in order).
    #[cfg(all(windows, target_arch = "x86_64"))]
    _unwind: Option<jitunwind::FunctionTable>,
    /// Keeps the machine code alive.
    _module: JITModule,
}

impl CompiledProgram {
    /// Builds the VM's constant table (static objects for this program) and
    /// sizes its module-static slot table (MODULE-STATIC-RETAINED-VALUES.md)
    /// to match -- both program-lifetime storage, installed together, once,
    /// before any generated code can run.
    pub fn install_constants(&self, vm: &mut Vm) {
        crate::runtime::constants::install(vm, &self.pool.entries, &self.generic_entries, self.statics);
    }
}

pub struct CompileOptions {
    /// Keep the CLIF of every function.
    pub clif: bool,
    /// Capture the pre-regalloc Cranelift VCode for this compilation.
    pub vcode: bool,
    /// Emit the extra "store this instruction's site id into vm.alloc_site"
    /// before each allocating helper call, and build CompiledProgram::sites
    /// (runtime/metrics.rs's AllocMode::Sites). False recompiles to exactly
    /// today's uninstrumented code: no VM_ALLOC_SITE_OFFSET store anywhere.
    pub alloc_sites: bool,
    /// The program runs with allocation metrics on (summary or sites mode,
    /// runtime/metrics.rs): `mutable_array::at`/`set` call their helpers,
    /// which count reads and writes, instead of their inline fast paths
    /// (codegen::clif's `mutarray_get`/`mutarray_set`), which count
    /// nothing. False for every uninstrumented run and executable.
    pub count_accesses: bool,
}

/// A code generator for NIR programs.
pub trait Backend {
    fn compile(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError>;
}

/// Whether generated code probes every page of a frame larger than one page,
/// top down, before it uses the frame (Cranelift's inline probestack):
///
///   * where the native stack guard exists (Linux x86-64 and AArch64, macOS
///     AArch64): without probes a large Cranelift frame could jump over the
///     thread library's guard pages entirely, and the guard
///     (runtime::platform) would never see the overflow;
///   * on Windows, whether or not a guard exists (it does since
///     WINDOWS-X86-64-MILESTONE-4.md): Windows commits a thread's stack one
///     page at a time, as each access to the guard page just below the
///     committed part moves it down, so a frame larger than a page that
///     touches its far end first skips the guard page and faults on
///     reserved, uncommitted memory -- an ordinary program would crash with
///     plenty of stack left, and an exhausted one with an access violation
///     instead of the STATUS_STACK_OVERFLOW the guard reports. Every Windows
///     C compiler probes for the same reason (`__chkstk`).
///
/// This is stack growth, not overflow handling: the guard reports the
/// exhaustion the probes reach.
fn stack_probes() -> bool {
    crate::runtime::native_stack::native_stack_overflow_supported() || cfg!(target_os = "windows")
}

fn isa(pic: bool) -> Result<OwnedTargetIsa, BackendError> {
    // Linked executables use the target's baseline ISA; only JIT code may
    // assume CPU features detected on the compiler's own machine.
    let isa = cranelift_native::builder_with_options(!pic).map_err(|e| BackendError::Codegen(e.to_string()))?;
    isa.finish(isa_flags(pic)?).map_err(|e| BackendError::Codegen(e.to_string()))
}

/// The ISA of the target TRIPLE with the flags of `isa(true)`: for tests
/// that read another target's object (only its code is made, never run).
#[cfg(all(test, target_arch = "x86_64"))]
fn isa_for(triple: &str) -> OwnedTargetIsa {
    use std::str::FromStr;
    let triple = target_lexicon::Triple::from_str(triple).unwrap();
    cranelift_codegen::isa::lookup(triple).unwrap().finish(isa_flags(true).unwrap()).unwrap()
}

fn isa_flags(pic: bool) -> Result<settings::Flags, BackendError> {
    let mut flags = settings::builder();
    let set = |flags: &mut settings::Builder, k: &str, v: &str| {
        flags.set(k, v).map_err(|e| BackendError::Codegen(format!("setting {k}: {e}")))
    };
    set(&mut flags, "opt_level", "speed")?;
    set(&mut flags, "use_colocated_libcalls", "false")?;
    set(&mut flags, "is_pic", if pic { "true" } else { "false" })?;
    // Probe only large frames (default spacing: one 4 KiB page).
    if stack_probes() {
        set(&mut flags, "enable_probestack", "true")?;
        set(&mut flags, "probestack_strategy", "inline")?;
    }
    Ok(settings::Flags::new(flags))
}

pub struct CraneliftJit;

impl CraneliftJit {
    fn compile_actual(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError> {
        let mut builder = JITBuilder::with_isa(isa(false)?, cranelift_module::default_libcall_names());
        // On Windows the code, its data and its unwind information share one
        // reserved range, the function table's base (codegen::jitunwind).
        #[cfg(all(windows, target_arch = "x86_64"))]
        let code_base = {
            let memory = jitunwind::CodeMemory::reserve().map_err(|e| BackendError::Codegen(format!("the JIT's code range: {e}")))?;
            let base = memory.base();
            builder.memory_provider(Box::new(memory));
            base
        };
        for (name, _, address) in helpers() {
            builder.symbol(name, address);
        }
        // A program that calls C (C-FFI.md) runs as a linked executable,
        // never in this JIT (main.rs): compiled here only for its code (clif,
        // size), its foreign symbols resolve to a stub that never runs --
        // never to whatever a library loaded into this process defines.
        for decl in &program.foreigns {
            #[cfg(all(test, windows, target_arch = "x86_64"))]
            if let Some(address) = jitunwind::tests::foreign(&decl.symbol) {
                builder.symbol(&decl.symbol, address);
                continue;
            }
            builder.symbol(&decl.symbol, crate::runtime::ffi::rt_ffi_unlinked as *const u8);
        }
        let mut module = JITModule::new(builder);
        let symbols = clif::declare(&mut module, program, false, false)?;
        let mut pool = ConstPool::default();
        let mut sites = Vec::new();
        let mut listing = options.clif.then(|| clif::legend(&symbols));
        let mut code_sizes = Vec::with_capacity(program.functions.len());
        let mut defines = Vec::with_capacity(program.functions.len());
        for f in &program.functions {
            let result =
                clif::define(&mut module, &symbols, f, &mut pool, &mut sites, options.alloc_sites, options.count_accesses, options.clif)?;
            code_sizes.push(result.direct_size + result.entry_size);
            if let (Some(listing), Some(text)) = (listing.as_mut(), &result.clif_text) {
                listing.push('\n');
                listing.push_str(text);
            }
            defines.push(result);
        }
        #[cfg(all(windows, target_arch = "x86_64"))]
        let unwind_data = jitunwind::define_unwind_data(&mut module, &defines)?;
        module.finalize_definitions().map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
        // Registered before any of the code can run: the code is reachable
        // only through the CompiledProgram returned below.
        #[cfg(all(windows, target_arch = "x86_64"))]
        let unwind = jitunwind::register(&module, &symbols, &defines, code_base, unwind_data)?;
        let entry_ptr = module.get_finalized_function(symbols.direct[0]);
        let generic_entries: Vec<usize> =
            symbols.entry.iter().map(|id| module.get_finalized_function(*id) as usize).collect();
        let direct_entries: Vec<usize> =
            symbols.direct.iter().map(|id| module.get_finalized_function(*id) as usize).collect();
        let entry: ProgramEntry = unsafe { std::mem::transmute(entry_ptr) };

        // Absolute function addresses only exist after `finalize_definitions`
        // above, so the stack-map table (framemap's own doc) is built here,
        // not inside the per-function loop: `defines[i].safepoints` (PC
        // offsets relative to `botlish_fn_i`'s own start, already extracted
        // in `clif::define`) becomes absolute by adding that start address.
        // Both a NIR function's direct entry (real safepoints) and its
        // generic entry (always empty -- see framemap::FunctionMap's doc:
        // a trampoline the frame-walker must still recognize as Botlish
        // code, never treat as a foreign boundary) are registered.
        let mut framemap = framemap::ProgramMap::new();
        for f in &program.functions {
            let define = &defines[f.id as usize];
            let direct_addr = direct_entries[f.id as usize];
            let safepoints =
                define.safepoints.iter().map(|&(pc, ref roots)| (pc, roots.clone())).collect();
            framemap.push(framemap::FunctionMap {
                code_start: direct_addr,
                code_end: direct_addr + define.direct_size as usize,
                safepoints,
            });
            let entry_addr = generic_entries[f.id as usize];
            framemap.push(framemap::FunctionMap {
                code_start: entry_addr,
                code_end: entry_addr + define.entry_size as usize,
                safepoints: Vec::new(),
            });
        }
        framemap.finish();

        Ok(CompiledProgram {
            entry,
            pool,
            generic_entries,
            #[cfg(all(test, windows, target_arch = "x86_64"))]
            direct_entries,
            clif: listing,
            vcode: None,
            code_sizes,
            sites,
            framemap: std::rc::Rc::new(framemap),
            statics: program.statics,
            #[cfg(all(windows, target_arch = "x86_64"))]
            _unwind: unwind,
            _module: module,
        })
    }
}

impl Backend for CraneliftJit {
    fn compile(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError> {
        if options.vcode {
            let capture = VCodeCapture::new();
            let result = capture.run(|| self.compile_actual(program, options));
            let mut compiled = result?;
            compiled.vcode = capture.take();
            return Ok(compiled);
        }
        self.compile_actual(program, options)
    }
}

static VCODE_BUFFER: std::sync::OnceLock<std::sync::Mutex<Option<String>>> = std::sync::OnceLock::new();
static VCODE_LOGGER: VCodeLogger = VCodeLogger;
static VCODE_LOGGER_INIT: std::sync::Once = std::sync::Once::new();

struct VCodeCapture {
    buffer: &'static std::sync::Mutex<Option<String>>,
}

struct VCodeLogger;

impl log::Log for VCodeLogger {
    fn enabled(&self, metadata: &log::Metadata) -> bool {
        metadata.level() <= log::Level::Trace
    }

    fn log(&self, record: &log::Record) {
        if !self.enabled(record.metadata()) {
            return;
        }
        let mut msg = record.args().to_string();
        let trimmed = msg.trim();
        if trimmed.is_empty() {
            return;
        }

        // Cranelift logs this after machine lowering and immediately before
        // regalloc2. Earlier trace lines describe CLIF construction, not VCode.
        if !trimmed.starts_with("vcode from lowering:") {
            return;
        }
        let buffer = VCODE_BUFFER.get_or_init(|| std::sync::Mutex::new(None));
        let mut guard = buffer.lock().unwrap();
        let text = guard.get_or_insert_with(String::new);
        if !msg.ends_with('\n') {
            msg.push('\n');
        }
        text.push_str(&msg);
    }

    fn flush(&self) {}
}

impl VCodeCapture {
    fn new() -> Self {
        VCODE_LOGGER_INIT.call_once(|| {
            log::set_logger(&VCODE_LOGGER).unwrap();
            log::set_max_level(log::LevelFilter::Trace);
        });
        let buffer = VCODE_BUFFER.get_or_init(|| std::sync::Mutex::new(None));
        let mut guard = buffer.lock().unwrap();
        *guard = Some(String::new());
        Self { buffer }
    }

    fn run<T>(&self, f: impl FnOnce() -> Result<T, BackendError>) -> Result<T, BackendError> {
        f()
    }

    fn take(&self) -> Option<String> {
        let mut guard = self.buffer.lock().unwrap();
        guard.take()
    }
}

/// The program as an object file (AOT). Functions are exported as
/// botlish_fn_N / botlish_entry_N; runtime helpers are undefined imports.
pub struct ObjectProgram {
    pub bytes: Vec<u8>,
    pub pool: ConstPool,
    pub functions: Vec<clif::DefineResult>,
}

pub fn emit_object(program: &Program) -> Result<ObjectProgram, BackendError> {
    emit_object_with(program, isa(true)?, None)
}

/// The program object of native library NAME (NATIVE-LIBRARY-MILESTONE-1.md):
/// the program's code, descriptor and record with local symbols only, and the
/// library's public C functions (codegen::library), its only global ones.
pub fn emit_library_object(program: &Program, name: &str) -> Result<ObjectProgram, BackendError> {
    emit_object_with(program, isa(true)?, Some(name))
}

fn emit_object_with(program: &Program, isa: OwnedTargetIsa, library: Option<&str>) -> Result<ObjectProgram, BackendError> {
    let builder = cranelift_object::ObjectBuilder::new(isa, "botlish", cranelift_module::default_libcall_names())
        .map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
    let mut module = cranelift_object::ObjectModule::new(builder);
    let symbols = clif::declare(&mut module, program, true, library.is_some())?;
    let mut pool = ConstPool::default();
    let mut sites = Vec::new();
    let mut functions = Vec::new();
    for f in &program.functions {
        functions.push(clif::define(&mut module, &symbols, f, &mut pool, &mut sites, false, false, false)?);
    }
    let linkage = if library.is_some() { cranelift_module::Linkage::Local } else { cranelift_module::Linkage::Export };
    let record = define_program_record(&mut module, &symbols, program, &pool, &functions, linkage)?;
    if let Some(name) = library {
        library::define(&mut module, program, name, record)?;
    }
    let mut product = module.finish();
    add_windows_unwind(&mut product, &symbols, &functions)?;
    let mut bytes = product.emit().map_err(|e| BackendError::Codegen(e.to_string()))?;
    if program.context_bytes > 0 {
        relax_context_got(&mut bytes);
    }
    Ok(ObjectProgram { bytes, pool, functions })
}

/// The program's startup data (runtime::program, NATIVE-LIBRARY-MILESTONE-1.md,
/// "One startup"): its descriptor (`botlish_descriptor`, the encoded
/// ProgramDescriptor: metadata, the constant pool POOL, the statics count,
/// every function's code sizes and stack maps from FUNCTIONS, the exports),
/// its code table (`botlish_code`: each function's direct and generic entry
/// address, relocated by the link) and the record that points at both
/// (`botlish_program`, a LinkedProgram, with LINKAGE: global for an
/// executable, whose startup names it, local for a library). Returns the
/// record's id.
fn define_program_record(
    module: &mut cranelift_object::ObjectModule,
    symbols: &clif::Symbols,
    program: &Program,
    pool: &ConstPool,
    functions: &[clif::DefineResult],
    linkage: cranelift_module::Linkage,
) -> Result<cranelift_module::DataId, BackendError> {
    use crate::runtime::program::{FunctionShape, LINKED_MAGIC, ProgramDescriptor, program_info};
    use cranelift_module::{DataDescription, Linkage, Module};
    let error = |e: cranelift_module::ModuleError| BackendError::Codegen(format!("{e:?}"));
    let descriptor = ProgramDescriptor {
        info: std::rc::Rc::new(program_info(program)),
        constants: pool.entries.clone(),
        statics: program.statics,
        functions: functions
            .iter()
            .map(|f| FunctionShape { direct_size: f.direct_size, entry_size: f.entry_size, safepoints: f.safepoints.clone() })
            .collect(),
        exports: program.exports.clone(),
    }
    .encode();
    let descriptor_len = descriptor.len();
    let descriptor_id = module.declare_data("botlish_descriptor", Linkage::Local, false, false).map_err(error)?;
    let mut data = DataDescription::new();
    data.define(descriptor.into_boxed_slice());
    data.set_align(8);
    module.define_data(descriptor_id, &data).map_err(error)?;

    let count = program.functions.len();
    let code_id = module.declare_data("botlish_code", Linkage::Local, false, false).map_err(error)?;
    let mut data = DataDescription::new();
    data.define(vec![0u8; 16 * count].into_boxed_slice());
    data.set_align(8);
    for i in 0..count {
        let direct = module.declare_func_in_data(symbols.direct[i], &mut data);
        data.write_function_addr((16 * i) as u32, direct);
        let entry = module.declare_func_in_data(symbols.entry[i], &mut data);
        data.write_function_addr((16 * i + 8) as u32, entry);
    }
    module.define_data(code_id, &data).map_err(error)?;

    let record_id = module.declare_data("botlish_program", linkage, false, false).map_err(error)?;
    let mut record = vec![0u8; 48];
    record[0..8].copy_from_slice(&LINKED_MAGIC.to_le_bytes());
    record[8..16].copy_from_slice(&crate::runtime::aotimage::abi_fingerprint().to_le_bytes());
    record[24..32].copy_from_slice(&(descriptor_len as u64).to_le_bytes());
    record[40..48].copy_from_slice(&(count as u64).to_le_bytes());
    let mut data = DataDescription::new();
    data.define(record.into_boxed_slice());
    data.set_align(8);
    let descriptor_gv = module.declare_data_in_data(descriptor_id, &mut data);
    data.write_data_addr(16, descriptor_gv, 0);
    let code_gv = module.declare_data_in_data(code_id, &mut data);
    data.write_data_addr(32, code_gv, 0);
    module.define_data(record_id, &data).map_err(error)?;
    Ok(record_id)
}

/// Adds the Windows x64 unwind sections to PRODUCT when its functions have
/// unwind information (`DefineResult::direct_unwind`/`entry_unwind`: Windows
/// x86-64's COFF object, both Windows environments alike): every function's
/// `UNWIND_INFO` in `.xdata`, and in `.pdata` one `RUNTIME_FUNCTION` per
/// function -- its start, its end and its `UNWIND_INFO`, image-relative
/// (`IMAGE_REL_AMD64_ADDR32NB`) -- in address order. The linker merges
/// `.pdata` into the executable's exception directory, which Windows'
/// unwinder searches (`RtlLookupFunctionEntry`) for every return address in
/// Botlish code (WINDOWS-X86-64-MILESTONE-3.md). Nothing else in the object
/// changes; other objects get no section.
fn add_windows_unwind(
    product: &mut cranelift_object::ObjectProduct,
    symbols: &clif::Symbols,
    functions: &[clif::DefineResult],
) -> Result<(), BackendError> {
    use cranelift_object::object::write::{Relocation, SymbolSection};
    use cranelift_object::object::{RelocationEncoding, RelocationFlags, RelocationKind, SectionKind};
    // (section, offset in it, symbol, size, UNWIND_INFO) of every function.
    let mut entries = Vec::new();
    for (i, f) in functions.iter().enumerate() {
        for (id, size, info) in [(symbols.direct[i], f.direct_size, &f.direct_unwind), (symbols.entry[i], f.entry_size, &f.entry_unwind)] {
            let Some(info) = info else { continue };
            let symbol = product.function_symbol(id);
            let defined = product.object.symbol(symbol);
            let SymbolSection::Section(section) = defined.section else {
                return Err(BackendError::Bug(format!("function symbol {:?} is not defined in a section", defined.name)));
            };
            entries.push((section, defined.value, symbol, size, info));
        }
    }
    if entries.is_empty() {
        return Ok(());
    }
    entries.sort_by_key(|e| (e.0, e.1));
    let object = &mut product.object;
    let xdata = object.add_section(Vec::new(), b".xdata".to_vec(), SectionKind::ReadOnlyData);
    let pdata = object.add_section(Vec::new(), b".pdata".to_vec(), SectionKind::ReadOnlyData);
    let mut infos = Vec::with_capacity(entries.len());
    for entry in &entries {
        infos.push(object.append_section_data(xdata, entry.4, 4));
    }
    object.set_section_data(pdata, vec![0u8; 12 * entries.len()], 4);
    let xdata_symbol = object.section_symbol(xdata);
    let image_offset = RelocationFlags::Generic { kind: RelocationKind::ImageOffset, encoding: RelocationEncoding::Generic, size: 32 };
    for (j, (entry, info)) in entries.iter().zip(infos).enumerate() {
        let fields = [(entry.2, 0), (entry.2, i64::from(entry.3)), (xdata_symbol, info as i64)];
        for (k, (symbol, addend)) in fields.into_iter().enumerate() {
            let offset = (12 * j + 4 * k) as u64;
            object
                .add_relocation(pdata, Relocation { offset, symbol, addend, flags: image_offset })
                .map_err(|e| BackendError::Codegen(format!("the .pdata relocation: {e}")))?;
        }
    }
    Ok(())
}

/// The context area's symbol (CONTEXTS.md, clif.rs's `declare`).
pub const CONTEXT_AREA_SYMBOL: &[u8] = b"botlish_context_area";

/// Makes every GOT-relative reference to the context area *relaxable*, so the
/// static linker turns it into a direct RIP-relative address (CONTEXTS.md).
///
/// Cranelift's x86-64 backend materializes any symbol address in PIC code as
/// `movq sym@GOTPCREL(%rip), %reg` (cranelift-codegen's `LoadExtName`),
/// colocated or not, and cranelift-object records it as R_X86_64_GOTPCREL,
/// which a linker must honour with a real GOT slot: one extra load from the
/// GOT before every context access. The context area is a linker-local
/// symbol (STB_LOCAL, never preemptible), so the same instruction may carry
/// R_X86_64_REX_GOTPCRELX instead, the relocation that permits the linker
/// to rewrite `movq sym@GOTPCREL(%rip), %reg` into `leaq sym(%rip), %reg`
/// (x86-64 psABI, "GOTPCRELX relaxation"; GNU ld and lld both do it for a
/// non-preemptible symbol). Only relocations against this one symbol whose
/// instruction is exactly that `REX.W 8B /r` RIP-relative load are changed;
/// the linker still checks the instruction and keeps the GOT slot if it
/// cannot relax. Returns how many relocations were changed. A no-op for
/// anything that is not a little-endian ELF64 object.
pub fn relax_context_got(bytes: &mut [u8]) -> usize {
    const R_X86_64_GOTPCREL: u64 = 9;
    const R_X86_64_REX_GOTPCRELX: u64 = 42;
    let mut changed = 0;
    for (entry, r_type, code_at) in context_relocations(bytes) {
        // movq disp32(%rip), %reg: REX.W (0x48/0x4c), 0x8b, ModRM 00 reg 101.
        if r_type != R_X86_64_GOTPCREL
            || code_at < 3
            || bytes[code_at - 3] & 0xfb != 0x48
            || bytes[code_at - 2] != 0x8b
            || bytes[code_at - 1] & 0xc7 != 0x05
        {
            continue;
        }
        let symbol = u64::from_le_bytes(bytes[entry + 8..entry + 16].try_into().unwrap()) >> 32;
        let relaxed = (symbol << 32) | R_X86_64_REX_GOTPCRELX;
        bytes[entry + 8..entry + 16].copy_from_slice(&relaxed.to_le_bytes());
        changed += 1;
    }
    changed
}

/// Every relocation of a little-endian ELF64 object against the context area
/// symbol: (byte offset of the Rela entry, its type, byte offset in the file
/// of the patched field). Empty for anything else.
pub fn context_relocations(bytes: &[u8]) -> Vec<(usize, u64, usize)> {
    const SHT_SYMTAB: u32 = 2;
    const SHT_RELA: u32 = 4;
    let u16_at = |o: usize| u16::from_le_bytes([bytes[o], bytes[o + 1]]);
    let u32_at = |o: usize| u32::from_le_bytes(bytes[o..o + 4].try_into().unwrap());
    let u64_at = |o: usize| u64::from_le_bytes(bytes[o..o + 8].try_into().unwrap());
    let mut found = Vec::new();
    if bytes.len() < 64 || &bytes[0..4] != b"\x7fELF" || bytes[4] != 2 || bytes[5] != 1 {
        return found;
    }
    let shoff = u64_at(0x28) as usize;
    let shentsize = u16_at(0x3a) as usize;
    let shnum = u16_at(0x3c) as usize;
    // (type, offset, size, link, info, entsize)
    let section = |i: usize| -> (u32, usize, usize, u32, u32, usize) {
        let h = shoff + i * shentsize;
        (u32_at(h + 4), u64_at(h + 0x18) as usize, u64_at(h + 0x20) as usize,
            u32_at(h + 0x28), u32_at(h + 0x2c), u64_at(h + 0x38) as usize)
    };
    // The symbol index of the context area in the symbol table.
    let mut target = None;
    for i in 0..shnum {
        let (kind, offset, size, link, _, entsize) = section(i);
        if kind != SHT_SYMTAB || entsize == 0 {
            continue;
        }
        let (_, strtab, _, _, _, _) = section(link as usize);
        for index in 0..size / entsize {
            let name = strtab + u32_at(offset + index * entsize) as usize;
            let end = bytes[name..].iter().position(|&c| c == 0).map_or(name, |n| name + n);
            if &bytes[name..end] == CONTEXT_AREA_SYMBOL {
                target = Some((i, index as u64));
            }
        }
    }
    let Some((symtab, symbol)) = target else { return found };
    for i in 0..shnum {
        let (kind, offset, size, link, info, entsize) = section(i);
        if kind != SHT_RELA || link as usize != symtab || entsize != 24 {
            continue;
        }
        let (_, code, code_size, _, _, _) = section(info as usize);
        for index in 0..size / entsize {
            let entry = offset + index * entsize;
            let r_offset = u64_at(entry) as usize;
            let r_info = u64_at(entry + 8);
            if r_info >> 32 != symbol || r_offset + 4 > code_size {
                continue;
            }
            found.push((entry, r_info & 0xffff_ffff, code + r_offset));
        }
    }
    found
}

#[cfg(test)]
mod context_area_tests {
    use super::*;

    /// A program with a two-slot context area: the program installs, f reads.
    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1 statics=0 contexts=16\n",
        "context 0 \"A\" offset=0 words=1 fields=\"value\"\n",
        "context 1 \"B\" offset=8 words=1 fields=\"value\"\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=4 pnames=\"\" captures=0\n",
        "    %0 = int 3\n    contextstore 0 %0\n    %1 = int 4\n    contextstore 8 %1\n",
        "    %2 = call 1\n    ret %2\nend\n\n",
        "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0\n",
        "    %0 = contextload 8\n    ret %0\nend\n",
    );

    #[test]
    fn context_lines_and_instructions_parse_and_validate() {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        assert_eq!(program.context_bytes, 16);
        let names: Vec<_> = program.contexts.iter().map(|c| (c.name.as_str(), c.offset, c.words)).collect();
        assert_eq!(names, vec![("A", 0, 1), ("B", 8, 1)]);
        // An offset outside the area, or unaligned, is invalid NIR.
        for bad in ["contextload 16", "contextload 4"] {
            let text = PROGRAM.replace("contextload 8", bad);
            assert!(crate::nir::parse(&text).is_err(), "{bad} must be rejected");
        }
        let text = PROGRAM.replace("contexts=16", "contexts=8");
        assert!(crate::nir::parse(&text).is_err(), "a slot beyond the area must be rejected");
    }

    /// x86-64 ELF only: the relocation types and the relaxation are the
    /// x86-64 psABI's (on AArch64 the object addresses the area with
    /// ADRP/LDR GOT pairs, which `relax_context_got` leaves alone, and a
    /// COFF object -- Windows' -- has neither GOT nor ELF relocations: the
    /// relaxation is ELF's and a no-op there).
    #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
    #[test]
    fn the_object_addresses_the_area_with_relaxable_relocations_only() {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let object = emit_object(&program).unwrap_or_else(|e| panic!("{}", e.message()));
        let types: Vec<u64> = context_relocations(&object.bytes).iter().map(|r| r.1).collect();
        // Two functions use the area: each takes its address once.
        assert_eq!(types, vec![42, 42], "R_X86_64_REX_GOTPCRELX, never a plain GOTPCREL");
        let mut again = object.bytes.clone();
        assert_eq!(relax_context_got(&mut again), 0, "nothing left to relax");
    }

    #[test]
    fn the_jit_reads_and_writes_the_area() {
        use crate::runtime::metrics::AllocMode;
        use crate::runtime::vm::ProgramInfo;
        use std::rc::Rc;
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: true, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let clif = compiled.clif.clone().unwrap();
        assert!(clif.contains("symbol_value.i64"), "{clif}");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        let result = (compiled.entry)(&mut *vm);
        assert_eq!(result, (4 << 1) | 1, "f reads B's slot, the tagged small Int 4");
    }
}

/// MutableArray capacity/at/set compile to inline loads and stores (clif.rs's
/// `mutarray_capacity`, `mutarray_get`, `mutarray_set`), their helpers only
/// in cold blocks, and to helper calls when the run counts accesses
/// (CompileOptions::count_accesses); both compilations compute the same
/// values, copy-on-write included.
#[cfg(test)]
mod mutarray_inline_tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;
    use std::rc::Rc;

    /// A = create(4, 7); A[2] = 9 (a unique backing: the inline store);
    /// B = a logical copy of A; A[1] = 5 at a proven index (a shared
    /// backing: the helper detaches A); then B[1] * 100 + A[1] * 10 +
    /// capacity(B) + A[2] = 700 + 50 + 4 + 9 = 763, and A[INDEX], an
    /// IndexNotFound for INDEX 4, -1, a large small Int or a BigInt.
    fn program(index: &str) -> String {
        [
            "nir 1 call-effects=1 statics=0\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=24 pnames=\"\" captures=0\n",
            "    %0 = int 4\n    %1 = int 7\n    %2 = op mutarraycreate %0 %1\n",
            "    %3 = int 2\n    %4 = int 9\n    %5 = op mutarrayset %2 %3 %4\n",
            "    %6 = str \"h\"\n    %7 = op mvshare %2 %6\n",
            "    %8 = int 1\n    %9 = int 5\n    %10 = op mutarraysetproven %2 %8 %9\n",
            "    %11 = op mutarrayget %7 %8\n    %12 = op mutarraygetproven %2 %8\n",
            "    %13 = op mutarraycapacity %7\n    %14 = op mutarrayget %2 %3\n",
            "    %15 = int 100\n    %16 = op imul %11 %15\n    %17 = int 10\n    %18 = op imul %12 %17\n",
            "    %19 = op iadd %16 %18\n    %20 = op iadd %19 %13\n    %21 = op iadd %20 %14\n",
            &format!("    %22 = int {index}\n    %23 = op mutarrayget %2 %22\n"),
            "    ret %21\nend\n",
        ]
        .concat()
    }

    /// Compiles and runs PROGRAM; returns the CLIF, the result and the Vm.
    fn run(text: &str, count_accesses: bool) -> (String, Value, Box<Vm>) {
        let program = crate::nir::parse(text).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: true, vcode: false, alloc_sites: false, count_accesses };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mode = if count_accesses { AllocMode::Summary } else { AllocMode::Off };
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            mode,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        let result = (compiled.entry)(&mut *vm);
        (compiled.clif.clone().unwrap(), result, vm)
    }

    /// The calls to helper NAME in CLIF, each as whether its block is cold.
    fn calls(clif: &str, name: &str) -> Vec<bool> {
        let Some(id) = clif.lines().find_map(|l| l.strip_prefix("; u0:").and_then(|r| r.strip_suffix(&format!(" = {name}")))) else {
            return Vec::new();
        };
        let refs: Vec<String> = clif
            .lines()
            .filter_map(|l| l.trim().split_once(&format!(" = u0:{id} ")).map(|(f, _)| format!("call {f}(")))
            .collect();
        let mut cold = false;
        let mut out = Vec::new();
        for line in clif.lines() {
            if line.starts_with("block") {
                cold = line.contains(" cold:");
            } else if refs.iter().any(|r| line.contains(r.as_str())) {
                out.push(cold);
            }
        }
        out
    }

    #[test]
    fn mutarray_accesses_are_inline_and_agree_with_the_helpers() {
        let text = program("0");
        let (inline, result, vm) = run(&text, false);
        assert_eq!(result, make_small(763), "{inline}");
        assert!(calls(&inline, "rt_mutarray_capacity").is_empty(), "capacity is a load: {inline}");
        for helper in ["rt_mutarray_get", "rt_mutarray_set", "rt_mutarray_set_proven"] {
            let found = calls(&inline, helper);
            assert!(!found.is_empty() && found.iter().all(|&cold| cold), "{helper} only on a cold path: {inline}");
        }
        assert!(calls(&inline, "rt_mutarray_get_proven").is_empty(), "a proven read has no slow path: {inline}");
        // The copy, and the one detach its write made.
        assert_eq!((vm.metrics.mutarray.shares, vm.metrics.mutarray.detaches), (1, 1));

        let (counted, result, vm) = run(&text, true);
        assert_eq!(result, make_small(763), "{counted}");
        // Capacity counts nothing: still the load. No slot is accessed inline.
        assert!(calls(&counted, "rt_mutarray_capacity").is_empty(), "{counted}");
        assert!(!counted.contains("mutarray slots"), "every element access a helper: {counted}");
        for helper in ["rt_mutarray_get", "rt_mutarray_get_proven", "rt_mutarray_set", "rt_mutarray_set_proven"] {
            assert!(calls(&counted, helper).iter().any(|&cold| !cold), "{helper} called: {counted}");
        }
        assert_eq!((vm.metrics.mutarray_reads, vm.metrics.mutarray_writes), (4, 2), "every read and write counted");
        assert_eq!((vm.metrics.mutarray.shares, vm.metrics.mutarray.detaches), (1, 1));
    }

    #[test]
    fn an_inline_checked_read_out_of_bounds_is_the_helpers_index_not_found() {
        for index in ["4", "-1", "1099511627776", "99999999999999999999999"] {
            for count_accesses in [false, true] {
                let (clif, result, vm) = run(&program(index), count_accesses);
                assert_eq!(result, NO_VALUE, "index {index}: {clif}");
                assert_eq!(vm.declared_error, crate::runtime::error::ERR_INDEX_NOT_FOUND, "index {index}: IndexNotFound pending");
            }
        }
    }
}

/// The generic-entry wrapper of a function with the ShortString1 ABI
/// (SHORT-STRING.md). No Botlish program can reach it -- only a closed
/// instance has the ABI, and a Block value of one is rejected -- but it is
/// generated for every such function and must be correct by construction: a
/// tagged String in is converted to the scalar the direct function expects,
/// the scalar result is materialized, and an error-capable function's status
/// word becomes the ordinary 0 error sentinel. Called here directly through
/// the JIT'd entry pointer.
#[cfg(test)]
mod short_string_generic_entry_tests {
    use super::*;
    use crate::runtime::error::RtError;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::ops::GenericEntry;
    use crate::runtime::vm::ProgramInfo;
    use std::rc::Rc;

    /// func 1 echo(s): ShortString1 in, ShortString1 out, cannot fail.
    /// func 2 guarded(s, flag): ShortString1 in, flag tagged; raises when
    /// FLAG is true, else returns s (so an Empty result is a *success*).
    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n",
        "func 1 \"echo\" params=1 env=0 regs=1 pnames=\"s\" captures=0 shortregs=\"0\" shortparams=\"0\" shortresult=1\n    ret %0\nend\n\n",
        "func 2 \"guarded\" params=2 env=0 regs=2 pnames=\"s flag\" captures=0 shortregs=\"0\" shortparams=\"0\" shortresult=1\n",
        "    br %1 L0 L1\n  label L0\n    raise RANGE \"boom\"\n  label L1\n    ret %0\nend\n\n",
    );

    struct Rig {
        vm: Box<Vm>,
        compiled: CompiledProgram,
    }

    fn rig() -> Rig {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        Rig { vm, compiled }
    }

    fn call(rig: &mut Rig, func: usize, args: &[Value]) -> Value {
        let entry: GenericEntry = unsafe { std::mem::transmute(rig.compiled.generic_entries[func]) };
        entry(&mut *rig.vm, 0, args.as_ptr())
    }

    fn text(v: Value) -> String {
        str_of(v).as_str().to_string()
    }

    #[test]
    fn echo_entry_converts_a_tagged_string_in_and_out() {
        let mut r = rig();
        for text_in in ["", "a", "\u{0}", "\u{e9}", "\u{3bb}", "\u{732b}", "\u{1f600}", "\u{10ffff}"] {
            let arg = r.vm.new_str(text_in);
            let out = call(&mut r, 1, &[arg]);
            assert_ne!(out, NO_VALUE, "{text_in:?}");
            assert_eq!(text(out), text_in);
            assert_eq!(str_of(out).chars, text_in.chars().count());
        }
    }

    #[test]
    fn guarded_entry_returns_empty_as_a_success_and_failure_as_the_sentinel() {
        let mut r = rig();
        let empty = r.vm.new_str("");
        let ok = call(&mut r, 2, &[empty, FALSE]);
        assert_ne!(ok, NO_VALUE, "Empty is a successful value, never the error sentinel");
        assert_eq!(text(ok), "");
        let x = r.vm.new_str("x");
        let ok = call(&mut r, 2, &[x, FALSE]);
        assert_eq!(text(ok), "x");
        let failed = call(&mut r, 2, &[x, TRUE]);
        assert_eq!(failed, NO_VALUE);
        match r.vm.error.take() {
            Some(RtError::Semantic { kind, message }) => assert_eq!((kind, message.as_str()), ("RANGE", "boom")),
            other => panic!("expected the RANGE error, got {other:?}"),
        }
    }
}

/// The same for the packed-ASCII ABI (SHORT-STRING.md, tier A): a tagged ASCII
/// String of at most eight characters in is packed for the direct function,
/// the packed result is unpacked (a fresh String) and an error-capable
/// function's status word becomes the 0 error sentinel.
#[cfg(test)]
mod packed_ascii_generic_entry_tests {
    use super::*;
    use crate::runtime::error::RtError;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::ops::GenericEntry;
    use crate::runtime::vm::ProgramInfo;
    use std::rc::Rc;

    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n",
        "func 1 \"echo\" params=1 env=0 regs=1 pnames=\"s\" captures=0 asciiregs=\"0\" asciiparams=\"0\" asciiresult=1\n    ret %0\nend\n\n",
        "func 2 \"guarded\" params=2 env=0 regs=2 pnames=\"s flag\" captures=0 asciiregs=\"0\" asciiparams=\"0\" asciiresult=1\n",
        "    br %1 L0 L1\n  label L0\n    raise RANGE \"boom\"\n  label L1\n    ret %0\nend\n\n",
    );

    struct Rig {
        vm: Box<Vm>,
        compiled: CompiledProgram,
    }

    fn rig() -> Rig {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        Rig { vm, compiled }
    }

    fn call(rig: &mut Rig, func: usize, args: &[Value]) -> Value {
        let entry: GenericEntry = unsafe { std::mem::transmute(rig.compiled.generic_entries[func]) };
        entry(&mut *rig.vm, 0, args.as_ptr())
    }

    fn text(v: Value) -> String {
        str_of(v).as_str().to_string()
    }

    #[test]
    fn echo_entry_packs_and_unpacks_every_length() {
        let mut r = rig();
        for text_in in ["", "a", "ab", "\u{0}", "a\u{0}b", "\u{7f}", "abcdefg", "abcdefgh", "Hello, w"] {
            let arg = r.vm.new_str(text_in);
            let out = call(&mut r, 1, &[arg]);
            assert_ne!(out, NO_VALUE, "{text_in:?}");
            assert_eq!(text(out), text_in);
            assert_eq!(str_of(out).chars, text_in.chars().count());
            assert!(str_of(out).ascii);
        }
    }

    #[test]
    fn guarded_entry_returns_empty_as_a_success_and_failure_as_the_sentinel() {
        let mut r = rig();
        let empty = r.vm.new_str("");
        let ok = call(&mut r, 2, &[empty, FALSE]);
        assert_ne!(ok, NO_VALUE, "the empty word is a successful value, never the error sentinel");
        assert_eq!(text(ok), "");
        let word = r.vm.new_str("abc");
        let ok = call(&mut r, 2, &[word, FALSE]);
        assert_eq!(text(ok), "abc");
        let failed = call(&mut r, 2, &[word, TRUE]);
        assert_eq!(failed, NO_VALUE);
        match r.vm.error.take() {
            Some(RtError::Semantic { kind, message }) => assert_eq!((kind, message.as_str()), ("RANGE", "boom")),
            other => panic!("expected the RANGE error, got {other:?}"),
        }
    }
}

/// Stack probes (`stack_probes`): every host that needs them probes a large
/// frame page by page, and a function with a frame of many pages runs on a
/// fresh thread whose stack is committed as it grows -- on Windows, where a
/// thread's stack is committed one guard page at a time, the far end of an
/// unprobed frame of that size is uncommitted memory and the run would fault.
#[cfg(test)]
mod stack_probe_tests {
    use super::*;
    use cranelift_codegen::ir::{types, AbiParam, InstBuilder, MemFlagsData, StackSlotData, StackSlotKind};
    use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
    use cranelift_module::{Linkage, Module};

    #[test]
    fn a_frame_of_many_pages_is_probed_and_runs() {
        let isa = isa(false).expect("isa");
        assert_eq!(isa.flags().enable_probestack(), stack_probes());
        assert_eq!(stack_probes(), cfg!(windows) || crate::runtime::native_stack::native_stack_overflow_supported());
        if !stack_probes() {
            return;
        }
        assert_eq!(isa.flags().probestack_strategy(), settings::ProbestackStrategy::Inline);
        let mut module = JITModule::new(JITBuilder::with_isa(isa, cranelift_module::default_libcall_names()));
        let mut sig = module.make_signature();
        sig.returns.push(AbiParam::new(types::I64));
        let id = module.declare_function("big_frame", Linkage::Local, &sig).expect("declare");
        let mut ctx = module.make_context();
        ctx.func.signature = sig;
        let mut fbc = FunctionBuilderContext::new();
        let config = module.isa().frontend_config();
        {
            let mut b = FunctionBuilder::new(&mut ctx.func, &mut fbc);
            let block = b.create_block();
            b.switch_to_block(block);
            b.seal_block(block);
            // One MiB of frame, its lowest word -- the end farthest from the
            // committed part of the stack -- written first.
            let slot = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, 1 << 20, 3));
            let base = b.ins().stack_addr(types::I64, slot, 0);
            let v = b.ins().iconst(types::I64, 42);
            b.ins().store(MemFlagsData::trusted(), v, base, 0);
            let r = b.ins().load(types::I64, MemFlagsData::trusted(), base, 0);
            b.ins().return_(&[r]);
            b.finalize(config);
        }
        ctx.set_disasm(true);
        module.define_function(id, &mut ctx).expect("define");
        // The probe: Cranelift's page-by-page loop, in the prologue.
        let vcode = ctx.compiled_code().and_then(|code| code.vcode.clone()).unwrap_or_default();
        assert!(vcode.contains("stack_probe_loop"), "{vcode}");
        module.finalize_definitions().expect("finalize");
        let f: extern "C" fn() -> i64 = unsafe { std::mem::transmute(module.get_finalized_function(id)) };
        let result = std::thread::Builder::new().stack_size(4 << 20).spawn(move || f()).expect("thread").join().expect("join");
        assert_eq!(result, 42);
    }
}

/// The program object is the host target's object format: ELF on Linux,
/// Mach-O on macOS, COFF x86-64 (machine 0x8664, the same bytes for the MSVC
/// and the GNU environment) on Windows.
#[cfg(test)]
mod object_format_tests {
    use super::*;

    #[test]
    fn the_program_object_is_the_hosts_format() {
        let text = "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = int 7\n    ret %0\nend\n";
        let program = crate::nir::parse(text).unwrap_or_else(|e| panic!("{}", e.message));
        let bytes = emit_object(&program).unwrap_or_else(|e| panic!("{}", e.message())).bytes;
        if cfg!(target_os = "linux") {
            assert_eq!(&bytes[..4], b"\x7fELF");
        } else if cfg!(target_os = "macos") {
            assert_eq!(&bytes[..4], &0xfeedfacf_u32.to_le_bytes());
        } else if cfg!(all(windows, target_arch = "x86_64")) {
            // An IMAGE_FILE_HEADER: Machine IMAGE_FILE_MACHINE_AMD64 first.
            assert_eq!(&bytes[..2], &0x8664_u16.to_le_bytes());
        }
    }

    /// Windows x86-64's COFF object (made here on any host) describes every
    /// function to Windows' unwinder: `.pdata` holds one RUNTIME_FUNCTION
    /// per direct function and generic entry, in address order, each its
    /// function's start and end (`IMAGE_REL_AMD64_ADDR32NB` against the
    /// function's own symbol, the end's addend its size) and its
    /// UNWIND_INFO in `.xdata` (against that section). WINDOWS-X86-64-
    /// MILESTONE-3.md; aot-facts.tcl and dumpbin read the linked executable
    /// on Windows. An x86-64 host's: an AArch64 build has no x86-64 backend.
    #[cfg(target_arch = "x86_64")]
    #[test]
    fn a_windows_object_has_an_unwind_entry_for_every_function() {
        use cranelift_object::object::{Object, ObjectSection, ObjectSymbol, RelocationTarget};
        // `g` holds six values across its call: its frame saves callee-saved
        // registers, the others' do not, so each entry must name its own.
        let text = concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
            "    %0 = int 7\n    %1 = call 2 %0\n    ret %1\nend\n\n",
            "func 1 \"f\" params=1 env=0 regs=2 pnames=\"x\" captures=0\n",
            "    %1 = op listnew %0 %0\n    ret %1\nend\n\n",
            "func 2 \"g\" params=1 env=0 regs=15 pnames=\"x\" captures=0\n",
            "    %1 = op imul %0 %0\n    %2 = op iadd %1 %0\n    %3 = op imul %2 %0\n",
            "    %4 = op iadd %3 %1\n    %5 = op imul %4 %0\n    %6 = op iadd %5 %2\n",
            "    %7 = call 1 %0\n    %8 = op listlen %7\n",
            "    %9 = op iadd %8 %1\n    %10 = op iadd %9 %2\n    %11 = op iadd %10 %3\n",
            "    %12 = op iadd %11 %4\n    %13 = op iadd %12 %5\n    %14 = op iadd %13 %6\n    ret %14\nend\n",
        );
        let program = crate::nir::parse(text).unwrap_or_else(|e| panic!("{}", e.message));
        let object = emit_object_with(&program, isa_for("x86_64-pc-windows-msvc"), None).unwrap_or_else(|e| panic!("{}", e.message()));
        let file = cranelift_object::object::File::parse(&*object.bytes).unwrap();
        let pdata = file.section_by_name(".pdata").expect(".pdata");
        let xdata = file.section_by_name(".xdata").expect(".xdata");
        let text = file.section_by_name(".text").expect(".text");
        let xbytes = xdata.data().unwrap();
        let pbytes = pdata.data().unwrap();
        let relocations: Vec<_> = pdata.relocations().collect();
        let mut expected = Vec::new();
        for (i, f) in object.functions.iter().enumerate() {
            for (name, size, info) in [("botlish_fn", f.direct_size, &f.direct_unwind), ("botlish_entry", f.entry_size, &f.entry_unwind)] {
                let symbol = file.symbol_by_name(&format!("{name}_{i}")).unwrap();
                assert_eq!(symbol.section_index(), Some(text.index()));
                expected.push((symbol.address(), symbol.index(), size, info.clone().expect("every function has a frame")));
            }
        }
        expected.sort_by_key(|e| e.0);
        assert!(expected.iter().any(|e| e.3 != expected[0].3), "frames of more than one shape: {expected:x?}");
        assert_eq!(pbytes.len(), 12 * expected.len());
        assert_eq!(relocations.len(), 3 * expected.len());
        let xdata_symbol = file.symbols().find(|s| s.section_index() == Some(xdata.index()) && s.kind() == cranelift_object::object::SymbolKind::Section).unwrap();
        for (j, (_, symbol, size, info)) in expected.iter().enumerate() {
            let field = |k: usize| {
                let (offset, relocation) = &relocations[3 * j + k];
                assert_eq!(*offset, (12 * j + 4 * k) as u64);
                assert_eq!(relocation.flags(), cranelift_object::object::RelocationFlags::Coff { typ: cranelift_object::object::pe::IMAGE_REL_AMD64_ADDR32NB });
                let addend = u32::from_le_bytes(pbytes[12 * j + 4 * k..][..4].try_into().unwrap());
                (relocation.target(), addend)
            };
            assert_eq!(field(0), (RelocationTarget::Symbol(*symbol), 0), "entry {j}: the start");
            assert_eq!(field(1), (RelocationTarget::Symbol(*symbol), *size), "entry {j}: the end");
            let (target, at) = field(2);
            assert_eq!(target, RelocationTarget::Symbol(xdata_symbol.index()));
            assert_eq!(&xbytes[at as usize..at as usize + info.len()], &info[..], "entry {j}: its UNWIND_INFO");
        }
    }
}

/// Euclidean mod's three native forms (native/lower.tcl's "Euclidean mod"):
/// the raw `rimodtotal` (no zero test), the raw `rimod` (an inline zero test,
/// rt_int_mod's ARITHMETIC error on a cold path) and the tagged `imod`
/// (inline when both operands are small, rt_int_mod for a BigInt or a zero
/// divisor), each JIT-compiled and called over a grid of operands against an
/// independent reference (i128 / BigInt `rem_euclid`).
#[cfg(test)]
mod euclid_mod_tests {
    use super::*;
    use crate::runtime::error::RtError;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::ops::GenericEntry;
    use crate::nir::OpCode;
    use crate::runtime::vm::ProgramInfo;
    use num_bigint::BigInt;
    use num_traits::{Signed, Zero};
    use std::rc::Rc;

    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n    %0 = unit\n    ret %0\nend\n\n",
        "func 1 \"total\" params=2 env=0 regs=6 pnames=\"a b\" captures=0 rawregs=\"2 3 4\"\n",
        "    %2 = op runbox %0\n    %3 = op runbox %1\n    %4 = op rimodtotal %2 %3\n    %5 = op rbox %4\n    ret %5\nend\n\n",
        "func 2 \"checked\" params=2 env=0 regs=6 pnames=\"a b\" captures=0 rawregs=\"2 3 4\"\n",
        "    %2 = op runbox %0\n    %3 = op runbox %1\n    %4 = op rimod %2 %3\n    %5 = op rbox %4\n    ret %5\nend\n\n",
        "func 3 \"tagged\" params=2 env=0 regs=3 pnames=\"a b\" captures=0 rawregs=\"\"\n",
        "    %2 = op imod %0 %1\n    ret %2\nend\n\n",
    );

    const SMALL_MIN: i64 = -(1 << 62);
    const SMALL_MAX: i64 = (1 << 62) - 1;
    const SMALLS: [i64; 20] = [
        SMALL_MIN, SMALL_MIN + 1, -(1 << 61), -1025, -1024, -1000, -7, -3, -2, -1, 0, 1, 2, 3, 7, 1023, 1024,
        1 << 61, SMALL_MAX - 1, SMALL_MAX,
    ];

    struct Rig {
        vm: Box<Vm>,
        compiled: CompiledProgram,
    }

    fn rig() -> Rig {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        Rig { vm, compiled }
    }

    fn call(rig: &mut Rig, func: usize, args: &[Value]) -> Value {
        let entry: GenericEntry = unsafe { std::mem::transmute(rig.compiled.generic_entries[func]) };
        entry(&mut *rig.vm, 0, args.as_ptr())
    }

    fn reference(x: &BigInt, y: &BigInt) -> BigInt {
        let r = x % y;
        if r.is_negative() { r + y.abs() } else { r }
    }

    fn expect_division_by_zero(rig: &mut Rig) {
        match rig.vm.error.take() {
            Some(RtError::Semantic { kind, message }) => {
                assert_eq!((kind, message.as_str()), ("ARITHMETIC", "mod: division by zero"))
            }
            other => panic!("expected the ARITHMETIC error, got {other:?}"),
        }
    }

    #[test]
    fn raw_forms_agree_with_the_euclidean_reference_on_small_operands() {
        let mut r = rig();
        for &x in &SMALLS {
            for &y in SMALLS.iter().filter(|y| **y != 0) {
                let want = (x as i128).rem_euclid(y as i128) as i64;
                for func in [1, 2, 3] {
                    let got = call(&mut r, func, &[make_small(x), make_small(y)]);
                    assert_eq!(int_small(got), Some(want), "func {func}: mod({x}, {y})");
                }
            }
        }
    }

    #[test]
    fn a_zero_divisor_raises_the_helpers_error_from_the_checked_and_tagged_forms() {
        let mut r = rig();
        for &x in &SMALLS {
            for func in [2, 3] {
                let got = call(&mut r, func, &[make_small(x), make_small(0)]);
                assert_eq!(got, NO_VALUE, "func {func}: mod({x}, 0)");
                expect_division_by_zero(&mut r);
            }
        }
        let big = r.vm.new_big(BigInt::from(1u8) << 70u32);
        assert_eq!(call(&mut r, 3, &[big, make_small(0)]), NO_VALUE);
        expect_division_by_zero(&mut r);
    }

    #[test]
    fn the_tagged_form_takes_bigint_operands_to_the_helper() {
        let mut r = rig();
        let wide: Vec<BigInt> = [
            BigInt::from(SMALL_MAX) + 1,
            BigInt::from(SMALL_MIN) - 1,
            BigInt::from(i64::MAX),
            BigInt::from(i64::MIN),
            BigInt::from(1u8) << 64u32,
            -(BigInt::from(1u8) << 70u32) + BigInt::from(5),
            BigInt::from(7),
            BigInt::from(-7),
            BigInt::from(SMALL_MIN),
        ]
        .into_iter()
        .collect();
        for x in &wide {
            for y in wide.iter().filter(|y| !y.is_zero()) {
                // Under BOTLISH_NATIVE_GC_STRESS every allocation collects:
                // the first operand must be a root while the second is
                // allocated, and both while the helper allocates the result.
                let vx = r.vm.new_big(x.clone());
                r.vm.temp_roots.push(vx);
                let vy = r.vm.new_big(y.clone());
                r.vm.temp_roots.push(vy);
                let got = call(&mut r, 3, &[vx, vy]);
                r.vm.temp_roots.truncate(r.vm.temp_roots.len() - 2);
                assert_ne!(got, NO_VALUE, "mod({x}, {y})");
                assert_eq!(int_to_big(got), reference(x, y), "mod({x}, {y})");
            }
        }
    }

    #[test]
    fn only_the_tagged_form_is_a_safepoint_and_only_rimodtotal_cannot_fail() {
        use crate::runtime::ops::{op_may_allocate, op_may_error};
        assert!(op_may_allocate(OpCode::IMod) && op_may_error(OpCode::IMod));
        assert!(!op_may_allocate(OpCode::RIMod) && op_may_error(OpCode::RIMod));
        assert!(!op_may_allocate(OpCode::RIModTotal) && !op_may_error(OpCode::RIModTotal));
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let effects: Vec<(bool, bool)> = program.functions.iter().map(|f| (f.may_error, f.may_gc)).collect();
        assert_eq!(effects[1..], [(false, false), (true, false), (true, true)]);
        for op in [OpCode::RIMod, OpCode::RIModTotal] {
            assert!(op.raw_operands() && op.raw_result() && op.arity() == Some(2), "{op:?}");
        }
    }
}

/// C words compiled and run (C-FFI-ERROR-CAPTURE-MILESTONE-2.md): `cword`
/// constants of both kinds, the word comparisons against words and against
/// tagged Ints (small, negative, BigInt), and `cwbox` on both sides of the
/// small-Int boundary.
#[cfg(test)]
mod c_word_tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;
    use std::rc::Rc;

    #[test]
    fn c_word_comparisons_and_boxing_run() {
        let text = concat!(
            "nir 1 call-effects=1 statics=0\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=28 pnames=\"\" captures=0 u64regs=\"0 1 2 3\" i64regs=\"4 5 6\"\n",
            "    %0 = cword 18446744073709551615\n    %1 = cword 18446744073709551614\n",
            "    %2 = cword 4611686018427387904\n    %3 = cword 4611686018427387903\n",
            "    %4 = cword -9223372036854775808\n    %5 = cword -1\n    %6 = cword -4611686018427387905\n",
            "    %7 = int 0\n    %8 = int -1\n    %9 = int 18446744073709551614\n    %10 = int -9223372036854775809\n",
            "    %11 = op cwgt %0 %1\n    %12 = op cweq %0 %9\n    %13 = op cweq %1 %9\n    %14 = op cwlt %0 %7\n",
            "    %15 = op cwgt %0 %8\n    %16 = op cwlt %4 %8\n    %17 = op cwlt %4 %5\n    %18 = op cwge %2 %9\n",
            "    %19 = op cwgt %4 %10\n    %20 = op cwle %6 %8\n",
            "    %21 = op cwbox %0\n    %22 = op cwbox %4\n    %23 = op cwbox %5\n    %24 = op cwbox %2\n    %25 = op cwbox %3\n    %26 = op cwbox %6\n",
            "    %27 = op listnew %11 %12 %13 %14 %15 %16 %17 %18 %19 %20 %21 %22 %23 %24 %25 %26\n",
            "    ret %27\nend\n",
        );
        let program = crate::nir::parse(text).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Off,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        let result = (compiled.entry)(&mut *vm);
        assert_eq!(
            crate::runtime::show::show(result),
            "[true, false, true, false, true, true, true, false, true, true, 18446744073709551615, -9223372036854775808, -1, 4611686018427387904, 4611686018427387903, -4611686018427387905]"
        );
    }
}


/// A suspended coroutine's root, found while others collect
/// (WINDOWS-X86-64-MILESTONE-5.md, "GC correctness"): `body` builds a list --
/// its only reference, in body's own frame -- and yields; while it is
/// suspended, a second coroutine (`churner`) allocates in both its segments
/// and the program allocates between them, then body resumes, allocates
/// again and sums the list. Under GC stress every allocation collects
/// first, from three stacks in turn: the churner's (body's suspended stack
/// is walked from where its switch left, through the coroutine object the
/// program holds, and the program's own stack from where the churner's
/// resumer switched), the program's, and body's own after its resume. A
/// suspended stack's walk that missed body's frame would free the list,
/// which the collector poisons (`Heap::set_poison_for_test`): the sum would
/// read poison. On Windows every Botlish frame of every walk is also
/// unwound by Windows' unwinder and compared (BOTLISH_NATIVE_UNWIND_CHECK's
/// check: a suspended coroutine's frames are on a fiber's stack, unwound
/// from its switch's record). Wherever native coroutines run.
#[cfg(test)]
mod suspended_root_tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::{FunctionInfo, ProgramInfo};
    use std::rc::Rc;

    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1 statics=0\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=17 pnames=\"\" captures=0\n",
        "    %0 = int 7\n    %1 = closure 1 %0\n    %2 = op cocreate %1\n    %3 = op costart %2\n",
        "    %4 = fnvalue 6\n    %5 = op cocreate %4\n    %6 = op costart %5\n",
        "    %7 = int 40\n    %8 = call 3 %7\n",
        "    %9 = op coresume0 %5\n    %10 = op coresume0 %2\n",
        "    %11 = op corelease %5\n    %12 = op corelease %2\n",
        "    %13 = op iadd %3 %6\n    %14 = op iadd %13 %8\n    %15 = op iadd %14 %9\n    %16 = op iadd %15 %10\n    ret %16\nend\n\n",
        "func 1 \"\" params=0 env=1 regs=2 pnames=\"\" captures=1\n",
        "    %0 = capture 0\n    %1 = call 2 %0\n    ret %1\nend\n\n",
        "func 2 \"body\" params=1 env=0 regs=7 pnames=\"k\" captures=0\n",
        "    %1 = op listnew %0 %0 %0 %0 %0 %0 %0 %0\n    %2 = op listlen %1\n    %3 = op coyield %2\n",
        "    %4 = int 20\n    %5 = call 3 %4\n    %6 = call 4 %1\n    ret %6\nend\n\n",
        "func 3 \"churn\" params=1 env=0 regs=10 pnames=\"n\" captures=0\n",
        "    %1 = int 1\n    %2 = op ilt %0 %1\n    br %2 L0 L1\n",
        "  label L0\n    %3 = int 0\n    ret %3\n",
        "  label L1\n    %4 = int 999\n    %5 = op listnew %4 %4 %4 %4 %4 %4 %4 %4\n",
        "    %6 = op isub %0 %1\n    %7 = call 3 %6\n    %8 = op listlen %5\n    %9 = op iadd %7 %8\n    ret %9\nend\n\n",
        "func 4 \"sum\" params=1 env=0 regs=20 pnames=\"l\" captures=0\n",
        "    %1 = int 0\n    %2 = int 1\n    %3 = int 2\n    %4 = int 3\n    %5 = int 4\n    %6 = int 5\n    %7 = int 6\n    %8 = int 7\n",
        "    %9 = op listget %0 %1\n    %10 = op listget %0 %2\n    %11 = op listget %0 %3\n    %12 = op listget %0 %4\n",
        "    %13 = op listget %0 %5\n    %14 = op listget %0 %6\n    %15 = op listget %0 %7\n    %16 = op listget %0 %8\n",
        "    %17 = op iadd %9 %10\n    %17 = op iadd %17 %11\n    %17 = op iadd %17 %12\n    %17 = op iadd %17 %13\n",
        "    %17 = op iadd %17 %14\n    %17 = op iadd %17 %15\n    %17 = op iadd %17 %16\n    ret %17\nend\n\n",
        "func 5 \"unused\" params=0 env=0 regs=1 pnames=\"\" captures=0\n    %0 = int 0\n    ret %0\nend\n\n",
        "func 6 \"churner\" params=0 env=0 regs=4 pnames=\"\" captures=0\n",
        "    %0 = int 30\n    %1 = call 3 %0\n    %2 = op coyield %1\n    %3 = call 3 %0\n    ret %3\nend\n",
    );

    #[test]
    fn a_suspended_coroutines_root_survives_other_stacks_collections() {
        if !crate::runtime::coroutine::STACK_SWITCHING {
            return;
        }
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).unwrap_or_else(|e| panic!("{}", e.message()));
        #[cfg(all(windows, target_arch = "x86_64"))]
        crate::runtime::framewalk::windows::force_unwind_check();
        #[cfg(all(windows, target_arch = "x86_64"))]
        let checked = crate::runtime::framewalk::windows::checked_frames();
        for stress in [false, true] {
            let functions = [(0, ""), (0, ""), (1, "k"), (1, "n"), (1, "l"), (0, ""), (0, "")]
                .map(|(arity, pnames)| FunctionInfo { arity, pnames: pnames.into() })
                .into();
            let mut vm = Vm::new(
                Rc::new(ProgramInfo { functions, natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
                AllocMode::Off,
            );
            compiled.install_constants(&mut vm);
            vm.set_framemap(compiled.framemap.clone());
            vm.heap.set_stress_for_test(stress);
            vm.heap.set_poison_for_test(stress);
            let result = (compiled.entry)(&mut *vm);
            assert!(vm.error.is_none(), "stress {stress}: {:?}", vm.error.as_ref().map(|e| e.message()));
            // body's first yield (8), the churner's two segments (240 each),
            // the program's churn (320), body's sum of its list (56).
            assert_eq!(result, make_small(8 + 240 + 320 + 240 + 56), "stress {stress}");
            assert_eq!(vm.heap.collections > 0, stress);
        }
        #[cfg(all(windows, target_arch = "x86_64"))]
        assert!(crate::runtime::framewalk::windows::checked_frames() > checked, "Windows' unwinder checked no Botlish frame");
    }
}

/// A caller's live root, found while its callee collects
/// (WINDOWS-X86-64-MILESTONE-3.md, section 4): `<program>` builds a list,
/// holds it -- its only reference -- across three calls that reach `churn`:
/// one direct, one through a function value (`rt_call_value`, which jumps to
/// the closure's code: no frame of its own), and one from inside a Rust
/// frame, `mutable_array::generate`'s, whose factory `make` calls `churn`
/// (the runtime's frame stays between `make`'s and the caller's) -- and
/// sums it afterwards. Under GC stress every allocation of `churn` (a list
/// of eight 999s, the size of the caller's) collects first. A walk that
/// missed the caller's frame -- below its callee's, or above a Rust frame --
/// would free the list, and the collector poisons what it frees
/// (`Heap::set_poison_for_test`): the sum would read poison, however the
/// allocator reuses the memory (Windows' heap may not reuse it at all
/// before the sum). Every host's root plan:
/// native frames (the frame walk; on Windows across Rust frames by Windows'
/// unwinder) or the fallback plan's shadow stack (a `fallback-roots`
/// build).
#[cfg(test)]
mod caller_root_tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::{FunctionInfo, ProgramInfo};
    use std::rc::Rc;

    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1 statics=0\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=15 pnames=\"\" captures=0\n",
        "    %0 = int 7\n    %1 = int 11\n    %2 = int 13\n",
        "    %3 = op listnew %0 %1 %2 %0 %1 %2 %0 %1\n",
        "    %4 = fnvalue 2\n    %5 = int 30\n",
        "    %6 = callvalue %4 %5\n",
        "    %7 = call 2 %5\n",
        "    %11 = int 3\n    %12 = fnvalue 3\n    %13 = op mutarraygenerate %11 %12\n",
        "    %8 = call 1 %3\n",
        "    %9 = op iadd %6 %7\n    %10 = op iadd %9 %8\n    ret %10\nend\n\n",
        "func 1 \"sum\" params=1 env=0 regs=20 pnames=\"l\" captures=0\n",
        "    %1 = int 0\n    %2 = int 1\n    %3 = int 2\n    %4 = int 3\n    %5 = int 4\n    %6 = int 5\n    %7 = int 6\n    %8 = int 7\n",
        "    %9 = op listget %0 %1\n    %10 = op listget %0 %2\n    %11 = op listget %0 %3\n    %12 = op listget %0 %4\n",
        "    %13 = op listget %0 %5\n    %14 = op listget %0 %6\n    %15 = op listget %0 %7\n    %16 = op listget %0 %8\n",
        "    %17 = op iadd %9 %10\n    %17 = op iadd %17 %11\n    %17 = op iadd %17 %12\n    %17 = op iadd %17 %13\n",
        "    %17 = op iadd %17 %14\n    %17 = op iadd %17 %15\n    %17 = op iadd %17 %16\n    ret %17\nend\n\n",
        "func 2 \"churn\" params=1 env=0 regs=10 pnames=\"n\" captures=0\n",
        "    %1 = int 1\n    %2 = op ilt %0 %1\n    br %2 L0 L1\n",
        "  label L0\n    %3 = int 0\n    ret %3\n",
        "  label L1\n    %4 = int 999\n    %5 = op listnew %4 %4 %4 %4 %4 %4 %4 %4\n",
        "    %6 = op isub %0 %1\n    %7 = call 2 %6\n    %8 = op listlen %5\n    %9 = op iadd %7 %8\n    ret %9\nend\n\n",
        "func 3 \"make\" params=1 env=0 regs=3 pnames=\"i\" captures=0\n",
        "    %1 = int 10\n    %2 = call 2 %1\n    ret %2\nend\n",
    );

    #[test]
    fn a_callers_root_survives_its_callees_collections() {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(&program, &options).unwrap_or_else(|e| panic!("{}", e.message()));
        for stress in [false, true] {
            let functions = [(0, ""), (1, "l"), (1, "n"), (1, "i")].map(|(arity, pnames)| FunctionInfo { arity, pnames: pnames.into() }).into();
            let mut vm = Vm::new(
                Rc::new(ProgramInfo { functions, natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
                AllocMode::Off,
            );
            compiled.install_constants(&mut vm);
            vm.set_framemap(compiled.framemap.clone());
            vm.heap.set_stress_for_test(stress);
            vm.heap.set_poison_for_test(stress);
            let result = (compiled.entry)(&mut *vm);
            assert_eq!(result, make_small(240 + 240 + 80), "stress {stress}: churn(30) twice, and the caller's list summed after the generate");
            assert_eq!(vm.heap.collections > 0, stress);
        }
    }
}
