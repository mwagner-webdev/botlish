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

use crate::nir::{FuncId, Program};
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

/// A program compiled to machine code, ready to run.
pub struct CompiledProgram {
    pub entry: ProgramEntry,
    pub pool: ConstPool,
    /// Address of each function's generic entry.
    pub generic_entries: Vec<usize>,
    pub clif: Option<String>,
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
            table.push(raw as Value);
            statics.push(raw);
        }
        vm.set_constants(table, statics);
    }
}

pub struct CompileOptions {
    /// Keep the CLIF of every function.
    pub clif: bool,
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

impl Backend for CraneliftJit {
    fn compile(&mut self, program: &Program, options: &CompileOptions) -> Result<CompiledProgram, BackendError> {
        let mut builder = JITBuilder::with_isa(isa(false)?, cranelift_module::default_libcall_names());
        for (name, _, address) in helpers() {
            builder.symbol(name, address);
        }
        let mut module = JITModule::new(builder);
        let symbols = clif::declare(&mut module, program, false)?;
        let mut pool = ConstPool::default();
        let mut listing = options.clif.then(|| clif::legend(&symbols));
        for f in &program.functions {
            let text = clif::define(&mut module, &symbols, f, &mut pool, options.clif)?;
            if let (Some(listing), Some(text)) = (listing.as_mut(), text) {
                listing.push('\n');
                listing.push_str(&text);
            }
        }
        module.finalize_definitions().map_err(|e| BackendError::Codegen(format!("{e:?}")))?;
        let entry_ptr = module.get_finalized_function(symbols.direct[0]);
        let generic_entries = symbols.entry.iter().map(|id| module.get_finalized_function(*id) as usize).collect();
        let entry: ProgramEntry = unsafe { std::mem::transmute(entry_ptr) };
        Ok(CompiledProgram { entry, pool, generic_entries, clif: listing, _module: module })
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
    for f in &program.functions {
        clif::define(&mut module, &symbols, f, &mut pool, false)?;
    }
    let bytes = module.finish().emit().map_err(|e| BackendError::Codegen(e.to_string()))?;
    Ok((bytes, pool))
}
