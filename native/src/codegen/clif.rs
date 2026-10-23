//! NIR to Cranelift IR, for any `cranelift_module::Module` (JIT or object).
//!
//! Function ABI (all words are I64, platform default calling convention):
//!
//! ```text
//!   botlish_fn_F(vm, a0, ..., an) -> Value            environment-free F
//!   botlish_fn_F(vm, closure, a0, ..., an) -> Value   F with environment
//!   botlish_entry_F(vm, closure, args*) -> Value      generic entry (Block code)
//! ```
//!
//! A result of 0 means an error is pending in the VM; every caller branches
//! to its own error exit, which restores any fallback root frame and returns 0.
//!
//! Frame layout: the prologue reserves this frame's physical root slots
//! (`codegen::roots::RootPlan::num_slots`), and every definition of a
//! rooted register is stored to its slot: one of the GC's precise root
//! sources (runtime/heap.rs). A slot is zeroed at frame entry only when
//! `RootPlan::entry_zero` says some reachable safepoint could otherwise
//! scan it before a real Value has been stored there (codegen::roots's
//! `entry_zero_slots`, F3b) -- not merely because the slot exists.
//! Register values live in Cranelift variables, so reads never touch
//! memory.
//!
//! Where those physical slots actually live depends on `RootPlan::storage`
//! (codegen::roots's `RootStorage`, see its own doc), and, for
//! `NativeFrame`, on `self.stack_maps` (this function's own copy of
//! `roots::plan`'s `native_frame_supported` argument --
//! runtime::framewalk's `NATIVE_FRAME_ROOTS`: x86-64 and AArch64 Linux and
//! macOS, x86-64 Windows):
//!
//!   * `RuntimeStack`: the shared shadow-stack array, indexed via
//!     `vm.ss_top`/`ss_limit`; at least one slot always, so the shared
//!     array's bounds check still bounds native recursion depth even for a
//!     function with zero roots (`prologue_runtime_stack`).
//!   * `NativeFrame`, x86-64 and AArch64 (`self.stack_maps`, the primary
//!     path this module implements): this function's own Cranelift-managed
//!     native stack slot (`self.root_slot`/`self.base`). No publish/restore
//!     of any kind -- the collector discovers these slots by walking the
//!     native call stack's frame-pointer chain (rbp, x29; on Windows,
//!     Windows' unwinder across the Rust frames between) and consulting
//!     Cranelift `UserStackMapEntry`s
//!     attached to each safepoint's own `call` instruction
//!     (`mark_safepoint`, runtime/framewalk.rs). Eligible for every
//!     function, called or not, recursive or not.
//!   * `NativeFrame`, fallback (`!self.stack_maps`, any other host, and
//!     the `fallback-roots` test build): the original, narrower mechanism --
//!     only eligible for a
//!     function with no Botlish call, published to `vm.native_roots_ptr`/
//!     `_len` (`prologue_native_frame`).
//!
//! On Linux and macOS the stack guard handles native overflow, so a calling
//! function has no Botlish-specific depth instructions. On Windows, whose
//! native frames hold the roots but which has no guard yet, a calling
//! function compares its stack pointer with the Vm's stack limit
//! (`prologue_stack_limit`); the fallback plan's `RuntimeStack` frames are
//! bounded by the shadow array's end.
//!
//! Whichever combination applies, `self.base` is simply "the address slot 0
//! lives at" for the rest of this file: `def`/`def_raw`/`zero_root_slots`
//! address every physical slot as `self.base + slot*8` without needing to
//! know which storage this turned out to be.
//!
//! Self tail calls (NIR `tail`) rebind the parameter variables and jump back
//! to the body block after the prologue: a CFG back edge, no call.

use super::roots::{self, RootPlan, RootStorage};
use super::{BackendError, Const, ConstPool, Site};
use crate::nir::{self, Inst, OpCode, Reg};
use crate::runtime::ops::helpers;
use crate::runtime::value::*;
use crate::runtime::vm::{
    VM_ALLOC_SITE_OFFSET, VM_CONSTS_OFFSET, VM_NATIVE_ROOTS_LEN_OFFSET, VM_NATIVE_ROOTS_PTR_OFFSET,
    VM_SS_LIMIT_OFFSET, VM_SS_TOP_OFFSET, VM_STACK_LIMIT_OFFSET, VM_STATICS_OFFSET,
};
use cranelift_codegen::ir::condcodes::{FloatCC, IntCC};
use cranelift_codegen::ir::{
    types, AbiParam, BlockArg, InstBuilder, MemFlagsData, Signature, StackSlotData, StackSlotKind,
    UserFuncName, UserStackMapEntry,
};
use cranelift_codegen::ir;
use cranelift_codegen::isa::CallConv;
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext, Variable};
use cranelift_module::{FuncId as ModuleFuncId, Linkage, Module};
use std::collections::HashMap;

const I64: ir::Type = types::I64;

pub struct Symbols {
    /// Per function: whether its direct function returns a raw Int result
    /// together with a status word (`raw_result` and `may_error`: see
    /// `physical_results`), so a call site checks the status word, not the
    /// value, for an error.
    pub status_result: Vec<bool>,
    pub direct: Vec<ModuleFuncId>,
    pub entry: Vec<ModuleFuncId>,
    pub helpers: HashMap<&'static str, ModuleFuncId>,
    /// Module function id -> symbol name, for readable CLIF listings.
    pub names: HashMap<u32, String>,
    /// Whether a call to a runtime helper should be emitted as a direct,
    /// PC-relative call (see `Translator::helper_ref`) instead of the
    /// address-then-indirect-call sequence Cranelift otherwise uses for a
    /// `Linkage::Import` callee (an imported symbol is never "colocated":
    /// `cranelift_module::Module::declare_func_in_func` sets
    /// `ExtFuncData::colocated` from `Linkage::is_final()`, which is false
    /// for `Import` -- see that method and `Linkage::is_final`'s doc).
    ///
    /// `helpers()` names the runtime's own extern "C" functions, always
    /// linked into the very same executable as the code calling them: on
    /// ELF/x86-64 (checked by `isa.name() == "x64"`; see below) a direct
    /// `call` to such a symbol is emitted with `R_X86_64_PLT32`, which the
    /// static linker resolves either straight to the definition (when it
    /// is local to this link unit, as it always is here) or through a PLT
    /// stub (if the symbol were ever satisfied by another shared object
    /// instead) -- both cases are already exactly how the recursive/direct
    /// Botlish calls this same backend emits are relocated (`Linkage::
    /// Local`/`Export` are `is_final`), so treating a known runtime helper
    /// the same way changes nothing about correctness, only which of two
    /// call sequences Cranelift's x64 backend selects. `colocated` means
    /// something else on other backends (e.g. AArch64's limited-range
    /// branch encoding, `ir::ExtFuncData::colocated`'s own doc), so this is
    /// restricted to the x64 backend specifically, not assumed in general.
    ///
    /// Only the AOT object backend (`emit_object`, `export == true`) sets
    /// this: the JIT backend already resolves a helper's call target to an
    /// absolute host address it computed itself (`CraneliftJit::compile`'s
    /// `builder.symbol`), which is unaffected by (and does not need) this
    /// distinction, and forcing `colocated` there would relax Cranelift's
    /// own rel32-range check on a real address this backend cannot vouch
    /// for the distance of.
    pub direct_helpers: bool,
    /// The program's context area (CONTEXTS.md, nir::Program::context_bytes):
    /// one linker-local, zero-initialized, writable data object, declared by
    /// `declare` when the program has context slots. Generated code reaches it
    /// through its symbol only -- no Vm field, no lookup, no extra argument.
    pub context_area: Option<cranelift_module::DataId>,
    /// Whether code addresses the context area PC-relatively (the AOT object,
    /// where the symbol is linker-local and so "colocated": Cranelift emits
    /// a GOT-relative load, which `mod.rs`'s `relax_context_got` marks
    /// relaxable so the static linker rewrites it to `lea
    /// botlish_context_area(%rip)`), or by its absolute address (`movabs`:
    /// the JIT, which places data and code independently, so a rel32 reach
    /// cannot be vouched for). Either way a fixed program address, never a
    /// lookup.
    pub context_pc_relative: bool,
    /// Per foreign function (nir::Program::foreigns, C-FFI.md): its imported
    /// symbol, declared with its C signature, and its declaration.
    pub foreigns: Vec<(ModuleFuncId, nir::ForeignDecl)>,
    /// The `%al` stubs of the program's variadic C calls on x86-64 System V
    /// (`va_stub`): (foreign index, vector register count) -> the stub's
    /// local function.
    pub va_stubs: HashMap<(u32, u32), ModuleFuncId>,
}

/// How many machine words F's direct function returns. Ordinarily
/// `f.results`; a raw-Int-result function (RAW-INT-ABI.md) that can fail
/// returns two: the raw integer and a status word (0 = an error is pending,
/// 1 = success), because the integer itself has no sentinel value -- errors
/// are never encoded in a magic integer. A raw-result function that cannot
/// fail (the settled `may_error` summary) returns just the integer: that is
/// the bare `i64 f(i64, ...)` shape.
fn physical_results(f: &nir::Function) -> usize {
    if f.scalar_result() && f.may_error {
        2
    } else {
        f.results as usize
    }
}

fn signature<M: Module>(module: &M, params: usize) -> Signature {
    signature_n(module, params, 1)
}

/// Like `signature`, with RESULTS return values instead of always one: a
/// scalar-replacement or string-region companion function
/// (nir::Function::results > 1) returns several tagged Values, one per
/// field of the fixed-shape aggregate its callers consume without ever
/// materializing the canonical List/String object (see native/lower.tcl's
/// "Scalar replacement"/"String regions" sections and nir.rs's
/// CallMulti/RetMulti).
///
/// RESULTS > 2 cannot return every field through an actual return register:
/// the target calling convention (x86-64 SysV here) has only two integer
/// return registers, and Cranelift's own ABI legalization rejects a bare
/// function signature declaring more ("Use a StructReturn argument
/// instead"). Such a function instead takes one extra trailing pointer
/// parameter (RESULTS-1 words of scratch, caller-allocated) and returns
/// only its first field normally; `Inst::RetMulti`/`Inst::CallMulti` (below)
/// store/load the rest through that pointer. This is purely a calling-
/// convention detail of a companion function Cranelift never exposes any
/// other way (never a closure, never a Block value, never called from
/// outside this same compilation): it changes nothing about NIR's own
/// `retmulti`/`callmulti` text, which still lists every field.
fn signature_n<M: Module>(module: &M, params: usize, results: usize) -> Signature {
    let mut sig = module.make_signature();
    for _ in 0..params {
        sig.params.push(AbiParam::new(I64));
    }
    if results > 2 {
        sig.params.push(AbiParam::new(I64));
        sig.returns.push(AbiParam::new(I64));
        return sig;
    }
    for _ in 0..results.max(1) {
        sig.returns.push(AbiParam::new(I64));
    }
    sig
}

/// The Cranelift type of C ABI class C (a pointer is a 64-bit word, a C
/// float and a C double the floating-point classes' F32 and F64: the C
/// type's own width, never its Float64 carrier's, C-FLOAT-FFI-MILESTONE-1.md).
fn c_type(c: nir::CAbi) -> ir::Type {
    if c == nir::CAbi::F32 {
        return types::F32;
    }
    if c == nir::CAbi::F64 {
        return types::F64;
    }
    match c.bits() {
        8 => types::I8,
        16 => types::I16,
        32 => types::I32,
        _ => I64,
    }
}

/// The C signature of foreign function DECL in the platform C calling
/// convention of the module's target (`target::c_call_conv`: AppleAarch64
/// on Apple AArch64, SystemV on Linux -- selected here explicitly, never the
/// Botlish-internal default by accident): each integer parameter of its
/// exact width, sign- or zero-extended by its class as the platform ABI
/// expects of a caller (the narrow ones, except Apple's stack-passed ones:
/// `target::c_extended_parameters`), a pointer a 64-bit word. The
/// result is declared without an extension attribute: the bits beyond a
/// narrow C result's width are unspecified by the ABI (GCC leaves them), so
/// the caller extends it itself (`ForeignCall`).
fn c_signature<M: Module>(module: &M, decl: &nir::ForeignDecl) -> Signature {
    let mut sig = module.make_signature();
    sig.call_conv = super::target::c_call_conv(module.isa().triple());
    let extended = super::target::c_extended_parameters(sig.call_conv);
    let mut integers = 0;
    for c in &decl.params {
        let param = AbiParam::new(c_type(*c));
        if c.floating() {
            // A float or a double takes a floating-point register: it has
            // no extension and leaves the integer registers' count alone.
            sig.params.push(param);
            continue;
        }
        let in_register = integers < extended;
        integers += 1;
        sig.params.push(match (c.bits() < 64 && in_register, c.signed()) {
            (true, true) => param.sext(),
            (true, false) => param.uext(),
            _ => param,
        });
    }
    if decl.result != nir::CAbi::Void {
        sig.returns.push(AbiParam::new(c_type(decl.result)));
    }
    sig
}

/// The machine signature of one call of foreign function DECL passing the
/// trailing arguments VARARGS (VARIADICS-VERTICAL-SLICE-1.md; DECL's own
/// `c_signature` when it is not variadic), and the padding parameters it
/// puts between the fixed and the trailing ones. A variadic call's
/// signature is the call's, not the declaration's: each call states its own
/// trailing arguments' promoted classes, so two calls of one C function may
/// pass different counts and types. Cranelift 0.135.2 has no notion of a
/// variadic call (nor does any release through 0.137): it places every
/// parameter of a signature as a named one, so the convention's variadic
/// rules are stated here by the signature's shape, never by a register or
/// a stack offset of Botlish's:
///
///   * System V (Linux x86-64 and AArch64): a trailing argument is passed
///     exactly as a named one of its promoted class (an `int` an I32, a
///     double an F64 in the next floating-point register, then the stack's
///     8-byte slots), so it is one more parameter. On x86-64 the caller also
///     states how many vector registers it used in %al (`va_stub`).
///   * AppleAarch64 ("Writing ARM64 code for Apple platforms"): every
///     trailing argument is on the stack, in its own 8-byte slot, however
///     many registers are free. The integer registers x0-x7 the fixed
///     parameters left free are filled with padding I64s, and v0-v7 with
///     padding F64s -- each kind only when a trailing argument of that kind
///     follows, counted apart as AAPCS64 does -- so Cranelift's assignment
///     of every later parameter is the stack, and each trailing argument is
///     an I64 (its value extended to 64 bits by its promoted class) or an
///     F64, whose natural slot is 8 bytes at 8-byte alignment: the slot
///     Apple's convention gives it, after any fixed stack argument.
fn c_call_signature<M: Module>(
    module: &M,
    decl: &nir::ForeignDecl,
    varargs: &[nir::VarArg],
) -> Result<(Signature, Vec<ir::Type>), BackendError> {
    let mut sig = c_signature(module, decl);
    if !decl.variadic {
        return Ok((sig, vec![]));
    }
    let apple = sig.call_conv == CallConv::AppleAarch64;
    if !apple && sig.call_conv != CallConv::SystemV {
        return Err(BackendError::Codegen(format!(
            "variadic C call of {}: no variadic call lowering for the {} convention",
            decl.name, sig.call_conv
        )));
    }
    let mut padding = vec![];
    if apple {
        let fixed_floatings = decl.params.iter().filter(|c| c.floating()).count();
        let fixed_integers = decl.params.len() - fixed_floatings;
        if varargs.iter().any(|a| a.promoted != nir::CAbi::F64) {
            padding.extend((fixed_integers..8).map(|_| I64));
        }
        if varargs.iter().any(|a| a.promoted == nir::CAbi::F64) {
            padding.extend((fixed_floatings..8).map(|_| types::F64));
        }
    }
    for t in &padding {
        sig.params.push(AbiParam::new(*t));
    }
    for a in varargs {
        let ty = if a.promoted == nir::CAbi::F64 {
            types::F64
        } else if apple {
            I64
        } else {
            c_type(a.promoted)
        };
        sig.params.push(AbiParam::new(ty));
    }
    Ok((sig, padding))
}

/// The number of vector registers a call of signature SIG uses on x86-64
/// System V (its F64 and F32 parameters -- a fixed C float takes one too --
/// at most xmm0-xmm7): what the caller of a variadic function states in %al.
fn vector_registers(sig: &Signature) -> u32 {
    sig.params.iter().filter(|p| p.value_type == types::F64 || p.value_type == types::F32).count().min(8) as u32
}

/// 1 if a variadic C call needs an `%al` stub on the module's target:
/// x86-64 System V.
fn needs_va_stub<M: Module>(module: &M) -> bool {
    module.isa().name() == "x64" && super::target::c_call_conv(module.isa().triple()) == CallConv::SystemV
}

/// Defines the `%al` stub of variadic calls of the foreign function IMPORT
/// using AL vector registers, as the local function ID: `mov $AL, %eax`,
/// then a jump to the C function, which returns to the stub's caller. System
/// V makes the caller of a variadic function state an upper bound of the
/// vector registers it passed arguments in, in %al (0 to 8), and Cranelift
/// has no way to give an argument or any value a fixed register at a call:
/// the stub is the one instruction it cannot place, emitted as machine code
/// through Cranelift's own `define_function_bytes`. It touches nothing else:
/// every argument register and the stack (the return address, the stack
/// arguments) are exactly as the call left them, rax is no argument
/// register, and r11 (the JIT form's) is the convention's scratch register.
/// In a PIC object the jump is `jmp SYMBOL@PLT` (R_X86_64_PLT32, as a C
/// compiler's tail call is); in the JIT, which places code independently of
/// the symbols it binds, `movabs $SYMBOL, %r11; jmp *%r11`. (The JIT never
/// runs a C call -- a program that calls C runs linked -- but compiles one
/// for its code: CLIF listings, sizes.)
fn va_stub<M: Module>(module: &mut M, id: ModuleFuncId, import: ModuleFuncId, al: u32) -> Result<(), BackendError> {
    let (bytes, offset, kind, addend) = va_stub_code(al, module.isa().flags().is_pic());
    let target = cranelift_module::ModuleRelocTarget::user(0, import.as_u32());
    let reloc = cranelift_module::ModuleReloc { offset, kind, name: target, addend };
    module.define_function_bytes(id, 16, &bytes, &[reloc]).map_err(module_error)
}

/// The `%al` stub's machine code for AL vector registers, and its one
/// relocation (its offset in the code, its kind, its addend): the PIC
/// object's form (PIC) or the JIT's (see `va_stub`).
fn va_stub_code(al: u32, pic: bool) -> (Vec<u8>, u32, cranelift_codegen::binemit::Reloc, i64) {
    let mut bytes = vec![0xb8];
    bytes.extend_from_slice(&al.to_le_bytes());
    if pic {
        bytes.extend_from_slice(&[0xe9, 0, 0, 0, 0]);
        (bytes, 6, cranelift_codegen::binemit::Reloc::X86CallPLTRel4, -4)
    } else {
        bytes.extend_from_slice(&[0x49, 0xbb, 0, 0, 0, 0, 0, 0, 0, 0, 0x41, 0xff, 0xe3]);
        (bytes, 7, cranelift_codegen::binemit::Reloc::Abs8, 0)
    }
}

fn module_error(e: cranelift_module::ModuleError) -> BackendError {
    BackendError::Codegen(format!("{e:?}"))
}

/// Declares the runtime helpers and every function of PROGRAM.
pub fn declare<M: Module>(module: &mut M, program: &nir::Program, export: bool) -> Result<Symbols, BackendError> {
    let direct_helpers = export && module.isa().name() == "x64";
    let mut symbols = Symbols {
        status_result: vec![],
        direct: vec![],
        entry: vec![],
        helpers: HashMap::new(),
        names: HashMap::new(),
        direct_helpers,
        context_area: None,
        context_pc_relative: export,
        foreigns: vec![],
        va_stubs: HashMap::new(),
    };
    if program.context_bytes > 0 {
        // The context area (CONTEXTS.md): every context slot, at the offsets
        // native/lower.tcl assigned, zero until the program function's own
        // `contextstore`s install the values. Linker-local (`Linkage::Local`
        // is "final", so the object backend may address it PC-relatively),
        // writable, not thread-local: process-wide storage of the main
        // execution domain.
        let id = module
            .declare_data("botlish_context_area", Linkage::Local, true, false)
            .map_err(module_error)?;
        let mut data = cranelift_module::DataDescription::new();
        data.define_zeroinit(program.context_bytes as usize);
        data.set_align(8);
        module.define_data(id, &data).map_err(module_error)?;
        symbols.context_area = Some(id);
    }
    for (name, params, _) in helpers() {
        let id = module.declare_function(name, Linkage::Import, &signature(module, params)).map_err(module_error)?;
        symbols.helpers.insert(name, id);
        symbols.names.insert(id.as_u32(), name.to_string());
    }
    for decl in &program.foreigns {
        // A C function (C-FFI.md): an imported symbol the system linker
        // resolves (the JIT's compile-only uses resolve it to a stub,
        // codegen/mod.rs), called with the platform C calling convention.
        let id = module
            .declare_function(&decl.symbol, Linkage::Import, &c_signature(module, decl))
            .map_err(module_error)?;
        symbols.names.insert(id.as_u32(), format!("{} (C {})", decl.symbol, decl.name));
        symbols.foreigns.push((id, decl.clone()));
    }
    if needs_va_stub(module) {
        // The %al stub of each (variadic C function, vector register count)
        // a call uses (`va_stub`), one local function each.
        for f in &program.functions {
            for inst in &f.body {
                let Inst::ForeignCall { foreign, varargs, .. } = inst else { continue };
                let (import, decl) = symbols.foreigns[*foreign as usize].clone();
                if !decl.variadic {
                    continue;
                }
                let al = vector_registers(&c_call_signature(module, &decl, varargs)?.0);
                if symbols.va_stubs.contains_key(&(*foreign, al)) {
                    continue;
                }
                let name = format!("botlish_va_{foreign}_{al}");
                let id = module
                    .declare_function(&name, Linkage::Local, &module.make_signature())
                    .map_err(module_error)?;
                va_stub(module, id, import, al)?;
                symbols.names.insert(id.as_u32(), format!("{name} (%al={al} stub of C {})", decl.name));
                symbols.va_stubs.insert((*foreign, al), id);
            }
        }
    }
    let linkage = if export { Linkage::Export } else { Linkage::Local };
    for f in &program.functions {
        let params = 1 + f.env as usize + f.params as usize;
        let name = format!("botlish_fn_{}", f.id);
        let id = module
            .declare_function(&name, linkage, &signature_n(module, params, physical_results(f)))
            .map_err(module_error)?;
        symbols.status_result.push(f.scalar_result() && f.may_error);
        symbols.names.insert(id.as_u32(), format!("{name} ({})", f.name));
        symbols.direct.push(id);
        // A results>1 function (a scalar-replacement companion) is only
        // ever reached through CallMulti/CallEnvMulti from other NIR this
        // same program emits: no closure or Block value ever points to it
        // (native/lower.tcl never hands one out as a value), so its generic
        // entry is dead code. It is still declared and defined -- as a
        // stub that never runs -- purely to keep `entry` indexed by FuncId
        // like `direct` (see `define`'s "results > 1" branch).
        let name = format!("botlish_entry_{}", f.id);
        let id = module.declare_function(&name, linkage, &signature(module, 3)).map_err(module_error)?;
        symbols.names.insert(id.as_u32(), name);
        symbols.entry.push(id);
    }
    Ok(symbols)
}

/// The result of compiling one NIR function: its CLIF (if requested), the
/// machine-code size of its direct entry and its generic entry separately
/// (codegen/mod.rs needs each function's own code range, not just their
/// sum), and its stack-map table -- see codegen::framemap's module doc.
pub struct DefineResult {
    pub clif_text: Option<String>,
    pub direct_size: u32,
    pub entry_size: u32,
    /// (return-addr offset within the direct function's own code, sorted
    /// live-root byte offsets from that safepoint's own SP): extracted from
    /// Cranelift's own `ir::UserStackMap`s (`mark_safepoint`'s
    /// `UserStackMapEntry`s, coalesced by the backend during emission),
    /// empty unless this function's `RootPlan::storage` is `NativeFrame` on
    /// the stack-map path. Never populated for the generic entry
    /// (`botlish_entry_N`): it is hand-built, not derived from NIR, and
    /// roots nothing of its own (see codegen::framemap's doc on why its
    /// code range is still registered, with an empty table).
    pub safepoints: Vec<(u32, Vec<u32>)>,
    /// The Windows x64 `UNWIND_INFO` of the direct function and of the
    /// generic entry (codegen::unwind), when the module's code is Windows
    /// x86-64's (`unwind::windows_x64`); None elsewhere. The AOT object
    /// writes them to `.xdata` (codegen::emit_object), the JIT registers
    /// them (codegen::jitunwind).
    pub direct_unwind: Option<Vec<u8>>,
    pub entry_unwind: Option<Vec<u8>>,
}

/// The Windows x64 `UNWIND_INFO` of the function just compiled in CTX, or
/// None where the module's code is not Windows x86-64's.
fn windows_unwind<M: Module>(module: &M, ctx: &cranelift_codegen::Context, what: &str) -> Result<Option<Vec<u8>>, BackendError> {
    if !super::unwind::windows_x64(module.isa()) {
        return Ok(None);
    }
    let code = ctx.compiled_code().ok_or_else(|| BackendError::Bug(format!("{what}: no compiled code")))?;
    super::unwind::unwind_info(code.buffer.data(), &code.buffer.unwind_info).map_err(|e| BackendError::Codegen(format!("{what}: {e}")))
}

/// Defines function F and its generic entry. Returns F's CLIF if LISTING,
/// the size in bytes of the machine code of each, and F's stack-map table.
pub fn define<M: Module>(
    module: &mut M,
    symbols: &Symbols,
    f: &nir::Function,
    pool: &mut ConstPool,
    sites: &mut Vec<Site>,
    instrument_sites: bool,
    count_accesses: bool,
    listing: bool,
) -> Result<DefineResult, BackendError> {
    let mut text = String::new();
    let mut ctx = module.make_context();
    let mut fctx = FunctionBuilderContext::new();

    ctx.func.signature = signature_n(module, 1 + f.env as usize + f.params as usize, physical_results(f));
    ctx.func.name = UserFuncName::user(0, symbols.direct[f.id as usize].as_u32());
    let config = module.isa().frontend_config();
    {
        let b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
        let mut t = Translator::new(b, module, symbols, f, pool, sites, instrument_sites, count_accesses);
        t.function()?;
        let Translator { mut b, .. } = t;
        b.seal_all_blocks();
        b.finalize(config);
    }
    if listing {
        text.push_str(&format!("; function {} \"{}\": botlish_fn_{}\n", f.id, f.name, f.id));
        text.push_str(&ctx.func.display().to_string());
    }
    module.define_function(symbols.direct[f.id as usize], &mut ctx).map_err(|e| {
        BackendError::Codegen(format!("function {} ({}): {e:?}", f.id, f.name))
    })?;
    let direct_size = ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
    let direct_unwind = windows_unwind(module, &ctx, &format!("function {} ({})", f.id, f.name))?;
    // Pull this function's stack maps out before `clear_context` drops them
    // (see `DefineResult::safepoints`'s own doc): `(CodeOffset, span,
    // ir::UserStackMap)` triples, one per safepoint `mark_safepoint`
    // actually attached entries to (see cranelift-codegen 0.135.2's
    // `machinst::buffer::MachBuffer::push_user_stack_map`, confirmed
    // against this pin: `CodeOffset` is the return address, i.e. the PC
    // immediately after that safepoint's own `call`). `entries()` yields
    // each live root's byte offset from that call's own stack pointer,
    // already fully resolved (Cranelift's own per-callsite `sp_to_sized_
    // stack_slots` accounting -- see `UserStackMap`'s doc).
    //
    // On AArch64 each offset is re-expressed as the root's distance *below
    // this function's own frame pointer* (`frame_to_fp_offset - offset`), the
    // form runtime::framewalk reads there: Cranelift's SP stays at the bottom
    // of the frame for the whole body, `frame_to_fp_offset` bytes below FP
    // (cranelift-codegen 0.135.2's `MachBufferFrameLayout`), so this is exact.
    // The walker cannot derive the SP from the callee's frame record as it
    // does on x86-64: LLVM's AArch64 Linux prologues put a Rust helper's
    // frame record at the bottom of its save area, not at its incoming SP.
    let below_fp = module.isa().name() == "aarch64";
    let mut safepoints: Vec<(u32, Vec<u32>)> = Vec::new();
    if let Some(code) = ctx.compiled_code() {
        let frame_to_fp = code.buffer.frame_layout().map(|layout| layout.frame_to_fp_offset);
        for (pc, _span, stack_map) in code.buffer.user_stack_maps() {
            let mut offsets: Vec<u32> = Vec::new();
            for (_ty, offset) in stack_map.entries() {
                if !below_fp {
                    offsets.push(offset);
                    continue;
                }
                match frame_to_fp.and_then(|fp| fp.checked_sub(offset)).filter(|&below| below > 0) {
                    Some(below) => offsets.push(below),
                    None => {
                        return Err(BackendError::Codegen(format!(
                            "function {} ({}): stack map root at SP+{offset} is not below the frame pointer ({frame_to_fp:?})",
                            f.id, f.name
                        )))
                    }
                }
            }
            offsets.sort_unstable();
            safepoints.push((*pc, offsets));
        }
    }
    module.clear_context(&mut ctx);

    // Generic entry: unpack the argument array and call the direct function.
    ctx.func.signature = signature(module, 3);
    ctx.func.name = UserFuncName::user(0, symbols.entry[f.id as usize].as_u32());
    if f.results != 1 {
        // A scalar-replacement companion (see nir::Function::results): no
        // closure or Block value ever points to this function (it is only
        // ever reached through CallMulti/CallEnvMulti from other NIR this
        // compilation emits), so its generic entry can never actually run.
        // Cranelift/cranelift-module still requires every declared function
        // to be defined, so this stub is that definition: it traps
        // immediately rather than mis-calling a multi-result function
        // through a single-result ABI.
        let mut fctx = FunctionBuilderContext::new();
        let mut b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        b.ins().trap(ir::TrapCode::unwrap_user(1));
        b.seal_all_blocks();
        b.finalize(config);
        module.define_function(symbols.entry[f.id as usize], &mut ctx).map_err(module_error)?;
        let entry_size = ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
        let entry_unwind = windows_unwind(module, &ctx, &format!("the generic entry of function {}", f.id))?;
        module.clear_context(&mut ctx);
        return Ok(DefineResult { clif_text: listing.then_some(text), direct_size, entry_size, safepoints, direct_unwind, entry_unwind });
    }
    {
        let mut fctx = FunctionBuilderContext::new();
        let mut b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        let params = b.block_params(block).to_vec();
        let mut args = vec![params[0]];
        if f.env {
            args.push(params[1]);
        }
        for i in 0..f.params {
            let mut v = b.ins().load(I64, MemFlagsData::trusted(), params[2], (i * 8) as i32);
            if f.raw_params[i as usize] {
                // The raw Int ABI (RAW-INT-ABI.md) is only planned for an
                // exact closed instance, which no Block value or dynamic
                // caller can reach, so this wrapper never runs; it still
                // converts so that the generic ABI is correct by
                // construction (a tagged small Int in, a raw integer out).
                v = b.ins().sshr_imm_s(v, 1);
            } else if f.short_params[i as usize] {
                // Likewise for the ShortString1 ABI (SHORT-STRING.md): never
                // reachable (only an exact closed instance has it), but
                // correct by construction -- a tagged String in, its
                // ShortString1 scalar out.
                let helper = module.declare_func_in_func(symbols.helpers["rt_str_to_short"], b.func);
                let call = b.ins().call(helper, &[params[0], v]);
                v = b.inst_results(call)[0];
            } else if f.ascii_params[i as usize] {
                // And for the packed-ASCII ABI: a tagged ASCII String in,
                // its packed word out (never reachable, correct anyway).
                let helper = module.declare_func_in_func(symbols.helpers["rt_str_to_ascii"], b.func);
                let call = b.ins().call(helper, &[params[0], v]);
                v = b.inst_results(call)[0];
            }
            args.push(v);
        }
        let callee = module.declare_func_in_func(symbols.direct[f.id as usize], b.func);
        let call = b.ins().call(callee, &args);
        let mut result = b.inst_results(call)[0];
        if f.raw_result {
            let shifted = b.ins().ishl_imm_s(result, 1);
            let tagged = b.ins().bor_imm_s(shifted, 1);
            result = if f.may_error {
                // The status word (nonzero = success): an error is the
                // ordinary 0 sentinel of the tagged ABI.
                let status = b.inst_results(call)[1];
                let zero = b.ins().iconst(I64, 0);
                b.ins().select(status, tagged, zero)
            } else {
                tagged
            };
        }
        if f.short_result || f.ascii_result {
            // A ShortString1 / packed-ASCII result is materialized for the
            // generic ABI (this wrapper never runs for it, see above), with
            // the same status-word convention as a raw result.
            let name = if f.short_result { "rt_short_to_str" } else { "rt_ascii_to_str" };
            let helper = module.declare_func_in_func(symbols.helpers[name], b.func);
            let call_status = if f.may_error { Some(b.inst_results(call)[1]) } else { None };
            let materialize = b.ins().call(helper, &[params[0], result]);
            let tagged = b.inst_results(materialize)[0];
            result = match call_status {
                Some(status) => {
                    let zero = b.ins().iconst(I64, 0);
                    b.ins().select(status, tagged, zero)
                }
                None => tagged,
            };
        }
        if f.plan_result {
            // A plan-result function (M8.a, nir::Function::plan_result) is
            // only ever given one when it is closed -- its every caller is
            // a direct call that knows the result may be a plan -- so this
            // generic entry is never expected to run. Defense in depth
            // anyway: the ordinary Value ABI must never see a plan, so the
            // result is materialized (rt_plan_materialize passes a flat
            // value, or the 0 error sentinel, through unchanged).
            let helper = module.declare_func_in_func(symbols.helpers["rt_plan_materialize"], b.func);
            let call = b.ins().call(helper, &[params[0], result]);
            result = b.inst_results(call)[0];
        }
        b.ins().return_(&[result]);
        b.seal_all_blocks();
        b.finalize(config);
    }
    module.define_function(symbols.entry[f.id as usize], &mut ctx).map_err(module_error)?;
    let entry_size = ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
    let entry_unwind = windows_unwind(module, &ctx, &format!("the generic entry of function {}", f.id))?;
    module.clear_context(&mut ctx);
    Ok(DefineResult { clif_text: listing.then_some(text), direct_size, entry_size, safepoints, direct_unwind, entry_unwind })
}

struct Translator<'a, 'b, M: Module> {
    b: FunctionBuilder<'b>,
    module: &'a mut M,
    symbols: &'a Symbols,
    f: &'a nir::Function,
    pool: &'a mut ConstPool,
    /// codegen/mod.rs's Site table: interned lazily, one entry per
    /// allocating instruction actually translated (see `mark_site`).
    sites: &'a mut Vec<Site>,
    instrument_sites: bool,
    /// Index into `f.body`/`f.origins` of the instruction being translated
    /// (set at the top of each iteration in `function`): `mark_site` reads
    /// `f.origins[current_index]` to attribute a site to its HIR expression.
    current_index: usize,
    vars: Vec<Variable>,
    closure: Option<Variable>,
    labels: HashMap<nir::Label, ir::Block>,
    vm: ir::Value,
    base: ir::Value,
    /// Fallback path (`!self.stack_maps`) `RootStorage::NativeFrame` with
    /// `num_slots > 0` only: the previous contents of `vm.native_roots_ptr`/
    /// `_len` (whatever the caller, or no one, had published there), saved
    /// once in the prologue and restored at every return path (see
    /// `restore_root_frame`). None on the stack-map path (nothing is ever
    /// published there at all -- see this file's header), for `RuntimeStack`
    /// (which restores `ss_top` from `base` instead), and for a `NativeFrame`
    /// function with zero physical slots (nothing was ever published, so
    /// nothing needs saving).
    saved_native_roots: Option<(ir::Value, ir::Value)>,
    /// The stack-map path's own Cranelift stack slot backing `self.base`,
    /// for `mark_safepoint` to attach `UserStackMapEntry`s against (needs
    /// the raw `ir::StackSlot`, not just its address). `Some` only when
    /// `self.stack_maps` and `self.plan.num_slots > 0` (mirrors
    /// `self.base`'s own validity on that path).
    root_slot: Option<ir::StackSlot>,
    /// Whether this compile targets the x86-64 native-stack-map path (see
    /// this file's header): `module.isa().name() == "x64"`, computed once,
    /// mirroring `Symbols::direct_helpers`'s own check. Never itself
    /// changes `self.plan` (already computed with the same value as
    /// `roots::plan`'s `native_frame_supported` argument) -- only which of
    /// the two `RootStorage::NativeFrame` sub-mechanisms `prologue_root_
    /// frame`/`restore_root_frame`/`mark_safepoint` use.
    stack_maps: bool,
    body: ir::Block,
    error_exit: ir::Block,
    /// Where `check`/`fail_with` currently branch on a NO_VALUE/failing
    /// result: this function's own `error_exit` outside any handled call,
    /// or (innermost last) a `handle`'s own dispatch label while lowering
    /// its wrapped call -- see Inst::PushErrorExit/PopErrorExit and
    /// EXPLICIT-ERROR-COMPLETIONS.md. Always non-empty: seeded with
    /// `error_exit` itself in `new`, never popped below that.
    error_exit_stack: Vec<ir::Block>,
    refs: HashMap<ModuleFuncId, ir::FuncRef>,
    /// This function's global value for the context area (`context_addr`),
    /// declared on first use.
    context_gv: Option<ir::GlobalValue>,
    terminated: bool,
    /// The hidden trailing pointer parameter of a `results > 2` function
    /// (signature_n): `RetMulti` writes fields 1.. through it instead of
    /// returning them. None for an ordinary (`results <= 2`) function.
    result_buf: Option<ir::Value>,
    /// Which shadow-stack slot (if any) each register needs: codegen::roots's
    /// safepoint-liveness analysis, computed once per function before
    /// translation begins. Replaces the old "one slot per register" policy
    /// (see this file's header and `def`/`def_raw`).
    plan: RootPlan,
    /// Whether `op listget` inlines its check-and-load fast path (`list::at`
    /// below) instead of always calling `rt_list_get`. On by default;
    /// BOTLISH_NATIVE_LISTGET_FAST_OPT=0 disables it, for differential
    /// testing and benchmark comparison (mirrors heap.rs's
    /// BOTLISH_NATIVE_GC_STRESS/MIN: a plain env var read once, since this
    /// is a pure Cranelift-codegen choice, not something native/lower.tcl's
    /// NIR emission needs to know about).
    listget_fast: bool,
    /// Whether `op mutarraycapacity` is the inline load of the header's LEN
    /// word (`mutarray_capacity` below) instead of a `rt_mutarray_capacity`
    /// call. On by default; BOTLISH_NATIVE_MUTARRAY_INLINE_OPT=0 disables
    /// every inline MutableArray path (this one and `mutarray_access`), for
    /// differential testing and benchmark comparison (like `listget_fast`).
    mutarray_inline: bool,
    /// Whether `op mutarrayget`/`mutarraygetproven`/`mutarrayset`/
    /// `mutarraysetproven` are inline loads and stores through the header's
    /// LEN/PTR/UNIQUE words (`mutarray_get`, `mutarray_set` below), their
    /// helpers only on a slow path: `mutarray_inline`, unless the program
    /// counts MutableArray reads and writes (CompileOptions::count_accesses:
    /// only the helpers count them).
    mutarray_access: bool,
    /// Whether the prologue zeroes only the physical shadow slots F3b's
    /// per-slot definite-initialization analysis (codegen::roots's
    /// `RootPlan::entry_zero`) says still need it, instead of eagerly
    /// zeroing every slot the way F3 originally did. On by default;
    /// BOTLISH_NATIVE_ROOT_INIT_OPT=0 restores the old eager-zero-every-slot
    /// policy, for differential testing (mirrors `listget_fast`'s own env
    /// var, same reasoning).
    root_init_opt: bool,
}

impl<'a, 'b, M: Module> Translator<'a, 'b, M> {
    fn new(
        mut b: FunctionBuilder<'b>,
        module: &'a mut M,
        symbols: &'a Symbols,
        f: &'a nir::Function,
        pool: &'a mut ConstPool,
        sites: &'a mut Vec<Site>,
        instrument_sites: bool,
        count_accesses: bool,
    ) -> Self {
        let vars = (0..f.regs).map(|_| b.declare_var(I64)).collect();
        let closure = f.env.then(|| b.declare_var(I64));
        let body = b.create_block();
        let error_exit = b.create_block();
        let placeholder = ir::Value::from_u32(0);
        // The native-stack-map frame-walker (runtime/framewalk.rs) is
        // implemented for x86-64 and AArch64, verified against this repo's
        // pinned Cranelift and its own generated assembly (see this file's
        // header, and `define`'s safepoint extraction for AArch64's
        // frame-pointer-relative roots), and runs on the hosts whose Rust
        // frames it can climb: runtime::framewalk's NATIVE_FRAME_ROOTS, the
        // one capability roots::report, the walk and Vm::new's shadow stack
        // read too. Every other host -- Windows -- keeps the original,
        // narrower RootStorage::NativeFrame rule (roots::plan's own doc).
        let stack_maps = crate::runtime::framewalk::NATIVE_FRAME_ROOTS;
        assert!(
            !stack_maps || matches!(module.isa().name(), "x64" | "aarch64"),
            "native-frame roots on an ISA the frame walk does not know"
        );
        let plan = roots::plan(f, stack_maps);
        let listget_fast = std::env::var("BOTLISH_NATIVE_LISTGET_FAST_OPT").ok().as_deref() != Some("0");
        let mutarray_inline = std::env::var("BOTLISH_NATIVE_MUTARRAY_INLINE_OPT").ok().as_deref() != Some("0");
        let root_init_opt = std::env::var("BOTLISH_NATIVE_ROOT_INIT_OPT").ok().as_deref() != Some("0");
        Translator {
            b,
            module,
            symbols,
            f,
            pool,
            sites,
            instrument_sites,
            // Not yet inside `f.body` (still building the prologue): an
            // out-of-range sentinel, so a call the prologue itself emits
            // (`rt_stack_overflow` past the stack limit) can never
            // accidentally match a real safepoint's index and have stack-map
            // entries misattached to it (`mark_safepoint`'s own guard).
            current_index: usize::MAX,
            vars,
            closure,
            labels: HashMap::new(),
            vm: placeholder,
            base: placeholder,
            saved_native_roots: None,
            root_slot: None,
            stack_maps,
            body,
            error_exit,
            error_exit_stack: vec![error_exit],
            refs: HashMap::new(),
            context_gv: None,
            terminated: false,
            plan,
            result_buf: None,
            listget_fast,
            mutarray_inline,
            mutarray_access: mutarray_inline && !count_accesses,
            root_init_opt,
        }
    }

    fn function(&mut self) -> Result<(), BackendError> {
        let f = self.f;
        let entry = self.b.create_block();
        self.b.append_block_params_for_function_params(entry);
        self.b.switch_to_block(entry);
        let params = self.b.block_params(entry).to_vec();
        self.vm = params[0];

        // Prologue: reserve and clear this frame's physical root slots,
        // wherever they live (see `prologue_root_frame`).
        self.prologue_root_frame();
        let mut next = 1;
        if let Some(closure) = self.closure {
            self.b.def_var(closure, params[1]);
            next = 2;
        }
        for i in 0..f.params {
            let v = params[next + i as usize];
            if f.raw_params[i as usize] {
                // Raw Int ABI (RAW-INT-ABI.md): the incoming argument is
                // already a raw signed machine integer, the proven-small
                // value itself -- no tag test, no unboxing, nothing to
                // re-check (the exact-call plan is the proof).
                self.def_raw(i, v);
            } else if f.short_params[i as usize] || f.ascii_params[i as usize] {
                // ShortString1 ABI (SHORT-STRING.md): the incoming argument
                // is already the scalar -- -1 Empty or the one character's
                // Unicode scalar value -- or, for the packed-ASCII ABI, the
                // packed word; never a GC root.
                self.def_raw(i, v);
            } else if f.raw_regs[i as usize] {
                // native/lower.tcl proved this parameter's whole range fits
                // the small-Int representation (RawParams): unbox the
                // incoming tagged argument once, here, so it stays raw for
                // the rest of the function, including every self-tail
                // backedge (Inst::Tail/TailEnv below) -- spec's "prove/unbox
                // once" (native/lower.tcl's Representation section, #9).
                let unboxed = self.b.ins().sshr_imm_s(v, 1);
                self.def_raw(i, unboxed);
            } else {
                self.def(i, v);
            }
        }
        if f.results > 2 {
            // The hidden trailing pointer parameter signature_n adds for a
            // `results > 2` companion: never a GC root itself (it points to
            // the caller's own stack, not the heap), so it is read once here
            // and never stored to the shadow stack.
            self.result_buf = Some(params[next + f.params as usize]);
        }
        self.b.ins().jump(self.body, &[]);

        self.b.switch_to_block(self.error_exit);
        self.restore_root_frame();
        self.return_zeros();

        self.b.switch_to_block(self.body);
        self.terminated = false;
        for (index, inst) in f.body.iter().enumerate() {
            self.current_index = index;
            self.inst(inst)?;
        }
        if !self.terminated {
            return Err(BackendError::Bug(format!("function {} falls off its end", f.id)));
        }
        Ok(())
    }

    /// Reserves the physical root slots, after bounding the recursion where
    /// this function must (`RootPlan::depth_reservation`): `RuntimeStack`
    /// storage reserves its slots in the shadow array, whose end is the
    /// bound; native-frame storage checks the stack pointer
    /// (`prologue_stack_limit`). Linux and macOS, whose guard reports an
    /// exhausted stack, need neither.
    fn prologue_root_frame(&mut self) {
        if self.plan.storage == RootStorage::NativeFrame && self.plan.depth_reservation {
            self.prologue_stack_limit();
        }
        match self.plan.storage {
            RootStorage::RuntimeStack => self.prologue_runtime_stack(),
            RootStorage::NativeFrame if self.plan.num_slots == 0 => {
                // Nothing to reserve or zero: no root candidates at all (see
                // `RootPlan::plan`'s num_slots, which applies no floor
                // here). `self.base`/`self.root_slot` stay the unused
                // placeholders `new` set them to: `def`/`def_raw`/
                // `mark_safepoint` never read them when no register has a
                // slot, and `restore_root_frame` below never touches them
                // either (`self.saved_native_roots` stays None).
            }
            RootStorage::NativeFrame => self.prologue_native_frame(),
        }
    }

    /// `RootPlan::depth_reservation` where native frames hold the roots but
    /// no guard reports an exhausted stack (Windows x86-64 until its stack
    /// guard: runtime::native_stack's `stack_limit_checked`): the frame,
    /// already allocated and probed, fails with NATIVE LIMIT STACK
    /// (`rt_stack_overflow`) when the stack pointer is below `vm.stack_limit`
    /// -- the thread's stack bound plus a margin for what may run below a
    /// checked frame (`Vm::new`). A bound in bytes of the native stack the
    /// recursion actually uses, which the shadow stack's slot count is not
    /// once the roots live in native frames (WINDOWS-X86-64-MILESTONE-3.md,
    /// section 5). Nothing to undo on the way out; the failure is an error
    /// every caller checks, as the shadow stack's was (nir's call effects,
    /// `depth_checked`).
    fn prologue_stack_limit(&mut self) {
        let sp = self.b.ins().get_stack_pointer(I64);
        let limit = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_STACK_LIMIT_OFFSET);
        let over = self.b.ins().icmp(IntCC::UnsignedLessThan, sp, limit);
        let overflow = self.b.create_block();
        let setup = self.b.create_block();
        self.b.ins().brif(over, overflow, &[], setup, &[]);
        self.b.set_cold_block(overflow);

        self.b.switch_to_block(overflow);
        self.call_helper("rt_stack_overflow", &[self.vm]);
        self.return_zeros();

        self.b.switch_to_block(setup);
    }

    /// `RootStorage::RuntimeStack`'s prologue: reserve and clear this
    /// frame's slots in the shared shadow-stack array, exactly as before
    /// this milestone. `self.plan.num_slots` (codegen::roots), not
    /// `f.regs`: only registers that are both managed-capable and live
    /// across a GC safepoint get a slot at all, and two such registers
    /// share one when their safepoint-live ranges never overlap (see
    /// roots.rs's module doc). At least one slot always, regardless of
    /// rooting needs, so the shadow stack still bounds native recursion
    /// depth (see RootPlan::num_slots's doc).
    fn prologue_runtime_stack(&mut self) {
        let slots = self.plan.num_slots as i64;
        self.base = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_SS_TOP_OFFSET);
        let top = self.b.ins().iadd_imm_s(self.base, slots * 8);
        let limit = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_SS_LIMIT_OFFSET);
        let over = self.b.ins().icmp(IntCC::UnsignedGreaterThan, top, limit);
        let overflow = self.b.create_block();
        let setup = self.b.create_block();
        self.b.ins().brif(over, overflow, &[], setup, &[]);

        self.b.switch_to_block(overflow);
        self.call_helper("rt_stack_overflow", &[self.vm]);
        self.return_zeros();

        self.b.switch_to_block(setup);
        self.b.ins().store(MemFlagsData::trusted(), top, self.vm, VM_SS_TOP_OFFSET);
        self.zero_root_slots(slots);
    }

    /// `RootStorage::NativeFrame`'s prologue for a function with at least
    /// one physical root slot: allocates ONE Cranelift explicit stack slot
    /// (this function's own native frame, not the shared shadow array) to
    /// hold every physical slot contiguously. What happens next depends on
    /// `self.stack_maps`:
    ///
    ///   * stack-map path (`self.stack_maps`, primary): nothing more is
    ///     published anywhere -- `self.root_slot` alone is enough for
    ///     `mark_safepoint` to attach this frame's `UserStackMapEntry`s at
    ///     each safepoint, and the collector discovers them at collection
    ///     time by walking the native call stack (runtime/framewalk.rs),
    ///     not by consulting anything this prologue writes to `Vm`.
    ///   * fallback path (`!self.stack_maps`): publishes this slot's
    ///     address and count to `vm.native_roots_ptr`/`_len` (so the
    ///     collector can find it -- see runtime/heap.rs's and vm.rs's
    ///     module docs) and saves whatever was published there before, so
    ///     `restore_root_frame` can put it back. Sound as a plain
    ///     save/restore pair (not a list): on this path `RootStorage::
    ///     NativeFrame` still implies no Botlish call (roots::plan's own
    ///     doc), so at most one such registration can ever be active along
    ///     any single call chain.
    fn prologue_native_frame(&mut self) {
        let slots = self.plan.num_slots as i64;
        let slot = self.b.create_sized_stack_slot(StackSlotData::new(
            StackSlotKind::ExplicitSlot,
            (slots * 8) as u32,
            3,
        ));
        self.root_slot = Some(slot);
        self.base = self.b.ins().stack_addr(I64, slot, 0);
        if !self.stack_maps {
            let saved_ptr = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_NATIVE_ROOTS_PTR_OFFSET);
            let saved_len = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_NATIVE_ROOTS_LEN_OFFSET);
            self.saved_native_roots = Some((saved_ptr, saved_len));
            self.b.ins().store(MemFlagsData::trusted(), self.base, self.vm, VM_NATIVE_ROOTS_PTR_OFFSET);
            let count = self.iconst(slots as u64);
            self.b.ins().store(MemFlagsData::trusted(), count, self.vm, VM_NATIVE_ROOTS_LEN_OFFSET);
        }
        self.zero_root_slots(slots);
    }

    /// F3b: zeroes only the physical slots codegen::roots's per-slot
    /// definite-initialization analysis says some reachable safepoint could
    /// otherwise scan before a valid Value has been stored into them
    /// (RootPlan::entry_zero); a slot every path to every reachable
    /// safepoint already stores a real Value into needs no prologue zero at
    /// all (see roots.rs's `entry_zero_slots` for the proof).
    /// BOTLISH_NATIVE_ROOT_INIT_OPT=0 restores the old "zero every slot"
    /// policy for differential testing. Shared between both storage modes:
    /// `self.base` already names wherever slot N actually lives (see
    /// `prologue_root_frame`).
    fn zero_root_slots(&mut self, slots: i64) {
        let mut zero = None;
        for slot in 0..slots {
            if !self.root_init_opt || self.plan.entry_zero[slot as usize] {
                let z = *zero.get_or_insert_with(|| self.b.ins().iconst(I64, 0));
                self.b.ins().store(MemFlagsData::trusted(), z, self.base, (slot * 8) as i32);
            }
        }
    }

    /// Restores whatever this frame's prologue displaced, on every path out
    /// of the function (each `Ret`/`RetMulti` and the shared `error_exit`):
    /// `RuntimeStack` pops the shared shadow-stack array back to this
    /// frame's own base (root storage and depth bound combined, as before
    /// this milestone); `NativeFrame` restores the fallback path's
    /// `vm.native_roots_ptr`/`_len` publish when it made one (nothing to do
    /// on the stack-map path, which never publishes anything -- see
    /// `prologue_native_frame`'s own doc). The stack-limit check
    /// (`prologue_stack_limit`) reserves nothing and has nothing to undo.
    fn restore_root_frame(&mut self) {
        match self.plan.storage {
            RootStorage::RuntimeStack => {
                self.b.ins().store(MemFlagsData::trusted(), self.base, self.vm, VM_SS_TOP_OFFSET);
            }
            RootStorage::NativeFrame => {
                if let Some((ptr, len)) = self.saved_native_roots {
                    self.b.ins().store(MemFlagsData::trusted(), ptr, self.vm, VM_NATIVE_ROOTS_PTR_OFFSET);
                    self.b.ins().store(MemFlagsData::trusted(), len, self.vm, VM_NATIVE_ROOTS_LEN_OFFSET);
                }
            }
        }
    }

    // -----------------------------------------------------------------------
    // Helpers

    fn def(&mut self, reg: Reg, value: ir::Value) {
        self.b.def_var(self.vars[reg as usize], value);
        // Only store when REG's root-liveness plan (codegen::roots) actually
        // assigned it a shadow slot: a managed-capable register that is
        // never live across a GC safepoint needs no root at all (see
        // roots.rs's module doc, items 3 and 6 of this milestone's brief) --
        // its value only ever needs to exist in this Cranelift variable, and
        // Cranelift's own register allocator is responsible for that, not
        // the shadow stack.
        if let Some(slot) = self.plan.slot_of[reg as usize] {
            self.b.ins().store(MemFlagsData::trusted(), value, self.base, (slot * 8) as i32);
        }
    }

    /// Like `def`, for a register that holds a raw (untagged) machine
    /// integer rather than a Value: never a GC root (it can hold no heap
    /// reference), so unlike `def` it is never stored to the shadow stack --
    /// storing a raw word there would let the collector misread it as a
    /// pointer (native/src/runtime/heap.rs's roots are precise, not
    /// conservative). The slot stays at the prologue's zero.
    fn def_raw(&mut self, reg: Reg, value: ir::Value) {
        self.b.def_var(self.vars[reg as usize], value);
    }

    fn get(&mut self, reg: Reg) -> ir::Value {
        self.b.use_var(self.vars[reg as usize])
    }

    /// The address of the program's context area (CONTEXTS.md):
    /// `symbol_value` of its data symbol -- PC-relative in the AOT object,
    /// absolute in the JIT (Symbols::context_pc_relative).
    fn context_addr(&mut self) -> Result<ir::Value, BackendError> {
        let Some(id) = self.symbols.context_area else {
            return Err(BackendError::Bug("context access in a program without a context area".into()));
        };
        let gv = match self.context_gv {
            Some(gv) => gv,
            None => {
                let gv = self.module.declare_data_in_func(id, self.b.func);
                if let ir::GlobalValueData::Symbol { colocated, .. } = &mut self.b.func.global_values[gv] {
                    *colocated = self.symbols.context_pc_relative;
                }
                self.context_gv = Some(gv);
                gv
            }
        };
        Ok(self.b.ins().symbol_value(I64, gv))
    }

    fn func_ref(&mut self, id: ModuleFuncId) -> ir::FuncRef {
        if let Some(r) = self.refs.get(&id) {
            return *r;
        }
        let r = self.module.declare_func_in_func(id, self.b.func);
        self.refs.insert(id, r);
        r
    }

    /// Like `func_ref`, for a runtime helper (ID is one of `symbols.helpers`'
    /// values): builds the `ir::FuncRef` with `colocated: true` when
    /// `symbols.direct_helpers` says a direct call is safe for this helper
    /// on this backend (see that field's doc), bypassing `declare_func_in_func`
    /// (which would otherwise always set `colocated` from the symbol's
    /// `Linkage::Import`, i.e. false: see `func_ref` above). Never used for
    /// `CallValue`'s dynamic dispatch target -- only for the statically
    /// known helper names `call_helper` passes here.
    fn helper_ref(&mut self, id: ModuleFuncId) -> ir::FuncRef {
        if let Some(r) = self.refs.get(&id) {
            return *r;
        }
        let r = if self.symbols.direct_helpers {
            let signature = self.module.declarations().get_function_decl(id).signature.clone();
            let sig_ref = self.b.func.import_signature(signature);
            let user_name_ref =
                self.b.func.declare_imported_user_function(ir::UserExternalName { namespace: 0, index: id.as_u32() });
            self.b.func.import_function(ir::ExtFuncData {
                name: ir::ExternalName::user(user_name_ref),
                signature: sig_ref,
                colocated: true,
                patchable: false,
            })
        } else {
            self.module.declare_func_in_func(id, self.b.func)
        };
        self.refs.insert(id, r);
        r
    }

    /// A C call (C-FFI.md, nir.rs's `foreigncall`): the operands converted
    /// to their C ABI classes, one direct call of the linked symbol, the
    /// result checked against an alias contract and converted back. Returns
    /// the tagged result.
    ///
    /// Operands: an exposure's address is a small Int (`sshr 1`), a raw
    /// pointer a C address word (`sshr 4`: the sign-extended address), a C
    /// `_Bool` a Botlish bool (its truth bit, `ushr 2` and 1: 0 or 1), a C
    /// integer an Int -- small for every class narrower than 64 bits (its
    /// proven range), else small or a BigInt (`rt_ffi_int_word`) -- then
    /// reduced to its width; a C double a Float64's number as it is, a C
    /// float the Float64 narrowed (`foreign_float_argument`: an overflow
    /// fails before the call). Results: a narrow integer extended by its own
    /// signedness and tagged; a `_Bool` byte the bool it is when 0 or 1, else
    /// `rt_ffi_bad_bool`; a 64-bit one tagged when it fits the small range,
    /// else boxed (`rt_ffi_box_i64`/`_u64`); a pointer tagged when the C
    /// address word holds it, else `rt_ffi_bad_address`; a C float widened
    /// exactly and, like a C double, admitted only when finite
    /// (`rt_float_nonfinite` otherwise), its negative zero made zero, then
    /// boxed; void unit.
    ///
    /// A variadic call (VARIADICS-VERTICAL-SLICE-1.md) passes its trailing
    /// operands after the fixed ones, each decoded by its own class and
    /// passed as its promoted one (`vararg_value`), with this call's own
    /// signature (`c_call_signature`, its padding zeros between the two) --
    /// on x86-64 through the `%al` stub of its vector register count.
    fn foreign_call(
        &mut self,
        foreign: u32,
        args: &[Reg],
        exposed: &[bool],
        discard: bool,
        varargs: &[nir::VarArg],
        word: bool,
    ) -> Result<ir::Value, BackendError> {
        let (id, decl) = self.symbols.foreigns[foreign as usize].clone();
        let (signature, padding) = c_call_signature(&*self.module, &decl, varargs)?;
        let apple = signature.call_conv == CallConv::AppleAarch64;
        let mut words = Vec::with_capacity(args.len());
        let mut values = Vec::with_capacity(args.len() + padding.len());
        for (i, r) in args.iter().enumerate() {
            let v = self.get(*r);
            if i >= decl.params.len() {
                if i == decl.params.len() {
                    for t in &padding {
                        values.push(if *t == types::F64 { self.b.ins().f64const(0.0) } else { self.iconst(0) });
                    }
                }
                let value = self.vararg_value(v, varargs[i - decl.params.len()], apple);
                values.push(value);
                continue;
            }
            let class = decl.params[i];
            if class == nir::CAbi::F64 {
                // A Float64's number, as it is: every Float64 is a double.
                words.push(v);
                values.push(self.float_number(FloatType::Float64, v));
                continue;
            }
            if class == nir::CAbi::F32 {
                words.push(v);
                let x = self.float_number(FloatType::Float64, v);
                values.push(self.foreign_float_argument(x));
                continue;
            }
            let word = if exposed[i] {
                self.b.ins().sshr_imm_s(v, 1)
            } else if class == nir::CAbi::Ptr {
                self.b.ins().sshr_imm_s(v, 4)
            } else if class == nir::CAbi::Bool {
                let shifted = self.b.ins().ushr_imm_s(v, 2);
                self.b.ins().band_imm_s(shifted, 1)
            } else if class.bits() < 64 {
                self.b.ins().sshr_imm_s(v, 1)
            } else {
                self.int_word(v)
            };
            words.push(word);
            values.push(if class.bits() < 64 { self.b.ins().ireduce(c_type(class), word) } else { word });
        }
        let r = if decl.variadic {
            // This call's own signature, the callee the C function itself --
            // or, on x86-64, its %al stub (`va_stub`).
            let callee = match self.symbols.va_stubs.get(&(foreign, vector_registers(&signature))) {
                Some(stub) => *stub,
                None if needs_va_stub(&*self.module) => {
                    return Err(BackendError::Bug(format!("no %al stub for the variadic call of {}", decl.name)));
                }
                None => id,
            };
            let sig_ref = self.b.func.import_signature(signature);
            let user = self
                .b
                .func
                .declare_imported_user_function(ir::UserExternalName { namespace: 0, index: callee.as_u32() });
            self.b.func.import_function(ir::ExtFuncData {
                name: ir::ExternalName::user(user),
                signature: sig_ref,
                colocated: false,
                patchable: false,
            })
        } else {
            self.func_ref(id)
        };
        let call = self.b.ins().call(r, &values);
        self.mark_safepoint(call);
        let returned = (decl.result != nir::CAbi::Void).then(|| self.b.inst_results(call)[0]);
        if let (Some(alias), Some(returned)) = (decl.alias, returned) {
            // The development assertion of an alias contract: the returned
            // address is exactly the argument's.
            let expected = words[alias as usize];
            let same = self.b.ins().icmp(IntCC::Equal, returned, expected);
            let ok = self.b.create_block();
            let bad = self.b.create_block();
            self.b.ins().brif(same, ok, &[], bad, &[]);
            self.b.switch_to_block(bad);
            let name = self.string(&decl.name);
            self.fail_with("rt_ffi_contract_violation", &[self.vm, name, expected, returned]);
            self.b.switch_to_block(ok);
        }
        if discard {
            return Ok(self.iconst(UNIT));
        }
        let Some(returned) = returned else { return Ok(self.iconst(UNIT)) };
        if word {
            // A C word destination (nir.rs validated the 64-bit integer
            // class): the machine word itself.
            return Ok(returned);
        }
        Ok(self.foreign_result(&decl, returned))
    }

    /// The machine value of the trailing argument V of a variadic C call,
    /// tagged as ARG's class says (an Int, a bool, a Float64, a C address
    /// word), passed as ARG's promoted class: an F64 for a double, else an
    /// integer of the promoted width -- under Apple's convention always the
    /// 64-bit word of its 8-byte stack slot (`c_call_signature`). An Int's
    /// word is its exact value (the admission proof held it in its C type's
    /// range), so it is already sign-extended for a signed promoted class
    /// and zero-extended for an unsigned one; a bool is 0 or 1.
    fn vararg_value(&mut self, v: ir::Value, arg: nir::VarArg, apple: bool) -> ir::Value {
        let word = match arg.class {
            nir::CAbi::F64 => return self.float_number(FloatType::Float64, v),
            nir::CAbi::Ptr => self.b.ins().sshr_imm_s(v, 4),
            nir::CAbi::Bool => {
                let shifted = self.b.ins().ushr_imm_s(v, 2);
                self.b.ins().band_imm_s(shifted, 1)
            }
            c if c.bits() < 64 => self.b.ins().sshr_imm_s(v, 1),
            _ => self.int_word(v),
        };
        if apple || arg.promoted.bits() == 64 {
            word
        } else {
            self.b.ins().ireduce(c_type(arg.promoted), word)
        }
    }

    /// The tagged Botlish value of C result RETURNED of a call of DECL (see
    /// `foreign_call`).
    fn foreign_result(&mut self, decl: &nir::ForeignDecl, returned: ir::Value) -> ir::Value {
        let class = decl.result;
        if class.floating() {
            // A double is a Float64 only when it is a finite number
            // (FLOAT64-MILESTONE-1.md): NaN or an infinity is the call's
            // NonFiniteFloat, negative zero is zero (`r + 0.0`). A float is
            // first widened to the double it exactly is (`fpromote` never
            // rounds; NaN stays NaN, an infinity an infinity), then admitted
            // the same way (C-FLOAT-FFI-MILESTONE-1.md).
            let wide = if class == nir::CAbi::F32 { self.b.ins().fpromote(types::F64, returned) } else { returned };
            let zero = self.b.ins().f64const(0.0);
            let r = self.b.ins().fadd(wide, zero);
            let magnitude = self.b.ins().fabs(r);
            let largest = self.b.ins().f64const(f64::MAX);
            let finite = self.b.ins().fcmp(FloatCC::LessThanOrEqual, magnitude, largest);
            let ok = self.b.create_block();
            let bad = self.b.create_block();
            self.b.ins().brif(finite, ok, &[], bad, &[]);
            self.b.switch_to_block(bad);
            let result = self.non_finite_code(r);
            self.fail_with("rt_float_nonfinite", &[self.vm, result]);
            self.b.switch_to_block(ok);
            let bits = self.b.ins().bitcast(I64, MemFlagsData::new(), r);
            let code = self.iconst(FloatType::Float64.code());
            return self.call_allocating("rt_float_new", &[self.vm, code, bits], "foreigncall", KIND_FLOAT);
        }
        if class == nir::CAbi::Ptr {
            // (address << 4) | tag when the word holds the address.
            let shifted = self.b.ins().ishl_imm_s(returned, 4);
            let back = self.b.ins().sshr_imm_s(shifted, 4);
            let fits = self.b.ins().icmp(IntCC::Equal, back, returned);
            let ok = self.b.create_block();
            let bad = self.b.create_block();
            self.b.ins().brif(fits, ok, &[], bad, &[]);
            self.b.switch_to_block(bad);
            let name = self.string(&decl.name);
            self.fail_with("rt_ffi_bad_address", &[self.vm, name, returned]);
            self.b.switch_to_block(ok);
            return self.b.ins().bor_imm_s(shifted, CPTR_TAG as i64);
        }
        if class == nir::CAbi::Bool {
            // The _Bool byte, whatever the register holds beyond it: 0 or 1
            // is false or true, any other byte no _Bool at all.
            let byte = self.b.ins().uextend(I64, returned);
            let valid = self.b.ins().icmp_imm_s(IntCC::UnsignedLessThanOrEqual, byte, 1);
            let ok = self.b.create_block();
            let bad = self.b.create_block();
            self.b.ins().brif(valid, ok, &[], bad, &[]);
            self.b.switch_to_block(bad);
            let name = self.string(&decl.name);
            self.fail_with("rt_ffi_bad_bool", &[self.vm, name, byte]);
            self.b.switch_to_block(ok);
            let shifted = self.b.ins().ishl_imm_s(byte, 2);
            return self.b.ins().bor_imm_s(shifted, 2);
        }
        if class.bits() < 64 {
            let wide = if class.signed() {
                self.b.ins().sextend(I64, returned)
            } else {
                self.b.ins().uextend(I64, returned)
            };
            let shifted = self.b.ins().ishl_imm_s(wide, 1);
            return self.b.ins().bor_imm_s(shifted, 1);
        }
        // A 64-bit result: tagged when it fits the small range, else boxed.
        self.box_word(returned, class.signed())
    }

    /// The Int of the 64-bit C word WORD (signed or not): tagged inline when
    /// it fits the small range, else a BigInt (`rt_ffi_box_i64`/`_u64`, the
    /// one path that allocates). A C call's 64-bit result tagged as part of
    /// the call, and `cwbox` of a C word kept until its first use that
    /// needs the Int (C-FFI-ERROR-CAPTURE-MILESTONE-2.md).
    fn box_word(&mut self, returned: ir::Value, signed: bool) -> ir::Value {
        let (fits, helper) = if signed {
            let shifted = self.b.ins().ishl_imm_s(returned, 1);
            let back = self.b.ins().sshr_imm_s(shifted, 1);
            (self.b.ins().icmp(IntCC::Equal, back, returned), "rt_ffi_box_i64")
        } else {
            (self.b.ins().icmp_imm_s(IntCC::UnsignedLessThan, returned, SMALL_MAX + 1), "rt_ffi_box_u64")
        };
        let small = self.b.create_block();
        let big = self.b.create_block();
        let join = self.b.create_block();
        self.b.append_block_param(join, I64);
        self.b.ins().brif(fits, small, &[], big, &[]);
        self.b.switch_to_block(small);
        let shifted = self.b.ins().ishl_imm_s(returned, 1);
        let tagged = self.b.ins().bor_imm_s(shifted, 1);
        self.b.ins().jump(join, &[BlockArg::Value(tagged)]);
        self.b.switch_to_block(big);
        let boxed = self.call_helper(helper, &[self.vm, returned]);
        self.b.ins().jump(join, &[BlockArg::Value(boxed)]);
        self.b.switch_to_block(join);
        self.b.block_params(join)[0]
    }

    /// The two's-complement 64-bit word of the Int V (a 64-bit C integer
    /// argument): inline for a small Int, `rt_ffi_int_word` for a BigInt.
    fn int_word(&mut self, v: ir::Value) -> ir::Value {
        let small = self.b.create_block();
        let big = self.b.create_block();
        let join = self.b.create_block();
        self.b.append_block_param(join, I64);
        let tag = self.b.ins().band_imm_s(v, 1);
        self.b.ins().brif(tag, small, &[], big, &[]);
        self.b.switch_to_block(small);
        let n = self.b.ins().sshr_imm_s(v, 1);
        self.b.ins().jump(join, &[BlockArg::Value(n)]);
        self.b.switch_to_block(big);
        let w = self.call_helper("rt_ffi_int_word", &[self.vm, v]);
        self.b.ins().jump(join, &[BlockArg::Value(w)]);
        self.b.switch_to_block(join);
        self.b.block_params(join)[0]
    }

    fn call_helper(&mut self, name: &str, args: &[ir::Value]) -> ir::Value {
        let id = self.symbols.helpers[name];
        let r = self.helper_ref(id);
        let call = self.b.ins().call(r, args);
        self.mark_safepoint(call);
        self.b.inst_results(call)[0]
    }

    /// Attaches Cranelift `UserStackMapEntry`s (this function's own live
    /// roots at this point) to CALL, the machine `call` instruction that
    /// just implemented the NIR instruction at `self.current_index` -- the
    /// single choke point every actual runtime-helper call passes through
    /// (`call_helper`, hence `call_allocating`/`op`'s allocating arms/
    /// `CallValue`'s `rt_call_value`), plus the two direct-Botlish-call
    /// sites that bypass it (`Inst::Call`/`Inst::CallEnv`, and `call_multi`
    /// for `CallMulti`/`CallEnvMulti`).
    ///
    /// A no-op whenever there is nothing to attach: no native root slot at
    /// all (`self.root_slot` is `None` off the stack-map path, or for a
    /// `NativeFrame` function with zero physical slots), or
    /// `self.current_index` names no safepoint (`self.plan.safepoint_slots`
    /// has no entry for it) -- covering both a genuinely non-safepoint
    /// call this same NIR instruction also makes (there are none: every
    /// call site this method is reached from is itself the allocating/
    /// calling operation) and, more importantly, every call made *outside*
    /// `f.body` translation, i.e. `self.current_index == usize::MAX`
    /// (`Translator::new`'s own doc) during prologue codegen -- a
    /// `prologue_stack_limit` failure's own `rt_stack_overflow` call must
    /// never be mistaken for a real instruction's safepoint (it runs before
    /// this frame's own slots hold anything meaningful at all).
    ///
    /// `is_safepoint` in codegen::roots and this method's own call sites
    /// are the two halves of one invariant this file relies on but does not
    /// re-verify here: every `f.body` instruction `roots::plan` classifies
    /// as a safepoint translates to exactly one dynamically-reachable
    /// runtime call along any path through its translation (fast/slow
    /// splits like `int_arith`/`both_small_split` only ever call a helper
    /// on the slow branch, so attaching unconditionally at every
    /// `call_helper` invocation already lands on exactly the right
    /// instruction -- see that classification's own doc, item 2).
    fn mark_safepoint(&mut self, call: ir::Inst) {
        let Some(slot) = self.root_slot else { return };
        let Some(slots) = self.plan.safepoint_slots.get(&self.current_index) else { return };
        for &physical_slot in slots {
            self.b.func.dfg.append_user_stack_map_entry(
                call,
                UserStackMapEntry { ty: I64, slot, offset: physical_slot * 8 },
            );
        }
    }

    /// Interns a Site for the instruction currently being translated and,
    /// in Sites mode, stores its id into `vm.alloc_site` (a no-op store
    /// when not instrumenting sites is never emitted at all -- this whole
    /// method is skipped). See the `sites`/`current_index` fields' docs.
    fn mark_site(&mut self, operation: &'static str, object_kind: u8) {
        if !self.instrument_sites {
            return;
        }
        let hir_expr = self.f.origins.get(self.current_index).copied().flatten();
        self.sites.push(Site { func: self.f.id, func_name: self.f.name.clone(), hir_expr, operation, object_kind });
        let id = self.iconst(self.sites.len() as u64); // 1-based: 0 means unattributed
        self.b.ins().store(MemFlagsData::trusted(), id, self.vm, VM_ALLOC_SITE_OFFSET);
    }

    /// Like `call_helper`, for a helper that may allocate an OBJECT_KIND
    /// via OPERATION. Marks the site immediately before the call and clears
    /// it immediately after (back to 0, "unattributed") rather than leaving
    /// it set: NAME does not always actually allocate (e.g. the BigInt slow
    /// path can still land on a value that fits small), and a stale site id
    /// left in `vm.alloc_site` would otherwise misattribute some later,
    /// unrelated allocation instead of just attributing nothing.
    fn call_allocating(&mut self, name: &str, args: &[ir::Value], operation: &'static str, object_kind: u8) -> ir::Value {
        self.mark_site(operation, object_kind);
        let r = self.call_helper(name, args);
        if self.instrument_sites {
            let zero = self.iconst(0);
            self.b.ins().store(MemFlagsData::trusted(), zero, self.vm, VM_ALLOC_SITE_OFFSET);
        }
        r
    }

    /// Returns F.RESULTS copies of the tagged 0 sentinel ("an error is
    /// pending"): the prologue's stack-overflow path and the shared
    /// error_exit block both need this, whether F is an ordinary
    /// (results == 1) function or a scalar-replacement companion (see
    /// nir::Function::results) -- a multi-result function's caller
    /// (CallMulti/CallEnvMulti) only ever checks its first result register
    /// for 0, exactly like an ordinary Call/CallEnv's single result, which
    /// is why every non-error RetMulti must produce fields that are never
    /// literally 0 (true of every tagged Value already: see `check`).
    fn return_zeros(&mut self) {
        let zero = self.b.ins().iconst(I64, 0);
        // A `results > 2` function's actual Cranelift return arity is 1
        // (signature_n): its caller reads only that one word as the error
        // sentinel and never touches the result buffer when it is 0, so
        // there is nothing to write there on this path.
        let n = if self.f.results > 2 { 1 } else { physical_results(self.f).max(1) };
        let zeros = vec![zero; n];
        self.b.ins().return_(&zeros);
    }

    /// Branches to the error exit if V is 0; continues in a new block.
    /// Where `check`/`fail_with` currently send a failing result: see
    /// `error_exit_stack`'s own doc.
    fn current_error_exit(&self) -> ir::Block {
        *self.error_exit_stack.last().expect("error_exit_stack is never empty")
    }

    fn check(&mut self, v: ir::Value) {
        let ok = self.b.create_block();
        let target = self.current_error_exit();
        self.b.ins().brif(v, ok, &[], target, &[]);
        self.b.switch_to_block(ok);
    }

    fn fail_with(&mut self, name: &str, args: &[ir::Value]) {
        self.call_helper(name, args);
        let target = self.current_error_exit();
        self.b.ins().jump(target, &[]);
    }

    fn constant(&mut self, c: Const) -> ir::Value {
        let index = self.pool.index(c);
        let table = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_CONSTS_OFFSET);
        self.b.ins().load(I64, MemFlagsData::trusted(), table, (index * 8) as i32)
    }

    fn string(&mut self, text: &str) -> ir::Value {
        self.constant(Const::Str(text.to_string()))
    }

    fn iconst(&mut self, n: u64) -> ir::Value {
        self.b.ins().iconst(I64, n as i64)
    }

    fn label(&mut self, l: nir::Label) -> ir::Block {
        if let Some(block) = self.labels.get(&l) {
            return *block;
        }
        let block = self.b.create_block();
        self.labels.insert(l, block);
        block
    }

    /// An array of the registers' values in a stack slot: (count, pointer).
    fn array(&mut self, regs: &[Reg]) -> (ir::Value, ir::Value) {
        let n = self.iconst(regs.len() as u64);
        if regs.is_empty() {
            return (n, self.iconst(0));
        }
        let slot = self.b.create_sized_stack_slot(StackSlotData::new(
            StackSlotKind::ExplicitSlot,
            (regs.len() * 8) as u32,
            3,
        ));
        for (i, reg) in regs.iter().enumerate() {
            let v = self.get(*reg);
            let addr = self.b.ins().stack_addr(I64, slot, (i * 8) as i32);
            self.b.ins().store(MemFlagsData::trusted(), v, addr, 0);
        }
        (n, self.b.ins().stack_addr(I64, slot, 0))
    }

    /// A fresh, uninitialized WORDS-word stack slot's address: scratch space
    /// a `results > 2` CallMulti/CallEnvMulti passes to its callee as the
    /// hidden trailing pointer parameter (signature_n), for the callee's
    /// RetMulti to write fields 1.. into. No GC hazard: nothing can allocate
    /// between the callee's store into it and the caller's own `def` of the
    /// loaded values right after the call returns (see Inst::RetMulti's and
    /// Inst::CallMulti's own comments).
    fn result_slot(&mut self, words: usize) -> ir::Value {
        let slot = self.b.create_sized_stack_slot(StackSlotData::new(
            StackSlotKind::ExplicitSlot,
            (words * 8) as u32,
            3,
        ));
        self.b.ins().stack_addr(I64, slot, 0)
    }

    /// Defines DST from the results of the direct call CALL of FUNC and
    /// performs the call site's error check. The tagged ABI returns one
    /// Value whose 0 is the error sentinel. The raw Int ABI
    /// (RAW-INT-ABI.md) returns the raw integer -- never an error sentinel
    /// -- alone when FUNC cannot fail, or followed by a status word
    /// (nonzero = success) when it can: the check then reads the status.
    fn finish_call(&mut self, dst: Reg, func: nir::FuncId, call: ir::Inst, may_error: bool) {
        let results = self.b.inst_results(call).to_vec();
        if self.symbols.status_result[func as usize] {
            self.check(results[1]);
        } else if may_error {
            self.check(results[0]);
        }
        if self.f.scalar_regs[dst as usize] {
            self.def_raw(dst, results[0]);
        } else {
            self.def(dst, results[0]);
        }
    }

    /// Shared body of Inst::CallMulti/CallEnvMulti: calls FUNC (VALUES
    /// already holding vm, and the closure for CallEnvMulti, ahead of the
    /// ordinary arguments), checks its first result, and defines DSTS --
    /// through the hidden result-buffer pointer (signature_n) when
    /// `dsts.len() > 2`, or directly from the call's own return registers
    /// otherwise. Never a GC hazard for the buffer case: the buffer holds
    /// only the callee's already-computed fields for the short window
    /// between its `store` (Inst::RetMulti) and this immediate `load`+`def`,
    /// with no allocation possible in between (nothing in either sequence
    /// calls a runtime helper).
    fn call_multi(&mut self, dsts: &[Reg], func: nir::FuncId, values: &mut Vec<ir::Value>, may_error: bool, may_gc: bool) {
        let buf = (dsts.len() > 2).then(|| self.result_slot(dsts.len() - 1));
        if let Some(ptr) = buf {
            values.push(ptr);
        }
        let r = self.func_ref(self.symbols.direct[func as usize]);
        let call = self.b.ins().call(r, values);
        if may_gc { self.mark_safepoint(call); }
        let results = self.b.inst_results(call).to_vec();
        if may_error { self.check(results[0]); }
        self.def(dsts[0], results[0]);
        match buf {
            Some(ptr) => {
                for (i, d) in dsts[1..].iter().enumerate() {
                    let v = self.b.ins().load(I64, MemFlagsData::trusted(), ptr, (i * 8) as i32);
                    self.def(*d, v);
                }
            }
            None => {
                for (d, v) in dsts[1..].iter().zip(results[1..].iter()) {
                    self.def(*d, *v);
                }
            }
        }
    }

    /// I8 1 if V has semantic kind KIND.
    fn is_kind(&mut self, v: ir::Value, kind: Kind) -> ir::Value {
        match kind {
            Kind::Bool => {
                let x = self.b.ins().bor_imm_s(v, 4);
                return self.b.ins().icmp_imm_s(IntCC::Equal, x, TRUE as i64);
            }
            Kind::Unit => return self.b.ins().icmp_imm_s(IntCC::Equal, v, UNIT as i64),
            Kind::UnicodeChar => {
                let x = self.b.ins().band_imm_s(v, CHAR_TAG_MASK as i64);
                return self.b.ins().icmp_imm_s(IntCC::Equal, x, CHAR_TAG as i64);
            }
            Kind::Enum => {
                let x = self.b.ins().band_imm_s(v, ENUM_TAG_MASK as i64);
                return self.b.ins().icmp_imm_s(IntCC::Equal, x, ENUM_TAG as i64);
            }
            Kind::CPtr => {
                let x = self.b.ins().band_imm_s(v, CPTR_TAG_MASK as i64);
                return self.b.ins().icmp_imm_s(IntCC::Equal, x, CPTR_TAG as i64);
            }
            _ => {}
        }
        let done = self.b.create_block();
        let result = self.b.append_block_param(done, types::I8);
        if kind == Kind::Int {
            let low = self.b.ins().band_imm_s(v, 1);
            let small = self.b.ins().icmp_imm_s(IntCC::NotEqual, low, 0);
            let check_heap = self.b.create_block();
            let yes = self.b.ins().iconst(types::I8, 1);
            self.b.ins().brif(small, done, &[BlockArg::Value(yes)], check_heap, &[]);
            self.b.switch_to_block(check_heap);
        }
        let heap_code = match kind {
            Kind::Int => KIND_BIGINT,
            Kind::Str => KIND_STR,
            Kind::List => KIND_LIST,
            Kind::Result => KIND_RESULT,
            Kind::Block => KIND_CLOSURE,
            Kind::Native => KIND_NATIVE,
            Kind::MutArray => KIND_MUTARRAY,
            Kind::ImmutableSet => KIND_SET,
            Kind::Struct => KIND_STRUCT,
            Kind::ByteStore => KIND_BYTES,
            Kind::MutByteStore => KIND_MUTBYTES,
            Kind::Coroutine => KIND_COROUTINE,
            Kind::MutVec => KIND_MUTVEC,
            // (A FloatObj's heap kind says which: FloatType::heap_kind.)
            Kind::Float64 => KIND_FLOAT,
            Kind::DecimalRounded => KIND_DECIMAL,
            Kind::Bool | Kind::Unit | Kind::UnicodeChar | Kind::Enum | Kind::CPtr => unreachable!(),
        };
        let low3 = self.b.ins().band_imm_s(v, 7);
        let pointer = self.b.ins().icmp_imm_s(IntCC::Equal, low3, 0);
        let load = self.b.create_block();
        let no = self.b.ins().iconst(types::I8, 0);
        self.b.ins().brif(pointer, load, &[], done, &[BlockArg::Value(no)]);
        self.b.switch_to_block(load);
        let tag = self.b.ins().load(types::I8, MemFlagsData::trusted(), v, 0);
        let same = self.b.ins().icmp_imm_s(IntCC::Equal, tag, heap_code as i64);
        self.b.ins().jump(done, &[BlockArg::Value(same)]);
        self.b.switch_to_block(done);
        result
    }

    fn bool_of(&mut self, flag: ir::Value) -> ir::Value {
        let t = self.iconst(TRUE);
        let f = self.iconst(FALSE);
        self.b.ins().select(flag, t, f)
    }

    // -----------------------------------------------------------------------
    // Instructions

    fn inst(&mut self, inst: &Inst) -> Result<(), BackendError> {
        if let Inst::Label(l) = inst {
            let block = self.label(*l);
            if !self.terminated {
                self.b.ins().jump(block, &[]);
            }
            self.b.switch_to_block(block);
            self.terminated = false;
            return Ok(());
        }
        if self.terminated {
            // Code after a terminator without a label is unreachable.
            let dead = self.b.create_block();
            self.b.switch_to_block(dead);
            self.terminated = false;
        }
        match inst {
            Inst::Label(_) => unreachable!(),
            Inst::RawInt { dst, digits } => {
                let n: i64 = digits.parse().expect("validated rawint literal");
                let v = self.b.ins().iconst(I64, n);
                self.def_raw(*dst, v);
            }
            Inst::CWord { dst, digits } => {
                // The word's bits: a signed word's two's complement, an
                // unsigned word's binary (validated against its kind).
                let bits = match digits.parse::<i64>() {
                    Ok(n) => n,
                    Err(_) => digits.parse::<u64>().expect("validated cword literal") as i64,
                };
                let v = self.b.ins().iconst(I64, bits);
                self.def_raw(*dst, v);
            }
            Inst::ShortLit { dst, value } | Inst::AsciiLit { dst, value } => {
                let v = self.b.ins().iconst(I64, *value);
                self.def_raw(*dst, v);
            }
            Inst::Int { dst, digits } => {
                let v = match digits.parse::<i64>() {
                    Ok(n) if fits_small(n) => self.iconst(make_small(n)),
                    _ => self.constant(Const::BigInt(digits.clone())),
                };
                self.def(*dst, v);
            }
            Inst::Str { dst, text } => {
                let v = self.string(text);
                self.def(*dst, v);
            }
            Inst::Bytes { dst, bytes } => {
                // A static byte storage (constants.rs installs it at
                // startup): loaded from the constant table like a String
                // constant, never allocated at run time.
                let v = self.constant(Const::Bytes(bytes.clone()));
                self.def(*dst, v);
            }
            Inst::Float { dst, ty, bits } => {
                // A static floating-point object (constants.rs installs it
                // at startup), loaded from the constant table like a String
                // constant: never allocated at run time.
                let v = self.constant(Const::Float(*ty, *bits));
                self.def(*dst, v);
            }
            Inst::Char { dst, digits } => {
                // Always fits: validated (a Unicode scalar value, <=
                // 0x10FFFF) when this instruction was parsed (nir.rs). An
                // ordinary immediate constant, exactly like Bool/Unit: no
                // allocation, no GC root.
                let codepoint: u32 = digits.parse().expect("validated char literal");
                let v = self.iconst(make_char(codepoint));
                self.def(*dst, v);
            }
            Inst::Enum { dst, index, case } => {
                // An immediate constant (ENUMS.md), like a Char: validated
                // against the program's enum table when parsed (nir.rs). No
                // allocation, no GC root.
                let v = self.iconst(make_enum(*index, *case));
                self.def(*dst, v);
            }
            Inst::Bool { dst, value } => {
                let v = self.iconst(bool_value(*value));
                self.def(*dst, v);
            }
            Inst::Unit { dst } => {
                let v = self.iconst(UNIT);
                self.def(*dst, v);
            }
            Inst::Native { dst, native } => {
                let v = self.constant(Const::Native(*native));
                self.def(*dst, v);
            }
            Inst::FnValue { dst, func } => {
                let v = self.constant(Const::FnValue(*func));
                self.def(*dst, v);
            }
            Inst::SelfClosure { dst } => {
                let v = self.b.use_var(self.closure.unwrap());
                self.def(*dst, v);
            }
            Inst::Capture { dst, index } => {
                let closure = self.b.use_var(self.closure.unwrap());
                let caps = self.b.ins().load(I64, MemFlagsData::trusted(), closure, CLOSURE_CAPS_OFFSET);
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), caps, (*index * 8) as i32);
                self.def(*dst, v);
            }
            Inst::StaticGet { dst, index } => {
                // Module-static storage (MODULE-STATIC-RETAINED-VALUES.md):
                // vm->statics_ptr, exactly like vm->consts (`constant`
                // above), except mutable and read through here from any
                // function alike -- never through this function's own
                // closure environment (Capture, above), whatever functions
                // are nested between the reference and the module section
                // that owns the binding.
                let table = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_STATICS_OFFSET);
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), table, (*index * 8) as i32);
                self.def(*dst, v);
            }
            Inst::StaticSet { index, value } => {
                // Written once, at the exact point the binding's own
                // initializer finishes evaluating (native/lower.tcl's
                // module-initialization lowering) -- see StaticSet's own
                // doc in nir.rs.
                let table = self.b.ins().load(I64, MemFlagsData::trusted(), self.vm, VM_STATICS_OFFSET);
                let v = self.get(*value);
                self.b.ins().store(MemFlagsData::trusted(), v, table, (*index * 8) as i32);
            }
            Inst::ContextLoad { dst, offset } => {
                // One scalar leaf of an installed context (CONTEXTS.md): the
                // area's fixed address plus a constant offset; the word is a
                // tagged immediate, never a pointer.
                let area = self.context_addr()?;
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), area, *offset as i32);
                self.def(*dst, v);
            }
            Inst::ContextStore { offset, value } => {
                // A `with context` installation (program function only).
                let area = self.context_addr()?;
                let v = self.get(*value);
                self.b.ins().store(MemFlagsData::trusted(), v, area, *offset as i32);
            }
            Inst::Move { dst, src } => {
                let v = self.get(*src);
                self.def(*dst, v);
            }
            Inst::Closure { dst, func, captures } => {
                let (n, ptr) = self.array(captures);
                let entry = self.func_ref(self.symbols.entry[*func as usize]);
                let code = self.b.ins().func_addr(I64, entry);
                let id = self.iconst(*func as u64);
                let v = self.call_allocating("rt_closure_new", &[self.vm, id, code, n, ptr], "closure", KIND_CLOSURE);
                self.def(*dst, v);
            }
            Inst::Guard { kind, value, context } => {
                let v = self.get(*value);
                let ok_flag = self.is_kind(v, *kind);
                let fail = self.b.create_block();
                let ok = self.b.create_block();
                self.b.ins().brif(ok_flag, ok, &[], fail, &[]);
                self.b.switch_to_block(fail);
                let code = self.iconst(kind.code() as u64);
                let context = self.string(context);
                self.fail_with("rt_type_error", &[self.vm, v, code, context]);
                self.b.switch_to_block(ok);
            }
            Inst::GuardBool { value } => {
                let v = self.get(*value);
                let ok_flag = self.is_kind(v, Kind::Bool);
                let fail = self.b.create_block();
                let ok = self.b.create_block();
                self.b.ins().brif(ok_flag, ok, &[], fail, &[]);
                self.b.switch_to_block(fail);
                self.fail_with("rt_not_boolean", &[self.vm, v]);
                self.b.switch_to_block(ok);
            }
            Inst::Construct { dst, list, plan, pieces } => {
                // runtime/construct.rs's word encoding: each piece's tag,
                // then its operand Values, in one stack array (the same
                // pass-by-pointer shape `array` gives listnew/closure/
                // callvalue: the operands stay rooted in their own
                // registers, live at this safepoint, for the whole call).
                use crate::runtime::construct::{MODE_LIST, MODE_PLAN, TAG_ELEM, TAG_REGION, TAG_SPAN};
                let mut words: Vec<ir::Value> = Vec::new();
                for piece in pieces {
                    let tag = match piece {
                        nir::Piece::Span(_) => TAG_SPAN,
                        nir::Piece::Region(..) => TAG_REGION,
                        nir::Piece::Elem(_) => TAG_ELEM,
                    };
                    words.push(self.iconst(tag));
                    for r in piece.regs() {
                        words.push(self.get(r));
                    }
                }
                let slot = self.b.create_sized_stack_slot(StackSlotData::new(
                    StackSlotKind::ExplicitSlot,
                    (words.len() * 8) as u32,
                    3,
                ));
                for (i, w) in words.iter().enumerate() {
                    let addr = self.b.ins().stack_addr(I64, slot, (i * 8) as i32);
                    self.b.ins().store(MemFlagsData::trusted(), *w, addr, 0);
                }
                let ptr = self.b.ins().stack_addr(I64, slot, 0);
                let n = self.iconst(words.len() as u64);
                let mode = self.iconst((if *list { MODE_LIST } else { 0 }) | (if *plan { MODE_PLAN } else { 0 }));
                let kind = match (*list, *plan) {
                    (false, false) => KIND_STR,
                    (true, false) => KIND_LIST,
                    (false, true) => KIND_STRPLAN,
                    (true, true) => KIND_LISTPLAN,
                };
                let v = self.call_allocating("rt_construct", &[self.vm, mode, n, ptr], "construct", kind);
                self.check(v);
                self.def(*dst, v);
            }
            Inst::StructNew { dst, shape, fields } => {
                // Field values stay rooted in their registers across the
                // allocating helper, like listnew's operands.
                let (n, ptr) = self.array(fields);
                let shape = self.iconst(*shape as u64);
                let v = self.call_allocating("rt_struct_new", &[self.vm, shape, n, ptr], "structnew", KIND_STRUCT);
                self.def(*dst, v);
            }
            Inst::StructGet { dst, slot, value } => {
                // A constant-slot load: the struct's field array lives behind
                // a raw pointer at STRUCT_PTR_OFFSET (value.rs's StructObj);
                // the slot was resolved from the receiver's known shape at
                // lowering time, so there is no bounds check and no name
                // lookup -- a struct's shape is fixed.
                let s = self.get(*value);
                let data = self.b.ins().load(I64, MemFlagsData::trusted(), s, STRUCT_PTR_OFFSET);
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), data, (*slot as i32) * 8);
                self.def(*dst, v);
            }
            Inst::Op { dst, op, args } => {
                // Each syscall transport compiles on every target: off its
                // own Linux architecture its helper fails at run time
                // (NATIVE UNSUPPORTED, runtime/syscall.rs), as the Tcl
                // backends refuse it at run time, so a program that only
                // defines a write still compiles and runs everywhere. The address bridges compute a payload
                // address on every target (range-checked into a small Int,
                // runtime/ops.rs; a 48-bit AArch64 Linux user address fits).
                let v = self.op(*op, args);
                if op.result_kind() != nir::RegKind::Tagged {
                    self.def_raw(*dst, v);
                } else {
                    self.def(*dst, v);
                }
            }
            Inst::Call { dst, func, args, may_error, may_gc } => {
                let mut values = vec![self.vm];
                values.extend(args.iter().map(|r| self.get(*r)));
                let r = self.func_ref(self.symbols.direct[*func as usize]);
                let call = self.b.ins().call(r, &values);
                if *may_gc { self.mark_safepoint(call); }
                self.finish_call(*dst, *func, call, *may_error);
            }
            Inst::CallEnv { dst, func, closure, args, may_error, may_gc } => {
                let mut values = vec![self.vm, self.get(*closure)];
                values.extend(args.iter().map(|r| self.get(*r)));
                let r = self.func_ref(self.symbols.direct[*func as usize]);
                let call = self.b.ins().call(r, &values);
                if *may_gc { self.mark_safepoint(call); }
                self.finish_call(*dst, *func, call, *may_error);
            }
            Inst::CallMulti { dsts, func, args, may_error, may_gc } => {
                let mut values = vec![self.vm];
                values.extend(args.iter().map(|r| self.get(*r)));
                self.call_multi(dsts, *func, &mut values, *may_error, *may_gc);
            }
            Inst::CallEnvMulti { dsts, func, closure, args, may_error, may_gc } => {
                let mut values = vec![self.vm, self.get(*closure)];
                values.extend(args.iter().map(|r| self.get(*r)));
                self.call_multi(dsts, *func, &mut values, *may_error, *may_gc);
            }
            Inst::CallValue { dst, callee, args } => {
                let f = self.get(*callee);
                let (n, ptr) = self.array(args);
                let v = self.call_helper("rt_call_value", &[self.vm, f, n, ptr]);
                self.check(v);
                self.def(*dst, v);
            }
            Inst::ForeignCall { dst, foreign, args, exposed, discard, varargs } => {
                // A destination declared a C word keeps the 64-bit result as
                // C returned it (C-FFI-ERROR-CAPTURE-MILESTONE-2.md): no
                // conversion runs after the call; `cwbox` makes the Int at
                // its first use that needs one.
                let word = self.f.kind_of(*dst).is_word();
                let v = self.foreign_call(*foreign, args, exposed, *discard, varargs, word)?;
                if word {
                    self.def_raw(*dst, v);
                } else {
                    self.def(*dst, v);
                }
            }
            Inst::Tail { args } | Inst::TailEnv { args, .. } => {
                let values: Vec<_> = args.iter().map(|r| self.get(*r)).collect();
                if let Inst::TailEnv { closure, .. } = inst {
                    let c = self.get(*closure);
                    self.b.def_var(self.closure.unwrap(), c);
                }
                for (i, v) in values.into_iter().enumerate() {
                    // nir.rs's validate already required this argument to be
                    // raw exactly when parameter slot i is (rawregs=): a
                    // backedge into a raw parameter carries a raw value
                    // straight through, never re-boxing to cross it.
                    if self.f.scalar_regs[i] {
                        self.def_raw(i as Reg, v);
                    } else {
                        self.def(i as Reg, v);
                    }
                }
                self.b.ins().jump(self.body, &[]);
                self.terminated = true;
            }
            Inst::Br { cond, then, otherwise } => {
                let c = self.get(*cond);
                let flag = self.b.ins().icmp_imm_s(IntCC::Equal, c, TRUE as i64);
                let (t, e) = (self.label(*then), self.label(*otherwise));
                self.b.ins().brif(flag, t, &[], e, &[]);
                self.terminated = true;
            }
            Inst::Jump(l) => {
                let block = self.label(*l);
                self.b.ins().jump(block, &[]);
                self.terminated = true;
            }
            Inst::Ret(reg) => {
                let v = self.get(*reg);
                self.restore_root_frame();
                if self.f.scalar_result() && self.f.may_error {
                    // Raw Int / ShortString1 / packed ASCII result of a function that can
                    // fail: the value plus a nonzero status word
                    // (RAW-INT-ABI.md, SHORT-STRING.md). The scalar never
                    // carries the error: Empty is -1, a successful value.
                    let ok = self.iconst(1);
                    self.b.ins().return_(&[v, ok]);
                } else {
                    self.b.ins().return_(&[v]);
                }
                self.terminated = true;
            }
            Inst::RetMulti(regs) => {
                let values: Vec<_> = regs.iter().map(|r| self.get(*r)).collect();
                self.restore_root_frame();
                if values.len() > 2 {
                    // signature_n's hidden trailing pointer: fields 1.. go
                    // through it (Cranelift/the target ABI has only two
                    // integer return registers), field 0 returns normally
                    // (call_multi's caller checks it for 0 exactly like any
                    // other fallible call, never reading the buffer then).
                    let buf = self.result_buf.expect("results>2 function must have a result buffer");
                    for (i, v) in values[1..].iter().enumerate() {
                        self.b.ins().store(MemFlagsData::trusted(), *v, buf, (i * 8) as i32);
                    }
                    self.b.ins().return_(&values[..1]);
                } else {
                    self.b.ins().return_(&values);
                }
                self.terminated = true;
            }
            Inst::Raise { kind, message } => {
                let kind = self.string(kind);
                let message = self.string(message);
                self.fail_with("rt_raise", &[self.vm, kind, message]);
                self.terminated = true;
            }
            Inst::Unreachable => {
                let kind = self.string("BUG");
                let message = self.string(&format!(
                    "native code reached a point HIR proved unreachable (function {})",
                    self.f.name
                ));
                self.fail_with("rt_raise", &[self.vm, kind, message]);
                self.terminated = true;
            }
            Inst::Fail { id, name, shape, payload } => {
                let id_val = self.iconst(*id as u64);
                let name_val = self.string(name);
                if payload.is_empty() {
                    self.fail_with("rt_fail_declared", &[self.vm, id_val, name_val]);
                } else {
                    // ERROR-PAYLOADS.md: the payload's field values, from a
                    // stack array, into the Vm's payload slots.
                    let (n, ptr) = self.array(payload);
                    let shape_val = self.iconst(*shape as u64);
                    self.fail_with("rt_fail_declared_payload", &[self.vm, id_val, name_val, shape_val, n, ptr]);
                }
                self.terminated = true;
            }
            Inst::DeclaredPayload { dst, index } => {
                let index_val = self.iconst(*index as u64);
                let v = self.call_helper("rt_declared_payload", &[self.vm, index_val]);
                self.def(*dst, v);
            }
            Inst::DeclaredErrorEq { dst, id } => {
                let raw = self.call_helper("rt_declared_error", &[self.vm]);
                let flag = self.b.ins().icmp_imm_s(IntCC::Equal, raw, *id as i64);
                let v = self.bool_of(flag);
                self.def(*dst, v);
            }
            Inst::ClearDeclaredError => {
                self.call_helper("rt_clear_declared_error", &[self.vm]);
            }
            Inst::PushErrorExit(l) => {
                let target = self.label(*l);
                self.error_exit_stack.push(target);
            }
            Inst::PopErrorExit => {
                if self.error_exit_stack.len() > 1 {
                    self.error_exit_stack.pop();
                }
            }
            Inst::Reraise => {
                let target = self.current_error_exit();
                self.b.ins().jump(target, &[]);
                self.terminated = true;
            }
        }
        Ok(())
    }

    /// A known operation on operands of the kinds it requires.
    fn op(&mut self, op: OpCode, args: &[Reg]) -> ir::Value {
        use OpCode::*;
        let a: Vec<ir::Value> = args.iter().map(|r| self.get(*r)).collect();
        match op {
            IAdd | ISub | IMul => self.int_arith(op, a[0], a[1]),
            IMod => self.int_mod(a[0], a[1]),
            IAnd | IOr | IXor => self.int_bitop(op, a[0], a[1]),
            ILt | ILe | IGt | IGe | IEq => self.int_compare(op, a[0], a[1]),
            ListGet if self.listget_fast => self.list_get(a[0], a[1]),
            ListGetProven if self.listget_fast => self.list_get_proven(a[0], a[1]),
            // MutableArray (MUTABLE-ARRAY.md): the header's LEN/PTR/UNIQUE
            // words (value.rs's MutArrayObj), read inline.
            MutArrayCapacity if self.mutarray_inline => self.mutarray_capacity(a[0]),
            MutArrayGet if self.mutarray_access => self.mutarray_get(a[0], a[1], false),
            MutArrayGetProven if self.mutarray_access => self.mutarray_get(a[0], a[1], true),
            MutArraySet if self.mutarray_access => self.mutarray_set(a[0], a[1], a[2], false),
            MutArraySetProven if self.mutarray_access => self.mutarray_set(a[0], a[1], a[2], true),
            // Inline String/UnicodeChar reads (ENCODE-UTF8-ALLOCATION-
            // RESEARCH.md): a character scan over str::length, str::char_at
            // and char::scalar_value runs without a helper call on ASCII text.
            // The String's character count, re-tagged as a small Int.
            StrLen => {
                let chars = self.b.ins().load(I64, MemFlagsData::trusted(), a[0], STR_CHARS_OFFSET);
                let shifted = self.b.ins().ishl_imm_s(chars, 1);
                self.b.ins().bor_imm_s(shifted, 1)
            }
            // char::scalar_value: the immediate's payload (cp << 3 | CHAR_TAG)
            // re-tagged as a small Int (cp << 1 | 1); never fails.
            CharCodepoint => {
                let cp = self.b.ins().ushr_imm_s(a[0], 3);
                let shifted = self.b.ins().ishl_imm_s(cp, 1);
                self.b.ins().bor_imm_s(shifted, 1)
            }
            // str::char_at at a proven index: an ASCII String's character I is
            // its text byte I; otherwise rt_str_char_at_proven decodes.
            StrCharAtProven => {
                let ascii_path = self.b.create_block();
                let wide = self.b.create_block();
                let done = self.b.create_block();
                let result = self.b.append_block_param(done, I64);
                let ascii = self.b.ins().uload8(I64, MemFlagsData::trusted(), a[0], STR_ASCII_OFFSET);
                self.b.ins().brif(ascii, ascii_path, &[], wide, &[]);
                self.b.switch_to_block(ascii_path);
                let idx = self.b.ins().sshr_imm_s(a[1], 1);
                let addr = self.b.ins().iadd(a[0], idx);
                let byte = self.b.ins().uload8(I64, MemFlagsData::trusted(), addr, STR_TEXT_OFFSET as i32);
                let shifted = self.b.ins().ishl_imm_s(byte, 3);
                let ch = self.b.ins().bor_imm_s(shifted, CHAR_TAG as i64);
                self.b.ins().jump(done, &[BlockArg::Value(ch)]);
                self.b.switch_to_block(wide);
                let v = self.call_helper("rt_str_char_at_proven", &[self.vm, a[0], a[1]]);
                self.b.ins().jump(done, &[BlockArg::Value(v)]);
                self.b.switch_to_block(done);
                result
            }
            CharEq | EnumEq => {
                let eq = self.b.ins().icmp(IntCC::Equal, a[0], a[1]);
                self.bool_of(eq)
            }
            // Floating-point arithmetic and comparisons (FLOAT64-MILESTONE-1.md):
            // the target's own floating-point instructions on the unboxed
            // numbers (float_op); the conversions are runtime helpers.
            F64Add | F64Sub | F64Mul | F64Div | F64Neg | F64Lt | F64Le | F64Gt | F64Ge | F64Eq
            | D64Add | D64Sub | D64Mul | D64Div | D64Neg => {
                let (ty, fop) = op.float().expect("a floating-point operation");
                self.float_op(ty, fop, &a)
            }
            // DecimalRounded's observations (DECIMAL-ROUNDED-MILESTONE-1.md):
            // exact decimal rounding at the precision operand, a runtime
            // helper (runtime::decimal).
            D64Lt | D64Le | D64Gt | D64Ge | D64Eq => {
                let cc = match op {
                    D64Lt => IntCC::SignedLessThan,
                    D64Le => IntCC::SignedLessThanOrEqual,
                    D64Gt => IntCC::SignedGreaterThan,
                    D64Ge => IntCC::SignedGreaterThanOrEqual,
                    _ => IntCC::Equal,
                };
                let order = self.call_helper("rt_decimal_cmp", &[self.vm, a[0], a[1], a[2]]);
                let flag = self.b.ins().icmp_imm_s(cc, order, 0);
                self.bool_of(flag)
            }
            D64ToF64 => self.call_allocating("rt_decimal_to_f64", &[self.vm, a[0], a[1]], "d64tof64", KIND_FLOAT),
            D64Round => {
                let v = self.call_allocating("rt_decimal_round", &[self.vm, a[0], a[1]], "d64round", KIND_DECIMAL);
                self.check(v);
                v
            }
            F64FromInt => {
                let v = self.call_allocating("rt_f64_from_int", &[self.vm, a[0]], "f64fromint", KIND_FLOAT);
                self.check(v);
                v
            }
            F64Trunc => self.call_allocating("rt_f64_trunc", &[self.vm, a[0]], "f64trunc", KIND_BIGINT),
            F64Round => self.call_allocating("rt_f64_round", &[self.vm, a[0]], "f64round", KIND_BIGINT),
            // DecimalRounded's text at the precision operand, and an Int's
            // text both ways (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md): runtime
            // helpers; only strtoint fails (the declared InvalidIntegerText,
            // routed by `check` like a `fail`).
            D64ToStr => self.call_allocating("rt_decimal_to_str", &[self.vm, a[0], a[1]], "d64tostr", KIND_STR),
            IntToStr => self.call_allocating("rt_int_to_str", &[self.vm, a[0]], "inttostr", KIND_STR),
            StrToInt => {
                let v = self.call_allocating("rt_str_to_int", &[self.vm, a[0]], "strtoint", KIND_BIGINT);
                self.check(v);
                v
            }
            // C addresses (C-ABI-TYPES.md): the null pointer is a constant
            // word, the null test one comparison with it, and clone, erase
            // and retype are the word itself -- no machine operation, no
            // allocation, no runtime type descriptor.
            CPtrNull => self.iconst(CPTR_NULL),
            CPtrIsNull => {
                let eq = self.b.ins().icmp_imm_s(IntCC::Equal, a[0], CPTR_NULL as i64);
                self.bool_of(eq)
            }
            CPtrSame => a[0],
            // `keepalive %b` (C-FFI-ERROR-CAPTURE-MILESTONE-1.md): no machine
            // operation at all. What keeps %b a GC root up to here is the NIR
            // use itself: codegen::roots's liveness counts it, so %b's slot
            // is in the stack map of every safepoint before it -- the
            // exposing syscall's or C call's own included -- and is not
            // reused before it. Emitting nothing also means nothing runs
            // between a C call and the code that reads its result: a call
            // there could disturb the C error state (errno).
            KeepAlive => self.iconst(UNIT),
            VEq | VEqTotal => {
                // Two small Ints compare as words; everything else structurally.
                let (fast, slow, done, result) = self.both_small_split(a[0], a[1]);
                self.b.switch_to_block(fast);
                let eq = self.b.ins().icmp(IntCC::Equal, a[0], a[1]);
                let r = self.bool_of(eq);
                self.b.ins().jump(done, &[BlockArg::Value(r)]);
                self.b.switch_to_block(slow);
                let r = self.call_helper("rt_value_eq", &[self.vm, a[0], a[1]]);
                if op == VEq {
                    // (VEqTotal's operands are proven equality-total: the
                    // helper cannot refuse them, op_may_error.)
                    self.check(r);
                }
                self.b.ins().jump(done, &[BlockArg::Value(r)]);
                self.b.switch_to_block(done);
                result
            }
            IsInt | IsStr | IsList | IsMutArray => {
                let kind = match op {
                    IsInt => Kind::Int,
                    IsStr => Kind::Str,
                    IsMutArray => Kind::MutArray,
                    _ => Kind::List,
                };
                let flag = self.is_kind(a[0], kind);
                self.bool_of(flag)
            }
            // Representation transitions and raw (untagged) integer
            // arithmetic/comparison: lower.tcl emits these only where range
            // analysis proved they are safe (see the "Representation"
            // section of native/lower.tcl), so no check is needed here.
            // C words (C-FFI-ERROR-CAPTURE-MILESTONE-2.md): the operand's
            // kind is its signedness.
            CWBox => {
                let signed = self.f.kind_of(args[0]) == nir::RegKind::I64;
                self.box_word(a[0], signed)
            }
            CWLt | CWLe | CWGt | CWGe | CWEq => {
                let signed = self.f.kind_of(args[0]) == nir::RegKind::I64;
                let word = self.f.kind_of(args[1]).is_word();
                self.word_compare(op, a[0], a[1], signed, word)
            }
            RBox => {
                // a[0] is raw and proven within the small-Int range.
                let shifted = self.b.ins().ishl_imm_s(a[0], 1);
                self.b.ins().bor_imm_s(shifted, 1)
            }
            RUnbox => {
                // a[0] is a tagged Value proven to be a small Int.
                self.b.ins().sshr_imm_s(a[0], 1)
            }
            // ShortString1 (SHORT-STRING.md): one i64, -1 Empty, else the
            // scalar value. Equality is word equality (both encodings are
            // canonical); the length is 0 for -1 and 1 otherwise.
            ShortEq => {
                let flag = self.b.ins().icmp(IntCC::Equal, a[0], a[1]);
                self.bool_of(flag)
            }
            ShortLen => {
                let flag = self.b.ins().icmp_imm_s(IntCC::NotEqual, a[0], -1);
                self.b.ins().uextend(I64, flag)
            }
            // Tagged String -> ShortString1, inline: the operand is a String
            // the compiler proved has at most one character, so its
            // character count is 0 or 1 and its first scalar is the whole
            // payload.
            StrToShort => {
                // No cached first scalar (STRING-ALLOCATION.md): Empty -> -1;
                // an ASCII String's first byte is its scalar (one load at the
                // inline text's constant offset); a non-ASCII one decodes in
                // the helper.
                let chars = self.b.ins().load(I64, MemFlagsData::trusted(), a[0], STR_CHARS_OFFSET);
                let empty = self.b.ins().icmp_imm_s(IntCC::Equal, chars, 0);
                let nonempty = self.b.create_block();
                let ascii_path = self.b.create_block();
                let wide = self.b.create_block();
                let done = self.b.create_block();
                let result = self.b.append_block_param(done, I64);
                let minus_one = self.b.ins().iconst(I64, -1);
                self.b.ins().brif(empty, done, &[BlockArg::Value(minus_one)], nonempty, &[]);
                self.b.switch_to_block(nonempty);
                let ascii = self.b.ins().uload8(I64, MemFlagsData::trusted(), a[0], STR_ASCII_OFFSET);
                self.b.ins().brif(ascii, ascii_path, &[], wide, &[]);
                self.b.switch_to_block(ascii_path);
                let byte = self.b.ins().uload8(I64, MemFlagsData::trusted(), a[0], STR_TEXT_OFFSET as i32);
                self.b.ins().jump(done, &[BlockArg::Value(byte)]);
                self.b.switch_to_block(wide);
                let v = self.call_helper("rt_str_to_short", &[self.vm, a[0]]);
                self.b.ins().jump(done, &[BlockArg::Value(v)]);
                self.b.switch_to_block(done);
                result
            }
            StrSliceShort => self.call_helper("rt_str_slice_short", &[self.vm, a[0], a[1], a[2]]),
            // ShortString1 -> tagged String: UTF-8 encode the scalar into a
            // fresh String (no interned table; a statically known value is a
            // `str` constant and never reaches this op).
            ShortToStr => self.call_allocating("rt_short_to_str", &[self.vm, a[0]], "shorttostr", KIND_STR),
            // Packed ASCII (tier A, SHORT-STRING.md): byte i = 0x80 | c.
            // Equality is word equality (the form is canonical).
            AsciiEq => {
                let flag = self.b.ins().icmp(IntCC::Equal, a[0], a[1]);
                self.bool_of(flag)
            }
            // length = (71 - clz(w)) >> 3: the highest set bit of a word of
            // n characters is bit 8n - 1 (its presence flag), and 0 gives 0.
            AsciiLen => {
                let lz = self.b.ins().clz(a[0]);
                let seventy_one = self.b.ins().iconst(I64, 71);
                let diff = self.b.ins().isub(seventy_one, lz);
                self.b.ins().ushr_imm_s(diff, 3)
            }
            // Word of at most one character -> ShortString1: 0 is Empty
            // (-1), else the payload byte.
            AsciiToShort => {
                let empty = self.b.ins().icmp_imm_s(IntCC::Equal, a[0], 0);
                let minus_one = self.b.ins().iconst(I64, -1);
                let payload = self.b.ins().band_imm_s(a[0], 0x7f);
                self.b.ins().select(empty, minus_one, payload)
            }
            // Ascii == ShortString1: pack the scalar (Empty -> 0, an ASCII
            // scalar c -> 0x80 | c, anything else -> 1, a word no canonical
            // packed String can equal) and compare words.
            AsciiShortEq => {
                let is_empty = self.b.ins().icmp_imm_s(IntCC::Equal, a[1], -1);
                let is_ascii = self.b.ins().icmp_imm_s(IntCC::UnsignedLessThan, a[1], 0x80);
                let packed = self.b.ins().bor_imm_s(a[1], 0x80);
                let one = self.b.ins().iconst(I64, 1);
                let zero = self.b.ins().iconst(I64, 0);
                let non_empty = self.b.ins().select(is_ascii, packed, one);
                let candidate = self.b.ins().select(is_empty, zero, non_empty);
                let flag = self.b.ins().icmp(IntCC::Equal, a[0], candidate);
                self.bool_of(flag)
            }
            // Tagged ASCII String (<= 8 characters, the caller's proof) ->
            // packed word: a non-allocating helper (reading a variable
            // number of bytes safely without overrunning the allocation).
            StrToAscii => self.call_helper("rt_str_to_ascii", &[self.vm, a[0]]),
            AsciiToStr => self.call_allocating("rt_ascii_to_str", &[self.vm, a[0]], "asciitostr", KIND_STR),
            RIAdd => self.b.ins().iadd(a[0], a[1]),
            RISub => self.b.ins().isub(a[0], a[1]),
            RIMul => self.b.ins().imul(a[0], a[1]),
            // native/lower.tcl's RawEligibleShift already proved a[0]
            // nonnegative and small and a[1] a single small value strictly
            // below the host word width, so this is a direct host machine
            // shift on the raw i64 operand -- never the tagged word (a
            // tagged small Int's own low bit is the representation tag, not
            // part of the logical integer, so shifting it directly would be
            // wrong: see this file's own int_bitop for the analogous
            // AND/OR/XOR case, which *can* operate on the tagged word
            // because bitwise-AND/OR/XOR of two tag-1 words keeps the tag
            // bit fixed -- a shift has no such property). `sshr` (not
            // `ushr`): Botlish's own shift_right is an arithmetic
            // (sign-extending) shift, and RawEligibleShift's nonnegative
            // requirement on a[0] makes the two coincide for every value
            // that reaches here.
            RIShr => self.b.ins().sshr(a[0], a[1]),
            RIShl => self.b.ins().ishl(a[0], a[1]),
            // native/lower.tcl's RawEligibleCall proved both raw operands
            // small, so the logical integers' own two's-complement bits are
            // the whole value: the host instruction is the operation.
            RIAnd => self.b.ins().band(a[0], a[1]),
            RIOr => self.b.ins().bor(a[0], a[1]),
            RIXor => self.b.ins().bxor(a[0], a[1]),
            // native/lower.tcl's RawEligibleCall proved both raw operands
            // small, so the remainder is small too and no path allocates.
            // RIModTotal's divisor Range excludes 0 (no test at all); RIMod
            // tests it and, for 0, raises rt_int_mod's own ARITHMETIC error
            // on a cold path (the helper given a zero divisor only records
            // the error: no allocation, so no safepoint).
            RIModTotal => self.euclid_mod(a[0], a[1]),
            RIMod => {
                let nonzero = self.b.create_block();
                let zero = self.b.create_block();
                self.b.set_cold_block(zero);
                self.b.ins().brif(a[1], nonzero, &[], zero, &[]);
                self.b.switch_to_block(zero);
                let shifted = self.b.ins().ishl_imm_s(a[0], 1);
                let dividend = self.b.ins().bor_imm_s(shifted, 1);
                let tagged_zero = self.iconst(1);
                self.fail_with("rt_int_mod", &[self.vm, dividend, tagged_zero]);
                self.b.switch_to_block(nonzero);
                self.euclid_mod(a[0], a[1])
            }
            RILt | RILe | RIGt | RIGe | RIEq => {
                let cc = match op {
                    RILt => IntCC::SignedLessThan,
                    RILe => IntCC::SignedLessThanOrEqual,
                    RIGt => IntCC::SignedGreaterThan,
                    RIGe => IntCC::SignedGreaterThanOrEqual,
                    _ => IntCC::Equal,
                };
                let flag = self.b.ins().icmp(cc, a[0], a[1]);
                self.bool_of(flag)
            }
            _ => {
                // The 4th element, when present, is this op's allocation
                // site (operation name, resulting object kind): see
                // `call_allocating`. None for helpers that never allocate.
                let (helper, extra, fallible, alloc): (&str, Option<u64>, bool, Option<(&'static str, u8)>) =
                    match op {
                        // Shifts always take the plain helper path: unlike
                        // IAdd/ISub/IMul/IMod/IAnd/IOr/IXor, a
                        // shift's tagged-word representation does not
                        // correspond to shifting the logical integer at all,
                        // so there is no cheap tagged-word trick to inline
                        // here -- see int_bitop's own doc for the AND/OR/XOR
                        // case, which does have one. Fallible: RANGE on an
                        // invalid shift amount (ops.rs's shift_amount). May
                        // allocate: the BigInt path (op_may_allocate above).
                        IShl => ("rt_int_shl", None, true, None),
                        IShr => ("rt_int_shr", None, true, None),
                        Hash => ("rt_hash", None, true, None),
                        // A Hashable operand (native/lower.tcl's `hashing`
                        // form): the same helper, which cannot refuse it.
                        HashTotal => ("rt_hash", None, false, None),
                        TableHash => ("rt_table_hash", None, true, None),
                        TableHashTotal => ("rt_table_hash", None, false, None),
                        RegionCheck => ("rt_str_region_check", None, true, None),
                        RegionEq => ("rt_str_region_eq", None, false, None),
                        StrEq => ("rt_str_eq", None, false, None),
                        StrByteLen => ("rt_str_byte_len", None, false, None),
                        StrCharAt => ("rt_str_char_at", None, true, None),
                        StrCharAtProven => ("rt_str_char_at_proven", None, false, None),
                        // The owned byte storage (ABI-BYTES.md). from_list
                        // allocates one object (or returns the static empty
                        // one) and is fallible (a non-byte element is TYPE);
                        // length/address read the header of a value that must
                        // be a storage (TYPE otherwise) and never allocate
                        // (keepalive is no call: above).
                        BytesFromList => ("rt_bytes_from_list", None, true, Some(("bytesfromlist", KIND_BYTES))),
                        BytesLen => ("rt_bytes_len", None, true, None),
                        BytesAddr => ("rt_bytes_addr", None, true, None),
                        // Fixed binary layouts (BINARY-LAYOUT.md): one helper
                        // call per field; all fallible only on operands a
                        // checked program never produces. A load may build a
                        // BigInt (a 64-bit field) or a Float64 (a C floating
                        // field: C-FLOAT-FFI-MILESTONE-1.md), so it is a
                        // safepoint; its site report names the BigInt kind
                        // either way (instrumentation only).
                        BytesZeroed => ("rt_bytes_zeroed", None, true, Some(("byteszeroed", KIND_BYTES))),
                        BinLoad => ("rt_bin_load", None, true, Some(("binload", KIND_BIGINT))),
                        BinStore => ("rt_bin_store", None, true, None),
                        // Native layout views (NATIVE-LAYOUT-VIEWS.md,
                        // runtime/nview.rs): one helper call per field read
                        // through the view's address, like binload's; a
                        // 64-bit scalar may build a BigInt, a C floating one
                        // a Float64 (a safepoint).
                        NativeLoad => ("rt_native_load", None, true, Some(("nativeload", KIND_BIGINT))),
                        NativeLoadPtr => ("rt_native_load_ptr", None, true, None),
                        CPtrOffset => ("rt_cptr_offset", None, true, None),
                        CPtrFixtureMemory => ("rt_cptr_fixture_memory", None, true, None),
                        // Native layout writes (NATIVE-LAYOUT-WRITES.md,
                        // runtime/nview.rs): one helper call per field
                        // written; a store through a native edit allocates
                        // nothing (no safepoint), a write into byte storage
                        // one fresh storage (the MutableBytes rule), the
                        // fixture's byte copy one List.
                        NativeStore => ("rt_native_store", None, true, None),
                        NativeStorePtr => ("rt_native_store_ptr", None, true, None),
                        MBytesWrite => ("rt_mbytes_write", None, true, Some(("mbyteswrite", KIND_MUTBYTES))),
                        MBytesWritePtr => ("rt_mbytes_write_ptr", None, true, Some(("mbyteswriteptr", KIND_MUTBYTES))),
                        CPtrFixtureBytes => ("rt_cptr_fixture_bytes", None, true, Some(("cptrfixturebytes", KIND_LIST))),
                        // Fixed arrays (FIXED-LAYOUT-ARRAYS.md): one helper
                        // call per row of scalars; a read makes its List (a
                        // safepoint), a write allocates nothing.
                        BinLoadArray => ("rt_bin_load_array", None, true, Some(("binloadarray", KIND_LIST))),
                        NativeLoadArray => ("rt_native_load_array", None, true, Some(("nativeloadarray", KIND_LIST))),
                        BinStoreArray => ("rt_bin_store_array", None, true, None),
                        NativeStoreArray => ("rt_native_store_array", None, true, None),
                        BinStorePtr => ("rt_bin_store_ptr", None, true, None),
                        // The writable byte storage (MUTABLE-BYTES.md): new /
                        // from / set / clone allocate one object, freeze and
                        // freeze_prefix one immutable one (all fallible, all
                        // safepoints); length/address read a header.
                        MBytesNew => ("rt_mbytes_new", None, true, Some(("mbytesnew", KIND_MUTBYTES))),
                        MBytesFrom => ("rt_mbytes_from", None, true, Some(("mbytesfrom", KIND_MUTBYTES))),
                        MBytesLen => ("rt_mbytes_len", None, true, None),
                        MBytesSet => ("rt_mbytes_set", None, true, Some(("mbytesset", KIND_MUTBYTES))),
                        MBytesClone => ("rt_mbytes_clone", None, true, Some(("mbytesclone", KIND_MUTBYTES))),
                        MBytesFreeze => ("rt_mbytes_freeze", None, true, Some(("mbytesfreeze", KIND_BYTES))),
                        MBytesFreezePrefix => ("rt_mbytes_freeze_prefix", None, true, Some(("mbytesfreezeprefix", KIND_BYTES))),
                        MBytesAddr => ("rt_mbytes_addr", None, true, None),
                        // Coroutines (COROUTINES.md, runtime/coroutine.rs):
                        // plain helper calls. Every one but codone is a
                        // safepoint (ops.rs's op_may_allocate), so the call's
                        // stack map holds this frame's roots while the
                        // coroutine is suspended inside it.
                        CoCreate => ("rt_co_create", None, false, Some(("cocreate", KIND_COROUTINE))),
                        CoStart => ("rt_co_start", None, true, None),
                        CoResume => ("rt_co_resume", None, true, None),
                        CoResume0 => ("rt_co_resume0", None, true, None),
                        CoYield => ("rt_co_yield", None, true, None),
                        CoDone => ("rt_co_done", None, false, None),
                        CPtrFixture => ("rt_cptr_fixture", None, true, None),
                        CPtrFixtureAddress => ("rt_cptr_fixture_address", None, false, None),
                        // The borrow test fixture (runtime/ffifixture.rs):
                        // fallible on an operand that is no address or count,
                        // fill_checked also with its declared UpperOverrun.
                        FfiFixtureRead => ("rt_ffi_fixture_read", None, true, Some(("ffifixtureread", KIND_LIST))),
                        FfiFixtureReadReentrant => {
                            ("rt_ffi_fixture_read_reentrant", None, true, Some(("ffifixturereadreentrant", KIND_LIST)))
                        }
                        FfiFixtureFill => ("rt_ffi_fixture_fill", None, true, None),
                        FfiFixtureFillChecked => ("rt_ffi_fixture_fill_checked", None, true, None),
                        FfiFixtureCopy => ("rt_ffi_fixture_copy", None, true, None),
                        FfiFixtureMixed => ("rt_ffi_fixture_mixed", None, true, None),
                        CoRelease => ("rt_co_release", None, false, None),
                        AffineDrop => ("rt_affine_drop", None, false, None),
                        // MutableVector (MUTABLE-VECTOR.md, runtime/mutvec.rs).
                        MvFromList => ("rt_mv_from_list", None, false, Some(("mvfromlist", KIND_MUTVEC))),
                        MvLen => ("rt_mv_len", None, false, None),
                        MvEmpty => ("rt_mv_empty", None, false, None),
                        MvAt => ("rt_mv_at", None, true, None),
                        MvPush => ("rt_mv_push", None, false, None),
                        MvPop => ("rt_mv_pop", None, true, None),
                        MvTake => ("rt_mv_take", None, true, None),
                        MvSwap => ("rt_mv_swap", None, true, None),
                        MvClear => ("rt_mv_clear", None, false, None),
                        MvShare => ("rt_mv_share", None, false, Some(("mvshare", KIND_MUTVEC))),
                        MvToList => ("rt_mv_to_list", None, false, Some(("mvtolist", KIND_LIST))),
                        MvTakeFront => ("rt_mv_take_front", None, false, None),
                        MvClearDrop => ("rt_mv_clear_drop", None, false, None),
                        MvSwapDrop => ("rt_mv_swap_drop", None, true, None),
                        CtxRoot => ("rt_context_root", None, false, None),
                        // MutableArray (MUTABLE-ARRAY.md, runtime/ops.rs).
                        MutArrayCreate => ("rt_mutarray_create", None, true, Some(("mutarraycreate", KIND_MUTARRAY))),
                        MutArrayFromList => ("rt_mutarray_from_list", None, false, Some(("mutarrayfromlist", KIND_MUTARRAY))),
                        MutArrayGenerate => ("rt_mutarray_generate", None, true, None),
                        MutArrayGenerateDrop => ("rt_mutarray_generate_drop", None, true, None),
                        MutArraySwap => ("rt_mutarray_swap", None, true, None),
                        MutArraySwapDrop => ("rt_mutarray_swap_drop", None, true, None),
                        MutArraySetDrop => ("rt_mutarray_set_drop", None, true, None),
                        MutArrayToList => ("rt_mutarray_to_list", None, false, Some(("mutarraytolist", KIND_LIST))),
                        MutArrayEmpty => ("rt_mutarray_empty", None, false, None),
                        MutArrayTakeFront => ("rt_mutarray_take_front", None, false, None),
                        // Never fallible (see ops.rs's rt_str_decode_char_at):
                        // a one-character String can never exceed
                        // MAX_COLLECTION_LENGTH. Still routed through
                        // call_allocating (like Substr) for GC accounting and
                        // site attribution, since it does allocate.
                        DecodeCharAt => {
                            return self.call_allocating(
                                "rt_str_decode_char_at",
                                &[self.vm, a[0], a[1]],
                                "decodecharat",
                                KIND_STR,
                            );
                        }
                        Substr => ("rt_substr", None, true, Some(("substr", KIND_STR))),
                        // The proven siblings (nir.rs): the same helpers
                        // minus the bounds checks, so `fallible` is false
                        // (matching their absence from `op_may_error`) --
                        // the slice is valid by hir/completions.tcl's proof.
                        // A substring is never longer than its base, so
                        // nothing here can be rejected as oversized.
                        SubstrProven => ("rt_substr_proven", None, false, Some(("substr", KIND_STR))),
                        ListGetProven => ("rt_list_get_proven", None, false, None),
                        MutArrayGetProven => ("rt_mutarray_get_proven", None, false, None),
                        MutArraySetProven => ("rt_mutarray_set_proven", None, false, None),
                        MutArrayCopyProven => ("rt_mutarray_copy_proven", None, false, None),
                        MutArrayFreezeProven => {
                            return self.call_allocating(
                                "rt_mutarray_freeze_proven",
                                &[self.vm, a[0], a[1]],
                                "mutarrayfreeze",
                                KIND_LIST,
                            );
                        }
                        // Fallible: each may construct a new String/List,
                        // which the runtime rejects past
                        // MAX_COLLECTION_LENGTH (Vm::reject_oversized_collection).
                        StrLower => ("rt_str_lower", None, true, Some(("strlower", KIND_STR))),
                        StrCat => ("rt_str_cat", None, true, Some(("strcat", KIND_STR))),
                        StrAppendChar => ("rt_str_append_char", None, true, Some(("strappendchar", KIND_STR))),
                        StrUtf8Bytes => {
                            ("rt_str_utf8_bytes", None, true, Some(("strutf8bytes", KIND_LIST)))
                        }
                        // No operands: the run's argument snapshot as a
                        // List of Strings. Fallible with the *declared*
                        // error InvalidArgumentEncoding (ops.rs's rt_argv
                        // sets the pending declared id before returning
                        // NO_VALUE, so `check` routes it like a `fail`).
                        Argv => ("rt_argv", None, true, Some(("argv", KIND_LIST))),
                        // The syscall transports: seven Int operands (the
                        // number register, then arguments 1-6), the raw result
                        // register back as an Int. Always
                        // a real helper call (never inline CLIF): Cranelift
                        // treats a call as reading and writing all memory,
                        // clobbering every caller-saved register, and never
                        // merges, hoists or deletes it. The helper itself
                        // executes the `syscall` / `svc #0` instruction
                        // (runtime/syscall.rs). It allocates only a BigInt
                        // result outside the small-Int range; fallible only
                        // on an operand that is no 64-bit word (TYPE: an
                        // unchecked program's unproven Register64).
                        SyscallLinuxX86_64 => {
                            ("rt_linux_x86_64_syscall", None, true, Some(("syscall", KIND_BIGINT)))
                        }
                        SyscallLinuxAarch64 => {
                            ("rt_linux_aarch64_syscall", None, true, Some(("syscall", KIND_BIGINT)))
                        }
                        // Never allocate (a Bool result, like StrEq); fallible
                        // (RANGE) on an operand that is not one Unicode scalar,
                        // like RegionCheck -- see ops.rs's rt_is_tcl_alpha/alnum.
                        StrIsTclAlpha => ("rt_is_tcl_alpha", None, true, None),
                        StrIsTclAlnum => ("rt_is_tcl_alnum", None, true, None),
                        // Same contract as StrIsTclAlpha/StrIsTclAlnum, over
                        // a validated StringRegion (base, start, end)
                        // instead of a materialized one-character String --
                        // never allocates, RANGE-fallible on the same
                        // not-exactly-one-scalar condition (ops.rs's
                        // rt_str_region_is_tcl_alpha/alnum).
                        StrRegionIsTclAlpha => ("rt_str_region_is_tcl_alpha", None, true, None),
                        StrRegionIsTclAlnum => ("rt_str_region_is_tcl_alnum", None, true, None),
                        ListLen => ("rt_list_len", None, false, None),
                        ListGet => ("rt_list_get", None, true, None),
                        ListWithLength => ("rt_list_with_length", None, true, None),
                        ListAppend => ("rt_list_append", None, true, Some(("listappend", KIND_LIST))),
                        // Deliberately no inline fast path (item 64: "a
                        // helper/runtime call is entirely acceptable"),
                        // unlike ListGet's own listget_fast special case
                        // above -- this milestone commits only to the
                        // simple O(n^2) reference semantics.
                        SetFromList => {
                            let v = self.call_allocating(
                                "rt_set_from_list",
                                &[self.vm, a[0]],
                                "setfromlist",
                                KIND_SET,
                            );
                            self.check(v);
                            return v;
                        }
                        // Same helper and allocation site kind as
                        // SetFromList; no `self.check` after the call
                        // (matches this opcode's own `op_may_error = false`
                        // classification, ops.rs) because native/lower.tcl
                        // only ever emits this opcode where it has already
                        // statically proven rt_set_from_list's own EQUALITY
                        // branch is unreachable for this call's own source
                        // list element type -- still allocates
                        // (op_may_allocate lists it, ops.rs), so still goes
                        // through call_allocating for GC accounting/site
                        // attribution (M4-EQUALITY-TOTAL-SETFROMLIST-EFFECT.md).
                        SetFromListTotal => {
                            let v = self.call_allocating(
                                "rt_set_from_list",
                                &[self.vm, a[0]],
                                "setfromlisttotal",
                                KIND_SET,
                            );
                            return v;
                        }
                        // Never allocates, but may fail (EQUALITY: see
                        // ops.rs's rt_set_contains), so it takes the plain
                        // (non-allocating) helper path below with `fallible`
                        // true, exactly like ListGet.
                        SetContains => ("rt_set_contains", None, true, None),
                        // Same helper as SetContains; `fallible: false`
                        // (no `self.check` after the call) matches this
                        // opcode's own `op_may_error = false` classification
                        // (ops.rs): native/lower.tcl only ever emits this
                        // opcode where it has already statically proven
                        // rt_set_contains's EQUALITY branch is unreachable
                        // for this call's own operand types, so skipping the
                        // local NO_VALUE check here is sound, not merely an
                        // effect-analysis simplification (M3-EQUALITY-TOTAL-
                        // SETCONTAINS-EFFECT.md).
                        SetContainsTotal => ("rt_set_contains", None, false, None),
                        MutArrayAllocate => {
                            let v = self.call_allocating(
                                "rt_mutarray_allocate",
                                &[self.vm, a[0]],
                                "mutarrayallocate",
                                KIND_MUTARRAY,
                            );
                            self.check(v);
                            return v;
                        }
                        MutArrayCapacity => ("rt_mutarray_capacity", None, false, None),
                        MutArrayGet => ("rt_mutarray_get", None, true, None),
                        MutArraySet => ("rt_mutarray_set", None, true, None),
                        MutArrayCopy => ("rt_mutarray_copy", None, true, None),
                        MutArrayFreeze => {
                            let v = self.call_allocating(
                                "rt_mutarray_freeze",
                                &[self.vm, a[0], a[1]],
                                "mutarrayfreeze",
                                KIND_LIST,
                            );
                            self.check(v);
                            return v;
                        }
                        IsOk => ("rt_is_result", Some(1), false, None),
                        IsError => ("rt_is_result", Some(0), false, None),
                        ResultValue => ("rt_result_payload", Some(1), true, None),
                        ResultError => ("rt_result_payload", Some(0), true, None),
                        MkOk | MkError => {
                            let ok = self.iconst((op == MkOk) as u64);
                            let operation = if op == MkOk { "mkok" } else { "mkerror" };
                            return self.call_allocating(
                                "rt_result_new",
                                &[self.vm, ok, a[0]],
                                operation,
                                KIND_RESULT,
                            );
                        }
                        ListNew => {
                            let (n, ptr) = self.array(args);
                            let v = self.call_allocating("rt_list_new", &[self.vm, n, ptr], "listnew", KIND_LIST);
                            self.check(v);
                            return v;
                        }
                        _ => unreachable!(),
                    };
                let mut values = vec![self.vm];
                values.extend(&a);
                if let Some(extra) = extra {
                    values.push(self.iconst(extra));
                }
                let r = match alloc {
                    Some((operation, kind)) => self.call_allocating(helper, &values, operation, kind),
                    None => self.call_helper(helper, &values),
                };
                if fallible {
                    self.check(r);
                }
                r
            }
        }
    }

    /// Branches on "both operands are small Ints". Returns (fast, slow, done,
    /// done's I64 parameter); the builder is left in no particular block.
    fn both_small_split(&mut self, a: ir::Value, b: ir::Value) -> (ir::Block, ir::Block, ir::Block, ir::Value) {
        let both = self.b.ins().band(a, b);
        let low = self.b.ins().band_imm_s(both, 1);
        let small = self.b.ins().icmp_imm_s(IntCC::NotEqual, low, 0);
        let fast = self.b.create_block();
        let slow = self.b.create_block();
        let done = self.b.create_block();
        let result = self.b.append_block_param(done, I64);
        self.b.ins().brif(small, fast, &[], slow, &[]);
        (fast, slow, done, result)
    }

    fn int_arith(&mut self, op: OpCode, a: ir::Value, b: ir::Value) -> ir::Value {
        let (fast, slow, done, result) = self.both_small_split(a, b);
        self.b.switch_to_block(fast);
        // Tagged words: a = 2x+1, b = 2y+1. Overflow of the word operation is
        // exactly "the result leaves the small range".
        let (r, overflow) = match op {
            OpCode::IAdd => {
                let b2 = self.b.ins().iadd_imm_s(b, -1);
                self.b.ins().sadd_overflow(a, b2)
            }
            OpCode::ISub => {
                let (d, of) = self.b.ins().ssub_overflow(a, b);
                (self.b.ins().iadd_imm_s(d, 1), of)
            }
            _ => {
                let x = self.b.ins().sshr_imm_s(a, 1);
                let b2 = self.b.ins().iadd_imm_s(b, -1);
                let (p, of) = self.b.ins().smul_overflow(x, b2);
                (self.b.ins().bor_imm_s(p, 1), of)
            }
        };
        self.b.ins().brif(overflow, slow, &[], done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(slow);
        let (helper, operation) = match op {
            OpCode::IAdd => ("rt_int_add", "iadd"),
            OpCode::ISub => ("rt_int_sub", "isub"),
            _ => ("rt_int_mul", "imul"),
        };
        // May not actually allocate (the result can still fit small, e.g.
        // BigInt - BigInt): call_allocating clears the site again after the
        // call either way, so an allocation-free slow path never leaves a
        // stale site id to misattribute a later allocation.
        let r = self.call_allocating(helper, &[self.vm, a, b], operation, KIND_BIGINT);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(done);
        result
    }

    /// Euclidean modulo of two raw small Ints, Y nonzero: `srem` (the sign
    /// of X) and the fix-up `r < 0 ? r + |Y| : r`, which lands on the one
    /// representative in [0, |Y|) -- rt_int_mod's and
    /// core::primitives::modulo's own rule. No overflow: X and Y lie in
    /// [-2^62, 2^62), so `srem` never sees i64::MIN / -1, |Y| <= 2^62, and
    /// r + |Y| < |Y|.
    fn euclid_mod(&mut self, x: ir::Value, y: ir::Value) -> ir::Value {
        let r = self.b.ins().srem(x, y);
        let abs = self.b.ins().iabs(y);
        let fixed = self.b.ins().iadd(r, abs);
        let negative = self.b.ins().icmp_imm_s(IntCC::SignedLessThan, r, 0);
        self.b.ins().select(negative, fixed, r)
    }

    /// Tagged `imod`: two small Ints with a nonzero divisor are decoded,
    /// reduced inline (`euclid_mod`) and re-tagged -- the remainder is small,
    /// |r| < |y| <= 2^62. A BigInt operand or a zero divisor (the tagged word
    /// 1) takes rt_int_mod, which allocates a BigInt remainder (so the op
    /// stays a safepoint, ops.rs's op_may_allocate, its stack map on that
    /// one call, like int_arith's) and raises ARITHMETIC for 0.
    fn int_mod(&mut self, a: ir::Value, b: ir::Value) -> ir::Value {
        let (fast, slow, done, result) = self.both_small_split(a, b);
        self.b.switch_to_block(fast);
        let compute = self.b.create_block();
        let zero = self.b.ins().icmp_imm_s(IntCC::Equal, b, 1);
        self.b.ins().brif(zero, slow, &[], compute, &[]);
        self.b.switch_to_block(compute);
        let x = self.b.ins().sshr_imm_s(a, 1);
        let y = self.b.ins().sshr_imm_s(b, 1);
        let r = self.euclid_mod(x, y);
        let shifted = self.b.ins().ishl_imm_s(r, 1);
        let tagged = self.b.ins().bor_imm_s(shifted, 1);
        self.b.ins().jump(done, &[BlockArg::Value(tagged)]);
        self.b.switch_to_block(slow);
        let r = self.call_helper("rt_int_mod", &[self.vm, a, b]);
        self.check(r);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(done);
        result
    }

    /// Bitwise AND/OR/XOR directly on the tagged words, never falling to a
    /// helper: unlike `+`/`-`/`*` (which can leave the small-Int range and
    /// need a BigInt fallback), AND/OR/XOR of two tagged Ints can never
    /// produce a result that needs more bits than the wider of its two
    /// operands already had, so a *proven-small* operand pair's tagged-word
    /// result is always itself proven small too -- no overflow check, no
    /// slow branch, ever. Both operands here are ordinary tagged Values
    /// (`2n+1`), not proven small by hir/range.tcl (operands it proves
    /// small are lowered to the raw RIAnd/RIOr/RIXor instead, with no
    /// tag test and no helper -- see native/lower.tcl's "Representation"
    /// section); this still works for two arbitrary tagged small Ints
    /// because the tag bit (bit 0) is 1 on both, so:
    ///   AND: (2x+1) & (2y+1) = 2(x&y) + 1 -- tag bit survives automatically
    ///   OR:  (2x+1) | (2y+1) = 2(x|y) + 1 -- likewise
    ///   XOR: (2x+1) ^ (2y+1) = 2(x^y) + 0 -- the two 1-tag-bits cancel, so
    ///        the raw xor's own bit 0 must be forced back to 1 afterward
    /// A BigInt operand (heap pointer, tag bit 0) never reaches this
    /// function: EmitArgGuards/hir::aot already proved both operands Int-
    /// kind, but "Int" spans both small and BigInt representations, so a
    /// genuine BigInt operand is still possible here -- handled by
    /// `both_small_split`'s runtime test exactly as `int_arith` does,
    /// falling to `rt_int_and`/`rt_int_or`/`rt_int_xor` (ops.rs) in that
    /// case, which is correct (if slower) for any Int, tagged or not.
    fn int_bitop(&mut self, op: OpCode, a: ir::Value, b: ir::Value) -> ir::Value {
        let (fast, slow, done, result) = self.both_small_split(a, b);
        self.b.switch_to_block(fast);
        let r = match op {
            OpCode::IAnd => self.b.ins().band(a, b),
            OpCode::IOr => self.b.ins().bor(a, b),
            _ => {
                let x = self.b.ins().bxor(a, b);
                self.b.ins().bor_imm_s(x, 1)
            }
        };
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(slow);
        let helper = match op {
            OpCode::IAnd => "rt_int_and",
            OpCode::IOr => "rt_int_or",
            _ => "rt_int_xor",
        };
        let r = self.call_helper(helper, &[self.vm, a, b]);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(done);
        result
    }

    /// The number of the floating-point value V of type TY, in a register of
    /// the target's floating-point class.
    fn float_number(&mut self, ty: FloatType, v: ir::Value) -> ir::Value {
        match ty {
            // (A DecimalRounded value's representation is a binary64 in the
            // same object layout.)
            FloatType::Float64 | FloatType::DecimalRounded => {
                self.b.ins().load(types::F64, MemFlagsData::trusted(), v, FLOAT_BITS_OFFSET)
            }
        }
    }

    /// The NonFiniteResult code (runtime::ops's NON_FINITE_CASES) of the
    /// non-finite number R, as runtime::ops's non_finite_code computes it:
    /// 2 (NotANumber) for NaN, else 0 or 1, the infinity of R's sign.
    fn non_finite_code(&mut self, r: ir::Value) -> ir::Value {
        let nan = self.b.ins().fcmp(FloatCC::Unordered, r, r);
        let zero = self.b.ins().f64const(0.0);
        let positive = self.b.ins().fcmp(FloatCC::GreaterThan, r, zero);
        let plus = self.iconst(0);
        let minus = self.iconst(1);
        let infinity = self.b.ins().select(positive, plus, minus);
        let not_a_number = self.iconst(2);
        self.b.ins().select(nan, not_a_number, infinity)
    }

    /// A C float argument (C-FLOAT-FFI-MILESTONE-1.md): the Float64 number X
    /// narrowed to binary32 by `fdemote`, IEEE 754's round to nearest, ties
    /// to even (the target's default rounding: Cranelift never changes it or
    /// flushes subnormals), its negative zero made zero (`n + 0.0`: a tiny
    /// negative number rounds to -0.0), and checked finite: a magnitude that
    /// rounded to an infinity fails the call before C runs, with the
    /// infinity's NonFiniteResult (rt_float_nonfinite), never clamped. X is
    /// finite, so the narrowed number is never NaN. runtime::value's
    /// narrow_binary32 computes the same in Rust.
    fn foreign_float_argument(&mut self, x: ir::Value) -> ir::Value {
        let narrowed = self.b.ins().fdemote(types::F32, x);
        let zero = self.b.ins().f32const(0.0);
        let n = self.b.ins().fadd(narrowed, zero);
        let magnitude = self.b.ins().fabs(n);
        let largest = self.b.ins().f32const(f32::MAX);
        let finite = self.b.ins().fcmp(FloatCC::LessThanOrEqual, magnitude, largest);
        let ok = self.b.create_block();
        let bad = self.b.create_block();
        self.b.ins().brif(finite, ok, &[], bad, &[]);
        self.b.switch_to_block(bad);
        let wide = self.b.ins().fpromote(types::F64, n);
        let result = self.non_finite_code(wide);
        self.fail_with("rt_float_nonfinite", &[self.vm, result]);
        self.b.switch_to_block(ok);
        n
    }

    /// The floating-point operation OP of type TY on the values A
    /// (runtime::ops's float_apply computes the same): a comparison is one
    /// `fcmp` (ordered: no operand is ever NaN); an arithmetic result has its
    /// negative zero made zero (`r + 0.0` is `r` for every other number) and,
    /// unless it is a negation, is checked finite -- |r| <= the largest
    /// finite number, false for an infinity and for NaN -- before it is
    /// boxed (rt_float_new); a non-finite one fails with NonFiniteFloat
    /// (rt_float_nonfinite, given which non-finite result it was). One runtime call on every path, as a safepoint
    /// needs (codegen::roots).
    fn float_op(&mut self, ty: FloatType, op: nir::FloatOp, a: &[ir::Value]) -> ir::Value {
        use nir::FloatOp::*;
        if op == Eq {
            let x = self.b.ins().load(I64, MemFlagsData::trusted(), a[0], FLOAT_BITS_OFFSET);
            let y = self.b.ins().load(I64, MemFlagsData::trusted(), a[1], FLOAT_BITS_OFFSET);
            let flag = self.b.ins().icmp(IntCC::Equal, x, y);
            return self.bool_of(flag);
        }
        let x = self.float_number(ty, a[0]);
        match op {
            Lt | Le | Gt | Ge => {
                let y = self.float_number(ty, a[1]);
                let cc = match op {
                    Lt => FloatCC::LessThan,
                    Le => FloatCC::LessThanOrEqual,
                    Gt => FloatCC::GreaterThan,
                    _ => FloatCC::GreaterThanOrEqual,
                };
                let flag = self.b.ins().fcmp(cc, x, y);
                self.bool_of(flag)
            }
            Add | Sub | Mul | Div | Neg => {
                let zero = self.b.ins().f64const(0.0);
                let r = match op {
                    Neg => self.b.ins().fsub(zero, x),
                    _ => {
                        let y = self.float_number(ty, a[1]);
                        match op {
                            Add => self.b.ins().fadd(x, y),
                            Sub => self.b.ins().fsub(x, y),
                            Mul => self.b.ins().fmul(x, y),
                            _ => self.b.ins().fdiv(x, y),
                        }
                    }
                };
                let r = self.b.ins().fadd(r, zero);
                if op != Neg {
                    let magnitude = self.b.ins().fabs(r);
                    let largest = self.b.ins().f64const(f64::MAX);
                    let finite = self.b.ins().fcmp(FloatCC::LessThanOrEqual, magnitude, largest);
                    let ok = self.b.create_block();
                    let bad = self.b.create_block();
                    self.b.ins().brif(finite, ok, &[], bad, &[]);
                    self.b.switch_to_block(bad);
                    let result = self.non_finite_code(r);
                    self.fail_with("rt_float_nonfinite", &[self.vm, result]);
                    self.b.switch_to_block(ok);
                }
                let bits = self.b.ins().bitcast(I64, MemFlagsData::new(), r);
                let code = self.iconst(ty.code());
                self.call_allocating("rt_float_new", &[self.vm, code, bits], "floatnew", ty.heap_kind())
            }
            Eq | FromInt | Trunc => unreachable!("not computed in floating-point registers"),
        }
    }

    fn int_compare(&mut self, op: OpCode, a: ir::Value, b: ir::Value) -> ir::Value {
        let cc = match op {
            OpCode::ILt => IntCC::SignedLessThan,
            OpCode::ILe => IntCC::SignedLessThanOrEqual,
            OpCode::IGt => IntCC::SignedGreaterThan,
            OpCode::IGe => IntCC::SignedGreaterThanOrEqual,
            _ => IntCC::Equal,
        };
        let (fast, slow, done, result) = self.both_small_split(a, b);
        self.b.switch_to_block(fast);
        let flag = self.b.ins().icmp(cc, a, b);
        let r = self.bool_of(flag);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(slow);
        let order = self.call_helper("rt_int_cmp", &[self.vm, a, b]);
        let flag = self.b.ins().icmp_imm_s(cc, order, 0);
        let r = self.bool_of(flag);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(done);
        result
    }

    /// The comparison OP (`cwlt` ...) of the C word W -- signed when SIGNED,
    /// else unsigned -- with OTHER: a word of the same signedness when WORD
    /// (one machine comparison), else a tagged Int. A small Int is untagged
    /// and compared inline (a negative one is below every unsigned word); a
    /// BigInt goes to `rt_ffi_word_cmp`, which compares in place and
    /// allocates nothing. Either way exact, and no value is boxed: the C
    /// error state the comparison guards is still intact after it.
    fn word_compare(&mut self, op: OpCode, w: ir::Value, other: ir::Value, signed: bool, word: bool) -> ir::Value {
        let (scc, ucc) = match op {
            OpCode::CWLt => (IntCC::SignedLessThan, IntCC::UnsignedLessThan),
            OpCode::CWLe => (IntCC::SignedLessThanOrEqual, IntCC::UnsignedLessThanOrEqual),
            OpCode::CWGt => (IntCC::SignedGreaterThan, IntCC::UnsignedGreaterThan),
            OpCode::CWGe => (IntCC::SignedGreaterThanOrEqual, IntCC::UnsignedGreaterThanOrEqual),
            _ => (IntCC::Equal, IntCC::Equal),
        };
        let cc = if signed { scc } else { ucc };
        if word {
            let flag = self.b.ins().icmp(cc, w, other);
            return self.bool_of(flag);
        }
        let small = self.b.create_block();
        let big = self.b.create_block();
        let done = self.b.create_block();
        let result = self.b.append_block_param(done, I64);
        let tag = self.b.ins().band_imm_s(other, 1);
        self.b.ins().brif(tag, small, &[], big, &[]);
        self.b.switch_to_block(small);
        let n = self.b.ins().sshr_imm_s(other, 1);
        let mut flag = self.b.ins().icmp(cc, w, n);
        if !signed {
            // Every unsigned word is above a negative Int.
            let negative = self.b.ins().icmp_imm_s(IntCC::SignedLessThan, n, 0);
            let above = matches!(op, OpCode::CWGt | OpCode::CWGe);
            let fixed = self.b.ins().iconst(types::I8, above as i64);
            flag = self.b.ins().select(negative, fixed, flag);
        }
        let r = self.bool_of(flag);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(big);
        let s = self.iconst(signed as u64);
        let order = self.call_helper("rt_ffi_word_cmp", &[self.vm, w, s, other]);
        let flag = self.b.ins().icmp_imm_s(scc, order, 0);
        let r = self.bool_of(flag);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);
        self.b.switch_to_block(done);
        result
    }

    /// `list::at(LIST, INDEX)` at an index hir/completions.tcl proved valid
    /// (`listgetproven`): the bare element read -- INDEX is a small tagged Int
    /// (a valid index is below the List's small length), decoded and loaded
    /// with no tag test, no bounds comparison and no slow path.
    fn list_get_proven(&mut self, list: ir::Value, index: ir::Value) -> ir::Value {
        let idx = self.b.ins().sshr_imm_s(index, 1);
        let ptr = self.b.ins().load(I64, MemFlagsData::trusted(), list, LIST_PTR_OFFSET);
        let byte_offset = self.b.ins().ishl_imm_s(idx, 3);
        let addr = self.b.ins().iadd(ptr, byte_offset);
        self.b.ins().load(I64, MemFlagsData::trusted(), addr, 0)
    }

    /// `list::at(LIST, INDEX)`'s inline fast path: LIST and INDEX already
    /// have semantic kinds List and Int respectively -- guaranteed, not
    /// merely likely, exactly like every other operand this file's `op`
    /// dispatches on (see ops.rs's module doc: "operands already have the
    /// kinds the operation requires"), since native/lower.tcl's NativeCall
    /// always runs EmitArgGuards before emitting `op listget` (a runtime
    /// `guard list`/`guard int`, or no guard at all when hir::aot already
    /// proved the argument's static type). So unlike codegen::clif's other
    /// representation-uncertain fast paths (`both_small_split` and its
    /// callers), this one needs no receiver-kind test at all: only INDEX's
    /// *representation* (small tagged Int vs BigInt heap object) is still
    /// open, since Kind::Int covers both. What remains genuinely dynamic --
    /// decoding a small index, bounds-checking it, and loading the element
    /// -- is inlined here; a BigInt index or an out-of-range/negative one
    /// falls back to `rt_list_get`, which still defines every failure's
    /// exact semantics (RANGE errors, BigInt indices) so this lowering
    /// never duplicates that logic.
    fn list_get(&mut self, list: ir::Value, index: ir::Value) -> ir::Value {
        let done = self.b.create_block();
        let result = self.b.append_block_param(done, I64);
        let slow = self.b.create_block();

        // INDEX is small (tagged: low bit 1) rather than a BigInt (heap
        // pointer: low bit 0), exactly `both_small_split`'s own test.
        let idx_tag = self.b.ins().band_imm_s(index, 1);
        let idx_is_small = self.b.ins().icmp_imm_s(IntCC::NotEqual, idx_tag, 0);
        let check_bounds = self.b.create_block();
        self.b.ins().brif(idx_is_small, check_bounds, &[], slow, &[]);

        // Bounds check: LIST's length is a small, nonnegative Int (its
        // MAX_COLLECTION_LENGTH invariant), so comparing the *decoded*
        // index against it as unsigned rejects a negative index (which
        // wraps to a huge unsigned value) and an out-of-range one alike in
        // one compare -- core/lists.tcl's `i < 0 || i >= length` in a
        // single IntCC::UnsignedLessThan, not two checks.
        self.b.switch_to_block(check_bounds);
        let idx = self.b.ins().sshr_imm_s(index, 1);
        let len = self.b.ins().load(I64, MemFlagsData::trusted(), list, LIST_LEN_OFFSET);
        let in_bounds = self.b.ins().icmp(IntCC::UnsignedLessThan, idx, len);
        let load_elem = self.b.create_block();
        self.b.ins().brif(in_bounds, load_elem, &[], slow, &[]);

        // Direct element load: LIST's elements live behind a raw pointer at
        // LIST_PTR_OFFSET (value.rs's ListObj), exactly ClosureObj's own
        // caps/ncaps pattern.
        self.b.switch_to_block(load_elem);
        let ptr = self.b.ins().load(I64, MemFlagsData::trusted(), list, LIST_PTR_OFFSET);
        let byte_offset = self.b.ins().ishl_imm_s(idx, 3);
        let addr = self.b.ins().iadd(ptr, byte_offset);
        let elem = self.b.ins().load(I64, MemFlagsData::trusted(), addr, 0);
        self.b.ins().jump(done, &[BlockArg::Value(elem)]);

        // Cold fallback: a BigInt index, or a bounds failure -- rt_list_get
        // re-derives the exact same declared IndexNotFound completion
        // `list::at`'s Tcl semantics (core/lists.tcl) define, never
        // duplicated here.
        self.b.switch_to_block(slow);
        let r = self.call_helper("rt_list_get", &[self.vm, list, index]);
        self.check(r);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);

        self.b.switch_to_block(done);
        result
    }

    // -----------------------------------------------------------------------
    // MutableArray (MUTABLE-ARRAY.md) inline paths. A header (value.rs's
    // MutArrayObj) carries, at fixed offsets, its element count (LEN), the
    // address of its first element (PTR) and whether its copy-on-write
    // backing is its alone (UNIQUE), kept exact by the runtime at every
    // change of the backing or the start. So `capacity` is one load, `at`
    // a bounds compare and two loads, `set` the same plus the copy-on-write
    // test and a store, and only what the runtime must decide -- a BigInt or
    // invalid index (the declared IndexNotFound), a shared backing (the
    // detach) -- calls the helper, which defines it exactly as before. None
    // of these paths allocates or is a safepoint (none was:
    // `op_may_allocate`), so roots and stack maps are unchanged; the
    // slow-path helpers are the same calls, in the same instruction, as the
    // whole operation was.

    /// The memory flags of an inline access to a MutableArray header's words
    /// (HEADER) or to its elements' slots: trusted (aligned and never
    /// trapping: a live array's header, an address among its elements), each
    /// in an alias region of its own. Generated code never stores to a
    /// header (only runtime helpers change it, and every call is a fence for
    /// every region in Cranelift's alias analysis) and no other CLIF access
    /// touches a header or a slot, so no location is ever accessed in two
    /// regions, the property alias regions require. It lets a header word's
    /// load be reused across stores to slots (redundant load elimination: a
    /// `capacity(a)` after an `a.set` needs no second load), though not
    /// across a call or a store in no region (a root slot's), which
    /// Cranelift treats as a fence.
    fn mutarray_flags(&mut self, header: bool) -> MemFlagsData {
        let (user_id, description) = if header { (1, "mutarray header") } else { (2, "mutarray slots") };
        let region = self.b.func.dfg.alias_regions.insert(ir::AliasRegionData { user_id, description: description.into() });
        MemFlagsData::trusted().with_alias_region(Some(region))
    }

    /// `mutable_array::capacity(ARR)`: the header's LEN, tagged. LEN is at
    /// most MAX_COLLECTION_LENGTH, a small Int, so the tag never overflows
    /// (the helper's `new_int` never allocated either).
    fn mutarray_capacity(&mut self, arr: ir::Value) -> ir::Value {
        let flags = self.mutarray_flags(true);
        let len = self.b.ins().load(I64, flags, arr, MUTARRAY_LEN_OFFSET);
        let shifted = self.b.ins().ishl_imm_s(len, 1);
        self.b.ins().bor_imm_s(shifted, 1)
    }

    /// The address of element IDX (a raw, valid index) of ARR: PTR + 8 IDX.
    fn mutarray_slot(&mut self, arr: ir::Value, idx: ir::Value) -> ir::Value {
        let flags = self.mutarray_flags(true);
        let ptr = self.b.ins().load(I64, flags, arr, MUTARRAY_PTR_OFFSET);
        let byte_offset = self.b.ins().ishl_imm_s(idx, 3);
        self.b.ins().iadd(ptr, byte_offset)
    }

    /// Branches to SLOW unless INDEX is a small Int below ARR's LEN; returns
    /// the decoded index, in the block where it is known valid. The unsigned
    /// compare rejects a negative index and a too-large one alike (LEN is a
    /// small nonnegative Int), exactly `list_get`'s test.
    fn mutarray_index(&mut self, arr: ir::Value, index: ir::Value, slow: ir::Block) -> ir::Value {
        let idx_tag = self.b.ins().band_imm_s(index, 1);
        let check_bounds = self.b.create_block();
        self.b.ins().brif(idx_tag, check_bounds, &[], slow, &[]);
        self.b.switch_to_block(check_bounds);
        let idx = self.b.ins().sshr_imm_s(index, 1);
        let flags = self.mutarray_flags(true);
        let len = self.b.ins().load(I64, flags, arr, MUTARRAY_LEN_OFFSET);
        let in_bounds = self.b.ins().icmp(IntCC::UnsignedLessThan, idx, len);
        let valid = self.b.create_block();
        self.b.ins().brif(in_bounds, valid, &[], slow, &[]);
        self.b.switch_to_block(valid);
        idx
    }

    /// `mutable_array::at(ARR, INDEX)`, inline. PROVEN (`mutarraygetproven`,
    /// hir/completions.tcl's bounds proof): INDEX is a small Int designating
    /// an element, so the read is the bare load, with no test and no slow
    /// path, exactly `list_get_proven`. Otherwise INDEX is tested
    /// (`mutarray_index`), and a BigInt or invalid one calls
    /// `rt_mutarray_get`, which reports the declared IndexNotFound.
    fn mutarray_get(&mut self, arr: ir::Value, index: ir::Value, proven: bool) -> ir::Value {
        if proven {
            let idx = self.b.ins().sshr_imm_s(index, 1);
            let addr = self.mutarray_slot(arr, idx);
            let flags = self.mutarray_flags(false);
            return self.b.ins().load(I64, flags, addr, 0);
        }
        let done = self.b.create_block();
        let result = self.b.append_block_param(done, I64);
        let slow = self.b.create_block();
        let idx = self.mutarray_index(arr, index, slow);
        let addr = self.mutarray_slot(arr, idx);
        let flags = self.mutarray_flags(false);
        let elem = self.b.ins().load(I64, flags, addr, 0);
        self.b.ins().jump(done, &[BlockArg::Value(elem)]);

        self.b.switch_to_block(slow);
        self.b.set_cold_block(slow);
        let r = self.call_helper("rt_mutarray_get", &[self.vm, arr, index]);
        self.check(r);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);

        self.b.switch_to_block(done);
        result
    }

    /// `mutable_array::set(ARR, INDEX, VALUE)`, inline: the store of VALUE
    /// into the element's slot, when the header's UNIQUE word says its
    /// backing is its alone -- the copy-on-write test `array_writable` makes
    /// (`Rc::strong_count == 1`), answered by one load, since the runtime
    /// clears UNIQUE wherever a backing gains a holder (value.rs's
    /// MutArrayObj). A shared backing (or, unless PROVEN, a BigInt or
    /// invalid index) calls the helper, which detaches it, writes, and
    /// re-enables UNIQUE (or reports IndexNotFound). The result is UNIT
    /// either way. Like the helper, this stores no Botlish object anywhere
    /// but the slot and allocates nothing: the collector, which traces an
    /// array's slots, sees the stored value at its next collection.
    fn mutarray_set(&mut self, arr: ir::Value, index: ir::Value, value: ir::Value, proven: bool) -> ir::Value {
        let done = self.b.create_block();
        let slow = self.b.create_block();
        let idx = if proven {
            self.b.ins().sshr_imm_s(index, 1)
        } else {
            self.mutarray_index(arr, index, slow)
        };
        let flags = self.mutarray_flags(true);
        let unique = self.b.ins().load(I64, flags, arr, MUTARRAY_UNIQUE_OFFSET);
        let store = self.b.create_block();
        self.b.ins().brif(unique, store, &[], slow, &[]);

        self.b.switch_to_block(store);
        let addr = self.mutarray_slot(arr, idx);
        let flags = self.mutarray_flags(false);
        self.b.ins().store(flags, value, addr, 0);
        self.b.ins().jump(done, &[]);

        self.b.switch_to_block(slow);
        self.b.set_cold_block(slow);
        if proven {
            self.call_helper("rt_mutarray_set_proven", &[self.vm, arr, index, value]);
        } else {
            let r = self.call_helper("rt_mutarray_set", &[self.vm, arr, index, value]);
            self.check(r);
        }
        self.b.ins().jump(done, &[]);

        self.b.switch_to_block(done);
        self.iconst(UNIT)
    }
}

/// Symbol names of every module function, for CLIF listings.
pub fn legend(symbols: &Symbols) -> String {
    let mut ids: Vec<_> = symbols.names.iter().collect();
    ids.sort();
    ids.iter().map(|(id, name)| format!("; u0:{id} = {name}\n")).collect()
}

/// The disassembly of a function calling, with literal arguments, the
/// foreign function `callee` of ABI classes PARAMS (result RESULT) through the
/// signature SIGNATURE makes for it, compiled for TRIPLE; a 16-byte explicit
/// stack slot written before the call and read after it sits right above the
/// outgoing argument area. Argument i is the integer -(i + 2) or the float
/// i + 0.5. TRIPLE's architecture must be the host's: a build's Cranelift has
/// its host's backend only (Cranelift's `host-arch`), so the Apple and
/// AAPCS64 checks run on AArch64 hosts and the SysV and Win64 ones on x86-64.
#[cfg(test)]
fn call_disassembly(
    triple: &str,
    params: &[nir::CAbi],
    result: nir::CAbi,
    signature: impl Fn(&cranelift_object::ObjectModule, &nir::ForeignDecl) -> Signature,
) -> String {
    use cranelift_codegen::settings::{self, Configurable};
    use std::str::FromStr;
    let triple = target_lexicon::Triple::from_str(triple).unwrap();
    let mut flags = settings::builder();
    flags.set("opt_level", "speed").unwrap();
    flags.set("is_pic", "true").unwrap();
    let isa = cranelift_codegen::isa::lookup(triple).unwrap().finish(settings::Flags::new(flags)).unwrap();
    let mut module = cranelift_object::ObjectModule::new(
        cranelift_object::ObjectBuilder::new(isa, "probe", cranelift_module::default_libcall_names()).unwrap(),
    );
    let decl = nir::ForeignDecl {
        symbol: "callee".into(),
        name: "callee".into(),
        params: params.to_vec(),
        result,
        alias: None,
        variadic: false,
    };
    let callee = module.declare_function("callee", Linkage::Import, &signature(&module, &decl)).unwrap();
    let mut sig = module.make_signature();
    sig.returns.push(AbiParam::new(types::I64));
    let mut func = ir::Function::with_name_signature(ir::UserFuncName::user(0, 0), sig);
    let mut context = FunctionBuilderContext::new();
    let mut b = FunctionBuilder::new(&mut func, &mut context);
    let block = b.create_block();
    b.switch_to_block(block);
    let slot = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, 16, 3));
    let sentinel = b.ins().iconst(types::I64, 0x1111_2222_3333_4444);
    b.ins().stack_store(types::I64, sentinel, slot, 0);
    let callee = module.declare_func_in_func(callee, b.func);
    let args: Vec<ir::Value> = params
        .iter()
        .enumerate()
        .map(|(i, c)| match c {
            nir::CAbi::F64 => b.ins().f64const(i as f64 + 0.5),
            nir::CAbi::F32 => b.ins().f32const(i as f32 + 0.5),
            _ => b.ins().iconst(c_type(*c), -(i as i64) - 2),
        })
        .collect();
    let call = b.ins().call(callee, &args);
    let returned = b.inst_results(call)[0];
    let word = match result {
        nir::CAbi::F64 => b.ins().bitcast(types::I64, MemFlagsData::new(), returned),
        nir::CAbi::F32 => {
            let wide = b.ins().fpromote(types::F64, returned);
            b.ins().bitcast(types::I64, MemFlagsData::new(), wide)
        }
        _ => returned,
    };
    let kept = b.ins().stack_load(types::I64, types::I64, slot, 0);
    let sum = b.ins().iadd(word, kept);
    b.ins().return_(&[sum]);
    b.seal_all_blocks();
    b.finalize(module.isa().frontend_config());
    let mut ctx = cranelift_codegen::Context::for_function(func);
    ctx.set_disasm(true);
    ctx.compile(module.isa(), &mut Default::default()).unwrap().vcode.clone().unwrap()
}

/// The foreign C signature compiled for Apple AArch64, read from Cranelift's
/// own disassembly of a call (call_disassembly). Runs on an AArch64 host,
/// whose Cranelift has the AArch64 backend (the macOS smoke job's and Linux
/// arm64 CI's driver tests); an x86-64 build has no AArch64 backend to ask.
#[cfg(all(test, target_arch = "aarch64"))]
mod apple_tests {
    use super::*;
    use cranelift_codegen::settings::{self, Configurable};
    use std::str::FromStr;

    /// Eight 64-bit register arguments, then stack arguments that Apple
    /// packs at their natural size and alignment -- a 64-bit one at 0, an
    /// int at 8, a short at 12, a signed char at 14 -- ending two bytes
    /// short of the 16-byte argument area.
    const STACK_TAIL: [nir::CAbi; 12] = {
        use nir::CAbi::*;
        [I64, I64, I64, I64, I64, I64, I64, I64, I64, I32, I16, I8]
    };

    /// Botlish's Apple signature stores each stack argument at its natural
    /// width at its packed offset -- `str w` at 8, `strh` at 12, `strb` at
    /// 14 -- so nothing is written past the argument area; and the narrow
    /// register arguments are extended by the caller, as Apple requires.
    #[test]
    fn ffi_apple_stack_arguments_stored_at_their_width() {
        let code = call_disassembly("aarch64-apple-darwin", &STACK_TAIL, nir::CAbi::I64, c_signature);
        for store in [", [sp, #8]", ", [sp, #12]", ", [sp, #14]"] {
            let line = code.lines().find(|l| l.contains(store)).unwrap_or_else(|| panic!("no store {store} in\n{code}"));
            let expected = match store {
                ", [sp, #8]" => "str w",
                ", [sp, #12]" => "strh w",
                _ => "strb w",
            };
            assert!(line.trim_start().starts_with(expected), "{line:?}, not {expected}, in\n{code}");
        }
        use nir::CAbi::*;
        let narrow = call_disassembly("aarch64-apple-darwin", &[I8, U8, I16, U16, I32, U32, Bool, I8], nir::CAbi::I64, c_signature);
        for extension in ["sxtb x0, w0", "uxtb w1, w1", "sxth x2, w2", "uxth w3, w3", "sxtw x4, w4", "mov w5, w5", "uxtb w6, w6", "sxtb x7, w7"] {
            assert!(narrow.contains(extension), "no {extension:?} in\n{narrow}");
        }
    }

    /// Doubles take floating-point registers (v0-v7) and leave the integer
    /// registers' count alone: after eight doubles, eight narrow integers
    /// are still x0-x7, each extended by the caller as Apple requires -- the
    /// count `target::c_extended_parameters` bounds is of integer-register
    /// parameters, never of positions.
    #[test]
    fn ffi_apple_doubles_leave_the_integer_registers() {
        use nir::CAbi::*;
        let params = [F64, F64, F64, F64, F64, F64, F64, F64, I8, U8, I16, U16, I32, U32, Bool, I8];
        let code = call_disassembly("aarch64-apple-darwin", &params, nir::CAbi::I64, c_signature);
        for extension in ["sxtb x0, w0", "uxtb w1, w1", "sxth x2, w2", "uxth w3, w3", "sxtw x4, w4", "mov w5, w5", "uxtb w6, w6", "sxtb x7, w7"] {
            assert!(code.contains(extension), "no {extension:?} in\n{code}");
        }
    }

    /// Why `target::c_extended_parameters` exists: Cranelift 0.135.2 stores
    /// an extended narrow stack argument with a full 8-byte `str` at its
    /// packed offset under AppleAarch64, so the last one here writes bytes
    /// 14 to 21, past the 16-byte argument area into the stack slot above
    /// it. When this fails after a Cranelift upgrade, the defect is fixed
    /// (it is in 0.136.0, whose `get_ext_mode` extends only register
    /// arguments under AppleAarch64): check the stores above and drop the
    /// exception.
    #[test]
    fn ffi_apple_extended_stack_argument_defect_still_present() {
        let every_parameter_extended = |module: &cranelift_object::ObjectModule, decl: &nir::ForeignDecl| {
            let mut sig = c_signature(module, decl);
            for (param, c) in sig.params.iter_mut().zip(&decl.params) {
                if c.bits() < 64 {
                    *param = if c.signed() { param.sext() } else { param.uext() };
                }
            }
            sig
        };
        let code = call_disassembly("aarch64-apple-darwin", &STACK_TAIL, nir::CAbi::I64, every_parameter_extended);
        assert!(
            code.lines().any(|l| l.trim_start().starts_with("str x") && l.contains(", [sp, #14]")),
            "Cranelift no longer stores an extended narrow stack argument at full width:\n{code}"
        );
    }

    /// The disassembly of one variadic C call (VARIADICS-VERTICAL-SLICE-1.md)
    /// compiled for TRIPLE: the fixed `int` 3, then the trailing arguments
    /// VARARGS -- an `int` 5, a double 2.5, a `long` 7, repeated as asked --
    /// through `c_call_signature`, its padding zeros between the two.
    fn variadic_disassembly(triple: &str, varargs: &[nir::VarArg]) -> String {
        let triple = target_lexicon::Triple::from_str(triple).unwrap();
        let mut flags = settings::builder();
        flags.set("opt_level", "speed").unwrap();
        flags.set("is_pic", "true").unwrap();
        let isa = cranelift_codegen::isa::lookup(triple).unwrap().finish(settings::Flags::new(flags)).unwrap();
        let module = cranelift_object::ObjectModule::new(
            cranelift_object::ObjectBuilder::new(isa, "probe", cranelift_module::default_libcall_names()).unwrap(),
        );
        let decl = nir::ForeignDecl {
            symbol: "callee".into(),
            name: "callee".into(),
            params: vec![nir::CAbi::I32],
            result: nir::CAbi::I32,
            alias: None,
            variadic: true,
        };
        let (signature, padding) = c_call_signature(&module, &decl, varargs).unwrap();
        let mut sig = module.make_signature();
        sig.returns.push(AbiParam::new(types::I32));
        let mut func = ir::Function::with_name_signature(ir::UserFuncName::user(0, 0), sig);
        let mut context = FunctionBuilderContext::new();
        let mut b = FunctionBuilder::new(&mut func, &mut context);
        let block = b.create_block();
        b.switch_to_block(block);
        let sig_ref = b.func.import_signature(signature);
        let name = b.func.declare_imported_user_function(ir::UserExternalName { namespace: 0, index: 1 });
        let callee = b.func.import_function(ir::ExtFuncData {
            name: ir::ExternalName::user(name),
            signature: sig_ref,
            colocated: false,
            patchable: false,
        });
        let mut args = vec![b.ins().iconst(types::I32, 3)];
        for t in &padding {
            args.push(if *t == types::F64 { b.ins().f64const(0.0) } else { b.ins().iconst(I64, 0) });
        }
        let apple = triple_is_apple(module.isa().triple());
        for a in varargs {
            args.push(match a.promoted {
                nir::CAbi::F64 => b.ins().f64const(2.5),
                nir::CAbi::I32 if !apple => b.ins().iconst(types::I32, 5),
                nir::CAbi::I32 => b.ins().iconst(I64, 5),
                _ => b.ins().iconst(I64, 7),
            });
        }
        let call = b.ins().call(callee, &args);
        let result = b.inst_results(call)[0];
        b.ins().return_(&[result]);
        b.seal_all_blocks();
        b.finalize(module.isa().frontend_config());
        let mut ctx = cranelift_codegen::Context::for_function(func);
        ctx.set_disasm(true);
        ctx.compile(module.isa(), &mut Default::default()).unwrap().vcode.clone().unwrap()
    }

    fn triple_is_apple(triple: &target_lexicon::Triple) -> bool {
        triple.operating_system.is_like_darwin()
    }

    const INT: nir::VarArg = nir::VarArg { class: nir::CAbi::I32, promoted: nir::CAbi::I32 };
    const DOUBLE: nir::VarArg = nir::VarArg { class: nir::CAbi::F64, promoted: nir::CAbi::F64 };
    const LONG: nir::VarArg = nir::VarArg { class: nir::CAbi::I64, promoted: nir::CAbi::I64 };

    /// Apple's convention passes every trailing argument on the stack in its
    /// own 8-byte slot, whatever registers are free: an int, a double and a
    /// long after one fixed int are the words at sp+0, +8 and +16 -- the int
    /// stored as a whole 64-bit word -- while the fixed int stays in w0 and
    /// the free x1-x7 and d0-d7 hold the padding (no trailing value is in a
    /// register at all).
    #[test]
    fn ffi_apple_variadic_arguments_on_the_stack() {
        let code = variadic_disassembly("aarch64-apple-darwin", &[INT, DOUBLE, LONG]);
        for (store, kind) in [("[sp]", "str x"), ("[sp, #8]", "str d"), ("[sp, #16]", "str x")] {
            let line = code
                .lines()
                .find(|l| l.contains(&format!(", {store}")) && l.trim_start().starts_with("str"))
                .unwrap_or_else(|| panic!("no store to {store} in\n{code}"));
            assert!(line.trim_start().starts_with(kind), "{line:?}, not {kind}, in\n{code}");
        }
        assert!(!code.contains("fmov d0, #2.5"), "a trailing double in v0:\n{code}");
        assert!(code.lines().any(|l| l.trim_start().starts_with("sxtw x0, ")), "the fixed int is not x0, extended:\n{code}");
        for register in ["x1", "x2", "x3", "x4", "x5", "x6", "v0.16b", "v6.16b"] {
            assert!(code.lines().any(|l| l.trim_start().starts_with(&format!("mov {register}, "))), "no padding in {register}:\n{code}");
        }
    }

    /// Only the registers a trailing argument's kind would take are padded:
    /// trailing doubles alone leave x1-x7 unpadded, trailing integers alone
    /// d0-d7 (`c_call_signature`'s padding is per kind, counted apart).
    #[test]
    fn ffi_apple_variadic_padding_per_kind() {
        let module = cranelift_object::ObjectModule::new(
            cranelift_object::ObjectBuilder::new(
                cranelift_codegen::isa::lookup(target_lexicon::Triple::from_str("aarch64-apple-darwin").unwrap())
                    .unwrap()
                    .finish(settings::Flags::new(settings::builder()))
                    .unwrap(),
                "probe",
                cranelift_module::default_libcall_names(),
            )
            .unwrap(),
        );
        let decl = nir::ForeignDecl {
            symbol: "f".into(),
            name: "f".into(),
            params: vec![nir::CAbi::I32, nir::CAbi::F64],
            result: nir::CAbi::Void,
            alias: None,
            variadic: true,
        };
        let (_, doubles) = c_call_signature(&module, &decl, &[DOUBLE, DOUBLE]).unwrap();
        let (_, ints) = c_call_signature(&module, &decl, &[INT]).unwrap();
        let (_, both) = c_call_signature(&module, &decl, &[INT, DOUBLE]).unwrap();
        assert_eq!(doubles, vec![types::F64; 7]);
        assert_eq!(ints, vec![I64; 7]);
        assert_eq!(both.len(), 14);
    }

    /// A fixed C float takes a floating-point register as a double does
    /// (SDL_RenderDebugTextFormat's renderer, x, y, fmt, ...): two fixed
    /// floats leave v2-v7 to pad, two fixed pointers x2-x7, so every
    /// trailing argument still lands on the stack.
    #[test]
    fn ffi_apple_variadic_padding_after_fixed_floats() {
        let module = cranelift_object::ObjectModule::new(
            cranelift_object::ObjectBuilder::new(
                cranelift_codegen::isa::lookup(target_lexicon::Triple::from_str("aarch64-apple-darwin").unwrap())
                    .unwrap()
                    .finish(settings::Flags::new(settings::builder()))
                    .unwrap(),
                "probe",
                cranelift_module::default_libcall_names(),
            )
            .unwrap(),
        );
        let decl = nir::ForeignDecl {
            symbol: "f".into(),
            name: "f".into(),
            params: vec![nir::CAbi::Ptr, nir::CAbi::F32, nir::CAbi::F32, nir::CAbi::Ptr],
            result: nir::CAbi::Bool,
            alias: None,
            variadic: true,
        };
        let (_, padding) = c_call_signature(&module, &decl, &[INT, DOUBLE]).unwrap();
        let mut expected = vec![I64; 6];
        expected.extend(vec![types::F64; 6]);
        assert_eq!(padding, expected);
    }

    /// AAPCS64 (Linux AArch64) passes trailing arguments as named ones: the
    /// int in w1, the double in d0, the long in x2 -- nothing on the stack --
    /// never Apple's stack-only rule.
    #[test]
    fn ffi_linux_aarch64_variadic_arguments_in_registers() {
        let code = variadic_disassembly("aarch64-unknown-linux-gnu", &[INT, DOUBLE, LONG]);
        assert!(!code.lines().any(|l| l.trim_start().starts_with("str") && l.contains("[sp")), "a stack argument:\n{code}");
        assert!(code.lines().any(|l| l.contains("w1") && l.contains("#5")), "the int is not w1:\n{code}");
        assert!(code.contains("fmov d0, #2.5"), "the double is not d0:\n{code}");
        assert!(code.lines().any(|l| l.contains("x2") && l.contains("#7")), "the long is not x2:\n{code}");
        // Past the registers: nine trailing ints after the fixed one take
        // x1-x7, then 8-byte stack slots at sp+0 and +8.
        let code = variadic_disassembly("aarch64-unknown-linux-gnu", &[INT; 9]);
        for store in ["[sp]", "[sp, #8]"] {
            assert!(code.lines().any(|l| l.trim_start().starts_with("str") && l.contains(store)), "no store to {store}:\n{code}");
        }
    }
}

/// The variadic call lowering of x86-64 System V (VARIADICS-VERTICAL-
/// SLICE-1.md), on an x86-64 host, whose Cranelift has the x64 backend.
#[cfg(all(test, target_arch = "x86_64"))]
mod x86_64_variadic_tests {
    use super::*;
    use cranelift_codegen::settings::{self, Configurable};
    use std::str::FromStr;

    fn module() -> cranelift_object::ObjectModule {
        let mut flags = settings::builder();
        flags.set("is_pic", "true").unwrap();
        let isa = cranelift_codegen::isa::lookup(target_lexicon::Triple::from_str("x86_64-unknown-linux-gnu").unwrap())
            .unwrap()
            .finish(settings::Flags::new(flags))
            .unwrap();
        cranelift_object::ObjectModule::new(
            cranelift_object::ObjectBuilder::new(isa, "probe", cranelift_module::default_libcall_names()).unwrap(),
        )
    }

    /// A trailing argument is one more parameter of its promoted type (an
    /// `int` an I32, a double an F64), no padding; %al is the call's
    /// F64 parameter count, fixed ones included, at most eight.
    #[test]
    fn ffi_sysv_variadic_signature_and_vector_count() {
        let module = module();
        let decl = nir::ForeignDecl {
            symbol: "f".into(),
            name: "f".into(),
            params: vec![nir::CAbi::F64, nir::CAbi::I32],
            result: nir::CAbi::I32,
            alias: None,
            variadic: true,
        };
        let int = nir::VarArg { class: nir::CAbi::U8, promoted: nir::CAbi::I32 };
        let double = nir::VarArg { class: nir::CAbi::F64, promoted: nir::CAbi::F64 };
        let (sig, padding) = c_call_signature(&module, &decl, &[int, double]).unwrap();
        assert!(padding.is_empty());
        let types: Vec<_> = sig.params.iter().map(|p| p.value_type).collect();
        assert_eq!(types, vec![types::F64, types::I32, types::I32, types::F64]);
        assert_eq!(vector_registers(&sig), 2);
        let (sig, _) = c_call_signature(&module, &decl, &[double; 10]).unwrap();
        assert_eq!(vector_registers(&sig), 8);
        let (sig, _) = c_call_signature(&module, &decl, &[]).unwrap();
        assert_eq!(vector_registers(&sig), 1);
        assert!(needs_va_stub(&module));
    }

    /// A fixed C float is passed in a vector register too, and %al counts
    /// it (C-FLOAT-FFI-MILESTONE-1.md): two fixed floats and a trailing
    /// double are three.
    #[test]
    fn ffi_sysv_variadic_vector_count_includes_fixed_floats() {
        let module = module();
        let decl = nir::ForeignDecl {
            symbol: "f".into(),
            name: "f".into(),
            params: vec![nir::CAbi::Ptr, nir::CAbi::F32, nir::CAbi::F32, nir::CAbi::Ptr],
            result: nir::CAbi::Bool,
            alias: None,
            variadic: true,
        };
        let double = nir::VarArg { class: nir::CAbi::F64, promoted: nir::CAbi::F64 };
        let (sig, _) = c_call_signature(&module, &decl, &[]).unwrap();
        assert_eq!(vector_registers(&sig), 2);
        let (sig, padding) = c_call_signature(&module, &decl, &[double]).unwrap();
        assert!(padding.is_empty());
        assert_eq!(vector_registers(&sig), 3);
    }

    /// The %al stub is exactly `mov $AL, %eax` and a PLT-relative jump to
    /// the C function in a PIC object: the bytes of the object's stub
    /// symbol.
    #[test]
    fn ffi_sysv_variadic_stub_bytes() {
        let mut module = module();
        let import = module.declare_function("callee", Linkage::Import, &module.make_signature()).unwrap();
        let stub = module.declare_function("stub", Linkage::Export, &module.make_signature()).unwrap();
        va_stub(&mut module, stub, import, 3).unwrap();
        let bytes = module.finish().emit().unwrap();
        let needle = [0xb8, 3, 0, 0, 0, 0xe9];
        assert!(bytes.windows(needle.len()).any(|w| w == needle), "no `mov $3, %eax; jmp` in the object");
    }

    /// Each form's relocation patches its jump's operand, and nothing else:
    /// the PIC form's rel32 right after `e9` (to the instruction's end, so
    /// the addend is -4: the field is the code's last four bytes), the JIT
    /// form's imm64 right after `49 bb` (movabs r11), before `41 ff e3` (jmp
    /// *%r11), absolute.
    #[test]
    fn ffi_sysv_variadic_stub_relocations() {
        let (pic, offset, kind, addend) = va_stub_code(5, true);
        assert_eq!(&pic[..5], &[0xb8, 5, 0, 0, 0]);
        assert_eq!(pic[offset as usize - 1], 0xe9);
        assert_eq!(offset as usize + 4, pic.len());
        assert_eq!((kind, addend), (cranelift_codegen::binemit::Reloc::X86CallPLTRel4, -4));
        let (jit, offset, kind, addend) = va_stub_code(5, false);
        assert_eq!(&jit[..5], &[0xb8, 5, 0, 0, 0]);
        assert_eq!(&jit[offset as usize - 2..offset as usize], &[0x49, 0xbb]);
        assert_eq!(&jit[offset as usize + 8..], &[0x41, 0xff, 0xe3]);
        assert_eq!((kind, addend), (cranelift_codegen::binemit::Reloc::Abs8, 0));
    }
}

/// C float and C double in the platform C conventions of the x86-64 targets
/// (C-FLOAT-FFI-MILESTONE-1.md), read from Cranelift's disassembly of a
/// call (call_disassembly): SysV's eight XMM registers taken by floats and
/// doubles alike before the stack, and Win64's four positional registers
/// shared by every kind. Windows has no runner; this is the lowering its
/// machine code would have.
#[cfg(all(test, target_arch = "x86_64"))]
mod x86_64_float_tests {
    use super::*;

    /// The stack stores of CODE: each `OP %REG, N(%rsp)` line's (OP, N).
    fn stack_stores(code: &str) -> Vec<(String, i64)> {
        code.lines()
            .filter_map(|l| {
                let l = l.trim();
                let (op, rest) = l.split_once(' ')?;
                let at = rest.rfind(", ")?;
                let target = rest[at + 2..].trim();
                let n = target.strip_suffix("(%rsp)")?;
                // (`(%rsp)` is offset 0; an offset may be hexadecimal.)
                let offset = if n.is_empty() {
                    0
                } else if let Some(hex) = n.strip_prefix("0x") {
                    i64::from_str_radix(hex, 16).ok()?
                } else {
                    n.parse().ok()?
                };
                Some((op.to_string(), offset))
            })
            .collect()
    }

    /// SysV: a float or a double takes the next of xmm0-xmm7 whatever the
    /// integers between them, and the ninth and tenth floating arguments go
    /// to the stack, each in its own 8-byte slot -- a float stored with
    /// movss (4 bytes), never widened to a double.
    #[test]
    fn c_float_sysv_xmm_exhaustion() {
        use nir::CAbi::*;
        let params = [F32, I32, F64, F32, I64, F32, F64, F32, F32, F64, F32, F32];
        let code = call_disassembly("x86_64-unknown-linux-gnu", &params, F32, c_signature);
        let stores = stack_stores(&code);
        assert!(stores.contains(&("movss".to_string(), 0)), "the ninth floating argument (a float) at 0(%rsp) by movss in\n{code}");
        assert!(stores.contains(&("movss".to_string(), 8)), "the tenth (a float) at 8(%rsp) by movss in\n{code}");
        assert!(!stores.iter().any(|(op, _)| op == "movsd"), "no float stored as a double in\n{code}");
        for register in ["%xmm0", "%xmm1", "%xmm2", "%xmm3", "%xmm4", "%xmm5", "%xmm6", "%xmm7"] {
            assert!(code.contains(register), "{register} unused in\n{code}");
        }
        // The float result comes back in xmm0 and is widened exactly.
        assert!(code.contains("cvtss2sd"), "no widening of the float result in\n{code}");
    }

    /// Win64: four positional argument registers shared by every kind -- a
    /// float in the first position is xmm0, an int in the second edx/rdx, a
    /// double in the third xmm2, a long long in the fourth r9 -- and the
    /// fifth argument, a float, on the stack past the 32-byte shadow space,
    /// stored as 4 bytes.
    #[test]
    fn c_float_win64_positions() {
        use nir::CAbi::*;
        let params = [F32, I32, F64, I64, F32, F64];
        let code = call_disassembly("x86_64-pc-windows-msvc", &params, F64, c_signature);
        let stores = stack_stores(&code);
        assert!(stores.contains(&("movss".to_string(), 32)), "the fifth argument (a float) at 32(%rsp) by movss in\n{code}");
        assert!(stores.contains(&("movsd".to_string(), 40)), "the sixth (a double) at 40(%rsp) by movsd in\n{code}");
        // The first four by position: xmm0, rdx (the int, extended), xmm2,
        // r9.
        for register in ["%xmm0", ", %rdx", "%xmm2", ", %r9"] {
            assert!(code.contains(register), "{register} unused in\n{code}");
        }
    }
}

/// C float and C double in the AArch64 C conventions (C-FLOAT-FFI-MILESTONE-1.md),
/// read from Cranelift's disassembly of a call (call_disassembly): AAPCS64
/// and Apple both give floating arguments v0-v7, counted apart from the
/// integers; past them Linux gives each stack argument an 8-byte slot and
/// Apple packs a float into 4 bytes. Runs on an AArch64 host.
#[cfg(all(test, target_arch = "aarch64"))]
mod aarch64_float_tests {
    use super::*;

    /// The (instruction, stack offset) of each `str`-family store to sp in
    /// CODE: `str s1, [sp]` is ("str s", 0), `str d2, [sp, #8]` ("str d", 8).
    fn stack_stores(code: &str) -> Vec<(String, i64)> {
        code.lines()
            .filter_map(|l| {
                let l = l.trim();
                if !l.starts_with("str") {
                    return None;
                }
                let at = l.find("[sp")?;
                let inside = l[at + 3..].split(']').next()?;
                let offset = match inside.trim_start_matches(',').trim().strip_prefix('#') {
                    Some(n) => n.parse().ok()?,
                    None => 0,
                };
                let (op, rest) = l.split_once(' ')?;
                Some((format!("{op} {}", &rest[..1]), offset))
            })
            .collect()
    }

    /// Ten floating arguments among integers: the first eight in v0-v7
    /// (s for a float, d for a double), the integers still x0.. in order,
    /// the ninth and tenth -- floats -- on the stack, stored as 4 bytes.
    const MIXED: [nir::CAbi; 13] = {
        use nir::CAbi::*;
        [F32, I32, F64, F32, I64, F32, F64, F32, F32, F64, I8, F32, F32]
    };

    #[test]
    fn c_float_aapcs64_stack_slots() {
        let code = call_disassembly("aarch64-unknown-linux-gnu", &MIXED, nir::CAbi::F32, c_signature);
        let stores = stack_stores(&code);
        assert!(stores.contains(&("str s".to_string(), 0)), "the ninth floating argument (a float) at [sp] in\n{code}");
        assert!(stores.contains(&("str s".to_string(), 8)), "the tenth at [sp, #8] (an 8-byte slot) in\n{code}");
        assert!(code.contains("fcvt d"), "no widening of the float result in\n{code}");
    }

    #[test]
    fn c_float_apple_floats_packed() {
        let code = call_disassembly("aarch64-apple-darwin", &MIXED, nir::CAbi::F32, c_signature);
        let stores = stack_stores(&code);
        assert!(stores.contains(&("str s".to_string(), 0)), "the ninth floating argument (a float) at [sp] in\n{code}");
        assert!(stores.contains(&("str s".to_string(), 4)), "the tenth packed at [sp, #4] in\n{code}");
    }
}

