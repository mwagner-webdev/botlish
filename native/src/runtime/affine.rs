//! The drop of affine aggregates (AFFINE-VALUES.md).
//!
//! An affine value is released where its owner dies; the compiler decides
//! where (hir/affine.tcl). A coroutine handle is released by `corelease`
//! (`rt_co_release`, runtime/coroutine.rs); an aggregate that owns affine
//! values -- a struct with affine fields, a List of affine elements -- by
//! `affinedrop %v %d`, which releases every affine value %v owns by the
//! static drop descriptor %d of %v's type (hir::affine::Descriptor, a
//! String):
//!
//! | descriptor            | drops                                          |
//! |-----------------------|------------------------------------------------|
//! | `c`                   | a coroutine handle (`rt_co_release`)           |
//! | `l` D                 | every element of a List by D, first to last    |
//! | `v` D                 | every live element of a MutableVector by D, first to last, leaving it empty (runtime/mutvec.rs) |
//! | `a` D                 | every element of a MutableArray by D, first to last (ops.rs; MUTABLE-ARRAY.md) |
//! | `s` N `.` (SLOT `.` D)* | the struct fields at those slots by their D, in the descriptor's order |
//!
//! The descriptor is type-directed: only positions the static type says are
//! affine are visited -- never an unrestricted field, never a List of
//! unrestricted values. Like a coroutine release, a drop is unobservable (no
//! Botlish code runs, no value changes), idempotent, never fails and never
//! allocates: it is no GC safepoint.
//!
//! Resources (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md) add two
//! parts that run Botlish code -- exactly the program's own release code:
//!
//! | descriptor | drops                                                     |
//! |------------|-----------------------------------------------------------|
//! | `r` K `.`  | a resource: its cleanup function, entry K of the run's cleanup table (`Vm::cleanups`, installed by `cleanuptable`), called with the value |
//! | `C`        | a coroutine of an unwinding program: `rt_co_abandon`, which runs its suspended frames' releases (runtime/coroutine.rs) |
//!
//! A descriptor with either is dropped by `affinedroprun` (`rt_affine_drop_run`,
//! a GC safepoint that may fail with a cleanup's run-time fault), never by
//! `affinedrop`; the collection drop forms that take a descriptor are
//! safepoints for the same reason. While such a walk runs code, everything it
//! has yet to drop is rooted (`Vm::temp_roots`): a value taken out of its
//! aggregate is no longer reachable through it.

use super::coroutine::{rt_co_abandon, rt_co_release};
use super::value::*;
use super::vm::Vm;

/// Releases every affine value VALUE owns, by DESCRIPTOR (a String).
#[unsafe(no_mangle)]
pub extern "C" fn rt_affine_drop(p: *mut Vm, value: Value, descriptor: Value) -> Value {
    drop_descriptor(p, value, str_of(descriptor).as_str().as_bytes());
    UNIT
}

/// `affinedroprun %v %d`: the drop of VALUE by DESCRIPTOR when the
/// descriptor runs code (a cleanup, an abandonment). VALUE and the
/// descriptor's text are held across the walk; a run-time fault of the code
/// it runs is its failure (NO_VALUE, recorded), after which nothing more is
/// dropped.
#[unsafe(no_mangle)]
pub extern "C" fn rt_affine_drop_run(p: *mut Vm, value: Value, descriptor: Value) -> Value {
    let text = str_of(descriptor).as_str().as_bytes().to_vec();
    let rooted = vm(p).temp_roots.len();
    vm(p).temp_roots.push(value);
    let ok = drop_descriptor(p, value, &text);
    vm(p).temp_roots.truncate(rooted);
    if ok { UNIT } else { NO_VALUE }
}

/// `cleanuptable %f...`: the run's cleanup functions, entry K the K-th
/// operand (hir/resources.tcl's cleanup table), held for the rest of the run.
#[unsafe(no_mangle)]
pub extern "C" fn rt_cleanup_table(p: *mut Vm, n: u64, functions: *const Value) -> Value {
    let functions = unsafe { std::slice::from_raw_parts(functions, n as usize) };
    vm(p).cleanups = functions.to_vec();
    UNIT
}

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// Whether descriptor text D runs code: it has a resource or an unwinding
/// coroutine part.
pub fn runs_code(d: &[u8]) -> bool {
    d.iter().any(|&c| c == b'r' || c == b'C')
}

/// Releases every affine value VALUE owns, by descriptor text D; false when
/// code it ran failed (the failure recorded).
pub fn drop_descriptor(p: *mut Vm, value: Value, d: &[u8]) -> bool {
    let mut pos = 0;
    let ok = drop_at(p, value, d, &mut pos);
    debug_assert!(!ok || pos == d.len(), "affine drop descriptor not consumed");
    ok
}

/// The drop of VALUE by the descriptor at POS of D, advancing POS past it;
/// false when code it ran failed.
pub fn drop_at(p: *mut Vm, value: Value, d: &[u8], pos: &mut usize) -> bool {
    drop_by(p, value, d, pos)
}

/// Calls cleanup K of the run's cleanup table with resource VALUE; false
/// when it failed (a run-time fault: a cleanup declares no error).
fn cleanup(p: *mut Vm, k: usize, value: Value) -> bool {
    let Some(&f) = vm(p).cleanups.get(k) else {
        vm(p).fail(super::error::RtError::Bug(format!("no cleanup function {k} in this run's cleanup table")));
        return false;
    };
    call_cleanup(p, f, value)
}

/// `cleanupcall %f %v`: the release of resource VALUE by its cleanup
/// function F.
#[unsafe(no_mangle)]
pub extern "C" fn rt_cleanup_call(p: *mut Vm, f: Value, value: Value) -> Value {
    if call_cleanup(p, f, value) { UNIT } else { NO_VALUE }
}

fn call_cleanup(p: *mut Vm, f: Value, value: Value) -> bool {
    vm(p).metrics.record_resource_cleanup();
    preserving_pending(p, || super::ops::rt_call_value(p, f, 1, &value) != NO_VALUE)
}

/// Runs RUN -- release code: a cleanup, an abandoned coroutine's unwinding --
/// with the Vm's pending failure set aside and put back after it: a release
/// on an error edge runs while that error propagates (its pad then raises it
/// on, `reraise`), and the code it runs may fail and handle errors of its
/// own. The set-aside values stay rooted. False (and the code's own failure
/// pending instead) when RUN failed.
pub fn preserving_pending(p: *mut Vm, run: impl FnOnce() -> bool) -> bool {
    let (error, id, payload, shape, rooted) = {
        let vm = vm(p);
        let error = vm.error.take();
        let id = std::mem::replace(&mut vm.declared_error, 0);
        let payload = std::mem::take(&mut vm.declared_payload);
        let shape = vm.declared_payload_shape;
        let rooted = vm.temp_roots.len();
        if let Some(e) = &error {
            vm.temp_roots.extend(e.values());
        }
        vm.temp_roots.extend_from_slice(&payload);
        (error, id, payload, shape, rooted)
    };
    let ok = run();
    let vm = vm(p);
    vm.temp_roots.truncate(rooted);
    if ok {
        vm.error = error;
        vm.declared_error = id;
        vm.declared_payload = payload;
        vm.declared_payload_shape = shape;
    }
    ok
}

fn drop_by(p: *mut Vm, value: Value, d: &[u8], pos: &mut usize) -> bool {
    let c = d[*pos];
    *pos += 1;
    match c {
        b'c' => {
            rt_co_release(p, value);
            true
        }
        b'C' => rt_co_abandon(p, value) != NO_VALUE,
        b'r' => {
            let k = number(d, pos);
            cleanup(p, k, value)
        }
        b'l' => {
            let start = *pos;
            let items = list_of(value).items();
            if items.is_empty() {
                skip(d, pos);
            }
            for &item in items {
                *pos = start;
                if !drop_by(p, item, d, pos) {
                    return false;
                }
            }
            true
        }
        b's' => {
            let n = number(d, pos);
            let fields = struct_of(value).fields();
            for _ in 0..n {
                let slot = number(d, pos);
                if !drop_by(p, fields[slot], d, pos) {
                    return false;
                }
            }
            true
        }
        b'v' => super::mutvec::drop_elements(p, value, d, pos),
        b'a' => super::ops::drop_array_elements(p, value, d, pos),
        _ => panic!("bad affine drop descriptor {:?}", std::str::from_utf8(d)),
    }
}

/// Drops ITEMS -- the elements a collection drop took out of their
/// collection -- by the element descriptor at START of D, first to last;
/// leaves POS past it. When the descriptor runs code, every item is rooted
/// until the walk ends (a taken item is reachable through nothing else).
pub fn drop_taken(p: *mut Vm, items: &[Value], d: &[u8], start: usize, pos: &mut usize) -> bool {
    if items.is_empty() {
        *pos = start;
        skip(d, pos);
        return true;
    }
    let rooted = vm(p).temp_roots.len();
    let runs = runs_code(&d[start..]);
    if runs {
        vm(p).temp_roots.extend_from_slice(items);
    }
    let mut ok = true;
    for &item in items {
        *pos = start;
        if !drop_by(p, item, d, pos) {
            ok = false;
            break;
        }
    }
    if !ok {
        *pos = start;
        skip(d, pos);
    }
    if runs {
        vm(p).temp_roots.truncate(rooted);
    }
    ok
}

/// Moves POS past the descriptor at POS without dropping anything.
pub fn skip(d: &[u8], pos: &mut usize) {
    let c = d[*pos];
    *pos += 1;
    match c {
        b'c' | b'C' => {}
        b'r' => {
            number(d, pos);
        }
        b'l' | b'v' | b'a' => skip(d, pos),
        b's' => {
            let n = number(d, pos);
            for _ in 0..n {
                number(d, pos);
                skip(d, pos);
            }
        }
        _ => panic!("bad affine drop descriptor {:?}", std::str::from_utf8(d)),
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

#[cfg(test)]
mod tests {
    use super::*;

    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
    mod drops {
        use super::super::*;
        use crate::runtime::coroutine::{coroutine_of, rt_co_create, CO_FRESH, CO_RELEASED};
        use crate::runtime::metrics::AllocMode;
        use crate::runtime::ops::GenericEntry;
        use crate::runtime::vm::ProgramInfo;

        fn new_vm() -> Box<Vm> {
            Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new(), errors: Vec::new() }), AllocMode::Summary)
        }

        extern "C" fn body(_p: *mut Vm, _closure: Value, _args: *const Value) -> Value {
            make_small(0)
        }

        /// A fresh (never started) coroutine: its release records one
        /// release and needs no stack.
        fn coroutine(vm: &mut Vm) -> Value {
            let caps: Box<[Value]> = Vec::new().into_boxed_slice();
            let code: GenericEntry = body;
            let t = vm.alloc(
                ClosureObj {
                    hdr: Header::new(KIND_CLOSURE, false),
                    func: 0,
                    arity: 0,
                    code: code as *const () as usize,
                    ncaps: 0,
                    caps: Box::into_raw(caps) as *mut Value,
                },
                0,
            );
            vm.temp_roots.push(t);
            let co = rt_co_create(vm, t);
            vm.temp_roots.push(co);
            co
        }

        fn drop_by(vm: &mut Vm, value: Value, descriptor: &str) {
            let d = vm.new_str(descriptor);
            vm.temp_roots.push(d);
            assert_eq!(rt_affine_drop(vm, value, d), UNIT);
        }

        fn state(v: Value) -> u8 {
            coroutine_of(v).state
        }

        #[test]
        fn a_list_drop_releases_every_element_once() {
            let mut vm = new_vm();
            let cs: Vec<Value> = (0..3).map(|_| coroutine(&mut vm)).collect();
            let list = vm.new_list(cs.clone());
            vm.temp_roots.push(list);
            drop_by(&mut vm, list, "lc");
            assert!(cs.iter().all(|&c| state(c) == CO_RELEASED));
            assert_eq!(vm.metrics.coroutines.released, 3);
            // Idempotent: a second drop releases nothing more.
            drop_by(&mut vm, list, "lc");
            assert_eq!(vm.metrics.coroutines.released, 3);
        }

        #[test]
        fn a_struct_drop_releases_only_the_slots_its_descriptor_names() {
            let mut vm = new_vm();
            let a = coroutine(&mut vm);
            let b = coroutine(&mut vm);
            let kept = coroutine(&mut vm);
            // Slots 0 and 2 are affine; slot 1 is an unrestricted Int, slot 3
            // a coroutine the descriptor excludes (moved out by a
            // destructuring).
            let s = vm.new_struct(0, vec![a, make_small(5), b, kept]);
            vm.temp_roots.push(s);
            drop_by(&mut vm, s, "s2.2.c0.c");
            assert_eq!((state(a), state(b), state(kept)), (CO_RELEASED, CO_RELEASED, CO_FRESH));
            assert_eq!(vm.metrics.coroutines.released, 2);
        }

        #[test]
        fn nested_aggregates_and_an_empty_list() {
            let mut vm = new_vm();
            let a = coroutine(&mut vm);
            let b = coroutine(&mut vm);
            let p = vm.new_struct(0, vec![make_small(1), a]);
            vm.temp_roots.push(p);
            let q = vm.new_struct(0, vec![make_small(2), b]);
            vm.temp_roots.push(q);
            let empty = vm.new_list(Vec::new());
            vm.temp_roots.push(empty);
            let list = vm.new_list(vec![p, q]);
            vm.temp_roots.push(list);
            let outer = vm.new_struct(0, vec![empty, list]);
            vm.temp_roots.push(outer);
            drop_by(&mut vm, outer, "s2.1.ls1.1.c0.lc");
            assert_eq!((state(a), state(b)), (CO_RELEASED, CO_RELEASED));
            assert_eq!(vm.metrics.coroutines.released, 2);
        }

        /// An affine MutableArray a consuming loop left early: its drop
        /// releases the elements not taken yet, never the one the loop
        /// took, and leaves the array with none (a second drop releases
        /// nothing more).
        #[test]
        fn a_mutarray_drop_releases_the_elements_left_once() {
            use crate::runtime::ops::{rt_mutarray_empty, rt_mutarray_from_list, rt_mutarray_take_front};
            let mut vm = new_vm();
            let cs: Vec<Value> = (0..3).map(|_| coroutine(&mut vm)).collect();
            let list = vm.new_list(cs.clone());
            vm.temp_roots.push(list);
            let array = rt_mutarray_from_list(&mut *vm, list);
            vm.temp_roots.push(array);
            assert_eq!(rt_mutarray_take_front(&mut *vm, array), cs[0]);
            drop_by(&mut vm, array, "ac");
            assert_eq!((state(cs[0]), state(cs[1]), state(cs[2])), (CO_FRESH, CO_RELEASED, CO_RELEASED));
            assert_eq!(rt_mutarray_empty(&mut *vm, array), TRUE);
            drop_by(&mut vm, array, "ac");
            assert_eq!(vm.metrics.coroutines.released, 2);
        }
    }

    #[test]
    fn descriptors_parse_and_skip() {
        let d = b"s2.2.ls1.0.c0.c";
        let mut pos = 0;
        skip(d, &mut pos);
        assert_eq!(pos, d.len());
        let mut pos = 0;
        assert_eq!(d[pos], b's');
        pos += 1;
        assert_eq!(number(d, &mut pos), 2);
        assert_eq!(number(d, &mut pos), 2);
    }
}
