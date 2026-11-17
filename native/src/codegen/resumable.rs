//! The resumable lowering of general coroutines
//! (WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md): a NIR-to-NIR pass
//! that makes every function that may yield a state machine over a heap
//! frame, for a runtime that switches no stacks (runtime::capabilities's
//! `resumable`: the fallback root plan natively, WebAssembly next). Fusion
//! (codegen::fusion) runs first; this pass lowers every coroutine fusion
//! left to the general mechanism, and never depends on fusion to make a
//! program run.
//!
//! # Which functions
//!
//! Fusion's `yielding()`: a function with a `coyield`, or a direct call
//! (`call`, `callenv`, `callmulti`, `callenvmulti`) of one, to a fixpoint.
//! It is exact because a function that may yield never becomes a value
//! (`UNWRAPPED-YIELD`, COROUTINES.md point 37): the only indirect entry is
//! the coroutine runtime's call of a thunk, the coroutine's boundary; a
//! capturing yielding closure is a NIR `closure` only as the environment of
//! a direct `callenv`. The pass checks what can be checked structurally
//! (`check_boundaries`: never the program, a C callback or a library
//! export), and the hidden frame parameter makes any dynamic call of a
//! lowered function an arity error (`rt_call_value`) before it runs: no Rust
//! activation can sit between a suspension and its resumer.
//!
//! # The shape of a lowered function
//!
//! The frame ABI is runtime/resumable.rs's: a hidden trailing frame
//! parameter `%fp` (UNIT: a fresh activation), and a suspension returns the
//! activation's frame as its (first) result.
//!
//! ```text
//!     %fr = move %fp                    entry (a self tail call's target too)
//!     %b = op frisframe %fp
//!     br %b DISPATCH START
//!   label START
//!     ...the body, each suspension point rewritten in place...
//!   ...protocol blocks, after the body (outside every handler span):
//!   label S_k                           suspend at point k
//!     %fr = op frensure %fr             the activation's frame, made once
//!     frsave %fr k [callee %t] tagged LIVE_k raw LIVE_k
//!     ret %fr                           (retmulti %fr unit...)
//!   label DISPATCH
//!     %p = op frpoint %fr
//!     switch %p BAD 0:0:START 1:1:D_1 ...
//!   label D_k                           resume at point k
//!     frrestore %fr tagged LIVE_k raw LIVE_k
//!     ...then continue at point k
//! ```
//!
//! * **A yield** `%d = op coyield %v` becomes `cosuspend %v; jump S_k;
//!   label Y_k; %d = op comsg`, and D_k continues at Y_k: the message, or
//!   the abandonment's failure, at the yield's own place in its handler
//!   spans -- so release pads and handlers run exactly as natively.
//! * **A yielding call** `%d = call g ARGS` becomes `label C_k; %t = call g
//!   ARGS %h; br (frisframe %t) S_k N_k; label N_k; %d = %t` (unboxed for a
//!   scalar result), `%h` the site's hand-off register (UNIT from START).
//!   D_k reloads, defines the arguments the callee ignores on a resume,
//!   takes the callee's frame into `%h` (`frcallee`) and jumps to C_k: the
//!   same call instruction, in the same handler spans, continues the callee
//!   where it stopped, and its failure reaches the handler it would
//!   natively. Once the callee returns, `%h` still holds the frame of that
//!   finished activation, which nothing else owns: the site's next call
//!   hands it down again, and the callee (its point 0) starts afresh in it
//!   -- a yielding call in a loop makes one frame, not one per iteration.
//! * **A self tail call** passes `%fr` as the new activation's frame: the
//!   finished activation's frame is reused (its point is 0 while it runs,
//!   so the entry dispatch starts the body afresh), and a loop written as
//!   yielding tail recursion -- a declared recognizer's `NAME#run` --
//!   allocates one frame, not one per iteration.
//!
//! LIVE_k is the root planner's own liveness (codegen::roots's
//! `live_at_many`) on the function before the rewrite: the registers live
//! after the suspension point, but its results -- plus a `callenv`'s
//! closure, which the re-entered callee reads its captures through.
//! Tagged registers go to tagged slots (traced), every unboxed kind to raw
//! slots (never traced). A frame's shape is the most any of its points
//! saves of each.
//!
//! # Results
//!
//! A suspension travels in a function's (first) result, so a yielding
//! function's result is a tagged Value: a raw, short or packed-ASCII result
//! (proven small or short, so boxing is exact) is boxed at its returns and
//! unboxed by its callers after their suspension check. A multi-result
//! companion carries the frame in its first result and UNIT in the others.
use crate::codegen::fusion::{max_label, rename, yielding};
use crate::codegen::roots::live_at_many;
use crate::nir::{self, FrameShape, Function, Inst, Label, OpCode, Program, Reg, RegKind};

/// What the pass did: the driver's `resumable` report and the tests' census.
#[derive(Default, Debug)]
pub struct Report {
    /// Every lowered function: its name and its frame's shape.
    pub functions: Vec<(String, FrameShape)>,
    pub yield_sites: usize,
    pub call_sites: usize,
    /// Self tail calls that reuse their activation's frame.
    pub tail_sites: usize,
    /// Yielding functions whose scalar result became a tagged one.
    pub boxed_results: usize,
    /// Yielding multi-result companions (the frame in their first result).
    pub multi_results: usize,
    /// Plan registers saved across a suspension point (the frame owns
    /// each until its resume point restores it).
    pub plans_saved: usize,
}

impl Report {
    /// One Tcl dict per lowered function, then the totals (`botlish-native
    /// resumable FILE.nir`).
    pub fn text(&self) -> String {
        let mut lines: Vec<String> = self
            .functions
            .iter()
            .map(|(name, shape)| format!("function {} tagged {} raw {}", crate::runtime::show::tcl_list(&[name.clone()]), shape.tagged, shape.raw))
            .collect();
        lines.push(format!(
            "functions {} yields {} calls {} tails {} boxed {} multi {} plans {}",
            self.functions.len(),
            self.yield_sites,
            self.call_sites,
            self.tail_sites,
            self.boxed_results,
            self.multi_results,
            self.plans_saved
        ));
        lines.join("\n")
    }
}

/// Whether PROGRAM's coroutines are lowered to resumable frames: its
/// runtime has no stack switch (runtime::capabilities). Never optional
/// there -- the runtime has no other mechanism -- and never applied where
/// coroutines switch stacks.
pub fn applies(program: &Program) -> bool {
    program.capabilities.resumable
}

fn name_of(f: &Function) -> String {
    if f.name.is_empty() { format!("#{}", f.id) } else { f.name.clone() }
}

/// A new register of F of KIND (never a plan register).
fn new_reg(f: &mut Function, kind: RegKind) -> Reg {
    let r = f.regs;
    f.regs += 1;
    f.raw_regs.push(kind == RegKind::Raw);
    f.plan_regs.push(false);
    f.short_regs.push(kind == RegKind::Short);
    f.ascii_regs.push(kind == RegKind::Ascii);
    f.i64_regs.push(kind == RegKind::I64);
    f.u64_regs.push(kind == RegKind::U64);
    f.scalar_regs.push(kind != RegKind::Tagged);
    r
}

/// A defined value of KIND that nothing reads: an argument the re-entered
/// callee ignores (it restores its own registers).
fn dummy(dst: Reg, kind: RegKind) -> Inst {
    match kind {
        RegKind::Tagged => Inst::Unit { dst },
        RegKind::Raw => Inst::RawInt { dst, digits: "0".into() },
        RegKind::Short => Inst::ShortLit { dst, value: -1 },
        RegKind::Ascii => Inst::AsciiLit { dst, value: 0 },
        RegKind::I64 | RegKind::U64 => Inst::CWord { dst, digits: "0".into() },
    }
}

/// The ops that box a scalar result of KIND for the tagged ABI, and unbox it
/// again at the call site.
fn boxing(kind: RegKind) -> Option<(OpCode, OpCode)> {
    match kind {
        RegKind::Raw => Some((OpCode::RBox, OpCode::RUnbox)),
        RegKind::Short => Some((OpCode::ShortToStr, OpCode::StrToShort)),
        RegKind::Ascii => Some((OpCode::AsciiToStr, OpCode::StrToAscii)),
        _ => None,
    }
}

/// The structural facts the lowering relies on (this module's doc), checked
/// on PROGRAM before anything changes. Err: a compiler bug upstream, never a
/// program the language allows.
///
/// A yielding function's generic entry is reached only by the coroutine
/// segment (a thunk, called with its frame) -- never by a C callback or a
/// library export, which run outside any coroutine (checked here), and
/// never by a dynamic call: `UNWRAPPED-YIELD` keeps a yielding function
/// from becoming a function value in the language, and NIR's `fnvalue` or
/// `closure` of one is either a thunk or the environment a direct `callenv`
/// passes (a capturing yielding closure). Should a dynamic call reach one
/// anyway, its hidden frame parameter makes the closure's arity one more
/// than any call could pass: `rt_call_value` refuses it (ARITY) before any
/// code runs, so no Rust activation can ever sit between a suspension and
/// its resumer.
fn check_boundaries(program: &Program, y: &[bool]) -> Result<(), String> {
    if y.first() == Some(&true) {
        return Err("the program function may yield: no coroutine runs it".into());
    }
    for c in &program.callbacks {
        if y.get(c.func as usize) == Some(&true) {
            return Err(format!("C callback {} may yield", name_of(&program.functions[c.func as usize])));
        }
    }
    for e in &program.exports {
        if y.get(e.func as usize) == Some(&true) {
            return Err(format!("exported C function {} may yield", e.symbol));
        }
    }
    for (i, f) in program.functions.iter().enumerate() {
        if !y[i] {
            continue;
        }
        if f.frame.is_some() {
            return Err(format!("{} is already lowered", name_of(f)));
        }
        if f.plan_result {
            return Err(format!("{} may yield and returns a plan", name_of(f)));
        }
        // STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md: a unit that may
        // suspend gets no region (hir/storageplan.tcl), so no scratch mark
        // is ever live across a suspension.
        if let Some(inst) = f.body.iter().find(|i| {
            matches!(
                i,
                Inst::Op { op: OpCode::ScratchTake | OpCode::ScratchMark | OpCode::ScratchReset | OpCode::ScratchExit | OpCode::ScratchReq | OpCode::ScratchDest, .. }
            )
        }) {
            return Err(format!("{} may yield and holds scratch storage ({inst:?})", name_of(f)));
        }
        let mut depth = 0i64;
        for inst in &f.body {
            match inst {
                Inst::PushErrorExit(_) => depth += 1,
                Inst::PopErrorExit => depth -= 1,
                _ => {}
            }
        }
        if depth != 0 {
            return Err(format!("{}: unbalanced error-exit spans", name_of(f)));
        }
    }
    Ok(())
}

/// F with a hidden frame parameter appended: register `params` (the old
/// count) becomes it, every other register at or above it moves up by one.
fn add_frame_param(f: &Function) -> Function {
    let p = f.params;
    let map = |r: Reg| if r >= p { r + 1 } else { r };
    let mut g = f.clone();
    g.body = f.body.iter().map(|inst| rename(inst, &map, &|l| l)).collect();
    for flags in [&mut g.raw_regs, &mut g.plan_regs, &mut g.short_regs, &mut g.ascii_regs, &mut g.i64_regs, &mut g.u64_regs, &mut g.scalar_regs] {
        flags.insert(p as usize, false);
    }
    for flags in [&mut g.raw_params, &mut g.short_params, &mut g.ascii_params] {
        flags.push(false);
    }
    g.params += 1;
    g.regs += 1;
    g.pnames = if f.pnames.is_empty() { "frame".to_string() } else { format!("{} frame", f.pnames) };
    g
}

/// One suspension point of a function, by its index in the (renumbered)
/// body.
enum Site {
    Yield { dst: Reg, value: Reg },
    /// A yielding call; `unbox[i]`: the op that unboxes result i of a callee
    /// whose scalar result became tagged.
    Call { unbox: Option<OpCode> },
}

/// Lowers every yielding function of PROGRAM (this module's doc), then
/// validates the program and settles its call effects again.
pub fn lower(program: &mut Program) -> Result<Report, String> {
    let y = yielding(program);
    check_boundaries(program, &y)?;
    let mut report = Report::default();
    // Results: a yielding function's scalar result becomes a tagged one,
    // boxed at its returns; its callers (yielding functions all) unbox.
    let mut unboxing: Vec<Option<OpCode>> = vec![None; program.functions.len()];
    for (i, f) in program.functions.iter().enumerate() {
        if y[i] && f.results == 1 {
            if let Some((_, unbox)) = boxing(f.result_kind()) {
                unboxing[i] = Some(unbox);
            }
        }
    }
    for i in 0..program.functions.len() {
        if !y[i] {
            continue;
        }
        let lowered = lower_function(&program.functions[i], &y, &unboxing, &mut report)?;
        program.functions[i] = lowered;
    }
    nir::validate(program).map_err(|e| format!("the resumable lowering's NIR does not validate: {e}"))?;
    nir::resummarize(program);
    Ok(report)
}

fn lower_function(original: &Function, y: &[bool], unboxing: &[Option<OpCode>], report: &mut Report) -> Result<Function, String> {
    // The scalar result, if any, becomes tagged.
    let boxed = if original.results == 1 { boxing(original.result_kind()) } else { None };
    let mut f = add_frame_param(original);
    let fp = original.params;
    if boxed.is_some() {
        f.raw_result = false;
        f.short_result = false;
        f.ascii_result = false;
        report.boxed_results += 1;
    }
    // Each yielding call site's hand-off register (the frame its call passes
    // down, see below), made before liveness is computed: defined (UNIT) at
    // the body's start and read by its call as the callee's hidden frame
    // argument, so the root planner's liveness saves it across every
    // suspension point after which its call can still run.
    let mut handoffs: Vec<Reg> = Vec::new();
    for i in 0..f.body.len() {
        let is_site = matches!(&f.body[i],
            Inst::Call { func, .. } | Inst::CallEnv { func, .. } | Inst::CallMulti { func, .. } | Inst::CallEnvMulti { func, .. }
                if y[*func as usize]);
        if !is_site {
            continue;
        }
        let h = new_reg(&mut f, RegKind::Tagged);
        handoffs.push(h);
        match &mut f.body[i] {
            Inst::Call { args, .. } | Inst::CallEnv { args, .. } | Inst::CallMulti { args, .. } | Inst::CallEnvMulti { args, .. } => {
                args.push(h)
            }
            _ => unreachable!("a call site"),
        }
    }
    for h in handoffs.iter().rev() {
        f.body.insert(0, Inst::Unit { dst: *h });
        f.origins.insert(0, None);
    }
    // The suspension points, and what each saves: the root planner's own
    // liveness, on the body before the protocol is inserted.
    let mut sites: Vec<(usize, Site)> = Vec::new();
    for (j, inst) in f.body.iter().enumerate() {
        match inst {
            Inst::Op { dst, op: OpCode::CoYield, args } => sites.push((j, Site::Yield { dst: *dst, value: args[0] })),
            Inst::Call { func, .. } | Inst::CallEnv { func, .. } | Inst::CallMulti { func, .. } | Inst::CallEnvMulti { func, .. }
                if y[*func as usize] =>
            {
                sites.push((j, Site::Call { unbox: unboxing[*func as usize] }))
            }
            _ => {}
        }
    }
    let indices: Vec<usize> = sites.iter().map(|(j, _)| *j).collect();
    let live = live_at_many(&f, &indices);
    let mut saved: Vec<(Vec<Reg>, Vec<Reg>)> = Vec::new();
    for ((j, _), (_, out)) in sites.iter().zip(&live) {
        let inst = &f.body[*j];
        // A call's own hand-off register is redefined by its resume point
        // (frcallee) before the call reads it: never saved there.
        let (mut dsts, closure): (Vec<Reg>, Option<Reg>) = match inst {
            Inst::Op { dst, .. } | Inst::Call { dst, .. } => (vec![*dst], None),
            Inst::CallEnv { dst, closure, .. } => (vec![*dst], Some(*closure)),
            Inst::CallMulti { dsts, .. } => (dsts.clone(), None),
            Inst::CallEnvMulti { dsts, closure, .. } => (dsts.clone(), Some(*closure)),
            _ => unreachable!("a suspension point"),
        };
        if let Inst::Call { args, .. } | Inst::CallEnv { args, .. } | Inst::CallMulti { args, .. } | Inst::CallEnvMulti { args, .. } = inst {
            dsts.push(*args.last().expect("the hand-off argument"));
        }
        let mut tagged = Vec::new();
        let mut raw = Vec::new();
        for r in 0..out.len() as Reg {
            // A `callenv`'s closure is always kept: the re-entered callee
            // reads its captures through it.
            let keep = (out[r as usize] && !dsts.contains(&r)) || closure == Some(r);
            if !keep {
                continue;
            }
            if f.kind_of(r) == RegKind::Tagged { tagged.push(r) } else { raw.push(r) }
        }
        saved.push((tagged, raw));
    }
    report.plans_saved += saved.iter().flat_map(|s| s.0.iter()).filter(|r| f.plan_regs[**r as usize]).count();
    if f.results > 1 {
        report.multi_results += 1;
    }
    let shape = FrameShape {
        tagged: saved.iter().map(|s| s.0.len() as u32).max().unwrap_or(0),
        raw: saved.iter().map(|s| s.1.len() as u32).max().unwrap_or(0),
    };
    // Labels above every label the function has.
    let mut next_label: Label = max_label(&f).map_or(0, |l| l + 1);
    let mut label = || {
        next_label += 1;
        next_label - 1
    };
    let fr = new_reg(&mut f, RegKind::Tagged);
    let is_frame = new_reg(&mut f, RegKind::Tagged);
    let l_start = label();
    let l_dispatch = label();
    let l_bad = label();
    let results = f.results;

    let old_body = std::mem::take(&mut f.body);
    let old_origins = std::mem::take(&mut f.origins);
    let mut body: Vec<Inst> = Vec::new();
    let mut origins: Vec<Option<u32>> = Vec::new();
    // The protocol blocks, appended after the body: (suspend, dispatch).
    let mut suspends: Vec<(Inst, Option<u32>)> = Vec::new();
    let mut dispatches: Vec<(Inst, Option<u32>)> = Vec::new();
    let mut dispatch_labels: Vec<Label> = Vec::new();

    body.push(Inst::Move { dst: fr, src: fp });
    origins.push(None);
    body.push(Inst::Op { dst: is_frame, op: OpCode::FrIsFrame, args: vec![fp] });
    origins.push(None);
    body.push(Inst::Br { cond: is_frame, then: l_dispatch, otherwise: l_start });
    origins.push(None);
    body.push(Inst::Label(l_start));
    origins.push(None);
    // Each yielding call site's hand-off register (the body, below, starts
    // by setting every one to UNIT): the frame its next call passes down --
    // UNIT at a fresh activation; the callee's own frame while it is
    // suspended (frcallee); and, once the callee has returned, the frame of
    // that finished activation, which nothing else holds any more: the
    // site's next call hands it down again (its point is 0, so the callee
    // starts afresh and reuses it), and a yielding call in a loop -- an
    // event loop's yield_now per dispatch -- makes one frame, not one per
    // iteration.

    let mut site_of = std::collections::HashMap::new();
    for (k, (j, _)) in sites.iter().enumerate() {
        site_of.insert(*j, k);
    }
    for (j, inst) in old_body.into_iter().enumerate() {
        let origin = old_origins[j];
        if let Some(&k) = site_of.get(&j) {
            let point = k as u32 + 1;
            let (tagged, raw) = saved[k].clone();
            let l_suspend = label();
            let l_resume = label();
            let l_back = label();
            dispatch_labels.push(l_resume);
            // What a suspension returns: the frame (first result).
            let suspend = |f: &mut Function, callee: Option<Reg>, out: &mut Vec<(Inst, Option<u32>)>| {
                out.push((Inst::Label(l_suspend), None));
                out.push((Inst::Op { dst: fr, op: OpCode::FrEnsure, args: vec![fr] }, origin));
                out.push((Inst::FrameSave { frame: fr, point, callee, tagged: tagged.clone(), raw: raw.clone() }, None));
                if results > 1 {
                    let mut rs = vec![fr];
                    for _ in 1..results {
                        let u = new_reg(f, RegKind::Tagged);
                        out.push((Inst::Unit { dst: u }, None));
                        rs.push(u);
                    }
                    out.push((Inst::RetMulti(rs), None));
                } else {
                    out.push((Inst::Ret(fr), None));
                }
            };
            match &sites[k].1 {
                Site::Yield { dst, value } => {
                    report.yield_sites += 1;
                    let u = new_reg(&mut f, RegKind::Tagged);
                    body.push(Inst::Op { dst: u, op: OpCode::CoSuspend, args: vec![*value] });
                    origins.push(origin);
                    body.push(Inst::Jump(l_suspend));
                    origins.push(None);
                    body.push(Inst::Label(l_back));
                    origins.push(None);
                    body.push(Inst::Op { dst: *dst, op: OpCode::CoMsg, args: vec![] });
                    origins.push(origin);
                    suspend(&mut f, None, &mut suspends);
                    dispatches.push((Inst::Label(l_resume), None));
                    dispatches.push((Inst::FrameRestore { frame: fr, tagged, raw }, None));
                    dispatches.push((Inst::Jump(l_back), None));
                }
                Site::Call { unbox } => {
                    report.call_sites += 1;
                    let h = match &inst {
                        Inst::Call { args, .. } | Inst::CallEnv { args, .. } | Inst::CallMulti { args, .. } | Inst::CallEnvMulti { args, .. } => {
                            *args.last().expect("the hand-off argument")
                        }
                        _ => unreachable!("a call site"),
                    };
                    let l_cont = label();
                    body.push(Inst::Label(l_back));
                    origins.push(None);
                    // The call, its results into fresh tagged registers.
                    let (call, args, dsts) = match inst {
                        Inst::Call { dst, func, args, may_error, may_gc } => {
                            let t = new_reg(&mut f, RegKind::Tagged);
                            (Inst::Call { dst: t, func, args: args.clone(), may_error, may_gc }, args, vec![(dst, t)])
                        }
                        Inst::CallEnv { dst, func, closure, args, may_error, may_gc } => {
                            let t = new_reg(&mut f, RegKind::Tagged);
                            (Inst::CallEnv { dst: t, func, closure, args: args.clone(), may_error, may_gc }, args, vec![(dst, t)])
                        }
                        Inst::CallMulti { dsts, func, args, may_error, may_gc } => {
                            let ts: Vec<Reg> = dsts.iter().map(|_| new_reg(&mut f, RegKind::Tagged)).collect();
                            let pairs = dsts.iter().copied().zip(ts.iter().copied()).collect();
                            (Inst::CallMulti { dsts: ts, func, args: args.clone(), may_error, may_gc }, args, pairs)
                        }
                        Inst::CallEnvMulti { dsts, func, closure, args, may_error, may_gc } => {
                            let ts: Vec<Reg> = dsts.iter().map(|_| new_reg(&mut f, RegKind::Tagged)).collect();
                            let pairs = dsts.iter().copied().zip(ts.iter().copied()).collect();
                            (Inst::CallEnvMulti { dsts: ts, func, closure, args: args.clone(), may_error, may_gc }, args, pairs)
                        }
                        _ => unreachable!("a call site"),
                    };
                    let t0 = dsts[0].1;
                    body.push(call);
                    origins.push(origin);
                    let b = new_reg(&mut f, RegKind::Tagged);
                    body.push(Inst::Op { dst: b, op: OpCode::FrIsFrame, args: vec![t0] });
                    origins.push(None);
                    body.push(Inst::Br { cond: b, then: l_suspend, otherwise: l_cont });
                    origins.push(None);
                    body.push(Inst::Label(l_cont));
                    origins.push(None);
                    for (dst, t) in &dsts {
                        match unbox {
                            Some(op) if dsts.len() == 1 => body.push(Inst::Op { dst: *dst, op: *op, args: vec![*t] }),
                            _ => body.push(Inst::Move { dst: *dst, src: *t }),
                        }
                        origins.push(None);
                    }
                    suspend(&mut f, Some(t0), &mut suspends);
                    // Resumed: reload, define the arguments the callee
                    // ignores, hand it its frame, make the same call again.
                    dispatches.push((Inst::Label(l_resume), None));
                    dispatches.push((Inst::FrameRestore { frame: fr, tagged: tagged.clone(), raw: raw.clone() }, None));
                    let restored: Vec<Reg> = tagged.iter().chain(&raw).copied().collect();
                    let mut defined: Vec<Reg> = Vec::new();
                    for a in &args[..args.len() - 1] {
                        if restored.contains(a) || defined.contains(a) {
                            continue;
                        }
                        defined.push(*a);
                        dispatches.push((dummy(*a, f.kind_of(*a)), None));
                    }
                    dispatches.push((Inst::Op { dst: h, op: OpCode::FrCallee, args: vec![fr] }, None));
                    dispatches.push((Inst::Jump(l_back), None));
                }
            }
            continue;
        }
        match inst {
            // A self tail call: the new activation continues with this
            // activation's frame (reused, never a second one).
            Inst::Tail { mut args } => {
                report.tail_sites += 1;
                args.push(fr);
                body.push(Inst::Tail { args });
            }
            Inst::TailEnv { closure, mut args } => {
                report.tail_sites += 1;
                args.push(fr);
                body.push(Inst::TailEnv { closure, args });
            }
            Inst::Ret(r) if boxed.is_some() => {
                let (op, _) = boxed.unwrap();
                let t = new_reg(&mut f, RegKind::Tagged);
                body.push(Inst::Op { dst: t, op, args: vec![r] });
                origins.push(origin);
                body.push(Inst::Ret(t));
            }
            inst => body.push(inst),
        }
        origins.push(origin);
    }
    for (inst, origin) in suspends {
        body.push(inst);
        origins.push(origin);
    }
    let point = new_reg(&mut f, RegKind::Raw);
    body.push(Inst::Label(l_dispatch));
    origins.push(None);
    body.push(Inst::Op { dst: point, op: OpCode::FrPoint, args: vec![fr] });
    origins.push(None);
    let mut cases = vec![(0i64, 0i64, l_start)];
    cases.extend(dispatch_labels.iter().enumerate().map(|(k, l)| (k as i64 + 1, k as i64 + 1, *l)));
    body.push(Inst::Switch { value: point, default: l_bad, cases });
    origins.push(None);
    for (inst, origin) in dispatches {
        body.push(inst);
        origins.push(origin);
    }
    body.push(Inst::Label(l_bad));
    origins.push(None);
    body.push(Inst::Unreachable);
    origins.push(None);
    f.body = body;
    f.origins = origins;
    f.frame = Some(shape);
    f.may_gc = true;
    report.functions.push((name_of(&f), shape));
    Ok(f)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A coroutine program: `leaf` yields with a String live across the
    /// yield; `middle` calls it twice (two sites of one callee); the thunk
    /// (function 3) calls `middle`.
    const PROGRAM: &str = concat!(
        "nir 1 call-effects=1\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=3 pnames=\"\" captures=0\n",
        "    %0 = fnvalue 3\n    %1 = op cocreate %0\n    %2 = op costart %1\n    ret %2\nend\n",
        "func 1 \"leaf\" params=1 env=0 regs=4 pnames=\"n\" captures=0\n",
        "    %1 = str \"kept\"\n    %2 = op coyield %0\n    %3 = op strlen %1\n    ret %3\nend\n",
        "func 2 \"middle\" params=1 env=0 regs=4 pnames=\"n\" captures=0\n",
        "    %1 = call 1 %0\n    %2 = call 1 %1\n    %3 = op iadd %1 %2\n    ret %3\nend\n",
        "func 3 \"\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
        "    %0 = int 7\n    %1 = call 2 %0\n    ret %1\nend\n",
    );

    fn lowered() -> (Program, Report) {
        let mut program = nir::parse(PROGRAM).unwrap_or_else(|e| panic!("{e}"));
        let report = lower(&mut program).unwrap_or_else(|e| panic!("{e}"));
        (program, report)
    }

    /// Every yielding function gains a frame shape and a hidden tagged frame
    /// parameter, its last; no `coyield` remains; the program validates.
    #[test]
    fn yielding_functions_become_state_machines() {
        let (program, report) = lowered();
        assert_eq!((report.yield_sites, report.call_sites, report.functions.len()), (1, 3, 3));
        for (id, params) in [(1, 2), (2, 2), (3, 1)] {
            let f = &program.functions[id];
            assert!(f.frame.is_some(), "{} has a frame shape", f.name);
            assert_eq!(f.params, params, "{}: the hidden frame parameter", f.name);
            assert_eq!(f.kind_of(params - 1), RegKind::Tagged);
        }
        assert!(program.functions[0].frame.is_none(), "the program function constructs, it does not yield");
        assert!(!program.functions.iter().flat_map(|f| &f.body).any(|i| matches!(i, Inst::Op { op: OpCode::CoYield, .. })));
        nir::validate(&program).unwrap();
    }

    /// I4/I5: a suspension saves exactly what is live after it -- leaf keeps
    /// its String (not its parameter, dead after the yield); middle's first
    /// site keeps the second site's hand-off register and the first result
    /// is the second call's argument, so the shape is the widest point's.
    #[test]
    fn a_suspension_saves_exactly_the_live_registers() {
        let (program, _) = lowered();
        let saves = |id: usize| -> Vec<(u32, usize, usize)> {
            program.functions[id]
                .body
                .iter()
                .filter_map(|i| if let Inst::FrameSave { point, tagged, raw, .. } = i { Some((*point, tagged.len(), raw.len())) } else { None })
                .collect()
        };
        assert_eq!(saves(1), vec![(1, 1, 0)], "leaf: only the String");
        assert_eq!(program.functions[1].frame, Some(FrameShape { tagged: 1, raw: 0 }));
        assert_eq!(saves(2), vec![(1, 1, 0), (2, 1, 0)], "middle: the next site's hand-off, then the first result");
    }

    /// Lowering a lowered program changes nothing: no `coyield` is left, so
    /// no function yields any more (the driver's `fused` output reads back
    /// and runs as it is).
    #[test]
    fn lowering_is_idempotent() {
        let (mut program, _) = lowered();
        let before: Vec<String> = program.functions.iter().map(|f| crate::codegen::nirtext::function(&program, f)).collect();
        let report = lower(&mut program).unwrap();
        assert!(report.functions.is_empty());
        let after: Vec<String> = program.functions.iter().map(|f| crate::codegen::nirtext::function(&program, f)).collect();
        assert_eq!(before, after);
        // And the text reads back to the same program.
        let text = program.functions.iter().map(|f| crate::codegen::nirtext::function(&program, f)).collect::<Vec<_>>().join("\n");
        let back = nir::parse(&format!("nir 1 call-effects=1\n\n{text}")).unwrap_or_else(|e| panic!("{e}\n{text}"));
        assert_eq!(back.functions[2].frame, program.functions[2].frame);
    }

    /// A yielding self tail call passes the activation's frame on: the new
    /// activation reuses it (its point is 0 while it runs).
    #[test]
    fn a_yielding_tail_call_passes_its_frame() {
        let text = concat!(
            "nir 1 call-effects=1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=3 pnames=\"\" captures=0\n",
            "    %0 = fnvalue 2\n    %1 = op cocreate %0\n    %2 = op costart %1\n    ret %2\nend\n",
            "func 1 \"spin\" params=1 env=0 regs=3 pnames=\"n\" captures=0\n",
            "    %1 = op coyield %0\n    %2 = int 1\n    %0 = op isub %0 %2\n    tail %0\nend\n",
            "func 2 \"\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
            "    %0 = int 3\n    %1 = call 1 %0\n    ret %1\nend\n",
        );
        let mut program = nir::parse(text).unwrap();
        let report = lower(&mut program).unwrap();
        assert_eq!(report.tail_sites, 1);
        let spin = &program.functions[1];
        let fr = match &spin.body[0] {
            Inst::Move { dst, src } if *src + 1 == spin.params => *dst,
            other => panic!("the entry takes the hidden frame: {other:?}"),
        };
        let tail = spin.body.iter().find_map(|i| if let Inst::Tail { args } = i { Some(args.clone()) } else { None }).unwrap();
        assert_eq!(tail.last(), Some(&fr), "the tail call hands the activation's frame to the next one");
    }

    /// The boundaries the lowering relies on: a yielding C callback or
    /// library export, or a yielding program function, is refused -- a
    /// compiler bug upstream, never a program the language allows.
    #[test]
    fn a_yield_reachable_from_c_or_the_program_is_refused() {
        let mut program = nir::parse(PROGRAM).unwrap();
        program.exports.push(nir::ExportDecl { symbol: "lib_leaf".into(), func: 1, params: vec![], result: nir::Boundary::Unit });
        assert!(lower(&mut program).unwrap_err().contains("lib_leaf"));
        let mut yielding_program = nir::parse(&PROGRAM.replace("    %0 = fnvalue 3\n    %1 = op cocreate %0\n    %2 = op costart %1\n    ret %2\n", "    %0 = int 1\n    %1 = call 1 %0\n    %2 = move %1\n    ret %2\n")).unwrap();
        assert!(lower(&mut yielding_program).unwrap_err().contains("program function"));
    }
}
