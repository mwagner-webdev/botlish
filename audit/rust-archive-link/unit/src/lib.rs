//! botlish_rustlink: the Rust fixture of
//! HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md.
//!
//! What it carries, because the http unit carries it and because each is a
//! way two copies of Rust's standard library in one executable can meet:
//!
//! * a `#[global_allocator]` of its own (a counting one, as botlish_http's
//!   test unit has): the allocator shim (`__rust_alloc` and friends) is the
//!   one place where the linker choosing the wrong copy is observable from
//!   outside -- the unit's allocations stop being counted, or the Botlish
//!   runtime's start to be;
//! * unwinding: every export runs in a guard that catches panics
//!   (botlish_http's `bridge::ffi::guard`), so a panic inside the unit runs
//!   the unit's own personality routine and unwind tables;
//! * a panic hook, a `Mutex`, thread-locals, `std::thread`, `format!` and
//!   `HashMap`: the standard library's global and per-thread state;
//! * opaque state behind i64 handles (a slab with generations, as
//!   botlish_http's exchanges), created and destroyed explicitly;
//! * caller-lent buffers (`buf`, `cap`: a Botlish write exposure, valid for
//!   one call), and one block the unit lends out and takes back
//!   (`rl_text_new`, `rl_text_free`: the caller holds it as an affine
//!   pointer and must give it back to the unit, never to libc's free --
//!   which, the unit's allocator being the system's underneath, would not
//!   crash but leave the unit's live-byte counter short: the violation is
//!   observable, not undefined);
//! * a synchronous C callback (a Botlish `callback c fn`), called with no
//!   lock held;
//! * the notification boundary: a foreign thread of the unit's calls
//!   `botlish_http_notify_post`, the C function of the notification object
//!   the build script compiles (by default packages/http/native/src/notify.c:
//!   a weak reference to the event loop's `botlish_event_post2`).
//!
//! The C ABI (every function returns an i64; negative values are errors):
//!
//!   rl_version()                      the ABI version, 1
//!   rl_open(capacity)                 a store's handle (> 0)
//!   rl_close(h)                       0
//!   rl_put(h, data, len)              the store's item count after it
//!   rl_digest(h, buf, cap)            the summary's length (copied: min(cap))
//!   rl_fail(h, kind)                  0: ERR_REFUSED; 1, 2: a panic (ERR_PANIC)
//!   rl_each(h, cb)                    the sum of cb(index, length) per item
//!   rl_notify(loop, ep, slot, gen, a) what the post returned (from a thread)
//!   rl_stats(buf, cap)                bytes written: 8 i64s (see STATS)
//!   rl_toolchain(buf, cap)            the rustc version's length (copied: min(cap))
//!   rl_text_new(h)                    a 64-byte block the unit owns (null: stale)
//!   rl_text_free(p)                   0: the block given back to the unit's allocator

use std::alloc::{GlobalAlloc, Layout, System};
use std::cell::Cell;
use std::collections::HashMap;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::{Mutex, Once};

pub const ERR_STALE: i64 = -1;
pub const ERR_FULL: i64 = -2;
pub const ERR_REFUSED: i64 = -4;
pub const ERR_ARGUMENT: i64 = -5;
pub const ERR_REENTRANT: i64 = -90003;
pub const ERR_PANIC: i64 = -90001;

// ------------------------------------------------------------ the allocator

struct Counting;

static ALLOCS: AtomicI64 = AtomicI64::new(0);
static FREES: AtomicI64 = AtomicI64::new(0);
static LIVE: AtomicI64 = AtomicI64::new(0);

unsafe impl GlobalAlloc for Counting {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        ALLOCS.fetch_add(1, Ordering::Relaxed);
        LIVE.fetch_add(layout.size() as i64, Ordering::Relaxed);
        System.alloc(layout)
    }

    unsafe fn alloc_zeroed(&self, layout: Layout) -> *mut u8 {
        ALLOCS.fetch_add(1, Ordering::Relaxed);
        LIVE.fetch_add(layout.size() as i64, Ordering::Relaxed);
        System.alloc_zeroed(layout)
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        FREES.fetch_add(1, Ordering::Relaxed);
        LIVE.fetch_sub(layout.size() as i64, Ordering::Relaxed);
        System.dealloc(ptr, layout)
    }

    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        ALLOCS.fetch_add(1, Ordering::Relaxed);
        FREES.fetch_add(1, Ordering::Relaxed);
        LIVE.fetch_add(new_size as i64 - layout.size() as i64, Ordering::Relaxed);
        System.realloc(ptr, layout, new_size)
    }
}

#[global_allocator]
static GLOBAL: Counting = Counting;

// ------------------------------------------------------------ the guard

static PANICS: AtomicI64 = AtomicI64::new(0);
static HOOK: Once = Once::new();
static LAST_PANIC: Mutex<String> = Mutex::new(String::new());

thread_local! {
    static ACTIVE: Cell<bool> = const { Cell::new(false) };
}

/// Run F as one C call: a panic is ERR_PANIC (never unwinding into C), a
/// call made while one runs on this thread ERR_REENTRANT. The unit's panic
/// hook records the message instead of printing it.
fn guard<F: FnOnce() -> i64>(f: F) -> i64 {
    HOOK.call_once(|| {
        std::panic::set_hook(Box::new(|info| {
            if let Ok(mut last) = LAST_PANIC.lock() {
                *last = format!("{info}");
            }
        }));
    });
    if ACTIVE.with(|a| a.replace(true)) {
        return ERR_REENTRANT;
    }
    let r = catch_unwind(AssertUnwindSafe(f));
    ACTIVE.with(|a| a.set(false));
    match r {
        Ok(v) => v,
        Err(_) => {
            PANICS.fetch_add(1, Ordering::Relaxed);
            ERR_PANIC
        }
    }
}

/// Copy SRC into the C buffer DST of CAP bytes; SRC's length.
///
/// # Safety
/// DST must be valid for CAP bytes of writes for this call.
unsafe fn copy_out(src: &[u8], dst: *mut u8, cap: u64) -> i64 {
    let n = src.len().min(cap as usize);
    if n > 0 && !dst.is_null() {
        std::ptr::copy_nonoverlapping(src.as_ptr(), dst, n);
    }
    src.len() as i64
}

// ------------------------------------------------------------ the stores

struct Store {
    capacity: usize,
    items: Vec<Vec<u8>>,
    seen: HashMap<Vec<u8>, usize>,
}

struct Slot {
    generation: i64,
    store: Option<Box<Store>>,
}

static SLOTS: Mutex<Vec<Slot>> = Mutex::new(Vec::new());
static OPENED: AtomicI64 = AtomicI64::new(0);

const SLOT_BITS: i64 = 24;

fn handle(index: usize, generation: i64) -> i64 {
    (generation << SLOT_BITS) | (index as i64 + 1)
}

/// The store of handle H, given to F with the slab locked; ERR_STALE for a
/// handle no open store has.
fn with_store<R>(h: i64, f: impl FnOnce(&mut Store) -> R) -> Result<R, i64> {
    if h <= 0 {
        return Err(ERR_STALE);
    }
    let index = ((h & ((1 << SLOT_BITS) - 1)) - 1) as usize;
    let generation = h >> SLOT_BITS;
    let mut slots = SLOTS.lock().unwrap();
    match slots.get_mut(index) {
        Some(Slot { generation: g, store: Some(store) }) if *g == generation => Ok(f(store)),
        _ => Err(ERR_STALE),
    }
}

fn fnv1a(hash: u64, bytes: &[u8]) -> u64 {
    bytes.iter().fold(hash, |h, b| (h ^ *b as u64).wrapping_mul(0x100000001b3))
}

/// The ABI version.
#[no_mangle]
pub extern "C" fn rl_version() -> i64 {
    guard(|| 1)
}

/// Open a store of at most CAPACITY items: its handle.
#[no_mangle]
pub extern "C" fn rl_open(capacity: i64) -> i64 {
    guard(|| {
        if !(1..=1 << 20).contains(&capacity) {
            return ERR_ARGUMENT;
        }
        let store = Box::new(Store { capacity: capacity as usize, items: Vec::new(), seen: HashMap::new() });
        let mut slots = SLOTS.lock().unwrap();
        OPENED.fetch_add(1, Ordering::Relaxed);
        if let Some(i) = slots.iter().position(|s| s.store.is_none()) {
            let slot = &mut slots[i];
            slot.generation += 1;
            slot.store = Some(store);
            return handle(i, slot.generation);
        }
        slots.push(Slot { generation: 1, store: Some(store) });
        handle(slots.len() - 1, 1)
    })
}

/// Close store H: everything it holds is freed (by the unit's allocator).
#[no_mangle]
pub extern "C" fn rl_close(h: i64) -> i64 {
    guard(|| {
        if h <= 0 {
            return ERR_STALE;
        }
        let index = ((h & ((1 << SLOT_BITS) - 1)) - 1) as usize;
        let generation = h >> SLOT_BITS;
        let taken = {
            let mut slots = SLOTS.lock().unwrap();
            match slots.get_mut(index) {
                Some(slot) if slot.generation == generation && slot.store.is_some() => slot.store.take(),
                _ => None,
            }
        };
        match taken {
            Some(store) => {
                drop(store);
                0
            }
            None => ERR_STALE,
        }
    })
}

/// Add a copy of the LEN bytes at DATA to store H: its item count after.
///
/// # Safety
/// DATA must be valid for LEN bytes of reads for this call (a Botlish read
/// exposure).
#[no_mangle]
pub unsafe extern "C" fn rl_put(h: i64, data: *const u8, len: u64) -> i64 {
    guard(|| {
        let bytes = if len == 0 || data.is_null() {
            Vec::new()
        } else {
            std::slice::from_raw_parts(data, len as usize).to_vec()
        };
        with_store(h, |s| {
            if s.items.len() >= s.capacity {
                return ERR_FULL;
            }
            let at = s.items.len();
            s.seen.entry(bytes.clone()).or_insert(at);
            s.items.push(bytes);
            s.items.len() as i64
        })
        .unwrap_or_else(|e| e)
    })
}

/// Store H's summary, copied into the CAP bytes at BUF: its length.
///
/// # Safety
/// BUF must be valid for CAP bytes of writes for this call.
#[no_mangle]
pub unsafe extern "C" fn rl_digest(h: i64, buf: *mut u8, cap: u64) -> i64 {
    guard(|| {
        let text = with_store(h, |s| {
            let bytes: usize = s.items.iter().map(Vec::len).sum();
            let hash = s.items.iter().fold(0xcbf29ce484222325, |h, item| fnv1a(fnv1a(h, item), &[0xff]));
            let mut firsts: Vec<(&Vec<u8>, &usize)> = s.seen.iter().collect();
            firsts.sort_by_key(|(_, at)| **at);
            let longest = firsts.iter().map(|(k, _)| k.len()).max().unwrap_or(0);
            format!("items={} unique={} bytes={} longest={} fnv1a={:016x}", s.items.len(), firsts.len(), bytes, longest, hash)
        });
        match text {
            Ok(text) => copy_out(text.as_bytes(), buf, cap),
            Err(e) => e,
        }
    })
}

/// A failure of store H's: KIND 0 a refusal (ERR_REFUSED), 1 an index out of
/// bounds and 2 an explicit panic -- both caught by the guard (ERR_PANIC),
/// unwinding through the unit's frames with its own personality routine.
#[no_mangle]
pub extern "C" fn rl_fail(h: i64, kind: i64) -> i64 {
    guard(|| {
        let n = match with_store(h, |s| s.items.len()) {
            Ok(n) => n,
            Err(e) => return e,
        };
        match kind {
            0 => ERR_REFUSED,
            1 => {
                let items: Vec<i64> = vec![0; n];
                items[n + std::hint::black_box(1)]
            }
            2 => panic!("rustlink: a requested panic after {n} items"),
            _ => ERR_ARGUMENT,
        }
    })
}

/// Call CB(index, length) for each item of store H, in order, with no lock
/// held (the lengths are copied first): the sum of what CB returned.
#[no_mangle]
pub extern "C" fn rl_each(h: i64, cb: Option<extern "C" fn(i64, i64) -> i64>) -> i64 {
    guard(|| {
        let Some(cb) = cb else { return ERR_ARGUMENT };
        let lengths = match with_store(h, |s| s.items.iter().map(Vec::len).collect::<Vec<_>>()) {
            Ok(l) => l,
            Err(e) => return e,
        };
        lengths.iter().enumerate().fold(0i64, |sum, (i, n)| sum.wrapping_add(cb(i as i64, *n as i64)))
    })
}

extern "C" {
    // The notification object's (build.rs: packages/http/native/src/notify.c
    // or a variant): a post to a loop's endpoint through the event loop's
    // native integration ABI, version 2.
    fn botlish_http_notify_post(lp: i32, endpoint: i32, slot: i32, generation: i32, a: i64, b: i64) -> i32;
}

/// Post (A, the posting thread's sequence number) to endpoint EP of loop LP
/// with the registration tag (SLOT, GEN), from a thread of the unit's own,
/// as the http unit's name resolver does: what the post returned (-38 where
/// nothing defines botlish_event_post2).
#[no_mangle]
pub extern "C" fn rl_notify(lp: i64, ep: i64, slot: i64, generation: i64, a: i64) -> i64 {
    guard(|| {
        let worker = std::thread::Builder::new()
            .name("rustlink-notify".to_string())
            .spawn(move || unsafe { botlish_http_notify_post(lp as i32, ep as i32, slot as i32, generation as i32, a, 1) as i64 });
        match worker.map(|w| w.join()) {
            Ok(Ok(r)) => r,
            _ => ERR_REFUSED,
        }
    })
}

/// The unit's counters, 8 i64s copied into BUF (CAP >= 64): open stores,
/// stores ever opened, the unit allocator's allocations, frees and live
/// bytes, panics caught, the length of the last panic's message, and 1.
///
/// # Safety
/// BUF must be valid for CAP bytes of writes for this call.
#[no_mangle]
pub unsafe extern "C" fn rl_stats(buf: *mut u8, cap: u64) -> i64 {
    guard(|| {
        if cap < 64 {
            return ERR_ARGUMENT;
        }
        let open = SLOTS.lock().unwrap().iter().filter(|s| s.store.is_some()).count() as i64;
        let last = LAST_PANIC.lock().map(|s| s.len() as i64).unwrap_or(-1);
        // Read the allocator's counters last: nothing after them allocates.
        let values = [
            open,
            OPENED.load(Ordering::Relaxed),
            ALLOCS.load(Ordering::Relaxed),
            FREES.load(Ordering::Relaxed),
            LIVE.load(Ordering::Relaxed),
            PANICS.load(Ordering::Relaxed),
            last,
            1,
        ];
        let mut bytes = [0u8; 64];
        for (i, v) in values.iter().enumerate() {
            bytes[i * 8..i * 8 + 8].copy_from_slice(&v.to_le_bytes());
        }
        copy_out(&bytes, buf, cap)
    })
}

/// The version of the rustc that built the unit, copied into BUF: its length.
///
/// # Safety
/// BUF must be valid for CAP bytes of writes for this call.
#[no_mangle]
pub unsafe extern "C" fn rl_toolchain(buf: *mut u8, cap: u64) -> i64 {
    guard(|| copy_out(env!("RUSTLINK_RUSTC").as_bytes(), buf, cap))
}

const TEXT_BLOCK: usize = 64;

/// A block of TEXT_BLOCK bytes the unit allocates and owns, holding the
/// start of store H's summary: the caller must give it back with
/// rl_text_free. Null for a stale handle.
#[no_mangle]
pub extern "C" fn rl_text_new(h: i64) -> *mut u8 {
    let mut block = Box::new([0u8; TEXT_BLOCK]);
    let r = guard(|| {
        let n = with_store(h, |s| s.items.len()).unwrap_or(usize::MAX);
        if n == usize::MAX {
            return ERR_STALE;
        }
        let text = format!("{n} items");
        let k = text.len().min(TEXT_BLOCK);
        block[..k].copy_from_slice(&text.as_bytes()[..k]);
        0
    });
    if r != 0 {
        return std::ptr::null_mut();
    }
    Box::into_raw(block).cast::<u8>()
}

/// Give back a block of rl_text_new's: 0, or ERR_ARGUMENT for null.
///
/// # Safety
/// P must be a block rl_text_new returned and not given back since.
#[no_mangle]
pub unsafe extern "C" fn rl_text_free(p: *mut u8) -> i64 {
    if p.is_null() {
        return ERR_ARGUMENT;
    }
    guard(|| {
        drop(Box::from_raw(p.cast::<[u8; TEXT_BLOCK]>()));
        0
    })
}
