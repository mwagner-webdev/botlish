//! Resumable coroutines (WASM-RESUMABLE-COROUTINES-SHADOW-ROOTS-MILESTONE-1.md):
//! the general coroutine mechanism of a runtime that switches no stacks --
//! the fallback root plan natively, and WebAssembly next.
//!
//! codegen::resumable rewrites every function that may yield into a state
//! machine over a heap *frame* (`FrameObj`): a suspension saves exactly the
//! registers live after it into the activation's frame and *returns* the
//! frame, through every activation of the yielding call chain, to the
//! coroutine's segment (`segment`); a resume calls the chain again from its
//! outermost frame, each function dispatching on its frame's resume point and
//! handing the frame of its suspended callee down to the same call. No
//! activation outlives a suspension, so the running code keeps one LIFO
//! shadow stack (codegen::roots's ShadowOnly mode) and a suspended coroutine
//! is nothing but its chain of frames, reachable from its handle.
//!
//! # The hand-off ABI
//!
//! * **Down**: a resumable function's last parameter is its hidden frame
//!   parameter: UNIT for a fresh activation, else the frame it continues
//!   (a resume) or reuses (its own self tail call). The coroutine's segment
//!   passes the outermost frame to the thunk's generic entry the same way,
//!   as its one argument.
//! * **Up**: a suspended activation returns its frame as its (first) result.
//!   A frame is never a program value, so `frisframe` (a pointer whose kind
//!   is KIND_FRAME) tells a suspension from every result, an error (0) and
//!   every multi-result convention.
//!
//! There is no hand-off slot in the Vm: a frame is always held by exactly
//! one owner -- the register of the activation running with it, the callee
//! field of its caller's frame, the coroutine object (the outermost), or a
//! call's argument or result in flight -- and taking it from a field clears
//! the field (`frcallee`, `segment`). Nothing is left behind on an error, an
//! abandonment or a completion: a failing activation's frame is simply
//! unreachable.
//!
//! # The frame
//!
//! One allocation: the fields of `FrameObj`, then `cap_tagged` tagged slots,
//! then `cap_raw` raw slots (every unboxed register kind: raw Ints, short and
//! packed-ASCII Strings, C words). The collector traces `callee` and the
//! first `ntagged` tagged slots -- the registers live across the current
//! suspension point, which `frsave` stores from slot 0 -- and never a raw
//! slot. `frrestore` marks the frame running (point 0, nothing traced): a
//! running activation's values are rooted in its shadow-stack frame, so its
//! own frame retains nothing.
use super::coroutine::{CoroutineObj, CO_COMPLETED, CO_FAILED, CO_RUNNING, CO_SUSPENDED};
use super::error::RtError;
use super::ops::GenericEntry;
use super::value::*;
use super::vm::Vm;
use std::mem::{offset_of, size_of};

/// Whether coroutines run as resumable state machines here: wherever no
/// stack switch exists (runtime::coroutine's STACK_SWITCHING). The two are
/// the general mechanisms; exactly one of them runs coroutines on any build.
pub const RESUMABLE: bool = !super::coroutine::STACK_SWITCHING;

/// One suspended activation of a resumable function (KIND_FRAME), followed in
/// the same allocation by its slots.
#[repr(C)]
pub struct FrameObj {
    pub hdr: Header,
    /// The resume point the activation suspended at (1-based); 0 while it
    /// runs or before it first suspends.
    pub point: u32,
    /// How many tagged slots, from slot 0, the collector traces: the tagged
    /// registers live across the suspension at `point`; 0 while running.
    pub ntagged: u32,
    /// The suspended callee's frame (a suspension at a call), else UNIT.
    pub callee: Value,
    /// The frame's shape: its function's (`nir::FrameShape`).
    pub cap_tagged: u32,
    pub cap_raw: u32,
}

/// Offsets generated code reads and writes (codegen::clif's frame
/// operations): the one place the frame's layout is stated.
pub const FRAME_POINT_OFFSET: i32 = offset_of!(FrameObj, point) as i32;
pub const FRAME_NTAGGED_OFFSET: i32 = offset_of!(FrameObj, ntagged) as i32;
pub const FRAME_CALLEE_OFFSET: i32 = offset_of!(FrameObj, callee) as i32;
/// Where tagged slot 0 is; raw slot J is at `FRAME_SLOTS_OFFSET + 8 *
/// (cap_tagged + J)`.
pub const FRAME_SLOTS_OFFSET: i32 = size_of::<FrameObj>() as i32;

const _: () = assert!(FRAME_SLOTS_OFFSET % 8 == 0 && offset_of!(FrameObj, hdr) == 0);

/// The frame of V, which must be one.
pub fn frame_of<'a>(v: Value) -> &'a mut FrameObj {
    debug_assert_eq!(heap_kind(v), KIND_FRAME);
    unsafe { &mut *(v as *mut FrameObj) }
}

/// Whether V is a frame object: a suspension result or a hidden frame
/// argument (never a program value).
#[inline]
pub fn is_frame(v: Value) -> bool {
    heap_kind(v) == KIND_FRAME
}

impl FrameObj {
    fn layout(cap_tagged: u32, cap_raw: u32) -> std::alloc::Layout {
        let bytes = size_of::<FrameObj>() + 8 * (cap_tagged as usize + cap_raw as usize);
        std::alloc::Layout::from_size_align(bytes, 8).expect("a frame's layout")
    }

    /// The slots: `cap_tagged` tagged ones, then `cap_raw` raw ones.
    fn slots(&self) -> &[u64] {
        // SAFETY: the allocation has room for every slot (`layout`).
        unsafe {
            let base = (self as *const FrameObj as *const u8).add(FRAME_SLOTS_OFFSET as usize) as *const u64;
            std::slice::from_raw_parts(base, self.cap_tagged as usize + self.cap_raw as usize)
        }
    }

    /// What the collector traces: the suspended callee, and the tagged slots
    /// the current suspension stored. Never a raw slot.
    pub fn traced(&self) -> impl Iterator<Item = Value> + '_ {
        let n = (self.ntagged as usize).min(self.cap_tagged as usize);
        std::iter::once(self.callee).chain(self.slots()[..n].iter().copied())
    }

    /// The object's size, for the collector's accounting.
    pub fn object_size(&self) -> usize {
        Self::layout(self.cap_tagged, self.cap_raw).size()
    }
}

/// Frees FRAME (the collector's sweep): no slot owns a Rust value.
///
/// # Safety
/// FRAME is an unreachable frame object this module allocated.
pub unsafe fn free_frame(frame: *mut Header) {
    unsafe {
        let f = &*(frame as *const FrameObj);
        let layout = FrameObj::layout(f.cap_tagged, f.cap_raw);
        std::alloc::dealloc(frame as *mut u8, layout);
    }
}

/// `frensure`'s allocation: a new frame of CAP_TAGGED tagged and CAP_RAW raw
/// slots, not suspended (point 0, nothing traced, no callee). Its slots are
/// zeroed, so no slot ever holds a stale word, even one nothing reads.
#[unsafe(no_mangle)]
pub extern "C" fn rt_frame_new(p: *mut Vm, cap_tagged: u64, cap_raw: u64) -> Value {
    let vm = unsafe { &mut *p };
    if vm.heap.wants_collection() {
        vm.collect();
    }
    let (cap_tagged, cap_raw) = (cap_tagged as u32, cap_raw as u32);
    let layout = FrameObj::layout(cap_tagged, cap_raw);
    // SAFETY: a non-zero-sized layout (the fields alone are 32 bytes).
    let raw = unsafe { std::alloc::alloc_zeroed(layout) } as *mut FrameObj;
    if raw.is_null() {
        std::alloc::handle_alloc_error(layout);
    }
    // SAFETY: a fresh allocation of the fields and every slot.
    unsafe {
        raw.write(FrameObj { hdr: Header::new(KIND_FRAME, false), point: 0, ntagged: 0, callee: UNIT, cap_tagged, cap_raw });
    }
    let header_bytes = size_of::<FrameObj>();
    let slot_bytes = layout.size() - header_bytes;
    vm.heap.register(raw as *mut Header, layout.size());
    if vm.metrics.enabled() {
        let site = vm.alloc_site;
        vm.alloc_site = 0;
        vm.metrics.record_alloc(KIND_FRAME, header_bytes, slot_bytes, site);
    }
    raw as Value
}

/// `cosuspend %v`: a yield's outward value, kept in the running coroutine
/// while its activations return their frames to the segment.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_suspend(p: *mut Vm, value: Value) -> Value {
    let vm = unsafe { &mut *p };
    let co = vm.co_current;
    if co.is_null() {
        return vm.fail(RtError::Semantic {
            kind: "YIELD-OUTSIDE-COROUTINE",
            message: "yield outside a coroutine: no coroutine is running here".to_string(),
        });
    }
    // SAFETY: the running coroutine is rooted through Vm::co_current.
    unsafe { (*co).value = value };
    UNIT
}

/// `comsg`: a resumed yield's value, the resume message -- or, when the
/// coroutine is being abandoned (runtime::coroutine's `rt_co_abandon` put
/// NO_VALUE there with the abandonment pending), a failure with it.
#[unsafe(no_mangle)]
pub extern "C" fn rt_co_msg(p: *mut Vm) -> Value {
    let vm = unsafe { &mut *p };
    let co = vm.co_current;
    if co.is_null() {
        return vm.fail(RtError::Bug("a resumed yield outside a coroutine".to_string()));
    }
    // SAFETY: as in rt_co_suspend.
    let message = unsafe { (*co).value };
    if message == NO_VALUE && vm.error.is_none() {
        return vm.fail(RtError::Bug("a resumed yield has no message and no pending abandonment".to_string()));
    }
    message
}

/// Runs one segment of resumable coroutine CO: its start (no frame yet) or a
/// resume (its outermost frame, taken from the object). The thunk's
/// activation either returns its value (the body ended), fails, or returns
/// its frame (it suspended); every activation of the chain has returned
/// either way, so the shadow stack is exactly where it was (invariant I1,
/// checked) and the suspended state is the frame chain alone, which the
/// coroutine keeps.
///
/// # Safety
/// CO is a live coroutine object about to run (FRESH or SUSPENDED), its
/// transport slot already holding the message; it is rooted through the
/// running chain (Vm::co_current) for as long as the segment runs.
pub unsafe fn segment(p: *mut Vm, co: *mut CoroutineObj) -> Value {
    unsafe {
        let frame = std::mem::replace(&mut (*co).frame, UNIT);
        (*co).resumer = (*p).co_current;
        (*p).co_current = co;
        (*co).state = CO_RUNNING;
        let entry_top = (*p).ss_top;
        let thunk = (*co).thunk;
        let result = if heap_kind(thunk) == KIND_CLOSURE {
            let c = closure_of(thunk);
            let entry: GenericEntry = std::mem::transmute(c.code);
            // The thunk's one parameter: its hidden frame parameter.
            let args = [frame];
            entry(p, thunk, args.as_ptr())
        } else {
            (*p).fail(RtError::Bug("a coroutine's body is not a Block".to_string()))
        };
        (*p).co_current = (*co).resumer;
        (*co).resumer = std::ptr::null_mut();
        if (*p).ss_top != entry_top {
            // I1: a segment, suspended or ended, pops every shadow-stack
            // frame it pushed. A violation is a code generation bug: no
            // root the segment's activations published may stay behind.
            (*p).ss_top = entry_top;
            (*co).state = CO_FAILED;
            (*co).thunk = UNIT;
            return (*p).fail(RtError::Bug("a resumable coroutine segment did not restore the shadow stack (invariant I1)".to_string()));
        }
        if is_frame(result) {
            (*co).frame = result;
            (*co).state = CO_SUSPENDED;
            return (*co).value;
        }
        (*co).thunk = UNIT;
        if result == NO_VALUE {
            let error = (*p).error.take().unwrap_or_else(|| RtError::Bug("a coroutine body failed without recording an error".to_string()));
            let id = (*p).declared_error;
            (*p).declared_error = 0;
            let payload = std::mem::take(&mut (*p).declared_payload);
            let shape = (*p).declared_payload_shape;
            (*co).failure = Some(Box::new((error, id, payload, shape)));
            (*co).state = CO_FAILED;
            super::coroutine::reraise(p, co)
        } else {
            (*co).value = result;
            (*co).state = CO_COMPLETED;
            result
        }
    }
}

/// The length of the frame chain FRAME starts (0 for UNIT): the depth of a
/// suspended coroutine's yielding call chain.
pub fn chain_length(mut frame: Value) -> usize {
    let mut n = 0;
    while is_frame(frame) {
        n += 1;
        frame = frame_of(frame).callee;
    }
    n
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    fn vm() -> Box<Vm> {
        Vm::new(std::sync::Arc::new(ProgramInfo::empty()), AllocMode::Summary)
    }

    fn slots_mut(frame: Value) -> &'static mut [u64] {
        let f = frame_of(frame);
        let n = f.cap_tagged as usize + f.cap_raw as usize;
        unsafe { std::slice::from_raw_parts_mut((frame as *mut u8).add(FRAME_SLOTS_OFFSET as usize) as *mut u64, n) }
    }

    /// The layout generated code relies on: fields at fixed offsets, slots
    /// after them, a frame's size its fields and its slots.
    #[test]
    fn the_layout_is_the_one_codegen_writes() {
        assert_eq!((FRAME_POINT_OFFSET, FRAME_NTAGGED_OFFSET, FRAME_CALLEE_OFFSET, FRAME_SLOTS_OFFSET), (8, 12, 16, 32));
        let mut vm = vm();
        let f = rt_frame_new(&mut *vm, 3, 2);
        assert!(is_frame(f) && is_pointer(f));
        let frame = frame_of(f);
        assert_eq!((frame.point, frame.ntagged, frame.callee, frame.cap_tagged, frame.cap_raw), (0, 0, UNIT, 3, 2));
        assert_eq!(frame.object_size(), 32 + 5 * 8);
        assert!(slots_mut(f).iter().all(|w| *w == 0), "a new frame's slots are zero");
        assert!(!is_frame(UNIT) && !is_frame(NO_VALUE) && !is_frame(15));
    }

    /// I3 and I6: the collector keeps exactly the tagged slots of the current
    /// suspension point and the callee frame; raw slots holding words that
    /// look like heap pointers are never traced.
    #[test]
    fn a_frame_traces_its_live_tagged_slots_and_callee_only() {
        let mut vm = vm();
        let callee = rt_frame_new(&mut *vm, 0, 0);
        vm.temp_roots.push(callee);
        let f = rt_frame_new(&mut *vm, 3, 1);
        vm.temp_roots.push(f);
        let kept = vm.new_str("kept");
        vm.temp_roots.push(kept);
        let dead = vm.new_str("dead past ntagged");
        vm.temp_roots.push(dead);
        let raw_target = vm.new_str("only a raw slot names me");
        vm.temp_roots.push(raw_target);
        {
            let slots = slots_mut(f);
            slots[0] = kept;
            slots[1] = dead;
            slots[3] = raw_target; // the raw slot
        }
        let frame = frame_of(f);
        frame.point = 2;
        frame.ntagged = 1;
        frame.callee = callee;
        // Only the frame itself stays a root.
        vm.temp_roots.clear();
        vm.temp_roots.push(f);
        vm.collect_for_test(crate::runtime::metrics::GcReason::Explicit);
        let live: Vec<Value> = vm.heap.objects_for_test().iter().map(|o| *o as Value).collect();
        assert!(live.contains(&f) && live.contains(&callee) && live.contains(&kept));
        assert!(!live.contains(&dead), "a slot past ntagged is not traced (I4)");
        assert!(!live.contains(&raw_target), "a raw slot is never traced (I6)");
        assert_eq!(chain_length(f), 2);
    }
}
