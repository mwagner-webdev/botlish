//! Windows x64 unwind information for Cranelift's code (WINDOWS-X86-64-
//! MILESTONE-3.md): the `UNWIND_INFO` that tells Windows' unwinder
//! (`RtlVirtualUnwind`, and through it exception dispatch, debuggers,
//! profilers and ETW) how to undo one Botlish function's prologue. The AOT
//! object carries it in `.xdata` with a `.pdata` entry per function
//! (codegen::emit_object); the JIT registers the same bytes with
//! `RtlAddFunctionTable` (codegen::jitunwind).
//!
//! # What Cranelift computes, and what this module encodes
//!
//! Cranelift describes every prologue it emits as a list of
//! `isa::unwind::UnwindInst`s (`MachBufferFinalized::unwind_info`): where the
//! frame pointer is pushed, where the frame is defined and how far below the
//! frame pointer the clobber area starts, and which callee-saved register is
//! stored where in it. That description is the authority here; nothing below
//! invents a frame layout. Cranelift 0.135.2 also encodes it as Windows
//! `UNWIND_INFO` itself (`isa::unwind::winx64::UnwindInfo::emit`), but that
//! encoding is wrong for every function that saves a callee-saved register
//! (`cranelift_windows_encoding_defect_still_present`):
//!
//!   * the header's frame offset is written as `offset_downward_to_clobbers
//!     << 4` in a byte, a byte count where the format wants a count of 16
//!     bytes: the clobber area's size is a multiple of 16, so the field is
//!     always 0 and the unwinder's frame base is the frame pointer itself;
//!   * a general register's save offset is divided by 16, where
//!     `UWOP_SAVE_NONVOL` scales by 8;
//!
//! so Windows restores RSI, RDI, RBX and R12-R15 from the wrong slots (the
//! caller's saved RBP among them), while RIP, RSP and RBP, which come from
//! the frame pointer, happen to be right. This module encodes the same
//! `UnwindInst`s again, correctly.
//!
//! # The prologue, as Windows is told it
//!
//! Cranelift's x86-64 prologue (`isa::x64::abi`, every function: the setup
//! area is unconditional) is
//!
//! ```text
//!   0: push rbp                       PushFrameRegs at 1
//!   1: mov  rbp, rsp                  (48 89 e5)
//!   4: [stack probes]                 inline probestack (codegen::stack_probes)
//!      sub  rsp, FRAME                FRAME = fixed storage + clobbers + outgoing arguments
//!      [DefineNewFrame { offset_downward_to_clobbers: CLOBBERS }]
//!      mov  [rsp + X + OFF], REG      SaveReg { clobber_offset: OFF, REG }, each
//! ```
//!
//! with the clobbered callee-saved registers at `rbp - CLOBBERS + OFF`. The
//! Windows format cannot say that directly: a register's save offset is
//! unsigned and counts up from the *establisher frame*, `FP - 16 *
//! FrameOffset`, so the frame base must lie at or below the clobber area,
//! while Cranelift sets FP above it. So the frame is described as the
//! equivalent prologue Windows' own compilers emit:
//!
//! ```text
//!   push rbp                          UWOP_PUSH_NONVOL RBP    at 1
//!   sub  rsp, CLOBBERS                UWOP_ALLOC CLOBBERS     at 4
//!   lea  rbp, [rsp + CLOBBERS]        UWOP_SET_FPREG          at 4, FrameOffset CLOBBERS / 16
//!   mov  [rsp + OFF], REG             UWOP_SAVE_NONVOL REG, OFF / 8 (UWOP_SAVE_XMM128, OFF / 16)
//! ```
//!
//! From offset 4 on, the frame pointer is fixed for the rest of the function
//! (through the probes, the allocation, the body and the epilogue up to its
//! `pop rbp`), and Windows' unwinder computes everything from it: the
//! establisher frame `rbp - CLOBBERS` is where the saves are, `UWOP_SET_FPREG`
//! sets RSP to it, the allocation code adds CLOBBERS back to reach the
//! pushed RBP, and the pushed RBP and the return address follow. The real
//! RSP between offsets 4 and the end of the prologue (probes moving it, the
//! allocation) is never read. Before offset 4 only the push applies, at
//! offset 0 nothing. In the epilogue (`mov rsp, rbp; pop rbp; ret`, after
//! the clobbers are reloaded and `add rsp, FRAME`) the unwinder recognizes
//! `pop rbp; ret` and `ret` and simulates them; before that, the frame
//! pointer still holds and the save slots still hold what the prologue
//! stored. So every instruction boundary of the function unwinds exactly.
//!
//! Every assumption above is checked, never taken: the push and the move at
//! offsets 0 and 1 (the bytes themselves), the one frame definition and its
//! offsets, the clobber area's size (a multiple of 16, at most 240: the
//! format's limit), each save's alignment and place in the clobber area, and
//! every code offset fitting a byte. A prologue of another shape -- a future
//! Cranelift's -- is an error (`NATIVE CODEGEN`), never an approximate
//! description.
use cranelift_codegen::isa::unwind::UnwindInst;
use cranelift_codegen::isa::TargetIsa;
use cranelift_codegen::RegClass;
use target_lexicon::{Architecture, OperatingSystem};

const UNWIND_INFO_VERSION: u8 = 1;
const UWOP_PUSH_NONVOL: u8 = 0;
const UWOP_ALLOC_LARGE: u8 = 1;
const UWOP_ALLOC_SMALL: u8 = 2;
const UWOP_SET_FPREG: u8 = 3;
const UWOP_SAVE_NONVOL: u8 = 4;
const UWOP_SAVE_XMM128: u8 = 8;
/// RBP in the unwind codes' register numbering (the hardware encoding, as
/// for every general register).
const RBP: u8 = 5;
/// `push rbp; mov rbp, rsp`: the bytes the prologue starts with.
const FRAME_SETUP: [u8; 4] = [0x55, 0x48, 0x89, 0xe5];
/// The largest establisher-frame offset the format holds: 15 * 16.
const MAX_CLOBBERS: u32 = 240;

/// Whether ISA's code is described to Windows by `UNWIND_INFO`: x86-64 code
/// for Windows (its functions use the Windows x64 convention, Cranelift's
/// default there).
pub fn windows_x64(isa: &dyn TargetIsa) -> bool {
    let triple = isa.triple();
    triple.operating_system == OperatingSystem::Windows && triple.architecture == Architecture::X86_64
}

/// One unwind code: its prologue offset, operation and operation info, and
/// the node that follows it, if the operation has one.
struct Code {
    offset: u8,
    op: u8,
    info: u8,
    extra: Option<u16>,
}

/// The `UNWIND_INFO` of the function whose machine code is CODE and whose
/// prologue Cranelift described as PROLOGUE (`unwind_info` of its finalized
/// buffer): version 1, no handler, no chained entry. `None` for code with no
/// prologue description at all (none of Cranelift's x86-64 functions: their
/// frame setup is unconditional); an error for a prologue of any shape but
/// the one this module's header states.
pub fn unwind_info(code: &[u8], prologue: &[(u32, UnwindInst)]) -> Result<Option<Vec<u8>>, String> {
    if prologue.is_empty() {
        return Ok(None);
    }
    let shape = |what: &str| Err(format!("Windows unwind information: {what} (prologue {prologue:?})"));
    let byte = |offset: u32| u8::try_from(offset).map_err(|_| format!("Windows unwind information: a prologue code at offset {offset}, past 255"));
    let mut insts = prologue.iter();
    match insts.next() {
        Some((1, UnwindInst::PushFrameRegs { offset_upward_to_caller_sp: 16 })) if code.starts_with(&FRAME_SETUP) => {}
        _ => return shape("the function does not start with push rbp; mov rbp, rsp"),
    }
    let (defined_at, clobbers) = match insts.next() {
        Some(&(at, UnwindInst::DefineNewFrame { offset_upward_to_caller_sp: 16, offset_downward_to_clobbers })) => {
            (at, offset_downward_to_clobbers)
        }
        _ => return shape("no frame definition after the frame pointer's"),
    };
    if defined_at < FRAME_SETUP.len() as u32 || clobbers % 16 != 0 || clobbers > MAX_CLOBBERS {
        return shape("the frame definition's clobber area is not one Windows can describe");
    }
    // In prologue order; the array holds them in reverse.
    let mut codes = vec![Code { offset: 1, op: UWOP_PUSH_NONVOL, info: RBP, extra: None }];
    let established = FRAME_SETUP.len() as u8;
    if clobbers > 0 {
        codes.push(if clobbers <= 128 {
            Code { offset: established, op: UWOP_ALLOC_SMALL, info: (clobbers / 8 - 1) as u8, extra: None }
        } else {
            Code { offset: established, op: UWOP_ALLOC_LARGE, info: 0, extra: Some((clobbers / 8) as u16) }
        });
    }
    codes.push(Code { offset: established, op: UWOP_SET_FPREG, info: 0, extra: None });
    let mut last = defined_at;
    for &(at, ref inst) in insts {
        let UnwindInst::SaveReg { clobber_offset, reg } = *inst else {
            return shape("an unwind step other than a register save after the frame definition");
        };
        let (op, scale) = match reg.class() {
            RegClass::Int => (UWOP_SAVE_NONVOL, 8),
            RegClass::Float => (UWOP_SAVE_XMM128, 16),
            RegClass::Vector => return shape("a vector register save"),
        };
        if at < last || clobber_offset % scale != 0 || clobber_offset + scale > clobbers || reg.hw_enc() > 15 {
            return shape("a register save outside the clobber area or out of order");
        }
        codes.push(Code { offset: byte(at)?, op, info: reg.hw_enc(), extra: Some((clobber_offset / scale) as u16) });
        last = at;
    }
    let size_of_prolog = byte(last.max(u32::from(established)))?;
    let nodes: usize = codes.iter().map(|c| 1 + c.extra.is_some() as usize).sum();
    let mut out = vec![
        UNWIND_INFO_VERSION,
        size_of_prolog,
        u8::try_from(nodes).map_err(|_| "Windows unwind information: more than 255 unwind codes".to_string())?,
        RBP | ((clobbers / 16) as u8) << 4,
    ];
    for code in codes.iter().rev() {
        out.push(code.offset);
        out.push(code.op | code.info << 4);
        if let Some(extra) = code.extra {
            out.extend_from_slice(&extra.to_le_bytes());
        }
    }
    if nodes % 2 == 1 {
        out.extend_from_slice(&[0, 0]);
    }
    Ok(Some(out))
}

/// Made for x86_64-pc-windows-msvc on any x86-64 host (only the code is made,
/// never run): an AArch64 build has no x86-64 backend to ask, as an x86-64
/// build has no AArch64 one (clif.rs's `apple_tests`).
#[cfg(all(test, target_arch = "x86_64"))]
mod tests {
    use super::*;
    use cranelift_codegen::ir::{self, types, AbiParam, InstBuilder, StackSlotData, StackSlotKind};
    use cranelift_codegen::settings::{self, Configurable};
    use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};
    use std::str::FromStr;

    /// A function compiled for x86_64-pc-windows-msvc (on any host: only the
    /// code is made, never run): it adds LIVE values computed before a call
    /// to the call's result, so the values live across the call take
    /// callee-saved registers, and stores to a stack slot of SLOT bytes if
    /// any (a frame larger than a page is probed). The values are loads from
    /// the parameter, never run. Returns the code, the
    /// prologue description and Cranelift's own Windows encoding of it.
    /// Without CALL it is a leaf.
    fn compile(live: usize, floats: usize, slot: u32, call: bool) -> (Vec<u8>, Vec<(u32, UnwindInst)>, Vec<u8>) {
        let mut flags = settings::builder();
        flags.set("opt_level", "speed").unwrap();
        flags.set("is_pic", "true").unwrap();
        flags.set("enable_probestack", "true").unwrap();
        flags.set("probestack_strategy", "inline").unwrap();
        let triple = target_lexicon::Triple::from_str("x86_64-pc-windows-msvc").unwrap();
        let isa = cranelift_codegen::isa::lookup(triple).unwrap().finish(settings::Flags::new(flags)).unwrap();
        assert!(windows_x64(&*isa));
        let mut sig = ir::Signature::new(isa.default_call_conv());
        sig.params.push(AbiParam::new(types::I64));
        sig.returns.push(AbiParam::new(types::I64));
        let mut func = ir::Function::with_name_signature(ir::UserFuncName::user(0, 0), sig.clone());
        let mut context = FunctionBuilderContext::new();
        let mut b = FunctionBuilder::new(&mut func, &mut context);
        let block = b.create_block();
        b.append_block_params_for_function_params(block);
        b.switch_to_block(block);
        let p = b.block_params(block)[0];
        if slot > 0 {
            let slot = b.create_sized_stack_slot(StackSlotData::new(StackSlotKind::ExplicitSlot, slot, 3));
            b.ins().stack_store(types::I64, p, slot, 0);
        }
        // Loads: values the code cannot recompute after the call.
        let flags = ir::MemFlagsData::trusted();
        let ints: Vec<_> = (0..live).map(|i| b.ins().load(types::I64, flags, p, 8 * i as i32)).collect();
        let doubles: Vec<_> = (0..floats).map(|i| b.ins().load(types::F64, flags, p, 512 + 8 * i as i32)).collect();
        let name = b.func.declare_imported_user_function(ir::UserExternalName::new(0, 1));
        let signature = b.import_signature(sig);
        let callee = b.import_function(ir::ExtFuncData {
            name: ir::ExternalName::user(name),
            signature,
            colocated: false,
            patchable: false,
        });
        let mut r = p;
        if call {
            let call = b.ins().call(callee, &[p]);
            r = b.inst_results(call)[0];
        }
        for v in ints {
            r = b.ins().iadd(r, v);
        }
        for d in doubles {
            let i = b.ins().fcvt_to_sint_sat(types::I64, d);
            r = b.ins().iadd(r, i);
        }
        b.ins().return_(&[r]);
        b.seal_all_blocks();
        b.finalize(isa.frontend_config());
        let mut ctx = cranelift_codegen::Context::for_function(func);
        let compiled = ctx.compile(&*isa, &mut Default::default()).unwrap();
        let theirs = match compiled.create_unwind_info(&*isa).unwrap() {
            Some(cranelift_codegen::isa::unwind::UnwindInfo::WindowsX64(info)) => {
                let mut bytes = vec![0; info.emit_size()];
                info.emit(&mut bytes);
                bytes
            }
            other => panic!("no Windows unwind information: {other:?}"),
        };
        (compiled.buffer.data().to_vec(), compiled.buffer.unwind_info.to_vec(), theirs)
    }

    /// The `UNWIND_INFO` fields: (size of prolog, frame offset, codes as
    /// (offset, op, info, following node)).
    fn decode(info: &[u8]) -> (u8, u8, Vec<(u8, u8, u8, Option<u16>)>) {
        assert_eq!(info[0], UNWIND_INFO_VERSION, "version 1, no flags");
        assert_eq!(info[3] & 15, RBP, "the frame register is RBP");
        let count = info[2] as usize;
        assert_eq!(info.len(), 4 + 2 * (count + count % 2));
        let node = |i: usize| u16::from_le_bytes([info[4 + 2 * i], info[5 + 2 * i]]);
        let mut codes = Vec::new();
        let mut i = 0;
        while i < count {
            let (offset, op, info) = (info[4 + 2 * i], info[5 + 2 * i] & 15, info[5 + 2 * i] >> 4);
            let extra = matches!(op, UWOP_SAVE_NONVOL | UWOP_SAVE_XMM128 | UWOP_ALLOC_LARGE).then(|| node(i + 1));
            codes.push((offset, op, info, extra));
            i += 1 + extra.is_some() as usize;
        }
        (info[1], info[3] >> 4, codes)
    }

    /// The save codes of a prologue: (offset, op, register, scaled offset),
    /// from SaveReg pseudo-instructions as Cranelift describes them.
    fn saves(prologue: &[(u32, UnwindInst)]) -> Vec<(u8, u8, u8, Option<u16>)> {
        prologue
            .iter()
            .rev()
            .filter_map(|(at, inst)| match *inst {
                UnwindInst::SaveReg { clobber_offset, reg } => Some(match reg.class() {
                    RegClass::Int => (*at as u8, UWOP_SAVE_NONVOL, reg.hw_enc(), Some((clobber_offset / 8) as u16)),
                    _ => (*at as u8, UWOP_SAVE_XMM128, reg.hw_enc(), Some((clobber_offset / 16) as u16)),
                }),
                _ => None,
            })
            .collect()
    }

    fn clobbers(prologue: &[(u32, UnwindInst)]) -> u32 {
        prologue
            .iter()
            .find_map(|(_, inst)| match *inst {
                UnwindInst::DefineNewFrame { offset_downward_to_clobbers, .. } => Some(offset_downward_to_clobbers),
                _ => None,
            })
            .unwrap()
    }

    /// A function that saves no register (a leaf returning its argument):
    /// the push and the frame pointer.
    #[test]
    fn a_frame_without_saves_is_the_push_and_the_frame_pointer() {
        let (code, prologue, _) = compile(0, 0, 0, false);
        assert_eq!(clobbers(&prologue), 0, "{prologue:?}");
        let info = unwind_info(&code, &prologue).unwrap().unwrap();
        let (prolog, frame_offset, codes) = decode(&info);
        assert_eq!((prolog, frame_offset), (4, 0));
        assert_eq!(codes, vec![(4, UWOP_SET_FPREG, 0, None), (1, UWOP_PUSH_NONVOL, RBP, None)]);
    }

    /// Saved general registers: the establisher frame is the clobber area's
    /// base, `rbp - CLOBBERS`, allocated at 4 below the pushed RBP, and each
    /// register's offset from it counts in 8 bytes.
    #[test]
    fn saved_registers_are_found_from_the_clobber_area() {
        let (code, prologue, _) = compile(3, 0, 0, true);
        let cs = clobbers(&prologue);
        assert!(cs > 0 && cs <= 128, "{prologue:?}");
        let info = unwind_info(&code, &prologue).unwrap().unwrap();
        let (prolog, frame_offset, codes) = decode(&info);
        assert_eq!(frame_offset as u32 * 16, cs);
        let mut expected = saves(&prologue);
        assert!(!expected.is_empty());
        assert_eq!(prolog, expected[0].0, "the prologue ends with its last save");
        expected.push((4, UWOP_SET_FPREG, 0, None));
        expected.push((4, UWOP_ALLOC_SMALL, (cs / 8 - 1) as u8, None));
        expected.push((1, UWOP_PUSH_NONVOL, RBP, None));
        assert_eq!(codes, expected);
    }

    /// Saved XMM registers count their offsets in 16 bytes; a clobber area
    /// over 128 bytes is a large allocation.
    #[test]
    fn saved_xmm_registers_and_a_large_clobber_area() {
        let (code, prologue, _) = compile(8, 10, 0, true);
        let cs = clobbers(&prologue);
        assert!(cs > 128, "{prologue:?}");
        let (_, frame_offset, codes) = decode(&unwind_info(&code, &prologue).unwrap().unwrap());
        assert_eq!(frame_offset as u32 * 16, cs);
        assert!(codes.iter().any(|c| c.1 == UWOP_SAVE_XMM128), "{codes:?}");
        assert!(codes.contains(&(4, UWOP_ALLOC_LARGE, 0, Some((cs / 8) as u16))), "{codes:?}");
        let mut expected = saves(&prologue);
        expected.extend([(4, UWOP_SET_FPREG, 0, None), (4, UWOP_ALLOC_LARGE, 0, Some((cs / 8) as u16)), (1, UWOP_PUSH_NONVOL, RBP, None)]);
        assert_eq!(codes, expected);
    }

    /// A frame of many pages: its probe loop runs between the frame
    /// pointer and the frame definition, which the codes place where the
    /// frame pointer is set (4), not where Cranelift defines the frame.
    #[test]
    fn a_probed_frame_unwinds_from_its_frame_pointer() {
        let (code, prologue, _) = compile(2, 0, 1 << 20, true);
        let defined = prologue.iter().find(|(_, i)| matches!(i, UnwindInst::DefineNewFrame { .. })).unwrap().0;
        assert!(defined > 20, "the probes come first: {prologue:?}");
        let (_, _, codes) = decode(&unwind_info(&code, &prologue).unwrap().unwrap());
        assert!(codes.contains(&(4, UWOP_SET_FPREG, 0, None)), "{codes:?}");
    }

    /// Any other prologue shape is refused, never described approximately.
    #[test]
    fn other_prologues_are_refused() {
        let (code, prologue, _) = compile(3, 0, 0, true);
        let mut moved = code.clone();
        moved[1] = 0x90;
        assert!(unwind_info(&moved, &prologue).is_err(), "no mov rbp, rsp at 1");
        let without_definition: Vec<_> =
            prologue.iter().filter(|(_, i)| !matches!(i, UnwindInst::DefineNewFrame { .. })).cloned().collect();
        assert!(unwind_info(&code, &without_definition).is_err());
        let mut far = prologue.clone();
        far.last_mut().unwrap().0 = 256;
        assert!(unwind_info(&code, &far).is_err(), "a code past offset 255");
        let mut allocated = prologue.clone();
        allocated.push((40, UnwindInst::StackAlloc { size: 16 }));
        assert!(unwind_info(&code, &allocated).is_err(), "an allocation code Cranelift's x86-64 prologue never has");
        assert_eq!(unwind_info(&code, &[]).unwrap(), None);
    }

    /// Why this module encodes Cranelift's description itself: Cranelift
    /// 0.135.2's own Windows encoding of a frame that saves registers has a
    /// zero frame offset (so the unwinder's establisher frame is RBP, above
    /// the clobber area) and scales a general register's offset by 16
    /// (`UWOP_SAVE_NONVOL` scales by 8): Windows would restore RSI and RDI
    /// from RBP's own slot. When this fails after a Cranelift upgrade, check
    /// its encoding against Windows' unwinder (WINDOWS-X86-64-MILESTONE-3.md,
    /// section 2) before taking it.
    #[test]
    fn cranelift_windows_encoding_defect_still_present() {
        let (code, prologue, theirs) = compile(3, 0, 0, true);
        let (_, their_offset, their_codes) = decode(&theirs);
        let (_, our_offset, _) = decode(&unwind_info(&code, &prologue).unwrap().unwrap());
        assert!(our_offset > 0);
        assert_eq!(their_offset, 0, "Cranelift's frame offset");
        let general: Vec<_> = their_codes.iter().filter(|c| c.1 == UWOP_SAVE_NONVOL).map(|c| c.3).collect();
        let mut slots = general.clone();
        slots.dedup();
        assert!(general.len() >= 2 && slots.len() < general.len(), "clobber offsets 0 and 8 both scaled to slot 0: {their_codes:?}");
    }
}
