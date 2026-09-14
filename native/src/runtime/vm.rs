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
    ss_base: *mut Value,
    shadow: Vec<Value>,
    pub heap: Heap,
    pub error: Option<RtError>,
    pub temp_roots: Vec<Value>,
    pub info: Rc<ProgramInfo>,
    const_table: Vec<Value>,
    statics: Vec<*mut Header>,
}

pub const VM_SS_TOP_OFFSET: i32 = offset_of!(Vm, ss_top) as i32;
pub const VM_SS_LIMIT_OFFSET: i32 = offset_of!(Vm, ss_limit) as i32;
pub const VM_CONSTS_OFFSET: i32 = offset_of!(Vm, consts) as i32;

impl Vm {
    pub fn new(info: Rc<ProgramInfo>) -> Box<Vm> {
        let mut shadow = vec![0u64; SHADOW_STACK_SLOTS];
        let base = shadow.as_mut_ptr();
        let limit = unsafe { base.add(SHADOW_STACK_SLOTS) };
        PROGRAM.with(|p| *p.borrow_mut() = Some(info.clone()));
        Box::new(Vm {
            ss_top: base,
            ss_limit: limit,
            consts: std::ptr::null(),
            ss_base: base,
            shadow,
            heap: Heap::new(),
            error: None,
            temp_roots: Vec::new(),
            info,
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

    /// Allocates OBJ (collecting first if due). BYTES is its payload size.
    pub fn alloc<T>(&mut self, obj: T, bytes: usize) -> Value {
        if self.heap.wants_collection() {
            self.collect();
        }
        let raw = Box::into_raw(Box::new(obj)) as *mut Header;
        self.heap.register(raw, std::mem::size_of::<T>() + bytes);
        raw as Value
    }

    pub fn collect(&mut self) {
        let stack = unsafe {
            std::slice::from_raw_parts(self.ss_base, self.ss_top.offset_from(self.ss_base) as usize)
        };
        let error_values = self.error.as_ref().map(|e| e.values()).unwrap_or_default();
        let roots = stack.iter().copied().chain(error_values).chain(self.temp_roots.iter().copied());
        self.heap.collect(roots.collect::<Vec<_>>().into_iter());
    }

    /// Prepares for the next run: empty shadow stack, no error, empty heap.
    pub fn reset(&mut self) {
        self.ss_top = self.ss_base;
        self.error = None;
        self.temp_roots.clear();
        self.collect();
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
        let bytes = items.capacity() * 8;
        self.alloc(ListObj { hdr: Header::new(KIND_LIST, false), items }, bytes)
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
