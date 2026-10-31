//! The C side of synchronous callbacks (C-CALLBACK-MILESTONE-1.md): machine
//! code Cranelift writes beside the program's functions, in the target's C
//! calling convention, for the runtime half (runtime::callback).
//!
//! Two shapes, both small and fixed, both local functions of the program's
//! object (or JIT module):
//!
//!   * a **transition shim** per call shape (foreign function, trailing
//!     arguments) of a C function that may call back (nir.rs's
//!     `callbacks=1`): the C call's own signature with the Vm first. It calls
//!     `rt_ffi_open(vm)`, then the C function (or its variadic stub) with
//!     its arguments unchanged, then `rt_ffi_close(vm, previous)`, and
//!     returns C's result. Botlish code calls it in place of the C function
//!     (codegen::clif's `foreign_call`), at the same safepoint. Its frame is
//!     what makes the transition walkable: Cranelift opens every frame that
//!     calls with a frame record (`push rbp; mov rbp, rsp`; `stp x29, x30`),
//!     so the shim's record holds the Botlish caller's frame pointer and its
//!     return address -- the call's safepoint -- exactly as any callee's
//!     does, and `rt_ffi_open` reads it from its own record's first word.
//!     The collector's walk of a callback jumps to it (framewalk's
//!     `walk_segmented`) and finds the caller's roots in its stack map;
//!   * a **callback entry point** per callback (nir.rs's `callback`): the
//!     callback's C signature -- each parameter of its class's machine type,
//!     a narrow integer or `_Bool` result extended by its signedness, a
//!     raw floating value's bits in the floating-point register of its
//!     finite counterpart -- that stores its C arguments as 64-bit words (an
//!     integer extended by its signedness, a `_Bool` zero-extended, a
//!     floating value's bits by `bitcast`: no conversion, so no NaN is
//!     quieted), calls `rt_callback_call(entry, desc, desc_len, words, out)`
//!     -- the function's generic entry, the callback's descriptor (a local
//!     read-only data object: runtime::callback's `descriptor`) -- and
//!     returns the result word OUT holds as its C type (a raw value's bits
//!     `bitcast` back into its floating-point register). `cbaddr N` is its
//!     address. It needs no symbol of its own: nothing but the program's
//!     own `cbaddr` names it, and no libffi, executable-memory trampoline or
//!     run-time code generation is involved -- a static function of the
//!     object, like any other.
//!
//! Everything a Botlish value is -- conversion, rooting, the activation, the
//! Vm -- is the runtime's: these functions know machine words only.
use super::clif::{c_call_signature, c_type, module_error, va_stub_for, Symbols};
use super::BackendError;
use crate::nir::{self, CAbi, Inst, Program};
use cranelift_codegen::ir::types::{F32, F64, I32, I64};
use cranelift_codegen::ir::{self, AbiParam, InstBuilder, MemFlagsData, Signature, StackSlotData, StackSlotKind, UserFuncName};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
use cranelift_module::{Linkage, Module};

/// Defines PROGRAM's transition shims and callback entry points in MODULE,
/// recording them in SYMBOLS (its `shims` and `callbacks`). SYMBOLS has the
/// runtime helpers, the foreign functions, the variadic stubs and every
/// function's generic entry declared.
pub fn define<M: Module>(module: &mut M, program: &Program, symbols: &mut Symbols) -> Result<(), BackendError> {
    let mut fctx = FunctionBuilderContext::new();
    for f in &program.functions {
        for inst in &f.body {
            let Inst::ForeignCall { foreign, varargs, .. } = inst else { continue };
            if !program.foreigns[*foreign as usize].callbacks {
                continue;
            }
            let key = (*foreign, varargs.clone());
            if symbols.shims.contains_key(&key) {
                continue;
            }
            let name = format!("botlish_transition_{foreign}_{}", symbols.shims.len());
            let (shim, shown) = shim(module, symbols, &mut fctx, *foreign, varargs, &name)?;
            symbols.callback_clif.push(format!("; transition shim {name} (C {})\n{shown}", program.foreigns[*foreign as usize].name));
            symbols.names.insert(shim.0.as_u32(), format!("{name} (transition shim of C {})", program.foreigns[*foreign as usize].name));
            symbols.shims.insert(key, shim);
        }
    }
    for (index, callback) in program.callbacks.iter().enumerate() {
        let name = format!("botlish_callback_{index}");
        let (id, shown) = entry_point(module, symbols, &mut fctx, index, callback, &name)?;
        symbols.callback_clif.push(format!("; callback entry point {name} (callback {})\n{shown}", callback.name));
        symbols.names.insert(id.as_u32(), format!("{name} (C entry point of callback {})", callback.name));
        symbols.callbacks.push(id);
    }
    Ok(())
}

/// The transition shim of the calls of foreign function FOREIGN passing the
/// trailing arguments VARARGS: its id and its signature.
fn shim<M: Module>(
    module: &mut M,
    symbols: &Symbols,
    fctx: &mut FunctionBuilderContext,
    foreign: u32,
    varargs: &[nir::VarArg],
    name: &str,
) -> Result<((cranelift_module::FuncId, Signature), String), BackendError> {
    let (import, decl) = symbols.foreigns[foreign as usize].clone();
    let (call_signature, _) = c_call_signature(&*module, &decl, varargs)?;
    // The C call's own signature, the Vm first. Without the extension
    // attributes: the shim's caller passes each narrow value as its type,
    // and the shim's own call of C extends it as C's signature says
    // (codegen::clif's `c_signature`) -- an attribute here would only move
    // a narrow parameter the Vm pushed onto the stack (Apple's stack slots
    // are of natural size: target::c_extended_parameters).
    let mut signature = call_signature.clone();
    for param in &mut signature.params {
        *param = AbiParam::new(param.value_type);
    }
    signature.params.insert(0, AbiParam::new(I64));
    let id = module.declare_function(name, Linkage::Local, &signature).map_err(module_error)?;
    let open = symbols.helpers["rt_ffi_open"];
    let close = symbols.helpers["rt_ffi_close"];
    let callee = match decl.variadic.then(|| va_stub_for(&*module, &call_signature)).flatten() {
        Some(kind) => *symbols.va_stubs.get(&(foreign, kind)).ok_or_else(|| {
            BackendError::Bug(format!("no {kind} stub for the variadic call of {}", decl.name))
        })?,
        None => import,
    };
    let mut ctx = module.make_context();
    ctx.func.signature = signature.clone();
    ctx.func.name = UserFuncName::user(0, id.as_u32());
    {
        let mut b = FunctionBuilder::new(&mut ctx.func, fctx);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        b.seal_block(block);
        let params = b.block_params(block).to_vec();
        let vm = params[0];
        let open = module.declare_func_in_func(open, b.func);
        let call = b.ins().call(open, &[vm]);
        let previous = b.inst_results(call)[0];
        let sig_ref = b.func.import_signature(call_signature);
        let user = b.func.declare_imported_user_function(ir::UserExternalName { namespace: 0, index: callee.as_u32() });
        let colocated = callee != import;
        let c = b.func.import_function(ir::ExtFuncData {
            name: ir::ExternalName::user(user),
            signature: sig_ref,
            colocated,
            patchable: false,
        });
        let call = b.ins().call(c, &params[1..]);
        let results = b.inst_results(call).to_vec();
        let close = module.declare_func_in_func(close, b.func);
        b.ins().call(close, &[vm, previous]);
        b.ins().return_(&results);
        b.finalize(module.isa().frontend_config());
    }
    let shown = ctx.func.display().to_string();
    module.define_function(id, &mut ctx).map_err(|e| BackendError::Codegen(format!("transition shim {name}: {e:?}")))?;
    module.clear_context(&mut ctx);
    Ok(((id, signature), shown))
}

/// The C signature of callback CALLBACK in the module's target convention.
fn entry_signature<M: Module>(module: &M, callback: &nir::CallbackDecl) -> Signature {
    let mut sig = module.make_signature();
    sig.call_conv = super::target::c_call_conv(module.isa().triple());
    sig.params.extend(callback.params.iter().map(|&c| AbiParam::new(c_type(c))));
    if callback.result != CAbi::Void {
        let param = AbiParam::new(c_type(callback.result));
        // A narrow integer or `_Bool` result extended to the register by its
        // signedness: whatever bits a C caller reads above its width are
        // then the value's (the ABIs leave them unspecified; this callee
        // defines them).
        sig.returns.push(match (callback.result.floating() || callback.result.bits() >= 64, callback.result.signed()) {
            (true, _) => param,
            (false, true) => param.sext(),
            (false, false) => param.uext(),
        });
    }
    sig
}

/// Callback INDEX's C entry point, CALLBACK its declaration.
fn entry_point<M: Module>(
    module: &mut M,
    symbols: &Symbols,
    fctx: &mut FunctionBuilderContext,
    index: usize,
    callback: &nir::CallbackDecl,
    name: &str,
) -> Result<(cranelift_module::FuncId, String), BackendError> {
    let signature = entry_signature(&*module, callback);
    let id = module.declare_function(name, Linkage::Local, &signature).map_err(module_error)?;
    let bytes = crate::runtime::callback::descriptor(&callback.params, callback.result, &callback.name);
    let desc = module
        .declare_data(&format!("botlish_callback_desc_{index}"), Linkage::Local, false, false)
        .map_err(module_error)?;
    let mut data = cranelift_module::DataDescription::new();
    data.define(bytes.clone().into_boxed_slice());
    module.define_data(desc, &data).map_err(module_error)?;
    let generic = *symbols.entry.get(callback.func as usize).ok_or_else(|| {
        BackendError::Bug(format!("callback {}: no function {}", callback.name, callback.func))
    })?;
    let call = symbols.helpers["rt_callback_call"];
    let mut ctx = module.make_context();
    ctx.func.signature = signature;
    ctx.func.name = UserFuncName::user(0, id.as_u32());
    {
        let mut b = FunctionBuilder::new(&mut ctx.func, fctx);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        b.seal_block(block);
        let params = b.block_params(block).to_vec();
        let words = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, (8 * params.len().max(1)) as u32, 3));
        let out = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, 8, 3));
        for (i, (&class, &v)) in callback.params.iter().zip(&params).enumerate() {
            let word = match class.machine_floating() {
                CAbi::F64 => b.ins().bitcast(I64, MemFlagsData::new(), v),
                CAbi::F32 => {
                    let bits = b.ins().bitcast(I32, MemFlagsData::new(), v);
                    b.ins().uextend(I64, bits)
                }
                _ if class.bits() >= 64 => v,
                _ if class.signed() => b.ins().sextend(I64, v),
                _ => b.ins().uextend(I64, v),
            };
            b.ins().stack_store(I64, word, words, (8 * i) as i32);
        }
        let generic = module.declare_func_in_func(generic, b.func);
        let entry = b.ins().func_addr(I64, generic);
        let desc = module.declare_data_in_func(desc, b.func);
        let desc = b.ins().symbol_value(I64, desc);
        let desc_len = b.ins().iconst(I64, bytes.len() as i64);
        let words = b.ins().stack_addr(I64, words, 0);
        let out_address = b.ins().stack_addr(I64, out, 0);
        let call = module.declare_func_in_func(call, b.func);
        b.ins().call(call, &[entry, desc, desc_len, words, out_address]);
        if callback.result == CAbi::Void {
            b.ins().return_(&[]);
        } else {
            let word = b.ins().stack_load(I64, I64, out, 0);
            let value = match callback.result.machine_floating() {
                CAbi::F64 => b.ins().bitcast(F64, MemFlagsData::new(), word),
                CAbi::F32 => {
                    let bits = b.ins().ireduce(I32, word);
                    b.ins().bitcast(F32, MemFlagsData::new(), bits)
                }
                _ if callback.result.bits() >= 64 => word,
                class => b.ins().ireduce(c_type(class), word),
            };
            b.ins().return_(&[value]);
        }
        b.finalize(module.isa().frontend_config());
    }
    let shown = ctx.func.display().to_string();
    module.define_function(id, &mut ctx).map_err(|e| BackendError::Codegen(format!("callback entry point {name}: {e:?}")))?;
    module.clear_context(&mut ctx);
    Ok((id, shown))
}

/// The C side of callbacks made for other targets than the host's, on an
/// x86-64 host (C-CALLBACK-MILESTONE-1.md, "Cross-target lowering"): an
/// object module of the target's own triple compiles a program's
/// transition shim and callback entry points, whose signatures are the
/// triple's C convention, never the host's -- System V on Linux and
/// macOS x86-64, Win64 on Windows (whose runtime refuses a callback, but
/// whose code is made like any other). Machine code is made, never run.
/// The driver's Cranelift has the host's ISA only (Cargo.toml), so the
/// AArch64 conventions are compiled -- and run -- on AArch64 hosts
/// (tests/c-callbacks.test there: CI's arm64 and macOS workflows).
#[cfg(all(test, target_arch = "x86_64"))]
mod tests {
    use super::super::{clif, isa_for};
    use cranelift_module::default_libcall_names;
    use cranelift_object::{ObjectBuilder, ObjectModule};

    /// A program with one callback of every class a callback takes -- a
    /// signed char, a raw double, a raw float, an unsigned 64-bit integer,
    /// a pointer, a `_Bool` and eleven ints past every convention's
    /// argument registers -- returning a signed char, and a call of a C
    /// function that may call back.
    const PROGRAM: &str = concat!(
        "nir 1\n",
        "callback 0 func=1 params=\"i8 rf64 rf32 u64 ptr bool i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32\" result=i8 name=\"m::cb\"\n",
        "callback 1 func=2 params=\"\" result=f64 name=\"m::half\"\n",
        "foreign 0 \"c_take\" params=\"ptr i32\" result=i32 callbacks=1 name=\"m::take\"\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=3 pnames=\"\" captures=0\n",
        "    %0 = cbaddr 0\n    %1 = int 1\n    %2 = foreigncall 0 %0 %1\n    ret %2\nend\n\n",
        "func 1 \"cb\" params=17 env=0 regs=18 pnames=\"a b c d e f g h i j k l m n o p q\" captures=0\n",
        "    %17 = int 0\n    ret %17\nend\n\n",
        "func 2 \"half\" params=0 env=0 regs=1 pnames=\"\" captures=0\n",
        "    %0 = float Float64 0x3fe0000000000000\n    ret %0\nend\n",
    );

    const TARGETS: [(&str, &str); 3] = [
        ("x86_64-unknown-linux-gnu", "system_v"),
        ("x86_64-apple-darwin", "system_v"),
        ("x86_64-pc-windows-msvc", "windows_fastcall"),
    ];

    fn declared(triple: &str) -> clif::Symbols {
        let program = crate::nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        let builder = ObjectBuilder::new(isa_for(triple), "callbacks", default_libcall_names()).unwrap();
        let mut module = ObjectModule::new(builder);
        let symbols = clif::declare(&mut module, &program, true, false).unwrap_or_else(|e| panic!("{triple}: {}", e.message()));
        // The shim and the entry points are defined (compiled) by declare.
        assert_eq!(symbols.callbacks.len(), 2, "{triple}");
        assert_eq!(symbols.shims.len(), 1, "{triple}");
        symbols
    }

    fn listing(symbols: &clif::Symbols, what: &str) -> String {
        symbols.callback_clif.iter().find(|t| t.contains(what)).unwrap_or_else(|| panic!("no {what}")).clone()
    }

    #[test]
    fn entry_points_take_the_targets_c_convention() {
        for (triple, convention) in TARGETS {
            let symbols = declared(triple);
            let entry = listing(&symbols, "botlish_callback_0 ");
            // Each parameter at its class's machine type -- the raw values
            // in the floating-point registers of their finite counterparts
            // -- and the narrow result sign-extended.
            let signature = "(i8, f64, f32, i64, i64, i8, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32) -> i8 sext";
            assert!(entry.contains(&format!("{signature} {convention}")), "{triple}: {entry}");
            // The raw values cross as their bits: bitcasts, never a float
            // conversion.
            assert!(entry.contains("bitcast.i64 v1"), "{triple}: {entry}");
            assert!(entry.contains("bitcast.i32 v2"), "{triple}: {entry}");
            assert!(!entry.contains("fpromote") && !entry.contains("fdemote") && !entry.contains("fcvt"), "{triple}: {entry}");
            let half = listing(&symbols, "botlish_callback_1 ");
            assert!(half.contains(&format!("() -> f64 {convention}")), "{triple}: {half}");
            assert!(half.contains("bitcast.f64"), "{triple}: {half}");
        }
    }

    #[test]
    fn a_transition_shim_brackets_the_c_call() {
        for (triple, convention) in TARGETS {
            let symbols = declared(triple);
            let shim = listing(&symbols, "transition shim");
            // The C call's own signature, the Vm first, no extension
            // attribute of its own; the C call keeps C's.
            assert!(shim.contains(&format!("(i64, i64, i32) -> i32 {convention}")), "{triple}: {shim}");
            assert!(shim.contains(&format!("(i64, i32 sext) -> i32 {convention}")), "{triple}: {shim}");
            // rt_ffi_open, then C, then rt_ffi_close, in that order.
            let calls: Vec<&str> = shim.lines().filter(|l| l.contains("= call fn")).collect();
            assert_eq!(calls.len(), 3, "{triple}: {shim}");
            assert!(calls[0].contains("call fn0(v0)") && calls[2].contains("(v0, "), "{triple}: {shim}");
        }
    }
}
