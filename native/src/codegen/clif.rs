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
//! to its own error exit, which pops its shadow frame and returns 0.
//!
//! Frame layout: the prologue reserves one shadow-stack slot per register
//! (at least one, so native depth is bounded by the shadow stack), clears
//! it, and every definition of a register is stored to its slot: the GC's
//! precise roots (runtime/heap.rs). Register values live in Cranelift
//! variables, so reads never touch memory.
//!
//! Self tail calls (NIR `tail`) rebind the parameter variables and jump back
//! to the body block after the prologue: a CFG back edge, no call.

use super::roots::{self, RootPlan};
use super::{BackendError, Const, ConstPool, Site};
use crate::nir::{self, Inst, OpCode, Reg};
use crate::runtime::ops::helpers;
use crate::runtime::value::*;
use crate::runtime::vm::{VM_ALLOC_SITE_OFFSET, VM_CONSTS_OFFSET, VM_SS_LIMIT_OFFSET, VM_SS_TOP_OFFSET};
use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{
    types, AbiParam, BlockArg, InstBuilder, MemFlagsData, Signature, StackSlotData, StackSlotKind,
    UserFuncName,
};
use cranelift_codegen::ir;
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext, Variable};
use cranelift_module::{FuncId as ModuleFuncId, Linkage, Module};
use std::collections::HashMap;

const I64: ir::Type = types::I64;

pub struct Symbols {
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

fn module_error(e: cranelift_module::ModuleError) -> BackendError {
    BackendError::Codegen(format!("{e:?}"))
}

/// Declares the runtime helpers and every function of PROGRAM.
pub fn declare<M: Module>(module: &mut M, program: &nir::Program, export: bool) -> Result<Symbols, BackendError> {
    let direct_helpers = export && module.isa().name() == "x64";
    let mut symbols =
        Symbols { direct: vec![], entry: vec![], helpers: HashMap::new(), names: HashMap::new(), direct_helpers };
    for (name, params, _) in helpers() {
        let id = module.declare_function(name, Linkage::Import, &signature(module, params)).map_err(module_error)?;
        symbols.helpers.insert(name, id);
        symbols.names.insert(id.as_u32(), name.to_string());
    }
    let linkage = if export { Linkage::Export } else { Linkage::Local };
    for f in &program.functions {
        let params = 1 + f.env as usize + f.params as usize;
        let name = format!("botlish_fn_{}", f.id);
        let id = module
            .declare_function(&name, linkage, &signature_n(module, params, f.results as usize))
            .map_err(module_error)?;
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

/// Defines function F and its generic entry. Returns F's CLIF if LISTING, and
/// the size in bytes of the machine code of both.
pub fn define<M: Module>(
    module: &mut M,
    symbols: &Symbols,
    f: &nir::Function,
    pool: &mut ConstPool,
    sites: &mut Vec<Site>,
    instrument_sites: bool,
    listing: bool,
) -> Result<(Option<String>, u32), BackendError> {
    let mut text = String::new();
    let mut ctx = module.make_context();
    let mut fctx = FunctionBuilderContext::new();

    ctx.func.signature = signature_n(module, 1 + f.env as usize + f.params as usize, f.results as usize);
    ctx.func.name = UserFuncName::user(0, symbols.direct[f.id as usize].as_u32());
    let config = module.isa().frontend_config();
    {
        let b = FunctionBuilder::new(&mut ctx.func, &mut fctx);
        let mut t = Translator::new(b, module, symbols, f, pool, sites, instrument_sites);
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
    let mut size = ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
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
        size += ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
        module.clear_context(&mut ctx);
        return Ok((listing.then_some(text), size));
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
            args.push(b.ins().load(I64, MemFlagsData::trusted(), params[2], (i * 8) as i32));
        }
        let callee = module.declare_func_in_func(symbols.direct[f.id as usize], b.func);
        let call = b.ins().call(callee, &args);
        let result = b.inst_results(call)[0];
        b.ins().return_(&[result]);
        b.seal_all_blocks();
        b.finalize(config);
    }
    module.define_function(symbols.entry[f.id as usize], &mut ctx).map_err(module_error)?;
    size += ctx.compiled_code().map_or(0, |code| code.code_info().total_size);
    module.clear_context(&mut ctx);
    Ok((listing.then_some(text), size))
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
    body: ir::Block,
    error_exit: ir::Block,
    refs: HashMap<ModuleFuncId, ir::FuncRef>,
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
    /// Whether `op listget` inlines its check-and-load fast path (`list_get`
    /// below) instead of always calling `rt_list_get`. On by default;
    /// BOTLISH_NATIVE_LISTGET_FAST_OPT=0 disables it, for differential
    /// testing and benchmark comparison (mirrors heap.rs's
    /// BOTLISH_NATIVE_GC_STRESS/MIN: a plain env var read once, since this
    /// is a pure Cranelift-codegen choice, not something native/lower.tcl's
    /// NIR emission needs to know about).
    listget_fast: bool,
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
    ) -> Self {
        let vars = (0..f.regs).map(|_| b.declare_var(I64)).collect();
        let closure = f.env.then(|| b.declare_var(I64));
        let body = b.create_block();
        let error_exit = b.create_block();
        let placeholder = ir::Value::from_u32(0);
        let plan = roots::plan(f);
        let listget_fast = std::env::var("BOTLISH_NATIVE_LISTGET_FAST_OPT").ok().as_deref() != Some("0");
        Translator {
            b,
            module,
            symbols,
            f,
            pool,
            sites,
            instrument_sites,
            current_index: 0,
            vars,
            closure,
            labels: HashMap::new(),
            vm: placeholder,
            base: placeholder,
            body,
            error_exit,
            refs: HashMap::new(),
            terminated: false,
            plan,
            result_buf: None,
            listget_fast,
        }
    }

    fn function(&mut self) -> Result<(), BackendError> {
        let f = self.f;
        let entry = self.b.create_block();
        self.b.append_block_params_for_function_params(entry);
        self.b.switch_to_block(entry);
        let params = self.b.block_params(entry).to_vec();
        self.vm = params[0];

        // Prologue: reserve and clear this frame's shadow-stack slots.
        // `self.plan.num_slots` (codegen::roots), not `f.regs`: only
        // registers that are both managed-capable and live across a GC
        // safepoint get a slot at all, and two such registers share one
        // when their safepoint-live ranges never overlap (see roots.rs's
        // module doc). At least one slot always, regardless of rooting
        // needs, so the shadow stack still bounds native recursion depth
        // (see RootPlan::num_slots's doc).
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
        let zero = self.b.ins().iconst(I64, 0);
        for slot in 0..slots {
            self.b.ins().store(MemFlagsData::trusted(), zero, self.base, (slot * 8) as i32);
        }
        let mut next = 1;
        if let Some(closure) = self.closure {
            self.b.def_var(closure, params[1]);
            next = 2;
        }
        for i in 0..f.params {
            let v = params[next + i as usize];
            if f.raw_regs[i as usize] {
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
        self.b.ins().store(MemFlagsData::trusted(), self.base, self.vm, VM_SS_TOP_OFFSET);
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

    fn call_helper(&mut self, name: &str, args: &[ir::Value]) -> ir::Value {
        let id = self.symbols.helpers[name];
        let r = self.helper_ref(id);
        let call = self.b.ins().call(r, args);
        self.b.inst_results(call)[0]
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
        let n = if self.f.results > 2 { 1 } else { self.f.results.max(1) as usize };
        let zeros = vec![zero; n];
        self.b.ins().return_(&zeros);
    }

    /// Branches to the error exit if V is 0; continues in a new block.
    fn check(&mut self, v: ir::Value) {
        let ok = self.b.create_block();
        self.b.ins().brif(v, ok, &[], self.error_exit, &[]);
        self.b.switch_to_block(ok);
    }

    fn fail_with(&mut self, name: &str, args: &[ir::Value]) {
        self.call_helper(name, args);
        self.b.ins().jump(self.error_exit, &[]);
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
    fn call_multi(&mut self, dsts: &[Reg], func: nir::FuncId, values: &mut Vec<ir::Value>) {
        let buf = (dsts.len() > 2).then(|| self.result_slot(dsts.len() - 1));
        if let Some(ptr) = buf {
            values.push(ptr);
        }
        let r = self.func_ref(self.symbols.direct[func as usize]);
        let call = self.b.ins().call(r, values);
        let results = self.b.inst_results(call).to_vec();
        self.check(results[0]);
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
            Kind::Bool | Kind::Unit => unreachable!(),
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
            Inst::Move { dst, src } => {
                let v = self.get(*src);
                self.def(*dst, v);
            }
            Inst::Cell { dst } => {
                let v = self.call_allocating("rt_cell_new", &[self.vm], "cell", KIND_CELL);
                self.def(*dst, v);
            }
            Inst::CellSet { cell, value } => {
                let c = self.get(*cell);
                let v = self.get(*value);
                self.b.ins().store(MemFlagsData::trusted(), v, c, CELL_VALUE_OFFSET);
            }
            Inst::CellGet { dst, cell } => {
                let c = self.get(*cell);
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), c, CELL_VALUE_OFFSET);
                self.def(*dst, v);
            }
            Inst::CellCheck { dst, cell, name } => {
                let c = self.get(*cell);
                let v = self.b.ins().load(I64, MemFlagsData::trusted(), c, CELL_VALUE_OFFSET);
                let unbound = self.b.ins().icmp_imm_s(IntCC::Equal, v, UNBOUND as i64);
                let fail = self.b.create_block();
                let ok = self.b.create_block();
                self.b.ins().brif(unbound, fail, &[], ok, &[]);
                self.b.switch_to_block(fail);
                let name = self.string(name);
                self.fail_with("rt_unbound", &[self.vm, name]);
                self.b.switch_to_block(ok);
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
            Inst::Op { dst, op, args } => {
                let v = self.op(*op, args);
                if op.raw_result() {
                    self.def_raw(*dst, v);
                } else {
                    self.def(*dst, v);
                }
            }
            Inst::Call { dst, func, args } => {
                let mut values = vec![self.vm];
                values.extend(args.iter().map(|r| self.get(*r)));
                let r = self.func_ref(self.symbols.direct[*func as usize]);
                let call = self.b.ins().call(r, &values);
                let v = self.b.inst_results(call)[0];
                self.check(v);
                self.def(*dst, v);
            }
            Inst::CallEnv { dst, func, closure, args } => {
                let mut values = vec![self.vm, self.get(*closure)];
                values.extend(args.iter().map(|r| self.get(*r)));
                let r = self.func_ref(self.symbols.direct[*func as usize]);
                let call = self.b.ins().call(r, &values);
                let v = self.b.inst_results(call)[0];
                self.check(v);
                self.def(*dst, v);
            }
            Inst::CallMulti { dsts, func, args } => {
                let mut values = vec![self.vm];
                values.extend(args.iter().map(|r| self.get(*r)));
                self.call_multi(dsts, *func, &mut values);
            }
            Inst::CallEnvMulti { dsts, func, closure, args } => {
                let mut values = vec![self.vm, self.get(*closure)];
                values.extend(args.iter().map(|r| self.get(*r)));
                self.call_multi(dsts, *func, &mut values);
            }
            Inst::CallValue { dst, callee, args } => {
                let f = self.get(*callee);
                let (n, ptr) = self.array(args);
                let v = self.call_helper("rt_call_value", &[self.vm, f, n, ptr]);
                self.check(v);
                self.def(*dst, v);
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
                    if self.f.raw_regs[i] {
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
                self.b.ins().store(MemFlagsData::trusted(), self.base, self.vm, VM_SS_TOP_OFFSET);
                self.b.ins().return_(&[v]);
                self.terminated = true;
            }
            Inst::RetMulti(regs) => {
                let values: Vec<_> = regs.iter().map(|r| self.get(*r)).collect();
                self.b.ins().store(MemFlagsData::trusted(), self.base, self.vm, VM_SS_TOP_OFFSET);
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
        }
        Ok(())
    }

    /// A known operation on operands of the kinds it requires.
    fn op(&mut self, op: OpCode, args: &[Reg]) -> ir::Value {
        use OpCode::*;
        let a: Vec<ir::Value> = args.iter().map(|r| self.get(*r)).collect();
        match op {
            IAdd | ISub | IMul => self.int_arith(op, a[0], a[1]),
            ILt | ILe | IGt | IGe | IEq => self.int_compare(op, a[0], a[1]),
            ListGet if self.listget_fast => self.list_get(a[0], a[1]),
            VEq => {
                // Two small Ints compare as words; everything else structurally.
                let (fast, slow, done, result) = self.both_small_split(a[0], a[1]);
                self.b.switch_to_block(fast);
                let eq = self.b.ins().icmp(IntCC::Equal, a[0], a[1]);
                let r = self.bool_of(eq);
                self.b.ins().jump(done, &[BlockArg::Value(r)]);
                self.b.switch_to_block(slow);
                let r = self.call_helper("rt_value_eq", &[self.vm, a[0], a[1]]);
                self.check(r);
                self.b.ins().jump(done, &[BlockArg::Value(r)]);
                self.b.switch_to_block(done);
                result
            }
            IsInt | IsStr | IsList => {
                let kind = match op {
                    IsInt => Kind::Int,
                    IsStr => Kind::Str,
                    _ => Kind::List,
                };
                let flag = self.is_kind(a[0], kind);
                self.bool_of(flag)
            }
            // Representation transitions and raw (untagged) integer
            // arithmetic/comparison: lower.tcl emits these only where range
            // analysis proved they are safe (see the "Representation"
            // section of native/lower.tcl), so no check is needed here.
            RBox => {
                // a[0] is raw and proven within the small-Int range.
                let shifted = self.b.ins().ishl_imm_s(a[0], 1);
                self.b.ins().bor_imm_s(shifted, 1)
            }
            RUnbox => {
                // a[0] is a tagged Value proven to be a small Int.
                self.b.ins().sshr_imm_s(a[0], 1)
            }
            RIAdd => self.b.ins().iadd(a[0], a[1]),
            RISub => self.b.ins().isub(a[0], a[1]),
            RIMul => self.b.ins().imul(a[0], a[1]),
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
                        IMod => ("rt_int_mod", None, true, None),
                        Hash => ("rt_hash", None, true, None),
                        RegionCheck => ("rt_str_region_check", None, true, None),
                        RegionEq => ("rt_str_region_eq", None, false, None),
                        StrEq => ("rt_str_eq", None, false, None),
                        StrLen => ("rt_str_len", None, false, None),
                        StrByteLen => ("rt_str_byte_len", None, false, None),
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
                        // Fallible: each may construct a new String/List,
                        // which the runtime rejects past
                        // MAX_COLLECTION_LENGTH (Vm::reject_oversized_collection).
                        StrLower => ("rt_str_lower", None, true, Some(("strlower", KIND_STR))),
                        StrCat => ("rt_str_cat", None, true, Some(("strcat", KIND_STR))),
                        StrUtf8Bytes => {
                            ("rt_str_utf8_bytes", None, true, Some(("strutf8bytes", KIND_LIST)))
                        }
                        ListLen => ("rt_list_len", None, false, None),
                        ListGet => ("rt_list_get", None, true, None),
                        ListAppend => ("rt_list_append", None, true, Some(("listappend", KIND_LIST))),
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

    /// `list_get(LIST, INDEX)`'s inline fast path: LIST and INDEX already
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
        // re-derives the exact same RANGE error `list_get`'s Tcl semantics
        // (core/lists.tcl) define, never duplicated here.
        self.b.switch_to_block(slow);
        let r = self.call_helper("rt_list_get", &[self.vm, list, index]);
        self.check(r);
        self.b.ins().jump(done, &[BlockArg::Value(r)]);

        self.b.switch_to_block(done);
        result
    }
}

/// Symbol names of every module function, for CLIF listings.
pub fn legend(symbols: &Symbols) -> String {
    let mut ids: Vec<_> = symbols.names.iter().collect();
    ids.sort();
    ids.iter().map(|(id, name)| format!("; u0:{id} = {name}\n")).collect()
}
