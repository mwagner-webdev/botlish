//! The borrow test fixture's synthetic foreign operations
//! (C-POINTER-BORROWING.md, "The fixture"; core/cabi.tcl's
//! installBorrowFixture is their Tcl model and their registration).
//!
//! There is no C call yet. These helpers stand in for one: each takes its
//! pointer operands as machine addresses and reads or writes the bytes
//! there exactly as C code given those pointers would -- with raw loads and
//! stores, trusting the count it is given (C does not know a buffer's
//! length) -- so a test observes the storage a byte exposure really hands
//! over, not a model of it. Only the fixture's natives lower to the
//! `ffifixture*` ops (native/lower.tcl), and only a test process registers
//! them, so no program outside a test can reach these.
//!
//! A pointer operand is either a byte exposure's payload address -- what
//! `bytesaddr` / `mbytesaddr` give for an argument native lowering exposes
//! (its BorrowCall), a small Int -- or an ordinary C address word (a raw
//! `ffi::c::Ptr` argument). Both are the same thing to the operation: an
//! address, which it neither keeps nor returns.
//!
//! Every op is a GC safepoint (ops.rs's op_may_allocate): foreign code may
//! run Botlish code during the call, which `read_reentrant` does on purpose
//! (a collection and same-sized allocations before it reads) -- the storage
//! behind an exposure must survive that, which only its `keepalive` after
//! the call guarantees.

use super::bytesobj::BytesObj;
use super::error::RtError;
use super::value::*;
use super::vm::Vm;

#[inline]
fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

fn type_error(p: *mut Vm, context: &str, what: &str, v: Value) -> Value {
    let message = format!("{context}: {what}, got {}", super::show::show(v));
    vm(p).fail(RtError::Semantic { kind: "TYPE", message })
}

/// The machine address pointer operand V carries.
fn address(p: *mut Vm, v: Value, context: &str) -> Result<*mut u8, Value> {
    if is_small(v) && small_of(v) >= 0 {
        return Ok(small_of(v) as usize as *mut u8);
    }
    if is_cptr(v) {
        return Ok(cptr_address(v) as usize as *mut u8);
    }
    Err(type_error(p, context, "expected an address (a byte exposure or a C pointer)", v))
}

/// The byte count operand V (a non-negative small Int).
fn count(p: *mut Vm, v: Value, context: &str) -> Result<usize, Value> {
    if is_small(v) && small_of(v) >= 0 {
        return Ok(small_of(v) as usize);
    }
    Err(type_error(p, context, "expected a byte count", v))
}

/// The bytes at A, as C reads them: COUNT raw loads.
fn load(a: *mut u8, count: usize) -> Vec<u8> {
    (0..count).map(|i| unsafe { std::ptr::read(a.add(i)) }).collect()
}

/// BYTES stored at A, as C writes them.
fn store(a: *mut u8, bytes: &[u8]) {
    for (i, b) in bytes.iter().enumerate() {
        unsafe { std::ptr::write(a.add(i), *b) };
    }
}

fn byte_list(p: *mut Vm, bytes: &[u8]) -> Value {
    vm(p).new_list(bytes.iter().map(|b| make_small(*b as i64)).collect())
}

macro_rules! operand {
    ($e:expr) => {
        match $e {
            Ok(v) => v,
            Err(failed) => return failed,
        }
    };
}

/// `ffifixtureread %p %n`: the N bytes at P, as a List of Ints.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_read(p: *mut Vm, ptr: Value, n: Value) -> Value {
    let a = operand!(address(p, ptr, "ffi_fixture::read"));
    let n = operand!(count(p, n, "ffi_fixture::read"));
    let bytes = load(a, n);
    byte_list(p, &bytes)
}

/// The most N-byte storages `read_reentrant` allocates.
const REENTRANT_ALLOCATIONS: usize = 256;

/// `ffifixturereadreentrant %p %n`: like read, but first runs what foreign
/// code calling back into Botlish might -- a collection, then allocations of
/// N-byte storages filled with 0xee (the size class of an N-byte exposure)
/// until one's payload is at P, at most REENTRANT_ALLOCATIONS -- and only
/// then reads. Which of its free blocks of that size malloc returns first is
/// not ours to predict, so a fixed few allocations would reuse a block the
/// collection wrongly freed only by luck (four did on one build and not on
/// another); a live block is never returned, and then all of them are made.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_read_reentrant(p: *mut Vm, ptr: Value, n: Value) -> Value {
    let a = operand!(address(p, ptr, "ffi_fixture::read_reentrant"));
    let n = operand!(count(p, n, "ffi_fixture::read_reentrant"));
    vm(p).collect_explicit();
    if n > 0 {
        let canary = vec![0xeeu8; n];
        for _ in 0..REENTRANT_ALLOCATIONS {
            let scratch = vm(p).new_bytes(&canary);
            if BytesObj::payload_address(scratch) == a as u64 {
                break;
            }
        }
    }
    let bytes = load(a, n);
    byte_list(p, &bytes)
}

/// `ffifixturefill %p %n %seed`: writes byte i = (SEED + 37 i) mod 256 at P,
/// for i < N.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_fill(p: *mut Vm, ptr: Value, n: Value, seed: Value) -> Value {
    let a = operand!(address(p, ptr, "ffi_fixture::fill"));
    let n = operand!(count(p, n, "ffi_fixture::fill"));
    let seed = operand!(count(p, seed, "ffi_fixture::fill"));
    let bytes: Vec<u8> = (0..n).map(|i| ((seed + 37 * i) % 256) as u8).collect();
    store(a, &bytes);
    UNIT
}

/// `ffifixturefillchecked %p %n %limit`: writes min(N, LIMIT) bytes (91 + 37
/// i) mod 256 at P, then fails with the declared UpperOverrun if N > LIMIT
/// (a foreign operation that writes part of its output and then reports
/// failure).
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_fill_checked(p: *mut Vm, ptr: Value, n: Value, limit: Value) -> Value {
    let a = operand!(address(p, ptr, "ffi_fixture::fill_checked"));
    let n = operand!(count(p, n, "ffi_fixture::fill_checked"));
    let limit = operand!(count(p, limit, "ffi_fixture::fill_checked"));
    let bytes: Vec<u8> = (0..n.min(limit)).map(|i| ((91 + 37 * i) % 256) as u8).collect();
    store(a, &bytes);
    if n > limit {
        return super::ops::fail_builtin(p, super::error::ERR_UPPER_OVERRUN, "UpperOverrun");
    }
    UNIT
}

/// `ffifixturecopy %dst %src %n`: DST[i] = SRC[i] for i < N.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_copy(p: *mut Vm, dst: Value, src: Value, n: Value) -> Value {
    let d = operand!(address(p, dst, "ffi_fixture::copy"));
    let s = operand!(address(p, src, "ffi_fixture::copy"));
    let n = operand!(count(p, n, "ffi_fixture::copy"));
    let bytes = load(s, n);
    store(d, &bytes);
    UNIT
}

/// `ffifixturemixed %input %state %output %n`: OUTPUT[i] = INPUT[N-1-i] for
/// i < N; the sum of INPUT's bytes. STATE is a userdata address it is
/// allowed to keep (and does not touch).
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_fixture_mixed(p: *mut Vm, input: Value, state: Value, output: Value, n: Value) -> Value {
    let i = operand!(address(p, input, "ffi_fixture::mixed"));
    operand!(address(p, state, "ffi_fixture::mixed"));
    let o = operand!(address(p, output, "ffi_fixture::mixed"));
    let n = operand!(count(p, n, "ffi_fixture::mixed"));
    let mut bytes = load(i, n);
    let sum: i64 = bytes.iter().map(|b| *b as i64).sum();
    bytes.reverse();
    store(o, &bytes);
    vm(p).new_int(sum)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::bytesobj::BytesObj;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::ops::{rt_bytes_addr, rt_mbytes_addr};
    use crate::runtime::vm::{ProgramInfo, Vm};

    fn vm() -> Box<Vm> {
        Vm::new(
            std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }),
            AllocMode::Summary,
        )
    }

    fn ints(list: Value) -> Vec<i64> {
        list_of(list).items().iter().map(|v| small_of(*v)).collect()
    }

    #[test]
    fn read_goes_through_the_exposed_address() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let data = vm.new_bytes(&[65, 0, 255, 7]);
        vm.temp_roots.push(data);
        // The address a read exposure hands over: bytesaddr's own result.
        let address = rt_bytes_addr(p, data);
        assert_eq!(small_of(address) as u64, BytesObj::payload_address(data));
        let read = rt_ffi_fixture_read(p, address, make_small(4));
        assert_eq!(ints(read), vec![65, 0, 255, 7]);
        // A prefix: the count is the caller's, the address carries no bounds.
        assert_eq!(ints(rt_ffi_fixture_read(p, address, make_small(2))), vec![65, 0]);
    }

    #[test]
    fn fill_and_copy_write_through_the_exposed_address() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let out = vm.new_mutbytes_with(5, |init| init.push_slice(&[9; 5]));
        vm.temp_roots.push(out);
        let address = rt_mbytes_addr(p, out);
        assert_eq!(rt_ffi_fixture_fill(p, address, make_small(3), make_small(250)), UNIT);
        assert_eq!(mutbytes_of(out), &[250, 31, 68, 9, 9]);
        let src = vm.new_bytes(&[1, 2, 3, 4, 5]);
        vm.temp_roots.push(src);
        assert_eq!(rt_ffi_fixture_copy(p, address, rt_bytes_addr(p, src), make_small(5)), UNIT);
        assert_eq!(mutbytes_of(out), &[1, 2, 3, 4, 5]);
    }

    #[test]
    fn a_null_raw_pointer_with_no_bytes_is_never_dereferenced() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        assert_eq!(ints(rt_ffi_fixture_read(p, CPTR_NULL, make_small(0))), Vec::<i64>::new());
        assert_eq!(rt_ffi_fixture_fill(p, CPTR_NULL, make_small(0), make_small(1)), UNIT);
    }

    #[test]
    fn fill_checked_writes_its_part_then_fails_declared() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let out = vm.new_mutbytes_with(3, |init| init.push_slice(&[0; 3]));
        vm.temp_roots.push(out);
        let address = rt_mbytes_addr(p, out);
        assert_eq!(rt_ffi_fixture_fill_checked(p, address, make_small(3), make_small(2)), NO_VALUE);
        assert_eq!(vm.declared_error, crate::runtime::error::ERR_UPPER_OVERRUN);
        assert_eq!(mutbytes_of(out), &[91, 128, 0]);
    }

    #[test]
    fn a_rooted_exposure_survives_the_reentrant_collection() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let data = vm.new_bytes(&[3, 1, 4, 1, 5, 9, 2, 6]);
        vm.temp_roots.push(data);
        let address = rt_bytes_addr(p, data);
        let read = rt_ffi_fixture_read_reentrant(p, address, make_small(8));
        assert_eq!(ints(read), vec![3, 1, 4, 1, 5, 9, 2, 6]);
    }

    #[test]
    fn mixed_reverses_and_sums_and_leaves_the_state_alone() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let input = vm.new_bytes(&[10, 20, 30]);
        vm.temp_roots.push(input);
        let output = vm.new_mutbytes_with(3, |init| init.push_slice(&[0; 3]));
        vm.temp_roots.push(output);
        let sum = rt_ffi_fixture_mixed(p, rt_bytes_addr(p, input), CPTR_NULL, rt_mbytes_addr(p, output), make_small(3));
        assert_eq!(small_of(sum), 60);
        assert_eq!(mutbytes_of(output), &[30, 20, 10]);
        assert_eq!(bytes_of(input), &[10, 20, 30]);
    }

    #[test]
    fn an_operand_that_is_no_address_is_a_type_error() {
        let mut vm = vm();
        let p: *mut Vm = &mut *vm;
        let s = vm.new_bytes(&[1]);
        vm.temp_roots.push(s);
        assert_eq!(rt_ffi_fixture_read(p, s, make_small(1)), NO_VALUE);
        assert_eq!(rt_ffi_fixture_read(p, make_small(-1), make_small(1)), NO_VALUE);
    }
}
