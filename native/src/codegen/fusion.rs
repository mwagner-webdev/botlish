//! Coroutine fusion (COROUTINE-FUSION-MILESTONE-1.md): a coroutine whose
//! whole protocol is statically closed inside one NIR function runs as
//! ordinary control flow on that function's own frame, with no coroutine
//! object, no stack of its own, no switch and no runtime coroutine
//! operation.
//!
//! A NIR-to-NIR pass, run by the driver on the parsed program before code
//! generation (main.rs), so every native consumer -- the JIT, objects,
//! executables, `clif`, `size`, `roots` -- sees the program it compiles.
//! It decides per construction site (`op cocreate`) and never changes what
//! a program means: a site it cannot prove keeps the general runtime
//! (runtime/coroutine.rs), which stays the oracle
//! (`BOTLISH_NATIVE_COROUTINE_FUSION=0` turns the pass off).
//!
//! # What makes a site fusible (each condition is checked here)
//!
//! * The body is a function value (`fnvalue T`, or `closure T %c...` with
//!   the same captures wherever it is made) used only by this
//!   construction: T is the thunk native/lower.tcl makes for
//!   `coroutine {step, first} = root(args)`.
//! * The handle never leaves the function: every register holding it is
//!   written only by the construction, by `unit` or by a `move` of another
//!   such register, and read only by `costart`, `coresume`, `coresume0`,
//!   `codone`, `corelease` (as the handle) or such a `move`. No call,
//!   field, List, capture, return, payload or guard sees it.
//! * At most one coroutine of the site is alive at a time: no register
//!   holding a handle is live after the construction but the one it
//!   defines (codegen::roots's liveness), so the site's state can live in
//!   one set of registers.
//! * Every function the coroutine's code can reach a `coyield` through --
//!   T, and every function T reaches by direct calls of functions that may
//!   yield -- can be inlined: environment-free (but T), a direct
//!   single-result `call`, no recursion among them (a self tail call is a
//!   loop and is fine), within a size budget.
//!
//! # The transformation
//!
//! T and that yielding call chain are inlined once into a *template*: their
//! registers renumbered into the function's, their labels into a private
//! space. The suspended call chain of a deep yield is then nothing but the
//! template's registers -- the inlined frames' locals, still live -- plus:
//!
//! ```text
//! st      0 fresh, k suspended at the k-th yield, -1 completed, -2 failed
//! out     the outward value (a yield's, or the final result: the cache)
//! msg     the resume message
//! failbox a terminal failed coroutine holding the failure (op cofailed)
//! ```
//!
//! Every start and resume of the coroutine gets its own *copy* of the
//! template's code over those same registers (its labels renamed), placed
//! after the function's code, whose every yield and completion jumps
//! straight back to the code after that start or resume. Control flow stays
//! exact: a segment returns only to the operation that ran it, as in the
//! source, so liveness, root plans and the validator's dataflow (a
//! collecting loop's private plan) see no path the program cannot take.
//! The price is code size: a copy per start and resume (code reachable only
//! from another operation's copy is dead in this one).
//!
//! * `cocreate` sets `st` to 0 (and the handle register to unit);
//! * `costart` jumps to its copy's entry; `coresume`/`coresume0` store the
//!   message and jump to their copy's dispatch, which branches on `st` to
//!   the point after the k-th yield (a completed coroutine to the cached
//!   result, a failed one to its failure);
//! * `coyield %v` stores `out`, sets `st` to k and jumps back to the code
//!   after the operation; the k-th resume point reads `msg`;
//! * the thunk's `ret` caches the result in `out` and sets `st` to -1;
//! * any failure inside a copy (each copy is one `pusherrorexit` span)
//!   takes the pending error into a failed coroutine object (`op
//!   cofailed`), sets `st` to -2 and goes to a stub placed where the start
//!   or resume was, inside the same error-exit spans, which raises it
//!   (`op coresume0` of the failed object: the general runtime's own stable
//!   terminal failure) -- at that resume, and at every later one;
//! * `codone` is `st < 0`; `corelease` is nothing (the template's
//!   registers simply die).
//!
//! The values a suspended coroutine holds are the template's registers,
//! live across the function's code from the yield to the next resume, so
//! the function's own root plan (codegen::roots) roots them at every
//! safepoint in between: the collector needs nothing coroutine-specific.
//! The tagged registers live into a dispatch are reset to unit at each
//! construction, so a construction in a loop does not keep the previous
//! coroutine's values alive.
//!
//! Every rewritten function is validated again (`nir::validate_function`); a site
//! whose fused function did not validate keeps the general runtime (and is
//! reported: it would be a bug of this pass). Fusion is applied repeatedly
//! within a function, so a coroutine constructed inside a fused producer
//! (whose construction the copies duplicate: one site, several `cocreate`s
//! of one register), or a second coroutine of the same consumer, is fused
//! in turn: two independent coroutines become two state machines in one
//! frame.

use crate::codegen::nirtext;
use crate::codegen::roots::{def_use, live_at_many};
use crate::nir::{self, FuncId, Function, Inst, Label, OpCode, Piece, Program, Reg, RegKind};
use crate::runtime::coroutine::STACK_SWITCHING;
use std::collections::HashSet;

/// The state of a completed and of a failed fused coroutine (`st`).
const DONE: i64 = -1;
const FAILED: i64 = -2;
/// Instructions one fused coroutine's template may hold (its thunk and
/// yielding call chain, inlined once).
const INLINE_LIMIT: usize = 20_000;
/// Instructions all the copies of one fused coroutine may hold.
const COPY_LIMIT: usize = 100_000;
/// The largest body fusion grows a function to.
const FUNCTION_LIMIT: usize = 200_000;
/// Construction sites fused per function (nested and repeated fusion).
const SITES_PER_FUNCTION: usize = 64;
/// The template label every yield and completion jumps to: the code after
/// the start or resume the copy belongs to.
const BACK: Label = 0;

/// Whether the driver fuses coroutines: on every host with native
/// coroutines (elsewhere the general runtime refuses them, and fusion must
/// not make such a program run), unless BOTLISH_NATIVE_COROUTINE_FUSION=0.
pub fn enabled() -> bool {
    STACK_SWITCHING && std::env::var("BOTLISH_NATIVE_COROUTINE_FUSION").map_or(true, |v| v != "0")
}

/// What became of one construction site.
pub struct SiteReport {
    /// The function the construction is in, as it was named.
    pub function: String,
    /// The construction's HIR expression (its `@eN`), if annotated.
    pub origin: Option<u32>,
    pub outcome: Result<Fused, String>,
}

/// A fused site: what the pass eliminated and what it inlined.
pub struct Fused {
    /// The inlined functions (the thunk first), in inlining order.
    pub inlined: Vec<String>,
    /// Yield points in the template: the dispatch's states 1..=yields.
    pub yields: usize,
    /// `cocreate`s of the site (more than one when an enclosing fused
    /// coroutine's copies duplicated the construction).
    pub creates: usize,
    pub starts: usize,
    pub resumes: usize,
    pub queries: usize,
    pub releases: usize,
    /// Instructions of the template, and of all its copies together.
    pub template: usize,
    pub copied: usize,
    /// Struct constructions of the values the coroutine passes that no
    /// longer allocate (`scalar_transport`).
    pub unboxed: usize,
}

/// Fuses every fusible construction site of PROGRAM, function by function;
/// returns what became of each site considered. Settles the program's
/// effect summaries again (`nir::resummarize`).
pub fn fuse(program: &mut Program) -> Vec<SiteReport> {
    let yielding = yielding(program);
    let mut reports = Vec::new();
    for fi in 0..program.functions.len() {
        let mut kept: HashSet<Reg> = HashSet::new();
        let mut fused = 0usize;
        loop {
            let f = &program.functions[fi];
            let Some(create) = f.body.iter().position(|inst| {
                matches!(inst, Inst::Op { op: OpCode::CoCreate, dst, .. } if !kept.contains(dst))
            }) else {
                break;
            };
            let Inst::Op { dst: handle, .. } = f.body[create] else { unreachable!() };
            let function = f.name.clone();
            let origin = f.origins[create];
            let outcome = if fused >= SITES_PER_FUNCTION {
                Err(format!("its function already holds {SITES_PER_FUNCTION} fused coroutines"))
            } else {
                fuse_site(program, fi, handle, &yielding)
            };
            let outcome = match outcome {
                Ok((rewritten, info)) => {
                    let original = std::mem::replace(&mut program.functions[fi], rewritten);
                    match nir::validate_function(program, fi) {
                        Ok(()) => {
                            fused += 1;
                            Ok(info)
                        }
                        Err(e) => {
                            program.functions[fi] = original;
                            kept.insert(handle);
                            Err(format!("its fused function does not validate (a fusion bug): {}", e.message))
                        }
                    }
                }
                Err(reason) => {
                    kept.insert(handle);
                    Err(reason)
                }
            };
            reports.push(SiteReport { function, origin, outcome });
        }
    }
    if reports.iter().any(|r| r.outcome.is_ok()) {
        drop_unreferenced(program);
    }
    nir::resummarize(program);
    reports
}

/// The functions no code of PROGRAM refers to any more -- a fused
/// coroutine's thunk, and the producers only it called -- keep their place
/// (function numbers are dense) but lose their code: their body becomes
/// `unreachable`. Referring is calling (also a self tail call) or making a
/// Block value (`fnvalue`, `closure`), from the program function on.
fn drop_unreferenced(program: &mut Program) {
    let n = program.functions.len();
    let mut reached = vec![false; n];
    let mut work = vec![0usize];
    reached[0] = true;
    while let Some(i) = work.pop() {
        for inst in &program.functions[i].body {
            let target = match inst {
                Inst::FnValue { func, .. } | Inst::Closure { func, .. } => Some(*func),
                other => callee(other),
            };
            if let Some(g) = target {
                if !reached[g as usize] {
                    reached[g as usize] = true;
                    work.push(g as usize);
                }
            }
        }
    }
    for (i, f) in program.functions.iter_mut().enumerate() {
        if !reached[i] && f.body.len() > 1 {
            f.body = vec![Inst::Unreachable];
            f.origins = vec![None];
        }
    }
}

/// The report as text, one Tcl list per site: `fused FUNCTION ORIGIN
/// {inlined NAMES yields K creates C starts S resumes R queries Q releases
/// L template T copied N unboxed U}` or `kept FUNCTION ORIGIN REASON`.
pub fn report(reports: &[SiteReport]) -> String {
    use crate::runtime::show::tcl_list;
    let mut lines = Vec::new();
    for r in reports {
        let origin = r.origin.map(|o| format!("e{o}")).unwrap_or_default();
        let line = match &r.outcome {
            Ok(f) => {
                let mut facts = vec!["inlined".to_string(), tcl_list(&f.inlined)];
                for (key, n) in [
                    ("yields", f.yields),
                    ("creates", f.creates),
                    ("starts", f.starts),
                    ("resumes", f.resumes),
                    ("queries", f.queries),
                    ("releases", f.releases),
                    ("template", f.template),
                    ("copied", f.copied),
                    ("unboxed", f.unboxed),
                ] {
                    facts.push(key.to_string());
                    facts.push(n.to_string());
                }
                tcl_list(&["fused".to_string(), r.function.clone(), origin, tcl_list(&facts)])
            }
            Err(reason) => tcl_list(&["kept".to_string(), r.function.clone(), origin, reason.clone()]),
        };
        lines.push(line);
    }
    lines.join("\n")
}

/// Per function: whether it may yield through direct calls -- it contains a
/// `coyield`, or a direct call of a function that may (a function that may
/// yield is never a value: COROUTINES.md point 37).
fn yielding(program: &Program) -> Vec<bool> {
    let mut y: Vec<bool> = program
        .functions
        .iter()
        .map(|f| f.body.iter().any(|i| matches!(i, Inst::Op { op: OpCode::CoYield, .. })))
        .collect();
    loop {
        let mut changed = false;
        for (i, f) in program.functions.iter().enumerate() {
            if y[i] {
                continue;
            }
            if f.body.iter().any(|inst| callee(inst).is_some_and(|g| y[g as usize])) {
                y[i] = true;
                changed = true;
            }
        }
        if !changed {
            return y;
        }
    }
}

/// The function INST calls directly, if it is a direct call.
fn callee(inst: &Inst) -> Option<FuncId> {
    match inst {
        Inst::Call { func, .. } | Inst::CallEnv { func, .. } | Inst::CallMulti { func, .. } | Inst::CallEnvMulti { func, .. } => {
            Some(*func)
        }
        _ => None,
    }
}

fn text(program: &Program, inst: &Inst) -> String {
    nirtext::inst(program, inst).trim().to_string()
}

/// F's name, or `#ID` for a nameless one (a thunk).
fn name_of(f: &Function) -> String {
    if f.name.is_empty() { format!("#{}", f.id) } else { f.name.clone() }
}

fn max_label(f: &Function) -> Option<Label> {
    f.body.iter().filter_map(|i| if let Inst::Label(l) = i { Some(*l) } else { None }).max()
}

/// How the function uses the coroutine at one instruction.
#[derive(Clone, Copy, PartialEq)]
enum Use {
    Start,
    Resume,
    Resume0,
    Done,
    Release,
}

/// Fuses the construction site whose handle is register HANDLE of function
/// FI: the rewritten function and what was done, or why the site keeps the
/// general runtime.
fn fuse_site(program: &Program, fi: usize, handle: Reg, yielding: &[bool]) -> Result<(Function, Fused), String> {
    let f = &program.functions[fi];

    // The constructions of HANDLE: one, or one per copy of an enclosing
    // fused coroutine's code -- the same body register each time.
    let creates: Vec<usize> = f
        .body
        .iter()
        .enumerate()
        .filter(|(_, inst)| matches!(inst, Inst::Op { op: OpCode::CoCreate, dst, .. } if *dst == handle))
        .map(|(i, _)| i)
        .collect();
    let Inst::Op { args, .. } = &f.body[creates[0]] else { unreachable!() };
    let body_reg = args[0];
    if creates.iter().any(|c| !matches!(&f.body[*c], Inst::Op { args, .. } if args[0] == body_reg)) {
        return Err("its handle register holds coroutines of different bodies".to_string());
    }

    // The body: one function value with the same captures wherever it is
    // made, used only by the constructions.
    if body_reg < f.params {
        return Err("its body is a parameter of the function".to_string());
    }
    let mut body_defs: Vec<usize> = Vec::new();
    let mut body_uses = 0usize;
    for (i, inst) in f.body.iter().enumerate() {
        let (defs, uses) = def_use(inst, f.params);
        if defs.contains(&body_reg) {
            body_defs.push(i);
        }
        body_uses += uses.iter().filter(|u| **u == body_reg).count();
    }
    if body_defs.is_empty() {
        return Err("its body value is not made in this function".to_string());
    }
    if body_uses != creates.len() {
        return Err("its body value is used besides the construction".to_string());
    }
    let made = |inst: &Inst| -> Option<(FuncId, Vec<Reg>)> {
        match inst {
            Inst::FnValue { func, .. } => Some((*func, Vec::new())),
            Inst::Closure { func, captures, .. } => Some((*func, captures.clone())),
            _ => None,
        }
    };
    let Some((thunk, captures)) = made(&f.body[body_defs[0]]) else {
        return Err(format!("its body is no known function: {}", text(program, &f.body[body_defs[0]])));
    };
    if body_defs.iter().any(|d| made(&f.body[*d]) != Some((thunk, captures.clone()))) {
        return Err("its body value is made from different functions or captures".to_string());
    }
    let tf = &program.functions[thunk as usize];
    if tf.params != 0 || tf.results != 1 || tf.has_scalar_abi() || tf.plan_result {
        return Err(format!("its body {} is no plain thunk", tf.id));
    }

    // The handle: the registers holding it, and every use of them.
    let mut alias: HashSet<Reg> = HashSet::from([handle]);
    loop {
        let before = alias.len();
        for inst in &f.body {
            if let Inst::Move { dst, src } = inst {
                if alias.contains(src) {
                    alias.insert(*dst);
                }
            }
        }
        if alias.len() == before {
            break;
        }
    }
    if alias.iter().any(|r| *r < f.params) {
        return Err("its handle reaches a parameter register".to_string());
    }
    let mut uses: Vec<(usize, Use)> = Vec::new();
    for (i, inst) in f.body.iter().enumerate() {
        let (defs, used) = def_use(inst, f.params);
        for d in &defs {
            // A `unit` write holds no handle: a fused enclosing coroutine's
            // construction resets its template's registers so, a nested
            // construction's handle register among them.
            if alias.contains(d)
                && !creates.contains(&i)
                && !matches!(inst, Inst::Unit { .. })
                && !matches!(inst, Inst::Move { src, .. } if alias.contains(src))
            {
                return Err(format!("a register holding its handle is also written by `{}`", text(program, inst)));
            }
        }
        if !used.iter().any(|u| alias.contains(u)) {
            continue;
        }
        let what = match inst {
            Inst::Move { .. } => continue,
            Inst::Op { op: OpCode::CoStart, args, .. } if args.len() == 1 => Use::Start,
            Inst::Op { op: OpCode::CoResume, args, .. } if args.len() == 2 && !alias.contains(&args[1]) => Use::Resume,
            Inst::Op { op: OpCode::CoResume0, args, .. } if args.len() == 1 => Use::Resume0,
            Inst::Op { op: OpCode::CoDone, args, .. } if args.len() == 1 => Use::Done,
            Inst::Op { op: OpCode::CoRelease, args, .. } if args.len() == 1 => Use::Release,
            other => {
                return Err(format!("its handle reaches `{}`, which fusion does not follow", text(program, other)));
            }
        };
        uses.push((i, what));
    }
    for (_, live_out) in live_at_many(f, &creates) {
        if alias.iter().any(|r| *r != handle && live_out[*r as usize]) {
            return Err("a coroutine an earlier run of this construction made may still be alive when it runs again".to_string());
        }
    }
    let segments = uses.iter().filter(|(_, u)| matches!(u, Use::Start | Use::Resume | Use::Resume0)).count();

    // The template: the thunk and its yielding call chain, inlined once.
    let mut b = Builder::new(program, f, yielding);
    let caps: Vec<Reg> = captures.iter().map(|_| b.new_reg(RegKind::Tagged, false)).collect();
    b.caps = caps.clone();
    let entry = b.template_label();
    b.inline(thunk, &[], Return::Complete, entry, true)?;
    let template_size = b.code.len();
    if template_size * segments > COPY_LIMIT {
        return Err(format!(
            "its {segments} starts and resumes would copy {} instructions, past the fusion budget of {COPY_LIMIT}",
            template_size * segments
        ));
    }

    // The function's own code, its uses of the coroutine rewritten, and a
    // copy of the template per start and resume after it.
    let mut body: Vec<(Inst, Option<u32>)> = Vec::new();
    let mut copies: Vec<(Vec<(Inst, Option<u32>)>, Label)> = Vec::new(); // (code, dispatch label)
    let mut counts = [0usize; 5];
    let mut resets_at: Vec<usize> = Vec::new();
    for (i, inst) in f.body.iter().enumerate() {
        let origin = f.origins[i];
        if body_defs.contains(&i) {
            for (cap, c) in caps.iter().zip(&captures) {
                body.push((Inst::Move { dst: *cap, src: *c }, origin));
            }
            continue;
        }
        if creates.contains(&i) {
            body.push((Inst::RawInt { dst: b.st, digits: "0".to_string() }, origin));
            body.push((Inst::Unit { dst: handle }, origin));
            resets_at.push(body.len());
            continue;
        }
        let Some(&(_, what)) = uses.iter().find(|(j, _)| *j == i) else {
            body.push((inst.clone(), origin));
            continue;
        };
        let Inst::Op { dst, args, .. } = inst else { unreachable!() };
        match what {
            Use::Done => {
                counts[3] += 1;
                let zero = b.new_reg(RegKind::Raw, false);
                body.push((Inst::RawInt { dst: zero, digits: "0".to_string() }, origin));
                body.push((Inst::Op { dst: *dst, op: OpCode::RILt, args: vec![b.st, zero] }, origin));
            }
            Use::Release => {
                counts[4] += 1;
                body.push((Inst::Unit { dst: *dst }, origin));
            }
            Use::Start | Use::Resume | Use::Resume0 => {
                let back = b.new_label();
                let raise = b.new_label();
                let (code, dispatch, start) = b.copy(back, raise, what == Use::Start, origin);
                match what {
                    Use::Start => counts[0] += 1,
                    Use::Resume => {
                        counts[1] += 1;
                        body.push((Inst::Move { dst: b.msg, src: args[1] }, origin));
                    }
                    _ => {
                        counts[2] += 1;
                        body.push((Inst::Unit { dst: b.msg }, origin));
                    }
                }
                body.push((Inst::Jump(if what == Use::Start { start } else { dispatch }), origin));
                // The failure is raised here, inside the error-exit spans
                // the start or resume was in.
                body.push((Inst::Label(raise), None));
                let ignored = b.new_reg(RegKind::Tagged, false);
                body.push((Inst::Op { dst: ignored, op: OpCode::CoResume0, args: vec![b.failbox] }, origin));
                body.push((Inst::Unreachable, origin));
                body.push((Inst::Label(back), None));
                body.push((Inst::Move { dst: *dst, src: b.out }, origin));
                copies.push((code, if what == Use::Start { start } else { dispatch }));
            }
        }
    }
    let copied: usize = copies.iter().map(|(code, _)| code.len()).sum();
    let mut dispatches = Vec::new();
    for (code, dispatch) in copies {
        dispatches.push(body.len() + code.iter().position(|(i, _)| matches!(i, Inst::Label(l) if *l == dispatch)).unwrap_or(0));
        body.extend(code);
    }

    let mut nf = b.nf;
    nf.body = body.iter().map(|(i, _)| i.clone()).collect();
    nf.origins = body.iter().map(|(_, o)| *o).collect();

    // A construction resets the template's tagged registers live into a
    // dispatch, so a coroutine made in a loop does not keep the previous
    // one's values alive (and none is read unset).
    let mut live = vec![false; nf.regs as usize];
    for (live_in, _) in live_at_many(&nf, &dispatches) {
        for (r, l) in live_in.iter().enumerate() {
            live[r] |= *l;
        }
    }
    let mut resets: Vec<Reg> = Vec::new();
    for r in b.template_regs.iter().copied().chain([b.out, b.msg, b.failbox]) {
        if live[r as usize] && nf.kind_of(r) == RegKind::Tagged {
            resets.push(r);
        }
    }
    if nf.body.len() + resets.len() * creates.len() > FUNCTION_LIMIT {
        return Err(format!("its function would grow past {FUNCTION_LIMIT} instructions"));
    }
    for at in resets_at.iter().rev() {
        let origin = body[at - 1].1;
        let inserted: Vec<(Inst, Option<u32>)> = resets.iter().map(|r| (Inst::Unit { dst: *r }, origin)).collect();
        body.splice(*at..*at, inserted);
    }
    nf.body = body.iter().map(|(i, _)| i.clone()).collect();
    nf.origins = body.iter().map(|(_, o)| *o).collect();
    let unboxed = scalar_transport(program, &mut nf, b.out) + scalar_transport(program, &mut nf, b.msg);

    let info = Fused {
        inlined: b.inlined,
        yields: b.resumes.len(),
        creates: creates.len(),
        starts: counts[0],
        resumes: counts[1] + counts[2],
        queries: counts[3],
        releases: counts[4],
        template: template_size,
        copied,
        unboxed,
    };
    Ok((nf, info))
}

/// A new register of F of KIND (a plan register if PLAN).
fn push_reg(f: &mut Function, kind: RegKind, plan: bool) -> Reg {
    let r = f.regs;
    f.regs += 1;
    f.raw_regs.push(kind == RegKind::Raw);
    f.plan_regs.push(plan);
    f.short_regs.push(kind == RegKind::Short);
    f.ascii_regs.push(kind == RegKind::Ascii);
    f.i64_regs.push(kind == RegKind::I64);
    f.u64_regs.push(kind == RegKind::U64);
    f.scalar_regs.push(kind != RegKind::Tagged);
    r
}

/// Scalar replacement of a value a fused coroutine passes: its outward
/// value (SEED `out`) or its resume message (SEED `msg`). Fusion puts the
/// struct a yield sends (or a resume hands in) and the projections that
/// read it into one function; when every register a `move` connects to
/// SEED is written only by `structnew` of one shape, a `move` or `unit` (a
/// construction's reset), and read only by `structget` or a `move`, the
/// struct is never needed as an object: each of those registers becomes a
/// register per field, `structnew` copies its fields, `structget` reads
/// one. Returns the number of `structnew`s that no longer allocate (0 when
/// some use needs the object: a call, a field, a List, a return).
fn scalar_transport(program: &Program, f: &mut Function, seed: Reg) -> usize {
    let mut class: HashSet<Reg> = HashSet::from([seed]);
    loop {
        let before = class.len();
        for inst in &f.body {
            if let Inst::Move { dst, src } = inst {
                if class.contains(dst) || class.contains(src) {
                    class.insert(*dst);
                    class.insert(*src);
                }
            }
        }
        if class.len() == before {
            break;
        }
    }
    if class.iter().any(|r| *r < f.params || f.kind_of(*r) != RegKind::Tagged || f.plan_regs[*r as usize]) {
        return 0;
    }
    let mut shape = None;
    let mut news = 0usize;
    for inst in &f.body {
        let (defs, uses) = def_use(inst, f.params);
        match inst {
            Inst::StructNew { dst, shape: s, fields } if class.contains(dst) => {
                if fields.iter().any(|r| class.contains(r)) || *shape.get_or_insert(*s) != *s {
                    return 0;
                }
                news += 1;
            }
            Inst::Move { dst, .. } if class.contains(dst) => {}
            Inst::Unit { dst } if class.contains(dst) => {}
            Inst::StructGet { dst, value, .. } if class.contains(value) && !class.contains(dst) => {}
            _ if defs.iter().chain(&uses).any(|r| class.contains(r)) => return 0,
            _ => {}
        }
    }
    let Some(shape) = shape else { return 0 };
    let width = program.shapes[shape as usize].fields.len();
    if f.body.iter().any(|i| matches!(i, Inst::StructGet { slot, value, .. } if class.contains(value) && *slot as usize >= width)) {
        return 0;
    }
    let mut members: Vec<Reg> = class.into_iter().collect();
    members.sort();
    let mut parts: std::collections::HashMap<Reg, Vec<Reg>> = std::collections::HashMap::new();
    for r in members {
        let regs = (0..width).map(|_| push_reg(f, RegKind::Tagged, false)).collect();
        parts.insert(r, regs);
    }
    let mut body = Vec::with_capacity(f.body.len());
    let mut origins = Vec::with_capacity(f.body.len());
    for (inst, origin) in f.body.iter().zip(&f.origins) {
        let rewritten: Vec<Inst> = match inst {
            Inst::StructNew { dst, fields, .. } if parts.contains_key(dst) => {
                parts[dst].iter().zip(fields).map(|(p, v)| Inst::Move { dst: *p, src: *v }).collect()
            }
            Inst::Move { dst, src } if parts.contains_key(dst) => {
                parts[dst].iter().zip(&parts[src]).map(|(d, s)| Inst::Move { dst: *d, src: *s }).collect()
            }
            Inst::Unit { dst } if parts.contains_key(dst) => parts[dst].iter().map(|p| Inst::Unit { dst: *p }).collect(),
            Inst::StructGet { dst, slot, value } if parts.contains_key(value) => {
                vec![Inst::Move { dst: *dst, src: parts[value][*slot as usize] }]
            }
            other => vec![other.clone()],
        };
        for i in rewritten {
            body.push(i);
            origins.push(*origin);
        }
    }
    f.body = body;
    f.origins = origins;
    news
}

/// Where an inlined function's `ret` goes.
#[derive(Clone, Copy)]
enum Return {
    /// The thunk's: the coroutine completes.
    Complete,
    /// A yielding callee's: the call's destination, then template LABEL.
    Value(Reg, Label),
}

/// The function being rewritten, and the template being inlined for it.
struct Builder<'p> {
    program: &'p Program,
    yielding: &'p [bool],
    nf: Function,
    /// The next label of the function (its own, then the copies').
    next_label: Label,
    /// The next label of the template's private space (BACK is 0).
    next_template_label: Label,
    st: Reg,
    out: Reg,
    msg: Reg,
    failbox: Reg,
    caps: Vec<Reg>,
    /// The template label after each yield, in order: state k resumes at
    /// entry k-1.
    resumes: Vec<Label>,
    /// The template's entry label.
    entry: Label,
    code: Vec<(Inst, Option<u32>)>,
    /// Registers the inlined functions' own registers became.
    template_regs: Vec<Reg>,
    stack: Vec<FuncId>,
    inlined: Vec<String>,
}

impl<'p> Builder<'p> {
    fn new(program: &'p Program, f: &Function, yielding: &'p [bool]) -> Builder<'p> {
        let mut nf = f.clone();
        nf.body = Vec::new();
        nf.origins = Vec::new();
        let mut b = Builder {
            program,
            yielding,
            nf,
            next_label: max_label(f).map_or(0, |l| l + 1),
            next_template_label: BACK + 1,
            st: 0,
            out: 0,
            msg: 0,
            failbox: 0,
            caps: Vec::new(),
            resumes: Vec::new(),
            entry: 0,
            code: Vec::new(),
            template_regs: Vec::new(),
            stack: Vec::new(),
            inlined: Vec::new(),
        };
        b.st = b.new_reg(RegKind::Raw, false);
        b.out = b.new_reg(RegKind::Tagged, false);
        b.msg = b.new_reg(RegKind::Tagged, false);
        b.failbox = b.new_reg(RegKind::Tagged, false);
        b
    }

    fn new_label(&mut self) -> Label {
        self.next_label += 1;
        self.next_label - 1
    }

    fn template_label(&mut self) -> Label {
        self.next_template_label += 1;
        self.next_template_label - 1
    }

    fn new_reg(&mut self, kind: RegKind, plan: bool) -> Reg {
        push_reg(&mut self.nf, kind, plan)
    }

    fn emit(&mut self, inst: Inst, origin: Option<u32>) {
        self.code.push((inst, origin));
    }

    /// Inlines function G into the template, its parameters bound to ARGS
    /// (registers of the function being rewritten): its body from template
    /// label ENTRY on, every `ret` going where RET says. THUNK: G is the
    /// coroutine's body (the one function with an environment allowed:
    /// `capture I` reads the I-th captured value).
    fn inline(&mut self, g: FuncId, args: &[Reg], ret: Return, entry: Label, thunk: bool) -> Result<(), String> {
        let program = self.program;
        let gf = &program.functions[g as usize];
        if self.stack.contains(&g) {
            return Err(format!("its yielding function {} is recursive", name_of(gf)));
        }
        if gf.env && !thunk {
            return Err(format!("its yielding function {} is a closure", name_of(gf)));
        }
        if gf.results != 1 {
            return Err(format!("its yielding function {} returns several values", name_of(gf)));
        }
        if self.code.len() + gf.body.len() > INLINE_LIMIT {
            return Err(format!("its code exceeds the fusion budget of {INLINE_LIMIT} inlined instructions"));
        }
        if thunk {
            self.entry = entry;
        }
        self.stack.push(g);
        self.inlined.push(name_of(gf));

        // G's registers, renumbered into the function's, with their kinds.
        let base = self.nf.regs;
        for r in 0..gf.regs {
            let reg = self.new_reg(gf.kind_of(r), gf.plan_regs[r as usize]);
            self.template_regs.push(reg);
        }
        let label_base = self.next_template_label;
        self.next_template_label += max_label(gf).map_or(0, |l| l + 1);
        let reg = |r: Reg| base + r;
        let label = |l: Label| label_base + l;

        // The parameters: a raw parameter of the tagged ABI is unboxed, as
        // the prologue would (codegen::clif); every other one has the
        // argument's own kind already (nir::validate's call-site rule).
        for (i, a) in args.iter().enumerate() {
            let p = reg(i as Reg);
            if gf.raw_regs[i] && !gf.raw_params[i] {
                self.emit(Inst::Op { dst: p, op: OpCode::RUnbox, args: vec![*a] }, None);
            } else {
                self.emit(Inst::Move { dst: p, src: *a }, None);
            }
        }
        self.emit(Inst::Label(entry), None);

        for (idx, inst) in gf.body.iter().enumerate() {
            let origin = gf.origins[idx];
            match inst {
                Inst::Capture { dst, index } if thunk => {
                    let src = self.caps[*index as usize];
                    self.emit(Inst::Move { dst: reg(*dst), src }, origin);
                }
                Inst::Capture { .. } | Inst::SelfClosure { .. } => {
                    return Err(format!("its function {} reads its own closure", name_of(gf)));
                }
                Inst::Ret(r) => match ret {
                    Return::Complete => {
                        self.emit(Inst::Move { dst: self.out, src: reg(*r) }, origin);
                        self.emit(Inst::RawInt { dst: self.st, digits: DONE.to_string() }, origin);
                        self.emit(Inst::Jump(BACK), origin);
                    }
                    Return::Value(dst, after) => {
                        self.emit(Inst::Move { dst, src: reg(*r) }, origin);
                        self.emit(Inst::Jump(after), origin);
                    }
                },
                Inst::RetMulti(_) | Inst::TailEnv { .. } => {
                    return Err(format!("its function {} has a form fusion does not inline", name_of(gf)));
                }
                Inst::Tail { args } => {
                    // A self tail call: a loop back to the inlined entry,
                    // every parameter rebound at once.
                    let temps: Vec<Reg> =
                        (0..args.len()).map(|i| self.new_reg(gf.kind_of(i as Reg), gf.plan_regs[i])).collect();
                    for (t, a) in temps.iter().zip(args) {
                        self.emit(Inst::Move { dst: *t, src: reg(*a) }, origin);
                    }
                    for (i, t) in temps.iter().enumerate() {
                        self.emit(Inst::Move { dst: reg(i as Reg), src: *t }, origin);
                    }
                    self.emit(Inst::Jump(entry), origin);
                }
                Inst::Op { dst, op: OpCode::CoYield, args } => {
                    let resume = self.template_label();
                    self.resumes.push(resume);
                    let k = self.resumes.len();
                    self.emit(Inst::Move { dst: self.out, src: reg(args[0]) }, origin);
                    self.emit(Inst::RawInt { dst: self.st, digits: k.to_string() }, origin);
                    self.emit(Inst::Jump(BACK), origin);
                    self.emit(Inst::Label(resume), None);
                    self.emit(Inst::Move { dst: reg(*dst), src: self.msg }, origin);
                }
                Inst::Call { dst, func, args: call_args, .. } if self.yielding[*func as usize] => {
                    let after = self.template_label();
                    let callee_entry = self.template_label();
                    let mapped: Vec<Reg> = call_args.iter().map(|a| reg(*a)).collect();
                    self.inline(*func, &mapped, Return::Value(reg(*dst), after), callee_entry, false)?;
                    self.emit(Inst::Label(after), None);
                }
                other if callee(other).is_some_and(|c| self.yielding[c as usize]) => {
                    return Err(format!("its function {} calls a yielding function in a form fusion does not inline: {}", name_of(gf), text(program, other)));
                }
                other => self.emit(rename(other, &reg, &label), origin),
            }
        }
        self.stack.pop();
        Ok(())
    }

    /// One copy of the template, for a start (START) or a resume: its code,
    /// its dispatch label and its entry label. Its yields and completion go
    /// to the function's label BACK_TO, its failures to RAISE.
    fn copy(&mut self, back_to: Label, raise: Label, start: bool, origin: Option<u32>) -> (Vec<(Inst, Option<u32>)>, Label, Label) {
        let base = self.next_label;
        self.next_label += self.next_template_label;
        let relabel = |l: Label| if l == BACK { back_to } else { base + l };
        let dispatch = self.new_label();
        let fail = self.new_label();
        let mut code: Vec<(Inst, Option<u32>)> = Vec::new();
        code.push((Inst::Label(dispatch), None));
        code.push((Inst::PushErrorExit(fail), origin));
        if !start {
            // Back to the point after the yield the coroutine is suspended
            // at; a terminal coroutine to its cached result or failure.
            for (k, resume) in self.resumes.clone().iter().enumerate() {
                let next = self.new_label();
                let state = self.new_reg(RegKind::Raw, false);
                let c = self.new_reg(RegKind::Tagged, false);
                code.push((Inst::RawInt { dst: state, digits: (k + 1).to_string() }, origin));
                code.push((Inst::Op { dst: c, op: OpCode::RIEq, args: vec![self.st, state] }, origin));
                code.push((Inst::Br { cond: c, then: relabel(*resume), otherwise: next }, origin));
                code.push((Inst::Label(next), None));
            }
            let state = self.new_reg(RegKind::Raw, false);
            let c = self.new_reg(RegKind::Tagged, false);
            code.push((Inst::RawInt { dst: state, digits: DONE.to_string() }, origin));
            code.push((Inst::Op { dst: c, op: OpCode::RIEq, args: vec![self.st, state] }, origin));
            code.push((Inst::Br { cond: c, then: back_to, otherwise: raise }, origin));
        }
        let identity = |r: Reg| r;
        for (inst, o) in &self.code {
            code.push((rename(inst, &identity, &relabel), *o));
        }
        code.push((Inst::PopErrorExit, origin));
        code.push((Inst::Label(fail), None));
        code.push((Inst::Op { dst: self.failbox, op: OpCode::CoFailed, args: Vec::new() }, origin));
        code.push((Inst::RawInt { dst: self.st, digits: FAILED.to_string() }, origin));
        code.push((Inst::Jump(raise), origin));
        (code, dispatch, relabel(self.entry))
    }
}

/// INST with every register R read or written as REG(R) and every label L
/// as LABEL(L).
fn rename(inst: &Inst, reg: &dyn Fn(Reg) -> Reg, label: &dyn Fn(Label) -> Label) -> Inst {
    let regs = |rs: &[Reg]| rs.iter().map(|r| reg(*r)).collect::<Vec<Reg>>();
    match inst {
        Inst::Label(l) => Inst::Label(label(*l)),
        Inst::Int { dst, digits } => Inst::Int { dst: reg(*dst), digits: digits.clone() },
        Inst::RawInt { dst, digits } => Inst::RawInt { dst: reg(*dst), digits: digits.clone() },
        Inst::CWord { dst, digits } => Inst::CWord { dst: reg(*dst), digits: digits.clone() },
        Inst::ShortLit { dst, value } => Inst::ShortLit { dst: reg(*dst), value: *value },
        Inst::AsciiLit { dst, value } => Inst::AsciiLit { dst: reg(*dst), value: *value },
        Inst::Str { dst, text } => Inst::Str { dst: reg(*dst), text: text.clone() },
        Inst::Bytes { dst, bytes } => Inst::Bytes { dst: reg(*dst), bytes: bytes.clone() },
        Inst::Char { dst, digits } => Inst::Char { dst: reg(*dst), digits: digits.clone() },
        Inst::Float { dst, ty, bits } => Inst::Float { dst: reg(*dst), ty: *ty, bits: *bits },
        Inst::Enum { dst, index, case } => Inst::Enum { dst: reg(*dst), index: *index, case: *case },
        Inst::Bool { dst, value } => Inst::Bool { dst: reg(*dst), value: *value },
        Inst::Unit { dst } => Inst::Unit { dst: reg(*dst) },
        Inst::Native { dst, native } => Inst::Native { dst: reg(*dst), native: *native },
        Inst::FnValue { dst, func } => Inst::FnValue { dst: reg(*dst), func: *func },
        Inst::SelfClosure { dst } => Inst::SelfClosure { dst: reg(*dst) },
        Inst::Capture { dst, index } => Inst::Capture { dst: reg(*dst), index: *index },
        Inst::StaticGet { dst, index } => Inst::StaticGet { dst: reg(*dst), index: *index },
        Inst::StaticSet { index, value } => Inst::StaticSet { index: *index, value: reg(*value) },
        Inst::ContextLoad { dst, offset } => Inst::ContextLoad { dst: reg(*dst), offset: *offset },
        Inst::ContextStore { offset, value } => Inst::ContextStore { offset: *offset, value: reg(*value) },
        Inst::Move { dst, src } => Inst::Move { dst: reg(*dst), src: reg(*src) },
        Inst::Closure { dst, func, captures } => Inst::Closure { dst: reg(*dst), func: *func, captures: regs(captures) },
        Inst::Guard { kind, value, context } => Inst::Guard { kind: *kind, value: reg(*value), context: context.clone() },
        Inst::GuardBool { value } => Inst::GuardBool { value: reg(*value) },
        Inst::Op { dst, op, args } => Inst::Op { dst: reg(*dst), op: *op, args: regs(args) },
        Inst::Call { dst, func, args, may_error, may_gc } => {
            Inst::Call { dst: reg(*dst), func: *func, args: regs(args), may_error: *may_error, may_gc: *may_gc }
        }
        Inst::CallEnv { dst, func, closure, args, may_error, may_gc } => Inst::CallEnv {
            dst: reg(*dst),
            func: *func,
            closure: reg(*closure),
            args: regs(args),
            may_error: *may_error,
            may_gc: *may_gc,
        },
        Inst::CallValue { dst, callee, args } => Inst::CallValue { dst: reg(*dst), callee: reg(*callee), args: regs(args) },
        Inst::ForeignCall { dst, foreign, args, exposed, discard, varargs } => Inst::ForeignCall {
            dst: reg(*dst),
            foreign: *foreign,
            args: regs(args),
            exposed: exposed.clone(),
            discard: *discard,
            varargs: varargs.clone(),
        },
        Inst::CallMulti { dsts, func, args, may_error, may_gc } => {
            Inst::CallMulti { dsts: regs(dsts), func: *func, args: regs(args), may_error: *may_error, may_gc: *may_gc }
        }
        Inst::CallEnvMulti { dsts, func, closure, args, may_error, may_gc } => Inst::CallEnvMulti {
            dsts: regs(dsts),
            func: *func,
            closure: reg(*closure),
            args: regs(args),
            may_error: *may_error,
            may_gc: *may_gc,
        },
        Inst::Tail { args } => Inst::Tail { args: regs(args) },
        Inst::TailEnv { closure, args } => Inst::TailEnv { closure: reg(*closure), args: regs(args) },
        Inst::Br { cond, then, otherwise } => Inst::Br { cond: reg(*cond), then: label(*then), otherwise: label(*otherwise) },
        Inst::Jump(l) => Inst::Jump(label(*l)),
        Inst::Ret(r) => Inst::Ret(reg(*r)),
        Inst::RetMulti(rs) => Inst::RetMulti(regs(rs)),
        Inst::Raise { kind, message } => Inst::Raise { kind: kind.clone(), message: message.clone() },
        Inst::Unreachable => Inst::Unreachable,
        Inst::Fail { id, name, shape, payload } => Inst::Fail { id: *id, name: name.clone(), shape: *shape, payload: regs(payload) },
        Inst::DeclaredPayload { dst, index } => Inst::DeclaredPayload { dst: reg(*dst), index: *index },
        Inst::DeclaredErrorEq { dst, id } => Inst::DeclaredErrorEq { dst: reg(*dst), id: *id },
        Inst::ClearDeclaredError => Inst::ClearDeclaredError,
        Inst::PushErrorExit(l) => Inst::PushErrorExit(label(*l)),
        Inst::PopErrorExit => Inst::PopErrorExit,
        Inst::Construct { dst, list, plan, pieces } => Inst::Construct {
            dst: reg(*dst),
            list: *list,
            plan: *plan,
            pieces: pieces
                .iter()
                .map(|p| match p {
                    Piece::Span(r) => Piece::Span(reg(*r)),
                    Piece::Region(b, s, e) => Piece::Region(reg(*b), reg(*s), reg(*e)),
                    Piece::Elem(r) => Piece::Elem(reg(*r)),
                })
                .collect(),
        },
        Inst::StructNew { dst, shape, fields } => Inst::StructNew { dst: reg(*dst), shape: *shape, fields: regs(fields) },
        Inst::StructGet { dst, slot, value } => Inst::StructGet { dst: reg(*dst), slot: *slot, value: reg(*value) },
        Inst::Reraise => Inst::Reraise,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::codegen::{Backend, CompileOptions, CraneliftJit};
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::value::Value;
    use crate::runtime::vm::{ProgramInfo, Vm};
    use std::rc::Rc;

    /// counter(m) yields 0..m-1 and returns -1; consume(m) folds every
    /// yield and the final result: 0 + 1 + ... + 9 - 1 = 44 for m = 10.
    /// CONSUMER_EXTRA is spliced into consume before its return.
    fn program(consumer_extra: &str, counter_extra: &str) -> String {
        [
            "nir 1 call-effects=1 statics=0\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0\n",
            "    %0 = int 10\n    %1 = call 2 %0\n    ret %1\nend\n",
            "func 1 \"counter\" params=1 env=0 regs=8 pnames=\"m\" captures=0\n",
            "    %1 = int 0\n    %2 = move %1\n    jump L0\n  label L0\n",
            "    %3 = op ilt %2 %0\n    br %3 L1 L2\n  label L1\n",
            "    %4 = op coyield %2\n    %5 = int 1\n    %6 = op iadd %2 %5\n    %2 = move %6\n",
            counter_extra,
            "    jump L0\n  label L2\n    %7 = int -1\n    ret %7\nend\n",
            "func 2 \"consume\" params=1 env=0 regs=14 pnames=\"m\" captures=0\n",
            "    %1 = closure 3 %0\n    %2 = op cocreate %1\n    %3 = op costart %2\n    %4 = move %3\n",
            "    %5 = int 1\n    jump L0\n  label L0\n    %6 = op ilt %5 %0\n    br %6 L1 L2\n  label L1\n",
            "    %7 = op coresume0 %2\n    %8 = op iadd %4 %7\n    %4 = move %8\n",
            "    %9 = int 1\n    %10 = op iadd %5 %9\n    %5 = move %10\n    jump L0\n  label L2\n",
            "    %11 = op coresume0 %2\n    %12 = op iadd %4 %11\n",
            consumer_extra,
            "    %13 = op corelease %2\n    ret %12\nend\n",
            "func 3 \"\" params=0 env=1 regs=2 pnames=\"\" captures=1\n",
            "    %0 = capture 0\n    %1 = call 1 %0\n    ret %1\nend\n",
            "func 4 \"keep\" params=1 env=0 regs=1 pnames=\"h\" captures=0\n    ret %0\nend\n",
        ]
        .concat()
    }

    fn run(program: &Program) -> Value {
        let options = CompileOptions { clif: false, vcode: false, alloc_sites: false, count_accesses: false };
        let compiled = CraneliftJit.compile(program, &options).expect("compiles");
        let mut vm = Vm::new(
            Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new() }),
            AllocMode::Off,
        );
        compiled.install_constants(&mut vm);
        vm.set_framemap(compiled.framemap.clone());
        (compiled.entry)(&mut *vm)
    }

    fn coroutine_ops(f: &Function) -> Vec<OpCode> {
        f.body
            .iter()
            .filter_map(|i| match i {
                Inst::Op { op, .. } if op.spelling().starts_with("co") => Some(*op),
                _ => None,
            })
            .collect()
    }

    #[test]
    fn a_generator_is_fused_into_its_consumer() {
        let text = program("", "");
        let mut program = nir::parse(&text).unwrap_or_else(|e| panic!("{e}"));
        let reports = fuse(&mut program);
        assert_eq!(reports.len(), 1);
        let fused = reports[0].outcome.as_ref().unwrap_or_else(|e| panic!("{e}"));
        assert_eq!((fused.yields, fused.starts, fused.resumes, fused.releases), (1, 1, 2, 1));
        assert_eq!(fused.inlined, vec!["#3".to_string(), "counter".to_string()]);
        // Only the failure path's operations are left in the consumer, and
        // the thunk and the producer, referred to no more, lost their code.
        assert!(coroutine_ops(&program.functions[2]).iter().all(|op| matches!(op, OpCode::CoFailed | OpCode::CoResume0)));
        assert!(matches!(program.functions[1].body[..], [Inst::Unreachable]));
        assert!(matches!(program.functions[3].body[..], [Inst::Unreachable]));
        // It runs without the coroutine runtime: no stack, no switch (the
        // general program's value is the same, tests/coroutine-fusion.test).
        assert_eq!(run(&program), crate::runtime::value::make_small(44));
    }

    #[test]
    fn a_handle_that_reaches_a_call_keeps_the_general_runtime() {
        let mut program = nir::parse(&program("    %13 = call 4 %2\n", "")).unwrap_or_else(|e| panic!("{e}"));
        let reports = fuse(&mut program);
        let reason = reports[0].outcome.as_ref().err().expect("kept");
        assert!(reason.contains("reaches `%13 = call 4 %2`"), "{reason}");
        assert!(coroutine_ops(&program.functions[2]).contains(&OpCode::CoStart));
    }

    #[test]
    fn a_recursive_yielding_function_keeps_the_general_runtime() {
        let mut program = nir::parse(&program("", "    %7 = call 1 %5\n")).unwrap_or_else(|e| panic!("{e}"));
        let reports = fuse(&mut program);
        assert_eq!(reports[0].outcome.as_ref().err().map(String::as_str), Some("its yielding function counter is recursive"));
    }

    #[test]
    fn the_report_names_what_was_done() {
        let mut program = nir::parse(&program("", "")).unwrap();
        let text = report(&fuse(&mut program));
        assert!(text.starts_with("fused consume {} {inlined {{#3} counter} yields 1 creates 1 starts 1 resumes 2"), "{text}");
    }
}
