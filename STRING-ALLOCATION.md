# One allocation per dynamic String

## Outcome

A dynamic native String is now **one heap allocation** holding the object header,
the String's metadata and its UTF-8 bytes. The separate `Box<str>` text buffer is
gone, and with it the two mallocs / two frees per String, the intermediate Rust
`String`/`Vec` most producers built, the pointer chase on every text access, and
the measured `str_text_ptr_offset()` probe of `Box<str>`'s unspecified layout.

| | before | after |
|---|---|---|
| heap allocations per non-empty dynamic String | 2 (`StrObj` + text) | **1** |
| frees per String | 2 | **1** |
| fixed header | 40 bytes (+ allocator bookkeeping of a second block) | **25 bytes** (text follows at offset 25) |
| empty dynamic String | one 40-byte object | the canonical static empty: **0 allocations** |
| cached first scalar in every String | yes (`StrObj::first`) | **removed** (measured: cheaper) |
| `shorttostr` U+0061, full churn life cycle | 862 Ir | **509 Ir (-41%)** |
| allocation side / free side (steady state) | 417 / 296 Ir | **204 / 161 Ir** |
| `refined-checks`, run + free side | 8,849,218 Ir | **6,752,466 (-23.7%)** |
| `ai_text_clean` | 121,022 Ir | **86,425 (-28.6%)** |
| `string_replace` short-regime regression (run window) | +87.7% | **+52.9%** |
| NIR | | **byte-identical** (68/68 corpus files) |
| non-String programs (`fib`, `loop-count`, `sum-refined`, `matmul`) | | **identical** run Ir |

No frontend proof, tier selection, demand rule, NIR, or RawInt behavior changed,
and no frontier heuristic, cache, interning, argv or I/O work was added. Strings
keep their semantics (Unicode scalar values, UTF-8, equality, hashing, errors).

Two things did not improve and are reported plainly in "Known limitations":
`lowercase` of non-ASCII text costs 12% *more* (two mapping passes replace a
temporary buffer), and the tiny `string_reverse` run window is about 2% slower
(four Strings, each now one `memcpy`-per-piece construct) although its free side
and total are better.

## Motivation

The short-String work ended with a measured fact: many of the remaining
regressions are dominated by the cost of falling back to the canonical String, and
that cost was inflated by a general runtime inefficiency. A dynamic String was two
heap objects:

```
StrObj  (Header, chars, ascii, first, Box<str>)   <- 40 bytes, one malloc
   `--> text bytes (the Box<str>)                 <- a second malloc (none for "")
```

The short-String reports measured about 312 instructions per materialization on
the allocation side and about 862 over a full churn life cycle, and proposed a
frontier heuristic calibrated to those numbers. This milestone does the
complementary thing first: make the canonical String intrinsically cheaper so that
any later frontier policy is calibrated against the runtime Botlish ships. The old
~312 / ~862 figures are historical (`SHORT-STRING*.md` carry a forward reference);
**they are not planner constants and none was added** - the new measurements below
are recorded for later, nothing more.

## Starting representation

`StrObj { hdr: Header(8), chars: usize, ascii: bool, first: u32, text: Box<str> }`
(40 bytes), allocated with `Box::new`, its text a second block owned by the `Box<str>`
(none for the empty String). Text access loaded the data pointer from a field whose
position inside the fat pointer Rust does not specify (`str_text_ptr_offset()`
measured it at startup). `free_object` dropped the `Box<StrObj>`, which freed the
text. Producers built a Rust `String`/`Vec` (`to_string`, `collect`, `with_capacity`,
`to_vec`) and moved it into the object.

## New layout

```
offset  size  field
     0     8  hdr        Header { kind, marked, is_static, 5 bytes pad }
     8     8  chars      semantic length (Unicode scalar values)
    16     8  byte_len   UTF-8 length; equals text.len()
    24     1  ascii      all bytes < 0x80 (then chars == byte_len)
    25     n  text       UTF-8 bytes, no terminator
```

`StrObj` (`native/src/runtime/strobj.rs`) is a `#[repr(C)]` custom dynamically
sized type whose last field is the unsized `[u8]` tail. A `&StrObj` is a wide
reference covering header *and* text, so `as_str()`/`as_bytes()` are ordinary safe
Rust; generated code and the GC hold only the thin tagged `Value`, and the wide
pointer is rebuilt from the stored `byte_len` (`StrObj::from_addr`).

### Layout invariants (pinned by tests)

* `STR_HEADER_SIZE == STR_TEXT_OFFSET == 25`; `offset_of!` rejects an unsized tail,
  so the offset is a stated constant `const`-asserted against `offset_of!(ascii) + 1`.
  The text is `[u8]` (alignment 1), so the header is not padded to 8.
* Allocation = `25 + byte_len` rounded **up to a multiple of 8**, aligned to 8
  (`str_layout`, the single place the size is computed; allocation and release both
  use it). The rounding is required for soundness: `size_of_val` of a struct with an
  unsized tail is rounded up to the alignment, so a smaller block would make the wide
  reference claim bytes past it. With glibc the chunk size is identical either way.
  The *accounted* size stays the logical `25 + byte_len`.
* Size arithmetic is overflow-checked (`checked_add`, `Layout::from_size_align`
  rejects sizes beyond `isize::MAX`): an unrepresentable String panics with
  "capacity overflow" (what an oversized `Vec` did), never wraps. The language-level
  limit (`MAX_COLLECTION_LENGTH` characters -> RANGE) is checked before allocating,
  exactly as before. OOM aborts through Rust's allocation-failure path, as the `Box`
  did.
* The text is valid UTF-8 for the object's whole life; it holds no `Value` (the GC
  marks the object, never the bytes). `ascii` implies `chars == byte_len` and the
  converse holds, which is how a constructor that knows both counts derives the flag
  without scanning.
* No cached first scalar: `StrToShort` reads `chars`, then `ascii`, then the byte at
  `obj + 25` (constant offset, no pointer to load), or calls the decode helper for
  non-ASCII. Measured on the single-allocation runtime, recovering it beats caching it
  everywhere (below), so the universal field was removed.
* Header padding: only the 5 spare bytes inside the shared `Header` are unused.

## Construction API and sequence

Only `StrInit` (strobj.rs) creates a String. It allocates the block, writes the
header (`kind`, `chars`, `byte_len`, `ascii`), and then accepts the text **strictly
front to back, by whole UTF-8 pieces** (`push_str`, `push_scalar`, `push_ascii`,
`push_ascii_prefix`), each bounds-checked; `finish` asserts every byte was written.
So the published text is a concatenation of valid UTF-8 pieces with no
uninitialized byte, whatever the caller does: the invariant `as_str` relies on is
established by construction and **no caller needs `unsafe`**. All pointer arithmetic
lives in strobj.rs (`write_scalar`, `write_low_bytes`, `read_low_bytes` are private).

`Vm` constructors (vm.rs) on top of it: `new_str`, `new_str_known` (text already
counted), `new_str_pieces` (concatenation: final size = sum of the pieces, one
allocation, each piece copied once), `new_str_scalar`, `new_str_with` (producers that
know the result size first), `short_to_string`, `ascii_to_string`. Each returns the
canonical static empty String for a zero-byte result.

**Sequence** (`Vm::alloc_str`): (1) enforce `MAX_COLLECTION_LENGTH` on the character
count; (2) run the collection that is due, *before the object exists*, so a
collection never sees a half-built String; (3) the one allocation, header complete,
text empty; (4) register with the heap and account (`header + byte_len` bytes, one
object); (5) the caller pushes the text - nothing between (4) and `finish`
allocates, so no collection can run on the unfinished object. The operands a
constructor reads (concat pieces, a substring's base) are arguments of an allocating
instruction and therefore GC roots at that safepoint (`codegen::roots`: a call's
arguments are in its own live-in set), so they survive step (2) and are readable
afterwards.

### Direct construction

* **ShortString1** (`shorttostr`): width from `len_utf8`, one allocation of exactly
  that many bytes, the scalar encoded straight into the tail. No intermediate `String`.
  `Empty` (-1) returns the canonical empty String.
* **Packed ASCII** (`asciitostr`): length from the presence bits, one allocation of
  `len` bytes, `word & 0x7F7F...` stored with at most two (overlapping) stores
  (`write_low_bytes`): only the relevant bytes are written, no temporary buffer.
* `strtoascii` packs the inline text with at most two loads that never leave it
  (`StrObj::packed_ascii`); no 8-byte overread.
* **concat / flat construct**: allocate the summed size once, copy each piece once.
* **substring**: ASCII - slice known by index, one allocation, one copy. Non-ASCII -
  the existing seek pass (counted as `utf8SeekBytes`) plus one pass over the
  `to - from` scalars to find the byte length, then one copy; the result's `ascii`
  flag follows from `byte_len == chars`, so there is no third pass.
* **lowercase**: ASCII - same size, one pass. Non-ASCII - a sizing pass then a writing
  pass (a mapped scalar can change width), no buffer.
* **Empty**: one canonical static empty String per `Vm` (not interning: one immutable
  object, not in the heap's object list, not a program constant). `substring(s, i, i)`,
  `shorttostr(-1)`, `asciitostr(0)` return it; counted as `emptyReused`. Compile-time
  literals (`""`, `"a"`, `"…"`, `"😀"`, long) stay static constants built once at program
  install with the same one-block layout - no run-time allocation.

### Constructor matrix (every native String producer)

| constructor / path | old heap allocs | new | old temporary / copy | new |
|---|---:|---:|---|---|
| `new_str*` (general API) | 2 | **1** | caller's `String` + move into `Box<str>` | one copy from `&str` |
| `substring` ASCII | 2 | **1** | `to_string()` | one `memcpy` base -> tail |
| `substring` non-ASCII | 4 | **1** | `collect::<String>()` (growth reallocs) + shrink | seek + width scan, one `memcpy` |
| `substring` empty | 1 | **0** | empty object | canonical empty |
| `concat` (`rt_str_cat`) | 2 | **1** | `with_capacity` + 2 `push_str` | 2 copies into the tail |
| flat `construct` (n pieces) | 2 | **1** | `Vec` of all pieces | each piece once |
| plan-mode `construct` | 2 (plan + `Vec`) | 2 (unchanged) | gap buffer | unchanged - a private transient plan, not a canonical String |
| `decodecharat` | 2 | **1** | `c.to_string()` | scalar encoded into tail |
| `shorttostr` (non-empty) | 2 | **1** | `c.to_string()` | scalar encoded into tail |
| `shorttostr` -1 / `asciitostr` 0 | 1 | **0** | | canonical empty |
| `asciitostr` n > 0 | 2 | **1** | `to_vec()` | <= 2 stores |
| `lowercase` ASCII | 4 | **1** | `collect` growth | one pass |
| `lowercase` non-ASCII | 4+ | **1** | `collect` growth | two passes, no buffer |
| program constants (once, at install) | 2 each | 1 each | `clone` + `into_boxed_str` | one copy |

"Old" counts are allocator calls (including reallocs) measured with a counting
global allocator on the parent tree; "new" counts are pinned by the same kind of
test in `native/src/runtime/string_alloc_tests.rs` (every constructor, including
4 KiB - 3 MiB Strings, plus a boundary-length oracle test). No dynamic *canonical*
String path is still two allocations.

## GC, rooting, deallocation

* A String is still one GC object, a normal tagged rootable pointer; stack maps,
  tagging and root liveness are unchanged. ShortString/packed registers remain
  non-root scalars. Marking a String marks the object only; the trailing bytes are
  never scanned (there is nothing to scan). The obsolete `Box<str>` handling is gone.
* Registration is exactly once (`Vm::alloc_str`); static objects stay excluded
  (`is_static`); accounting counts one object of `header + byte_len` bytes.
* `heap::free_object` -> `free_str`: reads `byte_len`, deallocates the block with the
  layout it was allocated with. No Rust destructor runs for a String (it owns
  nothing), so there is no double free by construction.
* Safepoints/root candidates/root slots: **unchanged**, because the NIR is unchanged
  and they are computed from it. Across the corpus (default configuration) the root
  reports are textually identical for all 68 files; totals: 603 safepoints, 1,262 root
  candidates, 800 shadow slots.

## Verification

| check | result |
|---|---|
| Rust tests (`cargo test --release`) | 135 lib + 28 bin pass: layout, boundary lengths 0-1 MiB, NUL/U+10FFFF/combining/ellipsis, writer invariants, counting-allocator pins (1 alloc / 1 free per String for every constructor), oracle tests over random Unicode |
| Miri (nightly) on `strobj` | 15/15 pass (reported "leaks" are the three intentional `should_panic` tests that abandon an unpublished block) |
| `tests/string-allocation.test` (new) | 24/24: allocation census pins, Unicode/NUL/empty/large parity across interp, compile, cranelift, cranelift-generic and native with the short tiers and demand rule on/off, GC stress, standalone executables incl. GC stress |
| full Tcl regression, interp backend | 3880/3880 |
| full Tcl regression, compile backend | 3876 passed, 4 skipped (the usual skips), 0 failed |
| differential fuzz, existing short-String generator | 0 disagreements: 1,500 default + 500 GC-stress + 300 specialization-off programs |
| differential fuzz, new general-construction generator (`fuzz-general.tcl`) | 800 default + 400 GC-stress + 300 specialization-off: the only 2 disagreements are the pre-existing region-equality `NATIVE BUG` below (identical at the parent commit) |
| helpers byte-identical to the measured build | the String helpers' machine code (`rt_*`) compared by disassembly: identical |
| GC-stress full suite / native-coverage | pass / one pre-existing failure: see "CI-equivalent runs" |

### Tests whose expectations changed

All changes are consequences of the new representation, none unexpected:

| test | change | class |
|---|---|---|
| `native-alloc.test` `alloc-live-1` | 42 -> 27 bytes for `concat("a","b")` (header 40 -> 25) | expected: header/accounting size |
| `native-string-region.test` `region-bounds-empty-1` | allocations 1 -> 0 for `substring("hello",2,2)` | expected: the empty String is the canonical static |
| Rust `short_encoding_is_the_scalar_value_and_empty_is_minus_one` | `shorttostr(-1)` twice now gives the *same* object | expected: canonical empty (non-empty values are still fresh) |

## Measurements

Instruction counts are callgrind figures (deterministic); both runtimes run the
*same NIR* (byte-identical across the parent and this tree). "Run" is the timed
program window; "reset" is the between-run `Vm::reset` that frees what the run
allocated (the free side the timed window excludes); run + reset is the whole life
cycle of a run's Strings. Wall-clock is not used as evidence.

### Cached versus recovered first scalar

Both designs were measured on the single-allocation runtime (`short-first-recovered`
was the existing counterfactual; this table is from the stage with a 32-byte header,
the other variable being only whether `finish` stores/computes the first scalar):

| program | cached run Ir | recovered run Ir | delta |
|---|---:|---:|---:|
| refined-checks | 5,717,054 | 5,256,040 | -8.06% |
| uri-steady | 38,921,627 | 37,849,918 | -2.75% |
| source-checks | 71,136 | 69,461 | -2.36% |
| string_reverse | 11,780 | 11,556 | -1.90% |
| csv_records | 98,375 | 96,697 | -1.71% |
| string_replace | 18,003 | 17,761 | -1.34% |
| ai_text_clean | 66,365 | 66,632 | +0.40% |
| hashtable | 11,732 | 11,732 | 0 |

With the text inline, recovering the first scalar is a load at a constant offset, so
the cached field only taxed every construction (a store plus, for non-ASCII text, a
decode). The universal field was removed and the cargo feature with it. Cost: whole
corpus machine code +420 bytes (+0.41%), the branchy inline `StrToShort` replacing the
two-load cached version (see "Code size").

### Materialization microbenchmarks

`audit/string-allocation/tools/materialize.py` (loop of `shorttostr`/`asciitostr` +
`strlen`, control loop subtracted). *alloc* = steady-state allocation side (no
collection in the window, arena reused); *free* = the between-run reset; *churn* =
allocation, sweep and free interleaved in a churn heap (20,000 -> 40,000 iterations,
the method behind the old 862). The old-runtime churn figure for U+0061 reproduces the
documented **862.0**.

### Materialization (instructions per materialization; control loop subtracted)

| value | alloc side old | new | free side old | new | churn life cycle old | new | Δ life cycle |
|---|---:|---:|---:|---:|---:|---:|---:|
| scalar U+0061 | 416.6 | 204.2 | 295.9 | 161.0 | 862.0 | 509.2 | -40.93% |
| scalar U+2026 | 457.6 | 240.2 | 295.9 | 161.0 | 878.8 | 616.6 | -29.83% |
| scalar U+1F600 | 462.6 | 243.2 | 295.9 | 161.0 | 872.6 | 606.4 | -30.50% |
| scalar Empty | 220.2 | 21.0 | 161.0 | 0.0 | 481.3 | 21.0 | -95.64% |
| packed ASCII length 0 | 249.6 | 39.0 | 161.0 | 0.0 | 510.3 | 39.0 | -92.36% |
| packed ASCII length 1 | 386.6 | 251.2 | 295.9 | 161.0 | 832.0 | 556.1 | -33.16% |
| packed ASCII length 2 | 388.6 | 254.2 | 295.9 | 161.0 | 821.6 | 644.9 | -21.50% |
| packed ASCII length 4 | 385.6 | 255.2 | 295.9 | 161.0 | 795.6 | 618.5 | -22.26% |
| packed ASCII length 8 | 382.9 | 251.2 | 295.9 | 161.0 | 753.1 | 569.4 | -24.39% |

### Exclusive-Ir breakdown of one `shorttostr` U+0061 (instructions)


allocation side (steady state):

| part | old | new |
|---|---:|---:|
| allocator (glibc) | 187.3 | 95.2 |
| free (glibc) | 0.3 | 0.0 |
| Rust allocator shims | 34.0 | 17.0 |
| memcpy/memmove | 16.0 | 0.0 |
| runtime constructors | 175.0 | 88.0 |
| generated code (loop + strlen) | 4.0 | 4.0 |
| **total** | 416.6 | 204.2 |

free side (between-run reset):

| part | old | new |
|---|---:|---:|
| free (glibc) | 245.9 | 123.0 |
| Rust allocator shims | 10.0 | 5.0 |
| GC bookkeeping + free_object | 40.0 | 33.0 |
| **total** | 295.9 | 161.0 |

churn life cycle:

| part | old | new |
|---|---:|---:|
| allocator (glibc) | 252.4 | 214.1 |
| free (glibc) | 328.6 | 155.0 |
| Rust allocator shims | 44.0 | 22.0 |
| memcpy/memmove | 16.0 | 0.0 |
| runtime constructors | 175.0 | 88.0 |
| GC bookkeeping + free_object | 42.0 | 26.0 |
| generated code (loop + strlen) | 4.0 | 4.0 |
| other | 0.1 | 0.1 |
| **total** | 862.0 | 509.2 |

malloc / free calls per materialization (U+0061): old 2.00 / 2.00, new 1.00 / 1.00

What remains after removing the second allocation: of the 509 Ir churn life cycle of
one `shorttostr`, glibc `malloc`+`free` is 369 (73%), runtime constructor code 88,
GC bookkeeping 26, Rust allocator shims 22 (the shim chain `__rust_alloc` ->
`__rdl_alloc` -> `malloc` halved with the call count). `memcpy` is eliminated (16 -> 0).
The largest remaining component is the allocator itself; the length of a packed-ASCII
String barely matters (251-255 Ir alloc side for 1-8 bytes), and the scalar width adds
about 36 Ir for U+2026/U+1F600 (multi-byte encode). The empty values (`Empty`, packed
length 0) now cost 21-39 Ir and nothing to free.

### Per-constructor cost

| constructor | alloc side old | new | free side old | new | life cycle old | new | Δ | malloc calls old | new |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| concat ASCII 5+5 bytes | 445.2 | 345.4 | 295.9 | 161.0 | 797.5 | 644.3 | -19.22% | 2.78 | 1.44 |
| concat non-ASCII 6+10 bytes | 443.2 | 342.2 | 295.9 | 161.0 | 735.7 | 592.3 | -19.49% | 2.78 | 1.44 |
| substring ASCII [3,8) | 424.9 | 341.8 | 295.9 | 161.0 | 824.5 | 691.5 | -16.13% | 2.78 | 1.45 |
| substring non-ASCII [1,4) | 1059.9 | 471.2 | 295.9 | 161.0 | 1420.8 | 779.4 | -45.15% | 5.46 | 1.45 |
| substring empty [2,2) | 285.2 | 115.0 | 161.0 | 0.0 | 545.9 | 115.0 | -78.93% | 1.45 | 0.00 |
| lowercase ASCII 12 bytes | 1743.1 | 448.2 | 295.9 | 161.0 | 2078.7 | 730.8 | -64.84% | 5.46 | 1.44 |
| lowercase non-ASCII | 1747.1 | 2054.2 | 295.9 | 161.0 | 2107.9 | 2362.5 | +12.08% | 5.46 | 1.44 |
| decode_char_at U+2026 | 450.9 | 263.2 | 295.9 | 161.0 | 872.6 | 639.5 | -26.72% | 2.78 | 1.44 |
| flat construct, 3 pieces | 1128.4 | 1128.9 | 295.9 | 161.0 | 1420.9 | 1366.1 | -3.86% | 2.78 | 1.45 |

The flat 3-piece `construct` shows no alloc-side change because its cost is dominated
by the region piece's UTF-8 seek, not by allocation. Lowercase of non-ASCII text is
the one constructor that got slower (+12%): two `to_lowercase` mapping passes now
replace a temporary `String`. (ASCII lowercase, the common case, is -65%.)

### Corpus dynamic instructions


### Default configuration (tiered short Strings + demand rule), String programs

| program | run Ir old | run Ir new | Δ | free-side (reset) Ir old | new | Δ | run+reset old | run+reset new | Δ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| refined-checks | 6,827,454 | 5,649,379 | -17.25% | 2,021,764 | 1,103,086 | -45.44% | 8,849,218 | 6,752,466 | -23.69% |
| source-checks | 73,899 | 70,419 | -4.71% | 39,591 | 36,763 | -7.14% | 113,490 | 107,182 | -5.56% |
| uri-steady | 42,867,597 | 38,897,139 | -9.26% | 4,887,383 | 3,278,474 | -32.92% | 47,754,980 | 42,175,612 | -11.68% |
| ai_text_clean | 86,566 | 66,499 | -23.18% | 34,455 | 19,926 | -42.17% | 121,022 | 86,425 | -28.59% |
| string_replace | 22,649 | 18,552 | -18.09% | 11,724 | 7,047 | -39.89% | 34,374 | 25,599 | -25.53% |
| hashtable | 11,741 | 11,732 | -0.08% | 2,905 | 2,919 | +0.50% | 14,646 | 14,651 | +0.04% |
| csv | 19,650 | 19,291 | -1.83% | 5,586 | 4,703 | -15.80% | 25,236 | 23,994 | -4.92% |
| csv_chunked | 19,558 | 19,169 | -1.99% | 7,251 | 6,413 | -11.56% | 26,809 | 25,582 | -4.58% |
| csv_geometric | 19,679 | 19,416 | -1.34% | 6,910 | 6,183 | -10.53% | 26,589 | 25,599 | -3.72% |
| csv_records | 99,640 | 98,151 | -1.49% | 22,747 | 20,361 | -10.49% | 122,386 | 118,513 | -3.17% |
| string_reverse | 11,480 | 11,719 | +2.08% | 3,268 | 2,858 | -12.55% | 14,748 | 14,576 | -1.16% |
| lex-strategy | 314,496 | 294,224 | -6.45% | 117,261 | 90,516 | -22.81% | 431,757 | 384,740 | -10.89% |
| test-selection | 33,639 | 33,728 | +0.26% | 13,981 | 13,986 | +0.04% | 47,619 | 47,713 | +0.20% |

### Default configuration, non-String controls

| program | run Ir old | run Ir new | Δ | free-side (reset) Ir old | new | Δ | run+reset old | run+reset new | Δ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| fib | 1,404,178 | 1,404,178 | +0.00% | 1,333 | 1,337 | +0.30% | 1,405,511 | 1,405,515 | +0.00% |
| loop-count | 12,037 | 12,037 | +0.00% | 1,413 | 1,417 | +0.28% | 13,450 | 13,454 | +0.03% |
| sum-refined | 12,435 | 12,435 | +0.00% | 1,413 | 1,417 | +0.28% | 13,848 | 13,852 | +0.03% |
| matmul | 9,240 | 9,240 | +0.00% | 5,199 | 5,206 | +0.13% | 14,439 | 14,446 | +0.05% |

### `-short-string-opt 0` (no short Strings: ordinary Strings only)

| program | run Ir old | run Ir new | Δ | free-side (reset) Ir old | new | Δ | run+reset old | run+reset new | Δ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| refined-checks | 6,826,246 | 5,650,851 | -17.22% | 2,021,128 | 1,102,631 | -45.44% | 8,847,374 | 6,753,483 | -23.67% |
| source-checks | 73,899 | 70,419 | -4.71% | 39,591 | 36,763 | -7.14% | 113,490 | 107,182 | -5.56% |
| uri-steady | 42,867,597 | 38,897,139 | -9.26% | 4,887,383 | 3,278,474 | -32.92% | 47,754,980 | 42,175,612 | -11.68% |
| ai_text_clean | 188,212 | 178,812 | -4.99% | 20,247 | 12,193 | -39.78% | 208,459 | 191,005 | -8.37% |
| string_replace | 12,068 | 12,136 | +0.56% | 3,151 | 2,538 | -19.45% | 15,219 | 14,674 | -3.58% |
| hashtable | 11,741 | 11,732 | -0.08% | 2,905 | 2,919 | +0.50% | 14,646 | 14,651 | +0.04% |
| csv | 19,571 | 19,224 | -1.77% | 5,586 | 4,814 | -13.82% | 25,157 | 24,038 | -4.45% |
| csv_chunked | 19,558 | 19,169 | -1.99% | 7,251 | 6,403 | -11.69% | 26,809 | 25,572 | -4.61% |
| csv_geometric | 19,679 | 19,416 | -1.34% | 6,910 | 6,183 | -10.53% | 26,589 | 25,599 | -3.72% |
| csv_records | 99,639 | 97,807 | -1.84% | 22,737 | 20,291 | -10.76% | 122,376 | 118,098 | -3.50% |
| string_reverse | 11,480 | 11,719 | +2.08% | 3,268 | 2,858 | -12.55% | 14,748 | 14,576 | -1.16% |
| lex-strategy | 314,496 | 294,224 | -6.45% | 117,261 | 90,516 | -22.81% | 431,757 | 384,740 | -10.89% |
| test-selection | 33,639 | 33,728 | +0.26% | 13,981 | 13,986 | +0.04% | 47,619 | 47,713 | +0.20% |

### `-ascii-pack-opt 0` (ShortString1 only)

| program | run Ir old | run Ir new | Δ | free-side (reset) Ir old | new | Δ | run+reset old | run+reset new | Δ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| refined-checks | 6,826,246 | 5,650,851 | -17.22% | 2,021,128 | 1,102,631 | -45.44% | 8,847,374 | 6,753,483 | -23.67% |
| source-checks | 73,899 | 70,419 | -4.71% | 39,591 | 36,763 | -7.14% | 113,490 | 107,182 | -5.56% |
| uri-steady | 42,867,597 | 38,897,139 | -9.26% | 4,887,383 | 3,278,474 | -32.92% | 47,754,980 | 42,175,612 | -11.68% |
| ai_text_clean | 86,566 | 66,499 | -23.18% | 34,455 | 19,926 | -42.17% | 121,022 | 86,425 | -28.59% |
| string_replace | 12,068 | 12,136 | +0.56% | 3,151 | 2,538 | -19.45% | 15,219 | 14,674 | -3.58% |
| hashtable | 11,741 | 11,732 | -0.08% | 2,905 | 2,919 | +0.50% | 14,646 | 14,651 | +0.04% |
| csv | 19,799 | 19,444 | -1.79% | 5,586 | 4,814 | -13.82% | 25,385 | 24,258 | -4.44% |
| csv_chunked | 19,558 | 19,169 | -1.99% | 7,251 | 6,413 | -11.56% | 26,809 | 25,582 | -4.58% |
| csv_geometric | 19,679 | 19,416 | -1.34% | 6,910 | 6,203 | -10.24% | 26,589 | 25,619 | -3.65% |
| csv_records | 99,663 | 97,722 | -1.95% | 22,737 | 20,391 | -10.32% | 122,400 | 118,113 | -3.50% |
| string_reverse | 11,480 | 11,719 | +2.08% | 3,268 | 2,858 | -12.55% | 14,748 | 14,576 | -1.16% |
| lex-strategy | 314,496 | 294,224 | -6.45% | 117,261 | 90,516 | -22.81% | 431,757 | 384,740 | -10.89% |
| test-selection | 33,639 | 33,728 | +0.26% | 13,981 | 13,986 | +0.04% | 47,619 | 47,713 | +0.20% |

Non-String programs are instruction-identical in the timed window; their reset
column differs by 4 instructions (code layout of the collector loop), noise.
Every String program improves in the whole life cycle except `hashtable` (+0.04%,
5 Ir, its Strings are static constants) and `test-selection` (+0.20%, 94 Ir of 47,619;
essentially no dynamic Strings). Largest winners: `ai_text_clean` -28.6%,
`string_replace` -25.5%, `refined-checks` -23.7%, `uri-steady` -11.7%, `lex-strategy`
-10.9%. The only run-window regression is `string_reverse` (+2.1%, see Known
limitations); its total is -1.2%.

### Allocator calls inside the window

| program | malloc calls old | malloc calls new | free calls (reset) old | free calls (reset) new |
|---|---:|---:|---:|---:|
| refined-checks | 33,056 | 19,803 | 28,886 | 19,802 |
| source-checks | 2,743 | 2,401 | 2,501 | 2,472 |
| uri-steady | 119,353 | 89,345 | 109,791 | 88,450 |
| ai_text_clean | 2,611 | 2,491 | 2,611 | 2,491 |
| string_replace | 2,195 | 2,147 | 2,194 | 2,147 |
| hashtable | 10,963 | 10,959 | 11,267 | 11,263 |
| csv | 4,947 | 4,956 | 5,116 | 5,125 |
| csv_chunked | 8,510 | 8,518 | 8,770 | 8,778 |
| csv_geometric | 7,351 | 7,359 | 7,609 | 7,617 |
| csv_records | 21,376 | 21,366 | 22,060 | 22,050 |
| string_reverse | 741 | 735 | 740 | 735 |
| lex-strategy | 4,588 | 4,334 | 4,171 | 3,932 |
| test-selection | 3,117 | 3,109 | 3,214 | 3,207 |

(`malloc` includes `calloc`/`realloc`; the old runtime's reallocs for growing
`String`s are part of why `uri-steady` loses 30,000 calls although it builds 16,000
Strings.)

### Short-String regime under each runtime

| program | A off old | B old | B−A old | A off new | B new | B−A new | C demand-off old | C new | C−A old | C−A new |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| refined-checks | 8,847,374 | 8,849,218 | +0.02% | 6,753,483 | 6,752,466 | -0.02% | 13,714,228 | 9,302,338 | +55.01% | +37.74% |
| source-checks | 113,490 | 113,490 | +0.00% | 107,182 | 107,182 | +0.00% | 158,805 | 129,422 | +39.93% | +20.75% |
| uri-steady | 47,754,980 | 47,754,980 | +0.00% | 42,175,612 | 42,175,612 | +0.00% | 46,541,990 | 41,107,837 | -2.54% | -2.53% |
| ai_text_clean | 208,459 | 121,022 | -41.94% | 191,005 | 86,425 | -54.75% | 121,022 | 86,425 | -41.94% | -54.75% |
| string_replace | 15,219 | 34,374 | +125.86% | 14,674 | 25,599 | +74.45% | 37,067 | 26,860 | +143.55% | +83.04% |
| hashtable | 14,646 | 14,646 | +0.00% | 14,651 | 14,651 | +0.00% | 29,628 | 23,737 | +102.30% | +62.01% |
| csv | 25,157 | 25,236 | +0.31% | 24,038 | 23,994 | -0.18% | 25,385 | 23,948 | +0.91% | -0.37% |
| csv_chunked | 26,809 | 26,809 | +0.00% | 25,572 | 25,582 | +0.04% | 26,809 | 25,582 | +0.00% | +0.04% |
| csv_geometric | 26,589 | 26,589 | +0.00% | 25,599 | 25,599 | +0.00% | 26,589 | 25,618 | +0.00% | +0.08% |
| csv_records | 122,376 | 122,386 | +0.01% | 118,098 | 118,513 | +0.35% | 133,387 | 124,854 | +9.00% | +5.72% |
| string_reverse | 14,748 | 14,748 | +0.00% | 14,576 | 14,576 | +0.00% | 14,748 | 14,576 | +0.00% | +0.00% |
| lex-strategy | 431,757 | 431,757 | +0.00% | 384,740 | 384,740 | +0.00% | 431,757 | 384,740 | +0.00% | +0.00% |
| test-selection | 47,619 | 47,619 | +0.00% | 47,713 | 47,713 | +0.00% | 47,619 | 47,713 | +0.00% | +0.00% |

(Run + reset. A = `-short-string-opt 0`, B = defaults, C = `-short-demand-opt 0`.)

**`string_replace`.** In the timed run window the short-String regime cost
+87.7% (12,068 -> 22,649 Ir) on the old runtime and costs **+52.9%** (12,136 -> 18,552)
on the new one; counting the free side, +125.9% -> +74.5%. The absolute extra work of
the 35 materializations fell from 10,581 to 6,416 Ir in the run window (-39%), i.e.
about 40% of the old regression was the two-allocation String; the remainder
(~183 Ir per materialization on the allocation side, ~129 on the free side) is the
price of the allocation itself and of a frontier the demand rule cannot see (a cheap
scalar `length` use per packed parameter, materialized 35 times). The regression is
not eliminated, as expected; **the demand rule is unchanged** and no allocation-weighted
heuristic was added.

**`uri-steady`.** Under the default rule the position stays tagged on both runtimes
(B = A, same NIR). With the demand rule off (C), representation elimination is worth
-2.54% on the old runtime and -2.53% on the new: the absolute saving fell only from
1,212,990 to 1,067,775 Ir. So what remains of its short-String gain is a real
representation-elimination win (transient one-character Strings not built), not an
artifact of the two-allocation runtime, but a small one: the large first-milestone
figure (-16.6%) came from an interned table that no longer exists.

**`ai_text_clean`** (the positive control) *improves*: A -> B is -41.9% on the old
runtime and **-54.8%** on the new one. **`refined-checks`/`source-checks`/`hashtable`**:
B = A under the demand rule (no change from the regime), and the categorical
configuration C, which is the pathological frontier shape, drops from +55.0% to
+37.7%, +39.9% to +20.8%, and +102.3% to +62.0% respectively: roughly a third to a half
of those regressions was allocation cost. **CSV family**: -3.2% to -4.9% whole life
cycle, regime-neutral. Ordinary String code with **no short Strings at all**
(`-short-string-opt 0`) benefits independently: `refined-checks` -23.7%, `uri-steady`
-11.7%, `ai_text_clean` -8.4%, `lex-strategy` -10.9%, the CSV family -3.5% to -4.6%.
With `-ascii-pack-opt 0` the picture is the same (tables above).

### Large String control

`audit/string-allocation/programs/large-string.bot` (doubling to ~2.5 MB, rotate by
slicing and re-concatenating, 5,000 mid-size churn iterations): 10,033 Strings,
20,066 -> 10,033 heap allocations, 9,267,924 -> 9,117,429 bytes, 32,869 -> 17,815
mallocs per run, **-13.4%** Ir over the life cycle (run -11.2%, free side -32.6%).
Large Strings are one block and the copy cost (each byte written once) is unchanged.

### String census (objects, allocations, bytes, frees)

`census.py`: "old" is the parent runtime with `old-census.patch`, which counts its
text buffers exactly. Text-buffer allocations and frees are structurally zero in the new
runtime (`strings.textBufferAllocations`/`textBufferFrees` in the allocation report;
the *measured* proof is the counting-allocator tests and the malloc counts above).


## default

| program | String objects old | String objects new | heap allocs old | heap allocs new | text-buffer allocs old | text-buffer allocs new | frees old | frees new | bytes old | bytes new | empty reuses |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| ai_text_clean | 109 | 109 | 218 | 109 | 109 | 0 | 218 | 109 | 4534 | 2899 | 0 |
| csv | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_chunked | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_geometric | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_records | 18 | 18 | 36 | 18 | 18 | 0 | 36 | 18 | 792 | 522 | 0 |
| lex-strategy | 198 | 198 | 396 | 198 | 198 | 0 | 396 | 198 | 8121 | 5151 | 0 |
| refined-checks | 6807 | 6807 | 13614 | 6807 | 6807 | 0 | 13614 | 6807 | 279497 | 177392 | 0 |
| source-checks | 21 | 21 | 42 | 21 | 21 | 0 | 42 | 21 | 864 | 549 | 0 |
| string_replace | 35 | 32 | 67 | 32 | 32 | 0 | 67 | 32 | 1501 | 901 | 3 |
| string_reverse | 4 | 4 | 8 | 4 | 4 | 0 | 8 | 4 | 174 | 114 | 0 |
| uri-steady | 16000 | 16000 | 32000 | 16000 | 16000 | 0 | 32000 | 16000 | 686000 | 446000 | 0 |
| **total** | 23210 | 23207 | 46417 | 23207 | 23207 | 0 | 46417 | 23207 | 982260 | 634035 | 3 |

## off

| program | String objects old | String objects new | heap allocs old | heap allocs new | text-buffer allocs old | text-buffer allocs new | frees old | frees new | bytes old | bytes new | empty reuses |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| ai_text_clean | 61 | 61 | 122 | 61 | 61 | 0 | 122 | 61 | 2566 | 1651 | 0 |
| csv | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_chunked | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_geometric | 6 | 6 | 12 | 6 | 6 | 0 | 12 | 6 | 259 | 169 | 0 |
| csv_records | 18 | 18 | 36 | 18 | 18 | 0 | 36 | 18 | 792 | 522 | 0 |
| lex-strategy | 198 | 198 | 396 | 198 | 198 | 0 | 396 | 198 | 8121 | 5151 | 0 |
| refined-checks | 6804 | 6804 | 13608 | 6804 | 6804 | 0 | 13608 | 6804 | 279368 | 177308 | 0 |
| source-checks | 21 | 21 | 42 | 21 | 21 | 0 | 42 | 21 | 864 | 549 | 0 |
| string_replace | 5 | 3 | 8 | 3 | 3 | 0 | 8 | 3 | 208 | 83 | 2 |
| string_reverse | 4 | 4 | 8 | 4 | 4 | 0 | 8 | 4 | 174 | 114 | 0 |
| uri-steady | 16000 | 16000 | 32000 | 16000 | 16000 | 0 | 32000 | 16000 | 686000 | 446000 | 0 |
| **total** | 23129 | 23127 | 46256 | 23127 | 23127 | 0 | 46256 | 23127 | 978870 | 631885 | 2 |

Per-String memory: fixed header 40 -> 25 bytes (the old text block's own allocator
bookkeeping is additionally gone); the minimum dynamic allocation is 32 bytes (25
rounded to 8) for a 1-byte String versus two blocks before. These are Rust object
sizes; glibc's 8-byte chunk overhead and 16-byte rounding are a separate allocator
effect that is not counted here.
Collocation of metadata and bytes is a fact of the layout; no cache win is claimed
(no cache measurement was made).

### Code size, runtime size, compile time

* Whole canonical corpus machine code (17 programs, 233 functions, identical NIR):
  **101,435 -> 101,855 bytes (+420, +0.41%)**. The whole delta is the inline
  `StrToShort` (the branchy no-cached-first form): `ai_text_clean` +40, `csv` family
  +95 each, everything else +0 (`fib`, `hashtable`, `refined-checks`, `uri-steady`...).
* Runtime/driver binary: `.text` 6,137,671 -> 6,140,807 (+3,136, +0.05%), `.rodata`
  +136; file size -6,984 bytes. The per-program numbers are not improved by moving
  code into the runtime (constructor logic is shared runtime code).
* Compile time (Cranelift, median of 7, summed over the corpus; machine under load so
  noise-level): 122,750 -> 122,001 us (-0.6%). The planner and NIR lowering are Tcl code
  and untouched (`git diff` of non-test Tcl is a two-line comment in `native.tcl`).
* NIR: byte-identical, all four configurations of all 17 programs.

## Architecture

The String storage is below NIR: frontend proof and NIR physical representation are
independent of the runtime heap layout. Cranelift and a future LLVM backend consume the
same NIR; the only generated-code change is the inline `StrToShort` reading the byte at
a constant offset. No proof, tier selection, demand rule, RawInt behavior or interpreter
code changed. The reference interpreter and the Tcl compile backend keep their own String
storage and serve as ground truth.

## Known limitations

* **`lowercase` of non-ASCII text is 12% slower** (+255 Ir over the life cycle for the
  measured 6-scalar string): sizing needs a mapping pass and writing a second. A bounded stack buffer for
  short inputs would remove it; deferred as a rare path.
* **Tiny programs can regress in the run window**: `string_reverse` +2.1% (+239 of 11.5k
  Ir, four Strings, each a flat construct whose per-piece copy is now a `memcpy` call into
  the tail); its free side is -12.6% and total -1.2%. A short-piece inline copy would
  recover it.
* **`string_replace` still pays +52.9% for the short regime** (was +87.7%); the demand
  rule cannot see 35 materializations of a cheaply-length-used parameter. This is the
  deferred frontier question.
* **Allocator dominated**: 73% of what a materialization costs now is glibc
  `malloc`/`free`; no cache, interning or custom allocator was added by design.
* **Plan-mode `construct`** (private transient `StrPlanObj`) still uses an object plus a
  `Vec`; it is not a canonical String and was out of scope.
* **Pre-existing bugs found by the new fuzzer, reproducible at the parent commit and not
  fixed here** (queued as separate tasks): `lowercase("İ")` (U+0130) was `i` on the Tcl
  backends but unchanged on native (Rust's lowercase of it is two characters; since fixed
  in `rt_str_lower`, and U+0130 is back in the fuzzer's literal pool); and a
  substring result compared with another String-region binding (`v == v`, and shapes like
  `first_half(x) == y`) fails native lowering with `{NATIVE BUG} region binding ...
  referenced outside a recognized consumer`. The fuzzer excludes `v == v`
  and its two remaining disagreements are the second bug.
* Miri validates `strobj.rs` only (the rest of the crate needs the JIT and stack walker).

## Future argv / I/O and the deferred frontier

Nothing here designs for argv, environment or I/O (none was implemented). What it
gives them: a canonical owned String that is cheap to build from bytes already in hand
(`new_str_known`/`push_str`) and a UTF-8 validity boundary that is explicit - external
text must be validated *before* it reaches `StrInit` (constructors take `&str`, so Rust
types already enforce it). The weighted frontier heuristic is explicitly **not**
implemented. The new measured costs - allocation side 204-255, free side 161, churn life
cycle 509-645 Ir per non-empty materialization, 21-39 for empty - are *measurements for
later, not planner constants*; they should be calibrated against real argv/I/O
workloads first.

## Answers to the required questions

**Representation.** 1. A `Box<StrObj>` (40 bytes) plus a separately allocated `Box<str>`
text (none for ""). 2. One block: 25-byte header + inline UTF-8, padded to 8. 3. One
(zero for empty and for program constants at run time). 4. Immediately after the header,
at offset 25. 5. The declared constant `STR_TEXT_OFFSET` (asserted to equal the end of
the `ascii` field). 6. `25 + byte_len` rounded up to a multiple of 8, overflow-checked
(`str_layout`). 7. 8. 8. `byte_len: usize` at offset 16 (it is also the wide-pointer
metadata). 9. `chars: usize` at offset 8. 10. Yes (`ascii`, offset 24): still used by
substring/equality/region fast paths. 11. No; it was measured against recovering it and
removed. 12. No unspecified Rust layout is relied on (`repr(C)` header; the tail offset
is const-asserted; the one language guarantee used is the defined `*mut [u8] as *mut StrObj`
cast of a slice-tailed struct). 13. No. 14. Yes: `StrObj::as_str()` is safe. 15. `free_str`:
one `dealloc` with `str_layout(byte_len)`.

**Construction.** 16. ASCII: `push_str` of the known text, one copy. 17. Non-ASCII: same,
with the char count and flag known or derived (`byte_len == chars`). 18. `push_scalar`
encodes directly into the tail. 19. `push_ascii_prefix`: word & 0x7F.. in at most two
stores. 20. No intermediate Rust `String` in either tier. 21. No: pieces are copied
directly into the final tail. 22. Yes, one (ASCII: one copy; non-ASCII: a seek, a width
scan, one copy). 23. Non-ASCII substring and non-ASCII lowercase walk the source more
than once but write each output byte once; no path copies output bytes more than once.
24. No canonical String path; plan-mode construct objects are transient and unchanged.
25. -

**GC.** 26. Yes. 27. No. 28. In `Vm::alloc_str` after the (possible) collection and the
single allocation, before the text is written, with no allocation in between. 29. `free_object`
-> `free_str`, one deallocation. 30. Small and large Strings pass the Rust, Tcl and fuzz GC-stress
runs (full-suite stress: see "CI-equivalent runs"). 31. No change (NIR unchanged). 32. No change (identical root
reports). 33. Not applicable: nothing changed.

**Cost.** 34. ~417 Ir (steady state, U+0061); 35. ~204. 36. 862. 37. 509. 38. glibc
allocation 187 -> 95 and Rust shims 34 -> 17 (alloc side). 39. Free side 296 -> 161 (glibc
free 246 -> 123). 40. 88 Ir of constructor code plus 26 of GC bookkeeping (churn). 41. `memcpy`
eliminated for scalar/packed materialization (16 -> 0). 42. Yes,
halved (shim chain per allocation/free). 43. The allocator (glibc malloc+free, 73%).

**Corpus.** 44. 101,435 -> 101,855 (+0.41%). 45. `.text` +3,136 bytes. 46. 23,210 -> 23,207
dynamic String objects (3 empties now reuse the canonical one); the large-String control
10,033 -> 10,033. 47. 23,207 -> 0. 48. 46,417 -> 23,207 String heap allocations. 49. 46,417 ->
23,207 frees. 50. `ai_text_clean` (-28.6%), then `string_replace`, `refined-checks`. 51. Run window
only: `string_reverse` +2.1% (total -1.2%); `test-selection` +0.2%, `hashtable` +0.04% in the
total (a handful of instructions). 52. Yes, identical run Ir.

**Short-String.** 53. +87.7% -> +52.9% (run window; +125.9% -> +74.5% with the free side).
54. B = A on both; with the demand rule off -2.54% -> -2.53%. 55. -41.9% -> -54.8%.
56./57./58. `refined-checks`, `source-checks` and `hashtable` are regime-neutral under the demand rule on
both runtimes (B = A); from the runtime alone their whole life cycle moves -23.7% / -5.6% / +0.04%. 59. -3.2% to -4.9% (neutral to the regime). 60. No.
61. No. 62. Yes.

**Architecture.** 63. No. 64. No. 65. No. 66. Yes. 67. Yes.

**Correctness.** 68.-81. Values and error messages agree with the interpreter on ASCII, U+0000
(one character, one zero byte, not empty), "…", BMP, astral, combining sequences, empty and
large Strings (`tests/string-allocation.test` + the fuzzers), under GC stress and in standalone
executables, with the two pre-existing divergences listed above (U+0130 lowercase; the
region-equality compile failure), full regression green (3880 + 3876 passed).

## Reproducing

```
cargo build --release --manifest-path native/Cargo.toml
cargo test --release --manifest-path native/Cargo.toml
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/string-allocation.test
tclsh9.0 tests/all.tcl                              # interp + compile
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl   # GC stress
tclsh9.0 audit/string-allocation/tools/fuzz-general.tcl -n 800 -seed 1
```
Measurement tools, their output and the parent-commit census patch are in
`audit/string-allocation/` (see its README). Audit builds must be made from inside a
checkout (root `.cargo` config, frame pointers).

## CI-equivalent runs

* GC-stress run of the full Tcl suite (`BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`, the
  CI `gc-stress` job, on a snapshot of the final tree): interp 3880/3880, compile 3876 passed + 4
  skipped, 0 failed.
* `tests/native-coverage.tcl` (the CI cranelift-coverage job): 3,914 tests; 1,565 native,
  2,258 backend-independent, 41 passed-partial, 49 unsupported (the usual unsupported
  constructs), 1 failed: `refined-5` (`Emailish?` requires a string), which fails identically at
  the parent commit and is unrelated to this change.
* The snapshots used for these runs predate only two code-motion/lint edits (`packed_ascii` moved
  into `strobj.rs`, one no-op cast removed); the compiled String helpers were compared by
  disassembly and are identical to the measured build.
