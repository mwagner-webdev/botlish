//! `linux::abi::syscall` (core/linuxabi.tcl, LINUX-X86-64-SYSCALL.md): the
//! one raw kernel transition Botlish code can make, on Linux x86-64.
//!
//! Two layers, and only the first is privileged:
//!
//! * [`botlish_linux_x86_64_syscall`] **is the privileged boundary**: seven
//!   64-bit register words in, one out, through the x86-64 `syscall`
//!   instruction itself (inline `asm!`, never libc's `syscall(3)`, `getpid`
//!   or any other wrapper). It is a plain register bridge: it does not know
//!   any syscall number, interprets no result (no errno, no `-1`), retries
//!   nothing, caches nothing and selects no vDSO entry.
//! * [`rt_linux_x86_64_syscall`] is the ordinary runtime helper generated
//!   code calls (NIR `op syscall_linux_x86_64`): it reads the seven operand
//!   Ints as the 64-bit words they are proven to be, calls the boundary, and
//!   returns `rax` read as a signed 64-bit Int (`Vm::new_int`: a small Int
//!   immediate, or a BigInt only when outside the small range).
//!
//! The helper is entered through the platform's ordinary function calling
//! convention (System V: arguments in rdi, rsi, rdx, rcx, r8, r9, then the
//! stack). That is *not* the kernel's: the asm block below places every word
//! in the register the Linux x86-64 syscall convention names -- in particular
//! argument 4 in r10, never rcx, which the `syscall` instruction itself
//! overwrites -- so nothing depends on the function convention happening to
//! leave words in the right registers.
//!
//! Clobbers and effects, all declared to the compiler of this file (and so
//! true of every caller): `syscall` overwrites rcx (the return rip) and r11
//! (the saved rflags) and returns in rax; rflags is not declared preserved;
//! the kernel does not touch the user stack (`nostack`). There is no `pure`,
//! `nomem` or `readonly`: the kernel may read and write any user memory
//! through pointer arguments, block, and return different results for equal
//! inputs, so the block is never merged, hoisted or removed. In generated
//! code the operation is a helper `call`, which Cranelift likewise treats as
//! reading and writing all memory and as clobbering every caller-saved
//! register (a superset of the instruction's own clobbers); the kernel
//! preserves the callee-saved ones.
//!
//! Target gating: the boundary exists only when compiling for Linux x86-64.
//! Code generation refuses the op for any other target (codegen/clif.rs), and
//! the helper is never reached there.

use super::error::RtError;
use super::value::*;
use super::vm::Vm;
use num_traits::ToPrimitive;

/// The x86-64 `syscall` instruction with RAX = `rax` (the syscall number)
/// and RDI, RSI, RDX, R10, R8, R9 = arguments 1-6; returns RAX afterwards,
/// unmodified.
///
/// # Safety
///
/// It performs whatever system call `rax` names, with whatever the argument
/// words mean to the kernel (including pointers into this process's memory).
/// The caller is responsible for that call being one it means to make.
#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
#[unsafe(no_mangle)]
#[inline(never)]
pub unsafe extern "C" fn botlish_linux_x86_64_syscall(
    rax: i64,
    rdi: i64,
    rsi: i64,
    rdx: i64,
    r10: i64,
    r8: i64,
    r9: i64,
) -> i64 {
    let result: i64;
    // SAFETY: the caller's contract (above). The operand constraints are
    // exactly the Linux x86-64 syscall register convention; rcx and r11 are
    // the instruction's own clobbers.
    unsafe {
        core::arch::asm!(
            "syscall",
            inlateout("rax") rax => result,
            in("rdi") rdi,
            in("rsi") rsi,
            in("rdx") rdx,
            in("r10") r10,
            in("r8") r8,
            in("r9") r9,
            lateout("rcx") _,
            lateout("r11") _,
            options(nostack),
        );
    }
    result
}

/// The 64-bit register word an operand Int denotes: the Int itself, which
/// HIR proved to be in -2^63..2^63-1 (an abi::x86_64::Register64's `word`,
/// lib/abi/x86_64.bot) -- its two's-complement bit pattern is the register
/// contents. None for anything else (a backend bug: never truncated).
#[inline]
pub fn register_word(v: Value) -> Option<i64> {
    if is_small(v) {
        return Some(small_of(v));
    }
    if is_pointer(v) && heap_kind(v) == KIND_BIGINT {
        return int_to_big(v).to_i64();
    }
    None
}

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// `linux::abi::syscall`: RAX (the syscall number) and RDI, RSI, RDX, R10,
/// R8, R9 (arguments 1-6; an argument the source omitted is the Int 0) are
/// Ints in -2^63..2^63-1; the result is the raw RAX afterwards, read as a
/// signed 64-bit Int. Fails only on an operand that is not such an Int --
/// which a checked program cannot produce (a Register64's word is proven),
/// but an unchecked (-strict 0) program can, by constructing a Register64
/// whose word HIR rejected: a TYPE error then, before any transition, and
/// never a truncation.
#[unsafe(no_mangle)]
pub extern "C" fn rt_linux_x86_64_syscall(
    p: *mut Vm,
    rax: Value,
    rdi: Value,
    rsi: Value,
    rdx: Value,
    r10: Value,
    r8: Value,
    r9: Value,
) -> Value {
    let operands = [rax, rdi, rsi, rdx, r10, r8, r9];
    let mut words = [0i64; 7];
    for (i, v) in operands.into_iter().enumerate() {
        match register_word(v) {
            Some(w) => words[i] = w,
            None => {
                let register = ["rax", "rdi", "rsi", "rdx", "r10", "r8", "r9"][i];
                return vm(p).fail(RtError::Semantic {
                    kind: "TYPE",
                    message: format!(
                        "linux::abi::syscall: register {register} is not a 64-bit register word (an Int in -2^63..2^63-1)"
                    ),
                });
            }
        }
    }
    syscall_words(p, words)
}

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
fn syscall_words(p: *mut Vm, w: [i64; 7]) -> Value {
    // SAFETY: Botlish's linux::abi::syscall is exactly a request to make this
    // system call (the program's own register words, unmodified).
    let rax = unsafe { botlish_linux_x86_64_syscall(w[0], w[1], w[2], w[3], w[4], w[5], w[6]) };
    rax_value(vm(p), rax)
}

/// The raw rax word as the Int it denotes under the signed reading (a
/// kernel error return such as -38 stays -38; nothing is interpreted): a
/// small Int immediate, or a BigInt outside the small range.
pub fn rax_value(vm: &mut Vm, rax: i64) -> Value {
    vm.new_int(rax)
}

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
fn syscall_words(p: *mut Vm, _w: [i64; 7]) -> Value {
    // Unreachable: codegen/clif.rs refuses the op for any other target.
    vm(p).fail(RtError::Unsupported("linux::abi::syscall needs a Linux x86-64 target".to_string()))
}

#[cfg(all(test, target_arch = "x86_64", target_os = "linux"))]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    /// x86-64 Linux syscall number 39, getpid: the one live syscall the test
    /// suite makes (harmless, argument-free, no failure case). The number is
    /// test data here, exactly as in Botlish source; nothing in the runtime
    /// knows it.
    const GETPID: i64 = 39;

    fn new_vm() -> Box<Vm> {
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new() }),
            AllocMode::Off,
        )
    }

    fn this_pid() -> i64 {
        std::process::id() as i64
    }

    #[test]
    fn boundary_getpid_is_this_process() {
        let pid = unsafe { botlish_linux_x86_64_syscall(GETPID, 0, 0, 0, 0, 0, 0) };
        assert_eq!(pid, this_pid());
        let again = unsafe { botlish_linux_x86_64_syscall(GETPID, 0, 0, 0, 0, 0, 0) };
        assert_eq!(pid, again);
    }

    #[test]
    fn boundary_ignores_unused_argument_registers() {
        // getpid takes no arguments: whatever the six argument registers
        // hold, the kernel returns the same pid.
        let pid = unsafe { botlish_linux_x86_64_syscall(GETPID, -1, i64::MIN, i64::MAX, 7, 8, 9) };
        assert_eq!(pid, this_pid());
    }

    #[test]
    fn register_words_are_the_ints_themselves() {
        let mut vm = new_vm();
        for n in [0i64, 1, 39, -1, SMALL_MAX, SMALL_MIN, SMALL_MAX + 1, SMALL_MIN - 1, i64::MAX, i64::MIN] {
            // Small Ints are immediates, the rest heap BigInts.
            let v = vm.new_int(n);
            assert_eq!(is_small(v), fits_small(n));
            assert_eq!(register_word(v), Some(n), "{n}");
        }
        assert_eq!(register_word(UNIT), None);
        assert_eq!(register_word(TRUE), None);
    }

    #[test]
    fn helper_returns_rax_as_an_int() {
        let mut vm = new_vm();
        let p = &mut *vm as *mut Vm;
        let zero = make_small(0);
        let nr = make_small(GETPID);
        let r = rt_linux_x86_64_syscall(p, nr, zero, zero, zero, zero, zero, zero);
        assert_eq!(int_small(r), Some(this_pid()));
        // BigInt operands (the i64 extremes) are read as their words too.
        // Rooted (as compiled code's stack maps root operands): BIG_MAX's
        // allocation may collect, always under BOTLISH_NATIVE_GC_STRESS=1.
        let big_min = vm.new_int(i64::MIN);
        vm.temp_roots.push(big_min);
        let big_max = vm.new_int(i64::MAX);
        vm.temp_roots.push(big_max);
        let r = rt_linux_x86_64_syscall(p, nr, big_min, big_max, zero, zero, zero, zero);
        assert_eq!(int_small(r), Some(this_pid()));
    }

    #[test]
    fn helper_never_truncates_a_non_word_operand() {
        let mut vm = new_vm();
        let p = &mut *vm as *mut Vm;
        let zero = make_small(0);
        let r = rt_linux_x86_64_syscall(p, make_small(GETPID), UNIT, zero, zero, zero, zero, zero);
        assert_eq!(r, NO_VALUE);
        assert!(matches!(&vm.error, Some(RtError::Semantic { kind: "TYPE", message }) if message.contains("rdi")));
        // A BigInt beyond i64 (2^64), as an unchecked program could build.
        let mut other = new_vm();
        let q = &mut *other as *mut Vm;
        let beyond = other.new_big(num_bigint::BigInt::from(1u128 << 64));
        let r = rt_linux_x86_64_syscall(q, make_small(GETPID), zero, beyond, zero, zero, zero, zero);
        assert_eq!(r, NO_VALUE);
        assert!(matches!(&other.error, Some(RtError::Semantic { kind: "TYPE", message }) if message.contains("rsi")));
    }

    /// ABI numeric values (lib/abi.bot) reach the kernel as their x86-64
    /// register bit patterns (ABI-NUMERIC-DOMAINS.md). Each word is built
    /// the way generated code builds it -- abi::x86_64::from_* passes a
    /// signed or lower-half unsigned value through unchanged, and computes
    /// an upper-half U64/Usize value's word with the runtime's ordinary Int
    /// subtraction, `v - 2^64` (rt_int_sub, BigInt operands) -- and the
    /// 64 bits register_word hands the boundary are checked against the
    /// expected pattern directly, not through any signed reading.
    #[test]
    fn abi_numeric_words_are_their_register_bit_patterns() {
        use crate::runtime::ops::rt_int_sub;
        let mut vm = new_vm();
        let p = &mut *vm as *mut Vm;
        // Every BigInt here is rooted (as compiled code's stack maps root
        // operands) before the next allocation, which may collect (always,
        // under BOTLISH_NATIVE_GC_STRESS=1).
        let two_64 = vm.new_big(num_bigint::BigInt::from(1u128 << 64));
        vm.temp_roots.push(two_64);
        // Signed values are sign-extended: the word is the value itself.
        for (value, bits) in [
            (-1i64, 0xffff_ffff_ffff_ffffu64), // I8/I16/I32/I64/Isize -1
            (-128, 0xffff_ffff_ffff_ff80),     // I8 min
            (127, 0x0000_0000_0000_007f),      // I8 max
            (-32768, 0xffff_ffff_ffff_8000),   // I16 min
            (-2147483648, 0xffff_ffff_8000_0000), // I32 min
            (i64::MIN, 0x8000_0000_0000_0000), // I64/Isize min
            (i64::MAX, 0x7fff_ffff_ffff_ffff), // I64/Isize max
            // Unsigned values below 2^63 are zero-extended: also the value.
            (255, 0x0000_0000_0000_00ff),        // U8 max
            (65535, 0x0000_0000_0000_ffff),      // U16 max
            (4294967295, 0x0000_0000_ffff_ffff), // U32 max
        ] {
            let word = vm.new_int(value);
            assert_eq!(register_word(word).map(|w| w as u64), Some(bits), "{value}");
        }
        // The upper half of U64/Usize: word = v - 2^64, through the
        // runtime's own BigInt subtraction, as from_u64 computes it.
        for (value, bits) in [
            (1u128 << 63, 0x8000_0000_0000_0000u64),       // 2^63
            ((1u128 << 63) + 1, 0x8000_0000_0000_0001),    // 2^63 + 1
            (3u128 << 62, 0xc000_0000_0000_0000),          // first small word
            ((1u128 << 64) - 2, 0xffff_ffff_ffff_fffe),
            ((1u128 << 64) - 1, 0xffff_ffff_ffff_ffff),    // U64/Usize max
        ] {
            let v = vm.new_big(num_bigint::BigInt::from(value));
            vm.temp_roots.push(v);
            let word = rt_int_sub(p, v, two_64);
            assert_eq!(register_word(word).map(|w| w as u64), Some(bits), "{value}");
            // A word outside the 63-bit small range stays a BigInt in
            // transit (the documented representation cost), and is still
            // read as exactly these 64 bits.
            assert_eq!(is_small(word), fits_small(bits as i64), "{value}");
        }
    }

    #[test]
    fn rax_is_read_signed() {
        // getpid's result is always a small positive pid, so the reading of
        // negative words (kernel error returns are -4095..-1) is pinned here,
        // without making any other syscall.
        let mut vm = new_vm();
        for (raw, expected) in [(-1i64, "-1"), (-38, "-38"), (-4095, "-4095"), (0, "0"), (i64::MIN, "-9223372036854775808"),
            (i64::MAX, "9223372036854775807"), (SMALL_MIN - 1, "-4611686018427387905")]
        {
            let v = rax_value(&mut vm, raw);
            assert_eq!(int_to_big(v).to_string(), expected);
        }
    }

    // -----------------------------------------------------------------------
    // write(2) over an owned byte storage (ABI-BYTES.md): the second live
    // syscall the suite makes, to a pipe this test owns (or an invalid
    // descriptor), through the generic boundary -- the runtime knows no
    // syscall number; 1 is test data, as in Botlish source.

    const WRITE: i64 = 1;

    fn small(n: i64) -> Value {
        make_small(n)
    }

    #[test]
    fn writing_a_byte_storage_through_the_generic_boundary_reaches_the_pipe_exactly() {
        use std::io::Read;
        use std::os::fd::AsRawFd;
        let mut vm = new_vm();
        let p: *mut Vm = &mut *vm;
        let payload = [0x41u8, 0x00, 0x42, 0xff, 0x00, 0x80];
        let storage = vm.new_bytes(&payload);
        let address = crate::runtime::ops::rt_bytes_addr(p, storage);
        let length = crate::runtime::ops::rt_bytes_len(p, storage);
        let (mut reader, writer) = std::io::pipe().unwrap();
        let fd = writer.as_raw_fd() as i64;
        let written =
            rt_linux_x86_64_syscall(p, small(WRITE), small(fd), address, length, small(0), small(0), small(0));
        assert_eq!(written, small(payload.len() as i64));
        drop(writer);
        let mut received = Vec::new();
        reader.read_to_end(&mut received).unwrap();
        assert_eq!(received, payload);
    }

    #[test]
    fn a_zero_length_write_and_an_invalid_descriptor_are_the_kernels_raw_results() {
        let mut vm = new_vm();
        let p: *mut Vm = &mut *vm;
        let empty = vm.new_bytes(&[]);
        let address = crate::runtime::ops::rt_bytes_addr(p, empty);
        let (reader, writer) = std::io::pipe().unwrap();
        use std::os::fd::AsRawFd;
        let fd = writer.as_raw_fd() as i64;
        // Count 0 on a valid descriptor: 0, whatever the (one-past) address.
        let zero = rt_linux_x86_64_syscall(p, small(WRITE), small(fd), address, small(0), small(0), small(0), small(0));
        assert_eq!(zero, small(0));
        // An invalid descriptor, even with a zero count: -EBADF, kept negative.
        let bad = rt_linux_x86_64_syscall(p, small(WRITE), small(1000), address, small(0), small(0), small(0), small(0));
        assert_eq!(bad, small(-9));
        drop((reader, writer));
    }

    #[test]
    fn the_storage_stays_valid_while_the_kernel_reads_it_even_with_a_collection_running() {
        use std::io::Read;
        use std::os::fd::AsRawFd;
        let mut vm = new_vm();
        vm.heap.set_stress_for_test(true);
        let p: *mut Vm = &mut *vm;
        let payload: Vec<u8> = (0..=255u8).cycle().take(4000).collect();
        let storage = vm.new_bytes(&payload);
        // Rooted for the syscall (what `op keepalive` guarantees in generated
        // code) while allocations -- each a collection under stress -- happen
        // between taking the address and making the call.
        vm.temp_roots.push(storage);
        let address = crate::runtime::ops::rt_bytes_addr(p, storage);
        for i in 0..50 {
            let _garbage = vm.new_bytes(&vec![i as u8; 4000]);
        }
        let (mut reader, writer) = std::io::pipe().unwrap();
        let fd = writer.as_raw_fd() as i64;
        // A pipe holds 64 KiB: 4000 bytes never block.
        let written = rt_linux_x86_64_syscall(
            p, small(WRITE), small(fd), address, small(payload.len() as i64), small(0), small(0), small(0),
        );
        assert_eq!(written, small(4000));
        drop(writer);
        let mut received = Vec::new();
        reader.read_to_end(&mut received).unwrap();
        assert_eq!(received, payload);
        vm.temp_roots.clear();
    }
}
