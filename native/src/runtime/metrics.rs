//! Allocation accounting: counts, bytes, live/peak, GC, copies.
//!
//! `Vm::alloc` (vm.rs) is the one physical allocation point; `Heap::collect`
//! (heap.rs) is the one place every object's fate (live or reclaimed) is
//! known exactly. Both update a `Metrics` in place. Nothing here changes
//! what is allocated, when a collection runs, or the collector's algorithm:
//! it only observes.
//!
//! Two independent switches (native::main's `--alloc`):
//!
//!   * `Off`: `Metrics::enabled()` is false everywhere, so every hook below
//!     is a single predictable branch and nothing else. Byte-identical
//!     execution to the uninstrumented backend otherwise.
//!   * `Summary`: every hook below runs. No NIR/codegen change is needed
//!     for this: counts, bytes, live/peak, GC, copies are all runtime-only.
//!   * `Sites`: additionally, codegen (codegen/clif.rs) emits one extra
//!     store of the causing instruction's site id into `Vm::alloc_site`
//!     before each allocating helper call, so `record_alloc` can attribute
//!     the allocation. Off/Summary never touch `alloc_site`.
//!
//! `allocated_bytes` is defined as exactly what the runtime's own
//! constructors compute and hand to `Heap::register`: the Rust struct size
//! (`header_bytes`, including the `Header` and every fixed field) plus the
//! caller-computed variable-length payload (`payload_bytes`) -- e.g. a
//! `Vec`'s capacity in bytes, a `Box<str>`'s length, a BigInt's estimated
//! limb bytes. This is *not* the allocator's actual malloc chunk size: no
//! padding or fragmentation accounting.
//!
//! What this does not see: `num-bigint`'s internal limb buffer is a second,
//! separate Rust allocation outside the Botlish heap's object list, and its
//! transient growth during arithmetic is never counted (see BigIntObj's
//! comment in value.rs and object_size in heap.rs). Also excluded: the
//! shadow stack (a fixed-size `Vec<Value>`, ~32 MB, vm.rs), Cranelift/JIT
//! code memory, and general process bookkeeping. This report measures the
//! Botlish managed heap only.

use super::show::tcl_list;
use super::value::{
    KIND_BIGINT, KIND_CELL, KIND_CLOSURE, KIND_LIST, KIND_MUTARRAY, KIND_NATIVE, KIND_RESULT, KIND_STR,
};
use std::collections::HashMap;
use std::time::Duration;

/// One more than the largest `Header::kind` value: `by_kind`/`static_by_kind`
/// are indexed directly by kind byte (index 0 unused).
pub const KIND_COUNT: usize = 9;

pub fn kind_name(kind: u8) -> &'static str {
    match kind {
        KIND_BIGINT => "BigInt",
        KIND_STR => "String",
        KIND_LIST => "List",
        KIND_RESULT => "Result",
        KIND_CLOSURE => "Block",
        KIND_NATIVE => "Native",
        KIND_CELL => "Cell",
        KIND_MUTARRAY => "MutableArray",
        _ => "?",
    }
}

/// Every kind this milestone's object set uses, in report order.
pub const KINDS: [u8; 8] =
    [KIND_STR, KIND_LIST, KIND_MUTARRAY, KIND_BIGINT, KIND_RESULT, KIND_CLOSURE, KIND_CELL, KIND_NATIVE];

#[derive(Clone, Copy, Default)]
pub struct KindStats {
    /// Total objects of this kind ever allocated (a running counter: not a
    /// live count).
    pub allocations: u64,
    pub header_bytes: u64,
    pub payload_bytes: u64,
    /// Recomputed exactly at every collection from the retained set (never
    /// "allocated - freed"), then held between collections.
    pub live_objects: u64,
    pub live_bytes: u64,
    /// Cumulative over every collection so far.
    pub reclaimed_objects: u64,
    pub reclaimed_bytes: u64,
}

impl KindStats {
    pub fn allocated_bytes(&self) -> u64 {
        self.header_bytes + self.payload_bytes
    }
}

#[derive(Clone, Copy, Default)]
pub struct StaticKindStats {
    pub allocations: u64,
    pub bytes: u64,
}

#[derive(Clone, Copy, Default)]
pub struct SiteStats {
    pub allocations: u64,
    pub allocated_bytes: u64,
}

/// Why a collection ran (Heap::trigger_reason, Vm::reset).
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum GcReason {
    /// Allocated bytes since the last collection exceeded the threshold.
    Threshold,
    /// BOTLISH_NATIVE_GC_STRESS=1: every allocation collects first.
    Stress,
    /// Vm::reset's end-of-run collection, between benchmark runs in one
    /// process.
    Explicit,
}

impl GcReason {
    pub fn name(self) -> &'static str {
        match self {
            GcReason::Threshold => "threshold",
            GcReason::Stress => "stress",
            GcReason::Explicit => "explicit",
        }
    }
}

pub struct GcCycle {
    pub reason: GcReason,
    pub objects_before: u64,
    pub bytes_before: u64,
    pub objects_reclaimed: u64,
    pub bytes_reclaimed: u64,
    pub objects_after: u64,
    pub bytes_after: u64,
    pub duration: Duration,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum AllocMode {
    Off,
    Summary,
    Sites,
}

impl AllocMode {
    pub fn parse(s: &str) -> Option<AllocMode> {
        match s {
            "off" => Some(AllocMode::Off),
            "summary" => Some(AllocMode::Summary),
            "sites" => Some(AllocMode::Sites),
            _ => None,
        }
    }

    pub fn enabled(self) -> bool {
        self != AllocMode::Off
    }

    pub fn sites(self) -> bool {
        self == AllocMode::Sites
    }
}

pub struct Metrics {
    pub mode: AllocMode,
    pub by_kind: [KindStats; KIND_COUNT],
    /// The constant/static table (codegen::CompiledProgram::install_constants):
    /// allocated once per program, outside the Heap's object list, never
    /// collected. Excluded from live/peak/GC; counted here only so "how
    /// many objects did this program allocate" is honest about them.
    pub static_by_kind: [StaticKindStats; KIND_COUNT],
    /// Populated only in Sites mode (site id 0 means "unattributed" and is
    /// never inserted).
    pub sites: HashMap<u32, SiteStats>,
    pub current_live_objects: u64,
    pub current_live_bytes: u64,
    pub peak_live_objects: u64,
    pub peak_live_bytes: u64,
    pub gc_cycles: Vec<GcCycle>,
    pub gc_time: Duration,
    pub gc_max_pause: Duration,
    pub string_bytes_copied: u64,
    pub list_elements_copied: u64,
    /// Existing-value movement into a MutableArray: bulk copy
    /// (mutable_array_copy) and finalization (mutable_array_freeze), never
    /// an ordinary append write of one fresh value into unused capacity
    /// (see the "No misleading copy accounting" note on
    /// rt_mutarray_set/rt_mutarray_freeze in ops.rs).
    pub mutarray_elements_copied: u64,
    /// Optional mutation counters (req #12): every mutable_array_get/_set
    /// call, regardless of whether it is part of a copy.
    pub mutarray_reads: u64,
    pub mutarray_writes: u64,
    /// Source UTF-8 bytes walked (`char_indices`/`chars().skip(..)`-style
    /// decoding) solely to map a semantic (Unicode-scalar) String position
    /// to a physical UTF-8 byte offset, when that offset is not already
    /// carried in from a previous access -- rt_substr's and
    /// rt_str_region_eq's non-ASCII paths, the two remaining places a
    /// character index is located by decoding forward from byte 0 (see
    /// their own comments). Never includes: the copy that follows a seek
    /// (string_bytes_copied, separate), equality/hash comparison bytes, or
    /// any use of rt_str_decode_char_at/rt_str_byte_len (the "String
    /// traversal" ops below), which act at an already-carried byte offset
    /// and so never seek at all. See hir/traversal.tcl and native/lower.tcl's
    /// "String traversal" section for the optimization this measures.
    pub utf8_seek_bytes: u64,
}

impl Metrics {
    pub fn new(mode: AllocMode) -> Metrics {
        Metrics {
            mode,
            by_kind: [KindStats::default(); KIND_COUNT],
            static_by_kind: [StaticKindStats::default(); KIND_COUNT],
            sites: HashMap::new(),
            current_live_objects: 0,
            current_live_bytes: 0,
            peak_live_objects: 0,
            peak_live_bytes: 0,
            gc_cycles: Vec::new(),
            gc_time: Duration::ZERO,
            gc_max_pause: Duration::ZERO,
            string_bytes_copied: 0,
            list_elements_copied: 0,
            mutarray_elements_copied: 0,
            mutarray_reads: 0,
            mutarray_writes: 0,
            utf8_seek_bytes: 0,
        }
    }

    pub fn enabled(&self) -> bool {
        self.mode.enabled()
    }

    /// Per-run isolation (Vm::reset): a fresh run starts with empty
    /// cumulative counters, not the previous run's totals. static_by_kind
    /// is preserved: the constant table is installed once per program (see
    /// codegen::CompiledProgram::install_constants), not once per run, so
    /// it is a program-level fact rather than something a run accumulates.
    pub fn reset(&mut self) {
        let static_by_kind = self.static_by_kind;
        *self = Metrics::new(self.mode);
        self.static_by_kind = static_by_kind;
    }

    pub fn record_alloc(&mut self, kind: u8, header_bytes: usize, payload_bytes: usize, site: u32) {
        if !self.enabled() {
            return;
        }
        let bytes = (header_bytes + payload_bytes) as u64;
        let k = &mut self.by_kind[kind as usize];
        k.allocations += 1;
        k.header_bytes += header_bytes as u64;
        k.payload_bytes += payload_bytes as u64;
        // Between collections, nothing dies: a fresh allocation is live
        // until the next Heap::collect proves otherwise, so both the
        // per-kind and global live counters grow here. Heap::collect then
        // overwrites both exactly from the retained set (never relying on
        // this incremental count alone), so there is no drift either way.
        k.live_objects += 1;
        k.live_bytes += bytes;
        self.current_live_objects += 1;
        self.current_live_bytes += bytes;
        self.peak_live_objects = self.peak_live_objects.max(self.current_live_objects);
        self.peak_live_bytes = self.peak_live_bytes.max(self.current_live_bytes);
        if site != 0 {
            let s = self.sites.entry(site).or_default();
            s.allocations += 1;
            s.allocated_bytes += bytes;
        }
    }

    pub fn record_static(&mut self, kind: u8, bytes: u64) {
        if !self.enabled() {
            return;
        }
        let k = &mut self.static_by_kind[kind as usize];
        k.allocations += 1;
        k.bytes += bytes;
    }

    pub fn record_string_copy(&mut self, bytes: usize) {
        if self.enabled() {
            self.string_bytes_copied += bytes as u64;
        }
    }

    pub fn record_list_copy(&mut self, elements: usize) {
        if self.enabled() {
            self.list_elements_copied += elements as u64;
        }
    }

    pub fn record_mutarray_copy(&mut self, elements: usize) {
        if self.enabled() {
            self.mutarray_elements_copied += elements as u64;
        }
    }

    pub fn record_mutarray_read(&mut self) {
        if self.enabled() {
            self.mutarray_reads += 1;
        }
    }

    pub fn record_mutarray_write(&mut self) {
        if self.enabled() {
            self.mutarray_writes += 1;
        }
    }

    pub fn record_utf8_seek(&mut self, bytes: usize) {
        if self.enabled() {
            self.utf8_seek_bytes += bytes as u64;
        }
    }

    pub fn total_allocations(&self) -> u64 {
        self.by_kind.iter().map(|k| k.allocations).sum()
    }

    pub fn total_allocated_bytes(&self) -> u64 {
        self.by_kind.iter().map(|k| k.allocated_bytes()).sum()
    }

    pub fn static_allocations(&self) -> u64 {
        self.static_by_kind.iter().map(|k| k.allocations).sum()
    }

    pub fn static_bytes(&self) -> u64 {
        self.static_by_kind.iter().map(|k| k.bytes).sum()
    }

    pub fn gc_reclaimed_objects(&self) -> u64 {
        self.gc_cycles.iter().map(|c| c.objects_reclaimed).sum()
    }

    pub fn gc_reclaimed_bytes(&self) -> u64 {
        self.gc_cycles.iter().map(|c| c.bytes_reclaimed).sum()
    }

    /// The structured allocation report as one Tcl dict (the canonical
    /// representation: tests and tooling read this, not the human text
    /// formatter native.tcl renders from it). SITES_TCL is a pre-rendered
    /// Tcl list of site entries (native/src/codegen/clif.rs's site table
    /// joined with this Metrics' per-site counts) -- "" when not in Sites
    /// mode, or before that table exists. Metrics itself never needs to
    /// know about NIR/HIR: see the "Site table" note in codegen/clif.rs.
    pub fn to_tcl(&self, sites_tcl: &str) -> String {
        let n = |v: u64| v.to_string();
        let us = |d: Duration| d.as_micros().to_string();
        let total = dict(&[
            ("allocations", n(self.total_allocations())),
            ("allocatedBytes", n(self.total_allocated_bytes())),
            ("headerBytes", n(self.by_kind.iter().map(|k| k.header_bytes).sum())),
            ("payloadBytes", n(self.by_kind.iter().map(|k| k.payload_bytes).sum())),
            ("currentLiveObjects", n(self.current_live_objects)),
            ("currentLiveBytes", n(self.current_live_bytes)),
            ("peakLiveObjects", n(self.peak_live_objects)),
            ("peakLiveBytes", n(self.peak_live_bytes)),
        ]);
        let by_kind = dict(&KINDS.iter().map(|&k| (kind_name(k), kind_dict(&self.by_kind[k as usize], &n))).collect::<Vec<_>>());
        let static_by_kind =
            dict(&KINDS.iter().map(|&k| (kind_name(k), static_kind_dict(&self.static_by_kind[k as usize], &n))).collect::<Vec<_>>());
        let statics = dict(&[
            ("allocations", n(self.static_allocations())),
            ("bytes", n(self.static_bytes())),
            ("byKind", static_by_kind),
        ]);
        let cycles: Vec<String> = self
            .gc_cycles
            .iter()
            .map(|c| {
                dict(&[
                    ("reason", c.reason.name().to_string()),
                    ("objectsBefore", n(c.objects_before)),
                    ("bytesBefore", n(c.bytes_before)),
                    ("objectsReclaimed", n(c.objects_reclaimed)),
                    ("bytesReclaimed", n(c.bytes_reclaimed)),
                    ("objectsAfter", n(c.objects_after)),
                    ("bytesAfter", n(c.bytes_after)),
                    ("durationUs", us(c.duration)),
                ])
            })
            .collect();
        let gc = dict(&[
            ("cycles", n(self.gc_cycles.len() as u64)),
            ("reclaimedObjects", n(self.gc_reclaimed_objects())),
            ("reclaimedBytes", n(self.gc_reclaimed_bytes())),
            ("totalTimeUs", us(self.gc_time)),
            ("maxPauseUs", us(self.gc_max_pause)),
            ("cyclesDetail", tcl_list(&cycles)),
        ]);
        let copies = dict(&[
            ("stringBytes", n(self.string_bytes_copied)),
            ("listElements", n(self.list_elements_copied)),
            ("mutableArrayElements", n(self.mutarray_elements_copied)),
        ]);
        let mutations = dict(&[("reads", n(self.mutarray_reads)), ("writes", n(self.mutarray_writes))]);
        let traversal = dict(&[("utf8SeekBytes", n(self.utf8_seek_bytes))]);
        dict(&[
            ("total", total),
            ("byKind", by_kind),
            ("static", statics),
            ("gc", gc),
            ("copies", copies),
            ("mutableArray", mutations),
            ("traversal", traversal),
            ("sites", sites_tcl.to_string()),
        ])
    }
}

fn dict(pairs: &[(&str, String)]) -> String {
    let words: Vec<String> = pairs.iter().flat_map(|(k, v)| [k.to_string(), v.clone()]).collect();
    tcl_list(&words)
}

fn kind_dict(k: &KindStats, n: &impl Fn(u64) -> String) -> String {
    dict(&[
        ("allocations", n(k.allocations)),
        ("allocatedBytes", n(k.allocated_bytes())),
        ("headerBytes", n(k.header_bytes)),
        ("payloadBytes", n(k.payload_bytes)),
        ("currentLiveObjects", n(k.live_objects)),
        ("currentLiveBytes", n(k.live_bytes)),
        ("reclaimedObjects", n(k.reclaimed_objects)),
        ("reclaimedBytes", n(k.reclaimed_bytes)),
    ])
}

fn static_kind_dict(k: &StaticKindStats, n: &impl Fn(u64) -> String) -> String {
    dict(&[("allocations", n(k.allocations)), ("bytes", n(k.bytes))])
}
