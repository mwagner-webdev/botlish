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
//! | `s` N `.` (SLOT `.` D)* | the struct fields at those slots by their D, in the descriptor's order |
//!
//! The descriptor is type-directed: only positions the static type says are
//! affine are visited -- never an unrestricted field, never a List of
//! unrestricted values. Like a coroutine release, a drop is unobservable (no
//! Botlish code runs, no value changes), idempotent, never fails and never
//! allocates: it is no GC safepoint.

use super::coroutine::rt_co_release;
use super::value::*;
use super::vm::Vm;

/// Releases every affine value VALUE owns, by DESCRIPTOR (a String).
#[unsafe(no_mangle)]
pub extern "C" fn rt_affine_drop(p: *mut Vm, value: Value, descriptor: Value) -> Value {
    let text = str_of(descriptor).as_str().as_bytes();
    let mut pos = 0;
    drop_by(p, value, text, &mut pos);
    debug_assert_eq!(pos, text.len(), "affine drop descriptor not consumed");
    UNIT
}

fn drop_by(p: *mut Vm, value: Value, d: &[u8], pos: &mut usize) {
    let c = d[*pos];
    *pos += 1;
    match c {
        b'c' => {
            rt_co_release(p, value);
        }
        b'l' => {
            let start = *pos;
            let items = list_of(value).items();
            if items.is_empty() {
                skip(d, pos);
            }
            for &item in items {
                *pos = start;
                drop_by(p, item, d, pos);
            }
        }
        b's' => {
            let n = number(d, pos);
            let fields = struct_of(value).fields();
            for _ in 0..n {
                let slot = number(d, pos);
                drop_by(p, fields[slot], d, pos);
            }
        }
        _ => panic!("bad affine drop descriptor {:?}", std::str::from_utf8(d)),
    }
}

/// Moves POS past the descriptor at POS without dropping anything.
fn skip(d: &[u8], pos: &mut usize) {
    let c = d[*pos];
    *pos += 1;
    match c {
        b'c' => {}
        b'l' => skip(d, pos),
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

    #[cfg(all(target_arch = "x86_64", target_os = "linux"))]
    mod drops {
        use super::super::*;
        use crate::runtime::coroutine::{coroutine_of, rt_co_create, CO_FRESH, CO_RELEASED};
        use crate::runtime::metrics::AllocMode;
        use crate::runtime::ops::GenericEntry;
        use crate::runtime::vm::ProgramInfo;

        fn new_vm() -> Box<Vm> {
            Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }), AllocMode::Summary)
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
