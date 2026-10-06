# Eliminating `str::encode_utf8`'s read-only Lists

Research report; its recommendation is now implemented (see
"Implemented" below). Question:
`web::uri_query_value?` (REFINEMENT-VALUES.md) materializes
`str::encode_utf8(value)` as a fresh `List[Byte]` on every call and only ever
reads it back with `list::length`/`list::at`. In `bench/refined-checks.bot`
that alone is 400 of the 412 Lists. How do we get rid of such allocations,
here and wherever the corpus has the same shape?

**Short answer.** The pattern is really about *reading the characters of a
String one at a time*. `uri_query_value?`'s byte condition is exactly
equivalent to a per-character ASCII condition (see "Is this just about
one-character strings?" below). `esc_char`, the corpus's other site, encodes
a one-character String it has just sliced out. Today's natives offer no
allocation-free way to *classify* one character: you can compare a slice
with `==`, but not get a value you can do arithmetic or set membership on.
Char literals (`'%'`) already exist. What is missing is one operation that
produces a `UnicodeChar` from a String position:
`str::char_at(s, i) -> UnicodeChar errors IndexNotFound`. With it,
plus inline Cranelift fast paths for it and three neighboring ops, both
corpus sites become allocation-free. Both get faster on native, are still
proven repeatable, and give identical results on all four backends. I
recommend that, not a byte-level native and not a compiler-side elision.

| program (native, cranelift) | Lists before → after | all objects before → after | best run before → after | machine code before → after |
|---|---|---|---|---|
| `bench/refined-checks.bot` | 412 → 9 | 7223 → 6817 | 475 → 430 µs (noise-dominated, see below) | 9371 → 11236 B |
| `bench/uri-steady.bot` (`uri_escape_text` × 2000) | 14009 → 9 | 38511 → 10511 (1.73 MB → 0.90 MB) | 4045 → 2188 µs (−46%) | 5444 → 6972 B |
| `query-value-steady.bot` (`uri_query_value?` × 2000) | 2009 → 9 | 2011 → 11 | 356 → 238 µs (−33%) | 4509 → 4811 B |
| `examples/refinement/refined-strings.bot` | 15 → 9 | 37 → 26 | 2.4 → 1.9 µs | 9393 → 11245 B |

(The 9 remaining Lists are module-level literals and `byte::set`'s
construction, built once.)

## Implemented

The recommendation (§4) is in the tree. It differs from the measured
prototype (`audit/encode-utf8-allocation/prototype/char-at.patch`) in one
respect. The prototype gave `VEq` a UnicodeChar fast path in codegen, which
put a tag test in front of *every* generic equality. Instead,
`native::lower::NativeCallOp` now picks a new NIR op `chareq` (word
equality, never fails) when both operands of `==` are statically
`UnicodeChar`, the same way it already picks `ieq`/`streq`.

What changed:

* **`core/strings.tcl`**: `str::char_at` (reference implementation and
  registration, `-bounds {index str 0 1}`).
* **`hir/completions.tcl`**: `IndexBounds`' `str` family is now measured
  against the String's scalar length.
* **`native/lower.tcl`**:
  * `str::char_at` → `strcharat`, with `strcharatproven` as its proven
    sibling;
  * `chareq`.
* **`native/src/nir.rs`**: the ops `StrCharAt`, `StrCharAtProven`, `CharEq`.
* **`native/src/runtime/ops.rs`**: `rt_str_char_at[_proven]`, with unit
  tests.
* **`native/src/codegen/clif.rs`**: inline `StrLen`, `CharCodepoint`,
  `StrCharAtProven` (ASCII byte load, helper otherwise) and `CharEq`. The
  now-unreachable helper-table entries for `StrLen`/`CharCodepoint` are
  removed.
* **`lib/web.bot`**: `uri_query_value?` and `uri_escape_text` read
  characters with `str::char_at`. `esc_char`/`esc_bytes` are replaced by
  `pct`/`cont`/`esc_scalar`, and `esc_from` makes three tail calls.
* **Docs**: README's intrinsics table, STDLIB-NAMESPACES.md's `str`
  inventory.

Measured on the implemented tree (`results/implemented.txt`, best of 10 × 20
runs; same tools as everywhere else here):

| program | Lists | objects | best run | machine code |
|---|---|---|---|---|
| `query-value-steady.bot` | 2009 → 9 | 2011 → 11 | 356 → 200 µs (−44%) | 4509 → 4661 B |
| `bench/uri-steady.bot` | 14009 → 9 | 38511 → 10511 | 4045 → 2170 µs (−46%) | 5444 → 6972 B |
| `bench/refined-checks.bot` | 412 → 9 | 7223 → 6817 | 475 → 462 µs (noise) | 9371 → 11086 B |
| `examples/refinement/refined-strings.bot` | 15 → 9 | 37 → 26 | 2.4 → 2.1 µs | 9393 → 11095 B |

The inline `str::length` also shortens unrelated programs a little. In the
regenerated `audit/native-scalar-asm` corpus:
* `examples/stdlib/csv.bot` goes 5968 → 5958 B with 4 fewer helper calls;
* `ai_text_clean.bot` goes 2611 → 2547 B.

Tests:

* **`tests/str-char-at.test` (new, 14 tests)**: the native's contract,
  four-way:
  * values over 1-, 2-, 3- and 4-byte scalars;
  * equality with char literals, and agreement with `str::substring`;
  * `IndexNotFound` for -1, the length, past the end, `""` and a BigInt;
  * the unhandled-obligation compile error;
  * the proven op under a guard, the checked op otherwise, and `chareq`
    instead of `veq`;
  * a call through a first-class `str::char_at` value;
  * repeatability of a predicate over it;
  * zero allocations for a non-ASCII scan.
* **`tests/native-uri-escape.test` (+12 tests and cases)**:
  * escaping parity with the independent Tcl reference at every UTF-8 width
    boundary, and more query-value cases;
  * `uri_escape_text` repeatability;
  * "no per-call allocation" pins (List and String counts identical at 10
    and 50 calls; no per-character List in the escaping);
  * an NIR pin: `valid_from?`, `upper_hex?` and `esc_from` read with
    `strcharatproven`, and none has `strutf8bytes`/`listlen`/`listget*`.

  The three new allocation/NIR pins fail against the old `lib/web.bot` and
  pass against the new one.
* **Updated structural pins.** These named the removed
  `esc_char`/`esc_bytes` or counted the old allocations; each keeps the
  property it checked, retargeted to the new helper:
  * `native-block-escape`: the refined-checks allocation pin
    (7220/6804/412 → 6814/6801/9) and the tail-call count (5 → 6);
  * `hir-callable-target` and `setcontains-equality-total`: the caller of
    `web::is_unreserved` is now `esc_from`, still a direct call, and the
    edge is still `may_error=false`;
  * `virtual-construction`: the URI helper family, and Strings 47500/16000 →
    39500/2000;
  * `stdlib-namespaces`/`imports`: the `str` inventory.
* **`audit/encode-utf8-allocation/tools/fuzz.tcl` (new)**: a differential
  fuzzer for both functions against a Tcl oracle over UTF-8 bytes, on all
  four backends. Seed 20261006: 1000 strings, 0 disagreements. It catches
  three hand-made mutations of the library: a wrong 3-byte lead byte, `G`
  accepted as a hex digit, and `'%'` replaced by `'#'`.

Validation:
* `cargo test --release`: 186 + 31 passed.
* Full Tcl suite: the only failures were the pins listed above, and each
  updated file passes when rerun.
* `BOTLISH_NATIVE_GC_STRESS=1` on `str-char-at.test` and
  `native-uri-escape.test`: 51/51 passed.
* `audit/refinement-values/tools/fuzz.tcl -seed 7 -count 300`: 0 failures.

## How this was measured

* Tcl 9.0.1 from the Ubuntu 25.04 packages (AGENTS.md), `LANG=C.utf8`, rustc
  1.97, `cargo build --release`. Cloud x86-64 container. Timings are noisy:
  the same unchanged program varied by ±10% between batches (refined-checks
  read 496, 475 and 427 µs on the same code).
* `audit/encode-utf8-allocation/tools/measure.tcl ?-root TREE? ?-fn NAME ...?
  PROGRAM` prints:
  * the value on interp, compile, cranelift-generic (`-specialize 0`) and
    cranelift;
  * `native::allocationReport HIR summary`, every kind;
  * `native::codeSize`, total and per NIR function name, all instances
    summed;
  * the best of K × `native::measure HIR 20` (K = 10 for the final
    numbers);
  * `hir::repeatable::explain` of each named module function.
* Prototypes were built in scratch copies of the tree, each with its own
  `native/target`. `-root` points the tool at one. The patches are in
  `audit/encode-utf8-allocation/prototype/` and the raw outputs in `.../results/`.
* New measurement programs live in `audit/encode-utf8-allocation/programs/`:
  * `query-value-steady.bot`: the predicate alone, over six inputs of 4 to 33
    bytes. Four are accepted. Two are rejected: `café` (non-ASCII) and `a%2fb`
    (lowercase hex).
  * `escape-parity.bot`: the semantic check.
* Allocation sites came from `native::allocationReport HIR sites` +
  `native::allocationText`.

## 1. Census

I ran a site-level allocation report on every `bench/*.bot`,
`examples/{stdlib,surface,linux,abi,refinement}/*.bot`. `09-mutual-recursion`
is a deliberate compile error. I also grepped `lib/**/*.bot` for producers.

**`str::encode_utf8` call sites in the corpus: four, two dynamic.**

| site | input | consumers | escapes? | allocations (native) |
|---|---|---|---|---|
| `lib/web.bot` `uri_query_value?`: `bytes = str::encode_utf8(value)` | whole argument | `list::length`, `list::at` in the lifted locals `valid_from?`/`upper_hex?` (it is passed to them as a trailing capture parameter) | no | one List per call: 400 in refined-checks (25.6 KB), 2009 in query-value-steady |
| `lib/web.bot` `esc_char`: `bytes = str::encode_utf8(c)` | a one-character String `esc_from` just sliced out with `str::substring(text, i, i + 1)` | `list::length`, `list::at(bytes, 0)`, and forwarded to `esc_bytes` (again only length/at) | no | one List per *character*: 14000 in uri-steady (468 KB, 27% of its bytes), plus the 14000 one-character Strings it encodes (366 KB) |
| `examples/linux/write.bot`, `context-hello.bot` | literal | `abi::bytes::from_list` | — | none: already a static constant (`native/lower.tcl` `StaticBytesCall`/`ConstantBytesOf`) |

`uri-steady`'s allocations are dominated by this: 14000 Lists from
`esc_char`, 14000 Strings from the `substring` feeding it, of 38511 objects.

**Other "materialized only to be read back" Lists** (same shape, different
producers):

| site | what is built | read by | allocations |
|---|---|---|---|
| `bench/lex-strategy.bot` `chars_of` | a List of one-character Strings, by `list::append` recursion | `loop c in` once, and `list::all?` | 164 Lists (132 appends + 32 news) |
| `bench/source-checks.bot` `classify_leading` | a List of 4 Bools, by a collecting loop over a List of predicates | `list::get(flags, 0/2, ...)` | 105 Lists |

Both are deliberately higher-order list benchmarks. A List built by
append-recursion or a collecting loop is a deforestation/fusion problem,
not an `encode_utf8` one. `hir/escape.tcl` handles fixed-shape aggregates
with constant indices only and explicitly not these (§2.4). They are out
of scope here. `chars_of` is the same "characters of a String" shape,
though, and a `str::char_at` loop would express it directly. Nothing else
in `examples/stdlib` allocates per element in this shape. The remaining
List allocations there are once-only literals.

## 2. Existing machinery

The full audit (file:line citations) was done against the current tree. In
summary:

1. **String regions** (`hir/stringregion.tcl`, STRING-VIEW-ALLOCATIONS.md).
   * A `(base, start, end)` character range kept in registers. It is
     produced by `str::substring` and literals.
   * Consumers: `==` (`regioneq`), `str::length`, and
     `is_tcl_alpha`/`is_tcl_alnum`.
   * It crosses calls only as a result, never as a parameter. It indexes by
     scalar, not byte.
   * STRING-VIEW-ALLOCATIONS.md lists "E. UTF-8 encode, `esc_char`'s
     `encode_utf8(c)`" as explicitly unchanged.
   * It is why a `c = str::substring(value, i, i + 1); c == "%"` costs no
     allocation (§3a).
2. **Short strings** (SHORT-STRING*.md, `native/shortstring.tcl`).
   * Packed-ASCII and one-scalar register tiers.
   * `esc_char`'s `c` is the docs' own canonical example of a "tagged-only"
     parameter that fails the demand rule (SHORT-STRING.md). Its only uses
     are `encode_utf8` and a return, so `esc_from` materializes it every
     character (`substrproven`, plus `asciitostr` of `text`).
   * `uri_query_value?`'s argument is unbounded, so the tiers don't apply.
3. **STRING-BYTES-CONSTRUCTION-AUDIT.md** already audited `encode_utf8`.
   * Its finding: every corpus use is immediate, non-escaping and read
     sequentially or by index. It judged the List "architecturally awkward,
     not materially expensive". It lists a compiler-internal UTF-8 span as
     missing.
   * That judgment predates `uri_query_value?` running 400–2000 times per
     program.
   * The static-Bytes path covers only `abi::bytes::from_list` of a
     statically known String.
4. **Scalar replacement / parameter aggregates / virtual construction**
   (`hir/escape.tcl`, NATIVE-PARAM-AGGREGATE.md, M8A).
   * Lists qualify only when fixed-shape, with every use `list::at` at a
     constant index. Unknown-length Lists are excluded by design.
   * A captured binding is never virtual.
   * M8A plans must be flattened before any read, and its doc names
     `encode_utf8(c)` as a flat-only barrier.
   * None fits a dynamic-length, dynamically indexed byte List.
5. **Escape analysis**.
   * `hir/blockescape.tcl` covers closures only. It is what lambda-lifts
     `valid_from?`/`upper_hex?` and turns `bytes` into a trailing tagged
     parameter (`native/lower.tcl` `InternalFunction`).
   * **No analysis proves "this List only flows to `list::length`/`list::at`
     (dynamic index)/forwarding."** That is the missing piece for any
     compiler-side elision (§3c).
6. **Exact value facts** (`hir/exactvalue.tcl`): bounded to 8 elements and
   forgotten at parameters. No `encode_utf8` case except the constant-Bytes
   path. Irrelevant for a dynamic `value`.
7. **Bytes / MutableBytes**: no String view, no indexing (ABI-BYTES.md:
   "slicing, indexing, … not provided"), and `from_list` is an eager copy.
   Going through Bytes would add a copy.
8. **Native String representation** (`native/src/runtime/strobj.rs`): one
   heap `StrObj` holding:
   * `chars` (cached scalar count);
   * `byte_len`;
   * an `ascii` flag;
   * the inline UTF-8 text.

   There is no char→byte index cache, so non-ASCII indexing seeks from byte
   0 (`utf8SeekBytes`). Reading "character i" of an ASCII String is one
   byte load at a constant offset; Cranelift already does exactly that
   inline in `StrToShort`. `UnicodeChar` is a tagged immediate (`cp << 3 |
   4`), so producing one never allocates.
9. **Specialization / representation-changing parameters**.
   * Instance keys are semantic kinds; captures aren't in the key.
   * Representation changes (`rawparams`, `asciiparams`, `fields`, plan
     params, traversal's hidden byte offset) are per-instance planners with
     the canonical function as fallback. None of them applies to a trailing
     capture parameter.

**Unicode char literals** exist (UNICODE-CHAR-LITERALS.md: `'%'`,
`byte::set(['-', '.', '_', '~'])`). But the only operation on a
`UnicodeChar` is `char::scalar_value`. Nothing produces a `UnicodeChar`
from a String: no char-at, no character iteration of a String, and no
String→UnicodeChar conversion (that doc's "Deferred" list).

**A latent gap found on the way.** `core::native::ValidBounds` accepts
`-bounds {index str C I}`. But `hir::completions::IndexBounds` has no `str`
branch, so such a native's index would be measured against
`hir::cardinality::Capacity` (a MutableArray capacity atom) and never be
proven. No registered native uses `index str` today, so it is harmless. Any
string-indexing native needs the one-line fix in the prototype patch.

## Is this just about one-character strings?

Partly, and that is the useful way to see it:

* **`esc_char` is exactly a one-character-String problem.** `esc_from`
  slices out a one-character String, and `esc_char` encodes it into a 1–4
  element List just to ask "is it ASCII, and which byte is it?" Both the
  String and the List exist only to classify one Unicode scalar.
* **`uri_query_value?` encodes the whole value, but its proposition reduces
  to a per-character one.** Every byte of a multi-byte UTF-8 sequence is ≥
  0x80, so it is never an unreserved character, never `%` (37), and never a
  hex digit (48–57, 65–70). A string with any non-ASCII scalar is therefore
  rejected by the byte rule, and by a rule that rejects non-ASCII scalars.
  The rejection may come at a different position, but the predicate returns
  only a Bool and has no other effect. For an all-ASCII string, byte index
  = character index and byte value = scalar value, so the two rules are
  the same automaton over the same sequence. Hence: *every byte is
  unreserved or starts an uppercase `%XX`* ⇔ *every scalar is ASCII and every
  scalar is unreserved or starts an uppercase `%XX`*.

So yes: with a way to read a String position as a `UnicodeChar`, char
literals (`c == '%'`) plus `char::scalar_value` arithmetic express both
sites with no List and no one-character String. That missing operation is
the whole story. Using only today's natives, the one-character Strings
can't be classified cheaply (§3a).

## 3. Options, measured

`query-value-steady.bot` isolates the predicate. `refined-checks.bot` is
dominated by `emailish?` (6804 Strings), so its time barely registers any
of this. Code sizes are `native::codeSize`.

### (a) Source-only rewrite with existing natives

Two exact rewrites over `str::substring(value, i, i + 1)` per character,
relying on the ASCII equivalence above. Patches:
`prototype/source-only-sets.patch`, `source-only-equality.patch`.

| `query-value-steady` | current | A1: `immutable_set::contains` of one-character Strings | A2: `c == "A" or c == "B" or …` (66/16-way `==` chains) |
|---|---|---|---|
| Lists / Strings | 2009 / 0 | 11 / 17667 | 9 / 0 |
| best run | 358 µs | 4224 µs | 3070 µs |
| code (valid_from? + upper_hex?) | 1082 B | 1256 B | 7552 B |
| all four backends agree, repeatable | yes | yes | yes |

* **A1** removes the List but allocates one String per classified character.
  `immutable_set::contains` is not a region consumer, so the slice
  materializes (`shorttostr`/`substr` sites). The set is also a linear
  `equal` scan of 66 elements (`rt_set_contains`). It is 12× slower.
* **A2** is allocation-free, which confirms `==` on a slice is a region
  comparison, but each `==` is an `rt_str_region_eq` helper call. It is
  8.6× slower, its code is 7× larger, and the source is unreadable.

Verdict: not viable. The List version is already fast on ASCII: an inline
`listgetproven` plus a raw compare per byte. Any replacement has to beat
that, not merely allocate less.

### (b) A library/native addition: `str::char_at`

**Semantics.** `str::char_at(s: str, i: int) -> UnicodeChar errors
IndexNotFound`: the Unicode scalar at character index `i` (the index space
of `str::length`/`str::substring`), for `0 <= i < str::length(s)`. Any other
Int fails with the declared builtin `IndexNotFound`, exactly like
`list::at`. It is total over its domain, context-free, and never allocates
(a `UnicodeChar` is an immediate). Registration:

```tcl
core::native::register str::char_at -arity 2 -impl core::strings::charAt \
    -param-types {str int} -result-type UnicodeChar -runtime {char-index range-check} \
    -context-free 1 -errors IndexNotFound -bounds {index str 0 1}
```

**Per backend (prototype, `prototype/char-at.patch`, ~330 lines):**

* **interp / compile** (`core/strings.tcl`): `string index` + `scan %c` into
  `core::value::char`. Tcl strings index scalars in O(1), so this is cheaper
  per call than `encodeUtf8`'s O(n) `encoding convertto` + `split` +
  per-byte boxing. Measured on query-value-steady: compile 674 → 571 ms;
  interp 25.7 → 30.1 s (one more native dispatch per character; the
  reference interpreter is slow either way). uri-steady: within 3% on both.
* **cranelift-generic / cranelift**: NIR ops `strcharat` (checked, error
  exit) and `strcharatproven` (via `native::lower`'s `provenOps` once
  `hir::completions` proves the bound).
  * Runtime helpers `rt_str_char_at[_proven]`: an ASCII String is a byte
    load; otherwise a forward decode from byte 0, the same seek `rt_substr`
    already pays and records in `utf8SeekBytes`.
  * Index-bounds proofs: one line in `hir::completions::IndexBounds`
    (the `str` family gap above), so `i >= str::length(value)` guards prove
    the read exactly as `list::length` guards prove `list::at` today.
* **Inline Cranelift fast paths** (`native/src/codegen/clif.rs`). These turn
  out to be what decides it. A first version without them was
  allocation-free but *slower* than the List (451 vs 358 µs). The NIR
  showed four helper calls per character: `strlen`, `strcharatproven`,
  `veq` (for `c == '%'`) and `charcodepoint`. The List version had one
  (`listlen`; `listgetproven` is already inline). The prototype inlines:
  * `StrLen`: a load of `chars` and a re-tag;
  * `CharCodepoint`: a shift and a re-tag;
  * `StrCharAtProven`: the `ascii` flag and one `uload8` on ASCII, with the
    helper on non-ASCII;
  * a `VEq` fast path when both operands carry the `UnicodeChar` tag (word
    compare).

  `StrLen` and `VEq` benefit every program, not just these. Rebuilding the
  *unchanged* library on these codegen changes moved nothing beyond noise
  (`results/final-batch.txt`, "treeD").

**Library source after the change** (the `uri_query_value?` half; the
predicate keeps `is_unreserved(b: Byte)`; `v` is proven 0..127 by the `v >
127` guard plus `char::scalar_value`'s `nonneg` range, so it passes as a
`Byte`):

```botlish
fn uri_query_value?(value: str) -> bool proves value: UriQueryValue:

    fn upper_hex?(i):
        if i < 0 or i >= str::length(value):
            false
        else:
            v = char::scalar_value(str::char_at(value, i))
            if v > 127:
                false
            else:
                ascii::is_digit(v) or (v >= 65 and v <= 70)

    fn valid_from?(i):
        if i < 0 or i >= str::length(value):
            true
        else:
            c = str::char_at(value, i)
            if c == '%':
                if upper_hex?(i + 1) and upper_hex?(i + 2):
                    valid_from?(i + 3)
                else:
                    false
            else:
                v = char::scalar_value(c)
                if v > 127:
                    false
                else:
                    if is_unreserved(v):
                        valid_from?(i + 1)
                    else:
                        false

    valid_from?(0)
```

For `uri_escape_text`, `esc_char`/`esc_bytes` are replaced:

* the non-ASCII case computes the UTF-8 bytes arithmetically (`bit_or(192,
  shift_right(v, 6))`, continuation bytes `bit_or(128, bit_and(shift_right(v,
  k), 63))`, 2/3/4-byte forms by the 0x800/0x10000 thresholds);
* an unreserved ASCII character appends `str::substring(text, i, i + 1)`;
* anything else appends `pct(v)`.

The three outcomes must be three tail calls, not one `piece = if …` joined
before a single `str::concat(acc, piece)`. The joined form produced 16500
StringPlan nodes instead of 8500 and was 50% slower (3276 vs 2188 µs): the
`if` value forces every branch's piece into a plan node. That cost is M8A's,
not this design's, but it is a trap a reviewer should know about.

**Results** (`results/final-batch.txt`, best of 10 × 20 runs):

| | current | `str::char_at` + inline paths |
|---|---|---|
| query-value-steady: Lists, objects | 2009, 2011 | 9, 11 |
| query-value-steady: best | 355.5 µs | 237.5 µs |
| query-value-steady: valid_from? + upper_hex? + uri_query_value? code | 1213 B | 1507 B |
| uri-steady: Strings / Lists / StringPlans | 16000 / 14009 / 8500 | 2000 / 9 / 8500 |
| uri-steady: allocated | 1.73 MB | 0.90 MB |
| uri-steady: best | 4045 µs | 2188 µs |
| uri-steady: esc_* code | esc_from 692 + esc_char 367 + esc_bytes 642 = 1701 B | esc_from 1476 + esc_scalar 1255 = 2731 B |
| refined-checks: Lists, objects | 412, 7223 | 9, 6817 |
| refined-checks: best | 475 µs | 430 µs (the unchanged library on the new codegen read 427: inside noise) |
| refined-checks: total code | 9371 B | 11236 B |

The remaining 2000 Strings in uri-steady are the results themselves.

**Repeatability.** `hir::repeatable::explain` is `""` (proven) for both
`web::uri_query_value?` and `web::uri_escape_text` before and after.
`str::char_at` is `-context-free 1`; `char::scalar_value` already is. The
refined-checks inner `emailish?` stays decided.

**Parity.** `programs/escape-parity.bot` covers:
* `""`, `a b`, `é`, `😀`, `50%`, `déjà vu`, `世界`, `~-._`;
* `%41%4a` (lowercase hex) and `%4` (truncated);
* every UTF-8 width boundary (U+007E, U+0080, U+07FF, U+0800, U+FFFF,
  U+10000, U+10FFFF).

For each input it checks `uri_escape_text(t)`, `uri_query_value?(escape(t))`
and `uri_query_value?(t)`. All four backends give identical output on the
current tree and on the prototype, and the two trees agree. Every program
above also agrees across backends and trees. Under
`BOTLISH_NATIVE_GC_STRESS=1`, the prototype's parity program and uri-steady
give the same values.

**Existing tests against the prototype.** `native-uri-escape`,
`refinement-values` (including the refined-checks NIR and machine-code
pins), `emailish-predicate`, `native-string-view`, `unicode-char` and
`stdlib-namespaces`: 299 of 301 pass. The two failures are
`stdlib-namespaces.test`'s inventory pins, which list `str`'s members and
gain `char_at`. They would be updated with the change.

**Costs and risks.**

* **Non-ASCII seeks.** On non-ASCII Strings each `char_at` seeks from byte 0,
  like `substring` already does: uri-steady's `utf8SeekBytes` went 24000 →
  30500, and query-value-steady's 0 → 1998 (the `café` input). The byte
  List had O(1) indexing on non-ASCII input. For the predicate this is
  bounded (it stops at the first non-ASCII scalar). For `esc_from` it is the
  same O(n²) behavior `esc_from` has today through `substring`.
  `hir/traversal.tcl`'s hidden byte-offset traversal is the fix for both,
  once it accepts a `char_at` "peek".
* **One new root native in `str`.** It needs its error contract, the
  `IndexBounds` fix, the two inventory pins, and `rt_*` tests mirroring
  `utf8_bytes_*` in `ops.rs`.
* **Code size grows** by roughly 1.9 KB on refined-checks, mostly the
  arithmetic UTF-8 encoder (`esc_scalar`), which `esc_char` used to get for
  free from the List.

A **byte-level native instead** (`str::utf8_byte_at(s, i) -> Byte` plus
`str::utf8_byte_count(s)`) would keep the source byte-shaped and give O(1)
non-ASCII indexing. But it needs:
* a new size form (`blen`) in `hir/cardinality.tcl` and `IndexBounds` to
  prove its reads;
* a new scalar `-result-shape` to type the result as `Byte` (today's
  `typed` shape is List-element-only);
* an O(n) `encoding convertto` per call in the reference backends (O(n²)
  per predicate on interp/compile).

It also does not help `esc_char`'s one-character String, which would still
be sliced and materialized. I did not build it. Its native speed on ASCII
should match `char_at`'s (same one-byte load).

### (c) Compiler-side elision of a non-escaping `encode_utf8`

Not prototyped. What it would take:

1. **A non-escape proof for a dynamically indexed List.** No such analysis
   exists. `hir/escape.tcl`'s use classifier (`UseTag`/`NativeUseTag`) and
   `Eligible` fixpoint are the closest scaffold. They would need to accept
   `list::at` at a *dynamic* index, `list::length`, and forwarding into an
   exact callee's parameter *including a lifted capture* (today a capture is
   never virtual). Soundness rests on Lists being immutable values with no
   identity: if every use of `bytes` is a length or element read (or a
   forward to a parameter all of whose uses are such reads), no code can
   observe whether a List object exists. `list::at`'s `IndexNotFound`
   completion must be preserved: the proven/unproven split stays, measured
   against the byte length.
2. **A representation change for the forwarded parameter.** The String
   instead of the List, in the `valid_from?`/`upper_hex?` internal variants.
   That is a new planner position over trailing capture parameters, with
   the List-taking canonical function as fallback (the `fields`/`CanSupply`
   discipline).
3. **Two new NIR ops**: `strbytelen` (exists, but as a helper call: needs an
   inline path) and an inline `strbyteat`. Plus the rewrite `listlen(bytes)
   → strbytelen(s)`, `listget[proven](bytes, i) → strbyteat(s, i)`, keyed on
   `str::encode_utf8`'s resolved identity, as `ConstantBytesOf` already
   matches it.

It would fix `uri_query_value?` without a source change, with O(1)
non-ASCII byte indexing. But it would not touch `esc_char`'s one-character
String, and that, not the List, is half of uri-steady's per-character cost.
It would not generalize to the census's other shapes (append-built and
loop-built Lists). It is the largest and riskiest of the three, roughly
`hir/escape.tcl`-sized: a new interprocedural analysis, a new parameter
representation, new ops, and GC-root changes for a parameter that becomes a
String. It is also the hardest to keep fuzz-stable. Repeatability is
unaffected (the predicate's HIR is unchanged). I could not measure its
runtime. Its ASCII hot path would be the same one-byte load as (b)'s, so I
would expect (b)'s numbers on ASCII input, minus the `char_at`
non-ASCII seek.

## 4. Recommendation

1. **Add `str::char_at`** as specified in (b), with:
   * the one-line `hir::completions::IndexBounds` `str`-family fix;
   * the four inline Cranelift paths (`StrLen`, `CharCodepoint`,
     `StrCharAtProven`, `UnicodeChar` `VEq`).

   The inline paths are not optional: without them the change is a
   regression on time.
2. **Rewrite `lib/web.bot`'s `uri_query_value?` and `uri_escape_text`**
   over it, as above. Keep three tail calls in `esc_from`, delete
   `esc_char`/`esc_bytes`, and update `lib/web.bot`'s header comment
   (which describes `esc_char`'s `List[Byte]` typing). `str::encode_utf8`
   stays for genuinely byte-oriented consumers (`abi::bytes::from_list`).
3. **Pins:**
   * a `tests/native-uri-escape.test`-style parity test over
     `programs/escape-parity.bot`'s inputs, on all four backends;
   * an allocation pin on `bench/uri-steady.bot` and refined-checks
     (Lists ≤ 9, no `strutf8bytes` site) via `native::allocationReport`;
   * NIR pins that `valid_from?` contains `strcharatproven` and no `listlen`
     (proves the bound and the absence of the List);
   * `hir::repeatable::explain` = `""` for both functions (already pinned
     for `uri_query_value?`; add `uri_escape_text`);
   * `str::char_at` contract tests: out-of-range and negative index →
     `IndexNotFound` on all backends, astral scalars, empty String;
   * `ops.rs` unit tests for the ASCII and non-ASCII helper paths;
   * a GC-stress run of the escape tests;
   * the two `stdlib-namespaces.test` inventory updates;
   * `audit/refinement-values/tools/fuzz.tcl`, since the predicate's body
     changes.
4. **Later, separately:** teach `hir/traversal.tcl` to carry the byte offset
   through a `char_at` scan, which removes the non-ASCII seeks for both
   `char_at` and `substring`. A `chars_of`-style rewrite of
   `bench/lex-strategy.bot` would then be a natural follow-up, but that
   benchmark is about list building and should keep doing it.
5. **Not recommended now:** (c), and the byte-level natives. Neither
   reaches `esc_char`'s one-character String, and (c) is far more
   machinery than the two call sites justify.

**Expected corpus-wide effect.** The only dynamic `encode_utf8` calls in the
corpus are these two:
* refined-checks: −403 Lists (6817 objects, below even the
  pre-milestone 6823);
* uri-steady: −14000 Lists and −14000 Strings (−73% objects, −48% bytes,
  −46% time);
* refined-strings: 37 → 26 objects.

The inline `StrLen`/`UnicodeChar`-equality paths apply to every program but
showed no measurable change on the unchanged library. No other corpus
program allocates in this shape.

## What I could not determine

* Option (c)'s actual runtime and code size (not built), and the byte-level
  natives' (not built). Their numbers above are reasoned, not measured.
* Timing differences under ~10% on refined-checks: run-to-run noise on this
  machine is that large, and that program is dominated by `emailish?`.
* Windows-native (non-WSL) behavior of the prototype: only Linux x86-64 was
  run. The full test suite was not run against the prototype, only the six
  files listed.
