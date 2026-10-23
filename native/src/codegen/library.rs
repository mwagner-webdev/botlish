//! The program descriptor in the program object, and a native library's C
//! entry points (NATIVE-LIBRARY-MILESTONE-1.md).
//!
//! Every program object `emit_object` writes carries its program descriptor
//! (runtime::program's module doc): `botlish_program`, global in an
//! executable's object (the generated startup crate names it) and local in
//! a library's, and `botlish_program_data`, always local.
//!
//! A library's object (nir::Program's `library`) also defines the library's
//! whole public C API, every function a C function in the platform C calling
//! convention (`target::c_call_conv`) named after the library:
//!
//! ```text
//!   LIB_abi_version, LIB_create, LIB_destroy      lifecycle
//!   LIB_error_*, LIB_bytes_release                 results the caller owns
//!   one function per export (nir::ExportDecl)      the exported functions
//! ```
//!
//! Each is a few instructions that forward to the runtime's library boundary
//! (runtime::library's `botlish_library_*`), adding the library's descriptor
//! where the runtime needs to know which program is meant. An export's
//! function stores its C arguments as machine words in a frame slot -- one
//! per argument, two for a `str`'s pointer and length, a C bool widened, a
//! double's bits -- and passes them with the export's index: every
//! conversion, check and call happens in the runtime, from the export's
//! description in the descriptor. Nothing else in the object is global, and
//! a library's final link localizes the runtime's own symbols too
//! (native/library.tcl), so the public API is the only interface two
//! libraries in one process share.
use super::clif::Symbols;
use super::{BackendError, ConstPool};
use crate::nir::{Boundary, Program};
use crate::runtime::program::{self, FunctionMeta, ProgramData};
use cranelift_codegen::ir::{self, types, AbiParam, InstBuilder, Signature, StackSlotData, StackSlotKind, UserFuncName};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use cranelift_module::{DataDescription, DataId, FuncId, Linkage, Module};

/// The descriptor's symbol: global in an executable's object.
pub const DESCRIPTOR_SYMBOL: &str = "botlish_program";
/// The encoded program data's symbol: always local.
pub const DESCRIPTOR_DATA_SYMBOL: &str = "botlish_program_data";
/// The version of the C API a library's header describes (LIB_ABI_VERSION).
pub const LIBRARY_ABI_VERSION: i64 = 1;

const I64: ir::Type = types::I64;
const I32: ir::Type = types::I32;

fn module_error(e: cranelift_module::ModuleError) -> BackendError {
    BackendError::Codegen(format!("{e:?}"))
}

/// Defines PROGRAM's descriptor (the module doc) from its compiled
/// functions FUNCTIONS and constant pool POOL. Returns the descriptor.
pub fn define_descriptor<M: Module>(
    module: &mut M,
    symbols: &Symbols,
    program: &Program,
    pool: &ConstPool,
    functions: &[super::clif::DefineResult],
) -> Result<DataId, BackendError> {
    let meta: Vec<FunctionMeta> = functions
        .iter()
        .map(|f| FunctionMeta { direct_size: f.direct_size, entry_size: f.entry_size, safepoints: f.safepoints.clone() })
        .collect();
    let encoded = ProgramData::of(program, pool.entries.clone(), meta).encode();
    let length = encoded.len() as u64;
    let data_id = module.declare_data(DESCRIPTOR_DATA_SYMBOL, Linkage::Local, false, false).map_err(module_error)?;
    let mut data = DataDescription::new();
    data.define(encoded.into_boxed_slice());
    data.set_align(8);
    module.define_data(data_id, &data).map_err(module_error)?;

    let linkage = if program.library.is_some() { Linkage::Local } else { Linkage::Export };
    let id = module.declare_data(DESCRIPTOR_SYMBOL, linkage, false, false).map_err(module_error)?;
    let n = program.functions.len();
    let mut bytes = Vec::with_capacity(program::DESCRIPTOR_HEADER_BYTES + 16 * n);
    for word in [
        program::DESCRIPTOR_MAGIC,
        program::DESCRIPTOR_FORMAT,
        crate::runtime::aotimage::abi_fingerprint(),
        0,
        length,
        n as u64,
    ] {
        bytes.extend_from_slice(&word.to_le_bytes());
    }
    bytes.resize(program::DESCRIPTOR_HEADER_BYTES + 16 * n, 0);
    let mut descriptor = DataDescription::new();
    descriptor.define(bytes.into_boxed_slice());
    descriptor.set_align(8);
    let blob = module.declare_data_in_data(data_id, &mut descriptor);
    descriptor.write_data_addr(24, blob, 0);
    for i in 0..n {
        let at = (program::DESCRIPTOR_HEADER_BYTES + 16 * i) as u32;
        let direct = module.declare_func_in_data(symbols.direct[i], &mut descriptor);
        descriptor.write_function_addr(at, direct);
        let entry = module.declare_func_in_data(symbols.entry[i], &mut descriptor);
        descriptor.write_function_addr(at + 8, entry);
    }
    module.define_data(id, &descriptor).map_err(module_error)?;
    Ok(id)
}

/// A C signature of the module's target: PARAMS, and RESULT if any.
fn c_signature<M: Module>(module: &M, params: &[ir::Type], result: Option<ir::Type>) -> Signature {
    let mut sig = module.make_signature();
    sig.call_conv = super::target::c_call_conv(module.isa().triple());
    sig.params.extend(params.iter().map(|t| AbiParam::new(*t)));
    sig.returns.extend(result.map(AbiParam::new));
    sig
}

/// One forwarding function of the public API: its name after the library
/// prefix, its C parameters and result, and the runtime function it calls
/// (with the descriptor's address first when `descriptor`).
struct Forward {
    name: &'static str,
    params: &'static [ir::Type],
    result: ir::Type,
    target: &'static str,
    descriptor: bool,
}

/// The library's API besides its exports (runtime::library has each
/// function's contract; the generated header states it for C).
const FORWARDS: &[Forward] = &[
    Forward { name: "create", params: &[I64, I64], result: I32, target: "botlish_library_create", descriptor: true },
    Forward { name: "destroy", params: &[I64], result: I32, target: "botlish_library_destroy", descriptor: true },
    Forward { name: "error_release", params: &[I64], result: I32, target: "botlish_library_error_release", descriptor: false },
    Forward { name: "error_status", params: &[I64], result: I32, target: "botlish_library_error_status", descriptor: false },
    Forward { name: "error_identity", params: &[I64, I64], result: I32, target: "botlish_library_error_identity", descriptor: false },
    Forward { name: "error_message", params: &[I64, I64], result: I32, target: "botlish_library_error_message", descriptor: false },
    Forward { name: "error_field_count", params: &[I64], result: I64, target: "botlish_library_error_field_count", descriptor: false },
    Forward { name: "error_field_name", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_name", descriptor: false },
    Forward { name: "error_field_kind", params: &[I64, I64], result: I32, target: "botlish_library_error_field_kind", descriptor: false },
    Forward { name: "error_field_int", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_int", descriptor: false },
    Forward { name: "error_field_bool", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_bool", descriptor: false },
    Forward { name: "error_field_float64", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_float64", descriptor: false },
    Forward { name: "error_field_str", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_str", descriptor: false },
    Forward { name: "error_field_text", params: &[I64, I64, I64], result: I32, target: "botlish_library_error_field_text", descriptor: false },
    Forward { name: "bytes_release", params: &[I64], result: I32, target: "botlish_library_bytes_release", descriptor: false },
];

/// Defines the public C API of PROGRAM's library (the module doc), reading
/// DESCRIPTOR. Nothing for an ordinary program.
pub fn define_api<M: Module>(module: &mut M, program: &Program, descriptor: DataId) -> Result<(), BackendError> {
    let Some(library) = &program.library else { return Ok(()) };
    let mut fctx = FunctionBuilderContext::new();
    let config = module.isa().frontend_config();

    // LIB_abi_version(void): the C API version this object implements.
    let sig = c_signature(module, &[], Some(I32));
    let id = module.declare_function(&format!("{library}_abi_version"), Linkage::Export, &sig).map_err(module_error)?;
    let mut ctx = module.make_context();
    ctx.func.signature = sig;
    ctx.func.name = UserFuncName::user(0, id.as_u32());
    {
        let mut b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
        let block = b.create_block();
        b.switch_to_block(block);
        b.seal_block(block);
        let version = b.ins().iconst(I32, LIBRARY_ABI_VERSION);
        b.ins().return_(&[version]);
        b.finalize(config);
    }
    module.define_function(id, &mut ctx).map_err(module_error)?;
    module.clear_context(&mut ctx);

    for forward in FORWARDS {
        let mut target_params: Vec<ir::Type> = Vec::new();
        if forward.descriptor {
            target_params.push(I64);
        }
        target_params.extend_from_slice(forward.params);
        let target_sig = c_signature(module, &target_params, Some(forward.result));
        let target = module.declare_function(forward.target, Linkage::Import, &target_sig).map_err(module_error)?;
        let sig = c_signature(module, forward.params, Some(forward.result));
        let id = module
            .declare_function(&format!("{library}_{}", forward.name), Linkage::Export, &sig)
            .map_err(module_error)?;
        define_forward(module, &mut fctx, id, sig, target, forward.descriptor.then_some(descriptor), |_, params| params.to_vec())?;
    }

    // One function per export: LIB-less, its own C symbol.
    let call_sig = c_signature(module, &[I64, I64, I64, I64, I64, I64], Some(I32));
    let call = module.declare_function("botlish_library_call", Linkage::Import, &call_sig).map_err(module_error)?;
    for (k, export) in program.exports.iter().enumerate() {
        // (instance, the arguments, the result's address unless unit, the
        // error's address)
        let mut params = vec![I64];
        for p in &export.params {
            match p {
                Boundary::Int => params.push(I64),
                Boundary::Bool => params.push(types::I8),
                Boundary::Float64 => params.push(types::F64),
                Boundary::Str => params.extend([I64, I64]),
                Boundary::Unit => unreachable!("nir rejects a unit parameter"),
            }
        }
        let has_result = export.result != Boundary::Unit;
        if has_result {
            params.push(I64);
        }
        params.push(I64);
        let sig = c_signature(module, &params, Some(I32));
        let id = module.declare_function(&export.symbol, Linkage::Export, &sig).map_err(module_error)?;
        let words = params.len() - 1 - 1 - usize::from(has_result);
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
            for (i, value) in values[1..1 + words].iter().enumerate() {
                let ty = b.func.dfg.value_type(*value);
                let word = if ty == types::I8 { b.ins().uextend(I64, *value) } else { *value };
                b.ins().stack_store(I64, word, slot, (8 * i) as i32);
            }
            let address = b.ins().stack_addr(I64, slot, 0);
            let gv = module.declare_data_in_func(descriptor, b.func);
            let descriptor_address = b.ins().symbol_value(I64, gv);
            let index = b.ins().iconst(I64, k as i64);
            let result = if has_result { values[1 + words] } else { b.ins().iconst(I64, 0) };
            let error = *values.last().unwrap();
            let callee = module.declare_func_in_func(call, b.func);
            let inst = b.ins().call(callee, &[descriptor_address, values[0], index, address, result, error]);
            let status = b.inst_results(inst)[0];
            b.ins().return_(&[status]);
            b.finalize(config);
        }
        module.define_function(id, &mut ctx).map_err(module_error)?;
        module.clear_context(&mut ctx);
    }
    Ok(())
}

/// Defines ID (signature SIG) as a call of TARGET with ARGS of its own
/// parameters, the descriptor's address first when DESCRIPTOR, returning
/// TARGET's result.
fn define_forward<M: Module>(
    module: &mut M,
    fctx: &mut FunctionBuilderContext,
    id: FuncId,
    sig: Signature,
    target: FuncId,
    descriptor: Option<DataId>,
    args: impl Fn(&mut FunctionBuilder, &[ir::Value]) -> Vec<ir::Value>,
) -> Result<(), BackendError> {
    let config = module.isa().frontend_config();
    let mut ctx = module.make_context();
    ctx.func.signature = sig;
    ctx.func.name = UserFuncName::user(0, id.as_u32());
    {
        let mut b = FunctionBuilder::new(&mut ctx.func, fctx);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        b.seal_block(block);
        let params = b.block_params(block).to_vec();
        let mut call_args = Vec::new();
        if let Some(descriptor) = descriptor {
            let gv = module.declare_data_in_func(descriptor, b.func);
            call_args.push(b.ins().symbol_value(I64, gv));
        }
        call_args.extend(args(&mut b, &params));
        let callee = module.declare_func_in_func(target, b.func);
        let inst = b.ins().call(callee, &call_args);
        let results = b.inst_results(inst).to_vec();
        b.ins().return_(&results);
        b.finalize(config);
    }
    module.define_function(id, &mut ctx).map_err(module_error)?;
    module.clear_context(&mut ctx);
    Ok(())
}
