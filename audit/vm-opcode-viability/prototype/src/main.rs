//! Calibration prototype for VM-OPCODE-VIABILITY.md section 12: the v1
//! dispatch loop that document specifies, reduced to the opcodes two
//! micro-benchmarks need, so that the interpreter's per-instruction and
//! per-call costs can be measured before any interpreter exists. It is not
//! part of Botlish and shares no code with `native/`.
//!
//! What it reproduces from the design:
//!
//!   * 64-bit instruction words, opcode in byte 0, 8-bit register fields,
//!     immediates sign-extended from the high bytes (section 4);
//!   * a `match` dispatch loop over a register stack indexed from `fp`, with
//!     frame records on a separate control stack (section 3.3);
//!   * `call` copying arguments into the callee frame with an unbox-on-entry
//!     mask and zeroing the callee's tagged slots; `ret` reading its
//!     destination from the call instruction (section 3.3);
//!   * ZF/CF flags in loop locals, written by `cmp` and read by jcc (3.5);
//!   * tagged-Int `add`/`cmp` with the small-Int fast path and an
//!     out-of-line slow path (5.3, 5.4);
//!   * the self tail call as a parallel copy and a jump to pc 0 of the
//!     function (3.3).
//!
//! What it leaves out: the other ~100 opcodes, the runtime (no heap, no GC,
//! no helpers: the BigInt slow path is a stub these programs never reach),
//! handler tables, the stack-depth error. Register access is unchecked, as a
//! validated-bytecode interpreter would do it.
//!
//! The programs are the VM code VM-OPCODE-VIABILITY.md section 2 shows for
//! `fib`, a tagged-Int `fib` (the generic instance, with no range proofs),
//! `count` from ../botlish/loop.bot, and variants of `fib` and `count` with
//! compare-and-branch fused into one superinstruction (and, for `count`, the
//! dead `mov` of NIR's `if` join dropped).
//!
//!   cargo run --release

use std::hint::black_box;
use std::time::Instant;

// Opcodes (byte 0 of the word).
const MOV_RR: u8 = 1; //  mov d, s
const MOV_RI: u8 = 2; //  mov d, imm48
const ADD_RRR: u8 = 3; // add r, r, r
const ADD_RRI: u8 = 4; // add r, r, imm40
const ADD_VVV: u8 = 5; // add v, v, v   (Botlish Int)
const ADD_VVI: u8 = 6; // add v, v, imm40 (immediate stored as 2k)
const CMP_RI: u8 = 7; //  cmp r, imm48
const CMP_VI: u8 = 8; //  cmp v, imm48 (immediate stored tagged)
const JMP: u8 = 9; //     jmp off32
const JGE: u8 = 10; //    jge off32
const JG: u8 = 11; //     jg off32
const CALL: u8 = 12; //   call f16, dst, args... (single result)
const RET: u8 = 13; //    ret r
const BOX: u8 = 14; //    box v, r
const TAIL: u8 = 15; //   tail args...
const JGE_RI: u8 = 16; // super cmp.jge r, imm16, off32
const JG_RI: u8 = 17; //  super cmp.jg  r, imm16, off32

const UNIT: i64 = 10;

// Encoders.
fn regs(op: u8, bytes: &[u8]) -> u64 {
    let mut x = op as u64;
    for (i, b) in bytes.iter().enumerate() {
        x |= (*b as u64) << (8 * (i + 1));
    }
    x
}
fn ri(op: u8, a: u8, imm: i64) -> u64 {
    op as u64 | (a as u64) << 8 | (imm as u64) << 16
}
fn rri(op: u8, d: u8, a: u8, imm: i64) -> u64 {
    op as u64 | (d as u64) << 8 | (a as u64) << 16 | (imm as u64) << 24
}
fn jmp(op: u8, off: i32) -> u64 {
    op as u64 | (off as u32 as u64) << 32
}
fn cmp_jmp(op: u8, a: u8, imm: i16, off: i32) -> u64 {
    op as u64 | (a as u64) << 8 | (imm as u16 as u64) << 16 | (off as u32 as u64) << 32
}
fn call(f: u16, dst_then_args: &[u8]) -> u64 {
    let mut x = CALL as u64 | (f as u64) << 8;
    for (i, r) in dst_then_args.iter().enumerate() {
        x |= (*r as u64) << (8 * (3 + i));
    }
    x
}
fn tag(n: i64) -> i64 {
    2 * n + 1
}

/// One function: entry pc, frame size, parameter count, unbox-on-entry
/// mask, and the tagged slots `vlo..vhi` a call zeroes.
#[derive(Clone, Copy)]
struct Func {
    entry: usize,
    size: usize,
    params: usize,
    unbox: u8,
    vlo: usize,
    vhi: usize,
}

struct Frame {
    call_pc: usize,
    fp: usize,
    func: usize,
}

#[inline(always)]
fn byte(w: u64, i: u32) -> usize {
    ((w >> (8 * i)) & 0xff) as usize
}
#[inline(always)]
fn imm48(w: u64) -> i64 {
    (w as i64) >> 16
}
#[inline(always)]
fn imm40(w: u64) -> i64 {
    (w as i64) >> 24
}
#[inline(always)]
fn off32(w: u64) -> i64 {
    ((w >> 32) as i32) as i64
}

#[inline(never)]
#[cold]
fn int_slow(_a: u64, _b: u64) -> u64 {
    panic!("the BigInt path is not exercised by this calibration")
}

fn run(code: &[u64], funcs: &[Func], entry_func: usize) -> u64 {
    let mut regs: Vec<u64> = vec![0; 1 << 20];
    let mut frames: Vec<Frame> = Vec::with_capacity(1 << 16);
    let mut fp = 0usize;
    let mut cur = entry_func;
    let mut size = funcs[cur].size;
    let mut pc = funcs[cur].entry;
    let (mut zf, mut cf) = (false, false);
    macro_rules! get {
        ($i:expr) => {
            unsafe { *regs.get_unchecked(fp + $i) }
        };
    }
    macro_rules! set {
        ($i:expr, $v:expr) => {{
            let v = $v;
            unsafe { *regs.get_unchecked_mut(fp + $i) = v }
        }};
    }
    loop {
        let ins = unsafe { *code.get_unchecked(pc) };
        match ins as u8 {
            MOV_RR => {
                set!(byte(ins, 1), get!(byte(ins, 2)));
                pc += 1
            }
            MOV_RI => {
                set!(byte(ins, 1), imm48(ins) as u64);
                pc += 1
            }
            ADD_RRR => {
                set!(byte(ins, 1), get!(byte(ins, 2)).wrapping_add(get!(byte(ins, 3))));
                pc += 1
            }
            ADD_RRI => {
                set!(byte(ins, 1), get!(byte(ins, 2)).wrapping_add(imm40(ins) as u64));
                pc += 1
            }
            ADD_VVV => {
                let (x, y) = (get!(byte(ins, 2)), get!(byte(ins, 3)));
                let v = if x & y & 1 != 0 {
                    match (x as i64).checked_add(y as i64 - 1) {
                        Some(s) => s as u64,
                        None => int_slow(x, y),
                    }
                } else {
                    int_slow(x, y)
                };
                set!(byte(ins, 1), v);
                pc += 1
            }
            ADD_VVI => {
                let x = get!(byte(ins, 2));
                let v = if x & 1 != 0 {
                    match (x as i64).checked_add(imm40(ins)) {
                        Some(s) => s as u64,
                        None => int_slow(x, 0),
                    }
                } else {
                    int_slow(x, 0)
                };
                set!(byte(ins, 1), v);
                pc += 1
            }
            CMP_RI => {
                let (x, y) = (get!(byte(ins, 1)) as i64, imm48(ins));
                zf = x == y;
                cf = x < y;
                pc += 1
            }
            CMP_VI => {
                let x = get!(byte(ins, 1));
                if x & 1 == 0 {
                    int_slow(x, 0);
                }
                let (x, y) = (x as i64, imm48(ins));
                zf = x == y;
                cf = x < y;
                pc += 1
            }
            JMP => pc = (pc as i64 + off32(ins)) as usize,
            JGE => pc = if !cf { (pc as i64 + off32(ins)) as usize } else { pc + 1 },
            JG => pc = if !cf && !zf { (pc as i64 + off32(ins)) as usize } else { pc + 1 },
            JGE_RI | JG_RI => {
                let x = get!(byte(ins, 1)) as i64;
                let y = ((ins >> 16) as u16 as i16) as i64;
                zf = x == y;
                cf = x < y;
                let take = if ins as u8 == JG_RI { !cf && !zf } else { !cf };
                pc = if take { (pc as i64 + off32(ins)) as usize } else { pc + 1 };
            }
            CALL => {
                let f = ((ins >> 8) & 0xffff) as usize;
                let callee = unsafe { *funcs.get_unchecked(f) };
                let nfp = fp + size;
                if nfp + callee.size > regs.len() {
                    regs.resize(regs.len() * 2, 0);
                }
                for i in 0..callee.params {
                    let mut v = get!(byte(ins, 4 + i as u32));
                    if callee.unbox & (1 << i) != 0 {
                        v = ((v as i64) >> 1) as u64;
                    }
                    unsafe { *regs.get_unchecked_mut(nfp + i) = v }
                }
                for s in callee.vlo..callee.vhi {
                    unsafe { *regs.get_unchecked_mut(nfp + s) = 0 }
                }
                frames.push(Frame { call_pc: pc, fp, func: cur });
                fp = nfp;
                cur = f;
                size = callee.size;
                pc = callee.entry;
            }
            RET => {
                let v = get!(byte(ins, 1));
                match frames.pop() {
                    None => return v,
                    Some(fr) => {
                        let call_word = unsafe { *code.get_unchecked(fr.call_pc) };
                        fp = fr.fp;
                        cur = fr.func;
                        size = unsafe { funcs.get_unchecked(cur) }.size;
                        set!(byte(call_word, 3), v);
                        pc = fr.call_pc + 1;
                    }
                }
            }
            BOX => {
                set!(byte(ins, 1), (get!(byte(ins, 2)) << 1) | 1);
                pc += 1
            }
            TAIL => {
                let n = unsafe { funcs.get_unchecked(cur) }.params;
                let mut tmp = [0u64; 7];
                for i in 0..n {
                    tmp[i] = get!(byte(ins, 1 + i as u32));
                }
                for i in 0..n {
                    set!(i, tmp[i]);
                }
                pc = unsafe { funcs.get_unchecked(cur) }.entry;
            }
            _ => unreachable!(),
        }
    }
}

fn main() {
    let n: i64 = black_box(30);
    let m: i64 = black_box(10_000_000);
    let mut code: Vec<u64> = Vec::new();
    let mut funcs: Vec<Func> = Vec::new();
    let mut add = |code: &mut Vec<u64>, body: &[u64], size: usize, params: usize, unbox: u8, v: (usize, usize)| {
        funcs.push(Func { entry: code.len(), size, params, unbox, vlo: v.0, vhi: v.1 });
        code.extend_from_slice(body);
        funcs.len() - 1
    };

    // f0/f1: fib with the raw-Int ABI, exactly section 2's VM code (NIR
    // register numbers, frame 14, no tagged slots).
    let prog_fib = add(&mut code, &[ri(MOV_RI, 0, n), call(1, &[1, 0]), regs(BOX, &[2, 1]), regs(RET, &[2])], 3, 0, 0, (2, 3));
    add(&mut code, &[
        ri(CMP_RI, 0, 2), jmp(JGE, 3), regs(MOV_RR, &[4, 0]), jmp(JMP, 7),
        rri(ADD_RRI, 7, 0, -1), call(1, &[8, 7]), rri(ADD_RRI, 11, 0, -2), call(1, &[12, 11]),
        regs(ADD_RRR, &[13, 8, 12]), regs(MOV_RR, &[4, 13]), regs(RET, &[4]),
    ], 14, 1, 0, (0, 0));

    // f2/f3: the same fib on tagged Ints, zeroing all 13 non-parameter slots
    // per call (NIR numbering).
    let prog_fib_tagged = add(&mut code, &[ri(MOV_RI, 0, tag(n)), call(3, &[1, 0]), regs(RET, &[1])], 3, 0, 0, (0, 3));
    let fib_tagged = add(&mut code, &[
        ri(CMP_VI, 0, tag(2)), jmp(JGE, 3), regs(MOV_RR, &[4, 0]), jmp(JMP, 7),
        rri(ADD_VVI, 7, 0, -2), call(3, &[8, 7]), rri(ADD_VVI, 11, 0, -4), call(3, &[12, 11]),
        regs(ADD_VVV, &[13, 8, 12]), regs(MOV_RR, &[4, 13]), regs(RET, &[4]),
    ], 14, 1, 0, (1, 14));

    // f4/f5: count(n, acc) from ../botlish/loop.bot: n is raw but arrives
    // tagged (unbox-on-entry), acc stays tagged; the dead `mov v5, unit` is
    // NIR's `if` join, kept because v1 only drops dead constants.
    let prog_count = add(&mut code, &[ri(MOV_RI, 0, tag(m)), ri(MOV_RI, 2, tag(0)), call(5, &[4, 0, 2]), regs(RET, &[4])], 5, 0, 0, (0, 5));
    add(&mut code, &[
        ri(CMP_RI, 0, 0), jmp(JG, 2), regs(RET, &[1]),
        ri(MOV_RI, 5, UNIT), rri(ADD_RRI, 9, 0, -1), regs(BOX, &[10, 0]),
        regs(ADD_VVV, &[11, 1, 10]), regs(TAIL, &[9, 11]),
    ], 12, 2, 1, (2, 12));

    // f6/f7: fib with `cmp` + `jge` fused into one superinstruction.
    let prog_fib_fused = add(&mut code, &[ri(MOV_RI, 0, n), call(7, &[1, 0]), regs(BOX, &[2, 1]), regs(RET, &[2])], 3, 0, 0, (2, 3));
    add(&mut code, &[
        cmp_jmp(JGE_RI, 0, 2, 3), regs(MOV_RR, &[4, 0]), jmp(JMP, 7),
        rri(ADD_RRI, 7, 0, -1), call(7, &[8, 7]), rri(ADD_RRI, 11, 0, -2), call(7, &[12, 11]),
        regs(ADD_RRR, &[13, 8, 12]), regs(MOV_RR, &[4, 13]), regs(RET, &[4]),
    ], 14, 1, 0, (0, 0));

    // f8/f9: count with `cmp` + `jg` fused and the dead join `mov` dropped.
    let prog_count_fused = add(&mut code, &[ri(MOV_RI, 0, tag(m)), ri(MOV_RI, 2, tag(0)), call(9, &[4, 0, 2]), regs(RET, &[4])], 5, 0, 0, (0, 5));
    add(&mut code, &[
        cmp_jmp(JG_RI, 0, 0, 2), regs(RET, &[1]),
        rri(ADD_RRI, 9, 0, -1), regs(BOX, &[10, 0]), regs(ADD_VVV, &[11, 1, 10]), regs(TAIL, &[9, 11]),
    ], 12, 2, 1, (2, 12));

    // The tagged fib again, zeroing 4 slots per call instead of 13: the
    // per-call cost of NIR numbering versus compaction (same code; only the
    // zeroed range changes).
    let mut compact = funcs.clone();
    compact[fib_tagged].vhi = 5;

    for (label, entry, table) in [
        ("fib(30), raw-Int ABI", prog_fib, &funcs),
        ("fib(30), tagged Ints, zeroing 13 slots", prog_fib_tagged, &funcs),
        ("fib(30), tagged Ints, zeroing 4 slots", prog_fib_tagged, &compact),
        ("count(10M)", prog_count, &funcs),
        ("fib(30), cmp+jcc fused", prog_fib_fused, &funcs),
        ("count(10M), cmp+jcc fused, dead mov dropped", prog_count_fused, &funcs),
    ] {
        let mut best = f64::MAX;
        let mut value = 0;
        for _ in 0..5 {
            let t = Instant::now();
            value = run(black_box(&code), black_box(table), entry);
            best = best.min(t.elapsed().as_secs_f64());
        }
        println!("{label:45} value {:>15}  best {:6.1} ms", (value as i64) >> 1, best * 1e3);
    }
}
