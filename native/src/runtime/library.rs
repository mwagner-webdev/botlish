//! Native libraries (NATIVE-LIBRARY-MILESTONE-1.md): the runtime half of a
//! Botlish library's C ABI.
//!
//! A library object (codegen::library) defines the public C functions --
//! `NAME_create`, `NAME_destroy`, one per exported function, the error and
//! result accessors -- as small machine-code forwarders to the functions
//! here, each passing the library's own program record (runtime::program's
//! LinkedProgram) where the program matters. The library's archive carries a
//! private copy of this runtime whose every symbol but those public
//! functions is local (native::library's link), so two libraries in one
//! process share no runtime code or state, and nothing here needs to tell
//! them apart.
//!
//! # Instances
//!
//! `create` makes a Vm on the calling thread and runs the program's
//! initialization once (function 0: every imported module's static
//! initialization -- a library's entry file has declarations only, so
//! nothing else). The instance belongs to that thread: every call and the
//! destroy must come from it, never concurrently with another call on it,
//! and never from inside one of its own calls (a C function a Botlish
//! function called). A handle is an opaque, never-reused token (a leaked
//! 8-byte allocation, so no later allocation can take its address): a handle
//! this library did not return, or one already destroyed, is refused as
//! INVALID-INSTANCE without touching anything through it. Instances share
//! nothing: each has its own Vm -- heap, constants, statics -- and nothing a
//! call leaves behind is visible to another instance.
//!
//! # Calls
//!
//! An export's trampoline stores its C arguments as words (a String as its
//! pointer and length, a Float64 as its bits) and calls `call`, which checks
//! the handle and the thread, converts the arguments into Botlish values
//! (rooted while the others are made), calls the export root's generic entry
//! (its function's generic instance, compiled under the declared contract
//! only: native/lower.tcl's export roots), and converts its result. The
//! collector's frame walk of the calling thread's stack stops at `enter`'s
//! frame (Vm::stack_ceiling): host frames above it are never read as Botlish
//! frames. The thread's current-program register (runtime::vm's PROGRAM,
//! read by printing and hashing) is this instance's for the call and
//! restored after it.
//!
//! # Results and errors
//!
//! Every function returns a status (the header's NAME_STATUS_*). A String
//! result is copied out into a buffer the caller owns and releases with
//! `bytes_release`: no pointer into the Botlish heap ever crosses the
//! boundary, so a result survives later calls, collections, the instance's
//! destruction and other libraries. A failure can hand the caller an owned
//! error object: its status, its identity -- a declared error's canonical
//! name (the program's error table), a runtime error's code words, a
//! boundary or invocation error's name -- as data, a human-readable message,
//! and the payload's scalar fields, typed. Releasing a buffer or an error
//! this library does not hold is refused; releasing a released one through
//! the same variable is a no-op (release clears it). No Rust panic and no
//! Botlish error unwinds into the caller: a Botlish error is a status, and a
//! panic in this runtime's boundary code is caught and reported as INTERNAL
//! (an `extern "C"` function aborts on any panic that escapes it).
use super::aot::ProgramEntry;
use super::error::RtError;
use super::program::{self, LinkedProgram};
use super::value::*;
use super::vm::{self, Vm};
use crate::nir::{Boundary, ExportDecl};
use std::collections::{BTreeMap, BTreeSet};
use std::ffi::c_void;
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::sync::Mutex;
use std::thread::ThreadId;

/// The version of the C ABI a library's header describes
/// (`NAME_ABI_VERSION`): what the statuses, the handle, result and error
/// conventions and the accessor signatures are.
pub const ABI_VERSION: u32 = 1;

pub const STATUS_OK: i32 = 0;
/// A declared Botlish error reached the caller (identity: its canonical name).
pub const STATUS_DECLARED: i32 = 1;
/// A runtime error (identity: its error code words, `CORE SEMANTIC RANGE`).
pub const STATUS_RUNTIME: i32 = 2;
/// An argument or a result the boundary cannot convert (identity:
/// ARGUMENT-NOT-UTF8, ARGUMENT-NULL, ARGUMENT-NOT-FINITE, RESULT-OUT-OF-RANGE;
/// an argument's error has the int field `argument`, its 0-based index).
pub const STATUS_BOUNDARY: i32 = 3;
/// A call the lifecycle or the calling convention forbids (identity:
/// INVALID-INSTANCE, WRONG-THREAD, REENTRANT-CALL, NULL-POINTER, INVALID-RELEASE,
/// NO-FIELD, FIELD-TYPE).
pub const STATUS_INVOCATION: i32 = 4;
/// A defect of the runtime itself (identity: NATIVE BUG).
pub const STATUS_INTERNAL: i32 = 5;

pub const FIELD_INT: i32 = 1;
pub const FIELD_BOOL: i32 = 2;
pub const FIELD_FLOAT64: i32 = 3;
pub const FIELD_STR: i32 = 4;
/// A payload field with no C form (a List, a struct, an enum ...): only the
/// message shows it.
pub const FIELD_OTHER: i32 = 5;

/// A String result: a buffer the caller owns (`NAME_bytes`).
#[repr(C)]
pub struct Bytes {
    pub ptr: *mut u8,
    pub len: usize,
}

enum FieldValue {
    Int(i64),
    /// An Int no int64_t holds (its decimal text, for the message).
    BigInt,
    Bool(bool),
    Float64(f64),
    Str(Vec<u8>),
    Other,
}

/// An error a call hands its caller (`NAME_error`), owned by the caller
/// until `error_release`. Holds copies only: nothing in it refers to a Vm.
pub struct LibError {
    status: i32,
    identity: Vec<u8>,
    message: Vec<u8>,
    fields: Vec<(Vec<u8>, FieldValue)>,
}

impl LibError {
    fn new(status: i32, identity: &str, message: impl Into<String>) -> LibError {
        LibError { status, identity: identity.as_bytes().to_vec(), message: message.into().into_bytes(), fields: Vec::new() }
    }

    fn with_argument(mut self, index: usize) -> LibError {
        self.fields.push((b"argument".to_vec(), FieldValue::Int(index as i64)));
        self
    }
}

struct Instance {
    vm: Box<Vm>,
    exports: Vec<ExportDecl>,
    /// Function N's (direct, generic entry) addresses.
    code: Vec<(usize, usize)>,
    /// The program record it was made from: a call must name the same one.
    program: usize,
}

struct Entry {
    instance: *mut Instance,
    owner: ThreadId,
    busy: bool,
}

// SAFETY: an Entry's instance pointer is only dereferenced on its owner
// thread (`checkout`), and the registry only moves the pointer value.
unsafe impl Send for Entry {}

/// Live instances by handle.
static INSTANCES: Mutex<BTreeMap<usize, Entry>> = Mutex::new(BTreeMap::new());
/// Live error objects and result buffers this library handed out.
static ERRORS: Mutex<BTreeSet<usize>> = Mutex::new(BTreeSet::new());
static BUFFERS: Mutex<BTreeSet<usize>> = Mutex::new(BTreeSet::new());

fn lock<T>(m: &Mutex<T>) -> std::sync::MutexGuard<'_, T> {
    // A panic never happens while one of these is held; recover anyway.
    m.lock().unwrap_or_else(|poisoned| poisoned.into_inner())
}

/// Hands ERROR to the caller through OUT (when it asked for errors) and
/// returns its status.
fn report(error: LibError, out: *mut *mut LibError) -> i32 {
    let status = error.status;
    if !out.is_null() {
        let raw = Box::into_raw(Box::new(error));
        lock(&ERRORS).insert(raw as usize);
        // SAFETY: OUT is the caller's non-null `NAME_error **`.
        unsafe { *out = raw };
    }
    status
}

fn invocation(identity: &str, message: impl Into<String>) -> LibError {
    LibError::new(STATUS_INVOCATION, identity, message)
}

/// Runs F, turning a panic into an INTERNAL error.
fn guarded(out: *mut *mut LibError, f: impl FnOnce() -> Result<(), LibError>) -> i32 {
    if !out.is_null() {
        // SAFETY: OUT is the caller's `NAME_error **`.
        unsafe { *out = std::ptr::null_mut() };
    }
    match catch_unwind(AssertUnwindSafe(f)) {
        Ok(Ok(())) => STATUS_OK,
        Ok(Err(error)) => report(error, out),
        Err(_) => report(LibError::new(STATUS_INTERNAL, "NATIVE BUG", "the Botlish runtime panicked at the library boundary"), out),
    }
}

/// The instance of HANDLE, checked out for a call on this thread: busy until
/// `checkin`.
fn checkout(handle: usize) -> Result<*mut Instance, LibError> {
    let mut instances = lock(&INSTANCES);
    let Some(entry) = instances.get_mut(&handle) else {
        return Err(invocation("INVALID-INSTANCE", "not a live instance of this library (never created here, or destroyed)"));
    };
    if entry.owner != std::thread::current().id() {
        return Err(invocation("WRONG-THREAD", "an instance is called only on the thread that created it"));
    }
    if entry.busy {
        return Err(invocation("REENTRANT-CALL", "the instance is running a call on this thread already (a call from inside one of its calls)"));
    }
    entry.busy = true;
    Ok(entry.instance)
}

/// Checks the instance of a handle back in when dropped, however the call
/// ended.
struct Checkin(usize);

impl Drop for Checkin {
    fn drop(&mut self) {
        if let Some(entry) = lock(&INSTANCES).get_mut(&self.0) {
            entry.busy = false;
        }
    }
}

/// Makes the instance's program the thread's current one for a call, and
/// restores the previous one when dropped.
struct ProgramScope(Option<std::rc::Rc<vm::ProgramInfo>>);

impl ProgramScope {
    fn enter(vm: &Vm) -> ProgramScope {
        ProgramScope(vm::swap_current_program(Some(vm.info.clone())))
    }
}

impl Drop for ProgramScope {
    fn drop(&mut self) {
        vm::swap_current_program(self.0.take());
    }
}

type GenericEntry = unsafe extern "C" fn(*mut Vm, Value, *const Value) -> Value;

/// Calls F with VM's frame-walk ceiling at this function's own frame record:
/// the collector's walk of this thread's stack ends here, never climbing
/// into the host's frames (whose frame pointers are not Botlish's to read).
/// Never inlined, so its frame record exists and lies above every Botlish
/// frame the call makes.
#[inline(never)]
fn enter(vm: &mut Vm, f: impl FnOnce(&mut Vm) -> Value) -> Value {
    let outer = vm.stack_ceiling;
    let outer_limit = vm.stack_limit;
    let frame = super::framewalk::frame_record();
    vm.stack_ceiling = frame;
    // The call's own stack bounds its recursion: the thread's, or none on a
    // stack this instance did not make (Vm::stack_limit_at).
    vm.stack_limit = vm.stack_limit_at(frame);
    let result = f(vm);
    vm.stack_ceiling = outer;
    vm.stack_limit = outer_limit;
    // Keeps this frame from becoming a tail call of F.
    std::hint::black_box(result)
}

/// The error of the failed Botlish run on VM, which it then clears.
fn botlish_error(vm: &mut Vm) -> LibError {
    let error = vm.error.take().unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
    let message = vm.describe_error(&error);
    let declared = vm.declared_error;
    let mut result = if declared != 0 {
        let identity = vm
            .info
            .errors
            .iter()
            .find(|(id, _)| *id == declared)
            .map(|(_, name)| name.clone())
            .unwrap_or_else(|| format!("error#{declared}"));
        let mut e = LibError::new(STATUS_DECLARED, &identity, message);
        let names = vm.info.shapes.get(vm.declared_payload_shape as usize).map(|s| s.fields.clone()).unwrap_or_default();
        if !vm.declared_payload.is_empty() {
            for (name, &value) in names.iter().zip(&vm.declared_payload) {
                e.fields.push((name.clone().into_bytes(), field_value(value)));
            }
        }
        e
    } else {
        LibError::new(STATUS_RUNTIME, &error.error_code().join(" "), message)
    };
    super::ops::rt_clear_declared_error(vm);
    if result.status == STATUS_RUNTIME && matches!(error, RtError::Bug(_)) {
        result.status = STATUS_INTERNAL;
    }
    result
}

fn field_value(v: Value) -> FieldValue {
    match kind_of(v) {
        Kind::Int => match int_small(v) {
            Some(n) => FieldValue::Int(n),
            None => match i64::try_from(int_to_big(v)) {
                Ok(n) => FieldValue::Int(n),
                Err(_) => FieldValue::BigInt,
            },
        },
        Kind::Bool => FieldValue::Bool(v == TRUE),
        Kind::Float64 => FieldValue::Float64(float64_of(v)),
        Kind::Str => FieldValue::Str(str_of(v).as_str().as_bytes().to_vec()),
        _ => FieldValue::Other,
    }
}

/// The Botlish value of the C argument of type TYPE at WORDS (its words), or
/// the boundary error of argument INDEX. The value is rooted
/// (`Vm::temp_roots`) until the caller truncates them.
fn argument(vm: &mut Vm, index: usize, ty: Boundary, words: &[u64]) -> Result<Value, LibError> {
    let value = match ty {
        Boundary::Int => vm.new_int(words[0] as i64),
        Boundary::Bool => bool_value(words[0] & 0xff != 0),
        Boundary::Float64 => {
            let x = f64::from_bits(words[0]);
            let Some(bits) = FloatType::Float64.admit(x) else {
                return Err(LibError::new(STATUS_BOUNDARY, "ARGUMENT-NOT-FINITE", format!("argument {index} is {x}: a Float64 is a finite number")).with_argument(index));
            };
            vm.new_float(FloatType::Float64, bits)
        }
        Boundary::Str => {
            let (ptr, len) = (words[0] as *const u8, words[1] as usize);
            let bytes: &[u8] = if len == 0 {
                &[]
            } else if ptr.is_null() {
                return Err(LibError::new(STATUS_BOUNDARY, "ARGUMENT-NULL", format!("argument {index} is a NULL pointer with a length of {len}")).with_argument(index));
            } else {
                // SAFETY: the caller's contract: PTR addresses LEN readable bytes.
                unsafe { std::slice::from_raw_parts(ptr, len) }
            };
            let Ok(text) = std::str::from_utf8(bytes) else {
                return Err(LibError::new(STATUS_BOUNDARY, "ARGUMENT-NOT-UTF8", format!("argument {index} is not UTF-8")).with_argument(index));
            };
            vm.new_str(text)
        }
        Boundary::Unit => return Err(LibError::new(STATUS_INTERNAL, "NATIVE BUG", "a unit parameter")),
    };
    if value == NO_VALUE {
        // The heap's own limits (a String past the collection limit).
        return Err(botlish_error(vm));
    }
    vm.temp_roots.push(value);
    Ok(value)
}

/// Writes the result VALUE of type TY to OUT.
fn result(vm: &mut Vm, ty: Boundary, value: Value, out: *mut c_void) -> Result<(), LibError> {
    let mismatch = || LibError::new(STATUS_INTERNAL, "NATIVE BUG", format!("an export's result is not its declared {}", ty.spelling()));
    match ty {
        Boundary::Unit => {}
        Boundary::Int => {
            if kind_of(value) != Kind::Int {
                return Err(mismatch());
            }
            let n = match int_small(value) {
                Some(n) => n,
                None => i64::try_from(int_to_big(value)).map_err(|_| {
                    LibError::new(STATUS_BOUNDARY, "RESULT-OUT-OF-RANGE", format!("the result {} is outside int64_t", super::show::show(value)))
                })?,
            };
            // SAFETY: OUT is the caller's non-null `int64_t *`.
            unsafe { *(out as *mut i64) = n };
        }
        Boundary::Bool => {
            if value != TRUE && value != FALSE {
                return Err(mismatch());
            }
            // SAFETY: OUT is the caller's non-null `bool *`.
            unsafe { *(out as *mut bool) = value == TRUE };
        }
        Boundary::Float64 => {
            if kind_of(value) != Kind::Float64 {
                return Err(mismatch());
            }
            // SAFETY: OUT is the caller's non-null `double *`.
            unsafe { *(out as *mut f64) = float64_of(value) };
        }
        Boundary::Str => {
            if kind_of(value) != Kind::Str {
                return Err(mismatch());
            }
            let text = str_of(value).as_str().as_bytes();
            let buffer = owned_buffer(text);
            // SAFETY: OUT is the caller's non-null `NAME_bytes *`.
            unsafe { *(out as *mut Bytes) = buffer };
        }
    }
    let _ = vm;
    Ok(())
}

/// A malloc'd copy of TEXT, NUL-terminated after its LEN bytes (embedded
/// NULs are kept: LEN is authoritative), registered as live.
fn owned_buffer(text: &[u8]) -> Bytes {
    // SAFETY: a fresh allocation of len + 1 bytes, filled before use.
    let ptr = unsafe { libc::malloc(text.len() + 1) } as *mut u8;
    if ptr.is_null() {
        std::alloc::handle_alloc_error(std::alloc::Layout::array::<u8>(text.len() + 1).unwrap());
    }
    unsafe {
        std::ptr::copy_nonoverlapping(text.as_ptr(), ptr, text.len());
        *ptr.add(text.len()) = 0;
    }
    lock(&BUFFERS).insert(ptr as usize);
    Bytes { ptr, len: text.len() }
}

/// Runs the instance's initialization or one of its exports with the call
/// discipline (frame-walk ceiling, rooted arguments; the caller holds the
/// program scope), and returns the raw result: NO_VALUE when Botlish failed.
fn run(instance: &mut Instance, f: impl FnOnce(&mut Vm) -> Value) -> Value {
    let vm = &mut *instance.vm;
    let roots = vm.temp_roots.len();
    let value = enter(vm, f);
    vm.temp_roots.truncate(roots);
    value
}

// ------------------------------------------------------------------ the ABI

/// `NAME_create(NAME_instance **instance, NAME_error **error)`.
///
/// # Safety
/// PROGRAM is the library's own record; INSTANCE and ERROR are the caller's
/// pointers (ERROR may be NULL).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_create(program: *const LinkedProgram, instance: *mut usize, error: *mut *mut LibError) -> i32 {
    guarded(error, || {
        if instance.is_null() {
            return Err(invocation("NULL-POINTER", "the instance out-parameter is NULL"));
        }
        // SAFETY: the caller's contract.
        unsafe { *instance = 0 };
        // SAFETY: PROGRAM is the record the library object emitted.
        let (descriptor, code) = unsafe { program::read_linked(&*program) }.map_err(|e| LibError::new(STATUS_INTERNAL, "NATIVE STARTUP", e))?;
        // A library's code runs on its host's thread: its record carries the
        // default policy (codegen::library), which nothing here reads
        // further (MAIN-THREAD-STARTUP-MILESTONE-1.md).
        // SAFETY: read_linked checked the record.
        if unsafe { program::startup_of(&*program) } != Ok(program::Startup::Worker) {
            return Err(LibError::new(STATUS_INTERNAL, "NATIVE STARTUP", "a native library's program record names an executable's startup policy".to_string()));
        }
        let previous = vm::swap_current_program(None);
        let (mut vm, entry): (Box<Vm>, ProgramEntry) = program::instantiate(&descriptor, &code);
        vm.set_argv(Vec::new());
        // A library's code checks its stack (codegen::clif's
        // `prologue_stack_limit`): no guard of ours runs in the host.
        vm.check_stack_limit();
        let mut made = Instance { vm, exports: descriptor.exports, code, program: program as usize };
        let initialized = {
            let _scope = ProgramScope::enter(&made.vm);
            let value = run(&mut made, |vm| entry(vm));
            if value == NO_VALUE { Err(botlish_error(&mut made.vm)) } else { Ok(()) }
        };
        vm::swap_current_program(previous);
        initialized?;
        let handle = Box::into_raw(Box::new(0u64)) as usize;
        let raw = Box::into_raw(Box::new(made));
        lock(&INSTANCES).insert(handle, Entry { instance: raw, owner: std::thread::current().id(), busy: false });
        // SAFETY: the caller's contract.
        unsafe { *instance = handle };
        Ok(())
    })
}

/// `NAME_destroy(NAME_instance *instance)`: frees the instance's Vm and
/// everything its heap holds. Results and errors it handed out stay valid.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_destroy(_program: *const LinkedProgram, instance: usize) -> i32 {
    guarded(std::ptr::null_mut(), || {
        let raw = {
            let mut instances = lock(&INSTANCES);
            let Some(entry) = instances.get(&instance) else {
                return Err(invocation("INVALID-INSTANCE", "not a live instance of this library"));
            };
            if entry.owner != std::thread::current().id() {
                return Err(invocation("WRONG-THREAD", "an instance is destroyed on the thread that created it"));
            }
            if entry.busy {
                return Err(invocation("REENTRANT-CALL", "the instance is running a call"));
            }
            instances.remove(&instance).unwrap().instance
        };
        // SAFETY: removed from the registry above, so this is its one owner.
        drop(unsafe { Box::from_raw(raw) });
        Ok(())
    })
}

/// One export's call: `NAME_FN(instance, ARGS..., [out,] error)` stores its
/// arguments' words at ARGS and calls this with its export index.
///
/// # Safety
/// ARGS holds the export's argument words; OUT points to its result's C
/// type (NULL for a unit result); ERROR may be NULL.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn botlish_library_call(
    program: *const LinkedProgram,
    instance: usize,
    export: u64,
    args: *const u64,
    out: *mut c_void,
    error: *mut *mut LibError,
) -> i32 {
    guarded(error, || {
        let raw = checkout(instance)?;
        let _checkin = Checkin(instance);
        // SAFETY: checked out: this thread owns the instance for the call.
        let instance = unsafe { &mut *raw };
        let _scope = ProgramScope::enter(&instance.vm);
        call_checked(instance, program, export as usize, args, out)
    })
}

fn call_checked(instance: &mut Instance, program: *const LinkedProgram, export: usize, args: *const u64, out: *mut c_void) -> Result<(), LibError> {
    if instance.program != program as usize {
        return Err(invocation("INVALID-INSTANCE", "an instance of another library"));
    }
    let Some(decl) = instance.exports.get(export).cloned() else {
        return Err(LibError::new(STATUS_INTERNAL, "NATIVE BUG", format!("no export {export}")));
    };
    if decl.result != Boundary::Unit && out.is_null() {
        return Err(invocation("NULL-POINTER", format!("{}: the result out-parameter is NULL", decl.symbol)));
    }
    let words: usize = decl.params.iter().map(|p| p.words()).sum();
    // SAFETY: the trampoline stored WORDS words at ARGS.
    let words = if words == 0 { &[][..] } else { unsafe { std::slice::from_raw_parts(args, words) } };
    let entry: GenericEntry = {
        let address = instance.code[decl.func as usize].1;
        // SAFETY: a generic entry has the GenericEntry signature.
        unsafe { std::mem::transmute(address) }
    };
    let mut failure = None;
    let value = run(instance, |vm| {
        let mut values = Vec::with_capacity(decl.params.len());
        let mut at = 0;
        for (index, &ty) in decl.params.iter().enumerate() {
            match argument(vm, index, ty, &words[at..at + ty.words()]) {
                Ok(v) => values.push(v),
                Err(e) => {
                    failure = Some(e);
                    return NO_VALUE;
                }
            }
            at += ty.words();
        }
        // SAFETY: the export root's generic entry, called with one tagged
        // Value per parameter of its declared types.
        unsafe { entry(vm, 0, values.as_ptr()) }
    });
    if let Some(e) = failure {
        return Err(e);
    }
    if value == NO_VALUE {
        return Err(botlish_error(&mut instance.vm));
    }
    result(&mut instance.vm, decl.result, value, out)
}

/// `NAME_error_release(NAME_error **error)`: frees *ERROR and sets it NULL.
/// A NULL ERROR or *ERROR is a no-op; an error this library does not hold is
/// refused (INVOCATION) and left alone.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_release(error: *mut *mut LibError) -> i32 {
    if error.is_null() {
        return STATUS_OK;
    }
    // SAFETY: the caller's `NAME_error **`.
    let raw = unsafe { *error };
    if raw.is_null() {
        return STATUS_OK;
    }
    if !lock(&ERRORS).remove(&(raw as usize)) {
        return STATUS_INVOCATION;
    }
    // SAFETY: removed from the live set: this is its one release.
    drop(unsafe { Box::from_raw(raw) });
    unsafe { *error = std::ptr::null_mut() };
    STATUS_OK
}

/// `NAME_bytes_release(NAME_bytes *bytes)`: frees the buffer and clears the
/// struct. A NULL BYTES or a cleared struct is a no-op; a buffer this
/// library does not hold is refused (INVOCATION) and left alone.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_bytes_release(bytes: *mut Bytes) -> i32 {
    if bytes.is_null() {
        return STATUS_OK;
    }
    // SAFETY: the caller's `NAME_bytes *`.
    let b = unsafe { &mut *bytes };
    if b.ptr.is_null() {
        return STATUS_OK;
    }
    if !lock(&BUFFERS).remove(&(b.ptr as usize)) {
        return STATUS_INVOCATION;
    }
    // SAFETY: removed from the live set: this is its one release.
    unsafe { libc::free(b.ptr as *mut c_void) };
    b.ptr = std::ptr::null_mut();
    b.len = 0;
    STATUS_OK
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_abi_version() -> u32 {
    ABI_VERSION
}

/// The live error ERROR, or None for a NULL or unknown one.
fn live_error<'a>(error: *const LibError) -> Option<&'a LibError> {
    if error.is_null() || !lock(&ERRORS).contains(&(error as usize)) {
        return None;
    }
    // SAFETY: a live error object this library made.
    Some(unsafe { &*error })
}

fn give(text: &[u8], ptr: *mut *const u8, len: *mut usize) -> i32 {
    if ptr.is_null() || len.is_null() {
        return STATUS_INVOCATION;
    }
    // SAFETY: the caller's out-parameters.
    unsafe {
        *ptr = text.as_ptr();
        *len = text.len();
    }
    STATUS_OK
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_status(error: *const LibError) -> i32 {
    live_error(error).map_or(STATUS_INVOCATION, |e| e.status)
}

/// The error's identity, borrowed from it until its release.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_identity(error: *const LibError, ptr: *mut *const u8, len: *mut usize) -> i32 {
    live_error(error).map_or(STATUS_INVOCATION, |e| give(&e.identity, ptr, len))
}

/// The error's message, borrowed from it until its release.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_message(error: *const LibError, ptr: *mut *const u8, len: *mut usize) -> i32 {
    live_error(error).map_or(STATUS_INVOCATION, |e| give(&e.message, ptr, len))
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_count(error: *const LibError) -> usize {
    live_error(error).map_or(0, |e| e.fields.len())
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_name(error: *const LibError, index: usize, ptr: *mut *const u8, len: *mut usize) -> i32 {
    match live_error(error).and_then(|e| e.fields.get(index)) {
        Some((name, _)) => give(name, ptr, len),
        None => STATUS_INVOCATION,
    }
}

/// The field's type (NAME_FIELD_*), or 0 for no such field.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_type(error: *const LibError, index: usize) -> i32 {
    match live_error(error).and_then(|e| e.fields.get(index)) {
        Some((_, FieldValue::Int(_) | FieldValue::BigInt)) => FIELD_INT,
        Some((_, FieldValue::Bool(_))) => FIELD_BOOL,
        Some((_, FieldValue::Float64(_))) => FIELD_FLOAT64,
        Some((_, FieldValue::Str(_))) => FIELD_STR,
        Some((_, FieldValue::Other)) => FIELD_OTHER,
        None => 0,
    }
}

fn field<'a>(error: *const LibError, index: usize) -> Result<&'a FieldValue, i32> {
    live_error(error).and_then(|e| e.fields.get(index)).map(|(_, v)| v).ok_or(STATUS_INVOCATION)
}

/// An Int field: OK, BOUNDARY when no int64_t holds it, INVOCATION for no
/// such field or another type.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_int(error: *const LibError, index: usize, out: *mut i64) -> i32 {
    match field(error, index) {
        Ok(FieldValue::Int(n)) if !out.is_null() => {
            unsafe { *out = *n };
            STATUS_OK
        }
        Ok(FieldValue::BigInt) => STATUS_BOUNDARY,
        Ok(_) => STATUS_INVOCATION,
        Err(status) => status,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_bool(error: *const LibError, index: usize, out: *mut bool) -> i32 {
    match field(error, index) {
        Ok(FieldValue::Bool(b)) if !out.is_null() => {
            unsafe { *out = *b };
            STATUS_OK
        }
        Ok(_) => STATUS_INVOCATION,
        Err(status) => status,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_float64(error: *const LibError, index: usize, out: *mut f64) -> i32 {
    match field(error, index) {
        Ok(FieldValue::Float64(x)) if !out.is_null() => {
            unsafe { *out = *x };
            STATUS_OK
        }
        Ok(_) => STATUS_INVOCATION,
        Err(status) => status,
    }
}

/// A String field's UTF-8, borrowed from the error until its release.
#[unsafe(no_mangle)]
pub extern "C" fn botlish_library_error_field_str(error: *const LibError, index: usize, ptr: *mut *const u8, len: *mut usize) -> i32 {
    match field(error, index) {
        Ok(FieldValue::Str(text)) => give(text, ptr, len),
        Ok(_) => STATUS_INVOCATION,
        Err(status) => status,
    }
}

/// The runtime functions a library object's public functions forward to,
/// as (public suffix, runtime symbol, parameter words, result, takes the
/// program record first): codegen::library writes one forwarder per entry.
/// The result is `i32`, `u32`, `usize` (`u64`) or nothing.
pub const FORWARDERS: &[(&str, &str, usize, &str, bool)] = &[
    ("create", "botlish_library_create", 2, "i32", true),
    ("destroy", "botlish_library_destroy", 1, "i32", true),
    ("abi_version", "botlish_library_abi_version", 0, "u32", false),
    ("error_release", "botlish_library_error_release", 1, "i32", false),
    ("error_status", "botlish_library_error_status", 1, "i32", false),
    ("error_identity", "botlish_library_error_identity", 3, "i32", false),
    ("error_message", "botlish_library_error_message", 3, "i32", false),
    ("error_field_count", "botlish_library_error_field_count", 1, "u64", false),
    ("error_field_name", "botlish_library_error_field_name", 4, "i32", false),
    ("error_field_type", "botlish_library_error_field_type", 2, "i32", false),
    ("error_field_int", "botlish_library_error_field_int", 3, "i32", false),
    ("error_field_bool", "botlish_library_error_field_bool", 3, "i32", false),
    ("error_field_float64", "botlish_library_error_field_float64", 3, "i32", false),
    ("error_field_str", "botlish_library_error_field_str", 4, "i32", false),
    ("bytes_release", "botlish_library_bytes_release", 1, "i32", false),
];

/// The runtime function every export's trampoline calls.
pub const CALL: &str = "botlish_library_call";

/// The public names a library reserves for its runtime API (`NAME_SUFFIX`):
/// an export may not take one.
pub fn reserved(suffix: &str) -> bool {
    FORWARDERS.iter().any(|f| f.0 == suffix)
}
