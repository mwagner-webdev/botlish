//! botlish_rlf -- the Rust link fixture (HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md).
//!
//! A static library whose only global symbols, once localized
//! (tools/rust-unit.tcl), are the `rlf_*` C functions and, with the weak
//! fallback, `rlfp_post`: its private Rust standard library, panic
//! runtime, personality routine and allocator never meet the Botlish
//! runtime's. What it exercises is what the http unit relies on:
//!
//! * the Rust standard library: collections, formatting, `Mutex`, threads;
//! * heap allocation and release on the unit's side only, counted by its
//!   own global allocator (feature `counting`);
//! * opaque state behind i64 handles, made and destroyed explicitly, a
//!   stale handle refused (never dereferenced);
//! * a stateful operation (a capacity-bounded store of integers);
//! * a notification boundary: a thread of the unit's posts records to an
//!   optional provider (notify.c), and its join reports what the provider
//!   accepted -- or the target's -ENOSYS when no provider is linked;
//! * failure paths: error codes, and a panic caught at the boundary
//!   (unwinding through the unit's own personality routine).
//!
//! Every buffer is the caller's (`rlf_describe` writes into it); nothing the
//! unit allocates is ever released by anyone else.

use std::collections::{BTreeMap, HashMap};
use std::fmt::Write as _;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::{Mutex, Once};
use std::thread::JoinHandle;

/// No store of that handle (never made, or destroyed).
pub const ERR_STALE: i64 = -2;
/// The store holds its capacity.
pub const ERR_FULL: i64 = -3;
/// An argument out of range.
pub const ERR_ARG: i64 = -4;
/// The store's notifier is running already, or none is.
pub const ERR_BUSY: i64 = -5;
/// A panic caught at the boundary.
pub const ERR_PANIC: i64 = -99;

#[cfg(feature = "counting")]
mod counting {
    use std::alloc::{GlobalAlloc, Layout, System};
    use std::sync::atomic::{AtomicI64, Ordering};

    pub static LIVE: AtomicI64 = AtomicI64::new(0);
    pub static TOTAL: AtomicI64 = AtomicI64::new(0);

    pub struct Counting;

    unsafe impl GlobalAlloc for Counting {
        unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
            LIVE.fetch_add(layout.size() as i64, Ordering::Relaxed);
            TOTAL.fetch_add(1, Ordering::Relaxed);
            System.alloc(layout)
        }

        unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
            LIVE.fetch_sub(layout.size() as i64, Ordering::Relaxed);
            System.dealloc(ptr, layout)
        }
    }

    #[global_allocator]
    static GLOBAL: Counting = Counting;
}

extern "C" {
    fn rlfshim_post(tag: i32, value: i64) -> i32;
    fn rlfshim_enosys() -> i32;
}

struct Store {
    values: Vec<i64>,
    capacity: usize,
    /// How often each value was pushed (a second structure, so that every
    /// push allocates and every destroy releases more than one block).
    counts: BTreeMap<i64, u32>,
    notifier: Option<JoinHandle<i64>>,
}

struct Registry {
    next: i64,
    stores: HashMap<i64, Store>,
}

static REGISTRY: Mutex<Option<Registry>> = Mutex::new(None);
static QUIET: Once = Once::new();

fn with_registry<R>(f: impl FnOnce(&mut Registry) -> R) -> R {
    let mut guard = REGISTRY.lock().unwrap_or_else(|e| e.into_inner());
    let registry = guard.get_or_insert_with(|| Registry { next: 1, stores: HashMap::new() });
    f(registry)
}

/// Run F, turning a panic into ERR_PANIC: no unwinding crosses the C ABI.
/// The unit's panic hook (its own standard library's) is silenced once, so
/// a caught panic prints nothing; the Botlish runtime's hook, in its own
/// standard library, is untouched.
fn guard(f: impl FnOnce() -> i64) -> i64 {
    QUIET.call_once(|| std::panic::set_hook(Box::new(|_| {})));
    match catch_unwind(AssertUnwindSafe(f)) {
        Ok(v) => v,
        Err(_) => ERR_PANIC,
    }
}

/// The fixture's ABI version.
#[no_mangle]
pub extern "C" fn rlf_version() -> i64 {
    1
}

/// A new store of CAPACITY integers (1 to 1,000,000): its handle (> 0), or
/// ERR_ARG.
#[no_mangle]
pub extern "C" fn rlf_create(capacity: i64) -> i64 {
    guard(|| {
        if !(1..=1_000_000).contains(&capacity) {
            return ERR_ARG;
        }
        with_registry(|r| {
            let h = r.next;
            r.next += 1;
            let store = Store { values: Vec::with_capacity(capacity.min(64) as usize), capacity: capacity as usize, counts: BTreeMap::new(), notifier: None };
            r.stores.insert(h, store);
            h
        })
    })
}

/// Push VALUE to store H: how many values it holds, ERR_FULL or ERR_STALE.
#[no_mangle]
pub extern "C" fn rlf_push(h: i64, value: i64) -> i64 {
    guard(|| {
        with_registry(|r| match r.stores.get_mut(&h) {
            None => ERR_STALE,
            Some(s) if s.values.len() >= s.capacity => ERR_FULL,
            Some(s) => {
                s.values.push(value);
                *s.counts.entry(value).or_insert(0) += 1;
                s.values.len() as i64
            }
        })
    })
}

/// The wrapping sum of store H's values, or ERR_STALE.
#[no_mangle]
pub extern "C" fn rlf_sum(h: i64) -> i64 {
    guard(|| with_registry(|r| r.stores.get(&h).map_or(ERR_STALE, |s| s.values.iter().fold(0i64, |a, v| a.wrapping_add(*v)))))
}

/// Store H described in UTF-8, written into BUF (CAP bytes, the caller's):
/// the description's length in bytes (at most CAP of them written), or
/// ERR_STALE. Formatting allocates on the unit's side and releases there.
///
/// # Safety
/// BUF holds CAP writable bytes.
#[no_mangle]
pub unsafe extern "C" fn rlf_describe(h: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| {
        let text = with_registry(|r| {
            r.stores.get(&h).map(|s| {
                let mut t = String::new();
                let sum = s.values.iter().fold(0i64, |a, v| a.wrapping_add(*v));
                let distinct = s.counts.len();
                let top = s.counts.iter().max_by_key(|(v, c)| (**c, std::cmp::Reverse(**v))).map(|(v, c)| format!("{v}\u{d7}{c}"));
                let _ = write!(t, "store {h}: {} of {} values, sum {sum}, {distinct} distinct, most {}", s.values.len(), s.capacity, top.as_deref().unwrap_or("none"));
                t
            })
        });
        match text {
            None => ERR_STALE,
            Some(t) => {
                let n = t.len().min(cap as usize);
                if n > 0 {
                    std::ptr::copy_nonoverlapping(t.as_ptr(), buf, n);
                }
                t.len() as i64
            }
        }
    })
}

/// Destroy store H (its notifier joined first): 0 or ERR_STALE.
#[no_mangle]
pub extern "C" fn rlf_destroy(h: i64) -> i64 {
    guard(|| {
        let removed = with_registry(|r| r.stores.remove(&h));
        match removed {
            None => ERR_STALE,
            Some(mut s) => {
                if let Some(t) = s.notifier.take() {
                    let _ = t.join();
                }
                drop(s);
                0
            }
        }
    })
}

/// How many stores are live.
#[no_mangle]
pub extern "C" fn rlf_live() -> i64 {
    guard(|| with_registry(|r| r.stores.len() as i64))
}

/// Bytes the unit's own allocator holds (feature `counting`), else -1.
#[no_mangle]
pub extern "C" fn rlf_alloc_live() -> i64 {
    #[cfg(feature = "counting")]
    {
        counting::LIVE.load(std::sync::atomic::Ordering::Relaxed)
    }
    #[cfg(not(feature = "counting"))]
    {
        -1
    }
}

/// Allocations the unit's own allocator made (feature `counting`), else -1.
#[no_mangle]
pub extern "C" fn rlf_alloc_total() -> i64 {
    #[cfg(feature = "counting")]
    {
        counting::TOTAL.load(std::sync::atomic::Ordering::Relaxed)
    }
    #[cfg(not(feature = "counting"))]
    {
        -1
    }
}

/// Panic inside the boundary, as a failing operation of store H would:
/// ERR_PANIC once the unwinding has run H's destructors on the unit's own
/// personality routine (ERR_STALE for no such store).
#[no_mangle]
pub extern "C" fn rlf_panic(h: i64) -> i64 {
    let live = with_registry(|r| r.stores.contains_key(&h));
    if !live {
        return ERR_STALE;
    }
    guard(|| {
        let scratch: Vec<String> = (0..4).map(|i| format!("scratch {i}")).collect();
        let index = scratch.len() + h as usize;
        // Out of bounds: a panic, unwound through `scratch`'s destructor.
        scratch[index].len() as i64
    })
}

/// Start store H's notifier: a thread of the unit's that posts COUNT
/// records (tag H, values 0..COUNT) through notify.c to the provider. 0,
/// ERR_BUSY (one is running), ERR_STALE or ERR_ARG.
#[no_mangle]
pub extern "C" fn rlf_notify_start(h: i64, count: i64) -> i64 {
    guard(|| {
        if !(0..=1_000_000).contains(&count) {
            return ERR_ARG;
        }
        with_registry(|r| match r.stores.get_mut(&h) {
            None => ERR_STALE,
            Some(s) if s.notifier.is_some() => ERR_BUSY,
            Some(s) => {
                let tag = h as i32;
                let thread = std::thread::Builder::new().name(format!("rlf-notify-{h}")).spawn(move || {
                    let mut accepted = 0i64;
                    for v in 0..count {
                        let rc = unsafe { rlfshim_post(tag, v) };
                        if rc < 0 {
                            return rc as i64;
                        }
                        accepted += 1;
                    }
                    accepted
                });
                match thread {
                    Ok(t) => {
                        s.notifier = Some(t);
                        0
                    }
                    Err(_) => ERR_ARG,
                }
            }
        })
    })
}

/// Join store H's notifier: how many records the provider accepted, the
/// provider's refusal (negative: the target's -ENOSYS when none is linked),
/// ERR_BUSY (none running) or ERR_STALE.
#[no_mangle]
pub extern "C" fn rlf_notify_join(h: i64) -> i64 {
    guard(|| {
        let thread = with_registry(|r| match r.stores.get_mut(&h) {
            None => Err(ERR_STALE),
            Some(s) => s.notifier.take().ok_or(ERR_BUSY),
        });
        match thread {
            Err(e) => e,
            Ok(t) => t.join().unwrap_or(ERR_PANIC),
        }
    })
}

/// The target's ENOSYS (38 on Linux, 78 on macOS).
#[no_mangle]
pub extern "C" fn rlf_no_provider() -> i64 {
    unsafe { rlfshim_enosys() as i64 }
}
