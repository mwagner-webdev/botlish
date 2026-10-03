//! Allocation pins for the one-allocation String (STRING-ALLOCATION.md).
//!
//! A counting global allocator (per-thread counters, so parallel tests do not
//! disturb each other) proves the structural claims: a dynamic String is one
//! heap allocation and one free, never a block plus a text buffer, for every
//! producer in the runtime.

use super::metrics::{AllocMode, GcReason};
use super::ops::*;
use super::strobj::*;
use super::value::*;
use super::vm::{ProgramInfo, Vm};
use std::alloc::{GlobalAlloc, Layout, System};
use std::cell::Cell;

struct Counting;

thread_local! {
    static ALLOCS: Cell<usize> = const { Cell::new(0) };
    static FREES: Cell<usize> = const { Cell::new(0) };
    static BYTES: Cell<usize> = const { Cell::new(0) };
}

unsafe impl GlobalAlloc for Counting {
    unsafe fn alloc(&self, l: Layout) -> *mut u8 {
        ALLOCS.with(|c| c.set(c.get() + 1));
        BYTES.with(|c| c.set(c.get() + l.size()));
        unsafe { System.alloc(l) }
    }
    unsafe fn dealloc(&self, p: *mut u8, l: Layout) {
        FREES.with(|c| c.set(c.get() + 1));
        unsafe { System.dealloc(p, l) }
    }
    unsafe fn realloc(&self, p: *mut u8, l: Layout, n: usize) -> *mut u8 {
        ALLOCS.with(|c| c.set(c.get() + 1));
        FREES.with(|c| c.set(c.get() + 1));
        BYTES.with(|c| c.set(c.get() + n));
        unsafe { System.realloc(p, l, n) }
    }
}

#[global_allocator]
static COUNTING: Counting = Counting;

/// (allocator calls, frees, bytes requested) of F on this thread.
fn measure<R>(f: impl FnOnce() -> R) -> (R, usize, usize, usize) {
    let (a0, f0, b0) = (ALLOCS.with(Cell::get), FREES.with(Cell::get), BYTES.with(Cell::get));
    let r = f();
    (r, ALLOCS.with(Cell::get) - a0, FREES.with(Cell::get) - f0, BYTES.with(Cell::get) - b0)
}

fn vm() -> Box<Vm> {
    let mut vm = Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }), AllocMode::Off);
    // The heap's own object list grows by doubling; warm it so the measured
    // windows contain only String allocations.
    for _ in 0..600 {
        vm.new_str("warm");
    }
    vm.temp_roots.clear();
    vm
}

fn small(n: i64) -> Value {
    make_small(n)
}

/// One heap allocation of exactly header + text bytes.
fn one_block(allocs: usize, bytes: usize, text_bytes: usize, what: &str) {
    assert_eq!(allocs, 1, "{what}: {allocs} allocations");
    // Header + text, rounded up to the 8-byte alignment (strobj.rs).
    assert_eq!(bytes, (STR_HEADER_SIZE + text_bytes).div_ceil(8) * 8, "{what}: {bytes} bytes requested");
}

#[test]
fn every_nonempty_constructor_is_one_allocation() {
    let mut vm = vm();
    for text in ["a", "hello", "\u{e9}", "\u{2026}", "\u{1f600}", "e\u{301}", "\0", &"x".repeat(100), &"\u{2026}".repeat(40)] {
        let (v, a, _, b) = measure(|| vm.new_str(text));
        one_block(a, b, text.len(), &format!("new_str({text:?})"));
        assert_eq!(str_of(v).as_str(), text);
    }
}

#[test]
fn scalar_materialization_is_one_allocation_of_the_utf8_width() {
    let mut vm = vm();
    for (c, width) in [('a', 1), ('\0', 1), ('\u{e9}', 2), ('\u{2026}', 3), ('\u{1f600}', 4), ('\u{10ffff}', 4)] {
        let (v, a, _, b) = measure(|| rt_short_to_str(&mut *vm, c as u64));
        one_block(a, b, width, &format!("shorttostr({c:?})"));
        assert_eq!(str_of(v).as_str(), c.to_string());
        assert_eq!((str_of(v).chars, str_of(v).len_bytes(), str_of(v).ascii), (1, width, width == 1));
    }
}

#[test]
fn packed_ascii_materialization_is_one_allocation_of_its_length() {
    let mut vm = vm();
    for text in ["a", "ab", "abc", "abcd", "abcde", "abcdef", "abcdefg", "abcdefgh", "\0\0"] {
        let w = pack_ascii(text.as_bytes());
        let (v, a, _, b) = measure(|| rt_ascii_to_str(&mut *vm, w));
        one_block(a, b, text.len(), &format!("asciitostr({text:?})"));
        assert_eq!(str_of(v).as_str(), text);
        assert!(str_of(v).ascii);
    }
}

#[test]
fn empty_is_the_canonical_static_string_and_allocates_nothing() {
    let mut vm = vm();
    let (e1, a, f, _) = measure(|| rt_short_to_str(&mut *vm, (-1i64) as u64));
    assert_eq!((a, f), (0, 0));
    let (e2, a, _, _) = measure(|| rt_ascii_to_str(&mut *vm, 0));
    assert_eq!(a, 0);
    let (e3, a, _, _) = measure(|| vm.new_str(""));
    assert_eq!(a, 0);
    let base = vm.new_str("abc");
    let (e4, a, _, _) = measure(|| rt_substr(&mut *vm, base, small(1), small(1)));
    assert_eq!(a, 0);
    assert!(e1 == e2 && e2 == e3 && e3 == e4);
    assert_eq!(unsafe { (*(e1 as *const Header)).is_static }, 1);
    assert_eq!((str_of(e1).chars, str_of(e1).len_bytes(), str_of(e1).ascii), (0, 0, true));
}

#[test]
fn concat_substring_lower_and_decode_are_one_allocation_each() {
    let mut vm = vm();
    let (ab, cd) = (vm.new_str("héllo"), vm.new_str(" wörld…"));
    let (v, a, _, b) = measure(|| rt_str_cat(&mut *vm, ab, cd));
    one_block(a, b, "héllo wörld…".len(), "concat");
    assert_eq!(str_of(v).as_str(), "héllo wörld…");
    assert_eq!(str_of(v).chars, "héllo wörld…".chars().count());

    // ASCII substring: one allocation, no scan.
    let ascii = vm.new_str("hello world");
    let (v, a, _, b) = measure(|| rt_substr(&mut *vm, ascii, small(3), small(8)));
    one_block(a, b, 5, "ascii substring");
    assert_eq!(str_of(v).as_str(), "lo wo");

    // Non-ASCII substring: still one allocation (a seek and a width scan,
    // both without allocating), flag and counts known.
    let wide = vm.new_str("a\u{e9}\u{2026}\u{1f600}z");
    let (v, a, _, b) = measure(|| rt_substr(&mut *vm, wide, small(1), small(4)));
    one_block(a, b, 2 + 3 + 4, "non-ascii substring");
    assert_eq!(str_of(v).as_str(), "\u{e9}\u{2026}\u{1f600}");
    assert_eq!((str_of(v).chars, str_of(v).ascii), (3, false));
    // A non-ASCII base whose slice is ASCII gets the ASCII flag.
    let (v, a, _, _) = measure(|| rt_substr(&mut *vm, wide, small(4), small(5)));
    assert_eq!(a, 1);
    assert_eq!((str_of(v).as_str(), str_of(v).ascii), ("z", true));

    let mixed = vm.new_str("ÀBC\u{212a}x");
    let (v, a, _, _) = measure(|| rt_str_lower(&mut *vm, mixed));
    assert_eq!(a, 1, "lower of non-ASCII text");
    assert_eq!(str_of(v).as_str(), "àbckx");
    assert_eq!(str_of(v).chars, 5);
    let upper = vm.new_str("HELLO, World");
    let (v, a, _, b) = measure(|| rt_str_lower(&mut *vm, upper));
    one_block(a, b, 12, "lower of ASCII text");
    assert_eq!(str_of(v).as_str(), "hello, world");

    let (v, a, _, b) = measure(|| rt_str_decode_char_at(&mut *vm, wide, small(3)));
    one_block(a, b, 3, "decode_char_at");
    assert_eq!(str_of(v).as_str(), "\u{2026}");
}

#[test]
fn flat_construct_is_one_allocation_whatever_the_piece_count() {
    use super::construct::{TAG_REGION, TAG_SPAN, rt_construct};
    let mut vm = vm();
    let (a, b, c) = (vm.new_str("ab"), vm.new_str("\u{2026}"), vm.new_str("xyz\u{1f600}"));
    let words = [TAG_SPAN, a, TAG_SPAN, b, TAG_REGION, c, small(1), small(4), TAG_SPAN, c];
    let (v, allocs, _, bytes) = measure(|| rt_construct(&mut *vm, 0, words.len() as u64, words.as_ptr()));
    let expect = "ab\u{2026}yz\u{1f600}xyz\u{1f600}";
    one_block(allocs, bytes, expect.len(), "flat construct");
    assert_eq!(str_of(v).as_str(), expect);
    assert_eq!(str_of(v).chars, expect.chars().count());
    assert!(!str_of(v).ascii);
}

#[test]
fn large_strings_are_still_one_block() {
    let mut vm = vm();
    vm.heap.defer_collection_for_test();
    for n in [1usize << 12, 1 << 16, 1 << 20, 3 << 20] {
        let text = "q".repeat(n);
        let (v, a, _, b) = measure(|| vm.new_str(&text));
        one_block(a, b, n, "large new_str");
        assert_eq!(str_of(v).len_bytes(), n);
        vm.temp_roots.push(v);
        let (v2, a, _, b) = measure(|| rt_str_cat(&mut *vm, v, v));
        one_block(a, b, 2 * n, "large concat");
        assert_eq!(str_of(v2).chars, 2 * n);
        vm.temp_roots.push(v2);
        let (v3, a, _, b) = measure(|| rt_substr(&mut *vm, v2, small(1), small(n as i64 + 1)));
        one_block(a, b, n, "large substring");
        assert_eq!(str_of(v3).as_str(), text);
        vm.temp_roots.clear();
    }
}

#[test]
fn collection_frees_one_block_per_string() {
    let mut vm = vm();
    let keep = vm.new_str("kept alive");
    vm.temp_roots.push(keep);
    // Baseline: what a collection frees on its own (its scratch vectors) with
    // nothing new to reclaim beyond the warm-up garbage.
    vm.collect_for_test(GcReason::Explicit);
    let (_, _, base_frees, _) = measure(|| vm.collect_for_test(GcReason::Explicit));
    let n = 50;
    for i in 0..n {
        vm.new_str(&format!("garbage number {i} with a text of some length"));
    }
    let (_, _, frees, _) = measure(|| vm.collect_for_test(GcReason::Explicit));
    assert_eq!(frees - base_frees, n, "one release per String: no second text buffer to free");
    assert_eq!(str_of(keep).as_str(), "kept alive");
    vm.temp_roots.clear();
}

#[test]
fn strings_survive_collection_unchanged() {
    let mut vm = vm();
    let texts = ["", "a", "\0", "\u{2026}", "\u{1f600}", "hello world", "e\u{301}x"];
    let held: Vec<Value> = texts.iter().map(|t| vm.new_str(t)).collect();
    vm.temp_roots.extend(held.iter().copied());
    for _ in 0..3 {
        // Churn: garbage between collections, with the held Strings rooted.
        for i in 0..200 {
            vm.new_str(&format!("garbage {i}"));
        }
        vm.collect_for_test(GcReason::Stress);
    }
    for (v, t) in held.iter().zip(texts) {
        assert_eq!(str_of(*v).as_str(), t);
        assert_eq!(str_of(*v).chars, t.chars().count());
        assert_eq!(str_of(*v).len_bytes(), t.len());
        assert_eq!(str_of(*v).ascii, t.is_ascii());
    }
    vm.temp_roots.clear();
}

#[test]
fn text_is_inline_at_a_constant_offset() {
    let mut vm = vm();
    for text in ["", "a", "\u{1f600}", "0123456789abcdef0123456789abcdef"] {
        let v = vm.new_str(text);
        let o = str_of(v);
        assert_eq!(o.text_ptr() as usize, v as usize + STR_TEXT_OFFSET);
        assert_eq!(o.len_bytes(), text.len());
    }
}

#[test]
fn string_census_counts_objects_frees_and_reused_empties() {
    let mut vm = Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new() }), AllocMode::Summary);
    vm.new_str("abc");
    vm.new_str("");
    vm.new_str_scalar('x');
    vm.collect_for_test(GcReason::Explicit);
    let report = vm.metrics.to_tcl("");
    assert!(report.contains("strings {objects 2 heapAllocations 2 textBufferAllocations 0 frees 2 textBufferFrees 0 bytes 54 emptyReused 1}"), "{report}");
}

// ---------------------------------------------------------------------------
// Property tests: every constructor agrees with a plain-Rust oracle on random
// Unicode text across the layout's boundary lengths.

struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        // xorshift64*
        self.0 ^= self.0 >> 12;
        self.0 ^= self.0 << 25;
        self.0 ^= self.0 >> 27;
        self.0.wrapping_mul(0x2545F4914F6CDD1D)
    }

    fn scalar(&mut self) -> char {
        loop {
            let c = match self.next() % 8 {
                0..=2 => (self.next() % 0x80) as u32,
                3 => 0x80 + (self.next() % 0x780) as u32,
                4 => 0x800 + (self.next() % 0xF800) as u32,
                5 => 0x10000 + (self.next() % 0x100000) as u32,
                6 => [0, 0x7f, 0x80, 0x7ff, 0x800, 0xffff, 0x10000, 0x10ffff, 0x2026][(self.next() % 9) as usize],
                _ => 0x61 + (self.next() % 26) as u32,
            };
            if let Some(c) = char::from_u32(c) {
                return c;
            }
        }
    }

    /// A String of exactly N characters.
    fn text(&mut self, n: usize, ascii_only: bool) -> String {
        (0..n).map(|_| if ascii_only { (self.next() % 0x80) as u8 as char } else { self.scalar() }).collect()
    }
}

const LENGTHS: [usize; 17] = [0, 1, 2, 3, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 300];

fn check(v: Value, expect: &str) {
    let o = str_of(v);
    assert_eq!(o.as_str(), expect);
    assert_eq!(o.len_bytes(), expect.len());
    assert_eq!(o.as_bytes().len(), expect.len());
    assert_eq!(o.chars, expect.chars().count());
    assert_eq!(o.ascii, expect.is_ascii());
    assert_eq!(o.first_scalar(), expect.chars().next().map_or(0, |c| c as u32));
    if expect.is_empty() {
        assert_eq!(unsafe { (*(v as *const Header)).is_static }, 1, "empty is the canonical static String");
    } else {
        assert_eq!(o.text_ptr() as usize, v as usize + STR_TEXT_OFFSET);
    }
}

/// Oracle for `rt_str_lower`: the Unicode 16 *simple* (one-to-one,
/// UnicodeData.txt) lowercase mapping that core::strings::lowercase defines.
/// Deliberately not `char::to_lowercase`'s output taken as-is: that is the
/// full SpecialCasing mapping (U+0130 -> "i" + U+0307, whose simple mapping is
/// plain U+0069) and, in rustc 1.97, Unicode 17 data (which adds lowercase
/// mappings for U+A7CE, U+A7D2, U+A7D4 and U+16EA0..=U+16EB8 that Unicode 16
/// lacks). The facts are spelled out here independently of ops.rs.
fn unicode16_simple_lower(c: char) -> char {
    match c {
        '\u{130}' => 'i',
        '\u{A7CE}' | '\u{A7D2}' | '\u{A7D4}' | '\u{16EA0}'..='\u{16EB8}' => c,
        _ => {
            let mut l = c.to_lowercase();
            match (l.next(), l.next()) {
                (Some(x), None) => x,
                _ => panic!("{c:?} has a multi-scalar lowercase other than U+0130"),
            }
        }
    }
}

#[test]
fn lowercase_is_unicode_16_simple_on_known_facts() {
    let mut vm = vm();
    for (c, want) in [
        ('A', 'a'),
        ('\u{130}', 'i'),        // not the full mapping "i" + U+0307
        ('\u{212A}', 'k'),       // KELVIN SIGN
        ('\u{23A}', '\u{2C65}'), // Tcl 9.0.x leaves it unchanged; the standard maps it
        ('\u{23E}', '\u{2C66}'),
        ('\u{A7CE}', '\u{A7CE}'), // Unicode 17 additions stay unchanged
        ('\u{A7D2}', '\u{A7D2}'),
        ('\u{A7D4}', '\u{A7D4}'),
        ('\u{16EA0}', '\u{16EA0}'),
        ('\u{16EB8}', '\u{16EB8}'),
        ('\u{1E9E}', '\u{DF}'),
        ('\u{10400}', '\u{10428}'),
    ] {
        let v = vm.new_str(&c.to_string());
        vm.temp_roots.push(v);
        let l = rt_str_lower(&mut *vm, v);
        assert_eq!(str_of(l).as_str(), want.to_string(), "lowercase of {c:?}");
        vm.temp_roots.clear();
    }
}

#[test]
fn constructors_agree_with_the_oracle_on_boundary_lengths() {
    let mut vm = vm();
    let mut rng = Rng(0x9E3779B97F4A7C15);
    for &n in &LENGTHS {
        for ascii_only in [true, false] {
            for _ in 0..8 {
                let a = rng.text(n, ascii_only);
                let (bn, bascii) = (rng.next() as usize % 40, rng.next() % 2 == 0);
                let b = rng.text(bn, bascii);
                let (va, vb) = (vm.new_str(&a), vm.new_str(&b));
                vm.temp_roots.extend([va, vb]);
                check(va, &a);
                let cat = rt_str_cat(&mut *vm, va, vb);
                check(cat, &format!("{a}{b}"));
                vm.temp_roots.push(cat);
                let chars: Vec<char> = a.chars().collect();
                let from = (rng.next() as usize) % (chars.len() + 1);
                let to = from + (rng.next() as usize) % (chars.len() - from + 1);
                let sub = rt_substr(&mut *vm, va, small(from as i64), small(to as i64));
                check(sub, &chars[from..to].iter().collect::<String>());
                let lower = rt_str_lower(&mut *vm, va);
                let expect_lower: String = a.chars().map(unicode16_simple_lower).collect();
                check(lower, &expect_lower);
                vm.temp_roots.clear();
            }
        }
    }
}

#[test]
fn one_scalar_materialization_agrees_with_the_oracle_for_every_width() {
    let mut vm = vm();
    let mut rng = Rng(12345);
    let mut scalars: Vec<char> = (0..2000).map(|_| rng.scalar()).collect();
    scalars.extend(['\0', 'a', '\u{7f}', '\u{80}', '\u{7ff}', '\u{800}', '\u{d7ff}', '\u{e000}', '\u{ffff}', '\u{10000}', '\u{10ffff}']);
    for c in scalars {
        let v = rt_short_to_str(&mut *vm, c as u64);
        check(v, &c.to_string());
        let d = vm.new_str_scalar(c);
        check(d, &c.to_string());
    }
}

#[test]
fn packed_ascii_materialization_agrees_with_the_oracle() {
    let mut vm = vm();
    let mut rng = Rng(777);
    for n in 0..=8usize {
        for _ in 0..50 {
            let text = rng.text(n, true);
            let w = pack_ascii(text.as_bytes());
            let v = rt_ascii_to_str(&mut *vm, w);
            check(v, &text);
            // And back: the String packs to the same canonical word.
            assert_eq!(rt_str_to_ascii(&mut *vm, v), w);
        }
    }
}

#[test]
fn piece_concatenation_writes_every_byte_once_in_order() {
    let mut vm = vm();
    let mut rng = Rng(4242);
    for pieces_n in 1..=10usize {
        let texts: Vec<String> = (0..pieces_n)
            .map(|_| {
                let (n, ascii) = (rng.next() as usize % 20, rng.next() % 2 == 0);
                rng.text(n, ascii)
            })
            .collect();
        let slices: Vec<&str> = texts.iter().map(|t| t.as_str()).collect();
        let joined: String = texts.concat();
        let v = vm.new_str_pieces(&slices, joined.chars().count(), joined.is_ascii());
        check(v, &joined);
    }
}
