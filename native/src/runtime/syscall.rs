//! The Linux syscall transports (core/linuxabi.tcl, LINUX-X86-64-SYSCALL.md,
//! LINUX-SYSCALL-TRANSPORTS.md): the raw kernel transitions Botlish code can
//! make, one per architecture -- `linux::abi::x86_64::syscall` on Linux
//! x86-64 and `linux::abi::aarch64::syscall` on Linux AArch64.
//!
//! Two layers per architecture, and only the first is privileged:
//!
//! * [`botlish_linux_x86_64_syscall`] and [`botlish_linux_aarch64_syscall`]
//!   **are the privileged boundaries**: seven 64-bit register words in, one
//!   out, through the architecture's syscall instruction itself (inline
//!   `asm!` -- x86-64's `syscall`, AArch64's `svc #0` -- never libc's
//!   `syscall(3)`, `getpid` or any other wrapper). Each is a plain register
//!   bridge: it does not know any syscall number, interprets no result (no
//!   errno, no `-1`), retries nothing, caches nothing and selects no vDSO
//!   entry.
//! * [`rt_linux_x86_64_syscall`] and [`rt_linux_aarch64_syscall`] are the
//!   ordinary runtime helpers generated code calls (NIR `op
//!   syscall_linux_x86_64` / `op syscall_linux_aarch64`): each reads the
//!   seven operand Ints as the 64-bit words they are proven to be, calls its
//!   boundary, and returns the result register read as a signed 64-bit Int
//!   (`Vm::new_int`: a small Int immediate, or a BigInt only when outside
//!   the small range).
//!
//! A boundary is entered through the platform's ordinary function calling
//! convention (System V on x86-64: arguments in rdi, rsi, rdx, rcx, r8, r9,
//! then the stack; AAPCS64 on AArch64: x0..x7). That is *not* the kernel's:
//! each asm block places every word in the register its Linux syscall
//! convention names -- on x86-64 argument 4 in r10, never rcx, which the
//! `syscall` instruction itself overwrites; on AArch64 the number in x8 and
//! arguments 1-6 in x0..x5 -- so nothing depends on the function convention
//! happening to leave words in the right registers.
//!
//! Clobbers and effects, all declared to the compiler of this file (and so
//! true of every caller). x86-64: `syscall` overwrites rcx (the return rip)
//! and r11 (the saved rflags) and returns in rax. AArch64: the kernel
//! returns in x0 and restores every other register. Neither declares the
//! flags preserved, and the kernel does not touch the user stack
//! (`nostack`). There is no `pure`, `nomem` or `readonly`: the kernel may
//! read and write any user memory through pointer arguments, block, and
//! return different results for equal inputs, so the block is never merged,
//! hoisted or removed. In generated code the operation is a helper `call`,
//! which Cranelift likewise treats as reading and writing all memory and as
//! clobbering every caller-saved register (a superset of the instruction's
//! own clobbers); the kernel preserves the callee-saved ones.
//!
//! Target gating: each boundary exists only when compiling for its own Linux
//! architecture. Both ops compile for every target (codegen/clif.rs), so a
//! program that only defines a syscall runs; running a transport on any
//! other target fails with NATIVE UNSUPPORTED (`syscall_words_*` below),
//! never with another architecture's convention.

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

/// The AArch64 `svc #0` instruction with X8 = `x8` (the syscall number) and
/// X0..X5 = arguments 1-6; returns X0 afterwards, unmodified.
///
/// # Safety
///
/// It performs whatever system call `x8` names, with whatever the argument
/// words mean to the kernel (including pointers into this process's memory).
/// The caller is responsible for that call being one it means to make.
#[cfg(all(target_arch = "aarch64", target_os = "linux"))]
#[unsafe(no_mangle)]
#[inline(never)]
pub unsafe extern "C" fn botlish_linux_aarch64_syscall(
    x8: i64,
    x0: i64,
    x1: i64,
    x2: i64,
    x3: i64,
    x4: i64,
    x5: i64,
) -> i64 {
    let result: i64;
    // SAFETY: the caller's contract (above). The operand constraints are
    // exactly the Linux AArch64 syscall register convention: the number in
    // x8, arguments 1-6 in x0..x5, the result in x0 (argument 1's register);
    // the kernel restores every other register.
    unsafe {
        core::arch::asm!(
            "svc #0",
            in("x8") x8,
            inlateout("x0") x0 => result,
            in("x1") x1,
            in("x2") x2,
            in("x3") x3,
            in("x4") x4,
            in("x5") x5,
            options(nostack),
        );
    }
    result
}

/// The 64-bit register word an operand Int denotes: the Int itself, which
/// HIR proved to be in -2^63..2^63-1 (a Register64's `word`, lib/abi/
/// x86_64.bot, lib/abi/aarch64.bot) -- its two's-complement bit pattern is
/// the register contents. None for anything else (a backend bug: never
/// truncated).
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

/// The seven register words of the operands of transport NATIVE (register
/// names REGISTERS, in its convention's order), or the TYPE failure for the
/// first operand that is not such an Int -- which a checked program cannot
/// produce (a Register64's word is proven), but an unchecked (-strict 0)
/// program can, by constructing a Register64 whose word HIR rejected: a TYPE
/// error then, before any transition, and never a truncation.
fn register_words(p: *mut Vm, native: &str, registers: [&str; 7], operands: [Value; 7]) -> Result<[i64; 7], Value> {
    let mut words = [0i64; 7];
    for (i, v) in operands.into_iter().enumerate() {
        match register_word(v) {
            Some(w) => words[i] = w,
            None => {
                let register = registers[i];
                return Err(vm(p).fail(RtError::Semantic {
                    kind: "TYPE",
                    message: format!(
                        "{native}: register {register} is not a 64-bit register word (an Int in -2^63..2^63-1)"
                    ),
                }));
            }
        }
    }
    Ok(words)
}

/// `linux::abi::x86_64::syscall`: RAX (the syscall number) and RDI, RSI,
/// RDX, R10, R8, R9 (arguments 1-6; an argument the source omitted is the
/// Int 0) are Ints in -2^63..2^63-1; the result is the raw RAX afterwards,
/// read as a signed 64-bit Int. Fails only on an operand that is not such an
/// Int (`register_words`), or, on any target but Linux x86-64, as NATIVE
/// UNSUPPORTED.
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
    match register_words(
        p,
        "std::linux::abi::x86_64::syscall",
        ["rax", "rdi", "rsi", "rdx", "r10", "r8", "r9"],
        [rax, rdi, rsi, rdx, r10, r8, r9],
    ) {
        Ok(words) => syscall_words_x86_64(p, words),
        Err(failed) => failed,
    }
}

/// `linux::abi::aarch64::syscall`: X8 (the syscall number) and X0..X5
/// (arguments 1-6; an argument the source omitted is the Int 0) are Ints in
/// -2^63..2^63-1; the result is the raw X0 afterwards, read as a signed
/// 64-bit Int. Fails only on an operand that is not such an Int
/// (`register_words`), or, on any target but Linux AArch64, as NATIVE
/// UNSUPPORTED.
#[unsafe(no_mangle)]
pub extern "C" fn rt_linux_aarch64_syscall(
    p: *mut Vm,
    x8: Value,
    x0: Value,
    x1: Value,
    x2: Value,
    x3: Value,
    x4: Value,
    x5: Value,
) -> Value {
    match register_words(
        p,
        "std::linux::abi::aarch64::syscall",
        ["x8", "x0", "x1", "x2", "x3", "x4", "x5"],
        [x8, x0, x1, x2, x3, x4, x5],
    ) {
        Ok(words) => syscall_words_aarch64(p, words),
        Err(failed) => failed,
    }
}

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
fn syscall_words_x86_64(p: *mut Vm, w: [i64; 7]) -> Value {
    // SAFETY: Botlish's linux::abi::x86_64::syscall is exactly a request to
    // make this system call (the program's own register words, unmodified).
    let rax = unsafe { botlish_linux_x86_64_syscall(w[0], w[1], w[2], w[3], w[4], w[5], w[6]) };
    result_value(vm(p), rax)
}

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
fn syscall_words_x86_64(p: *mut Vm, _w: [i64; 7]) -> Value {
    // Any other target: running the transport is unsupported (the op
    // compiles, so a program that only defines a syscall runs).
    vm(p).fail(RtError::Unsupported("std::linux::abi::x86_64::syscall needs a Linux x86-64 target".to_string()))
}

#[cfg(all(target_arch = "aarch64", target_os = "linux"))]
fn syscall_words_aarch64(p: *mut Vm, w: [i64; 7]) -> Value {
    // SAFETY: Botlish's linux::abi::aarch64::syscall is exactly a request to
    // make this system call (the program's own register words, unmodified).
    let x0 = unsafe { botlish_linux_aarch64_syscall(w[0], w[1], w[2], w[3], w[4], w[5], w[6]) };
    result_value(vm(p), x0)
}

#[cfg(not(all(target_arch = "aarch64", target_os = "linux")))]
fn syscall_words_aarch64(p: *mut Vm, _w: [i64; 7]) -> Value {
    // Any other target: running the transport is unsupported (the op
    // compiles, so a program that only defines a syscall runs).
    vm(p).fail(RtError::Unsupported("std::linux::abi::aarch64::syscall needs a Linux AArch64 target".to_string()))
}

/// The raw result register word as the Int it denotes under the signed
/// reading (a kernel error return such as -38 stays -38; nothing is
/// interpreted): a small Int immediate, or a BigInt outside the small range.
pub fn result_value(vm: &mut Vm, word: i64) -> Value {
    vm.new_int(word)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    pub(super) fn new_vm() -> Box<Vm> {
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Off,
        )
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
    fn helpers_never_truncate_a_non_word_operand() {
        // Checked before any transition, so on every target: no syscall is
        // made, whichever architecture runs the test.
        type Helper = extern "C" fn(*mut Vm, Value, Value, Value, Value, Value, Value, Value) -> Value;
        let helpers: [(Helper, &str, &str); 2] = [
            (rt_linux_x86_64_syscall, "std::linux::abi::x86_64::syscall: register rdi", "register rsi"),
            (rt_linux_aarch64_syscall, "std::linux::abi::aarch64::syscall: register x0", "register x1"),
        ];
        for (helper, first, second) in helpers {
            let mut vm = new_vm();
            let p = &mut *vm as *mut Vm;
            let zero = make_small(0);
            let r = helper(p, make_small(39), UNIT, zero, zero, zero, zero, zero);
            assert_eq!(r, NO_VALUE);
            assert!(matches!(&vm.error, Some(RtError::Semantic { kind: "TYPE", message }) if message.starts_with(first)));
            // A BigInt beyond i64 (2^64), as an unchecked program could build.
            let mut other = new_vm();
            let q = &mut *other as *mut Vm;
            let beyond = other.new_big(num_bigint::BigInt::from(1u128 << 64));
            let r = helper(q, make_small(39), zero, beyond, zero, zero, zero, zero);
            assert_eq!(r, NO_VALUE);
            assert!(matches!(&other.error, Some(RtError::Semantic { kind: "TYPE", message }) if message.contains(second)));
        }
    }

    #[test]
    fn the_other_architectures_transport_is_unsupported() {
        // A transport runs only on its own architecture: the other one fails
        // with NATIVE UNSUPPORTED, never with this architecture's convention.
        #[cfg(target_arch = "aarch64")]
        let (other, name): (extern "C" fn(*mut Vm, Value, Value, Value, Value, Value, Value, Value) -> Value, _) =
            (rt_linux_x86_64_syscall, "std::linux::abi::x86_64::syscall needs a Linux x86-64 target");
        #[cfg(not(target_arch = "aarch64"))]
        let (other, name): (extern "C" fn(*mut Vm, Value, Value, Value, Value, Value, Value, Value) -> Value, _) =
            (rt_linux_aarch64_syscall, "std::linux::abi::aarch64::syscall needs a Linux AArch64 target");
        let mut vm = new_vm();
        let p = &mut *vm as *mut Vm;
        let zero = make_small(0);
        let r = other(p, make_small(39), zero, zero, zero, zero, zero, zero);
        assert_eq!(r, NO_VALUE);
        assert!(matches!(&vm.error, Some(RtError::Unsupported(message)) if message == name));
    }

    /// ABI numeric values (lib/abi.bot) reach the kernel as their x86-64
    /// and AArch64 register bit patterns (ABI-NUMERIC-DOMAINS.md). Each word is built
    /// the way generated code builds it -- abi::x86_64::from_* (and
    /// abi::aarch64::from_*, the same source) passes a
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
    fn results_are_read_signed() {
        // getpid's result is always a small positive pid, so the reading of
        // negative words (kernel error returns are -4095..-1) is pinned here,
        // without making any other syscall.
        let mut vm = new_vm();
        for (raw, expected) in [(-1i64, "-1"), (-38, "-38"), (-4095, "-4095"), (0, "0"), (i64::MIN, "-9223372036854775808"),
            (i64::MAX, "9223372036854775807"), (SMALL_MIN - 1, "-4611686018427387905")]
        {
            let v = result_value(&mut vm, raw);
            assert_eq!(int_to_big(v).to_string(), expected);
        }
    }
}

/// The live syscalls of the suite, on whichever Linux architecture runs it:
/// getpid (harmless, argument-free, no failure case) and write(2) to a pipe
/// the test owns (or an invalid descriptor), through the architecture's own
/// generic boundary. The numbers are test data here, exactly as in Botlish
/// source (lib/linux/sys.x86_64.bot, lib/linux/sys.aarch64.bot); nothing in
/// the runtime knows them.
#[cfg(all(test, target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
mod live {
    use super::tests::new_vm;
    use super::*;

    #[cfg(target_arch = "x86_64")]
    mod arch {
        pub const GETPID: i64 = 39;
        pub const WRITE: i64 = 1;
        pub use super::super::{botlish_linux_x86_64_syscall as boundary, rt_linux_x86_64_syscall as helper};
    }

    #[cfg(target_arch = "aarch64")]
    mod arch {
        pub const GETPID: i64 = 172;
        pub const WRITE: i64 = 64;
        pub use super::super::{botlish_linux_aarch64_syscall as boundary, rt_linux_aarch64_syscall as helper};
    }

    use arch::{boundary, helper, GETPID, WRITE};

    fn this_pid() -> i64 {
        std::process::id() as i64
    }

    fn small(n: i64) -> Value {
        make_small(n)
    }

    #[test]
    fn boundary_getpid_is_this_process() {
        let pid = unsafe { boundary(GETPID, 0, 0, 0, 0, 0, 0) };
        assert_eq!(pid, this_pid());
        let again = unsafe { boundary(GETPID, 0, 0, 0, 0, 0, 0) };
        assert_eq!(pid, again);
    }

    #[test]
    fn boundary_ignores_unused_argument_registers() {
        // getpid takes no arguments: whatever the six argument registers
        // hold, the kernel returns the same pid.
        let pid = unsafe { boundary(GETPID, -1, i64::MIN, i64::MAX, 7, 8, 9) };
        assert_eq!(pid, this_pid());
    }

    #[test]
    fn helper_returns_the_result_register_as_an_int() {
        let mut vm = new_vm();
        let p = &mut *vm as *mut Vm;
        let zero = make_small(0);
        let nr = make_small(GETPID);
        let r = helper(p, nr, zero, zero, zero, zero, zero, zero);
        assert_eq!(int_small(r), Some(this_pid()));
        // BigInt operands (the i64 extremes) are read as their words too.
        // Rooted (as compiled code's stack maps root operands): BIG_MAX's
        // allocation may collect, always under BOTLISH_NATIVE_GC_STRESS=1.
        let big_min = vm.new_int(i64::MIN);
        vm.temp_roots.push(big_min);
        let big_max = vm.new_int(i64::MAX);
        vm.temp_roots.push(big_max);
        let r = helper(p, nr, big_min, big_max, zero, zero, zero, zero);
        assert_eq!(int_small(r), Some(this_pid()));
    }

    // -----------------------------------------------------------------------
    // write(2) over an owned byte storage (ABI-BYTES.md): the second live
    // syscall the suite makes.

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
        let written = helper(p, small(WRITE), small(fd), address, length, small(0), small(0), small(0));
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
        let zero = helper(p, small(WRITE), small(fd), address, small(0), small(0), small(0), small(0));
        assert_eq!(zero, small(0));
        // An invalid descriptor, even with a zero count: -EBADF (9 on both
        // architectures: the generic errno table), kept negative.
        let bad = helper(p, small(WRITE), small(1000), address, small(0), small(0), small(0), small(0));
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
        let written =
            helper(p, small(WRITE), small(fd), address, small(payload.len() as i64), small(0), small(0), small(0));
        assert_eq!(written, small(4000));
        drop(writer);
        let mut received = Vec::new();
        reader.read_to_end(&mut received).unwrap();
        assert_eq!(received, payload);
        vm.temp_roots.clear();
    }
}
