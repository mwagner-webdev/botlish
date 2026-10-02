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
pub mod roots;

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
    // Probe only large frames (default spacing: one 4 KiB page). Without
    // this, a large Cranelift frame can jump over pthread's guard entirely.
    if crate::runtime::native_stack::native_stack_overflow_supported() {
        set(&mut flags, "enable_probestack", "true")?;
        set(&mut flags, "probestack_strategy", "inline")?;
    }
    // Linked executables use the target's baseline ISA; only JIT code may
    // assume CPU features detected on the compiler's own machine.
    let isa = cranelift_native::builder_with_options(!pic).map_err(|e| BackendError::Codegen(e.to_string()))?;
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
        let mut defines = Vec::with_capacity(program.functions.len());
        for f in &program.functions {
            let result =
                clif::define(&mut module, &symbols, f, &mut pool, &mut sites, options.alloc_sites, options.clif)?;
            code_sizes.push(result.direct_size + result.entry_size);
            if let (Some(listing), Some(text)) = (listing.as_mut(), &result.clif_text) {
                listing.push('\n');
                listing.push_str(text);
            }
            defines.push(result);
        }
        module.finalize_definitions().map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
        let entry_ptr = module.get_finalized_function(symbols.direct[0]);
        let generic_entries: Vec<usize> =
            symbols.entry.iter().map(|id| module.get_finalized_function(*id) as usize).collect();
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
            let direct_addr = module.get_finalized_function(symbols.direct[f.id as usize]) as usize;
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
            clif: listing,
            vcode: None,
            code_sizes,
            sites,
            framemap: std::rc::Rc::new(framemap),
            statics: program.statics,
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
    let builder = cranelift_object::ObjectBuilder::new(isa(true)?, "botlish", cranelift_module::default_libcall_names())
        .map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
    let mut module = cranelift_object::ObjectModule::new(builder);
    let symbols = clif::declare(&mut module, program, true)?;
    let mut pool = ConstPool::default();
    let mut sites = Vec::new();
    let mut functions = Vec::new();
    for f in &program.functions {
        functions.push(clif::define(&mut module, &symbols, f, &mut pool, &mut sites, false, false)?);
    }
    let bytes = module.finish().emit().map_err(|e| BackendError::Codegen(e.to_string()))?;
    Ok(ObjectProgram { bytes, pool, functions })
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
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false };
        let compiled = CraneliftJit.compile(&program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }),
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
        str_of(v).text.to_string()
    }

    #[test]
    fn echo_entry_converts_a_tagged_string_in_and_out() {
        let mut r = rig();
        for text_in in ["", "a", "\u{0}", "\u{e9}", "\u{3bb}", "\u{732b}", "\u{1f600}", "\u{10ffff}"] {
            let arg = r.vm.new_str(text_in.to_string());
            let out = call(&mut r, 1, &[arg]);
            assert_ne!(out, NO_VALUE, "{text_in:?}");
            assert_eq!(text(out), text_in);
            assert_eq!(str_of(out).chars, text_in.chars().count());
        }
    }

    #[test]
    fn guarded_entry_returns_empty_as_a_success_and_failure_as_the_sentinel() {
        let mut r = rig();
        let empty = r.vm.new_str(String::new());
        let ok = call(&mut r, 2, &[empty, FALSE]);
        assert_ne!(ok, NO_VALUE, "Empty is a successful value, never the error sentinel");
        assert_eq!(text(ok), "");
        let x = r.vm.new_str("x".to_string());
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
