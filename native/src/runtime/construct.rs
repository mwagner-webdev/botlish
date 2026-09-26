//! Virtual immutable construction (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md):
//! the runtime half of native/lower.tcl's "Virtual construction" lowering.
//!
//! A *construction plan* is compiler/runtime implementation state meaning
//! "if this immutable String/List becomes observable as a flat value, here
//! are the already-evaluated pieces it is made of". It is never a Botlish
//! value: no semantic operation ever receives one. Every plan object is
//! owned by exactly one NIR register at a time (native/lower.tcl's linear-
//! use proof, re-checked structurally by nir.rs's `validate_plans`), so the
//! runtime may extend it *in place* -- the only transient mutation M8.a
//! introduces, and never observable, because nothing but the next
//! `construct` (or the final materialization) ever reads it.
//!
//! One instruction family, `construct KIND MODE PIECE...` (nir.rs's
//! `Inst::Construct`), lowers to one helper, `rt_construct`, whatever the
//! number of pieces (no strcat2/strcat3/... opcode zoo):
//!
//!   KIND   str | list
//!   MODE   flat  -> an ordinary flat String/List, byte-for-byte the object
//!                   rt_str_cat/rt_list_append would have built (or an
//!                   existing flat piece returned unchanged when it is the
//!                   only piece)
//!          plan  -> a private plan object (KIND_STRPLAN/KIND_LISTPLAN):
//!                   the first plan piece, if any, extended in place
//!                   ("anchor"), else a fresh plan
//!   PIECE  span %r               a flat String/List, or an owned plan of the
//!                                same family (consumed)
//!          region %b %s %e       String only: base[s..e) by character index,
//!                                already validated by `regioncheck` (a
//!                                StringRegion used as a piece, never
//!                                materialized as its own String)
//!          elem %r               List only: one already-evaluated element
//!
//! Plan representations (the smallest append-efficient transient shapes the
//! measured workloads justify -- see the report's "Chosen construction-plan
//! representation"):
//!
//!   StrPlanObj   a gap buffer of UTF-8 bytes, data in buf[start..end], with
//!                amortized geometric growth at whichever end is extended
//!                (appends keep front slack 0, prepends keep back slack 0),
//!                so both `concat(acc, x)` and `concat(x, acc)` recurrences
//!                copy each piece's bytes a constant number of times. Holds
//!                no Value at all: a piece's bytes are copied in when it
//!                joins, so the piece object itself may die immediately --
//!                nothing for the collector to trace.
//!   ListPlanObj  a growable Vec of element Values (append-only: list_append
//!                is the only List construction API). Traced by the
//!                collector (heap.rs) like a List's own items.
//!
//! The character count and ASCII flag of a String plan are maintained
//! incrementally from each piece's own stored fields, exactly as rt_str_cat
//! computes them (no rescan).

use super::error::RtError;
use std::mem::MaybeUninit;
use super::value::*;
use super::vm::Vm;

pub const TAG_SPAN: u64 = 0;
pub const TAG_REGION: u64 = 1;
pub const TAG_ELEM: u64 = 2;

/// `rt_construct`'s MODE word: bit 0 set for a List (else String), bit 1 set
/// for plan mode (else flat).
pub const MODE_LIST: u64 = 1;
pub const MODE_PLAN: u64 = 2;

/// Bytes left free before a fresh String plan's data (see construct_str).
const FRESH_FRONT_SLACK: usize = 8;

#[repr(C)]
pub struct StrPlanObj {
    pub hdr: Header,
    /// Storage: `buf.len()` is the capacity; live bytes are buf[start..end].
    pub buf: Vec<u8>,
    pub start: usize,
    pub end: usize,
    pub chars: usize,
    pub ascii: bool,
    /// Set once the plan has been absorbed into another construction; any
    /// later read is a broken linearity invariant (see this module's doc)
    /// and panics instead of silently reading an empty/stale plan.
    pub consumed: bool,
}

#[repr(C)]
pub struct ListPlanObj {
    pub hdr: Header,
    pub items: Vec<Value>,
    pub consumed: bool,
}

/// Shared access to a String plan (reading its bytes as a piece).
pub fn strplan_of<'a>(v: Value) -> &'a StrPlanObj {
    debug_assert_eq!(heap_kind(v), KIND_STRPLAN);
    unsafe { as_ref(v) }
}

/// Exclusive access to a String plan: only ever taken once every shared
/// borrow of the running construct's pieces has ended.
fn strplan_mut<'a>(v: Value) -> &'a mut StrPlanObj {
    debug_assert_eq!(heap_kind(v), KIND_STRPLAN);
    unsafe { &mut *(v as *mut StrPlanObj) }
}

pub fn listplan_of<'a>(v: Value) -> &'a ListPlanObj {
    debug_assert_eq!(heap_kind(v), KIND_LISTPLAN);
    unsafe { as_ref(v) }
}

fn listplan_mut<'a>(v: Value) -> &'a mut ListPlanObj {
    debug_assert_eq!(heap_kind(v), KIND_LISTPLAN);
    unsafe { &mut *(v as *mut ListPlanObj) }
}

/// Marks the absorbed plan V consumed and releases its storage early.
fn consume_str_plan(p: *mut Vm, v: Value) {
    let plan = strplan_mut(v);
    plan.consumed = true;
    plan.buf = Vec::new();
    plan.start = 0;
    plan.end = 0;
    vm(p).metrics.construction.merges += 1;
}

fn consume_list_plan(p: *mut Vm, v: Value) {
    let plan = listplan_mut(v);
    plan.consumed = true;
    plan.items = Vec::new();
    vm(p).metrics.construction.merges += 1;
}

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

/// One decoded String piece: its UTF-8 bytes (borrowed from a live, rooted
/// object -- every piece is an operand register of the running `construct`,
/// and objects never move), character count, ASCII flag, and the plan
/// object it came from, if any (to be consumed).
#[derive(Clone, Copy)]
struct StrPiece<'a> {
    /// The piece's own Value when it is a flat String span (returned as-is
    /// by a one-piece flat construct).
    flat: Option<Value>,
    bytes: &'a [u8],
    chars: usize,
    ascii: bool,
    plan: Option<Value>,
}

#[derive(Clone, Copy)]
enum ListPiece<'a> {
    Span { items: &'a [Value], plan: Option<Value> },
    Elem(Value),
}

/// A construct's decoded pieces: inline for the common handful (no heap
/// allocation per `construct` -- the per-step cost a runtime recurrence pays
/// on every iteration), spilling to a Vec only for an unusually long one.
struct Small<T: Copy> {
    /// Slots 0..len are initialized (never read beyond len).
    inline: [MaybeUninit<T>; 8],
    len: usize,
    spill: Vec<T>,
}

impl<T: Copy> Small<T> {
    #[inline(always)]
    fn new() -> Small<T> {
        Small { inline: [const { MaybeUninit::uninit() }; 8], len: 0, spill: Vec::new() }
    }

    #[inline(always)]
    fn push(&mut self, x: T) {
        if self.spill.is_empty() && self.len < self.inline.len() {
            self.inline[self.len] = MaybeUninit::new(x);
            self.len += 1;
            return;
        }
        if self.spill.is_empty() {
            let inline = self.as_slice().to_vec();
            self.spill = inline;
        }
        self.spill.push(x);
    }

    #[inline(always)]
    fn as_slice(&self) -> &[T] {
        if self.spill.is_empty() {
            // Slots 0..len were written by push.
            unsafe { std::slice::from_raw_parts(self.inline.as_ptr() as *const T, self.len) }
        } else {
            &self.spill
        }
    }
}

impl StrPlanObj {
    fn data(&self) -> &[u8] {
        &self.buf[self.start..self.end]
    }

    fn len(&self) -> usize {
        self.end - self.start
    }

    /// Grows to fit N more bytes at the back; returns the bytes moved.
    fn reserve_back(&mut self, n: usize) -> usize {
        if self.end + n <= self.buf.len() {
            return 0;
        }
        let len = self.len();
        let capacity = (2 * (len + n)).max(16);
        let mut buf = vec![0u8; capacity];
        buf[..len].copy_from_slice(self.data());
        self.buf = buf;
        self.start = 0;
        self.end = len;
        len
    }

    /// Grows to fit N more bytes at the front; returns the bytes moved.
    fn reserve_front(&mut self, n: usize) -> usize {
        if self.start >= n {
            return 0;
        }
        let len = self.len();
        let capacity = (2 * (len + n)).max(16);
        let mut buf = vec![0u8; capacity];
        buf[capacity - len..].copy_from_slice(self.data());
        self.buf = buf;
        self.start = capacity - len;
        self.end = capacity;
        len
    }
}

fn check_live(consumed: bool) {
    if consumed {
        panic!("BUG: a virtual construction plan was read after it was consumed (linearity violated)");
    }
}

fn oversized(p: *mut Vm, len: usize) -> Value {
    let message = format!("a String/List cannot exceed {MAX_COLLECTION_LENGTH} characters/elements, got {len}");
    vm(p).fail(RtError::Semantic { kind: "RANGE", message })
}

#[inline(always)]
fn decode_str_pieces<'a>(p: *mut Vm, words: &'a [u64]) -> Small<StrPiece<'a>> {
    let mut pieces = Small::new();
    let mut i = 0;
    while i < words.len() {
        match words[i] {
            TAG_SPAN => {
                let v = words[i + 1];
                match heap_kind(v) {
                    KIND_STR => {
                        let s = str_of(v);
                        pieces.push(StrPiece { flat: Some(v), bytes: s.text.as_bytes(), chars: s.chars, ascii: s.ascii, plan: None });
                    }
                    KIND_STRPLAN => {
                        let plan = strplan_of(v);
                        check_live(plan.consumed);
                        pieces.push(StrPiece { flat: None, bytes: plan.data(), chars: plan.chars, ascii: plan.ascii, plan: Some(v) });
                    }
                    kind => panic!("BUG: construct str: span piece of heap kind {kind}"),
                }
                i += 2;
            }
            TAG_REGION => {
                let base = str_of(words[i + 1]);
                let from = int_small(words[i + 2]).expect("region start already validated") as usize;
                let to = int_small(words[i + 3]).expect("region end already validated") as usize;
                let bytes = if base.ascii {
                    &base.text.as_bytes()[from..to]
                } else {
                    // The same seek rt_substr/rt_str_region_eq perform (and
                    // account) for a non-ASCII base: character index FROM
                    // is located by decoding forward from byte 0.
                    let mut indices = base.text.char_indices();
                    let seek_start = indices.by_ref().nth(from).map_or(base.text.len(), |(i, _)| i);
                    vm(p).metrics.record_utf8_seek(seek_start);
                    let rest = &base.text[seek_start..];
                    let width = rest.char_indices().nth(to - from).map_or(rest.len(), |(i, _)| i);
                    &rest.as_bytes()[..width]
                };
                let ascii = base.ascii || bytes.is_ascii();
                pieces.push(StrPiece { flat: None, bytes, chars: to - from, ascii, plan: None });
                vm(p).metrics.construction.region_pieces += 1;
                i += 4;
            }
            tag => panic!("BUG: construct str: bad piece tag {tag}"),
        }
    }
    pieces
}

#[inline(always)]
fn decode_list_pieces(words: &[u64]) -> Small<ListPiece<'_>> {
    let mut pieces = Small::new();
    let mut i = 0;
    while i < words.len() {
        match words[i] {
            TAG_SPAN => {
                let v = words[i + 1];
                match heap_kind(v) {
                    KIND_LIST => pieces.push(ListPiece::Span { items: list_of(v).items(), plan: None }),
                    KIND_LISTPLAN => {
                        let plan = listplan_of(v);
                        check_live(plan.consumed);
                        pieces.push(ListPiece::Span { items: &plan.items, plan: Some(v) });
                    }
                    kind => panic!("BUG: construct list: span piece of heap kind {kind}"),
                }
                i += 2;
            }
            TAG_ELEM => {
                pieces.push(ListPiece::Elem(words[i + 1]));
                i += 2;
            }
            tag => panic!("BUG: construct list: bad piece tag {tag}"),
        }
    }
    pieces
}

/// `%d = construct KIND MODE PIECE...` (see this module's doc). WORDS is N
/// 64-bit words: each piece's tag followed by its operand Values. Returns
/// the result, or NO_VALUE with a pending RANGE error when the result would
/// exceed MAX_COLLECTION_LENGTH (the one failure mode eager concat and
/// list_append also have).
pub extern "C" fn rt_construct(p: *mut Vm, mode: u64, n: u64, words: *const u64) -> Value {
    let words = unsafe { std::slice::from_raw_parts(words, n as usize) };
    let plan_mode = mode & MODE_PLAN != 0;
    if mode & MODE_LIST != 0 {
        construct_list(p, plan_mode, words)
    } else {
        construct_str(p, plan_mode, words)
    }
}

fn construct_str(p: *mut Vm, plan_mode: bool, words: &[u64]) -> Value {
    let decoded = decode_str_pieces(p, words);
    let pieces = decoded.as_slice();
    let mut chars = 0;
    let mut bytes = 0;
    let mut ascii = true;
    let mut anchor = None;
    for (i, piece) in pieces.iter().enumerate() {
        chars += piece.chars;
        bytes += piece.bytes.len();
        ascii &= piece.ascii;
        if anchor.is_none() && piece.plan.is_some() {
            anchor = Some(i);
        }
    }
    if chars > MAX_COLLECTION_LENGTH {
        return oversized(p, chars);
    }
    vm(p).metrics.construction.pieces += pieces.len() as u64;
    if !plan_mode {
        if let [StrPiece { flat: Some(v), .. }] = pieces {
            // The one piece is already a flat String: it *is* the result.
            let v = *v;
            vm(p).metrics.construction.passthrough += 1;
            return v;
        }
        let mut text = Vec::with_capacity(bytes);
        for piece in pieces {
            text.extend_from_slice(piece.bytes);
        }
        let text = unsafe { String::from_utf8_unchecked(text) };
        let r = vm(p).new_str_known(text, chars, ascii);
        // Every plan piece is absorbed (only its Value is read here: its
        // bytes were copied above).
        for piece in pieces {
            if let Some(plan) = piece.plan {
                consume_str_plan(p, plan);
            }
        }
        let m = &mut vm(p).metrics;
        m.record_string_copy(bytes);
        m.construction.materializations += 1;
        m.construction.materialized_str_bytes += bytes as u64;
        return r;
    }
    let (target, moved, written) = match anchor {
        Some(anchor) => {
            // Extend the first plan piece in place: the pieces before it are
            // written, in order, into its front slack, the ones after it
            // into its back. No other piece can alias the anchor's buffer
            // (every plan has exactly one owner, and this construct owns
            // them all), so each is copied straight from its own storage.
            let target = pieces[anchor].plan.unwrap();
            let before: usize = pieces[..anchor].iter().map(|x| x.bytes.len()).sum();
            let after: usize = pieces[anchor + 1..].iter().map(|x| x.bytes.len()).sum();
            let plan = strplan_mut(target);
            let mut moved = 0;
            if before > 0 {
                moved += plan.reserve_front(before);
                plan.start -= before;
                let mut at = plan.start;
                for piece in &pieces[..anchor] {
                    plan.buf[at..at + piece.bytes.len()].copy_from_slice(piece.bytes);
                    at += piece.bytes.len();
                }
            }
            if after > 0 {
                moved += plan.reserve_back(after);
                for piece in &pieces[anchor + 1..] {
                    let end = plan.end;
                    plan.buf[end..end + piece.bytes.len()].copy_from_slice(piece.bytes);
                    plan.end += piece.bytes.len();
                }
            }
            plan.chars = chars;
            plan.ascii = ascii;
            if moved > 0 {
                let capacity = plan.buf.len();
                let v = vm(p);
                v.metrics.construction.growths += 1;
                v.heap.note_growth(capacity);
            }
            vm(p).metrics.construction.extensions += 1;
            (target, moved, before + after)
        }
        None => {
            // A little front slack (FRESH_FRONT_SLACK) so the common
            // "short prefix before a fresh construction" shape -- e.g. `"%"`
            // before a helper's returned plan -- extends in place instead
            // of regrowing immediately; room at the back for the next few
            // appends.
            let capacity = (2 * bytes + FRESH_FRONT_SLACK).max(32);
            let mut buf = vec![0u8; capacity];
            let mut at = FRESH_FRONT_SLACK;
            for piece in pieces {
                buf[at..at + piece.bytes.len()].copy_from_slice(piece.bytes);
                at += piece.bytes.len();
            }
            let obj = StrPlanObj {
                hdr: Header::new(KIND_STRPLAN, false),
                buf,
                start: FRESH_FRONT_SLACK,
                end: FRESH_FRONT_SLACK + bytes,
                chars,
                ascii,
                consumed: false,
            };
            let r = vm(p).alloc(obj, capacity);
            vm(p).metrics.construction.plans_created += 1;
            (r, 0, bytes)
        }
    };
    // Every plan piece but the result's own anchor is absorbed.
    for piece in pieces {
        if let Some(plan) = piece.plan {
            if plan != target {
                consume_str_plan(p, plan);
            }
        }
    }
    let m = &mut vm(p).metrics;
    m.record_string_copy(written + moved);
    m.construction.str_bytes_into_plans += written as u64;
    m.construction.growth_str_bytes += moved as u64;
    target
}

fn construct_list(p: *mut Vm, plan_mode: bool, words: &[u64]) -> Value {
    let decoded = decode_list_pieces(words);
    let pieces = decoded.as_slice();
    let mut total = 0;
    // Existing stored elements moved (a span's items), as rt_list_append
    // counts them; freshly supplied elements (elem pieces) are writes of a
    // given value, not copies of stored data -- the same convention.
    let mut span_elements = 0;
    for piece in pieces {
        match piece {
            ListPiece::Span { items, .. } => {
                total += items.len();
                span_elements += items.len();
            }
            ListPiece::Elem(_) => total += 1,
        }
    }
    if total > MAX_COLLECTION_LENGTH {
        return oversized(p, total);
    }
    vm(p).metrics.construction.pieces += pieces.len() as u64;
    // Append-only: a leading plan span is extended in place; any other plan
    // span is absorbed.
    let anchor = match pieces.first() {
        Some(ListPiece::Span { plan: Some(v), .. }) if plan_mode => Some(*v),
        _ => None,
    };
    let absorb = |p: *mut Vm, pieces: &[ListPiece]| {
        for piece in pieces {
            if let ListPiece::Span { plan: Some(v), .. } = piece {
                if Some(*v) != anchor {
                    consume_list_plan(p, *v);
                }
            }
        }
    };
    let extend = |items: &mut Vec<Value>, pieces: &[ListPiece]| {
        for piece in pieces {
            match piece {
                ListPiece::Span { items: xs, .. } => items.extend_from_slice(xs),
                ListPiece::Elem(x) => items.push(*x),
            }
        }
    };
    if !plan_mode {
        if let [ListPiece::Span { plan: None, .. }] = pieces {
            vm(p).metrics.construction.passthrough += 1;
            return words[1];
        }
        let mut items = Vec::with_capacity(total);
        extend(&mut items, pieces);
        let r = vm(p).new_list(items);
        absorb(p, pieces);
        let m = &mut vm(p).metrics;
        m.record_list_copy(span_elements);
        m.construction.materializations += 1;
        m.construction.materialized_list_elements += total as u64;
        return r;
    }
    let (target, moved, written, copied) = match anchor {
        Some(target) => {
            let plan = listplan_mut(target);
            let before = plan.items.capacity();
            let old_len = plan.items.len();
            let own = match pieces[0] {
                ListPiece::Span { items, .. } => items.len(),
                ListPiece::Elem(_) => 0,
            };
            extend(&mut plan.items, &pieces[1..]);
            let after = plan.items.capacity();
            let moved = if after != before { old_len } else { 0 };
            if after != before {
                let v = vm(p);
                v.metrics.construction.growths += 1;
                v.heap.note_growth((after - before) * 8);
            }
            vm(p).metrics.construction.extensions += 1;
            (target, moved, total - old_len, span_elements - own)
        }
        None => {
            let mut items = Vec::with_capacity(total.max(4));
            extend(&mut items, pieces);
            let capacity = items.capacity();
            let obj = ListPlanObj { hdr: Header::new(KIND_LISTPLAN, false), items, consumed: false };
            let r = vm(p).alloc(obj, capacity * 8);
            vm(p).metrics.construction.plans_created += 1;
            (r, 0, total, span_elements)
        }
    };
    absorb(p, pieces);
    let m = &mut vm(p).metrics;
    m.record_list_copy(copied + moved);
    m.construction.list_elements_into_plans += written as u64;
    m.construction.growth_list_elements += moved as u64;
    target
}

/// V as an ordinary flat value: V itself unless it is a construction plan,
/// which is materialized (consuming it). Used only by a plan-result
/// function's generic entry (codegen::clif's `define`), the one place a
/// plan-capable result could conceivably meet a caller that expects the
/// ordinary Value ABI: native/lower.tcl only gives a plan result to a closed
/// instance, which that ABI never reaches, so this is defense in depth, not
/// a path any analyzed program takes. Roots V across the allocation with
/// `temp_roots` (this wrapper has no stack map of its own).
pub extern "C" fn rt_plan_materialize(p: *mut Vm, v: Value) -> Value {
    let mode = match heap_kind(v) {
        KIND_STRPLAN => 0,
        KIND_LISTPLAN => MODE_LIST,
        _ => return v,
    };
    vm(p).temp_roots.push(v);
    let words = [TAG_SPAN, v];
    let r = rt_construct(p, mode, 2, words.as_ptr());
    vm(p).temp_roots.pop();
    r
}

#[cfg(test)]
mod tests {
    use super::*;

    fn plan(text: &str, start: usize, capacity: usize) -> StrPlanObj {
        let mut buf = vec![0u8; capacity];
        buf[start..start + text.len()].copy_from_slice(text.as_bytes());
        StrPlanObj {
            hdr: Header::new(KIND_STRPLAN, false),
            buf,
            start,
            end: start + text.len(),
            chars: text.chars().count(),
            ascii: text.is_ascii(),
            consumed: false,
        }
    }

    #[test]
    fn reserve_back_grows_geometrically_and_keeps_data() {
        let mut p = plan("abc", 0, 4);
        assert_eq!(p.reserve_back(1), 0, "fits: nothing moves");
        let moved = p.reserve_back(10);
        assert_eq!(moved, 3);
        assert_eq!(p.data(), b"abc");
        assert!(p.buf.len() >= 2 * (3 + 10));
        assert_eq!(p.start, 0, "append growth leaves no front slack");
    }

    #[test]
    fn reserve_front_grows_toward_the_front() {
        let mut p = plan("xyz", 2, 8);
        assert_eq!(p.reserve_front(2), 0);
        let moved = p.reserve_front(5);
        assert_eq!(moved, 3);
        assert_eq!(p.data(), b"xyz");
        assert_eq!(p.end, p.buf.len(), "prepend growth leaves no back slack");
        assert!(p.start >= 5);
    }

    #[test]
    fn repeated_appends_copy_linearly() {
        // Amortized growth: total bytes moved by regrowth over N one-byte
        // appends stays O(N) (geometric capacity), never O(N^2).
        let mut p = plan("", 0, 1);
        let mut moved = 0;
        for _ in 0..10_000 {
            moved += p.reserve_back(1);
            let end = p.end;
            p.buf[end] = b'a';
            p.end += 1;
        }
        assert_eq!(p.len(), 10_000);
        assert!(moved < 3 * 10_000, "moved {moved} bytes for 10000 appends");
    }

    #[test]
    #[should_panic(expected = "linearity violated")]
    fn a_consumed_plan_cannot_be_read_again() {
        check_live(true);
    }
}
