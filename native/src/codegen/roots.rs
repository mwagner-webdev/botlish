//! GC-root liveness: which NIR registers need a shadow-stack slot, and which
//! slots may be shared, computed from safepoint-live-range interference
//! instead of the old "one slot per register, forever" policy (see
//! codegen::clif's module doc for that policy and why it over-roots).
//!
//! Pipeline (module-level, no Cranelift involved -- this operates on
//! `nir::Function` alone, so it can run, and be tested, without a backend):
//!
//!   1. Build the function's basic-block CFG from its label/branch structure
//!      (`Cfg`, mirroring exactly the block/edge shape codegen::clif's own
//!      translation gives the same instructions: a label starts a block, a
//!      branch/jump/tail/ret ends one, a self `tail`/`tailenv` back-edges to
//!      the function's first block).
//!   2. Classify every instruction as a GC safepoint or not (`is_safepoint`):
//!      an instruction whose runtime helper may allocate (ops.rs's
//!      `op_may_allocate`, the one authoritative table), a direct Botlish
//!      call (conservatively -- the callee may allocate even when the caller
//!      cannot prove otherwise; see item 9 of this milestone's brief), or a
//!      dynamically dispatched call.
//!   3. Run ordinary backward liveness (def/use per instruction, standard
//!      dataflow over the CFG, iterated to a fixpoint for loops) to get
//!      `LiveIn` at every instruction.
//!   4. At each safepoint, `Roots(safepoint) = LiveIn(safepoint) restricted to
//!      non-raw (managed-capable) registers` -- this single definition
//!      already covers a call's own arguments (they are `Use`s of the call,
//!      hence in its `LiveIn` regardless of whether they are read again
//!      afterward) and values only needed after the call returns (they are
//!      `LiveOut`, hence `LiveIn`, if not redefined by the call), so no
//!      separate "argument rooting" or "result rooting" special case is
//!      needed: see the milestone brief's items 14-16.
//!   5. Two registers interfere iff some safepoint's root set contains both.
//!      Greedy-color the interference graph (deterministic: registers and
//!      slots are tried in ascending numeric order) to assign each register
//!      that is ever a safepoint root a shadow slot, reusing a slot for any
//!      two registers that never co-occur.
//!
//! A register never live at any safepoint (raw, or tagged but dead before
//! every safepoint that could see it) gets no slot at all: `RootPlan::slot_of`
//! is `None` for it, and codegen never stores to or zeroes a slot that does
//! not exist. Raw registers can never be candidates in the first place (they
//! are filtered out of every safepoint's live set before interference is
//! even computed), so they cost zero slots unconditionally -- not "usually
//! zero", never.
//!
//! What this module deliberately does not do (see the milestone brief's
//! items 18-19, 25-26): a globally optimal coloring, a stack-map/PC-indexed
//! root table it, or store motion beyond "store once, at definition, for any
//! register that is a candidate at all" (`RootPlan` only decides *whether* a
//! register is stored and where; codegen::clif's `def` still does the
//! storing, unconditionally at every definition of a slotted register,
//! exactly the simplest sound model the brief asks for).

use crate::nir::{Function, Inst, Program, Reg};
use crate::runtime::ops::op_may_allocate;
use std::collections::HashSet;
use std::fmt::Write as _;

/// The result of root-liveness analysis for one function: which register
/// gets which shadow-stack slot (if any), and the structural facts
/// `native/explain-native.tcl`'s root report (and this module's own tests)
/// read back out.
pub struct RootPlan {
    /// Per NIR register (indexed by `Reg`): its shadow slot, or None if it
    /// never needs one (raw, or tagged but never live at a safepoint).
    pub slot_of: Vec<Option<u32>>,
    /// Number of shadow slots this function's frame needs. At least 1
    /// always (codegen::clif's prologue reserves at least one slot
    /// regardless of rooting needs, to keep the shadow stack bounding
    /// native recursion depth even for a function with zero roots: see its
    /// own doc comment).
    pub num_slots: u32,
    /// Number of instructions classified as GC safepoints.
    pub safepoints: u32,
    /// Number of distinct registers that are live at at least one safepoint
    /// (i.e., that need a slot at all, before coloring/reuse).
    pub root_candidates: u32,
    /// The largest `Roots(safepoint)` seen at any single safepoint: the
    /// theoretical minimum slot count a perfect (non-greedy) allocator could
    /// not go below.
    pub max_live: u32,
}

impl RootPlan {
    /// The register count and how many are raw, for diagnostics
    /// (`native/explain-native.tcl`'s root report): not stored on the plan
    /// itself since they are already on `Function`, just re-exposed here so
    /// callers don't need both.
    pub fn counts(f: &Function) -> (u32, u32) {
        let raw = f.raw_regs.iter().filter(|r| **r).count() as u32;
        (f.regs, raw)
    }
}

/// Whether INST is a point GC may run: a helper call that may allocate, a
/// direct or dynamically-dispatched Botlish call (conservatively: the callee
/// may allocate even when this instruction's own operation cannot -- see
/// this module's doc and the milestone brief's item 9), or a construction
/// (`cell`/`closure`) whose own runtime helper always allocates.
fn is_safepoint(inst: &Inst) -> bool {
    match inst {
        Inst::Cell { .. } | Inst::Closure { .. } => true,
        Inst::Op { op, .. } => op_may_allocate(*op),
        Inst::Call { .. } | Inst::CallEnv { .. } | Inst::CallMulti { .. } | Inst::CallEnvMulti { .. } => true,
        Inst::CallValue { .. } => true,
        _ => false,
    }
}

/// The registers INST defines and uses, for liveness. `raise`/`unreachable`
/// use no register (their string operands are literals, not NIR values) and
/// always end the block they are in, so they contribute nothing here beyond
/// being a terminator with no successor (see `Cfg::build`).
fn def_use(inst: &Inst, params: u32) -> (Vec<Reg>, Vec<Reg>) {
    match inst {
        Inst::Label(_) | Inst::Unreachable | Inst::Raise { .. } => (vec![], vec![]),
        Inst::Int { dst, .. }
        | Inst::RawInt { dst, .. }
        | Inst::Str { dst, .. }
        | Inst::Bool { dst, .. }
        | Inst::Unit { dst }
        | Inst::Native { dst, .. }
        | Inst::FnValue { dst, .. }
        | Inst::SelfClosure { dst }
        | Inst::Capture { dst, .. }
        | Inst::Cell { dst } => (vec![*dst], vec![]),
        Inst::Move { dst, src } => (vec![*dst], vec![*src]),
        Inst::CellSet { cell, value } => (vec![], vec![*cell, *value]),
        Inst::CellGet { dst, cell } => (vec![*dst], vec![*cell]),
        Inst::CellCheck { dst, cell, .. } => (vec![*dst], vec![*cell]),
        Inst::Closure { dst, captures, .. } => (vec![*dst], captures.clone()),
        Inst::Guard { value, .. } | Inst::GuardBool { value } => (vec![], vec![*value]),
        Inst::Op { dst, args, .. } => (vec![*dst], args.clone()),
        Inst::Call { dst, args, .. } => (vec![*dst], args.clone()),
        Inst::CallEnv { dst, closure, args, .. } => {
            let mut use_ = vec![*closure];
            use_.extend(args);
            (vec![*dst], use_)
        }
        Inst::CallMulti { dsts, args, .. } => (dsts.clone(), args.clone()),
        Inst::CallEnvMulti { dsts, closure, args, .. } => {
            let mut use_ = vec![*closure];
            use_.extend(args);
            (dsts.clone(), use_)
        }
        Inst::CallValue { dst, callee, args } => {
            let mut use_ = vec![*callee];
            use_.extend(args);
            (vec![*dst], use_)
        }
        // A self tail call rebinds every parameter register (codegen::clif's
        // Inst::Tail/TailEnv translation): the parameter slots 0..params are
        // defined, args (plus, for TailEnv, the new environment register)
        // are used to compute the new values.
        Inst::Tail { args } => ((0..params).collect(), args.clone()),
        Inst::TailEnv { closure, args } => {
            let mut use_ = vec![*closure];
            use_.extend(args);
            ((0..params).collect(), use_)
        }
        Inst::Br { cond, .. } => (vec![], vec![*cond]),
        Inst::Jump(_) => (vec![], vec![]),
        Inst::Ret(r) => (vec![], vec![*r]),
        Inst::RetMulti(rs) => (vec![], rs.clone()),
    }
}

/// The function's basic blocks and their successors, built from exactly the
/// control-flow codegen::clif's own translation gives the same NIR (see this
/// module's doc): a label starts a block; a branch/jump/tail/ret/raise/
/// unreachable ends one; anything else falls through to the next block
/// (matching `Translator::inst`'s implicit "jump into block" at a label
/// reached without an explicit terminator). A self `tail`/`tailenv` back-
/// edges to block 0 (the function's own entry, exactly where
/// `Translator::function`'s prologue jumps after binding parameters).
struct Cfg {
    /// (start, end) instruction index range of each block, end exclusive.
    blocks: Vec<(usize, usize)>,
    succs: Vec<Vec<usize>>,
}

impl Cfg {
    fn build(f: &Function) -> Cfg {
        let n = f.body.len();
        let mut is_start = vec![false; n.max(1)];
        is_start[0] = true;
        let mut label_index = std::collections::HashMap::new();
        for (i, inst) in f.body.iter().enumerate() {
            if let Inst::Label(l) = inst {
                label_index.insert(*l, i);
                is_start[i] = true;
            }
        }
        for i in 0..n {
            if f.body[i].is_terminator() && i + 1 < n {
                is_start[i + 1] = true;
            }
        }
        let mut block_of = vec![0usize; n];
        let mut starts = Vec::new();
        for i in 0..n {
            if is_start[i] {
                starts.push(i);
            }
            block_of[i] = starts.len() - 1;
        }
        let blocks: Vec<(usize, usize)> =
            starts.iter().enumerate().map(|(k, &s)| (s, starts.get(k + 1).copied().unwrap_or(n))).collect();
        let mut succs = vec![Vec::new(); blocks.len()];
        for (bidx, &(s, e)) in blocks.iter().enumerate() {
            if s == e {
                continue;
            }
            match &f.body[e - 1] {
                Inst::Jump(l) => succs[bidx].push(block_of[label_index[l]]),
                Inst::Br { then, otherwise, .. } => {
                    succs[bidx].push(block_of[label_index[then]]);
                    succs[bidx].push(block_of[label_index[otherwise]]);
                }
                // A self tail call jumps back to the body's first block,
                // exactly like codegen::clif's own translation (see this
                // module's doc).
                Inst::Tail { .. } | Inst::TailEnv { .. } => succs[bidx].push(0),
                Inst::Ret(_) | Inst::RetMulti(_) | Inst::Raise { .. } | Inst::Unreachable => {}
                // Not a terminator: this block was only split here because
                // the next instruction is a label (implicit fallthrough), or
                // this is the function's very last, terminator-ending block
                // (validate() already required the body to end in one, so
                // this arm is only ever the fallthrough case).
                _ => {
                    if bidx + 1 < blocks.len() {
                        succs[bidx].push(bidx + 1);
                    }
                }
            }
        }
        Cfg { blocks, succs }
    }
}

/// Ordinary backward liveness (`LiveIn` at every instruction, as a bitset
/// over registers) plus, along the way, each safepoint's root set: the
/// managed-capable (non-raw) registers in `LiveIn` at that instruction (see
/// this module's doc, item 4). Converges by the same argument any backward
/// "may" dataflow analysis does: bitsets only grow, and are bounded by
/// `f.regs` bits, so the loop below terminates; `guard` only exists to turn a
/// dataflow bug into a clear panic instead of a silent hang.
struct Liveness {
    /// Roots(safepoint) for every safepoint instruction, in program order.
    safepoint_roots: Vec<Vec<Reg>>,
}

fn analyze(f: &Function, cfg: &Cfg) -> Liveness {
    let regs = f.regs as usize;
    let nb = cfg.blocks.len();
    let mut live_in: Vec<Vec<bool>> = vec![vec![false; regs]; nb];
    let mut live_out: Vec<Vec<bool>> = vec![vec![false; regs]; nb];

    let block_live_in = |b: usize, live_in: &[Vec<bool>]| -> Vec<bool> {
        let (s, e) = cfg.blocks[b];
        let mut live = live_out_of(b, live_in, cfg);
        for idx in (s..e).rev() {
            let (defs, uses) = def_use(&f.body[idx], f.params);
            for d in &defs {
                live[*d as usize] = false;
            }
            for u in &uses {
                live[*u as usize] = true;
            }
        }
        live
    };
    fn live_out_of(b: usize, live_in: &[Vec<bool>], cfg: &Cfg) -> Vec<bool> {
        let regs = live_in.first().map_or(0, Vec::len);
        let mut out = vec![false; regs];
        for &s in &cfg.succs[b] {
            for i in 0..regs {
                out[i] |= live_in[s][i];
            }
        }
        out
    }

    let mut guard = 0usize;
    loop {
        guard += 1;
        if guard > (nb + f.body.len()) * 4 + 1000 {
            panic!("root liveness failed to converge for function {} ({})", f.id, f.name);
        }
        let mut changed = false;
        for b in (0..nb).rev() {
            let out = live_out_of(b, &live_in, cfg);
            if out != live_out[b] {
                live_out[b] = out;
                changed = true;
            }
            let new_in = block_live_in(b, &live_in);
            if new_in != live_in[b] {
                live_in[b] = new_in;
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }

    // Second pass: walk every block backward once more from its now-final
    // LiveOut, recording each safepoint's root set as we pass it.
    let mut safepoint_roots = Vec::new();
    for b in 0..nb {
        let (s, e) = cfg.blocks[b];
        let mut live = live_out[b].clone();
        for idx in (s..e).rev() {
            let inst = &f.body[idx];
            let (defs, uses) = def_use(inst, f.params);
            let mut live_in_inst = live.clone();
            for d in &defs {
                live_in_inst[*d as usize] = false;
            }
            for u in &uses {
                live_in_inst[*u as usize] = true;
            }
            if is_safepoint(inst) {
                let roots: Vec<Reg> =
                    (0..regs).filter(|&r| live_in_inst[r] && !f.raw_regs[r]).map(|r| r as Reg).collect();
                safepoint_roots.push(roots);
            }
            live = live_in_inst;
        }
    }
    Liveness { safepoint_roots }
}

/// Deterministic greedy coloring of the interference graph implied by
/// SAFEPOINT_ROOTS (two registers interfere iff some safepoint's root set
/// contains both): registers are colored in ascending numeric order, each
/// taking the lowest-numbered slot not already taken by a register it
/// interferes with, opening a new slot only when none fits (milestone brief
/// item 18: "do not attempt globally optimal coloring... simple deterministic
/// greedy... is sufficient").
fn color(regs: u32, safepoint_roots: &[Vec<Reg>]) -> (Vec<Option<u32>>, u32, u32) {
    let mut is_candidate = vec![false; regs as usize];
    let mut adjacency: Vec<HashSet<Reg>> = vec![HashSet::new(); regs as usize];
    let mut max_live = 0u32;
    for roots in safepoint_roots {
        max_live = max_live.max(roots.len() as u32);
        for &r in roots {
            is_candidate[r as usize] = true;
        }
        for i in 0..roots.len() {
            for j in (i + 1)..roots.len() {
                let (a, b) = (roots[i], roots[j]);
                adjacency[a as usize].insert(b);
                adjacency[b as usize].insert(a);
            }
        }
    }
    let mut slot_of: Vec<Option<u32>> = vec![None; regs as usize];
    let mut slot_members: Vec<Vec<Reg>> = Vec::new();
    for r in 0..regs {
        if !is_candidate[r as usize] {
            continue;
        }
        let mut chosen = None;
        for (s, members) in slot_members.iter().enumerate() {
            if members.iter().all(|m| !adjacency[r as usize].contains(m)) {
                chosen = Some(s as u32);
                break;
            }
        }
        let s = chosen.unwrap_or_else(|| {
            slot_members.push(Vec::new());
            (slot_members.len() - 1) as u32
        });
        slot_members[s as usize].push(r);
        slot_of[r as usize] = Some(s);
    }
    let root_candidates = is_candidate.iter().filter(|c| **c).count() as u32;
    (slot_of, slot_members.len() as u32, root_candidates)
}

/// Computes F's root-allocation plan (see this module's doc).
pub fn plan(f: &Function) -> RootPlan {
    let cfg = Cfg::build(f);
    let liveness = analyze(f, &cfg);
    let (slot_of, colored_slots, root_candidates) = color(f.regs, &liveness.safepoint_roots);
    let max_live = liveness.safepoint_roots.iter().map(Vec::len).max().unwrap_or(0) as u32;
    RootPlan {
        slot_of,
        // At least one slot always, so the shadow stack still bounds native
        // recursion depth for a function with zero roots (see RootPlan's
        // doc and codegen::clif's prologue).
        num_slots: colored_slots.max(1),
        safepoints: liveness.safepoint_roots.len() as u32,
        root_candidates,
        max_live,
    }
}

/// A compact, per-function root report for PROGRAM (milestone brief item 48:
/// "function fib<int>\nNIR regs: 17\nraw regs: 6\nsafepoints: 4\nroot
/// candidates: 7\nmax live roots: 3\nshadow slots: 3"), read by
/// `native/explain-native.tcl` (as `roots.txt`) and by `botlish-native
/// roots FILE.nir` directly. Purely a rendering of `RootPlan`/`Function`'s
/// own fields -- no analysis happens here.
pub fn report(program: &Program) -> String {
    let mut out = String::new();
    for f in &program.functions {
        let plan = plan(f);
        let (regs, raw) = RootPlan::counts(f);
        writeln!(out, "function {} \"{}\"", f.id, f.name).unwrap();
        writeln!(out, "  NIR regs: {regs}").unwrap();
        writeln!(out, "  raw regs: {raw}").unwrap();
        writeln!(out, "  managed-capable regs: {}", regs - raw).unwrap();
        writeln!(out, "  safepoints: {}", plan.safepoints).unwrap();
        writeln!(out, "  root candidates: {}", plan.root_candidates).unwrap();
        writeln!(out, "  max live roots: {}", plan.max_live).unwrap();
        writeln!(out, "  shadow slots: {}", plan.num_slots).unwrap();
        out.push('\n');
    }
    out
}


#[cfg(test)]
mod tests {
    use super::*;
    use crate::nir;

    /// Parses PROGRAM (possibly several `func`s) and returns it whole.
    fn parse_program(text: &str) -> nir::Program {
        nir::parse(text).unwrap_or_else(|e| panic!("{e}"))
    }

    /// Parses a one-function program and returns that function.
    fn parse_one(text: &str) -> nir::Function {
        parse_program(text).functions.into_iter().next().unwrap()
    }

    /// A minimal one-function program (function 0, no params/env, one
    /// result: the shape validate() requires of function 0) with REGS
    /// registers, RAWREGS the raw ones (space-separated, e.g. "0 2"), and
    /// BODY as its instructions.
    fn program_of(regs: u32, rawregs: &str, body: &str) -> nir::Function {
        let text = format!(
            "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs={regs} pnames=\"\" captures=0 rawregs=\"{rawregs}\"\n{body}end\n"
        );
        parse_one(&text)
    }

    /// A two-function program: function 0 is the required no-argument
    /// program entry, which calls function 1 (the actual function under
    /// test, declared by FUNC1_TEXT, a `func 1 ...` ... `end` block) with
    /// ENTRY_ARG (an NIR instruction producing register %0) as its one
    /// argument. Returns function 1.
    fn parse_with_one_arg(entry_arg: &str, func1_text: &str) -> nir::Function {
        let text = format!(
            "nir 1\n\nfunc 0 \"<program>\" params=0 env=0 regs=2 pnames=\"\" captures=0 rawregs=\"\"\n{entry_arg}    %1 = call 1 %0\n    ret %1\nend\n{func1_text}"
        );
        parse_program(&text).functions.into_iter().nth(1).unwrap()
    }

    // -----------------------------------------------------------------------
    // #27: a function with only raw temporaries needs zero root slots.

    #[test]
    fn raw_only_needs_no_slots() {
        // %0/%1/%2 are raw; %3 (the boxed sum, tagged since `ret` always
        // returns a Value) is never live across a safepoint -- this
        // function has none at all.
        let f = program_of(
            4,
            "0 1 2",
            "    %0 = rawint 1\n    %1 = rawint 2\n    %2 = op riadd %0 %1\n    %3 = op rbox %2\n    ret %3\n",
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 0);
        assert_eq!(plan.root_candidates, 0);
        assert_eq!(plan.num_slots, 1, "still >=1 for the recursion-depth bound, but zero *value* slots");
        assert!(plan.slot_of.iter().all(Option::is_none));
    }

    // -----------------------------------------------------------------------
    // #28: tagged intermediates that die before any safepoint need no slot.
    // `imod`'s helper never allocates (ops.rs's table), so this function has
    // no safepoint at all despite every register being tagged.

    #[test]
    fn tagged_dead_before_safepoint_needs_no_slot() {
        let f = program_of(3, "", "    %0 = int 7\n    %1 = int 2\n    %2 = op imod %0 %1\n    ret %2\n");
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 0);
        assert_eq!(plan.root_candidates, 0);
        assert!(plan.slot_of.iter().all(Option::is_none));
    }

    // -----------------------------------------------------------------------
    // #29: a managed value live across a MayGc op must be rooted. `cell`
    // allocates but takes no operands, so it isolates "must survive an
    // allocation" from "is itself the allocation's own argument" (that case
    // is covered separately below).

    #[test]
    fn tagged_live_across_gc_is_rooted() {
        let f = program_of(
            3,
            "",
            "    %0 = str \"a\"\n    %1 = cell\n    %2 = op streq %0 %0\n    ret %2\n",
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 1);
        assert_eq!(plan.max_live, 1, "only %0 is live across the cell allocation");
        assert_eq!(plan.root_candidates, 1);
        assert!(plan.slot_of[0].is_some());
        assert!(plan.slot_of[1].is_none(), "the fresh cell itself is dead before any later safepoint");
        assert_eq!(plan.num_slots, 1);
    }

    // -----------------------------------------------------------------------
    // A value that is itself an operand of the allocating instruction must
    // also be rooted during it (milestone brief item 15), even though it is
    // never read again afterward.

    #[test]
    fn call_argument_is_rooted_during_the_call() {
        let f = program_of(
            3,
            "",
            "    %0 = str \"a\"\n    %1 = str \"b\"\n    %2 = op strcat %0 %1\n    ret %2\n",
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 1);
        // Both %0 and %1 are live-in at the strcat: they are its operands,
        // needed while it runs, even though neither survives past it.
        assert_eq!(plan.max_live, 2);
        assert_eq!(plan.root_candidates, 2);
        assert_ne!(plan.slot_of[0], plan.slot_of[1]);
    }

    // -----------------------------------------------------------------------
    // #30: two values simultaneously live across a safepoint need two slots.

    #[test]
    fn two_simultaneous_roots_get_distinct_slots() {
        let f = program_of(
            4,
            "",
            "    %0 = str \"a\"\n    %1 = str \"b\"\n    %2 = cell\n    %3 = op streq %0 %1\n    ret %3\n",
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 1);
        assert_eq!(plan.max_live, 2);
        assert!(plan.slot_of[0].is_some() && plan.slot_of[1].is_some());
        assert_ne!(plan.slot_of[0], plan.slot_of[1]);
        assert_eq!(plan.num_slots, 2);
    }

    // -----------------------------------------------------------------------
    // #31: non-overlapping safepoint-live roots reuse one slot.

    #[test]
    fn non_overlapping_roots_reuse_one_slot() {
        // %0/%1 are live across the first strcat and die immediately after;
        // %3/%4 are defined and die only around the second, much later.
        let f = program_of(
            6,
            "",
            concat!(
                "    %0 = str \"a\"\n",
                "    %1 = str \"z\"\n",
                "    %2 = op strcat %0 %1\n",
                "    %3 = str \"b\"\n",
                "    %4 = str \"c\"\n",
                "    %5 = op strcat %3 %4\n",
                "    ret %5\n",
            ),
        );
        let plan = plan(&f);
        assert!(
            plan.num_slots < plan.root_candidates,
            "some slot must be reused: {} candidates, {} slots",
            plan.root_candidates,
            plan.num_slots
        );
    }

    // -----------------------------------------------------------------------
    // #32: branches that separately need a root, never simultaneously, may
    // reuse one slot. Both branches define the SAME join register (%2),
    // exactly the "if-join shared result register" pattern nir.rs documents
    // (Function::raw_regs's doc comment) -- not two different registers
    // that happen to both be dead by the join, which is a different (also
    // valid, see `non_overlapping_roots_reuse_one_slot`) case.

    #[test]
    fn branch_local_roots_do_not_interfere() {
        let f = parse_one(concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=4 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = bool true\n",
            "    br %0 L0 L1\n",
            "  label L0\n",
            "    %1 = str \"a\"\n",
            "    %2 = op strcat %1 %1\n",
            "    jump L2\n",
            "  label L1\n",
            "    %3 = str \"b\"\n",
            "    %2 = op strcat %3 %3\n",
            "    jump L2\n",
            "  label L2\n",
            "    ret %2\n",
            "end\n",
        ));
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 2);
        assert_eq!(plan.max_live, 1);
        // %1 and %3 never co-occur at any single safepoint: they may share.
        assert_eq!(plan.slot_of[1], plan.slot_of[3]);
        assert!(plan.slot_of[1].is_some());
    }

    // -----------------------------------------------------------------------
    // #33: a managed value carried across a loop containing a MayGc op stays
    // rooted every iteration.

    #[test]
    fn loop_carried_root_stays_rooted() {
        let f = parse_with_one_arg(
            "    %0 = str \"seed\"\n",
            concat!(
                "func 1 \"loop\" params=1 env=0 regs=3 pnames=\"acc\" captures=0 rawregs=\"\"\n",
                "  label L0\n",
                "    %1 = str \"x\"\n",
                "    %2 = op strcat %0 %1\n",
                "    tail %2\n",
                "end\n",
            ),
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 1);
        // %0 (the carried accumulator) and %1 (this iteration's fresh
        // temporary) are both operands of the strcat, so both are live-in
        // there on every pass through the loop, by construction of the
        // fixpoint -- and since they always co-occur, they can never share
        // a slot.
        assert_eq!(plan.max_live, 2);
        assert!(plan.slot_of[0].is_some());
        assert!(plan.slot_of[1].is_some());
        assert_ne!(plan.slot_of[0], plan.slot_of[1]);
    }

    // -----------------------------------------------------------------------
    // #34: a value live on the normal path but dead on an error-terminating
    // path is not kept rooted past where it actually dies.

    #[test]
    fn error_path_does_not_extend_liveness() {
        let f = parse_with_one_arg(
            "    %0 = str \"seed\"\n",
            concat!(
                "func 1 \"f\" params=1 env=0 regs=3 pnames=\"x\" captures=0 rawregs=\"\"\n",
                "    %1 = bool true\n",
                "    br %1 L0 L1\n",
                "  label L0\n",
                "    %2 = op strcat %0 %0\n",
                "    ret %2\n",
                "  label L1\n",
                "    raise BUG \"unreachable\"\n",
                "end\n",
            ),
        );
        let plan = plan(&f);
        assert_eq!(plan.safepoints, 1);
        assert_eq!(plan.max_live, 1);
        assert!(plan.slot_of[0].is_some());
    }

    // -----------------------------------------------------------------------
    // Determinism (#49): re-running the analysis on the same function
    // produces the same slot assignment.

    #[test]
    fn assignment_is_deterministic() {
        let f = parse_one(concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=6 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = str \"a\"\n    %1 = str \"b\"\n    %2 = op strcat %0 %1\n",
            "    %3 = str \"c\"\n    %4 = str \"d\"\n    %5 = op strcat %3 %4\n",
            "    ret %5\n",
            "end\n",
        ));
        let a = plan(&f).slot_of;
        let b = plan(&f).slot_of;
        assert_eq!(a, b);
    }

    // -----------------------------------------------------------------------
    // A direct Botlish call is conservatively a safepoint even though its
    // own operands never touch an allocating helper directly (#9).

    #[test]
    fn direct_call_is_a_conservative_safepoint() {
        let program = parse_program(concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = call 1\n",
            "    ret %0\n",
            "end\n",
            "func 1 \"f\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = unit\n",
            "    ret %0\n",
            "end\n",
        ));
        let plan = plan(&program.functions[0]);
        assert_eq!(plan.safepoints, 1);
        assert_eq!(plan.max_live, 0, "the call has no argument and its result is only defined after it");
    }

    // -----------------------------------------------------------------------
    // fib<int>'s actual shape (see NATIVE-AUDIT.md/tests/native.test): two
    // non-tail recursive calls whose results feed a final `+`, which is
    // itself conservatively a safepoint too (IAdd's BigInt fallback may
    // allocate). 17 registers, 6 raw, but only 2 shadow slots: %9 (boxed
    // n-1, the first call's own argument) shares a slot with %10 (the first
    // call's result, dead once the final `+` has consumed it), and %14/%15
    // (boxed n-2 and the second call's result) share the other slot --
    // never with %9/%10, since %10 and %15 are both live, simultaneously, at
    // the final `+`.

    #[test]
    fn fib_shape_needs_two_slots() {
        let f = parse_with_one_arg(
            "    %0 = int 5\n",
            concat!(
                "func 1 \"fib\" params=1 env=0 regs=17 pnames=\"n\" captures=0 rawregs=\"2 5 7 8 12 13\"\n",
                "    %1 = int 2\n",
                "    %2 = rawint 2\n",
                "    %3 = op ilt %0 %1\n",
                "    br %3 L0 L1\n",
                "  label L0\n",
                "    %4 = move %0\n",
                "    jump L2\n",
                "  label L1\n",
                "    %5 = op runbox %0\n",
                "    %6 = int 1\n",
                "    %7 = rawint 1\n",
                "    %8 = op risub %5 %7\n",
                "    %9 = op rbox %8\n",
                "    %10 = call 1 %9\n",
                "    %11 = int 2\n",
                "    %12 = rawint 2\n",
                "    %13 = op risub %5 %12\n",
                "    %14 = op rbox %13\n",
                "    %15 = call 1 %14\n",
                "    %16 = op iadd %10 %15\n",
                "    %4 = move %16\n",
                "    jump L2\n",
                "  label L2\n",
                "    ret %4\n",
                "end\n",
            ),
        );
        let plan = plan(&f);
        // Two recursive calls, plus the final `+` that combines their
        // results (conservatively a safepoint too: see this test's doc).
        assert_eq!(plan.safepoints, 3);
        assert_eq!(plan.max_live, 2);
        assert_eq!(plan.root_candidates, 4, "regs 9, 10, 14, 15");
        assert_eq!(plan.num_slots, 2, "9 shares a slot with 10, and 14 shares a slot with 15");
        for r in [0u32, 1, 3, 4, 6, 11, 16] {
            assert!(plan.slot_of[r as usize].is_none(), "reg {r} should need no slot");
        }
        for r in [2u32, 5, 7, 8, 12, 13] {
            assert!(plan.slot_of[r as usize].is_none(), "raw reg {r} should need no slot");
        }
        assert!(
            [9u32, 10, 14, 15].iter().all(|&r| plan.slot_of[r as usize].is_some()),
            "9, 10, 14, 15 must all be rooted: {:?}",
            plan.slot_of
        );
        // %10 and %15 are simultaneously live at the final `+`, so whatever
        // they are colored, they must differ; %9 (dead once the first call
        // returns) is free to reuse whichever of the two slots %10 does not
        // end up on, and likewise %14 with %15's slot.
        assert_ne!(plan.slot_of[10], plan.slot_of[15]);
        assert_eq!(plan.slot_of[9], plan.slot_of[10]);
        assert_eq!(plan.slot_of[14], plan.slot_of[15]);
    }
}
