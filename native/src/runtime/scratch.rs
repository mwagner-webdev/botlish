//! Compiler-managed scratch storage (STORAGE-COMPILER-MANAGED-SCRATCH-
//! MILESTONE-1.md): the storage provider that realizes the compiler's
//! storage-use plan (hir/storageplan.tcl) for temporary Strings.
//!
//! Who decides what. The compiler decides which allocation sites may use
//! reusable storage and when that storage may be reused: hir::lifetime proves
//! an object confined to a region (an activation, a loop iteration),
//! hir::storageplan selects the sites and native lowering emits the region
//! boundaries (`scratchmark` at a region's entry, `scratchreset` at an
//! iteration's start and at the loop's exit, `scratchexit` at every function
//! exit, normal or error) and the requests (`scratchreq` before a selected
//! String operation, `scratchdest` before a call whose callee may place its
//! result's pieces in the caller's region). This module only supplies and
//! reuses bytes: it never decides that an object is dead, never discovers a
//! lifetime and never resets anything on its own.
//!
//! The provider. One per Vm (it lives in the Vm's `Heap`): a stack of
//! regions over a list of chunks. Allocation bumps a position; a region's
//! mark is the position at its entry; a reset moves the position back to a
//! mark. Regions nest strictly (a callee's region above its caller's, an
//! inner loop's above its enclosing one's), so a reset to a region's mark
//! releases exactly that region's objects and those of regions it entered.
//! Units that may suspend never enter a region (the plan excludes them), so
//! the nesting holds across coroutine stacks too: a segment's regions are
//! all left before it yields.
//!
//! Chunks never move: an object's address stays valid until the position
//! is reset below it. When the current chunk is full the position moves to
//! the next chunk -- an existing one if it is large enough, else a new
//! reservation -- so growth never invalidates a live object. A chunk above
//! the position holds no live object and may be replaced by a larger one.
//! Chunks are kept for the next region's reuse until the run ends
//! (`Vm::reset`) or the Vm is dropped.
//!
//! Policy of this first provider (opportunistic): a String larger than
//! `max_object` bytes, or one that would take the reserved total past
//! `max_total`, falls back to the managed heap -- an ordinary heap String,
//! collected as every other. Fallback never changes a value or an error.
//! BOTLISH_NATIVE_SCRATCH_CHUNK, _MAX_OBJECT and _MAX_TOTAL override the
//! three sizes (tests force growth and fallback with them).
//!
//! The collector. A scratch String holds no reference (a String is a leaf:
//! heap.rs never scans its text), so nothing in scratch needs tracing. The
//! collector skips every pointer into a chunk *before* reading what it
//! points at (`contains`), so a scratch object is never marked or swept,
//! and a stale pointer into released scratch memory can never be
//! misread as a header. Such a pointer would be a premature reset (the
//! compiler's confinement proof says none exists): the collector counts it
//! (`stale_roots`), which the tests and the audit require to be zero.
//!
//! Test instruments: with BOTLISH_NATIVE_SCRATCH_POISON=1 (and always under
//! BOTLISH_NATIVE_GC_STRESS=1) every reset overwrites the released bytes
//! with `POISON_BYTE`, so a read of a released String reads garbage instead
//! of its old text; `stale_roots` counts roots into released storage at
//! every collection. Neither decides anything.

use super::metrics::ScratchStats;
use super::value::{Value, fits_small, is_small, make_small, small_of};
use std::alloc::{Layout, alloc, dealloc, handle_alloc_error};

/// The byte a poisoned reset writes over released storage.
pub const POISON_BYTE: u8 = 0xDB;

/// The first chunk's capacity (later ones double).
const FIRST_CHUNK: usize = 16 << 10;
/// The largest String (header and text, padded) placed in scratch storage.
const MAX_OBJECT: usize = 64 << 10;
/// The most scratch storage one Vm reserves before falling back.
const MAX_TOTAL: usize = 64 << 20;
/// Chunk alignment (a String needs 8).
const CHUNK_ALIGN: usize = 16;

struct Chunk {
    ptr: *mut u8,
    cap: usize,
    /// Where the position left this chunk for the next one (valid for the
    /// chunks below the current one).
    fill: usize,
    /// The highest offset ever allocated up to: an allocation entirely below
    /// it reuses bytes an earlier object occupied.
    high: usize,
}

pub struct Scratch {
    chunks: Vec<Chunk>,
    cur: usize,
    pos: usize,
    /// Bytes in use below the current chunk (the fills of chunks 0..cur).
    base: usize,
    /// Address bounds of every chunk ([lo, hi)), for the collector's
    /// quick rejection.
    lo: usize,
    hi: usize,
    reserved: usize,
    first_chunk: usize,
    max_object: usize,
    max_total: usize,
    poison: bool,
}

fn env_size(name: &str, default: usize) -> usize {
    std::env::var(name).ok().and_then(|v| v.parse().ok()).filter(|&n: &usize| n > 0).unwrap_or(default)
}

impl Scratch {
    pub fn new(stress: bool) -> Scratch {
        let poison = stress || std::env::var("BOTLISH_NATIVE_SCRATCH_POISON").is_ok_and(|v| v == "1");
        Scratch {
            chunks: Vec::new(),
            cur: 0,
            pos: 0,
            base: 0,
            lo: usize::MAX,
            hi: 0,
            reserved: 0,
            first_chunk: env_size("BOTLISH_NATIVE_SCRATCH_CHUNK", FIRST_CHUNK),
            max_object: env_size("BOTLISH_NATIVE_SCRATCH_MAX_OBJECT", MAX_OBJECT),
            max_total: env_size("BOTLISH_NATIVE_SCRATCH_MAX_TOTAL", MAX_TOTAL),
            poison,
        }
    }

    /// Test hook: poison released storage (as BOTLISH_NATIVE_SCRATCH_POISON=1).
    pub fn set_poison_for_test(&mut self, on: bool) {
        self.poison = on;
    }

    /// Test hook: the three policy sizes.
    pub fn set_sizes_for_test(&mut self, first_chunk: usize, max_object: usize, max_total: usize) {
        self.first_chunk = first_chunk;
        self.max_object = max_object;
        self.max_total = max_total;
    }

    /// The current position as a mark: a small Int (chunk << 32 | offset),
    /// never a pointer, so a register or root slot holding it is nothing to
    /// the collector.
    pub fn mark(&self) -> Value {
        let m = ((self.cur as i64) << 32) | self.pos as i64;
        debug_assert!(fits_small(m));
        make_small(m)
    }

    fn decode(mark: Value) -> Option<(usize, usize)> {
        if !is_small(mark) {
            return None;
        }
        let m = small_of(mark);
        if m < 0 {
            return None;
        }
        Some(((m >> 32) as usize, (m & 0xffff_ffff) as usize))
    }

    /// Bytes in use (allocated and not released).
    pub fn occupancy(&self) -> usize {
        self.base + self.pos
    }

    /// Bytes reserved (every chunk's capacity).
    pub fn reserved(&self) -> usize {
        self.reserved
    }

    pub fn chunk_count(&self) -> usize {
        self.chunks.len()
    }

    /// Moves the position back to MARK, releasing every object allocated
    /// since. A mark above the position (impossible while regions nest) is
    /// a protocol error: counted, and the position stays.
    pub fn reset(&mut self, mark: Value, stats: &mut ScratchStats) {
        stats.resets += 1;
        let Some((c, p)) = Self::decode(mark) else {
            stats.protocol_errors += 1;
            return;
        };
        if (c, p) == (self.cur, self.pos) {
            return;
        }
        if (c, p) > (self.cur, self.pos) || (c > 0 && c >= self.chunks.len()) {
            stats.protocol_errors += 1;
            return;
        }
        if self.poison {
            self.poison_range(c, p);
        }
        self.cur = c;
        self.pos = p;
        self.base = self.chunks[..c].iter().map(|k| k.fill).sum();
    }

    /// Overwrites the bytes between (C, P) and the position with POISON_BYTE.
    fn poison_range(&mut self, c: usize, p: usize) {
        for i in c..=self.cur {
            if i >= self.chunks.len() {
                break;
            }
            let from = if i == c { p } else { 0 };
            let to = if i == self.cur { self.pos } else { self.chunks[i].fill };
            if to > from {
                unsafe { std::ptr::write_bytes(self.chunks[i].ptr.add(from), POISON_BYTE, to - from) };
            }
        }
    }

    /// SIZE bytes (a multiple of 8), 8-aligned, or None when the policy
    /// sends the object to the heap (too large, or the reservation limit).
    pub fn alloc(&mut self, size: usize, stats: &mut ScratchStats) -> Option<*mut u8> {
        debug_assert!(size % 8 == 0);
        if size > self.max_object {
            stats.fallback_large += 1;
            return None;
        }
        if self.chunks.is_empty() {
            let cap = self.first_chunk.max(size);
            if !self.reserve_at(0, cap, stats) {
                return None;
            }
            self.cur = 0;
            self.pos = 0;
            self.base = 0;
        }
        if self.pos + size > self.chunks[self.cur].cap {
            // The next chunk: an existing one large enough, a larger one in
            // place of one too small (it holds no live object: it is above
            // the position), or a new one.
            let next = self.cur + 1;
            let fits = next < self.chunks.len() && self.chunks[next].cap >= size;
            if !fits {
                let cap = (self.chunks[self.cur].cap * 2).max(size).max(self.first_chunk);
                if !self.reserve_at(next, cap, stats) {
                    return None;
                }
            }
            self.chunks[self.cur].fill = self.pos;
            self.base += self.pos;
            self.cur = next;
            self.pos = 0;
        }
        let at = self.pos;
        let chunk = &mut self.chunks[self.cur];
        if at + size <= chunk.high {
            stats.reused += 1;
        }
        chunk.high = chunk.high.max(at + size);
        let block = unsafe { chunk.ptr.add(at) };
        self.pos = at + size;
        stats.allocations += 1;
        stats.bytes += size as u64;
        stats.peak_occupancy = stats.peak_occupancy.max(self.occupancy() as u64);
        Some(block)
    }

    /// Reserves a chunk of CAP bytes as chunk AT (a new last chunk, or in
    /// place of a chunk above the position). False at the reservation limit.
    fn reserve_at(&mut self, at: usize, cap: usize, stats: &mut ScratchStats) -> bool {
        let freed = if at < self.chunks.len() { self.chunks[at].cap } else { 0 };
        if self.reserved - freed + cap > self.max_total {
            stats.fallback_capacity += 1;
            return false;
        }
        let layout = Layout::from_size_align(cap, CHUNK_ALIGN).expect("scratch chunk layout");
        let ptr = unsafe { alloc(layout) };
        if ptr.is_null() {
            handle_alloc_error(layout);
        }
        let chunk = Chunk { ptr, cap, fill: 0, high: 0 };
        if at < self.chunks.len() {
            let old = std::mem::replace(&mut self.chunks[at], chunk);
            unsafe { dealloc(old.ptr, Layout::from_size_align_unchecked(old.cap, CHUNK_ALIGN)) };
            stats.released_reservations += 1;
        } else {
            self.chunks.push(chunk);
        }
        if stats.reservations > 0 || self.chunks.len() > 1 {
            stats.growths += 1;
        }
        stats.reservations += 1;
        self.reserved = self.reserved - freed + cap;
        stats.peak_reserved = stats.peak_reserved.max(self.reserved as u64);
        self.lo = self.chunks.iter().map(|k| k.ptr as usize).min().unwrap_or(usize::MAX);
        self.hi = self.chunks.iter().map(|k| k.ptr as usize + k.cap).max().unwrap_or(0);
        true
    }

    /// Whether ADDR lies in a chunk (an object of this Vm's scratch storage,
    /// live or released): what the collector skips without reading it.
    #[inline]
    pub fn contains(&self, addr: Value) -> bool {
        let a = addr as usize;
        if a < self.lo || a >= self.hi {
            return false;
        }
        self.chunks.iter().any(|k| a >= k.ptr as usize && a < k.ptr as usize + k.cap)
    }

    /// Whether ADDR (in a chunk) lies in released storage: at or past the
    /// position in the current chunk, past a lower chunk's fill, or in a
    /// chunk above the current one.
    pub fn is_released(&self, addr: Value) -> bool {
        let a = addr as usize;
        for (i, k) in self.chunks.iter().enumerate() {
            let start = k.ptr as usize;
            if a >= start && a < start + k.cap {
                let off = a - start;
                return if i > self.cur || self.chunks.is_empty() {
                    true
                } else if i == self.cur {
                    off >= self.pos
                } else {
                    off >= k.fill
                };
            }
        }
        false
    }

    /// The end of a run (Vm::reset): every region is left; the chunks go.
    pub fn release_all(&mut self) {
        for k in self.chunks.drain(..) {
            unsafe { dealloc(k.ptr, Layout::from_size_align_unchecked(k.cap, CHUNK_ALIGN)) };
        }
        self.cur = 0;
        self.pos = 0;
        self.base = 0;
        self.lo = usize::MAX;
        self.hi = 0;
        self.reserved = 0;
    }
}

impl Drop for Scratch {
    fn drop(&mut self) {
        self.release_all();
    }
}

// ---------------------------------------------------------------------------
// The helpers generated code calls (native/lower.tcl's scratch frames and
// loop regions; codegen::clif). `scratchtake`, `scratchreq` and
// `scratchdest` are inline stores and loads of the Vm's two words.

/// `%m = op scratchmark`: entering a region, its mark (a small Int).
#[unsafe(no_mangle)]
pub extern "C" fn rt_scratch_mark(p: *mut super::vm::Vm) -> Value {
    let vm = unsafe { &mut *p };
    vm.metrics.scratch.regions += 1;
    vm.heap.scratch.mark()
}

/// `op scratchreset %m`: a loop iteration's start or the loop's exit; every
/// object of the region since MARK is dead (the plan's proof).
#[unsafe(no_mangle)]
pub extern "C" fn rt_scratch_reset(p: *mut super::vm::Vm, mark: Value) -> Value {
    let vm = unsafe { &mut *p };
    vm.heap.scratch.reset(mark, &mut vm.metrics.scratch);
    super::value::UNIT
}

/// `op scratchexit %m %d`: a framed function's exit, normal or error. A
/// function its caller gave a destination (DEST the small Int 1) leaves
/// what it allocated in the caller's region; any other resets to MARK.
#[unsafe(no_mangle)]
pub extern "C" fn rt_scratch_exit(p: *mut super::vm::Vm, mark: Value, dest: Value) -> Value {
    if dest != make_small(1) {
        rt_scratch_reset(p, mark);
    }
    super::value::UNIT
}

#[cfg(test)]
mod tests {
    use super::*;

    fn stats() -> ScratchStats {
        ScratchStats::default()
    }

    #[test]
    fn bump_mark_reset_reuses_the_same_bytes() {
        let mut s = Scratch::new(false);
        let mut st = stats();
        let m = s.mark();
        let a = s.alloc(32, &mut st).unwrap();
        let b = s.alloc(32, &mut st).unwrap();
        assert_eq!(b as usize, a as usize + 32);
        s.reset(m, &mut st);
        let c = s.alloc(32, &mut st).unwrap();
        assert_eq!(c, a, "the region's bytes are reused after its reset");
        assert_eq!(st.reservations, 1);
        assert_eq!(st.reused, 1);
        assert_eq!(st.protocol_errors, 0);
    }

    #[test]
    fn nested_regions_release_only_their_own() {
        let mut s = Scratch::new(false);
        let mut st = stats();
        let outer = s.alloc(40, &mut st).unwrap();
        let m = s.mark();
        let inner = s.alloc(40, &mut st).unwrap();
        assert!(inner as usize >= outer as usize + 40);
        s.reset(m, &mut st);
        assert!(!s.is_released(outer as Value));
        assert!(s.is_released(inner as Value));
        assert_eq!(s.occupancy(), 40);
    }

    #[test]
    fn growth_never_moves_a_live_object() {
        let mut s = Scratch::new(false);
        s.set_sizes_for_test(64, 1024, 1 << 20);
        let mut st = stats();
        let first = s.alloc(48, &mut st).unwrap();
        unsafe { first.write(7) };
        let second = s.alloc(48, &mut st).unwrap();
        assert_ne!(second as usize, first as usize + 48, "a second chunk");
        assert_eq!(unsafe { first.read() }, 7);
        assert!(s.contains(first as Value) && s.contains(second as Value));
        assert_eq!(st.reservations, 2);
        assert_eq!(st.growths, 1);
        // Back to the start: the second chunk is reused by the next region.
        s.reset(make_small(0), &mut st);
        let a = s.alloc(48, &mut st).unwrap();
        let b = s.alloc(48, &mut st).unwrap();
        assert_eq!((a, b), (first, second));
        assert_eq!(st.reservations, 2, "no new reservation once warmed up");
    }

    #[test]
    fn a_too_small_chunk_above_the_position_is_replaced() {
        let mut s = Scratch::new(false);
        s.set_sizes_for_test(64, 4096, 1 << 20);
        let mut st = stats();
        s.alloc(64, &mut st).unwrap();
        s.alloc(64, &mut st).unwrap(); // chunk 1 (128 bytes)
        s.reset(make_small(0), &mut st);
        s.alloc(64, &mut st).unwrap();
        let big = s.alloc(1000, &mut st).unwrap();
        assert!(s.contains(big as Value));
        assert_eq!(st.released_reservations, 1);
        assert_eq!(s.chunk_count(), 2);
    }

    #[test]
    fn policy_falls_back_for_large_objects_and_at_the_limit() {
        let mut s = Scratch::new(false);
        s.set_sizes_for_test(64, 128, 256);
        let mut st = stats();
        assert!(s.alloc(136, &mut st).is_none());
        assert_eq!(st.fallback_large, 1);
        s.alloc(64, &mut st).unwrap();
        s.alloc(128, &mut st).unwrap(); // 64 + 128 reserved
        assert!(s.alloc(128, &mut st).is_none(), "a third chunk would pass the limit");
        assert_eq!(st.fallback_capacity, 1);
        assert_eq!(s.occupancy(), 192);
    }

    #[test]
    fn poison_overwrites_released_bytes() {
        let mut s = Scratch::new(false);
        s.set_poison_for_test(true);
        let mut st = stats();
        let m = s.mark();
        let a = s.alloc(16, &mut st).unwrap();
        unsafe { std::ptr::write_bytes(a, 1, 16) };
        s.reset(m, &mut st);
        assert_eq!(unsafe { a.read() }, POISON_BYTE);
    }

    #[test]
    fn a_mark_above_the_position_is_a_protocol_error() {
        let mut s = Scratch::new(false);
        let mut st = stats();
        s.alloc(8, &mut st).unwrap();
        let high = s.mark();
        s.reset(make_small(0), &mut st);
        s.reset(high, &mut st);
        assert_eq!(st.protocol_errors, 1);
        assert_eq!(s.occupancy(), 0);
        s.reset(super::super::value::UNIT, &mut st);
        assert_eq!(st.protocol_errors, 2);
    }

    #[test]
    fn marks_are_small_ints() {
        let mut s = Scratch::new(false);
        let mut st = stats();
        s.alloc(24, &mut st).unwrap();
        let m = s.mark();
        assert!(is_small(m));
        assert!(!super::super::value::is_pointer(m));
    }
}
