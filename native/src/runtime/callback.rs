//! Synchronous C callbacks (C-CALLBACK-MILESTONE-1.md): the runtime half of
//! a Botlish -> C -> Botlish round trip.
//!
//! # Transitions and activations
//!
//! A Botlish function calls a C function whose contract lets it call back (a
//! function pointer parameter it does not keep: nir.rs's `callbacks=1`)
//! through a *transition shim* (codegen::callback): a small function of the
//! C function's own signature, plus the Vm, that calls `rt_ffi_open` before
//! the C call and `rt_ffi_close` after it. `rt_ffi_open` records the shim's
//! frame record -- whose return address is the Botlish caller's call site, a
//! safepoint with every live root of that frame in its stack map -- on the
//! Vm (`Vm::foreign_open`), and makes this thread's *active* execution
//! environment that Vm (`ACTIVE`): C runs, and the Vm waits in it.
//!
//! A callback's C entry point (codegen::callback's trampoline) stores its C
//! arguments as words and calls `rt_callback_call`, which runs the callback
//! in the active execution environment only:
//!
//!   * this thread must have one: a Vm waiting in a transition (`ACTIVE`).
//!     On a thread with none -- a C thread, or the program's own thread
//!     outside any transition (C kept the pointer past the call that gave it,
//!     or calls it during a call whose contract does not let it call back)
//!     -- nothing runs: the process ends with NATIVE CALLBACK THREAD or
//!     NATIVE CALLBACK INACTIVE before any Botlish code. The pointer
//!     selects no execution environment and is no authority to make one: no
//!     Vm, actor, context or heap is ever created here;
//!   * the callback's code must be that environment's program's
//!     (`Vm::program_token`): two programs' runtimes never share a Vm;
//!   * C must call it on the stack the transition left (the running stack,
//!     below the transition's frame): the collector's walk crosses from the
//!     callback's frames to the transition's, which only one stack holds
//!     (NATIVE CALLBACK STACK otherwise).
//!
//! The callback then runs nested in that same Vm: no new heap, context area,
//! statics or coroutine chain. The Vm is no longer waiting in C (`ACTIVE`
//! cleared: a call of the pointer from the callback's own C calls needs
//! their own transition), and its *segment* -- this function's frame record
//! and the transition's -- is pushed for the collector (`Vm::
//! callback_segments`, framewalk::walk_segmented): a collection during the
//! callback walks its frames, jumps from here to the transition shim's
//! record, and goes on through the Botlish frame that called C, never
//! reading C's frames. Returning restores everything exactly: the segment
//! popped, the Vm waiting in C again.
//!
//! # Failure is fatal
//!
//! A C callback has no error channel. The front end proves a callback
//! raises no declared error and never suspends (hir/callbacks.tcl), and
//! every conversion at the boundary is total but a C `_Bool` byte other than
//! 0 or 1 and an address the C address word cannot hold. Whatever still
//! fails -- a run-time failure of the body, such a value, a refused entry, a
//! panic of this runtime -- ends the process here, after its report
//! (runtime::platform's `report_fatal`: the driver's result line, or the
//! message on standard error). Nothing unwinds into C, no value is made up
//! for C to receive, and nothing returns to C with the runtime's state
//! changed.
use super::error::RtError;
use super::value::*;
use super::vm::Vm;
use crate::nir::CAbi;
use std::cell::Cell;
use std::sync::atomic::{AtomicUsize, Ordering};

/// Whether this host runs C callbacks: where the collector walks frames by
/// frame pointer (framewalk's `walk_segmented` crosses a transition), with
/// the stack guard bounding recursion -- Linux x86-64 and AArch64, macOS
/// AArch64. Windows walks frames by its unwinder and the fallback plan
/// keeps roots on a shadow stack, neither of which crosses a transition
/// yet: there a program with a callback is refused before it runs
/// (codegen::callback, NATIVE UNSUPPORTED callback).
pub const SUPPORTED: bool = super::framewalk::NATIVE_FRAME_ROOTS && cfg!(not(windows));

thread_local! {
    /// The execution environment waiting in a transition on this thread:
    /// the Vm whose innermost foreign call may call back now, or null.
    static ACTIVE: Cell<*mut Vm> = const { Cell::new(std::ptr::null_mut()) };
}

/// The thread that opened a transition in this runtime last (the address of
/// its ACTIVE slot, a token no other live thread has), or 0: what tells a
/// callback on another thread (NATIVE CALLBACK THREAD) from one on the
/// program's own thread outside any transition (NATIVE CALLBACK INACTIVE).
/// A diagnosis only -- the refusal is the same -- kept with plain loads and
/// stores, so a transition costs no locked instruction.
static LAST_THREAD: AtomicUsize = AtomicUsize::new(0);

/// The C ABI classes a callback descriptor names, by code (codegen::callback
/// writes them; `class_of` reads them).
const CLASSES: [CAbi; 15] = [
    CAbi::I8,
    CAbi::U8,
    CAbi::I16,
    CAbi::U16,
    CAbi::I32,
    CAbi::U32,
    CAbi::I64,
    CAbi::U64,
    CAbi::Bool,
    CAbi::F32,
    CAbi::F64,
    CAbi::RawF32,
    CAbi::RawF64,
    CAbi::Ptr,
    CAbi::Void,
];

/// The descriptor code of class C.
pub fn class_code(c: CAbi) -> u8 {
    CLASSES.iter().position(|&k| k == c).expect("every class has a code") as u8
}

fn class_of(code: u8) -> Option<CAbi> {
    CLASSES.get(code as usize).copied()
}

/// A callback's descriptor, the read-only data its entry point passes:
/// `[result, count, param classes..., name bytes...]` (codegen::callback's
/// `descriptor`).
pub fn descriptor(params: &[CAbi], result: CAbi, name: &str) -> Vec<u8> {
    let mut bytes = vec![class_code(result), params.len() as u8];
    bytes.extend(params.iter().map(|&c| class_code(c)));
    bytes.extend_from_slice(name.as_bytes());
    bytes
}

/// A callback's descriptor as read in place: nothing is allocated to read
/// one (a callback's success path allocates nothing of the runtime's own;
/// only the messages of a failure do).
struct Descriptor<'a> {
    result: CAbi,
    /// The parameters' class codes, every one valid (`read_descriptor`).
    params: &'a [u8],
    name: &'a [u8],
}

impl Descriptor<'_> {
    /// "callback NAME", for messages.
    fn what(&self) -> String {
        format!("callback {}", String::from_utf8_lossy(self.name))
    }

    fn param(&self, index: usize) -> CAbi {
        class_of(self.params[index]).unwrap_or(CAbi::Void)
    }
}

/// Reads the descriptor at DESC, LEN bytes long.
///
/// # Safety
/// DESC is a callback entry point's own descriptor, which lives as long as
/// the program's code.
unsafe fn read_descriptor<'a>(desc: *const u8, len: usize) -> Option<Descriptor<'a>> {
    // SAFETY: the caller's contract.
    let bytes = unsafe { std::slice::from_raw_parts(desc, len) };
    let result = class_of(*bytes.first()?)?;
    let count = *bytes.get(1)? as usize;
    let params = bytes.get(2..2 + count)?;
    if params.iter().any(|&c| class_of(c).is_none()) {
        return None;
    }
    let name = bytes.get(2 + count..)?;
    Some(Descriptor { result, params, name })
}

/// Opens a foreign transition of VM (`rt_ffi_open`'s work), CALLER being the
/// transition shim's frame record. Returns the environment that was active
/// before (always null when Botlish code makes the call: a running callback
/// cleared it).
fn open(p: *mut Vm, caller: usize) -> *mut Vm {
    // SAFETY: generated code passes the Vm it runs on.
    let vm = unsafe { &mut *p };
    vm.foreign_open.push(caller);
    ACTIVE.with(|a| {
        let me = a as *const Cell<*mut Vm> as usize;
        if LAST_THREAD.load(Ordering::Relaxed) != me {
            LAST_THREAD.store(me, Ordering::Relaxed);
        }
        a.replace(p)
    })
}

/// `rt_ffi_open(vm)`, called by a transition shim right before its C call:
/// records the shim's frame record (its caller's, read from this function's
/// own record: the frame-pointer chain both keep) as the transition, and
/// makes VM this thread's active execution environment. Returns the one it
/// replaces, which `rt_ffi_close` restores.
#[unsafe(no_mangle)]
#[inline(never)]
pub extern "C" fn rt_ffi_open(p: *mut Vm) -> u64 {
    // SAFETY: this function's own frame record holds its caller's frame
    // pointer first (both frames keep the chain: codegen's frames, and this
    // crate's under -C force-frame-pointers=yes, framewalk's header).
    let caller = unsafe { *(super::framewalk::frame_record() as *const usize) };
    open(p, caller) as u64
}

/// `rt_ffi_close(vm, previous)`, called by a transition shim right after
/// its C call returned: closes VM's innermost transition and makes PREVIOUS
/// (rt_ffi_open's result) the active environment again.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_close(p: *mut Vm, previous: u64) -> u64 {
    // SAFETY: generated code passes the Vm it runs on.
    let vm = unsafe { &mut *p };
    let closed = vm.foreign_open.pop();
    ACTIVE.with(|a| a.set(previous as *mut Vm));
    // Every callback that entered through this transition has returned:
    // a segment still naming it would let the collector jump into frames
    // that no longer exist.
    if closed.is_some() && vm.callback_segments.last().is_some_and(|&(_, t)| Some(t) == closed) {
        Fatal::new(&["NATIVE", "CALLBACK", "BUG"], "a callback's segment outlived the foreign call it entered through").terminate();
    }
    0
}

/// Why a callback did not complete: its error code (NATIVE CALLBACK KIND)
/// and its message.
struct Fatal {
    code: &'static [&'static str],
    message: String,
}

impl Fatal {
    fn new(code: &'static [&'static str], message: impl Into<String>) -> Fatal {
        Fatal { code, message: message.into() }
    }

    /// Reports the failure and ends the process (`report_fatal`).
    fn terminate(self) -> ! {
        let code = self.code.join(" ");
        let result = format!(
            "{}\n",
            super::show::tcl_list(&["error".to_string(), super::show::tcl_list(&self.code.iter().map(|w| w.to_string()).collect::<Vec<_>>()), self.message.clone()])
        );
        let line = format!("{} ({code})\n", self.message);
        #[cfg(unix)]
        super::platform::report_fatal(result.as_bytes(), line.as_bytes());
        #[cfg(not(unix))]
        {
            let _ = result;
            eprint!("{line}");
            std::process::exit(1)
        }
    }
}

/// `rt_callback_call(entry, desc, words, out)`: one call of a callback's C
/// entry point. ENTRY is the callback function's generic entry, DESC its
/// descriptor (DESC_LEN bytes, `descriptor`), WORDS its C arguments as 64-bit
/// words (an integer extended by its signedness, a `_Bool` 0 or 1, a
/// floating value's bits, an address) and OUT where its C result's word
/// goes. Returns 0 -- or never: every failure ends the process (the module
/// header). Nothing unwinds out of it.
///
/// # Safety
/// The callback entry point's contract: its own ENTRY, DESC and DESC_LEN,
/// and WORDS and OUT its own stack slots.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rt_callback_call(entry: u64, desc: u64, desc_len: u64, words: u64, out: u64) -> u64 {
    let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        // SAFETY: the caller's contract.
        let Some(decl) = (unsafe { read_descriptor(desc as *const u8, desc_len as usize) }) else {
            return Err(Fatal::new(&["NATIVE", "CALLBACK", "BUG"], "a callback entry point's descriptor is malformed"));
        };
        // SAFETY: the caller's contract.
        let args = unsafe { std::slice::from_raw_parts(words as *const u64, decl.params.len()) };
        // SAFETY: the caller's contract.
        unsafe { run(entry as usize, &decl, args, out as *mut u64) }
    }));
    match outcome {
        Ok(Ok(())) => 0,
        Ok(Err(fatal)) => fatal.terminate(),
        Err(_) => Fatal::new(&["NATIVE", "CALLBACK", "BUG"], "the runtime panicked while it ran a callback").terminate(),
    }
}

type GenericEntry = unsafe extern "C" fn(*mut Vm, Value, *const Value) -> Value;

/// Runs the callback DECL in this thread's active execution environment
/// (the module header), writing its C result's word to OUT. Never inlined:
/// its frame record is the segment's entry the collector's walk jumps from,
/// on the chain of every Botlish frame the callback makes.
///
/// # Safety
/// ENTRY is DECL's function's generic entry; OUT is writable.
#[inline(never)]
unsafe fn run(entry: usize, decl: &Descriptor, args: &[u64], out: *mut u64) -> Result<(), Fatal> {
    let p = ACTIVE.with(|a| a.get());
    if !SUPPORTED {
        return Err(Fatal::new(
            &["NATIVE", "CALLBACK", "UNSUPPORTED"],
            format!("{}: C callbacks run on Linux x86-64 and AArch64 and macOS AArch64, where the collector walks frames by frame pointer across a foreign call (C-CALLBACK-MILESTONE-1.md); nothing ran", decl.what()),
        ));
    }
    if p.is_null() {
        let me = ACTIVE.with(|a| a as *const Cell<*mut Vm> as usize);
        let last = LAST_THREAD.load(Ordering::Relaxed);
        if last != 0 && last != me {
            return Err(Fatal::new(
                &["NATIVE", "CALLBACK", "THREAD"],
                format!("{} was called on a thread with no Botlish execution environment waiting in a foreign call: a callback runs only synchronously, on the thread of the foreign call that may call it back, never on another thread; nothing ran", decl.what()),
            ));
        }
        return Err(Fatal::new(
            &["NATIVE", "CALLBACK", "INACTIVE"],
            format!("{} was called outside every foreign call that may call it back: C may call a callback only during a call whose contract lets it (a std::ffi::c::FnPtr parameter declared noescape), never after the call returned or during another; nothing ran", decl.what()),
        ));
    }
    // SAFETY: ACTIVE holds the Vm waiting in this thread's open transition,
    // alive while it waits.
    let vm = unsafe { &mut *p };
    let Some(&transition) = vm.foreign_open.last() else {
        return Err(Fatal::new(&["NATIVE", "CALLBACK", "BUG"], format!("{}: an active execution environment with no open transition", decl.what())));
    };
    let record = super::framewalk::frame_record();
    let on_stack = match vm.running_stack() {
        Some(stack) => stack.contains(record, 16) && stack.contains(transition, 16) && record < transition,
        None => record < transition,
    };
    if !on_stack {
        return Err(Fatal::new(
            &["NATIVE", "CALLBACK", "STACK"],
            format!("{} was called on another stack than the foreign call that may call it back: a callback runs on the stack of that call, which C left; nothing ran", decl.what()),
        ));
    }
    ACTIVE.with(|a| a.set(std::ptr::null_mut()));
    vm.callback_segments.push((record, transition));
    let roots = vm.temp_roots.len();
    // The arguments, rooted while the others are made (a raw value or a
    // BigInt allocates); up to sixteen in this frame, more in a Vec.
    let mut inline = [NO_VALUE; 16];
    let mut spilled = Vec::new();
    let values: &mut [Value] = if args.len() <= inline.len() {
        &mut inline[..args.len()]
    } else {
        spilled.resize(args.len(), NO_VALUE);
        &mut spilled
    };
    for (index, &word) in args.iter().enumerate() {
        let value = argument(vm, decl.param(index), word)
            .map_err(|why| Fatal::new(&["NATIVE", "CALLBACK", "ARGUMENT"], format!("{}: argument {}: {why}; nothing ran", decl.what(), index + 1)))?;
        vm.temp_roots.push(value);
        values[index] = value;
    }
    // SAFETY: ENTRY is a generic entry, called with one tagged Value per
    // parameter of the callback's declared types.
    let result = unsafe {
        let entry: GenericEntry = std::mem::transmute(entry);
        entry(vm, 0, values.as_ptr())
    };
    vm.temp_roots.truncate(roots);
    if result == NO_VALUE {
        let error = vm.error.take().unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
        let code = error.error_code().join(" ");
        return Err(Fatal::new(
            &["NATIVE", "CALLBACK", "FAILED"],
            format!("{} failed, and a C callback has no error channel to its C caller: {} ({code})", decl.what(), vm.describe_error(&error)),
        ));
    }
    let word = result_word(decl.result, result).map_err(|why| Fatal::new(&["NATIVE", "CALLBACK", "RESULT"], format!("{}: its result {why}", decl.what())))?;
    vm.callback_segments.pop();
    ACTIVE.with(|a| a.set(p));
    // SAFETY: the caller's contract.
    unsafe { *out = word };
    // Keeps this frame from becoming a tail call of the entry.
    std::hint::black_box(());
    Ok(())
}

/// The Botlish value of the C argument WORD of class CLASS: an Int of the C
/// integer's value, a bool of a `_Bool`, a raw C floating value of its bits,
/// a C address word. Err when C passed what no C value of the class is (a
/// `_Bool` byte but 0 or 1) or what the address word cannot hold.
fn argument(vm: &mut Vm, class: CAbi, word: u64) -> Result<Value, String> {
    Ok(match class {
        CAbi::I8 => vm.new_int(word as u8 as i8 as i64),
        CAbi::U8 => vm.new_int(word as u8 as i64),
        CAbi::I16 => vm.new_int(word as u16 as i16 as i64),
        CAbi::U16 => vm.new_int(word as u16 as i64),
        CAbi::I32 => vm.new_int(word as u32 as i32 as i64),
        CAbi::U32 => vm.new_int(word as u32 as i64),
        CAbi::I64 => vm.new_int(word as i64),
        CAbi::U64 => {
            if word <= i64::MAX as u64 {
                vm.new_int(word as i64)
            } else {
                vm.new_big(num_bigint::BigInt::from(word))
            }
        }
        CAbi::Bool => match word & 0xff {
            0 => FALSE,
            1 => TRUE,
            byte => return Err(format!("the C _Bool byte {byte} is neither 0 nor 1 (NATIVE BOOL)")),
        },
        CAbi::RawF32 => vm.new_raw_float(CFloatFormat::Binary32, word & 0xffff_ffff),
        CAbi::RawF64 => vm.new_raw_float(CFloatFormat::Binary64, word),
        CAbi::Ptr => {
            if !cptr_fits(word as i64) {
                return Err(format!("the address {word:#x} is no C address word can hold (NATIVE ADDRESS)"));
            }
            make_cptr(word as i64)
        }
        CAbi::F32 | CAbi::F64 | CAbi::Void => return Err(format!("{class:?} is no callback parameter class")),
    })
}

/// The C result word of the callback result V of class CLASS. The checker
/// proved V is of the declared type; Err only for a value of no such type
/// (an unchecked program's).
fn result_word(class: CAbi, v: Value) -> Result<u64, String> {
    let int = |v: Value| -> Option<i128> {
        if let Some(i) = int_small(v) {
            return Some(i as i128);
        }
        if is_small(v) || v == NO_VALUE || v & 7 != 0 || heap_kind(v) != KIND_BIGINT {
            return None;
        }
        num_traits::ToPrimitive::to_i128(big_of(v))
    };
    let ranged = |lo: i128, hi: i128| -> Result<u64, String> {
        match int(v) {
            Some(i) if i >= lo && i <= hi => Ok(i as u64),
            _ => Err(format!("is no value of its C type ({})", super::show::show(v))),
        }
    };
    match class {
        CAbi::I8 => ranged(i8::MIN as i128, i8::MAX as i128),
        CAbi::U8 => ranged(0, u8::MAX as i128),
        CAbi::I16 => ranged(i16::MIN as i128, i16::MAX as i128),
        CAbi::U16 => ranged(0, u16::MAX as i128),
        CAbi::I32 => ranged(i32::MIN as i128, i32::MAX as i128),
        CAbi::U32 => ranged(0, u32::MAX as i128),
        CAbi::I64 => ranged(i64::MIN as i128, i64::MAX as i128),
        CAbi::U64 => ranged(0, u64::MAX as i128),
        CAbi::Bool => match v {
            TRUE => Ok(1),
            FALSE => Ok(0),
            _ => Err(format!("is no bool ({})", super::show::show(v))),
        },
        CAbi::F64 => {
            if is_small(v) || v == NO_VALUE || v & 7 != 0 || heap_kind(v) != KIND_FLOAT {
                return Err(format!("is no Float64 ({})", super::show::show(v)));
            }
            Ok(float64_of(v).to_bits())
        }
        CAbi::RawF32 | CAbi::RawF64 => {
            let format = if class == CAbi::RawF32 { CFloatFormat::Binary32 } else { CFloatFormat::Binary64 };
            if raw_format_of(v) != Some(format) {
                return Err(format!("is no raw C floating value of its format ({})", super::show::show(v)));
            }
            Ok(raw_bits(v))
        }
        CAbi::Ptr => {
            if !is_cptr(v) {
                return Err(format!("is no C address ({})", super::show::show(v)));
            }
            Ok(cptr_address(v) as u64)
        }
        CAbi::Void => Ok(0),
        CAbi::F32 => Err("is a C float, which no callback returns".to_string()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn descriptors_read_back() {
        let bytes = descriptor(&[CAbi::I32, CAbi::RawF64, CAbi::Ptr, CAbi::Bool], CAbi::U64, "m::cb");
        let decl = unsafe { read_descriptor(bytes.as_ptr(), bytes.len()) }.unwrap();
        assert_eq!((0..decl.params.len()).map(|i| decl.param(i)).collect::<Vec<_>>(), vec![CAbi::I32, CAbi::RawF64, CAbi::Ptr, CAbi::Bool]);
        assert_eq!(decl.result, CAbi::U64);
        assert_eq!(decl.what(), "callback m::cb");
        for c in CLASSES {
            assert_eq!(class_of(class_code(c)), Some(c));
        }
        assert!(unsafe { read_descriptor(bytes.as_ptr(), 3) }.is_none());
    }

    #[test]
    fn result_words_are_exactly_the_c_values() {
        assert_eq!(result_word(CAbi::I32, make_small(-5)), Ok(-5i64 as u64));
        assert_eq!(result_word(CAbi::U8, make_small(255)), Ok(255));
        assert!(result_word(CAbi::U8, make_small(256)).is_err());
        assert!(result_word(CAbi::I8, make_small(-129)).is_err());
        assert_eq!(result_word(CAbi::Bool, TRUE), Ok(1));
        assert_eq!(result_word(CAbi::Bool, FALSE), Ok(0));
        assert_eq!(result_word(CAbi::Void, UNIT), Ok(0));
        assert_eq!(result_word(CAbi::Ptr, make_cptr(0x1234)), Ok(0x1234));
        assert!(result_word(CAbi::Ptr, make_small(1)).is_err());
    }
}
