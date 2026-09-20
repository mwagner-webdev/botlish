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
use std::collections::{BTreeMap, HashSet};
use std::fmt::Write as _;

/// Where a function's physical root slots (`RootPlan::slot_of`/`num_slots`)
/// actually live: this is a storage-location decision made *after* F3's own
/// coloring, never a change to the coloring/liveness itself.
///
/// * `NativeFrame`: the physical slots live in a Cranelift-managed stack
///   slot inside this function's own native frame (rbp/rsp-relative).
///   `plan`'s NATIVE_FRAME_SUPPORTED argument selects one of two ways the
///   collector discovers these slots (see that argument's doc and
///   codegen::clif's prologue for the actual emitted sequences):
///
///     - on the x86-64 native-stack-map path (NATIVE_FRAME_SUPPORTED true):
///       every such function, called or not, recursive or not, qualifies.
///       Its slots are discovered by the collector walking the machine
///       call stack's rbp chain and consulting per-safepoint stack-map
///       metadata (`RootPlan::safepoint_slots`, runtime/framewalk.rs) --
///       no publish/restore of any kind is emitted for them.
///     - on the fallback path (NATIVE_FRAME_SUPPORTED false, e.g. a
///       non-x86-64 host where the frame-walker is not implemented): only
///       a function with no Botlish call qualifies (`has_botlish_call`),
///       exactly the original, narrower rule, published to the collector
///       through `Vm::native_roots_ptr`/`_len` (at most one such
///       registration can ever be active along any single call chain,
///       since a function *with* a call is never eligible here).
///
/// * `RuntimeStack`: the shared `Vm::shadow` array indexed via
///   `ss_top`/`ss_limit`, scanned as one contiguous region. Used as
///   physical *root storage* only on the fallback path, for a function
///   that contains a Botlish call (mirrors the original, pre-stack-map
///   mechanism exactly). On the native-stack-map path this storage is
///   never used for roots at all -- see `RootPlan::depth_reservation` for
///   the unrelated, narrower way a call-containing function still touches
///   this same shared array (a one-slot recursion-depth token, holding no
///   Value and needing no stack-map entry).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RootStorage {
    NativeFrame,
    RuntimeStack,
}

/// Whether F contains a Botlish call (`Call`/`CallEnv`/`CallMulti`/
/// `CallEnvMulti`/`CallValue` -- a dynamically dispatched call is folded
/// into `CallValue`, already covered). `Tail`/`TailEnv` (a self back-edge,
/// codegen::clif's own doc) is deliberately not one of these: it is a CFG
/// jump to this same frame's entry block, never a machine `call`, so it
/// neither grows the native call stack nor creates a second frame.
///
/// Two independent things key off this predicate (see `RootPlan`'s
/// `storage`/`depth_reservation` docs): on the fallback (non-native-stack-
/// map) path it is exactly the old `RootStorage::NativeFrame` eligibility
/// rule; on every path it is exactly `RootPlan::depth_reservation` --
/// whether this function's own recursion depth still needs the shared
/// shadow array's bound, decoupled from wherever its actual GC roots live
/// (this milestone's own goal: see this module's doc and codegen::clif's).
fn has_botlish_call(f: &Function) -> bool {
    f.body.iter().any(|inst| {
        matches!(
            inst,
            Inst::Call { .. }
                | Inst::CallEnv { .. }
                | Inst::CallMulti { .. }
                | Inst::CallEnvMulti { .. }
                | Inst::CallValue { .. }
        )
    })
}

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
    /// F3b (per-physical-slot definite-initialization): indexed by physical
    /// slot 0..num_slots, whether codegen::clif's prologue must zero that
    /// slot at frame entry. `true` means some reachable GC safepoint is not
    /// dominated, on every path from frame publication, by a store of a
    /// valid Value into that slot, so the slot could otherwise reach a
    /// safepoint holding leftover machine data; `false` means every
    /// reachable safepoint is provably preceded by such a store on every
    /// path, so the entry zero is redundant (see `entry_zero_slots`, this
    /// module's own analysis, and clif.rs's prologue). This is a strictly
    /// separate fact from `num_slots`/`slot_of` -- F3's own physical-slot
    /// allocation is unchanged by it (milestone brief items 1, 34).
    pub entry_zero: Vec<bool>,
    /// Where these physical slots live: `RootStorage`'s own doc -- a
    /// storage-location decision that never revisits
    /// `slot_of`/`num_slots`/`entry_zero` above (this module's own doc: "a
    /// storage-location change, not a new root allocator").
    pub storage: RootStorage,
    /// Whether this function's own recursion depth still needs the shared
    /// `RuntimeStack` array's bound: exactly `has_botlish_call(f)`,
    /// decoupled from `storage` (this milestone's own goal -- see this
    /// module's and codegen::clif's doc). When true, codegen::clif emits a
    /// minimal one-slot bump/limit-check/restore against that shared array
    /// purely to bound native recursion depth, storing no Value there and
    /// needing no stack-map entry, *independent* of wherever this
    /// function's actual GC roots live (`storage`/`safepoint_slots`).
    pub depth_reservation: bool,
    /// `RootStorage::NativeFrame` on the native-stack-map path only: for
    /// each safepoint instruction (by its index into `f.body`), the
    /// physical slots (`slot_of`'s values) live *at that specific point* --
    /// a subset of the slots this function ever uses, precise per safepoint
    /// exactly like `entry_zero_slots`'s own per-slot analysis (see this
    /// module's doc, item 4: `Roots(safepoint) = LiveIn(safepoint)`
    /// restricted to non-raw registers, mapped through `slot_of`). Read by
    /// codegen::clif to attach Cranelift `UserStackMapEntry`s to the actual
    /// machine call at each safepoint (`mark_safepoint`). Empty (no entry
    /// for any index) whenever `storage` is not `NativeFrame` on this path,
    /// or (the fallback path) when native stack maps are not in use at all.
    pub safepoint_slots: BTreeMap<usize, Vec<u32>>,
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
    /// Roots(safepoint) for every safepoint instruction (order matches
    /// `safepoint_index`, not necessarily `f.body` order -- see `analyze`'s
    /// own second pass -- but every consumer below is order-independent).
    safepoint_roots: Vec<Vec<Reg>>,
    /// The `f.body` index of each entry of `safepoint_roots`, same length,
    /// same order: lets `plan` build `RootPlan::safepoint_slots` (keyed by
    /// body index, for codegen::clif's per-instruction lookup) without
    /// re-walking the CFG.
    safepoint_index: Vec<usize>,
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
    let mut safepoint_index = Vec::new();
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
                safepoint_index.push(idx);
            }
            live = live_in_inst;
        }
    }
    Liveness { safepoint_roots, safepoint_index }
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

/// F3b: per-physical-slot definite-initialization dataflow, run after F3's
/// own CFG/liveness/coloring (`slot_of`, already colored onto physical
/// slots 0..NUM_SLOTS -- this function does not revisit *whether* a
/// register is rooted or *which* physical slot it shares, only *whether
/// that physical slot's prologue zero is still needed*: see this module's
/// doc and the milestone brief's item 5, "analyze physical slots, not NIR
/// registers").
///
/// Two-point per-slot lattice, UNINITIALIZED < INITIALIZED: this is a
/// forward "must" dataflow, the mirror image of `analyze`'s backward "may"
/// liveness. A definition of a register `slot_of` colors to physical slot S
/// (`def_use`'s `defs`, restricted to slotted registers -- exactly the
/// registers `codegen::clif::Translator::def` actually stores to the shadow
/// stack, never `def_raw`'s, which are never candidates in the first place)
/// is a one-way UNINITIALIZED -> INITIALIZED transition for S, and is never
/// reversed: a physical slot's logical root going dead does not make the
/// slot's *machine* contents invalid again (milestone brief item 22 -- a
/// stale but valid Value is still GC-safe). CFG joins meet with logical AND
/// ("definitely initialized" means "on every path reaching this point").
/// Block 0 (the function's own entry, on first arrival -- not a self tail
/// call's back edge to it, see `Cfg::build`'s doc) always contributes a
/// fixed entry state as one of its effective predecessors: every slot a
/// parameter register colors to (codegen::clif's prologue stores every
/// parameter to its slot, unconditionally, right after the zero loop and
/// before the body -- see `entry_zero_slots`'s own `entry_state`) starts
/// INITIALIZED; every other slot starts UNINITIALIZED, since frame
/// publication has stored nothing else into it yet. Since AND with
/// UNINITIALIZED can never become INITIALIZED again, this is simplest
/// expressed by seeding block 0's input at this fixed entry state outright
/// rather than modeling a synthetic entry predecessor.
///
/// At a safepoint, every physical slot the GC could scan while this frame
/// is published is checked against the *input* state to that instruction
/// (before its own def, if it has one, takes effect -- mirrors `analyze`'s
/// own `live_in_inst`, and for the same reason: a call's own destination
/// register is not written until after it returns, i.e. after whatever
/// safepoint inside it already ran). Every physical slot is checked, not
/// only the ones live at that particular safepoint: the runtime scans the
/// whole published shadow-stack region for this frame (`base..base +
/// num_slots*8`, see runtime/heap.rs's and vm.rs's module docs) regardless
/// of which registers happen to be live there, so an uninitialized slot is
/// unsafe to scan even where nothing is nominally "rooted" at that point.
///
/// What counts as a "reachable safepoint" is exactly `is_safepoint` over
/// F's own CFG (unchanged from F3): a call this function makes is itself
/// conservatively a safepoint (module doc, item 2), which already accounts
/// for GC running arbitrarily deep inside a callee -- this frame's own
/// slots cannot change while suspended inside a call, so checking the state
/// immediately before the call instruction is equivalent to checking it at
/// every point GC could actually run during that call. The stack-overflow
/// check and frame-publication store themselves are pure codegen::clif
/// prologue machinery, never NIR instructions, so they are simply outside
/// this CFG and impose no requirement here (milestone brief item 11):
/// nothing before publication can force a slot's entry zero.
fn entry_zero_slots(f: &Function, cfg: &Cfg, slot_of: &[Option<u32>], num_slots: u32) -> Vec<bool> {
    let ns = num_slots as usize;
    let nb = cfg.blocks.len();

    let mut preds: Vec<Vec<usize>> = vec![Vec::new(); nb];
    for (b, s) in cfg.succs.iter().enumerate() {
        for &t in s {
            preds[t].push(b);
        }
    }

    // codegen::clif's prologue stores every parameter into its shadow slot
    // (`Translator::function`'s `self.def(i, v)` loop) immediately after
    // the (now conditional) zero loop and strictly before jumping into the
    // body -- but that store is not an `f.body` instruction, so `def_use`
    // never reports it as a def of register `i`. Without accounting for it
    // here, a parameter that is also a root candidate would look forever
    // UNINITIALIZED to this analysis and force a needless entry zero on
    // every call (a self tail call's own back edge does not have this gap:
    // `Inst::Tail`/`Inst::TailEnv` rebind parameters 0..f.params as
    // ordinary `f.body` defs, already handled by `apply_block` below). This
    // is exactly the real function entry's initial state -- i.e. block 0's
    // input on first arrival, not on a back edge, which is what the
    // `b == 0` case of `block_input` below seeds.
    let mut entry_state = vec![false; ns];
    for i in 0..f.params {
        if let Some(slot) = slot_of[i as usize] {
            entry_state[slot as usize] = true;
        }
    }

    // The state a block's own instructions produce, given INPUT at its
    // first instruction: a "gen" transfer only (see this function's doc --
    // definite initialization is one-way, so there is no "kill").
    let apply_block = |b: usize, input: &[bool]| -> Vec<bool> {
        let (s, e) = cfg.blocks[b];
        let mut state = input.to_vec();
        for idx in s..e {
            let (defs, _uses) = def_use(&f.body[idx], f.params);
            for d in defs {
                if let Some(slot) = slot_of[d as usize] {
                    state[slot as usize] = true;
                }
            }
        }
        state
    };
    // A block's input state: AND of its predecessors' output (block 0 also
    // always ANDs in the implicit entry edge -- ENTRY_STATE, i.e. exactly
    // the parameter-bound slots, everything else UNINITIALIZED -- see this
    // function's doc).
    let block_input = |b: usize, block_out: &[Vec<bool>]| -> Vec<bool> {
        let mut input = if b == 0 { entry_state.clone() } else { vec![true; ns] };
        for &p in &preds[b] {
            for s in 0..ns {
                input[s] &= block_out[p][s];
            }
        }
        input
    };

    // Forward "must" fixpoint: every block starts optimistic (all
    // INITIALIZED, i.e. top of this lattice) and a block's state only ever
    // loses bits as real predecessors are folded in, so this is monotone
    // and bounded exactly like `analyze`'s own backward fixpoint (see its
    // doc); `guard` exists for the same reason as there.
    let mut block_out: Vec<Vec<bool>> = vec![vec![true; ns]; nb];
    let mut guard = 0usize;
    loop {
        guard += 1;
        if guard > (nb + f.body.len()) * 4 + 1000 {
            panic!("root definite-init analysis failed to converge for function {} ({})", f.id, f.name);
        }
        let mut changed = false;
        for b in 0..nb {
            let input = block_input(b, &block_out);
            let out = apply_block(b, &input);
            if out != block_out[b] {
                block_out[b] = out;
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }

    // Second pass, from the converged per-block inputs: walk every block's
    // instructions forward once more, recording at each safepoint any slot
    // not yet definitely INITIALIZED (see this function's doc for why the
    // safepoint instruction's own def, if any, does not yet count).
    let mut needs_zero = vec![false; ns];
    for b in 0..nb {
        let (s, e) = cfg.blocks[b];
        let mut state = block_input(b, &block_out);
        for idx in s..e {
            let inst = &f.body[idx];
            if is_safepoint(inst) {
                for slot in 0..ns {
                    if !state[slot] {
                        needs_zero[slot] = true;
                    }
                }
            }
            let (defs, _uses) = def_use(inst, f.params);
            for d in defs {
                if let Some(slot) = slot_of[d as usize] {
                    state[slot as usize] = true;
                }
            }
        }
    }
    needs_zero
}

/// Computes F's root-allocation plan (see this module's doc).
///
/// NATIVE_FRAME_SUPPORTED: whether the collector can discover
/// `RootStorage::NativeFrame` roots by walking the native machine stack and
/// consulting per-safepoint stack maps (runtime/framewalk.rs) -- true on
/// the primary x86-64 path (codegen::clif passes `module.isa().name() ==
/// "x64"`, the same check `Symbols::direct_helpers` already uses), false on
/// the fallback path where that walker is not implemented and `NativeFrame`
/// keeps its original, narrower meaning (see `RootStorage`'s own doc for
/// both). This is a pure storage/discovery decision: it never changes
/// `slot_of`/`entry_zero`/liveness/coloring above, and on the fallback path
/// it reproduces the pre-stack-map behavior exactly, byte for byte.
pub fn plan(f: &Function, native_frame_supported: bool) -> RootPlan {
    let cfg = Cfg::build(f);
    let liveness = analyze(f, &cfg);
    let (slot_of, colored_slots, root_candidates) = color(f.regs, &liveness.safepoint_roots);
    let max_live = liveness.safepoint_roots.iter().map(Vec::len).max().unwrap_or(0) as u32;
    let depth_reservation = if native_frame_supported { false } else { has_botlish_call(f) };
    // On the primary native-stack-map path the active OS thread stack is the
    // authoritative overflow boundary, so there is no remaining shadow-stack
    // recursion-depth token. Only the legacy fallback path keeps the old
    // RuntimeStack depth reservation. The native-frame root storage decision is
    // otherwise unchanged.
    let storage = if native_frame_supported || !depth_reservation {
        RootStorage::NativeFrame
    } else {
        RootStorage::RuntimeStack
    };
    // At least one slot always for RuntimeStack, so the shared shadow array
    // still bounds native recursion depth for a function with zero roots
    // (see RootPlan's doc and codegen::clif's prologue) -- this is the
    // fallback path's combined depth+storage floor, unchanged. A
    // NativeFrame function needs no such floor regardless of calls: on the
    // native-stack-map path, recursion depth is bounded by
    // `depth_reservation`'s own, wholly separate one-slot reservation
    // instead (codegen::clif); on the fallback path, NativeFrame implies no
    // Botlish call at all (`!depth_reservation` above), so it cannot
    // recurse through one either.
    let num_slots = match storage {
        RootStorage::RuntimeStack => colored_slots.max(1),
        RootStorage::NativeFrame => colored_slots,
    };
    let entry_zero = entry_zero_slots(f, &cfg, &slot_of, num_slots);
    let mut safepoint_slots = BTreeMap::new();
    if storage == RootStorage::NativeFrame {
        for (&idx, roots) in liveness.safepoint_index.iter().zip(liveness.safepoint_roots.iter()) {
            let mut slots: Vec<u32> = roots.iter().filter_map(|&r| slot_of[r as usize]).collect();
            slots.sort_unstable();
            slots.dedup();
            safepoint_slots.insert(idx, slots);
        }
    }
    RootPlan {
        slot_of,
        num_slots,
        safepoints: liveness.safepoint_roots.len() as u32,
        root_candidates,
        max_live,
        storage,
        depth_reservation,
        safepoint_slots,
        entry_zero,
    }
}

/// A compact, per-function root report for PROGRAM (milestone brief item 48:
/// "function fib<int>\nNIR regs: 17\nraw regs: 6\nsafepoints: 4\nroot
/// candidates: 7\nmax live roots: 3\nshadow slots: 3\nentry zero slots: 3"),
/// read by `native/explain-native.tcl` (as `roots.txt`) and by
/// `botlish-native roots FILE.nir` directly. Purely a rendering of
/// `RootPlan`/`Function`'s own fields -- no analysis happens here.
/// `shadow slots` (F3's physical-slot count) and `entry zero slots` (F3b's
/// count of those physical slots that still need a prologue zero) are
/// deliberately separate numbers (milestone brief item 34): the first is
/// unaffected by this module's definite-initialization analysis, the
/// second is entirely its output.
pub fn report(program: &Program) -> String {
    // Reflects what this host's actual JIT compile will decide
    // (codegen::clif passes the same `isa.name() == "x64"` check): this CLI
    // parses and analyzes only, never compiles (main.rs's own doc), so
    // there is no `Module`/ISA here to ask directly.
    let native_frame_supported = cfg!(target_arch = "x86_64");
    let mut out = String::new();
    for f in &program.functions {
        let plan = plan(f, native_frame_supported);
        let (regs, raw) = RootPlan::counts(f);
        writeln!(out, "function {} \"{}\"", f.id, f.name).unwrap();
        writeln!(out, "  NIR regs: {regs}").unwrap();
        writeln!(out, "  raw regs: {raw}").unwrap();
        writeln!(out, "  managed-capable regs: {}", regs - raw).unwrap();
        writeln!(out, "  safepoints: {}", plan.safepoints).unwrap();
        writeln!(out, "  root candidates: {}", plan.root_candidates).unwrap();
        writeln!(out, "  max live roots: {}", plan.max_live).unwrap();
        writeln!(out, "  shadow slots: {}", plan.num_slots).unwrap();
        writeln!(out, "  entry zero slots: {}", plan.entry_zero.iter().filter(|z| **z).count()).unwrap();
        writeln!(out, "  depth reservation: {}", if plan.depth_reservation { "yes" } else { "no" }).unwrap();
        writeln!(
            out,
            "  storage: {}",
            match plan.storage {
                RootStorage::NativeFrame => "native frame",
                RootStorage::RuntimeStack => "runtime stack",
            }
        )
        .unwrap();
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
        let plan = plan(&f, true);
        assert_eq!(plan.safepoints, 0);
        assert_eq!(plan.root_candidates, 0);
        // This function also makes no Botlish call, so it is RootStorage::
        // NativeFrame (see that test group below): no recursion-depth floor
        // applies, so num_slots is a true zero here, not the RuntimeStack
        // floor of 1 (`any_botlish_call_forces_runtime_stack` covers that
        // floor directly, for a function that DOES call).
        assert_eq!(plan.storage, RootStorage::NativeFrame);
        assert_eq!(plan.num_slots, 0, "zero value slots, and no depth-bound floor: this function cannot recurse");
        assert!(plan.slot_of.iter().all(Option::is_none));
    }

    // -----------------------------------------------------------------------
    // #28: tagged intermediates that die before any safepoint need no slot.
    // `imod`'s helper never allocates (ops.rs's table), so this function has
    // no safepoint at all despite every register being tagged.

    #[test]
    fn tagged_dead_before_safepoint_needs_no_slot() {
        let f = program_of(3, "", "    %0 = int 7\n    %1 = int 2\n    %2 = op imod %0 %1\n    ret %2\n");
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let plan = plan(&f, true);
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
        let a = plan(&f, true).slot_of;
        let b = plan(&f, true).slot_of;
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
        let plan = plan(&program.functions[0], true);
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
        let plan = plan(&f, true);
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

    // -------------------------------------------------------------------
    // F3b: per-physical-slot definite-initialization (RootPlan::entry_zero).

    /// A parameter that is itself a root candidate needs no entry zero:
    /// codegen::clif's prologue stores every parameter into its slot
    /// (unconditionally, right after the zero loop, before the body ever
    /// runs) even though that store is not an `f.body` instruction at all
    /// -- the gap this test guards against is `entry_zero_slots` mistaking
    /// "no `f.body` def" for "never initialized" and demanding a needless
    /// zero on every call.
    #[test]
    fn parameter_root_needs_no_entry_zero() {
        let f = parse_with_one_arg(
            "    %0 = str \"seed\"\n",
            concat!(
                "func 1 \"f\" params=1 env=0 regs=3 pnames=\"p\" captures=0 rawregs=\"\"\n",
                "    %1 = str \"x\"\n",
                "    %2 = op strcat %0 %1\n",
                "    ret %2\n",
                "end\n",
            ),
        );
        let plan = plan(&f, true);
        assert_eq!(plan.safepoints, 1);
        let slot = plan.slot_of[0].expect("the parameter is live across the strcat");
        assert!(!plan.entry_zero[slot as usize], "the prologue's own parameter store already initializes it");
    }

    // -------------------------------------------------------------------
    // Milestone brief item 20 / the sum-refined shape: a branch that
    // returns before any safepoint must not force the other branch's
    // (safepoint-reaching) slot to keep its entry zero.

    #[test]
    fn early_return_branch_without_safepoint_does_not_force_entry_zero() {
        let f = parse_with_one_arg(
            "    %0 = str \"seed\"\n",
            concat!(
                "func 1 \"f\" params=1 env=0 regs=5 pnames=\"p\" captures=0 rawregs=\"\"\n",
                "    %1 = bool true\n",
                "    br %1 L0 L1\n",
                "  label L0\n",
                "    ret %0\n",
                "  label L1\n",
                "    %2 = str \"x\"\n",
                "    %3 = op strcat %0 %2\n",
                "    ret %3\n",
                "end\n",
            ),
        );
        let plan = plan(&f, true);
        assert_eq!(plan.safepoints, 1);
        let slot0 = plan.slot_of[0].expect("the parameter is live across the strcat on the L1 path");
        let slot2 = plan.slot_of[2].expect("the fresh string is live across the strcat too");
        assert!(!plan.entry_zero[slot0 as usize], "L0 returns before any safepoint; L1 stores %0's slot at entry");
        assert!(!plan.entry_zero[slot2 as usize], "%2 is stored before the only safepoint on the only path to it");
    }

    // -------------------------------------------------------------------
    // Milestone brief item 18: a safepoint that can run before a candidate
    // register's very first definition must keep that slot's entry zero,
    // even though the same slot is safely reinitialized before a *later*
    // safepoint.

    #[test]
    fn safepoint_before_first_definition_forces_entry_zero() {
        let program = parse_program(concat!(
            "nir 1\n\n",
            "func 0 \"<program>\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = call 1\n",
            "    ret %0\n",
            "end\n",
            "func 1 \"f\" params=0 env=0 regs=3 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = call 2\n", // safepoint #1: %1 does not exist yet on this path.
            "    %1 = str \"a\"\n",
            "    %2 = call 3 %1\n", // safepoint #2: %1 is live-in here.
            "    ret %2\n",
            "end\n",
            "func 2 \"zero-arg\" params=0 env=0 regs=1 pnames=\"\" captures=0 rawregs=\"\"\n",
            "    %0 = unit\n",
            "    ret %0\n",
            "end\n",
            "func 3 \"one-arg\" params=1 env=0 regs=1 pnames=\"x\" captures=0 rawregs=\"\"\n",
            "    ret %0\n",
            "end\n",
        ));
        let plan = plan(&program.functions[1], true);
        assert_eq!(plan.safepoints, 2);
        let slot = plan.slot_of[1].expect("%1 is live across the second call");
        assert!(plan.entry_zero[slot as usize], "the first call can scan %1's slot before %1 is ever defined");
    }

    // -------------------------------------------------------------------
    // Milestone brief item 19: a slot only conditionally defined before a
    // safepoint must stay conservatively zeroed -- the false branch reaches
    // the safepoint without ever storing to it.

    #[test]
    fn conditionally_defined_root_before_safepoint_forces_entry_zero() {
        let f = parse_with_one_arg(
            "    %0 = bool true\n",
            concat!(
                "func 1 \"f\" params=1 env=0 regs=5 pnames=\"cond\" captures=0 rawregs=\"\"\n",
                "    br %0 L0 L1\n",
                "  label L0\n",
                "    %1 = str \"a\"\n",
                "    jump L2\n",
                "  label L1\n",
                "    jump L2\n",
                "  label L2\n",
                "    %3 = call 1 %1\n", // safepoint: %1 is live-in, but only L0 defines it.
                "    ret %3\n",
                "end\n",
            ),
        );
        let plan = plan(&f, true);
        assert_eq!(plan.safepoints, 1);
        let slot = plan.slot_of[1].expect("%1 is live across the call on the L2 join");
        assert!(plan.entry_zero[slot as usize], "the L1 (false) branch reaches the safepoint without defining %1");
    }

    // -------------------------------------------------------------------
    // Milestone brief item 21: two non-overlapping virtual roots colored
    // onto the very same physical slot (see `non_overlapping_roots_reuse_
    // one_slot`, F3's own test) must each be judged independently against
    // that one physical slot, not against their own distinct register
    // identity -- a later register reusing an earlier one's slot is not
    // itself a reason to need an entry zero.

    #[test]
    fn colored_slot_reuse_does_not_force_bogus_entry_zero() {
        let f = program_of(
            6,
            "",
            concat!(
                "    %0 = str \"a\"\n",
                "    %1 = str \"z\"\n",
                "    %2 = op strcat %0 %1\n", // safepoint #1: roots {0, 1}.
                "    %3 = str \"b\"\n",
                "    %4 = str \"c\"\n",
                "    %5 = op strcat %3 %4\n", // safepoint #2: roots {3, 4}, never live with {0, 1}.
                "    ret %5\n",
            ),
        );
        let plan = plan(&f, true);
        assert!(plan.num_slots < plan.root_candidates, "some slot must be reused (see the sibling F3 test)");
        assert_eq!(plan.slot_of[3], plan.slot_of[0], "reg 3 should reuse reg 0's now-dead slot");
        for slot in 0..plan.num_slots {
            assert!(!plan.entry_zero[slot as usize], "every slot is stored to before its own safepoint either way");
        }
    }

    // -------------------------------------------------------------------
    // Milestone brief item 24: a loop-carried root (see `loop_carried_
    // root_stays_rooted`, F3's own test) converges to "no entry zero" --
    // the parameter is bound before the loop's first iteration and rebound
    // by the `tail` at the end of every later one, always before the one
    // safepoint inside the loop body.

    #[test]
    fn loop_carried_root_needs_no_entry_zero() {
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
        let plan = plan(&f, true);
        assert_eq!(plan.safepoints, 1);
        let slot = plan.slot_of[0].expect("the carried accumulator is live across the strcat");
        assert!(!plan.entry_zero[slot as usize], "bound by the prologue, then rebound by every `tail`, before the loop's one safepoint");
    }

    // -------------------------------------------------------------------
    // RootStorage: native-stack-slot eligibility (native-stack-authoritative
    // roadmap). `raw_only_needs_no_slots` above already covers "no roots,
    // no calls -> NativeFrame with zero physical slots" directly (on both
    // paths, since a no-call function is NativeFrame either way).

    /// A root candidate whose only safepoint is an internal (non-Botlish)
    /// allocating op, with no Botlish call anywhere in the function: always
    /// eligible for `NativeFrame` (both paths), with exactly the physical
    /// slots F3's own coloring already decided (unaffected by the storage
    /// decision), and no depth reservation (nothing here can recurse).
    #[test]
    fn root_with_no_botlish_calls_is_native_frame() {
        let f = program_of(
            3,
            "",
            "    %0 = str \"a\"\n    %1 = cell\n    %2 = op streq %0 %0\n    ret %2\n",
        );
        for native_frame_supported in [true, false] {
            let plan = plan(&f, native_frame_supported);
            assert_eq!(plan.storage, RootStorage::NativeFrame);
            assert_eq!(plan.num_slots, 1);
            assert!(plan.slot_of[0].is_some());
            assert!(!plan.depth_reservation);
        }
    }

    /// A loop-carried root reached purely by a self `tail` back-edge (no
    /// Botlish call at all): also `NativeFrame` on both paths -- a self
    /// tail call is a CFG jump within this same frame, never a machine
    /// `call` (codegen::clif's own doc), so it cannot grow the native call
    /// stack and needs no recursion-depth bound.
    #[test]
    fn tail_self_loop_alone_is_native_frame() {
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
        assert_eq!(plan(&f, true).storage, RootStorage::NativeFrame);
        assert_eq!(plan(&f, false).storage, RootStorage::NativeFrame);
    }

    /// A direct Botlish call anywhere in the function always sets
    /// `depth_reservation` (fib<int>'s own shape, `fib_shape_needs_two_
    /// slots`, is the flagship instance: two recursive calls with genuine
    /// cross-call roots) -- but, on the native-stack-map path, no longer
    /// forces `RuntimeStack` *storage*: the frame-walker can discover a
    /// `NativeFrame` function's roots regardless of how many further calls
    /// nest on top of it (this milestone's own goal). Only the fallback
    /// path (no frame-walker) keeps the old, narrower rule.
    #[test]
    fn any_botlish_call_sets_depth_reservation_but_only_fallback_forces_runtime_stack() {
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
        let native = plan(&program.functions[0], true);
        assert_eq!(native.storage, RootStorage::NativeFrame, "the stack-map path discovers roots across calls too");
        assert!(!native.depth_reservation, "primary x86-64/Linux path uses the native stack for overflow, not the shadow-depth token");
        assert_eq!(native.num_slots, 0, "no RuntimeStack floor: NativeFrame storage needs none");

        let fallback = plan(&program.functions[0], false);
        assert_eq!(fallback.storage, RootStorage::RuntimeStack, "no frame-walker: the old, narrower rule applies");
        assert!(fallback.depth_reservation);
        assert_eq!(fallback.num_slots, 1, "RuntimeStack's own recursion-depth floor, unchanged on the fallback path");
    }

    /// fib<int>'s own shape (`fib_shape_needs_two_slots`): two recursive
    /// calls with cross-call roots. On the native-stack-map path it now
    /// gets `NativeFrame` storage (its two cross-call roots become
    /// discoverable through stack maps) while still needing the depth
    /// reservation (it can genuinely recurse); the fallback path keeps the
    /// original `RuntimeStack` storage, unchanged.
    #[test]
    fn fib_shape_moves_to_native_frame_on_stack_map_path_stays_on_fallback() {
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
        let native = plan(&f, true);
        assert_eq!(native.storage, RootStorage::NativeFrame);
        assert!(!native.depth_reservation, "primary x86-64/Linux stack overflow protection is native-stack-based");
        assert_eq!(native.num_slots, 2, "same F3 coloring as fib_shape_needs_two_slots, unaffected by storage");
        // See fib_shape_needs_two_slots's own breakdown: %9/%10 share one
        // physical slot (call it A), %14/%15 the other (B). Body indices
        // (0-based, labels count too): %10 = call 1 %9 is instruction 13
        // (live-in: just %9's slot, A); %15 = call 1 %14 is instruction 18
        // (live-in: %10, carried across for the final `+`, on slot A, and
        // %14, this call's own argument, on slot B); the final %16 = op
        // iadd %10 %15 is instruction 19 (live-in: %10 on A, %15 on B).
        let call1_slots = native.safepoint_slots.get(&13).expect("the first recursive call is a safepoint");
        assert_eq!(call1_slots.len(), 1, "only %9 is live-in at the first call");
        let slot_a = call1_slots[0];
        let call2_slots = native.safepoint_slots.get(&18).expect("the second recursive call is a safepoint");
        assert_eq!(call2_slots.len(), 2, "%10 (carried) and %14 (this call's own arg) are both live-in");
        assert!(call2_slots.contains(&slot_a), "%10 still shares %9's slot A");
        let slot_b = *call2_slots.iter().find(|&&s| s != slot_a).unwrap();
        let add_slots = native.safepoint_slots.get(&19).expect("the final `+` is a safepoint");
        assert_eq!(add_slots, &vec![slot_a.min(slot_b), slot_a.max(slot_b)], "both call results are live at the final +");

        let fallback = plan(&f, false);
        assert_eq!(fallback.storage, RootStorage::RuntimeStack);
        assert!(fallback.safepoint_slots.is_empty(), "safepoint_slots is only populated for NativeFrame storage");
    }
}
