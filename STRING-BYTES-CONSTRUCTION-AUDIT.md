# String/Bytes construction audit: `ai_text_clean`, `encode_utf8`, and what's next

Milestone date: 22 September 2026. Prior source revision: `8358e8d`
("Regenerate the scalar assembly audit corpus"). This is an audit and
design-decision milestone: **no** `Utf8Bytes`, `Bytes`, `BytesBuilder`,
`TextBuilder`, general concat optimization, small-string optimization,
rope, interning, or new public String syntax was implemented. One narrow
diagnostic fix (below) is the only code change.

## Files changed

- `native/src/runtime/ops.rs` -- `rt_str_decode_char_at` now calls
  `record_string_copy` for its own copied bytes, matching every other
  String-producing runtime op (`rt_substr`, `rt_str_cat`, `rt_str_lower`).
  This is diagnostic-only: it fixes an undercount in `native::
  allocationReport`'s `copies.stringBytes` field, found by reconciling it
  against `byKind.String.payloadBytes` on `bench/ai_text_clean.tcl` (see
  "Diagnostic tooling added" below). No allocation count, no allocated
  byte total, no program value, and no other metric changes.
- `tests/native-string-traversal.test` -- one new test,
  `traversal-string-copy-accounting-1`, locking in the fixed reconciliation
  for a concrete, fully hand-verified case.

No change to `core/`, `surface/`, `hir/`, `lib/web.bot`, `lib/web.tcl`, or
any `examples/stdlib/*.bot` source. All allocation *counts* and *byte
totals* reported below are unchanged from HEAD before this diagnostic fix;
only the `copies.stringBytes` aggregate for `ai_text_clean` changes (from
an undercounted 313 to the correct 383 -- see below), because it is the
only corpus program that exercises the undercounted op at all (confirmed
by direct check: `csv`/`csv_chunked`/`csv_geometric`/`string_replace`/
`string_reverse`/`csv_records` already reconciled exactly, before and
after).

## Diagnostic tooling added

`rt_str_decode_char_at` (native/src/runtime/ops.rs) is the runtime op
`native/lower.tcl`'s String-traversal optimization (hir/traversal.tcl)
lowers a `peek`-shaped character access to, once it has proven the access
reads at a byte offset already carried forward from a previous access
instead of needing to seek. Unlike `rt_substr`/`rt_str_cat`/`rt_str_lower`,
it never called `Metrics::record_string_copy` for the one-character
`String` it allocates (`c.to_string()`) -- an oversight, not a design
choice: the copy happens exactly as it does for every other String
constructor. This under-reported `copies.stringBytes` by exactly this op's
own contribution whenever a program's `peek`-shaped access is optimized to
`decodecharat` **and** its result still needs to materialize (escapes past
the region-consumer shapes `hir::stringregion.tcl` recognizes -- see
below). `ai_text_clean` is the only corpus/bench program where this
combination occurs (confirmed directly: none of `csv`/`csv_chunked`/
`csv_geometric`/`string_replace`/`string_reverse`/`csv_records` allocate
via `decodecharat` at all -- see "Corpus-wide census" below). Fixed with a
one-line `record_string_copy(bytes)` call; no NIR, codegen, or ABI change,
and no semantic behavior change (the allocation and the copy it counts
already happened). Verified by reconciliation: `ai_text_clean`'s `copies.
stringBytes` now equals `byKind.String.payloadBytes` exactly (383 == 383),
which must hold for any program whose every String allocation is a full
copy (true here) -- this identity is exactly what exposed the gap in the
first place, and is now asserted as a regression test.

All other evidence below is drawn from the runtime's existing
instrumentation (`native::allocationReport`'s `summary`/`sites` modes,
`native/src/runtime/metrics.rs`) with no additional runtime changes.

## Runtime representation audit (String, `encode_utf8`, substring, concat)

**String layout** (`native/src/runtime/value.rs::StrObj`):

```rust
pub struct StrObj {
    pub hdr: Header,       // 8 bytes: kind, marked, is_static, padding
    pub chars: usize,      // Unicode scalar count -- stored, not recomputed
    pub ascii: bool,       // true iff every scalar is ASCII -- stored
    pub text: Box<str>,    // the UTF-8 payload: contiguous, owned, immutable
}
```

`size_of::<StrObj>() == 40` bytes (confirmed empirically: every String
allocation's `headerBytes` in `native::allocationReport`'s sites mode is
exactly 40, corpus-wide, with zero exceptions). Answering #33 directly:

- UTF-8 payload bytes are contiguous: `Box<str>` is a single owned,
  contiguous byte buffer (Rust's own `str` invariant: always valid UTF-8).
- Byte length is stored (implicitly, in `Box<str>`'s fat-pointer length --
  O(1) to read, e.g. `rt_str_byte_len`); scalar length is stored explicitly
  (`chars: usize`, computed once at construction, never rescanned).
- Base pointer + byte offset already cheaply identifies a span: this is
  exactly what `rt_str_decode_char_at`/`rt_str_byte_len` (the "String
  traversal" ops) and `rt_str_region_eq`/`rt_str_region_is_tcl_*` (the
  StringRegion ops) already do -- no new field or layout is needed for a
  byte-offset view; the facts already exist on every `StrObj`.

**Substring/concat never share storage** (#34): `rt_substr` always builds
a fresh owned `String` (`obj.text[from..to].to_string()` on the ASCII path,
`.collect()` on the non-ASCII path) and `rt_str_cat` always builds a fresh
owned `String` (`String::with_capacity` + two `push_str`s). Neither ever
returns a view into an existing `StrObj`'s buffer. `StringRegion` (a
`{base, start, end}` triple) exists **only** at the NIR/compile-time level
(`hir/stringregion.tcl`, `native/lower.tcl`'s "String regions" section) --
there is no runtime object for it; a region that reaches an unrecognized
consumer is materialized via the same `rt_substr`, and one that reaches a
recognized consumer (`==`, `length`, `is_tcl_alpha`/`is_tcl_alnum`, or a
proven-pure predicate parameter) is read directly from its base `StrObj`
with no allocation at all, via `rt_str_region_eq`/`rt_str_region_is_tcl_*`.

**`encode_utf8`'s exact contract** (#7, answering "verify current
reality" rather than assuming the historical `str -> list<int>`
description): `core::strings::encodeUtf8` (`core/strings.tcl`) is the
interp/compile (Tcl-hosted) reference implementation; `rt_str_utf8_bytes`
(`native/src/runtime/ops.rs`) is the Cranelift runtime op it lowers to
(NIR `strutf8bytes`). Both are registered under one native, `encode_utf8`
(`core/strings.tcl`'s `-param-types {str} -result-type list`), so the
contract is exactly `str -> List[Int]`, one element per UTF-8 byte, in
order, each element `0..255`. Confirmed by direct inspection, not
assumption:

- **Result Ints are ordinary Ints, and always small (never BigInt)**: a
  byte value is `0..255`, deep inside `Value`'s small-Int range
  (`-2^62..2^62`, `native/src/runtime/value.rs`'s header comment) --
  `vm.new_int(b as i64)` always takes the `fits_small` branch. A byte is
  therefore a plain tagged 64-bit word (`(n << 1) | 1`), never a separate
  heap `BigIntObj` -- no "boxing" allocation per element, ever.
  Corpus-wide: no `BigInt` allocation appears in any program's report.
- **Byte range is proven by construction, not merely believed**: the
  native op reads `str_of(s).text.bytes()` directly off an existing `Box
  <str>`, which is a Rust `str` invariant (always valid UTF-8), so every
  emitted byte is mechanically `0..255` -- this is a property of Rust's
  type, not a runtime check `rt_str_utf8_bytes` performs itself.
  `core::strings::encodeUtf8` gets the same guarantee from Tcl's `encoding
  convertto utf-8`.
- **List storage is tagged Value storage**: `ListObj`'s backing store is
  `Box<[Value]>` (`native/src/runtime/value.rs`), i.e. one 64-bit tagged
  word per element -- the same uniform representation every other List in
  the language uses. There is no untagged/packed byte array anywhere in
  the current runtime.
- **No specialized representation exists today**: `encode_utf8`'s result
  is an ordinary `List`, exactly as declared; nothing analogous to a
  packed byte buffer, small-buffer optimization, or Bytes value exists.
- **Does it decode then re-encode?** (#54, #18 of the milestone's
  question list) **No**, for the native (Cranelift) backend specifically:
  `rt_str_utf8_bytes`'s own doc comment states it plainly -- "S's text is
  already a Rust `String`, so it is already valid UTF-8 -- this is a plain
  byte-by-byte read, never a re-encode." This is the backend every
  allocation number in this report is measured on. The Tcl-hosted
  reference implementation (`core::strings::encodeUtf8`) *does* call
  `encoding convertto utf-8` -- a real conversion step, because Tcl's
  internal string representation is not itself UTF-8 -- but that is an
  interp/compile-backend-only fact, irrelevant to every number below.

**Concat's contract**: `rt_str_cat` computes `chars`/`ascii` from its
operands' own stored fields (`x.chars + y.chars`, `x.ascii && y.ascii`) --
never rescans either operand -- then does exactly one allocation, copying
both operands' full byte payloads into the new buffer
(`String::with_capacity` sized exactly, two `push_str`s). This is already
optimal *per call*; the cost analyzed below is entirely about how many
times, and over what growing prefix, it gets called by an *accumulator*.

## `ai_text_clean`'s pipeline, current and end-to-end

`examples/stdlib/ai_text_clean.bot` (`peek`/`cleaner_emoji`/`clean_char`/
`clean_from`/`clean_ai_text`) contains **zero calls to `encode_utf8`**.
This is the single most important correction to the milestone brief's own
framing: the brief's opening evidence ("110 String, 1 List") invites
reading `encode_utf8 -> List[Int]` as the likely source of those 110
Strings, by analogy with the prior audit's `uriEscape` finding. It is not.
Grepping `examples/stdlib/*.bot` confirms `encode_utf8` appears nowhere
outside `lib/web.bot`'s `uri_escape_text`. `ai_text_clean`'s 110 Strings
and 1 List come entirely from ordinary `substring`/`concat`/`==`
traversal, and the milestone's `encode_utf8`/`List[Int]` questions
(#6-20) can only be answered against `uriEscape` as *secondary* evidence
(exactly as the brief's own #30 anticipates) -- done below.

Current pipeline, traced from the compiled NIR (`native::allocationReport
sites`, per-line attribution) rather than assumed from source:

```
literal driver String (constant table, not counted in "allocated")
    │  clean_from(text, 0, "")  -- self-tail recursion, one call per character
    ▼
peek(text, index)                              -- ai_text_clean.bot:34-38
    │  recognized by hir::traversal.tcl as a CharAccessorShape (the exact
    │  2-parameter peek(text,index) idiom): lowered to `decodecharat` at an
    │  already-carried byte offset, NOT ordinary substr -- confirmed: 0
    │  utf8SeekBytes for the whole run (see "Seeking cost" below)
    ▼
one-character String  (55 decodecharat allocations, 6-case demo)
    │  passed to clean_char(character)                -- ai_text_clean.bot:51-67
    │  clean_char is if/==-chain against literals, EXCEPT its fallback
    │  (line 67) returns `character` -- the parameter -- unchanged
    ▼
clean_char's result (same object, unchanged, on the common path)
    │  concat(done, clean_char(...))                  -- ai_text_clean.bot:74
    ▼
strcat: a NEW String = done's full prefix + this one character
    (55 strcat allocations, 6-case demo -- each copies the WHOLE growing
    prefix, not just the new character: the classic immutable-accumulator
    shape, identical to string_reverse.bot's reverse_from and lib/web.bot's
    esc_from/esc_bytes)
    ▼
... recurse until index >= length(text) ...
    ▼
final "done" value returned as clean_ai_text's result -- NO extra copy:
the last strcat's own output IS the returned value.
    ▼
[clean_ai_text(s1), ..., clean_ai_text(s6)]            -- ai_text_clean.bot:79
    one `listnew` (1 allocation, the demo's own output collection)
```

Minimum plausible pipeline the evidence supports (not implemented; see
"Strategic decision"):

```
input String/StringRegion
    ↓ direct byte-offset scalar access (already exists: decodecharat)
a value NEVER materialized as its own String object -- flows, unmaterialized,
through clean_char's ==-comparisons and its "return parameter unchanged"
fallback, directly into...
    ↓ ONE construction step per call: an amortized-O(1) piece accumulator
      (Botlish already has this pattern -- GeometricBuilder, below) whose
      pieces are joined in ONE pass at the end
final String -- exactly 1 allocation, exactly output-length bytes copied
```

## Allocation census: `ai_text_clean`, fresh from HEAD

Reproduced with the corpus's own trailing 6-case demo expression as the
program value (`surface::readProgramFile`, matching `bench/
substr_classify.tcl`'s and the prior milestone's own methodology --
**not** a re-derivation, an independent re-run):

```
total allocations: 111   total bytes: 4855

by kind:
    String   110   headerBytes=4400  payloadBytes=383  allocatedBytes=4783
    List       1   headerBytes=24    payloadBytes=48    allocatedBytes=72

copies: stringBytes=383  listElements=6  mutableArrayElements=0
traversal: utf8SeekBytes=0
```

Every allocation site, with location, operation, count, and bytes (sites
mode; this is the complete site list -- there are only three):

| source site | operation | allocations | bytes (hdr+payload) |
|---|---|---:|---:|
| `ai_text_clean.bot:74` (`peek(text,index)` inside `clean_from`'s recursive call) | `decodecharat` | 55 | 2270 (2200 + 70) |
| `ai_text_clean.bot:74` (`concat(done, clean_char(...))`) | `strcat` | 55 | 2513 (2200 + 313) |
| `ai_text_clean.bot:79` (driver's demo list) | `listnew` | 1 | 72 (24 + 48) |
| **sum** | | **111** | **4855** |

This reconciles **exactly** with the total (111 allocations, 4855 bytes):
no unexplained recurrent allocation exists. Both String sites attribute to
line 74 because `peek(text, index)` and `concat(done, clean_char(...))`
are both sub-expressions of that one line's recursive call -- distinct
compiled instructions, distinct NIR site ids, same source line.

55 characters total across the demo's 6 inputs (`"hello"`=5,
`"hello 🙂 world"`=13, `"AI—generated"`=12, `"“hello”"`=7, `"‘hello’"`=7,
`"wait… what?"`=11 -- sums to 55), one `decodecharat` + one `strcat` per
character: **every recurrent allocation is accounted for by exactly one
semantic operation** (one character read, one accumulator step), with no
residual.

### Classification of the 110 Strings (#4 of the milestone)

Using the milestone's own taxonomy, against actual source behavior:

| category | count | which Strings |
|---|---:|---|
| D. temporary conversion result | 55 | every `decodecharat` result: `peek`'s one-character read, consumed by `clean_char`, never itself stored/returned as a distinct identity |
| B. concat result | 49 | every `strcat` output **except** the 6 that are each input's final returned value |
| C. final output String | 6 | the last `strcat` per driver string -- `clean_from`'s base case returns `done` directly, so no copy beyond the concat that already produced it |
| A. substring/extracted region | 0 | none -- `ai_text_clean` never extracts a multi-character region, only ever one-character `peek` reads |
| E. literal/static-related | 0 (excluded from "allocated" entirely) | driver input Strings live in the constant table, `static`, never counted here |
| F. replacement/transformation result | 0 | none distinct from B/C -- `clean_char`'s replacements (`"-"`, `"'"`, `"\""`, `"..."`) are String **literals**, resolved from the constant table, not fresh allocations; they become part of the *next* `strcat`'s output, already covered by B |
| G. escaping/stored String | 0 | none escape past the single demo-list `listnew` |
| H. other | 0 | -- |

Not all 110 are equally avoidable (explicitly required, #4): the 6 "C"
final outputs are semantically unavoidable (the program *returns* 6
distinct Strings); the 49 "B" intermediates and 55 "D" temporaries are
representational artifacts of the current accumulator/traversal strategy,
not semantic requirements -- see "Theoretical minimum" below.

### Object count vs. copied payload (#5)

| metric | value |
|---|---:|
| String object count | 110 |
| String managed bytes (header+payload) | 4783 (4400 header + 383 payload) |
| String payload bytes copied | 383 (110 objects × mostly-ASCII 1-byte characters, plus growing concat prefixes) |
| -- of which: `decodecharat` (temporary one-char reads) | 70 bytes, 55 objects |
| -- of which: `strcat` (accumulator steps) | 313 bytes, 55 objects |
| substring bytes copied | 0 (no multi-character `substring` call exists in this program) |
| concat bytes copied | 313 (all of it: `strcat` copies the **entire growing prefix** each step, not just the new character) |

**Object count and copied bytes tell different stories here**: `decodecharat`
and `strcat` have equal object counts (55 each) but wildly different
payload weight (70 vs 313 bytes) -- confirming the milestone's own warning
(#5, #82) not to pick the next abstraction from count alone. At this tiny
fixture size the difference is already 4.5x; it grows without bound (next
section).

## Scaling evidence: the accumulator is the dominant cost, not decodecharat

`bench/ai_text_clean.tcl -runs 3` (Cranelift, single-input driver, three
input families -- ASCII, curly punctuation, emoji-heavy):

| family | size | allocations | allocated bytes | String bytes copied |
|---|---|---:|---:|---:|
| ascii | 1K chars | 2,111 | 586.4 KB | 500.8 KB |
| ascii | 10K chars | 20,111 | 50.82 MB | 50.01 MB |
| ascii | 100K chars | 200,111 | 5,008.15 MB | 5,000.05 MB |
| punctuation | 1K chars | 2,111 | 602.6 KB | 516.9 KB |
| punctuation | 10K chars | 20,111 | 52.46 MB | 51.64 MB |
| punctuation | 100K chars | 200,111 | 5,172.07 MB | 5,163.95 MB |
| emoji | 1K chars | 2,111 | 645.8 KB | 559.9 KB |
| emoji | 10K chars | 20,111 | 56.75 MB | 55.93 MB |
| emoji | 100K chars | 200,111 | 5,601.39 MB | 5,593.24 MB |

Allocation **count** is exactly `2N + 11` for N input characters (one
`decodecharat` + one `strcat` per character, plus the 11-allocation demo
fixed cost) -- linear, as expected. Allocated **bytes** scale
86.7x-98.7x per 10x input growth (converging toward the ideal 100x/
quadratic as N grows), matching README's own already-documented O(n²)
finding for `string_reverse`/`string_replace`'s identical accumulator
shape. `-string-region-opt 0` vs `1` produce byte-identical allocation
counts at every size (20,111 either way, 10K case) -- confirming the
bench script's own header note: `ai_text_clean`'s `peek()`'d character
always escapes into the output on the unchanged-character path, so
StringRegion's existing consumer analysis (which only recognizes `==`/
`length`/classification, never "return the parameter unchanged into a
concat") makes no difference here, exactly as already documented.
`utf8SeekBytes` is 0 in every case: the traversal optimization (below)
is working correctly at every size tested.

## Seeking cost: traversal optimization works for `ai_text_clean`, not for `uriEscape`

`ai_text_clean`'s `peek(text, index)` is precisely the 2-parameter
`CharAccessorShape` `hir/traversal.tcl` recognizes: its self-tail loop
(`clean_from`) carries the byte offset forward, so `decodecharat` never
seeks (`utf8SeekBytes == 0` at every size measured, including the
emoji-heavy 100K case, which is non-ASCII throughout). This answers #14/
#17 directly for `ai_text_clean`: the traversal work already eliminated
the O(n²)-seeking half of the problem here; only the O(n²)-**copying**
half (the concat accumulator) remains.

`lib/web.bot`'s `esc_from` (uriEscape's per-character scan) is a
**different, unoptimized shape**: it is a 3-parameter self-tail function
(`text, i, acc`) that calls `substring(text, i, i+1)` **inline**, not
through a separate 2-parameter `peek`-shaped helper -- `hir::traversal.
tcl`'s `CharAccessorShape` only ever recognizes the latter. Measured
directly (secondary workload, below): `esc_from` over a 12-character,
non-ASCII-overall input records **93 `utf8SeekBytes`** -- a real, nonzero,
exactly-reconciled instance of the seeking cost the traversal work exists
to eliminate, sitting in already-shipped library code that the traversal
optimization simply does not reach. This is flagged as a finding, not
fixed here (#63/#65: the scalar/traversal work is closed for this
milestone) -- but it is worth recording precisely because it demonstrates
by direct measurement, not simulation, exactly the O(n²)-seeking failure
mode item #14 warns a new byte-view design must not reintroduce.

## `encode_utf8` audit (secondary evidence: `uriEscape`, since `ai_text_clean` has no calls)

Every call to `encode_utf8` in the corpus is inside `lib/web.bot`'s
`esc_char(c)` (`uriEscape`'s implementation), always applied to a
**one-character** String (`c = substring(text, i, i+1)`, from `esc_from`).
Measured directly on `web::uri_escape_text("a café €北京🙂!")` (12
scalars, 22 UTF-8 bytes, spanning 1/2/3/4-byte encodings on purpose, per
#53):

```
total allocations: 91   total bytes: 4217

by kind:
    String   78   payloadBytes=481  (substr:12, strcat lines 123/129×2/145)
    List     13   payloadBytes=304  (strutf8bytes:12, listnew hex_digits:1)

copies: stringBytes=481  listElements=38
traversal: utf8SeekBytes=93
output: "a%20caf%C3%A9%20%E2%82%AC%E5%8C%97%E4%BA%AC%F0%9F%99%82%21"
```

| site | op | allocs | bytes |
|---|---|---:|---:|
| `web.bot:145` (`esc_from`'s own accumulator) | `substr` | 12 | 502 |
| `web.bot:145` (`esc_from`'s own accumulator) | `strcat` | 12 | 747 |
| `web.bot:129` (`esc_bytes`'s inner `concat("%", hex_pair(...))`) | `strcat` | 18 | 774 |
| `web.bot:129` (`esc_bytes`'s outer `concat(acc, ...)`) | `strcat` | 18 | 822 |
| `web.bot:123` (`hex_pair`'s `concat`) | `strcat` | 18 | 756 |
| `web.bot:132` (`esc_char`'s `encode_utf8(c)`) | `strutf8bytes` | 12 | 464 |
| `web.bot:31` (`hex_digits` literal table, once) | `listnew` | 1 | 152 |
| **sum** | | **91** | **4217** |

Every number reconciles exactly against the input, byte-for-byte:

- **12 `encode_utf8` calls**, one per input scalar (#7-9): confirms
  `esc_char`'s call site is always on a one-character String, never a
  whole string -- `encode_utf8`'s List length here is always `1..4`,
  never unbounded, for *this call site specifically* (a fact about how
  `uriEscape` uses it, not about `encode_utf8`'s own general contract).
- **18 escaped bytes** (`hex_pair` calls, `web.bot:123`) exactly equals
  the count of non-"unreserved" bytes in the input (space×2, `é`×2,
  `€`×3, `北`×3, `京`×3, `🙂`×4, `!`×1 = 18) -- confirms `is_unreserved`'s
  RFC 3986 classification is being exercised correctly across the whole
  1-4 byte width range.
- **93 `utf8SeekBytes`** exactly equals the sum of each character's
  starting byte offset (0+1+2+3+4+5+7+8+11+14+17+21 = 93) -- confirms
  every one of the 12 `substring` calls re-seeks from byte 0 (the whole
  input String is non-ASCII overall, so `rt_substr`'s ASCII fast path
  never applies, even to the plain-ASCII characters in the string).
- **38 list elements copied** = 22 (the `encode_utf8` byte lists' own
  total length, matching the 22-byte input exactly) + 16 (`hex_digits`'
  own one-time 16-entry table) -- confirms `rt_list_new` counts its own
  initial element writes as copies, corpus-wide, not something specific
  to `encode_utf8`.

### `encode_utf8` consumer taxonomy and design fork (#9-20)

`esc_char`'s only two uses of `encode_utf8`'s result:

1. `list_length(bytes) == 1` then `is_unreserved(list_get(bytes, 0))` --
   **class A** (inspect bytes sequentially/by index), immediate, never
   escapes.
2. `esc_bytes(bytes, 0, "")` -- walks every element via `list_get`,
   converts each to two hex-digit characters, accumulates by `concat` --
   **class A + C** (inspect, then emit/copy as text), immediate, never
   escapes.

No call anywhere in the corpus stores, returns, hashes, or retains an
`encode_utf8` result past the statement that produced it (#16: the
negative/escape case). **Every current byte consumer needs only
sequential read access to bytes already inside an existing String's
UTF-8 payload -- never ownership, never persistence past the call.**
This is a small, single-call-site sample (12 calls, one 22-byte input),
but it is unambiguous: nothing here supports "owned Bytes" as a genuine
requirement (#21, #74's criteria are not met by any evidence found).
`esc_char`'s own one-character call pattern (#60-61) also confirms the
milestone's own hypothesis: since it is *always* called on a ≤4-byte
region, a compiler-internal UTF-8 span reading directly from the
region's already-known `(base, start, end)` would answer every one of
these calls without ever allocating a `List` at all -- but see "Is List[Int]
the cost" below for why this would be a small, not corpus-dominant, win.

### Is `List[Int]` materially expensive here, or merely awkward? (#8, #24)

Per call: one `List` allocation (24-byte header + up to 4×8=32 bytes
payload for a 4-byte scalar -- 56 bytes max), holding 1-4 already-tagged
Int words (no boxing: confirmed above, small-Int range covers every byte
value). This is **cheap in absolute terms** (56 bytes is smaller than one
`StrObj`'s own 40-byte header alone would need for two extra bytes of
text) and **not corpus-dominant**: in the full `refined-checks.ir`
program (`uriEscape` computed once, on a 3-byte literal, per the prior
milestone's own finding), the entire `uriEscape` family contributes 9
Strings + a handful of Lists out of that program's 15 total managed
objects and 717 bytes -- see "Corpus-wide census" below. The answer is
**"merely architecturally awkward, not materially expensive"**: a
dedicated `Byte` element (1 byte) vs. a tagged `Int` element (8 bytes,
already unboxed) is an 8x storage-density difference *per element*, but
since the number of elements here is 1-4 and the whole List is one
allocation regardless, the *allocation-count* story (#8's actual question)
is unaffected either way. A `Bytes` representation would not reduce
allocation count below what a compiler-internal UTF-8 span already
achieves (zero), and would only matter for a workload that builds large,
long-lived byte sequences -- which nothing in the current corpus does.

## GeometricBuilder: the missing piece is smaller than a builder

Botlish already has a working, purely-library (**not** compiler/runtime)
answer to "how do you accumulate N pieces without O(n²) copying," proven
in the corpus today: `examples/stdlib/csv_geometric.bot`'s
`GeometricBuilder` (`geo_new`/`geo_append`/`geo_finish`), built entirely
from existing `mutable_array_allocate`/`_capacity`/`_get`/`_set`/`_copy`/
`_freeze` runtime primitives, with geometric (doubling) capacity growth
decided entirely in ordinary Botlish source (`geo_new_capacity`). This
already gives amortized O(1) per-element append with **zero new runtime
capability** -- it is used today for `csv_geometric.bot`'s
field/record-List construction.

**What it cannot do**: `mutable_array_freeze` (`rt_mutarray_freeze`,
native/src/runtime/ops.rs) always finalizes a `MutableArray` into a
`List` of `Value`s -- never into a `String`. There is **no** primitive
anywhere in the runtime or `core/strings.tcl` that joins a `List` of
Strings into one String in a single pass (`grep`-confirmed: no `join`,
`concat_all`, or equivalent exists). So today, even a program willing to
collect its pieces in a `GeometricBuilder` (amortized O(1) per piece) has
no way to turn that finished `List[str]` into a final `str` except by
falling back to the same pairwise `concat`-in-a-loop this audit already
shows is O(n²) -- the missing capability is not the accumulation phase
(already solved, in library code, today) but the **one-shot join** at the
end.

## Theoretical minimum vs. current, for the concrete sample

For the 6-case `ai_text_clean` demo:

```
current:   110 String objects, 1 List, 383 payload bytes copied
minimum:     6 String objects (one final output per call), 1 List,
             56 payload bytes copied (sum of the 6 outputs' own lengths:
             5+12+12+7+7+13)
```

110 → 6 is a 94.5% cut in String object count; 383 → 56 is an 85% cut in
copied bytes **at this tiny fixture**. The gap widens without bound as
input grows (§"Scaling evidence"): at 100K ASCII characters, current
copies ~5.0 GB against a semantic minimum of ~100 KB (the output's own
size) -- roughly **50,000x** more copying than the theoretical floor,
growing quadratically. The theoretical-minimum String count for a single
`clean_ai_text` call is exactly **1** (the returned value is the only
Botlish-visible, semantically-required owned String); the temporary
one-character reads and every intermediate accumulator step are pure
representation artifacts of the current traversal-and-concat strategy, not
requirements of the algorithm.

## Corpus-wide census (13 programs, fresh from HEAD)

`examples/stdlib/*.bot` (9 programs) + `bench/*.ir` (4 programs: `fib`,
`loop-count`, `refined-checks`, `sum-refined`):

| program | allocations | String | List | MutArray | Block | bytes | String bytes copied | List elems copied |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **ai_text_clean** | **111** | **110** | 1 | 0 | 0 | **4855** | **383** | 6 |
| csv_records | 83 | 18 | 11 | 54 | 0 | 4056 | 72 | 7 |
| string_replace | 26 | 25 | 1 | 0 | 0 | 1084 | 20 | 5 |
| string_reverse | 23 | 22 | 1 | 0 | 0 | 987 | 43 | 5 |
| csv_geometric | 23 | 6 | 4 | 13 | 0 | 867 | 19 | 0 |
| csv_chunked | 22 | 6 | 8 | 8 | 0 | 2835 | 19 | 0 |
| csv | 19 | 6 | 13 | 0 | 0 | 691 | 19 | 6 |
| refined-checks | 15 | 9 | 5 | 0 | 1 | 717 | 21 | 21 |
| matmul | 16 | 0 | 16 | 0 | 0 | 592 | 0 | 20 |
| hashtable | 5 | 0 | 1 | 4 | 0 | 400 | 0 | 6 |
| fib | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| loop-count | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| sum-refined | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

`refined-checks` here reproduces the milestone brief's own stated
baseline exactly (15 objects, 9 String, 5 List, 1 Block, 717 bytes) --
confirms this census's methodology against the brief's own already-known
numbers, independent corroboration rather than a re-derivation.

**Ranking by allocation count**: `ai_text_clean` (111) leads by a wide
margin over the next (`csv_records`, 83). **Ranking by managed bytes**:
`ai_text_clean` (4855) also leads (`csv_records` 4056 next). **Ranking by
String bytes copied**: `ai_text_clean` (383) leads (`string_reverse` 43
next). All three rankings agree on the same answer (#39): `ai_text_clean`
is the corpus's dominant String/Bytes allocation site today, on every
axis, at this fixture size -- and its dominance *grows*, not shrinks, at
realistic input sizes (§"Scaling evidence"), where its copied-byte total
already reaches gigabytes at 100K characters, dwarfing every other
program in the table combined.

**Corpus-wide `substring`/concat-accumulator inventory** (#33-35, #40):
the exact `out = concat(out, piece)` (or `concat(piece, out)`) recursive
shape appears in at least four places: `ai_text_clean.bot`'s `clean_from`,
`string_reverse.bot`'s `reverse_from`, `lib/web.bot`'s `esc_bytes` (line
129, twice per byte) and `esc_from` (line 145), and `hex_pair` (line 123,
a small fixed 2-piece case, not a growing accumulator -- see "Distinguish
small fixed concat from builder-worthy accumulation" below). `csv_records.
bot`'s `scan_quoted` also uses the identical `concat(field, character)`
shape for quoted-field character accumulation (confirmed by direct
inspection, per the brief's #31 -- flagged as sharing the same mechanism,
not pursued further: CSV/record optimization stays out of scope).
`string_replace.bot`'s `replace_from` uses a coarser-grained but same-family
accumulator (`concat(done, substring(...))` per matched chunk, not per
character -- already less quadratic in practice since it copies at match
boundaries, not every character).

**Do these rankings point at the same next capability? Does `uriEscape`
support the same conclusion?** (#39-40) Yes to both: every one of these
sites is an instance of exactly the same problem -- an immutable
accumulator repeatedly copying its own growing prefix -- and `uriEscape`'s
own three concat sites (123, 129×2, 145) are further, independent
instances of it, not a different problem. `hex_pair` (line 123) is
explicitly **not** the same shape (see next section): it is a small,
fixed, 2-piece concat, not a growing accumulator, and gains nothing from
whatever answers the accumulator problem.

**Distinguishing small fixed concat from builder-worthy accumulation**
(#24): `hex_pair`'s `concat(a, b)` (two 1-character lookups, fixed size,
called once per escaped byte, never itself accumulated into) is already
optimal -- one allocation, exactly 2 bytes copied, no way to do less work
for a 2-piece concatenation. It needs nothing further. `esc_bytes`/
`esc_from`/`clean_from`/`reverse_from`'s `concat(acc, piece)` loops are the
opposite: unboundedly growing, each step re-copying everything accumulated
so far. These are not the same problem and must not be solved by the same
mechanism-shaped-for-the-wrong-case (#24 of the brief, directly).

## Strategic decision: **D**, a one-shot presized join, fed by the existing GeometricBuilder idiom

**Primary recommendation: D (one-shot presized String construction)** --
specifically, a single new native, informally `join(pieces: List[str]) ->
str`, computing total output length from each piece's own already-stored
`chars`/byte-length fields (zero rescanning, exactly like `rt_str_cat`
already does for two operands today), allocating exactly once, and
copying each piece's bytes into the result exactly once. This is a direct
N-ary generalization of `rt_str_cat`'s own existing algorithm, not a new
representation, mutable type, or ownership model.

**Why D, not C (a mutable builder)**: Botlish already has a proven,
purely-library, amortized-O(1) accumulation mechanism -- `GeometricBuilder`
over `MutableArray` (`csv_geometric.bot`), used today. The gap is not "no
way to accumulate pieces cheaply" (solved) but "no way to turn the
finished `List[str]` into one `String` without paying O(n²) again"
(unsolved: `mutable_array_freeze` only produces a `List`, and there is no
join). Closing that one gap with a one-shot presized primitive fully
resolves the O(n²)-copying cost this audit measured in `ai_text_clean`
(§"Scaling evidence"), `string_reverse`, `string_replace`, and both of
`uriEscape`'s accumulators -- **without** introducing a new mutable,
Botlish-visible builder type, its freeze semantics, or its GC interaction
story. A full mutable text/byte builder (option C) would also work, but is
strictly more machinery than the evidence requires: every corpus
accumulator already fits the "collect via GeometricBuilder, then one final
join" shape, and nothing found needs incremental (interleaved
read-while-writing) access to a partially-built buffer.

**Why not A (compiler-internal UTF-8 span) as primary**: A view would
eliminate `ai_text_clean`'s 55 `decodecharat` allocations (real, but only
70 of the workload's 383 copied bytes -- 18%) and `uriEscape`'s 12
`strutf8bytes`/List allocations (real, but not corpus-dominant: 9 total
String allocations in the whole `refined-checks.ir` program that computes
it). Neither is the dominant cost measured. A is a legitimate, well-scoped
**secondary** item precisely because it is a small, natural extension of
already-existing, already-correctly-scoped machinery (`hir::stringregion.
tcl`'s `ConsumingParams`, generalized to recognize "compared to literals,
OR returned unchanged, and the result flows into a supported consumer"
rather than only "compared to literals") -- see next section.

**Why not B (owned Bytes/Utf8Bytes)**: no evidence anywhere in the corpus
shows byte data escaping, persisting, being stored, or being returned
independently of a String (#16, #21-22's criteria are unmet). Every
`encode_utf8` call found is an immediate, non-escaping, sequential-read
consumer. Committing to an owned Bytes representation now would be
solving a problem this corpus does not have.

**Why not E (no new primitive, fix the library alone)**: Botlish's
current language semantics give no way to accumulate pieces into a single
String in less than O(n²) total copying using *only* existing native
primitives -- `concat` is pairwise and `List`'s own `list_append` is
itself O(n) per call (README's own already-documented finding), so
routing the accumulator through a `List` first does not avoid the
quadratic cost, it just moves it. A new primitive (D) is genuinely
required; this is not a pure source-level bug.

### Scope for the `join` milestone (for the next implementation prompt)

- **Semantic contract**: `join(pieces: List[str]) -> str`, returning the
  concatenation of `pieces` in order (empty List -> `""`); no separator
  argument in this minimal form (adding one is a trivial, backward-
  compatible follow-up, not part of this contract).
- **Runtime representation**: one `rt_list_join`-shaped native op:
  iterate `pieces` once to sum each element's `text.len()` (byte length)
  and `chars` (already-stored, no rescan) and AND their `ascii` flags;
  allocate one `String` of exactly the summed byte length; iterate again,
  `push_str`-ing each piece's bytes in order; construct one `StrObj` via
  `new_str_known` (chars, ascii already computed, no rescan) -- exactly
  `rt_str_cat`'s existing algorithm, generalized from 2 operands to N.
- **Eliminates**: the O(n²) repeated-copying cost of `clean_from`,
  `reverse_from`, `esc_bytes`, `esc_from`, and `csv_records.bot`'s
  `scan_quoted` -- **once each of those source functions is rewritten**
  to accumulate pieces via `GeometricBuilder`+`geo_finish` (already-
  existing library code) and call `join` once at the end, instead of
  recursive `concat`. This milestone's audit does not itself rewrite
  those sources; that rewrite is the next milestone's own scope,
  informed by this report.
- **Deliberately will not eliminate**: `ai_text_clean`'s 55
  `decodecharat` temporaries (a separate, smaller item -- see "Secondary
  candidate" below); `uriEscape`'s `encode_utf8`/List intermediates (also
  separate); `esc_from`'s 93-byte seeking gap (a traversal-recognition
  gap, unrelated to construction, explicitly out of this milestone's
  scope per #63/#65).
- **Primary benchmark**: `bench/ai_text_clean.tcl` (already exists,
  already measures exactly this).
- **Secondary benchmark**: a new `bench/*.tcl` for `string_reverse`/
  `uriEscape` at scale (neither currently has a dedicated scaling bench;
  `bench/bench.tcl`'s `refined-checks.ir` computes `uriEscape` only once,
  on a 3-byte literal -- insufficient to show the accumulator cost at
  scale, which is exactly why this audit measured `uriEscape` with a
  purpose-built driver instead).
- **Negative/escape cases**: `join` returning a String whose pieces
  contain non-ASCII/astral text (correctness: `chars`/`ascii` computed
  from already-correct per-piece fields, not re-derived); an empty
  `pieces` List; a single-element `pieces` List (should cost exactly one
  allocation, the same as returning that element's own bytes copied once
  -- not zero, since the language returns a fresh value, not aliases
  a List's own element, matching `rt_str_cat`'s existing precedent of a
  fresh copy even when handed a piece list containing empty strings).

### Secondary candidate: extend `hir::stringregion.tcl`'s `ConsumingParams` to "returned unchanged, into a supported consumer"

`clean_char`'s fallback (`character` returned unchanged) is exactly the
one shape `ConsumingShape`'s current definition excludes (it recognizes
only `if`/`==`/`length`/classification-call bodies, per `hir/
stringregion.tcl`'s own comment, "materializes... if it is stored,
returned, captured..."). A future generalization recognizing "every use of
the parameter is either a supported comparison/classification, or the
parameter returned as the function's own value, AND the call site's result
immediately feeds a recognized region consumer" would let `clean_char`'s
one-character argument flow, unmaterialized, from `peek`'s traversal-
carried byte offset directly into a region-aware `concat`/`join` operand
-- eliminating `ai_text_clean`'s 55 `decodecharat` allocations entirely
(18% of its copied bytes, 50% of its object count). This is flagged as a
well-scoped, natural continuation of already-existing, already-correctly-
bounded machinery -- not proposed for implementation here (#65: reopening
StringRegion is explicitly conditional on "direct evidence reveals a
missing byte-view composition," which this is, but the brief also asks for
one primary recommendation, and this item does not address the dominant,
quantified cost).

### Not pursued: fixing `esc_from`'s seeking gap

`esc_from`'s 93-`utf8SeekBytes` finding (above) is real and quantified,
but is a `hir/traversal.tcl` *recognition* gap (an inline 3-parameter
self-tail substring, not the narrower 2-parameter `peek`-helper shape it
currently recognizes), unrelated to String/Bytes representation. Recorded
as a finding; explicitly out of this milestone's scope (#63/#65: the
scalar/traversal work is closed).

## Design pathways (#84-85)

```
String -> Unicode scalar iteration           already supported (peek/substring)
String -> compiler-internal UTF-8 span       missing; secondary candidate above
                                              (small: 18% of ai_text_clean's
                                              copied bytes, not corpus-dominant)
String -> owned UTF-8 bytes (encode_utf8)    already supported; no evidence
                                              anything needs OWNERSHIP of it
Bytes -> raw byte iteration                  not needed by any current workload
validated UTF-8 Bytes -> String              not needed by any current workload

existing immutable concat (pairwise)         already supported, already optimal
                                              per-call; the problem is call COUNT
                                              in an accumulator, not the op itself
one-shot presized construction (join)        MISSING, NEEDED NOW -- primary
                                              recommendation
growable byte/text construction (builder)    NOT needed: GeometricBuilder+join
                                              already covers every corpus case
freeze to immutable String/Bytes             MutableArray->List exists; ->String
                                              (via join) is exactly the gap
```

## Answers to the mandatory questions

**`ai_text_clean` (#1-20)**

1. 55 `decodecharat` (one-character traversal reads) + 55 `strcat`
   (accumulator steps, 49 intermediate + 6 final outputs).
2. `ai_text_clean.bot:74`, both sites (the recursive call's two
   sub-expressions).
3. The 6 final outputs (one per driver call) are semantically necessary
   owned Strings; nothing else is.
4. All 55 `decodecharat` + 49 of the 55 `strcat` (104 of 110) are
   temporary representation artifacts of the current traversal+
   accumulator strategy, not semantic requirements.
5. Zero -- `ai_text_clean` has no multi-character `substring` call.
6. 313 bytes (all of `strcat`'s copying; `strcat` copies the *entire*
   growing prefix each step).
7. Zero times -- `ai_text_clean` never calls `encode_utf8`.
8-13. N/A for `ai_text_clean` (no calls); answered against `uriEscape`
   as secondary evidence, above.
14. Would need to be re-checked per consumer if `encode_utf8` reaches
    `ai_text_clean` in future; not applicable today.
15. Yes for `clean_char`'s ==-comparison branches (already true today,
    via existing StringRegion); no for its "return unchanged" fallback
    (the gap identified above).
16. Yes -- `peek`'s traversal-carried byte offset is exactly the
    compiler-known fact a view would need; already computed today for
    `decodecharat`/`strbytelen`.
17. No -- confirmed empirically, `utf8SeekBytes == 0` at every size
    tested (1K/10K/100K, all three input families).
18. No, for the native (Cranelift) backend measured throughout this
    report -- `rt_str_utf8_bytes` reads already-UTF-8 bytes directly,
    confirmed from its own source and doc comment. (The Tcl-hosted
    reference implementation does re-encode, but is not what any number
    here measures.)
19. 6 owned Strings (the 6 final outputs) for the demo sample.
20. 56 bytes (the sum of the 6 outputs' own lengths).

**Design (#21-30)**

21. No -- no evidence of escaping/persisting/returned byte data anywhere
    in the corpus.
22. Yes, for every immediate consumer found (`uriEscape`'s two use
    sites, and hypothetically `ai_text_clean` if it ever called
    `encode_utf8`).
23. Not reached: no evidence supports needing Bytes at all yet; if it
    ever is needed, the required distinction is "arbitrary octets" vs.
    "statically/runtime-proven valid UTF-8" (String -> Bytes is always
    valid by construction; Bytes -> String needs validation unless
    proven).
24. Storage density yes (8x: one tagged 64-bit Int word vs. one packed
    byte), allocation count no (already one List regardless of length,
    same as a Bytes value would be).
25. Yes, decisively -- 313 of 383 copied bytes (82%) in `ai_text_clean`
    are the accumulator's `strcat` copying, not any byte-conversion
    step (which doesn't exist in this program at all).
26. No, not before the scan completes (output length depends on
    per-character classification decided during the scan) -- but yes,
    trivially, once the pieces are collected into a List (each piece's
    length is already a stored field, summable in one pass with no
    rescanning).
27. Yes -- exactly the `join` primitive recommended above, applied after
    collection, not before.
28. No -- see "Why D, not C" above: `GeometricBuilder` (already existing,
    library-only) already provides amortized-O(1) accumulation; nothing
    in the corpus needs interleaved read/write access mid-construction.
29. Yes -- `join`'s algorithm is a direct N-ary generalization of
    `rt_str_cat`'s existing 2-operand algorithm; no separate lower-level
    buffer primitive is needed beyond what `rt_str_cat` already does.
30. `MutableArray` already fully serves the *accumulation* phase
    (`GeometricBuilder`, proven); byte-packed storage is a separate,
    unaddressed question only relevant if a future workload needs
    large, persistent Bytes values -- not evidenced today.

**Corpus (#31-40)**

31. Only `lib/web.bot`'s `esc_char` (`uriEscape`'s implementation);
    nowhere else in `bench/`, `examples/stdlib/`, or `lib/`.
32. All calls found are immediate consumers; none escape.
33. `ai_text_clean` (`clean_from`), `string_reverse` (`reverse_from`),
    `uriEscape` (`esc_bytes` ×2, `esc_from`), `csv_records`
    (`scan_quoted`).
34. `csv`/`csv_chunked`/`csv_geometric` (field extraction, but resolved
    to zero allocation for `==`/`length`-only uses via existing
    StringRegion); `string_replace` (chunk extraction at match
    boundaries); `ai_text_clean`/`uriEscape` (per-character, via `peek`/
    inline `substring`).
35. None of the *.bot programs (confirmed by direct grep and site
    inspection: `ai_text_clean` has no `encode_utf8` calls; only
    `uriEscape` does, and its List intermediates are small and
    non-escaping, not "recurrent" in the sense of dominating a program's
    profile).
36. By allocation count: `ai_text_clean` (111) > `csv_records` (83) >
    `string_replace` (26) > `string_reverse`/`csv_geometric` (23) >
    `csv_chunked` (22) > `csv` (19) > `refined-checks` (15) > `matmul`
    (16, all List) > `hashtable` (5).
37. By managed bytes: `ai_text_clean` (4855) > `csv_records` (4056) >
    `csv_chunked` (2835) > `string_replace` (1084) > `string_reverse`
    (987) > `csv_geometric` (867) > `refined-checks` (717) > `csv` (691)
    > `matmul` (592) > `hashtable` (400).
38. By String bytes copied: `ai_text_clean` (383) > `string_reverse`
    (43) > `csv_records` (72) > `refined-checks` (21) > `string_replace`
    (20) > `csv`/`csv_chunked`/`csv_geometric` (19 each) > everything
    else (0).
39. Yes, unanimously: `ai_text_clean` leads on every ranking, at this
    fixture size, and its lead widens (not narrows) at realistic input
    sizes.
40. Yes -- `uriEscape`'s own accumulators (`esc_bytes`, `esc_from`) are
    further instances of the identical repeated-immutable-concat problem
    `ai_text_clean` demonstrates; its `encode_utf8` usage independently
    confirms the "immediate consumer, never escapes" finding that rules
    out an owned-Bytes primary recommendation.

## Regression testing

- `cargo test --release --manifest-path native/Cargo.toml`: 60/60 passed
  (unchanged from before this milestone -- the diagnostic fix touches no
  existing test's expected values; `decode_char_at_*` tests continue to
  pass unmodified).
- `tclsh9.0 tests/all.tcl` (interp and compile backends): **1504/1504
  passed** (1503 pre-existing + 1 new, `traversal-string-copy-accounting-1`).
- `bench/ai_text_clean.tcl -runs 3`: unchanged program values (CRC-
  verified internally by the bench script itself) across all three input
  families and all three sizes measured.
- No source file under `core/`, `surface/`, `hir/`, `lib/`, or
  `examples/stdlib/` was touched: every allocation count and program
  value in this report is unchanged from HEAD before this milestone.
