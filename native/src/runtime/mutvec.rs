//! MutableVector[T] (MUTABLE-VECTOR.md): a growable mutable VALUE.
//!
//! Mutable storage does not imply reference semantics. A vector is two
//! layers, exactly as on the Tcl backends (core/mutvec.tcl):
//!
//!   * the *header* (`MutVecObj`, KIND_MUTVEC): the identity of ONE logical
//!     vector value. Every mutation (push, pop, take, swap, clear) changes
//!     the header it is applied to, in place, so a mutation never stores a
//!     new value back into its receiver: the receiver place keeps its header
//!     register (or struct field, or context slot) unchanged.
//!   * the *backing* (`Rc<VecDeque<Value>>`): the elements, shared between
//!     headers copy-on-write. A logical copy (`mvshare`, which the compiler
//!     inserts wherever a vector-bearing value is copied out of or into a
//!     place: hir/mutvec.tcl) is a new header on the same backing -- O(1),
//!     no element is copied. A mutation through a header whose backing is
//!     shared first *detaches* it (`Rc::make_mut`: one shallow copy of the
//!     element words); one whose backing is unique mutates in place (an
//!     amortized O(1) push). The `Rc` count is the copy-on-write sharing
//!     count of the backing -- an implementation detail, never a source
//!     ownership count: a header the collector frees gives its share back,
//!     a dead header the collector has not seen yet only makes a later
//!     write copy once more.
//!
//! The compiler guarantees a header is mutated only through the one place
//! that owns it (every logical copy is a new header), so no alias of a header
//! ever observes a mutation.
//!
//! Affine elements (a vector of coroutine handles, of structs owning one) make
//! the vector affine: it is never shared (a copy is a move), so its backing
//! is always unique -- a shared backing under an affine operation
//! (`mvcleardrop`, `mvswapdrop`, a `v` drop) is an invariant violation and
//! panics rather than copying affine elements. Their ownership is entirely
//! static: the runtime stores elements and performs the transfers and drops
//! the compiler asked for (no owner, no moved flag, no affine flag).
//!
//! Exactly the live elements `[0, len)` are owned and traced: a `VecDeque`
//! holds no slot beyond its length that `iter()` visits (removed slots and
//! spare capacity are not elements), and growth or compaction moves element
//! words inside Rust code that never reaches a safepoint (no Botlish
//! allocation, so no collection, can happen while an element is between its
//! old and its new slot). At every safepoint each live element has exactly
//! one storage location in its vector.
//!
//! Drop order (clear, whole-vector drop, a consuming loop's remaining
//! suffix): lowest index first.

use super::affine::drop_descriptor;
use super::ops::fail_index_not_found;
use super::value::*;
use super::vm::Vm;
use std::collections::VecDeque;
use std::rc::Rc;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

#[repr(C)]
pub struct MutVecObj {
    pub hdr: Header,
    pub backing: Rc<VecDeque<Value>>,
}

pub fn mutvec_of<'a>(v: Value) -> &'a MutVecObj {
    debug_assert_eq!(heap_kind(v), KIND_MUTVEC);
    unsafe { as_ref(v) }
}

#[allow(clippy::mut_from_ref)]
fn mutvec_of_mut<'a>(v: Value) -> &'a mut MutVecObj {
    debug_assert_eq!(heap_kind(v), KIND_MUTVEC);
    unsafe { &mut *(v as *mut MutVecObj) }
}

/// The live elements of vector V, first to last (the collector's trace).
pub fn elements(v: Value) -> impl Iterator<Item = Value> {
    mutvec_of(v).backing.iter().copied()
}

/// Approximate bytes vector V owns (heap.rs's object_size): its header and
/// its share of the backing.
pub fn object_size(v: Value) -> usize {
    let obj = mutvec_of(v);
    std::mem::size_of::<MutVecObj>() + obj.backing.capacity() * 8 / Rc::strong_count(&obj.backing)
}

/// A new header on BACKING (allocates; may collect first).
fn new_header(p: *mut Vm, backing: Rc<VecDeque<Value>>) -> Value {
    let bytes = backing.capacity() * 8;
    vm(p).alloc(MutVecObj { hdr: Header::new(KIND_MUTVEC, false), backing }, bytes)
}

/// The elements of V, unique to its header: a shared backing is detached
/// first (one shallow copy, counted), a unique one is returned as it is.
fn writable<'a>(p: *mut Vm, v: Value) -> &'a mut VecDeque<Value> {
    let obj = mutvec_of_mut(v);
    if Rc::strong_count(&obj.backing) > 1 {
        let n = obj.backing.len();
        let vm = vm(p);
        vm.metrics.record_mutvec_detach(n);
        vm.heap.note_growth(n * 8);
    }
    Rc::make_mut(&mut obj.backing)
}

/// The elements of affine vector V: its backing is never shared (an affine
/// vector is moved, never copied), so this never copies an element.
fn owned<'a>(v: Value, what: &str) -> &'a mut VecDeque<Value> {
    let obj = mutvec_of_mut(v);
    match Rc::get_mut(&mut obj.backing) {
        Some(items) => items,
        None => panic!("{what}: an affine MutableVector's backing is shared (an ownership invariant violation)"),
    }
}

/// Appends X to the unique elements ITEMS of a vector, counting a capacity
/// change (growth relocates element words inside this call: no safepoint).
fn push_counted(p: *mut Vm, items: &mut VecDeque<Value>, x: Value) {
    let before = items.capacity();
    items.push_back(x);
    let after = items.capacity();
    if after != before {
        let vm = vm(p);
        vm.metrics.record_mutvec_growth((after - before) * 8);
        vm.heap.note_growth((after - before) * 8);
    }
}

/// `mutable_vector::from_list(xs)`: a fresh vector of the List's elements.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_from_list(p: *mut Vm, list: Value) -> Value {
    let items: VecDeque<Value> = list_of(list).items().iter().copied().collect();
    new_header(p, Rc::new(items))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_len(_p: *mut Vm, v: Value) -> Value {
    make_small(mutvec_of(v).backing.len() as i64)
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_empty(_p: *mut Vm, v: Value) -> Value {
    bool_value(mutvec_of(v).backing.is_empty())
}

/// The index Int I of a vector of N elements, if it designates one.
fn index_of(i: Value, n: usize) -> Option<usize> {
    if !is_small(i) {
        return None;
    }
    let i = small_of(i);
    (i >= 0 && (i as usize) < n).then_some(i as usize)
}

/// `mutable_vector::at(v, i)`: the element (an unrestricted value: the
/// compiler rejects `at` of affine elements), never detaching.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_at(p: *mut Vm, v: Value, i: Value) -> Value {
    let items = &mutvec_of(v).backing;
    match index_of(i, items.len()) {
        Some(i) => items[i],
        None => fail_index_not_found(p),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_push(p: *mut Vm, v: Value, x: Value) -> Value {
    let items = writable(p, v);
    push_counted(p, items, x);
    UNIT
}

/// `mutable_vector::pop(v)`: the last element, moved out; IndexNotFound (and
/// nothing changes) when empty.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_pop(p: *mut Vm, v: Value) -> Value {
    if mutvec_of(v).backing.is_empty() {
        return fail_index_not_found(p);
    }
    writable(p, v).pop_back().expect("a non-empty vector")
}

/// `mutable_vector::take(v, i)`: element I, moved out; the later elements keep
/// their order (a front removal is O(1)).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_take(p: *mut Vm, v: Value, i: Value) -> Value {
    match index_of(i, mutvec_of(v).backing.len()) {
        Some(i) => writable(p, v).remove(i).expect("an element"),
        None => fail_index_not_found(p),
    }
}

/// `mutable_vector::swap(v, i, x)`: X installed at I, the old element moved
/// out; IndexNotFound and nothing changes when I is no element.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_swap(p: *mut Vm, v: Value, i: Value, x: Value) -> Value {
    match index_of(i, mutvec_of(v).backing.len()) {
        Some(i) => std::mem::replace(&mut writable(p, v)[i], x),
        None => fail_index_not_found(p),
    }
}

/// `mutable_vector::clear(v)` of unrestricted elements: a shared backing is
/// not copied, just left to its other headers.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_clear(_p: *mut Vm, v: Value) -> Value {
    let obj = mutvec_of_mut(v);
    match Rc::get_mut(&mut obj.backing) {
        Some(items) => items.clear(),
        None => obj.backing = Rc::new(VecDeque::new()),
    }
    UNIT
}

/// `mutable_vector#clear_drop(v, d)`: clear of affine elements, each dropped
/// by descriptor D, first to last. The elements leave the vector before any
/// is dropped, so each is dropped exactly once.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_clear_drop(p: *mut Vm, v: Value, d: Value) -> Value {
    let items = std::mem::take(owned(v, "mutable_vector#clear_drop"));
    let text = str_of(d).as_str().as_bytes();
    for item in items {
        drop_descriptor(p, item, text);
    }
    UNIT
}

/// `mutable_vector#swap_drop(v, i, x, d)`: swap of affine elements. When I is no
/// element the replacement X -- already owned by this operation -- is dropped
/// by D before IndexNotFound; the vector is unchanged.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_swap_drop(p: *mut Vm, v: Value, i: Value, x: Value, d: Value) -> Value {
    match index_of(i, mutvec_of(v).backing.len()) {
        Some(i) => std::mem::replace(&mut owned(v, "mutable_vector#swap_drop")[i], x),
        None => {
            drop_descriptor(p, x, str_of(d).as_str().as_bytes());
            fail_index_not_found(p)
        }
    }
}

/// `mutable_vector#take_front(v)`: the first element of a non-empty vector,
/// moved out (a consuming loop's step, O(1)).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_take_front(p: *mut Vm, v: Value) -> Value {
    writable(p, v).pop_front().expect("mutable_vector#take_front: an empty vector")
}

/// `mutable_vector#to_list(v)`: an immutable List snapshot of the elements
/// (the domain a loop over an unrestricted vector iterates).
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_to_list(p: *mut Vm, v: Value) -> Value {
    let items: Vec<Value> = elements(v).collect();
    vm(p).new_list(items)
}

/// `mutable_vector#share(value, d)`: a logical copy of the vector-bearing VALUE
/// by share descriptor D (hir::mutvec::ShareDescriptor): `h` a vector (a new
/// header on the same backing), `s`N`.`(SLOT`.`D)* a struct whose listed
/// slots are shared (a new struct). Allocates.
#[unsafe(no_mangle)]
pub extern "C" fn rt_mv_share(p: *mut Vm, value: Value, d: Value) -> Value {
    let text = str_of(d).as_str().as_bytes().to_vec();
    let mut pos = 0;
    let rooted = vm(p).temp_roots.len();
    let result = share_by(p, value, &text, &mut pos);
    vm(p).temp_roots.truncate(rooted);
    debug_assert_eq!(pos, text.len(), "share descriptor not consumed");
    result
}

fn share_by(p: *mut Vm, value: Value, d: &[u8], pos: &mut usize) -> Value {
    let c = d[*pos];
    *pos += 1;
    match c {
        b'h' => {
            let backing = Rc::clone(&mutvec_of(value).backing);
            vm(p).metrics.record_mutvec_share();
            new_header(p, backing)
        }
        b's' => {
            let n = number(d, pos);
            // The copies are rooted while the next ones (and the struct) are
            // allocated; VALUE itself is the caller's operand (rooted).
            let mut copies = Vec::with_capacity(n);
            for _ in 0..n {
                let slot = number(d, pos);
                let field = struct_of(value).fields()[slot];
                let copy = share_by(p, field, d, pos);
                vm(p).temp_roots.push(copy);
                copies.push((slot, copy));
            }
            let mut fields = struct_of(value).fields().to_vec();
            for (slot, copy) in copies {
                fields[slot] = copy;
            }
            let shape = struct_of(value).shape;
            vm(p).new_struct(shape, fields)
        }
        _ => panic!("bad share descriptor {:?}", std::str::from_utf8(d)),
    }
}

/// The decimal number at POS, terminated by ".".
fn number(d: &[u8], pos: &mut usize) -> usize {
    let mut n = 0usize;
    while d[*pos] != b'.' {
        n = n * 10 + (d[*pos] - b'0') as usize;
        *pos += 1;
    }
    *pos += 1;
    n
}

/// The `v` drop of affine.rs: every live element of vector V by the element
/// descriptor at POS of D, first to last, leaving V empty. Returns with POS
/// past the element descriptor.
pub fn drop_elements(p: *mut Vm, v: Value, d: &[u8], pos: &mut usize) {
    let start = *pos;
    let items = std::mem::take(owned(v, "affine#drop"));
    if items.is_empty() {
        super::affine::skip(d, pos);
    }
    for item in items {
        *pos = start;
        super::affine::drop_at(p, item, d, pos);
    }
}
