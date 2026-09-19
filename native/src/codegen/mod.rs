//! Code generation backends for NIR.
//!
//! A backend turns a validated NIR program into something executable. The
//! only one today is Cranelift (`clif`), used two ways that share all of the
//! translation:
//!
//!   * JIT (`CraneliftJit`): compile in memory and run in this process
//!   * object (`emit_object`): an object file for AOT linking (smoke test
//!     only: a runnable executable would also need the runtime as a static
//!     library and a constant-table initializer)
//!
//! Semantics live in NIR and the runtime; nothing here may change what a
//! program means.

pub mod clif;
pub mod roots;

use crate::nir::{FuncId, Program};
use crate::runtime::heap::object_size;
use crate::runtime::ops::helpers;
use crate::runtime::value::*;
use crate::runtime::vm::{str_object, Vm};
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

/// A constant generated code loads from the VM's constant table.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Const {
    Str(String),
    BigInt(String),
    Native(u32),
    /// The closure of an environment-free function.
    FnValue(FuncId),
}

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
    pub clif: Option<String>,
    /// Pre-regalloc Cranelift VCode emitted by the lowering pipeline.
    pub vcode: Option<String>,
    /// Machine code bytes of each function (with its generic entry).
    pub code_sizes: Vec<u32>,
    /// Empty unless compiled with CompileOptions::alloc_sites.
    pub sites: Vec<Site>,
    /// Keeps the machine code alive.
    _module: JITModule,
}

impl CompiledProgram {
    /// Builds the VM's constant table: static objects for this program.
    pub fn install_constants(&self, vm: &mut Vm) {
        let mut table = Vec::with_capacity(self.pool.entries.len());
        let mut statics = Vec::new();
        for c in &self.pool.entries {
            let raw: *mut Header = match c {
                Const::Str(text) => Box::into_raw(Box::new(str_object(text.clone(), true))) as *mut Header,
                Const::BigInt(digits) => Box::into_raw(Box::new(BigIntObj {
                    hdr: Header::new(KIND_BIGINT, true),
                    n: digits.parse().expect("validated big Int literal"),
                })) as *mut Header,
                Const::Native(index) => Box::into_raw(Box::new(NativeObj {
                    hdr: Header::new(KIND_NATIVE, true),
                    native: *index,
                })) as *mut Header,
                Const::FnValue(func) => {
                    let caps: Box<[Value]> = Box::new([]);
                    Box::into_raw(Box::new(ClosureObj {
                        hdr: Header::new(KIND_CLOSURE, true),
                        func: *func,
                        arity: vm.info.functions[*func as usize].arity as u32,
                        code: self.generic_entries[*func as usize],
                        ncaps: 0,
                        caps: Box::into_raw(caps) as *mut Value,
                    })) as *mut Header
                }
            };
            if vm.metrics.enabled() {
                let bytes = unsafe { object_size(raw) } as u64;
                vm.record_static_alloc(unsafe { (*raw).kind }, bytes);
            }
            table.push(raw as Value);
            statics.push(raw);
        }
        vm.set_constants(table, statics);
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
}

/// A code generator for NIR programs.
pub trait Backend {
    fn compile(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError>;
}

fn isa(pic: bool) -> Result<OwnedTargetIsa, BackendError> {
    let mut flags = settings::builder();
    let set = |flags: &mut settings::Builder, k: &str, v: &str| {
        flags.set(k, v).map_err(|e| BackendError::Codegen(format!("setting {k}: {e}")))
    };
    set(&mut flags, "opt_level", "speed")?;
    set(&mut flags, "use_colocated_libcalls", "false")?;
    set(&mut flags, "is_pic", if pic { "true" } else { "false" })?;
    let isa = cranelift_native::builder().map_err(|e| BackendError::Codegen(e.to_string()))?;
    isa.finish(settings::Flags::new(flags)).map_err(|e| BackendError::Codegen(e.to_string()))
}

pub struct CraneliftJit;

impl CraneliftJit {
    fn compile_actual(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError> {
        let mut builder = JITBuilder::with_isa(isa(false)?, cranelift_module::default_libcall_names());
        for (name, _, address) in helpers() {
            builder.symbol(name, address);
        }
        let mut module = JITModule::new(builder);
        let symbols = clif::declare(&mut module, program, false)?;
        let mut pool = ConstPool::default();
        let mut sites = Vec::new();
        let mut listing = options.clif.then(|| clif::legend(&symbols));
        let mut code_sizes = Vec::with_capacity(program.functions.len());
        for f in &program.functions {
            let (text, size) =
                clif::define(&mut module, &symbols, f, &mut pool, &mut sites, options.alloc_sites, options.clif)?;
            code_sizes.push(size);
            if let (Some(listing), Some(text)) = (listing.as_mut(), text) {
                listing.push('\n');
                listing.push_str(&text);
            }
        }
        module.finalize_definitions().map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
        let entry_ptr = module.get_finalized_function(symbols.direct[0]);
        let generic_entries = symbols.entry.iter().map(|id| module.get_finalized_function(*id) as usize).collect();
        let entry: ProgramEntry = unsafe { std::mem::transmute(entry_ptr) };
        Ok(CompiledProgram { entry, pool, generic_entries, clif: listing, vcode: None, code_sizes, sites, _module: module })
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
        let buffer = VCODE_BUFFER.get_or_init(|| std::sync::Mutex::new(None));
        let mut guard = buffer.lock().unwrap();
        let text = guard.get_or_insert_with(String::new);
        let mut msg = record.args().to_string();
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
pub fn emit_object(program: &Program) -> Result<(Vec<u8>, ConstPool), BackendError> {
    let builder = cranelift_object::ObjectBuilder::new(isa(true)?, "botlish", cranelift_module::default_libcall_names())
        .map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
    let mut module = cranelift_object::ObjectModule::new(builder);
    let symbols = clif::declare(&mut module, program, true)?;
    let mut pool = ConstPool::default();
    let mut sites = Vec::new();
    for f in &program.functions {
        clif::define(&mut module, &symbols, f, &mut pool, &mut sites, false, false)?;
    }
    let bytes = module.finish().emit().map_err(|e| BackendError::Codegen(e.to_string()))?;
    Ok((bytes, pool))
}
