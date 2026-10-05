//! The virtual machine state generated code runs against.
//!
//! Generated code receives `*mut Vm` as its first argument and reads the
//! first three fields at fixed offsets (see `VM_*_OFFSET`):
//!
//!   ss_top    next free shadow-stack slot
//!   ss_limit  end of the shadow stack
//!   consts    the program's constant table (strings, big Ints, natives,
//!             closures of environment-free functions)
//!
//! Generated code also reads/writes `statics_ptr` at VM_STATICS_OFFSET (a
//! fixed offset, not one of the first three, but a raw pointer read/written
//! the same way): module-static storage, MODULE-STATIC-RETAINED-VALUES.md.
//! Unlike `consts` (read-only, compile-time-derived data), a static slot is
//! written once by generated code itself (module initialization) and read
//! any number of times afterward -- see `install_statics` and `statics_ptr`'s
//! own doc.

use super::error::RtError;
use super::framemap::ProgramMap;
use super::heap::Heap;
use super::metrics::{AllocMode, GcReason, Metrics};
use super::native_stack::NativeStack;
use super::bytesobj::BytesInit;
use super::strobj::StrInit;
use super::value::*;
use crate::nir::OpCode;
use std::cell::RefCell;
use std::mem::offset_of;
use std::rc::Rc;

/// The argument vector of a run nobody gave one: a synthetic argument zero
/// (core::process::defaultArgv), never the launching process's own.
pub const DEFAULT_ARGV: &[&str] = &["botlish-runner"];

/// Fallback shadow stack capacity in Value slots.
const SHADOW_STACK_SLOTS: usize = 1 << 22;

pub struct FunctionInfo {
    pub arity: usize,
    /// Parameter names joined by spaces, as block messages show them.
    pub pnames: String,
}

pub struct NativeInfo {
    pub name: String,
    /// None for any number of arguments.
    pub arity: Option<usize>,
    /// The kind each parameter must have (None: any), checked in order.
    pub params: Vec<Option<Kind>>,
    pub op: OpCode,
}

/// One struct shape (STRUCTS.md): the static description every struct object
/// of the shape shares -- static, non-GC data of the program, looked up only
/// by equality, hashing, printing and handing values back to the host, never
/// by field access (a projection compiles to a constant slot).
///
/// An anonymous shape (`name` None) is a field set: `fields` in canonical
/// (sorted) slot order, one shape per distinct set however literals spelled
/// it. A named shape (`name` Some) is one declaration's identity (program-
/// unique, module-qualified as "namespace::Name") with its declared slot
/// order: two declarations with equal fields remain two shapes.
pub struct ShapeInfo {
    pub name: Option<String>,
    pub fields: Vec<String>,
    /// The declaration is an `opaque struct` (OPAQUE-STRUCTS.md): its
    /// representation belongs to the declaring module at the source level.
    /// Purely a rendering fact -- `show` prints a value of it by its nominal
    /// type only; no operation, check or layout consults it. Always false for
    /// an anonymous shape.
    pub opaque: bool,
}

pub struct ProgramInfo {
    pub functions: Vec<FunctionInfo>,
    pub natives: Vec<NativeInfo>,
    /// The program's struct shapes, indexed by the shape number NIR's
    /// `structnew` carries and `StructObj::shape` stores.
    pub shapes: Vec<ShapeInfo>,
}

thread_local! {
    static PROGRAM: RefCell<Option<Rc<ProgramInfo>>> = const { RefCell::new(None) };
}

/// Runs F with the program currently executing on this thread.
pub fn current_program<R>(f: impl FnOnce(&ProgramInfo) -> R) -> R {
    PROGRAM.with(|p| f(p.borrow().as_ref().expect("no native program is running")))
}

#[repr(C)]
pub struct Vm {
    pub ss_top: *mut Value,
    pub ss_limit: *mut Value,
    pub consts: *const Value,
    /// The allocation site (codegen::clif's per-instruction site table
    /// index; 0 = unattributed) of the instruction about to call an
    /// allocating helper. Only written by generated code in Sites mode
    /// (see metrics.rs); read and reset to 0 by `Vm::alloc`.
    pub alloc_site: u32,
    /// The currently active `RootStorage::NativeFrame` function's own root
    /// block (null when none is active): codegen::clif's prologue publishes
    /// its Cranelift stack slot's address and slot count here instead of
    /// participating in `ss_top`/`ss_limit`/`shadow` below, and restores
    /// whatever was here on entry before returning (see codegen::roots's
    /// `RootStorage` doc for why at most one such registration can ever be
    /// active at a time). Scanned by `collect_with` alongside the shadow
    /// stack, the pending error, and `temp_roots` -- a fourth, minimal root
    /// source, not a replacement for any of the others.
    pub native_roots_ptr: *mut Value,
    /// A plain word (not `u32`) so generated code can store/reload it with
    /// the same I64 op it already uses for `native_roots_ptr`, without a
    /// second width.
    pub native_roots_len: u64,
    /// Module-static storage (MODULE-STATIC-RETAINED-VALUES.md): the base
    /// address of `statics_table` below, read by generated code
    /// (codegen::clif's StaticGet/StaticSet, at VM_STATICS_OFFSET) exactly
    /// like `consts` above, except mutable -- a module-static slot is
    /// written once, by the program function's own module-initialization
    /// code, then only ever read afterward. Recomputed whenever
    /// `install_statics` (re)allocates `statics_table`; never written by
    /// anything else, so it always agrees with `statics_table.as_mut_ptr()`.
    pub statics_ptr: *mut Value,
    /// The module-static slots themselves: one per module-static binding
    /// this program declares (nir::Program's own `statics` count), each a
    /// plain Value, pre-filled with UNIT until generated code overwrites it.
    /// A GC root for as long as this Vm exists: scanned unconditionally by
    /// `collect_with` below, exactly like `temp_roots` -- module/program
    /// lifetime, never cleared by `reset` (see that method's own doc: each
    /// run's own module-initialization code overwrites every slot it can
    /// possibly read from before anything reads it, in the same left-to-
    /// right order the interpreter and Tcl compiler already use, so a
    /// slot's previous run's value is retained a little longer than
    /// strictly necessary -- safe, never a use-after-free -- rather than
    /// ever observed stale).
    statics_table: Vec<Value>,
    ss_base: *mut Value,
    shadow: Vec<Value>,
    pub heap: Heap,
    pub error: Option<RtError>,
    /// The identity of the most recent unhandled `fail` (EXPLICIT-ERROR-
    /// COMPLETIONS.md), a small 1-indexed id native/lower.tcl assigns each
    /// declared error name at NIR-build time (0 = none pending). Set by
    /// `rt_fail_declared` alongside `error` (a fallback RtError, in case
    /// this propagates uncaught all the way to the program boundary);
    /// cleared, along with `error`, by `rt_clear_declared_error` when a
    /// `handle` (codegen::clif's PushErrorExit/PopErrorExit) catches it.
    /// Never itself a GC root: an id is a small compile-time constant, not
    /// a heap value.
    pub declared_error: u32,
    /// The process argument snapshot of this run, as raw bytes exactly as
    /// the launching process supplied them (ARGV.md): copied here once, at
    /// startup or by the harness, and never decoded until `argv()` runs.
    /// Owned by the Vm, so it outlives the C startup array it came from.
    argv: Vec<Vec<u8>>,
    /// The index of the first argument of `argv` that is not valid UTF-8
    /// (`Some(i)`), or `None` when every argument is -- a cache of the
    /// validation, computed on the first `argv()` call (`argv_status`);
    /// never observable, and never a GC root (a plain index).
    argv_invalid: std::cell::OnceCell<Option<usize>>,
    pub temp_roots: Vec<Value>,
    pub info: Rc<ProgramInfo>,
    pub metrics: Metrics,
    const_table: Vec<Value>,
    statics: Vec<*mut Header>,
    /// The one canonical empty String (static: never collected, not in the
    /// heap's object list, not a program constant). Every dynamic String
    /// constructor returns it instead of allocating a zero-byte object;
    /// Strings are immutable, so sharing it is unobservable.
    empty_str: *mut Header,
    /// The one canonical empty byte storage (static, like `empty_str`):
    /// `abi::bytes::from_list([])` allocates nothing. Storages are immutable, so sharing
    /// it is unobservable (a Bytes' identity is not part of its value).
    empty_bytes: *mut Header,
    /// The one canonical EMPTY writable storage (static): a zero-length
    /// MutableBytes has no byte any value could write or observe, so sharing
    /// one object is unobservable. A non-empty storage is never shared
    /// (MUTABLE-BYTES.md: every non-empty one is its own heap object).
    empty_mutbytes: *mut Header,
    /// This program's PC-indexed stack-map table (runtime::framemap), set
    /// once by `set_framemap` right after compiling (codegen::CompiledProgram
    /// owns the original; this is an `Rc` clone). `collect_with` walks the
    /// native call stack through it (runtime::framewalk) to discover every
    /// active `RootStorage::NativeFrame` function's roots on the x86-64
    /// stack-map path -- a fifth root source, alongside the shadow stack,
    /// `native_roots_ptr`/`_len` (the fallback path's own, narrower
    /// mechanism), the pending error, and `temp_roots`; see `collect_with`'s
    /// own doc for why these never double-trace the same logical root.
    /// Starts as an empty table (`ProgramMap::new()`), which simply finds no
    /// roots -- harmless for the brief window before a program is compiled.
    framemap: Rc<ProgramMap>,
    native_stack: Option<NativeStack>,
}

pub const VM_SS_TOP_OFFSET: i32 = offset_of!(Vm, ss_top) as i32;
pub const VM_SS_LIMIT_OFFSET: i32 = offset_of!(Vm, ss_limit) as i32;
pub const VM_CONSTS_OFFSET: i32 = offset_of!(Vm, consts) as i32;
pub const VM_ALLOC_SITE_OFFSET: i32 = offset_of!(Vm, alloc_site) as i32;
pub const VM_NATIVE_ROOTS_PTR_OFFSET: i32 = offset_of!(Vm, native_roots_ptr) as i32;
pub const VM_NATIVE_ROOTS_LEN_OFFSET: i32 = offset_of!(Vm, native_roots_len) as i32;
pub const VM_STATICS_OFFSET: i32 = offset_of!(Vm, statics_ptr) as i32;

impl Vm {
    pub fn new(info: Rc<ProgramInfo>, alloc_mode: AllocMode) -> Box<Vm> {
        let mut shadow = if super::native_stack::native_stack_overflow_supported() {
            Vec::new()
        } else {
            vec![0u64; SHADOW_STACK_SLOTS]
        };
        let base = if shadow.is_empty() { std::ptr::null_mut() } else { shadow.as_mut_ptr() };
        let limit = if shadow.is_empty() { base } else { unsafe { base.add(SHADOW_STACK_SLOTS) } };
        PROGRAM.with(|p| *p.borrow_mut() = Some(info.clone()));
        Box::new(Vm {
            ss_top: base,
            ss_limit: limit,
            consts: std::ptr::null(),
            alloc_site: 0,
            native_roots_ptr: std::ptr::null_mut(),
            native_roots_len: 0,
            statics_ptr: std::ptr::null_mut(),
            statics_table: Vec::new(),
            ss_base: base,
            shadow,
            heap: Heap::new(),
            error: None,
            declared_error: 0,
            argv: DEFAULT_ARGV.iter().map(|a| a.as_bytes().to_vec()).collect(),
            argv_invalid: std::cell::OnceCell::new(),
            temp_roots: Vec::new(),
            info,
            metrics: Metrics::new(alloc_mode),
            const_table: Vec::new(),
            statics: Vec::new(),
            empty_str: StrObj::new_static(""),
            empty_bytes: BytesObj::new_static(&[]),
            empty_mutbytes: BytesObj::new_static_mutable_empty(),
            framemap: Rc::new(ProgramMap::new()),
            native_stack: {
                #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
                { Some(NativeStack::current().expect("pthread stack bounds")) }
                #[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
                { None }
            },
        })
    }

    /// Replaces the argument snapshot with ARGV (raw bytes, one Vec per
    /// argument, zero arguments allowed). Validation stays lazy: nothing is
    /// decoded here.
    pub fn set_argv(&mut self, argv: Vec<Vec<u8>>) {
        self.argv = argv;
        self.argv_invalid = std::cell::OnceCell::new();
    }

    /// The raw argument snapshot.
    pub fn argv_raw(&self) -> &[Vec<u8>] {
        &self.argv
    }

    /// `None` if every argument is valid UTF-8, else the index of the first
    /// that is not (computed once, then cached).
    pub fn argv_status(&self) -> Option<usize> {
        *self.argv_invalid.get_or_init(|| self.argv.iter().position(|a| std::str::from_utf8(a).is_err()))
    }

    /// Installs the constant table (static objects owned by the VM).
    pub fn set_constants(&mut self, table: Vec<Value>, statics: Vec<*mut Header>) {
        self.const_table = table;
        self.consts = self.const_table.as_ptr();
        self.statics = statics;
    }

    /// Installs this program's stack-map table (see `framemap`'s own doc).
    pub fn set_framemap(&mut self, framemap: Rc<ProgramMap>) {
        self.framemap = framemap;
    }

    /// Sizes module-static storage to COUNT slots (nir::Program's own
    /// `statics`), called once per compiled program, before any generated
    /// code can run (mirrors `set_constants`). Every slot starts UNIT: a
    /// harmless, non-pointer placeholder no reference can observe before
    /// generated code overwrites it (module initialization always runs, in
    /// source order, before any code that could read a given slot -- MODULE-
    /// STATIC-RETAINED-VALUES.md). `statics_table` is never resized again
    /// after this, so `statics_ptr` stays valid for the Vm's whole lifetime.
    pub fn install_statics(&mut self, count: usize) {
        self.statics_table = vec![UNIT; count];
        self.statics_ptr = self.statics_table.as_mut_ptr();
    }

    pub fn fail(&mut self, error: RtError) -> Value {
        if self.error.is_none() {
            self.error = Some(error);
        }
        NO_VALUE
    }

    /// Allocates OBJ (collecting first if due). BYTES is its payload size
    /// (the object's Rust struct size is its header size: see metrics.rs's
    /// allocated_bytes definition).
    pub fn alloc<T>(&mut self, obj: T, bytes: usize) -> Value {
        if self.heap.wants_collection() {
            self.collect();
        }
        let raw = Box::into_raw(Box::new(obj)) as *mut Header;
        let header_bytes = std::mem::size_of::<T>();
        self.heap.register(raw, header_bytes + bytes);
        if self.metrics.enabled() {
            let kind = unsafe { (*raw).kind };
            let site = self.alloc_site;
            self.alloc_site = 0;
            self.metrics.record_alloc(kind, header_bytes, bytes, site);
        }
        raw as Value
    }

    /// Records one constant-table (static) object: allocated once per
    /// program by codegen::CompiledProgram::install_constants, outside the
    /// Heap's object list and never collected (see metrics.rs).
    pub fn record_static_alloc(&mut self, kind: u8, bytes: u64) {
        self.metrics.record_static(kind, bytes);
    }

    /// A collection triggered by an allocation (Heap::wants_collection):
    /// threshold or stress, whichever Heap says caused it.
    pub fn collect(&mut self) {
        let reason = self.heap.trigger_reason();
        self.collect_with(reason);
    }

    /// A collection on demand, for unit tests that drive the Vm directly.
    #[cfg(test)]
    pub fn collect_for_test(&mut self, reason: GcReason) {
        self.collect_with(reason);
    }

    fn collect_with(&mut self, reason: GcReason) {
        let stack = if self.shadow.is_empty() {
            &[][..]
        } else {
            unsafe { std::slice::from_raw_parts(self.ss_base, self.ss_top.offset_from(self.ss_base) as usize) }
        };
        // The currently active RootStorage::NativeFrame function's own root
        // block, if any (see that field's doc): empty when no such function
        // is on the call stack right now (native_roots_ptr null, or -- same
        // thing -- native_roots_len 0). Fallback path only (non-x86-64, or
        // any function `roots::plan` still routes there): on the stack-map
        // path below, `native_roots_ptr`/`_len` are never written at all
        // (codegen::clif's `prologue_native_frame`), so this is always empty
        // there -- see `native_frame_roots` below for why this is not a
        // double-count either way.
        let native = if self.native_roots_ptr.is_null() {
            &[][..]
        } else {
            unsafe { std::slice::from_raw_parts(self.native_roots_ptr, self.native_roots_len as usize) }
        };
        // Every `RootStorage::NativeFrame` function currently suspended
        // anywhere on the native call stack, on the x86-64 stack-map path
        // (runtime::framewalk; a no-op elsewhere -- see that module's own
        // `#[cfg]`-gated stub). This is the collector's replacement for
        // `RuntimeStack` as root storage for such a function: a function
        // covered by this walk never also stores a real Value into the
        // shadow array `stack` above (`codegen::clif::Translator::def`
        // stores to exactly one physical location per rooted register, and
        // `RootPlan::storage` picks that location once, never both), and
        // never also publishes to `native_roots_ptr`/`_len` (this module's
        // own comment above) -- so this walk's roots, `stack`'s, and
        // `native`'s are three disjoint sets of memory locations, never the
        // same logical root scanned twice.
        let mut native_frame_roots = Vec::new();
        super::framewalk::walk(&self.framemap, self.native_stack.as_ref(), |addr| native_frame_roots.push(unsafe { *addr }));
        let error_values = self.error.as_ref().map(|e| e.values()).unwrap_or_default();
        let roots = stack
            .iter()
            .copied()
            .chain(native.iter().copied())
            .chain(native_frame_roots)
            .chain(error_values)
            .chain(self.temp_roots.iter().copied())
            .chain(self.statics_table.iter().copied());
        self.heap.collect(roots.collect::<Vec<_>>().into_iter(), &mut self.metrics, reason);
    }

    /// Prepares for the next run: empty shadow stack, no error, empty heap,
    /// fresh metrics (per-run isolation: a run's report must not include an
    /// earlier run's allocations). Metrics are reset before the cleanup
    /// collection below runs, so that collection's own effect (releasing
    /// the previous run's objects) is visible in the new run's report as
    /// its first GC cycle, not folded into stale totals.
    ///
    /// `statics_table` is deliberately left untouched: it is module/program-
    /// lifetime storage, not per-run storage (`statics_ptr`'s own doc). The
    /// next run's own module-initialization code overwrites every slot it
    /// can possibly read from, in the same order it always has, before
    /// anything in that run reads it -- so a stale previous-run value is
    /// simply retained as an ordinary (harmless) GC root a little longer,
    /// exactly like this same collection call's other roots.
    pub fn reset(&mut self) {
        self.ss_top = self.ss_base;
        self.native_roots_ptr = std::ptr::null_mut();
        self.native_roots_len = 0;
        self.error = None;
        self.declared_error = 0;
        self.temp_roots.clear();
        self.metrics.reset();
        self.collect_with(GcReason::Explicit);
    }

    // -----------------------------------------------------------------------
    // Constructors

    pub fn new_big(&mut self, n: num_bigint::BigInt) -> Value {
        use num_traits::ToPrimitive;
        if let Some(small) = n.to_i64() {
            if fits_small(small) {
                return make_small(small);
            }
        }
        let bytes = n.bits() as usize / 8;
        self.alloc(BigIntObj { hdr: Header::new(KIND_BIGINT, false), n }, bytes)
    }

    pub fn new_int(&mut self, n: i64) -> Value {
        if fits_small(n) { make_small(n) } else { self.new_big(n.into()) }
    }

    /// Allocates the one block of a dynamic String of BYTE_LEN text bytes
    /// (strobj.rs: header + metadata + text, one allocation): enforces
    /// MAX_COLLECTION_LENGTH on CHARS (RANGE, no allocation), collects first
    /// if one is due (before the object exists), allocates, registers it with
    /// the heap, and returns the writer for the still-uninitialized text. No
    /// allocation happens between here and `StrInit::finish`, so no
    /// collection can observe the half-built object.
    fn alloc_str(&mut self, byte_len: usize, chars: usize, ascii: bool) -> Result<StrInit, Value> {
        if let Some(v) = self.reject_oversized_collection(chars) {
            return Err(v);
        }
        if self.heap.wants_collection() {
            self.collect();
        }
        let init = StrInit::new(byte_len, chars, ascii, false);
        self.heap.register(init.addr() as *mut Header, STR_HEADER_SIZE + byte_len);
        if self.metrics.enabled() {
            let site = self.alloc_site;
            self.alloc_site = 0;
            self.metrics.record_alloc(KIND_STR, STR_HEADER_SIZE, byte_len, site);
        }
        Ok(init)
    }

    /// The canonical empty String, counted for the audit report.
    #[inline]
    fn empty_string(&mut self) -> Value {
        if self.metrics.enabled() {
            self.metrics.str_empty_reuses += 1;
        }
        self.empty_str as Value
    }

    /// A String with the text TEXT (character count and ASCII flag computed
    /// here).
    pub fn new_str(&mut self, text: &str) -> Value {
        let ascii = text.is_ascii();
        let chars = if ascii { text.len() } else { text.chars().count() };
        self.new_str_known(text, chars, ascii)
    }

    /// A String whose character count and ASCII flag the caller knows: one
    /// allocation, the bytes copied straight into it.
    pub fn new_str_known(&mut self, text: &str, chars: usize, ascii: bool) -> Value {
        debug_assert_eq!(chars, text.chars().count());
        debug_assert_eq!(ascii, text.is_ascii());
        self.new_str_pieces(&[text], chars, ascii)
    }

    /// The concatenation of PIECES whose total character count and ASCII flag
    /// the caller knows: the final size is the sum of the pieces, so the
    /// String is allocated once and each piece is copied once, directly into
    /// place (no intermediate buffer).
    pub fn new_str_pieces(&mut self, pieces: &[&str], chars: usize, ascii: bool) -> Value {
        let byte_len: usize = pieces.iter().map(|p| p.len()).sum();
        if byte_len == 0 {
            return self.empty_string();
        }
        match self.alloc_str(byte_len, chars, ascii) {
            Err(v) => v,
            Ok(mut init) => {
                for piece in pieces {
                    init.push_str(piece);
                }
                init.finish() as Value
            }
        }
    }

    /// The one-character String of scalar C, its UTF-8 encoded straight
    /// into the new String's text.
    pub fn new_str_scalar(&mut self, c: char) -> Value {
        let n = c.len_utf8();
        match self.alloc_str(n, 1, n == 1) {
            Err(v) => v,
            Ok(mut init) => {
                init.push_scalar(c);
                init.finish() as Value
            }
        }
    }

    /// A String of BYTE_LEN bytes holding CHARS characters (ASCII exactly when
    /// the two are equal), whose text FILL writes in place with the writer's
    /// pushes: for the producers that know the result size before producing
    /// it (lowercase). The writer enforces valid UTF-8 and that every byte is
    /// written (strobj.rs), so FILL cannot build a malformed String.
    pub fn new_str_with(&mut self, byte_len: usize, chars: usize, fill: impl FnOnce(&mut StrInit)) -> Value {
        if byte_len == 0 {
            return self.empty_string();
        }
        match self.alloc_str(byte_len, chars, byte_len == chars) {
            Err(v) => v,
            Ok(mut init) => {
                fill(&mut init);
                init.finish() as Value
            }
        }
    }

    /// The String a ShortString1 scalar SHORT stands for (-1: the empty
    /// String, else the one character of that Unicode scalar value), UTF-8
    /// encoded directly into one freshly allocated String. There is no
    /// interned table: every runtime materialization of a non-empty value
    /// allocates (a value the compiler knows statically is a `str` constant
    /// instead, never reaching here).
    pub fn short_to_string(&mut self, short: i64) -> Value {
        if short == -1 {
            return self.empty_string();
        }
        let c = char::from_u32(short as u32).expect("a ShortString1 scalar is a Unicode scalar value");
        self.new_str_scalar(c)
    }

    /// The String a packed-ASCII word stands for: its bytes are the word
    /// masked to the 7-bit payload (one AND), only the first `len` of them
    /// written, directly into the one allocation.
    pub fn ascii_to_string(&mut self, word: u64) -> Value {
        let n = ascii_word_len(word);
        if n == 0 {
            return self.empty_string();
        }
        match self.alloc_str(n, n, true) {
            Err(v) => v,
            Ok(mut init) => {
                init.push_ascii_prefix(word, n);
                init.finish() as Value
            }
        }
    }

    /// Allocates the one block of a dynamic byte storage of LEN payload bytes
    /// (bytesobj.rs: header + length + payload, one allocation): enforces
    /// MAX_COLLECTION_LENGTH (RANGE, no allocation), collects first if one is
    /// due (before the object exists), allocates, registers it with the heap
    /// and returns the writer for the still-uninitialized payload. No
    /// allocation happens between here and `BytesInit::finish`, so no
    /// collection can observe the half-built object.
    fn alloc_bytes(&mut self, len: usize) -> Result<BytesInit, Value> {
        self.alloc_byte_storage(KIND_BYTES, len)
    }

    /// `alloc_bytes` for either storage kind (KIND_BYTES, or KIND_MUTBYTES for
    /// an `abi::bytes::MutableBytes`): the same single block, the same ceiling, the
    /// same collect-before-the-object-exists sequence.
    fn alloc_byte_storage(&mut self, kind: u8, len: usize) -> Result<BytesInit, Value> {
        if len > MAX_COLLECTION_LENGTH {
            let what = if kind == KIND_MUTBYTES { "MutableBytes" } else { "Bytes" };
            let message = format!("a {what} cannot exceed {MAX_COLLECTION_LENGTH} bytes, got {len}");
            return Err(self.fail(RtError::Semantic { kind: "RANGE", message }));
        }
        if self.heap.wants_collection() {
            self.collect();
        }
        let Some(init) = BytesInit::try_new_kind(kind, len, false) else {
            let what = if kind == KIND_MUTBYTES { "MutableBytes" } else { "Bytes" };
            let message = format!("cannot allocate a {len}-byte {what}: out of memory");
            return Err(self.fail(RtError::Semantic { kind: "RANGE", message }));
        };
        self.heap.register(init.addr() as *mut Header, BYTES_PAYLOAD_OFFSET + len);
        if self.metrics.enabled() {
            let site = self.alloc_site;
            self.alloc_site = 0;
            self.metrics.record_alloc(kind, BYTES_PAYLOAD_OFFSET, len, site);
        }
        Ok(init)
    }

    /// A writable byte storage of LEN bytes that FILL writes in place (every
    /// byte must be written). Always a fresh heap object -- never a static
    /// constant -- except the zero-length one, which is the shared static
    /// empty storage. The same rooting rule as `new_bytes_with`: FILL may read
    /// operands of the allocating instruction, which are roots across the
    /// collection that may run first.
    pub fn new_mutbytes_with(&mut self, len: usize, fill: impl FnOnce(&mut BytesInit)) -> Value {
        if len == 0 {
            return self.empty_mutbytes as Value;
        }
        match self.alloc_byte_storage(KIND_MUTBYTES, len) {
            Err(v) => v,
            Ok(mut init) => {
                fill(&mut init);
                init.finish() as Value
            }
        }
    }

    /// A byte storage holding exactly BYTES: one allocation, copied straight
    /// into place; the empty storage is the shared static one (no allocation).
    pub fn new_bytes(&mut self, bytes: &[u8]) -> Value {
        self.new_bytes_with(bytes.len(), |init| init.push_slice(bytes))
    }

    /// A byte storage of LEN bytes that FILL writes in place (every byte must
    /// be written: bytesobj.rs's `finish` asserts it). Allocation may collect
    /// first, so a caller's operands must be rooted (they are operands of an
    /// allocating instruction).
    pub fn new_bytes_with(&mut self, len: usize, fill: impl FnOnce(&mut BytesInit)) -> Value {
        if len == 0 {
            return self.empty_bytes as Value;
        }
        match self.alloc_bytes(len) {
            Err(v) => v,
            Ok(mut init) => {
                fill(&mut init);
                init.finish() as Value
            }
        }
    }

    pub fn new_list(&mut self, items: Vec<Value>) -> Value {
        if let Some(v) = self.reject_oversized_collection(items.len()) {
            return v;
        }
        let boxed: Box<[Value]> = items.into_boxed_slice();
        let len = boxed.len();
        let bytes = len * 8;
        let ptr = Box::into_raw(boxed) as *mut Value;
        self.alloc(ListObj { hdr: Header::new(KIND_LIST, false), len, ptr }, bytes)
    }

    /// A struct value of shape SHAPE whose fields are FIELDS, in slot order.
    /// Every field value was evaluated before this is called, and the
    /// object is complete when it first exists: nothing partially
    /// initialized is ever observable. (Allocation may collect first, which
    /// is why FIELDS' referents are rooted by the caller, like every
    /// allocating helper's operands.)
    pub fn new_struct(&mut self, shape: u32, fields: Vec<Value>) -> Value {
        let boxed: Box<[Value]> = fields.into_boxed_slice();
        let len = boxed.len();
        let bytes = len * 8;
        let ptr = Box::into_raw(boxed) as *mut Value;
        self.alloc(StructObj { hdr: Header::new(KIND_STRUCT, false), shape, len, ptr }, bytes)
    }

    /// An ImmutableSet of ITEMS, which must already be deduplicated (the one
    /// caller, `rt_set_from_list`, guarantees this): mirrors `new_list`
    /// exactly (MINIMAL-IMMUTABLE-SET.md item 31), under KIND_SET instead of
    /// KIND_LIST so the two runtime kinds are never confused.
    pub fn new_set(&mut self, items: Vec<Value>) -> Value {
        if let Some(v) = self.reject_oversized_collection(items.len()) {
            return v;
        }
        let boxed: Box<[Value]> = items.into_boxed_slice();
        let len = boxed.len();
        let bytes = len * 8;
        let ptr = Box::into_raw(boxed) as *mut Value;
        self.alloc(SetObj { hdr: Header::new(KIND_SET, false), len, ptr }, bytes)
    }

    /// Enforces MAX_COLLECTION_LENGTH (see its doc comment): Some(NO_VALUE)
    /// with a pending RANGE error if LEN exceeds it, else None (construct as
    /// normal). Every String/List constructor routes through this, so
    /// `str::length`/`list::length`'s `-result-range collection-length` metadata
    /// (core/native.tcl) is an actual checked invariant, not an assumption.
    fn reject_oversized_collection(&mut self, len: usize) -> Option<Value> {
        if len <= MAX_COLLECTION_LENGTH {
            return None;
        }
        let message = format!(
            "a String/List cannot exceed {MAX_COLLECTION_LENGTH} characters/elements, got {len}"
        );
        Some(self.fail(RtError::Semantic { kind: "RANGE", message }))
    }

    pub fn new_result(&mut self, ok: bool, payload: Value) -> Value {
        self.alloc(ResultObj { hdr: Header::new(KIND_RESULT, false), ok, payload }, 0)
    }

    /// A fresh MutableArray of CAPACITY slots, every slot initialized to
    /// UNIT (never uninitialized memory: see MutArrayObj's doc comment).
    /// Rejects a capacity outside 0..=MAX_COLLECTION_LENGTH with RANGE, the
    /// same construction limit every String/List already enforces.
    pub fn new_mutarray(&mut self, capacity: usize) -> Value {
        if let Some(v) = self.reject_oversized_collection(capacity) {
            return v;
        }
        let bytes = capacity * 8;
        let slots = vec![UNIT; capacity].into_boxed_slice();
        self.alloc(MutArrayObj { hdr: Header::new(KIND_MUTARRAY, false), slots }, bytes)
    }
}

impl Drop for Vm {
    fn drop(&mut self) {
        for &object in &self.statics {
            unsafe { super::heap::free_object(object) };
        }
        unsafe { super::heap::free_object(self.empty_str) };
        unsafe { super::heap::free_object(self.empty_bytes) };
        unsafe { super::heap::free_object(self.empty_mutbytes) };
    }
}
