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
