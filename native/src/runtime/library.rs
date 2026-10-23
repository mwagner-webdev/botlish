//! A native library's runtime boundary (NATIVE-LIBRARY-MILESTONE-1.md): the
//! functions a library's public C API forwards to (codegen::library), and
//! the runtime instances they create.
//!
//! # Instances
//!
//! `botlish_library_create` makes one instance of the program a descriptor
//! describes (runtime::program): its own Vm -- heap, constants, module
//! statics, stack-map table, pending error -- built by the construction
//! every startup shares, on the calling thread, which owns it from then on.
//! Creating it runs the program's function 0, which for a library is the
//! initialization of the modules it imports and nothing else
//! (native::library refuses a library whose root file has statements): an
//! error there fails the creation and leaves nothing behind. Two instances
//! share nothing mutable, of one library or of two; a library's code reads
//! its program's tables through its own Vm, and the thread's current program
//! (runtime::vm's `current_program`, what printing and the runtime's error
//! payloads read) is the called instance's for exactly the duration of the
//! call.
//!
//! An instance is thread-affine: every call, and its destruction, must come
//! from the thread that created it, and a call on any other thread fails
//! with an invocation error before touching it. A thread is known by a
//! serial number drawn once per thread, never reused, so a thread that
//! exits and a later one the system gives the same identity are two
//! threads. A call made while a call into the same instance is running on
//! its thread (reentrance: a signal handler, a future callback) fails the
//! same way. Nothing here moves a Vm between threads, locks around Botlish
//! code, or runs it anywhere but on the caller's own stack.
//!
//! Every live instance, error and result buffer is in a registry of this
//! runtime, and every call checks its handle there first, so a handle that
//! was never one, one already released or destroyed, or one of another
//! library (another copy of this runtime, with its own registries) is an
//! invocation error, never undefined behavior. An instance's record outlives
//! its destruction (a few dozen bytes; its Vm is freed), so its address is
//! never another instance's and a stale handle stays detectably stale.
//!
//! # Calls
//!
//! An export's C function passes its arguments as machine words
//! (codegen::library) to `botlish_library_call`, which converts them to
//! Botlish values (an Int from int64_t, a String from UTF-8 bytes after
//! validating them, a Float64 from a finite double), roots them, calls the
//! exported function's generic entry, and converts its result: an Int
//! result outside int64_t is a boundary error, never truncated; a String
//! result is copied into a buffer the caller owns. A Botlish failure becomes
//! an error object the caller owns (`LibError`), whose identity, message
//! and payload fields are data copied out of the Vm: nothing returned points
//! into the Botlish heap. Neither a Botlish error nor a Rust panic unwinds
//! out: a panic in this boundary code poisons the instance (every later call
//! fails with an invocation error) and is reported as a runtime error.
//!
//! The GC walks this instance's frames only: the call makes its own frame
//! the top of the stack the Vm walks (Vm::set_stack_boundary), so the host's
//! frames above it are never read as Botlish ones. Generated code checks
//! the stack pointer against the instance's stack limit (the creating
//! thread's stack bound plus a margin, runtime::native_stack), so recursion
//! that would exhaust the stack fails with NATIVE LIMIT STACK, a runtime
//! error. No signal handler is installed, and nothing here ends the
//! process.
use super::error::RtError;
use super::metrics::AllocMode;
use super::program::{self, Descriptor, ExportMeta};
use super::show::show;
use super::value::*;
use super::vm::{swap_current_program, Vm};
use crate::nir::Boundary;
use num_bigint::BigInt;
use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Mutex;

/// The status of a call (the generated header's LIB_OK ...).
pub const OK: i32 = 0;
/// The Botlish function failed with a declared error.
pub const DECLARED_ERROR: i32 = 1;
/// The Botlish code failed with a runtime error (a semantic error, an
/// exhausted stack, a native backend failure).
pub const RUNTIME_ERROR: i32 = 2;
/// A value could not cross the boundary: an argument that is not UTF-8 or
/// not a finite double, an Int result outside int64_t, a payload field of
/// another kind or out of range.
pub const BOUNDARY_ERROR: i32 = 3;
/// The call itself is invalid: a null pointer, a handle that is no live
/// instance (or error, or buffer) of this library, the wrong thread, a
/// reentrant call, a poisoned instance.
pub const INVOCATION_ERROR: i32 = 4;

/// A payload field's kind (LIB_FIELD_*).
pub const FIELD_OTHER: i32 = 0;
pub const FIELD_INT: i32 = 1;
pub const FIELD_BOOL: i32 = 2;
pub const FIELD_FLOAT64: i32 = 3;
pub const FIELD_STR: i32 = 4;

/// An owned byte buffer (LIB_bytes): `len` bytes at `data`, followed by a
/// NUL that `len` does not count. Released by `botlish_library_bytes_release`.
#[repr(C)]
pub struct Bytes {
    pub data: *mut u8,
    pub len: usize,
}

/// A borrowed view of bytes an error object owns (LIB_text).
#[repr(C)]
pub struct Text {
    pub data: *const u8,
    pub len: usize,
}

enum FieldValue {
    Int(BigInt),
    Bool(bool),
    Float64(f64),
    Str(String),
    Other,
}

/// A failure, as the caller receives it (LIB_error): its status, its
/// identity (a declared error's canonical name; a runtime error's code;
/// `BOUNDARY ...`, `INVOCATION ...`), its message, and a declared error's
/// payload fields (name, value, Botlish text), all owned.
pub struct LibError {
    status: i32,
    identity: String,
    message: String,
    fields: Vec<(String, FieldValue, String)>,
}

impl LibError {
    fn new(status: i32, identity: &str, message: impl Into<String>) -> LibError {
        LibError { status, identity: identity.to_string(), message: message.into(), fields: Vec::new() }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum State {
    Idle,
    Calling,
    Destroyed,
    Poisoned,
}

/// An instance's lifecycle record, in the registry.
struct Record {
    descriptor: usize,
    owner: u64,
    state: State,
}

/// An instance's program state: touched only by its owner thread, and only
/// while its record says Calling (or during creation and destruction).
pub struct Instance {
    vm: Option<Box<Vm>>,
    code: Vec<[usize; 2]>,
    exports: Vec<ExportMeta>,
    errors: HashMap<u32, String>,
}

static INSTANCES: Mutex<BTreeMap<usize, Record>> = Mutex::new(BTreeMap::new());
static ERRORS: Mutex<BTreeSet<usize>> = Mutex::new(BTreeSet::new());
static BUFFERS: Mutex<BTreeMap<usize, usize>> = Mutex::new(BTreeMap::new());
static NEXT_THREAD: AtomicU64 = AtomicU64::new(1);

thread_local! {
    static THREAD: u64 = NEXT_THREAD.fetch_add(1, Ordering::Relaxed);
}

/// This thread's serial number (the module doc).
fn this_thread() -> u64 {
    THREAD.with(|t| *t)
}

fn lock<T>(m: &Mutex<T>) -> std::sync::MutexGuard<'_, T> {
    m.lock().unwrap_or_else(|poisoned| poisoned.into_inner())
}

/// Hands FAILURE to the caller through ERROR (when it asked for it) and
/// returns its status.
fn report(error: *mut *mut LibError, failure: LibError) -> i32 {
    let status = failure.status;
    if !error.is_null() {
        let boxed = Box::into_raw(Box::new(failure));
        lock(&ERRORS).insert(boxed as usize);
        unsafe { *error = boxed };
    }
    status
}

fn invocation(what: &str, message: impl Into<String>) -> LibError {
    LibError::new(INVOCATION_ERROR, &format!("INVOCATION {what}"), message)
}

fn panic_text(payload: &(dyn std::any::Any + Send)) -> String {
    if let Some(s) = payload.downcast_ref::<&str>() {
        s.to_string()
    } else if let Some(s) = payload.downcast_ref::<String>() {
        s.clone()
    } else {
        "a panic".to_string()
    }
}

/// Moves INSTANCE from Idle to Calling for this thread, or explains why it
/// cannot be called.
fn enter(descriptor: *const Descriptor, instance: *mut Instance) -> Result<(), LibError> {
    if instance.is_null() {
        return Err(invocation("NULL-INSTANCE", "the instance is a null pointer"));
    }
    let mut registry = lock(&INSTANCES);
    let Some(record) = registry.get_mut(&(instance as usize)) else {
        return Err(invocation("UNKNOWN-INSTANCE", "the handle is no instance of this library"));
    };
    if record.descriptor != descriptor as usize {
        return Err(invocation("OTHER-LIBRARY", "the instance belongs to another library"));
    }
    if record.owner != this_thread() {
        return Err(invocation("WRONG-THREAD", "an instance is called only on the thread that created it"));
    }
    match record.state {
        State::Idle => {
            record.state = State::Calling;
            Ok(())
        }
        State::Calling => Err(invocation("REENTRANT", "a call into this instance is already running on its thread")),
        State::Destroyed => Err(invocation("DESTROYED", "the instance was destroyed")),
        State::Poisoned => Err(invocation("POISONED", "the instance failed internally and can only be destroyed")),
    }
}

fn leave(instance: *mut Instance, state: State) {
    if let Some(record) = lock(&INSTANCES).get_mut(&(instance as usize)) {
        record.state = state;
    }
}

/// The error of the failed call or initialization pending in VM, taken out
/// of it as data (the module doc), and the Vm's error state cleared.
fn capture(vm: &mut Vm, errors: &HashMap<u32, String>) -> LibError {
    let error = vm.error.take().unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
    let message = vm.describe_error(&error);
    let failure = if vm.declared_error != 0 {
        let id = vm.declared_error;
        let identity = errors.get(&id).cloned().unwrap_or_else(|| format!("error#{id}"));
        let mut failure = LibError::new(DECLARED_ERROR, &identity, message);
        if !vm.declared_payload.is_empty() {
            let names = vm.info.shapes.get(vm.declared_payload_shape as usize).map(|s| s.fields.clone()).unwrap_or_default();
            for (i, &value) in vm.declared_payload.iter().enumerate() {
                let name = names.get(i).cloned().unwrap_or_else(|| format!("field{i}"));
                failure.fields.push((name, field_value(value), show(value)));
            }
        }
        failure
    } else {
        LibError::new(RUNTIME_ERROR, &error.error_code().join(" "), message)
    };
    vm.declared_error = 0;
    vm.declared_payload.clear();
    vm.error = None;
    failure
}

fn field_value(v: Value) -> FieldValue {
    match kind_of(v) {
        Kind::Int => FieldValue::Int(int_to_big(v)),
        Kind::Bool => FieldValue::Bool(v == TRUE),
        Kind::Float64 => FieldValue::Float64(float64_of(v)),
        Kind::Str => FieldValue::Str(str_of(v).as_str().to_string()),
        _ => FieldValue::Other,
    }
}

/// Runs F with VM as the running instance: this thread's current program is
/// the instance's, and the Vm's stack ends at BOUNDARY, the frame of the
/// boundary function that runs Botlish code (the module doc). Restores the
/// thread's previous program afterwards.
fn running<R>(vm: &mut Vm, boundary: usize, f: impl FnOnce(&mut Vm) -> R) -> R {
    vm.set_stack_boundary(boundary);
    let previous = swap_current_program(Some(vm.info.clone()));
    let result = f(vm);
    swap_current_program(previous);
    result
}

#[cfg(all(any(target_arch = "x86_64", target_arch = "aarch64"), not(windows)))]
#[inline(always)]
fn frame() -> usize {
    super::framewalk::frame_address()
}

#[cfg(not(all(any(target_arch = "x86_64", target_arch = "aarch64"), not(windows))))]
#[inline(always)]
fn frame() -> usize {
    usize::MAX
}

/// Creates an instance (LIB_create): *INSTANCE becomes it, or null. On
/// failure *ERROR (when not null) receives the error.
///
/// # Safety
/// DESCRIPTOR is the library's own descriptor (its generated LIB_create
/// passes it); INSTANCE and ERROR are null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_create(
    descriptor: *const Descriptor,
    instance: *mut *mut Instance,
    error: *mut *mut LibError,
) -> i32 {
    if !error.is_null() {
        unsafe { *error = std::ptr::null_mut() };
    }
    if instance.is_null() {
        return report(error, invocation("NULL-POINTER", "LIB_create needs the address to store the instance at"));
    }
    unsafe { *instance = std::ptr::null_mut() };
    let created = catch_unwind(AssertUnwindSafe(|| create(descriptor)));
    match created {
        Ok(Ok(shell)) => {
            let address = Box::into_raw(shell);
            lock(&INSTANCES).insert(
                address as usize,
                Record { descriptor: descriptor as usize, owner: this_thread(), state: State::Idle },
            );
            unsafe { *instance = address };
            OK
        }
        Ok(Err(failure)) => report(error, failure),
        Err(payload) => report(
            error,
            LibError::new(RUNTIME_ERROR, "NATIVE BUG", format!("instance creation panicked: {}", panic_text(&*payload))),
        ),
    }
}

fn create(descriptor: *const Descriptor) -> Result<Box<Instance>, LibError> {
    let (data, code) = unsafe { program::read(descriptor) }
        .map_err(|message| LibError::new(RUNTIME_ERROR, "NATIVE STARTUP", message))?;
    if data.library.is_none() {
        return Err(invocation("NOT-A-LIBRARY", "the program is not compiled as a native library"));
    }
    let stack = native_stack().map_err(|message| LibError::new(RUNTIME_ERROR, "NATIVE STARTUP", message))?;
    let errors: HashMap<u32, String> = data.errors.iter().cloned().collect();
    let previous = swap_current_program(None);
    let mut vm =
        program::build_vm_on(data.info, &data.constants, data.statics, &code, &data.functions, AllocMode::Off, stack);
    swap_current_program(previous);
    if let Some(stack) = stack {
        vm.stack_limit = stack.stack_limit();
    }
    // A library instance has no process arguments: argv() is the empty List.
    vm.set_argv(Vec::new());
    let entry: super::aot::ProgramEntry = unsafe { std::mem::transmute(code[0][0]) };
    let boundary = frame();
    let initialized = running(&mut vm, boundary, |vm| {
        let r = entry(vm);
        if r == NO_VALUE { Err(capture(vm, &errors)) } else { Ok(()) }
    });
    initialized?;
    vm.temp_roots.clear();
    Ok(Box::new(Instance { vm: Some(vm), code, exports: data.exports, errors }))
}

/// The calling thread's stack (runtime::native_stack), or why it cannot be
/// found.
fn native_stack() -> Result<Option<super::native_stack::NativeStack>, String> {
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64")))]
    {
        super::native_stack::NativeStack::current()
            .map(Some)
            .map_err(|e| format!("the calling thread's stack bounds are unknown: {e}"))
    }
    #[cfg(not(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64"), all(windows, target_arch = "x86_64"))))]
    {
        Ok(None)
    }
}

/// Destroys INSTANCE (LIB_destroy): frees its Vm, on its owner thread, when
/// no call into it is running. A poisoned instance may be destroyed.
///
/// # Safety
/// INSTANCE is any pointer; it is only dereferenced once the registry
/// knows it as an instance of DESCRIPTOR's library.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_destroy(descriptor: *const Descriptor, instance: *mut Instance) -> i32 {
    {
        if instance.is_null() {
            return INVOCATION_ERROR;
        }
        let mut registry = lock(&INSTANCES);
        let Some(record) = registry.get_mut(&(instance as usize)) else { return INVOCATION_ERROR };
        if record.descriptor != descriptor as usize || record.owner != this_thread() {
            return INVOCATION_ERROR;
        }
        match record.state {
            State::Idle | State::Poisoned => record.state = State::Destroyed,
            State::Calling | State::Destroyed => return INVOCATION_ERROR,
        }
    }
    let shell = unsafe { &mut *instance };
    let vm = shell.vm.take();
    let freed = catch_unwind(AssertUnwindSafe(move || {
        if let Some(vm) = vm {
            let previous = swap_current_program(Some(vm.info.clone()));
            drop(vm);
            swap_current_program(previous);
        }
    }));
    if freed.is_err() { RUNTIME_ERROR } else { OK }
}

/// Calls export EXPORT of INSTANCE (an export's C function): ARGS are its
/// arguments' words (codegen::library), RESULT the result's address (unused
/// for a unit result). On failure *ERROR (when not null) receives the error.
///
/// # Safety
/// The generated export function passes its own C arguments; the C caller
/// guarantees them valid for their C types (a pointer and length naming
/// readable bytes, a writable result).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_call(
    descriptor: *const Descriptor,
    instance: *mut Instance,
    export: u64,
    args: *const u64,
    result: *mut u8,
    error: *mut *mut LibError,
) -> i32 {
    if !error.is_null() {
        unsafe { *error = std::ptr::null_mut() };
    }
    if let Err(failure) = enter(descriptor, instance) {
        return report(error, failure);
    }
    let shell = unsafe { &mut *instance };
    let boundary = frame();
    let outcome = catch_unwind(AssertUnwindSafe(|| call(shell, export, args, result, boundary)));
    match outcome {
        Ok(outcome) => {
            leave(instance, State::Idle);
            match outcome {
                Ok(()) => OK,
                Err(failure) => report(error, failure),
            }
        }
        Err(payload) => {
            leave(instance, State::Poisoned);
            report(error, LibError::new(RUNTIME_ERROR, "NATIVE BUG", format!("the call panicked: {}", panic_text(&*payload))))
        }
    }
}

type GenericEntry = unsafe extern "C" fn(*mut Vm, Value, *const Value) -> Value;

fn call(shell: &mut Instance, export: u64, args: *const u64, result: *mut u8, boundary: usize) -> Result<(), LibError> {
    let Some(meta) = shell.exports.get(export as usize).cloned() else {
        return Err(invocation("UNKNOWN-EXPORT", format!("the library has no export {export}")));
    };
    if meta.result != Boundary::Unit && result.is_null() {
        return Err(invocation("NULL-POINTER", format!("{}: the result's address is a null pointer", meta.symbol)));
    }
    let words = meta.params.iter().map(|p| p.words()).sum::<usize>();
    let args: &[u64] = if words == 0 { &[] } else { unsafe { std::slice::from_raw_parts(args, words) } };
    let entry: GenericEntry = unsafe { std::mem::transmute(shell.code[meta.func as usize][1]) };
    let errors = &shell.errors;
    let vm = shell.vm.as_mut().ok_or_else(|| invocation("DESTROYED", "the instance was destroyed"))?;
    running(vm, boundary, |vm| {
        let roots = vm.temp_roots.len();
        let outcome = (|| {
            let mut values = Vec::with_capacity(meta.params.len());
            let mut at = 0;
            for (i, p) in meta.params.iter().enumerate() {
                let value = match p {
                    Boundary::Int => vm.new_int(args[at] as i64),
                    Boundary::Bool => if args[at] & 0xff != 0 { TRUE } else { FALSE },
                    Boundary::Float64 => {
                        let x = f64::from_bits(args[at]);
                        let Some(bits) = FloatType::Float64.admit(x) else {
                            return Err(LibError::new(
                                BOUNDARY_ERROR,
                                "BOUNDARY NON-FINITE",
                                format!("{}: argument {} is {x}, which is no Float64 (a finite number)", meta.symbol, i + 1),
                            ));
                        };
                        vm.new_float(FloatType::Float64, bits)
                    }
                    Boundary::Str => {
                        let (pointer, length) = (args[at] as *const u8, args[at + 1] as usize);
                        let bytes: &[u8] = if length == 0 {
                            &[]
                        } else if pointer.is_null() {
                            return Err(invocation(
                                "NULL-POINTER",
                                format!("{}: argument {} is a null pointer with length {length}", meta.symbol, i + 1),
                            ));
                        } else {
                            unsafe { std::slice::from_raw_parts(pointer, length) }
                        };
                        let Ok(text) = std::str::from_utf8(bytes) else {
                            return Err(LibError::new(
                                BOUNDARY_ERROR,
                                "BOUNDARY UTF-8",
                                format!("{}: argument {} is not UTF-8", meta.symbol, i + 1),
                            ));
                        };
                        vm.new_str(text)
                    }
                    Boundary::Unit => NO_VALUE,
                };
                if value == NO_VALUE {
                    return Err(capture(vm, errors));
                }
                vm.temp_roots.push(value);
                values.push(value);
                at += p.words();
            }
            let r = unsafe { entry(vm, 0, values.as_ptr()) };
            if r == NO_VALUE {
                return Err(capture(vm, errors));
            }
            write_result(&meta, r, result)
        })();
        vm.temp_roots.truncate(roots);
        outcome
    })
}

/// Converts the export's result R into the C result at RESULT.
fn write_result(meta: &ExportMeta, r: Value, result: *mut u8) -> Result<(), LibError> {
    let wrong = || {
        LibError::new(
            RUNTIME_ERROR,
            "NATIVE BUG",
            format!("{}: the result is not a {} value", meta.symbol, meta.result.name()),
        )
    };
    match meta.result {
        Boundary::Unit => Ok(()),
        Boundary::Int => {
            if kind_of(r) != Kind::Int {
                return Err(wrong());
            }
            let n = match int_small(r) {
                Some(n) => n,
                None => {
                    let big = int_to_big(r);
                    i64::try_from(&big).map_err(|_| {
                        LibError::new(
                            BOUNDARY_ERROR,
                            "BOUNDARY INT-RANGE",
                            format!("{}: the Int result {big} is outside int64_t", meta.symbol),
                        )
                    })?
                }
            };
            unsafe { (result as *mut i64).write_unaligned(n) };
            Ok(())
        }
        Boundary::Bool => {
            if r != TRUE && r != FALSE {
                return Err(wrong());
            }
            unsafe { (result as *mut bool).write(r == TRUE) };
            Ok(())
        }
        Boundary::Float64 => {
            if kind_of(r) != Kind::Float64 {
                return Err(wrong());
            }
            unsafe { (result as *mut f64).write_unaligned(float64_of(r)) };
            Ok(())
        }
        Boundary::Str => {
            if kind_of(r) != Kind::Str {
                return Err(wrong());
            }
            let bytes = owned_bytes(str_of(r).as_bytes());
            unsafe { (result as *mut Bytes).write_unaligned(bytes) };
            Ok(())
        }
    }
}

/// A buffer the caller owns holding a copy of BYTES and a terminating NUL.
fn owned_bytes(bytes: &[u8]) -> Bytes {
    let mut buffer = Vec::with_capacity(bytes.len() + 1);
    buffer.extend_from_slice(bytes);
    buffer.push(0);
    let boxed = buffer.into_boxed_slice();
    let len = boxed.len() - 1;
    let data = Box::into_raw(boxed) as *mut u8;
    lock(&BUFFERS).insert(data as usize, len + 1);
    Bytes { data, len }
}

/// Releases the buffer BYTES holds (LIB_bytes_release) and empties it. An
/// empty one (null data) is nothing to release; a buffer this runtime did
/// not give out, or gave out and took back, is an invocation error, and
/// nothing is freed.
///
/// # Safety
/// BYTES is null or a readable and writable LIB_bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_bytes_release(bytes: *mut Bytes) -> i32 {
    if bytes.is_null() {
        return INVOCATION_ERROR;
    }
    let b = unsafe { &mut *bytes };
    if b.data.is_null() {
        return OK;
    }
    let Some(size) = lock(&BUFFERS).remove(&(b.data as usize)) else { return INVOCATION_ERROR };
    drop(unsafe { Box::from_raw(std::ptr::slice_from_raw_parts_mut(b.data, size)) });
    b.data = std::ptr::null_mut();
    b.len = 0;
    OK
}

/// The live error at ERROR, if it is one.
fn error_ref<'a>(error: *const LibError) -> Option<&'a LibError> {
    if error.is_null() || !lock(&ERRORS).contains(&(error as usize)) {
        return None;
    }
    Some(unsafe { &*error })
}

fn text(out: *mut Text, s: &str) -> i32 {
    if out.is_null() {
        return INVOCATION_ERROR;
    }
    unsafe { out.write(Text { data: s.as_ptr(), len: s.len() }) };
    OK
}

/// Releases an error (LIB_error_release); null is nothing to release.
///
/// # Safety
/// ERROR is any pointer: it is released only if this runtime gave it out.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_release(error: *mut LibError) -> i32 {
    if error.is_null() {
        return OK;
    }
    if !lock(&ERRORS).remove(&(error as usize)) {
        return INVOCATION_ERROR;
    }
    drop(unsafe { Box::from_raw(error) });
    OK
}

/// The status a call that failed with ERROR returned, or -1 for a pointer
/// that is no live error.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_status(error: *const LibError) -> i32 {
    error_ref(error).map_or(-1, |e| e.status)
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_identity(error: *const LibError, out: *mut Text) -> i32 {
    error_ref(error).map_or(INVOCATION_ERROR, |e| text(out, &e.identity))
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_message(error: *const LibError, out: *mut Text) -> i32 {
    error_ref(error).map_or(INVOCATION_ERROR, |e| text(out, &e.message))
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_count(error: *const LibError) -> usize {
    error_ref(error).map_or(0, |e| e.fields.len())
}

fn field<'a>(error: *const LibError, index: usize) -> Option<&'a (String, FieldValue, String)> {
    error_ref(error).and_then(|e| e.fields.get(index))
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_name(error: *const LibError, index: usize, out: *mut Text) -> i32 {
    field(error, index).map_or(INVOCATION_ERROR, |f| text(out, &f.0))
}

/// The kind of field INDEX (FIELD_*), or -1 when there is no such field.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_kind(error: *const LibError, index: usize) -> i32 {
    field(error, index).map_or(-1, |f| match f.1 {
        FieldValue::Int(_) => FIELD_INT,
        FieldValue::Bool(_) => FIELD_BOOL,
        FieldValue::Float64(_) => FIELD_FLOAT64,
        FieldValue::Str(_) => FIELD_STR,
        FieldValue::Other => FIELD_OTHER,
    })
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_int(error: *const LibError, index: usize, out: *mut i64) -> i32 {
    match field(error, index) {
        Some((_, FieldValue::Int(n), _)) if !out.is_null() => match i64::try_from(n) {
            Ok(n) => {
                unsafe { out.write(n) };
                OK
            }
            Err(_) => BOUNDARY_ERROR,
        },
        _ => INVOCATION_ERROR,
    }
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_bool(error: *const LibError, index: usize, out: *mut bool) -> i32 {
    match field(error, index) {
        Some((_, FieldValue::Bool(b), _)) if !out.is_null() => {
            unsafe { out.write(*b) };
            OK
        }
        _ => INVOCATION_ERROR,
    }
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_float64(error: *const LibError, index: usize, out: *mut f64) -> i32 {
    match field(error, index) {
        Some((_, FieldValue::Float64(x), _)) if !out.is_null() => {
            unsafe { out.write(*x) };
            OK
        }
        _ => INVOCATION_ERROR,
    }
}

/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_str(error: *const LibError, index: usize, out: *mut Text) -> i32 {
    match field(error, index) {
        Some((_, FieldValue::Str(s), _)) => text(out, s),
        _ => INVOCATION_ERROR,
    }
}

/// Any field's value as Botlish prints it.
///
/// # Safety
/// OUT is null or writable.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_error_field_text(error: *const LibError, index: usize, out: *mut Text) -> i32 {
    field(error, index).map_or(INVOCATION_ERROR, |f| text(out, &f.2))
}
