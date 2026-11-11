//! A native library's public C functions (NATIVE-LIBRARY-MILESTONE-1.md):
//! machine code Cranelift writes into the library's program object, beside
//! the program's own functions, in the target's C calling convention.
//!
//! Two shapes, both small and fixed:
//!
//!   * a **forwarder** per runtime API function (`NAME_create`,
//!     `NAME_destroy`, the error accessors, `NAME_bytes_release`, ...: the
//!     table runtime::library::FORWARDERS): its arguments passed on unchanged
//!     to the runtime's `botlish_library_*` function, with the address of the
//!     library's program record (runtime::program's LinkedProgram,
//!     `botlish_program`) first where the program matters;
//!   * a **trampoline** per export (`NAME_FN`): its C arguments -- an int64_t,
//!     a bool, a double, a String's pointer and length -- stored as 64-bit
//!     words in a stack array, then one call of `botlish_library_call` with
//!     the program record, the instance, the export's index, the words, the
//!     result out-parameter (none for a unit result) and the error
//!     out-parameter.
//!
//! Everything a Botlish function does at the boundary -- checking the
//! instance and the thread, converting values, calling the export root's
//! generic entry, building results and errors -- is the runtime's
//! (runtime::library), written once for every library; nothing here knows a
//! Botlish value. Only these functions have a global symbol in the object:
//! the program's functions, its descriptor and its record are local
//! (`emit_library_object`), so two libraries' objects never share a name but
//! their public ones.
use super::BackendError;
use crate::nir::{Boundary, Program};
use crate::runtime::library::{CALL, FORWARDERS};
use cranelift_codegen::ir::types::{F64, I8, I32, I64};
use cranelift_codegen::ir::{AbiParam, InstBuilder, MemFlagsData, Signature, StackSlotData, StackSlotKind, UserFuncName};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use cranelift_module::{DataId, Linkage, Module};

/// Whether this host makes native libraries: Linux glibc on x86-64 and
/// AArch64, where the library's archive is made with GNU binutils' partial
/// link and symbol localization (native::library) and the runtime walks
/// frames by frame pointer up to the call's ceiling; and Windows x86-64 with
/// MSVC's toolchain (WINDOWS-X86-64-MILESTONE-8.md), where the library is a
/// DLL link.exe links from the program object and the runtime archive
/// (codegen::aot's `link_windows_library`), exporting exactly its public
/// functions, and the runtime walks Botlish frames by their records and the
/// others with Windows' unwinder, up to the call's ceiling.
pub const SUPPORTED: bool = cfg!(any(
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),
    all(target_os = "windows", target_env = "msvc", target_arch = "x86_64")
));

/// Whether a native library of TARGET is made: Linux glibc on x86-64 and
/// AArch64, and Android on AArch64 (ANDROID-AARCH64-TARGET-SUPPORT-
/// MILESTONE-1.md: an ELF shared object of the NDK's link, whose runtime --
/// Bionic's, from the target support package -- walks frames as Linux
/// AArch64's does). The library's own target, never this host's: an
/// Android library is made on a Linux x86-64 host.
pub fn supports(target: &target_lexicon::Triple) -> bool {
    use target_lexicon::{Architecture, Environment, OperatingSystem};
    let aarch64 = matches!(target.architecture, Architecture::Aarch64(_));
    match target.operating_system {
        OperatingSystem::Linux => match target.environment {
            Environment::Gnu => aarch64 || target.architecture == Architecture::X86_64,
            Environment::Android => aarch64,
            _ => false,
        },
        // Windows x86-64, MSVC's ABI (WINDOWS-X86-64-MILESTONE-8.md): a DLL,
        // made on its own host only (the driver's `library-dll`).
        OperatingSystem::Windows => target.environment == Environment::Msvc && target.architecture == Architecture::X86_64,
        _ => false,
    }
}

fn module_error(e: cranelift_module::ModuleError) -> BackendError {
    BackendError::Codegen(format!("{e:?}"))
}

/// A C signature in the module's target convention.
fn c_signature<M: Module>(module: &M, params: &[cranelift_codegen::ir::Type], result: Option<cranelift_codegen::ir::Type>) -> Signature {
    let mut sig = module.make_signature();
    sig.call_conv = super::target::c_call_conv(module.isa().triple());
    sig.params.extend(params.iter().map(|&t| AbiParam::new(t)));
    if let Some(t) = result {
        sig.returns.push(AbiParam::new(t));
    }
    sig
}

fn result_type(spelling: &str) -> Option<cranelift_codegen::ir::Type> {
    match spelling {
        "i32" | "u32" => Some(I32),
        "u64" => Some(I64),
        _ => None,
    }
}

/// A public C function `define` wrote: its id, its code's size and, where
/// the module's code is Windows x86-64's, its `UNWIND_INFO`
/// (codegen::unwind), which the object's `.pdata` and `.xdata` carry as
/// every Botlish function's do (codegen::add_windows_unwind): a trampoline
/// and a forwarder have frames, and Windows' unwinder -- an exception
/// dispatched through the call, a debugger's or a profiler's stack trace,
/// the host's own unwinding -- must never take one for a leaf
/// (WINDOWS-X86-64-MILESTONE-8.md, "Unwind information").
pub struct Defined {
    pub id: cranelift_module::FuncId,
    pub size: u32,
    pub unwind: Option<Vec<u8>>,
}

/// Defines the public C functions of library NAME over PROGRAM in MODULE,
/// RECORD being the program's `botlish_program` record. Returns each one's
/// `Defined`.
pub fn define<M: Module>(module: &mut M, program: &Program, name: &str, record: DataId) -> Result<Vec<Defined>, BackendError> {
    let mut defined = Vec::new();
    let mut fctx = FunctionBuilderContext::new();
    for &(suffix, runtime, words, result, with_program) in FORWARDERS {
        let ret = result_type(result);
        let public_sig = c_signature(module, &vec![I64; words], ret);
        let mut runtime_params = vec![I64; words];
        if with_program {
            runtime_params.insert(0, I64);
        }
        let runtime_sig = c_signature(module, &runtime_params, ret);
        let callee = module.declare_function(runtime, Linkage::Import, &runtime_sig).map_err(module_error)?;
        let id = module.declare_function(&format!("{name}_{suffix}"), Linkage::Export, &public_sig).map_err(module_error)?;
        let mut ctx = module.make_context();
        ctx.func.signature = public_sig;
        ctx.func.name = UserFuncName::user(0, id.as_u32());
        {
            let mut b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
            let block = b.create_block();
            b.append_block_params_for_function_params(block);
            b.switch_to_block(block);
            b.seal_block(block);
            let mut args: Vec<_> = b.block_params(block).to_vec();
            if with_program {
                let gv = module.declare_data_in_func(record, b.func);
                args.insert(0, b.ins().symbol_value(I64, gv));
            }
            let fref = module.declare_func_in_func(callee, b.func);
            let call = b.ins().call(fref, &args);
            let results = b.inst_results(call).to_vec();
            b.ins().return_(&results);
            b.finalize(module.isa().frontend_config());
        }
        module.define_function(id, &mut ctx).map_err(module_error)?;
        defined.push(compiled(module, &ctx, id, &format!("the forwarder {name}_{suffix}"))?);
        module.clear_context(&mut ctx);
    }

    let call_sig = c_signature(module, &[I64; 6], Some(I32));
    let call = module.declare_function(CALL, Linkage::Import, &call_sig).map_err(module_error)?;
    for (index, export) in program.exports.iter().enumerate() {
        // (instance, ARGS..., [out,] error) -> status
        let mut params = vec![I64];
        for p in &export.params {
            match p {
                Boundary::Int => params.push(I64),
                Boundary::Bool => params.push(I8),
                Boundary::Float64 => params.push(F64),
                Boundary::Str => params.extend([I64, I64]),
                Boundary::Unit => return Err(BackendError::Bug(format!("export {}: a unit parameter", export.symbol))),
            }
        }
        if export.result != Boundary::Unit {
            params.push(I64);
        }
        params.push(I64);
        let sig = c_signature(module, &params, Some(I32));
        let id = module.declare_function(&export.symbol, Linkage::Export, &sig).map_err(module_error)?;
        let words: usize = export.params.iter().map(|p| p.words()).sum();
        let mut ctx = module.make_context();
        ctx.func.signature = sig;
        ctx.func.name = UserFuncName::user(0, id.as_u32());
        {
            let mut b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
            let block = b.create_block();
            b.append_block_params_for_function_params(block);
            b.switch_to_block(block);
            b.seal_block(block);
            let values = b.block_params(block).to_vec();
            let slot = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, (8 * words.max(1)) as u32, 3));
            let mut next = 1;
            let mut offset = 0i32;
            for p in &export.params {
                let stored: Vec<_> = match p {
                    Boundary::Int => vec![values[next]],
                    Boundary::Bool => vec![b.ins().uextend(I64, values[next])],
                    Boundary::Float64 => vec![b.ins().bitcast(I64, MemFlagsData::new(), values[next])],
                    Boundary::Str => vec![values[next], values[next + 1]],
                    Boundary::Unit => unreachable!(),
                };
                next += if *p == Boundary::Str { 2 } else { 1 };
                for v in stored {
                    b.ins().stack_store(I64, v, slot, offset);
                    offset += 8;
                }
            }
            let out = if export.result != Boundary::Unit {
                next += 1;
                values[next - 1]
            } else {
                b.ins().iconst(I64, 0)
            };
            let error = values[next];
            let gv = module.declare_data_in_func(record, b.func);
            let program_address = b.ins().symbol_value(I64, gv);
            let export_index = b.ins().iconst(I64, index as i64);
            let words_address = b.ins().stack_addr(I64, slot, 0);
            let fref = module.declare_func_in_func(call, b.func);
            let status = b.ins().call(fref, &[program_address, values[0], export_index, words_address, out, error]);
            let status = b.inst_results(status)[0];
            b.ins().return_(&[status]);
            b.finalize(module.isa().frontend_config());
        }
        module.define_function(id, &mut ctx).map_err(module_error)?;
        defined.push(compiled(module, &ctx, id, &format!("the trampoline {}", export.symbol))?);
        module.clear_context(&mut ctx);
    }
    Ok(defined)
}

/// The `Defined` of function ID, just compiled in CTX.
fn compiled<M: Module>(module: &M, ctx: &cranelift_codegen::Context, id: cranelift_module::FuncId, what: &str) -> Result<Defined, BackendError> {
    let size = ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
    let unwind = super::clif::windows_unwind(module, ctx, what)?;
    Ok(Defined { id, size, unwind })
}
