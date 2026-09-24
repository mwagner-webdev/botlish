//! The native heap: allocation and a non-moving mark-and-sweep collector.
//!
//! Temporary memory-management strategy for the first native backend.
//!
//! Every heap object is an individually allocated Rust box registered in the
//! heap. A collection runs when the bytes allocated since the last one exceed
//! a threshold (twice the live bytes after the last collection, at least
//! `MIN_THRESHOLD`, 1 MB). It never runs except inside an allocation.
//!
//! Roots are precise, from five sources (`Vm::collect_with`):
//!   * the shadow stack: every register of every active `RootStorage::
//!     RuntimeStack` frame (the generated prologue reserves and clears one
//!     slot per register, and every definition of a register is stored to
//!     its slot) -- on the x86-64 stack-map path this region only ever
//!     is empty and not allocated on x86-64/Linux
//!   * `Vm::native_roots_ptr`/`_len`: the currently active `RootStorage::
//!     NativeFrame` function's own root block, on the fallback (non-x86-64)
//!     path only -- see codegen::roots's `RootStorage` doc
//!   * the native call stack itself, walked through `runtime::framewalk`
//!     (x86-64 only): every `RootStorage::NativeFrame` function's roots,
//!     for however many such frames are nested, discovered via per-safepoint
//!     stack maps (`runtime::framemap`) instead of any registration Vm
//!     holds -- the collector's replacement for `RuntimeStack` as *root
//!     storage for
//!     every function this milestone covers, `fib<int>` included
//!   * the values of a pending error
//!   * `Vm::temp_roots`, for runtime code that holds values across an
//!     allocation
//!
//! Static objects (constants, natives, closures of environment-free functions)
//! are never collected and hold no references to collectable objects.
//!
//! Objects never move, so a register's machine copy stays valid across a
//! collection. Between program runs the whole heap is released.

use super::metrics::{GcCycle, GcReason, Metrics, KIND_COUNT};
use super::value::*;
use std::mem::size_of;
use std::time::Instant;

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

    /// Why the next allocation-triggered collection would run (Metrics'
    /// GcReason; Vm::reset's own collection uses GcReason::Explicit
    /// instead, since it is not triggered by an allocation at all).
    pub fn trigger_reason(&self) -> GcReason {
        if self.stress { GcReason::Stress } else { GcReason::Threshold }
    }

    /// Registers a new object of about BYTES bytes.
    pub fn register(&mut self, object: *mut Header, bytes: usize) {
        self.objects.push(object);
        self.allocated += bytes;
    }

    /// Frees every object not reachable from ROOTS. Updates METRICS exactly
    /// (never "allocated - freed") when it is enabled: this is the one
    /// place every object's fate -- live or reclaimed -- is known for
    /// certain, so live/peak/reclaimed accounting lives here rather than
    /// being approximated from allocation counts.
    pub fn collect(&mut self, roots: impl Iterator<Item = Value>, metrics: &mut Metrics, reason: GcReason) {
        let started = metrics.enabled().then(Instant::now);
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
                KIND_LIST => stack.extend_from_slice(list_of(v).items()),
                KIND_SET => stack.extend_from_slice(set_of(v).items()),
                // Every slot is traced, initialized or not: allocation fills
                // unused capacity with UNIT (Vm::new_mutarray), never
                // uninitialized memory, so there is nothing here that could
                // be mistaken for an arbitrary root.
                KIND_MUTARRAY => stack.extend_from_slice(&mutarray_of(v).slots),
                KIND_RESULT => stack.push(result_of(v).payload),
                KIND_CLOSURE => {
                    let c = closure_of(v);
                    stack.extend_from_slice(unsafe { std::slice::from_raw_parts(c.caps, c.ncaps) });
                }
                KIND_CELL => stack.push(unsafe { as_ref::<CellObj>(v) }.value),
                _ => {}
            }
        }

        let objects_before = self.objects.len() as u64;
        let bytes_before = if metrics.enabled() {
            self.objects.iter().map(|&o| unsafe { object_size(o) } as u64).sum()
        } else {
            0
        };
        let mut live = 0;
        let mut live_by_kind = [(0u64, 0u64); KIND_COUNT];
        let mut reclaimed_by_kind = [(0u64, 0u64); KIND_COUNT];
        self.objects.retain(|&object| {
            let header = unsafe { &mut *object };
            if header.marked != 0 {
                header.marked = 0;
                let size = unsafe { object_size(object) };
                live += size;
                if metrics.enabled() {
                    let k = &mut live_by_kind[header.kind as usize];
                    k.0 += 1;
                    k.1 += size as u64;
                }
                true
            } else {
                if metrics.enabled() {
                    let size = unsafe { object_size(object) };
                    let k = &mut reclaimed_by_kind[header.kind as usize];
                    k.0 += 1;
                    k.1 += size as u64;
                }
                unsafe { free_object(object) };
                false
            }
        });
        self.allocated = 0;
        self.threshold = self.min_threshold.max(live * 2);
        self.collections += 1;

        if metrics.enabled() {
            let mut reclaimed_objects = 0u64;
            let mut reclaimed_bytes = 0u64;
            for k in 0..KIND_COUNT {
                metrics.by_kind[k].live_objects = live_by_kind[k].0;
                metrics.by_kind[k].live_bytes = live_by_kind[k].1;
                metrics.by_kind[k].reclaimed_objects += reclaimed_by_kind[k].0;
                metrics.by_kind[k].reclaimed_bytes += reclaimed_by_kind[k].1;
                reclaimed_objects += reclaimed_by_kind[k].0;
                reclaimed_bytes += reclaimed_by_kind[k].1;
            }
            metrics.current_live_objects = self.objects.len() as u64;
            metrics.current_live_bytes = live as u64;
            metrics.peak_live_objects = metrics.peak_live_objects.max(metrics.current_live_objects);
            metrics.peak_live_bytes = metrics.peak_live_bytes.max(metrics.current_live_bytes);
            let duration = started.unwrap().elapsed();
            metrics.gc_time += duration;
            metrics.gc_max_pause = metrics.gc_max_pause.max(duration);
            metrics.gc_cycles.push(GcCycle {
                reason,
                objects_before,
                bytes_before,
                objects_reclaimed: reclaimed_objects,
                bytes_reclaimed: reclaimed_bytes,
                objects_after: self.objects.len() as u64,
                bytes_after: live as u64,
                duration,
            });
        }
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
            KIND_LIST => size_of::<ListObj>() + list_of(v).len * 8,
            KIND_SET => size_of::<SetObj>() + set_of(v).len * 8,
            KIND_MUTARRAY => size_of::<MutArrayObj>() + mutarray_of(v).slots.len() * 8,
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
            KIND_LIST => {
                let l = Box::from_raw(object as *mut ListObj);
                drop(Box::from_raw(std::ptr::slice_from_raw_parts_mut(l.ptr, l.len)));
            }
            KIND_SET => {
                let s = Box::from_raw(object as *mut SetObj);
                drop(Box::from_raw(std::ptr::slice_from_raw_parts_mut(s.ptr, s.len)));
            }
            KIND_RESULT => drop(Box::from_raw(object as *mut ResultObj)),
            KIND_CLOSURE => {
                let c = Box::from_raw(object as *mut ClosureObj);
                drop(Box::from_raw(std::ptr::slice_from_raw_parts_mut(c.caps, c.ncaps)));
            }
            KIND_NATIVE => drop(Box::from_raw(object as *mut NativeObj)),
            KIND_CELL => drop(Box::from_raw(object as *mut CellObj)),
            KIND_MUTARRAY => drop(Box::from_raw(object as *mut MutArrayObj)),
            kind => panic!("bad heap object kind {kind}"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;

    /// Vm::alloc's instrumentation, replicated for tests that exercise Heap
    /// and Metrics directly without a full Vm/compiled program.
    fn alloc<T>(heap: &mut Heap, metrics: &mut Metrics, obj: T, payload_bytes: usize) -> Value {
        let raw = Box::into_raw(Box::new(obj)) as *mut Header;
        let header_bytes = size_of::<T>();
        heap.register(raw, header_bytes + payload_bytes);
        if metrics.enabled() {
            let kind = unsafe { (*raw).kind };
            metrics.record_alloc(kind, header_bytes, payload_bytes, 0);
        }
        raw as Value
    }

    fn str_val(heap: &mut Heap, metrics: &mut Metrics, text: &str) -> Value {
        let obj =
            StrObj { hdr: Header::new(KIND_STR, false), chars: text.chars().count(), ascii: text.is_ascii(), text: text.into() };
        let bytes = obj.text.len();
        alloc(heap, metrics, obj, bytes)
    }

    fn list_val(heap: &mut Heap, metrics: &mut Metrics, items: Vec<Value>) -> Value {
        let boxed: Box<[Value]> = items.into_boxed_slice();
        let len = boxed.len();
        let bytes = len * 8;
        let ptr = Box::into_raw(boxed) as *mut Value;
        let obj = ListObj { hdr: Header::new(KIND_LIST, false), len, ptr };
        alloc(heap, metrics, obj, bytes)
    }

    #[test]
    fn counts_and_bytes_by_kind() {
        let mut heap = Heap::new();
        let mut metrics = Metrics::new(AllocMode::Summary);
        let a = str_val(&mut heap, &mut metrics, "hello");
        let b = str_val(&mut heap, &mut metrics, "world!!");
        list_val(&mut heap, &mut metrics, vec![a, b]);
        assert_eq!(metrics.total_allocations(), 3);
        assert_eq!(metrics.by_kind[KIND_STR as usize].allocations, 2);
        assert_eq!(metrics.by_kind[KIND_STR as usize].payload_bytes, 5 + 7);
        assert_eq!(metrics.by_kind[KIND_LIST as usize].allocations, 1);
        assert_eq!(metrics.total_allocated_bytes(), metrics.by_kind.iter().map(|k| k.allocated_bytes()).sum());
    }

    #[test]
    fn live_and_reclaimed_are_recomputed_exactly() {
        let mut heap = Heap::new();
        let mut metrics = Metrics::new(AllocMode::Summary);
        let kept = str_val(&mut heap, &mut metrics, "kept");
        str_val(&mut heap, &mut metrics, "garbage, not rooted");
        // Before any collection, an allocation is optimistically live.
        assert_eq!(metrics.current_live_objects, 2);

        heap.collect(std::iter::once(kept), &mut metrics, GcReason::Explicit);

        assert_eq!(metrics.current_live_objects, 1);
        assert_eq!(metrics.current_live_bytes, "kept".len() as u64 + size_of::<StrObj>() as u64);
        assert_eq!(metrics.by_kind[KIND_STR as usize].live_objects, 1);
        assert_eq!(metrics.by_kind[KIND_STR as usize].reclaimed_objects, 1);
        assert_eq!(metrics.gc_cycles.len(), 1);
        let cycle = &metrics.gc_cycles[0];
        assert_eq!(cycle.reason, GcReason::Explicit);
        assert_eq!(cycle.objects_before, 2);
        assert_eq!(cycle.objects_reclaimed, 1);
        assert_eq!(cycle.objects_after, 1);
        assert_eq!(metrics.gc_reclaimed_objects(), 1);
    }

    #[test]
    fn reachable_children_survive_through_their_container() {
        let mut heap = Heap::new();
        let mut metrics = Metrics::new(AllocMode::Summary);
        let a = str_val(&mut heap, &mut metrics, "a");
        let b = str_val(&mut heap, &mut metrics, "b");
        let list = list_val(&mut heap, &mut metrics, vec![a, b]);

        // Only the list is rooted; its elements must be kept reachable
        // through it, not freed as if unrooted.
        heap.collect(std::iter::once(list), &mut metrics, GcReason::Explicit);

        assert_eq!(metrics.current_live_objects, 3);
        assert_eq!(metrics.by_kind[KIND_STR as usize].reclaimed_objects, 0);
    }

    #[test]
    fn peak_live_can_exceed_final_live() {
        let mut heap = Heap::new();
        let mut metrics = Metrics::new(AllocMode::Summary);
        for i in 0..5 {
            str_val(&mut heap, &mut metrics, &format!("temp{i}"));
        }
        assert_eq!(metrics.peak_live_objects, 5);

        heap.collect(std::iter::empty(), &mut metrics, GcReason::Explicit);

        assert_eq!(metrics.current_live_objects, 0);
        assert_eq!(metrics.peak_live_objects, 5);
        assert!(metrics.peak_live_objects > metrics.current_live_objects);
    }

    #[test]
    fn off_mode_records_nothing() {
        let mut heap = Heap::new();
        let mut metrics = Metrics::new(AllocMode::Off);
        str_val(&mut heap, &mut metrics, "x");
        assert_eq!(metrics.total_allocations(), 0);
        heap.collect(std::iter::empty(), &mut metrics, GcReason::Explicit);
        assert_eq!(metrics.gc_cycles.len(), 0);
        assert_eq!(metrics.current_live_objects, 0);
    }

    #[test]
    fn reset_preserves_static_but_clears_run_counters() {
        let mut metrics = Metrics::new(AllocMode::Summary);
        metrics.record_static(KIND_STR, 40);
        metrics.record_alloc(KIND_STR, 40, 5, 0);
        assert_eq!(metrics.static_allocations(), 1);
        assert_eq!(metrics.total_allocations(), 1);

        metrics.reset();

        assert_eq!(metrics.static_allocations(), 1);
        assert_eq!(metrics.total_allocations(), 0);
        assert_eq!(metrics.current_live_objects, 0);
    }

    #[test]
    fn trigger_reason_reflects_stress_flag() {
        let mut heap = Heap::new();
        heap.stress = false;
        assert_eq!(heap.trigger_reason(), GcReason::Threshold);
        heap.stress = true;
        assert_eq!(heap.trigger_reason(), GcReason::Stress);
    }
}
