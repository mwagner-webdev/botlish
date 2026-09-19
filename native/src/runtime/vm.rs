//! The virtual machine state generated code runs against.
//!
//! Generated code receives `*mut Vm` as its first argument and reads the
//! first three fields at fixed offsets (see `VM_*_OFFSET`):
//!
//!   ss_top    next free shadow-stack slot
//!   ss_limit  end of the shadow stack
//!   consts    the program's constant table (strings, big Ints, natives,
//!             closures of environment-free functions)

use super::error::RtError;
use super::heap::Heap;
use super::metrics::{AllocMode, GcReason, Metrics};
use super::value::*;
use crate::nir::OpCode;
use std::cell::RefCell;
use std::mem::offset_of;
use std::rc::Rc;

/// Shadow stack capacity in slots (one per register of an active frame).
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

pub struct ProgramInfo {
    pub functions: Vec<FunctionInfo>,
    pub natives: Vec<NativeInfo>,
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
    ss_base: *mut Value,
    shadow: Vec<Value>,
    pub heap: Heap,
    pub error: Option<RtError>,
    pub temp_roots: Vec<Value>,
    pub info: Rc<ProgramInfo>,
    pub metrics: Metrics,
    const_table: Vec<Value>,
    statics: Vec<*mut Header>,
}

pub const VM_SS_TOP_OFFSET: i32 = offset_of!(Vm, ss_top) as i32;
pub const VM_SS_LIMIT_OFFSET: i32 = offset_of!(Vm, ss_limit) as i32;
pub const VM_CONSTS_OFFSET: i32 = offset_of!(Vm, consts) as i32;
pub const VM_ALLOC_SITE_OFFSET: i32 = offset_of!(Vm, alloc_site) as i32;
pub const VM_NATIVE_ROOTS_PTR_OFFSET: i32 = offset_of!(Vm, native_roots_ptr) as i32;
pub const VM_NATIVE_ROOTS_LEN_OFFSET: i32 = offset_of!(Vm, native_roots_len) as i32;

impl Vm {
    pub fn new(info: Rc<ProgramInfo>, alloc_mode: AllocMode) -> Box<Vm> {
        let mut shadow = vec![0u64; SHADOW_STACK_SLOTS];
        let base = shadow.as_mut_ptr();
        let limit = unsafe { base.add(SHADOW_STACK_SLOTS) };
        PROGRAM.with(|p| *p.borrow_mut() = Some(info.clone()));
        Box::new(Vm {
            ss_top: base,
            ss_limit: limit,
            consts: std::ptr::null(),
            alloc_site: 0,
            native_roots_ptr: std::ptr::null_mut(),
            native_roots_len: 0,
            ss_base: base,
            shadow,
            heap: Heap::new(),
            error: None,
            temp_roots: Vec::new(),
            info,
            metrics: Metrics::new(alloc_mode),
            const_table: Vec::new(),
            statics: Vec::new(),
        })
    }

    /// Installs the constant table (static objects owned by the VM).
    pub fn set_constants(&mut self, table: Vec<Value>, statics: Vec<*mut Header>) {
        self.const_table = table;
        self.consts = self.const_table.as_ptr();
        self.statics = statics;
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

    fn collect_with(&mut self, reason: GcReason) {
        let stack = unsafe {
            std::slice::from_raw_parts(self.ss_base, self.ss_top.offset_from(self.ss_base) as usize)
        };
        // The currently active RootStorage::NativeFrame function's own root
        // block, if any (see that field's doc): empty when no such function
        // is on the call stack right now (native_roots_ptr null, or -- same
        // thing -- native_roots_len 0).
        let native = if self.native_roots_ptr.is_null() {
            &[][..]
        } else {
            unsafe { std::slice::from_raw_parts(self.native_roots_ptr, self.native_roots_len as usize) }
        };
        let error_values = self.error.as_ref().map(|e| e.values()).unwrap_or_default();
        let roots =
            stack.iter().copied().chain(native.iter().copied()).chain(error_values).chain(self.temp_roots.iter().copied());
        self.heap.collect(roots.collect::<Vec<_>>().into_iter(), &mut self.metrics, reason);
    }

    /// Prepares for the next run: empty shadow stack, no error, empty heap,
    /// fresh metrics (per-run isolation: a run's report must not include an
    /// earlier run's allocations). Metrics are reset before the cleanup
    /// collection below runs, so that collection's own effect (releasing
    /// the previous run's objects) is visible in the new run's report as
    /// its first GC cycle, not folded into stale totals.
    pub fn reset(&mut self) {
        self.ss_top = self.ss_base;
        self.native_roots_ptr = std::ptr::null_mut();
        self.native_roots_len = 0;
        self.error = None;
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

    pub fn new_str(&mut self, text: String) -> Value {
        let obj = str_object(text, false);
        if let Some(v) = self.reject_oversized_collection(obj.chars) {
            return v;
        }
        let bytes = obj.text.len();
        self.alloc(obj, bytes)
    }

    /// A string whose character count and ASCII flag the caller knows.
    pub fn new_str_known(&mut self, text: String, chars: usize, ascii: bool) -> Value {
        debug_assert_eq!(chars, text.chars().count());
        debug_assert_eq!(ascii, text.is_ascii());
        if let Some(v) = self.reject_oversized_collection(chars) {
            return v;
        }
        let bytes = text.len();
        let obj = StrObj { hdr: Header::new(KIND_STR, false), chars, ascii, text: text.into_boxed_str() };
        self.alloc(obj, bytes)
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

    /// Enforces MAX_COLLECTION_LENGTH (see its doc comment): Some(NO_VALUE)
    /// with a pending RANGE error if LEN exceeds it, else None (construct as
    /// normal). Every String/List constructor routes through this, so
    /// `length`/`list_length`'s `-result-range collection-length` metadata
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
    }
}

pub fn str_object(text: String, is_static: bool) -> StrObj {
    let ascii = text.is_ascii();
    let chars = if ascii { text.len() } else { text.chars().count() };
    StrObj { hdr: Header::new(KIND_STR, is_static), chars, ascii, text: text.into_boxed_str() }
}
