//! The native heap: allocation and a non-moving mark-and-sweep collector.
//!
//! Temporary memory-management strategy for the first native backend.
//!
//! Every heap object is an individually allocated Rust box registered in the
//! heap. A collection runs when the bytes allocated since the last one exceed
//! a threshold (twice the live bytes after the last collection, at least
//! `MIN_THRESHOLD`, 1 MB). It never runs except inside an allocation.
//!
//! Roots are precise:
//!   * the shadow stack: every register of every active native frame (the
//!     generated prologue reserves and clears one slot per register, and every
//!     definition of a register is stored to its slot)
//!   * the values of a pending error
//!   * `Vm::temp_roots`, for runtime code that holds values across an
//!     allocation
//!
//! Static objects (constants, natives, closures of environment-free functions)
//! are never collected and hold no references to collectable objects.
//!
//! Objects never move, so a register's machine copy stays valid across a
//! collection. Between program runs the whole heap is released.

use super::value::*;
use std::mem::size_of;

/// Collect at least this often. Small on purpose: without a nursery, garbage
/// left uncollected pushes new allocations into cold memory. Measured on the
/// corpus (string_replace 100 KB: 146 ms at 32 MB, 81 ms at 1 MB, 49 ms at
/// 256 KB; csv 10,000 rows: 358 ms, 180 ms, 237 ms). BOTLISH_NATIVE_GC_MIN
/// overrides it (bytes).
const MIN_THRESHOLD: usize = 1 << 20;

pub struct Heap {
    objects: Vec<*mut Header>,
    allocated: usize,
    threshold: usize,
    min_threshold: usize,
    pub collections: usize,
    stress: bool,
}

impl Heap {
    /// BOTLISH_NATIVE_GC_STRESS=1 collects before every allocation (for
    /// testing that every live value is rooted).
    pub fn new() -> Heap {
        let stress = std::env::var("BOTLISH_NATIVE_GC_STRESS").is_ok_and(|v| v == "1");
        let min_threshold = std::env::var("BOTLISH_NATIVE_GC_MIN")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(MIN_THRESHOLD);
        Heap { objects: Vec::new(), allocated: 0, threshold: min_threshold, min_threshold, collections: 0, stress }
    }

    /// Whether the next allocation should collect first.
    pub fn wants_collection(&self) -> bool {
        self.stress || self.allocated > self.threshold
    }

    /// Registers a new object of about BYTES bytes.
    pub fn register(&mut self, object: *mut Header, bytes: usize) {
        self.objects.push(object);
        self.allocated += bytes;
    }

    /// Frees every object not reachable from ROOTS.
    pub fn collect(&mut self, roots: impl Iterator<Item = Value>) {
        let mut stack: Vec<Value> = roots.collect();
        while let Some(v) = stack.pop() {
            if !is_pointer(v) {
                continue;
            }
            let header = unsafe { &mut *(v as *mut Header) };
            if header.is_static != 0 || header.marked != 0 {
                continue;
            }
            header.marked = 1;
            match header.kind {
                KIND_LIST => stack.extend_from_slice(&list_of(v).items),
                KIND_RESULT => stack.push(result_of(v).payload),
                KIND_CLOSURE => {
                    let c = closure_of(v);
                    stack.extend_from_slice(unsafe { std::slice::from_raw_parts(c.caps, c.ncaps) });
                }
                KIND_CELL => stack.push(unsafe { as_ref::<CellObj>(v) }.value),
                _ => {}
            }
        }
        let mut live = 0;
        self.objects.retain(|&object| {
            let header = unsafe { &mut *object };
            if header.marked != 0 {
                header.marked = 0;
                live += unsafe { object_size(object) };
                true
            } else {
                unsafe { free_object(object) };
                false
            }
        });
        self.allocated = 0;
        self.threshold = self.min_threshold.max(live * 2);
        self.collections += 1;
    }
}

impl Drop for Heap {
    fn drop(&mut self) {
        for &object in &self.objects {
            unsafe { free_object(object) };
        }
    }
}

/// Approximate bytes owned by OBJECT.
pub unsafe fn object_size(object: *mut Header) -> usize {
    let v = object as Value;
    unsafe {
        match (*object).kind {
            KIND_BIGINT => size_of::<BigIntObj>() + (as_ref::<BigIntObj>(v).n.bits() as usize / 8),
            KIND_STR => size_of::<StrObj>() + str_of(v).text.len(),
            KIND_LIST => size_of::<ListObj>() + list_of(v).items.capacity() * 8,
            KIND_RESULT => size_of::<ResultObj>(),
            KIND_CLOSURE => size_of::<ClosureObj>() + closure_of(v).ncaps * 8,
            KIND_NATIVE => size_of::<NativeObj>(),
            KIND_CELL => size_of::<CellObj>(),
            kind => panic!("bad heap object kind {kind}"),
        }
    }
}

/// Frees OBJECT (created by `Box::into_raw` of its type).
pub unsafe fn free_object(object: *mut Header) {
    unsafe {
        match (*object).kind {
            KIND_BIGINT => drop(Box::from_raw(object as *mut BigIntObj)),
            KIND_STR => drop(Box::from_raw(object as *mut StrObj)),
            KIND_LIST => drop(Box::from_raw(object as *mut ListObj)),
            KIND_RESULT => drop(Box::from_raw(object as *mut ResultObj)),
            KIND_CLOSURE => {
                let c = Box::from_raw(object as *mut ClosureObj);
                drop(Box::from_raw(std::ptr::slice_from_raw_parts_mut(c.caps, c.ncaps)));
            }
            KIND_NATIVE => drop(Box::from_raw(object as *mut NativeObj)),
            KIND_CELL => drop(Box::from_raw(object as *mut CellObj)),
            kind => panic!("bad heap object kind {kind}"),
        }
    }
}
