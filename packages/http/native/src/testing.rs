//! The test unit's exports (feature `testing`, never in a released
//! archive): fault injection, the bridge's counters, and a counting global
//! allocator (allocations and bytes the unit's Rust code made).

use crate::bridge::ffi::{guard, guard_with};
use crate::bridge::{exec, stats};
use std::alloc::{GlobalAlloc, Layout, System};
use std::sync::atomic::{AtomicU64, Ordering};

struct Counting;

static ALLOCS: AtomicU64 = AtomicU64::new(0);
static BYTES: AtomicU64 = AtomicU64::new(0);
static LIVE: AtomicU64 = AtomicU64::new(0);

unsafe impl GlobalAlloc for Counting {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        ALLOCS.fetch_add(1, Ordering::Relaxed);
        BYTES.fetch_add(layout.size() as u64, Ordering::Relaxed);
        LIVE.fetch_add(layout.size() as u64, Ordering::Relaxed);
        System.alloc(layout)
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        LIVE.fetch_sub(layout.size() as u64, Ordering::Relaxed);
        System.dealloc(ptr, layout)
    }
}

#[global_allocator]
static GLOBAL: Counting = Counting;

/// Set the fault bits (crate::faults).
#[no_mangle]
pub extern "C" fn bh_t_set_fault(bits: i64) -> i64 {
    guard_with(false, || {
        crate::faults::set(bits as u32);
        0
    })
}

/// The bridge's counter I (bridge::stats::Counter), or -1.
#[no_mangle]
pub extern "C" fn bh_t_stat(i: i64) -> i64 {
    guard_with(false, || stats::get(i as i32))
}

/// 0 allocations, 1 bytes allocated, 2 bytes live (the unit's Rust heap).
#[no_mangle]
pub extern "C" fn bh_t_alloc(i: i64) -> i64 {
    guard_with(false, || match i {
        0 => ALLOCS.load(Ordering::Relaxed) as i64,
        1 => BYTES.load(Ordering::Relaxed) as i64,
        2 => LIVE.load(Ordering::Relaxed) as i64,
        _ => -1,
    })
}

/// Live bridge tasks.
#[no_mangle]
pub extern "C" fn bh_t_tasks() -> i64 {
    guard(|| exec::task_count() as i64)
}

/// Reset the bridge's counters.
#[no_mangle]
pub extern "C" fn bh_t_stats_reset() -> i64 {
    guard_with(false, || {
        stats::reset();
        0
    })
}
